"""home.py — Public home page route."""

from flask import render_template
from app import app, db


@app.route('/')
def index():
    """
    Public home page with live stats from the DB.
    Accessible to everyone — logged-in users see a 'Go to Dashboard' button.
    """
    stats = {'trap_lines': 0, 'active_traps': 0, 'total_catches': 0}
    try:
        with db.get_cursor() as cursor:
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
    except Exception:
        pass

    return render_template('home.html', stats=stats)