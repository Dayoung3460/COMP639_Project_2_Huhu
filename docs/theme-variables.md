# Theme variable contract

Every theme — a `theme_presets` row, the `platform_theme` singleton, and any
`group_themes` row — has the same shape. This document is the contract
between the schema, the context processor, the template that emits the CSS
variables, and the stylesheets that consume them. Build the editor against
this list.

## Column → CSS variable → consumer

| DB column          | Emitted as              | Consumed in                                                                                | Notes                                                                                  |
|--------------------|-------------------------|--------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------|
| `primary_color`    | `--theme-primary`       | `template-default.css` (marketing chrome), `custom.css` (`--pf-*` scale derives from this) | Hex `#rrggbb`, validated by `^#[0-9A-Fa-f]{6}$` CHECK constraint.                       |
| `secondary_color`  | `--theme-secondary`     | `template-default.css` (accent), `custom.css` (`--sf-*` scale derives from this)           | Hex.                                                                                   |
| `background_color` | `--theme-background`    | `template-default.css` (body bg), `custom.css` (`--surface-*` neutrals derive from this)   | Hex.                                                                                   |
| `button_style`     | `--theme-button-radius` | `custom.css` (`.btn-pf*` family border-radius)                                             | ENUM `button_style_type`. `'rounded'` → `8px`, `'square'` → `0`. Mapped in `themes.py:_shape_theme`. |
| `font_heading`     | `--theme-font-heading`  | `custom.css` (`h1`–`h6` + every `var(--theme-font-heading, 'Cabin')` selector — gallery tile H2, page titles, brand wordmark, etc.), `template-default.css` (`--font-display` token used by marketing display headlines) | Free-text VARCHAR(80), restricted at write time to `themes.FONT_HEADING_WHITELIST`. |
| `font_body`        | `--theme-font-body`     | `custom.css` (`body` rule), `template-default.css` (`--font-body` token used by marketing body text) | Free-text VARCHAR(80), restricted at write time to `themes.FONT_BODY_WHITELIST`. |
| `nav_position`     | *(no CSS var)*          | `base.html` body class `layout-nav-<value>`, `_nav_topbar.html` / `_nav_sidebar.html` include gate | ENUM `nav_position_type`: `'sidebar' | 'topbar'`.                                       |
| `content_width`    | *(no CSS var)*          | `base.html` body class `layout-width-<value>`, `.app-wrap` CSS                             | ENUM `content_width_type`: `'wrap' | 'full'`.                                           |

## Where the CSS variables are written

The `<style>` block in `app/templates/base.html` (and again in
`app/templates/base_marketing.html`) emits the six variables at the top of
`<head>` from `_t.*` — the theme dict the `inject_theme_identity` context
processor injects. Both base templates also emit the matching Google Fonts
`<link rel="stylesheet">` tags for `font_heading` and `font_body`,
**deduped when the two values match** so a custom theme with heading ==
body doesn't issue two identical requests. The auth surface
(`base_auth.html`) intentionally skips the block, so every
`var(--theme-x, default)` on an auth page resolves to its hardcoded
default — auth stays unthemed by omission.

## Apply flow

`themes.apply_preset(group_id, preset_id, user_id)` is the only entry point
that mutates a group's theme. It runs three writes inside one transaction:

1. Read the group's current effective theme (`group_themes` if present,
   else `platform_theme`).
2. INSERT a snapshot of that previous theme into `theme_history`.
3. UPSERT `group_themes` with the preset's values + `based_on_preset =
   preset_id` + `updated_at = NOW()` + `updated_by = user_id`.
4. DELETE history rows beyond the 10 most recent for this group.

`themes.save_custom_theme(...)` follows the same shape for editor saves;
the only difference is where the values come from.

## Customisable values vs locked values (today)

`primary_color`, `secondary_color`, `background_color`, `button_style`,
`font_heading`, `font_body`, `nav_position`, and `content_width` are all
theme-driven — flipping them via apply or save propagates through the
cascade on the next render. Anything not in that list is platform-locked:
font weights and sizes, the `--pf-*` shade ramp shape, button base size,
spacing scale.

## Editor caveat — single font picker today

The custom-theme editor (`/coordinator/themes/customise`) exposes ONE
font picker, not two. When a Coordinator saves, the single value gets
**copied into both `font_heading` and `font_body`**. This is intentional
transitional behaviour: the heading + body split lives in the schema and
the apply/preset flow so groups picking a preset get a proper pairing
(Fraunces + IBM Plex Sans, Merriweather + Source Sans 3, etc.), but the
editor UI for picking each font independently is the next story under
the Custom Themes epic.

Consequences while this remains the case:

- Applying a preset → both columns carry the curated pair (correct).
- Editing a custom theme → both columns collapse to the same value
  (one font for both headings and body). The previous curated heading
  font is overwritten.
- The validator's transitional branch
  (`themes._validate_theme_values`) accepts a single `font_family` key
  and writes to both columns; when the editor surfaces two pickers,
  remove that branch and use the explicit
  `font_heading` / `font_body` keys it already handles.
