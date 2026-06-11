"""
map3d.py - Innovation Epic: 3D Terrain Map (P2-106)
COMP639 Group Project 2, Team Huhu - Lincoln University

Stack choice: Three.js r128, loaded from cdnjs (already on the project's CDN
allow-list per the artifacts spec). Free, no commercial API key, runs in any
modern browser. Terrain heights are derived from the open Open-Elevation API
on first load and cached in-memory in the JS layer so re-opens are instant
on PythonAnywhere.

Routes
------
GET  /map3d                        -- main page, current group
GET  /map3d/data/group.json        -- markers + colour scale + line metadata
GET  /map3d/data/line/<id>.json    -- one line with its asset sequence + bbox
GET  /map3d/data/operational-area.json -- the group's polygon as GeoJSON
POST /map3d/prefs                  -- save show_vegetation + activity_days
"""

import json
import logging
from datetime import date, datetime, timedelta

from flask import (
    abort, jsonify, redirect, render_template, request, session, url_for,
    flash,
)

from app import app, db
from app.utils import role_required

logger = logging.getLogger(__name__)

VIEW_ROLES = ('Observer', 'Operator', 'Group Coordinator', 'Super Admin', 'Support Technician')


# ---- Helpers --------------------------------------------------------------

def _active_group_id():
    gid = session.get('group_id')
    if not gid:
        flash('Select a group to use the 3D map.', 'warning')
        abort(redirect(url_for('select_group')))
    return gid


def _data_group_id():
    """Group id for the JSON data endpoints.

    Normal roles are scoped to their active session group. Cross-group
    staff (Super Admin + Support Technician) have no session group, so
    -- like the reports page -- they pass ?group_id= and may view any
    group's map. Without this, the JS fetch gets redirected to
    /select-group and the stage hangs at "loading elevation…" forever.
    """
    if session.get('group_role') in ('Super Admin', 'Support Technician'):
        gid = request.args.get('group_id', type=int)
        if not gid:
            abort(400)
        return gid
    return _active_group_id()


def _load_prefs(user_id):
    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT show_vegetation, activity_days FROM map3d_view_prefs WHERE user_id = %s',
            (user_id,)
        )
        row = cursor.fetchone()
    return {
        'show_vegetation': True if not row else bool(row['show_vegetation']),
        'activity_days':   30   if not row else int(row['activity_days']),
    }


def _log_view(user_id, group_id, line_id=None):
    try:
        with db.get_cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO map3d_view_log (user_id, group_id, line_id)
                VALUES (%s, %s, %s)
                """,
                (user_id, group_id, line_id)
            )
    except Exception:
        logger.exception('Failed to log 3D view')


def _activity_colour(catch_count):
    """Sequential green-to-red ramp for the marker colour-coding legend."""
    if catch_count <= 0:  return '#9ec5fe'   # cool blue -- no recent activity
    if catch_count == 1:  return '#a3cfbb'
    if catch_count <= 3:  return '#ffe69c'
    if catch_count <= 6:  return '#fd9843'
    return '#dc3545'                         # hot red -- 7+ catches in window


# ---- Pages ----------------------------------------------------------------

@app.route('/map3d')
@role_required(*VIEW_ROLES)
def map3d_index():
    role = session.get('group_role')
    is_super_admin = role == 'Super Admin'
    # Cross-group staff (Super Admin + Support Technician) have no
    # session group, so they get the same `?group_id=` picker. The
    # template's existing `is_super_admin` flag drives that picker —
    # treat TS as super-admin-equivalent for this view only.
    is_cross_group = role in ('Super Admin', 'Support Technician')
    prefs = _load_prefs(session['user_id'])

    all_groups = []
    if is_cross_group:
        with db.get_cursor() as cursor:
            cursor.execute(
                'SELECT group_id, name FROM groups WHERE is_active = TRUE ORDER BY name'
            )
            all_groups = cursor.fetchall()
        valid_ids = {g['group_id'] for g in all_groups}
        group_id = request.args.get('group_id', type=int)
        if group_id not in valid_ids:
            group_id = None
        if not group_id:
            # No group chosen yet -- show the selector prompt, no map.
            return render_template(
                'map3d/index.html',
                prefs=prefs, lines=[], assigned_lines=[], is_operator=False,
                is_super_admin=True, all_groups=all_groups,
                selected_group_id=None, group_name='', no_group_selected=True,
            )
        group_name = next((g['name'] for g in all_groups if g['group_id'] == group_id), '')
    else:
        group_id = _active_group_id()
        group_name = session.get('group_name', '')

    _log_view(session['user_id'], group_id)
    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT l.line_id, l.name, l.type
              FROM lines l
             WHERE l.group_id = %s AND l.is_retired = FALSE
             ORDER BY l.name
            """,
            (group_id,)
        )
        lines = cursor.fetchall()
        if session.get('group_role') == 'Operator':
            cursor.execute(
                """
                SELECT ol.line_id FROM operator_lines ol
                 WHERE ol.operator_id = %s
                """,
                (session['user_id'],)
            )
            assigned_ids = {r['line_id'] for r in cursor.fetchall()}
            assigned_lines = [l for l in lines if l['line_id'] in assigned_ids]
        else:
            assigned_lines = []
    return render_template(
        'map3d/index.html',
        prefs=prefs,
        lines=lines,
        assigned_lines=assigned_lines,
        is_operator=session.get('group_role') == 'Operator',
        # `is_super_admin` here gates the group-picker dropdown in the
        # template — Support Technician needs the same picker (no session
        # group), so flip it true for any cross-group viewer.
        is_super_admin=is_cross_group,
        all_groups=all_groups,
        selected_group_id=group_id,
        group_name=group_name,
        no_group_selected=False,
    )


# ---- JSON data endpoints --------------------------------------------------

@app.route('/map3d/data/operational-area.json')
@role_required(*VIEW_ROLES)
def map3d_operational_area():
    group_id = _data_group_id()
    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT geojson FROM group_operational_areas WHERE group_id = %s',
            (group_id,)
        )
        row = cursor.fetchone()
    if not row:
        return jsonify({'geojson': None})
    try:
        geo = json.loads(row['geojson'])
    except Exception:
        geo = None
    return jsonify({'geojson': geo})


@app.route('/map3d/data/group.json')
@role_required(*VIEW_ROLES)
def map3d_group_data():
    group_id = _data_group_id()
    days = max(1, min(365, request.args.get('days', 30, type=int)))
    cutoff = date.today() - timedelta(days=days)

    with db.get_cursor() as cursor:
        # Operators per line (one line can have several; one operator can serve
        # several lines). Group by line_id so the asset rows can attach their
        # operator names without an N+1 query.
        cursor.execute(
            """
            SELECT ol.line_id, u.first_name, u.last_name
              FROM operator_lines ol
              JOIN users u ON u.user_id = ol.operator_id
              JOIN lines l ON l.line_id = ol.line_id
             WHERE l.group_id = %s
             ORDER BY u.last_name, u.first_name
            """,
            (group_id,)
        )
        line_to_operators = {}
        for r in cursor.fetchall():
            name = f"{(r['first_name'] or '').strip()} {(r['last_name'] or '').strip()}".strip()
            if not name:
                continue
            line_to_operators.setdefault(r['line_id'], []).append(name)

        # Traps
        cursor.execute(
            """
            SELECT t.trap_id AS asset_id, 'trap' AS asset_type,
                   t.code, t.trap_type AS sub_type,
                   t.line_id, l.name AS line_name, l.type AS line_type,
                   t.latitude, t.longitude, t.is_retired,
                   (SELECT COUNT(*) FROM trap_catches tc
                     WHERE tc.trap_id = t.trap_id
                       AND tc.date::date >= %s
                       AND tc.species_caught != 'None') AS recent_catches,
                   (SELECT MAX(date) FROM trap_catches WHERE trap_id = t.trap_id) AS last_check
              FROM traps t
              JOIN lines l ON l.line_id = t.line_id
             WHERE l.group_id = %s
             ORDER BY l.name, t.code
            """,
            (cutoff, group_id)
        )
        traps = cursor.fetchall()

        cursor.execute(
            """
            SELECT bs.station_id AS asset_id, 'bait_station' AS asset_type,
                   bs.code, bs.station_type AS sub_type,
                   bs.line_id, l.name AS line_name, l.type AS line_type,
                   bs.latitude, bs.longitude, bs.is_retired,
                   (SELECT COUNT(*) FROM bait_station_records r
                     WHERE r.station_id = bs.station_id
                       AND r.date::date >= %s) AS recent_records,
                   (SELECT MAX(date) FROM bait_station_records WHERE station_id = bs.station_id) AS last_check
              FROM bait_stations bs
              JOIN lines l ON l.line_id = bs.line_id
             WHERE l.group_id = %s
             ORDER BY l.name, bs.code
            """,
            (cutoff, group_id)
        )
        stations = cursor.fetchall()

        cursor.execute(
            """
            SELECT line_id, name, type FROM lines
             WHERE group_id = %s AND is_retired = FALSE
             ORDER BY name
            """,
            (group_id,)
        )
        lines = cursor.fetchall()

    def asset_to_json(r):
        n = r['recent_catches'] if 'recent_catches' in r else r['recent_records']
        return {
            'asset_id':    r['asset_id'],
            'asset_type':  r['asset_type'],
            'code':        r['code'],
            'sub_type':    r['sub_type'],
            'line_id':     r['line_id'],
            'line_name':   r['line_name'],
            'line_type':   r['line_type'],
            'operators':   line_to_operators.get(r['line_id'], []),
            'latitude':    float(r['latitude']) if r['latitude'] is not None else None,
            'longitude':   float(r['longitude']) if r['longitude'] is not None else None,
            'is_retired':  bool(r['is_retired']),
            'activity':    int(n or 0),
            'colour':      _activity_colour(int(n or 0)),
            'last_check':  r['last_check'].isoformat() if r['last_check'] else None,
        }

    return jsonify({
        'days':   days,
        'assets': [asset_to_json(r) for r in traps] + [asset_to_json(r) for r in stations],
        'lines':  [{'line_id': l['line_id'], 'name': l['name'], 'type': l['type']} for l in lines],
        'legend': [
            {'label': 'No recent activity',  'min': 0, 'colour': '#9ec5fe'},
            {'label': '1 record',            'min': 1, 'colour': '#a3cfbb'},
            {'label': '2-3 records',         'min': 2, 'colour': '#ffe69c'},
            {'label': '4-6 records',         'min': 4, 'colour': '#fd9843'},
            {'label': '7+ records (hotspot)','min': 7, 'colour': '#dc3545'},
        ],
    })


@app.route('/map3d/data/line/<int:line_id>.json')
@role_required(*VIEW_ROLES)
def map3d_line_data(line_id):
    group_id = _data_group_id()
    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT * FROM lines WHERE line_id = %s AND group_id = %s',
            (line_id, group_id)
        )
        line = cursor.fetchone()
    if not line:
        abort(404)
    # Operator may only fetch their assigned lines.
    if session.get('group_role') == 'Operator':
        with db.get_cursor() as cursor:
            cursor.execute(
                'SELECT 1 FROM operator_lines WHERE operator_id = %s AND line_id = %s LIMIT 1',
                (session['user_id'], line_id)
            )
            if not cursor.fetchone():
                abort(403)

    table = 'traps' if line['type'] == 'Trap' else 'bait_stations'
    id_col = 'trap_id' if line['type'] == 'Trap' else 'station_id'
    type_col = 'trap_type' if line['type'] == 'Trap' else 'station_type'
    with db.get_cursor() as cursor:
        cursor.execute(
            f"""
            SELECT a.{id_col} AS asset_id, a.code, a.{type_col} AS sub_type,
                   a.latitude, a.longitude
              FROM {table} a
             WHERE a.line_id = %s AND a.is_retired = FALSE
               AND a.latitude IS NOT NULL AND a.longitude IS NOT NULL
             ORDER BY a.code
            """,
            (line_id,)
        )
        assets = cursor.fetchall()

    if assets:
        lats = [float(a['latitude']) for a in assets]
        lons = [float(a['longitude']) for a in assets]
        bbox = {'minLat': min(lats), 'maxLat': max(lats),
                'minLon': min(lons), 'maxLon': max(lons)}
    else:
        bbox = None

    _log_view(session['user_id'], group_id, line_id=line_id)

    return jsonify({
        'line_id': line['line_id'],
        'name':    line['name'],
        'type':    line['type'],
        'bbox':    bbox,
        'assets':  [{
            'asset_id':  a['asset_id'],
            'code':      a['code'],
            'sub_type':  a['sub_type'],
            'latitude':  float(a['latitude']),
            'longitude': float(a['longitude']),
        } for a in assets],
    })


@app.route('/map3d/prefs', methods=['POST'])
@role_required(*VIEW_ROLES)
def map3d_save_prefs():
    show_veg = request.form.get('show_vegetation') == 'true'
    try:
        days = max(1, min(365, int(request.form.get('activity_days', 30))))
    except (TypeError, ValueError):
        days = 30
    with db.get_cursor() as cursor:
        cursor.execute(
            """
            INSERT INTO map3d_view_prefs (user_id, show_vegetation, activity_days)
            VALUES (%s, %s, %s)
            ON CONFLICT (user_id) DO UPDATE
               SET show_vegetation = EXCLUDED.show_vegetation,
                   activity_days   = EXCLUDED.activity_days,
                   updated_at      = CURRENT_TIMESTAMP
            """,
            (session['user_id'], show_veg, days)
        )
    return jsonify({'ok': True, 'show_vegetation': show_veg, 'activity_days': days})
