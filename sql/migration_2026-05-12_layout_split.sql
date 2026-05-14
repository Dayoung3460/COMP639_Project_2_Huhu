-- ============================================================================
-- Migration: layout_template (single ENUM) → nav_position + content_width
-- Date:      2026-05-12
-- Applies to: theme_presets, group_themes, platform_theme, theme_history
-- Reversible: yes (rollback SQL at the bottom, commented out)
--
-- Mapping:
--   'centred' → sidebar + wrap   (old default)
--   'sidebar' → sidebar + full   (sidebar-prominent, full-width content)
--   'grid'    → topbar  + full   (no sidebar, edge-to-edge)
--
-- Safety: the DO/RAISE verification block aborts the whole transaction if
-- any row was missed by the backfill, BEFORE any destructive DROP runs.
-- ============================================================================

BEGIN;

-- ── New ENUM types ──────────────────────────────────────────────────────────
CREATE TYPE nav_position_type  AS ENUM ('sidebar', 'topbar');
CREATE TYPE content_width_type AS ENUM ('wrap', 'full');

-- ── 1. ADD columns (nullable, so the backfill can populate them) ────────────
ALTER TABLE theme_presets   ADD COLUMN nav_position  nav_position_type;
ALTER TABLE theme_presets   ADD COLUMN content_width content_width_type;

ALTER TABLE group_themes    ADD COLUMN nav_position  nav_position_type;
ALTER TABLE group_themes    ADD COLUMN content_width content_width_type;

ALTER TABLE platform_theme  ADD COLUMN nav_position  nav_position_type;
ALTER TABLE platform_theme  ADD COLUMN content_width content_width_type;

ALTER TABLE theme_history   ADD COLUMN nav_position  nav_position_type;
ALTER TABLE theme_history   ADD COLUMN content_width content_width_type;

-- ── 2. BACKFILL from layout_template ────────────────────────────────────────
UPDATE theme_presets SET
  nav_position  = CASE layout_template
                    WHEN 'centred' THEN 'sidebar'::nav_position_type
                    WHEN 'sidebar' THEN 'sidebar'::nav_position_type
                    WHEN 'grid'    THEN 'topbar'::nav_position_type
                  END,
  content_width = CASE layout_template
                    WHEN 'centred' THEN 'wrap'::content_width_type
                    WHEN 'sidebar' THEN 'full'::content_width_type
                    WHEN 'grid'    THEN 'full'::content_width_type
                  END;

UPDATE group_themes SET
  nav_position  = CASE layout_template
                    WHEN 'centred' THEN 'sidebar'::nav_position_type
                    WHEN 'sidebar' THEN 'sidebar'::nav_position_type
                    WHEN 'grid'    THEN 'topbar'::nav_position_type
                  END,
  content_width = CASE layout_template
                    WHEN 'centred' THEN 'wrap'::content_width_type
                    WHEN 'sidebar' THEN 'full'::content_width_type
                    WHEN 'grid'    THEN 'full'::content_width_type
                  END;

UPDATE platform_theme SET
  nav_position  = CASE layout_template
                    WHEN 'centred' THEN 'sidebar'::nav_position_type
                    WHEN 'sidebar' THEN 'sidebar'::nav_position_type
                    WHEN 'grid'    THEN 'topbar'::nav_position_type
                  END,
  content_width = CASE layout_template
                    WHEN 'centred' THEN 'wrap'::content_width_type
                    WHEN 'sidebar' THEN 'full'::content_width_type
                    WHEN 'grid'    THEN 'full'::content_width_type
                  END;

UPDATE theme_history SET
  nav_position  = CASE layout_template
                    WHEN 'centred' THEN 'sidebar'::nav_position_type
                    WHEN 'sidebar' THEN 'sidebar'::nav_position_type
                    WHEN 'grid'    THEN 'topbar'::nav_position_type
                  END,
  content_width = CASE layout_template
                    WHEN 'centred' THEN 'wrap'::content_width_type
                    WHEN 'sidebar' THEN 'full'::content_width_type
                    WHEN 'grid'    THEN 'full'::content_width_type
                  END;

-- ── 3. Verify the backfill before destructive changes ───────────────────────
-- DO/RAISE block aborts the whole transaction if any row escaped the backfill.
-- No destructive ALTER/DROP runs unless these all pass.
DO $$
DECLARE
  bad_rows INTEGER;
BEGIN
  SELECT COUNT(*) INTO bad_rows FROM theme_presets
   WHERE nav_position IS NULL OR content_width IS NULL;
  IF bad_rows > 0 THEN
    RAISE EXCEPTION 'theme_presets: % rows still NULL after backfill', bad_rows;
  END IF;

  SELECT COUNT(*) INTO bad_rows FROM group_themes
   WHERE nav_position IS NULL OR content_width IS NULL;
  IF bad_rows > 0 THEN
    RAISE EXCEPTION 'group_themes: % rows still NULL', bad_rows;
  END IF;

  SELECT COUNT(*) INTO bad_rows FROM platform_theme
   WHERE nav_position IS NULL OR content_width IS NULL;
  IF bad_rows > 0 THEN
    RAISE EXCEPTION 'platform_theme: % rows still NULL', bad_rows;
  END IF;

  SELECT COUNT(*) INTO bad_rows FROM theme_history
   WHERE nav_position IS NULL OR content_width IS NULL;
  IF bad_rows > 0 THEN
    RAISE EXCEPTION 'theme_history: % rows still NULL', bad_rows;
  END IF;
END $$;

-- ── 4. Tighten to NOT NULL ─────────────────────────────────────────────────
ALTER TABLE theme_presets  ALTER COLUMN nav_position  SET NOT NULL;
ALTER TABLE theme_presets  ALTER COLUMN content_width SET NOT NULL;
ALTER TABLE group_themes   ALTER COLUMN nav_position  SET NOT NULL;
ALTER TABLE group_themes   ALTER COLUMN content_width SET NOT NULL;
ALTER TABLE platform_theme ALTER COLUMN nav_position  SET NOT NULL;
ALTER TABLE platform_theme ALTER COLUMN content_width SET NOT NULL;
ALTER TABLE theme_history  ALTER COLUMN nav_position  SET NOT NULL;
ALTER TABLE theme_history  ALTER COLUMN content_width SET NOT NULL;

-- ── 5. DROP old column + ENUM ───────────────────────────────────────────────
ALTER TABLE theme_presets  DROP COLUMN layout_template;
ALTER TABLE group_themes   DROP COLUMN layout_template;
ALTER TABLE platform_theme DROP COLUMN layout_template;
ALTER TABLE theme_history  DROP COLUMN layout_template;

DROP TYPE layout_template_type;

COMMIT;

-- ============================================================================
-- Rollback (uncomment + run manually if downstream breaks)
-- ============================================================================
-- BEGIN;
-- CREATE TYPE layout_template_type AS ENUM ('centred', 'sidebar', 'grid');
--
-- ALTER TABLE theme_presets   ADD COLUMN layout_template layout_template_type;
-- ALTER TABLE group_themes    ADD COLUMN layout_template layout_template_type;
-- ALTER TABLE platform_theme  ADD COLUMN layout_template layout_template_type;
-- ALTER TABLE theme_history   ADD COLUMN layout_template layout_template_type;
--
-- -- Reverse mapping. topbar+wrap collapses to 'centred' on rollback (no exact
-- -- 1:1 since topbar+wrap is a new combo introduced by this migration).
-- UPDATE theme_presets SET layout_template = CASE
--   WHEN nav_position = 'sidebar' AND content_width = 'wrap' THEN 'centred'::layout_template_type
--   WHEN nav_position = 'sidebar' AND content_width = 'full' THEN 'sidebar'::layout_template_type
--   WHEN nav_position = 'topbar'  AND content_width = 'full' THEN 'grid'::layout_template_type
--   WHEN nav_position = 'topbar'  AND content_width = 'wrap' THEN 'centred'::layout_template_type
-- END;
-- (repeat the same UPDATE for group_themes, platform_theme, theme_history)
--
-- ALTER TABLE theme_presets  ALTER COLUMN layout_template SET NOT NULL;
-- ALTER TABLE group_themes   ALTER COLUMN layout_template SET NOT NULL;
-- ALTER TABLE platform_theme ALTER COLUMN layout_template SET NOT NULL;
-- ALTER TABLE theme_history  ALTER COLUMN layout_template SET NOT NULL;
--
-- ALTER TABLE theme_presets  DROP COLUMN nav_position;
-- ALTER TABLE theme_presets  DROP COLUMN content_width;
-- ALTER TABLE group_themes   DROP COLUMN nav_position;
-- ALTER TABLE group_themes   DROP COLUMN content_width;
-- ALTER TABLE platform_theme DROP COLUMN nav_position;
-- ALTER TABLE platform_theme DROP COLUMN content_width;
-- ALTER TABLE theme_history  DROP COLUMN nav_position;
-- ALTER TABLE theme_history  DROP COLUMN content_width;
--
-- DROP TYPE nav_position_type;
-- DROP TYPE content_width_type;
-- COMMIT;
