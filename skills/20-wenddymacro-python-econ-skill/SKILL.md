---
name: python-econ-computing
description: Use when writing Python code for DSGE models, HANK models, numerical economic computation, causal inference, or quantitative economic data analysis
---

# Python Economic Numerical Computing
- Author：Wenli Xu
- Email： wlxu@cityu.edu.mo
- 2026-03-11
---


## Overview

Best practices for macroeconomic modeling (DSGE/HANK), causal inference, and data analysis in Python. Core principle: **vectorize first, accelerate loops with Numba, keep code structure aligned with economic theory**.

---

## Library Quick Reference

| Use Case | Preferred Libraries |
|----------|-------------------|
| Numerical core | `numpy`, `scipy` |
| Loop acceleration | `numba` (`@njit`, `@njit(parallel=True)`) |
| Economics toolkit | `quantecon` |
| HANK / sequence space | `sequence_jacobian` (SSJ) |
| Heterogeneous agents | `HARK` |
| **Linear models with FE** | **`pyfixest`** (`pip install pyfixest`) |
| **DID / DD / DDD** | **`diff-diff`** (`pip install diff-diff`) |
| **IV / 2SLS / GMM** | **`linearmodels`** (or `pyfixest` for panel IV with FE) |
| **RD / RDD / RKD** | **`rdrobust`**, `rddensity`, `rdlocrand` |
| **Synthetic Control** | **`pysynth`**, `synth_control`, `sdid` |
| **Matching** | **`causalml`**, `pymatch`, `econml` |
| **Causal ML / DML** | **`econml`**, `dowhy` |
| Data manipulation | `pandas`, `polars` (large datasets) |
| Visualization | `matplotlib`, `seaborn` |

---

## DSGE Models

### Linearization and Solution (Blanchard-Kahn)

```python
import numpy as np
from scipy.linalg import ordqz

def solve_bk(A, B, n_fwd):
    """
    Solve linear DSGE: A E_t[x_{t+1}] = B x_t + C eps_t
    n_fwd: number of forward-looking variables
    Returns decision rule matrix P such that x_t = P x_{t-1} + ...
    """
    AA, BB, alpha, beta, Q, Z = ordqz(A, B, sort='ouc')
    n = A.shape[0]
    Z21 = Z[n - n_fwd:, :n - n_fwd]
    Z22 = Z[n - n_fwd:, n - n_fwd:]
    P = -np.linalg.solve(Z22, Z21)
    return P
```

### Perturbation Methods (Second-Order Approximation)

- Use `quantecon.lqcontrol` for LQ problems
- Higher-order perturbation: `perturbpy` or manual implementation
- Steady-state solving: `scipy.optimize.fsolve` / `root`

---

## HANK Models

### Sequence-Space Jacobian Method (SSJ)

```python
import sequence_jacobian as sj

# 1. Define steady-state blocks
@sj.simple
def household_ss(r, w, beta, sigma):
    # Return steady-state aggregates
    ...

# 2. Build DAG
model = sj.create_model([household_block, firm_block, market_clearing],
                         name='HANK')

# 3. Solve steady state
ss = model.solve_steady_state(calibration, unknowns, targets)

# 4. Compute Jacobians → solve transition dynamics
G = model.solve_jacobian(ss, unknowns, targets, T=300)
```

### Value Function Iteration — Numba Accelerated

```python
from numba import njit
import numpy as np

@njit
def vfi(V0, a_grid, y_grid, r, beta, sigma, tol=1e-8, max_iter=1000):
    """Heterogeneous agent VFI over asset grid × income grid"""
    n_a, n_y = len(a_grid), len(y_grid)
    V = V0.copy()
    policy = np.zeros((n_a, n_y))

    for it in range(max_iter):
        V_new = np.empty_like(V)
        for ia in range(n_a):
            for iy in range(n_y):
                best_val = -1e10
                best_a = 0
                for ia2 in range(n_a):
                    c = (1 + r) * a_grid[ia] + y_grid[iy] - a_grid[ia2]
                    if c <= 0:
                        continue
                    u = c ** (1 - sigma) / (1 - sigma)
                    val = u + beta * V[:, iy].mean()  # use transition matrix in practice
                    if val > best_val:
                        best_val = val
                        best_a = ia2
                V_new[ia, iy] = best_val
                policy[ia, iy] = a_grid[best_a]
        if np.max(np.abs(V_new - V)) < tol:
            break
        V = V_new
    return V, policy
```

### Distribution Iteration (Young 2010)

```python
def iterate_distribution(policy_idx, trans_mat, dist0, T=500):
    """Iterate joint distribution to steady state given policy indices and income transition matrix"""
    dist = dist0.copy()
    n_a, n_y = dist.shape
    for _ in range(T):
        dist_new = np.zeros_like(dist)
        for iy in range(n_y):
            for iy2 in range(n_y):
                dist_new[policy_idx[:, iy], iy2] += dist[:, iy] * trans_mat[iy, iy2]
        dist = dist_new
    return dist
```

---

## Linear Models with Fixed Effects (pyfixest)

**Rule: For any OLS/Poisson/Logit with fixed effects, use `pyfixest`. It mirrors R's `fixest` syntax.**

```python
import pyfixest as pf

# OLS with unit + time FE, cluster-robust SEs
fit = pf.feols("y ~ treat_post | unit + year",
               data=df, vcov={"CRV1": "id"})
fit.summary()

# Multiple high-dimensional FE (Frisch-Waugh absorbed)
fit = pf.feols("y ~ x1 + x2 | unit + year + industry",
               data=df, vcov={"CRV1": "id"})

# Wild cluster bootstrap (few clusters, <50)
fit = pf.feols("y ~ treat_post | unit + year",
               data=df, vcov={"CRV1": "id"})
fit.wildboottest(param="treat_post", B=9999, seed=42)

# Event study via i() syntax
fit = pf.feols("y ~ i(rel_year, ref=-1) | unit + year",
               data=df, vcov={"CRV1": "id"})
pf.iplot(fit)  # event study plot

# Poisson (count / log-linear) with FE
fit_pois = pf.fepois("y ~ treat_post | unit + year",
                     data=df, vcov={"CRV1": "id"})

# Access results
fit.coef()           # coefficient estimates
fit.se()             # standard errors
fit.pvalue()         # p-values
fit.confint()        # confidence intervals
fit._N               # number of observations
```

### pyfixest vs statsmodels

| Use case | Use |
|----------|-----|
| OLS / WLS with any FE | `pyfixest` |
| Poisson / logit with FE | `pyfixest` |
| Wild bootstrap | `pyfixest` |
| Time-series ARIMA, VAR | `statsmodels` |
| MLE / GLM without FE | `statsmodels` |

---

## Causal Inference: DID / DD / DDD Methods

**Rule: For any DiD, DD, DDD, or staggered difference-in-differences design, use `diff-diff` and follow the General Empirical Workflow below.**

Source: https://github.com/igerber/diff-diff | https://github.com/wenddymacro/A-General-Empirical-Workflow-for-DID

### diff-diff Estimator Reference

| Alias | Class | Use When |
|-------|-------|----------|
| `DiD` | `DifferenceInDifferences` | Basic 2×2 DiD |
| `TWFE` | `TwoWayFixedEffects` | Standard panel DiD |
| `EventStudy` | `MultiPeriodDiD` | Dynamic effects / event study |
| `CS` | `CallawaySantAnna` | Staggered adoption, heterogeneous effects |
| `SA` | `SunAbraham` | Staggered, avoids negative weights |
| `BJS` | `ImputationDiD` | Borusyak et al. imputation approach |
| `SDiD` | `SyntheticDiD` | Synthetic DiD |
| `DDD` | `TripleDifference` | Triple difference |

### Key API Parameters

```python
from diff_diff import DiD, TWFE, EventStudy, CS, SA, BJS, DDD

# Common fit() arguments
results = estimator.fit(
    data,
    outcome='y',           # dependent variable
    treatment='treated',   # binary treatment indicator
    time='post',           # binary post-period (or period var for panel)
    unit='id',             # unit identifier (panel)
    covariates=['x1','x2'],# control variables
    absorb=['region'],     # high-dim fixed effects (within-transform)
    cluster='id',          # clustered standard errors
    robust=True,           # HC1 robust SEs
    inference='wild_bootstrap',  # for few clusters (<50)
    n_bootstrap=999,
)

# Results
results.att           # ATT estimate
results.se            # standard error
results.p_value
results.conf_int      # confidence interval tuple
results.print_summary()
results.to_dataframe()
```

### DDD (Triple Difference)

```python
from diff_diff import DDD

ddd = DDD()
results = ddd.fit(
    data,
    outcome='y',
    treatment='treated',
    time='post',
    third_diff='group_var',  # third differencing dimension
    cluster='id',
)
```

---

## DID Empirical Workflow (11 Steps)

Follow this workflow for every DID/DD/DDD paper or analysis.

### Step 1 — Data & Descriptive Statistics

- Construct panel: define units, time span, treatment variable
- Document data sources, missing values, winsorization
- Describe cohort structure (treated units per cohort, policy onset dates)
- **Table:** full-sample stats + treated vs. control comparison with t-tests
- Pre-treatment covariate balance test

**Covariate types:**

| Type | Form | Purpose |
|------|------|---------|
| Covariates | Pre-treatment, time-invariant | Condition parallel trends |
| Control variables | Baseline × time trend | Absorb residual heterogeneity |

### Step 2 — Identification Strategy

State and justify:
1. **Parallel trends** — partially testable via pre-period event study
2. **SUTVA / no interference** — argue no cross-unit spillovers
3. **No anticipation** — pre-period coefficients should be zero

Document policy assignment mechanism; cite policy documents for exogeneity.

### Step 3 — Baseline Regression

Model:
$$Y_{it} = \alpha + \beta(\text{Treat}_i \times \text{Post}_{it}) + \gamma W_i + \delta(Z_i^{pre} \times t) + \mu_i + \lambda_t + \varepsilon_{it}$$

Run **six progressive specifications** (M1–M6):

| Model | Unit FE | Time FE | Covariates | Baseline×Trend | Regional FE | Unit Trend |
|-------|---------|---------|-----------|----------------|------------|-----------|
| M1 | ✓ | — | — | — | — | — |
| M2 | ✓ | ✓ | — | — | — | — |
| M3 | ✓ | ✓ | ✓ | ✓ | — | — |
| M4 | ✓ | ✓ | ✓ | ✓ | ✓ | — |
| M5 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| M6 | ✓ | ✓ | ✓ | ✓ | Industry×Year | ✓ |

Coefficient stability across M1→M6 supports identification. Report **Oster (2019) δ\*** (selection bias ratio); |δ*| > 1 = basic robustness, |δ*| > 2 = strong.

```python
import pyfixest as pf

# M1: unit FE only
pf.feols("y ~ treat_post | unit", data=df, vcov={"CRV1": "id"}).summary()

# M2: unit + time FE
pf.feols("y ~ treat_post | unit + year", data=df, vcov={"CRV1": "id"}).summary()

# M3–M4: add covariates and baseline×trend
pf.feols("y ~ treat_post + x1 + x2 + baseline:year | unit + year",
         data=df, vcov={"CRV1": "id"}).summary()

# M5: + regional FE
pf.feols("y ~ treat_post + x1 + x2 + baseline:year | unit + year + region",
         data=df, vcov={"CRV1": "id"}).summary()

# M6: + industry×year FE
pf.feols("y ~ treat_post + x1 + x2 + baseline:year | unit + industry^year",
         data=df, vcov={"CRV1": "id"}).summary()
```

### Step 4 — Parallel Trends: Event Study Plots

```python
from diff_diff import EventStudy

es = EventStudy()
res = es.fit(data, outcome='y', treatment='treated',
             unit='id', time='year', base_period=-1,
             cluster='id')
res.plot()  # shows pre/post coefficients with CIs
```

**Plot standards:**
- Y-axis: "Coefficient (ATT)"; X-axis: "Years relative to policy"
- Reference lines at 0; base period k = −1 omitted
- Show M6 in main text; M1–M5 in appendix
- Pre-period coefficients (k ∈ {−4,−3,−2}) should be statistically insignificant

**Run all estimators for staggered designs:**

```python
from diff_diff import CS, SA, BJS

# Callaway & Sant'Anna (2021)
cs = CS().fit(data, outcome='y', unit='id', time='year',
              cohort='treat_year', control_group='never_treated', cluster='id')

# Sun & Abraham (2021)
sa = SA().fit(data, outcome='y', unit='id', time='year',
              cohort='treat_year', cluster='id')

# Borusyak et al. (2024) imputation
bjs = BJS().fit(data, outcome='y', unit='id', time='year',
                cohort='treat_year', horizons=range(5), cluster='id')
```

### Step 5 — Parallel Trends Sensitivity: HonestDiD

Use Rambachan-Roth (2023) bounds to quantify robustness to parallel trends violations.

```python
# After event study, extract pre/post coefficients and covariance
# Pass to HonestDiD (R package via rpy2, or use diff-diff's built-in honest DiD)
from diff_diff import EventStudy

es = EventStudy()
res = es.fit(data, ..., honest_did=True,
             sensitivity_constraint='smoothness')
res.plot_honest_did()  # shows identified set under relaxed PT assumption
```

### Step 6 — Rule Out Alternative Explanations

| Threat | Test |
|--------|------|
| Spatial spillovers | Geographic placebo; effect by distance from treated units |
| Anticipation effects | Pre-period event-study coefficients ≈ 0 |
| Policy overlap | Exclude or control for concurrent policies |

### Step 7 — Robustness Checks

```python
from diff_diff import DiD
from diff_diff.diagnostics import PlaceboTest, GoodmanBaconDecomposition

# Goodman-Bacon decomposition (TWFE bias diagnosis)
gb = GoodmanBaconDecomposition().fit(data, outcome='y', treatment='treated',
                                      unit='id', time='year')
gb.plot()

# Placebo tests
placebo = PlaceboTest(method='fake_timing').fit(data, ...)
placebo = PlaceboTest(method='permutation', n_permutations=500).fit(data, ...)

# Subsample / specification robustness
for subsample_mask in subsamples:
    res = CS().fit(data[subsample_mask], ...)
```

Standard robustness battery:
- Placebo / fake timing
- Falsification on pre-reform period
- Alternative outcome variables
- Subsample splits by pre-determined characteristics
- Randomization inference

### Step 8 — Heterogeneous Treatment Effects

```python
# Triple difference for effect heterogeneity by subgroup Z
from diff_diff import DDD

ddd = DDD().fit(data, outcome='y', treatment='treated',
                time='post', third_diff='high_exposure', cluster='id')

# Interaction-based heterogeneity in TWFE
from diff_diff import TWFE
res = TWFE().fit(data, outcome='y',
                 treatment='treat_post',
                 interactions=['treat_post:firm_size'],
                 absorb=['id', 'year'], cluster='id')
```

### Step 9 — Mechanism Analysis

1. **Outcome ladder:** immediate → intermediate → final outcome
2. **Mediation:** include proposed mechanism as control; compare ATT with/without
3. **Heterogeneity as mechanism:** subgroup event studies by initial conditions

### Step 10 — Welfare & Policy Implications

- Aggregate ATTs to policy-level impacts
- Cost-benefit ratios
- Distributional effects (winners vs. losers)

### Step 11 — Full Workflow Summary

```
1. Data & balance
2. Identification assumptions
3. Baseline specs M1–M6 + Oster δ*
4. Event study (TWFE + CS + SA + BJS)
5. HonestDiD sensitivity
6. Alternative explanations
7. Robustness battery
8. Heterogeneous effects (DDD / interactions)
9. Mechanisms
10. Welfare implications
```

---

## Causal Inference: Method Selection

```
What is your identification strategy?
├── Policy/treatment with parallel trends → DID (see above)
├── Exogenous instrument for endogenous X → IV
├── Discontinuity in assignment rule → RD / RKD
├── Control units that can be reweighted → Synthetic Control
├── Selection on observables → Matching / IPW
└── High-dimensional / ML setting → DML / Causal Forest
```

---

## Instrumental Variables (IV / 2SLS / GMM)

**Library:** `linearmodels` (preferred over statsmodels for panel IV)

**Key assumptions:** Relevance (F > 10, ideally > 104 per Lee et al. 2022), Exclusion restriction, Independence.

```python
from linearmodels.iv import IV2SLS, IVGMM, IVLIML

# Basic 2SLS: y ~ X_exog + [X_endog ~ Z_instruments]
res = IV2SLS(dependent=y,
             exog=X_exog,        # included exogenous (+ constant)
             endog=X_endog,      # endogenous regressors
             instruments=Z).fit(cov_type='robust')

# Panel IV with fixed effects
from linearmodels import PanelOLS, BetweenOLS
from linearmodels.iv import IV2SLS
# absorb FE first (within transform), then IV on residuals
# or use linearmodels.panel with IV support

# GMM (efficient with heteroskedasticity)
res = IVGMM(y, X_exog, X_endog, Z).fit(cov_type='robust')

# LIML (less biased with weak instruments)
res = IVLIML(y, X_exog, X_endog, Z).fit(cov_type='robust')

# Key diagnostics
print(res.first_stage)          # first-stage F-statistic
print(res.wooldridge_score)     # endogeneity test (H0: OLS consistent)
print(res.sargan)               # overidentification test (J-stat, requires overid)
```

### IV Diagnostics Checklist

| Test | What it checks | Pass if |
|------|---------------|---------|
| First-stage F | Instrument relevance | F > 104 (Lee et al.) or > 10 (rule of thumb) |
| Cragg-Donald / Kleibergen-Paap | Weak instrument (multiple endog) | > Stock-Yogo critical values |
| Sargan-Hansen J-test | Overidentification (exclusion) | p > 0.1 (can't reject validity) |
| Hausman / Wooldridge | Endogeneity of X | p < 0.05 → IV needed |
| Reduced form | Instrument affects outcome | Should be significant |

```python
# Anderson-Rubin confidence set (robust to weak instruments)
from linearmodels.iv import IV2SLS
res = IV2SLS(y, X_exog, X_endog, Z).fit(cov_type='robust')
print(res.anderson_rubin)  # AR test, valid even with weak instruments

# Conley spatial HAC SEs (geographic instruments)
res = IV2SLS(y, X_exog, X_endog, Z).fit(cov_type='kernel', bandwidth=5)
```

### Bartik / Shift-Share IV

```python
# Bartik instrument: Z_i = sum_k s_{ik} * g_k
# s_{ik}: industry share of unit i; g_k: national industry growth
import numpy as np

def bartik_instrument(shares, growth):
    """
    shares: (n_units, n_industries)
    growth: (n_industries,)
    returns: (n_units,) Bartik instrument
    """
    return shares @ growth
```

---

## Regression Discontinuity (RD / RKD / Fuzzy RD)

**Library:** `rdrobust` (Python port of R package)

**Key assumption:** Units cannot precisely manipulate the running variable around the cutoff.

```python
from rdrobust import rdrobust, rdbwselect, rdplot

# Sharp RD
res = rdrobust(y, x, c=cutoff)          # default: MSE-optimal bandwidth, local linear
res = rdrobust(y, x, c=0,
               kernel='triangular',     # triangular (default) / uniform / epanechnikov
               bwselect='mserd',        # MSE-optimal (default); 'cerrd' for coverage
               vce='hc1',              # robust SEs
               cluster=cluster_var)
print(res)

# Fuzzy RD (instrument = 1[x >= c])
res_fuzzy = rdrobust(y, x, c=0,
                     fuzzy=treatment_var)  # IV-style, estimates LATE

# Bandwidth selection
bw = rdbwselect(y, x, c=0, bwselect='mserd')
print(bw.bws)    # optimal bandwidth

# Visualization
rdplot(y, x, c=0)   # binned scatter with polynomial fit
```

### RD Diagnostics Checklist

```python
from rddensity import rddensity
from rdrobust import rdrobust

# 1. McCrary density test (H0: no manipulation at cutoff)
den = rddensity(x, c=cutoff)
print(den.test)   # p > 0.05: no evidence of manipulation

# 2. Covariate smoothness (placebo on pre-determined covariates)
for cov in baseline_covariates:
    res = rdrobust(cov, x, c=cutoff)
    print(f'{cov}: {res.coef[0]:.3f} (p={res.pv[2]:.3f})')  # should be insignificant

# 3. Placebo cutoffs (should find no effect at fake cutoffs)
for fake_c in [cutoff - 0.5, cutoff + 0.5]:
    res = rdrobust(y, x, c=fake_c)
    print(f'Placebo c={fake_c}: {res.coef[0]:.3f}')

# 4. Sensitivity to bandwidth
for h in [bw_opt * 0.5, bw_opt * 0.75, bw_opt, bw_opt * 1.25, bw_opt * 1.5]:
    res = rdrobust(y, x, c=cutoff, h=h)
    print(f'h={h:.2f}: {res.coef[0]:.3f}')

# 5. Donut hole (exclude units very close to cutoff)
mask = np.abs(x - cutoff) > donut_radius
res_donut = rdrobust(y[mask], x[mask], c=cutoff)
```

### Regression Kink Design (RKD)

```python
# RKD: identifies effect via kink (slope discontinuity) rather than level jump
res_rkd = rdrobust(y, x, c=cutoff, deriv=1)  # deriv=1 estimates slope discontinuity
```

---

## Synthetic Control

**Use when:** Few treated units (often N=1), long pre-treatment panel, no obvious control group.

**Libraries:** `pysynth`, `synth_control` (pip), or manual implementation via `scipy.optimize`.

```python
# --- Option 1: pysynth ---
from pysynth import Synth

sc = Synth()
sc.fit(
    dataprep={
        'foo_table': df,
        'predictors': ['gdp', 'trade', 'invest'],
        'predictors_op': 'mean',
        'time_predictors_prior': list(range(1980, 1990)),
        'special_predictors': [('gdp', [1985, 1988], 'mean')],
        'dependent': 'gdp',
        'unit_variable': 'country',
        'time_variable': 'year',
        'treatment_identifier': 'basque',
        'controls_identifier': control_countries,
        'time_optimize_ssr': list(range(1960, 1990)),
        'time_plot': list(range(1960, 1998)),
    }
)
sc.plot(['trends', 'weights', 'gaps'])

# --- Option 2: manual (scipy) ---
from scipy.optimize import minimize
import numpy as np

def synth_loss(w, Y_pre_control, Y_pre_treated):
    """Minimize pre-treatment fit: ||Y_treated - Y_control @ w||^2"""
    return np.sum((Y_pre_treated - Y_pre_control @ w) ** 2)

n_controls = Y_pre_control.shape[1]
w0 = np.ones(n_controls) / n_controls
constraints = [{'type': 'eq', 'fun': lambda w: w.sum() - 1}]
bounds = [(0, 1)] * n_controls

res = minimize(synth_loss, w0,
               args=(Y_pre_control, Y_pre_treated),
               method='SLSQP',
               bounds=bounds,
               constraints=constraints)
w_opt = res.x
Y_synth = Y_post_control @ w_opt
gap = Y_post_treated - Y_synth
```

### Synthetic Control Diagnostics

```python
# Pre-treatment fit (RMSPE)
rmspe_pre = np.sqrt(np.mean((Y_pre_treated - Y_pre_control @ w_opt)**2))

# Placebo tests: apply SC to each control unit, compute distribution of gaps
placebo_gaps = []
for ctrl in control_units:
    Y_treated_placebo = Y_pre[:, ctrl_idx]
    Y_control_placebo = np.delete(Y_pre, ctrl_idx, axis=1)
    # ... fit and store gap
    placebo_gaps.append(gap_placebo)

# Ratio: treated RMSPE_post / RMSPE_pre vs. controls (Abadie et al. 2010)
ratio_treated = rmspe_post / rmspe_pre
# Inference: fraction of placebos with ratio >= ratio_treated → p-value

# In-time placebo: apply SC using period before actual treatment as fake treatment
# In-space placebo: already done above
```

### Synthetic DiD (SDiD)

```python
# Combines SC weights with DiD — robust to both parallel trends violations and
# imperfect pre-treatment fit
from diff_diff import SDiD

sdid = SDiD()
res = sdid.fit(data, outcome='y', treatment='treated',
               unit='id', time='year', cluster='id')
res.print_summary()
```

---

## Matching and Reweighting

**Use when:** Selection on observables; rich baseline covariate data.

**Estimands:** ATT (treated vs. matched controls), ATE (population average).

### Propensity Score Methods

```python
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import StandardScaler
import numpy as np

# 1. Estimate propensity score
X_scaled = StandardScaler().fit_transform(X_covariates)
ps_model = LogisticRegression(C=1.0, max_iter=1000)
ps_model.fit(X_scaled, treatment)
p_score = ps_model.predict_proba(X_scaled)[:, 1]

# 2. Check overlap / common support
import matplotlib.pyplot as plt
plt.hist(p_score[treatment==1], alpha=0.5, label='Treated', bins=30)
plt.hist(p_score[treatment==0], alpha=0.5, label='Control', bins=30)
plt.legend(); plt.xlabel('Propensity Score')
# Trim tails: drop obs with p_score outside [0.05, 0.95]
mask = (p_score >= 0.05) & (p_score <= 0.95)
```

### IPW / AIPW (Doubly Robust)

```python
from econml.dr import LinearDRLearner
from sklearn.linear_model import LassoCV, LogisticRegressionCV

# Doubly robust (AIPW) — consistent if either outcome or propensity model correct
dr = LinearDRLearner(
    model_regression=LassoCV(),      # outcome model
    model_propensity=LogisticRegressionCV(),  # propensity model
    featurizer=None
)
dr.fit(Y, T, X=X_het, W=X_controls)  # X: effect modifiers, W: controls
ate = dr.ate(X_het)
print(dr.ate_interval(X_het))         # confidence interval
```

### Nearest-Neighbor Matching

```python
from causalml.match import NearestNeighborMatch
from causalml.propensity import ElasticNetPropensityModel

# Propensity score matching
pm = ElasticNetPropensityModel()
ps = pm.fit_predict(X_covariates, treatment)

matcher = NearestNeighborMatch(replace=False, ratio=1, random_state=42)
matched = matcher.match(data=df, treatment_col='treated', score_cols=['ps'])

# ATT on matched sample
att = matched[matched.treated==1]['y'].mean() - matched[matched.treated==0]['y'].mean()

# OR: Mahalanobis distance matching (better for low-dimensional X)
from pymatch.Matcher import Matcher
m = Matcher(test=df[df.treated==1], control=df[df.treated==0],
            yvar='y', exclude=['id'])
m.fit_scores(balance=True, nmodels=10)
m.predict_scores()
m.match(method='min', nmatches=1, threshold=0.001)
m.assess_balance(actual=True)
```

### Covariate Balance Diagnostics

```python
# Standardized mean differences (SMD) before/after matching
def smd(x_treat, x_control):
    return (x_treat.mean() - x_control.mean()) / np.sqrt(
        (x_treat.var() + x_control.var()) / 2
    )

for col in covariates:
    before = smd(df[df.treated==1][col], df[df.treated==0][col])
    after  = smd(matched[matched.treated==1][col], matched[matched.treated==0][col])
    print(f'{col}: SMD before={before:.3f}, after={after:.3f}')
# Target: |SMD| < 0.1 after matching

# Love plot
import matplotlib.pyplot as plt
smds_before = [...]
smds_after  = [...]
plt.scatter(smds_before, covariates, label='Before', marker='o')
plt.scatter(smds_after,  covariates, label='After',  marker='s')
plt.axvline(0, color='k', lw=0.5); plt.axvline(0.1, color='r', ls='--')
plt.legend(); plt.xlabel('Standardized Mean Difference')
```

### Entropy Balancing

```python
# Reweight controls to exactly match treated means (and optionally variances)
# Install: pip install ebal
from ebal import ebal

# Balances moments of X_controls exactly — no propensity model needed
weights = ebal(X_control=X[treatment==0],
               X_treated=X[treatment==1],
               moments=1)   # 1=means, 2=means+variances

# Use weights in weighted regression
import pyfixest as pf
df["w"] = np.where(treatment == 1, 1.0, weights)
res = pf.feols("y ~ treated", data=df, weights="w", vcov={"CRV1": "id"})
```

---

## Double Machine Learning (DML) & Causal Forests

**Use when:** High-dimensional controls; heterogeneous treatment effects; flexible functional form.

```python
from econml.dml import LinearDML, CausalForestDML, NonParamDML
from econml.dr import ForestDRLearner
from sklearn.ensemble import GradientBoostingRegressor, GradientBoostingClassifier
from sklearn.linear_model import LassoCV, LogisticRegressionCV

# --- Linear DML (Partially Linear Robinson model) ---
dml = LinearDML(
    model_y=LassoCV(),              # outcome residualization
    model_t=LassoCV(),              # treatment residualization
    discrete_treatment=False,
    cv=5,
)
dml.fit(Y, T, X=X_het, W=X_controls)
print(dml.ate(), dml.ate_interval())

# --- Causal Forest (nonparametric CATE) ---
cf = CausalForestDML(
    model_y=GradientBoostingRegressor(),
    model_t=GradientBoostingRegressor(),
    n_estimators=1000,
    min_samples_leaf=5,
    max_depth=5,
    discrete_treatment=False,
    cv=5,
)
cf.fit(Y, T, X=X_het, W=X_controls)

# Heterogeneous effects
tau_hat = cf.effect(X_het)            # CATE for each unit
lb, ub = cf.effect_interval(X_het)   # 95% CI

# Feature importance for heterogeneity
cf.feature_importances_  # which X drives heterogeneity

# Best linear predictor of CATE
blp = cf.ate_inference(X_het)
blp.summary_frame()

# --- IV + DML (DRIV for endogenous treatment) ---
from econml.iv.dr import LinearDRIV
driv = LinearDRIV(
    model_y_xw=LassoCV(),
    model_t_xw=LassoCV(),
    model_z=LogisticRegressionCV(),  # instrument model
    discrete_instrument=True,
)
driv.fit(Y, T, Z=Z_instrument, X=X_het, W=X_controls)
```

---

## Causal Method Selection Guide

| Setting | Method | Key Library |
|---------|--------|------------|
| OLS / WLS / Poisson with FE | Linear models | **`pyfixest`** |
| Panel + policy shock, parallel trends | DID / TWFE / CS / SA | `diff-diff` + `pyfixest` |
| Staggered adoption | CS, SA, BJS | `diff-diff` |
| Exogenous instrument | 2SLS / GMM / LIML | `linearmodels` (or `pyfixest` for panel IV) |
| Weak instrument concern | AR confidence set, LIML | `linearmodels` |
| Cutoff assignment rule | Sharp / Fuzzy RD | `rdrobust` |
| Slope discontinuity | RKD | `rdrobust` (deriv=1) |
| N=1 treated, long panel | Synthetic Control | `pysynth` / manual |
| SC + panel structure | Synthetic DiD | `diff-diff` (SDiD) |
| Selection on observables | PSM / IPW / EB | `causalml`, `ebal` |
| High-dim controls, binary T | AIPW / DR-Learner | `econml` |
| Heterogeneous effects | Causal Forest | `econml` |
| Endogenous T + heterogeneity | DRIV | `econml` |

---

## General Numerical Patterns

### Root Finding

```python
from scipy.optimize import brentq, root

# Scalar: prefer brentq (robust)
r_star = brentq(lambda r: asset_market_clearing(r, params), -0.05, 0.1)

# Multivariate
sol = root(equilibrium_system, x0=initial_guess, method='hybr', tol=1e-10)
```

### Income Process Discretization

```python
import quantecon as qe

# Tauchen: AR(1) log y' = rho log y + sigma_e * eps
mc = qe.tauchen(rho, sigma_e, n=7)
y_grid = np.exp(mc.state_values)
trans_mat = mc.P

# Rouwenhorst (better for high persistence)
mc = qe.rouwenhorst(n=7, rho=rho, sigma=sigma_e)
```

### Performance Hierarchy

```python
# 1. Vectorize with numpy first
# 2. Must loop → @njit
# 3. Parallelizable outer loop → @njit(parallel=True) + prange
# 4. Sparse structure → scipy.sparse

from numba import njit, prange

@njit(parallel=True)
def parallel_vfi(V, a_grid, y_grid, beta, sigma):
    n_a = len(a_grid)
    V_new = np.empty_like(V)
    for ia in prange(n_a):
        ...
    return V_new
```

---

## Common Mistakes

| Mistake | Correct Approach |
|---------|-----------------|
| TWFE with staggered treatment | Use CS / SA / BJS to avoid negative-weight bias |
| DID without clustered SEs | `cluster='id'` in `diff_diff` |
| Few clusters (<50) | `inference='wild_bootstrap'` in diff-diff |
| IV: not checking first-stage F | Always print `res.first_stage`; F > 104 preferred |
| IV: J-test p < 0.05 with overid | Instrument likely invalid; reconsider exclusion restriction |
| RD: single bandwidth choice | Show robustness across multiple bandwidths |
| RD: not testing density at cutoff | Run McCrary / `rddensity` test always |
| Matching: not checking balance | Report SMD before/after; target \|SMD\| < 0.1 |
| Matching: ignoring common support | Trim p-score outside [0.05, 0.95] |
| SC: poor pre-treatment fit | RMSPE_pre high → SC weights unreliable; report fit explicitly |
| VFI inner loops without Numba | Decorate with `@njit` |
| Uniform grid for income | Tauchen / Rouwenhorst discretization |
| Linear asset grid | Log/exponential spacing near borrowing constraint |
| Not checking solver convergence | Inspect `sol.success` and residuals |

---

## Debugging Checklist

**DID:** Pre-period event study coefficients ≈ 0; Goodman-Bacon decomposition for TWFE weight check

**IV:** First-stage F > 104; reduced form significant; J-test p > 0.1 (overid); AR confidence set if weak instruments

**RD:** Density test p > 0.05; covariates smooth at cutoff; robust to bandwidth choice

**SC:** Pre-treatment RMSPE small; placebo RMSPE ratio (post/pre) for inference

**Matching:** |SMD| < 0.1 after matching; Love plot; common support overlap

**DSGE/HANK:** All market-clearing residuals `< 1e-8`; VFI: plot `max|V_{n+1} - V_n|`; Distribution: `assert np.isclose(dist.sum(), 1.0)`; Jacobian: `np.allclose(J_analytic, J_fd, rtol=1e-4)`
