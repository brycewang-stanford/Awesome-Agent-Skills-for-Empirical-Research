---
name: obsidian-experiment-log
description: Use this skill when the user discusses experiment design, ablations, training runs, evaluation, baselines, metrics, failures, or result interpretation that should be logged into Obsidian experiment and result notes.
---

# Obsidian Experiment Log

Use this skill whenever project work changes the experimental state.

## Role in the workflow

This is a **supporting skill** under `obsidian-project-memory`.

It should help maintain canonical experiment and result notes, not create note sprawl.

## Default outputs

- the relevant canonical note in `Experiments/`
- the relevant canonical note in `Results/`, if a durable finding exists
- links from today's `Daily/` note
- relevant hub or plan references only when project state materially changes

## Main rules

- Prefer updating an existing experiment note over creating a sibling note for the same experiment line.
- Prefer updating an existing result note over creating a parallel result page for the same durable finding.
- Raw logs, metric dumps, and temporary analysis fragments should usually stay in `Daily/` until they are interpreted.
- A result note should exist only when the outcome is stable enough to reference later.

## Minimum experiment sections

- Goal / hypothesis
- Code or config entrypoint
- Dataset / split
- Metrics
- Status (`planned`, `running`, `done`, `failed`)
- Findings / notes
- Next step

## Minimum result sections

- Linked experiment
- Main observation
- Key numbers
- Evidence
- Interpretation
- Decision: keep / iterate / discard

## Linking rule

Link experiments and results directly to each other, and link both back to `00-Hub.md`, `01-Plan.md`, or `Daily/` only when those references improve the main working surface.


## Research path handoff

Treat experiment notes as the bridge between `Papers/` and `Results/`:
- paper-derived hypotheses, baselines, and ablations should land here,
- stable findings should be promoted from here into `Results/`,
- when a result becomes claim-worthy, update `Writing/` rather than leaving the chain unfinished.
