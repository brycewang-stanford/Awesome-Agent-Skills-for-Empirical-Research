---
name: education-data-source-ipeds
description: >-
  IPEDS — primary federal postsecondary data (~6,500 institutions, 1980-present): enrollment, completions, graduation rates, finance, aid, admissions, HR. For college/university analysis. Grad rates = first-time full-time; finance needs GASB/FASB care.
metadata:
  audience: any-agent
  domain: data-source
  skill-authored: "2026-02-09"
  skill-last-updated: "2026-02-09"
---

# IPEDS Data Source Reference

IPEDS (Integrated Postsecondary Education Data System) — the primary federal data system for ~6,500 U.S. postsecondary institutions, comprising 12+ annual survey components: enrollment, completions, graduation rates, finance, financial aid, admissions, human resources, and institutional characteristics (1980-present, varies by component). Use when analyzing postsecondary enrollment, degree completions by CIP code, institutional finances, or admissions data. Graduation rates track first-time full-time students only (150% cohort). Cross-sector finance comparisons require care due to GASB vs. FASB accounting.

Comprehensive guide to understanding and using IPEDS data correctly. IPEDS is the most widely used source for postsecondary education data but has significant complexities — including sector-specific accounting standards, cohort-limited graduation rates, and integer-encoded categorical variables — that users must understand.

> **CRITICAL: Value Encoding**
>
> This document describes **Education Data Portal** integer encodings, which differ from NCES raw file string codes. The Portal converts categorical variables to integers for consistency across sources.
>
> | Context | Race White | Race Black | Sex Male | Sector Public 4-yr |
> |---------|------------|------------|----------|-------------------|
> | **Portal (integers)** | `1` | `2` | `1` | `1` |
> | NCES raw files | `EFFY_WHITE` | `EFFY_BKAA` | `M` | varies |
>
> **Always verify codes against Portal codebooks** (available alongside each dataset in the Portal mirrors).

## What is IPEDS?

IPEDS (Integrated Postsecondary Education Data System) is a system of 12+ interrelated survey components:

- **Administered by**: National Center for Education Statistics (NCES)
- **Coverage**: ~6,500 Title IV-participating postsecondary institutions
- **Frequency**: Annual collection in three periods (Fall, Winter, Spring)
- **Mandate**: Required for Title IV federal student aid participation
- **Available years**: 1980-present (varies by component)
- **Primary identifier**: UNITID (6-digit institution ID)
- **Available through**: Education Data Portal mirrors (32 datasets covering most survey components; some variables not mirrored — see Data Access section)

## Reference File Structure

| File | Purpose | When to Read |
|------|---------|--------------|
| `survey-components.md` | All 12+ IPEDS surveys with collection periods | Understanding data structure |
| `graduation-rates.md` | **CRITICAL** GRS limitations and who is tracked | Any graduation rate analysis |
| `enrollment-data.md` | Fall vs 12-month, FTE calculations | Enrollment comparisons |
| `finance-data.md` | GASB vs FASB accounting standards | Cross-sector finance analysis |
| `financial-aid.md` | Net price, aid types, populations | Aid and cost analysis |
| `institution-identifiers.md` | UNITID, OPEID, mergers, closures | Data linking and longitudinal work |
| `completions-data.md` | Degrees awarded, CIP codes | Completions and outcomes |
| `data-quality.md` | Known issues, sector comparisons | Quality assurance |

## Decision Trees

### What data am I working with?

```
Working with IPEDS data?
├─ Graduation rates → ./references/graduation-rates.md (READ FIRST!)
├─ Enrollment counts → ./references/enrollment-data.md
├─ Finance/revenue/expenses → ./references/finance-data.md
├─ Financial aid/net price → ./references/financial-aid.md
├─ Degrees/completions → ./references/completions-data.md
├─ Institutional info → ./references/survey-components.md (IC section)
├─ Human resources/salaries → ./references/survey-components.md (HR section)
└─ Linking to other data → ./references/institution-identifiers.md
```

### Is my analysis valid?

```
Cross-sector comparison?
├─ Comparing grad rates across sectors
│   └─ CAUTION: Different populations → ./references/graduation-rates.md
├─ Comparing finances across sectors
│   └─ CAUTION: GASB vs FASB → ./references/finance-data.md
├─ Comparing net price across sectors
│   └─ CAUTION: Aid populations differ → ./references/financial-aid.md
└─ Time series analysis
    └─ Check for institutional changes → ./references/institution-identifiers.md
```

### Finding specific variables?

```
Need variable definitions?
├─ Survey component overview → ./references/survey-components.md
├─ Graduation cohort definitions → ./references/graduation-rates.md
├─ Enrollment level/status → ./references/enrollment-data.md
├─ Revenue/expense categories → ./references/finance-data.md
├─ Aid types and populations → ./references/financial-aid.md
└─ CIP codes for programs → ./references/completions-data.md
```

## Quick Reference: Survey Components

| Component | Abbrev | Collection | Key Content |
|-----------|--------|------------|-------------|
| Institutional Characteristics | IC | Fall | Directory, tuition, mission |
| 12-Month Enrollment | E12 | Fall | Unduplicated headcount, FTE |
| Completions | C | Fall | Degrees by CIP, demographics |
| Cost | CST | Fall/Winter | Cost of attendance, net price |
| Admissions | ADM | Winter | Applications, admits, enrollees |
| Student Financial Aid | SFA | Winter | Aid counts and amounts |
| Graduation Rates | GR | Winter | 150% completion rates |
| Graduation Rates 200% | GR200 | Winter | 200% completion rates |
| Outcome Measures | OM | Winter | Part-time and transfer outcomes |
| Fall Enrollment | EF | Spring | Point-in-time enrollment |
| Finance | F | Spring | Revenue, expenses, assets |
| Human Resources | HR | Spring | Employees, salaries |
| Academic Libraries | AL | Spring | Library resources (biennial) |

### Key Identifiers

| ID | Format | Level | Example | Notes |
|----|--------|-------|---------|-------|
| `unitid` | 6-digit integer | Institution | `100654` | Unique, persistent across years; changes on merger |
| `opeid` | 8-digit string | Institution (Title IV) | `00100200` | Links to FSA/NSLDS; shared across branches |

### Institution Type Codes

| Variable | Values | Meaning |
|----------|--------|---------|
| `inst_control` | 1 | Public |
| | 2 | Private nonprofit |
| | 3 | Private for-profit |
| | -1 | Missing/not reported |
| `institution_level` | 1 | Less than 2-year |
| | 2 | 2-year (at least 2 but less than 4) |
| | **4** | 4-year or above |
| | -1 | Missing/not reported |
| `sector` | 0 | Administrative unit |
| | 1 | Public, 4-year or above |
| | 2 | Private not-for-profit, 4-year or above |
| | 3 | Private for-profit, 4-year or above |
| | 4 | Public, 2-year |
| | 5 | Private not-for-profit, 2-year |
| | 6 | Private for-profit, 2-year |
| | 7 | Public, less-than 2-year |
| | 8 | Private not-for-profit, less-than 2-year |
| | 9 | Private for-profit, less-than 2-year |
| | -1 | Sector unknown (not active) |
| `hbcu` | 1 | Historically Black College/University |
| | 0 | Not HBCU |
| | -1 | Missing/not reported |
| `tribal_college` | 1 | Tribal College |
| | 0 | Not Tribal College |
| | -1 | Missing/not reported |
| `degree_granting` | 1 | Degree-granting |
| | 0 | Non-degree-granting |

**Note:** There is **no code 3** for `institution_level`. The Portal uses codes 1, 2, 4 (not 1, 2, 3).

### `inst_size` Categories

| Code | Meaning |
|------|---------|
| 1 | Under 1,000 |
| 2 | 1,000 - 4,999 |
| 3 | 5,000 - 9,999 |
| 4 | 10,000 - 19,999 |
| 5 | 20,000 and above |

**Note:** `inst_size` is a category code (1-5), not an actual enrollment count.

### Race/Ethnicity Codes (Portal Integer Encoding)

| Code | Category | Notes |
|------|----------|-------|
| `1` | White | Single race, non-Hispanic |
| `2` | Black | Single race, non-Hispanic |
| `3` | Hispanic | Any race |
| `4` | Asian | Single race, non-Hispanic |
| `5` | American Indian/Alaska Native | Single race, non-Hispanic |
| `6` | Native Hawaiian/Pacific Islander | Single race, non-Hispanic |
| `7` | Two or more races | Multiple races selected, non-Hispanic |
| `8` | Nonresident alien | International students |
| `9` | Unknown | Race/ethnicity unknown |
| `20` | Other | Other race/ethnicity |
| `99` | Total | All races combined |
| `-1` | Missing/not reported | |
| `-2` | Not applicable | |
| `-3` | Suppressed | Privacy protection |

> **Historical note:** Prior to 2010, Asian included Pacific Islanders (code 6 did not exist), and "Two or more races" (code 7) was not collected.

### Sex Codes (Portal Integer Encoding)

| Code | Category |
|------|----------|
| `1` | Male |
| `2` | Female |
| `3` | Nonbinary/Another gender |
| `4` | Unknown/Prefer not to say |
| `9` | Unknown |
| `99` | Total |
| `-1` | Missing/not reported |
| `-2` | Not applicable |
| `-3` | Suppressed |

> **Note:** Codes 3 and 4 are recent additions for non-binary gender reporting. Historical data may only have codes 1, 2, and 99. The exact meaning of codes 3 vs 4 may vary by endpoint — check the specific codebook.

### Missing Data Codes

| Code | Meaning | When Used |
|------|---------|-----------|
| `-1` | Missing/not reported | Data not submitted by institution |
| `-2` | Not applicable | Item doesn't apply to this institution type |
| `-3` | Suppressed | Data suppressed for privacy |
| `null` | Not available | Field not collected for this survey year |

### Year Field Meanings

| Data Type | Year Field Meaning |
|-----------|--------------------|
| Institutional characteristics | As of fall of indicated year |
| Fall enrollment | As of fall census date |
| 12-month enrollment | July 1 to June 30 academic year |
| Completions | Awarded during academic year |
| Graduation rates | **Cohort entered** in indicated year |
| Finance | Fiscal year ending in indicated year |
| Student financial aid | For indicated academic year |

## Data Access

Datasets for IPEDS are available via the mirror system. See `datasets-reference.md` for canonical paths, `mirrors.yaml` for mirror configuration, and `fetch-patterns.md` for fetch code patterns.

**Key datasets:**

| Dataset | Type | Path | Codebook |
|---------|------|------|----------|
| Directory | Single | `ipeds/colleges_ipeds_directory` | `ipeds/codebook_colleges_ipeds_directory` |
| Admissions | Single | `ipeds/colleges_ipeds_admissions-enrollment` | `ipeds/codebook_colleges_ipeds_admissions-enrollment` |
| Enrollment FTE | Single | `ipeds/colleges_ipeds_enrollment-fte` | `ipeds/codebook_colleges_ipeds_enrollment-fte` |
| Graduation Rates | Single | `ipeds/colleges_ipeds_grad-rates` | `ipeds/codebook_colleges_ipeds_grad-rates` |
| Finance | Single | `ipeds/colleges_ipeds_finance` | `ipeds/codebook_colleges_ipeds_finance` |

32 IPEDS datasets exist in the mirror (5 shown above). See `datasets-reference.md` for the complete list with all paths and codebook paths.

> **Known Portal gaps:**
> - **Distance education enrollment variables** (`efdeexc`, `efdesom`, `efdenom`) are not in Portal mirror datasets. Use the NCES IPEDS Data Center for these.
> - **Open-admissions policy variable** (`OPENADMP`) is not in Portal mirror datasets. Note: `open_public` is NOT the same thing — see Common Pitfalls below.
> - **Finance data** may have a year lag relative to NCES releases (last verified through 2017 in some datasets).
>
> For data not available through Portal mirrors, access NCES directly at https://nces.ed.gov/ipeds/.

Codebooks are `.xls` files co-located with data in all mirrors. Use `get_codebook_url()` from `fetch-patterns.md` to construct download URLs:

```python
url = get_codebook_url("ipeds/codebook_colleges_ipeds_directory")
```

> **Truth Hierarchy:** When interpreting variable values, apply this priority:
> 1. **Actual data file** (what you observe in the parquet/CSV) — this IS the truth
> 2. **Live codebook** (.xls in mirror) — authoritative documentation, may lag
> 3. **This skill documentation** — convenient summary, may drift from codebook
>
> If this documentation contradicts the codebook, trust the codebook. If the codebook contradicts observed data, trust the data and investigate.

### Filtering

```python
import polars as pl

# Admissions totals: filter to sex=99 for institution-level totals
# WRONG - includes duplicates (~26K rows with multiple sex values per institution)
df = pl.read_parquet("data/raw/admissions.parquet")
# CORRECT - one row per institution-year (~8K rows)
df_totals = df.filter(pl.col("sex") == 99)

# Calculate admission rate (not provided directly)
df = df.with_columns(
    (pl.col("number_admitted") / pl.col("number_applied") * 100).alias("admit_rate")
)

# Filter to active, degree-granting, 4-year public institutions
df = df.filter(
    (pl.col("sector") == 1) &
    (pl.col("degree_granting") == 1)
)
```

### Data Availability & Lag Times

IPEDS data becomes available with significant lag. Always verify year availability before committing to a year range.

| Survey Component | Typical Lag | Latest Available (as of Jan 2026) |
|------------------|-------------|-----------------------------------|
| **Directory** | ~1 year | 2023 |
| **Admissions-Enrollment** | ~2 years | 2022 |
| **Fall Enrollment** | ~2-3 years | 2022 |
| **Completions** | ~2 years | 2022 |
| **Finance** | ~4+ years | **2017** (see warning below) |
| **Graduation Rates** | ~2-3 years | 2022 |

> **CRITICAL: IPEDS Finance Data Cutoff.** As of January 2026, IPEDS Finance data is only available through **2017** in the Portal mirrors. This affects endowment values (`endowment_end`), revenue/expense data, and any financial ratios. Options: (1) limit analysis to available years, (2) use NCCS 990 data for private institutions as an alternative, or (3) forward-fill with a documented caveat and indicator column.

### Variable Name Mappings

The Portal uses different names than NCES raw file documentation. The table below lists commonly confused mappings:

| NCES Raw File Name | Actual Portal Name | Notes |
|--------------------|-------------------|-------|
| `INSTNM` | `inst_name` | Institution name |
| `STABBR` | `state_abbr` | State abbreviation |
| `CONTROL` | `inst_control` | Institutional control |
| `ICLEVEL` | `institution_level` | Level of institution |
| `DEGGRANT` | `degree_granting` | Degree-granting status |
| `CYACTIVE` | `currently_active_ipeds` | Currently active flag |
| `DEATHYR` | `year_deleted` | Year institution closed |
| `APPLCN` | `number_applied` | Total applicants |
| `ADMSSN` | `number_admitted` | Total admitted |
| `EFTOTLT` | `enrollment_fall` | Fall enrollment (in fall-enrollment-race dataset) |
| various `GR*` | `completion_rate_150pct`, `completers_150pct`, etc. | Grad rate variables |

> **Note:** Portal variable names are always **lowercase** with underscores. NCES documentation often uses UPPERCASE or CamelCase. When in doubt, fetch a sample of the actual data and inspect its column names.

### Enrollment Dataset Clarification

IPEDS has multiple enrollment-related datasets in the Portal:

| Dataset | Key Columns | Best For |
|---------|-------------|----------|
| `fall-enrollment-race` (yearly) | `enrollment_fall`, `race`, `sex`, `level_of_study`, `ftpt`, `class_level`, `degree_seeking` | Detailed demographic breakdowns |
| `fall-enrollment-age` (yearly) | Enrollment by age group | Age distribution analysis |
| `enrollment-fte` (single) | `est_fte`, `rep_fte` | FTE-based comparisons |
| `enrollment-headcount` (single) | Headcount data | Headcount-based analysis |
| `fall-retention` (single) | Retention rates | Retention analysis |

> **Note:** The `fall-enrollment-race` yearly dataset provides the most granular enrollment data, disaggregated by multiple dimensions. For institution-level totals, filter to `race == 99`, `sex == 99`, `ftpt == 99`, `level_of_study == 99`.

## Common Pitfalls

| Pitfall | Issue | Solution |
|---------|-------|----------|
| Using string codes | Portal uses integer encodings, not NCES string codes | Always verify against Portal codebooks; see encoding table above |
| Grad rates as sole quality metric | IPEDS tracks only first-time, full-time, fall-entering students; excludes ~40% transfers, ~40% part-time | Use Outcome Measures (OM) for part-time/transfer data; note limitations |
| Cross-sector finance comparison | Public (GASB) and private (FASB) use different accounting standards | Compare within sector only; see `./references/finance-data.md` for crosswalk |
| Net price for all students | Net price covers only first-time, full-time students who received Title IV aid | Document population limitation; excludes full-pay students |
| Admissions without sex filter | Admissions data disaggregated by sex — unfiltered data has duplicates | Filter to `sex == 99` for institution totals |
| No `institution_level` 3 | Codes are 1, 2, 4 — not sequential 1, 2, 3 | Use exact codes: 1=less-than-2yr, 2=2yr, 4=4yr+ |
| Ignoring mergers/closures | Institutions merge, close, or change sector over time | Check `currently_active_ipeds` and `year_deleted`; track UNITID changes; see `./references/institution-identifiers.md` |
| `inst_size` as enrollment | `inst_size` is a 1-5 category code, not an enrollment count | Use enrollment endpoints for actual counts |
| Distance education variables missing | `efdeexc`, `efdesom`, `efdenom` are not in Portal mirror datasets | Use the NCES IPEDS Data Center directly for distance education enrollment |
| GRS duplicate rows per institution | Graduation rates data has multiple rows per `unitid` within the same subcohort/year, differing in `cohort_rev` and count columns | Filter to target subcohort first (e.g., `subcohort == 2` for bachelor's-seeking at 4-yr), then deduplicate: sort by `completion_rate_150pct` descending (nulls last), then `unique(subset=["unitid"], keep="first")` |
| `open_public` is not open admissions | `open_public` (from `openpubl`) means "open to the general public" (i.e., a currently operating institution) — Harvard has `open_public=1`. The actual open-admissions policy variable (`OPENADMP`) is not available in the Portal mirror | Do not use `open_public` to identify open-admissions institutions. Use admissions data (admit rate near 100%) as a proxy, or access `OPENADMP` via the IPEDS API directly |
| SFA `type_of_aid=9` is all grants, not Pell | `type_of_aid=9` in `sfa_grants_and_net_price` captures ALL grant/scholarship recipients (Pell + institutional + state/local). The median ratio to total students is ~0.98 — nearly universal. This dramatically overestimates "Pell share" if used as a Pell proxy | For Pell-specific data, use FSA (pre-2020) or College Scorecard bulk download. SFA `type_of_aid=9` is appropriate for total grant aid analysis but not for Pell isolation |

## Critical Limitations

### Graduation Rates (GRS)

**CRITICAL**: IPEDS graduation rates track ONLY first-time, full-time, fall-entering students.

| Excluded Population | Approximate % of Undergrads |
|---------------------|----------------------------|
| Transfer students | ~40% |
| Part-time students | ~40% |
| Spring/summer starts | Varies |
| Students who transfer OUT | Counted as non-completers |

**At community colleges, IPEDS grad rates may represent <25% of students.**

See `./references/graduation-rates.md` for complete details.

### Finance Data

**CRITICAL**: Public and private institutions use different accounting standards.

| Standard | Institution Type | Comparison |
|----------|-----------------|------------|
| GASB | Public | Compare within sector only |
| FASB | Private nonprofit | Different from GASB |
| FASB | Private for-profit | Different revenue treatment |

See `./references/finance-data.md` for crosswalk guidance.

### Net Price

Net price is calculated ONLY for:
- First-time, full-time students
- Who received Title IV aid
- Excludes full-pay students

See `./references/financial-aid.md` for details.

### Data Quality Checklist

```python
import polars as pl

def ipeds_quality_check(df):
    """Basic IPEDS data quality checks using Portal variable names."""
    issues = []

    # Check graduation rates — Portal stores as 0-1 proportions (not 0-100)
    # See education-data-context skill > Rate and Proportion Normalization
    if "completion_rate_150pct" in df.columns:
        bad = df.filter(
            (pl.col("completion_rate_150pct") > 1.0) |
            (pl.col("completion_rate_150pct") < 0)
        )
        if bad.height > 0:
            issues.append(f"Invalid grad rates: {bad.height} rows")

    # Check for non-active institutions (directory dataset)
    if "currently_active_ipeds" in df.columns:
        inactive = df.filter(pl.col("currently_active_ipeds") != 1)
        if inactive.height > 0:
            issues.append(f"Non-active institutions: {inactive.height}")

    # Check sector consistency
    if "inst_control" in df.columns:
        invalid = df.filter(
            ~pl.col("inst_control").is_in([1, 2, 3, -1])
        )
        if invalid.height > 0:
            issues.append(f"Invalid control codes: {invalid.height}")

    return issues
```

## Related Data Sources

| Source | Relationship | When to Use |
|--------|--------------|-------------|
| `education-data-source-scorecard` | Non-traditional student outcomes | Post-college earnings, broader student population |
| `education-data-source-fsa` | Detailed loan/grant data | Federal student aid analysis (link on OPEID) |
| `education-data-source-nccs` | Private institution 990 data | Financial data beyond IPEDS cutoff year |
| `education-data-source-pseo` | Post-college employment | State-level employment outcomes |
| `education-data-source-eada` | College athletics | Athletics equity and finance |
| `education-data-source-nacubo` | Endowment data | Endowment analysis beyond IPEDS |
| `education-data-source-campus-safety` | Campus crime statistics | Safety and compliance |
| `education-data-explorer` | Parent discovery skill | Finding available endpoints |
| `education-data-query` | Data fetching | Downloading parquet/CSV files |

## Topic Index

| Topic | Reference File |
|-------|---------------|
| Survey components overview | `./references/survey-components.md` |
| Graduation rate cohort definition | `./references/graduation-rates.md` |
| First-time full-time limitation | `./references/graduation-rates.md` |
| Transfer-out rates | `./references/graduation-rates.md` |
| Outcome Measures survey | `./references/graduation-rates.md` |
| 150% vs 200% time | `./references/graduation-rates.md` |
| Fall enrollment | `./references/enrollment-data.md` |
| 12-month enrollment | `./references/enrollment-data.md` |
| FTE calculations | `./references/enrollment-data.md` |
| Enrollment by level | `./references/enrollment-data.md` |
| GASB accounting | `./references/finance-data.md` |
| FASB accounting | `./references/finance-data.md` |
| Revenue categories | `./references/finance-data.md` |
| Expense categories | `./references/finance-data.md` |
| Net price definition | `./references/financial-aid.md` |
| Pell grant data | `./references/financial-aid.md` |
| Aid by income level | `./references/financial-aid.md` |
| UNITID | `./references/institution-identifiers.md` |
| OPEID | `./references/institution-identifiers.md` |
| Institutional mergers | `./references/institution-identifiers.md` |
| Sector changes | `./references/institution-identifiers.md` |
| CIP codes | `./references/completions-data.md` |
| Award levels | `./references/completions-data.md` |
| Completers vs completions | `./references/completions-data.md` |
| Data quality issues | `./references/data-quality.md` |
| Missing data codes | `./references/data-quality.md` |
| Sector comparisons | `./references/data-quality.md` |
| Subcohort codes (GRS) | `./references/graduation-rates.md` |
| GRS deduplication | `./references/graduation-rates.md` |
| `open_public` vs open admissions | Common Pitfalls (this file) |
| SFA `type_of_aid` codes | `./references/financial-aid.md` |
