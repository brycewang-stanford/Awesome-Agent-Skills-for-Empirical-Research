# Agent-First Import

## When to use this workflow

Use agent-first import when:
- a repository already contains substantial project documents,
- the user says the knowledge base lacks background,
- multiple sources must be combined into a stable project summary,
- the project needs a real overview instead of a folder skeleton.

## Recommended source-reading order

Read only the most informative sources first:

1. `README.md` if it is meaningful
2. `plan/` or `docs/` design notes
3. `outputs/analysis/` reports and summaries
4. `run/conf/` for task protocol and experimental assumptions
5. `src/analysis_module/` or other orchestration code for analysis modes
6. `TODO.md` or scratch notes only as supplemental context

## What the agent should extract

Ask the agent to produce these sections:
1. project background and research goal
2. core research questions
3. current main experiment lines
4. key results and conclusions
5. codebase-to-knowledge-base mapping
6. recommended durable notes to create or update
7. top content for `00-Hub.md`

## After the agent returns

Do not paste the entire agent response into the vault.

Instead:
- convert the synthesis into durable notes,
- keep one idea per note,
- put high-level framing in `Knowledge/`,
- put experiment logic in `Experiments/`,
- put findings in `Results/`,
- put literature-facing material in `Papers/`.

## Anti-pattern

Do not treat file paths as meaning.

Examples of bad behavior:
- mapping every `plan/*.md` file into a one-to-one note automatically,
- generating empty notes because a folder exists,
- creating new notes before understanding which sources matter.
