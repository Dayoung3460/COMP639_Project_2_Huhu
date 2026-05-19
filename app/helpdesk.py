"""helpdesk.py — Support ticket submission and tracking (P2-49, P2-50)."""

import logging
import os

from flask import flash, redirect, render_template, request, session, url_for, abort
from app import app, db
from app.utils import role_required, sniff_image_kind

logger = logging.getLogger(__name__)

SCREENSHOT_EXTENSIONS = {'jpg', 'jpeg', 'png', 'webp'}
SCREENSHOT_MAX_BYTES   = 5 * 1024 * 1024  # 5 MB

TICKET_TYPES      = ('Help', 'Bug Report')
TICKET_PRIORITIES = ('Low', 'Medium', 'High')
TICKET_STATUSES   = ('New', 'Open', 'Stalled', 'Resolved')


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
    """List all support tickets submitted by the current user.

    Supports ?status= filter and ?sort= (date_asc / date_desc).
    """
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
    assigned_filter = request.args.get('assigned', '').strip()   # 'me', 'unassigned', or ''
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
    if assigned_filter == 'me':
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
                           sort=sort)
