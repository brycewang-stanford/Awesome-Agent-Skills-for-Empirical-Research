---
name: education-data-source-meps
description: >-
  MEPS — Urban Institute modeled school-level poverty (% at 100% FPL), from CCD + SAIPE (public schools, 2009-2022, 2-3yr lag). Use when FRPL is unreliable due to CEP. Consistent cross-state measurement. Public schools only.
metadata:
  audience: any-agent
  domain: data-source
  skill-authored: "2026-02-09"
  skill-last-updated: "2026-02-09"
---

# MEPS Data Source Reference

Model Estimates of Poverty in Schools (MEPS) — Urban Institute modeled estimates of school-level poverty (% students at or below 100% FPL), derived from CCD and Census SAIPE data (public schools, 2009-2022, 2-3 year lag). Use when analyzing school poverty rates, comparing poverty across states, or when FRPL data is unreliable due to CEP enrollment. Unlike FRPL, MEPS provides consistent cross-state measurement at a standardized 100% FPL threshold. Public schools only.

School-level poverty measure from the Urban Institute that is **comparable across states and time**, unlike Free/Reduced-Price Lunch (FRPL) data.

> **CRITICAL: Value Encoding**
>
> The Education Data Portal returns MEPS data with **integer-encoded** categorical and identifier columns. This differs from some external documentation:
>
> | Column | Portal Type | Example Value | Notes |
> |--------|-------------|---------------|-------|
> | `fips` | Int64 | `6` | State FIPS as integer (California = 6) |
> | `ncessch` | Int64 | `10000200277` | 12-digit NCES school ID as integer |
> | `leaid` | Int64 | `100002` | 7-digit district ID as integer |
> | `gleaid` | Int64 | `100013` | Geographic LEA ID as integer |
> | `year` | Int64 | `2018` | Academic year (fall semester) |
>
> **Missing values:** Unlike CCD, MEPS uses **native nulls** rather than negative coded values (-1, -2, -3). While the codebook lists these codes, actual Portal data contains nulls for missing values.
>
> See `./references/variable-definitions.md` for complete encoding tables.

## What is MEPS?

MEPS is a **modeled estimate** of the share of students from households with incomes at or below **100% of the Federal Poverty Level (FPL)**.

- **Purpose**: Provide consistent school poverty measurement across all US states
- **Key advantage**: Comparable across states (unlike FRPL which varies by state policy)
- **Data level**: School-level (individual schools)
- **Coverage**: 2009-2022 (actual Portal data range)
- **Source**: Urban Institute, derived from CCD and SAIPE data
- **Primary identifier**: `ncessch` (12-digit NCES school ID)
- **Public schools only**: Does not cover private schools

## Reference File Structure

| File | Purpose | When to Read |
|------|---------|--------------|
| `methodology.md` | How MEPS estimates are calculated | Understanding the model, research validation |
| `comparison-to-frpl.md` | Detailed FRPL vs MEPS comparison | Deciding which measure to use |
| `data-sources.md` | Input data (CCD, SAIPE, ISP) | Understanding data provenance |
| `variable-definitions.md` | MEPS variables and codes | Building queries, interpreting results |
| `data-quality.md` | Limitations, uncertainty, appropriate uses | Research design, caveats |

## Decision Trees

### Should I use MEPS or FRPL?

```
What is your research goal?
├─ Compare poverty across states → Use MEPS
│   └─ FRPL varies by state policy, MEPS is standardized
├─ Track poverty over time (post-2010) → Use MEPS
│   └─ CEP adoption makes FRPL inconsistent
├─ Study CEP/universal meals impact → Use both
│   └─ Compare MEPS (true poverty) vs FRPL (program participation)
├─ Match historical research (pre-2010) → Consider FRPL
│   └─ MEPS only available 2006+, but FRPL was more reliable then
├─ Need 185% FPL threshold → Use FRPL with caveats
│   └─ MEPS only measures 100% FPL
└─ Federal funding formulas → Check formula requirements
    └─ Some formulas mandate FRPL; note limitations
```

### Which MEPS variable should I use?

```
Which estimate type?
├─ Standard analysis → `meps_poverty_pct`
│   └─ Original modeled estimate
├─ High-poverty district adjustment → `meps_mod_poverty_pct`
│   └─ Modified MEPS for districts where model underestimates
├─ Need confidence bounds → `meps_poverty_se`
│   └─ Standard error for uncertainty analysis
└─ Categorical analysis → Derive from `meps_poverty_pct`
    └─ Create quartiles/quintiles as needed
```

### How do I access MEPS data?

```
Access method?
├─ Mirror download (recommended) → See "Data Access" section below
└─ Join with other data → Use `ncessch` as join key
```

## Quick Reference: MEPS Variables

> **Data Access:** MEPS data is fetched from mirrors (parquet/CSV). See `datasets-reference.md` for canonical paths, `mirrors.yaml` for mirror configuration, and `fetch-patterns.md` for fetch code patterns.

### Portal Field Names

The Portal field names differ from some external MEPS documentation:

| External Documentation | Portal Field Name |
|------------------------|-------------------|
| `meps` / `school_poverty` | `meps_poverty_pct` |
| `meps_mod` | `meps_mod_poverty_pct` |
| `meps_se` | `meps_poverty_se` |

### Variable Reference

All ID and categorical columns use **integer encoding** in Portal data:

| Variable | Description | Type | Range/Notes |
|----------|-------------|------|-------------|
| `ncessch` | NCES school ID (12-digit) | **Int64** | e.g., `10000200277` |
| `ncessch_num` | NCES school ID (numeric duplicate) | **Int64** | Same as ncessch |
| `year` | School year (fall) | **Int64** | 2009-2022 (actual data range) |
| `fips` | State FIPS code | **Int64** | 1-56 |
| `leaid` | District ID (7-digit) | **Int64** | e.g., `100002` |
| `gleaid` | Geographic LEA ID | **Int64** | e.g., `100013` |
| `meps_poverty_pct` | Estimated share in poverty (100% FPL) | Float64 | 0.0-60.5% (actual range) |
| `meps_mod_poverty_pct` | Modified MEPS estimate | Float64 | 0.0-100.0% |
| `meps_poverty_se` | Standard error of estimate | Float64 | 0.5-3.8 (typical range) |
| `meps_poverty_ptl` | National percentile (enrollment-weighted) | **Int64** | 1-100 |
| `meps_mod_poverty_ptl` | Modified percentile (enrollment-weighted) | **Int64** | 1-100 |

### Key Identifiers

| ID | Format | Level | Example | Notes |
|----|--------|-------|---------|-------|
| `ncessch` | Int64 (12-digit) | School | `10000200277` | Primary join key for school-level joins |
| `leaid` | Int64 (7-digit) | District | `100002` | Use for district-level joins (e.g., with SAIPE) |
| `gleaid` | Int64 | Geographic LEA | `100013` | Geographic LEA ID |
| `fips` | Int64 | State | `6` | State FIPS code |

### Missing Data Codes

| Code | Meaning | When Used |
|------|---------|-----------|
| `null` | Missing / Not available | All missing values — MEPS uses native nulls, not negative coded values |

**Important:** Unlike CCD and most other Portal sources, MEPS does **not** use `-1`, `-2`, `-3` coded values. Use null checks:
```python
# Correct
valid_data = df.filter(pl.col("meps_poverty_pct").is_not_null())

# Wrong (MEPS doesn't use -1, -2, -3 coded values)
# df.filter(pl.col("meps_poverty_pct") >= 0)  # Unnecessary
```

## Data Access

Datasets for MEPS are available via the mirror system. See `datasets-reference.md` for canonical paths, `mirrors.yaml` for mirror configuration, and `fetch-patterns.md` for fetch code patterns.

| Dataset | Type | Years | Path | Codebook |
|---------|------|-------|------|----------|
| School Poverty | Single | 2009-2022 | `meps/schools_meps` | `meps/codebook_schools_meps` |

Codebooks are `.xls` files co-located with data in all mirrors. Use `get_codebook_url()` from `fetch-patterns.md` to construct download URLs:

```python
url = get_codebook_url("meps/codebook_schools_meps")
```

> **Truth Hierarchy:** When interpreting variable values, apply this priority:
> 1. **Actual data file** (what you observe in the parquet/CSV) -- this IS the truth
> 2. **Live codebook** (.xls in mirror) -- authoritative documentation, may lag
> 3. **This skill documentation** -- convenient summary, may drift from codebook
>
> If this documentation contradicts the codebook, trust the codebook. If the codebook contradicts observed data, trust the data and investigate.

### Filtering

```python
# Filter to valid poverty estimates only (drop nulls)
df = df.filter(pl.col("meps_poverty_pct").is_not_null())

# High-poverty schools (top quartile nationally)
high_poverty = df.filter(pl.col("meps_poverty_ptl") >= 75)

# Use modified MEPS for high-poverty districts
df = df.with_columns(
    pl.when(pl.col("meps_mod_poverty_pct").is_not_null())
    .then(pl.col("meps_mod_poverty_pct"))
    .otherwise(pl.col("meps_poverty_pct"))
    .alias("poverty_pct_best")
)
```

## Common Pitfalls

| Pitfall | Issue | Solution |
|---------|-------|----------|
| Using negative value filters | Filtering `>= 0` to remove missing values; MEPS uses nulls, not `-1`/`-2`/`-3` | Use `.is_not_null()` instead of `>= 0` |
| Confusing MEPS with FRPL thresholds | MEPS measures 100% FPL; FRPL uses 130-185% FPL — rates are not comparable | State clearly which measure and threshold; never mix in same analysis |
| Using wrong field names | Documentation says `meps` but actual Portal field is `meps_poverty_pct` | Always use Portal field names: `meps_poverty_pct`, `meps_mod_poverty_pct`, `meps_poverty_se` |
| Ignoring standard errors | Treating MEPS as exact counts; they are modeled estimates with uncertainty | Use `meps_poverty_se` for close comparisons; flag when SE exceeds meaningful difference |
| Including private schools | MEPS only covers public schools; joining with datasets containing private schools inflates nulls | Filter to public schools before joining |
| Expecting recent data | MEPS has 2-3 year data lag; latest available may be several years behind | Check actual year range (2009-2022) before planning analysis |

## Why MEPS Instead of FRPL?

| Issue | FRPL Problem | MEPS Solution |
|-------|--------------|---------------|
| **CEP schools** | All students counted as "free lunch" regardless of income | Uses modeled estimates independent of meal programs |
| **State variation** | Different states use different eligibility criteria | Standardized 100% FPL threshold nationwide |
| **Direct certification** | Varies by state program participation | Calibrated to Census SAIPE data |
| **Income threshold** | 130-185% FPL (varies) | Consistent 100% FPL |
| **Time consistency** | Policy changes affect comparability over time | Methodology consistent across years |

**Critical insight**: As of 2020, ~60% of schools participate in CEP or other universal meal programs, making FRPL increasingly unreliable as a poverty proxy.

## Key Methodological Points

1. **Model-based**: MEPS uses a linear probability model, not direct counts
2. **Calibrated to SAIPE**: District totals align with Census poverty estimates
3. **School-specific**: Reflects enrolled students, not neighborhood demographics
4. **100% FPL threshold**: Lower than FRPL (185%) - captures deeper poverty
5. **Public schools only**: Does not cover private schools

## Common Use Cases

| Use Case | Recommended Approach |
|----------|---------------------|
| School poverty rankings | Use `meps_poverty_pct`, note `meps_poverty_se` for close comparisons |
| State-level aggregation | Sum weighted by enrollment |
| Poverty-achievement gaps | Join MEPS with EDFacts assessments on `ncessch` |
| Resource allocation analysis | Join MEPS with CCD finance on `leaid` |
| CEP impact research | Compare MEPS vs FRPL trends over time |
| Title I targeting analysis | Use `meps_poverty_pct` to identify high-poverty schools |

## Joining MEPS with Other Data

| Source | Join Key | Use Case |
|--------|----------|----------|
| CCD Directory | `ncessch`, `year` | Add school characteristics |
| CCD Enrollment | `ncessch`, `year` | Get enrollment for weighting |
| CRDC | `ncessch`, `year` | Discipline, AP courses + poverty |
| EDFacts | `ncessch`, `year` | Achievement + poverty analysis |
| SAIPE (district) | `leaid`, `year` | Validate against Census estimates |

## Limitations

- **Years available**: 2009-2022 (actual Portal data range)
- **Public schools only**: No private school coverage
- **Modeled estimates**: Subject to estimation error (use `meps_poverty_se`)
- **100% FPL only**: Does not capture near-poverty (100-185% FPL)
- **Not real-time**: 2-3 year data lag typical

## Related Data Sources

| Source | Relationship | When to Use |
|--------|--------------|-------------|
| `education-data-source-saipe` | District-level poverty (Census) | District-level analysis; MEPS calibration source |
| `education-data-source-ccd` | School/district characteristics | Join for enrollment, demographics, finance |
| `education-data-source-crdc` | Civil rights/discipline data | Join on `ncessch` for poverty + discipline analysis |
| `education-data-source-edfacts` | State assessment data | Join on `ncessch` for poverty + achievement analysis |
| `education-data-explorer` | Parent discovery skill | Finding available endpoints |
| `education-data-query` | Data fetching | Downloading MEPS parquet/CSV files |

## Topic Index

| Topic | Reference File |
|-------|---------------|
| Linear probability model | `./references/methodology.md` |
| SAIPE calibration | `./references/methodology.md` |
| Modified MEPS | `./references/methodology.md` |
| Validation evidence | `./references/methodology.md` |
| CEP impact on FRPL | `./references/comparison-to-frpl.md` |
| Direct certification | `./references/comparison-to-frpl.md` |
| State policy variation | `./references/comparison-to-frpl.md` |
| CCD data inputs | `./references/data-sources.md` |
| SAIPE data inputs | `./references/data-sources.md` |
| ISP data (MEPS 2.0) | `./references/data-sources.md` |
| Variable definitions | `./references/variable-definitions.md` |
| Poverty thresholds | `./references/variable-definitions.md` |
| Standard errors | `./references/data-quality.md` |
| Appropriate uses | `./references/data-quality.md` |
| Known limitations | `./references/data-quality.md` |
