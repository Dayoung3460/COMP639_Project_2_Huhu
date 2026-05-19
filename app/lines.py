import logging
import os

from flask import render_template, request, url_for, flash, redirect, session
from app import app, db
from app.utils import role_required, LINE_COLOURS, is_super_admin_mode, is_support_tech_mode
from app.helpers.dbHelper import fetch_active_lookup

logger = logging.getLogger(__name__)

linz_api_key = os.getenv('LINZ_API_KEY', '')

@app.route('/lines')
@role_required()
def lines_index():
    """Display all active trap lines."""
    line_filter = request.args.get('filter', 'all')
    operator_filter = request.args.get('operator')
    if line_filter not in ('all', 'active', 'retired'):
        line_filter = 'all'

    # Super Admins and Support Technicians operate without group context —
    # drop the WHERE l.group_id filter so they see data across every group.
    bypass_group = is_super_admin_mode() or is_support_tech_mode()
    group_id = session.get('group_id')
    group_clause = '' if bypass_group else 'l.group_id = %s AND'
    group_params = () if bypass_group else (group_id,)

    with db.get_cursor() as cursor:
        cursor.execute(
            f"""
            SELECT
                l.line_id,
                l.name,
                l.type,
                l.is_retired,
                l.retired_at,
                u_ret.username AS retired_by_username,
                (
                    SELECT COUNT(*)
                    FROM traps t
                    WHERE t.line_id = l.line_id
                      AND t.is_retired = FALSE
                ) AS trap_count,
                (
                    SELECT COUNT(*)
                    FROM bait_stations bs
                    WHERE bs.line_id = l.line_id
                      AND bs.is_retired = FALSE
                ) AS station_count,
                (
                    SELECT COUNT(*)
                    FROM operator_lines ol
                    JOIN users u ON u.user_id = ol.operator_id
                    WHERE ol.line_id = l.line_id
                      AND EXISTS (SELECT 1 FROM group_memberships gm WHERE gm.user_id = u.user_id AND gm.role = 'Operator')
                ) AS operator_count,
                COALESCE(
                    (
                        SELECT STRING_AGG(op.operator_label, ' | ' ORDER BY op.operator_label)
                        FROM (
                            SELECT DISTINCT CONCAT_WS(
                                ' ',
                                u.first_name,
                                u.last_name,
                                CONCAT('(@', u.username, ')')
                            ) AS operator_label
                            FROM operator_lines ol
                            JOIN users u ON u.user_id = ol.operator_id
                            WHERE ol.line_id = l.line_id
                              AND EXISTS (SELECT 1 FROM group_memberships gm WHERE gm.user_id = u.user_id AND gm.role = 'Operator')
                        ) AS op
                    ),
                    ''
                ) AS assigned_operator_names,
                COALESCE(
                    (
                        SELECT ARRAY_AGG(op.operator_label ORDER BY op.operator_label)
                        FROM (
                            SELECT DISTINCT CONCAT_WS(
                                ' ',
                                u.first_name,
                                u.last_name,
                                CONCAT('(@', u.username, ')')
                            ) AS operator_label
                            FROM operator_lines ol
                            JOIN users u ON u.user_id = ol.operator_id
                            WHERE ol.line_id = l.line_id
                              AND EXISTS (SELECT 1 FROM group_memberships gm WHERE gm.user_id = u.user_id AND gm.role = 'Operator')
                        ) AS op
                    ),
                    ARRAY[]::text[]
                ) AS assigned_operator_labels,
                COALESCE(
                    (
                        SELECT ARRAY_AGG(op.username ORDER BY op.operator_label, op.operator_id)
                        FROM (
                            SELECT DISTINCT
                                u.user_id AS operator_id,
                                u.username,
                                CONCAT_WS(
                                    ' ',
                                    u.first_name,
                                    u.last_name,
                                    CONCAT('(@', u.username, ')')
                                ) AS operator_label
                            FROM operator_lines ol
                            JOIN users u ON u.user_id = ol.operator_id
                            WHERE ol.line_id = l.line_id
                              AND EXISTS (SELECT 1 FROM group_memberships gm WHERE gm.user_id = u.user_id AND gm.role = 'Operator')
                        ) AS op
                    ),
                    ARRAY[]::text[]
                ) AS assigned_operator_usernames,
                COALESCE(
                    (
                        SELECT ARRAY_AGG(op.operator_id ORDER BY op.operator_label, op.operator_id)
                        FROM (
                            SELECT DISTINCT
                                u.user_id AS operator_id,
                                CONCAT_WS(
                                    ' ',
                                    u.first_name,
                                    u.last_name,
                                    CONCAT('(@', u.username, ')')
                                ) AS operator_label
                            FROM operator_lines ol
                            JOIN users u ON u.user_id = ol.operator_id
                            WHERE ol.line_id = l.line_id
                              AND EXISTS (SELECT 1 FROM group_memberships gm WHERE gm.user_id = u.user_id AND gm.role = 'Operator')
                        ) AS op
                    ),
                    ARRAY[]::int[]
                ) AS assigned_operator_ids,
                g.name AS group_name
            FROM lines l
            LEFT JOIN users u_ret ON u_ret.user_id = l.retired_by
            LEFT JOIN groups g ON g.group_id = l.group_id
            WHERE {group_clause} (
                CASE %s
                    WHEN 'all' THEN TRUE
                    WHEN 'retired' THEN l.is_retired = TRUE
                    ELSE l.is_retired = FALSE
                END
            )
            ORDER BY l.is_retired ASC, l.line_id DESC
            """,
            group_params + (line_filter,)
        )
        lines = cursor.fetchall()

        cursor.execute(
            f"""
            SELECT l.line_id, COUNT(t.is_retired) as has_active_trap
            FROM lines AS l
            LEFT JOIN traps as t ON t.line_id = l.line_id
            WHERE {group_clause} t.is_retired = FALSE
            GROUP BY l.line_id
            """,
            group_params
        )
        line_has_active_traps = cursor.fetchall()
        active_trap_line_ids = set(
            line['line_id'] for line in line_has_active_traps
            if line['has_active_trap'] > 0
        )

        cursor.execute(
            f"""
            SELECT l.line_id, COUNT(bs.station_id) AS has_active_station
            FROM lines AS l
            LEFT JOIN bait_stations AS bs ON bs.line_id = l.line_id
            WHERE {group_clause} bs.is_retired = FALSE
            GROUP BY l.line_id
            """,
            group_params
        )
        active_station_line_ids = set(
            row['line_id'] for row in cursor.fetchall()
            if row['has_active_station'] > 0
        )

        cursor.execute(
            f"""
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
            WHERE {group_clause} (
                CASE %s
                    WHEN 'all' THEN TRUE
                    WHEN 'retired' THEN l.is_retired = TRUE
                    ELSE l.is_retired = FALSE
                END
              )
              AND t.trap_id IS NOT NULL
              AND t.latitude IS NOT NULL
              AND t.longitude IS NOT NULL
              AND (
                CASE %s
                    WHEN 'all' THEN TRUE
                    WHEN 'retired' THEN t.is_retired = TRUE
                    ELSE t.is_retired = FALSE
                END
              )
            ORDER BY l.name ASC, t.code ASC
            """,
            group_params + (line_filter, line_filter)
        )
        trap_rows = cursor.fetchall()

        cursor.execute(
            f"""
            SELECT
                l.line_id,
                l.name AS line_name,
                l.is_retired AS line_is_retired,
                bs.station_id,
                bs.code,
                bs.station_type,
                bs.latitude,
                bs.longitude,
                bs.is_retired AS station_is_retired
            FROM lines l
            JOIN bait_stations bs ON bs.line_id = l.line_id
            WHERE {group_clause} (
                CASE %s
                    WHEN 'all' THEN TRUE
                    WHEN 'retired' THEN l.is_retired = TRUE
                    ELSE l.is_retired = FALSE
                END
              )
              AND bs.latitude IS NOT NULL
              AND bs.longitude IS NOT NULL
              AND (
                CASE %s
                    WHEN 'all' THEN TRUE
                    WHEN 'retired' THEN bs.is_retired = TRUE
                    ELSE bs.is_retired = FALSE
                END
              )
            ORDER BY l.name ASC, bs.code ASC
            """,
            group_params + (line_filter, line_filter)
        )
        station_rows = cursor.fetchall()

    map_traps = []
    for trap in trap_rows:
        detail_url = url_for('line_detail', line_id=trap['line_id'])
        if line_filter != 'all':
            detail_url = f"{detail_url}?filter={line_filter}"

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
            'is_station': False,
            'detail_url': detail_url
        })

    for station in station_rows:
        detail_url = url_for('line_detail', line_id=station['line_id'])
        if line_filter != 'all':
            detail_url = f"{detail_url}?filter={line_filter}"

        map_traps.append({
            'line_id': station['line_id'],
            'line_name': station['line_name'],
            'line_is_retired': station['line_is_retired'],
            'trap_id': None,
            'code': station['code'],
            'trap_type': station['station_type'],
            'latitude': float(station['latitude']),
            'longitude': float(station['longitude']),
            'trap_is_retired': station['station_is_retired'],
            'is_station': True,
            'detail_url': detail_url
        })

    for line in lines:
        line['assigned_operator_labels'] = line.get('assigned_operator_labels') or []
        line['assigned_operator_usernames'] = line.get('assigned_operator_usernames') or []
        line['assigned_operator_ids'] = line.get('assigned_operator_ids') or []
        line['assigned_operators'] = [
            {
                'user_id': operator_id,
                'username': username,
                'label': label
            }
            for operator_id, username, label in zip(
                line['assigned_operator_ids'],
                line['assigned_operator_usernames'],
                line['assigned_operator_labels']
            )
        ]

    available_types = sorted({
        line['type'] for line in lines
        if line.get('type')
    })
    available_operators = sorted({
        operator_label
        for line in lines
        for operator_label in line['assigned_operator_labels']
    })

    return render_template(
        'lines/index.html',
        lines=lines,
        line_filter=line_filter,
        operator_filter=operator_filter,
        map_traps=map_traps,
        linz_api_key=linz_api_key,
        active_trap_line_ids=active_trap_line_ids,
        active_station_line_ids=active_station_line_ids,
        available_types=available_types,
        available_operators=available_operators,
        line_colours=LINE_COLOURS
    )


@app.route('/lines/<int:line_id>')
@role_required()
def line_detail(line_id):
    """Display a single line and all its traps or bait stations."""
    line_filter = request.args.get('filter', 'all')
    if line_filter not in ('all', 'active', 'retired'):
        line_filter = 'all'

    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT l.line_id, l.name, l.type, l.is_retired, l.group_id,
                   l.retired_at,
                   u_ret.username AS retired_by_username
            FROM lines l
            LEFT JOIN users u_ret ON u_ret.user_id = l.retired_by
            WHERE l.line_id = %s
            """,
            (line_id,)
        )
        line = cursor.fetchone()

    if line and not is_super_admin_mode() and not is_support_tech_mode() \
            and line['group_id'] != session.get('group_id'):
        flash('Line not found in your group.', 'danger')
        return redirect(url_for('lines_index'))

    if line and is_support_tech_mode():
        logger.info('Support Technician %d viewed line %d', session['user_id'], line_id)

    traps = []
    bait_stations = []
    operators = []
    trap_markers = []
    station_markers = []

    if line:
        with db.get_cursor() as cursor:
            if line['type'] == 'Bait Station':
                cursor.execute(
                    """
                    SELECT
                        bs.station_id,
                        bs.code,
                        bs.station_type,
                        bs.other_type,
                        bs.latitude,
                        bs.longitude,
                        bs.is_retired,
                        bs.retired_at,
                        u_ret.username AS retired_by_username
                    FROM bait_stations bs
                    LEFT JOIN users u_ret ON u_ret.user_id = bs.retired_by
                    WHERE bs.line_id = %s
                      AND (
                        CASE %s
                            WHEN 'all' THEN TRUE
                            WHEN 'retired' THEN bs.is_retired = TRUE
                            ELSE bs.is_retired = FALSE
                        END
                      )
                    ORDER BY bs.code ASC
                    """,
                    (line_id, line_filter)
                )
                bait_stations = cursor.fetchall()
                for bs in bait_stations:
                    if bs.get('latitude') is None or bs.get('longitude') is None:
                        continue
                    station_markers.append({
                        'station_id': bs['station_id'],
                        'code': bs['code'],
                        'station_type': bs['station_type'],
                        'other_type': bs['other_type'],
                        'latitude': float(bs['latitude']),
                        'longitude': float(bs['longitude']),
                        'is_retired': bs['is_retired']
                    })
            else:
                cursor.execute(
                    """
                    SELECT
                        t.trap_id,
                        t.code,
                        t.trap_type,
                        t.latitude,
                        t.longitude,
                        t.is_retired,
                        t.retired_at,
                        u_ret.username AS retired_by_username
                    FROM traps t
                    LEFT JOIN users u_ret ON u_ret.user_id = t.retired_by
                    WHERE t.line_id = %s
                      AND (
                        CASE %s
                            WHEN 'all' THEN TRUE
                            WHEN 'retired' THEN t.is_retired = TRUE
                            ELSE t.is_retired = FALSE
                        END
                      )
                    ORDER BY t.code ASC
                    """,
                    (line_id, line_filter)
                )
                traps = cursor.fetchall()
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

            cursor.execute(
                """
                SELECT u.user_id, u.username, u.first_name, u.last_name
                FROM operator_lines ol
                JOIN users u ON u.user_id = ol.operator_id
                WHERE ol.line_id = %s
                  AND EXISTS (
                      SELECT 1 FROM group_memberships gm
                      WHERE gm.user_id = u.user_id AND gm.role = 'Operator'
                  )
                ORDER BY u.first_name ASC, u.last_name ASC
                """,
                (line_id,)
            )
            operators = cursor.fetchall()

    trap_types = fetch_active_lookup(db, 'trap_types')
    bait_station_types = fetch_active_lookup(db, 'bait_station_types')

    return render_template(
        'lines/detail.html',
        line=line,
        traps=traps,
        bait_stations=bait_stations,
        operators=operators,
        line_filter=line_filter,
        trap_markers=trap_markers,
        station_markers=station_markers,
        linz_api_key=linz_api_key,
        trap_types=trap_types,
        bait_station_types=bait_station_types,
        line_colours=LINE_COLOURS
    )
