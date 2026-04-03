# MEPS Variable Definitions

Comprehensive definitions of all variables in the MEPS dataset, including identifiers, estimates, and metadata.

> **Codebook Authority:** The variable definitions in this document are summaries for convenience.
> The authoritative source for variable names, codes, and definitions is the codebook `.xls` file
> available in the data mirrors. Use `get_codebook_url("meps/codebook_schools_meps")` from `fetch-patterns.md`
> to download the codebook. If this document contradicts the codebook, trust the codebook and
> flag the discrepancy.

> **CRITICAL: Portal Integer Encoding**
>
> This document describes **Education Data Portal** encodings. The Portal returns all ID and categorical columns as **integers**, not strings. Missing values use **native nulls**, not negative coded values.
>
> | Column | Portal Type | Documentation May Say | Actual Portal Value |
> |--------|-------------|----------------------|---------------------|
> | `ncessch` | Int64 | "12-character string" | `10000200277` (integer) |
> | `fips` | Int64 | "FIPS code" | `6` (integer for California) |
> | `leaid` | Int64 | "7-character string" | `100002` (integer) |
> | Missing | null | "-1, -2, -3" | Native null (no coded values) |

## Core MEPS Variables

### School Identifier

| Variable | Portal Type | Description |
|----------|-------------|-------------|
| `ncessch` | **Int64** | NCES school identification number. Unique identifier for each school. Structure: {2-digit state FIPS}{5-digit district}{5-digit school} |
| `ncessch_num` | **Int64** | Numeric duplicate of NCES school ID (same values) |

**Example**: `60000100001` (as integer)
- `06` = California (state FIPS)
- `00001` = District code
- `00001` = School code

> **Note:** Portal returns as integer. Leading zeros are implicit. To reconstruct 12-character string: `f"{ncessch:012d}"`

### Geographic Identifiers (Portal Integer Encoding)

| Variable | Portal Type | Description |
|----------|-------------|-------------|
| `fips` | **Int64** | Federal Information Processing Standard state code (1-56) |
| `leaid` | **Int64** | Local Education Agency (district) ID (7-digit structure, returned as integer) |
| `gleaid` | **Int64** | Geographic Local Education Agency ID |
| `year` | **Int64** | School year (fall semester). Example: 2018 = 2018-19 school year |

> **Note:** All IDs returned as integers. To reconstruct 7-character string for leaid: `f"{leaid:07d}"`

### MEPS Estimates (Portal Field Names)

| Portal Variable | Type | Range | Description |
|-----------------|------|-------|-------------|
| `meps_poverty_pct` | Float64 | 0.0-60.5 | Estimated share of students from households at or below 100% FPL |
| `meps_mod_poverty_pct` | Float64 | 0.0-100.0 | Modified MEPS estimate (adjusted for high-poverty districts) |
| `meps_poverty_se` | Float64 | 0.5-3.8 | Standard error of the MEPS estimate |
| `meps_poverty_ptl` | Int64 | 1-100 | National percentile of poverty (enrollment-weighted) |
| `meps_mod_poverty_ptl` | Int64 | 1-100 | Modified percentile (enrollment-weighted) |

> **Field name mapping:** Documentation may reference `meps`, `meps_mod`, `meps_se`. Actual Portal fields are `meps_poverty_pct`, `meps_mod_poverty_pct`, `meps_poverty_se`.

## Understanding MEPS Values

### `meps_poverty_pct`

The primary poverty estimate. Interpretation:
- `meps_poverty_pct = 25.0` means 25% of students estimated to be in poverty (at or below 100% FPL)
- Values range from 0.0 to 60.5 (percentage scale)
- National average is approximately 15-20%

### `meps_mod_poverty_pct`

Modified estimate for schools in high-poverty districts:
- Adjusts for systematic underestimation in the original model
- Generally higher than `meps_poverty_pct` for high-poverty schools
- Use when focusing on high-poverty populations
- Range: 0.0-100.0%

### `meps_poverty_se`

Standard error quantifying estimation uncertainty (on the same percentage scale as `meps_poverty_pct`):
- Smaller values = more precise estimates
- Larger values = less certainty about the point estimate
- Use for confidence intervals and statistical comparisons
- Actual observed range: 0.52-3.77

**Calculating confidence intervals:**
```
95% CI = meps_poverty_pct +/- (1.96 x meps_poverty_se)
```

## Poverty Threshold: 100% FPL

### Federal Poverty Level (FPL)

MEPS uses 100% of the Federal Poverty Level as its threshold:

| Family Size | 100% FPL (2024) | 130% FPL | 185% FPL |
|-------------|-----------------|----------|----------|
| 1 | $15,060 | $19,578 | $27,861 |
| 2 | $20,440 | $26,572 | $37,814 |
| 3 | $25,820 | $33,566 | $47,767 |
| 4 | $31,200 | $40,560 | $57,720 |
| 5 | $36,580 | $47,554 | $67,673 |
| 6 | $41,960 | $54,548 | $77,626 |

**Note**: FPL is updated annually by the Department of Health and Human Services.

### Comparison to Other Thresholds

| Measure | Threshold | Meaning |
|---------|-----------|---------|
| MEPS | 100% FPL | Official poverty line |
| FRPL Free | 130% FPL | Free lunch eligibility |
| FRPL Reduced | 185% FPL | Reduced-price lunch eligibility |
| Near poverty | 200% FPL | Common research threshold |

**Key implication**: MEPS captures **deeper poverty** than FRPL. Schools may have low MEPS but higher FRPL if many families are 100-185% FPL.

## Missing Data Handling

> **CRITICAL: MEPS Uses Native Nulls**
>
> Unlike CCD and other sources, MEPS data in the Portal uses **native null values**, not negative coded values. The codebook lists -1, -2, -3 as theoretical possibilities, but actual Portal data contains nulls.

**Codebook codes (theoretical):**
| Code | Meaning |
|------|---------|
| `-1` | Missing/not reported |
| `-2` | Not applicable |
| `-3` | Suppressed for privacy |

**Actual Portal behavior:**
| Value | Meaning |
|-------|---------|
| `null` | Missing/not available (all missing types) |
| Valid number | Data present |

**Handling missing data (correct approach):**
```python
import polars as pl

# Filter to non-null values
valid_data = df.filter(pl.col("meps_poverty_pct").is_not_null())

# Count missing
null_count = df["meps_poverty_pct"].null_count()
```

**Do NOT use negative value filtering for MEPS:**
```python
# WRONG - MEPS doesn't use coded values
df.filter(pl.col("meps_poverty_pct") >= 0)  # Unnecessary and misleading
```

## Derived Variables

### Creating Categorical Poverty Measures

MEPS is continuous; create categories as needed:

```python
import polars as pl

# Policy-relevant thresholds
df = df.with_columns([
    (pl.col("meps_poverty_pct") >= 30.0).alias("high_poverty"),
    (pl.col("meps_poverty_pct") < 10.0).alias("low_poverty"),
])

# Title I style categories
df = df.with_columns(
    pl.when(pl.col("meps_poverty_pct") >= 40.0).then(pl.lit("Very High"))
    .when(pl.col("meps_poverty_pct") >= 25.0).then(pl.lit("High"))
    .when(pl.col("meps_poverty_pct") >= 10.0).then(pl.lit("Moderate"))
    .otherwise(pl.lit("Low"))
    .alias("poverty_level")
)
```

### School-Level Poverty Count

Estimate the number of students in poverty (requires joining with CCD enrollment data first):

```python
# After joining MEPS with CCD enrollment on ncessch + year:
df = df.with_columns(
    (pl.col("meps_poverty_pct") / 100.0 * pl.col("enrollment")).round(0).alias("poverty_count")
)
```

### District Aggregation

Aggregate school MEPS to district level (requires enrollment data from CCD join):

```python
# Enrollment-weighted district average
district_meps = (
    df.filter(pl.col("meps_poverty_pct").is_not_null() & pl.col("enrollment").is_not_null())
    .group_by("leaid")
    .agg(
        (pl.col("meps_poverty_pct") * pl.col("enrollment")).sum()
        / pl.col("enrollment").sum()
    ).rename({"meps_poverty_pct": "meps_weighted_avg"})
)
```

## Variable Relationships

### MEPS vs FRPL Conceptual Mapping

| FRPL Concept | MEPS Equivalent | Notes |
|--------------|-----------------|-------|
| % FRPL eligible | `meps_poverty_pct` | Different threshold (185% vs 100% FPL) |
| Free lunch % | No direct equivalent | MEPS doesn't distinguish free vs reduced |
| Reduced lunch % | No direct equivalent | Not separately estimated |
| FRPL count | `meps_poverty_pct / 100 * enrollment` | Approximate only (requires CCD join) |

### MEPS and Other Poverty Measures

| Other Measure | Relationship to MEPS | Correlation |
|---------------|---------------------|-------------|
| SAIPE (district) | MEPS calibrated to match | ~0.90 |
| Census tract poverty | Similar but geographic | ~0.70 |
| Title I status | Based on different criteria | ~0.65 |
| FRPL (non-CEP schools) | Related but different threshold | ~0.75 |
| FRPL (CEP schools) | Not comparable | Low/meaningless |

## Data Type Specifications (Portal Actual Types)

### Polars Schema (from actual Portal data)

```python
# Polars types - matches actual Portal parquet files
import polars as pl

meps_schema = {
    'year': pl.Int64,
    'fips': pl.Int64,
    'gleaid': pl.Int64,
    'ncessch': pl.Int64,           # Integer, not string!
    'meps_poverty_pct': pl.Float64,
    'meps_poverty_se': pl.Float64,
    'meps_mod_poverty_pct': pl.Float64,
    'meps_poverty_ptl': pl.Int64,
    'meps_mod_poverty_ptl': pl.Int64,
    'ncessch_num': pl.Int64,
    'leaid': pl.Int64,             # Integer, not string!
}
```

### SQL table definition

```sql
-- SQL table definition (INTEGER for IDs per Portal encoding)
CREATE TABLE meps (
    ncessch BIGINT NOT NULL,       -- 12-digit integer
    year INTEGER NOT NULL,
    fips INTEGER,
    leaid BIGINT,                  -- 7-digit integer, nullable
    gleaid BIGINT,
    meps_poverty_pct DECIMAL(6,4),
    meps_mod_poverty_pct DECIMAL(6,4),
    meps_poverty_se DECIMAL(8,6),
    meps_poverty_ptl INTEGER,
    meps_mod_poverty_ptl INTEGER,
    PRIMARY KEY (ncessch, year)
);
```

### Converting IDs to String Format

If you need traditional string-format IDs for joining with other systems:

```python
import polars as pl

# Convert integer IDs to zero-padded strings
df = df.with_columns([
    pl.col("ncessch").cast(pl.Utf8).str.zfill(12).alias("ncessch_str"),
    pl.col("leaid").cast(pl.Utf8).str.zfill(7).alias("leaid_str"),
])
```

## Quick Reference Card

| Portal Variable | What it tells you |
|-----------------|-------------------|
| `meps_poverty_pct` | Estimated share of students in poverty (100% FPL), as percentage |
| `meps_mod_poverty_pct` | Adjusted estimate for high-poverty districts |
| `meps_poverty_se` | How confident you can be in the estimate |
| `meps_poverty_ptl` | National percentile (enrollment-weighted, 1-100) |
| `meps_mod_poverty_ptl` | Modified percentile (enrollment-weighted, 1-100) |
| `ncessch` | Unique school identifier for joins (Int64) |
| `leaid` | District ID for aggregation (Int64) |
| `year` | Which school year |
| `fips` | Which state (Int64) |

**Most common usage:**
```python
import polars as pl

# "What's the poverty rate at this school?"
result = df.filter(pl.col("ncessch") == 60000100001).select("meps_poverty_pct")
# Returns value like 25.0 (meaning 25% estimated in poverty)
```
