"""identity_defaults.py — generated default cover + logo SVGs.

When a group hasn't uploaded its own cover or profile photo, the
identity cascade resolves to one of the routes below — an on-the-fly
SVG built from the group's name and theme colours. The result is:
  • Profile (logo): a solid circle in the theme's primary, with the
    group's 1–3 letter initials in white.
  • Cover: a primary→secondary linear gradient with a white disc in
    the middle and the same initials, tinted in the theme primary.

Public — no auth required (so an <img> tag works on logged-out
marketing pages and reuses the browser HTTP cache). Tiny payload
(~600 bytes) plus a short `Cache-Control: max-age=300` so changes to
the underlying theme propagate within a few minutes.
"""

import html

from flask import Response

from app import app, themes


# ── Helpers ────────────────────────────────────────────────────────────────


def _initials_for(name):
    """Return up to 3 uppercase letters of `name` (one per word).

    Hyphens and underscores act as word separators alongside whitespace,
    so "Banks-Peninsula Restoration" yields "BPR". Returns 'T' when
    `name` is empty/falsy so the platform fallback always has something
    to render.
    """
    if not name:
        return 'T'
    cleaned = name.replace('-', ' ').replace('_', ' ')
    parts = [p for p in cleaned.split() if p]
    if not parts:
        return 'T'
    return ''.join(p[0] for p in parts[:3]).upper() or 'T'


def _theme_for_group(group_id):
    """Resolve a group's effective theme (group_themes → platform_theme)."""
    return themes.get_active_theme(group_id)


def _profile_svg(initials, primary):
    """Solid circle in `primary` with `initials` in white. 400×400.

    Explicit width/height attributes on the SVG root: when an SVG is
    used as an `<img src>`, some browsers won't infer intrinsic
    dimensions from viewBox alone, which breaks `object-fit: cover`
    in any parent that depends on aspect ratio.
    """
    initials = html.escape(initials)
    primary  = html.escape(primary)
    return (
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<svg xmlns="http://www.w3.org/2000/svg" '
        'width="400" height="400" viewBox="0 0 400 400" '
        'preserveAspectRatio="xMidYMid meet" role="img" '
        f'aria-label="Default avatar — {initials}">\n'
        f'  <title>{initials}</title>\n'
        f'  <circle cx="200" cy="200" r="200" fill="{primary}"/>\n'
        f'  <text x="200" y="200" text-anchor="middle" dominant-baseline="central" '
        'font-family="Cabin, system-ui, -apple-system, sans-serif" '
        f'font-size="180" font-weight="700" fill="#ffffff">{initials}</text>\n'
        '</svg>\n'
    )


def _cover_svg(initials, primary, secondary):
    """Linear gradient primary→secondary with a white disc + tinted
    initials at centre. 1200×400 (3:1 — matches the upload guidance).

    Explicit width/height attributes are required for the hero's
    `<img class="hero__img">` — the CSS uses `width:100%;height:100%;
    object-fit: cover`, which only works if the browser can resolve
    intrinsic dimensions. viewBox alone is unreliable across browsers
    for that. `preserveAspectRatio="xMidYMid meet"` (the default) lets
    CSS object-fit do the cropping rather than the SVG slicing itself
    twice in a row.
    """
    initials  = html.escape(initials)
    primary   = html.escape(primary)
    secondary = html.escape(secondary)
    return (
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<svg xmlns="http://www.w3.org/2000/svg" '
        'width="1200" height="400" viewBox="0 0 1200 400" '
        'preserveAspectRatio="xMidYMid meet" role="img" '
        f'aria-label="Default cover — {initials}">\n'
        f'  <title>{initials}</title>\n'
        '  <defs>\n'
        '    <linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">\n'
        f'      <stop offset="0%" stop-color="{primary}"/>\n'
        f'      <stop offset="100%" stop-color="{secondary}"/>\n'
        '    </linearGradient>\n'
        '  </defs>\n'
        '  <rect width="1200" height="400" fill="url(#bg)"/>\n'
        '  <circle cx="600" cy="200" r="120" fill="#ffffff" opacity="0.95"/>\n'
        f'  <text x="600" y="200" text-anchor="middle" dominant-baseline="central" '
        'font-family="Cabin, system-ui, -apple-system, sans-serif" '
        f'font-size="120" font-weight="700" fill="{primary}">{initials}</text>\n'
        '</svg>\n'
    )


def _svg_response(body):
    """Wrap an SVG string in a properly typed + cacheable Response."""
    return Response(
        body,
        mimetype='image/svg+xml',
        headers={'Cache-Control': 'public, max-age=300'},
    )


# ── Routes ─────────────────────────────────────────────────────────────────


@app.route('/identity/default/group/<int:group_id>/cover.svg')
def identity_default_group_cover(group_id):
    name = themes.get_group_name(group_id) or 'Tiaki'
    theme = _theme_for_group(group_id)
    return _svg_response(_cover_svg(
        _initials_for(name),
        theme['primary_color'],
        theme['secondary_color'],
    ))


@app.route('/identity/default/group/<int:group_id>/profile.svg')
def identity_default_group_profile(group_id):
    name = themes.get_group_name(group_id) or 'Tiaki'
    theme = _theme_for_group(group_id)
    return _svg_response(_profile_svg(
        _initials_for(name),
        theme['primary_color'],
    ))


@app.route('/identity/default/platform/cover.svg')
def identity_default_platform_cover():
    theme = themes.get_platform_theme()
    return _svg_response(_cover_svg(
        'T',
        theme['primary_color'],
        theme['secondary_color'],
    ))


@app.route('/identity/default/platform/profile.svg')
def identity_default_platform_profile():
    theme = themes.get_platform_theme()
    return _svg_response(_profile_svg('T', theme['primary_color']))
