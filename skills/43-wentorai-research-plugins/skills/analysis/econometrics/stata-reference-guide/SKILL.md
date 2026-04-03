---
name: stata-reference-guide
description: "Comprehensive Stata reference covering syntax, econometrics, and 20+ packages"
metadata:
  openclaw:
    emoji: "📊"
    category: "analysis"
    subcategory: "econometrics"
    keywords: ["stata", "econometrics", "panel data", "causal inference", "community packages", "data management", "regression"]
    source: "https://github.com/dylantmoore/stata-skill"
---

# Stata Comprehensive Reference Guide

## Overview

Stata is the dominant statistical software in economics, political science, public health, and sociology research. This guide provides a comprehensive reference covering core syntax, data management, estimation commands, causal inference methods, graphics, Mata programming, and 20+ community-contributed packages. It is designed as a progressive-disclosure reference: use the section relevant to your current task rather than reading end-to-end.

## Core Syntax and Data Management

### Data Import and Export

```stata
* Import CSV with variable names in first row
import delimited "data.csv", clear varnames(1)

* Import Excel (specific sheet and cell range)
import excel "workbook.xlsx", sheet("Sheet1") cellrange(A1:Z1000) firstrow clear

* Import Stata format
use "dataset.dta", clear

* Export to CSV
export delimited "output.csv", replace

* Save as Stata format
save "cleaned_data.dta", replace
```

### Variable Management

```stata
* Generate new variables
gen log_income = ln(income)
gen age_sq = age^2
gen treatment_post = treatment * post

* Recode and label
recode education (1/12 = 1 "HS or less") (13/16 = 2 "College") (17/20 = 3 "Graduate"), gen(edu_cat)
label variable edu_cat "Education Category"

* String operations
gen first_name = word(full_name, 1)
gen year_str = string(year)
destring price_str, gen(price) force

* Date handling
gen date = date(date_str, "YMD")
format date %td
gen year = year(date)
gen quarter = quarter(date)
```

### Data Cleaning Patterns

```stata
* Identify and handle duplicates
duplicates report id year
duplicates tag id year, gen(dup_flag)
duplicates drop id year, force

* Missing values
misstable summarize
misstable patterns
replace income = . if income < 0  // recode impossible values

* Merge datasets
merge 1:1 id year using "panel_data.dta", keep(match master) nogen
merge m:1 state year using "state_controls.dta", keep(match master) nogen

* Reshape between wide and long
reshape long income_, i(id) j(year)
reshape wide income, i(id) j(year)

* Collapse to group level
collapse (mean) avg_income=income (sd) sd_income=income (count) n=income, by(state year)
```

## Estimation Commands

### Linear Regression

```stata
* OLS with robust standard errors
reg y x1 x2 x3, robust

* Clustered standard errors
reg y x1 x2 x3, cluster(firm_id)

* Fixed effects (within estimator)
xtreg y x1 x2 x3, fe cluster(firm_id)
xtset firm_id year  // must declare panel structure first

* Absorbing high-dimensional FE (reghdfe)
reghdfe y x1 x2 x3, absorb(firm_id year) cluster(firm_id)

* Instrumental variables (2SLS)
ivregress 2sls y x1 x2 (endog_var = instrument1 instrument2), robust
estat firststage
estat overid
```

### Panel Data Methods

```stata
* Panel setup
xtset firm_id year

* Hausman test (FE vs RE)
quietly xtreg y x1 x2, fe
estimates store fe
quietly xtreg y x1 x2, re
estimates store re
hausman fe re

* Dynamic panel GMM (xtabond2)
xtabond2 y L.y x1 x2, gmm(L.y, lag(2 4)) iv(x1 x2) robust twostep

* Test for serial correlation and overidentification
estat abond    // Arellano-Bond test
estat sargan   // Sargan/Hansen test
```

### Causal Inference

```stata
* Difference-in-Differences
gen did = treatment * post
reg y did treatment post controls, cluster(state)

* Modern DiD with staggered treatment (csdid)
csdid y x1 x2, ivar(id) time(year) gvar(first_treat) method(dripw)
csdid_plot  // event study plot

* Regression Discontinuity (rdrobust)
rdrobust y running_var, c(0) p(1) kernel(triangular)
rdplot y running_var, c(0) p(1)

* Propensity Score Matching (psmatch2)
psmatch2 treatment x1 x2 x3, outcome(y) logit caliper(0.05) common
pstest x1 x2 x3  // balance check

* Synthetic Control (synth)
synth y x1 x2 x3 y(1990) y(1991) y(1992), trunit(1) trperiod(1993) fig
```

### Limited Dependent Variables

```stata
* Logit/Probit
logit binary_y x1 x2, robust
margins, dydx(*)  // average marginal effects

probit binary_y x1 x2, robust
margins, dydx(*)

* Ordered logit
ologit ordered_y x1 x2, robust
margins, predict(outcome(3)) dydx(x1)

* Tobit (censored regression)
tobit y x1 x2, ll(0)

* Poisson and Negative Binomial
poisson count_y x1 x2, robust
nbreg count_y x1 x2, robust
```

## Community Packages (20+)

### Installation

```stata
* Install from SSC (Statistical Software Components)
ssc install reghdfe
ssc install estout
ssc install coefplot
ssc install csdid
ssc install rdrobust
ssc install psmatch2
ssc install synth
ssc install ivreg2
ssc install xtabond2
ssc install winsor2
ssc install gtools
ssc install ftools
ssc install binscatter
ssc install binsreg
ssc install grstyle

* Install from GitHub
net install did_multiplegt, from("https://raw.githubusercontent.com/chaisemartinDehejia/did_multiplegt/main")
```

### Publication-Quality Output

```stata
* estout / esttab — formatted regression tables
eststo clear
eststo: reg y x1 x2, robust
eststo: reg y x1 x2 x3, robust
eststo: reg y x1 x2 x3, cluster(firm_id)
esttab, se star(* 0.10 ** 0.05 *** 0.01) ///
    title("Main Results") label replace ///
    scalars("r2 R-squared" "N Observations")

* Export to LaTeX
esttab using "table1.tex", replace booktabs ///
    se star(* 0.10 ** 0.05 *** 0.01) label

* Export to CSV/Excel
esttab using "table1.csv", replace se

* coefplot — coefficient visualization
coefplot est1 est2 est3, drop(_cons) xline(0) ///
    title("Coefficient Estimates") legend(order(1 "Model 1" 2 "Model 2" 3 "Model 3"))
```

## Graphics

```stata
* Scatter with fit line
twoway (scatter y x) (lfit y x), title("Y vs X") ///
    xtitle("X Variable") ytitle("Y Variable")

* Event study plot
coefplot, vertical drop(_cons) yline(0) ///
    title("Event Study") xtitle("Periods Relative to Treatment")

* Binned scatter (binscatter)
binscatter y x, controls(z1 z2) nquantiles(20) ///
    title("Binned Scatter") xtitle("X") ytitle("Y")

* Kernel density
kdensity income if year==2020, normal ///
    title("Income Distribution") xtitle("Income")

* Graph styling (grstyle)
grstyle init
grstyle set plain, horizontal grid
grstyle color background white
grstyle set color economist
```

## Mata Programming

```stata
* Basic Mata usage
mata:
    // Matrix operations
    X = st_data(., ("x1", "x2", "x3"))
    y = st_data(., "y")
    n = rows(X)

    // OLS by hand
    X = X, J(n, 1, 1)  // add constant
    beta = invsym(X'X) * X'y
    e = y - X * beta
    sigma2 = (e'e) / (n - cols(X))
    V = sigma2 * invsym(X'X)
    se = sqrt(diagonal(V))

    beta, se
end
```

## Workflow Best Practices

1. **Always set a random seed** before any procedure involving randomness: `set seed 12345`
2. **Use `preserve`/`restore`** for temporary data manipulations within a do-file
3. **Log your sessions**: `log using "analysis_log.smcl", replace`
4. **Version control**: Start do-files with `version 17` (or your version) for reproducibility
5. **Use tempfiles** for intermediate datasets: `tempfile merged` then `save `merged'`
6. **Profile your code** with `timer on 1` / `timer off 1` / `timer list` for long-running operations
7. **Use `gtools`** (greshape, gcollapse, gegen) for 5-10x speedups on large datasets

## References

- [Stata Official Documentation](https://www.stata.com/manuals/)
- [UCLA Stata FAQ](https://stats.oarc.ucla.edu/stata/faq/)
- [Stata Journal](https://www.stata-journal.com/)
- [SSC Archive](https://ideas.repec.org/s/boc/bocode.html)
- [dylantmoore/stata-skill](https://github.com/dylantmoore/stata-skill) — Source for this reference
