---
name: causal-inference
argument-hint: "<method or identification strategy>"
description: >-
  This skill covers causal inference methods in observational and quasi-experimental settings. Use when the user is implementing, choosing between, or debugging causal identification strategies — including instrumental variables, difference-in-differences, regression discontinuity, synthetic control, or matching estimators. Triggers on "causal effect", "identification strategy", "instrumental variable", "2SLS", "GMM", "difference-in-differences", "DiD", "staggered treatment", "regression discontinuity", "RDD", "synthetic control", "matching", "propensity score", "IPW", "AIPW", "doubly robust", "LATE", "ATT", "ATE", "parallel trends", "exclusion restriction", "first stage", "weak instruments", or "endogeneity".
---

# Causal Inference

Reference for implementing causal inference methods: from identification strategy to estimation to diagnostics and robustness. Covers the major quasi-experimental and observational methods used in applied economics and quantitative social science.

## When to Use This Skill

Use when the user is:
- Choosing an identification strategy for a causal question
- Implementing IV/2SLS, DiD, RDD, synthetic control, or matching
- Debugging specification issues (weak instruments, parallel trends violations, bandwidth sensitivity)
- Running robustness checks or falsification tests
- Working with modern DiD methods for staggered treatment timing

Skip when:
- The task is structural estimation (use `structural-modeling` skill)
- The task is pure prediction/ML (no causal question)
- The user needs simulation design (use `numerical-auditor` agent)

## Where to Start
- **Choosing a method?** Jump to [Method Selection Guide](#method-selection-guide) at the end
- **Implementing a specific method?** Go directly to that method's section below
- **Need full code?** See `references/method-implementations.md` for complete implementations

## Frameworks

Two complementary frameworks underpin all causal inference:

**Potential Outcomes (Rubin):** Define Y(1), Y(0) as potential outcomes under treatment and control. The causal effect is τ = Y(1) - Y(0). The fundamental problem: we never observe both for the same unit. All methods are strategies for constructing valid counterfactuals.

**DAGs (Pearl):** Graphical models encoding conditional independence assumptions. Use d-separation to determine what must be conditioned on (and what must NOT be conditioned on) to identify causal effects. Particularly useful for reasoning about bad controls (colliders, mediators), overcontrol bias, and which instruments satisfy the exclusion restriction.

## Quick Reference: Methods at a Glance

| Method | Key Assumption | Target Parameter | Key Package |
|--------|---------------|-----------------|-------------|
| IV/2SLS | Exclusion restriction, monotonicity | LATE | `linearmodels` (Py), `fixest` (R), `ivregress` (Stata) |
| DiD | Parallel trends | ATT | `fixest` (R), `reghdfe` (Stata), `linearmodels` (Py) |
| RDD | No manipulation, local continuity | LATE at cutoff | `rdrobust` (all) |
| Synthetic Control | Weights reproduce pre-treatment trends | ATT (single unit) | `Synth`/`augsynth` (R) |
| Matching/AIPW | Selection on observables | ATE or ATT | `econml` (Py), `MatchIt`/`WeightIt` (R) |

## Target Parameters

Be precise about what parameter you are estimating:

| Parameter | Definition | Estimated by |
|-----------|-----------|-------------|
| ATE | E[Y(1) - Y(0)] | Randomized experiment, IPW, AIPW |
| ATT | E[Y(1) - Y(0) \| D=1] | DiD, matching, selection-on-observables |
| LATE | E[Y(1) - Y(0) \| compliers] | IV/2SLS (Imbens-Angrist 1994) |
| ATT(g,t) | Group-time specific treatment effect | Staggered DiD (Callaway-Sant'Anna) |

**Common mistake:** IV estimates LATE, not ATE. DiD estimates ATT, not ATE. This matters for policy interpretation.

## Instrumental Variables (IV/2SLS)

**Key idea:** Find a variable Z that shifts D (first stage) but affects Y only through D (exclusion restriction).

```python
from linearmodels.iv import IV2SLS

result = IV2SLS.from_formula(
    'lwage ~ 1 + exper + expersq + [educ ~ nearc4 + nearc2]',
    data=df
).fit(cov_type='robust')

# Always check first-stage F > 10; report LIML as robustness with weak instruments
```

For R/Stata implementations, weak instrument corrections (LIML, Anderson-Rubin), and overidentification tests, see `references/method-implementations.md`.

**IV Diagnostics Checklist:**
- [ ] First-stage F > 10 (or Olea-Pflueger effective F for robust inference)
- [ ] Exclusion restriction argued substantively (not testable)
- [ ] Monotonicity for LATE interpretation (no defiers)
- [ ] Reduced form significant (regress Y directly on Z)
- [ ] Overidentification test reported if over-identified
- [ ] Compare OLS vs 2SLS — direction and magnitude as expected?
- [ ] Report LATE interpretation — who are the compliers?

## Difference-in-Differences (DiD)

**Key idea:** Compare changes over time between treated and control groups, assuming they would have followed parallel trends absent treatment.

```python
import statsmodels.formula.api as smf

# Standard 2x2 DiD
result = smf.ols('y ~ treated + post + treated:post', data=df).fit(
    cov_type='cluster', cov_kwds={'groups': df['state']}
)
# Coefficient on treated:post is the DiD estimate
```

**Staggered treatment timing:** With staggered adoption, TWFE can produce sign-reversed estimates due to negative weights. Use:
- **Callaway-Sant'Anna** (`did` R package): Most flexible aggregation, doubly robust
- **Sun-Abraham** (`fixest::sunab`): Integrates directly into `feols`; simpler for event studies
- **Bacon decomposition** (`bacondecomp` R): Diagnose how much weight TWFE puts on contaminated comparisons

For full staggered DiD code (C-SA, Sun-Abraham, BJS24, de Chaisemartin-D'H), see `references/staggered-did.md`. For event study code and HonestDiD pre-trend sensitivity, see `references/method-implementations.md`.

**DiD Diagnostics Checklist:**
- [ ] Pre-trends: Event study shows no significant pre-treatment coefficients
- [ ] Parallel trends sensitivity: Rambachan-Roth or similar analysis
- [ ] Staggered timing: If varies, use C-SA or S-A — NOT naive TWFE
- [ ] Clustering at level of treatment assignment (typically state/county)
- [ ] Anticipation: Check period just before treatment
- [ ] Bacon decomposition if using TWFE

## Regression Discontinuity (RDD)

**Key idea:** Units just above and below a threshold are locally comparable; the jump at the threshold identifies the causal effect.

```python
from rdrobust import rdrobust, rdbwselect, rdplot

# Basic sharp RD with bias-corrected robust CI
result = rdrobust(y=df['outcome'], x=df['running_var'], c=0)
# Reports: point estimate, robust CI, MSE-optimal bandwidth, N left/right

# Density test for manipulation
from rddensity import rddensity
density_test = rddensity(X=df['running_var'], c=0)
```

For fuzzy RDD, bandwidth sensitivity tables, and R/Stata implementations, see `references/method-implementations.md`.

**RDD Diagnostics Checklist:**
- [ ] McCrary density test: No manipulation of running variable at cutoff
- [ ] Covariate balance: Run RD on predetermined covariates as placebo outcomes
- [ ] Bandwidth sensitivity: Results stable across 0.5×, 0.75×, 1×, 1.5×, 2× optimal
- [ ] Local linear (p=1) is standard — avoid high-order polynomials
- [ ] Donut hole: Drop observations very close to cutoff
- [ ] Placebo cutoffs: Run RD where no effect should exist

## Synthetic Control

**When to use:** Single or very few treated units, long pre-treatment series, no obvious comparison group. SC constructs a synthetic counterfactual as a weighted average of donor units.

**Key packages:** R: `Synth`, `tidysynth`, `augsynth`; Python: `SparseSC`, `SyntheticControlMethods`

**Diagnostics:** Pre-treatment RMSPE (fit quality), permutation/placebo tests across donor units, leave-one-out stability, time placebo at earlier date.

For full implementation (Synth setup, augsynth, permutation tests), see `references/synthetic-control.md` and `references/method-implementations.md`. The `identification-critic` agent can evaluate SC identification assumptions.

## Matching and Weighting

**Key idea:** Reweight control group to match treated group on observed characteristics. Only valid under selection-on-observables (no unobserved confounders).

**AIPW (doubly robust) is the recommended default** — consistent if either the propensity score model or the outcome model is correctly specified.

```python
from econml.dr import LinearDRLearner
from sklearn.ensemble import GradientBoostingRegressor, GradientBoostingClassifier

# Doubly robust learner
dr = LinearDRLearner(
    model_regression=GradientBoostingRegressor(),
    model_propensity=GradientBoostingClassifier()
)
dr.fit(Y=df['y'], T=df['treatment'], X=df[covariates], W=None)
ate = dr.ate(df[covariates])
```

For propensity score estimation, IPW/Hajek estimators, and manual AIPW implementation, see `references/method-implementations.md`.

**Matching Diagnostics Checklist:**
- [ ] Covariate balance: Standardized mean differences < 0.1 after weighting
- [ ] Common support: Substantial overlap in propensity score distributions
- [ ] Sensitivity analysis: Rosenbaum bounds
- [ ] No post-treatment covariates in the propensity model
- [ ] Trim if propensity scores near 0 or 1

## Method Selection Guide

| Scenario | Recommended Method | Key Assumption |
|----------|--------------------|----------------|
| Random assignment with imperfect compliance | IV/2SLS | Exclusion restriction, monotonicity |
| Policy change at a threshold | RDD | No manipulation, local continuity |
| Policy change at a time point, treated and control groups | DiD | Parallel trends |
| Staggered policy adoption across units | Staggered DiD (C-SA, S-A) | Parallel trends (conditional) |
| Single treated unit, long pre-period | Synthetic control | Weights reproduce pre-treatment |
| Treatment assignment based on observables | Matching/IPW/AIPW | Selection on observables |

**Decision heuristic:**
1. Is there a sharp threshold? → RDD
2. Is there an instrument? → IV
3. Is there a clean pre/post + treated/control? → DiD
4. Only one treated unit? → Synthetic control
5. Rich observables, selection on observables plausible? → AIPW
6. None of the above → structural model may be needed

## Common Anti-Patterns

| Anti-Pattern | Problem | Better Approach |
|--------------|---------|-----------------|
| TWFE with staggered timing and heterogeneous effects | Negative weights, biased estimates | Use Callaway-Sant'Anna or Sun-Abraham |
| Reporting 2SLS without first-stage F | Reader cannot assess instrument strength | Always report first-stage F (and LIML as robustness) |
| High-order polynomial in RDD | Overfitting, poor boundary properties | Use local linear (p=1) with rdrobust |
| Matching on post-treatment variables | Conditioning on outcome of treatment | Only match on pre-treatment covariates |
| Claiming parallel trends hold because pre-event coefficients are insignificant | Low power; absence of evidence ≠ evidence of absence | Use Rambachan-Roth sensitivity analysis |
| IPW with extreme propensity scores (near 0 or 1) | Huge variance, unstable estimates | Trim, use normalized/Hajek weights, or switch to AIPW |
| Reporting only one bandwidth in RDD | Cherry-picking concern | Show results across bandwidth range |
| Cluster-robust SEs with few clusters (< 30-40) | Poor finite-sample coverage | Wild cluster bootstrap (Cameron, Gelbach, Miller 2008) |

## Integration with compound-science

- `econometric-reviewer` — Reviews identification strategy, standard errors, and asymptotic properties
- `identification-critic` — Evaluates exclusion restrictions, support conditions, and identification completeness
- `identification-critic` agent / `identification-proofs` skill — Formalize an identification argument end-to-end
- `/estimate` — Run a full estimation pipeline with diagnostics
- `empirical-playbook` skill (`sensitivity-analysis.md`) — Oster bounds, specification curve, breakdown frontier for robustness

## Additional References

- `references/method-implementations.md` — Full IV/2SLS, DiD event study, RDD, and matching/AIPW implementation code
- `references/staggered-did.md` — Full implementation code for Callaway-Sant'Anna, Sun-Abraham, BJS24, de Chaisemartin-D'Haultfoeuille, and Bacon decomposition
- `references/synthetic-control.md` — Standard SC optimizer, permutation/placebo test code, augmented SC, diagnostics checklist
