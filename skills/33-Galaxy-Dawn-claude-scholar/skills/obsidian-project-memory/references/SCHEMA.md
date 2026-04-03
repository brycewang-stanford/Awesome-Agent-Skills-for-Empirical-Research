# Obsidian Project Knowledge Base Schema

## Repository-local memory files

- `.claude/project-memory/registry.yaml` — registry keyed by `project_id`
- `.claude/project-memory/<project_id>.md` — compact project memory snapshot used on project turns

Note: `registry.yaml` is currently JSON-formatted on disk for historical compatibility.

Optional per-project registry fields:
- `note_language` — note language for generated/synced notes. Supported values: `en`, `zh-CN`.

Language resolution priority:
1. project config in `.claude/project-memory/registry.yaml`
2. environment variable `OBSIDIAN_NOTE_LANGUAGE`
3. default `en`

## Vault layout

```text
Research/{project-slug}/
  00-Hub.md
  01-Plan.md
  Knowledge/
  Papers/
  Experiments/
  Results/
    Reports/
  Writing/
  Daily/
  Archive/
```

## Role of each top-level location

- `00-Hub.md` — project homepage, current state, must-remember numbers, key links
- `01-Plan.md` — active goals, tasks, open questions, next actions
- `Knowledge/` — stable project understanding such as background, research questions, method survey, data protocol, source inventory
- `Papers/` — paper notes, literature summaries, related-work assets
- `Experiments/` — experiment designs, runbooks, ablations, mechanism studies
- `Results/` — canonical durable findings, diagnostics, figure/table indexes, cross-experiment conclusions
- `Results/Reports/` — internal experiment round reports and batch retrospectives with stable naming
- `Writing/` — paper drafting, slides, proposal text, rebuttal material
- `Daily/` — daily logs, lightweight sync queue, scratch notes, meeting fragments
- `Archive/` — inactive or historical material that should not stay in the main working surface

## Minimum note types

- `project`
- `daily`
- `paper`
- `experiment`
- `result`
- `results-report`
- `synthesis`
- `meta`
- `writing`
- `task`

## Main design rule

This schema is intentionally small. Prefer a few durable notes over many placeholder notes.
