-- =============================================================
-- 3d_epic_migration.sql -- Innovation Epic: 3D Terrain Map
-- COMP639 Group Project 2, Team Huhu -- Lincoln University
-- Run AFTER create_tables.sql + populate_tables.sql + seed_data.sql.
-- Idempotent: safe to re-run.
-- =============================================================

BEGIN;

-- Per-user view preferences (toggle persistence -- vegetation on/off, etc.)
CREATE TABLE IF NOT EXISTS map3d_view_prefs (
    user_id          INT PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
    show_vegetation  BOOL NOT NULL DEFAULT TRUE,
    activity_days    INT  NOT NULL DEFAULT 30 CHECK (activity_days BETWEEN 1 AND 365),
    updated_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Lightweight access log so the team can show usage at demo time.
CREATE TABLE IF NOT EXISTS map3d_view_log (
    log_id      SERIAL PRIMARY KEY,
    user_id     INT REFERENCES users(user_id) ON DELETE SET NULL,
    group_id    INT REFERENCES groups(group_id) ON DELETE SET NULL,
    line_id     INT REFERENCES lines(line_id)  ON DELETE SET NULL,
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_map3d_view_log_group_time
    ON map3d_view_log (group_id, created_at DESC);

COMMIT;
