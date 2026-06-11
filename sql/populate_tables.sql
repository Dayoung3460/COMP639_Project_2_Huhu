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
-- Coordinates spread over realistic line distances (1.5-2km per
-- line, ~400-500m between traps), matching how predator-control
-- lines are actually laid out in the field rather than the dense
-- clusters used in the original seed.
-- ══════════════════════════════════════════════════════

INSERT INTO traps (code, trap_type, line_id, latitude, longitude, is_retired) VALUES
-- North Campus Trap Line — runs ~2km west-to-east along the north boundary
('NCT-01', 'DOC 200',        (SELECT line_id FROM lines WHERE name = 'North Campus Trap Line'), -43.637500, 172.460000, false),
('NCT-02', 'A24',            (SELECT line_id FROM lines WHERE name = 'North Campus Trap Line'), -43.637800, 172.465500, false),
('NCT-03', 'DOC 150',        (SELECT line_id FROM lines WHERE name = 'North Campus Trap Line'), -43.638200, 172.471000, false),
('NCT-04', 'Victor',         (SELECT line_id FROM lines WHERE name = 'North Campus Trap Line'), -43.637700, 172.476500, false),
('NCT-05', 'Rat trap',       (SELECT line_id FROM lines WHERE name = 'North Campus Trap Line'), -43.637300, 172.482000, false),
-- South Campus Trap Line — runs ~1.7km along the southern boundary
('SCT-01', 'DOC 200',        (SELECT line_id FROM lines WHERE name = 'South Campus Trap Line'), -43.655500, 172.461500, false),
('SCT-02', 'A24',            (SELECT line_id FROM lines WHERE name = 'South Campus Trap Line'), -43.656000, 172.467500, false),
('SCT-03', 'Trapinator',     (SELECT line_id FROM lines WHERE name = 'South Campus Trap Line'), -43.656300, 172.473500, false),
('SCT-04', 'DOC 250',        (SELECT line_id FROM lines WHERE name = 'South Campus Trap Line'), -43.655800, 172.479500, false),
-- Lake Edge Trap Line — curves ~2km south-east around the water margin
('LET-01', 'DOC 200',        (SELECT line_id FROM lines WHERE name = 'Lake Edge Trap Line'),    -43.645000, 172.450000, false),
('LET-02', 'A24',            (SELECT line_id FROM lines WHERE name = 'Lake Edge Trap Line'),    -43.648500, 172.453000, false),
('LET-03', 'Flipping Timmy', (SELECT line_id FROM lines WHERE name = 'Lake Edge Trap Line'),    -43.652000, 172.456500, false),
('LET-04', 'T-Rex Rat Trap', (SELECT line_id FROM lines WHERE name = 'Lake Edge Trap Line'),    -43.655500, 172.460000, false),
('LET-05', 'Victor',         (SELECT line_id FROM lines WHERE name = 'Lake Edge Trap Line'),    -43.658000, 172.465500, false),
-- Research Farm Trap Line — runs ~1.2km north-to-south across the farm
('RFT-01', 'DOC 200',        (SELECT line_id FROM lines WHERE name = 'Research Farm Trap Line'),-43.660000, 172.475000, false),
('RFT-02', 'A24',            (SELECT line_id FROM lines WHERE name = 'Research Farm Trap Line'),-43.663500, 172.474800, false),
('RFT-03', 'DOC 150',        (SELECT line_id FROM lines WHERE name = 'Research Farm Trap Line'),-43.667000, 172.475500, false),
('RFT-04', 'Victor',         (SELECT line_id FROM lines WHERE name = 'Research Farm Trap Line'),-43.670500, 172.475000, false),
-- Central City Trap Line (CCT) — ~1km diagonal through urban green corridor
('CCT-01', 'DOC 200',        (SELECT line_id FROM lines WHERE name = 'Central City Trap Line'), -43.530000, 172.633000, false),
('CCT-02', 'A24',            (SELECT line_id FROM lines WHERE name = 'Central City Trap Line'), -43.532000, 172.638500, false),
('CCT-03', 'Rat trap',       (SELECT line_id FROM lines WHERE name = 'Central City Trap Line'), -43.534000, 172.644000, false),
-- Peninsula Ridge Line (BP) — ~1.6km south-east along the ridge spine
('PRL-01', 'DOC 200',        (SELECT line_id FROM lines WHERE name = 'Peninsula Ridge Line'),   -43.753000, 172.927000, false),
('PRL-02', 'DOC 250',        (SELECT line_id FROM lines WHERE name = 'Peninsula Ridge Line'),   -43.757500, 172.932500, false),
('PRL-03', 'A24',            (SELECT line_id FROM lines WHERE name = 'Peninsula Ridge Line'),   -43.762000, 172.938000, false)
ON CONFLICT (code) DO NOTHING;

-- Retired line traps — Old Boundary Track ran along the former NW edge
INSERT INTO traps (code, trap_type, line_id, latitude, longitude, is_retired, retired_at, retired_by) VALUES
('OBT-01', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Old Boundary Track'), -43.640000, 172.455000, true, '2025-06-01 10:00:00', (SELECT user_id FROM users WHERE username = 'smitchell')),
('OBT-02', 'A24',     (SELECT line_id FROM lines WHERE name = 'Old Boundary Track'), -43.645000, 172.458500, true, '2025-06-01 10:00:00', (SELECT user_id FROM users WHERE username = 'smitchell'))
ON CONFLICT (code) DO NOTHING;

-- ══════════════════════════════════════════════════════
-- BAIT STATIONS
-- ══════════════════════════════════════════════════════

INSERT INTO bait_stations (code, station_type, line_id, latitude, longitude, is_retired) VALUES
-- North Bait Station Line (PFLU) — runs ~1.6km parallel and just south of NCT
('NBS-01', 'Philproof',   (SELECT line_id FROM lines WHERE name = 'North Bait Station Line'), -43.639200, 172.460500, false),
('NBS-02', 'Protecta LP', (SELECT line_id FROM lines WHERE name = 'North Bait Station Line'), -43.639500, 172.466000, false),
('NBS-03', 'Nara',        (SELECT line_id FROM lines WHERE name = 'North Bait Station Line'), -43.639800, 172.471500, false),
-- South Bait Station Line (PFLU) — runs ~1.5km parallel and just north of SCT
('SBS-01', 'Philproof',   (SELECT line_id FROM lines WHERE name = 'South Bait Station Line'), -43.653500, 172.462000, false),
('SBS-02', 'Protecta LP', (SELECT line_id FROM lines WHERE name = 'South Bait Station Line'), -43.654000, 172.468000, false),
('SBS-03', 'Nara',        (SELECT line_id FROM lines WHERE name = 'South Bait Station Line'), -43.654300, 172.474000, false),
-- Hagley Park Bait Line (CCT) — ~700m diagonal across Hagley Park
('HPS-01', 'Philproof',   (SELECT line_id FROM lines WHERE name = 'Hagley Park Bait Line'),   -43.525500, 172.622500, false),
('HPS-02', 'Nara',        (SELECT line_id FROM lines WHERE name = 'Hagley Park Bait Line'),   -43.529500, 172.628500, false)
ON CONFLICT (code) DO NOTHING;

-- Station with type 'Other' requires other_type — separate insert.
-- Sits at the far east end of the North Bait Station Line.
INSERT INTO bait_stations (code, station_type, other_type, line_id, latitude, longitude, is_retired) VALUES
('NBS-04', 'Other', 'Repurposed biscuit tin bait box',
 (SELECT line_id FROM lines WHERE name = 'North Bait Station Line'), -43.640100, 172.477000, false)
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
('2024-03-12 07:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Predator sighting',     'Stoat spotted near north campus fence line at dawn.',         -43.637800, 172.466000, (SELECT line_id FROM lines WHERE name = 'North Campus Trap Line')),
('2024-05-18 08:00:00', (SELECT user_id FROM users WHERE username = 'fgrant'),  'Predator tracks',       'Possum tracks in mud on south campus path after rain.',       -43.656000, 172.467500, (SELECT line_id FROM lines WHERE name = 'South Campus Trap Line')),
('2024-07-14 09:00:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'Native species tracks', 'Pūkeko tracks along lake edge — good habitat indicator.',     -43.651000, 172.455500, (SELECT line_id FROM lines WHERE name = 'Lake Edge Trap Line')),
('2024-09-22 08:15:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Bird sighting',         'Morepork heard calling near north campus at dusk.',           -43.638000, 172.471000, (SELECT line_id FROM lines WHERE name = 'North Campus Trap Line')),
('2024-11-10 07:45:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'Predator sighting',     'Rat observed entering grain store at research farm.',         -43.663500, 172.474900, (SELECT line_id FROM lines WHERE name = 'Research Farm Trap Line')),
('2025-01-20 09:30:00', (SELECT user_id FROM users WHERE username = 'fgrant'),  'Native species sign',   'Gecko sheltering under south campus trap cover — positive.',  -43.656200, 172.473500, (SELECT line_id FROM lines WHERE name = 'South Campus Trap Line')),
('2025-03-05 08:00:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'Bird sighting',         'Kererū pair feeding in willows along lake edge.',             -43.654800, 172.459800, (SELECT line_id FROM lines WHERE name = 'Lake Edge Trap Line')),
('2025-05-28 07:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Predator tracks',       'Fresh rat burrows found near north bait station NBS-03.',     -43.639800, 172.471500, (SELECT line_id FROM lines WHERE name = 'North Bait Station Line')),
('2025-07-15 09:00:00', (SELECT user_id FROM users WHERE username = 'hpatel'),  'Predator sighting',     'Rat running along central city wall at dusk.',                -43.532000, 172.638500, (SELECT line_id FROM lines WHERE name = 'Central City Trap Line')),
('2025-09-08 08:30:00', (SELECT user_id FROM users WHERE username = 'fgrant'),  'Other',                 'Trap cover damaged by livestock — repaired on site.',         -43.655700, 172.470500, (SELECT line_id FROM lines WHERE name = 'South Campus Trap Line')),
('2025-11-22 07:45:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'Bird sighting',         'Pied stilt pair nesting near lake — pair bonded.',            -43.655500, 172.460200, (SELECT line_id FROM lines WHERE name = 'Lake Edge Trap Line')),
('2026-01-14 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'),    'Predator sighting',     'Stoat with prey item crossing peninsula ridge at midday.',    -43.757500, 172.932500, (SELECT line_id FROM lines WHERE name = 'Peninsula Ridge Line')),
('2026-03-28 08:00:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Native species sign',   'Skink tracks near north bait line — positive recovery sign.', -43.639500, 172.466000, (SELECT line_id FROM lines WHERE name = 'North Bait Station Line')),
('2026-04-15 09:30:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'Predator tracks',       'Fresh stoat prints on tracking card near research farm trap.',-43.666900, 172.475500, (SELECT line_id FROM lines WHERE name = 'Research Farm Trap Line'))

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
-- KNOWLEDGE HUB — category seed
-- (merged from the old group_updates_hub_migration.sql)
-- ══════════════════════════════════════════════════════

INSERT INTO knowledge_categories (slug, name, description, display_order)
VALUES
    ('trap-management',  'Trap management',  'Setting, maintaining, and inspecting traps.', 1),
    ('bait-stations',    'Bait stations',    'Bait choice, monitoring, and safe handling.', 2),
    ('seasonal-advice',  'Seasonal advice',  'Strategy that changes with the seasons.',     3),
    ('species-id',       'Species ID',       'Identifying captures and signs.',             4),
    ('safety',           'Safety',           'Personal and animal-welfare guidance.',       5)
ON CONFLICT (slug) DO NOTHING;


-- ══════════════════════════════════════════════════════
-- ANALYTICS & RECORDS — extended seed data (merged from seed_data.sql)
-- Adds ~440 trap catches + bait records with seasonal variation
-- (higher rates in autumn/winter) for analytics-realistic data.
-- ══════════════════════════════════════════════════════

-- ── TRAP CATCHES (440 records)

INSERT INTO trap_catches
    (trap_id, date, recorded_by_id, species_caught, sex, maturity,
     status, rebaited, bait_type, bait_details, trap_condition, strikes, notes)
VALUES
    ((SELECT trap_id FROM traps WHERE code='NCT-01'), '2024-01-11 09:15:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', NULL, 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-01'), '2024-03-03 10:02:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Chicken', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-01'), '2024-04-07 10:14:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-01'), '2024-05-25 08:13:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Other', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-01'), '2024-07-02 09:38:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Rabbit', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-01'), '2024-08-09 10:05:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Lure', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-01'), '2024-10-02 09:36:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-01'), '2024-11-08 08:49:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-01'), '2024-12-21 09:10:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-01'), '2025-01-31 07:38:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Chicken', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-01'), '2025-03-14 10:17:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Other', NULL, 'Juvenile', 'Sprung', 'Yes', 'Chicken', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-01'), '2025-05-09 07:14:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Hedgehog', 'Female', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-01'), '2025-06-19 09:13:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Rabbit', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-01'), '2025-08-13 09:08:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', NULL, 'Juvenile', 'Sprung', 'Yes', 'Chocolate', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-01'), '2025-10-05 10:23:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-01'), '2025-11-25 07:55:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-01'), '2026-01-19 10:38:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Rabbit', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-01'), '2026-03-03 07:43:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Lure', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-02'), '2024-01-13 09:07:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-02'), '2024-02-22 09:32:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Needs maintenance', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-02'), '2024-03-31 09:53:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Chicken', NULL, 'Needs maintenance', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-02'), '2024-05-11 08:34:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Other', NULL, 'Adult', 'Sprung', 'Yes', 'Chicken', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-02'), '2024-06-30 09:56:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Other', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-02'), '2024-08-22 07:46:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-02'), '2024-10-13 08:42:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'Needs maintenance', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-02'), '2024-11-22 10:13:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Other', NULL, 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-02'), '2025-01-05 09:28:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Egg', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-02'), '2025-02-16 09:01:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Mouse', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-02'), '2025-03-25 07:14:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-02'), '2025-05-09 08:17:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Possum', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-02'), '2025-07-01 08:50:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-02'), '2025-08-26 10:26:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Mouse', NULL, 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-02'), '2025-10-20 10:46:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Mouse', 'Male', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-02'), '2025-12-11 10:11:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-02'), '2026-01-22 07:28:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Egg', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-02'), '2026-03-18 07:05:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-03'), '2024-01-08 10:57:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-03'), '2024-02-24 10:16:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Other', 'Female', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-03'), '2024-04-16 10:09:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-03'), '2024-05-27 07:47:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-03'), '2024-07-02 08:03:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Other', 'Male', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-03'), '2024-08-08 08:25:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Needs maintenance', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-03'), '2024-09-19 07:39:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-03'), '2024-11-14 09:59:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-03'), '2025-01-09 08:16:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-03'), '2025-03-06 10:20:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-03'), '2025-04-24 07:04:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Chicken', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-03'), '2025-06-06 09:56:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-03'), '2025-07-25 09:39:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Egg', NULL, 'Needs maintenance', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-03'), '2025-09-19 09:59:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Peanut butter', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-03'), '2025-11-01 07:47:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Chicken', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-03'), '2025-12-16 09:32:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Mouse', 'Male', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-03'), '2026-01-28 09:49:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-03'), '2026-03-21 07:07:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-04'), '2024-01-09 09:37:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-04'), '2024-02-24 07:57:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-04'), '2024-04-20 07:22:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Weasel', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-04'), '2024-06-01 08:56:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-04'), '2024-07-11 09:50:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rabbit', NULL, 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-04'), '2024-08-20 07:24:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-04'), '2024-10-01 10:22:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Mouse', 'Male', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-04'), '2024-11-11 09:55:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-04'), '2024-12-27 10:43:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Egg', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-04'), '2025-02-03 09:11:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Egg', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-04'), '2025-03-13 09:46:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-04'), '2025-05-06 07:24:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Chocolate', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-04'), '2025-06-11 07:33:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rabbit', NULL, 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-04'), '2025-08-06 10:04:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Other', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Chocolate', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-04'), '2025-09-13 09:32:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-04'), '2025-10-31 09:35:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Rabbit', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-04'), '2025-12-10 09:25:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Chocolate', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-04'), '2026-01-23 09:29:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Mouse', NULL, 'Adult', 'Sprung', 'Yes', 'Chicken', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-04'), '2026-03-04 09:32:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Chicken', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-05'), '2024-01-02 08:43:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-05'), '2024-02-12 07:15:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Other', NULL, 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-05'), '2024-04-07 10:31:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Stoat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-05'), '2024-05-15 08:11:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Rabbit', NULL, 'Needs maintenance', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-05'), '2024-06-20 07:29:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Chicken', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-05'), '2024-08-13 10:39:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Hedgehog', NULL, 'Adult', 'Sprung', 'Yes', 'Chicken', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-05'), '2024-09-22 10:28:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-05'), '2024-11-16 10:40:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-05'), '2024-12-28 09:57:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Peanut butter', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-05'), '2025-02-05 08:45:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-05'), '2025-03-26 08:53:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Stoat', NULL, 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-05'), '2025-05-12 09:19:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Weasel', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-05'), '2025-07-03 08:31:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-05'), '2025-08-17 10:46:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-05'), '2025-09-25 07:58:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'Needs maintenance', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-05'), '2025-11-17 07:41:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-05'), '2026-01-05 09:24:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-05'), '2026-02-17 10:16:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='NCT-05'), '2026-03-24 07:22:00', (SELECT user_id FROM users WHERE username='enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-01'), '2024-01-13 07:48:00', (SELECT user_id FROM users WHERE username='fgrant'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-01'), '2024-02-23 08:15:00', (SELECT user_id FROM users WHERE username='fgrant'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-01'), '2024-04-19 08:29:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Chicken', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-01'), '2024-05-27 08:19:00', (SELECT user_id FROM users WHERE username='fgrant'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Needs maintenance', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-01'), '2024-07-01 10:25:00', (SELECT user_id FROM users WHERE username='fgrant'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Egg', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-01'), '2024-08-23 08:06:00', (SELECT user_id FROM users WHERE username='fgrant'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Lure', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-01'), '2024-10-16 07:22:00', (SELECT user_id FROM users WHERE username='fgrant'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Lure', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-01'), '2024-12-01 09:00:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Hedgehog', 'Female', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-01'), '2025-01-25 10:45:00', (SELECT user_id FROM users WHERE username='fgrant'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-01'), '2025-03-06 09:39:00', (SELECT user_id FROM users WHERE username='fgrant'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Rabbit', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-01'), '2025-04-23 09:20:00', (SELECT user_id FROM users WHERE username='fgrant'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-01'), '2025-06-05 08:48:00', (SELECT user_id FROM users WHERE username='fgrant'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'Needs maintenance', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-01'), '2025-07-29 09:01:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-01'), '2025-09-13 09:17:00', (SELECT user_id FROM users WHERE username='fgrant'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Chocolate', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-01'), '2025-11-04 08:05:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Chicken', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-01'), '2025-12-24 10:28:00', (SELECT user_id FROM users WHERE username='fgrant'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-01'), '2026-02-06 08:19:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Chicken', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-01'), '2026-03-24 09:22:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-02'), '2024-01-12 07:47:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Mouse', NULL, 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-02'), '2024-03-02 09:06:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Hedgehog', 'Female', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-02'), '2024-04-15 08:17:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Chocolate', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-02'), '2024-05-24 10:06:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Hedgehog', NULL, 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-02'), '2024-07-12 07:16:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Other', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-02'), '2024-08-31 07:09:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', NULL, 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-02'), '2024-10-08 10:38:00', (SELECT user_id FROM users WHERE username='fgrant'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Peanut butter', NULL, 'Needs maintenance', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-02'), '2024-11-28 10:19:00', (SELECT user_id FROM users WHERE username='fgrant'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Chocolate', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-02'), '2025-01-20 07:48:00', (SELECT user_id FROM users WHERE username='fgrant'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-02'), '2025-03-02 07:10:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', NULL, 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-02'), '2025-04-19 10:18:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Chocolate', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-02'), '2025-06-07 08:59:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', NULL, 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-02'), '2025-07-25 08:41:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-02'), '2025-09-03 09:28:00', (SELECT user_id FROM users WHERE username='fgrant'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-02'), '2025-10-17 09:32:00', (SELECT user_id FROM users WHERE username='fgrant'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Rabbit', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-02'), '2025-11-23 10:47:00', (SELECT user_id FROM users WHERE username='fgrant'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'Needs maintenance', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-02'), '2026-01-05 08:43:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Hedgehog', NULL, 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-02'), '2026-02-17 08:30:00', (SELECT user_id FROM users WHERE username='fgrant'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Rabbit', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-03'), '2024-01-03 10:40:00', (SELECT user_id FROM users WHERE username='fgrant'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-03'), '2024-02-22 09:20:00', (SELECT user_id FROM users WHERE username='fgrant'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Peanut butter', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-03'), '2024-04-07 10:18:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Possum', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-03'), '2024-05-14 09:07:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Other', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-03'), '2024-07-05 07:12:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Mouse', NULL, 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-03'), '2024-08-10 08:59:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Stoat', NULL, 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-03'), '2024-10-04 08:45:00', (SELECT user_id FROM users WHERE username='fgrant'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-03'), '2024-11-25 10:05:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-03'), '2025-01-03 09:32:00', (SELECT user_id FROM users WHERE username='fgrant'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Rabbit', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-03'), '2025-02-22 08:29:00', (SELECT user_id FROM users WHERE username='fgrant'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Rabbit', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-03'), '2025-04-04 08:55:00', (SELECT user_id FROM users WHERE username='fgrant'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-03'), '2025-05-22 09:52:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', NULL, 'Adult', 'Sprung', 'Yes', 'Chicken', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-03'), '2025-07-17 08:28:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Chicken', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-03'), '2025-09-02 09:55:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', NULL, 'Adult', 'Sprung', 'Yes', 'Chicken', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-03'), '2025-10-14 10:02:00', (SELECT user_id FROM users WHERE username='fgrant'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-03'), '2025-12-03 10:24:00', (SELECT user_id FROM users WHERE username='fgrant'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Peanut butter', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-03'), '2026-01-22 08:32:00', (SELECT user_id FROM users WHERE username='fgrant'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Egg', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-03'), '2026-03-12 10:00:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Weasel', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-04'), '2024-01-13 09:39:00', (SELECT user_id FROM users WHERE username='fgrant'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Lure', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-04'), '2024-02-19 10:20:00', (SELECT user_id FROM users WHERE username='fgrant'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Rabbit', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-04'), '2024-04-11 07:15:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-04'), '2024-05-29 07:28:00', (SELECT user_id FROM users WHERE username='fgrant'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-04'), '2024-07-12 07:20:00', (SELECT user_id FROM users WHERE username='fgrant'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-04'), '2024-08-27 08:15:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Mouse', NULL, 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-04'), '2024-10-06 10:39:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Stoat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-04'), '2024-11-24 10:16:00', (SELECT user_id FROM users WHERE username='fgrant'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Rabbit', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-04'), '2025-01-07 08:04:00', (SELECT user_id FROM users WHERE username='fgrant'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-04'), '2025-03-01 10:44:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-04'), '2025-04-08 09:36:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Stoat', NULL, 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-04'), '2025-05-25 07:58:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-04'), '2025-07-10 08:39:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', NULL, 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-04'), '2025-09-03 07:19:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Hedgehog', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Chocolate', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-04'), '2025-10-12 09:20:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Possum', 'Male', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-04'), '2025-11-27 09:53:00', (SELECT user_id FROM users WHERE username='fgrant'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-04'), '2026-01-16 09:47:00', (SELECT user_id FROM users WHERE username='fgrant'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='SCT-04'), '2026-03-06 08:48:00', (SELECT user_id FROM users WHERE username='fgrant'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-01'), '2024-01-07 09:05:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-01'), '2024-02-19 10:23:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Lure', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-01'), '2024-04-02 09:06:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Chicken', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-01'), '2024-05-17 08:41:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-01'), '2024-07-05 09:41:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-01'), '2024-08-13 07:19:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Other', 'Male', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-01'), '2024-09-21 09:42:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Other', NULL, 'Juvenile', 'Sprung', 'Yes', 'Rabbit', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-01'), '2024-10-30 07:53:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'Needs maintenance', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-01'), '2024-12-17 09:02:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Peanut butter', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-01'), '2025-02-04 08:54:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-01'), '2025-04-01 09:03:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-01'), '2025-05-27 07:03:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Weasel', 'Male', 'Adult', 'Sprung', 'Yes', 'Chicken', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-01'), '2025-07-03 08:37:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-01'), '2025-08-17 07:17:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-01'), '2025-10-08 08:07:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-01'), '2025-11-19 07:11:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-01'), '2025-12-28 07:47:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-01'), '2026-02-15 07:28:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Chicken', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-01'), '2026-03-23 09:29:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Egg', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-02'), '2024-01-14 07:31:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Egg', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-02'), '2024-02-20 08:04:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-02'), '2024-04-14 09:24:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Chocolate', NULL, 'Needs maintenance', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-02'), '2024-06-02 10:06:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Weasel', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-02'), '2024-07-13 08:26:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-02'), '2024-08-20 09:42:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Rat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-02'), '2024-09-26 07:27:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-02'), '2024-11-11 07:37:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Chocolate', NULL, 'Needs maintenance', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-02'), '2025-01-06 09:55:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Stoat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-02'), '2025-03-01 07:36:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Mouse', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-02'), '2025-04-08 09:07:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Weasel', NULL, 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-02'), '2025-06-01 07:38:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Rabbit', NULL, 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-02'), '2025-07-14 09:58:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-02'), '2025-09-08 08:47:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Possum', 'Male', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-02'), '2025-10-19 10:21:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Rat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Chocolate', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-02'), '2025-12-12 07:09:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Rat', NULL, 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-02'), '2026-01-24 10:31:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Rabbit', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-02'), '2026-03-08 07:22:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Mouse', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-03'), '2024-01-09 07:14:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'Needs maintenance', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-03'), '2024-02-14 09:13:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-03'), '2024-03-20 10:11:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-03'), '2024-05-11 09:04:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Stoat', NULL, 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-03'), '2024-06-29 09:36:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'Needs maintenance', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-03'), '2024-08-15 10:18:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-03'), '2024-09-19 08:51:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Lure', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-03'), '2024-11-04 07:15:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Mouse', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-03'), '2024-12-18 08:21:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-03'), '2025-02-07 08:57:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-03'), '2025-04-03 08:06:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-03'), '2025-05-14 08:48:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Weasel', 'Male', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-03'), '2025-07-02 10:43:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Rabbit', NULL, 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-03'), '2025-08-16 09:09:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-03'), '2025-10-05 09:50:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'Needs maintenance', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-03'), '2025-11-10 07:19:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-03'), '2025-12-16 09:04:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Stoat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Chicken', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-03'), '2026-02-01 07:28:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Peanut butter', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-03'), '2026-03-18 08:03:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-04'), '2024-01-12 08:02:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Chicken', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-04'), '2024-03-06 09:58:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-04'), '2024-04-11 09:04:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-04'), '2024-06-02 09:16:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Possum', NULL, 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-04'), '2024-07-09 08:58:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Stoat', NULL, 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-04'), '2024-08-17 07:19:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Mouse', NULL, 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-04'), '2024-10-12 07:41:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Chicken', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-04'), '2024-11-27 09:11:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Other', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-04'), '2025-01-05 09:54:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Possum', NULL, 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-04'), '2025-02-10 08:38:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-04'), '2025-03-22 08:46:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-04'), '2025-05-03 09:48:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Peanut butter', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-04'), '2025-06-24 10:57:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Hedgehog', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Chicken', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-04'), '2025-08-12 10:32:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Peanut butter', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-04'), '2025-09-22 08:55:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-04'), '2025-11-16 09:35:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-04'), '2026-01-06 09:05:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-04'), '2026-02-24 08:53:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-05'), '2024-01-14 09:59:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-05'), '2024-02-19 09:15:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-05'), '2024-04-05 09:59:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Rat', NULL, 'Juvenile', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-05'), '2024-05-14 10:44:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Hedgehog', NULL, 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-05'), '2024-06-18 07:16:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-05'), '2024-08-09 10:07:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-05'), '2024-09-22 08:26:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Possum', NULL, 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-05'), '2024-11-11 07:40:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Peanut butter', NULL, 'Needs maintenance', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-05'), '2024-12-20 07:39:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-05'), '2025-02-11 07:33:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-05'), '2025-04-03 07:24:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Rabbit', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-05'), '2025-05-16 09:50:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Rat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-05'), '2025-06-23 09:08:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Rat', NULL, 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-05'), '2025-08-18 10:40:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-05'), '2025-09-23 07:50:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-05'), '2025-11-09 10:16:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-05'), '2025-12-20 07:55:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Chocolate', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-05'), '2026-01-27 10:56:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='LET-05'), '2026-03-17 10:21:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-01'), '2024-01-06 09:51:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-01'), '2024-02-23 08:34:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-01'), '2024-04-07 10:10:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-01'), '2024-05-23 10:17:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Possum', 'Male', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-01'), '2024-07-09 08:01:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Rat', NULL, 'Juvenile', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-01'), '2024-08-17 09:23:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Stoat', NULL, 'Adult', 'Sprung', 'Yes', 'Chicken', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-01'), '2024-10-12 09:23:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-01'), '2024-12-04 09:25:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-01'), '2025-01-13 10:58:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Chocolate', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-01'), '2025-02-25 08:39:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-01'), '2025-04-16 08:54:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Rat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-01'), '2025-06-11 09:42:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-01'), '2025-07-18 09:57:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Rat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-01'), '2025-09-11 09:32:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-01'), '2025-10-16 09:29:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Hedgehog', NULL, 'Adult', 'Sprung', 'Yes', 'Chicken', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-01'), '2025-11-22 10:33:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-01'), '2026-01-14 09:41:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Rat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Chicken', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-01'), '2026-02-22 08:49:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-02'), '2024-01-15 07:33:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-02'), '2024-02-24 08:22:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Other', NULL, 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-02'), '2024-04-05 09:08:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Chicken', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-02'), '2024-05-27 08:37:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Other', 'Male', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-02'), '2024-07-20 07:52:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Hedgehog', 'Male', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-02'), '2024-09-01 10:39:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Rabbit', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-02'), '2024-10-26 09:30:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-02'), '2024-12-12 07:44:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-02'), '2025-01-30 10:13:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'Needs maintenance', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-02'), '2025-03-10 09:46:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Other', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-02'), '2025-04-30 09:15:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-02'), '2025-06-07 10:55:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Mouse', 'Male', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-02'), '2025-07-22 08:31:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Other', 'Female', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-02'), '2025-08-26 10:32:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Mouse', 'Male', 'Adult', 'Sprung', 'Yes', 'Chicken', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-02'), '2025-10-01 10:38:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Hedgehog', NULL, 'Juvenile', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-02'), '2025-11-22 07:27:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Rat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-02'), '2026-01-07 07:36:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Mouse', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-02'), '2026-02-23 09:52:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Chicken', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-03'), '2024-01-03 10:23:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'Needs maintenance', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-03'), '2024-02-18 08:38:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Chicken', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-03'), '2024-03-25 08:45:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Stoat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-03'), '2024-05-18 08:20:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Peanut butter', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-03'), '2024-07-04 09:37:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'Needs maintenance', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-03'), '2024-08-24 09:30:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Hedgehog', 'Female', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-03'), '2024-10-11 07:38:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-03'), '2024-12-05 08:46:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Needs maintenance', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-03'), '2025-01-24 10:09:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Hedgehog', 'Male', 'Adult', 'Sprung', 'Yes', 'Chicken', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-03'), '2025-03-03 10:20:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Stoat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-03'), '2025-04-23 10:55:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Egg', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-03'), '2025-06-01 09:42:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-03'), '2025-07-23 09:43:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Weasel', NULL, 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-03'), '2025-09-04 08:15:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'Needs maintenance', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-03'), '2025-10-18 09:49:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Rat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-03'), '2025-12-02 09:18:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Needs maintenance', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-03'), '2026-01-27 10:52:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-03'), '2026-03-12 07:22:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Rabbit', NULL, 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-04'), '2024-01-04 09:59:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Chocolate', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-04'), '2024-02-12 08:15:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Rat', NULL, 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-04'), '2024-03-19 09:45:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Mouse', NULL, 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-04'), '2024-04-28 10:30:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-04'), '2024-06-03 07:41:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Chicken', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-04'), '2024-07-09 08:26:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-04'), '2024-08-25 08:59:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Egg', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-04'), '2024-09-29 07:59:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Other', 'Female', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-04'), '2024-11-19 08:54:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Chocolate', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-04'), '2024-12-30 09:10:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Lure', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-04'), '2025-02-11 07:47:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-04'), '2025-04-05 08:11:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Rabbit', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-04'), '2025-05-23 07:25:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Possum', 'Male', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-04'), '2025-07-04 10:15:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-04'), '2025-08-26 09:44:00', (SELECT user_id FROM users WHERE username='gwatson'), 'Rat', NULL, 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-04'), '2025-10-05 09:44:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-04'), '2025-11-18 08:14:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-04'), '2025-12-27 09:26:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Rabbit', NULL, 'Needs maintenance', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='RFT-04'), '2026-02-17 08:48:00', (SELECT user_id FROM users WHERE username='gwatson'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-01'), '2024-01-14 10:33:00', (SELECT user_id FROM users WHERE username='hpatel'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Egg', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-01'), '2024-03-07 08:36:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Mouse', 'Male', 'Adult', 'Sprung', 'Yes', 'Chicken', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-01'), '2024-04-14 10:05:00', (SELECT user_id FROM users WHERE username='hpatel'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Egg', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-01'), '2024-06-02 10:29:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Mouse', NULL, 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-01'), '2024-07-07 07:47:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-01'), '2024-08-13 07:59:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rabbit', 'Female', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-01'), '2024-09-22 10:23:00', (SELECT user_id FROM users WHERE username='hpatel'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-01'), '2024-11-08 08:41:00', (SELECT user_id FROM users WHERE username='hpatel'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-01'), '2024-12-18 10:33:00', (SELECT user_id FROM users WHERE username='hpatel'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-01'), '2025-01-29 07:19:00', (SELECT user_id FROM users WHERE username='hpatel'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-01'), '2025-03-22 10:52:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-01'), '2025-05-02 07:02:00', (SELECT user_id FROM users WHERE username='hpatel'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Chicken', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-01'), '2025-06-06 07:06:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Mouse', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-01'), '2025-07-12 07:25:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Stoat', NULL, 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-01'), '2025-09-01 08:52:00', (SELECT user_id FROM users WHERE username='hpatel'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Chocolate', NULL, 'Needs maintenance', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-01'), '2025-10-24 09:15:00', (SELECT user_id FROM users WHERE username='hpatel'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-01'), '2025-12-19 10:19:00', (SELECT user_id FROM users WHERE username='hpatel'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-01'), '2026-02-09 08:40:00', (SELECT user_id FROM users WHERE username='hpatel'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Chicken', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-01'), '2026-03-31 09:41:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Possum', NULL, 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-02'), '2024-01-03 08:48:00', (SELECT user_id FROM users WHERE username='hpatel'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Peanut butter', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-02'), '2024-02-14 08:51:00', (SELECT user_id FROM users WHERE username='hpatel'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-02'), '2024-04-06 10:35:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-02'), '2024-05-21 10:54:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Stoat', NULL, 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-02'), '2024-07-03 07:55:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', NULL, 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-02'), '2024-08-13 09:19:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Other', 'Male', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-02'), '2024-09-20 10:58:00', (SELECT user_id FROM users WHERE username='hpatel'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-02'), '2024-11-13 10:58:00', (SELECT user_id FROM users WHERE username='hpatel'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Needs maintenance', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-02'), '2024-12-28 10:29:00', (SELECT user_id FROM users WHERE username='hpatel'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Chocolate', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-02'), '2025-02-10 10:29:00', (SELECT user_id FROM users WHERE username='hpatel'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-02'), '2025-04-01 09:58:00', (SELECT user_id FROM users WHERE username='hpatel'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-02'), '2025-05-16 08:47:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Chicken', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-02'), '2025-07-03 08:21:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', NULL, 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-02'), '2025-08-27 09:16:00', (SELECT user_id FROM users WHERE username='hpatel'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-02'), '2025-10-21 10:10:00', (SELECT user_id FROM users WHERE username='hpatel'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Peanut butter', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-02'), '2025-11-29 10:11:00', (SELECT user_id FROM users WHERE username='hpatel'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Egg', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-02'), '2026-01-19 07:52:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-02'), '2026-03-02 08:00:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-03'), '2024-01-11 10:42:00', (SELECT user_id FROM users WHERE username='hpatel'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-03'), '2024-02-15 10:00:00', (SELECT user_id FROM users WHERE username='hpatel'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Needs maintenance', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-03'), '2024-03-29 09:01:00', (SELECT user_id FROM users WHERE username='hpatel'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Lure', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-03'), '2024-05-16 08:06:00', (SELECT user_id FROM users WHERE username='hpatel'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Needs maintenance', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-03'), '2024-06-24 09:52:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-03'), '2024-08-12 08:19:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Possum', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-03'), '2024-09-18 10:35:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Mouse', NULL, 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-03'), '2024-10-25 10:41:00', (SELECT user_id FROM users WHERE username='hpatel'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'Needs maintenance', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-03'), '2024-12-02 07:14:00', (SELECT user_id FROM users WHERE username='hpatel'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-03'), '2025-01-24 07:59:00', (SELECT user_id FROM users WHERE username='hpatel'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-03'), '2025-03-08 07:11:00', (SELECT user_id FROM users WHERE username='hpatel'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-03'), '2025-04-18 10:59:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-03'), '2025-06-04 09:24:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Weasel', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-03'), '2025-07-25 09:03:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-03'), '2025-09-17 10:49:00', (SELECT user_id FROM users WHERE username='hpatel'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-03'), '2025-11-11 10:31:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', NULL, 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-03'), '2026-01-06 10:05:00', (SELECT user_id FROM users WHERE username='hpatel'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Peanut butter', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-03'), '2026-02-12 08:24:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Possum', NULL, 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='CCT-03'), '2026-03-29 07:00:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Other', 'Female', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-01'), '2024-01-02 10:35:00', (SELECT user_id FROM users WHERE username='dlee'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-01'), '2024-02-17 09:55:00', (SELECT user_id FROM users WHERE username='dlee'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-01'), '2024-04-01 07:46:00', (SELECT user_id FROM users WHERE username='dlee'), 'Rabbit', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Chicken', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-01'), '2024-05-27 08:17:00', (SELECT user_id FROM users WHERE username='dlee'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-01'), '2024-07-14 09:30:00', (SELECT user_id FROM users WHERE username='dlee'), 'Weasel', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-01'), '2024-09-07 08:29:00', (SELECT user_id FROM users WHERE username='dlee'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-01'), '2024-10-31 09:28:00', (SELECT user_id FROM users WHERE username='dlee'), 'Mouse', NULL, 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-01'), '2024-12-15 08:30:00', (SELECT user_id FROM users WHERE username='dlee'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-01'), '2025-01-31 09:47:00', (SELECT user_id FROM users WHERE username='dlee'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Rabbit', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-01'), '2025-03-25 09:24:00', (SELECT user_id FROM users WHERE username='dlee'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-01'), '2025-05-10 08:37:00', (SELECT user_id FROM users WHERE username='dlee'), 'Other', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Chicken', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-01'), '2025-06-28 08:28:00', (SELECT user_id FROM users WHERE username='dlee'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-01'), '2025-08-04 10:43:00', (SELECT user_id FROM users WHERE username='dlee'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-01'), '2025-09-28 09:42:00', (SELECT user_id FROM users WHERE username='dlee'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-01'), '2025-11-21 10:34:00', (SELECT user_id FROM users WHERE username='dlee'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Rabbit', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-01'), '2026-01-12 09:44:00', (SELECT user_id FROM users WHERE username='dlee'), 'Hedgehog', NULL, 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-01'), '2026-02-19 09:10:00', (SELECT user_id FROM users WHERE username='dlee'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Egg', NULL, 'Needs maintenance', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-02'), '2024-01-11 10:48:00', (SELECT user_id FROM users WHERE username='dlee'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-02'), '2024-02-18 09:14:00', (SELECT user_id FROM users WHERE username='dlee'), 'Mouse', NULL, 'Juvenile', 'Sprung', 'Yes', 'Chicken', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-02'), '2024-04-11 09:25:00', (SELECT user_id FROM users WHERE username='dlee'), 'Mouse', NULL, 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-02'), '2024-05-20 07:30:00', (SELECT user_id FROM users WHERE username='dlee'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-02'), '2024-06-28 09:29:00', (SELECT user_id FROM users WHERE username='dlee'), 'Weasel', NULL, 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-02'), '2024-08-05 10:20:00', (SELECT user_id FROM users WHERE username='dlee'), 'Rat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-02'), '2024-09-19 08:59:00', (SELECT user_id FROM users WHERE username='dlee'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Chicken', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-02'), '2024-10-29 09:35:00', (SELECT user_id FROM users WHERE username='dlee'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-02'), '2024-12-10 08:11:00', (SELECT user_id FROM users WHERE username='dlee'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Rabbit', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-02'), '2025-01-26 08:28:00', (SELECT user_id FROM users WHERE username='dlee'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-02'), '2025-03-08 07:36:00', (SELECT user_id FROM users WHERE username='dlee'), 'Rat', NULL, 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-02'), '2025-04-18 09:42:00', (SELECT user_id FROM users WHERE username='dlee'), 'Rabbit', NULL, 'Juvenile', 'Sprung', 'Yes', 'Chocolate', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-02'), '2025-06-04 07:22:00', (SELECT user_id FROM users WHERE username='dlee'), 'Stoat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-02'), '2025-07-18 07:43:00', (SELECT user_id FROM users WHERE username='dlee'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-02'), '2025-08-25 07:11:00', (SELECT user_id FROM users WHERE username='dlee'), 'Stoat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-02'), '2025-10-18 10:27:00', (SELECT user_id FROM users WHERE username='dlee'), 'Rat', NULL, 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-02'), '2025-11-27 10:18:00', (SELECT user_id FROM users WHERE username='dlee'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-02'), '2026-01-11 07:55:00', (SELECT user_id FROM users WHERE username='dlee'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-02'), '2026-03-02 10:35:00', (SELECT user_id FROM users WHERE username='dlee'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-03'), '2024-01-12 10:10:00', (SELECT user_id FROM users WHERE username='dlee'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Needs maintenance', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-03'), '2024-02-16 08:18:00', (SELECT user_id FROM users WHERE username='dlee'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-03'), '2024-03-29 08:49:00', (SELECT user_id FROM users WHERE username='dlee'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'Needs maintenance', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-03'), '2024-05-18 07:36:00', (SELECT user_id FROM users WHERE username='dlee'), 'Rat', NULL, 'Adult', 'Sprung', 'Yes', 'Chicken', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-03'), '2024-07-06 10:06:00', (SELECT user_id FROM users WHERE username='dlee'), 'Possum', NULL, 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-03'), '2024-08-24 07:28:00', (SELECT user_id FROM users WHERE username='dlee'), 'Rabbit', 'Male', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-03'), '2024-10-16 10:10:00', (SELECT user_id FROM users WHERE username='dlee'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Peanut butter', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-03'), '2024-11-26 09:34:00', (SELECT user_id FROM users WHERE username='dlee'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'Needs maintenance', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-03'), '2025-01-17 09:18:00', (SELECT user_id FROM users WHERE username='dlee'), 'Mouse', NULL, 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-03'), '2025-03-06 09:55:00', (SELECT user_id FROM users WHERE username='dlee'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Lure', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-03'), '2025-04-14 09:53:00', (SELECT user_id FROM users WHERE username='dlee'), 'Rat', NULL, 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-03'), '2025-06-06 10:24:00', (SELECT user_id FROM users WHERE username='dlee'), 'Stoat', NULL, 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'Needs maintenance', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-03'), '2025-07-19 09:29:00', (SELECT user_id FROM users WHERE username='dlee'), 'Other', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'Repaired', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-03'), '2025-08-25 10:40:00', (SELECT user_id FROM users WHERE username='dlee'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Chocolate', NULL, 'Repaired', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-03'), '2025-10-01 10:13:00', (SELECT user_id FROM users WHERE username='dlee'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-03'), '2025-11-20 09:21:00', (SELECT user_id FROM users WHERE username='dlee'), 'Mouse', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-03'), '2026-01-15 07:06:00', (SELECT user_id FROM users WHERE username='dlee'), 'None', NULL, NULL, 'Still set, bait missing', 'Yes', 'Egg', NULL, 'OK', 0, NULL),
    ((SELECT trap_id FROM traps WHERE code='PRL-03'), '2026-02-22 08:28:00', (SELECT user_id FROM users WHERE username='dlee'), 'None', NULL, NULL, 'Still set, bait bad', 'No', 'None', NULL, 'OK', 0, NULL)
ON CONFLICT DO NOTHING;

-- ══════════════════════════════════════════════════════
-- BAIT STATION RECORDS (138 records)
-- ══════════════════════════════════════════════════════

INSERT INTO bait_station_records
    (station_id, date, recorded_by_id, target_species, active_ingredient,
     formulation, concentration, bait_remaining, bait_removed, bait_added, notes)
VALUES
    ((SELECT station_id FROM bait_stations WHERE code='NBS-01'), '2024-01-07 09:05:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 433.023, NULL, 95.28, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-01'), '2024-03-09 07:25:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 453.073, 13.29, 147.337, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-01'), '2024-05-10 07:45:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 489.859, NULL, 85.122, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-01'), '2024-06-24 08:33:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 494.872, NULL, 69.905, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-01'), '2024-08-26 10:44:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 483.622, 6.871, 68.089, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-01'), '2024-10-11 07:06:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 507.826, NULL, 63.4, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-01'), '2024-12-02 08:41:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 532.848, NULL, 107.408, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-01'), '2025-02-03 08:28:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 613.113, NULL, 51.271, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-01'), '2025-03-28 10:39:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 563.814, NULL, 72.706, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-01'), '2025-05-30 08:48:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 512.282, NULL, 184.489, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-01'), '2025-07-14 09:50:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 557.814, NULL, 194.487, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-01'), '2025-08-29 11:38:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 684.956, NULL, 87.225, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-01'), '2025-11-02 09:13:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 721.801, NULL, 153.571, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-01'), '2025-12-30 08:31:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 825.026, 7.835, 146.925, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-01'), '2026-02-22 11:56:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 946.314, NULL, 139.089, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-02'), '2024-01-12 09:34:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Possum', 'Cholecalciferol', 'Pellets', 0.08, 450.275, NULL, 135.257, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-02'), '2024-03-15 07:01:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Possum', 'Cholecalciferol', 'Pellets', 0.08, 523.438, NULL, 198.105, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-02'), '2024-05-14 07:50:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Possum', 'Cholecalciferol', 'Pellets', 0.08, 634.79, NULL, 55.974, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-02'), '2024-07-07 10:27:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Possum', 'Cholecalciferol', 'Pellets', 0.08, 560.103, NULL, 125.157, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-02'), '2024-09-09 08:17:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Possum', 'Cholecalciferol', 'Pellets', 0.08, 607.101, NULL, 130.648, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-02'), '2024-10-23 08:34:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Possum', 'Cholecalciferol', 'Pellets', 0.08, 702.254, NULL, 80.48, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-02'), '2024-12-14 07:19:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Possum', 'Cholecalciferol', 'Pellets', 0.08, 743.197, NULL, 175.179, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-02'), '2025-02-16 08:05:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Possum', 'Cholecalciferol', 'Pellets', 0.08, 876.502, NULL, 85.796, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-02'), '2025-04-12 08:07:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Possum', 'Cholecalciferol', 'Pellets', 0.08, 904.179, NULL, 58.254, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-02'), '2025-05-24 09:33:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Possum', 'Cholecalciferol', 'Pellets', 0.08, 811.643, NULL, 74.575, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-02'), '2025-07-21 08:47:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Possum', 'Cholecalciferol', 'Pellets', 0.08, 727.919, NULL, 75.044, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-02'), '2025-09-25 07:21:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Possum', 'Cholecalciferol', 'Pellets', 0.08, 691.821, NULL, 67.709, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-02'), '2025-12-01 11:40:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Possum', 'Cholecalciferol', 'Pellets', 0.08, 718.064, NULL, 89.442, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-02'), '2026-01-14 11:10:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Possum', 'Cholecalciferol', 'Pellets', 0.08, 762.699, NULL, 58.316, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-02'), '2026-03-08 07:14:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Possum', 'Cholecalciferol', 'Pellets', 0.08, 760.003, NULL, 184.14, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-03'), '2024-01-17 08:11:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 87.965, 0.92, 104.596, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-03'), '2024-03-26 10:14:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 140.086, NULL, 157.103, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-03'), '2024-05-17 07:36:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 192.363, NULL, 97.99, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-03'), '2024-07-09 08:51:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 198.413, NULL, 57.901, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-03'), '2024-09-05 10:55:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 137.615, NULL, 60.339, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-03'), '2024-10-26 10:00:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 139.278, NULL, 62.958, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-03'), '2024-12-18 11:15:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 172.202, NULL, 95.586, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-03'), '2025-02-12 08:46:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 229.374, NULL, 199.668, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-03'), '2025-04-23 10:01:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 340.783, NULL, 72.585, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-03'), '2025-06-11 07:21:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 279.213, NULL, 154.019, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-03'), '2025-07-23 09:06:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 277.339, NULL, 160.712, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-03'), '2025-09-09 07:09:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 350.964, NULL, 123.804, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-03'), '2025-11-12 10:44:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 440.777, 4.629, 176.826, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-03'), '2026-01-21 07:32:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 578.978, NULL, 62.735, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-03'), '2026-03-08 07:27:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 547.108, NULL, 138.784, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-04'), '2024-01-05 09:20:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 199.82, NULL, 170.123, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-04'), '2024-03-01 11:06:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 300.906, 4.054, 166.991, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-04'), '2024-04-16 07:34:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 410.501, NULL, 97.105, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-04'), '2024-06-08 09:54:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 331.143, NULL, 96.246, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-04'), '2024-07-23 11:02:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 338.347, NULL, 95.632, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-04'), '2024-09-09 08:22:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 325.464, NULL, 63.682, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-04'), '2024-11-02 08:01:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 343.473, NULL, 89.025, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-04'), '2024-12-26 07:29:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 369.768, NULL, 132.518, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-04'), '2025-02-09 08:08:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 442.091, 0.239, 174.556, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-04'), '2025-03-29 07:37:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 508.99, NULL, 144.545, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-04'), '2025-05-28 07:12:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 547.653, NULL, 53.27, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-04'), '2025-08-06 09:07:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 505.704, NULL, 63.797, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-04'), '2025-09-18 10:31:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 453.541, 18.483, 114.973, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-04'), '2025-10-30 08:17:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 529.378, NULL, 103.091, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-04'), '2025-12-19 09:31:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 590.168, 12.282, 142.547, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='NBS-04'), '2026-02-12 10:08:00', (SELECT user_id FROM users WHERE username='enyberg'), 'Rat', 'Brodifacoum', 'Block', 0.005, 668.576, NULL, 63.158, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-01'), '2024-01-07 11:50:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 315.068, NULL, 199.113, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-01'), '2024-02-18 11:50:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 444.711, NULL, 103.867, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-01'), '2024-04-15 09:11:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 474.496, NULL, 98.241, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-01'), '2024-05-27 09:03:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 460.849, NULL, 184.365, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-01'), '2024-08-02 08:10:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 525.807, NULL, 165.026, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-01'), '2024-09-16 07:48:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 623.483, NULL, 130.053, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-01'), '2024-11-04 08:11:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 704.751, NULL, 108.263, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-01'), '2024-12-23 11:01:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 763.388, NULL, 154.644, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-01'), '2025-02-25 11:12:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 863.004, NULL, 134.541, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-01'), '2025-05-04 09:11:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 818.744, NULL, 123.834, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-01'), '2025-06-30 10:00:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 858.782, 12.033, 52.989, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-01'), '2025-08-21 08:58:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 797.518, NULL, 69.573, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-01'), '2025-10-27 11:45:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 804.877, NULL, 53.287, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-01'), '2025-12-12 07:23:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 799.446, NULL, 179.1, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-01'), '2026-02-14 09:20:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 911.45, NULL, 65.155, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-02'), '2024-01-06 09:11:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 364.48, NULL, 123.08, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-02'), '2024-03-10 09:14:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 369.748, NULL, 189.327, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-02'), '2024-05-12 08:11:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 420.18, 6.136, 153.275, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-02'), '2024-07-16 11:02:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 493.275, NULL, 135.925, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-02'), '2024-09-01 08:40:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 537.033, NULL, 195.13, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-02'), '2024-10-31 07:15:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 706.957, NULL, 99.675, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-02'), '2024-12-23 09:28:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 737.513, 17.706, 63.309, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-02'), '2025-02-03 09:50:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 767.561, NULL, 60.169, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-02'), '2025-03-20 08:56:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 727.301, 8.764, 112.948, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-02'), '2025-05-14 07:53:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 710.941, NULL, 131.904, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-02'), '2025-07-10 08:10:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 683.972, NULL, 163.737, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-02'), '2025-09-04 09:16:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 792.549, NULL, 94.236, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-02'), '2025-10-19 11:57:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 863.075, 7.509, 159.798, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-02'), '2025-12-02 07:27:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 985.975, NULL, 183.984, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-02'), '2026-02-02 07:21:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 1141.709, NULL, 73.566, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-02'), '2026-03-22 11:16:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 1097.067, NULL, 133.117, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-03'), '2024-01-10 10:09:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 229.294, NULL, 132.449, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-03'), '2024-02-22 11:30:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 323.702, NULL, 94.182, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-03'), '2024-04-10 07:30:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 361.095, NULL, 145.729, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-03'), '2024-06-18 09:05:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 415.273, NULL, 120.642, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-03'), '2024-08-19 10:02:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 447.826, 17.71, 105.41, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-03'), '2024-10-08 11:03:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 511.249, NULL, 175.562, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-03'), '2024-11-23 09:51:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 629.199, NULL, 62.856, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-03'), '2025-01-21 07:53:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 651.356, NULL, 84.127, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-03'), '2025-03-16 10:36:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 628.195, NULL, 130.327, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-03'), '2025-05-25 07:32:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 654.958, NULL, 109.221, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-03'), '2025-07-24 11:09:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 594.133, NULL, 151.63, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-03'), '2025-09-07 08:13:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 629.315, NULL, 192.359, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-03'), '2025-11-13 08:52:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 792.038, 1.567, 152.469, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-03'), '2026-01-14 07:05:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 917.113, NULL, 97.962, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='SBS-03'), '2026-03-09 11:29:00', (SELECT user_id FROM users WHERE username='fgrant'), 'Rat', 'Diphacinone', 'Block', 0.005, 926.13, NULL, 178.494, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='HPS-01'), '2024-01-01 10:09:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', 'Brodifacoum', 'Block', 0.005, 374.14, NULL, 112.939, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='HPS-01'), '2024-02-16 07:59:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', 'Brodifacoum', 'Block', 0.005, 438.749, NULL, 194.725, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='HPS-01'), '2024-04-01 09:56:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', 'Brodifacoum', 'Block', 0.005, 544.086, 5.722, 130.345, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='HPS-01'), '2024-05-26 10:02:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', 'Brodifacoum', 'Block', 0.005, 568.017, NULL, 135.803, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='HPS-01'), '2024-07-12 07:25:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', 'Brodifacoum', 'Block', 0.005, 596.279, 12.173, 154.049, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='HPS-01'), '2024-09-20 10:58:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', 'Brodifacoum', 'Block', 0.005, 638.801, NULL, 57.394, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='HPS-01'), '2024-11-09 09:53:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', 'Brodifacoum', 'Block', 0.005, 631.343, 16.348, 95.458, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='HPS-01'), '2025-01-05 08:08:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', 'Brodifacoum', 'Block', 0.005, 663.889, NULL, 195.874, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='HPS-01'), '2025-02-25 09:46:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', 'Brodifacoum', 'Block', 0.005, 791.052, NULL, 173.873, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='HPS-01'), '2025-04-21 10:47:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', 'Brodifacoum', 'Block', 0.005, 872.576, 8.834, 187.015, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='HPS-01'), '2025-06-17 11:50:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', 'Brodifacoum', 'Block', 0.005, 903.642, NULL, 173.153, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='HPS-01'), '2025-08-03 11:56:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', 'Brodifacoum', 'Block', 0.005, 1022.202, NULL, 110.508, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='HPS-01'), '2025-10-02 08:02:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', 'Brodifacoum', 'Block', 0.005, 1111.263, 16.659, 175.547, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='HPS-01'), '2025-11-27 09:52:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', 'Brodifacoum', 'Block', 0.005, 1264.282, NULL, 79.866, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='HPS-01'), '2026-01-22 07:15:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', 'Brodifacoum', 'Block', 0.005, 1298.892, NULL, 68.581, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='HPS-01'), '2026-03-16 10:37:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', 'Brodifacoum', 'Block', 0.005, 1283.258, NULL, 194.078, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='HPS-02'), '2024-01-12 07:18:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', 'Brodifacoum', 'Block', 0.005, 208.604, NULL, 174.631, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='HPS-02'), '2024-02-23 08:41:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', 'Brodifacoum', 'Block', 0.005, 343.907, 11.445, 194.738, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='HPS-02'), '2024-04-12 07:55:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', 'Brodifacoum', 'Block', 0.005, 441.206, NULL, 111.426, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='HPS-02'), '2024-06-17 08:41:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', 'Brodifacoum', 'Block', 0.005, 375.918, NULL, 121.115, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='HPS-02'), '2024-08-03 09:45:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', 'Brodifacoum', 'Block', 0.005, 404.953, 5.048, 170.763, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='HPS-02'), '2024-10-06 09:29:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', 'Brodifacoum', 'Block', 0.005, 523.579, NULL, 106.471, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='HPS-02'), '2024-11-25 11:25:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', 'Brodifacoum', 'Block', 0.005, 599.14, NULL, 128.096, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='HPS-02'), '2025-01-24 09:35:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', 'Brodifacoum', 'Block', 0.005, 702.12, NULL, 149.353, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='HPS-02'), '2025-03-27 10:04:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', 'Brodifacoum', 'Block', 0.005, 759.909, NULL, 152.662, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='HPS-02'), '2025-05-18 09:41:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', 'Brodifacoum', 'Block', 0.005, 733.735, NULL, 179.224, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='HPS-02'), '2025-07-21 11:48:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', 'Brodifacoum', 'Block', 0.005, 737.74, NULL, 78.254, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='HPS-02'), '2025-09-08 11:25:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', 'Brodifacoum', 'Block', 0.005, 703.016, NULL, 170.355, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='HPS-02'), '2025-11-10 09:16:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', 'Brodifacoum', 'Block', 0.005, 837.392, 0.509, 124.606, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='HPS-02'), '2026-01-04 11:52:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', 'Brodifacoum', 'Block', 0.005, 921.768, NULL, 137.454, NULL),
    ((SELECT station_id FROM bait_stations WHERE code='HPS-02'), '2026-02-21 10:58:00', (SELECT user_id FROM users WHERE username='hpatel'), 'Rat', 'Brodifacoum', 'Block', 0.005, 1022.064, NULL, 152.948, NULL)
ON CONFLICT DO NOTHING;



-- ══════════════════════════════════════════════════════
-- EXPANSION SEED — varied-size lines at real NZ predator-
-- control hotspots, group updates with engagement,
-- Knowledge Hub articles, operational areas, plus extra
-- catches/observations/bait records so every page has
-- something to render. Augments the data above; nothing
-- existing is replaced.
-- ══════════════════════════════════════════════════════

INSERT INTO lines (name, type, group_id, is_retired) VALUES
  ('Te Waihora Pilot Line', 'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false),
  ('Selwyn River Corridor', 'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false),
  ('Vineyard Block Bait Stations', 'Bait Station', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false),
  ('Travis Wetland Reserve', 'Trap', (SELECT group_id FROM groups WHERE name = 'Christchurch City Trappers'), false),
  ('Bottle Lake Forest Loop', 'Trap', (SELECT group_id FROM groups WHERE name = 'Christchurch City Trappers'), false),
  ('Avon-Heathcote Estuary Stations', 'Bait Station', (SELECT group_id FROM groups WHERE name = 'Christchurch City Trappers'), false),
  ('Port Hills Summit Track', 'Trap', (SELECT group_id FROM groups WHERE name = 'Christchurch City Trappers'), false),
  ('Riccarton Bush Pilot', 'Trap', (SELECT group_id FROM groups WHERE name = 'Christchurch City Trappers'), false),
  ('Hinewai Reserve Main Ridge', 'Trap', (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), false),
  ('Otanerito Valley Bush', 'Trap', (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), false),
  ('Akaroa Harbour Cliff Edge', 'Trap', (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), false),
  ('Long Bay Coastal Track', 'Trap', (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), false),
  ('Wainui Bait Station Network', 'Bait Station', (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), false)
ON CONFLICT (name) DO NOTHING;

INSERT INTO operator_lines (operator_id, line_id) VALUES
  ((SELECT user_id FROM users WHERE username = 'enyberg'), (SELECT line_id FROM lines WHERE name = 'Te Waihora Pilot Line')),
  ((SELECT user_id FROM users WHERE username = 'fgrant'), (SELECT line_id FROM lines WHERE name = 'Selwyn River Corridor')),
  ((SELECT user_id FROM users WHERE username = 'gwatson'), (SELECT line_id FROM lines WHERE name = 'Vineyard Block Bait Stations')),
  ((SELECT user_id FROM users WHERE username = 'hpatel'), (SELECT line_id FROM lines WHERE name = 'Travis Wetland Reserve')),
  ((SELECT user_id FROM users WHERE username = 'hpatel'), (SELECT line_id FROM lines WHERE name = 'Bottle Lake Forest Loop')),
  ((SELECT user_id FROM users WHERE username = 'iford'), (SELECT line_id FROM lines WHERE name = 'Avon-Heathcote Estuary Stations')),
  ((SELECT user_id FROM users WHERE username = 'hpatel'), (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track')),
  ((SELECT user_id FROM users WHERE username = 'iford'), (SELECT line_id FROM lines WHERE name = 'Riccarton Bush Pilot')),
  ((SELECT user_id FROM users WHERE username = 'dlee'), (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge')),
  ((SELECT user_id FROM users WHERE username = 'bkim'), (SELECT line_id FROM lines WHERE name = 'Otanerito Valley Bush')),
  ((SELECT user_id FROM users WHERE username = 'dlee'), (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Cliff Edge')),
  ((SELECT user_id FROM users WHERE username = 'dlee'), (SELECT line_id FROM lines WHERE name = 'Long Bay Coastal Track')),
  ((SELECT user_id FROM users WHERE username = 'bkim'), (SELECT line_id FROM lines WHERE name = 'Wainui Bait Station Network'))
ON CONFLICT DO NOTHING;

INSERT INTO traps (code, trap_type, line_id, latitude, longitude, is_retired) VALUES
  ('TWP-01', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Te Waihora Pilot Line'), -43.781, 172.45, false),
  ('TWP-02', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Te Waihora Pilot Line'), -43.7795, 172.4525, false),
  ('TWP-03', 'A24', (SELECT line_id FROM lines WHERE name = 'Te Waihora Pilot Line'), -43.778, 172.455, false),
  ('SRC-01', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Selwyn River Corridor'), -43.621, 172.405, false),
  ('SRC-02', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Selwyn River Corridor'), -43.6218, 172.41, false),
  ('SRC-03', 'Victor', (SELECT line_id FROM lines WHERE name = 'Selwyn River Corridor'), -43.6226, 172.415, false),
  ('SRC-04', 'Timms', (SELECT line_id FROM lines WHERE name = 'Selwyn River Corridor'), -43.6234, 172.42, false),
  ('SRC-05', 'A24', (SELECT line_id FROM lines WHERE name = 'Selwyn River Corridor'), -43.6242, 172.425, false),
  ('SRC-06', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Selwyn River Corridor'), -43.625, 172.43, false),
  ('SRC-07', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Selwyn River Corridor'), -43.6258, 172.435, false),
  ('SRC-08', 'Victor', (SELECT line_id FROM lines WHERE name = 'Selwyn River Corridor'), -43.6266, 172.44, false),
  ('SRC-09', 'Timms', (SELECT line_id FROM lines WHERE name = 'Selwyn River Corridor'), -43.6274, 172.445, false),
  ('SRC-10', 'A24', (SELECT line_id FROM lines WHERE name = 'Selwyn River Corridor'), -43.6282, 172.45, false),
  ('SRC-11', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Selwyn River Corridor'), -43.629, 172.455, false),
  ('SRC-12', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Selwyn River Corridor'), -43.6298, 172.46, false),
  ('TWR-01', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Travis Wetland Reserve'), -43.494, 172.69, false),
  ('TWR-02', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Travis Wetland Reserve'), -43.493, 172.6915, false),
  ('TWR-03', 'A24', (SELECT line_id FROM lines WHERE name = 'Travis Wetland Reserve'), -43.492, 172.693, false),
  ('TWR-04', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Travis Wetland Reserve'), -43.491, 172.6945, false),
  ('TWR-05', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Travis Wetland Reserve'), -43.49, 172.696, false),
  ('TWR-06', 'A24', (SELECT line_id FROM lines WHERE name = 'Travis Wetland Reserve'), -43.489, 172.6975, false),
  ('TWR-07', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Travis Wetland Reserve'), -43.488, 172.699, false),
  ('TWR-08', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Travis Wetland Reserve'), -43.487, 172.7005, false),
  ('TWR-09', 'A24', (SELECT line_id FROM lines WHERE name = 'Travis Wetland Reserve'), -43.486, 172.702, false),
  ('TWR-10', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Travis Wetland Reserve'), -43.485, 172.7035, false),
  ('BLF-01', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Bottle Lake Forest Loop'), -43.46, 172.69, false),
  ('BLF-02', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Bottle Lake Forest Loop'), -43.4588, 172.6911, false),
  ('BLF-03', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Bottle Lake Forest Loop'), -43.4576, 172.6922, false),
  ('BLF-04', 'A24', (SELECT line_id FROM lines WHERE name = 'Bottle Lake Forest Loop'), -43.4564, 172.6933, false),
  ('BLF-05', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Bottle Lake Forest Loop'), -43.4552, 172.6944, false),
  ('BLF-06', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Bottle Lake Forest Loop'), -43.454, 172.6955, false),
  ('BLF-07', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Bottle Lake Forest Loop'), -43.4528, 172.6966, false),
  ('BLF-08', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Bottle Lake Forest Loop'), -43.4516, 172.6977, false),
  ('BLF-09', 'A24', (SELECT line_id FROM lines WHERE name = 'Bottle Lake Forest Loop'), -43.4504, 172.6988, false),
  ('BLF-10', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Bottle Lake Forest Loop'), -43.4492, 172.6999, false),
  ('BLF-11', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Bottle Lake Forest Loop'), -43.448, 172.701, false),
  ('BLF-12', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Bottle Lake Forest Loop'), -43.4468, 172.7021, false),
  ('BLF-13', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Bottle Lake Forest Loop'), -43.4456, 172.7032, false),
  ('BLF-14', 'A24', (SELECT line_id FROM lines WHERE name = 'Bottle Lake Forest Loop'), -43.4444, 172.7043, false),
  ('BLF-15', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Bottle Lake Forest Loop'), -43.4432, 172.7054, false),
  ('BLF-16', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Bottle Lake Forest Loop'), -43.442, 172.7065, false),
  ('BLF-17', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Bottle Lake Forest Loop'), -43.4408, 172.7076, false),
  ('BLF-18', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Bottle Lake Forest Loop'), -43.4396, 172.7087, false),
  ('BLF-19', 'A24', (SELECT line_id FROM lines WHERE name = 'Bottle Lake Forest Loop'), -43.4384, 172.7098, false),
  ('BLF-20', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Bottle Lake Forest Loop'), -43.4372, 172.7109, false),
  ('BLF-21', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Bottle Lake Forest Loop'), -43.436, 172.712, false),
  ('BLF-22', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Bottle Lake Forest Loop'), -43.4348, 172.7131, false),
  ('BLF-23', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Bottle Lake Forest Loop'), -43.4336, 172.7142, false),
  ('BLF-24', 'A24', (SELECT line_id FROM lines WHERE name = 'Bottle Lake Forest Loop'), -43.4324, 172.7153, false),
  ('BLF-25', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Bottle Lake Forest Loop'), -43.4312, 172.7164, false),
  ('PHS-01', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.605, 172.65, false),
  ('PHS-02', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6053, 172.6518, false),
  ('PHS-03', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6056, 172.6536, false),
  ('PHS-04', 'A24', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6059, 172.6554, false),
  ('PHS-05', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6062, 172.6572, false),
  ('PHS-06', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6065, 172.659, false),
  ('PHS-07', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6068, 172.6608, false),
  ('PHS-08', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6071, 172.6626, false),
  ('PHS-09', 'A24', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6074, 172.6644, false),
  ('PHS-10', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6077, 172.6662, false),
  ('PHS-11', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.608, 172.668, false),
  ('PHS-12', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6083, 172.6698, false),
  ('PHS-13', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6086, 172.6716, false),
  ('PHS-14', 'A24', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6089, 172.6734, false),
  ('PHS-15', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6092, 172.6752, false),
  ('PHS-16', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6095, 172.677, false),
  ('PHS-17', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6098, 172.6788, false),
  ('PHS-18', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6101, 172.6806, false),
  ('PHS-19', 'A24', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6104, 172.6824, false),
  ('PHS-20', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6107, 172.6842, false),
  ('PHS-21', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.611, 172.686, false),
  ('PHS-22', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6113, 172.6878, false),
  ('PHS-23', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6116, 172.6896, false),
  ('PHS-24', 'A24', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6119, 172.6914, false),
  ('PHS-25', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6122, 172.6932, false),
  ('PHS-26', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6125, 172.695, false),
  ('PHS-27', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6128, 172.6968, false),
  ('PHS-28', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6131, 172.6986, false),
  ('PHS-29', 'A24', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6134, 172.7004, false),
  ('PHS-30', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6137, 172.7022, false),
  ('PHS-31', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.614, 172.704, false),
  ('PHS-32', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6143, 172.7058, false),
  ('PHS-33', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6146, 172.7076, false),
  ('PHS-34', 'A24', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6149, 172.7094, false),
  ('PHS-35', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6152, 172.7112, false),
  ('PHS-36', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6155, 172.713, false),
  ('PHS-37', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6158, 172.7148, false),
  ('PHS-38', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6161, 172.7166, false),
  ('PHS-39', 'A24', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6164, 172.7184, false),
  ('PHS-40', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6167, 172.7202, false),
  ('PHS-41', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.617, 172.722, false),
  ('PHS-42', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6173, 172.7238, false),
  ('PHS-43', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6176, 172.7256, false),
  ('PHS-44', 'A24', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6179, 172.7274, false),
  ('PHS-45', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), -43.6182, 172.7292, false),
  ('RBP-01', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Riccarton Bush Pilot'), -43.531, 172.589, false),
  ('RBP-02', 'A24', (SELECT line_id FROM lines WHERE name = 'Riccarton Bush Pilot'), -43.5302, 172.5894, false),
  ('HRM-01', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.82, 172.96, false),
  ('HRM-02', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8196, 172.9611, false),
  ('HRM-03', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8192, 172.9622, false),
  ('HRM-04', 'A24', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8188, 172.9633, false),
  ('HRM-05', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8184, 172.9644, false),
  ('HRM-06', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.818, 172.9655, false),
  ('HRM-07', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8176, 172.9666, false),
  ('HRM-08', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8172, 172.9677, false),
  ('HRM-09', 'A24', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8168, 172.9688, false),
  ('HRM-10', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8164, 172.9699, false),
  ('HRM-11', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.816, 172.971, false),
  ('HRM-12', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8156, 172.9721, false),
  ('HRM-13', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8152, 172.9732, false),
  ('HRM-14', 'A24', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8148, 172.9743, false),
  ('HRM-15', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8144, 172.9754, false),
  ('HRM-16', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.814, 172.9765, false),
  ('HRM-17', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8136, 172.9776, false),
  ('HRM-18', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8132, 172.9787, false),
  ('HRM-19', 'A24', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8128, 172.9798, false),
  ('HRM-20', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8124, 172.9809, false),
  ('HRM-21', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.812, 172.982, false),
  ('HRM-22', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8116, 172.9831, false),
  ('HRM-23', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8112, 172.9842, false),
  ('HRM-24', 'A24', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8108, 172.9853, false),
  ('HRM-25', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8104, 172.9864, false),
  ('HRM-26', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.81, 172.9875, false),
  ('HRM-27', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8096, 172.9886, false),
  ('HRM-28', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8092, 172.9897, false),
  ('HRM-29', 'A24', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8088, 172.9908, false),
  ('HRM-30', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8084, 172.9919, false),
  ('HRM-31', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.808, 172.993, false),
  ('HRM-32', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8076, 172.9941, false),
  ('HRM-33', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8072, 172.9952, false),
  ('HRM-34', 'A24', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8068, 172.9963, false),
  ('HRM-35', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8064, 172.9974, false),
  ('HRM-36', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.806, 172.9985, false),
  ('HRM-37', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8056, 172.9996, false),
  ('HRM-38', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8052, 173.0007, false),
  ('HRM-39', 'A24', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8048, 173.0018, false),
  ('HRM-40', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8044, 173.0029, false),
  ('HRM-41', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.804, 173.004, false),
  ('HRM-42', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8036, 173.0051, false),
  ('HRM-43', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8032, 173.0062, false),
  ('HRM-44', 'A24', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8028, 173.0073, false),
  ('HRM-45', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8024, 173.0084, false),
  ('HRM-46', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.802, 173.0095, false),
  ('HRM-47', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8016, 173.0106, false),
  ('HRM-48', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8012, 173.0117, false),
  ('HRM-49', 'A24', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8008, 173.0128, false),
  ('HRM-50', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), -43.8004, 173.0139, false),
  ('OVB-01', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Otanerito Valley Bush'), -43.83, 173.0, false),
  ('OVB-02', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Otanerito Valley Bush'), -43.8294, 173.0009, false),
  ('OVB-03', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Otanerito Valley Bush'), -43.8288, 173.0018, false),
  ('OVB-04', 'A24', (SELECT line_id FROM lines WHERE name = 'Otanerito Valley Bush'), -43.8282, 173.0027, false),
  ('OVB-05', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Otanerito Valley Bush'), -43.8276, 173.0036, false),
  ('OVB-06', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Otanerito Valley Bush'), -43.827, 173.0045, false),
  ('OVB-07', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Otanerito Valley Bush'), -43.8264, 173.0054, false),
  ('OVB-08', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Otanerito Valley Bush'), -43.8258, 173.0063, false),
  ('OVB-09', 'A24', (SELECT line_id FROM lines WHERE name = 'Otanerito Valley Bush'), -43.8252, 173.0072, false),
  ('OVB-10', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Otanerito Valley Bush'), -43.8246, 173.0081, false),
  ('OVB-11', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Otanerito Valley Bush'), -43.824, 173.009, false),
  ('OVB-12', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Otanerito Valley Bush'), -43.8234, 173.0099, false),
  ('OVB-13', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Otanerito Valley Bush'), -43.8228, 173.0108, false),
  ('OVB-14', 'A24', (SELECT line_id FROM lines WHERE name = 'Otanerito Valley Bush'), -43.8222, 173.0117, false),
  ('OVB-15', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Otanerito Valley Bush'), -43.8216, 173.0126, false),
  ('OVB-16', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Otanerito Valley Bush'), -43.821, 173.0135, false),
  ('OVB-17', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Otanerito Valley Bush'), -43.8204, 173.0144, false),
  ('OVB-18', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Otanerito Valley Bush'), -43.8198, 173.0153, false),
  ('OVB-19', 'A24', (SELECT line_id FROM lines WHERE name = 'Otanerito Valley Bush'), -43.8192, 173.0162, false),
  ('OVB-20', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Otanerito Valley Bush'), -43.8186, 173.0171, false),
  ('OVB-21', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Otanerito Valley Bush'), -43.818, 173.018, false),
  ('OVB-22', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Otanerito Valley Bush'), -43.8174, 173.0189, false),
  ('OVB-23', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Otanerito Valley Bush'), -43.8168, 173.0198, false),
  ('OVB-24', 'A24', (SELECT line_id FROM lines WHERE name = 'Otanerito Valley Bush'), -43.8162, 173.0207, false),
  ('OVB-25', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Otanerito Valley Bush'), -43.8156, 173.0216, false),
  ('OVB-26', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Otanerito Valley Bush'), -43.815, 173.0225, false),
  ('OVB-27', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Otanerito Valley Bush'), -43.8144, 173.0234, false),
  ('OVB-28', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Otanerito Valley Bush'), -43.8138, 173.0243, false),
  ('AHC-01', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Cliff Edge'), -43.795, 172.955, false),
  ('AHC-02', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Cliff Edge'), -43.796, 172.9562, false),
  ('AHC-03', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Cliff Edge'), -43.797, 172.9574, false),
  ('AHC-04', 'A24', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Cliff Edge'), -43.798, 172.9586, false),
  ('AHC-05', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Cliff Edge'), -43.799, 172.9598, false),
  ('AHC-06', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Cliff Edge'), -43.8, 172.961, false),
  ('AHC-07', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Cliff Edge'), -43.801, 172.9622, false),
  ('AHC-08', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Cliff Edge'), -43.802, 172.9634, false),
  ('AHC-09', 'A24', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Cliff Edge'), -43.803, 172.9646, false),
  ('AHC-10', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Cliff Edge'), -43.804, 172.9658, false),
  ('AHC-11', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Cliff Edge'), -43.805, 172.967, false),
  ('AHC-12', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Cliff Edge'), -43.806, 172.9682, false),
  ('AHC-13', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Cliff Edge'), -43.807, 172.9694, false),
  ('AHC-14', 'A24', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Cliff Edge'), -43.808, 172.9706, false),
  ('LBC-01', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Long Bay Coastal Track'), -43.838, 173.045, false),
  ('LBC-02', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Long Bay Coastal Track'), -43.8371, 173.047, false),
  ('LBC-03', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Long Bay Coastal Track'), -43.8362, 173.049, false),
  ('LBC-04', 'A24', (SELECT line_id FROM lines WHERE name = 'Long Bay Coastal Track'), -43.8353, 173.051, false),
  ('LBC-05', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Long Bay Coastal Track'), -43.8344, 173.053, false)
ON CONFLICT (code) DO NOTHING;

INSERT INTO bait_stations (code, station_type, line_id, latitude, longitude, is_retired) VALUES
  ('VBS-01', 'Philproof', (SELECT line_id FROM lines WHERE name = 'Vineyard Block Bait Stations'), -43.65, 172.51, false),
  ('VBS-02', 'Protecta LP', (SELECT line_id FROM lines WHERE name = 'Vineyard Block Bait Stations'), -43.6485, 172.512, false),
  ('VBS-03', 'Mini Philproof', (SELECT line_id FROM lines WHERE name = 'Vineyard Block Bait Stations'), -43.647, 172.514, false),
  ('VBS-04', 'Nara', (SELECT line_id FROM lines WHERE name = 'Vineyard Block Bait Stations'), -43.6455, 172.516, false),
  ('VBS-05', 'Goodnature', (SELECT line_id FROM lines WHERE name = 'Vineyard Block Bait Stations'), -43.644, 172.518, false),
  ('AHE-01', 'Philproof', (SELECT line_id FROM lines WHERE name = 'Avon-Heathcote Estuary Stations'), -43.548, 172.705, false),
  ('AHE-02', 'Protecta LP', (SELECT line_id FROM lines WHERE name = 'Avon-Heathcote Estuary Stations'), -43.5468, 172.7058, false),
  ('AHE-03', 'Nara', (SELECT line_id FROM lines WHERE name = 'Avon-Heathcote Estuary Stations'), -43.5456, 172.7066, false),
  ('AHE-04', 'Tunnel', (SELECT line_id FROM lines WHERE name = 'Avon-Heathcote Estuary Stations'), -43.5444, 172.7074, false),
  ('AHE-05', 'Philproof', (SELECT line_id FROM lines WHERE name = 'Avon-Heathcote Estuary Stations'), -43.5432, 172.7082, false),
  ('AHE-06', 'Protecta LP', (SELECT line_id FROM lines WHERE name = 'Avon-Heathcote Estuary Stations'), -43.542, 172.709, false),
  ('WBN-01', 'Philproof', (SELECT line_id FROM lines WHERE name = 'Wainui Bait Station Network'), -43.85, 172.92, false),
  ('WBN-02', 'Protecta LP', (SELECT line_id FROM lines WHERE name = 'Wainui Bait Station Network'), -43.8494, 172.9214, false),
  ('WBN-03', 'Nara', (SELECT line_id FROM lines WHERE name = 'Wainui Bait Station Network'), -43.8488, 172.9228, false),
  ('WBN-04', 'Goodnature', (SELECT line_id FROM lines WHERE name = 'Wainui Bait Station Network'), -43.8482, 172.9242, false),
  ('WBN-05', 'EnviroMate100', (SELECT line_id FROM lines WHERE name = 'Wainui Bait Station Network'), -43.8476, 172.9256, false),
  ('WBN-06', 'Philproof', (SELECT line_id FROM lines WHERE name = 'Wainui Bait Station Network'), -43.847, 172.927, false),
  ('WBN-07', 'Protecta LP', (SELECT line_id FROM lines WHERE name = 'Wainui Bait Station Network'), -43.8464, 172.9284, false),
  ('WBN-08', 'Nara', (SELECT line_id FROM lines WHERE name = 'Wainui Bait Station Network'), -43.8458, 172.9298, false),
  ('WBN-09', 'Goodnature', (SELECT line_id FROM lines WHERE name = 'Wainui Bait Station Network'), -43.8452, 172.9312, false),
  ('WBN-10', 'EnviroMate100', (SELECT line_id FROM lines WHERE name = 'Wainui Bait Station Network'), -43.8446, 172.9326, false),
  ('WBN-11', 'Philproof', (SELECT line_id FROM lines WHERE name = 'Wainui Bait Station Network'), -43.844, 172.934, false),
  ('WBN-12', 'Protecta LP', (SELECT line_id FROM lines WHERE name = 'Wainui Bait Station Network'), -43.8434, 172.9354, false),
  ('WBN-13', 'Nara', (SELECT line_id FROM lines WHERE name = 'Wainui Bait Station Network'), -43.8428, 172.9368, false),
  ('WBN-14', 'Goodnature', (SELECT line_id FROM lines WHERE name = 'Wainui Bait Station Network'), -43.8422, 172.9382, false),
  ('WBN-15', 'EnviroMate100', (SELECT line_id FROM lines WHERE name = 'Wainui Bait Station Network'), -43.8416, 172.9396, false),
  ('WBN-16', 'Philproof', (SELECT line_id FROM lines WHERE name = 'Wainui Bait Station Network'), -43.841, 172.941, false),
  ('WBN-17', 'Protecta LP', (SELECT line_id FROM lines WHERE name = 'Wainui Bait Station Network'), -43.8404, 172.9424, false),
  ('WBN-18', 'Nara', (SELECT line_id FROM lines WHERE name = 'Wainui Bait Station Network'), -43.8398, 172.9438, false),
  ('WBN-19', 'Goodnature', (SELECT line_id FROM lines WHERE name = 'Wainui Bait Station Network'), -43.8392, 172.9452, false),
  ('WBN-20', 'EnviroMate100', (SELECT line_id FROM lines WHERE name = 'Wainui Bait Station Network'), -43.8386, 172.9466, false)
ON CONFLICT (code) DO NOTHING;

INSERT INTO trap_catches (trap_id, date, recorded_by_id, species_caught, sex, maturity, status, rebaited, bait_type, bait_details, trap_condition, strikes, notes) VALUES
  ((SELECT trap_id FROM traps WHERE code = 'TWP-01'), '2024-05-07 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'TWP-01'), '2024-02-02 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Egg', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'TWP-01'), '2025-12-23 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'TWP-01'), '2024-10-14 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'TWP-02'), '2024-02-13 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'TWP-02'), '2024-07-02 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'TWP-03'), '2024-10-11 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Needs maintenance', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'TWP-03'), '2024-03-03 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Salmon', NULL, 'Repaired', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'TWP-03'), '2026-01-01 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SRC-01'), '2025-10-29 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Male', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SRC-02'), '2025-04-06 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SRC-02'), '2025-10-12 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SRC-03'), '2025-04-03 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SRC-03'), '2025-01-26 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SRC-04'), '2024-08-16 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Peanut butter', NULL, 'Needs maintenance', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SRC-05'), '2025-09-30 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SRC-05'), '2025-04-03 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Lure', NULL, 'Needs maintenance', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SRC-05'), '2024-06-10 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SRC-06'), '2024-05-04 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Needs maintenance', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SRC-07'), '2024-04-14 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rabbit', NULL, 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SRC-07'), '2025-01-28 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Salmon', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SRC-07'), '2025-08-26 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SRC-08'), '2026-01-06 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SRC-08'), '2024-10-03 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SRC-08'), '2025-05-25 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rabbit', NULL, 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SRC-08'), '2024-07-02 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SRC-09'), '2024-04-02 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rabbit', NULL, 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SRC-09'), '2026-01-07 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SRC-09'), '2025-05-01 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rabbit', NULL, 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SRC-10'), '2024-11-07 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Ferret', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SRC-10'), '2025-01-27 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SRC-10'), '2025-11-09 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SRC-10'), '2025-09-29 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SRC-11'), '2024-10-12 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SRC-11'), '2025-11-06 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SRC-12'), '2025-11-04 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'TWR-01'), '2025-10-02 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'TWR-01'), '2024-05-14 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'TWR-01'), '2024-03-08 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'TWR-01'), '2025-02-14 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'TWR-02'), '2024-07-14 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Weasel', 'Male', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'TWR-02'), '2025-03-08 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'TWR-03'), '2025-12-06 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Male', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'TWR-03'), '2026-01-08 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'TWR-03'), '2025-06-25 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'TWR-04'), '2025-05-27 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'TWR-05'), '2024-05-18 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Repaired', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'TWR-05'), '2025-07-26 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Weasel', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'TWR-05'), '2024-09-04 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'TWR-06'), '2024-12-10 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'TWR-06'), '2024-04-17 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'TWR-06'), '2024-02-07 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'TWR-07'), '2024-10-27 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Salmon', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'TWR-07'), '2025-08-27 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'TWR-07'), '2025-09-26 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'TWR-07'), '2025-05-31 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'TWR-08'), '2025-03-06 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'TWR-08'), '2024-10-14 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Weasel', 'Male', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'TWR-08'), '2024-03-18 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'TWR-08'), '2024-02-13 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Male', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'TWR-09'), '2024-08-05 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Rabbit', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'TWR-09'), '2025-10-26 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Male', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'TWR-10'), '2026-01-03 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'TWR-10'), '2024-12-08 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-01'), '2024-11-03 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-01'), '2024-08-30 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Chocolate', NULL, 'Repaired', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-02'), '2025-10-22 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-02'), '2025-06-25 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-02'), '2024-12-09 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-03'), '2024-03-14 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-03'), '2025-12-01 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-04'), '2024-11-06 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-04'), '2025-11-04 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-04'), '2025-03-15 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-05'), '2024-11-09 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Rabbit', NULL, 'Needs maintenance', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-05'), '2024-08-12 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-06'), '2024-04-20 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-06'), '2024-11-03 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-06'), '2025-05-25 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-06'), '2025-11-05 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-07'), '2025-02-14 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-07'), '2024-09-02 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Egg', NULL, 'Repaired', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-07'), '2024-06-06 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Needs maintenance', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-08'), '2025-04-11 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-08'), '2025-11-04 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Peanut butter', NULL, 'Needs maintenance', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-09'), '2024-10-05 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Salmon', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-09'), '2024-09-05 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-09'), '2025-09-30 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-10'), '2024-09-01 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-10'), '2025-02-04 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-11'), '2025-01-25 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Rabbit', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-11'), '2025-08-04 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-11'), '2025-12-10 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-12'), '2024-02-12 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-12'), '2025-02-11 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-12'), '2024-11-28 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-13'), '2024-10-09 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Male', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-14'), '2024-10-12 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-14'), '2025-03-16 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-14'), '2024-04-19 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-15'), '2024-08-06 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Peanut butter', NULL, 'Repaired', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-15'), '2025-04-14 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-15'), '2025-12-09 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-16'), '2025-12-09 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-16'), '2024-08-17 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Repaired', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-16'), '2024-04-01 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-17'), '2025-10-05 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Egg', NULL, 'Needs maintenance', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-17'), '2024-12-07 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-17'), '2024-02-05 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-18'), '2025-03-04 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Male', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-18'), '2025-12-28 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Lure', NULL, 'Repaired', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-18'), '2025-08-05 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Male', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-19'), '2024-08-08 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-19'), '2025-01-01 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Rabbit', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-19'), '2024-10-14 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Needs maintenance', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-20'), '2025-11-23 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Male', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-20'), '2025-05-04 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-20'), '2025-04-06 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-20'), '2024-02-08 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-21'), '2024-05-17 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-21'), '2025-12-27 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-22'), '2025-08-29 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Male', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-22'), '2024-10-27 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-22'), '2024-05-17 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-23'), '2025-08-02 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-24'), '2024-10-12 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-25'), '2025-09-26 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-25'), '2025-11-08 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Lure', NULL, 'Repaired', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BLF-25'), '2024-03-20 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-01'), '2025-03-15 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-01'), '2024-11-04 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-01'), '2025-07-31 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-02'), '2025-11-30 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-02'), '2025-09-06 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-02'), '2025-05-01 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-03'), '2024-05-31 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-03'), '2024-04-09 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Male', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-04'), '2025-02-09 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-04'), '2024-10-07 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Cat (feral)', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-04'), '2025-06-12 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Cat (feral)', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Chocolate', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-04'), '2025-06-25 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-05'), '2024-07-12 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Egg', NULL, 'Needs maintenance', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-05'), '2025-08-04 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-06'), '2024-12-11 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-06'), '2025-02-26 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-07'), '2024-02-14 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Male', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-07'), '2025-11-10 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-07'), '2025-07-11 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-08'), '2024-02-20 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Cat (feral)', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-09'), '2024-02-02 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-09'), '2025-07-09 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Lure', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-09'), '2025-03-09 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-10'), '2025-02-13 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Cat (feral)', 'Male', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-10'), '2024-08-08 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Cat (feral)', 'Female', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-11'), '2025-07-28 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-11'), '2025-11-08 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-11'), '2025-05-13 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Male', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-12'), '2025-05-15 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-12'), '2025-12-09 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Male', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-12'), '2025-02-08 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-12'), '2025-10-24 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-13'), '2024-04-12 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-13'), '2024-11-28 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-13'), '2025-11-04 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-13'), '2025-06-24 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-14'), '2025-03-03 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Cat (feral)', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-14'), '2024-06-04 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Rabbit', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-15'), '2024-09-04 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-15'), '2025-05-09 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Male', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-15'), '2025-08-11 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Chocolate', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-15'), '2024-06-08 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-16'), '2025-08-02 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-16'), '2024-12-27 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Cat (feral)', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-16'), '2024-11-07 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-17'), '2024-05-14 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-17'), '2025-10-01 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-17'), '2024-03-18 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-17'), '2024-11-05 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Egg', NULL, 'Needs maintenance', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-18'), '2024-06-06 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Lure', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-19'), '2025-01-25 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Male', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-20'), '2025-01-28 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Needs maintenance', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-20'), '2025-09-22 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Cat (feral)', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-20'), '2025-01-15 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-21'), '2024-03-16 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-21'), '2024-11-08 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-22'), '2025-08-06 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Needs maintenance', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-22'), '2026-01-09 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-22'), '2024-06-05 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-23'), '2025-01-07 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Male', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-23'), '2025-06-30 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-23'), '2025-10-02 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-23'), '2024-03-18 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-24'), '2024-02-04 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Cat (feral)', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-24'), '2024-10-01 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-24'), '2024-05-30 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-25'), '2024-05-15 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-25'), '2026-01-04 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Cat (feral)', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-25'), '2024-04-09 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Male', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-26'), '2025-11-05 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-26'), '2024-05-02 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'Repaired', 1, NULL)
ON CONFLICT DO NOTHING;

INSERT INTO trap_catches (trap_id, date, recorded_by_id, species_caught, sex, maturity, status, rebaited, bait_type, bait_details, trap_condition, strikes, notes) VALUES
  ((SELECT trap_id FROM traps WHERE code = 'PHS-26'), '2025-05-12 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Rabbit', NULL, 'Repaired', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-27'), '2024-11-15 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-27'), '2025-04-01 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-27'), '2025-06-08 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-28'), '2024-12-07 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-28'), '2025-10-24 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-28'), '2024-10-01 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Cat (feral)', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-29'), '2025-11-04 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-29'), '2024-05-19 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-30'), '2024-06-14 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-30'), '2025-10-25 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Male', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-31'), '2025-10-22 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Cat (feral)', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-31'), '2025-10-01 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-31'), '2025-07-12 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Egg', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-32'), '2025-10-08 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-32'), '2024-02-05 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Chocolate', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-32'), '2024-04-19 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-32'), '2025-12-22 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-33'), '2025-11-10 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-33'), '2025-02-27 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-33'), '2025-05-10 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Cat (feral)', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-34'), '2024-03-10 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-34'), '2024-02-03 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-34'), '2024-08-02 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-35'), '2025-01-26 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Male', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-36'), '2025-03-16 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-36'), '2025-08-03 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-36'), '2025-02-07 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-37'), '2024-04-10 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-37'), '2025-02-14 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-37'), '2024-11-03 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-38'), '2024-06-04 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Rabbit', NULL, 'Repaired', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-38'), '2025-10-10 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-38'), '2024-04-14 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-39'), '2025-08-04 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Cat (feral)', 'Male', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-39'), '2024-03-02 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-40'), '2025-09-06 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Cat (feral)', 'Male', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-40'), '2025-06-04 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Cat (feral)', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-40'), '2025-02-08 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-41'), '2024-07-13 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Male', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-41'), '2024-03-13 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-41'), '2024-09-17 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Egg', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-41'), '2025-11-24 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Cat (feral)', 'Female', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-42'), '2024-12-14 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-42'), '2024-04-09 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Peanut butter', NULL, 'Repaired', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-43'), '2024-04-20 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-43'), '2024-10-29 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Lure', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-43'), '2025-06-24 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-43'), '2025-02-09 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-44'), '2024-05-17 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-44'), '2025-06-13 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-45'), '2025-08-24 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-45'), '2024-07-13 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Cat (feral)', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-45'), '2026-01-07 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'PHS-45'), '2025-04-13 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'RBP-01'), '2025-03-15 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'RBP-01'), '2024-07-10 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Repaired', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'RBP-01'), '2024-08-01 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'RBP-02'), '2024-06-06 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Hedgehog', 'Female', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'RBP-02'), '2025-03-08 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Peanut butter', NULL, 'Needs maintenance', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'RBP-02'), '2024-04-02 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-01'), '2025-10-01 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Salmon', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-01'), '2024-12-11 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Male', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-01'), '2024-06-05 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Repaired', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-01'), '2024-03-20 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-02'), '2024-05-07 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-02'), '2024-03-20 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-03'), '2025-11-30 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-03'), '2024-06-17 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-04'), '2025-01-12 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-04'), '2024-04-20 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-04'), '2025-06-05 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-05'), '2026-01-10 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-05'), '2025-11-08 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Rabbit', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-06'), '2024-07-13 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-06'), '2024-05-31 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Rabbit', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-06'), '2024-04-15 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-06'), '2025-12-02 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-07'), '2024-05-13 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-07'), '2025-01-10 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-08'), '2026-01-03 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-09'), '2024-11-28 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-09'), '2024-05-13 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-10'), '2025-01-15 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-10'), '2025-09-12 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-10'), '2025-02-24 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-10'), '2024-10-04 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Chocolate', NULL, 'Needs maintenance', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-11'), '2024-03-15 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-11'), '2025-08-27 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-11'), '2024-06-06 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-12'), '2025-02-02 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Salmon', NULL, 'Needs maintenance', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-12'), '2025-06-30 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-12'), '2024-05-03 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-13'), '2025-11-01 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-14'), '2024-11-16 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-14'), '2024-07-05 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-14'), '2025-12-06 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-15'), '2025-06-26 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-15'), '2024-06-15 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-15'), '2025-09-02 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-16'), '2024-06-19 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-16'), '2025-06-25 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Repaired', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-17'), '2024-11-01 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Male', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-17'), '2024-07-01 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-18'), '2025-10-11 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-18'), '2024-11-14 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-19'), '2025-08-23 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-19'), '2024-12-16 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-19'), '2025-08-08 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Chocolate', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-19'), '2024-03-08 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Chocolate', NULL, 'Needs maintenance', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-20'), '2025-11-22 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-21'), '2024-11-30 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Chocolate', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-21'), '2025-08-27 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Lure', NULL, 'Repaired', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-22'), '2024-12-03 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Male', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-23'), '2024-05-09 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-23'), '2024-03-19 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-24'), '2025-04-10 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-24'), '2025-05-02 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-24'), '2024-11-11 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-25'), '2025-02-28 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-26'), '2024-03-07 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-26'), '2025-08-07 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Lure', NULL, 'Repaired', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-26'), '2025-06-27 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-27'), '2025-01-14 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-27'), '2024-05-31 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-27'), '2024-08-02 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-28'), '2025-02-03 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-28'), '2025-09-07 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-29'), '2025-11-04 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-29'), '2024-05-19 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-30'), '2026-01-08 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-30'), '2024-03-13 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-31'), '2024-02-10 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Male', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-31'), '2025-04-08 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-32'), '2024-06-09 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-32'), '2025-05-30 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-32'), '2024-08-17 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Male', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-32'), '2025-07-03 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-33'), '2025-12-08 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Chocolate', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-33'), '2025-05-13 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-33'), '2024-12-05 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-33'), '2025-01-09 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-34'), '2025-07-11 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-34'), '2024-10-15 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-35'), '2025-09-23 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-35'), '2024-08-31 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-36'), '2025-10-01 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-36'), '2025-05-15 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-36'), '2024-08-03 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Male', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-37'), '2025-12-22 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-37'), '2024-11-06 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-38'), '2024-06-07 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-38'), '2025-06-14 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Male', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-38'), '2025-04-04 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-39'), '2025-06-06 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-39'), '2024-12-06 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-39'), '2024-04-14 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Chocolate', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-40'), '2025-12-29 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-40'), '2025-07-27 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-40'), '2024-02-09 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-41'), '2024-09-01 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-41'), '2024-06-14 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-41'), '2025-05-14 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Repaired', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-42'), '2025-05-27 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-42'), '2025-11-27 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-42'), '2025-01-09 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-43'), '2025-06-08 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Needs maintenance', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-44'), '2025-06-08 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-44'), '2025-02-24 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-45'), '2024-04-11 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-45'), '2024-03-16 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-45'), '2025-03-16 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-46'), '2025-02-11 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-46'), '2024-04-12 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-46'), '2025-10-22 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-47'), '2025-07-01 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-47'), '2025-01-28 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-47'), '2024-09-03 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-48'), '2025-10-29 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-48'), '2025-12-08 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-48'), '2024-03-08 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Lure', NULL, 'Repaired', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-49'), '2024-12-12 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-49'), '2024-09-14 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-49'), '2024-11-13 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Male', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-49'), '2024-06-15 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-50'), '2024-07-06 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-50'), '2025-06-28 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Egg', NULL, 'Repaired', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'HRM-50'), '2025-05-08 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Male', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-01'), '2024-11-28 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-01'), '2025-09-23 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-02'), '2024-04-06 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Needs maintenance', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-03'), '2024-11-26 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-03'), '2024-11-03 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-04'), '2024-11-10 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-04'), '2025-02-10 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-05'), '2024-08-08 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-05'), '2024-12-26 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-06'), '2024-09-15 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Needs maintenance', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-06'), '2025-02-11 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-07'), '2024-07-04 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL)
ON CONFLICT DO NOTHING;

INSERT INTO trap_catches (trap_id, date, recorded_by_id, species_caught, sex, maturity, status, rebaited, bait_type, bait_details, trap_condition, strikes, notes) VALUES
  ((SELECT trap_id FROM traps WHERE code = 'OVB-07'), '2026-01-06 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-07'), '2025-01-08 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-08'), '2024-08-14 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-09'), '2025-10-22 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-09'), '2025-05-03 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-09'), '2024-02-05 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-10'), '2025-08-31 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Chocolate', NULL, 'Needs maintenance', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-10'), '2025-05-27 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-11'), '2024-09-17 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-11'), '2024-11-08 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-11'), '2025-11-11 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-11'), '2024-04-20 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Lure', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-12'), '2024-03-19 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-12'), '2024-09-14 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-12'), '2024-08-04 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-13'), '2024-07-06 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-13'), '2025-08-05 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-14'), '2025-12-24 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Male', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-14'), '2025-01-14 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-14'), '2024-03-15 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Male', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-15'), '2024-07-11 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-15'), '2025-10-24 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Male', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-15'), '2025-08-05 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-16'), '2025-04-03 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-16'), '2025-01-09 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-17'), '2025-07-13 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-17'), '2024-04-13 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-18'), '2025-06-06 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-18'), '2024-07-14 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-18'), '2025-11-04 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-19'), '2026-01-05 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-19'), '2025-10-01 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-20'), '2025-04-08 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-20'), '2024-12-06 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-21'), '2024-12-16 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Male', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-21'), '2024-11-08 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-21'), '2026-01-07 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-22'), '2024-11-09 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-22'), '2025-11-28 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Rabbit', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-22'), '2024-04-02 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Rabbit', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-23'), '2025-11-22 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Salmon', NULL, 'Repaired', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-23'), '2025-03-15 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-23'), '2025-06-29 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-24'), '2025-02-24 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-24'), '2024-05-17 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-25'), '2025-11-07 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-25'), '2025-08-02 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Male', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-25'), '2025-12-02 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-26'), '2025-01-09 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-26'), '2025-04-26 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-26'), '2024-05-10 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-27'), '2024-07-16 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-27'), '2025-06-29 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-27'), '2024-12-02 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-28'), '2024-09-29 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'OVB-28'), '2025-12-01 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHC-01'), '2025-10-04 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Cat (feral)', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHC-01'), '2024-12-07 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHC-01'), '2025-09-11 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Cat (feral)', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHC-02'), '2024-09-06 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHC-03'), '2025-01-29 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Cat (feral)', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHC-03'), '2025-03-16 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Cat (feral)', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHC-03'), '2025-09-01 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHC-04'), '2024-12-26 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Male', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHC-05'), '2025-10-07 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHC-05'), '2025-05-13 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHC-05'), '2025-03-03 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Cat (feral)', 'Female', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHC-06'), '2025-05-13 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Chocolate', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHC-06'), '2025-06-25 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Lure', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHC-06'), '2025-06-07 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHC-06'), '2024-05-08 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Male', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHC-07'), '2026-01-01 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Peanut butter', NULL, 'Repaired', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHC-07'), '2025-07-28 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHC-08'), '2024-10-02 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHC-08'), '2025-09-08 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHC-08'), '2025-07-07 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHC-09'), '2024-06-09 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHC-09'), '2025-12-11 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHC-10'), '2024-04-08 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Rabbit', NULL, 'Needs maintenance', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHC-10'), '2025-02-04 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Cat (feral)', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHC-10'), '2025-06-14 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Egg', NULL, 'Repaired', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHC-10'), '2026-01-02 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHC-11'), '2024-11-13 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Cat (feral)', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHC-11'), '2024-11-27 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Rabbit', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHC-12'), '2024-07-13 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Male', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHC-13'), '2024-11-16 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHC-13'), '2024-06-30 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHC-13'), '2024-10-10 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHC-13'), '2024-03-31 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Repaired', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHC-14'), '2025-06-08 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHC-14'), '2025-11-04 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Needs maintenance', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'LBC-01'), '2024-09-09 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Chocolate', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'LBC-02'), '2024-06-03 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'LBC-02'), '2025-02-10 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Cat (feral)', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'LBC-03'), '2025-01-15 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait OK', 'No', 'None', NULL, 'Needs maintenance', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'LBC-03'), '2026-01-09 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'None', NULL, NULL, 'Still set, bait bad', 'Yes', 'Peanut butter', NULL, 'OK', 0, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'LBC-03'), '2024-08-01 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'LBC-04'), '2025-02-28 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'LBC-04'), '2024-12-13 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Cat (feral)', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'LBC-05'), '2025-06-10 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'LBC-05'), '2025-08-30 08:30:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Needs maintenance', 1, NULL)
ON CONFLICT DO NOTHING;

INSERT INTO bait_station_records (station_id, date, recorded_by_id, target_species, active_ingredient, formulation, concentration, bait_remaining, bait_removed, bait_added, notes) VALUES
  ((SELECT station_id FROM bait_stations WHERE code = 'VBS-01'), '2025-11-23 09:30:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'Rat', 'Diphacinone', 'Paste', 0.0035, 738.651, 113.676, 91.353, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'VBS-01'), '2024-11-24 09:30:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'Mouse', 'Brodifacoum', 'Block', 0.0122, 61.035, 43.149, 230.645, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'VBS-02'), '2025-11-01 09:30:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'Mouse', 'Cholecalciferol', 'Gel', 0.0143, 115.942, 107.313, 154.012, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'VBS-02'), '2025-03-12 09:30:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'Rat', 'Diphacinone', 'Block', 0.0107, 212.558, 161.612, 134.098, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'VBS-02'), '2025-07-06 09:30:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'Possum', 'Brodifacoum', 'Paste', 0.0143, 633.967, 169.294, 14.476, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'VBS-03'), '2025-08-19 09:30:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'Rat', 'Cholecalciferol', 'Block', 0.0069, 643.355, 148.132, 29.861, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'VBS-03'), '2024-10-19 09:30:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'Possum', 'Brodifacoum', 'Wax block', 0.0104, 327.364, 103.445, 205.627, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'VBS-04'), '2024-11-18 09:30:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'Mouse', 'Bromadiolone', 'Paste', 0.0149, 144.445, 179.979, 83.753, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'VBS-04'), '2025-08-14 09:30:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'Mouse', 'Brodifacoum', 'Paste', 0.0145, 511.321, 15.414, 113.799, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'VBS-04'), '2025-06-04 09:30:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'Rat', 'Cholecalciferol', 'Wax block', 0.008, 254.093, 20.581, 143.478, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'VBS-05'), '2025-01-20 09:30:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'Possum', 'Brodifacoum', 'Block', 0.0173, 59.83, 9.196, 90.994, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'VBS-05'), '2024-11-01 09:30:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'Rat', 'Brodifacoum', 'Gel', 0.0053, 248.611, 183.171, 79.984, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'AHE-01'), '2026-01-07 09:30:00', (SELECT user_id FROM users WHERE username = 'iford'), 'Mouse', 'Brodifacoum', 'Block', 0.0044, 693.47, 196.283, 238.52, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'AHE-01'), '2024-08-10 09:30:00', (SELECT user_id FROM users WHERE username = 'iford'), 'Mouse', 'Diphacinone', 'Paste', 0.0072, 492.473, 1.594, 50.168, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'AHE-02'), '2026-02-28 09:30:00', (SELECT user_id FROM users WHERE username = 'iford'), 'Rat', 'Cholecalciferol', 'Paste', 0.0122, 444.689, 154.523, 48.856, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'AHE-02'), '2025-12-12 09:30:00', (SELECT user_id FROM users WHERE username = 'iford'), 'Rat', 'Bromadiolone', 'Block', 0.0187, 69.128, 108.309, 158.985, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'AHE-02'), '2024-06-10 09:30:00', (SELECT user_id FROM users WHERE username = 'iford'), 'Mouse', 'Brodifacoum', 'Gel', 0.0171, 631.772, 20.79, 132.454, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'AHE-03'), '2025-08-04 09:30:00', (SELECT user_id FROM users WHERE username = 'iford'), 'Mouse', 'Brodifacoum', 'Wax block', 0.0145, 124.421, 184.255, 224.322, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'AHE-03'), '2025-11-15 09:30:00', (SELECT user_id FROM users WHERE username = 'iford'), 'Mouse', 'Diphacinone', 'Gel', 0.0195, 117.922, 19.115, 33.378, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'AHE-04'), '2024-08-16 09:30:00', (SELECT user_id FROM users WHERE username = 'iford'), 'Possum', 'Brodifacoum', 'Gel', 0.0136, 154.567, 58.335, 212.728, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'AHE-04'), '2025-07-08 09:30:00', (SELECT user_id FROM users WHERE username = 'iford'), 'Possum', 'Diphacinone', 'Paste', 0.0096, 236.889, 188.711, 34.028, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'AHE-04'), '2026-01-20 09:30:00', (SELECT user_id FROM users WHERE username = 'iford'), 'Rat', 'Bromadiolone', 'Block', 0.0041, 422.844, 81.303, 133.981, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'AHE-05'), '2025-09-06 09:30:00', (SELECT user_id FROM users WHERE username = 'iford'), 'Mouse', 'Cholecalciferol', 'Paste', 0.0172, 122.337, 161.519, 76.054, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'AHE-05'), '2026-02-08 09:30:00', (SELECT user_id FROM users WHERE username = 'iford'), 'Rat', 'Bromadiolone', 'Paste', 0.0038, 618.926, 193.68, 99.061, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'AHE-06'), '2025-04-03 09:30:00', (SELECT user_id FROM users WHERE username = 'iford'), 'Mouse', 'Bromadiolone', 'Block', 0.0191, 733.681, 111.191, 137.53, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'AHE-06'), '2024-09-05 09:30:00', (SELECT user_id FROM users WHERE username = 'iford'), 'Mouse', 'Brodifacoum', 'Wax block', 0.0033, 99.335, 156.192, 55.572, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-01'), '2025-07-16 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Mouse', 'Brodifacoum', 'Paste', 0.0184, 109.99, 199.432, 49.438, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-01'), '2026-03-24 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Mouse', 'Bromadiolone', 'Block', 0.0182, 713.485, 66.31, 10.674, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-02'), '2024-07-22 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Rat', 'Cholecalciferol', 'Gel', 0.0104, 356.184, 85.333, 88.486, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-02'), '2024-12-09 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Mouse', 'Diphacinone', 'Gel', 0.0178, 77.72, 123.835, 61.446, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-02'), '2025-03-30 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Mouse', 'Cholecalciferol', 'Gel', 0.0022, 273.821, 27.447, 49.864, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-03'), '2026-03-08 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Possum', 'Brodifacoum', 'Gel', 0.0159, 337.29, 108.904, 121.17, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-03'), '2026-01-01 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Possum', 'Diphacinone', 'Gel', 0.0061, 70.85, 119.423, 7.326, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-04'), '2024-07-30 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Mouse', 'Diphacinone', 'Wax block', 0.0195, 130.107, 131.373, 66.632, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-04'), '2024-07-28 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Rat', 'Cholecalciferol', 'Paste', 0.0188, 843.234, 34.742, 59.138, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-04'), '2025-04-22 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Possum', 'Diphacinone', 'Block', 0.0144, 331.346, 113.53, 35.526, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-05'), '2025-10-18 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Possum', 'Diphacinone', 'Wax block', 0.0103, 122.206, 46.525, 54.702, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-05'), '2025-11-22 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Mouse', 'Brodifacoum', 'Paste', 0.0184, 211.172, 26.098, 179.234, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-06'), '2024-07-31 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Rat', 'Bromadiolone', 'Wax block', 0.0157, 727.185, 172.134, 240.14, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-06'), '2025-06-18 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Possum', 'Cholecalciferol', 'Block', 0.0074, 308.083, 195.172, 183.088, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-06'), '2025-08-22 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Possum', 'Cholecalciferol', 'Paste', 0.0043, 824.994, 138.712, 232.211, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-07'), '2025-01-15 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Possum', 'Bromadiolone', 'Gel', 0.0068, 600.799, 25.47, 182.208, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-07'), '2026-01-08 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Mouse', 'Brodifacoum', 'Wax block', 0.0124, 786.831, 193.506, 55.224, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-07'), '2026-01-01 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Rat', 'Cholecalciferol', 'Wax block', 0.0073, 112.245, 69.362, 79.88, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-08'), '2026-03-17 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Possum', 'Diphacinone', 'Gel', 0.0012, 217.747, 138.635, 87.62, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-08'), '2024-09-19 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Possum', 'Brodifacoum', 'Block', 0.0083, 636.068, 193.82, 221.138, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-09'), '2025-06-23 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Mouse', 'Cholecalciferol', 'Block', 0.0167, 680.984, 115.611, 189.561, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-09'), '2025-01-17 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Rat', 'Cholecalciferol', 'Block', 0.0162, 76.73, 4.016, 65.282, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-09'), '2024-09-16 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Rat', 'Diphacinone', 'Wax block', 0.0179, 178.724, 15.0, 235.459, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-10'), '2025-05-13 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Possum', 'Cholecalciferol', 'Block', 0.0092, 572.908, 121.464, 108.55, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-10'), '2024-07-25 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Rat', 'Diphacinone', 'Wax block', 0.0195, 377.424, 110.822, 231.393, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-11'), '2025-03-16 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Mouse', 'Bromadiolone', 'Block', 0.0019, 507.416, 167.971, 38.397, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-11'), '2025-06-05 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Rat', 'Cholecalciferol', 'Block', 0.0066, 579.616, 120.043, 49.919, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-11'), '2024-06-27 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Rat', 'Bromadiolone', 'Paste', 0.0196, 428.857, 23.102, 196.219, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-12'), '2025-10-14 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Possum', 'Diphacinone', 'Block', 0.0132, 360.022, 74.204, 95.361, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-12'), '2024-12-09 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Mouse', 'Brodifacoum', 'Paste', 0.0094, 260.721, 167.416, 141.062, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-12'), '2024-11-02 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Possum', 'Brodifacoum', 'Block', 0.0137, 696.544, 82.797, 189.114, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-13'), '2025-12-19 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Rat', 'Cholecalciferol', 'Gel', 0.0193, 599.654, 187.272, 143.179, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-13'), '2025-01-28 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Mouse', 'Diphacinone', 'Block', 0.0085, 733.152, 6.946, 142.805, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-14'), '2024-10-02 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Mouse', 'Bromadiolone', 'Wax block', 0.0195, 696.769, 25.237, 105.844, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-14'), '2025-08-20 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Rat', 'Bromadiolone', 'Paste', 0.0071, 631.682, 161.469, 21.757, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-15'), '2025-12-18 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Mouse', 'Diphacinone', 'Gel', 0.0184, 59.891, 140.082, 146.894, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-15'), '2025-08-04 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Rat', 'Cholecalciferol', 'Wax block', 0.0038, 520.347, 151.675, 234.912, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-15'), '2024-09-17 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Possum', 'Brodifacoum', 'Paste', 0.0175, 754.109, 175.579, 66.034, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-16'), '2026-01-07 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Possum', 'Cholecalciferol', 'Block', 0.0043, 372.379, 123.649, 170.203, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-16'), '2025-07-17 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Rat', 'Cholecalciferol', 'Paste', 0.0141, 89.433, 95.044, 67.146, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-16'), '2025-06-17 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Rat', 'Diphacinone', 'Paste', 0.0069, 724.277, 171.647, 171.213, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-17'), '2024-10-16 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Mouse', 'Cholecalciferol', 'Paste', 0.0061, 383.418, 129.111, 46.984, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-17'), '2025-01-03 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Mouse', 'Cholecalciferol', 'Paste', 0.0166, 462.216, 31.794, 77.781, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-18'), '2024-10-17 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Possum', 'Brodifacoum', 'Wax block', 0.0047, 716.344, 167.395, 62.373, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-18'), '2025-09-11 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Rat', 'Diphacinone', 'Wax block', 0.0062, 708.805, 101.025, 158.852, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-18'), '2024-10-05 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Possum', 'Brodifacoum', 'Wax block', 0.0081, 525.235, 35.517, 217.62, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-19'), '2025-05-19 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Rat', 'Diphacinone', 'Block', 0.0064, 359.253, 32.581, 143.065, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-19'), '2025-01-06 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Rat', 'Bromadiolone', 'Wax block', 0.0061, 377.606, 4.01, 195.076, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-19'), '2024-06-10 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Mouse', 'Bromadiolone', 'Wax block', 0.0124, 56.771, 50.478, 201.271, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-20'), '2026-03-21 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Mouse', 'Cholecalciferol', 'Gel', 0.0172, 417.198, 43.642, 75.536, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-20'), '2025-11-16 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Possum', 'Cholecalciferol', 'Block', 0.0011, 849.544, 193.297, 209.845, NULL),
  ((SELECT station_id FROM bait_stations WHERE code = 'WBN-20'), '2025-12-27 09:30:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Possum', 'Diphacinone', 'Paste', 0.014, 435.391, 67.257, 69.121, NULL)
ON CONFLICT DO NOTHING;

INSERT INTO incidental_observations (date, operator_id, observation_type, notes, latitude, longitude, line_id) VALUES
  ('2025-06-11 10:15:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Other', 'GPS reading inconsistent — possibly tree cover.', -43.77925, 172.453224, (SELECT line_id FROM lines WHERE name = 'Te Waihora Pilot Line')),
  ('2025-03-12 10:15:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Predator sighting', 'Rat surface activity along the line edge.', -43.780972, 172.449584, (SELECT line_id FROM lines WHERE name = 'Te Waihora Pilot Line')),
  ('2025-10-19 10:15:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Predator sighting', 'Rat surface activity along the line edge.', -43.778289, 172.454424, (SELECT line_id FROM lines WHERE name = 'Te Waihora Pilot Line')),
  ('2026-01-23 10:15:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Native species tracks', 'Cabbage tree leaf litter shows weta activity.', -43.779885, 172.45237, (SELECT line_id FROM lines WHERE name = 'Te Waihora Pilot Line')),
  ('2026-04-21 10:15:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Bird sighting', 'Pīwakawaka feeding on insects above the canopy.', -43.629008, 172.460506, (SELECT line_id FROM lines WHERE name = 'Selwyn River Corridor')),
  ('2025-04-16 10:15:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Other', 'GPS reading inconsistent — possibly tree cover.', -43.628945, 172.455456, (SELECT line_id FROM lines WHERE name = 'Selwyn River Corridor')),
  ('2025-02-22 10:15:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'Predator tracks', 'Cat tracks crossing the line.', -43.64451, 172.517356, (SELECT line_id FROM lines WHERE name = 'Vineyard Block Bait Stations')),
  ('2025-05-23 10:15:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'Other', 'GPS reading inconsistent — possibly tree cover.', -43.643579, 172.517493, (SELECT line_id FROM lines WHERE name = 'Vineyard Block Bait Stations')),
  ('2024-12-01 10:15:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'Bird sighting', 'Bellbird heard along the corridor.', -43.648732, 172.512391, (SELECT line_id FROM lines WHERE name = 'Vineyard Block Bait Stations')),
  ('2025-08-06 10:15:00', (SELECT user_id FROM users WHERE username = 'gwatson'), 'Predator sighting', 'Adult possum in canopy near trap VBS-03.', -43.647383, 172.51367, (SELECT line_id FROM lines WHERE name = 'Vineyard Block Bait Stations')),
  ('2026-04-21 10:15:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Predator tracks', 'Cat tracks crossing the line.', -43.484289, 172.702814, (SELECT line_id FROM lines WHERE name = 'Travis Wetland Reserve')),
  ('2025-01-01 10:15:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Predator tracks', 'Fresh stoat prints on muddy section.', -43.487952, 172.698861, (SELECT line_id FROM lines WHERE name = 'Travis Wetland Reserve')),
  ('2025-08-17 10:15:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Native species tracks', 'Skink track in dust near BLF-14.', -43.44362, 172.704929, (SELECT line_id FROM lines WHERE name = 'Bottle Lake Forest Loop')),
  ('2025-07-21 10:15:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Bird sighting', 'Pīwakawaka feeding on insects above the canopy.', -43.434111, 172.713529, (SELECT line_id FROM lines WHERE name = 'Bottle Lake Forest Loop')),
  ('2025-03-01 10:15:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Bird sighting', 'Tūī foraging in flax near BLF-11.', -43.447785, 172.700208, (SELECT line_id FROM lines WHERE name = 'Bottle Lake Forest Loop')),
  ('2026-04-14 10:15:00', (SELECT user_id FROM users WHERE username = 'iford'), 'Predator sighting', 'Stoat seen darting between traps at dawn.', -43.546817, 172.706222, (SELECT line_id FROM lines WHERE name = 'Avon-Heathcote Estuary Stations')),
  ('2025-11-19 10:15:00', (SELECT user_id FROM users WHERE username = 'iford'), 'Native species tracks', 'Gecko sheltering under the trap cover.', -43.542113, 172.708886, (SELECT line_id FROM lines WHERE name = 'Avon-Heathcote Estuary Stations')),
  ('2024-09-05 10:15:00', (SELECT user_id FROM users WHERE username = 'iford'), 'Predator sighting', 'Adult possum in canopy near trap AHE-01.', -43.547946, 172.705369, (SELECT line_id FROM lines WHERE name = 'Avon-Heathcote Estuary Stations')),
  ('2024-09-19 10:15:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Predator tracks', 'Cat tracks crossing the line.', -43.618693, 172.727774, (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track')),
  ('2025-08-19 10:15:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Native species sign', 'Kahikatea seedlings recovering near PHS-20.', -43.611294, 172.684014, (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track')),
  ('2025-02-19 10:15:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Bird sighting', 'Bellbird heard along the corridor.', -43.605682, 172.656877, (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track')),
  ('2025-11-19 10:15:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Bird sighting', 'Tūī foraging in flax near RBP-01.', -43.531252, 172.589642, (SELECT line_id FROM lines WHERE name = 'Riccarton Bush Pilot')),
  ('2025-02-16 10:15:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Predator tracks', 'Fresh stoat prints on muddy section.', -43.530969, 172.588959, (SELECT line_id FROM lines WHERE name = 'Riccarton Bush Pilot')),
  ('2024-09-23 10:15:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Predator sighting', 'Adult possum in canopy near trap RBP-01.', -43.531603, 172.589338, (SELECT line_id FROM lines WHERE name = 'Riccarton Bush Pilot')),
  ('2025-05-20 10:15:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Predator sighting', 'Rat surface activity along the line edge.', -43.53085, 172.588277, (SELECT line_id FROM lines WHERE name = 'Riccarton Bush Pilot')),
  ('2024-10-20 10:15:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Predator sighting', 'Rat surface activity along the line edge.', -43.803015, 173.008311, (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge')),
  ('2025-05-17 10:15:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Other', 'Trap cover bumped by wind, repositioned.', -43.807677, 172.992529, (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge')),
  ('2025-07-06 10:15:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Bird sighting', 'Pīwakawaka feeding on insects above the canopy.', -43.821941, 173.01196, (SELECT line_id FROM lines WHERE name = 'Otanerito Valley Bush')),
  ('2025-01-19 10:15:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Other', 'Trap cover bumped by wind, repositioned.', -43.821671, 173.011068, (SELECT line_id FROM lines WHERE name = 'Otanerito Valley Bush')),
  ('2025-06-17 10:15:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Native species sign', 'Kererū feeding on miro fruits — recovery indicator.', -43.795544, 172.956196, (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Cliff Edge')),
  ('2025-05-28 10:15:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Other', 'GPS reading inconsistent — possibly tree cover.', -43.807963, 172.970123, (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Cliff Edge')),
  ('2025-02-12 10:15:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Other', 'GPS reading inconsistent — possibly tree cover.', -43.837923, 173.045657, (SELECT line_id FROM lines WHERE name = 'Long Bay Coastal Track')),
  ('2025-08-05 10:15:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Predator sighting', 'Rat surface activity along the line edge.', -43.837896, 173.047275, (SELECT line_id FROM lines WHERE name = 'Long Bay Coastal Track')),
  ('2026-01-19 10:15:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Predator sighting', 'Rat surface activity along the line edge.', -43.836381, 173.047447, (SELECT line_id FROM lines WHERE name = 'Long Bay Coastal Track')),
  ('2024-12-13 10:15:00', (SELECT user_id FROM users WHERE username = 'enyberg'), 'Bird sighting', 'Bellbird heard along the corridor.', -43.835969, 173.048931, (SELECT line_id FROM lines WHERE name = 'Long Bay Coastal Track')),
  ('2024-10-22 10:15:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Bird sighting', 'Bellbird heard along the corridor.', -43.847699, 172.924799, (SELECT line_id FROM lines WHERE name = 'Wainui Bait Station Network')),
  ('2025-07-18 10:15:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Predator sighting', 'Stoat seen darting between traps at dawn.', -43.841818, 172.937552, (SELECT line_id FROM lines WHERE name = 'Wainui Bait Station Network')),
  ('2025-01-20 10:15:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Native species sign', 'Kahikatea seedlings recovering near WBN-06.', -43.847274, 172.927631, (SELECT line_id FROM lines WHERE name = 'Wainui Bait Station Network')),
  ('2024-12-05 10:15:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Native species tracks', 'Gecko sheltering under the trap cover.', -43.842896, 172.934893, (SELECT line_id FROM lines WHERE name = 'Wainui Bait Station Network')),
  ('2025-12-12 10:15:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Native species tracks', 'Gecko sheltering under the trap cover.', -43.844663, 172.931504, (SELECT line_id FROM lines WHERE name = 'Wainui Bait Station Network'))
ON CONFLICT DO NOTHING;

INSERT INTO group_updates (group_id, author_id, title, body, status, created_at, published_at, updated_at) VALUES
  ((SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), (SELECT user_id FROM users WHERE username = 'bkim'), 'Autumn check round-up — best month since program started', 'Whānau, just back from the autumn round on North and South Campus lines. Eight stoats and a dozen rats in a single week. Hats off to Erik for the extra Saturday push, the data is going straight into next terms reporting. Te Waihora pilot is now live too — first stoat already in the bag.', 'published', NOW() - INTERVAL '15 days', NOW() - INTERVAL '14 days', NOW() - INTERVAL '14 days'),
  ((SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), (SELECT user_id FROM users WHERE username = 'smitchell'), 'Lab availability for camera reviews — next four weekends', 'Ive booked the analytics lab Saturdays 9–12 through May. If youve got card pulls from your traps, bring them in and well run the species ID workflow on the big screen. Coffee provided.', 'published', NOW() - INTERVAL '6 days', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days'),
  ((SELECT group_id FROM groups WHERE name = 'Christchurch City Trappers'), (SELECT user_id FROM users WHERE username = 'cwhite'), 'Port Hills Summit Track officially open', 'Forty-five DOC 200s went in last weekend along the Port Hills ridge — huge thanks to the volunteer crew. The line crosses both the city-side and harbour-side faces. First-month catch data will tell us a lot about how the predator pressure moves between those slopes.', 'published', NOW() - INTERVAL '22 days', NOW() - INTERVAL '21 days', NOW() - INTERVAL '21 days'),
  ((SELECT group_id FROM groups WHERE name = 'Christchurch City Trappers'), (SELECT user_id FROM users WHERE username = 'cwhite'), 'Travis Wetland: stations are in, please log every check', 'For our wetland reserve weve gone with ten DOC 150s/200s in tunnels so we dont disturb the bird life. Important: please log "Still set, bait OK" as a real check, not a skip — the AC for the council reporting needs every visit recorded.', 'published', NOW() - INTERVAL '4 days', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days'),
  ((SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), (SELECT user_id FROM users WHERE username = 'dlee'), 'Hinewai 50-trap ridge — pilot ready', 'The big one is in. Fifty traps along the main Hinewai ridge between the Hugh Wilson saddle and the kahikatea grove. Bo and I will be doing the first systematic run next weekend. If youre keen to shadow, ping me.', 'published', NOW() - INTERVAL '10 days', NOW() - INTERVAL '9 days', NOW() - INTERVAL '9 days'),
  ((SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), (SELECT user_id FROM users WHERE username = 'enyberg'), 'Otanerito valley — Wainui bait station network commissioning', 'Twenty Philproof/Protecta stations now along the valley floor. First-fill goes in this Saturday — Brodifacoum block, rats as the primary target. Please use the bait station record form, not the trap form.', 'published', NOW() - INTERVAL '31 days', NOW() - INTERVAL '30 days', NOW() - INTERVAL '30 days'),
  ((SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), (SELECT user_id FROM users WHERE username = 'dlee'), 'Draft: summer volunteer roster', 'Working draft for the December–February roster. Not published yet — will share for feedback before locking in.', 'draft', NOW() - INTERVAL '2 days', NULL, NOW() - INTERVAL '2 days')
;


INSERT INTO group_update_likes (update_id, user_id, liked_at)
SELECT u.update_id, usr.user_id, NOW() - (random() * INTERVAL '20 days')
FROM group_updates u
CROSS JOIN users usr
WHERE u.status = 'published'
  AND usr.username IN ('enyberg','fgrant','gwatson','iford','jmoss','hpatel','bkim','dlee','smitchell')
  AND random() < 0.55
ON CONFLICT DO NOTHING;


INSERT INTO group_update_comments (update_id, author_id, body, status, created_at)
VALUES
  ((SELECT update_id FROM group_updates WHERE title = 'Autumn check round-up — best month since program started' LIMIT 1),
   (SELECT user_id FROM users WHERE username = 'enyberg'),
   'Great month! NCT-02 in particular had a juvenile stoat which is a good sign for early dispersal — let''s push the line east.',
   'visible', NOW() - INTERVAL '12 days'),
  ((SELECT update_id FROM group_updates WHERE title = 'Autumn check round-up — best month since program started' LIMIT 1),
   (SELECT user_id FROM users WHERE username = 'fgrant'),
   'Big effort. Happy to take the next Saturday round if needed.',
   'visible', NOW() - INTERVAL '11 days'),
  ((SELECT update_id FROM group_updates WHERE title = 'Hinewai 50-trap ridge — pilot ready' LIMIT 1),
   (SELECT user_id FROM users WHERE username = 'gwatson'),
   'Keen to help with the first run. Available next Sat from 7am.',
   'visible', NOW() - INTERVAL '8 days'),
  ((SELECT update_id FROM group_updates WHERE title = 'Port Hills Summit Track officially open' LIMIT 1),
   (SELECT user_id FROM users WHERE username = 'hpatel'),
   'Quick note — coordinates on PHS-23 looked off when I pinged it yesterday, will re-survey on Sunday.',
   'visible', NOW() - INTERVAL '18 days'),
  ((SELECT update_id FROM group_updates WHERE title = 'Otanerito valley — Wainui bait station network commissioning' LIMIT 1),
   (SELECT user_id FROM users WHERE username = 'bkim'),
   'Confirmed for Saturday. Bringing two extra bait blocks just in case.',
   'visible', NOW() - INTERVAL '28 days')
ON CONFLICT DO NOTHING;

INSERT INTO knowledge_articles (category_id, author_id, author_group_id, title, summary, body, status, is_featured, current_version, reviewed_by, reviewed_at, created_at, published_at, updated_at) VALUES
  ((SELECT category_id FROM knowledge_categories WHERE slug = 'trap-management'), (SELECT user_id FROM users WHERE username = 'bkim'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), 'DOC 200 — pre-set checklist', 'Five things to inspect before arming a DOC 200 to keep operator and target welfare front-of-mind.', 'Before you arm a DOC 200, walk the trap through:

1. Spring tension — does the trigger drop with a firm pencil push?
2. Box integrity — no chew marks on the entrance baffles?
3. Bait condition — fresh, dry, no mould.
4. Surrounds — clear leaf litter inside the entry so the target lines up nose-first.
5. Cover — heavy enough that it wont shift in heavy wind.

If any of the five fail, log Needs maintenance and dont re-arm until next round.', 'published', TRUE, 1, (SELECT user_id FROM users WHERE username = 'smitchell'), NOW() - INTERVAL '60 days', NOW() - INTERVAL '61 days', NOW() - INTERVAL '60 days', NOW() - INTERVAL '59 days'),
  ((SELECT category_id FROM knowledge_categories WHERE slug = 'bait-stations'), (SELECT user_id FROM users WHERE username = 'cwhite'), (SELECT group_id FROM groups WHERE name = 'Christchurch City Trappers'), 'Choosing between Philproof and Protecta LP for urban green corridors', 'Quick decision tree on station type for council-managed green corridors with public access.', 'For corridors with public foot traffic the Philproof box is generally safer — it has a smaller mouth that hands wont fit into and the bait sits behind two internal barriers. Protecta LP is great for heavier rodent loads but the wide mouth is a liability where kids walk past.

Rule of thumb:
- Sealed path edge with signage: Protecta LP fine.
- Open reserve with no fence: Philproof.
- Tunnel mount on a tree: either, but Philproof is lighter.', 'published', TRUE, 1, (SELECT user_id FROM users WHERE username = 'smitchell'), NOW() - INTERVAL '45 days', NOW() - INTERVAL '46 days', NOW() - INTERVAL '45 days', NOW() - INTERVAL '44 days'),
  ((SELECT category_id FROM knowledge_categories WHERE slug = 'seasonal-advice'), (SELECT user_id FROM users WHERE username = 'dlee'), (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), 'Mid-autumn intensification — why we double-up checks May–June', 'Stoats and rats move into new territory through autumn. A summary of what weve learned over three seasons.', 'Through April–June the kits born in spring start dispersing, and rat populations push into new niches as natural food drops. We see the spike in catches in our analytics dashboards every year. Double-up the line check frequency for those eight weeks and have spare bait in the field bag — the round will take longer but the catch numbers reward it.', 'published', FALSE, 1, (SELECT user_id FROM users WHERE username = 'smitchell'), NOW() - INTERVAL '32 days', NOW() - INTERVAL '33 days', NOW() - INTERVAL '32 days', NOW() - INTERVAL '31 days'),
  ((SELECT category_id FROM knowledge_categories WHERE slug = 'species-id'), (SELECT user_id FROM users WHERE username = 'gwatson'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), 'Stoat vs weasel — three field tests', 'A quick guide to distinguishing stoats from weasels when you cant use the tail.', '1. Size — adult stoats are larger and longer in the body. A weasel feels light when you lift it.
2. Tail tip — stoat has a clear black tip; weasels tail is uniformly brown and shorter.
3. Belly line — stoat has a clean horizontal cut between brown and cream. Weasels belly line is wavy.

When in doubt, photo and ask in the chat before logging.', 'published', FALSE, 1, (SELECT user_id FROM users WHERE username = 'smitchell'), NOW() - INTERVAL '21 days', NOW() - INTERVAL '22 days', NOW() - INTERVAL '21 days', NOW() - INTERVAL '20 days'),
  ((SELECT category_id FROM knowledge_categories WHERE slug = 'safety'), (SELECT user_id FROM users WHERE username = 'smitchell'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), 'Carrying brodifacoum bait — the three-bag rule', 'Personal protective protocol for moving anticoag bait between vehicle and station.', 'When carrying brodifacoum bait blocks:
- Inner bag (Ziploc) holds the blocks.
- Outer bag (tough polyethylene) holds the inner — never directly handle blocks.
- Disposal bag for any wrapping or contaminated paper towel.

Wash hands before eating, even after the standard nitrile gloves come off.', 'published', FALSE, 1, (SELECT user_id FROM users WHERE username = 'smitchell'), NOW() - INTERVAL '90 days', NOW() - INTERVAL '91 days', NOW() - INTERVAL '90 days', NOW() - INTERVAL '89 days'),
  ((SELECT category_id FROM knowledge_categories WHERE slug = 'trap-management'), (SELECT user_id FROM users WHERE username = 'enyberg'), (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), 'Hinewai ridge line — operator handbook (draft)', 'Draft handbook for the new 50-trap Hinewai ridge programme.', 'Operator handbook for the Hinewai ridge programme. Covers access, vehicle storage at the Wilson saddle, suggested round order (top to bottom for fastest re-bait), and emergency contacts. Still in draft — please flag anything missing before we publish.', 'pending_review', FALSE, 1, NULL, NULL, NOW() - INTERVAL '4 days', NULL, NOW() - INTERVAL '4 days'),
  ((SELECT category_id FROM knowledge_categories WHERE slug = 'bait-stations'), (SELECT user_id FROM users WHERE username = 'fgrant'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), 'Vineyard bait stations — what were trialling', 'First-month notes on the vineyard block pilot.', 'Five Philproof/Mini-Philproof stations going around the vineyard edge. Aim is to see whether smaller stations close to vine trunks deter rats from chewing the irrigation drippers (a long-running pain point for the contractor). Notes after the first month suggest yes, but we need three more checks before we draw firm conclusions.', 'pending_review', FALSE, 1, NULL, NULL, NOW() - INTERVAL '1 days', NULL, NOW() - INTERVAL '1 days'),
  ((SELECT category_id FROM knowledge_categories WHERE slug = 'species-id'), (SELECT user_id FROM users WHERE username = 'iford'), (SELECT group_id FROM groups WHERE name = 'Christchurch City Trappers'), 'Hedgehog catch — when to log as a non-target', 'Decision flow for hedgehog catches: target species or non-target depending on the project context.', 'For most urban Christchurch sites hedgehog is the intended target along with rats. For the Travis Wetland reserve were actively recording hedgehogs because they predate ground-nesting bird eggs. Log as a real catch with species Hedgehog. If you ever catch a non-target like a blackbird (rare) please flag in notes.', 'published', FALSE, 1, (SELECT user_id FROM users WHERE username = 'smitchell'), NOW() - INTERVAL '12 days', NOW() - INTERVAL '13 days', NOW() - INTERVAL '12 days', NOW() - INTERVAL '11 days')
;


INSERT INTO knowledge_article_versions (article_id, version_no, title, body, summary, edited_by, edited_at, note)
SELECT a.article_id, 1, a.title, a.body, a.summary, a.author_id, a.created_at, 'Initial version'
FROM knowledge_articles a
WHERE NOT EXISTS (
    SELECT 1 FROM knowledge_article_versions v WHERE v.article_id = a.article_id AND v.version_no = 1
);


INSERT INTO knowledge_moderation_log (article_id, actor_id, action, note, created_at)
SELECT a.article_id, a.reviewed_by, 'approved', 'Approved for publication.', a.reviewed_at
FROM knowledge_articles a
WHERE a.status = 'published' AND a.reviewed_by IS NOT NULL;


INSERT INTO knowledge_moderation_log (article_id, actor_id, action, note, created_at)
SELECT a.article_id,
       (SELECT user_id FROM users WHERE username = 'smitchell'),
       'featured',
       'Featured on the hub home.',
       a.published_at + INTERVAL '1 day'
FROM knowledge_articles a
WHERE a.is_featured = TRUE;

INSERT INTO kb_articles (category_id, title, body, is_published, created_by, updated_by) VALUES
  ((SELECT category_id FROM kb_categories WHERE name = 'Account & Login'), 'I lost my password — how do I reset it?', 'From the login page choose "Forgot password" and follow the email link. The link is single-use and expires after one hour. If you dont get an email within five minutes check your spam folder, then contact the support team via the helpdesk form.', TRUE, (SELECT user_id FROM users WHERE username = 'smitchell'), (SELECT user_id FROM users WHERE username = 'smitchell')),
  ((SELECT category_id FROM kb_categories WHERE name = 'Account & Login'), 'How do I change my email or phone number?', 'Open the user menu (top-right avatar) and choose "Edit profile". The change is immediate — there is no email re-verification step at this time.', TRUE, (SELECT user_id FROM users WHERE username = 'smitchell'), (SELECT user_id FROM users WHERE username = 'smitchell')),
  ((SELECT category_id FROM kb_categories WHERE name = 'Lines & Traps'), 'Why cant I see the "Add Trap" button on a line?', 'Adding traps is restricted to Group Coordinators and Super Admins. If you are an Operator and need a trap added, ask your group coordinator or open a support request and include the line name and proposed code.', TRUE, (SELECT user_id FROM users WHERE username = 'smitchell'), (SELECT user_id FROM users WHERE username = 'smitchell')),
  ((SELECT category_id FROM kb_categories WHERE name = 'Lines & Traps'), 'A trap of mine has been damaged — what do I record?', 'Mark the trap as "Needs maintenance" on your next catch record and add a short note describing the damage. The trap remains on the line until a coordinator retires it.', TRUE, (SELECT user_id FROM users WHERE username = 'smitchell'), (SELECT user_id FROM users WHERE username = 'smitchell')),
  ((SELECT category_id FROM kb_categories WHERE name = 'Bait Stations'), 'What does the "Other" station type mean?', 'Use "Other" only when none of the listed types matches what is on the ground — for example a repurposed container or a non-standard tunnel. When you pick "Other", the system asks for a short description so coordinators know what is actually installed.', TRUE, (SELECT user_id FROM users WHERE username = 'smitchell'), (SELECT user_id FROM users WHERE username = 'smitchell')),
  ((SELECT category_id FROM kb_categories WHERE name = 'Records'), 'I made a mistake on a catch record — can I edit it?', 'Yes, find the record in My Records (Operators) or Catch Records (Coordinators/Admins) and choose Edit. The edit is logged with your user and a timestamp so the history stays auditable.', TRUE, (SELECT user_id FROM users WHERE username = 'smitchell'), (SELECT user_id FROM users WHERE username = 'smitchell'))
;

INSERT INTO group_operational_areas (group_id, geojson, updated_by) VALUES
  ((SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), '{"type":"Polygon","coordinates":[[[172.395,-43.620],[172.500,-43.620],[172.520,-43.660],[172.490,-43.700],[172.430,-43.790],[172.395,-43.760],[172.395,-43.620]]]}', (SELECT user_id FROM users WHERE username = 'smitchell')),
  ((SELECT group_id FROM groups WHERE name = 'Christchurch City Trappers'), '{"type":"Polygon","coordinates":[[[172.560,-43.440],[172.730,-43.440],[172.760,-43.520],[172.730,-43.620],[172.620,-43.640],[172.560,-43.580],[172.560,-43.440]]]}', (SELECT user_id FROM users WHERE username = 'smitchell')),
  ((SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), '{"type":"Polygon","coordinates":[[[172.880,-43.720],[173.080,-43.720],[173.110,-43.820],[173.080,-43.880],[172.940,-43.900],[172.880,-43.840],[172.880,-43.720]]]}', (SELECT user_id FROM users WHERE username = 'smitchell'))

ON CONFLICT (group_id) DO NOTHING;


SELECT setval('group_updates_update_id_seq',
              (SELECT COALESCE(MAX(update_id), 1) FROM group_updates));
SELECT setval('group_update_comments_comment_id_seq',
              (SELECT COALESCE(MAX(comment_id), 1) FROM group_update_comments));
SELECT setval('knowledge_articles_article_id_seq',
              (SELECT COALESCE(MAX(article_id), 1) FROM knowledge_articles));
SELECT setval('knowledge_article_versions_version_id_seq',
              (SELECT COALESCE(MAX(version_id), 1) FROM knowledge_article_versions));
SELECT setval('knowledge_moderation_log_log_id_seq',
              (SELECT COALESCE(MAX(log_id), 1) FROM knowledge_moderation_log));




-- ══════════════════════════════════════════════════════
-- EXPANSION SEED — PART 2
-- Fills the tables the line/trap/catch expansion missed:
-- 4 more groups at real NZ predator-control sites, 15 more
-- users spread across all groups, join requests and group
-- applications across every status, support tickets with
-- replies + status history, suspension + role-audit logs,
-- theme history snapshots and group overrides, and 3D-map
-- view-log entries so the analytics views aren't blank.
-- ══════════════════════════════════════════════════════


INSERT INTO groups (name, description, location, is_public, color_theme) VALUES
  ('Wellington Town Belt Trappers',
   'Volunteer-run trapping along the Wellington Town Belt — Polhill, Mt Victoria, and Otari-Wilton''s Bush. Focus on stoats and rats in urban green corridors.',
   'Wellington', TRUE,  '#3d9b67'),
  ('Otago Peninsula Conservation Trust',
   'Community conservation across the Otago Peninsula. Coastal cliffs, albatross colony surrounds, and Orokonui-adjacent farmland edges.',
   'Dunedin',    TRUE,  '#1a5c38'),
  ('Routeburn Tramping & Trapping',
   'Tramper-supported trap network along the Routeburn Track and its access valleys. Long-line lower-density coverage in alpine bush.',
   'Queenstown', FALSE, '#2d7a4f'),
  ('Tūmanako Wetland Restoration',
   'Wetland restoration on a private trust block near Temuka. Bait stations on the farmland boundary; pilot stage.',
   'Temuka',     FALSE, '#236b43')
ON CONFLICT (name) DO NOTHING;

INSERT INTO users (username, email, password_hash, first_name, last_name, is_super_admin, account_status, phone, date_joined, last_login) VALUES
  ('nharris', 'nharris@example.nz', '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Nikau', 'Harris', FALSE, 'active', '021 695 4190', NOW() - INTERVAL '291 days', NOW() - INTERVAL '30 days'),
  ('oroberts', 'oroberts@example.nz', '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Olivia', 'Roberts', FALSE, 'active', '021 467 8653', NOW() - INTERVAL '39 days', NOW() - INTERVAL '22 days'),
  ('pwilson', 'pwilson@example.nz', '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Pete', 'Wilson', FALSE, 'active', '021 615 4514', NOW() - INTERVAL '323 days', NOW() - INTERVAL '8 days'),
  ('qbrown', 'qbrown@example.nz', '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Quinn', 'Brown', FALSE, 'active', '021 395 8953', NOW() - INTERVAL '369 days', NOW() - INTERVAL '26 days'),
  ('vadams', 'vadams@example.nz', '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Vicky', 'Adams', FALSE, 'active', '021 317 6390', NOW() - INTERVAL '239 days', NOW() - INTERVAL '3 days'),
  ('wjones', 'wjones@example.nz', '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Will', 'Jones', FALSE, 'active', '021 361 4166', NOW() - INTERVAL '97 days', NOW() - INTERVAL '3 days'),
  ('xcampbell', 'xcampbell@example.nz', '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Xena', 'Campbell', FALSE, 'active', '021 555 9803', NOW() - INTERVAL '202 days', NOW() - INTERVAL '7 days'),
  ('yhall', 'yhall@example.nz', '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Yusuf', 'Hall', FALSE, 'active', '021 583 6341', NOW() - INTERVAL '137 days', NOW() - INTERVAL '21 days'),
  ('zking', 'zking@example.nz', '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Zara', 'King', FALSE, 'active', '021 910 7617', NOW() - INTERVAL '231 days', NOW() - INTERVAL '7 days'),
  ('aanderson', 'aanderson@example.nz', '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Aroha', 'Anderson', FALSE, 'active', '021 164 8047', NOW() - INTERVAL '254 days', NOW() - INTERVAL '10 days'),
  ('rsmith', 'rsmith@example.nz', '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Rangi', 'Smith', FALSE, 'active', '021 316 2815', NOW() - INTERVAL '348 days', NOW() - INTERVAL '27 days'),
  ('stenh', 'stenh@example.nz', '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Sina', 'Tenh', FALSE, 'active', '021 739 6382', NOW() - INTERVAL '355 days', NOW() - INTERVAL '28 days'),
  ('uthomas', 'uthomas@example.nz', '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Una', 'Thomas', FALSE, 'active', '021 373 7465', NOW() - INTERVAL '209 days', NOW() - INTERVAL '8 days'),
  ('ldavis', 'ldavis@example.nz', '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Lou', 'Davis', FALSE, 'active', '021 533 2258', NOW() - INTERVAL '222 days', NOW() - INTERVAL '24 days'),
  ('mhill', 'mhill@example.nz', '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Mia', 'Hill', FALSE, 'active', '021 784 7855', NOW() - INTERVAL '18 days', NOW() - INTERVAL '28 days')
ON CONFLICT (username) DO NOTHING;

INSERT INTO group_memberships (user_id, group_id, role)
SELECT u.user_id, g.group_id, m.role::group_role_type
FROM (VALUES
  ('nharris', 'Wellington Town Belt Trappers', 'Group Coordinator'),
  ('oroberts', 'Wellington Town Belt Trappers', 'Operator'),
  ('pwilson', 'Wellington Town Belt Trappers', 'Operator'),
  ('qbrown', 'Wellington Town Belt Trappers', 'Observer'),
  ('vadams', 'Otago Peninsula Conservation Trust', 'Group Coordinator'),
  ('wjones', 'Otago Peninsula Conservation Trust', 'Operator'),
  ('xcampbell', 'Otago Peninsula Conservation Trust', 'Observer'),
  ('yhall', 'Routeburn Tramping & Trapping', 'Group Coordinator'),
  ('zking', 'Routeburn Tramping & Trapping', 'Operator'),
  ('aanderson', 'Routeburn Tramping & Trapping', 'Observer'),
  ('rsmith', 'Tūmanako Wetland Restoration', 'Group Coordinator'),
  ('stenh', 'Tūmanako Wetland Restoration', 'Operator'),
  ('uthomas', 'Tūmanako Wetland Restoration', 'Observer'),
  ('ldavis', 'Predator Free Lincoln University', 'Operator'),
  ('mhill', 'Christchurch City Trappers', 'Operator'),
  ('oroberts', 'Otago Peninsula Conservation Trust', 'Observer'),
  ('wjones', 'Routeburn Tramping & Trapping', 'Observer'),
  ('zking', 'Banks Peninsula Restoration', 'Operator'),
  ('stenh', 'Predator Free Lincoln University', 'Observer'),
  ('ldavis', 'Christchurch City Trappers', 'Observer'),
  ('mhill', 'Predator Free Lincoln University', 'Observer'),
  ('vadams', 'Tūmanako Wetland Restoration', 'Observer')
) AS m(username, group_name, role)
JOIN users u ON u.username = m.username
JOIN groups g ON g.name = m.group_name
ON CONFLICT (user_id, group_id) DO NOTHING;

INSERT INTO group_join_requests (user_id, group_id, status, message, requested_at) VALUES
  ((SELECT user_id FROM users WHERE username = 'uthomas'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), 'pending', 'I work near campus, would love to help out a couple of evenings a week.', NOW() - INTERVAL '2 days'),
  ((SELECT user_id FROM users WHERE username = 'xcampbell'), (SELECT group_id FROM groups WHERE name = 'Christchurch City Trappers'), 'pending', 'Otago Peninsula member; visiting Christchurch for three months and keen to keep contributing.', NOW() - INTERVAL '5 days'),
  ((SELECT user_id FROM users WHERE username = 'aanderson'), (SELECT group_id FROM groups WHERE name = 'Wellington Town Belt Trappers'), 'pending', 'Tramper based out of Wellington over summer.', NOW() - INTERVAL '1 days'),
  ((SELECT user_id FROM users WHERE username = 'pwilson'), (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), 'approved', 'Joined BP after Akaroa weekend with the team.', NOW() - INTERVAL '45 days'),
  ((SELECT user_id FROM users WHERE username = 'oroberts'), (SELECT group_id FROM groups WHERE name = 'Christchurch City Trappers'), 'approved', 'Christchurch transplant from the Wellington team.', NOW() - INTERVAL '60 days'),
  ((SELECT user_id FROM users WHERE username = 'qbrown'), (SELECT group_id FROM groups WHERE name = 'Otago Peninsula Conservation Trust'), 'rejected', 'Tried to join two groups in one week — lets revisit.', NOW() - INTERVAL '20 days'),
  ((SELECT user_id FROM users WHERE username = 'trequest1'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), 'cancelled', 'Withdrew application.', NOW() - INTERVAL '40 days')
ON CONFLICT (user_id, group_id) WHERE status = 'pending' DO NOTHING;

INSERT INTO group_applications (user_id, proposed_name, description, location, justification, status, applied_at, decided_by, decided_at, decision_reason) VALUES
  ((SELECT user_id FROM users WHERE username = 'vadams'), 'Aoraki Predator Free', 'A community-led predator network across the lower Hooker Valley and Kea Point. Focus on stoat and rat control during the kea breeding season (Oct–Feb). Operating from the DOC Visitor Centre car park as a logistics base.', 'Aoraki/Mt Cook', 'Twelve registered volunteers; DOC concession in progress; partnership with Project Kea who are providing 30 DOC 250 traps and bait at cost.', 'pending', NOW() - INTERVAL '3 days', NULL, NULL, NULL),
  ((SELECT user_id FROM users WHERE username = 'yhall'), 'Lower Hollyford Stoat Lines', 'Two long stoat lines along the Lower Hollyford road and a side line up to Lake Marian. Designed to plug the gap between the Routeburn trap network and DOCs own lines at the Marian Falls car park.', 'Hollyford Valley', 'Six experienced trampers (three are NZTA registered drivers), letters of support from the Routeburn Tramping & Trapping group, and 60 m of marked-out track surveys submitted.', 'pending', NOW() - INTERVAL '8 days', NULL, NULL, NULL),
  ((SELECT user_id FROM users WHERE username = 'nharris'), 'Wellington Coastal Lines', 'Extension of the Wellington Town Belt programme down onto the south coast — Tarakena Bay, Owhiro Bay, and the Cook Strait facing slopes around Red Rocks. Adds coastal coverage that the Town Belt group cant easily reach.', 'South Coast, Wellington', 'Eight active members; coordinated with Wellington City Council Parks team; equipment funded by a Predator Free Wellington pilot grant.', 'approved', NOW() - INTERVAL '35 days', (SELECT user_id FROM users WHERE username = 'smitchell'), NOW() - INTERVAL '33 days', 'Solid plan, clear location, named volunteers.'),
  ((SELECT user_id FROM users WHERE username = 'wjones'), 'Otago Albatross Surrounds', 'Tight perimeter trap network around the Royal Albatross Centre to reduce predation pressure on chicks during the late-summer fledging window.', 'Taiaroa Head', 'Three named operators; informal partnership with the Trust; equipment loaned by Otago Peninsula Conservation Trust.', 'rejected', NOW() - INTERVAL '25 days', (SELECT user_id FROM users WHERE username = 'smitchell'), NOW() - INTERVAL '23 days', 'Overlaps with existing Otago Peninsula Conservation Trust coverage. Please join them instead.'),
  ((SELECT user_id FROM users WHERE username = 'rsmith'), 'Tūmanako Pilot Block — old proposal', 'Wetland restoration block with bait stations around the boundary. Single-property pilot, then scale out.', 'Temuka', 'Two operators, landowner approval; equipment to be sourced after approval.', 'rejected', NOW() - INTERVAL '90 days', (SELECT user_id FROM users WHERE username = 'smitchell'), NOW() - INTERVAL '88 days', 'Resubmitted later as the formal Tūmanako Wetland Restoration which was approved.')
;

INSERT INTO user_notifications (user_id, message, category, url, group_id, is_active, created_at) VALUES
  ((SELECT user_id FROM users WHERE username = 'bkim'), 'Reminder: TWR-07 is overdue for a check.', 'warning', NULL, NULL, TRUE, NOW() - INTERVAL '50 days 0 hours'),
  ((SELECT user_id FROM users WHERE username = 'pwilson'), 'Knowledge Hub article "Autumn check round-up" needs your review.', 'warning', '/hub/moderation', NULL, TRUE, NOW() - INTERVAL '52 days 4 hours'),
  ((SELECT user_id FROM users WHERE username = 'yhall'), 'Your join request for Banks Peninsula Restoration has been approved.', 'success', '/select-group', NULL, TRUE, NOW() - INTERVAL '48 days 4 hours'),
  ((SELECT user_id FROM users WHERE username = 'pwilson'), 'Support ticket #19 assigned to you.', 'info', '/support/queue', NULL, TRUE, NOW() - INTERVAL '31 days 16 hours'),
  ((SELECT user_id FROM users WHERE username = 'jmoss'), 'Group update posted: "Autumn check round-up"', 'info', '/updates', NULL, FALSE, NOW() - INTERVAL '4 days 1 hours'),
  ((SELECT user_id FROM users WHERE username = 'pwilson'), 'Your password was changed.', 'info', NULL, NULL, TRUE, NOW() - INTERVAL '44 days 14 hours'),
  ((SELECT user_id FROM users WHERE username = 'ldavis'), 'Your join request for Otago Peninsula Conservation Trust has been rejected.', 'warning', '/select-group', NULL, FALSE, NOW() - INTERVAL '8 days 21 hours'),
  ((SELECT user_id FROM users WHERE username = 'bkim'), 'New trap catch logged on Otago Peninsula Conservation Trust — Rat at NCT-02.', 'info', '/lines', NULL, FALSE, NOW() - INTERVAL '56 days 9 hours'),
  ((SELECT user_id FROM users WHERE username = 'vadams'), 'Knowledge Hub article "Autumn check round-up" needs your review.', 'warning', '/hub/moderation', NULL, TRUE, NOW() - INTERVAL '35 days 22 hours'),
  ((SELECT user_id FROM users WHERE username = 'rsmith'), 'Knowledge Hub article "Autumn check round-up" needs your review.', 'warning', '/hub/moderation', NULL, TRUE, NOW() - INTERVAL '43 days 10 hours'),
  ((SELECT user_id FROM users WHERE username = 'dlee'), 'Your join request for Banks Peninsula Restoration has been rejected.', 'warning', '/select-group', NULL, TRUE, NOW() - INTERVAL '13 days 13 hours'),
  ((SELECT user_id FROM users WHERE username = 'jparata'), 'Your join request for Christchurch City Trappers has been rejected.', 'warning', '/select-group', NULL, TRUE, NOW() - INTERVAL '17 days 20 hours'),
  ((SELECT user_id FROM users WHERE username = 'enyberg'), 'New trap catch logged on Predator Free Lincoln University — Mouse at TWR-07.', 'info', '/lines', NULL, TRUE, NOW() - INTERVAL '36 days 1 hours'),
  ((SELECT user_id FROM users WHERE username = 'cwhite'), 'Knowledge Hub article "DOC 200 — pre-set checklist" needs your review.', 'warning', '/hub/moderation', NULL, TRUE, NOW() - INTERVAL '12 days 17 hours'),
  ((SELECT user_id FROM users WHERE username = 'lchen'), 'Your password was changed.', 'info', NULL, NULL, TRUE, NOW() - INTERVAL '1 days 4 hours'),
  ((SELECT user_id FROM users WHERE username = 'pwilson'), 'Group update posted: "DOC 200 — pre-set checklist"', 'info', '/updates', NULL, FALSE, NOW() - INTERVAL '25 days 20 hours'),
  ((SELECT user_id FROM users WHERE username = 'cwhite'), 'Your join request for Predator Free Lincoln University has been approved.', 'success', '/select-group', NULL, TRUE, NOW() - INTERVAL '42 days 3 hours'),
  ((SELECT user_id FROM users WHERE username = 'oroberts'), 'New trap catch logged on Predator Free Lincoln University — Possum at NCT-02.', 'info', '/lines', NULL, TRUE, NOW() - INTERVAL '42 days 6 hours'),
  ((SELECT user_id FROM users WHERE username = 'jparata'), 'Knowledge Hub article "Hinewai 50-trap ridge — pilot ready" needs your review.', 'warning', '/hub/moderation', NULL, TRUE, NOW() - INTERVAL '34 days 17 hours'),
  ((SELECT user_id FROM users WHERE username = 'nharris'), 'Knowledge Hub article "DOC 200 — pre-set checklist" needs your review.', 'warning', '/hub/moderation', NULL, FALSE, NOW() - INTERVAL '15 days 13 hours'),
  ((SELECT user_id FROM users WHERE username = 'rsmith'), 'New incidental observation in Christchurch City Trappers (Predator sighting).', 'info', '/observations', NULL, TRUE, NOW() - INTERVAL '37 days 10 hours'),
  ((SELECT user_id FROM users WHERE username = 'rsmith'), 'Reminder: NCT-02 is overdue for a check.', 'warning', NULL, NULL, TRUE, NOW() - INTERVAL '45 days 6 hours'),
  ((SELECT user_id FROM users WHERE username = 'rsmith'), 'Your join request for Predator Free Lincoln University has been approved.', 'success', '/select-group', NULL, TRUE, NOW() - INTERVAL '59 days 14 hours'),
  ((SELECT user_id FROM users WHERE username = 'ldavis'), 'Group update posted: "Hinewai 50-trap ridge — pilot ready"', 'info', '/updates', NULL, TRUE, NOW() - INTERVAL '51 days 20 hours'),
  ((SELECT user_id FROM users WHERE username = 'fgrant'), 'Your join request for Christchurch City Trappers has been approved.', 'success', '/select-group', NULL, TRUE, NOW() - INTERVAL '7 days 22 hours'),
  ((SELECT user_id FROM users WHERE username = 'ldavis'), 'Your join request for Otago Peninsula Conservation Trust has been rejected.', 'warning', '/select-group', NULL, TRUE, NOW() - INTERVAL '46 days 2 hours'),
  ((SELECT user_id FROM users WHERE username = 'smitchell'), 'New trap catch logged on Otago Peninsula Conservation Trust — Stoat at HRM-15.', 'info', '/lines', NULL, TRUE, NOW() - INTERVAL '22 days 6 hours'),
  ((SELECT user_id FROM users WHERE username = 'hpatel'), 'Welcome to Tiaki! Pick a group to get started.', 'info', '/select-group', NULL, FALSE, NOW() - INTERVAL '46 days 6 hours'),
  ((SELECT user_id FROM users WHERE username = 'jmoss'), 'New trap catch logged on Banks Peninsula Restoration — Mouse at SCT-04.', 'info', '/lines', NULL, TRUE, NOW() - INTERVAL '12 days 16 hours'),
  ((SELECT user_id FROM users WHERE username = 'cwhite'), 'Welcome to Tiaki! Pick a group to get started.', 'info', '/select-group', NULL, TRUE, NOW() - INTERVAL '33 days 0 hours'),
  ((SELECT user_id FROM users WHERE username = 'jparata'), 'Knowledge Hub article "Hinewai 50-trap ridge — pilot ready" needs your review.', 'warning', '/hub/moderation', NULL, TRUE, NOW() - INTERVAL '30 days 4 hours'),
  ((SELECT user_id FROM users WHERE username = 'hpatel'), 'Your join request for Predator Free Lincoln University has been rejected.', 'warning', '/select-group', NULL, TRUE, NOW() - INTERVAL '36 days 22 hours'),
  ((SELECT user_id FROM users WHERE username = 'ldavis'), 'Your password was changed.', 'info', NULL, NULL, TRUE, NOW() - INTERVAL '17 days 12 hours'),
  ((SELECT user_id FROM users WHERE username = 'fgrant'), 'New trap catch logged on Predator Free Lincoln University — Possum at TWR-07.', 'info', '/lines', NULL, TRUE, NOW() - INTERVAL '6 days 9 hours'),
  ((SELECT user_id FROM users WHERE username = 'cwhite'), 'Group update posted: "Hinewai 50-trap ridge — pilot ready"', 'info', '/updates', NULL, FALSE, NOW() - INTERVAL '24 days 20 hours')
;


INSERT INTO user_suspension_log (target_user_id, actor_user_id, action, reason, created_at) VALUES
  ((SELECT user_id FROM users WHERE username = 'ktaylor'),
   (SELECT user_id FROM users WHERE username = 'lchen'),
   'suspended',
   'Multiple reports of inappropriate comments on Knowledge Hub article — pending review by Group Coordinator.',
   NOW() - INTERVAL '14 days'),
  ((SELECT user_id FROM users WHERE username = 'ktaylor'),
   (SELECT user_id FROM users WHERE username = 'mreid'),
   'reinstated',
   'Reviewed with Group Coordinator; comments deleted by author. Reinstating with a written warning.',
   NOW() - INTERVAL '8 days'),
  ((SELECT user_id FROM users WHERE username = 'trequest2'),
   (SELECT user_id FROM users WHERE username = 'lchen'),
   'suspended',
   'Repeated failed login attempts from unusual IPs — suspending while we verify identity.',
   NOW() - INTERVAL '3 days');


INSERT INTO support_tech_audit_log (target_user_id, actor_user_id, action, created_at) VALUES
  ((SELECT user_id FROM users WHERE username = 'lchen'),
   (SELECT user_id FROM users WHERE username = 'smitchell'),
   'granted', NOW() - INTERVAL '350 days'),
  ((SELECT user_id FROM users WHERE username = 'mreid'),
   (SELECT user_id FROM users WHERE username = 'smitchell'),
   'granted', NOW() - INTERVAL '350 days'),
  ((SELECT user_id FROM users WHERE username = 'jparata'),
   (SELECT user_id FROM users WHERE username = 'smitchell'),
   'granted', NOW() - INTERVAL '500 days'),
  ((SELECT user_id FROM users WHERE username = 'jparata'),
   (SELECT user_id FROM users WHERE username = 'smitchell'),
   'revoked', NOW() - INTERVAL '380 days');

INSERT INTO support_tickets (submitted_by, group_id, request_type, title, description, priority, status, assigned_to, created_at, updated_at) VALUES
  ((SELECT user_id FROM users WHERE username = 'iford'), (SELECT gm.group_id FROM group_memberships gm JOIN users u ON u.user_id = gm.user_id WHERE u.username = 'iford' LIMIT 1), 'Help', 'Knowledge Hub article won''t save when I add a photo', 'I''m writing a Knowledge Hub article and as soon as I attach a photo (JPG, ~500KB) the Save Draft button does nothing. Without the photo the save works fine. Tried Chrome and Firefox on the same laptop. No errors visible on the page — just no save.', 'Medium', 'New', NULL, NOW() - INTERVAL '0 days', NOW() - INTERVAL '0 days'),
  ((SELECT user_id FROM users WHERE username = 'jmoss'), (SELECT gm.group_id FROM group_memberships gm JOIN users u ON u.user_id = gm.user_id WHERE u.username = 'jmoss' LIMIT 1), 'Bug Report', 'Map3D viewer is white — appears to be a WebGL issue on my laptop', 'The 3D map page loads but the actual stage is blank white. The toolbar at the top renders correctly, and the legend shows up at the bottom — just nothing in between. Old Lenovo Yoga, integrated Intel graphics. Possibly a WebGL / Three.js issue but worth checking the page first.', 'Low', 'New', NULL, NOW() - INTERVAL '1 days', NOW() - INTERVAL '0 days'),
  ((SELECT user_id FROM users WHERE username = 'hpatel'), (SELECT gm.group_id FROM group_memberships gm JOIN users u ON u.user_id = gm.user_id WHERE u.username = 'hpatel' LIMIT 1), 'Help', 'How do I assign multiple operators to the same trap line?', 'I''ve got two operators sharing the Lake Edge line over winter — Erik and Fiona alternating weekends. The Assign Operators page only seems to let me pick one. Am I missing a multi-select, or do I need to swap them each round?', 'Low', 'Resolved', (SELECT user_id FROM users WHERE username = 'lchen'), NOW() - INTERVAL '12 days', NOW() - INTERVAL '11 days'),
  ((SELECT user_id FROM users WHERE username = 'cwhite'), (SELECT gm.group_id FROM group_memberships gm JOIN users u ON u.user_id = gm.user_id WHERE u.username = 'cwhite' LIMIT 1), 'Bug Report', 'Group Updates page is sorted oldest-first — shouldn''t it be newest?', 'On the Group Updates list, the oldest update is at the top and the newest at the bottom. Pretty sure this should be reversed — newest first is the usual pattern. Easy fix on the SQL ORDER BY.', 'Medium', 'Open', (SELECT user_id FROM users WHERE username = 'mreid'), NOW() - INTERVAL '4 days', NOW() - INTERVAL '3 days'),
  ((SELECT user_id FROM users WHERE username = 'fgrant'), (SELECT gm.group_id FROM group_memberships gm JOIN users u ON u.user_id = gm.user_id WHERE u.username = 'fgrant' LIMIT 1), 'Help', 'CSV export from Catches page is including retired traps', 'I exported the catch records CSV for the last three months for council reporting, but the export includes catches from traps that were retired before that period. Filter for is_retired = false should be applied to the CSV query the same way it''s applied to the on-screen list.', 'Medium', 'Open', (SELECT user_id FROM users WHERE username = 'lchen'), NOW() - INTERVAL '6 days', NOW() - INTERVAL '5 days'),
  ((SELECT user_id FROM users WHERE username = 'oroberts'), (SELECT gm.group_id FROM group_memberships gm JOIN users u ON u.user_id = gm.user_id WHERE u.username = 'oroberts' LIMIT 1), 'Help', 'I can''t see the New Update button as Group Coordinator', 'Logged in as Group Coordinator for Wellington Town Belt Trappers. The Updates page renders but the "New Update" button at the top right is missing. Browser console doesn''t show JS errors. Did permissions change recently?', 'High', 'Stalled', (SELECT user_id FROM users WHERE username = 'mreid'), NOW() - INTERVAL '10 days', NOW() - INTERVAL '9 days'),
  ((SELECT user_id FROM users WHERE username = 'nharris'), (SELECT gm.group_id FROM group_memberships gm JOIN users u ON u.user_id = gm.user_id WHERE u.username = 'nharris' LIMIT 1), 'Bug Report', 'Account settings 500 error when uploading a profile photo over 2MB', 'Tried to update my profile photo on Wednesday and got a Flask 500 page. The image was 3.2MB. Resizing to under 2MB worked. The form should ideally validate before submit with a friendly error rather than crashing — also the 2MB limit isn''t mentioned on the upload field.', 'High', 'Resolved', (SELECT user_id FROM users WHERE username = 'mreid'), NOW() - INTERVAL '22 days', NOW() - INTERVAL '21 days'),
  ((SELECT user_id FROM users WHERE username = 'gwatson'), (SELECT gm.group_id FROM group_memberships gm JOIN users u ON u.user_id = gm.user_id WHERE u.username = 'gwatson' LIMIT 1), 'Help', 'Suggestion: add a "duplicate this catch" button for repeat checks', 'Loving the system. When I do a round of identical "Still set, bait OK" checks across 20 traps, I''m re-typing the same fields on every record. A "Duplicate previous catch" button on the Add Catch screen would save a lot of clicks.', 'Low', 'Resolved', (SELECT user_id FROM users WHERE username = 'lchen'), NOW() - INTERVAL '35 days', NOW() - INTERVAL '34 days')
;


INSERT INTO ticket_replies (ticket_id, author_id, body, created_at)
SELECT st.ticket_id, st.submitted_by,
       'Adding a screenshot in the second reply — let me know if more detail is needed.',
       st.created_at + INTERVAL '2 hours'
FROM support_tickets st
WHERE st.title IN (
  'Knowledge Hub article won''t save when I add a photo',
  'Map3D viewer is white — appears to be a WebGL issue on my laptop',
  'Group Updates page is sorted oldest-first — shouldn''t it be newest?',
  'I can''t see the New Update button as Group Coordinator',
  'Account settings 500 error when uploading a profile photo over 2MB'
);

INSERT INTO ticket_replies (ticket_id, author_id, body, created_at)
SELECT st.ticket_id, st.assigned_to,
       'Got it — looking into this now. Will follow up shortly with a status update.',
       st.created_at + INTERVAL '6 hours'
FROM support_tickets st
WHERE st.assigned_to IS NOT NULL
  AND st.title IN (
    'How do I assign multiple operators to the same trap line?',
    'Group Updates page is sorted oldest-first — shouldn''t it be newest?',
    'CSV export from Catches page is including retired traps',
    'I can''t see the New Update button as Group Coordinator',
    'Account settings 500 error when uploading a profile photo over 2MB',
    'Suggestion: add a "duplicate this catch" button for repeat checks'
);

INSERT INTO ticket_replies (ticket_id, author_id, body, created_at)
SELECT st.ticket_id, st.assigned_to,
       'Confirmed fix is live — please refresh and let me know if anything else looks off. Closing as Resolved.',
       st.updated_at
FROM support_tickets st
WHERE st.status = 'Resolved'
  AND st.title IN (
    'How do I assign multiple operators to the same trap line?',
    'Account settings 500 error when uploading a profile photo over 2MB',
    'Suggestion: add a "duplicate this catch" button for repeat checks'
);


INSERT INTO ticket_status_history (ticket_id, changed_by, old_status, new_status, note, changed_at)
SELECT st.ticket_id, st.assigned_to, 'New', 'Open',
       'Picked up from the queue.',
       st.created_at + INTERVAL '4 hours'
FROM support_tickets st
WHERE st.assigned_to IS NOT NULL
  AND st.title IN (
    'How do I assign multiple operators to the same trap line?',
    'Group Updates page is sorted oldest-first — shouldn''t it be newest?',
    'CSV export from Catches page is including retired traps',
    'I can''t see the New Update button as Group Coordinator',
    'Account settings 500 error when uploading a profile photo over 2MB',
    'Suggestion: add a "duplicate this catch" button for repeat checks'
  );

INSERT INTO ticket_status_history (ticket_id, changed_by, old_status, new_status, note, changed_at)
SELECT st.ticket_id, st.assigned_to, 'Open', 'Resolved',
       'Fixed and verified.',
       st.updated_at
FROM support_tickets st
WHERE st.status = 'Resolved'
  AND st.title IN (
    'How do I assign multiple operators to the same trap line?',
    'Account settings 500 error when uploading a profile photo over 2MB',
    'Suggestion: add a "duplicate this catch" button for repeat checks'
  );

INSERT INTO ticket_status_history (ticket_id, changed_by, old_status, new_status, note, changed_at)
SELECT st.ticket_id, st.assigned_to, 'Open', 'Stalled',
       'Waiting on submitter for additional info.',
       st.created_at + INTERVAL '3 days'
FROM support_tickets st
WHERE st.status = 'Stalled';


INSERT INTO group_themes (group_id, primary_color, secondary_color, background_color, button_style, font_heading, font_body, nav_position, content_width, updated_by, based_on_preset, updated_at)
VALUES
  ((SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'),
   '#0d3823', '#c65d3c', '#f5f0e6', 'rounded', 'Fraunces', 'IBM Plex Sans',
   'sidebar', 'wrap',
   (SELECT user_id FROM users WHERE username = 'dlee'),
   (SELECT preset_id FROM theme_presets ORDER BY preset_id LIMIT 1),
   NOW() - INTERVAL '12 days'),
  ((SELECT group_id FROM groups WHERE name = 'Wellington Town Belt Trappers'),
   '#1a4f6e', '#e8920a', '#f0f5f7', 'square',  'Cabin',    'IBM Plex Sans',
   'topbar',  'full',
   (SELECT user_id FROM users WHERE username = 'nharris'),
   (SELECT preset_id FROM theme_presets ORDER BY preset_id LIMIT 1 OFFSET 1),
   NOW() - INTERVAL '6 days');


INSERT INTO theme_history
  (group_id, primary_color, secondary_color, background_color, button_style, font_heading, font_body, nav_position, content_width, based_on_preset, saved_by, saved_at, is_pinned, name)
VALUES
  ((SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'),
   '#1a3a2e','#c65d3c','#f5f0e6','rounded','Fraunces','IBM Plex Sans','sidebar','wrap',
   (SELECT preset_id FROM theme_presets ORDER BY preset_id LIMIT 1),
   (SELECT user_id FROM users WHERE username = 'dlee'),
   NOW() - INTERVAL '40 days', FALSE, NULL),
  ((SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'),
   '#0d3823','#c65d3c','#f5f0e6','rounded','Fraunces','IBM Plex Sans','sidebar','wrap',
   (SELECT preset_id FROM theme_presets ORDER BY preset_id LIMIT 1),
   (SELECT user_id FROM users WHERE username = 'dlee'),
   NOW() - INTERVAL '12 days', TRUE,  'Hinewai launch theme'),
  ((SELECT group_id FROM groups WHERE name = 'Wellington Town Belt Trappers'),
   '#3d9b67','#c65d3c','#f5f0e6','rounded','Cabin','IBM Plex Sans','topbar','full',
   (SELECT preset_id FROM theme_presets ORDER BY preset_id LIMIT 1),
   (SELECT user_id FROM users WHERE username = 'nharris'),
   NOW() - INTERVAL '20 days', FALSE, NULL),
  ((SELECT group_id FROM groups WHERE name = 'Wellington Town Belt Trappers'),
   '#1a4f6e','#e8920a','#f0f5f7','square','Cabin','IBM Plex Sans','topbar','full',
   (SELECT preset_id FROM theme_presets ORDER BY preset_id LIMIT 1 OFFSET 1),
   (SELECT user_id FROM users WHERE username = 'nharris'),
   NOW() - INTERVAL '6 days',  TRUE,  'Coastal harbour palette'),
  ((SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'),
   '#1a3a2e','#c65d3c','#f5f0e6','rounded','Fraunces','IBM Plex Sans','sidebar','wrap',
   (SELECT preset_id FROM theme_presets ORDER BY preset_id LIMIT 1),
   (SELECT user_id FROM users WHERE username = 'bkim'),
   NOW() - INTERVAL '70 days', FALSE, NULL);

INSERT INTO map3d_view_log (user_id, group_id, line_id, created_at) VALUES
  ((SELECT user_id FROM users WHERE username = 'hpatel'), (SELECT group_id FROM groups WHERE name = 'Christchurch City Trappers'), (SELECT line_id FROM lines WHERE name = 'Travis Wetland Reserve'), NOW() - INTERVAL '48 days 4 hours'),
  ((SELECT user_id FROM users WHERE username = 'mreid'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), NULL, NOW() - INTERVAL '42 days 22 hours'),
  ((SELECT user_id FROM users WHERE username = 'smitchell'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), (SELECT line_id FROM lines WHERE name = 'North Campus Trap Line'), NOW() - INTERVAL '30 days 9 hours'),
  ((SELECT user_id FROM users WHERE username = 'cwhite'), (SELECT group_id FROM groups WHERE name = 'Christchurch City Trappers'), (SELECT line_id FROM lines WHERE name = 'Bottle Lake Forest Loop'), NOW() - INTERVAL '30 days 15 hours'),
  ((SELECT user_id FROM users WHERE username = 'jparata'), (SELECT group_id FROM groups WHERE name = 'Christchurch City Trappers'), NULL, NOW() - INTERVAL '25 days 13 hours'),
  ((SELECT user_id FROM users WHERE username = 'smitchell'), (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), NOW() - INTERVAL '76 days 5 hours'),
  ((SELECT user_id FROM users WHERE username = 'enyberg'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), NULL, NOW() - INTERVAL '56 days 15 hours'),
  ((SELECT user_id FROM users WHERE username = 'jparata'), (SELECT group_id FROM groups WHERE name = 'Christchurch City Trappers'), NULL, NOW() - INTERVAL '35 days 0 hours'),
  ((SELECT user_id FROM users WHERE username = 'jparata'), (SELECT group_id FROM groups WHERE name = 'Christchurch City Trappers'), NULL, NOW() - INTERVAL '42 days 1 hours'),
  ((SELECT user_id FROM users WHERE username = 'jparata'), (SELECT group_id FROM groups WHERE name = 'Christchurch City Trappers'), NULL, NOW() - INTERVAL '39 days 16 hours'),
  ((SELECT user_id FROM users WHERE username = 'bkim'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), (SELECT line_id FROM lines WHERE name = 'Lake Edge Trap Line'), NOW() - INTERVAL '4 days 12 hours'),
  ((SELECT user_id FROM users WHERE username = 'smitchell'), (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), NOW() - INTERVAL '32 days 18 hours'),
  ((SELECT user_id FROM users WHERE username = 'mreid'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), NULL, NOW() - INTERVAL '82 days 21 hours'),
  ((SELECT user_id FROM users WHERE username = 'lchen'), (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), NOW() - INTERVAL '47 days 14 hours'),
  ((SELECT user_id FROM users WHERE username = 'lchen'), (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), NOW() - INTERVAL '33 days 1 hours'),
  ((SELECT user_id FROM users WHERE username = 'enyberg'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), NULL, NOW() - INTERVAL '85 days 9 hours'),
  ((SELECT user_id FROM users WHERE username = 'smitchell'), (SELECT group_id FROM groups WHERE name = 'Christchurch City Trappers'), (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), NOW() - INTERVAL '22 days 21 hours'),
  ((SELECT user_id FROM users WHERE username = 'smitchell'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), (SELECT line_id FROM lines WHERE name = 'North Campus Trap Line'), NOW() - INTERVAL '47 days 15 hours'),
  ((SELECT user_id FROM users WHERE username = 'smitchell'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), (SELECT line_id FROM lines WHERE name = 'North Campus Trap Line'), NOW() - INTERVAL '49 days 1 hours'),
  ((SELECT user_id FROM users WHERE username = 'dlee'), (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), (SELECT line_id FROM lines WHERE name = 'Otanerito Valley Bush'), NOW() - INTERVAL '7 days 7 hours'),
  ((SELECT user_id FROM users WHERE username = 'smitchell'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), (SELECT line_id FROM lines WHERE name = 'North Campus Trap Line'), NOW() - INTERVAL '48 days 4 hours'),
  ((SELECT user_id FROM users WHERE username = 'enyberg'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), NULL, NOW() - INTERVAL '50 days 3 hours'),
  ((SELECT user_id FROM users WHERE username = 'smitchell'), (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), NOW() - INTERVAL '53 days 22 hours'),
  ((SELECT user_id FROM users WHERE username = 'mreid'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), NULL, NOW() - INTERVAL '56 days 8 hours'),
  ((SELECT user_id FROM users WHERE username = 'dlee'), (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), (SELECT line_id FROM lines WHERE name = 'Otanerito Valley Bush'), NOW() - INTERVAL '27 days 21 hours'),
  ((SELECT user_id FROM users WHERE username = 'lchen'), (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), NOW() - INTERVAL '36 days 12 hours'),
  ((SELECT user_id FROM users WHERE username = 'smitchell'), (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), NOW() - INTERVAL '21 days 16 hours'),
  ((SELECT user_id FROM users WHERE username = 'mreid'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), NULL, NOW() - INTERVAL '62 days 9 hours'),
  ((SELECT user_id FROM users WHERE username = 'jparata'), (SELECT group_id FROM groups WHERE name = 'Christchurch City Trappers'), NULL, NOW() - INTERVAL '53 days 16 hours'),
  ((SELECT user_id FROM users WHERE username = 'smitchell'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), (SELECT line_id FROM lines WHERE name = 'North Campus Trap Line'), NOW() - INTERVAL '6 days 16 hours'),
  ((SELECT user_id FROM users WHERE username = 'smitchell'), (SELECT group_id FROM groups WHERE name = 'Christchurch City Trappers'), (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), NOW() - INTERVAL '90 days 0 hours'),
  ((SELECT user_id FROM users WHERE username = 'enyberg'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), NULL, NOW() - INTERVAL '36 days 14 hours'),
  ((SELECT user_id FROM users WHERE username = 'mreid'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), NULL, NOW() - INTERVAL '47 days 19 hours'),
  ((SELECT user_id FROM users WHERE username = 'bkim'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), (SELECT line_id FROM lines WHERE name = 'Lake Edge Trap Line'), NOW() - INTERVAL '17 days 11 hours'),
  ((SELECT user_id FROM users WHERE username = 'enyberg'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), NULL, NOW() - INTERVAL '31 days 4 hours'),
  ((SELECT user_id FROM users WHERE username = 'enyberg'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), NULL, NOW() - INTERVAL '8 days 12 hours'),
  ((SELECT user_id FROM users WHERE username = 'smitchell'), (SELECT group_id FROM groups WHERE name = 'Christchurch City Trappers'), (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), NOW() - INTERVAL '79 days 15 hours'),
  ((SELECT user_id FROM users WHERE username = 'smitchell'), (SELECT group_id FROM groups WHERE name = 'Christchurch City Trappers'), (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), NOW() - INTERVAL '69 days 1 hours'),
  ((SELECT user_id FROM users WHERE username = 'mreid'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), NULL, NOW() - INTERVAL '58 days 8 hours'),
  ((SELECT user_id FROM users WHERE username = 'dlee'), (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), (SELECT line_id FROM lines WHERE name = 'Otanerito Valley Bush'), NOW() - INTERVAL '48 days 5 hours'),
  ((SELECT user_id FROM users WHERE username = 'smitchell'), (SELECT group_id FROM groups WHERE name = 'Christchurch City Trappers'), (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), NOW() - INTERVAL '71 days 7 hours'),
  ((SELECT user_id FROM users WHERE username = 'hpatel'), (SELECT group_id FROM groups WHERE name = 'Christchurch City Trappers'), (SELECT line_id FROM lines WHERE name = 'Travis Wetland Reserve'), NOW() - INTERVAL '65 days 13 hours'),
  ((SELECT user_id FROM users WHERE username = 'cwhite'), (SELECT group_id FROM groups WHERE name = 'Christchurch City Trappers'), (SELECT line_id FROM lines WHERE name = 'Bottle Lake Forest Loop'), NOW() - INTERVAL '22 days 22 hours'),
  ((SELECT user_id FROM users WHERE username = 'smitchell'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), (SELECT line_id FROM lines WHERE name = 'North Campus Trap Line'), NOW() - INTERVAL '47 days 23 hours'),
  ((SELECT user_id FROM users WHERE username = 'lchen'), (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), NOW() - INTERVAL '13 days 0 hours'),
  ((SELECT user_id FROM users WHERE username = 'smitchell'), (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), NOW() - INTERVAL '32 days 22 hours'),
  ((SELECT user_id FROM users WHERE username = 'smitchell'), (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), NOW() - INTERVAL '67 days 4 hours'),
  ((SELECT user_id FROM users WHERE username = 'hpatel'), (SELECT group_id FROM groups WHERE name = 'Christchurch City Trappers'), (SELECT line_id FROM lines WHERE name = 'Travis Wetland Reserve'), NOW() - INTERVAL '36 days 16 hours'),
  ((SELECT user_id FROM users WHERE username = 'lchen'), (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), NOW() - INTERVAL '74 days 21 hours'),
  ((SELECT user_id FROM users WHERE username = 'jparata'), (SELECT group_id FROM groups WHERE name = 'Christchurch City Trappers'), NULL, NOW() - INTERVAL '70 days 18 hours'),
  ((SELECT user_id FROM users WHERE username = 'smitchell'), (SELECT group_id FROM groups WHERE name = 'Christchurch City Trappers'), (SELECT line_id FROM lines WHERE name = 'Port Hills Summit Track'), NOW() - INTERVAL '24 days 4 hours'),
  ((SELECT user_id FROM users WHERE username = 'smitchell'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), (SELECT line_id FROM lines WHERE name = 'North Campus Trap Line'), NOW() - INTERVAL '71 days 6 hours'),
  ((SELECT user_id FROM users WHERE username = 'enyberg'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), NULL, NOW() - INTERVAL '15 days 19 hours'),
  ((SELECT user_id FROM users WHERE username = 'smitchell'), (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), NOW() - INTERVAL '61 days 15 hours'),
  ((SELECT user_id FROM users WHERE username = 'bkim'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), (SELECT line_id FROM lines WHERE name = 'Lake Edge Trap Line'), NOW() - INTERVAL '23 days 4 hours'),
  ((SELECT user_id FROM users WHERE username = 'smitchell'), (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), NOW() - INTERVAL '20 days 15 hours'),
  ((SELECT user_id FROM users WHERE username = 'cwhite'), (SELECT group_id FROM groups WHERE name = 'Christchurch City Trappers'), (SELECT line_id FROM lines WHERE name = 'Bottle Lake Forest Loop'), NOW() - INTERVAL '61 days 1 hours'),
  ((SELECT user_id FROM users WHERE username = 'smitchell'), (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), NOW() - INTERVAL '45 days 2 hours'),
  ((SELECT user_id FROM users WHERE username = 'lchen'), (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), NOW() - INTERVAL '32 days 5 hours'),
  ((SELECT user_id FROM users WHERE username = 'mreid'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), NULL, NOW() - INTERVAL '0 days 0 hours'),
  ((SELECT user_id FROM users WHERE username = 'dlee'), (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), (SELECT line_id FROM lines WHERE name = 'Otanerito Valley Bush'), NOW() - INTERVAL '4 days 4 hours'),
  ((SELECT user_id FROM users WHERE username = 'bkim'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), (SELECT line_id FROM lines WHERE name = 'Lake Edge Trap Line'), NOW() - INTERVAL '29 days 20 hours'),
  ((SELECT user_id FROM users WHERE username = 'smitchell'), (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), NOW() - INTERVAL '52 days 7 hours'),
  ((SELECT user_id FROM users WHERE username = 'mreid'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), NULL, NOW() - INTERVAL '25 days 10 hours'),
  ((SELECT user_id FROM users WHERE username = 'smitchell'), (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), NOW() - INTERVAL '74 days 10 hours'),
  ((SELECT user_id FROM users WHERE username = 'dlee'), (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), (SELECT line_id FROM lines WHERE name = 'Otanerito Valley Bush'), NOW() - INTERVAL '89 days 12 hours'),
  ((SELECT user_id FROM users WHERE username = 'dlee'), (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), (SELECT line_id FROM lines WHERE name = 'Otanerito Valley Bush'), NOW() - INTERVAL '28 days 18 hours'),
  ((SELECT user_id FROM users WHERE username = 'bkim'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), (SELECT line_id FROM lines WHERE name = 'Lake Edge Trap Line'), NOW() - INTERVAL '37 days 9 hours'),
  ((SELECT user_id FROM users WHERE username = 'hpatel'), (SELECT group_id FROM groups WHERE name = 'Christchurch City Trappers'), (SELECT line_id FROM lines WHERE name = 'Travis Wetland Reserve'), NOW() - INTERVAL '54 days 5 hours'),
  ((SELECT user_id FROM users WHERE username = 'mreid'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), NULL, NOW() - INTERVAL '18 days 22 hours'),
  ((SELECT user_id FROM users WHERE username = 'smitchell'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), (SELECT line_id FROM lines WHERE name = 'North Campus Trap Line'), NOW() - INTERVAL '48 days 3 hours'),
  ((SELECT user_id FROM users WHERE username = 'hpatel'), (SELECT group_id FROM groups WHERE name = 'Christchurch City Trappers'), (SELECT line_id FROM lines WHERE name = 'Travis Wetland Reserve'), NOW() - INTERVAL '55 days 5 hours'),
  ((SELECT user_id FROM users WHERE username = 'bkim'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), (SELECT line_id FROM lines WHERE name = 'Lake Edge Trap Line'), NOW() - INTERVAL '27 days 14 hours'),
  ((SELECT user_id FROM users WHERE username = 'enyberg'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), NULL, NOW() - INTERVAL '73 days 6 hours'),
  ((SELECT user_id FROM users WHERE username = 'smitchell'), (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), NOW() - INTERVAL '13 days 2 hours'),
  ((SELECT user_id FROM users WHERE username = 'cwhite'), (SELECT group_id FROM groups WHERE name = 'Christchurch City Trappers'), (SELECT line_id FROM lines WHERE name = 'Bottle Lake Forest Loop'), NOW() - INTERVAL '87 days 12 hours'),
  ((SELECT user_id FROM users WHERE username = 'smitchell'), (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), (SELECT line_id FROM lines WHERE name = 'North Campus Trap Line'), NOW() - INTERVAL '38 days 5 hours'),
  ((SELECT user_id FROM users WHERE username = 'lchen'), (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), NOW() - INTERVAL '16 days 16 hours'),
  ((SELECT user_id FROM users WHERE username = 'lchen'), (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), NOW() - INTERVAL '51 days 1 hours'),
  ((SELECT user_id FROM users WHERE username = 'lchen'), (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), (SELECT line_id FROM lines WHERE name = 'Hinewai Reserve Main Ridge'), NOW() - INTERVAL '45 days 19 hours')
;


INSERT INTO map3d_view_prefs (user_id, show_vegetation, activity_days, updated_at) VALUES
  ((SELECT user_id FROM users WHERE username = 'smitchell'), TRUE,  60, NOW() - INTERVAL '4 days'),
  ((SELECT user_id FROM users WHERE username = 'bkim'),      TRUE,  30, NOW() - INTERVAL '2 days'),
  ((SELECT user_id FROM users WHERE username = 'dlee'),      FALSE, 90, NOW() - INTERVAL '7 days'),
  ((SELECT user_id FROM users WHERE username = 'cwhite'),    TRUE,  14, NOW() - INTERVAL '1 day'),
  ((SELECT user_id FROM users WHERE username = 'lchen'),     TRUE,  30, NOW() - INTERVAL '5 days')
ON CONFLICT (user_id) DO NOTHING;


SELECT setval('users_user_id_seq',                          (SELECT MAX(user_id)         FROM users));
SELECT setval('groups_group_id_seq',                        (SELECT MAX(group_id)        FROM groups));
SELECT setval('group_memberships_membership_id_seq',        (SELECT MAX(membership_id)   FROM group_memberships));
SELECT setval('group_join_requests_request_id_seq',         (SELECT MAX(request_id)      FROM group_join_requests));
SELECT setval('group_applications_application_id_seq',      (SELECT MAX(application_id)  FROM group_applications));
SELECT setval('user_notifications_notification_id_seq',     (SELECT MAX(notification_id) FROM user_notifications));
SELECT setval('support_tickets_ticket_id_seq',              (SELECT MAX(ticket_id)        FROM support_tickets));
SELECT setval('ticket_replies_reply_id_seq',                (SELECT MAX(reply_id)         FROM ticket_replies));
SELECT setval('ticket_status_history_history_id_seq',       (SELECT MAX(history_id)       FROM ticket_status_history));
SELECT setval('user_suspension_log_log_id_seq',             (SELECT MAX(log_id)           FROM user_suspension_log));
SELECT setval('support_tech_audit_log_log_id_seq',          (SELECT MAX(log_id)           FROM support_tech_audit_log));
SELECT setval('theme_history_history_id_seq',               (SELECT COALESCE(MAX(history_id),1) FROM theme_history));
SELECT setval('map3d_view_log_log_id_seq',                  (SELECT COALESCE(MAX(log_id),1) FROM map3d_view_log));




-- ══════════════════════════════════════════════════════
-- MEGA-LINES — 3 very long trap lines that loop across
-- Banks Peninsula so the 3D map flyby has something
-- spectacular to follow. Each line is 4-8× longer than
-- the next-longest line (Hinewai Reserve Main Ridge, 50).
-- ══════════════════════════════════════════════════════

INSERT INTO lines (name, type, group_id, is_retired) VALUES
  ('Banks Peninsula Crater Rim Traverse', 'Trap', (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), false),
  ('Akaroa Harbour Perimeter Network', 'Trap', (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), false),
  ('South Coast Cliffs — Wainui to Hickory Bay', 'Trap', (SELECT group_id FROM groups WHERE name = 'Banks Peninsula Restoration'), false)
ON CONFLICT (name) DO NOTHING;


INSERT INTO operator_lines (operator_id, line_id) VALUES
  ((SELECT user_id FROM users WHERE username = 'dlee'),
   (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse')),
  ((SELECT user_id FROM users WHERE username = 'bkim'),
   (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network')),
  ((SELECT user_id FROM users WHERE username = 'dlee'),
   (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay')),
  ((SELECT user_id FROM users WHERE username = 'enyberg'),
   (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'))
ON CONFLICT DO NOTHING;

INSERT INTO traps (code, trap_type, line_id, latitude, longitude, is_retired) VALUES
  ('BCR-001', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.671029, 172.68991, false),
  ('BCR-002', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.671403, 172.691456, false),
  ('BCR-003', 'A24', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.6716, 172.693313, false),
  ('BCR-004', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.672142, 172.69559, false),
  ('BCR-005', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.672576, 172.69807, false),
  ('BCR-006', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.673116, 172.700539, false),
  ('BCR-007', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.67364, 172.703287, false),
  ('BCR-008', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.674146, 172.706295, false),
  ('BCR-009', 'A24', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.674915, 172.709464, false),
  ('BCR-010', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.675618, 172.712615, false),
  ('BCR-011', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.676049, 172.715722, false),
  ('BCR-012', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.676663, 172.718994, false),
  ('BCR-013', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.677353, 172.722168, false),
  ('BCR-014', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.678091, 172.725242, false),
  ('BCR-015', 'A24', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.678814, 172.728408, false),
  ('BCR-016', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.679104, 172.731821, false),
  ('BCR-017', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.679838, 172.73535, false),
  ('BCR-018', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.680371, 172.738878, false),
  ('BCR-019', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.681031, 172.742219, false),
  ('BCR-020', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.681468, 172.745815, false),
  ('BCR-021', 'A24', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.682142, 172.74958, false),
  ('BCR-022', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.682759, 172.753321, false),
  ('BCR-023', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.68358, 172.756666, false),
  ('BCR-024', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.684554, 172.760373, false),
  ('BCR-025', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.685167, 172.76377, false),
  ('BCR-026', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.686215, 172.767203, false),
  ('BCR-027', 'A24', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.687268, 172.770509, false),
  ('BCR-028', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.688373, 172.7739, false),
  ('BCR-029', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.689607, 172.777141, false),
  ('BCR-030', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.690921, 172.780071, false),
  ('BCR-031', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.692195, 172.783186, false),
  ('BCR-032', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.693433, 172.786197, false),
  ('BCR-033', 'A24', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.694889, 172.789376, false),
  ('BCR-034', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.696529, 172.792363, false),
  ('BCR-035', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.697885, 172.795343, false),
  ('BCR-036', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.699395, 172.798282, false),
  ('BCR-037', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.701067, 172.80128, false),
  ('BCR-038', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.702558, 172.804421, false),
  ('BCR-039', 'A24', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.704069, 172.807627, false),
  ('BCR-040', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.705424, 172.811072, false),
  ('BCR-041', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.706831, 172.814435, false),
  ('BCR-042', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.708521, 172.817819, false),
  ('BCR-043', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.709996, 172.821029, false),
  ('BCR-044', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.711471, 172.824655, false),
  ('BCR-045', 'A24', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.713061, 172.828047, false),
  ('BCR-046', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.714487, 172.831754, false),
  ('BCR-047', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.716033, 172.835173, false),
  ('BCR-048', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.717604, 172.838627, false),
  ('BCR-049', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.719031, 172.842428, false),
  ('BCR-050', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.720677, 172.845819, false),
  ('BCR-051', 'A24', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.72238, 172.849328, false),
  ('BCR-052', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.723958, 172.852948, false),
  ('BCR-053', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.725727, 172.85651, false),
  ('BCR-054', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.727306, 172.859826, false),
  ('BCR-055', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.729015, 172.863495, false),
  ('BCR-056', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.730948, 172.866927, false),
  ('BCR-057', 'A24', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.732586, 172.870415, false),
  ('BCR-058', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.734485, 172.874231, false),
  ('BCR-059', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.736357, 172.877637, false),
  ('BCR-060', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.737985, 172.881277, false),
  ('BCR-061', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.739845, 172.884682, false),
  ('BCR-062', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.741622, 172.888078, false),
  ('BCR-063', 'A24', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.743446, 172.891567, false),
  ('BCR-064', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.745306, 172.895028, false),
  ('BCR-065', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.74719, 172.898399, false),
  ('BCR-066', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.748841, 172.901793, false),
  ('BCR-067', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.750565, 172.90492, false),
  ('BCR-068', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.752393, 172.908334, false),
  ('BCR-069', 'A24', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.754141, 172.911531, false),
  ('BCR-070', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.755769, 172.914859, false),
  ('BCR-071', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.757646, 172.917976, false),
  ('BCR-072', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.759372, 172.921137, false),
  ('BCR-073', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.760936, 172.924291, false),
  ('BCR-074', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.762573, 172.927208, false),
  ('BCR-075', 'A24', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.764262, 172.930254, false),
  ('BCR-076', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.766074, 172.933129, false),
  ('BCR-077', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.767694, 172.935967, false),
  ('BCR-078', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.769404, 172.938959, false),
  ('BCR-079', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.770898, 172.941497, false),
  ('BCR-080', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.77249, 172.944113, false),
  ('BCR-081', 'A24', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.774248, 172.946601, false),
  ('BCR-082', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.775655, 172.948807, false),
  ('BCR-083', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.77727, 172.951063, false),
  ('BCR-084', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.778782, 172.953265, false),
  ('BCR-085', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.780274, 172.95523, false),
  ('BCR-086', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.782026, 172.95734, false),
  ('BCR-087', 'A24', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.783465, 172.959654, false),
  ('BCR-088', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.784794, 172.961836, false),
  ('BCR-089', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.786499, 172.964197, false),
  ('BCR-090', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.787859, 172.966641, false),
  ('BCR-091', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.789597, 172.969271, false),
  ('BCR-092', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.790938, 172.97203, false),
  ('BCR-093', 'A24', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.792666, 172.974752, false),
  ('BCR-094', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.794198, 172.97778, false),
  ('BCR-095', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.795847, 172.981021, false),
  ('BCR-096', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.797182, 172.98432, false),
  ('BCR-097', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.798862, 172.987667, false),
  ('BCR-098', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.800484, 172.990749, false),
  ('BCR-099', 'A24', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.802006, 172.994131, false),
  ('BCR-100', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.803371, 172.997325, false),
  ('BCR-101', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.804941, 173.000679, false),
  ('BCR-102', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.806595, 173.003762, false),
  ('BCR-103', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.808023, 173.006615, false),
  ('BCR-104', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.809789, 173.009326, false),
  ('BCR-105', 'A24', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.811309, 173.012121, false),
  ('BCR-106', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.812894, 173.014652, false),
  ('BCR-107', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.814251, 173.017128, false),
  ('BCR-108', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.815668, 173.019591, false),
  ('BCR-109', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.817215, 173.021936, false),
  ('BCR-110', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.818689, 173.024144, false),
  ('BCR-111', 'A24', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.820314, 173.02643, false),
  ('BCR-112', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.821867, 173.028473, false),
  ('BCR-113', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.823321, 173.030729, false),
  ('BCR-114', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.82477, 173.032908, false),
  ('BCR-115', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.826477, 173.035286, false),
  ('BCR-116', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.828141, 173.037567, false),
  ('BCR-117', 'A24', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.829941, 173.039669, false),
  ('BCR-118', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.831717, 173.04212, false),
  ('BCR-119', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.833628, 173.044606, false),
  ('BCR-120', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.835754, 173.047392, false),
  ('BCR-121', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.837942, 173.050121, false),
  ('BCR-122', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.840375, 173.052791, false),
  ('BCR-123', 'A24', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.842449, 173.055521, false),
  ('BCR-124', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.844851, 173.057919, false),
  ('BCR-125', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.846819, 173.060597, false),
  ('BCR-126', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.849027, 173.063023, false),
  ('BCR-127', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.850729, 173.065112, false),
  ('BCR-128', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.852379, 173.067043, false),
  ('BCR-129', 'A24', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.853921, 173.06853, false),
  ('BCR-130', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Banks Peninsula Crater Rim Traverse'), -43.855047, 173.070038, false)
ON CONFLICT (code) DO NOTHING;

INSERT INTO traps (code, trap_type, line_id, latitude, longitude, is_retired) VALUES
  ('AHP-001', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.790094, 172.954904, false),
  ('AHP-002', 'A24', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.791188, 172.954237, false),
  ('AHP-003', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.792341, 172.953248, false),
  ('AHP-004', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.794303, 172.951872, false),
  ('AHP-005', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.795973, 172.950394, false),
  ('AHP-006', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.797933, 172.949005, false),
  ('AHP-007', 'A24', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.800082, 172.947791, false),
  ('AHP-008', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.801974, 172.946331, false),
  ('AHP-009', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.803919, 172.945546, false),
  ('AHP-010', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.80569, 172.94478, false),
  ('AHP-011', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.807531, 172.944087, false),
  ('AHP-012', 'A24', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.809298, 172.943693, false),
  ('AHP-013', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.81088, 172.943321, false),
  ('AHP-014', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.812361, 172.943334, false),
  ('AHP-015', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.814113, 172.943033, false),
  ('AHP-016', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.816094, 172.943008, false),
  ('AHP-017', 'A24', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.817971, 172.94296, false),
  ('AHP-018', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.819782, 172.942945, false),
  ('AHP-019', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.821965, 172.94295, false),
  ('AHP-020', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.824033, 172.942883, false),
  ('AHP-021', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.826344, 172.943112, false),
  ('AHP-022', 'A24', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.828798, 172.94325, false),
  ('AHP-023', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.831374, 172.943488, false),
  ('AHP-024', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.833729, 172.943631, false),
  ('AHP-025', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.836092, 172.944177, false),
  ('AHP-026', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.838579, 172.944593, false),
  ('AHP-027', 'A24', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.840712, 172.945179, false),
  ('AHP-028', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.843254, 172.945991, false),
  ('AHP-029', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.845788, 172.947029, false),
  ('AHP-030', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.848322, 172.947981, false),
  ('AHP-031', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.85094, 172.949418, false),
  ('AHP-032', 'A24', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.853383, 172.950502, false),
  ('AHP-033', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.855455, 172.951825, false),
  ('AHP-034', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.857724, 172.953274, false),
  ('AHP-035', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.859825, 172.954778, false),
  ('AHP-036', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.86141, 172.956351, false),
  ('AHP-037', 'A24', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.862911, 172.957645, false),
  ('AHP-038', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.864559, 172.959347, false),
  ('AHP-039', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.86609, 172.961209, false),
  ('AHP-040', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.867337, 172.962843, false),
  ('AHP-041', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.868345, 172.964691, false),
  ('AHP-042', 'A24', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.869194, 172.966671, false),
  ('AHP-043', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.869735, 172.968439, false),
  ('AHP-044', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.869979, 172.970456, false),
  ('AHP-045', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.870087, 172.972681, false),
  ('AHP-046', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.869902, 172.975018, false),
  ('AHP-047', 'A24', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.869586, 172.977573, false),
  ('AHP-048', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.869061, 172.980111, false),
  ('AHP-049', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.86831, 172.982399, false),
  ('AHP-050', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.867428, 172.984965, false),
  ('AHP-051', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.866449, 172.987251, false),
  ('AHP-052', 'A24', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.865445, 172.989359, false),
  ('AHP-053', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.863999, 172.991438, false),
  ('AHP-054', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.862705, 172.993605, false),
  ('AHP-055', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.861094, 172.995365, false),
  ('AHP-056', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.859282, 172.997332, false),
  ('AHP-057', 'A24', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.857389, 172.999195, false),
  ('AHP-058', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.855381, 173.001103, false),
  ('AHP-059', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.853443, 173.00258, false),
  ('AHP-060', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.851539, 173.004044, false),
  ('AHP-061', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.849797, 173.005163, false),
  ('AHP-062', 'A24', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.848033, 173.006188, false),
  ('AHP-063', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.846242, 173.007092, false),
  ('AHP-064', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.844282, 173.007671, false),
  ('AHP-065', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.84274, 173.008423, false),
  ('AHP-066', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.840804, 173.008827, false),
  ('AHP-067', 'A24', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.839191, 173.009201, false),
  ('AHP-068', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.837431, 173.009602, false),
  ('AHP-069', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.835554, 173.00975, false),
  ('AHP-070', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.83398, 173.010089, false),
  ('AHP-071', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.832091, 173.010465, false),
  ('AHP-072', 'A24', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.830501, 173.010384, false),
  ('AHP-073', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.828733, 173.010592, false),
  ('AHP-074', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.826804, 173.010762, false),
  ('AHP-075', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.825145, 173.010538, false),
  ('AHP-076', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.823238, 173.010514, false),
  ('AHP-077', 'A24', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.821474, 173.010167, false),
  ('AHP-078', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.819777, 173.010066, false),
  ('AHP-079', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.818118, 173.009599, false),
  ('AHP-080', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.816088, 173.009268, false),
  ('AHP-081', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.814418, 173.008858, false),
  ('AHP-082', 'A24', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.812408, 173.008565, false),
  ('AHP-083', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.810782, 173.007965, false),
  ('AHP-084', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.80896, 173.007168, false),
  ('AHP-085', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.807187, 173.00637, false),
  ('AHP-086', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.805714, 173.005582, false),
  ('AHP-087', 'A24', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.804268, 173.004373, false),
  ('AHP-088', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.802634, 173.002754, false),
  ('AHP-089', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.801365, 173.000928, false),
  ('AHP-090', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.800046, 172.99888, false),
  ('AHP-091', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.798696, 172.996621, false),
  ('AHP-092', 'A24', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.79746, 172.994439, false),
  ('AHP-093', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.796613, 172.992773, false),
  ('AHP-094', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.795813, 172.991259, false),
  ('AHP-095', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Akaroa Harbour Perimeter Network'), -43.795014, 172.989997, false)
ON CONFLICT (code) DO NOTHING;

INSERT INTO traps (code, trap_type, line_id, latitude, longitude, is_retired) VALUES
  ('SCC-001', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.869851, 172.969876, false),
  ('SCC-002', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.870531, 172.970941, false),
  ('SCC-003', 'A24', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.870846, 172.972159, false),
  ('SCC-004', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.871571, 172.973475, false),
  ('SCC-005', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.872097, 172.974852, false),
  ('SCC-006', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.87301, 172.97652, false),
  ('SCC-007', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.873706, 172.978193, false),
  ('SCC-008', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.874247, 172.979796, false),
  ('SCC-009', 'A24', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.875186, 172.981934, false),
  ('SCC-010', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.875976, 172.983803, false),
  ('SCC-011', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.876523, 172.985672, false),
  ('SCC-012', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.877116, 172.98758, false),
  ('SCC-013', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.877951, 172.989491, false),
  ('SCC-014', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.878244, 172.991196, false),
  ('SCC-015', 'A24', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.878903, 172.993056, false),
  ('SCC-016', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.879214, 172.994998, false),
  ('SCC-017', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.879492, 172.996963, false),
  ('SCC-018', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.880096, 172.998981, false),
  ('SCC-019', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.880317, 173.001249, false),
  ('SCC-020', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.880801, 173.003196, false),
  ('SCC-021', 'A24', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.880913, 173.005347, false),
  ('SCC-022', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.881387, 173.007561, false),
  ('SCC-023', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.88146, 173.009445, false),
  ('SCC-024', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.881759, 173.011582, false),
  ('SCC-025', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.88187, 173.01363, false),
  ('SCC-026', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.882141, 173.015624, false),
  ('SCC-027', 'A24', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.882203, 173.017703, false),
  ('SCC-028', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.882044, 173.01976, false),
  ('SCC-029', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.882138, 173.021773, false),
  ('SCC-030', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.881814, 173.023806, false),
  ('SCC-031', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.881805, 173.025896, false),
  ('SCC-032', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.881628, 173.027926, false),
  ('SCC-033', 'A24', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.881582, 173.029741, false),
  ('SCC-034', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.881293, 173.031767, false),
  ('SCC-035', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.881238, 173.034049, false),
  ('SCC-036', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.880963, 173.035886, false),
  ('SCC-037', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.881109, 173.038042, false),
  ('SCC-038', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.880938, 173.039902, false),
  ('SCC-039', 'A24', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.881058, 173.042069, false),
  ('SCC-040', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.881332, 173.043938, false),
  ('SCC-041', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.881532, 173.046182, false),
  ('SCC-042', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.881665, 173.048059, false),
  ('SCC-043', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.881977, 173.05018, false),
  ('SCC-044', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.882159, 173.052175, false),
  ('SCC-045', 'A24', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.882369, 173.054144, false),
  ('SCC-046', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.882684, 173.056164, false),
  ('SCC-047', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.882616, 173.058376, false),
  ('SCC-048', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.882765, 173.060376, false),
  ('SCC-049', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.88289, 173.062336, false),
  ('SCC-050', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.882977, 173.06439, false),
  ('SCC-051', 'A24', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.882823, 173.066382, false),
  ('SCC-052', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.882846, 173.068447, false),
  ('SCC-053', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.882617, 173.070416, false),
  ('SCC-054', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.882681, 173.072464, false),
  ('SCC-055', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.882366, 173.074348, false),
  ('SCC-056', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.882208, 173.076497, false),
  ('SCC-057', 'A24', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.881661, 173.078531, false),
  ('SCC-058', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.881404, 173.080442, false),
  ('SCC-059', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.881245, 173.082704, false),
  ('SCC-060', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.880816, 173.084663, false),
  ('SCC-061', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.880607, 173.086672, false),
  ('SCC-062', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.880264, 173.088558, false),
  ('SCC-063', 'A24', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.879991, 173.090587, false),
  ('SCC-064', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.879642, 173.0928, false),
  ('SCC-065', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.878996, 173.095106, false),
  ('SCC-066', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.878698, 173.097466, false),
  ('SCC-067', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.878064, 173.099712, false),
  ('SCC-068', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.877586, 173.102282, false),
  ('SCC-069', 'A24', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.877278, 173.10431, false),
  ('SCC-070', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.876712, 173.106782, false),
  ('SCC-071', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.876362, 173.108687, false),
  ('SCC-072', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.875992, 173.110547, false),
  ('SCC-073', 'DOC 250', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.875499, 173.112306, false),
  ('SCC-074', 'Trapinator', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.87511, 173.113801, false),
  ('SCC-075', 'A24', (SELECT line_id FROM lines WHERE name = 'South Coast Cliffs — Wainui to Hickory Bay'), -43.875111, 173.11505, false)
ON CONFLICT (code) DO NOTHING;

INSERT INTO trap_catches (trap_id, date, recorded_by_id, species_caught, sex, maturity, status, rebaited, bait_type, bait_details, trap_condition, strikes, notes) VALUES
  ((SELECT trap_id FROM traps WHERE code = 'BCR-002'), '2025-11-03 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BCR-004'), '2026-02-13 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BCR-006'), '2025-11-16 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Stoat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BCR-008'), '2026-04-14 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Possum', 'Male', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BCR-009'), '2026-03-07 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BCR-011'), '2026-04-20 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Weasel', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BCR-020'), '2026-04-17 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BCR-026'), '2026-02-06 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Weasel', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BCR-030'), '2026-01-16 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Possum', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BCR-031'), '2026-04-24 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Possum', 'Male', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BCR-033'), '2026-02-25 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BCR-036'), '2026-03-23 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Weasel', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BCR-040'), '2025-12-07 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BCR-041'), '2026-04-01 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BCR-044'), '2025-11-22 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Rat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BCR-048'), '2026-04-17 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Stoat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BCR-061'), '2025-12-07 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BCR-062'), '2025-11-07 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Weasel', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BCR-064'), '2026-04-23 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BCR-065'), '2026-01-10 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Possum', 'Male', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BCR-071'), '2026-03-30 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Weasel', 'Male', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BCR-072'), '2025-11-02 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BCR-073'), '2025-11-28 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BCR-081'), '2025-12-04 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BCR-094'), '2026-01-13 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BCR-104'), '2026-02-11 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Weasel', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BCR-107'), '2026-01-22 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Possum', 'Male', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BCR-112'), '2026-02-03 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BCR-114'), '2025-12-04 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BCR-117'), '2026-02-17 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BCR-118'), '2026-02-26 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Mouse', 'Male', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BCR-123'), '2025-11-25 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BCR-126'), '2026-03-04 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'BCR-128'), '2025-12-11 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHP-001'), '2026-03-19 09:00:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHP-002'), '2026-04-27 09:00:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Possum', 'Male', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHP-004'), '2026-03-16 09:00:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHP-009'), '2026-03-07 09:00:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Rat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHP-014'), '2026-03-21 09:00:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Mouse', 'Male', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHP-015'), '2026-01-12 09:00:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHP-026'), '2026-01-03 09:00:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Weasel', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Lure', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHP-028'), '2026-03-28 09:00:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Stoat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHP-029'), '2025-12-03 09:00:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHP-030'), '2026-01-29 09:00:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Weasel', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHP-038'), '2026-01-26 09:00:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHP-048'), '2025-11-23 09:00:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Possum', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHP-050'), '2026-01-25 09:00:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHP-055'), '2026-04-25 09:00:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Weasel', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHP-068'), '2026-02-08 09:00:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Stoat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHP-069'), '2026-02-18 09:00:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Weasel', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHP-076'), '2025-12-02 09:00:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Stoat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHP-079'), '2026-01-12 09:00:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Possum', 'Male', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHP-081'), '2025-12-23 09:00:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Stoat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHP-083'), '2025-12-09 09:00:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Possum', 'Male', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHP-084'), '2026-03-03 09:00:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHP-089'), '2025-12-27 09:00:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Weasel', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Egg', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHP-090'), '2026-03-07 09:00:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHP-091'), '2026-04-12 09:00:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Rat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'AHP-092'), '2026-01-23 09:00:00', (SELECT user_id FROM users WHERE username = 'bkim'), 'Possum', 'Male', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SCC-002'), '2026-02-10 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Weasel', 'Female', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SCC-003'), '2026-01-01 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Possum', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SCC-006'), '2025-12-03 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Weasel', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SCC-007'), '2026-04-20 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Mouse', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SCC-009'), '2025-11-11 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Possum', 'Male', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SCC-011'), '2025-12-17 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Rat', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SCC-012'), '2025-12-24 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Stoat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SCC-013'), '2026-03-04 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SCC-020'), '2025-12-25 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SCC-021'), '2025-11-06 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Rat', 'Female', 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SCC-029'), '2025-12-05 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Rat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SCC-031'), '2025-11-06 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Possum', 'Male', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SCC-037'), '2025-12-23 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Stoat', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SCC-038'), '2026-01-29 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SCC-039'), '2025-12-02 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SCC-041'), '2026-04-28 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Rat', 'Male', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SCC-048'), '2025-12-25 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Weasel', 'Female', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SCC-049'), '2025-12-02 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Stoat', 'Female', 'Adult', 'Sprung', 'Yes', 'Lure', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SCC-054'), '2025-12-06 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Possum', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SCC-056'), '2026-04-19 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Weasel', 'Female', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SCC-060'), '2026-03-05 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Mouse', 'Male', 'Adult', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SCC-062'), '2026-04-10 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Stoat', 'Male', 'Adult', 'Sprung', 'Yes', 'Egg', NULL, 'Needs maintenance', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SCC-067'), '2026-01-08 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Weasel', 'Female', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SCC-068'), '2026-02-12 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Mouse', 'Female', 'Adult', 'Sprung', 'Yes', 'Salmon', NULL, 'OK', 1, NULL),
  ((SELECT trap_id FROM traps WHERE code = 'SCC-072'), '2025-12-28 09:00:00', (SELECT user_id FROM users WHERE username = 'dlee'), 'Weasel', 'Male', 'Juvenile', 'Sprung', 'Yes', 'Peanut butter', NULL, 'OK', 1, NULL)
ON CONFLICT DO NOTHING;



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
