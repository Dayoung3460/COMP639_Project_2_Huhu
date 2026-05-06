from flask import render_template, request, redirect, url_for, flash, session
from app import app, db
from app.utils import role_required, allowed_file, UPLOAD_FOLDER
import os
import uuid

@app.route('/conservation/apply', methods=['GET', 'POST'])
@role_required('Observer', 'Operator', 'Group Coordinator')
def apply_for_conservation():
    if 'user_id' not in session:
        return redirect(url_for('login'))
    
    if request.method == 'POST':
        user_id = session.get('user_id')
        proposed_name = request.form.get('proposed_name', '').strip()
        description = request.form.get('description', '').strip()
        location = request.form.get('location', '').strip()
        justification = request.form.get('justification', '').strip()

        # ── Server-side validation ─────────────────────────────
        if not all([proposed_name, description, location, justification]):
            flash('Please fill in all required fields.', 'danger')
            return redirect(url_for('apply_for_conservation'))
        
        # ── Check proposed_name not already taken ──────────────
        with db.get_cursor() as cursor:
            cursor.execute(
                """
                SELECT proposed_name FROM group_applications
                WHERE proposed_name = %s
                """,
                (proposed_name,)
            )
            existing_application = cursor.fetchone()

        if existing_application:
            flash(f'A conservation application with this name "{proposed_name}" already exists.', 'danger')
            return redirect(url_for('apply_for_conservation'))
        
        # ── Handle profile photo upload ────────────────────────
        profile_photo = None
        file = request.files.get('profile_photo')
        if file and file.filename:
            if allowed_file(file.filename):
                ext = file.filename.rsplit('.', 1)[1].lower()
                filename = f"conservation_bg_{uuid.uuid4().hex[:10]}.{ext}"
                os.makedirs(UPLOAD_FOLDER, exist_ok=True)
                file.save(os.path.join(UPLOAD_FOLDER, filename))
                profile_photo = filename
            else:
                flash('Profile photo must be a PNG, JPG, JPEG, or GIF.', 'danger')
                return redirect(url_for('apply_for_conservation'))

        with db.get_cursor() as cursor:
            # cursor.execute(
            #     """
            #     INSERT INTO group_applications (user_id, proposed_name, description, location, justification)
            #     VALUES (%s, %s, %s, %s, %s)
            #     """,
            #     (user_id, proposed_name, description, location, justification)
            # )
            cursor.execute(
                """
                INSERT INTO group_applications (user_id, proposed_name)
                VALUES (%s, %s)
                """,
                (user_id, proposed_name)
            )
            
            return redirect(url_for('observer_dashboard'))

    return render_template('conservation/apply_conservation.html')