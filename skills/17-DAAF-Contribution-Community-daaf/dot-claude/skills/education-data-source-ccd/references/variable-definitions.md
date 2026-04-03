# CCD Variable Definitions

Comprehensive reference for key CCD variables, coding schemes, and special values.

> **Codebook Authority:** The variable definitions in this document are summaries for convenience.
> The authoritative source for variable names, codes, and definitions is the codebook `.xls` file
> available in the data mirrors. Use `get_codebook_url("ccd/codebook_schools_ccd_directory")` from `fetch-patterns.md`
> to download the codebook. If this document contradicts the codebook, trust the codebook and
> flag the discrepancy.

> **CRITICAL: Portal vs NCES Raw File Encoding**
>
> This document describes **Education Data Portal** integer encodings, which differ from NCES raw file string codes. The Portal converts categorical variables to integers for consistency across sources. All Portal column names are **lowercase** with underscores.
>
> | Context | Grade Pre-K | Kindergarten | Total | Race White |
> |---------|-------------|--------------|-------|------------|
> | **Portal (integers)** | `-1` | `0` | `99` | `1` |
> | NCES raw files (strings) | `PK` | `KG` | varies | `WH` |
>
> **Semantic trap:** In enrollment data, `grade = -1` means **Pre-K**, NOT missing! Missing data uses the standard codes only for `numeric` format variables.
>
> Verify these codes against the live codebook. Use `get_codebook_url()` from `fetch-patterns.md`.

## Identifiers

### School ID (`ncessch`)

**Portal column name:** `ncessch` (lowercase)
**NCES source name:** NCESSCH

**Format**: 12 characters (when String) or equivalent integer

**Structure**:
```
[State FIPS: 2 digits][LEA Suffix: 5 digits][School ID: 5 digits]
Example: 010000100100
         01      = Alabama (State FIPS)
         00001   = LEA suffix within state
         00100   = School ID within LEA
```

> **Type Warning:** `ncessch` is String in the Schools Directory dataset (preserving leading zeros)
> but Int64 in the Schools Enrollment dataset. Always check dtype before joining.
> An additional column `ncessch_num` (always Int64) exists in some datasets as a numeric equivalent.

**Characteristics**:
- Assigned by NCES when school first reported
- Generally stable across years
- May change due to: school closure/reopening, district change, merger, reporting corrections

**ID Stability Checks**:
- NCES provides crosswalk files for ID changes
- Always verify ID continuity before building longitudinal panels

### LEA/District ID (`leaid`)

**Portal column name:** `leaid` (lowercase)
**NCES source name:** LEAID

**Format**: 7 characters (when String) or equivalent integer

**Structure**:
```
[State FIPS: 2 digits][State-assigned: 5 digits]
Example: 0100001
         01    = Alabama (State FIPS)
         00001 = State-assigned district ID
```

> **Type Warning:** `leaid` is Int64 in the Districts Directory and District Enrollment datasets
> but String in the Schools Directory and District Finance datasets. Always check dtype and
> cast as needed when joining across datasets.

**When LEAID Changes**:
- District merger
- District split
- Annexation
- Reporting corrections

### State FIPS Codes

| Code | State | Code | State | Code | State |
|------|-------|------|-------|------|-------|
| 01 | Alabama | 18 | Indiana | 35 | New Mexico |
| 02 | Alaska | 19 | Iowa | 36 | New York |
| 04 | Arizona | 20 | Kansas | 37 | North Carolina |
| 05 | Arkansas | 21 | Kentucky | 38 | North Dakota |
| 06 | California | 22 | Louisiana | 39 | Ohio |
| 08 | Colorado | 23 | Maine | 40 | Oklahoma |
| 09 | Connecticut | 24 | Maryland | 41 | Oregon |
| 10 | Delaware | 25 | Massachusetts | 42 | Pennsylvania |
| 11 | DC | 26 | Michigan | 44 | Rhode Island |
| 12 | Florida | 27 | Minnesota | 45 | South Carolina |
| 13 | Georgia | 28 | Mississippi | 46 | South Dakota |
| 15 | Hawaii | 29 | Missouri | 47 | Tennessee |
| 16 | Idaho | 30 | Montana | 48 | Texas |
| 17 | Illinois | 31 | Nebraska | 49 | Utah |
| | | 32 | Nevada | 50 | Vermont |
| | | 33 | New Hampshire | 51 | Virginia |
| | | 34 | New Jersey | 53 | Washington |
| | | | | 54 | West Virginia |
| | | | | 55 | Wisconsin |
| | | | | 56 | Wyoming |

**Special Codes**:
| Code | Jurisdiction |
|------|--------------|
| 60 | American Samoa |
| 66 | Guam |
| 69 | Northern Mariana Islands |
| 72 | Puerto Rico |
| 78 | Virgin Islands |
| 58 | Bureau of Indian Education |
| 59 | DoD Education Activity |

---

## Missing Data Codes

### Standard Missing Data Values

| Code | Meaning | When Used |
|------|---------|-----------|
| `-1` | Missing | State did not report; value unknown |
| `-2` | Not applicable | Item doesn't apply (e.g., staff count for school with no staff) |
| `-3` | Suppressed | Data suppressed for privacy protection |
| `-9` | Not reported | State opted not to report this item |

### Handling Missing Data

```python
# Identify problematic values
problematic_codes = [-1, -2, -3, -9]

# Filter to valid data
df_valid = df.filter(~pl.col("variable").is_in(problematic_codes))

# Or convert to null
df_clean = df.with_columns(
    pl.when(pl.col("variable").is_in(problematic_codes))
    .then(None)
    .otherwise(pl.col("variable"))
    .alias("variable")
)
```

### Suppression Rules

Data is typically suppressed when:
- Cell count is small (often <5 students)
- Complementary suppression is needed (prevent back-calculation)
- Privacy concerns for small subgroups

**Impact**: Disaggregated data (by race, grade, etc.) has higher suppression rates than totals.

---

## Grade Codes

### Portal Integer Encoding (enrollment data)

| Code | Grade Level | Description |
|------|-------------|-------------|
| `-1` | Pre-Kindergarten | Ages 3-5, before kindergarten |
| `0` | Kindergarten | Typically age 5 |
| `1`-`12` | Grades 1-12 | Standard grades |
| `13` | Grade 13 | Extended high school |
| `14` | Adult education | Adult education programs |
| `15` | Ungraded | No standard grade assignment |
| `99` | Total | All grades combined |
| `999` | Not specified | Grade not specified |

> **WARNING:** `grade = -1` means **Pre-K**, NOT missing! This differs from numeric variables where `-1` indicates missing data.

### Using Grade Codes

**Best Practice**: Use `grade == 99` (total) rather than summing individual grades.

**Why**: Summing grades may miss:
- Ungraded students (grade=15)
- Adult education (grade=14)
- Students in non-standard grade configurations
- Reporting differences by state

```python
# RECOMMENDED: Use total enrollment
total = df.filter(pl.col("grade") == 99)["enrollment"]

# NOT RECOMMENDED: Summing grades
# May undercount due to ungraded students
grade_sum = df.filter(pl.col("grade").is_between(1, 12))["enrollment"].sum()
```

### Grade Span

Schools report lowest (GSLO) and highest (GSHI) grades offered:
- Elementary: Typically PK/KG through 5 or 6
- Middle: Typically 6-8 or 7-8
- High: Typically 9-12
- Combined: Various spans

---

## Race/Ethnicity Codes

### Portal Integer Encoding (Current)

| Code | Category | Description |
|------|----------|-------------|
| `1` | White | Single race, non-Hispanic |
| `2` | Black | Single race, non-Hispanic |
| `3` | Hispanic | Any race; ethnicity collected separately |
| `4` | Asian | Single race, non-Hispanic |
| `5` | American Indian/Alaska Native | Single race, non-Hispanic |
| `6` | Native Hawaiian/Pacific Islander | Single race, non-Hispanic |
| `7` | Two or More Races | Multiple races selected, non-Hispanic |
| `9` | Unknown | Race/ethnicity unknown |
| `99` | Total | All races combined |

> **Note:** NCES raw files use string codes (WH, BL, HI, AS, AM, HP, TR). The Portal converts these to integers for consistency.
>
> **CCD-specific:** Empirically verified codes in CCD enrollment data are `1-7`, `9`, and `99`. Codes `8` (Nonresident alien) and `20` (Other) appear in postsecondary datasets (IPEDS) but are NOT present in CCD K-12 data. Missing data codes (`-1`, `-2`, `-3`) may appear in non-enrollment CCD datasets.

**Key Points**:
- Hispanic is treated as ethnicity, asked first
- Non-Hispanic students then select one or more races
- "Two or More Races" category added in 2010
- HP (Pacific Islander) separated from AS (Asian) in 2010

### Historical Context (Pre-2010)

States transitioned to 7-category system at different times. Data from 2007-2010 may have reporting inconsistencies.

**Caution**: Time series analysis across this period requires careful handling.

---

## Sex Codes

### Portal Integer Encoding

| Code | Category |
|------|----------|
| `1` | Male |
| `2` | Female |
| `9` | Unknown |
| `99` | Total |

> **CCD-specific:** Empirically verified codes in CCD enrollment data are `1`, `2`, `9`, and `99`. Code `3` (Another gender) may appear in other Portal datasets but is NOT present in CCD K-12 enrollment data. Missing data codes (`-1`, `-2`, `-3`) may appear in non-enrollment CCD datasets.

---

## Locale Codes

### Portal Integer Encoding

The Portal uses integer locale codes. **Both old and new systems appear in the data** depending on the year.

### Urban-Centric Locale Codes (2006-Present)

| Code | Category | Definition |
|------|----------|------------|
| `11` | City, Large | Principal city, population ≥250,000 |
| `12` | City, Midsize | Principal city, 100,000-249,999 |
| `13` | City, Small | Principal city, <100,000 |
| `21` | Suburb, Large | Outside principal city, urbanized area ≥250,000 |
| `22` | Suburb, Midsize | Outside principal city, urbanized area 100,000-249,999 |
| `23` | Suburb, Small | Outside principal city, urbanized area <100,000 |
| `31` | Town, Fringe | Urban cluster, ≤10 miles from urbanized area |
| `32` | Town, Distant | Urban cluster, 10-35 miles from urbanized area |
| `33` | Town, Remote | Urban cluster, >35 miles from urbanized area |
| `41` | Rural, Fringe | ≤5 miles from urbanized area |
| `42` | Rural, Distant | 5-25 miles from urbanized area |
| `43` | Rural, Remote | >25 miles from urbanized area |
| `9` | Not assigned | Locale not assigned |
| `-1` | Missing/not reported | Data not reported |
| `-2` | Not applicable | Item doesn't apply |
| `-3` | Suppressed | Privacy suppression |

### Metro-Centric Locale Codes (Pre-2006)

| Code | Category |
|------|----------|
| `1` | Large city |
| `2` | Midsize city |
| `3` | Urban fringe of large city |
| `4` | Urban fringe of midsize city |
| `5` | Large town |
| `6` | Small town |
| `7` | Rural, outside CBSA |
| `8` | Rural, inside CBSA |

### Locale Code Mapping

**There is no one-to-one mapping** between old and new locale codes. The underlying geographic methodology changed completely in 2006.

**Recommendation**:
- Analyze pre-2006 and post-2006 separately
- Do not attempt direct comparisons across the transition
- If longitudinal analysis is essential, use NCES crosswalk documentation with extreme caution

---

## School and LEA Type Codes

### School Type (Portal Integer Encoding)

| Code | Type | Description |
|------|------|-------------|
| `1` | Regular school | Standard public school |
| `2` | Special education school | Focuses on students with disabilities |
| `3` | Vocational school | Career/technical focus |
| `4` | Other/alternative school | Non-traditional programs |
| `5` | Reportable program | Program within school, no separate principal (2007-08+) |
| `-1` | Missing/not reported | Data not reported |
| `-2` | Not applicable | Item doesn't apply |
| `-3` | Suppressed | Privacy suppression |

### School Level (Portal Integer Encoding)

| Code | Level | Description |
|------|-------|-------------|
| `0` | Prekindergarten | Pre-K only |
| `1` | Primary | Elementary school |
| `2` | Middle | Middle school |
| `3` | High | High school |
| `4` | Other | Other configuration |
| `5` | Ungraded | No standard grade structure |
| `6` | Adult Education | Adult education programs |
| `7` | Secondary | Combined middle/high |
| `-1` | Missing/not reported | Data not reported |
| `-2` | Not applicable | Item doesn't apply |
| `-3` | Suppressed | Privacy suppression |

### LEA Type (`agency_type`, Portal Integer Encoding)

| Code | Type | Description |
|------|------|-------------|
| `1` | Regular | Standard local school district |
| `2` | Component | District sharing superintendent |
| `3` | Supervisory Union | Admin for multiple districts |
| `4` | Regional Agency | Education service agency |
| `5` | State-operated | State-run schools |
| `6` | Federal-operated | BIE, DoDEA |
| `7` | Charter Agency | All schools are charters (2007-08+) |
| `8` | Other | Other agencies (2007-08+) |
| `9` | Specialized Agency | Specialized public agency (observed in data) |

**Historical Note**: Prior to 2007-08, code 7 was used for "Other" agencies. The charter-specific designation was added in 2007-08.

> **Note:** The Districts Directory column is named `agency_type`, not `lea_type`.

---

## Status Codes

### School Operational Status (Portal Integer Encoding)

| Code | Status | Meaning |
|------|--------|---------|
| `1` | Open | Currently operational |
| `2` | Closed | No longer operating |
| `3` | New | Opened since last report |
| `4` | Added | Existed but not previously reported |
| `5` | Changed agency | Now associated with different LEA |
| `6` | Inactive | Temporarily closed (may reopen ≤3 years) |
| `7` | Future | Scheduled to open within 2 years |
| `8` | Reopened | Was closed, now operational |
| `-1` | Missing/not reported | Data not reported |
| `-2` | Not applicable | Item doesn't apply |
| `-3` | Suppressed | Privacy suppression |

Codes 6, 7 added in 2002-03. Code 8 added in 2005-06.

### LEA Boundary Status

Similar to school status, indicating changes to LEA boundaries or jurisdiction.

---

## Program Participation Variables

### Title I Status (Portal Integer Encoding)

| Code | Status |
|------|--------|
| `1` | Eligible for TAS, provides no program |
| `2` | Eligible for TAS, provides TAS program |
| `3` | Eligible for SWP, provides TAS program |
| `4` | Eligible for SWP, provides no program |
| `5` | Eligible for SWP, provides SWP |
| `6` | Not eligible for Title I |
| `-1` | Missing/not reported |
| `-2` | Not applicable |
| `-3` | Suppressed |

> TAS = Targeted Assistance, SWP = Schoolwide Program

### Lunch Program (Portal Integer Encoding)

| Code | Status |
|------|--------|
| `0` | No |
| `1` | Yes, without Provision or CEP |
| `2` | Yes, under Community Eligibility Provision (CEP) |
| `3` | Yes, under Provision 1 |
| `4` | Yes, under Provision 2 |
| `5` | Yes, under Provision 3 |
| `-1` | Missing/not reported |

> **CEP Note:** Schools using CEP (code 2) report 100% free lunch, making FRPL unreliable as a poverty measure. Use MEPS or SAIPE instead.

### Virtual School Status (Portal Integer Encoding)

| Code | Status |
|------|--------|
| `0` | No (not virtual) |
| `1` | Yes (fully virtual) |
| `2` | Virtual with face-to-face options |
| `3` | Supplemental virtual |
| `-1` | Missing/not reported |

### Yes/No Variables (Charter, Magnet, etc.)

| Code | Meaning |
|------|---------|
| `0` | No |
| `1` | Yes |
| `-1` | Missing/not reported |
| `-2` | Not applicable |
| `-3` | Suppressed |

Used for: `charter`, `magnet`, and similar binary indicators.

---

## Finance Variables

### Revenue Categories

| Category | Description |
|----------|-------------|
| Federal Revenue | Direct federal grants, Title I, IDEA, etc. |
| State Revenue | State aid formula, categorical grants |
| Local Revenue | Property taxes, other local sources |

### Expenditure Categories

| Category | Description |
|----------|-------------|
| Instruction | Teachers, instructional materials |
| Support Services | Administration, student services |
| Operations | Utilities, maintenance |
| Capital Outlay | Construction, equipment |
| Interest on Debt | Debt service |

### Per-Pupil Calculations

Multiple per-pupil measures exist:
- Total expenditure per pupil
- Current expenditure per pupil
- Instructional expenditure per pupil

**Enrollment Base**: Finance data typically uses fall enrollment counts, which may differ from membership counts.

---

## Special Indicators (Portal Integer Encoding)

> **Empirically verified** against actual Portal data. These replace older NCES string codes (e.g., `F`/`V`/`N` for virtual, `M` for missing, `1`/`2` for charter yes/no) which are NOT present in Portal data.

### Charter School (`charter`)

| Code | Status |
|------|--------|
| `0` | No, not a charter school |
| `1` | Yes, charter school |
| `-1` | Missing/not reported |
| `-2` | Not applicable |

> **CAUTION:** Some older documentation (including NCES sources) shows `1=Yes, 2=No`. The Portal uses `0=No, 1=Yes`. Empirically confirmed.

### Magnet School (`magnet`)

| Code | Status |
|------|--------|
| `0` | No, not a magnet school |
| `1` | Yes, magnet school or program |
| `-1` | Missing/not reported |
| `-2` | Not applicable |

### Virtual School (`virtual`, 2014-15+)

| Code | Status |
|------|--------|
| `0` | Not virtual |
| `1` | Fully virtual |
| `2` | Virtual with face-to-face options |
| `3` | Supplemental virtual |
| `-1` | Missing/not reported |

> **Note:** NCES raw files use string codes (`F`, `V`, `N`). The Portal converts these to integers.

---

## Calculated Variables

### Student/Teacher Ratio

```
Student/Teacher Ratio = Total Membership / FTE Teachers
```

**Notes**:
- Uses October 1 membership count
- Uses FTE teachers, not headcount
- Ratio reported may differ from calculated value due to rounding/timing

### School Level

NCES assigns school level based on grade span:
- Elementary: Lowest grade ≤ 6, highest grade ≤ 8
- Middle: Lowest grade ≥ 4, highest grade ≤ 9
- High: Lowest grade ≥ 7, highest grade ≤ 12
- Other: Doesn't fit above patterns

**Note**: Level assignment logic changed in 2017-18. See historical changes reference.
