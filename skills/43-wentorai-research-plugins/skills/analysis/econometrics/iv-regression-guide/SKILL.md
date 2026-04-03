---
name: iv-regression-guide
description: "Apply instrumental variables, 2SLS, and address endogeneity issues"
metadata:
  openclaw:
    emoji: "🔧"
    category: "analysis"
    subcategory: "econometrics"
    keywords: ["instrumental variables", "2SLS", "endogeneity", "IV regression", "causal inference", "econometrics"]
    source: "wentor-research-plugins"
---

# Instrumental Variables Regression Guide

A skill for applying instrumental variables (IV) estimation to address endogeneity in regression models. Covers the logic of IV, two-stage least squares (2SLS), instrument validity tests, weak instrument diagnostics, and reporting standards.

## The Endogeneity Problem

### Why OLS Fails

```
Ordinary Least Squares assumes:  E[u | X] = 0
(Regressors are uncorrelated with the error term)

This assumption is violated when:
  - Omitted variable bias: A confound affects both X and Y
  - Simultaneity: X affects Y and Y affects X
  - Measurement error: X is measured with noise

Consequence: OLS estimates are biased and inconsistent.
No amount of data will fix this.
```

### The IV Solution

An instrumental variable Z satisfies two conditions:

```
1. Relevance:  Z is correlated with the endogenous regressor X
               Cov(Z, X) != 0

2. Exclusion:  Z affects Y ONLY through X (not directly)
               Cov(Z, u) = 0

   Z --> X --> Y
   Z -/-> Y  (no direct path)
```

## Two-Stage Least Squares (2SLS)

### How 2SLS Works

```
Stage 1: Regress the endogenous variable on the instrument(s)
         X = gamma_0 + gamma_1 * Z + controls + v
         Save the fitted values: X_hat

Stage 2: Regress the outcome on the fitted values
         Y = beta_0 + beta_1 * X_hat + controls + e

The coefficient beta_1 is the IV estimate of the causal effect.
```

### Implementation in Python

```python
from linearmodels.iv import IV2SLS
import pandas as pd


def run_2sls(data: pd.DataFrame, dependent: str,
             endogenous: str, instruments: list[str],
             controls: list[str] = None) -> dict:
    """
    Run a 2SLS instrumental variables regression.

    Args:
        data: DataFrame with all variables
        dependent: Name of the dependent variable (Y)
        endogenous: Name of the endogenous regressor (X)
        instruments: List of instrument variable names (Z)
        controls: List of exogenous control variable names
    """
    controls = controls or []
    exog_str = " + ".join(["1"] + controls) if controls else "1"
    endog_str = endogenous
    instr_str = " + ".join(instruments)

    formula = f"{dependent} ~ {exog_str} + [{endog_str} ~ {instr_str}]"

    model = IV2SLS.from_formula(formula, data)
    result = model.fit(cov_type="robust")

    return {
        "coefficients": dict(result.params),
        "std_errors": dict(result.std_errors),
        "p_values": dict(result.pvalues),
        "f_statistic_first_stage": result.first_stage.diagnostics,
        "summary": str(result.summary)
    }
```

### Implementation in R

```r
library(ivreg)

# 2SLS estimation
iv_model <- ivreg(
  log(wage) ~ education + experience | parent_education + experience,
  data = df
)

summary(iv_model, diagnostics = TRUE)
```

## Instrument Validity Tests

### First-Stage F-Statistic (Relevance)

```python
def check_weak_instruments(first_stage_f: float) -> dict:
    """
    Evaluate instrument strength using first-stage F-statistic.

    Args:
        first_stage_f: F-statistic from the first-stage regression
    """
    return {
        "f_statistic": first_stage_f,
        "rule_of_thumb": (
            "Strong instruments" if first_stage_f > 10
            else "Potentially weak instruments"
        ),
        "interpretation": (
            "Stock & Yogo (2005) suggest F > 10 as a minimum for "
            "one endogenous variable. For more precise thresholds, "
            "consult the Stock-Yogo critical values table based on "
            "the number of instruments and desired maximal bias."
        ),
        "if_weak": [
            "Use LIML (Limited Information Maximum Likelihood) instead of 2SLS",
            "Report Anderson-Rubin confidence intervals (robust to weak IV)",
            "Consider finding stronger instruments",
            "Use the Lee et al. (2022) tF procedure for valid inference"
        ]
    }
```

### Overidentification Test (Exclusion Restriction)

When you have more instruments than endogenous variables, the Hansen J test (or Sargan test) checks whether the extra instruments are valid:

```
H0: All instruments are valid (uncorrelated with the error)
H1: At least one instrument is invalid

If p < 0.05: Reject -> at least one instrument may violate exclusion
If p > 0.05: Fail to reject -> instruments appear valid
             (but this test has low power)
```

## Classic IV Examples

### Famous Instruments in Economics

```
Research Question          | Endogenous Var | Instrument
---------------------------|---------------|------------------
Returns to education       | Years of school| Quarter of birth (Angrist & Krueger)
Effect of institutions     | Institutions   | Settler mortality (Acemoglu et al.)
Colonial origins of trade  | Trade openness | Geography (Frankel & Romer)
Effect of military service | Veteran status | Draft lottery number (Angrist)
Price elasticity of demand | Price          | Supply shifters (cost, weather)
```

## Reporting IV Results

### Required Elements

```
1. Justify instrument choice with economic/theoretical reasoning
2. Report first-stage regression results:
   - Coefficient of Z on X with standard error
   - First-stage F-statistic
3. Report second-stage (2SLS) results:
   - IV coefficient with robust standard errors
   - Compare with OLS estimate (discuss direction of bias)
4. Report diagnostic tests:
   - Weak instrument test (F-statistic or Kleibergen-Paap)
   - Overidentification test if applicable (Hansen J)
   - Endogeneity test (Hausman or Durbin-Wu-Hausman)
5. Discuss threats to instrument validity
   - Can the exclusion restriction be challenged?
   - Are there plausible alternative channels?
```

Always present both OLS and IV estimates side by side. The comparison helps readers understand the direction and magnitude of endogeneity bias and assess whether the IV correction is meaningful.
