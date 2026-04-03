---
name: obsidian-synthesis-map
description: Use this skill when generating higher-level synthesis notes such as literature reviews, comparison matrices, project summaries, or other cross-note summaries inside the project knowledge base.
---

# Obsidian Synthesis Map

This is a **legacy compatibility helper**.

Despite the name, the current default workflow focuses on **synthesis notes**, not Bases or Canvas artifacts.

## Default outputs

- `Writing/` synthesis notes
- project summaries tied to `Knowledge/`, `Papers/`, `Experiments/`, and `Results/`
- comparison notes that help writing, planning, or result interpretation

## Guidelines

- Use `obsidian-project-memory` as the main workflow authority.
- Use `$obsidian-markdown` for note quality.
- Keep synthesis notes anchored to real papers, experiments, results, and project questions via wikilinks.
- Prefer one durable synthesis note per purpose instead of many overlapping summaries.
- If the user explicitly asks for `.base` or `.canvas` artifacts, treat them as optional add-ons, not default outputs.

## Default stance

Do **not** generate:
- `Views/*.base`
- `Maps/*.canvas`

unless the user explicitly asks for those artifacts.
