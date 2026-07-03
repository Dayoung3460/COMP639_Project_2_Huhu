# Tiaki — Community Predator Trapping & Monitoring

Tiaki is a web platform for volunteer predator-control groups in New Zealand. Groups map their trap lines, log catches, bait records, and observations from the field, publish updates to their members, and report on their progress — all under their own branding.

This started as a university group project built with my teammates. The course has since wrapped up, and this fork is my personal continuation of the project — polishing, refactoring, and extending it at my own pace.

**Live URL:** http://tiaki.pythonanywhere.com

---

## Features

**Groups & roles**
- Multi-group platform — public groups are open to browse; private groups gate their content behind a join request
- Per-group roles: **Group Coordinator**, **Operator**, **Observer** — plus site-wide **Super Admin** and **Support Technician** roles
- Group landing pages, membership management, and join-request workflow
- **My Tiaki** — a cross-group personal home page aggregating your activity, groups, and requests

**Field work**
- Interactive maps (Leaflet) of trap lines, traps, and bait stations, with an operational-area editor
- Catch records, bait station records, and incidental observations
- **3D terrain map** — trap lines rendered on real elevation data (Three.js + Open-Elevation API)

**Communication & knowledge**
- **Group Updates** — coordinators publish updates (with photo attachments and drafts); members like and comment; coordinators moderate
- **Knowledge Hub** — shared articles and resources per group
- **AI assistant** — in-app chat agent (Azure AI Foundry) with per-group conversation context
- **Helpdesk** — support ticket submission and tracking, handled by Support Technicians

**Reporting**
- Reports and charts (Chart.js) with filters by line, operator, and date range
- CSV export hub for coordinators

**Theming & identity**
- Theme gallery with pre-made presets, a full customise editor (colours, fonts, button style, nav layout), and live preview
- Saved themes, auto-snapshot history with restore, and JSON export/import
- Group cover and profile photo uploads, with generated branded SVG fallbacks
- Super Admin can manage the platform default theme or any group's theme

---

## Tech Stack

| Layer | Technology |
|---|---|
| Backend | Python 3, Flask |
| Database | PostgreSQL (psycopg2) |
| Frontend | Bootstrap 5, HTML, CSS, JavaScript |
| Charting | Chart.js |
| Maps | Leaflet.js (2D), Three.js + Open-Elevation API (3D) |
| AI assistant | Azure AI Foundry agent (OpenAI Responses API) |
| Email | Flask-Mail (Gmail SMTP) |
| Hosting | PythonAnywhere |

---

## The Original Team

The first version of Tiaki was built by Team Huhu at Lincoln University, New Zealand:

| Name | GitHub |
|---|---|
| Ben Fitzgerald | @Ben-Fitzgerald-1170063 |
| Da-young Kim | @Dayoung-Kim-1171294 |
| Ming-Cheng Hsiao | @hsiaomingcheng |
| Ziyuan Sun | @Ziyuan-Sun-1172292 |
| Jeremiah Ruanes | @Jeremiah-Ruanes-1172832 |

---

## Test Accounts

All test accounts use the password: **`Password1!`**

### Site-Wide Accounts

| Role | Username | Name | Notes |
|---|---|---|---|
| Super Admin | `smitchell` | Sarah Mitchell | |
| Super Admin | `jparata` | James Parata | Also Group Coordinator of Christchurch City Trappers |
| Support Technician | `lchen` | Lily Chen | No group memberships |
| Support Technician | `mreid` | Mark Reid | No group memberships |

### Group Accounts

Group roles are per-group — several users hold different roles in different groups.

| Username | Name | Predator Free Lincoln University | Christchurch City Trappers | Banks Peninsula Restoration |
|---|---|---|---|---|
| `bkim` | Bo Kim | Group Coordinator | — | Operator |
| `cwhite` | Cara White | — | Group Coordinator | — |
| `dlee` | Dana Lee | — | — | Group Coordinator |
| `enyberg` | Erik Nyberg | Operator | — | Group Coordinator |
| `fgrant` | Fiona Grant | Operator | — | Observer |
| `gwatson` | Glen Watson | Operator | — | Observer |
| `hpatel` | Hira Patel | Observer | Operator | — |
| `iford` | Isla Ford | Observer | Operator | — |
| `jmoss` | Jake Moss | Observer | Observer | — |
| `ktaylor` | Kai Taylor | Observer (inactive account) | — | — |

### No-Membership Accounts (for join request testing)

| Username | Name |
|---|---|
| `trequest1` | Tom Request |
| `trequest2` | Sara Request |

---

## Project Structure

```
├── run.py                      # App entry point
├── run_local.py                # Single-process mode for stable debugging
├── requirements.txt            # Python dependencies
├── .env.example                # Environment variable template
├── sql/
│   ├── create_tables.sql       # Schema creation script
│   └── populate_tables.sql     # Sample data script
├── app/
│   ├── __init__.py             # App factory, context processors, filters
│   ├── db.py                   # PostgreSQL connection handler
│   ├── utils.py                # Decorators, validators, helpers
│   ├── auth.py                 # Register, login, logout, profile, password
│   ├── home.py                 # Public home page
│   ├── groups.py               # Group landing pages and visibility logic
│   ├── my_tiaki.py             # Cross-group personal home page
│   ├── admin.py                # Admin dashboard and user management
│   ├── operator.py             # Operator dashboard, add catch/observation
│   ├── observer.py             # Observer dashboard
│   ├── coordinator.py          # Coordinator dashboard, themes, group identity
│   ├── coordinator_export.py   # CSV export hub
│   ├── lines.py                # Trap lines, traps, bait stations
│   ├── general.py              # Shared routes — catch records, observations
│   ├── reports.py              # Reports and chart data
│   ├── updates_hub.py          # Group updates + knowledge hub
│   ├── map3d.py                # 3D terrain map
│   ├── themes.py               # Theme read/write/validation helpers
│   ├── identity_defaults.py    # Generated SVG cover/profile defaults
│   ├── helpdesk.py             # Support ticket submission and tracking
│   ├── agent.py                # AI assistant proxy routes
│   ├── helpers/                # Shared DB and validation helpers
│   └── templates/              # Jinja templates (per-area subfolders)
├── static/
│   ├── css/                    # custom.css + page-specific styles
│   ├── js/                     # Page scripts (maps, forms, theme preview, agent chat)
│   └── images/                 # Logo, icons, user uploads
└── tests/                      # Unit tests
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
git clone git@github.com:Dayoung3460/COMP639_Project_2_Huhu.git
cd COMP639_Project_2_Huhu
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
Edit `.env` with your local DB credentials and mail settings. The `AZURE_AI_AGENT_*` variables are only needed if you want the AI assistant enabled.

5. **Set up the database**

Create a local PostgreSQL database, then run:
```bash
psql -U postgres -d your_database -f sql/create_tables.sql
psql -U postgres -d your_database -f sql/populate_tables.sql
```

6. **Run the application**
```bash
python3 run.py
```

Visit `http://127.0.0.1:5000`

---

## Tests

```bash
python -m unittest discover -s tests -p 'test_*.py'
```

---

## Role-Based Access — Developer Notes

All protected routes use the `@role_required` decorator from `app/utils.py`:

- Unauthenticated request → redirect to `/login`
- Authenticated but wrong role → HTTP 403
- Authenticated with an allowed role → route handler runs

```python
from app import app
from app.utils import role_required

# Super Admin only
@app.route('/admin/dashboard')
@role_required('Super Admin')
def admin_dashboard(): ...

# Coordinator or Super Admin
@app.route('/coordinator/dashboard')
@role_required('Group Coordinator', 'Super Admin')
def coordinator_dashboard(): ...

# Any logged-in user (no role restriction)
@app.route('/profile')
@role_required()
def profile(): ...
```

Valid role strings: `'Super Admin'`, `'Support Technician'`, `'Group Coordinator'`, `'Operator'`, `'Observer'`.

The active group and role live in the session after login (or group selection) as `session['user_id']`, `session['group_id']`, `session['group_role']`, and `session['group_name']`. Use `get_current_group_role()` from `app/utils.py` to branch on the current role inside handlers or templates.

---

## Deployment (PythonAnywhere)

1. Pull the repository via the PythonAnywhere console or Files tab
2. Point the WSGI configuration file at the app (`from app import app as application`)
3. Create the `.env` file in the project root with production DB credentials and a secure `SECRET_KEY`
4. Reload the web app from the Web tab