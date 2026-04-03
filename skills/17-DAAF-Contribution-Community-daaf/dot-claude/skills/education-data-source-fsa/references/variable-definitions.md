# FSA Variable Definitions

Comprehensive reference for variables available in FSA datasets through the Urban Institute Education Data Portal.

> **CRITICAL: Portal Integer Encoding**
>
> This document describes **Education Data Portal** integer encodings. The Portal converts categorical variables to integers for consistency across sources. All parquet files contain integer-typed categorical columns.
>
> | Variable | Portal (integers) | Original FSA |
> |----------|-------------------|--------------|
> | `grant_type` | `1`, `2`, `3`, `4`, `5` | Descriptive text |
> | `loan_type` | `1`-`14` | Descriptive text |
> | `award_type` | `1`, `2`, `3` | Descriptive text |
> | `allocation_flag` | `0`, `1` | Yes/No |
>
> **Missing data codes** (`-1`, `-2`, `-3`) apply to `numeric` format variables only. Categorical variables use the specific codes documented below.

## Contents

- [Overview](#overview)
- [Grants Dataset Variables](#grants-dataset-variables)
- [Loans Dataset Variables](#loans-dataset-variables)
- [Campus-Based Volume Variables](#campus-based-volume-variables)
- [Financial Responsibility Variables](#financial-responsibility-variables)
- [90/10 Revenue Variables](#9010-revenue-variables)
- [Common Identifiers](#common-identifiers)
- [Missing Data Codes](#missing-data-codes)

## Overview

> **Codebook Authority:** This file summarizes variable definitions for convenience. The authoritative source is the codebook `.xls` file for each dataset (see codebook paths in SKILL.md "Data Access" section). Use `get_codebook_url()` from `fetch-patterns.md` to construct download URLs. If this file contradicts observed data or the codebook, trust the higher-priority source per the Truth Hierarchy in SKILL.md.

FSA data in the Education Data Portal is organized into five datasets, each with specific variables related to Title IV aid programs. Data is accessed via the Portal mirrors (see `mirrors.yaml` for configuration, `datasets-reference.md` for canonical paths, `fetch-patterns.md` for fetch code).

### Dataset Summary

| Dataset | Canonical Path | Years | Approx Records |
|---------|---------------|-------|----------------|
| Grants | `fsa/colleges_fsa_grants` | 1999-2021 | ~608K total |
| Loans | `fsa/colleges_fsa_loans` | 1999-2021 | ~1.6M total |
| Campus-Based Volume | `fsa/colleges_fsa_campus_based_volume` | 2001-2021 | ~248K total |
| Financial Responsibility | `fsa/colleges_fsa_composite_scores` | 2006-2016 | ~38K total |
| 90/10 Revenue Percentages | `fsa/colleges_fsa_90_10_revenue_percentages` | 2014-2021 | ~14K total |

## Grants Dataset Variables

Canonical path: `fsa/colleges_fsa_grants` | Codebook: `fsa/codebook_colleges_fsa_grants`

### Identification Variables

| Variable | Type | Description |
|----------|------|-------------|
| `unitid` | Int64 | IPEDS institution identifier (6-digit) |
| `year` | Int64 | Academic award year (fall start year) |
| `fips` | Int64 | State FIPS code (integer) |
| `opeid` | Int64 | 8-digit Office of Postsecondary Education ID |
| `inst_name_fsa` | String | Institution name (FSA) |

### Grant Type Variable (Portal Integer Encoding)

| Code | Grant Type |
|------|------------|
| `1` | Federal Pell Grant |
| `2` | Federal Supplemental Educational Opportunity Grant (FSEOG) |
| `3` | TEACH Grant |
| `4` | Iraq and Afghanistan Service Grant |
| `5` | Children of Fallen Heroes Grant |

### Grant Amount Variables

| Variable | Type | Description | Units |
|----------|------|-------------|-------|
| `grant_type` | Int64 | Type of Title IV grant (see codes above) | Code |
| `grant_recipients_unitid` | Float64 | Grant recipients by unit ID | Count |
| `value_grants_disbursed_unitid` | Float64 | Grants disbursed by unit ID | Dollars |
| `grant_recipients_opeid` | Float64 | Grant recipients by OPEID | Count |
| `value_grants_disbursed_opeid` | Float64 | Grants disbursed by OPEID | Dollars |
| `allocation_flag` | Int64 | Allocated across multiple unit IDs (0=No, 1=Yes) | Code |
| `combined_flag` | Int64 | Combined from multiple OPEIDs (0=No, 1=Yes) | Code |
| `other_assoc_opeids` | String | Other associated OPEIDs | Text |

### Example Query

```python
import polars as pl

# Fetch grants data via mirror system
df = fetch_from_mirrors("fsa/colleges_fsa_grants")

# Get Pell Grant data for California in 2020
df_pell_ca = df.filter(
    (pl.col("grant_type") == 1) &  # 1 = Pell Grant
    (pl.col("fips") == 6) &         # 6 = California
    (pl.col("year") == 2020)
)
```

## Loans Dataset Variables

Canonical path: `fsa/colleges_fsa_loans` | Codebook: `fsa/codebook_colleges_fsa_loans`

### Identification Variables

| Variable | Type | Description |
|----------|------|-------------|
| `unitid` | Int64 | IPEDS institution identifier |
| `year` | Int64 | Academic award year |
| `fips` | Int64 | State FIPS code (integer) |
| `opeid` | Int64 | 8-digit Office of Postsecondary Education ID |
| `inst_name_fsa` | String | Institution name (FSA) |

### Loan Type Variable (Portal Integer Encoding)

| Code | Loan Type |
|------|-----------|
| `1` | Subsidized Direct Loan - Undergraduate |
| `2` | Subsidized Direct Loan - Graduate |
| `3` | Subsidized Direct Loan - Total |
| `4` | Unsubsidized Direct Loan - Undergraduate |
| `5` | Unsubsidized Direct Loan - Graduate |
| `6` | Unsubsidized Direct Loan - Total |
| `7` | Direct Loan, Parent PLUS |
| `8` | Direct Loan, Grad PLUS |
| `9` | Direct Loan PLUS (sum of Parent PLUS and Grad PLUS) |
| `10` | Subsidized Federal Family Education Loans |
| `11` | Unsubsidized Federal Family Education Loans |
| `12` | Parent PLUS Federal Family Education Loans |
| `13` | Grad PLUS Federal Family Education Loans |
| `14` | PLUS Federal Family Education Loans |

### Loan Amount Variables

| Variable | Type | Description | Units |
|----------|------|-------------|-------|
| `loan_type` | Int64 | Type of Title IV loan (see codes above) | Code |
| `loan_recipients_unitid` | Float64 | Loan recipients by unit ID | Count |
| `num_loans_disbursed_unitid` | Float64 | Number of loans disbursed by unit ID | Count |
| `num_loans_originated_unitid` | Float64 | Number of loans originated by unit ID | Count |
| `value_loans_originated_unitid` | Float64 | Loans originated by unit ID | Dollars |
| `value_loan_disbursements_unitid` | Float64 | Loans disbursed by unit ID | Dollars |
| `loan_recipients_opeid` | Float64 | Loan recipients by OPEID | Count |
| `num_loans_disbursed_opeid` | Float64 | Number of loans disbursed by OPEID | Count |
| `num_loans_originated_opeid` | Float64 | Number of loans originated by OPEID | Count |
| `value_loans_originated_opeid` | Float64 | Loans originated by OPEID | Dollars |
| `value_loan_disbursements_opeid` | Float64 | Loans disbursed by OPEID | Dollars |
| `allocation_flag` | Int64 | Allocated across multiple unit IDs (0=No, 1=Yes) | Code |
| `combined_flag` | Int64 | Combined from multiple OPEIDs (0=No, 1=Yes) | Code |
| `other_assoc_opeids` | String | Other associated OPEIDs | Text |

### Example Query

```python
import polars as pl

# Fetch loans data via mirror system
df = fetch_from_mirrors("fsa/colleges_fsa_loans")

# Get Direct Subsidized Undergraduate loan data for a specific institution
df_sub = df.filter(
    (pl.col("loan_type") == 1) &     # 1 = Subsidized Direct Loan - Undergraduate
    (pl.col("unitid") == 110635)
)

# Get all Parent PLUS loans
df_plus = df.filter(pl.col("loan_type") == 7)  # 7 = Parent PLUS
```

## Campus-Based Volume Dataset Variables

Canonical path: `fsa/colleges_fsa_campus_based_volume` | Codebook: `fsa/codebook_colleges_fsa_campus_based_volume`

### Identification Variables

| Variable | Type | Description |
|----------|------|-------------|
| `unitid` | Int64 | IPEDS institution identifier |
| `year` | Int64 | Academic award year |
| `fips` | Int64 | State FIPS code (integer) |
| `opeid` | Int64 | 8-digit Office of Postsecondary Education ID |
| `inst_name_fsa` | String | Institution name (FSA) |

### Award Type Variable (Portal Integer Encoding)

| Code | Award Type |
|------|------------|
| `1` | Federal Supplemental Educational Opportunity Grants (FSEOG) |
| `2` | Federal Work-Study (FWS) |
| `3` | Perkins Loans (discontinued after 2017) |

### Campus-Based Amount Variables

| Variable | Type | Description | Units |
|----------|------|-------------|-------|
| `award_type` | Int64 | Type of campus-based award (see codes above) | Code |
| `campus_award_recipients_unitid` | Float64 | Recipients by unit ID | Count |
| `value_campus_disbursed_unitid` | Float64 | Awards disbursed by unit ID | Dollars |
| `campus_award_fed_contr_unitid` | Float64 | Federal contribution by unit ID | Dollars |
| `campus_award_recipients_opeid` | Float64 | Recipients by OPEID | Count |
| `value_campus_disbursed_opeid` | Float64 | Awards disbursed by OPEID | Dollars |
| `campus_award_fed_contr_opeid` | Float64 | Federal contribution by OPEID | Dollars |
| `allocation_flag` | Int64 | Allocated across multiple unit IDs (0=No, 1=Yes) | Code |
| `combined_flag` | Int64 | Combined from multiple OPEIDs (0=No, 1=Yes) | Code |
| `other_assoc_opeids` | String | Other associated OPEIDs | Text |

**Note**: Perkins Loan program discontinued; no new loans after September 30, 2017.

### Example Query

```python
import polars as pl

# Fetch campus-based data via mirror system
df = fetch_from_mirrors("fsa/colleges_fsa_campus_based_volume")

# Get Federal Work-Study data for 2020
df_fws = df.filter(
    (pl.col("award_type") == 2) &  # 2 = Federal Work-Study
    (pl.col("year") == 2020)
)

# Get FSEOG data
df_fseog = df.filter(pl.col("award_type") == 1)  # 1 = FSEOG
```

## Financial Responsibility Dataset Variables

Canonical path: `fsa/colleges_fsa_composite_scores` | Codebook: `fsa/codebook_colleges_fsa_financial_responsibility`

> **Naming mismatch:** Data path uses `composite_scores`; codebook uses `financial_responsibility`. This is intentional.

### Identification Variables

| Variable | Type | Description |
|----------|------|-------------|
| `unitid` | Int64 | IPEDS institution identifier |
| `year` | Int64 | Fiscal year |
| `fips` | Int64 | State FIPS code (integer) |
| `opeid` | Int64 | 8-digit Office of Postsecondary Education ID |
| `inst_name_fsa` | String | Institution name (FSA) |
| `inst_group_name` | String | Institution group name (if applicable) |

### Composite Score Variables

| Variable | Type | Description | Range |
|----------|------|-------------|-------|
| `financial_resp_score` | Float64 | Overall financial responsibility score | -1.0 to 3.0 |
| `multicampus_flag` | Int64 | Multicampus indicator | 1 when true; null otherwise (true-only flag — value 0 is not used) |

### Score Interpretation

| Composite Score | Classification |
|-----------------|----------------|
| ≥ 1.5 | Financially Responsible |
| 1.0 - 1.49 | In the Zone |
| < 1.0 | Not Financially Responsible |

### Example Query

```python
import polars as pl

# Fetch financial responsibility data via mirror system
df = fetch_from_mirrors("fsa/colleges_fsa_composite_scores")

# Get institutions in the "zone" (1.0 to 1.49)
df_zone = df.filter(
    (pl.col("financial_resp_score") >= 1.0) &
    (pl.col("financial_resp_score") < 1.5)
)

# Get institutions not financially responsible
df_at_risk = df.filter(pl.col("financial_resp_score") < 1.0)
```

## 90/10 Revenue Dataset Variables

Canonical path: `fsa/colleges_fsa_90_10_revenue_percentages` | Codebook: `fsa/codebook_colleges_fsa_90-10_revenue_percentages`

> **Naming mismatch:** Data path uses underscores (`90_10`); codebook uses hyphens (`90-10`). This is intentional.

### Identification Variables

| Variable | Type | Description |
|----------|------|-------------|
| `unitid` | Int64 | IPEDS institution identifier |
| `year` | Int64 | Fiscal year |
| `fips` | Int64 | State FIPS code (integer) |
| `opeid` | Int64 | 8-digit Office of Postsecondary Education ID |
| `inst_name_fsa` | String | Institution name (FSA) |

### Revenue Variables

| Variable | Type | Description | Units |
|----------|------|-------------|-------|
| `rev_pct_90_10` | Float64 | 90/10 revenue percentage | **Proportion (0-1)**, NOT percent (0-100) |
| `numerator_90_10` | Float64 | Title IV revenue (numerator) | Dollars (null for ~17 rows) |
| `denominator_90_10` | Float64 | Total revenue (denominator) | Dollars (null for ~17 rows) |

> **CRITICAL: Proportion, not percentage.** `rev_pct_90_10` is stored as a proportion (e.g., 0.87 means 87%). The compliance threshold is `rev_pct_90_10 > 0.90`, NOT `> 90`.

### Calculated Relationship

```
rev_pct_90_10 = numerator_90_10 / denominator_90_10
```

(The result is a proportion, not multiplied by 100.)

### Compliance Interpretation

| Title IV Proportion | Equivalent Percentage | Status |
|--------------------|----------------------|--------|
| <= 0.90 | <= 90% | Compliant |
| > 0.90 (1 year) | > 90% | Provisional |
| > 0.90 (2 consecutive years) | > 90% | Ineligible |

### Example Query

```python
import polars as pl

# Fetch 90/10 data via mirror system
df = fetch_from_mirrors("fsa/colleges_fsa_90_10_revenue_percentages")

# Get institutions near the threshold (85%+ = 0.85 as proportion)
df_at_risk = df.filter(pl.col("rev_pct_90_10") >= 0.85)

# Get apparent violations (>90% = 0.90 as proportion)
df_violations = df.filter(pl.col("rev_pct_90_10") > 0.90)
```

## Common Identifiers

### Primary Keys

| Identifier | Format | Description | Example |
|------------|--------|-------------|---------|
| `unitid` | 6-digit integer | IPEDS institution ID | 110635 |
| `year` | 4-digit integer | Academic/fiscal year | 2018 |

### Geographic Identifiers

| Identifier | Format | Description | Example |
|------------|--------|-------------|---------|
| `fips` | 1-2 digit integer | State FIPS code | 6 (California) |

### Common FIPS Codes

| FIPS | State | FIPS | State |
|------|-------|------|-------|
| 1 | Alabama | 36 | New York |
| 6 | California | 39 | Ohio |
| 12 | Florida | 44 | Rhode Island |
| 17 | Illinois | 48 | Texas |
| 25 | Massachusetts | 53 | Washington |

## Missing Data Codes

FSA data uses standard Education Data Portal missing data codes:

| Code | Meaning |
|------|---------|
| -1 | Not reported |
| -2 | Not applicable |
| -3 | Suppressed due to small cell size |
| `null` | No data available |

### Handling Missing Data

When analyzing FSA data:

```python
import polars as pl

# Filter out missing sentinel values from numeric columns
df = df.filter(~pl.col("grant_recipients_unitid").is_in([-1, -2, -3]))

# Or filter to positive values only
df = df.filter(pl.col("grant_recipients_unitid") > 0)

# Replace sentinel values with null
df = df.with_columns(
    pl.when(pl.col("grant_recipients_unitid").is_in([-1, -2, -3]))
    .then(None)
    .otherwise(pl.col("grant_recipients_unitid"))
    .alias("grant_recipients_unitid")
)
```

## Variable Naming Conventions

FSA Portal variables use **generic column names** with type code columns to differentiate programs. There are no program-specific column names (e.g., no `pell_recipients` or `dl_sub_recipients`).

| Pattern | Meaning | Example |
|---------|---------|---------|
| `*_recipients_unitid` | Count of aid recipients (by unit ID) | `grant_recipients_unitid`, `loan_recipients_unitid` |
| `*_recipients_opeid` | Count of aid recipients (by OPEID) | `grant_recipients_opeid`, `loan_recipients_opeid` |
| `value_*_disbursed_unitid` | Total dollars disbursed (by unit ID) | `value_grants_disbursed_unitid` |
| `value_*_disbursed_opeid` | Total dollars disbursed (by OPEID) | `value_grants_disbursed_opeid` |
| `*_fed_contr_*` | Federal contribution amount | `campus_award_fed_contr_unitid` |
| `*_flag` | Boolean indicator | `allocation_flag`, `combined_flag`, `multicampus_flag` |
| `*_type` | Program type code (integer) | `grant_type`, `loan_type`, `award_type` |
| `financial_resp_score` | Financial responsibility composite score | `financial_resp_score` |
| `rev_pct_90_10` | 90/10 revenue proportion | `rev_pct_90_10` |

## Data Type Considerations

### Integer Variables

- Recipient counts
- Year values
- FIPS codes
- Unit IDs

### Float Variables

- Dollar amounts (disbursements, allocations)
- Percentages
- Ratios
- Composite scores

### String Variables

- Institution names (from joined IPEDS data)
- State names (when labels applied)

## Common Calculations

### Per-Student Metrics (join with IPEDS enrollment)

```
Pell per undergraduate = pell_disbursements / undergraduate_enrollment
Loan per student = dl_total_disbursements / total_enrollment
```

### Year-over-Year Changes

```
pell_growth = (pell_recipients_2018 - pell_recipients_2017) / pell_recipients_2017
disbursement_change = pell_disbursements_2018 - pell_disbursements_2017
```

### Sector Aggregations (join with IPEDS)

```
Group by inst_control:
- Total Pell recipients by sector
- Average loan amount by institution type
- Distribution of composite scores
```

## Polars Query Patterns

### Basic Filters

```python
import polars as pl

# Single filter
df.filter(pl.col("fips") == 6)

# Multiple filters
df.filter(
    (pl.col("fips") == 6) &
    (pl.col("year") == 2020)
)

# Comparison operators
df.filter(pl.col("financial_resp_score") < 1.5)
df.filter(pl.col("rev_pct_90_10") >= 85)
```

### Aggregations

```python
# Total grants by state
df.group_by("fips").agg(
    pl.col("value_grants_disbursed_unitid").sum().alias("total_grants")
)

# Average by year
df.group_by("year").agg(
    pl.col("value_grants_disbursed_unitid").mean().alias("avg_grant")
)
```
