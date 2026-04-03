# Query Patterns Reference

> **LEGACY REFERENCE:** This file documents the deprecated REST API query approach using direct HTTP requests. For current mirror-based data fetching, see `fetch-patterns.md` in this skill directory. This file is retained for reference only.

Comprehensive URL construction examples for the Education Data Portal API.

## URL Structure

```
https://educationdata.urban.org/api/v1/{level}/{source}/{topic}/{year}/[disaggregators]/[?filters]
```

## Schools (CCD)

### Directory

Basic school information (name, address, type, status).

```python
# All schools (paginated)
"https://educationdata.urban.org/api/v1/schools/ccd/directory/2020/"

# Schools in California
"https://educationdata.urban.org/api/v1/schools/ccd/directory/2020/?fips=6"

# Charter schools nationwide
"https://educationdata.urban.org/api/v1/schools/ccd/directory/2020/?charter=1"

# Magnet schools in New York
"https://educationdata.urban.org/api/v1/schools/ccd/directory/2020/?fips=36&magnet=1"

# High schools (school_level=3)
"https://educationdata.urban.org/api/v1/schools/ccd/directory/2020/?school_level=3"

# Elementary schools in Texas
"https://educationdata.urban.org/api/v1/schools/ccd/directory/2020/?fips=48&school_level=1"

# Charter high schools in California
"https://educationdata.urban.org/api/v1/schools/ccd/directory/2020/?fips=6&charter=1&school_level=3"

# Virtual schools
"https://educationdata.urban.org/api/v1/schools/ccd/directory/2020/?virtual=1"

# Title I eligible schools in Florida
"https://educationdata.urban.org/api/v1/schools/ccd/directory/2020/?fips=12&title_i_eligible=1"

# Urban schools (urban_centric_locale 11-13)
"https://educationdata.urban.org/api/v1/schools/ccd/directory/2020/?urban_centric_locale=11,12,13"

# Rural schools (urban_centric_locale 41-43)
"https://educationdata.urban.org/api/v1/schools/ccd/directory/2020/?urban_centric_locale=41,42,43"

# Multiple states
"https://educationdata.urban.org/api/v1/schools/ccd/directory/2020/?fips=6,36,48"

# Specific school by NCES ID
"https://educationdata.urban.org/api/v1/schools/ccd/directory/2020/?ncessch=060000000001"

# Schools in a specific district
"https://educationdata.urban.org/api/v1/schools/ccd/directory/2020/?leaid=0600001"

# Multiple years
"https://educationdata.urban.org/api/v1/schools/ccd/directory/?year=2018,2019,2020&fips=6"
```

### Enrollment

School enrollment data. **Requires grade disaggregator in path.**

```python
# Total enrollment (grade-99 = all grades)
"https://educationdata.urban.org/api/v1/schools/ccd/enrollment/2020/grade-99/"

# Total enrollment in California
"https://educationdata.urban.org/api/v1/schools/ccd/enrollment/2020/grade-99/?fips=6"

# Grade 3 enrollment
"https://educationdata.urban.org/api/v1/schools/ccd/enrollment/2020/grade-3/"

# Kindergarten enrollment in Texas
"https://educationdata.urban.org/api/v1/schools/ccd/enrollment/2020/grade-pk/?fips=48"

# Grade 12 enrollment in charter schools
"https://educationdata.urban.org/api/v1/schools/ccd/enrollment/2020/grade-12/?charter=1"

# Enrollment by race (MUST include grade first - grade-99 for totals)
"https://educationdata.urban.org/api/v1/schools/ccd/enrollment/2020/grade-99/race/"

# Enrollment by race in California
"https://educationdata.urban.org/api/v1/schools/ccd/enrollment/2020/grade-99/race/?fips=6"

# Enrollment by sex (MUST include grade first)
"https://educationdata.urban.org/api/v1/schools/ccd/enrollment/2020/grade-99/sex/"

# Enrollment by race and sex (order: grade → race → sex)
"https://educationdata.urban.org/api/v1/schools/ccd/enrollment/2020/grade-99/race/sex/"
```

**Grade values (URL path → data column):**

| URL Path | Data Column | Description |
|----------|-------------|-------------|
| `grade-pk` | `grade = -1` | Pre-kindergarten (**SEMANTIC TRAP!**) |
| `grade-k` | `grade = 0` | Kindergarten |
| `grade-1` to `grade-12` | `grade = 1` to `12` | Grades 1-12 |
| `grade-13` | `grade = 13` | Ungraded |
| `grade-99` | `grade = 99` | Total (all grades combined) |

**CRITICAL:** In downloaded data, `grade = -1` means Pre-K, NOT missing data!

**CRITICAL: Disaggregator Ordering Rules**

For CCD enrollment endpoints, disaggregators must follow this order:
1. `grade` (REQUIRED for race/sex disaggregation)
2. `race` (optional)
3. `sex` (optional)

Patterns that **FAIL** (return HTTP 500):
- `/enrollment/2020/race/` - Missing grade
- `/enrollment/2020/sex/` - Missing grade
- `/enrollment/2020/race/grade-99/` - Wrong order

### Membership

Similar to enrollment but different counting methodology.

```python
# Total membership
"https://educationdata.urban.org/api/v1/schools/ccd/membership/2020/grade-99/"

# Membership by grade and race
"https://educationdata.urban.org/api/v1/schools/ccd/membership/2020/grade-3/race/"
```

## Schools (CRDC)

Civil Rights Data Collection - discipline, courses, staffing.

### Enrollment

```python
# CRDC enrollment
"https://educationdata.urban.org/api/v1/schools/crdc/enrollment/2017/"

# By disability status
"https://educationdata.urban.org/api/v1/schools/crdc/enrollment/2017/disability/"

# By race and sex
"https://educationdata.urban.org/api/v1/schools/crdc/enrollment/2017/race/sex/"

# LEP students
"https://educationdata.urban.org/api/v1/schools/crdc/enrollment/2017/lep/"
```

### Discipline

**CRITICAL: CRDC discipline endpoints require disaggregation levels in the URL path.**

```python
# Discipline (requires disaggregation - use disability/sex or disability/race/sex)
"https://educationdata.urban.org/api/v1/schools/crdc/discipline/2020/disability/sex/"

# Discipline by race (must include other disaggregations)
"https://educationdata.urban.org/api/v1/schools/crdc/discipline/2020/disability/race/sex/"

# Suspensions-days endpoint
"https://educationdata.urban.org/api/v1/schools/crdc/suspensions-days/2020/race/sex/"

# Restraint and seclusion
"https://educationdata.urban.org/api/v1/schools/crdc/restraint-and-seclusion/2017/"
```

**Note:** Endpoints like `/crdc/suspensions/` and `/crdc/expulsions/` may return 404. Use `/crdc/discipline/` with disaggregation instead.

### Advanced Coursework

**CRITICAL: AP enrollment requires disaggregation in URL path.**

```python
# AP/IB enrollment (requires race/sex disaggregation)
"https://educationdata.urban.org/api/v1/schools/crdc/ap-ib-enrollment/2020/race/sex/"

# Note: /crdc/ap-enrollment/ may return 404; use /crdc/ap-ib-enrollment/ instead

# AP exams
"https://educationdata.urban.org/api/v1/schools/crdc/ap-exams/2017/"

# Algebra enrollment
"https://educationdata.urban.org/api/v1/schools/crdc/algebra1/2017/"

# Gifted/talented enrollment
"https://educationdata.urban.org/api/v1/schools/crdc/gifted-and-talented/2017/"
```

## Schools (EDFacts)

Assessment and achievement data.

```python
# Assessment participation
"https://educationdata.urban.org/api/v1/schools/edfacts/assessments/2019/grade-3/"

# By race
"https://educationdata.urban.org/api/v1/schools/edfacts/assessments/2019/grade-3/race/"

# Math proficiency
"https://educationdata.urban.org/api/v1/schools/edfacts/math-proficiency/2019/grade-3/"

# Reading proficiency
"https://educationdata.urban.org/api/v1/schools/edfacts/rla-proficiency/2019/grade-3/"

# Graduation rates (EDFacts)
"https://educationdata.urban.org/api/v1/schools/edfacts/grad-rates/2019/"
```

## School Districts (CCD)

### Directory

```python
# All districts
"https://educationdata.urban.org/api/v1/school-districts/ccd/directory/2020/"

# Districts in California
"https://educationdata.urban.org/api/v1/school-districts/ccd/directory/2020/?fips=6"

# Specific district by LEAID
"https://educationdata.urban.org/api/v1/school-districts/ccd/directory/2020/?leaid=0600001"

# By agency type (1=regular local, 2=component, etc.)
"https://educationdata.urban.org/api/v1/school-districts/ccd/directory/2020/?agency_type=1"
```

### Enrollment

```python
# Total district enrollment
"https://educationdata.urban.org/api/v1/school-districts/ccd/enrollment/2020/grade-99/"

# District enrollment in Texas
"https://educationdata.urban.org/api/v1/school-districts/ccd/enrollment/2020/grade-99/?fips=48"

# By grade
"https://educationdata.urban.org/api/v1/school-districts/ccd/enrollment/2020/grade-3/"

# By race
"https://educationdata.urban.org/api/v1/school-districts/ccd/enrollment/2020/race/"

# By sex
"https://educationdata.urban.org/api/v1/school-districts/ccd/enrollment/2020/sex/"
```

### Finance

District financial data (revenues, expenditures).

```python
# All district finance data
"https://educationdata.urban.org/api/v1/school-districts/ccd/finance/2019/"

# Finance data for California districts
"https://educationdata.urban.org/api/v1/school-districts/ccd/finance/2019/?fips=6"

# Specific district finance
"https://educationdata.urban.org/api/v1/school-districts/ccd/finance/2019/?leaid=0600001"
```

## School Districts (SAIPE)

Small Area Income and Poverty Estimates.

```python
# Poverty estimates for all districts
"https://educationdata.urban.org/api/v1/school-districts/saipe/2020/"

# Poverty estimates for California districts
"https://educationdata.urban.org/api/v1/school-districts/saipe/2020/?fips=6"

# Multiple years
"https://educationdata.urban.org/api/v1/school-districts/saipe/?year=2018,2019,2020&fips=6"
```

## School Districts (EDFacts)

```python
# District assessments
"https://educationdata.urban.org/api/v1/school-districts/edfacts/assessments/2019/"

# District graduation rates
"https://educationdata.urban.org/api/v1/school-districts/edfacts/grad-rates/2019/"
```

## Colleges (IPEDS)

Integrated Postsecondary Education Data System.

### Directory

```python
# All institutions
"https://educationdata.urban.org/api/v1/college-university/ipeds/directory/2020/"

# Institutions in Massachusetts
"https://educationdata.urban.org/api/v1/college-university/ipeds/directory/2020/?fips=25"

# Public 4-year (sector=1)
"https://educationdata.urban.org/api/v1/college-university/ipeds/directory/2020/?sector=1"

# Private nonprofit 4-year (sector=2)
"https://educationdata.urban.org/api/v1/college-university/ipeds/directory/2020/?sector=2"

# Private for-profit 4-year (sector=3)
"https://educationdata.urban.org/api/v1/college-university/ipeds/directory/2020/?sector=3"

# Public 2-year (sector=4)
"https://educationdata.urban.org/api/v1/college-university/ipeds/directory/2020/?sector=4"

# HBCUs
"https://educationdata.urban.org/api/v1/college-university/ipeds/directory/2020/?hbcu=1"

# Tribal colleges
"https://educationdata.urban.org/api/v1/college-university/ipeds/directory/2020/?tribal_college=1"

# Degree-granting institutions
"https://educationdata.urban.org/api/v1/college-university/ipeds/directory/2020/?degree_granting=1"

# Specific institution by UNITID
"https://educationdata.urban.org/api/v1/college-university/ipeds/directory/2020/?unitid=166027"

# By control (1=public, 2=private nonprofit, 3=private for-profit)
"https://educationdata.urban.org/api/v1/college-university/ipeds/directory/2020/?inst_control=1"
```

**Sector values:**
- 0 = Administrative unit
- 1 = Public 4-year
- 2 = Private nonprofit 4-year
- 3 = Private for-profit 4-year
- 4 = Public 2-year
- 5 = Private nonprofit 2-year
- 6 = Private for-profit 2-year
- 7 = Public less-than-2-year
- 8 = Private nonprofit less-than-2-year
- 9 = Private for-profit less-than-2-year

### Enrollment

**Requires level_of_study in path.**

```python
# All enrollment
"https://educationdata.urban.org/api/v1/college-university/ipeds/enrollment-full-time-equivalent/2020/"

# Undergraduate enrollment
"https://educationdata.urban.org/api/v1/college-university/ipeds/enrollment-full-time-equivalent/2020/undergrad/"

# Graduate enrollment
"https://educationdata.urban.org/api/v1/college-university/ipeds/enrollment-full-time-equivalent/2020/grad/"

# By race
"https://educationdata.urban.org/api/v1/college-university/ipeds/fall-enrollment/2020/race/"

# By gender
"https://educationdata.urban.org/api/v1/college-university/ipeds/fall-enrollment/2020/sex/"

# Headcount enrollment
"https://educationdata.urban.org/api/v1/college-university/ipeds/enrollment-headcount/2020/"
```

### Graduation Rates

```python
# Overall graduation rates
"https://educationdata.urban.org/api/v1/college-university/ipeds/grad-rates/2020/"

# By race
"https://educationdata.urban.org/api/v1/college-university/ipeds/grad-rates/2020/race/"

# 200% time graduation rates
"https://educationdata.urban.org/api/v1/college-university/ipeds/grad-rates-200pct/2020/"

# Pell recipient graduation rates
"https://educationdata.urban.org/api/v1/college-university/ipeds/grad-rates-pell/2020/"
```

### Admissions

```python
# Admissions and test scores
"https://educationdata.urban.org/api/v1/college-university/ipeds/admissions-enrollment/2020/"

# Admissions requirements
"https://educationdata.urban.org/api/v1/college-university/ipeds/admissions-requirements/2020/"
```

### Costs and Financial Aid

```python
# Academic year tuition and fees
"https://educationdata.urban.org/api/v1/college-university/ipeds/academic-year-tuition/2020/"

# Room and board
"https://educationdata.urban.org/api/v1/college-university/ipeds/academic-year-room-and-board/2020/"

# Student financial aid
"https://educationdata.urban.org/api/v1/college-university/ipeds/sfa/2020/"

# Net price by income
"https://educationdata.urban.org/api/v1/college-university/ipeds/net-price/2020/"
```

### Institutional Characteristics

```python
# Student services
"https://educationdata.urban.org/api/v1/college-university/ipeds/student-services/2020/"

# Athletics
"https://educationdata.urban.org/api/v1/college-university/ipeds/athletics/2020/"

# Completions (degrees awarded)
"https://educationdata.urban.org/api/v1/college-university/ipeds/completions/2020/"

# Program completions by CIP code
"https://educationdata.urban.org/api/v1/college-university/ipeds/completions-cip/2020/"
```

### Finance

```python
# Institutional finance
"https://educationdata.urban.org/api/v1/college-university/ipeds/finance/2020/"

# Human resources
"https://educationdata.urban.org/api/v1/college-university/ipeds/hr/2020/"
```

## Colleges (Scorecard)

College Scorecard data.

```python
# Scorecard data
"https://educationdata.urban.org/api/v1/college-university/scorecard/earnings/2020/"

# Student loan repayment
"https://educationdata.urban.org/api/v1/college-university/scorecard/repayment/2020/"

# Default rates
"https://educationdata.urban.org/api/v1/college-university/scorecard/default/2020/"
```

## Colleges (FSA)

Federal Student Aid data.

```python
# Title IV program volume
"https://educationdata.urban.org/api/v1/college-university/fsa/program-volume/2020/"
```

## Combined Filters Examples

### Complex School Queries

```python
# Large urban charter high schools in California
"https://educationdata.urban.org/api/v1/schools/ccd/directory/2020/?fips=6&charter=1&school_level=3&urban_centric_locale=11,12"

# Title I magnet elementary schools
"https://educationdata.urban.org/api/v1/schools/ccd/directory/2020/?title_i_eligible=1&magnet=1&school_level=1"

# Schools in specific districts (multiple LEAIDs)
"https://educationdata.urban.org/api/v1/schools/ccd/directory/2020/?leaid=0600001,0600002,0600003"
```

### Complex College Queries

```python
# HBCUs with high graduation rates (need to filter after fetch)
"https://educationdata.urban.org/api/v1/college-university/ipeds/directory/2020/?hbcu=1"

# Public research universities in multiple states
"https://educationdata.urban.org/api/v1/college-university/ipeds/directory/2020/?sector=1&fips=6,36,48"

# Community colleges in California
"https://educationdata.urban.org/api/v1/college-university/ipeds/directory/2020/?fips=6&sector=4"
```

### Time Series Queries

```python
# California schools across multiple years
"https://educationdata.urban.org/api/v1/schools/ccd/directory/?year=2015,2016,2017,2018,2019,2020&fips=6"

# Enrollment trends
"https://educationdata.urban.org/api/v1/schools/ccd/enrollment/grade-99/?year=2015,2016,2017,2018,2019,2020&fips=6"
```

## Note on Data Fetching

URL patterns in this file document the endpoint path structure of the Education Data Portal.
For actual data fetching, use the mirror-based patterns in `./fetch-patterns.md` — no direct
API calls are used. These URL patterns remain useful for understanding dataset naming conventions
and constructing mirror file paths.
