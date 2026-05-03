"""coordinator.py — Group Coordinator dashboard, lines, traps, bait stations, group settings."""

from flask import render_template, request, redirect, url_for, flash, session
from app import app, db
from app.utils import role_required


@app.route('/coordinator/dashboard')
@role_required('Group Coordinator')
def coordinator_dashboard():
    """Group Coordinator dashboard — placeholder."""
    return render_template('coordinator/dashboard.html')
