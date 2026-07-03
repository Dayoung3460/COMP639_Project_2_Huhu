"""Implements simple PostgreSQL database connectivity for a Flask web app.

This approach is based on the "Define and Access the Database" Flask
tutorial [1]. It gives you an easy way to request a database connection or
cursor while processing a Flask request, and gives you access to that
connection from anywhere in your app (including other functions or modules)
until the request is complete.

Usage:
------
When initialising your Flask application, call `init_db` passing in your
`Flask` application object and database connection details:
```
>>> app = Flask(__name__)
>>> db.init_db(app, 'username', 'password', 'host', 'database', port)
```

Then, while handling a Flask request you can get a database connection
specific to that request by calling:
```
>>> db = db.get_db()
>>> # Your database code here...
```

If you need a new cursor, you can call:
```
>>> cursor = db.get_cursor()
>>> # Your database code here...
>>> cursor.close()
```

Alternatively, consider using a `with` block to ensure that the cursor is
automatically closed at the end of your query:
```
>>> with get_cursor() as cursor:
>>>     # Your query here...
```

Note that you don't have to close the database connection returned by
`get_db()` as it will be closed automatically at the end of the Flask request.
However, you should ensure that you close all cursors: this includes any
created by the `get_cursor()` function, and any you create manually using the
database connection.

References:
-----------
    [1] https://flask.palletsprojects.com/en/stable/tutorial/database/
    [2] https://www.digitalocean.com/community/tutorials/how-to-use-a-postgresql-database-in-a-flask-application
"""

from flask import Flask, g
import psycopg2
import psycopg2.extras

# Database connection parameters (set when calling `init_db`).
connection_params = {}


def init_db(app: Flask, user: str, password: str, host: str, database: str,
            port: int = 5432, autocommit: bool = True, sslmode: str = None):
    """Sets up PostgreSQL connectivity for the specified Flask app.

    This must be called once while initialising your Flask web app, before any
    other `db` module functions are called.

    Args:
        app: The `Flask` application to set up database connectivity for.
        user: Username used to connect to the PostgreSQL server.
        password: Password used to connect to the PostgreSQL server.
        host: Host name or IP address of the PostgreSQL server.
        database: Name of the database to connect to on the PostgreSQL server.
        port: Port used to connect to the PostgreSQL server (default `5432`).
        autocommit: Whether or not to enable auto-commit (default `True`).
        sslmode: libpq sslmode, e.g. `'require'` for hosted providers such as
            Neon or Supabase (default `None` — libpq's own default applies).
    """
    connection_params['user'] = user
    connection_params['password'] = password
    connection_params['host'] = host
    connection_params['database'] = database
    connection_params['port'] = port
    connection_params['autocommit'] = autocommit
    connection_params['sslmode'] = sslmode

    app.teardown_appcontext(close_db)


def get_db():
    """Gets a PostgreSQL database connection for the current Flask request.

    The first time you call this during a request, a new connection will be
    created. Additional calls during the same request return the same connection.

    Returns:
        A psycopg2 `Connection` instance.
    """
    if 'db' not in g:
        connect_kwargs = dict(
            user=connection_params['user'],
            password=connection_params['password'],
            host=connection_params['host'],
            dbname=connection_params['database'],
            port=connection_params['port']
        )
        if connection_params.get('sslmode'):
            connect_kwargs['sslmode'] = connection_params['sslmode']
        conn = psycopg2.connect(**connect_kwargs)
        conn.autocommit = connection_params.get('autocommit', True)
        g.db = conn

    return g.db


def get_cursor():
    """Gets a new PostgreSQL RealDictCursor for the current Flask request.

    Rows returned by this cursor are accessible by column name (like a dict).
    Always close cursors when done, or use a `with` block.

    Returns:
        A new `psycopg2.extras.RealDictCursor` instance.
    """
    return get_db().cursor(cursor_factory=psycopg2.extras.RealDictCursor)


def close_db(exception=None):
    """Closes the PostgreSQL database connection for the current Flask request.

    Called automatically at the end of each request via `teardown_appcontext`.

    Args:
        exception: The exception that terminated the request, or None.
    """
    db = g.pop('db', None)

    if db is not None:
        db.close()
