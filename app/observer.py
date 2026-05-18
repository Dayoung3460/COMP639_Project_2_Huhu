"""observer.py — Observer dashboard."""

from flask import render_template, session
from app import app, db
from app.utils import role_required, is_super_admin_mode


@app.route('/observer/dashboard')
@role_required()
def observer_dashboard():
    """Observer dashboard — stats for the active group.

    Super Admin in platform-wide mode sees aggregated stats across
    every group; everyone else is scoped to their selected group.
    """
    stats = {
        'total_catches': 0,
        'total_lines':   0,
        'total_traps':   0,
        'top_species':   '—',
    }
    recent_catches = []

    super_admin = is_super_admin_mode()
    group_id = session.get('group_id')
    line_group_clause = '' if super_admin else 'AND l.group_id = %s'
    group_params = () if super_admin else (group_id,)

    try:
        with db.get_cursor() as cursor:

            # Total catches (within active group)
            cursor.execute(f"""
                SELECT COUNT(*) AS cnt
                FROM trap_catches tc
                JOIN traps t ON t.trap_id = tc.trap_id
                JOIN lines l ON l.line_id = t.line_id
                WHERE tc.species_caught != 'None' {line_group_clause}
            """, group_params)
            stats['total_catches'] = cursor.fetchone()['cnt']

            # Active lines
            cursor.execute(f"""
                SELECT COUNT(*) AS cnt FROM lines l
                WHERE l.is_retired = FALSE {line_group_clause}
            """, group_params)
            stats['total_lines'] = cursor.fetchone()['cnt']

            # Active traps
            cursor.execute(f"""
                SELECT COUNT(*) AS cnt
                FROM traps t
                JOIN lines l ON l.line_id = t.line_id
                WHERE t.is_retired = FALSE {line_group_clause}
            """, group_params)
            stats['total_traps'] = cursor.fetchone()['cnt']

            # Top species
            cursor.execute(f"""
                SELECT tc.species_caught, COUNT(*) AS cnt
                FROM trap_catches tc
                JOIN traps t ON t.trap_id = tc.trap_id
                JOIN lines l ON l.line_id = t.line_id
                WHERE tc.species_caught != 'None' {line_group_clause}
                GROUP BY tc.species_caught
                ORDER BY cnt DESC
                LIMIT 1
            """, group_params)
            row = cursor.fetchone()
            if row:
                stats['top_species'] = row['species_caught']

            # Recent catches (last 5)
            cursor.execute(f"""
                SELECT tc.date, tc.species_caught, tc.status,
                       t.code AS trap_code, l.name AS line_name,
                       u.username AS recorded_by
                FROM trap_catches tc
                JOIN traps t ON tc.trap_id = t.trap_id
                JOIN lines l ON t.line_id = l.line_id
                LEFT JOIN users u ON tc.recorded_by_id = u.user_id
                WHERE tc.species_caught != 'None' {line_group_clause}
                ORDER BY tc.date DESC
                LIMIT 5
            """, group_params)
            recent_catches = cursor.fetchall()
 
    except Exception as e:
        app.logger.error(f'Observer dashboard error: {e}')
 
    return render_template('observer/dashboard.html',
                           stats=stats,
                           recent_catches=recent_catches)