"""admin.py — Admin dashboard, user management, lines, traps, operator assignment, lookups."""

from flask import render_template, request, redirect, url_for, flash, session
import os
import uuid
from app import app, db
from app.utils import (
    role_required,
    validate_lincoln_nz_coordinates,
    LINCOLN_NZ_LAT_RANGE,
    LINCOLN_NZ_LON_RANGE,
    LINE_COLOURS,
    allowed_file,
    UPLOAD_FOLDER,
)
from app.helpers.dbHelper import update_user_active, fetch_lookup_data, fetch_user_info, update_user_role, insert_notification, fetch_active_lookup


# ── Dashboard ─────────────────────────────────────────────────────────────────

@app.route('/admin/dashboard')
@role_required('Super Admin')
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
        app.logger.error(f'Admin dashboard error: {e}')
 
    return render_template('admin/dashboard.html',
                           stats=stats,
                           recent_users=recent_users,
                           recent_catches=recent_catches)


# ── User management ───────────────────────────────────────────────────────────

@app.route('/admin/users')
@role_required('Super Admin')
def admin_users():
    """List all registered users with role and account status."""
    search = request.args.get('search', '').strip()
    role_filter = request.args.get('role', '').strip()
    status_filter = request.args.get('status', '').strip()

    query = '''
        SELECT u.user_id, u.username, u.first_name, u.last_name,
               gm.role, u.account_status, u.date_joined, u.last_login
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

    if role_filter:
        query += " AND gm.role = %s"
        params.append(role_filter)

    if status_filter:
        query += " AND u.account_status = %s"
        params.append(status_filter)

    # Default sorting (subsequent sorting is handled client-side)
    query += " ORDER BY u.first_name ASC, u.last_name ASC"

    with db.get_cursor() as cursor:
        cursor.execute(query, tuple(params))
        users = cursor.fetchall()

    return render_template('admin/users.html', users=users, 
                           search=search, role_filter=role_filter, 
                           status_filter=status_filter)


@app.route('/admin/users/<int:user_id>')
@role_required('Super Admin')
def admin_user_detail(user_id):
    """View detailed profile for a single user."""
    with db.get_cursor() as cursor:
        cursor.execute('''
            SELECT u.user_id, u.username, u.first_name, u.last_name, u.email, u.phone, u.address,
                   u.emergency_contact_name, u.emergency_contact_phone, u.profile_photo,
                   u.notes, gm.role, u.account_status, u.date_joined, u.last_login
            FROM users u
            LEFT JOIN group_memberships gm ON gm.user_id = u.user_id
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

    assigned_lines = []
    if user['role'] == 'Operator':
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
                           assigned_lines=assigned_lines, 
                           catches=catches,
                           observations=observations,
                           line_colours=LINE_COLOURS)


@app.route('/admin/users/<int:user_id>/toggle-active', methods=['POST'])
@role_required('Super Admin')
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
@role_required('Super Admin')
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
    with db.get_cursor() as cursor:
        cursor.execute(
            "SELECT role FROM group_memberships WHERE user_id = %s AND group_id = %s",
            (user_id, session.get('group_id'))
        )
        gm_row = cursor.fetchone()
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
@role_required('Super Admin')
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
@role_required('Super Admin', 'Group Coordinator')
def new_line():
    """Create a new line (Trap or Bait Station) in the currently selected group."""
    if request.method == 'POST':
        name = request.form.get('name', '').strip()
        line_type = request.form.get('type', '').strip()

        if not name:
            flash('Please provide a name', 'danger')
            return render_template('lines/new_line.html', name=name, line_type=line_type)

        if line_type not in ('Trap', 'Bait Station'):
            flash('Please select a line type', 'danger')
            return render_template('lines/new_line.html', name=name, line_type=line_type)

        with db.get_cursor() as cursor:
            cursor.execute('SELECT line_id FROM lines WHERE name = %s', (name,))
            if cursor.fetchone():
                flash(f'A line named "{name}" already exists', 'danger')
                return render_template('lines/new_line.html', name=name, line_type=line_type)

            cursor.execute(
                'INSERT INTO lines (name, type, group_id) VALUES (%s, %s, %s)',
                (name, line_type, session.get('group_id'))
            )

        flash(f'{line_type} line "{name}" created successfully', 'success')
        return redirect(url_for('lines_index'))

    return render_template('lines/new_line.html', name='', line_type='Trap')


@app.route('/admin/lines/<int:line_id>/edit', methods=['GET', 'POST'])
@role_required('Super Admin', 'Group Coordinator')
def edit_line(line_id):
    """Edit an existing trap line."""
    line = None

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

    # Query line details for pre-filling the form
    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT line_id, name, type
            FROM lines
            WHERE line_id = %s
            """,
            (line_id,)
        )
        line = cursor.fetchone()
        if not line:
            flash('Trap line not found.', 'danger')
            return redirect(url_for('lines_index'))

    return render_template(
        'lines/edit_line.html',
        line=line,
        line_id=line_id
    )


@app.route('/admin/lines/<int:line_id>/retire', methods=['POST'])
@role_required('Super Admin', 'Group Coordinator')
def retire_line(line_id):
    """Retire a trap line (set is_retired = TRUE)."""
    has_active_traps = request.args.get('active_traps') == '1'
    delete_confirm = request.form.get('delete-confirm')

    if delete_confirm != 'delete':
        flash('You must type "delete" to confirm retiring line.', 'danger')
        return redirect(url_for('lines_index'))

    retired_by = session['user_id']

    with db.get_cursor() as cursor:
        cursor.execute(
            """
            UPDATE lines
            SET is_retired = TRUE, retired_at = CURRENT_TIMESTAMP, retired_by = %s
            WHERE line_id = %s
            """,
            (retired_by, line_id)
        )

        if has_active_traps:
            cursor.execute(
                """
                UPDATE traps
                SET is_retired = TRUE, retired_at = CURRENT_TIMESTAMP, retired_by = %s
                WHERE line_id = %s AND is_retired = FALSE
                """,
                (retired_by, line_id)
            )
            cursor.execute(
                """
                UPDATE bait_stations
                SET is_retired = TRUE, retired_at = CURRENT_TIMESTAMP, retired_by = %s
                WHERE line_id = %s AND is_retired = FALSE
                """,
                (retired_by, line_id)
            )

    flash('Line retired.', 'success')
    return redirect(url_for('lines_index'))


@app.route('/admin/lines/<int:line_id>/unretire', methods=['POST'])
@role_required('Super Admin', 'Group Coordinator')
def unretire_line(line_id):
    """Unretire a line (set is_retired = FALSE)."""
    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT line_id, group_id FROM lines WHERE line_id = %s',
            (line_id,)
        )
        line = cursor.fetchone()

    if not line or line['group_id'] != session.get('group_id'):
        flash('Line not found in your group.', 'danger')
        return redirect(url_for('lines_index'))

    with db.get_cursor() as cursor:
        cursor.execute(
            'UPDATE lines SET is_retired = FALSE, retired_at = NULL, retired_by = NULL WHERE line_id = %s',
            (line_id,)
        )

    flash('Line unretired.', 'success')
    return redirect(url_for('lines_index'))


# ── Traps ─────────────────────────────────────────────────────────────────────

@app.route('/admin/lines/<int:line_id>/new_trap', methods=['POST'])
@role_required('Super Admin', 'Group Coordinator')
def new_trap(line_id):
    """Add a new trap to a line."""
    with db.get_cursor() as cursor:
        cursor.execute("SELECT line_id, name, is_retired FROM lines WHERE line_id = %s", (line_id,))
        line = cursor.fetchone()

        if not line:
            flash('Trap line not found', 'danger')
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
@role_required('Super Admin', 'Group Coordinator')
def edit_trap(line_id, trap_id):
    """Edit an existing trap."""
    trap_types = fetch_active_lookup(db, 'trap_types')
    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT trap_id, line_id, code, trap_type, latitude, longitude, is_retired
            FROM traps
            WHERE trap_id = %s
            """,
            (trap_id,)
        )
        trap = cursor.fetchone()
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
@role_required('Super Admin', 'Group Coordinator')
def retire_trap(line_id):
    """Retire an individual trap (set is_retired = TRUE)."""
    trap_id = request.form.get('trap_id')
    delete_confirm = request.form.get('delete-confirm')

    if delete_confirm != 'delete':
        flash('You must type "delete" to confirm retiring the trap.', 'danger')
        return redirect(url_for('line_detail', line_id=line_id))

    retired_by = session['user_id']

    with db.get_cursor() as cursor:
        cursor.execute(
            """
            UPDATE traps
            SET is_retired = TRUE, retired_at = CURRENT_TIMESTAMP, retired_by = %s
            WHERE trap_id = %s
            """,
            (retired_by, trap_id)
        )

    flash('Trap retired.', 'success')
    return redirect(url_for('line_detail', line_id=line_id))


@app.route('/admin/traps/<int:line_id>/<int:trap_id>/unretire', methods=['POST'])
@role_required('Super Admin', 'Group Coordinator')
def unretire_trap(line_id, trap_id):
    """Unretire an individual trap (set is_retired = FALSE)."""
    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT t.trap_id FROM traps t
            JOIN lines l ON l.line_id = t.line_id
            WHERE t.trap_id = %s AND l.group_id = %s
            """,
            (trap_id, session.get('group_id'))
        )
        if not cursor.fetchone():
            flash('Trap not found.', 'danger')
            return redirect(url_for('line_detail', line_id=line_id))

        cursor.execute(
            'UPDATE traps SET is_retired = FALSE, retired_at = NULL, retired_by = NULL WHERE trap_id = %s',
            (trap_id,)
        )

    flash('Trap unretired.', 'success')
    return redirect(url_for('line_detail', line_id=line_id))


# ── Bait stations ─────────────────────────────────────────────────────────────

@app.route('/admin/lines/<int:line_id>/new-bait-station', methods=['GET', 'POST'])
@role_required('Super Admin', 'Group Coordinator')
def new_bait_station(line_id):
    """Add a new bait station to a Bait Station line."""
    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT line_id, name, type, is_retired, group_id FROM lines WHERE line_id = %s',
            (line_id,)
        )
        line = cursor.fetchone()

    if not line or line['group_id'] != session.get('group_id'):
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
@role_required('Super Admin', 'Group Coordinator')
def edit_bait_station(line_id, station_id):
    """Edit an existing bait station."""
    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT l.line_id, l.group_id FROM lines l WHERE l.line_id = %s',
            (line_id,)
        )
        line = cursor.fetchone()

    if not line or line['group_id'] != session.get('group_id'):
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
@role_required('Super Admin', 'Group Coordinator')
def deactivate_bait_station(line_id):
    """Deactivate a bait station (soft-delete)."""
    station_id = request.form.get('station_id', type=int)
    delete_confirm = request.form.get('delete-confirm')

    if delete_confirm != 'delete':
        flash('You must type "delete" to confirm retirement.', 'danger')
        return redirect(url_for('line_detail', line_id=line_id))

    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT bs.station_id FROM bait_stations bs JOIN lines l ON l.line_id = bs.line_id WHERE bs.station_id = %s AND l.group_id = %s',
            (station_id, session.get('group_id'))
        )
        if not cursor.fetchone():
            flash('Station not found.', 'danger')
            return redirect(url_for('line_detail', line_id=line_id))

        cursor.execute(
            'UPDATE bait_stations SET is_retired = TRUE, retired_at = CURRENT_TIMESTAMP, retired_by = %s WHERE station_id = %s',
            (session['user_id'], station_id)
        )

    flash('Bait station retired.', 'success')
    return redirect(url_for('line_detail', line_id=line_id))


@app.route('/admin/lines/<int:line_id>/bait-stations/<int:station_id>/activate', methods=['POST'])
@role_required('Super Admin', 'Group Coordinator')
def activate_bait_station(line_id, station_id):
    """Reactivate a deactivated bait station."""
    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT bs.station_id FROM bait_stations bs JOIN lines l ON l.line_id = bs.line_id WHERE bs.station_id = %s AND l.group_id = %s',
            (station_id, session.get('group_id'))
        )
        if not cursor.fetchone():
            flash('Station not found.', 'danger')
            return redirect(url_for('line_detail', line_id=line_id))

        cursor.execute(
            'UPDATE bait_stations SET is_retired = FALSE, retired_at = NULL, retired_by = NULL WHERE station_id = %s',
            (station_id,)
        )

    flash('Bait station unretired.', 'success')
    return redirect(url_for('line_detail', line_id=line_id))


# ── Operator assignment ───────────────────────────────────────────────────────

@app.route('/admin/lines/<int:line_id>/assign', methods=['GET', 'POST'])
@role_required('Super Admin', 'Group Coordinator')
def assign_operators(line_id):
    """Assign or reassign operators to a trap line."""
    if request.method == 'POST':
        operator_ids = request.form.getlist('operator_ids')

        with db.get_cursor() as cursor:
            # Delete ALL current assignments for this line
            cursor.execute("""
                DELETE FROM operator_lines
                WHERE line_id = %s
            """, (line_id,))

            # Re-insert only the checked ones
            for operator_id in operator_ids:
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

        cursor.execute(
            """
            SELECT u.user_id, u.username, u.first_name, u.last_name
            FROM users u
            JOIN group_memberships gm ON gm.user_id = u.user_id
            WHERE gm.role = 'Operator'
            ORDER BY u.last_name ASC, u.first_name ASC
            """
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
        'reserved': ['None'],
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
@role_required('Super Admin')
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
@role_required('Super Admin')
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
@role_required('Super Admin')
def manage_species():
    """Redirect to generic reference data handler."""
    return redirect(url_for('manage_lookup', config_key='species'))


@app.route('/admin/statuses')
@role_required('Super Admin')
def manage_statuses():
    """Redirect to generic reference data handler."""
    return redirect(url_for('manage_lookup', config_key='statuses'))


# ── Group management ─────────────────────────────────────────────────────────

@app.route('/admin/groups')
@role_required('Super Admin')
def admin_groups():
    """List all groups with summary info."""
    search = request.args.get('search', '').strip()
    status_filter = request.args.get('status', '').strip()

    query = '''
        SELECT g.group_id, g.name, g.is_public, g.is_active, g.created_at,
               g.cover_photo, g.color_theme,
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
@role_required('Super Admin')
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
            ext = file.filename.rsplit('.', 1)[1].lower()
            filename = f"group_{uuid.uuid4().hex}.{ext}"
            os.makedirs(UPLOAD_FOLDER, exist_ok=True)
            file.save(os.path.join(UPLOAD_FOLDER, filename))

        with db.get_cursor() as cursor:
            cursor.execute('''
                INSERT INTO groups (name, description, is_public, cover_photo)
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
                'success'
            )

        flash(f'Group "{name}" created successfully.', 'success')
        return redirect(url_for('admin_group_detail', group_id=group_id))

    return render_template('admin/create_group.html', all_users=all_users)


@app.route('/admin/groups/<int:group_id>')
@role_required('Super Admin')
def admin_group_detail(group_id):
    """View and manage a single group."""
    with db.get_cursor() as cursor:
        cursor.execute('''
            SELECT g.group_id, g.name, g.description, g.is_public, g.is_active, g.created_at,
                   g.cover_photo, g.color_theme,
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
@role_required('Super Admin')
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
@role_required('Super Admin')
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
@role_required('Super Admin')
def admin_group_add_coordinator(group_id):
    """Promote an existing member to Group Coordinator."""
    user_id = request.form.get('user_id', type=int)
    if not user_id:
        flash('Invalid user.', 'danger')
        return redirect(url_for('admin_group_detail', group_id=group_id))

    with db.get_cursor() as cursor:
        cursor.execute('SELECT role FROM group_memberships WHERE user_id = %s AND group_id = %s',
                       (user_id, group_id))
        membership = cursor.fetchone()
        if not membership:
            flash('User is not a member of this group.', 'danger')
            return redirect(url_for('admin_group_detail', group_id=group_id))

        cursor.execute(
            "UPDATE group_memberships SET role = 'Group Coordinator' WHERE user_id = %s AND group_id = %s",
            (user_id, group_id)
        )

    flash('Member promoted to Group Coordinator.', 'success')
    return redirect(url_for('admin_group_detail', group_id=group_id))


@app.route('/admin/groups/<int:group_id>/coordinators/remove/<int:user_id>', methods=['POST'])
@role_required('Super Admin')
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
@role_required('Super Admin')
def admin_group_update_image(group_id):
    """Upload or replace the group's tile image."""
    with db.get_cursor() as cursor:
        cursor.execute('SELECT image FROM groups WHERE group_id = %s', (group_id,))
        group = cursor.fetchone()

    if not group:
        flash('Group not found.', 'danger')
        return redirect(url_for('admin_groups'))

    file = request.files.get('image')
    if not file or not file.filename:
        flash('No file selected.', 'danger')
        return redirect(url_for('admin_group_detail', group_id=group_id))

    if not allowed_file(file.filename):
        flash('Image must be PNG, JPG, JPEG, or GIF.', 'danger')
        return redirect(url_for('admin_group_detail', group_id=group_id))

    if group['image']:
        old_path = os.path.join(UPLOAD_FOLDER, group['image'])
        if os.path.exists(old_path):
            os.remove(old_path)

    ext = file.filename.rsplit('.', 1)[1].lower()
    filename = f"group_{group_id}_{uuid.uuid4().hex[:8]}.{ext}"
    os.makedirs(UPLOAD_FOLDER, exist_ok=True)
    file.save(os.path.join(UPLOAD_FOLDER, filename))

    with db.get_cursor() as cursor:
        cursor.execute('UPDATE groups SET image = %s WHERE group_id = %s',
                       (filename, group_id))

    flash('Group image updated.', 'success')
    return redirect(url_for('admin_group_detail', group_id=group_id))


@app.route('/admin/groups/<int:group_id>/image/remove', methods=['POST'])
@role_required('Super Admin')
def admin_group_remove_image(group_id):
    """Remove the group's tile image."""
    with db.get_cursor() as cursor:
        cursor.execute('SELECT image FROM groups WHERE group_id = %s', (group_id,))
        group = cursor.fetchone()

    if not group:
        flash('Group not found.', 'danger')
        return redirect(url_for('admin_groups'))

    if group['image']:
        old_path = os.path.join(UPLOAD_FOLDER, group['image'])
        if os.path.exists(old_path):
            os.remove(old_path)
        with db.get_cursor() as cursor:
            cursor.execute('UPDATE groups SET image = NULL WHERE group_id = %s', (group_id,))
        flash('Group image removed.', 'success')
    else:
        flash('No image to remove.', 'info')

    return redirect(url_for('admin_group_detail', group_id=group_id))


@app.route('/admin/bait-types')
@role_required('Super Admin')
def manage_bait_types():
    """Redirect to generic reference data handler."""
    return redirect(url_for('manage_lookup', config_key='bait-types'))

