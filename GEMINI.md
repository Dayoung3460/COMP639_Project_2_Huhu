# Huhu Tiaki - Gemini CLI Rules

This file serves as the foundational mandate for Gemini CLI in this project. These rules take precedence over general defaults.

## Project Context
- **Institution:** Lincoln University, NZ (COMP639).
- **Communication:** Always write team-facing messages (commit messages, summaries intended for teammates) in **English**.
- **Ownership:** Dayoung owns all pages and logic under the `/lines` section. Scope all refactoring and UI changes strictly to her files unless explicitly instructed otherwise.

## Frontend & UI Standards
- **Source of Truth:** All UI must follow `tiaki_ui_guide.html` and `static/css/custom.css`.
- **No Inline Code:** 
  - NO JavaScript in `.html` templates. Bind events in `static/js/*.js`.
  - NO inline styles. Use classes from `custom.css` or CSS variables.
- **Jinja Macros:** Use shared macros in `app/templates/_ui_macros.html` for buttons, panels, and status badges.
- **Tiaki Components:**
  - Use `btn-pf`, `btn-pf-outline`, etc. (Avoid Bootstrap `btn-primary`, `btn-danger`).
  - Use `pf-table` for tables.
  - Use the `panel` structure (`panel-header`, `panel-body`).

## Backend & Database
- **Logic Placement:** Keep route logic minimal. Move business logic to `app/helpers/`.
- **Database Helpers:** Use and extend `app/helpers/dbHelper.py` for reusable SQL actions.
- **Lookups:** Use `fetch_lookup_data` for enums/types rather than hardcoding.

## Execution Workflow
- **Validation:** Always verify features end-to-end (Backend -> Template -> JS interaction).
- **Testing:** When changing macros or shared helpers, verify all dependent pages render correctly.
