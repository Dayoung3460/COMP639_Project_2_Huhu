"""
utils.py — PF-LU
Shared utilities: role_required decorator, password validation,
file upload helper, role-based redirect, and before_request status check.
"""

from functools import wraps
from flask import session, flash, redirect, url_for, request
import re
import os


# ── Constants ─────────────────────────────────────────────────────────────────

UPLOAD_FOLDER = os.path.join(os.path.dirname(__file__), '..', 'static', 'images', 'uploads')
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}


# ── Decorators ────────────────────────────────────────────────────────────────

def role_required(*roles):
    """
    Decorator to restrict route access by user role.
    Also handles login check in one go.

    Args:
        *roles: Allowed roles. If empty, any logged-in user can access.

    Usage:
        @role_required('Admin')
        @role_required('Admin', 'Operator')
        @role_required()  # any logged-in user
    """
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            if 'user_id' not in session:
                flash('Please log in to access this page.', 'danger')
                return redirect(url_for('auth.login'))
            if roles and session.get('role') not in roles:
                flash('You do not have permission to access that page.', 'danger')
                return redirect(url_for('home.index'))
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


# ── Role-based redirect ───────────────────────────────────────────────────────

def redirect_by_role():
    """
    Redirects the logged-in user to their role-specific dashboard.
    Used after login and other shared actions.

    Returns:
        A Flask redirect response to the appropriate dashboard.
    """
    role = session.get('role')
    if role == 'Admin':
        return redirect(url_for('admin_dashboard'))
    elif role == 'Operator':
        return redirect(url_for('operator_dashboard'))
    else:
        return redirect(url_for('observer_dashboard'))


# ── Before request check ──────────────────────────────────────────────────────

def check_user_status():
    """
    Runs before every request to verify the logged-in user is still active.
    If the account has been deactivated by an Admin, the session is cleared
    and the user is redirected to login immediately.

    Excludes public routes and static files.
    """
    excluded_routes = ['auth.login', 'auth.register', 'home.index', 'static']

    if request.endpoint in excluded_routes:
        return

    if 'user_id' in session:
        from app import db
        with db.get_cursor() as cursor:
            cursor.execute(
                'SELECT is_active FROM "user" WHERE user_id = %s',
                (session['user_id'],)
            )
            user = cursor.fetchone()
            if user and not user['is_active']:
                session.clear()
                flash('Your account has been deactivated. Please contact an administrator.', 'danger')
                return redirect(url_for('auth.login'))
