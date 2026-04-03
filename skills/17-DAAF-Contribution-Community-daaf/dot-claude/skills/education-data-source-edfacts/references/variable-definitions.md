# Variable Definitions

Detailed definitions for key EDFacts variables, suppression codes, special values, and data handling.

## Contents

- [Missing and Suppressed Data Codes](#missing-and-suppressed-data-codes)
- [Range and Midpoint Variables](#range-and-midpoint-variables)
- [Assessment Variables](#assessment-variables)
- [Graduation Rate Variables](#graduation-rate-variables)
- [Participation Variables](#participation-variables)
- [Subgroup Codes](#subgroup-codes)
- [Geographic Identifiers](#geographic-identifiers)
- [Handling Special Values](#handling-special-values)

## Missing and Suppressed Data Codes

EDFacts uses specific numeric codes to indicate missing or suppressed data:

### Standard Missing Data Codes

| Code | Meaning | When Used |
|------|---------|-----------|
| `-1` | Missing/Not applicable | Data element not applicable to this entity |
| `-2` | Not reported | State did not report this data |
| `-3` | Suppressed | Data suppressed for privacy |
| `-9` | Rounds to zero | Value rounds to 0% |

### Understanding Each Code

#### `-1` (Missing/Not Applicable)

Data does not apply to this record:
- School doesn't serve tested grades
- Indicator not applicable to school type
- Data element doesn't exist for this entity

```python
# Example: Elementary school has no graduation rate
# grad_rate_midpt = -1 (not applicable)
```

#### `-2` (Not Reported)

State did not submit this data:
- State-level reporting issue
- Data collection problem
- Indicator not collected that year

```python
# Example: State didn't report participation rates
# read_test_pct_part = -2 (not reported)
```

#### `-3` (Suppressed for Privacy)

Data suppressed to protect student privacy:
- Small cell sizes
- Complementary suppression
- FERPA compliance

```python
# Example: Small subgroup, exact value would reveal individuals
# math_test_pct_prof_midpt = -3 (suppressed)
```

#### `-9` (Rounds to Zero)

Actual value rounds to 0% but isn't truly zero:
- Very small percentage
- Distinguishes from true 0%

```python
# Example: 0.4% proficient rounds to 0
# read_test_pct_prof_midpt = -9 (rounds to zero)
```

### Filtering Missing Data

```python
import polars as pl

# Remove all missing/suppressed values
clean_df = df.filter(
    (pl.col("read_test_pct_prof_midpt") >= 0)
)

# Or explicitly check for each code
clean_df = df.filter(
    ~pl.col("read_test_pct_prof_midpt").is_in([-1, -2, -3, -9])
)
```

## Range and Midpoint Variables

### Why Ranges Are Reported

When exact values could identify individual students (small cell sizes), EDFacts reports ranges instead:

| Exact Value | Would Reveal | Solution |
|-------------|--------------|----------|
| 33.3% | 1 of 3 students | Report range |
| 100% | All passed | Report range |
| 0% | None passed | Report range |

### Variable Naming Convention

| Suffix | Meaning | Example |
|--------|---------|---------|
| `_low` | Lower bound of range | `read_test_pct_prof_low` |
| `_high` | Upper bound of range | `read_test_pct_prof_high` |
| `_midpt` | Midpoint of range | `read_test_pct_prof_midpt` |

### Midpoint Calculation

```
midpt = (low + high) / 2
```

Example:
- `_low` = 30%
- `_high` = 40%
- `_midpt` = 35%

### Standard Range Widths

EDFacts uses standard range bands:

| Range | Width | Example |
|-------|-------|---------|
| Very narrow | 2-3 points | 48-50% |
| Standard | 5 points | 45-50% |
| Wider | 10 points | 40-50% |

### Best Practices for Ranges

1. **Always use `_midpt` for analysis**
   ```python
   # Correct
   avg_prof = df["read_test_pct_prof_midpt"].mean()
   
   # Not useful alone
   avg_low = df["read_test_pct_prof_low"].mean()
   ```

2. **Document uncertainty from ranges**
   ```python
   # Calculate uncertainty
   df = df.with_columns(
       (pl.col("read_test_pct_prof_high") - pl.col("read_test_pct_prof_low"))
       .alias("range_width")
   )
   avg_uncertainty = df["range_width"].mean()
   ```

3. **Report range width in findings**

## Assessment Variables

### Proficiency Variables

| Variable | Description | Type |
|----------|-------------|------|
| `read_test_pct_prof_low` | Reading % proficient, lower bound | Percentage |
| `read_test_pct_prof_high` | Reading % proficient, upper bound | Percentage |
| `read_test_pct_prof_midpt` | Reading % proficient, midpoint | Percentage |
| `math_test_pct_prof_low` | Math % proficient, lower bound | Percentage |
| `math_test_pct_prof_high` | Math % proficient, upper bound | Percentage |
| `math_test_pct_prof_midpt` | Math % proficient, midpoint | Percentage |

### Test Count Variables

| Variable | Description | Type |
|----------|-------------|------|
| `read_test_num_valid` | Number of valid reading test scores | Integer |
| `math_test_num_valid` | Number of valid math test scores | Integer |

### Using Test Counts

Test counts are useful for:
- Determining sample size
- Weighting averages
- Identifying suppression likelihood

```python
# Weight average by number of test-takers
weighted_avg = (
    df.filter(pl.col("read_test_num_valid") > 0)
    .select(
        (pl.col("read_test_pct_prof_midpt") * pl.col("read_test_num_valid")).sum() /
        pl.col("read_test_num_valid").sum()
    )
)
```

## Graduation Rate Variables

### Rate Variables

> **Empirically verified** from 2019 grad rate data. Note that `grad_rate_midpt` is **Int64** (not Float64 like assessment midpoints).

| Variable | Description | Portal Type |
|----------|-------------|-------------|
| `grad_rate_low` | Graduation rate, lower bound (null when exact) | Int64 |
| `grad_rate_high` | Graduation rate, upper bound (null when exact) | Int64 |
| `grad_rate_midpt` | Graduation rate, midpoint or exact value | Int64 |

### Cohort Variable

| Variable | Description | Portal Type |
|----------|-------------|-------------|
| `cohort_num` | Adjusted cohort size | Int64 |

> **Note:** The variable is `cohort_num`, NOT `cohort_count`. There is no `grad_count` column in the Portal data.

### Extended Rate Variables

Extended graduation rate variables (`grad_rate_5yr_midpt`, `grad_rate_6yr_midpt`) are not observed in the current Portal datasets. If your analysis requires extended rates, verify column availability empirically before proceeding.

## Participation Variables

### Participation Rate Variables

| Variable | Description |
|----------|-------------|
| `read_test_pct_part` | Reading test participation rate |
| `math_test_pct_part` | Math test participation rate |

### 95% Participation Threshold

| Rate | Status |
|------|--------|
| ≥95% | Meets federal requirement |
| <95% | Does not meet requirement |

### Using Participation Data

```python
# Identify schools below participation threshold
low_participation = df.filter(
    (pl.col("read_test_pct_part") < 95) |
    (pl.col("math_test_pct_part") < 95)
)
```

## Subgroup Codes

> **Portal Encoding Warning:** The Urban Institute Education Data Portal converts NCES string codes to integers. The documentation below shows NCES string codes in parentheses but **actual data uses integers**.

### Race/Ethnicity Codes (Portal Integer Encoding)

> **Empirically verified** from 2018 assessment data. Only these values appear in the `race` column.

| Portal Code | NCES Code | Description |
|-------------|-----------|-------------|
| `1` | WH | White |
| `2` | BL | Black or African American |
| `3` | HI | Hispanic/Latino of any race |
| `4` | AS | Asian |
| `5` | AM | American Indian/Alaska Native |
| `7` | MR | Two or more races |
| `99` | — | Total |

> **Note:** Code `6` (NH/PI), `8` (Nonresident alien), `9` (Unknown), `20` (Other) are NOT observed in EDFacts data. Negative codes (-1, -2, -3) are also not present in the `race` column -- suppression is applied to the *value* columns, not the subgroup filter columns.

### Special Population Codes (Portal Integer Encoding)

EDFacts uses **filter columns** for special populations. Each column has:
- `1` = Yes (student is in this subgroup)
- `99` = Total (all students)

| Column | NCES Code | Description |
|--------|-----------|-------------|
| `lep` | LEP | Limited English proficient students |
| `disability` | CWD | Students with disabilities (see disability codes below) |
| `homeless` | HOM | McKinney-Vento identified homeless students |
| `foster_care` | FCS | Students in foster care system |
| `migrant` | MIG | Migrant education program participants |
| `econ_disadvantaged` | ECODIS | Economically disadvantaged students |
| `military_connected` | MIL | Students from military families |

### Disability Codes (Portal Integer Encoding)

> **Empirically verified** from 2018 assessment and 2019 grad rate data. Only `1` and `99` are observed.

| Code | Description |
|------|-------------|
| `1` | Students with disabilities (IDEA-eligible) |
| `99` | Total (all students) |

> **Note:** The expanded disability codes (0-4) documented in other Portal sources are NOT present in EDFacts datasets. EDFacts uses a simple binary: `1` = students with disabilities, `99` = total.

### Sex Codes (Portal Integer Encoding)

| Code | Description |
|------|-------------|
| `1` | Male |
| `2` | Female |
| `9` | Unknown |
| `99` | Total |

### Filtering by Subgroup

```python
# Get data for students with disabilities (IDEA)
# Portal uses integer 1, NOT string "CWD"
cwd_data = df.filter(pl.col("disability") == 1)

# Get total row (all students)
all_students = df.filter(pl.col("race") == 99)

# Get Black students only
black_students = df.filter(pl.col("race") == 2)

# Get LEP students
lep_data = df.filter(pl.col("lep") == 1)

# Compare race groups
race_comparison = (df
    .filter(pl.col("race").is_in([1, 2, 3, 99]))  # White, Black, Hispanic, Total
    .group_by("race")
    .agg(pl.col("read_test_pct_prof_midpt").mean())
)
```

## Geographic Identifiers

> **Portal Data Types:** All identifiers are **Int64** in the Portal parquet files. The NCES source format (zero-padded strings) is described below for reference, but you will encounter integer values when working with the data.

### School-Level (Assessment datasets: 26 cols, Grad rate datasets: 18 cols)

| Variable | Description | Portal Type | NCES Source Format |
|----------|-------------|-------------|-------------------|
| `ncessch` | NCES school ID | Int64 | 12-char zero-padded |
| `ncessch_num` | School ID (same as ncessch) | Int64 | — |
| `school_name` | School name | String | — |

### District-Level (Assessment datasets: 23 cols, Grad rate datasets: 15 cols)

| Variable | Description | Portal Type | NCES Source Format |
|----------|-------------|-------------|-------------------|
| `leaid` | NCES district/LEA ID | Int64 | 7-char zero-padded |
| `leaid_num` | District ID (same as leaid) | Int64 | — |
| `lea_name` | LEA/district name | String | — |

### State-Level

| Variable | Description | Portal Type |
|----------|-------------|-------------|
| `fips` | State FIPS code | Int64 |

> **Note:** `state_name` and `state_abbrev` columns are NOT present in EDFacts datasets. Only `fips` is available. Join with CCD directory data to get state names.

### ID Format Reference (NCES Source)

```python
# NCESSCH logical format: SSLLLLLNNNNN (12 digits)
# SS = State FIPS (2 digits)
# LLLLL = LEA ID (5 digits)
# NNNNN = School ID within LEA (5 digits)
#
# In Portal data, this is stored as Int64 (no leading zeros):
# California example: ncessch = 60000100001 (Int64)
# NCES source:        ncessch = "060000100001" (12-char string)
```

## Handling Special Values

### Complete Data Cleaning Function

```python
import polars as pl

def clean_edfacts_data(df, value_cols):
    """
    Clean EDFacts data by handling special values.
    
    Parameters:
    -----------
    df : polars.DataFrame
        Raw EDFacts data
    value_cols : list
        Columns containing numeric values to clean
    
    Returns:
    --------
    polars.DataFrame with cleaned data
    """
    
    # Define missing value codes
    missing_codes = [-1, -2, -3, -9]
    
    for col in value_cols:
        # Replace missing codes with null
        df = df.with_columns(
            pl.when(pl.col(col).is_in(missing_codes))
            .then(None)
            .otherwise(pl.col(col))
            .alias(col)
        )
    
    return df
```

### Documenting Suppression

```python
def suppression_report(df, value_col):
    """Generate suppression report for a variable."""
    
    total = len(df)
    
    suppression_counts = {
        "total_records": total,
        "valid": (df[value_col] >= 0).sum(),
        "missing_na": (df[value_col] == -1).sum(),
        "not_reported": (df[value_col] == -2).sum(),
        "suppressed": (df[value_col] == -3).sum(),
        "rounds_to_zero": (df[value_col] == -9).sum()
    }
    
    suppression_counts["pct_valid"] = suppression_counts["valid"] / total * 100
    suppression_counts["pct_suppressed"] = suppression_counts["suppressed"] / total * 100
    
    return suppression_counts
```

### Working with Ranges

```python
def add_range_metrics(df, var_prefix):
    """Add range-related metrics to dataframe."""
    
    low_col = f"{var_prefix}_low"
    high_col = f"{var_prefix}_high"
    midpt_col = f"{var_prefix}_midpt"
    
    return df.with_columns([
        # Range width
        (pl.col(high_col) - pl.col(low_col)).alias(f"{var_prefix}_range_width"),
        
        # Is exact (range width = 0)?
        (pl.col(high_col) == pl.col(low_col)).alias(f"{var_prefix}_is_exact"),
        
        # Relative uncertainty
        pl.when(pl.col(midpt_col) > 0)
        .then((pl.col(high_col) - pl.col(low_col)) / pl.col(midpt_col) * 100)
        .otherwise(None)
        .alias(f"{var_prefix}_relative_uncertainty")
    ])
```

## EDFacts Data in the Portal

### Fetching EDFacts Data

EDFacts data is fetched via the mirror-based bulk download system. See `fetch-patterns.md` for the `fetch_yearly_from_mirrors()` function.

```python
import polars as pl

# School-level assessments (yearly dataset)
df = fetch_yearly_from_mirrors(
    path_template="edfacts/schools_edfacts_assessments_{year}",
    years=[2017, 2018],
)

# Filter to California, grade 4
ca_grade4 = df.filter(
    (pl.col("fips") == 6) & (pl.col("grade_edfacts") == 4)
)

# School-level graduation rates (yearly dataset)
grad_df = fetch_yearly_from_mirrors(
    path_template="edfacts/schools_edfacts_grad_rates_{year}",
    years=[2018, 2019],
)
```

### Codebook Authority

> **Truth Hierarchy:** This file summarizes variable definitions for convenience. When this file contradicts observed data or the live codebook, trust the higher-priority source. See the Truth Hierarchy in SKILL.md.
>
> Assessment codebooks: `get_codebook_url("edfacts/codebook_schools_edfacts_assessments")`
>
> Graduation rate codebooks: `get_codebook_url("edfacts/codebook_schools_edfacts_graduation")`

### Available EDFacts Datasets

| Level | Dataset | Path Pattern |
|-------|---------|-------------|
| Schools | Assessments | `edfacts/schools_edfacts_assessments_{year}` |
| Schools | Grad Rates | `edfacts/schools_edfacts_grad_rates_{year}` |
| Districts | Assessments | `edfacts/districts_edfacts_assessments_{year}` |
| Districts | Grad Rates | `edfacts/districts_edfacts_grad_rates_{year}` |

## Best Practices Summary

### Do

- Use `_midpt` variables for analysis
- Filter out missing values appropriately
- Document suppression rates
- Consider range width in interpretation
- Use test counts for weighting

### Don't

- Treat `-3` as 0% or ignore it
- Compare exact values to midpoints
- Assume missing means zero
- Ignore range uncertainty
- Use `_low` or `_high` alone for analysis
