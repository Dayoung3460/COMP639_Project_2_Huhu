"""home.py — Public home page route."""

from flask import render_template
from app import app


@app.route('/')
def index():
    """Render the public home page."""
    return render_template('home.html')
