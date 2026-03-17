-- =============================================================
-- populate_database.sql — PF-LU Seed Data
-- COMP639 Group Project 1 — Semester 1, 2026
--
-- Run AFTER create_database.sql (Sun's schema)
--
-- All passwords are bcrypt hashes of: Password1!
-- =============================================================

-- ── Species (lookup table — VARCHAR PRIMARY KEY) ──────────────
-- Full list from the project brief
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

-- ── Trap statuses (lookup table — VARCHAR PRIMARY KEY) ────────
-- Full list from the project brief
-- NOTE: "Still set, bait OK/bad/missing" are each ONE status entry
INSERT INTO trap_statuses (name) VALUES
    ('Initial set'),
    ('Removed for Repair'),
    ('Sprung'),
    ('Still set, bait OK'),
    ('Still set, bait bad'),
    ('Still set, bait missing'),
    ('Trap Replaced'),
    ('Trap gone'),
    ('Trap interfered with');

-- ── Bait types (lookup table — VARCHAR PRIMARY KEY) ───────────
-- Full list from the project brief
INSERT INTO bait_types (name) VALUES
    ('None'),
    ('Carrot'),
    ('Cereal'),
    ('Cheese'),
    ('Chocolate'),
    ('Dehydrated Rabbit'),
    ('Dried fruit'),
    ('Ferret bedding'),
    ('Fish'),
    ('Fresh Possum'),
    ('Fresh Rabbit'),
    ('Fresh fruit'),
    ('Fresh meat'),
    ('Golf ball'),
    ('Good Nature Chocolate'),
    ('Good Nature Meat Lovers'),
    ('Goodnature Blood'),
    ('Goodnature Cinnamon pre feed'),
    ('Goodnature Nut Butter'),
    ('Lure'),
    ('Lure-it Salmon Spray'),
    ('Mayo'),
    ('Mustelid and Cat Lure'),
    ('NARA Blocks'),
    ('NZAT Lure - Original'),
    ('Nut'),
    ('Nutella'),
    ('Other (please specify)'),
    ('Peanut butter'),
    ('PoaUku'),
    ('Possum Dough'),
    ('Rabbit oil'),
    ('Rat and Possum Lure'),
    ('Rat oil'),
    ('Salmon'),
    ('Salmon oil'),
    ('Salted Possum'),
    ('Salted Rabbit'),
    ('Salted meat'),
    ('Smooth'),
    ('Terracotta Lures'),
    ('Tinned Sardines'),
    ('Whole egg');

-- ── Admin accounts (2 required) ───────────────────────────────
-- role uses ENUM role_type: 'Observer' | 'Operator' | 'Admin'
-- account_status uses ENUM account_status_type: 'active' | 'inactive'
INSERT INTO users
    (username, email, password_hash, first_name, last_name,
     contact_information, emergency_contact_information,
     role, account_status)
VALUES
    ('admin1', 'admin1@pflu.ac.nz',
     '$2b$12$BVmgoCw0W76RGSnOGTd1KeQ/VYEPCuJ0SmG/Krx6gi74.bAtSMBSu',
     'Admin', 'One',
     '021 000 0001', 'Emergency One — 021 000 0099',
     'Admin', 'active'),

    ('admin2', 'admin2@pflu.ac.nz',
     '$2b$12$BVmgoCw0W76RGSnOGTd1KeQ/VYEPCuJ0SmG/Krx6gi74.bAtSMBSu',
     'Admin', 'Two',
     '021 000 0002', 'Emergency Two — 021 000 0098',
     'Admin', 'active');

-- ── Operator accounts (10 required) ───────────────────────────
INSERT INTO users
    (username, email, password_hash, first_name, last_name,
     contact_information, emergency_contact_information,
     role, account_status)
VALUES
    ('operator1', 'op1@pflu.ac.nz',
     '$2b$12$BVmgoCw0W76RGSnOGTd1KeQ/VYEPCuJ0SmG/Krx6gi74.bAtSMBSu',
     'James', 'Ruane', '021 100 0001', 'James Emergency — 021 100 0091',
     'Operator', 'active'),

    ('operator2', 'op2@pflu.ac.nz',
     '$2b$12$BVmgoCw0W76RGSnOGTd1KeQ/VYEPCuJ0SmG/Krx6gi74.bAtSMBSu',
     'Aroha', 'Kahu', '021 100 0002', 'Aroha Emergency — 021 100 0092',
     'Operator', 'active'),

    ('operator3', 'op3@pflu.ac.nz',
     '$2b$12$BVmgoCw0W76RGSnOGTd1KeQ/VYEPCuJ0SmG/Krx6gi74.bAtSMBSu',
     'Tom', 'Walker', '021 100 0003', 'Tom Emergency — 021 100 0093',
     'Operator', 'active'),

    ('operator4', 'op4@pflu.ac.nz',
     '$2b$12$BVmgoCw0W76RGSnOGTd1KeQ/VYEPCuJ0SmG/Krx6gi74.bAtSMBSu',
     'Nina', 'Brown', '021 100 0004', 'Nina Emergency — 021 100 0094',
     'Operator', 'active'),

    ('operator5', 'op5@pflu.ac.nz',
     '$2b$12$BVmgoCw0W76RGSnOGTd1KeQ/VYEPCuJ0SmG/Krx6gi74.bAtSMBSu',
     'Liam', 'Chen', '021 100 0005', 'Liam Emergency — 021 100 0095',
     'Operator', 'active'),

    ('operator6', 'op6@pflu.ac.nz',
     '$2b$12$BVmgoCw0W76RGSnOGTd1KeQ/VYEPCuJ0SmG/Krx6gi74.bAtSMBSu',
     'Mei', 'Zhang', '021 100 0006', 'Mei Emergency — 021 100 0096',
     'Operator', 'active'),

    ('operator7', 'op7@pflu.ac.nz',
     '$2b$12$BVmgoCw0W76RGSnOGTd1KeQ/VYEPCuJ0SmG/Krx6gi74.bAtSMBSu',
     'Sam', 'Wilson', '021 100 0007', 'Sam Emergency — 021 100 0087',
     'Operator', 'active'),

    ('operator8', 'op8@pflu.ac.nz',
     '$2b$12$BVmgoCw0W76RGSnOGTd1KeQ/VYEPCuJ0SmG/Krx6gi74.bAtSMBSu',
     'Priya', 'Patel', '021 100 0008', 'Priya Emergency — 021 100 0088',
     'Operator', 'active'),

    ('operator9', 'op9@pflu.ac.nz',
     '$2b$12$BVmgoCw0W76RGSnOGTd1KeQ/VYEPCuJ0SmG/Krx6gi74.bAtSMBSu',
     'Carlos', 'Rivera', '021 100 0009', 'Carlos Emergency — 021 100 0089',
     'Operator', 'active'),

    ('operator10', 'op10@pflu.ac.nz',
     '$2b$12$BVmgoCw0W76RGSnOGTd1KeQ/VYEPCuJ0SmG/Krx6gi74.bAtSMBSu',
     'Fiona', 'McDonald', '021 100 0010', 'Fiona Emergency — 021 100 0080',
     'Operator', 'active');

-- ── Observer accounts (10 required) ───────────────────────────
INSERT INTO users
    (username, email, password_hash, first_name, last_name,
     contact_information, emergency_contact_information,
     role, account_status)
VALUES
    ('observer1', 'obs1@pflu.ac.nz',
     '$2b$12$BVmgoCw0W76RGSnOGTd1KeQ/VYEPCuJ0SmG/Krx6gi74.bAtSMBSu',
     'Sarah', 'Thompson', '021 200 0001', 'Sarah Emergency — 021 200 0091',
     'Observer', 'active'),

    ('observer2', 'obs2@pflu.ac.nz',
     '$2b$12$BVmgoCw0W76RGSnOGTd1KeQ/VYEPCuJ0SmG/Krx6gi74.bAtSMBSu',
     'Mike', 'Jones', '021 200 0002', 'Mike Emergency — 021 200 0092',
     'Observer', 'active'),

    ('observer3', 'obs3@pflu.ac.nz',
     '$2b$12$BVmgoCw0W76RGSnOGTd1KeQ/VYEPCuJ0SmG/Krx6gi74.bAtSMBSu',
     'Ella', 'Davis', '021 200 0003', 'Ella Emergency — 021 200 0093',
     'Observer', 'active'),

    ('observer4', 'obs4@pflu.ac.nz',
     '$2b$12$BVmgoCw0W76RGSnOGTd1KeQ/VYEPCuJ0SmG/Krx6gi74.bAtSMBSu',
     'Noah', 'Martin', '021 200 0004', 'Noah Emergency — 021 200 0094',
     'Observer', 'active'),

    ('observer5', 'obs5@pflu.ac.nz',
     '$2b$12$BVmgoCw0W76RGSnOGTd1KeQ/VYEPCuJ0SmG/Krx6gi74.bAtSMBSu',
     'Isla', 'White', '021 200 0005', 'Isla Emergency — 021 200 0095',
     'Observer', 'active'),

    ('observer6', 'obs6@pflu.ac.nz',
     '$2b$12$BVmgoCw0W76RGSnOGTd1KeQ/VYEPCuJ0SmG/Krx6gi74.bAtSMBSu',
     'Jack', 'Harris', '021 200 0006', 'Jack Emergency — 021 200 0096',
     'Observer', 'active'),

    ('observer7', 'obs7@pflu.ac.nz',
     '$2b$12$BVmgoCw0W76RGSnOGTd1KeQ/VYEPCuJ0SmG/Krx6gi74.bAtSMBSu',
     'Chloe', 'Clark', '021 200 0007', 'Chloe Emergency — 021 200 0097',
     'Observer', 'active'),

    ('observer8', 'obs8@pflu.ac.nz',
     '$2b$12$BVmgoCw0W76RGSnOGTd1KeQ/VYEPCuJ0SmG/Krx6gi74.bAtSMBSu',
     'Oliver', 'Lewis', '021 200 0008', 'Oliver Emergency — 021 200 0098',
     'Observer', 'active'),

    ('observer9', 'obs9@pflu.ac.nz',
     '$2b$12$BVmgoCw0W76RGSnOGTd1KeQ/VYEPCuJ0SmG/Krx6gi74.bAtSMBSu',
     'Grace', 'Hall', '021 200 0009', 'Grace Emergency — 021 200 0099',
     'Observer', 'active'),

    ('observer10', 'obs10@pflu.ac.nz',
     '$2b$12$BVmgoCw0W76RGSnOGTd1KeQ/VYEPCuJ0SmG/Krx6gi74.bAtSMBSu',
     'Henry', 'Young', '021 200 0010', 'Henry Emergency — 021 200 0080',
     'Observer', 'active');

-- ── Trap lines (5 required) ───────────────────────────────────
INSERT INTO lines (name, type, is_retired) VALUES
    ('North Line',   'Trap', TRUE),
    ('Lake Route',   'Trap', TRUE),
    ('East Track',   'Trap', FALSE),
    ('West Loop',    'Trap', FALSE),
    ('Central Line', 'Trap', FALSE);

-- ── Assign operators to lines ─────────────────────────────────
INSERT INTO operator_lines (operator_id, line_id) VALUES
    ((SELECT user_id FROM users WHERE username = 'operator1'),
     (SELECT line_id  FROM lines WHERE name    = 'North Line')),
    ((SELECT user_id FROM users WHERE username = 'operator1'),
     (SELECT line_id  FROM lines WHERE name    = 'Lake Route')),
    ((SELECT user_id FROM users WHERE username = 'operator2'),
     (SELECT line_id  FROM lines WHERE name    = 'East Track')),
    ((SELECT user_id FROM users WHERE username = 'operator2'),
     (SELECT line_id  FROM lines WHERE name    = 'West Loop')),
    ((SELECT user_id FROM users WHERE username = 'operator3'),
     (SELECT line_id  FROM lines WHERE name    = 'Central Line')),
    ((SELECT user_id FROM users WHERE username = 'operator4'),
     (SELECT line_id  FROM lines WHERE name    = 'North Line')),
    ((SELECT user_id FROM users WHERE username = 'operator5'),
     (SELECT line_id  FROM lines WHERE name    = 'Lake Route'));

-- ── Traps — 5 per line (trap_type uses ENUM trap_type_enum) ───

-- North Line
INSERT INTO traps (code, trap_type, line_id, latitude, longitude, is_retired) VALUES
    ('NL-01', 'DOC 150',        (SELECT line_id FROM lines WHERE name = 'North Line'), -43.645000, 172.472000, TRUE),
    ('NL-02', 'T-Rex Rat Trap', (SELECT line_id FROM lines WHERE name = 'North Line'), -43.645200, 172.473000, FALSE),
    ('NL-03', 'DOC 200',        (SELECT line_id FROM lines WHERE name = 'North Line'), -43.645500, 172.474000, FALSE),
    ('NL-04', 'Trapinator',     (SELECT line_id FROM lines WHERE name = 'North Line'), -43.645800, 172.475000, TRUE),
    ('NL-05', 'Victor',         (SELECT line_id FROM lines WHERE name = 'North Line'), -43.646000, 172.476000, FALSE);

-- Lake Route
INSERT INTO traps (code, trap_type, line_id, latitude, longitude, is_retired) VALUES
    ('LR-01', 'DOC 150',        (SELECT line_id FROM lines WHERE name = 'Lake Route'), -43.648000, 172.470000, FALSE),
    ('LR-02', 'Trapinator',     (SELECT line_id FROM lines WHERE name = 'Lake Route'), -43.648500, 172.471000, FALSE),
    ('LR-03', 'A24',            (SELECT line_id FROM lines WHERE name = 'Lake Route'), -43.649000, 172.472000, FALSE),
    ('LR-04', 'Victor',         (SELECT line_id FROM lines WHERE name = 'Lake Route'), -43.649500, 172.473000, TRUE),
    ('LR-05', 'DOC 250',        (SELECT line_id FROM lines WHERE name = 'Lake Route'), -43.650000, 172.474000, TRUE);

-- East Track
INSERT INTO traps (code, trap_type, line_id, latitude, longitude, is_retired) VALUES
    ('ET-01', 'DOC 150',        (SELECT line_id FROM lines WHERE name = 'East Track'), -43.643000, 172.480000, FALSE),
    ('ET-02', 'DOC 200',        (SELECT line_id FROM lines WHERE name = 'East Track'), -43.643200, 172.481000, FALSE),
    ('ET-03', 'T-Rex Rat Trap', (SELECT line_id FROM lines WHERE name = 'East Track'), -43.643500, 172.482000, FALSE),
    ('ET-04', 'Trapinator',     (SELECT line_id FROM lines WHERE name = 'East Track'), -43.643800, 172.483000, FALSE),
    ('ET-05', 'Victor',         (SELECT line_id FROM lines WHERE name = 'East Track'), -43.644000, 172.484000, TRUE);

-- West Loop
INSERT INTO traps (code, trap_type, line_id, latitude, longitude, is_retired) VALUES
    ('WL-01', 'A24',            (SELECT line_id FROM lines WHERE name = 'West Loop'), -43.647000, 172.466000, FALSE),
    ('WL-02', 'DOC 150',        (SELECT line_id FROM lines WHERE name = 'West Loop'), -43.647500, 172.465000, TRUE),
    ('WL-03', 'DOC 200',        (SELECT line_id FROM lines WHERE name = 'West Loop'), -43.648000, 172.464000, FALSE),
    ('WL-04', 'Victor',         (SELECT line_id FROM lines WHERE name = 'West Loop'), -43.648500, 172.463000, FALSE),
    ('WL-05', 'Trapinator',     (SELECT line_id FROM lines WHERE name = 'West Loop'), -43.649000, 172.462000, TRUE);

-- Central Line
INSERT INTO traps (code, trap_type, line_id, latitude, longitude, is_retired) VALUES
    ('CL-01', 'DOC 150',        (SELECT line_id FROM lines WHERE name = 'Central Line'), -43.644000, 172.475000, FALSE),
    ('CL-02', 'T-Rex Rat Trap', (SELECT line_id FROM lines WHERE name = 'Central Line'), -43.644200, 172.476000, FALSE),
    ('CL-03', 'DOC 200',        (SELECT line_id FROM lines WHERE name = 'Central Line'), -43.644500, 172.477000, FALSE),
    ('CL-04', 'A24',            (SELECT line_id FROM lines WHERE name = 'Central Line'), -43.644800, 172.478000, FALSE),
    ('CL-05', 'Victor',         (SELECT line_id FROM lines WHERE name = 'Central Line'), -43.645000, 172.479000, TRUE);

-- ── Catch records — 5 per line ────────────────────────────────
-- Sun's column names: recorded_by_id, species_caught, status, bait_type
-- sex/maturity/rebaited are ENUMs — use exact ENUM values
-- trap_condition is ENUM trap_condition_type
-- CHECK: strikes = 0 requires species_caught = 'None'
-- CHECK: rebaited = 'No' requires bait_type = 'None'

-- North Line catches
INSERT INTO trap_catches
    (trap_id, date, recorded_by_id, species_caught, sex, maturity,
     status, rebaited, bait_type, trap_condition, strikes)
VALUES
    ((SELECT trap_id FROM traps WHERE code = 'NL-01'), '2026-03-10 08:30',
     (SELECT user_id FROM users WHERE username = 'operator1'),
     'Stoat', 'Male', 'Adult',
     'Sprung', 'Yes', 'Goodnature Nut Butter', 'OK', 1),

    ((SELECT trap_id FROM traps WHERE code = 'NL-02'), '2026-03-10 08:45',
     (SELECT user_id FROM users WHERE username = 'operator1'),
     'None', NULL, NULL,
     'Still set, bait OK', 'No', 'None', 'OK', 0),

    ((SELECT trap_id FROM traps WHERE code = 'NL-03'), '2026-03-10 09:00',
     (SELECT user_id FROM users WHERE username = 'operator1'),
     'Ship Rat', 'Female', 'Adult',
     'Sprung', 'Yes', 'Peanut butter', 'OK', 1),

    ((SELECT trap_id FROM traps WHERE code = 'NL-04'), '2026-03-10 09:15',
     (SELECT user_id FROM users WHERE username = 'operator1'),
     'None', NULL, NULL,
     'Still set, bait bad', 'Yes', 'Peanut butter', 'Needs maintenance', 0),

    ((SELECT trap_id FROM traps WHERE code = 'NL-05'), '2026-03-10 09:30',
     (SELECT user_id FROM users WHERE username = 'operator1'),
     'Possum', 'Male', 'Adult',
     'Sprung', 'Yes', 'Whole egg', 'OK', 1);

-- Lake Route catches
INSERT INTO trap_catches
    (trap_id, date, recorded_by_id, species_caught, sex, maturity,
     status, rebaited, bait_type, trap_condition, strikes)
VALUES
    ((SELECT trap_id FROM traps WHERE code = 'LR-01'), '2026-03-11 08:30',
     (SELECT user_id FROM users WHERE username = 'operator1'),
     'None', NULL, NULL,
     'Still set, bait OK', 'No', 'None', 'OK', 0),

    ((SELECT trap_id FROM traps WHERE code = 'LR-02'), '2026-03-11 08:50',
     (SELECT user_id FROM users WHERE username = 'operator1'),
     'Possum', 'Female', 'Adult',
     'Sprung', 'Yes', 'Goodnature Nut Butter', 'OK', 1),

    ((SELECT trap_id FROM traps WHERE code = 'LR-03'), '2026-03-11 09:10',
     (SELECT user_id FROM users WHERE username = 'operator1'),
     'None', NULL, NULL,
     'Still set, bait missing', 'Yes', 'Peanut butter', 'OK', 0),

    ((SELECT trap_id FROM traps WHERE code = 'LR-04'), '2026-03-11 09:25',
     (SELECT user_id FROM users WHERE username = 'operator1'),
     'Kiore Rat', 'Male', 'Juvenile',
     'Sprung', 'Yes', 'Peanut butter', 'OK', 2),

    ((SELECT trap_id FROM traps WHERE code = 'LR-05'), '2026-03-11 09:40',
     (SELECT user_id FROM users WHERE username = 'operator1'),
     'None', NULL, NULL,
     'Still set, bait OK', 'No', 'None', 'Needs maintenance', 0);

-- East Track catches
INSERT INTO trap_catches
    (trap_id, date, recorded_by_id, species_caught, sex, maturity,
     status, rebaited, bait_type, trap_condition, strikes)
VALUES
    ((SELECT trap_id FROM traps WHERE code = 'ET-01'), '2026-03-12 08:00',
     (SELECT user_id FROM users WHERE username = 'operator2'),
     'Ferret', 'Male', 'Adult',
     'Sprung', 'Yes', 'Dehydrated Rabbit', 'OK', 1),

    ((SELECT trap_id FROM traps WHERE code = 'ET-02'), '2026-03-12 08:20',
     (SELECT user_id FROM users WHERE username = 'operator2'),
     'None', NULL, NULL,
     'Still set, bait OK', 'No', 'None', 'OK', 0),

    ((SELECT trap_id FROM traps WHERE code = 'ET-03'), '2026-03-12 08:40',
     (SELECT user_id FROM users WHERE username = 'operator2'),
     'Norway Rat', 'Female', 'Adult',
     'Sprung', 'Yes', 'Peanut butter', 'OK', 1),

    ((SELECT trap_id FROM traps WHERE code = 'ET-04'), '2026-03-12 09:00',
     (SELECT user_id FROM users WHERE username = 'operator2'),
     'None', NULL, NULL,
     'Still set, bait bad', 'Yes', 'Goodnature Nut Butter', 'Repaired', 0),

    ((SELECT trap_id FROM traps WHERE code = 'ET-05'), '2026-03-12 09:20',
     (SELECT user_id FROM users WHERE username = 'operator2'),
     'Stoat', 'Male', 'Adult',
     'Sprung', 'Yes', 'Goodnature Blood', 'OK', 1);

-- West Loop catches
INSERT INTO trap_catches
    (trap_id, date, recorded_by_id, species_caught, sex, maturity,
     status, rebaited, bait_type, trap_condition, strikes)
VALUES
    ((SELECT trap_id FROM traps WHERE code = 'WL-01'), '2026-03-13 08:00',
     (SELECT user_id FROM users WHERE username = 'operator2'),
     'None', NULL, NULL,
     'Initial set', 'Yes', 'Peanut butter', 'OK', 0),

    ((SELECT trap_id FROM traps WHERE code = 'WL-02'), '2026-03-13 08:20',
     (SELECT user_id FROM users WHERE username = 'operator2'),
     'Ship Rat', 'Male', 'Adult',
     'Sprung', 'Yes', 'Peanut butter', 'OK', 1),

    ((SELECT trap_id FROM traps WHERE code = 'WL-03'), '2026-03-13 08:40',
     (SELECT user_id FROM users WHERE username = 'operator2'),
     'None', NULL, NULL,
     'Still set, bait OK', 'No', 'None', 'OK', 0),

    ((SELECT trap_id FROM traps WHERE code = 'WL-04'), '2026-03-13 09:00',
     (SELECT user_id FROM users WHERE username = 'operator2'),
     'Weasel', 'Female', 'Adult',
     'Sprung', 'Yes', 'Salmon', 'OK', 1),

    ((SELECT trap_id FROM traps WHERE code = 'WL-05'), '2026-03-13 09:20',
     (SELECT user_id FROM users WHERE username = 'operator2'),
     'None', NULL, NULL,
     'Still set, bait missing', 'Yes', 'Peanut butter', 'Needs maintenance', 0);

-- Central Line catches
INSERT INTO trap_catches
    (trap_id, date, recorded_by_id, species_caught, sex, maturity,
     status, rebaited, bait_type, trap_condition, strikes)
VALUES
    ((SELECT trap_id FROM traps WHERE code = 'CL-01'), '2026-03-14 08:00',
     (SELECT user_id FROM users WHERE username = 'operator3'),
     'Possum', 'Female', 'Adult',
     'Sprung', 'Yes', 'Whole egg', 'OK', 1),

    ((SELECT trap_id FROM traps WHERE code = 'CL-02'), '2026-03-14 08:20',
     (SELECT user_id FROM users WHERE username = 'operator3'),
     'None', NULL, NULL,
     'Still set, bait OK', 'No', 'None', 'OK', 0),

    ((SELECT trap_id FROM traps WHERE code = 'CL-03'), '2026-03-14 08:40',
     (SELECT user_id FROM users WHERE username = 'operator3'),
     'Kiore Rat', 'Male', 'Juvenile',
     'Sprung', 'Yes', 'Peanut butter', 'OK', 1),

    ((SELECT trap_id FROM traps WHERE code = 'CL-04'), '2026-03-14 09:00',
     (SELECT user_id FROM users WHERE username = 'operator3'),
     'None', NULL, NULL,
     'Still set, bait bad', 'Yes', 'Goodnature Nut Butter', 'OK', 0),

    ((SELECT trap_id FROM traps WHERE code = 'CL-05'), '2026-03-14 09:20',
     (SELECT user_id FROM users WHERE username = 'operator3'),
     'Stoat', 'Female', 'Adult',
     'Sprung', 'Yes', 'Dehydrated Rabbit', 'Repaired', 1);

-- ── Incidental observations ───────────────────────────────────
-- Sun's schema includes: latitude, longitude, line_id, trap_id (all optional)
INSERT INTO incidental_observations
    (date, operator_id, observation_type, notes, latitude, longitude, line_id, trap_id)
VALUES
    ('2026-03-10 10:00',
     (SELECT user_id FROM users WHERE username = 'operator1'),
     'Bird sighting',
     'Kereru observed in canopy above North Line near NL-02',
     -43.645300, 172.473500,
     (SELECT line_id FROM lines WHERE name = 'North Line'),
     (SELECT trap_id FROM traps WHERE code  = 'NL-02')),

    ('2026-03-11 09:45',
     (SELECT user_id FROM users WHERE username = 'operator1'),
     'Predator tracks',
     'Possum footprints in mud near Lake Route trap LR-03',
     -43.648800, 172.471500,
     (SELECT line_id FROM lines WHERE name = 'Lake Route'),
     (SELECT trap_id FROM traps WHERE code  = 'LR-03')),

    ('2026-03-12 09:30',
     (SELECT user_id FROM users WHERE username = 'operator2'),
     'Native species sign',
     'Waxeye nest observed in flax at East Track south end',
     -43.644100, 172.484200,
     (SELECT line_id FROM lines WHERE name = 'East Track'),
     NULL),

    ('2026-03-13 09:35',
     (SELECT user_id FROM users WHERE username = 'operator2'),
     'Predator sighting',
     'Stoat observed crossing track near West Loop trap WL-04',
     -43.648700, 172.463500,
     (SELECT line_id FROM lines WHERE name = 'West Loop'),
     (SELECT trap_id FROM traps WHERE code  = 'WL-04')),

    ('2026-03-14 09:30',
     (SELECT user_id FROM users WHERE username = 'operator3'),
     'Bird sighting',
     'Fantail pair seen foraging near Central Line traps',
     -43.644600, 172.477200,
     (SELECT line_id FROM lines WHERE name = 'Central Line'),
     NULL);
