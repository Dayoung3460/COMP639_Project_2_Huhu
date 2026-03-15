-- =============================================================
-- populate_database.sql — PF-LU Seed Data
-- COMP639 Group Project 1 — Semester 1, 2026
--
-- Run AFTER create_tables.sql
--
-- IMPORTANT: Replace placeholder password hashes before use.
-- Generate real hashes with:
--   python -c "from flask_bcrypt import generate_password_hash; \
--              print(generate_password_hash('Password1!').decode())"
-- =============================================================

-- ── Roles ─────────────────────────────────────────────────────
INSERT INTO role (role_name) VALUES
    ('Observer'),
    ('Operator'),
    ('Admin');

-- ── Species ───────────────────────────────────────────────────
INSERT INTO species (name) VALUES
    ('None'),
    ('Ferret'),
    ('Hedgehog'),
    ('Mouse'),
    ('Possum'),
    ('Kiore Rat'),
    ('Norway Rat'),
    ('Ship Rat'),
    ('Stoat'),
    ('Weasel'),
    ('Unspecified');

-- ── Trap statuses ─────────────────────────────────────────────
INSERT INTO trap_status (status_name) VALUES
    ('Initial set'),
    ('Removed for Repair'),
    ('Sprung'),
    ('Still set, bait OK'),
    ('Still set, bait bad'),
    ('Still set, bait missing'),
    ('Trap Replaced'),
    ('Trap gone'),
    ('Trap interfered with');

-- ── Trap conditions ───────────────────────────────────────────
INSERT INTO trap_condition (name) VALUES
    ('OK'),
    ('Needs maintenance'),
    ('Repaired'),
    ('Regassed'),
    ('Recurred'),
    ('Battery charge');

-- ── Bait types ────────────────────────────────────────────────
-- Add remaining values from the project brief as needed
INSERT INTO bait_type (name) VALUES
    ('None'),
    ('Peanut butter'),
    ('Egg'),
    ('Goodnature Nut Butter'),
    ('Goodnature Chocolate'),
    ('Goodnature Blood'),
    ('Salmon'),
    ('Dehydrated Rabbit'),
    ('Fresh Possum'),
    ('Fresh Rabbit'),
    ('Nutella'),
    ('Carrot'),
    ('Cheese'),
    ('Chocolate'),
    ('Fish'),
    ('Other (please specify)');

-- ── Admin accounts (2 required) ───────────────────────────────
INSERT INTO "user"
    (username, email, password_hash, first_name, last_name, role_id)
VALUES
    ('admin1', 'admin1@pflu.ac.nz',
     '$2b$12$DSNt3QbdOpc7a6dVMHo8iO0Do6v6sAnIye6Bb8SvuIlQRk7TSCG6G',
     'Admin', 'One',
     (SELECT role_id FROM role WHERE role_name = 'Admin')),
    ('admin2', 'admin2@pflu.ac.nz',
     '$2b$12$DSNt3QbdOpc7a6dVMHo8iO0Do6v6sAnIye6Bb8SvuIlQRk7TSCG6G',
     'Admin', 'Two',
     (SELECT role_id FROM role WHERE role_name = 'Admin'));

-- ── Operator accounts (10 required) ───────────────────────────
INSERT INTO "user"
    (username, email, password_hash, first_name, last_name, role_id)
VALUES
    ('operator1',  'op1@pflu.ac.nz',  '$2b$12$DSNt3QbdOpc7a6dVMHo8iO0Do6v6sAnIye6Bb8SvuIlQRk7TSCG6G', 'James',  'Ruane',    (SELECT role_id FROM role WHERE role_name = 'Operator')),
    ('operator2',  'op2@pflu.ac.nz',  '$2b$12$DSNt3QbdOpc7a6dVMHo8iO0Do6v6sAnIye6Bb8SvuIlQRk7TSCG6G', 'Aroha',  'Kahu',     (SELECT role_id FROM role WHERE role_name = 'Operator')),
    ('operator3',  'op3@pflu.ac.nz',  '$2b$12$DSNt3QbdOpc7a6dVMHo8iO0Do6v6sAnIye6Bb8SvuIlQRk7TSCG6G', 'Tom',    'Walker',   (SELECT role_id FROM role WHERE role_name = 'Operator')),
    ('operator4',  'op4@pflu.ac.nz',  '$2b$12$DSNt3QbdOpc7a6dVMHo8iO0Do6v6sAnIye6Bb8SvuIlQRk7TSCG6G', 'Nina',   'Brown',    (SELECT role_id FROM role WHERE role_name = 'Operator')),
    ('operator5',  'op5@pflu.ac.nz',  '$2b$12$DSNt3QbdOpc7a6dVMHo8iO0Do6v6sAnIye6Bb8SvuIlQRk7TSCG6G', 'Liam',   'Chen',     (SELECT role_id FROM role WHERE role_name = 'Operator')),
    ('operator6',  'op6@pflu.ac.nz',  '$2b$12$DSNt3QbdOpc7a6dVMHo8iO0Do6v6sAnIye6Bb8SvuIlQRk7TSCG6G', 'Mei',    'Zhang',    (SELECT role_id FROM role WHERE role_name = 'Operator')),
    ('operator7',  'op7@pflu.ac.nz',  '$2b$12$DSNt3QbdOpc7a6dVMHo8iO0Do6v6sAnIye6Bb8SvuIlQRk7TSCG6G', 'Sam',    'Wilson',   (SELECT role_id FROM role WHERE role_name = 'Operator')),
    ('operator8',  'op8@pflu.ac.nz',  '$2b$12$DSNt3QbdOpc7a6dVMHo8iO0Do6v6sAnIye6Bb8SvuIlQRk7TSCG6G', 'Priya',  'Patel',    (SELECT role_id FROM role WHERE role_name = 'Operator')),
    ('operator9',  'op9@pflu.ac.nz',  '$2b$12$DSNt3QbdOpc7a6dVMHo8iO0Do6v6sAnIye6Bb8SvuIlQRk7TSCG6G', 'Carlos', 'Rivera',   (SELECT role_id FROM role WHERE role_name = 'Operator')),
    ('operator10', 'op10@pflu.ac.nz', '$2b$12$DSNt3QbdOpc7a6dVMHo8iO0Do6v6sAnIye6Bb8SvuIlQRk7TSCG6G', 'Fiona',  'McDonald', (SELECT role_id FROM role WHERE role_name = 'Operator'));

-- ── Observer accounts (10 required) ───────────────────────────
INSERT INTO "user"
    (username, email, password_hash, first_name, last_name, role_id)
VALUES
    ('observer1',  'obs1@pflu.ac.nz',  '$2b$12$DSNt3QbdOpc7a6dVMHo8iO0Do6v6sAnIye6Bb8SvuIlQRk7TSCG6G', 'Sarah',  'Thompson', (SELECT role_id FROM role WHERE role_name = 'Observer')),
    ('observer2',  'obs2@pflu.ac.nz',  '$2b$12$DSNt3QbdOpc7a6dVMHo8iO0Do6v6sAnIye6Bb8SvuIlQRk7TSCG6G', 'Mike',   'Jones',    (SELECT role_id FROM role WHERE role_name = 'Observer')),
    ('observer3',  'obs3@pflu.ac.nz',  '$2b$12$DSNt3QbdOpc7a6dVMHo8iO0Do6v6sAnIye6Bb8SvuIlQRk7TSCG6G', 'Ella',   'Davis',    (SELECT role_id FROM role WHERE role_name = 'Observer')),
    ('observer4',  'obs4@pflu.ac.nz',  '$2b$12$DSNt3QbdOpc7a6dVMHo8iO0Do6v6sAnIye6Bb8SvuIlQRk7TSCG6G', 'Noah',   'Martin',   (SELECT role_id FROM role WHERE role_name = 'Observer')),
    ('observer5',  'obs5@pflu.ac.nz',  '$2b$12$DSNt3QbdOpc7a6dVMHo8iO0Do6v6sAnIye6Bb8SvuIlQRk7TSCG6G', 'Isla',   'White',    (SELECT role_id FROM role WHERE role_name = 'Observer')),
    ('observer6',  'obs6@pflu.ac.nz',  '$2b$12$DSNt3QbdOpc7a6dVMHo8iO0Do6v6sAnIye6Bb8SvuIlQRk7TSCG6G', 'Jack',   'Harris',   (SELECT role_id FROM role WHERE role_name = 'Observer')),
    ('observer7',  'obs7@pflu.ac.nz',  '$2b$12$DSNt3QbdOpc7a6dVMHo8iO0Do6v6sAnIye6Bb8SvuIlQRk7TSCG6G', 'Chloe',  'Clark',    (SELECT role_id FROM role WHERE role_name = 'Observer')),
    ('observer8',  'obs8@pflu.ac.nz',  '$2b$12$DSNt3QbdOpc7a6dVMHo8iO0Do6v6sAnIye6Bb8SvuIlQRk7TSCG6G', 'Oliver', 'Lewis',    (SELECT role_id FROM role WHERE role_name = 'Observer')),
    ('observer9',  'obs9@pflu.ac.nz',  '$2b$12$DSNt3QbdOpc7a6dVMHo8iO0Do6v6sAnIye6Bb8SvuIlQRk7TSCG6G', 'Grace',  'Hall',     (SELECT role_id FROM role WHERE role_name = 'Observer')),
    ('observer10', 'obs10@pflu.ac.nz', '$2b$12$DSNt3QbdOpc7a6dVMHo8iO0Do6v6sAnIye6Bb8SvuIlQRk7TSCG6G', 'Henry',  'Young',    (SELECT role_id FROM role WHERE role_name = 'Observer'));

-- ── Trap lines (5 required) ───────────────────────────────────
INSERT INTO line (name, type) VALUES
    ('North Line',   'Trap'),
    ('Lake Route',   'Trap'),
    ('East Track',   'Trap'),
    ('West Loop',    'Trap'),
    ('Central Line', 'Trap');

-- ── Assign operators to lines ─────────────────────────────────
INSERT INTO operator_line (operator_id, line_id) VALUES
    ((SELECT user_id FROM "user" WHERE username = 'operator1'),
     (SELECT line_id  FROM line  WHERE name     = 'North Line')),
    ((SELECT user_id FROM "user" WHERE username = 'operator1'),
     (SELECT line_id  FROM line  WHERE name     = 'Lake Route')),
    ((SELECT user_id FROM "user" WHERE username = 'operator2'),
     (SELECT line_id  FROM line  WHERE name     = 'East Track')),
    ((SELECT user_id FROM "user" WHERE username = 'operator2'),
     (SELECT line_id  FROM line  WHERE name     = 'West Loop')),
    ((SELECT user_id FROM "user" WHERE username = 'operator3'),
     (SELECT line_id  FROM line  WHERE name     = 'Central Line'));

-- ── Traps — 5 per line ────────────────────────────────────────

-- North Line
INSERT INTO trap (code, trap_type, line_id, latitude, longitude) VALUES
    ('NL-01', 'DOC 150',        (SELECT line_id FROM line WHERE name = 'North Line'), -43.6450, 172.4720),
    ('NL-02', 'T-Rex Rat Trap', (SELECT line_id FROM line WHERE name = 'North Line'), -43.6452, 172.4730),
    ('NL-03', 'DOC 200',        (SELECT line_id FROM line WHERE name = 'North Line'), -43.6455, 172.4740),
    ('NL-04', 'Trapinator',     (SELECT line_id FROM line WHERE name = 'North Line'), -43.6458, 172.4750),
    ('NL-05', 'Victor',         (SELECT line_id FROM line WHERE name = 'North Line'), -43.6460, 172.4760);

-- Lake Route
INSERT INTO trap (code, trap_type, line_id, latitude, longitude) VALUES
    ('LR-01', 'DOC 150',    (SELECT line_id FROM line WHERE name = 'Lake Route'), -43.6480, 172.4700),
    ('LR-02', 'Trapinator', (SELECT line_id FROM line WHERE name = 'Lake Route'), -43.6485, 172.4710),
    ('LR-03', 'A24',        (SELECT line_id FROM line WHERE name = 'Lake Route'), -43.6490, 172.4720),
    ('LR-04', 'Victor',     (SELECT line_id FROM line WHERE name = 'Lake Route'), -43.6495, 172.4730),
    ('LR-05', 'DOC 250',    (SELECT line_id FROM line WHERE name = 'Lake Route'), -43.6500, 172.4740);

-- East Track
INSERT INTO trap (code, trap_type, line_id, latitude, longitude) VALUES
    ('ET-01', 'DOC 150',        (SELECT line_id FROM line WHERE name = 'East Track'), -43.6430, 172.4800),
    ('ET-02', 'DOC 200',        (SELECT line_id FROM line WHERE name = 'East Track'), -43.6432, 172.4810),
    ('ET-03', 'T-Rex Rat Trap', (SELECT line_id FROM line WHERE name = 'East Track'), -43.6435, 172.4820),
    ('ET-04', 'Trapinator',     (SELECT line_id FROM line WHERE name = 'East Track'), -43.6438, 172.4830),
    ('ET-05', 'Victor',         (SELECT line_id FROM line WHERE name = 'East Track'), -43.6440, 172.4840);

-- West Loop
INSERT INTO trap (code, trap_type, line_id, latitude, longitude) VALUES
    ('WL-01', 'A24',        (SELECT line_id FROM line WHERE name = 'West Loop'), -43.6470, 172.4660),
    ('WL-02', 'DOC 150',    (SELECT line_id FROM line WHERE name = 'West Loop'), -43.6475, 172.4650),
    ('WL-03', 'DOC 200',    (SELECT line_id FROM line WHERE name = 'West Loop'), -43.6480, 172.4640),
    ('WL-04', 'Victor',     (SELECT line_id FROM line WHERE name = 'West Loop'), -43.6485, 172.4630),
    ('WL-05', 'Trapinator', (SELECT line_id FROM line WHERE name = 'West Loop'), -43.6490, 172.4620);

-- Central Line
INSERT INTO trap (code, trap_type, line_id, latitude, longitude) VALUES
    ('CL-01', 'DOC 150',        (SELECT line_id FROM line WHERE name = 'Central Line'), -43.6440, 172.4750),
    ('CL-02', 'T-Rex Rat Trap', (SELECT line_id FROM line WHERE name = 'Central Line'), -43.6442, 172.4760),
    ('CL-03', 'DOC 200',        (SELECT line_id FROM line WHERE name = 'Central Line'), -43.6445, 172.4770),
    ('CL-04', 'A24',            (SELECT line_id FROM line WHERE name = 'Central Line'), -43.6448, 172.4780),
    ('CL-05', 'Victor',         (SELECT line_id FROM line WHERE name = 'Central Line'), -43.6450, 172.4790);

-- ── Catch records — 5 per line ────────────────────────────────

-- North Line
INSERT INTO trap_catch
    (trap_id, date, recorded_by, species_id, sex, maturity,
     status_id, rebaited, bait_type_id, condition_id, strikes)
VALUES
    ((SELECT trap_id FROM trap WHERE code = 'NL-01'), '2026-03-10 08:30',
     (SELECT user_id FROM "user" WHERE username = 'operator1'),
     (SELECT species_id FROM species WHERE name = 'Stoat'), 'Male', 'Adult',
     (SELECT status_id FROM trap_status WHERE status_name = 'Sprung'), 'Yes',
     (SELECT bait_type_id FROM bait_type WHERE name = 'Goodnature Nut Butter'),
     (SELECT condition_id FROM trap_condition WHERE name = 'OK'), 1),

    ((SELECT trap_id FROM trap WHERE code = 'NL-02'), '2026-03-10 08:45',
     (SELECT user_id FROM "user" WHERE username = 'operator1'),
     (SELECT species_id FROM species WHERE name = 'None'), NULL, NULL,
     (SELECT status_id FROM trap_status WHERE status_name = 'Still set, bait OK'), 'No',
     (SELECT bait_type_id FROM bait_type WHERE name = 'None'),
     (SELECT condition_id FROM trap_condition WHERE name = 'OK'), 0),

    ((SELECT trap_id FROM trap WHERE code = 'NL-03'), '2026-03-10 09:00',
     (SELECT user_id FROM "user" WHERE username = 'operator1'),
     (SELECT species_id FROM species WHERE name = 'Ship Rat'), 'Female', 'Adult',
     (SELECT status_id FROM trap_status WHERE status_name = 'Sprung'), 'Yes',
     (SELECT bait_type_id FROM bait_type WHERE name = 'Peanut butter'),
     (SELECT condition_id FROM trap_condition WHERE name = 'OK'), 1),

    ((SELECT trap_id FROM trap WHERE code = 'NL-04'), '2026-03-10 09:15',
     (SELECT user_id FROM "user" WHERE username = 'operator1'),
     (SELECT species_id FROM species WHERE name = 'None'), NULL, NULL,
     (SELECT status_id FROM trap_status WHERE status_name = 'Still set, bait OK'), 'No',
     (SELECT bait_type_id FROM bait_type WHERE name = 'None'),
     (SELECT condition_id FROM trap_condition WHERE name = 'OK'), 0),

    ((SELECT trap_id FROM trap WHERE code = 'NL-05'), '2026-03-10 09:30',
     (SELECT user_id FROM "user" WHERE username = 'operator1'),
     (SELECT species_id FROM species WHERE name = 'Possum'), 'Male', 'Adult',
     (SELECT status_id FROM trap_status WHERE status_name = 'Sprung'), 'Yes',
     (SELECT bait_type_id FROM bait_type WHERE name = 'Egg'),
     (SELECT condition_id FROM trap_condition WHERE name = 'OK'), 1);

-- TODO: Add 5 catch records each for Lake Route, East Track, West Loop, Central Line
--       Follow the same pattern as North Line above.

-- ── Observations ──────────────────────────────────────────────
INSERT INTO observation (operator_id, obs_date, obs_type, location, notes) VALUES
    ((SELECT user_id FROM "user" WHERE username = 'operator1'),
     '2026-03-10 10:00', 'Bird sighting', 'North Line near NL-03',
     'Kereru observed in canopy'),
    ((SELECT user_id FROM "user" WHERE username = 'operator2'),
     '2026-03-11 09:00', 'Predator tracks', 'East Track junction',
     'Possum footprints in mud near ET-02'),
    ((SELECT user_id FROM "user" WHERE username = 'operator3'),
     '2026-03-12 08:30', 'Native species sign', 'Central Line south end',
     'Waxeye nest observed in flax');
