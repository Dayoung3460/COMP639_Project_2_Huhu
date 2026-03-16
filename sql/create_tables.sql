DROP TABLE IF EXISTS incidental_observations CASCADE;
DROP TABLE IF EXISTS trap_catches CASCADE;
DROP TABLE IF EXISTS operator_lines CASCADE;
DROP TABLE IF EXISTS traps CASCADE;
DROP TABLE IF EXISTS lines CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS species CASCADE;
DROP TABLE IF EXISTS trap_statuses CASCADE;
DROP TABLE IF EXISTS bait_types CASCADE;

DROP TYPE IF EXISTS role_type CASCADE;
DROP TYPE IF EXISTS account_status_type CASCADE;
DROP TYPE IF EXISTS trap_type_enum CASCADE;
DROP TYPE IF EXISTS sex_type CASCADE;
DROP TYPE IF EXISTS maturity_type CASCADE;
DROP TYPE IF EXISTS rebaited_type CASCADE;
DROP TYPE IF EXISTS trap_condition_type CASCADE;

-- ==============================================================================
-- 1. ENUMs for non-changeable types (Static lists defined in instructions)
-- ==============================================================================
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

-- ==============================================================================
-- 2. Lookup tables for Admin-manageable lists (User Stories 18, 19, 20)
-- We use VARCHAR PRIMARY KEY to allow easy and readable CHECK constraints on trap_catches
-- ==============================================================================
CREATE TABLE species (
    name VARCHAR(100) PRIMARY KEY
);

CREATE TABLE trap_statuses (
    name VARCHAR(100) PRIMARY KEY
);

CREATE TABLE bait_types (
    name VARCHAR(100) PRIMARY KEY
);

-- ==============================================================================
-- 3. Core Entities
-- ==============================================================================
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    contact_information TEXT NOT NULL,
    emergency_contact_information TEXT NOT NULL,
    role role_type NOT NULL,
    account_status account_status_type NOT NULL DEFAULT 'active'
);

CREATE TABLE lines (
    line_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    type VARCHAR(255) NOT NULL,
    is_retired BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE traps (
    trap_id SERIAL PRIMARY KEY,
    code VARCHAR(255) NOT NULL UNIQUE,
    trap_type trap_type_enum NOT NULL,
    line_id INTEGER NOT NULL REFERENCES lines(line_id),
    latitude NUMERIC(9, 6) NOT NULL,
    longitude NUMERIC(9, 6) NOT NULL,
    is_retired BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE operator_lines (
    operator_id INTEGER NOT NULL REFERENCES users(user_id),
    line_id INTEGER NOT NULL REFERENCES lines(line_id),
    PRIMARY KEY (operator_id, line_id)
);

CREATE TABLE trap_catches (
    catch_id SERIAL PRIMARY KEY,
    trap_id INTEGER NOT NULL REFERENCES traps(trap_id),
    date TIMESTAMP NOT NULL,
    recorded_by_id INTEGER REFERENCES users(user_id),
    species_caught VARCHAR(100) NOT NULL REFERENCES species(name) ON UPDATE CASCADE,
    sex sex_type,
    maturity maturity_type,
    status VARCHAR(100) NOT NULL REFERENCES trap_statuses(name) ON UPDATE CASCADE,
    rebaited rebaited_type NOT NULL,
    bait_type VARCHAR(100) NOT NULL REFERENCES bait_types(name) ON UPDATE CASCADE,
    bait_details TEXT,
    trap_condition trap_condition_type NOT NULL,
    strikes INTEGER NOT NULL CHECK (strikes >= 0),
    notes TEXT,
    CHECK ((strikes = 0 AND species_caught = 'None') OR strikes >= 1),
    CHECK ((rebaited = 'No' AND bait_type = 'None') OR rebaited = 'Yes')
);

CREATE TABLE incidental_observations (
    observation_id SERIAL PRIMARY KEY,
    date TIMESTAMP NOT NULL,
    operator_id INTEGER NOT NULL REFERENCES users(user_id),
    observation_type VARCHAR(255) NOT NULL,
    notes TEXT,
    latitude NUMERIC(9, 6),
    longitude NUMERIC(9, 6),
    line_id INTEGER REFERENCES lines(line_id),
    trap_id INTEGER REFERENCES traps(trap_id)
);
