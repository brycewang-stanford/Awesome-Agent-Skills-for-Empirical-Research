# Meta-Governance: This Repository's Dual Nature

This repository is both a working project and a public template for empirical social science research (economics, finance, marketing, management, accounting, public policy).

## Working Project
- We develop research papers, seminars, guides, and documentation
- We accumulate project-specific learnings and institutional context (UAB)
- We test and iterate on the architecture itself

## Public Template
- Others fork this repo to run their own research workflows
- They share the same pipeline (identify → estimate → write → submit) and tools (LaTeX, R/Stata/Python, Beamer)
- Field-specific differences (journals, methods, conventions) are handled by `.claude/references/domain-profile.md` and `.claude/references/journal-profiles.md`

## The One Rule

Before committing, ask: **would another empirical researcher forking this repo benefit from this?**

- **Yes** → commit (workflow patterns, skills, agents, rules, templates)
- **No** → keep local in `.claude/state/` (machine paths, tool versions, institutional requirements, API keys)
