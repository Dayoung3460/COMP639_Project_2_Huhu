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
