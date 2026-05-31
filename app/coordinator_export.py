"""coordinator_export.py — CSV export hub for Group Coordinators."""

import csv
import io
from datetime import datetime

from flask import render_template, request, session, Response
from app import app, db
from app.utils import role_required


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

                # ── Pill 1: Line Records ──────────────────────────
                if export_type == 'lines':
                    line_type = request.form.get('line_type', 'Trap')

                    if line_type == 'Trap':
                        fieldnames = ['Code', 'Trap type', 'Line',
                                      'Latitude', 'Longitude', 'Status']
                        cursor.execute('''
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
                            ORDER BY l.name, t.code
                        ''', (group_id,))
                        filename = f'{safe_name}_trap_lines_{date_str}.csv'
                    else:
                        fieldnames = ['Code', 'Station type', 'Line',
                                      'Latitude', 'Longitude', 'Status']
                        cursor.execute('''
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
                            ORDER BY l.name, bs.code
                        ''', (group_id,))
                        filename = f'{safe_name}_bait_station_lines_{date_str}.csv'

                    rows = cursor.fetchall()

                # ── Pill 2: Trap Records ──────────────────────────
                elif export_type == 'trap_records':
                    line_id = request.form.get('line_id', '')
                    fieldnames = ['Date', 'Trap code', 'Line', 'Species',
                                  'Sex', 'Maturity', 'Status', 'Rebaited',
                                  'Bait type', 'Trap condition', 'Strikes',
                                  'Notes', 'Recorded by']

                    line_sql    = 'AND l.line_id = %s' if line_id else ''
                    line_params = [line_id] if line_id else []

                    cursor.execute(f'''
                        SELECT
                            TO_CHAR(tc.date, 'YYYY-MM-DD HH24:MI')
                                                         AS "Date",
                            t.code                       AS "Trap code",
                            l.name                       AS "Line",
                            tc.species_caught             AS "Species",
                            COALESCE(tc.sex::text, '')    AS "Sex",
                            COALESCE(tc.maturity::text, '') AS "Maturity",
                            tc.status::text               AS "Status",
                            tc.rebaited::text             AS "Rebaited",
                            COALESCE(tc.bait_type, '')    AS "Bait type",
                            COALESCE(tc.trap_condition::text, '') AS "Trap condition",
                            COALESCE(tc.strikes, 0)       AS "Strikes",
                            COALESCE(tc.notes, '')        AS "Notes",
                            u.first_name || ' ' || u.last_name AS "Recorded by"
                        FROM trap_catches tc
                        JOIN traps t  ON tc.trap_id = t.trap_id
                        JOIN lines l  ON t.line_id  = l.line_id
                        JOIN users u  ON tc.recorded_by_id = u.user_id
                        WHERE l.group_id = %s
                        {line_sql}
                        ORDER BY tc.date DESC, l.name, t.code
                    ''', [group_id] + line_params)
                    rows = cursor.fetchall()

                    # Use line name in filename if a specific line was selected
                    line_name_slug = ''
                    if line_id:
                        cursor.execute(
                            'SELECT name FROM lines WHERE line_id = %s', (line_id,)
                        )
                        line_row = cursor.fetchone()
                        if line_row:
                            line_name_slug = '_' + line_row['name'].lower().replace(' ', '_')
                    filename = f'{safe_name}_trap_records{line_name_slug}_{date_str}.csv'

        except Exception as e:
            app.logger.error(f'CSV export error: {e}')

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

    # ── GET — render export hub ───────────────────────────────
    trap_count    = 0
    station_count = 0
    catch_count   = 0
    trap_lines    = []
    bait_lines    = []

    try:
        with db.get_cursor() as cursor:
            cursor.execute('''
                SELECT COUNT(*) AS cnt FROM traps t
                JOIN lines l ON t.line_id = l.line_id
                WHERE l.group_id = %s AND l.type = 'Trap'
            ''', (group_id,))
            trap_count = cursor.fetchone()['cnt']

            cursor.execute('''
                SELECT COUNT(*) AS cnt FROM bait_stations bs
                JOIN lines l ON bs.line_id = l.line_id
                WHERE l.group_id = %s AND l.type = 'Bait Station'
            ''', (group_id,))
            station_count = cursor.fetchone()['cnt']

            cursor.execute('''
                SELECT COUNT(*) AS cnt FROM trap_catches tc
                JOIN traps t ON tc.trap_id = t.trap_id
                JOIN lines l ON t.line_id = l.line_id
                WHERE l.group_id = %s
            ''', (group_id,))
            catch_count = cursor.fetchone()['cnt']

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
            bait_lines = cursor.fetchall()

    except Exception as e:
        app.logger.error(f'CSV export count error: {e}')

    return render_template('coordinator/export.html',
                           trap_count=trap_count,
                           station_count=station_count,
                           catch_count=catch_count,
                           trap_lines=trap_lines,
                           bait_lines=bait_lines)
