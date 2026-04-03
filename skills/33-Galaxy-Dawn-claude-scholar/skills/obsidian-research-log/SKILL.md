---
name: obsidian-research-log
description: Use this skill when the user is discussing daily research work, TODOs, plans, standups, meetings, milestones, or general project progress that should be reflected in Obsidian daily notes, plan notes, and hub updates.
---

# Obsidian Research Log

Use this skill to keep project planning and daily progress synchronized.

## Role in the workflow

This is a **supporting skill** under `obsidian-project-memory`.

Prefer a small number of durable updates over creating extra planning folders.

## Default targets

- `Daily/YYYY-MM-DD.md`
- `01-Plan.md`
- `00-Hub.md` recent progress block
- `.claude/project-memory/<project_id>.md`

## Rules

- Convert vague TODOs into concrete checkbox lists in `01-Plan.md` when they become durable commitments.
- Preserve chronology in `Daily/`: append dated blocks instead of rewriting history.
- Link daily notes to touched experiments, papers, results, and writing notes when the destination is already canonical.
- If a meeting note is only temporary, keep it in `Daily/` first.
- If meeting output becomes durable project knowledge, summarize and route it into `Knowledge/`, `Writing/`, or `01-Plan.md` instead of creating a default `Meetings/` folder.
- Prefer updating existing canonical notes over spawning parallel task notes.

## Main judgment rule

Daily logs are for process.

If a note will still matter after several days or weeks, promote the durable part into `Knowledge/`, `Experiments/`, `Results/`, or `Writing/`.
