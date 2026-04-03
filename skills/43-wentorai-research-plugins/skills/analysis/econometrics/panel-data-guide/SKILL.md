---
name: panel-data-guide
description: "Panel data analysis with fixed and random effects models"
metadata:
  openclaw:
    emoji: "📋"
    category: "analysis"
    subcategory: "econometrics"
    keywords: ["panel data", "fixed effects", "random effects", "Stata commands"]
    source: "wentor-research-plugins"
---

# Panel Data Analysis Guide

Estimate and interpret fixed effects, random effects, and dynamic panel models using Stata, R, and Python for longitudinal/panel datasets.

## What Is Panel Data?

Panel data (also called longitudinal or cross-sectional time-series data) tracks the same units (individuals, firms, countries) across multiple time periods. This structure enables:

- Controlling for unobserved heterogeneity (time-invariant omitted variables)
- Studying dynamic relationships (how X at time t affects Y at time t+1)
- Increased statistical power through more observations

### Data Structure

```
| unit_id | year | gdp_growth | investment | trade_openness |
|---------|------|-----------|------------|----------------|
| USA     | 2015 | 2.9       | 20.5       | 28.3           |
| USA     | 2016 | 1.7       | 20.1       | 27.1           |
| USA     | 2017 | 2.3       | 20.8       | 27.5           |
| CHN     | 2015 | 6.9       | 43.3       | 39.9           |
| CHN     | 2016 | 6.7       | 42.7       | 37.2           |
| CHN     | 2017 | 6.9       | 43.1       | 38.1           |
```

Key notation:
- i = unit (cross-sectional dimension): i = 1, ..., N
- t = time period: t = 1, ..., T
- Y_it = dependent variable for unit i at time t

## Model Specification

### Pooled OLS

```
Y_it = alpha + beta * X_it + epsilon_it
```

Ignores panel structure; assumes no unit-specific effects. Rarely appropriate.

### Fixed Effects (FE) Model

```
Y_it = alpha_i + beta * X_it + epsilon_it
```

Each unit has its own intercept (alpha_i) that captures all time-invariant unobserved heterogeneity. The "within" estimator removes alpha_i by demeaning.

### Random Effects (RE) Model

```
Y_it = alpha + beta * X_it + u_i + epsilon_it
```

The unit-specific effect u_i is treated as random and uncorrelated with X_it.

## Estimation in Stata

### Setting Up Panel Data

```stata
* Declare panel structure
xtset country_id year

* Summarize within and between variation
xtsum gdp_growth investment trade_openness
```

### Fixed Effects

```stata
* Fixed effects regression
xtreg gdp_growth investment trade_openness, fe

* Store results for Hausman test
estimates store FE

* Fixed effects with robust standard errors (clustered by unit)
xtreg gdp_growth investment trade_openness, fe vce(cluster country_id)

* Test joint significance of fixed effects
testparm i.country_id
```

### Random Effects

```stata
* Random effects regression
xtreg gdp_growth investment trade_openness, re

* Store results for Hausman test
estimates store RE
```

### Hausman Test (FE vs. RE)

```stata
* Hausman specification test
hausman FE RE

* If p < 0.05: reject RE, use FE
* If p > 0.05: RE is consistent and efficient, prefer RE
```

### First Differences

```stata
* First-differenced regression (alternative to FE)
reg D.gdp_growth D.investment D.trade_openness, vce(cluster country_id)
```

## Estimation in R (plm Package)

```r
library(plm)

# Convert to panel data frame
pdata <- pdata.frame(mydata, index = c("country_id", "year"))

# Fixed effects
fe_model <- plm(gdp_growth ~ investment + trade_openness,
                data = pdata, model = "within")
summary(fe_model)

# Random effects
re_model <- plm(gdp_growth ~ investment + trade_openness,
                data = pdata, model = "random")
summary(re_model)

# Hausman test
phtest(fe_model, re_model)

# Clustered standard errors
library(lmtest)
library(sandwich)
coeftest(fe_model, vcov = vcovHC(fe_model, type = "HC1", cluster = "group"))

# Time fixed effects
fe_twoway <- plm(gdp_growth ~ investment + trade_openness + factor(year),
                 data = pdata, model = "within")

# Test for time fixed effects
pFtest(fe_twoway, fe_model)
```

## Estimation in Python (linearmodels)

```python
import pandas as pd
from linearmodels.panel import PanelOLS, RandomEffects, compare

# Set multi-index for panel structure
data = data.set_index(["country_id", "year"])

# Fixed effects
fe = PanelOLS.from_formula(
    "gdp_growth ~ investment + trade_openness + EntityEffects",
    data=data
)
fe_result = fe.fit(cov_type="clustered", cluster_entity=True)
print(fe_result.summary)

# Random effects
re = RandomEffects.from_formula(
    "gdp_growth ~ investment + trade_openness + 1",
    data=data
)
re_result = re.fit()
print(re_result.summary)

# Two-way fixed effects (entity + time)
twoway = PanelOLS.from_formula(
    "gdp_growth ~ investment + trade_openness + EntityEffects + TimeEffects",
    data=data
)
twoway_result = twoway.fit(cov_type="clustered", cluster_entity=True)
print(twoway_result.summary)

# Compare models
print(compare({"FE": fe_result, "RE": re_result, "Two-way FE": twoway_result}))
```

## Diagnostic Tests

### Testing for Panel Effects

| Test | Stata | R | Null Hypothesis |
|------|-------|---|----------------|
| F-test for FE | Built into `xtreg, fe` | `pFtest()` | All alpha_i = 0 (pooled OLS is appropriate) |
| Breusch-Pagan LM | `xttest0` | `plmtest()` | Var(u_i) = 0 (pooled OLS vs. RE) |
| Hausman | `hausman FE RE` | `phtest()` | RE is consistent (u_i uncorrelated with X) |

### Testing for Serial Correlation

```stata
* Wooldridge test for serial correlation in panel data
xtserial gdp_growth investment trade_openness
* If p < 0.05: serial correlation present; use clustered SE or AR(1) correction
```

```r
# Wooldridge test
pbgtest(fe_model)  # Breusch-Godfrey test for serial correlation
```

### Testing for Heteroskedasticity

```stata
* Modified Wald test for groupwise heteroskedasticity
xttest3
* If p < 0.05: heteroskedasticity present; use robust/clustered SE
```

## Advanced Panel Models

### Dynamic Panel (Arellano-Bond GMM)

When a lagged dependent variable is included as a regressor:

```stata
* Arellano-Bond one-step GMM
xtabond gdp_growth investment trade_openness, lags(1) vce(robust)

* System GMM (Blundell-Bond) - more efficient
xtdpdsys gdp_growth investment trade_openness, lags(1) vce(robust)

* Sargan/Hansen test for overidentifying restrictions
* AR(2) test for second-order serial correlation
```

### Difference-in-Differences (DID)

```stata
* Basic DID with two-way fixed effects
xtreg outcome treated##post, fe vce(cluster unit_id)

* Event study specification
xtreg outcome i.relative_time##treated, fe vce(cluster unit_id)
```

## Reporting Results

```
Table X: Panel Regression Results (Fixed Effects)
Dependent Variable: GDP Growth (%)

                      (1)         (2)         (3)
                      FE          RE          Two-way FE
Investment           0.125***    0.118***    0.131***
                    (0.032)     (0.029)     (0.035)
Trade Openness       0.045**     0.051**     0.038*
                    (0.018)     (0.017)     (0.020)

Entity FE             Yes         No         Yes
Time FE               No          No         Yes
Observations          850         850        850
R-squared (within)   0.234       0.228      0.267
Hausman test (p)       --        0.003        --

Notes: Robust standard errors clustered at the country level in
parentheses. * p<0.10, ** p<0.05, *** p<0.01.
```
