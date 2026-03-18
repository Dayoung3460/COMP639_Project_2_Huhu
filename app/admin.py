"""admin.py — Admin dashboard, user management, lines, traps, operator assignment, lookups."""

from flask import render_template, request, redirect, url_for, flash, session
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
    # TODO: UPDATE line SET is_retired = TRUE
    flash('Trap line retired.', 'success')
    return redirect(url_for('lines_index'))


# ── Traps ─────────────────────────────────────────────────────────────────────

@app.route('/admin/lines/<int:line_id>/traps/new', methods=['GET', 'POST'])
@role_required('Admin')
def new_trap(line_id):
    """Add a new trap to a line."""
    if request.method == 'POST':
        # TODO: validate unique code, INSERT into trap
        flash('Trap added.', 'success')
        return redirect(url_for('line_detail', line_id=line_id))
    # TODO: query line
    line = None
    return render_template('lines/new_trap.html', line=line)


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


@app.route('/admin/traps/<int:trap_id>/retire', methods=['POST'])
@role_required('Admin')
def retire_trap(trap_id):
    """Retire an individual trap (set is_retired = TRUE)."""
    # TODO: UPDATE trap SET is_retired = TRUE
    flash('Trap retired.', 'success')
    return redirect(url_for('lines_index'))


# ── Operator assignment ───────────────────────────────────────────────────────

@app.route('/admin/lines/<int:line_id>/assign', methods=['GET', 'POST'])
@role_required('Admin')
def assign_operators(line_id):
    """Assign or reassign operators to a trap line."""
    if request.method == 'POST':
        # TODO: DELETE old operator_line rows, INSERT new ones from form
        flash('Operators updated.', 'success')
        return redirect(url_for('line_detail', line_id=line_id))
    # TODO: query line, all operators, currently assigned operator ids
    line = None
    all_operators = []
    assigned_ids = []
    return render_template('admin/assign_operators.html',
                           line=line,
                           all_operators=all_operators,
                           assigned_ids=assigned_ids)


# ── Lookup data management ────────────────────────────────────────────────────

@app.route('/admin/species')
@role_required('Admin')
def manage_species():
    """View and manage the species lookup table."""
    # TODO: query species
    return render_template('admin/manage_species.html', species=[])


@app.route('/admin/statuses')
@role_required('Admin')
def manage_statuses():
    """View and manage the trap status lookup table."""
    # TODO: query trap_status
    return render_template('admin/manage_statuses.html', statuses=[])


@app.route('/admin/bait-types')
@role_required('Admin')
def manage_bait_types():
    """View and manage the bait type lookup table."""
    # TODO: query bait_type
    return render_template('admin/manage_bait_types.html', bait_types=[])
