-- =============================================================
-- create_tables.sql — Conservation Groups Platform
-- COMP639 Group Project 2 — Semester 1, 2026
--
-- Run this first, then run populate_tables.sql
-- =============================================================

-- ── Drop tables (children before parents) ─────────────────────
DROP TABLE IF EXISTS password_reset_tokens   CASCADE;
DROP TABLE IF EXISTS bait_station_records    CASCADE;
DROP TABLE IF EXISTS bait_stations           CASCADE;
DROP TABLE IF EXISTS incidental_observations CASCADE;
DROP TABLE IF EXISTS trap_catches            CASCADE;
DROP TABLE IF EXISTS operator_lines          CASCADE;
DROP TABLE IF EXISTS traps                   CASCADE;
DROP TABLE IF EXISTS lines                   CASCADE;
DROP TABLE IF EXISTS user_notifications      CASCADE;
DROP TABLE IF EXISTS group_join_requests     CASCADE;
DROP TABLE IF EXISTS group_applications      CASCADE;
DROP TABLE IF EXISTS group_memberships       CASCADE;
DROP TABLE IF EXISTS groups                  CASCADE;
DROP TABLE IF EXISTS users                   CASCADE;
DROP TABLE IF EXISTS species                 CASCADE;
DROP TABLE IF EXISTS trap_statuses           CASCADE;
DROP TABLE IF EXISTS bait_types              CASCADE;

-- ── Drop ENUMs ────────────────────────────────────────────────
DROP TYPE IF EXISTS group_role_type       CASCADE;
DROP TYPE IF EXISTS account_status_type   CASCADE;
DROP TYPE IF EXISTS line_type_enum        CASCADE;
DROP TYPE IF EXISTS trap_type_enum        CASCADE;
DROP TYPE IF EXISTS sex_type              CASCADE;
DROP TYPE IF EXISTS maturity_type         CASCADE;
DROP TYPE IF EXISTS rebaited_type         CASCADE;
DROP TYPE IF EXISTS trap_condition_type   CASCADE;
DROP TYPE IF EXISTS observation_type_enum CASCADE;
DROP TYPE IF EXISTS request_status_enum   CASCADE;

-- ==============================================================
-- 1. ENUMs
-- ==============================================================

CREATE TYPE group_role_type AS ENUM (
    'Observer',
    'Operator',
    'Group Coordinator'
);

CREATE TYPE account_status_type AS ENUM ('active', 'inactive');

-- Lines are either Trap lines or Bait Station lines — no combination
CREATE TYPE line_type_enum AS ENUM ('Trap', 'Bait Station');

CREATE TYPE trap_type_enum AS ENUM (
    'A24',
    'DOC 150',
    'DOC 200',
    'DOC 250',
    'Flipping Timmy',
    'Rat trap',
    'T-Rex Rat Trap',
    'Trapinator',
    'Victor'
);

CREATE TYPE sex_type AS ENUM ('Male', 'Female');

CREATE TYPE maturity_type AS ENUM ('Juvenile', 'Adult');

CREATE TYPE rebaited_type AS ENUM ('Yes', 'No');

CREATE TYPE trap_condition_type AS ENUM (
    'OK',
    'Needs maintenance',
    'Repaired',
    'Regassed',
    'Recurred',
    'Battery charge'
);

CREATE TYPE observation_type_enum AS ENUM (
    'Bird sighting',
    'Predator sighting',
    'Predator tracks',
    'Native species tracks',
    'Native species sign',
    'Other'
);

-- Shared status ENUM for join requests and group applications
CREATE TYPE request_status_enum AS ENUM ('pending', 'approved', 'rejected');

-- ==============================================================
-- 2. Lookup tables — Super Admin managed
-- ==============================================================

CREATE TABLE species (
    name VARCHAR(100) PRIMARY KEY
);

CREATE TABLE trap_statuses (
    name VARCHAR(100) PRIMARY KEY
);

CREATE TABLE bait_types (
    name VARCHAR(100) PRIMARY KEY
);

-- ==============================================================
-- 3. Users — site-wide role via is_super_admin; group role lives in group_memberships
-- ==============================================================

CREATE TABLE users (
    user_id       SERIAL PRIMARY KEY,
    username      VARCHAR(255) NOT NULL UNIQUE,
    email         VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name    VARCHAR(255) NOT NULL,
    last_name     VARCHAR(255) NOT NULL,

    phone         VARCHAR(20)  DEFAULT NULL,
    address       VARCHAR(255) DEFAULT NULL,

    emergency_contact_name  VARCHAR(100) DEFAULT NULL,
    emergency_contact_phone VARCHAR(20)  DEFAULT NULL,

    profile_photo VARCHAR(255) DEFAULT NULL,
    notes         TEXT         DEFAULT NULL,

    is_super_admin BOOLEAN             NOT NULL DEFAULT FALSE,
    account_status account_status_type NOT NULL DEFAULT 'active',

    date_joined TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_login  TIMESTAMP DEFAULT NULL
);

-- ==============================================================
-- 4. Groups
-- ==============================================================

CREATE TABLE groups (
    group_id    SERIAL PRIMARY KEY,
    name        VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    location    VARCHAR(255),
    is_public   BOOLEAN      NOT NULL DEFAULT TRUE,
    is_active   BOOLEAN      NOT NULL DEFAULT TRUE,
    image       VARCHAR(255) DEFAULT NULL,
    color_theme VARCHAR(7)   NOT NULL DEFAULT '#198754',
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ==============================================================
-- 5. Group memberships — one row per user per group
-- ==============================================================

CREATE TABLE group_memberships (
    membership_id SERIAL PRIMARY KEY,
    user_id       INTEGER   NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    group_id      INTEGER   NOT NULL REFERENCES groups(group_id) ON DELETE CASCADE,
    role          group_role_type NOT NULL,
    joined_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, group_id)
);

-- ==============================================================
-- 6. Group join requests — for private groups
-- ==============================================================

CREATE TABLE group_join_requests (
    request_id   SERIAL PRIMARY KEY,
    user_id      INTEGER             NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    group_id     INTEGER             NOT NULL REFERENCES groups(group_id) ON DELETE CASCADE,
    status       request_status_enum NOT NULL DEFAULT 'pending',
    message      TEXT                DEFAULT NULL,
    requested_at TIMESTAMP           NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, group_id)
);

-- ==============================================================
-- 7. User notifications — flashed once on next login/group select
-- ==============================================================

CREATE TABLE user_notifications (
    notification_id SERIAL PRIMARY KEY,
    user_id         INTEGER     NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    message         TEXT        NOT NULL,
    category        VARCHAR(20) NOT NULL DEFAULT 'info',
    is_active       BOOLEAN     NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ==============================================================
-- 8. Group applications — users applying to form a new group
-- ==============================================================

CREATE TABLE group_applications (
    application_id  SERIAL PRIMARY KEY,
    user_id         INTEGER             NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    proposed_name   VARCHAR(255)        NOT NULL,
    description     TEXT                NOT NULL,
    location        VARCHAR(255)        NOT NULL,
    justification   TEXT                NOT NULL,
    image           VARCHAR(500)        DEFAULT NULL,
    status          request_status_enum NOT NULL DEFAULT 'pending',
    applied_at      TIMESTAMP           NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- Decided part
    decided_by      INTEGER             DEFAULT NULL REFERENCES users(user_id),
    decided_at      TIMESTAMP           DEFAULT NULL,
    decision_reason TEXT                DEFAULT NULL
);

-- ==============================================================
-- 8. Lines — scoped to a group; type is Trap or Bait Station
-- ==============================================================

CREATE TABLE lines (
    line_id    SERIAL PRIMARY KEY,
    name       VARCHAR(255)   NOT NULL UNIQUE,
    type       line_type_enum NOT NULL,
    group_id   INTEGER        NOT NULL REFERENCES groups(group_id),
    is_retired BOOLEAN        NOT NULL DEFAULT FALSE,
    retired_at TIMESTAMP      DEFAULT NULL,
    retired_by INTEGER        DEFAULT NULL REFERENCES users(user_id)
);

-- ==============================================================
-- 9. Traps — belong to a Trap type line
-- ==============================================================

CREATE TABLE traps (
    trap_id    SERIAL PRIMARY KEY,
    code       VARCHAR(255)   NOT NULL UNIQUE,
    trap_type  trap_type_enum NOT NULL,
    line_id    INTEGER        NOT NULL REFERENCES lines(line_id),
    latitude   NUMERIC(9, 6)  NOT NULL,
    longitude  NUMERIC(9, 6)  NOT NULL,
    is_retired BOOLEAN        NOT NULL DEFAULT FALSE,
    retired_at TIMESTAMP      DEFAULT NULL,
    retired_by INTEGER        DEFAULT NULL REFERENCES users(user_id)
);

-- ==============================================================
-- 10. Bait stations — belong to a Bait Station type line
-- ==============================================================

CREATE TABLE bait_stations (
    station_id   SERIAL PRIMARY KEY,
    code         VARCHAR(255)  NOT NULL UNIQUE,
    station_type VARCHAR(100)  NOT NULL,
    other_type   VARCHAR(255)  DEFAULT NULL,
    line_id      INTEGER       NOT NULL REFERENCES lines(line_id),
    latitude     NUMERIC(9, 6) NOT NULL,
    longitude    NUMERIC(9, 6) NOT NULL,
    is_retired   BOOLEAN       NOT NULL DEFAULT FALSE,
    retired_at   TIMESTAMP     DEFAULT NULL,
    retired_by   INTEGER       DEFAULT NULL REFERENCES users(user_id),
    CONSTRAINT other_type_required CHECK (
        station_type != 'Other' OR other_type IS NOT NULL
    )
);

-- ==============================================================
-- 11. Operator–line assignments
-- ==============================================================

CREATE TABLE operator_lines (
    operator_id INTEGER NOT NULL REFERENCES users(user_id),
    line_id     INTEGER NOT NULL REFERENCES lines(line_id),
    PRIMARY KEY (operator_id, line_id)
);

-- ==============================================================
-- 12. Trap catch records
-- ==============================================================

CREATE TABLE trap_catches (
    catch_id       SERIAL PRIMARY KEY,
    trap_id        INTEGER             NOT NULL REFERENCES traps(trap_id),
    date           TIMESTAMP           NOT NULL,
    recorded_by_id INTEGER             REFERENCES users(user_id),
    species_caught VARCHAR(100)        NOT NULL REFERENCES species(name) ON UPDATE CASCADE,
    sex            sex_type,
    maturity       maturity_type,
    status         VARCHAR(100)        NOT NULL REFERENCES trap_statuses(name) ON UPDATE CASCADE,
    rebaited       rebaited_type       NOT NULL,
    bait_type      VARCHAR(100)        NOT NULL REFERENCES bait_types(name) ON UPDATE CASCADE,
    bait_details   TEXT,
    trap_condition trap_condition_type NOT NULL,
    strikes        INTEGER             NOT NULL CHECK (strikes >= 0),
    notes          TEXT,
    CHECK ((strikes = 0 AND species_caught = 'None') OR strikes >= 1),
    CHECK ((rebaited = 'No' AND bait_type = 'None') OR rebaited = 'Yes')
);

-- ==============================================================
-- 13. Bait station records
-- ==============================================================

CREATE TABLE bait_station_records (
    record_id         SERIAL PRIMARY KEY,
    station_id        INTEGER       NOT NULL REFERENCES bait_stations(station_id),
    date              TIMESTAMP     NOT NULL,
    recorded_by_id    INTEGER       REFERENCES users(user_id),
    target_species    VARCHAR(100)  NOT NULL,
    active_ingredient VARCHAR(100)  NOT NULL,
    formulation       VARCHAR(100)  NOT NULL,
    concentration     NUMERIC(5, 2) NOT NULL,
    bait_remaining    NUMERIC(8, 3) NOT NULL,
    bait_removed      NUMERIC(8, 3) DEFAULT NULL,
    bait_added        NUMERIC(8, 3) DEFAULT NULL,
    notes             TEXT          DEFAULT NULL
);

-- ==============================================================
-- 14. Incidental observations
-- ==============================================================

CREATE TABLE incidental_observations (
    observation_id   SERIAL PRIMARY KEY,
    date             TIMESTAMP             NOT NULL,
    operator_id      INTEGER               NOT NULL REFERENCES users(user_id),
    observation_type observation_type_enum NOT NULL,
    notes            TEXT,
    latitude         NUMERIC(9, 6),
    longitude        NUMERIC(9, 6),
    line_id          INTEGER               NOT NULL REFERENCES lines(line_id),
    trap_id          INTEGER               REFERENCES traps(trap_id)
);

-- ==============================================================
-- 15. Password reset tokens
-- ==============================================================

CREATE TABLE password_reset_tokens (
    token      VARCHAR(64) PRIMARY KEY,
    user_id    INTEGER     NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    expires_at TIMESTAMP   NOT NULL,
    used       BOOLEAN     NOT NULL DEFAULT FALSE
);
