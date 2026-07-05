# Improvement Backlog

Prioritised list of improvements (reviewed 2026-07-05).
Recommended order: 1 → 2 → 4 → 5.

## High impact (user-facing)

- [x] **1. Move uploads to object storage** — done (2026-07-05): all uploads go
  through `app/helpers/storageHelper.py` (Cloudflare R2 when `R2_*` env vars are
  set, local `static/` otherwise). Remaining ops steps to go live: create the R2
  bucket + API token, set the five `R2_*` vars on Render, then run
  `python scripts/sync_uploads_to_r2.py` once (see README → Deployment).
- [x] **2. Add DB connection pooling** — done (2026-07-05): `app/db.py` now uses
  `psycopg2.pool.ThreadedConnectionPool` (lazy per-process pool, connections
  health-checked on borrow so Neon auto-suspend doesn't surface errors).
  Measured borrow cost: ~50 ms fresh connect → ~0.2 ms pooled.
- [ ] **3. Stop silently swallowing exceptions** — dashboards (e.g. `app/observer.py`)
  catch `Exception`, log it, and render zeros as if there were no data. Surface a
  flash message or error state instead. Pattern is repeated across several modules.

## Code quality / maintainability

- [ ] **4. Expand tests and add CI** — only 2 test files (~325 lines) against a
  ~13k-line backend. Start with regression-prone areas: the `role_required`
  permission matrix, reports filter combinations, theme validation. Add a GitHub
  Actions workflow running tests + ruff on every push.
- [ ] **5. Split oversized modules and adopt Blueprints** — `coordinator.py` (1,605
  lines), `themes.py` (1,396), `helpdesk.py` (1,198) all attach routes to the single
  `app` object via `from app import app`. Convert areas (coordinator, helpdesk,
  updates, …) to Flask Blueprints. Do this after #4 so the refactor has a safety net.
- [ ] **6. Consolidate f-string SQL fragment assembly** — 30+ queries in `reports.py`,
  `observer.py`, `coordinator_export.py`, `admin.py` interpolate SQL fragments via
  f-strings. All current fragments are internally whitelisted (not injectable), but
  the pattern invites future injection bugs. Extract a shared WHERE-clause builder
  into `app/helpers/` (per `app/CLAUDE.md` conventions).

## Small cleanups

- [ ] Split dev dependencies (`livereload`, `tornado`) out of `requirements.txt`
  into a `requirements-dev.txt` so production builds stay lean.
- [x] Fix README Tech Stack table — done (2026-07-05) alongside the R2 work.
- [ ] Replace the hand-rolled `load_env_file` in `app/__init__.py` with
  `python-dotenv` (already a dependency).
- [ ] Mitigate Render free-tier cold start (~30 s wake-up) with an external ping
  (e.g. cron-job.org) — note this is a grey area under Render's free-tier policy.
- [ ] Resolve untracked files: `.gemini/`, `GEMINI.md`, `run_local.py` — commit or
  add to `.gitignore`.
