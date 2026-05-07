"""groups.py — Group landing pages.

Route:
    GET /groups/<int:group_id>

Visibility logic (per the brief):
    - Public groups are discoverable by anyone (logged in or out).
    - Private groups are visible in the browse list but content is gated:
      non-members see only a minimal page with a request-to-join CTA.
    - Members of a group are sent straight to the in-app dashboard.
"""

from flask import render_template, redirect, url_for, session, abort
from app import app, db


@app.route('/groups/<int:group_id>')
def group_landing(group_id):
    """Public landing page for a single group.

    Behaviour:
      - Members → redirect to dashboard (already inside the group).
      - Public group + non-member/anonymous → full landing page.
      - Private group + non-member/anonymous → minimal "request to join" view.
    """
    user_id = session.get('user_id')

    with db.get_cursor() as cursor:
        # ── Group basics ─────────────────────────────────────────
        cursor.execute('''
            SELECT
                g.group_id, g.name, g.description, g.is_public,
                g.tile_image, g.color_theme, g.created_at
            FROM groups g
            WHERE g.group_id = %s
        ''', (group_id,))
        group = cursor.fetchone()

        if not group:
            abort(404)

        # ── Membership check ─────────────────────────────────────
        is_member = False
        if user_id:
            cursor.execute('''
                SELECT 1 FROM group_memberships
                WHERE user_id = %s AND group_id = %s
            ''', (user_id, group_id))
            is_member = cursor.fetchone() is not None

        # If they're already in this group, send them to the dashboard.
        if is_member:
            return redirect(url_for('select_group'))

        # ── Stats — only computed for public groups, never leaked ─
        stats = None
        coordinators = []

        if group['is_public']:
            cursor.execute('''
                SELECT COUNT(*) AS count
                FROM group_memberships
                WHERE group_id = %s
            ''', (group_id,))
            member_count = cursor.fetchone()['count']

            cursor.execute('''
                SELECT COUNT(*) AS count
                FROM lines
                WHERE group_id = %s AND is_retired = FALSE
            ''', (group_id,))
            line_count = cursor.fetchone()['count']

            cursor.execute('''
                SELECT COUNT(*) AS count
                FROM trap_catches tc
                JOIN traps t ON tc.trap_id = t.trap_id
                JOIN lines l ON t.line_id = l.line_id
                WHERE l.group_id = %s AND tc.species_caught != 'None'
            ''', (group_id,))
            catch_count = cursor.fetchone()['count']

            stats = {
                'members': member_count,
                'lines':   line_count,
                'catches': catch_count,
            }

            # Coordinator names — humanises the page
            cursor.execute('''
                SELECT u.first_name, u.last_name
                FROM group_memberships gm
                JOIN users u ON gm.user_id = u.user_id
                WHERE gm.group_id = %s AND gm.role = 'Group Coordinator'
                ORDER BY u.first_name
            ''', (group_id,))
            coordinators = cursor.fetchall()

        # ── Pending join request? (for private groups, logged-in users) ──
        has_pending_request = False
        if user_id and not group['is_public']:
            cursor.execute('''
                SELECT 1 FROM group_join_requests
                WHERE user_id = %s AND group_id = %s AND status = 'pending'
            ''', (user_id, group_id))
            has_pending_request = cursor.fetchone() is not None

    return render_template(
        'group_landing.html',
        group=group,
        stats=stats,
        coordinators=coordinators,
        has_pending_request=has_pending_request,
    )