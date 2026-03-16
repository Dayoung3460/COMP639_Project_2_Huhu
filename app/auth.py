"""auth.py — Register, login, logout, change password, profile."""

from flask import render_template, request, redirect, url_for, flash, session
from app import app, db, bcrypt
from app.utils import is_valid_password, redirect_by_role


@app.route('/register', methods=['GET', 'POST'])
def register():
    """Register a new Observer account."""
    if request.method == 'POST':
        username          = request.form.get('username', '').strip()
        email             = request.form.get('email', '').strip()
        password          = request.form.get('password', '')
        confirm_password  = request.form.get('confirm_password', '')
        first_name        = request.form.get('first_name', '').strip()
        last_name         = request.form.get('last_name', '').strip()
        contact_info      = request.form.get('contact_info', '').strip()
        emergency_name    = request.form.get('emergency_name', '').strip()
        emergency_phone   = request.form.get('emergency_phone', '').strip()
        emergency_contact = f"{emergency_name} — {emergency_phone}" if emergency_name else ''

        # Validation
        if not all([username, email, password, confirm_password, first_name, last_name]):
            flash('Please fill in all required fields.', 'danger')
            return render_template('auth/register.html')

        if password != confirm_password:
            flash('Passwords do not match.', 'danger')
            return render_template('auth/register.html')

        if not is_valid_password(password):
            flash('Password must be at least 8 characters with uppercase, lowercase, and a number.', 'danger')
            return render_template('auth/register.html')

        with db.get_cursor() as cursor:
            # Check username/email not already taken
            cursor.execute(
                'SELECT user_id FROM users WHERE username = %s OR email = %s',
                (username, email)
            )
            if cursor.fetchone():
                flash('Username or email is already in use.', 'danger')
                return render_template('auth/register.html')

            password_hash = bcrypt.generate_password_hash(password).decode('utf-8')

            # role and account_status are ENUMs — insert value directly, no lookup table
            cursor.execute('''
                INSERT INTO users
                    (username, email, password_hash, first_name, last_name,
                     contact_information, emergency_contact_information,
                     role, account_status)
                VALUES (%s, %s, %s, %s, %s, %s, %s, 'Observer', 'active')
            ''', (username, email, password_hash, first_name, last_name,
                  contact_info, emergency_contact))

        flash('Account created successfully! Please log in.', 'success')
        return redirect(url_for('login'))

    return render_template('auth/register.html')


@app.route('/login', methods=['GET', 'POST'])
def login():
    """Log in an existing user and redirect to their role dashboard."""
    if request.method == 'POST':
        username = request.form.get('username', '').strip()
        password = request.form.get('password', '')

        with db.get_cursor() as cursor:
            # role is an ENUM directly on users — no JOIN to a role table needed
            cursor.execute('''
                SELECT user_id, username, password_hash,
                       account_status, role
                FROM users
                WHERE username = %s
            ''', (username,))
            user = cursor.fetchone()

        if not user or not bcrypt.check_password_hash(user['password_hash'], password):
            flash('Incorrect username or password.', 'danger')
            return render_template('auth/login.html', username=username)

        if user['account_status'] != 'active':
            flash('Your account has been deactivated. Please contact an administrator.', 'danger')
            return render_template('auth/login.html', username=username)

        session['user_id']  = user['user_id']
        session['username'] = user['username']
        session['role']     = user['role']

        flash(f"Welcome back, {user['username']}!", 'success')
        return redirect_by_role()

    return render_template('auth/login.html')


@app.route('/logout')
def logout():
    """Clear the session and redirect to the home page."""
    session.clear()
    flash('You have been logged out.', 'info')
    return redirect(url_for('index'))


@app.route('/change-password', methods=['GET', 'POST'])
def change_password():
    """Allow a logged-in user to change their password."""
    if 'user_id' not in session:
        return redirect(url_for('login'))

    if request.method == 'POST':
        current_password = request.form.get('current_password', '')
        new_password     = request.form.get('new_password', '')
        confirm_password = request.form.get('confirm_password', '')

        with db.get_cursor() as cursor:
            cursor.execute(
                'SELECT password_hash FROM users WHERE user_id = %s',
                (session['user_id'],)
            )
            user = cursor.fetchone()

        if not bcrypt.check_password_hash(user['password_hash'], current_password):
            flash('Current password is incorrect.', 'danger')
            return render_template('auth/change_password.html')

        if new_password == current_password:
            flash('New password must be different from your current password.', 'danger')
            return render_template('auth/change_password.html')

        if new_password != confirm_password:
            flash('New passwords do not match.', 'danger')
            return render_template('auth/change_password.html')

        if not is_valid_password(new_password):
            flash('Password must be at least 8 characters with uppercase, lowercase, and a number.', 'danger')
            return render_template('auth/change_password.html')

        new_hash = bcrypt.generate_password_hash(new_password).decode('utf-8')
        with db.get_cursor() as cursor:
            cursor.execute(
                'UPDATE users SET password_hash = %s WHERE user_id = %s',
                (new_hash, session['user_id'])
            )

        flash('Password updated successfully.', 'success')
        return redirect(url_for('profile'))

    return render_template('auth/change_password.html')


@app.route('/profile', methods=['GET', 'POST'])
def profile():
    """View and update the logged-in user's profile."""
    if 'user_id' not in session:
        return redirect(url_for('login'))

    if request.method == 'POST':
        first_name        = request.form.get('first_name', '').strip()
        last_name         = request.form.get('last_name', '').strip()
        email             = request.form.get('email', '').strip()
        contact_info      = request.form.get('contact_info', '').strip()
        emergency_name    = request.form.get('emergency_name', '').strip()
        emergency_phone   = request.form.get('emergency_phone', '').strip()
        emergency_contact = f"{emergency_name} — {emergency_phone}" if emergency_name else ''

        with db.get_cursor() as cursor:
            cursor.execute('''
                UPDATE users
                SET first_name = %s,
                    last_name = %s,
                    email = %s,
                    contact_information = %s,
                    emergency_contact_information = %s
                WHERE user_id = %s
            ''', (first_name, last_name, email, contact_info,
                  emergency_contact, session['user_id']))

        flash('Profile updated successfully.', 'success')
        return redirect(url_for('profile'))

    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT * FROM users WHERE user_id = %s',
            (session['user_id'],)
        )
        user = cursor.fetchone()

    return render_template('auth/profile.html', user=user)