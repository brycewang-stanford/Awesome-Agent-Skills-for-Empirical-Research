# Covariance Estimation and Inference

Reference for all standard error and covariance types in linearmodels across panel,
IV, and system model families. For methodology guidance on when to use which SE type,
see the data-scientist skill's `statistical-modeling.md` reference.

## Contents

- [Overview](#overview)
- [Panel Model Covariance Types](#panel-model-covariance-types)
- [IV Model Covariance Types](#iv-model-covariance-types)
- [System Model Covariance Types](#system-model-covariance-types)
- [GMM Weight Matrices](#gmm-weight-matrices)
- [The debiased Parameter](#the-debiased-parameter)
- [SE Type Decision Guide](#se-type-decision-guide)
- [Comparison with pyfixest and statsmodels](#comparison-with-pyfixest-and-statsmodels)
- [Key Differences from pyfixest](#key-differences-from-pyfixest)
- [References and Further Reading](#references-and-further-reading)

## Overview

linearmodels provides rich covariance estimation across all model types. Key points:

- **Panel-aware clustering**: entity and time dimensions are built into the API
  (`cluster_entity`, `cluster_time`) -- no need to pass cluster variables manually
- **Driscoll-Kraay SEs**: kernel-based covariance robust to cross-sectional dependence,
  available for panel models -- not offered by statsmodels
- **Small-sample corrections**: all covariance estimators accept a `debiased` parameter
- **SE type is specified at `.fit()` time**, not post-estimation -- unlike pyfixest's
  `.vcov()` method, you must re-fit to change the covariance type

## Panel Model Covariance Types

All panel estimators (`PanelOLS`, `RandomEffects`, `BetweenOLS`, `FirstDifferenceOLS`,
`PooledOLS`, `FamaMacBeth`) accept `cov_type` in `.fit()`.

### Homoskedastic (Unadjusted)

```python
res = mod.fit(cov_type="unadjusted")  # or "homoskedastic"
```

Assumes homoskedastic, uncorrelated errors. Rarely appropriate for panel data --
use only as a baseline or when you have strong theoretical justification.

### Heteroskedasticity-Robust

```python
res = mod.fit(cov_type="robust")  # or "heteroskedastic"
```

White's heteroskedasticity-consistent estimator. Corrects for non-constant error
variance but does NOT account for within-entity serial correlation or
cross-sectional dependence. Typically insufficient for panel data.

### Clustered (One-Way and Two-Way)

```python
# Cluster by entity (most common for panel data)
res = mod.fit(cov_type="clustered", cluster_entity=True)

# Cluster by time
res = mod.fit(cov_type="clustered", cluster_time=True)

# Two-way clustering (entity AND time)
res = mod.fit(cov_type="clustered", cluster_entity=True, cluster_time=True)

# Cluster by a custom variable (must align with the data index)
res = mod.fit(cov_type="clustered", clusters=df["state_id"])
```

- Entity clustering accounts for arbitrary within-entity serial correlation
- Time clustering accounts for cross-sectional correlation within time periods
- Two-way clustering accounts for both simultaneously (Cameron, Gelbach, Miller 2011)
- When clustering by the same variable used for FE, the df correction properly
  accounts for absorbed effects
- Custom `clusters` variable must have the same index as the dependent variable

### Driscoll-Kraay (Kernel)

```python
res = mod.fit(cov_type="kernel", kernel="bartlett", bandwidth=5)
```

Robust to heteroskedasticity, serial correlation, AND cross-sectional dependence.
This is the key covariance type that linearmodels offers beyond what most Python
packages provide.

- Appropriate when T is large relative to N (unlike clustered SEs which assume
  large N, fixed T)
- Kernel options: `"bartlett"` (Newey-West), `"parzen"`, `"qs"` (Quadratic Spectral)
- `bandwidth`: number of lags included (larger = more serial correlation accounted for)
- Bandwidth rule of thumb for Bartlett: `floor(4 * (T/100)^(2/9))`

```python
import math

# Automatic bandwidth selection (Bartlett kernel)
T = df.index.get_level_values(1).nunique()
bw = math.floor(4 * (T / 100) ** (2 / 9))
print(f"Suggested Bartlett bandwidth for T={T}: {bw}")

res = mod.fit(cov_type="kernel", kernel="bartlett", bandwidth=bw)
```

### Fama-MacBeth Covariance

Only available for the `FamaMacBeth` estimator. Adjusts inference for time-series
dependence in the averaged cross-sectional regression coefficients.

```python
from linearmodels.panel import FamaMacBeth

mod = FamaMacBeth.from_formula("ret ~ 1 + beta + size + bm", data=df)

# Standard FM SEs (assumes independence across time periods)
res = mod.fit(cov_type="unadjusted")

# HAC-adjusted FM SEs (accounts for serial dependence in coefficient averages)
res = mod.fit(cov_type="kernel", kernel="bartlett", bandwidth=5)
```

## IV Model Covariance Types

All IV estimators (`IV2SLS`, `IVLIML`, `IVGMM`, `IVGMMCUE`) accept `cov_type`
in `.fit()`. IV models work with flat DataFrames (no MultiIndex).

### Homoskedastic

```python
res = mod.fit(cov_type="unadjusted")
```

Classical (homoskedastic) standard errors. Textbook settings only.

### Heteroskedasticity-Robust

```python
res = mod.fit(cov_type="robust")
```

Eicker-Huber-White heteroskedasticity-consistent SEs. The default choice for
cross-sectional IV applications.

### Clustered

```python
res = mod.fit(cov_type="clustered", clusters=df["group"])
```

Cluster-robust SEs. Pass the grouping variable directly -- IV models do not have
`cluster_entity`/`cluster_time` shortcuts (those are panel-only).

### HAC / Kernel

```python
res = mod.fit(cov_type="kernel", kernel="bartlett", bandwidth=5)
```

HAC (Newey-West style) covariance for time-series or spatial correlation in
cross-sectional IV data. Same kernel options as panel models: `"bartlett"`,
`"parzen"`, `"qs"`.

## System Model Covariance Types

System models (`SUR`, `IV3SLS`, `IVSystemGMM`) support covariance estimation on
top of their cross-equation error structure. The system sigma matrix (cross-equation
covariance) is always estimated; `cov_type` controls within-equation inference.

```python
from linearmodels.system import SUR

mod = SUR(equations)

# Homoskedastic (GLS with estimated sigma)
res = mod.fit(cov_type="unadjusted")

# Heteroskedasticity-robust
res = mod.fit(cov_type="robust")

# HAC kernel
res = mod.fit(cov_type="kernel", kernel="bartlett", bandwidth=5)

# Clustered
res = mod.fit(cov_type="clustered", clusters=df["group"])
```

For `IVSystemGMM`, the `weight_type` parameter controls the GMM weight matrix
independently of `cov_type`, following the same pattern as single-equation `IVGMM`.

## GMM Weight Matrices

For `IVGMM` and `IVSystemGMM`, the weight matrix determines estimator efficiency
while `cov_type` determines inference. These should generally match.

```python
from linearmodels.iv import IVGMM

mod = IVGMM.from_formula(
    "np.log(wage) ~ 1 + exper + [educ ~ motheduc + fatheduc]", data=df
)

# Homoskedastic weight matrix
res = mod.fit(weight_type="unadjusted", cov_type="unadjusted")

# Robust weight matrix (heteroskedastic-efficient)
res = mod.fit(weight_type="robust", cov_type="robust")

# HAC weight matrix (serial-correlation-efficient)
res = mod.fit(weight_type="kernel", kernel="bartlett", bandwidth=5,
              cov_type="kernel")

# Clustered weight matrix
res = mod.fit(weight_type="clustered", clusters=df["group"],
              cov_type="clustered")
```

| `weight_type` | Efficient Under | Pair with `cov_type` |
|---------------|-----------------|----------------------|
| `"unadjusted"` | Homoskedastic errors | `"unadjusted"` |
| `"robust"` | Heteroskedastic errors | `"robust"` |
| `"kernel"` | Serial/spatial correlation | `"kernel"` |
| `"clustered"` | Clustered dependence | `"clustered"` |

Mismatching `weight_type` and `cov_type` is legal but produces a less efficient
estimator. The main case for intentional mismatch: use `weight_type="robust"` for
point estimates but `cov_type="clustered"` for conservative inference.

## The debiased Parameter

```python
# Apply small-sample correction
res = mod.fit(cov_type="clustered", cluster_entity=True, debiased=True)

# No correction (default for some models)
res = mod.fit(cov_type="clustered", cluster_entity=True, debiased=False)
```

- When `True`: applies (N-1)/(N-K) type adjustments to the covariance matrix
- For clustered SEs with FE: the correction accounts for degrees of freedom
  consumed by absorbed entity/time effects
- Default value varies by model type -- always specify explicitly for
  reproducibility

```python
# Explicit debiased across different SE types
res_robust = mod.fit(cov_type="robust", debiased=True)
res_cluster = mod.fit(cov_type="clustered", cluster_entity=True, debiased=True)
res_kernel = mod.fit(cov_type="kernel", kernel="bartlett", bandwidth=5, debiased=True)
```

The impact of `debiased` shrinks as sample size grows. For small panels (N < 50
entities or T < 20 periods), the correction can meaningfully affect inference.

## SE Type Decision Guide

| Situation | Recommended Type | Code |
|-----------|-----------------|------|
| Panel: within-entity correlation | Clustered by entity | `cov_type="clustered", cluster_entity=True` |
| Panel: cross-sectional dependence (large T) | Driscoll-Kraay | `cov_type="kernel", kernel="bartlett"` |
| Panel: both within-entity and cross-sectional | Two-way clustering | `cluster_entity=True, cluster_time=True` |
| Cross-section: heteroskedasticity only | Robust | `cov_type="robust"` |
| Cross-section: group structure | Clustered | `cov_type="clustered", clusters=df["group"]` |
| Time series: serial correlation | Kernel (HAC) | `cov_type="kernel", kernel="bartlett"` |
| Fama-MacBeth: time-series averaging | FM kernel | `cov_type="kernel"` (on FamaMacBeth) |
| Assumed homoskedastic + independent | Unadjusted | `cov_type="unadjusted"` |

Default recommendation for most panel applications: **entity-clustered SEs**.
They are robust to arbitrary within-entity correlation patterns and are the
most widely reported in applied econometrics.

## Comparison with pyfixest and statsmodels

| SE Type | linearmodels | pyfixest | statsmodels |
|---------|-------------|----------|-------------|
| Robust (HC1) | `cov_type="robust"` | `vcov="hetero"` | `cov_type="HC1"` |
| Cluster (1-way) | `cov_type="clustered", cluster_entity=True` | `vcov={"CRV1": "entity"}` | Limited support |
| Cluster (2-way) | `cluster_entity=True, cluster_time=True` | `vcov={"CRV1": "e+t"}` | Not available |
| Driscoll-Kraay | `cov_type="kernel", kernel="bartlett"` | `vcov="DK"` | Not available |
| HAC (Newey-West) | `cov_type="kernel", kernel="bartlett"` | `vcov="NW"` | `cov_type="HAC"` |
| CRV3 | Not available | `vcov={"CRV3": "g"}` | Not available |
| Wild bootstrap | Not available | `.wildboottest()` | Not available |
| Post-estimation switch | Not available (must re-fit) | `.vcov("hetero")` | Not available |

## Key Differences from pyfixest

- **Fit-time vs post-estimation**: linearmodels requires SE choice at `.fit()` time;
  pyfixest allows post-estimation switching via `.vcov()`. To compare SE types in
  linearmodels, you must call `.fit()` multiple times.
- **Kernel options**: linearmodels offers three kernels for Driscoll-Kraay (Bartlett,
  Parzen, Quadratic Spectral) with explicit bandwidth control; pyfixest has basic
  DK support with `vcov="DK"`.
- **Bootstrap**: pyfixest offers CRV3 and wild bootstrap inference that linearmodels
  does not provide. Use pyfixest when bootstrap-based inference is needed.
- **Two-way clustering**: both support it; linearmodels uses `cluster_entity=True,
  cluster_time=True`; pyfixest uses `vcov={"CRV1": "entity+time"}`.
- **Panel-aware shortcuts**: linearmodels provides `cluster_entity` and `cluster_time`
  booleans that automatically use the MultiIndex levels; pyfixest references variable
  names from the formula or data.

## References and Further Reading

- Driscoll, J.C. and Kraay, A.C. (1998). "Consistent Covariance Matrix Estimation with Spatially Dependent Panel Data." *Review of Economics and Statistics*, 80(4), 549-560.
- Cameron, A.C. and Miller, D.L. (2015). "A Practitioner's Guide to Cluster-Robust Inference." *Journal of Human Resources*, 50(2), 317-372.
- Newey, W.K. and West, K.D. (1987). "A Simple, Positive Semi-definite, Heteroskedasticity and Autocorrelation Consistent Covariance Matrix." *Econometrica*, 55(3), 703-708.
- Petersen, M.A. (2009). "Estimating Standard Errors in Finance Panel Data Sets: Comparing Approaches." *Review of Financial Studies*, 22(1), 435-480.
- Sheppard, K. linearmodels Covariance documentation. https://bashtage.github.io/linearmodels/panel/reference.html
