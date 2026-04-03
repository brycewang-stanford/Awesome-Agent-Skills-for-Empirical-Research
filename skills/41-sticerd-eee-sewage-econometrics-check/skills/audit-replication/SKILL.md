---
name: audit-replication
description: Validate the replication package for the sewage-house-prices project. Runs 10 checks covering script execution, file integrity, output freshness, dependency verification, data provenance, and README completeness (AEA format). This skill should be used when asked to "audit replication", "check the package", or "verify reproducibility".
argument-hint: "[replication directory OR 'here' for current project]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Bash", "Agent"]
---

# Audit Replication Package

Run end-to-end validation of the replication package for the sewage-house-prices project.

**Input:** `$ARGUMENTS` — directory containing the replication package (`Replication/` by default), or `here` for the current project root.

---

## Project-Specific Context

### Expected Structure
- Pipeline scripts: `scripts/R/01_data_ingestion/` through `scripts/R/06_analysis_datasets/`
- Analysis scripts: `scripts/R/09_analysis/`
- Utilities: `scripts/R/utils/`
- Python: `scripts/python/`
- Data: `data/raw/`, `data/processed/`, `data/final/`
- Output: `output/tables/`, `output/figures/`
- Manuscript: `docs/overleaf/`
- R packages: `renv.lock`

---

## Workflow

### Step 1: Locate Package

- If `$ARGUMENTS` is a directory path: use it
- If `$ARGUMENTS` is `here` or empty: use `Replication/` if it exists, otherwise project root
- Verify the directory exists and contains scripts

### Step 2: Run 10 Verification Checks

#### Standard Checks (1-4)

1. **Script syntax** — All `.R` files parse without syntax errors
2. **File references** — All `read_parquet()`, `readRDS()`, `read.csv()` targets exist or are documented as inputs
3. **File integrity** — No orphaned scripts (referenced but missing), no orphaned outputs (generated but unreferenced)
4. **Output freshness** — Output files are newer than their source scripts (no stale outputs)

#### Submission Checks (5-10)

5. **Package inventory** — Scripts are logically ordered, master script exists
6. **Dependency verification** — `renv.lock` present, R version documented, Python deps documented
7. **Data provenance** — Every dataset has documented source, access date, and restrictions
8. **Path hygiene** — No hardcoded absolute paths, all paths use `here::here()`
9. **Output cross-reference** — Every table/figure in the manuscript traces to a specific script
10. **README completeness** — AEA format: data availability, computational requirements, program descriptions, instructions

### Step 3: Handle Failures

If failures found:
1. Display specific error with file and line number
2. Suggest concrete fix
3. Ask user if they want to fix and re-audit (max 3 iterations)

### Step 4: Present Results

```markdown
# Replication Audit Report
**Date:** YYYY-MM-DD
**Directory:** [path]

## Check Results
| # | Check | Status | Details |
|---|-------|--------|---------|
| 1 | Script syntax | PASS/FAIL | |
| 2 | File references | PASS/FAIL | |
| 3 | File integrity | PASS/FAIL | |
| 4 | Output freshness | PASS/FAIL | |
| 5 | Package inventory | PASS/FAIL | |
| 6 | Dependencies | PASS/FAIL | |
| 7 | Data provenance | PASS/FAIL | |
| 8 | Path hygiene | PASS/FAIL | |
| 9 | Output cross-reference | PASS/FAIL | |
| 10 | README completeness | PASS/FAIL | |

## Summary
- Checks passed: N / 10
- **Overall: PASS / FAIL**
- Blocking issues: [list]
- Positive findings: [list]
```

Save to `output/log/replication_audit_[date].md`.

---

## Principles

- **Read and analyse only.** Do not modify the package during audit.
- **Specific errors.** "Script 03_robustness.R references `data/final/panel.parquet` which does not exist" beats "file reference error."
- **AEA Data Editor standards.** The target is full compliance.
- **Path checking is critical.** Any `setwd()` or absolute path is a FAIL for Check 8.
- **Restricted data awareness.** Land Registry and Zoopla data may have access restrictions — document, don't block.
