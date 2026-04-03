# Validation Patterns for Data Analysis

This reference provides patterns for rigorous, step-by-step validation in marimo notebooks for data science workflows.

## Core Principle: Transform-Validate Pairs

**Every transformation cell MUST be followed by a validation cell.** This ensures:
- Immediate detection of unexpected behavior
- Clear audit trail of changes
- Prevents error accumulation
- Enables checkpoint-based recovery

## Pattern 1: Basic Transform-Validate Pair

### Cell N: Transform
```python
import marimo as mo
import polars as pl

mo.md("## Transform: Filter to high schools")

# Capture pre-state
pre_shape = df.shape
pre_sample_ids = df.select("ncessch").sample(5, seed=42).to_series().to_list()
pre_sample = df.filter(pl.col("ncessch").is_in(pre_sample_ids))

# Execute transformation
df_filtered = df.filter(pl.col("school_level") == 3)
```

### Cell N+1: Validate (REQUIRED)
```python
mo.md("## Validation: Filter to high schools")

# Capture post-state
post_shape = df_filtered.shape
post_sample = df_filtered.filter(pl.col("ncessch").is_in(pre_sample_ids))

# Calculate metrics
row_retention = (post_shape[0] / pre_shape[0]) * 100 if pre_shape[0] > 0 else 0
col_retention = (post_shape[1] / pre_shape[1]) * 100 if pre_shape[1] > 0 else 0

# Check invariants
all_high_schools = (df_filtered["school_level"] == 3).all()

# Report
validation_report = mo.md(f"""
**Transformation:** Filter to high schools (school_level == 3)

**Pre-state:** {pre_shape[0]:,} rows × {pre_shape[1]} cols  
**Post-state:** {post_shape[0]:,} rows × {post_shape[1]} cols  
**Row retention:** {row_retention:.1f}%  
**Column retention:** {col_retention:.1f}%

**Sample comparison:**
```
Before: {pre_sample.shape[0]} records
After: {post_sample.shape[0]} records
```

**Invariant checks:**
- All rows have school_level == 3: {all_high_schools} {'✅' if all_high_schools else '❌'}

{'✅ **Validation PASSED**' if all_high_schools else '❌ **Validation FAILED**'}
""")

# Gate: Stop execution if validation fails
mo.stop(
    not all_high_schools,
    mo.md("🛑 **STOP:** Validation failed. Non-high-school records found after filter.")
)

validation_report
```

## Pattern 2: Multi-Condition Filter Validation

### Cell N: Transform
```python
mo.md("## Transform: Filter to California public high schools in 2020")

# Pre-state
pre_shape = df.shape
pre_states = df.select("fips").unique().to_series().to_list()
pre_years = df.select("year").unique().to_series().to_list()

# Transform
df_filtered = df.filter(
    (pl.col("fips") == 6) &  # California
    (pl.col("year") == 2020) &
    (pl.col("school_level") == 3)  # High school
)
```

### Cell N+1: Validate
```python
mo.md("## Validation: Multi-condition filter")

# Post-state
post_states = df_filtered.select("fips").unique().to_series().to_list()
post_years = df_filtered.select("year").unique().to_series().to_list()
post_levels = df_filtered.select("school_level").unique().to_series().to_list()

# Invariant checks
correct_state = post_states == [6]
correct_year = post_years == [2020]
correct_level = post_levels == [3]

all_checks_pass = correct_state and correct_year and correct_level

mo.md(f"""
**Transformation:** Filter to CA public high schools in 2020

**Row change:** {pre_shape[0]:,} → {df_filtered.shape[0]:,} ({df_filtered.shape[0]/pre_shape[0]*100:.1f}% retained)

**Unique values check:**
- States: {pre_states[:5]}... → {post_states} {'✅' if correct_state else '❌'}
- Years: {pre_years} → {post_years} {'✅' if correct_year else '❌'}
- Levels: {post_levels} {'✅' if correct_level else '❌'}

{'✅ **Validation PASSED**' if all_checks_pass else '❌ **Validation FAILED**'}
""")

mo.stop(
    not all_checks_pass,
    mo.md("🛑 **STOP:** Filter validation failed. Check unique values above.")
)
```

## Pattern 3: Join Validation

### Cell N: Transform (Join)
```python
mo.md("## Transform: Join schools with MEPS poverty data")

# Pre-state
pre_left_shape = df_schools.shape
pre_right_shape = df_meps.shape
pre_left_ids = set(df_schools["ncessch"].unique().to_list())
pre_right_ids = set(df_meps["ncessch"].unique().to_list())

# Transform
df_joined = df_schools.join(df_meps, on="ncessch", how="left")
```

### Cell N+1: Validate
```python
mo.md("## Validation: Join")

# Post-state
post_shape = df_joined.shape
post_ids = set(df_joined["ncessch"].unique().to_list())

# Join metrics
expected_rows = pre_left_shape[0]  # Left join preserves left rows
actual_rows = post_shape[0]
row_duplication = actual_rows / expected_rows if expected_rows > 0 else 0

# Check for unexpected duplication
no_unexpected_duplication = row_duplication <= 1.01  # Allow 1% margin

# Check ID preservation
ids_preserved = pre_left_ids == post_ids

# Check for new missing values
pre_null_count = df_schools.null_count().sum_horizontal()[0]
post_null_count = df_joined.select(df_schools.columns).null_count().sum_horizontal()[0]
nulls_preserved = pre_null_count == post_null_count

mo.md(f"""
**Transformation:** Left join schools with MEPS data

**Row counts:**
- Left (schools): {pre_left_shape[0]:,}
- Right (MEPS): {pre_right_shape[0]:,}
- Result: {post_shape[0]:,}
- Duplication ratio: {row_duplication:.2f} {'✅' if no_unexpected_duplication else '❌ WARNING'}

**ID preservation:**
- IDs preserved: {ids_preserved} {'✅' if ids_preserved else '❌'}
- Missing from result: {len(pre_left_ids - post_ids)}
- Added to result: {len(post_ids - pre_left_ids)}

**Null counts (original columns only):**
- Before: {pre_null_count:,}
- After: {post_null_count:,}
- Preserved: {nulls_preserved} {'✅' if nulls_preserved else '❌'}

**Match rate:** {len(pre_left_ids & pre_right_ids) / len(pre_left_ids) * 100:.1f}% of schools matched
""")

mo.stop(
    not (no_unexpected_duplication and ids_preserved),
    mo.md("🛑 **STOP:** Join validation failed. Check for duplicate keys or ID loss.")
)
```

## Pattern 4: Aggregation Validation

### Cell N: Transform (Aggregation)
```python
mo.md("## Transform: Aggregate enrollment by state")

# Pre-state
pre_total_enrollment = df.select(pl.col("enrollment").sum())[0, 0]
pre_row_count = df.shape[0]
pre_states = df.select("fips").n_unique()

# Transform
df_agg = df.group_by("fips").agg([
    pl.col("enrollment").sum().alias("total_enrollment"),
    pl.len().alias("school_count")
])
```

### Cell N+1: Validate
```python
mo.md("## Validation: Aggregation")

# Post-state
post_total_enrollment = df_agg.select(pl.col("total_enrollment").sum())[0, 0]
post_row_count = df_agg.shape[0]

# Invariant checks
enrollment_preserved = abs(pre_total_enrollment - post_total_enrollment) < 0.01  # Float precision
correct_state_count = post_row_count == pre_states
row_count_decreased = post_row_count < pre_row_count

all_checks = enrollment_preserved and correct_state_count and row_count_decreased

mo.md(f"""
**Transformation:** Aggregate by state (fips)

**Row count change:** {pre_row_count:,} → {post_row_count:,} {'✅' if row_count_decreased else '❌'}

**Enrollment totals:**
- Before: {pre_total_enrollment:,.0f}
- After: {post_total_enrollment:,.0f}
- Difference: {abs(pre_total_enrollment - post_total_enrollment):,.0f}
- Preserved: {enrollment_preserved} {'✅' if enrollment_preserved else '❌'}

**State count:**
- Expected: {pre_states}
- Actual: {post_row_count}
- Match: {correct_state_count} {'✅' if correct_state_count else '❌'}

{'✅ **Validation PASSED**' if all_checks else '❌ **Validation FAILED**'}
""")

mo.stop(
    not all_checks,
    mo.md("🛑 **STOP:** Aggregation validation failed. Check invariants above.")
)
```

## Pattern 5: Column Transformation Validation

### Cell N: Transform (Create derived column)
```python
mo.md("## Transform: Calculate students per teacher ratio")

# Pre-state
pre_shape = df.shape
pre_sample_ids = df.select("ncessch").sample(5, seed=42).to_series().to_list()
pre_sample = df.filter(pl.col("ncessch").is_in(pre_sample_ids)).select(["ncessch", "students", "teachers"])

# Transform
df_with_ratio = df.with_columns(
    (pl.col("students") / pl.col("teachers")).alias("student_teacher_ratio")
)
```

### Cell N+1: Validate
```python
mo.md("## Validation: Derived column")

# Post-state
post_sample = df_with_ratio.filter(pl.col("ncessch").is_in(pre_sample_ids)).select(["ncessch", "students", "teachers", "student_teacher_ratio"])

# Invariant checks
shape_preserved = df_with_ratio.shape[0] == pre_shape[0]
col_count_increased = df_with_ratio.shape[1] == pre_shape[1] + 1
new_col_exists = "student_teacher_ratio" in df_with_ratio.columns

# Manual calculation check on sample
manual_check = (
    post_sample.with_columns(
        (pl.col("students") / pl.col("teachers")).alias("manual_ratio")
    )
    .select(
        ((pl.col("student_teacher_ratio") - pl.col("manual_ratio")).abs() < 0.01).all()
    )[0, 0]
)

all_checks = shape_preserved and col_count_increased and new_col_exists and manual_check

mo.md(f"""
**Transformation:** Add student_teacher_ratio column

**Shape changes:**
- Rows: {pre_shape[0]:,} → {df_with_ratio.shape[0]:,} {'✅' if shape_preserved else '❌'}
- Columns: {pre_shape[1]} → {df_with_ratio.shape[1]} {'✅' if col_count_increased else '❌'}

**New column:** {new_col_exists} {'✅' if new_col_exists else '❌'}

**Sample verification:**
```
{post_sample}
```

**Manual calculation check:** {manual_check} {'✅' if manual_check else '❌'}

{'✅ **Validation PASSED**' if all_checks else '❌ **Validation FAILED**'}
""")

mo.stop(
    not all_checks,
    mo.md("🛑 **STOP:** Derived column validation failed.")
)
```

## Pattern 6: Validation State Tracker

For complex notebooks with many transformations, track validation state:

### Cell: Initialize Tracker
```python
import marimo as mo

mo.md("## Validation Tracker")

# Track which validations have passed
validation_log = {
    "fetch_validated": False,
    "coded_values_filtered": False,
    "state_filter_validated": False,
    "join_validated": False,
    "aggregation_validated": False
}
```

### After Each Validation Cell
```python
# At end of validation cell, update tracker
validation_log["state_filter_validated"] = True
validation_log
```

### Final Check Cell
```python
mo.md("## Overall Validation Status")

incomplete = [k for k, v in validation_log.items() if not v]

if incomplete:
    mo.md(f"""
    ⚠️ **Incomplete validations:**
    {chr(10).join(f'- {item}' for item in incomplete)}
    """)
else:
    mo.md("✅ **All validations complete**")

mo.stop(
    len(incomplete) > 0,
    mo.md("🛑 **STOP:** Complete all validations before proceeding to analysis.")
)
```

## Anti-Patterns (DO NOT DO)

### ❌ Bad: Multiple Transforms Without Validation
```python
# DON'T DO THIS
df = df.filter(pl.col("state") == "CA")
df = df.with_columns((pl.col("a") * 2).alias("b"))
df = df.join(other_df, on="id")
df = df.group_by("category").agg(pl.sum("value"))
# No validation until the end - errors accumulate!
```

### ❌ Bad: Validation Without mo.stop()
```python
# DON'T DO THIS
mo.md(f"Rows: {df.shape[0]}")  # Just showing the number
# No check if the number is reasonable
# Notebook continues even if something is wrong
```

### ❌ Bad: No Pre-State Capture
```python
# DON'T DO THIS
df_filtered = df.filter(pl.col("year") == 2020)
# Can't compare before/after without pre-state
```

### ✅ Good: One Transform, One Validation
```python
# Transform
pre_shape = df.shape
df_filtered = df.filter(pl.col("year") == 2020)

# Validate immediately in next cell
post_shape = df_filtered.shape
mo.md(f"Pre: {pre_shape}, Post: {post_shape}")
mo.stop(post_shape[0] == 0, "Empty result!")
```

## Integration with Checkpoints

These patterns implement the 4 validation checkpoints from the full pipeline workflow:

| Checkpoint | Pattern | When |
|------------|---------|------|
| **CP1: Post-Fetch** | Basic Transform-Validate | After API data retrieval |
| **CP2: Post-Cleaning** | Multi-Condition Filter | After removing coded values |
| **CP3: Post-Transformation** | Join/Aggregation patterns | After each transform |
| **CP4: Pre-Output** | Validation State Tracker | Before final output — covers both Stage 8.1 analysis results and Stage 8.2 visualization outputs |

## Best Practices Summary

1. **Always pair:** Transform cell → Validation cell
2. **Always capture:** Pre-state before transforming
3. **Always compare:** Pre vs. post metrics
4. **Always check:** Invariants that should be preserved
5. **Always stop:** Use `mo.stop()` if validation fails
6. **Always report:** Clear markdown with metrics and emoji status
7. **Never batch:** Max 1-2 operations per transform cell

## Example: Complete Transform-Validate Sequence

```python
# Cell 1: Load data
df = pl.read_parquet("data.parquet")
mo.md(f"Loaded {df.shape[0]:,} rows")

# Cell 2: Transform - Filter year
pre_shape = df.shape
df_2020 = df.filter(pl.col("year") == 2020)

# Cell 3: Validate - Filter year
post_shape = df_2020.shape
year_check = df_2020["year"].unique().to_list() == [2020]
mo.md(f"Rows: {pre_shape[0]:,} → {post_shape[0]:,}, Year correct: {year_check} {'✅' if year_check else '❌'}")
mo.stop(not year_check, "Year validation failed")

# Cell 4: Transform - Filter state
pre_shape = df_2020.shape
df_ca = df_2020.filter(pl.col("fips") == 6)

# Cell 5: Validate - Filter state
post_shape = df_ca.shape
state_check = df_ca["fips"].unique().to_list() == [6]
mo.md(f"Rows: {pre_shape[0]:,} → {post_shape[0]:,}, State correct: {state_check} {'✅' if state_check else '❌'}")
mo.stop(not state_check, "State validation failed")

# Cell 6: Analysis (only after validations pass)
result = df_ca.group_by("district").agg(pl.sum("enrollment"))
mo.ui.table(result)
```

Each transformation is discrete, validated, and gates the next step.
