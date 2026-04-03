# Double Machine Learning — Implementation Reference

Reference: Chernozhukov, Chetverikov, Demirer, Duflo, Hansen, Newey, Robins (2018), "Double/debiased machine learning for treatment and structural parameters," *Econometrics Journal*.

## Core Idea

Naive approach: regress Y on D and X with ML. This fails because ML regularization (LASSO shrinkage, random forest bias) contaminates the coefficient on D. The bias does not vanish even as n → ∞.

DML fix: partial out X from both Y and D using separate ML models, then regress the residuals on each other. The key properties that make this work:

1. **Neyman orthogonality**: The moment condition is locally insensitive to perturbations in the nuisance parameters. Small errors in nuisance estimates have second-order (not first-order) effects on the target parameter.
2. **Cross-fitting**: Estimate nuisance models on a held-out fold to avoid overfitting bias contaminating the main estimate.

## Partially Linear Model (PLR)

The PLR is the workhorse DML specification:

```
Y = θ₀ D + g₀(X) + ε,   E[ε | D, X] = 0
D = m₀(X) + v,           E[v | X] = 0
```

where g₀(X) is an unknown function of controls X, and θ₀ is the ATE of interest. The nuisance functions are g₀ and m₀.

**Identification assumption:** After conditioning on X, D is as good as randomly assigned. This is selection on observables — the same assumption as standard regression, but allowing the functional form of X to be flexible.

## Interactive Regression Model (IRM)

When treatment D is binary and the effect may be heterogeneous:

```
Y = g₀(D, X) + ε,   E[ε | D, X] = 0
D ~ Bernoulli(m₀(X))
```

The IRM estimates the ATE by averaging individual-level predictions:

```
θ₀ = E[g₀(1, X) - g₀(0, X)]
```

Use IRM when:
- D is binary and you suspect treatment effect heterogeneity
- You want ATE rather than a single θ coefficient
- The partially linear assumption (additive separability) seems too strong

## Cross-Fitting Procedure

Cross-fitting prevents overfitting bias from contaminating inference. The K-fold procedure (K=5 is standard):

```python
import numpy as np
from sklearn.model_selection import KFold

def cross_fit_residuals(Y, D, X, ml_model_y, ml_model_d, n_splits=5, random_state=42):
    """
    Cross-fitting step for DML partially linear model.

    Returns:
        W: residuals Y - E[Y|X] (partialled-out Y)
        V: residuals D - E[D|X] (partialled-out D)
    """
    n = len(Y)
    W = np.zeros(n)  # Y residuals
    V = np.zeros(n)  # D residuals

    kf = KFold(n_splits=n_splits, shuffle=True, random_state=random_state)

    for train_idx, test_idx in kf.split(X):
        # Train nuisance models on training fold
        ml_model_y.fit(X[train_idx], Y[train_idx])
        ml_model_d.fit(X[train_idx], D[train_idx])

        # Predict and residualize on held-out test fold
        W[test_idx] = Y[test_idx] - ml_model_y.predict(X[test_idx])
        V[test_idx] = D[test_idx] - ml_model_d.predict(X[test_idx])

    return W, V

def dml_plr_estimate(W, V):
    """
    DML estimate from partialled-out residuals.
    theta_hat = (V'W) / (V'V)  — OLS of W on V (no intercept)
    Standard errors via influence function.
    """
    n = len(W)
    theta_hat = np.dot(V, W) / np.dot(V, V)

    # Influence function: psi_i = V_i * (W_i - theta_hat * V_i)
    psi = V * (W - theta_hat * V)

    # Sandwich variance
    J = -np.mean(V ** 2)
    var_hat = np.mean(psi ** 2) / (J ** 2)
    se = np.sqrt(var_hat / n)

    return theta_hat, se
```

## Using the `DoubleML` Package (Python)

```python
import doubleml as dml
import numpy as np
from sklearn.ensemble import RandomForestRegressor, RandomForestClassifier
from sklearn.linear_model import LassoCV

# Setup: data object
# Y: outcome (1D array), D: treatment (1D array), X: controls (2D array)
data = dml.DoubleMLData.from_arrays(X=X, y=Y, d=D)

# Choose learners for nuisance functions
# For continuous D: two regression learners
ml_g = RandomForestRegressor(n_estimators=100, max_depth=5, random_state=42)
ml_m = RandomForestRegressor(n_estimators=100, max_depth=5, random_state=42)

# Partially Linear Regression model
plr = dml.DoubleMLPLR(
    obj_dml_data=data,
    ml_g=ml_g,      # learner for E[Y|X]
    ml_m=ml_m,      # learner for E[D|X]
    n_folds=5,
    score='partialling out',
)
plr.fit()
print(plr.summary)

# For binary D: use classification learner for propensity
ml_m_binary = RandomForestClassifier(n_estimators=100, max_depth=5, random_state=42)
irm = dml.DoubleMLIRM(
    obj_dml_data=data,
    ml_g=ml_g,
    ml_m=ml_m_binary,
    n_folds=5,
    score='ATE',
)
irm.fit()
print(irm.summary)

# Cluster-robust standard errors
plr_clustered = dml.DoubleMLPLR(data, ml_g, ml_m, n_folds=5)
plr_clustered.fit()
# Pass cluster variable:
# data = dml.DoubleMLData.from_arrays(X=X, y=Y, d=D, cluster_cols=cluster_ids)
```

## Using the `DoubleML` Package (R)

```r
library(DoubleML)
library(mlr3)
library(mlr3learners)

# Create DoubleML data object
dml_data <- DoubleMLData$new(
  data = df,
  y_col = "outcome",
  d_cols = "treatment",
  x_cols = c("x1", "x2", "x3")  # control variables
)

# Specify learners (mlr3 ecosystem)
learner_g <- lrn("regr.ranger", num.trees = 100, max.depth = 5)
learner_m <- lrn("regr.ranger", num.trees = 100, max.depth = 5)

# Partially linear regression
plr <- DoubleMLPLR$new(
  data = dml_data,
  ml_g = learner_g,
  ml_m = learner_m,
  n_folds = 5
)
plr$fit()
plr$summary()

# For binary treatment (IRM)
learner_m_cls <- lrn("classif.ranger", num.trees = 100, max.depth = 5,
                     predict_type = "prob")
irm <- DoubleMLIRM$new(
  data = dml_data,
  ml_g = learner_g,
  ml_m = learner_m_cls,
  n_folds = 5,
  score = "ATE"
)
irm$fit()
irm$summary()
```

## DML Diagnostic Checklist

- [ ] **Nuisance fit quality**: Report R² (or classification accuracy) for both nuisance models (E[Y|X] and E[D|X]). Low R² on E[D|X] implies weak "first stage" — the controls barely explain treatment variation.
- [ ] **Residual balance**: After partialling out, regress V (D residuals) on X — coefficients should be near zero. If not, the ML model for E[D|X] is misspecified.
- [ ] **Cross-fitting fold stability**: Repeat with different random seeds. Estimates should be stable across seeds. Large variation implies insufficient sample size for the chosen ML method.
- [ ] **Compare K=5 vs K=10**: If estimates differ substantially, sample size may be too small for cross-fitting to work well.
- [ ] **Neyman orthogonality check**: Perturb nuisance estimates slightly — the main estimate should be insensitive. Large sensitivity suggests the score is not sufficiently orthogonal.
- [ ] **Trim extreme propensity scores**: For binary D, trim observations where E[D|X] is near 0 or 1 (e.g., below 0.01 or above 0.99). Extreme values inflate variance.

## Common DML Pitfalls

| Pitfall | Problem | Fix |
|---------|---------|-----|
| No cross-fitting | Overfitting bias in theta | Always use K-fold cross-fitting |
| Same learner for Y and D | Correlated errors across folds | Use separate model instances |
| Using DML R² as goodness-of-fit for causal claim | ML fit ≠ identification validity | Causal assumption is selection on observables — argue it separately |
| Ignoring clustering | Underestimated SEs in panel/clustered data | Pass cluster variable to DoubleML |
| Insufficient n for deep forests | ML models overfit → noisy nuisance | Use shallower trees, LASSO, or ElasticNet for smaller n |
