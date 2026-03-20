"""lines.py — Trap lines and traps viewing (all logged-in roles)."""

from flask import render_template, request, url_for
from app import app, db
from app.utils import role_required
import os

linz_api_key = os.getenv('LINZ_API_KEY', '')

@app.route('/lines')
@role_required()
def lines_index():
    """Display all active trap lines."""
    show_retired = request.args.get('show_retired') in ('1', 'true', 'on', 'yes')

    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT
                l.line_id,
                l.name,
                l.type,
                l.is_retired,
                COUNT(DISTINCT t.trap_id)
                    FILTER (WHERE t.is_retired = FALSE) AS trap_count,
                COUNT(DISTINCT ol.operator_id) AS operator_count
            FROM lines l
            LEFT JOIN traps t ON t.line_id = l.line_id
            LEFT JOIN operator_lines ol ON ol.line_id = l.line_id
            WHERE (%s OR l.is_retired = FALSE)
            GROUP BY l.line_id, l.name, l.type, l.is_retired
            ORDER BY l.is_retired ASC, l.name ASC
            """,
            (show_retired,)
        )
        lines = cursor.fetchall()

        cursor.execute(
            """
            SELECT l.line_id, COUNT(t.is_retired) as has_active_trap
            FROM lines AS l
            LEFT JOIN traps as t ON t.line_id = l.line_id
            WHERE t.is_retired = FALSE
            GROUP BY l.line_id
            ;
            """
        )
        line_has_active_traps = cursor.fetchall()
        active_trap_line_ids = set(
            line['line_id'] for line in line_has_active_traps 
            if line['has_active_trap'] > 0
        )

        cursor.execute(
            """
            SELECT
                l.line_id,
                l.name AS line_name,
                l.is_retired AS line_is_retired,
                t.trap_id,
                t.code,
                t.trap_type,
                t.latitude,
                t.longitude,
                t.is_retired AS trap_is_retired
            FROM lines l
            LEFT JOIN traps t ON t.line_id = l.line_id
            WHERE (%s OR l.is_retired = FALSE)
              AND t.trap_id IS NOT NULL
              AND t.latitude IS NOT NULL
              AND t.longitude IS NOT NULL
              AND (%s OR t.is_retired = FALSE)
            ORDER BY l.name ASC, t.code ASC
            """,
            (show_retired, show_retired)
        )
        trap_rows = cursor.fetchall()

    map_traps = []
    for trap in trap_rows:
        detail_url = url_for('line_detail', line_id=trap['line_id'])
        if show_retired:
            detail_url = f"{detail_url}?show_retired=1"

        map_traps.append({
            'line_id': trap['line_id'],
            'line_name': trap['line_name'],
            'line_is_retired': trap['line_is_retired'],
            'trap_id': trap['trap_id'],
            'code': trap['code'],
            'trap_type': trap['trap_type'],
            'latitude': float(trap['latitude']),
            'longitude': float(trap['longitude']),
            'trap_is_retired': trap['trap_is_retired'],
            'detail_url': detail_url
        })

    return render_template(
        'lines/index.html',
        lines=lines,
        show_retired=show_retired,
        map_traps=map_traps,
        linz_api_key=linz_api_key,
        active_trap_line_ids=active_trap_line_ids
    )


@app.route('/lines/<int:line_id>')
@role_required()
def line_detail(line_id):
    """Display a single trap line and all its traps."""
    show_retired = request.args.get('show_retired') in ('1', 'true', 'on', 'yes')

    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT line_id, name, type, is_retired
            FROM lines
            WHERE line_id = %s
            """,
            (line_id,)
        )
        line = cursor.fetchone()

        if line:
            cursor.execute(
                """
                SELECT
                    trap_id,
                    code,
                    trap_type,
                    latitude,
                    longitude,
                    is_retired
                FROM traps
                WHERE line_id = %s
                  AND (%s OR is_retired = FALSE)
                ORDER BY code ASC
                """,
                (line_id, show_retired)
            )
            traps = cursor.fetchall()

            cursor.execute(
                """
                SELECT u.user_id, u.username, u.first_name, u.last_name
                FROM operator_lines ol
                JOIN users u ON u.user_id = ol.operator_id
                WHERE ol.line_id = %s
                  AND u.role = 'Operator'
                ORDER BY u.first_name ASC, u.last_name ASC
                """,
                (line_id,)
            )
            operators = cursor.fetchall()
        else:
            traps = []
            operators = []

    trap_markers = []
    for trap in traps:
        if trap.get('latitude') is None or trap.get('longitude') is None:
            continue
        trap_markers.append({
            'trap_id': trap['trap_id'],
            'code': trap['code'],
            'trap_type': trap['trap_type'],
            'latitude': float(trap['latitude']),
            'longitude': float(trap['longitude']),
            'is_retired': trap['is_retired']
        })

    return render_template(
        'lines/detail.html',
        line=line,
        traps=traps,
        operators=operators,
        show_retired=show_retired,
        trap_markers=trap_markers,
        linz_api_key=linz_api_key
    )
