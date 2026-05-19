-- kb_seed.sql — Seed Knowledge Base articles for the Tiaki platform.
-- Run after create_tables.sql has created kb_categories and kb_articles.
-- Uses name-based lookups for category_id so ID order doesn't matter.

-- ── Account & Login ───────────────────────────────────────────────────────────

INSERT INTO kb_articles (category_id, title, body, is_published)
VALUES (
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

INSERT INTO kb_articles (category_id, title, body, is_published)
VALUES (
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

INSERT INTO kb_articles (category_id, title, body, is_published)
VALUES (
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

INSERT INTO kb_articles (category_id, title, body, is_published)
VALUES (
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

-- ── Lines & Traps ─────────────────────────────────────────────────────────────

INSERT INTO kb_articles (category_id, title, body, is_published)
VALUES (
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

INSERT INTO kb_articles (category_id, title, body, is_published)
VALUES (
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

INSERT INTO kb_articles (category_id, title, body, is_published)
VALUES (
  (SELECT category_id FROM kb_categories WHERE name = 'Lines & Traps'),
  'What does "retired" mean for a trap?',
  'A retired trap is one that has been permanently removed from service. Retired traps are kept in the system for historical record purposes — any catch records associated with them are preserved.

You cannot add new catch records to a retired trap.

A trap can be retired by a Group Coordinator or Super Admin from the line detail page. If a trap has been retired by mistake, contact your Group Coordinator to have it unretired.',
  TRUE
);

-- ── Bait Stations ─────────────────────────────────────────────────────────────

INSERT INTO kb_articles (category_id, title, body, is_published)
VALUES (
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

INSERT INTO kb_articles (category_id, title, body, is_published)
VALUES (
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

-- ── Records ───────────────────────────────────────────────────────────────────

INSERT INTO kb_articles (category_id, title, body, is_published)
VALUES (
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

INSERT INTO kb_articles (category_id, title, body, is_published)
VALUES (
  (SELECT category_id FROM kb_categories WHERE name = 'Records'),
  'How do I view my catch records?',
  'To review the records you have submitted:

1. Click "My Catch Records" in the navigation.
2. Your records are listed in reverse chronological order.
3. Use the filter controls at the top to narrow by date range, species, or line.

To see all records across the group (not just yours), click "Catch Records" in the navigation instead.',
  TRUE
);

INSERT INTO kb_articles (category_id, title, body, is_published)
VALUES (
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
