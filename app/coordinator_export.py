"""coordinator_export.py — CSV export for Group Coordinators."""

import csv
import io
from datetime import datetime

from flask import render_template, request, session, Response
from app import app, db
from app.utils import role_required


@app.route('/coordinator/lines/export', methods=['GET', 'POST'])
@role_required('Group Coordinator')
def coordinator_lines_export():
    """Export page — GET shows filter form, POST returns CSV download."""
    group_id   = session.get('group_id')
    group_name = session.get('group_name', 'group')

    if request.method == 'POST':
        line_type = request.form.get('line_type', 'Trap')  # 'Trap' or 'Bait Station'

        rows = []
        try:
            with db.get_cursor() as cursor:
                if line_type == 'Trap':
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
                else:
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
                rows = cursor.fetchall()
        except Exception as e:
            app.logger.error(f'CSV export error: {e}')
            rows = []

        # Build CSV in memory
        output   = io.StringIO()
        if rows:
            fieldnames = list(rows[0].keys())
            writer = csv.DictWriter(output, fieldnames=fieldnames)
            writer.writeheader()
            for row in rows:
                writer.writerow(dict(row))
        else:
            # Write header-only CSV when no data
            if line_type == 'Trap':
                output.write('Code,Trap type,Line,Latitude,Longitude,Status\n')
            else:
                output.write('Code,Station type,Line,Latitude,Longitude,Status\n')

        # Build filename: groupname_traplines_YYYYMMDD.csv
        date_str  = datetime.now().strftime('%Y%m%d')
        type_slug = 'trap_lines' if line_type == 'Trap' else 'bait_station_lines'
        safe_name = group_name.lower().replace(' ', '_')
        filename  = f'{safe_name}_{type_slug}_{date_str}.csv'

        return Response(
            output.getvalue(),
            mimetype='text/csv',
            headers={'Content-Disposition': f'attachment; filename="{filename}"'}
        )

    # GET — render the export filter page
    # Count available records so the coordinator knows what they'll get
    trap_count    = 0
    station_count = 0
    try:
        with db.get_cursor() as cursor:
            cursor.execute('''
                SELECT COUNT(*) AS cnt
                FROM traps t
                JOIN lines l ON t.line_id = l.line_id
                WHERE l.group_id = %s AND l.type = 'Trap'
            ''', (group_id,))
            trap_count = cursor.fetchone()['cnt']

            cursor.execute('''
                SELECT COUNT(*) AS cnt
                FROM bait_stations bs
                JOIN lines l ON bs.line_id = l.line_id
                WHERE l.group_id = %s AND l.type = 'Bait Station'
            ''', (group_id,))
            station_count = cursor.fetchone()['cnt']
    except Exception as e:
        app.logger.error(f'CSV export count error: {e}')

    return render_template('coordinator/export.html',
                           trap_count=trap_count,
                           station_count=station_count)
