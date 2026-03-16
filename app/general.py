"""general.py — General routes accessible by multiple roles."""

from flask import render_template, request
from app import app, db
from app.utils import role_required

@app.route('/catch-records')
@role_required()
def catch_records():
    """Browse and filter all trap catch records."""
    filters = {
        'trap_code': request.args.get('trap_code'),
        'line_id': request.args.get('line_id'),
        'species_caught': request.args.get('species_caught'),
        'status': request.args.get('status'),
        'trap_condition': request.args.get('trap_condition'),
        'date_from': request.args.get('date_from'),
        'date_to': request.args.get('date_to'),
        'sort_date': request.args.get('sort_date', 'desc')
    }

    where_clauses = []
    query_params = []

    if filters['trap_code']:
        where_clauses.append("t.code = %s")
        query_params.append(filters['trap_code'])
    if filters['line_id']:
        where_clauses.append("l.line_id = %s")
        query_params.append(filters['line_id'])
    if filters['species_caught']:
        where_clauses.append("tc.species_caught = %s")
        query_params.append(filters['species_caught'])
    if filters['status']:
        where_clauses.append("tc.status = %s")
        query_params.append(filters['status'])
    if filters['trap_condition']:
        where_clauses.append("tc.trap_condition = %s")
        query_params.append(filters['trap_condition'])
    if filters['date_from']:
        where_clauses.append("tc.date >= %s")
        query_params.append(filters['date_from'])
    if filters['date_to']:
        where_clauses.append("tc.date <= %s")
        query_params.append(filters['date_to'] + " 23:59:59")

    where_sql = ""
    if where_clauses:
        where_sql = "WHERE " + " AND ".join(where_clauses)
        
    # Sort by date only
    if filters['sort_date'] == 'asc':
        order_sql = "ORDER BY tc.date ASC"
    else:
        order_sql = "ORDER BY tc.date DESC"

    with db.get_cursor() as cursor:
        cursor.execute(f"""
            SELECT 
                tc.*,
                t.code AS trap_code,
                t.trap_type,
                l.name AS line_name,
                u.first_name || ' ' || u.last_name AS recorded_by
            FROM trap_catches tc
            JOIN traps t ON tc.trap_id = t.trap_id
            JOIN lines l ON t.line_id = l.line_id
            LEFT JOIN users u ON tc.recorded_by_id = u.user_id
            {where_sql}
            {order_sql}
        """, tuple(query_params))
        records = cursor.fetchall()

        cursor.execute("SELECT DISTINCT code FROM traps ORDER BY code")
        trap_codes = [r['code'] for r in cursor.fetchall()]
        
        cursor.execute("SELECT line_id, name FROM lines ORDER BY name")
        lines = cursor.fetchall()
        
        cursor.execute("SELECT name FROM species ORDER BY name")
        species = [r['name'] for r in cursor.fetchall()]
        
        cursor.execute("SELECT name FROM trap_statuses ORDER BY name")
        statuses = [r['name'] for r in cursor.fetchall()]
        
        cursor.execute("SELECT unnest(enum_range(NULL::trap_condition_type)) AS condition")
        conditions = [r['condition'] for r in cursor.fetchall()]

        filter_data = {
            'trap_codes': trap_codes,
            'lines': lines,
            'species': species,
            'statuses': statuses,
            'conditions': conditions
        }

    return render_template(
        'observer/catch_records.html', 
        records=records, 
        selected_filters=filters, 
        filter_data=filter_data
    )

