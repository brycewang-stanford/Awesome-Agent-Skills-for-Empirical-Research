---
name: stata-accounting-guide
description: "STATA code for empirical accounting and financial economics research"
metadata:
  openclaw:
    emoji: "📒"
    category: "analysis"
    subcategory: "econometrics"
    keywords: ["Stata", "accounting research", "Compustat", "CRSP", "earnings management", "financial economics"]
    source: "https://www.stata.com"
---

# Stata Accounting Research Guide

Generate publication-ready Stata code for empirical accounting research. This skill covers the standard econometric models, variable constructions, and estimation procedures used in top accounting journals (TAR, JAR, JAE, RAS, CAR).

## Overview

Empirical accounting research has developed a distinctive set of analytical conventions that differ from general econometrics. Researchers work with financial statement data from databases like Compustat and CRSP, construct standardized proxies for earnings quality, accruals, and discretionary behavior, and employ estimation techniques that address the particular endogeneity concerns in archival accounting studies.

This skill provides the Stata implementation for the most commonly used models in accounting research: accrual models (Jones, Modified Jones, performance-matched), earnings management detection, value relevance studies, audit quality analyses, and corporate governance research. Each model includes the variable construction from raw Compustat items, the estimation procedure, and the table formatting expected by accounting journal reviewers.

The code follows the conventions established in influential methodological papers by Dechow, Sloan, and Sweeney (1995), Kothari, Leone, and Wasley (2005), and Ecker, Francis, Kim, Olsson, and Schipper (2006), ensuring alignment with reviewer expectations at major accounting journals.

## Data Preparation from Compustat

### Variable Construction

```stata
* ============================================
* Standard Compustat Variable Construction
* ============================================

* Load Compustat annual data
use "raw/compustat_annual.dta", clear

* Fiscal year identifier
gen fyear = year(datadate)

* Key financial variables (Compustat mnemonics)
* Total accruals (balance sheet approach)
gen total_accruals_bs = (dch_act - dch_che) - (dch_lct - dch_dlc - dch_txp) - dp
replace total_accruals_bs = total_accruals_bs / l.at  // Scale by lagged assets

* Total accruals (cash flow approach, preferred)
gen total_accruals_cf = (ib - oancf) / l.at

* Key ratios
gen roa = ib / l.at                           // Return on assets
gen leverage = (dltt + dlc) / at              // Financial leverage
gen size = ln(at)                              // Firm size (log assets)
gen mb = (prcc_f * csho) / ceq               // Market-to-book
gen sales_growth = (sale - l.sale) / l.sale   // Revenue growth
gen cfo = oancf / l.at                        // Cash flow from operations
gen loss = (ib < 0)                           // Loss indicator

* Industry classification (Fama-French 48)
merge m:1 sic using "reference/ff48_sic.dta", nogen keep(master match)
```

### Sample Selection and Filters

```stata
* Standard sample restrictions
drop if at <= 0                    // Positive assets
drop if sale < 0                   // Non-negative sales
drop if missing(ib, at, sale)      // Key variables non-missing
drop if inlist(sic, 6000, 6999)    // Exclude financials (SIC 6000-6999)
drop if inlist(sic, 4900, 4999)    // Exclude utilities (SIC 4900-4999)

* Require minimum observations per industry-year
bysort ff48 fyear: gen n_iy = _N
drop if n_iy < 20

* Winsorize continuous variables at 1st/99th percentile
foreach var of varlist roa leverage mb sales_growth cfo total_accruals_cf {
    winsor2 `var', cuts(1 99) replace
}
```

## Accrual Models

### Modified Jones Model (Dechow, Sloan, Sweeney 1995)

```stata
* ============================================
* Modified Jones Model - Industry-Year Estimation
* ============================================

* Construct regressors
gen inv_at = 1 / l.at
gen d_rev_rec = ((sale - l.sale) - (rect - l.rect)) / l.at
gen ppe_scaled = ppegt / l.at

* Estimate by industry-year cross-sections
gen da_mj = .
levelsof ff48, local(industries)
levelsof fyear, local(years)

foreach ind of local industries {
    foreach yr of local years {
        capture {
            reg total_accruals_cf inv_at d_rev_rec ppe_scaled ///
                if ff48 == `ind' & fyear == `yr', robust
            predict resid if e(sample), resid
            replace da_mj = resid if ff48 == `ind' & fyear == `yr' & !missing(resid)
            drop resid
        }
    }
}

label variable da_mj "Discretionary accruals (Modified Jones)"
```

### Performance-Matched Model (Kothari et al. 2005)

```stata
* Add ROA as control for performance matching
gen da_kothari = .

foreach ind of local industries {
    foreach yr of local years {
        capture {
            reg total_accruals_cf inv_at d_rev_rec ppe_scaled roa ///
                if ff48 == `ind' & fyear == `yr', robust
            predict resid if e(sample), resid
            replace da_kothari = resid if ff48 == `ind' & fyear == `yr' & !missing(resid)
            drop resid
        }
    }
}

label variable da_kothari "Discretionary accruals (Kothari)"

* Alternative: performance matching by ROA decile
xtile roa_decile = roa, nq(10)
bysort ff48 fyear roa_decile: egen da_pm = mean(da_mj)
gen da_performance_matched = da_mj - da_pm
```

## Earnings Management Detection

### Earnings Management Around Thresholds

```stata
* ============================================
* Earnings Distribution Discontinuity Test
* ============================================

* Scaled earnings (earnings per share / price)
gen earn_scaled = ib / (prcc_f * csho)

* Histogram around zero
twoway (histogram earn_scaled if inrange(earn_scaled, -0.10, 0.10), ///
    width(0.005) color(navy%50)), ///
    xline(0, lcolor(red)) ///
    title("Distribution of Scaled Earnings Around Zero") ///
    xtitle("Earnings / Market Cap") ytitle("Frequency") ///
    graphregion(color(white))
graph export "figures/earnings_discontinuity.pdf", replace

* Burgstahler & Dichev (1997) test
gen earn_bin = round(earn_scaled, 0.005)
tab earn_bin if inrange(earn_scaled, -0.025, 0.025)

* Test for discontinuity at zero
gen just_above = (earn_scaled >= 0 & earn_scaled < 0.005)
gen just_below = (earn_scaled >= -0.005 & earn_scaled < 0)
prtest just_above == just_below
```

### Real Earnings Management (Roychowdhury 2006)

```stata
* Abnormal cash flow from operations
gen da_cfo = .
foreach ind of local industries {
    foreach yr of local years {
        capture {
            reg cfo inv_at sale_scaled d_sale_scaled ///
                if ff48 == `ind' & fyear == `yr', robust
            predict resid if e(sample), resid
            replace da_cfo = resid if ff48 == `ind' & fyear == `yr' & !missing(resid)
            drop resid
        }
    }
}

* Abnormal production costs
gen prod_costs = cogs + (xinv - l.xinv)
gen prod_scaled = prod_costs / l.at

gen da_prod = .
foreach ind of local industries {
    foreach yr of local years {
        capture {
            reg prod_scaled inv_at sale_scaled d_sale_scaled l.d_sale_scaled ///
                if ff48 == `ind' & fyear == `yr', robust
            predict resid if e(sample), resid
            replace da_prod = resid if ff48 == `ind' & fyear == `yr' & !missing(resid)
            drop resid
        }
    }
}
```

## Publication Tables

### Regression Table with Standard Formatting

```stata
* Main regression: Discretionary accruals on governance
reg abs_da_mj board_independence ceo_duality audit_committee_size ///
    big4 size leverage mb loss i.fyear, cluster(gvkey)
estimates store gov1

reg abs_da_mj board_independence ceo_duality audit_committee_size ///
    big4 inst_ownership analyst_following ///
    size leverage mb loss i.fyear, cluster(gvkey)
estimates store gov2

* Publication table
esttab gov1 gov2 using "tables/governance_regression.tex", ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    label title("Corporate Governance and Earnings Quality") ///
    mtitles("Baseline" "Extended") ///
    drop(*.fyear) indicate("Year FE = *.fyear") ///
    stats(N r2_a, labels("Observations" "Adj. R-squared") fmt(0 3)) ///
    addnotes("Standard errors clustered by firm in parentheses.") ///
    replace
```

## Endogeneity and Identification

### Two-Stage Least Squares

```stata
* Instrumental variable regression
ivregress 2sls earnings_quality (board_independence = ///
    state_governance_index peer_board_independence) ///
    size leverage mb loss i.fyear, cluster(gvkey) first

* First-stage diagnostics
estat firststage
estat endogenous

* Weak instrument test
estat firststage, forcenonrobust
```

### Propensity Score Matching

```stata
* PSM for treatment effect of Big 4 auditor
logit big4 size leverage mb roa loss i.ff48, robust
predict pscore, pr

* Nearest-neighbor matching
psmatch2 big4, pscore(pscore) outcome(abs_da_mj) ///
    neighbor(3) caliper(0.01) common
```

## References

- Dechow, Sloan & Sweeney (1995), "Detecting Earnings Management," TAR 70(2)
- Kothari, Leone & Wasley (2005), "Performance Matched Discretionary Accrual Measures," JAE 39(1)
- Roychowdhury (2006), "Earnings Management through Real Activities Manipulation," JAE 42(3)
- Burgstahler & Dichev (1997), "Earnings Management to Avoid Earnings Decreases and Losses," JAE 24(1)
- Compustat Manual: https://www.spglobal.com/marketintelligence
