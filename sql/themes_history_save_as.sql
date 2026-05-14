-- ============================================================================
-- Migration: add name + is_pinned to theme_history (Save-as-Preset feature)
-- Date:      2026-05-15
-- Applies to: theme_history
--
-- Purpose:
--   The Customise History page lets a coordinator (a) see prior snapshots and
--   restore them, and (b) "Save current as…" — pin a named snapshot so it
--   survives the OFFSET-N cap and can be re-applied months later.
--
--   `name` is NULL for auto-snapshots written by apply_preset /
--   save_custom_theme; populated only when the user explicitly saves one.
--   `is_pinned` is the cap-exemption flag: TRUE rows are never deleted by
--   the trim query.
--
-- Reversible: yes (rollback block at bottom, commented).
-- ============================================================================

BEGIN;

ALTER TABLE theme_history
    ADD COLUMN name      VARCHAR(80),
    ADD COLUMN is_pinned BOOLEAN NOT NULL DEFAULT FALSE;

-- A pinned row must have a name; a named row is implicitly user-saved.
ALTER TABLE theme_history
    ADD CONSTRAINT th_pinned_requires_name
    CHECK (is_pinned = FALSE OR name IS NOT NULL);

-- Hot path for the history page: list a group's pinned rows first, then
-- recent auto-snapshots, both ordered by saved_at DESC.
CREATE INDEX theme_history_group_pinned_saved
    ON theme_history (group_id, is_pinned DESC, saved_at DESC);

COMMIT;

-- ============================================================================
-- Rollback (uncomment + run manually if needed)
-- ============================================================================
-- BEGIN;
-- DROP INDEX IF EXISTS theme_history_group_pinned_saved;
-- ALTER TABLE theme_history DROP CONSTRAINT IF EXISTS th_pinned_requires_name;
-- ALTER TABLE theme_history DROP COLUMN IF EXISTS is_pinned;
-- ALTER TABLE theme_history DROP COLUMN IF EXISTS name;
-- COMMIT;
