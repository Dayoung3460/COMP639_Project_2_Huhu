"""reports.py — Reports and chart data routes (all logged-in roles)."""

from flask import render_template, request, jsonify
from app import app, db
from app.utils import role_required


@app.route('/reports')
@role_required()
def reports():
    """Render the reports page with chart placeholders and summary stats."""
    # TODO: query stats, chart data for species, lines, trend over time
    return render_template('reports/index.html')


@app.route('/reports/data/species')
@role_required()
def reports_data_species():
    """Return JSON data for the catches-by-species chart."""
    # TODO: SELECT species.name, COUNT(*) FROM trap_catch
    #       JOIN species ON trap_catch.species_id = species.species_id
    #       WHERE strikes > 0 GROUP BY species.name
    return jsonify({'labels': [], 'values': []})


@app.route('/reports/data/by-line')
@role_required()
def reports_data_by_line():
    """Return JSON data for the catches-by-line bar chart."""
    # TODO: query catches grouped by line name
    return jsonify({'labels': [], 'values': []})


@app.route('/reports/data/trend')
@role_required()
def reports_data_trend():
    """Return JSON data for the catch trend over time line chart."""
    # TODO: query catches grouped by week or month
    return jsonify({'labels': [], 'values': []})
