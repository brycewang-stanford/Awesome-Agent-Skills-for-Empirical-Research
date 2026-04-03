---
description: Three-phase proofreading — agent proposes, user approves, then agent applies. Never auto-edits prose.
paths:
  - "**/*.tex"
  - "**/*.qmd"
---

# Writing Review Protocol (MANDATORY)

**Every file intended for an audience MUST be reviewed before any commit or PR.**

**CRITICAL RULE: The agent must NEVER apply changes directly. It proposes all changes for review first.**

## What the Agent Checks

1. **Grammar** -- subject-verb agreement, missing articles, wrong prepositions
2. **Typos** -- misspellings, search-and-replace corruption, duplicated words
3. **Layout issues** -- overfull hbox (LaTeX), content exceeding slide boundaries (Quarto), table/column overflow in manuscripts
4. **Consistency** -- notation, citation style (`\citet` vs `\citep`, `[@key]`), terminology, variable names in prose matching table column names
5. **Academic quality** -- informal abbreviations, missing words, awkward phrasing

## Three-Phase Workflow

### Phase 1: Review & Propose (NO EDITS)

The agent:
1. Reads the entire file
2. Produces a **report** with every proposed change:
   - Location (line number or section heading)
   - Current text
   - Proposed fix
   - Category (grammar / typo / layout / consistency)
3. Saves report to `quality_reports/` (e.g., `quality_reports/[filename]_report.md`)
4. **Does NOT modify any source files**

### Phase 2: Review & Approve

The user reviews the proposed changes:
- Accepts all, accepts selectively, or requests modifications
- **Only after explicit approval** does the agent proceed

### Phase 3: Apply Fixes

Apply only approved changes:
- Use Edit tool; use `replace_all: true` for issues with multiple instances
- Verify each edit succeeded
- Report completion summary
