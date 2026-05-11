"""themes.py — Custom Themes epic, foundation.

Two pure read helpers consumed by the `inject_theme_identity` context
processor in `app/__init__.py`. They surface the active group's theme
+ identity (cover / profile photos) into every template render.

Schema assumptions (applied out-of-band; not yet in
`sql/create_tables.sql`):

  group_themes      (group_id PK, primary_color, secondary_color,
                     background_color, button_style ENUM
                     button_style_type 'rounded'|'square', font_family,
                     layout_template)
  platform_theme    — same columns, singleton row enforced by
                       CHECK (id = 1)
  platform_settings — (id PK CHECK (id = 1), cover_photo, profile_photo, …)
  groups.cover_photo, groups.profile_photo — paths relative to /static/

All photo paths are relative to `/static/`. Templates always wrap
the returned string with `url_for('static', filename=…)`.
"""

from app import db


# Hardcoded fallbacks when both the per-group row and platform_settings
# leave a column NULL. Paths are relative to /static/ to stay consistent
# with the DB convention.
DEFAULT_COVER_PHOTO   = 'images/default-cover.jpg'
DEFAULT_PROFILE_PHOTO = 'images/default-profile.png'

# Used by the context processor's exception path so pages still render
# themed-by-default if the DB is unreachable mid-request.
PLATFORM_DEFAULT_THEME = {
    'primary_color':    '#1a3a2e',
    'secondary_color':  '#c65d3c',
    'background_color': '#f5f0e6',
    'button_style':     'rounded',
    'button_radius':    '8px',
    'font_family':      'IBM Plex Sans',
    'layout_template':  'default',
}

_THEME_COLUMNS = (
    'primary_color, secondary_color, background_color, '
    'button_style, font_family, layout_template'
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
