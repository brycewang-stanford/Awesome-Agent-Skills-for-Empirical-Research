# Districts Endpoints Reference

> **NOTE:** This file documents endpoint patterns from the Education Data Portal API for reference. Data is now fetched via mirrors (see `education-data-query` skill). These endpoint paths help identify available datasets and their structure.

Complete reference for all school district (LEA) level endpoints in the Education Data Portal.

**Base URL**: `https://educationdata.urban.org/api/v1/school-districts/`

**Primary Identifier**: `leaid` (7-character NCES district ID)

## Contents

- [CCD Endpoints](#ccd-endpoints)
- [SAIPE Endpoint](#saipe-endpoint)
- [EDFacts Endpoints](#edfacts-endpoints)

---

## CCD Endpoints

Common Core of Data - National public school district directory, enrollment, and finance data.

**Years Available**: 1986-2023 (varies by endpoint)

### Directory

**Endpoint**: `/school-districts/ccd/directory/{year}/`

**Years**: 1986-2023

**Variables**:

| Variable | Description |
|----------|-------------|
| `year` | Academic year (spring semester) |
| `leaid` | NCES district ID (7-char) |
| `lea_name` | District name |
| `fips` | State FIPS code |
| `state_leaid` | State-assigned district ID |
| `state_location` | State abbreviation |
| `city_location` | City name |
| `zip_location` | ZIP code |
| `street_location` | Street address |
| `phone` | Phone number |
| `website` | District website URL |
| `urban_centric_locale` | Urban-centric locale code (11-43) |
| `county_code` | County FIPS code |
| `county_name` | County name |
| `cbsa` | Core-based statistical area code |
| `csa` | Combined statistical area code |
| `metromicro` | Metropolitan/micropolitan indicator |
| `congress_district_id` | Congressional district ID |
| `agency_type` | Agency type code |
| `agency_level` | Agency level (elementary, secondary, combined) |
| `number_of_schools` | Total number of schools |
| `enrollment` | Total enrollment |
| `teachers_fte` | Full-time equivalent teachers |
| `spec_ed_students` | Special education students |
| `english_language_learners` | English language learner students |
| `migrant_students` | Migrant students |
| `homeless_students` | Homeless students |
| `students_free_lunch` | Students eligible for free lunch |
| `students_reduced_lunch` | Students eligible for reduced-price lunch |
| `lowest_grade_offered` | Lowest grade offered in district |
| `highest_grade_offered` | Highest grade offered in district |

**Filters**: `year`, `fips`, `leaid`, `urban_centric_locale`, `agency_type`

### Enrollment by Grade

**Endpoint**: `/school-districts/ccd/enrollment/{year}/{grade}/`

**Years**: 1986-2023

**Grade URL values**: `grade-pk`, `grade-k`, `grade-1` through `grade-12`, `grade-13`, `grade-14`, `grade-99` (total)

**Variables**:

| Variable | Description |
|----------|-------------|
| `year` | Academic year |
| `leaid` | District ID |
| `fips` | State FIPS code |
| `grade` | Grade level code |
| `enrollment` | Enrollment count |

**Filters**: `year`, `fips`, `leaid`

### Enrollment by Grade and Race

**Endpoint**: `/school-districts/ccd/enrollment/{year}/{grade}/race/`

**Additional Variables**:

| Variable | Description |
|----------|-------------|
| `race` | Race/ethnicity code (1-9, 20, 99) |

### Enrollment by Grade and Sex

**Endpoint**: `/school-districts/ccd/enrollment/{year}/{grade}/sex/`

**Additional Variables**:

| Variable | Description |
|----------|-------------|
| `sex` | Sex code (1=Male, 2=Female, 9=Unknown, 99=Total) |

### Enrollment by Grade, Race, and Sex

**Endpoint**: `/school-districts/ccd/enrollment/{year}/{grade}/race/sex/`

**Additional Variables**: Both `race` and `sex`

### Finance

**Endpoint**: `/school-districts/ccd/finance/{year}/`

**Years**: 1989-2021

**Variables**:

| Variable | Description |
|----------|-------------|
| `year` | Fiscal year |
| `leaid` | District ID |
| `fips` | State FIPS code |
| `enrollment_fall_responsible` | Fall enrollment (responsible) |

#### Revenue Variables

| Variable | Description |
|----------|-------------|
| `rev_total` | Total revenue |
| `rev_fed_total` | Total federal revenue |
| `rev_fed_title_i` | Title I revenue |
| `rev_fed_idea` | IDEA (special ed) revenue |
| `rev_fed_child_nutrition` | Child nutrition program revenue |
| `rev_fed_vocational` | Vocational education revenue |
| `rev_fed_other` | Other federal revenue |
| `rev_state_total` | Total state revenue |
| `rev_state_formula` | State formula assistance |
| `rev_state_special_ed` | State special education |
| `rev_state_transportation` | State transportation |
| `rev_state_other` | Other state revenue |
| `rev_local_total` | Total local revenue |
| `rev_local_property_tax` | Property tax revenue |
| `rev_local_parent_govt` | Revenue from parent government |
| `rev_local_cities_counties` | Revenue from cities/counties |
| `rev_local_other` | Other local revenue |
| `rev_local_charges` | Charges for services |

#### Expenditure Variables

| Variable | Description |
|----------|-------------|
| `exp_total` | Total expenditure |
| `exp_current_total` | Total current expenditure |
| `exp_current_instruction` | Instruction expenditure |
| `exp_current_instruction_salaries` | Instruction salary expenditure |
| `exp_current_instruction_benefits` | Instruction benefit expenditure |
| `exp_current_support_total` | Total support services expenditure |
| `exp_current_support_student` | Student support services |
| `exp_current_support_instructional` | Instructional support |
| `exp_current_support_general_admin` | General administration |
| `exp_current_support_school_admin` | School administration |
| `exp_current_support_operations` | Operations and maintenance |
| `exp_current_support_transportation` | Transportation |
| `exp_current_support_other` | Other support services |
| `exp_current_food_services` | Food services expenditure |
| `exp_current_enterprise` | Enterprise operations |
| `exp_current_other` | Other current expenditure |
| `exp_capital_outlay` | Capital outlay expenditure |
| `exp_capital_construction` | Construction expenditure |
| `exp_capital_land` | Land and existing structures |
| `exp_capital_equipment` | Equipment expenditure |
| `exp_interest` | Interest on debt |

#### Per-Pupil Variables

| Variable | Description |
|----------|-------------|
| `rev_total_per_pupil` | Total revenue per pupil |
| `rev_fed_per_pupil` | Federal revenue per pupil |
| `rev_state_per_pupil` | State revenue per pupil |
| `rev_local_per_pupil` | Local revenue per pupil |
| `exp_total_per_pupil` | Total expenditure per pupil |
| `exp_current_per_pupil` | Current expenditure per pupil |
| `exp_current_instruction_per_pupil` | Instruction expenditure per pupil |

**Filters**: `year`, `fips`, `leaid`

---

## SAIPE Endpoint

Small Area Income and Poverty Estimates - Census Bureau poverty estimates.

**Endpoint**: `/school-districts/saipe/{year}/`

**Years**: 1995-2023

**Variables**:

| Variable | Description |
|----------|-------------|
| `year` | Estimate year |
| `leaid` | District ID |
| `fips` | State FIPS code |
| `lea_name` | District name |
| `population_5_17` | Population ages 5-17 |
| `population_5_17_poverty` | Population 5-17 in poverty |
| `population_5_17_poverty_pct` | Percent 5-17 in poverty |
| `population_5_17_poverty_pct_lb` | Lower bound (90% CI) |
| `population_5_17_poverty_pct_ub` | Upper bound (90% CI) |
| `children_poverty_total` | Total children in poverty (all ages) |
| `population_total` | Total population |
| `median_household_income` | Median household income |
| `median_household_income_lb` | Median income lower bound (90% CI) |
| `median_household_income_ub` | Median income upper bound (90% CI) |

**Filters**: `year`, `fips`, `leaid`

---

## EDFacts Endpoints

Assessment and graduation rate data at district level.

**Years Available**: 2009-2020 (varies)

### Assessments by Grade

**Endpoint**: `/school-districts/edfacts/assessments/{year}/{grade}/`

**Years**: 2009-2019

**Grade URL values**: `grade-3` through `grade-8`, `grade-99` (total)

**Variables**:

| Variable | Description |
|----------|-------------|
| `leaid` | District ID |
| `fips` | State FIPS |
| `grade` | Grade level |
| `read_test_pct_prof_midpt` | Reading proficiency midpoint % |
| `read_test_pct_prof_low` | Reading proficiency low bound % |
| `read_test_pct_prof_high` | Reading proficiency high bound % |
| `read_test_num_valid` | Reading valid test count |
| `math_test_pct_prof_midpt` | Math proficiency midpoint % |
| `math_test_pct_prof_low` | Math proficiency low bound % |
| `math_test_pct_prof_high` | Math proficiency high bound % |
| `math_test_num_valid` | Math valid test count |

### Assessments by Grade and Race

**Endpoint**: `/school-districts/edfacts/assessments/{year}/{grade}/race/`

**Additional Variables**:

| Variable | Description |
|----------|-------------|
| `race` | Race/ethnicity code |

### Assessments by Grade and Sex

**Endpoint**: `/school-districts/edfacts/assessments/{year}/{grade}/sex/`

**Additional Variables**:

| Variable | Description |
|----------|-------------|
| `sex` | Sex code |

### Assessments by Grade and Special Populations

**Endpoint**: `/school-districts/edfacts/assessments/{year}/{grade}/special-populations/`

**Additional Variables**:

| Variable | Description |
|----------|-------------|
| `disability` | Disability status (0/1) |
| `econ_disadvantaged` | Economically disadvantaged (0/1) |
| `lep` | Limited English proficient (0/1) |
| `homeless` | Homeless status (0/1) |
| `migrant` | Migrant status (0/1) |
| `foster_care` | Foster care status (0/1) |

### Graduation Rates

**Endpoint**: `/school-districts/edfacts/grad-rates/{year}/`

**Years**: 2010-2020

**Variables**:

| Variable | Description |
|----------|-------------|
| `leaid` | District ID |
| `fips` | State FIPS |
| `cohort_count` | Adjusted cohort count |
| `grad_rate_midpt` | Graduation rate midpoint % |
| `grad_rate_low` | Graduation rate low bound % |
| `grad_rate_high` | Graduation rate high bound % |

**Filters**: `year`, `fips`, `leaid`

---

## Endpoint Summary Table

| Source | Endpoint Count | Primary Variables |
|--------|---------------|-------------------|
| CCD | 6 | Directory, enrollment, finance |
| SAIPE | 1 | Poverty estimates |
| EDFacts | 5 | Assessments, graduation rates |
| **Total** | **12** | |

---

## Common Use Cases

### District Characteristics
```
/school-districts/ccd/directory/2022/
```
Get district name, location, enrollment, locale type.

### District Finance Analysis
```
/school-districts/ccd/finance/2021/?fips=6
```
Revenue and expenditure for California districts.

### Poverty and Achievement
```
/school-districts/saipe/2021/?leaid=0622710
```
Poverty estimates for specific district (combine with EDFacts).

### Enrollment Trends
```
/school-districts/ccd/enrollment/2022/grade-99/?fips=48
```
Total enrollment for Texas districts.
