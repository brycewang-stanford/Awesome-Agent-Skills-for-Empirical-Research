# Bootstrap Runbook

## Preflight decisions

1. Run `detect` first.
2. If the repo is already bound, stop and reuse the existing project.
3. If the repo is not research-like, stop and ask for confirmation instead of forcing bootstrap.
4. If `OBSIDIAN_VAULT_PATH` is missing, request it explicitly.

## Common failure modes

- `vault path missing` -> require explicit path or environment variable.
- `already bound` -> do not rebuild by default.
- `repo not research-like` -> do not create a vault structure automatically without confirmation.
- `python interpreter mismatch` -> run with the available interpreter and state the path used.

## Post-bootstrap verification

Check for these minimum artifacts:
- `.claude/project-memory/registry.yaml`
- `.claude/project-memory/<project_id>.md`
- `Research/{project-slug}/00-Hub.md`
- `Research/{project-slug}/01-Plan.md`
- `Research/{project-slug}/Knowledge/Source-Inventory.md`
- `Research/{project-slug}/Knowledge/Codebase-Overview.md`

If the project still feels empty after bootstrap, continue with agent-first synthesis instead of adding placeholder notes.
