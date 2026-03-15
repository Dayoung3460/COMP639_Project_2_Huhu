"""run.py — Entry point for the PF-LU Flask application.

Run locally with:
    python run.py

On PythonAnywhere, point the WSGI file to this module.
"""

from app import app

if __name__ == '__main__':
    app.run(debug=True)
