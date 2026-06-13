"""operator.py — Operator dashboard, add/edit catch records, observations."""

import logging
import os

from flask import render_template, request, redirect, url_for, flash, session
from app import app, db
from app.utils import (
    role_required, LINE_COLOURS, LINCOLN_NZ_LAT_RANGE, LINCOLN_NZ_LON_RANGE,
    LINCOLN_NZ_CENTER, is_super_admin_mode,
)
from app.helpers.trapCatchHelper import validate_all_catch_record_fields, validate_all_observation_fields
from app.helpers.dbHelper import (
    fetch_all_lines, fetch_operator_lines, insert_catch_record, fetch_lookup_data,
    insert_observation, validate_lookup_table_values, update_catch_record,
    fetch_operator_bait_lines, fetch_operator_bait_station_ids,
    insert_bait_station_record, update_bait_station_record, fetch_active_lookup,
)

logger = logging.getLogger(__name__)

linz_api_key = os.getenv('LINZ_API_KEY', '')


@app.route('/operator/dashboard')
@role_required('Operator')
def operator_dashboard():
    """Operator dashboard — assigned lines, stats, and recent catches.

    Scoped to the operator's active group so that an operator who
    works in multiple groups doesn't see lines, traps, or catches
    from the inactive group bleeding into the dashboard.
    """
    user_id = session.get('user_id')
    group_id = session.get('group_id')
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

            # Assigned lines with trap count — active group only
            cursor.execute('''
                SELECT l.line_id, l.name, l.type,
                       COUNT(t.trap_id) FILTER (WHERE t.is_retired = FALSE) AS trap_count
                FROM operator_lines ol
                JOIN lines l ON ol.line_id = l.line_id
                LEFT JOIN traps t ON t.line_id = l.line_id
                WHERE ol.operator_id = %s AND l.is_retired = FALSE AND l.group_id = %s
                GROUP BY l.line_id, l.name, l.type
                ORDER BY l.name
            ''', (user_id, group_id))
            assigned_lines = cursor.fetchall()
            stats['lines_count'] = len(assigned_lines)

            # Total catches by this operator (within active group)
            cursor.execute('''
                SELECT COUNT(*) AS cnt
                FROM trap_catches tc
                JOIN traps t ON t.trap_id = tc.trap_id
                JOIN lines l ON l.line_id = t.line_id
                WHERE tc.recorded_by_id = %s AND tc.species_caught != 'None'
                  AND l.group_id = %s
            ''', (user_id, group_id))
            stats['total_catches'] = cursor.fetchone()['cnt']

            # Catches this month (active group)
            cursor.execute('''
                SELECT COUNT(*) AS cnt
                FROM trap_catches tc
                JOIN traps t ON t.trap_id = tc.trap_id
                JOIN lines l ON l.line_id = t.line_id
                WHERE tc.recorded_by_id = %s
                  AND tc.species_caught != 'None'
                  AND tc.date >= NOW() - INTERVAL '30 days'
                  AND l.group_id = %s
            ''', (user_id, group_id))
            stats['catches_month'] = cursor.fetchone()['cnt']

            # Total records this month (active group)
            cursor.execute('''
                SELECT COUNT(*) AS cnt
                FROM trap_catches tc
                JOIN traps t ON t.trap_id = tc.trap_id
                JOIN lines l ON l.line_id = t.line_id
                WHERE tc.recorded_by_id = %s
                  AND tc.date >= NOW() - INTERVAL '30 days'
                  AND l.group_id = %s
            ''', (user_id, group_id))
            stats['total_records'] = cursor.fetchone()['cnt']

            # Recent records (last 5) — active group
            cursor.execute('''
                SELECT tc.catch_id, tc.date, tc.species_caught,
                       tc.status, tc.strikes,
                       t.code AS trap_code, l.name AS line_name
                FROM trap_catches tc
                JOIN traps t ON tc.trap_id = t.trap_id
                JOIN lines l ON t.line_id = l.line_id
                WHERE tc.recorded_by_id = %s AND l.group_id = %s
                ORDER BY tc.date DESC
                LIMIT 5
            ''', (user_id, group_id))
            recent_records = cursor.fetchall()
 
    except Exception as e:
        logger.error('Operator dashboard error: %s', e)
 
    return render_template('operator/dashboard.html',
                           assigned_lines=assigned_lines,
                           stats=stats,
                           recent_records=recent_records)


@app.route('/operator/add-catch', methods=['GET', 'POST'])
@role_required('Operator')
def add_catch():
    """Add a new trap catch record for an assigned line."""
    if request.method == 'POST':
        pass_check, errors, lookup = validate_all_catch_record_fields(request.form, db, session['user_id'], group_id=session.get('group_id'))

        # Additional check for lookup tables, in case the data inconsistency of database values
        lookup_valid_msg = validate_lookup_table_values(db, request.form)

        if lookup_valid_msg:
            flash(lookup_valid_msg, 'error')
            lines = fetch_operator_lines(db, session['user_id'], group_id=session.get('group_id'))
            return render_template('operator/add_catch.html', data=request.form, lines=lines, lookup=lookup)

        if not pass_check:
            flash('Please fix the errors below before submitting.', 'error')
            lines = fetch_operator_lines(db, session['user_id'], group_id=session.get('group_id'))
            return render_template('operator/add_catch.html', errors=errors, data=request.form, lines=lines, lookup=lookup)
        
        insert_catch_record(db, request.form, session['user_id'])
        flash('Catch record added successfully.', 'success')
        return redirect(url_for('operator_dashboard'))

    else:
        lookup = fetch_lookup_data(db)
        lines = fetch_operator_lines(db, session['user_id'], group_id=session.get('group_id'))
        
        # Capture selected line from URL param, validate it belongs to operator
        selected_line_id = request.args.get('line_id', '')
        valid_line_ids = [str(line['line_id']) for line in lines]
        if selected_line_id not in valid_line_ids:
            selected_line_id = ''

        # Capture selected trap from URL param, validate it belongs to operator
        selected_trap_id = request.args.get('trap_id', '')
        valid_trap_ids = [str(trap['trap_id']) for ln in lines for trap in (ln.get('traps') or [])]
        if selected_trap_id not in valid_trap_ids:
            selected_trap_id = ''

        return render_template('operator/add_catch.html', lines=lines, data={'line_id': selected_line_id, 'trap_id': selected_trap_id}, lookup=lookup)


@app.route('/operator/edit-catch/<int:catch_id>', methods=['GET', 'POST'])
@role_required('Operator', 'Super Admin', 'Group Coordinator')
def edit_catch(catch_id):
    """Edit an existing catch record (own records only for Operators)."""
    # Fetch record + owning group/line so we can authorize before doing
    # anything else. Trusting the form's recorded_by_id is NOT safe — a
    # malicious operator could POST their own user_id and edit someone
    # else's record. The DB row is the only source of truth here.
    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT tc.catch_id, tc.recorded_by_id, tc.trap_id,
                   t.line_id, l.group_id
            FROM trap_catches tc
            JOIN traps t ON t.trap_id = tc.trap_id
            JOIN lines l ON l.line_id = t.line_id
            WHERE tc.catch_id = %s
            """,
            (catch_id,)
        )
        record = cursor.fetchone()

    if not record:
        flash('Catch record not found.', 'danger')
        return redirect(url_for('catch_records'))

    role = session.get('group_role')
    user_id = session['user_id']
    super_admin = is_super_admin_mode()

    # Cross-group gate. Coordinators must be in the catch's group;
    # Operators must be in the catch's group AND have recorded it.
    if not super_admin and record['group_id'] != session.get('group_id'):
        flash('Catch record not found in your group.', 'danger')
        return redirect(url_for('catch_records'))

    if role == 'Operator' and record['recorded_by_id'] != user_id:
        flash('You can only edit your own catch records.', 'danger')
        return redirect(url_for('my_records'))

    if request.method == 'POST':
        pass_check, errors, lookup = validate_all_catch_record_fields(request.form, db, session['user_id'], role=session.get('group_role'), group_id=session.get('group_id'))

        # Additional check for lookup tables, in case the data inconsistency of database values
        lookup_valid_msg = validate_lookup_table_values(db, request.form)

        if lookup_valid_msg:
            flash(lookup_valid_msg, 'error')
            lines = fetch_all_lines(db) if session.get('group_role') in ('Super Admin', 'Group Coordinator') else fetch_operator_lines(db, session['user_id'], group_id=session.get('group_id'))
            return render_template('operator/edit_catch.html', record=record, catch_id=catch_id, errors=errors, data=request.form, lines=lines, lookup=lookup)

        if not pass_check:
            flash('Please fix the errors below before submitting.', 'error')
            lines = fetch_all_lines(db) if session.get('group_role') in ('Super Admin', 'Group Coordinator') else fetch_operator_lines(db, session['user_id'], group_id=session.get('group_id'))
            return render_template('operator/edit_catch.html', record=record, catch_id=catch_id, errors=errors, data=request.form, lines=lines, lookup=lookup)

        # Update the catch record in the database
        update_catch_record(db, data={**request.form, 'catch_id': catch_id}, user_id=record['recorded_by_id'])
        flash('Catch record updated successfully.', 'success')
        return redirect(url_for('my_records') if session.get('group_role') == 'Operator' else url_for('catch_records'))


    lines = fetch_operator_lines(db, session['user_id'], group_id=session.get('group_id'))

    if session.get('group_role') in ('Super Admin', 'Group Coordinator'):
        lines = fetch_all_lines(db)

    with db.get_cursor() as cursor:
        cursor.execute("SELECT * FROM trap_catches WHERE catch_id = %s", (catch_id,))
        record = cursor.fetchone()
        cursor.execute("SELECT line_id FROM traps WHERE trap_id = %s", (record['trap_id'],))
        line_id = cursor.fetchone()['line_id']

    lookup = fetch_lookup_data(db, include_values={
        'species_caught': record['species_caught'],
        'status': record['status'],
        'bait_type': record['bait_type'],
    })

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
    """View all catch records created by the logged-in operator.

    Scoped to the operator's active group — multi-group operators
    see only the current group's records here, matching the rest
    of the operator surface.
    """
    from app.general import get_catch_records
    records, filters, filter_data = get_catch_records(recorded_by_id=session.get('user_id'))

    user_id = session.get('user_id')
    group_id = session.get('group_id')

    # Trap state lookup — scoped to the active group's traps.
    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT t.trap_id, t.is_retired
            FROM traps t
            JOIN lines l ON l.line_id = t.line_id
            WHERE l.group_id = %s
            """,
            (group_id,)
        )
        traps = cursor.fetchall()

    # Lines assigned to this operator WITHIN their active group.
    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT ol.line_id
            FROM operator_lines ol
            JOIN lines l ON l.line_id = ol.line_id
            WHERE ol.operator_id = %s AND l.group_id = %s
            """,
            (user_id, group_id)
        )
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
        pass_check, errors, lookup = validate_all_observation_fields(request.form, db, session['user_id'], group_id=session.get('group_id'))
        
        if not pass_check:
            lines = fetch_operator_lines(db, session['user_id'], group_id=session.get('group_id'))
            return render_template('operator/add_observation.html', errors=errors, data=request.form, lines=lines, lookup=lookup, linz_api_key=linz_api_key,
                                   lat_range=LINCOLN_NZ_LAT_RANGE, lon_range=LINCOLN_NZ_LON_RANGE, map_center=LINCOLN_NZ_CENTER)
        
        insert_observation(db, request.form, session['user_id'])
        flash('Observation recorded successfully.', 'success')
        return redirect(url_for('operator_dashboard'))

    else:
        lines = fetch_operator_lines(db, session['user_id'], group_id=session.get('group_id'))
        lookup = fetch_lookup_data(db)
        
        # Capture selected line from URL param, validate it belongs to operator
        selected_line_id = request.args.get('line_id', '')
        valid_line_ids = [str(line['line_id']) for line in lines]
        if selected_line_id not in valid_line_ids:
            selected_line_id = ''
        
        return render_template('operator/add_observation.html', lines=lines, data={'line_id': selected_line_id}, lookup=lookup, linz_api_key=linz_api_key,
                               lat_range=LINCOLN_NZ_LAT_RANGE, lon_range=LINCOLN_NZ_LON_RANGE, map_center=LINCOLN_NZ_CENTER)


def _validate_bait_record(data):
    """Validate bait station record fields. Returns list of error strings."""
    errors = []
    if not data.get('station_id'):
        errors.append('Bait station is required.')
    if not data.get('date'):
        errors.append('Date is required.')
    if not data.get('active_ingredient'):
        errors.append('Active ingredient is required.')
    if not data.get('formulation'):
        errors.append('Formulation is required.')
    for field, label in [('concentration', 'Concentration'), ('bait_remaining', 'Bait remaining')]:
        val = data.get(field, '')
        if not val and val != 0:
            errors.append(f'{label} is required.')
        else:
            try:
                if float(val) < 0:
                    errors.append(f'{label} must be 0 or greater.')
            except (TypeError, ValueError):
                errors.append(f'{label} must be a number.')
    for field, label in [('bait_removed', 'Bait removed'), ('bait_added', 'Bait added')]:
        val = data.get(field, '')
        if val:
            try:
                if float(val) < 0:
                    errors.append(f'{label} must be 0 or greater.')
            except (TypeError, ValueError):
                errors.append(f'{label} must be a number.')
    return errors


@app.route('/operator/add-bait-record', methods=['GET', 'POST'])
@role_required('Operator')
def add_bait_record():
    """Record a bait station check."""
    user_id = session['user_id']
    group_id = session['group_id']
    bait_lines = fetch_operator_bait_lines(db, user_id, group_id)
    valid_station_ids = fetch_operator_bait_station_ids(db, user_id, group_id)

    species_list = fetch_active_lookup(db, 'species')
    active_ingredients = fetch_active_lookup(db, 'active_ingredients')
    formulations = fetch_active_lookup(db, 'bait_formulations')

    if request.method == 'POST':
        errors = _validate_bait_record(request.form)

        station_id = request.form.get('station_id', type=int)
        if station_id not in valid_station_ids:
            errors.append('You are not assigned to that bait station.')

        if errors:
            for e in errors:
                flash(e, 'danger')
            return render_template('operator/add_bait_record.html',
                                   bait_lines=bait_lines, data=request.form,
                                   show_back=bool(request.form.get('station_id')),
                                   species_list=species_list,
                                   active_ingredients=active_ingredients,
                                   formulations=formulations)

        insert_bait_station_record(db, request.form, user_id)
        flash('Bait station record added.', 'success')
        return redirect(url_for('bait_records'))

    selected_station_id = request.args.get('station_id', '')
    selected_line_id = request.args.get('line_id', '')
    return render_template('operator/add_bait_record.html',
                           bait_lines=bait_lines,
                           show_back=bool(selected_station_id),
                           data={'station_id': selected_station_id, 'line_id': selected_line_id},
                           species_list=species_list,
                           active_ingredients=active_ingredients,
                           formulations=formulations)


@app.route('/operator/edit-bait-record/<int:record_id>', methods=['GET', 'POST'])
@role_required('Operator', 'Group Coordinator', 'Super Admin')
def edit_bait_record(record_id):
    """Edit a bait station check record."""
    user_id = session['user_id']
    super_admin = is_super_admin_mode()
    group_id = session.get('group_id')
    role = session.get('group_role')

    with db.get_cursor() as cursor:
        cursor.execute("""
            SELECT bsr.*, bs.code AS station_code, bs.line_id,
                   l.name AS line_name, l.group_id
            FROM bait_station_records bsr
            JOIN bait_stations bs ON bs.station_id = bsr.station_id
            JOIN lines l ON l.line_id = bs.line_id
            WHERE bsr.record_id = %s
        """, (record_id,))
        record = cursor.fetchone()

    if not record or (not super_admin and record['group_id'] != group_id):
        flash('Record not found.', 'danger')
        return redirect(url_for('bait_records'))

    if role == 'Operator' and record['recorded_by_id'] != user_id:
        flash('You can only edit your own records.', 'danger')
        return redirect(url_for('bait_records'))

    species_list = fetch_active_lookup(db, 'species', include_value=record['target_species'])
    active_ingredients = fetch_active_lookup(db, 'active_ingredients', include_value=record['active_ingredient'])
    formulations = fetch_active_lookup(db, 'bait_formulations', include_value=record['formulation'])

    if request.method == 'POST':
        errors = _validate_bait_record(request.form)

        # Authorise the station_id the user is submitting. Without this
        # an Operator could swap to a station on a line they don't
        # operate, or a Coordinator could write into another group.
        submitted_station_id = request.form.get('station_id', type=int)
        if submitted_station_id:
            if role == 'Operator':
                allowed_station_ids = set(fetch_operator_bait_station_ids(db, user_id, group_id))
                if submitted_station_id not in allowed_station_ids:
                    errors.append('You are not assigned to that bait station.')
            elif not super_admin:
                with db.get_cursor() as cursor:
                    cursor.execute(
                        """
                        SELECT 1
                        FROM bait_stations bs
                        JOIN lines l ON l.line_id = bs.line_id
                        WHERE bs.station_id = %s AND l.group_id = %s
                        """,
                        (submitted_station_id, group_id)
                    )
                    if not cursor.fetchone():
                        errors.append('That bait station is not in your group.')

        if errors:
            for e in errors:
                flash(e, 'danger')
            return render_template('operator/edit_bait_record.html',
                                   record=record, data=request.form,
                                   species_list=species_list,
                                   active_ingredients=active_ingredients,
                                   formulations=formulations)

        update_bait_station_record(db, {**request.form, 'record_id': record_id}, user_id)
        flash('Record updated.', 'success')
        return redirect(url_for('bait_records'))

    return render_template('operator/edit_bait_record.html',
                           record=record,
                           data={
                               'station_id': str(record['station_id']),
                               'date': record['date'],
                               'target_species': record['target_species'] or '',
                               'active_ingredient': record['active_ingredient'],
                               'formulation': record['formulation'],
                               'concentration': record['concentration'],
                               'bait_remaining': record['bait_remaining'],
                               'bait_removed': record['bait_removed'] or '',
                               'bait_added': record['bait_added'] or '',
                               'notes': record['notes'] or '',
                           },
                           species_list=species_list,
                           active_ingredients=active_ingredients,
                           formulations=formulations)
