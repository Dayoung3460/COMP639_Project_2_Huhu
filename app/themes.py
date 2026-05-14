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

from app import db


# Hardcoded fallbacks when both the per-group row and platform_settings
# leave a column NULL. Paths are relative to /static/ to stay consistent
# with the DB convention.
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

_HEX_RE = re.compile(r'^#[0-9A-Fa-f]{6}$')

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


def get_active_identity(group_id=None):
    """Return {cover_photo, profile_photo} as paths relative to /static/.

    Each column resolves independently — a group can override just the
    cover and inherit the platform default profile photo, or vice versa.

    Fallback chain per column: groups → platform_settings → hardcoded
    DEFAULT_* constants.
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
        'cover_photo':   cover   or DEFAULT_COVER_PHOTO,
        'profile_photo': profile or DEFAULT_PROFILE_PHOTO,
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
    """Return {cover_photo, profile_photo} from platform_settings,
    with hardcoded defaults filling any NULL. Never None."""
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
        pass  # fall through to constant defaults
    return {
        'cover_photo':   cover   or DEFAULT_COVER_PHOTO,
        'profile_photo': profile or DEFAULT_PROFILE_PHOTO,
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
    """Return {cover_photo, profile_photo} read directly from the groups
    row, or None if group_id is falsy or the group doesn't exist. Values
    can themselves be None — the consuming template handles per-field
    fallback against platform_identity."""
    if not group_id:
        return None
    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT cover_photo, profile_photo FROM groups WHERE group_id = %s',
            (group_id,)
        )
        return cursor.fetchone()


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

            # Step d — cap auto-snapshots at 7 per group. Pinned rows
            # (is_pinned = TRUE, written by save_current_as_pinned) are
            # exempt: both the count and the deletion target only
            # NOT is_pinned rows. OFFSET handles "no-op when ≤ 7" and
            # "delete the surplus when > 7" in one statement.
            cursor.execute(
                'DELETE FROM theme_history WHERE history_id IN ('
                '  SELECT history_id FROM theme_history '
                '  WHERE group_id = %s AND NOT is_pinned '
                '  ORDER BY saved_at DESC, history_id DESC '
                '  OFFSET 7'
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

            # Step d — cap auto-snapshots at 7 per group. See note in
            # apply_preset; pinned rows are exempt.
            cursor.execute(
                'DELETE FROM theme_history WHERE history_id IN ('
                '  SELECT history_id FROM theme_history '
                '  WHERE group_id = %s AND NOT is_pinned '
                '  ORDER BY saved_at DESC, history_id DESC '
                '  OFFSET 7'
                ')',
                (group_id,)
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
# trim to the most recent 7 per group. Pinned rows (named, is_pinned = TRUE)
# are written by save_current_as_pinned and never auto-trim — they're the
# coordinator's archive of "monthly" customisations.

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
    7-row cap. Returns the new history_id.

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
      d. Cap auto-snapshots at 7 per group; pinned rows (including the
         source row, if it was pinned) are exempt.

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

            # Step d — cap auto-snapshots at 7 per group.
            cursor.execute(
                'DELETE FROM theme_history WHERE history_id IN ('
                '  SELECT history_id FROM theme_history '
                '  WHERE group_id = %s AND NOT is_pinned '
                '  ORDER BY saved_at DESC, history_id DESC '
                '  OFFSET 7'
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
