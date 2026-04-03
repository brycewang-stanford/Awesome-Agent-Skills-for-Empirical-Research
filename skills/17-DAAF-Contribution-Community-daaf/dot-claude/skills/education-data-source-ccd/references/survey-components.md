# CCD Survey Components

The Common Core of Data consists of six major survey components, each collecting different types of information about public elementary and secondary education.

> **Variable Name Convention:** This document references both NCES source names (UPPERCASE, as used in NCES documentation and original data files) and Portal names (lowercase, as used in the Education Data Portal mirror). Portal names appear in parentheses where relevant. When writing code, always use the Portal lowercase names. See `variable-definitions.md` for complete Portal encoding tables.

## Directory

### School Directory

**Purpose**: Basic identifying information for every public school in the United States.

**Reporting Level**: Individual school

**Key Variables**:

| NCES Name | Portal Name | Description | Notes |
|-----------|-------------|-------------|-------|
| `NCESSCH` | `ncessch` | 12-character unique school identifier | State FIPS + LEA suffix + School ID |
| `SCH_NAME` | `school_name` | School name | As reported by state |
| `LSTREET1/2` | `street_location` | Physical address | Location address |
| `MSTREET1/2` | `street_mailing` | Mailing address | May differ from physical |
| `LCITY`, `LSTATE`, `LZIP` | `city_location`, `state_location`, `zip_location` | Physical location | |
| `PHONE` | `phone` | Main phone number | |
| `SCH_TYPE` | `school_type` | School type (1-5) | Regular, Special Ed, Vocational, Alternative, Program |
| `STATUS` | `school_status` | Operational status (1-8) | Continuing, Closed, New, Added, etc. |
| `CHARTER` | `charter` | Charter school indicator | Portal: `0=No, 1=Yes` (NOT `1=Yes, 2=No`) |
| `MAGNET` | `magnet` | Magnet school indicator | Portal: `0=No, 1=Yes` |
| `VIRTUAL` | `virtual` | Virtual school indicator | Portal: `0-3` integers; Added 2014-15 |
| `LOCALE` | `urban_centric_locale` | Urban-centric locale code | 11-43 codes (post-2006) |
| `TITLEI` | `title_i_status` | Title I eligible status | |
| `GSLO`, `GSHI` | `lowest_grade_offered`, `highest_grade_offered` | Lowest/highest grade offered | Portal: integers (see grade codes) |
| `LEVEL` | `school_level` | School level | Portal: integer codes |
| `LATCOD`, `LONCOD` | `latitude`, `longitude` | Latitude/longitude | Geocoded coordinates |

**School Status Codes** (`school_status`):

| Code | Status | Definition |
|------|--------|------------|
| 1 | Continuing | Operational, no change |
| 2 | Closed | No longer operating |
| 3 | New | Opened since last report |
| 4 | Added | Existed but wasn't previously reported |
| 5 | Changed Agency | Moved to different LEA |
| 6 | Inactive | Temporarily closed (at most 3 years) |
| 7 | Future | Scheduled to open within 2 years |
| 8 | Reopened | Was closed, now open again |

### LEA (District) Directory

**Purpose**: Basic identifying information for every local education agency.

**Reporting Level**: District/LEA

**Key Variables**:

| NCES Name | Portal Name | Description | Notes |
|-----------|-------------|-------------|-------|
| `LEAID` | `leaid` | 7-character unique LEA identifier | State FIPS + State-assigned ID; **Int64 in this dataset** |
| `LEA_NAME` | `lea_name` | District name | |
| `LEA_TYPE` | `agency_type` | Agency type (1-9) | Regular, Supervisory Union, Charter, etc. |
| `BOUND` | `boundary_change_indicator` | Agency status | Similar to school status |
| `LOCALE` | `urban_centric_locale` | Urban-centric locale code | Weighted average of school locales |
| `CONUM` | `county_code` | County FIPS code | 5-digit county identifier |
| `CONAME` | `county_name` | County name | |
| `GSLO`, `GSHI` | `lowest_grade_offered`, `highest_grade_offered` | Grade span offered | |
| `CSA` | `csa` | Combined Statistical Area | Census geography |
| `CBSA` | `cbsa` | Core Based Statistical Area | Census geography |

### State Directory

**Purpose**: State-level aggregate information.

**Reporting Level**: State Education Agency (SEA)

**Key Data**: State totals, contact information, coordinators.

---

## Membership

### Overview

Membership (enrollment) data represents student counts as of October 1 (or closest school day). This is the primary source for student enrollment statistics in public schools.

**Critical Note**: Use `grade=99` for totals rather than summing individual grades, as this captures ungraded students.

> **Portal Encoding:** Variables are lowercase (`enrollment`, `grade`, `race`, `sex`) and use integer codes. See `variable-definitions.md` for complete mappings.

### School-Level Membership

**Disaggregations Available**:

| Disaggregation | Portal Codes | Notes |
|----------------|--------------|-------|
| Grade | -1 (Pre-K), 0 (KG), 1-12, 15 (Ungraded), 99 (Total) | -1 = Pre-K, NOT missing |
| Race/Ethnicity | 1-7 (categories), 99 (Total) | Integers, not strings |
| Sex | 1 (Male), 2 (Female), 99 (Total) | |
| Combined | Grade × Race × Sex | Full cross-tabulation |

**Key Variables (Portal lowercase names)**:

| Variable | Description | Notes |
|----------|-------------|-------|
| `enrollment` | Student enrollment count | |
| `grade` | Grade level code | -1=Pre-K, 0=KG, 1-12, 99=Total |
| `race` | Race/ethnicity category | 1-7 integers, 99=Total |
| `sex` | Sex | 1=Male, 2=Female, 99=Total |

### Race/Ethnicity Categories (Portal Integer Codes, 2010+)

| Code | Category | Description |
|------|----------|-------------|
| `1` | White | Single race, non-Hispanic |
| `2` | Black or African American | Single race, non-Hispanic |
| `3` | Hispanic/Latino | Any race |
| `4` | Asian | Single race, non-Hispanic |
| `5` | American Indian/Alaska Native | Single race, non-Hispanic |
| `6` | Native Hawaiian/Pacific Islander | Single race, non-Hispanic |
| `7` | Two or More Races | Non-Hispanic |
| `99` | Total | All races combined |

### LEA-Level Membership

Same structure as school-level, aggregated to district.

**Important Change (2017-18)**: Guidance for reporting LEA-level membership changed. Prior to 2017-18, states could report LEA totals that differed from school sums. Starting 2017-18, LEA totals should equal sum of schools.

### Special Populations

Additional counts collected at school level:

| Variable (Portal) | Description | Notes |
|-------------------|-------------|-------|
| `free_lunch` | Free lunch eligible students | NSLP participation |
| `reduced_lunch` | Reduced-price lunch eligible | NSLP participation |
| `free_or_reduced_price_lunch` | Total free/reduced lunch | Sum or direct count |
| `direct_certification` | Directly certified students | Auto-enrolled without application |

> **Note:** Portal uses lowercase with underscores. Original NCES variable names (FRELCH, REDLCH, etc.) are transformed.

**FRPL Complexity**: Starting 2012-13, Community Eligibility Provision (CEP) allows high-poverty schools to provide free meals to all students. Schools participating in CEP may report 100% eligibility, making FRPL less useful as a poverty proxy. Use MEPS or SAIPE for poverty measurement instead.

---

## Staffing

### Overview

Staff data reports full-time equivalent (FTE) counts by professional category.

**Reporting Level**: School, LEA, State

### Staff Categories

| Category | Description | Includes |
|----------|-------------|----------|
| Teachers | Instructional staff | All grade levels and subjects |
| Instructional Aides | Support for teachers | Paraprofessionals |
| Instructional Coordinators/Supervisors | Curriculum staff | Not school-based |
| Guidance Counselors | Student services | School counselors |
| Librarians/Media Specialists | Library staff | Professional library services |
| School Administrators | Principals, APs | School-level leadership |
| School Admin Support | Office staff | Secretaries, clerks |
| Student Support Services | Other student services | Health, social work, psychology |
| LEA Administrators | Central office | Superintendents, directors |
| LEA Admin Support | Central office support | Business office, data processing |
| All Other Support | Remaining staff | Maintenance, food service, transportation |

### Key Variables

| NCES Name | Portal Name | Description | Notes |
|-----------|-------------|-------------|-------|
| `TEACHERS` | `teachers_total_fte` | FTE classroom teachers | |
| `TOTSTAFF` | `staff_total_fte` | Total FTE staff | |
| `STUTERATIO` | (calculated) | Student/teacher ratio | Calculated from membership/teachers |

> **Note:** Staffing variables are available in the Districts Directory dataset (`ccd/school-districts_lea_directory`), not as a separate dataset in the Portal mirrors. The Districts Directory includes detailed FTE breakdowns by staff category (e.g., `teachers_elementary_fte`, `guidance_counselors_total_fte`, etc.).

### Data Quality Notes

- **FTE vs. Headcount**: CCD reports FTE (full-time equivalent), not headcount
- **State Variation**: Definition of FTE may vary by state
- **Assignment Challenges**: Teachers with multiple assignments may be counted differently
- **Missing Data**: Staff data has higher missing rates than membership

---

## Finance

The CCD includes two major finance surveys collecting revenue and expenditure data.

### National Public Education Financial Survey (NPEFS)

**Purpose**: State-level aggregate finance data

**Reporting Level**: State totals

**Key Categories**:

**Revenue Sources**:
- Federal revenue
- State revenue
- Local revenue (property tax, other local)
- Intermediate sources

**Expenditure Functions**:
- Instruction
- Support services (student, instructional staff, administration)
- Operations and maintenance
- Student transportation
- Other

**Years Available**: 1989-present

**Lag**: Typically 1-2 years behind current school year

### School District Finance Survey (F-33)

**Purpose**: District-level detailed finance data

**Reporting Level**: Individual LEAs

**Universe**: All local education agencies with students

**Key Variables**:

| Category | NCES Name | Portal Name | Description |
|----------|-----------|-------------|-------------|
| Revenue | `TFEDREV` | `rev_fed_total` | Federal revenue total |
| Revenue | `TSTREV` | `rev_state_total` | State revenue total |
| Revenue | `TLOCREV` | `rev_local_total` | Local revenue total |
| Revenue | — | `rev_total` | Total all revenue |
| Expenditure | `TCURINST` | `exp_current_instruction_total` | Current instruction expenditure |
| Expenditure | — | `exp_total` | Total expenditure |
| Expenditure | — | `exp_current_elsec_total` | Current ELSEC expenditure |
| Debt | — | `debt_longterm_outstand_end_FY` | Outstanding long-term debt |
| Capital | `TCAPOUT` | `outlay_capital_total` | Capital outlay total |

> **Note:** The Finance dataset has 163 columns. See the codebook or actual data for the full list. The NCES variable names shown above are approximate mappings -- use the Portal names in code.


**Key Measures**:

| Measure | Description | Notes |
|---------|-------------|-------|
| Total Revenue | All sources combined | Federal + State + Local |
| Current Expenditure | Operating costs | Excludes capital, debt service |
| Per-Pupil Expenditure | Expenditure / Students | Various calculations available |
| Instruction Expenditure | Teaching costs | Salaries, benefits, materials |

**Lag**: Typically 2 years behind current school year

**Note**: Finance data definitions follow the Financial Accounting for Local and State School Systems (FALSSS) handbook standards.

---

## Dropout and Completers

### Overview

Data on students leaving school without completing, and those who complete.

**Reporting Level**: LEA, State

**Key Distinctions**:

| Term | Definition |
|------|------------|
| Dropout | Left school without completing, not enrolled elsewhere |
| Diploma Recipient | Received standard high school diploma |
| Other Completer | Certificate of attendance, alternative credential |
| Graduation Rate | Percentage completing with diploma in cohort |

### Dropout Types

**Event Dropout Rate**: Students who dropped out in a single year, divided by enrollment.

**Status Dropout Rate**: Percentage of an age group not enrolled and without credential (point-in-time measure).

**CCD vs. CPS**: CCD covers grades 7-12; Current Population Survey covers grades 10-12. Rates are not directly comparable.

### Graduation Rate Measures

| Measure | Calculation | Notes |
|---------|-------------|-------|
| AFGR | Averaged Freshman Graduation Rate | Uses enrollment approximation |
| ACGR | Adjusted Cohort Graduation Rate | Tracks actual cohort | Required under ESEA |

**ACGR** (Adjusted Cohort Graduation Rate): Tracks a cohort of first-time 9th graders, adjusting for transfers in/out, and calculates percentage receiving diploma within 4 years (or extended time).

### Key Variables

| Variable | Description |
|----------|-------------|
| `DROPOUT` | Count of dropouts |
| `DIPLOMA` | Standard diploma recipients |
| `OTHCOMP` | Other completers |
| `GRADRATE` | Graduation rate percentage |

### Data Quality Concerns

- **State Definitions Vary**: Each state may define "dropout" differently
- **GED Treatment**: States handle GED completers differently
- **Transfer Tracking**: Difficult to distinguish transfers from dropouts
- **Homeless/Mobile Students**: Challenging to track

**Recommendation**: Use dropout/graduation data for within-state comparisons only, not cross-state comparisons without understanding definitional differences.

---

## Data File Structure

### NCES Original File Formats (Source Background)

> **Note:** The following describes NCES original file formats, NOT the Portal mirror format. When using this system, you access data via the Portal mirrors (parquet or CSV) which have already been reformatted into a consistent long-format structure with lowercase variable names and integer codes. This section is included for historical context only.

Starting 2016-17, NCES CCD files are published in **long format** (one row per observation with disaggregation variables as columns) rather than wide format. The Portal mirrors use long format for all years.

**NCES File Naming Convention** (original source files):

```
ccd_[level]_[year]_[version].csv

Examples:
ccd_sch_029_2223_w_1a.csv  (School membership, 2022-23, version 1a)
ccd_lea_052_2223_l_1a.csv  (LEA directory, 2022-23, long format, version 1a)
```

**NCES Version Codes**:

| Code | Meaning |
|------|---------|
| 0a, 0b, ... | Preliminary releases |
| 1a, 1b, ... | Provisional (quality-reviewed) releases |

### Portal Mirror Format

In the Portal mirrors, CCD data is available as:
- **Parquet files** (HuggingFace, primary): columnar, compressed, schema embedded
- **CSV files** (Urban Institute, fallback): large files, use lazy loading

All data uses lowercase column names, integer-coded categoricals, and a consistent long format. See `datasets-reference.md` for canonical paths and `fetch-patterns.md` for fetch code patterns.

### Release Schedule

1. **Preliminary Directory**: ~6-8 months after school year end (e.g., July for previous fall data)
2. **Preliminary Universe**: ~10-12 months after school year end
3. **Provisional Files**: ~12-18 months after school year end
4. **Finance Data**: ~24-30 months after fiscal year end
