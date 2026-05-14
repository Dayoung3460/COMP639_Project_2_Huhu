-- ============================================================================
-- Custom Themes — DDL only. Populate with sql/themes_populate.sql.
--
-- Run order on a fresh database:
--   1. sql/create_tables.sql      (users, groups, etc.)
--   2. sql/themes_create.sql      (this file)
--   3. sql/populate_tables.sql    (users, groups data)
--   4. sql/themes_populate.sql    (platform_theme row + 4 presets)
--
-- Schema shape: every theme — preset, platform default, per-group, history
-- snapshot — is the same 8-column bundle (3 colours, button_style,
-- font_heading, font_body, nav_position, content_width) plus tracking
-- columns.
--
-- Column ordering: this file groups nav_position + content_width with the
-- other style columns. The live DB (migrated incrementally) has them
-- appended at the end of each table. App reads use named-column SELECTs so
-- ordinal position is irrelevant.
-- ============================================================================

BEGIN;

-- ── ENUMs ───────────────────────────────────────────────────────────────────
CREATE TYPE button_style_type  AS ENUM ('rounded', 'square');
CREATE TYPE nav_position_type  AS ENUM ('sidebar', 'topbar');
CREATE TYPE content_width_type AS ENUM ('wrap', 'full');

-- ── theme_presets — platform-shipped themes (gallery library) ───────────────
CREATE TABLE theme_presets (
    preset_id        SERIAL PRIMARY KEY,
    name             VARCHAR(80)  NOT NULL UNIQUE,
    description      TEXT,
    primary_color    VARCHAR(7)   NOT NULL,
    secondary_color  VARCHAR(7)   NOT NULL,
    background_color VARCHAR(7)   NOT NULL,
    button_style     button_style_type  NOT NULL,
    font_heading     VARCHAR(80)  NOT NULL,
    font_body        VARCHAR(80)  NOT NULL,
    nav_position     nav_position_type  NOT NULL,
    content_width    content_width_type NOT NULL,
    preview_image    VARCHAR(255),
    display_order    INTEGER      NOT NULL DEFAULT 0,
    CONSTRAINT preset_hex_primary    CHECK (primary_color    ~ '^#[0-9A-Fa-f]{6}$'),
    CONSTRAINT preset_hex_secondary  CHECK (secondary_color  ~ '^#[0-9A-Fa-f]{6}$'),
    CONSTRAINT preset_hex_background CHECK (background_color ~ '^#[0-9A-Fa-f]{6}$')
);

-- ── platform_theme — singleton row holding the platform default ─────────────
-- CHECK (id = 1) is the singleton enforcement; ON CONFLICT (id) in the
-- populate script handles re-runs.
CREATE TABLE platform_theme (
    id               INTEGER PRIMARY KEY DEFAULT 1 CHECK (id = 1),
    primary_color    VARCHAR(7)   NOT NULL,
    secondary_color  VARCHAR(7)   NOT NULL,
    background_color VARCHAR(7)   NOT NULL,
    button_style     button_style_type  NOT NULL,
    font_heading     VARCHAR(80)  NOT NULL,
    font_body        VARCHAR(80)  NOT NULL,
    nav_position     nav_position_type  NOT NULL,
    content_width    content_width_type NOT NULL,
    based_on_preset  INTEGER REFERENCES theme_presets(preset_id) ON DELETE SET NULL,
    updated_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by       INTEGER REFERENCES users(user_id),
    CONSTRAINT pt_hex_primary    CHECK (primary_color    ~ '^#[0-9A-Fa-f]{6}$'),
    CONSTRAINT pt_hex_secondary  CHECK (secondary_color  ~ '^#[0-9A-Fa-f]{6}$'),
    CONSTRAINT pt_hex_background CHECK (background_color ~ '^#[0-9A-Fa-f]{6}$')
);

-- ── group_themes — per-group override (PK = group_id, one row per group) ────
-- Resolved by themes.get_active_theme: group_themes if present, else
-- platform_theme. ON DELETE CASCADE drops the row when its group is deleted.
CREATE TABLE group_themes (
    group_id         INTEGER PRIMARY KEY
                     REFERENCES groups(group_id) ON DELETE CASCADE,
    primary_color    VARCHAR(7)   NOT NULL,
    secondary_color  VARCHAR(7)   NOT NULL,
    background_color VARCHAR(7)   NOT NULL,
    button_style     button_style_type  NOT NULL,
    font_heading     VARCHAR(80)  NOT NULL,
    font_body        VARCHAR(80)  NOT NULL,
    nav_position     nav_position_type  NOT NULL,
    content_width    content_width_type NOT NULL,
    based_on_preset  INTEGER REFERENCES theme_presets(preset_id) ON DELETE SET NULL,
    updated_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by       INTEGER REFERENCES users(user_id),
    CONSTRAINT gt_hex_primary    CHECK (primary_color    ~ '^#[0-9A-Fa-f]{6}$'),
    CONSTRAINT gt_hex_secondary  CHECK (secondary_color  ~ '^#[0-9A-Fa-f]{6}$'),
    CONSTRAINT gt_hex_background CHECK (background_color ~ '^#[0-9A-Fa-f]{6}$')
);

-- ── theme_history — pre-overwrite snapshots, capped per group ───────────────
-- Auto-snapshots (name IS NULL, is_pinned = FALSE) are trimmed by app code to
-- the most recent N per group (DELETE ... WHERE NOT is_pinned ... OFFSET N).
-- Pinned rows (named, is_pinned = TRUE) are written by the "Save current as…"
-- action on the history page and are exempt from the cap.
CREATE TABLE theme_history (
    history_id       SERIAL PRIMARY KEY,
    group_id         INTEGER REFERENCES groups(group_id) ON DELETE CASCADE,
    primary_color    VARCHAR(7)   NOT NULL,
    secondary_color  VARCHAR(7)   NOT NULL,
    background_color VARCHAR(7)   NOT NULL,
    button_style     button_style_type  NOT NULL,
    font_heading     VARCHAR(80)  NOT NULL,
    font_body        VARCHAR(80)  NOT NULL,
    nav_position     nav_position_type  NOT NULL,
    content_width    content_width_type NOT NULL,
    based_on_preset  INTEGER REFERENCES theme_presets(preset_id) ON DELETE SET NULL,
    name             VARCHAR(80),
    is_pinned        BOOLEAN      NOT NULL DEFAULT FALSE,
    saved_at         TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    saved_by         INTEGER REFERENCES users(user_id),
    CONSTRAINT th_hex_primary         CHECK (primary_color    ~ '^#[0-9A-Fa-f]{6}$'),
    CONSTRAINT th_hex_secondary       CHECK (secondary_color  ~ '^#[0-9A-Fa-f]{6}$'),
    CONSTRAINT th_hex_background      CHECK (background_color ~ '^#[0-9A-Fa-f]{6}$'),
    CONSTRAINT th_pinned_requires_name CHECK (is_pinned = FALSE OR name IS NOT NULL)
);

-- Hot paths:
--   • Cap trim reads non-pinned rows for one group ordered by saved_at DESC.
--   • History page lists pinned rows first, then recent auto-snapshots.
CREATE INDEX theme_history_group_saved
    ON theme_history (group_id, saved_at DESC);
CREATE INDEX theme_history_group_pinned_saved
    ON theme_history (group_id, is_pinned DESC, saved_at DESC);

COMMIT;
