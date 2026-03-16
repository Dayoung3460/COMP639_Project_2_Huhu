"""observer.py — Observer dashboard, catch records view, CSV download."""

from flask import render_template, request, send_file
from app import app, db
from app.utils import role_required
import io, csv


@app.route('/observer/dashboard')
@role_required()
def observer_dashboard():
    """Observer dashboard — summary stats and recent activity."""
    # TODO: query stats and recent records
    return render_template('observer/dashboard.html')

@app.route('/observations')
@role_required()
def observations():
    """View all incidental observations."""
    # TODO: query all observations
    observations = []
    return render_template('observer/observations.html', observations=observations)


@app.route('/download-csv')
@role_required()
def download_csv():
    """Download all catch records as a trap.nz-compatible CSV file."""
    # TODO: query all catch records with all required fields
    output = io.StringIO()
    writer = csv.writer(output)
    writer.writerow([
        'code', 'date', 'recorded by', 'species caught', 'sex', 'maturity',
        'status', 'rebaited', 'bait type', 'trap condition', 'strikes', 'notes'
    ])
    # TODO: write data rows
    output.seek(0)
    return send_file(
        io.BytesIO(output.getvalue().encode('utf-8')),
        mimetype='text/csv',
        as_attachment=True,
        download_name='pflu_catch_records.csv'
    )
