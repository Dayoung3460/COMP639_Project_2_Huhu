# PF-LU Predator Control System
### COMP639 Studio Project — Group Project 1 — Semester 1, 2026

[Live URL](https://pflu.pythonanywhere.com/)
A Flask web application for monitoring and reporting predator trap activity across Lincoln University campus.

---

## Setup Instructions

### 1. Clone the repository
```bash
git clone <your-repo-url>
cd COMP639_Project_1_Huhu
```

### 2. Create and activate a virtual environment
```bash
python -m venv venv
source venv/bin/activate        # macOS/Linux
venv\Scripts\activate           # Windows
```

### 3. Install dependencies
```bash
pip install -r requirements.txt
```

### 4. Configure database credentials
Copy `app/connect.py.example` (or create `app/connect.py`) and fill in your local PostgreSQL details:
```python
dbuser = 'postgres'
dbpass = 'your_password'
dbhost = 'localhost'
dbport = 5432
dbname = 'pflu_db'
```
> `connect.py` is listed in `.gitignore` — never commit it.

### 5. Set up the database
```bash
psql -U postgres -d pflu_db -f sql/create_tables.sql
psql -U postgres -d pflu_db -f sql/populate_database.sql
```

### 6. Generate real password hashes
Before running populate_database.sql, replace `$2b$12$REPLACE_WITH_REAL_HASH` with actual bcrypt hashes:
```bash
python -c "from flask_bcrypt import generate_password_hash; print(generate_password_hash('Password1!').decode())"
```

### 7. Run the application
```bash
python run.py
```
Visit: http://127.0.0.1:5000

---

## Test Accounts

| Role     | Username  | Password    |
|----------|-----------|-------------|
| Admin    | admin1    | Password1!  |
| Operator | operator1 | Password1!  |
| Observer | observer1 | Password1!  |

---

## Project Structure

```
pflu/
├── run.py                   ← Entry point
├── requirements.txt
├── .gitignore
├── app/
│   ├── __init__.py          ← App factory, blueprints, filters
│   ├── connect.py           ← DB credentials (not committed)
│   ├── db.py                ← psycopg2 connection helpers
│   ├── utils.py             ← role_required, password validation
│   ├── general.py           ← Routes accessible by multiple roles
│   ├── home.py
│   ├── auth.py
│   ├── observer.py
│   ├── operator.py
│   ├── admin.py
│   ├── lines.py
│   ├── reports.py
│   └── templates/
│       ├── base.html
│       ├── home.html
│       ├── auth/
│       ├── observer/
│       ├── operator/
│       ├── admin/
│       ├── lines/
│       └── reports/
├── static/
│   ├── css/custom.css
│   ├── js/main.js
│   └── images/uploads/
└── sql/
    ├── create_tables.sql
    └── populate_database.sql
```

---

## Tech Stack

- **Backend:** Python 3, Flask
- **Database:** PostgreSQL (psycopg2 — raw SQL, no SQLAlchemy)
- **Frontend:** Bootstrap 5, Bootstrap Icons, Jinja2
- **Auth:** flask-bcrypt
- **Hosting:** PythonAnywhere

---

## Generative AI Usage

| Date | Member | Tool | Purpose | Reviewed? |
|------|--------|------|---------|-----------|
| 15 Mar 2026 | Jeremiah | Claude (Anthropic) | Project brief analysis, user stories, technical stories, folder structure, starter files | Yes |

> All AI-generated content was reviewed and adapted by the team before use.

---

**Group:** HUHU
**Live URL:** [Your PythonAnywhere URL here]
