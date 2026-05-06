-- populate_database.sql
-- Conservation Groups — COMP639 Group Project 2, Team Huhu
-- Lincoln University, Semester 1, 2026
-- All passwords: Password1!
-- Run in psql or TablePlus query window

BEGIN;

-- ══════════════════════════════════════════════════════
-- SEED GROUP
-- Insert the default group first — lines and memberships depend on it
-- ══════════════════════════════════════════════════════

INSERT INTO groups (name, description, is_public, color_theme) VALUES
    ('Predator Free Lincoln University',
     'A volunteer group running a predator-control initiative across the Lincoln University campus.',
     TRUE,
     '#198754'),
    ('Christchurch City Trappers',
     'A community predator trapping group operating across central Christchurch.',
     TRUE,
     '#0d6efd')
ON CONFLICT (name) DO NOTHING;

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
-- USERS
-- All passwords: Password1!
-- ══════════════════════════════════════════════════════

INSERT INTO users (username, email, password_hash, first_name, last_name, account_status, phone, address, emergency_contact_name, emergency_contact_phone, date_joined, last_login) VALUES

-- Admins
('smitchell',  's.mitchell@lincoln.ac.nz',  '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Sarah',     'Mitchell',  'active',   '021 345 6789', '12 Lincoln Road, Lincoln 7608',    'John Mitchell',   '021 987 6543', '2024-01-15 09:00:00', '2026-04-17 08:30:00'),
('jthornton',  'j.thornton@lincoln.ac.nz',  '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'James',     'Thornton',  'active',   '021 456 7890', '45 Springs Road, Lincoln 7608',    'Mary Thornton',   '021 876 5432', '2024-01-15 09:00:00', '2026-04-16 14:22:00'),
('eparata',    'e.parata@lincoln.ac.nz',    '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Emma',      'Parata',    'active',   '027 567 8901', '78 Boundary Road, Lincoln 7608',   'Peter Parata',    '027 765 4321', '2024-01-20 09:00:00', '2026-04-15 11:00:00'),
('dchen',      'd.chen@lincoln.ac.nz',      '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'David',     'Chen',      'active',   '027 678 9012', '23 Gerald Street, Lincoln 7608',   'Susan Chen',      '027 654 3210', '2024-02-01 09:00:00', '2026-04-10 09:45:00'),

-- Operators
('landerson',  'liam.anderson@lincoln.ac.nz',    '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Liam',      'Anderson',  'active',   '021 111 2233', '5 Selwyn Road, Lincoln 7608',      'Helen Anderson',  '021 543 2109', '2024-02-10 09:00:00', '2026-04-17 07:55:00'),
('owalker',    'olivia.walker@lincoln.ac.nz',    '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Olivia',    'Walker',    'active',   '021 222 3344', '89 Lincoln Road, Lincoln 7608',    'Michael Walker',  '021 432 1098', '2024-02-10 09:00:00', '2026-04-14 16:30:00'),
('ncampbell',  'noah.campbell@lincoln.ac.nz',    '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Noah',      'Campbell',  'active',   '021 333 4455', '34 Springs Road, Lincoln 7608',    'John Campbell',   '021 321 0987', '2024-03-01 09:00:00', '2026-04-12 08:10:00'),
('sroberts',   'sophia.roberts@lincoln.ac.nz',   '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Sophia',    'Roberts',   'active',   '027 444 5566', '56 Boundary Road, Lincoln 7608',   'Mary Roberts',    '027 210 9876', '2024-03-01 09:00:00', '2026-04-11 12:45:00'),
('eclarke',    'ethan.clarke@lincoln.ac.nz',     '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Ethan',     'Clarke',    'active',   '027 555 6677', '12 Gerald Street, Lincoln 7608',   'Susan Clarke',    '027 109 8765', '2024-03-15 09:00:00', '2026-04-09 09:00:00'),
('ithompson',  'isabella.thompson@lincoln.ac.nz','$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Isabella',  'Thompson',  'active',   '027 666 7788', '67 Selwyn Road, Lincoln 7608',     'Peter Thompson',  '027 098 7654', '2024-04-01 09:00:00', '2026-04-08 14:20:00'),
('wbrown',     'william.brown@lincoln.ac.nz',    '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'William',   'Brown',     'active',   '021 777 8899', '90 Lincoln Road, Lincoln 7608',    'Helen Brown',     '021 987 6543', '2024-04-01 09:00:00', '2026-03-30 10:10:00'),
('mdavies',    'mia.davies@lincoln.ac.nz',       '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Mia',       'Davies',    'inactive', '021 888 9900', '23 Springs Road, Lincoln 7608',    'Michael Davies',  '021 876 5432', '2024-04-15 09:00:00', '2025-11-20 09:00:00'),
('bscott',     'benjamin.scott@lincoln.ac.nz',   '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Benjamin',  'Scott',     'inactive', '027 999 0011', '45 Boundary Road, Lincoln 7608',   'John Scott',      '027 765 4321', '2024-05-01 09:00:00', '2025-10-15 14:30:00'),
('cwilson',    'charlotte.wilson@lincoln.ac.nz', '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Charlotte', 'Wilson',    'active',   '021 100 1122', '78 Gerald Street, Lincoln 7608',   'Mary Wilson',     '021 654 3210', '2024-05-01 09:00:00', '2026-04-16 08:00:00'),

-- Observers
('ataylor',    'ava.taylor@lincoln.ac.nz',        '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Ava',       'Taylor',    'active',   '021 201 3456', '11 Lincoln Road, Lincoln 7608',    'John Taylor',     '021 543 2109', '2024-06-01 09:00:00', '2026-04-17 06:45:00'),
('mharris',    'mason.harris@lincoln.ac.nz',      '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Mason',     'Harris',    'active',   '021 202 3457', '22 Springs Road, Lincoln 7608',    'Mary Harris',     '021 432 1098', '2024-06-01 09:00:00', '2026-04-13 11:30:00'),
('hmartin',    'harper.martin@lincoln.ac.nz',     '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Harper',    'Martin',    'active',   '027 203 3458', '33 Boundary Road, Lincoln 7608',   'Peter Martin',    '021 321 0987', '2024-06-15 09:00:00', '2026-04-10 09:20:00'),
('ejackson',   'elijah.jackson@lincoln.ac.nz',    '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Elijah',    'Jackson',   'active',   '027 204 3459', '44 Gerald Street, Lincoln 7608',   'Susan Jackson',   '027 210 9876', '2024-07-01 09:00:00', '2026-04-07 15:00:00'),
('awhite',     'amelia.white@lincoln.ac.nz',      '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Amelia',    'White',     'inactive', '021 205 3460', '55 Selwyn Road, Lincoln 7608',     'Helen White',     '027 109 8765', '2024-07-01 09:00:00', '2025-09-10 10:00:00'),
('jyoung',     'james.young@lincoln.ac.nz',       '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'James',     'Young',     'active',   '021 206 3461', '66 Lincoln Road, Lincoln 7608',    'Michael Young',   '021 098 7654', '2024-07-15 09:00:00', '2026-04-05 08:50:00'),
('ehall',      'evelyn.hall@lincoln.ac.nz',       '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Evelyn',    'Hall',      'active',   '027 207 3462', '77 Springs Road, Lincoln 7608',    'John Hall',       '021 987 6543', '2024-08-01 09:00:00', '2026-04-02 12:00:00'),
('lking',      'logan.king@lincoln.ac.nz',        '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Logan',     'King',      'active',   '027 208 3463', '88 Boundary Road, Lincoln 7608',   'Mary King',       '021 876 5432', '2024-08-01 09:00:00', '2026-03-28 09:30:00'),
('awright',    'abigail.wright@lincoln.ac.nz',    '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Abigail',   'Wright',    'inactive', '021 209 3464', '99 Gerald Street, Lincoln 7608',   'Peter Wright',    '027 765 4321', '2024-08-15 09:00:00', '2025-12-01 08:00:00'),
('llopez',     'lucas.lopez@lincoln.ac.nz',       '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Lucas',     'Lopez',     'active',   '021 210 3465', '10 Selwyn Road, Lincoln 7608',     'Susan Lopez',     '027 654 3210', '2024-09-01 09:00:00', '2026-04-16 07:30:00'),
('ehill',      'emily.hill@lincoln.ac.nz',        '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Emily',     'Hill',      'active',   '027 211 3466', '21 Lincoln Road, Lincoln 7608',    'Helen Hill',      '021 543 2109', '2024-09-01 09:00:00', '2026-04-14 13:15:00'),
('ogreen',     'oliver.green@lincoln.ac.nz',      '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Oliver',    'Green',     'active',   '027 212 3467', '32 Springs Road, Lincoln 7608',    'Michael Green',   '021 432 1098', '2024-09-15 09:00:00', '2026-04-11 10:45:00'),
('cadams',     'chloe.adams@lincoln.ac.nz',       '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Chloe',     'Adams',     'active',   '021 213 3468', '43 Boundary Road, Lincoln 7608',   'John Adams',      '021 321 0987', '2024-10-01 09:00:00', '2026-04-08 16:00:00'),
('ebaker',     'elias.baker@lincoln.ac.nz',       '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Elias',     'Baker',     'inactive', '021 214 3469', '54 Gerald Street, Lincoln 7608',   'Mary Baker',      '027 210 9876', '2024-10-01 09:00:00', '2025-08-20 11:00:00'),
('pnelson',    'penelope.nelson@lincoln.ac.nz',   '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Penelope',  'Nelson',    'active',   '027 215 3470', '65 Selwyn Road, Lincoln 7608',     'Peter Nelson',    '027 109 8765', '2024-10-15 09:00:00', '2026-04-05 09:10:00'),
('mcarter',    'mateo.carter@lincoln.ac.nz',      '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Mateo',     'Carter',    'active',   '027 216 3471', '76 Lincoln Road, Lincoln 7608',    'Helen Carter',    '021 098 7654', '2024-11-01 09:00:00', '2026-04-03 08:20:00'),
('lmitchell',  'layla.mitchell@lincoln.ac.nz',    '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Layla',     'Mitchell',  'active',   '021 217 3472', '87 Springs Road, Lincoln 7608',    'Michael Mitchell','021 987 6543', '2024-11-01 09:00:00', '2026-04-01 14:30:00'),
('hperez',     'henry.perez@lincoln.ac.nz',       '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Henry',     'Perez',     'active',   '021 218 3473', '98 Boundary Road, Lincoln 7608',   'John Perez',      '021 876 5432', '2024-11-15 09:00:00', '2026-03-29 10:00:00'),
('sroberts2',  'scarlett.roberts@lincoln.ac.nz',  '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Scarlett',  'Roberts',   'inactive', '027 219 3474', '109 Gerald Street, Lincoln 7608',  'Mary Roberts',    '027 765 4321', '2024-12-01 09:00:00', '2025-07-15 09:00:00'),
('jturner',    'jackson.turner@lincoln.ac.nz',    '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Jackson',   'Turner',    'active',   '027 220 3475', '120 Selwyn Road, Lincoln 7608',    'Peter Turner',    '027 654 3210', '2024-12-01 09:00:00', '2026-04-16 11:00:00')

ON CONFLICT (username) DO NOTHING;

-- ══════════════════════════════════════════════════════
-- GROUP MEMBERSHIPS
-- Maps every seeded user into the default group with their P1 role
-- Super Admin = former Admin, Group Coordinator = new role (assign manually after setup)
-- ══════════════════════════════════════════════════════

INSERT INTO group_memberships (user_id, group_id, role)
SELECT u.user_id,
       (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'),
       m.role::role_type
FROM (VALUES
    ('smitchell',  'Super Admin'),
    ('jthornton',  'Super Admin'),
    ('eparata',    'Super Admin'),
    ('dchen',      'Group Coordinator'),
    ('landerson',  'Operator'),
    ('owalker',    'Operator'),
    ('ncampbell',  'Operator'),
    ('sroberts',   'Operator'),
    ('eclarke',    'Operator'),
    ('ithompson',  'Operator'),
    ('wbrown',     'Operator'),
    ('mdavies',    'Operator'),
    ('bscott',     'Operator'),
    ('cwilson',    'Operator'),
    ('ataylor',    'Observer'),
    ('mharris',    'Observer'),
    ('hmartin',    'Observer'),
    ('ejackson',   'Observer'),
    ('awhite',     'Observer'),
    ('jyoung',     'Observer'),
    ('ehall',      'Observer'),
    ('lking',      'Observer'),
    ('awright',    'Observer'),
    ('llopez',     'Observer'),
    ('ehill',      'Observer'),
    ('ogreen',     'Observer'),
    ('cadams',     'Observer'),
    ('ebaker',     'Observer'),
    ('pnelson',    'Observer'),
    ('mcarter',    'Observer'),
    ('lmitchell',  'Observer'),
    ('hperez',     'Observer'),
    ('sroberts2',  'Observer'),
    ('jturner',    'Observer')
) AS m(username, role)
JOIN users u ON u.username = m.username
ON CONFLICT (user_id, group_id) DO NOTHING;

-- Multi-group test users: each quick-login account belongs to both groups
INSERT INTO group_memberships (user_id, group_id, role)
SELECT u.user_id,
       (SELECT group_id FROM groups WHERE name = 'Christchurch City Trappers'),
       m.role::role_type
FROM (VALUES
    ('smitchell', 'Super Admin'),
    ('dchen',     'Group Coordinator'),
    ('landerson', 'Operator'),
    ('ataylor',   'Observer')
) AS m(username, role)
JOIN users u ON u.username = m.username
ON CONFLICT (user_id, group_id) DO NOTHING;

-- ══════════════════════════════════════════════════════
-- LINES
-- All within Lincoln University campus bounds
-- ══════════════════════════════════════════════════════

INSERT INTO lines (name, type, group_id, is_retired, retired_at, retired_by) VALUES

-- Active lines — North campus
('North Paddock Line',          'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),
('North Shelter Belt',          'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),
('North Boundary Track',        'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),
('North Gate Perimeter',        'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),
('North Creek Corridor',        'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),

-- Active lines — Central campus
('Main Campus Circuit',         'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),
('Library Quadrant Track',      'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),
('Administration Perimeter',    'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),
('Engineering Block Track',     'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),
('Biology Building Line',       'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),
('Student Village Perimeter',   'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),
('Conference Centre Loop',      'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),
('Central Reserve Track',       'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),

-- Active lines — South campus
('South Boundary Line',         'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),
('South Shelter Belt',          'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),
('South Gate Track',            'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),
('South Paddock East',          'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),
('South Paddock West',          'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),

-- Active lines — East campus
('East Riparian Track',         'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),
('East Boundary Line',          'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),
('East Farm Road',              'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),
('East Research Block',         'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),

-- Active lines — West campus
('West Shelter Belt',           'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),
('West Boundary Track',         'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),
('West Farm Road',              'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),

-- Active lines — Lake & wetland
('Lake Edge Track',             'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),
('Lake Loop North',             'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),
('Lake Loop South',             'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),
('Wetland Reserve Line',        'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),

-- Active lines — Arboretum
('Arboretum North Track',       'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),
('Arboretum South Track',       'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),
('Arboretum East Perimeter',    'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),

-- Active lines — Farm & research
('Research Farm North',         'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),
('Research Farm South',         'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),
('Equine Centre Track',         'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),
('Viticulture Block Line',      'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),
('Horticulture Plots Track',    'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),
('Orchard Track East',          'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),
('Orchard Track West',          'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),

-- Active lines — Misc
('Sports Field Perimeter',      'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),
('Heritage Walk',               'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), false, NULL, NULL),

-- Retired lines
('Old Farm Track',              'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), true, '2025-06-15 10:00:00', (SELECT user_id FROM users WHERE username = 'smitchell')),
('Temporary Fence Line',        'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), true, '2025-03-20 09:00:00', (SELECT user_id FROM users WHERE username = 'jthornton')),
('Building Site Track',         'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), true, '2025-08-01 11:00:00', (SELECT user_id FROM users WHERE username = 'eparata')),
('South Creek Corridor',        'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), true, '2025-09-10 09:00:00', (SELECT user_id FROM users WHERE username = 'dchen')),
('Carpark Extension Line',      'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), true, '2024-11-05 10:00:00', (SELECT user_id FROM users WHERE username = 'smitchell')),
('Demolished Block Track',      'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), true, '2024-12-15 09:00:00', (SELECT user_id FROM users WHERE username = 'jthornton')),
('Old Orchard Line',            'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), true, '2025-01-20 10:00:00', (SELECT user_id FROM users WHERE username = 'eparata')),
('Flood Zone Track',            'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), true, '2025-04-30 14:00:00', (SELECT user_id FROM users WHERE username = 'dchen')),
('Seed Bank Perimeter',         'Trap', (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'), true, '2025-11-22 09:00:00', (SELECT user_id FROM users WHERE username = 'smitchell'))

ON CONFLICT (name) DO NOTHING;

-- ══════════════════════════════════════════════════════
-- OPERATOR → LINE ASSIGNMENTS
-- ══════════════════════════════════════════════════════

INSERT INTO operator_lines (operator_id, line_id) VALUES
-- landerson → North campus lines
((SELECT user_id FROM users WHERE username = 'landerson'), (SELECT line_id FROM lines WHERE name = 'North Paddock Line')),
((SELECT user_id FROM users WHERE username = 'landerson'), (SELECT line_id FROM lines WHERE name = 'North Shelter Belt')),
((SELECT user_id FROM users WHERE username = 'landerson'), (SELECT line_id FROM lines WHERE name = 'North Boundary Track')),

-- owalker → Central campus lines
((SELECT user_id FROM users WHERE username = 'owalker'), (SELECT line_id FROM lines WHERE name = 'Main Campus Circuit')),
((SELECT user_id FROM users WHERE username = 'owalker'), (SELECT line_id FROM lines WHERE name = 'Library Quadrant Track')),
((SELECT user_id FROM users WHERE username = 'owalker'), (SELECT line_id FROM lines WHERE name = 'Administration Perimeter')),
((SELECT user_id FROM users WHERE username = 'owalker'), (SELECT line_id FROM lines WHERE name = 'Conference Centre Loop')),

-- ncampbell → South campus lines
((SELECT user_id FROM users WHERE username = 'ncampbell'), (SELECT line_id FROM lines WHERE name = 'South Boundary Line')),
((SELECT user_id FROM users WHERE username = 'ncampbell'), (SELECT line_id FROM lines WHERE name = 'South Shelter Belt')),
((SELECT user_id FROM users WHERE username = 'ncampbell'), (SELECT line_id FROM lines WHERE name = 'South Paddock East')),
((SELECT user_id FROM users WHERE username = 'ncampbell'), (SELECT line_id FROM lines WHERE name = 'South Paddock West')),

-- sroberts → East campus lines
((SELECT user_id FROM users WHERE username = 'sroberts'), (SELECT line_id FROM lines WHERE name = 'East Riparian Track')),
((SELECT user_id FROM users WHERE username = 'sroberts'), (SELECT line_id FROM lines WHERE name = 'East Boundary Line')),
((SELECT user_id FROM users WHERE username = 'sroberts'), (SELECT line_id FROM lines WHERE name = 'East Farm Road')),

-- eclarke → West campus lines
((SELECT user_id FROM users WHERE username = 'eclarke'), (SELECT line_id FROM lines WHERE name = 'West Shelter Belt')),
((SELECT user_id FROM users WHERE username = 'eclarke'), (SELECT line_id FROM lines WHERE name = 'West Boundary Track')),
((SELECT user_id FROM users WHERE username = 'eclarke'), (SELECT line_id FROM lines WHERE name = 'West Farm Road')),

-- ithompson → Lake & wetland lines
((SELECT user_id FROM users WHERE username = 'ithompson'), (SELECT line_id FROM lines WHERE name = 'Lake Edge Track')),
((SELECT user_id FROM users WHERE username = 'ithompson'), (SELECT line_id FROM lines WHERE name = 'Lake Loop North')),
((SELECT user_id FROM users WHERE username = 'ithompson'), (SELECT line_id FROM lines WHERE name = 'Lake Loop South')),
((SELECT user_id FROM users WHERE username = 'ithompson'), (SELECT line_id FROM lines WHERE name = 'Wetland Reserve Line')),

-- wbrown → Arboretum lines
((SELECT user_id FROM users WHERE username = 'wbrown'), (SELECT line_id FROM lines WHERE name = 'Arboretum North Track')),
((SELECT user_id FROM users WHERE username = 'wbrown'), (SELECT line_id FROM lines WHERE name = 'Arboretum South Track')),
((SELECT user_id FROM users WHERE username = 'wbrown'), (SELECT line_id FROM lines WHERE name = 'Arboretum East Perimeter')),

-- cwilson → Research farm lines
((SELECT user_id FROM users WHERE username = 'cwilson'), (SELECT line_id FROM lines WHERE name = 'Research Farm North')),
((SELECT user_id FROM users WHERE username = 'cwilson'), (SELECT line_id FROM lines WHERE name = 'Research Farm South')),
((SELECT user_id FROM users WHERE username = 'cwilson'), (SELECT line_id FROM lines WHERE name = 'Equine Centre Track')),

-- ncampbell also covers orchard
((SELECT user_id FROM users WHERE username = 'ncampbell'), (SELECT line_id FROM lines WHERE name = 'Orchard Track East')),
((SELECT user_id FROM users WHERE username = 'ncampbell'), (SELECT line_id FROM lines WHERE name = 'Orchard Track West')),

-- landerson also covers sports & heritage
((SELECT user_id FROM users WHERE username = 'landerson'), (SELECT line_id FROM lines WHERE name = 'Sports Field Perimeter')),
((SELECT user_id FROM users WHERE username = 'landerson'), (SELECT line_id FROM lines WHERE name = 'Heritage Walk'))

ON CONFLICT DO NOTHING;

-- ══════════════════════════════════════════════════════
-- TRAPS
-- 6-10 traps per active line, 3-5 per retired line
-- Coordinates within Lincoln University campus bounds
-- ══════════════════════════════════════════════════════

-- North Paddock Line traps
INSERT INTO traps (code, trap_type, line_id, latitude, longitude, is_retired) VALUES
('NPL-01', 'DOC 200',       (SELECT line_id FROM lines WHERE name = 'North Paddock Line'), -43.638012, 172.462045, false),
('NPL-02', 'A24',           (SELECT line_id FROM lines WHERE name = 'North Paddock Line'), -43.638245, 172.462380, false),
('NPL-03', 'DOC 150',       (SELECT line_id FROM lines WHERE name = 'North Paddock Line'), -43.638490, 172.462710, false),
('NPL-04', 'Victor',        (SELECT line_id FROM lines WHERE name = 'North Paddock Line'), -43.638720, 172.463050, false),
('NPL-05', 'Rat trap',      (SELECT line_id FROM lines WHERE name = 'North Paddock Line'), -43.638950, 172.463390, false),
('NPL-06', 'T-Rex Rat Trap',(SELECT line_id FROM lines WHERE name = 'North Paddock Line'), -43.639180, 172.463720, false),
('NPL-07', 'DOC 250',       (SELECT line_id FROM lines WHERE name = 'North Paddock Line'), -43.639410, 172.464050, false)
ON CONFLICT (code) DO NOTHING;

INSERT INTO traps (code, trap_type, line_id, latitude, longitude, is_retired) VALUES
('NSB-01', 'A24',           (SELECT line_id FROM lines WHERE name = 'North Shelter Belt'), -43.639012, 172.468045, false),
('NSB-02', 'DOC 200',       (SELECT line_id FROM lines WHERE name = 'North Shelter Belt'), -43.639280, 172.468420, false),
('NSB-03', 'Trapinator',    (SELECT line_id FROM lines WHERE name = 'North Shelter Belt'), -43.639550, 172.468800, false),
('NSB-04', 'DOC 150',       (SELECT line_id FROM lines WHERE name = 'North Shelter Belt'), -43.639820, 172.469180, false),
('NSB-05', 'Victor',        (SELECT line_id FROM lines WHERE name = 'North Shelter Belt'), -43.640090, 172.469560, false),
('NSB-06', 'Rat trap',      (SELECT line_id FROM lines WHERE name = 'North Shelter Belt'), -43.640360, 172.469940, false)
ON CONFLICT (code) DO NOTHING;

INSERT INTO traps (code, trap_type, line_id, latitude, longitude, is_retired) VALUES
('NBT-01', 'DOC 200',       (SELECT line_id FROM lines WHERE name = 'North Boundary Track'), -43.637012, 172.472045, false),
('NBT-02', 'A24',           (SELECT line_id FROM lines WHERE name = 'North Boundary Track'), -43.637280, 172.472450, false),
('NBT-03', 'DOC 250',       (SELECT line_id FROM lines WHERE name = 'North Boundary Track'), -43.637550, 172.472860, false),
('NBT-04', 'Victor',        (SELECT line_id FROM lines WHERE name = 'North Boundary Track'), -43.637820, 172.473270, false),
('NBT-05', 'Rat trap',      (SELECT line_id FROM lines WHERE name = 'North Boundary Track'), -43.638090, 172.473680, false),
('NBT-06', 'T-Rex Rat Trap',(SELECT line_id FROM lines WHERE name = 'North Boundary Track'), -43.638360, 172.474090, false),
('NBT-07', 'Flipping Timmy',(SELECT line_id FROM lines WHERE name = 'North Boundary Track'), -43.638630, 172.474500, false),
('NBT-08', 'DOC 150',       (SELECT line_id FROM lines WHERE name = 'North Boundary Track'), -43.638900, 172.474910, false)
ON CONFLICT (code) DO NOTHING;

INSERT INTO traps (code, trap_type, line_id, latitude, longitude, is_retired) VALUES
('MCC-01', 'DOC 200',       (SELECT line_id FROM lines WHERE name = 'Main Campus Circuit'), -43.641012, 172.470045, false),
('MCC-02', 'A24',           (SELECT line_id FROM lines WHERE name = 'Main Campus Circuit'), -43.641350, 172.470480, false),
('MCC-03', 'Victor',        (SELECT line_id FROM lines WHERE name = 'Main Campus Circuit'), -43.641700, 172.470920, false),
('MCC-04', 'Rat trap',      (SELECT line_id FROM lines WHERE name = 'Main Campus Circuit'), -43.642050, 172.471360, false),
('MCC-05', 'DOC 150',       (SELECT line_id FROM lines WHERE name = 'Main Campus Circuit'), -43.642400, 172.471800, false),
('MCC-06', 'T-Rex Rat Trap',(SELECT line_id FROM lines WHERE name = 'Main Campus Circuit'), -43.642750, 172.472240, false),
('MCC-07', 'DOC 250',       (SELECT line_id FROM lines WHERE name = 'Main Campus Circuit'), -43.643100, 172.472680, false),
('MCC-08', 'Trapinator',    (SELECT line_id FROM lines WHERE name = 'Main Campus Circuit'), -43.643450, 172.473120, false)
ON CONFLICT (code) DO NOTHING;

INSERT INTO traps (code, trap_type, line_id, latitude, longitude, is_retired) VALUES
('SBL-01', 'DOC 200',       (SELECT line_id FROM lines WHERE name = 'South Boundary Line'), -43.652012, 172.468045, false),
('SBL-02', 'A24',           (SELECT line_id FROM lines WHERE name = 'South Boundary Line'), -43.652350, 172.468520, false),
('SBL-03', 'Victor',        (SELECT line_id FROM lines WHERE name = 'South Boundary Line'), -43.652700, 172.469000, false),
('SBL-04', 'Rat trap',      (SELECT line_id FROM lines WHERE name = 'South Boundary Line'), -43.653050, 172.469480, false),
('SBL-05', 'DOC 150',       (SELECT line_id FROM lines WHERE name = 'South Boundary Line'), -43.653400, 172.469960, false),
('SBL-06', 'T-Rex Rat Trap',(SELECT line_id FROM lines WHERE name = 'South Boundary Line'), -43.653750, 172.470440, false)
ON CONFLICT (code) DO NOTHING;

INSERT INTO traps (code, trap_type, line_id, latitude, longitude, is_retired) VALUES
('ERT-01', 'DOC 200',       (SELECT line_id FROM lines WHERE name = 'East Riparian Track'), -43.645012, 172.484045, false),
('ERT-02', 'A24',           (SELECT line_id FROM lines WHERE name = 'East Riparian Track'), -43.645350, 172.484520, false),
('ERT-03', 'Trapinator',    (SELECT line_id FROM lines WHERE name = 'East Riparian Track'), -43.645700, 172.485000, false),
('ERT-04', 'DOC 150',       (SELECT line_id FROM lines WHERE name = 'East Riparian Track'), -43.646050, 172.485480, false),
('ERT-05', 'Victor',        (SELECT line_id FROM lines WHERE name = 'East Riparian Track'), -43.646400, 172.485960, false),
('ERT-06', 'Rat trap',      (SELECT line_id FROM lines WHERE name = 'East Riparian Track'), -43.646750, 172.486440, false),
('ERT-07', 'DOC 250',       (SELECT line_id FROM lines WHERE name = 'East Riparian Track'), -43.647100, 172.486920, false)
ON CONFLICT (code) DO NOTHING;

INSERT INTO traps (code, trap_type, line_id, latitude, longitude, is_retired) VALUES
('WSB-01', 'DOC 200',       (SELECT line_id FROM lines WHERE name = 'West Shelter Belt'), -43.647012, 172.458045, false),
('WSB-02', 'A24',           (SELECT line_id FROM lines WHERE name = 'West Shelter Belt'), -43.647350, 172.458520, false),
('WSB-03', 'DOC 150',       (SELECT line_id FROM lines WHERE name = 'West Shelter Belt'), -43.647700, 172.459000, false),
('WSB-04', 'Victor',        (SELECT line_id FROM lines WHERE name = 'West Shelter Belt'), -43.648050, 172.459480, false),
('WSB-05', 'Rat trap',      (SELECT line_id FROM lines WHERE name = 'West Shelter Belt'), -43.648400, 172.459960, false),
('WSB-06', 'Flipping Timmy',(SELECT line_id FROM lines WHERE name = 'West Shelter Belt'), -43.648750, 172.460440, false)
ON CONFLICT (code) DO NOTHING;

INSERT INTO traps (code, trap_type, line_id, latitude, longitude, is_retired) VALUES
('LET-01', 'DOC 200',       (SELECT line_id FROM lines WHERE name = 'Lake Edge Track'), -43.650012, 172.466045, false),
('LET-02', 'A24',           (SELECT line_id FROM lines WHERE name = 'Lake Edge Track'), -43.650350, 172.466520, false),
('LET-03', 'Trapinator',    (SELECT line_id FROM lines WHERE name = 'Lake Edge Track'), -43.650700, 172.467000, false),
('LET-04', 'DOC 150',       (SELECT line_id FROM lines WHERE name = 'Lake Edge Track'), -43.651050, 172.467480, false),
('LET-05', 'Victor',        (SELECT line_id FROM lines WHERE name = 'Lake Edge Track'), -43.651400, 172.467960, false),
('LET-06', 'Rat trap',      (SELECT line_id FROM lines WHERE name = 'Lake Edge Track'), -43.651750, 172.468440, false),
('LET-07', 'T-Rex Rat Trap',(SELECT line_id FROM lines WHERE name = 'Lake Edge Track'), -43.652100, 172.468920, false),
('LET-08', 'DOC 250',       (SELECT line_id FROM lines WHERE name = 'Lake Edge Track'), -43.652450, 172.469400, false)
ON CONFLICT (code) DO NOTHING;

INSERT INTO traps (code, trap_type, line_id, latitude, longitude, is_retired) VALUES
('ANT-01', 'DOC 200',       (SELECT line_id FROM lines WHERE name = 'Arboretum North Track'), -43.640012, 172.464045, false),
('ANT-02', 'A24',           (SELECT line_id FROM lines WHERE name = 'Arboretum North Track'), -43.640350, 172.464520, false),
('ANT-03', 'DOC 150',       (SELECT line_id FROM lines WHERE name = 'Arboretum North Track'), -43.640700, 172.465000, false),
('ANT-04', 'Victor',        (SELECT line_id FROM lines WHERE name = 'Arboretum North Track'), -43.641050, 172.465480, false),
('ANT-05', 'Rat trap',      (SELECT line_id FROM lines WHERE name = 'Arboretum North Track'), -43.641400, 172.465960, false),
('ANT-06', 'Flipping Timmy',(SELECT line_id FROM lines WHERE name = 'Arboretum North Track'), -43.641750, 172.466440, false)
ON CONFLICT (code) DO NOTHING;

INSERT INTO traps (code, trap_type, line_id, latitude, longitude, is_retired) VALUES
('RFN-01', 'DOC 200',       (SELECT line_id FROM lines WHERE name = 'Research Farm North'), -43.656012, 172.470045, false),
('RFN-02', 'A24',           (SELECT line_id FROM lines WHERE name = 'Research Farm North'), -43.656350, 172.470520, false),
('RFN-03', 'Trapinator',    (SELECT line_id FROM lines WHERE name = 'Research Farm North'), -43.656700, 172.471000, false),
('RFN-04', 'DOC 150',       (SELECT line_id FROM lines WHERE name = 'Research Farm North'), -43.657050, 172.471480, false),
('RFN-05', 'Victor',        (SELECT line_id FROM lines WHERE name = 'Research Farm North'), -43.657400, 172.471960, false),
('RFN-06', 'Rat trap',      (SELECT line_id FROM lines WHERE name = 'Research Farm North'), -43.657750, 172.472440, false),
('RFN-07', 'T-Rex Rat Trap',(SELECT line_id FROM lines WHERE name = 'Research Farm North'), -43.658100, 172.472920, false)
ON CONFLICT (code) DO NOTHING;

-- Retired line traps
INSERT INTO traps (code, trap_type, line_id, latitude, longitude, is_retired, retired_at, retired_by) VALUES
('OFT-01', 'DOC 200', (SELECT line_id FROM lines WHERE name = 'Old Farm Track'), -43.657012, 172.466045, true, '2025-06-15 10:00:00', (SELECT user_id FROM users WHERE username = 'smitchell')),
('OFT-02', 'A24',     (SELECT line_id FROM lines WHERE name = 'Old Farm Track'), -43.657350, 172.466520, true, '2025-06-15 10:00:00', (SELECT user_id FROM users WHERE username = 'smitchell')),
('OFT-03', 'Victor',  (SELECT line_id FROM lines WHERE name = 'Old Farm Track'), -43.657700, 172.467000, true, '2025-06-15 10:00:00', (SELECT user_id FROM users WHERE username = 'smitchell')),
('OFT-04', 'Rat trap',(SELECT line_id FROM lines WHERE name = 'Old Farm Track'), -43.658050, 172.467480, true, '2025-06-15 10:00:00', (SELECT user_id FROM users WHERE username = 'smitchell')),

('TFL-01', 'DOC 150', (SELECT line_id FROM lines WHERE name = 'Temporary Fence Line'), -43.644012, 172.458045, true, '2025-03-20 09:00:00', (SELECT user_id FROM users WHERE username = 'jthornton')),
('TFL-02', 'A24',     (SELECT line_id FROM lines WHERE name = 'Temporary Fence Line'), -43.644350, 172.458520, true, '2025-03-20 09:00:00', (SELECT user_id FROM users WHERE username = 'jthornton')),
('TFL-03', 'Victor',  (SELECT line_id FROM lines WHERE name = 'Temporary Fence Line'), -43.644700, 172.459000, true, '2025-03-20 09:00:00', (SELECT user_id FROM users WHERE username = 'jthornton'))
ON CONFLICT (code) DO NOTHING;

-- ══════════════════════════════════════════════════════
-- TRAP CATCHES
-- Spread across 2024-2026, realistic for NZ predator control
-- ══════════════════════════════════════════════════════

INSERT INTO trap_catches (trap_id, date, recorded_by_id, species_caught, sex, maturity, status, rebaited, bait_type, bait_details, trap_condition, strikes, notes) VALUES

-- North Paddock Line catches
((SELECT trap_id FROM traps WHERE code = 'NPL-01'), '2024-02-10 08:30:00', (SELECT user_id FROM users WHERE username = 'landerson'), 'Stoat',  'Male',   'Adult',    'Sprung',                 'Yes', 'Egg',          NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'NPL-01'), '2024-04-15 09:00:00', (SELECT user_id FROM users WHERE username = 'landerson'), 'None',   NULL,     NULL,       'Still set, bait OK',     'No',  'None',         NULL,           'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'NPL-01'), '2024-06-20 07:45:00', (SELECT user_id FROM users WHERE username = 'landerson'), 'Rat',    'Female', 'Adult',    'Sprung',                 'Yes', 'Peanut butter',NULL,           'OK',               1, 'Fresh bait applied'),
((SELECT trap_id FROM traps WHERE code = 'NPL-01'), '2024-08-12 08:15:00', (SELECT user_id FROM users WHERE username = 'landerson'), 'None',   NULL,     NULL,       'Still set, bait bad',    'Yes', 'Egg',          'Replaced',     'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'NPL-01'), '2024-10-05 09:30:00', (SELECT user_id FROM users WHERE username = 'landerson'), 'Stoat',  'Female', 'Juvenile', 'Sprung',                 'Yes', 'Egg',          NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'NPL-01'), '2024-12-18 08:00:00', (SELECT user_id FROM users WHERE username = 'landerson'), 'None',   NULL,     NULL,       'Still set, bait OK',     'No',  'None',         NULL,           'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'NPL-01'), '2025-02-14 09:00:00', (SELECT user_id FROM users WHERE username = 'landerson'), 'Mouse',  'Male',   'Adult',    'Sprung',                 'Yes', 'Chocolate',    NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'NPL-01'), '2025-04-20 08:30:00', (SELECT user_id FROM users WHERE username = 'landerson'), 'None',   NULL,     NULL,       'Still set, bait missing','Yes', 'Egg',          'Full replacement','OK',             0, 'Bait taken by non-target'),
((SELECT trap_id FROM traps WHERE code = 'NPL-01'), '2025-06-10 09:15:00', (SELECT user_id FROM users WHERE username = 'landerson'), 'Rat',    'Male',   'Adult',    'Sprung',                 'Yes', 'Peanut butter',NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'NPL-01'), '2025-08-22 08:45:00', (SELECT user_id FROM users WHERE username = 'landerson'), 'None',   NULL,     NULL,       'Still set, bait OK',     'No',  'None',         NULL,           'Needs maintenance',0, 'Spring tension low'),
((SELECT trap_id FROM traps WHERE code = 'NPL-01'), '2025-10-15 09:00:00', (SELECT user_id FROM users WHERE username = 'landerson'), 'Stoat',  'Male',   'Adult',    'Sprung',                 'Yes', 'Egg',          NULL,           'Repaired',         1, 'Trap repaired on site'),
((SELECT trap_id FROM traps WHERE code = 'NPL-01'), '2025-12-08 08:30:00', (SELECT user_id FROM users WHERE username = 'landerson'), 'None',   NULL,     NULL,       'Still set, bait OK',     'No',  'None',         NULL,           'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'NPL-01'), '2026-02-18 09:00:00', (SELECT user_id FROM users WHERE username = 'landerson'), 'Possum', NULL,     'Adult',    'Sprung',                 'Yes', 'Lure',         NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'NPL-01'), '2026-04-10 08:15:00', (SELECT user_id FROM users WHERE username = 'landerson'), 'None',   NULL,     NULL,       'Still set, bait OK',     'No',  'None',         NULL,           'OK',               0, NULL),

((SELECT trap_id FROM traps WHERE code = 'NPL-02'), '2024-03-05 08:00:00', (SELECT user_id FROM users WHERE username = 'landerson'), 'Rat',    'Male',   'Adult',    'Sprung',                 'Yes', 'Chocolate',    NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'NPL-02'), '2024-05-20 09:00:00', (SELECT user_id FROM users WHERE username = 'landerson'), 'None',   NULL,     NULL,       'Still set, bait OK',     'No',  'None',         NULL,           'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'NPL-02'), '2024-07-15 08:30:00', (SELECT user_id FROM users WHERE username = 'landerson'), 'Stoat',  'Female', 'Adult',    'Sprung',                 'Yes', 'Egg',          NULL,           'OK',               2, 'Double strike'),
((SELECT trap_id FROM traps WHERE code = 'NPL-02'), '2024-09-08 09:15:00', (SELECT user_id FROM users WHERE username = 'landerson'), 'Mouse',  'Female', 'Juvenile', 'Sprung',                 'Yes', 'Peanut butter',NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'NPL-02'), '2024-11-22 08:45:00', (SELECT user_id FROM users WHERE username = 'landerson'), 'None',   NULL,     NULL,       'Still set, bait bad',    'Yes', 'Egg',          'Replaced',     'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'NPL-02'), '2025-01-18 09:00:00', (SELECT user_id FROM users WHERE username = 'landerson'), 'Rat',    'Male',   'Adult',    'Sprung',                 'Yes', 'Chocolate',    NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'NPL-02'), '2025-03-25 08:30:00', (SELECT user_id FROM users WHERE username = 'landerson'), 'None',   NULL,     NULL,       'Still set, bait OK',     'No',  'None',         NULL,           'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'NPL-02'), '2025-05-14 09:00:00', (SELECT user_id FROM users WHERE username = 'landerson'), 'Weasel', 'Male',   'Adult',    'Sprung',                 'Yes', 'Rabbit',       NULL,           'OK',               1, 'First weasel on this line'),
((SELECT trap_id FROM traps WHERE code = 'NPL-02'), '2025-07-28 08:15:00', (SELECT user_id FROM users WHERE username = 'landerson'), 'None',   NULL,     NULL,       'Still set, bait missing','Yes', 'Egg',          'Full replacement','OK',             0, NULL),
((SELECT trap_id FROM traps WHERE code = 'NPL-02'), '2025-09-12 09:30:00', (SELECT user_id FROM users WHERE username = 'landerson'), 'Stoat',  'Male',   'Adult',    'Sprung',                 'Yes', 'Egg',          NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'NPL-02'), '2025-11-05 08:45:00', (SELECT user_id FROM users WHERE username = 'landerson'), 'None',   NULL,     NULL,       'Still set, bait OK',     'No',  'None',         NULL,           'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'NPL-02'), '2026-01-20 09:00:00', (SELECT user_id FROM users WHERE username = 'landerson'), 'Rat',    'Female', 'Juvenile', 'Sprung',                 'Yes', 'Peanut butter',NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'NPL-02'), '2026-03-15 08:30:00', (SELECT user_id FROM users WHERE username = 'landerson'), 'None',   NULL,     NULL,       'Still set, bait OK',     'No',  'None',         NULL,           'OK',               0, NULL),

-- Main Campus Circuit catches
((SELECT trap_id FROM traps WHERE code = 'MCC-01'), '2024-02-20 08:00:00', (SELECT user_id FROM users WHERE username = 'owalker'), 'Rat',    'Male',   'Adult',    'Sprung',                 'Yes', 'Peanut butter',NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'MCC-01'), '2024-04-08 09:00:00', (SELECT user_id FROM users WHERE username = 'owalker'), 'None',   NULL,     NULL,       'Still set, bait OK',     'No',  'None',         NULL,           'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'MCC-01'), '2024-06-15 08:30:00', (SELECT user_id FROM users WHERE username = 'owalker'), 'Mouse',  'Female', 'Adult',    'Sprung',                 'Yes', 'Chocolate',    NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'MCC-01'), '2024-08-22 09:15:00', (SELECT user_id FROM users WHERE username = 'owalker'), 'Rat',    'Male',   'Juvenile', 'Sprung',                 'Yes', 'Peanut butter',NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'MCC-01'), '2024-10-10 08:45:00', (SELECT user_id FROM users WHERE username = 'owalker'), 'None',   NULL,     NULL,       'Still set, bait bad',    'Yes', 'Peanut butter','Fresh',        'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'MCC-01'), '2024-12-05 09:00:00', (SELECT user_id FROM users WHERE username = 'owalker'), 'Rat',    'Female', 'Adult',    'Sprung',                 'Yes', 'Chocolate',    NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'MCC-01'), '2025-02-18 08:15:00', (SELECT user_id FROM users WHERE username = 'owalker'), 'None',   NULL,     NULL,       'Still set, bait OK',     'No',  'None',         NULL,           'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'MCC-01'), '2025-04-10 09:30:00', (SELECT user_id FROM users WHERE username = 'owalker'), 'Mouse',  'Male',   'Adult',    'Sprung',                 'Yes', 'Peanut butter',NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'MCC-01'), '2025-06-25 08:00:00', (SELECT user_id FROM users WHERE username = 'owalker'), 'Rat',    'Female', 'Juvenile', 'Sprung',                 'Yes', 'Chocolate',    NULL,           'Needs maintenance',1, 'Trap needs cleaning'),
((SELECT trap_id FROM traps WHERE code = 'MCC-01'), '2025-08-12 09:00:00', (SELECT user_id FROM users WHERE username = 'owalker'), 'None',   NULL,     NULL,       'Still set, bait OK',     'No',  'None',         NULL,           'Repaired',         0, 'Cleaned and reset'),
((SELECT trap_id FROM traps WHERE code = 'MCC-01'), '2025-10-28 08:30:00', (SELECT user_id FROM users WHERE username = 'owalker'), 'Rat',    'Male',   'Adult',    'Sprung',                 'Yes', 'Peanut butter',NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'MCC-01'), '2025-12-15 09:15:00', (SELECT user_id FROM users WHERE username = 'owalker'), 'None',   NULL,     NULL,       'Still set, bait missing','Yes', 'Peanut butter','Full replacement','OK',             0, NULL),
((SELECT trap_id FROM traps WHERE code = 'MCC-01'), '2026-02-10 08:45:00', (SELECT user_id FROM users WHERE username = 'owalker'), 'Mouse',  'Female', 'Adult',    'Sprung',                 'Yes', 'Chocolate',    NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'MCC-01'), '2026-04-05 09:00:00', (SELECT user_id FROM users WHERE username = 'owalker'), 'None',   NULL,     NULL,       'Still set, bait OK',     'No',  'None',         NULL,           'OK',               0, NULL),

-- South Boundary Line catches
((SELECT trap_id FROM traps WHERE code = 'SBL-01'), '2024-03-10 07:30:00', (SELECT user_id FROM users WHERE username = 'ncampbell'), 'Possum', NULL,     'Adult',    'Sprung',                 'Yes', 'Lure',         NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'SBL-01'), '2024-05-15 08:00:00', (SELECT user_id FROM users WHERE username = 'ncampbell'), 'None',   NULL,     NULL,       'Still set, bait OK',     'No',  'None',         NULL,           'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'SBL-01'), '2024-07-20 08:30:00', (SELECT user_id FROM users WHERE username = 'ncampbell'), 'Stoat',  'Male',   'Adult',    'Sprung',                 'Yes', 'Egg',          NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'SBL-01'), '2024-09-14 09:00:00', (SELECT user_id FROM users WHERE username = 'ncampbell'), 'None',   NULL,     NULL,       'Still set, bait bad',    'Yes', 'Egg',          'Replaced',     'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'SBL-01'), '2024-11-28 08:15:00', (SELECT user_id FROM users WHERE username = 'ncampbell'), 'Rabbit', NULL,     NULL,       'Sprung',                 'Yes', 'Lure',         NULL,           'OK',               1, 'Unexpected catch'),
((SELECT trap_id FROM traps WHERE code = 'SBL-01'), '2025-01-22 09:30:00', (SELECT user_id FROM users WHERE username = 'ncampbell'), 'Possum', NULL,     'Juvenile', 'Sprung',                 'Yes', 'Lure',         NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'SBL-01'), '2025-03-18 08:45:00', (SELECT user_id FROM users WHERE username = 'ncampbell'), 'None',   NULL,     NULL,       'Still set, bait OK',     'No',  'None',         NULL,           'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'SBL-01'), '2025-05-25 09:00:00', (SELECT user_id FROM users WHERE username = 'ncampbell'), 'Stoat',  'Female', 'Adult',    'Sprung',                 'Yes', 'Egg',          NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'SBL-01'), '2025-07-14 08:30:00', (SELECT user_id FROM users WHERE username = 'ncampbell'), 'None',   NULL,     NULL,       'Still set, bait OK',     'No',  'None',         NULL,           'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'SBL-01'), '2025-09-28 09:15:00', (SELECT user_id FROM users WHERE username = 'ncampbell'), 'Possum', NULL,     'Adult',    'Sprung',                 'Yes', 'Lure',         NULL,           'Needs maintenance',1, 'Hinge worn'),
((SELECT trap_id FROM traps WHERE code = 'SBL-01'), '2025-11-12 08:00:00', (SELECT user_id FROM users WHERE username = 'ncampbell'), 'None',   NULL,     NULL,       'Still set, bait missing','Yes', 'Lure',         'Full replacement','Repaired',        0, 'Hinge replaced'),
((SELECT trap_id FROM traps WHERE code = 'SBL-01'), '2026-01-28 09:30:00', (SELECT user_id FROM users WHERE username = 'ncampbell'), 'Stoat',  'Male',   'Juvenile', 'Sprung',                 'Yes', 'Egg',          NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'SBL-01'), '2026-03-20 08:15:00', (SELECT user_id FROM users WHERE username = 'ncampbell'), 'None',   NULL,     NULL,       'Still set, bait OK',     'No',  'None',         NULL,           'OK',               0, NULL),

-- East Riparian Track catches
((SELECT trap_id FROM traps WHERE code = 'ERT-01'), '2024-02-28 08:00:00', (SELECT user_id FROM users WHERE username = 'sroberts'), 'Rat',    'Female', 'Adult',    'Sprung',                 'Yes', 'Peanut butter',NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'ERT-01'), '2024-04-25 09:00:00', (SELECT user_id FROM users WHERE username = 'sroberts'), 'Hedgehog',NULL,    NULL,       'Sprung',                 'Yes', 'Chicken',      NULL,           'OK',               1, 'Non-target capture noted'),
((SELECT trap_id FROM traps WHERE code = 'ERT-01'), '2024-06-30 08:30:00', (SELECT user_id FROM users WHERE username = 'sroberts'), 'None',   NULL,     NULL,       'Still set, bait OK',     'No',  'None',         NULL,           'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'ERT-01'), '2024-09-02 09:15:00', (SELECT user_id FROM users WHERE username = 'sroberts'), 'Rat',    'Male',   'Adult',    'Sprung',                 'Yes', 'Peanut butter',NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'ERT-01'), '2024-11-18 08:45:00', (SELECT user_id FROM users WHERE username = 'sroberts'), 'None',   NULL,     NULL,       'Still set, bait bad',    'Yes', 'Peanut butter','Fresh',        'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'ERT-01'), '2025-01-14 09:00:00', (SELECT user_id FROM users WHERE username = 'sroberts'), 'Stoat',  'Male',   'Adult',    'Sprung',                 'Yes', 'Egg',          NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'ERT-01'), '2025-03-28 08:15:00', (SELECT user_id FROM users WHERE username = 'sroberts'), 'Rat',    'Female', 'Juvenile', 'Sprung',                 'Yes', 'Chocolate',    NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'ERT-01'), '2025-05-22 09:30:00', (SELECT user_id FROM users WHERE username = 'sroberts'), 'None',   NULL,     NULL,       'Still set, bait OK',     'No',  'None',         NULL,           'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'ERT-01'), '2025-07-10 08:00:00', (SELECT user_id FROM users WHERE username = 'sroberts'), 'Rat',    'Male',   'Adult',    'Sprung',                 'Yes', 'Peanut butter',NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'ERT-01'), '2025-09-24 09:00:00', (SELECT user_id FROM users WHERE username = 'sroberts'), 'None',   NULL,     NULL,       'Still set, bait OK',     'No',  'None',         NULL,           'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'ERT-01'), '2025-11-18 08:30:00', (SELECT user_id FROM users WHERE username = 'sroberts'), 'Stoat',  'Female', 'Adult',    'Sprung',                 'Yes', 'Egg',          NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'ERT-01'), '2026-01-15 09:15:00', (SELECT user_id FROM users WHERE username = 'sroberts'), 'None',   NULL,     NULL,       'Still set, bait missing','Yes', 'Peanut butter','Full replacement','OK',             0, NULL),
((SELECT trap_id FROM traps WHERE code = 'ERT-01'), '2026-03-28 08:45:00', (SELECT user_id FROM users WHERE username = 'sroberts'), 'Rat',    'Female', 'Adult',    'Sprung',                 'Yes', 'Chocolate',    NULL,           'OK',               1, NULL),

-- Lake Edge Track catches
((SELECT trap_id FROM traps WHERE code = 'LET-01'), '2024-03-18 07:45:00', (SELECT user_id FROM users WHERE username = 'ithompson'), 'Rat',    'Male',   'Adult',    'Sprung',                 'Yes', 'Peanut butter',NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'LET-01'), '2024-05-25 08:15:00', (SELECT user_id FROM users WHERE username = 'ithompson'), 'None',   NULL,     NULL,       'Still set, bait OK',     'No',  'None',         NULL,           'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'LET-01'), '2024-07-30 09:00:00', (SELECT user_id FROM users WHERE username = 'ithompson'), 'Stoat',  'Male',   'Adult',    'Sprung',                 'Yes', 'Egg',          NULL,           'OK',               1, 'Near waterway'),
((SELECT trap_id FROM traps WHERE code = 'LET-01'), '2024-10-18 08:30:00', (SELECT user_id FROM users WHERE username = 'ithompson'), 'Rat',    'Female', 'Juvenile', 'Sprung',                 'Yes', 'Chocolate',    NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'LET-01'), '2024-12-28 09:15:00', (SELECT user_id FROM users WHERE username = 'ithompson'), 'None',   NULL,     NULL,       'Still set, bait bad',    'Yes', 'Peanut butter','Fresh',        'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'LET-01'), '2025-02-22 08:45:00', (SELECT user_id FROM users WHERE username = 'ithompson'), 'Possum', NULL,     'Adult',    'Sprung',                 'Yes', 'Lure',         NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'LET-01'), '2025-04-14 09:00:00', (SELECT user_id FROM users WHERE username = 'ithompson'), 'Rat',    'Male',   'Adult',    'Sprung',                 'Yes', 'Peanut butter',NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'LET-01'), '2025-06-28 08:00:00', (SELECT user_id FROM users WHERE username = 'ithompson'), 'None',   NULL,     NULL,       'Still set, bait OK',     'No',  'None',         NULL,           'Needs maintenance',0, 'Water damage noted'),
((SELECT trap_id FROM traps WHERE code = 'LET-01'), '2025-08-18 09:30:00', (SELECT user_id FROM users WHERE username = 'ithompson'), 'Stoat',  'Female', 'Juvenile', 'Sprung',                 'Yes', 'Egg',          NULL,           'Repaired',         1, 'Repaired after water damage'),
((SELECT trap_id FROM traps WHERE code = 'LET-01'), '2025-10-25 08:15:00', (SELECT user_id FROM users WHERE username = 'ithompson'), 'None',   NULL,     NULL,       'Still set, bait OK',     'No',  'None',         NULL,           'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'LET-01'), '2025-12-20 09:00:00', (SELECT user_id FROM users WHERE username = 'ithompson'), 'Rat',    'Female', 'Adult',    'Sprung',                 'Yes', 'Chocolate',    NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'LET-01'), '2026-02-25 08:30:00', (SELECT user_id FROM users WHERE username = 'ithompson'), 'None',   NULL,     NULL,       'Still set, bait missing','Yes', 'Peanut butter','Full replacement','OK',             0, NULL),
((SELECT trap_id FROM traps WHERE code = 'LET-01'), '2026-04-12 09:00:00', (SELECT user_id FROM users WHERE username = 'ithompson'), 'Possum', NULL,     'Juvenile', 'Sprung',                 'Yes', 'Lure',         NULL,           'OK',               1, NULL),

-- Arboretum North Track catches
((SELECT trap_id FROM traps WHERE code = 'ANT-01'), '2024-03-22 08:00:00', (SELECT user_id FROM users WHERE username = 'wbrown'), 'Rat',    'Male',   'Adult',    'Sprung',                 'Yes', 'Peanut butter',NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'ANT-01'), '2024-05-30 09:00:00', (SELECT user_id FROM users WHERE username = 'wbrown'), 'None',   NULL,     NULL,       'Still set, bait OK',     'No',  'None',         NULL,           'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'ANT-01'), '2024-08-05 08:30:00', (SELECT user_id FROM users WHERE username = 'wbrown'), 'Stoat',  'Female', 'Adult',    'Sprung',                 'Yes', 'Egg',          NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'ANT-01'), '2024-10-20 09:15:00', (SELECT user_id FROM users WHERE username = 'wbrown'), 'None',   NULL,     NULL,       'Still set, bait bad',    'Yes', 'Egg',          'Replaced',     'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'ANT-01'), '2024-12-15 08:45:00', (SELECT user_id FROM users WHERE username = 'wbrown'), 'Mouse',  'Male',   'Adult',    'Sprung',                 'Yes', 'Chocolate',    NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'ANT-01'), '2025-02-25 09:00:00', (SELECT user_id FROM users WHERE username = 'wbrown'), 'Stoat',  'Male',   'Juvenile', 'Sprung',                 'Yes', 'Egg',          NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'ANT-01'), '2025-04-28 08:15:00', (SELECT user_id FROM users WHERE username = 'wbrown'), 'None',   NULL,     NULL,       'Still set, bait OK',     'No',  'None',         NULL,           'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'ANT-01'), '2025-06-20 09:30:00', (SELECT user_id FROM users WHERE username = 'wbrown'), 'Rat',    'Female', 'Adult',    'Sprung',                 'Yes', 'Peanut butter',NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'ANT-01'), '2025-08-25 08:00:00', (SELECT user_id FROM users WHERE username = 'wbrown'), 'None',   NULL,     NULL,       'Still set, bait OK',     'No',  'None',         NULL,           'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'ANT-01'), '2025-10-18 09:00:00', (SELECT user_id FROM users WHERE username = 'wbrown'), 'Weasel', 'Male',   'Adult',    'Sprung',                 'Yes', 'Rabbit',       NULL,           'OK',               1, 'Weasel sighting confirmed'),
((SELECT trap_id FROM traps WHERE code = 'ANT-01'), '2025-12-10 08:30:00', (SELECT user_id FROM users WHERE username = 'wbrown'), 'Stoat',  'Female', 'Adult',    'Sprung',                 'Yes', 'Egg',          NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'ANT-01'), '2026-02-14 09:15:00', (SELECT user_id FROM users WHERE username = 'wbrown'), 'None',   NULL,     NULL,       'Still set, bait missing','Yes', 'Egg',          'Full replacement','OK',             0, NULL),
((SELECT trap_id FROM traps WHERE code = 'ANT-01'), '2026-04-08 08:45:00', (SELECT user_id FROM users WHERE username = 'wbrown'), 'Rat',    'Male',   'Juvenile', 'Sprung',                 'Yes', 'Chocolate',    NULL,           'OK',               1, NULL),

-- Research Farm North catches
((SELECT trap_id FROM traps WHERE code = 'RFN-01'), '2024-04-05 08:00:00', (SELECT user_id FROM users WHERE username = 'cwilson'), 'Rabbit', NULL,     NULL,       'Sprung',                 'Yes', 'Lure',         NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'RFN-01'), '2024-06-10 09:00:00', (SELECT user_id FROM users WHERE username = 'cwilson'), 'None',   NULL,     NULL,       'Still set, bait OK',     'No',  'None',         NULL,           'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'RFN-01'), '2024-08-18 08:30:00', (SELECT user_id FROM users WHERE username = 'cwilson'), 'Stoat',  'Male',   'Adult',    'Sprung',                 'Yes', 'Egg',          NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'RFN-01'), '2024-10-25 09:15:00', (SELECT user_id FROM users WHERE username = 'cwilson'), 'None',   NULL,     NULL,       'Still set, bait OK',     'No',  'None',         NULL,           'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'RFN-01'), '2024-12-20 08:45:00', (SELECT user_id FROM users WHERE username = 'cwilson'), 'Rat',    'Female', 'Adult',    'Sprung',                 'Yes', 'Peanut butter',NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'RFN-01'), '2025-02-28 09:00:00', (SELECT user_id FROM users WHERE username = 'cwilson'), 'Possum', NULL,     'Adult',    'Sprung',                 'Yes', 'Lure',         NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'RFN-01'), '2025-04-22 08:15:00', (SELECT user_id FROM users WHERE username = 'cwilson'), 'None',   NULL,     NULL,       'Still set, bait bad',    'Yes', 'Lure',         'Replaced',     'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'RFN-01'), '2025-06-15 09:30:00', (SELECT user_id FROM users WHERE username = 'cwilson'), 'Rabbit', NULL,     NULL,       'Sprung',                 'Yes', 'Lure',         NULL,           'Needs maintenance',1, 'Trap corroded'),
((SELECT trap_id FROM traps WHERE code = 'RFN-01'), '2025-08-28 08:00:00', (SELECT user_id FROM users WHERE username = 'cwilson'), 'None',   NULL,     NULL,       'Still set, bait OK',     'No',  'None',         NULL,           'Repaired',         0, 'Treated for corrosion'),
((SELECT trap_id FROM traps WHERE code = 'RFN-01'), '2025-10-22 09:00:00', (SELECT user_id FROM users WHERE username = 'cwilson'), 'Stoat',  'Female', 'Juvenile', 'Sprung',                 'Yes', 'Egg',          NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'RFN-01'), '2025-12-18 08:30:00', (SELECT user_id FROM users WHERE username = 'cwilson'), 'None',   NULL,     NULL,       'Still set, bait OK',     'No',  'None',         NULL,           'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'RFN-01'), '2026-02-20 09:15:00', (SELECT user_id FROM users WHERE username = 'cwilson'), 'Rat',    'Male',   'Adult',    'Sprung',                 'Yes', 'Chocolate',    NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'RFN-01'), '2026-04-14 08:45:00', (SELECT user_id FROM users WHERE username = 'cwilson'), 'None',   NULL,     NULL,       'Still set, bait missing','Yes', 'Peanut butter','Full replacement','OK',             0, NULL),

-- West Shelter Belt catches
((SELECT trap_id FROM traps WHERE code = 'WSB-01'), '2024-04-12 08:00:00', (SELECT user_id FROM users WHERE username = 'eclarke'), 'Stoat',  'Male',   'Adult',    'Sprung',                 'Yes', 'Egg',          NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'WSB-01'), '2024-06-18 09:00:00', (SELECT user_id FROM users WHERE username = 'eclarke'), 'None',   NULL,     NULL,       'Still set, bait OK',     'No',  'None',         NULL,           'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'WSB-01'), '2024-08-25 08:30:00', (SELECT user_id FROM users WHERE username = 'eclarke'), 'Rat',    'Female', 'Juvenile', 'Sprung',                 'Yes', 'Peanut butter',NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'WSB-01'), '2024-10-30 09:15:00', (SELECT user_id FROM users WHERE username = 'eclarke'), 'None',   NULL,     NULL,       'Still set, bait bad',    'Yes', 'Egg',          'Replaced',     'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'WSB-01'), '2025-01-05 08:45:00', (SELECT user_id FROM users WHERE username = 'eclarke'), 'Stoat',  'Female', 'Adult',    'Sprung',                 'Yes', 'Egg',          NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'WSB-01'), '2025-03-12 09:00:00', (SELECT user_id FROM users WHERE username = 'eclarke'), 'Mouse',  'Male',   'Juvenile', 'Sprung',                 'Yes', 'Chocolate',    NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'WSB-01'), '2025-05-18 08:15:00', (SELECT user_id FROM users WHERE username = 'eclarke'), 'None',   NULL,     NULL,       'Still set, bait OK',     'No',  'None',         NULL,           'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'WSB-01'), '2025-07-22 09:30:00', (SELECT user_id FROM users WHERE username = 'eclarke'), 'Stoat',  'Male',   'Juvenile', 'Sprung',                 'Yes', 'Egg',          NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'WSB-01'), '2025-09-15 08:00:00', (SELECT user_id FROM users WHERE username = 'eclarke'), 'None',   NULL,     NULL,       'Still set, bait OK',     'No',  'None',         NULL,           'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'WSB-01'), '2025-11-28 09:00:00', (SELECT user_id FROM users WHERE username = 'eclarke'), 'Rat',    'Female', 'Adult',    'Sprung',                 'Yes', 'Peanut butter',NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'WSB-01'), '2026-01-25 08:30:00', (SELECT user_id FROM users WHERE username = 'eclarke'), 'None',   NULL,     NULL,       'Still set, bait OK',     'No',  'None',         NULL,           'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'WSB-01'), '2026-03-22 09:15:00', (SELECT user_id FROM users WHERE username = 'eclarke'), 'Stoat',  'Male',   'Adult',    'Sprung',                 'Yes', 'Egg',          NULL,           'OK',               1, NULL),

-- Retired line catches (Old Farm Track — before retirement date)
((SELECT trap_id FROM traps WHERE code = 'OFT-01'), '2024-04-20 08:00:00', (SELECT user_id FROM users WHERE username = 'landerson'), 'Rat',    'Male',   'Adult',    'Sprung',                 'Yes', 'Peanut butter',NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'OFT-01'), '2024-07-15 09:00:00', (SELECT user_id FROM users WHERE username = 'landerson'), 'None',   NULL,     NULL,       'Still set, bait OK',     'No',  'None',         NULL,           'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'OFT-01'), '2024-10-22 08:30:00', (SELECT user_id FROM users WHERE username = 'landerson'), 'Stoat',  'Female', 'Adult',    'Sprung',                 'Yes', 'Egg',          NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'OFT-01'), '2025-01-18 09:00:00', (SELECT user_id FROM users WHERE username = 'landerson'), 'None',   NULL,     NULL,       'Still set, bait bad',    'Yes', 'Egg',          'Replaced',     'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'OFT-01'), '2025-04-10 08:15:00', (SELECT user_id FROM users WHERE username = 'landerson'), 'Rat',    'Male',   'Juvenile', 'Sprung',                 'Yes', 'Chocolate',    NULL,           'OK',               1, NULL),

((SELECT trap_id FROM traps WHERE code = 'TFL-01'), '2024-05-15 08:00:00', (SELECT user_id FROM users WHERE username = 'owalker'), 'Mouse',  'Female', 'Adult',    'Sprung',                 'Yes', 'Peanut butter',NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'TFL-01'), '2024-08-20 09:00:00', (SELECT user_id FROM users WHERE username = 'owalker'), 'None',   NULL,     NULL,       'Still set, bait OK',     'No',  'None',         NULL,           'OK',               0, NULL),
((SELECT trap_id FROM traps WHERE code = 'TFL-01'), '2024-11-25 08:30:00', (SELECT user_id FROM users WHERE username = 'owalker'), 'Rat',    'Male',   'Adult',    'Sprung',                 'Yes', 'Chocolate',    NULL,           'OK',               1, NULL),
((SELECT trap_id FROM traps WHERE code = 'TFL-01'), '2025-02-15 09:00:00', (SELECT user_id FROM users WHERE username = 'owalker'), 'None',   NULL,     NULL,       'Still set, bait OK',     'No',  'None',         NULL,           'OK',               0, NULL)

ON CONFLICT DO NOTHING;

-- ══════════════════════════════════════════════════════
-- INCIDENTAL OBSERVATIONS
-- ══════════════════════════════════════════════════════

INSERT INTO incidental_observations (date, operator_id, observation_type, notes, latitude, longitude, line_id) VALUES
('2024-02-15 07:30:00', (SELECT user_id FROM users WHERE username = 'landerson'), 'Predator sighting',     'Spotted stoat near north paddock fence line.',         -43.638200, 172.462500, (SELECT line_id FROM lines WHERE name = 'North Paddock Line')),
('2024-03-10 08:00:00', (SELECT user_id FROM users WHERE username = 'owalker'),   'Native species sign',   'Fantail nest found near library quadrant.',             -43.643100, 172.468200, (SELECT line_id FROM lines WHERE name = 'Library Quadrant Track')),
('2024-04-22 09:15:00', (SELECT user_id FROM users WHERE username = 'ncampbell'), 'Predator tracks',       'Possum tracks in mud after overnight rain.',            -43.652300, 172.468600, (SELECT line_id FROM lines WHERE name = 'South Boundary Line')),
('2024-05-18 08:30:00', (SELECT user_id FROM users WHERE username = 'sroberts'),  'Bird sighting',         'Kererū pair observed feeding in riparian zone.',        -43.645500, 172.484800, (SELECT line_id FROM lines WHERE name = 'East Riparian Track')),
('2024-06-25 07:45:00', (SELECT user_id FROM users WHERE username = 'eclarke'),   'Predator sighting',     'Weasel seen crossing west boundary track at dawn.',     -43.648100, 172.459200, (SELECT line_id FROM lines WHERE name = 'West Shelter Belt')),
('2024-07-14 09:00:00', (SELECT user_id FROM users WHERE username = 'ithompson'), 'Native species tracks', 'Pūkeko tracks along lake edge. Good habitat indicator.', -43.650600, 172.466800, (SELECT line_id FROM lines WHERE name = 'Lake Edge Track')),
('2024-08-28 08:15:00', (SELECT user_id FROM users WHERE username = 'wbrown'),    'Predator tracks',       'Fresh rat burrow system near arboretum east wall.',     -43.641200, 172.464800, (SELECT line_id FROM lines WHERE name = 'Arboretum North Track')),
('2024-09-12 09:30:00', (SELECT user_id FROM users WHERE username = 'cwilson'),   'Other',                 'Evidence of grazing damage near research farm traps.',  -43.656500, 172.470800, (SELECT line_id FROM lines WHERE name = 'Research Farm North')),
('2024-10-05 08:00:00', (SELECT user_id FROM users WHERE username = 'landerson'), 'Bird sighting',         'Morepork heard at dusk near north shelter belt.',        -43.639300, 172.468800, (SELECT line_id FROM lines WHERE name = 'North Shelter Belt')),
('2024-11-20 07:30:00', (SELECT user_id FROM users WHERE username = 'owalker'),   'Predator sighting',     'Rat observed running along main campus wall at night.', -43.641600, 172.470800, (SELECT line_id FROM lines WHERE name = 'Main Campus Circuit')),
('2024-12-10 09:00:00', (SELECT user_id FROM users WHERE username = 'ncampbell'), 'Native species sign',   'Kiwi feathers found near south shelter belt — unusual.', -43.653200, 172.472400, (SELECT line_id FROM lines WHERE name = 'South Shelter Belt')),
('2025-01-08 08:30:00', (SELECT user_id FROM users WHERE username = 'sroberts'),  'Predator tracks',       'Stoat footprints in tracking tunnel mud insert.',       -43.646200, 172.485600, (SELECT line_id FROM lines WHERE name = 'East Riparian Track')),
('2025-02-22 07:45:00', (SELECT user_id FROM users WHERE username = 'eclarke'),   'Bird sighting',         'Kākā sighted perching in arboretum — first record.',    -43.640800, 172.465200, (SELECT line_id FROM lines WHERE name = 'Arboretum East Perimeter')),
('2025-03-15 09:15:00', (SELECT user_id FROM users WHERE username = 'ithompson'), 'Predator sighting',     'Possum spotted in lake loop north — large individual.',  -43.649200, 172.464400, (SELECT line_id FROM lines WHERE name = 'Lake Loop North')),
('2025-04-28 08:00:00', (SELECT user_id FROM users WHERE username = 'wbrown'),    'Native species tracks', 'Kererū feeding tracks near arboretum south.',            -43.641200, 172.463400, (SELECT line_id FROM lines WHERE name = 'Arboretum South Track')),
('2025-05-20 09:30:00', (SELECT user_id FROM users WHERE username = 'cwilson'),   'Other',                 'Irrigation pipe damaged near equine centre traps.',     -43.655200, 172.464400, (SELECT line_id FROM lines WHERE name = 'Equine Centre Track')),
('2025-06-12 08:15:00', (SELECT user_id FROM users WHERE username = 'landerson'), 'Predator sighting',     'Hedgehog observed near sports field perimeter at dusk.', -43.646200, 172.472400, (SELECT line_id FROM lines WHERE name = 'Sports Field Perimeter')),
('2025-07-25 07:30:00', (SELECT user_id FROM users WHERE username = 'owalker'),   'Bird sighting',         'Tūī heard singing near conference centre loop.',         -43.641200, 172.477200, (SELECT line_id FROM lines WHERE name = 'Conference Centre Loop')),
('2025-08-18 09:00:00', (SELECT user_id FROM users WHERE username = 'ncampbell'), 'Predator tracks',       'Possum claw marks on orchard trees — recent activity.',  -43.655500, 172.482200, (SELECT line_id FROM lines WHERE name = 'Orchard Track East')),
('2025-09-10 08:30:00', (SELECT user_id FROM users WHERE username = 'sroberts'),  'Native species sign',   'Gecko spotted under trap cover — positive sign.',       -43.646800, 172.487200, (SELECT line_id FROM lines WHERE name = 'East Boundary Line')),
('2025-10-22 07:45:00', (SELECT user_id FROM users WHERE username = 'eclarke'),   'Predator sighting',     'Rat running along west boundary at 6am.',               -43.648800, 172.456400, (SELECT line_id FROM lines WHERE name = 'West Boundary Track')),
('2025-11-14 09:15:00', (SELECT user_id FROM users WHERE username = 'ithompson'), 'Bird sighting',         'Pied stilt pair nesting near wetland reserve.',          -43.652200, 172.463200, (SELECT line_id FROM lines WHERE name = 'Wetland Reserve Line')),
('2025-12-08 08:00:00', (SELECT user_id FROM users WHERE username = 'wbrown'),    'Other',                 'Old trap from previous season found buried — removed.',  -43.640500, 172.466400, (SELECT line_id FROM lines WHERE name = 'Arboretum East Perimeter')),
('2026-01-15 09:30:00', (SELECT user_id FROM users WHERE username = 'cwilson'),   'Predator sighting',     'Stoat with prey item crossing research farm south.',    -43.658200, 172.472400, (SELECT line_id FROM lines WHERE name = 'Research Farm South')),
('2026-02-28 08:15:00', (SELECT user_id FROM users WHERE username = 'landerson'), 'Native species tracks', 'Skink tracks near north gate perimeter — positive sign.',-43.636800, 172.476400, (SELECT line_id FROM lines WHERE name = 'North Gate Perimeter')),
('2026-03-20 07:45:00', (SELECT user_id FROM users WHERE username = 'owalker'),   'Predator tracks',       'Fresh stoat prints in tracking card by admin block.',   -43.642800, 172.465200, (SELECT line_id FROM lines WHERE name = 'Administration Perimeter')),
('2026-04-10 09:00:00', (SELECT user_id FROM users WHERE username = 'ncampbell'), 'Bird sighting',         'Kererū flock of 8 in south shelter belt trees.',         -43.653500, 172.472200, (SELECT line_id FROM lines WHERE name = 'South Shelter Belt')),
('2026-04-15 08:30:00', (SELECT user_id FROM users WHERE username = 'ithompson'), 'Predator sighting',     'Rat nest found beside lake loop south trap.',            -43.651200, 172.465400, (SELECT line_id FROM lines WHERE name = 'Lake Loop South'))

ON CONFLICT DO NOTHING;

-- ══════════════════════════════════════════════════════
-- TEST JOIN REQUESTS
-- Two users with no group membership — pending requests to join PFLÜ
-- Log in as dchen / Password1! (Group Coordinator) to approve/reject
-- ══════════════════════════════════════════════════════

INSERT INTO users (username, email, password_hash, first_name, last_name, account_status, date_joined) VALUES
('trequest1', 'tom.request@example.com',  '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Tom',   'Request', 'active', NOW()),
('trequest2', 'sara.request@example.com', '$2b$12$UgOAbgTWVU08KBBX85L0h.yFdWzm.tFv99mt/C/7uF62jxBfzUtbS', 'Sara',  'Request', 'active', NOW())
ON CONFLICT (username) DO NOTHING;

INSERT INTO group_join_requests (user_id, group_id, status, message, requested_at)
VALUES
(
    (SELECT user_id FROM users WHERE username = 'trequest1'),
    (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'),
    'pending',
    'Hi, I am a local volunteer and have been trapping in the area for two years. I would love to contribute to the group effort and help with data recording on the north campus lines.',
    NOW() - INTERVAL '2 days'
),
(
    (SELECT user_id FROM users WHERE username = 'trequest2'),
    (SELECT group_id FROM groups WHERE name = 'Predator Free Lincoln University'),
    'pending',
    'Keen to join!',
    NOW() - INTERVAL '1 day'
)
ON CONFLICT (user_id, group_id) DO NOTHING;

-- ══════════════════════════════════════════════════════
-- RESET SEQUENCES
-- ══════════════════════════════════════════════════════

SELECT setval('users_user_id_seq',                  (SELECT MAX(user_id)         FROM users));
SELECT setval('lines_line_id_seq',                  (SELECT MAX(line_id)         FROM lines));
SELECT setval('traps_trap_id_seq',                  (SELECT MAX(trap_id)         FROM traps));
SELECT setval('trap_catches_catch_id_seq',           (SELECT MAX(catch_id)        FROM trap_catches));
SELECT setval('incidental_observations_observation_id_seq', (SELECT MAX(observation_id) FROM incidental_observations));
SELECT setval('group_join_requests_request_id_seq', (SELECT MAX(request_id)      FROM group_join_requests));
SELECT setval('user_notifications_notification_id_seq', (SELECT MAX(notification_id) FROM user_notifications));

COMMIT;


