"""operator.py — Operator dashboard, add/edit catch records, observations."""

from flask import render_template, request, redirect, url_for, flash, session
from app import app, db
import os
from app.utils import role_required, LINE_COLOURS, LINCOLN_NZ_LAT_RANGE, LINCOLN_NZ_LON_RANGE, LINCOLN_NZ_CENTER
from app.helpers.trapCatchHelper import validate_all_catch_record_fields, validate_all_observation_fields
from app.helpers.dbHelper import fetch_operator_lines, insert_catch_record, fetch_lookup_data, insert_observation, validate_lookup_table_values, update_catch_record

linz_api_key = os.getenv('LINZ_API_KEY', '')


@app.route('/operator/dashboard')
@role_required('Operator', 'Admin')
def operator_dashboard():
    """Operator dashboard — assigned lines, stats, and recent catches."""
    user_id = session.get('user_id')
    assigned_lines = []
    stats = {
        'total_catches': 0,
        'catches_month': 0,
        'total_records': 0,
        'lines_count':   0,
    }
    recent_records = []
 
    try:
        with db.get_cursor() as cursor:
 
            # Assigned lines with trap count
            cursor.execute('''
                SELECT l.line_id, l.name, l.type,
                       COUNT(t.trap_id) FILTER (WHERE t.is_retired = FALSE) AS trap_count
                FROM operator_lines ol
                JOIN lines l ON ol.line_id = l.line_id
                LEFT JOIN traps t ON t.line_id = l.line_id
                WHERE ol.operator_id = %s AND l.is_retired = FALSE
                GROUP BY l.line_id, l.name, l.type
                ORDER BY l.name
            ''', (user_id,))
            assigned_lines = cursor.fetchall()
            stats['lines_count'] = len(assigned_lines)
 
            # Total catches by this operator
            cursor.execute('''
                SELECT COUNT(*) AS cnt FROM trap_catches
                WHERE recorded_by_id = %s AND species_caught != 'None'
            ''', (user_id,))
            stats['total_catches'] = cursor.fetchone()['cnt']
 
            # Catches this month
            cursor.execute('''
                SELECT COUNT(*) AS cnt FROM trap_catches
                WHERE recorded_by_id = %s
                AND species_caught != 'None'
                AND date >= NOW() - INTERVAL '30 days'
            ''', (user_id,))
            stats['catches_month'] = cursor.fetchone()['cnt']
 
            # Total records this month
            cursor.execute('''
                SELECT COUNT(*) AS cnt FROM trap_catches
                WHERE recorded_by_id = %s
                AND date >= NOW() - INTERVAL '30 days'
            ''', (user_id,))
            stats['total_records'] = cursor.fetchone()['cnt']
 
            # Recent records (last 5)
            cursor.execute('''
                SELECT tc.catch_id, tc.date, tc.species_caught,
                       tc.status, tc.strikes,
                       t.code AS trap_code, l.name AS line_name
                FROM trap_catches tc
                JOIN traps t ON tc.trap_id = t.trap_id
                JOIN lines l ON t.line_id = l.line_id
                WHERE tc.recorded_by_id = %s
                ORDER BY tc.date DESC
                LIMIT 5
            ''', (user_id,))
            recent_records = cursor.fetchall()
 
    except Exception as e:
        app.logger.error(f'Operator dashboard error: {e}')
 
    return render_template('operator/dashboard.html',
                           assigned_lines=assigned_lines,
                           stats=stats,
                           recent_records=recent_records)


@app.route('/operator/add-catch', methods=['GET', 'POST'])
@role_required('Operator')
def add_catch():
    """Add a new trap catch record for an assigned line."""
    if request.method == 'POST':
        pass_check, errors, lookup = validate_all_catch_record_fields(request.form, db, session['user_id'])

        # Additional check for lookup tables, in case the data inconsistency of database values
        lookup_valid_msg = validate_lookup_table_values(db, request.form)

        if lookup_valid_msg:
            flash(lookup_valid_msg, 'error')
            lines = fetch_operator_lines(db, session['user_id'])
            return render_template('operator/add_catch.html', data=request.form, lines=lines, lookup=lookup)

        if not pass_check:
            flash('Please fix the errors below before submitting.', 'error')
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
        # Security check: ensure the recorded_by_id in form matches session user_id to prevent tampering
        if str(request.form.get('recorded_by_id')) != str(session['user_id']):
            flash("You can only edit your own catch records.", 'error')
            return redirect(url_for('my_records'))
        
        pass_check, errors, lookup = validate_all_catch_record_fields(request.form, db, session['user_id'])

        # Additional check for lookup tables, in case the data inconsistency of database values
        lookup_valid_msg = validate_lookup_table_values(db, request.form)

        if lookup_valid_msg:
            flash(lookup_valid_msg, 'error')
            lines = fetch_operator_lines(db, session['user_id'])
            return render_template('operator/edit_catch.html',catch_id=catch_id, errors=errors, data=request.form, lines=lines, lookup=lookup)

        if not pass_check:
            flash('Please fix the errors below before submitting.', 'error')
            lines = fetch_operator_lines(db, session['user_id'])
            return render_template('operator/edit_catch.html',catch_id=catch_id, errors=errors, data=request.form, lines=lines, lookup=lookup)

        # Update the catch record in the database
        update_catch_record(db, data={**request.form, 'catch_id': catch_id}, user_id=session['user_id'])
        flash('Catch record updated successfully.', 'success')
        return redirect(url_for('my_records'))


    lookup = fetch_lookup_data(db)
    lines = fetch_operator_lines(db, session['user_id'])
    record = None

    # Fetch the catch record and its associated line_id for pre-filling the form
    with db.get_cursor() as cursor:
        cursor.execute("""
            SELECT * FROM trap_catches WHERE catch_id = %s
        """, (catch_id,))
        record = cursor.fetchone()

        cursor.execute("""
            SELECT line_id FROM traps WHERE trap_id = %s
        """, (record['trap_id'],))
        line_id = cursor.fetchone()['line_id']

    return render_template(
        'operator/edit_catch.html',
        record=record,
        lines=lines,
        lookup=lookup,
        data={ # Pre-fill the form fields
            'line_id': str(line_id),
            'trap_id': str(record['trap_id']),
            'date': record['date'],
            'species_caught': record['species_caught'],
            'strikes': str(record['strikes']),
            'sex': record['sex'] or '',
            'maturity': record['maturity'] or '',
            'status': record['status'],
            'trap_condition': record['trap_condition'],
            'rebaited': record['rebaited'],
            'bait_type': record['bait_type'],
            'bait_details': record['bait_details'] or '',
            'notes': record['notes'] or '',
            'recorded_by_id': record['recorded_by_id']
        }
    )


@app.route('/operator/my-records')
@role_required('Operator')
def my_records():
    """View all catch records created by the logged-in operator."""
    from app.general import get_catch_records
    records, filters, filter_data = get_catch_records(recorded_by_id=session.get('user_id'))

    # Get trap_id to is_retired mapping for all traps to determine if edit action should be shown
    with db.get_cursor() as cursor:
        cursor.execute("SELECT trap_id, is_retired FROM traps")
        traps = cursor.fetchall()

    # Get line_ids that belong to this operator to determine if they should be shown in line filter dropdown
    user_id = session.get('user_id')
    with db.get_cursor() as cursor:
        cursor.execute("SELECT line_id FROM operator_lines WHERE operator_id = %s", (user_id,))
        line_ids_for_operator = [row['line_id'] for row in cursor.fetchall()]

    trap_map = {t["trap_id"]: t for t in traps}

    return render_template(
        'observer/catch_records.html', 
        records=records, 
        selected_filters=filters, 
        filter_data=filter_data,
        is_my_records=True,
        trap_map=trap_map,
        line_ids_for_operator=line_ids_for_operator
    )


@app.route('/operator/add-observation', methods=['GET', 'POST'])
@role_required('Operator')
def add_observation():
    """Record an incidental observation."""
    if request.method == 'POST':
        pass_check, errors, lookup = validate_all_observation_fields(request.form, db, session['user_id'])
        
        if not pass_check:
            lines = fetch_operator_lines(db, session['user_id'])
            return render_template('operator/add_observation.html', errors=errors, data=request.form, lines=lines, lookup=lookup, linz_api_key=linz_api_key,
                                   lat_range=LINCOLN_NZ_LAT_RANGE, lon_range=LINCOLN_NZ_LON_RANGE, map_center=LINCOLN_NZ_CENTER)
        
        insert_observation(db, request.form, session['user_id'])
        flash('Observation recorded successfully.', 'success')
        return redirect(url_for('operator_dashboard'))

    else:
        lines = fetch_operator_lines(db, session['user_id'])
        lookup = fetch_lookup_data(db)
        
        # Capture selected line from URL param, validate it belongs to operator
        selected_line_id = request.args.get('line_id', '')
        valid_line_ids = [str(line['line_id']) for line in lines]
        if selected_line_id not in valid_line_ids:
            selected_line_id = ''
        
        return render_template('operator/add_observation.html', lines=lines, data={'line_id': selected_line_id}, lookup=lookup, linz_api_key=linz_api_key,
                               lat_range=LINCOLN_NZ_LAT_RANGE, lon_range=LINCOLN_NZ_LON_RANGE, map_center=LINCOLN_NZ_CENTER)
