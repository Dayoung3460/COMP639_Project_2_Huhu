"""agent.py — Microsoft Azure AI Foundry agent proxy routes.

Uses the OpenAI Responses API endpoint that Foundry exposes at:
  .../agents/{name}/endpoint/protocols/openai/responses

Each call is synchronous (no threads/polling). Multi-turn context is
maintained via the `previous_response_id` returned by each response,
stored per-group in the Flask session.
"""

import logging
import os

import requests as http
from flask import jsonify, request, session

from app import app, db
from app.utils import role_required

logger = logging.getLogger(__name__)

_ENDPOINT = os.environ.get('AZURE_AI_AGENT_ENDPOINT', '').rstrip('/')
_KEY      = os.environ.get('AZURE_AI_AGENT_KEY', '')
_TIMEOUT  = 60  # seconds — Foundry responses can be slow


def _configured():
    return bool(_ENDPOINT and _KEY)


def _headers():
    return {'api-key': _KEY, 'Content-Type': 'application/json'}


# ── Session keys (scoped per group so switching group resets context) ─────────

def _response_id_key():
    return f'agent_prev_response_{session.get("group_id", "none")}'


def _get_previous_response_id():
    return session.get(_response_id_key())


def _set_previous_response_id(response_id):
    session[_response_id_key()] = response_id


def _clear_previous_response_id():
    session.pop(_response_id_key(), None)


# ── Foundry API call ──────────────────────────────────────────────────────────

def _call_agent(message):
    """POST to the Foundry Responses endpoint and return (response_id, text)."""
    payload = {'input': message}

    prev_id = _get_previous_response_id()
    if prev_id:
        payload['previous_response_id'] = prev_id

    # api-version=v1 is required by Azure AI Foundry's Responses endpoint
    url = _ENDPOINT + ('&' if '?' in _ENDPOINT else '?') + 'api-version=v1'
    r = http.post(url, headers=_headers(), json=payload, timeout=_TIMEOUT)
    r.raise_for_status()
    data = r.json()

    response_id = data.get('id')

    # Walk the output array to find the assistant's text block
    text = ''
    for item in data.get('output', []):
        if item.get('type') == 'message' and item.get('role') == 'assistant':
            for block in item.get('content', []):
                if block.get('type') == 'output_text':
                    text = block.get('text', '')
                    break
        if text:
            break

    return response_id, text or 'No response received.'


# ── Data context ──────────────────────────────────────────────────────────────

def _build_data_context(group_id):
    """Fetch live group stats and return them as a formatted text block."""
    if not group_id:
        return ''

    parts = []

    try:
        with db.get_cursor() as cursor:
            # Per-line trap counts
            cursor.execute(
                """
                SELECT l.name, COUNT(t.trap_id) AS n
                FROM lines l
                LEFT JOIN traps t ON t.line_id = l.line_id AND t.is_retired = FALSE
                WHERE l.group_id = %s AND l.is_retired = FALSE
                GROUP BY l.line_id, l.name
                ORDER BY l.name
                """,
                (group_id,)
            )
            trap_lines = cursor.fetchall()
            if trap_lines:
                summary = '; '.join(f"{r['name']}: {r['n']} traps" for r in trap_lines)
                parts.append(f"Active trap lines with trap counts: {summary}")

        with db.get_cursor() as cursor:
            # Per-line bait station counts
            cursor.execute(
                """
                SELECT l.name, COUNT(bs.station_id) AS n
                FROM lines l
                LEFT JOIN bait_stations bs ON bs.line_id = l.line_id AND bs.is_retired = FALSE
                WHERE l.group_id = %s AND l.is_retired = FALSE
                GROUP BY l.line_id, l.name
                HAVING COUNT(bs.station_id) > 0
                ORDER BY l.name
                """,
                (group_id,)
            )
            bait_lines = cursor.fetchall()
            if bait_lines:
                summary = '; '.join(f"{r['name']}: {r['n']} bait stations" for r in bait_lines)
                parts.append(f"Active bait station lines with station counts: {summary}")

        with db.get_cursor() as cursor:
            cursor.execute(
                """
                SELECT tc.species_caught, COUNT(*) AS n
                FROM trap_catches tc
                JOIN traps t ON t.trap_id  = tc.trap_id
                JOIN lines l ON l.line_id  = t.line_id
                WHERE l.group_id = %s AND tc.date >= NOW() - INTERVAL '90 days'
                GROUP BY tc.species_caught ORDER BY n DESC LIMIT 10
                """,
                (group_id,)
            )
            catches = cursor.fetchall()
            if catches:
                summary = ', '.join(f"{r['species_caught']}: {r['n']}" for r in catches)
                parts.append(f"Catches in the last 90 days by species: {summary}")

        with db.get_cursor() as cursor:
            cursor.execute(
                """
                SELECT COUNT(*) AS n FROM trap_catches tc
                JOIN traps t ON t.trap_id = tc.trap_id
                JOIN lines l ON l.line_id = t.line_id
                WHERE l.group_id = %s AND tc.date >= NOW() - INTERVAL '30 days'
                """,
                (group_id,)
            )
            row = cursor.fetchone()
            if row:
                parts.append(f"Catches in the last 30 days: {row['n']}")

        with db.get_cursor() as cursor:
            cursor.execute(
                """
                SELECT MAX(tc.date) AS last_date FROM trap_catches tc
                JOIN traps t ON t.trap_id = tc.trap_id
                JOIN lines l ON l.line_id = t.line_id
                WHERE l.group_id = %s
                """,
                (group_id,)
            )
            row = cursor.fetchone()
            if row and row['last_date']:
                parts.append(f"Most recent catch recorded: {row['last_date'].strftime('%Y-%m-%d')}")

    except Exception:
        logger.exception('Failed to build data context for group %s', group_id)

    if not parts:
        return ''

    group_name = session.get('group_name', 'your group')
    return f'[Live data snapshot for group "{group_name}"]\n' + '\n'.join(parts)


# ── Routes ────────────────────────────────────────────────────────────────────

@app.route('/agent/chat', methods=['POST'])
@role_required()
def agent_chat():
    if not _configured():
        return jsonify({'error': 'The AI assistant is not configured yet.'}), 503

    data    = request.get_json(silent=True) or {}
    message = (data.get('message') or '').strip()
    if not message:
        return jsonify({'error': 'Message cannot be empty.'}), 400
    if len(message) > 1000:
        return jsonify({'error': 'Message is too long (max 1000 characters).'}), 400

    group_id   = session.get('group_id')
    group_name = session.get('group_name', 'your group')
    role       = session.get('group_role', 'member')

    data_context = _build_data_context(group_id)

    parts = []
    if data_context:
        parts.append(data_context)
    parts.append(f'[User role: {role} in group "{group_name}"]')
    parts.append(message)
    full_message = '\n'.join(parts)

    try:
        response_id, reply = _call_agent(full_message)
        if response_id:
            _set_previous_response_id(response_id)
        return jsonify({'reply': reply})

    except http.HTTPError as exc:
        logger.exception('Foundry API HTTP error: %s', exc)
        return jsonify({'error': 'Could not reach the AI assistant. Please try again later.'}), 502
    except http.RequestException as exc:
        logger.exception('Foundry API connection error: %s', exc)
        return jsonify({'error': 'Connection to the AI assistant failed. Please try again later.'}), 502


@app.route('/agent/reset', methods=['POST'])
@role_required()
def agent_reset():
    """Clear the conversation context for the current group session."""
    _clear_previous_response_id()
    return jsonify({'ok': True})
