# Tiaki — Predator Trapping & Monitoring

A web application for Predator Free Lincoln University (PF-LU), a fictional volunteer group running a predator-control initiative across the Lincoln University campus.

Built as part of **COMP639 Group Project 1, Semester 1, 2026** by Team Huhu at Lincoln University, New Zealand.

**Live URL:** http://pflu.pythonanywhere.com

---

## The Team

| Name | GitHub |
|---|---|
| Ben Fitzgerald | @Ben-Fitzgerald |
| Da-young Kim | @Da-young-Kim |
| Ming-Cheng Hsiao | @Ming-Cheng-Hsiao |
| Ziyuan Sun | @ziyuansun |
| Jeremiah Ruanes | @jeremiahruanes |

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
- View trap lines and traps on an interactive map
- Browse and filter catch records and incidental observations
- View reports and charts with filters by line, operator, and date range
- Download catch records as CSV

**Operator** (field worker)
- Add and edit catch records for assigned trap lines
- Record incidental observations
- View assigned lines with map

**Admin** (system administrator)
- Manage users — create, assign roles, activate/deactivate
- Create and manage trap lines and traps
- Assign operators to lines
- Manage lookup data — species, trap statuses, bait types
- Retire lines and traps

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
    ├── connect.py                  # DB connection config
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

6. **Update `app/connect.py`** with your local DB connection details.

7. **Run the application**
```bash
python3 run.py
```

Visit `http://127.0.0.1:5000`

---

## PythonAnywhere Deployment

1. Upload all project files via the PythonAnywhere Files tab or GitHub pull
2. Set the WSGI file to point to `run.py`
3. Add `lincolnmac` as a teacher via the site configuration
4. Configure the `.env` file on PythonAnywhere with production DB credentials
5. Reload the web app

---

## GenAI Acknowledgement

Claude (Anthropic) was used during development to accelerate specific tasks:

- **Complex SQL queries** — multi-join queries for reports and dashboards. Schema and requirements were provided; Claude assisted with syntax.
- **Repetitive boilerplate** — similar route structures and template patterns across multiple files.
- **Sample data generation** — generating realistic NZ-context population data for `populate_database.sql`.
- **Debugging** — identifying errors in Flask routes and Jinja2 templates.

All architecture decisions, CSS design, application logic, and feature design were made independently by the team. Claude was used as a development aid — not to generate complete features.