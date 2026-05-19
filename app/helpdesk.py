"""helpdesk.py — Support ticket submission for all logged-in users (P2-49)."""

import logging
import os

from flask import flash, redirect, render_template, request, session, url_for, abort
from app import app, db
from app.utils import role_required, sniff_image_kind

logger = logging.getLogger(__name__)

SCREENSHOT_EXTENSIONS = {'jpg', 'jpeg', 'png', 'webp'}
SCREENSHOT_MAX_BYTES   = 5 * 1024 * 1024  # 5 MB

TICKET_TYPES     = ('Help', 'Bug Report')
TICKET_PRIORITIES = ('Low', 'Medium', 'High')


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
    # Normalise jpeg/jpg
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

    # ── Collect + validate ───────────────────────────────────────
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

    # ── Insert ticket (no screenshot yet) ────────────────────────
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

    # ── Optional screenshot upload ───────────────────────────────
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

    flash(
        f'Request #{ticket_id} submitted. We\'ll get back to you as soon as possible.',
        'success'
    )
    return redirect(url_for('helpdesk_view', ticket_id=ticket_id))


# ── My requests list ──────────────────────────────────────────────────────────

@app.route('/support/my-requests')
@role_required()
def helpdesk_my_requests():
    """List all support tickets submitted by the current user."""
    user_id = session['user_id']
    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT ticket_id, request_type, title, priority, status, created_at
            FROM support_tickets
            WHERE submitted_by = %s
            ORDER BY created_at DESC
            """,
            (user_id,)
        )
        tickets = cursor.fetchall()
    return render_template('helpdesk/my_requests.html', tickets=tickets)


# ── View single ticket ────────────────────────────────────────────────────────

@app.route('/support/my-requests/<int:ticket_id>')
@role_required()
def helpdesk_view(ticket_id):
    """Read-only detail view for a ticket — only the submitter can see it."""
    user_id = session['user_id']
    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT st.*,
                   g.name AS group_name
            FROM   support_tickets st
            LEFT JOIN groups g ON g.group_id = st.group_id
            WHERE  st.ticket_id = %s
            """,
            (ticket_id,)
        )
        ticket = cursor.fetchone()

    if not ticket:
        abort(404)

    # Only the submitter (or Super Admin) may view
    if ticket['submitted_by'] != user_id and session.get('group_role') != 'Super Admin':
        abort(403)

    return render_template('helpdesk/view_request.html', ticket=ticket)
