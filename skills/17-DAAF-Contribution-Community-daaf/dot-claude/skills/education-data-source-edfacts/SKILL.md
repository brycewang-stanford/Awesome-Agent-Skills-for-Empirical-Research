---
name: education-data-source-edfacts
description: >-
  EDFacts — K-12 outcomes: assessment proficiency, ACGR graduation rates, ESSA accountability at school/district level (2009-2020). Within-state trends and subgroup gaps. Complements CCD with outcome data. Cannot compare across states — use NAEP.
metadata:
  audience: any-agent
  domain: data-source
  skill-authored: "2026-02-09"
  skill-last-updated: "2026-02-09"
---

# EDFacts Data Source Reference

EDFacts — federal K-12 outcome data from State Education Agencies, covering state assessment proficiency rates, ACGR graduation rates, and ESSA accountability indicators at school and district level (assessments 2009-2020, graduation rates 2010-2019). Use when analyzing within-state achievement trends, subgroup proficiency gaps, or adjusted cohort graduation rates. Complements CCD (school characteristics) with outcome data. State assessment scores CANNOT be compared across states; use NAEP for cross-state comparisons.

EDFacts is the U.S. Department of Education's centralized data collection system for pre-K through grade 12 education data from State Education Agencies (SEAs). It provides state assessment proficiency rates, graduation rates, and accountability indicators — the authoritative federal source for state-level K-12 outcome data.

> **CRITICAL: Value Encoding**
>
> The Urban Institute Education Data Portal converts NCES string codes (e.g., `ALL`, `CWD`, `LEP`) to **integer codes**. Always verify actual data values before filtering — do not rely on documentation labels alone.
>
> | Context | Subgroup "All" | English Learner | Sex "Male" |
> |---------|----------------|-----------------|------------|
> | **Portal integer** | `99` | `1` | `1` |
> | NCES string | `ALL` | `LEP` | `M` |
>
> See `./references/variable-definitions.md` for complete encoding tables.

## What is EDFacts?

- **Collector**: U.S. Department of Education, via State Education Agencies (SEAs)
- **Coverage**: All public schools and districts in 50 states + DC
- **Content**: State assessment proficiency rates, ACGR graduation rates, participation rates, accountability indicators
- **Frequency**: Annual collection
- **Available years**: Assessments 2009-10 to present; Graduation rates 2010-11 to present
- **Primary identifiers**: `ncessch` (school ID, Int64), `leaid` (district ID, Int64), `fips` (state FIPS code, Int64)
- **Key limitation**: State assessment scores CANNOT be compared across states (different tests, different cut scores)
- **Available through**: Education Data Portal mirrors

## Reference File Structure

| File | Purpose | When to Read |
|------|---------|--------------|
| `accountability-context.md` | ESSA, NCLB history, accountability systems | Understanding policy context |
| `assessment-data.md` | Proficiency levels, test scores, limitations | Working with assessment data |
| `graduation-rates.md` | ACGR methodology, cohort definitions | Analyzing graduation data |
| `variable-definitions.md` | Key variables, suppression codes, special values | Interpreting specific variables |
| `data-quality.md` | Known issues, state variations, COVID impacts | Data cleaning, limitations |
| `subgroup-reporting.md` | Special populations, disaggregation | Analyzing by student groups |

## Decision Trees

### What type of analysis?

```
What EDFacts data do you need?
├─ Assessment/proficiency data
│   ├─ Within-state trends → Valid analysis
│   ├─ Cross-state comparison → INVALID - use NAEP instead
│   └─ Subgroup gaps → See ./references/subgroup-reporting.md
├─ Graduation rates (ACGR)
│   ├─ Understand methodology → See ./references/graduation-rates.md
│   ├─ Extended rates (5-year, 6-year) → See ./references/graduation-rates.md
│   └─ Subgroup rates → See ./references/subgroup-reporting.md
├─ Understanding variables
│   ├─ Missing/suppressed values → See ./references/variable-definitions.md
│   ├─ Range vs. exact values → See ./references/variable-definitions.md
│   └─ Subgroup codes → See ./references/subgroup-reporting.md
└─ Data quality concerns
    ├─ COVID-19 impacts (2019-20) → See ./references/data-quality.md
    ├─ State reporting changes → See ./references/data-quality.md
    └─ Suppression rates → See ./references/data-quality.md
```

### Is my comparison valid?

```
What are you comparing?
├─ Same state, different years
│   ├─ Same assessment system? → Valid
│   └─ Different tests? → Break in time series
├─ Schools within same state → Valid
├─ Districts within same state → Valid
├─ Subgroups within same school → Valid (check suppression)
├─ Different states
│   ├─ Proficiency rates → INVALID
│   ├─ Graduation rates (ACGR) → More comparable
│   └─ Use NAEP instead → Valid
└─ National ranking by proficiency → INVALID
```

## Quick Reference: EDFacts Data Elements

### Assessment Data

| Data Element | Description | Available Years |
|--------------|-------------|-----------------|
| Proficiency rates | % meeting state standards in reading/math | 2009-10 to present |
| Participation rates | % of students assessed | 2012-13 to present |
| Achievement levels | Below Basic, Basic, Proficient, Advanced | Varies by state |
| Grade levels | Grades 3-8, high school (varies) | 2009-10 to present |

### Graduation Data

| Data Element | Description | Available Years |
|--------------|-------------|-----------------|
| 4-year ACGR | Adjusted Cohort Graduation Rate | 2010-11 to present |
| 5-year ACGR | Extended graduation rate | 2011-12 to present |
| 6-year ACGR | Further extended rate | 2012-13 to present |
| Diploma types | Regular diploma only in ACGR | All years |

### Key Identifiers

> **Portal Data Types:** All identifiers are **Int64** in the Portal parquet files. The NCES source format (zero-padded strings) is shown for reference only. When joining with other Portal datasets, join on the integer columns directly.

| ID | Portal Type | NCES Source Format | Level | Example (Int64) |
|----|-------------|-------------------|-------|-----------------|
| `ncessch` | Int64 | 12-char zero-padded | School | `10000500870` |
| `ncessch_num` | Int64 | Same as ncessch | School | `10000500870` |
| `leaid` | Int64 | 7-char zero-padded | District/LEA | `100005` |
| `leaid_num` | Int64 | Same as leaid | District/LEA | `100005` |
| `fips` | Int64 | 2-digit | State | `1` (Alabama) |

### Data Levels

| Level | Identifier | Dataset Path Pattern |
|-------|------------|---------------------|
| School | `ncessch` (Int64) | `edfacts/schools_edfacts_*` |
| District/LEA | `leaid` (Int64) | `edfacts/districts_edfacts_*` |
| State | `fips` (Int64) | Aggregate from lower levels |

### Subgroups Reported

> **Note:** Not all subgroup columns are present in every dataset. Grad rates data does NOT have `sex`, `migrant`, or `military_connected` columns.

| Subgroup | NCES Code | Portal Integer | Column | Available In |
|----------|-----------|----------------|--------|--------------|
| All students | `ALL` | `99` | race, sex, lep, disability | Assessments, Grad Rates |
| Economically disadvantaged | `ECODIS` | `1` | econ_disadvantaged | Assessments, Grad Rates |
| Students with disabilities | `CWD` | `1` | disability | Assessments, Grad Rates |
| English learners | `LEP` | `1` | lep | Assessments, Grad Rates |
| Homeless | `HOM` | `1` | homeless | Assessments, Grad Rates |
| Foster care | `FCS` | `1` | foster_care | Assessments, Grad Rates |
| Migrant | `MIG` | `1` | migrant | Assessments only |
| Military connected | `MIL` | `1` | military_connected | Assessments only |
| Race/ethnicity | Multiple | `1-7, 99` | race | Assessments, Grad Rates |
| Sex | `M/F` | `1, 2, 99` | sex | Assessments only |

**EDFacts Filter Column Pattern:**
- Special population columns (lep, disability, homeless, etc.) use `1` = subgroup, `99` = total
- Race column uses integer codes (1=White, 2=Black, etc.)
- Sex column uses `1` = Male, `2` = Female, `99` = Total (assessments only)

### Grade Codes (grade_edfacts)

| Code | Grade Level |
|------|-------------|
| `3`-`8` | Grades 3-8 (individual) |
| `9` | Grades 9-12 combined |
| `99` | Total (all grades) |

### Race Codes

> **Empirically verified** from 2018 school assessment data. Only these values appear in the `race` column:

| Code | Category |
|------|----------|
| `1` | White |
| `2` | Black |
| `3` | Hispanic |
| `4` | Asian |
| `5` | American Indian/Alaska Native |
| `7` | Two or More Races |
| `99` | Total |

> **Note:** Code `6` (Native Hawaiian/Pacific Islander) is NOT observed in the data. Codes `8` (Nonresident alien), `9` (Unknown), `20` (Other), `-1`, `-2`, `-3` are also not observed in the race column. These codes may exist in other Portal sources but are absent from EDFacts.

### Sex Codes

| Code | Category |
|------|----------|
| `1` | Male |
| `2` | Female |
| `9` | Unknown |
| `99` | Total |

### Disability Codes

> **Empirically verified** from 2018 school assessment and 2019 grad rate data. Only `1` and `99` are observed in the `disability` column. The expanded codes (0-4) documented in other Portal sources are NOT present in EDFacts datasets.

| Code | Category |
|------|----------|
| `1` | Students with disabilities (IDEA-eligible) |
| `99` | Total (all students) |

### LEP Codes

| Code | Category |
|------|----------|
| `1` | Students who are limited English proficient |
| `99` | All students (total) |

### Special Population Columns

For `homeless`, `migrant`, `econ_disadvantaged`, `foster_care`, `military_connected`:

| Code | Category |
|------|----------|
| `1` | Yes (in subgroup) |
| `99` | Total (all students) |

### Missing Data Codes

| Code | Meaning | When Used |
|------|---------|-----------|
| `-1` | Missing/not applicable | Data not reported |
| `-2` | Not reported | Item doesn't apply to this entity |
| `-3` | Suppressed for privacy | Data suppressed for small N-size |
| `-9` | Rounds to zero | Value rounds to zero |
| Range values | Exact value suppressed | Range provided instead of exact value |
| `_midpt` suffix | Calculated midpoint of suppressed range | Use for analysis when exact values are suppressed |

**Always use `_midpt` variables for analysis when exact values are suppressed.**

## Data Access

All EDFacts data is fetched via the **Education Data Portal mirror system**. There is no API access.

**Key references:**
- **`mirrors.yaml`** -- Mirror definitions, URL templates, read strategies
- **`datasets-reference.md`** -- Canonical dataset paths (one path works for all mirrors)
- **`fetch-patterns.md`** -- `fetch_from_mirrors()` and `fetch_yearly_from_mirrors()` patterns

> **Truth Hierarchy:** When interpreting variable values, apply this priority:
> 1. **Actual data file** (what you observe in the parquet/CSV) — this IS the truth
> 2. **Live codebook** (.xls in mirror) — authoritative documentation, may lag
> 3. **This skill documentation** — convenient summary, may drift from codebook
>
> If this documentation contradicts the codebook, trust the codebook. If the codebook contradicts observed data, trust the data and investigate.

### Key Datasets

| Dataset | Path | Type | Columns |
|---------|------|------|---------|
| School Assessments | `edfacts/schools_edfacts_assessments_{year}` | Yearly (2009-2018, 2020) | 26 cols |
| School Grad Rates | `edfacts/schools_edfacts_grad_rates_{year}` | Yearly (2010-2019) | 18 cols |
| District Assessments | `edfacts/districts_edfacts_assessments_{year}` | Yearly (2009-2018, 2020) | 23 cols |
| District Grad Rates | `edfacts/districts_edfacts_grad_rates_{year}` | Yearly (2010-2019) | 15 cols |

> **Note:** 2019 assessment data is NOT available (at any level) due to COVID testing waivers.

### Codebooks

Codebook `.xls` files are available for both assessment and graduation rate datasets. Use `get_codebook_url()` from `fetch-patterns.md`:

```python
# Assessment codebooks:
url = get_codebook_url("edfacts/codebook_schools_edfacts_assessments")
url = get_codebook_url("edfacts/codebook_districts_edfacts_assessments")

# Graduation rate codebooks:
url = get_codebook_url("edfacts/codebook_schools_edfacts_graduation")
url = get_codebook_url("edfacts/codebook_districts_edfacts_graduation")
```

> **Codebook naming note:** Graduation rate codebooks use `_graduation` (not `_grad_rates`), while the data files use `_grad_rates`. This follows the same pattern as other Portal sources where codebook names differ from data file names. See `datasets-reference.md` for the authoritative path mapping.

### Dataset Column Differences

Assessment and graduation rate datasets have **different column sets**:

| Column | Assessments | Grad Rates |
|--------|-------------|------------|
| `sex` | Yes (1, 2, 99) | **No** |
| `migrant` | Yes (1, 99) | **No** |
| `military_connected` | Yes (1, 99) | **No** |
| `grade_edfacts` | Yes (3-9, 99) | **No** |
| `read_test_*` / `math_test_*` | Yes | **No** |
| `grad_rate_*` | **No** | Yes |
| `cohort_num` | **No** | Yes |
| `school_name` / `lea_name` | Yes | Yes |

### Filtering

```python
# Grade filtering: grade_edfacts uses integer codes
df = df.filter(pl.col("grade_edfacts") == 4)  # Grade 4
df = df.filter(pl.col("grade_edfacts") == 99)  # All grades combined

# Subgroup filtering: special population columns use 1/99 pattern
df_total = df.filter(pl.col("sex") == 99)  # All students (total)
df_econ = df.filter(pl.col("econ_disadvantaged") == 1)  # Economically disadvantaged only

# Race filtering: integer codes
df_black = df.filter(pl.col("race") == 2)  # Black students
```

## Common Pitfalls

| Pitfall | Issue | Solution |
|---------|-------|----------|
| Ranking states by proficiency | Different tests, different cut scores make comparisons meaningless | Use NAEP for cross-state comparisons |
| Comparing 2019-20 to other years | COVID testing waivers created data gaps | Note data gap, exclude year |
| Ignoring suppression | Results biased toward larger schools/subgroups | Document suppression rates, use `_midpt` variables |
| Assuming proficiency = same thing | State definitions of "proficient" vary widely | Clarify each state's definition |
| Pre/post ESSA comparison | Different accountability systems (NCLB vs ESSA) | Note policy change at 2015 boundary |
| Using string codes for filtering | Portal uses integer encoding, not NCES strings | Always check actual data values; see encoding tables above |

## Key Policy Context

| Law | Years | Key Features |
|-----|-------|--------------|
| NCLB | 2002-2015 | AYP, 100% proficiency goal, HQT |
| ESSA | 2015-present | State flexibility, multiple indicators |

- **AYP (Adequate Yearly Progress)**: NCLB requirement eliminated by ESSA
- **ESSA Accountability**: States design own systems with federal guardrails
- **N-size**: Minimum students required for reporting (varies by state, typically 10-30)

## CRITICAL WARNING: Cross-State Comparisons

**State assessment proficiency rates CANNOT be compared across states.**

| Factor | Why It Varies |
|--------|---------------|
| Assessment content | Each state creates its own tests |
| Proficiency cut scores | Each state sets own thresholds |
| Standards alignment | State academic standards differ |
| Test difficulty | Not calibrated nationally |

A student "proficient" in one state may score "below basic" in another state taking a harder test with higher cut scores. **Rankings of states by proficiency rates are meaningless.**

Use NAEP (National Assessment of Educational Progress) for valid cross-state comparisons.

### Valid vs. Invalid Analysis Examples

**Valid Analysis:**

```python
# Within-state trend analysis
state_df = df.filter(pl.col("fips") == 6)  # California only
trend = state_df.group_by("year").agg(
    pl.col("read_test_pct_prof_midpt").mean()
)
# Valid: Same state, same test system
```

**INVALID Analysis:**

```python
# DO NOT DO THIS - Cross-state comparison
# This comparison is MEANINGLESS
state_comparison = df.group_by("fips").agg(
    pl.col("read_test_pct_prof_midpt").mean()
).sort("read_test_pct_prof_midpt", descending=True)
# INVALID: Different tests, different standards
```

## Related Data Sources

| Source | Relationship | When to Use |
|--------|--------------|-------------|
| `education-data-source-ccd` | CCD provides school/district demographics | Combining outcome data with school characteristics |
| `education-data-source-crdc` | CRDC has discipline, AP, school climate data | Analyzing school equity alongside achievement |
| `education-data-source-saipe` | SAIPE provides district poverty estimates | Linking poverty to achievement |
| `education-data-source-meps` | MEPS provides school poverty estimates | School-level poverty and assessment analysis |
| `education-data-explorer` | Parent discovery skill | Finding available endpoints |
| `education-data-query` | Data fetching | Downloading via mirrors |

## Topic Index

| Topic | Reference File |
|-------|---------------|
| NCLB to ESSA transition | `./references/accountability-context.md` |
| State accountability systems | `./references/accountability-context.md` |
| Federal reporting requirements | `./references/accountability-context.md` |
| Proficiency levels | `./references/assessment-data.md` |
| Why states can't be compared | `./references/assessment-data.md` |
| NAEP comparison | `./references/assessment-data.md` |
| Assessment system changes | `./references/assessment-data.md` |
| ACGR calculation | `./references/graduation-rates.md` |
| Cohort adjustments | `./references/graduation-rates.md` |
| Extended graduation rates | `./references/graduation-rates.md` |
| Diploma types | `./references/graduation-rates.md` |
| Suppression codes | `./references/variable-definitions.md` |
| Missing data values | `./references/variable-definitions.md` |
| Range/midpoint variables | `./references/variable-definitions.md` |
| Participation rates | `./references/variable-definitions.md` |
| COVID-19 data gaps | `./references/data-quality.md` |
| State reporting variations | `./references/data-quality.md` |
| Known data issues | `./references/data-quality.md` |
| Time series breaks | `./references/data-quality.md` |
| Students with disabilities | `./references/subgroup-reporting.md` |
| English learners | `./references/subgroup-reporting.md` |
| Economically disadvantaged | `./references/subgroup-reporting.md` |
| Race/ethnicity reporting | `./references/subgroup-reporting.md` |
| Homeless/foster/migrant | `./references/subgroup-reporting.md` |
| N-size requirements | `./references/subgroup-reporting.md` |
