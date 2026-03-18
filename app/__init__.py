"""
__init__.py — PF-LU (Predator Free Lincoln University)
COMP639 Group Project 1 — Semester 1, 2026

Application factory: initialises Flask app, bcrypt, database,
route modules, template filters, and global context processors.
"""

from flask import Flask
from flask_bcrypt import Bcrypt
from datetime import timedelta
import os

# ── App setup ─────────────────────────────────────────────────────────────────

app = Flask(__name__,
            template_folder='templates',
            static_folder='../static')

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

# ── Constants ─────────────────────────────────────────────────────────────────

UPLOAD_FOLDER = os.path.join(app.root_path, '..', 'static', 'images', 'uploads')
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}

# ── Before request ────────────────────────────────────────────────────────────

from app.utils import check_user_status
app.before_request(check_user_status)

# ── After request — prevent browser caching on authenticated pages ────────────

from flask import session, request as flask_request

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
    return dict(
        site_name='PF-LU',
        site_tagline='Predator Free Lincoln University'
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

from flask import render_template

@app.errorhandler(403)
def forbidden(e):
    return render_template('403.html'), 403

@app.errorhandler(404)
def not_found(e):
    return render_template('404.html'), 404

@app.errorhandler(500)
def server_error(e):
    return render_template('500.html'), 500