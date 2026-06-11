# Innovation Epic - 3D Terrain Map (P2-106)

## Run order on a fresh database

```bash
psql -d tiaki -f sql/create_tables.sql
psql -d tiaki -f sql/populate_tables.sql
psql -d tiaki -f sql/seed_data.sql
psql -d tiaki -f sql/3d_epic_migration.sql
python run.py
```

Migration is idempotent and add-only -- creates `map3d_view_prefs` (per-user toggle persistence) and `map3d_view_log` (lightweight access log for demo metrics). No existing tables modified.

## Story-by-story implementation map

| Jira story | Where it lives |
|---|---|
| Set up the 3D map foundation | `app/templates/map3d/index.html` loads Three.js r128 from cdnjs (free, no key); `static/js/map3d.js` builds the scene, lighting, custom orbit controls, terrain mesh, asset placement |
| View my group's area as a 3D map | `/map3d` route (`map3d_index`) -- group-scoped, gated by `_active_group_id()`; nav entry added to primary nav + sidebar |
| Show vegetation (bush vs open ground) | `rebuildVegetation()` in `map3d.js` -- cone+cylinder tree meshes placed using bias + noise so they cluster like a bush patch; capped at ~250 meshes for laptop perf; toggle switch persists via `/map3d/prefs` |
| Show traps and bait stations as 3D markers | `placeAssets()` -- traps render as small green boxes, bait stations as cylinders; meshes inherit `userData` for click-picking |
| Colour-code markers by recent activity | `_activity_colour()` in `app/map3d.py` -- blue (none) -> green -> yellow -> orange -> red (7+ hits). Legend is rendered from the same scale returned in the JSON, so the data source is the single source of truth |
| Select a marker to view its details | Raycaster click handler in `map3d.js` opens a side popup with code, type, sub-type, line, recent activity, last check date + deep link into the line records page |
| Preview an assigned line before fieldwork | Operators get a "Your assigned lines" `<optgroup>` in the focus dropdown; selecting it calls `/map3d/data/line/<id>.json` which 403s if the line isn't theirs |
| Filter lines and asset types | Two `<select>` inputs ("Focus a line" + "Line type filter") trigger `placeAssets()` -- updates instantly without a fetch |

## Stack choices

- **Three.js r128 from cdnjs** -- chosen over CesiumJS because (a) free, (b) no commercial API key (matches the AC), (c) the artifacts spec lists this exact URL on the allowed CDN.
- **Open-Elevation** for real terrain heights, batched POST per session, with a sinusoidal fallback so the demo still works if the API is unreachable.
- **Custom orbit controls** -- OrbitControls isn't on the same CDN, so we wrote a minimal pointer/touch controller (~30 lines). It supports orbit, zoom, and keyboard pan.

## Files added

- `sql/3d_epic_migration.sql`
- `app/map3d.py` (5 routes, 4 helpers)
- `app/templates/map3d/index.html`
- `static/js/map3d.js`
- `tests/test_3d_epic.py` (7 tests)
- Nav links in `_primary_nav_links.html` and `_nav_sidebar.html`

## Performance + accessibility

- Tree meshes capped at 250 max; reusing geometry + material so it's a single draw call per type.
- Activity window default 30 days; user can clamp 1-365 (server-side double-validated).
- 3D stage is keyboard-focusable (`tabindex=0`) with arrow keys panning the camera target.
- Legend uses both color swatches and text labels; status badges in popups use the same dual-channel pattern.
- `aria-label`s on all controls; popup uses `role="dialog"`.
