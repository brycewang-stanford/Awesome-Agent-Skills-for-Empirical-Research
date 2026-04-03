# Method Patterns — Full Code Templates

Detailed code templates extracted from 58 Python scripts, ~56 R scripts, and ~60 Stata .do files in the Mixtape repository.

---

## §1 OLS / Regression

### Python

```python
import pandas as pd
import statsmodels.formula.api as smf

# Basic OLS with robust SE
model = smf.ols('outcome ~ treatment + control1 + control2', data=df)
results = model.fit(cov_type='HC1')
print(results.summary())

# WLS (weighted least squares)
model = smf.wls('outcome ~ treatment', data=df, weights=df['weight'])
results = model.fit()
```

### R

```r
library(estimatr)

# OLS with robust SE (HC1)
model <- lm_robust(outcome ~ treatment + control1 + control2, data = df, se_type = "HC1")
summary(model)

# Clustered SE
model <- lm_robust(outcome ~ treatment, data = df, clusters = firm_id, se_type = "stata")
```

### Stata

```stata
* Basic OLS with robust SE
reg outcome treatment control1 control2, robust

* Cluster SE
reg outcome treatment control1 control2, cluster(firm_id)

* High-dimensional FE
reghdfe outcome treatment control1, absorb(firm_id year) cluster(firm_id)
```

---

## §2 Difference-in-Differences

### Python

```python
import statsmodels.formula.api as smf

# Standard 2x2 DiD
model = smf.ols('y ~ C(treated)*C(post)', data=df)
results = model.fit(cov_type='cluster', cov_kwds={'groups': df['state']})

# The DiD coefficient is the interaction term: C(treated)[T.1]:C(post)[T.1]
did_coef = results.params['C(treated)[T.1]:C(post)[T.1]']
print(f"DiD estimate: {did_coef:.4f} (SE: {results.bse['C(treated)[T.1]:C(post)[T.1]']:.4f})")

# With controls and entity + time FE
model = smf.ols('y ~ C(treated)*C(post) + control1 + C(entity_id) + C(year)', data=df)
results = model.fit(cov_type='cluster', cov_kwds={'groups': df['state']})
```

### R

```r
library(lfe)

# DiD with two-way FE
model <- felm(y ~ treated:post + controls | entity_id + year | 0 | state, data = df)
summary(model)

# Alternative with fixest
library(fixest)
model <- feols(y ~ treated:post + controls | entity_id + year, data = df, cluster = ~state)
```

### Stata

```stata
* Standard DiD
reg y treated##post, cluster(state)

* With two-way FE
reghdfe y treated_post controls, absorb(entity_id year) cluster(state)

* Triple difference
reghdfe y treated##post##group controls, absorb(entity_id year) cluster(state)
```

---

## §3 Event Study (Dynamic DiD)

### Python

```python
import numpy as np
import statsmodels.formula.api as smf
import matplotlib.pyplot as plt

# Create relative time variable
df['rel_time'] = df['year'] - df['treatment_year']

# Create dummies (drop t=-1 as reference)
leads_lags = list(range(-4, 0)) + list(range(0, 5))  # exclude -1
for k in leads_lags:
    if k < 0:
        df[f'lead{abs(k)}'] = (df['rel_time'] == k).astype(int)
    else:
        df[f'lag{k}'] = (df['rel_time'] == k).astype(int)

# Regression
vars_str = ' + '.join([f'lead{abs(k)}' for k in range(-4, 0)] + [f'lag{k}' for k in range(0, 5)])
formula = f'y ~ {vars_str} + C(entity_id) + C(year)'
model = smf.ols(formula, data=df)
results = model.fit(cov_type='cluster', cov_kwds={'groups': df['state']})

# Plot coefficients
coefs = []
ses = []
periods = list(range(-4, 0)) + [0] + list(range(0, 5))
# Insert 0 for reference period t=-1
# ... extract from results.params and results.bse

fig, ax = plt.subplots(figsize=(10, 6))
ax.errorbar(periods, coefs, yerr=[1.96*s for s in ses], fmt='o-', capsize=3)
ax.axhline(y=0, color='red', linestyle='--')
ax.axvline(x=-0.5, color='grey', linestyle='--', alpha=0.5)
ax.set_xlabel('Periods Relative to Treatment')
ax.set_ylabel('Coefficient Estimate')
ax.set_title('Event Study Plot')
plt.tight_layout()
```

### R

```r
library(fixest)

# Sun & Abraham (2021) interaction-weighted estimator
model <- feols(y ~ sunab(treatment_year, year) | entity_id + year, data = df, cluster = ~state)
iplot(model, main = "Event Study")
```

### Stata

```stata
* Event study with reghdfe
reghdfe y lead4 lead3 lead2 lag0 lag1 lag2 lag3 lag4, ///
    absorb(entity_id year) cluster(state)

* Plot
coefplot, keep(lead* lag*) vertical yline(0) xline(4.5, lpattern(dash))
```

---

## §4 Staggered DiD / TWFE Issues

### Bacon Decomposition (R)

```r
library(bacondecomp)

# Goodman-Bacon (2021) decomposition
bacon_out <- bacon(y ~ treatment, data = df, id_var = "entity_id", time_var = "year")
print(bacon_out)

# Weighted sum = TWFE estimate
# Shows which 2x2 comparisons drive the estimate
# Flags problematic "already-treated vs later-treated" comparisons
```

### Bacon Decomposition (Stata)

```stata
* Install: ssc install bacondecomp
bacondecomp y treatment, ddetail
```

### Callaway & Sant'Anna (R)

```r
library(did)

# Group-time ATT
att_gt <- att_gt(yname = "y", tname = "year", idname = "entity_id",
                 gname = "treatment_year", data = df)
summary(att_gt)
ggdid(att_gt)

# Aggregate to overall ATT
agg <- aggte(att_gt, type = "dynamic")
ggdid(agg)
```

---

## §5 Regression Discontinuity Design

### Python (Sharp RDD)

```python
import statsmodels.formula.api as smf
import numpy as np

# Center running variable at cutoff
df['x_centered'] = df['running_var'] - cutoff
df['treated'] = (df['running_var'] >= cutoff).astype(int)

# Local linear regression (bandwidth h)
h = 10  # IK optimal or manually set
subset = df[abs(df['x_centered']) <= h].copy()

# Polynomial interaction
model = smf.ols('y ~ treated * x_centered', data=subset)
results = model.fit(cov_type='HC1')
rdd_effect = results.params['treated']

# Bandwidth robustness: repeat with h/2, 2h
for bw in [h/2, h, 2*h]:
    sub = df[abs(df['x_centered']) <= bw]
    m = smf.ols('y ~ treated * x_centered', data=sub).fit(cov_type='HC1')
    print(f"BW={bw:.1f}: effect={m.params['treated']:.3f} (SE={m.bse['treated']:.3f})")
```

### R

```r
library(rdrobust)

# Automatic bandwidth selection + local polynomial
rd_result <- rdrobust(y = df$y, x = df$running_var, c = cutoff)
summary(rd_result)

# Plot
rdplot(y = df$y, x = df$running_var, c = cutoff,
       title = "RD Plot", x.label = "Running Variable", y.label = "Outcome")
```

### Stata

```stata
* RD plot
rdplot y running_var, c(cutoff) graph_options(title("RD Plot"))

* RD estimate with rdrobust
rdrobust y running_var, c(cutoff) kernel(triangular) bwselect(mserd)
```

### McCrary Density Test (R)

```r
library(rdd)
DCdensity(df$running_var, cutpoint = cutoff, plot = TRUE)
```

---

## §6 Instrumental Variables / 2SLS

### Python

```python
from linearmodels.iv import IV2SLS

# 2SLS estimation
# Formula: dependent ~ exogenous + [endogenous ~ instruments]
model = IV2SLS.from_formula(
    'y ~ 1 + control1 + control2 + [endog_var ~ instrument1 + instrument2]',
    data=df
)
results = model.fit(cov_type='clustered', clusters=df['cluster_var'])
print(results.summary)

# First-stage F-statistic
print(f"First-stage F: {results.first_stage.diagnostics['f.stat']:.1f}")

# Manual first stage for inspection
first_stage = smf.ols('endog_var ~ instrument1 + instrument2 + control1 + control2', data=df)
fs_results = first_stage.fit(cov_type='HC1')
```

### R

```r
library(AER)

# 2SLS
model <- ivreg(y ~ control1 + control2 + endog_var | control1 + control2 + instrument1 + instrument2,
               data = df)
summary(model, diagnostics = TRUE)  # Includes weak instrument test, Wu-Hausman, Sargan
```

### Stata

```stata
* 2SLS
ivregress 2sls y control1 control2 (endog_var = instrument1 instrument2), first robust

* Post-estimation diagnostics
estat firststage    /* First-stage F */
estat overid        /* Sargan-Hansen test */
estat endogenous    /* Wu-Hausman */
```

---

## §7 Synthetic Control

### Python (via rpy2)

```python
import rpy2.robjects as ro
from rpy2.robjects import pandas2ri
pandas2ri.activate()

# Transfer data to R
ro.globalenv['df'] = df

# Run Synth in R
ro.r('''
library(Synth)
dataprep.out <- dataprep(
    foo = df,
    predictors = c("predictor1", "predictor2"),
    predictors.op = "mean",
    dependent = "outcome",
    unit.variable = "unit_id",
    time.variable = "year",
    treatment.identifier = treated_unit,
    controls.identifier = control_units,
    time.predictors.prior = pre_period,
    time.optimize.ssr = pre_period,
    time.plot = full_period
)
synth.out <- synth(dataprep.out)
synth.tables <- synth.tab(dataprep.res = dataprep.out, synth.res = synth.out)
''')
```

### R (Native)

```r
library(Synth)

dataprep.out <- dataprep(
    foo = df,
    predictors = c("gdp", "trade", "infrate"),
    predictors.op = "mean",
    dependent = "outcome",
    unit.variable = "unit_id",
    time.variable = "year",
    treatment.identifier = 1,
    controls.identifier = c(2:10),
    time.predictors.prior = 1980:1990,
    time.optimize.ssr = 1980:1990,
    time.plot = 1980:2000
)

synth.out <- synth(dataprep.out)
path.plot(synth.res = synth.out, dataprep.res = dataprep.out)
gaps.plot(synth.res = synth.out, dataprep.res = dataprep.out)

# Placebo tests (permutation)
library(SCtools)
placebo <- generate.placebos(dataprep.out, synth.out, Sigf.ipop = 5)
plot_placebos(placebo)
mspe.plot(placebo, discard.extreme = TRUE, mspe.limit = 20)
```

### Stata

```stata
* Synthetic control
synth outcome predictor1 predictor2 outcome(1980) outcome(1985), ///
    trunit(1) trperiod(1990) figure
```

---

## §8 Matching / PSM / IPW / CEM

### Python (Propensity Score + IPW)

```python
import statsmodels.formula.api as smf
import numpy as np

# Step 1: Estimate propensity score
logit = smf.logit('treated ~ x1 + x2 + x3', data=df).fit()
df['pscore'] = logit.predict()

# Step 2: IPW weights
df['ipw'] = np.where(
    df['treated'] == 1,
    1 / df['pscore'],
    1 / (1 - df['pscore'])
)

# Step 3: Weighted regression (ATE)
model = smf.wls('y ~ treated', data=df, weights=df['ipw'])
results = model.fit(cov_type='HC1')

# Trimming extreme weights
df_trimmed = df[(df['pscore'] > 0.1) & (df['pscore'] < 0.9)]
```

### R (MatchIt)

```r
library(MatchIt)
library(Zelig)

# Nearest neighbor matching
m.out <- matchit(treated ~ x1 + x2 + x3, data = df, method = "nearest", ratio = 1)
summary(m.out)
plot(m.out, type = "jitter")

# Estimate treatment effect on matched data
m.data <- match.data(m.out)
model <- lm(y ~ treated + x1 + x2 + x3, data = m.data, weights = weights)
```

### R (IPW)

```r
library(ipw)

# IPW weights
temp <- ipwpoint(
    exposure = treated,
    family = "binomial",
    link = "logit",
    numerator = ~ 1,
    denominator = ~ x1 + x2 + x3,
    data = df
)
df$ipw <- temp$ipw.weights

# Weighted model
library(survey)
design <- svydesign(ids = ~1, weights = ~ipw, data = df)
model <- svyglm(y ~ treated, design = design)
```

### Stata (CEM + teffects)

```stata
* Coarsened Exact Matching
cem x1 (#5) x2 (#3) x3, treatment(treated)
reg y treated [iweight = cem_weights]

* Propensity Score Matching via teffects
teffects psmatch (y) (treated x1 x2 x3), atet

* IPW
teffects ipw (y) (treated x1 x2 x3), atet
```

---

## §9 DAGs and Collider Bias

### Conceptual Framework

```python
# DAGs are primarily conceptual tools
# Use dagitty.net for interactive DAG drawing

# Key rules from Mixtape:
# 1. Condition on confounders (common causes of treatment and outcome)
# 2. Never condition on colliders (common effects of treatment and outcome)
# 3. Never condition on mediators (if estimating total effect)
# 4. Backdoor criterion: block all backdoor paths from treatment to outcome
```

### R (ggdag)

```r
library(ggdag)
library(dagitty)

# Define DAG
dag <- dagitty('dag {
    X -> Y
    Z -> X
    Z -> Y
    M -> X
    M -> Y
}')

# Identify adjustment sets
adjustmentSets(dag, exposure = "X", outcome = "Y")

# Plot
ggdag(dag) + theme_dag()
```

---

## §10 Randomization Inference

### Python

```python
import numpy as np

def permutation_test(treatment, outcome, n_permutations=1000):
    """Sharp null hypothesis test via randomization inference."""
    observed_diff = outcome[treatment == 1].mean() - outcome[treatment == 0].mean()

    null_diffs = []
    for _ in range(n_permutations):
        perm_treatment = np.random.permutation(treatment)
        diff = outcome[perm_treatment == 1].mean() - outcome[perm_treatment == 0].mean()
        null_diffs.append(diff)

    p_value = np.mean(np.abs(null_diffs) >= np.abs(observed_diff))
    return observed_diff, p_value

obs_diff, p_val = permutation_test(df['treated'].values, df['y'].values)
print(f"Observed difference: {obs_diff:.4f}, RI p-value: {p_val:.4f}")
```

### R

```r
library(ri2)

# Declare randomization procedure
declaration <- declare_ra(N = nrow(df), m = sum(df$treated))

# Conduct randomization inference
ri_out <- conduct_ri(
    y ~ treated,
    declaration = declaration,
    sharp_hypothesis = 0,
    data = df
)
summary(ri_out)
plot(ri_out)
```

### Stata

```stata
* Randomization inference
ritest treated _b[treated], reps(1000): reg y treated
```
