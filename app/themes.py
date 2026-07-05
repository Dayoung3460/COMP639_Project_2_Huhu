"""themes.py — Custom Themes epic, foundation.

Two pure read helpers consumed by the `inject_theme_identity` context
processor in `app/__init__.py`. They surface the active group's theme
+ identity (cover / profile photos) into every template render.

Schema assumptions (applied out-of-band; not yet in
`sql/create_tables.sql`):

  group_themes      (group_id PK, primary_color, secondary_color,
                     background_color, button_style ENUM
                     button_style_type 'rounded'|'square',
                     font_heading, font_body,
                     nav_position ENUM 'sidebar'|'topbar',
                     content_width ENUM 'wrap'|'full')
  platform_theme    — same columns, singleton row enforced by
                       CHECK (id = 1)
  theme_history     — same columns + group_id, history_id, saved_at,
                       saved_by, based_on_preset
  theme_presets     — same columns + preset_id, name, description,
                       preview_image, display_order
  platform_settings — (id PK CHECK (id = 1), cover_photo, profile_photo, …)
  groups.cover_photo, groups.profile_photo — paths relative to /static/

2026-05-12 migration: layout_template (single ENUM) was split into
nav_position + content_width (two orthogonal ENUMs) so the editor can
expose two independent layout dimensions instead of three named combos.

All photo paths are relative to `/static/`. Templates always wrap
the returned string with `url_for('static', filename=…)`.
"""

import re

from flask import url_for

from app import db
from app.helpers import storageHelper


# Legacy static placeholders. Kept for the DB-unreachable exception
# path where `url_for` can still fail (e.g. ServerSelectionTimeoutError
# before app context). Live identity rendering uses the generated SVG
# routes registered by app/identity_defaults.py — see
# `_default_cover_url` / `_default_profile_url` below.
DEFAULT_COVER_PHOTO   = 'images/default-cover.jpg'
DEFAULT_PROFILE_PHOTO = 'images/default-profile.png'

# Used by the context processor's exception path so pages still render
# themed-by-default if the DB is unreachable mid-request.
#
# 2026-05-12 schema split: `layout_template` (single ENUM) replaced by
# `nav_position` + `content_width` (two orthogonal ENUMs). The defaults
# below pick the "old centred" combo so DB-unreachable fallbacks land
# on Tiaki's least-surprising chrome.
PLATFORM_DEFAULT_THEME = {
    'primary_color':    '#1a3a2e',
    'secondary_color':  '#c65d3c',
    'background_color': '#f5f0e6',
    'button_style':     'rounded',
    'button_radius':    '8px',
    'font_heading':     'Fraunces',
    'font_body':        'IBM Plex Sans',
    'nav_position':     'sidebar',
    'content_width':    'wrap',
}

DEFAULT_GROUP_COLOR = PLATFORM_DEFAULT_THEME['primary_color']

# Whitelists of font families a Coordinator may pick in the custom theme
# editor. Two lists because the heading + body split (2026-05-15) wants
# semantically appropriate options on each picker — display serifs/sans
# on the heading list, readable body fonts on the body list. All families
# are free Google Fonts with 400/500/600/700 weights so the existing
# wght query string in <link> tags keeps working.
FONT_HEADING_WHITELIST = (
    'Fraunces',
    'Merriweather',
    'Playfair Display',
    'Oswald',
    'Lora',
    'Cabin',
)
FONT_BODY_WHITELIST = (
    'IBM Plex Sans',
    'Inter',
    'Source Sans 3',
    'Lora',
    'Merriweather',
    'DM Sans',
)

# Neutral starting values for the editor's "Start from scratch" path
# (?blank=1). Deliberately understated: black-on-white with the first
# whitelisted body font, square buttons, sidebar+wrap layout. The point
# is "no inheritance from the active theme" — the coordinator sees a
# clean palette and types in colours from there.
BLANK_CANVAS_DEFAULTS = {
    'primary_color':    '#1f1f1f',
    'secondary_color':  '#666666',
    'background_color': '#ffffff',
    'button_style':     'rounded',
    'font_family':      'IBM Plex Sans',
    'nav_position':     'sidebar',
    'content_width':    'wrap',
}

_HEX_RE = re.compile(r'^#[0-9A-Fa-f]{6}$')

# Auto-snapshot cap. apply_preset / save_custom_theme / restore_from_history
# each end with a DELETE … WHERE NOT is_pinned … OFFSET HISTORY_CAP, so the
# table holds at most this many auto-snapshots per group. Pinned rows
# (is_pinned = TRUE, written by save_current_as_pinned) are exempt — they
# never count toward the cap and are never trimmed.
HISTORY_CAP = 10

_THEME_COLUMNS = (
    'primary_color, secondary_color, background_color, '
    'button_style, font_heading, font_body, nav_position, content_width'
)


def _shape_theme(row):
    """RealDictCursor row → mutable dict + derived `button_radius`.

    Centralises the 'rounded' → '8px' / 'square' → '0' mapping so the
    template can emit a CSS-ready string verbatim. Raw `button_style`
    stays on the dict so templates can still branch on the enum.
    """
    d = dict(row)
    d['button_radius'] = '8px' if d.get('button_style') == 'rounded' else '0'
    return d


def get_active_theme(group_id=None):
    """Return the active theme dict. Never returns None.

    Resolution order:
      1. group_themes row for `group_id`, if any.
      2. platform_theme singleton (CHECK id = 1).
      3. PLATFORM_DEFAULT_THEME — only reached if platform_theme is
         missing, which the schema seed should make impossible.
    """
    if group_id:
        with db.get_cursor() as cursor:
            cursor.execute(
                f'SELECT {_THEME_COLUMNS} FROM group_themes WHERE group_id = %s',
                (group_id,)
            )
            row = cursor.fetchone()
        if row:
            return _shape_theme(row)

    with db.get_cursor() as cursor:
        cursor.execute(
            f'SELECT {_THEME_COLUMNS} FROM platform_theme WHERE id = 1'
        )
        row = cursor.fetchone()
    return _shape_theme(row) if row else dict(PLATFORM_DEFAULT_THEME)


def _default_cover_url(group_id=None):
    """URL for the generated default cover SVG. Group-scoped when
    `group_id` is supplied; platform fallback otherwise."""
    if group_id:
        return url_for('identity_default_group_cover', group_id=group_id)
    return url_for('identity_default_platform_cover')


def _default_profile_url(group_id=None):
    """URL for the generated default profile SVG. Group-scoped when
    `group_id` is supplied; platform fallback otherwise."""
    if group_id:
        return url_for('identity_default_group_profile', group_id=group_id)
    return url_for('identity_default_platform_profile')


def _static_url(rel_path):
    """Public URL for a stored upload. Returns None if rel_path is falsy
    OR points at a file that verifiably no longer exists (broken-image
    fallback: missing uploads collapse to None so the caller's `or`
    chain resolves to the generated SVG default instead of serving a
    404 image that renders as the ugly browser placeholder)."""
    try:
        return storageHelper.upload_url_if_exists(rel_path)
    except Exception:
        # No app context or unexpected path issue — fall back to the
        # SVG default rather than risk a broken <img src>.
        return None


def get_active_identity(group_id=None):
    """Return {cover_photo, profile_photo} as `<img src>`-ready URLs.

    Each column resolves independently — a group can override just the
    cover and inherit the platform default profile photo, or vice versa.

    Fallback chain per column:
      1. groups.<col> (uploaded asset)             → /static/uploads/...
      2. platform_settings.<col> (platform upload) → /static/...
      3. Generated SVG default                     → /identity/default/...

    Generated SVGs render in the group's theme colours and carry the
    group's initials, so even un-uploaded groups have a branded look.
    """
    cover, profile = None, None

    if group_id:
        with db.get_cursor() as cursor:
            cursor.execute(
                'SELECT cover_photo, profile_photo FROM groups WHERE group_id = %s',
                (group_id,)
            )
            row = cursor.fetchone()
        if row:
            cover, profile = row['cover_photo'], row['profile_photo']

    if not cover or not profile:
        with db.get_cursor() as cursor:
            cursor.execute(
                'SELECT cover_photo, profile_photo FROM platform_settings WHERE id = 1'
            )
            ps = cursor.fetchone()
        if ps:
            cover   = cover   or ps['cover_photo']
            profile = profile or ps['profile_photo']

    return {
        'cover_photo':   _static_url(cover)   or _default_cover_url(group_id),
        'profile_photo': _static_url(profile) or _default_profile_url(group_id),
    }


# ── Surface-scoped reads (foundation fix) ───────────────────────────────────
# get_active_theme / get_active_identity above fold the platform fallback
# into a single value — useful for routes that want "what theme is this
# group on right now". The helpers below split the two scopes so the
# context processor can expose them separately: marketing pages can render
# strictly in platform identity (Tiaki stays Tiaki), in-app pages render in
# the active group's theme, and routes that preview one group (the public
# /groups/<id> landing) can pass that group's theme as an explicit
# override without mutating the platform identity.

def get_platform_theme():
    """Return the singleton platform_theme row. Never None — falls back
    to PLATFORM_DEFAULT_THEME if the DB is unreachable mid-request."""
    try:
        with db.get_cursor() as cursor:
            cursor.execute(
                f'SELECT {_THEME_COLUMNS} FROM platform_theme WHERE id = 1'
            )
            row = cursor.fetchone()
    except Exception:
        return dict(PLATFORM_DEFAULT_THEME)
    return _shape_theme(row) if row else dict(PLATFORM_DEFAULT_THEME)


def get_platform_identity():
    """Return {cover_photo, profile_photo} as `<img src>`-ready URLs.

    Source order: platform_settings upload → generated platform SVG.
    Never None — generated SVG always wins when no upload exists.
    """
    cover, profile = None, None
    try:
        with db.get_cursor() as cursor:
            cursor.execute(
                'SELECT cover_photo, profile_photo '
                'FROM platform_settings WHERE id = 1'
            )
            row = cursor.fetchone()
        if row:
            cover, profile = row['cover_photo'], row['profile_photo']
    except Exception:
        pass  # fall through to generated SVGs
    return {
        'cover_photo':   _static_url(cover)   or _default_cover_url(),
        'profile_photo': _static_url(profile) or _default_profile_url(),
    }


def get_group_theme(group_id):
    """Return the group's group_themes row dict, or None if no row exists
    OR group_id is falsy. Purely group-scoped — no platform fallback at
    this layer; the caller (template) decides whether to fall back to
    platform_theme."""
    if not group_id:
        return None
    with db.get_cursor() as cursor:
        cursor.execute(
            f'SELECT {_THEME_COLUMNS} FROM group_themes WHERE group_id = %s',
            (group_id,)
        )
        row = cursor.fetchone()
    return _shape_theme(row) if row else None


def get_group_identity(group_id):
    """Return {cover_photo, profile_photo} as `<img src>`-ready URLs
    for a specific group, or None if group_id is falsy or the group
    doesn't exist.

    Each column resolves independently: a group can upload just its
    cover and still get a generated profile SVG with its initials.
    The consuming template no longer needs to OR-fall-back to
    platform_identity — the generated SVG is the per-group default.
    """
    if not group_id:
        return None
    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT cover_photo, profile_photo FROM groups WHERE group_id = %s',
            (group_id,)
        )
        row = cursor.fetchone()
    if not row:
        return None
    return {
        'cover_photo':   _static_url(row['cover_photo'])   or _default_cover_url(group_id),
        'profile_photo': _static_url(row['profile_photo']) or _default_profile_url(group_id),
    }


# ── Theme presets (P2-41 Browse pre-made theme gallery) ─────────────────────

_PRESET_COLUMNS = (
    'preset_id, name, description, '
    'primary_color, secondary_color, background_color, '
    'button_style, font_heading, font_body, nav_position, content_width, '
    'display_order'
)

# Themable columns that define a theme's identity. Used by
# find_matching_preset to decide whether a group's current effective
# theme is one of the canned presets or a custom one. Both
# nav_position and content_width participate — Coastal (sidebar+full)
# and Tussock (topbar+full) share content_width but not nav_position,
# so the match comparison must check both.
_THEME_MATCH_KEYS = (
    'primary_color', 'secondary_color', 'background_color',
    'button_style', 'font_heading', 'font_body',
    'nav_position', 'content_width',
)


def list_presets():
    """Return every preset row, ordered for gallery display."""
    with db.get_cursor() as cursor:
        cursor.execute(
            f'SELECT {_PRESET_COLUMNS} FROM theme_presets '
            'ORDER BY display_order, preset_id'
        )
        return cursor.fetchall()


def get_preset(preset_id):
    """Return a single preset row or None if no such id."""
    with db.get_cursor() as cursor:
        cursor.execute(
            f'SELECT {_PRESET_COLUMNS} FROM theme_presets WHERE preset_id = %s',
            (preset_id,)
        )
        return cursor.fetchone()


def get_reset_baseline_for_preset(preset_id):
    """Return the canonical "Reset to <preset>" baseline for the editor.

    For Default Tiaki (preset_id = 1) the DB row drifts whenever a
    Super Admin customises the platform default — we sync the preset
    row to keep the gallery tile honest. So reading get_preset(1) after
    a customisation returns the customised values, which would defeat
    the Reset button entirely. Return the hardcoded
    PLATFORM_DEFAULT_THEME constant instead so "Reset to Default Tiaki"
    always means original Tiaki styling, regardless of platform state.

    For any other preset the DB row is the source of truth (those rows
    are immutable seed themes — nothing in the app mutates them).
    """
    if preset_id == _DEFAULT_TIAKI_PRESET_ID:
        # The constant has the same eight themable columns the template
        # data-reset-* attrs read, so it's a drop-in for a preset row.
        return dict(PLATFORM_DEFAULT_THEME)
    return get_preset(preset_id)


def get_group_based_on_preset(group_id):
    """Return the group's `based_on_preset` value (int or None).

    This is the *lineage* marker — set by apply_preset and preserved
    across save_custom_theme. The gallery uses this to flag a preset
    as the group's active theme even when the coordinator has
    customised some columns since applying it (find_matching_preset
    would return None in that case; based_on_preset keeps the
    relationship visible).
    """
    if not group_id:
        return None
    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT based_on_preset FROM group_themes WHERE group_id = %s',
            (group_id,)
        )
        row = cursor.fetchone()
    return row['based_on_preset'] if row else None


def get_platform_based_on_preset():
    """Return platform_theme.based_on_preset (int or None).

    Same lineage marker as get_group_based_on_preset, but for the
    singleton platform_theme row. Used by the gallery when the
    Super Admin's active target is the platform default, so the
    "Active" badge still surfaces if the platform is on a preset.
    """
    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT based_on_preset FROM platform_theme WHERE id = 1'
        )
        row = cursor.fetchone()
    return row['based_on_preset'] if row else None


def find_matching_preset(current_theme, presets):
    """Return the preset_id whose six themable columns exactly match
    `current_theme`, or None if the group is on a custom theme.

    `current_theme` is the dict returned by get_active_theme() — i.e. the
    group's effective theme after the group_themes → platform_theme
    fallback chain has resolved.
    """
    for p in presets:
        if all(p[k] == current_theme.get(k) for k in _THEME_MATCH_KEYS):
            return p['preset_id']
    return None


# ── Theme target resolution (Super Admin admin path) ────────────────────────
# Coordinators always operate on their own group — session['group_id'] is set
# at login and the theme routes have always read it directly. Super Admins
# without a group membership land on /admin/dashboard with no group_id in
# session, so the theme routes couldn't run for them at all.
#
# resolve_theme_target() bridges that: Coordinators see the same group they
# always did; Super Admins read three dedicated session keys
# (theme_target_type / theme_target_group_id / theme_target_name) that the
# picker page sets. The keys are deliberately separate from session['group_id']
# so a Super Admin managing Group X's brand doesn't see their own dashboard
# flip into that brand — the inject_theme_identity context processor still
# reads group_id, not these target keys.


def resolve_theme_target(session):
    """Return the theme target the current request should operate on.

    Shape:
      {'type': 'group',    'group_id': <int>, 'name': <str>}
      {'type': 'platform', 'group_id': None,  'name': 'Platform default'}
      None — Super Admin hasn't picked yet; caller redirects to picker.

    For a Coordinator (or any non–Super Admin role allowed by the route
    gate) the answer is always the group from session — same data the
    routes have always used, new wrapper shape. For a Super Admin the
    answer comes from the dedicated theme_target_* session keys.
    """
    if session.get('group_role') == 'Super Admin':
        t = session.get('theme_target_type')
        if t == 'platform':
            return {'type': 'platform', 'group_id': None,
                    'name': 'Platform default'}
        if t == 'group' and session.get('theme_target_group_id'):
            return {'type': 'group',
                    'group_id': session['theme_target_group_id'],
                    'name': (session.get('theme_target_name')
                             or f"Group #{session['theme_target_group_id']}")}
        return None

    if session.get('group_id'):
        return {'type': 'group',
                'group_id': session['group_id'],
                'name': session.get('group_name')}
    return None


def list_active_groups():
    """Every active group (group_id + name), ordered by name.

    Used by the Super Admin picker and the header switcher. Trimmed
    version of admin.py's admin_groups() query — no member counts or
    coordinator aggregation, since the picker just needs a clickable
    list.
    """
    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT group_id, name FROM groups '
            'WHERE is_active = TRUE ORDER BY name ASC'
        )
        return cursor.fetchall()


def is_active_group(group_id):
    """Return True if group_id exists and is_active. Used by the picker
    setter to reject pointing the target at a deleted/inactive group."""
    if not group_id:
        return False
    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT name FROM groups WHERE group_id = %s AND is_active = TRUE',
            (group_id,)
        )
        return cursor.fetchone() is not None


def get_group_name(group_id):
    """Return the group's name, or None if not found. Used by the
    picker setter to cache the display label in session."""
    if not group_id:
        return None
    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT name FROM groups WHERE group_id = %s',
            (group_id,)
        )
        row = cursor.fetchone()
    return row['name'] if row else None


# ── Target dispatch helpers ─────────────────────────────────────────────────
# Routes call these instead of branching on target['type'] themselves. Keeps
# the group/platform fork in one place; routes read like the original
# group-only flow with `target` substituted for `group_id`. apply_preset and
# save_custom_theme stay untouched so existing call sites keep working.


def get_target_theme(target):
    """Effective theme for a target dict. Mirrors get_active_theme but
    routes platform targets to platform_theme directly."""
    if target['type'] == 'platform':
        return get_platform_theme()
    return get_active_theme(target['group_id'])


def get_target_based_on_preset(target):
    """Lineage marker for a target dict — either group_themes or
    platform_theme depending on type."""
    if target['type'] == 'platform':
        return get_platform_based_on_preset()
    return get_group_based_on_preset(target['group_id'])


def apply_preset_to_target(target, preset_id, user_id):
    """Apply a preset to whatever the target points at. Returns the
    preset's name on success. Raises PresetNotFound if preset_id is
    unknown. Wraps the existing apply_preset / apply_preset_to_platform
    pair so route handlers stay branchless."""
    if target['type'] == 'platform':
        return apply_preset_to_platform(preset_id, user_id)
    return apply_preset(target['group_id'], preset_id, user_id)


def save_custom_target_theme(target, theme_values, based_on_preset, user_id):
    """Save a customised theme to whatever the target points at.
    Wraps save_custom_theme / save_custom_platform_theme so route
    handlers stay branchless. Raises ValidationError on bad input."""
    if target['type'] == 'platform':
        return save_custom_platform_theme(theme_values, based_on_preset, user_id)
    return save_custom_theme(target['group_id'], theme_values,
                              based_on_preset, user_id)


# ── Apply a preset (P2-42) ──────────────────────────────────────────────────

class PresetNotFound(LookupError):
    """Raised by apply_preset when the preset_id doesn't exist."""


# Columns selected for the history snapshot. `based_on_preset` is pulled
# alongside the six themable columns so the previous theme's lineage is
# preserved — if the group was on, say, "Forest", and switches to "Coastal",
# the history row still records that the *previous* row was based on
# "Forest" (preset_id 2 or whatever).
_SNAPSHOT_COLUMNS = (
    'primary_color, secondary_color, background_color, '
    'button_style, font_heading, font_body, nav_position, content_width, '
    'based_on_preset'
)


def apply_preset(group_id, preset_id, user_id):
    """Apply a preset to a group. Returns the preset's name on success.

    Atomic, in order:
      a. Read the group's CURRENT effective theme (group_themes if present,
         else platform_theme).
      b. INSERT a snapshot of that effective theme into theme_history with
         saved_at = NOW(), saved_by = user_id, based_on_preset = the
         previous theme's based_on_preset (NULL when the previous theme
         came from platform_theme).
      c. UPSERT group_themes with the preset's values + based_on_preset =
         preset_id + updated_at = NOW() + updated_by = user_id.
      d. Cap theme_history at the most recent 10 rows per group_id by
         deleting anything older.

    All three writes commit together or none of them do.

    Raises PresetNotFound if preset_id doesn't exist. Lets the underlying
    psycopg2 exception propagate (after rollback) for any DB-level failure
    — the route handler logs and surfaces a generic flash.
    """
    preset = get_preset(preset_id)
    if not preset:
        raise PresetNotFound(preset_id)

    # ── Read the effective current theme + its based_on_preset.
    # We can't reuse get_active_theme() because it doesn't surface
    # based_on_preset (P2-41 helper is intentionally untouched).
    with db.get_cursor() as cursor:
        cursor.execute(
            f'SELECT {_SNAPSHOT_COLUMNS} '
            'FROM group_themes WHERE group_id = %s',
            (group_id,)
        )
        current = cursor.fetchone()
    if not current:
        with db.get_cursor() as cursor:
            cursor.execute(
                'SELECT primary_color, secondary_color, background_color, '
                'button_style, font_heading, font_body, '
                'nav_position, content_width, '
                'NULL::INTEGER AS based_on_preset '
                'FROM platform_theme WHERE id = 1'
            )
            current = cursor.fetchone()

    # ── Atomic write block. First and only place in the codebase that
    # toggles autocommit off; the finally-restore keeps the connection's
    # behaviour unchanged for any further work in this request, and the
    # connection is per-request anyway (db.close_db on teardown).
    conn = db.get_db()
    prev_autocommit = conn.autocommit
    conn.autocommit = False
    try:
        with db.get_cursor() as cursor:
            # Step b — snapshot the PREVIOUS effective theme into history.
            cursor.execute(
                'INSERT INTO theme_history '
                '(group_id, primary_color, secondary_color, '
                ' background_color, button_style, font_heading, font_body, '
                ' nav_position, content_width, '
                ' based_on_preset, saved_at, saved_by) '
                'VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, NOW(), %s)',
                (group_id,
                 current['primary_color'], current['secondary_color'],
                 current['background_color'], current['button_style'],
                 current['font_heading'], current['font_body'],
                 current['nav_position'], current['content_width'],
                 current['based_on_preset'], user_id)
            )

            # Step c — UPSERT group_themes with the new preset values.
            # group_id is the PK so ON CONFLICT (group_id) handles both
            # "no row yet" and "row exists" in one statement.
            cursor.execute(
                'INSERT INTO group_themes '
                '(group_id, primary_color, secondary_color, '
                ' background_color, button_style, font_heading, font_body, '
                ' nav_position, content_width, '
                ' based_on_preset, updated_at, updated_by) '
                'VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, NOW(), %s) '
                'ON CONFLICT (group_id) DO UPDATE SET '
                '  primary_color    = EXCLUDED.primary_color, '
                '  secondary_color  = EXCLUDED.secondary_color, '
                '  background_color = EXCLUDED.background_color, '
                '  button_style     = EXCLUDED.button_style, '
                '  font_heading     = EXCLUDED.font_heading, '
                '  font_body        = EXCLUDED.font_body, '
                '  nav_position     = EXCLUDED.nav_position, '
                '  content_width    = EXCLUDED.content_width, '
                '  based_on_preset  = EXCLUDED.based_on_preset, '
                '  updated_at       = EXCLUDED.updated_at, '
                '  updated_by       = EXCLUDED.updated_by',
                (group_id,
                 preset['primary_color'], preset['secondary_color'],
                 preset['background_color'], preset['button_style'],
                 preset['font_heading'], preset['font_body'],
                 preset['nav_position'], preset['content_width'],
                 preset_id, user_id)
            )

            # Step d — cap auto-snapshots at HISTORY_CAP per group.
            # Pinned rows (is_pinned = TRUE, written by
            # save_current_as_pinned) are exempt: both the count and the
            # deletion target only NOT is_pinned rows. OFFSET handles
            # "no-op when ≤ HISTORY_CAP" and "delete the surplus" in
            # one statement.
            cursor.execute(
                'DELETE FROM theme_history WHERE history_id IN ('
                '  SELECT history_id FROM theme_history '
                '  WHERE group_id = %s AND NOT is_pinned '
                '  ORDER BY saved_at DESC, history_id DESC '
                f'  OFFSET {HISTORY_CAP}'
                ')',
                (group_id,)
            )
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.autocommit = prev_autocommit

    return preset['name']


# The "Default Tiaki" preset row is treated as the visible identity of
# the platform default theme — its column values are kept in sync with
# platform_theme so the gallery's Default Tiaki tile always reflects
# what the platform currently looks like. Other presets (Forest /
# Coastal / Tussock / Pōhutukawa) stay immutable seed themes.
_DEFAULT_TIAKI_PRESET_ID = 1


def _sync_default_tiaki_preset(cursor, primary, secondary, background,
                               button_style, font_heading, font_body,
                               nav_position, content_width):
    """Mirror the eight themable columns into the Default Tiaki preset row.

    Called from inside the same transaction as a platform_theme write so
    the two stay consistent. `name`, `description`, `preview_image`,
    `display_order` are intentionally NOT touched — only the visual
    columns. If preset_id 1 has been deleted, this UPDATE is a no-op
    (rowcount 0) and the platform write still succeeds.
    """
    cursor.execute(
        'UPDATE theme_presets SET '
        '  primary_color    = %s, '
        '  secondary_color  = %s, '
        '  background_color = %s, '
        '  button_style     = %s, '
        '  font_heading     = %s, '
        '  font_body        = %s, '
        '  nav_position     = %s, '
        '  content_width    = %s '
        'WHERE preset_id = %s',
        (primary, secondary, background, button_style,
         font_heading, font_body, nav_position, content_width,
         _DEFAULT_TIAKI_PRESET_ID)
    )


def apply_preset_to_platform(preset_id, user_id):
    """Apply a preset to the singleton platform_theme. Returns its name.

    Sibling of apply_preset for the Super Admin "Platform default"
    target. Same UPSERT shape, but writes to platform_theme (id = 1)
    instead of group_themes, and skips the theme_history snapshot
    + cap — platform history is deferred (platform_theme is low-churn;
    theme_history.group_id is NOT NULL so a platform snapshot would
    need a schema change). `based_on_preset` lineage is preserved
    exactly like in the group path.

    The Default Tiaki preset row is also kept in sync — the gallery's
    Default Tiaki tile is treated as the visible identity of the
    platform default. Wrapped in a transaction so the two writes
    commit together.
    """
    preset = get_preset(preset_id)
    if not preset:
        raise PresetNotFound(preset_id)

    conn = db.get_db()
    prev_autocommit = conn.autocommit
    conn.autocommit = False
    try:
        with db.get_cursor() as cursor:
            cursor.execute(
                'INSERT INTO platform_theme '
                '(id, primary_color, secondary_color, '
                ' background_color, button_style, font_heading, font_body, '
                ' nav_position, content_width, '
                ' based_on_preset, updated_at, updated_by) '
                'VALUES (1, %s, %s, %s, %s, %s, %s, %s, %s, %s, NOW(), %s) '
                'ON CONFLICT (id) DO UPDATE SET '
                '  primary_color    = EXCLUDED.primary_color, '
                '  secondary_color  = EXCLUDED.secondary_color, '
                '  background_color = EXCLUDED.background_color, '
                '  button_style     = EXCLUDED.button_style, '
                '  font_heading     = EXCLUDED.font_heading, '
                '  font_body        = EXCLUDED.font_body, '
                '  nav_position     = EXCLUDED.nav_position, '
                '  content_width    = EXCLUDED.content_width, '
                '  based_on_preset  = EXCLUDED.based_on_preset, '
                '  updated_at       = EXCLUDED.updated_at, '
                '  updated_by       = EXCLUDED.updated_by',
                (preset['primary_color'], preset['secondary_color'],
                 preset['background_color'], preset['button_style'],
                 preset['font_heading'], preset['font_body'],
                 preset['nav_position'], preset['content_width'],
                 preset_id, user_id)
            )

            _sync_default_tiaki_preset(
                cursor,
                preset['primary_color'], preset['secondary_color'],
                preset['background_color'], preset['button_style'],
                preset['font_heading'], preset['font_body'],
                preset['nav_position'], preset['content_width'],
            )
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.autocommit = prev_autocommit

    return preset['name']


# ── Save a custom theme (P2-43) ─────────────────────────────────────────────

class ValidationError(ValueError):
    """Raised by save_custom_theme when one or more submitted fields fail
    validation. `.errors` is a dict keyed by form field name → user-facing
    message, so the route handler can both flash a generic message AND
    highlight specific inputs on re-render."""

    def __init__(self, errors):
        super().__init__('Theme validation failed')
        self.errors = errors


def _validate_theme_values(values):
    """Returns (clean_dict, errors_dict). errors_dict is empty on success.

    Server-side validation is authoritative — client-side select/radio
    constraints are hints only. Hex colours are normalised to lowercase
    so equality checks against preset rows in find_matching_preset are
    deterministic.
    """
    errors = {}
    clean = {}

    for key in ('primary_color', 'secondary_color', 'background_color'):
        v = (values.get(key) or '').strip()
        if not _HEX_RE.match(v):
            label = key.replace('_', ' ').capitalize()
            errors[key] = (
                f'{label} must be a 6-digit hex colour (e.g. #1a3a2e).'
            )
        else:
            clean[key] = v.lower()

    # Font validation accepts any value that's in either whitelist,
    # for either slot. The two whitelists exist to surface curated
    # heading-suitable vs body-suitable picks in the editor UI — they
    # do NOT restrict the underlying schema. Imports + single-font
    # editor saves both rely on this (the single-font shim writes the
    # picked value to both columns, so a body-suited font can land
    # in font_heading; on re-import that must still validate).
    allowed_fonts = set(FONT_HEADING_WHITELIST) | set(FONT_BODY_WHITELIST)

    if 'font_heading' in values or 'font_body' in values:
        heading = (values.get('font_heading') or '').strip()
        body = (values.get('font_body') or '').strip()
        if heading not in allowed_fonts:
            errors['font_heading'] = 'Pick a font from the supplied list.'
        else:
            clean['font_heading'] = heading
        if body not in allowed_fonts:
            errors['font_body'] = 'Pick a font from the supplied list.'
        else:
            clean['font_body'] = body
    else:
        font = (values.get('font_family') or '').strip()
        if font not in allowed_fonts:
            errors['font_family'] = 'Pick a font from the supplied list.'
        else:
            clean['font_heading'] = font
            clean['font_body'] = font

    btn = (values.get('button_style') or '').strip()
    if btn not in ('rounded', 'square'):
        errors['button_style'] = 'Button style must be rounded or square.'
    else:
        clean['button_style'] = btn

    nav = (values.get('nav_position') or '').strip()
    if nav not in ('sidebar', 'topbar'):
        errors['nav_position'] = 'Navigation position must be sidebar or top bar.'
    else:
        clean['nav_position'] = nav

    width = (values.get('content_width') or '').strip()
    if width not in ('wrap', 'full'):
        errors['content_width'] = 'Content width must be wrap or full.'
    else:
        clean['content_width'] = width

    return clean, errors


def save_custom_theme(group_id, theme_values, based_on_preset, user_id):
    """Save a coordinator-customised theme to group_themes.

    Same 3-step atomic shape as apply_preset:
      a. Read the group's CURRENT effective theme (group_themes if any,
         else platform_theme) + its based_on_preset.
      b. INSERT a snapshot of that previous theme into theme_history.
      c. UPSERT group_themes with the new values + based_on_preset
         (the caller decides whether it's NULL or a preset_id — spec
         says 'from scratch' → NULL, 'from preset' → that preset's id,
         preserved across customisation as the 'started from' marker).
      d. Cap theme_history at 10 per group.

    Raises ValidationError BEFORE any DB write if validation fails.
    All three writes commit together or none of them do.
    """
    clean, errors = _validate_theme_values(theme_values)
    if errors:
        raise ValidationError(errors)

    if based_on_preset is not None and not isinstance(based_on_preset, int):
        raise ValidationError({'based_on_preset': 'Invalid preset reference.'})

    # Read previous effective theme + its based_on_preset for the snapshot.
    # Mirrors the apply_preset pattern; can't reuse get_active_theme()
    # because it doesn't surface based_on_preset.
    with db.get_cursor() as cursor:
        cursor.execute(
            f'SELECT {_SNAPSHOT_COLUMNS} '
            'FROM group_themes WHERE group_id = %s',
            (group_id,)
        )
        previous = cursor.fetchone()
    if not previous:
        with db.get_cursor() as cursor:
            cursor.execute(
                'SELECT primary_color, secondary_color, background_color, '
                'button_style, font_heading, font_body, '
                'nav_position, content_width, '
                'NULL::INTEGER AS based_on_preset '
                'FROM platform_theme WHERE id = 1'
            )
            previous = cursor.fetchone()

    conn = db.get_db()
    prev_autocommit = conn.autocommit
    conn.autocommit = False
    try:
        with db.get_cursor() as cursor:
            # Step b — snapshot the previous theme into history.
            cursor.execute(
                'INSERT INTO theme_history '
                '(group_id, primary_color, secondary_color, '
                ' background_color, button_style, font_heading, font_body, '
                ' nav_position, content_width, '
                ' based_on_preset, saved_at, saved_by) '
                'VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, NOW(), %s)',
                (group_id,
                 previous['primary_color'], previous['secondary_color'],
                 previous['background_color'], previous['button_style'],
                 previous['font_heading'], previous['font_body'],
                 previous['nav_position'], previous['content_width'],
                 previous['based_on_preset'], user_id)
            )

            # Step c — UPSERT group_themes with the customised values.
            cursor.execute(
                'INSERT INTO group_themes '
                '(group_id, primary_color, secondary_color, '
                ' background_color, button_style, font_heading, font_body, '
                ' nav_position, content_width, '
                ' based_on_preset, updated_at, updated_by) '
                'VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, NOW(), %s) '
                'ON CONFLICT (group_id) DO UPDATE SET '
                '  primary_color    = EXCLUDED.primary_color, '
                '  secondary_color  = EXCLUDED.secondary_color, '
                '  background_color = EXCLUDED.background_color, '
                '  button_style     = EXCLUDED.button_style, '
                '  font_heading     = EXCLUDED.font_heading, '
                '  font_body        = EXCLUDED.font_body, '
                '  nav_position     = EXCLUDED.nav_position, '
                '  content_width    = EXCLUDED.content_width, '
                '  based_on_preset  = EXCLUDED.based_on_preset, '
                '  updated_at       = EXCLUDED.updated_at, '
                '  updated_by       = EXCLUDED.updated_by',
                (group_id,
                 clean['primary_color'], clean['secondary_color'],
                 clean['background_color'], clean['button_style'],
                 clean['font_heading'], clean['font_body'],
                 clean['nav_position'], clean['content_width'],
                 based_on_preset, user_id)
            )

            # Step d — cap auto-snapshots at HISTORY_CAP per group.
            # See note in apply_preset; pinned rows are exempt.
            cursor.execute(
                'DELETE FROM theme_history WHERE history_id IN ('
                '  SELECT history_id FROM theme_history '
                '  WHERE group_id = %s AND NOT is_pinned '
                '  ORDER BY saved_at DESC, history_id DESC '
                f'  OFFSET {HISTORY_CAP}'
                ')',
                (group_id,)
            )
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.autocommit = prev_autocommit


def save_custom_platform_theme(theme_values, based_on_preset, user_id):
    """Save a coordinator-customised theme to platform_theme (singleton).

    Sibling of save_custom_theme for the Super Admin "Platform default"
    target. Same validation pass + UPSERT shape, but writes to
    platform_theme (id = 1) instead of group_themes, and skips the
    history snapshot + cap — platform history is deferred (see
    apply_preset_to_platform). `based_on_preset` lineage is preserved
    exactly like in the group path.

    Also mirrors the column values into the Default Tiaki preset row
    (preset_id = 1) so the gallery's Default Tiaki tile stays in sync
    with the live platform default. Wrapped in a transaction so both
    writes commit together.
    """
    clean, errors = _validate_theme_values(theme_values)
    if errors:
        raise ValidationError(errors)

    if based_on_preset is not None and not isinstance(based_on_preset, int):
        raise ValidationError({'based_on_preset': 'Invalid preset reference.'})

    conn = db.get_db()
    prev_autocommit = conn.autocommit
    conn.autocommit = False
    try:
        with db.get_cursor() as cursor:
            cursor.execute(
                'INSERT INTO platform_theme '
                '(id, primary_color, secondary_color, '
                ' background_color, button_style, font_heading, font_body, '
                ' nav_position, content_width, '
                ' based_on_preset, updated_at, updated_by) '
                'VALUES (1, %s, %s, %s, %s, %s, %s, %s, %s, %s, NOW(), %s) '
                'ON CONFLICT (id) DO UPDATE SET '
                '  primary_color    = EXCLUDED.primary_color, '
                '  secondary_color  = EXCLUDED.secondary_color, '
                '  background_color = EXCLUDED.background_color, '
                '  button_style     = EXCLUDED.button_style, '
                '  font_heading     = EXCLUDED.font_heading, '
                '  font_body        = EXCLUDED.font_body, '
                '  nav_position     = EXCLUDED.nav_position, '
                '  content_width    = EXCLUDED.content_width, '
                '  based_on_preset  = EXCLUDED.based_on_preset, '
                '  updated_at       = EXCLUDED.updated_at, '
                '  updated_by       = EXCLUDED.updated_by',
                (clean['primary_color'], clean['secondary_color'],
                 clean['background_color'], clean['button_style'],
                 clean['font_heading'], clean['font_body'],
                 clean['nav_position'], clean['content_width'],
                 based_on_preset, user_id)
            )

            _sync_default_tiaki_preset(
                cursor,
                clean['primary_color'], clean['secondary_color'],
                clean['background_color'], clean['button_style'],
                clean['font_heading'], clean['font_body'],
                clean['nav_position'], clean['content_width'],
            )
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.autocommit = prev_autocommit


# ── Customise history (Save-as-Preset + Restore) ────────────────────────────
# Surfaces the existing theme_history snapshots to coordinators via the
# /coordinator/themes/history page. Auto-snapshots (name IS NULL,
# is_pinned = FALSE) accumulate from apply_preset / save_custom_theme and
# trim to the most recent HISTORY_CAP per group. Pinned rows (named,
# is_pinned = TRUE) are written by save_current_as_pinned and never
# auto-trim — they're the coordinator's archive of "monthly"
# customisations.

class HistoryNotFound(LookupError):
    """Raised when a history_id doesn't exist for the given group."""


_HISTORY_LIST_COLUMNS = (
    'history_id, group_id, '
    'primary_color, secondary_color, background_color, '
    'button_style, font_heading, font_body, nav_position, content_width, '
    'based_on_preset, name, is_pinned, saved_at, saved_by'
)


def list_group_history(group_id):
    """Return every theme_history row for a group, pinned first.

    Ordering matches the theme_history_group_pinned_saved index so the page
    template can split the rows into "Saved themes" and "Recent
    customisations" in one pass without re-sorting.
    """
    if not group_id:
        return []
    with db.get_cursor() as cursor:
        cursor.execute(
            f'SELECT {_HISTORY_LIST_COLUMNS} FROM theme_history '
            'WHERE group_id = %s '
            'ORDER BY is_pinned DESC, saved_at DESC, history_id DESC',
            (group_id,)
        )
        rows = cursor.fetchall()
    # Derive button_radius the same way _shape_theme does so the history
    # template can render a faithful preview swatch + button corner sample.
    return [_shape_theme(r) for r in rows]


def get_history_entry(group_id, history_id):
    """Fetch one history row scoped to the group. Returns None if missing."""
    if not group_id or not history_id:
        return None
    with db.get_cursor() as cursor:
        cursor.execute(
            f'SELECT {_HISTORY_LIST_COLUMNS} FROM theme_history '
            'WHERE history_id = %s AND group_id = %s',
            (history_id, group_id)
        )
        row = cursor.fetchone()
    return _shape_theme(row) if row else None


def save_current_as_pinned(group_id, user_id, name):
    """Snapshot the group's CURRENT effective theme as a pinned history row.

    `name` is required (CHECK th_pinned_requires_name) and trimmed/validated
    here. The snapshot mirrors the auto-snapshot shape used by apply_preset
    / save_custom_theme — same column set, same based_on_preset preservation
    — but with `name` set and `is_pinned = TRUE`, exempting it from the
    auto-snapshot cap. Returns the new history_id.

    If the group has no group_themes row yet, the snapshot uses the platform
    fallback so the coordinator can still pin "the look I have right now",
    even on first visit.
    """
    clean_name = (name or '').strip()
    if not clean_name:
        raise ValidationError({'name': 'Give this snapshot a name to save it.'})
    if len(clean_name) > 80:
        raise ValidationError({'name': 'Name must be 80 characters or fewer.'})

    with db.get_cursor() as cursor:
        cursor.execute(
            f'SELECT {_SNAPSHOT_COLUMNS} FROM group_themes WHERE group_id = %s',
            (group_id,)
        )
        current = cursor.fetchone()
    if not current:
        with db.get_cursor() as cursor:
            cursor.execute(
                'SELECT primary_color, secondary_color, background_color, '
                'button_style, font_heading, font_body, '
                'nav_position, content_width, '
                'NULL::INTEGER AS based_on_preset '
                'FROM platform_theme WHERE id = 1'
            )
            current = cursor.fetchone()

    with db.get_cursor() as cursor:
        cursor.execute(
            'INSERT INTO theme_history '
            '(group_id, primary_color, secondary_color, '
            ' background_color, button_style, font_heading, font_body, '
            ' nav_position, content_width, '
            ' based_on_preset, name, is_pinned, saved_at, saved_by) '
            'VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, TRUE, NOW(), %s) '
            'RETURNING history_id',
            (group_id,
             current['primary_color'], current['secondary_color'],
             current['background_color'], current['button_style'],
             current['font_heading'], current['font_body'],
             current['nav_position'], current['content_width'],
             current['based_on_preset'], clean_name, user_id)
        )
        return cursor.fetchone()['history_id']


def restore_from_history(group_id, history_id, user_id):
    """Apply a history snapshot to group_themes.

    Same 3-step atomic shape as apply_preset:
      a. Read the target history row (scoped to group_id).
      b. Snapshot the group's CURRENT effective theme into history so the
         restore is itself reversible.
      c. UPSERT group_themes with the snapshot's values, preserving its
         based_on_preset lineage (so the gallery still flags the originating
         preset as "Active" after a restore).
      d. Cap auto-snapshots at HISTORY_CAP per group; pinned rows
         (including the source row, if it was pinned) are exempt.

    Raises HistoryNotFound if history_id doesn't exist for the group.
    """
    snapshot = get_history_entry(group_id, history_id)
    if not snapshot:
        raise HistoryNotFound(history_id)

    with db.get_cursor() as cursor:
        cursor.execute(
            f'SELECT {_SNAPSHOT_COLUMNS} FROM group_themes WHERE group_id = %s',
            (group_id,)
        )
        previous = cursor.fetchone()
    if not previous:
        with db.get_cursor() as cursor:
            cursor.execute(
                'SELECT primary_color, secondary_color, background_color, '
                'button_style, font_heading, font_body, '
                'nav_position, content_width, '
                'NULL::INTEGER AS based_on_preset '
                'FROM platform_theme WHERE id = 1'
            )
            previous = cursor.fetchone()

    conn = db.get_db()
    prev_autocommit = conn.autocommit
    conn.autocommit = False
    try:
        with db.get_cursor() as cursor:
            # Step b — snapshot the pre-restore theme into history.
            cursor.execute(
                'INSERT INTO theme_history '
                '(group_id, primary_color, secondary_color, '
                ' background_color, button_style, font_heading, font_body, '
                ' nav_position, content_width, '
                ' based_on_preset, saved_at, saved_by) '
                'VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, NOW(), %s)',
                (group_id,
                 previous['primary_color'], previous['secondary_color'],
                 previous['background_color'], previous['button_style'],
                 previous['font_heading'], previous['font_body'],
                 previous['nav_position'], previous['content_width'],
                 previous['based_on_preset'], user_id)
            )

            # Step c — UPSERT group_themes with the snapshot's values.
            cursor.execute(
                'INSERT INTO group_themes '
                '(group_id, primary_color, secondary_color, '
                ' background_color, button_style, font_heading, font_body, '
                ' nav_position, content_width, '
                ' based_on_preset, updated_at, updated_by) '
                'VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, NOW(), %s) '
                'ON CONFLICT (group_id) DO UPDATE SET '
                '  primary_color    = EXCLUDED.primary_color, '
                '  secondary_color  = EXCLUDED.secondary_color, '
                '  background_color = EXCLUDED.background_color, '
                '  button_style     = EXCLUDED.button_style, '
                '  font_heading     = EXCLUDED.font_heading, '
                '  font_body        = EXCLUDED.font_body, '
                '  nav_position     = EXCLUDED.nav_position, '
                '  content_width    = EXCLUDED.content_width, '
                '  based_on_preset  = EXCLUDED.based_on_preset, '
                '  updated_at       = EXCLUDED.updated_at, '
                '  updated_by       = EXCLUDED.updated_by',
                (group_id,
                 snapshot['primary_color'], snapshot['secondary_color'],
                 snapshot['background_color'], snapshot['button_style'],
                 snapshot['font_heading'], snapshot['font_body'],
                 snapshot['nav_position'], snapshot['content_width'],
                 snapshot['based_on_preset'], user_id)
            )

            # Step d — cap auto-snapshots at HISTORY_CAP per group.
            cursor.execute(
                'DELETE FROM theme_history WHERE history_id IN ('
                '  SELECT history_id FROM theme_history '
                '  WHERE group_id = %s AND NOT is_pinned '
                '  ORDER BY saved_at DESC, history_id DESC '
                f'  OFFSET {HISTORY_CAP}'
                ')',
                (group_id,)
            )
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.autocommit = prev_autocommit

    return snapshot


def delete_history_entry(group_id, history_id):
    """Remove a history row. Used to unpin/delete a saved theme.

    Scoped to group_id so a coordinator can't delete another group's row by
    guessing the id. Returns True if a row was deleted, False if no match.
    """
    if not group_id or not history_id:
        return False
    with db.get_cursor() as cursor:
        cursor.execute(
            'DELETE FROM theme_history '
            'WHERE history_id = %s AND group_id = %s',
            (history_id, group_id)
        )
        return cursor.rowcount > 0


def list_pinned_for_group(group_id):
    """Pinned-only history rows for a group, newest first.

    Used by the gallery to surface "Saved themes" as their own section.
    Trims list_group_history's two-section output down to just the
    named/archived snapshots so the gallery never mixes them with the
    auto-rolling recent snapshots (those stay on the history page).
    """
    if not group_id:
        return []
    with db.get_cursor() as cursor:
        cursor.execute(
            f'SELECT {_HISTORY_LIST_COLUMNS} FROM theme_history '
            'WHERE group_id = %s AND is_pinned = TRUE '
            'ORDER BY saved_at DESC, history_id DESC',
            (group_id,)
        )
        return [_shape_theme(r) for r in cursor.fetchall()]


def apply_saved_theme_to_target(target, history_id, user_id):
    """Apply a pinned theme_history row's column values to the target.

    Different shape from restore_from_history: restore re-applies a
    snapshot inside its own group (and writes a fresh snapshot of the
    pre-restore state). This helper is the gallery "Use this saved
    theme" action — it writes the chosen pinned row's values to the
    current target via save_custom_target_theme so the same atomic
    snapshot+cap behaviour as a manual editor save applies.

    The pinned row's `based_on_preset` lineage is preserved (so the
    gallery's Active badge still surfaces on the originating preset).

    Raises HistoryNotFound if the history_id isn't a pinned row of the
    group it claims to belong to. Returns the row's `name` on success
    so the route can flash it back.

    Note: pinned rows are group-scoped (theme_history.group_id NOT NULL),
    so this helper rejects platform targets — there's nothing to apply
    from. The caller should gate at the route level for a clearer error.
    """
    if target['type'] == 'platform':
        raise ValueError("Saved themes can't be applied to the platform "
                         "default target (saved themes are group-scoped).")
    if not history_id:
        raise HistoryNotFound(history_id)

    with db.get_cursor() as cursor:
        cursor.execute(
            f'SELECT {_HISTORY_LIST_COLUMNS} FROM theme_history '
            'WHERE history_id = %s AND is_pinned = TRUE',
            (history_id,)
        )
        row = cursor.fetchone()
    if not row:
        raise HistoryNotFound(history_id)
    snapshot = _shape_theme(row)

    # save_custom_target_theme handles validation + group snapshot + cap
    # for group targets. For the column shape it expects the same dict
    # the editor POST produces; remap a couple of keys.
    payload = {
        'primary_color':    snapshot['primary_color'],
        'secondary_color':  snapshot['secondary_color'],
        'background_color': snapshot['background_color'],
        'button_style':     snapshot['button_style'],
        'font_heading':     snapshot['font_heading'],
        'font_body':        snapshot['font_body'],
        'nav_position':     snapshot['nav_position'],
        'content_width':    snapshot['content_width'],
    }
    save_custom_target_theme(
        target, payload, snapshot['based_on_preset'], user_id
    )
    return snapshot['name']
