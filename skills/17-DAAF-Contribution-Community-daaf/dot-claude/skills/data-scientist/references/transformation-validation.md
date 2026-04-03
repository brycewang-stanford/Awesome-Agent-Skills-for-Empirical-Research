# Transformation Validation

Patterns and techniques for validating data transformations. NEVER assume a transformation worked correctly.

## Contents

- [Before/After Validation Pattern](#beforeafter-validation-pattern)
- [Row Count Validation](#row-count-validation)
- [Join Validation](#join-validation)
- [Aggregation Validation](#aggregation-validation)
- [Sample-Based Verification](#sample-based-verification)
- [Schema Validation (Keep It Simple)](#schema-validation-keep-it-simple)
- [Common Errors and Detection](#common-errors-and-detection)

## Before/After Validation Pattern

**Every transformation should follow this pattern:**

```python
import polars as pl

# ============================================================
# STEP 1: Document pre-transformation state
# ============================================================
pre_shape = df.shape
pre_columns = df.columns.copy()
pre_sample = df.sample(10, seed=42)  # Reproducible sample

# Record relevant aggregates for validation
pre_row_count = len(df)
pre_null_counts = {col: df[col].null_count().item() for col in df.columns}

# For aggregations, record sums of additive metrics
pre_total = df.select(pl.col("amount").sum()).item() if "amount" in df.columns else None

# ============================================================
# STEP 2: Perform transformation (with comments)
# ============================================================
# GOAL: [State what you're trying to accomplish]
# EXPECTED: [State expected changes - row count, columns, etc.]
# INVARIANTS: [State what should NOT change]

result = df.filter(pl.col("status") == "active")

# ============================================================
# STEP 3: Validate post-transformation state
# ============================================================
post_shape = result.shape
post_columns = result.columns

# Basic shape validation
print(f"Shape change: {pre_shape} -> {post_shape}")
print(f"Row change: {pre_row_count} -> {len(result)} ({len(result) - pre_row_count:+d})")
print(f"Column change: {len(pre_columns)} -> {len(post_columns)}")

# Verify columns preserved/changed as expected
added_cols = set(post_columns) - set(pre_columns)
removed_cols = set(pre_columns) - set(post_columns)
if added_cols:
    print(f"Columns added: {added_cols}")
if removed_cols:
    print(f"Columns removed: {removed_cols}")

# Sample comparison
sample_ids = pre_sample["id"].to_list()[:5]
print(f"\nSample before:\n{pre_sample.filter(pl.col('id').is_in(sample_ids))}")
print(f"\nSample after (if present):\n{result.filter(pl.col('id').is_in(sample_ids))}")
```

## Row Count Validation

Different operations have different expected row count behaviors:

| Operation | Expected Row Count Change |
|-----------|---------------------------|
| Filter | Decrease (or stay same if no matches filtered) |
| Select | Same |
| With_columns | Same |
| Join (inner) | Usually decrease; ≤ min(left, right) |
| Join (left) | ≥ left count (can increase if many-to-many) |
| Join (outer) | ≥ max(left, right) |
| Group_by.agg | = number of unique groups |
| Concat (vertical) | = sum of input row counts |
| Unique/Distinct | ≤ original count |
| Explode | ≥ original count |

### Validation Pattern

```python
# Validate row count change
change = post_count - pre_count
pct_change = (change / pre_count * 100) if pre_count > 0 else 0
print(f"Row count: {pre_count:,} → {post_count:,} ({change:+,}, {pct_change:+.1f}%)")
if expected_change == "decrease" and change > 0:
    print("WARNING: Expected decrease but rows increased!")
```

## Join Validation

Joins are a common source of subtle bugs. Always validate.

### Pre-Join Checks

```python
# Pre-join checks
for key in join_keys:
    left_type = left_df[key].dtype
    right_type = right_df[key].dtype
    if left_type != right_type:
        print(f"WARNING: Type mismatch for '{key}': {left_type} vs {right_type}")

    left_unique = left_df[key].n_unique()
    right_unique = right_df[key].n_unique()
    left_nulls = left_df[key].null_count()
    right_nulls = right_df[key].null_count()
    print(f"Key '{key}': left={left_unique:,} unique ({left_nulls} nulls), right={right_unique:,} unique ({right_nulls} nulls)")

left_keys_set = set(left_df[join_keys[0]].unique().to_list())
right_keys_set = set(right_df[join_keys[0]].unique().to_list())
overlap = len(left_keys_set & right_keys_set)
print(f"Key overlap: {overlap:,} ({overlap/len(left_keys_set):.1%} of left, {overlap/len(right_keys_set):.1%} of right)")
```

### Post-Join Validation

```python
# Post-join validation
left_count = len(left_df)
right_count = len(right_df)
result_count = len(result_df)
print(f"Post-join shape: {result_df.shape}")
print(f"Left: {left_count:,}, Right: {right_count:,}, Result: {result_count:,}")

if result_count > max(left_count, right_count):
    print(f"WARNING: Result has more rows than either input — possible many-to-many duplication!")

# For left joins, verify all left keys are present
if join_type == "left":
    left_keys_set = set(left_df[join_keys[0]].unique().to_list())
    result_keys_set = set(result_df[join_keys[0]].unique().to_list())
    missing = left_keys_set - result_keys_set
    if missing:
        print(f"WARNING: {len(missing)} left keys missing from result!")

# Check for new nulls introduced by the join
result_nulls = result_df.null_count()
print(f"Result null counts:\n{result_nulls}")
```

### Using Join Indicators

```python
# Join with match indicator (Polars doesn't have pandas-style indicator)
right_with_marker = right_df.with_columns(pl.lit(True).alias("_right_matched"))
result = left_df.join(right_with_marker, on=on, how="left")
result = result.with_columns(pl.col("_right_matched").fill_null(False))

matched = result.filter(pl.col("_right_matched")).height
unmatched = result.filter(~pl.col("_right_matched")).height
print(f"Matched: {matched:,}, Unmatched: {unmatched:,}")
```

## Aggregation Validation

### Sum Conservation

For additive metrics, the total should be preserved (or explainably different).

```python
# Validate aggregation preserves sum
pre_sum = pre_df[sum_column].sum()
post_sum = post_df[sum_column].sum()
diff = abs(pre_sum - post_sum)
print(f"Sum of '{sum_column}': {pre_sum:,.2f} → {post_sum:,.2f} (diff: {diff:,.2f})")
assert diff < 1e-6, f"STOP: Sum changed during aggregation by {diff}"
```

### Group Count Validation

```python
# Validate group counts
expected_groups = pre_df.select(group_columns).n_unique()
actual_groups = len(post_df)
print(f"Group count: expected {expected_groups:,} unique combinations, got {actual_groups:,} rows")
assert expected_groups == actual_groups, f"STOP: Group count mismatch ({expected_groups} vs {actual_groups})"
```

### Row Accounting

```python
# Validate row accounting — all rows accounted for in aggregation
pre_count = len(pre_df)
group_sizes = pre_df.group_by(group_columns).len()
total_accounted = group_sizes["len"].sum()
print(f"Row accounting: {pre_count:,} original rows, {total_accounted:,} accounted for in groups")
assert pre_count == total_accounted, f"STOP: {pre_count - total_accounted} rows unaccounted for!"
```

## Sample-Based Verification

Manual spot-checking catches errors that automated checks miss.

### Selecting Representative Samples

```python
# Select a diverse verification sample
random_sample = df.sample(5, seed=42)
edge_sample = pl.concat([df.head(2), df.tail(2)])
null_cols = [col for col in df.columns if df[col].null_count() > 0]
null_sample = df.filter(pl.col(null_cols[0]).is_null()).head(2) if null_cols else pl.DataFrame()
sample = pl.concat([random_sample, edge_sample, null_sample]).unique().head(10)
print(f"Verification sample: {len(sample)} rows")
print(sample)
```

### Manual Verification Template

```python
# Template for manual verification
print("=== Manual Verification ===")
print("For each sample row, verify:")
print("1. Input values are as expected")
print("2. Transformation logic was applied correctly")
print("3. Output values are correct")
print()

sample = select_verification_sample(pre_df, n=5)
sample_ids = sample["id"].to_list()

print("BEFORE transformation:")
print(pre_df.filter(pl.col("id").is_in(sample_ids)))

print("\nAFTER transformation:")
print(result.filter(pl.col("id").is_in(sample_ids)))

print("\nManual check: Do the transformations look correct? (Y/N)")
```

### Schema Validation (Keep It Simple)

For one-and-done scripts, validate schemas inline:

```python
# Check required columns exist
required = ["id", "amount", "category"]
missing = [c for c in required if c not in df.columns]
assert not missing, f"Missing columns: {missing}"

# Check types
assert df["id"].dtype == pl.Int64, f"Expected Int64, got {df['id'].dtype}"
```

## Common Errors and Detection

### Silent Type Coercion

```python
# Problem: Type conversion can silently create nulls or lose precision
pre_null_count = df["column"].null_count().item()

# This might silently fail
df = df.with_columns(pl.col("column").cast(pl.Int64))

post_null_count = df["column"].null_count().item()
new_nulls = post_null_count - pre_null_count

if new_nulls > 0:
    print(f"WARNING: Type coercion created {new_nulls} new null values!")
```

### Filter Returning Empty

```python
# Problem: Filter conditions might match nothing
result = df.filter(pl.col("status") == "active")

if len(result) == 0:
    print("WARNING: Filter returned no rows!")
    print("Check if filter condition is correct.")
    print(f"Unique values in 'status': {df['status'].unique().to_list()}")
```

### Join Key Type Mismatch

```python
# Check join key types match (type mismatches cause silent join failures)
for key in join_keys:
    left_type = left_df[key].dtype
    right_type = right_df[key].dtype
    if left_type != right_type:
        print(f"WARNING: Type mismatch for '{key}': {left_type} vs {right_type} — join may fail silently!")
```

### Off-by-One in Group Operations

```python
# Problem: Groupby excludes null keys by default in some operations
null_key_rows = df.filter(pl.col("group_key").is_null())
if len(null_key_rows) > 0:
    print(f"WARNING: {len(null_key_rows)} rows have null group keys")
    print("These may be excluded from groupby operations!")
```

### Accidental Column Overwrite

```python
# Problem: with_columns can silently overwrite existing columns
existing_cols = set(df.columns)
new_col_names = ["calculated_value", "status"]  # Ops we're adding

overlap = existing_cols & set(new_col_names)
if overlap:
    print(f"WARNING: These columns will be overwritten: {overlap}")
    print("Is this intentional?")
```

## Validation Checklist

Use this checklist for ANY transformation:

### Before

- [ ] Documented pre-transformation shape
- [ ] Saved reproducible sample for comparison
- [ ] Recorded relevant aggregates (sums, counts)
- [ ] Stated what SHOULD change
- [ ] Stated what should NOT change
- [ ] Checked input data types match expectations

### After

- [ ] Verified shape change matches expectations
- [ ] Compared sample records before/after
- [ ] Validated invariants (sums preserved, etc.)
- [ ] Checked for unintended new nulls
- [ ] Checked for unintended duplicates
- [ ] Verified column types in output
- [ ] Documented what was validated and results
