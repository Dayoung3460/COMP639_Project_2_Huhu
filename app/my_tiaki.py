"""my_tiaki.py — Cross-group personal home page.

Route:
    GET /my-tiaki

The 'My Tiaki' surface aggregates a logged-in user's activity, groups,
and requests across every group they belong to. Distinct from the
per-group dashboards under /coordinator, /operator, /observer.

The feed is a UNION of the four activity sources that already exist in
the schema — trap catches, bait station records, incidental
observations, and member-joined events — newest first. There is no
posts/likes/comments schema, so the page shows only real recorded
activity. Notifications in the sidebar come from the context
processor's nav_notifications; the greeting and 'You' card use
nav_first_name / nav_full_name / nav_profile_photo.
"""

from datetime import datetime

from flask import render_template, session
from app import app, db, _compute_initials
from app.utils import role_required

FEED_LIMIT = 30

# One NULL-padded shape across all four sources so a single ORDER BY /
# LIMIT in SQL gives the exact newest-N (a Python merge would need to
# over-fetch every branch). Enums are cast ::text and padding columns
# typed explicitly so Postgres can resolve the union column types.
_FEED_SQL = '''
    WITH my_groups AS (
        SELECT gm.group_id
        FROM group_memberships gm
        JOIN groups g ON g.group_id = gm.group_id
        WHERE gm.user_id = %(uid)s AND g.is_active = TRUE
    )
    SELECT * FROM (
        -- Trap catches / checks
        SELECT 'catch' AS kind, tc.date AS ts, tc.recorded_by_id AS actor_id,
               u.first_name, u.last_name, u.username, u.profile_photo,
               g.group_id, g.name AS group_name, g.color_theme,
               l.name AS line_name, t.code AS place_code,
               tc.species_caught AS detail_a, tc.bait_type AS detail_b,
               tc.status AS detail_c,
               NULL::numeric AS num_a, NULL::numeric AS num_b
        FROM trap_catches tc
        JOIN traps  t ON t.trap_id  = tc.trap_id
        JOIN lines  l ON l.line_id  = t.line_id
        JOIN groups g ON g.group_id = l.group_id
        LEFT JOIN users u ON u.user_id = tc.recorded_by_id
        WHERE l.group_id IN (SELECT group_id FROM my_groups)

        UNION ALL
        -- Bait station records
        SELECT 'bait', bsr.date, bsr.recorded_by_id,
               u.first_name, u.last_name, u.username, u.profile_photo,
               g.group_id, g.name, g.color_theme,
               l.name, bs.code,
               bsr.active_ingredient, bsr.formulation, NULL::text,
               bsr.bait_remaining, bsr.bait_added
        FROM bait_station_records bsr
        JOIN bait_stations bs ON bs.station_id = bsr.station_id
        JOIN lines  l ON l.line_id  = bs.line_id
        JOIN groups g ON g.group_id = l.group_id
        LEFT JOIN users u ON u.user_id = bsr.recorded_by_id
        WHERE l.group_id IN (SELECT group_id FROM my_groups)

        UNION ALL
        -- Incidental observations
        SELECT 'observation', io.date, io.operator_id,
               u.first_name, u.last_name, u.username, u.profile_photo,
               g.group_id, g.name, g.color_theme,
               l.name, t.code,
               io.observation_type::text, io.notes, NULL::text,
               NULL::numeric, NULL::numeric
        FROM incidental_observations io
        JOIN lines  l ON l.line_id  = io.line_id
        JOIN groups g ON g.group_id = l.group_id
        LEFT JOIN traps t ON t.trap_id = io.trap_id
        LEFT JOIN users u ON u.user_id = io.operator_id
        WHERE l.group_id IN (SELECT group_id FROM my_groups)

        UNION ALL
        -- Member joined
        SELECT 'member_joined', gm2.joined_at, gm2.user_id,
               u.first_name, u.last_name, u.username, u.profile_photo,
               g.group_id, g.name, g.color_theme,
               NULL::varchar, NULL::varchar,
               gm2.role::text, NULL::text, NULL::text,
               NULL::numeric, NULL::numeric
        FROM group_memberships gm2
        JOIN groups g ON g.group_id = gm2.group_id
        JOIN users  u ON u.user_id  = gm2.user_id
        WHERE gm2.group_id IN (SELECT group_id FROM my_groups)
    ) feed
    ORDER BY ts DESC
    LIMIT %(limit)s
'''

_AVATAR_CLASS = {
    'catch':         'feed-avatar-primary',
    'bait':          'feed-avatar-accent',
    'observation':   'feed-avatar-soft',
    'member_joined': 'feed-avatar-soft',
}


def _rel_time(dt):
    """Short relative age for feed timestamps ('2h ago', 'yesterday')."""
    if dt is None:
        return ''
    seconds = (datetime.now() - dt).total_seconds()
    if seconds < 60:                      # also clamps clock skew
        return 'just now'
    minutes = int(seconds // 60)
    if minutes < 60:
        return f'{minutes}m ago'
    hours = int(minutes // 60)
    if hours < 24:
        return f'{hours}h ago'
    days = int(hours // 24)
    if days == 1:
        return 'yesterday'
    if days < 7:
        return f'{days} days ago'
    return dt.strftime('%d %b %Y').lstrip('0') if dt.year != datetime.now().year \
        else dt.strftime('%d %b').lstrip('0')


@app.route('/my-tiaki')
@role_required()
def my_tiaki():
    """Render the cross-group personal home page with real activity."""
    user_id = session['user_id']

    my_groups = []
    feed_rows = []
    my_requests = []

    try:
        with db.get_cursor() as cursor:

            # ── My groups — also drives the no-membership empty state ─
            cursor.execute('''
                SELECT gm.group_id, gm.role, g.name, g.color_theme
                FROM group_memberships gm
                JOIN groups g ON g.group_id = gm.group_id
                WHERE gm.user_id = %s AND g.is_active = TRUE
                ORDER BY g.name
            ''', (user_id,))
            my_groups = cursor.fetchall()

            # ── Activity feed across all of the user's groups ─────────
            if my_groups:
                cursor.execute(_FEED_SQL, {'uid': user_id,
                                           'limit': FEED_LIMIT})
                feed_rows = cursor.fetchall()

            # ── Open requests (pending only; full list on /my-requests)
            cursor.execute('''
                SELECT 'Join request' AS type, g.name AS subject,
                       gjr.status, gjr.requested_at AS at
                FROM group_join_requests gjr
                JOIN groups g ON gjr.group_id = g.group_id
                WHERE gjr.user_id = %s AND gjr.status = 'pending'
                UNION ALL
                SELECT 'Group application', ga.proposed_name,
                       ga.status, ga.applied_at
                FROM group_applications ga
                WHERE ga.user_id = %s AND ga.status = 'pending'
                ORDER BY at DESC
                LIMIT 4
            ''', (user_id, user_id))
            my_requests = cursor.fetchall()

    except Exception:
        app.logger.exception('my_tiaki: failed to load feed data')
        # Render the page with whatever loaded; empty states cover gaps.

    # ── Shape feed rows for the template ─────────────────────────────
    feed_items = []
    for row in feed_rows:
        is_mine = row['actor_id'] == user_id
        full_name = f"{row['first_name'] or ''} {row['last_name'] or ''}".strip()
        feed_items.append({
            'kind':         row['kind'],
            'is_mine':      is_mine,
            'actor_name':   'You' if is_mine
                            else (full_name or row['username']
                                  or 'Unknown member'),
            'initials':     _compute_initials(row['first_name'],
                                              row['last_name'],
                                              row['username']),
            'profile_photo': row['profile_photo'],
            'avatar_class': 'feed-avatar-self' if is_mine
                            else _AVATAR_CLASS[row['kind']],
            'group_name':   row['group_name'],
            'color_theme':  row['color_theme'],
            'line_name':    row['line_name'],
            'place_code':   row['place_code'],
            'detail_a':     row['detail_a'],
            'detail_b':     row['detail_b'],
            'detail_c':     row['detail_c'],
            'num_a':        row['num_a'],
            'num_b':        row['num_b'],
            # A trap check that caught nothing reads differently.
            'is_check':     row['kind'] == 'catch'
                            and row['detail_a'] == 'None',
            'ts':           row['ts'],
            'when':         _rel_time(row['ts']),
        })

    counts = {
        'all':   len(feed_items),
        'catch': sum(1 for i in feed_items if i['kind'] == 'catch'),
        'bait':  sum(1 for i in feed_items if i['kind'] == 'bait'),
        'mine':  sum(1 for i in feed_items if i['is_mine']),
    }

    return render_template(
        'my_tiaki.html',
        feed_items=feed_items,
        counts=counts,
        my_groups=my_groups,
        my_requests=my_requests,
    )
