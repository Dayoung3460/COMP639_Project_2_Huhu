"""groups.py — Group landing pages.

Route:
    GET /groups/<int:group_id>

Visibility logic (per the brief):
    - Public groups are discoverable by anyone (logged in or out).
    - Private groups are visible in the browse list but content is gated:
      non-members see only a minimal page with a request-to-join CTA.
    - Members of a group are sent straight to the in-app dashboard.
"""

from flask import render_template, request, redirect, url_for, flash, session, abort, jsonify
from app import app, db
from app.utils import role_required, save_uploaded_image, redirect_by_role
from app.helpers.dbHelper import fetch_membership_role, insert_notification


@app.route('/groups/<int:group_id>')
def group_landing(group_id):
    """Public landing page for a single group."""
    user_id = session.get('user_id')

    with db.get_cursor() as cursor:
        # ── Group basics ─────────────────────────────────────────
        cursor.execute('''
            SELECT
                g.group_id, g.name, g.description, g.is_public,
                g.cover_photo, g.color_theme, g.created_at, g.is_active
            FROM groups g
            WHERE g.group_id = %s
        ''', (group_id,))
        group = cursor.fetchone()

        if not group or not group['is_active']:
            abort(404)

        # ── Super admin check ─────────────────────────────────────
        is_super_admin = False
        if user_id:
            cursor.execute('SELECT is_super_admin FROM users WHERE user_id = %s', (user_id,))
            u = cursor.fetchone()
            is_super_admin = bool(u and u['is_super_admin'])

        # ── Membership check — fetch role for "Go to Group" button ─
        is_member = False
        member_role = None
        if user_id:
            membership = fetch_membership_role(db, user_id, group_id)
            if membership:
                is_member = True
                member_role = membership['role']

        # ── Stats — only computed for public groups, never leaked ─
        stats = None
        coordinators = []

        if group['is_public']:
            cursor.execute('''
                SELECT COUNT(*) AS count
                FROM group_memberships
                WHERE group_id = %s
            ''', (group_id,))
            member_count = cursor.fetchone()['count']

            cursor.execute('''
                SELECT COUNT(*) AS count
                FROM lines
                WHERE group_id = %s AND is_retired = FALSE
            ''', (group_id,))
            line_count = cursor.fetchone()['count']

            cursor.execute('''
                SELECT COUNT(*) AS count
                FROM trap_catches tc
                JOIN traps t ON tc.trap_id = t.trap_id
                JOIN lines l ON t.line_id = l.line_id
                WHERE l.group_id = %s AND tc.species_caught != 'None'
            ''', (group_id,))
            catch_count = cursor.fetchone()['count']

            stats = {
                'members': member_count,
                'lines':   line_count,
                'catches': catch_count,
            }

            cursor.execute('''
                SELECT u.first_name, u.last_name
                FROM group_memberships gm
                JOIN users u ON gm.user_id = u.user_id
                WHERE gm.group_id = %s AND gm.role = 'Group Coordinator'
                ORDER BY u.first_name
            ''', (group_id,))
            coordinators = cursor.fetchall()

        # ── Pending request — for all logged-in non-members (not super admin) ──
        has_pending_request = False
        if user_id and not is_member and not is_super_admin:
            cursor.execute('''
                SELECT 1 FROM group_join_requests
                WHERE user_id = %s AND group_id = %s AND status = 'pending'
            ''', (user_id, group_id))
            has_pending_request = cursor.fetchone() is not None

    # Foundation-fix: /groups/<id> is a marketing-surface page that's
    # *about* this group, so it previews that group's brand. The override
    # is consumed by base_marketing.html's <style> block; routes that
    # don't pass an override (e.g. /, /select-group) fall through to
    # platform_theme so Tiaki stays Tiaki.
    return render_template(
        'group_landing.html',
        group=group,
        stats=stats,
        coordinators=coordinators,
        has_pending_request=has_pending_request,
        is_member=is_member,
        member_role=member_role,
        is_super_admin=is_super_admin,
    )

@app.route('/groups/apply', methods=['GET', 'POST'])
def apply_for_group():
    if 'user_id' not in session:
        return redirect(url_for('login'))
    
    if request.method == 'POST':
        user_id = session.get('user_id')
        proposed_name = request.form.get('proposed_name', '').strip()
        description = request.form.get('description', '').strip()
        location = request.form.get('location', '').strip()
        justification = request.form.get('justification', '').strip()

        # ── Check user has pending applications ─────────────────────────────
        with db.get_cursor() as cursor:
            cursor.execute(
                """
                SELECT COUNT(*) FROM group_applications WHERE user_id = %s AND status = 'pending'
                """,
                (user_id,)
            )
            pending_count = cursor.fetchone()

            print(f"User {user_id} has {pending_count['count']} pending applications.")  # Debug log

            if pending_count['count'] > 0:
                flash('You already have a pending conservation application. Please wait for it to be reviewed before submitting another.', 'warning')
                return redirect(url_for('apply_for_group'))

        # ── Server-side validation ─────────────────────────────
        if not all([proposed_name, description, location, justification]):
            flash('Please fill in all required fields.', 'danger')
            return redirect(url_for('apply_for_group'))
        
        # ── Check proposed_name not already taken ──────────────
        with db.get_cursor() as cursor:
            cursor.execute(
                """
                SELECT proposed_name FROM group_applications
                WHERE proposed_name = %s
                """,
                (proposed_name,)
            )
            existing_application = cursor.fetchone()

        if existing_application:
            flash(f'A conservation application with this name "{proposed_name}" already exists.', 'danger')
            return redirect(url_for('apply_for_group'))
        
        # ── Handle profile photo upload ────────────────────────
        profile_photo, img_err = save_uploaded_image(request.files.get('group_image_input'), 'group')
        if img_err:
            flash(img_err, 'danger')
            return redirect(url_for('apply_for_group'))

        with db.get_cursor() as cursor:
            if profile_photo:
                insert_query = """
                INSERT INTO group_applications (user_id, proposed_name, description, location, justification, image)
                VALUES (%s, %s, %s, %s, %s, %s)
                """
                tuple_values = (user_id, proposed_name, description, location, justification, profile_photo)
            else:
                insert_query = """
                INSERT INTO group_applications (user_id, proposed_name, description, location, justification)
                VALUES (%s, %s, %s, %s, %s)
                """
                tuple_values = (user_id, proposed_name, description, location, justification)

            cursor.execute(
                insert_query,
                tuple_values
            )

            # Notify all Super Admins so they don't have to poll the page
            cursor.execute('SELECT user_id FROM users WHERE is_super_admin = TRUE')
            admin_ids = [r['user_id'] for r in cursor.fetchall()]

        for admin_id in admin_ids:
            insert_notification(
                db, admin_id,
                f'New group application: "{proposed_name}" — review it in Group Applications.',
                'info',
                url=url_for('admin_group_applications')
            )

        flash('Your conservation application has been submitted successfully!', 'success')
        return redirect(url_for('apply_for_group'))

    return render_template('groups/apply_group.html')

@app.route('/group/join', methods=['POST'])
def request_join_group():
    user_id = session.get('user_id')

    # 1. Not logged in → 401
    if not user_id:
        abort(401)

    group_id = request.form.get('group_id', type=int)

    with db.get_cursor() as cursor:
        # 2. Super Admin → 403
        cursor.execute('SELECT is_super_admin FROM users WHERE user_id = %s', (user_id,))
        u = cursor.fetchone()
        if u and u['is_super_admin']:
            abort(403)

        # 3. Group exists and is active → 404
        cursor.execute(
            'SELECT group_id, name, is_public, is_active FROM groups WHERE group_id = %s',
            (group_id,)
        )
        group = cursor.fetchone()
        if not group or not group['is_active']:
            abort(404)

        # 4. Already a member → 400
        if fetch_membership_role(db, user_id, group_id):
            return jsonify({'error': 'You are already a member of this group'}), 400

        # 5. Duplicate pending request → 400
        cursor.execute(
            "SELECT 1 FROM group_join_requests WHERE user_id = %s AND group_id = %s AND status = 'pending'",
            (user_id, group_id)
        )
        if cursor.fetchone():
            return jsonify({'error': 'You already have a pending request for this group'}), 400

        # 6. Public → join immediately as Observer; Private → create pending request
        coord_ids = []
        if group['is_public']:
            cursor.execute(
                "INSERT INTO group_memberships (user_id, group_id, role) VALUES (%s, %s, 'Observer')",
                (user_id, group_id)
            )
            flash('Joined successfully!', 'success')
        else:
            message = request.form.get('message', '').strip() or None
            cursor.execute(
                "INSERT INTO group_join_requests (user_id, group_id, status, message) VALUES (%s, %s, 'pending', %s)",
                (user_id, group_id, message)
            )
            flash('Request submitted successfully!', 'success')

            # Notify all Group Coordinators of this group
            cursor.execute('''
                SELECT user_id FROM group_memberships
                WHERE group_id = %s AND role = 'Group Coordinator'
            ''', (group_id,))
            coord_ids = [r['user_id'] for r in cursor.fetchall()]

        for coord_id in coord_ids:
            insert_notification(
                db, coord_id,
                f'New join request for {group["name"]} — review it in Join Requests.',
                'info',
                url=url_for('coordinator_requests'),
                group_id=group_id,
            )

    return redirect(url_for('group_landing', group_id=group_id))


@app.route('/notifications/<int:notification_id>/dismiss')
def notification_click(notification_id):
    """Mark a notification inactive and redirect to its stored url."""
    user_id = session.get('user_id')
    if not user_id:
        abort(401)

    with db.get_cursor() as cursor:
        cursor.execute(
            'UPDATE user_notifications SET is_active = FALSE '
            'WHERE notification_id = %s AND user_id = %s RETURNING url',
            (notification_id, user_id)
        )
        row = cursor.fetchone()

    dest = row['url'] if row and row['url'] else request.referrer or url_for('index')
    return redirect(dest)


@app.route('/notifications/mark-all-read', methods=['POST'])
def notifications_mark_all_read():
    """Mark every active notification for the current user (in the
    current group scope, matching the dropdown query in inject_globals)
    as read. Called from the navbar bell when the dropdown opens."""
    user_id = session.get('user_id')
    if not user_id:
        return jsonify({'ok': False}), 401

    with db.get_cursor() as cursor:
        cursor.execute(
            'UPDATE user_notifications SET is_active = FALSE '
            'WHERE user_id = %s AND is_active = TRUE '
            '  AND (group_id IS NULL OR group_id = %s)',
            (user_id, session.get('group_id', 0))
        )
    return jsonify({'ok': True})


@app.route('/groups/<int:group_id>/enter')
def enter_group(group_id):
    """Sets the session context for a group the user is already a member of."""
    user_id = session.get('user_id')
    if not user_id:
        return redirect(url_for('login'))

    with db.get_cursor() as cursor:
        cursor.execute('''
            SELECT gm.role, g.name, g.is_active
            FROM group_memberships gm
            JOIN groups g ON gm.group_id = g.group_id
            WHERE gm.user_id = %s AND gm.group_id = %s
        ''', (user_id, group_id))
        membership = cursor.fetchone()

    if not membership or not membership['is_active']:
        abort(404)

    session['group_id']   = group_id
    session['group_role'] = membership['role']
    session['group_name'] = membership['name']

    return redirect_by_role()