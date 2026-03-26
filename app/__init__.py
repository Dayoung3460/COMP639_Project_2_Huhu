"""
__init__.py — Tiaki (Predator Trapping & Monitoring)
COMP639 Group Project 1 — Semester 1, 2026

Application factory: initialises Flask app, bcrypt, database,
route modules, template filters, and global context processors.
"""

from flask import Flask, session, request as flask_request, url_for, render_template
from flask_bcrypt import Bcrypt
from flask_mail import Mail
from datetime import timedelta
import os

def load_env_file(env_path):
    """Load key=value pairs from a .env file into process environment."""
    if not os.path.exists(env_path):
        return

    with open(env_path, 'r', encoding='utf-8') as env_file:
        for raw_line in env_file:
            line = raw_line.strip()
            if not line or line.startswith('#') or '=' not in line:
                continue

            key, value = line.split('=', 1)
            key = key.strip()
            value = value.strip().strip('"').strip("'")
            if key:
                os.environ.setdefault(key, value)

# ── App setup ─────────────────────────────────────────────────────────────────

app = Flask(__name__,
            template_folder='templates',
            static_folder='../static')

load_env_file(os.path.join(app.root_path, '..', '.env'))

bcrypt = Bcrypt(app)
app.secret_key = 'pflu_secret_key_change_in_production'

# ── Database ──────────────────────────────────────────────────────────────────

from app import connect
from app import db

db.init_db(app,
           connect.dbuser,
           connect.dbpass,
           connect.dbhost,
           connect.dbname,
           connect.dbport)

# ── Mail (Gmail SMTP) ─────────────────────────────────────────────────────────

app.config['MAIL_SERVER']         = 'smtp.gmail.com'
app.config['MAIL_PORT']           = 587
app.config['MAIL_USE_TLS']        = True
app.config['MAIL_USERNAME']       = os.environ.get('MAIL_USERNAME', '')
app.config['MAIL_PASSWORD']       = os.environ.get('MAIL_PASSWORD', '')
app.config['MAIL_DEFAULT_SENDER'] = ('Tiaki System',
                                      os.environ.get('MAIL_USERNAME', ''))

mail = Mail(app)

# ── Constants ─────────────────────────────────────────────────────────────────

UPLOAD_FOLDER = os.path.join(app.root_path, '..', 'static', 'images', 'uploads')
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}

# ── Before request ────────────────────────────────────────────────────────────

from app.utils import check_user_status
app.before_request(check_user_status)

# ── After request — prevent browser caching on authenticated pages ────────────

@app.after_request
def set_cache_headers(response):
    """
    Prevents the browser from caching authenticated pages.
    Fixes the back-button issue after logout — cached pages won't be shown.
    Public pages (home, login, register) are allowed to cache normally.
    """
    public_endpoints = {'index', 'login', 'register', 'forgot_password',
                        'reset_password', 'static'}
    if flask_request.endpoint not in public_endpoints:
        response.headers['Cache-Control'] = 'no-store, no-cache, must-revalidate, max-age=0'
        response.headers['Pragma'] = 'no-cache'
        response.headers['Expires'] = '0'
    return response

# ── Route modules ─────────────────────────────────────────────────────────────

from app import home
from app import auth
from app import observer
from app import operator
from app import admin
from app import lines
from app import reports
from app import general

# ── Template globals ──────────────────────────────────────────────────────────

@app.context_processor
def inject_globals():
    """Makes global variables available to all Jinja2 templates."""
    profile_photo = None
    first_name    = None
    last_name     = None
    if session.get('user_id'):
        try:
            with db.get_cursor() as cursor:
                cursor.execute(
                    'SELECT profile_photo, first_name, last_name FROM users WHERE user_id = %s',
                    (session['user_id'],)
                )
                row = cursor.fetchone()
                if row:
                    profile_photo = row['profile_photo']
                    first_name    = row['first_name']
                    last_name     = row['last_name']
        except Exception:
            pass
    return dict(
        site_name='Tiaki',
        site_tagline='Predator Trapping & Monitoring',
        logo_url=url_for('static', filename='images/logo.png'),
        icon_url=url_for('static', filename='images/icon.png'),
        favicon_url=url_for('static', filename='images/favicon.png'),
        nav_profile_photo=profile_photo,
        nav_first_name=first_name,
        nav_full_name=f"{first_name} {last_name}".strip(),
    )

# ── Template filters ──────────────────────────────────────────────────────────

@app.template_filter('nz_date')
def nz_date_filter(date):
    """Formats a date as DD/MM/YYYY (NZ format)."""
    if date:
        return date.strftime('%d/%m/%Y')
    return ''

@app.template_filter('nz_datetime')
def nz_datetime_filter(dt):
    """Formats a datetime as DD/MM/YYYY HH:MM."""
    if dt:
        return dt.strftime('%d/%m/%Y %H:%M')
    return ''

# ── Error handlers ────────────────────────────────────────────────────────────

@app.errorhandler(403)
def forbidden(e):
    return render_template('403.html'), 403

@app.errorhandler(404)
def not_found(e):
    return render_template('404.html'), 404

@app.errorhandler(500)
def server_error(e):
    return render_template('500.html'), 500