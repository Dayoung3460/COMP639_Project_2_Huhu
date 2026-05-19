"""Database helper functions - reusable database operations."""

def fetch_enum_values(db, enum_type):
    """Fetch all values for a given PostgreSQL ENUM type."""
    with db.get_cursor() as cursor:
        cursor.execute(f"SELECT unnest(enum_range(NULL::{enum_type}))")
        return [row['unnest'] for row in cursor.fetchall()]


def fetch_active_lookup(db, table, include_value=None):
    """Fetch active entries from a lookup table as a flat list of names.
    Optionally include a specific value even if inactive (for edit forms).
    """
    with db.get_cursor() as cursor:
        if include_value:
            cursor.execute(
                f"SELECT name FROM {table} WHERE is_active = TRUE OR name = %s ORDER BY name",
                (include_value,)
            )
        else:
            cursor.execute(f"SELECT name FROM {table} WHERE is_active = TRUE ORDER BY name")
        return [row['name'] for row in cursor.fetchall()]


def fetch_lookup_data(db, include_values=None):
    """Fetch general lookup data (species, statuses, bait types, ENUMs).
    include_values: dict of field-name to current value, ensuring deactivated
    entries still appear when editing existing records.
    """
    include_values = include_values or {}

    with db.get_cursor() as cursor:
        inc = include_values.get('species_caught')
        if inc:
            cursor.execute(
                "SELECT name FROM species WHERE is_active = TRUE OR name = %s ORDER BY name", (inc,))
        else:
            cursor.execute("SELECT name FROM species WHERE is_active = TRUE ORDER BY name")
        species_list = cursor.fetchall()

        inc = include_values.get('status')
        if inc:
            cursor.execute(
                "SELECT name FROM trap_statuses WHERE is_active = TRUE OR name = %s ORDER BY name", (inc,))
        else:
            cursor.execute("SELECT name FROM trap_statuses WHERE is_active = TRUE ORDER BY name")
        status_list = cursor.fetchall()

        inc = include_values.get('bait_type')
        if inc:
            cursor.execute(
                "SELECT name FROM bait_types WHERE is_active = TRUE OR name = %s ORDER BY name", (inc,))
        else:
            cursor.execute("SELECT name FROM bait_types WHERE is_active = TRUE ORDER BY name")
        bait_list = cursor.fetchall()

    valid_conditions = fetch_enum_values(db, 'trap_condition_type')
    valid_rebaited = fetch_enum_values(db, 'rebaited_type')
    valid_sex = fetch_enum_values(db, 'sex_type')
    valid_maturity = fetch_enum_values(db, 'maturity_type')
    valid_account_status = fetch_enum_values(db, 'account_status_type')
    valid_roles = fetch_enum_values(db, 'role_type')
    valid_observation_types = fetch_enum_values(db, 'observation_type_enum')

    return {
        'species_list': species_list,
        'status_list': status_list,
        'bait_list': bait_list,
        'valid_species': [s['name'] for s in species_list],
        'valid_statuses': [s['name'] for s in status_list],
        'valid_baits': [b['name'] for b in bait_list],
        'valid_conditions': valid_conditions,
        'valid_rebaited': valid_rebaited,
        'valid_sex': valid_sex,
        'valid_maturity': valid_maturity,
        'valid_roles': valid_roles,
        'valid_account_status': valid_account_status,
        'valid_observation_types': valid_observation_types
    }

def fetch_operator_trap_ids(db, operator_id, group_id=None):
    """Fetch valid trap IDs for a specific operator (role-based access).

    Pass `group_id` to restrict to the operator's lines within a specific
    group — needed so an Operator who's an Operator in multiple groups
    can only record against their active group's traps.
    """
    sql = """
        SELECT t.trap_id::text
        FROM operator_lines ol
        JOIN lines l ON ol.line_id = l.line_id
        JOIN traps t ON l.line_id = t.line_id
        WHERE ol.operator_id = %s AND l.is_retired = FALSE AND t.is_retired = FALSE
    """
    params = [operator_id]
    if group_id is not None:
        sql += ' AND l.group_id = %s'
        params.append(group_id)
    with db.get_cursor() as cursor:
        cursor.execute(sql, tuple(params))
        return [row['trap_id'] for row in cursor.fetchall()]

def fetch_all_trap_ids(db):
    """Fetch all valid (non-retired) trap IDs (for admin access)."""
    with db.get_cursor() as cursor:
        cursor.execute("""
            SELECT t.trap_id::text
            FROM traps t
            JOIN lines l ON t.line_id = l.line_id
            WHERE l.is_retired = FALSE AND t.is_retired = FALSE
        """)
        return [row['trap_id'] for row in cursor.fetchall()]

def fetch_operator_line_ids(db, operator_id, group_id=None):
    """Fetch valid line IDs for a specific operator (role-based access).

    Pass `group_id` to restrict to the operator's currently active group.
    """
    sql = """
        SELECT l.line_id::text
        FROM operator_lines ol
        JOIN lines l ON ol.line_id = l.line_id
        WHERE ol.operator_id = %s AND l.is_retired = FALSE
    """
    params = [operator_id]
    if group_id is not None:
        sql += ' AND l.group_id = %s'
        params.append(group_id)
    sql += ' ORDER BY l.name'
    with db.get_cursor() as cursor:
        cursor.execute(sql, tuple(params))
        return [row['line_id'] for row in cursor.fetchall()]

def fetch_operator_lines(db, user_id, group_id=None):
    """Fetch lines with traps for the operator's assigned lines.

    Pass `group_id` to restrict to the operator's currently active group.
    """
    sql = """
        SELECT
            l.line_id,
            l.name AS line_name,
            l.type,
            json_agg(
                json_build_object(
                    'trap_id', t.trap_id,
                    'trap_code', t.code,
                    'trap_type', t.trap_type,
                    'latitude', t.latitude,
                    'longitude', t.longitude
                ) ORDER BY t.code
            ) AS traps
        FROM operator_lines ol
        JOIN lines l ON ol.line_id = l.line_id
        JOIN traps t ON l.line_id = t.line_id
        WHERE ol.operator_id = %s AND l.is_retired = FALSE AND t.is_retired = FALSE
    """
    params = [user_id]
    if group_id is not None:
        sql += ' AND l.group_id = %s'
        params.append(group_id)
    sql += ' GROUP BY l.line_id, l.name, l.type ORDER BY l.name'
    with db.get_cursor() as cursor:
        cursor.execute(sql, tuple(params))
        return cursor.fetchall()
    
def fetch_all_lines(db):
    """Fetch all lines with traps (for admin view)."""
    with db.get_cursor() as cursor:
        cursor.execute("""
            SELECT 
                l.line_id, 
                l.name AS line_name, 
                l.type,
                json_agg(
                    json_build_object(
                        'trap_id', t.trap_id,
                        'trap_code', t.code,
                        'trap_type', t.trap_type,
                        'latitude', t.latitude,
                        'longitude', t.longitude
                    ) ORDER BY t.code
                ) AS traps
            FROM lines l
            JOIN traps t ON l.line_id = t.line_id
            WHERE l.is_retired = FALSE AND t.is_retired = FALSE
            GROUP BY l.line_id, l.name, l.type
            ORDER BY l.name
        """)
        return cursor.fetchall()

#validate catch data before call this!
def insert_catch_record(db, data, user_id):
    """Insert a validated catch record into the database."""
    with db.get_cursor() as cursor:
        cursor.execute("""
            INSERT INTO trap_catches (
                trap_id, date, recorded_by_id, species_caught, sex, maturity, 
                status, rebaited, bait_type, bait_details, trap_condition, strikes, notes
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            data['trap_id'],
            data['date'],
            user_id,
            data['species_caught'],
            data.get('sex') or None,
            data.get('maturity') or None,
            data['status'],
            data['rebaited'],
            data['bait_type'],
            data.get('bait_details') or None,
            data['trap_condition'],
            data['strikes'],
            data.get('notes') or None
        ))

#validate catch data before call this!
def update_catch_record(db, data, user_id):
    """Update a validated catch record into the database."""
    with db.get_cursor() as cursor:
        cursor.execute("""
            UPDATE trap_catches
            SET 
                trap_id = %s,
                date = %s,
                species_caught = %s,
                sex = %s,
                maturity = %s,
                status = %s,
                rebaited = %s,
                bait_type = %s,
                bait_details = %s,
                trap_condition = %s,
                strikes = %s,
                notes = %s
            WHERE catch_id = %s AND recorded_by_id = %s
        """, (
            data['trap_id'],
            data['date'],
            data['species_caught'],
            data.get('sex') or None,
            data.get('maturity') or None,
            data['status'],
            data['rebaited'],
            data['bait_type'],
            data.get('bait_details') or None,
            data['trap_condition'],
            data['strikes'],
            data.get('notes') or None,
            data['catch_id'],
            user_id
        ))

def insert_observation(db, data, user_id):
    """Insert an incidental observation into the database."""
    with db.get_cursor() as cursor:
        cursor.execute("""
            INSERT INTO incidental_observations (
                date, operator_id, observation_type, notes, latitude, longitude, line_id, trap_id
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            data['date'],
            user_id,
            data['observation_type'],
            data.get('notes') or None,
            data.get('latitude') or None,
            data.get('longitude') or None,
            data['line_id'],  # Required field
            data.get('trap_id') or None
        ))

def update_user_active(db, user_id, status):
    """Update a user's account status."""
    with db.get_cursor() as cursor:
        cursor.execute("""
            UPDATE users
            SET account_status = %s
            WHERE user_id = %s
        """, (status, user_id))

def fetch_user_info(db, user_id):
    """Fetch user info for permission checks. Role comes from group_memberships."""
    with db.get_cursor() as cursor:
        cursor.execute("""
            SELECT user_id, username, email, first_name, last_name, account_status
            FROM users
            WHERE user_id = %s
        """, (user_id,))
        return cursor.fetchone()

def update_user_role(db, user_id, group_id, role):
    """Update a user's role within a specific group."""
    with db.get_cursor() as cursor:
        cursor.execute("""
            UPDATE group_memberships
            SET role = %s
            WHERE user_id = %s AND group_id = %s
        """, (role, user_id, group_id))

def insert_user_role(db, user_id, group_id, role):
    """Insert a new role for a user within a specific group."""
    with db.get_cursor() as cursor:
        cursor.execute("""
            INSERT INTO group_memberships (user_id, group_id, role)
            VALUES (%s, %s, %s)
        """, (user_id, group_id, role))

def validate_lookup_table_values(db, data):
    """If the value that user selected from dropdown is not in database, return error message. This is to prevent the data inconsistency of database values."""
    with db.get_cursor() as cursor:
        if data.get('species_caught'):
            cursor.execute("SELECT name FROM species WHERE name = %s", (data.get('species_caught'),))
            species_result = cursor.fetchone()
            if not species_result:
                return f"The species '{data.get('species_caught')}' not found in database. Please select a valid species."

        if data.get('bait_type'):
            cursor.execute("SELECT name FROM bait_types WHERE name = %s", (data.get('bait_type'),))
            bait_result = cursor.fetchone()
            if not bait_result:
                return f"The bait type '{data.get('bait_type')}' not found in database. Please select a valid bait type."

        if data.get('status'):
            cursor.execute("SELECT name FROM trap_statuses WHERE name = %s", (data.get('status'),))
            status_result = cursor.fetchone()
            if not status_result:
                return f"The status '{data.get('status')}' not found in database. Please select a valid status."
        
    return False # No lookup errors found

def fetch_operator_bait_station_ids(db, operator_id, group_id):
    """Fetch active bait station IDs on lines assigned to this operator within the group."""
    with db.get_cursor() as cursor:
        cursor.execute("""
            SELECT bs.station_id
            FROM operator_lines ol
            JOIN lines l ON ol.line_id = l.line_id
            JOIN bait_stations bs ON bs.line_id = l.line_id
            WHERE ol.operator_id = %s
              AND l.group_id = %s
              AND l.is_retired = FALSE
              AND l.type = 'Bait Station'
              AND bs.is_retired = FALSE
        """, (operator_id, group_id))
        return {row['station_id'] for row in cursor.fetchall()}


def fetch_operator_bait_lines(db, user_id, group_id):
    """Fetch Bait Station lines with their stations for an operator."""
    with db.get_cursor() as cursor:
        cursor.execute("""
            SELECT l.line_id, l.name AS line_name,
                   json_agg(json_build_object(
                       'station_id', bs.station_id,
                       'code', bs.code,
                       'station_type', bs.station_type
                   ) ORDER BY bs.code) AS stations
            FROM operator_lines ol
            JOIN lines l ON ol.line_id = l.line_id
            JOIN bait_stations bs ON bs.line_id = l.line_id
            WHERE ol.operator_id = %s
              AND l.group_id = %s
              AND l.is_retired = FALSE
              AND l.type = 'Bait Station'
              AND bs.is_retired = FALSE
            GROUP BY l.line_id, l.name
            ORDER BY l.name
        """, (user_id, group_id))
        return cursor.fetchall()


def insert_bait_station_record(db, data, user_id):
    """Insert a validated bait station check record."""
    with db.get_cursor() as cursor:
        cursor.execute("""
            INSERT INTO bait_station_records (
                station_id, date, recorded_by_id, target_species,
                active_ingredient, formulation, concentration,
                bait_remaining, bait_removed, bait_added, notes
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            data['station_id'],
            data['date'],
            user_id,
            data.get('target_species') or None,
            data['active_ingredient'],
            data['formulation'],
            data['concentration'],
            data['bait_remaining'],
            data.get('bait_removed') or None,
            data.get('bait_added') or None,
            data.get('notes') or None,
        ))


def update_bait_station_record(db, data, editor_id):
    """Update an existing bait station record, logging the editor."""
    with db.get_cursor() as cursor:
        cursor.execute("""
            UPDATE bait_station_records
            SET date = %s,
                target_species = %s,
                active_ingredient = %s,
                formulation = %s,
                concentration = %s,
                bait_remaining = %s,
                bait_removed = %s,
                bait_added = %s,
                notes = %s,
                edited_by_id = %s,
                edited_at = CURRENT_TIMESTAMP
            WHERE record_id = %s
        """, (
            data['date'],
            data.get('target_species') or None,
            data['active_ingredient'],
            data['formulation'],
            data['concentration'],
            data['bait_remaining'],
            data.get('bait_removed') or None,
            data.get('bait_added') or None,
            data.get('notes') or None,
            editor_id,
            data['record_id'],
        ))


def insert_notification(db, user_id, message, category='info', url=None, group_id=None):
    """Insert a bell notification for the user.

    Pass group_id to scope to a specific group context; leave None for
    platform-wide notifications (helpdesk staff alerts, admin events).
    """
    with db.get_cursor() as cursor:
        cursor.execute("""
            INSERT INTO user_notifications (user_id, message, category, url, group_id)
            VALUES (%s, %s, %s, %s, %s)
        """, (user_id, message, category, url, group_id))