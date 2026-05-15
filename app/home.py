"""home.py — Public home page route."""

from flask import render_template
from app import app, db


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
        'total_lines':   0,
        'total_catches': 0,
    }
    public_groups = []
    featured_groups = []

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
                FROM lines l
                JOIN groups g ON l.group_id = g.group_id
                WHERE g.is_public = TRUE AND l.is_retired = FALSE
            ''')
            stats['total_lines'] = cursor.fetchone()['count']

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
                    g.is_public,
                    g.cover_photo,
                    g.color_theme,
                    g.created_at,
                    (SELECT COUNT(*) FROM group_memberships
                       WHERE group_id = g.group_id) AS member_count,
                    (SELECT COUNT(*) FROM lines
                       WHERE group_id = g.group_id AND is_retired = FALSE) AS line_count
                FROM groups g
                ORDER BY g.is_public DESC, g.created_at ASC
            ''')
            public_groups = cursor.fetchall()

            # ── Featured groups — top 3 PUBLIC groups for the hero cards ─
            cursor.execute('''
                SELECT
                    g.name,
                    (SELECT COUNT(*) FROM group_memberships
                       WHERE group_id = g.group_id) AS member_count
                FROM groups g
                WHERE g.is_public = TRUE
                ORDER BY member_count DESC, g.created_at ASC
                LIMIT 3
            ''')
            featured_groups = cursor.fetchall()

    except Exception:
        # Leave defaults if DB is unavailable; page still renders.
        pass

    # AC #6: empty state fires when there are zero PUBLIC groups,
    # regardless of how many private ones exist.
    has_public_groups = any(g['is_public'] for g in public_groups)

    return render_template(
        'home.html',
        stats=stats,
        public_groups=public_groups,
        has_public_groups=has_public_groups,
        featured_groups=featured_groups,
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