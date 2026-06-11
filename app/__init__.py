"""
__init__.py — Tiaki (Predator Trapping & Monitoring)
COMP639 Group Project 1 — Semester 1, 2026

Application factory: initialises Flask app, bcrypt, database,
route modules, template filters, and global context processors.
"""

from flask import Flask, session, request as flask_request, url_for, render_template
from flask_bcrypt import Bcrypt
from flask_mail import Mail
from datetime import datetime, timedelta
import os


def _compute_initials(first_name, last_name, username):
    """Two-character initials for the user avatar in the navbar chrome.

    Cascading sources: first_name (+ last_name) → username → '?'.

    Cases verified:
      ('Bo',  None)       → 'BO'      (single word, 2+ chars: first 2)
      ('Bo',  'Kim')      → 'BK'      (two words: first letter of each)
      ('Mary Jane', 'Smith') → 'MS'   (3 words: first letter of first + last)
      ('A',   None)       → 'A'       (single char stays single, CSS centres it)
      (None,  None) + 'admin' → 'AD'  (falls back to username)
      empty all                → '?'
    """
    parts = []
    if first_name and first_name.strip():
        parts.extend(first_name.strip().split())
    if last_name and last_name.strip():
        parts.extend(last_name.strip().split())

    if len(parts) >= 2:
        return (parts[0][0] + parts[-1][0]).upper()
    if len(parts) == 1:
        single = parts[0]
        return single[:2].upper()

    if username and username.strip():
        u = username.strip()
        return u[:2].upper()

    return '?'

def load_env_file(env_path):
    """Load key=value pairs from a .env file into process environment."""
    if not os.path.exists(env_path):
        return

    with open(env_path, 'r', encoding='utf-8-sig') as env_file:
        for raw_line in env_file:
            line = raw_line.strip()
            if not line or line.startswith('#') or '=' not in line:
                continue

            key, value = line.split('=', 1)
            key = key.strip()
            value = value.strip().strip('"').strip("'")
            if key:
                os.environ[key] = value

# ── App setup ─────────────────────────────────────────────────────────────────

app = Flask(__name__,
            template_folder='templates',
            static_folder='../static')

load_env_file(os.path.join(app.root_path, '..', '.env'))

bcrypt = Bcrypt(app)
app.secret_key = os.environ.get('SECRET_KEY', 'pflu_secret_key_change_in_production')

# ── Database ──────────────────────────────────────────────────────────────────

from app import db

db.init_db(app,
           os.environ.get('DB_USER'),
           os.environ.get('DB_PASSWORD'),
           os.environ.get('DB_HOST'),
           os.environ.get('DB_NAME'),
           int(os.environ.get('DB_PORT', 5432)))

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
from app import groups
from app import auth
from app import observer
from app import operator
from app import admin
from app import coordinator
from app import coordinator_export
from app import lines
from app import reports
from app import general
from app import my_tiaki
from app import themes
from app import identity_defaults  # noqa: F401 — registers /identity/default/* routes
from app import helpdesk
from app import updates_hub  # noqa: F401 -- Updates + Knowledge Hub (P2-107)

# ── Template globals ──────────────────────────────────────────────────────────

_ROLE_TO_DASHBOARD = {
    'Super Admin':       'admin_dashboard',
    'Group Coordinator': 'coordinator_dashboard',
    'Operator':          'operator_dashboard',
    # Observer + any other unrecognised role falls through to
    # observer_dashboard via dict.get's default below.
}


@app.context_processor
def inject_globals():
    """Makes global variables available to all Jinja2 templates."""
    profile_photo = None
    first_name    = None
    last_name     = None
    nav_is_public = None
    nav_group_member_count = 0
    nav_notifications = []
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
                if session.get('group_id'):
                    cursor.execute(
                        'SELECT is_public FROM groups WHERE group_id = %s',
                        (session['group_id'],)
                    )
                    g = cursor.fetchone()
                    if g:
                        nav_is_public = g['is_public']
                    # Member count — consumed by the new hero pill. Same
                    # DB round-trip block as nav_is_public so cost is
                    # one extra query per request, not a separate trip.
                    cursor.execute(
                        'SELECT COUNT(*) AS n FROM group_memberships WHERE group_id = %s',
                        (session['group_id'],)
                    )
                    mc = cursor.fetchone()
                    if mc:
                        nav_group_member_count = mc['n']
                
                cursor.execute(
                    '''
                    SELECT notification_id, message, created_at, url
                    FROM user_notifications
                    WHERE user_id = %s AND is_active = TRUE
                      AND (group_id IS NULL OR group_id = %s)
                    ORDER BY created_at DESC
                    LIMIT 20
                    ''',
                    (session['user_id'], session.get('group_id', 0))
                )
                nav_notifications = cursor.fetchall()
        except Exception:
            pass

    # Dashboard URL for the active role — consumed by base.html's brand
    # link so a click on the group brand lands the user on their role
    # dashboard (mirrors redirect_by_role()). Logged-out + missing-role
    # users get '/' so the brand on auth/marketing pages still works.
    if session.get('user_id'):
        endpoint = _ROLE_TO_DASHBOARD.get(
            session.get('group_role'), 'observer_dashboard'
        )
        try:
            nav_dashboard_url = url_for(endpoint)
        except Exception:
            nav_dashboard_url = url_for('index')
    else:
        nav_dashboard_url = url_for('index')

    return dict(
        site_name='Tiaki',
        site_tagline='Conservation Group Management',
        logo_url=url_for('static', filename='images/logo.png'),
        icon_url=url_for('static', filename='images/icon.png'),
        favicon_url=url_for('static', filename='images/favicon.png'),
        nav_profile_photo=profile_photo,
        nav_first_name=first_name,
        nav_full_name=f"{first_name} {last_name}".strip(),
        nav_initials=_compute_initials(
            first_name, last_name, session.get('username')
        ),
        nav_group_name=session.get('group_name', ''),
        nav_group_role=session.get('group_role', ''),
        nav_is_public=nav_is_public,
        nav_notifications=nav_notifications,
        nav_group_member_count=nav_group_member_count,
        nav_dashboard_url=nav_dashboard_url,
        current_year=datetime.now().year,
    )


@app.context_processor
def inject_theme_identity():
    """Custom Themes — surface-scoped theme + identity for every render.

    Exposes four variables so templates pick the right scope:
      - platform_theme    — Tiaki's own brand. Always set.
      - platform_identity — Tiaki's cover/profile. Always set.
      - group_theme       — active group's theme dict, or None.
      - group_identity    — active group's cover/profile, or None.

    Marketing surface (base_marketing.html) renders in platform_theme by
    default; a route that's *about* a specific group (group_landing) can
    pass `override_theme` / `override_identity` to preview that group
    without changing Tiaki's identity globally.

    In-app surface (base.html) renders in `group_theme or platform_theme`
    — the active group's brand inside its own context, Tiaki defaults
    when no group is selected.

    Auth bases inject no <style> block at all, so the var fallbacks in
    the CSS resolve to literal defaults → auth pages stay on Tiaki.
    """
    group_id = session.get('group_id')
    try:
        platform_theme    = themes.get_platform_theme()
        platform_identity = themes.get_platform_identity()
        group_theme       = themes.get_group_theme(group_id)
        group_identity    = themes.get_group_identity(group_id)
    except Exception:
        platform_theme = dict(themes.PLATFORM_DEFAULT_THEME)
        # Generated SVG routes don't need the DB to mint a URL — they
        # only hit the DB when actually fetched. So even when the theme
        # query failed we can still hand templates a working <img src>.
        platform_identity = {
            'cover_photo':   url_for('identity_default_platform_cover'),
            'profile_photo': url_for('identity_default_platform_profile'),
        }
        group_theme    = None
        group_identity = None
    return dict(
        platform_theme=platform_theme,
        platform_identity=platform_identity,
        group_theme=group_theme,
        group_identity=group_identity,
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
    """Formats a datetime as DD Mon YYYY HH:MM."""
    if dt:
        return dt.strftime('%d %b %Y %H:%M')
    return ''

@app.template_filter('contrast_text')
def contrast_text_filter(hex_color):
    """Return '#fff' or '#212529' — whichever reads better on hex_color.

    Picks dark text for light backgrounds and vice versa using the
    W3C relative-luminance threshold, so themed pill badges stay legible.
    """
    fallback = '#fff'
    if not hex_color:
        return fallback
    h = hex_color.lstrip('#')
    if len(h) != 6:
        return fallback
    try:
        r, g, b = (int(h[i:i + 2], 16) for i in (0, 2, 4))
    except ValueError:
        return fallback
    luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255
    return '#212529' if luminance > 0.6 else '#fff'

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
