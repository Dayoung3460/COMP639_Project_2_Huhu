"""helpdesk.py — Support ticket submission and tracking (P2-49, P2-50)."""

import logging
import os

from flask import flash, redirect, render_template, request, session, url_for, abort
from app import app, db
from app.utils import role_required, sniff_image_kind
from app.helpers.dbHelper import insert_notification

logger = logging.getLogger(__name__)

SCREENSHOT_EXTENSIONS = {'jpg', 'jpeg', 'png', 'webp'}
SCREENSHOT_MAX_BYTES   = 5 * 1024 * 1024  # 5 MB

TICKET_TYPES      = ('Help', 'Bug Report')
TICKET_PRIORITIES = ('Low', 'Medium', 'High')
TICKET_STATUSES   = ('New', 'Open', 'Stalled', 'Resolved')
# Statuses the ticket owner can set — 'New' is auto-only, never manually re-set
OWNER_STATUSES    = ('Open', 'Stalled', 'Resolved')


def _change_status(ticket_id, old_status, new_status, changed_by, note=None):
    """Update ticket status, log to history, return True if changed."""
    if old_status == new_status:
        return False
    with db.get_cursor() as cursor:
        cursor.execute(
            'UPDATE support_tickets SET status = %s, updated_at = CURRENT_TIMESTAMP '
            'WHERE ticket_id = %s',
            (new_status, ticket_id)
        )
        cursor.execute(
            'INSERT INTO ticket_status_history '
            '(ticket_id, old_status, new_status, changed_by, note) '
            'VALUES (%s, %s, %s, %s, %s)',
            (ticket_id, old_status, new_status, changed_by, note or None)
        )
    return True


def _screenshot_dir(ticket_id):
    return os.path.join(app.root_path, '..', 'static', 'uploads', 'tickets', str(ticket_id))


def _validate_screenshot(file):
    """Returns (ext, err). On success err is None and file stream is seeked to 0."""
    if not file or not file.filename:
        return None, None  # optional — no file is fine

    ext = file.filename.rsplit('.', 1)[-1].lower() if '.' in file.filename else ''
    if ext not in SCREENSHOT_EXTENSIONS:
        return None, 'Screenshot must be JPG, PNG, or WEBP.'

    file.stream.seek(0, os.SEEK_END)
    size = file.stream.tell()
    file.stream.seek(0)
    if size > SCREENSHOT_MAX_BYTES:
        return None, 'Screenshot must be under 5 MB.'

    head = file.stream.read(1024)
    file.stream.seek(0)
    sniffed = sniff_image_kind(head)
    ext_norm     = 'jpg' if ext == 'jpeg' else ext
    sniffed_norm = 'jpg' if sniffed == 'jpeg' else (sniffed or '')
    if not sniffed_norm or sniffed_norm not in ('jpg', 'png', 'webp'):
        return None, "Screenshot file contents don't match the extension."
    if sniffed_norm != ext_norm:
        return None, "Screenshot file contents don't match the extension."

    return ext, None


def _save_screenshot(ticket_id, file, ext):
    """Writes the uploaded file and returns the DB-storable relative path."""
    ticket_dir = _screenshot_dir(ticket_id)
    os.makedirs(ticket_dir, exist_ok=True)
    filename  = f'screenshot.{ext}'
    disk_path = os.path.join(ticket_dir, filename)
    file.save(disk_path)
    return f'uploads/tickets/{ticket_id}/{filename}'


# ── Submit form ───────────────────────────────────────────────────────────────

@app.route('/support/submit', methods=['GET', 'POST'])
@role_required()
def helpdesk_submit():
    """Submit a support request or bug report."""
    if session.get('group_role') in ('Support Technician', 'Super Admin'):
        abort(403)

    if request.method == 'GET':
        return render_template('helpdesk/submit.html',
                               ticket_types=TICKET_TYPES,
                               priorities=TICKET_PRIORITIES,
                               data={}, errors={})

    data = {
        'request_type': request.form.get('request_type', '').strip(),
        'title':        request.form.get('title', '').strip(),
        'description':  request.form.get('description', '').strip(),
        'priority':     request.form.get('priority', '').strip(),
    }
    errors = {}

    if data['request_type'] not in TICKET_TYPES:
        errors['request_type'] = 'Select a request type.'
    if not data['title']:
        errors['title'] = 'Title is required.'
    if not data['description']:
        errors['description'] = 'Description is required.'
    if data['priority'] not in TICKET_PRIORITIES:
        errors['priority'] = 'Select a priority.'

    screenshot_file = request.files.get('screenshot')
    ext, ss_err = _validate_screenshot(screenshot_file)
    if ss_err:
        errors['screenshot'] = ss_err

    if errors:
        return render_template('helpdesk/submit.html',
                               ticket_types=TICKET_TYPES,
                               priorities=TICKET_PRIORITIES,
                               data=data, errors=errors)

    user_id  = session['user_id']
    group_id = session.get('group_id')

    with db.get_cursor() as cursor:
        cursor.execute(
            """
            INSERT INTO support_tickets
                (submitted_by, group_id, request_type, title, description, priority)
            VALUES (%s, %s, %s, %s, %s, %s)
            RETURNING ticket_id
            """,
            (user_id, group_id,
             data['request_type'], data['title'], data['description'], data['priority'])
        )
        ticket_id = cursor.fetchone()['ticket_id']

    if ext and screenshot_file:
        try:
            rel_path = _save_screenshot(ticket_id, screenshot_file, ext)
            with db.get_cursor() as cursor:
                cursor.execute(
                    'UPDATE support_tickets SET screenshot = %s WHERE ticket_id = %s',
                    (rel_path, ticket_id)
                )
        except OSError:
            logger.exception('Screenshot save failed for ticket %d', ticket_id)
            flash('Ticket submitted, but the screenshot could not be saved.', 'warning')

    logger.info('User %d submitted support ticket %d (%s)',
                user_id, ticket_id, data['request_type'])
    flash(f'Request #{ticket_id} submitted. We\'ll get back to you as soon as possible.', 'success')
    return redirect(url_for('helpdesk_view', ticket_id=ticket_id))


# ── My requests list ──────────────────────────────────────────────────────────

@app.route('/support/my-requests')
@role_required()
def helpdesk_my_requests():
    """List all support tickets submitted by the current user."""
    if session.get('group_role') in ('Support Technician', 'Super Admin'):
        abort(403)

    user_id     = session['user_id']
    status_filter = request.args.get('status', '').strip()
    sort          = request.args.get('sort', 'date_desc').strip()

    order_clause = 'st.created_at ASC' if sort == 'date_asc' else 'st.created_at DESC'

    params = [user_id]
    where  = 'WHERE st.submitted_by = %s'
    if status_filter in TICKET_STATUSES:
        where  += ' AND st.status = %s'
        params.append(status_filter)

    with db.get_cursor() as cursor:
        cursor.execute(
            f"""
            SELECT st.ticket_id,
                   st.request_type,
                   st.title,
                   st.priority,
                   st.status,
                   st.created_at,
                   st.updated_at,
                   u.first_name || ' ' || u.last_name AS assigned_owner
            FROM   support_tickets st
            LEFT JOIN users u ON u.user_id = st.assigned_to
            {where}
            ORDER BY {order_clause}
            """,
            params
        )
        tickets = cursor.fetchall()

    return render_template('helpdesk/my_requests.html',
                           tickets=tickets,
                           statuses=TICKET_STATUSES,
                           status_filter=status_filter,
                           sort=sort)


# ── View single ticket + post reply ──────────────────────────────────────────

@app.route('/support/my-requests/<int:ticket_id>', methods=['GET', 'POST'])
@role_required()
def helpdesk_view(ticket_id):
    """Detail view for a ticket — submitter sees full history and can add replies."""
    user_id = session['user_id']

    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT st.*,
                   g.name AS group_name,
                   u.first_name || ' ' || u.last_name AS assigned_owner
            FROM   support_tickets st
            LEFT JOIN groups g ON g.group_id = st.group_id
            LEFT JOIN users  u ON u.user_id  = st.assigned_to
            WHERE  st.ticket_id = %s
            """,
            (ticket_id,)
        )
        ticket = cursor.fetchone()

    if not ticket:
        abort(404)

    # Staff should use the dedicated staff view
    if session.get('group_role') in ('Support Technician',):
        return redirect(url_for('helpdesk_ticket', ticket_id=ticket_id))

    if ticket['submitted_by'] != user_id and session.get('group_role') != 'Super Admin':
        abort(403)

    # Handle reply POST
    if request.method == 'POST':
        body = request.form.get('body', '').strip()
        if not body:
            flash('Reply cannot be empty.', 'danger')
        else:
            with db.get_cursor() as cursor:
                cursor.execute(
                    'INSERT INTO ticket_replies (ticket_id, author_id, body) VALUES (%s, %s, %s)',
                    (ticket_id, user_id, body)
                )
                cursor.execute(
                    'UPDATE support_tickets SET updated_at = CURRENT_TIMESTAMP WHERE ticket_id = %s',
                    (ticket_id,)
                )
                # Notify assigned technician if there is one and they are not the commenter
                cursor.execute(
                    'SELECT assigned_to, title FROM support_tickets WHERE ticket_id = %s',
                    (ticket_id,)
                )
                row = cursor.fetchone()

            if row and row['assigned_to'] and row['assigned_to'] != user_id:
                insert_notification(
                    db,
                    row['assigned_to'],
                    f'New comment on support request #{ticket_id}: "{row["title"]}"',
                    'info',
                    url=url_for('helpdesk_ticket', ticket_id=ticket_id)
                )

            logger.info('User %d added reply to ticket %d', user_id, ticket_id)
            flash('Reply added.', 'success')
        return redirect(url_for('helpdesk_view', ticket_id=ticket_id))

    # Fetch replies
    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT tr.reply_id,
                   tr.body,
                   tr.created_at,
                   u.first_name || ' ' || u.last_name AS author_name,
                   u.user_id AS author_id
            FROM   ticket_replies tr
            JOIN   users u ON u.user_id = tr.author_id
            WHERE  tr.ticket_id = %s
            ORDER BY tr.created_at ASC
            """,
            (ticket_id,)
        )
        replies = cursor.fetchall()

    # Fetch status history
    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT tsh.old_status,
                   tsh.new_status,
                   tsh.changed_at,
                   u.first_name || ' ' || u.last_name AS changed_by_name
            FROM   ticket_status_history tsh
            LEFT JOIN users u ON u.user_id = tsh.changed_by
            WHERE  tsh.ticket_id = %s
            ORDER BY tsh.changed_at ASC
            """,
            (ticket_id,)
        )
        status_history = cursor.fetchall()

    return render_template('helpdesk/view_request.html',
                           ticket=ticket,
                           replies=replies,
                           status_history=status_history,
                           current_user_id=user_id)


# ── Support Queue (Super Admin + Support Technician) ─────────────────────────

@app.route('/support/queue')
@role_required('Super Admin', 'Support Technician')
def helpdesk_queue():
    """Centralised support queue — all tickets across the platform."""
    status_filter   = request.args.get('status', '').strip()
    priority_filter = request.args.get('priority', '').strip()
    type_filter     = request.args.get('request_type', '').strip()
    assigned_filter = request.args.get('assigned', '').strip()   # 'unassigned' or ''
    mine_filter     = bool(request.args.get('mine', '').strip())  # checkbox
    sort            = request.args.get('sort', 'priority').strip()

    # Build WHERE conditions
    conditions = []
    params     = []

    if status_filter in TICKET_STATUSES:
        conditions.append('st.status = %s')
        params.append(status_filter)
    if priority_filter in TICKET_PRIORITIES:
        conditions.append('st.priority = %s')
        params.append(priority_filter)
    if type_filter in TICKET_TYPES:
        conditions.append('st.request_type = %s')
        params.append(type_filter)
    if mine_filter:
        conditions.append('st.assigned_to = %s')
        params.append(session['user_id'])
    elif assigned_filter == 'unassigned':
        conditions.append('st.assigned_to IS NULL')

    where = ('WHERE ' + ' AND '.join(conditions)) if conditions else ''

    # Priority sort: High → Medium → Low then by date
    priority_order = "CASE st.priority WHEN 'High' THEN 1 WHEN 'Medium' THEN 2 ELSE 3 END"
    order_map = {
        'priority':   f'{priority_order}, st.created_at ASC',
        'date_asc':   'st.created_at ASC',
        'date_desc':  'st.created_at DESC',
        'updated':    'st.updated_at DESC',
    }
    order_clause = order_map.get(sort, order_map['priority'])

    with db.get_cursor() as cursor:
        cursor.execute(
            f"""
            SELECT st.ticket_id,
                   st.request_type,
                   st.title,
                   st.priority,
                   st.status,
                   st.created_at,
                   st.updated_at,
                   submitter.first_name || ' ' || submitter.last_name AS submitter_name,
                   tech.first_name     || ' ' || tech.last_name     AS assigned_owner,
                   g.name AS group_name
            FROM   support_tickets st
            JOIN   users submitter ON submitter.user_id = st.submitted_by
            LEFT JOIN users tech   ON tech.user_id      = st.assigned_to
            LEFT JOIN groups g     ON g.group_id         = st.group_id
            {where}
            ORDER BY {order_clause}
            """,
            params
        )
        tickets = cursor.fetchall()

    # Counts for the filter badge
    total      = len(tickets)
    unassigned = sum(1 for t in tickets if not t['assigned_owner'])

    return render_template('helpdesk/queue.html',
                           tickets=tickets,
                           total=total,
                           unassigned=unassigned,
                           statuses=TICKET_STATUSES,
                           priorities=TICKET_PRIORITIES,
                           ticket_types=TICKET_TYPES,
                           status_filter=status_filter,
                           priority_filter=priority_filter,
                           type_filter=type_filter,
                           assigned_filter=assigned_filter,
                           mine_filter=mine_filter,
                           sort=sort)


# ── Staff ticket detail (Super Admin + Support Technician) ───────────────────

@app.route('/support/ticket/<int:ticket_id>', methods=['GET', 'POST'])
@role_required('Super Admin', 'Support Technician')
def helpdesk_ticket(ticket_id):
    """Staff ticket detail — reply and status change via POST."""
    user_id = session['user_id']

    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT st.*,
                   g.name AS group_name,
                   submitter.first_name || ' ' || submitter.last_name AS submitter_name,
                   tech.first_name      || ' ' || tech.last_name      AS assigned_owner
            FROM   support_tickets st
            JOIN   users submitter ON submitter.user_id = st.submitted_by
            LEFT JOIN groups g     ON g.group_id        = st.group_id
            LEFT JOIN users tech   ON tech.user_id      = st.assigned_to
            WHERE  st.ticket_id = %s
            """,
            (ticket_id,)
        )
        ticket = cursor.fetchone()

    if not ticket:
        abort(404)

    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT tr.reply_id, tr.body, tr.created_at,
                   u.first_name || ' ' || u.last_name AS author_name,
                   u.user_id AS author_id
            FROM   ticket_replies tr
            JOIN   users u ON u.user_id = tr.author_id
            WHERE  tr.ticket_id = %s
            ORDER BY tr.created_at ASC
            """,
            (ticket_id,)
        )
        replies = cursor.fetchall()

    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT tsh.old_status, tsh.new_status, tsh.changed_at, tsh.note,
                   u.first_name || ' ' || u.last_name AS changed_by_name
            FROM   ticket_status_history tsh
            LEFT JOIN users u ON u.user_id = tsh.changed_by
            WHERE  tsh.ticket_id = %s
            ORDER BY tsh.changed_at ASC
            """,
            (ticket_id,)
        )
        status_history = cursor.fetchall()

    # Technician list for reassign form — exclude current assignee
    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT user_id, first_name || ' ' || last_name AS full_name
            FROM   users
            WHERE  is_support_tech = TRUE AND user_id != %s
            ORDER BY full_name
            """,
            (ticket['assigned_to'] or 0,)
        )
        technicians = cursor.fetchall()

    can_reassign = (
        session.get('group_role') == 'Super Admin'
        or (ticket['assigned_to'] and ticket['assigned_to'] == user_id)
    )
    can_take = (
        session.get('group_role') == 'Support Technician'
        and not ticket['assigned_to']
    )
    can_act = session.get('group_role') == 'Super Admin' or ticket['assigned_to'] == user_id

    if request.method == 'POST':
        action = request.form.get('action')

        if action == 'reply':
            if not can_act:
                abort(403)
            body = request.form.get('body', '').strip()
            if not body:
                flash('Reply cannot be empty.', 'danger')
                return redirect(url_for('helpdesk_ticket', ticket_id=ticket_id))
            with db.get_cursor() as cursor:
                cursor.execute(
                    'INSERT INTO ticket_replies (ticket_id, author_id, body) VALUES (%s, %s, %s)',
                    (ticket_id, user_id, body)
                )
                cursor.execute(
                    'UPDATE support_tickets SET updated_at = CURRENT_TIMESTAMP WHERE ticket_id = %s',
                    (ticket_id,)
                )
            # Auto-transition New → Open on first reply
            if ticket['status'] == 'New':
                _change_status(ticket_id, 'New', 'Open', user_id, note='Auto-opened on first staff reply')
            insert_notification(
                db, ticket['submitted_by'],
                f'Support staff replied to your request #{ticket_id}: "{ticket["title"]}"',
                'info',
                url=url_for('helpdesk_view', ticket_id=ticket_id),
                group_id=ticket['group_id']
            )
            logger.info('Staff %d replied to ticket %d', user_id, ticket_id)
            flash('Reply posted.', 'success')

        elif action == 'status':
            if not can_act:
                abort(403)
            new_status = request.form.get('new_status', '').strip()
            note       = request.form.get('note', '').strip() or None
            if new_status not in OWNER_STATUSES:
                flash('Invalid status.', 'danger')
                return redirect(url_for('helpdesk_ticket', ticket_id=ticket_id))
            if not _change_status(ticket_id, ticket['status'], new_status, user_id, note=note):
                flash('Status unchanged.', 'info')
                return redirect(url_for('helpdesk_ticket', ticket_id=ticket_id))
            insert_notification(
                db, ticket['submitted_by'],
                f'Your request #{ticket_id} "{ticket["title"]}" status changed to {new_status}.',
                'info',
                url=url_for('helpdesk_view', ticket_id=ticket_id),
                group_id=ticket['group_id']
            )
            logger.info('Staff %d changed ticket %d status %s → %s',
                        user_id, ticket_id, ticket['status'], new_status)
            flash(f'Status updated to {new_status}.', 'success')

        return redirect(url_for('helpdesk_ticket', ticket_id=ticket_id))

    return render_template('helpdesk/ticket.html',
                           ticket=ticket,
                           replies=replies,
                           status_history=status_history,
                           current_user_id=user_id,
                           technicians=technicians,
                           can_reassign=can_reassign,
                           can_take=can_take,
                           can_act=can_act,
                           owner_statuses=OWNER_STATUSES)


# ── Take ownership of an unassigned ticket ───────────────────────────────────

@app.route('/support/ticket/<int:ticket_id>/take', methods=['POST'])
@role_required('Support Technician')
def helpdesk_take(ticket_id):
    """Assign the current staff member as owner of an unassigned ticket."""
    user_id = session['user_id']

    with db.get_cursor() as cursor:
        cursor.execute(
            """
            UPDATE support_tickets
            SET    assigned_to = %s, updated_at = CURRENT_TIMESTAMP
            WHERE  ticket_id = %s AND assigned_to IS NULL
            RETURNING submitted_by, title, group_id, status
            """,
            (user_id, ticket_id)
        )
        row = cursor.fetchone()

    if not row:
        flash('This request already has an owner.', 'warning')
        return redirect(url_for('helpdesk_ticket', ticket_id=ticket_id))

    # Auto-transition New → Open when taken
    if row['status'] == 'New':
        _change_status(ticket_id, 'New', 'Open', user_id, note='Auto-opened when taken by staff')

    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT first_name || \' \' || last_name AS full_name FROM users WHERE user_id = %s',
            (user_id,)
        )
        staff = cursor.fetchone()
    staff_name = staff['full_name'] if staff else 'Support staff'

    insert_notification(db, row['submitted_by'],
        f'Your request #{ticket_id} "{row["title"]}" has been picked up by {staff_name}.', 'info',
        url=url_for('helpdesk_view', ticket_id=ticket_id),
        group_id=row['group_id'])

    logger.info('Staff %d took ownership of ticket %d', user_id, ticket_id)
    flash('You are now the owner of this request.', 'success')
    return redirect(url_for('helpdesk_ticket', ticket_id=ticket_id))


# ── Reassign ticket to another technician ────────────────────────────────────

@app.route('/support/ticket/<int:ticket_id>/assign', methods=['POST'])
@role_required('Super Admin', 'Support Technician')
def helpdesk_assign(ticket_id):
    """Reassign an owned ticket to another support technician."""
    user_id = session['user_id']

    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT assigned_to, submitted_by, title, group_id FROM support_tickets WHERE ticket_id = %s',
            (ticket_id,)
        )
        ticket = cursor.fetchone()

    if not ticket:
        abort(404)

    is_super_admin = session.get('group_role') == 'Super Admin'
    is_owner = ticket['assigned_to'] == user_id
    if not is_super_admin and not is_owner:
        abort(403)

    new_assignee_id = request.form.get('new_assignee', type=int)
    if not new_assignee_id:
        flash('Please select a technician.', 'danger')
        return redirect(url_for('helpdesk_ticket', ticket_id=ticket_id))

    # Validate new assignee is actually a support technician
    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT user_id, first_name || \' \' || last_name AS full_name '
            'FROM users WHERE user_id = %s AND is_support_tech = TRUE',
            (new_assignee_id,)
        )
        new_owner = cursor.fetchone()

    if not new_owner:
        flash('Invalid technician selected.', 'danger')
        return redirect(url_for('helpdesk_ticket', ticket_id=ticket_id))

    with db.get_cursor() as cursor:
        cursor.execute(
            'UPDATE support_tickets SET assigned_to = %s, updated_at = CURRENT_TIMESTAMP '
            'WHERE ticket_id = %s',
            (new_assignee_id, ticket_id)
        )

    # Notify the new owner
    insert_notification(db, new_assignee_id,
        f'You have been assigned support request #{ticket_id}: "{ticket["title"]}"', 'info',
        url=url_for('helpdesk_ticket', ticket_id=ticket_id))

    # Notify submitter — no staff names exposed per AC
    insert_notification(db, ticket['submitted_by'],
        f'Your request #{ticket_id} "{ticket["title"]}" has been reassigned to another member of our support team.',
        'info', url=url_for('helpdesk_view', ticket_id=ticket_id),
        group_id=ticket['group_id'])

    logger.info('Staff %d reassigned ticket %d to user %d', user_id, ticket_id, new_assignee_id)
    flash(f'Request reassigned to {new_owner["full_name"]}.', 'success')
    return redirect(url_for('helpdesk_ticket', ticket_id=ticket_id))


# ── Drop ticket back to unassigned queue ─────────────────────────────────────

@app.route('/support/ticket/<int:ticket_id>/drop', methods=['POST'])
@role_required('Super Admin', 'Support Technician')
def helpdesk_drop(ticket_id):
    """Clear the owner of a ticket, returning it to the unassigned queue."""
    user_id = session['user_id']

    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT assigned_to, submitted_by, title, status, group_id FROM support_tickets WHERE ticket_id = %s',
            (ticket_id,)
        )
        ticket = cursor.fetchone()

    if not ticket:
        abort(404)

    if not ticket['assigned_to']:
        flash('This request is already in the queue.', 'warning')
        return redirect(url_for('helpdesk_ticket', ticket_id=ticket_id))

    if ticket['status'] == 'Resolved':
        flash('Resolved requests cannot be dropped.', 'warning')
        return redirect(url_for('helpdesk_ticket', ticket_id=ticket_id))

    is_super_admin = session.get('group_role') == 'Super Admin'
    if not is_super_admin and ticket['assigned_to'] != user_id:
        abort(403)

    with db.get_cursor() as cursor:
        cursor.execute(
            'UPDATE support_tickets SET assigned_to = NULL, updated_at = CURRENT_TIMESTAMP '
            'WHERE ticket_id = %s',
            (ticket_id,)
        )

    insert_notification(db, ticket['submitted_by'],
        f'Your request #{ticket_id} "{ticket["title"]}" is awaiting reassignment by our support team.',
        'info', url=url_for('helpdesk_view', ticket_id=ticket_id),
        group_id=ticket['group_id'])

    logger.info('Staff %d dropped ticket %d back to queue', user_id, ticket_id)
    flash('Request returned to the queue.', 'success')
    return redirect(url_for('helpdesk_ticket', ticket_id=ticket_id))


# ── User Search (P2-60) ──────────────────────────────────────────────────────

@app.route('/support/user-search', methods=['GET', 'POST'])
@role_required('Super Admin', 'Support Technician')
def helpdesk_user_search():
    """Search for users across all groups — Support Technicians and Super Admins only."""
    user_id = session['user_id']
    query   = request.form.get('q', request.args.get('q', '')).strip()
    users   = []

    if query:
        with db.get_cursor() as cursor:
            cursor.execute(
                """
                SELECT u.user_id,
                       u.username,
                       u.first_name || ' ' || u.last_name AS full_name,
                       u.email,
                       u.account_status,
                       u.date_joined,
                       u.last_login,
                       COALESCE(
                           STRING_AGG(g.name || ' (' || gm.role || ')', ', ' ORDER BY g.name),
                           '—'
                       ) AS memberships
                FROM   users u
                LEFT JOIN group_memberships gm ON gm.user_id = u.user_id
                LEFT JOIN groups g             ON g.group_id = gm.group_id
                WHERE  (u.first_name || ' ' || u.last_name ILIKE %s
                        OR u.email    ILIKE %s
                        OR u.username ILIKE %s)
                  AND  u.is_super_admin = FALSE
                GROUP BY u.user_id, u.username, u.first_name, u.last_name,
                         u.email, u.account_status, u.date_joined, u.last_login
                ORDER BY u.last_name, u.first_name
                LIMIT 50
                """,
                (f'%{query}%', f'%{query}%', f'%{query}%')
            )
            users = cursor.fetchall()

        logger.info('User %d searched users with query=%r — %d results', user_id, query, len(users))

    return render_template('helpdesk/user_search.html', query=query, users=users)


@app.route('/support/user-search/<int:target_user_id>')
@role_required('Super Admin', 'Support Technician')
def helpdesk_user_profile(target_user_id):
    """Read-only user profile view for support staff — no role-change actions."""
    viewer_id = session['user_id']

    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT user_id, username, first_name, last_name, email, phone,
                   account_status, date_joined, last_login, notes
            FROM   users
            WHERE  user_id = %s AND is_super_admin = FALSE
            """,
            (target_user_id,)
        )
        user = cursor.fetchone()

    if not user:
        abort(404)

    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT gm.role, g.name AS group_name, g.is_active AS group_active,
                   gm.joined_at
            FROM   group_memberships gm
            JOIN   groups g ON g.group_id = gm.group_id
            WHERE  gm.user_id = %s
            ORDER BY g.name
            """,
            (target_user_id,)
        )
        memberships = cursor.fetchall()

    # Recent catch records
    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT tc.catch_id, tc.date, tc.species_caught,
                   t.code AS trap_code, l.name AS line_name
            FROM   trap_catches tc
            JOIN   traps t ON t.trap_id = tc.trap_id
            JOIN   lines l ON l.line_id = t.line_id
            WHERE  tc.recorded_by_id = %s
            ORDER BY tc.date DESC
            LIMIT  10
            """,
            (target_user_id,)
        )
        recent_catches = cursor.fetchall()

    # Recent bait station records
    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT bsr.record_id, bsr.date, bsr.target_species,
                   bs.code AS station_code, l.name AS line_name
            FROM   bait_station_records bsr
            JOIN   bait_stations bs ON bs.station_id = bsr.station_id
            JOIN   lines l          ON l.line_id      = bs.line_id
            WHERE  bsr.recorded_by_id = %s
            ORDER BY bsr.date DESC
            LIMIT  10
            """,
            (target_user_id,)
        )
        recent_bait = cursor.fetchall()

    # Recent observations
    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT o.observation_id, o.date, o.observation_type,
                   l.name AS line_name
            FROM   incidental_observations o
            LEFT JOIN lines l ON l.line_id = o.line_id
            WHERE  o.operator_id = %s
            ORDER BY o.date DESC
            LIMIT  10
            """,
            (target_user_id,)
        )
        recent_observations = cursor.fetchall()

    # Suspension audit log
    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT usl.action, usl.reason, usl.created_at,
                   actor.first_name || ' ' || actor.last_name AS actor_name
            FROM   user_suspension_log usl
            LEFT JOIN users actor ON actor.user_id = usl.actor_user_id
            WHERE  usl.target_user_id = %s
            ORDER BY usl.created_at DESC
            """,
            (target_user_id,)
        )
        suspension_log = cursor.fetchall()

    logger.info('User %d viewed profile of user %d', viewer_id, target_user_id)

    return render_template(
        'helpdesk/user_profile.html',
        user=user,
        memberships=memberships,
        recent_catches=recent_catches,
        recent_bait=recent_bait,
        recent_observations=recent_observations,
        suspension_log=suspension_log,
    )


# ── Suspend a user account ───────────────────────────────────────────────────

@app.route('/support/user-search/<int:target_user_id>/suspend', methods=['POST'])
@role_required('Super Admin', 'Support Technician')
def helpdesk_user_suspend(target_user_id):
    """Suspend a user account with a required reason."""
    actor_id = session['user_id']

    if actor_id == target_user_id:
        flash('You cannot suspend your own account.', 'danger')
        return redirect(url_for('helpdesk_user_profile', target_user_id=target_user_id))

    reason = request.form.get('reason', '').strip()
    if not reason:
        flash('A reason is required to suspend an account.', 'danger')
        return redirect(url_for('helpdesk_user_profile', target_user_id=target_user_id))

    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT user_id, account_status, is_super_admin, first_name, last_name '
            'FROM users WHERE user_id = %s',
            (target_user_id,)
        )
        target = cursor.fetchone()

    if not target or target['is_super_admin']:
        abort(404)

    if target['account_status'] == 'suspended':
        flash('This account is already suspended.', 'warning')
        return redirect(url_for('helpdesk_user_profile', target_user_id=target_user_id))

    if target['account_status'] != 'active':
        flash('Only active accounts can be suspended.', 'warning')
        return redirect(url_for('helpdesk_user_profile', target_user_id=target_user_id))

    with db.get_cursor() as cursor:
        cursor.execute(
            'UPDATE users SET account_status = %s WHERE user_id = %s',
            ('suspended', target_user_id)
        )
        cursor.execute(
            'INSERT INTO user_suspension_log (target_user_id, actor_user_id, action, reason) '
            'VALUES (%s, %s, %s, %s)',
            (target_user_id, actor_id, 'suspended', reason)
        )

    logger.info(
        'User %d suspended account %d — reason: %s',
        actor_id, target_user_id, reason
    )
    flash(
        f'{target["first_name"]} {target["last_name"]}\'s account has been suspended.',
        'success'
    )
    return redirect(url_for('helpdesk_user_profile', target_user_id=target_user_id))


# ── Reinstate a suspended user account ──────────────────────────────────────

@app.route('/support/user-search/<int:target_user_id>/reinstate', methods=['POST'])
@role_required('Super Admin', 'Support Technician')
def helpdesk_user_reinstate(target_user_id):
    """Reinstate a suspended user account with a required reason."""
    actor_id = session['user_id']

    reason = request.form.get('reason', '').strip()
    if not reason:
        flash('A reason is required to reinstate an account.', 'danger')
        return redirect(url_for('helpdesk_user_profile', target_user_id=target_user_id))

    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT user_id, account_status, is_super_admin, first_name, last_name '
            'FROM users WHERE user_id = %s',
            (target_user_id,)
        )
        target = cursor.fetchone()

    if not target or target['is_super_admin']:
        abort(404)

    if target['account_status'] != 'suspended':
        flash('This account is not suspended.', 'warning')
        return redirect(url_for('helpdesk_user_profile', target_user_id=target_user_id))

    with db.get_cursor() as cursor:
        cursor.execute(
            'UPDATE users SET account_status = %s WHERE user_id = %s',
            ('active', target_user_id)
        )
        cursor.execute(
            'INSERT INTO user_suspension_log (target_user_id, actor_user_id, action, reason) '
            'VALUES (%s, %s, %s, %s)',
            (target_user_id, actor_id, 'reinstated', reason)
        )

    logger.info(
        'User %d reinstated account %d — reason: %s',
        actor_id, target_user_id, reason
    )
    flash(
        f'{target["first_name"]} {target["last_name"]}\'s account has been reinstated.',
        'success'
    )
    return redirect(url_for('helpdesk_user_profile', target_user_id=target_user_id))
