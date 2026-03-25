"""admin.py — Admin dashboard, user management, lines, traps, operator assignment, lookups."""

from flask import render_template, request, redirect, url_for, flash, session
import os
from app import app, db
from app.utils import role_required
from app.helpers.dbHelper import fetch_enum_values


# ── Dashboard ─────────────────────────────────────────────────────────────────

@app.route('/admin/dashboard')
@role_required('Admin')
def admin_dashboard():
    """Admin dashboard — system-wide statistics and quick actions."""
    # TODO: query stats (total lines, traps, users, captures)
    return render_template('admin/dashboard.html')


# ── User management ───────────────────────────────────────────────────────────

@app.route('/admin/users')
@role_required('Admin')
def admin_users():
    """List all registered users with role and account status."""
    # TODO: query all users with role name and is_active
    users = []
    return render_template('admin/users.html', users=users)


@app.route('/admin/users/<int:user_id>')
@role_required('Admin')
def admin_user_detail(user_id):
    """View detailed profile for a single user."""
    # TODO: query user, assigned lines, catch record history
    user = None
    return render_template('admin/user_detail.html', user=user)


@app.route('/admin/users/<int:user_id>/toggle-active', methods=['POST'])
@role_required('Admin')
def toggle_active(user_id):
    """Activate or deactivate a user account."""
    # TODO: UPDATE "user" SET is_active = NOT is_active WHERE user_id = %s
    flash('User account status updated.', 'success')
    return redirect(url_for('admin_users'))


@app.route('/admin/users/<int:user_id>/change-role', methods=['POST'])
@role_required('Admin')
def change_role(user_id):
    """Change a user's role. Admin cannot change their own role."""
    # TODO: get new_role from form
    # TODO: prevent changing own role
    # TODO: UPDATE role_id
    flash('User role updated.', 'success')
    return redirect(url_for('admin_user_detail', user_id=user_id))


# ── Lines ─────────────────────────────────────────────────────────────────────

@app.route('/admin/lines/new', methods=['GET', 'POST'])
@role_required('Admin')
def new_line():
    """Create a new trap line."""
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

            # Insert the new line
            cursor.execute("INSERT INTO lines (name, type) VALUES (%s, 'Trap')", (name,))

        flash(f'Trap line "{name}" created successfully', 'success')
        return redirect(url_for('lines_index'))
        
    return render_template('lines/new_line.html')


@app.route('/admin/lines/<int:line_id>/edit', methods=['GET', 'POST'])
@role_required('Admin')
def edit_line(line_id):
    """Edit an existing trap line."""
    line = None

    if request.method == 'POST':
        
        name = request.form.get('line_name')
        type = request.form.get('line_type')

        # Basic validation
        if not name or not type:
            flash('Line Name and Line Type are required.', 'danger')
            return redirect(url_for('edit_line', line_id=line_id))
        
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
                SET name = %s, type = %s
                WHERE line_id = %s
                """,
                (name, type, line_id)
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
@role_required('Admin')
def retire_line(line_id):
    """Retire a trap line (set is_retired = TRUE)."""
    
    has_active_traps = request.args.get('active_traps') == '1'

    with db.get_cursor() as cursor:
        cursor.execute(
            """
            UPDATE lines
            SET is_retired = TRUE
            WHERE line_id = %s
            """,
            (line_id,)
        )

        if has_active_traps:
            cursor.execute(
                """
                UPDATE traps
                SET is_retired = TRUE
                WHERE line_id = %s AND is_retired = FALSE
                """,
                (line_id,)
            )

    flash('Trap line retired.', 'success')
    return redirect(url_for('lines_index'))


# ── Traps ─────────────────────────────────────────────────────────────────────

@app.route('/admin/lines/<int:line_id>/new_trap', methods=['POST'])
@role_required('Admin')
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
                latitude=latitude,
                longitude=longitude,
                add_trap=1,
                error='Invalid trap type selected'
            )
        )

    try:
        float(latitude)
        float(longitude)
    except ValueError:
        return redirect(url_for('line_detail', line_id=line_id, code=code, trap_type=trap_type, add_trap=1, error='Invalid coordinates. Please ensure Latitude and Longitude are valid numbers.'))

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
@role_required('Admin')
def edit_trap(line_id, trap_id):
    """Edit an existing trap."""
    # get trap types for dropdown
    trap_types = fetch_enum_values(db, 'trap_type_enum')
    trap = None

    if request.method == 'POST':
        code = request.form.get('trap_code')
        trap_type = request.form.get('trap_type')
        latitude = request.form.get('trap_latitude')
        longitude = request.form.get('trap_longitude')

        # Basic validation
        if not code or not trap_type or not latitude or not longitude:
            flash('All fields are required.', 'danger')
            return redirect(url_for('edit_trap', line_id=line_id, trap_id=trap_id))

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
                return redirect(url_for('edit_trap', line_id=line_id, trap_id=trap_id))
            
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

    # Query trap details for pre-filling the form
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

    return render_template('lines/edit_trap.html', trap=trap, trap_types=trap_types, line_id=line_id)


@app.route('/admin/traps/<int:line_id>/retire', methods=['POST'])
@role_required('Admin')
def retire_trap(line_id):
    """Retire an individual trap (set is_retired = TRUE)."""
    trap_id = request.form.get('trap_id')

    if request.method == 'POST':
        with db.get_cursor() as cursor:
            cursor.execute(
                """
                UPDATE traps
                SET is_retired = TRUE
                WHERE trap_id = %s
                """,
                (trap_id,)
            )

    flash('Trap retired.', 'success')
    return redirect(url_for('line_detail', line_id=line_id))


# ── Operator assignment ───────────────────────────────────────────────────────

@app.route('/admin/lines/<int:line_id>/assign', methods=['GET', 'POST'])
@role_required('Admin')
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
            SELECT user_id, username, first_name, last_name
            FROM users
            WHERE role = 'Operator'
            ORDER BY last_name ASC, first_name ASC
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
@role_required('Admin')
def manage_species():
    """View and manage the species lookup table."""
    if request.method == 'POST':
        current_species_name = request.form.get('current-species-name', '').strip()
        species_name = request.form.get('species-name', '').strip()
        modal_action = request.form.get('modal-action')

        if not species_name:
            flash('Please provide a species name.', 'danger')
            return redirect(url_for('manage_species'))
        
        with db.get_cursor() as cursor:
            # Check for existing species with the same name
            cursor.execute(
                """
                SELECT name
                FROM species
                WHERE name = %s
                """, (species_name,))
            if cursor.fetchone():
                flash(f'A species named "{species_name}" already exists.', 'danger')
                return redirect(url_for('manage_species'))
            
            if modal_action == 'add':
                # Insert the new species
                cursor.execute(
                    """
                    INSERT INTO species (name)
                    VALUES (%s)
                    """, (species_name,))
                flash(f'Species "{species_name}" added successfully.', 'success')
            elif modal_action == 'edit':
                # Update the new species
                cursor.execute(
                    """
                    UPDATE species
                    SET name = %s
                    WHERE name = %s
                    """, (species_name, current_species_name))
                flash(f'Species "{current_species_name}" updated to "{species_name}" successfully.', 'success')

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
@role_required('Admin')
def manage_statuses():
    """View and manage the trap status lookup table."""
    if request.method == 'POST':
        current_status_name = request.form.get('current-status-name', '').strip()
        status_name = request.form.get('status-name', '').strip()
        modal_action = request.form.get('modal-action')

        if not status_name:
            flash('Please provide a trap status name.', 'danger')
            return redirect(url_for('manage_statuses'))
        
        with db.get_cursor() as cursor:
            # Check for existing status with the same name
            cursor.execute(
                """
                SELECT name
                FROM trap_statuses
                WHERE name = %s
                """, (status_name,))
            if cursor.fetchone():
                flash(f'A trap status named "{status_name}" already exists.', 'danger')
                return redirect(url_for('manage_statuses'))
            
            if modal_action == 'add':
                # Insert the new status
                print(f"Adding new status: {status_name}")
                cursor.execute(
                    """
                    INSERT INTO trap_statuses (name)
                    VALUES (%s)
                    """, (status_name,))
                flash(f'Trap status "{status_name}" added successfully.', 'success')
            elif modal_action == 'edit':
                # Update the new status
                cursor.execute(
                    """
                    UPDATE trap_statuses
                    SET name = %s
                    WHERE name = %s
                    """, (status_name, current_status_name))
                flash(f'Trap status "{current_status_name}" updated to "{status_name}" successfully.', 'success')

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


@app.route('/admin/bait-types', methods=['GET', 'POST'])
@role_required('Admin')
def manage_bait_types():
    """View and manage the bait type lookup table."""
    if request.method == 'POST':
        current_bait_type_name = request.form.get('current-bait-type-name', '').strip()
        bait_type_name = request.form.get('bait-type-name', '').strip()
        modal_action = request.form.get('modal-action')
        
        if not bait_type_name:
            flash('Please provide a bait type name.', 'danger')
            return redirect(url_for('manage_bait_types'))
        
        with db.get_cursor() as cursor:
            # Check for existing bait type with the same name
            cursor.execute(
                """
                SELECT name
                FROM bait_types
                WHERE name = %s
                """, (bait_type_name,))
            if cursor.fetchone():
                flash(f'A bait type named "{bait_type_name}" already exists.', 'danger')
                return redirect(url_for('manage_bait_types'))
            
            if modal_action == 'add':
                # Insert the new bait type
                cursor.execute(
                    """
                    INSERT INTO bait_types (name)
                    VALUES (%s)
                    """, (bait_type_name,))
                flash(f'Bait type "{bait_type_name}" added successfully.', 'success')
            elif modal_action == 'edit':
                # Update the new bait type
                cursor.execute(
                    """
                    UPDATE bait_types
                    SET name = %s
                    WHERE name = %s
                    """, (bait_type_name, current_bait_type_name))
                flash(f'Bait type "{current_bait_type_name}" updated to "{bait_type_name}" successfully.', 'success')

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
