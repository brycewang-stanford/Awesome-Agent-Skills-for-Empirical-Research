# Script vs Agent Boundary

Use this guide to decide whether a task belongs in `project_kb.py` or must remain agent-driven.

## Good fit for the script

These tasks are low-freedom, deterministic, and should behave the same every time:

- detect whether a repo is bound to a project vault
- bootstrap the standard vault structure
- sync repo-driven state into daily, hub, plan, memory, and auto-sync notes
- list or suggest the canonical notes to read for a question shape
- archive, purge, or rename a single note with direct-link repair in explicit index notes
- maintain source inventory and codebase overview

Current script-facing commands:
- `detect`
- `bootstrap`
- `sync`
- `lifecycle`
- `query-context`
- `find-canonical-note`
- `note-lifecycle`

## Must stay with the agent

These tasks require semantic judgment and should not be hard-coded into the script:

- deciding whether a new Markdown file is durable knowledge or raw material
- deciding whether to promote, merge, or stage a new Markdown file
- deciding which existing note is the canonical note when multiple semantic candidates exist
- synthesizing background from many project documents
- interpreting experimental meaning or result significance
- deciding whether a note should be split or merged based on conceptual overlap
- deciding whether a result is stable enough for `Results/`

## Practical rule

If the task can be framed as:

- “find”, “move”, “rename”, “archive”, “sync”, or “suggest reads”

it is probably script-suitable.

If the task can be framed as:

- “understand”, “interpret”, “decide meaning”, “summarize”, “merge concepts”, or “promote to durable knowledge”

it should remain agent-driven.
