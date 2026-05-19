"""auth.py — Register, login, logout, change password, profile."""

from flask import render_template, request, redirect, url_for, flash, session
from app import app, db, bcrypt, mail
from app.utils import is_valid_password, redirect_by_role, allowed_file, UPLOAD_FOLDER
import os
import uuid


def _flash_pending_notifications(user_id):
    """Flash every active notification for the user then mark them inactive."""
    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT notification_id, message, category FROM user_notifications '
            'WHERE user_id = %s AND is_active = TRUE ORDER BY created_at',
            (user_id,)
        )
        notifications = cursor.fetchall()
    if notifications:
        ids = [n['notification_id'] for n in notifications]

        # This makes the Notification bell only work for Group Coordinators.
        # So, the Group Coordinators can see the notifications only when they click the bell icon.
        # Once they click, the notifications will be marked as inactive and won't show up again.
        if session.get('group_role') != 'Group Coordinator':
            with db.get_cursor() as cursor:
                cursor.execute(
                    'UPDATE user_notifications SET is_active = FALSE '
                    'WHERE notification_id = ANY(%s) AND group_id = %s',
                    (ids, session.get('group_id'))
                )
        for n in notifications:
            flash(n['message'], n['category'])


def _is_quick_login_enabled():
    """Return True when test quick-login UI should be shown."""
    return os.environ.get('ENABLE_QUICK_LOGIN', 'false').strip().lower() in {
        '1', 'true', 'yes', 'on'
    }


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
                     account_status)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, 'active')
                RETURNING user_id
            ''', (username, email, password_hash, first_name, last_name,
                  phone or None, address or None,
                  emergency_name or None, emergency_phone or None,
                  profile_photo))
            new_user_id = cursor.fetchone()['user_id']

        # Auto-login the new account and drop them on the picker. They
        # have no memberships yet, so /select-group will show the empty
        # state with "Apply to start a new group".
        session['user_id']  = new_user_id
        session['username'] = username
        flash(f"Welcome to Tiaki, {first_name}!", 'success')
        return redirect(url_for('select_group'))

    return render_template('auth/register.html')


@app.route('/login', methods=['GET', 'POST'])
def login():
    """Log in an existing user and redirect to their role dashboard."""
    quick_login_enabled = _is_quick_login_enabled()

    if request.method == 'POST':
        username = request.form.get('username', '').strip()
        password = request.form.get('password', '')

        with db.get_cursor() as cursor:
            cursor.execute('''
                SELECT user_id, username, password_hash, account_status, is_super_admin, is_support_tech
                FROM users
                WHERE username = %s
            ''', (username,))
            user = cursor.fetchone()

        if not user or not bcrypt.check_password_hash(user['password_hash'], password):
            flash('Incorrect username or password.', 'danger')
            return render_template(
                'auth/login.html',
                username=username,
                quick_login_enabled=quick_login_enabled
            )

        if user['account_status'] != 'active':
            flash('Your account has been deactivated. Please contact an administrator.', 'danger')
            return render_template(
                'auth/login.html',
                username=username,
                quick_login_enabled=quick_login_enabled
            )

        session['user_id']  = user['user_id']
        session['username'] = user['username']

        # Pull the user's active group memberships once; we branch on
        # role-and-count to pick the right post-login destination.
        with db.get_cursor() as cursor:
            cursor.execute('''
                SELECT gm.group_id, gm.role, g.name AS group_name
                FROM group_memberships gm
                JOIN groups g ON gm.group_id = g.group_id
                WHERE gm.user_id = %s AND g.is_active = TRUE
                ORDER BY g.name
            ''', (user['user_id'],))
            memberships = cursor.fetchall()

        # Super Admin with no group context → admin dashboard.
        if user['is_super_admin'] and len(memberships) == 0:
            session['group_role'] = 'Super Admin'
            _flash_pending_notifications(user['user_id'])
            return redirect(url_for('admin_dashboard'))

        # Support Technician with no group memberships → support queue.
        if user['is_support_tech'] and not user['is_super_admin'] and len(memberships) == 0:
            session['group_role'] = 'Support Technician'
            _flash_pending_notifications(user['user_id'])
            return redirect(url_for('helpdesk_queue'))

        # Regular user with exactly one membership → auto-select that
        # group and go straight to the role dashboard. Skips the picker
        # so single-group members don't pay an extra click per login.
        # Super Admins are deliberately excluded so they always land on
        # the picker when they have any group context.
        if not user['is_super_admin'] and len(memberships) == 1:
            m = memberships[0]
            session['group_id']   = m['group_id']
            session['group_role'] = m['role']
            session['group_name'] = m['group_name']
            _flash_pending_notifications(user['user_id'])
            return redirect_by_role()

        # Everyone else (Super Admins with memberships, regular users
        # with 0 or 2+ memberships) → picker. select_group() flashes
        # notifications when the user commits to a group.
        return redirect(url_for('select_group'))

    return render_template('auth/login.html', quick_login_enabled=quick_login_enabled)


@app.route('/select-group', methods=['GET', 'POST'])
def select_group():
    """Group picker — the post-login landing page for any logged-in user.

    Memberships are re-read from the DB on every call so the page is
    reachable any time (typed URL, marketing-nav 'My Tiaki' link), and
    so the list reflects the user's current memberships rather than a
    snapshot stashed at login.
    """
    if 'user_id' not in session:
        return redirect(url_for('login'))

    user_id = session['user_id']

    with db.get_cursor() as cursor:
        cursor.execute('SELECT is_super_admin FROM users WHERE user_id = %s', (user_id,))
        row = cursor.fetchone()
        is_super_admin = bool(row and row['is_super_admin'])

        cursor.execute('''
            SELECT gm.group_id, gm.role, g.name AS group_name, g.location
            FROM group_memberships gm
            JOIN groups g ON gm.group_id = g.group_id
            WHERE gm.user_id = %s AND g.is_active = TRUE
            ORDER BY g.name
        ''', (user_id,))
        memberships = cursor.fetchall()

    if request.method == 'POST':
        # Super Admin "act platform-wide" path — no group context, but all
        # group-scoped list pages will bypass their group_id filter via
        # is_super_admin_mode().
        if is_super_admin and request.form.get('mode') == 'super_admin':
            session.pop('group_id', None)
            session['group_role'] = 'Super Admin'
            session['group_name'] = 'Super Admin'
            _flash_pending_notifications(user_id)
            return redirect_by_role()

        group_id = request.form.get('group_id', type=int)
        match = next((m for m in memberships if m['group_id'] == group_id), None)
        if not match:
            flash('Invalid selection.', 'danger')
            return render_template('auth/select_group.html',
                                   memberships=memberships,
                                   is_super_admin=is_super_admin)

        session['group_id']   = match['group_id']
        session['group_role'] = match['role']
        session['group_name'] = match['group_name']
        _flash_pending_notifications(user_id)
        return redirect_by_role()

    return render_template('auth/select_group.html',
                           memberships=memberships,
                           is_super_admin=is_super_admin)


@app.route('/logout')
def logout():
    """Clear the session and redirect to the home page."""
    if 'user_id' in session:
        with db.get_cursor() as cursor:
            cursor.execute(
                'UPDATE users SET last_login = NOW() WHERE user_id = %s',
                (session['user_id'],)
            )
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

@app.route('/profile')
def profile():
    """View the logged-in user's profile."""
    if 'user_id' not in session:
        return redirect(url_for('login'))

    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT * FROM users WHERE user_id = %s',
            (session['user_id'],)
        )
        user = cursor.fetchone()

    return render_template('auth/profile.html', user=user)

@app.route('/profile/edit', methods=['GET', 'POST'])
def edit_profile():
    """Edit the logged-in user's profile."""
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
        remove_photo    = request.form.get('remove_photo')

        # ── Server-side validation ─────────────────────────────
        if not all([username, first_name, last_name, email]):
            flash('Please fill in all required fields.', 'danger')
            return redirect(url_for('edit_profile'))

        # ── Check username/email not already taken ──────────────
        with db.get_cursor() as cursor:
            cursor.execute('''
                SELECT user_id FROM users
                WHERE (username = %s OR email = %s)
                AND user_id != %s
            ''', (username, email, session['user_id']))
            conflict = cursor.fetchone()

        if conflict:
            with db.get_cursor() as cursor:
                cursor.execute(
                    'SELECT user_id FROM users WHERE username = %s AND user_id != %s',
                    (username, session['user_id'])
                )
                if cursor.fetchone():
                    flash('That username is already taken. Please choose a different one.', 'danger')
                else:
                    flash('That email address is already in use by another account.', 'danger')
            return redirect(url_for('edit_profile'))

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
                return redirect(url_for('edit_profile'))

        # ── Update DB ──────────────────────────────────────────
        with db.get_cursor() as cursor:
            if profile_photo:
                # New photo uploaded
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
            elif remove_photo:
                # Remove photo — set to NULL
                cursor.execute('''
                    UPDATE users
                    SET username = %s, first_name = %s, last_name = %s, email = %s,
                        phone = %s, address = %s,
                        emergency_contact_name = %s, emergency_contact_phone = %s,
                        profile_photo = NULL
                    WHERE user_id = %s
                ''', (username, first_name, last_name, email,
                      phone or None, address or None,
                      emergency_name or None, emergency_phone or None,
                      session['user_id']))
            else:
                # No photo change
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

    return render_template('auth/edit_profile.html', user=user)


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

            # Send password reset email
            reset_url = url_for('reset_password', token=token, _external=True)
            try:
                from flask_mail import Message
                msg = Message(
                    subject='Reset your Tiaki password',
                    recipients=[email]
                )
                msg.html = f'''
                <div style="font-family:Arial,sans-serif;max-width:480px;margin:0 auto;">
                  <div style="background:#1a5c38;padding:24px;border-radius:10px 10px 0 0;text-align:center;">
                    <h2 style="color:#fff;margin:0;font-size:20px;">Tiaki — Password Reset</h2>
                    <p style="color:#a3d4b5;font-size:13px;margin:8px 0 0;">
                      Predator Trapping & Monitoring
                    </p>
                  </div>
                  <div style="background:#fff;padding:28px;border:1px solid #e4ede8;
                              border-top:none;border-radius:0 0 10px 10px;">
                    <p style="color:#1a1f1b;font-size:14px;">Hi,</p>
                    <p style="color:#1a1f1b;font-size:14px;">
                      We received a request to reset your Tiaki password.
                      Click the button below to set a new password.
                      This link expires in <strong>1 hour</strong>.
                    </p>
                    <div style="text-align:center;margin:28px 0;">
                      <a href="{reset_url}"
                         style="background:#236b43;color:#fff;padding:12px 28px;
                                border-radius:8px;text-decoration:none;
                                font-size:14px;font-weight:600;">
                        Reset My Password
                      </a>
                    </div>
                    <p style="color:#6b7c72;font-size:12px;">
                      If you didn't request this, you can safely ignore this email.
                      Your password won't change.
                    </p>
                    <hr style="border:none;border-top:1px solid #e4ede8;margin:20px 0;">
                    <p style="color:#a3b5aa;font-size:11px;text-align:center;">
                      Tiaki — COMP639 Group Project 1, Lincoln University
                    </p>
                  </div>
                </div>
                '''
                mail.send(msg)
                flash('Password reset link sent! Check your email.', 'success')
            except Exception as e:
                app.logger.error(f'Mail send failed: {e}')
                flash('Failed to send reset email. Please try again later.', 'danger')
            return redirect(url_for('forgot_password'))

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


@app.route('/my-requests')
def my_requests():
    """Show the logged-in user's join requests, group applications, and combined history."""
    if 'user_id' not in session:
        return redirect(url_for('login'))

    user_id = session['user_id']

    with db.get_cursor() as cursor:
        # Tab 1 — all join requests for this user
        cursor.execute('''
            SELECT gjr.request_id, g.name AS group_name, gjr.status, gjr.requested_at
            FROM group_join_requests gjr
            JOIN groups g ON gjr.group_id = g.group_id
            WHERE gjr.user_id = %s
            ORDER BY gjr.requested_at DESC
        ''', (user_id,))
        join_requests = cursor.fetchall()

        # Tab 2 — pending group creation applications only
        # (Approved/rejected applications move to the History tab.)
        cursor.execute('''
            SELECT application_id, proposed_name, status, applied_at,
                   decided_at, decision_reason
            FROM group_applications
            WHERE user_id = %s AND status = 'pending'
            ORDER BY applied_at DESC
        ''', (user_id,))
        applications = cursor.fetchall()

        # Tab 3 — approved/rejected entries from both tables, oldest first
        cursor.execute('''
            SELECT 'Join'        AS type,
                   g.name        AS subject,
                   gjr.status,
                   gjr.requested_at AS date,
                   NULL          AS decision_reason
            FROM group_join_requests gjr
            JOIN groups g ON gjr.group_id = g.group_id
            WHERE gjr.user_id = %s AND gjr.status IN ('approved', 'rejected', 'cancelled')

            UNION ALL

            SELECT 'Application'   AS type,
                   ga.proposed_name AS subject,
                   ga.status,
                   ga.applied_at    AS date,
                   ga.decision_reason
            FROM group_applications ga
            WHERE ga.user_id = %s AND ga.status IN ('approved', 'rejected')

            ORDER BY date ASC
        ''', (user_id, user_id))
        history = cursor.fetchall()

    return render_template('auth/my_requests.html',
                           join_requests=join_requests,
                           applications=applications,
                           history=history)


@app.route('/my-requests/cancel/<int:request_id>', methods=['POST'])
def cancel_join_request(request_id):
    """Cancel a pending join request — server-side ownership and status checks."""
    if 'user_id' not in session:
        return redirect(url_for('login'))

    user_id = session['user_id']

    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT status FROM group_join_requests WHERE request_id = %s AND user_id = %s',
            (request_id, user_id)
        )
        req = cursor.fetchone()

    if not req:
        flash('Request not found.', 'warning')
        return redirect(url_for('my_requests'))

    if req['status'] != 'pending':
        flash('Only pending requests can be cancelled.', 'warning')
        return redirect(url_for('my_requests'))

    with db.get_cursor() as cursor:
        cursor.execute(
            'UPDATE group_join_requests SET status = %s WHERE request_id = %s AND user_id = %s AND status = %s',
            ('cancelled', request_id, user_id, 'pending')
        )

    flash('Your join request has been cancelled.', 'success')
    return redirect(url_for('my_requests'))