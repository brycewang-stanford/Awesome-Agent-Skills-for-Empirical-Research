---
name: proofread
description: Proofread the sewage-house-prices manuscript. Checks 6 categories — structure, claims-evidence alignment, identification fidelity, writing quality, grammar, and compilation. Produces a scored report without editing files. This skill should be used when asked to "proofread", "review the paper", "check the manuscript", or "quality check".
argument-hint: "[filename, section number, or 'all']"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Agent"]
---

# Proofread Manuscript

Run the proofreading protocol on the "Sewage in Our Waters" manuscript. Produces a report — does NOT edit source files.

**Input:** `$ARGUMENTS` — a `.tex` filename, section number (e.g. `01`), or `all`.

---

## Project-Specific Context

### File Locations
- Manuscript sections: `docs/overleaf/*.tex`
- Main document: `docs/overleaf/_main.tex`
- Bibliography: `docs/overleaf/refs.bib`
- Generated tables: `output/tables/*.tex` (tabularray format)
- Generated figures: `output/figures/`
- Quarto book: `book/*.qmd` (for cross-referencing analysis)
- Analysis scripts: `scripts/R/09_analysis/` (for methodology verification)

### Key Checks Specific to This Project
- Spill count/hours metrics must match the 12/24-hour counting methodology
- Radius distances (250m-10km) must be consistent across sections
- LSOA vs MSOA fixed effects must be correctly stated
- Upstream/downstream directionality must match river network logic
- Dry spill definition must be consistent with rainfall threshold used

---

## Workflow

### Step 1: Identify Files

- If `$ARGUMENTS` is a specific `.tex` file: review that file
- If `$ARGUMENTS` is a section number (e.g. `01`): review `docs/overleaf/0X_*.tex`
- If `$ARGUMENTS` is `all`: review `_main.tex` and all section files in `docs/overleaf/`
- If `$ARGUMENTS` is a `.qmd` file: review as **advisory** (non-blocking)

### Step 2: Run 6-Category Review

#### Category 1: Structure
- Contribution clearly stated within first 2 pages of introduction
- Standard economics paper sequence (intro → background → data → method → results → conclusion)
- Smooth transitions between sections
- Road map in introduction matches actual section ordering
- Appendix sections properly referenced from main text

#### Category 2: Claims-Evidence Alignment
- Every stated effect size matches a number in `output/tables/`
- Percentage impacts correctly computed from log coefficients
- Sample sizes and time periods match data pipeline output
- Radius distances in text match those in tables
- "Significant" claims match actual p-values / confidence intervals

#### Category 3: Identification Fidelity
- Hedonic specification matches what `scripts/R/09_analysis/02_hedonic/` actually estimates
- Repeat sales approach correctly described per Palmquist (1982)
- Long difference specification matches grid-level scripts
- DiD/event study timing and treatment definitions consistent
- Instrument (hydraulic capacity) described consistently with `04_hydraulics_instrument.tex`
- Dry spill identification matches rainfall threshold in data pipeline

#### Category 4: Writing Quality
- No banned hedging phrases ("interestingly", "it is worth noting", "arguably", "it is important to note")
- Notation consistent: LSOA, MSOA, EDM used correctly throughout
- Variable names in text match variable names in specifications
- No AI writing patterns (see humanizer skill for full checklist)
- Tone matches existing author voice

#### Category 5: Grammar & Polish
- Subject-verb agreement
- Article usage (particular attention to UK vs US English conventions)
- Tense consistency (present for methodology, past for results)
- No orphaned text, repeated words, or copy-paste artifacts
- Acronyms defined on first use

#### Category 6: Compilation & LaTeX
- All `\input{}` files exist
- All `\textcite{}` / `\parencite{}` keys exist in `refs.bib`
- All `\ref{}` targets have matching `\label{}`
- Table/figure floats properly placed
- No overfull hbox warnings (check tabularray table widths)
- KOMA-Script class options used correctly

### Step 3: Scoring

Apply deductions on a 0-100 scale:

| Issue | Deduction |
|-------|-----------|
| Effect size doesn't match table output | -25 |
| Identification strategy misrepresented | -20 |
| Broken citations (`\textcite` key missing) | -15 |
| Broken cross-references (`\ref` undefined) | -15 |
| Radius/sample inconsistency across sections | -10 |
| Overfull hbox > 10pt | -10 per |
| Hedging language | -5 per (max -15) |
| Notation inconsistency | -5 |
| Overfull hbox 1-10pt | -1 per |

### Step 4: Format-Aware Severity

| Context | Scoring |
|---------|---------|
| Paper manuscript (`.tex`) | **Blocking** — issues must be fixed |
| Quarto book (`.qmd`) | **Advisory** — reported but non-blocking |

### Step 5: Present Report

Save report to `output/log/proofread_report_[SECTION].md` and present summary:

```markdown
## Proofread Report: [filename]
**Score:** XX / 100
**Date:** YYYY-MM-DD

### Issues by Category
| Category | Critical | Major | Minor |
|----------|----------|-------|-------|
| Structure | ... | ... | ... |
| Claims-Evidence | ... | ... | ... |
| Identification | ... | ... | ... |
| Writing Quality | ... | ... | ... |
| Grammar | ... | ... | ... |
| LaTeX | ... | ... | ... |

### Top 3 Critical Issues
1. ...
2. ...
3. ...

### Escalation Flags
- Claims don't match output → verify against analysis scripts
- Strategy misrepresented → review identification approach
- Framing issues → flag to authors
```

---

## Principles

- **Proofreader is a CRITIC, not a creator.** Never write or revise — only report.
- **Be precise.** Quote exact text, cite exact line numbers and file paths.
- **Cross-reference against actual output.** Always verify numbers against `output/tables/`.
- **Proportional severity.** A missing comma is Minor. Numbers that don't match regression output is Critical.
- **Format-aware.** Paper `.tex` files are blocking; book `.qmd` files are advisory.
