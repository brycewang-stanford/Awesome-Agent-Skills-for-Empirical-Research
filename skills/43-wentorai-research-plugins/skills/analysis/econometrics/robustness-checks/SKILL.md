---
name: robustness-checks
description: "Sequential robustness checks in Stata with confounder blocks"
metadata:
  openclaw:
    emoji: "🔬"
    category: "analysis"
    subcategory: "econometrics"
    keywords: ["robustness checks", "sensitivity analysis", "Stata regression", "panel data", "causal inference", "fixed effects"]
    source: "wentor-research-plugins"
---

# Robustness Checks

A skill for conducting sequential robustness checks in Stata, systematically adding blocks of potential confounders to assess estimate stability.

## Quick Start

```stata
* Base model
svy: regress outcome controls treatment
estimates store m1

* Add confounder block
svy: regress outcome controls treatment confounder1 confounder2
estimates store m2

* Compare
esttab m1 m2, se star(+ 0.1 * 0.05 ** 0.01)
```

## Key Patterns

### 1. Sequential Model Building

```stata
* Define base controls
local control_var i.batch age i.race i.gender i.education
estimates clear

* Model 1: Base model
svy: regress outcome `control_var' treatment
margins, dydx(treatment) post
estimates store m1

* Model 2: Add contextual factors
svy: regress outcome `control_var' treatment covid health_insurance
margins, dydx(treatment) post
estimates store m2

* Model 3: Add health factors
svy: regress outcome `control_var' treatment cci_charlson any_encounter
margins, dydx(treatment) post
estimates store m3

* Model 4: Add psychological factors
svy: regress outcome `control_var' treatment depression anxiety
margins, dydx(treatment) post
estimates store m4

* Model 5: Add behavioral factors
svy: regress outcome `control_var' treatment i.smoke_status bmi
margins, dydx(treatment) post
estimates store m5
```

### 2. Standard Robustness Check Template

```stata
*------------------------------------------------------------
* Table: Robustness Checks
*------------------------------------------------------------
version 17
clear all
use "analysis_data.dta", clear
svyset cluster [pweight = weight]

* Base controls (always included)
local control_var i.batch leukocytes age i.race i.gender i.education i.marital
estimates clear

*--- Model 1: Baseline ---
svy: regress outcome `control_var' treatment
margins, dydx(treatment) post
estimates store m1

*--- Model 2: + COVID & Insurance ---
svy: regress outcome `control_var' treatment covid health_insurance
margins, dydx(treatment) post
estimates store m2

*--- Model 3: + Healthcare utilization ---
svy: regress outcome `control_var' treatment cci_charlson any_encounter_3years
margins, dydx(treatment) post
estimates store m3

*--- Model 4: + Multimorbidity ---
svy: regress outcome `control_var' treatment multi_morbidity
margins, dydx(treatment) post
estimates store m4

*--- Model 5: + Psychosocial factors ---
svy: regress outcome `control_var' treatment matter_important matter_depend
margins, dydx(treatment) post
estimates store m5

*--- Model 6: + Occupation ---
svy: regress outcome `control_var' treatment i.occ_group
margins, dydx(treatment) post
estimates store m6

*--- Model 7: + Smoking ---
svy: regress outcome `control_var' treatment i.smoke_status
margins, dydx(treatment) post
estimates store m7

*--- Model 8: + Childhood adversity ---
svy: regress outcome `control_var' treatment c.aces_sum_std
margins, dydx(treatment) post
estimates store m8

*--- Export ---
esttab m1 m2 m3 m4 m5 m6 m7 m8 using "robustness.csv", csv se ///
  mtitle("Base" "+COVID" "+Health" "+Morbid" "+Psych" "+Occ" "+Smoke" "+ACE") ///
  nogap label replace star(+ 0.1 * 0.05 ** 0.01)
```

### 3. Multiple Outcomes

```stata
* Repeat for each outcome
foreach outcome in pace grimage2 phenoage {
  estimates clear

  svy: regress `outcome' `control_var' treatment
  margins, dydx(treatment) post
  estimates store `outcome'_m1

  svy: regress `outcome' `control_var' treatment covid health_insurance
  margins, dydx(treatment) post
  estimates store `outcome'_m2

  svy: regress `outcome' `control_var' treatment cci_charlson any_encounter
  margins, dydx(treatment) post
  estimates store `outcome'_m3
}

* Export all
esttab pace_m1 pace_m2 pace_m3 grimage2_m1 grimage2_m2 grimage2_m3 ///
  using "robustness_all.csv", csv se nogap label replace
```

### 4. Model Specification Checks

```stata
estimates clear

* Linear specification
svy: regress outcome `control_var' treatment
estimates store linear

* Logged outcome
gen log_outcome = ln(outcome + 1)
svy: regress log_outcome `control_var' treatment
estimates store log_linear

* Categorical treatment
svy: regress outcome `control_var' i.treatment_cat
estimates store categorical

* With squared term
svy: regress outcome `control_var' c.treatment##c.treatment
estimates store quadratic

esttab linear log_linear categorical quadratic using "spec_checks.csv", ///
  csv se nogap label replace
```

### 5. Sample Restriction Checks

```stata
estimates clear

* Full sample
svy: regress outcome `control_var' treatment
estimates store full

* Exclude outliers
svy: regress outcome `control_var' treatment if outcome < p99_outcome
estimates store no_outliers

* Complete cases only
svy: regress outcome `control_var' treatment if complete_case == 1
estimates store complete

* Subpopulation
svy, subpop(if age >= 50): regress outcome `control_var' treatment
estimates store age50plus

esttab full no_outliers complete age50plus using "sample_checks.csv", ///
  csv se nogap label replace
```

### 6. Alternative Variable Definitions

```stata
estimates clear

* Binary treatment
svy: regress outcome `control_var' treatment_binary
margins, dydx(treatment_binary) post
estimates store binary

* Continuous treatment
svy: regress outcome `control_var' treatment_continuous
margins, dydx(treatment_continuous) post
estimates store continuous

* Categorical treatment
svy: regress outcome `control_var' i.treatment_cat
margins, dydx(treatment_cat) post
estimates store categorical

* Standardized treatment
svy: regress outcome `control_var' c.treatment_std
margins, dydx(treatment_std) post
estimates store standardized

esttab binary continuous categorical standardized using "alt_definitions.csv", ///
  csv se nogap label replace
```

## Interpretation Guide

| Result | Interpretation |
|--------|----------------|
| Estimate stable across models | Robust to confounding |
| Estimate attenuates with additions | Confounding present |
| Estimate reverses sign | Serious confounding concern |
| Estimate strengthens | Suppression effect |
| SE increases substantially | Multicollinearity |

## Tips

- Start with theoretically-motivated confounder blocks
- Order blocks from most to least plausible confounders
- Document the rationale for each block
- Present all models, not just the "best" one
- Watch for substantial increases in standard errors (multicollinearity)
- Consider pre-registering the robustness check plan
