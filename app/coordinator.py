"""coordinator.py — Group Coordinator dashboard, lines, traps, bait stations, group settings."""

import glob
import json
import logging
import os
import re
from datetime import datetime, timezone

from flask import (
    render_template, request, redirect, url_for, flash, session, abort,
    Response,
)
from app import app, db, themes
from app.utils import (
    IDENTITY_PHOTO_EXTENSIONS,
    IDENTITY_PHOTO_MAX_BYTES,
    role_required,
    sniff_image_kind,
)
from app.helpers.dbHelper import insert_notification, insert_user_role, update_user_role

logger = logging.getLogger(__name__)


@app.route('/coordinator/dashboard')
@role_required('Group Coordinator')
def coordinator_dashboard():
    """Group Coordinator dashboard — placeholder."""
    return render_template('coordinator/dashboard.html')


# ── Operator assignment — line selector ──────────────────────────────────────

@app.route('/coordinator/lines/assign')
@role_required('Group Coordinator')
def coordinator_lines_assign():
    """List all active lines in the group so the coordinator can pick one to manage."""
    group_id = session['group_id']
    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT l.*,
                   COUNT(ol.operator_id) AS operator_count,
                   (SELECT COUNT(*) FROM group_memberships
                    WHERE group_id = %s AND role = 'Operator')
                    AS total_operators
            FROM lines l
            LEFT JOIN operator_lines ol ON ol.line_id = l.line_id
            WHERE l.group_id = %s AND l.is_retired = FALSE
            GROUP BY l.line_id
            ORDER BY l.name
            """,
            (group_id, group_id)
        )
        lines = cursor.fetchall()
    return render_template('coordinator/lines_assign.html', lines=lines)


# ── Operator assignment — per-line manage page ───────────────────────────────

@app.route('/coordinator/lines/<int:line_id>/assign')
@role_required('Group Coordinator')
def coordinator_assign_operators(line_id):
    """Show assigned and available operators for one line."""
    group_id = session['group_id']

    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT * FROM lines WHERE line_id = %s AND group_id = %s',
            (line_id, group_id)
        )
        line = cursor.fetchone()

    if not line:
        flash('Line not found in your group.', 'danger')
        return redirect(url_for('coordinator_lines_assign'))

    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT u.*
            FROM users u
            JOIN group_memberships gm ON gm.user_id = u.user_id
            WHERE gm.role = 'Operator' AND gm.group_id = %s
            ORDER BY u.last_name, u.first_name
            """,
            (group_id,)
        )
        all_operators = cursor.fetchall()

        cursor.execute(
            'SELECT * FROM operator_lines WHERE line_id = %s',
            (line_id,)
        )
        assigned_ids = {r['operator_id'] for r in cursor.fetchall()}

    assigned_operators   = [op for op in all_operators if op['user_id'] in assigned_ids]
    unassigned_operators = [op for op in all_operators if op['user_id'] not in assigned_ids]

    return render_template('coordinator/assign_operators.html',
                           line=line,
                           line_id=line_id,
                           assigned_operators=assigned_operators,
                           unassigned_operators=unassigned_operators)


# ── Add one operator to a line ───────────────────────────────────────────────

@app.route('/coordinator/lines/<int:line_id>/assign/add', methods=['POST'])
@role_required('Group Coordinator')
def coordinator_operator_add(line_id):
    """Assign a single operator to a line."""
    group_id    = session['group_id']
    operator_id = request.form.get('operator_id', type=int)

    if not operator_id:
        flash('Invalid operator.', 'danger')
        return redirect(url_for('coordinator_assign_operators', line_id=line_id))

    with db.get_cursor() as cursor:
        # Verify line belongs to this group
        cursor.execute(
            'SELECT line_id FROM lines WHERE line_id = %s AND group_id = %s',
            (line_id, group_id)
        )
        if not cursor.fetchone():
            flash('Line not found in your group.', 'danger')
            return redirect(url_for('coordinator_lines_assign'))

        # Verify operator is an Operator in this group
        cursor.execute(
            """
            SELECT 1 FROM group_memberships
            WHERE user_id = %s AND group_id = %s AND role = 'Operator'
            """,
            (operator_id, group_id)
        )
        if not cursor.fetchone():
            flash('That user is not an Operator in your group.', 'danger')
            return redirect(url_for('coordinator_assign_operators', line_id=line_id))

        cursor.execute(
            'INSERT INTO operator_lines (operator_id, line_id) VALUES (%s, %s) ON CONFLICT DO NOTHING',
            (operator_id, line_id)
        )

    logger.info('Coordinator %s added operator %s to line %d',
                session['user_id'], operator_id, line_id)
    flash('Operator added.', 'success')
    return redirect(url_for('coordinator_assign_operators', line_id=line_id))


# ── Remove one operator from a line ─────────────────────────────────────────

@app.route('/coordinator/lines/<int:line_id>/assign/remove', methods=['POST'])
@role_required('Group Coordinator')
def coordinator_operator_remove(line_id):
    """Remove a single operator from a line."""
    group_id    = session['group_id']
    operator_id = request.form.get('operator_id', type=int)

    if not operator_id:
        flash('Invalid operator.', 'danger')
        return redirect(url_for('coordinator_assign_operators', line_id=line_id))

    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT line_id FROM lines WHERE line_id = %s AND group_id = %s',
            (line_id, group_id)
        )
        if not cursor.fetchone():
            flash('Line not found in your group.', 'danger')
            return redirect(url_for('coordinator_lines_assign'))

        cursor.execute(
            'DELETE FROM operator_lines WHERE operator_id = %s AND line_id = %s',
            (operator_id, line_id)
        )

    logger.info('Coordinator %s removed operator %s from line %d',
                session['user_id'], operator_id, line_id)
    flash('Operator removed.', 'success')
    return redirect(url_for('coordinator_assign_operators', line_id=line_id))


# ── Members list ─────────────────────────────────────────────────────────────

@app.route('/coordinator/members')
@role_required('Group Coordinator')
def coordinator_members():
    """List all members of the active group."""
    group_id = session['group_id']
    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT u.user_id, u.username, u.first_name, u.last_name, u.date_joined,
                   gm.role
            FROM users u
            JOIN group_memberships gm ON gm.user_id = u.user_id
            WHERE gm.group_id = %s
            ORDER BY u.last_name, u.first_name
            """,
            (group_id,)
        )
        members = cursor.fetchall()
    return render_template('coordinator/members.html', members=members)


# ── Change a member's role ────────────────────────────────────────────────────

@app.route('/coordinator/members/<int:user_id>/change-role', methods=['POST'])
@role_required('Group Coordinator')
def coordinator_member_change_role(user_id):
    """Toggle a member's role between Observer and Operator."""
    group_id = session['group_id']
    new_role = request.form.get('role')

    if new_role not in ('Observer', 'Operator'):
        flash('Invalid role.', 'danger')
        return redirect(url_for('coordinator_members'))

    if user_id == session['user_id']:
        flash('You cannot change your own role.', 'danger')
        return redirect(url_for('coordinator_members'))

    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT role FROM group_memberships WHERE user_id = %s AND group_id = %s',
            (user_id, group_id)
        )
        membership = cursor.fetchone()

    if not membership:
        flash('Member not found in your group.', 'danger')
        return redirect(url_for('coordinator_members'))

    if membership['role'] in ('Group Coordinator', 'Super Admin'):
        flash('Cannot change a Group Coordinator role — contact a Super Admin.', 'danger')
        return redirect(url_for('coordinator_members'))

    update_user_role(db, user_id, group_id, new_role)
    logger.info('Coordinator %s changed user %s to role %s in group %d',
                session['user_id'], user_id, new_role, group_id)
    flash(f'Role updated to {new_role}.', 'success')
    return redirect(url_for('coordinator_members'))


# ── Remove a member from the group ───────────────────────────────────────────

@app.route('/coordinator/members/<int:user_id>/remove', methods=['POST'])
@role_required('Group Coordinator')
def coordinator_member_remove(user_id):
    """Remove a member from the group (membership only — account is unaffected)."""
    group_id = session['group_id']

    if user_id == session['user_id']:
        flash('You cannot remove yourself from the group.', 'danger')
        return redirect(url_for('coordinator_members'))

    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT role FROM group_memberships WHERE user_id = %s AND group_id = %s',
            (user_id, group_id)
        )
        membership = cursor.fetchone()

    if not membership:
        flash('Member not found in your group.', 'danger')
        return redirect(url_for('coordinator_members'))

    if membership['role'] in ('Group Coordinator', 'Super Admin'):
        flash('Cannot remove a Group Coordinator — contact a Super Admin.', 'danger')
        return redirect(url_for('coordinator_members'))

    with db.get_cursor() as cursor:
        cursor.execute(
            'DELETE FROM group_memberships WHERE user_id = %s AND group_id = %s',
            (user_id, group_id)
        )

    logger.info('Coordinator %s removed user %s from group %d',
                session['user_id'], user_id, group_id)
    flash('Member removed from group.', 'success')
    return redirect(url_for('coordinator_members'))

#   ── Group settings ───────────────────────────────────────────────────────────

@app.route('/coordinator/settings', methods=['GET', 'POST'])
@role_required('Group Coordinator')
def coordinator_settings():
    group_id = session['group_id']

    if request.method == 'POST':
        is_public = request.form.get('is_public') == '1'
        with db.get_cursor() as cursor:
            cursor.execute(
                'UPDATE groups SET is_public = %s WHERE group_id = %s',
                (is_public, group_id)
            )
        label = 'Public' if is_public else 'Private'
        logger.info('Coordinator %s set group %d to %s', session['user_id'], group_id, label)
        flash(f'Group visibility set to {label}.', 'success')
        return redirect(url_for('coordinator_settings'))

    with db.get_cursor() as cursor:
        cursor.execute('SELECT is_public FROM groups WHERE group_id = %s', (group_id,))
        group = cursor.fetchone()

    return render_template('coordinator/settings.html', is_public=group['is_public'])


#   ── Join request list ────────────────────────────────────────────────────────
@app.route('/coordinator/requests')
@role_required('Group Coordinator')
def coordinator_requests():
    group_id = session['group_id']
    with db.get_cursor() as cursor:
        cursor.execute(
            '''SELECT gjr.*, u.username, u.first_name, u.last_name, u.email, u.phone
               FROM group_join_requests gjr
               JOIN users u ON gjr.user_id = u.user_id
               WHERE gjr.group_id = %s AND gjr.status = 'pending'
               ORDER BY gjr.requested_at''',
            (group_id,)
        )
        join_requests = cursor.fetchall()

        cursor.execute(
            '''SELECT gjr.*, u.username, u.first_name, u.last_name, u.email, u.phone
               FROM group_join_requests gjr
               JOIN users u ON gjr.user_id = u.user_id
               WHERE gjr.group_id = %s AND gjr.status IN ('approved', 'rejected')
               ORDER BY gjr.requested_at DESC''',
            (group_id,)
        )
        history = cursor.fetchall()

    return render_template('coordinator/requests.html',
                           join_requests=join_requests, history=history)


#   ── Approve or reject a single join request ───────────────────────────────────
@app.route('/coordinator/requests/<int:request_id>/decide', methods=['POST'])
@role_required('Group Coordinator')
def coordinator_decide_request(request_id):
    decision = request.form.get('decision')
    if decision not in ('approve', 'reject'):
        flash('Invalid decision.', 'danger')
        return redirect(url_for('coordinator_requests'))

    group_id   = session['group_id']
    group_name = session['group_name']

    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT user_id FROM group_join_requests WHERE request_id = %s AND group_id = %s AND status = %s',
            (request_id, group_id, 'pending')
        )
        join_request = cursor.fetchone()

    if not join_request:
        flash('Request not found.', 'danger')
        return redirect(url_for('coordinator_requests'))

    applicant_id = join_request['user_id']

    if decision == 'approve':
        insert_user_role(db, applicant_id, group_id, 'Observer')
        insert_notification(db, applicant_id,
                            f'Your request to join {group_name} has been approved. You have been added as an Observer.',
                            'success')
        logger.info('Coordinator %s approved join request %d (user %d)',
                    session['user_id'], request_id, applicant_id)
        flash('Request approved — user added as Observer.', 'success')
    else:
        reason = request.form.get('reason', '').strip()
        message = f'Your request to join {group_name} was not approved.'
        if reason:
            message += f' Reason: {reason}'
        insert_notification(db, applicant_id, message, 'warning')
        logger.info('Coordinator %s rejected join request %d (user %d)',
                    session['user_id'], request_id, applicant_id)
        flash('Request rejected.', 'info')

    new_status = 'approved' if decision == 'approve' else 'rejected'
    with db.get_cursor() as cursor:
        cursor.execute(
            "UPDATE group_join_requests SET status = %s WHERE request_id = %s",
            (new_status, request_id)
        )

    return redirect(url_for('coordinator_requests'))


# ── Theme gallery (P2-41) ────────────────────────────────────────────────────
# Note: this route admits both 'Group Coordinator' and 'Super Admin' — a
# deliberate divergence from the rest of this module, which gates on
# Coordinator only. Per spec for P2-41. Whether Super Admin should also
# admin the other coordinator routes is a separate policy question.

@app.route('/coordinator/themes')
@role_required('Group Coordinator', 'Super Admin')
def coordinator_themes():
    """Browse pre-made theme presets for the active group.

    "Active" lineage: we mark whichever preset the group is currently
    BASED ON (group_themes.based_on_preset). That stays true even if
    the coordinator has tweaked colours/fonts since applying — the
    preset tile keeps its Active badge, and the template surfaces a
    small "Customised" sub-label when the live columns no longer
    match the preset exactly. If based_on_preset is NULL the group
    is on a from-scratch custom theme; no tile is marked Active and
    the "Custom theme in use" notice appears.
    """
    group_id = session['group_id']
    presets = themes.list_presets()
    current_theme = themes.get_active_theme(group_id)
    applied_preset_id = themes.get_group_based_on_preset(group_id)
    exact_match_id = themes.find_matching_preset(current_theme, presets)
    is_customised = (
        applied_preset_id is not None
        and applied_preset_id != exact_match_id
    )

    # Split the gallery WP-style: the active preset goes into the
    # "Featured" slot at the top (large side-by-side card); every other
    # preset renders in the grid below. When no preset is active, the
    # full list renders as the grid and the Featured slot is omitted.
    featured_preset = None
    if applied_preset_id is not None:
        featured_preset = next(
            (p for p in presets if p['preset_id'] == applied_preset_id),
            None,
        )
    other_presets = [
        p for p in presets if p['preset_id'] != applied_preset_id
    ]

    return render_template(
        'coordinator/themes.html',
        featured_preset=featured_preset,
        other_presets=other_presets,
        applied_preset_id=applied_preset_id,
        is_customised=is_customised,
        is_custom_theme=(applied_preset_id is None),
    )


@app.route('/coordinator/themes/<int:preset_id>')
@role_required('Group Coordinator', 'Super Admin')
def coordinator_theme_preview(preset_id):
    """Fuller preview of a single preset, with Apply action (P2-42).

    Pulls the group's currently-effective theme so the preview can hide
    the Apply button (and show a static "Currently applied" tag) when
    this preset is already the active theme.
    """
    preset = themes.get_preset(preset_id)
    if not preset:
        abort(404)
    group_id = session['group_id']
    current_theme = themes.get_active_theme(group_id)
    presets = themes.list_presets()
    applied_preset_id = themes.find_matching_preset(current_theme, presets)
    return render_template(
        'coordinator/theme_preview.html',
        preset=preset,
        is_currently_applied=(applied_preset_id == preset_id),
    )


@app.route('/coordinator/themes/<int:preset_id>/apply', methods=['POST'])
@role_required('Group Coordinator', 'Super Admin')
def coordinator_apply_theme(preset_id):
    """Apply a pre-made theme preset to the active group (P2-42).

    The heavy lifting (snapshot → UPSERT → cap history) lives in
    themes.apply_preset() so it can roll back atomically.
    """
    group_id = session['group_id']
    user_id  = session['user_id']
    try:
        preset_name = themes.apply_preset(group_id, preset_id, user_id)
    except themes.PresetNotFound:
        abort(404)
    except Exception:
        logger.exception(
            'apply_preset failed for group %s preset %s', group_id, preset_id
        )
        flash('Failed to apply the theme. Please try again.', 'danger')
        return redirect(
            url_for('coordinator_theme_preview', preset_id=preset_id)
        )
    flash(f"'{preset_name}' theme applied.", 'success')
    return redirect(url_for('coordinator_themes'))


# ── Export / Import (manual archive — 2026-05-15) ───────────────────────────
#
# Why this exists: the in-DB theme_history is capped at 7 rows per group as
# a safety-net for accidental overwrites. Coordinators who want a durable
# archive of a customised look use the JSON export — a single file they can
# store in Drive / email / Git / wherever, and re-import later via the
# matching import handler. The export format is versioned
# (`tiaki_theme_format: 1`) so a future schema change can be detected on
# import without silently corrupting columns.

# Filename-safe slug for whatever group name we ship. Keeps unicode group
# names like "Pōhutukawa" from breaking Content-Disposition headers.
_THEME_EXPORT_FORMAT = 1
_SLUG_RE = re.compile(r'[^a-z0-9]+')


def _theme_export_filename(group_name):
    slug = _SLUG_RE.sub('-', (group_name or 'group').lower()).strip('-')
    return f"tiaki-theme-{slug or 'group'}-{datetime.now():%Y%m%d}.json"


@app.route('/coordinator/themes/export')
@role_required('Group Coordinator', 'Super Admin')
def coordinator_theme_export():
    """Download the group's current theme as a JSON archive."""
    group_id = session['group_id']
    group_name = session.get('group_name', 'group')

    current = themes.get_active_theme(group_id)
    based_on = themes.get_group_based_on_preset(group_id)
    based_on_name = None
    if based_on is not None:
        preset = themes.get_preset(based_on)
        based_on_name = preset['name'] if preset else None

    payload = {
        'tiaki_theme_format': _THEME_EXPORT_FORMAT,
        'exported_at':        datetime.now(timezone.utc).isoformat(),
        'exported_from_group': group_name,
        'based_on_preset_name': based_on_name,
        'theme': {
            'primary_color':    current['primary_color'],
            'secondary_color':  current['secondary_color'],
            'background_color': current['background_color'],
            'button_style':     current['button_style'],
            'font_heading':     current['font_heading'],
            'font_body':        current['font_body'],
            'nav_position':     current['nav_position'],
            'content_width':    current['content_width'],
            'based_on_preset':  based_on,
        },
    }

    body = json.dumps(payload, indent=2, ensure_ascii=False)
    filename = _theme_export_filename(group_name)
    return Response(
        body,
        mimetype='application/json',
        headers={'Content-Disposition': f'attachment; filename="{filename}"'},
    )


@app.route('/coordinator/themes/import', methods=['POST'])
@role_required('Group Coordinator', 'Super Admin')
def coordinator_theme_import():
    """Apply a previously exported theme JSON to the active group.

    Goes through `themes.save_custom_theme` so the same validation +
    history snapshot semantics apply as a manual editor save. Lineage
    (`based_on_preset`) is preserved when the referenced preset still
    exists in the platform's library; otherwise the imported theme
    lands as a from-scratch custom.
    """
    group_id = session['group_id']
    user_id  = session['user_id']

    upload = request.files.get('theme_file')
    if not upload or not upload.filename:
        flash('Pick a theme JSON file to import.', 'warning')
        return redirect(url_for('coordinator_themes'))

    try:
        data = json.loads(upload.read().decode('utf-8'))
    except (UnicodeDecodeError, json.JSONDecodeError):
        flash("That file isn't valid JSON. Re-export and try again.", 'danger')
        return redirect(url_for('coordinator_themes'))

    if not isinstance(data, dict) or data.get('tiaki_theme_format') != _THEME_EXPORT_FORMAT:
        flash("That file isn't a Tiaki theme export "
              f"(expected tiaki_theme_format={_THEME_EXPORT_FORMAT}).", 'danger')
        return redirect(url_for('coordinator_themes'))

    theme_payload = data.get('theme')
    if not isinstance(theme_payload, dict):
        flash('Theme payload missing or malformed.', 'danger')
        return redirect(url_for('coordinator_themes'))

    based_on = theme_payload.get('based_on_preset')
    if based_on is not None:
        try:
            based_on = int(based_on)
        except (TypeError, ValueError):
            based_on = None
        if based_on is not None and not themes.get_preset(based_on):
            # Referenced preset no longer exists — drop the lineage
            # but keep the column values.
            based_on = None

    try:
        themes.save_custom_theme(group_id, theme_payload, based_on, user_id)
    except themes.ValidationError as e:
        details = ', '.join(sorted(e.errors.keys()))
        flash(f'Imported theme failed validation ({details}).', 'danger')
        return redirect(url_for('coordinator_themes'))
    except Exception:
        logger.exception('Theme import failed for group %s', group_id)
        flash('Could not import that theme. Try again.', 'danger')
        return redirect(url_for('coordinator_themes'))

    flash('Theme imported and applied.', 'success')
    return redirect(url_for('coordinator_themes'))


# ── P2-43: Custom theme editor ───────────────────────────────────────────────
#
# Two entry paths converge on /coordinator/themes/customise:
#   (a) no query string         → pre-fill from current effective theme,
#                                  save with based_on_preset = NULL.
#   (b) ?from_preset=<int>      → pre-fill from that preset,
#                                  save with based_on_preset = preset_id.
# POST to the same URL saves. On ValidationError, re-render with the
# submitted values so the user doesn't lose work.


def _initial_values_for_editor(group_id, from_preset_raw):
    """Resolve initial form values + header label for the editor GET path.

    Returns a dict with:
      field_values        — six themable keys, ready for form pre-fill
      based_on_preset     — int or None (carried in a hidden form field)
      based_on_preset_name— preset name for the header label, or None
      font_warning        — True when the source font was snapped to the
                            whitelist default; route should flash.
    """
    based_on_preset = None
    based_on_preset_name = None
    font_warning = False

    # The editor today exposes ONE font picker (the heading-split UI is
    # the next story). We seed it from font_body — that's what the user
    # reads-types-and-edits in the dashboard; the heading sample they see
    # is whatever ships from the source theme. On save the same picked
    # value lands in BOTH columns (see themes._validate_theme_values).
    if from_preset_raw and from_preset_raw.isdigit():
        preset = themes.get_preset(int(from_preset_raw))
        if not preset:
            abort(404)
        based_on_preset      = preset['preset_id']
        based_on_preset_name = preset['name']
        values = {
            'primary_color':    preset['primary_color'],
            'secondary_color':  preset['secondary_color'],
            'background_color': preset['background_color'],
            'button_style':     preset['button_style'],
            'font_family':      preset['font_body'],
            'nav_position':     preset['nav_position'],
            'content_width':    preset['content_width'],
        }
    else:
        current = themes.get_active_theme(group_id)
        values = {
            'primary_color':    current['primary_color'],
            'secondary_color':  current['secondary_color'],
            'background_color': current['background_color'],
            'button_style':     current['button_style'],
            'font_family':      current['font_body'],
            'nav_position':     current['nav_position'],
            'content_width':    current['content_width'],
        }
        # Entering with no ?from_preset (e.g. the nav's "Customise" link)
        # should still preserve whatever preset the group is currently
        # based on. Without this, saving would clear group_themes.based_on_preset
        # and the Active badge would disappear from the gallery — the very
        # state the WordPress-style "active even when customised" wants
        # to avoid. Reading directly from the DB keeps a single source of
        # truth (the live lineage marker) rather than re-deriving from
        # column matching.
        based_on_preset = themes.get_group_based_on_preset(group_id)
        if based_on_preset is not None:
            preset = themes.get_preset(based_on_preset)
            based_on_preset_name = preset['name'] if preset else None

    # Conflict-B defensive snap: a preset (or platform_theme) whose font
    # falls outside the editor's whitelist would otherwise pre-fill an
    # un-saveable value. Snap to Tiaki's default and tell the user.
    if values['font_family'] not in themes.FONT_BODY_WHITELIST:
        values['font_family'] = 'IBM Plex Sans'
        font_warning = True

    return {
        'field_values':         values,
        'based_on_preset':      based_on_preset,
        'based_on_preset_name': based_on_preset_name,
        'font_warning':         font_warning,
    }


@app.route('/coordinator/themes/customise')
@role_required('Group Coordinator', 'Super Admin')
def coordinator_theme_customise():
    """GET — render the custom theme editor.

    Reads ?from_preset=<int> to decide entry path. Passes platform_theme
    separately so the client-side Reset button has authoritative values
    (via data-* attrs on the preview container).
    """
    group_id = session['group_id']

    initial = _initial_values_for_editor(
        group_id, request.args.get('from_preset')
    )

    if initial['font_warning']:
        flash(
            'That preset uses a font outside the current whitelist; '
            'pre-filled with IBM Plex Sans instead.',
            'warning',
        )

    # 2026-05-15: Reset target = the currently *selected* theme, not
    # the platform default. If the group is on a preset, Reset reverts
    # to that preset's pristine column values; if it's on a from-scratch
    # custom theme, Reset reverts to the saved group_themes row (i.e.
    # discards unsaved edits in the editor session). Either way the
    # user lands back on the theme they think is "theirs".
    if initial['based_on_preset'] is not None:
        reset_theme = themes.get_preset(initial['based_on_preset'])
    else:
        reset_theme = themes.get_active_theme(group_id)

    return render_template(
        'coordinator/theme_edit.html',
        values=initial['field_values'],
        based_on_preset=initial['based_on_preset'],
        based_on_preset_name=initial['based_on_preset_name'],
        reset_theme=reset_theme,
        fonts=themes.FONT_BODY_WHITELIST,
        errors={},
    )


@app.route('/coordinator/themes/customise', methods=['POST'])
@role_required('Group Coordinator', 'Super Admin')
def coordinator_theme_customise_save():
    """POST — save the submitted custom theme.

    On ValidationError: re-render the editor with the submitted values
    + field-keyed errors so the user keeps their work. HTTP 400 so the
    response code matches the failure mode (test 8/9 in the verification
    matrix).

    On any other exception: log + flash + redirect back to the editor.
    """
    group_id = session['group_id']
    user_id  = session['user_id']

    submitted = {
        'primary_color':    request.form.get('primary_color', ''),
        'secondary_color':  request.form.get('secondary_color', ''),
        'background_color': request.form.get('background_color', ''),
        'button_style':     request.form.get('button_style', ''),
        'font_family':      request.form.get('font_family', ''),
        'nav_position':     request.form.get('nav_position', ''),
        'content_width':    request.form.get('content_width', ''),
    }
    raw_bop = request.form.get('based_on_preset', '').strip()
    based_on_preset = int(raw_bop) if raw_bop.isdigit() else None

    try:
        themes.save_custom_theme(
            group_id, submitted, based_on_preset, user_id
        )
    except themes.ValidationError as e:
        based_on_name = None
        if based_on_preset is not None:
            p = themes.get_preset(based_on_preset)
            based_on_name = p['name'] if p else None
        # Reset target for the re-render: same logic as the GET path.
        if based_on_preset is not None:
            reset_theme = themes.get_preset(based_on_preset)
        else:
            reset_theme = themes.get_active_theme(group_id)
        flash('Some values need fixing. See highlighted fields below.', 'danger')
        return render_template(
            'coordinator/theme_edit.html',
            values=submitted,
            based_on_preset=based_on_preset,
            based_on_preset_name=based_on_name,
            reset_theme=reset_theme,
            fonts=themes.FONT_BODY_WHITELIST,
            errors=e.errors,
        ), 400
    except Exception:
        logger.exception(
            'save_custom_theme failed for group %s', group_id
        )
        flash('Could not save the theme. Please try again.', 'danger')
        return redirect(url_for('coordinator_theme_customise'))

    # 2026-05-15: stay on the editor after a successful save so the
    # coordinator can keep iterating without bouncing back to the
    # gallery. The next GET pulls the just-saved values via
    # _initial_values_for_editor → get_active_theme, so the form
    # re-renders with the persisted state.
    flash('Custom theme saved.', 'success')
    return redirect(url_for('coordinator_theme_customise'))


# ── Customise history (Save-as-Preset + Restore) ─────────────────────────────
#
# Surfaces the snapshots that apply_preset / save_custom_theme already write
# into theme_history. Two row classes share the same table:
#   • Auto-snapshots (name IS NULL, is_pinned = FALSE) — capped at 7 per group.
#   • Pinned saves   (name set,     is_pinned = TRUE)  — exempt from the cap,
#                                                         the coordinator's
#                                                         monthly archive.
# Restore takes either kind and re-applies it via the same 3-step atomic
# write apply_preset uses, so the restore is itself reversible.


@app.route('/coordinator/themes/history')
@role_required('Group Coordinator', 'Super Admin')
def coordinator_theme_history():
    """List this group's theme_history snapshots.

    Pinned rows are surfaced first as "Saved themes"; auto-snapshots follow
    as "Recent customisations". The template splits by is_pinned in one
    pass — themes.list_group_history orders pinned-first.
    """
    group_id = session['group_id']
    entries  = themes.list_group_history(group_id)
    pinned   = [e for e in entries if e['is_pinned']]
    recent   = [e for e in entries if not e['is_pinned']]
    return render_template(
        'coordinator/theme_history.html',
        pinned=pinned,
        recent=recent,
    )


@app.route('/coordinator/themes/history/save-as', methods=['POST'])
@role_required('Group Coordinator', 'Super Admin')
def coordinator_theme_history_save_as():
    """Pin the current group theme as a named history row.

    Mirrors the gallery's POST-redirect-GET pattern: validation errors
    flash and re-render the history page; success flashes and returns
    there too.
    """
    group_id = session['group_id']
    user_id  = session['user_id']
    name     = request.form.get('name', '')

    try:
        themes.save_current_as_pinned(group_id, user_id, name)
    except themes.ValidationError as e:
        # Name is the only validated field here — surface its message.
        flash(e.errors.get('name', 'Could not save that snapshot.'), 'warning')
        return redirect(url_for('coordinator_theme_history'))
    except Exception:
        logger.exception(
            'save_current_as_pinned failed for group %s', group_id
        )
        flash('Could not save that snapshot. Please try again.', 'danger')
        return redirect(url_for('coordinator_theme_history'))

    flash('Saved current theme to your history.', 'success')
    return redirect(url_for('coordinator_theme_history'))


@app.route('/coordinator/themes/history/<int:history_id>/restore',
           methods=['POST'])
@role_required('Group Coordinator', 'Super Admin')
def coordinator_theme_history_restore(history_id):
    """Re-apply a history snapshot to the active group's theme."""
    group_id = session['group_id']
    user_id  = session['user_id']

    try:
        themes.restore_from_history(group_id, history_id, user_id)
    except themes.HistoryNotFound:
        flash('That history entry no longer exists.', 'warning')
        return redirect(url_for('coordinator_theme_history'))
    except Exception:
        logger.exception(
            'restore_from_history failed for group %s history %s',
            group_id, history_id
        )
        flash('Could not restore that theme. Please try again.', 'danger')
        return redirect(url_for('coordinator_theme_history'))

    flash('Theme restored from history.', 'success')
    return redirect(url_for('coordinator_theme_history'))


@app.route('/coordinator/themes/history/<int:history_id>/delete',
           methods=['POST'])
@role_required('Group Coordinator', 'Super Admin')
def coordinator_theme_history_delete(history_id):
    """Remove a history row (typically used to unpin a saved theme)."""
    group_id = session['group_id']

    try:
        deleted = themes.delete_history_entry(group_id, history_id)
    except Exception:
        logger.exception(
            'delete_history_entry failed for group %s history %s',
            group_id, history_id
        )
        flash('Could not delete that entry. Please try again.', 'danger')
        return redirect(url_for('coordinator_theme_history'))

    if deleted:
        flash('History entry removed.', 'success')
    else:
        flash('That history entry no longer exists.', 'warning')
    return redirect(url_for('coordinator_theme_history'))


# ── P2-44: Group identity (cover + profile photo upload) ─────────────────────
#
# Same role gate as the themes routes (Coordinator + Super Admin). Each slot
# is a separate endpoint so the form actions stay simple and intent is clear
# at the URL level. Storage convention: static/uploads/group_<id>/cover.<ext>
# (and profile.<ext>) — relative path is what lands in groups.cover_photo /
# groups.profile_photo so the existing identity cascade picks it up
# automatically on next render.

def _identity_group_dir(group_id):
    """Absolute filesystem path for a group's identity upload directory."""
    return os.path.join(app.root_path, '..', 'static',
                        'uploads', f'group_{group_id}')


def _identity_rel_path(group_id, filename):
    """DB-storable path, relative to /static/."""
    return f'uploads/group_{group_id}/{filename}'


def _validate_identity_upload(file):
    """Layered upload validation. Returns (ext, err) where err is a
    user-facing flash message or None on success. Leaves file.stream
    seek position at 0 so the caller can save() immediately."""
    if not file or not file.filename:
        return None, 'No file selected.'

    # 1. Extension allow-list (client hint).
    ext = file.filename.rsplit('.', 1)[-1].lower() if '.' in file.filename else ''
    if ext not in IDENTITY_PHOTO_EXTENSIONS:
        return None, 'Only JPG, PNG, and WEBP are accepted.'

    # 2. Size — Werkzeug spools to a SpooledTemporaryFile above ~500KB,
    #    so seek/tell is the reliable way to measure the actual payload.
    file.stream.seek(0, os.SEEK_END)
    size = file.stream.tell()
    file.stream.seek(0)
    if size > IDENTITY_PHOTO_MAX_BYTES:
        return None, 'File exceeds 2 MB.'

    # 3. Magic-byte sniff — authoritative MIME source. Reject if the
    #    file's bytes disagree with the declared extension (catches the
    #    rename-a-GIF-to-.png attack).
    head = file.stream.read(12)
    file.stream.seek(0)
    sniffed = sniff_image_kind(head)
    # Normalise so 'jpg' and 'jpeg' compare equal against sniffer's 'jpeg'.
    ext_norm     = 'jpg' if ext == 'jpeg' else ext
    sniffed_norm = 'jpg' if sniffed == 'jpeg' else sniffed
    if sniffed_norm is None or sniffed_norm != ext_norm:
        return None, "File contents don't match the file extension."

    return ext, None


def _upload_identity_slot(slot):
    """Shared handler for the cover/profile upload POST routes.

    `slot` is 'cover' or 'profile' and is used as both the form field
    name and the on-disk filename stem.

    Transactional order: write file → UPDATE groups → cleanup stale
    siblings. If DB fails, best-effort delete the just-written file so
    we don't leak orphans into the new directory.
    """
    group_id = session['group_id']
    file = request.files.get(f'{slot}_photo')

    ext, err = _validate_identity_upload(file)
    if err:
        flash(err, 'danger')
        return redirect(url_for('coordinator_group_identity'))

    group_dir     = _identity_group_dir(group_id)
    new_filename  = f'{slot}.{ext}'
    new_disk_path = os.path.join(group_dir, new_filename)
    new_rel_path  = _identity_rel_path(group_id, new_filename)

    # 1. Filesystem write — first, so we never point the DB at a missing file.
    try:
        os.makedirs(group_dir, exist_ok=True)
        file.save(new_disk_path)
    except OSError:
        logger.exception('Failed to write %s for group %s', slot, group_id)
        flash('Could not save the file. Please try again.', 'danger')
        return redirect(url_for('coordinator_group_identity'))

    # 2. DB write — if this fails, roll back the filesystem side.
    db_column = 'cover_photo' if slot == 'cover' else 'profile_photo'
    try:
        with db.get_cursor() as cursor:
            cursor.execute(
                f'UPDATE groups SET {db_column} = %s WHERE group_id = %s',
                (new_rel_path, group_id),
            )
    except Exception:
        logger.exception('DB update failed for %s group %s', slot, group_id)
        try:
            if os.path.exists(new_disk_path):
                os.remove(new_disk_path)
        except OSError:
            logger.exception(
                'Filesystem rollback also failed for %s', new_disk_path
            )
        flash('Could not save the file. Please try again.', 'danger')
        return redirect(url_for('coordinator_group_identity'))

    # 3. Cleanup — when extension changes (cover.jpg → cover.webp), the
    #    stale sibling would orphan otherwise. Only after DB confirms.
    for stale in glob.glob(os.path.join(group_dir, f'{slot}.*')):
        if os.path.abspath(stale) != os.path.abspath(new_disk_path):
            try:
                os.remove(stale)
            except OSError:
                logger.warning('Could not delete stale %s file %s', slot, stale)

    flash(
        'Cover photo updated.' if slot == 'cover' else 'Profile photo updated.',
        'success',
    )
    return redirect(url_for('coordinator_group_identity'))


def _remove_identity_slot(slot):
    """Shared handler for the cover/profile remove POST routes.

    DB is the source of truth — NULL it first, then best-effort delete
    the file. A failed file delete is logged but the user sees success
    because the cascade renders correctly regardless (the platform
    default takes over on next render).
    """
    group_id = session['group_id']
    db_column = 'cover_photo' if slot == 'cover' else 'profile_photo'

    # Read current path before nulling so we know what to unlink.
    with db.get_cursor() as cursor:
        cursor.execute(
            f'SELECT {db_column} AS path FROM groups WHERE group_id = %s',
            (group_id,),
        )
        row = cursor.fetchone()

    current_rel = row['path'] if row else None
    if not current_rel:
        flash('No photo to remove.', 'info')
        return redirect(url_for('coordinator_group_identity'))

    # 1. DB to NULL — source of truth.
    try:
        with db.get_cursor() as cursor:
            cursor.execute(
                f'UPDATE groups SET {db_column} = NULL WHERE group_id = %s',
                (group_id,),
            )
    except Exception:
        logger.exception('DB null failed for %s group %s', slot, group_id)
        flash('Could not remove the photo. Please try again.', 'danger')
        return redirect(url_for('coordinator_group_identity'))

    # 2. Filesystem cleanup — best effort. Sweep the whole slot.* set
    #    (paranoia about extension drift). User sees success regardless;
    #    orphan files are cleanup work, not a user-facing bug.
    group_dir = _identity_group_dir(group_id)
    for stale in glob.glob(os.path.join(group_dir, f'{slot}.*')):
        try:
            os.remove(stale)
        except OSError:
            logger.warning(
                'Could not delete %s file %s on remove', slot, stale
            )

    flash(
        'Cover photo removed. Using fallback.' if slot == 'cover'
        else 'Profile photo removed. Using fallback.',
        'success',
    )
    return redirect(url_for('coordinator_group_identity'))


@app.route('/coordinator/group/identity')
@role_required('Group Coordinator', 'Super Admin')
def coordinator_group_identity():
    """Two-card page showing current cover + profile state.

    Reads the group's own uploads from the DB (so the "Remove" button
    only renders for slots that actually have a group-tier upload).
    The template separately walks the foundation cascade to label the
    effective source: group → platform_settings → static default.
    """
    group_id = session['group_id']
    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT cover_photo, profile_photo FROM groups WHERE group_id = %s',
            (group_id,),
        )
        row = cursor.fetchone()

    return render_template(
        'coordinator/group_identity.html',
        group_cover_path=(row['cover_photo'] if row else None),
        group_profile_path=(row['profile_photo'] if row else None),
    )


@app.route('/coordinator/group/identity/cover', methods=['POST'])
@role_required('Group Coordinator', 'Super Admin')
def coordinator_identity_upload_cover():
    return _upload_identity_slot('cover')


@app.route('/coordinator/group/identity/profile', methods=['POST'])
@role_required('Group Coordinator', 'Super Admin')
def coordinator_identity_upload_profile():
    return _upload_identity_slot('profile')


@app.route('/coordinator/group/identity/cover/remove', methods=['POST'])
@role_required('Group Coordinator', 'Super Admin')
def coordinator_identity_remove_cover():
    return _remove_identity_slot('cover')


@app.route('/coordinator/group/identity/profile/remove', methods=['POST'])
@role_required('Group Coordinator', 'Super Admin')
def coordinator_identity_remove_profile():
    return _remove_identity_slot('profile')