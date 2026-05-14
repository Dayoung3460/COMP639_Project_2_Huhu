-- ============================================================================
-- Custom Themes — seed data. Depends on sql/themes_create.sql.
--
-- Idempotent: every INSERT uses ON CONFLICT DO NOTHING so re-running on an
-- already-populated database is a no-op (preset and platform_theme rows stay
-- as they are).
--
-- Run order: see header in sql/themes_create.sql.
-- ============================================================================

BEGIN;

-- ── theme_presets — 4 platform-shipped themes ───────────────────────────────
-- Default Tiaki must reproduce the canonical Tiaki mockup exactly:
-- Fraunces (heading) + IBM Plex Sans (body), primary #1a3a2e, secondary
-- #c65d3c, background #f5f0e6, rounded buttons, sidebar nav, centred wrap.
-- The other three presets use deliberate heading + body pairings tuned to
-- their palette — heading first, body second on every row.
INSERT INTO theme_presets
  (preset_id, name, description,
   primary_color, secondary_color, background_color,
   button_style, font_heading, font_body, nav_position, content_width,
   display_order)
VALUES
  (1, 'Default Tiaki',
      'The platform default — deep forest, terracotta accent, warm cream background.',
      '#1a3a2e', '#c65d3c', '#f5f0e6',
      'rounded', 'Fraunces', 'IBM Plex Sans', 'sidebar', 'wrap',
      0),
  (2, 'Forest',
      'Deep greens and warm browns for native bush groups.',
      '#2d5016', '#8b6f47', '#f4ead5',
      'rounded', 'Merriweather', 'Source Sans 3', 'sidebar', 'wrap',
      1),
  (3, 'Coastal',
      'Ocean blues and sand for coastal restoration groups.',
      '#1e5f8e', '#d4a574', '#f0f4f7',
      'rounded', 'Playfair Display', 'Inter', 'sidebar', 'full',
      2),
  (4, 'Tussock',
      'Golden tussock and earthy tones for high-country groups.',
      '#8b6914', '#5c4a3a', '#faf3e0',
      'square', 'Oswald', 'Lora', 'topbar', 'full',
      3),
  (5, 'Pōhutukawa',
      'Crimson and sage for coastal pōhutukawa-belt groups — top nav, wrapped layout.',
      '#8a1f3a', '#2d5a44', '#faf2e8',
      'rounded', 'Fraunces', 'Source Sans 3', 'topbar', 'wrap',
      4)
ON CONFLICT (preset_id) DO NOTHING;

-- Keep the sequence ahead of the explicit preset_ids above, otherwise the
-- next ad-hoc INSERT without an explicit id would collide.
SELECT setval('theme_presets_preset_id_seq',
              (SELECT MAX(preset_id) FROM theme_presets));

-- ── platform_theme — singleton row pointing at Default Tiaki ────────────────
INSERT INTO platform_theme
  (id, primary_color, secondary_color, background_color,
   button_style, font_heading, font_body, nav_position, content_width,
   based_on_preset)
VALUES
  (1, '#1a3a2e', '#c65d3c', '#f5f0e6',
   'rounded', 'Fraunces', 'IBM Plex Sans', 'sidebar', 'wrap',
   1)
ON CONFLICT (id) DO NOTHING;

COMMIT;
