"""general.py — General routes accessible by multiple roles."""

from flask import render_template, request, session
from app import app, db
from app.utils import role_required, is_super_admin_mode, is_support_tech_mode
from app.themes import PLATFORM_DEFAULT_THEME

# Fallback badge colour for groups with no custom theme row.
DEFAULT_GROUP_COLOR = PLATFORM_DEFAULT_THEME['primary_color']

def get_catch_records(recorded_by_id=None):
    """Query catch records with optional filter by recorded_by_id.

    Scopes to the active group unless the caller is Super Admin acting
    platform-wide. Without this every logged-in user could see every
    group's catches.
    """
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

    # Super Admin (platform-wide) and Support Technician see every group.
    bypass_group = is_super_admin_mode() or is_support_tech_mode()

    if not bypass_group:
        where_clauses.append("l.group_id = %s")
        query_params.append(session.get('group_id'))
    if recorded_by_id:
        where_clauses.append("tc.recorded_by_id = %s")
        query_params.append(recorded_by_id)
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
                g.name AS group_name,
                COALESCE(gt.primary_color, '{DEFAULT_GROUP_COLOR}') AS group_color
            FROM trap_catches tc
            JOIN traps t ON tc.trap_id = t.trap_id
            JOIN lines l ON t.line_id = l.line_id
            LEFT JOIN groups g ON g.group_id = l.group_id
            LEFT JOIN group_themes gt ON gt.group_id = l.group_id
            LEFT JOIN users u ON tc.recorded_by_id = u.user_id
            {where_sql}
            {order_sql}
        """, tuple(query_params))
        records = cursor.fetchall()

        # Scope filter dropdowns the same way as the record query.
        if bypass_group:
            cursor.execute("SELECT DISTINCT code FROM traps ORDER BY code")
            trap_codes = [r['code'] for r in cursor.fetchall()]

            cursor.execute("SELECT line_id, name FROM lines ORDER BY name")
            lines = cursor.fetchall()
        else:
            active_group = session.get('group_id')
            cursor.execute(
                """
                SELECT DISTINCT t.code
                FROM traps t
                JOIN lines l ON l.line_id = t.line_id
                WHERE l.group_id = %s
                ORDER BY t.code
                """,
                (active_group,)
            )
            trap_codes = [r['code'] for r in cursor.fetchall()]

            cursor.execute(
                "SELECT line_id, name FROM lines WHERE group_id = %s ORDER BY name",
                (active_group,)
            )
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

    return records, filters, filter_data


@app.route('/catch-records')
@role_required()
def catch_records():
    """Browse and filter all trap catch records."""
    records, filters, filter_data = get_catch_records()

    trap_map = None
    if session.get('group_role') in ('Super Admin', 'Group Coordinator'):
        # Trap state lookup for the inline edit-action gate. Scope to the
        # active group unless acting platform-wide (Super Admin / Support Tech).
        with db.get_cursor() as cursor:
            if is_super_admin_mode() or is_support_tech_mode():
                cursor.execute("SELECT trap_id, is_retired FROM traps")
            else:
                cursor.execute(
                    """
                    SELECT t.trap_id, t.is_retired
                    FROM traps t
                    JOIN lines l ON l.line_id = t.line_id
                    WHERE l.group_id = %s
                    """,
                    (session.get('group_id'),)
                )
            traps = cursor.fetchall()

        trap_map = {t["trap_id"]: t for t in traps}

    return render_template(
        'observer/catch_records.html',
        records=records,
        selected_filters=filters,
        filter_data=filter_data,
        trap_map=trap_map,
        cross_group=is_super_admin_mode() or is_support_tech_mode()
    )


def get_observations(operator_id=None):
    """Query observations with optional filter by operator_id.

    Scopes to the active group unless the caller is Super Admin acting
    platform-wide. Without this every logged-in user could see every
    group's observations.
    """
    filters = {
        'observation_type': request.args.get('observation_type'),
        'line_id': request.args.get('line_id'),
        'trap_code': request.args.get('trap_code'),
        'date_from': request.args.get('date_from'),
        'date_to': request.args.get('date_to'),
        'sort_date': request.args.get('sort_date', 'desc')
    }

    where_clauses = []
    query_params = []

    # Super Admin (platform-wide) and Support Technician see every group.
    bypass_group = is_super_admin_mode() or is_support_tech_mode()

    if not bypass_group:
        where_clauses.append("l.group_id = %s")
        query_params.append(session.get('group_id'))
    if operator_id:
        where_clauses.append("o.operator_id = %s")
        query_params.append(operator_id)
    if filters['observation_type']:
        where_clauses.append("o.observation_type = %s")
        query_params.append(filters['observation_type'])
    if filters['line_id']:
        where_clauses.append("o.line_id = %s")
        query_params.append(filters['line_id'])
    if filters['trap_code']:
        where_clauses.append("t.code = %s")
        query_params.append(filters['trap_code'])
    if filters['date_from']:
        where_clauses.append("o.date >= %s")
        query_params.append(filters['date_from'])
    if filters['date_to']:
        where_clauses.append("o.date <= %s")
        query_params.append(filters['date_to'] + " 23:59:59")

    where_sql = ""
    if where_clauses:
        where_sql = "WHERE " + " AND ".join(where_clauses)
        
    if filters['sort_date'] == 'asc':
        order_sql = "ORDER BY o.date ASC"
    else:
        order_sql = "ORDER BY o.date DESC"

    with db.get_cursor() as cursor:
        cursor.execute(f"""
            SELECT 
                o.*,
                t.code AS trap_code,
                l.name AS line_name,
                g.name AS group_name,
                COALESCE(gt.primary_color, '{DEFAULT_GROUP_COLOR}') AS group_color,
                u.first_name || ' ' || u.last_name AS operator_name
            FROM incidental_observations o
            LEFT JOIN traps t ON o.trap_id = t.trap_id
            LEFT JOIN lines l ON o.line_id = l.line_id
            LEFT JOIN groups g ON g.group_id = l.group_id
            LEFT JOIN group_themes gt ON gt.group_id = l.group_id
            LEFT JOIN users u ON o.operator_id = u.user_id
            {where_sql}
            {order_sql}
        """, tuple(query_params))
        records = cursor.fetchall()

        # Scope filter dropdowns the same way as the record query.
        if bypass_group:
            cursor.execute("SELECT DISTINCT code FROM traps ORDER BY code")
            trap_codes = [r['code'] for r in cursor.fetchall()]

            cursor.execute("SELECT line_id, name FROM lines ORDER BY name")
            lines = cursor.fetchall()
        else:
            active_group = session.get('group_id')
            cursor.execute(
                """
                SELECT DISTINCT t.code
                FROM traps t
                JOIN lines l ON l.line_id = t.line_id
                WHERE l.group_id = %s
                ORDER BY t.code
                """,
                (active_group,)
            )
            trap_codes = [r['code'] for r in cursor.fetchall()]

            cursor.execute(
                "SELECT line_id, name FROM lines WHERE group_id = %s ORDER BY name",
                (active_group,)
            )
            lines = cursor.fetchall()

        cursor.execute("SELECT unnest(enum_range(NULL::observation_type_enum)) AS obs_type")
        observation_types = [r['obs_type'] for r in cursor.fetchall()]

        filter_data = {
            'trap_codes': trap_codes,
            'lines': lines,
            'observation_types': observation_types
        }

    return records, filters, filter_data


@app.route('/observations')
@role_required()
def observations():
    """Browse and filter all incidental observations."""
    records, filters, filter_data = get_observations()
    return render_template(
        'observer/observations.html',
        records=records,
        selected_filters=filters,
        filter_data=filter_data,
        cross_group=is_super_admin_mode() or is_support_tech_mode()
    )


@app.route('/bait-records')
@role_required()
def bait_records():
    """Browse bait station records.

    Normal users see records for their active group. Super Admin acting
    platform-wide sees records from every group.
    """
    # Super Admin (platform-wide) and Support Technician see every group.
    bypass_group = is_super_admin_mode() or is_support_tech_mode()
    group_id = session.get('group_id')
    user_id = session['user_id']
    role = session.get('group_role')

    filters = {
        'line_id': request.args.get('line_id'),
        'station_id': request.args.get('station_id'),
        'date_from': request.args.get('date_from'),
        'date_to': request.args.get('date_to'),
    }

    where_clauses = []
    params = []

    if not bypass_group:
        where_clauses.append('l.group_id = %s')
        params.append(group_id)

    if filters['line_id']:
        where_clauses.append('l.line_id = %s')
        params.append(filters['line_id'])
    if filters['station_id']:
        where_clauses.append('bsr.station_id = %s')
        params.append(filters['station_id'])
    if filters['date_from']:
        where_clauses.append('bsr.date >= %s')
        params.append(filters['date_from'])
    if filters['date_to']:
        where_clauses.append('bsr.date <= %s')
        params.append(filters['date_to'])

    where_sql = ('WHERE ' + ' AND '.join(where_clauses)) if where_clauses else ''

    with db.get_cursor() as cursor:
        cursor.execute(f"""
            SELECT bsr.*,
                   bs.code AS station_code, bs.station_type,
                   l.line_id, l.name AS line_name,
                   g.name AS group_name,
                   COALESCE(gt.primary_color, '{DEFAULT_GROUP_COLOR}') AS group_color,
                   ru.username AS recorded_by_username,
                   eu.username AS edited_by_username
            FROM bait_station_records bsr
            JOIN bait_stations bs ON bs.station_id = bsr.station_id
            JOIN lines l ON l.line_id = bs.line_id
            LEFT JOIN groups g ON g.group_id = l.group_id
            LEFT JOIN group_themes gt ON gt.group_id = l.group_id
            LEFT JOIN users ru ON ru.user_id = bsr.recorded_by_id
            LEFT JOIN users eu ON eu.user_id = bsr.edited_by_id
            {where_sql}
            ORDER BY bsr.date DESC
        """, params)
        records = cursor.fetchall()

        if bypass_group:
            cursor.execute("""
                SELECT l.line_id, l.name
                FROM lines l
                WHERE l.type = 'Bait Station' AND l.is_retired = FALSE
                ORDER BY l.name
            """)
        else:
            cursor.execute("""
                SELECT l.line_id, l.name
                FROM lines l
                WHERE l.group_id = %s AND l.type = 'Bait Station' AND l.is_retired = FALSE
                ORDER BY l.name
            """, (group_id,))
        lines = cursor.fetchall()

        station_filter_line = filters['line_id'] or None
        if station_filter_line:
            cursor.execute("""
                SELECT bs.station_id, bs.code
                FROM bait_stations bs
                WHERE bs.line_id = %s
                ORDER BY bs.code
            """, (station_filter_line,))
        elif bypass_group:
            cursor.execute("""
                SELECT bs.station_id, bs.code
                FROM bait_stations bs
                ORDER BY bs.code
            """)
        else:
            cursor.execute("""
                SELECT bs.station_id, bs.code
                FROM bait_stations bs
                JOIN lines l ON l.line_id = bs.line_id
                WHERE l.group_id = %s
                ORDER BY bs.code
            """, (group_id,))
        stations = cursor.fetchall()

    return render_template('observer/bait_records.html',
                           records=records,
                           selected_filters=filters,
                           lines=lines,
                           stations=stations,
                           user_id=user_id,
                           role=role,
                           cross_group=bypass_group)

