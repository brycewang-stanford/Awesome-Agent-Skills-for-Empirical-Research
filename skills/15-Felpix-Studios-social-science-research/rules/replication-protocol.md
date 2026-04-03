---
description: Replication-first workflow — match original results exactly before extending. Tolerance thresholds for point estimates, SEs, and p-values.
paths:
  - "scripts/**/*.R"
  - "scripts/**/*.py"
  - "notebooks/**/*.ipynb"
  - "explorations/**"
---

# Replication-First Protocol

**Core principle:** Replicate original results to the dot BEFORE extending.

---

## Phase 1: Inventory & Baseline

Before writing any code:

- [ ] Read the paper's replication README
- [ ] Inventory replication package: language, data files, scripts, outputs
- [ ] Record gold standard numbers from the paper:

```markdown
## Replication Targets: [Paper Author (Year)]

| Target | Table/Figure | Value | SE/CI | Notes |
|--------|-------------|-------|-------|-------|
| Main ATT | Table 2, Col 3 | -1.632 | (0.584) | Primary specification |
```

- [ ] Store targets in `quality_reports/[analysis-name]_replication_targets.md` or as RDS/parquet

---

## Phase 2: Translate & Execute

- [ ] Follow code conventions in `rules/` for your language (R or Python)
- [ ] Translate line-by-line initially -- don't "improve" during replication
- [ ] Match original specification exactly (covariates, sample, clustering, SE computation)
- [ ] Save all intermediate results (RDS for R; `.pkl` or `.parquet` for Python)

### Stata to R Translation Pitfalls

<!-- Customize: Add pitfalls specific to your field and source language -->

| Stata | R Equivalent | Trap |
|-------|-------------|------|
| `reg y x, cluster(id)` | `feols(y ~ x, cluster = ~id)` | Stata clusters df-adjust differently from some R packages |
| `areg y x, absorb(id)` | `feols(y ~ x \| id)` | Check demeaning method matches |
| `probit` for PS | `glm(family=binomial(link="probit"))` | R default logit != Stata default in some commands |
| `bootstrap, reps(999)` | Depends on method | Match seed, reps, and bootstrap type exactly |

### Python Equivalents

| R | Python | Notes |
|---|--------|-------|
| `feols(y ~ x, cluster = ~id)` | `PanelOLS` from `linearmodels` | Check cluster SE formula matches |
| `saveRDS(obj, path)` | `joblib.dump(obj, path)` or `df.to_parquet(path)` | Use parquet for DataFrames, joblib for model objects |
| `set.seed(N)` | `np.random.seed(N)` + `random.seed(N)` | Set both numpy and stdlib seeds |
| `lm(y ~ x)` | `smf.ols("y ~ x", data=df).fit()` | Formula interface via `statsmodels` |

---

## Phase 3: Verify Match

### Tolerance Thresholds

| Type | Tolerance | Rationale |
|------|-----------|-----------|
| Integers (N, counts) | Exact match | No reason for any difference |
| Point estimates | < 0.01 | Rounding in paper display |
| Standard errors | < 0.05 | Bootstrap/clustering variation |
| P-values | Same significance level | Exact p may differ slightly |
| Percentages | < 0.1pp | Display rounding |

### If Mismatch

**Do NOT proceed to extensions.** Isolate which step introduces the difference, check common causes (sample size, SE computation, default options, variable definitions), and document the investigation even if unresolved.

### Replication Report

Save to `quality_reports/[analysis-name]_replication_report.md`:

```markdown
# Replication Report: [Paper Author (Year)]
**Date:** [YYYY-MM-DD]
**Original language:** [Stata/R/Python/etc.]
**Translation:** [script path]

## Summary
- **Targets checked / Passed / Failed:** N / M / K
- **Overall:** [REPLICATED / PARTIAL / FAILED]

## Results Comparison

| Target | Paper | Ours | Diff | Status |
|--------|-------|------|------|--------|

## Discrepancies (if any)
- **Target:** X | **Investigation:** ... | **Resolution:** ...

## Environment
- Language version, key packages (with versions), data source
```

---

## Phase 4: Only Then Extend

After replication is verified (all targets PASS):

- [ ] Commit replication script: "Replicate [Paper] Table X -- all targets match"
- [ ] Now extend with your modifications (different estimators, new figures, extensions)
- [ ] Each extension builds on the verified baseline
