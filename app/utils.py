"""
utils.py — Tiaki
Shared utilities: role_required decorator, password validation,
file upload helper, role-based redirect, and before_request status check.
"""

from functools import wraps
from flask import session, flash, redirect, url_for, request, abort
import re
import os


# ── Constants ─────────────────────────────────────────────────────────────────

UPLOAD_FOLDER = os.path.join(os.path.dirname(__file__), '..', 'static', 'images', 'uploads')
CONSERVATION_BG_FOLDER = os.path.join(os.path.dirname(__file__), '..', 'static', 'images', 'uploads', 'conservation-group-bg')
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}
LINCOLN_NZ_LAT_RANGE = (-43.6600, -43.6350)
LINCOLN_NZ_LON_RANGE = (172.4550, 172.4900)
LINCOLN_NZ_CENTER = (
    (LINCOLN_NZ_LAT_RANGE[0] + LINCOLN_NZ_LAT_RANGE[1]) / 2,
    (LINCOLN_NZ_LON_RANGE[0] + LINCOLN_NZ_LON_RANGE[1]) / 2,
)
LINCOLN_NZ_COORDINATES_ERROR = 'Coordinates must be within the allowed Lincoln, New Zealand boundary.'
LINE_COLOURS = [
    '#0d6efd', '#6610f2', '#20c997', '#fd7e14', '#d63384', '#198754', '#6f42c1',
    '#dc3545', '#0dcaf0', '#ffc107', '#6c757d', '#1982c4', '#8ac926', '#ff595e',
    '#ff924c', '#9b5de5', '#2ec4b6', '#e71d36', '#3a86ff', '#8338ec'
]


# ── Decorators ────────────────────────────────────────────────────────────────

def role_required(*roles):
    """
    Decorator to restrict route access by user role.
    Also handles login check in one go.

    Args:
        *roles: Allowed roles. If empty, any logged-in user can access.

    Usage:
        @role_required('Super Admin')
        @role_required('Super Admin', 'Group Coordinator')
        @role_required()  # any logged-in user
    """
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            if 'user_id' not in session:
                flash('Please log in to access this page.', 'danger')
                return redirect(url_for('login'))
            if roles and session.get('group_role') not in roles:
                abort(403)
            return f(*args, **kwargs)
        return decorated_function
    return decorator


# ── Password validation ───────────────────────────────────────────────────────

def is_valid_password(password):
    """
    Validates password meets minimum security requirements.
    Must be at least 8 characters with uppercase, lowercase, and a number.

    Args:
        password (str): The password string to validate.

    Returns:
        bool: True if valid, False otherwise.
    """
    if len(password) < 8:
        return False
    if not re.search(r'[A-Z]', password):
        return False
    if not re.search(r'[a-z]', password):
        return False
    if not re.search(r'\d', password):
        return False
    return True


# ── File upload helper ────────────────────────────────────────────────────────

def allowed_file(filename):
    """
    Checks if an uploaded file has an allowed image extension.

    Args:
        filename (str): The name of the file to check.

    Returns:
        bool: True if the extension is allowed, False otherwise.
    """
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


def validate_lincoln_nz_coordinates(latitude, longitude):
    """
    Validates trap coordinates fall within the supported Lincoln, New Zealand area.

    Args:
        latitude (str | float): Latitude to validate.
        longitude (str | float): Longitude to validate.

    Returns:
        str: Empty string when valid, otherwise an error message.
    """
    try:
        lat = float(latitude)
        lon = float(longitude)
    except (TypeError, ValueError):
        return 'Invalid coordinates. Please ensure Latitude and Longitude are valid numbers.'

    if not (LINCOLN_NZ_LAT_RANGE[0] <= lat <= LINCOLN_NZ_LAT_RANGE[1]):
        return LINCOLN_NZ_COORDINATES_ERROR

    if not (LINCOLN_NZ_LON_RANGE[0] <= lon <= LINCOLN_NZ_LON_RANGE[1]):
        return LINCOLN_NZ_COORDINATES_ERROR

    return ''


# ── Role helpers ─────────────────────────────────────────────────────────────

def get_current_group_role():
    """Returns the active group role from the session, or None if not set."""
    return session.get('group_role')


# ── Role-based redirect ───────────────────────────────────────────────────────

def redirect_by_role():
    """
    Redirects the logged-in user to their role-specific dashboard.
    Used after login and other shared actions.

    Returns:
        A Flask redirect response to the appropriate dashboard.
    """
    role = session.get('group_role')
    if role == 'Super Admin':
        return redirect(url_for('admin_dashboard'))
    elif role == 'Group Coordinator':
        return redirect(url_for('coordinator_dashboard'))
    elif role == 'Operator':
        return redirect(url_for('operator_dashboard'))
    else:
        return redirect(url_for('observer_dashboard'))


# ── Before request check ──────────────────────────────────────────────────────

def check_user_status():
    """
    Runs before every request to verify the logged-in user is still active.
    Also catches stale sessions (user_id present but group_role not yet set).

    Excludes public routes, auth routes, and the group-selector page.
    """
    excluded_routes = {
        'login', 'register', 'index', 'static',
        'select_group', 'logout', 'forgot_password', 'reset_password',
    }

    if request.endpoint in excluded_routes:
        return

    if 'user_id' in session:
        # Stale P1 sessions have user_id but no group_role — send them back to login
        if 'group_role' not in session:
            session.clear()
            flash('Your session has expired. Please log in again.', 'info')
            return redirect(url_for('login'))

        from app import db
        with db.get_cursor() as cursor:
            cursor.execute(
                'SELECT account_status FROM users WHERE user_id = %s',
                (session['user_id'],)
            )
            user = cursor.fetchone()
            if user and user['account_status'] != 'active':
                session.clear()
                flash('Your account has been deactivated. Please contact an administrator.', 'danger')
                return redirect(url_for('login'))

        # If the user has an active group session, verify that group is still active.
        # If the group has been deactivated, strip the group context and redirect them out.
        group_id = session.get('group_id')
        if group_id and request.endpoint not in ('select_group', 'logout'):
            with db.get_cursor() as cursor:
                cursor.execute(
                    'SELECT is_active FROM groups WHERE group_id = %s',
                    (group_id,)
                )
                grp = cursor.fetchone()
            if grp and not grp['is_active']:
                group_name = session.get('group_name', 'your group')
                session.pop('group_id', None)
                session.pop('group_role', None)
                session.pop('group_name', None)
                flash(
                    f'"{group_name}" has been deactivated by an administrator. '
                    'Please select another group or contact support.',
                    'warning'
                )
                return redirect(url_for('select_group'))
