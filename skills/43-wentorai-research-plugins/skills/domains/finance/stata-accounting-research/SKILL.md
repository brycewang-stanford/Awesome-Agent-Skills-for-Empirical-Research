---
name: stata-accounting-research
description: "STATA code patterns for empirical accounting and finance research"
metadata:
  openclaw:
    emoji: "📒"
    category: "domains"
    subcategory: "finance"
    keywords: ["STATA", "accounting", "empirical finance", "panel data", "earnings management", "audit"]
    source: "wentor-research-plugins"
---

# STATA Accounting Research Guide

## Overview

Empirical accounting research relies heavily on STATA for data manipulation, statistical analysis, and robustness testing. The field has developed standardized methodological approaches -- earnings quality models, event studies, difference-in-differences for regulatory changes, and instrument variable strategies for endogeneity -- that are implemented in a relatively stable set of STATA patterns.

This guide provides the core STATA code patterns used in top accounting journals (The Accounting Review, Journal of Accounting Research, Journal of Accounting and Economics, and Review of Accounting Studies). These patterns are drawn from commonly used research designs in financial reporting, auditing, tax, and managerial accounting research.

Whether you are estimating discretionary accruals, conducting an event study around an earnings announcement, testing the effect of auditor rotation on audit quality, or implementing a regulatory shock analysis, these patterns provide tested, reviewable STATA implementations.

## Data Preparation

### Loading and Cleaning COMPUSTAT Data

```stata
* ============================================================
* COMPUSTAT Annual Data Preparation for Accounting Research
* Standard preparation used across most empirical accounting papers
* ============================================================

* Load COMPUSTAT annual data
use "compustat_annual.dta", clear

* Keep relevant variables
keep gvkey fyear datadate at sale cogs xsga dp ib oancf act lct che dlc ///
     csho prcc_f ceq re dltt txp xrd ppegt ppent invt rect

* Set panel structure
destring gvkey, replace
xtset gvkey fyear

* --- Basic cleaning ---
* Drop financial firms (SIC 6000-6999) and utilities (SIC 4900-4999)
drop if inrange(sic, 6000, 6999) | inrange(sic, 4900, 4999)

* Require minimum observations
bysort gvkey: gen nobs = _N
drop if nobs < 3
drop nobs

* --- Generate common variables ---
* Total accruals (balance sheet approach)
gen total_accruals = (D.act - D.che) - (D.lct - D.dlc) - dp

* Total accruals (cash flow approach, preferred)
gen total_accruals_cf = ib - oancf

* Scale by lagged total assets
gen lag_at = L.at
gen ta_scaled = total_accruals_cf / lag_at
gen sale_scaled = sale / lag_at
gen ppe_scaled = ppent / lag_at
gen dsale = D.sale / lag_at
gen drec = D.rect / lag_at
gen roa = ib / lag_at

* Market value of equity
gen mve = csho * prcc_f

* Book-to-market ratio
gen btm = ceq / mve

* Leverage
gen leverage = (dlc + dltt) / at

* Firm size
gen size = ln(at)

* --- Winsorize at 1% and 99% ---
foreach var of varlist ta_scaled sale_scaled ppe_scaled roa btm leverage size {
    winsor2 `var', replace cuts(1 99)
}

* Label variables
label var ta_scaled "Total accruals / lagged assets"
label var roa "Return on assets"
label var btm "Book-to-market ratio"
label var leverage "Total debt / total assets"
label var size "Log(total assets)"

save "compustat_clean.dta", replace
```

## Earnings Quality Models

### Modified Jones Model (Dechow et al., 1995)

```stata
* ============================================================
* Modified Jones Model: Estimate discretionary accruals
* Standard model for earnings management research
* ============================================================

use "compustat_clean.dta", clear

* --- Step 1: Estimate non-discretionary accruals by industry-year ---
* Jones (1991) model estimated cross-sectionally

gen inv_lag_at = 1 / lag_at
gen dsale_drec = dsale - drec  // Modified Jones adjustment

* Estimate by 2-digit SIC and year (require >= 15 obs per group)
gen sic2 = floor(sic / 100)

* Cross-sectional estimation
gen da_mj = .
gen nda_mj = .

levelsof fyear, local(years)
foreach y of local years {
    levelsof sic2 if fyear == `y', local(industries)
    foreach ind of local industries {
        * Count observations in this industry-year
        count if sic2 == `ind' & fyear == `y' & !missing(ta_scaled, inv_lag_at, dsale_drec, ppe_scaled)
        if r(N) >= 15 {
            * Estimate Jones model
            quietly reg ta_scaled inv_lag_at dsale_drec ppe_scaled ///
                if sic2 == `ind' & fyear == `y', robust

            * Predict non-discretionary accruals
            quietly predict temp_nda if sic2 == `ind' & fyear == `y', xb
            quietly replace nda_mj = temp_nda if sic2 == `ind' & fyear == `y'
            drop temp_nda
        }
    }
}

* Discretionary accruals = Total accruals - Non-discretionary accruals
replace da_mj = ta_scaled - nda_mj

* Absolute discretionary accruals (common measure of earnings quality)
gen abs_da = abs(da_mj)

label var da_mj "Discretionary accruals (Modified Jones)"
label var abs_da "Absolute discretionary accruals"

save "accruals_data.dta", replace
```

### Performance-Matched Discretionary Accruals (Kothari et al., 2005)

```stata
* ============================================================
* Kothari (2005): Performance-matched discretionary accruals
* Controls for correlation between performance and accruals
* ============================================================

* Add ROA to the Jones model
gen da_kothari = .

levelsof fyear, local(years)
foreach y of local years {
    levelsof sic2 if fyear == `y', local(industries)
    foreach ind of local industries {
        count if sic2 == `ind' & fyear == `y' & !missing(ta_scaled, inv_lag_at, dsale_drec, ppe_scaled, roa)
        if r(N) >= 15 {
            quietly reg ta_scaled inv_lag_at dsale_drec ppe_scaled roa ///
                if sic2 == `ind' & fyear == `y', robust
            quietly predict temp_res if sic2 == `ind' & fyear == `y', residuals
            quietly replace da_kothari = temp_res if sic2 == `ind' & fyear == `y'
            drop temp_res
        }
    }
}

gen abs_da_kothari = abs(da_kothari)
label var da_kothari "Discretionary accruals (Kothari)"
label var abs_da_kothari "Absolute DA (Kothari)"
```

## Event Study

```stata
* ============================================================
* Short-window event study around earnings announcements
* Standard methodology for capital markets research
* ============================================================

use "crsp_daily_returns.dta", clear

* Merge with event dates
merge m:1 gvkey fyear using "earnings_dates.dta", keep(match) nogen

* --- Estimation window: [-250, -30] relative to announcement ---
gen event_day = date - rdq  // rdq = report date of quarterly earnings
keep if inrange(event_day, -250, 10)

* Estimate market model in estimation window
gen est_window = inrange(event_day, -250, -30)
gen event_window = inrange(event_day, -1, 1)  // 3-day window [-1, +1]

* Market model: R_i = alpha + beta * R_m + epsilon
bysort permno fyear: egen has_enough = total(est_window)
keep if has_enough >= 100  // Require 100+ days in estimation window

* Estimate market model parameters
gen alpha = .
gen beta_mkt = .

levelsof permno, local(firms)
foreach p of local firms {
    capture quietly reg ret mktrf if permno == `p' & est_window == 1
    if _rc == 0 {
        quietly replace alpha = _b[_cons] if permno == `p'
        quietly replace beta_mkt = _b[mktrf] if permno == `p'
    }
}

* Abnormal returns
gen ar = ret - (alpha + beta_mkt * mktrf)

* Cumulative abnormal returns [-1, +1]
bysort permno fyear (event_day): egen car_3day = total(ar) if event_window == 1

* Cross-sectional test
preserve
    keep if event_day == 0
    * t-test: Is average CAR different from zero?
    ttest car_3day == 0
    * Regression with controls
    reg car_3day surprise size btm, robust
restore
```

## Regression Specifications

### Standard Panel Regression with Fixed Effects

```stata
* ============================================================
* Standard regression specification for accounting research
* Includes firm and year fixed effects, clustered standard errors
* ============================================================

use "merged_analysis_data.dta", clear

* --- Main specification ---
* DV: Absolute discretionary accruals (earnings quality)
* Key IV: Big 4 auditor indicator

* Model 1: Pooled OLS (baseline, for comparison only)
reg abs_da big4 size leverage btm roa loss, robust
estimates store m1

* Model 2: Year fixed effects
reg abs_da big4 size leverage btm roa loss i.fyear, robust
estimates store m2

* Model 3: Industry + Year fixed effects
reg abs_da big4 size leverage btm roa loss i.sic2 i.fyear, robust
estimates store m3

* Model 4: Firm + Year fixed effects (preferred specification)
reghdfe abs_da big4 size leverage btm roa loss, absorb(gvkey fyear) ///
    cluster(gvkey)
estimates store m4

* Model 5: Firm + Year FE, two-way clustering (firm and year)
reghdfe abs_da big4 size leverage btm roa loss, absorb(gvkey fyear) ///
    cluster(gvkey fyear)
estimates store m5

* --- Output table ---
esttab m1 m2 m3 m4 m5 using "table_main.tex", replace ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    b(%9.4f) se(%9.4f) ///
    stats(N r2 r2_a, fmt(%9.0g %9.4f %9.4f) ///
        labels("Observations" "R-squared" "Adj. R-squared")) ///
    title("Effect of Auditor Type on Earnings Quality") ///
    label booktabs
```

## Robustness Tests

### Propensity Score Matching

```stata
* ============================================================
* Propensity Score Matching (PSM) for endogeneity concerns
* Used when treatment assignment (e.g., Big 4 auditor) is not random
* ============================================================

* Step 1: Estimate propensity score
logit big4 size leverage btm roa loss age_firm, robust
predict pscore, pr

* Step 2: Common support check
gen cs = pscore >= 0.1 & pscore <= 0.9  // Trim extreme propensity scores

* Step 3: Nearest-neighbor matching (1:1, without replacement)
psmatch2 big4 size leverage btm roa loss if cs == 1, ///
    outcome(abs_da) neighbor(1) caliper(0.01) common

* Check covariate balance after matching
pstest size leverage btm roa loss, both

* Step 4: Re-estimate on matched sample
gen matched = _weight != .
reg abs_da big4 size leverage btm roa loss if matched == 1, robust
```

### Heckman Selection Model

```stata
* ============================================================
* Heckman two-stage model for sample selection bias
* Example: Analyst coverage → Earnings quality
* ============================================================

* First stage: Selection equation (what determines analyst coverage?)
probit analyst_covered size btm roa institutional_ownership sp500 ///
    exchange_listed, robust

* Second stage: Outcome equation with inverse Mills ratio
heckman abs_da analyst_covered size leverage btm roa, ///
    select(analyst_covered = size btm roa institutional_ownership ///
           sp500 exchange_listed) ///
    twostep
```

## Publication-Ready Output

```stata
* ============================================================
* Generating publication-ready tables and statistics
* ============================================================

* Summary statistics table
estpost summarize abs_da big4 size leverage btm roa loss, detail
esttab using "table_sumstats.tex", replace ///
    cells("count mean sd p25 p50 p75") ///
    label booktabs title("Summary Statistics")

* Correlation matrix
pwcorr abs_da big4 size leverage btm roa, star(0.05) sig
estpost correlate abs_da big4 size leverage btm roa, matrix listwise
esttab using "table_corr.tex", replace unstack not noobs ///
    label booktabs title("Correlation Matrix")

* Univariate comparison (treatment vs. control)
ttest abs_da, by(big4) unequal
ranksum abs_da, by(big4)
```

## Best Practices

- **Always cluster standard errors** by firm (at minimum) in panel data. Two-way clustering by firm and year is increasingly required by reviewers.
- **Use `reghdfe`** for high-dimensional fixed effects. It is faster and more memory-efficient than `areg` or `xtreg, fe`.
- **Report economic magnitude.** A one-standard-deviation change in X produces a Y% change in the dependent variable.
- **Include all robustness tests** that reviewers expect: PSM, Heckman, placebo tests, entropy balancing, and alternative variable definitions.
- **Winsorize at 1% and 99%** as a default; report results at 5%/95% as a robustness check.
- **Use `eststo` and `esttab`** for consistent, automated table generation. Never hand-type regression results.

## References

- Dechow, P. M., Sloan, R. G., & Sweeney, A. P. (1995). Detecting Earnings Management. The Accounting Review, 70(2), 193-225.
- Kothari, S. P., Leone, A. J., & Wasley, C. E. (2005). Performance Matched Discretionary Accrual Measures. Journal of Accounting and Economics, 39(1), 163-197.
- [WRDS (Wharton Research Data Services)](https://wrds-www.wharton.upenn.edu/) -- Standard data platform for accounting/finance research
- [reghdfe documentation](https://github.com/sergiocorreia/reghdfe) -- Fast fixed-effects estimation in STATA
- Gow, I. D., Ormazabal, G., & Taylor, D. J. (2010). Correcting for Cross-Sectional and Time-Series Dependence in Accounting Research. The Accounting Review, 85(2), 483-512.
