---
name: education-data-source-pseo
description: >-
  PSEO — Census data linking graduates to employment via LEHD wage records. Earnings percentiles at 1/5/10 years post-graduation by institution, degree, CIP. Use for graduate earnings analysis. Coverage: ~29% of graduates from ~31 states.
metadata:
  audience: any-agent
  domain: data-source
  skill-authored: "2026-02-09"
  skill-last-updated: "2026-02-09"
---

# PSEO Data Source Reference

Postsecondary Employment Outcomes (PSEO) — Census Bureau experimental statistics linking college graduates to employment outcomes via UI wage records (LEHD program). Covers earnings (25th/50th/75th percentile, measured 1, 5, and 10 years post-graduation) and employment flows by institution, degree level, and CIP field. Use when comparing graduate earnings across programs or institutions, analyzing industry entry patterns, or studying geographic migration of graduates. Coverage limited to ~29% of graduates from ~31 participating states.

Postsecondary Employment Outcomes (PSEO) is an experimental data product from the U.S. Census Bureau that links college graduate records to national employment data, providing earnings and employment outcomes by institution, degree level, and field of study.

> **CRITICAL: Value Encoding**
>
> This document describes **Education Data Portal** integer encodings, which differ from Census API string codes. The Portal converts categorical variables to integers for consistency.
>
> | Context | Baccalaureate | Associates | Masters | Census Division Pacific |
> |---------|---------------|------------|---------|-------------------------|
> | **Portal (integers)** | `5` | `3` | `7` | `9` |
> | Census API (strings) | `05` | `03` | `07` | `9` |
>
> **Key differences:** Degree level uses simple integers (1-10), not string codes like "1C", "05". CIP codes are 2-digit integers (11 for Computer Science), not strings like "11.01".
>
> See `./references/variable-definitions.md` for complete encoding tables.

## What is PSEO?

- **Producer**: U.S. Census Bureau, LEHD program (Longitudinal Employer-Household Dynamics)
- **Coverage**: ~29% of all U.S. college graduates from 31 states + D.C. + Western Governors University
- **Content**: Links university transcript data with national UI wage records to track graduate employment outcomes
- **Two data types**: Graduate Earnings (percentile earnings) and Employment Flows (industry/geography)
- **Frequency**: Updated periodically; cohorts span 3-year (Bachelor's) or 5-year (all others) windows
- **Primary identifiers**: `unitid` (IPEDS Unit ID, integer), `opeid` (integer in Portal data)
- **Privacy method**: Differential privacy mechanisms protect individual data
- **Available through**: Education Data Portal mirrors (restructured from Census Bureau LEHD format with integer encodings and lowercase variable names)

## Reference File Structure

| File | Purpose | When to Read |
|------|---------|--------------|
| `lehd-methodology.md` | How LEHD produces tabulations, data matching process | Understanding data creation |
| `earnings-data.md` | Percentile earnings, cohort definitions, labor attachment | Analyzing graduate earnings |
| `geographic-flows.md` | Where graduates work by Census Division | Studying migration patterns |
| `industry-flows.md` | What industries graduates enter by NAICS sector | Career pathway analysis |
| `variable-definitions.md` | All variables, codes, and status flags | Building queries or interpreting values |
| `state-coverage.md` | Participating states, coverage rates, data partners | Understanding limitations |

## Decision Trees

### What type of outcome am I researching?

```
Graduate outcomes research?
├─ Earnings by program/institution
│   ├─ Median earnings → `p50_earnings` column, filter by `years_after_grad`
│   ├─ Earnings distribution → `p25_earnings`/`p50_earnings`/`p75_earnings`
│   └─ See ./references/earnings-data.md
├─ Where graduates work (geography)
│   ├─ Census Division of employment → `census_division` column
│   ├─ In-state vs out-of-state → `employed_instate_grads_count`
│   └─ See ./references/geographic-flows.md
├─ What industries graduates enter
│   ├─ NAICS sector employment → `industry` column (String)
│   └─ See ./references/industry-flows.md
└─ How many graduates are employed
    ├─ Employment counts → `employed_grads_count_f`
    ├─ Non-employed/marginal → `jobless_m_emp_grads_count`
    └─ See ./references/variable-definitions.md
```

### What degree level am I researching?

```
Degree level?
├─ Certificate (<1 year) → degree_level=1
├─ Certificate (1-2 years) → degree_level=2
├─ Certificate (2-4 years) → degree_level=4
├─ Associate's → degree_level=3
├─ Bachelor's → degree_level=5 (default, 3-year cohorts)
├─ Post-Bacc Certificate → degree_level=6
├─ Master's → degree_level=7 (2-digit CIP only)
├─ Post-Masters Certificate → degree_level=8
├─ Doctoral-Research → degree_level=9 (2-digit CIP only)
└─ Doctoral-Professional Practice → degree_level=10
```

> **Note:** Portal uses integers 1-10. Census Bureau source data uses string codes like "05", "1C" -- these do not appear in Portal data.

### Is my institution/state covered?

```
Checking data availability?
├─ Which states participate → ./references/state-coverage.md
├─ Which institutions have data → Check PSEO Explorer or mirror data
├─ Coverage rate for state → ./references/state-coverage.md
└─ Why data might be missing
    ├─ Institution not partnered
    ├─ Cell suppressed (count < 30)
    └─ Insufficient labor force attachment
```

## Quick Reference: PSEO Variables

### Earnings Variables

| Portal Variable | Description |
|-----------------|-------------|
| `p25_earnings` | 25th percentile earnings (2022 dollars) |
| `p50_earnings` | Median earnings (2022 dollars) |
| `p75_earnings` | 75th percentile earnings (2022 dollars) |
| `years_after_grad` | Years post-graduation: `1`, `5`, or `10` |
| `employed_grads_count_e` | Graduate count with earnings data |
| `total_grads_count` | Total IPEDS-reported graduates |

### Flows Variables

| Portal Variable | Description |
|-----------------|-------------|
| `employed_grads_count_f` | Employed graduates count |
| `employed_instate_grads_count` | Employed in institution's state |
| `jobless_m_emp_grads_count` | Non-employed or marginally employed |
| `industry` | 2-digit NAICS sector (String, e.g., `"54"`, `"31-33"`) |
| `census_division` | Census Division of employment (1-9, 99) |

> **Note:** Portal uses restructured schema with `years_after_grad` column instead of Census API's `Y1_*/Y5_*/Y10_*` naming. The `industry` column is String type because some NAICS sectors span ranges (e.g., `"31-33"` for Manufacturing, `"44-45"` for Retail Trade).

### Key Identifiers

| ID | Format | Level | Example | Notes |
|----|--------|-------|---------|-------|
| `unitid` | Integer | Institution | `100751` | IPEDS Unit ID (University of Alabama) |
| `opeid` | Integer | Institution | `105100` | Portal stores as integer (Census uses 8-digit zero-padded string) |
| `fips` | Integer | State | `48` | State of institution (Texas) |
| `cipcode` | 2-digit integer | Field of study | `11` | Computer Science; Portal uses integers, not "11.01" |

### Key Filters (Portal Integer Encoding)

| Parameter | Description | Example |
|-----------|-------------|---------|
| `degree_level` | Degree type integer | `5` (Bachelor's) |
| `pseo_cohort` | Graduation cohort | `"2016-2020"` or `"2019-2021"` (string format, full year range) |
| `years_after_grad` | Years post-graduation | `1`, `5`, or `10` |

### Cohort Definitions

| Degree Level | Cohort Years | Example Cohorts |
|--------------|--------------|-----------------|
| Bachelor's | 3-year | `"2001-2003"`, `"2004-2006"`, `"2007-2009"`, `"2010-2012"`, `"2013-2015"`, `"2016-2018"`, `"2019-2021"` |
| All others | 5-year | `"2001-2005"`, `"2006-2010"`, `"2011-2015"`, `"2016-2020"` |

### Missing Data Codes

| Code | Meaning | When Used |
|------|---------|-----------|
| `-1` | Missing/not reported | Primary missing data indicator; very common in earnings and flows columns |
| `-3` | Suppressed | Cell count < 30 graduates (differential privacy suppression) |
| `-2` | Not applicable | Item doesn't apply to this entity (Portal convention) |

> **Note:** PSEO data has **no null values** in the parquet files. All missing/suppressed data uses integer codes (`-1`, `-3`). Filter with `pl.col("p50_earnings") > 0` to get valid earnings, not `.is_not_null()`. PSEO uses differential privacy rather than traditional suppression. Cells with fewer than 30 graduates are suppressed entirely (coded as `-3`). Earnings values coded `-1` may indicate insufficient labor force attachment.

## Data Access

Datasets for PSEO are available via the Education Data Portal mirror system. See `datasets-reference.md` for canonical paths, `mirrors.yaml` for mirror configuration, and `fetch-patterns.md` for fetch code patterns.

| Dataset | Type | Path | Codebook |
|---------|------|------|----------|
| Earnings and Flows | Yearly (2001-2021) | `pseo/colleges_pseo_{year}` | `pseo/codebook_colleges_pseo` |

Codebooks are `.xls` files co-located with data in all mirrors. Use `get_codebook_url()` from `fetch-patterns.md` to construct download URLs.

> **Truth Hierarchy:** When interpreting variable values, apply this priority:
> 1. **Actual data file** (what you observe in the parquet/CSV) -- this IS the truth
> 2. **Live codebook** (.xls in mirror) -- authoritative documentation, may lag
> 3. **This skill documentation** -- convenient summary, may drift from codebook
>
> If this documentation contradicts the codebook, trust the codebook. If the codebook contradicts observed data, trust the data and investigate.

### Fetching PSEO Data

```python
import polars as pl

# PSEO is a yearly dataset -- fetch individual years
df = fetch_yearly_from_mirrors(
    path_template="pseo/colleges_pseo_{year}",
    years=[2018, 2019, 2020],
)

# Or fetch a single year
df = fetch_from_mirrors("pseo/colleges_pseo_2020")
```

### Filtering

```python
# Filter by institution
df.filter(pl.col("unitid") == 100751)  # University of Alabama

# Filter by field of study
df.filter(pl.col("cipcode") == 11)  # Computer Science

# Filter by cohort (note: full year range format)
df.filter(pl.col("pseo_cohort") == "2019-2021")

# Earnings rows only (exclude missing/suppressed)
df.filter(pl.col("p50_earnings") > 0)

# Filter by industry (String column, not integer)
df.filter(pl.col("industry") == "54")  # Professional Services
```

### Additional Access Methods (Census Bureau Source)

1. **PSEO Explorer**: Interactive visualization tool at `https://lehd.ces.census.gov/data/pseo_explorer.html`
2. **Census bulk download**: CSV/XLS files at `https://lehd.ces.census.gov/data/pseo/`
3. **Census API**: `https://api.census.gov/data/timeseries/pseo/earnings` and `.../flows` (uses different variable naming and string codes; not used in this system)

## Common Pitfalls

| Pitfall | Issue | Solution |
|---------|-------|----------|
| Using Census string codes | Portal uses integers (e.g., `5` for Bachelor's), not Census strings (`"05"`) | Always check encoding; see variable-definitions.md |
| Ignoring suppression | Cells with <30 graduates are suppressed; missing data looks like no program exists | Check `total_grads_count` to confirm cell exists; null earnings may mean suppression |
| Cross-institution comparison without controlling degree/CIP | Institutions offer different program mixes; aggregate comparison is misleading | Always filter to same `degree_level` and `cipcode` when comparing institutions |
| Treating PSEO as comprehensive | Only ~29% of graduates covered; participating states differ systematically | Acknowledge selection bias; do not generalize to all U.S. graduates |
| Ignoring labor attachment | Workers need 3+ quarters above minimum wage threshold to appear in earnings data | Some graduates are employed but excluded; note this limitation |
| Treating Portal opeid as string | Portal stores `opeid` as integer (e.g., `105100`), not Census's 8-digit zero-padded string (`"00105100"`) | Use integer comparison in Portal data; only Census API uses string format |
| Mixing cohort spans | Bachelor's uses 3-year cohorts; all others use 5-year | Filter by `degree_level` first, then verify cohort format matches |
| Assuming inflation comparability | All earnings are in 2022 CPI-U dollars | No manual inflation adjustment needed; values are already real dollars |

## PSEO vs Other Data Sources

| Feature | PSEO | College Scorecard | State Systems |
|---------|------|-------------------|---------------|
| Coverage | Graduates only | All enrollees | Graduates only |
| Geographic scope | National (cross-state) | National | In-state only |
| Sample | All graduates from partners | Federal aid recipients | All graduates |
| Earnings detail | 25th/50th/75th percentile | Median only | Varies |
| Industry data | Yes (NAICS sector) | No | Varies |
| Geographic flows | Yes (Census Division) | No | No |
| Privacy method | Differential privacy | Traditional suppression | Varies |

## Common Use Cases

| Use Case | Data Needed | Key Considerations |
|----------|-------------|-------------------|
| Compare programs within institution | Earnings by CIPCODE | Check cell counts for suppression |
| Compare institutions for same program | Earnings by INSTITUTION | Ensure same degree level and CIP |
| Analyze brain drain/retention | Flows by division + in-state | Only 9 Census Divisions |
| Career pathway analysis | Flows by NAICS sector | 2-digit NAICS only |
| ROI by degree level | Earnings across DEGREE_LEVEL | Different cohort spans |

## Important Limitations

1. **Experimental status**: Not official Census statistics; methodology may change
2. **Partial coverage**: Only ~29% of graduates from participating institutions
3. **Selection bias**: Participating states/institutions may differ systematically
4. **Employment coverage**: Excludes self-employed, independent contractors, military, some federal
5. **Labor attachment requirement**: Workers must have 3+ quarters of earnings above minimum wage threshold
6. **Suppression**: Cells with fewer than 30 graduates are suppressed
7. **Earnings inflation-adjusted**: All earnings in 2022 dollars (CPI-U)

## Related Data Sources

| Source | Relationship | When to Use |
|--------|--------------|-------------|
| `education-data-source-scorecard` | Alternative earnings source (median only, all enrollees) | When PSEO coverage is insufficient or need non-graduate outcomes |
| `education-data-source-ipeds` | Institution characteristics, enrollment, graduation rates | Contextualizing PSEO institutions; join on `unitid` |
| `education-data-explorer` | Parent discovery skill | Finding available endpoints |
| `education-data-query` | Data fetching | Downloading parquet/CSV files |

## Topic Index

| Topic | Reference File |
|-------|---------------|
| LEHD program overview | `./references/lehd-methodology.md` |
| Data matching process | `./references/lehd-methodology.md` |
| Differential privacy | `./references/lehd-methodology.md` |
| Percentile earnings | `./references/earnings-data.md` |
| Labor force attachment | `./references/earnings-data.md` |
| Cohort definitions | `./references/earnings-data.md` |
| Census Division employment | `./references/geographic-flows.md` |
| In-state employment | `./references/geographic-flows.md` |
| NAICS sector employment | `./references/industry-flows.md` |
| Industry code reference | `./references/industry-flows.md` |
| Variable names and codes | `./references/variable-definitions.md` |
| Status flags | `./references/variable-definitions.md` |
| State participation | `./references/state-coverage.md` |
| Coverage rates | `./references/state-coverage.md` |
| Data partners | `./references/state-coverage.md` |
| Mirror-based data download | Data Access section above |
| Bulk data download | Data Access section above |
