# Causal Forests and Meta-Learners — Implementation Reference

## Causal Forests (Generalized Random Forests)

Reference: Athey, Tibshirani, Wager (2019), "Generalized random forests," *Annals of Statistics*. Wager and Athey (2018), "Estimation and inference of heterogeneous treatment effects using random forests," *JASA*.

### Core Idea

Causal forests estimate the CATE τ(x) = E[Y(1) - Y(0) | X = x] at any point x. The key innovation over standard random forests is **honesty**: the tree structure is learned on one subsample, and the leaf-level treatment effect is estimated on a separate subsample. This prevents overfitting from conflating the splitting criterion with the estimation.

Honesty is necessary for valid confidence intervals. Without it, leaf estimates are biased and confidence intervals have poor coverage.

### Intuition: Local ATE via Weighted Neighbors

Causal forests solve:

```
τ̂(x) = argmin_τ Σᵢ αᵢ(x) · [Yᵢ - m̂(Xᵢ) - τ · (Dᵢ - ê(Xᵢ))]²
```

where αᵢ(x) are forest weights (how much unit i's neighborhood contributes to τ(x)), and m̂(X), ê(X) are residualized outcomes and propensities. Units that are neighbors of x in feature space get high weight. Units far away get low weight.

This is local ATE estimation, where "local" is defined by proximity in the feature space learned by the forest.

### Python: CausalForestDML via `econml`

```python
from econml.dml import CausalForestDML
from sklearn.ensemble import RandomForestRegressor, RandomForestClassifier
import numpy as np

# X: features for CATE heterogeneity (can differ from controls W)
# T: binary or continuous treatment
# Y: outcome
# W: high-dimensional controls to partial out (optional, separate from X)

cf = CausalForestDML(
    model_y=RandomForestRegressor(n_estimators=100, random_state=42),
    model_t=RandomForestClassifier(n_estimators=100, random_state=42),
    n_estimators=500,
    min_samples_leaf=5,
    max_depth=None,
    random_state=42,
    cv=5,           # cross-fitting folds
    honest=True,    # always use honest splitting
)
cf.fit(Y=y, T=t, X=X, W=W)  # W is additional controls not in X

# Estimate CATE for each observation
tau_hat = cf.effect(X)

# Estimate ATE and confidence interval
ate_result = cf.ate(X, T0=0, T1=1)
print(f"ATE: {ate_result:.4f}")

# Confidence intervals for each unit (conservative)
tau_lb, tau_ub = cf.effect_interval(X, alpha=0.05)

# Best linear projection of CATE onto features
from econml.inference import LinearModelFinalInference
blp = cf.const_marginal_effect_inference(X)
print(blp.summary_frame())
```

### R: `grf` Package

```r
library(grf)

# Prepare data
# X: matrix of features, Y: outcome vector, W: treatment vector

cf <- causal_forest(
  X = X_matrix,
  Y = Y_vector,
  W = W_treatment,
  num.trees = 2000,
  honesty = TRUE,          # required for valid inference
  min.node.size = 5,
  seed = 42
)

# Average treatment effect
ate <- average_treatment_effect(cf, target.sample = "all")
cat("ATE:", ate["estimate"], "+/-", 1.96 * ate["std.err"], "\n")

# ATT
att <- average_treatment_effect(cf, target.sample = "treated")

# CATE predictions with confidence intervals
tau_hat <- predict(cf, estimate.variance = TRUE)
tau_vals <- tau_hat$predictions
tau_se   <- sqrt(tau_hat$variance.estimates)

# Test for heterogeneity: BLP calibration test
# Chernozhukov, Demirer, Duflo, Fernandez-Val (2022)
calibration <- test_calibration(cf)
print(calibration)
# mean.forest.prediction: should be ~1 if CATE is well-calibrated
# differential.forest.prediction: should be >0 if heterogeneity is real

# Best linear projection of CATE on covariates
blp <- best_linear_projection(cf, A = X_matrix)
print(blp)
```

### CATE Heterogeneity: Calibration Test

The calibration test (Chernozhukov, Demirer, Duflo, Fernandez-Val 2022) estimates a linear projection:

```
τᵢ = α₀ + α₁ · τ̂ᵢ + εᵢ
```

using an AIPW-based approach. Interpretation:
- α₁ ≈ 1: forest predictions are well-calibrated on average
- α₁ > 0 and significant: there is real heterogeneity (the forest is detecting genuine variation, not noise)
- α₁ = 0: forest's heterogeneity is indistinguishable from noise

Report this test whenever presenting CATE estimates.

```r
# R (grf)
cal <- test_calibration(cf)
# Examine: mean.forest.prediction coefficient and its p-value
# Examine: differential.forest.prediction coefficient and its p-value

# Python (econml): use the best_linear_projection API
```

### Causal Forest Diagnostic Checklist

- [ ] **Honesty enabled**: Always set `honest = TRUE` (R) or `honest=True` (Python). Without honesty, confidence intervals are invalid.
- [ ] **Calibration test**: Run `test_calibration()`. Report both coefficients. Significant differential coefficient supports real heterogeneity.
- [ ] **ATE recovery**: Compare forest ATE to a standard doubly-robust ATE estimator. They should agree closely. Large discrepancy suggests a problem with nuisance models.
- [ ] **Overlap / positivity**: Check that propensity scores ê(X) are bounded away from 0 and 1. Forest fails when treatment assignment is deterministic given X.
- [ ] **Variable importance**: Examine `variable_importance(cf)` (R) or `cf.feature_importances_` (Python). Dominant variables driving heterogeneity should be interpretable.
- [ ] **Minimum leaf size**: Default `min.node.size=5` is a starting point. Increase for small samples; the forest should not have near-empty leaves.
- [ ] **Number of trees**: Use at least 2,000 trees for stable variance estimates. More trees reduce Monte Carlo error in τ̂(x).
- [ ] **Subgroup analysis**: Pre-specify subgroups before running the forest. Post-hoc "we found heterogeneity along dimension k" inflates false discovery rates.

### Common Causal Forest Pitfalls

| Pitfall | Problem | Fix |
|---------|---------|-----|
| `honest = FALSE` | Biased leaf estimates, invalid CIs | Always use honest splitting |
| Reporting CATE for individuals without calibration test | May be noise, not signal | Always report calibration test alongside individual CATEs |
| Using forest CATE for policy targeting without welfare analysis | High-variance individual CIs | Target subgroups defined by stable covariates, not individual predictions |
| X and W conflated | Controls that should be partialled out inflate variance in X | Separate: X = heterogeneity features; W = nuisance controls |
| Too few trees for stable variance | Variance estimates fluctuate across runs | Use 2000+ trees; check stability with different seeds |

---

## DR-Learner and Meta-Learners

Meta-learners decompose the CATE estimation problem into standard supervised learning sub-problems. The choice of meta-learner determines the statistical properties of τ̂(x).

Reference: Kennedy (2023), "Towards optimal doubly robust estimation of heterogeneous causal effects," *Electronic Journal of Statistics*. Künzel et al. (2019), "Meta-learners for estimating heterogeneous treatment effects using machine learning," *PNAS*.

### Overview of Meta-Learners

| Learner | Procedure | Pros | Cons |
|---------|-----------|------|------|
| T-Learner | Separate outcome models μ₁(x), μ₀(x); τ̂(x) = μ̂₁(x) - μ̂₀(x) | Simple | Regularization not targeted at τ; shrinks both toward zero rather than toward effect |
| S-Learner | Single model μ(x, d); τ̂(x) = μ̂(x,1) - μ̂(x,0) | Simple | Treatment effect may be shrunk to zero if D is not selected |
| X-Learner | Two-stage: impute counterfactuals, then regress; weighted combination | Works well in imbalanced treatment | Tuning heavy; depends on propensity weighting |
| DR-Learner | Regress DR pseudo-outcomes on X; τ̂(x) = learned function of DR scores | Best statistical properties; doubly robust at CATE level | Requires good nuisance estimates; more moving parts |

**Recommendation for applied work:** DR-Learner when sample is large enough for nuisance estimation. T-Learner as a simple benchmark. Report both.

### DR-Learner: Doubly Robust CATE

The DR-Learner constructs pseudo-outcomes:

```
ψᵢ = μ̂₁(Xᵢ) - μ̂₀(Xᵢ)
    + Dᵢ(Yᵢ - μ̂₁(Xᵢ)) / ê(Xᵢ)
    - (1-Dᵢ)(Yᵢ - μ̂₀(Xᵢ)) / (1 - ê(Xᵢ))
```

Then regresses these pseudo-outcomes on X to get τ̂(x). The pseudo-outcomes are doubly robust: if either the outcome model or propensity model is correct, the pseudo-outcome has the correct expectation.

```python
from econml.dr import DRLearner
from sklearn.ensemble import RandomForestRegressor, RandomForestClassifier
from sklearn.linear_model import RidgeCV

# DR-Learner
dr = DRLearner(
    model_propensity=RandomForestClassifier(n_estimators=100, random_state=42),
    model_regression=RandomForestRegressor(n_estimators=100, random_state=42),
    model_final=RidgeCV(),       # final CATE model (can be any regressor)
    cv=5,
    random_state=42,
)
dr.fit(Y=y, T=t, X=X, W=W)

# CATE estimates
tau_dr = dr.effect(X)

# ATE from DR-Learner
ate_dr = dr.ate(X)
print(f"ATE (DR-Learner): {ate_dr:.4f}")

# Confidence intervals
ate_interval = dr.ate_interval(X, alpha=0.05)
print(f"95% CI: [{ate_interval[0]:.4f}, {ate_interval[1]:.4f}]")

# T-Learner for comparison
from econml.metalearners import TLearner

tl = TLearner(
    models=RandomForestRegressor(n_estimators=100, random_state=42)
)
tl.fit(y, t, X=X)
tau_tl = tl.effect(X)
```

### When to Use Each Meta-Learner

- **T-Learner**: Quick baseline; when treatment groups are roughly balanced; when you have very large n and flexible models
- **S-Learner**: When treatment effect is expected to be small or zero for most units (LASSO/tree won't shrink effect to zero unlike T-Learner)
- **X-Learner**: When treatment is rare or imbalanced (many control, few treated); designed specifically for this case
- **DR-Learner**: When you want the best-calibrated CATE estimates with valid inference; default for serious empirical work

### DR-Learner Diagnostic Checklist

- [ ] **Propensity model quality**: Check AUC and calibration of propensity score. Miscalibrated propensities inflate DR pseudo-outcome variance.
- [ ] **Outcome model quality**: Report R² for μ̂₁(X) and μ̂₀(X) separately. Low R² reduces efficiency but does not invalidate doubly-robust property (as long as propensity is right).
- [ ] **Compare T-Learner and DR-Learner**: If they agree closely, results are likely robust. Large disagreements suggest a nuisance specification problem.
- [ ] **ATE vs. mean of CATE**: `np.mean(tau_dr)` should match `dr.ate(X)` — if not, there is a weighting issue.
- [ ] **Calibration**: Apply Chernozhukov calibration test logic: project CATE onto a low-dimensional summary; check that projection coefficient is not zero.
