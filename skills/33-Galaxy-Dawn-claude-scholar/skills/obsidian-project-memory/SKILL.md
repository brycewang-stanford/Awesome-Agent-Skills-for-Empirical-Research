---
name: obsidian-project-memory
description: This skill should be used when the user asks to maintain an Obsidian knowledge base for a research project, import an existing research repository into Obsidian, keep project memory or daily notes synchronized, summarize project context into durable notes, or update experiments, results, papers, writing, and plans in an Obsidian vault without requiring MCP.
---

# Obsidian Project Memory

Maintain a **filesystem-first, agent-driven** Obsidian knowledge base for a research project.

Default note output language follows the project's configured `note_language`; if no note language is configured, default to **English**. Keep technical terms, paper titles, and established folder names in their original form when that is clearer. Only switch note prose to another language when the user explicitly asks.

Prefer this skill when working inside a repository that:
- already contains `.claude/project-memory/registry.yaml`, or
- clearly looks like a research project and should be bound to an Obsidian vault.

## Core principles

- Use **scripts for project state management**.
- Use **agents for project understanding and synthesis**.
- Write only **durable research knowledge** into a **small vault structure**.
- Do **not** require MCP, API keys, REST plugins, or `.base` artifacts.
- Do not depend on `.canvas` globally, but allow literature workflows to maintain `Maps/literature.canvas` as a default literature graph artifact.
- Treat internal experiment summary reports as **durable result-facing notes** under `Results/Reports/`, not as `Writing/` notes.

## Default vault structure

Write into this project layout only:

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

Read [references/SCHEMA.md](references/SCHEMA.md) for the exact structure and note roles.

## Deterministic helper script

Use `scripts/project_kb.py` only for low-freedom operations such as detect, bootstrap, sync, and lifecycle management:

```bash
python3 scripts/project_kb.py detect --cwd "$PWD"
python3 scripts/project_kb.py bootstrap --cwd "$PWD" --vault-path "$OBSIDIAN_VAULT_PATH"
python3 scripts/project_kb.py sync --cwd "$PWD" --scope auto
python3 scripts/project_kb.py lifecycle --cwd "$PWD" --mode archive
python3 scripts/project_kb.py query-context --cwd "$PWD" --kind broad
python3 scripts/project_kb.py query-context --cwd "$PWD" --kind experiment --query freezing
python3 scripts/project_kb.py find-canonical-note --cwd "$PWD" --kind experiment --query freezing
python3 scripts/project_kb.py note-lifecycle --cwd "$PWD" --mode archive --note "Results/Old-Result.md"
```

Do **not** expect the script to understand project meaning. It manages state; it does not replace synthesis.

Read [references/SCRIPT-VS-AGENT.md](references/SCRIPT-VS-AGENT.md) when deciding whether a task belongs in the script or must stay agent-driven.

## Default workflow

### 1. Detect and bind

1. Run `scripts/project_kb.py detect --cwd "$PWD"`.
2. If the repo is already bound, continue with the existing project.
3. If the repo is not yet bound but is a strong research-project candidate, bootstrap it with `project_kb.py bootstrap`.

For the detailed lifecycle, read [references/WORKFLOW.md](references/WORKFLOW.md).

### 2. Read the minimum context

Before writing anything, read only the minimum stable context:
- `.claude/project-memory/<project_id>.md`
- `00-Hub.md`
- `01-Plan.md`
- today's `Daily/YYYY-MM-DD.md` if it exists

If the task is about project understanding, existing docs, or historical results, load more context selectively using the references below.

### 3. Classify the knowledge delta

Route the current turn into one or more of these buckets:
- `knowledge`
- `paper`
- `experiment`
- `result`
- `writing`
- `daily`
- `project-structure`

Read [references/NOTE-ROUTING.md](references/NOTE-ROUTING.md) before writing.

### 4. Follow the default durable research path

Default path for substantive research work:
- `Papers/` -> extract reusable ideas, baselines, and project relevance
- `Experiments/` -> turn those into testable hypotheses, runbooks, or ablations
- `Results/` -> promote stable findings with evidence and interpretation
- `Results/Reports/` -> store one round or one batch's internal experiment report when a complete retrospective has been written
- `Writing/` -> externalize durable claims into reviews, proposals, drafts, slides, or rebuttal notes

Use `Daily/` as chronology and staging, not the final home for durable research knowledge.

Read [references/PAPERS-TO-WRITING.md](references/PAPERS-TO-WRITING.md) when deciding how a turn should advance along this path.

### 5. Decide whether agent-first synthesis is required

Use **agent-first import/synthesis** when:
- importing an existing repository for the first time,
- the user says the knowledge base is empty or lacks background,
- multiple source documents must be synthesized into stable project knowledge,
- the project needs a durable overview, research questions, experiment map, or results summary.

In these cases, first use an agent to read key sources, then write the synthesized result back into Obsidian.

Read [references/AGENT-FIRST-IMPORT.md](references/AGENT-FIRST-IMPORT.md) for the recommended source-reading order.

### 6. Write back minimally

Always keep write-back conservative.

Write back at least:
- today's `Daily/YYYY-MM-DD.md` when this turn changes project state,
- `00-Hub.md` only when recent progress or top-level status truly changes,
- `.claude/project-memory/<project_id>.md` when project state changes.

Then write only the durable note that matches the bucket:
- `knowledge` -> `Knowledge/`
- `paper` -> `Papers/`
- `experiment` -> `Experiments/`
- `result` -> `Results/`
- `writing` -> `Writing/`
- `daily` -> `Daily/`
- `project-structure` -> usually `Knowledge/Project-Overview.md` or `Knowledge/Source-Inventory.md`

Internal experiment round reports should default to:
- `Results/Reports/YYYY-MM-DD--{experiment-line}--r{round}--{purpose}.md`

Read [references/NOTE-TEMPLATES.md](references/NOTE-TEMPLATES.md) when a note needs a stable shape.

## Knowledge CRUD rules

Treat the vault as a small set of **canonical notes** plus supporting daily context.

### Create

- Ingest new knowledge deliberately; do not equate every new Markdown file with a durable note.
- Keep **one canonical note per durable object** whenever possible:
  - one stable project overview,
  - one stable experiment note per experiment line,
  - one stable result note per durable finding,
  - one stable paper note per paper.
- For new Markdown files, default to **summarize first, then route**:
  - promote directly only when the file is already stable and self-contained,
  - otherwise merge into an existing canonical note or stage it in `Daily/`.
- If the new durable object is a full internal experiment report, store it under `Results/Reports/` and link the matching `Experiments/` and canonical `Results/` notes.

### Read

- Query narrowly first:
  - broad project questions -> `00-Hub.md` + key `Knowledge/` notes,
  - active work questions -> `01-Plan.md` + today's `Daily/` + project memory,
  - specific experiment/result/paper questions -> the matching canonical note first,
  - specific internal experiment retrospective -> the matching note in `Results/Reports/` first.
- Use agent synthesis only when the answer spans multiple durable sources or still depends on repo material after reading canonical notes.

### Update

- Prefer **updating** an existing canonical note over creating a sibling note.
- Treat raw material as input, not as a final vault object.
- Allow fast append-only logging in `Daily/`, but keep durable knowledge in `Knowledge/`, `Papers/`, `Experiments/`, `Results/`, `Results/Reports/`, or `Writing/`.

### Delete

- Treat “remove”, “delete”, or “stop using” as **archive by default**.
- Purge only when the user explicitly asks for permanent deletion.
- When archiving or purging a durable note, repair direct links in `00-Hub.md`, `01-Plan.md`, and explicit index notes so the main working surface does not point to missing files.

## Safety rules

- Do not mirror the whole repository into the vault.
- Do not generate empty folder taxonomies or placeholder notes without real content.
- Do not write every repo delta into a new note.
- Do not treat every code change as a knowledge update.
- Do not create `.base` files unless the user explicitly asks for them.
- Do not create arbitrary `.canvas` sprawl; the main default exception is `Maps/literature.canvas` for literature workflows.
- For engineering-only turns, prefer `Daily/` plus project memory unless there is a real experiment, result, or planning impact.
- Treat “remove project knowledge” as **archive** by default; purge only when the user explicitly asks for permanent deletion.

## Reference files

Load only what is needed:
- `references/SCHEMA.md` - vault structure and note roles
- `references/WORKFLOW.md` - detect/bootstrap/sync/archive workflow
- `references/PAPERS-TO-WRITING.md` - default handoff from literature to experiments, results, and writing
- `references/SCRIPT-VS-AGENT.md` - boundary between low-freedom script operations and agent-only reasoning
- `references/KNOWLEDGE-CRUD.md` - create/read/update/delete rules for durable research knowledge
- `references/NOTE-ROUTING.md` - where each kind of knowledge should go
- `references/NEW-MD-INGESTION.md` - how to ingest a newly created Markdown file
- `references/AGENT-FIRST-IMPORT.md` - how to import an existing project with agent synthesis
- `references/NOTE-TEMPLATES.md` - lightweight note shapes for common note types
