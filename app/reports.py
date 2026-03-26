"""reports.py — Reports and chart data routes (all logged-in roles)."""

from flask import render_template, request
from app import app, db
from app.utils import role_required


@app.route('/reports')
@role_required()
def reports():
    """Render the reports page with live summary stats."""
    line_id     = request.args.get('line_id', '')
    period      = request.args.get('period', '3')
    date_from   = request.args.get('date_from', '')
    date_to     = request.args.get('date_to', '')
    line_status = 'all'

    # Handle All Active / All Retired coming through line_id dropdown
    if line_id == 'active':
        line_status = 'active'
        line_id     = ''
    elif line_id == 'retired':
        line_status = 'retired'
        line_id     = ''

    # ── Build date filter ─────────────────────────────────────
    period_sql = ''
    if period == 'custom' and date_from and date_to:
        period_sql = f"AND tc.date BETWEEN '{date_from}' AND '{date_to} 23:59:59'"
    elif period != 'all':
        period_sql = f"AND tc.date >= NOW() - INTERVAL '{period} months'"

    # ── Build line filter ─────────────────────────────────────
    line_sql    = ''
    line_params = []
    if line_id:
        line_sql    = 'AND l.line_id = %s'
        line_params = [line_id]

    # ── Build retired status filter ───────────────────────────
    status_filter = ''
    if line_status == 'active':
        status_filter = 'AND l.is_retired = FALSE'
    elif line_status == 'retired':
        status_filter = 'AND l.is_retired = TRUE'

    stats = {
        'total_captures':  0,
        'total_records':   0,
        'active_trap_pct': 0,
        'top_species':     '—',
    }

    lines = []

    try:
        with db.get_cursor() as cursor:

            # All lines for filter dropdown — including retired
            cursor.execute(
                '''SELECT line_id, name, is_retired
                   FROM lines
                   ORDER BY is_retired ASC, name ASC'''
            )
            lines = cursor.fetchall()

            # Total captures (species != None)
            cursor.execute(f'''
                SELECT COUNT(*) AS count
                FROM trap_catches tc
                JOIN traps t ON tc.trap_id = t.trap_id
                JOIN lines l ON t.line_id = l.line_id
                WHERE tc.species_caught != 'None'
                {period_sql} {line_sql} {status_filter}
            ''', line_params)
            stats['total_captures'] = cursor.fetchone()['count']

            # Total records
            cursor.execute(f'''
                SELECT COUNT(*) AS count
                FROM trap_catches tc
                JOIN traps t ON tc.trap_id = t.trap_id
                JOIN lines l ON t.line_id = l.line_id
                WHERE 1=1 {period_sql} {line_sql} {status_filter}
            ''', line_params)
            stats['total_records'] = cursor.fetchone()['count']

            # Active trap %
            cursor.execute('SELECT COUNT(*) AS total FROM traps WHERE is_retired = FALSE')
            total_traps = cursor.fetchone()['total']
            cursor.execute('''
                SELECT COUNT(DISTINCT tc.trap_id) AS active
                FROM trap_catches tc
                JOIN traps t ON tc.trap_id = t.trap_id
                WHERE t.is_retired = FALSE
                AND tc.date >= NOW() - INTERVAL '30 days'
            ''')
            active_traps = cursor.fetchone()['active']
            if total_traps > 0:
                stats['active_trap_pct'] = round((active_traps / total_traps) * 100)

            # Top species
            cursor.execute(f'''
                SELECT tc.species_caught, COUNT(*) AS cnt
                FROM trap_catches tc
                JOIN traps t ON tc.trap_id = t.trap_id
                JOIN lines l ON t.line_id = l.line_id
                WHERE tc.species_caught != 'None'
                {period_sql} {line_sql} {status_filter}
                GROUP BY tc.species_caught
                ORDER BY cnt DESC
                LIMIT 1
            ''', line_params)
            row = cursor.fetchone()
            if row:
                stats['top_species'] = row['species_caught']

    except Exception as e:
        app.logger.error(f'Reports stats error: {e}')

    # ── Chart data ────────────────────────────────────────────
    trend_labels    = []
    trend_values    = []
    species_labels  = []
    species_values  = []
    species_colors  = []
    other_breakdown = {}
    line_labels     = []
    line_values     = []
    line_colors     = []
    status_labels   = []
    status_datasets = []
    insights        = {}
    recent_catches  = []

    try:
        with db.get_cursor() as cursor:

            # ── Catch trend — grouped by week ─────────────────
            cursor.execute(f'''
                SELECT
                    TO_CHAR(DATE_TRUNC('week', tc.date), 'DD Mon') AS week_label,
                    COUNT(*) AS cnt
                FROM trap_catches tc
                JOIN traps t ON tc.trap_id = t.trap_id
                JOIN lines l ON t.line_id = l.line_id
                WHERE tc.species_caught != 'None'
                {period_sql} {line_sql} {status_filter}
                GROUP BY DATE_TRUNC('week', tc.date)
                ORDER BY DATE_TRUNC('week', tc.date)
            ''', line_params)
            trend_rows    = cursor.fetchall()
            trend_labels  = [r['week_label'] for r in trend_rows]
            trend_values  = [r['cnt'] for r in trend_rows]

            # ── Species breakdown with 5% threshold ──────────
            cursor.execute(f'''
                SELECT tc.species_caught, COUNT(*) AS cnt
                FROM trap_catches tc
                JOIN traps t ON tc.trap_id = t.trap_id
                JOIN lines l ON t.line_id = l.line_id
                WHERE tc.species_caught != 'None'
                {period_sql} {line_sql} {status_filter}
                GROUP BY tc.species_caught
                ORDER BY cnt DESC
            ''', line_params)
            species_rows  = cursor.fetchall()

            total_catches = sum(r['cnt'] for r in species_rows)
            threshold     = total_catches * 0.05 if total_catches > 0 else 0

            palette   = ['#3d9b67','#e8920a','#1a6fa8','#7c3aed','#c0392b',
                         '#0891b2','#d97706','#059669','#dc2626','#7c3aed']
            color_idx = 0
            other_total = 0

            for row in species_rows:
                if row['cnt'] >= threshold:
                    species_labels.append(row['species_caught'])
                    species_values.append(row['cnt'])
                    species_colors.append(palette[color_idx % len(palette)])
                    color_idx += 1
                else:
                    other_breakdown[row['species_caught']] = row['cnt']
                    other_total += row['cnt']

            if other_total > 0:
                species_labels.append('Other')
                species_values.append(other_total)
                species_colors.append('#6b7c72')

            # ── Catches by trap line ───────────────────────────
            cursor.execute(f'''
                SELECT l.line_id, l.name AS line_name, l.is_retired, COUNT(*) AS cnt
                FROM trap_catches tc
                JOIN traps t ON tc.trap_id = t.trap_id
                JOIN lines l ON t.line_id = l.line_id
                WHERE tc.species_caught != 'None'
                {period_sql} {line_sql} {status_filter}
                GROUP BY l.line_id, l.name, l.is_retired
                ORDER BY l.is_retired ASC, cnt DESC
            ''', line_params)
            line_rows      = cursor.fetchall()
            active_palette = ['#3d9b67','#e8920a','#1a6fa8','#7c3aed','#c0392b',
                              '#0891b2','#d97706','#059669','#dc2626','#6b7280']
            retired_color  = '#cbd5e1'
            line_labels = [
                r['line_name'] + (' ⊘' if r['is_retired'] else '')
                for r in line_rows
            ]
            line_values = [r['cnt'] for r in line_rows]
            line_colors = [
                retired_color if r['is_retired'] else active_palette[i % len(active_palette)]
                for i, r in enumerate(line_rows)
            ]

            # ── Trap status distribution by line ───────────────
            cursor.execute(f'''
                SELECT l.line_id, l.name AS line_name, l.is_retired, tc.status, COUNT(*) AS cnt
                FROM trap_catches tc
                JOIN traps t ON tc.trap_id = t.trap_id
                JOIN lines l ON t.line_id = l.line_id
                WHERE 1=1 {period_sql} {line_sql} {status_filter}
                GROUP BY l.line_id, l.name, l.is_retired, tc.status
                ORDER BY l.is_retired ASC, l.name, tc.status
            ''', line_params)
            status_rows = cursor.fetchall()

            seen = {}
            for r in status_rows:
                key = r['line_id']
                if key not in seen:
                    label = r['line_name'] + (' ⊘' if r['is_retired'] else '')
                    seen[key] = (label, r['is_retired'])
            status_line_names = [v[0] for v in seen.values()]

            status_map = {}
            for r in status_rows:
                label = r['line_name'] + (' ⊘' if r['is_retired'] else '')
                if r['status'] not in status_map:
                    status_map[r['status']] = {ln: 0 for ln in status_line_names}
                status_map[r['status']][label] = r['cnt']

            status_labels  = status_line_names
            status_palette = {
                'Sprung':                  '#c0392b',
                'Still set, bait OK':      '#3d9b67',
                'Still set, bait bad':     '#e8920a',
                'Still set, bait missing': '#f59e0b',
                'Initial set':             '#1a6fa8',
                'Removed':                 '#6b7c72',
            }
            status_datasets = [
                {
                    'label':           status,
                    'data':            [counts[ln] for ln in status_line_names],
                    'backgroundColor': status_palette.get(status, '#9ca3af')
                }
                for status, counts in status_map.items()
            ]

            # ── Key insights ───────────────────────────────────
            if line_labels:
                insights['busiest_line']  = line_labels[0]
                insights['busiest_count'] = line_values[0]

            # Traps needing maintenance
            cursor.execute(f'''
                SELECT DISTINCT t.code
                FROM trap_catches tc
                JOIN traps t ON tc.trap_id = t.trap_id
                JOIN lines l ON t.line_id = l.line_id
                WHERE tc.trap_condition = 'Needs maintenance'
                {period_sql} {line_sql} {status_filter}
                ORDER BY t.code
            ''', line_params)
            maintenance_rows              = cursor.fetchall()
            insights['maintenance_count'] = len(maintenance_rows)
            insights['maintenance_traps'] = [r['code'] for r in maintenance_rows]

            # Capture rate
            if stats['total_records'] > 0:
                insights['capture_rate'] = round(
                    (stats['total_captures'] / stats['total_records']) * 100, 1
                )
            else:
                insights['capture_rate'] = 0

            # Most recent check
            cursor.execute(f'''
                SELECT tc.date, l.name AS line_name
                FROM trap_catches tc
                JOIN traps t ON tc.trap_id = t.trap_id
                JOIN lines l ON t.line_id = l.line_id
                WHERE 1=1 {line_sql} {status_filter}
                ORDER BY tc.date DESC
                LIMIT 1
            ''', line_params)
            last = cursor.fetchone()
            if last:
                insights['last_check_line'] = last['line_name']
                insights['last_check_date'] = last['date']

            # Retired lines
            cursor.execute(
                'SELECT name FROM lines WHERE is_retired = TRUE ORDER BY name'
            )
            retired_rows              = cursor.fetchall()
            insights['retired_lines'] = [r['name'] for r in retired_rows]

            # ── Recent catches (last 10) ───────────────────────
            cursor.execute(f'''
                SELECT
                    tc.date,
                    l.name  AS line_name,
                    t.code  AS trap_code,
                    tc.species_caught,
                    tc.status
                FROM trap_catches tc
                JOIN traps t ON tc.trap_id = t.trap_id
                JOIN lines l ON t.line_id = l.line_id
                WHERE 1=1 {line_sql} {status_filter}
                ORDER BY tc.date DESC
                LIMIT 10
            ''', line_params)
            recent_catches = cursor.fetchall()

    except Exception as e:
        app.logger.error(f'Reports chart data error: {e}')

    return render_template('reports/index.html',
                           stats=stats,
                           lines=lines,
                           selected_line=line_id,
                           selected_line_status=line_status,
                           selected_period=period,
                           date_from=date_from,
                           date_to=date_to,
                           trend_labels=trend_labels,
                           trend_values=trend_values,
                           species_labels=species_labels,
                           species_values=species_values,
                           species_colors=species_colors,
                           other_breakdown=other_breakdown,
                           line_labels=line_labels,
                           line_values=line_values,
                           line_colors=line_colors,
                           status_labels=status_labels,
                           status_datasets=status_datasets,
                           insights=insights,
                           recent_catches=recent_catches)