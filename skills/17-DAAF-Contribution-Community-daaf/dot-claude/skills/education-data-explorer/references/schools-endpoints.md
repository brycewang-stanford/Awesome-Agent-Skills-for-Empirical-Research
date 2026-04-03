# Schools Endpoints Reference

> **NOTE:** This file documents endpoint patterns from the Education Data Portal API for reference. Data is now fetched via mirrors (see `education-data-query` skill). These endpoint paths help identify available datasets and their structure.

Complete reference for all school-level endpoints in the Education Data Portal.

**Base URL**: `https://educationdata.urban.org/api/v1/schools/`

**Primary Identifier**: `ncessch` (12-character NCES school ID)

## Contents

- [CCD Endpoints](#ccd-endpoints)
- [CRDC Endpoints](#crdc-endpoints)
- [EDFacts Endpoints](#edfacts-endpoints)
- [MEPS Endpoint](#meps-endpoint)
- [NHGIS Endpoints](#nhgis-endpoints)

---

## CCD Endpoints

Common Core of Data - National public school directory and enrollment data.

**Years Available**: 1986-2023 (varies by endpoint)

### Directory

**Endpoint**: `/schools/ccd/directory/{year}/`

**Years**: 1986-2023

**Variables**:

| Variable | Description |
|----------|-------------|
| `year` | Academic year (spring semester) |
| `ncessch` | NCES school ID (12-char) |
| `ncessch_num` | NCES school ID (numeric) |
| `leaid` | LEA/district ID (7-char) |
| `lea_name` | District name |
| `school_name` | School name |
| `fips` | State FIPS code |
| `state_location` | State abbreviation |
| `city_location` | City name |
| `zip_location` | ZIP code |
| `street_location` | Street address |
| `phone` | Phone number |
| `latitude` | Latitude coordinate |
| `longitude` | Longitude coordinate |
| `county_code` | County FIPS code |
| `county_name` | County name |
| `cbsa` | Core-based statistical area code |
| `csa` | Combined statistical area code |
| `urban_centric_locale` | Urban-centric locale code (11-43) |
| `congress_district_id` | Congressional district ID |
| `school_level` | School level (0-4) |
| `school_type` | School type (1-4) |
| `school_status` | Operating status |
| `charter` | Charter school indicator (0/1) |
| `magnet` | Magnet school indicator (0/1) |
| `virtual` | Virtual school indicator |
| `title_i_eligible` | Title I eligible (0/1) |
| `title_i_schoolwide` | Title I schoolwide program (0/1) |
| `lowest_grade_offered` | Lowest grade offered |
| `highest_grade_offered` | Highest grade offered |
| `enrollment` | Total enrollment |
| `teachers_fte` | Full-time equivalent teachers |
| `free_lunch` | Free lunch eligible students |
| `reduced_price_lunch` | Reduced-price lunch eligible |
| `free_or_reduced_price_lunch` | Total FRPL eligible |
| `bureau_indian_education` | BIE school indicator |

**Filters**: `year`, `fips`, `leaid`, `ncessch`, `charter`, `magnet`, `school_level`, `school_type`, `urban_centric_locale`

### Enrollment by Grade

**Endpoint**: `/schools/ccd/enrollment/{year}/{grade}/`

**Years**: 1986-2023

**Grade URL values**: `grade-pk`, `grade-k`, `grade-1` through `grade-12`, `grade-13`, `grade-14`, `grade-99` (total)

**Variables**:

| Variable | Description |
|----------|-------------|
| `year` | Academic year |
| `ncessch` | NCES school ID |
| `leaid` | District ID |
| `fips` | State FIPS code |
| `grade` | Grade level code |
| `enrollment` | Enrollment count |

**Filters**: `year`, `fips`, `leaid`, `ncessch`

### Enrollment by Grade and Race

**Endpoint**: `/schools/ccd/enrollment/{year}/{grade}/race/`

**Additional Variables**:

| Variable | Description |
|----------|-------------|
| `race` | Race/ethnicity code (1-9, 20, 99) |

### Enrollment by Grade and Sex

**Endpoint**: `/schools/ccd/enrollment/{year}/{grade}/sex/`

**Additional Variables**:

| Variable | Description |
|----------|-------------|
| `sex` | Sex code (1=Male, 2=Female, 9=Unknown, 99=Total) |

### Enrollment by Grade, Race, and Sex

**Endpoint**: `/schools/ccd/enrollment/{year}/{grade}/race/sex/`

**Additional Variables**: Both `race` and `sex`

---

## CRDC Endpoints

Civil Rights Data Collection - Discipline, course access, staffing data.

**Years Available**: 2011, 2013, 2015, 2017, 2020 (biennial)

### Directory

**Endpoint**: `/schools/crdc/directory/{year}/`

**Variables**:

| Variable | Description |
|----------|-------------|
| `year` | Survey year |
| `ncessch` | NCES school ID |
| `leaid` | District ID |
| `crdc_id` | CRDC school ID |
| `school_name` | School name |
| `fips` | State FIPS code |
| `charter` | Charter indicator |
| `magnet` | Magnet indicator |
| `alternative` | Alternative school indicator |
| `special_ed` | Special education school |
| `jj_school` | Juvenile justice school |
| `enrollment` | Total enrollment |

### Enrollment (3 endpoints)

**Endpoints**:
- `/schools/crdc/enrollment/{year}/` - Total enrollment
- `/schools/crdc/enrollment/{year}/race/` - By race
- `/schools/crdc/enrollment/{year}/race/sex/` - By race and sex

**Variables**:

| Variable | Description |
|----------|-------------|
| `enrollment` | Enrollment count |
| `race` | Race/ethnicity code |
| `sex` | Sex code |
| `disability` | Students with disabilities (IDEA) |
| `lep` | Limited English proficient |
| `section504` | Section 504 students |

### Discipline (multiple endpoints)

**CRITICAL:** CRDC discipline endpoints require disaggregation levels in the URL path.

**Working Endpoints**:
- `/schools/crdc/discipline/{year}/disability/sex/` - By disability and sex
- `/schools/crdc/discipline/{year}/disability/race/sex/` - By disability, race, and sex
- `/schools/crdc/suspensions-days/{year}/race/sex/` - Suspension days data

**Note:** Standalone endpoints like `/schools/crdc/discipline/{year}/` may return 404. Use disaggregated endpoints.

**Variables**:

| Variable | Description |
|----------|-------------|
| `expulsions_with_ed` | Expulsions with educational services |
| `expulsions_without_ed` | Expulsions without educational services |
| `expulsions_under_zero_tolerance` | Zero-tolerance expulsions |
| `iss` | In-school suspensions |
| `oss_one` | Out-of-school suspension (1 occurrence) |
| `oss_multiple` | Out-of-school suspension (multiple) |
| `referrals_to_law_enforcement` | Law enforcement referrals |
| `school_related_arrests` | School-related arrests |
| `students_corporal_punishment` | Corporal punishment |
| `transfers_to_alt_schools` | Transfers to alternative schools |

### Chronic Absenteeism (3 endpoints)

**Endpoints**:
- `/schools/crdc/chronic-absenteeism/{year}/` - Total
- `/schools/crdc/chronic-absenteeism/{year}/race/` - By race
- `/schools/crdc/chronic-absenteeism/{year}/race/sex/` - By race and sex

**Variables**:

| Variable | Description |
|----------|-------------|
| `chronic_absentees` | Students chronically absent (15+ days) |

### Harassment and Bullying (4 endpoints)

**Endpoints**:
- `/schools/crdc/harassment-or-bullying/{year}/` - Total
- `/schools/crdc/harassment-or-bullying/{year}/race/` - By race
- `/schools/crdc/harassment-or-bullying/{year}/sex/` - By sex
- `/schools/crdc/harassment-or-bullying/{year}/race/sex/` - By race and sex

**Variables**:

| Variable | Description |
|----------|-------------|
| `allegations_of_harassment_sex` | Allegations based on sex |
| `allegations_of_harassment_race` | Allegations based on race |
| `allegations_of_harassment_disability` | Allegations based on disability |
| `allegations_of_harassment_orientation` | Allegations based on sexual orientation |
| `allegations_of_harassment_religion` | Allegations based on religion |
| `students_disciplined_harassment_sex` | Disciplined for sex harassment |
| `students_disciplined_harassment_race` | Disciplined for race harassment |
| `students_disciplined_harassment_disability` | Disciplined for disability harassment |
| `students_disciplined_harassment_orientation` | Disciplined for orientation harassment |
| `students_disciplined_harassment_religion` | Disciplined for religion harassment |

### Restraint and Seclusion (4 endpoints)

**Endpoints**:
- `/schools/crdc/restraint-and-seclusion/{year}/` - Total
- `/schools/crdc/restraint-and-seclusion/{year}/race/` - By race
- `/schools/crdc/restraint-and-seclusion/{year}/sex/` - By sex
- `/schools/crdc/restraint-and-seclusion/{year}/race/sex/` - By race and sex

**Variables**:

| Variable | Description |
|----------|-------------|
| `students_restrained_mechanical` | Mechanical restraint |
| `students_restrained_physical` | Physical restraint |
| `students_secluded` | Seclusion |
| `instances_restrained_mechanical` | Mechanical restraint instances |
| `instances_restrained_physical` | Physical restraint instances |
| `instances_secluded` | Seclusion instances |

### AP/IB/Gifted and Talented (3 endpoints)

**Endpoints**:
- `/schools/crdc/ap-ib-gt/{year}/` - Total
- `/schools/crdc/ap-ib-gt/{year}/race/` - By race
- `/schools/crdc/ap-ib-gt/{year}/race/sex/` - By race and sex

**Variables**:

| Variable | Description |
|----------|-------------|
| `ap_enrollment` | AP course enrollment |
| `ib_enrollment` | IB course enrollment |
| `gt_enrollment` | Gifted/talented enrollment |
| `ap_courses_offered` | Number of AP courses offered |
| `ap_students_passed` | Students passing AP exam |

### AP Exams (3 endpoints)

**Endpoints**:
- `/schools/crdc/ap-exams/{year}/` - Total
- `/schools/crdc/ap-exams/{year}/race/` - By race
- `/schools/crdc/ap-exams/{year}/race/sex/` - By race and sex

**Variables**:

| Variable | Description |
|----------|-------------|
| `students_AP_exam` | Students taking AP exam |
| `students_AP_passed` | Students passing AP exam (3+) |

### SAT/ACT (3 endpoints)

**Endpoints**:
- `/schools/crdc/sat-act/{year}/` - Total
- `/schools/crdc/sat-act/{year}/race/` - By race
- `/schools/crdc/sat-act/{year}/race/sex/` - By race and sex

**Variables**:

| Variable | Description |
|----------|-------------|
| `students_SAT_ACT` | Students taking SAT or ACT |

### Teachers and Staff

**Endpoint**: `/schools/crdc/teachers-and-staff/{year}/`

**Variables**:

| Variable | Description |
|----------|-------------|
| `teachers_certified` | Certified teachers |
| `teachers_first_year` | First-year teachers |
| `teachers_second_year` | Second-year teachers |
| `teachers_absent_10_plus` | Teachers absent 10+ days |
| `counselors_fte` | Counselor FTEs |
| `psychologists_fte` | Psychologist FTEs |
| `social_workers_fte` | Social worker FTEs |
| `nurses_fte` | Nurse FTEs |
| `law_enforcement_fte` | Law enforcement FTEs |
| `security_guards_fte` | Security guard FTEs |

### Math and Science Courses (3 endpoints)

**Endpoints**:
- `/schools/crdc/math-and-science/{year}/` - Total
- `/schools/crdc/math-and-science/{year}/race/` - By race
- `/schools/crdc/math-and-science/{year}/race/sex/` - By race and sex

**Variables**:

| Variable | Description |
|----------|-------------|
| `algebra_2` | Algebra II enrollment |
| `calculus` | Calculus enrollment |
| `geometry` | Geometry enrollment |
| `advanced_math` | Advanced math enrollment |
| `biology` | Biology enrollment |
| `chemistry` | Chemistry enrollment |
| `physics` | Physics enrollment |

### Algebra I (3 endpoints)

**Endpoints**:
- `/schools/crdc/algebra1/{year}/` - Total
- `/schools/crdc/algebra1/{year}/race/` - By race
- `/schools/crdc/algebra1/{year}/race/sex/` - By race and sex

**Variables**:

| Variable | Description |
|----------|-------------|
| `algebra1_grade7` | Algebra I in grade 7 |
| `algebra1_grade8` | Algebra I in grade 8 |
| `passed_algebra1_grade7` | Passed Algebra I in grade 7 |
| `passed_algebra1_grade8` | Passed Algebra I in grade 8 |

### Dual Enrollment (3 endpoints)

**Endpoints**:
- `/schools/crdc/dual-enrollment/{year}/` - Total
- `/schools/crdc/dual-enrollment/{year}/race/` - By race
- `/schools/crdc/dual-enrollment/{year}/race/sex/` - By race and sex

**Variables**:

| Variable | Description |
|----------|-------------|
| `dual_enrollment` | Dual enrollment count |
| `credit_recovery` | Credit recovery enrollment |

### Course Offerings

**Endpoint**: `/schools/crdc/offerings/{year}/`

**Variables**:

| Variable | Description |
|----------|-------------|
| `offers_ap` | Offers AP courses (0/1) |
| `offers_ib` | Offers IB courses (0/1) |
| `offers_gt` | Offers gifted/talented (0/1) |
| `offers_algebra1` | Offers Algebra I (0/1) |
| `offers_algebra2` | Offers Algebra II (0/1) |
| `offers_geometry` | Offers Geometry (0/1) |
| `offers_calculus` | Offers Calculus (0/1) |
| `offers_biology` | Offers Biology (0/1) |
| `offers_chemistry` | Offers Chemistry (0/1) |
| `offers_physics` | Offers Physics (0/1) |

### Finance

**Endpoint**: `/schools/crdc/finance/{year}/`

**Variables**:

| Variable | Description |
|----------|-------------|
| `total_expenditure` | Total school expenditure |
| `per_pupil_expenditure` | Per-pupil expenditure |
| `non_personnel_expenditure` | Non-personnel expenditure |
| `personnel_salaries` | Personnel salary expenditure |
| `personnel_benefits` | Personnel benefit expenditure |

### Retention (3 endpoints)

**Endpoints**:
- `/schools/crdc/retention/{year}/` - Total
- `/schools/crdc/retention/{year}/race/` - By race
- `/schools/crdc/retention/{year}/race/sex/` - By race and sex

**Variables**:

| Variable | Description |
|----------|-------------|
| `students_retained` | Students retained in grade |

### COVID

**Endpoint**: `/schools/crdc/covid/{year}/`

**Years**: 2020 only

**Variables**:

| Variable | Description |
|----------|-------------|
| `instruction_mode` | Instruction mode during COVID |
| `days_in_person` | Days of in-person instruction |
| `days_virtual` | Days of virtual instruction |
| `days_hybrid` | Days of hybrid instruction |

### Internet Access

**Endpoint**: `/schools/crdc/internet-access/{year}/`

**Years**: 2017, 2020

**Variables**:

| Variable | Description |
|----------|-------------|
| `students_no_device` | Students without device |
| `students_no_internet` | Students without internet |

### Offenses

**Endpoint**: `/schools/crdc/offenses/{year}/`

**Variables**:

| Variable | Description |
|----------|-------------|
| `offenses_alcohol` | Alcohol offenses |
| `offenses_drugs` | Drug offenses |
| `offenses_weapons_firearm` | Firearm offenses |
| `offenses_weapons_other` | Other weapon offenses |
| `offenses_violence` | Violence offenses |
| `offenses_sexual` | Sexual offenses |

---

## EDFacts Endpoints

Assessment and graduation rate data.

**Years Available**: 2009-2018, 2020 (note: 2019 is MISSING from the API)

### Assessments by Grade

**Endpoint**: `/schools/edfacts/assessments/{year}/{grade}/`

**Variables**:

| Variable | Description |
|----------|-------------|
| `ncessch` | School ID |
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

**Endpoint**: `/schools/edfacts/assessments/{year}/{grade}/race/`

**Additional**: `race` variable

### Assessments by Grade and Sex

**Endpoint**: `/schools/edfacts/assessments/{year}/{grade}/sex/`

**Additional**: `sex` variable

### Assessments by Grade and Special Populations

**Endpoint**: `/schools/edfacts/assessments/{year}/{grade}/special-populations/`

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

**Endpoint**: `/schools/edfacts/grad-rates/{year}/`

**Years**: 2010-2020

**Variables**:

| Variable | Description |
|----------|-------------|
| `cohort_count` | Adjusted cohort count |
| `grad_rate_midpt` | Graduation rate midpoint % |
| `grad_rate_low` | Graduation rate low bound % |
| `grad_rate_high` | Graduation rate high bound % |

---

## MEPS Endpoint

Measures of Education Poverty in Schools.

**Endpoint**: `/schools/meps/{year}/`

**Years**: 2006-2019

**Variables**:

| Variable | Description |
|----------|-------------|
| `ncessch` | School ID |
| `fips` | State FIPS |
| `meps_poverty_pct` | School poverty percentage (100% FPL) |
| `meps_mod_poverty_pct` | School moderate poverty percentage |
| `poverty_quintile` | Poverty quintile (1-5) |

**Note:** The field is `meps_poverty_pct`, not `school_poverty`.

---

## NHGIS Endpoints

Census geography crosswalks - link schools to census tracts/blocks.

### 1990 Census

**Endpoint**: `/schools/nhgis/census-1990/{year}/`

**Years**: 1990-1999

### 2000 Census

**Endpoint**: `/schools/nhgis/census-2000/{year}/`

**Years**: 2000-2009

### 2010 Census

**Endpoint**: `/schools/nhgis/census-2010/{year}/`

**Years**: 2010-2019

### 2020 Census

**Endpoint**: `/schools/nhgis/census-2020/{year}/`

**Years**: 2020-2023

**Variables** (all NHGIS endpoints):

| Variable | Description |
|----------|-------------|
| `ncessch` | School ID |
| `tract` | Census tract ID |
| `block_group` | Census block group ID |
| `block` | Census block ID |
| `gisjoin` | NHGIS geographic ID |

---

## Endpoint Summary Table

| Source | Endpoint Count | Primary Variables |
|--------|---------------|-------------------|
| CCD | 5 | Directory, enrollment |
| CRDC | 48 | Discipline, courses, staff, civil rights |
| EDFacts | 5 | Assessments, graduation rates |
| MEPS | 1 | School poverty measure |
| NHGIS | 4 | Census geography crosswalks |
| **Total** | **63** | |
