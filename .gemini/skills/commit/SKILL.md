---
name: commit
description: Use this skill to create focused, logical git commits by grouping related changes together. Triggered by requests to commit changes or "wrap up" work.
---

# Commit Skill

Analyze all current git changes and create multiple focused commits by grouping related changes together.

## Steps

1. Run `git status` and `git diff` to identify all unstaged and staged changes.
2. Analyse the changes and group them by logical concern (e.g. feature additions, bug fixes, config changes, documentation updates, styling).
3. For each group, stage only the relevant files using `git add <files>`.
4. Write a commit message following the template below, then commit.
5. Repeat for each group until all changes are committed.

## Commit Message Template

```
<type>/ <subject>
```

Where `<type>` is one of:
- `feat` — a new feature
- `fix` — a bug fix
- `docs` — documentation changes (README, assignment notes, etc.)
- `style` — formatting/style-only changes (no logic changes)
- `refactor` — code changes that neither fix a bug nor add a feature
- `test` — adding or updating tests
- `chore` — build/config/dependency/maintenance tasks

## Commit Message Rules

- Use UK English.
- Use imperative mood (e.g., "Add observer role to database").
- Start subject with uppercase.
- No trailing period.
- Keep subject within 72 characters.
- Do NOT group unrelated changes into one commit just to reduce the number of commits.

## Example

If there are changes to a new login feature, a README update, and a config file fix, create three separate commits:
- `feat/ Add login form validation`
- `docs/ Update README with setup instructions`
- `chore/ Fix database config for local environment`
