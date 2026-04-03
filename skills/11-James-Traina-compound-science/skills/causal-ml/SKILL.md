---
name: causal-ml
argument-hint: "<estimator or method choice>"
description: >-
  This skill covers causal machine learning methods in applied economics and quantitative social science. Use when implementing or choosing between modern ML-based causal estimators — including double machine learning, DML, partially linear models, interactive regression models, cross-fitting, Neyman orthogonality, debiased ML, causal forests, generalized random forest, GRF, honest causal trees, AIPW with machine learning, doubly robust with machine learning, DR-Learner, T-Learner, S-Learner, X-Learner, meta-learners, heterogeneous treatment effects, conditional average treatment effect, CATE, HTE, high-dimensional controls, LASSO controls, post-LASSO, post-double selection, Belloni-Chernozhukov-Hansen, Riesz representer, Chernozhukov, sample splitting, econml, DoubleML package, or any combination of machine learning and causal inference.
---

# Causal Machine Learning

Reference for semiparametric ML estimators: DML with cross-fitting, generalized random forests, debiased regularization, and nuisance function approximation. Covers Neyman-orthogonal moment conditions, sample splitting, plug-in bias correction, and heterogeneous treatment effects.

## When to Use This Skill

Use when the user is:
- Estimating treatment effects with high-dimensional controls (p large relative to n)
- Interested in heterogeneous treatment effects (CATE) as a primary estimand
- Applying ML for flexible nuisance function estimation within a causal framework
- Implementing cross-fitting, sample splitting, or Neyman-orthogonal estimators
- Using `econml`, `DoubleML`, or `grf` packages

Skip when:
- Sample is small (n < 500 — ML nuisance models need data)
- A well-specified parametric model is available and defensible
- The task is standard IV/DiD/RDD without high-dimensional controls (use `causal-inference` skill)
- Structural modeling is needed (use `structural-modeling` skill)
- The task needs formal identification proof (use `identification-proofs` skill)

## Where to Start

- **Choosing a method?** Jump to [Method Selection Guide](#method-selection-guide)
- **ATE with many controls?** See `references/dml.md`
- **Heterogeneous treatment effects?** See `references/grf-meta-learners.md`
- **Variable selection for controls?** See `references/high-dim-cross-fitting.md`
- **Reporting HTE results?** See `references/hte-inference.md`
- **Connecting to traditional methods?** See `references/connections-traditional.md`

---

## Causal ML vs Traditional Methods

| Dimension | Traditional (IV, DiD, RDD) | Causal ML |
|-----------|--------------------------|-----------|
| Functional form | Parametric | Nonparametric / semi-parametric |
| High-dimensional controls | Problematic | Native support |
| Heterogeneous effects | Secondary (subgroup analysis) | Primary estimand (CATE) |
| Sample requirements | Moderate N | ML nuisance needs large N |
| Identification | Explicit (IV, DiD, RCT) | Same assumptions — ML is estimation, not identification |

**Critical point:** Causal ML does not relax identification assumptions. If you need a valid instrument, parallel trends, or no unmeasured confounding, those must still hold.

---

## Double Machine Learning (DML)

DML (Chernozhukov et al. 2018) fixes regularization bias in naive ML-in-regression. Partial out controls X from both Y and D using separate ML nuisance models, then regress residuals. Two properties: **Neyman orthogonality** (moment condition locally insensitive to nuisance error) and **cross-fitting** (prevents overfitting bias).

**PLR** (Partially Linear Regression): $Y = \theta D + g(X) + \varepsilon$. Workhorse for continuous or binary D with ATE under selection on observables. **IRM** (Interactive Regression Model): relaxes additive separability for binary D with heterogeneous effects.

Full implementation (Python/R code, cross-fitting from scratch, diagnostics) in `references/dml.md`.

## Causal Forests

Causal forests (Wager-Athey 2018; Athey-Tibshirani-Wager 2019) estimate CATE $\tau(x) = E[Y(1)-Y(0)|X=x]$ using **honest** forests (structure learned on one subsample, effects estimated on another). Use when CATE is the primary estimand and n $\geq$ 2,000. Always run the calibration test before reporting heterogeneity.

R (`grf`) and Python (`econml`) implementations, ATE/ATT extraction, BLP projections in `references/grf-meta-learners.md`.

## Meta-Learners

Decompose CATE estimation into supervised learning sub-problems. **DR-Learner** (Kennedy 2023): best properties when both nuisance models are well-specified. **T-Learner**: simplest baseline. **X-Learner**: designed for imbalanced treatment. For applied work: DR-Learner primary, T-Learner benchmark. Large disagreement signals nuisance model problems.

All implementations in `references/grf-meta-learners.md`.

## High-Dimensional Controls

**PDS-LASSO** (Belloni-Chernozhukov-Hansen 2014): separate LASSOes of Y on X and D on X, union of selected variables, then OLS. Works at moderate n (~200 with sparse confounders). See `references/high-dim-cross-fitting.md`.

## HTE Inference

Before reporting CATE, test for genuine heterogeneity using BLP calibration test. Do not report heterogeneous effects if calibration test fails (p > 0.10). See `references/hte-inference.md`.

---

## Method Selection Guide

### Decision Heuristic

```
1. n < 500? → Use standard methods (causal-inference skill)
2. High-dim controls (p > 20), want ATE? → PDS-LASSO or DML-PLR; binary D → DML-IRM
3. CATE is primary estimand? → Causal Forest (large n) or DR-Learner (doubly robust)
4. Endogenous treatment with instrument? → DML-PLIV
5. Treatment is rare/imbalanced? → X-Learner
6. Quick benchmark? → Always compute T-Learner as baseline
```

### Full Method Comparison

| Method | Estimand | Python | R | Min n | Key diagnostic |
|--------|----------|--------|---|-------|----------------|
| DML-PLR | ATE | `doubleml`, `econml` | `DoubleML` | ~500 | Nuisance R², residual balance |
| DML-IRM | ATE (binary D) | `doubleml`, `econml` | `DoubleML` | ~500 | Propensity AUC, trim threshold |
| DML-PLIV | LATE | `doubleml`, `econml` | `DoubleML` | ~1,000 | Effective F-stat |
| Causal Forest | CATE(x) | `econml` | `grf` | ~2,000 | Calibration test, ATE match |
| DR-Learner | CATE(x) | `econml.dr` | manual/`grf` | ~1,000 | Propensity calibration |
| PDS-LASSO | ATE (high-dim X) | `sklearn` + manual | `hdm` | ~200 | Union size, penalty sensitivity |
| X-Learner | CATE (imbalanced D) | `econml` | manual | ~1,000 | Compare to DR-Learner |

### Limitations to State Explicitly

- **ML needs data**: Causal forests need n $\geq$ 2,000; DML needs n $\geq$ 500. Below these, use parametric methods.
- **Identification is not relaxed**: ML is better nuisance estimation, not weaker assumptions.
- **CATE inference is hard**: Individual-level CIs are conservative; policy targeting requires care.
- **Publication**: DML and causal forests are mainstream in top applied micro journals. Compare to traditional estimators.

---

## Connections to Traditional Methods

Causal ML nests traditional estimators: DML with linear nuisance = OLS (Frisch-Waugh), DML + IV = PLIV, causal forests + instrument = heterogeneous LATE (`grf::instrumental_forest`), post-LASSO + many instruments = sparse instrument selection then 2SLS. Details in `references/connections-traditional.md`.

---

## Integration with Plugin

**Agents:** `econometric-reviewer` (post-estimation review, table/code consistency), `identification-critic` (IV/PLIV assumptions), `numerical-auditor` (convergence, seeding, Monte Carlo validation).

**Cross-references:** `empirical-playbook` skill → `sensitivity-analysis.md` (specification curve over ML choices), `empirical-playbook` skill → `diagnostic-battery.md` (nuisance R², overlap, calibration), `numerical-auditor` agent (synthetic data with known CATE).

**Relationship to `causal-inference` skill:** Use `causal-inference` to establish identification; use `causal-ml` for implementation with high-dimensional controls or when heterogeneity is primary. Complements, not substitutes.

## Reference Files

- `references/dml.md` — Full DML implementation: PLR, IRM, PLIV with econml/DoubleML, cross-fitting, diagnostics
- `references/grf-meta-learners.md` — Causal forests (grf/econml), DR/T/S/X-Learner, calibration tests
- `references/high-dim-cross-fitting.md` — PDS-LASSO, Belloni-Chernozhukov-Hansen, cross-fitting protocols
- `references/hte-inference.md` — Calibration tests, individual CATE CIs, BLP projections, subgroup analysis
- `references/connections-traditional.md` — DML-OLS equivalence, PLIV, instrumental forests, post-LASSO
