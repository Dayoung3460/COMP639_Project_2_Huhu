"""lines.py — Trap lines and traps viewing (all logged-in roles)."""

from flask import render_template, request
from app import app, db
from app.utils import role_required
from app.connect import api_key as linz_api_key


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
                    FILTER (WHERE (%s OR t.is_retired = FALSE)) AS trap_count,
                COUNT(DISTINCT ol.operator_id) AS operator_count
            FROM lines l
            LEFT JOIN traps t ON t.line_id = l.line_id
            LEFT JOIN operator_lines ol ON ol.line_id = l.line_id
            WHERE (%s OR l.is_retired = FALSE)
            GROUP BY l.line_id, l.name, l.type, l.is_retired
            ORDER BY l.is_retired ASC, l.name ASC
            """,
            (show_retired, show_retired)
        )
        lines = cursor.fetchall()

    return render_template(
        'lines/index.html',
        lines=lines,
        show_retired=show_retired
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
              AND (%s OR is_retired = FALSE)
            """,
            (line_id, show_retired)
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
