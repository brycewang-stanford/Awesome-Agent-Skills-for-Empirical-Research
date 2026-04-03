# Diagnostic Battery Reference

Comprehensive diagnostic battery for estimation results, organized by category. Use this reference to determine which tests apply, how to interpret results, and when to act on findings.

---

## 1. Estimation Type Detection

### Method Classification

| Method Class | Detection Signals | Example Packages |
|-------------|-------------------|-----------------|
| **OLS / WLS** | `lm`, `ols`, `OLS`, `feols` without IV syntax | statsmodels `OLS`, R `lm`, Stata `reg` |
| **IV / 2SLS** | `ivreg`, `iv2sls`, `feols` with `\|`, pipe syntax | `ivreg2`, `linearmodels.IV2SLS`, `AER::ivreg` |
| **GMM** | `gmm`, moment conditions, weighting matrix | `gmm` (R), `GMMResults`, custom moment code |
| **MLE** | `logit`, `probit`, `tobit`, `mle2`, `optim` with likelihood | statsmodels `Logit`/`Probit`, R `glm`, Stata `logit` |
| **Structural** | Custom optimization, `pyblp`, `NFXP`, `MPEC` | `scipy.optimize`, `pyblp`, JAX-based solvers |
| **Panel FE/RE** | `plm`, `PanelOLS`, `feols` with FE absorb syntax | `fixest::feols`, `linearmodels.PanelOLS`, Stata `xtreg` |

### Diagnostic Applicability Matrix

| Phase | OLS/WLS | IV/2SLS | GMM | MLE | Structural | Panel FE/RE |
|-------|---------|---------|-----|-----|-----------|-------------|
| Specification tests | Full | Full | Partial | Partial | No | Full |
| Instrument diagnostics | No | Full | Full | No | Partial | If IV |
| Residual diagnostics | Full | Full | No | Limited | No | Full |
| Model fit | Full | Full | Full | Full | Full | Full |

Before running tests, extract: N, K, clustering variable and count, FE dimensions, instrument list (if IV/GMM), endogenous variables (if IV/GMM), dependent variable name and type.

---

## 2. Specification Tests

### Hausman Test

| Context | Null Hypothesis | Rejection Means |
|---------|-----------------|-----------------|
| IV vs OLS | OLS is consistent (no endogeneity) | Endogeneity present; IV needed |
| FE vs RE | RE is consistent | RE inconsistent; use FE |

Report chi-squared statistic, degrees of freedom, p-value. Flag if p < 0.10, Fail if p < 0.05.

### RESET Test (Ramsey, 1969)

Tests functional form misspecification by including powers of fitted values (y-hat squared, y-hat cubed). Applies to OLS, IV, panel. Report F-statistic, p-value. Pass if p > 0.10, Flag if 0.05 < p < 0.10, Fail if p < 0.05.

### Omitted Variable / Link Test

Regress outcome on predicted values and their square. Significant squared term suggests missing variables or wrong functional form. For binary outcomes, use Pregibon's link test. Flag if squared term significant at p < 0.05.

### Multicollinearity

Inflates standard errors without biasing point estimates -- matters for inference, not consistency.

| Metric | Computation | Pass | Flag | Fail |
|--------|------------|------|------|------|
| **VIF** | 1 / (1 - R-sq from regressing Xj on other X's) | < 10 | 10-100 | > 100 |
| **Condition number** | Ratio of largest to smallest singular value of X'X | kappa < 30 | 30-1000 | > 1000 |
| **Pairwise correlations** | Pearson correlation of regressors | \|r\| < 0.8 | \|r\| > 0.8 | \|r\| > 0.95 |

### Structural Break / Stability

Applicable when data has a time dimension.

| Test | Use When |
|------|----------|
| **Chow test** | Known candidate break date |
| **CUSUM** | Unknown break date; plots cumulative sum of recursive residuals |
| **Bai-Perron** | Multiple unknown breaks; endogenous date selection |

Flag if instability detected. May require split-sample estimation or time-varying parameters.

---

## 3. Instrument Diagnostics

**Applies only to IV, 2SLS, and GMM.** Skip for OLS, MLE, and non-IV panel models.

### First-Stage Diagnostics

| Test | Pass | Flag | Fail |
|------|------|------|------|
| **First-stage F** | F > 10 | 4 < F < 10 | F < 4 |
| **Effective F** (Olea & Pflueger 2013) | Eff-F > 23.1 (10% worst-case bias) | 10 < Eff-F < 23.1 | Eff-F < 10 |
| **Partial R-squared** | Context-dependent | Low | Very low |
| **Shea's partial R-squared** | Higher is better | — | Near zero |

Report full first-stage regression for each endogenous variable with individual instrument coefficients, t-statistics, and joint F.

### Weak Instrument Robust Inference

When F < 10, standard 2SLS inference is unreliable:

- **Anderson-Rubin (AR) CI:** Valid regardless of instrument strength; may be unbounded.
- **Conditional LR** (Moreira 2003): More powerful than AR; conditions on sufficient statistic.
- **Stock-Yogo critical values:** Tabulated thresholds for specific bias/size tolerances.

Divergence between AR confidence set and standard Wald CI confirms a material weak instrument problem.

### Under-Identification Tests

| Test | Assumption | Null |
|------|-----------|------|
| **Kleibergen-Paap rk LM** | Heteroskedastic / clustered | Under-identified |
| **Anderson canonical correlations** | Homoskedastic | Under-identified |

Pass if p < 0.05 (reject under-identification). Flag if 0.05 < p < 0.10. Fail if p > 0.10.

### Over-Identification Tests

Applicable only when instruments outnumber endogenous variables.

| Test | Assumption | Null |
|------|-----------|------|
| **Sargan test** | Homoskedastic | All instruments valid |
| **Hansen J-test** | Heteroskedastic / clustered | All instruments valid |

Pass if p > 0.10. Flag if 0.05 < p < 0.10. Fail if p < 0.05. Caveat: J-test has low power with few overidentifying restrictions -- failure to reject does not prove validity.

---

## 4. Residual Diagnostics

### Normality

Non-normality affects exact finite-sample inference but not consistency. More consequential for MLE with distributional assumptions.

| Test | Best For | Assessment |
|------|----------|------------|
| **Jarque-Bera** | Large samples (N > 100) | Flag if p < 0.05 |
| **Shapiro-Wilk** | Small-moderate samples (N < 5000) | Flag if p < 0.05 |
| **D'Agostino-Pearson** | General purpose | Flag if p < 0.05 |

Report skewness and excess kurtosis alongside test statistics.

### Heteroskedasticity

| Test | Best For |
|------|----------|
| **White's test** | General heteroskedasticity (default first test) |
| **Breusch-Pagan** | Linear heteroskedasticity; more power against Var proportional to X-beta |
| **Goldfeld-Quandt** | Monotone heteroskedasticity in a single variable |

If detected (p < 0.05) with classical SEs: **critical failure** -- require HC-robust or clustered SEs. If robust SEs already used: note but no action needed.

### Serial Correlation

| Test | Data Type |
|------|-----------|
| **Durbin-Watson** | Time series. Pass: 1.5-2.5. Flag: 1.0-1.5 or 2.5-3.0. Fail: <1.0 or >3.0. |
| **Breusch-Godfrey** | Time series and panel. Tests up to lag p. |
| **Wooldridge test** | Panel data. Tests first-order autocorrelation. |

If detected, recommend Newey-West (time series) or clustered SEs (panel).

### Spatial Correlation

Moran's I test for spatial autocorrelation in residuals. If detected, recommend Conley (1999) SEs with appropriate distance cutoff. Flag if neither clustered nor Conley SEs are used.

### Influential Observations

Flag for researcher review -- never recommend automatic removal.

| Metric | Threshold | Detects |
|--------|-----------|---------|
| **Cook's D** | D > 4/N (flag), D > 1 (critical) | Observations shifting entire coefficient vector |
| **DFBETAS** | \|DFBETAS\| > 2/sqrt(N) | Observations shifting a specific coefficient |
| **Leverage** | h > 2K/N | Unusual X values (high potential influence) |
| **Studentized residuals** | \|r*\| > 3 | Outliers (unusual Y given X) |

Report counts by criterion and the top 5 most influential observations. High leverage alone is not a problem -- it becomes one when combined with a large residual.

---

## 5. Model Fit

### Goodness-of-Fit

| Metric | Applicable To | Notes |
|--------|--------------|-------|
| **R-squared** | OLS, IV, panel | Can be negative for IV |
| **Adjusted R-squared** | OLS, IV, panel | Penalizes additional regressors |
| **Within R-squared** | Panel FE | Relevant for FE; between-R-squared for RE |
| **Pseudo R-squared** | MLE (logit, probit) | McFadden; 0.2-0.4 is excellent |

### Information Criteria

| Criterion | Formula | Select Model With |
|-----------|---------|------------------|
| **AIC** | -2LL + 2K | Lowest; least penalization |
| **BIC** | -2LL + K * ln(N) | Lowest; penalizes complexity more |
| **HQIC** | -2LL + 2K * ln(ln(N)) | Lowest; intermediate |

AIC-BIC disagreement means additional parameters improve fit modestly but not enough to justify the BIC complexity penalty.

### Predictive Performance

| Metric | Interpretation |
|--------|---------------|
| **RMSE** | In outcome units; lower is better |
| **MAE** | Robust to outliers; in outcome units |
| **MAPE** | Percentage error; undefined if yi = 0 |
| **K-fold CV RMSE** | Out-of-sample accuracy (K = 5 or 10) |

Large gap between in-sample and CV performance indicates overfitting.

### Classification Metrics (Binary Outcomes)

| Metric | Good Value |
|--------|------------|
| **Percent correct** | Compare to naive baseline (predicting mode) |
| **AUC-ROC** | 0.5 = random, >0.7 acceptable, >0.8 excellent |
| **Hosmer-Lemeshow** | p > 0.05 indicates adequate calibration |

### Convergence (Iterative Estimators)

For MLE, GMM, and structural models. Non-convergence is a critical failure.

| Metric | Pass | Flag | Fail |
|--------|------|------|------|
| **Gradient norm** | < 1e-6 | 1e-6 to 1e-3 | > 1e-3 |
| **Iterations vs limit** | Well below limit | > 50% of limit | At or near limit |
| **Hessian condition** | kappa < 1e6 | 1e6 to 1e10 | > 1e10 |
| **Hessian positive definite** | Yes | — | No (SEs unreliable) |
| **Objective path** | Monotonically decreasing | Slow convergence | Cycling or flat |

---

## 6. Assessment Thresholds

### Master Table

| Test | Pass | Flag | Fail |
|------|------|------|------|
| First-stage F | F > 10 | 4-10 | F < 4 |
| Effective F | > 23.1 | 10-23.1 | < 10 |
| J-test / Sargan | p > 0.10 | 0.05-0.10 | p < 0.05 |
| White / BP test | p > 0.05 | — | p < 0.05 (classical SEs) |
| VIF | < 10 | 10-100 | > 100 |
| Condition number | kappa < 30 | 30-1000 | > 1000 |
| Durbin-Watson | 1.5-2.5 | 1.0-1.5 or 2.5-3.0 | < 1.0 or > 3.0 |
| Cook's D | All < 4/N | Some > 4/N | Many > 4/N or any > 1 |
| Gradient norm | < 1e-6 | 1e-6 to 1e-3 | > 1e-3 |
| Hessian condition | < 1e6 | 1e6-1e10 | > 1e10 |
| AUC-ROC | > 0.8 | 0.7-0.8 | < 0.7 |

### Overall Assessment

| Rating | Criteria |
|--------|---------|
| **PASS** | No failures; at most minor flags |
| **FLAG** | One or more non-critical flags; no critical failures |
| **FAIL** | One or more critical failures |

### Critical Failures (Require Action)

1. Weak instruments (F < 4) with no weak-instrument robust inference
2. Heteroskedasticity detected with classical (non-robust) SEs
3. Non-convergence or non-positive-definite Hessian
4. VIF > 100 (near-perfect collinearity)
5. Serial correlation detected with no HAC or clustered SEs

### Non-Critical Flags (Document in Paper)

1. First-stage F between 4 and 10 -- report AR confidence sets alongside Wald CIs
2. Marginal J-test rejection (0.05 < p < 0.10) -- discuss instrument validity
3. Moderate multicollinearity (10 < VIF < 100) -- note imprecision in affected coefficients
4. Non-normal residuals -- note for exact inference; not an issue asymptotically
5. Influential observations -- report sensitivity to their exclusion

---

## Key Packages

| Language | Packages |
|----------|----------|
| **Python** | `statsmodels.stats.diagnostic`, `linearmodels.iv.diagnostics`, `scipy.stats`, `sklearn.metrics` |
| **R** | `lmtest`, `sandwich`, `car` (vif), `spdep` (Moran's I), `AER`, `fixest`, `plm` |
| **Stata** | `estat`, `ovtest`, `linktest`, `vif`, `ivreg2`, `xttest`, `whitetst`, `bgodfrey` |
| **Julia** | `GLM.jl`, `HypothesisTests.jl`, `StatsBase.jl` |
