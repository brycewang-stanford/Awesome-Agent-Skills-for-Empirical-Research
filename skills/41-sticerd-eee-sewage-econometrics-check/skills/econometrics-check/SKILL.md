---
name: econometrics-check
description: Causal inference design audit for the sewage-house-prices project. Runs a 4-phase review (claim identification, design validity, inference, polish) covering hedonic pricing, repeat sales, long difference, DiD/event studies, upstream/downstream, and dry spill strategies. This skill should be used when asked to "check the econometrics", "audit the identification", "review the strategy", or when verifying that code matches the stated design.
argument-hint: "[.tex section, .R script, directory path, or 'all']"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Agent"]
---

# Econometrics Check

Run a 4-phase causal inference audit on the target file(s) for the sewage-house-prices project.

**Input:** `$ARGUMENTS` — a `.tex` file, `.R` script, directory path, or `all`.

---

## Project-Specific Context

### Identification Strategies in This Paper

1. **Hedonic regressions** — Cross-sectional: `log(price)` on spill count/hours (continuous + bins), LSOA FE, heteroskedasticity-robust SE
2. **Repeat sales** — Within-property variation (Palmquist 1982), house fixed effects
3. **Long difference** — 250m grid-level changes, weighted/unweighted, all/exposed grids
4. **News/media DiD** — Google Trends and LexisNexis media coverage as treatment
5. **Upstream/downstream** — Directional spillover via PostGIS river network topology
6. **Dry spills** — Spills occurring without rainfall as identification variation (rainfall threshold-based)

### Key Variables

- Outcome: `log(price)` for sales, `log(rent)` for rentals
- Treatment: `spill_count`, `spill_hrs`, `spill_count_daily_avg`, `spill_hrs_daily_avg`
- Geography: `n_spill_sites` within radius, `min_dist` / `mean_dist`
- Radii: 250m, 500m, 1000m, 2000m, 5000m, 10000m
- Fixed effects: LSOA (`lsoa`), MSOA (`msoa`), year-quarter
- SE: heteroskedasticity-robust via `fixest::feols(vcov = "hetero")`
- Counting: 12/24-hour methodology in `spill_aggregation_utils.R`

### File Locations

- Manuscript: `docs/overleaf/*.tex`
- Analysis scripts: `scripts/R/09_analysis/`
- Utility functions: `scripts/R/utils/`
- Pipeline scripts: `scripts/R/01_data_ingestion/` through `scripts/R/06_analysis_datasets/`

---

## Workflow

### Step 1: Parse Input

Determine target from `$ARGUMENTS`:
- **`.tex` file:** Review manuscript section for identification claims, assumption statements, estimation descriptions
- **`.R` file:** Review analysis script for code-theory alignment, package usage, SE computation
- **Directory (e.g. `scripts/R/09_analysis/02_hedonic/`):** Review all scripts in that approach
- **`all`:** Review `docs/overleaf/*.tex` and `scripts/R/09_analysis/`
- **No argument:** Review all manuscript sections and analysis scripts

### Step 2: Context Gathering

Before auditing:
1. Read the target file(s)
2. Read `docs/overleaf/refs.bib` for citation availability
3. If reviewing scripts: read corresponding manuscript section for code-theory alignment
4. If reviewing manuscript: read corresponding analysis scripts for accuracy
5. Read `scripts/R/utils/spill_aggregation_utils.R` for counting methodology

### Step 3: Run 4-Phase Review

#### Phase 1: Claim Identification
- What design is being used? (hedonic / repeat sales / long diff / DiD / upstream-downstream / dry spill)
- What is the estimand? (ATT / ATE / LATE)
- What is the treatment? (spill count, spill hours, distance, media coverage)
- What is the comparison group?

#### Phase 2: Core Design Validity
Design-specific assumption checks:

**Hedonic:**
- Selection on observables assumption — are LSOA FE sufficient?
- Omitted variable bias from neighbourhood sorting
- Measurement error in spill count/hours

**Repeat sales:**
- Within-property variation correctly specified
- Time-varying confounders addressed
- Property-level fixed effects properly implemented

**Long difference:**
- Grid construction and assignment correct
- Weighted vs unweighted justified
- Pre-period balance

**DiD / Event studies:**
- Parallel trends assumption stated and tested
- Treatment timing correctly identified
- Staggered adoption issues addressed (if applicable)

**Upstream/downstream:**
- River network topology correctly implemented
- Directionality assumption valid
- Spillover definitions consistent

**Dry spills:**
- Rainfall threshold justified
- Dry vs wet spill definition consistent with data pipeline
- Selection into dry spills addressed

#### Phase 3: Inference
- SE computation: heteroskedasticity-robust applied correctly
- Multiple testing: across radii, specifications, outcomes
- Code-theory alignment: does the R code implement what the paper claims?

#### Phase 4: Polish & Completeness
- Robustness checks: radius sensitivity, time period variation, specification changes
- Sensitivity analysis: how sensitive are results to key assumptions?
- Citation fidelity: are methodological references accurate?

**Early stopping:** If Phase 2 finds CRITICAL issues, focus there.

### Step 4: Present Summary

```markdown
## Econometrics Audit: [target]
**Date:** YYYY-MM-DD

### Design(s) Reviewed
- [List designs audited]

### Overall Assessment: [SOUND / MINOR ISSUES / MAJOR ISSUES / CRITICAL ERRORS]

### Blocking Issues (CRITICAL)
1. ...

### Priority Action List
1. ...
2. ...
3. ...

### Positive Findings
- ...
```

Save report to `output/log/econometrics_check_[target].md`.

---

## Principles

- **Design-opinionated, package-flexible.** Validate the econometric logic, not just the R packages.
- **Cross-reference code and paper.** Flag any mismatch between what the manuscript says and what the script does.
- **Actionable output.** Every issue must have a concrete fix.
- **Proportional.** Not every approach needs every robustness check.
- **Sequential phases.** Never skip to robustness before verifying the core design holds.
