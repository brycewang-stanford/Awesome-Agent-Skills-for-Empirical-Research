---
name: causal-inference-guide
description: "Causal inference methods including DiD, IV, RDD, and synthetic control"
metadata:
  openclaw:
    emoji: "🔗"
    category: "analysis"
    subcategory: "econometrics"
    keywords: ["difference-in-differences", "DiD", "causal inference", "instrumental variables", "IV estimation", "regression discontinuity"]
    source: "wentor"
---

# Causal Inference Guide

A skill for applying quasi-experimental causal inference methods in observational research. Covers difference-in-differences, instrumental variables, regression discontinuity designs, and synthetic control methods with implementation code and diagnostic checks.

## Difference-in-Differences (DiD)

### Classic Two-Period DiD

```python
import numpy as np
import pandas as pd
import statsmodels.formula.api as smf

def did_estimation(df: pd.DataFrame, outcome: str, treatment: str,
                    post: str, covariates: list[str] = None) -> dict:
    """
    Estimate a difference-in-differences model.

    Args:
        df: Panel DataFrame
        outcome: Name of outcome variable column
        treatment: Name of treatment group indicator (0/1)
        post: Name of post-treatment period indicator (0/1)
        covariates: Optional list of control variable names
    """
    # Create interaction term
    df = df.copy()
    df['did'] = df[treatment] * df[post]

    # Build formula
    formula = f"{outcome} ~ {treatment} + {post} + did"
    if covariates:
        formula += ' + ' + ' + '.join(covariates)

    model = smf.ols(formula, data=df).fit(cov_type='cluster',
                                           cov_kwds={'groups': df.get('unit_id', df.index)})

    return {
        'did_estimate': model.params['did'],
        'se': model.bse['did'],
        'p_value': model.pvalues['did'],
        'ci_95': (model.conf_int().loc['did', 0], model.conf_int().loc['did', 1]),
        'r_squared': model.rsquared,
        'n_obs': model.nobs,
        'interpretation': (
            f"The treatment effect is {model.params['did']:.3f} "
            f"(SE = {model.bse['did']:.3f}, p = {model.pvalues['did']:.4f}). "
            f"{'Statistically significant' if model.pvalues['did'] < 0.05 else 'Not significant'} "
            f"at the 5% level."
        )
    }
```

### Parallel Trends Test

The key identifying assumption. Test it with pre-treatment data:

```python
def test_parallel_trends(df: pd.DataFrame, outcome: str,
                          treatment: str, time: str,
                          treatment_period: int) -> dict:
    """
    Test the parallel trends assumption using event study specification.
    """
    df = df.copy()
    pre_periods = sorted(df[df[time] < treatment_period][time].unique())

    # Create period dummies interacted with treatment
    for t in pre_periods:
        df[f'pre_{t}'] = ((df[time] == t) & (df[treatment] == 1)).astype(int)

    period_vars = [f'pre_{t}' for t in pre_periods[:-1]]  # omit last pre-period (reference)
    formula = f"{outcome} ~ {' + '.join(period_vars)} + C({time}) + C(unit_id)"

    model = smf.ols(formula, data=df).fit()

    # Joint F-test: all pre-treatment interactions = 0
    f_test = model.f_test(' = '.join([f'{v} = 0' for v in period_vars]))

    return {
        'pre_period_coefficients': {v: model.params[v] for v in period_vars},
        'f_statistic': f_test.fvalue[0][0],
        'f_pvalue': f_test.pvalue,
        'parallel_trends_hold': f_test.pvalue > 0.05,
        'interpretation': (
            'Parallel trends assumption supported (cannot reject joint null)'
            if f_test.pvalue > 0.05
            else 'WARNING: Parallel trends assumption may be violated'
        )
    }
```

## Instrumental Variables (IV)

### Two-Stage Least Squares

```python
from linearmodels.iv import IV2SLS

def iv_estimation(df: pd.DataFrame, outcome: str, endogenous: str,
                   instrument: str, exogenous: list[str] = None) -> dict:
    """
    Estimate an IV model using 2SLS.

    Args:
        outcome: Dependent variable
        endogenous: Endogenous regressor
        instrument: Instrumental variable
        exogenous: List of exogenous control variables
    """
    exog_formula = '1'
    if exogenous:
        exog_formula += ' + ' + ' + '.join(exogenous)

    model = IV2SLS(
        dependent=df[outcome],
        exog=df[exogenous] if exogenous else None,
        endog=df[[endogenous]],
        instruments=df[[instrument]]
    ).fit(cov_type='robust')

    # First-stage F-statistic
    first_stage = smf.ols(f"{endogenous} ~ {instrument}", data=df).fit()
    f_stat = first_stage.fvalue

    return {
        'iv_estimate': model.params[endogenous],
        'se': model.std_errors[endogenous],
        'p_value': model.pvalues[endogenous],
        'first_stage_F': f_stat,
        'weak_instrument': f_stat < 10,  # Stock-Yogo rule of thumb
        'interpretation': (
            f"IV estimate: {model.params[endogenous]:.3f}. "
            f"First-stage F = {f_stat:.1f} "
            f"({'Strong' if f_stat >= 10 else 'WEAK'} instrument)."
        )
    }
```

### IV Diagnostic Checklist

1. **Relevance**: First-stage F > 10 (Stock & Yogo, 2005)
2. **Exclusion restriction**: Instrument affects outcome only through the endogenous variable (untestable, argue conceptually)
3. **Overidentification test**: Sargan/Hansen J-test when you have more instruments than endogenous variables

## Regression Discontinuity Design (RDD)

```python
def rdd_estimation(df: pd.DataFrame, outcome: str, running_var: str,
                    cutoff: float, bandwidth: float = None) -> dict:
    """
    Sharp regression discontinuity design estimation.
    """
    df = df.copy()
    df['centered'] = df[running_var] - cutoff
    df['treated'] = (df[running_var] >= cutoff).astype(int)

    if bandwidth is None:
        bandwidth = df['centered'].std()  # simple default

    # Restrict to bandwidth
    local = df[df['centered'].abs() <= bandwidth]

    # Local linear regression
    formula = f"{outcome} ~ treated * centered"
    model = smf.ols(formula, data=local).fit(cov_type='HC1')

    return {
        'rdd_estimate': model.params['treated'],
        'se': model.bse['treated'],
        'p_value': model.pvalues['treated'],
        'bandwidth': bandwidth,
        'n_obs': len(local),
        'n_treated': local['treated'].sum(),
        'n_control': len(local) - local['treated'].sum()
    }
```

## Best Practices

- Always visualize your data: plot outcome trends over time (DiD), first-stage relationships (IV), or running variable distributions (RDD)
- Report robustness checks: varying bandwidths, alternative specifications, placebo tests
- Use cluster-robust standard errors at the appropriate level (usually the treatment unit level)
- Be transparent about identifying assumptions and potential violations
- Pre-register your analysis plan when possible to avoid p-hacking concerns
