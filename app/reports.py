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
    operator_id = request.args.get('operator_id', '')
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

    # ── Build operator filter ─────────────────────────────────
    operator_sql    = ''
    operator_params = []
    if operator_id:
        operator_sql    = 'AND tc.recorded_by_id = %s'
        operator_params = [operator_id]

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

    lines     = []
    operators = []

    try:
        with db.get_cursor() as cursor:

            # All lines for filter dropdown — including retired
            cursor.execute(
                '''SELECT line_id, name, is_retired
                   FROM lines
                   ORDER BY is_retired ASC, name ASC'''
            )
            lines = cursor.fetchall()

            # All operators who have catch records — for filter dropdown
            cursor.execute('''
                SELECT DISTINCT u.user_id, u.first_name, u.last_name
                FROM users u
                JOIN trap_catches tc ON tc.recorded_by_id = u.user_id
                ORDER BY u.first_name, u.last_name
            ''')
            operators = cursor.fetchall()

            # Combined params for filtered queries
            all_params = line_params + operator_params

            # Total captures (species != None)
            cursor.execute(f'''
                SELECT COUNT(*) AS count
                FROM trap_catches tc
                JOIN traps t ON tc.trap_id = t.trap_id
                JOIN lines l ON t.line_id = l.line_id
                WHERE tc.species_caught != 'None'
                {period_sql} {line_sql} {operator_sql} {status_filter}
            ''', all_params)
            stats['total_captures'] = cursor.fetchone()['count']

            # Total records
            cursor.execute(f'''
                SELECT COUNT(*) AS count
                FROM trap_catches tc
                JOIN traps t ON tc.trap_id = t.trap_id
                JOIN lines l ON t.line_id = l.line_id
                WHERE 1=1 {period_sql} {line_sql} {operator_sql} {status_filter}
            ''', all_params)
            stats['total_records'] = cursor.fetchone()['count']

            # Active traps — count of non-retired traps on non-retired lines
            cursor.execute(f'''
                SELECT COUNT(*) AS total
                FROM traps t
                JOIN lines l ON t.line_id = l.line_id
                WHERE t.is_retired = FALSE
                AND l.is_retired = FALSE
                {line_sql} {status_filter}
            ''', line_params)
            stats['active_trap_pct'] = cursor.fetchone()['total']

            # Top species
            cursor.execute(f'''
                SELECT tc.species_caught, COUNT(*) AS cnt
                FROM trap_catches tc
                JOIN traps t ON tc.trap_id = t.trap_id
                JOIN lines l ON t.line_id = l.line_id
                WHERE tc.species_caught != 'None'
                {period_sql} {line_sql} {operator_sql} {status_filter}
                GROUP BY tc.species_caught
                ORDER BY cnt DESC
                LIMIT 1
            ''', all_params)
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

            all_params = line_params + operator_params

            # ── Catch trend — grouped by week ─────────────────
            cursor.execute(f'''
                SELECT
                    TO_CHAR(DATE_TRUNC('week', tc.date), 'DD Mon') AS week_label,
                    COUNT(*) AS cnt
                FROM trap_catches tc
                JOIN traps t ON tc.trap_id = t.trap_id
                JOIN lines l ON t.line_id = l.line_id
                WHERE tc.species_caught != 'None'
                {period_sql} {line_sql} {operator_sql} {status_filter}
                GROUP BY DATE_TRUNC('week', tc.date)
                ORDER BY DATE_TRUNC('week', tc.date)
            ''', all_params)
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
                {period_sql} {line_sql} {operator_sql} {status_filter}
                GROUP BY tc.species_caught
                ORDER BY cnt DESC
            ''', all_params)
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
                {period_sql} {line_sql} {operator_sql} {status_filter}
                GROUP BY l.line_id, l.name, l.is_retired
                ORDER BY l.is_retired ASC, cnt DESC
            ''', all_params)
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
                WHERE 1=1 {period_sql} {line_sql} {operator_sql} {status_filter}
                GROUP BY l.line_id, l.name, l.is_retired, tc.status
                ORDER BY l.is_retired ASC, l.name, tc.status
            ''', all_params)
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
                {period_sql} {line_sql} {operator_sql} {status_filter}
                ORDER BY t.code
            ''', all_params)
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
                WHERE 1=1 {line_sql} {operator_sql} {status_filter}
                ORDER BY tc.date DESC
                LIMIT 1
            ''', line_params + operator_params)
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
                WHERE 1=1 {line_sql} {operator_sql} {status_filter}
                ORDER BY tc.date DESC
                LIMIT 10
            ''', line_params + operator_params)
            recent_catches = cursor.fetchall()

    except Exception as e:
        app.logger.error(f'Reports chart data error: {e}')

    return render_template('reports/index.html',
                           stats=stats,
                           lines=lines,
                           operators=operators,
                           selected_line=line_id,
                           selected_line_status=line_status,
                           selected_operator=operator_id,
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


# ─────────────────────────────────────────────────────────────────────────────
# Super Admin Platform Analytics
# ─────────────────────────────────────────────────────────────────────────────

@app.route('/admin/reports')
@role_required('Super Admin')
def admin_reports():
    """Platform Analytics dashboard — Super Admin only."""

    period    = request.args.get('period', '3')
    date_from = request.args.get('date_from', '')
    date_to   = request.args.get('date_to', '')

    # ── Build date filter ─────────────────────────────────────
    period_sql = ''
    if period == 'custom' and date_from and date_to:
        period_sql = f"AND tc.date BETWEEN '{date_from}' AND '{date_to} 23:59:59'"
    elif period != 'all':
        period_sql = f"AND tc.date >= NOW() - INTERVAL '{period} months'"

    stats = {
        'total_captures': 0,
        'active_groups':  0,
        'active_traps':   0,
        'top_species':    '—',
    }

    trend_labels    = []
    trend_values    = []
    species_labels  = []
    species_values  = []
    species_colors  = []
    other_breakdown = {}
    group_labels    = []
    group_values    = []
    group_colors    = []
    group_rows      = []

    try:
        with db.get_cursor() as cursor:

            # ── Platform-wide summary stats ───────────────────

            # Total captures (period-filtered)
            cursor.execute(f'''
                SELECT COUNT(*) AS count
                FROM trap_catches tc
                JOIN traps t ON tc.trap_id = t.trap_id
                JOIN lines l ON t.line_id = l.line_id
                WHERE tc.species_caught != 'None'
                {period_sql}
            ''')
            stats['total_captures'] = cursor.fetchone()['count']

            # Total active groups
            cursor.execute(
                "SELECT COUNT(*) AS count FROM groups WHERE is_active = TRUE"
            )
            stats['active_groups'] = cursor.fetchone()['count']

            # Total active traps across all groups
            cursor.execute('''
                SELECT COUNT(*) AS count
                FROM traps t
                JOIN lines l ON t.line_id = l.line_id
                WHERE t.is_retired = FALSE AND l.is_retired = FALSE
            ''')
            stats['active_traps'] = cursor.fetchone()['count']

            # Top species (period-filtered, platform-wide)
            cursor.execute(f'''
                SELECT tc.species_caught, COUNT(*) AS cnt
                FROM trap_catches tc
                JOIN traps t ON tc.trap_id = t.trap_id
                JOIN lines l ON t.line_id = l.line_id
                WHERE tc.species_caught != 'None'
                {period_sql}
                GROUP BY tc.species_caught
                ORDER BY cnt DESC
                LIMIT 1
            ''')
            row = cursor.fetchone()
            if row:
                stats['top_species'] = row['species_caught']

            # ── Catch trend — platform-wide, grouped by week ──
            cursor.execute(f'''
                SELECT
                    TO_CHAR(DATE_TRUNC('week', tc.date), 'DD Mon') AS week_label,
                    COUNT(*) AS cnt
                FROM trap_catches tc
                JOIN traps t ON tc.trap_id = t.trap_id
                JOIN lines l ON t.line_id = l.line_id
                WHERE tc.species_caught != 'None'
                {period_sql}
                GROUP BY DATE_TRUNC('week', tc.date)
                ORDER BY DATE_TRUNC('week', tc.date)
            ''')
            trend_rows   = cursor.fetchall()
            trend_labels = [r['week_label'] for r in trend_rows]
            trend_values = [r['cnt'] for r in trend_rows]

            # ── Species breakdown — platform-wide, 5% threshold
            cursor.execute(f'''
                SELECT tc.species_caught, COUNT(*) AS cnt
                FROM trap_catches tc
                JOIN traps t ON tc.trap_id = t.trap_id
                JOIN lines l ON t.line_id = l.line_id
                WHERE tc.species_caught != 'None'
                {period_sql}
                GROUP BY tc.species_caught
                ORDER BY cnt DESC
            ''')
            species_rows  = cursor.fetchall()
            total_catches = sum(r['cnt'] for r in species_rows)
            threshold     = total_catches * 0.05 if total_catches > 0 else 0
            palette       = ['#3d9b67', '#e8920a', '#1a6fa8', '#7c3aed', '#c0392b',
                             '#0891b2', '#d97706', '#059669', '#dc2626', '#7c3aed']
            color_idx   = 0
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

            # ── Catches per group (horizontal bar chart) ──────
            bar_palette = ['#3d9b67', '#e8920a', '#1a6fa8', '#7c3aed', '#c0392b',
                           '#0891b2', '#d97706', '#059669', '#dc2626', '#6b7280']
            cursor.execute(f'''
                SELECT g.name AS group_name, COUNT(*) AS cnt
                FROM trap_catches tc
                JOIN traps t ON tc.trap_id = t.trap_id
                JOIN lines l ON t.line_id = l.line_id
                JOIN groups g ON l.group_id = g.group_id
                WHERE tc.species_caught != 'None'
                {period_sql}
                GROUP BY g.group_id, g.name
                ORDER BY cnt DESC
            ''')
            gbar_rows    = cursor.fetchall()
            group_labels = [r['group_name'] for r in gbar_rows]
            group_values = [r['cnt'] for r in gbar_rows]
            group_colors = [bar_palette[i % len(bar_palette)]
                            for i in range(len(gbar_rows))]

            # ── Group leaderboard table ────────────────────────
            # Subquery-based: member count, active lines/traps,
            # period-filtered catch count and capture rate.
            cursor.execute(f'''
                SELECT
                    g.name        AS group_name,
                    g.is_active,
                    COALESCE(members.member_count, 0)  AS member_count,
                    COALESCE(ls.active_lines, 0)       AS active_lines,
                    COALESCE(ts.active_traps, 0)       AS active_traps,
                    COALESCE(stats.catch_count, 0)     AS catch_count,
                    COALESCE(stats.total_records, 0)   AS total_records,
                    CASE
                        WHEN COALESCE(stats.total_records, 0) > 0
                        THEN ROUND(
                            COALESCE(stats.catch_count, 0) * 100.0
                            / stats.total_records, 1)
                        ELSE 0
                    END AS capture_rate
                FROM groups g
                LEFT JOIN (
                    SELECT group_id, COUNT(*) AS member_count
                    FROM group_memberships
                    GROUP BY group_id
                ) members ON g.group_id = members.group_id
                LEFT JOIN (
                    SELECT group_id, COUNT(*) AS active_lines
                    FROM lines
                    WHERE is_retired = FALSE
                    GROUP BY group_id
                ) ls ON g.group_id = ls.group_id
                LEFT JOIN (
                    SELECT l.group_id, COUNT(*) AS active_traps
                    FROM traps t
                    JOIN lines l ON t.line_id = l.line_id
                    WHERE t.is_retired = FALSE AND l.is_retired = FALSE
                    GROUP BY l.group_id
                ) ts ON g.group_id = ts.group_id
                LEFT JOIN (
                    SELECT
                        l.group_id,
                        COUNT(CASE WHEN tc.species_caught != 'None' THEN 1 END)
                            AS catch_count,
                        COUNT(*) AS total_records
                    FROM trap_catches tc
                    JOIN traps t ON tc.trap_id = t.trap_id
                    JOIN lines l ON t.line_id = l.line_id
                    WHERE 1=1 {period_sql}
                    GROUP BY l.group_id
                ) stats ON g.group_id = stats.group_id
                WHERE g.is_active = TRUE
                ORDER BY catch_count DESC, g.name
            ''')
            group_rows = cursor.fetchall()

    except Exception as e:
        app.logger.error(f'Admin reports error: {e}')

    # ── Auto-generated chart summaries ───────────────────────
    # Computed from live data — never hard-coded.

    # Trend summary
    if not trend_values:
        trend_summary = 'No catch data was recorded in this period.'
    elif len(trend_values) == 1:
        v = trend_values[0]
        trend_summary = (
            f'{v} catch{"es" if v != 1 else ""} recorded in the '
            f'only active week of this period.'
        )
    else:
        total_t  = sum(trend_values)
        peak_idx = trend_values.index(max(trend_values))
        peak_lbl = trend_labels[peak_idx]
        peak_val = trend_values[peak_idx]
        avg_t    = total_t / len(trend_values)

        mid         = len(trend_values) // 2
        first_avg   = sum(trend_values[:mid]) / mid if mid else 0
        second_avg  = sum(trend_values[mid:]) / (len(trend_values) - mid)
        if second_avg > first_avg * 1.15:
            direction = 'an upward trend'
        elif second_avg < first_avg * 0.85:
            direction = 'a downward trend'
        else:
            direction = 'stable activity'

        trend_summary = (
            f'{total_t} total catch{"es" if total_t != 1 else ""} were recorded '
            f'across the platform this period, showing {direction}.'
        )
        if peak_val > avg_t * 1.5 and len(trend_values) > 2:
            trend_summary += (
                f' A spike occurred in the week of {peak_lbl} with {peak_val} '
                f'catch{"es" if peak_val != 1 else ""} '
                f'({round(peak_val / avg_t, 1)}× the weekly average).'
            )
        else:
            trend_summary += (
                f' The busiest week was {peak_lbl} with '
                f'{peak_val} catch{"es" if peak_val != 1 else ""}.'
            )

    # Species summary
    if not species_values:
        species_summary = 'No captures have been recorded in this period.'
    else:
        total_sp    = sum(species_values)
        top_sp      = species_labels[0]
        top_sp_val  = species_values[0]
        top_sp_pct  = round(top_sp_val / total_sp * 100, 1) if total_sp else 0
        num_species = (
            len(species_labels)
            - (1 if 'Other' in species_labels else 0)
            + len(other_breakdown)
        )

        species_summary = (
            f'{num_species} distinct '
            f'species{"" if num_species == 1 else ""} recorded platform-wide. '
            f'{top_sp} is the most frequently caught, accounting for '
            f'{top_sp_pct}% of all captures ({top_sp_val} total).'
        )
        if top_sp_pct >= 70:
            species_summary += (
                f' The platform is heavily dominated by {top_sp} this period.'
            )
        elif num_species == 1:
            species_summary += ' Only a single species was recorded this period.'

    # Group comparison summary
    if not group_values:
        group_summary = (
            'No catch data was recorded across any group in this period.'
        )
    else:
        top_grp   = group_labels[0]
        top_gval  = group_values[0]
        active_ct = len([v for v in group_values if v > 0])
        total_grp = stats['active_groups']
        inactive  = total_grp - active_ct

        group_summary = (
            f'{top_grp} leads all groups with {top_gval} '
            f'capture{"s" if top_gval != 1 else ""} this period. '
            f'{active_ct} out of {total_grp} active '
            f'group{"s" if total_grp != 1 else ""} recorded at least one catch.'
        )
        if inactive > 0:
            group_summary += (
                f' {inactive} group{"s" if inactive != 1 else ""} '
                f'recorded no catch activity this period.'
            )
        elif len(group_values) >= 2 and group_values[1] > 0:
            gap = top_gval - group_values[1]
            group_summary += (
                f' {top_grp} leads the next group by '
                f'{gap} capture{"s" if gap != 1 else ""}.'
            )

    return render_template('reports/admin_reports.html',
                           stats=stats,
                           selected_period=period,
                           date_from=date_from,
                           date_to=date_to,
                           trend_labels=trend_labels,
                           trend_values=trend_values,
                           species_labels=species_labels,
                           species_values=species_values,
                           species_colors=species_colors,
                           other_breakdown=other_breakdown,
                           group_labels=group_labels,
                           group_values=group_values,
                           group_colors=group_colors,
                           group_rows=group_rows,
                           trend_summary=trend_summary,
                           species_summary=species_summary,
                           group_summary=group_summary)