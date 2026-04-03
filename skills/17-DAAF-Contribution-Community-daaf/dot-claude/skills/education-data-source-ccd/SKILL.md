---
name: education-data-source-ccd
description: >-
  CCD — federal universe of all U.S. public K-12 schools (~100K) and districts (~18K). Enrollment, staffing, finance, directory data (1986-present). Use for public school analysis by grade/race/sex. Public only; excludes private and postsecondary.
metadata:
  audience: any-agent
  domain: data-source
  skill-authored: "2026-02-09"
  skill-last-updated: "2026-02-09"
---

# CCD Data Source Reference

Common Core of Data (CCD) — the federal complete-universe database of all U.S. public K-12 schools and districts (~100,000 schools, ~18,000 districts), collecting enrollment, staffing, finance, and directory data annually (1986-present). Use when analyzing public school enrollment by grade/race/sex, district finances, school staffing, or directory attributes. Public schools and districts only; excludes private schools and postsecondary. Note significant variable encoding and race/ethnicity definition changes over time.

The CCD is the Department of Education's comprehensive, annual, national database of all public elementary and secondary schools and school districts in the United States. It is the only federal dataset that provides a complete universe census (not a sample) of U.S. public K-12 education.

> **CRITICAL: Value Encoding**
>
> The Education Data Portal uses **integer codes** for categorical variables that
> differ from NCES's original string codes. Always verify codes against codebooks.
>
> | Context | `school_type` | `charter` | `urban_centric_locale` |
> |---------|---------------|-----------|------------------------|
> | **Portal (integers)** | `1` (Regular) | `0` (No) / `1` (Yes) | `11` (City-Large) |
> | NCES original | `1-Regular school` | `Yes` / `No` | `11-City: Large` |
>
> **Note:** `charter` and `magnet` use `0/1` encoding, NOT `1=Yes / 2=No` as some NCES documentation shows.
>
> See `./references/variable-definitions.md` for complete encoding tables.

## What is CCD?

- **Primary K-12 database**: DOE's authoritative source for public elementary/secondary education statistics
- **Universe survey**: Covers ALL public schools and districts, not a sample
- **Annual collection**: Data submitted by State Education Agencies (SEAs) each year
- **Six major components**: Directory, Membership, Staffing, Finance (state and district), Dropout/Completers
- **Coverage**: ~100,000 public schools and ~18,000 school districts nationwide
- **Historical depth**: Data available from 1986 to present (varies by component)
- **Collector**: National Center for Education Statistics (NCES) via EDFacts
- **Available through**: Education Data Portal mirrors (5 of 6 survey components; see Data Access section for details)

## Reference File Structure

| File | Purpose | When to Read |
|------|---------|--------------|
| `survey-components.md` | Detailed coverage of each CCD survey component | Understanding what data is collected |
| `data-collection.md` | How data flows from schools to NCES, timelines, respondent universe | Understanding data provenance and timing |
| `variable-definitions.md` | Key variables, coding schemes, special values | Interpreting specific data elements |
| `data-quality.md` | Missing data patterns, suppression, state variations | Assessing data reliability |
| `historical-changes.md` | Definition changes, code revisions over time | Longitudinal analysis |

## Decision Trees

### What CCD component do I need?

```
What information do you need?
├─ School/district names, addresses, contacts → Directory
│   └─ See ./references/survey-components.md#directory
├─ Student enrollment counts → Membership
│   ├─ By grade → Membership (grade disaggregation)
│   ├─ By race/ethnicity → Membership (race disaggregation)
│   ├─ By sex → Membership (sex disaggregation)
│   └─ See ./references/survey-components.md#membership
├─ Staff/teacher counts → Staffing
│   └─ See ./references/survey-components.md#staffing
├─ Revenue and expenditure → Finance
│   ├─ State-level totals → National Public Education Financial Survey
│   ├─ District-level detail → School District Finance Survey (F-33)
│   └─ See ./references/survey-components.md#finance
├─ Graduation/dropout rates → Dropout and Completers
│   └─ See ./references/survey-components.md#dropout-completers
└─ School type, charter status, locale → Directory
    └─ See ./references/survey-components.md#directory
```

### Is this a data quality issue?

```
Unexpected data values?
├─ Negative numbers (-1, -2, -3, -9) → Missing data codes
│   └─ See ./references/variable-definitions.md#missing-data-codes
├─ Very different from prior year → Check for definition changes
│   └─ See ./references/historical-changes.md
├─ State appears as outlier → Check state-specific reporting
│   └─ See ./references/data-quality.md#state-variations
├─ Large number of zeros → Check suppression rules
│   └─ See ./references/data-quality.md#suppression
└─ Locale codes don't match → Pre/post 2006 locale system change
    └─ See ./references/historical-changes.md#locale-codes
```

### Can I compare across time?

```
Building a time series?
├─ Race/ethnicity categories → Major change in 2010
│   └─ See ./references/historical-changes.md#race-ethnicity
├─ Locale codes → Completely revised in 2006
│   └─ See ./references/historical-changes.md#locale-codes
├─ School/district IDs → Check for ID changes
│   └─ See ./references/variable-definitions.md#identifiers
├─ Free/reduced lunch → CEP and direct certification changes
│   └─ See ./references/data-quality.md#frpl
└─ Finance data → Definition changes and inflation
    └─ See ./references/historical-changes.md#finance
```

## Quick Reference: CCD Components

| Component | Level | Key Variables | Years | Update Cycle |
|-----------|-------|---------------|-------|--------------|
| Directory | School, LEA, State | Name, address, type, status, locale, charter | 1986+ | Annual |
| Membership | School, LEA, State | Enrollment by grade, race, sex | 1986+ | Annual |
| Staffing | School, LEA, State | FTE teachers, staff by category | 1987+ | Annual |
| Finance (State) | State | Revenue, expenditure by source/function | 1989+ | Annual (1-2 yr lag) |
| Finance (District) | LEA | Revenue, expenditure, per-pupil | 1989+ | Annual (2 yr lag) |
| Dropout/Completers | LEA, State | Dropout counts, diploma recipients | 1991+ | Annual |

> **Note:** Not all components listed above are available through the Portal mirrors. See the Data Access section for which datasets are mirrored.

### Key Identifiers

| Portal Column | Format | Level | Example | Notes |
|---------------|--------|-------|---------|-------|
| `ncessch` | 12 characters | School | `010000100100` | State FIPS (2) + LEA suffix (5) + School (5) |
| `leaid` | 7 characters | District | `0100001` | State FIPS (2) + State-assigned (5) |
| `fips` | 2 digits | State | `01` | Federal Information Processing Standard |

> **ID Type Warning:** `ncessch` and `leaid` may be String or Int64 depending on the dataset.
> In the Schools Directory, `ncessch` is String (preserving leading zeros); in enrollment data,
> `ncessch` is Int64. In the Districts Directory, `leaid` is Int64; in Finance data, `leaid` is String.
> Always check the actual dtype and cast as needed when joining across datasets.

### Missing Data Codes

The Portal uses both `null` and negative integer codes to represent missing/special values. The specific pattern varies by dataset:

| Code | Meaning | When Used |
|------|---------|-----------|
| `null` | Not available | Common in Directory fields that don't apply to all years |
| `-1` | Missing/not reported | Data not reported by state |
| `-2` | Not applicable | Item doesn't apply to this entity |
| `-3` | Suppressed | Data suppressed for privacy |
| `-9` | Not reported | State did not report this item |

> **Check actual data.** Some datasets use `null` where others use `-1` for effectively the same condition. Always check the observed values in the data before applying a blanket missing-value filter.

### School Types (`school_type`)

| Code | Type | Description |
|------|------|-------------|
| 1 | Regular | Standard public school |
| 2 | Special Education | Focuses on students with disabilities |
| 3 | Vocational | Career/technical education focus |
| 4 | Alternative | Non-traditional programs |
| 5 | Reportable Program | Program within another school (2007-08+) |

### LEA Types (`agency_type`)

| Code | Type | Description |
|------|------|-------------|
| 1 | Regular | Locally governed school district |
| 2 | Component | District sharing superintendent with others |
| 3 | Supervisory Union | Admin services for multiple districts |
| 4 | Regional Agency | Education service agency |
| 5 | State-operated | State-run schools (deaf, blind, correctional) |
| 6 | Federal-operated | Federal schools (BIE, DoDEA) |
| 7 | Charter Agency | All schools are charters (2007-08+) |
| 8 | Other | Doesn't fit other categories (2007-08+) |
| 9 | Specialized Agency | Specialized public agency (observed in data) |

### Grade -1 Encoding

In CCD enrollment data:
- `grade = -1` means **Pre-Kindergarten**, NOT missing data
- `grade = 99` means **Total** across all grades

**Do NOT filter `grade >= 0`** — this removes all Pre-K students!

```python
# WRONG - removes Pre-K students!
df = df.filter(pl.col("grade") >= 0)

# CORRECT
pre_k = df.filter(pl.col("grade") == -1)  # Pre-K only
k12 = df.filter(pl.col("grade").is_between(0, 12))  # K-12
total = df.filter(pl.col("grade") == 99)  # All grades
```

### Portal Column Name Mapping

> **Variable Name Mapping:** The Portal column `urban_centric_locale` contains locale codes. Some documentation may refer to this as simply `locale`. Use `urban_centric_locale` when filtering or selecting columns in Portal data.

### Dataset-to-Component Mapping

| Mirror Dataset | CCD Component | Path |
|----------------|---------------|------|
| Schools CCD Directory | School Directory | `ccd/schools_ccd_directory` |
| Schools CCD Enrollment | School Membership | `ccd/schools_ccd_enrollment_{year}` |
| Districts LEA Directory | LEA Directory | `ccd/school-districts_lea_directory` |
| Districts CCD Enrollment | LEA Membership | `ccd/schools_ccd_lea_enrollment_{year}` |
| Districts CCD Finance | F-33 District Finance | `ccd/districts_ccd_finance` |

### Data Collection Flow

```
Schools → Local Education Agencies (LEAs)
                ↓
    State Education Agencies (SEAs)
                ↓
        EDFacts Submission System
                ↓
    NCES Quality Review & Editing
                ↓
        CCD Public Data Files
```

**Timeline**: Data for school year 20XX-YY typically submitted spring 20YY, released fall 20YY (preliminary) to spring 20YY+1 (provisional/final).

## Data Access

Datasets for CCD are available via the mirror system. See `datasets-reference.md` for canonical paths, `mirrors.yaml` for mirror configuration, and `fetch-patterns.md` for fetch code patterns.

**Key datasets (5 datasets; see `datasets-reference.md` for the authoritative list):**

| Dataset | Type | Path | Codebook |
|---------|------|------|----------|
| School Directory | Single | `ccd/schools_ccd_directory` | `ccd/codebook_schools_ccd_directory` |
| School Enrollment | Yearly (1986-2023) | `ccd/schools_ccd_enrollment_{year}` | `ccd/codebook_schools_ccd_enrollment` |
| District Directory | Single | `ccd/school-districts_lea_directory` | `ccd/codebook_districts_ccd_directory` |
| District Enrollment | Yearly (1986-2023) | `ccd/schools_ccd_lea_enrollment_{year}` | `ccd/codebook_districts_ccd_enrollment` |
| District Finance | Single | `ccd/districts_ccd_finance` | `ccd/codebook_districts_ccd_finance` |

> **Not in Portal mirrors:** The following CCD components are documented in this skill for reference but are **not available** through the Education Data Portal mirrors:
> - **Dropout/Completers** — completion and dropout data by demographics
> - **State Finance (NPEFS)** — state-level education revenue and expenditure
>
> For these components, access NCES directly at https://nces.ed.gov/ccd/.

Codebooks are `.xls` files co-located with data in all mirrors. Use `get_codebook_url()` from `fetch-patterns.md` to construct download URLs:

```python
url = get_codebook_url("ccd/codebook_schools_ccd_directory")
```

> **Truth Hierarchy:** When interpreting variable values, apply this priority:
> 1. **Actual data file** (what you observe in the parquet/CSV) -- this IS the truth
> 2. **Live codebook** (.xls in mirror) -- authoritative documentation, may lag
> 3. **This skill documentation** -- convenient summary, may drift from codebook
>
> If this documentation contradicts the codebook, trust the codebook. If the codebook contradicts observed data, trust the data and investigate.

### Filtering

All filtering is done locally with Polars after download:

```python
import polars as pl

# Filter by state (California)
df = df.filter(pl.col("fips") == 6)

# Filter by year
df = df.filter(pl.col("year").is_in([2020, 2021, 2022]))

# Get totals only (enrollment)
df = df.filter(pl.col("grade") == 99)

# Get specific grades (K-12)
df = df.filter(pl.col("grade").is_between(0, 12))
```

### Finance Data Notes

- **Finance data lag:** The latest available year in the mirror is **2020** (empirically verified). Finance data typically lags 2+ years behind current school year.
- Finance dataset has 163 columns -- by far the most complex CCD dataset
- Some finance columns use `_total` suffix (e.g., `exp_current_instruction_total`)
- `leaid` is String type in Finance data (unlike the Districts Directory where it is Int64)

## Common Pitfalls

| Pitfall | Issue | Solution |
|---------|-------|----------|
| Summing grades | Misses ungraded students | Use `grade=99` (total) instead |
| Assuming `-1` is missing | In grade data, `-1` = Pre-K | Check variable format in codebook |
| Cross-state comparison | Different state definitions | Check state methodology first |
| Using FRPL as poverty measure | CEP schools show 100% | Supplement with MEPS or SAIPE data |
| Locale time series | 2006 code system change | Analyze pre/post-2006 separately |
| Charter school counts | Early years incomplete | Verify against state records pre-2010 |
| Dropout rate comparison | State definitions vary | Within-state comparisons only |
| Using NCES string codes | Portal uses integers | See variable-definitions.md for mappings |
| Assuming `charter=1/2` | Portal uses `0=No, 1=Yes` | Empirically verified; not NCES `1=Yes, 2=No` |
| ID type across datasets | `leaid`/`ncessch` may be String or Int64 | Always check dtype before joining |

## Coverage Notes

### What CCD Includes

- All public schools (traditional, charter, magnet, alternative)
- All public school districts and LEAs
- Bureau of Indian Education (BIE) schools
- Department of Defense Education Activity (DoDEA) schools
- State-operated schools (deaf, blind, correctional)

### What CCD Excludes

- Private schools (use Private School Universe Survey - PSS)
- Homeschool students
- Postsecondary institutions (use IPEDS)
- Detailed student-level data (CCD is aggregate only)

## Related Data Sources

| Source | Relationship | When to Use |
|--------|--------------|-------------|
| `education-data-source-edfacts` | CCD nonfiscal data flows through EDFacts | Same underlying data |
| `education-data-source-crdc` | Biennial; uses CCD school IDs | Need discipline, course access, equity data |
| `education-data-source-saipe` | Uses CCD district IDs | Need poverty estimates (better than FRPL) |
| `education-data-source-meps` | School-level poverty estimates | Need school-level poverty (better than FRPL) |
| `education-data-source-ipeds` | Separate system for postsecondary | Need college/university data |
| PSS | Private school equivalent | Need private school data |
| `education-data-source-nhgis` | Census geography crosswalks | Need school-Census links |
| `education-data-explorer` | Parent discovery skill | Finding available datasets |
| `education-data-query` | Data fetching (mirror system) | Downloading parquet/CSV files via `fetch_from_mirrors()` |

## Topic Index

| Topic | Reference File |
|-------|---------------|
| Directory survey | `./references/survey-components.md` |
| Membership survey | `./references/survey-components.md` |
| Staffing survey | `./references/survey-components.md` |
| Finance surveys | `./references/survey-components.md` |
| Dropout/completers | `./references/survey-components.md` |
| Data collection process | `./references/data-collection.md` |
| EDFacts submission | `./references/data-collection.md` |
| Respondent universe | `./references/data-collection.md` |
| NCES identifiers | `./references/variable-definitions.md` |
| Missing data codes | `./references/variable-definitions.md` |
| Grade codes | `./references/variable-definitions.md` |
| Race/ethnicity codes | `./references/variable-definitions.md` |
| Locale codes | `./references/variable-definitions.md` |
| State-level variations | `./references/data-quality.md` |
| Missing data patterns | `./references/data-quality.md` |
| FRPL limitations | `./references/data-quality.md` |
| Data suppression | `./references/data-quality.md` |
| Locale code changes (2006) | `./references/historical-changes.md` |
| Race/ethnicity changes (2010) | `./references/historical-changes.md` |
| LEA type changes (2007) | `./references/historical-changes.md` |
| ID changes over time | `./references/historical-changes.md` |
