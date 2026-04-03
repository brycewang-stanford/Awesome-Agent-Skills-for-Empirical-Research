# Meta-Governance: This Repository's Dual Nature

**This repository is BOTH a working project AND a template for others.**

Understanding this distinction is critical for deciding what to commit, what to document, and where to save learnings.

---

## The Two Identities

### Identity 1: Working Project
- We actively develop lecture slides, guides, and documentation
- We accumulate learnings specific to our setup and workflow
- We test new features and iterate on infrastructure
- We have institutional context (Emory, econometrics, specific tools)

### Identity 2: Public Template
- Others fork this repo to bootstrap their own academic workflows
- They use different domains (biology, physics, CS, not just economics)
- They use different tools (pure LaTeX, pure R, Python, Jupyter)
- They need generic patterns, not our specific decisions

---

## Decision Framework

When creating or modifying content, ask:

### "Is this GENERIC or SPECIFIC?"

**GENERIC (commit to repo, helps all users):**
- Workflow patterns (spec-then-plan, quality gates, orchestrator)
- Design principles (framework-oriented, progressive disclosure)
- Templates (requirements spec, constitutional governance, skill template)
- Documentation standards (update README+guide together)
- Rules that adapt to user context (path-scoped rules)

**SPECIFIC (keep local or gitignore):**
- Machine-specific paths (`TEXINPUTS=../Preambles` on macOS)
- Tool versions (`Quarto 1.3.x vs 1.4.x`)
- Institutional requirements (Emory thesis format)
- Personal preferences (90/100 quality gate for this project)
- API keys, credentials, local workarounds

---

## Memory Management: Two-Tier System

### MEMORY.md (root directory, committed)

**Purpose:** Generic learnings that help ALL users

**What goes here:**
- Workflow improvements: `[LEARN:workflow] Spec-then-plan reduces rework 30-50%`
- Design principles: `[LEARN:design] Framework-oriented > prescriptive rules`
- Documentation patterns: `[LEARN:documentation] Update README+guide together`
- Quality standards: `[LEARN:quality] 80/90/95 thresholds work across domains`

**Review cadence:** After every significant session (plan approval, feature implementation)

**Size limit:** Keep under 200 lines (stays in Claude's system prompt)

---

### .claude/state/personal-memory.md (gitignored, local only)

**Purpose:** Machine-specific and user-specific learnings

**What goes here:**
- Machine setup: `[LEARN:latex] XeLaTeX on macOS requires TEXINPUTS=../Preambles`
- Tool quirks: `[LEARN:quarto] Version 1.4.x has nested div bug, use 1.3.x`
- Local paths: `[LEARN:files] Bibliography at ~/Dropbox/References/main.bib`
- Personal workflow: `[LEARN:workflow] I prefer 90/100 for lecture slides, 80/100 for explorations`

**Review cadence:** As needed (no pressure to formalize)

**Size limit:** None (doesn't load into context automatically)

---

## Cross-Machine Access

### Scenario: User Works on Multiple Machines

**Machine A (office desktop):**
- Clone repo → gets MEMORY.md with generic learnings ✓
- Gets all infrastructure (skills, agents, rules, templates) ✓
- Gets up-to-date guide and documentation ✓
- Builds `.claude/state/personal-memory.md` specific to desktop setup

**Machine B (laptop):**
- Clone same repo → gets same MEMORY.md ✓
- Gets same infrastructure ✓
- Builds DIFFERENT `.claude/state/personal-memory.md` for laptop setup

**Key insight:** Generic patterns sync via git, personal patterns stay local (or manually copied if truly needed).

---

## Dogfooding: Following Our Own Guide

**We must follow the patterns we recommend to users.**

### Plan-First Workflow
✅ Do: Enter plan mode for non-trivial tasks (>3 files, >1 hour, multi-step)
✅ Do: Save plans to `quality_reports/plans/YYYY-MM-DD_description.md`
❌ Don't: Skip planning for "quick fixes" that turn into multi-hour tasks

### Spec-Then-Plan
✅ Do: Create requirements specs for complex/ambiguous tasks
✅ Do: Use MUST/SHOULD/MAY framework with clarity status
❌ Don't: Jump straight to planning when requirements are fuzzy

### Quality Gates
✅ Do: Run quality scoring before commits
✅ Do: Nothing ships below 80/100
❌ Don't: Commit "WIP" code without quality verification

### Documentation Standards
✅ Do: Update README and guide together when adding features
✅ Do: Keep dates current (frontmatter, "Last Updated" fields)
❌ Don't: Let documentation drift from implementation

### Context Survival
✅ Do: Update MEMORY.md with [LEARN] entries after sessions
✅ Do: Save active plans to disk before compression
✅ Do: Keep session logs current (last 10 minutes)
❌ Don't: Rely solely on conversation history (it compresses)

---

## Template Maintenance Principles

### Keep It Generic

**Bad (too specific):**
```markdown
# Beamer Compilation Rule
Always use XeLaTeX with TEXINPATHS=../Preambles for Emory slides.
```

**Good (framework-oriented):**
```markdown
# LaTeX Compilation Rule
Use project-specific TEXINPATHS if preambles are in separate directory.
Configure in CLAUDE.md for your setup.
```

### Provide Examples from Multiple Domains

**Bad (single use case):**
```markdown
Example: Econometric panel data analysis
```

**Good (diverse use cases):**
```markdown
Examples:
- Econometrics: Panel regression with fixed effects
- Biology: Lab protocol validation
- Physics: Numerical simulation workflow
```

### Use Templates Not Prescriptions

**Bad (prescriptive):**
```markdown
Your bibliography MUST be named Bibliography_base.bib and live in root.
```

**Good (template with placeholders):**
```markdown
Configure bibliography location in CLAUDE.md:
[YOUR_BIB_FILE] (e.g., Bibliography_base.bib, refs.bib, ../library.bib)
```

---

## When to Make Exceptions

### Templates Can Show Specific Examples

It's okay for README and guide to say:
> "This workflow was developed for Econ 730 at Emory University..."

As long as it's clear this is ONE example, not THE requirement.

### CLAUDE.md Can Have Placeholders

The template CLAUDE.md has `[YOUR PROJECT NAME]`, `[YOUR INSTITUTION]` — this is correct. Users fill them in.

### Documentation Can Reference Original Use Case

Pedagogically valuable to show real-world example:
> "Case Study: 6 lectures, 800+ slides, Beamer + Quarto + R replication"

This shows what's POSSIBLE, not what's REQUIRED.

---

## Amendment Process

As this repository evolves, meta-governance may need updates.

**When to amend this file:**
- We discover better ways to distinguish generic vs specific
- Cross-machine workflows change (e.g., Claude Code adds cloud sync)
- Memory system evolves (e.g., automatic [LEARN] extraction)
- User feedback reveals confusion about template vs working project

**Amendment protocol:**
1. Propose change in session log or plan
2. Discuss implications (what breaks? what improves?)
3. Update this file
4. Document change with [LEARN:meta-governance] entry in MEMORY.md

---

## Quick Reference Table

| Content Type | Commit to Repo? | Where It Goes | Syncs Across Machines? |
|--------------|----------------|---------------|----------------------|
| Workflow patterns (generic) | ✅ Yes | MEMORY.md | ✅ Yes (via git) |
| Machine-specific setup | ❌ No | .claude/state/personal-memory.md | ❌ No (gitignored) |
| Templates (generic) | ✅ Yes | templates/ | ✅ Yes |
| Skills (generic) | ✅ Yes | .claude/skills/ | ✅ Yes |
| Rules (path-scoped, generic) | ✅ Yes | .claude/rules/ | ✅ Yes |
| Agents (generic) | ✅ Yes | .claude/agents/ | ✅ Yes |
| Hooks (generic behavior) | ✅ Yes | .claude/hooks/ | ✅ Yes |
| Session logs | ✅ Yes | quality_reports/session_logs/ | ✅ Yes |
| Plans | ✅ Yes | quality_reports/plans/ | ✅ Yes |
| Local settings | ❌ No | .claude/settings.local.json | ❌ No (gitignored) |
| Session state | ❌ No | .claude/state/ | ❌ No (gitignored) |
| Build artifacts | ❌ No | .aux, .log, .synctex.gz | ❌ No (gitignored) |

---

## Summary

**This repository serves two masters:**
1. Our working project (specific, contextual, evolving)
2. A template for others (generic, framework-oriented, stable)

**The solution:**
- Commit generic patterns that help all users (MEMORY.md, templates, infrastructure)
- Keep specific learnings local (.claude/state/personal-memory.md, gitignored)
- Dogfood our own workflow (plan-first, spec-then-plan, quality gates)
- Document with examples from multiple domains (not just our use case)
- Review quarterly: promote generic patterns, refine specific ones

**When in doubt:** Ask "Would a biology PhD student forking this repo for lab protocols benefit from this knowledge?" If yes → MEMORY.md. If no → personal-memory.md.
