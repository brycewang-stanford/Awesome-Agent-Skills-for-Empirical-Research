# Connections to Traditional Methods — Reference

Understanding how causal ML relates to traditional methods helps build intuition and credibility with traditional audiences.

## DML Reduces to IV When Nuisance Models Are Linear

If E[Y|X] and E[D|X] are both estimated by OLS (linear projections), then DML's partialling out is numerically identical to the Frisch-Waugh-Lovell theorem. The DML θ̂ equals the OLS coefficient on D in a regression of Y on D and X.

This means: DML with linear nuisance models = standard OLS. DML adds value precisely when the nuisance functions are nonlinear — it allows flexible control for X while maintaining √n-inference on θ.

**Practical check:** Run DML with linear nuisance models (OLS) and compare to OLS with all controls. They should match. If not, there is a coding error.

## IV with DML Nuisance Models

DML extends naturally to IV. The partially linear IV model:

```
Y = θ₀ D + g₀(X) + ε
D = m₀(X) + v
Z: instrument with E[Z · ε | X] = 0
```

Cross-fitted IV moment: regress residualized Y on residualized D, instrumenting with residualized Z.

```python
# DoubleML: Partially linear IV
pliv = dml.DoubleMLPLIV(
    obj_dml_data=data,   # data must include Z (instrument)
    ml_g=ml_g,           # learner for E[Y|X]
    ml_m=ml_m,           # learner for E[D|X]
    ml_r=ml_r,           # learner for E[Z|X]  — partialling out Z
    n_folds=5,
)
pliv.fit()
print(pliv.summary)
```

## Causal Forests Generalize Local ATE

Standard IV/2SLS at a single instrument value (e.g., an RDD cutoff) gives LATE for compliers at that point. A causal forest with an instrument generalizes this to heterogeneous LATE across the covariate space:

```r
# R: grf — instrumental forest
iv_forest <- instrumental_forest(
  X = X_matrix,
  Y = Y_vector,
  W = W_treatment,   # endogenous treatment
  Z = Z_instrument,  # instrument
  seed = 42
)
tau_late_hat <- predict(iv_forest)$predictions
ate_late <- average_treatment_effect(iv_forest)
```

## Post-LASSO Generalizes 2SLS with Many Instruments

The many-instruments problem (Bekker 1994) causes 2SLS to be inconsistent when the number of instruments grows with n. Post-LASSO selects a sparse set of strong instruments, then runs standard 2SLS on the selected instruments. This connects to LIML and jackknife IV estimators.

```r
# R: hdm — LASSO for many instruments
# First, select relevant instruments using LASSO
lasso_z <- rlasso(D_vector ~ Z_matrix)  # regress D on instruments
selected_z <- which(lasso_z$coef != 0)

# Then run 2SLS with selected instruments
library(fixest)
iv_formula <- as.formula(
  paste("Y ~", paste(X_names, collapse = "+"),
        "| D ~ ", paste(Z_names[selected_z], collapse = "+"))
)
result_iv <- feols(iv_formula, data = df, vcov = "hetero")
print(result_iv)
```
