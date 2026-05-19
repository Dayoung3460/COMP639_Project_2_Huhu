-- =============================================================
-- create_tables.sql — Conservation Groups Platform
-- COMP639 Group Project 2, Team Huhu — Lincoln University
-- Semester 1, 2026
--
-- Generated from live DB via TablePlus on 2026-05-15.
-- Re-runnable: every DROP uses CASCADE.
--
-- Run order on a fresh PostgreSQL database:
--   1. create_tables.sql      (this file — all 22 tables incl. theme system)
--   2. populate_tables.sql    (seed users, groups, traps, catches, etc.)
--   3. themes_populate.sql    (seed theme presets + platform default)
--
-- Note: the older sql/themes_create.sql is now redundant; its tables
-- (theme_presets, group_themes, platform_theme, theme_history) are
-- included in this file. Delete themes_create.sql after switching.
-- =============================================================

-- -------------------------------------------------------------
-- TablePlus 6.9.0(668)
--
-- https://tableplus.com/
--
-- Database: Tiaki_2
-- Generation Time: 2026-05-15 19:18:53.8250
-- -------------------------------------------------------------


DROP TABLE IF EXISTS "public"."traps" CASCADE;
-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS traps_trap_id_seq;
-- Table Definition
CREATE TABLE "public"."traps" (
    "trap_id" int4 NOT NULL DEFAULT nextval('traps_trap_id_seq'::regclass),
    "code" varchar(255) NOT NULL,
    "trap_type" varchar(100) NOT NULL,
    "line_id" int4 NOT NULL,
    "latitude" numeric(9,6) NOT NULL,
    "longitude" numeric(9,6) NOT NULL,
    "is_retired" bool NOT NULL DEFAULT false,
    "retired_at" timestamp,
    "retired_by" int4,
    PRIMARY KEY ("trap_id")
);

DROP TABLE IF EXISTS "public"."bait_stations" CASCADE;
-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS bait_stations_station_id_seq;

-- Table Definition
CREATE TABLE "public"."bait_stations" (
    "station_id" int4 NOT NULL DEFAULT nextval('bait_stations_station_id_seq'::regclass),
    "code" varchar(255) NOT NULL,
    "station_type" varchar(100) NOT NULL,
    "other_type" varchar(255) DEFAULT NULL::character varying,
    "line_id" int4 NOT NULL,
    "latitude" numeric(9,6) NOT NULL,
    "longitude" numeric(9,6) NOT NULL,
    "is_retired" bool NOT NULL DEFAULT false,
    "retired_at" timestamp,
    "retired_by" int4,
    PRIMARY KEY ("station_id")
);

DROP TABLE IF EXISTS "public"."operator_lines" CASCADE;
-- Table Definition
CREATE TABLE "public"."operator_lines" (
    "operator_id" int4 NOT NULL,
    "line_id" int4 NOT NULL,
    PRIMARY KEY ("operator_id","line_id")
);

DROP TABLE IF EXISTS "public"."trap_catches" CASCADE;
-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS trap_catches_catch_id_seq;
DROP TYPE IF EXISTS "public"."sex_type" CASCADE;
CREATE TYPE "public"."sex_type" AS ENUM ('Male', 'Female');
DROP TYPE IF EXISTS "public"."maturity_type" CASCADE;
CREATE TYPE "public"."maturity_type" AS ENUM ('Juvenile', 'Adult');
DROP TYPE IF EXISTS "public"."rebaited_type" CASCADE;
CREATE TYPE "public"."rebaited_type" AS ENUM ('Yes', 'No');
DROP TYPE IF EXISTS "public"."trap_condition_type" CASCADE;
CREATE TYPE "public"."trap_condition_type" AS ENUM ('OK', 'Needs maintenance', 'Repaired', 'Regassed', 'Recurred', 'Battery charge');

-- Table Definition
CREATE TABLE "public"."trap_catches" (
    "catch_id" int4 NOT NULL DEFAULT nextval('trap_catches_catch_id_seq'::regclass),
    "trap_id" int4 NOT NULL,
    "date" timestamp NOT NULL,
    "recorded_by_id" int4,
    "species_caught" varchar(100) NOT NULL,
    "sex" "public"."sex_type",
    "maturity" "public"."maturity_type",
    "status" varchar(100) NOT NULL,
    "rebaited" "public"."rebaited_type" NOT NULL,
    "bait_type" varchar(100) NOT NULL,
    "bait_details" text,
    "trap_condition" "public"."trap_condition_type" NOT NULL,
    "strikes" int4 NOT NULL CHECK (strikes >= 0),
    "notes" text,
    PRIMARY KEY ("catch_id")
);

DROP TABLE IF EXISTS "public"."species" CASCADE;
-- Table Definition
CREATE TABLE "public"."species" (
    "name" varchar(100) NOT NULL,
    "is_active" bool NOT NULL DEFAULT true,
    PRIMARY KEY ("name")
);

DROP TABLE IF EXISTS "public"."trap_statuses" CASCADE;
-- Table Definition
CREATE TABLE "public"."trap_statuses" (
    "name" varchar(100) NOT NULL,
    "is_active" bool NOT NULL DEFAULT true,
    PRIMARY KEY ("name")
);

DROP TABLE IF EXISTS "public"."bait_types" CASCADE;
-- Table Definition
CREATE TABLE "public"."bait_types" (
    "name" varchar(100) NOT NULL,
    "is_active" bool NOT NULL DEFAULT true,
    PRIMARY KEY ("name")
);

DROP TABLE IF EXISTS "public"."trap_types" CASCADE;
-- Table Definition
CREATE TABLE "public"."trap_types" (
    "name" varchar(100) NOT NULL,
    "is_active" bool NOT NULL DEFAULT true,
    PRIMARY KEY ("name")
);

DROP TABLE IF EXISTS "public"."bait_station_types" CASCADE;
-- Table Definition
CREATE TABLE "public"."bait_station_types" (
    "name" varchar(100) NOT NULL,
    "is_active" bool NOT NULL DEFAULT true,
    PRIMARY KEY ("name")
);

DROP TABLE IF EXISTS "public"."bait_formulations" CASCADE;
-- Table Definition
CREATE TABLE "public"."bait_formulations" (
    "name" varchar(100) NOT NULL,
    "is_active" bool NOT NULL DEFAULT true,
    PRIMARY KEY ("name")
);

DROP TABLE IF EXISTS "public"."active_ingredients" CASCADE;
-- Table Definition
CREATE TABLE "public"."active_ingredients" (
    "name" varchar(100) NOT NULL,
    "is_active" bool NOT NULL DEFAULT true,
    PRIMARY KEY ("name")
);

DROP TABLE IF EXISTS "public"."bait_station_records" CASCADE;
-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS bait_station_records_record_id_seq;

-- Table Definition
CREATE TABLE "public"."bait_station_records" (
    "record_id" int4 NOT NULL DEFAULT nextval('bait_station_records_record_id_seq'::regclass),
    "station_id" int4 NOT NULL,
    "date" timestamp NOT NULL,
    "recorded_by_id" int4,
    "target_species" varchar(100),
    "active_ingredient" varchar(100) NOT NULL,
    "formulation" varchar(100) NOT NULL,
    "concentration" numeric(5,2) NOT NULL,
    "bait_remaining" numeric(8,3) NOT NULL,
    "bait_removed" numeric(8,3) DEFAULT NULL::numeric,
    "bait_added" numeric(8,3) DEFAULT NULL::numeric,
    "notes" text,
    "edited_by_id" int4 DEFAULT NULL,
    "edited_at" timestamp DEFAULT NULL,
    PRIMARY KEY ("record_id")
);

DROP TABLE IF EXISTS "public"."incidental_observations" CASCADE;
-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS incidental_observations_observation_id_seq;
DROP TYPE IF EXISTS "public"."observation_type_enum" CASCADE;
CREATE TYPE "public"."observation_type_enum" AS ENUM ('Bird sighting', 'Predator sighting', 'Predator tracks', 'Native species tracks', 'Native species sign', 'Other');

-- Table Definition
CREATE TABLE "public"."incidental_observations" (
    "observation_id" int4 NOT NULL DEFAULT nextval('incidental_observations_observation_id_seq'::regclass),
    "date" timestamp NOT NULL,
    "operator_id" int4 NOT NULL,
    "observation_type" "public"."observation_type_enum" NOT NULL,
    "notes" text,
    "latitude" numeric(9,6),
    "longitude" numeric(9,6),
    "line_id" int4 NOT NULL,
    "trap_id" int4,
    PRIMARY KEY ("observation_id")
);

DROP TABLE IF EXISTS "public"."password_reset_tokens" CASCADE;
-- Table Definition
CREATE TABLE "public"."password_reset_tokens" (
    "token" varchar(64) NOT NULL,
    "user_id" int4 NOT NULL,
    "expires_at" timestamp NOT NULL,
    "used" bool NOT NULL DEFAULT false,
    PRIMARY KEY ("token")
);

DROP TABLE IF EXISTS "public"."users" CASCADE;
-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS users_user_id_seq;
DROP TYPE IF EXISTS "public"."account_status_type" CASCADE;
CREATE TYPE "public"."account_status_type" AS ENUM ('active', 'inactive', 'suspended');

-- Table Definition
CREATE TABLE "public"."users" (
    "user_id" int4 NOT NULL DEFAULT nextval('users_user_id_seq'::regclass),
    "username" varchar(255) NOT NULL,
    "email" varchar(255) NOT NULL,
    "password_hash" varchar(255) NOT NULL,
    "first_name" varchar(255) NOT NULL,
    "last_name" varchar(255) NOT NULL,
    "phone" varchar(20) DEFAULT NULL::character varying,
    "address" varchar(255) DEFAULT NULL::character varying,
    "emergency_contact_name" varchar(100) DEFAULT NULL::character varying,
    "emergency_contact_phone" varchar(20) DEFAULT NULL::character varying,
    "profile_photo" varchar(255) DEFAULT NULL::character varying,
    "notes" text,
    "is_super_admin"    bool NOT NULL DEFAULT false,
    "is_support_tech"   bool NOT NULL DEFAULT false,
    "account_status" "public"."account_status_type" NOT NULL DEFAULT 'active'::account_status_type,
    "date_joined" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "last_login" timestamp,
    PRIMARY KEY ("user_id")
);

DROP TABLE IF EXISTS "public"."group_memberships" CASCADE;
-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS group_memberships_membership_id_seq;
DROP TYPE IF EXISTS "public"."group_role_type" CASCADE;
CREATE TYPE "public"."group_role_type" AS ENUM ('Observer', 'Operator', 'Group Coordinator');

-- Table Definition
CREATE TABLE "public"."group_memberships" (
    "membership_id" int4 NOT NULL DEFAULT nextval('group_memberships_membership_id_seq'::regclass),
    "user_id" int4 NOT NULL,
    "group_id" int4 NOT NULL,
    "role" "public"."group_role_type" NOT NULL,
    "joined_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("membership_id")
);

DROP TABLE IF EXISTS "public"."group_join_requests" CASCADE;
-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS group_join_requests_request_id_seq;
DROP TYPE IF EXISTS "public"."request_status_enum" CASCADE;
CREATE TYPE "public"."request_status_enum" AS ENUM ('pending', 'approved', 'rejected', 'cancelled');

-- Table Definition
CREATE TABLE "public"."group_join_requests" (
    "request_id" int4 NOT NULL DEFAULT nextval('group_join_requests_request_id_seq'::regclass),
    "user_id" int4 NOT NULL,
    "group_id" int4 NOT NULL,
    "status" "public"."request_status_enum" NOT NULL DEFAULT 'pending'::request_status_enum,
    "message" text,
    "requested_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("request_id")
);

DROP TABLE IF EXISTS "public"."user_notifications" CASCADE;
-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS user_notifications_notification_id_seq;

-- Table Definition
CREATE TABLE "public"."user_notifications" (
    "notification_id" int4 NOT NULL DEFAULT nextval('user_notifications_notification_id_seq'::regclass),
    "user_id" int4 NOT NULL,
    "group_id" int4 DEFAULT NULL REFERENCES groups(group_id) ON DELETE CASCADE,
    "message" text NOT NULL,
    "category" varchar(20) NOT NULL DEFAULT 'info'::character varying,
    "url" varchar(500) DEFAULT NULL,
    "is_active" bool NOT NULL DEFAULT true,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("notification_id")
);

DROP TABLE IF EXISTS "public"."group_applications" CASCADE;
-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS group_applications_application_id_seq;

-- Table Definition
CREATE TABLE "public"."group_applications" (
    "application_id" int4 NOT NULL DEFAULT nextval('group_applications_application_id_seq'::regclass),
    "user_id" int4 NOT NULL,
    "proposed_name" varchar(255) NOT NULL,
    "description" text NOT NULL,
    "location" varchar(255) NOT NULL,
    "justification" text NOT NULL,
    "image" varchar(500) DEFAULT NULL::character varying,
    "status" "public"."request_status_enum" NOT NULL DEFAULT 'pending'::request_status_enum,
    "applied_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "decided_by" int4,
    "decided_at" timestamp,
    "decision_reason" text,
    PRIMARY KEY ("application_id")
);

DROP TABLE IF EXISTS "public"."lines" CASCADE;
-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS lines_line_id_seq;
DROP TYPE IF EXISTS "public"."line_type_enum" CASCADE;
CREATE TYPE "public"."line_type_enum" AS ENUM ('Trap', 'Bait Station');

-- Table Definition
CREATE TABLE "public"."lines" (
    "line_id" int4 NOT NULL DEFAULT nextval('lines_line_id_seq'::regclass),
    "name" varchar(255) NOT NULL,
    "type" "public"."line_type_enum" NOT NULL,
    "group_id" int4 NOT NULL,
    "is_retired" bool NOT NULL DEFAULT false,
    "retired_at" timestamp,
    "retired_by" int4,
    PRIMARY KEY ("line_id")
);

DROP TABLE IF EXISTS "public"."groups" CASCADE;
-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS groups_group_id_seq;

-- Table Definition
CREATE TABLE "public"."groups" (
    "group_id" int4 NOT NULL DEFAULT nextval('groups_group_id_seq'::regclass),
    "name" varchar(255) NOT NULL,
    "description" text,
    "location" varchar(255),
    "is_public" bool NOT NULL DEFAULT true,
    "is_active" bool NOT NULL DEFAULT true,
    "cover_photo" varchar(255) DEFAULT NULL::character varying,
    "color_theme" varchar(7) NOT NULL DEFAULT '#198754'::character varying,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "profile_photo" varchar(255),
    "tile_image" varchar(255) DEFAULT NULL::character varying,
    PRIMARY KEY ("group_id")
);

-- Column Comment
COMMENT ON COLUMN "public"."groups"."cover_photo" IS 'Large banner shown at top of group pages and on browse cards. Coordinator-controlled.';
COMMENT ON COLUMN "public"."groups"."profile_photo" IS 'Group avatar shown in nav, member lists, and My Groups. Coordinator-controlled.';
COMMENT ON COLUMN "public"."groups"."tile_image" IS 'Image shown on the public home browse grid and the Super Admin groups list. Super Admin controlled.';

DROP TABLE IF EXISTS "public"."platform_settings" CASCADE;
-- Table Definition
CREATE TABLE "public"."platform_settings" (
    "id" int4 NOT NULL DEFAULT 1 CHECK (id = 1),
    "cover_photo" varchar(255),
    "profile_photo" varchar(255),
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_by" int4,
    PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS "public"."theme_presets" CASCADE;
-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS theme_presets_preset_id_seq;
DROP TYPE IF EXISTS "public"."button_style_type" CASCADE;
CREATE TYPE "public"."button_style_type" AS ENUM ('rounded', 'square');
DROP TYPE IF EXISTS "public"."nav_position_type" CASCADE;
CREATE TYPE "public"."nav_position_type" AS ENUM ('sidebar', 'topbar');
DROP TYPE IF EXISTS "public"."content_width_type" CASCADE;
CREATE TYPE "public"."content_width_type" AS ENUM ('wrap', 'full');

-- Table Definition
CREATE TABLE "public"."theme_presets" (
    "preset_id" int4 NOT NULL DEFAULT nextval('theme_presets_preset_id_seq'::regclass),
    "name" varchar(100) NOT NULL,
    "description" text,
    "primary_color" varchar(7) NOT NULL CHECK ((primary_color)::text ~ '^#[0-9A-Fa-f]{6}$'::text),
    "secondary_color" varchar(7) NOT NULL CHECK ((secondary_color)::text ~ '^#[0-9A-Fa-f]{6}$'::text),
    "background_color" varchar(7) NOT NULL CHECK ((background_color)::text ~ '^#[0-9A-Fa-f]{6}$'::text),
    "button_style" "public"."button_style_type" NOT NULL,
    "preview_image" varchar(255),
    "display_order" int4 NOT NULL DEFAULT 0,
    "nav_position" "public"."nav_position_type" NOT NULL,
    "content_width" "public"."content_width_type" NOT NULL,
    "font_heading" varchar(80) NOT NULL,
    "font_body" varchar(80) NOT NULL,
    PRIMARY KEY ("preset_id")
);

DROP TABLE IF EXISTS "public"."group_themes" CASCADE;

-- Table Definition
CREATE TABLE "public"."group_themes" (
    "group_id" int4 NOT NULL,
    "primary_color" varchar(7) NOT NULL CHECK ((primary_color)::text ~ '^#[0-9A-Fa-f]{6}$'::text),
    "secondary_color" varchar(7) NOT NULL CHECK ((secondary_color)::text ~ '^#[0-9A-Fa-f]{6}$'::text),
    "background_color" varchar(7) NOT NULL CHECK ((background_color)::text ~ '^#[0-9A-Fa-f]{6}$'::text),
    "button_style" "public"."button_style_type" NOT NULL,
    "based_on_preset" int4,
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_by" int4,
    "nav_position" "public"."nav_position_type" NOT NULL,
    "content_width" "public"."content_width_type" NOT NULL,
    "font_heading" varchar(80) NOT NULL,
    "font_body" varchar(80) NOT NULL,
    PRIMARY KEY ("group_id")
);

DROP TABLE IF EXISTS "public"."platform_theme" CASCADE;

-- Table Definition
CREATE TABLE "public"."platform_theme" (
    "id" int4 NOT NULL DEFAULT 1 CHECK (id = 1),
    "primary_color" varchar(7) NOT NULL CHECK ((primary_color)::text ~ '^#[0-9A-Fa-f]{6}$'::text),
    "secondary_color" varchar(7) NOT NULL CHECK ((secondary_color)::text ~ '^#[0-9A-Fa-f]{6}$'::text),
    "background_color" varchar(7) NOT NULL CHECK ((background_color)::text ~ '^#[0-9A-Fa-f]{6}$'::text),
    "button_style" "public"."button_style_type" NOT NULL,
    "based_on_preset" int4,
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_by" int4,
    "nav_position" "public"."nav_position_type" NOT NULL,
    "content_width" "public"."content_width_type" NOT NULL,
    "font_heading" varchar(80) NOT NULL,
    "font_body" varchar(80) NOT NULL,
    PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS "public"."theme_history" CASCADE;
-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS theme_history_history_id_seq;

-- Table Definition
CREATE TABLE "public"."theme_history" (
    "history_id" int4 NOT NULL DEFAULT nextval('theme_history_history_id_seq'::regclass),
    "group_id" int4,
    "primary_color" varchar(7) NOT NULL CHECK ((primary_color)::text ~ '^#[0-9A-Fa-f]{6}$'::text),
    "secondary_color" varchar(7) NOT NULL CHECK ((secondary_color)::text ~ '^#[0-9A-Fa-f]{6}$'::text),
    "background_color" varchar(7) NOT NULL CHECK ((background_color)::text ~ '^#[0-9A-Fa-f]{6}$'::text),
    "button_style" "public"."button_style_type" NOT NULL,
    "based_on_preset" int4,
    "saved_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "saved_by" int4,
    "nav_position" "public"."nav_position_type" NOT NULL,
    "content_width" "public"."content_width_type" NOT NULL,
    "font_heading" varchar(80) NOT NULL,
    "font_body" varchar(80) NOT NULL,
    "name" varchar(80),
    "is_pinned" bool NOT NULL DEFAULT false,
    PRIMARY KEY ("history_id")
);

ALTER TABLE "public"."traps" ADD FOREIGN KEY ("line_id") REFERENCES "public"."lines"("line_id");
ALTER TABLE "public"."traps" ADD FOREIGN KEY ("retired_by") REFERENCES "public"."users"("user_id");


-- Indices
CREATE UNIQUE INDEX traps_code_key ON public.traps USING btree (code);
ALTER TABLE "public"."bait_stations" ADD FOREIGN KEY ("line_id") REFERENCES "public"."lines"("line_id");
ALTER TABLE "public"."bait_stations" ADD FOREIGN KEY ("retired_by") REFERENCES "public"."users"("user_id");


-- Indices
CREATE UNIQUE INDEX bait_stations_code_key ON public.bait_stations USING btree (code);
ALTER TABLE "public"."operator_lines" ADD FOREIGN KEY ("line_id") REFERENCES "public"."lines"("line_id");
ALTER TABLE "public"."operator_lines" ADD FOREIGN KEY ("operator_id") REFERENCES "public"."users"("user_id");
ALTER TABLE "public"."trap_catches" ADD FOREIGN KEY ("recorded_by_id") REFERENCES "public"."users"("user_id");
ALTER TABLE "public"."trap_catches" ADD FOREIGN KEY ("bait_type") REFERENCES "public"."bait_types"("name") ON UPDATE CASCADE;
ALTER TABLE "public"."trap_catches" ADD FOREIGN KEY ("trap_id") REFERENCES "public"."traps"("trap_id");
ALTER TABLE "public"."trap_catches" ADD FOREIGN KEY ("status") REFERENCES "public"."trap_statuses"("name") ON UPDATE CASCADE;
ALTER TABLE "public"."trap_catches" ADD FOREIGN KEY ("species_caught") REFERENCES "public"."species"("name") ON UPDATE CASCADE;
ALTER TABLE "public"."bait_station_records" ADD FOREIGN KEY ("station_id") REFERENCES "public"."bait_stations"("station_id");
ALTER TABLE "public"."bait_station_records" ADD FOREIGN KEY ("recorded_by_id") REFERENCES "public"."users"("user_id");
ALTER TABLE "public"."bait_station_records" ADD FOREIGN KEY ("edited_by_id") REFERENCES "public"."users"("user_id");
ALTER TABLE "public"."bait_station_records" ADD FOREIGN KEY ("target_species") REFERENCES "public"."species"("name") ON UPDATE CASCADE;
ALTER TABLE "public"."bait_station_records" ADD FOREIGN KEY ("active_ingredient") REFERENCES "public"."active_ingredients"("name") ON UPDATE CASCADE;
ALTER TABLE "public"."bait_station_records" ADD FOREIGN KEY ("formulation") REFERENCES "public"."bait_formulations"("name") ON UPDATE CASCADE;
ALTER TABLE "public"."traps" ADD FOREIGN KEY ("trap_type") REFERENCES "public"."trap_types"("name") ON UPDATE CASCADE;
ALTER TABLE "public"."bait_stations" ADD FOREIGN KEY ("station_type") REFERENCES "public"."bait_station_types"("name") ON UPDATE CASCADE;
ALTER TABLE "public"."incidental_observations" ADD FOREIGN KEY ("operator_id") REFERENCES "public"."users"("user_id");
ALTER TABLE "public"."incidental_observations" ADD FOREIGN KEY ("trap_id") REFERENCES "public"."traps"("trap_id");
ALTER TABLE "public"."incidental_observations" ADD FOREIGN KEY ("line_id") REFERENCES "public"."lines"("line_id");
ALTER TABLE "public"."password_reset_tokens" ADD FOREIGN KEY ("user_id") REFERENCES "public"."users"("user_id") ON DELETE CASCADE;


-- Indices
CREATE UNIQUE INDEX users_username_key ON public.users USING btree (username);
CREATE UNIQUE INDEX users_email_key ON public.users USING btree (email);
ALTER TABLE "public"."group_memberships" ADD FOREIGN KEY ("user_id") REFERENCES "public"."users"("user_id") ON DELETE CASCADE;
ALTER TABLE "public"."group_memberships" ADD FOREIGN KEY ("group_id") REFERENCES "public"."groups"("group_id") ON DELETE CASCADE;


-- Indices
CREATE UNIQUE INDEX group_memberships_user_id_group_id_key ON public.group_memberships USING btree (user_id, group_id);
ALTER TABLE "public"."group_join_requests" ADD FOREIGN KEY ("user_id") REFERENCES "public"."users"("user_id") ON DELETE CASCADE;
ALTER TABLE "public"."group_join_requests" ADD FOREIGN KEY ("group_id") REFERENCES "public"."groups"("group_id") ON DELETE CASCADE;


-- Indices
CREATE UNIQUE INDEX group_join_requests_one_pending_per_user_group ON public.group_join_requests (user_id, group_id) WHERE status = 'pending';
ALTER TABLE "public"."user_notifications" ADD FOREIGN KEY ("user_id") REFERENCES "public"."users"("user_id") ON DELETE CASCADE;
ALTER TABLE "public"."group_applications" ADD FOREIGN KEY ("user_id") REFERENCES "public"."users"("user_id") ON DELETE CASCADE;
ALTER TABLE "public"."group_applications" ADD FOREIGN KEY ("decided_by") REFERENCES "public"."users"("user_id");
ALTER TABLE "public"."lines" ADD FOREIGN KEY ("group_id") REFERENCES "public"."groups"("group_id");
ALTER TABLE "public"."lines" ADD FOREIGN KEY ("retired_by") REFERENCES "public"."users"("user_id");


-- Indices
CREATE UNIQUE INDEX lines_name_key ON public.lines USING btree (name);


-- Indices
CREATE UNIQUE INDEX groups_name_key ON public.groups USING btree (name);
ALTER TABLE "public"."platform_settings" ADD FOREIGN KEY ("updated_by") REFERENCES "public"."users"("user_id");


-- Indices
CREATE UNIQUE INDEX theme_presets_name_key ON public.theme_presets USING btree (name);
ALTER TABLE "public"."group_themes" ADD FOREIGN KEY ("group_id") REFERENCES "public"."groups"("group_id") ON DELETE CASCADE;
ALTER TABLE "public"."group_themes" ADD FOREIGN KEY ("updated_by") REFERENCES "public"."users"("user_id");
ALTER TABLE "public"."group_themes" ADD FOREIGN KEY ("based_on_preset") REFERENCES "public"."theme_presets"("preset_id") ON DELETE SET NULL;
ALTER TABLE "public"."platform_theme" ADD FOREIGN KEY ("based_on_preset") REFERENCES "public"."theme_presets"("preset_id") ON DELETE SET NULL;
ALTER TABLE "public"."platform_theme" ADD FOREIGN KEY ("updated_by") REFERENCES "public"."users"("user_id");
ALTER TABLE "public"."theme_history" ADD FOREIGN KEY ("group_id") REFERENCES "public"."groups"("group_id") ON DELETE CASCADE;
ALTER TABLE "public"."theme_history" ADD FOREIGN KEY ("based_on_preset") REFERENCES "public"."theme_presets"("preset_id") ON DELETE SET NULL;
ALTER TABLE "public"."theme_history" ADD FOREIGN KEY ("saved_by") REFERENCES "public"."users"("user_id");


-- Indices
CREATE INDEX theme_history_group_saved ON public.theme_history USING btree (group_id, saved_at DESC);
CREATE INDEX theme_history_group_pinned_saved ON public.theme_history USING btree (group_id, is_pinned DESC, saved_at DESC);


-- =============================================================
-- Table-level CHECK constraints
-- TablePlus does not export table-level CHECK constraints, so they
-- are re-applied here explicitly.
-- =============================================================

ALTER TABLE "public"."bait_stations"
    ADD CONSTRAINT other_type_required
    CHECK (station_type != 'Other' OR other_type IS NOT NULL);

ALTER TABLE "public"."trap_catches"
    ADD CONSTRAINT strikes_species_consistency
    CHECK ((strikes = 0 AND species_caught = 'None') OR strikes >= 1);

ALTER TABLE "public"."trap_catches"
    ADD CONSTRAINT rebaited_bait_consistency
    CHECK ((rebaited = 'No' AND bait_type = 'None') OR rebaited = 'Yes');

ALTER TABLE "public"."theme_history"
    ADD CONSTRAINT th_pinned_requires_name
    CHECK (is_pinned = FALSE OR name IS NOT NULL);

-- ==============================================================
-- Support Tickets (Helpdesk Epic — P2-49)
-- ==============================================================

DROP TYPE IF EXISTS ticket_type_enum     CASCADE;
DROP TYPE IF EXISTS ticket_priority_enum CASCADE;
DROP TYPE IF EXISTS ticket_status_enum   CASCADE;

CREATE TYPE ticket_type_enum     AS ENUM ('Help', 'Bug Report');
CREATE TYPE ticket_priority_enum AS ENUM ('Low', 'Medium', 'High');
CREATE TYPE ticket_status_enum   AS ENUM ('New', 'Open', 'Stalled', 'Resolved');

DROP TABLE IF EXISTS support_tickets CASCADE;

CREATE TABLE support_tickets (
    ticket_id    SERIAL               PRIMARY KEY,
    submitted_by INTEGER              NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    group_id     INTEGER              REFERENCES groups(group_id) ON DELETE SET NULL,
    request_type ticket_type_enum     NOT NULL,
    title        VARCHAR(255)         NOT NULL,
    description  TEXT                 NOT NULL,
    priority     ticket_priority_enum NOT NULL,
    screenshot   VARCHAR(500)         DEFAULT NULL,
    status       ticket_status_enum   NOT NULL DEFAULT 'New',
    assigned_to  INTEGER              REFERENCES users(user_id) ON DELETE SET NULL DEFAULT NULL,
    created_at   TIMESTAMP            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP            NOT NULL DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS ticket_replies CASCADE;

CREATE TABLE ticket_replies (
    reply_id     SERIAL    PRIMARY KEY,
    ticket_id    INTEGER   NOT NULL REFERENCES support_tickets(ticket_id) ON DELETE CASCADE,
    author_id    INTEGER   NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    body         TEXT      NOT NULL,
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS ticket_status_history CASCADE;

CREATE TABLE ticket_status_history (
    history_id   SERIAL             PRIMARY KEY,
    ticket_id    INTEGER            NOT NULL REFERENCES support_tickets(ticket_id) ON DELETE CASCADE,
    changed_by   INTEGER            REFERENCES users(user_id) ON DELETE SET NULL,
    old_status   ticket_status_enum NOT NULL,
    new_status   ticket_status_enum NOT NULL,
    note         TEXT               DEFAULT NULL,
    changed_at   TIMESTAMP          NOT NULL DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS kb_articles CASCADE;
DROP TABLE IF EXISTS kb_categories CASCADE;

CREATE TABLE kb_categories (
    category_id SERIAL      PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    sort_order  INT          NOT NULL DEFAULT 0
);

INSERT INTO kb_categories (name, sort_order) VALUES
    ('Account & Login', 1),
    ('Lines & Traps',   2),
    ('Bait Stations',   3),
    ('Records',         4);

CREATE TABLE kb_articles (
    article_id  SERIAL       PRIMARY KEY,
    category_id INT          NOT NULL REFERENCES kb_categories(category_id),
    title       VARCHAR(255) NOT NULL,
    body        TEXT         NOT NULL,
    is_published BOOL        NOT NULL DEFAULT FALSE,
    created_by  INT          REFERENCES users(user_id) ON DELETE SET NULL,
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by  INT          REFERENCES users(user_id) ON DELETE SET NULL,
    updated_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS user_suspension_log CASCADE;

CREATE TABLE user_suspension_log (
    log_id         SERIAL    PRIMARY KEY,
    target_user_id INTEGER   NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    actor_user_id  INTEGER   REFERENCES users(user_id) ON DELETE SET NULL,
    action         VARCHAR(20) NOT NULL CHECK (action IN ('suspended', 'reinstated')),
    reason         TEXT      NOT NULL,
    created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
