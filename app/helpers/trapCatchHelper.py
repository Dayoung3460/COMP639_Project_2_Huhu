from datetime import datetime
from app.helpers.dbHelper import fetch_lookup_data, fetch_operator_trap_ids, fetch_operator_line_ids

################# validate catch data #################
def validate_trap_id(trap_id, valid_trap_ids):
    if not trap_id:
        return "Trap is required."
    if trap_id not in valid_trap_ids:
        return "Invalid trap selected or you do not have permission for this trap."
    return ""

def validate_date(date_str):
    if not date_str:
        return "Date and time is required."
    try:
        dt = datetime.strptime(date_str, '%Y-%m-%dT%H:%M')
        if dt > datetime.now():
            return "Date and time cannot be in the future."
        return ""
    except ValueError:
        return "Invalid date/time format."

def validate_lookup_field(value, valid_list, field_name):
    if not value:
        return f"{field_name} is required."
    if value not in valid_list:
        return f"Invalid {field_name.lower()} selected."
    return ""

def validate_optional_lookup_field(value, valid_list, field_name):
    if value and value not in valid_list:
        return f"Invalid {field_name.lower()} selected."
    return ""

def validate_strikes_and_species(strikes_str, species_caught, valid_species):
    strikes_error = ""
    species_error = validate_lookup_field(species_caught, valid_species, 'Species')
        
    try:
        strikes = int(strikes_str) if strikes_str else -1
        if strikes < 0:
            strikes_error = "Strikes must be 0 or greater."
        elif strikes == 0 and species_caught != 'None':
            strikes_error = "If strikes is 0, species caught must be 'None'."
        elif strikes >= 1 and species_caught == 'None':
            species_error = "If strikes >= 1, a species must be recorded (not 'None')."
    except ValueError:
        strikes_error = "Strikes must be a valid number."
        
    return strikes_error, species_error

def validate_bait(rebaited, bait_type, valid_baits):
    bait_error = validate_lookup_field(bait_type, valid_baits, 'Bait type')
    
    if not bait_error:
        if rebaited == 'No' and bait_type != 'None':
            bait_error = "If not rebaited, bait type must be 'None'."
        elif rebaited == 'Yes' and bait_type == 'None':
            bait_error = "If rebaited, bait type cannot be 'None'."
            
    return bait_error

def validate_bait_details(bait_type, bait_details):
    """Validate bait details - required when bait type starts with 'Other'."""
    if bait_type and bait_type.startswith('Other') and not (bait_details and bait_details.strip()):
        return "Bait details are required when bait type is 'Other'."
    return ""

def validate_all_catch_record_fields(data, db, operator_id):
    """Validate catch record fields. Fetches lookup data from database internally."""
    pass_check = True
    
    # Fetch general lookup data (no user context needed)
    lookup = fetch_lookup_data(db)
    
    strikes_error, species_error = validate_strikes_and_species(
        data.get('strikes'), 
        data.get('species_caught'), 
        lookup['valid_species']
    )

    errors = {
        'trap_id': validate_trap_id(data.get('trap_id'), fetch_operator_trap_ids(db, operator_id)),
        'date': validate_date(data.get('date', '')),
        'species_caught': species_error,
        'status': validate_lookup_field(data.get('status'), lookup['valid_statuses'], 'Status'),
        'rebaited': validate_lookup_field(data.get('rebaited'), lookup['valid_rebaited'], 'Rebaited'),
        'bait_type': validate_bait(data.get('rebaited'), data.get('bait_type'), lookup['valid_baits']),
        'trap_condition': validate_lookup_field(data.get('trap_condition'), lookup['valid_conditions'], 'Trap condition'),
        'strikes': strikes_error,
        'sex': validate_optional_lookup_field(data.get('sex'), lookup['valid_sex'], 'Sex'),
        'maturity': validate_optional_lookup_field(data.get('maturity'), lookup['valid_maturity'], 'Maturity'),
        'bait_details': validate_bait_details(data.get('bait_type'), data.get('bait_details'))
    }

    # Check if any errors exist
    for error in errors.values():
        if error:
            pass_check = False
            break

    return pass_check, errors, lookup
################# validate catch data #################


################# validate observation data #################
def validate_observation_type(observation_type, valid_observation_types):
    """Validate observation type - must be a valid ENUM value."""
    if not observation_type:
        return "Observation type is required."
    if observation_type not in valid_observation_types:
        return "Invalid observation type selected."
    return ""

def validate_coordinates(latitude, longitude):
    """Validate latitude and longitude - optional but must be valid if provided."""
    lat_error = ""
    lon_error = ""
    
    if latitude:
        try:
            lat = float(latitude)
            if lat < -90 or lat > 90:
                lat_error = "Latitude must be between -90 and 90."
        except ValueError:
            lat_error = "Invalid latitude value."
    
    if longitude:
        try:
            lon = float(longitude)
            if lon < -180 or lon > 180:
                lon_error = "Longitude must be between -180 and 180."
        except ValueError:
            lon_error = "Invalid longitude value."
    
    # If one is provided, both should be provided
    if (latitude and not longitude) or (longitude and not latitude):
        return "Both latitude and longitude are required if either is provided.", ""
    
    return lat_error, lon_error

def validate_line_id(line_id, valid_line_ids):
    """Validate line_id - required and must be valid for operator."""
    if not line_id:
        return "Line is required."
    if str(line_id) not in valid_line_ids:
        return "Invalid line selected or you do not have permission for this line."
    return ""

def validate_optional_trap_id(trap_id, valid_trap_ids):
    """Validate trap_id - optional but must be valid for operator if provided."""
    if trap_id and str(trap_id) not in valid_trap_ids:
        return "Invalid trap selected or you do not have permission for this trap."
    return ""

def validate_all_observation_fields(data, db, operator_id):
    """Validate observation fields. Fetches lookup data from database internally."""
    pass_check = True
    
    # Fetch lookup data for observation types
    lookup = fetch_lookup_data(db)
    
    lat_error, lon_error = validate_coordinates(data.get('latitude'), data.get('longitude'))
    
    errors = {
        'date': validate_date(data.get('date', '')),
        'observation_type': validate_observation_type(data.get('observation_type', ''), lookup['valid_observation_types']),
        'notes': "",  # Notes is optional, no validation needed
        'latitude': lat_error,
        'longitude': lon_error,
        'line_id': validate_line_id(data.get('line_id'), fetch_operator_line_ids(db, operator_id)),
        'trap_id': validate_optional_trap_id(data.get('trap_id'), fetch_operator_trap_ids(db, operator_id))
    }

    # Check if any errors exist
    for error in errors.values():
        if error:
            pass_check = False
            break

    return pass_check, errors, lookup
################# validate observation data #################
