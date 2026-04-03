# Civil Rights Data Collection (CRDC) Context

The CRDC collects data on equity indicators and civil rights compliance from public schools and districts. In this system, CRDC data is accessed through the Urban Institute Education Data Portal, which standardizes variable names to lowercase and applies integer encoding to categorical variables.

## Source Overview

| Attribute | Value |
|-----------|-------|
| Collector | U.S. Department of Education, Office for Civil Rights |
| Respondents | Public schools and districts |
| Focus | Educational equity and civil rights |
| Frequency | Biennial (every 2 years) |
| Available Years | 2011, 2013, 2015, 2017, 2020, 2021 |
| Primary Use | Discipline, course access, resource equity |

### Historical Context

- First collected 1968 as part of civil rights enforcement
- Modern collection began 2009-10 (released 2011)
- Scope and variables have expanded over time
- Focus on identifying discrimination and inequity

## Collection Schedule

### Available Years

| School Year | Release Year | Notes |
|-------------|--------------|-------|
| 2011-12 | 2012 | Sampled subset of schools |
| 2013-14 | 2014 | Expanded universe |
| 2015-16 | 2016 | Near-universe |
| 2017-18 | 2018 | Universe collection |
| 2020-21 | 2021 | COVID-19 impacted year |

### NOT Annual Data

**Critical**: CRDC is collected every TWO years.
- Cannot interpolate between collection years
- No data for 2012, 2014, 2016, 2018, 2019

### Timing Within Year

Data reflects the full school year (not point-in-time):
- Discipline counts: full year
- Enrollment: varies by variable
- Course enrollment: full year

## Sampling and Coverage

### Sample vs. Universe

| Collection | Approach |
|------------|----------|
| 2011-12 | Sample of ~7,000 districts |
| 2013-14 | Expanded sample |
| 2015-16 | Near-universe (~96,000 schools) |
| 2017-18 | Universe (all public schools) |
| 2020-21 | Universe |

### Coverage Implications

- Early years: Not all schools represented
- Cannot aggregate early samples to national totals
- Sample weights not provided
- Comparisons across years require same schools

### Verifying Coverage

```python
# Check school coverage
def crdc_coverage_check(crdc_df, ccd_df, year):
    crdc_schools = set(crdc_df["ncessch"].unique())
    ccd_schools = set(ccd_df["ncessch"].unique())
    
    coverage = len(crdc_schools & ccd_schools) / len(ccd_schools) * 100
    print(f"CRDC covers {coverage:.1f}% of CCD schools for {year}")
    
    return coverage
```

## Self-Reported Data

### Quality Implications

CRDC is self-reported by districts:

| Issue | Impact |
|-------|--------|
| Definition interpretation | Districts may define categories differently |
| Data system quality | Varies by district size and resources |
| Verification | OCR spot-checks but cannot verify all |
| Incentives | Under-reporting discipline may occur |

### Known Quality Concerns

1. **Small districts**: May have less sophisticated data systems
2. **New districts**: First-time reporters have learning curve
3. **Sensitive categories**: Discipline data may be underreported
4. **Complex categories**: Restraint/seclusion definitions vary

## Discipline Data

### Categories Collected

| Category | Definition Notes |
|----------|------------------|
| In-school suspension | Student removed from class but remains in school |
| Out-of-school suspension | Student removed from school premises |
| Expulsion | Removal for extended period or permanent |
| Referral to law enforcement | Any contact with police |
| School-related arrest | Arrest on school property or for school incident |
| Corporal punishment | Physical discipline (where legal) |
| Restraint | Physical restraint of student |
| Seclusion | Involuntary confinement |

### Discipline Data Caveats

**Definition Variation:**
- "Suspension" length thresholds vary by district
- "Referral to law enforcement" interpretation varies
- State laws affect what must be reported

**Zero-Tolerance Policies:**
- Districts with mandatory discipline policies show higher counts
- Policy changes affect time series
- Not necessarily indicator of student behavior

**Underreporting Concerns:**
- Discipline carries stigma
- Districts may use unreported informal discipline
- Electronic records may be incomplete

### Analyzing Discipline Data

```python
# Discipline rates per 100 students
def calculate_discipline_rate(df, discipline_col, enrollment_col):
    return (df[discipline_col] / df[enrollment_col] * 100)

# Compare across subgroups
def discipline_disparity(df, discipline_col, group1, group2):
    rate1 = df.filter(pl.col("subgroup") == group1)[discipline_col].mean()
    rate2 = df.filter(pl.col("subgroup") == group2)[discipline_col].mean()
    return rate1 / rate2  # Disparity ratio
```

## Variable Consistency

### Variables Added Over Time

| Variable Category | First Collected |
|-------------------|-----------------|
| Basic discipline | 2011 |
| Restraint/seclusion | 2011 |
| Chronic absenteeism | 2015 |
| Preschool suspension | 2015 |
| Sexual harassment | 2015 |
| Advanced coursework access | 2011 (expanded later) |

### Definition Changes

Always compare codebooks across collection years:
- Variable names may change
- Categories may be combined or split
- Response options may differ

### Missing Variables

Check that variables exist for your year:
```python
# Verify variable availability
def check_variable_availability(variable, year):
    availability = {
        "chronic_absent": [2015, 2017, 2020],
        "preschool_suspend": [2015, 2017, 2020],
        # Add more as needed
    }
    if year not in availability.get(variable, []):
        print(f"WARNING: {variable} not available for {year}")
```

## COVID-19 Impact (2020-2021)

The 2020-21 collection reflects pandemic conditions:

### Comparability Issues

| Domain | Impact |
|--------|--------|
| Discipline | Reduced due to remote learning |
| Chronic absenteeism | Definition changed (virtual attendance) |
| Course enrollment | AP/IB offerings may have changed |
| School staffing | Significant changes |

### What's Different

1. **Reduced in-person time**: Discipline naturally lower
2. **Virtual attendance**: Absenteeism measured differently
3. **Course access**: Some courses not offered
4. **New indicators**: COVID-specific variables added

### Recommendation

Do NOT directly compare 2020-21 to prior years without explicitly noting COVID context.

## Course Access Data

### What's Collected

| Category | Examples |
|----------|----------|
| Math | Algebra I, Algebra II, Calculus |
| Science | Physics, Chemistry, Biology |
| AP courses | By subject area |
| Computer science | Any CS course |
| Career/technical | By pathway |

### Access vs. Enrollment

CRDC distinguishes:
- **Course offered**: School offers the course
- **Student enrolled**: Students taking the course

### Equity Analysis

```python
# Course access disparity
def course_access_disparity(df):
    # Schools with no access vs. students by subgroup
    return df.group_by(["school_has_ap", "student_race"]).agg(
        pl.col("enrollment").sum()
    )
```

## Linking CRDC to Other Data

### To CCD

CRDC uses NCESSCH identifiers, same as CCD:

```python
# Join CRDC to CCD
crdc = fetch("schools/crdc/discipline/2017")
ccd = fetch("schools/ccd/directory/2017")

merged = crdc.join(ccd, on="ncessch", how="left")
```

### Year Alignment

CRDC is biennial; align with correct CCD year:

| CRDC Collection | CCD Year to Use |
|-----------------|-----------------|
| 2017-18 CRDC | 2017-18 CCD |
| 2015-16 CRDC | 2015-16 CCD |

### Coverage Differences

Not all CCD schools are in CRDC (especially early years):
- Check for nulls after merge
- Document schools dropped due to non-match

## Suppression

### Suppression Rules

Small cell sizes are suppressed for privacy:
- Typically counts fewer than 3-5 students
- Affects subgroup breakdowns
- More suppression in smaller schools

### Suppression Impact

```python
# Check suppression rate before analysis
def suppression_rate(df, variable):
    suppressed = df.filter(pl.col(variable) == -3).height
    total = df.height
    rate = suppressed / total * 100
    
    if rate > 10:
        print(f"WARNING: {rate:.1f}% of {variable} is suppressed")
        print("Subgroup analysis may be unreliable")
    
    return rate
```

## Recommended Practices

### Before Analysis

1. **Check collection year coverage** - Sample vs. universe
2. **Verify variable exists** - Not all variables all years
3. **Compare definitions** - Review codebook for your year
4. **Check suppression** - Especially for subgroup analysis
5. **Note COVID impact** - If using 2020-21 data

### For Discipline Analysis

1. **Calculate rates per enrollment** - Not raw counts
2. **Compare within similar school types** - Elementary vs. high school differ
3. **Consider policy context** - Zero-tolerance affects counts
4. **Document definition interpretation**

### For Time Series

1. **Use only universe years for trends** - 2015+
2. **Same schools across years** - Restrict to consistent sample
3. **Note definition changes**
4. **Exclude or flag 2020-21**

### For Equity Analysis

1. **Check suppression by subgroup** - Small groups often suppressed
2. **Use disparity ratios** - Compare to majority group
3. **Control for school characteristics**
4. **Document data limitations**

## Related Data Sources

| Source | Use When |
|--------|----------|
| CCD | Need school/district characteristics |
| EDFacts | Need assessment/graduation data |
| State administrative data | Need more detailed discipline records |
| OCR complaints | Need enforcement context |

## Quick Reference Card

| Task | Guidance |
|------|----------|
| Checking availability | CRDC is biennial (2011, 2013, 2015, 2017, 2020, 2021) |
| Using early years | Note sample vs. universe |
| Discipline analysis | Rates, not counts; within-type comparisons |
| Subgroup analysis | Check suppression first |
| Time series | Use 2015+ for consistency; flag COVID year |
| Linking to CCD | Use NCESSCH; check coverage |
| COVID year | Do not compare directly to prior years |
| Course access | Distinguish offered vs. enrolled |
