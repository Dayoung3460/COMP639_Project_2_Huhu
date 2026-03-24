-- =============================================================
-- create_database.sql — PF-LU Database Schema
-- COMP639 Group Project 1 — Semester 1, 2026
--
-- Run this first, then run populate_database.sql
-- =============================================================

-- ── Drop tables (safe re-run order — children before parents) ─
DROP TABLE IF EXISTS password_reset_tokens  CASCADE;
DROP TABLE IF EXISTS incidental_observations CASCADE;
DROP TABLE IF EXISTS trap_catches           CASCADE;
DROP TABLE IF EXISTS operator_lines         CASCADE;
DROP TABLE IF EXISTS traps                  CASCADE;
DROP TABLE IF EXISTS lines                  CASCADE;
DROP TABLE IF EXISTS users                  CASCADE;
DROP TABLE IF EXISTS species                CASCADE;
DROP TABLE IF EXISTS trap_statuses          CASCADE;
DROP TABLE IF EXISTS bait_types             CASCADE;

-- ── Drop ENUMs ────────────────────────────────────────────────
DROP TYPE IF EXISTS role_type           CASCADE;
DROP TYPE IF EXISTS account_status_type CASCADE;
DROP TYPE IF EXISTS trap_type_enum      CASCADE;
DROP TYPE IF EXISTS sex_type            CASCADE;
DROP TYPE IF EXISTS maturity_type       CASCADE;
DROP TYPE IF EXISTS rebaited_type       CASCADE;
DROP TYPE IF EXISTS trap_condition_type CASCADE;
DROP TYPE IF EXISTS observation_type_enum CASCADE;

-- ==============================================================
-- 1. ENUMs — static values that will never change
-- ==============================================================

CREATE TYPE role_type AS ENUM ('Observer', 'Operator', 'Admin');
CREATE TYPE account_status_type AS ENUM ('active', 'inactive');

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

-- ==============================================================
-- 2. Lookup tables — Admin-manageable lists (User Stories 18–20)
--    VARCHAR PRIMARY KEY allows readable FK references in trap_catches
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
-- 3. Core tables
-- ==============================================================

CREATE TABLE users (
    user_id       SERIAL PRIMARY KEY,
    username      VARCHAR(255) NOT NULL UNIQUE,
    email         VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name    VARCHAR(255) NOT NULL,
    last_name     VARCHAR(255) NOT NULL,

    -- Contact information (structured — replaces old free-text fields)
    phone         VARCHAR(20)  DEFAULT NULL,
    address       VARCHAR(255) DEFAULT NULL,  -- home address for emergency use

    -- Emergency contact
    emergency_contact_name  VARCHAR(100) DEFAULT NULL,
    emergency_contact_phone VARCHAR(20)  DEFAULT NULL,

    -- Profile
    profile_photo VARCHAR(255) DEFAULT NULL,  -- filename only, stored in static/images/uploads/
    notes         TEXT         DEFAULT NULL,  -- admin-only internal notes

    -- Role and status
    role           role_type           NOT NULL,
    account_status account_status_type NOT NULL DEFAULT 'active',

    -- Timestamps
    date_joined TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_login  TIMESTAMP DEFAULT NULL
);

CREATE TABLE lines (
    line_id    SERIAL PRIMARY KEY,
    name       VARCHAR(255) NOT NULL UNIQUE,
    type       VARCHAR(255) NOT NULL,
    is_retired BOOLEAN      NOT NULL DEFAULT FALSE
);

CREATE TABLE traps (
    trap_id    SERIAL PRIMARY KEY,
    code       VARCHAR(255)   NOT NULL UNIQUE,
    trap_type  trap_type_enum NOT NULL,
    line_id    INTEGER        NOT NULL REFERENCES lines(line_id),
    latitude   NUMERIC(9, 6)  NOT NULL,
    longitude  NUMERIC(9, 6)  NOT NULL,
    is_retired BOOLEAN        NOT NULL DEFAULT FALSE
);

-- Many-to-many: Operators assigned to Lines
CREATE TABLE operator_lines (
    operator_id INTEGER NOT NULL REFERENCES users(user_id),
    line_id     INTEGER NOT NULL REFERENCES lines(line_id),
    PRIMARY KEY (operator_id, line_id)
);

CREATE TABLE trap_catches (
    catch_id       SERIAL PRIMARY KEY,
    trap_id        INTEGER              NOT NULL REFERENCES traps(trap_id),
    date           TIMESTAMP            NOT NULL,
    recorded_by_id INTEGER              REFERENCES users(user_id),
    species_caught VARCHAR(100)         NOT NULL REFERENCES species(name) ON UPDATE CASCADE,
    sex            sex_type,
    maturity       maturity_type,
    status         VARCHAR(100)         NOT NULL REFERENCES trap_statuses(name) ON UPDATE CASCADE,
    rebaited       rebaited_type        NOT NULL,
    bait_type      VARCHAR(100)         NOT NULL REFERENCES bait_types(name) ON UPDATE CASCADE,
    bait_details   TEXT,
    trap_condition trap_condition_type  NOT NULL,
    strikes        INTEGER              NOT NULL CHECK (strikes >= 0),
    notes          TEXT,
    CHECK ((strikes = 0 AND species_caught = 'None') OR strikes >= 1),
    CHECK ((rebaited = 'No' AND bait_type = 'None') OR rebaited = 'Yes')
);

CREATE TABLE incidental_observations (
    observation_id   SERIAL PRIMARY KEY,
    date             TIMESTAMP            NOT NULL,
    operator_id      INTEGER              NOT NULL REFERENCES users(user_id),
    observation_type observation_type_enum NOT NULL,
    notes            TEXT,
    latitude         NUMERIC(9, 6),
    longitude        NUMERIC(9, 6),
    line_id          INTEGER              NOT NULL REFERENCES lines(line_id),
    trap_id          INTEGER              REFERENCES traps(trap_id)
);

-- Password reset tokens — used by the forgot password flow
CREATE TABLE password_reset_tokens (
    token      VARCHAR(64) PRIMARY KEY,
    user_id    INTEGER     NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    expires_at TIMESTAMP   NOT NULL,
    used       BOOLEAN     NOT NULL DEFAULT FALSE
);
