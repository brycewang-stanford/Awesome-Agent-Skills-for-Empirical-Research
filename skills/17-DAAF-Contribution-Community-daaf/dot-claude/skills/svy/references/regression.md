# svy Regression Reference

svy v0.13.0 — syntax and library guidance only.

---

## Contents

1. [Overview: Survey-Weighted GLM](#overview-survey-weighted-glm)
2. [Survey-Weighted Linear Regression (Gaussian)](#survey-weighted-linear-regression-gaussian)
3. [Survey-Weighted Logistic Regression (Binomial)](#survey-weighted-logistic-regression-binomial)
4. [Survey-Weighted Poisson Regression](#survey-weighted-poisson-regression)
5. [Specifying Predictors](#specifying-predictors)
6. [Extracting Results](#extracting-results)
7. [Survey Regression vs. WLS vs. Cluster-Robust SEs](#survey-regression-vs-wls-vs-cluster-robust-ses)
8. [Diagnostics and Model Fit](#diagnostics-and-model-fit)
9. [Domain-Specific Regression](#domain-specific-regression)
10. [The rpy2 Bridge for Unsupported Models](#the-rpy2-bridge-for-unsupported-models)
11. [Complete Regression Workflow Example](#complete-regression-workflow-example)

---

## Overview: Survey-Weighted GLM

svy fits generalized linear models (GLMs) that account for the complex survey design in both point estimation and variance estimation. The interface is through `sample.glm.fit()`:

```python
model = sample.glm.fit(
    y="outcome_variable",
    x=["predictor1", "predictor2", svy.Cat("categorical_var")],
    family="gaussian"  # or "binomial" or "poisson"
)
```

**Supported families:**

| Family | Use Case | Link Function |
|--------|----------|---------------|
| `"gaussian"` | Continuous outcome (linear regression) | Identity |
| `"binomial"` | Binary outcome (logistic regression) | Logit |
| `"poisson"` | Count outcome (Poisson regression) | Log |

**Not supported in svy** (use rpy2 + R survey package):
- Negative binomial
- Ordinal logistic (`svyolr` in R)
- Cox proportional hazards (`svycoxph` in R)
- Multinomial logistic
- Quasi-families

The design-based SEs produced by `sample.glm.fit()` are model-robust "sandwich" estimators that account for stratification, clustering, and unequal probability of selection. These are analogous to R's `survey::svyglm()`.

---

## Survey-Weighted Linear Regression (Gaussian)

### Basic Linear Model

```python
import svy
import polars as pl

# Load and set up design (see design-weights.md)
data = pl.read_parquet("data/raw/nhanes.parquet")
design = svy.Design(stratum="sdmvstra", psu="sdmvpsu", wgt="wtmec2yr")
sample = svy.Sample(data=data, design=design)

# INTENT: Estimate association between age and BMI, controlling for gender
# REASONING: Linear model appropriate for continuous outcome (BMI)
# ASSUMES: Linear relationship between age and BMI within the modeled range
model = sample.glm.fit(
    y="bmxbmi",
    x=["ridageyr", svy.Cat("riagendr")],
    family="gaussian"
)
print(model)
```

### Multiple Continuous Predictors

```python
model = sample.glm.fit(
    y="bmxbmi",
    x=["ridageyr", "indfmpir", "lbxtc"],
    family="gaussian"
)
```

### Interpreting Gaussian GLM Output

The coefficients from a gaussian-family GLM are interpreted identically to OLS:
- Each coefficient represents the expected change in Y for a one-unit change in X, holding other variables constant
- The intercept is the expected value of Y when all predictors are zero
- SEs, t-statistics, and p-values reflect the complex survey design, not simple random sampling assumptions

---

## Survey-Weighted Logistic Regression (Binomial)

### Basic Logistic Model

```python
# INTENT: Model probability of obesity as a function of demographics
# REASONING: Binary outcome (obese yes/no) requires logistic regression
# ASSUMES: The outcome variable is coded 0/1
model = sample.glm.fit(
    y="obese_flag",
    x=["ridageyr", "indfmpir", svy.Cat("riagendr"), svy.Cat("ridreth1")],
    family="binomial"
)
print(model)
```

### Interpreting Logistic GLM Output

- Coefficients are on the **log-odds** scale
- To get odds ratios: exponentiate the coefficients (`exp(coef)`)
- A positive coefficient means higher odds of the outcome for a one-unit increase in the predictor
- SEs are on the log-odds scale; exponentiate the confidence interval bounds for OR CIs

```python
import numpy as np

# sample.glm.fit() returns the GLM accessor; the GLMFit result is at glm.fitted
glm = sample.glm.fit(y="obese_flag", x=["ridageyr", svy.Cat("riagendr")], family="binomial")
fit = glm.fitted                          # GLMFit object

# Convert to odds ratios via the GLMFit.to_polars() DataFrame
coef_df = fit.to_polars()                 # columns: term, estimate, std_err, conf_low, conf_high, statistic, p_value, df
odds_ratios = np.exp(coef_df["estimate"])
or_ci_lower = np.exp(coef_df["conf_low"])
or_ci_upper = np.exp(coef_df["conf_high"])

# Or access individual coefficients via fit.coefs (list of GLMCoef objects)
for c in fit.coefs:
    print(f"{c.term}: OR={np.exp(c.est):.3f}  [{np.exp(c.lci):.3f}, {np.exp(c.uci):.3f}]")
```

### Important: Quasi-Binomial in R vs. svy

In R's `survey::svyglm()`, `family=quasibinomial()` is preferred over `family=binomial()` to avoid warnings about non-integer successes (which arise from weighted data). svy handles this internally — use `family="binomial"` directly.

---

## Survey-Weighted Poisson Regression

### Basic Poisson Model

```python
# INTENT: Model count of doctor visits as a function of health indicators
# REASONING: Count outcome with no upper bound suits Poisson regression
# ASSUMES: Conditional mean equals conditional variance (Poisson assumption)
model = sample.glm.fit(
    y="doctor_visits",
    x=["ridageyr", svy.Cat("health_status"), svy.Cat("insurance_status")],
    family="poisson"
)
print(model)
```

### Interpreting Poisson GLM Output

- Coefficients are on the **log scale**
- To get incidence rate ratios (IRRs): exponentiate the coefficients
- A coefficient of 0.3 means `exp(0.3) = 1.35`, i.e., a 35% higher rate for a one-unit increase
- SEs are on the log scale; exponentiate CI bounds for IRR CIs

### Overdispersion Caveat

Poisson regression assumes the conditional variance equals the conditional mean. Survey data often exhibits overdispersion (variance > mean). The design-based SEs from svy partially accommodate this because they are sandwich estimators, but severe overdispersion may still produce misleading inference. Consider:
1. Checking whether the mean-variance assumption is reasonable
2. For negative binomial (overdispersed Poisson), use rpy2 + R's `survey::svyglm(family=quasipoisson())` or `MASS::glm.nb` with survey design

---

## Specifying Predictors

### Continuous Predictors

Pass variable names as strings in the `x` list:

```python
x=["age", "income", "bmi"]
```

### Categorical Predictors with svy.Cat

Wrap categorical variable names in `svy.Cat()` to get proper dummy coding:

```python
x=["age", svy.Cat("education"), svy.Cat("region")]
```

`svy.Cat()` creates indicator (dummy) variables for each level, with one level omitted as the reference category. The reference category is typically the first level alphabetically or numerically.

### Mixing Continuous and Categorical

```python
model = sample.glm.fit(
    y="income",
    x=[
        "age",                          # continuous
        "years_education",              # continuous
        svy.Cat("gender"),              # categorical (2 levels)
        svy.Cat("race_ethnicity"),      # categorical (5 levels)
        svy.Cat("marital_status"),      # categorical (3 levels)
    ],
    family="gaussian"
)
```

### Interactions

```python
# Pre-compute interaction columns in Polars before passing to svy
data = data.with_columns(
    (pl.col("age") * pl.col("income")).alias("age_x_income")
)
sample = svy.Sample(data=data, design=design)
model = sample.glm.fit(
    y="bmi",
    x=["age", "income", "age_x_income"],
    family="gaussian"
)
```

---

## Extracting Results

### Model Output Structure

The model object returned by `sample.glm.fit()` contains point estimates, standard errors, test statistics, p-values, and confidence intervals for each coefficient.

```python
model = sample.glm.fit(y="bmxbmi", x=["ridageyr", svy.Cat("riagendr")], family="gaussian")

# Print full summary
print(model)
```

### Accessing Individual Components

`sample.glm.fit()` returns the `GLM` accessor. The fitted result (`GLMFit`) is stored at `glm.fitted`:

```python
glm = sample.glm.fit(y="bmxbmi", x=["ridageyr", svy.Cat("riagendr")], family="gaussian")
fit = glm.fitted                          # GLMFit object

# --- Tabular output (recommended) ---
coef_df = fit.to_polars()
# columns: term, estimate, std_err, conf_low, conf_high, statistic, p_value, df

# --- Individual coefficient objects ---
for c in fit.coefs:                       # list of GLMCoef
    print(c.term, c.est, c.se, c.lci, c.uci)
    # c.wald  — TDist with .value (t-statistic) and .p_value

# --- Model statistics ---
stats = fit.stats                         # GLMStats
print(stats.n, stats.r_squared, stats.aic, stats.bic, stats.deviance)
```

**Important:** `sample.glm` creates a new `GLM` object each time it is accessed (it is a property). You must hold a reference to the return value of `.fit()` to access `glm.fitted` and `glm.predict()` later.

### Reporting Results

When reporting survey regression results:
1. State the survey design (strata, PSU, weight variable)
2. Report the variance estimation method (Taylor linearization or replicate type)
3. Report design-based degrees of freedom (not sample size minus parameters)
4. Report coefficients with design-based SEs and CIs
5. Note the effective sample size if substantially smaller than n

---

## Survey Regression vs. WLS vs. Cluster-Robust SEs

This distinction is critical. Three approaches look superficially similar but are fundamentally different:

### 1. Survey-Weighted Regression (svy)

```python
# svy: accounts for strata, PSU, and unequal selection probabilities
design = svy.Design(stratum="strata", psu="psu", wgt="weight")
sample = svy.Sample(data=data, design=design)
model = sample.glm.fit(y="y", x=["x1", "x2"], family="gaussian")
```

**What it does:**
- Uses weights in point estimation (weighted least squares for coefficients)
- Uses the full design (strata + PSU + weights) for variance estimation
- Produces design-based degrees of freedom (# PSUs - # strata)
- Accounts for stratification (reduces variance), clustering (increases variance), and unequal selection

### 2. Weighted Least Squares (statsmodels WLS)

```python
# statsmodels WLS: uses weights for point estimates only
import statsmodels.formula.api as smf
results = smf.wls("y ~ x1 + x2", data=df, weights=df["weight"]).fit()
```

**What it does:**
- Uses weights in point estimation
- Does NOT account for stratification or clustering in variance
- Assumes independent observations with heterogeneous variance
- **Produces incorrect SEs for survey data** — typically too small

### 3. Cluster-Robust Standard Errors (statsmodels / pyfixest)

```python
# Cluster-robust SEs: accounts for clustering only
import statsmodels.formula.api as smf
results = smf.ols("y ~ x1 + x2", data=df).fit(cov_type="cluster", cov_kwds={"groups": df["psu"]})
```

**What it does:**
- Does NOT use survey weights in point estimation (unless combined with WLS)
- Accounts for within-cluster correlation in variance
- Does NOT account for stratification or unequal selection
- Approximation that works for some settings but is not a substitute for design-based inference

### Summary Comparison

| Aspect | svy Survey Regression | statsmodels WLS | Cluster-Robust SEs |
|--------|----------------------|-----------------|-------------------|
| Weights in point estimates | Yes | Yes | No (unless combined) |
| Stratification in SE | Yes | No | No |
| Clustering in SE | Yes | No | Yes |
| Unequal selection in SE | Yes | No | No |
| Degrees of freedom | Design-based | Model-based | Large-sample |
| Correct for complex surveys | **Yes** | **No** | **No** |

**Rule of thumb:** If you have data from a complex survey with known design variables, use svy. If you have non-survey data with clustered observations, cluster-robust SEs are appropriate.

---

## Diagnostics and Model Fit

### R-Squared in Survey Context

Traditional R-squared is not well-defined for survey-weighted regression because the weights change the effective sample. Some implementations report a pseudo-R-squared. Interpret with caution.

### Residual Analysis

```python
# Residuals and fitted values are obtained via glm.predict()
glm = sample.glm.fit(y="bmxbmi", x=["ridageyr", svy.Cat("riagendr")], family="gaussian")

# Pass y_col to get residuals (without it, pred.residuals is None)
pred = glm.predict(new_data=data, y_col="bmxbmi")
residuals = pred.residuals               # numpy array
fitted_values = pred.yhat                 # numpy array

# As a Polars DataFrame:
pred_df = pred.to_polars()                # columns: yhat, se, lci, uci, residuals
```

Residual plots for survey regressions should use weighted residuals. Unweighted residual plots can be misleading because they treat all observations equally regardless of their representation of the population.

### Specification Concerns

Standard diagnostic tests (Breusch-Pagan, RESET, VIF) from statsmodels are designed for simple random samples. For survey data:
- **Multicollinearity**: VIF computed on the unweighted design matrix is still informative for detecting collinearity, though not for assessing its impact on survey SEs
- **Functional form**: Plot weighted residuals against predictors visually; formal tests require survey-adjusted versions
- **Influential observations**: Observations with large weights are inherently influential by design — they represent more of the population. Do not simply remove them without substantive justification

### Model Comparison

```python
glm = sample.glm.fit(y="bmxbmi", x=["ridageyr", svy.Cat("riagendr")], family="gaussian")
fit = glm.fitted

# AIC/BIC are on the GLMStats object (fit.stats), not the model directly
print(f"AIC: {fit.stats.aic}")
print(f"BIC: {fit.stats.bic}")
```

For comparing nested survey regression models, use Wald tests based on the design-based covariance matrix rather than likelihood ratio tests (which assume independent observations).

---

## Domain-Specific Regression

To fit a regression model for a subpopulation (domain), do NOT pre-filter the data. Instead, use domain estimation:

```python
# WRONG: pre-filtering breaks the design
# females = data.filter(pl.col("gender") == 2)
# female_sample = svy.Sample(data=females, design=design)
# model = female_sample.glm.fit(...)  # <-- WRONG SEs
```

> **Limitation (v0.13.0):** Domain-restricted regression (fitting a model within a subpopulation while preserving the full design) is **not supported** in `sample.glm.fit()`. The `fit()` method has no `by=`, `subset=`, or `where=` parameter. For domain estimation of means/totals/proportions, use `sample.estimation.mean(..., by="group")`, which does support correct domain analysis. For regression within a subpopulation, the only current option is to pre-filter the data, with the caveat that SEs will not fully account for the original design structure. Document this limitation in your analysis with an `# ASSUMES:` comment.

Domain regression preserves the full design structure for variance estimation while restricting the model to the subpopulation of interest. This is methodologically equivalent to R's `svyglm(..., design=subset(design, gender == 2))` where the subsetting is done within the survey design framework. Monitor future svy releases for this feature.

---

## The rpy2 Bridge for Unsupported Models

When svy does not support the needed model (ordinal logistic, Cox survival, negative binomial, etc.), use R's survey package via rpy2.

### Setup

```python
# rpy2 bridge pattern — this is standard rpy2, not svy-specific
import rpy2.robjects as ro
from rpy2.robjects import pandas2ri
from rpy2.robjects.packages import importr

pandas2ri.activate()
survey_r = importr("survey")

# Convert Polars to pandas for rpy2 (rpy2 uses pandas bridge)
df_pandas = data.to_pandas()

# Create R survey design
r_design = survey_r.svydesign(
    ids=ro.Formula("~psu_id"),
    strata=ro.Formula("~stratum"),
    weights=ro.Formula("~weight"),
    data=df_pandas,
    nest=True
)
```

### Ordinal Logistic

```python
# Ordinal logistic regression in R via rpy2
r_model = survey_r.svyolr(
    ro.Formula("ordered_outcome ~ age + education"),
    design=r_design
)
print(ro.r.summary(r_model))
```

### Cox Proportional Hazards

```python
# Cox PH model in R via rpy2
r_model = survey_r.svycoxph(
    ro.Formula("Surv(time, event) ~ age + treatment"),
    design=r_design
)
print(ro.r.summary(r_model))
```

### Negative Binomial (via Quasi-Poisson)

```python
# Quasi-Poisson as overdispersion-robust alternative
r_model = survey_r.svyglm(
    ro.Formula("count ~ age + region"),
    design=r_design,
    family=ro.r("quasipoisson()")
)
print(ro.r.summary(r_model))
```

**Decision rule:** If `family` is not `"gaussian"`, `"binomial"`, or `"poisson"`, use the rpy2 bridge. Document the bridge usage with `# REASONING:` comments explaining why svy was insufficient.

---

## Complete Regression Workflow Example

```python
import svy
import polars as pl
import numpy as np

# --- Config ---
DATA_PATH = "data/raw/2026-03-27_nhanes_demo_exam.parquet"
OUTPUT_PATH = "output/analysis/2026-03-27_bmi_regression.parquet"

# --- Load ---
data = pl.read_parquet(DATA_PATH)
print(f"Loaded {data.shape[0]} rows, {data.shape[1]} columns")

# --- Design ---
# INTENT: NHANES 2017-2020 uses a complex multi-stage probability design
# REASONING: sdmvstra/sdmvpsu are masked design variables; wtmec2yr is the
#   2-year MEC exam weight appropriate for variables collected during the exam
# ASSUMES: Analysis restricted to MEC-examined participants aged 20+
design = svy.Design(stratum="sdmvstra", psu="sdmvpsu", wgt="wtmec2yr")
sample = svy.Sample(data=data, design=design)

# --- Transform ---
# INTENT: Create age-squared term for nonlinear age effect on BMI
from svy.core.expr import col
sample = sample.wrangling.mutate({
    "age_sq": col("ridageyr") ** 2
})

# --- Analysis ---
# INTENT: Estimate association between demographics and BMI
# REASONING: Gaussian family for continuous outcome; design-based SEs
# ASSUMES: Linear in parameters; additive effects; no unmeasured confounders
model = sample.glm.fit(
    y="bmxbmi",
    x=[
        "ridageyr",
        "age_sq",
        "indfmpir",
        svy.Cat("riagendr"),
        svy.Cat("ridreth1"),
    ],
    family="gaussian"
)
print(model)

# --- Validate ---
# Verify model ran on expected sample size
print(f"Input data rows: {data.shape[0]}")
fit = model.fitted
print(f"Model N: {fit.stats.n}")
print(f"R-squared: {fit.stats.r_squared:.4f}")
print(f"AIC: {fit.stats.aic:.2f}")
```
