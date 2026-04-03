# Earnings Data

Graduate earnings tabulations from PSEO: percentile earnings, cohort definitions, and labor force attachment requirements.

> **Portal Variable Names:** Portal uses lowercase variable names (e.g., `p50_earnings`, `years_after_grad`), not Census API names (e.g., `Y1_P50_EARNINGS`). See variable mapping below.

## Contents

- [Earnings Overview](#earnings-overview)
- [Percentile Earnings Variables](#percentile-earnings-variables)
- [Labor Force Attachment](#labor-force-attachment)
- [Cohort Definitions](#cohort-definitions)
- [Earnings Adjustments](#earnings-adjustments)
- [Interpretation Guidelines](#interpretation-guidelines)

## Earnings Overview

The Graduate Earnings tabulations provide earnings percentiles for graduates at three time points post-graduation:

| Time Point | Definition |
|------------|------------|
| Year 1 | First full calendar year after graduation year |
| Year 5 | Fifth full calendar year after graduation year |
| Year 10 | Tenth full calendar year after graduation year |

**Example**: A student graduating in May 2015:
- Year 1 = Calendar year 2016 (Jan-Dec)
- Year 5 = Calendar year 2020
- Year 10 = Calendar year 2025

## Percentile Earnings Variables

### Portal Variable Names vs Census API

The Education Data Portal uses a **restructured schema** with lowercase names:

| Portal Variable | Census API Equivalent | Description |
|-----------------|----------------------|-------------|
| `p25_earnings` | `Y*_P25_EARNINGS` | 25th percentile earnings |
| `p50_earnings` | `Y*_P50_EARNINGS` | Median (50th percentile) earnings |
| `p75_earnings` | `Y*_P75_EARNINGS` | 75th percentile earnings |
| `years_after_grad` | (implicit in variable name) | `1`, `5`, or `10` years post-graduation |
| `employed_grads_count_e` | `Y*_GRADS` (earnings) | Graduates with observable earnings |
| `employed_grads_count_f` | `Y*_GRADS_EMP` (flows) | Employed graduates count |
| `total_grads_count` | — | Total IPEDS-reported graduates |
| `employed_instate_grads_count` | `Y*_GRADS_EMP_INSTATE` | Graduates employed in-state |
| `jobless_m_emp_grads_count` | `Y*_GRADS_NME` | Non-employed or marginally employed |

> **Key difference:** Portal data uses `years_after_grad` (1, 5, 10) as a column, not embedded in variable names like Census API.

### Using Portal Data

```python
import polars as pl

# Filter to Year 1 earnings
year1 = df.filter(pl.col("years_after_grad") == 1)

# Get median earnings
median_earnings = year1.select("p50_earnings")
```

### Status/Suppression

| Code | Meaning |
|------|---------|
| `-1` | Missing/not reported |
| `-2` | Not applicable |
| `-3` | Suppressed (cell count < 30) |

> **Note:** Portal uses standard negative codes. Census API uses separate STATUS_* variables.

## Labor Force Attachment

Not all graduates are included in earnings statistics. PSEO applies labor force attachment restrictions to focus on workers who are meaningfully employed.

### Inclusion Criteria

A graduate is included if they meet BOTH requirements:

1. **Minimum earnings threshold**: Annual earnings ≥ full-time federal minimum wage equivalent
   - Calculated as: Federal minimum wage × 40 hours × 52 weeks
   - Example: At $7.25/hour = $15,080/year minimum

2. **Employment continuity**: Earnings in at least 3 of 4 quarters in the reference year

### Exclusions

Graduates excluded from earnings tabulations:

| Reason | Impact |
|--------|--------|
| Earnings below threshold | Low earners/part-time workers excluded |
| Fewer than 3 quarters with earnings | Seasonal/intermittent workers excluded |
| No match in LEHD | Self-employed, uncovered employment |
| Zero earnings all year | Graduate students, not in labor force |

### Non-Employed/Marginal Employment

Graduates who don't meet attachment criteria are counted in the `jobless_m_emp_grads_count` column, filtered by `years_after_grad`:

| Portal Variable | `years_after_grad` | Census API Equivalent |
|-----------------|--------------------|-----------------------|
| `jobless_m_emp_grads_count` | `1` | `Y1_GRADS_NME` |
| `jobless_m_emp_grads_count` | `5` | `Y5_GRADS_NME` |
| `jobless_m_emp_grads_count` | `10` | `Y10_GRADS_NME` |

> **Note:** Portal restructures Census API's separate Y1/Y5/Y10 variables into a single column with a `years_after_grad` filter.

## Cohort Definitions

Graduates are grouped into cohorts based on graduation year. Cohort length varies by degree level:

### Bachelor's Degree Cohorts (3-year)

| `pseo_cohort` Value | Years Included |
|---------------------|----------------|
| `"2001-2003"` | 2001, 2002, 2003 |
| `"2004-2006"` | 2004, 2005, 2006 |
| `"2007-2009"` | 2007, 2008, 2009 |
| `"2010-2012"` | 2010, 2011, 2012 |
| `"2013-2015"` | 2013, 2014, 2015 |
| `"2016-2018"` | 2016, 2017, 2018 |
| `"2019-2021"` | 2019, 2020, 2021 |

> **Note:** Portal uses full year range strings (e.g., `"2019-2021"`). Census Bureau source data uses abbreviated start-year format (e.g., `2019`).

### All Other Degree Levels (5-year)

Includes: Certificates, Associate's, Master's, Doctoral

| `pseo_cohort` Value | Years Included |
|---------------------|----------------|
| `"2001-2005"` | 2001, 2002, 2003, 2004, 2005 |
| `"2006-2010"` | 2006, 2007, 2008, 2009, 2010 |
| `"2011-2015"` | 2011, 2012, 2013, 2014, 2015 |
| `"2016-2020"` | 2016, 2017, 2018, 2019, 2020 |

### Why Different Cohort Lengths?

- **Bachelor's (3-year)**: Higher graduate counts allow smaller cohorts while maintaining sufficient sample sizes
- **Other degrees (5-year)**: Smaller programs require larger cohorts to avoid suppression

### All-Cohort Aggregations

In Census Bureau source data, `GRAD_COHORT=0000` spans all available cohorts, with `GRAD_COHORT_YEARS` indicating the cohort span (3 for Bachelor's, 5 for others). In Portal data, check for aggregate `pseo_cohort` values that span all years.

## Earnings Adjustments

### Inflation Adjustment

All earnings are converted to **2022 dollars** using the Consumer Price Index for All Urban Consumers (CPI-U).

Example conversion:
```
Real_2022 = Nominal_Year × (CPI-U_2022 / CPI-U_Year)
```

### Multiple Jobs

Earnings include total annual earnings from **all jobs**:
- If a graduate works multiple jobs, all covered earnings are summed
- Part-time job + full-time job = combined earnings

### Earnings Sources

Included:
- Wages and salaries from UI-covered employment
- Federal civilian employment (from OPM)

Excluded:
- Self-employment income
- Investment/capital income
- Uncovered employment

## Interpretation Guidelines

### Comparing Programs

When comparing earnings across programs:

1. **Same degree level**: Only compare Bachelor's to Bachelor's, etc.
2. **Same time point**: Compare Y1 to Y1, Y5 to Y5
3. **Check sample sizes**: Large differences may reflect small cells
4. **Consider field**: Some fields have delayed earnings (e.g., grad school track)

### Understanding Percentiles

| Percentile | Meaning |
|------------|---------|
| 25th (P25) | 25% of graduates earn less than this |
| 50th (P50) | Half earn more, half earn less (median) |
| 75th (P75) | 25% of graduates earn more than this |

**Interquartile range (IQR)** = P75 - P25: Indicates earnings dispersion

### Limitations

| Issue | Impact |
|-------|--------|
| Selection into labor force | Higher earners more likely to meet attachment criteria |
| Graduate school | Enrolled grad students may be excluded (low/no earnings) |
| Geographic cost of living | Raw earnings don't account for regional differences |
| Field-specific patterns | Some fields have non-linear career trajectories |
| Cohort effects | Economic conditions vary by graduation year |

### Example Analysis

**Question**: What do Computer Science Bachelor's graduates from UT Austin earn?

```python
import polars as pl

# Fetch PSEO data for 2020
df = fetch_from_mirrors("pseo/colleges_pseo_2020")

# Filter to UT Austin CS Bachelor's
ut_cs = df.filter(
    (pl.col("unitid") == 228778)         # UT Austin
    & (pl.col("degree_level") == 5)       # Bachelor's
    & (pl.col("cipcode") == 11)           # Computer Science
    & (pl.col("p50_earnings") > 0)        # Valid earnings only
)

# View earnings by years after graduation
print(ut_cs.select("years_after_grad", "p25_earnings", "p50_earnings", "p75_earnings", "employed_grads_count_e"))
```

**Example result** (hypothetical):
- `years_after_grad=1`: `p50_earnings` = $62,500 (median 1 year out)
- `years_after_grad=5`: `p50_earnings` = $95,000 (median 5 years out)
- `employed_grads_count_e` = 450 (sample size)

**Interpretation**: Median CS graduate from UT Austin earned $62,500 one year after graduation (in 2022 dollars), growing to $95,000 five years out. With 450 graduates in the cell, this estimate is relatively precise.
