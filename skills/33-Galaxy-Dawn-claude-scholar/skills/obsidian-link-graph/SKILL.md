---
name: obsidian-link-graph
description: Use this skill when the user wants to repair or strengthen Obsidian wikilinks among existing canonical project notes, especially across papers, knowledge notes, experiments, results, and writing.
---

# Obsidian Link Graph

This is a **legacy compatibility helper**.

Despite the name, the current default workflow is **not** graph-heavy. Use this skill to repair navigation among existing canonical notes, not to generate graph artifacts by default.

## Responsibilities

- strengthen wikilinks among `00-Hub.md`, `01-Plan.md`, `Knowledge/`, `Papers/`, `Experiments/`, `Results/`, `Writing/`, and `Daily/`
- improve backlinks where a durable relationship is already clear
- help route a new reference to the best existing canonical note
- reduce disconnected durable notes without creating concept or dataset sprawl

## Link heuristics

- Prefer one canonical note per durable object.
- Link through stable project objects, not ad-hoc phrases.
- Avoid overlinking every paragraph; keep only meaningful edges.
- Prefer repairing existing links over creating new auxiliary notes.
- If the best target is unclear, narrow the search first and use `find-canonical-note` from `obsidian-project-memory` when helpful.

## Do not assume by default

- `Concepts/`
- `Datasets/`
- `Maps/`
- `Views/`
- `.canvas`
- `.base`

Create those only if the user explicitly asks for them.
