# statsmodels GLM and Discrete Models Reference

statsmodels v0.14.6 — syntax and library guidance only.

---

## Contents

1. [GLM Framework](#glm-framework)
2. [Logit and Probit (Discrete Choice)](#logit-and-probit-discrete-choice)
3. [Multinomial Logit (MNLogit)](#multinomial-logit-mnlogit)
4. [Poisson and Negative Binomial Count Models](#poisson-and-negative-binomial-count-models)
5. [Zero-Inflated Models](#zero-inflated-models)
6. [Separation Detection](#separation-detection)
7. [Marginal Effects](#marginal-effects)
8. [Exposure and Offset for Rate Models](#exposure-and-offset-for-rate-models)
9. [Ordered logit / probit](#ordered-logit-and-probit-orderedmodel)
10. [References and Further Reading](#references-and-further-reading)

---

## GLM Framework

The `GLM` class provides a unified interface for all generalized linear models. Specify the distribution of y via a `family` object and optionally override the default link function.

### Basic Usage

```python
import statsmodels.api as sm
import statsmodels.formula.api as smf

# Formula API
results = smf.glm("y ~ x1 + x2", data=df,
                   family=sm.families.Binomial()).fit()

# Array API
X = sm.add_constant(df[["x1", "x2"]])
results = sm.GLM(df["y"], X, family=sm.families.Binomial()).fit()

print(results.summary())
```

### Family Classes

All families are under `sm.families`:

| Family | Default Link | Use For |
|--------|--------------|---------|
| `Gaussian()` | Identity | Continuous outcomes (same as OLS) |
| `Binomial()` | Logit | Binary outcomes (0/1), proportions |
| `Poisson()` | Log | Count data |
| `NegativeBinomial(alpha=1.0)` | Log | Overdispersed counts |
| `Gamma()` | InversePower | Positive continuous, right-skewed |
| `InverseGaussian()` | InverseSquared | Positive continuous, highly skewed |
| `Tweedie(var_power=1.5)` | Log | Mixed continuous-discrete (e.g., insurance claims) |

`NegativeBinomial(alpha=1.0)`: `alpha` is the overdispersion parameter (also called the heterogeneity parameter). Larger alpha = more overdispersion. When alpha → 0, approaches Poisson.

`Tweedie(var_power=p)`: variance = μ^p. `p=1` is Poisson, `p=2` is Gamma. Values between 1 and 2 produce a compound Poisson-Gamma (Tweedie) distribution with a point mass at zero.

### Link Functions

All links are under `sm.families.links`:

| Link | Function g(μ) | Inverse μ = g⁻¹(η) |
|------|--------------|---------------------|
| `Identity()` | μ | η |
| `Log()` | ln(μ) | exp(η) |
| `Logit()` | ln(μ/(1-μ)) | 1/(1+exp(-η)) |
| `Probit()` | Φ⁻¹(μ) | Φ(η) |
| `CLogLog()` | ln(-ln(1-μ)) | 1-exp(-exp(η)) |
| `InversePower()` | 1/μ | 1/η |
| `InverseSquared()` | 1/μ² | 1/√η |
| `Power(power=1)` | μ^p | η^(1/p) |
| `Cauchy()` | tan(π·(p - 0.5)) | arctan(η)/π + 0.5 |

### Specifying a Non-Default Link

```python
# Probit link with Binomial family (probit regression via GLM)
results = smf.glm("y ~ x1 + x2", data=df,
                   family=sm.families.Binomial(
                       link=sm.families.links.Probit()
                   )).fit()

# Log link with Gaussian family (log-linear model for continuous y)
results = smf.glm("y ~ x1 + x2", data=df,
                   family=sm.families.Gaussian(
                       link=sm.families.links.Log()
                   )).fit()

# Complementary log-log link (Binomial family — proportional hazards interpretation)
results = smf.glm("y ~ x1 + x2", data=df,
                   family=sm.families.Binomial(
                       link=sm.families.links.CLogLog()
                   )).fit()
```

### GLM Result Attributes

```python
results.params          # Coefficients on the link scale
results.pvalues         # P-values
results.conf_int()      # Confidence intervals (default alpha=0.05)
results.fittedvalues    # Fitted values on the response scale (μ̂)
results.resid_response  # Response residuals: y - μ̂
results.resid_pearson   # Pearson residuals: (y - μ̂) / sqrt(V(μ̂))
results.resid_deviance  # Deviance residuals (signed sqrt of deviance contributions)
results.deviance        # Residual deviance
results.null_deviance   # Null model deviance (intercept only)
results.df_resid        # Residual degrees of freedom
results.df_model        # Model degrees of freedom (excl. constant)
results.aic             # AIC = deviance + 2 * (df_model + 1)
results.bic             # BIC
results.llf             # Log-likelihood
results.nobs            # Number of observations
```

Dispersion parameter (phi):

```python
results.scale           # Estimated dispersion (phi); for Poisson/Binomial fixed at 1
```

### Prediction from GLM

```python
# Predict on new data — returns values on the response scale (μ̂)
y_pred = results.predict(new_data)

# Predict with confidence intervals (linear predictor scale by default)
pred = results.get_prediction(new_data)
frame = pred.summary_frame(alpha=0.05)
# Columns: mean, mean_se, mean_ci_lower, mean_ci_upper
```

---

## Logit and Probit (Discrete Choice)

Dedicated classes for binary dependent variables. These offer additional features beyond `GLM(family=Binomial())`: McFadden's R², `pred_table()`, and direct `get_margeff()`.

### Logit

```python
# Formula API
results = smf.logit("y ~ x1 + x2 + x3", data=df).fit()

# Array API
results = sm.Logit(df["y"], sm.add_constant(df[["x1", "x2", "x3"]])).fit()

print(results.summary())
```

Logit coefficients are log-odds ratios. Exponentiate for odds ratios:

```python
import numpy as np

or_df = pd.DataFrame({
    "OR": np.exp(results.params),
    "ci_lo": np.exp(results.conf_int()[0]),
    "ci_hi": np.exp(results.conf_int()[1])
})
print(or_df)
```

### Probit

```python
# Formula API
results = smf.probit("y ~ x1 + x2 + x3", data=df).fit()

# Array API
results = sm.Probit(df["y"], sm.add_constant(df[["x1", "x2", "x3"]])).fit()
```

Probit coefficients scale with the standard normal CDF. They are not directly interpretable as odds ratios; use marginal effects (see section below).

### Key Result Attributes for Binary Models

```python
results.llf             # Log-likelihood of the fitted model
results.llnull          # Log-likelihood of the null model (intercept only)
results.prsquared       # McFadden's pseudo R² = 1 - llf / llnull
                        # Values of 0.2-0.4 indicate good fit (lower than OLS R²)
results.pred_table()    # Confusion matrix as numpy array [[TN, FP], [FN, TP]]
                        # Default threshold: 0.5
```

Confusion matrix with labels:

```python
table = results.pred_table()
print(f"True Negatives:  {table[0,0]}")
print(f"False Positives: {table[0,1]}")
print(f"False Negatives: {table[1,0]}")
print(f"True Positives:  {table[1,1]}")
accuracy = (table[0,0] + table[1,1]) / table.sum()
print(f"Accuracy: {accuracy:.3f}")
```

### Predicted Probabilities

```python
# In-sample fitted probabilities
prob_hat = results.predict()          # or results.fittedvalues

# Out-of-sample
prob_new = results.predict(new_data)

# Using get_prediction for confidence intervals
pred = results.get_prediction(new_data)
frame = pred.summary_frame()
# Columns: mean (probability), mean_se, mean_ci_lower, mean_ci_upper
```

---

## Multinomial Logit (MNLogit)

For outcomes with 3 or more unordered categories. The base (reference) category is J=0.

### Usage

```python
# y must be integer-coded: 0, 1, 2, ...
# Category 0 is the reference

# Array API
results = sm.MNLogit(df["y"], sm.add_constant(df[["x1", "x2"]])).fit()

# Formula API
results = smf.mnlogit("y ~ x1 + x2", data=df).fit()

print(results.summary())
```

### Coefficients and Shape

```python
results.params          # Shape: (n_params, J-1)
                        # Columns are categories 1, 2, ..., J-1 (relative to category 0)
results.pvalues         # Same shape as params
results.conf_int()      # Shape: (n_params * (J-1), 2) — stacked by category
```

Extracting coefficients for a specific category:

```python
# Coefficients for category 1 vs. reference (category 0)
coef_cat1 = results.params.iloc[:, 0]

# Coefficients for category 2 vs. reference
coef_cat2 = results.params.iloc[:, 1]
```

### Predicted Probabilities

```python
# Returns (n_obs, J) array — probability of each category for each observation
probs = results.predict()                    # in-sample
probs_new = results.predict(new_data_X)     # out-of-sample (array API: pass design matrix)

# For formula API new data:
probs_new = results.predict(new_data_df)
```

### Changing the Reference Category

To use a different reference category, recode y before fitting:

```python
# Make category 2 the reference by shifting values
df["y_recoded"] = df["y"].map({0: 1, 1: 2, 2: 0})  # category 2 → 0
results = smf.mnlogit("y_recoded ~ x1 + x2", data=df).fit()
```

---

## Poisson and Negative Binomial Count Models

### Poisson

Assumes equidispersion: E[y] = Var[y] = μ. Use when counts are genuinely Poisson-distributed.

```python
# Formula API
results = smf.poisson("count ~ x1 + x2", data=df).fit()

# Array API
results = sm.Poisson(df["count"], sm.add_constant(df[["x1", "x2"]])).fit()

print(results.summary())
```

Checking for overdispersion (Var[y] >> E[y]):

```python
mean_count = df["count"].mean()
var_count = df["count"].var()
dispersion_ratio = var_count / mean_count
print(f"Dispersion ratio: {dispersion_ratio:.2f}")
# >> 1 suggests overdispersion → use NegBin
```

### Negative Binomial

Adds a random effect to the Poisson rate, producing Var[y] = μ + alpha*μ². Use when variance exceeds the mean (overdispersion).

```python
# NegativeBinomial (NB2 parameterization — variance = μ + alpha*μ²)
results = sm.NegativeBinomial(
    df["count"], sm.add_constant(df[["x1", "x2"]])
).fit()

# Via GLM (fixes alpha instead of estimating it)
results = smf.glm("count ~ x1 + x2", data=df,
                   family=sm.families.NegativeBinomial(alpha=1.0)).fit()

# NegativeBinomialP (flexible parameterization: variance = μ + alpha*μ^p)
results = sm.NegativeBinomialP(
    df["count"], sm.add_constant(df[["x1", "x2"]])
).fit()
```

`sm.NegativeBinomial` estimates `alpha` from the data. `sm.families.NegativeBinomial(alpha=...)` fixes it.

### Interpreting Count Model Coefficients

Poisson and NegBin coefficients are log rate ratios. Exponentiate for incidence rate ratios (IRR):

```python
import numpy as np

irr = np.exp(results.params)
irr_ci = np.exp(results.conf_int())
irr_df = pd.concat([irr, irr_ci], axis=1)
irr_df.columns = ["IRR", "CI_lo", "CI_hi"]
print(irr_df)
# IRR > 1: positive association; IRR < 1: negative association
```

### NB2 vs. NB-P

| Model | Variance Function | When to Use |
|-------|------------------|-------------|
| `NegativeBinomial` (NB2) | μ + alpha*μ² | Standard choice for overdispersed counts |
| `NegativeBinomialP` (NB-P) | μ + alpha*μ^p (p estimated) | When the form of overdispersion is unknown |

Accessing the estimated alpha (overdispersion) from NB2:

```python
# alpha is the last element of params in NegativeBinomial
print(f"Estimated alpha: {results.params['alpha']:.4f}")
```

---

## Zero-Inflated Models

For count data with more zeros than a Poisson or NegBin can explain. These model two latent processes: (1) whether an observation is a structural zero, and (2) the count conditional on being non-zero.

### Zero-Inflated Poisson (ZIP)

```python
# exog_infl: covariates for the zero-inflation (structural zero) equation
# Can differ from the count equation covariates
results = sm.ZeroInflatedPoisson(
    df["count"],
    sm.add_constant(df[["x1", "x2"]]),          # count model covariates
    exog_infl=sm.add_constant(df[["z1"]]),        # inflation model covariates
    inflation="logit"                             # logit model for P(structural zero)
).fit()

# If inflation model has same covariates as count model, omit exog_infl
results = sm.ZeroInflatedPoisson(
    df["count"],
    sm.add_constant(df[["x1", "x2"]]),
    inflation="logit"
).fit()
```

`inflation` options: `"logit"` (default) or `"probit"`.

### Zero-Inflated Negative Binomial (ZINB)

```python
results = sm.ZeroInflatedNegativeBinomialP(
    df["count"],
    sm.add_constant(df[["x1", "x2"]]),
    exog_infl=sm.add_constant(df[["z1"]]),
    inflation="logit"
).fit()
```

### Zero-Inflated Generalized Poisson (ZIGP)

```python
results = sm.ZeroInflatedGeneralizedPoisson(
    df["count"],
    sm.add_constant(df[["x1", "x2"]]),
    exog_infl=sm.add_constant(df[["z1"]]),
    inflation="logit"
).fit()
```

### Reading Zero-Inflated Results

The summary contains two blocks of coefficients:

```python
print(results.summary())
# "inflate_*" parameters: coefficients for the zero-inflation (logit) equation
# Positive inflate coefficient → higher probability of structural zero
# Remaining parameters: count model coefficients (log scale)
```

Accessing coefficients by block:

```python
all_params = results.params

# Count model coefficients (prefix varies — check results.params.index)
count_params = all_params[~all_params.index.str.startswith("inflate")]
inflate_params = all_params[all_params.index.str.startswith("inflate")]
```

### Comparing ZIP vs. Poisson with Vuong Test

The Vuong test compares non-nested models (e.g., ZIP vs. Poisson):

```python
from statsmodels.discrete.count_model import ZeroInflatedPoisson
from statsmodels.discrete.discrete_model import Poisson

poisson_res = sm.Poisson(df["count"], X).fit()
zip_res = sm.ZeroInflatedPoisson(df["count"], X, inflation="logit").fit()

# Vuong statistic > 1.96 favors ZIP; < -1.96 favors Poisson
# Not directly built into statsmodels — compute manually or use AIC comparison
print(f"Poisson AIC: {poisson_res.aic:.2f}")
print(f"ZIP AIC:     {zip_res.aic:.2f}")
```

---

## Separation Detection

Perfect or quasi-perfect separation occurs when a predictor (or combination) perfectly predicts y=0 or y=1 in a binary model. The MLE does not exist; coefficients diverge to ±infinity.

### Symptoms

```python
results = smf.logit("y ~ x1 + x2 + C(state)", data=df).fit()

# Warning at convergence is the first signal:
# "Maximum Likelihood optimization failed to converge"
print(results.mle_retvals["converged"])   # False if not converged

# Very large coefficient magnitudes
print(results.params[results.params.abs() > 10])

# Very large standard errors
print(results.bse[results.bse > 100])
```

### Diagnosing the Source

```python
# For a binary predictor suspected of causing separation:
print(pd.crosstab(df["y"], df["x_binary"]))
# If any cell is 0, that predictor perfectly separates y

# For a continuous predictor:
print(df.groupby("y")["x_continuous"].agg(["min", "max"]))
# If ranges do not overlap, separation is present

# Check all categorical predictors
for col in df.select_dtypes("object").columns:
    ct = pd.crosstab(df["y"], df[col])
    zero_cells = (ct == 0).any().any()
    if zero_cells:
        print(f"Potential separation: {col}")
        print(ct)
```

### Fixes

statsmodels does not natively implement Firth (penalized) logit. Options:

1. **Reduce model complexity**: remove the separating predictor, combine sparse categories
2. **Aggregate rare categories**: merge categories with few observations in either y=0 or y=1
3. **External package**: use the `firthlogist` package for Firth's penalized logit
4. **Bayesian prior**: use a weakly informative prior (not available in statsmodels directly)

```python
# Check if dropping a variable resolves convergence
results_reduced = smf.logit("y ~ x1 + x2", data=df).fit()   # dropped x3
print(results_reduced.mle_retvals["converged"])
```

---

## Marginal Effects

GLM and discrete model coefficients are on the link scale (log-odds, log rate). Marginal effects translate them to the response scale (probabilities, rates), enabling direct interpretation.

### `get_margeff()` Method

Available on `Logit`, `Probit`, `Poisson`, `MNLogit`, and `GLM` results:

```python
results = smf.logit("y ~ x1 + x2 + C(group)", data=df).fit()

# Average marginal effects (AME) — most common, averaged over observed X
mfx = results.get_margeff(at="overall", method="dydx")
print(mfx.summary())
```

### `at` Parameter Options

| Value | Meaning |
|-------|---------|
| `"overall"` | Average marginal effect (AME): compute ME at each observation, then average |
| `"mean"` | Marginal effect at the mean (MEM): compute ME at X = X̄ |
| `"median"` | Marginal effect at the median of each X |
| `"zero"` | Marginal effect at X = 0 |
| `"all"` | Marginal effect for every observation (returns n x k matrix) |

AME (`at="overall"`) is generally preferred over MEM because it does not evaluate the model at an artificial observation (the mean of a categorical variable is not a valid category value).

### `method` Parameter Options

| Method | Formula | Interpretation |
|--------|---------|----------------|
| `"dydx"` | ∂P/∂x | Change in probability (or rate) per unit change in x |
| `"eyex"` | (x/P) * ∂P/∂x | Elasticity: % change in P per % change in x |
| `"dyex"` | x * ∂P/∂x | Semi-elasticity: change in P per % change in x |
| `"eydx"` | (1/P) * ∂P/∂x | Semi-elasticity: % change in P per unit change in x |

For count models, replace P with the expected count μ.

### Dummy Variables in Marginal Effects

For binary/categorical predictors, use `dummy=True` to compute the discrete change in probability when the variable switches from 0 to 1:

```python
mfx = results.get_margeff(at="overall", method="dydx", dummy=True)
print(mfx.summary())
```

Without `dummy=True`, marginal effects for binary variables are computed as a derivative (treating the variable as continuous), which is technically incorrect.

### Accessing Marginal Effects Programmatically

```python
mfx = results.get_margeff(at="overall", method="dydx", dummy=True)

mfx.margeff          # Marginal effect point estimates (array)
mfx.margeff_se       # Standard errors
mfx.pvalues          # P-values
mfx.conf_int()       # Confidence intervals — DataFrame with [lower, upper]
mfx.tvalues          # t-statistics

# As a DataFrame
mfx_df = pd.DataFrame({
    "margeff": mfx.margeff,
    "se": mfx.margeff_se,
    "pvalue": mfx.pvalues,
    "ci_lo": mfx.conf_int()[:, 0],
    "ci_hi": mfx.conf_int()[:, 1]
}, index=mfx.margeff_se.index if hasattr(mfx.margeff_se, "index") else None)
```

### Marginal Effects from GLM

`get_margeff()` is available on `GLM` results, but the dedicated `Logit`/`Probit`/`Poisson` classes provide additional post-estimation features (e.g., `pred_table()`, McFadden's pseudo R-squared). Prefer the dedicated classes when available:

```python
# Preferred for marginal effects
results = smf.logit("y ~ x1 + x2", data=df).fit()
mfx = results.get_margeff()
```

For count models:

```python
results = smf.poisson("count ~ x1 + x2", data=df).fit()
mfx = results.get_margeff(at="overall", method="dydx")
print(mfx.summary())
# For Poisson, dydx marginal effect is ∂E[count]/∂x = β * E[count]
```

---

## Exposure and Offset for Rate Models

When modeling event rates (events per unit of exposure), include exposure in the model so coefficients are interpretable as rate ratios.

### `exposure` Parameter

Pass the raw exposure variable. statsmodels takes ln(exposure) internally:

```python
# Poisson rate model: events per person-year
results = smf.poisson("events ~ x1 + x2", data=df,
                       exposure=df["person_years"]).fit()

# Array API
results = sm.Poisson(df["events"], X, exposure=df["person_years"]).fit()
```

### `offset` Parameter

Pass the pre-computed log(exposure) manually:

```python
import numpy as np

df["log_pop"] = np.log(df["population"])
results = smf.poisson("events ~ x1 + x2", data=df,
                       offset=df["log_pop"]).fit()
```

`exposure` and `offset` are equivalent: `offset = log(exposure)`. Use `offset` when your exposure variable is already on the log scale, or when you need a custom offset that is not the log of a simple exposure.

### Interpreting Rate Model Coefficients

```python
# Coefficients represent log(rate ratio) per unit change in x
irr = np.exp(results.params)
print(irr)
# Exclude the constant when interpreting IRRs — it represents the baseline rate
# (at x=0 and offset=0), which may not be meaningful on its own
```

### Negative Binomial Rate Model

```python
# Overdispersed rate model
results = sm.NegativeBinomial(
    df["events"], X, exposure=df["person_years"]
).fit()
```

### Rate Prediction

When predicting with an exposure/offset, include it in the prediction call:

```python
# Predict expected counts (not rates) for new observations
new_X = sm.add_constant(new_df[["x1", "x2"]])
pred_counts = results.predict(new_X, exposure=new_df["person_years"])

# Predicted rates (events per unit exposure)
pred_rates = pred_counts / new_df["person_years"]
```

---

## Ordered Logit and Probit (OrderedModel)

For ordinal outcomes (e.g., Likert scales, education levels, satisfaction ratings):

```python
from statsmodels.miscmodels.ordinal_model import OrderedModel

# Ordered logit (proportional odds model)
results = OrderedModel(y, X, distr='logit').fit(method='bfgs')
print(results.summary())

# Ordered probit
results = OrderedModel(y, X, distr='probit').fit(method='bfgs')
```

- `y` must be an ordered categorical or integer-coded (0, 1, 2, ..., K-1)
- `distr`: `'logit'` (proportional odds) or `'probit'`
- Formula API is also available via `OrderedModel.from_formula("y ~ x1 + x2", data=df, distr='logit')`
- Returns threshold parameters (cutpoints) alongside regression coefficients
- Coefficients represent log-odds (logit) or z-score (probit) change per unit increase in x
- For interpretation, compute predicted probabilities for each category:

```python
pred_probs = results.predict()  # N x K matrix of predicted probabilities
```

- Parallel regression assumption (proportional odds): the effect of each predictor is the same across all thresholds. Violations suggest an alternative like multinomial logit
- `results.pred_table()` for classification accuracy across ordered categories

---

## References and Further Reading

- statsmodels GLM documentation: https://www.statsmodels.org/stable/glm.html
- statsmodels GLM families and links: https://www.statsmodels.org/stable/glm.html#families
- statsmodels discrete choice models: https://www.statsmodels.org/stable/discretemod.html
- statsmodels count model examples: https://www.statsmodels.org/stable/examples/notebooks/generated/count_model.html
- statsmodels marginal effects: https://www.statsmodels.org/stable/margeff.html
- statsmodels zero-inflated models: https://www.statsmodels.org/stable/generated/statsmodels.discrete.count_model.ZeroInflatedPoisson.html
- Cameron, A.C. & Trivedi, P.K. (2013). *Regression Analysis of Count Data*, 2nd ed. Cambridge University Press.
- Long, J.S. & Freese, J. (2014). *Regression Models for Categorical Dependent Variables Using Stata*, 3rd ed. Stata Press.
- Wooldridge, J.M. (2010). *Econometric Analysis of Cross Section and Panel Data*, 2nd ed. MIT Press — Chapters 15-16 (count models, binary and multinomial response).
- Hilbe, J.M. (2011). *Negative Binomial Regression*, 2nd ed. Cambridge University Press.
- McCullagh, P. & Nelder, J.A. (1989). *Generalized Linear Models*, 2nd ed. Chapman & Hall.
