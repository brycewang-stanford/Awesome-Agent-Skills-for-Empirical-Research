# EDFacts Context

EDFacts provides state-reported data on assessment results, graduation rates, and other accountability indicators for K-12 public schools. In this system, EDFacts data is accessed through the Urban Institute Education Data Portal, which converts original NCES string codes to integer encodings and standardizes variable names to lowercase.

## Source Overview

| Attribute | Value |
|-----------|-------|
| Collector | U.S. Department of Education |
| Respondents | State Education Agencies |
| Mandate | ESEA/ESSA accountability requirements |
| Coverage | Public schools and districts |
| Primary Use | Assessment proficiency, graduation rates |
| Available Years | 2010+ (varies by indicator) |

## Critical Limitation: State Assessments Not Comparable

**THE most important caveat for EDFacts:**

### Why You Cannot Compare Across States

| Factor | How It Varies |
|--------|---------------|
| Assessment content | Each state writes own tests |
| Proficiency cut scores | Set by each state |
| Grade-level expectations | State standards differ |
| Test difficulty | Not calibrated across states |
| Scaling method | Different psychometric approaches |

### What This Means

A student who is "proficient" in Mississippi is NOT equivalent to a student who is "proficient" in Massachusetts:
- Cut scores differ dramatically
- Content coverage differs
- Same-ability student might pass in one state, fail in another

### NAEP Is the Exception

The National Assessment of Educational Progress (NAEP) IS comparable across states:
- Same test nationally
- Same cut scores
- Not in EDFacts (separate data source)

## Proficiency Data

### How Proficiency Is Reported

EDFacts reports proficiency as percentages meeting state standards:

| Variable Type | Example |
|---------------|---------|
| Proficiency rate | 45% proficient or above |
| Ranges | 35-50% (when suppressed) |
| Midpoint estimate | 42.5% (calculated from range) |

### Using Range Data

When counts are small, exact percentages are suppressed. Instead, ranges are provided:

```python
# EDFacts proficiency range handling
# Look for variables ending in _midpt for single-value estimates

df.select([
    "proficiency_low",   # Lower bound
    "proficiency_high",  # Upper bound
    "proficiency_midpt"  # Midpoint for analysis
])
```

**Use `_midpt` variables for single-value analysis**, but note uncertainty.

### Proficiency Levels

Most states report:
- Below Basic / Not Meeting
- Basic / Partially Meeting
- Proficient / Meeting
- Advanced / Exceeding

But labels and cut scores vary by state.

## Missing Assessment Data

### 2019-20 Testing Waivers

**Critical**: Most states did not test in spring 2020 due to COVID-19:
- 2019-20 assessment data largely missing
- States received federal waivers
- Cannot calculate 2020 proficiency for most states

### Other Missing Data

| Reason | Impact |
|--------|--------|
| State testing changes | New test = break in series |
| Grade span changes | Tested grades may change |
| Opt-out movements | Some states had high opt-out rates |
| Natural disasters | Hurricane years may have missing data |

### Check Before Analysis

```python
# Check assessment data availability
def check_assessment_years(df, state_fips):
    state_data = df.filter(pl.col("fips") == state_fips)
    
    available_years = state_data["year"].unique().sort()
    print(f"Available years for state {state_fips}: {available_years}")
    
    # Check for gaps
    all_years = range(min(available_years), max(available_years) + 1)
    missing = set(all_years) - set(available_years)
    if missing:
        print(f"Missing years: {missing}")
```

## Graduation Rates

### Adjusted Cohort Graduation Rate (ACGR)

EDFacts reports ACGR, the federal accountability measure:

| Aspect | Definition |
|--------|------------|
| Cohort | First-time 9th graders |
| Adjustments | Transfer in/out, emigration, death |
| Denominator | Adjusted cohort (original - out + in) |
| Numerator | Graduate with regular diploma in 4 years |

### Extended Graduation Rates

| Rate | Definition |
|------|------------|
| 4-year | Within 4 years of 9th grade |
| 5-year | Within 5 years |
| 6-year | Within 6 years |
| 7-year | Within 7 years (some states) |

### Graduation Rate Caveats

| Issue | Impact |
|-------|--------|
| Diploma type | Regular diploma only; excludes alternative credentials |
| GED completers | Counted as non-graduates in ACGR |
| Late graduates | Not counted in 4-year rate |
| Special education | May take longer; extended rates more appropriate |
| Transfer tracking | States may lose track of transfers |

### Cohort Timing

For `year=2019` graduation data:
- Cohort entered 9th grade in fall 2015
- 4-year graduation measured in 2019
- Data released in 2020

## Suppression

### Heavy Suppression for Subgroups

EDFacts has significant suppression:

| Subgroup | Suppression Level |
|----------|-------------------|
| All students | Low |
| Major racial groups | Moderate |
| Small racial groups | High |
| Students with disabilities | High |
| English learners | Moderate to high |
| Economically disadvantaged | Moderate |

### Suppression Impact Analysis

```python
# Check suppression before disaggregating
def check_subgroup_suppression(df, variable, subgroup_col):
    return df.group_by(subgroup_col).agg([
        (pl.col(variable) == -3).sum().alias("suppressed"),
        pl.col(variable).count().alias("total")
    ]).with_columns(
        (pl.col("suppressed") / pl.col("total") * 100).alias("pct_suppressed")
    ).sort("pct_suppressed", descending=True)
```

### Why So Much Suppression?

- Small schools have small subgroups
- 10-student minimum for many indicators
- Complementary suppression to prevent calculation
- Rural areas particularly affected

## Known Data Issues

### State-Specific Problems

| State | Year | Issue |
|-------|------|-------|
| Virginia | 2016-17 | Grade 5-8 math proficiency shares inaccurate |
| Various | 2019-20 | COVID testing waivers - no data |

### Testing Irregularities

Some states have had testing irregularities in specific years:
- Check state education agency announcements
- Unusual year-over-year changes may indicate problems
- Exclude affected years from analysis

## Valid vs. Invalid Comparisons

### Valid Comparisons

| Comparison Type | Validity |
|-----------------|----------|
| Same state over time | Valid (with same test) |
| Districts within state | Valid |
| Schools within district | Valid |
| Subgroups within school | Valid (watch suppression) |

### Invalid Comparisons

| Comparison Type | Why Invalid |
|-----------------|-------------|
| State vs. state proficiency | Different tests and cut scores |
| National ranking by proficiency | Meaningless |
| State "improvement" via proficiency | May reflect test/cut score changes |

## Time Series Issues

### Assessment System Changes

States periodically change assessments:
- New standards (Common Core transition ~2015)
- New test vendors
- New cut scores

**These create breaks in time series.**

### Identifying Assessment Changes

```python
# Look for suspicious jumps in state data
def identify_assessment_changes(df, state_fips, variable):
    state_data = df.filter(pl.col("fips") == state_fips).sort("year")
    
    # Calculate year-over-year change
    state_data = state_data.with_columns(
        (pl.col(variable) - pl.col(variable).shift(1)).alias("yoy_change")
    )
    
    # Flag large changes (>10 percentage points)
    large_changes = state_data.filter(pl.col("yoy_change").abs() > 10)
    
    return large_changes
```

### Common Transition Years

| Event | Years Affected |
|-------|----------------|
| Common Core standards | 2014-2016 |
| PARCC/SBAC implementation | 2015-2017 |
| ESSA transition | 2017-2018 |
| COVID waivers | 2019-2020 |

## Using Scale Scores

### When Available

Some EDFacts data includes scale score information:
- More comparable over time within state
- Allows for growth measurement
- Not all variables have scale scores

### Scale Score Advantages

- Not affected by cut score changes (same scale)
- Can measure growth, not just proficiency
- More granular than proficiency categories

## Recommended Practices

### For Any Analysis

1. **Never compare proficiency across states**
2. **Check for assessment system changes in your time period**
3. **Document suppression rates**
4. **Note COVID-19 impact on 2019-20 data**
5. **Use within-state comparisons only**

### For Proficiency Analysis

1. Use within-state trends only
2. Check for test changes in period
3. Use `_midpt` for suppressed ranges
4. Note what "proficient" means in that state

### For Graduation Rate Analysis

1. Use ACGR for federal comparability
2. Note extended rates for complete picture
3. Remember cohort timing (entry year)
4. Account for transfer tracking limitations

### For Subgroup Analysis

1. Check suppression rates first
2. Smaller groups = more suppression
3. May need to aggregate to district/state level
4. Document groups excluded due to suppression

### For Time Series

1. Identify assessment system changes
2. Create separate pre/post periods if needed
3. Exclude COVID-affected years or note clearly
4. Verify indicator definitions haven't changed

## Alternatives for Cross-State Comparison

If you need to compare across states, consider:

| Source | Use |
|--------|-----|
| NAEP | Nationally comparable assessment (sample) |
| SAT/ACT | Participation varies; selection bias |
| AP exam scores | For AP participants only |
| ACGR | Graduation rates more comparable than proficiency |

## Quick Reference Card

| Task | Guidance |
|------|----------|
| Cross-state proficiency | DO NOT COMPARE - not valid |
| Within-state trends | Valid if same test period |
| Graduation rates | ACGR is more comparable |
| Subgroup analysis | Check suppression first |
| 2019-20 data | Mostly missing (COVID waivers) |
| Time series | Check for assessment changes |
| Suppressed values | Use `_midpt` variables |
| National ranking | Invalid for state assessments |
