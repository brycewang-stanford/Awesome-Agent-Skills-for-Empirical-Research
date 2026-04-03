# Solution Schema and Catalog Reference

## Research Problem Categories

Six categories cover the research domain. Each maps to a specialist agent for routing future similar problems.

| Category Directory | Problem Types | Specialist Agent |
|---|---|---|
| `estimation-issues/` | Convergence failures, identification failures, wrong standard errors, numerical instability in optimization | `econometric-reviewer` |
| `data-issues/` | Cleaning problems, merge errors, missing data patterns, panel structure issues, variable construction errors | `data-detective` |
| `numerical-issues/` | Floating-point precision, matrix conditioning, gradient accuracy, overflow/underflow, quadrature errors | `numerical-auditor` |
| `methodology-issues/` | Specification errors, robustness failures, wrong estimator choice, misapplied methods, invalid assumptions | `methods-explorer` |
| `derivation-issues/` | Proof gaps, incorrect regularity conditions, wrong limiting distributions, missing edge cases in arguments | `mathematical-prover` |
| `replication-issues/` | Reproducibility failures, missing dependencies, broken pipelines, seed mismatches, environment drift | `reproducibility-auditor` |

### Category Detection Rules

Classify by the **root cause**, not the symptom:

- Optimization failed to converge -> check if the cause is numerical (-> `numerical-issues`) or identification (-> `estimation-issues`)
- Results differ across machines -> likely `replication-issues` unless caused by floating-point (-> `numerical-issues`)
- Estimator gives wrong coverage in Monte Carlo -> `methodology-issues` if wrong estimator, `numerical-issues` if implementation bug
- Standard errors are wrong -> `estimation-issues` (clustering, heteroskedasticity) unless caused by singular Hessian (-> `numerical-issues`)

---

## Problem Type Enum

| problem_type | Category | Description |
|---|---|---|
| `estimation_convergence` | estimation-issues | Optimizer fails to converge |
| `identification_failure` | estimation-issues | Model not identified or weakly identified |
| `standard_error_computation` | estimation-issues | Wrong SEs (clustering, bootstrap, sandwich) |
| `endogeneity_issue` | estimation-issues | Unaddressed endogeneity |
| `data_cleaning_error` | data-issues | Errors in data preparation |
| `merge_error` | data-issues | Join/merge produces wrong results |
| `missing_data_handling` | data-issues | Incorrect treatment of missing values |
| `panel_structure_error` | data-issues | Wrong panel ID, time index, or balance |
| `floating_point_error` | numerical-issues | Precision loss, catastrophic cancellation |
| `matrix_conditioning` | numerical-issues | Near-singular matrices, pivot failures |
| `gradient_computation` | numerical-issues | Wrong analytic gradient or bad step size |
| `overflow_underflow` | numerical-issues | Likelihood or probability computation overflow |
| `specification_error` | methodology-issues | Wrong functional form or model specification |
| `robustness_failure` | methodology-issues | Results not robust to reasonable alternatives |
| `wrong_estimator` | methodology-issues | Inappropriate method for the data structure |
| `invalid_assumption` | methodology-issues | Violated assumption (e.g., parallel trends) |
| `proof_gap` | derivation-issues | Missing or incorrect step in proof |
| `regularity_conditions` | derivation-issues | Wrong or missing regularity conditions |
| `limiting_distribution` | derivation-issues | Incorrect asymptotic result |
| `reproducibility_failure` | replication-issues | Results differ across runs or machines |
| `missing_dependency` | replication-issues | Package or data file not included |
| `pipeline_break` | replication-issues | Pipeline fails at some stage |
| `seed_mismatch` | replication-issues | Different seeds produce different "fixed" results |

## Root Cause Enum

| root_cause | Description |
|---|---|
| `poor_starting_values` | Optimization started far from solution |
| `weak_instruments` | Instruments have low predictive power |
| `misspecified_model` | Model doesn't match data generating process |
| `numerical_precision` | Floating-point arithmetic issues |
| `singular_matrix` | Matrix inversion failed or nearly singular |
| `wrong_clustering` | Standard errors clustered at wrong level |
| `data_contamination` | Outliers, duplicates, or coding errors in data |
| `merge_key_mismatch` | Join keys don't align across datasets |
| `missing_not_random` | Missingness is informative, not handled |
| `wrong_functional_form` | Linear when should be nonlinear (or vice versa) |
| `violated_assumption` | Key identifying assumption doesn't hold |
| `implementation_bug` | Code doesn't implement intended estimator |
| `environment_drift` | Package versions or platform differences |
| `missing_seed` | Random seed not set or not propagated |
| `path_dependency` | Absolute paths or machine-specific config |

If a problem doesn't fit existing enums, use the closest match and add a `notes` field.

---

## YAML Frontmatter Schema

All solution docs require validated YAML frontmatter.

**Required fields:**

```yaml
---
component: "BLP demand estimation"          # What had the problem
date: 2025-02-25                            # When solved
problem_type: estimation_convergence        # See enum above
category: estimation-issues                 # Directory (derived from problem_type)
symptoms:
  - "Optimizer returns non-convergence after 1000 iterations"
  - "Objective function value jumps between iterations"
root_cause: poor_starting_values            # See enum above
severity: high                              # critical | high | medium | low
estimation_method: blp                      # Optional: method involved
language: python                            # python | r | julia | stata
packages:                                   # Optional: packages involved
  - pyblp
  - numpy
tags: [convergence, blp, starting-values, demand-estimation]
specialist_agent: econometric-reviewer            # Which agent handles this category
related_docs: []                            # Cross-references (populated later)
---
```

---

## Document Template

```markdown
---
[validated YAML frontmatter]
---

# [Descriptive Title]

## Symptom

[What was observed -- exact error messages, wrong numerical results, unexpected behavior]

## Investigation

### What was tried
1. [First attempt and why it didn't work]
2. [Second attempt and why it didn't work]
3. [...]

### Key diagnostic
[The observation or test that revealed the root cause]

## Root Cause

[Technical explanation of why the problem occurred]

## Solution

[What fixed it -- specific code changes, parameter adjustments, methodological corrections]

\```python
# Before (broken)
result = model.fit(method='bfgs', maxiter=100)

# After (fixed)
x0 = get_starting_values(data, method='ols')  # informed starting values
result = model.fit(method='bfgs', maxiter=5000, x0=x0, gtol=1e-8)
\```

## Prevention

[How to avoid this in future -- checks to run, patterns to follow]

## Context

- **Dataset:** [description]
- **Sample size:** [N]
- **Estimation method:** [method]
- **Packages:** [list with versions]
- **Related docs:** [cross-references]
```

---

## Cross-Reference and Pattern Detection

**If similar issues found during search:**
- Add bidirectional cross-references (update both docs)
- Update `related_docs` in YAML frontmatter of both files

**Pattern detection -- if 3+ similar issues exist:**

Create or update `docs/solutions/patterns/common-patterns.md`:

```markdown
## [Pattern Name]

**Common symptom:** [Description]
**Root cause:** [Technical explanation]
**Solution pattern:** [General approach]
**Category:** [category] -> **Agent:** [specialist_agent]

**Examples:**
- [Link to doc 1]
- [Link to doc 2]
- [Link to doc 3]
```

**Critical pattern promotion:**

If the issue has indicators suggesting it's critical:
- Severity: `critical`
- Affects foundational code (identification, core estimation, data pipeline)
- Non-obvious solution that every researcher on the project should know

Then add to `docs/solutions/patterns/critical-patterns.md` with the wrong/right format.

---

## Searching Past Solutions

Before investigating a new problem from scratch, search existing solutions.

**When to search:** Before starting any non-trivial debugging, when a user reports a problem that sounds familiar, or when an agent encounters a known problem type.

**Search workflow:**

1. **Identify the symptom category** -- use the Category Detection Rules above to classify by root cause
2. **Search by category directory:**
   ```bash
   ls docs/solutions/estimation-issues/
   ls docs/solutions/numerical-issues/
   ```
3. **Search by keywords** (error messages, packages, tags):
   ```bash
   grep -r "convergence" docs/solutions/
   grep -r "pyblp" docs/solutions/ --include="*.md"
   grep -r "tags:.*weak-instruments" docs/solutions/
   grep -r "severity: critical" docs/solutions/
   ```
4. **If a match is found:** Read the solution doc, check if root cause matches, apply the documented fix.
5. **If no match:** Proceed with investigation, then document the solution.
6. **Route to specialist:** Use the `specialist_agent` field from matching docs to determine which agent should handle the current problem.

**Tip:** Search `docs/solutions/patterns/common-patterns.md` first -- if the symptom matches a known pattern, skip straight to the documented fix.
