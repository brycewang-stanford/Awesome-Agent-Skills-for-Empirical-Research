# Instrumental Variable and GMM Models

Reference for all IV estimators in linearmodels.iv. For methodology guidance on when IV
is appropriate, instrument validity, and identification, see the data-scientist skill's
causal-inference.md reference.

## Contents

- [Data Requirements](#data-requirements)
- [IV2SLS (Two-Stage Least Squares)](#iv2sls-two-stage-least-squares)
- [IVLIML (Limited Information Maximum Likelihood)](#ivliml-limited-information-maximum-likelihood)
- [IVGMM (Generalized Method of Moments)](#ivgmm-generalized-method-of-moments)
- [IVGMMCUE (Continuously Updating Estimator)](#ivgmmcue-continuously-updating-estimator)
- [AbsorbingLS](#absorbingls)
- [Diagnostics and Tests](#diagnostics-and-tests)
- [Covariance Options](#covariance-options)
- [Estimator Selection Guide](#estimator-selection-guide)
- [Common Pitfalls](#common-pitfalls)
- [References and Further Reading](#references-and-further-reading)

## Data Requirements

- IV models do **not** require a MultiIndex (unlike panel models)
- Accept regular pandas DataFrames
- Terms: dependent, exog (exogenous regressors), endog (endogenous regressors),
  instruments (excluded instruments)
- The model automatically distinguishes between included exogenous variables and
  excluded instruments
- The order of identification requires at least as many excluded instruments as
  endogenous regressors

## IV2SLS (Two-Stage Least Squares)

The workhorse IV estimator. Nests OLS when there are no endogenous variables
(`endog=None`). Consistent under heteroskedasticity with robust covariance.

### Formula API

```python
from linearmodels.iv import IV2SLS

# Basic IV: educ is endogenous, instrumented by motheduc and fatheduc
mod = IV2SLS.from_formula(
    "np.log(wage) ~ 1 + exper + exper_sq + [educ ~ motheduc + fatheduc]",
    data=df
)
res = mod.fit(cov_type="robust")
print(res.summary)
```

### Array API

```python
from linearmodels.iv import IV2SLS
import statsmodels.api as sm

dependent = df["log_wage"]
exog = sm.add_constant(df[["exper", "exper_sq"]])  # Included exogenous (with constant)
endog = df[["educ"]]                                 # Endogenous variable(s)
instruments = df[["motheduc", "fatheduc"]]           # Excluded instruments

mod = IV2SLS(dependent, exog, endog, instruments)
res = mod.fit(cov_type="robust")
```

### Formula Bracket Syntax

Brackets enclose the `endogenous ~ instruments` mapping:

```python
# Single endogenous, two instruments
"y ~ 1 + exog1 + exog2 + [endog1 ~ inst1 + inst2]"

# Multiple endogenous variables
"y ~ 1 + exog1 + [endog1 + endog2 ~ inst1 + inst2 + inst3]"

# Constants: include "1" in the exogenous part, NOT inside brackets
"y ~ 1 + exog1 + [endog1 ~ inst1]"        # Correct
"y ~ exog1 + [endog1 ~ 1 + inst1]"        # Wrong — constant goes outside brackets

# Suppress constant
"y ~ exog1 + [endog1 ~ inst1] - 1"
```

Compare with pyfixest pipe-separated syntax:

```python
# pyfixest: "y ~ exog | 0 | endog ~ inst"
# linearmodels: "y ~ 1 + exog + [endog ~ inst]"
```

### Interpreting IV2SLS Output

`res.summary` prints multiple sections:

- **Parameter estimates**: Coefficients, standard errors, t-stats, p-values, CIs
- **First-stage diagnostics** (per endogenous variable):
  - Partial R-squared of excluded instruments
  - Partial F-statistic — rule of thumb: F > 10 suggests instruments are
    not weak (Staiger-Stock)
- **Sargan/Hansen J-test**: Test of overidentifying restrictions (only when
  `# instruments > # endogenous`). H0: instruments are valid. Rejection suggests
  at least one instrument is endogenous.
- **Wooldridge regression test for endogeneity**: Durbin-Wu-Hausman equivalent.
  H0: the endogenous variable is actually exogenous. Failure to reject means OLS
  may be consistent and IV is unnecessary.

## IVLIML (Limited Information Maximum Likelihood)

Alternative to 2SLS with better finite-sample properties. Less biased than 2SLS
when instruments are weak. LIML is a k-class estimator: 2SLS uses k=1; LIML uses
k=lambda_min (smallest eigenvalue of a particular matrix).

```python
from linearmodels.iv import IVLIML

# Standard LIML
mod = IVLIML.from_formula(
    "np.log(wage) ~ 1 + exper + [educ ~ motheduc + fatheduc]",
    data=df
)
res = mod.fit(cov_type="robust")
```

### Fuller's Modified LIML

Subtracts `alpha / (n - L)` from k for finite-sample bias correction, where L is
the number of instruments. The `fuller` parameter controls alpha.

```python
# Fuller's modified LIML (alpha=1 is the standard choice)
mod = IVLIML.from_formula(
    "np.log(wage) ~ 1 + exper + [educ ~ motheduc + fatheduc]",
    data=df,
    fuller=1
)
res = mod.fit(cov_type="robust")
```

### When to Use LIML vs 2SLS

- Many instruments: LIML is less biased (2SLS bias is proportional to
  `# instruments / n`)
- Weak instruments: LIML is more robust (but still problematic with very weak
  instruments)
- Fuller's LIML with `alpha=1`: approximately unbiased with very small efficiency
  loss — a good default when instrument strength is uncertain
- Single endogenous variable + single instrument: 2SLS and LIML are numerically
  identical (k=1 in both cases)

## IVGMM (Generalized Method of Moments)

Most efficient IV estimator when instruments are valid and the model is
overidentified. Estimates an optimal weight matrix from a first-step estimation,
then re-estimates.

```python
from linearmodels.iv import IVGMM

# 2-step efficient GMM with robust weight matrix
mod = IVGMM.from_formula(
    "np.log(wage) ~ 1 + exper + [educ ~ motheduc + fatheduc]",
    data=df
)
res = mod.fit(cov_type="robust", weight_type="robust")
```

### Weight Matrix Options

| Weight Type | Use When | Code |
|-------------|----------|------|
| `"unadjusted"` | Homoskedastic errors assumed | `weight_type="unadjusted"` |
| `"robust"` | Heteroskedastic errors | `weight_type="robust"` |
| `"kernel"` | HAC (time-series dependence) | `weight_type="kernel", kernel="bartlett"` |
| `"clustered"` | Clustered dependence | `weight_type="clustered", clusters=df["group"]` |

### Steps Parameter

```python
# 1-step GMM (uses initial weight matrix only)
res = mod.fit(steps=1, weight_type="robust")

# 2-step GMM (default — efficient under correct specification)
res = mod.fit(steps=2, weight_type="robust")

# Iterative GMM (repeats until weight matrix converges)
res = mod.fit(iter_limit=100, weight_type="robust")
```

### When to Use GMM vs 2SLS

- Just-identified (# instruments = # endogenous): 2SLS and efficient GMM produce
  identical estimates. Use 2SLS for simplicity.
- Overidentified with heteroskedasticity: GMM with `weight_type="robust"` is more
  efficient than 2SLS.
- Overidentified with homoskedasticity: 2SLS is already efficient; GMM gains nothing.

## IVGMMCUE (Continuously Updating Estimator)

Jointly optimizes parameters and weight matrix in a single objective function
(non-linear optimization). Can be more robust to weak instruments than 2-step GMM,
but is more computationally expensive and may not converge.

```python
from linearmodels.iv import IVGMMCUE

mod = IVGMMCUE.from_formula(
    "np.log(wage) ~ 1 + exper + [educ ~ motheduc + fatheduc]",
    data=df
)
res = mod.fit(cov_type="robust")
```

Use CUE when:
- Concerned about finite-sample bias from sequential 2-step estimation
- Moderate number of moment conditions (CUE becomes unstable with many)
- Willing to accept higher computation time and possible convergence issues

## AbsorbingLS

OLS/WLS with high-dimensional absorbed fixed effects. Uses pyhdfe for FE absorption
(similar to Stata's `reghdfe` or pyfixest). Lives in the IV module but is
fundamentally an OLS estimator — does not support endogenous variables.

```python
from linearmodels.iv import AbsorbingLS

# Absorb entity and year fixed effects
mod = AbsorbingLS(
    dependent=df["y"],
    exog=df[["x1", "x2"]],
    absorb=df[["entity_id", "year"]]
)
res = mod.fit()
```

### Interacted Fixed Effects

```python
from linearmodels.iv.absorbing import Interaction

# Entity-by-industry interacted FE
interact = Interaction(df["entity_id"], df["industry"])
mod = AbsorbingLS(
    dependent=df["y"],
    exog=df[["x1"]],
    absorb=interact
)
res = mod.fit()
```

### AbsorbingLS vs PanelOLS vs pyfixest

| Feature | AbsorbingLS | PanelOLS | pyfixest |
|---------|-------------|----------|----------|
| Max FE dimensions | Unlimited | 2 | Unlimited |
| Requires MultiIndex | No | Yes | No |
| Speed (large data) | Moderate (pyhdfe) | Moderate | Fast (numba/JAX) |
| IV support | No | No | Yes (with FE) |
| Interacted FE | Yes (`Interaction`) | No | Yes (native `^`) |

**Recommendation:** For most absorbed-FE work, prefer pyfixest for speed and
formula convenience. Use AbsorbingLS when you need to stay within the linearmodels
ecosystem or need the `Interaction` class for complex FE structures that are not
easily expressed in pyfixest's `^` syntax.

## Diagnostics and Tests

### First-Stage Statistics

```python
res = mod.fit(cov_type="robust")

# Per-endogenous-variable first-stage results
for name, fs in res.first_stage.individual.items():
    print(f"--- First stage for {name} ---")
    print(f"  Partial R²: {fs.rsquared:.4f}")
    print(f"  Partial F:  {fs.f_statistic.stat:.2f} (p={fs.f_statistic.pval:.4f})")
```

### Overidentification Test (Sargan / Hansen J-Test)

Available only when `# instruments > # endogenous`:

```python
# Sargan test (assumes homoskedastic errors)
print(f"Sargan J-stat:  {res.sargan.stat:.3f}")
print(f"Sargan p-value: {res.sargan.pval:.3f}")

# Wooldridge overidentification test (robust to heteroskedasticity)
print(f"Wooldridge overid stat:  {res.wooldridge_overid.stat:.3f}")
print(f"Wooldridge overid p-val: {res.wooldridge_overid.pval:.3f}")
```

### Endogeneity Test (Wu-Hausman)

Tests H0: the suspected endogenous variable is actually exogenous.

```python
wh = res.wu_hausman()
print(f"Wu-Hausman F-stat: {wh.stat:.3f}")
print(f"Wu-Hausman p-val:  {wh.pval:.3f}")
```

### Wooldridge Regression-Based Endogeneity Test

```python
endo_test = res.wooldridge_regression
print(f"Wooldridge stat: {endo_test.stat:.3f}")
print(f"Wooldridge pval: {endo_test.pval:.3f}")
```

### Weak Instrument Warning Signs

- First-stage partial F < 10 (Staiger-Stock rule of thumb)
- Large difference between 2SLS and LIML estimates (suggests weak instrument bias
  in 2SLS — LIML is median-unbiased, so divergence from 2SLS indicates 2SLS bias)
- Wide confidence intervals relative to OLS
- Anderson-Rubin confidence sets (not built in — construct manually or use
  alternative packages if needed)

## Covariance Options

All IV estimators accept `cov_type` in `.fit()`:

| `cov_type` | Description | When to Use |
|-------------|-------------|-------------|
| `"unadjusted"` | Classical (homoskedastic) | Textbook settings only |
| `"robust"` | Eicker-Huber-White | Default for cross-sectional data |
| `"kernel"` | HAC (Newey-West style) | Time-series or spatial correlation |
| `"clustered"` | Cluster-robust | Grouped/panel-like data |

```python
# Robust (heteroskedasticity-consistent)
res = mod.fit(cov_type="robust")

# Clustered by state
res = mod.fit(cov_type="clustered", clusters=df["state"])

# HAC with Bartlett kernel, bandwidth 5
res = mod.fit(cov_type="kernel", kernel="bartlett", bandwidth=5)
```

For GMM models, `weight_type` and `cov_type` are separate arguments. The weight
matrix determines efficiency; the covariance type determines inference. They should
generally match (e.g., `weight_type="robust"` with `cov_type="robust"`).

## Estimator Selection Guide

```
How to choose an IV estimator?
├─ Just-identified (# inst = # endog)
│   ├─ All estimators give identical point estimates
│   └─ Use IV2SLS for simplicity
├─ Overidentified (# inst > # endog)
│   ├─ Instruments strong (F > 10)?
│   │   ├─ Yes, homoskedastic → IV2SLS
│   │   ├─ Yes, heteroskedastic → IVGMM (2-step, weight_type="robust")
│   │   └─ Yes, clustered → IVGMM (2-step, weight_type="clustered")
│   └─ Instruments possibly weak (F ~ 10)?
│       ├─ Few instruments → IVLIML or Fuller (fuller=1)
│       └─ Many instruments → Fuller (fuller=1) preferred
├─ Concerned about finite-sample bias?
│   ├─ IVLIML (less biased than 2SLS)
│   ├─ Fuller LIML (approximately unbiased)
│   └─ IVGMMCUE (if willing to accept computation cost)
└─ Just want a robust default?
    └─ IV2SLS with cov_type="robust" (widely understood, easy to report)
```

## Common Pitfalls

**Constant term placement:**
The constant (`1`) goes in the exogenous part, never inside the brackets.

```python
# Correct
"y ~ 1 + exper + [educ ~ motheduc + fatheduc]"

# Wrong — do not put constant inside brackets
"y ~ exper + [educ ~ 1 + motheduc + fatheduc]"
```

**Forgetting to check first-stage strength:**
Always inspect `res.first_stage` before interpreting second-stage results. Weak
first stages invalidate standard inference even with large samples.

**Using Sargan test with heteroskedastic data:**
The Sargan test assumes homoskedasticity. Use `res.wooldridge_overid` for
heteroskedasticity-robust overidentification testing.

**Confusing weight_type and cov_type in GMM:**
`weight_type` determines the GMM weight matrix (affects point estimates in
overidentified models). `cov_type` determines standard errors (affects inference
only). They should generally be set to the same value.

**Mixing up with panel IV:**
linearmodels does not have a combined panel-IV estimator. If you need IV with
entity/time fixed effects, use pyfixest:

```python
# pyfixest: IV with entity and time FE
import pyfixest as pf
fit = pf.feols("log_wage ~ 1 + exper | entity + year | educ ~ motheduc + fatheduc", data=df)
```

## References and Further Reading

- Sheppard, K. linearmodels IV documentation. https://bashtage.github.io/linearmodels/iv/introduction.html
- Angrist, J.D. and Pischke, J.-S. (2009). *Mostly Harmless Econometrics*. Princeton University Press.
- Baum, C.F., Schaffer, M.E., and Stillman, S. (2007). "Enhanced Routines for Instrumental Variables/Generalized Method of Moments Estimation and Testing." *Stata Journal*, 7(4), 465-506.
- Stock, J.H. and Yogo, M. (2005). "Testing for Weak Instruments in Linear IV Regression." In Andrews, D.W.K. and Stock, J.H. (eds.), *Identification and Inference for Econometric Models*. Cambridge University Press.
- Hansen, L.P. (1982). "Large Sample Properties of Generalized Method of Moments Estimators." *Econometrica*, 50(4), 1029-1054.
