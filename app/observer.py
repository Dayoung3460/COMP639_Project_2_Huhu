"""observer.py — Observer dashboard."""

from flask import render_template
from app import app, db
from app.utils import role_required


@app.route('/observer/dashboard')
@role_required()
def observer_dashboard():
    """Observer dashboard — system-wide stats and recent activity."""
    stats = {
        'total_catches': 0,
        'total_lines':   0,
        'total_traps':   0,
        'top_species':   '—',
    }
    recent_catches = []
 
    try:
        with db.get_cursor() as cursor:
 
            # Total catches
            cursor.execute("""
                SELECT COUNT(*) AS cnt FROM trap_catches
                WHERE species_caught != 'None'
            """)
            stats['total_catches'] = cursor.fetchone()['cnt']
 
            # Active lines
            cursor.execute("""
                SELECT COUNT(*) AS cnt FROM lines WHERE is_retired = FALSE
            """)
            stats['total_lines'] = cursor.fetchone()['cnt']
 
            # Active traps
            cursor.execute("""
                SELECT COUNT(*) AS cnt FROM traps WHERE is_retired = FALSE
            """)
            stats['total_traps'] = cursor.fetchone()['cnt']
 
            # Top species
            cursor.execute("""
                SELECT species_caught, COUNT(*) AS cnt
                FROM trap_catches
                WHERE species_caught != 'None'
                GROUP BY species_caught
                ORDER BY cnt DESC
                LIMIT 1
            """)
            row = cursor.fetchone()
            if row:
                stats['top_species'] = row['species_caught']
 
            # Recent catches (last 5)
            cursor.execute("""
                SELECT tc.date, tc.species_caught, tc.status,
                       t.code AS trap_code, l.name AS line_name,
                       u.username AS recorded_by
                FROM trap_catches tc
                JOIN traps t ON tc.trap_id = t.trap_id
                JOIN lines l ON t.line_id = l.line_id
                LEFT JOIN users u ON tc.recorded_by_id = u.user_id
                WHERE tc.species_caught != 'None'
                ORDER BY tc.date DESC
                LIMIT 5
            """)
            recent_catches = cursor.fetchall()
 
    except Exception as e:
        app.logger.error(f'Observer dashboard error: {e}')
 
    return render_template('observer/dashboard.html',
                           stats=stats,
                           recent_catches=recent_catches)