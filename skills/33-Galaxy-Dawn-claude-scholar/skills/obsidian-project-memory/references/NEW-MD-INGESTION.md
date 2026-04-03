# New Markdown Ingestion

Use this guide when a new Markdown file appears and should be considered for the knowledge base.

## Three-step decision

### 1. Classify

Classify the file as one of:
- `knowledge`
- `paper`
- `experiment`
- `result`
- `writing`
- `daily`

### 2. Decide: durable note or raw material

Treat it as a **durable note** only if it is already:
- complete enough to stand on its own,
- stable in scope,
- likely to be referenced later.

Otherwise treat it as **raw material**.

### 3. Choose the action

Choose one of these:

- **promote**
  - use only when the file is already a stable, complete, long-lived note
- **merge**
  - use when it supplements an existing canonical note for the same object
- **stage-to-daily**
  - use when it is still unstable, incomplete, or not worth promoting yet

Default answer: **summarize first, then route**.

## Examples

### New paper summary

- likely classification: `paper`
- if complete and stable -> promote to `Papers/`
- if partial reading notes for an existing paper note -> merge

### New experiment plan

- likely classification: `experiment`
- if it defines a distinct experiment line -> promote to `Experiments/`
- if it refines an existing experiment -> merge into that note

### New result memo

- likely classification: `result`
- if it contains a durable conclusion with evidence -> promote to `Results/`
- if it is a full internal experiment summary report -> promote to `Results/Reports/` using the stable naming contract
- if it is still exploratory -> stage in `Daily/` or merge into the existing experiment note first

### New meeting note

- likely classification: `daily`
- default -> stage in `Daily/`
- promote only if the meeting produced a stable decision that belongs in `Knowledge/`, `Experiments/`, or `Writing/`

### New scratch idea

- likely classification: `daily` or `knowledge`
- default -> stage in `Daily/`
- promote later only if it becomes a stable research question, method direction, or experiment plan


### Cross-stage routing hint

When a new file is about papers, experiments, results, or writing, do not stop at file classification alone. Also ask whether it clearly implies the next durable handoff:

- paper note -> should an experiment note be updated?
- experiment note -> is there already a stable finding that belongs in `Results/`?
- result memo -> does a writing note need an update?

If that next handoff is already clear, prefer updating the downstream canonical note in the same turn.
