from flask import render_template, request, redirect, url_for, flash, session
from app import app, db
from app.utils import role_required, allowed_file, CONSERVATION_BG_FOLDER
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

        # ── Check user has pending applications ─────────────────────────────
        with db.get_cursor() as cursor:
            cursor.execute(
                """
                SELECT COUNT(*) FROM group_applications WHERE user_id = %s AND status = 'pending'
                """,
                (user_id,)
            )
            pending_count = cursor.fetchone()

            print(f"User {user_id} has {pending_count['count']} pending applications.")  # Debug log

            if pending_count['count'] > 0:
                flash('You already have a pending conservation application. Please wait for it to be reviewed before submitting another.', 'warning')
                return redirect(url_for('apply_for_conservation'))

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
        file = request.files.get('group_image_input')
        if file and file.filename:
            if allowed_file(file.filename):
                ext = file.filename.rsplit('.', 1)[1].lower()
                filename = f"conservation_bg_{uuid.uuid4().hex[:10]}.{ext}"
                os.makedirs(CONSERVATION_BG_FOLDER, exist_ok=True)
                file.save(os.path.join(CONSERVATION_BG_FOLDER, filename))
                profile_photo = filename
            else:
                flash('Profile photo must be a PNG, JPG, JPEG, or GIF.', 'danger')
                return redirect(url_for('apply_for_conservation'))

        with db.get_cursor() as cursor:
            if profile_photo:
                insert_query = """
                INSERT INTO group_applications (user_id, proposed_name, description, location, justification, tile_image)
                VALUES (%s, %s, %s, %s, %s, %s)
                """
                tuple_values = (user_id, proposed_name, description, location, justification, profile_photo)
            else:
                insert_query = """
                INSERT INTO group_applications (user_id, proposed_name, description, location, justification)
                VALUES (%s, %s, %s, %s, %s)
                """
                tuple_values = (user_id, proposed_name, description, location, justification)

            cursor.execute(
                insert_query,
                tuple_values
            )
            flash('Your conservation application has been submitted successfully!', 'success')
            
            return redirect(url_for('apply_for_conservation'))

    return render_template('conservation/apply_conservation.html')