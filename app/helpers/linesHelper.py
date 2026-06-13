from flask import session
from app.utils import is_super_admin_mode


def build_map_traps(trap_rows, station_rows, make_detail_url):
    map_traps = []
    for trap in trap_rows:
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
            'detail_url': make_detail_url(trap['line_id'])
        })
    for station in station_rows:
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
            'detail_url': make_detail_url(station['line_id'])
        })
    return map_traps


def _effective_group_id():
    """Return the group_id to use for ownership checks, or None to skip filtering.

    Returns None only for Super Admin in platform-wide mode (no group context).
    For all other roles with no group_id (e.g. Support Technician), returns a
    sentinel that forces the SQL filter to match nothing, denying access.
    """
    if is_super_admin_mode():
        return None
    return session.get('group_id')


def fetch_line_for_group(db, line_id):
    """Return the full line row if accessible, None if not found or wrong group.

    Super Admin in platform-wide mode bypasses the group filter.
    Any other role without a group_id in session is denied (returns None).
    """
    group_id = _effective_group_id()
    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT * FROM lines WHERE line_id = %s AND (%s::int IS NULL OR group_id = %s::int)',
            (line_id, group_id, group_id)
        )
        return cursor.fetchone()


def fetch_trap_for_group(db, trap_id):
    """Return trap row (with group_id from its line) if accessible, else None.

    Super Admin in platform-wide mode bypasses the group filter.
    Any other role without a group_id in session is denied (returns None).
    """
    group_id = _effective_group_id()
    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT t.trap_id, t.line_id, t.code, t.trap_type,
                   t.latitude, t.longitude, t.is_retired, l.group_id
            FROM traps t
            JOIN lines l ON l.line_id = t.line_id
            WHERE t.trap_id = %s AND (%s::int IS NULL OR l.group_id = %s::int)
            """,
            (trap_id, group_id, group_id)
        )
        return cursor.fetchone()


def fetch_bait_station_for_group(db, station_id):
    """Return the bait station row if accessible, None if not found or wrong group.

    Super Admin in platform-wide mode bypasses the group filter.
    Any other role without a group_id in session is denied (returns None).
    """
    group_id = _effective_group_id()
    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT bs.station_id
            FROM bait_stations bs
            JOIN lines l ON l.line_id = bs.line_id
            WHERE bs.station_id = %s AND (%s::int IS NULL OR l.group_id = %s::int)
            """,
            (station_id, group_id, group_id)
        )
        return cursor.fetchone()
