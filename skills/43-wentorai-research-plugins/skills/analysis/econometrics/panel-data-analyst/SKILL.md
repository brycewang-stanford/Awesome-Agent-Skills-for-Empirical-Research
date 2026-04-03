---
name: panel-data-analyst
description: "Expert panel data regression analysis with fixed effects and GMM"
metadata:
  openclaw:
    emoji: "📊"
    category: "analysis"
    subcategory: "econometrics"
    keywords: ["panel data", "fixed effects", "random effects", "GMM", "dynamic panel", "Hausman test"]
    source: "https://www.stata.com/manuals/xt.pdf"
---

# Panel Data Analyst

Perform expert-level panel data regression analysis including fixed effects, random effects, dynamic panel models (Arellano-Bond/Blundell-Bond GMM), and advanced diagnostic tests. This skill covers the full workflow from panel setup through model selection, estimation, and publication-ready reporting.

## Overview

Panel data -- repeated observations on the same cross-sectional units over time -- is the workhorse of modern empirical economics, finance, political science, and management research. Panel methods exploit both cross-sectional and temporal variation, enabling researchers to control for unobserved heterogeneity that would bias ordinary cross-sectional estimates.

The choice between fixed effects, random effects, and dynamic panel estimators depends on the data structure, the nature of unobserved heterogeneity, and the identifying assumptions the researcher is willing to make. This skill provides a systematic decision framework and implementation in both Stata and R, with emphasis on the diagnostic tests that justify model selection.

Beyond basic FE/RE models, this skill covers the advanced techniques increasingly required by journal reviewers: instrumental variables within panel frameworks, Driscoll-Kraay standard errors for cross-sectional dependence, correlated random effects (Mundlak/Chamberlain), and system GMM for dynamic panels with endogenous regressors.

## Panel Data Setup

### Declaring Panel Structure

```stata
* Stata panel setup
xtset firm_id year
xtset  // Verify panel structure

* Check panel balance
xtdescribe
* Shows: min/max/avg observations per panel, gaps

* Summary statistics by panel dimension
xtsum revenue profit employees rnd_spending
* Reports overall, between, and within variation
```

### Panel Diagnostics

```stata
* Check for gaps in panel
xtset firm_id year
gen gap = year - l.year if l.year != .
tab gap  // Should be all 1's for balanced annual panels

* Create balanced subsample
by firm_id: gen T_i = _N
tab T_i
keep if T_i == max_T  // Keep only units observed in all periods

* Attrition analysis
gen in_panel = 1
xtset firm_id year
tsfill, full
replace in_panel = 0 if missing(in_panel)
reg in_panel l.revenue l.profit l.size, cluster(firm_id)
```

## Fixed Effects vs. Random Effects

### Fixed Effects Estimation

```stata
* Within estimator (entity fixed effects)
xtreg profit revenue rnd_spending employees i.year, fe robust
estimates store fe_model

* Entity and time fixed effects
reghdfe profit revenue rnd_spending employees, ///
    absorb(firm_id year) cluster(firm_id)
estimates store twoway_fe

* First-differences (alternative to within estimator)
reg d.profit d.revenue d.rnd_spending d.employees i.year, ///
    cluster(firm_id)
estimates store fd_model
```

### Random Effects Estimation

```stata
* GLS random effects
xtreg profit revenue rnd_spending employees i.year, re robust
estimates store re_model
```

### Hausman Test for Model Selection

```stata
* Classic Hausman test
xtreg profit revenue rnd_spending employees, fe
estimates store fe_haus
xtreg profit revenue rnd_spending employees, re
estimates store re_haus
hausman fe_haus re_haus

* Robust Hausman test (preferred with heteroskedasticity)
* Mundlak (1978) approach: add group means to RE model
foreach var of varlist revenue rnd_spending employees {
    bysort firm_id: egen m_`var' = mean(`var')
}
xtreg profit revenue rnd_spending employees ///
    m_revenue m_rnd_spending m_employees i.year, re cluster(firm_id)
test m_revenue m_rnd_spending m_employees
* Rejection => FE preferred; failure to reject => RE acceptable
```

## Dynamic Panel Models

### Arellano-Bond GMM (Difference GMM)

```stata
* When the lagged dependent variable is a regressor:
* y_it = alpha * y_{i,t-1} + X_it * beta + mu_i + epsilon_it

* Difference GMM (Arellano & Bond 1991)
xtabond profit l.profit revenue rnd_spending employees, ///
    lags(1) twostep robust artests(2)

* Diagnostics
* AR(1) should be significant, AR(2) should NOT be significant
* Hansen J test of overidentifying restrictions (p > 0.10 desired)
```

### System GMM (Blundell-Bond)

```stata
* System GMM (Blundell & Bond 1998)
* More efficient than difference GMM, especially with persistent series

xtabond2 profit l.profit revenue rnd_spending employees i.year, ///
    gmm(l.profit, lag(2 4) collapse) ///
    gmm(revenue rnd_spending, lag(2 3) collapse) ///
    iv(employees i.year) ///
    twostep robust orthogonal small

* Key diagnostics to report:
* 1. Number of instruments (should not exceed number of groups)
* 2. Hansen J test p-value (> 0.10, but < 0.25 preferred -- not too high)
* 3. AR(2) test p-value (> 0.10 for valid instruments)
* 4. Difference-in-Hansen test for subset of instruments
```

### GMM Diagnostic Checklist

| Test | Null Hypothesis | Desired Result | Stata Command |
|------|----------------|----------------|---------------|
| AR(1) | No first-order autocorrelation | Reject (p < 0.05) | Reported automatically |
| AR(2) | No second-order autocorrelation | Fail to reject (p > 0.10) | Reported automatically |
| Hansen J | Instruments are valid | Fail to reject (p > 0.10) | Reported automatically |
| Diff-in-Hansen | Level instruments valid | Fail to reject (p > 0.10) | Reported automatically |
| Instrument count | -- | N_instruments < N_groups | Check output |

## Standard Error Options

### Choosing the Right Standard Errors

```stata
* Entity-clustered (default choice for firm panels)
xtreg profit revenue rnd_spending, fe cluster(firm_id)

* Two-way clustering (firm and year)
reghdfe profit revenue rnd_spending, ///
    absorb(firm_id) cluster(firm_id year)

* Driscoll-Kraay standard errors (cross-sectional dependence)
xtscc profit revenue rnd_spending i.year, fe lag(3)

* Newey-West within panels (autocorrelation + heteroskedasticity)
xtreg profit revenue rnd_spending, fe
xtpcse profit revenue rnd_spending i.firm_id, correlation(ar1)
```

### Diagnostic Tests for Standard Error Selection

```stata
* Test for heteroskedasticity in FE model
xtreg profit revenue rnd_spending, fe
xttest3  // Modified Wald test (rejects => use robust/cluster SE)

* Test for serial correlation
xtserial profit revenue rnd_spending
* Wooldridge test (rejects => use cluster SE or Newey-West)

* Test for cross-sectional dependence
xtreg profit revenue rnd_spending, fe
xtcsd, pesaran abs
* Pesaran CD test (rejects => consider Driscoll-Kraay SE)
```

## Advanced Specifications

### Interaction Effects in Panel Models

```stata
* Continuous x continuous interaction with FE
xtreg profit c.rnd_spending##c.market_share i.year, fe cluster(firm_id)

* Visualize marginal effect
margins, dydx(rnd_spending) at(market_share=(0(0.1)1))
marginsplot, title("Marginal Effect of R&D by Market Share")
```

### Instrumental Variables in Panel Data

```stata
* IV with fixed effects (xtivreg)
xtivreg profit (rnd_spending = tax_credit regulatory_change) ///
    employees size i.year, fe first

* First-stage F-statistic check
* Report Kleibergen-Paap rk Wald F for weak instruments
```

### Correlated Random Effects (Mundlak)

```stata
* Mundlak (1978) approach: include within-group means
foreach var of varlist revenue rnd_spending employees {
    bysort firm_id: egen bar_`var' = mean(`var')
}

xtreg profit revenue rnd_spending employees ///
    bar_revenue bar_rnd_spending bar_employees ///
    i.year, re cluster(firm_id)

* Coefficients on time-varying vars are equivalent to FE estimates
* Coefficients on bar_ vars capture between-unit effects
```

## Publication Tables

```stata
* Comparison table: FE vs RE vs GMM
esttab fe_model re_model gmm_model using "tables/panel_comparison.tex", ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    label title("Panel Regression Results") ///
    mtitles("Fixed Effects" "Random Effects" "System GMM") ///
    stats(N N_g r2_w ar2p hansenp, ///
        labels("Observations" "Firms" "Within R-squared" ///
               "AR(2) p-value" "Hansen p-value") ///
        fmt(0 0 3 3 3)) ///
    addnotes("Clustered standard errors in parentheses." ///
             "All models include year fixed effects.") ///
    replace
```

## References

- Wooldridge, J.M. (2010), Econometric Analysis of Cross Section and Panel Data, 2nd ed., MIT Press
- Arellano & Bond (1991), "Some Tests of Specification for Panel Data," RES 58(2)
- Blundell & Bond (1998), "Initial Conditions and Moment Restrictions in Dynamic Panel Data Models," JoE 87(1)
- Roodman (2009), "How to Do xtabond2: An Introduction to Difference and System GMM in Stata," SJ 9(1)
- Cameron & Trivedi (2005), Microeconometrics: Methods and Applications, Cambridge University Press
