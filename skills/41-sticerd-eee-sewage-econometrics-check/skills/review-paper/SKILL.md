---
name: review-paper
description: Simulated peer review of the sewage-house-prices manuscript. Dispatches 2 independent referee reviews (parallel) and an editorial decision (sequential). Produces referee reports and accept/revise/reject recommendation. This skill should be used when asked to "review the paper", "get feedback", "simulate peer review", or "what would referees say".
argument-hint: "[.tex file path, section number, or 'all']"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Agent"]
---

# Review Paper

Simulate peer review of the "Sewage in Our Waters" manuscript by running two independent referee reviews and an editorial synthesis.

**Input:** `$ARGUMENTS` — path to `.tex` file, section number (e.g. `01`), or `all`. Defaults to reviewing all sections in `docs/overleaf/`.

---

## Project-Specific Context

### Manuscript Location
- Main document: `docs/overleaf/_main.tex`
- Sections: `docs/overleaf/01_introduction.tex` through `docs/overleaf/05_research_question.tex`
- Appendices: `docs/overleaf/100_appendix_*.tex`
- Bibliography: `docs/overleaf/refs.bib`

### Key Aspects for Referee Scrutiny
- Identification: Do hedonic, repeat sales, long diff, DiD, upstream/downstream, dry spill approaches yield consistent results?
- External validity: England-specific EDM data — how generalisable?
- Data quality: EDM monitoring started 2021 — short panel concerns
- Treatment measurement: Spill count vs hours, 12/24-hour counting methodology
- Spatial matching: 10km maximum radius — appropriate?
- Sorting: Do households sort based on sewage spill information?

### Supporting Evidence
- Regression output: `output/tables/*.tex`
- Figures: `output/figures/`
- Analysis scripts: `scripts/R/09_analysis/`
- Quarto book: `book/*.qmd`

---

## Workflow

### Step 1: Context Gathering

1. Read the manuscript sections from `docs/overleaf/`
2. Read `docs/overleaf/refs.bib` for citation verification
3. Scan `output/tables/` for available regression output
4. Scan `output/figures/` for available figures
5. Read relevant analysis scripts for methodology verification

### Step 2: Referee 1 Review

Launch an Agent to conduct the first blind review:

**Focus:** Identification strategy and econometric rigour

Score across 5 dimensions:
- **Contribution (25%):** Novelty, importance, gap filled in hedonic pricing / environmental disamenity literature
- **Identification (30%):** Design validity, assumptions, threats across all 6 approaches
- **Data (20%):** EDM data quality, Land Registry coverage, spatial matching methodology
- **Writing (15%):** Clarity, structure, notation consistency
- **Journal Fit (10%):** Appropriate for environmental/urban economics journals

Produce: summary, detailed comments by section, recommendation (Accept/Minor/Major/Reject).

### Step 3: Referee 2 Review

Launch an Agent (in parallel with Referee 1) for the second blind review:

**Focus:** External validity, robustness, and alternative explanations

Emphasis on:
- Are results robust across radii (250m-10km)?
- Can sorting explain the findings?
- Do results differ for sales vs rentals — and why?
- Is the dry spill identification convincing?
- How does the upstream/downstream analysis strengthen or weaken the story?

Same 5-dimension scoring, independent of Referee 1.

### Step 4: Editorial Synthesis

After both referee reviews complete:
- Read both reports
- Identify areas of agreement and disagreement
- Weigh referee recommendations
- Specify which concerns are mandatory vs optional to address
- Make recommendation: Accept / Minor Revision / Major Revision / Reject

### Step 5: Present Results

```markdown
# Peer Review Report: Sewage in Our Waters
**Date:** YYYY-MM-DD

## Editorial Decision: [Accept / Minor / Major / Reject]

## Referee 1 Summary
- **Overall score:** XX/100
- **Recommendation:** [Accept/Minor/Major/Reject]
- **Key strengths:** [2-3 points]
- **Key concerns:** [2-3 points]

## Referee 2 Summary
- **Overall score:** XX/100
- **Recommendation:** [Accept/Minor/Major/Reject]
- **Key strengths:** [2-3 points]
- **Key concerns:** [2-3 points]

## Editor's Assessment
- **Referee agreement:** [Where they agree, where they disagree]
- **Mandatory revisions:** [List]
- **Optional improvements:** [List]

## Full Reports
- Referee 1: output/log/referee_1_report.md
- Referee 2: output/log/referee_2_report.md
- Editor: output/log/editorial_decision.md
```

Save all reports to `output/log/`.

---

## Principles

- **Independence.** Referees do not see each other's reports. Run in parallel.
- **Constructive criticism.** The goal is to improve the paper, not tear it down.
- **Specific feedback.** Every concern must cite exact sections, equations, or tables.
- **Calibrated severity.** A working draft gets developmental feedback. A near-final manuscript gets referee-level scrutiny.
- **Cross-reference against actual output.** Verify numbers against `output/tables/`.
- **Editor synthesizes.** The Editor resolves referee disagreements and prioritizes revisions.
