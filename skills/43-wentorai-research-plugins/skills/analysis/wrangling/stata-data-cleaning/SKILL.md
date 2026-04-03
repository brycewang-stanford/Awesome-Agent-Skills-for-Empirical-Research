---
name: stata-data-cleaning
description: "Clean, transform, and validate messy research data using Stata"
metadata:
  openclaw:
    emoji: "🧹"
    category: "analysis"
    subcategory: "wrangling"
    keywords: ["Stata", "data cleaning", "data wrangling", "missing values", "recoding", "validation"]
    source: "https://www.stata.com/manuals/d.pdf"
---

# Stata Data Cleaning

Clean, transform, and validate messy research datasets in Stata. This skill covers the complete data preparation pipeline from raw survey or administrative data to analysis-ready datasets, with emphasis on documentation, reproducibility, and handling the common data quality issues encountered in social science, economics, and health research.

## Overview

Data cleaning typically consumes 60-80% of research time in empirical studies, yet it is often under-documented and poorly reproducible. Stata provides a powerful set of commands for data manipulation, but knowing which commands to use and in what order requires experience with common data quality issues: inconsistent coding, duplicate observations, string formatting problems, implausible values, and complex missing data patterns.

This skill provides a systematic, step-by-step data cleaning workflow in Stata. Each step produces a log of changes made, enabling full reproducibility and audit trails. The workflow is organized around the principle that raw data should never be modified in place -- instead, cleaning scripts transform raw data into processed datasets while preserving the original.

The approach follows best practices from the World Bank's DIME Analytics team and the J-PAL research transparency guidelines, making it suitable for projects that require rigorous data documentation for peer review, replication packages, or regulatory compliance.

## Initial Data Assessment

### Loading and Inspecting Data

```stata
* ============================================
* Data Cleaning Script: [Project Name]
* Author: [Name]
* Date: [Date]
* Input: raw/survey_data_raw.dta
* Output: processed/survey_data_clean.dta
* ============================================

clear all
set more off
log using "logs/cleaning_log.smcl", replace

* Load raw data
use "raw/survey_data_raw.dta", clear

* Basic inspection
describe
summarize
codebook, compact

* Check dimensions
display "Observations: " _N
display "Variables: " c(k)

* Check for duplicates on ID variable
duplicates report respondent_id
duplicates list respondent_id if duplicates(respondent_id) > 0
```

### Data Quality Report

```stata
* Generate a data quality summary
foreach var of varlist _all {
    quietly {
        count if missing(`var')
        local nmiss = r(N)
        local pctmiss = (`nmiss' / _N) * 100
    }
    if `pctmiss' > 0 {
        display "`var': `nmiss' missing (`pctmiss'%)"
    }
}

* Check value ranges for numeric variables
foreach var of varlist age income years_education {
    summarize `var', detail
    * Flag implausible values
    count if `var' < 0 & !missing(`var')
    count if `var' > 150 & !missing(`var')
}
```

## String Cleaning

### Standardizing Text Variables

```stata
* Trim whitespace
replace name = strtrim(name)
replace name = stritrim(name)  // Remove internal multiple spaces

* Standardize case
replace city = proper(city)        // Title case
replace country = upper(country)   // Upper case
replace email = lower(email)       // Lower case

* Remove special characters
replace phone = ustrregexra(phone, "[^0-9]", "")

* Fix encoding issues
replace name = ustrfix(name)

* Standardize common variations
replace department = "Computer Science" if ///
    inlist(department, "CS", "Comp Sci", "Comp. Sci.", "CompSci")

replace gender = "Female" if inlist(gender, "F", "f", "female", "FEMALE")
replace gender = "Male" if inlist(gender, "M", "m", "male", "MALE")
```

### Parsing Complex Strings

```stata
* Split full name into first and last
gen first_name = word(full_name, 1)
gen last_name = word(full_name, -1)

* Extract year from date string "March 15, 2024"
gen year = real(word(date_string, -1))

* Parse numeric values from strings like "$1,234.56"
gen income_clean = real(subinstr(subinstr(income_str, "$", "", .), ",", "", .))
```

## Missing Data Handling

### Identifying Missing Data Patterns

```stata
* Install missing data analysis tools
ssc install mdesc
ssc install misstable

* Summary of missing data
mdesc

* Missing data patterns
misstable summarize
misstable patterns

* Create missing indicator variables
foreach var of varlist income education occupation {
    gen mi_`var' = missing(`var')
}

* Test whether missing is random (Little's MCAR test approximation)
* Compare means of observed variables by missing status
foreach var of varlist income education {
    ttest age, by(mi_`var')
    ttest gender_numeric, by(mi_`var')
}
```

### Recoding Missing Values

```stata
* Common survey codes for missing
* -99 = refused, -88 = don't know, -77 = not applicable
foreach var of varlist income satisfaction trust_score {
    replace `var' = .r if `var' == -99  // .r = refused
    replace `var' = .d if `var' == -88  // .d = don't know
    replace `var' = .n if `var' == -77  // .n = not applicable
}

* Extended missing values preserve the reason for missingness
* while still being treated as missing in analyses
```

## Variable Construction

### Recoding and Categorization

```stata
* Create age groups
recode age (18/29 = 1 "18-29") (30/44 = 2 "30-44") ///
           (45/59 = 3 "45-59") (60/max = 4 "60+"), gen(age_group)

* Create binary indicator
gen high_income = (income > 75000) if !missing(income)

* Create composite scale (e.g., Likert items)
alpha item1 item2 item3 item4 item5, gen(scale_score) item
* Cronbach's alpha is reported; scale_score is the mean

* Standardize continuous variables
foreach var of varlist income education_years age {
    egen z_`var' = std(`var')
}

* Winsorize extreme values
winsor2 income, cuts(1 99) replace
```

### Date Variables

```stata
* Parse date strings
gen interview_date = date(date_string, "MDY")
format interview_date %td

* Extract components
gen interview_year = year(interview_date)
gen interview_month = month(interview_date)
gen interview_dow = dow(interview_date)  // 0=Sunday

* Calculate durations
gen days_since_treatment = interview_date - treatment_date
gen months_since = (interview_date - treatment_date) / 30.44
```

## Data Validation

### Assertion-Based Validation

```stata
* These assertions halt execution if violated
assert _N == 5000  // Expected sample size
assert !missing(respondent_id)  // No missing IDs
assert age >= 18 & age <= 120 if !missing(age)  // Plausible age range
assert inlist(gender, "Male", "Female", "Other", "") | missing(gender)

* Cross-variable consistency checks
assert education_years >= 0 if !missing(education_years)
assert income >= 0 if !missing(income)
assert end_date >= start_date if !missing(end_date) & !missing(start_date)
```

### Duplicate Detection and Resolution

```stata
* Identify duplicates
duplicates tag respondent_id, gen(dup_flag)
list respondent_id survey_date if dup_flag > 0, sepby(respondent_id)

* Keep most recent observation per respondent
bysort respondent_id (survey_date): keep if _n == _N

* Or keep first observation
bysort respondent_id (survey_date): keep if _n == 1
```

## Saving and Documentation

```stata
* Label all variables
label variable age "Age at time of interview (years)"
label variable income "Annual household income (USD)"
label variable education_years "Total years of formal education"

* Save cleaned dataset
compress  // Reduce file size
save "processed/survey_data_clean.dta", replace

* Export codebook
codebook, compact
describe, short

* Close log
log close
```

## Best Practices

1. **Never modify raw data files**: Always read raw data and write to a separate processed file.
2. **Log everything**: Use `log using` to capture all output for audit trails.
3. **Use assert statements**: Validate assumptions about the data at each stage.
4. **Document decisions**: Comment every recode, drop, or imputation with the rationale.
5. **Version your cleaning scripts**: Use git to track changes to .do files.
6. **Produce a data dictionary**: Label every variable and value label in the final dataset.

## References

- Stata Data Management Reference Manual: https://www.stata.com/manuals/d.pdf
- DIME Analytics Data Management Wiki: https://dimewiki.worldbank.org/Data_Management
- J-PAL Research Resources: https://www.povertyactionlab.org/resource/data-cleaning
- Long, J.S. (2009), The Workflow of Data Analysis Using Stata, Stata Press
