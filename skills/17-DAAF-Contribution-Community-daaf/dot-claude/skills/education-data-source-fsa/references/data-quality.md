# FSA Data Quality and Limitations

Reference for understanding data quality issues, coverage limitations, and timing considerations when working with FSA data in the Urban Institute Education Data Portal.

## Contents

- [Overview](#overview)
- [Year Coverage by Dataset](#year-coverage-by-dataset)
- [Institutional Coverage](#institutional-coverage)
- [Data Timing and Lag](#data-timing-and-lag)
- [Known Data Issues](#known-data-issues)
- [Missing Data Patterns](#missing-data-patterns)
- [Methodological Considerations](#methodological-considerations)
- [Data Source Comparison](#data-source-comparison)

## Overview

FSA data provides valuable information on federal student aid programs but has important limitations that analysts should understand before conducting research.

### Key Considerations

| Issue | Impact | Mitigation |
|-------|--------|------------|
| Data lag | 1-3 years behind current year | Note data vintage in analysis |
| Coverage gaps | Not all institutions in all datasets | Check institutional availability |
| Methodology changes | Calculation rules change over time | Document methods by year |
| Self-reported data | Subject to reporting errors | Cross-validate with other sources |

## Year Coverage by Dataset

### Available Years (Portal Mirror)

| Dataset Path | Earliest Year | Latest Year | Total Years |
|-------------|---------------|-------------|-------------|
| `fsa/colleges_fsa_grants` | 1999 | 2021 | 23 |
| `fsa/colleges_fsa_loans` | 1999 | 2021 | 23 |
| `fsa/colleges_fsa_campus_based_volume` | 2001 | 2021 | 21 |
| `fsa/colleges_fsa_composite_scores` | 2006 | 2016 | 11 |
| `fsa/colleges_fsa_90_10_revenue_percentages` | 2014 | 2021 | 8 |

### Timeline Visualization

```
         1999  2001  2006  2010  2014  2016  2021
Grants   |-----------------------------------------------|
Loans    |-----------------------------------------------|
Campus   |     |---------------------------------------------|
Fin Resp |          |---------------------|
90/10    |                    |-----------------------------|
```

### Data Currency

**Note**: Data is accessed via the Education Data Portal mirrors (see `mirrors.yaml` for mirror configuration, `datasets-reference.md` for canonical paths, `fetch-patterns.md` for fetch code).

## Institutional Coverage

### Title IV Participation Universe

FSA data covers institutions that:
- Are certified to participate in Title IV programs
- Have a valid Program Participation Agreement (PPA)
- Actually disbursed Title IV funds during the year

### Coverage by Sector

| Sector | Grants/Loans Coverage | Financial Responsibility | 90/10 |
|--------|----------------------|-------------------------|-------|
| Public 4-year | High | Limited* | N/A |
| Public 2-year | High | Limited* | N/A |
| Private nonprofit | High | Good | N/A |
| Private for-profit | High | Good | Complete |

*Public institutions often exempt from composite score requirements

### Institutions NOT in FSA Data

- Non-Title IV participating schools
- Schools that lost eligibility
- Schools that never disbursed aid in a given year
- Foreign institutions (even if Title IV eligible)
- Schools closed before data collection

### Institutional Count by Dataset (Approximate)

| Dataset | Records per Year | Unique Institutions |
|----------|------------------|---------------------|
| Grants | ~5,500-6,500 | Varies by year |
| Loans | ~5,500-6,500 | Varies by year |
| Campus-Based | ~4,500-5,500 | Varies by year |
| Financial Responsibility | ~2,500-3,500 | Private/for-profit only |
| 90/10 | ~2,000-3,000 | For-profit only |

## Data Timing and Lag

### Award Year vs. Fiscal Year

| Data Type | Reporting Period | Definition |
|-----------|------------------|------------|
| Grants/Loans | Award year | July 1 - June 30 (e.g., 2017-18) |
| Campus-Based | Award year | July 1 - June 30 |
| Financial Responsibility | Fiscal year | Institution's fiscal year end |
| 90/10 | Fiscal year | Institution's fiscal year end |

### Data Publication Lag

| Dataset | Typical Lag | Reason |
|----------|-------------|--------|
| Grants/Loans | 1-2 years | Reconciliation period after award year |
| Campus-Based | 1-2 years | FISAP reporting cycle |
| Financial Responsibility | 2-3 years | Audit completion + analysis |
| 90/10 | 2-3 years | Fiscal year audits required |

### Example: What Data is Available When?

If current date is January 2026:
- Grants/Loans: Likely through 2023-24 or 2024-25 award year
- Financial Responsibility: Likely through 2022 or 2023 fiscal year
- 90/10: Likely through 2022 or 2023 fiscal year

## Known Data Issues

### Grant Data Issues

| Issue | Description | Impact |
|-------|-------------|--------|
| Pell timing | Disbursements vs. obligations | May not match other sources |
| Year-round Pell | Multiple grants per student | Recipient counts may double-count |
| FSEOG variability | Campus-based allocation varies | Not comparable across institutions |

### Loan Data Issues

| Issue | Description | Impact |
|-------|-------------|--------|
| Origination vs. disbursement | Data may use different definitions | Verify metric definition |
| PLUS loan attribution | Parent vs. student counts | Clarify what "recipient" means |
| Consolidation loans | May not be in institutional data | Aggregate data may differ |
| Default recoveries | Affect net disbursement figures | Historical comparisons impacted |

### Financial Responsibility Issues

| Issue | Description | Impact |
|-------|-------------|--------|
| Public institution gaps | Many publics exempt from reporting | Sector comparisons limited |
| Accounting standard changes | FASB/GASB changes affect ratios | Time series comparisons difficult |
| Related-party adjustments | Vary by interpretation | Scores may not be fully comparable |
| Restatements | Prior years may be restated | Check for data updates |

### 90/10 Issues

| Issue | Description | Impact |
|-------|-------------|--------|
| Limited years | 2014-2021 available | 8-year time series |
| Proportion format | `rev_pct_90_10` is a proportion (0-1), not percentage (0-100) | Compare to 0.90 threshold, not 90 |
| Pre-2021 methodology | VA/DoD not counted as federal before 2021 | Not comparable to current rule |
| Revenue recognition | Timing differences | Annual figures may be volatile |
| Audit adjustments | May differ from published data | Verify with official sources |

## Missing Data Patterns

### Missing Data Codes

| Code | Meaning | When Used |
|------|---------|-----------|
| -1 | Not reported | Institution did not report value |
| -2 | Not applicable | Variable doesn't apply to institution |
| -3 | Suppressed | Small cell size protection |
| null/NA | No data | Record or field not present |

### Common Missing Data Scenarios

**Grants Dataset:**
- Institution doesn't participate in FSEOG → FSEOG values = -2
- No students received Pell → Pell values = 0 or -1
- Data not yet available → null

**Loans Dataset:**
- Undergraduate-only school → Grad PLUS = -2
- No students took loans → values = 0

**Financial Responsibility:**
- Public institution → entire record may be missing
- Score calculation error → composite_score = null

**90/10:**
- Nonprofit/public institution → no record
- New proprietary school → may not have full year data

### Handling Missing Data

```python
import polars as pl

# Approach 1: Filter to non-null records
df = df.filter(pl.col("grant_recipients_unitid").is_not_null())

# Approach 2: Filter out missing data codes
df = df.filter(~pl.col("fips").is_in([-1, -2, -3]))

# Approach 3: Replace missing codes with null
df = df.with_columns(
    pl.when(pl.col("fips").is_in([-1, -2, -3]))
    .then(None)
    .otherwise(pl.col("fips"))
    .alias("fips_clean")
)
```

## Methodological Considerations

### Changes Over Time

| Year | Change | Impact |
|------|--------|--------|
| 2010 | Direct Loan transition | FFEL phased out; Direct Loan data increases |
| 2012 | Grad subsidized eliminated | Grad loan composition changes |
| 2017 | Perkins discontinued | No new Perkins loans after this |
| 2021 | 90/10 methodology change | VA/DoD now counted as federal |
| 2024 | SAI replaces EFC | May affect Pell eligibility patterns |

### Comparability Issues

| Comparison | Concern | Recommendation |
|------------|---------|----------------|
| Year-over-year | Enrollment changes | Calculate per-student metrics |
| Cross-sector | Different program participation | Control for sector |
| Pre/post-2010 | FFEL to Direct Loan | Combine loan types or note break |
| State-level | Different state aid programs | Account for state context |

### Inflation Adjustment

Dollar amounts are nominal (not inflation-adjusted):

```python
import polars as pl

# Example: Adjust to 2021 dollars using CPI multipliers
cpi_multipliers = {2018: 1.08, 2019: 1.06, 2020: 1.04, 2021: 1.00}

df = df.with_columns(
    (pl.col("value_grants_disbursed_unitid") *
     pl.col("year").replace(cpi_multipliers)).alias("grants_real_2021")
)
```

## Data Source Comparison

### FSA vs. IPEDS Financial Aid

| Aspect | FSA Data | IPEDS SFA |
|--------|----------|-----------|
| Source | FSA administrative data | Institutional survey |
| Timing | Award year, with lag | Fall cohort, annual |
| Coverage | All Title IV institutions | Title IV institutions |
| Detail | Program-specific | Aggregated categories |
| Accuracy | Administrative records | Self-reported |

### When to Use Each

| Use Case | Preferred Source | Reason |
|----------|------------------|--------|
| Total Pell disbursements | FSA | Direct administrative data |
| Net price by income | IPEDS | Includes institutional aid |
| Loan composition | FSA | Detailed by program |
| Aid by enrollment status | IPEDS | Includes part-time |

### FSA vs. College Scorecard

| Aspect | FSA Data | College Scorecard |
|--------|----------|------------------|
| Aid data | Direct from FSA | Derived/processed |
| Outcomes | Limited | Earnings, debt, repayment |
| Program-level | Institutional | Some program-level |
| Update frequency | Periodic | Annual |

## Best Practices

### Before Analysis

1. **Check year coverage**: Verify dataset has data for your period
2. **Check institutional coverage**: Confirm institutions of interest are present
3. **Review missing data**: Understand patterns of missingness
4. **Note methodology**: Document which rules apply to your years

### During Analysis

1. **Use appropriate filters**: Filter out missing/not-applicable values
2. **Control for enrollment**: Calculate per-student metrics when comparing
3. **Acknowledge limitations**: Note coverage gaps in findings
4. **Cross-validate**: Check key findings against other sources

### Reporting Results

1. **State data vintage**: Note the year(s) of data used
2. **Document exclusions**: Explain any records dropped
3. **Acknowledge gaps**: Note sectors or years not covered
4. **Cite appropriately**: Credit Education Data Portal and original FSA data

## Data Quality Checks

### Reasonableness Checks

| Check | Variable | Flag If |
|-------|----------|---------|
| Composite score | `financial_resp_score` | Outside -1 to 3 range |
| 90/10 proportion | `rev_pct_90_10` | > 1.01 or < 0 (stored as proportion 0-1, not percentage) |
| Grant values | `value_grants_disbursed_*` | Negative values |
| Recipient count | `grant_recipients_*` | Negative values |

### Cross-Validation

```python
import polars as pl

# Check: 90/10 calculation matches components
# NOTE: rev_pct_90_10 is a proportion (0-1), not percentage (0-100)
df = df.with_columns(
    (pl.col("numerator_90_10") / pl.col("denominator_90_10"))
    .alias("calculated_pct")
)

# Flag discrepancies > 0.01 (1 percentage point)
df_discrepancy = df.filter(
    (pl.col("rev_pct_90_10") - pl.col("calculated_pct")).abs() > 0.01
)
```

### Outlier Detection

```python
import polars as pl

# Identify extreme values
q01 = df["financial_resp_score"].quantile(0.01)
q99 = df["financial_resp_score"].quantile(0.99)

outliers = df.filter(
    (pl.col("financial_resp_score") < q01) |
    (pl.col("financial_resp_score") > q99)
)
```
