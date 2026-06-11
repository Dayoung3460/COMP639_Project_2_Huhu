# P2-107 - Group Updates & Shared Knowledge Hub

This fork implements every Jira story under the P2-107 epic exactly as written, on top of the latest baseline (which now includes operational areas, the bait-station export, and the super-admin reports view).

## Run order on a fresh database

```bash
psql -d tiaki -f sql/create_tables.sql
psql -d tiaki -f sql/populate_tables.sql
python run.py
```

The epic's schema (8 tables: `group_updates`, `group_update_photos`, `group_update_likes`, `group_update_comments`, `knowledge_categories`, `knowledge_articles`, `knowledge_article_photos`, `knowledge_article_versions`, `knowledge_moderation_log`, plus 3 enums) is now created directly inside `create_tables.sql` — the separate `group_updates_hub_migration.sql` file has been folded in.

## Story-by-story implementation map

### Group Updates

| Story | Implementation |
|---|---|
| Coordinator publishes a group update | `updates_new` accepts `action=publish`; `@role_required('Group Coordinator')` -- only coordinators of the active group; feed is ordered most-recent first, shows author + date |
| Coordinator saves an update as a draft | Same form, `action=draft`; drafts are excluded from the `updates_list` WHERE clause unless the viewer is a coordinator |
| Coordinator edits or removes an update | `updates_edit` / `updates_remove` -- the remove flips status to `'removed'` so the row + comments + likes stay for audit |
| Attach photos to an update | `_save_photos` saves to `static/images/uploads/`, validates extension via `allowed_file`, enforces 4 MB per file with a clear flash error; multi-file `<input type="file" multiple>`; existing photos can be removed via per-photo delete checkbox |
| Members view group updates | `updates_list` + `updates_detail` -- queries filter by `session['group_id']`, so a member of group A cannot see group B's updates even with a forged URL |
| Members like and comment on updates | Like-toggle is a POST to `updates_toggle_like` returning JSON `{ok, liked, count}`; the like button's text + colour + aria-pressed flip in-place. Comments polled via `updates_comments_json` every 30s, no page reload |
| Coordinator moderates comments | `updates_comment_remove` soft-deletes (`status='removed'`, `removed_by`, `removed_at`); the rendered list shows "[Removed by coordinator]" so the thread context survives |

### Shared Knowledge Hub

| Story | Implementation |
|---|---|
| Access the Shared Knowledge Hub | `hub_index` redirects to `select_group` if the user belongs to no group (`_user_in_any_group`); each article shows title, category, body, photos |
| Browse and search knowledge entries | `?q=term` triggers ILIKE across title, body, summary; empty state is explicit ("No articles match... Clear filters to see all") |
| Filter knowledge entries by category | `?category=<slug>` joins on `knowledge_categories`; combinable with `q`; "Clear filters" link resets both |
| Feature important knowledge entries | `hub_toggle_feature` flips `is_featured`; featured list rendered at top of index, marked with a star icon and accessible label |
| Member submits a knowledge entry for review | `hub_submit` creates the row with `status='pending_review'`, snapshots v1 into `knowledge_article_versions`, notifies the coordinators of the submitter's group |
| Coordinator reviews and approves or rejects submissions | `hub_moderation` lists pending; `hub_decision` flips to `published` (with `published_at`) or `rejected`; reason note stored on the article and logged to `knowledge_moderation_log` |
| Update and version a knowledge entry | `hub_edit` is open to coordinator/super-admin OR the original author; every save bumps `current_version`, inserts a row into `knowledge_article_versions`, logs a `versioned` row to the moderation log; latest version always shown by default; "last updated" date displayed in the header |

## Files added

- `sql/group_updates_hub_migration.sql`
- `app/updates_hub.py` (17 routes, ~900 lines)
- `app/templates/updates_hub/` (9 templates)
- `tests/test_updates_hub.py` (12 tests, all green)
- Nav additions in `_primary_nav_links.html` and `_nav_sidebar.html`

## Accessibility + polish

- Like button uses `aria-pressed` so screen readers announce state change.
- Every form input has `<label for>` + `required` + a visible asterisk + a hidden `aria-hidden="true"` on the asterisk so it isn't read twice.
- Removed comments stay visible as italic "[Removed by coordinator]" so reading order isn't broken.
- Search empty state is explicit and links back to the unfiltered hub.
- Image uploads are explicitly capped (4 MB) with a clear error -- AC says "reasonable file type and size limits with a clear error when exceeded".
- Submission status visible to the author at any time via `/hub/my-submissions`, including the reason note on rejected items.
