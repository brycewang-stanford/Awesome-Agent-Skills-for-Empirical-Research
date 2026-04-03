# Colleges Endpoints Reference

> **NOTE:** This file documents endpoint patterns from the Education Data Portal API for reference. Data is now fetched via mirrors (see `education-data-query` skill). These endpoint paths help identify available datasets and their structure.

Complete reference for all college/university level endpoints in the Education Data Portal.

**Base URL**: `https://educationdata.urban.org/api/v1/college-university/`

**Primary Identifier**: `unitid` (6-digit IPEDS institution ID)

## Contents

- [IPEDS Endpoints](#ipeds-endpoints)
- [College Scorecard Endpoints](#college-scorecard-endpoints)
- [FSA Endpoints](#fsa-endpoints)
- [Other Endpoints](#other-endpoints)

---

## IPEDS Endpoints

Integrated Postsecondary Education Data System - Primary federal source for postsecondary data.

**Years Available**: 1980-2023 (varies by endpoint)

### Directory

**Endpoint**: `/college-university/ipeds/directory/{year}/`

**Years**: 1980-2023

**Variables**:

| Variable | Description |
|----------|-------------|
| `year` | Academic year |
| `unitid` | IPEDS institution ID |
| `inst_name` | Institution name |
| `fips` | State FIPS code |
| `state_abbr` | State abbreviation |
| `city` | City |
| `zip` | ZIP code |
| `address` | Street address |
| `phone` | Phone number |
| `website` | Institution URL |
| `latitude` | Latitude |
| `longitude` | Longitude |
| `county_code` | County FIPS |
| `county_name` | County name |
| `cbsa` | CBSA code |
| `csa` | CSA code |
| `congress_district_id` | Congressional district |
| `inst_control` | Control (1=public, 2=private nonprofit, 3=private for-profit) |
| `inst_level` | Level (1=4-year, 2=2-year, 3=less-than-2-year) |
| `inst_category` | Carnegie classification category |
| `hbcu` | HBCU indicator (0/1) |
| `tribal_college` | Tribal college indicator (0/1) |
| `primarily_online` | Primarily online institution (0/1) |
| `open_admissions` | Open admissions policy (0/1) |
| `locale` | Locale code |
| `degree_granting` | Degree-granting status |
| `highest_degree_offered` | Highest degree offered code |
| `calendar_system` | Calendar system (semester, quarter, etc.) |
| `enrollment_total` | Total enrollment |
| `enrollment_undergrad` | Undergraduate enrollment |
| `enrollment_grad` | Graduate enrollment |

**Filters**: `year`, `fips`, `unitid`, `inst_control`, `inst_level`, `hbcu`

### Institutional Characteristics

**Endpoint**: `/college-university/ipeds/institutional-characteristics/{year}/`

**Years**: 1984-2023

**Variables**:

| Variable | Description |
|----------|-------------|
| `unitid` | Institution ID |
| `inst_name` | Institution name |
| `room_and_board` | Room and board charge |
| `books_and_supplies` | Books/supplies estimate |
| `room_capacity` | Residence hall capacity |
| `meal_plan` | Meal plan availability |
| `undergraduate_application_fee` | Undergrad application fee |
| `graduate_application_fee` | Graduate application fee |
| `offers_rotc_army` | ROTC Army offered |
| `offers_rotc_navy` | ROTC Navy offered |
| `offers_rotc_airforce` | ROTC Air Force offered |
| `offers_credit_for_ap` | AP credit offered |
| `offers_credit_for_clep` | CLEP credit offered |
| `offers_credit_for_life_experience` | Life experience credit |

### Admissions Requirements

**Endpoint**: `/college-university/ipeds/admissions-requirements/{year}/`

**Years**: 1990-2023

**Variables**:

| Variable | Description |
|----------|-------------|
| `unitid` | Institution ID |
| `req_high_school_gpa` | HS GPA required/recommended |
| `req_high_school_rank` | HS rank required/recommended |
| `req_high_school_record` | HS record required/recommended |
| `req_test_scores` | Test scores required/recommended |
| `req_toefl` | TOEFL required/recommended |
| `req_recommendations` | Recommendations required |
| `req_secondary_school_report` | Secondary school report required |

### Admissions and Enrollment

**Endpoint**: `/college-university/ipeds/admissions-enrollment/{year}/`

**Years**: 2001-2023

**Variables**:

| Variable | Description |
|----------|-------------|
| `unitid` | Institution ID |
| `applicants_total` | Total applicants |
| `applicants_men` | Male applicants |
| `applicants_women` | Female applicants |
| `admissions_total` | Total admitted |
| `admissions_men` | Males admitted |
| `admissions_women` | Females admitted |
| `enrolled_total` | Total enrolled (first-time) |
| `enrolled_men` | Males enrolled |
| `enrolled_women` | Females enrolled |
| `enrolled_full_time` | Full-time enrolled |
| `enrolled_part_time` | Part-time enrolled |
| `admit_rate` | Admission rate |
| `yield_rate` | Yield rate |
| `sat_scores_submitted` | Students submitting SAT |
| `act_scores_submitted` | Students submitting ACT |
| `sat_reading_25` | SAT Reading 25th percentile |
| `sat_reading_75` | SAT Reading 75th percentile |
| `sat_math_25` | SAT Math 25th percentile |
| `sat_math_75` | SAT Math 75th percentile |
| `act_composite_25` | ACT Composite 25th percentile |
| `act_composite_75` | ACT Composite 75th percentile |
| `act_english_25` | ACT English 25th percentile |
| `act_english_75` | ACT English 75th percentile |
| `act_math_25` | ACT Math 25th percentile |
| `act_math_75` | ACT Math 75th percentile |

### Student Charges - Academic Year

**Endpoint**: `/college-university/ipeds/student-charges-academic-year/{year}/`

**Years**: 1984-2023

**Variables**:

| Variable | Description |
|----------|-------------|
| `unitid` | Institution ID |
| `tuition_fees_in_state` | In-state tuition and fees |
| `tuition_fees_out_state` | Out-of-state tuition and fees |
| `tuition_in_state` | In-state tuition only |
| `tuition_out_state` | Out-of-state tuition only |
| `fees_in_state` | In-state fees only |
| `fees_out_state` | Out-of-state fees only |
| `room_charge` | Room charge |
| `board_charge` | Board charge |
| `room_board_charge` | Room and board combined |
| `other_expenses` | Other expenses estimate |

### Student Charges Academic Year by Level

**Endpoint**: `/college-university/ipeds/student-charges-academic-year/{year}/{level}/`

**Levels**: `undergraduate`, `graduate`

Additional breakdown by student level.

### Student Charges Academic Year by Living Arrangement

**Endpoint**: `/college-university/ipeds/student-charges-academic-year/{year}/living-arrangement/`

**Variables include**:

| Variable | Description |
|----------|-------------|
| `living_arrangement` | On-campus, off-campus w/family, off-campus |
| `total_price` | Total price of attendance |
| `total_price_program_year` | Program year total |

### Student Charges - Program Year

**Endpoint**: `/college-university/ipeds/student-charges-program-year/{year}/`

**Years**: 2000-2023

For programs measured in program years (clock hours, etc.)

### Student Charges Program Year by Program

**Endpoint**: `/college-university/ipeds/student-charges-program-year/{year}/program/`

Breakdown by specific program.

### Enrollment - Full-Time Equivalent

**Endpoint**: `/college-university/ipeds/enrollment-full-time-equivalent/{year}/`

**Years**: 1986-2023

**Variables**:

| Variable | Description |
|----------|-------------|
| `unitid` | Institution ID |
| `fte_undergrad` | Undergraduate FTE |
| `fte_grad` | Graduate FTE |
| `fte_total` | Total FTE |
| `instructional_fte` | Instructional FTE |
| `research_fte` | Research FTE |
| `public_service_fte` | Public service FTE |

### Enrollment Headcount

**Endpoint**: `/college-university/ipeds/enrollment-headcount/{year}/`

**Years**: 1980-2023

**Variables**:

| Variable | Description |
|----------|-------------|
| `unitid` | Institution ID |
| `enrollment` | Total headcount enrollment |
| `enrollment_undergrad` | Undergraduate headcount |
| `enrollment_grad` | Graduate headcount |
| `enrollment_full_time` | Full-time enrollment |
| `enrollment_part_time` | Part-time enrollment |
| `enrollment_men` | Male enrollment |
| `enrollment_women` | Female enrollment |

### Fall Enrollment by Level

**Endpoint**: `/college-university/ipeds/fall-enrollment/{year}/{level}/`

**Years**: 1986-2023

**Levels**: `undergraduate`, `graduate`, `first-professional`

**Variables**:

| Variable | Description |
|----------|-------------|
| `unitid` | Institution ID |
| `level` | Student level |
| `enrollment` | Enrollment count |
| `enrollment_full_time` | Full-time |
| `enrollment_part_time` | Part-time |

### Fall Enrollment by Level and Race

**Endpoint**: `/college-university/ipeds/fall-enrollment/{year}/{level}/race/`

**Additional**: `race` variable

### Fall Enrollment by Level and Sex

**Endpoint**: `/college-university/ipeds/fall-enrollment/{year}/{level}/sex/`

**Additional**: `sex` variable

### Fall Enrollment by Level, Race, and Sex

**Endpoint**: `/college-university/ipeds/fall-enrollment/{year}/{level}/race/sex/`

**Additional**: `race` and `sex` variables

### Fall Enrollment by Age

**Endpoint**: `/college-university/ipeds/fall-enrollment-age/{year}/`

**Variables include**: `age_group`, `enrollment`

### Finance

**Endpoint**: `/college-university/ipeds/finance/{year}/`

**Years**: 1987-2022

**Variables** (subset):

| Variable | Description |
|----------|-------------|
| `unitid` | Institution ID |
| `rev_total` | Total revenue |
| `rev_tuition_fees` | Tuition and fees revenue |
| `rev_govt_federal` | Federal government revenue |
| `rev_govt_state` | State government revenue |
| `rev_govt_local` | Local government revenue |
| `rev_private_gifts` | Private gifts revenue |
| `rev_investment` | Investment return |
| `rev_auxiliary` | Auxiliary enterprises revenue |
| `exp_total` | Total expenditure |
| `exp_instruction` | Instruction expenditure |
| `exp_research` | Research expenditure |
| `exp_public_service` | Public service expenditure |
| `exp_academic_support` | Academic support |
| `exp_student_services` | Student services |
| `exp_institutional_support` | Institutional support |
| `exp_scholarships` | Scholarships/fellowships |
| `exp_auxiliary` | Auxiliary expenditure |
| `assets_total` | Total assets |
| `liabilities_total` | Total liabilities |
| `endowment_eoy` | End-of-year endowment |

### Student-Faculty Ratio

**Endpoint**: `/college-university/ipeds/student-faculty-ratio/{year}/`

**Years**: 2009-2023

**Variables**:

| Variable | Description |
|----------|-------------|
| `unitid` | Institution ID |
| `student_faculty_ratio` | Student-to-faculty ratio |
| `instructional_fte` | Instructional FTE faculty |

### Libraries

**Endpoint**: `/college-university/ipeds/libraries/{year}/`

**Years**: 2014-2022

**Variables**:

| Variable | Description |
|----------|-------------|
| `unitid` | Institution ID |
| `physical_books` | Physical book holdings |
| `digital_books` | Digital book holdings |
| `physical_media` | Physical media holdings |
| `digital_media` | Digital media holdings |
| `databases` | Database subscriptions |
| `library_exp_total` | Total library expenditure |
| `library_exp_salaries` | Library salary expenditure |

### Salaries

**Endpoint**: `/college-university/ipeds/salaries/{year}/`

**Years**: 2012-2022

**Variables**:

| Variable | Description |
|----------|-------------|
| `unitid` | Institution ID |
| `faculty_count` | Faculty count |
| `salary_all_avg` | Average salary (all ranks) |
| `salary_professor_avg` | Professor average |
| `salary_assoc_professor_avg` | Associate professor average |
| `salary_asst_professor_avg` | Assistant professor average |
| `salary_instructor_avg` | Instructor average |
| `salary_lecturer_avg` | Lecturer average |

### Financial Aid

**Endpoint**: `/college-university/ipeds/sfa-all-undergraduates/{year}/`

**Years**: 2007-2023

**Variables**:

| Variable | Description |
|----------|-------------|
| `unitid` | Institution ID |
| `students_receiving_aid` | Students receiving any aid |
| `pct_receiving_aid` | Percent receiving aid |
| `students_receiving_grants` | Students receiving grants |
| `avg_grant_amount` | Average grant amount |
| `students_receiving_federal_grants` | Federal grant recipients |
| `avg_federal_grant` | Average federal grant |
| `students_receiving_pell` | Pell grant recipients |
| `avg_pell` | Average Pell grant |
| `students_receiving_loans` | Student loan recipients |
| `avg_loan_amount` | Average loan amount |
| `avg_net_price` | Average net price |

### SFA by Income Level

**Endpoint**: `/college-university/ipeds/sfa-by-income/{year}/`

**Variables include**: `income_level`, `avg_net_price`, `pct_receiving_aid`

### SFA by Living Arrangement

**Endpoint**: `/college-university/ipeds/sfa-by-living-arrangement/{year}/`

### SFA by Tuition Status

**Endpoint**: `/college-university/ipeds/sfa-by-tuition-status/{year}/`

### Net Price by Income

**Endpoint**: `/college-university/ipeds/net-price-by-income/{year}/`

**Variables**:

| Variable | Description |
|----------|-------------|
| `income_level` | Family income bracket |
| `avg_net_price_public` | Net price (public) |
| `avg_net_price_private` | Net price (private) |

### Graduation Rates

**Endpoint**: `/college-university/ipeds/graduation-rates/{year}/`

**Years**: 1996-2022

**Variables**:

| Variable | Description |
|----------|-------------|
| `unitid` | Institution ID |
| `cohort_year` | Cohort starting year |
| `cohort_size` | Cohort size |
| `grad_rate_4yr` | 4-year graduation rate |
| `grad_rate_5yr` | 5-year graduation rate |
| `grad_rate_6yr` | 6-year graduation rate |
| `transfer_rate` | Transfer-out rate |
| `still_enrolled` | Still enrolled rate |

### Graduation Rates by Race

**Endpoint**: `/college-university/ipeds/graduation-rates/{year}/race/`

**Additional**: `race` variable

### Graduation Rates by Sex

**Endpoint**: `/college-university/ipeds/graduation-rates/{year}/sex/`

**Additional**: `sex` variable

### Graduation Rates 200%

**Endpoint**: `/college-university/ipeds/graduation-rates-200/{year}/`

Extended time graduation rates (8 years for 4-year institutions).

### Completions by CIP

**Endpoint**: `/college-university/ipeds/completions-cip/{year}/`

**Years**: 1984-2023

**Variables**:

| Variable | Description |
|----------|-------------|
| `unitid` | Institution ID |
| `cip_code` | CIP code (2/4/6 digit) |
| `cip_name` | CIP program name |
| `award_level` | Award level code |
| `completions` | Number of completions |
| `completions_men` | Male completions |
| `completions_women` | Female completions |

### Completions by CIP and Race

**Endpoint**: `/college-university/ipeds/completions-cip/{year}/race/`

### Completions by CIP and Sex

**Endpoint**: `/college-university/ipeds/completions-cip/{year}/sex/`

### Completions by CIP, Race, and Sex

**Endpoint**: `/college-university/ipeds/completions-cip/{year}/race/sex/`

---

## College Scorecard Endpoints

Department of Education College Scorecard data - outcomes and debt.

**Years Available**: 1996-2020 (varies)

### Institutional Characteristics

**Endpoint**: `/college-university/scorecard/institutional-characteristics/{year}/`

**Years**: 1996-2020

**Variables**:

| Variable | Description |
|----------|-------------|
| `unitid` | Institution ID |
| `predominant_degree` | Predominant degree awarded |
| `highest_degree` | Highest degree awarded |
| `ownership` | Ownership type |
| `region` | Census region |
| `online_only` | Online only indicator |
| `main_campus` | Main campus indicator |

### Student Characteristics

**Endpoint**: `/college-university/scorecard/student-characteristics/{year}/`

**Variables**:

| Variable | Description |
|----------|-------------|
| `unitid` | Institution ID |
| `pct_first_gen` | Percent first-generation |
| `pct_pell` | Percent receiving Pell |
| `pct_independent` | Percent independent students |
| `pct_married` | Percent married |
| `median_family_income` | Median family income |
| `avg_family_income` | Average family income |
| `pct_female` | Percent female |
| `pct_white` | Percent white |
| `pct_black` | Percent Black |
| `pct_hispanic` | Percent Hispanic |
| `pct_asian` | Percent Asian |

### Earnings

**Endpoint**: `/college-university/scorecard/earnings/{year}/`

**Years**: 1996-2020

**Variables**:

| Variable | Description |
|----------|-------------|
| `unitid` | Institution ID |
| `earn_count_wne_p6` | Working and not enrolled count (6 years) |
| `earn_count_wne_p10` | Working count (10 years) |
| `earn_mean_wne_p6` | Mean earnings (6 years) |
| `earn_mean_wne_p10` | Mean earnings (10 years) |
| `earn_median_wne_p6` | Median earnings (6 years) |
| `earn_median_wne_p10` | Median earnings (10 years) |
| `earn_pct_gt_25k_p6` | Percent earning >$25k (6 years) |
| `earn_pct_gt_25k_p10` | Percent earning >$25k (10 years) |

### Default Rates

**Endpoint**: `/college-university/scorecard/default/{year}/`

**Variables**:

| Variable | Description |
|----------|-------------|
| `unitid` | Institution ID |
| `cdr2` | 2-year cohort default rate |
| `cdr3` | 3-year cohort default rate |
| `default_rate_2yr` | 2-year default rate |
| `default_rate_3yr` | 3-year default rate |

### Repayment

**Endpoint**: `/college-university/scorecard/repayment/{year}/`

**Variables**:

| Variable | Description |
|----------|-------------|
| `unitid` | Institution ID |
| `repay_1yr_rate` | 1-year repayment rate |
| `repay_3yr_rate` | 3-year repayment rate |
| `repay_5yr_rate` | 5-year repayment rate |
| `repay_7yr_rate` | 7-year repayment rate |
| `median_debt` | Median debt at completion |
| `median_debt_pell` | Median debt (Pell recipients) |
| `median_debt_no_pell` | Median debt (no Pell) |
| `monthly_payment_10yr` | Monthly payment (10-year plan) |

### Completion by Income

**Endpoint**: `/college-university/scorecard/completion-by-income/{year}/`

**Variables include**: `income_bracket`, `completion_rate`

---

## FSA Endpoints

Federal Student Aid data - loans, grants, financial responsibility.

**Years Available**: 1999-2021 (varies)

### Financial Responsibility

**Endpoint**: `/college-university/fsa/financial-responsibility/{year}/`

**Years**: 2007-2021

**Variables**:

| Variable | Description |
|----------|-------------|
| `unitid` | Institution ID |
| `fr_composite_score` | Financial responsibility composite score |
| `fr_primary_reserve_ratio` | Primary reserve ratio |
| `fr_equity_ratio` | Equity ratio |
| `fr_net_income_ratio` | Net income ratio |
| `fr_zone` | FR zone (passing, zone, failing) |

### Grants

**Endpoint**: `/college-university/fsa/grants/{year}/`

**Years**: 1999-2021

**Variables**:

| Variable | Description |
|----------|-------------|
| `unitid` | Institution ID |
| `pell_recipients` | Pell grant recipients |
| `pell_disbursements` | Total Pell disbursements |
| `pell_avg_amount` | Average Pell amount |
| `seog_recipients` | SEOG recipients |
| `seog_disbursements` | Total SEOG disbursements |
| `teach_recipients` | TEACH grant recipients |
| `teach_disbursements` | TEACH disbursements |

### Loans

**Endpoint**: `/college-university/fsa/loans/{year}/`

**Years**: 1999-2021

**Variables**:

| Variable | Description |
|----------|-------------|
| `unitid` | Institution ID |
| `loan_recipients` | Direct loan recipients |
| `loan_disbursements` | Total loan disbursements |
| `subsidized_recipients` | Subsidized loan recipients |
| `subsidized_disbursements` | Subsidized disbursements |
| `unsubsidized_recipients` | Unsubsidized recipients |
| `unsubsidized_disbursements` | Unsubsidized disbursements |
| `plus_recipients` | PLUS loan recipients |
| `plus_disbursements` | PLUS disbursements |
| `grad_plus_recipients` | Grad PLUS recipients |
| `grad_plus_disbursements` | Grad PLUS disbursements |

### Campus-Based Aid

**Endpoint**: `/college-university/fsa/campus-based/{year}/`

**Years**: 1999-2021

**Variables**:

| Variable | Description |
|----------|-------------|
| `unitid` | Institution ID |
| `perkins_recipients` | Perkins loan recipients |
| `perkins_disbursements` | Perkins disbursements |
| `work_study_recipients` | Work-study recipients |
| `work_study_disbursements` | Work-study disbursements |

### 90/10 Revenue

**Endpoint**: `/college-university/fsa/ninety-ten/{year}/`

**Years**: 2007-2021

For for-profit institutions: percentage of revenue from federal sources.

**Variables**:

| Variable | Description |
|----------|-------------|
| `unitid` | Institution ID |
| `pct_revenue_federal` | Percent revenue from federal sources |
| `pct_revenue_other` | Percent revenue from other sources |
| `ninety_ten_ratio` | 90/10 ratio |

---

## Other Endpoints

### NACUBO Endowments

**Endpoint**: `/college-university/nacubo/{year}/`

**Years**: 2009-2022

**Variables**:

| Variable | Description |
|----------|-------------|
| `unitid` | Institution ID |
| `endowment_eoy` | End-of-year endowment market value |
| `endowment_change_pct` | Percent change from prior year |

### NCCS (Nonprofit Data)

**Endpoint**: `/college-university/nccs/{year}/`

990 tax form data for private nonprofits.

### EADA Athletics

**Endpoint**: `/college-university/eada/{year}/`

**Years**: 2003-2022

Equity in Athletics Disclosure Act data.

**Variables**:

| Variable | Description |
|----------|-------------|
| `unitid` | Institution ID |
| `athletes_male` | Male athletes |
| `athletes_female` | Female athletes |
| `exp_male` | Male athletics expenditure |
| `exp_female` | Female athletics expenditure |
| `rev_male` | Male athletics revenue |
| `rev_female` | Female athletics revenue |
| `coaches_male_male_head` | Male head coaches for men |
| `coaches_female_female_head` | Female head coaches for women |

### Campus Crime

**Endpoint**: `/college-university/campus-crime/{year}/`

**Years**: 2001-2022

**Variables**:

| Variable | Description |
|----------|-------------|
| `unitid` | Institution ID |
| `murder` | Murder/non-negligent manslaughter |
| `rape` | Rape offenses |
| `robbery` | Robbery offenses |
| `aggravated_assault` | Aggravated assault |
| `burglary` | Burglary |
| `motor_vehicle_theft` | Motor vehicle theft |
| `arson` | Arson |
| `domestic_violence` | Domestic violence |
| `dating_violence` | Dating violence |
| `stalking` | Stalking |
| `weapons_arrests` | Weapons arrests |
| `drug_arrests` | Drug arrests |
| `liquor_arrests` | Liquor law arrests |

### PSEO (Post-Secondary Employment Outcomes)

**Endpoint**: `/college-university/pseo/{year}/`

Experimental Census Bureau data on post-graduation employment.

---

## Endpoint Summary Table

| Source | Endpoint Count | Primary Variables |
|--------|---------------|-------------------|
| IPEDS | 32 | Directory, enrollment, finance, aid, completions |
| Scorecard | 6 | Earnings, debt, outcomes |
| FSA | 5 | Loans, grants, financial responsibility |
| Other | 9 | Endowments, athletics, crime, PSEO |
| **Total** | **52** | |
