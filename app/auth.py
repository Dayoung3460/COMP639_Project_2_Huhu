"""auth.py — Register, login, logout, change password, profile."""

from flask import render_template, request, redirect, url_for, flash, session
from app import app, db, bcrypt
from app.utils import is_valid_password, redirect_by_role, allowed_file, UPLOAD_FOLDER
import os
import uuid


@app.route('/register', methods=['GET', 'POST'])
def register():
    """Register a new Observer account."""
    if request.method == 'POST':
        username         = request.form.get('username', '').strip()
        email            = request.form.get('email', '').strip()
        password         = request.form.get('password', '')
        confirm_password = request.form.get('confirm_password', '')
        first_name       = request.form.get('first_name', '').strip()
        last_name        = request.form.get('last_name', '').strip()
        phone            = request.form.get('phone', '').strip()
        address          = request.form.get('address', '').strip()
        emergency_name   = request.form.get('emergency_name', '').strip()
        emergency_phone  = request.form.get('emergency_phone', '').strip()

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

        # ── Handle profile photo upload ────────────────────────────
        profile_photo = None
        file = request.files.get('profile_photo')
        if file and file.filename:
            if allowed_file(file.filename):
                ext = file.filename.rsplit('.', 1)[1].lower()
                filename = f"avatar_{uuid.uuid4().hex[:10]}.{ext}"
                os.makedirs(UPLOAD_FOLDER, exist_ok=True)
                file.save(os.path.join(UPLOAD_FOLDER, filename))
                profile_photo = filename
            else:
                flash('Profile photo must be a PNG, JPG, JPEG, or GIF.', 'danger')
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

            cursor.execute('''
                INSERT INTO users
                    (username, email, password_hash, first_name, last_name,
                     phone, address,
                     emergency_contact_name, emergency_contact_phone,
                     profile_photo,
                     role, account_status)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, 'Observer', 'active')
            ''', (username, email, password_hash, first_name, last_name,
                  phone or None, address or None,
                  emergency_name or None, emergency_phone or None,
                  profile_photo))

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
        username        = request.form.get('username', '').strip()
        first_name      = request.form.get('first_name', '').strip()
        last_name       = request.form.get('last_name', '').strip()
        email           = request.form.get('email', '').strip()
        phone           = request.form.get('phone', '').strip()
        address         = request.form.get('address', '').strip()
        emergency_name  = request.form.get('emergency_name', '').strip()
        emergency_phone = request.form.get('emergency_phone', '').strip()

        # ── Server-side validation ─────────────────────────────
        if not all([username, first_name, last_name, email]):
            flash('Please fill in all required fields.', 'danger')
            return redirect(url_for('profile'))

        # ── Check username/email not already taken by another user ──
        with db.get_cursor() as cursor:
            cursor.execute('''
                SELECT user_id FROM users
                WHERE (username = %s OR email = %s)
                AND user_id != %s
            ''', (username, email, session['user_id']))
            conflict = cursor.fetchone()

        if conflict:
            # Find out which one conflicts
            with db.get_cursor() as cursor:
                cursor.execute(
                    'SELECT user_id FROM users WHERE username = %s AND user_id != %s',
                    (username, session['user_id'])
                )
                if cursor.fetchone():
                    flash('That username is already taken. Please choose a different one.', 'danger')
                else:
                    flash('That email address is already in use by another account.', 'danger')
            return redirect(url_for('profile'))

        # ── Handle profile photo upload ────────────────────────
        profile_photo = None
        file = request.files.get('profile_photo')
        if file and file.filename:
            if allowed_file(file.filename):
                ext = file.filename.rsplit('.', 1)[1].lower()
                filename = f"avatar_{uuid.uuid4().hex[:10]}.{ext}"
                os.makedirs(UPLOAD_FOLDER, exist_ok=True)
                file.save(os.path.join(UPLOAD_FOLDER, filename))
                profile_photo = filename
            else:
                flash('Profile photo must be a PNG, JPG, JPEG, or GIF.', 'danger')
                return redirect(url_for('profile'))

        with db.get_cursor() as cursor:
            if profile_photo:
                cursor.execute('''
                    UPDATE users
                    SET username = %s, first_name = %s, last_name = %s, email = %s,
                        phone = %s, address = %s,
                        emergency_contact_name = %s, emergency_contact_phone = %s,
                        profile_photo = %s
                    WHERE user_id = %s
                ''', (username, first_name, last_name, email,
                      phone or None, address or None,
                      emergency_name or None, emergency_phone or None,
                      profile_photo, session['user_id']))
            else:
                cursor.execute('''
                    UPDATE users
                    SET username = %s, first_name = %s, last_name = %s, email = %s,
                        phone = %s, address = %s,
                        emergency_contact_name = %s, emergency_contact_phone = %s
                    WHERE user_id = %s
                ''', (username, first_name, last_name, email,
                      phone or None, address or None,
                      emergency_name or None, emergency_phone or None,
                      session['user_id']))

        # ── Update session username if it changed ──────────────
        session['username'] = username

        flash('Profile updated successfully.', 'success')
        return redirect(url_for('profile'))

    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT * FROM users WHERE user_id = %s',
            (session['user_id'],)
        )
        user = cursor.fetchone()

    return render_template('auth/profile.html', user=user)


@app.route('/forgot-password', methods=['GET', 'POST'])
def forgot_password():
    """
    Step 1 of password reset.
    GET:  Render the forgot password form.
    POST: If email matches a user, generate a token and store it.
          In production this token would be emailed to the user.
          For now we flash the reset link directly (dev only).
    """
    if request.method == 'POST':
        email = request.form.get('email', '').strip()

        with db.get_cursor() as cursor:
            cursor.execute(
                'SELECT user_id FROM users WHERE email = %s AND account_status = %s',
                (email, 'active')
            )
            user = cursor.fetchone()

        if user:
            import secrets
            from datetime import datetime, timedelta

            token = secrets.token_urlsafe(32)
            expires_at = datetime.now() + timedelta(hours=1)

            with db.get_cursor() as cursor:
                # Remove any existing unused tokens for this user
                cursor.execute(
                    'DELETE FROM password_reset_tokens WHERE user_id = %s',
                    (user['user_id'],)
                )
                cursor.execute('''
                    INSERT INTO password_reset_tokens (token, user_id, expires_at)
                    VALUES (%s, %s, %s)
                ''', (token, user['user_id'], expires_at))

            # TODO: Send email to user with reset link
            # In production, replace this with: send_reset_email(email, token)
            # For development — pass the link to the template as a variable
            reset_url = url_for('reset_password', token=token, _external=True)
            return render_template('auth/forgot_password.html', reset_url=reset_url)

        # Always show the same message — don't reveal if email exists
        flash('If that email is registered, a reset link has been sent.', 'success')
        return redirect(url_for('forgot_password'))

    return render_template('auth/forgot_password.html')


@app.route('/reset-password/<token>', methods=['GET', 'POST'])
def reset_password(token):
    """
    Step 2 of password reset.
    GET:  Validate the token and render the new password form.
    POST: Validate the token again, update the password, mark token as used.
    """
    from datetime import datetime

    # Validate token on both GET and POST
    with db.get_cursor() as cursor:
        cursor.execute('''
            SELECT t.token, t.user_id, t.expires_at, t.used
            FROM password_reset_tokens t
            WHERE t.token = %s
        ''', (token,))
        record = cursor.fetchone()

    if not record:
        flash('This reset link is invalid.', 'danger')
        return redirect(url_for('forgot_password'))

    if record['used']:
        flash('This reset link has already been used. Please request a new one.', 'danger')
        return redirect(url_for('forgot_password'))

    if record['expires_at'] < datetime.now():
        flash('This reset link has expired. Please request a new one.', 'danger')
        return redirect(url_for('forgot_password'))

    if request.method == 'POST':
        from app.utils import is_valid_password

        new_password     = request.form.get('new_password', '')
        confirm_password = request.form.get('confirm_password', '')

        if new_password != confirm_password:
            flash('Passwords do not match.', 'danger')
            return render_template('auth/reset_password.html', token=token)

        if not is_valid_password(new_password):
            flash('Password must be at least 8 characters with uppercase, lowercase, and a number.', 'danger')
            return render_template('auth/reset_password.html', token=token)

        new_hash = bcrypt.generate_password_hash(new_password).decode('utf-8')

        with db.get_cursor() as cursor:
            # Update password
            cursor.execute(
                'UPDATE users SET password_hash = %s WHERE user_id = %s',
                (new_hash, record['user_id'])
            )
            # Mark token as used so it can't be reused
            cursor.execute(
                'UPDATE password_reset_tokens SET used = TRUE WHERE token = %s',
                (token,)
            )

        flash('Password updated successfully. Please log in.', 'success')
        return redirect(url_for('login'))

    return render_template('auth/reset_password.html', token=token)