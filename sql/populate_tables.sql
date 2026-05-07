-- populate_tables.sql
-- Conservation Groups Platform — COMP639 Group Project 2, Team Huhu
-- Lincoln University, Semester 1, 2026
-- All passwords: Password1!
-- Run create_tables.sql first

BEGIN;

-- ══════════════════════════════════════════════════════
-- LOOKUP TABLES
-- ══════════════════════════════════════════════════════

INSERT INTO species (name) VALUES
    ('None'), ('Stoat'), ('Rat'), ('Mouse'), ('Possum'),
    ('Weasel'), ('Hedgehog'), ('Rabbit'), ('Other')
ON CONFLICT DO NOTHING;

INSERT INTO trap_statuses (name) VALUES
    ('Sprung'),
    ('Still set, bait OK'),
    ('Still set, bait bad'),
    ('Still set, bait missing'),
    ('Initial set'),
    ('Removed')
ON CONFLICT DO NOTHING;

INSERT INTO bait_types (name) VALUES
    ('None'), ('Egg'), ('Peanut butter'), ('Chocolate'),
    ('Rabbit'), ('Chicken'), ('Lure'), ('Other')
ON CONFLICT DO NOTHING;

-- ══════════════════════════════════════════════════════
-- GROUPS
-- ══════════════════════════════════════════════════════

INSERT INTO groups (name, description, is_public, color_theme) VALUES
    ('Predator Free Lincoln University',
     'Volunteer predator-control initiative across Lincoln University campus.',
     TRUE,  '#198754'),
    ('Christchurch City Trappers',
     'Community predator trapping group operating across central Christchurch.',
     TRUE,  '#0d6efd'),
    ('Banks Peninsula Restoration',
     'Private restoration group operating on private land on Banks Peninsula.',
     FALSE, '#dc3545')
ON CONFLICT (name) DO NOTHING;

-- ══════════════════════════════════════════════════════
-- USERS
-- All passwords: Password1!
-- ══════════════════════════════════════════════════════

INSERT INTO users (username, email, password_hash, first_name, last_name, is_super_admin, account_status, phone, address, emergency_contact_name, emergency_contact_phone, date_joined, last_login) VALUES

-- Super Admins (site-wide)
('smitchell', 's.mitchell@lincoln.ac.nz', '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Sarah', 'Mitchell', TRUE,  'active',   '021 345 6789', '12 Lincoln Road, Lincoln 7608',        'John Mitchell', '021 987 6543', '2024-01-15 09:00:00', '2026-04-17 08:30:00'),
('jparata',   'j.parata@lincoln.ac.nz',   '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'James', 'Parata',   TRUE,  'active',   '021 456 7890', '45 Springs Road, Lincoln 7608',        'Mary Parata',   '021 876 5432', '2024-01-15 09:00:00', '2026-04-16 14:22:00'),

-- Group Coordinators
('bkim',      'b.kim@lincoln.ac.nz',       '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Bo',    'Kim',      FALSE, 'active',   '027 567 8901', '78 Boundary Road, Lincoln 7608',       'Sue Kim',       '027 765 4321', '2024-02-01 09:00:00', '2026-04-15 11:00:00'),
('cwhite',    'c.white@chch.example.nz',   '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Cara',  'White',    FALSE, 'active',   '027 678 9012', '23 Riccarton Road, Christchurch 8011', 'Dan White',     '027 654 3210', '2024-02-01 09:00:00', '2026-04-10 09:45:00'),
('dlee',      'd.lee@bp.example.nz',       '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Dana',  'Lee',      FALSE, 'active',   '021 789 0123', '5 Akaroa Road, Banks Peninsula',       'Eli Lee',       '021 543 2109', '2024-02-10 09:00:00', '2026-04-14 10:00:00'),

-- Operators — Predator Free Lincoln University
('enyberg',   'e.nyberg@lincoln.ac.nz',    '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Erik',  'Nyberg',   FALSE, 'active',   '021 111 2233', '5 Selwyn Road, Lincoln 7608',          'Finn Nyberg',   '021 543 2109', '2024-03-01 09:00:00', '2026-04-17 07:55:00'),
('fgrant',    'f.grant@lincoln.ac.nz',     '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Fiona', 'Grant',    FALSE, 'active',   '021 222 3344', '89 Lincoln Road, Lincoln 7608',        'Greg Grant',    '021 432 1098', '2024-03-01 09:00:00', '2026-04-14 16:30:00'),
('gwatson',   'g.watson@lincoln.ac.nz',    '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Glen',  'Watson',   FALSE, 'active',   '021 333 4455', '34 Springs Road, Lincoln 7608',        'Helen Watson',  '021 321 0987', '2024-03-15 09:00:00', '2026-04-12 08:10:00'),

-- Operator — Christchurch City Trappers
('hpatel',    'h.patel@chch.example.nz',   '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Hira',  'Patel',    FALSE, 'active',   '027 444 5566', '56 Ilam Road, Christchurch 8041',      'Ian Patel',     '027 210 9876', '2024-03-15 09:00:00', '2026-04-11 12:45:00'),

-- Observers — Predator Free Lincoln University
('iford',     'i.ford@lincoln.ac.nz',      '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Isla',  'Ford',     FALSE, 'active',   '021 555 6677', '12 Gerald Street, Lincoln 7608',       'Jack Ford',     '027 109 8765', '2024-04-01 09:00:00', '2026-04-09 09:00:00'),
('jmoss',     'j.moss@lincoln.ac.nz',      '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Jake',  'Moss',     FALSE, 'active',   '027 666 7788', '67 Selwyn Road, Lincoln 7608',         'Kate Moss',     '027 098 7654', '2024-04-01 09:00:00', '2026-04-08 14:20:00'),
('ktaylor',   'k.taylor@lincoln.ac.nz',    '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Kai',   'Taylor',   FALSE, 'inactive', '021 777 8899', '90 Lincoln Road, Lincoln 7608',        'Lena Taylor',   '021 987 6543', '2024-05-01 09:00:00', '2025-11-20 09:00:00'),

-- No-membership users for join request testing
('trequest1', 'tom.request@example.com',   '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Tom',   'Request',  FALSE, 'active',   NULL, NULL, NULL, NULL, NOW() - INTERVAL '3 days', NULL),
('trequest2', 'sara.request@example.com',  '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Sara',  'Request',  FALSE, 'active',   NULL, NULL, NULL, NULL, NOW() - INTERVAL '1 day',  NULL)

ON CONFLICT (username) DO NOTHING;

-- ══════════════════════════════════════════════════════
-- GROUP MEMBERSHIPS
-- ══════════════════════════════════════════════════════

-- Predator Free Lincoln University
INSERT INTO group_memberships (user_id, group_id, role)
SELECT u.user_id,
       (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'),
       m.role::group_role_type
FROM (VALUES
    ('bkim',    'Group Coordinator'),
    ('enyberg', 'Operator'),
    ('fgrant',  'Operator'),
    ('gwatson', 'Operator'),
    ('hpatel',  'Observer'),   -- Operator in CCT, Observer here
    ('iford',   'Observer'),
    ('jmoss',   'Observer'),
    ('ktaylor', 'Observer')
) AS m(username, role)
JOIN users u ON u.username = m.username
ON CONFLICT (user_id, group_id) DO NOTHING;

-- Christchurch City Trappers
INSERT INTO group_memberships (user_id, group_id, role)
SELECT u.user_id,
       (SELECT group_id FROM groups WHERE name = 'Christchurch City Trappers'),
       m.role::group_role_type
FROM (VALUES
    ('jparata', 'Group Coordinator'), -- Super Admin who also holds a group role
    ('cwhite',  'Group Coordinator'),
    ('hpatel',  'Operator'),
    ('iford',   'Operator'),          -- Observer in PFLU, Operator here
    ('jmoss',   'Observer')
) AS m(username, role)
JOIN users u ON u.username = m.username
ON CONFLICT (user_id, group_id) DO NOTHING;

-- Banks Peninsula Restoration
INSERT INTO group_memberships (user_id, group_id, role)
SELECT u.user_id,
       (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'),
       m.role::group_role_type
FROM (VALUES
    ('dlee',    'Group Coordinator'),
    ('enyberg', 'Group Coordinator'), -- Operator in PFLU, Coordinator here
    ('bkim',    'Operator'),          -- Coordinator in PFLU, Operator here
    ('fgrant',  'Observer'),          -- Operator in PFLU, Observer here
    ('gwatson', 'Observer')           -- Operator in PFLU, Observer here
) AS m(username, role)
JOIN users u ON u.username = m.username
ON CONFLICT (user_id, group_id) DO NOTHING;

-- ══════════════════════════════════════════════════════
-- LINES
-- ══════════════════════════════════════════════════════

INSERT INTO lines (name, type, group_id, is_retired, retired_at, retired_by) VALUES

-- Predator Free Lincoln University — trap lines
('North Campus Trap Line',  'Trap',         (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),
('South Campus Trap Line',  'Trap',         (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),
('Lake Edge Trap Line',     'Trap',         (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),
('Research Farm Trap Line', 'Trap',         (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),
('Old Boundary Track',      'Trap',         (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), true,  '2025-06-01 10:00:00', (SELECT user_id FROM users WHERE username = 'smitchell')),

-- Predator Free Lincoln University — bait station lines
('North Bait Station Line', 'Bait Station', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),
('South Bait Station Line', 'Bait Station', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),

-- Christchurch City Trappers
('Central City Trap Line',  'Trap',         (SELECT group_id FROM groups WHERE name = 'Christchurch City Trappers'),      false, NULL, NULL),
('Hagley Park Bait Line',   'Bait Station', (SELECT group_id FROM groups WHERE name = 'Christchurch City Trappers'),      false, NULL, NULL),

-- Banks Peninsula Restoration
('Peninsula Ridge Line',    'Trap',         (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'),     false, NULL, NULL)

ON CONFLICT (name) DO NOTHING;

-- ══════════════════════════════════════════════════════
-- OPERATOR–LINE ASSIGNMENTS
-- ══════════════════════════════════════════════════════

INSERT INTO operator_lines (operator_id, line_id) VALUES
((SELECT user_id FROM users WHERE username = 'enyberg'), (SELECT line_id FROM lines WHERE name = 'North Campus Trap Line')),
((SELECT user_id FROM users WHERE username = 'enyberg'), (SELECT line_id FROM lines WHERE name = 'North Bait Station Line')),
((SELECT user_id FROM users WHERE username = 'fgrant'),  (SELECT line_id FROM lines WHERE name = 'South Campus Trap Line')),
((SELECT user_id FROM users WHERE username = 'fgrant'),  (SELECT line_id FROM lines WHERE name = 'South Bait Station Line')),
((SELECT user_id FROM users WHERE username = 'gwatson'), (SELECT line_id FROM lines WHERE name = 'Lake Edge Trap Line')),
((SELECT user_id FROM users WHERE username = 'gwatson'), (SELECT line_id FROM lines WHERE name = 'Research Farm Trap Line')),
((SELECT user_id FROM users WHERE username = 'hpatel'),  (SELECT line_id FROM lines WHERE name = 'Central City Trap Line')),
((SELECT user_id FROM users WHERE username = 'hpatel'),  (SELECT line_id FROM lines WHERE name = 'Hagley Park Bait Line')),
((SELECT user_id FROM users WHERE username = 'dlee'),    (SELECT line_id FROM lines WHERE name = 'Peninsula Ridge Line'))
ON CONFLICT DO NOTHING;

-- ══════════════════════════════════════════════════════
-- TRAPS
-- Coordinates within each group's area
-- ══════════════════════════════════════════════════════

INSERT INTO traps (code, trap_type, line_id, latitude, longitude, is_retired) VALUES
-- North Campus Trap Line
('NCT-01', 'DOC 200',        (SELECT line_id FROM lines WHERE name = 'North Campus Trap Line'), -43.638012, 172.462045, false),
('NCT-02', 'A24',            (SELECT line_id FROM lines WHERE name = 'North Campus Trap Line'), -43.638400, 172.462500, false),
('NCT-03', 'DOC 150',        (SELECT line_id FROM lines WHERE name = 'North Campus Trap Line'), -43.638800, 172.462950, false),
('NCT-04', 'Victor',         (SELECT line_id FROM lines WHERE name = 'North Campus Trap Line'), -43.639200, 172.463400, false),
('NCT-05', 'Rat trap',       (SELECT line_id FROM lines WHERE name = 'North Campus Trap Line'), -43.639600, 172.463850, false),
-- South Campus Trap Line
('SCT-01', 'DOC 200',        (SELECT line_id FROM lines WHERE name = 'South Campus Trap Line'), -43.652000, 172.468000, false),
('SCT-02', 'A24',            (SELECT line_id FROM lines WHERE name = 'South Campus Trap Line'), -43.652400, 172.468500, false),
('SCT-03', 'Trapinator',     (SELECT line_id FROM lines WHERE name = 'South Campus Trap Line'), -43.652800, 172.469000, false),
('SCT-04', 'DOC 250',        (SELECT line_id FROM lines WHERE name = 'South Campus Trap Line'), -43.653200, 172.469500, false),
-- Lake Edge Trap Line
('LET-01', 'DOC 200',        (SELECT line_id FROM lines WHERE name = 'Lake Edge Trap Line'),    -43.650000, 172.466000, false),
('LET-02', 'A24',            (SELECT line_id FROM lines WHERE name = 'Lake Edge Trap Line'),    -43.650400, 172.466500, false),
('LET-03', 'Flipping Timmy', (SELECT line_id FROM lines WHERE name = 'Lake Edge Trap Line'),    -43.650800, 172.467000, false),
('LET-04', 'T-Rex Rat Trap', (SELECT line_id FROM lines WHERE name = 'Lake Edge Trap Line'),    -43.651200, 172.467500, false),
('LET-05', 'Victor',         (SELECT line_id FROM lines WHERE name = 'Lake Edge Trap Line'),    -43.651600, 172.468000, false),
-- Research Farm Trap Line
('RFT-01', 'DOC 200',        (SELECT line_id FROM lines WHERE name = 'Research Farm Trap Line'),-43.656000, 172.470000, false),
('RFT-02', 'A24',            (SELECT line_id FROM lines WHERE name = 'Research Farm Trap Line'),-43.656400, 172.470500, false),
('RFT-03', 'DOC 150',        (SELECT line_id FROM lines WHERE name = 'Research Farm Trap Line'),-43.656800, 172.471000, false),
('RFT-04', 'Victor',         (SELECT line_id FROM lines WHERE name = 'Research Farm Trap Line'),-43.657200, 172.471500, false),
-- Central City Trap Line (CCT)
('CCT-01', 'DOC 200',        (SELECT line_id FROM lines WHERE name = 'Central City Trap Line'), -43.530000, 172.636000, false),
('CCT-02', 'A24',            (SELECT line_id FROM lines WHERE name = 'Central City Trap Line'), -43.530400, 172.636500, false),
('CCT-03', 'Rat trap',       (SELECT line_id FROM lines WHERE name = 'Central City Trap Line'), -43.530800, 172.637000, false),
-- Peninsula Ridge Line (BP)
('PRL-01', 'DOC 200',        (SELECT line_id FROM lines WHERE name = 'Peninsula Ridge Line'),   -43.760000, 172.940000, false),
('PRL-02', 'DOC 250',        (SELECT line_id FROM lines WHERE name = 'Peninsula Ridge Line'),   -43.760400, 172.940500, false),
('PRL-03', 'A24',            (SELECT line_id FROM lines WHERE name = 'Peninsula Ridge Line'),   -43.760800, 172.941000, false)
ON CONFLICT (code) DO NOTHING;

-- Retired line traps
INSERT INTO traps (code, trap_type, line_id, latitude, longitude, is_retired, retired_at, retired_by) VALUES
('OBT-01', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Old Boundary Track'), -43.644000, 172.458000, true, '2025-06-01 10:00:00', (SELECT user_id FROM users WHERE username = 'smitchell')),
('OBT-02', 'A24',     (SELECT line_id FROM lines WHERE name = 'Old Boundary Track'), -43.644400, 172.458500, true, '2025-06-01 10:00:00', (SELECT user_id FROM users WHERE username = 'smitchell'))
ON CONFLICT (code) DO NOTHING;

-- ══════════════════════════════════════════════════════
-- BAIT STATIONS
-- ══════════════════════════════════════════════════════

INSERT INTO bait_stations (code, station_type, line_id, latitude, longitude, is_retired) VALUES
-- North Bait Station Line (PFLU)
('NBS-01', 'Philproof',   (SELECT line_id FROM lines WHERE name = 'North Bait Station Line'), -43.638100, 172.463000, false),
('NBS-02', 'Protecta LP', (SELECT line_id FROM lines WHERE name = 'North Bait Station Line'), -43.638600, 172.463500, false),
('NBS-03', 'Nara',        (SELECT line_id FROM lines WHERE name = 'North Bait Station Line'), -43.639100, 172.464000, false),
-- South Bait Station Line (PFLU)
('SBS-01', 'Philproof',   (SELECT line_id FROM lines WHERE name = 'South Bait Station Line'), -43.652200, 172.467200, false),
('SBS-02', 'Protecta LP', (SELECT line_id FROM lines WHERE name = 'South Bait Station Line'), -43.652600, 172.467700, false),
('SBS-03', 'Nara',        (SELECT line_id FROM lines WHERE name = 'South Bait Station Line'), -43.653000, 172.468200, false),
-- Hagley Park Bait Line (CCT)
('HPS-01', 'Philproof',   (SELECT line_id FROM lines WHERE name = 'Hagley Park Bait Line'),   -43.527000, 172.632000, false),
('HPS-02', 'Nara',        (SELECT line_id FROM lines WHERE name = 'Hagley Park Bait Line'),   -43.527400, 172.632500, false)
ON CONFLICT (code) DO NOTHING;

-- Station with type 'Other' requires other_type — separate insert
INSERT INTO bait_stations (code, station_type, other_type, line_id, latitude, longitude, is_retired) VALUES
('NBS-04', 'Other', 'Repurposed biscuit tin bait box',
 (SELECT line_id FROM lines WHERE name = 'North Bait Station Line'), -43.639600, 172.464500, false)
ON CONFLICT (code) DO NOTHING;

-- ══════════════════════════════════════════════════════
-- TRAP CATCHES
-- CHECK: strikes = 0 → species_caught = 'None'
-- CHECK: rebaited = 'No' → bait_type = 'None'
-- ══════════════════════════════════════════════════════

INSERT INTO trap_catches (trap_id, date, recorded_by_id, species_caught, sex, maturity, status, rebaited, bait_type, bait_details, trap_condition, strikes, notes) VALUES

-- NCT-01
((SELECT trap_id FROM traps WHERE code = 'NCT-01'), '2024-03-10 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat',  'Male',   'Adult',    'Sprung',                  'Yes', 'Egg',           NULL,             'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'NCT-01'), '2024-06-15 08:00:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None',   NULL,     NULL,       'Still set, bait OK',      'No',  'None',          NULL,             'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'NCT-01'), '2024-09-20 09:00:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat',    'Female', 'Adult',    'Sprung',                  'Yes', 'Peanut butter', NULL,             'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'NCT-01'), '2025-01-14 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None',   NULL,     NULL,       'Still set, bait bad',     'Yes', 'Egg',           'Replaced',       'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'NCT-01'), '2025-05-08 09:00:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse',  'Male',   'Juvenile', 'Sprung',                  'Yes', 'Chocolate',     NULL,             'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'NCT-01'), '2025-09-22 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat',  'Female', 'Adult',    'Sprung',                  'Yes', 'Egg',           NULL,             'Needs maintenance',1, 'Spring tension low'),
((SELECT trap_id FROM traps WHERE code = 'NCT-01'), '2026-02-10 09:00:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None',   NULL,     NULL,       'Still set, bait OK',      'No',  'None',          NULL,             'Repaired',         0, 'Trap serviced'),

-- NCT-02
((SELECT trap_id FROM traps WHERE code = 'NCT-02'), '2024-03-10 08:45:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat',    'Male',   'Adult',    'Sprung',                  'Yes', 'Peanut butter', NULL,             'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'NCT-02'), '2024-07-18 09:00:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None',   NULL,     NULL,       'Still set, bait OK',      'No',  'None',          NULL,             'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'NCT-02'), '2025-02-22 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat',  'Male',   'Juvenile', 'Sprung',                  'Yes', 'Egg',           NULL,             'OK',               1, 'Young of year'),
((SELECT trap_id FROM traps WHERE code = 'NCT-02'), '2025-08-14 09:00:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None',   NULL,     NULL,       'Still set, bait OK',      'No',  'None',          NULL,             'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'NCT-02'), '2026-03-05 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat',    'Female', 'Adult',    'Sprung',                  'Yes', 'Chocolate',     NULL,             'OK',               1, NULL),

-- SCT-01
((SELECT trap_id FROM traps WHERE code = 'SCT-01'), '2024-04-05 09:00:00', (SELECT user_id FROM users WHERE username = 'fgrant'),  'Possum', NULL,     'Adult',    'Sprung',                  'Yes', 'Lure',          NULL,             'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'SCT-01'), '2024-08-10 08:30:00', (SELECT user_id FROM users WHERE username = 'fgrant'),  'None',   NULL,     NULL,       'Still set, bait OK',      'No',  'None',          NULL,             'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'SCT-01'), '2024-12-18 09:00:00', (SELECT user_id FROM users WHERE username = 'fgrant'),  'Stoat',  'Female', 'Adult',    'Sprung',                  'Yes', 'Egg',           NULL,             'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'SCT-01'), '2025-04-22 08:30:00', (SELECT user_id FROM users WHERE username = 'fgrant'),  'None',   NULL,     NULL,       'Still set, bait bad',     'Yes', 'Egg',           'Replaced',       'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'SCT-01'), '2025-10-15 09:00:00', (SELECT user_id FROM users WHERE username = 'fgrant'),  'Rat',    'Male',   'Adult',    'Sprung',                  'Yes', 'Peanut butter', NULL,             'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'SCT-01'), '2026-03-28 08:30:00', (SELECT user_id FROM users WHERE username = 'fgrant'),  'Possum', NULL,     'Juvenile', 'Sprung',                  'Yes', 'Lure',          NULL,             'OK',               1, NULL),

-- LET-01
((SELECT trap_id FROM traps WHERE code = 'LET-01'), '2024-03-25 07:45:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'Rat',    'Male',   'Adult',    'Sprung',                  'Yes', 'Peanut butter', NULL,             'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'LET-01'), '2024-07-05 08:15:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'Stoat',  'Male',   'Adult',    'Sprung',                  'Yes', 'Egg',           NULL,             'OK',               1, 'Near waterway'),
((SELECT trap_id FROM traps WHERE code = 'LET-01'), '2024-10-20 09:00:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'None',   NULL,     NULL,       'Still set, bait OK',      'No',  'None',          NULL,             'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'LET-01'), '2025-02-18 08:30:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'Possum', NULL,     'Adult',    'Sprung',                  'Yes', 'Lure',          NULL,             'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'LET-01'), '2025-07-10 09:00:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'None',   NULL,     NULL,       'Still set, bait missing', 'Yes', 'Egg',           'Full replacement','Needs maintenance',0, 'Water damage noted'),
((SELECT trap_id FROM traps WHERE code = 'LET-01'), '2026-01-15 08:30:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'Rat',    'Female', 'Juvenile', 'Sprung',                  'Yes', 'Chocolate',     NULL,             'Repaired',         1, 'Serviced after water damage'),

-- RFT-01
((SELECT trap_id FROM traps WHERE code = 'RFT-01'), '2024-05-12 09:00:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'Rabbit', NULL,     NULL,       'Sprung',                  'Yes', 'Lure',          NULL,             'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'RFT-01'), '2024-09-18 08:30:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'Stoat',  'Male',   'Adult',    'Sprung',                  'Yes', 'Egg',           NULL,             'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'RFT-01'), '2025-01-28 09:00:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'None',   NULL,     NULL,       'Still set, bait OK',      'No',  'None',          NULL,             'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'RFT-01'), '2025-06-14 08:30:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'Rat',    'Female', 'Adult',    'Sprung',                  'Yes', 'Peanut butter', NULL,             'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'RFT-01'), '2025-11-20 09:00:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'None',   NULL,     NULL,       'Still set, bait bad',     'Yes', 'Peanut butter', 'Fresh',          'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'RFT-01'), '2026-04-08 08:30:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'Stoat',  'Female', 'Juvenile', 'Sprung',                  'Yes', 'Egg',           NULL,             'OK',               1, NULL),

-- CCT-01
((SELECT trap_id FROM traps WHERE code = 'CCT-01'), '2024-04-18 08:00:00', (SELECT user_id FROM users WHERE username = 'hpatel'),  'Rat',    'Male',   'Adult',    'Sprung',                  'Yes', 'Peanut butter', NULL,             'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'CCT-01'), '2024-09-05 09:00:00', (SELECT user_id FROM users WHERE username = 'hpatel'),  'None',   NULL,     NULL,       'Still set, bait OK',      'No',  'None',          NULL,             'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'CCT-01'), '2025-03-20 08:30:00', (SELECT user_id FROM users WHERE username = 'hpatel'),  'Rat',    'Female', 'Adult',    'Sprung',                  'Yes', 'Chocolate',     NULL,             'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'CCT-01'), '2025-10-08 09:00:00', (SELECT user_id FROM users WHERE username = 'hpatel'),  'Mouse',  'Male',   'Adult',    'Sprung',                  'Yes', 'Peanut butter', NULL,             'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'CCT-01'), '2026-04-01 08:30:00', (SELECT user_id FROM users WHERE username = 'hpatel'),  'None',   NULL,     NULL,       'Still set, bait OK',      'No',  'None',          NULL,             'OK',               0, NULL),

-- PRL-01
((SELECT trap_id FROM traps WHERE code = 'PRL-01'), '2024-06-10 08:00:00', (SELECT user_id FROM users WHERE username = 'dlee'),    'Stoat',  'Male',   'Adult',    'Sprung',                  'Yes', 'Egg',           NULL,             'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'PRL-01'), '2024-10-22 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'),    'None',   NULL,     NULL,       'Still set, bait OK',      'No',  'None',          NULL,             'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'PRL-01'), '2025-03-12 08:30:00', (SELECT user_id FROM users WHERE username = 'dlee'),    'Rat',    'Female', 'Adult',    'Sprung',                  'Yes', 'Peanut butter', NULL,             'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'PRL-01'), '2025-09-18 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'),    'Stoat',  'Female', 'Juvenile', 'Sprung',                  'Yes', 'Egg',           NULL,             'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'PRL-01'), '2026-03-25 08:30:00', (SELECT user_id FROM users WHERE username = 'dlee'),    'None',   NULL,     NULL,       'Still set, bait bad',     'Yes', 'Egg',           'Replaced',       'OK',               0, NULL),

-- Retired line catches (before retirement date)
((SELECT trap_id FROM traps WHERE code = 'OBT-01'), '2024-08-15 08:00:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat',    'Male',   'Adult',    'Sprung',                  'Yes', 'Peanut butter', NULL,             'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'OBT-01'), '2025-02-10 09:00:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None',   NULL,     NULL,       'Still set, bait OK',      'No',  'None',          NULL,             'OK',               0, NULL)

ON CONFLICT DO NOTHING;

-- ══════════════════════════════════════════════════════
-- BAIT STATION RECORDS
-- ══════════════════════════════════════════════════════

INSERT INTO bait_station_records (station_id, date, recorded_by_id, target_species, active_ingredient, formulation, concentration, bait_remaining, bait_removed, bait_added, notes) VALUES

-- NBS-01
((SELECT station_id FROM bait_stations WHERE code = 'NBS-01'), '2024-03-01 09:00:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat',    'Brodifacoum',     'Block',   0.005, 200.000, NULL,    200.000, 'Initial fill'),
((SELECT station_id FROM bait_stations WHERE code = 'NBS-01'), '2024-07-15 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat',    'Brodifacoum',     'Block',   0.005,  80.000, 120.000, 150.000, 'High uptake — rats active'),
((SELECT station_id FROM bait_stations WHERE code = 'NBS-01'), '2025-01-20 09:00:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat',    'Brodifacoum',     'Block',   0.005, 120.000,  80.000, 120.000, NULL),
((SELECT station_id FROM bait_stations WHERE code = 'NBS-01'), '2025-07-08 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat',    'Brodifacoum',     'Block',   0.005, 160.000,  80.000, 120.000, NULL),
((SELECT station_id FROM bait_stations WHERE code = 'NBS-01'), '2026-01-22 09:00:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat',    'Brodifacoum',     'Block',   0.005, 130.000,  70.000, 100.000, NULL),

-- NBS-02
((SELECT station_id FROM bait_stations WHERE code = 'NBS-02'), '2024-03-01 09:15:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Cholecalciferol', 'Pellets', 0.08,  500.000, NULL,    500.000, 'Initial fill'),
((SELECT station_id FROM bait_stations WHERE code = 'NBS-02'), '2024-08-10 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Cholecalciferol', 'Pellets', 0.08,  320.000, 180.000, 250.000, NULL),
((SELECT station_id FROM bait_stations WHERE code = 'NBS-02'), '2025-02-18 09:00:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Cholecalciferol', 'Pellets', 0.08,  380.000, 120.000, 200.000, 'Possum activity noted near arboretum'),
((SELECT station_id FROM bait_stations WHERE code = 'NBS-02'), '2025-09-05 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Cholecalciferol', 'Pellets', 0.08,  450.000,  80.000, 150.000, NULL),
((SELECT station_id FROM bait_stations WHERE code = 'NBS-02'), '2026-03-12 09:00:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Cholecalciferol', 'Pellets', 0.08,  360.000, 140.000, 200.000, NULL),

-- SBS-01
((SELECT station_id FROM bait_stations WHERE code = 'SBS-01'), '2024-04-05 09:00:00', (SELECT user_id FROM users WHERE username = 'fgrant'),  'Rat',    'Diphacinone',     'Block',   0.005, 200.000, NULL,    200.000, 'Initial fill'),
((SELECT station_id FROM bait_stations WHERE code = 'SBS-01'), '2024-09-12 08:30:00', (SELECT user_id FROM users WHERE username = 'fgrant'),  'Rat',    'Diphacinone',     'Block',   0.005, 100.000, 100.000, 150.000, NULL),
((SELECT station_id FROM bait_stations WHERE code = 'SBS-01'), '2025-03-08 09:00:00', (SELECT user_id FROM users WHERE username = 'fgrant'),  'Rat',    'Diphacinone',     'Block',   0.005, 170.000,  80.000, 120.000, NULL),
((SELECT station_id FROM bait_stations WHERE code = 'SBS-01'), '2025-10-14 08:30:00', (SELECT user_id FROM users WHERE username = 'fgrant'),  'Rat',    'Diphacinone',     'Block',   0.005, 130.000,  70.000, 100.000, NULL),
((SELECT station_id FROM bait_stations WHERE code = 'SBS-01'), '2026-04-02 09:00:00', (SELECT user_id FROM users WHERE username = 'fgrant'),  'Rat',    'Diphacinone',     'Block',   0.005, 150.000,  50.000,  80.000, NULL),

-- HPS-01 (CCT)
((SELECT station_id FROM bait_stations WHERE code = 'HPS-01'), '2024-05-01 09:00:00', (SELECT user_id FROM users WHERE username = 'hpatel'),  'Rat',    'Brodifacoum',     'Block',   0.005, 200.000, NULL,    200.000, 'Initial fill'),
((SELECT station_id FROM bait_stations WHERE code = 'HPS-01'), '2024-10-15 08:30:00', (SELECT user_id FROM users WHERE username = 'hpatel'),  'Rat',    'Brodifacoum',     'Block',   0.005,  60.000, 140.000, 180.000, 'Very high uptake in urban zone'),
((SELECT station_id FROM bait_stations WHERE code = 'HPS-01'), '2025-04-08 09:00:00', (SELECT user_id FROM users WHERE username = 'hpatel'),  'Rat',    'Brodifacoum',     'Block',   0.005, 140.000,  80.000, 120.000, NULL),
((SELECT station_id FROM bait_stations WHERE code = 'HPS-01'), '2025-11-20 08:30:00', (SELECT user_id FROM users WHERE username = 'hpatel'),  'Rat',    'Brodifacoum',     'Block',   0.005, 180.000,  80.000, 120.000, NULL),
((SELECT station_id FROM bait_stations WHERE code = 'HPS-01'), '2026-04-15 09:00:00', (SELECT user_id FROM users WHERE username = 'hpatel'),  'Rat',    'Brodifacoum',     'Block',   0.005, 130.000,  70.000, 100.000, NULL);

-- ══════════════════════════════════════════════════════
-- INCIDENTAL OBSERVATIONS
-- ══════════════════════════════════════════════════════

INSERT INTO incidental_observations (date, operator_id, observation_type, notes, latitude, longitude, line_id) VALUES
('2024-03-12 07:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Predator sighting',     'Stoat spotted near north campus fence line at dawn.',         -43.638200, 172.462500, (SELECT line_id FROM lines WHERE name = 'North Campus Trap Line')),
('2024-05-18 08:00:00', (SELECT user_id FROM users WHERE username = 'fgrant'),  'Predator tracks',       'Possum tracks in mud on south campus path after rain.',       -43.652300, 172.468600, (SELECT line_id FROM lines WHERE name = 'South Campus Trap Line')),
('2024-07-14 09:00:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'Native species tracks', 'Pūkeko tracks along lake edge — good habitat indicator.',     -43.650600, 172.466800, (SELECT line_id FROM lines WHERE name = 'Lake Edge Trap Line')),
('2024-09-22 08:15:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Bird sighting',         'Morepork heard calling near north campus at dusk.',           -43.638800, 172.463000, (SELECT line_id FROM lines WHERE name = 'North Campus Trap Line')),
('2024-11-10 07:45:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'Predator sighting',     'Rat observed entering grain store at research farm.',         -43.656200, 172.470400, (SELECT line_id FROM lines WHERE name = 'Research Farm Trap Line')),
('2025-01-20 09:30:00', (SELECT user_id FROM users WHERE username = 'fgrant'),  'Native species sign',   'Gecko sheltering under south campus trap cover — positive.',  -43.652800, 172.469000, (SELECT line_id FROM lines WHERE name = 'South Campus Trap Line')),
('2025-03-05 08:00:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'Bird sighting',         'Kererū pair feeding in willows along lake edge.',             -43.650400, 172.467200, (SELECT line_id FROM lines WHERE name = 'Lake Edge Trap Line')),
('2025-05-28 07:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Predator tracks',       'Fresh rat burrows found near north bait station NBS-03.',     -43.639100, 172.464000, (SELECT line_id FROM lines WHERE name = 'North Bait Station Line')),
('2025-07-15 09:00:00', (SELECT user_id FROM users WHERE username = 'hpatel'),  'Predator sighting',     'Rat running along central city wall at dusk.',                -43.530200, 172.636200, (SELECT line_id FROM lines WHERE name = 'Central City Trap Line')),
('2025-09-08 08:30:00', (SELECT user_id FROM users WHERE username = 'fgrant'),  'Other',                 'Trap cover damaged by livestock — repaired on site.',         -43.652500, 172.468000, (SELECT line_id FROM lines WHERE name = 'South Campus Trap Line')),
('2025-11-22 07:45:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'Bird sighting',         'Pied stilt pair nesting near lake — pair bonded.',            -43.650800, 172.466500, (SELECT line_id FROM lines WHERE name = 'Lake Edge Trap Line')),
('2026-01-14 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'),    'Predator sighting',     'Stoat with prey item crossing peninsula ridge at midday.',    -43.760200, 172.940200, (SELECT line_id FROM lines WHERE name = 'Peninsula Ridge Line')),
('2026-03-28 08:00:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Native species sign',   'Skink tracks near north bait line — positive recovery sign.', -43.638500, 172.463200, (SELECT line_id FROM lines WHERE name = 'North Bait Station Line')),
('2026-04-15 09:30:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'Predator tracks',       'Fresh stoat prints on tracking card near research farm trap.',-43.656400, 172.471000, (SELECT line_id FROM lines WHERE name = 'Research Farm Trap Line'))

ON CONFLICT DO NOTHING;

-- ══════════════════════════════════════════════════════
-- GROUP JOIN REQUESTS
-- Banks Peninsula Restoration is private — use these to test coordinator review
-- Log in as dlee / Password1! to approve or reject
-- ══════════════════════════════════════════════════════

INSERT INTO group_join_requests (user_id, group_id, status, message, requested_at)
VALUES
(
    (SELECT user_id FROM users WHERE username = 'trequest1'),
    (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'),
    'pending',
    'I live on Banks Peninsula and have been trapping on my property for three years. Would love to contribute data to a coordinated effort.',
    NOW() - INTERVAL '4 days'
),
(
    (SELECT user_id FROM users WHERE username = 'trequest2'),
    (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'),
    'pending',
    'Keen to get involved with organised trapping on the peninsula.',
    NOW() - INTERVAL '1 day'
)
ON CONFLICT (user_id, group_id) DO NOTHING;

-- ══════════════════════════════════════════════════════
-- GROUP APPLICATIONS
-- Log in as smitchell / Password1! (Super Admin) to approve or reject
-- ══════════════════════════════════════════════════════

INSERT INTO group_applications (user_id, proposed_name, description, location, justification, status, applied_at) VALUES
(
    (SELECT user_id FROM users WHERE username = 'enyberg'),
    'Selwyn District Trappers',
    'An informal trapping network across the Selwyn District with about 15 volunteers, focused on coordinating predator control efforts.',
    'Selwyn District',
    'I coordinate an informal trapping network across the Selwyn District with about 15 volunteers. Formalising would let us centralise our data and coordinate effort more effectively.',
    'pending',
    NOW() - INTERVAL '5 days'
),
(
    (SELECT user_id FROM users WHERE username = 'hpatel'),
    'Riccarton Bush Restoration',
    'A small community group focused on predator control in the Riccarton Bush reserve, running monthly trap checks.',
    'Riccarton, Christchurch',
    'A small community group focused on the Riccarton Bush reserve. We run monthly trap checks and would benefit from proper data recording tools.',
    'pending',
    NOW() - INTERVAL '2 days'
)
ON CONFLICT DO NOTHING;

-- ══════════════════════════════════════════════════════
-- USER NOTIFICATIONS
-- ══════════════════════════════════════════════════════

INSERT INTO user_notifications (user_id, message, category, is_active, created_at) VALUES
(
    (SELECT user_id FROM users WHERE username = 'trequest1'),
    'Your request to join Banks Peninsula Restoration is pending review by the coordinator.',
    'info', true, NOW() - INTERVAL '4 days'
),
(
    (SELECT user_id FROM users WHERE username = 'trequest2'),
    'Your request to join Banks Peninsula Restoration is pending review by the coordinator.',
    'info', true, NOW() - INTERVAL '1 day'
),
(
    (SELECT user_id FROM users WHERE username = 'dlee'),
    'You have 2 pending join requests to review for Banks Peninsula Restoration.',
    'info', true, NOW() - INTERVAL '1 day'
),
(
    (SELECT user_id FROM users WHERE username = 'smitchell'),
    'Group application from Erik Nyberg (Selwyn District Trappers) is awaiting your review.',
    'info', true, NOW() - INTERVAL '5 days'
),
(
    (SELECT user_id FROM users WHERE username = 'smitchell'),
    'Group application from Hira Patel (Riccarton Bush Restoration) is awaiting your review.',
    'info', true, NOW() - INTERVAL '2 days'
);

-- ══════════════════════════════════════════════════════
-- RESET SEQUENCES
-- ══════════════════════════════════════════════════════

SELECT setval('users_user_id_seq',                          (SELECT MAX(user_id)          FROM users));
SELECT setval('groups_group_id_seq',                        (SELECT MAX(group_id)         FROM groups));
SELECT setval('group_memberships_membership_id_seq',        (SELECT MAX(membership_id)    FROM group_memberships));
SELECT setval('lines_line_id_seq',                          (SELECT MAX(line_id)          FROM lines));
SELECT setval('traps_trap_id_seq',                          (SELECT MAX(trap_id)          FROM traps));
SELECT setval('bait_stations_station_id_seq',               (SELECT MAX(station_id)       FROM bait_stations));
SELECT setval('trap_catches_catch_id_seq',                  (SELECT MAX(catch_id)         FROM trap_catches));
SELECT setval('bait_station_records_record_id_seq',         (SELECT MAX(record_id)        FROM bait_station_records));
SELECT setval('incidental_observations_observation_id_seq', (SELECT MAX(observation_id)   FROM incidental_observations));
SELECT setval('group_join_requests_request_id_seq',         (SELECT MAX(request_id)       FROM group_join_requests));
SELECT setval('group_applications_application_id_seq',      (SELECT MAX(application_id)   FROM group_applications));
SELECT setval('user_notifications_notification_id_seq',     (SELECT MAX(notification_id)  FROM user_notifications));

COMMIT;
