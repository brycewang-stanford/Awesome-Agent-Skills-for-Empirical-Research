# IPEDS Data Quality and Known Issues

Understanding data quality considerations, missing data, and analytical pitfalls.

## Contents

- [Data Quality Overview](#data-quality-overview)
- [Missing Data Codes](#missing-data-codes)
- [Imputation](#imputation)
- [Response Rates](#response-rates)
- [Known Data Quality Issues](#known-data-quality-issues)
- [Sector Comparison Warnings](#sector-comparison-warnings)
- [Historical Data Issues](#historical-data-issues)
- [Validation Checks](#validation-checks)
- [Data Quality Flags](#data-quality-flags)

## Data Quality Overview

### IPEDS Strengths

| Strength | Description |
|----------|-------------|
| High response rate | ~99% due to mandatory reporting |
| Consistent definitions | Standardized across institutions |
| Longitudinal coverage | Many surveys since 1980s |
| Public access | Free, well-documented |
| Regular updates | Annual collection |

### IPEDS Limitations

| Limitation | Description |
|------------|-------------|
| Institutional-level only | No student-level data |
| Title IV only | Non-Title IV institutions excluded |
| Cohort definitions | GR excludes many students |
| Accounting differences | GASB vs FASB |
| Lag time | 1-2 year delay for most data |
| Voluntary items | Some data elements optional |

## Missing Data Codes

> **CRITICAL: Portal Integer Encoding**
>
> The Education Data Portal uses **integer codes** for missing/special values. These differ from raw NCES file conventions.

IPEDS uses specific codes for missing or suppressed data:

### Standard Missing Data Codes (Portal Integer Encoding)

| Code | Meaning | Use |
|------|---------|-----|
| `-1` | Missing/not reported | State/institution did not report; value unknown |
| `-2` | Not applicable | Item doesn't apply to this institution |
| `-3` | Suppressed | Suppressed for privacy protection |
| `null`/`None` | Null value | No data present |

### Handling Missing Data

```python
import polars as pl

# Filter out missing/not applicable
valid_data = df.filter(
    pl.col("variable") > 0  # Excludes negative codes and nulls
)

# Or explicitly handle each code
df = df.with_columns(
    pl.when(pl.col("variable") < 0)
    .then(None)
    .otherwise(pl.col("variable"))
    .alias("variable_clean")
)
```

### Privacy Suppression (-3)

Small cell counts are suppressed to protect privacy:
- Typically cells with fewer than 10 individuals
- Common in demographic breakdowns
- More common at smaller institutions

```python
# Check for suppression
suppressed = df.filter(pl.col("variable") == -3)
print(f"Suppressed cells: {suppressed.height}")
```

### Not Applicable (-2)

Code `-2` is used when item doesn't apply:
- Graduation rates for non-degree institutions
- Graduate data for undergrad-only institutions
- Distance education for institutions without DE programs

## Imputation

### IPEDS Imputation Process

For non-respondents, IPEDS imputes values using:

1. **Prior year data** - carry forward from previous year
2. **Peer group mean** - average of similar institutions
3. **Ratio adjustment** - based on related variables

### Imputation Flags

IPEDS provides imputation flags in detailed data files:

| Flag | Meaning |
|------|---------|
| R | Reported by institution |
| P | Reported, adjusted by IPEDS |
| I | Imputed |
| D | Derived |

```python
# Check imputation rate
imputed = df.filter(pl.col("variable_flag") == "I")
imputation_rate = imputed.height / df.height * 100
print(f"Imputation rate: {imputation_rate:.1f}%")
```

### Best Practices

1. **Check imputation rates** for key variables
2. **Note high imputation** in analysis limitations
3. **Exclude highly imputed data** for sensitive analyses
4. **Use imputation flags** when available

## Response Rates

### Overall Response

IPEDS achieves ~99% overall response because:
- Required for Title IV participation
- Financial penalties for non-response
- Extensive follow-up

### Component-Specific Response

| Component | Response Considerations |
|-----------|------------------------|
| IC | Required; high response |
| EF, E12 | High response |
| C | High response |
| SFA | High response |
| GR | Some small cohorts suppressed |
| F | Some delayed reporting |
| HR | High response |
| AL | Biennial; some non-response |

### Unit Non-Response

Entire institution doesn't respond:
- Rare (<1%)
- Often new or closing institutions
- Entire record imputed or excluded

### Item Non-Response

Individual items missing:
- More common than unit non-response
- Varies by item complexity
- Imputed using methods above

## Known Data Quality Issues

### Issue 1: Enrollment Count Timing

| Problem | Different census dates across institutions |
|---------|------------------------------------------|
| Impact | Point-in-time comparisons affected |
| Mitigation | Use 12-month enrollment for year-round schools |

### Issue 2: First-Time Student Classification

| Problem | Dual enrollment students may be misclassified |
|---------|----------------------------------------------|
| Impact | Affects GR cohorts, first-time enrollment |
| Mitigation | Note in analysis; may not be fixable |

### Issue 3: Branch Campus Reporting

| Problem | Inconsistent branch vs main campus reporting |
|---------|---------------------------------------------|
| Impact | Some data at campus level, some at system |
| Mitigation | Aggregate to OPEID6 level; check patterns |

### Issue 4: Online Program Growth

| Problem | DE definition changes, COVID disruption |
|---------|----------------------------------------|
| Impact | Pre-2020 to post-2020 not comparable |
| Mitigation | Note structural break; analyze separately |

### Issue 5: For-Profit Sector Volatility

| Problem | High closure/change rate in for-profit sector |
|---------|----------------------------------------------|
| Impact | Longitudinal analysis challenging |
| Mitigation | Track closures; note sample changes |

### Issue 6: Race/Ethnicity Unknown

| Problem | High "unknown" rates at some institutions |
|---------|------------------------------------------|
| Impact | Demographic analysis unreliable |
| Mitigation | Check unknown rates; exclude high-unknown institutions |

### Issue 7: Finance Data Comparability

| Problem | GASB vs FASB; passthrough transactions |
|---------|---------------------------------------|
| Impact | Cross-sector analysis problematic |
| Mitigation | See `finance-data.md`; use Delta Cost |

### Issue 8: Graduation Rate Cohort

| Problem | FTFT cohort not representative |
|---------|--------------------------------|
| Impact | See `graduation-rates.md` |
| Mitigation | Use Outcome Measures; note limitations |

## Sector Comparison Warnings

### Public vs Private Comparisons

| Data Type | Comparability | Issues |
|-----------|---------------|--------|
| Enrollment | Moderate | Different student populations |
| Completions | Moderate | Different program mixes |
| Finance | Low | GASB vs FASB |
| Graduation rates | Low | Different populations |
| Net price | Moderate | Different aid structures |

### 4-Year vs 2-Year Comparisons

| Data Type | Comparability | Issues |
|-----------|---------------|--------|
| Enrollment | Moderate | Different missions |
| Completions | Moderate | Different award levels |
| Graduation rates | Very low | Transfer mission ignored |
| Finance | Low | Different cost structures |

### Selective vs Open-Access

| Data Type | Comparability | Issues |
|-----------|---------------|--------|
| Graduation rates | Very low | Input vs outcome |
| Enrollment demographics | Low | Selection effects |
| Financial aid | Moderate | Different student needs |

### Best Practice: Peer Group Analysis

Always compare within peer groups:
- Same sector (public/private NP/private FP)
- Same level (4-year/2-year/less-than-2-year)
- Similar selectivity (Carnegie classification)
- Similar size
- Same geographic region (if relevant)

```python
# Define peer group
peers = df.filter(
    (pl.col("inst_control") == 1) &  # Public
    (pl.col("institution_level") == 4) &    # 4-year (Portal code is 4, not 1)
    (pl.col("carnegie_basic").is_in(peer_carnegies)) &
    (pl.col("enrollment_size").is_between(5000, 15000))
)
```

## Historical Data Issues

### Survey Changes Over Time

| Year | Change | Impact |
|------|--------|--------|
| 1986 | IPEDS begins | Start of consistent data |
| 1997 | FASB finance | Private finance changes |
| 2002-04 | GASB finance | Public finance changes |
| 2008 | Race/ethnicity categories | Two+ races added |
| 2010 | Award level changes | Doctoral split |
| 2012 | Distance education added | New data element |
| 2015 | Outcome Measures begins | New survey |
| 2020 | COVID impacts | Major disruption |

### Pre-2008 Race/Ethnicity

Before 2008-09:
- No "Two or more races" category
- "Asian" included Pacific Islander
- Different classification rules

```python
# Combining old and new race data
# Two+ races: only available 2008-09+
# Pre-2008: Asian includes Pacific Islander

if year < 2008:
    asian_combined = asian  # Includes Pacific Islander
else:
    asian_combined = asian + nhpi  # Separate in new data
```

### Finance Form Changes

Cannot directly compare:
- Pre-1997 private to post-1997 private
- Pre-2004 public to post-2004 public

Delta Cost Project provides harmonized historical data.

## Validation Checks

### Basic Validation

```python
def validate_ipeds_data(df, key_vars):
    """Basic IPEDS data validation."""
    issues = []
    
    # 1. Check for duplicate UNITIDs
    dups = df.group_by("unitid").count().filter(pl.col("count") > 1)
    if dups.height > 0:
        issues.append(f"Duplicate UNITIDs: {dups.height}")
    
    # 2. Check for missing critical fields
    for var in key_vars:
        missing = df.filter(pl.col(var).is_null()).height
        if missing > 0:
            issues.append(f"Missing {var}: {missing} rows")
    
    # 3. Check for implausible values
    # Portal stores grad rates as 0-1 proportions (not 0-100)
    # See education-data-context skill > Rate and Proportion Normalization
    if "completion_rate_150pct" in df.columns:
        bad_grad = df.filter(
            (pl.col("completion_rate_150pct") > 1.0) | (pl.col("completion_rate_150pct") < 0)
        )
        if bad_grad.height > 0:
            issues.append(f"Invalid grad rates: {bad_grad.height}")
    
    # 4. Check enrollment reasonableness
    if "enrollment" in df.columns:
        huge = df.filter(pl.col("enrollment") > 200000)
        if huge.height > 0:
            issues.append(f"Unusually large enrollments: {huge.height}")
    
    return issues
```

### Consistency Checks

```python
def check_consistency(df):
    """Check internal consistency."""
    issues = []
    
    # Full-time + part-time should equal total
    if all(c in df.columns for c in ["ft_enrl", "pt_enrl", "total_enrl"]):
        inconsistent = df.filter(
            (pl.col("ft_enrl") + pl.col("pt_enrl") != pl.col("total_enrl")) &
            (pl.col("total_enrl") > 0)
        )
        if inconsistent.height > 0:
            issues.append(f"FT+PT != Total: {inconsistent.height}")
    
    # Race categories should sum to total
    race_cols = ["white", "black", "hispanic", "asian", "nhpi", 
                 "aian", "two_more", "unknown", "nonres"]
    if all(c in df.columns for c in race_cols + ["total"]):
        race_sum = sum(pl.col(c) for c in race_cols)
        inconsistent = df.filter(race_sum != pl.col("total"))
        if inconsistent.height > 0:
            issues.append(f"Race sum != Total: {inconsistent.height}")
    
    return issues
```

### Year-Over-Year Checks

```python
def check_yoy_changes(df, max_change=0.5):
    """Flag large year-over-year changes."""
    df = df.sort(["unitid", "year"])
    
    df = df.with_columns(
        (pl.col("enrollment") / pl.col("enrollment").shift(1) - 1)
        .over("unitid")
        .alias("yoy_change")
    )
    
    suspicious = df.filter(pl.col("yoy_change").abs() > max_change)
    return suspicious
```

## Data Quality Flags

### Institution Status Flags

| Portal Variable | Description | Check |
|-----------------|-------------|-------|
| `currently_active_ipeds` | Currently active | Should be 1 for analysis |
| `inst_category` | Institution category | Check for changes |
| `year_deleted` | Year closed | Exclude closed institutions |
| `inst_status` | Institution status | Active vs inactive |

> **Note:** NCES raw file documentation may use different variable names (e.g., `CYACTIVE`, `INSTCAT`, `DEATHYR`). The Portal uses the lowercase descriptive names shown above. Always verify against the actual data columns.

### Data Quality Flags

| Flag Type | Description |
|-----------|-------------|
| Imputation flags | Indicate imputed values |
| Revision flags | Indicate revised data |
| Status flags | Indicate reporting issues |

### Using Flags in Analysis

```python
import polars as pl

# Example: Quality-filtered analysis using Portal variable names
analysis_data = df.filter(
    (pl.col("currently_active_ipeds") == 1) &  # Active institutions
    (pl.col("year_deleted").is_null()) &        # Not closed
    (pl.col("enrollment") > 100)               # Minimum size (if applicable)
)

# Document filtering
print(f"Original: {df.height}")
print(f"Analysis sample: {analysis_data.height}")
print(f"Excluded: {df.height - analysis_data.height}")
```

## Recommended Workflow

1. **Download data with flags** - Include imputation/status flags
2. **Check response rates** - Document non-response
3. **Validate basic quality** - Run validation checks
4. **Filter appropriately** - Remove problematic records
5. **Document decisions** - Note all exclusions
6. **Sensitivity analysis** - Test with/without exclusions
7. **Note limitations** - Include in write-up
