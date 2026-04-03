# System Regression Models

Reference for system estimators in `linearmodels.system`: SUR, IV3SLS, IVSystemGMM, and
cross-equation constraints. For methodology guidance on simultaneous equations and
identification, see the data-scientist skill's `statistical-modeling.md` reference.

## Contents

- [Overview](#overview)
- [Data Setup](#data-setup)
- [SUR (Seemingly Unrelated Regression)](#sur-seemingly-unrelated-regression)
- [IV3SLS (Three-Stage Least Squares)](#iv3sls-three-stage-least-squares)
- [IVSystemGMM](#ivsystemgmm)
- [Cross-Equation Constraints (LinearConstraint)](#cross-equation-constraints-linearconstraint)
- [Interpreting System Output](#interpreting-system-output)
- [Performance Notes](#performance-notes)
- [References and Further Reading](#references-and-further-reading)

## Overview

System models estimate multiple equations jointly, exploiting cross-equation error
correlation for efficiency gains over equation-by-equation estimation.

Three estimators handle different settings:

| Estimator | Endogenous Allowed | Efficiency Source |
|-----------|--------------------|-------------------|
| `SUR` | No (all regressors exogenous) | GLS on cross-equation error covariance |
| `IV3SLS` | Yes (per-equation instruments) | GLS + IV first stages |
| `IVSystemGMM` | Yes (per-equation instruments) | Optimal GMM weight matrix |

Key differences from panel and IV models:

- **Input format**: dict or `OrderedDict` of equations, not a single formula
- **No MultiIndex required**: data is a flat DataFrame (or arrays per equation)
- **No `.from_formula()` on the constructor**: use a dict of formula strings instead
- **Cross-equation covariance** (sigma matrix) is estimated and used for GLS

## Data Setup

Each equation is defined as a dict with keys for its components. Equations are
collected into an `OrderedDict` (or regular dict on Python 3.7+, though
`OrderedDict` makes equation ordering explicit).

### Array Input

```python
from collections import OrderedDict
from linearmodels.system import SUR
import statsmodels.api as sm

# Build equation specifications
equations = OrderedDict()
equations["earnings"] = {
    "dependent": data["hrearn"],
    "exog": data[["const", "exper", "tenure"]],
}
equations["benefits"] = {
    "dependent": data["hrbens"],
    "exog": data[["const", "exper", "union"]],
}

mod = SUR(equations)
res = mod.fit(cov_type="robust")
print(res.summary)
```

Each equation dict accepts these keys:

| Key | Required | Description |
|-----|----------|-------------|
| `"dependent"` | Yes | Series or array of the dependent variable |
| `"exog"` | Yes | DataFrame or array of exogenous regressors (include constant) |
| `"endog"` | IV only | DataFrame or array of endogenous regressors |
| `"instruments"` | IV only | DataFrame or array of excluded instruments |

### Formula Input

Pass a dict of formula strings to `.from_formula()`:

```python
from linearmodels.system import SUR

formulas = {
    "earnings": "hrearn ~ 1 + exper + tenure",
    "benefits": "hrbens ~ 1 + exper + union",
}
mod = SUR.from_formula(formulas, data=data)
res = mod.fit()
print(res.summary)
```

For IV formulas, use the same bracket syntax as single-equation IV models:

```python
from linearmodels.system import IV3SLS

formulas = {
    "demand": "quantity ~ 1 + income + [price ~ cost + weather]",
    "supply": "quantity ~ 1 + cost + [price ~ income + weather]",
}
mod = IV3SLS.from_formula(formulas, data=data)
res = mod.fit(cov_type="robust")
```

## SUR (Seemingly Unrelated Regression)

GLS estimator that exploits cross-equation error correlation for efficiency. All
regressors must be exogenous. More efficient than equation-by-equation OLS when
(a) errors are correlated across equations AND (b) regressors differ across
equations. If all equations share identical regressors, SUR reduces to OLS
(Zellner's invariance result).

```python
from collections import OrderedDict
from linearmodels.system import SUR

equations = OrderedDict()
equations["earnings"] = {
    "dependent": data["hrearn"],
    "exog": data[["const", "exper", "tenure"]],
}
equations["benefits"] = {
    "dependent": data["hrbens"],
    "exog": data[["const", "exper", "union"]],
}

mod = SUR(equations)
res = mod.fit(cov_type="robust")
print(res.summary)

# System R-squared
print(f"System R-squared: {res.rsquared:.4f}")

# Cross-equation covariance (sigma) matrix
print("Sigma matrix:")
print(res.sigma)
```

### Iterative SUR (FGLS)

Iterative SUR re-estimates the sigma matrix and GLS coefficients until
convergence. Produces maximum likelihood estimates under normality.

```python
# Iterative SUR — set iter_limit > 1
res_isur = mod.fit(iter_limit=100, cov_type="robust")
print(f"Iterations: {res_isur.iterations}")
```

### Covariance Options

```python
# Unadjusted (homoskedastic)
res = mod.fit(cov_type="unadjusted")

# Heteroskedasticity-robust
res = mod.fit(cov_type="robust")

# HAC (kernel-based)
res = mod.fit(cov_type="kernel", kernel="bartlett", bandwidth=5)
```

## IV3SLS (Three-Stage Least Squares)

SUR extended to allow endogenous variables. Each equation can have its own set of
endogenous regressors and excluded instruments. The three stages are: (1) 2SLS
per equation to get consistent residuals, (2) estimate cross-equation covariance
from those residuals, (3) GLS using the estimated covariance.

```python
from collections import OrderedDict
from linearmodels.system import IV3SLS

equations = OrderedDict()
equations["demand"] = {
    "dependent": data["quantity"],
    "exog": data[["const", "income"]],
    "endog": data[["price"]],
    "instruments": data[["cost", "weather"]],
}
equations["supply"] = {
    "dependent": data["quantity"],
    "exog": data[["const", "cost"]],
    "endog": data[["price"]],
    "instruments": data[["income", "weather"]],
}

mod = IV3SLS(equations)
res = mod.fit(cov_type="robust")
print(res.summary)
```

### Mixed Equations (Some IV, Some Not)

Not every equation needs endogenous variables. Equations without `"endog"` and
`"instruments"` keys are treated as exogenous:

```python
equations = OrderedDict()
equations["demand"] = {
    "dependent": data["quantity"],
    "exog": data[["const", "income"]],
    "endog": data[["price"]],
    "instruments": data[["cost", "weather"]],
}
equations["wage"] = {
    "dependent": data["wage"],
    "exog": data[["const", "educ", "exper"]],
}

mod = IV3SLS(equations)
res = mod.fit(cov_type="robust")
```

## IVSystemGMM

System GMM estimation for multiple IV equations. More efficient than 3SLS under
heteroskedasticity because it uses an optimal weight matrix rather than the
parametric GLS covariance.

```python
from linearmodels.system import IVSystemGMM

mod = IVSystemGMM(equations)
res = mod.fit(weight_type="robust")
print(res.summary)
```

### Weight Matrix Options

| `weight_type` | Use When | Code |
|---------------|----------|------|
| `"unadjusted"` | Homoskedastic errors assumed | `weight_type="unadjusted"` |
| `"robust"` | Heteroskedastic errors | `weight_type="robust"` |
| `"kernel"` | HAC (time-series dependence) | `weight_type="kernel", kernel="bartlett"` |

### When to Use IVSystemGMM vs IV3SLS

- Homoskedastic errors: 3SLS is efficient; GMM gains nothing
- Heteroskedastic errors: System GMM with `weight_type="robust"` dominates 3SLS
- Small samples: 3SLS may be more stable (GMM weight matrix estimation is noisy)
- Report both as a robustness check when feasible

## Cross-Equation Constraints (LinearConstraint)

Test or impose linear restrictions across equation parameters using the
`R * beta = q` format. Common use: constraining a coefficient to be equal across
equations.

### Parameter Ordering

System models stack parameters as a single vector: all parameters from equation 1,
then all from equation 2, etc. Use `res.params` to inspect the ordering:

```python
res = mod.fit()
print("Parameter names and indices:")
for i, name in enumerate(res.params.index):
    print(f"  [{i}] {name}")
```

### Imposing an Equality Constraint

```python
from linearmodels.system import SUR, LinearConstraint
import numpy as np

# Suppose res.params.index is:
#   [0] earnings_const
#   [1] earnings_exper
#   [2] earnings_tenure
#   [3] benefits_const
#   [4] benefits_exper
#   [5] benefits_union

# Constraint: exper coefficient equal across equations
# earnings_exper - benefits_exper = 0
total_params = len(res.params)
r = np.zeros((1, total_params))
r[0, 1] = 1.0    # earnings_exper
r[0, 4] = -1.0   # benefits_exper
q = np.array([0.0])

constraint = LinearConstraint(r, q)
res_constrained = mod.fit(constraints=constraint, cov_type="robust")
print(res_constrained.summary)
```

### Multiple Simultaneous Constraints

```python
# Constrain both exper AND constant to be equal across equations
r = np.zeros((2, total_params))
r[0, 0] = 1.0    # earnings_const
r[0, 3] = -1.0   # benefits_const
r[1, 1] = 1.0    # earnings_exper
r[1, 4] = -1.0   # benefits_exper
q = np.array([0.0, 0.0])

constraint = LinearConstraint(r, q)
res_constrained = mod.fit(constraints=constraint, cov_type="robust")
```

## Interpreting System Output

### Per-Equation Results

`res.summary` reports coefficients, standard errors, t-stats, and p-values grouped
by equation. Each equation has its own R-squared.

```python
res = mod.fit(cov_type="robust")

# Full summary with all equations
print(res.summary)

# Access equation-level results
for eq_name in res.equations:
    eq = res.equations[eq_name]
    print(f"\n--- {eq_name} ---")
    print(f"  R-squared: {eq.rsquared:.4f}")
    print(f"  Params:\n{eq.params}")
    print(f"  Std Errors:\n{eq.std_errors}")
```

### System-Level Statistics

```python
# System R-squared (weighted average across equations)
print(f"System R-squared: {res.rsquared:.4f}")

# Cross-equation covariance matrix (sigma)
# Off-diagonal elements measure error correlation across equations
print("Sigma (cross-equation covariance):")
print(res.sigma)

# Total number of observations and parameters
print(f"Total observations: {res.nobs}")
print(f"Total parameters: {len(res.params)}")
```

### Joint Hypothesis Tests

Use the Wald test via constraints to test joint hypotheses across equations:

```python
# Test H0: exper coefficient = 0 in BOTH equations simultaneously
r = np.zeros((2, total_params))
r[0, 1] = 1.0   # earnings_exper = 0
r[1, 4] = 1.0   # benefits_exper = 0
q = np.array([0.0, 0.0])

# Compare constrained vs unconstrained fit
constraint = LinearConstraint(r, q)
res_restricted = mod.fit(constraints=constraint)
```

## Performance Notes

- SUR, 3SLS, and System GMM use **dense matrix operations** on the stacked system.
  Memory and computation scale with `(sum of N_i * K_i)^2` where N_i is the
  observations and K_i is the parameters per equation.
- For large N with few equations, consider equation-by-equation estimation with
  cluster-robust standard errors as a scalable alternative (sacrificing cross-equation
  efficiency).
- Cross-equation constraints add minimal overhead -- the constraint matrix is small
  relative to the system.
- Iterative SUR (`iter_limit > 1`) adds one matrix factorization per iteration but
  typically converges in fewer than 20 iterations.

## References and Further Reading

- Sheppard, K. linearmodels System documentation. https://bashtage.github.io/linearmodels/system/index.html
- Zellner, A. (1962). "An Efficient Method of Estimating Seemingly Unrelated Regressions and Tests for Aggregation Bias." *JASA*, 57(298), 348-368.
- Zellner, A. and Theil, H. (1962). "Three-Stage Least Squares: Simultaneous Estimation of Simultaneous Equations." *Econometrica*, 30(1), 54-78.
- Greene, W.H. (2018). *Econometric Analysis*. 8th ed. Pearson. Ch. 10 (Systems of Equations).
- Wooldridge, J.M. (2010). *Econometric Analysis of Cross Section and Panel Data*. 2nd ed. MIT Press. Ch. 7 (Simultaneous Equations Models).
