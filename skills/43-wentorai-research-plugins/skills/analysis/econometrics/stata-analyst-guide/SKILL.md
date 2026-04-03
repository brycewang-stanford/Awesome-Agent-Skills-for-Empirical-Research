---
name: stata-analyst-guide
description: "Stata workflows for publication-ready sociology and social science research"
metadata:
  openclaw:
    emoji: "📋"
    category: "analysis"
    subcategory: "econometrics"
    keywords: ["Stata", "sociology", "social science", "survey data", "regression", "publication tables"]
    source: "https://www.stata.com"
---

# Stata Analyst Guide for Social Science Research

Complete Stata workflow for sociology and social science research, from survey data preparation through publication-ready regression tables and visualizations. This skill covers the analytical techniques most commonly used in top sociology journals.

## Overview

Stata is the dominant statistical software in sociology, political science, demography, and many social science disciplines. Its command-line interface, reproducible do-file workflow, and comprehensive support for survey data, multilevel models, and categorical data analysis make it the tool of choice for researchers working with complex social datasets.

This skill provides ready-to-use Stata code for the most common analytical tasks in social science research: descriptive statistics for diverse variable types, regression modeling with proper controls and robustness checks, interaction effects with meaningful visualizations, and automated production of APA/ASA-formatted tables suitable for direct inclusion in journal manuscripts.

The examples draw on typical social science data structures: individual-level survey data with sampling weights, nested data (individuals within organizations or regions), longitudinal panels, and event-history data. All code follows the conventions expected by reviewers at journals such as the American Sociological Review, American Journal of Sociology, and Social Forces.

## Descriptive Statistics

### Weighted Summary Statistics

```stata
* Social science surveys typically require survey weights
svyset psu [pweight=finalweight], strata(stratum)

* Weighted means and proportions
svy: mean income education_years age
svy: proportion race gender marital_status

* Weighted cross-tabulation
svy: tabulate education_cat income_quintile, row se

* Descriptive statistics table for paper
estpost summarize age education_years income ///
    children household_size, detail
esttab using "tables/descriptives.tex", ///
    cells("mean(fmt(2)) sd(fmt(2)) min max count") ///
    label title("Descriptive Statistics") replace
```

### Group Comparisons

```stata
* T-tests with survey weights
svy: mean income, over(gender)
lincom [income]Male - [income]Female

* ANOVA
svy: regress income i.race i.education_cat
testparm i.race
testparm i.education_cat

* Effect sizes (Cohen's d)
esize twosample income, by(gender)
```

## Regression Analysis

### OLS with Standard Controls

```stata
* Model building strategy (nested models for sociology papers)

* Model 1: Bivariate
reg income i.gender [pweight=finalweight], robust
estimates store m1

* Model 2: Add demographics
reg income i.gender age age_sq i.race i.marital [pweight=finalweight], robust
estimates store m2

* Model 3: Add human capital
reg income i.gender age age_sq i.race i.marital ///
    education_years experience experience_sq [pweight=finalweight], robust
estimates store m3

* Model 4: Add job characteristics
reg income i.gender age age_sq i.race i.marital ///
    education_years experience experience_sq ///
    i.occupation i.industry hours_worked [pweight=finalweight], robust
estimates store m4

* Publication-ready table
esttab m1 m2 m3 m4 using "tables/regression_income.tex", ///
    b(3) se(3) star(* 0.05 ** 0.01 *** 0.001) ///
    label title("OLS Regression of Income") ///
    mtitles("Bivariate" "Demographics" "Human Capital" "Full Model") ///
    stats(N r2_a, labels("Observations" "Adjusted R-squared") fmt(0 3)) ///
    addnotes("Standard errors in parentheses." ///
             "All models use survey weights.") ///
    replace
```

### Logistic Regression

```stata
* Binary outcome: employment status
logit employed i.gender age age_sq i.race i.education_cat ///
    children i.marital [pweight=finalweight], robust
estimates store logit1

* Report odds ratios
logit employed i.gender age age_sq i.race i.education_cat ///
    children i.marital [pweight=finalweight], robust or
estimates store logit_or

* Average marginal effects (preferred in sociology)
margins, dydx(*) post
estimates store ame

* Predicted probabilities by group
logit employed i.gender##i.race age education_years [pweight=finalweight], robust
margins gender#race, atmeans
marginsplot, title("Predicted Probability of Employment")
```

## Interaction Effects

### Continuous x Categorical Interaction

```stata
* Gender x education interaction on income
reg income c.education_years##i.gender age i.race [pweight=finalweight], robust

* Visualize interaction
margins gender, at(education_years=(8(2)20))
marginsplot, ///
    title("Returns to Education by Gender") ///
    ytitle("Predicted Income ($)") ///
    xtitle("Years of Education") ///
    legend(order(1 "Male" 2 "Female")) ///
    scheme(s2mono)
graph export "figures/education_gender_interaction.pdf", replace
```

### Moderation Analysis

```stata
* Test whether the effect of X on Y varies by moderator Z
reg outcome c.x_var##c.moderator controls [pweight=finalweight], robust

* Simple slopes at meaningful values of moderator
margins, dydx(x_var) at(moderator=(10 25 50 75 90))  // Percentiles
marginsplot, recast(line) recastci(rarea) ///
    title("Effect of X on Y at Different Levels of Moderator")
```

## Multilevel Models

```stata
* Students nested within schools
mixed test_score gender ses || school_id:, ///
    variance mle

* Random slopes
mixed test_score gender c.ses || school_id: ses, ///
    covariance(unstructured) mle

* Calculate ICC
estat icc

* Store and compare models
estimates store mlm1
mixed test_score gender c.ses school_quality || school_id: ses, ///
    covariance(unstructured) mle
estimates store mlm2

lrtest mlm1 mlm2
```

## Visualization for Publication

### Journal-Quality Figures

```stata
* Set publication-ready scheme
set scheme s2mono

* Coefficient plot
coefplot m2 m3 m4, ///
    drop(_cons) xline(0) ///
    title("Regression Coefficients Across Models") ///
    legend(order(2 "Demographics" 4 "Human Capital" 6 "Full")) ///
    graphregion(color(white))
graph export "figures/coefplot.pdf", replace

* Distribution comparison
twoway (kdensity income if gender==1, lcolor(navy)) ///
       (kdensity income if gender==2, lcolor(cranberry)), ///
    title("Income Distribution by Gender") ///
    legend(order(1 "Male" 2 "Female")) ///
    xtitle("Annual Income ($)") ytitle("Density") ///
    graphregion(color(white))
graph export "figures/income_density.pdf", replace
```

## Replication Package

```stata
* Master do-file structure for replication
* master.do
* ==========================================
* Project: [Title]
* Author: [Name]
* Date: [Date]
* Description: Master script for replication
* ==========================================

version 17
clear all
set more off
set maxvar 10000

global root "~/research/project_name"
global raw "$root/data/raw"
global processed "$root/data/processed"
global tables "$root/tables"
global figures "$root/figures"
global logs "$root/logs"

log using "$logs/master_log.smcl", replace

do "$root/code/01_data_cleaning.do"
do "$root/code/02_descriptives.do"
do "$root/code/03_main_analysis.do"
do "$root/code/04_robustness.do"
do "$root/code/05_tables_figures.do"

log close
```

## References

- Stata Survey Data Reference Manual: https://www.stata.com/manuals/svy.pdf
- Mitchell, M. (2021), A Visual Guide to Stata Graphics, 4th ed., Stata Press
- Long & Freese (2014), Regression Models for Categorical Dependent Variables Using Stata, 3rd ed.
- esttab/estout documentation: http://repec.sowi.unibe.ch/stata/estout/
- ASA Style Guide: https://www.asanet.org/publications/style-guide/
