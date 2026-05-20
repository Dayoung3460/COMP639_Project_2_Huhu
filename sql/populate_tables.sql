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
    ('Weasel'), ('Hedgehog'), ('Rabbit'), ('Ferret'), ('Cat (feral)'),
    ('Kiore Rat'), ('Norway Rat'), ('Ship Rat'), ('Unspecified'), ('Other')
ON CONFLICT DO NOTHING;

INSERT INTO trap_statuses (name) VALUES
    ('Sprung'),
    ('Still set, bait OK'),
    ('Still set, bait bad'),
    ('Still set, bait missing'),
    ('Initial set'),
    ('Removed'),
    ('Removed for Repair'),
    ('Trap Replaced'),
    ('Trap gone'),
    ('Trap interfered with')
ON CONFLICT DO NOTHING;

INSERT INTO bait_types (name) VALUES
    ('None'), ('Carrot'), ('Cereal'), ('Cheese'), ('Chocolate'),
    ('Dehydrated Rabbit'), ('Dried fruit'), ('Egg'),
    ('Ferret bedding'), ('Fish'), ('Fresh Possum'), ('Fresh Rabbit'),
    ('Fresh fruit'), ('Fresh meat'), ('Golf ball'),
    ('Good Nature Chocolate'), ('Good Nature Meat Lovers'),
    ('Goodnature Blood'), ('Goodnature Cinnamon pre feed'),
    ('Goodnature Nut Butter'), ('Lure'), ('Lure-it Salmon Spray'),
    ('Mayo'), ('Mustelid and Cat Lure'), ('NARA Blocks'),
    ('NZAT Lure - Original'), ('Nut'), ('Nutella'),
    ('Other'), ('Peanut butter'), ('PoaUku'),
    ('Possum Dough'), ('Rabbit'), ('Rabbit oil'),
    ('Rat and Possum Lure'), ('Rat oil'), ('Salmon'), ('Salmon oil'),
    ('Salted Possum'), ('Salted Rabbit'), ('Salted meat'),
    ('Smooth'), ('Terracotta Lures'), ('Tinned Sardines'), ('Whole egg'),
    ('Chicken')
ON CONFLICT DO NOTHING;

INSERT INTO trap_types (name) VALUES
    ('A24'), ('DOC 150'), ('DOC 200'), ('DOC 250'),
    ('Flipping Timmy'), ('Rat trap'), ('Snap-E'), ('Steve Allan'),
    ('T-Rex Rat Trap'), ('Timms'), ('Trapinator'), ('Victor')
ON CONFLICT DO NOTHING;

INSERT INTO bait_station_types (name) VALUES
    ('Bait Safe'), ('Bell Labs'), ('Chimney'), ('EnviroMate100'),
    ('Flowerpot'), ('Goodnature'), ('Hockey stick'), ('KK'),
    ('Kilmore'), ('Mini Philproof'), ('Nara'), ('Novacoil'),
    ('PelGar Rat Station'), ('Philproof'), ('Pied Piper'),
    ('Protecta Ambush'), ('Protecta EVO Edge'), ('Protecta LP'),
    ('Protecta Sidekick'), ('Rodent Cafe'), ('Sentry'), ('Sentry Plus'),
    ('Striker'), ('Trakka'), ('Tunnel'), ('Wasptek'), ('ZIP tunnel'),
    ('Other')
ON CONFLICT DO NOTHING;

INSERT INTO bait_formulations (name) VALUES
    ('Block'), ('Cereal'), ('Gel'), ('Grain'), ('Liquid'),
    ('Paste'), ('Pellets'), ('Powder'), ('Wax block')
ON CONFLICT DO NOTHING;

INSERT INTO active_ingredients (name) VALUES
    ('Brodifacoum'), ('Bromadiolone'), ('Cholecalciferol'),
    ('Coumatetralyl'), ('Cyanide'), ('Diphacinone'), ('Flocoumafen'),
    ('PAPP'), ('Pindone'), ('Sodium fluoroacetate (1080)'), ('Zinc phosphide')
ON CONFLICT DO NOTHING;

-- ══════════════════════════════════════════════════════
-- GROUPS
-- ══════════════════════════════════════════════════════

INSERT INTO groups (name, description, location, is_public, cover_photo, color_theme) VALUES
    ('Predator Free Lincoln University',
     'Volunteer predator-control initiative across Lincoln University campus.',
     'Lincoln, Canterbury',
     TRUE,  'group_lincoln.png', '#198754'),
    ('Christchurch City Trappers',
     'Community predator trapping group operating across central Christchurch.',
     'Christchurch, Canterbury',
     TRUE,  'group_chch.png',    '#0d6efd'),
    ('Banks Peninsula Restoration',
     'Private restoration group operating on private land on Banks Peninsula.',
     'Banks Peninsula, Canterbury',
     FALSE, 'group_banks.png',   '#dc3545')
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

-- Support Technicians (site-wide, no group memberships)
('lchen',     'l.chen@support.tiaki.nz',  '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Lily',  'Chen',     FALSE, 'active',   '021 888 9900', NULL, NULL, NULL, '2025-06-01 09:00:00', '2026-05-10 08:30:00'),
('mreid',     'm.reid@support.tiaki.nz',  '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Mark',  'Reid',     FALSE, 'active',   '021 777 0011', NULL, NULL, NULL, '2025-06-01 09:00:00', '2026-05-12 09:15:00'),

-- No-membership users for join request testing
('trequest1', 'tom.request@example.com',   '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Tom',   'Request',  FALSE, 'active',   NULL, NULL, NULL, NULL, NOW() - INTERVAL '3 days', NULL),
('trequest2', 'sara.request@example.com',  '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Sara',  'Request',  FALSE, 'active',   NULL, NULL, NULL, NULL, NOW() - INTERVAL '1 day',  NULL)

ON CONFLICT (username) DO NOTHING;

-- Flag support technicians (done after INSERT to avoid column-list issues)
UPDATE users SET is_support_tech = TRUE
WHERE username IN ('lchen', 'mreid');

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
-- The unique index is partial (WHERE status = 'pending'), so the
-- ON CONFLICT target must repeat that predicate.
ON CONFLICT (user_id, group_id) WHERE status = 'pending' DO NOTHING;

-- ══════════════════════════════════════════════════════
-- GROUP APPLICATIONS
-- Log in as smitchell / Password1! (Super Admin) to approve or reject
-- ══════════════════════════════════════════════════════

INSERT INTO group_applications (user_id, proposed_name, description, location, justification, status, applied_at, decided_by, decided_at, decision_reason) VALUES
(
    (SELECT user_id FROM users WHERE username = 'enyberg'),
    'Selwyn District Trappers',
    'An informal trapping network across the Selwyn District with about 15 volunteers, focused on coordinating predator control efforts.',
    'Selwyn District',
    'I coordinate an informal trapping network across the Selwyn District with about 15 volunteers. Formalising would let us centralise our data and coordinate effort more effectively.',
    'approved',
    NOW() - INTERVAL '5 days',
    (SELECT user_id FROM users WHERE is_super_admin = TRUE LIMIT 1),
    NOW() - INTERVAL '3 days',
    'Great initiative, approved and welcome to the platform.'
),
(
    (SELECT user_id FROM users WHERE username = 'hpatel'),
    'Riccarton Bush Restoration',
    'A small community group focused on predator control in the Riccarton Bush reserve, running monthly trap checks.',
    'Riccarton, Christchurch',
    'A small community group focused on the Riccarton Bush reserve. We run monthly trap checks and would benefit from proper data recording tools.',
    'pending',
    NOW() - INTERVAL '2 days',
    NULL,
    NULL,
    NULL
)
ON CONFLICT DO NOTHING;

-- ══════════════════════════════════════════════════════
-- USER NOTIFICATIONS
-- ══════════════════════════════════════════════════════

INSERT INTO user_notifications (user_id, group_id, message, category, is_active, created_at) VALUES
(
    (SELECT user_id FROM users WHERE username = 'trequest1'),
    (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'),
    'Your request to join Banks Peninsula Restoration is pending review by the coordinator.',
    'info', true, NOW() - INTERVAL '4 days'
),
(
    (SELECT user_id FROM users WHERE username = 'trequest2'),
    (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'),
    'Your request to join Banks Peninsula Restoration is pending review by the coordinator.',
    'info', true, NOW() - INTERVAL '1 day'
),
(
    (SELECT user_id FROM users WHERE username = 'dlee'),
    (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'),
    'You have 2 pending join requests to review for Banks Peninsula Restoration.',
    'info', true, NOW() - INTERVAL '1 day'
),
(
    (SELECT user_id FROM users WHERE username = 'enyberg'),
    (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'),
    'New join request for Banks Peninsula Restoration',
    'info', true, NOW() - INTERVAL '1 day'
),
(
    (SELECT user_id FROM users WHERE username = 'smitchell'),
    NULL,
    'Group application from Erik Nyberg (Selwyn District Trappers) is awaiting your review.',
    'info', true, NOW() - INTERVAL '5 days'
),
(
    (SELECT user_id FROM users WHERE username = 'smitchell'),
    NULL,
    'Group application from Hira Patel (Riccarton Bush Restoration) is awaiting your review.',
    'info', true, NOW() - INTERVAL '2 days'
);

-- ══════════════════════════════════════════════════════
-- PLATFORM SETTINGS (singleton)
-- ══════════════════════════════════════════════════════

INSERT INTO platform_settings (id) VALUES (1)
ON CONFLICT (id) DO NOTHING;

-- ══════════════════════════════════════════════════════
-- THEME PRESETS (gallery library — 5 platform-shipped themes)
-- ══════════════════════════════════════════════════════

INSERT INTO theme_presets
  (preset_id, name, description,
   primary_color, secondary_color, background_color,
   button_style, font_heading, font_body, nav_position, content_width,
   display_order)
VALUES
  (1, 'Default Tiaki',
      'The platform default — deep forest, terracotta accent, warm cream background.',
      '#1a3a2e', '#c65d3c', '#f5f0e6',
      'rounded', 'Fraunces', 'IBM Plex Sans', 'sidebar', 'wrap',
      0),
  (2, 'Forest',
      'Deep greens and warm browns for native bush groups.',
      '#2d5016', '#8b6f47', '#f4ead5',
      'rounded', 'Merriweather', 'Source Sans 3', 'sidebar', 'wrap',
      1),
  (3, 'Coastal',
      'Ocean blues and sand for coastal restoration groups.',
      '#1e5f8e', '#d4a574', '#f0f4f7',
      'rounded', 'Playfair Display', 'Inter', 'sidebar', 'full',
      2),
  (4, 'Tussock',
      'Golden tussock and earthy tones for high-country groups.',
      '#8b6914', '#5c4a3a', '#faf3e0',
      'square', 'Oswald', 'Lora', 'topbar', 'full',
      3),
  (5, 'Pōhutukawa',
      'Crimson and sage for coastal pōhutukawa-belt groups — top nav, wrapped layout.',
      '#8a1f3a', '#2d5a44', '#faf2e8',
      'rounded', 'Fraunces', 'Source Sans 3', 'topbar', 'wrap',
      4)
ON CONFLICT (preset_id) DO NOTHING;

-- Keep sequence ahead of the explicit preset_ids above.
SELECT setval('theme_presets_preset_id_seq',
              (SELECT MAX(preset_id) FROM theme_presets));

-- ══════════════════════════════════════════════════════
-- PLATFORM THEME (singleton — points at Default Tiaki)
-- ══════════════════════════════════════════════════════

INSERT INTO platform_theme
  (id, primary_color, secondary_color, background_color,
   button_style, font_heading, font_body, nav_position, content_width,
   based_on_preset)
VALUES
  (1, '#1a3a2e', '#c65d3c', '#f5f0e6',
   'rounded', 'Fraunces', 'IBM Plex Sans', 'sidebar', 'wrap',
   1)
ON CONFLICT (id) DO NOTHING;

-- ══════════════════════════════════════════════════════
-- SUPPORT TICKETS — bkim test data
-- Log in as bkim / Password1! to see these in My Requests
-- lchen and mreid are the assigned Support Technicians.
-- ══════════════════════════════════════════════════════

INSERT INTO support_tickets
    (submitted_by, group_id, request_type, title, description, priority, status, assigned_to, created_at, updated_at)
VALUES
(
    (SELECT user_id FROM users WHERE username = 'bkim'),
    (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'),
    'Help',
    'Cannot export catch records to CSV',
    'When I click the CSV export button on the Reports page nothing happens. I have tried Chrome and Firefox. No error message appears — the button just does nothing.',
    'Medium',
    'Open',
    (SELECT user_id FROM users WHERE username = 'lchen'),
    NOW() - INTERVAL '6 days',
    NOW() - INTERVAL '1 day'
),
(
    (SELECT user_id FROM users WHERE username = 'bkim'),
    (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'),
    'Bug Report',
    'Bait station map pins disappear after page refresh',
    'After adding a new bait station and saving, the map pin appears correctly. But if I refresh the page the pin is gone, even though the station shows in the list. This only happens for bait stations — trap pins are fine.',
    'High',
    'New',
    NULL,
    NOW() - INTERVAL '2 days',
    NOW() - INTERVAL '2 days'
),
(
    (SELECT user_id FROM users WHERE username = 'bkim'),
    (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'),
    'Help',
    'How do I invite a new operator to my group?',
    'I have a new volunteer who wants to join as an Operator. I can see the Members page but cannot find an invite or add button. Do they need to register themselves first and then request to join, or can I add them directly?',
    'Low',
    'Resolved',
    (SELECT user_id FROM users WHERE username = 'mreid'),
    NOW() - INTERVAL '14 days',
    NOW() - INTERVAL '10 days'
),
(
    (SELECT user_id FROM users WHERE username = 'bkim'),
    (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'),
    'Bug Report',
    'Line assignment page shows wrong operator count',
    'On the Assign Operators page, the operator count badge next to each line shows a number that does not match the actual assigned operators list below. For example North Campus Trap Line shows 3 but only 2 operators are listed.',
    'Medium',
    'Stalled',
    (SELECT user_id FROM users WHERE username = 'mreid'),
    NOW() - INTERVAL '20 days',
    NOW() - INTERVAL '8 days'
)
ON CONFLICT DO NOTHING;

-- Replies for ticket 1 (CSV export — Open)
INSERT INTO ticket_replies (ticket_id, author_id, body, created_at)
VALUES
(
    (SELECT ticket_id FROM support_tickets WHERE title = 'Cannot export catch records to CSV' AND submitted_by = (SELECT user_id FROM users WHERE username = 'bkim')),
    (SELECT user_id FROM users WHERE username = 'lchen'),
    'Thanks for the report, Bo. Can you let me know which browser version you are using? Also, does the issue occur on all groups or just Predator Free Lincoln University?',
    NOW() - INTERVAL '4 days'
),
(
    (SELECT ticket_id FROM support_tickets WHERE title = 'Cannot export catch records to CSV' AND submitted_by = (SELECT user_id FROM users WHERE username = 'bkim')),
    (SELECT user_id FROM users WHERE username = 'bkim'),
    'Chrome 124.0.6367.82 and Firefox 125.0.1. I only have coordinator access on PFLU so I cannot test other groups. I also tried on my laptop and the same thing happens.',
    NOW() - INTERVAL '3 days'
),
(
    (SELECT ticket_id FROM support_tickets WHERE title = 'Cannot export catch records to CSV' AND submitted_by = (SELECT user_id FROM users WHERE username = 'bkim')),
    (SELECT user_id FROM users WHERE username = 'lchen'),
    'Confirmed — looks like a JavaScript error is being thrown when the date range has no catches. Working on a fix now.',
    NOW() - INTERVAL '1 day'
)
ON CONFLICT DO NOTHING;

-- Replies for ticket 3 (invite operator — Resolved)
INSERT INTO ticket_replies (ticket_id, author_id, body, created_at)
VALUES
(
    (SELECT ticket_id FROM support_tickets WHERE title = 'How do I invite a new operator to my group?' AND submitted_by = (SELECT user_id FROM users WHERE username = 'bkim')),
    (SELECT user_id FROM users WHERE username = 'mreid'),
    'Hi Bo — new users need to register an account themselves first at /register. Once they have an account they can either request to join your group (if it is private) or be added directly by you on the Members page using the role change option. Let me know if you need more help.',
    NOW() - INTERVAL '13 days'
),
(
    (SELECT ticket_id FROM support_tickets WHERE title = 'How do I invite a new operator to my group?' AND submitted_by = (SELECT user_id FROM users WHERE username = 'bkim')),
    (SELECT user_id FROM users WHERE username = 'bkim'),
    'Perfect, that worked. They registered and I approved their join request. Thanks!',
    NOW() - INTERVAL '11 days'
)
ON CONFLICT DO NOTHING;

-- Status history for ticket 3 (New → Open → Resolved)
INSERT INTO ticket_status_history (ticket_id, changed_by, old_status, new_status, changed_at)
VALUES
(
    (SELECT ticket_id FROM support_tickets WHERE title = 'How do I invite a new operator to my group?' AND submitted_by = (SELECT user_id FROM users WHERE username = 'bkim')),
    (SELECT user_id FROM users WHERE username = 'mreid'),
    'New', 'Open',
    NOW() - INTERVAL '13 days'
),
(
    (SELECT ticket_id FROM support_tickets WHERE title = 'How do I invite a new operator to my group?' AND submitted_by = (SELECT user_id FROM users WHERE username = 'bkim')),
    (SELECT user_id FROM users WHERE username = 'mreid'),
    'Open', 'Resolved',
    NOW() - INTERVAL '10 days'
)
ON CONFLICT DO NOTHING;

-- Status history for ticket 4 (New → Open → Stalled)
INSERT INTO ticket_status_history (ticket_id, changed_by, old_status, new_status, changed_at)
VALUES
(
    (SELECT ticket_id FROM support_tickets WHERE title = 'Line assignment page shows wrong operator count' AND submitted_by = (SELECT user_id FROM users WHERE username = 'bkim')),
    (SELECT user_id FROM users WHERE username = 'mreid'),
    'New', 'Open',
    NOW() - INTERVAL '18 days'
),
(
    (SELECT ticket_id FROM support_tickets WHERE title = 'Line assignment page shows wrong operator count' AND submitted_by = (SELECT user_id FROM users WHERE username = 'bkim')),
    (SELECT user_id FROM users WHERE username = 'mreid'),
    'Open', 'Stalled',
    NOW() - INTERVAL '8 days'
)
ON CONFLICT DO NOTHING;

-- Additional support tickets from other users
INSERT INTO support_tickets
    (submitted_by, group_id, request_type, title, description, priority, status, assigned_to, created_at, updated_at)
VALUES
(
    (SELECT user_id FROM users WHERE username = 'enyberg'),
    (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'),
    'Bug Report',
    'Add catch form crashes when no traps on assigned line',
    'When I try to add a catch record and select a line that has no traps, the form throws a 500 error. This only happens on lines with zero traps — lines with at least one trap work fine.',
    'High',
    'New',
    NULL,
    NOW() - INTERVAL '1 day',
    NOW() - INTERVAL '1 day'
),
(
    (SELECT user_id FROM users WHERE username = 'enyberg'),
    (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'),
    'Help',
    'How do I see a history of all my past catch records?',
    'I can see my recent records on the My Records page but I cannot find a way to view records from previous months. Is there a way to filter or export everything I have submitted?',
    'Low',
    'Resolved',
    (SELECT user_id FROM users WHERE username = 'lchen'),
    NOW() - INTERVAL '30 days',
    NOW() - INTERVAL '25 days'
),
(
    (SELECT user_id FROM users WHERE username = 'iford'),
    (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'),
    'Bug Report',
    'Map does not load on the Lines page — blank tile area',
    'The map area on the Lines page shows as a blank grey box. No tiles load at all. Checked on two different browsers (Chrome and Edge) and the same issue occurs. Other pages load fine.',
    'High',
    'Open',
    (SELECT user_id FROM users WHERE username = 'lchen'),
    NOW() - INTERVAL '4 days',
    NOW() - INTERVAL '2 days'
),
(
    (SELECT user_id FROM users WHERE username = 'iford'),
    (SELECT group_id FROM groups WHERE name = 'Selwyn District Trappers'),
    'Help',
    'Can I be a member of more than one group at the same time?',
    'I have been asked to join a second conservation group but I am already a member of Banks Peninsula Restoration. Is it possible to belong to two groups? If so, how do I request to join the second group?',
    'Low',
    'New',
    NULL,
    NOW() - INTERVAL '3 hours',
    NOW() - INTERVAL '3 hours'
)
ON CONFLICT DO NOTHING;

-- Reply for enyberg resolved ticket (catch history help)
INSERT INTO ticket_replies (ticket_id, author_id, body, created_at)
VALUES
(
    (SELECT ticket_id FROM support_tickets WHERE title = 'How do I see a history of all my past catch records?' AND submitted_by = (SELECT user_id FROM users WHERE username = 'enyberg')),
    (SELECT user_id FROM users WHERE username = 'lchen'),
    'Hi Erik — on the My Records page use the date range filter at the top to expand the window. You can also download a CSV of all your records from the Reports page. Let me know if that helps.',
    NOW() - INTERVAL '28 days'
),
(
    (SELECT ticket_id FROM support_tickets WHERE title = 'How do I see a history of all my past catch records?' AND submitted_by = (SELECT user_id FROM users WHERE username = 'enyberg')),
    (SELECT user_id FROM users WHERE username = 'enyberg'),
    'Perfect, the CSV export worked great. Thanks Lily!',
    NOW() - INTERVAL '26 days'
)
ON CONFLICT DO NOTHING;

-- Reply for iford map bug
INSERT INTO ticket_replies (ticket_id, author_id, body, created_at)
VALUES
(
    (SELECT ticket_id FROM support_tickets WHERE title = 'Map does not load on the Lines page — blank tile area' AND submitted_by = (SELECT user_id FROM users WHERE username = 'iford')),
    (SELECT user_id FROM users WHERE username = 'lchen'),
    'Thanks for the report. Could you check your browser console (F12 → Console) and let me know if there are any errors when the page loads? Also, does the map work if you try on a mobile device?',
    NOW() - INTERVAL '3 days'
)
ON CONFLICT DO NOTHING;

-- Status history for enyberg resolved ticket
INSERT INTO ticket_status_history (ticket_id, changed_by, old_status, new_status, changed_at)
VALUES
(
    (SELECT ticket_id FROM support_tickets WHERE title = 'How do I see a history of all my past catch records?' AND submitted_by = (SELECT user_id FROM users WHERE username = 'enyberg')),
    (SELECT user_id FROM users WHERE username = 'lchen'),
    'New', 'Open',
    NOW() - INTERVAL '29 days'
),
(
    (SELECT ticket_id FROM support_tickets WHERE title = 'How do I see a history of all my past catch records?' AND submitted_by = (SELECT user_id FROM users WHERE username = 'enyberg')),
    (SELECT user_id FROM users WHERE username = 'lchen'),
    'Open', 'Resolved',
    NOW() - INTERVAL '25 days'
)
ON CONFLICT DO NOTHING;

-- Status history for iford map bug (New → Open)
INSERT INTO ticket_status_history (ticket_id, changed_by, old_status, new_status, changed_at)
VALUES
(
    (SELECT ticket_id FROM support_tickets WHERE title = 'Map does not load on the Lines page — blank tile area' AND submitted_by = (SELECT user_id FROM users WHERE username = 'iford')),
    (SELECT user_id FROM users WHERE username = 'lchen'),
    'New', 'Open',
    NOW() - INTERVAL '4 days'
)
ON CONFLICT DO NOTHING;

-- ══════════════════════════════════════════════════════
-- KNOWLEDGE BASE ARTICLES (P2-63)
-- ══════════════════════════════════════════════════════

INSERT INTO kb_articles (category_id, title, body, is_published) VALUES (
  (SELECT category_id FROM kb_categories WHERE name = 'Account & Login'),
  'How do I reset my password?',
  'If you have forgotten your password, follow these steps:

1. Go to the login page and click "Forgot password?" below the login form.
2. Enter your registered email address and click Submit.
3. Check your inbox for a reset link — it expires after 1 hour.
4. Click the link, enter your new password twice, and save.

Your new password must be at least 8 characters and include an uppercase letter, a lowercase letter, and a number.

If you do not receive the email within a few minutes, check your spam folder. If the problem persists, submit a support request.',
  TRUE
);

INSERT INTO kb_articles (category_id, title, body, is_published) VALUES (
  (SELECT category_id FROM kb_categories WHERE name = 'Account & Login'),
  'How do I update my profile?',
  'You can update your name, phone number, address, emergency contact, and profile photo at any time.

1. Click your avatar or username in the top navigation bar.
2. Select "My Profile" from the menu.
3. Edit the fields you want to change.
4. Click Save to apply the changes.

Note: your username and email address cannot be changed here. If you need to update these, submit a support request.',
  TRUE
);

INSERT INTO kb_articles (category_id, title, body, is_published) VALUES (
  (SELECT category_id FROM kb_categories WHERE name = 'Account & Login'),
  'Why can''t I log in?',
  'There are a few common reasons why you may not be able to log in:

Incorrect credentials
Make sure your username and password are typed correctly. Passwords are case-sensitive.

Account suspended or deactivated
If your account has been suspended or deactivated, you will see a message at login. Contact support for assistance.

No group membership
If you have just registered, you are not automatically a member of any group. You need to apply to join a group from the home page before you can access group features.

Browser issues
Try clearing your browser cache or using a different browser.',
  TRUE
);

INSERT INTO kb_articles (category_id, title, body, is_published) VALUES (
  (SELECT category_id FROM kb_categories WHERE name = 'Account & Login'),
  'How do I join a conservation group?',
  'To join an existing group:

1. Log in and go to the home page — all public groups are listed there.
2. Find the group you want to join and click its tile.
3. Click "Request to Join" on the group page.
4. Add an optional message explaining why you want to join.
5. Submit the request.

The Group Coordinator will review your request and approve or decline it. You will receive a notification once a decision is made.

Private groups are not listed publicly. You will need an invitation from the Group Coordinator.',
  TRUE
);

INSERT INTO kb_articles (category_id, title, body, is_published) VALUES (
  (SELECT category_id FROM kb_categories WHERE name = 'Lines & Traps'),
  'What is a trap line?',
  'A trap line is a named route or area that contains a set of traps. Each trap belongs to exactly one line.

Lines are managed by Group Coordinators and Super Admins. As an Operator, you are assigned to specific lines and can record catches for the traps on those lines.

Two types of lines exist:
- Trap Lines — contain individual traps (e.g. DOC 200, Timms, Victor)
- Bait Station Lines — contain bait stations instead of traps

You can view all lines in your group by clicking "Lines" in the navigation.',
  TRUE
);

INSERT INTO kb_articles (category_id, title, body, is_published) VALUES (
  (SELECT category_id FROM kb_categories WHERE name = 'Lines & Traps'),
  'How do I view the traps on a line?',
  'To see the traps on a specific line:

1. Click "Lines" in the navigation.
2. Find the line you want and click its name.
3. The line detail page shows a map of all trap locations and a table listing each trap with its code, type, and status.

You can filter the list to show All, Active, or Retired traps using the buttons above the map.

Clicking a trap marker on the map highlights the corresponding row in the table.',
  TRUE
);

INSERT INTO kb_articles (category_id, title, body, is_published) VALUES (
  (SELECT category_id FROM kb_categories WHERE name = 'Lines & Traps'),
  'What does "retired" mean for a trap?',
  'A retired trap is one that has been permanently removed from service. Retired traps are kept in the system for historical record purposes — any catch records associated with them are preserved.

You cannot add new catch records to a retired trap.

A trap can be retired by a Group Coordinator or Super Admin from the line detail page. If a trap has been retired by mistake, contact your Group Coordinator to have it unretired.',
  TRUE
);

INSERT INTO kb_articles (category_id, title, body, is_published) VALUES (
  (SELECT category_id FROM kb_categories WHERE name = 'Bait Stations'),
  'What is a bait station?',
  'A bait station is a device used to deliver poison bait to target pest species such as rats, mice, and possums.

In Tiaki, bait stations are organised into Bait Station Lines (separate from Trap Lines). Each bait station has:
- A unique code
- A type (e.g. Philproof, Protecta EVO Edge, Timms, etc.)
- GPS coordinates
- An active or retired status

Operators assigned to a bait station line can submit bait records each time they service a station.',
  TRUE
);

INSERT INTO kb_articles (category_id, title, body, is_published) VALUES (
  (SELECT category_id FROM kb_categories WHERE name = 'Bait Stations'),
  'How do I add a bait record?',
  'To record a bait station service visit:

1. Click "Add Bait Record" in the navigation (Operator role required).
2. Select the line and station you serviced.
3. Fill in the required fields:
   - Date of visit
   - Target species (e.g. Rats, Mice, Possums)
   - Active ingredient (e.g. Brodifacoum, Cyanide)
   - Formulation (e.g. Block, Pellet)
   - Concentration (%)
   - Bait remaining (kg)
4. Optionally record bait removed and bait added.
5. Add any notes and click Submit.

You can only add bait records for stations on lines you have been assigned to.',
  TRUE
);

INSERT INTO kb_articles (category_id, title, body, is_published) VALUES (
  (SELECT category_id FROM kb_categories WHERE name = 'Records'),
  'How do I add a catch record?',
  'To record a catch from a trap:

1. Click "Add Catch Record" in the navigation (Operator role required).
2. Select the trap line and the specific trap.
3. Fill in the required fields:
   - Date
   - Species caught
   - Rebaited? (Yes / No)
   - Bait type
   - Trap condition
   - Number of strikes
4. Optionally record sex, maturity, and notes.
5. Click Submit to save the record.

You can only record catches for traps on lines you have been assigned to. If you cannot see your assigned line, contact your Group Coordinator.',
  TRUE
);

INSERT INTO kb_articles (category_id, title, body, is_published) VALUES (
  (SELECT category_id FROM kb_categories WHERE name = 'Records'),
  'How do I view my catch records?',
  'To review the records you have submitted:

1. Click "My Catch Records" in the navigation.
2. Your records are listed in reverse chronological order.
3. Use the filter controls at the top to narrow by date range, species, or line.

To see all records across the group (not just yours), click "Catch Records" in the navigation instead.',
  TRUE
);

INSERT INTO kb_articles (category_id, title, body, is_published) VALUES (
  (SELECT category_id FROM kb_categories WHERE name = 'Records'),
  'How do I export data?',
  'Group Coordinators and Super Admins can export catch data as a CSV file compatible with trap.nz.

1. Go to Reports & Charts in the navigation.
2. Scroll to the export section.
3. Select the date range and any filters you want to apply.
4. Click "Export CSV" to download the file.

The CSV includes all catch records for your group within the selected period, formatted for import into trap.nz.',
  TRUE
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
SELECT setval('support_tickets_ticket_id_seq',              (SELECT MAX(ticket_id)         FROM support_tickets));
SELECT setval('ticket_replies_reply_id_seq',                (SELECT MAX(reply_id)          FROM ticket_replies));
SELECT setval('ticket_status_history_history_id_seq',       (SELECT MAX(history_id)        FROM ticket_status_history));
SELECT setval('kb_categories_category_id_seq',              (SELECT MAX(category_id)       FROM kb_categories));
SELECT setval('kb_articles_article_id_seq',                 (SELECT MAX(article_id)        FROM kb_articles));

COMMIT;
