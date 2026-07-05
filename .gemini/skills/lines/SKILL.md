---
name: lines
description: Use this skill when making changes to the /lines section of the application. Triggered by requests related to line management, traps, or bait stations.
---

# Lines Management Skill

Use this skill when modifying the `/lines` section. You MUST read the relevant context files before making any changes.

## Context Files

Read these files before editing:
- **Routes:** `app/lines.py` (display), `app/admin.py` (admin CRUD)
- **Templates:** 
  - `app/templates/lines/index.html`
  - `app/templates/lines/detail.html`
  - `app/templates/lines/new_line.html`
  - `app/templates/lines/edit_line.html`
  - `app/templates/lines/edit_trap.html`
- **JavaScript:** 
  - `static/js/lines-index.js`
  - `static/js/lines-detail.js`
  - `static/js/lines-map-utils.js`
- **Helpers:** `app/helpers/dbHelper.py`, `app/helpers/trapCatchHelper.py`
- **UI & Style:** 
  - `app/templates/_ui_macros.html`
  - `static/css/custom.css`
  - `tiaki_ui_guide.html`

## Instructions

1. **Read First:** Always read the relevant files listed above.
2. **Follow Rules:** Strictly adhere to the rules in `GEMINI.md` (and the original `CLAUDE.md` rules):
   - Use Tiaki UI patterns and classes.
   - Keep JavaScript separate from templates.
   - Use `dbHelper.py` for database actions.
   - Use Jinja macros for common UI elements.
3. **Validation:** Verify all changes end-to-end (Backend -> Template -> JS interaction).
