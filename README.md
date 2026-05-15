# Tiaki — Predator Trapping & Monitoring

A web application for Predator Free Lincoln University (PF-LU), a fictional volunteer group running a predator-control initiative across the Lincoln University campus.

Built as part of **COMP639 Group Project 1, Semester 1, 2026** by Team Huhu at Lincoln University, New Zealand.

**Live URL:** http://pflu.pythonanywhere.com

---

## The Team

| Name | GitHub |
|---|---|
| Ben Fitzgerald | @Ben-Fitzgerald-1170063 |
| Da-young Kim | @Dayoung-Kim-1171294 |
| Ming-Cheng Hsiao | @hsiaomingcheng |
| Ziyuan Sun | @Ziyuan-Sun-1172292 |
| Jeremiah Ruanes | @Jeremiah-Ruanes-1172832 |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Backend | Python 3, Flask |
| Database | PostgreSQL |
| Frontend | Bootstrap 5, HTML, CSS, JavaScript |
| Charting | Chart.js |
| Maps | Leaflet.js |
| Email | Flask-Mail (Gmail SMTP) |
| Hosting | PythonAnywhere |

---

## Features

**All roles**
- View all trap lines and traps on an interactive map
- Browse and filter all catch records and incidental observations
- View reports and charts with filters by line, operator, and date range
- Download catch records as CSV

**Operator** (field worker)
- Add and edit own catch records for assigned trap lines
- Record incidental observations
- View assigned lines with map

**Admin** (system administrator)
- Manage users — assign roles, activate/deactivate
- Create and edit trap lines and traps
- Assign/deassign operators to lines
- Manage lookup data — species, trap statuses, bait types
- Retire lines and traps

**Group Coordinator + Super Admin** (theme management)
- Browse a gallery of pre-made themes, apply one in a click, or customise from scratch
- Save customised themes by name and re-apply them later from the gallery's **Saved themes** section
- View a 10-deep auto-snapshot history; pin a snapshot to keep it past the cap; restore any past snapshot
- Export the current theme as JSON for off-platform archive; re-import to apply
- Upload a group cover photo and profile photo (JPG / PNG / WEBP / SVG); ungenerated slots fall back to a branded gradient with the group's initials
- Super Admin can manage either the platform default theme or any group's theme via the target picker

See [Custom Themes Epic](#custom-themes-epic) below for the architecture deep-dive.

---

## Test Accounts

All test accounts use the password: **`Password1!`**

| Role | Username | Name |
|---|---|---|
| Admin | `smitchell` | Sarah Mitchell |
| Admin | `jthornton` | James Thornton |
| Operator | `landerson` | Liam Anderson |
| Operator | `owalker` | Olivia Walker |
| Operator | `ncampbell` | Noah Campbell |
| Observer | `ataylor` | Ava Taylor |
| Observer | `mharris` | Mason Harris |
| Observer | `ejackson` | Elijah Jackson |

---

## Project Structure

```
COMP639_Project_1_Huhu/
├── run.py                          # App entry point
├── requirements.txt                # Python dependencies
├── .env.example                    # Environment variable template
├── sql/
│   ├── create_database.sql         # Schema creation script
│   └── populate_database.sql       # Sample data script
└── app/
    ├── __init__.py                 # App factory, context processor, filters
    ├── db.py                       # PostgreSQL connection handler
    ├── utils.py                    # Decorators, validators, helpers
    ├── auth.py                     # Register, login, logout, profile, password
    ├── home.py                     # Public home page
    ├── admin.py                    # Admin dashboard and user management
    ├── operator.py                 # Operator dashboard, add catch/observation
    ├── observer.py                 # Observer dashboard
    ├── lines.py                    # Trap lines and traps
    ├── general.py                  # Shared routes — catch records, observations
    ├── reports.py                  # Reports and chart data
    ├── helpers/
    │   ├── dbHelper.py             # Shared DB query helpers
    │   └── trapCatchHelper.py      # Catch record validation helpers
    ├── static/
    │   ├── css/custom.css          # All application styles and CSS variables
    │   ├── js/main.js              # Sidebar toggle and shared JS
    │   └── images/                 # Logo, icon, team photos, user uploads
    └── templates/
        ├── base.html               # Master layout with sidebar
        ├── base_auth.html          # Auth page layout
        ├── home.html               # Public home page
        ├── auth/                   # Login, register, profile, password pages
        ├── admin/                  # Admin dashboard, user management, manage lists
        ├── operator/               # Operator dashboard, add catch/observation
        ├── observer/               # Observer dashboard, catch records, observations
        ├── lines/                  # Trap lines index, detail, edit
        └── reports/                # Reports and charts page
```

---

## Local Setup

### Prerequisites
- Python 3.10+
- PostgreSQL
- Git

### Steps

1. **Clone the repository**
```bash
git clone https://github.com/COMP639-StudioProjects-26S1/COMP639_Project_1_Huhu.git
cd COMP639_Project_1_Huhu
```

2. **Create and activate a virtual environment**
```bash
python3 -m venv venv
source venv/bin/activate
```

3. **Install dependencies**
```bash
pip install -r requirements.txt
```

4. **Configure environment variables**
```bash
cp .env.example .env
```
Edit `.env` with your local DB credentials and mail settings.

5. **Set up the database**

Create a local PostgreSQL database, then run:
```bash
psql -U postgres -d your_database -f sql/create_database.sql
psql -U postgres -d your_database -f sql/populate_database.sql
```

6. **Run the application**
```bash
python3 run.py
```

Visit `http://127.0.0.1:5000`

---

## PythonAnywhere Deployment

1. Upload all project files via the PythonAnywhere Files tab or GitHub pull
2. Edit the WSGI configuration file to import your app (e.g., `from app import app as application`)
3. Add `lincolnmac` as a teacher via the Account -> Education tab
4. Create and configure the `.env` file in your project root with production DB credentials and a secure `SECRET_KEY`
5. Reload the web app from the Web tab

---

## GenAI Acknowledgement

All team members utilised Generative AI tools (including ChatGPT, Claude, and Gemini) throughout the project lifecycle to assist with various development tasks. 

**AI was primarily used by the team for:**
- Complex multi-join SQL queries for reports and dashboards
- Repetitive boilerplate across similar route structures
- Generating realistic NZ-context sample data for `populate_database.sql`
- Debugging Flask routes and Jinja2 template errors
- CSS component design and `custom.css` structure

While GenAI served as a valuable development accelerator for everyone, the team mostly independently managed core application architecture, database schema design, UI/UX decisions, and final code reviews to ensure the project met all requirements.

---

## Custom Themes Epic

The Custom Themes epic lets a Group Coordinator brand their group's pages — colours, fonts, button style, navigation layout — and lets a Super Admin do the same for the platform default that every un-themed group inherits. The whole epic flows through one set of theme tables, one editor, and one gallery — everything else is layered on top.

### Architecture at a glance

```
                     ┌──────────────────────────────────────────┐
                     │  inject_theme_identity (context proc)    │
                     │  reads session['group_id'] each request  │
                     └────────────────┬─────────────────────────┘
                                      │
              ┌───────────────────────┴───────────────────────┐
              │                                               │
   group_themes (per-group overrides)            platform_theme (singleton fallback)
              │                                               │
              └────────────────┬──────────────────────────────┘
                               │
                  base.html emits a <style> block with
                  --theme-primary / --theme-secondary /
                  --theme-background / --theme-button-radius
                  + Google Fonts <link>s
                               │
                  custom.css derives --pf-* shades from --theme-primary
                  via color-mix() so the in-app chrome flips too
```

### Database tables

| Table | Purpose |
|---|---|
| `theme_presets` | Library of seed themes shown in the gallery (Default Tiaki, Forest, Coastal, Tussock, Pōhutukawa). |
| `platform_theme` | Singleton (`CHECK (id = 1)`) — the fallback every un-themed group inherits. Default Tiaki preset row mirrors this on every write. |
| `group_themes` | Per-group override row (PK = `group_id`). Falls back to `platform_theme` when absent. |
| `theme_history` | Pre-overwrite snapshots. Auto-snapshots cap at 10 per group; pinned rows (named, `is_pinned = TRUE`) are exempt and persist indefinitely as **Saved themes**. |
| `groups.cover_photo` / `groups.profile_photo` | Per-group identity uploads, relative to `/static/`. NULL falls back to the generated SVG default. |

### Theme columns (shared shape)

`theme_presets`, `platform_theme`, `group_themes`, and `theme_history` all carry the same eight themable columns plus tracking:

| Column | Type / values |
|---|---|
| `primary_color`, `secondary_color`, `background_color` | `VARCHAR(7)` hex with `^#[0-9A-Fa-f]{6}$` CHECK |
| `button_style` | ENUM `button_style_type` — `'rounded'` or `'square'` |
| `font_heading`, `font_body` | `VARCHAR(80)` from `themes.FONT_HEADING_WHITELIST` / `FONT_BODY_WHITELIST` |
| `nav_position` | ENUM `nav_position_type` — `'sidebar'` or `'topbar'` |
| `content_width` | ENUM `content_width_type` — `'wrap'` or `'full'` |
| `based_on_preset` | FK → `theme_presets(preset_id)`, preserved across customisations as the lineage marker |

### Routes

| Method · Path | Purpose |
|---|---|
| `GET /coordinator/themes` | Theme gallery — Featured active card, **Saved themes** section, preset grid (with Start-from-scratch tile leading) |
| `GET /coordinator/themes/<id>` | Single-preset preview page |
| `POST /coordinator/themes/<id>/apply` | Apply a preset to the active target (atomic snapshot → UPSERT → cap) |
| `POST /coordinator/themes/saved/<history_id>/apply` | Apply a pinned saved theme to the active group target |
| `GET /coordinator/themes/customise` | Editor — `?from_preset=<id>` to inherit, `?blank=1` for the blank canvas |
| `POST /coordinator/themes/customise` | Save the customised theme; optional `save_name` also pins it to Saved themes |
| `GET /coordinator/themes/history` | Saved themes (pinned) + Recent customisations (auto-snapshots) |
| `POST /coordinator/themes/history/save-as` | Pin the current theme with a name |
| `POST /coordinator/themes/history/<id>/restore` | Re-apply a snapshot (snapshots the current state first → reversible) |
| `POST /coordinator/themes/history/<id>/delete` | Delete a pinned snapshot |
| `GET /coordinator/themes/export` | Download the current theme as JSON (`tiaki_theme_format: 1`) |
| `POST /coordinator/themes/import` | Re-apply a previously exported JSON |
| `GET /coordinator/themes/select-target` | Super Admin picker — Platform default + every active group |
| `POST /coordinator/themes/select-target` | Stash the chosen target in `session['theme_target_*']` |
| `GET /coordinator/group/identity` | Cover + profile upload page |
| `POST /coordinator/group/identity/{cover,profile}` | Upload (JPG / PNG / WEBP / SVG, max 2 MB, magic-byte sniffed, SVGs script-stripped) |
| `POST /coordinator/group/identity/{cover,profile}/remove` | Remove the uploaded slot → fall back to the generated default |
| `GET /identity/default/group/<id>/{cover,profile}.svg` | On-the-fly branded SVG default (primary→secondary gradient with group initials) |
| `GET /identity/default/platform/{cover,profile}.svg` | Platform SVG defaults (initial "T") |

### Super Admin admin path

Super Admins have no group membership, so their session has no `group_id`. The theme target picker page lists every active group plus a "Platform default" tile; clicking one stashes `session['theme_target_type']` / `session['theme_target_group_id']` / `session['theme_target_name']`. The keys are intentionally **separate** from `session['group_id']` — managing Group X's hot-pink theme doesn't flip the Super Admin's own admin dashboard into hot-pink.

Every theme route opens with `themes.resolve_theme_target(session)` which returns the right target for both Coordinators (their session group) and Super Admins (the picked target), or `None` → redirect to the picker. Reads and writes dispatch through `themes.get_target_theme` / `apply_preset_to_target` / `save_custom_target_theme` so the platform-vs-group branch stays out of the handlers.

### Default Tiaki preset ⇄ platform_theme sync

The "Default Tiaki" preset row (`theme_presets.preset_id = 1`) is treated as the **visible identity** of the platform default. Writes via `apply_preset_to_platform` or `save_custom_platform_theme` mirror their eight themable columns into the preset row inside the same transaction, so the gallery's Default Tiaki tile always reflects the live platform look.

Other presets stay immutable seeds. The Reset button in the editor reads from `themes.get_reset_baseline_for_preset(preset_id)` which falls back to the hardcoded `PLATFORM_DEFAULT_THEME` constant for Default Tiaki — so "Reset to Default Tiaki" always means the **original** Tiaki styling, regardless of how the preset row has drifted.

### Generated default cover + logo SVGs

A group with no uploaded cover/profile still has a branded default: a small SVG rendered on the fly from the group's name and theme colours.

- **Profile**: solid circle in the theme's `primary_color`, 1–3 letter initials in white, 400×400. Initials derive from the group name ("Predator Free Lincoln University" → "PFL").
- **Cover**: `primary_color` → `secondary_color` linear gradient with a white disc at centre carrying the same initials in primary, 1200×400.
- **Platform fallback**: initial "T".

The identity helpers in `themes.py` (`get_active_identity` / `get_platform_identity` / `get_group_identity`) return `<img src>`-ready URLs — `/static/...` for uploads, `/identity/default/...` for the generated route — so templates render `<img src="{{ group_identity.cover_photo }}">` directly without any `url_for('static', ...)` wrapping.

### Customise history + Save-as-Preset

Every preset apply and every customise save writes a snapshot of the **previous** state into `theme_history`. Two row classes share the table:

- **Auto-snapshots** (`name IS NULL`, `is_pinned = FALSE`) — capped at the 10 most recent per group. Acts as a safety net for accidental overwrites.
- **Saved themes** (`name` set, `is_pinned = TRUE`) — exempt from the cap, surface as their own gallery section, and can be re-applied with one click.

A coordinator pins a snapshot by typing a name in the editor's optional "Save as…" field on a normal save, or via the "Save current as…" form at the top of the history page. Restoring a pinned row goes through the same atomic snapshot → UPSERT → cap flow as a customise, so the restore is itself reversible.

### Files

| File | Role |
|---|---|
| `app/themes.py` | All theme helpers: read, validation, write helpers (group + platform), target resolver, dispatch helpers, history. |
| `app/coordinator.py` | Theme routes (gallery, preview, apply, customise, history, export/import, identity, picker). |
| `app/identity_defaults.py` | Four SVG-generating routes for default covers and profiles. |
| `app/templates/coordinator/themes.html` | Gallery: Featured / Saved themes / Other themes (with Start-from-scratch tile). |
| `app/templates/coordinator/theme_edit.html` | Customise editor with optional Save-as name input + live preview. |
| `app/templates/coordinator/theme_history.html` | Saved themes + Recent customisations lists. |
| `app/templates/coordinator/theme_select_target.html` | Super Admin target picker. |
| `app/templates/coordinator/group_identity.html` | Cover + profile upload UI. |
| `app/templates/partials/_theme_tile_preview.html` | Reusable theme thumbnail macro (used by gallery, history, picker). |
| `app/templates/partials/_theme_target_switcher.html` | "Managing themes for: NAME ▾" pill rendered on every theme page (Super Admin only). |
| `static/css/custom.css` | All `.theme-*`, `.theme-tile-*`, `.theme-history-*`, `.theme-target-*` styles + derived `--pf-*` ramp. |
| `static/js/theme-preview.js` | Live-preview JS: sets `--theme-*` on `<html>` + flips body layout classes when a Preview button is clicked. |
| `sql/themes_create.sql` | DDL for the four theme tables + ENUMs + indexes. |
| `sql/themes_populate.sql` | Seeds platform_theme + the 5 presets. |
| `sql/themes_font_split.sql` | Migration: `font_family` → `font_heading` + `font_body`. |
| `sql/themes_history_save_as.sql` | Migration: `theme_history.name` + `is_pinned` columns. |

---

## Role-Based Access — Developer Guide

All protected routes use the `@role_required` decorator from `app/utils.py`.

### How it works

- Unauthenticated request (no session) → redirect to `/login`
- Authenticated but wrong role → HTTP 403 (renders `templates/errors/403.html`)
- Authenticated with an allowed role → route handler runs

The user's active group and role are stored in the session after login (or group selection):

| Session key | Example value |
|---|---|
| `session['user_id']` | `42` |
| `session['group_id']` | `3` |
| `session['group_role']` | `'Group Coordinator'` |
| `session['group_name']` | `'Zealandia Restoration'` |

### Decorator usage

```python
from app.utils import role_required

# Super Admin only
@app.route('/admin/dashboard')
@role_required('Super Admin')
def admin_dashboard():
    ...

# Coordinator or Super Admin
@app.route('/coordinator/dashboard')
@role_required('Group Coordinator', 'Super Admin')
def coordinator_dashboard():
    ...

# Any logged-in user (no role restriction)
@app.route('/profile')
@role_required()
def profile():
    ...
```

Valid role strings: `'Super Admin'`, `'Group Coordinator'`, `'Operator'`, `'Observer'`

### Helper function

```python
from app.utils import get_current_group_role

role = get_current_group_role()  # returns e.g. 'Operator', or None if not in a group
```

Use this inside route handlers or templates (via the context processor) when you need to branch on the current role without rechecking the session key directly.