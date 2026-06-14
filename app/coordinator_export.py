"""coordinator_export.py — CSV export hub for Group Coordinators."""

import csv
import io
import logging
from datetime import datetime

from flask import render_template, request, session, Response, jsonify
from app import app, db
from app.utils import role_required

logger = logging.getLogger(__name__)


@app.route('/coordinator/export', methods=['GET', 'POST'])
@role_required('Group Coordinator')
def coordinator_export():
    """Export hub — GET shows pill UI, POST returns CSV download."""
    group_id   = session.get('group_id')
    group_name = session.get('group_name', 'group')

    if request.method == 'POST':
        export_type = request.form.get('export_type', 'lines')
        date_str    = datetime.now().strftime('%Y%m%d')
        safe_name   = group_name.lower().replace(' ', '_')

        rows       = []
        fieldnames = []
        filename   = f'{safe_name}_export_{date_str}.csv'

        try:
            with db.get_cursor() as cursor:

                # ── Pill 1: Line Records ──────────────────────────────────
                if export_type == 'lines':
                    line_type = request.form.get('line_type', 'Trap')

                    if line_type == 'Trap':
                        fieldnames = ['Name', 'Type', 'Status', 'Trap count']
                        cursor.execute('''
                            SELECT
                                l.name                                         AS "Name",
                                l.type                                         AS "Type",
                                CASE WHEN l.is_retired THEN 'Retired' ELSE 'Active' END
                                                                               AS "Status",
                                COUNT(t.trap_id)                               AS "Trap count"
                            FROM lines l
                            LEFT JOIN traps t ON t.line_id = l.line_id
                            WHERE l.group_id = %s AND l.type = 'Trap'
                            GROUP BY l.line_id, l.name, l.type, l.is_retired
                            ORDER BY l.name
                        ''', (group_id,))
                        filename = f'{safe_name}_trap_lines_{date_str}.csv'
                    else:
                        fieldnames = ['Name', 'Type', 'Status', 'Station count']
                        cursor.execute('''
                            SELECT
                                l.name                                         AS "Name",
                                l.type                                         AS "Type",
                                CASE WHEN l.is_retired THEN 'Retired' ELSE 'Active' END
                                                                               AS "Status",
                                COUNT(bs.station_id)                           AS "Station count"
                            FROM lines l
                            LEFT JOIN bait_stations bs ON bs.line_id = l.line_id
                            WHERE l.group_id = %s AND l.type = 'Bait Station'
                            GROUP BY l.line_id, l.name, l.type, l.is_retired
                            ORDER BY l.name
                        ''', (group_id,))
                        filename = f'{safe_name}_bait_station_lines_{date_str}.csv'

                    rows = cursor.fetchall()

                # ── Pill 2: Trap device records ───────────────────────────
                elif export_type == 'traps':
                    line_id = request.form.get('line_id', '')
                    fieldnames = ['Code', 'Trap type', 'Line',
                                  'Latitude', 'Longitude', 'Status']

                    line_sql    = 'AND l.line_id = %s' if line_id else ''
                    line_params = [line_id] if line_id else []

                    cursor.execute(f'''
                        SELECT
                            t.code           AS "Code",
                            t.trap_type      AS "Trap type",
                            l.name           AS "Line",
                            t.latitude       AS "Latitude",
                            t.longitude      AS "Longitude",
                            CASE WHEN t.is_retired THEN 'Retired' ELSE 'Active' END
                                             AS "Status"
                        FROM traps t
                        JOIN lines l ON t.line_id = l.line_id
                        WHERE l.group_id = %s AND l.type = 'Trap'
                        {line_sql}
                        ORDER BY l.name, t.code
                    ''', [group_id] + line_params)
                    rows = cursor.fetchall()

                    line_name_slug = ''
                    if line_id:
                        cursor.execute(
                            'SELECT name FROM lines WHERE line_id = %s', (line_id,)
                        )
                        line_row = cursor.fetchone()
                        if line_row:
                            line_name_slug = '_' + line_row['name'].lower().replace(' ', '_')
                    filename = f'{safe_name}_traps{line_name_slug}_{date_str}.csv'

                # ── Pill 3: Trap check records (AR-08) ────────────────────
                elif export_type == 'trap_checks':
                    line_id   = request.form.get('line_id', '')
                    trap_id   = request.form.get('trap_id', '')
                    species   = request.form.get('species', '')
                    date_from = request.form.get('date_from', '')
                    date_to   = request.form.get('date_to', '')

                    fieldnames = ['Date', 'Trap code', 'Line', 'Species',
                                  'Sex', 'Maturity', 'Status', 'Rebaited',
                                  'Bait type', 'Trap condition', 'Strikes',
                                  'Notes', 'Recorded by']

                    conditions = ['l.group_id = %s']
                    params     = [group_id]

                    if line_id:
                        conditions.append('l.line_id = %s')
                        params.append(line_id)
                    if trap_id:
                        conditions.append('t.trap_id = %s')
                        params.append(trap_id)
                    if species:
                        conditions.append('tc.species_caught ILIKE %s')
                        params.append(f'%{species}%')
                    if date_from:
                        conditions.append('tc.date >= %s')
                        params.append(date_from)
                    if date_to:
                        conditions.append('tc.date <= %s')
                        params.append(date_to)

                    where_sql = ' AND '.join(conditions)

                    cursor.execute(f'''
                        SELECT
                            TO_CHAR(tc.date, 'YYYY-MM-DD HH24:MI')       AS "Date",
                            t.code                                         AS "Trap code",
                            l.name                                         AS "Line",
                            tc.species_caught                              AS "Species",
                            COALESCE(tc.sex::text, '')                    AS "Sex",
                            COALESCE(tc.maturity::text, '')               AS "Maturity",
                            tc.status::text                               AS "Status",
                            tc.rebaited::text                             AS "Rebaited",
                            COALESCE(tc.bait_type, '')                    AS "Bait type",
                            COALESCE(tc.trap_condition::text, '')         AS "Trap condition",
                            COALESCE(tc.strikes, 0)                       AS "Strikes",
                            COALESCE(tc.notes, '')                        AS "Notes",
                            u.first_name || ' ' || u.last_name           AS "Recorded by"
                        FROM trap_catches tc
                        JOIN traps t  ON tc.trap_id = t.trap_id
                        JOIN lines l  ON t.line_id  = l.line_id
                        JOIN users u  ON tc.recorded_by_id = u.user_id
                        WHERE {where_sql}
                        ORDER BY tc.date DESC, l.name, t.code
                    ''', params)
                    rows = cursor.fetchall()
                    filename = f'{safe_name}_trap_checks_{date_str}.csv'

                # ── Pill 4: Bait station device records (AR-09) ───────────
                elif export_type == 'bait_stations':
                    line_id = request.form.get('line_id', '')
                    fieldnames = ['Code', 'Station type', 'Line',
                                  'Latitude', 'Longitude', 'Status']

                    line_sql    = 'AND l.line_id = %s' if line_id else ''
                    line_params = [line_id] if line_id else []

                    cursor.execute(f'''
                        SELECT
                            bs.code          AS "Code",
                            bs.station_type  AS "Station type",
                            l.name           AS "Line",
                            bs.latitude      AS "Latitude",
                            bs.longitude     AS "Longitude",
                            CASE WHEN bs.is_retired THEN 'Retired' ELSE 'Active' END
                                             AS "Status"
                        FROM bait_stations bs
                        JOIN lines l ON bs.line_id = l.line_id
                        WHERE l.group_id = %s AND l.type = 'Bait Station'
                        {line_sql}
                        ORDER BY l.name, bs.code
                    ''', [group_id] + line_params)
                    rows = cursor.fetchall()

                    line_name_slug = ''
                    if line_id:
                        cursor.execute(
                            'SELECT name FROM lines WHERE line_id = %s', (line_id,)
                        )
                        line_row = cursor.fetchone()
                        if line_row:
                            line_name_slug = '_' + line_row['name'].lower().replace(' ', '_')
                    filename = f'{safe_name}_bait_stations{line_name_slug}_{date_str}.csv'

                # ── Pill 5: Bait station records (AR-10) ──────────────────
                elif export_type == 'bait_station_records':
                    line_id    = request.form.get('line_id', '')
                    station_id = request.form.get('station_id', '')
                    date_from  = request.form.get('date_from', '')
                    date_to    = request.form.get('date_to', '')

                    fieldnames = ['Date', 'Station code', 'Line',
                                  'Target species', 'Active ingredient',
                                  'Formulation', 'Concentration',
                                  'Bait remaining', 'Bait removed',
                                  'Bait added', 'Notes', 'Recorded by']

                    conditions = ['l.group_id = %s']
                    params     = [group_id]

                    if line_id:
                        conditions.append('l.line_id = %s')
                        params.append(line_id)
                    if station_id:
                        conditions.append('bs.station_id = %s')
                        params.append(station_id)
                    if date_from:
                        conditions.append('bsr.date >= %s')
                        params.append(date_from)
                    if date_to:
                        conditions.append('bsr.date <= %s')
                        params.append(date_to)

                    where_sql = ' AND '.join(conditions)

                    cursor.execute(f'''
                        SELECT
                            TO_CHAR(bsr.date, 'YYYY-MM-DD HH24:MI')      AS "Date",
                            bs.code                                        AS "Station code",
                            l.name                                         AS "Line",
                            COALESCE(bsr.target_species, '')              AS "Target species",
                            bsr.active_ingredient                          AS "Active ingredient",
                            bsr.formulation                               AS "Formulation",
                            bsr.concentration                             AS "Concentration",
                            bsr.bait_remaining                            AS "Bait remaining",
                            COALESCE(bsr.bait_removed, 0)                AS "Bait removed",
                            COALESCE(bsr.bait_added, 0)                  AS "Bait added",
                            COALESCE(bsr.notes, '')                       AS "Notes",
                            COALESCE(u.first_name || ' ' || u.last_name, '') AS "Recorded by"
                        FROM bait_station_records bsr
                        JOIN bait_stations bs  ON bsr.station_id    = bs.station_id
                        JOIN lines l           ON bs.line_id        = l.line_id
                        LEFT JOIN users u      ON bsr.recorded_by_id = u.user_id
                        WHERE {where_sql}
                        ORDER BY bsr.date DESC, l.name, bs.code
                    ''', params)
                    rows = cursor.fetchall()
                    filename = f'{safe_name}_bait_station_records_{date_str}.csv'

        except Exception:
            logger.exception('CSV export error')

        # Build CSV in memory
        output = io.StringIO()
        writer = csv.DictWriter(output, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            writer.writerow(dict(row))

        return Response(
            output.getvalue(),
            mimetype='text/csv',
            headers={'Content-Disposition': f'attachment; filename="{filename}"'}
        )

    # ── GET — render export hub ───────────────────────────────────────────────
    trap_line_count      = 0
    bait_line_count      = 0
    trap_count           = 0
    trap_check_count     = 0
    bait_station_count   = 0
    bait_record_count    = 0
    trap_lines           = []
    bait_station_lines   = []

    try:
        with db.get_cursor() as cursor:
            cursor.execute('''
                SELECT COUNT(*) AS cnt FROM lines
                WHERE group_id = %s AND type = 'Trap'
            ''', (group_id,))
            trap_line_count = cursor.fetchone()['cnt']

            cursor.execute('''
                SELECT COUNT(*) AS cnt FROM lines
                WHERE group_id = %s AND type = 'Bait Station'
            ''', (group_id,))
            bait_line_count = cursor.fetchone()['cnt']

            cursor.execute('''
                SELECT COUNT(*) AS cnt FROM traps t
                JOIN lines l ON t.line_id = l.line_id
                WHERE l.group_id = %s AND l.type = 'Trap'
            ''', (group_id,))
            trap_count = cursor.fetchone()['cnt']

            cursor.execute('''
                SELECT COUNT(*) AS cnt FROM trap_catches tc
                JOIN traps t ON tc.trap_id = t.trap_id
                JOIN lines l ON t.line_id = l.line_id
                WHERE l.group_id = %s
            ''', (group_id,))
            trap_check_count = cursor.fetchone()['cnt']

            cursor.execute('''
                SELECT COUNT(*) AS cnt FROM bait_stations bs
                JOIN lines l ON bs.line_id = l.line_id
                WHERE l.group_id = %s AND l.type = 'Bait Station'
            ''', (group_id,))
            bait_station_count = cursor.fetchone()['cnt']

            cursor.execute('''
                SELECT line_id, name FROM lines
                WHERE group_id = %s AND type = 'Trap' AND is_retired = FALSE
                ORDER BY name
            ''', (group_id,))
            trap_lines = cursor.fetchall()

            cursor.execute('''
                SELECT line_id, name FROM lines
                WHERE group_id = %s AND type = 'Bait Station' AND is_retired = FALSE
                ORDER BY name
            ''', (group_id,))
            bait_station_lines = cursor.fetchall()

            cursor.execute('''
                SELECT COUNT(*) AS cnt FROM bait_station_records bsr
                JOIN bait_stations bs ON bsr.station_id = bs.station_id
                JOIN lines l ON bs.line_id = l.line_id
                WHERE l.group_id = %s
            ''', (group_id,))
            bait_record_count = cursor.fetchone()['cnt']

    except Exception:
        logger.exception('CSV export count error')

    return render_template('coordinator/export.html',
                           trap_line_count=trap_line_count,
                           bait_line_count=bait_line_count,
                           trap_count=trap_count,
                           trap_check_count=trap_check_count,
                           bait_station_count=bait_station_count,
                           bait_record_count=bait_record_count,
                           trap_lines=trap_lines,
                           bait_station_lines=bait_station_lines)


@app.route('/api/traps_by_line')
@role_required('Group Coordinator')
def api_traps_by_line():
    """JSON list of active traps for a line — scoped to the coordinator's group."""
    line_id  = request.args.get('line_id', '')
    group_id = session.get('group_id')
    traps = []
    if line_id:
        try:
            with db.get_cursor() as cursor:
                cursor.execute('''
                    SELECT t.trap_id, t.code
                    FROM traps t
                    JOIN lines l ON t.line_id = l.line_id
                    WHERE t.line_id = %s AND l.group_id = %s AND t.is_retired = FALSE
                    ORDER BY t.code
                ''', (line_id, group_id))
                traps = [dict(r) for r in cursor.fetchall()]
        except Exception:
            logger.exception('api_traps_by_line error')
    return jsonify(traps)


@app.route('/api/stations_by_line')
@role_required('Group Coordinator')
def api_stations_by_line():
    """JSON list of active bait stations for a line — scoped to the coordinator's group."""
    line_id  = request.args.get('line_id', '')
    group_id = session.get('group_id')
    stations = []
    if line_id:
        try:
            with db.get_cursor() as cursor:
                cursor.execute('''
                    SELECT bs.station_id, bs.code
                    FROM bait_stations bs
                    JOIN lines l ON bs.line_id = l.line_id
                    WHERE bs.line_id = %s AND l.group_id = %s AND bs.is_retired = FALSE
                    ORDER BY bs.code
                ''', (line_id, group_id))
                stations = [dict(r) for r in cursor.fetchall()]
        except Exception:
            logger.exception('api_stations_by_line error')
    return jsonify(stations)
