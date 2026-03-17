"""operator.py — Operator dashboard, add/edit catch records, observations."""

from flask import render_template, request, redirect, url_for, flash, session
from app import app, db
from app.utils import role_required


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
        # TODO: get all form fields
        # TODO: verify selected line is in operator's assigned lines
        # TODO: validate all required fields (strikes >= 0, species/bait None rules)
        # TODO: INSERT into trap_catch
        flash('Catch record added successfully.', 'success')
        return redirect(url_for('operator_dashboard'))

    # TODO: query assigned lines, species, statuses, bait_types, conditions
    return render_template('operator/add_catch.html')


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
@role_required('Operator', 'Admin')
def my_records():
    """View all catch records created by the logged-in operator."""
    # TODO: query WHERE recorded_by = session['user_id']
    records = []
    return render_template('operator/my_records.html', records=records)


@app.route('/operator/add-observation', methods=['GET', 'POST'])
@role_required('Operator')
def add_observation():
    """Record an incidental observation."""
    if request.method == 'POST':
        # TODO: INSERT into observation
        flash('Observation recorded successfully.', 'success')
        return redirect(url_for('operator_dashboard'))

    return render_template('operator/add_observation.html')
