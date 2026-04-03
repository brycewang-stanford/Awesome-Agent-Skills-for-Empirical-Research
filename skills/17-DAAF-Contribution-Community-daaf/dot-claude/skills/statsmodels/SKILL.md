---
name: statsmodels
description: >-
  Statistical modeling: OLS/WLS/GLS, GLM (logit, probit, Poisson), time series (ARIMA, VAR), mixed effects, diagnostics. Formula API. Use for regressions without fixed effects, GLMs, or time series. For FE/DiD use pyfixest; panel/IV use linearmodels.
metadata:
  audience: research-coders
  domain: python-library
  library-version: "0.14.6"
  skill-last-updated: "2026-03-27"
---

# statsmodels Skill

statsmodels general-purpose statistical modeling library for Python. Covers OLS/WLS/GLS, GLM (logit, probit, Poisson, negative binomial), discrete choice models, time series (ARIMA, SARIMAX, VAR), mixed effects (MixedLM), robust regression, hypothesis tests, and comprehensive diagnostics. Supports R-style formula API. Use when fitting regressions without fixed effects, running GLMs or logit/probit, analyzing time series, or using formula syntax. For fixed effects or DiD, use pyfixest; for panel/IV/system models, use linearmodels.

Comprehensive skill for statistical modeling with statsmodels. Use decision trees below to find the right guidance, then load detailed references.

## What is statsmodels?

statsmodels is the general-purpose **statistical modeling** library for Python:
- **Two APIs**: Formula API (`smf.ols("y ~ x1 + x2", data=df)`) for R-style modeling, and array API (`sm.OLS(y, X)`) for programmatic control
- **Broad model coverage**: OLS, WLS, GLS, GLM (all families), logit, probit, multinomial, count models, zero-inflated models, quantile regression, robust regression
- **Time series**: ARIMA, SARIMAX, VAR, exponential smoothing, state space models, unit root tests
- **Diagnostics**: Heteroskedasticity tests, normality tests, specification tests, VIF, influence measures, residual analysis
- **Hypothesis testing**: t-tests, F-tests, Wald tests, likelihood ratio tests, multiple comparison corrections

## How to Use This Skill

### Reference File Structure

| File | Purpose | When to Read |
|------|---------|--------------|
| `quickstart.md` | Installation, formula vs array API, first model | Starting with statsmodels |
| `linear-models.md` | OLS, WLS, GLS, robust regression, quantile regression | Fitting linear models |
| `glm-discrete.md` | GLM families, logit/probit, count models, zero-inflated | Non-linear models, binary/count outcomes |
| `time-series.md` | ARIMA, SARIMAX, VAR, exponential smoothing, unit root tests | Analyzing temporal data |
| `diagnostics.md` | Heteroskedasticity, normality, VIF, influence, residuals | Checking model assumptions |
| `hypothesis-testing.md` | t-tests, F-tests, Wald tests, multiple comparisons | Testing coefficients and comparing models |
| `gotchas.md` | Constant term, convergence, predict pitfalls, pyfixest boundary | Debugging issues |

### Reading Order

1. **New to statsmodels?** Start with `quickstart.md` then `linear-models.md`
2. **Need GLM or logit/probit?** Read `quickstart.md` then `glm-discrete.md`
3. **Time series analysis?** Read `quickstart.md` then `time-series.md`
4. **Checking model assumptions?** Read `diagnostics.md`
5. **Coming from R?** Read `quickstart.md` (formula API mirrors R syntax)

## Related Skills

- **pyfixest**: Use instead of statsmodels when your model needs absorbed fixed effects, IV with FE, or difference-in-differences. pyfixest is faster for FE models; statsmodels is broader for everything else
- **linearmodels**: Use for panel data models (FE, RE, between, first difference, Fama-MacBeth), IV/GMM without FE (2SLS, LIML, GMM), system estimation (SUR, 3SLS), and asset pricing. Built on top of statsmodels; extends it for structured data
- **svy**: Use for survey-weighted regression and estimation with complex survey designs. **Important:** statsmodels WLS is NOT equivalent to survey-weighted regression — WLS handles heteroscedastic errors but does not account for stratification, clustering, or finite population corrections. If your data comes from a complex probability survey (NHANES, ACS PUMS, CPS, ECLS-K, etc.), load the `svy` skill instead
- **data-scientist**: Provides methodology guidance (when to use which model, assumption checking protocol, interpretation). Load alongside statsmodels for the "why"; statsmodels provides the "how"
- **polars**: Data manipulation before modeling. statsmodels accepts pandas DataFrames; convert with `df.to_pandas()` if using Polars
- **plotnine**: Publication-quality visualization of model results and diagnostics

## Quick Decision Trees

### "I need to fit a regression model"

```
What kind of regression?
├─ Linear (continuous outcome)
│   ├─ Basic OLS → ./references/linear-models.md
│   ├─ Weighted least squares → ./references/linear-models.md
│   │   (⚠ WLS ≠ survey-weighted regression — for complex surveys, use `svy` skill)
│   ├─ Correlated errors (GLS) → ./references/linear-models.md
│   ├─ Robust to outliers (M-estimator) → ./references/linear-models.md
│   └─ Quantile regression → ./references/linear-models.md
├─ Binary outcome (0/1)
│   ├─ Logit → ./references/glm-discrete.md
│   └─ Probit → ./references/glm-discrete.md
├─ Count outcome (0, 1, 2, ...)
│   ├─ Poisson → ./references/glm-discrete.md
│   ├─ Negative binomial → ./references/glm-discrete.md
│   └─ Zero-inflated → ./references/glm-discrete.md
├─ Multinomial (3+ categories)
│   └─ Multinomial logit → ./references/glm-discrete.md
├─ GLM (custom family/link)
│   └─ GLM framework → ./references/glm-discrete.md
└─ Need fixed effects?
    └─ Use pyfixest instead (faster FE absorption)
```

### "I need to analyze time series"

```
What time series task?
├─ Forecast a single series
│   ├─ ARIMA / SARIMAX → ./references/time-series.md
│   └─ Exponential smoothing → ./references/time-series.md
├─ Multiple interrelated series
│   └─ VAR / VECM → ./references/time-series.md
├─ Test for stationarity
│   ├─ ADF test → ./references/time-series.md
│   └─ KPSS test → ./references/time-series.md
├─ Examine autocorrelation
│   └─ ACF / PACF → ./references/time-series.md
└─ Structural time series
    └─ Unobserved components → ./references/time-series.md
```

### "I need to check model assumptions"

```
What assumption to check?
├─ Heteroskedasticity → ./references/diagnostics.md
│   ├─ Breusch-Pagan test
│   └─ White test
├─ Normality of residuals → ./references/diagnostics.md
│   ├─ Jarque-Bera test
│   └─ Shapiro-Wilk test
├─ Specification / functional form → ./references/diagnostics.md
│   └─ RESET test
├─ Multicollinearity → ./references/diagnostics.md
│   ├─ VIF
│   └─ Condition number
├─ Influential observations → ./references/diagnostics.md
│   ├─ Cook's distance
│   └─ Leverage / DFFITS
├─ Serial correlation → ./references/diagnostics.md
│   └─ Durbin-Watson / Breusch-Godfrey
└─ All of the above → ./references/diagnostics.md
```

### "I need to test hypotheses"

```
What kind of test?
├─ Single coefficient significance → ./references/hypothesis-testing.md
├─ Joint significance (F-test) → ./references/hypothesis-testing.md
├─ Linear restrictions (Wald) → ./references/hypothesis-testing.md
├─ Compare nested models (LR test) → ./references/hypothesis-testing.md
├─ Multiple comparisons correction → ./references/hypothesis-testing.md
└─ Chi-squared test → ./references/hypothesis-testing.md
```

### "Something isn't working"

```
Common issues?
├─ Missing constant / intercept → ./references/gotchas.md
├─ Convergence warnings → ./references/gotchas.md
├─ predict() errors → ./references/gotchas.md
├─ Formula parsing issues → ./references/gotchas.md
├─ summary() formatting → ./references/gotchas.md
├─ statsmodels vs pyfixest → ./references/gotchas.md
└─ General troubleshooting → ./references/gotchas.md
```

## File-First Execution in Research Workflows

**Important:** In data research pipelines (see `CLAUDE.md`), statsmodels analyses are executed through **script files**, not interactively. This ensures auditability and reproducibility.

**The pattern:**
1. Write model code to `scripts/stage8_analysis/{step}_{model-name}.py`
2. Execute via Bash with automatic output capture wrapper script
3. Validation results get automatically embedded in scripts as comments
4. If failed, create versioned copy for fixes

Closely read `agent_reference/SCRIPT_EXECUTION_REFERENCE.md` for the mandatory file-first execution protocol covering complete code file writing, output capture, and file versioning rules.

**See:**
- `agent_reference/SCRIPT_EXECUTION_REFERENCE.md` — Script execution protocol and format with validation

The examples below show statsmodels syntax. In research workflows, wrap them in scripts following the file-first pattern.

---

## Quick Reference

### Essential Imports

```python
import statsmodels.api as sm           # Array API
import statsmodels.formula.api as smf  # Formula API (R-style)
```

### Core Operations

| Operation | Code |
|-----------|------|
| OLS (formula) | `smf.ols("y ~ x1 + x2", data=df).fit()` |
| OLS (array) | `sm.OLS(y, sm.add_constant(X)).fit()` |
| Logit | `smf.logit("y ~ x1 + x2", data=df).fit()` |
| Probit | `smf.probit("y ~ x1 + x2", data=df).fit()` |
| Poisson | `smf.poisson("y ~ x1 + x2", data=df).fit()` |
| GLM (custom) | `smf.glm("y ~ x1", data=df, family=sm.families.Binomial()).fit()` |
| WLS | `smf.wls("y ~ x1", data=df, weights=w).fit()` |
| Robust (HC1) | `fit = smf.ols(...).fit(cov_type='HC1')` |
| ARIMA | `sm.tsa.ARIMA(y, order=(p,d,q)).fit()` |
| Summary | `results.summary()` |
| Predict | `results.predict(new_data)` |
| Confidence intervals | `results.conf_int(alpha=0.05)` |
| Marginal effects | `results.get_margeff(at='overall')` |
| VIF | `from statsmodels.stats.outliers_influence import variance_inflation_factor` |
| Breusch-Pagan | `sm.stats.diagnostic.het_breuschpagan(resid, exog)` |

### Formula Syntax

```python
# Additive terms
"y ~ x1 + x2 + x3"

# Interaction (with main effects)
"y ~ x1 * x2"           # equivalent to x1 + x2 + x1:x2

# Interaction only (no main effects)
"y ~ x1 : x2"

# Categorical variable
"y ~ C(region)"          # treatment coding (default)
"y ~ C(region, Treatment(reference='West'))"  # explicit reference

# Suppress intercept
"y ~ x1 + x2 - 1"

# Polynomial
"y ~ x1 + I(x1**2)"     # I() protects Python operators
```

## Topic Index

| Topic | Reference File |
|-------|---------------|
| Installation | `./references/quickstart.md` |
| Formula vs array API | `./references/quickstart.md` |
| Reading summary output | `./references/quickstart.md` |
| Comparison to pyfixest | `./references/quickstart.md` |
| OLS regression | `./references/linear-models.md` |
| Weighted least squares | `./references/linear-models.md` |
| GLS | `./references/linear-models.md` |
| Robust regression (RLM) | `./references/linear-models.md` |
| Quantile regression | `./references/linear-models.md` |
| Interactions and polynomials | `./references/linear-models.md` |
| GLM framework | `./references/glm-discrete.md` |
| Logit / probit | `./references/glm-discrete.md` |
| Multinomial logit | `./references/glm-discrete.md` |
| Poisson / negative binomial | `./references/glm-discrete.md` |
| Zero-inflated models | `./references/glm-discrete.md` |
| Marginal effects | `./references/glm-discrete.md` |
| Exposure / offset | `./references/glm-discrete.md` |
| ARIMA / SARIMAX | `./references/time-series.md` |
| VAR / VECM | `./references/time-series.md` |
| Exponential smoothing | `./references/time-series.md` |
| Unit root tests | `./references/time-series.md` |
| ACF / PACF | `./references/time-series.md` |
| Forecasting | `./references/time-series.md` |
| State space models | `./references/time-series.md` |
| Heteroskedasticity tests | `./references/diagnostics.md` |
| Normality tests | `./references/diagnostics.md` |
| Specification tests (RESET) | `./references/diagnostics.md` |
| VIF / multicollinearity | `./references/diagnostics.md` |
| Influence measures | `./references/diagnostics.md` |
| Residual analysis | `./references/diagnostics.md` |
| Durbin-Watson | `./references/diagnostics.md` |
| t-tests and F-tests | `./references/hypothesis-testing.md` |
| Wald tests | `./references/hypothesis-testing.md` |
| Likelihood ratio tests | `./references/hypothesis-testing.md` |
| Multiple comparison corrections | `./references/hypothesis-testing.md` |
| Comparing nested models | `./references/hypothesis-testing.md` |
| Serial correlation tests | `./references/diagnostics.md` |
| Diagnostic checklist | `./references/diagnostics.md` |
| Chi-squared tests | `./references/hypothesis-testing.md` |
| Joint significance tests | `./references/hypothesis-testing.md` |
| Ordered logit / probit | `./references/glm-discrete.md` |
| Mixed effects (MixedLM) | `./references/linear-models.md` |
| Constant term pitfall | `./references/gotchas.md` |
| Convergence warnings | `./references/gotchas.md` |
| predict() issues | `./references/gotchas.md` |
| Formula parsing (patsy) | `./references/gotchas.md` |
| summary() vs summary2() | `./references/gotchas.md` |
| NaN / missing data | `./references/gotchas.md` |
| DataFrame index issues | `./references/gotchas.md` |
| statsmodels vs pyfixest | `./references/gotchas.md` |

## Citation

When this library is used as a primary analytical tool, include in the report's
Software & Tools references:

> Seabold, S. & Perktold, J. (2010). "Statsmodels: Econometric and Statistical Modeling with Python." *Proceedings of the 9th Python in Science Conference*.

**Cite when:** statsmodels is used for GLM estimation, time series modeling, or statistical hypothesis testing central to the analysis.
**Do not cite when:** Only used for post-estimation diagnostics supporting another library's primary estimation.

For method-specific citations (e.g., individual estimators or techniques),
consult the reference files in this skill and `agent_reference/CITATION_REFERENCE.md`.
