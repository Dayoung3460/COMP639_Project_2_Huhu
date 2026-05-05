"""coordinator.py — Group Coordinator dashboard, lines, traps, bait stations, group settings."""

import logging
from flask import render_template, request, redirect, url_for, flash, session
from app import app, db
from app.utils import role_required

logger = logging.getLogger(__name__)


@app.route('/coordinator/dashboard')
@role_required('Group Coordinator')
def coordinator_dashboard():
    """Group Coordinator dashboard — placeholder."""
    return render_template('coordinator/dashboard.html')


# ── Operator assignment — line selector ──────────────────────────────────────

@app.route('/coordinator/lines/assign')
@role_required('Group Coordinator')
def coordinator_lines_assign():
    """List all active lines in the group so the coordinator can pick one to manage."""
    group_id = session['group_id']
    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT l.*,
                   COUNT(ol.operator_id) AS operator_count,
                   (SELECT COUNT(*) FROM group_memberships
                    WHERE group_id = %s AND role = 'Operator')
                    AS total_operators
            FROM lines l
            LEFT JOIN operator_lines ol ON ol.line_id = l.line_id
            WHERE l.group_id = %s AND l.is_retired = FALSE
            GROUP BY l.line_id
            ORDER BY l.name
            """,
            (group_id, group_id)
        )
        lines = cursor.fetchall()
    return render_template('coordinator/lines_assign.html', lines=lines)


# ── Operator assignment — per-line manage page ───────────────────────────────

@app.route('/coordinator/lines/<int:line_id>/assign')
@role_required('Group Coordinator')
def coordinator_assign_operators(line_id):
    """Show assigned and available operators for one line."""
    group_id = session['group_id']

    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT * FROM lines WHERE line_id = %s AND group_id = %s',
            (line_id, group_id)
        )
        line = cursor.fetchone()

    if not line:
        flash('Line not found in your group.', 'danger')
        return redirect(url_for('coordinator_lines_assign'))

    with db.get_cursor() as cursor:
        cursor.execute(
            """
            SELECT u.*
            FROM users u
            JOIN group_memberships gm ON gm.user_id = u.user_id
            WHERE gm.role = 'Operator' AND gm.group_id = %s
            ORDER BY u.last_name, u.first_name
            """,
            (group_id,)
        )
        all_operators = cursor.fetchall()

        cursor.execute(
            'SELECT * FROM operator_lines WHERE line_id = %s',
            (line_id,)
        )
        assigned_ids = {r['operator_id'] for r in cursor.fetchall()}

    assigned_operators   = [op for op in all_operators if op['user_id'] in assigned_ids]
    unassigned_operators = [op for op in all_operators if op['user_id'] not in assigned_ids]

    return render_template('coordinator/assign_operators.html',
                           line=line,
                           line_id=line_id,
                           assigned_operators=assigned_operators,
                           unassigned_operators=unassigned_operators)


# ── Add one operator to a line ───────────────────────────────────────────────

@app.route('/coordinator/lines/<int:line_id>/assign/add', methods=['POST'])
@role_required('Group Coordinator')
def coordinator_operator_add(line_id):
    """Assign a single operator to a line."""
    group_id    = session['group_id']
    operator_id = request.form.get('operator_id', type=int)

    if not operator_id:
        flash('Invalid operator.', 'danger')
        return redirect(url_for('coordinator_assign_operators', line_id=line_id))

    with db.get_cursor() as cursor:
        # Verify line belongs to this group
        cursor.execute(
            'SELECT line_id FROM lines WHERE line_id = %s AND group_id = %s',
            (line_id, group_id)
        )
        if not cursor.fetchone():
            flash('Line not found in your group.', 'danger')
            return redirect(url_for('coordinator_lines_assign'))

        # Verify operator is an Operator in this group
        cursor.execute(
            """
            SELECT 1 FROM group_memberships
            WHERE user_id = %s AND group_id = %s AND role = 'Operator'
            """,
            (operator_id, group_id)
        )
        if not cursor.fetchone():
            flash('That user is not an Operator in your group.', 'danger')
            return redirect(url_for('coordinator_assign_operators', line_id=line_id))

        cursor.execute(
            'INSERT INTO operator_lines (operator_id, line_id) VALUES (%s, %s) ON CONFLICT DO NOTHING',
            (operator_id, line_id)
        )

    logger.info('Coordinator %s added operator %s to line %d',
                session['user_id'], operator_id, line_id)
    flash('Operator added.', 'success')
    return redirect(url_for('coordinator_assign_operators', line_id=line_id))


# ── Remove one operator from a line ─────────────────────────────────────────

@app.route('/coordinator/lines/<int:line_id>/assign/remove', methods=['POST'])
@role_required('Group Coordinator')
def coordinator_operator_remove(line_id):
    """Remove a single operator from a line."""
    group_id    = session['group_id']
    operator_id = request.form.get('operator_id', type=int)

    if not operator_id:
        flash('Invalid operator.', 'danger')
        return redirect(url_for('coordinator_assign_operators', line_id=line_id))

    with db.get_cursor() as cursor:
        cursor.execute(
            'SELECT line_id FROM lines WHERE line_id = %s AND group_id = %s',
            (line_id, group_id)
        )
        if not cursor.fetchone():
            flash('Line not found in your group.', 'danger')
            return redirect(url_for('coordinator_lines_assign'))

        cursor.execute(
            'DELETE FROM operator_lines WHERE operator_id = %s AND line_id = %s',
            (operator_id, line_id)
        )

    logger.info('Coordinator %s removed operator %s from line %d',
                session['user_id'], operator_id, line_id)
    flash('Operator removed.', 'success')
    return redirect(url_for('coordinator_assign_operators', line_id=line_id))
