"""admin.py — Admin dashboard, user management, lines, traps, operator assignment, lookups."""

import logging

from flask import render_template, request, redirect, url_for, flash, session
from app import app, db
from app.utils import (
    role_required,
    validate_lincoln_nz_coordinates,
    LINCOLN_NZ_LAT_RANGE,
    LINCOLN_NZ_LON_RANGE,
    LINE_COLOURS,
    allowed_file,
    save_uploaded_image,
    delete_upload,
    is_super_admin_mode,
)
from app.helpers.dbHelper import update_user_active, fetch_lookup_data, fetch_user_info, fetch_membership_role, update_user_role, insert_notification, fetch_active_lookup
from app.helpers.linesHelper import (
    fetch_line_for_group, fetch_trap_for_group, fetch_bait_station_for_group,
    retire_asset, unretire_asset,
)

logger = logging.getLogger(__name__)


# ── Dashboard ─────────────────────────────────────────────────────────────────

@app.route('/admin/dashboard')
@role_required('Super Admin', 'Support Technician')
def admin_dashboard():
    """Admin dashboard — system-wide statistics and quick actions."""
    stats = {
        'total_users':    0,
        'total_observers': 0,
        'total_operators': 0,
        'total_admins':   0,
        'inactive_users': 0,
        'total_lines':    0,
        'retired_lines':  0,
        'total_traps':    0,
        'retired_traps':  0,
        'total_catches':  0,
        'catches_month':  0,
        'maintenance_traps': 0,
    }
    recent_users = []
    recent_catches = []
 
    try:
        with db.get_cursor() as cursor:
 
            # ── Users ─────────────────────────────────────────
            cursor.execute("""
                SELECT
                    COUNT(DISTINCT u.user_id)                                                    AS total,
                    COUNT(*) FILTER (WHERE gm.role = 'Observer')                                 AS observers,
                    COUNT(*) FILTER (WHERE gm.role = 'Operator')                                 AS operators,
                    COUNT(DISTINCT u.user_id) FILTER (WHERE u.is_super_admin = TRUE)             AS admins,
                    COUNT(DISTINCT u.user_id) FILTER (WHERE u.account_status = 'inactive')       AS inactive
                FROM users u
                LEFT JOIN group_memberships gm ON gm.user_id = u.user_id
            """)
            row = cursor.fetchone()
            stats['total_users']     = row['total']
            stats['total_observers'] = row['observers']
            stats['total_operators'] = row['operators']
            stats['total_admins']    = row['admins']
            stats['inactive_users']  = row['inactive']
 
            # ── Lines & Traps ──────────────────────────────────
            cursor.execute("""
                SELECT
                    COUNT(*)                                    AS total,
                    COUNT(*) FILTER (WHERE is_retired = TRUE)  AS retired
                FROM lines
            """)
            row = cursor.fetchone()
            stats['total_lines']   = row['total']
            stats['retired_lines'] = row['retired']
 
            cursor.execute("""
                SELECT
                    COUNT(*)                                    AS total,
                    COUNT(*) FILTER (WHERE is_retired = TRUE)  AS retired
                FROM traps
            """)
            row = cursor.fetchone()
            stats['total_traps']   = row['total']
            stats['retired_traps'] = row['retired']
 
            # ── Catches ────────────────────────────────────────
            cursor.execute("""
                SELECT COUNT(*) AS cnt FROM trap_catches
                WHERE species_caught != 'None'
            """)
            stats['total_catches'] = cursor.fetchone()['cnt']
 
            cursor.execute("""
                SELECT COUNT(*) AS cnt FROM trap_catches
                WHERE species_caught != 'None'
                AND date >= NOW() - INTERVAL '30 days'
            """)
            stats['catches_month'] = cursor.fetchone()['cnt']
 
            # ── Traps needing maintenance ──────────────────────
            cursor.execute("""
                SELECT COUNT(DISTINCT trap_id) AS cnt FROM trap_catches
                WHERE trap_condition = 'Needs maintenance'
                AND date >= NOW() - INTERVAL '30 days'
            """)
            stats['maintenance_traps'] = cursor.fetchone()['cnt']
 
            # ── Recent registrations (last 5) ──────────────────
            cursor.execute("""
                SELECT u.username, u.first_name, u.last_name,
                       gm.role, u.account_status, u.date_joined
                FROM users u
                LEFT JOIN group_memberships gm ON gm.user_id = u.user_id
                ORDER BY u.date_joined DESC
                LIMIT 5
            """)
            recent_users = cursor.fetchall()
 
            # ── Recent catches (last 5) ────────────────────────
            cursor.execute("""
                SELECT tc.date, tc.species_caught, tc.status,
                       t.code AS trap_code, l.name AS line_name,
                       u.username AS recorded_by
                FROM trap_catches tc
                JOIN traps t ON tc.trap_id = t.trap_id
                JOIN lines l ON t.line_id = l.line_id
                LEFT JOIN users u ON tc.recorded_by_id = u.user_id
                WHERE tc.species_caught != 'None'
                ORDER BY tc.date DESC
                LIMIT 5
            """)
            recent_catches = cursor.fetchall()
 
    except Exception as e:
        logger.error('Admin dashboard error: %s', e)
 
    return render_template('admin/dashboard.html',
                           stats=stats,
                           recent_users=recent_users,
                           recent_catches=recent_catches)


# ── User management ───────────────────────────────────────────────────────────

@app.route('/admin/users')
@role_required('Super Admin', 'Support Technician')
def admin_users():
    """Platform-wide user list for Super Admin.

    One row per user. Surfaces platform-level facts only — the
    Super Admin flag and a count of group memberships — instead of
    per-group role (which lives on the user detail page since each
    user can have a different role in each group).
    """
    search = request.args.get('search', '').strip()
    status_filter = request.args.get('status', '').strip()

    query = '''
        SELECT u.user_id, u.username, u.first_name, u.last_name,
               u.is_super_admin, u.account_status, u.date_joined, u.last_login,
               COUNT(gm.group_id) AS memberships
        FROM users u
        LEFT JOIN group_memberships gm ON gm.user_id = u.user_id
        WHERE 1=1
    '''
    params = []

    if search:
        # Strip '@' in case the user copy-pasted the username from the table
        clean_search = search.lstrip('@')
        query += " AND (u.username ILIKE %s OR u.first_name ILIKE %s OR u.last_name ILIKE %s OR CONCAT(u.first_name, ' ', u.last_name) ILIKE %s)"
        search_term = f"%{clean_search}%"
        params.extend([search_term, search_term, search_term, search_term])

    if status_filter:
        query += " AND u.account_status = %s"
        params.append(status_filter)

    query += '''
        GROUP BY u.user_id
        ORDER BY u.first_name ASC, u.last_name ASC
    '''

    with db.get_cursor() as cursor:
        cursor.execute(query, tuple(params))
        users = cursor.fetchall()

    return render_template('admin/users.html', users=users,
                           search=search,
                           status_filter=status_filter)


@app.route('/admin/users/<int:user_id>')
@role_required('Super Admin', 'Support Technician')
def admin_user_detail(user_id):
    """View detailed profile for a single user.

    Memberships are loaded as a list (one row per group) rather than
    flattened into a single role field — a user can be an Observer
    in one group and an Operator in another, and the detail page is
    where Super Admin needs to see that breakdown.
    """
    with db.get_cursor() as cursor:
        cursor.execute('''
            SELECT u.user_id, u.username, u.first_name, u.last_name, u.email, u.phone, u.address,
                   u.emergency_contact_name, u.emergency_contact_phone, u.profile_photo,
                   u.notes, u.is_super_admin, u.account_status, u.date_joined, u.last_login
            FROM users u
            WHERE u.user_id = %s
        ''', (user_id,))
        user = cursor.fetchone()

    if not user:
        flash('User not found', 'danger')
        return redirect(url_for('admin_users'))

    # Handle optional data defaults (display "None provided" for missing text fields)
    optional_text_fields = ['phone', 'address', 'emergency_contact_name', 'emergency_contact_phone', 'notes']
    for field in optional_text_fields:
        if not user.get(field) or not str(user.get(field)).strip():
            user[field] = 'None provided'

    # Per-group memberships — drives the Memberships card on the detail page.
    with db.get_cursor() as cursor:
        cursor.execute('''
            SELECT gm.group_id, gm.role, g.name AS group_name, g.is_active
            FROM group_memberships gm
            JOIN groups g ON g.group_id = gm.group_id
            WHERE gm.user_id = %s
            ORDER BY g.name ASC
        ''', (user_id,))
        memberships = cursor.fetchall()

    membership_roles = {m['role'] for m in memberships}

    assigned_lines = []
    if 'Operator' in membership_roles:
        with db.get_cursor() as cursor:
            cursor.execute('''
                SELECT l.line_id, l.name
                FROM operator_lines ol
                JOIN lines l ON ol.line_id = l.line_id
                WHERE ol.operator_id = %s
                ORDER BY l.name ASC
            ''', (user_id,))
            assigned_lines = cursor.fetchall()

    catches = []
    with db.get_cursor() as cursor:
        cursor.execute('''
            SELECT tc.catch_id, tc.date, tc.species_caught, t.code AS trap_code, l.name AS line_name, l.line_id
            FROM trap_catches tc
            JOIN traps t ON tc.trap_id = t.trap_id
            JOIN lines l ON t.line_id = l.line_id
            WHERE tc.recorded_by_id = %s
            ORDER BY tc.date DESC
        ''', (user_id,))
        catches = cursor.fetchall()

    observations = []
    with db.get_cursor() as cursor:
        cursor.execute('''
            SELECT o.observation_id, o.date, o.observation_type, 
                   l.name AS line_name, t.code AS trap_code, l.line_id
            FROM incidental_observations o
            LEFT JOIN lines l ON o.line_id = l.line_id
            LEFT JOIN traps t ON o.trap_id = t.trap_id
            WHERE o.operator_id = %s
            ORDER BY o.date DESC
        ''', (user_id,))
        observations = cursor.fetchall()

    return render_template('admin/user_detail.html',
                           user=user,
                           memberships=memberships,
                           membership_roles=membership_roles,
                           assigned_lines=assigned_lines,
                           catches=catches,
                           observations=observations,
                           line_colours=LINE_COLOURS)


@app.route('/admin/users/<int:user_id>/toggle-active', methods=['POST'])
@role_required('Super Admin', 'Support Technician')
def toggle_active(user_id):
    """Activate or deactivate a user account."""
    # Prevent admin from deactivating themselves
    if user_id == session.get('user_id'):
        flash('You cannot deactivate your own account.', 'danger')
        return redirect(url_for('admin_users'))
    
    with db.get_cursor() as cursor:
        cursor.execute("SELECT account_status FROM users WHERE user_id = %s", (user_id,))
        user = cursor.fetchone()
        if not user:
            flash('User not found.', 'danger')
            return redirect(url_for('admin_users'))

        if user['account_status'] == 'suspended':
            flash('This account is suspended by Support. Use the User Search to reinstate it.', 'warning')
            return redirect(url_for('admin_users'))

        # Toggle between 'active' and 'inactive'
        new_status = 'inactive' if user['account_status'] == 'active' else 'active'

        # Guard: prevent deactivating an account that is the sole active coordinator of any group
        if new_status == 'inactive':
            cursor.execute("""
                SELECT gm.group_id, g.name AS group_name
                FROM group_memberships gm
                JOIN groups g ON gm.group_id = g.group_id
                WHERE gm.user_id = %s AND gm.role = 'Group Coordinator'
                  AND (
                      SELECT COUNT(*) FROM group_memberships gm2
                      JOIN users u2 ON gm2.user_id = u2.user_id
                      WHERE gm2.group_id = gm.group_id
                        AND gm2.role = 'Group Coordinator'
                        AND u2.account_status = 'active'
                  ) = 1
            """, (user_id,))
            blocking_groups = cursor.fetchall()
            if blocking_groups:
                names = ', '.join(r['group_name'] for r in blocking_groups)
                flash(
                    f'Cannot deactivate this user — they are the only active coordinator of: {names}. '
                    'Assign another coordinator first.',
                    'danger'
                )
                return redirect(url_for('admin_users'))

        update_user_active(db, user_id, new_status)

    flash(f'User account {"activated" if new_status == "active" else "deactivated"}.', 'success')
    return redirect(url_for('admin_users'))


@app.route('/admin/users/<int:user_id>/edit-role', methods=['GET', 'POST'])
@role_required('Super Admin')  # role changes — Super Admin only per spec
def edit_role(user_id):
    """Edit a user's role."""
    # Prevent admin from changing their own role
    if user_id == session.get('user_id'):
        flash('You cannot change your own role.', 'danger')
        return redirect(url_for('admin_users'))
    
    user = fetch_user_info(db, user_id)
    if not user:
        flash('User not found.', 'danger')
        return redirect(url_for('admin_users'))

    # Attach current role from group_memberships so the template can pre-select it
    gm_row = fetch_membership_role(db, user_id, session.get('group_id'))
    user = dict(user)
    user['role'] = gm_row['role'] if gm_row else None

    lookup = fetch_lookup_data(db)
    
    if request.method == 'POST':
        new_role = request.form.get('role')
        if new_role not in lookup['valid_roles']:
            flash('Invalid role selected.', 'danger')
            return render_template('admin/edit_role.html', user=user, roles=lookup['valid_roles'])
        
        update_user_role(db, user_id, session.get('group_id'), new_role)
        flash(f'Role updated to "{new_role}" for {user["first_name"]} {user["last_name"]}.', 'success')
        return redirect(url_for('admin_users'))
    
    return render_template('admin/edit_role.html', user=user, roles=lookup['valid_roles'])

@app.route('/admin/users/<int:user_id>/notes', methods=['POST'])
@role_required('Super Admin', 'Support Technician')
def update_user_notes(user_id):
    """Update the admin-only notes for a user."""
    notes = request.form.get('notes', '').strip()
    
    if len(notes) > 2000:
        flash('Admin notes cannot exceed 2000 characters', 'danger')
        return redirect(url_for('admin_user_detail', user_id=user_id))
        
    with db.get_cursor() as cursor:
        cursor.execute('''
            UPDATE users
            SET notes = %s
            WHERE user_id = %s
        ''', (notes if notes else None, user_id))
    flash('Admin notes updated', 'success')
    return redirect(url_for('admin_user_detail', user_id=user_id))


# ── Lines ─────────────────────────────────────────────────────────────────────

@app.route('/admin/lines/new', methods=['GET', 'POST'])
@role_required('Super Admin', 'Group Coordinator', 'Support Technician')
def new_line():
    """Create a new line (Trap or Bait Station).

    Coordinators create within their selected group. A Super Admin in
    platform-wide mode has no group context, so they pick the target
    group via a dropdown on the form.
    """
    super_admin = is_super_admin_mode()
    groups = []
    if super_admin:
        with db.get_cursor() as cursor:
            cursor.execute('''
                SELECT group_id, name FROM groups
                WHERE is_active = TRUE
                ORDER BY name
            ''')
            groups = cursor.fetchall()

    if request.method == 'POST':
        name = request.form.get('name', '').strip()
        line_type = request.form.get('type', '').strip()
        if super_admin:
            target_group_id = request.form.get('group_id', type=int)
        else:
            target_group_id = session.get('group_id')

        def _render(error):
            flash(error, 'danger')
            return render_template('lines/new_line.html',
                                   name=name, line_type=line_type,
                                   super_admin=super_admin, groups=groups,
                                   selected_group_id=target_group_id)

        if not name:
            return _render('Please provide a name')
        if line_type not in ('Trap', 'Bait Station'):
            return _render('Please select a line type')
        if super_admin and not target_group_id:
            return _render('Please select the group this line belongs to')
        if super_admin and not any(g['group_id'] == target_group_id for g in groups):
            return _render('Selected group is not valid')

        with db.get_cursor() as cursor:
            cursor.execute('SELECT line_id FROM lines WHERE name = %s', (name,))
            if cursor.fetchone():
                return _render(f'A line named "{name}" already exists')

            cursor.execute(
                'INSERT INTO lines (name, type, group_id) VALUES (%s, %s, %s)',
                (name, line_type, target_group_id)
            )

        flash(f'{line_type} line "{name}" created successfully', 'success')
        return redirect(url_for('lines_index'))

    return render_template('lines/new_line.html', name='', line_type='Trap',
                           super_admin=super_admin, groups=groups,
                           selected_group_id=None)


@app.route('/admin/lines/<int:line_id>/edit', methods=['GET', 'POST'])
@role_required('Super Admin', 'Group Coordinator', 'Support Technician')
def edit_line(line_id):
    """Edit an existing trap line."""
    line = fetch_line_for_group(db, line_id)
    if not line:
        flash('Line not found in your group.', 'danger')
        return redirect(url_for('lines_index'))

    if request.method == 'POST':

        name = request.form.get('line_name').strip()

        # Check for unique line name (excluding current line)
        with db.get_cursor() as cursor:
            cursor.execute(
                """
                SELECT line_id
                FROM lines
                WHERE name = %s AND line_id != %s
                """,
                (name, line_id)
            )
            existing_line = cursor.fetchone()
            if existing_line:
                flash(f'Line Name "{name}" has already been taken. Please choose a different name.', 'danger')
                return redirect(url_for('edit_line', line_id=line_id))

        # Update line in database
        with db.get_cursor() as cursor:
            cursor.execute(
                """
                UPDATE lines
                SET name = %s
                WHERE line_id = %s
                """,
                (name, line_id)
            )

        flash('Trap line updated.', 'success')
        return redirect(url_for('lines_index'))

    return render_template(
        'lines/edit_line.html',
        line=line,
        line_id=line_id
    )


@app.route('/admin/lines/<int:line_id>/retire', methods=['POST'])
@role_required('Super Admin', 'Group Coordinator', 'Support Technician')
def retire_line(line_id):
    """Retire a trap line (set is_retired = TRUE)."""
    has_active_traps = request.args.get('active_traps') == '1'
    delete_confirm = request.form.get('delete-confirm')

    if delete_confirm != 'delete':
        flash('You must type "delete" to confirm retiring line.', 'danger')
        return redirect(url_for('lines_index'))

    if not fetch_line_for_group(db, line_id):
        flash('Line not found in your group.', 'danger')
        return redirect(url_for('lines_index'))

    retired_by = session['user_id']

    retire_asset(db, 'lines', 'line_id', line_id, retired_by)
    if has_active_traps:
        with db.get_cursor() as cursor:
            cursor.execute(
                'UPDATE traps SET is_retired = TRUE, retired_at = CURRENT_TIMESTAMP, retired_by = %s WHERE line_id = %s AND is_retired = FALSE',
                (retired_by, line_id)
            )
            cursor.execute(
                'UPDATE bait_stations SET is_retired = TRUE, retired_at = CURRENT_TIMESTAMP, retired_by = %s WHERE line_id = %s AND is_retired = FALSE',
                (retired_by, line_id)
            )

    flash('Line retired.', 'success')
    return redirect(url_for('lines_index'))


@app.route('/admin/lines/<int:line_id>/unretire', methods=['POST'])
@role_required('Super Admin', 'Group Coordinator', 'Support Technician')
def unretire_line(line_id):
    """Unretire a line (set is_retired = FALSE)."""
    if not fetch_line_for_group(db, line_id):
        flash('Line not found in your group.', 'danger')
        return redirect(url_for('lines_index'))

    unretire_asset(db, 'lines', 'line_id', line_id)

    flash('Line unretired.', 'success')
    return redirect(url_for('lines_index'))


# ── Traps ─────────────────────────────────────────────────────────────────────

@app.route('/admin/lines/<int:line_id>/new_trap', methods=['POST'])
@role_required('Super Admin', 'Group Coordinator', 'Support Technician')
def new_trap(line_id):
    """Add a new trap to a line."""
    line = fetch_line_for_group(db, line_id)
    if not line:
        flash('Line not found in your group.', 'danger')
        return redirect(url_for('lines_index'))
    if line['is_retired']:
        flash('Cannot add traps to a retired line', 'danger')
        return redirect(url_for('line_detail', line_id=line_id))

    code = request.form.get('code', '').strip()
    trap_type = request.form.get('trap_type', '').strip()
    latitude = request.form.get('latitude', '').strip()
    longitude = request.form.get('longitude', '').strip()

    if not all([code, trap_type, latitude, longitude]):
        return redirect(url_for('line_detail', line_id=line_id, code=code, trap_type=trap_type, latitude=latitude, longitude=longitude, add_trap=1, error='All fields are required'))

    allowed_trap_types = fetch_active_lookup(db, 'trap_types')
    if trap_type not in allowed_trap_types:
        return redirect(
            url_for(
                'line_detail',
                line_id=line_id,
                code=code,
                trap_type=trap_type,
                latitude=latitude,
                longitude=longitude,
                add_trap=1,
                error='Invalid trap type selected'
            )
        )

    coordinates_error = validate_lincoln_nz_coordinates(latitude, longitude)
    if coordinates_error:
        return redirect(
            url_for(
                'line_detail',
                line_id=line_id,
                code=code,
                trap_type=trap_type,
                add_trap=1,
                error=coordinates_error
            )
        )

    with db.get_cursor() as cursor:
        cursor.execute("SELECT code FROM traps WHERE code = %s", (code,))
        if cursor.fetchone():
            return redirect(url_for('line_detail', line_id=line_id, trap_type=trap_type, latitude=latitude, longitude=longitude, add_trap=1, error=f'Trap code "{code}" already exists. Please choose a different code.'))

        cursor.execute(
            """
            INSERT INTO traps (code, trap_type, line_id, latitude, longitude)
            VALUES (%s, %s, %s, %s, %s)
            """,
            (code, trap_type, line_id, latitude, longitude)
        )

    flash('Trap added', 'success')
    return redirect(url_for('line_detail', line_id=line_id))

@app.route('/admin/traps/<int:line_id>/<int:trap_id>/edit', methods=['GET', 'POST'])
@role_required('Super Admin', 'Group Coordinator', 'Support Technician')
def edit_trap(line_id, trap_id):
    """Edit an existing trap."""
    trap_types = fetch_active_lookup(db, 'trap_types')
    trap = fetch_trap_for_group(db, trap_id)
    if not trap:
        flash('Trap not found.', 'danger')
        return redirect(url_for('lines_index'))

    if request.method == 'POST':
        code = request.form.get('trap_code', '').strip()
        trap_type = request.form.get('trap_type', '').strip()
        latitude = request.form.get('trap_latitude', '').strip()
        longitude = request.form.get('trap_longitude', '').strip()

        def _edit_trap_error_redirect(msg):
            return redirect(url_for('line_detail', line_id=line_id,
                edit_trap=trap_id, error=msg,
                code=code, trap_type=trap_type, latitude=latitude, longitude=longitude))

        # Basic validation
        if not code or not trap_type or not latitude or not longitude:
            return _edit_trap_error_redirect('All fields are required.')

        coordinates_error = validate_lincoln_nz_coordinates(latitude, longitude)
        if coordinates_error:
            return _edit_trap_error_redirect(coordinates_error)

        # Check for unique trap code (excluding current trap)
        with db.get_cursor() as cursor:
            cursor.execute(
                """
                SELECT trap_id
                FROM traps
                WHERE code = %s AND trap_id != %s
                """,
                (code, trap_id)
            )
            existing_trap = cursor.fetchone()
            if existing_trap:
                return _edit_trap_error_redirect(
                    f'Trap Code "{code}" has already been taken. Please choose a different code.'
                )
            
        # Update trap in database
        with db.get_cursor() as cursor:
            cursor.execute(
                """
                UPDATE traps
                SET code = %s, trap_type = %s, latitude = %s, longitude = %s
                WHERE trap_id = %s
                """,
                (code, trap_type, latitude, longitude, trap_id)
            )

        flash('Trap updated.', 'success')
        return redirect(url_for('line_detail', line_id=line_id))

    return redirect(url_for('line_detail', line_id=line_id, edit_trap=trap_id))


@app.route('/admin/traps/<int:line_id>/retire', methods=['POST'])
@role_required('Super Admin', 'Group Coordinator', 'Support Technician')
def retire_trap(line_id):
    """Retire an individual trap (set is_retired = TRUE)."""
    trap_id = request.form.get('trap_id')
    delete_confirm = request.form.get('delete-confirm')

    if delete_confirm != 'delete':
        flash('You must type "delete" to confirm retiring the trap.', 'danger')
        return redirect(url_for('line_detail', line_id=line_id))

    if not fetch_trap_for_group(db, trap_id):
        flash('Trap not found in your group.', 'danger')
        return redirect(url_for('line_detail', line_id=line_id))

    retired_by = session['user_id']

    retire_asset(db, 'traps', 'trap_id', trap_id, retired_by)

    flash('Trap retired.', 'success')
    return redirect(url_for('line_detail', line_id=line_id))


@app.route('/admin/traps/<int:line_id>/<int:trap_id>/unretire', methods=['POST'])
@role_required('Super Admin', 'Group Coordinator', 'Support Technician')
def unretire_trap(line_id, trap_id):
    """Unretire an individual trap (set is_retired = FALSE)."""
    if not fetch_trap_for_group(db, trap_id):
        flash('Trap not found.', 'danger')
        return redirect(url_for('line_detail', line_id=line_id))

    unretire_asset(db, 'traps', 'trap_id', trap_id)

    flash('Trap unretired.', 'success')
    return redirect(url_for('line_detail', line_id=line_id))


# ── Bait stations ─────────────────────────────────────────────────────────────

@app.route('/admin/lines/<int:line_id>/new-bait-station', methods=['GET', 'POST'])
@role_required('Super Admin', 'Group Coordinator', 'Support Technician')
def new_bait_station(line_id):
    """Add a new bait station to a Bait Station line."""
    line = fetch_line_for_group(db, line_id)
    if not line:
        flash('Line not found in your group.', 'danger')
        return redirect(url_for('lines_index'))
    if line['type'] != 'Bait Station':
        flash('That line is not a Bait Station line.', 'danger')
        return redirect(url_for('line_detail', line_id=line_id))
    if line['is_retired']:
        flash('Cannot add stations to a retired line.', 'danger')
        return redirect(url_for('line_detail', line_id=line_id))

    if request.method == 'POST':
        code = request.form.get('code', '').strip()
        station_type = request.form.get('station_type', '').strip()
        other_type = request.form.get('other_type', '').strip() or None
        latitude = request.form.get('latitude', '').strip()
        longitude = request.form.get('longitude', '').strip()

        errors = []
        if not code:
            errors.append('Code is required.')
        valid_station_types = fetch_active_lookup(db, 'bait_station_types')
        if station_type not in valid_station_types:
            errors.append('Please select a valid station type.')
        if station_type == 'Other' and not other_type:
            errors.append('Please specify the type when "Other" is selected.')

        coord_error = validate_lincoln_nz_coordinates(latitude, longitude)
        if coord_error:
            errors.append(coord_error)

        if not errors:
            with db.get_cursor() as cursor:
                cursor.execute('SELECT station_id FROM bait_stations WHERE code = %s AND line_id = %s', (code, line_id))
                if cursor.fetchone():
                    errors.append(f'Station code "{code}" already exists on this line. Please choose a different code.')

        if errors:
            return redirect(url_for(
                'line_detail', line_id=line_id,
                add_station=1,
                error=errors[0],
                code=code,
                station_type=station_type,
                other_type=other_type or '',
                latitude=latitude,
                longitude=longitude,
            ))

        with db.get_cursor() as cursor:
            cursor.execute(
                'INSERT INTO bait_stations (code, station_type, other_type, line_id, latitude, longitude) VALUES (%s, %s, %s, %s, %s, %s)',
                (code, station_type, other_type, line_id, latitude, longitude)
            )

        flash(f'Bait station "{code}" added.', 'success')
        return redirect(url_for('line_detail', line_id=line_id))

    bait_station_types = fetch_active_lookup(db, 'bait_station_types')
    return render_template('lines/new_bait_station.html', line=line,
                           bait_station_types=bait_station_types, data={})


@app.route('/admin/lines/<int:line_id>/bait-stations/<int:station_id>/edit', methods=['GET', 'POST'])
@role_required('Super Admin', 'Group Coordinator', 'Support Technician')
def edit_bait_station(line_id, station_id):
    """Edit an existing bait station."""
    if not fetch_line_for_group(db, line_id):
        flash('Line not found in your group.', 'danger')
        return redirect(url_for('lines_index'))

    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT * FROM bait_stations WHERE station_id = %s AND line_id = %s',
            (station_id, line_id)
        )
        station = cursor.fetchone()

    if not station:
        flash('Bait station not found.', 'danger')
        return redirect(url_for('line_detail', line_id=line_id))

    if request.method == 'POST':
        code = request.form.get('code', '').strip()
        station_type = request.form.get('station_type', '').strip()
        other_type = request.form.get('other_type', '').strip() or None
        latitude = request.form.get('latitude', '').strip()
        longitude = request.form.get('longitude', '').strip()

        errors = []
        if not code:
            errors.append('Code is required.')
        valid_station_types = fetch_active_lookup(db, 'bait_station_types')
        if station_type not in valid_station_types:
            errors.append('Please select a valid station type.')
        if station_type == 'Other' and not other_type:
            errors.append('Please specify the type when "Other" is selected.')

        coord_error = validate_lincoln_nz_coordinates(latitude, longitude)
        if coord_error:
            errors.append(coord_error)

        if not errors:
            with db.get_cursor() as cursor:
                cursor.execute(
                    'SELECT station_id FROM bait_stations WHERE code = %s AND line_id = %s AND station_id != %s',
                    (code, line_id, station_id)
                )
                if cursor.fetchone():
                    errors.append(f'Station code "{code}" already exists on this line. Please choose a different code.')

        if errors:
            return redirect(url_for('line_detail', line_id=line_id,
                edit_station=station_id, error='; '.join(errors),
                code=code, station_type=station_type, other_type=other_type or '',
                latitude=latitude, longitude=longitude))

        with db.get_cursor() as cursor:
            cursor.execute(
                'UPDATE bait_stations SET code = %s, station_type = %s, other_type = %s, latitude = %s, longitude = %s WHERE station_id = %s',
                (code, station_type, other_type, latitude, longitude, station_id)
            )

        flash('Bait station updated.', 'success')
        return redirect(url_for('line_detail', line_id=line_id))

    return redirect(url_for('line_detail', line_id=line_id, edit_station=station_id))


@app.route('/admin/lines/<int:line_id>/bait-stations/deactivate', methods=['POST'])
@role_required('Super Admin', 'Group Coordinator', 'Support Technician')
def deactivate_bait_station(line_id):
    """Deactivate a bait station (soft-delete)."""
    station_id = request.form.get('station_id', type=int)
    delete_confirm = request.form.get('delete-confirm')

    if delete_confirm != 'delete':
        flash('You must type "delete" to confirm retirement.', 'danger')
        return redirect(url_for('line_detail', line_id=line_id))

    if not fetch_bait_station_for_group(db, station_id):
        flash('Station not found.', 'danger')
        return redirect(url_for('line_detail', line_id=line_id))

    retire_asset(db, 'bait_stations', 'station_id', station_id, session['user_id'])

    flash('Bait station retired.', 'success')
    return redirect(url_for('line_detail', line_id=line_id))


@app.route('/admin/lines/<int:line_id>/bait-stations/<int:station_id>/activate', methods=['POST'])
@role_required('Super Admin', 'Group Coordinator', 'Support Technician')
def activate_bait_station(line_id, station_id):
    """Reactivate a deactivated bait station."""
    if not fetch_bait_station_for_group(db, station_id):
        flash('Station not found.', 'danger')
        return redirect(url_for('line_detail', line_id=line_id))

    unretire_asset(db, 'bait_stations', 'station_id', station_id)

    flash('Bait station unretired.', 'success')
    return redirect(url_for('line_detail', line_id=line_id))


# ── Operator assignment ───────────────────────────────────────────────────────

@app.route('/admin/lines/<int:line_id>/assign', methods=['GET', 'POST'])
@role_required('Super Admin', 'Group Coordinator', 'Support Technician')
def assign_operators(line_id):
    """Assign or reassign operators to a trap line."""
    line_row = fetch_line_for_group(db, line_id)
    if not line_row:
        flash('Line not found in your group.', 'danger')
        return redirect(url_for('lines_index'))

    line_group_id = line_row['group_id']

    if request.method == 'POST':
        operator_ids = request.form.getlist('operator_ids')

        # Validate every submitted operator is an Operator in this line's
        # group — protects against POSTing arbitrary user_ids.
        with db.get_cursor() as cursor:
            cursor.execute(
                """
                SELECT user_id FROM group_memberships
                WHERE group_id = %s AND role = 'Operator'
                """,
                (line_group_id,)
            )
            valid_operator_ids = {row['user_id'] for row in cursor.fetchall()}

        clean_operator_ids = [
            int(oid) for oid in operator_ids
            if oid.isdigit() and int(oid) in valid_operator_ids
        ]

        with db.get_cursor() as cursor:
            # Delete ALL current assignments for this line
            cursor.execute("""
                DELETE FROM operator_lines
                WHERE line_id = %s
            """, (line_id,))

            # Re-insert only the checked ones
            for operator_id in clean_operator_ids:
                cursor.execute("""
                    INSERT INTO operator_lines (operator_id, line_id)
                    VALUES (%s, %s)
                """, (operator_id, line_id))

        flash('Operators updated.', 'success')
        return redirect(url_for('line_detail', line_id=line_id))

    line = None
    all_operators = []
    assigned_ids = []

    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT line_id, name
            FROM lines
            WHERE line_id = %s
            """,
            (line_id,)
        )
        line = cursor.fetchone()

        # Only list Operators who belong to the line's group — assigning
        # an Operator from another group would never be valid.
        cursor.execute(
            """
            SELECT u.user_id, u.username, u.first_name, u.last_name
            FROM users u
            JOIN group_memberships gm ON gm.user_id = u.user_id
            WHERE gm.role = 'Operator' AND gm.group_id = %s
            ORDER BY u.last_name ASC, u.first_name ASC
            """,
            (line_group_id,)
        )
        all_operators = cursor.fetchall()

        cursor.execute(
            """
            SELECT operator_id
            FROM operator_lines
            WHERE line_id = %s
            """,
            (line_id,)
        )
        assign_operators = cursor.fetchall()
        assigned_ids = [row['operator_id'] for row in assign_operators]

    return render_template('admin/assign_operators.html',
                           line_id=line_id,
                           line=line,
                           all_operators=all_operators,
                           assigned_ids=assigned_ids)


# ── Reference data management ────────────────────────────────────────────────

LOOKUP_CONFIGS = {
    'species': {
        'table': 'species',
        'label': 'Species',
        'label_plural': 'Species',
        'description': 'Species recorded in trap catches and bait station records',
        'usage_checks': [
            ("SELECT COUNT(*) AS cnt FROM trap_catches WHERE species_caught = %s", 'catch record'),
            ("SELECT COUNT(*) AS cnt FROM bait_station_records WHERE target_species = %s", 'bait station record'),
        ],
        'reserved': ['None', 'Other'],
    },
    'statuses': {
        'table': 'trap_statuses',
        'label': 'Trap Status',
        'label_plural': 'Trap Statuses',
        'description': 'Statuses used in trap catch records',
        'usage_checks': [
            ("SELECT COUNT(*) AS cnt FROM trap_catches WHERE status = %s", 'catch record'),
        ],
        'reserved': [],
    },
    'bait-types': {
        'table': 'bait_types',
        'label': 'Bait Type',
        'label_plural': 'Bait Types',
        'description': 'Bait types used in trap catch records',
        'usage_checks': [
            ("SELECT COUNT(*) AS cnt FROM trap_catches WHERE bait_type = %s", 'catch record'),
        ],
        'reserved': ['None', 'Other'],
    },
    'trap-types': {
        'table': 'trap_types',
        'label': 'Trap Type',
        'label_plural': 'Trap Types',
        'description': 'Types of traps available for installation',
        'usage_checks': [
            ("SELECT COUNT(*) AS cnt FROM traps WHERE trap_type = %s", 'trap'),
        ],
        'reserved': [],
    },
    'bait-station-types': {
        'table': 'bait_station_types',
        'label': 'Bait Station Type',
        'label_plural': 'Bait Station Types',
        'description': 'Types of bait stations available for installation',
        'usage_checks': [
            ("SELECT COUNT(*) AS cnt FROM bait_stations WHERE station_type = %s", 'bait station'),
        ],
        'reserved': ['Other'],
    },
    'bait-formulations': {
        'table': 'bait_formulations',
        'label': 'Bait Formulation',
        'label_plural': 'Bait Formulations',
        'description': 'Bait formulations used in bait station records',
        'usage_checks': [
            ("SELECT COUNT(*) AS cnt FROM bait_station_records WHERE formulation = %s", 'bait station record'),
        ],
        'reserved': [],
    },
    'active-ingredients': {
        'table': 'active_ingredients',
        'label': 'Active Ingredient',
        'label_plural': 'Active Ingredients',
        'description': 'Active ingredients used in bait station records',
        'usage_checks': [
            ("SELECT COUNT(*) AS cnt FROM bait_station_records WHERE active_ingredient = %s", 'bait station record'),
        ],
        'reserved': [],
    },
}


@app.route('/admin/reference-data')
@role_required('Super Admin', 'Support Technician')
def reference_data():
    """Landing page showing all reference data tables."""
    table_info = []
    with db.get_cursor() as cursor:
        for key, config in LOOKUP_CONFIGS.items():
            cursor.execute(
                f"SELECT COUNT(*) AS cnt FROM {config['table']} WHERE is_active = TRUE"
            )
            row = cursor.fetchone()
            table_info.append({
                'key': key,
                'label': config['label_plural'],
                'description': config['description'],
                'count': row['cnt'],
            })
    return render_template('admin/reference_data.html', tables=table_info)


@app.route('/admin/reference-data/<config_key>', methods=['GET', 'POST'])
@role_required('Super Admin', 'Support Technician')
def manage_lookup(config_key):
    """Generic CRUD handler for any lookup table."""
    if config_key not in LOOKUP_CONFIGS:
        flash('Invalid reference data table.', 'danger')
        return redirect(url_for('reference_data'))

    config = LOOKUP_CONFIGS[config_key]
    table = config['table']
    label = config['label']
    reserved = config['reserved']

    if request.method == 'POST':
        current_item_name = request.form.get('current-item-name', '').strip()
        item_name = request.form.get('item-name', '').strip()
        modal_action = request.form.get('modal-action')

        if modal_action == 'delete':
            if request.form.get('delete-confirm', '').strip().lower() != 'delete':
                flash('Please type "delete" to confirm deletion.', 'danger')
                return redirect(url_for('manage_lookup', config_key=config_key))

            total_usage = 0
            with db.get_cursor() as cursor:
                for check_query, _ in config['usage_checks']:
                    cursor.execute(check_query, (current_item_name,))
                    total_usage += cursor.fetchone()['cnt']

            if total_usage > 0:
                with db.get_cursor() as cursor:
                    cursor.execute(f"UPDATE {table} SET is_active = FALSE WHERE name = %s", (current_item_name,))
            else:
                with db.get_cursor() as cursor:
                    cursor.execute(f"DELETE FROM {table} WHERE name = %s", (current_item_name,))
            flash(f'{label} "{current_item_name}" deleted.', 'success')
            return redirect(url_for('manage_lookup', config_key=config_key))

        if not item_name:
            flash(f'Please provide a {label.lower()} name.', 'danger')
            return redirect(url_for('manage_lookup', config_key=config_key))

        if item_name in reserved or item_name.lower() in [r.lower() for r in reserved]:
            flash(f'"{item_name}" is a system-reserved value and cannot be modified.', 'danger')
            return redirect(url_for('manage_lookup', config_key=config_key))

        with db.get_cursor() as cursor:
            cursor.execute(f"SELECT name FROM {table} WHERE name = %s", (item_name,))
            if cursor.fetchone():
                flash(f'A {label.lower()} named "{item_name}" already exists.', 'danger')
                return redirect(url_for('manage_lookup', config_key=config_key))

            if modal_action == 'add':
                cursor.execute(f"INSERT INTO {table} (name) VALUES (%s)", (item_name,))
                flash(f'{label} "{item_name}" added.', 'success')
            elif modal_action == 'edit':
                cursor.execute(f"UPDATE {table} SET name = %s WHERE name = %s", (item_name, current_item_name))
                flash(f'{label} "{current_item_name}" renamed to "{item_name}".', 'success')

        return redirect(url_for('manage_lookup', config_key=config_key))

    with db.get_cursor() as cursor:
        cursor.execute(f"SELECT name FROM {table} WHERE is_active = TRUE ORDER BY name ASC")
        items = cursor.fetchall()

    return render_template('admin/manage_lookup.html',
                           config=config,
                           config_key=config_key,
                           items=items)


@app.route('/admin/species')
@role_required('Super Admin', 'Support Technician')
def manage_species():
    """Redirect to generic reference data handler."""
    return redirect(url_for('manage_lookup', config_key='species'))


@app.route('/admin/statuses')
@role_required('Super Admin', 'Support Technician')
def manage_statuses():
    """Redirect to generic reference data handler."""
    return redirect(url_for('manage_lookup', config_key='statuses'))


# ── Group management ─────────────────────────────────────────────────────────

@app.route('/admin/groups')
@role_required('Super Admin', 'Support Technician')
def admin_groups():
    """List all groups with summary info."""
    search = request.args.get('search', '').strip()
    status_filter = request.args.get('status', '').strip()

    query = '''
        SELECT g.group_id, g.name, g.is_public, g.is_active, g.created_at,
               g.tile_image, g.color_theme,
               COUNT(DISTINCT gm.user_id) AS member_count,
               STRING_AGG(DISTINCT u.first_name || ' ' || u.last_name, ', '
                   ORDER BY u.first_name || ' ' || u.last_name)
                   FILTER (WHERE gm.role = 'Group Coordinator') AS coordinators
        FROM groups g
        LEFT JOIN group_memberships gm ON gm.group_id = g.group_id
        LEFT JOIN users u ON gm.user_id = u.user_id
        WHERE 1=1
    '''
    params = []

    if search:
        query += ' AND g.name ILIKE %s'
        params.append(f'%{search}%')

    if status_filter == 'active':
        query += ' AND g.is_active = TRUE'
    elif status_filter == 'inactive':
        query += ' AND g.is_active = FALSE'

    query += ' GROUP BY g.group_id ORDER BY g.name ASC'

    with db.get_cursor() as cursor:
        cursor.execute(query, tuple(params))
        groups = cursor.fetchall()

    return render_template('admin/groups.html', groups=groups,
                           search=search, status_filter=status_filter)


@app.route('/admin/groups/create', methods=['GET', 'POST'])
@role_required('Super Admin', 'Support Technician')
def admin_group_create():
    """Create a new group directly and optionally appoint coordinators."""
    with db.get_cursor() as cursor:
        cursor.execute('''
            SELECT user_id, first_name, last_name, username
            FROM users
            WHERE is_super_admin = FALSE AND account_status = 'active'
            ORDER BY first_name, last_name
        ''')
        all_users = cursor.fetchall()

    if request.method == 'POST':
        name = request.form.get('name', '').strip()
        description = request.form.get('description', '').strip()
        is_public = request.form.get('is_public') == '1'
        coordinator_ids = request.form.getlist('coordinator_ids', type=int)
        file = request.files.get('image')

        errors = []
        if not name:
            errors.append('Group name is required.')
        if not description:
            errors.append('Description is required.')
        if not coordinator_ids:
            errors.append('At least one Group Coordinator must be selected.')
        if file and file.filename and not allowed_file(file.filename):
            errors.append('Image must be PNG, JPG, JPEG, or GIF.')

        if errors:
            for msg in errors:
                flash(msg, 'danger')
            return render_template('admin/create_group.html', all_users=all_users)

        with db.get_cursor() as cursor:
            cursor.execute('SELECT group_id FROM groups WHERE name = %s', (name,))
            if cursor.fetchone():
                flash(f'A group named "{name}" already exists.', 'danger')
                return render_template('admin/create_group.html', all_users=all_users)

        # Optional image upload
        filename = None
        if file and file.filename:
            filename, _ = save_uploaded_image(file, 'group')

        with db.get_cursor() as cursor:
            cursor.execute('''
                INSERT INTO groups (name, description, is_public, tile_image)
                VALUES (%s, %s, %s, %s)
                RETURNING group_id
            ''', (name, description, is_public, filename))
            group_id = cursor.fetchone()['group_id']

        # Add coordinators and notify them
        valid_user_ids = {u['user_id'] for u in all_users}
        for uid in coordinator_ids:
            if uid not in valid_user_ids:
                continue
            with db.get_cursor() as cursor:
                cursor.execute('''
                    INSERT INTO group_memberships (user_id, group_id, role)
                    VALUES (%s, %s, 'Group Coordinator')
                    ON CONFLICT (user_id, group_id) DO UPDATE SET role = 'Group Coordinator'
                ''', (uid, group_id))
            insert_notification(
                db, uid,
                f'You have been appointed as Group Coordinator for "{name}". '
                'Visit your dashboard to get started.',
                'success',
                url=url_for('group_landing', group_id=group_id)
            )

        flash(f'Group "{name}" created successfully.', 'success')
        return redirect(url_for('admin_group_detail', group_id=group_id))

    return render_template('admin/create_group.html', all_users=all_users)


@app.route('/admin/groups/<int:group_id>')
@role_required('Super Admin', 'Support Technician')
def admin_group_detail(group_id):
    """View and manage a single group."""
    with db.get_cursor() as cursor:
        cursor.execute('''
            SELECT g.group_id, g.name, g.description, g.is_public, g.is_active, g.created_at,
                   g.tile_image, g.color_theme,
                   COUNT(DISTINCT gm.user_id) AS member_count
            FROM groups g
            LEFT JOIN group_memberships gm ON gm.group_id = g.group_id
            WHERE g.group_id = %s
            GROUP BY g.group_id
        ''', (group_id,))
        group = cursor.fetchone()

    if not group:
        flash('Group not found.', 'danger')
        return redirect(url_for('admin_groups'))

    with db.get_cursor() as cursor:
        cursor.execute('''
            SELECT u.user_id, u.username, u.first_name, u.last_name, u.account_status
            FROM group_memberships gm
            JOIN users u ON gm.user_id = u.user_id
            WHERE gm.group_id = %s AND gm.role = 'Group Coordinator'
            ORDER BY u.first_name, u.last_name
        ''', (group_id,))
        coordinators = cursor.fetchall()
        coordinator_ids = {c['user_id'] for c in coordinators}

        cursor.execute('''
            SELECT u.user_id, u.username, u.first_name, u.last_name, gm.role
            FROM group_memberships gm
            JOIN users u ON gm.user_id = u.user_id
            WHERE gm.group_id = %s
              AND gm.role NOT IN ('Group Coordinator')
              AND u.is_super_admin = FALSE
            ORDER BY u.first_name, u.last_name
        ''', (group_id,))
        promotable_members = cursor.fetchall()

    return render_template('admin/group_detail.html',
                           group=group,
                           coordinators=coordinators,
                           coordinator_ids=coordinator_ids,
                           promotable_members=promotable_members)


@app.route('/admin/groups/<int:group_id>/edit', methods=['POST'])
@role_required('Super Admin', 'Support Technician')
def admin_group_edit(group_id):
    """Edit a group's name and description."""
    name = request.form.get('name', '').strip()
    description = request.form.get('description', '').strip()

    if not name:
        flash('Group name is required.', 'danger')
        return redirect(url_for('admin_group_detail', group_id=group_id))

    if not description:
        flash('Description is required.', 'danger')
        return redirect(url_for('admin_group_detail', group_id=group_id))

    with db.get_cursor() as cursor:
        cursor.execute('SELECT group_id FROM groups WHERE name = %s AND group_id != %s',
                       (name, group_id))
        if cursor.fetchone():
            flash(f'A group named "{name}" already exists.', 'danger')
            return redirect(url_for('admin_group_detail', group_id=group_id))

        cursor.execute('UPDATE groups SET name = %s, description = %s WHERE group_id = %s',
                       (name, description, group_id))

    flash('Group updated successfully.', 'success')
    return redirect(url_for('admin_group_detail', group_id=group_id))


@app.route('/admin/groups/<int:group_id>/toggle-active', methods=['POST'])
@role_required('Super Admin', 'Support Technician')
def admin_group_toggle_active(group_id):
    """Deactivate or reactivate a group."""
    with db.get_cursor() as cursor:
        cursor.execute('SELECT name, is_active FROM groups WHERE group_id = %s', (group_id,))
        group = cursor.fetchone()
        if not group:
            flash('Group not found.', 'danger')
            return redirect(url_for('admin_groups'))

        new_status = not group['is_active']
        cursor.execute('UPDATE groups SET is_active = %s WHERE group_id = %s',
                       (new_status, group_id))

    if new_status:
        flash(f'"{group["name"]}" has been reactivated.', 'success')
    else:
        flash(f'"{group["name"]}" has been deactivated. Members will lose write access.', 'warning')

    return redirect(url_for('admin_groups'))


@app.route('/admin/groups/<int:group_id>/coordinators/add', methods=['POST'])
@role_required('Super Admin')  # role changes — Super Admin only per spec
def admin_group_add_coordinator(group_id):
    """Promote an existing member to Group Coordinator."""
    user_id = request.form.get('user_id', type=int)
    if not user_id:
        flash('Invalid user.', 'danger')
        return redirect(url_for('admin_group_detail', group_id=group_id))

    if not fetch_membership_role(db, user_id, group_id):
        flash('User is not a member of this group.', 'danger')
        return redirect(url_for('admin_group_detail', group_id=group_id))

    update_user_role(db, user_id, group_id, 'Group Coordinator')

    flash('Member promoted to Group Coordinator.', 'success')
    return redirect(url_for('admin_group_detail', group_id=group_id))


@app.route('/admin/groups/<int:group_id>/coordinators/remove/<int:user_id>', methods=['POST'])
@role_required('Super Admin')  # role changes — Super Admin only per spec
def admin_group_remove_coordinator(group_id, user_id):
    """Demote a Group Coordinator back to Observer (must keep at least one)."""
    with db.get_cursor() as cursor:
        cursor.execute("""
            SELECT COUNT(*) AS cnt FROM group_memberships
            WHERE group_id = %s AND role = 'Group Coordinator'
        """, (group_id,))
        if cursor.fetchone()['cnt'] <= 1:
            flash('Cannot remove the only coordinator. Add another coordinator first.', 'danger')
            return redirect(url_for('admin_group_detail', group_id=group_id))

        cursor.execute(
            "UPDATE group_memberships SET role = 'Observer' WHERE user_id = %s AND group_id = %s",
            (user_id, group_id)
        )

    flash('Coordinator demoted to Observer.', 'success')
    return redirect(url_for('admin_group_detail', group_id=group_id))


@app.route('/admin/groups/<int:group_id>/image', methods=['POST'])
@role_required('Super Admin', 'Support Technician')
def admin_group_update_image(group_id):
    """Upload or replace the group's tile image (Super Admin controlled).

    tile_image is independent of cover_photo / profile_photo, which are
    coordinator-controlled via the group identity flow.
    """
    with db.get_cursor() as cursor:
        cursor.execute('SELECT tile_image FROM groups WHERE group_id = %s', (group_id,))
        group = cursor.fetchone()

    if not group:
        flash('Group not found.', 'danger')
        return redirect(url_for('admin_groups'))

    file = request.files.get('image')
    filename, img_err = save_uploaded_image(file, f'group_{group_id}')
    if not filename:
        flash(img_err or 'No file selected.', 'danger')
        return redirect(url_for('admin_group_detail', group_id=group_id))

    delete_upload(group['tile_image'])

    with db.get_cursor() as cursor:
        cursor.execute('UPDATE groups SET tile_image = %s WHERE group_id = %s',
                       (filename, group_id))

    flash('Group tile image updated.', 'success')
    return redirect(url_for('admin_group_detail', group_id=group_id))


@app.route('/admin/groups/<int:group_id>/image/remove', methods=['POST'])
@role_required('Super Admin', 'Support Technician')
def admin_group_remove_image(group_id):
    """Remove the group's tile image (Super Admin controlled)."""
    with db.get_cursor() as cursor:
        cursor.execute('SELECT tile_image FROM groups WHERE group_id = %s', (group_id,))
        group = cursor.fetchone()

    if not group:
        flash('Group not found.', 'danger')
        return redirect(url_for('admin_groups'))

    if group['tile_image']:
        delete_upload(group['tile_image'])
        with db.get_cursor() as cursor:
            cursor.execute('UPDATE groups SET tile_image = NULL WHERE group_id = %s', (group_id,))
        flash('Group tile image removed.', 'success')
    else:
        flash('No tile image to remove.', 'info')

    return redirect(url_for('admin_group_detail', group_id=group_id))


# ── Group applications ────────────────────────────────────────────────────────

@app.route('/admin/group-applications')
@role_required('Super Admin', 'Support Technician')
def admin_group_applications():
    """List all group creation applications, filterable by status."""
    status_filter = request.args.get('status', 'pending').strip()
    if status_filter not in ('pending', 'approved', 'rejected', 'all'):
        status_filter = 'pending'

    query = '''
        SELECT ga.application_id, ga.proposed_name, ga.description, ga.location,
               ga.justification, ga.image, ga.status, ga.applied_at,
               ga.decided_at, ga.decision_reason,
               u.user_id, u.first_name, u.last_name, u.username, u.email,
               d.first_name AS decided_by_first, d.last_name AS decided_by_last
        FROM group_applications ga
        JOIN users u ON ga.user_id = u.user_id
        LEFT JOIN users d ON ga.decided_by = d.user_id
        WHERE 1=1
    '''
    params = []

    if status_filter != 'all':
        query += ' AND ga.status = %s'
        params.append(status_filter)

    query += ' ORDER BY ga.applied_at DESC'

    with db.get_cursor() as cursor:
        cursor.execute(query, tuple(params))
        applications = cursor.fetchall()

        cursor.execute("""
            SELECT
                COUNT(*) FILTER (WHERE status = 'pending') AS pending_count,
                COUNT(*) FILTER (WHERE status = 'approved') AS approved_count,
                COUNT(*) FILTER (WHERE status = 'rejected') AS rejected_count,
                COUNT(*) AS total_count
            FROM group_applications
        """)
        counts = cursor.fetchone()

    return render_template('admin/group_applications.html',
                           applications=applications,
                           status_filter=status_filter,
                           counts=counts)


@app.route('/admin/group-applications/<int:application_id>/approve', methods=['POST'])
@role_required('Super Admin', 'Support Technician')
def admin_group_application_approve(application_id):
    """Approve a group application — creates the group and assigns the applicant as coordinator."""
    with db.get_cursor() as cursor:
        cursor.execute('''
            SELECT ga.*, u.first_name, u.last_name
            FROM group_applications ga
            JOIN users u ON ga.user_id = u.user_id
            WHERE ga.application_id = %s
        ''', (application_id,))
        application = cursor.fetchone()

    if not application:
        flash('Application not found.', 'danger')
        return redirect(url_for('admin_group_applications'))

    if application['status'] != 'pending':
        flash('This application has already been decided.', 'warning')
        return redirect(url_for('admin_group_applications'))

    with db.get_cursor() as cursor:
        cursor.execute('SELECT group_id FROM groups WHERE name = %s', (application['proposed_name'],))
        if cursor.fetchone():
            flash(f'A group named "{application["proposed_name"]}" already exists. Please reject this application or ask the applicant to choose a different name.', 'danger')
            return redirect(url_for('admin_group_applications'))

        cursor.execute('''
            INSERT INTO groups (name, description, location, is_public)
            VALUES (%s, %s, %s, FALSE)
            RETURNING group_id
        ''', (application['proposed_name'], application['description'], application['location']))
        group_id = cursor.fetchone()['group_id']

        if application['image']:
            cursor.execute('UPDATE groups SET cover_photo = %s WHERE group_id = %s',
                           (application['image'], group_id))

        cursor.execute('''
            INSERT INTO group_memberships (user_id, group_id, role)
            VALUES (%s, %s, 'Group Coordinator')
            ON CONFLICT (user_id, group_id) DO UPDATE SET role = 'Group Coordinator'
        ''', (application['user_id'], group_id))

        cursor.execute('''
            UPDATE group_applications
            SET status = 'approved', decided_by = %s, decided_at = CURRENT_TIMESTAMP
            WHERE application_id = %s
        ''', (session['user_id'], application_id))

    insert_notification(
        db, application['user_id'],
        f'Your application to create group "{application["proposed_name"]}" has been approved! '
        'You are now the Group Coordinator. Visit the group to get started.',
        'success',
        url=url_for('group_landing', group_id=group_id)
    )

    flash(f'Application approved. Group "{application["proposed_name"]}" created with {application["first_name"]} {application["last_name"]} as coordinator.', 'success')
    return redirect(url_for('admin_group_applications'))


@app.route('/admin/group-applications/<int:application_id>/reject', methods=['POST'])
@role_required('Super Admin', 'Support Technician')
def admin_group_application_reject(application_id):
    """Reject a group application with an optional reason."""
    reason = request.form.get('reason', '').strip()

    with db.get_cursor() as cursor:
        cursor.execute('''
            SELECT ga.*, u.first_name, u.last_name
            FROM group_applications ga
            JOIN users u ON ga.user_id = u.user_id
            WHERE ga.application_id = %s
        ''', (application_id,))
        application = cursor.fetchone()

    if not application:
        flash('Application not found.', 'danger')
        return redirect(url_for('admin_group_applications'))

    if application['status'] != 'pending':
        flash('This application has already been decided.', 'warning')
        return redirect(url_for('admin_group_applications'))

    with db.get_cursor() as cursor:
        cursor.execute('''
            UPDATE group_applications
            SET status = 'rejected', decided_by = %s, decided_at = CURRENT_TIMESTAMP,
                decision_reason = %s
            WHERE application_id = %s
        ''', (session['user_id'], reason or None, application_id))

    notification_msg = f'Your application to create group "{application["proposed_name"]}" has been declined.'
    if reason:
        notification_msg += f' Reason: {reason}'
    insert_notification(db, application['user_id'], notification_msg, 'warning')

    flash(f'Application from {application["first_name"]} {application["last_name"]} rejected.', 'success')
    return redirect(url_for('admin_group_applications'))


@app.route('/admin/bait-types')
@role_required('Super Admin', 'Support Technician')
def manage_bait_types():
    """Redirect to generic reference data handler."""
    return redirect(url_for('manage_lookup', config_key='bait-types'))


# ── Support Technician role management ───────────────────────────────────────

@app.route('/admin/support-technicians')
@role_required('Super Admin')  # role changes — Super Admin only per spec
def admin_support_technicians():
    """List current technicians; search for users to grant/revoke the role."""
    search = request.args.get('search', '').strip()

    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT user_id, username, first_name, last_name, account_status
            FROM users
            WHERE is_support_tech = TRUE
            ORDER BY last_name, first_name
            """
        )
        technicians = cursor.fetchall()

        search_results = []
        if search:
            cursor.execute(
                """
                SELECT user_id, username, first_name, last_name,
                       account_status, is_support_tech, is_super_admin
                FROM users
                WHERE (username ILIKE %s OR first_name ILIKE %s OR last_name ILIKE %s
                       OR (first_name || ' ' || last_name) ILIKE %s)
                  AND is_super_admin = FALSE
                ORDER BY last_name, first_name
                LIMIT 20
                """,
                (f'%{search}%', f'%{search}%', f'%{search}%', f'%{search}%')
            )
            search_results = cursor.fetchall()

        cursor.execute(
            """
            SELECT
                sal.action, sal.created_at,
                target.first_name || ' ' || target.last_name AS target_name,
                actor.first_name  || ' ' || actor.last_name  AS actor_name
            FROM support_tech_audit_log sal
            JOIN users target ON target.user_id = sal.target_user_id
            LEFT JOIN users actor  ON actor.user_id  = sal.actor_user_id
            ORDER BY sal.created_at DESC
            LIMIT 50
            """
        )
        audit_log = cursor.fetchall()

    return render_template('admin/support_technicians.html',
                           technicians=technicians,
                           search=search,
                           search_results=search_results,
                           audit_log=audit_log)


@app.route('/admin/support-technicians/<int:user_id>/grant', methods=['POST'])
@role_required('Super Admin')  # role changes — Super Admin only per spec
def admin_support_tech_grant(user_id):
    """Grant the Support Technician role to a user."""
    user = fetch_user_info(db, user_id)

    if not user:
        flash('User not found.', 'danger')
        return redirect(url_for('admin_support_technicians'))

    if user['is_super_admin']:
        flash('Super Admins already have elevated access.', 'warning')
        return redirect(url_for('admin_support_technicians'))

    with db.get_cursor() as cursor:
        cursor.execute(
            'UPDATE users SET is_support_tech = TRUE WHERE user_id = %s',
            (user_id,)
        )
        cursor.execute(
            'INSERT INTO support_tech_audit_log (target_user_id, actor_user_id, action) VALUES (%s, %s, %s)',
            (user_id, session['user_id'], 'granted')
        )

    full_name = f"{user['first_name']} {user['last_name']}"
    logger.info('Super Admin %s granted Support Technician role to user %d (%s)',
                       session['user_id'], user_id, full_name)
    flash(f'{full_name} granted Support Technician role.', 'success')
    return redirect(url_for('admin_support_technicians'))


@app.route('/admin/support-technicians/<int:user_id>/revoke', methods=['POST'])
@role_required('Super Admin')  # role changes — Super Admin only per spec
def admin_support_tech_revoke(user_id):
    """Revoke the Support Technician role from a user."""
    user = fetch_user_info(db, user_id)

    if not user:
        flash('User not found.', 'danger')
        return redirect(url_for('admin_support_technicians'))

    with db.get_cursor() as cursor:
        cursor.execute(
            'UPDATE users SET is_support_tech = FALSE WHERE user_id = %s',
            (user_id,)
        )
        cursor.execute(
            'INSERT INTO support_tech_audit_log (target_user_id, actor_user_id, action) VALUES (%s, %s, %s)',
            (user_id, session['user_id'], 'revoked')
        )

    full_name = f"{user['first_name']} {user['last_name']}"
    logger.info('Super Admin %s revoked Support Technician role from user %d (%s)',
                       session['user_id'], user_id, full_name)
    flash(f'{full_name} Support Technician role revoked.', 'success')
    return redirect(url_for('admin_support_technicians'))

