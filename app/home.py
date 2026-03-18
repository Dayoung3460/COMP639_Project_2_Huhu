"""home.py — Public home page route."""

from flask import render_template
from app import app, db


@app.route('/')
def index():
    """
    Public home page with live stats and recent catch activity from the DB.
    Accessible to everyone — logged-in users see a 'Go to Dashboard' button.
    """
    stats = {'trap_lines': 0, 'active_traps': 0, 'total_catches': 0}
    recent_activity = []

    try:
        with db.get_cursor() as cursor:
            # ── Hero stats ─────────────────────────────────────
            cursor.execute(
                'SELECT COUNT(*) AS count FROM lines WHERE is_retired = FALSE'
            )
            stats['trap_lines'] = cursor.fetchone()['count']

            cursor.execute(
                'SELECT COUNT(*) AS count FROM traps WHERE is_retired = FALSE'
            )
            stats['active_traps'] = cursor.fetchone()['count']

            cursor.execute(
                "SELECT COUNT(*) AS count FROM trap_catches "
                "WHERE species_caught != 'None'"
            )
            stats['total_catches'] = cursor.fetchone()['count']

            # ── Recent catch activity (last 3 records) ─────────
            cursor.execute('''
                SELECT
                    tc.species_caught,
                    tc.status,
                    tc.rebaited,
                    tc.date,
                    t.code  AS trap_code,
                    l.name  AS line_name
                FROM trap_catches tc
                JOIN traps t ON tc.trap_id = t.trap_id
                JOIN lines l ON t.line_id  = l.line_id
                ORDER BY tc.date DESC
                LIMIT 3
            ''')
            recent_activity = cursor.fetchall()

    except Exception:
        pass  # Leave defaults if DB is unavailable

    return render_template('home.html', stats=stats,
                           recent_activity=recent_activity)