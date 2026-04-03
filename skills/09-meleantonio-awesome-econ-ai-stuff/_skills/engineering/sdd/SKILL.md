---
name: sdd
description: >
  Implements the Spec-Driven Development lifecycle (Intent, Requirements, Design, Tasks, Build)
  for structured feature development. Use when the user wants to scaffold a new feature spec,
  generate EARS requirements, create a technical design, break work into tasks, or check spec status.
  Trigger on keywords: sdd, spec-driven, ears requirements, feature spec.
workflow_stage: engineering
compatibility:
  - claude-code
  - cursor
  - codex
  - gemini-cli
author: Awesome Econ AI Community
version: 1.0.0
tags:
  - spec-driven-development
  - requirements
  - design
  - documentation
---

# Spec-Driven Development (SDD)

## Core Philosophy

1. **Clarity before Code:** Never generate code until requirements and design are approved.
2. **Iterative Refinement:** Loop through Req → Design → Tasks until solid.
3. **Code via Docs:** The truth is in the markdown files, not the chat.

## Commands

Execute in the **project root** (where `spec/` and `steering/` live).

### `init`

Scaffold the SDD folder structure and template files.

1. If `spec/` already exists, skip or ask before overwriting.
2. Create `spec/` and `steering/`.
3. Create `spec/intent.md` (blank or minimal placeholder).
4. Copy templates from this skill’s `templates/` directory (in the same folder as `SKILL.md`, or from your install path under `~/.cursor/skills/sdd/` after copying the skill there) into the project:
   - `templates/spec/requirements.md` → `spec/requirements.md`
   - `templates/spec/design.md` → `spec/design.md`
   - `templates/spec/tasks.md` → `spec/tasks.md`
   - `templates/steering/coding-standards.md` → `steering/coding-standards.md`

### `reqs`

Generate EARS requirements from intent.

1. Read `spec/intent.md` and `steering/*.md`.
2. Convert the intent into EARS requirements (see EARS Quick Reference below). Add a Properties (invariants) section.
3. Write to `spec/requirements.md`.
4. Ask for user approval before proceeding.

### `design`

Generate technical design from requirements.

1. Read `spec/requirements.md` and `steering/*.md`.
2. Create a technical design: architecture, data models, component interfaces, error handling, security. Apply the Design Checklist below.
3. Write to `spec/design.md`.
4. Ask for user approval before proceeding.

### `tasks`

Generate implementation tasks from design.

1. Read `spec/design.md` and `spec/requirements.md`.
2. Create a sequential task list: max two levels (Task > Subtask). Link each task to requirement IDs (e.g. `REQ-001`). Follow Task Rules below.
3. Write to `spec/tasks.md`.
4. Ask for user approval before proceeding.

### `status`

Report current state of the spec.

1. List files in `spec/` (and optionally `steering/`).
2. If `spec/tasks.md` exists, count unchecked `[ ]` vs checked `[x]` and summarize.

## EARS Quick Reference

- **Ubiquitous:** `<system> shall <response>`
- **Event-Driven:** `WHEN <trigger> [precondition] the <system> shall <response>`
- **Unwanted:** `IF <unwanted condition> THEN the <system> shall <response>`
- **State-Driven:** `WHILE <system state>, the <system> shall <response>`
- **Optional:** `WHERE <feature is included>, the <system> shall <response>`

Use IDs like `[REQ-001]`; add a **Properties (Invariants)** section for universal correctness statements.

## Design Checklist

- Edit ruthlessly (remove over-engineering).
- Check for circular dependencies; fix via interface extraction, layering, or events.
- Ensure alignment with steering documents.

## Task Rules

- Two-level hierarchy maximum (Task > Subtask).
- Sequential order (each task builds on previous).
- Traceability: each task or subtask links back to requirement IDs (e.g. *Traceability:* Implements `REQ-001`).

## Additional Resources

- For full framework detail (workflow, refinement, iteration triggers), see [reference.md](reference.md).
