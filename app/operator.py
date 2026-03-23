"""operator.py — Operator dashboard, add/edit catch records, observations."""

from flask import render_template, request, redirect, url_for, flash, session
from app import app, db
from app.utils import role_required
from app.helpers.trapCatchHelper import validate_all_catch_record_fields
from app.helpers.dbHelper import fetch_operator_lines, insert_catch_record, fetch_lookup_data


@app.route('/operator/dashboard')
@role_required('Operator', 'Admin')
def operator_dashboard():
    """Operator dashboard — assigned lines and recent records."""
    # TODO: query lines assigned to session['user_id'] via operator_line
    # TODO: query recent catch records by this operator
    assigned_lines = []
    return render_template('operator/dashboard.html', assigned_lines=assigned_lines)


@app.route('/operator/add-catch', methods=['GET', 'POST'])
@role_required('Operator')
def add_catch():
    """Add a new trap catch record for an assigned line."""
    if request.method == 'POST':
        pass_check, errors, lookup = validate_all_catch_record_fields(request.form, db, session['user_id'])
        
        if not pass_check:
            lines = fetch_operator_lines(db, session['user_id'])
            return render_template('operator/add_catch.html', errors=errors, data=request.form, lines=lines, lookup=lookup)
        
        insert_catch_record(db, request.form, session['user_id'])
        flash('Catch record added successfully.', 'success')
        return redirect(url_for('operator_dashboard'))

    else:
        lookup = fetch_lookup_data(db)
        lines = fetch_operator_lines(db, session['user_id'])
        
        # Capture selected line from URL param, validate it belongs to operator
        selected_line_id = request.args.get('line_id', '')
        valid_line_ids = [str(line['line_id']) for line in lines]
        if selected_line_id not in valid_line_ids:
            selected_line_id = ''
        
        return render_template('operator/add_catch.html', lines=lines, data={'line_id': selected_line_id}, lookup=lookup)


@app.route('/operator/edit-catch/<int:catch_id>', methods=['GET', 'POST'])
@role_required('Operator', 'Admin')
def edit_catch(catch_id):
    """Edit an existing catch record (own records only)."""
    if request.method == 'POST':
        # TODO: verify recorded_by == session['user_id']
        # TODO: validate and UPDATE trap_catch
        flash('Catch record updated successfully.', 'success')
        return redirect(url_for('my_records'))

    # TODO: query catch record by catch_id
    # TODO: verify ownership
    record = None
    return render_template('operator/edit_catch.html', record=record)


@app.route('/operator/my-records')
@role_required('Operator')
def my_records():
    """View all catch records created by the logged-in operator."""
    from app.general import get_catch_records
    records, filters, filter_data = get_catch_records(recorded_by_id=session.get('user_id'))
    return render_template(
        'observer/catch_records.html', 
        records=records, 
        selected_filters=filters, 
        filter_data=filter_data,
        is_my_records=True
    )


@app.route('/operator/add-observation', methods=['GET', 'POST'])
@role_required('Operator')
def add_observation():
    """Record an incidental observation."""
    if request.method == 'POST':
        # TODO: INSERT into observation
        flash('Observation recorded successfully.', 'success')
        return redirect(url_for('operator_dashboard'))

    return render_template('operator/add_observation.html')
