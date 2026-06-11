"""home.py — Public home page route."""

import os

from flask import render_template, url_for
from app import app, db

linz_api_key = os.getenv('LINZ_API_KEY', '')

# NZ bounding box for the schematic homepage map. Real trap coordinates
# are projected linearly into 0–100% positions inside the map panel.
_NZ_LNG_MIN, _NZ_LNG_MAX = 166.0, 179.0
_NZ_LAT_MIN, _NZ_LAT_MAX = -47.5, -34.5


def _map_position(lat, lng):
    """Project a lat/lng into schematic-map percentages (x right, y down)."""
    if lat is None or lng is None:
        return None, None
    x = (float(lng) - _NZ_LNG_MIN) / (_NZ_LNG_MAX - _NZ_LNG_MIN) * 100
    y = (_NZ_LAT_MAX - float(lat)) / (_NZ_LAT_MAX - _NZ_LAT_MIN) * 100
    return round(max(0, min(100, x)), 1), round(max(0, min(100, y)), 1)


@app.route('/')
def index():
    """
    Public homepage.

    Shows platform-wide stats aggregated across all public groups, plus a
    browseable grid of ALL groups (public AND private — per the brief,
    private groups are visible but content is gated). Logged-in users see
    slightly different CTAs but the page is otherwise the same.
    """
    stats = {
        'total_groups':  0,
        'total_traps':   0,
        'total_catches': 0,
    }
    public_groups = []
    latest_catches = []
    line_names = []

    try:
        with db.get_cursor() as cursor:

            # ── Platform stats — public groups only ───────────────────────
            cursor.execute('''
                SELECT COUNT(*) AS count
                FROM groups
                WHERE is_public = TRUE
            ''')
            stats['total_groups'] = cursor.fetchone()['count']

            cursor.execute('''
                SELECT COUNT(*) AS count
                FROM traps t
                JOIN lines l ON t.line_id = l.line_id
                JOIN groups g ON l.group_id = g.group_id
                WHERE g.is_public = TRUE
                  AND t.is_retired = FALSE
                  AND l.is_retired = FALSE
            ''')
            stats['total_traps'] = cursor.fetchone()['count']

            cursor.execute('''
                SELECT COUNT(*) AS count
                FROM trap_catches tc
                JOIN traps t ON tc.trap_id = t.trap_id
                JOIN lines l ON t.line_id = l.line_id
                JOIN groups g ON l.group_id = g.group_id
                WHERE g.is_public = TRUE
                  AND tc.species_caught != 'None'
            ''')
            stats['total_catches'] = cursor.fetchone()['count']

            # ── All groups list — for the browse grid ────────────────────
            # Per the brief: private groups must be VISIBLE in the list.
            # Access to private group content is gated on the landing page.
            cursor.execute('''
                SELECT
                    g.group_id,
                    g.name,
                    g.description,
                    g.location,
                    g.is_public,
                    g.tile_image,
                    g.color_theme,
                    g.created_at,
                    (SELECT COUNT(*) FROM group_memberships
                       WHERE group_id = g.group_id) AS member_count,
                    (SELECT COUNT(*) FROM lines
                       WHERE group_id = g.group_id AND is_retired = FALSE) AS line_count,
                    (SELECT COUNT(*)
                       FROM trap_catches tc
                       JOIN traps t ON tc.trap_id = t.trap_id
                       JOIN lines l ON t.line_id = l.line_id
                      WHERE l.group_id = g.group_id
                        AND tc.species_caught != 'None') AS catch_count,
                    (SELECT AVG(t.latitude)
                       FROM traps t
                       JOIN lines l ON t.line_id = l.line_id
                      WHERE l.group_id = g.group_id) AS avg_lat,
                    (SELECT AVG(t.longitude)
                       FROM traps t
                       JOIN lines l ON t.line_id = l.line_id
                      WHERE l.group_id = g.group_id) AS avg_lng
                FROM groups g
                ORDER BY member_count DESC, g.created_at ASC
            ''')
            public_groups = cursor.fetchall()

            # ── Latest catches — real events for the hero ticker ─────────
            cursor.execute('''
                SELECT
                    tc.species_caught,
                    tc.date,
                    l.name AS line_name
                FROM trap_catches tc
                JOIN traps t ON tc.trap_id = t.trap_id
                JOIN lines l ON t.line_id = l.line_id
                JOIN groups g ON l.group_id = g.group_id
                WHERE g.is_public = TRUE
                  AND tc.species_caught != 'None'
                ORDER BY tc.date DESC
                LIMIT 6
            ''')
            latest_catches = cursor.fetchall()

            # ── Line names — label the decorative hero canvas lines ──────
            cursor.execute('''
                SELECT l.name
                FROM lines l
                JOIN groups g ON l.group_id = g.group_id
                WHERE g.is_public = TRUE AND l.is_retired = FALSE
                ORDER BY l.line_id ASC
                LIMIT 6
            ''')
            line_names = [row['name'] for row in cursor.fetchall()]

    except Exception:
        # Leave defaults if DB is unavailable; page still renders.
        pass

    # AC #6: empty state fires when there are zero PUBLIC groups,
    # regardless of how many private ones exist.
    has_public_groups = any(g['is_public'] for g in public_groups)

    # ── Browse data for the client-side filter/sort/map controls ─────────
    # Region = the part of the free-text location after the last comma
    # ("Lincoln, Canterbury" → "Canterbury").
    groups_json = []
    for g in public_groups:
        location = (g['location'] or '').strip()
        region = location.rsplit(',', 1)[-1].strip() if location else ''
        x, y = _map_position(g['avg_lat'], g['avg_lng'])
        groups_json.append({
            'id':      g['group_id'],
            'name':    g['name'],
            'blurb':   g['description'] or 'A volunteer-led conservation group.',
            'location': location,
            'region':  region,
            'vis':     'public' if g['is_public'] else 'private',
            'members': g['member_count'],
            'lines':   g['line_count'],
            'catches': g['catch_count'],
            'founded': g['created_at'].year if g['created_at'] else None,
            'x':       x,
            'y':       y,
            'lat':     round(float(g['avg_lat']), 5) if g['avg_lat'] is not None else None,
            'lng':     round(float(g['avg_lng']), 5) if g['avg_lng'] is not None else None,
            'tile':    (url_for('static', filename='images/uploads/' + g['tile_image'])
                        if g['tile_image'] else None),
            'accent':  g['color_theme'],
            'url':     url_for('group_landing', group_id=g['group_id']),
        })

    ticker_json = [{
        'species': c['species_caught'],
        'line':    c['line_name'],
        'at':      c['date'].isoformat(),
    } for c in latest_catches]

    return render_template(
        'home.html',
        stats=stats,
        public_groups=public_groups,
        has_public_groups=has_public_groups,
        groups_json=groups_json,
        ticker_json=ticker_json,
        line_names=line_names,
        linz_api_key=linz_api_key,
    )


@app.route('/documentation')
def documentation():
    return render_template('documentation.html')


@app.route('/privacy')
def privacy():
    """Public privacy policy page. Reachable from both the in-app
    site-footer (logged-in surface) and from deep links. Extends
    base.html so logged-in users see the in-app chrome and logged-out
    users get the public navbar — both surfaces should be able to
    read the policy."""
    return render_template('privacy.html')


@app.route('/terms')
def terms():
    """Public terms of service page. Same access pattern as /privacy."""
    return render_template('terms.html')


@app.route('/accessibility')
def accessibility():
    """Public accessibility statement. Same access pattern as /privacy."""
    return render_template('accessibility.html')


@app.route('/cookies')
def cookies():
    """Public cookie policy. Same access pattern as /privacy."""
    return render_template('cookies.html')