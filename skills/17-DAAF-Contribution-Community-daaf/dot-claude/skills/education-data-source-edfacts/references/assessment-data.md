# Assessment Data

Understanding state assessment data in EDFacts, including proficiency levels, why cross-state comparisons are invalid, and proper analysis approaches.

## Contents

- [Critical Limitation: No Cross-State Comparisons](#critical-limitation-no-cross-state-comparisons)
- [Why States Cannot Be Compared](#why-states-cannot-be-compared)
- [NAEP: The Exception](#naep-the-exception)
- [Proficiency Levels](#proficiency-levels)
- [Assessment Data Structure](#assessment-data-structure)
- [Range and Midpoint Variables](#range-and-midpoint-variables)
- [Time Series Considerations](#time-series-considerations)
- [Valid Analysis Approaches](#valid-analysis-approaches)

## Critical Limitation: No Cross-State Comparisons

**This is the most important caveat for EDFacts assessment data.**

State assessment proficiency rates are **NOT comparable across states**. Rankings or comparisons of states by proficiency percentages are **meaningless** and **misleading**.

### The Core Problem

Each state administers its own assessment with its own proficiency standards:

| Component | State A | State B |
|-----------|---------|---------|
| Test content | State-designed | State-designed |
| Difficulty level | Varies | Varies |
| Cut scores | State-determined | State-determined |
| Proficiency definition | State-specific | State-specific |

A student who scores "proficient" in one state might score "below basic" in another state—not because they learned more, but because one state has lower standards.

## Why States Cannot Be Compared

### 1. Different Assessment Content

Each state develops or selects its own assessment:
- Different question types
- Different content coverage
- Different cognitive demand levels
- Different alignment to standards

### 2. Different Academic Standards

State learning standards vary significantly:
- Grade-level expectations differ
- Content scope and sequence varies
- Depth of knowledge requirements differ

### 3. Different Proficiency Cut Scores

The score needed to be "proficient" varies dramatically:

| Example | Impact |
|---------|--------|
| State with low cut score | Higher proficiency rates |
| State with high cut score | Lower proficiency rates |
| Same student performance | Different labels |

### 4. Political and Economic Pressures

States face pressures that influence cut scores:
- Avoid having too many "failing" schools
- Balance rigor with achievable targets
- Respond to stakeholder concerns

### Evidence: NAEP Mapping Studies

NCES periodically maps state proficiency standards onto the NAEP scale:

| Finding | Implication |
|---------|-------------|
| State cut scores vary by 40+ NAEP points | Huge differences in what "proficient" means |
| Some state "proficient" = NAEP "Basic" | States labeling students proficient at low levels |
| Variation persists over time | Not converging to common standard |

### Example: Mapping Results

From NCES mapping studies (illustrative):

| State | Grade 4 Reading "Proficient" | NAEP Equivalent |
|-------|------------------------------|-----------------|
| High-standards state | 250 scale score | NAEP Proficient |
| Low-standards state | 215 scale score | NAEP Basic |
| Difference | 35 points | One achievement level |

**The same student would be "proficient" in one state and "basic" in another.**

## NAEP: The Exception

The National Assessment of Educational Progress (NAEP) IS comparable across states:

| Feature | NAEP | State Assessments |
|---------|------|-------------------|
| Test content | Identical nationally | State-specific |
| Cut scores | Same everywhere | State-determined |
| Administration | Standardized | Varies |
| Comparability | Cross-state valid | Within-state only |

### NAEP Limitations

| Limitation | Impact |
|------------|--------|
| Sample-based | No individual student scores |
| Limited grades | 4, 8, 12 (not tested every year) |
| Limited subjects | Reading, math, science, writing |
| Not for accountability | Cannot identify individual schools |

### Using NAEP for Cross-State Analysis

For valid cross-state comparisons, use NAEP data (not available in the Portal mirror):

```python
# NAEP data is available from nationsreportcard.gov
# or the NAEP Data Explorer — it is NOT in the Education Data Portal.
#
# Example: Valid cross-state comparison (conceptual — NAEP data is external)
# naep_scores = pl.read_csv("naep_grade4_reading_2022.csv")
# state_rankings = naep_scores.sort("avg_scale_score", descending=True)
# This comparison IS meaningful because NAEP uses the same test nationwide
```

## Proficiency Levels

### Standard Achievement Levels

Most states report four levels (labels vary):

| Level | Common Labels | Description |
|-------|---------------|-------------|
| Level 4 | Advanced, Exceeds | Above grade-level expectations |
| Level 3 | Proficient, Meets | At grade-level expectations |
| Level 2 | Basic, Approaches | Partial mastery |
| Level 1 | Below Basic, Does Not Meet | Minimal mastery |

### Proficiency Rate Definition

**Proficiency rate** typically means % of students at Levels 3 + 4:

```
Proficiency Rate = (# Proficient + # Advanced) / # Tested × 100
```

### Cautions About Proficiency

| Issue | Explanation |
|-------|-------------|
| Binary reduction | Loses information about distribution |
| Cut score proximity | Students just below and just above are similar |
| Incentive to focus on "bubble" | Students near cut score get disproportionate attention |
| Doesn't capture growth | Proficiency status, not progress |

## Assessment Data Structure

### Variables in EDFacts Assessment Data

| Variable | Description |
|----------|-------------|
| `read_test_pct_prof_low` | Reading proficiency %, lower bound |
| `read_test_pct_prof_high` | Reading proficiency %, upper bound |
| `read_test_pct_prof_midpt` | Reading proficiency %, midpoint |
| `math_test_pct_prof_low` | Math proficiency %, lower bound |
| `math_test_pct_prof_high` | Math proficiency %, upper bound |
| `math_test_pct_prof_midpt` | Math proficiency %, midpoint |
| `read_test_num_valid` | Number of valid reading scores |
| `math_test_num_valid` | Number of valid math scores |

### Subject Coverage

| Subject | Availability |
|---------|--------------|
| Reading/ELA | All states, grades 3-8 + high school |
| Mathematics | All states, grades 3-8 + high school |
| Science | Many states, selected grades |

### Grade Levels

Assessment required at:
- Grades 3-8 annually
- Once in high school (typically grade 10 or 11)

## Range and Midpoint Variables

### Why Range Variables Exist

When exact proficiency rates would reveal individual students, data is suppressed and reported as ranges:

| Scenario | Reporting |
|----------|-----------|
| Large school | Exact percentage |
| Small school/subgroup | Range (e.g., 30-40%) |

### Range Variable Structure

| Variable Suffix | Meaning |
|-----------------|---------|
| `_low` | Lower bound of range |
| `_high` | Upper bound of range |
| `_midpt` | Calculated midpoint: (low + high) / 2 |

### Using Midpoint Variables

**Always use `_midpt` variables for quantitative analysis**:

```python
# Correct approach
df.select([
    "read_test_pct_prof_midpt",  # Use midpoint
    "math_test_pct_prof_midpt"   # Use midpoint
])

# Avoid
df.select([
    "read_test_pct_prof_low",   # Only bounds, not useful alone
    "read_test_pct_prof_high"   # Only bounds, not useful alone
])
```

### Midpoint Caveats

| Caveat | Implication |
|--------|-------------|
| Introduces uncertainty | True value anywhere in range |
| Wider ranges = more uncertainty | Document range widths |
| Not exact | Treat as estimate |

## Time Series Considerations

### Assessment System Changes

States periodically change their assessments:

| Change Type | Impact |
|-------------|--------|
| New test vendor | Break in time series |
| New standards | Break in time series |
| Re-norming | Break in time series |
| New cut scores | Break in time series |

### Major Transition Periods

| Period | Event | Impact |
|--------|-------|--------|
| 2014-2017 | Common Core transition | Many states adopted new tests |
| 2015-2017 | PARCC/SBAC implementation | Consortium assessments |
| 2019-2020 | COVID-19 | Testing largely waived |
| 2020-2021 | Return to testing | Varied state approaches |

### Identifying Assessment Changes

```python
def detect_assessment_changes(df, state_fips, variable):
    """Flag potential assessment system changes."""
    state_data = df.filter(pl.col("fips") == state_fips).sort("year")
    
    # Calculate year-over-year change
    state_data = state_data.with_columns(
        (pl.col(variable) - pl.col(variable).shift(1)).alias("yoy_change")
    )
    
    # Large changes (>10 points) suggest assessment change
    suspicious = state_data.filter(pl.col("yoy_change").abs() > 10)
    return suspicious
```

### Handling Time Series Breaks

| Approach | When to Use |
|----------|-------------|
| Split series | Analyze pre- and post-change separately |
| Exclude transition year | Drop year of change |
| Document break | Note limitation in findings |
| Verify with state | Check state documentation |

## Valid Analysis Approaches

### Valid Comparisons

| Comparison | Validity | Notes |
|------------|----------|-------|
| Same state over time | Valid | If same assessment system |
| Schools within state | Valid | Same test, same standards |
| Districts within state | Valid | Same test, same standards |
| Subgroups within school | Valid | Check suppression |
| Cross-state proficiency | **INVALID** | Different tests and standards |

### Example: Valid Trend Analysis

```python
# Valid: Within-state trend analysis
def analyze_state_trend(df, state_fips, start_year, end_year):
    """Analyze proficiency trends within a single state."""
    
    state_data = (df
        .filter(pl.col("fips") == state_fips)
        .filter(pl.col("year").is_between(start_year, end_year))
    )
    
    # Check for assessment changes in period
    # (You would implement detection logic here)
    
    trend = (state_data
        .group_by("year")
        .agg(pl.col("read_test_pct_prof_midpt").mean())
        .sort("year")
    )
    
    return trend
```

### Example: Within-State School Comparison

```python
# Valid: Compare schools within same state
def compare_schools_within_state(df, state_fips, year):
    """Compare schools within the same state."""
    
    state_schools = (df
        .filter(pl.col("fips") == state_fips)
        .filter(pl.col("year") == year)
        .select([
            "ncessch",
            "school_name",
            "read_test_pct_prof_midpt",
            "math_test_pct_prof_midpt"
        ])
    )
    
    return state_schools.sort("read_test_pct_prof_midpt", descending=True)
```

### Invalid Analysis Example

```python
# INVALID: Cross-state comparison
# DO NOT DO THIS

def invalid_state_ranking(df, year):
    """THIS IS INVALID - DO NOT USE."""
    
    # This ranking is MEANINGLESS
    state_ranking = (df
        .filter(pl.col("year") == year)
        .group_by("fips")
        .agg(pl.col("read_test_pct_prof_midpt").mean())
        .sort("read_test_pct_prof_midpt", descending=True)
    )
    
    # WARNING: This comparison is invalid
    # States have different tests and standards
    return state_ranking  # DO NOT USE
```

## Participation Rates

### 95% Participation Requirement

ESSA requires 95% student participation in assessments:

| Requirement | Details |
|-------------|---------|
| All students | 95% of each school |
| Each subgroup | 95% of each reportable subgroup |
| Consequences | States must address low participation |

### Participation Data Variables

| Variable | Description |
|----------|-------------|
| `read_test_pct_part` | Reading participation rate |
| `math_test_pct_part` | Math participation rate |

### Low Participation Concerns

| Issue | Impact |
|-------|--------|
| Selection bias | Who opts out may differ systematically |
| Proficiency inflation | If low performers opt out, rates inflated |
| Accountability issues | May not meet 95% requirement |

### Opt-Out Movements

Some states/communities have significant opt-out rates:
- Certain states have organized opt-out movements
- Higher income communities sometimes have higher opt-out
- Can significantly affect school-level data

## Recommendations for Analysis

### Always

1. **Clarify scope**: State clearly that analysis is within-state only
2. **Check for breaks**: Identify assessment system changes
3. **Use midpoint variables**: For suppressed data
4. **Document suppression**: Report suppression rates
5. **Note COVID gap**: 2019-20 data largely missing

### Never

1. **Never rank states by proficiency**: Invalid comparison
2. **Never claim cross-state differences**: Tests are different
3. **Never ignore assessment changes**: Creates false trends
4. **Never present proficiency as absolute**: It's state-specific

### Communication Template

When reporting findings:

> "Proficiency rates in [State] increased from X% to Y% between [Year1] and [Year2]. Note that state assessment proficiency rates reflect [State]'s specific standards and cannot be compared to other states. For cross-state comparisons, see NAEP results."
