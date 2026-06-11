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
