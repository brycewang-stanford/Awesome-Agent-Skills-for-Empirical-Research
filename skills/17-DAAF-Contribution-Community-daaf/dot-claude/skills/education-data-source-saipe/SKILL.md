---
name: education-data-source-saipe
description: >-
  SAIPE — annual Census poverty estimates for school districts (Portal; county/state not in Portal). Use for district poverty, Title I context, or trends. ~18-month lag. No race/ethnicity disaggregation at district level — use ACS 5-year for that.
metadata:
  audience: any-agent
  domain: data-source
  skill-authored: "2026-02-09"
  skill-last-updated: "2026-02-09"
---

# SAIPE Data Source Reference

Census Bureau Small Area Income and Poverty Estimates (SAIPE) — annual model-based poverty estimates for school districts (Portal mirror; county and state data not in Portal). Use when district-level poverty is needed for Title I allocation interpretation, annual poverty trend analysis, or school-age children in poverty estimates. Estimates have ~18-month lag and no race/ethnicity disaggregation at district level — use ACS 5-year for race-disaggregated poverty.

Reference for understanding Census Bureau poverty estimates for school districts, counties, and states. SAIPE is the only annual, district-level poverty source and the legally mandated basis for Title I education funding allocations.

> **CRITICAL: Value Encoding**
>
> This document describes **Education Data Portal** integer encodings, which differ from Census Bureau raw file formats. The Portal uses integers for FIPS codes and standard missing data conventions.
>
> | Context | FIPS Alabama | FIPS California | Missing | Suppressed |
> |---------|--------------|-----------------|---------|------------|
> | **Portal (integers)** | `1` | `6` | `-1` | `-3` |
> | Census raw files | `01` (string) | `06` (string) | varies | varies |
>
> **Key difference:** Portal FIPS codes are integers (no leading zeros), while Census files use 2-character strings.
>
> See `./references/variable-definitions.md` for complete encoding tables.

## What is SAIPE?

SAIPE is the Census Bureau's program for producing **model-based** estimates of income and poverty:

- **Primary purpose**: Provide annual poverty estimates for Title I education funding allocations
- **Collector**: U.S. Census Bureau
- **Coverage**: All 50 states, 3,100+ counties, 13,000+ school districts
- **Key measure**: Related children ages 5-17 in families in poverty
- **Update frequency**: Annual (released each December, ~18-month lag)
- **Available years**: 1995-2023 (gaps at 1996, 1998; annual from 1999)
- **Primary identifier**: FIPS code + LEAID (district ID)
- **Methodology**: Model-based — combines ACS survey data with administrative records (IRS tax returns, SNAP data) using regression models with "shrinkage" techniques; school district estimates are allocated from county totals using within-county shares; all estimates contain uncertainty and confidence intervals are essential
- **Available through**: Education Data Portal mirrors (district-level only; state and county SAIPE are not in Portal mirrors — see Data Access section)

## Reference File Structure

| File | Purpose | When to Read |
|------|---------|--------------|
| `estimation-methodology.md` | How state/county models work | Understanding model inputs and outputs |
| `school-district-estimates.md` | How district estimates are derived | Working with school district data |
| `variable-definitions.md` | Variables, codes, population universes | Interpreting specific data fields |
| `data-quality.md` | Uncertainty, CV, limitations | Assessing estimate reliability |
| `historical-changes.md` | Methodology changes over time | Comparing across years |
| `comparison-other-sources.md` | SAIPE vs ACS, FRPL, CPS | Choosing between data sources |

## Decision Trees

### What do I need to understand?

```
Understanding SAIPE?
├─ How are estimates created?
│   ├─ State/county models → ./references/estimation-methodology.md
│   └─ School district shares → ./references/school-district-estimates.md
├─ What variables are available?
│   └─ Variable definitions → ./references/variable-definitions.md
├─ How reliable are estimates?
│   ├─ Confidence intervals → ./references/data-quality.md
│   └─ Small district uncertainty → ./references/data-quality.md
├─ Comparing data sources?
│   ├─ SAIPE vs FRPL → ./references/comparison-other-sources.md
│   ├─ SAIPE vs ACS → ./references/comparison-other-sources.md
│   └─ Why estimates differ → ./references/comparison-other-sources.md
└─ Year-to-year changes?
    ├─ Methodology breaks → ./references/historical-changes.md
    └─ Safe comparisons → ./references/historical-changes.md
```

### Common research questions

```
Research question?
├─ District poverty rate for Title I
│   ├─ Use SAIPE (official source for Title I)
│   └─ Note: rates use different numerator/denominator universes
├─ Compare district poverty over time
│   ├─ Check methodology breaks → ./references/historical-changes.md
│   └─ Cannot compare school districts pre/post 2010
├─ Why doesn't SAIPE match FRPL?
│   └─ Different income thresholds → ./references/comparison-other-sources.md
├─ Poverty by race/ethnicity in districts
│   └─ SAIPE does NOT provide race breakdowns for districts
│       Use ACS 5-year estimates instead
└─ Very small district reliability
    └─ Check CV by population size → ./references/data-quality.md
```

## Quick Reference: SAIPE Variables

### CRITICAL: Field Name Prefix

All SAIPE estimate columns in the Education Data Portal use the `est_` prefix:

| Short Name | Portal Column Name |
|------------|-------------------|
| `population_total` | `est_population_total` |
| `population_5_17` | `est_population_5_17` |
| `population_5_17_poverty` | `est_population_5_17_poverty` |
| `population_5_17_poverty_pct` | `est_population_5_17_poverty_pct` |

### Key Identifiers

| ID | Format | Level | Example | Notes |
|----|--------|-------|---------|-------|
| `fips` | Integer | State | `6` | State FIPS code (no leading zeros in Portal) |
| `leaid` | String | District | `0100005` | NCES district ID; join key to CCD |
| `year` | Integer | Time | `2022` | Estimate reference year |

### School District Estimates

| Variable | Description | Notes |
|----------|-------------|-------|
| `est_population_total` | Total population in district | Not enrollment - residential population |
| `est_population_5_17` | Children ages 5-17 | School-age population, all enrollment types |
| `est_population_5_17_poverty` | Related children 5-17 in families in poverty | Numerator for poverty calculations |
| `est_population_5_17_poverty_pct` | Percent of children 5-17 in poverty | **Not a true rate** - see notes |

### State/County Estimates (additional)

> **Not available in Portal mirrors.** The datasets below describe variables in SAIPE state and county files published by the Census Bureau. Only the **district-level** dataset (`saipe/districts_saipe`) is available in the Education Data Portal mirrors. These variables are listed for context only — they cannot be fetched via `fetch_from_mirrors()`.

| Variable | Description |
|----------|-------------|
| `population_0_4_poverty` | Children under 5 in poverty (states only) |
| `population_0_17_poverty` | All children under 18 in poverty |
| `population_poverty` | All ages in poverty |
| `median_household_income` | Median household income |

### Missing Data Codes

> **Empirical observation (2025):** The `districts_saipe` parquet file uses `null` for all missing/unavailable values. No negative integer codes (-1, -2, -3) were observed in any column. Verify against the live codebook if this changes in future releases.

| Code | Meaning | When Used |
|------|---------|-----------|
| `null` | Missing or unavailable | Estimate not produced for this district/year |

### When to Use SAIPE vs Alternatives

| Use Case | Best Source | Reason |
|----------|-------------|--------|
| Title I allocations | **SAIPE** | Legally mandated source |
| Annual district poverty | **SAIPE** | Only annual source for all districts |
| District poverty by race | ACS 5-year | SAIPE has no race breakdown |
| School-level poverty | ACS 5-year or FRPL | SAIPE is district-level only |
| Most current data | ACS 1-year | Lower lag (but fewer districts) |
| 5-year trends | Use caution | Methodology breaks exist |

### Confidence Intervals

State and county estimates include 90% confidence intervals. Interpretation:

```
Estimate: 5,000 children in poverty
90% CI: 4,200 - 5,800

Interpretation: We are 90% confident the true value falls
between 4,200 and 5,800.
```

**School district estimates do NOT have published confidence intervals** - use CV guidance:

| District Population | Median CV | Approximate 90% CI Width |
|---------------------|-----------|--------------------------|
| 0-2,500 | 0.67 | +/- 110% |
| 2,500-5,000 | 0.42 | +/- 69% |
| 5,000-10,000 | 0.35 | +/- 58% |
| 10,000-20,000 | 0.28 | +/- 46% |
| 20,000-65,000 | 0.23 | +/- 38% |
| 65,000+ | 0.15 | +/- 25% |

## Data Access

Datasets for SAIPE are available via the Education Data Portal mirror system. See `datasets-reference.md` for canonical paths, `mirrors.yaml` for mirror configuration, and `fetch-patterns.md` for fetch code patterns.

| Dataset | Type | Years | Path | Codebook |
|---------|------|-------|------|----------|
| District Poverty Estimates | Single | 1995-2023 (gaps: 1996, 1998) | `saipe/districts_saipe` | `saipe/codebook_districts_saipe` |

> **Only district-level SAIPE data is available in the Portal mirrors.** State and county SAIPE estimates are published by the Census Bureau but are not included in the Education Data Portal mirror system.

Codebooks are `.xls` files co-located with data in all mirrors. Use `get_codebook_url()` from `fetch-patterns.md` to construct download URLs:

```python
url = get_codebook_url("saipe/codebook_districts_saipe")
```

> **Truth Hierarchy:** When interpreting variable values, apply this priority:
> 1. **Actual data file** (what you observe in the parquet/CSV) — this IS the truth
> 2. **Live codebook** (.xls in mirror) — authoritative documentation, may lag
> 3. **This skill documentation** — convenient summary, may drift from codebook
>
> If this documentation contradicts the codebook, trust the codebook. If the codebook contradicts observed data, trust the data and investigate.

### Filtering

```python
# Filter to a specific state and year
df_state = df.filter(
    (pl.col("fips") == 6) & (pl.col("year") == 2022)
)

# Exclude null poverty estimates
df_valid = df.filter(
    pl.col("est_population_5_17_poverty").is_not_null()
)

# High-poverty districts (above 20%)
df_high = df.filter(
    pl.col("est_population_5_17_poverty_pct").is_not_null()
    & (pl.col("est_population_5_17_poverty_pct") >= 20)
)
```

## Common Pitfalls

| Pitfall | Issue | Solution |
|---------|-------|----------|
| Model-based estimates | Not direct counts; contain model uncertainty | Always use confidence intervals; check CV for small districts |
| ~18 month lag | 2023 estimates released Dec 2024; data never "current" | Accept lag for federal allocations; document vintage |
| No race/ethnicity | School district estimates are not disaggregated by demographics | Use ACS 5-year estimates for racial breakdowns |
| Not enrollment | Population-based (residential), not enrolled students | Different from FRPL counts; do not equate with enrollment |
| Boundary timing | May not reflect very recent district consolidations or splits | Check SDRP update cycle in `./references/historical-changes.md` |
| County allocation | Districts inherit county model uncertainty plus allocation uncertainty | Larger CV for small districts; use CV table for reliability |
| Missing `est_` prefix | Portal columns use `est_` prefix not shown in some documentation | Always use `est_`-prefixed column names when working with Portal data |
| Pre/post 2010 comparison | Methodology break at 2010 decennial update invalidates naive trends | Do not compare school district estimates across the 2010 boundary |

## Poverty Definition

SAIPE uses the **official Census Bureau poverty definition**:

- Poverty threshold based on family size and composition
- Cash income only (excludes non-cash benefits like SNAP)
- Pre-tax income
- 2023 threshold example: $30,900 for family of 4 with 2 children

**"Related children"** = persons ages 5-17 related to householder by birth, marriage, or adoption who live in families (excludes foster children, group quarters residents).

## Related Data Sources

| Source | Relationship | When to Use |
|--------|--------------|-------------|
| `education-data-source-meps` | Complementary poverty source (school-level) | School-level poverty estimates (MEPS) vs district-level (SAIPE) |
| `education-data-source-ccd` | K-12 enrollment and demographics | Join on LEAID for district enrollment alongside poverty |
| `education-data-source-nhgis` | Census/demographic data | ACS 5-year tables for race-disaggregated poverty |
| `education-data-explorer` | Parent discovery skill | Finding available endpoints and variables |
| `education-data-query` | Data fetching | Downloading parquet/CSV files from mirrors |

## Topic Index

| Topic | Reference File |
|-------|---------------|
| Model-based estimation | `./references/estimation-methodology.md` |
| Shrinkage estimators | `./references/estimation-methodology.md` |
| ACS integration | `./references/estimation-methodology.md` |
| Administrative records | `./references/estimation-methodology.md` |
| School district methodology | `./references/school-district-estimates.md` |
| Within-county shares | `./references/school-district-estimates.md` |
| Grade relevance | `./references/school-district-estimates.md` |
| Overlapping districts | `./references/school-district-estimates.md` |
| Variable definitions | `./references/variable-definitions.md` |
| Population universes | `./references/variable-definitions.md` |
| Poverty thresholds | `./references/variable-definitions.md` |
| Confidence intervals | `./references/data-quality.md` |
| Coefficient of variation | `./references/data-quality.md` |
| Small area uncertainty | `./references/data-quality.md` |
| Geocoding limitations | `./references/data-quality.md` |
| 2005 ACS switch | `./references/historical-changes.md` |
| 2010 decennial update | `./references/historical-changes.md` |
| Methodology breaks | `./references/historical-changes.md` |
| SAIPE vs FRPL | `./references/comparison-other-sources.md` |
| SAIPE vs ACS | `./references/comparison-other-sources.md` |
| Title I requirements | `./references/comparison-other-sources.md` |
