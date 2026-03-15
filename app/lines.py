"""lines.py — Trap lines and traps viewing (all logged-in roles)."""

from flask import render_template, request
from app import app, db
from app.utils import role_required


@app.route('/lines')
@role_required()
def lines_index():
    """Display all active trap lines."""
    # TODO: query all lines with trap count and operator count
    lines = []
    return render_template('lines/index.html', lines=lines)


@app.route('/lines/<int:line_id>')
@role_required()
def line_detail(line_id):
    """Display a single trap line and all its traps."""
    # TODO: query line, traps, assigned operators
    line = None
    traps = []
    operators = []
    return render_template('lines/detail.html',
                           line=line, traps=traps, operators=operators)
