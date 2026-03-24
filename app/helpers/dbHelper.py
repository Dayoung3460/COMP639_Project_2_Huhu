"""Database helper functions - reusable database operations."""

def fetch_enum_values(db, enum_type):
    """Fetch all values for a given PostgreSQL ENUM type."""
    with db.get_cursor() as cursor:
        cursor.execute(f"SELECT unnest(enum_range(NULL::{enum_type}))")
        return [row['unnest'] for row in cursor.fetchall()]

def fetch_lookup_data(db):
    """Fetch general lookup data (species, statuses, bait types, ENUMs). No user context needed."""
    with db.get_cursor() as cursor:
        cursor.execute("SELECT name FROM species ORDER BY name")
        species_list = cursor.fetchall()
        
        cursor.execute("SELECT name FROM trap_statuses ORDER BY name")
        status_list = cursor.fetchall()
        
        cursor.execute("SELECT name FROM bait_types ORDER BY name")
        bait_list = cursor.fetchall()
    
    # Fetch ENUM values from database
    valid_conditions = fetch_enum_values(db, 'trap_condition_type')
    valid_rebaited = fetch_enum_values(db, 'rebaited_type')
    valid_sex = fetch_enum_values(db, 'sex_type')
    valid_maturity = fetch_enum_values(db, 'maturity_type')
    valid_account_status = fetch_enum_values(db, 'account_status_type')
    valid_roles = fetch_enum_values(db, 'role_type')
    valid_observation_types = fetch_enum_values(db, 'observation_type_enum')
    valid_roles = fetch_enum_values(db, 'role_type')
        
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
        'valid_roles': valid_roles,
        'valid_observation_types': valid_observation_types
    }

def fetch_operator_trap_ids(db, operator_id):
    """Fetch valid trap IDs for a specific operator (role-based access)."""
    with db.get_cursor() as cursor:
        cursor.execute("""
            SELECT t.trap_id::text
            FROM operator_lines ol
            JOIN lines l ON ol.line_id = l.line_id
            JOIN traps t ON l.line_id = t.line_id
            WHERE ol.operator_id = %s AND l.is_retired = FALSE AND t.is_retired = FALSE
        """, (operator_id,))
        return [row['trap_id'] for row in cursor.fetchall()]

def fetch_operator_line_ids(db, operator_id):
    """Fetch valid line IDs for a specific operator (role-based access)."""
    with db.get_cursor() as cursor:
        cursor.execute("""
            SELECT l.line_id::text
            FROM operator_lines ol
            JOIN lines l ON ol.line_id = l.line_id
            WHERE ol.operator_id = %s AND l.is_retired = FALSE
            ORDER BY l.name
        """, (operator_id,))
        return [row['line_id'] for row in cursor.fetchall()]

def fetch_operator_lines(db, user_id):
    """Fetch lines with traps for the operator's assigned lines."""
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
            FROM operator_lines ol
            JOIN lines l ON ol.line_id = l.line_id
            JOIN traps t ON l.line_id = t.line_id
            WHERE ol.operator_id = %s AND l.is_retired = FALSE AND t.is_retired = FALSE
            GROUP BY l.line_id, l.name, l.type
            ORDER BY l.name
        """, (user_id,))
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
    """Fetch user info including role for permission checks."""
    with db.get_cursor() as cursor:
        cursor.execute("""
            SELECT user_id, username, email, first_name, last_name, role, account_status
            FROM users
            WHERE user_id = %s
        """, (user_id,))
        return cursor.fetchone()

def update_user_role(db, user_id, role):
    """Update a user's role."""
    with db.get_cursor() as cursor:
        cursor.execute("""
            UPDATE users
            SET role = %s
            WHERE user_id = %s
        """, (status, user_id))