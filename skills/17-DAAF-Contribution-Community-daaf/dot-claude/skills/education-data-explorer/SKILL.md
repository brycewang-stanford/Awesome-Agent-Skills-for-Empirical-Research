---
name: education-data-explorer
description: >-
  Discovers education data from Urban Institute Portal: endpoints, variables, year coverage, join keys (CCD, IPEDS, CRDC, Scorecard, SAIPE). Use to map questions to data. Load before education-data-query — discovery here, download there.
metadata:
  audience: research-planner
  domain: data-access
---

# Education Data Explorer

Discovers available education data from the Urban Institute Education Data Portal: endpoints, variables, year coverage, and join keys for schools, districts, and colleges (CCD, IPEDS, CRDC, Scorecard, SAIPE, and more). Use during discovery and scoping phases when identifying what data exists, mapping research questions to endpoints, or resolving variable name discrepancies between documentation and actual field names. Load before education-data-query — this skill covers discovery; education-data-query handles the download.

Discover available education data from the Urban Institute Education Data Portal for research planning and query design.

## What is the Education Data Portal?

- **Comprehensive education data** from Urban Institute - free and publicly available
- **Three data levels**: schools, school-districts, college-university
- **Multiple data sources**: CCD, IPEDS, CRDC, College Scorecard, EDFacts, SAIPE, FSA, MEPS, PSEO, etc.
- **Coverage**: 1980-2023 depending on source
- **Access**: Mirror downloads (parquet/CSV) via `education-data-query` skill
- **Documentation**: https://educationdata.urban.org/documentation/
- **Curation layer, not a direct pass-through**: The EDP standardizes data from original federal sources with lowercase variable names, integer-encoded categoricals, and uniform missing value codes (`-1`, `-2`, `-3`)
- **Coverage varies by source**: Some sources are fully mirrored; others are partially mirrored with only a subset of variables or datasets available. See individual `education-data-source-*` skills for source-specific coverage details

> **Skill Provenance Note:** Each `*-data-source-*` skill includes
> `provenance.skill_last_updated` in its frontmatter. When exploring data
> sources during Stage 2, note the provenance dates of any skills you
> reference — if more than a few months old, flag this in your findings
> so the orchestrator can consider re-verifying with data-ingest.

> **Note:** This workflow uses mirror-based file downloads, not paginated API calls. See `education-data-query` skill for fetch patterns and `datasets-reference.md` for file paths.

## Reference File Structure

| File | Purpose | When to Read |
|------|---------|--------------|
| `schools-endpoints.md` | All school-level endpoints and variables | Researching K-12 schools |
| `districts-endpoints.md` | All district-level endpoints and variables | Researching school districts |
| `colleges-endpoints.md` | All college-level endpoints and variables | Researching higher education |
| `variable-codes.md` | Code values for states, grades, race, etc. | Interpreting or filtering data |
| `metadata-api.md` | Programmatic endpoint/variable discovery | Dynamic exploration |

## Decision Trees

### What data level do I need?

```
What entity am I researching?
├─ Individual K-12 schools → schools level
│   └─ See ./references/schools-endpoints.md
├─ School districts / LEAs → school-districts level
│   └─ See ./references/districts-endpoints.md
├─ Colleges / Universities → college-university level
│   └─ See ./references/colleges-endpoints.md
└─ Not sure
    ├─ Need school-specific data (discipline, AP, demographics) → schools
    ├─ Need aggregate district data (finance, poverty) → school-districts
    └─ Need postsecondary data (enrollment, aid, outcomes) → college-university
```

### What topic am I researching?

```
Research topic?
├─ Enrollment / Demographics
│   ├─ K-12 public schools → CCD enrollment endpoints
│   ├─ Civil rights indicators → CRDC enrollment
│   └─ Colleges → IPEDS enrollment
├─ School Finance
│   ├─ District revenue/expenditure → CCD finance
│   └─ College finance → IPEDS finance
├─ Student Outcomes
│   ├─ K-12 assessments → EDFacts
│   ├─ Graduation rates (K-12) → EDFacts
│   ├─ College completion → IPEDS completions
│   └─ Post-college earnings → College Scorecard
├─ Student Aid / Loans
│   ├─ College financial aid → IPEDS aid
│   ├─ Federal loans/grants → FSA
│   └─ Debt/repayment → College Scorecard
├─ Discipline / Civil Rights
│   └─ K-12 discipline, harassment, restraint → CRDC
├─ Poverty Estimates
│   └─ District-level → SAIPE
└─ Directory / Location
    ├─ K-12 schools → CCD directory
    ├─ Districts → CCD directory
    └─ Colleges → IPEDS directory
```

### How do I find specific variables?

```
Finding variables?
├─ Know the endpoint → Check reference file for variable list
├─ Know the topic → Use topic index below
├─ Need to search programmatically → See ./references/metadata-api.md
└─ Need code definitions → See ./references/variable-codes.md
```

## Quick Reference: Data Levels

| Level | Key Sources | Primary ID | ID Format |
|-------|-------------|------------|-----------|
| schools | CCD, CRDC, EDFacts, MEPS, NHGIS | `ncessch` | 12-char string |
| school-districts | CCD, SAIPE, EDFacts | `leaid` | 7-char string |
| college-university | IPEDS, Scorecard, FSA, PSEO, EADA | `unitid` | 6-digit integer |

## Quick Reference: Data Sources

| Source | Level | Description | Years |
|--------|-------|-------------|-------|
| CCD | Schools, Districts | Public K-12 directory, enrollment, finance | 1986-2023 |
| CRDC | Schools | Civil rights indicators, discipline, AP courses | 2011-2021 |
| EDFacts | Schools, Districts | Assessments, graduation rates | 2009-2020 |
| IPEDS | Colleges | Enrollment, completions, finance, institutional data | 1980-2023 |
| College Scorecard | Colleges | Earnings, debt, student outcomes | 1996-2020 |
| SAIPE | Districts | Census poverty estimates for school-age children | 1995-2023 |
| FSA | Colleges | Federal student aid, loans, grants, 90/10 | 1999-2021 |
| MEPS | Schools | School poverty measure | 2006-2019 |
| NHGIS | Schools | Census geography crosswalks | 1990, 2000, 2010, 2020 |

## Quick Reference: Common Endpoints

### Schools

| Endpoint | Description |
|----------|-------------|
| `/schools/ccd/directory/{year}/` | School directory (location, type, enrollment) |
| `/schools/ccd/enrollment/{year}/{grade}/` | Enrollment by grade |
| `/schools/crdc/discipline/{year}/` | Discipline incidents |
| `/schools/crdc/ap-ib-enrollment/{year}/race/sex/` | AP/IB enrollment (requires disaggregation) |
| `/schools/edfacts/assessments/{year}/{grade}/` | Assessment results |

### Districts

| Endpoint | Description |
|----------|-------------|
| `/school-districts/ccd/directory/{year}/` | District directory |
| `/school-districts/ccd/enrollment/{year}/{grade}/` | District enrollment |
| `/school-districts/ccd/finance/{year}/` | Revenue and expenditure |
| `/school-districts/saipe/{year}/` | Poverty estimates |

### Colleges

| Endpoint | Description |
|----------|-------------|
| `/college-university/ipeds/directory/{year}/` | Institution directory |
| `/college-university/ipeds/admissions-enrollment/{year}/` | Admissions data |
| `/college-university/ipeds/enrollment-full-time-equivalent/{year}/` | FTE enrollment |
| `/college-university/ipeds/fall-enrollment/{year}/{level}/` | Fall enrollment |
| `/college-university/ipeds/graduation-rates/{year}/` | Graduation rates |
| `/college-university/scorecard/earnings/{year}/` | Post-college earnings |

## Exploration Workflow

Follow these steps to identify data for a research question:

1. **Identify data level**
   - Schools: individual K-12 school records
   - Districts: school district / LEA records
   - Colleges: postsecondary institution records

2. **Identify relevant data source(s)**
   - Use the data sources table above
   - Multiple sources may be needed (e.g., CCD + CRDC)

3. **Check available endpoints**
   - Read the appropriate reference file
   - Note endpoint URL pattern and variables

4. **Review variables and filters**
   - Check variable lists in reference files
   - Note which variables can be used as filters

5. **Check years available**
   - Each endpoint has different year coverage
   - Use metadata API to get exact years

6. **Understand source context** (RECOMMENDED)
   - Load the appropriate `education-data-source-*` skill for deep context
   - Understand data collection methodology and limitations
   - Review variable definitions and coding schemes

7. **Plan query**
   - Load `education-data-query` skill for query construction
   - Or use metadata API to build query programmatically

## URL Pattern Structure

All endpoints follow this pattern:

```
/api/v1/{level}/{source}/{topic}/{year}/[{disaggregation}/]
```

Examples:
- `/api/v1/schools/ccd/directory/2022/`
- `/api/v1/schools/ccd/enrollment/2022/grade-5/`
- `/api/v1/schools/ccd/enrollment/2022/grade-5/race/`
- `/api/v1/school-districts/ccd/finance/2021/`
- `/api/v1/college-university/ipeds/fall-enrollment/2022/undergraduate/`

## Filtering

### Query Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `fips` | State FIPS code | `?fips=6` (California) |
| `leaid` | District ID | `?leaid=0600001` |
| `ncessch` | School ID | `?ncessch=060000100001` |
| `unitid` | College ID | `?unitid=110635` |
| `year` | Filter by year | `?year=2022` |

### Response Format

```json
{
  "count": 12345,
  "next": "https://educationdata.urban.org/api/v1/...?page=2",
  "previous": null,
  "results": [
    {"ncessch": "...", "school_name": "...", ...},
    ...
  ]
}
```

## Cross-Reference to Related Skills

| Skill | Purpose | When to Use |
|-------|---------|-------------|
| `education-data-query` | Download data from mirrors | After identifying endpoints/variables |
| `education-data-context` | Interpret data, understand limitations | After retrieving data |

### Deep-Dive Data Source Skills

For comprehensive understanding of each data source beyond the portal documentation, load the appropriate source-specific skill:

| Skill | Data Source | Key Topics |
|-------|-------------|------------|
| `education-data-source-ccd` | Common Core of Data | K-12 directory, enrollment, finance, staffing surveys |
| `education-data-source-crdc` | Civil Rights Data Collection | Discipline, harassment, course access, civil rights context |
| `education-data-source-saipe` | Small Area Income & Poverty | District poverty estimates, model methodology |
| `education-data-source-edfacts` | EDFacts | State assessments, graduation rates, accountability |
| `education-data-source-ipeds` | IPEDS | College enrollment, graduation, finance, completions |
| `education-data-source-scorecard` | College Scorecard | Post-college earnings, debt, repayment |
| `education-data-source-nhgis` | NHGIS | Census geography, demographic crosswalks |
| `education-data-source-fsa` | Federal Student Aid | Pell, loans, financial responsibility, 90/10 |
| `education-data-source-nacubo` | NACUBO | College endowment data |
| `education-data-source-nccs` | NCCS | Nonprofit data for private colleges |
| `education-data-source-meps` | MEPS | Model-based school poverty (superior to FRPL) |
| `education-data-source-eada` | EADA | College athletics equity data |
| `education-data-source-campus-safety` | Campus Safety | Campus crime, Clery Act data |
| `education-data-source-pseo` | PSEO | Post-graduation employment outcomes |

**When to load source skills:**
- Need deeper understanding of data collection methodology
- Encountering unexpected values or patterns
- Planning analysis that requires understanding source limitations
- Working with less common data elements not covered in this skill

## Topic Index

| Topic | Reference File | Section |
|-------|---------------|---------|
| School directory | `schools-endpoints.md` | CCD Directory |
| School enrollment | `schools-endpoints.md` | CCD Enrollment |
| Discipline data | `schools-endpoints.md` | CRDC Discipline |
| AP/IB courses | `schools-endpoints.md` | CRDC AP-IB-GT |
| K-12 assessments | `schools-endpoints.md` | EDFacts |
| District directory | `districts-endpoints.md` | CCD Directory |
| District finance | `districts-endpoints.md` | CCD Finance |
| District poverty | `districts-endpoints.md` | SAIPE |
| College directory | `colleges-endpoints.md` | IPEDS Directory |
| College enrollment | `colleges-endpoints.md` | IPEDS Enrollment |
| College graduation | `colleges-endpoints.md` | IPEDS Graduation |
| Financial aid | `colleges-endpoints.md` | IPEDS Aid, FSA |
| Post-college earnings | `colleges-endpoints.md` | Scorecard |
| Student debt | `colleges-endpoints.md` | Scorecard, FSA |
| State FIPS codes | `variable-codes.md` | State FIPS |
| Grade codes | `variable-codes.md` | Grade Codes |
| Race/ethnicity codes | `variable-codes.md` | Race Codes |
| Locale codes | `variable-codes.md` | Urban-Centric Locale |
| Programmatic discovery | `metadata-api.md` | All |

## Example: Planning a Research Query

**Research question**: "What is the relationship between school poverty and AP course offerings in California high schools?"

1. **Data level**: Schools (individual school records)

2. **Data sources needed**:
   - CRDC for AP course data
   - MEPS or CCD for poverty measure

3. **Endpoints**:
   - `/schools/crdc/ap-ib-enrollment/{year}/race/sex/` - AP enrollment (requires disaggregation)
   - `/schools/meps/{year}/` - School poverty measure

4. **Key variables**:
   - `ncessch` - school identifier (for joining)
   - `fips=6` - California filter
   - AP enrollment variables from CRDC
   - Poverty measure from MEPS

5. **Years**: Check overlap (CRDC: 2011-2021, MEPS: 2006-2019)

6. **Next step**: Load `education-data-query` skill to construct the actual API calls

## Common Pitfalls

- **Year coverage varies**: Always check years available for each endpoint
- **Different ID formats**: `ncessch` (12-char), `leaid` (7-char), `unitid` (6-digit)
- **Disaggregation in URL**: Grade, race, sex are often URL path components, not query params
- **Missing data codes**: -1, -2, -3 have specific meanings (see variable-codes.md)

## Pre-Query Validation

### CRITICAL: Variable Name Discrepancies

The Education Data Portal API often uses **different variable names** than documentation suggests. **Always fetch a sample first:**

```python
# Test query to verify actual column names
response = requests.get(
    "https://educationdata.urban.org/api/v1/college-university/ipeds/directory/2023/"
)
data = response.json()
print("Actual columns:", list(data['results'][0].keys()))
```

**Known discrepancies:**

| Documented | Actual API Field | Endpoint |
|------------|------------------|----------|
| `inst_level` | `institution_level` | IPEDS Directory |
| `applicants_total` | `number_applied` | IPEDS Admissions |
| `admissions_total` | `number_admitted` | IPEDS Admissions |
| `grad_rate_150pct` | `completion_rate_150pct` | IPEDS Graduation Rates |
| `school_poverty` | `meps_poverty_pct` | MEPS |
| `population_5_17_poverty` | `est_population_5_17_poverty` | SAIPE |

See the relevant `education-data-source-*` skill for comprehensive variable mappings per source.

### Metadata API Limitations

The metadata API has undocumented limitations:
- `?section=schools` **works** to filter by data level
- `?source=ipeds` does **NOT work** - filter client-side instead
- Response field names differ: `source` is actually `class_name`, `source_name` is actually `label`

## Data Source Details

Quick summaries below. For comprehensive documentation including methodology, variable definitions, data quality issues, and historical changes, load the corresponding `education-data-source-*` skill.

### CCD (Common Core of Data)

**Coverage**: All public elementary and secondary schools and districts in the U.S.

| Topic | Schools | Districts |
|-------|---------|-----------|
| Directory | Yes | Yes |
| Enrollment | Yes (by grade, race, sex) | Yes (by grade, race, sex) |
| Finance | No | Yes (revenue, expenditure) |

**Key Variables**:
- `ncessch`: 12-character NCES school ID
- `leaid`: 7-character NCES district ID
- `enrollment`: Total enrollment count
- `free_or_reduced_price_lunch`: FRPL-eligible students (poverty proxy)
- `charter`: Charter school indicator
- `urban_centric_locale`: Urban/suburban/town/rural classification

**Deep dive**: Load `education-data-source-ccd` for survey components, data collection process, variable coding, state variations, and historical changes (e.g., 2006 locale code revision, 2010 race category changes).

### CRDC (Civil Rights Data Collection)

**Coverage**: Biennial survey of public schools (2011, 2013, 2015, 2017, 2020, 2021)

**Topics**:
- Discipline (suspensions, expulsions, arrests)
- Chronic absenteeism
- Harassment and bullying
- Restraint and seclusion
- Advanced courses (AP, IB, gifted)
- Course offerings
- Teacher qualifications
- Retention
- COVID impacts (2020 only)

**Key Feature**: Disaggregation by race, sex, disability, and LEP status

**Deep dive**: Load `education-data-source-crdc` for civil rights legal context (Title VI, IX, Section 504), collection methodology, underreporting issues, and year-to-year changes.

### EDFacts

**Coverage**: State assessment and accountability data

**Topics**:
- Assessment proficiency rates (reading, math)
- Graduation rates (4-year adjusted cohort)

**Key Feature**: Data available by special populations (disability, economically disadvantaged, LEP, homeless, migrant, foster care)

**CRITICAL**: State assessment scores CANNOT be compared across states (different tests, cut scores).

**Deep dive**: Load `education-data-source-edfacts` for ESSA/NCLB accountability context, why cross-state comparison is invalid, ACGR methodology, and subgroup reporting rules.

### IPEDS (Integrated Postsecondary Education Data System)

**Coverage**: All Title IV-eligible postsecondary institutions

**Topics**:
- Institutional characteristics and directory
- Admissions and enrollment
- Student charges (tuition, fees, room, board)
- Financial aid
- Finance (revenue, expenditure, assets)
- Graduation rates
- Completions (degrees awarded by CIP code)
- Human resources (salaries, faculty)

**Key Variables**:
- `unitid`: 6-digit IPEDS institution ID
- `inst_control`: 1=Public, 2=Private nonprofit, 3=Private for-profit
- `institution_level`: 1=Less-than-2-year, 2=2-year, 4=4-year (no code 3)
- `hbcu`: Historically Black college indicator

**Deep dive**: Load `education-data-source-ipeds` for critical graduation rate limitations (first-time full-time only), GASB vs FASB finance accounting, survey components, and identifier changes.

### College Scorecard

**Coverage**: Title IV institutions with outcome data

**Topics**:
- Post-college earnings (6 and 10 years after entry)
- Student debt and repayment
- Default rates
- Completion rates by income level

**Key Feature**: Links education to labor market outcomes

**CRITICAL**: Only covers Title IV aid recipients (selection bias toward lower-income students).

**Deep dive**: Load `education-data-source-scorecard` for earnings methodology (IRS data), population coverage limitations, suppression rules, and field-of-study data.

### SAIPE (Small Area Income and Poverty Estimates)

**Coverage**: Census Bureau poverty estimates for school districts

**Key Variables**:
- `population_5_17_poverty`: Children 5-17 in poverty
- `population_5_17_poverty_pct`: Percent in poverty
- `median_household_income`: District median income

**Deep dive**: Load `education-data-source-saipe` for model-based estimation methodology, confidence intervals (not available at district level), and comparison to other poverty measures.

### FSA (Federal Student Aid)

**Coverage**: Title IV institutions receiving federal aid

**Topics**:
- Pell grants
- Direct loans (subsidized, unsubsidized, PLUS)
- Campus-based aid (Perkins, work-study)
- Financial responsibility scores
- 90/10 revenue (for-profit institutions)

**Deep dive**: Load `education-data-source-fsa` for Title IV program details, financial responsibility composite scores, and 90/10 rule compliance.

### Additional Data Sources

| Source | Coverage | Deep Dive Skill |
|--------|----------|-----------------|
| MEPS | School-level poverty estimates (superior to FRPL for cross-state comparison) | `education-data-source-meps` |
| NHGIS | Census geography crosswalks for schools | `education-data-source-nhgis` |
| NACUBO | College endowment data | `education-data-source-nacubo` |
| NCCS | Nonprofit data for private colleges (Form 990) | `education-data-source-nccs` |
| EADA | College athletics equity data | `education-data-source-eada` |
| Campus Safety | Campus crime statistics (Clery Act) | `education-data-source-campus-safety` |
| PSEO | Post-graduation employment outcomes | `education-data-source-pseo` |

## Joining Data Across Sources

### School-Level Joins

Join school data across sources using `ncessch`:

| Source 1 | Source 2 | Join Key | Use Case |
|----------|----------|----------|----------|
| CCD | CRDC | `ncessch` | Enrollment + discipline |
| CCD | EDFacts | `ncessch` | Directory + assessments |
| CCD | MEPS | `ncessch` | Enrollment + poverty |
| CRDC | MEPS | `ncessch` | AP courses + poverty |

**Note**: Match on `year` when joining (years may not align perfectly)

### District-Level Joins

Join district data using `leaid`:

| Source 1 | Source 2 | Join Key | Use Case |
|----------|----------|----------|----------|
| CCD Directory | CCD Finance | `leaid` | Characteristics + spending |
| CCD | SAIPE | `leaid` | Enrollment + poverty |
| CCD | EDFacts | `leaid` | Enrollment + outcomes |

### College-Level Joins

Join college data using `unitid`:

| Source 1 | Source 2 | Join Key | Use Case |
|----------|----------|----------|----------|
| IPEDS Directory | IPEDS Finance | `unitid` | Characteristics + finance |
| IPEDS | Scorecard | `unitid` | Enrollment + earnings |
| IPEDS | FSA | `unitid` | Enrollment + aid data |

## Disaggregation Patterns

### URL Path Disaggregation

Some disaggregations are part of the URL path:

```
/schools/ccd/enrollment/{year}/{grade}/           # By grade
/schools/ccd/enrollment/{year}/{grade}/race/      # By grade and race
/schools/ccd/enrollment/{year}/{grade}/race/sex/  # By grade, race, and sex
```

### Query Parameter Disaggregation

Other filters are query parameters:

```
?fips=6                    # California only
?charter=1                 # Charter schools only
?school_level=3            # High schools only
?urban_centric_locale=11   # Large cities only
```

### Available Disaggregations by Source

| Source | Grade | Race | Sex | Disability | Econ Status | LEP |
|--------|-------|------|-----|------------|-------------|-----|
| CCD | Yes | Yes | Yes | No | No | No |
| CRDC | No | Yes | Yes | Yes | No | Yes |
| EDFacts | Yes | Yes | Yes | Yes | Yes | Yes |
| IPEDS | Level | Yes | Yes | No | No | No |

## Year Coverage Quick Reference

| Source | Earliest | Latest | Update Frequency |
|--------|----------|--------|------------------|
| CCD Directory | 1986 | 2023 | Annual |
| CCD Finance | 1989 | 2021 | Annual (2-year lag) |
| CRDC | 2011 | 2021 | Biennial |
| EDFacts | 2009 | 2020 | Annual |
| IPEDS | 1980 | 2023 | Annual |
| Scorecard | 1996 | 2020 | Annual |
| SAIPE | 1995 | 2023 | Annual |
| FSA | 1999 | 2021 | Annual |

## Example Research Scenarios

| Scenario | Data Sources | Key Variables |
|----------|--------------|---------------|
| Charter vs traditional school outcomes | CCD directory + EDFacts assessments | `charter`, `read_test_pct_prof_midpt` |
| College affordability by income | IPEDS directory + net-price-by-income | `inst_control`, `income_level`, `avg_net_price` |
| Discipline disparities by race | CRDC discipline + enrollment (by race) | `race`, `oss_one`, `expulsions_*` |
| Spending and graduation rates | CCD finance + EDFacts grad-rates | `exp_current_per_pupil`, `grad_rate_midpt` |
| School poverty and AP access | CRDC ap-ib-enrollment + MEPS | `ap_enrollment`, `meps_poverty_pct` |
| College earnings by major | IPEDS completions + Scorecard earnings | `cip_code`, `earn_median_wne_p10` |
