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
from app.helpers.dbHelper import fetch_enum_values, update_user_active, fetch_lookup_data, fetch_user_info, update_user_role, insert_notification


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
                    COUNT(*) FILTER (WHERE gm.role = 'Super Admin')                              AS admins,
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
    """Create a new trap line in the currently selected group."""
    if request.method == 'POST':
        name = request.form.get('name', '').strip()

        # Validate name
        if not name:
            flash('Please provide a name', 'danger')
            return render_template('lines/new_line.html', name=name)

        with db.get_cursor() as cursor:
            # Check for existing line with the same name
            cursor.execute('SELECT line_id FROM lines WHERE name = %s', (name,))
            if cursor.fetchone():
                flash(f'A line named "{name}" already exists', 'danger')
                return render_template('lines/new_line.html', name=name)

            # Insert the new line scoped to the current group
            cursor.execute(
                "INSERT INTO lines (name, type, group_id) VALUES (%s, 'Trap', %s)",
                (name, session.get('group_id'))
            )

        flash(f'Trap line "{name}" created successfully', 'success')
        return redirect(url_for('lines_index'))
        
    return render_template('lines/new_line.html')


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

    flash('Trap line retired.', 'success')
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

    allowed_trap_types = fetch_enum_values(db, 'trap_type_enum')
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
    # get trap types for dropdown
    trap_types = fetch_enum_values(db, 'trap_type_enum')
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

        # Basic validation
        if not code or not trap_type or not latitude or not longitude:
            flash('All fields are required.', 'danger')
            trap.update({
                'code': code,
                'trap_type': trap_type,
                'latitude': latitude,
                'longitude': longitude
            })
            return render_template(
                'lines/edit_trap.html',
                trap=trap,
                trap_types=trap_types,
                line_id=line_id,
                lat_range=LINCOLN_NZ_LAT_RANGE,
                lon_range=LINCOLN_NZ_LON_RANGE,
            )

        coordinates_error = validate_lincoln_nz_coordinates(latitude, longitude)
        if coordinates_error:
            flash(coordinates_error, 'danger')
            trap.update({
                'code': code,
                'trap_type': trap_type,
                'latitude': latitude,
                'longitude': longitude
            })
            return render_template(
                'lines/edit_trap.html',
                trap=trap,
                trap_types=trap_types,
                line_id=line_id,
                lat_range=LINCOLN_NZ_LAT_RANGE,
                lon_range=LINCOLN_NZ_LON_RANGE,
            )

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
                flash(f'Trap Code "{code}" has already been taken. Please choose a different code.', 'danger')
                trap.update({
                    'code': code,
                    'trap_type': trap_type,
                    'latitude': latitude,
                    'longitude': longitude
                })
                return render_template(
                    'lines/edit_trap.html',
                    trap=trap,
                    trap_types=trap_types,
                    line_id=line_id,
                    lat_range=LINCOLN_NZ_LAT_RANGE,
                    lon_range=LINCOLN_NZ_LON_RANGE,
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

    return render_template(
        'lines/edit_trap.html',
        trap=trap,
        trap_types=trap_types,
        line_id=line_id,
        lat_range=LINCOLN_NZ_LAT_RANGE,
        lon_range=LINCOLN_NZ_LON_RANGE,
    )


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


# ── Lookup data management ────────────────────────────────────────────────────

@app.route('/admin/species', methods=['GET', 'POST'])
@role_required('Super Admin')
def manage_species():
    """View and manage the species lookup table."""
    if request.method == 'POST':
        current_item_name = request.form.get('current-item-name', '').strip()
        item_name = request.form.get('item-name', '').strip()
        modal_action = request.form.get('modal-action')

        if modal_action == 'delete':
            # check that user typed "delete" to confirm deletion
            if request.form.get('delete-confirm', '').strip().lower() != 'delete':
                flash('Please type "delete" to confirm deletion.', 'danger')
                return redirect(url_for('manage_species'))
            
            # check if this species is used in any catch records
            with db.get_cursor() as cursor:
                cursor.execute(
                    "SELECT COUNT(*) AS cnt FROM trap_catches WHERE species_caught = %s",
                    (current_item_name,))
                count = cursor.fetchone()['cnt']

            # if it is used, prevent deletion and show error message with count of records using it
            # if it is not used, proceed with deletion and show success message
            if count > 0:
                flash(f'Cannot delete "{current_item_name}" — it is used in {count} catch record(s).', 'danger')
            else:
                with db.get_cursor() as cursor:
                    cursor.execute("DELETE FROM species WHERE name = %s", (current_item_name,))
                flash(f'Species "{current_item_name}" deleted successfully.', 'success')
            return redirect(url_for('manage_species'))

        if not item_name:
            flash('Please provide a species name.', 'danger')
            return redirect(url_for('manage_species'))
        
        # Define reserved names that cannot be used for species
        reserved = ['none', 'unspecified']

        if item_name.lower() in reserved:
            flash(f'"{item_name}" is a system-reserved value and cannot be added.', 'danger')
            return redirect(url_for('manage_species'))

        with db.get_cursor() as cursor:
            # Check for existing species with the same name
            cursor.execute(
                """
                SELECT name
                FROM species
                WHERE name = %s
                """, (item_name,))
            if cursor.fetchone():
                flash(f'A species named "{item_name}" already exists.', 'danger')
                return redirect(url_for('manage_species'))

            if modal_action == 'add':
                # Insert the new species
                cursor.execute(
                    """
                    INSERT INTO species (name)
                    VALUES (%s)
                    """, (item_name,))
                flash(f'Species "{item_name}" added successfully.', 'success')
            elif modal_action == 'edit':
                # Update the new species
                cursor.execute(
                    """
                    UPDATE species
                    SET name = %s
                    WHERE name = %s
                    """, (item_name, current_item_name))
                flash(f'Species "{current_item_name}" updated to "{item_name}" successfully.', 'success')

    # get list of species for display
    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT name
            FROM species
            ORDER BY name ASC
            """
        )
        species_list = cursor.fetchall()
    
    return render_template('admin/manage_species.html', species_list=species_list)


@app.route('/admin/statuses', methods=['GET', 'POST'])
@role_required('Super Admin')
def manage_statuses():
    """View and manage the trap status lookup table."""
    if request.method == 'POST':
        current_item_name = request.form.get('current-item-name', '').strip()
        item_name = request.form.get('item-name', '').strip()
        modal_action = request.form.get('modal-action')

        if modal_action == 'delete':
            if request.form.get('delete-confirm', '').strip().lower() != 'delete':
                flash('Please type "delete" to confirm deletion.', 'danger')
                return redirect(url_for('manage_statuses'))
            with db.get_cursor() as cursor:
                cursor.execute(
                    "SELECT COUNT(*) AS cnt FROM trap_catches WHERE status = %s",
                    (current_item_name,))
                count = cursor.fetchone()['cnt']
            if count > 0:
                flash(f'Cannot delete "{current_item_name}" — it is used in {count} catch record(s).', 'danger')
            else:
                with db.get_cursor() as cursor:
                    cursor.execute("DELETE FROM trap_statuses WHERE name = %s", (current_item_name,))
                flash(f'Trap status "{current_item_name}" deleted successfully.', 'success')
            return redirect(url_for('manage_statuses'))

        if not item_name:
            flash('Please provide a trap status name.', 'danger')
            return redirect(url_for('manage_statuses'))
        
        with db.get_cursor() as cursor:
            # Check for existing status with the same name
            cursor.execute(
                """
                SELECT name
                FROM trap_statuses
                WHERE name = %s
                """, (item_name,))
            if cursor.fetchone():
                flash(f'A trap status named "{item_name}" already exists.', 'danger')
                return redirect(url_for('manage_statuses'))
            
            if modal_action == 'add':
                # Insert the new status
                cursor.execute(
                    """
                    INSERT INTO trap_statuses (name)
                    VALUES (%s)
                    """, (item_name,))
                flash(f'Trap status "{item_name}" added successfully.', 'success')
            elif modal_action == 'edit':
                # Update the new status
                cursor.execute(
                    """
                    UPDATE trap_statuses
                    SET name = %s
                    WHERE name = %s
                    """, (item_name, current_item_name))
                flash(f'Trap status "{current_item_name}" updated to "{item_name}" successfully.', 'success')

    # get list of statuses for display
    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT name
            FROM trap_statuses
            ORDER BY name ASC
            """
        )
        statuses_list = cursor.fetchall()
        
    return render_template('admin/manage_statuses.html', statuses_list=statuses_list)


# ── Group management ─────────────────────────────────────────────────────────

@app.route('/admin/groups')
@role_required('Super Admin')
def admin_groups():
    """List all groups with summary info."""
    search = request.args.get('search', '').strip()
    status_filter = request.args.get('status', '').strip()

    query = '''
        SELECT g.group_id, g.name, g.is_public, g.is_active, g.created_at,
               g.image, g.color_theme,
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
                INSERT INTO groups (name, description, is_public, image)
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
                   g.image, g.color_theme,
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


@app.route('/admin/bait-types', methods=['GET', 'POST'])
@role_required('Super Admin')
def manage_bait_types():
    """View and manage the bait type lookup table."""
    if request.method == 'POST':
        current_item_name = request.form.get('current-item-name', '').strip()
        item_name = request.form.get('item-name', '').strip()
        modal_action = request.form.get('modal-action')
        
        if modal_action == 'delete':
            if request.form.get('delete-confirm', '').strip().lower() != 'delete':
                flash('Please type "delete" to confirm deletion.', 'danger')
                return redirect(url_for('manage_bait_types'))
            with db.get_cursor() as cursor:
                cursor.execute(
                    "SELECT COUNT(*) AS cnt FROM trap_catches WHERE bait_type = %s",
                    (current_item_name,))
                count = cursor.fetchone()['cnt']
            if count > 0:
                flash(f'Cannot delete "{current_item_name}" — it is used in {count} catch record(s).', 'danger')
            else:
                with db.get_cursor() as cursor:
                    cursor.execute("DELETE FROM bait_types WHERE name = %s", (current_item_name,))
                flash(f'Bait type "{current_item_name}" deleted successfully.', 'success')
            return redirect(url_for('manage_bait_types'))

        if not item_name:
            flash('Please provide a bait type name.', 'danger')
            return redirect(url_for('manage_bait_types'))
        
        # Define reserved names that cannot be used for bait types
        reserved = ['none', 'other']

        if item_name.lower() in reserved:
            flash(f'"{item_name}" is a system-reserved value and cannot be added.', 'danger')
            return redirect(url_for('manage_bait_types'))
        
        with db.get_cursor() as cursor:
            # Check for existing bait type with the same name
            cursor.execute(
                """
                SELECT name
                FROM bait_types
                WHERE name = %s
                """, (item_name,))
            if cursor.fetchone():
                flash(f'A bait type named "{item_name}" already exists.', 'danger')
                return redirect(url_for('manage_bait_types'))
            
            if modal_action == 'add':
                # Insert the new bait type
                cursor.execute(
                    """
                    INSERT INTO bait_types (name)
                    VALUES (%s)
                    """, (item_name,))
                flash(f'Bait type "{item_name}" added successfully.', 'success')
            elif modal_action == 'edit':
                # Update the new bait type
                cursor.execute(
                    """
                    UPDATE bait_types
                    SET name = %s
                    WHERE name = %s
                    """, (item_name, current_item_name))
                flash(f'Bait type "{current_item_name}" updated to "{item_name}" successfully.', 'success')

    # get list of bait types for display
    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT name
            FROM bait_types
            ORDER BY name ASC
            """
        )
        bait_types = cursor.fetchall()

    return render_template('admin/manage_bait_types.html', bait_types=bait_types)

