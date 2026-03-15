-- =============================================================
-- create_tables.sql — PF-LU Database Schema
-- COMP639 Group Project 1 — Semester 1, 2026
--
-- Run this first, then run populate_database.sql
-- =============================================================

-- Drop tables in safe order (children before parents)
DROP TABLE IF EXISTS observation     CASCADE;
DROP TABLE IF EXISTS trap_catch      CASCADE;
DROP TABLE IF EXISTS operator_line   CASCADE;
DROP TABLE IF EXISTS trap            CASCADE;
DROP TABLE IF EXISTS line            CASCADE;
DROP TABLE IF EXISTS "user"          CASCADE;
DROP TABLE IF EXISTS role            CASCADE;
DROP TABLE IF EXISTS trap_condition  CASCADE;
DROP TABLE IF EXISTS bait_type       CASCADE;
DROP TABLE IF EXISTS trap_status     CASCADE;
DROP TABLE IF EXISTS species         CASCADE;

-- ── Lookup tables ─────────────────────────────────────────────

-- User roles
CREATE TABLE role (
    role_id   SERIAL PRIMARY KEY,
    role_name VARCHAR(20) NOT NULL UNIQUE  -- Observer | Operator | Admin
);

-- Species caught in traps
CREATE TABLE species (
    species_id SERIAL PRIMARY KEY,
    name       VARCHAR(50) NOT NULL UNIQUE
);

-- Trap check statuses
CREATE TABLE trap_status (
    status_id   SERIAL PRIMARY KEY,
    status_name VARCHAR(60) NOT NULL UNIQUE
);

-- Bait types
CREATE TABLE bait_type (
    bait_type_id SERIAL PRIMARY KEY,
    name         VARCHAR(80) NOT NULL UNIQUE
);

-- Trap condition values
CREATE TABLE trap_condition (
    condition_id SERIAL PRIMARY KEY,
    name         VARCHAR(50) NOT NULL UNIQUE
);

-- ── Core tables ───────────────────────────────────────────────

-- Users (all roles stored in same table)
CREATE TABLE "user" (
    user_id           SERIAL PRIMARY KEY,
    username          VARCHAR(50)  NOT NULL UNIQUE,
    email             VARCHAR(100) NOT NULL UNIQUE,
    password_hash     VARCHAR(255) NOT NULL,
    first_name        VARCHAR(50)  NOT NULL,
    last_name         VARCHAR(50)  NOT NULL,
    contact_info      TEXT,
    emergency_contact TEXT,
    role_id           INTEGER NOT NULL REFERENCES role(role_id),
    is_active         BOOLEAN NOT NULL DEFAULT TRUE
);

-- Trap lines
CREATE TABLE line (
    line_id    SERIAL PRIMARY KEY,
    name       VARCHAR(100) NOT NULL UNIQUE,
    type       VARCHAR(50)  NOT NULL DEFAULT 'Trap',
    is_retired BOOLEAN NOT NULL DEFAULT FALSE
);

-- Individual traps — each belongs to exactly one line
CREATE TABLE trap (
    trap_id    SERIAL PRIMARY KEY,
    code       VARCHAR(50)  NOT NULL UNIQUE,
    trap_type  VARCHAR(50)  NOT NULL,
    line_id    INTEGER NOT NULL REFERENCES line(line_id),
    latitude   DECIMAL(9,6) NOT NULL,
    longitude  DECIMAL(9,6) NOT NULL,
    is_retired BOOLEAN NOT NULL DEFAULT FALSE
);

-- Many-to-many: Operators assigned to Lines
CREATE TABLE operator_line (
    operator_id INTEGER NOT NULL REFERENCES "user"(user_id),
    line_id     INTEGER NOT NULL REFERENCES line(line_id),
    PRIMARY KEY (operator_id, line_id)
);

-- Trap catch records
CREATE TABLE trap_catch (
    catch_id     SERIAL PRIMARY KEY,
    trap_id      INTEGER   NOT NULL REFERENCES trap(trap_id),
    date         TIMESTAMP NOT NULL,
    recorded_by  INTEGER   REFERENCES "user"(user_id),
    species_id   INTEGER   NOT NULL REFERENCES species(species_id),
    sex          VARCHAR(10),        -- Male | Female | NULL
    maturity     VARCHAR(10),        -- Adult | Juvenile | NULL
    status_id    INTEGER   NOT NULL REFERENCES trap_status(status_id),
    rebaited     VARCHAR(3) NOT NULL, -- Yes | No
    bait_type_id INTEGER   NOT NULL REFERENCES bait_type(bait_type_id),
    condition_id INTEGER   NOT NULL REFERENCES trap_condition(condition_id),
    strikes      INTEGER   NOT NULL CHECK (strikes >= 0),
    notes        TEXT
);

-- Incidental observations
CREATE TABLE observation (
    obs_id      SERIAL PRIMARY KEY,
    operator_id INTEGER   NOT NULL REFERENCES "user"(user_id),
    obs_date    TIMESTAMP NOT NULL,
    obs_type    VARCHAR(50),
    location    TEXT,
    notes       TEXT
);
