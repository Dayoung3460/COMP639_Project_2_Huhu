-- ============================================================================
-- Migration: split font_family into font_heading + font_body
-- Date:      2026-05-15
-- Applies to: theme_presets, group_themes, platform_theme, theme_history
-- Reversible: yes (rollback block at the bottom, commented out)
--
-- Backfill rule:
--   font_body    = old font_family on every row (1:1 carry-over).
--   font_heading = each preset's curated heading font, looked up by id.
--                  For non-preset rows (group_themes / platform_theme /
--                  theme_history) the heading font is derived from
--                  based_on_preset → that preset's heading; rows with a
--                  NULL based_on_preset (or one that no longer resolves)
--                  fall back to the platform default heading 'Fraunces'.
--
-- Safety: the DO/RAISE block runs BEFORE any SET NOT NULL or DROP. If a
-- single row across the four tables still has a NULL in either of the new
-- columns, it aborts the whole transaction with a clear message and leaves
-- the schema unchanged.
-- ============================================================================

BEGIN;

-- ── 1. ADD columns (nullable so the backfill can populate them) ─────────────
ALTER TABLE theme_presets  ADD COLUMN font_heading VARCHAR(80);
ALTER TABLE theme_presets  ADD COLUMN font_body    VARCHAR(80);
ALTER TABLE group_themes   ADD COLUMN font_heading VARCHAR(80);
ALTER TABLE group_themes   ADD COLUMN font_body    VARCHAR(80);
ALTER TABLE platform_theme ADD COLUMN font_heading VARCHAR(80);
ALTER TABLE platform_theme ADD COLUMN font_body    VARCHAR(80);
ALTER TABLE theme_history  ADD COLUMN font_heading VARCHAR(80);
ALTER TABLE theme_history  ADD COLUMN font_body    VARCHAR(80);

-- ── 2. BACKFILL font_body — straight carry-over from font_family ────────────
UPDATE theme_presets  SET font_body = font_family;
UPDATE group_themes   SET font_body = font_family;
UPDATE platform_theme SET font_body = font_family;
UPDATE theme_history  SET font_body = font_family;

-- ── 3. BACKFILL font_heading ────────────────────────────────────────────────
-- Presets: explicit per-id assignment matching themes_populate.sql.
UPDATE theme_presets SET font_heading = CASE preset_id
  WHEN 1 THEN 'Fraunces'         -- Default Tiaki
  WHEN 2 THEN 'Merriweather'     -- Forest
  WHEN 3 THEN 'Playfair Display' -- Coastal
  WHEN 4 THEN 'Oswald'           -- Tussock
END
WHERE preset_id IN (1, 2, 3, 4);

-- Group themes / platform_theme / theme_history: heading derives from the
-- referenced preset; NULL based_on_preset or unmatched id falls back to
-- 'Fraunces' (the platform default heading).
UPDATE group_themes gt SET font_heading = COALESCE(
  (SELECT tp.font_heading FROM theme_presets tp WHERE tp.preset_id = gt.based_on_preset),
  'Fraunces'
);

UPDATE platform_theme pt SET font_heading = COALESCE(
  (SELECT tp.font_heading FROM theme_presets tp WHERE tp.preset_id = pt.based_on_preset),
  'Fraunces'
);

UPDATE theme_history th SET font_heading = COALESCE(
  (SELECT tp.font_heading FROM theme_presets tp WHERE tp.preset_id = th.based_on_preset),
  'Fraunces'
);

-- ── 4. ASSERT — every row in every table has both new columns populated ─────
-- Must run BEFORE any SET NOT NULL or DROP COLUMN. A failure here aborts the
-- transaction and leaves font_family intact. This is an explicit guarantee,
-- not just implied by statement ordering.
DO $$
DECLARE
  bad INTEGER;
BEGIN
  SELECT COUNT(*) INTO bad FROM theme_presets
   WHERE font_heading IS NULL OR font_body IS NULL;
  IF bad > 0 THEN
    RAISE EXCEPTION 'theme_presets: % rows still have NULL font_heading or font_body — aborting before DROP', bad;
  END IF;

  SELECT COUNT(*) INTO bad FROM group_themes
   WHERE font_heading IS NULL OR font_body IS NULL;
  IF bad > 0 THEN
    RAISE EXCEPTION 'group_themes: % rows still have NULL font_heading or font_body — aborting before DROP', bad;
  END IF;

  SELECT COUNT(*) INTO bad FROM platform_theme
   WHERE font_heading IS NULL OR font_body IS NULL;
  IF bad > 0 THEN
    RAISE EXCEPTION 'platform_theme: % rows still have NULL font_heading or font_body — aborting before DROP', bad;
  END IF;

  SELECT COUNT(*) INTO bad FROM theme_history
   WHERE font_heading IS NULL OR font_body IS NULL;
  IF bad > 0 THEN
    RAISE EXCEPTION 'theme_history: % rows still have NULL font_heading or font_body — aborting before DROP', bad;
  END IF;
END $$;

-- ── 5. Tighten to NOT NULL ──────────────────────────────────────────────────
ALTER TABLE theme_presets  ALTER COLUMN font_heading SET NOT NULL;
ALTER TABLE theme_presets  ALTER COLUMN font_body    SET NOT NULL;
ALTER TABLE group_themes   ALTER COLUMN font_heading SET NOT NULL;
ALTER TABLE group_themes   ALTER COLUMN font_body    SET NOT NULL;
ALTER TABLE platform_theme ALTER COLUMN font_heading SET NOT NULL;
ALTER TABLE platform_theme ALTER COLUMN font_body    SET NOT NULL;
ALTER TABLE theme_history  ALTER COLUMN font_heading SET NOT NULL;
ALTER TABLE theme_history  ALTER COLUMN font_body    SET NOT NULL;

-- ── 6. DROP old font_family column ──────────────────────────────────────────
ALTER TABLE theme_presets  DROP COLUMN font_family;
ALTER TABLE group_themes   DROP COLUMN font_family;
ALTER TABLE platform_theme DROP COLUMN font_family;
ALTER TABLE theme_history  DROP COLUMN font_family;

COMMIT;

-- ============================================================================
-- Rollback (uncomment + run manually if downstream breaks before deploy)
-- ============================================================================
-- BEGIN;
-- ALTER TABLE theme_presets  ADD COLUMN font_family VARCHAR(80);
-- ALTER TABLE group_themes   ADD COLUMN font_family VARCHAR(80);
-- ALTER TABLE platform_theme ADD COLUMN font_family VARCHAR(80);
-- ALTER TABLE theme_history  ADD COLUMN font_family VARCHAR(80);
--
-- UPDATE theme_presets  SET font_family = font_body;
-- UPDATE group_themes   SET font_family = font_body;
-- UPDATE platform_theme SET font_family = font_body;
-- UPDATE theme_history  SET font_family = font_body;
--
-- ALTER TABLE theme_presets  ALTER COLUMN font_family SET NOT NULL;
-- ALTER TABLE group_themes   ALTER COLUMN font_family SET NOT NULL;
-- ALTER TABLE platform_theme ALTER COLUMN font_family SET NOT NULL;
-- ALTER TABLE theme_history  ALTER COLUMN font_family SET NOT NULL;
--
-- ALTER TABLE theme_presets  DROP COLUMN font_heading;
-- ALTER TABLE theme_presets  DROP COLUMN font_body;
-- ALTER TABLE group_themes   DROP COLUMN font_heading;
-- ALTER TABLE group_themes   DROP COLUMN font_body;
-- ALTER TABLE platform_theme DROP COLUMN font_heading;
-- ALTER TABLE platform_theme DROP COLUMN font_body;
-- ALTER TABLE theme_history  DROP COLUMN font_heading;
-- ALTER TABLE theme_history  DROP COLUMN font_body;
-- COMMIT;
