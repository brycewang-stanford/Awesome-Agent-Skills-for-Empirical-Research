# Variable Definitions

Complete reference for PSEO variables, codes, and status flags.

> **CRITICAL: Portal vs Census API Encoding**
>
> This document describes **Education Data Portal** integer encodings, which differ from Census API string codes. The Portal converts categorical variables to integers for consistency.
>
> | Context | Baccalaureate | Associates | Masters | Division Code |
> |---------|---------------|------------|---------|---------------|
> | **Portal (integers)** | `5` | `3` | `7` | `9` |
> | Census API (strings) | `05` | `03` | `07` | `9` |
>
> **Key Points:**
> - All variable names are **lowercase** in Portal data
> - `opeid` is an **integer**, not an 8-digit string
> - `cipcode` is a **2-digit integer** (e.g., `11` for Computer Science)
> - `industry` is a **String**, not an integer (e.g., `"54"`, `"31-33"`)
> - Missing data codes: `-1` (missing), `-2` (not applicable), `-3` (suppressed)
>
> **Truth Hierarchy:** When interpreting variable values, apply this priority:
> 1. **Actual data file** (what you observe in the parquet) -- this IS the truth
> 2. **Live codebook** (`.xls` in mirror, via `get_codebook_url()` from `fetch-patterns.md`) -- authoritative documentation, may lag
> 3. **This skill documentation** -- convenient summary, may drift from codebook
>
> If this documentation contradicts the codebook or observed data, trust the higher-priority source and flag the discrepancy.

## Contents

- [Identifier Variables](#identifier-variables)
- [Earnings Variables](#earnings-variables)
- [Flow Variables](#flow-variables)
- [Status Flags](#status-flags)
- [Degree Level Codes](#degree-level-codes)
- [CIP Codes](#cip-codes)
- [Institution Codes](#institution-codes)
- [Geography Codes](#geography-codes)
- [Aggregation Levels](#aggregation-levels)

## Identifier Variables

### Institution Identifiers (Portal Integer Encoding)

| Variable | Description | Type |
|----------|-------------|------|
| `unitid` | IPEDS Unit ID | Integer |
| `opeid` | Office of Postsecondary Education ID | Integer (not 8-digit string) |
| `fips` | State FIPS code of institution | Integer |

> **Note:** Portal uses `unitid` and `opeid` as integers. Census API uses `INSTITUTION` as 8-digit string (e.g., "00365800").

### Program Identifiers (Portal Integer Encoding)

| Variable | Description | Type |
|----------|-------------|------|
| `degree_level` | Type of credential | Integer (1-10) |
| `cipcode` | Classification of Instructional Programs | 2-digit integer |

### Cohort Identifiers

| Variable | Description | Type |
|----------|-------------|------|
| `pseo_cohort` | Graduation cohort | String (e.g., `"2016-2020"`, `"2019-2021"`) |
| `year` | Academic year (fall semester) | Integer |
| `years_after_grad` | Years post-graduation | Integer (1, 5, or 10) |

## Earnings Variables (Portal Schema)

### Percentile Earnings

| Portal Variable | Description | Unit |
|-----------------|-------------|------|
| `p25_earnings` | 25th percentile earnings | 2022 dollars |
| `p50_earnings` | Median (50th percentile) earnings | 2022 dollars |
| `p75_earnings` | 75th percentile earnings | 2022 dollars |
| `years_after_grad` | Years post-graduation | `1`, `5`, or `10` |

> **Note:** Portal uses `years_after_grad` column to indicate timing. Census API embeds timing in variable names (Y1_*, Y5_*, Y10_*).

### Graduate Counts

| Portal Variable | Description |
|-----------------|-------------|
| `employed_grads_count_e` | Graduates with valid earnings |
| `total_grads_count` | Total IPEDS-reported graduates |

## Flow Variables (Portal Schema)

### Employment Counts

| Portal Variable | Description |
|-----------------|-------------|
| `employed_grads_count_f` | Employed graduates count |
| `employed_instate_grads_count` | Employed in institution's state |
| `jobless_m_emp_grads_count` | Non-employed or marginally employed |

### Industry Classification

| Portal Variable | Description |
|-----------------|-------------|
| `industry` | 2-digit NAICS sector (String, e.g., `"54"`, `"31-33"`, `"44-45"`) |

### Geography of Employment

| Portal Variable | Description |
|-----------------|-------------|
| `census_division` | Census Division code (1-9, 99 for aggregate) |

## Missing Data Codes (Portal Standard)

| Code | Meaning | When Used |
|------|---------|-----------|
| `-1` | Missing/not reported | Value unknown or not submitted |
| `-2` | Not applicable | Item doesn't apply to this record |
| `-3` | Suppressed | Data suppressed for privacy |

### Handling Missing Data in Portal PSEO Data

```python
import polars as pl

# Load PSEO data
df = pl.read_parquet("colleges_pseo_2020.parquet")

# Filter out missing earnings data
valid_earnings = df.filter(pl.col("p50_earnings") > 0)

# Check for suppressed values
suppressed = df.filter(pl.col("p50_earnings") == -3)

# Convert coded missing to null
df_clean = df.with_columns(
    pl.when(pl.col("p50_earnings") < 0)
    .then(None)
    .otherwise(pl.col("p50_earnings"))
    .alias("p50_earnings_clean")
)
```

## Degree Level Codes (Portal Integer Encoding)

| Code | Degree Level | CIP Level | Cohort Years |
|------|--------------|-----------|--------------|
| `1` | Certificate (< 1 year) | 4-digit | 5 |
| `2` | Certificate (1-2 years) | 4-digit | 5 |
| `3` | Associate's | 4-digit | 5 |
| `4` | Certificate (2-4 years) | 4-digit | 5 |
| `5` | Bachelor's | 4-digit | 3 |
| `6` | Post-Bacc Certificate | 4-digit | 5 |
| `7` | Master's | 2-digit only | 5 |
| `8` | Post-Masters Certificate | 4-digit | 5 |
| `9` | Doctoral-Research/Scholarship | 2-digit only | 5 |
| `10` | Doctoral-Professional Practice | 4-digit | 5 |
| `-1` | Missing/not reported | — | — |
| `-2` | Not applicable | — | — |
| `-3` | Suppressed data | — | — |

**Notes:**
- Bachelor's (`5`) is the default if not specified
- Master's and Doctoral-Research only have 2-digit CIP codes
- Cohort years affects valid cohort values

> **Census API comparison:** API uses string codes like "05", "1C", "07". Portal uses integers 1-10.

## CIP Codes (Portal Integer Encoding)

### CIP Level

| Level | Description | Portal Example |
|-------|-------------|----------------|
| 2-digit | Broad field | `11` = Computer and Information Sciences |

> **Note:** Portal data uses 2-digit integer CIP codes only (no decimal points).

### Common 2-Digit CIP Codes (Portal Integers)

| Code | Field |
|------|-------|
| `1` | Agriculture |
| `3` | Natural Resources and Conservation |
| `4` | Architecture |
| `5` | Area, Ethnic, Cultural, Gender Studies |
| `9` | Communication, Journalism |
| `10` | Communications Technologies |
| `11` | Computer and Information Sciences |
| `13` | Education |
| `14` | Engineering |
| `15` | Engineering Technologies |
| `16` | Foreign Languages, Literatures, Linguistics |
| `19` | Family and Consumer Sciences |
| `22` | Legal Professions and Studies |
| `23` | English Language and Literature |
| `24` | Liberal Arts and Sciences |
| `25` | Library Science |
| `26` | Biological and Biomedical Sciences |
| `27` | Mathematics and Statistics |
| `30` | Multi/Interdisciplinary Studies |
| `31` | Parks, Recreation, Leisure, Fitness |
| `38` | Philosophy and Religious Studies |
| `40` | Physical Sciences |
| `42` | Psychology |
| `43` | Homeland Security, Law Enforcement |
| `44` | Public Administration and Social Service |
| `45` | Social Sciences |
| `50` | Visual and Performing Arts |
| `51` | Health Professions |
| `52` | Business, Management, Marketing |
| `54` | History |
| `99` | All programs |
| `-1` | Missing/not reported |
| `-2` | Not applicable |
| `-3` | Suppressed data |

Full reference: [CIPCODE Labels (CSV)](https://lehd.ces.census.gov/data/schema/latest/label_cipcode.csv)

## Institution Codes (Portal Integer Encoding)

### Portal Format

In the Education Data Portal, institution identifiers use integers:

| Variable | Type | Example |
|----------|------|---------|
| `unitid` | Integer | `100751` (University of Alabama) |
| `opeid` | Integer | `105100` (not "00105100") |

> **Note:** Census API uses 8-digit OPEID strings (e.g., "00365800"). Portal stores as integer.

### Example UNITID Values

| unitid | Institution |
|--------|-------------|
| `228778` | University of Texas at Austin |
| `139755` | Georgia Institute of Technology |
| `170976` | University of Michigan - Ann Arbor |
| `110635` | University of California - Berkeley |

### Finding Institution Codes

1. [All PSEO Institution Codes (CSV)](https://lehd.ces.census.gov/data/pseo/latest_release/all/pseo_all_institutions.csv)
2. [Complete Institution Labels (CSV)](https://lehd.ces.census.gov/data/schema/latest/label_institution.csv)

## Geography Codes (Portal Integer Encoding)

### State FIPS Codes (`fips`)

| Code | State | Code | State |
|------|-------|------|-------|
| `1` | Alabama | `27` | Minnesota |
| `4` | Arizona | `29` | Missouri |
| `8` | Colorado | `30` | Montana |
| `9` | Connecticut | `36` | New York |
| `11` | District of Columbia | `39` | Ohio |
| `13` | Georgia | `40` | Oklahoma |
| `15` | Hawaii | `41` | Oregon |
| `17` | Illinois | `42` | Pennsylvania |
| `18` | Indiana | `44` | Rhode Island |
| `19` | Iowa | `45` | South Carolina |
| `22` | Louisiana | `46` | South Dakota |
| `23` | Maine | `48` | Texas |
| `25` | Massachusetts | `49` | Utah |
| `26` | Michigan | `51` | Virginia |
| `-1` | Missing | `54` | West Virginia |
| | | `55` | Wisconsin |
| | | `56` | Wyoming |

> **Note:** Portal uses integers (e.g., `1` not `"01"`). Missing values use `-1`.

Full reference: [State FIPS Labels (CSV)](https://lehd.ces.census.gov/data/schema/latest/label_fipsnum.csv)

### Census Division Codes (`census_division`)

| Code | Division |
|------|----------|
| `1` | New England |
| `2` | Middle Atlantic |
| `3` | East North Central |
| `4` | West North Central |
| `5` | South Atlantic |
| `6` | East South Central |
| `7` | West South Central |
| `8` | Mountain |
| `9` | Pacific |
| `99` | All divisions (aggregate) |

Full reference: [Division Labels (CSV)](https://lehd.ces.census.gov/data/schema/latest/label_geography_division.csv)

## Aggregation Levels

### AGG_LEVEL_PSEO

The `AGG_LEVEL_PSEO` variable indicates the combination of dimensions in a tabulation:

| Code | Dimensions Included |
|------|---------------------|
| `38` | Institution + Degree + CIP + Cohort |
| Other codes | Various combinations |

Use to filter for specific aggregation patterns in bulk data.

### Default Values

In Portal data, there are no implicit defaults -- you must filter explicitly. For reference, the Census API defaults are:

| Census API Parameter | Default Value | Portal Equivalent |
|---------------------|---------------|-------------------|
| `DEGREE_LEVEL` | `05` (Bachelor's) | `degree_level == 5` |
| `CIP_LEVEL` | `2` | Portal uses 2-digit CIP only |
| `GRAD_COHORT_YEARS` | `3` (if Bachelor's) or `5` | Implicit in `pseo_cohort` string |
| `INST_LEVEL` | `I` (Individual institution) | Not applicable in Portal |

## Schema Reference Files

| File | URL |
|------|-----|
| Complete schema | `lehd.ces.census.gov/data/schema/latest/lehd_public_use_schema.html` |
| Earnings variables | `lehd.ces.census.gov/data/schema/latest/variables_pseoe.csv` |
| Flows variables | `lehd.ces.census.gov/data/schema/latest/variables_pseof.csv` |
| All labels | `lehd.ces.census.gov/data/schema/latest/` (browse directory) |
