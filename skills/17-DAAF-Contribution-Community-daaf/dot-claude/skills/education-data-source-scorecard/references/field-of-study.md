# Field of Study Data

College Scorecard provides program-level data on earnings and debt by field of study (CIP code), enabling analysis of outcomes at the major/program level.

> **Portal availability note:** Field-of-study data is **not available as a separate Portal mirror dataset**. The 6 Portal Scorecard datasets cover institution-level earnings, default, repayment, institutional characteristics, and student body characteristics. For program-level data, use the College Scorecard bulk downloads at `collegescorecard.ed.gov` (the "Most Recent Institution-Level Data" or "Field of Study" files). Variable names below use the original Scorecard naming convention, not Portal lowercase names.

## Overview

Field of study data links outcomes to specific academic programs:

| Aspect | Detail |
|--------|--------|
| Granularity | By CIP code + credential level + institution |
| Earnings timing | Post-completion (not post-entry like institution-level) |
| Coverage | Completers with Title IV aid |
| Suppression | High - many programs below threshold |

## Data Structure

### Key Identifiers

| Variable | Description |
|----------|-------------|
| `UNITID` | Institution ID |
| `CIPCODE` | Classification of Instructional Programs code |
| `CIPDESC` | CIP description |
| `CREDLEV` | Credential level |
| `CREDDESC` | Credential description |

### CIP Code Levels

| Level | Format | Example |
|-------|--------|---------|
| 2-digit | XX | 11 (Computer Science) |
| 4-digit | XX.XX | 11.01 (Computer Science General) |
| 6-digit | XX.XXXX | 11.0101 (Computer Science) |

### Credential Levels

> **Portal Encoding:** These are integer codes in the Portal data.

| Code | Description |
|------|-------------|
| 1 | Undergraduate Certificate or Diploma |
| 2 | Associate's Degree |
| 3 | Bachelor's Degree |
| 4 | Post-baccalaureate Certificate |
| 5 | Master's Degree |
| 6 | Doctoral Degree |
| 7 | First Professional Degree |
| 8 | Graduate/Professional Certificate |

## Important Difference: Post-Completion Timing

**Critical:** Field of study earnings are measured from **completion**, not entry.

| Level | Institution Earnings | Field Earnings |
|-------|---------------------|----------------|
| Reference point | Entry (first enrollment) | Completion |
| Includes non-completers | Yes | No |
| Time frame meaning | "6 years after entry" | "1-2 years after completion" |

### Field-Level Time Frames

| Variable | Description |
|----------|-------------|
| `EARN_MDN_HI_1YR` | Median earnings, 1 year post-completion |
| `EARN_MDN_HI_2YR` | Median earnings, 2 years post-completion |
| `EARN_COUNT_WNE_HI_1YR` | Count earning 1 year post-completion |
| `EARN_COUNT_WNE_HI_2YR` | Count earning 2 years post-completion |

## Field-Level Variables

### Earnings

| Variable | Description |
|----------|-------------|
| `EARN_MDN_HI_1YR` | Median earnings at 1 year |
| `EARN_MDN_HI_2YR` | Median earnings at 2 years |
| `EARN_NE_MDN_3YR` | Median earnings at 3 years (if available) |
| `EARN_COUNT_WNE_HI_*` | Count with positive earnings |

### Debt

| Variable | Description |
|----------|-------------|
| `DEBT_ALL_STGP_ANY_MDN` | Median debt, all sources |
| `DEBT_ALL_STGP_EVAL_MDN` | Median debt, evaluated programs |
| `DEBT_ALL_PP_ANY_MDN` | Median debt, parent PLUS included |

### Completion Counts

| Variable | Description |
|----------|-------------|
| `NUM_AWARDS` | Number of awards conferred |
| `IPEDSCOUNT1` | IPEDS completions count |
| `IPEDSCOUNT2` | IPEDS completions, alternate count |

### Program Status

| Variable | Description |
|----------|-------------|
| `MAIN` | Main campus indicator |
| `BRANCH` | Branch campus indicator |
| `DISTONLY` | Distance-only program |

## Suppression in Field Data

### High Suppression Rates

Field-level data has much higher suppression than institution-level:

| Data Type | Typical Suppression |
|-----------|-------------------|
| Institution-level earnings | 5-15% |
| 2-digit CIP earnings | 20-40% |
| 4-digit CIP earnings | 40-60% |
| 6-digit CIP earnings | 60-80% |

### Why So Much Suppression

1. **Small programs** - Many programs graduate <30 students/year
2. **Credential splitting** - Same field, different credentials
3. **Campus splitting** - Main vs branch
4. **Working requirement** - Must be working to have earnings

### Checking Suppression

```python
import polars as pl

# Count suppressed/missing records
# Note: Field-of-study data is from Scorecard bulk downloads, not Portal mirrors.
# Suppression may use null, -3, or "PrivacySuppressed" depending on file format.
suppressed = df.filter(
    pl.col("earn_mdn_hi_2yr").is_null() |
    (pl.col("earn_mdn_hi_2yr") == -3)
)

suppression_rate = suppressed.height / df.height
print(f"Suppression/missing rate: {suppression_rate:.1%}")

# Programs with valid data (positive values only)
with_data = df.filter(
    pl.col("earn_mdn_hi_2yr").is_not_null() &
    (pl.col("earn_mdn_hi_2yr") > 0)
)
print(f"Programs with valid earnings data: {with_data.height}")
```

## Common CIP Codes

### High-Earning Fields (Typically)

| CIP | Field | Typical Earnings |
|-----|-------|------------------|
| 11 | Computer Science | High |
| 14 | Engineering | High |
| 52 | Business | Medium-High |
| 51 | Health Professions | Medium-High |

### Lower-Earning Fields (Typically)

| CIP | Field | Typical Earnings |
|-----|-------|------------------|
| 50 | Visual/Performing Arts | Lower |
| 54 | History | Lower |
| 38 | Philosophy/Religion | Lower |
| 23 | English | Lower |

### Fields with High Grad School Rates

| CIP | Field | Effect on Earnings |
|-----|-------|-------------------|
| 26 | Biology | Understated (many in grad school) |
| 40 | Physical Sciences | Understated |
| 42 | Psychology | Understated |
| 45 | Social Sciences | Understated |

## Analytical Considerations

### Comparing Fields

**Valid comparisons:**
- Same credential level (Bachelor's to Bachelor's)
- Same institution or similar institution type
- Fields with similar grad school rates

**Invalid comparisons:**
- Bachelor's vs Associate's earnings
- Fields with high vs low grad school attendance
- Suppressed vs non-suppressed programs

### Using CIP Aggregations

| Approach | Pros | Cons |
|----------|------|------|
| 2-digit CIP | More data, less suppression | Heterogeneous |
| 4-digit CIP | More specific | More suppression |
| 6-digit CIP | Most specific | Highest suppression |

### Aggregating Across Institutions

To reduce suppression, aggregate across similar institutions:

```python
import polars as pl

# Aggregate 2-digit CIP earnings across public 4-years
# Portal uses integer codes: control=1 is public
field_summary = (
    df.filter(pl.col("control") == 1)  # Public (integer code)
    .filter(pl.col("credlev") == 3)    # Bachelor's (integer code)
    .filter(pl.col("earn_mdn_hi_2yr") > 0)  # Valid earnings only
    .group_by("cipcode")
    .agg([
        pl.col("earn_mdn_hi_2yr").median().alias("median_earnings"),
        pl.col("num_awards").sum().alias("total_completers")
    ])
)
```

## Gainful Employment Metrics

Field-level data supports accountability metrics:

### Debt-to-Earnings Ratio

| Metric | Formula |
|--------|---------|
| Annual earnings | Median earnings post-completion |
| Annual debt payment | Estimated from median debt |
| D/E ratio | Annual payment / Annual earnings |

### Earnings Threshold

| Metric | Description |
|--------|-------------|
| Earnings > HS grad | Program earnings exceed HS-only baseline |
| Earnings > federal poverty | Program earnings above poverty level |

### Program-Level Accountability

Used for:
- Gainful Employment regulations
- Consumer disclosures
- Institutional accountability

## Recommended Practices

### For Field-Level Analysis

1. **Start with 2-digit CIP** for broader coverage
2. **Report suppression rates** prominently
3. **Note post-completion timing** differs from institution level
4. **Acknowledge grad school effects** on certain fields
5. **Compare same credential levels** only

### For Consumer Information

```
Good: "Computer Science graduates at School X earn $75,000 
      two years after graduation"

Better: "Computer Science bachelor's degree graduates at School X 
        who received federal aid and are working full-time earn 
        a median of $75,000 two years after graduation"

Best: "Computer Science bachelor's degree graduates at School X 
      who received federal aid earn a median of $75,000 two years 
      after graduation. This excludes graduates who continued to 
      graduate school, are self-employed, or are not working. 
      Based on XX completers in the cohort."
```

### Dealing with Suppression

| Strategy | Use Case |
|----------|----------|
| Aggregate to 2-digit CIP | Broad field analysis |
| Aggregate across years | Increase sample size |
| Aggregate across similar schools | National field estimates |
| Note as missing | When suppression high |

## Linking to Institution Data

Join field data to institution characteristics:

```python
import polars as pl

# Merge field data with institution data
# Note: Portal column names are lowercase
combined = field_df.join(
    institution_df.select(["unitid", "inst_name", "control", "state_abbr"]),
    on="unitid",
    how="left"
)
```

## Limitations Summary

| Limitation | Impact |
|------------|--------|
| High suppression | Many programs have no data |
| Post-completion timing | Not comparable to institution-level entry cohorts |
| Completers only | Excludes program non-completers |
| Title IV only | Same selection bias as institution level |
| Working only | Excludes grad school, unemployed |
| 1-2 year earnings | Very early career only |
