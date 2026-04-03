# Common Core of Data (CCD) Context

The Common Core of Data is the primary source for K-12 public school and district information in the United States. In this system, CCD data is accessed through the Urban Institute Education Data Portal, which standardizes variable names to lowercase, applies integer encoding to categorical variables, and provides a curated subset of the full CCD variable catalog.

## Source Overview

| Attribute | Value |
|-----------|-------|
| Collector | National Center for Education Statistics (NCES) |
| Respondents | State Education Agencies (SEAs) |
| Coverage | All public schools and local education agencies |
| Frequency | Annual |
| Available Years | 1986-present |
| Primary Use | School/district characteristics, enrollment, staffing |

## Coverage

### What CCD Includes

- **All public schools**: Traditional, charter, magnet, alternative
- **All public school districts**: Including state-operated and regional
- **Bureau of Indian Education (BIE) schools**: Federally operated
- **Department of Defense (DoDEA) schools**: Military base schools

### What CCD Excludes

- **Private schools**: Use Private School Universe Survey (PSS) instead
- **Homeschool students**: No federal data collection
- **Some charter schools in early years**: Coverage improved over time
- **Postsecondary institutions**: Use IPEDS instead

### Charter School Coverage Notes

| Period | Coverage Issue |
|--------|----------------|
| Pre-2000 | Many charter schools missing or miscoded |
| 2000-2010 | Improving but inconsistent state-to-state |
| 2010+ | Generally complete coverage |

Always verify charter school counts against state records for early years.

## Missing Data Patterns

### State-Level Clustering

Missing data in CCD tends to cluster by state:
- If one district in a state is missing data, others likely are too
- Caused by state reporting systems and capacity
- Check missingness rates BY STATE before comparing states

### High-Missingness Variables

| Variable | Issue | Affected Years |
|----------|-------|----------------|
| Free/reduced lunch | Direct certification changed reporting | 2010+ |
| FTE staff counts | Inconsistent state reporting | Varies |
| Enrollment by grade | Some states report all as "ungraded" | Varies |
| Finance data | Lag in reporting | Most recent 1-2 years |
| Student demographics | Race/ethnicity changes | Pre-2010 |

### Missing Data Check

```python
# Check missingness by state and variable
def check_ccd_missingness(df, variable):
    return df.group_by("fips").agg([
        (pl.col(variable) == -1).sum().alias("missing_n1"),
        (pl.col(variable) == -2).sum().alias("na_n2"),
        (pl.col(variable) == -3).sum().alias("suppressed_n3"),
        pl.col(variable).count().alias("total"),
    ]).with_columns(
        ((pl.col("missing_n1") + pl.col("na_n2") + pl.col("suppressed_n3")) 
         / pl.col("total") * 100).alias("pct_problematic")
    ).sort("pct_problematic", descending=True)
```

## Definitional Issues

### Variables with State Variation

| Variable | Issue | Recommendation |
|----------|-------|----------------|
| Dropouts | State definitions vary; CCD grades 7-12, CPS grades 10-12 | Use within-state comparisons only |
| Average Daily Attendance | Different state laws on calculation | Do not compare across states |
| Ungraded students | Some states assign all to one grade | Check by state before using grade-level data |
| Free/reduced lunch | Direct certification vs. application-based | Note methodology changes |
| Virtual students | Inconsistent counting across states | Verify state methodology |

### Dropout Rate Caveats

The CCD dropout rate has specific limitations:

1. **Grade coverage**: CCD covers grades 7-12; Current Population Survey (CPS) covers 10-12
2. **Calculation method**: Event dropout rate (annual) vs. status dropout rate (point-in-time)
3. **State definitions**: States define "dropout" differently
4. **GED completers**: Treatment varies by state

**Do not compare CCD dropout rates across states without understanding each state's definition.**

### Free/Reduced Price Lunch (FRPL)

FRPL eligibility is commonly used as a poverty proxy, but:

| Issue | Impact |
|-------|--------|
| Direct certification | Some students auto-enrolled without application; undercounts in application-based systems |
| Community Eligibility Provision (CEP) | High-poverty schools may show 100% eligible; not comparable to non-CEP schools |
| Stigma effects | Some eligible students don't apply |
| Income threshold changes | Federal poverty guidelines change annually |

**Recommendation**: For poverty analysis, consider supplementing with Census Bureau data (SAIPE).

## Time Series Issues

### Locale Code Changes (2006)

School locale codes were completely revised in 2006:

| Old System (pre-2006) | New System (2006+) |
|----------------------|-------------------|
| 1-8 numeric codes | 11-43 codes |
| 7 categories | 12 categories |
| Based on MSA definitions | Based on Census urban/rural definitions |

**Mapping is not one-to-one.** If analyzing locale over time:
- Use separate analyses for pre-2006 and post-2006
- Or use NCES locale crosswalk with caution

### Race/Ethnicity Category Changes

| Period | Categories |
|--------|------------|
| Pre-1997 | 5 categories (no multiracial) |
| 1997-2010 | Transition period; inconsistent |
| 2010+ | 7 categories including two or more races |

**Hispanic ethnicity**: Collected separately from race. A student can be Hispanic AND any race.

### Other Definition Changes

| Year | Change |
|------|--------|
| 2002 | Grade span definitions refined |
| 2006 | Locale codes revised |
| 2007 | Graduation rate calculation changed (ACGR introduced) |
| 2010 | Race categories expanded |
| 2014 | Virtual school identification improved |
| 2020 | COVID-related enrollment disruptions |

## Identifier Issues

### NCESSCH (School ID)

Format: 12 characters
```
[State FIPS: 2][LEAID suffix: 5][School: 5]
Example: 010000100100
         01 = Alabama
         00001 = District ID portion
         00100 = School ID portion
```

**When NCESSCH changes:**
- School closes and reopens
- School changes districts
- School merges with another
- Reporting corrections

### LEAID (District ID)

Format: 7 characters
```
[State FIPS: 2][State-assigned: 5]
Example: 0100001
         01 = Alabama
         00001 = State-assigned district ID
```

**When LEAID changes:**
- Districts merge
- Districts split
- Annexation of territory
- Reporting corrections

### Building Longitudinal Panels

```python
# Verify ID stability before merging years
def check_id_stability(df_year1, df_year2, id_col):
    ids_y1 = set(df_year1[id_col].unique())
    ids_y2 = set(df_year2[id_col].unique())
    
    return {
        "dropped": len(ids_y1 - ids_y2),
        "added": len(ids_y2 - ids_y1),
        "stable": len(ids_y1 & ids_y2),
        "pct_stable": len(ids_y1 & ids_y2) / len(ids_y1) * 100
    }
```

## State-Specific Notes

### Single-District States

| State | Note |
|-------|------|
| Hawaii | Single statewide district; school = district for aggregation |
| Washington DC | Single district; treated as state and district |

### Known Reporting Anomalies

| State | Year | Issue |
|-------|------|-------|
| Puerto Rico | Various | Reporting gaps; not always included |
| New York | Pre-2010 | NYC charter schools sometimes aggregated |
| California | Various | Large district reporting delays |
| Texas | Various | Charter network reporting changes |

### States with Frequent Issues

Some states have historically higher rates of missing or problematic data:
- Check state-specific missingness rates before analysis
- Contact state education agencies for context on anomalies
- Document any state exclusions in your analysis

## Recommended Practices

### Enrollment Totals

**Use grade 99 (total) rather than summing grade-level enrollment:**

```python
# RECOMMENDED - use reported total (grade=99, NOT -99)
total_enrollment = df.filter(pl.col("grade") == 99)["enrollment"]

# NOT RECOMMENDED - summing grades may miss ungraded students
# grade_sum = df.filter(pl.col("grade").is_between(0, 12))["enrollment"].sum()
```

**CRITICAL: Grade -1 means Pre-K, NOT missing data!**

The Portal uses integer encoding for grades:
- `grade = -1` → Pre-Kindergarten (semantic trap!)
- `grade = 0` → Kindergarten
- `grade = 1-12` → Grades 1-12
- `grade = 13` → Ungraded
- `grade = 99` → Total

```python
# WRONG - this filters out Pre-K students!
df = df.filter(pl.col("grade") >= 0)

# RIGHT - include Pre-K
pre_k = df.filter(pl.col("grade") == -1)
k_12 = df.filter(pl.col("grade").is_between(0, 12))
```

### State Comparisons

Before comparing across states:

1. Check missingness rates by state for key variables
2. Verify definition consistency (e.g., dropout definition)
3. Document any states excluded due to data quality
4. Consider using within-state comparisons or ranking rather than absolute values

### Longitudinal Analysis

1. Verify identifier stability across years
2. Check for definition changes in your time period
3. Account for school/district openings, closings, mergers
4. Use NCES-provided crosswalks when available
5. Document attrition from your panel

### Handling Suppression

```python
# Identify suppression impact
def suppression_analysis(df, variable):
    total = len(df)
    suppressed = df.filter(pl.col(variable) == -3).height
    
    if suppressed / total > 0.1:
        print(f"WARNING: {suppressed/total:.1%} of {variable} is suppressed")
        print("Disaggregated analysis may be unreliable")
```

## Related Data Sources

| Source | Use When |
|--------|----------|
| CRDC | Need discipline, course access, equity indicators |
| EDFacts | Need assessment results, graduation rates |
| SAIPE | Need poverty estimates (supplement to FRPL) |
| PSS | Need private school data |
| Census | Need community demographics |
| NHGIS | Need school-census geography links |

## Quick Reference Card

| Task | Guidance |
|------|----------|
| Getting enrollment | Use grade=99 for totals (integer, not -99) |
| Pre-K enrollment | Use grade=-1 (**NOT** missing data!) |
| Comparing states | Check missingness first |
| Using FRPL | Note CEP and direct certification |
| Time series | Check for definition changes |
| Linking years | Verify ID stability |
| Disaggregating | Check suppression rates |
| Using locale | Pre-2006 vs. post-2006 not comparable |
| Dropout rates | Within-state only |

## Portal Integer Encoding Reference

CCD data uses integer codes, not strings:

| Variable | Values | Notes |
|----------|--------|-------|
| Grade | -1 to 13, 99 | -1=Pre-K (semantic trap!), 0=K, 99=Total |
| Race | 1-7, 99 | 1=White, 2=Black, 3=Hispanic, etc. |
| Sex | 1, 2, 99 | 1=Male, 2=Female, 99=Total |
| Charter | 0, 1 | 0=No, 1=Yes |
| School Level | 0-4 | 1=Primary, 2=Middle, 3=High |

See `education-data-context` SKILL.md for complete encoding tables.
