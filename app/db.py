"""Implements pooled PostgreSQL database connectivity for a Flask web app.

The request-facing API follows the "Define and Access the Database" Flask
tutorial [1]: call `get_db()` / `get_cursor()` while handling a request and
you get a connection scoped to that request. Under the hood, connections
come from a shared `psycopg2.pool.ThreadedConnectionPool` instead of being
opened fresh each time — against a remote database such as Neon, a new
connection costs a TCP + TLS handshake (tens of ms), so reusing
already-open connections removes that per-request overhead.

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
`get_db()` — it is returned to the pool automatically at the end of the
Flask request. However, you should ensure that you close all cursors: this
includes any created by the `get_cursor()` function, and any you create
manually using the database connection.

References:
-----------
    [1] https://flask.palletsprojects.com/en/stable/tutorial/database/
    [2] https://www.psycopg.org/docs/pool.html
"""

import threading

from flask import Flask, g
import psycopg2
import psycopg2.extras
import psycopg2.pool

# Database connection parameters (set when calling `init_db`).
connection_params = {}

# Shared across all request threads in this process. Created lazily on the
# first `get_db()` call rather than in `init_db`, so importing the app never
# requires a reachable database (tests, scripts), and each gunicorn worker
# builds its own pool after fork instead of inheriting sockets.
_pool = None
_pool_lock = threading.Lock()


def init_db(app: Flask, user: str, password: str, host: str, database: str,
            port: int = 5432, autocommit: bool = True, sslmode: str = None,
            pool_min: int = 2, pool_max: int = 5):
    """Sets up pooled PostgreSQL connectivity for the specified Flask app.

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
        pool_min: Idle connections the pool keeps open for reuse (default 2).
        pool_max: Hard cap on concurrent connections per process (default 5).
    """
    connection_params['user'] = user
    connection_params['password'] = password
    connection_params['host'] = host
    connection_params['database'] = database
    connection_params['port'] = port
    connection_params['autocommit'] = autocommit
    connection_params['sslmode'] = sslmode
    connection_params['pool_min'] = pool_min
    connection_params['pool_max'] = pool_max

    app.teardown_appcontext(close_db)


def _get_pool():
    """Returns the process-wide connection pool, creating it on first use."""
    global _pool
    if _pool is None:
        with _pool_lock:
            if _pool is None:
                connect_kwargs = dict(
                    user=connection_params['user'],
                    password=connection_params['password'],
                    host=connection_params['host'],
                    dbname=connection_params['database'],
                    port=connection_params['port'],
                    # TCP keepalives so idle pooled connections aren't
                    # silently dropped by NATs between the app and the
                    # database server.
                    keepalives=1,
                    keepalives_idle=30,
                    keepalives_interval=10,
                    keepalives_count=3,
                )
                if connection_params.get('sslmode'):
                    connect_kwargs['sslmode'] = connection_params['sslmode']
                _pool = psycopg2.pool.ThreadedConnectionPool(
                    connection_params.get('pool_min', 2),
                    connection_params.get('pool_max', 5),
                    **connect_kwargs)
    return _pool


def _checkout_connection(pool):
    """Borrows a healthy connection from the pool.

    Pooled connections can die while idle — Neon suspends free-tier computes
    after inactivity, closing every server-side session — so each borrowed
    connection is validated with a trivial query and discarded if broken.
    Once the dead idle connections are used up, `getconn` opens a fresh one
    (or raises, exactly as a direct `connect()` would if the DB is down).
    """
    attempts = connection_params.get('pool_min', 2) + 1
    for _ in range(attempts):
        conn = pool.getconn()
        try:
            conn.autocommit = connection_params.get('autocommit', True)
            with conn.cursor() as cursor:
                cursor.execute('SELECT 1')
            return conn
        except psycopg2.Error:
            pool.putconn(conn, close=True)
    raise psycopg2.OperationalError(
        'could not obtain a working database connection from the pool')


def get_db():
    """Gets a PostgreSQL database connection for the current Flask request.

    The first time you call this during a request, a connection is borrowed
    from the pool. Additional calls during the same request return the same
    connection.

    Returns:
        A psycopg2 `Connection` instance.
    """
    if 'db' not in g:
        g.db = _checkout_connection(_get_pool())

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
    """Returns the current request's connection to the pool.

    Called automatically at the end of each request via `teardown_appcontext`.
    `putconn` rolls back any open transaction and discards broken
    connections, so the next borrower always starts from a clean state.

    Args:
        exception: The exception that terminated the request, or None.
    """
    db = g.pop('db', None)

    if db is not None and _pool is not None:
        _pool.putconn(db)
