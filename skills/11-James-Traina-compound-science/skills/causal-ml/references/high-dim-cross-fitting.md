# High-Dimensional Controls and Cross-Fitting — Implementation Reference

## High-Dimensional Controls

Reference: Belloni, Chernozhukov, Hansen (2014), "Inference on treatment effects after selection among high-dimensional controls," *Review of Economic Studies*.

### When You Need This

You have many candidate control variables (p large relative to n) and want to:
1. Avoid overfitting by selecting controls automatically
2. Maintain valid inference on a treatment effect after selection
3. Avoid the Leeb-Pötscher problem: you cannot do inference on θ after LASSO selection of X unless you account for selection

**Key insight:** Running LASSO to predict Y and then doing OLS on the selected variables gives biased inference on D. You need post-double selection (PDS-LASSO) to avoid this.

### Post-Double Selection LASSO (PDS-LASSO)

The Belloni-Chernozhukov-Hansen (2014) procedure:

1. Run LASSO of Y on X → select variables S₁
2. Run LASSO of D on X → select variables S₂
3. Union: S = S₁ ∪ S₂
4. Run OLS of Y on D and all variables in S

The union step is critical: including variables that predict D (even if they don't add predictive power for Y) controls for confounders. Including variables that predict Y (even if they don't add for D) improves efficiency.

### Python: Manual PDS-LASSO

```python
import numpy as np
from sklearn.linear_model import LassoCV
import statsmodels.api as sm

def pds_lasso(Y, D, X, n_splits=5, random_state=42):
    """
    Post-double selection LASSO.

    Returns OLS estimate of treatment effect and standard error,
    controlling for selected variables.
    """
    # Step 1: LASSO of Y on X
    lasso_y = LassoCV(cv=n_splits, random_state=random_state)
    lasso_y.fit(X, Y)
    selected_y = np.where(np.abs(lasso_y.coef_) > 0)[0]

    # Step 2: LASSO of D on X
    lasso_d = LassoCV(cv=n_splits, random_state=random_state)
    lasso_d.fit(X, D)
    selected_d = np.where(np.abs(lasso_d.coef_) > 0)[0]

    # Step 3: Union of selected variables
    selected = np.union1d(selected_y, selected_d)
    print(f"Variables selected by Y-LASSO: {len(selected_y)}")
    print(f"Variables selected by D-LASSO: {len(selected_d)}")
    print(f"Union size: {len(selected)}")

    # Step 4: OLS with selected controls
    if len(selected) > 0:
        controls = X[:, selected]
        regressors = np.column_stack([D, controls])
    else:
        regressors = D.reshape(-1, 1)

    regressors_with_const = sm.add_constant(regressors)
    ols = sm.OLS(Y, regressors_with_const).fit(cov_type='HC3')

    # Treatment effect is the coefficient on D (index 1 after constant)
    theta_hat = ols.params[1]
    se = ols.bse[1]
    ci = ols.conf_int().iloc[1]

    return {
        'theta': theta_hat,
        'se': se,
        'ci_lo': ci[0],
        'ci_hi': ci[1],
        'n_selected': len(selected),
        'selected_idx': selected,
    }
```

### R: `hdm` Package

```r
library(hdm)

# Post-double selection LASSO via hdm
# Single treatment variable
pds <- rlassoEffect(
  x = X_matrix,        # control variables (n x p matrix)
  y = Y_vector,        # outcome
  d = D_vector,        # treatment
  method = "double selection"
)
print(pds)

# Inference on multiple treatment variables simultaneously
pds_multi <- rlassoEffects(
  x = X_matrix,
  y = Y_vector,
  d = D_matrix,        # multiple treatment variables
  method = "double selection"
)
summary(pds_multi)

# LASSO for variable selection only (then examine selected set)
lasso_y <- rlasso(Y_vector ~ X_matrix)
lasso_d <- rlasso(D_vector ~ X_matrix)

selected_y <- which(lasso_y$coef != 0)
selected_d <- which(lasso_d$coef != 0)
selected_union <- union(selected_y, selected_d)
cat("Union size:", length(selected_union), "\n")
```

### Practical Guidance for High-Dimensional Controls

**Choosing the LASSO penalty:**
- Use theory-based (Belloni-Chernozhukov) penalty: λ = 2c · σ̂ · √(n log p) for some constant c. This is what `hdm::rlasso` uses by default.
- Cross-validation (LassoCV) is common in practice but does not have the same theoretical guarantees for post-selection inference. Prefer `hdm` for formal inference.

**When p > n:**
- PDS-LASSO still works if the true model is sparse (few controls truly matter)
- If the true model is dense (many controls each with small effect), consider ridge or elastic net nuisance models within DML instead

**Interactions and polynomials:**
- You may want to include interactions D × X in the control set for the Y-LASSO step (to detect effect modifiers)
- But do NOT include D × X in the D-LASSO step — these are endogenous by construction

### PDS-LASSO Diagnostic Checklist

- [ ] **Selected variable set is interpretable**: Review which controls were selected. Variables strongly correlated with both Y and D should appear in the union.
- [ ] **First-stage effective F-stat**: After union selection, check that D is not partialled out (residual variance is not too small). Compute F from regression of D on selected controls.
- [ ] **Sensitivity to LASSO penalty**: Vary λ by factor of 0.5 and 2. Selected set should not change dramatically.
- [ ] **Compare PDS to OLS with all controls**: If PDS estimate differs substantially from OLS with full X, either the high-dimensional OLS is overfitting or there is important nonlinearity.
- [ ] **Sparsity assumption**: PDS-LASSO requires that few controls truly matter. If you expect dense effects (all controls matter a little), DML with ridge/elastic net is more appropriate.
- [ ] **Post-selection F-stat on treatment**: After union selection, report the partial F-statistic on D in the first-stage regression — confirms that the selected controls do not absorb all variation in D.

### Common PDS-LASSO Pitfalls

| Pitfall | Problem | Fix |
|---------|---------|-----|
| Using LassoCV without union step | Biased inference (post-selection problem) | Always use the union of Y-LASSO and D-LASSO selected sets |
| One-step LASSO (LASSO of Y on D and X jointly) | Treatment coefficient is regularized toward zero | Use PDS or DML — never regularize the causal parameter |
| Ignoring penalty choice | CV lambda is optimized for prediction, not inference | Use theory-based lambda (hdm package) for inference |
| p >> n without sparsity | LASSO may select noise variables | Validate selection stability; consider ridge DML instead |

---

## Sample Splitting and Cross-Fitting

### Why Naive ML-in-Regression Fails

Consider fitting Y ~ θD + g(X) with LASSO. The LASSO regularizer penalizes θ just as it penalizes the coefficients on X. Even with large n, θ̂ is biased toward zero by the regularization — this bias does not vanish.

More generally, if you use the same data to (a) learn the nuisance function g(X) and (b) estimate θ, the estimation error in (a) contaminates (b) at first order. The result is that √n-convergence of θ̂ breaks down.

**Solution:** Cross-fitting separates these two estimation tasks across data folds.

### K-Fold Cross-Fitting Step by Step

```
1. Partition {1, ..., n} into K folds I₁, ..., I_K of approximately equal size.

2. For k = 1, ..., K:
   a. Training set: I^c_k = {1,...,n} \ I_k  (all folds except fold k)
   b. Fit nuisance model ĝ_k on training set I^c_k
   c. Compute residuals Ŵ_i = Y_i - ĝ_k(X_i) for all i ∈ I_k

3. Each observation gets one residual Ŵ_i from the fold in which it was held out.

4. Same procedure for D: Ṽ_i = D_i - m̂_k(X_i) for i ∈ I_k

5. Pool all residuals: use (Ŵ₁, ..., Ŵ_n) and (Ṽ₁, ..., Ṽ_n) for final inference.

6. θ̂ = (Σ Ṽ_i Ŵ_i) / (Σ Ṽ_i²) — OLS of Ŵ on Ṽ (no intercept)
```

### Practical Choices for K

| K | When to use | Trade-off |
|---|-------------|-----------|
| K = 2 | Minimal (not recommended) | Low computation, but each training set is only n/2 |
| K = 5 | Default (recommended) | Good balance of bias and training set size |
| K = 10 | Large samples | Small held-out set; each nuisance model trained on 90% |
| K = n (LOOCV) | Do not use for DML | Computationally infeasible; no clear benefit |

**Tip:** With K=5, each nuisance model is trained on 80% of the data. This is large enough for random forests and LASSO to be well-fit on most empirically realistic samples (n > 1,000).

### Cross-Fitting from Scratch (Illustrative)

```python
import numpy as np
from sklearn.model_selection import KFold
from sklearn.ensemble import RandomForestRegressor
import statsmodels.api as sm

def dml_crossfit(Y, D, X, n_splits=5, seed=42):
    """
    Full DML cross-fitting with inference.
    Assumes partially linear model: Y = theta*D + g(X) + eps
    """
    n = len(Y)
    W_hat = np.zeros(n)  # Y - E[Y|X]
    V_hat = np.zeros(n)  # D - E[D|X]

    kf = KFold(n_splits=n_splits, shuffle=True, random_state=seed)

    r2_y_list, r2_d_list = [], []

    for fold_idx, (train_idx, test_idx) in enumerate(kf.split(X)):
        # Nuisance models
        rf_y = RandomForestRegressor(n_estimators=200, max_depth=5, random_state=seed)
        rf_d = RandomForestRegressor(n_estimators=200, max_depth=5, random_state=seed)

        rf_y.fit(X[train_idx], Y[train_idx])
        rf_d.fit(X[train_idx], D[train_idx])

        Y_pred = rf_y.predict(X[test_idx])
        D_pred = rf_d.predict(X[test_idx])

        W_hat[test_idx] = Y[test_idx] - Y_pred
        V_hat[test_idx] = D[test_idx] - D_pred

        # Nuisance fit diagnostics
        ss_res_y = np.sum((Y[test_idx] - Y_pred) ** 2)
        ss_tot_y = np.sum((Y[test_idx] - Y[test_idx].mean()) ** 2)
        r2_y_list.append(1 - ss_res_y / ss_tot_y)

        ss_res_d = np.sum((D[test_idx] - D_pred) ** 2)
        ss_tot_d = np.sum((D[test_idx] - D[test_idx].mean()) ** 2)
        r2_d_list.append(1 - ss_res_d / ss_tot_d)

    print(f"Mean R2 (Y nuisance): {np.mean(r2_y_list):.3f}")
    print(f"Mean R2 (D nuisance): {np.mean(r2_d_list):.3f}")

    # DML estimate
    theta_hat = np.dot(V_hat, W_hat) / np.dot(V_hat, V_hat)

    # Influence function SE
    psi = V_hat * (W_hat - theta_hat * V_hat)
    J = np.mean(V_hat ** 2)
    var = np.mean(psi ** 2) / J ** 2
    se = np.sqrt(var / n)

    ci_lo = theta_hat - 1.96 * se
    ci_hi = theta_hat + 1.96 * se

    print(f"\nDML Estimate: {theta_hat:.4f}")
    print(f"SE:           {se:.4f}")
    print(f"95% CI:       [{ci_lo:.4f}, {ci_hi:.4f}]")

    return theta_hat, se

# Usage
theta, se = dml_crossfit(Y=y, D=d, X=X_controls)
```

### Aggregating Estimates Across Folds

When implementing DML with repeated cross-fitting (recommended for stability), run the full K-fold procedure M times with different random seeds and aggregate:

```python
def dml_repeated(Y, D, X, n_splits=5, n_reps=5):
    """DML with repeated cross-fitting for stability."""
    estimates = []
    for rep in range(n_reps):
        theta_r, _ = dml_crossfit(Y, D, X, n_splits=n_splits, seed=rep * 42)
        estimates.append(theta_r)

    # Median aggregation (more robust than mean)
    theta_final = np.median(estimates)
    print(f"Median across {n_reps} repetitions: {theta_final:.4f}")
    print(f"Std across repetitions: {np.std(estimates):.4f}")
    return theta_final
```

A large standard deviation across repetitions signals that the ML models are unstable — either the sample is too small or the models are too complex.
