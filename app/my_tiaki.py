"""my_tiaki.py — Cross-group personal home page.

Route:
    GET /my-tiaki

The 'My Tiaki' surface aggregates a logged-in user's activity, groups,
requests, and tasks across every group they belong to. Distinct from
the per-group dashboards under /coordinator, /operator, /observer.

Currently shipped with placeholder content — the schema for posts,
likes, comments, milestones, and scheduled tasks doesn't exist yet,
so the feed and 'Coming up' sections are static for now. The eyebrow
greeting and the 'You' sidebar card use the existing context
processor (nav_first_name / nav_full_name / nav_profile_photo).
"""

from flask import render_template
from app import app
from app.utils import role_required


@app.route('/my-tiaki')
@role_required()
def my_tiaki():
    """Render the cross-group personal home page."""
    return render_template('my_tiaki.html')
