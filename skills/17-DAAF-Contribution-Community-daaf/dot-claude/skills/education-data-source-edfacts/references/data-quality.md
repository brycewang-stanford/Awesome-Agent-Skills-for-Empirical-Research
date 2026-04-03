# Data Quality

Known data quality issues, state reporting variations, COVID-19 impacts, and guidance for handling problematic data in EDFacts.

## Contents

- [COVID-19 Data Gaps](#covid-19-data-gaps)
- [State Reporting Variations](#state-reporting-variations)
- [Known Data Issues](#known-data-issues)
- [Time Series Breaks](#time-series-breaks)
- [Suppression Patterns](#suppression-patterns)
- [Data Validation](#data-validation)
- [Documentation Practices](#documentation-practices)

## COVID-19 Data Gaps

### 2019-20 Testing Waivers

**Critical**: Spring 2020 assessments were largely waived due to COVID-19:

| Impact | Details |
|--------|---------|
| Assessment data | Most states have no 2019-20 data |
| Participation rates | Not meaningful for 2019-20 |
| Federal waivers | States received assessment waivers |

### What's Available for 2019-20

| Data Type | Availability |
|-----------|--------------|
| Assessment proficiency | **Largely missing** |
| Graduation rates | Mostly available (cohort-based) |
| Directory data | Available |
| Enrollment data | Available |

### 2020-21 Partial Return

The 2020-21 school year had mixed testing:

| Variation | Impact |
|-----------|--------|
| State decisions | Some states tested, some didn't |
| Participation rates | Often below 95% |
| Comparability | Limited comparability to prior years |

### 2021-22 Onward

Testing largely resumed, but considerations remain:

| Issue | Guidance |
|-------|----------|
| Learning loss | Score drops reflect COVID impact |
| Changed baselines | Not directly comparable to pre-COVID |
| Ongoing effects | Recovery still in progress |

### Handling COVID Years in Analysis

```python
def exclude_covid_years(df, assessment_col):
    """Exclude COVID-affected years from trend analysis."""
    
    # 2020 (spring 2020 testing) is most affected
    # 2021 has partial data
    
    return df.filter(
        ~pl.col("year").is_in([2020, 2021])
    )

def flag_covid_years(df):
    """Add flag for COVID-affected years."""
    
    return df.with_columns(
        pl.when(pl.col("year") == 2020)
        .then(pl.lit("no_testing"))
        .when(pl.col("year") == 2021)
        .then(pl.lit("partial_testing"))
        .otherwise(pl.lit("normal"))
        .alias("covid_status")
    )
```

### Reporting COVID Gaps

When presenting findings:

> "Data for 2019-20 is largely unavailable due to federal assessment waivers during COVID-19. Data for 2020-21 reflects partial testing with participation below typical levels. Trends should be interpreted with caution around these years."

## State Reporting Variations

### Timing of Data Submission

States submit data on different schedules:

| Variation | Impact |
|-----------|--------|
| Submission deadlines | Data completeness varies |
| Resubmission | Some states update data |
| Lag time | 1-2 years from collection to availability |

### Definition Variations

Despite federal requirements, states interpret definitions differently:

| Concept | How It Varies |
|---------|---------------|
| Economically disadvantaged | FRPL, CEP, other measures |
| School levels | Grade spans differ |
| Charter classification | Reporting practices differ |
| Transfer documentation | Tracking rigor varies |

### Economically Disadvantaged Definition

States define "economically disadvantaged" differently:

| Definition | States Using |
|------------|--------------|
| Free lunch eligible | Some states |
| Free or reduced lunch | Many states |
| Direct certification | Increasing |
| CEP schools (100%) | Growing issue |

### Community Eligibility Provision (CEP) Impact

CEP schools serve all students free meals regardless of income:

| Issue | Impact |
|-------|--------|
| No individual applications | Can't identify FRPL-eligible |
| Often marked 100% | Inflates economically disadvantaged counts |
| Comparability | Pre/post CEP not comparable |

```python
# Flag potential CEP schools
def flag_potential_cep(df):
    """Flag schools that might be CEP (100% economically disadvantaged)."""
    
    return df.with_columns(
        (pl.col("econ_disadvantaged_pct") >= 99).alias("likely_cep")
    )
```

## Known Data Issues

### State-Specific Issues

Documented data quality issues by state (examples):

| State | Year | Issue |
|-------|------|-------|
| Virginia | 2016-17 | Grade 5-8 math proficiency shares inaccurate |
| Various | 2019-20 | COVID testing waivers |
| Various | Multiple | Assessment system transitions |

### Checking for Known Issues

1. **Review state documentation**: Check state education agency websites
2. **Look for unusual patterns**: Large year-over-year changes
3. **Verify with multiple sources**: Cross-reference with state data
4. **Contact state if needed**: State data offices can clarify

### Common Data Anomalies

| Anomaly | Possible Cause |
|---------|----------------|
| Large proficiency jump | Assessment change |
| Large proficiency drop | Higher standards/new test |
| Missing year | Data collection issue |
| 100% proficiency | Very small school or data error |
| 0% proficiency | Very small school or data error |

## Time Series Breaks

### Assessment System Changes

States periodically adopt new assessments:

| Period | Major Changes |
|--------|---------------|
| 2014-2016 | Common Core adoption |
| 2015-2017 | PARCC/SBAC implementation |
| 2017-2018 | ESSA transition |
| Ongoing | State-specific changes |

### Detecting Time Series Breaks

```python
def detect_breaks(df, state_fips, variable, threshold=10):
    """
    Detect potential time series breaks.
    
    Parameters:
    -----------
    df : DataFrame with year and variable columns
    state_fips : State to analyze
    variable : Variable to check for breaks
    threshold : Percentage point change to flag (default 10)
    
    Returns:
    --------
    DataFrame with flagged years
    """
    
    state_data = (df
        .filter(pl.col("fips") == state_fips)
        .sort("year")
    )
    
    # Calculate year-over-year change
    state_data = state_data.with_columns(
        (pl.col(variable) - pl.col(variable).shift(1)).alias("yoy_change")
    )
    
    # Flag large changes
    breaks = state_data.filter(
        pl.col("yoy_change").abs() > threshold
    )
    
    return breaks
```

### Handling Time Series Breaks

| Approach | When to Use |
|----------|-------------|
| Split analysis | Pre and post change separately |
| Exclude transition | Drop year(s) of change |
| Document break | Note limitation in findings |
| Standardize scores | If scale scores available |

### Example: Segmented Analysis

```python
def segmented_trend(df, state_fips, variable, break_year):
    """Analyze trends separately before and after break."""
    
    state_data = df.filter(pl.col("fips") == state_fips)
    
    pre_break = state_data.filter(pl.col("year") < break_year)
    post_break = state_data.filter(pl.col("year") >= break_year)
    
    results = {
        "pre_break_trend": calculate_trend(pre_break, variable),
        "post_break_trend": calculate_trend(post_break, variable),
        "break_year": break_year,
        "note": "Trends should not be compared across the break"
    }
    
    return results
```

## Suppression Patterns

### Who Gets Suppressed

Suppression disproportionately affects:

| Population | Suppression Rate |
|------------|------------------|
| Small schools | High |
| Rural schools | High |
| Small subgroups | Very high |
| Students with disabilities | High |
| English learners | Moderate to high |
| Small racial groups | Very high |

### Suppression Impact on Analysis

| Issue | Impact |
|-------|--------|
| Sample selection | Only larger schools remain |
| Subgroup invisibility | Can't see small group outcomes |
| Bias | Survivors may not be representative |
| Aggregation | May need to aggregate up |

### Analyzing Suppression Patterns

```python
def suppression_analysis(df, value_col, group_col=None):
    """Analyze suppression patterns."""
    
    if group_col:
        analysis = (df
            .group_by(group_col)
            .agg([
                pl.count().alias("total"),
                (pl.col(value_col) == -3).sum().alias("suppressed"),
                (pl.col(value_col) >= 0).sum().alias("valid")
            ])
            .with_columns(
                (pl.col("suppressed") / pl.col("total") * 100).alias("pct_suppressed")
            )
            .sort("pct_suppressed", descending=True)
        )
    else:
        total = len(df)
        suppressed = (df[value_col] == -3).sum()
        analysis = {
            "total": total,
            "suppressed": suppressed,
            "pct_suppressed": suppressed / total * 100
        }
    
    return analysis
```

### Mitigating Suppression Bias

| Strategy | Description |
|----------|-------------|
| Aggregate to district | Less suppression at district level |
| Pool years | Combine multiple years |
| Pool subgroups | Broader categories |
| Document limitation | Note excluded records |
| Use multiple imputation | Advanced technique |

## Data Validation

### Basic Validation Checks

```python
def validate_edfacts(df):
    """Basic validation for EDFacts data."""
    
    issues = []
    
    # Check for impossible percentages
    pct_cols = [c for c in df.columns if "pct" in c and "_midpt" in c]
    for col in pct_cols:
        invalid = df.filter(
            (pl.col(col) > 100) | 
            ((pl.col(col) < 0) & (~pl.col(col).is_in([-1, -2, -3, -9])))
        )
        if len(invalid) > 0:
            issues.append(f"Invalid percentages in {col}: {len(invalid)} records")
    
    # Check for year coverage
    years = sorted(df["year"].unique().to_list())
    expected_years = list(range(min(years), max(years) + 1))
    missing_years = set(expected_years) - set(years)
    if missing_years:
        issues.append(f"Missing years: {missing_years}")
    
    # Check for ID consistency
    id_cols = ["ncessch", "leaid", "fips"]
    for col in id_cols:
        if col in df.columns:
            nulls = df[col].null_count()
            if nulls > 0:
                issues.append(f"Null IDs in {col}: {nulls} records")
    
    return issues
```

### Cross-Source Validation

Compare EDFacts data with other sources:

| Source | Compare To | Check |
|--------|------------|-------|
| EDFacts enrollment | CCD enrollment | Should be similar |
| EDFacts grad rates | State reports | Should match |
| EDFacts assessments | State reports | Should match |

```python
def cross_validate(edfacts_df, ccd_df, merge_keys, compare_cols):
    """Cross-validate EDFacts with CCD data."""
    
    merged = edfacts_df.join(
        ccd_df,
        on=merge_keys,
        suffix="_ccd"
    )
    
    discrepancies = []
    for col in compare_cols:
        ccd_col = f"{col}_ccd"
        diff = merged.with_columns(
            (pl.col(col) - pl.col(ccd_col)).abs().alias(f"{col}_diff")
        )
        
        large_diff = diff.filter(pl.col(f"{col}_diff") > 5)
        if len(large_diff) > 0:
            discrepancies.append({
                "column": col,
                "records_with_large_diff": len(large_diff)
            })
    
    return discrepancies
```

## Documentation Practices

### What to Document

For any EDFacts analysis, document:

| Element | Description |
|---------|-------------|
| Data version | Which release of the data |
| Years included | Time period of analysis |
| Filters applied | States, grades, subgroups |
| Missing data handling | How -1, -2, -3, -9 treated |
| Suppression impact | % records suppressed |
| Known issues | Any data quality issues |
| COVID impact | How COVID years handled |

### Documentation Template

```markdown
## Data Notes

### Source
- Data: EDFacts via Urban Institute Education Data Portal
- Version: [version number]
- Access date: [date]

### Scope
- Years: [range]
- States: [list or "all"]
- Grades: [list]
- Subgroups: [list]

### Data Quality
- Records suppressed (code -3): X%
- Records not reported (code -2): X%
- Records with ranges (not exact): X%

### Limitations
- [COVID-19 impact if relevant]
- [Assessment changes if relevant]
- [Other issues]

### Processing
- Missing values handled by: [approach]
- Midpoint variables used for: [list]
- Exclusions: [any records excluded]
```

### Example: Full Documentation

```markdown
## Data Notes for State Proficiency Analysis

### Source
- Data: EDFacts Assessment Data via Urban Institute Education Data Portal
- Version: 2024.1
- Access date: January 15, 2024

### Scope
- Years: 2017-18 through 2022-23
- States: All 50 states + DC
- Grades: Grade 4 reading
- Subgroups: All students, economically disadvantaged, students with disabilities

### Data Quality
- 2019-20 data excluded due to COVID testing waivers
- 2020-21 has participation below 95% in many states
- 12% of school-year-subgroup records suppressed (code -3)
- 3% of records not reported (code -2)

### Limitations
- Proficiency rates NOT comparable across states
- Several states changed assessments during period (breaks noted in text)
- CEP schools may inflate economically disadvantaged counts

### Processing
- Used _midpt variables for suppressed exact values
- Excluded records with -1, -2, -3 codes
- Weighted state averages by student count

### Citation
EDFacts Assessment Data, Education Data Portal (Version [version]),
Urban Institute, accessed [date],
https://educationdata.urban.org/documentation/,
made available under the ODC Attribution License.
```

## Recommendations Summary

### Before Analysis

1. Check for known data quality issues
2. Identify COVID-affected years
3. Look for assessment system changes
4. Assess suppression rates

### During Analysis

1. Document all data handling decisions
2. Use midpoint variables consistently
3. Flag uncertain estimates
4. Consider suppression bias

### When Reporting

1. Note all data limitations
2. Describe COVID data gaps
3. State that cross-state comparisons are invalid
4. Provide full data documentation
