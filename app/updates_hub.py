"""
updates_hub.py - Group Updates & Shared Knowledge Hub (P2-107)
COMP639 Group Project 2, Team Huhu - Lincoln University

Implements every Jira story under epic P2-107:

GROUP UPDATES
- Coordinator publishes a group update            -> updates_new (action=publish)
- Coordinator saves an update as a draft          -> updates_new (action=draft)
- Coordinator edits or removes an update          -> updates_edit, updates_remove
- Attach photos to an update                      -> _save_photos (multi-file)
- Members view group updates                      -> updates_list, updates_detail
- Members like and comment on updates             -> updates_toggle_like (JSON),
                                                     updates_comment, updates_comments_json
- Coordinator moderates comments                  -> updates_comment_remove

KNOWLEDGE HUB
- Access the Shared Knowledge Hub                 -> hub_index (in-any-group gate)
- Browse and search knowledge entries             -> hub_index (?q=)
- Filter knowledge entries by category            -> hub_index (?category=)
- Feature important knowledge entries             -> hub_toggle_feature
- Member submits a knowledge entry for review     -> hub_submit
- Coordinator reviews and approves or rejects     -> hub_moderation, hub_decision
- Update and version a knowledge entry            -> hub_edit (+ versions table)
"""

import logging
import os
import re
import uuid
from datetime import datetime
from werkzeug.utils import secure_filename

from flask import (
    abort, flash, jsonify, redirect, render_template, request, session, url_for,
)

from app import app, db
from app.utils import role_required, allowed_file, UPLOAD_FOLDER
from app.helpers.dbHelper import insert_notification

logger = logging.getLogger(__name__)

PHOTO_MAX_BYTES = 4 * 1024 * 1024   # 4 MB per file -- AC: "reasonable size limits"


def _save_photos(files):
    """Save uploaded photos, return list of saved filenames + list of errors."""
    saved = []
    errors = []
    if not files:
        return saved, errors
    os.makedirs(UPLOAD_FOLDER, exist_ok=True)
    for f in files:
        if not f or not f.filename:
            continue
        if not allowed_file(f.filename):
            errors.append(f.filename + ': unsupported file type')
            continue
        # Size check (cheap, before save)
        f.stream.seek(0, 2)
        size = f.stream.tell()
        f.stream.seek(0)
        if size > PHOTO_MAX_BYTES:
            errors.append(f.filename + ': exceeds 4 MB limit')
            continue
        ext = f.filename.rsplit('.', 1)[1].lower()
        fname = f'{uuid.uuid4().hex}.{ext}'
        f.save(os.path.join(UPLOAD_FOLDER, fname))
        saved.append(fname)
    return saved, errors


def _user_in_group(user_id, group_id):
    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT 1 FROM group_memberships WHERE user_id = %s AND group_id = %s LIMIT 1',
            (user_id, group_id)
        )
        return cursor.fetchone() is not None


def _user_in_any_group(user_id):
    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT 1 FROM group_memberships WHERE user_id = %s LIMIT 1',
            (user_id,)
        )
        return cursor.fetchone() is not None


# =========================================================================
# GROUP UPDATES
# =========================================================================

@app.route('/updates')
@role_required()
def updates_list():
    group_id = session.get('group_id')
    if not group_id:
        flash(
            'Group updates are scoped to one group at a time. '
            'Pick the group whose updates you want to view.',
            'info'
        )
        return redirect(url_for('select_group'))
    role = session.get('group_role')
    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT u.*, usr.first_name, usr.last_name, usr.username,
                   (SELECT COUNT(*) FROM group_update_likes
                     WHERE update_id = u.update_id) AS like_count,
                   (SELECT COUNT(*) FROM group_update_comments
                     WHERE update_id = u.update_id AND status = 'visible') AS comment_count,
                   EXISTS(SELECT 1 FROM group_update_likes
                           WHERE update_id = u.update_id AND user_id = %s) AS liked_by_me,
                   ARRAY(
                       SELECT photo_path FROM group_update_photos
                        WHERE update_id = u.update_id
                        ORDER BY display_order, photo_id
                        LIMIT 1
                   ) AS thumb
              FROM group_updates u
              LEFT JOIN users usr ON usr.user_id = u.author_id
             WHERE u.group_id = %s
               AND (u.status = 'published'
                    OR (u.status = 'draft' AND %s = 'Group Coordinator'))
             ORDER BY COALESCE(u.published_at, u.created_at) DESC
            """,
            (session['user_id'], group_id, role)
        )
        updates = cursor.fetchall()
    return render_template('updates_hub/updates_list.html',
                           updates=updates,
                           can_post=(role == 'Group Coordinator'))


@app.route('/updates/<int:update_id>')
@role_required()
def updates_detail(update_id):
    group_id = session.get('group_id')
    if not group_id:
        flash(
            'Group updates are scoped to one group at a time. '
            'Pick the group whose updates you want to view.',
            'info'
        )
        return redirect(url_for('select_group'))
    role = session.get('group_role')
    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT u.*, usr.first_name, usr.last_name, usr.username,
                   (SELECT COUNT(*) FROM group_update_likes
                     WHERE update_id = u.update_id) AS like_count,
                   EXISTS(SELECT 1 FROM group_update_likes
                           WHERE update_id = u.update_id AND user_id = %s) AS liked_by_me
              FROM group_updates u
              LEFT JOIN users usr ON usr.user_id = u.author_id
             WHERE u.update_id = %s AND u.group_id = %s
            """,
            (session['user_id'], update_id, group_id)
        )
        update = cursor.fetchone()
        if not update:
            abort(404)
        if update['status'] != 'published' and role != 'Group Coordinator':
            abort(404)
        cursor.execute(
            """
            SELECT photo_path FROM group_update_photos
             WHERE update_id = %s ORDER BY display_order, photo_id
            """,
            (update_id,)
        )
        photos = [r['photo_path'] for r in cursor.fetchall()]
        cursor.execute(
            """
            SELECT c.*, u.first_name, u.last_name, u.username
              FROM group_update_comments c
              LEFT JOIN users u ON u.user_id = c.author_id
             WHERE c.update_id = %s
               AND (c.status = 'visible' OR %s = 'Group Coordinator')
             ORDER BY c.created_at
            """,
            (update_id, role)
        )
        comments = cursor.fetchall()
    return render_template('updates_hub/updates_detail.html',
                           update=update, photos=photos, comments=comments,
                           can_moderate=(role == 'Group Coordinator'))


@app.route('/updates/new', methods=['GET', 'POST'])
@role_required('Group Coordinator')
def updates_new():
    group_id = session['group_id']
    if request.method == 'POST':
        title = (request.form.get('title') or '').strip()
        body  = (request.form.get('body') or '').strip()
        action = (request.form.get('action') or 'draft').lower()
        if not title or not body:
            flash('Title and body are required.', 'danger')
            return render_template('updates_hub/updates_form.html',
                                   update={'title': title, 'body': body}, photos=[])
        photos, errors = _save_photos(request.files.getlist('photos'))
        for e in errors:
            flash(e, 'warning')
        status = 'published' if action == 'publish' else 'draft'
        published_at = datetime.utcnow() if status == 'published' else None
        with db.get_cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO group_updates
                    (group_id, author_id, title, body, status, published_at)
                VALUES (%s,%s,%s,%s,%s,%s)
                RETURNING update_id
                """,
                (group_id, session['user_id'], title, body, status, published_at)
            )
            new_id = cursor.fetchone()['update_id']
            for i, fname in enumerate(photos):
                cursor.execute(
                    """
                    INSERT INTO group_update_photos (update_id, photo_path, display_order)
                    VALUES (%s, %s, %s)
                    """,
                    (new_id, fname, i)
                )
            if status == 'published':
                cursor.execute(
                    """
                    SELECT user_id FROM group_memberships
                     WHERE group_id = %s AND user_id != %s
                    """,
                    (group_id, session['user_id'])
                )
                recipients = [r['user_id'] for r in cursor.fetchall()]
            else:
                recipients = []
        for uid in recipients:
            try:
                insert_notification(
                    db, uid, f'New group update: "{title}"',
                    category='info',
                    url=url_for('updates_detail', update_id=new_id),
                    group_id=group_id,
                )
            except Exception:
                logger.exception('Notify failed')
        flash(f'Update {"published" if status == "published" else "saved as draft"}.', 'success')
        return redirect(url_for('updates_detail', update_id=new_id))
    return render_template('updates_hub/updates_form.html', update=None, photos=[])


@app.route('/updates/<int:update_id>/edit', methods=['GET', 'POST'])
@role_required('Group Coordinator')
def updates_edit(update_id):
    group_id = session['group_id']
    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT * FROM group_updates WHERE update_id = %s AND group_id = %s',
            (update_id, group_id)
        )
        update = cursor.fetchone()
        if not update:
            abort(404)
        cursor.execute(
            """
            SELECT photo_id, photo_path FROM group_update_photos
             WHERE update_id = %s ORDER BY display_order, photo_id
            """,
            (update_id,)
        )
        photos = cursor.fetchall()
    if update['status'] == 'removed':
        abort(404)
    if request.method == 'POST':
        title = (request.form.get('title') or '').strip()
        body  = (request.form.get('body') or '').strip()
        action = (request.form.get('action') or 'save').lower()
        if not title or not body:
            flash('Title and body are required.', 'danger')
            return render_template('updates_hub/updates_form.html',
                                   update={'update_id': update_id, 'title': title, 'body': body},
                                   photos=photos)
        new_photos, errors = _save_photos(request.files.getlist('photos'))
        for e in errors:
            flash(e, 'warning')
        status = update['status']
        published_at = update['published_at']
        if action == 'publish' and status != 'published':
            status = 'published'
            published_at = datetime.utcnow()
        with db.get_cursor() as cursor:
            cursor.execute(
                """
                UPDATE group_updates
                   SET title = %s, body = %s, status = %s, published_at = %s,
                       updated_at = CURRENT_TIMESTAMP
                 WHERE update_id = %s AND group_id = %s
                """,
                (title, body, status, published_at, update_id, group_id)
            )
            # Remove any photos the user ticked the delete checkbox for
            delete_ids = request.form.getlist('delete_photo_id')
            if delete_ids:
                cursor.execute(
                    """
                    DELETE FROM group_update_photos
                     WHERE update_id = %s AND photo_id = ANY(%s::int[])
                    """,
                    (update_id, [int(x) for x in delete_ids])
                )
            # Append the new uploads at the end
            cursor.execute(
                'SELECT COALESCE(MAX(display_order), -1) AS m FROM group_update_photos WHERE update_id = %s',
                (update_id,)
            )
            next_order = (cursor.fetchone()['m'] or -1) + 1
            for i, fname in enumerate(new_photos):
                cursor.execute(
                    """
                    INSERT INTO group_update_photos (update_id, photo_path, display_order)
                    VALUES (%s, %s, %s)
                    """,
                    (update_id, fname, next_order + i)
                )
        flash('Update saved.', 'success')
        return redirect(url_for('updates_detail', update_id=update_id))
    return render_template('updates_hub/updates_form.html', update=update, photos=photos)


@app.route('/updates/<int:update_id>/remove', methods=['POST'])
@role_required('Group Coordinator')
def updates_remove(update_id):
    group_id = session['group_id']
    with db.get_cursor() as cursor:
        cursor.execute(
            """
            UPDATE group_updates
               SET status = 'removed', removed_at = CURRENT_TIMESTAMP
             WHERE update_id = %s AND group_id = %s
            """,
            (update_id, group_id)
        )
    flash('Update removed.', 'success')
    return redirect(url_for('updates_list'))


@app.route('/updates/<int:update_id>/like.json', methods=['POST'])
@role_required()
def updates_toggle_like(update_id):
    """JSON endpoint -- AC: 'like count update without a full page reload'."""
    group_id = session.get('group_id')
    if not group_id:
        return jsonify({'ok': False, 'error': 'no group'}), 400
    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT group_id, status FROM group_updates WHERE update_id = %s',
            (update_id,)
        )
        row = cursor.fetchone()
        if not row or row['group_id'] != group_id or row['status'] != 'published':
            return jsonify({'ok': False}), 404
        cursor.execute(
            'SELECT 1 FROM group_update_likes WHERE update_id = %s AND user_id = %s',
            (update_id, session['user_id'])
        )
        liked = cursor.fetchone() is not None
        if liked:
            cursor.execute(
                'DELETE FROM group_update_likes WHERE update_id = %s AND user_id = %s',
                (update_id, session['user_id'])
            )
            liked = False
        else:
            cursor.execute(
                'INSERT INTO group_update_likes (update_id, user_id) VALUES (%s, %s)',
                (update_id, session['user_id'])
            )
            liked = True
        cursor.execute(
            'SELECT COUNT(*) AS n FROM group_update_likes WHERE update_id = %s',
            (update_id,)
        )
        n = cursor.fetchone()['n']
    return jsonify({'ok': True, 'liked': liked, 'count': int(n)})


@app.route('/updates/<int:update_id>/comments.json')
@role_required()
def updates_comments_json(update_id):
    """JSON list of comments -- AC: 'updates without a full page reload'."""
    group_id = session.get('group_id')
    if not group_id:
        abort(403)
    role = session.get('group_role')
    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT group_id FROM group_updates WHERE update_id = %s',
            (update_id,)
        )
        row = cursor.fetchone()
        if not row or row['group_id'] != group_id:
            abort(404)
        cursor.execute(
            """
            SELECT c.comment_id, c.body, c.status, c.created_at,
                   u.first_name, u.last_name
              FROM group_update_comments c
              LEFT JOIN users u ON u.user_id = c.author_id
             WHERE c.update_id = %s
               AND (c.status = 'visible' OR %s = 'Group Coordinator')
             ORDER BY c.created_at
            """,
            (update_id, role)
        )
        rows = cursor.fetchall()
    return jsonify({
        'comments': [{
            'id':     r['comment_id'],
            'body':   r['body'] if r['status'] == 'visible' else '[Removed by coordinator]',
            'author': (r['first_name'] or '') + ' ' + (r['last_name'] or ''),
            'at':     r['created_at'].isoformat() if r['created_at'] else None,
            'removed': r['status'] != 'visible',
        } for r in rows]
    })


@app.route('/updates/<int:update_id>/comment', methods=['POST'])
@role_required()
def updates_comment(update_id):
    group_id = session.get('group_id')
    if not group_id:
        abort(403)
    body = (request.form.get('body') or '').strip()
    if not body or len(body) > 4000:
        flash('Comment is required (max 4000 characters).', 'danger')
        return redirect(url_for('updates_detail', update_id=update_id))
    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT group_id, status FROM group_updates WHERE update_id = %s',
            (update_id,)
        )
        row = cursor.fetchone()
        if not row or row['group_id'] != group_id or row['status'] != 'published':
            abort(404)
        cursor.execute(
            'INSERT INTO group_update_comments (update_id, author_id, body) VALUES (%s, %s, %s)',
            (update_id, session['user_id'], body)
        )
    flash('Comment posted.', 'success')
    return redirect(url_for('updates_detail', update_id=update_id))


@app.route('/updates/comments/<int:comment_id>/remove', methods=['POST'])
@role_required('Group Coordinator')
def updates_comment_remove(comment_id):
    with db.get_cursor() as cursor:
        cursor.execute(
            """
            UPDATE group_update_comments c
               SET status = 'removed', removed_at = CURRENT_TIMESTAMP, removed_by = %s
              FROM group_updates u
             WHERE c.update_id = u.update_id
               AND c.comment_id = %s
               AND u.group_id = %s
            RETURNING c.update_id
            """,
            (session['user_id'], comment_id, session['group_id'])
        )
        row = cursor.fetchone()
    if not row:
        abort(404)
    flash('Comment removed.', 'success')
    return redirect(url_for('updates_detail', update_id=row['update_id']))


# =========================================================================
# SHARED KNOWLEDGE HUB
# =========================================================================

@app.route('/hub')
@role_required()
def hub_index():
    if not _user_in_any_group(session['user_id']):
        flash('The Knowledge Hub is for members of at least one group.', 'warning')
        return redirect(url_for('select_group'))

    category_slug = (request.args.get('category') or '').strip() or None
    q = (request.args.get('q') or '').strip()

    where = ["a.status = 'published'"]
    params = []
    if category_slug:
        where.append('c.slug = %s'); params.append(category_slug)
    if q:
        where.append('(a.title ILIKE %s OR a.body ILIKE %s OR a.summary ILIKE %s)')
        params.extend([f'%{q}%', f'%{q}%', f'%{q}%'])

    with db.get_cursor() as cursor:
        cursor.execute(
            f"""
            SELECT a.*, c.name AS category_name, c.slug AS category_slug,
                   u.first_name, u.last_name, u.username,
                   g.name AS author_group_name,
                   ARRAY(SELECT photo_path FROM knowledge_article_photos
                          WHERE article_id = a.article_id
                          ORDER BY display_order LIMIT 1) AS thumb
              FROM knowledge_articles a
              JOIN knowledge_categories c ON c.category_id = a.category_id
              LEFT JOIN users u  ON u.user_id  = a.author_id
              LEFT JOIN groups g ON g.group_id = a.author_group_id
             WHERE {' AND '.join(where)}
             ORDER BY a.is_featured DESC, a.published_at DESC NULLS LAST
            """,
            tuple(params)
        )
        articles = cursor.fetchall()
        cursor.execute('SELECT * FROM knowledge_categories ORDER BY display_order, name')
        categories = cursor.fetchall()
        cursor.execute(
            """
            SELECT a.*, c.name AS category_name, c.slug AS category_slug
              FROM knowledge_articles a
              JOIN knowledge_categories c ON c.category_id = a.category_id
             WHERE a.status = 'published' AND a.is_featured = TRUE
             ORDER BY a.published_at DESC NULLS LAST
             LIMIT 6
            """
        )
        featured = cursor.fetchall()

    return render_template(
        'updates_hub/hub_index.html',
        articles=articles, categories=categories, featured=featured,
        selected_category=category_slug, query=q,
        can_moderate=session.get('group_role') in ('Group Coordinator', 'Super Admin'),
    )


@app.route('/hub/article/<int:article_id>')
@role_required()
def hub_article(article_id):
    role = session.get('group_role')
    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT a.*, c.name AS category_name, c.slug AS category_slug,
                   u.first_name, u.last_name, u.username,
                   g.name AS author_group_name
              FROM knowledge_articles a
              JOIN knowledge_categories c ON c.category_id = a.category_id
              LEFT JOIN users u  ON u.user_id  = a.author_id
              LEFT JOIN groups g ON g.group_id = a.author_group_id
             WHERE a.article_id = %s
            """,
            (article_id,)
        )
        article = cursor.fetchone()
        if not article:
            abort(404)
        if article['status'] != 'published' and role not in ('Group Coordinator', 'Super Admin') \
                and article['author_id'] != session['user_id']:
            abort(404)
        cursor.execute(
            """
            SELECT photo_path FROM knowledge_article_photos
             WHERE article_id = %s ORDER BY display_order
            """,
            (article_id,)
        )
        photos = [r['photo_path'] for r in cursor.fetchall()]
        cursor.execute(
            """
            SELECT v.*, u.first_name, u.last_name, u.username
              FROM knowledge_article_versions v
              LEFT JOIN users u ON u.user_id = v.edited_by
             WHERE v.article_id = %s
             ORDER BY v.version_no DESC
            """,
            (article_id,)
        )
        history = cursor.fetchall()
        cursor.execute(
            """
            SELECT m.action, m.note, m.created_at,
                   u.first_name, u.last_name
              FROM knowledge_moderation_log m
              LEFT JOIN users u ON u.user_id = m.actor_id
             WHERE m.article_id = %s
             ORDER BY m.created_at DESC
            """,
            (article_id,)
        )
        mod_log = cursor.fetchall()
    return render_template(
        'updates_hub/hub_article.html',
        article=article, photos=photos, history=history, mod_log=mod_log,
        can_moderate=role in ('Group Coordinator', 'Super Admin'),
        is_author=(article['author_id'] == session['user_id']),
    )


@app.route('/hub/article/<int:article_id>/version/<int:version_no>')
@role_required()
def hub_article_version(article_id, version_no):
    """Read-only view of a historical version of a knowledge article.

    Visibility mirrors hub_article: published articles are visible to
    any logged-in user; drafts/pending are only visible to the author
    or to moderators (Group Coordinator / Super Admin).
    """
    role = session.get('group_role')
    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT a.article_id, a.author_id, a.status, a.current_version,
                   a.category_id, a.created_at,
                   c.name AS category_name, c.slug AS category_slug,
                   g.name AS author_group_name
              FROM knowledge_articles a
              JOIN knowledge_categories c ON c.category_id = a.category_id
              LEFT JOIN groups g ON g.group_id = a.author_group_id
             WHERE a.article_id = %s
            """,
            (article_id,)
        )
        article = cursor.fetchone()
        if not article:
            abort(404)
        if article['status'] != 'published' and role not in ('Group Coordinator', 'Super Admin') \
                and article['author_id'] != session['user_id']:
            abort(404)
        cursor.execute(
            """
            SELECT v.version_id, v.article_id, v.version_no, v.title, v.body,
                   v.summary, v.edited_at, v.note,
                   u.first_name, u.last_name, u.username
              FROM knowledge_article_versions v
              LEFT JOIN users u ON u.user_id = v.edited_by
             WHERE v.article_id = %s AND v.version_no = %s
            """,
            (article_id, version_no)
        )
        version = cursor.fetchone()
        if not version:
            abort(404)
    is_current = (version_no == article['current_version'])
    return render_template(
        'updates_hub/hub_article_version.html',
        article=article, version=version, is_current=is_current,
    )


@app.route('/hub/my-submissions')
@role_required()
def hub_my_submissions():
    """Author-facing list of their submissions with current status."""
    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT a.*, c.name AS category_name
              FROM knowledge_articles a
              JOIN knowledge_categories c ON c.category_id = a.category_id
             WHERE a.author_id = %s
             ORDER BY a.created_at DESC
            """,
            (session['user_id'],)
        )
        articles = cursor.fetchall()
    return render_template('updates_hub/hub_my_submissions.html', articles=articles)


@app.route('/hub/submit', methods=['GET', 'POST'])
@role_required()
def hub_submit():
    with db.get_cursor() as cursor:
        cursor.execute('SELECT * FROM knowledge_categories ORDER BY display_order, name')
        categories = cursor.fetchall()

    if request.method == 'POST':
        title = (request.form.get('title') or '').strip()
        body  = (request.form.get('body') or '').strip()
        summary = (request.form.get('summary') or '').strip() or None
        category_id = request.form.get('category_id', type=int)
        if not title or not body or not category_id:
            flash('Title, body, and category are required.', 'danger')
            return render_template('updates_hub/hub_submit.html',
                                   categories=categories,
                                   draft={'title': title, 'body': body,
                                          'summary': summary, 'category_id': category_id})
        photos, errors = _save_photos(request.files.getlist('photos'))
        for e in errors:
            flash(e, 'warning')
        with db.get_cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO knowledge_articles
                    (category_id, title, body, summary, author_id, author_group_id, status)
                VALUES (%s,%s,%s,%s,%s,%s,'pending_review')
                RETURNING article_id
                """,
                (category_id, title, body, summary,
                 session['user_id'], session.get('group_id'))
            )
            new_id = cursor.fetchone()['article_id']
            for i, fname in enumerate(photos):
                cursor.execute(
                    """
                    INSERT INTO knowledge_article_photos (article_id, photo_path, display_order)
                    VALUES (%s, %s, %s)
                    """,
                    (new_id, fname, i)
                )
            cursor.execute(
                """
                INSERT INTO knowledge_article_versions
                    (article_id, version_no, title, body, summary, edited_by, note)
                VALUES (%s, 1, %s, %s, %s, %s, 'Initial submission')
                """,
                (new_id, title, body, summary, session['user_id'])
            )
            if session.get('group_id'):
                cursor.execute(
                    """
                    SELECT user_id FROM group_memberships
                     WHERE group_id = %s AND role = 'Group Coordinator'
                    """,
                    (session['group_id'],)
                )
                coord_ids = [r['user_id'] for r in cursor.fetchall()]
            else:
                coord_ids = []
        for uid in coord_ids:
            try:
                insert_notification(
                    db, uid,
                    f'Knowledge Hub article awaiting review: "{title}"',
                    category='info',
                    url=url_for('hub_moderation'),
                    group_id=session.get('group_id'),
                )
            except Exception:
                logger.exception('Hub submission notification failed')
        flash('Submitted. Track its status under "My submissions".', 'success')
        return redirect(url_for('hub_my_submissions'))

    return render_template('updates_hub/hub_submit.html',
                           categories=categories, draft=None)


@app.route('/hub/article/<int:article_id>/edit', methods=['GET', 'POST'])
@role_required()
def hub_edit(article_id):
    """Open to coordinator/super-admin OR the original author (per CSV AC).
    Editing creates a new version row."""
    role = session.get('group_role')
    with db.get_cursor() as cursor:
        cursor.execute('SELECT * FROM knowledge_articles WHERE article_id = %s', (article_id,))
        article = cursor.fetchone()
        if not article:
            abort(404)
        if role not in ('Group Coordinator', 'Super Admin') \
                and article['author_id'] != session['user_id']:
            abort(403)
        cursor.execute('SELECT * FROM knowledge_categories ORDER BY display_order, name')
        categories = cursor.fetchall()
        cursor.execute(
            'SELECT photo_id, photo_path FROM knowledge_article_photos WHERE article_id = %s ORDER BY display_order',
            (article_id,)
        )
        photos = cursor.fetchall()

    if request.method == 'POST':
        title = (request.form.get('title') or '').strip()
        body  = (request.form.get('body') or '').strip()
        summary = (request.form.get('summary') or '').strip() or None
        category_id = request.form.get('category_id', type=int) or article['category_id']
        note = (request.form.get('note') or '').strip() or 'Edit'
        if not title or not body:
            flash('Title and body are required.', 'danger')
            return render_template('updates_hub/hub_edit.html',
                                   article=article, categories=categories, photos=photos)
        new_photos, errors = _save_photos(request.files.getlist('photos'))
        for e in errors:
            flash(e, 'warning')
        new_version = article['current_version'] + 1
        with db.get_cursor() as cursor:
            cursor.execute(
                """
                UPDATE knowledge_articles
                   SET title = %s, body = %s, summary = %s, category_id = %s,
                       current_version = %s, updated_at = CURRENT_TIMESTAMP
                 WHERE article_id = %s
                """,
                (title, body, summary, category_id, new_version, article_id)
            )
            cursor.execute(
                """
                INSERT INTO knowledge_article_versions
                    (article_id, version_no, title, body, summary, edited_by, note)
                VALUES (%s,%s,%s,%s,%s,%s,%s)
                """,
                (article_id, new_version, title, body, summary,
                 session['user_id'], note)
            )
            delete_ids = request.form.getlist('delete_photo_id')
            if delete_ids:
                cursor.execute(
                    'DELETE FROM knowledge_article_photos WHERE article_id = %s AND photo_id = ANY(%s::int[])',
                    (article_id, [int(x) for x in delete_ids])
                )
            cursor.execute(
                'SELECT COALESCE(MAX(display_order), -1) AS m FROM knowledge_article_photos WHERE article_id = %s',
                (article_id,)
            )
            next_order = (cursor.fetchone()['m'] or -1) + 1
            for i, fname in enumerate(new_photos):
                cursor.execute(
                    'INSERT INTO knowledge_article_photos (article_id, photo_path, display_order) VALUES (%s,%s,%s)',
                    (article_id, fname, next_order + i)
                )
            cursor.execute(
                """
                INSERT INTO knowledge_moderation_log (article_id, actor_id, action, note)
                VALUES (%s, %s, 'versioned', %s)
                """,
                (article_id, session['user_id'], note)
            )
        flash('Saved. New version recorded.', 'success')
        return redirect(url_for('hub_article', article_id=article_id))
    return render_template('updates_hub/hub_edit.html',
                           article=article, categories=categories, photos=photos)


@app.route('/hub/moderate')
@role_required('Group Coordinator', 'Super Admin')
def hub_moderation():
    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT a.*, c.name AS category_name,
                   u.first_name, u.last_name, u.username,
                   g.name AS author_group_name
              FROM knowledge_articles a
              JOIN knowledge_categories c ON c.category_id = a.category_id
              LEFT JOIN users u  ON u.user_id  = a.author_id
              LEFT JOIN groups g ON g.group_id = a.author_group_id
             WHERE a.status = 'pending_review'
             ORDER BY a.created_at
            """
        )
        pending = cursor.fetchall()
    return render_template('updates_hub/hub_moderation.html', pending=pending)


@app.route('/hub/article/<int:article_id>/decision', methods=['POST'])
@role_required('Group Coordinator', 'Super Admin')
def hub_decision(article_id):
    decision = (request.form.get('decision') or '').lower()
    note = (request.form.get('note') or '').strip() or None
    is_featured = request.form.get('is_featured') == 'on'
    if decision not in ('approve', 'reject'):
        flash('Pick approve or reject.', 'danger')
        return redirect(url_for('hub_moderation'))
    with db.get_cursor() as cursor:
        cursor.execute('SELECT * FROM knowledge_articles WHERE article_id = %s', (article_id,))
        article = cursor.fetchone()
        if not article or article['status'] != 'pending_review':
            abort(404)
        if decision == 'approve':
            cursor.execute(
                """
                UPDATE knowledge_articles
                   SET status = 'published', reviewed_by = %s,
                       reviewed_at = CURRENT_TIMESTAMP, review_note = %s,
                       published_at = CURRENT_TIMESTAMP, is_featured = %s,
                       updated_at = CURRENT_TIMESTAMP
                 WHERE article_id = %s
                """,
                (session['user_id'], note, is_featured, article_id)
            )
            cursor.execute(
                """
                INSERT INTO knowledge_moderation_log (article_id, actor_id, action, note)
                VALUES (%s, %s, 'approved', %s)
                """,
                (article_id, session['user_id'], note)
            )
        else:
            cursor.execute(
                """
                UPDATE knowledge_articles
                   SET status = 'rejected', reviewed_by = %s,
                       reviewed_at = CURRENT_TIMESTAMP, review_note = %s,
                       updated_at = CURRENT_TIMESTAMP
                 WHERE article_id = %s
                """,
                (session['user_id'], note, article_id)
            )
            cursor.execute(
                """
                INSERT INTO knowledge_moderation_log (article_id, actor_id, action, note)
                VALUES (%s, %s, 'rejected', %s)
                """,
                (article_id, session['user_id'], note)
            )
        if article['author_id']:
            try:
                insert_notification(
                    db, article['author_id'],
                    f'Your Knowledge Hub article "{article["title"]}" was {decision}d.',
                    category='success' if decision == 'approve' else 'warning',
                    url=url_for('hub_article', article_id=article_id),
                    group_id=article['author_group_id'],
                )
            except Exception:
                logger.exception('Hub decision notification failed')
    flash(f'Article {decision}d.', 'success')
    return redirect(url_for('hub_moderation'))


@app.route('/hub/article/<int:article_id>/feature', methods=['POST'])
@role_required('Group Coordinator', 'Super Admin')
def hub_toggle_feature(article_id):
    """Toggle the featured flag (AC: 'featuring can be removed')."""
    with db.get_cursor() as cursor:
        cursor.execute(
            """
            UPDATE knowledge_articles
               SET is_featured = NOT is_featured,
                   updated_at = CURRENT_TIMESTAMP
             WHERE article_id = %s AND status = 'published'
            RETURNING is_featured
            """,
            (article_id,)
        )
        row = cursor.fetchone()
        if row is None:
            abort(404)
        action = 'featured' if row['is_featured'] else 'unfeatured'
        cursor.execute(
            'INSERT INTO knowledge_moderation_log (article_id, actor_id, action) VALUES (%s, %s, %s)',
            (article_id, session['user_id'], action)
        )
    flash(f'Article {action}.', 'success')
    return redirect(url_for('hub_article', article_id=article_id))
