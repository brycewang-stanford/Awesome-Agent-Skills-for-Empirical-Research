---
paths:
  - "**/*.jl"
  - "**/*.R"
  - "scripts/**/*.R"
---

# Estimation Pipeline Verification Protocol

**Core principle:** Verify the estimation pipeline reproduces known results before making changes.

---

## Phase 1: Baseline Verification

Before modifying any estimation code:

- [ ] Record current output values from the outcomes directory
- [ ] Store baseline in `quality_reports/` as reference:

```markdown
## Baseline Estimates

| Parameter | Model 1 | Model 2 | Model N |
|-----------|---------|---------|---------|
| [param1] | [value] | [value] | [value] |
| [param2] | [value] | [value] | [value] |
```

---

## Phase 2: Run & Compare

- [ ] Run the full estimation pipeline
- [ ] Compare new outputs against baseline
- [ ] Apply tolerance thresholds

### Tolerance Thresholds (Customize Per Project)

| Type | Tolerance | Rationale |
|------|-----------|-----------|
| Point estimates | < 1e-6 | Numerical precision of optimization |
| Standard errors | < 1e-4 | Bootstrap/simulation MC variability |
| Significance stars | Exact match | Discrete classification must agree |
| Sample sizes | Exact match | No reason for difference |

### If Mismatch

**Do NOT proceed with modifications.** Isolate which step introduces the difference.
Document the investigation even if unresolved.

---

## Phase 3: Julia-to-R Translation Pitfalls

| Julia | R (via RCall) | Trap |
|-------|---------------|------|
| `Float64` | `numeric` | R may silently convert to lower precision |
| `DataFrame` column types | R factor vs character | Check column types after `@rget` |
| `Matrix{Float64}` | Dense matrix | Sparse matrices lose sparsity through RCall |
| `missing` | `NA` | RCall handles this, but check edge cases |

---

## Phase 4: Verification Report

Save to `quality_reports/pipeline_verification.md`:

```markdown
# Pipeline Verification Report
**Date:** [YYYY-MM-DD]

## Summary
- **Parameters checked / Passed / Failed:** N / M / K
- **Overall:** [VERIFIED / PARTIAL / FAILED]

## Results Comparison

| Parameter | Baseline | Current | Diff | Status |
|-----------|----------|---------|------|--------|

## Environment
- Julia version, R version, key packages
- OS, CPU cores used
```
