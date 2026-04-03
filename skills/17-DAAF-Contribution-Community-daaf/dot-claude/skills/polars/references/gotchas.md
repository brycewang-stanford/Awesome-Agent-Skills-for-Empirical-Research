# Gotchas & Common Issues

Common mistakes, error patterns, and troubleshooting for Polars.

## Contents

- [Type Errors](#type-errors)
- [Null Handling](#null-handling)
- [Expression Context Errors](#expression-context-errors)
- [Performance Anti-Patterns](#performance-anti-patterns)
- [Migration from Pandas](#migration-from-pandas)
- [Memory Issues](#memory-issues)

> See also: `qcut()` label format surprise under [Type Errors](#type-errors).

## Type Errors

### "Expected X, got Y" in Expressions

**Problem:** Type mismatch in operations.

```python
# Error: cannot compare String to Int
df.filter(pl.col("id") == "123")  # id is Int64
```

**Fix:** Cast to correct type or use correct literal:

```python
df.filter(pl.col("id") == 123)           # Use int literal
df.filter(pl.col("id") == pl.lit("123").cast(pl.Int64))  # Or cast
```

### Arithmetic on Wrong Types

**Problem:** Operations between incompatible types.

```python
# Error: cannot add String and Int
df.with_columns(pl.col("a") + pl.col("b"))  # a is String
```

**Fix:** Cast before operations:

```python
df.with_columns(
    (pl.col("a").cast(pl.Int64) + pl.col("b")).alias("sum")
)
```

## Null Handling

### Nulls in Comparisons

**Problem:** Nulls don't equal anything, including themselves.

```python
# This does NOT find nulls
df.filter(pl.col("x") == None)  # Wrong
```

**Fix:** Use `is_null()` or `is_not_null()`:

```python
df.filter(pl.col("x").is_null())
df.filter(pl.col("x").is_not_null())
```

### Nulls in Aggregations

**Problem:** Aggregations skip nulls by default.

```python
# sum() ignores nulls, may give unexpected count
df.select(pl.col("x").sum())
```

**Fix:** Handle nulls explicitly if needed:

```python
df.select(
    pl.col("x").fill_null(0).sum(),        # Replace nulls
    pl.col("x").drop_nulls().count(),       # Count non-nulls
    pl.col("x").null_count()                # Count nulls
)
```

### Nulls in String Operations

**Problem:** String operations propagate nulls.

```python
# If "name" has nulls, result has nulls
df.with_columns(pl.col("name").str.to_uppercase())
```

**Fix:** Fill nulls before or after:

```python
df.with_columns(
    pl.col("name").fill_null("").str.to_uppercase()
)
```

## Expression Context Errors

### Using Expressions Outside Context

**Problem:** Expressions need a context (select, filter, with_columns).

```python
# Error: expressions must be used in a context
result = pl.col("a") + pl.col("b")  # Wrong
```

**Fix:** Use within a DataFrame context:

```python
result = df.select(pl.col("a") + pl.col("b"))
```

### Column Not Found

**Problem:** Referencing non-existent column.

```python
# Error: column "foo" not found
df.select("foo")  # Column doesn't exist
```

**Fix:** Check column names:

```python
print(df.columns)  # List columns
df.select(pl.col("^foo.*$"))  # Regex if unsure of exact name
```

### Aliasing Required in Aggregations

**Problem:** Multiple aggregations on same column need aliases.

```python
# Error: duplicate column name
df.group_by("cat").agg(
    pl.col("val").sum(),
    pl.col("val").mean()  # Same output name "val"
)
```

**Fix:** Use `.alias()`:

```python
df.group_by("cat").agg(
    pl.col("val").sum().alias("total"),
    pl.col("val").mean().alias("average")
)
```

### `qcut()` Labels Get Unexpected Suffixes

**Problem:** `pl.Series.qcut()` and `pl.Expr.qcut()` with custom labels append
descriptive suffixes to the first and last labels when `include_breaks=False`
(the default).

```python
# Requesting labels ["Q1", "Q2", "Q3", "Q4", "Q5"] with 5 quantiles
# produces: "Q1 (Lowest)", "Q2", "Q3", "Q4", "Q5 (Highest)"
s = pl.Series("val", range(100))
result = s.qcut(5, labels=["Q1", "Q2", "Q3", "Q4", "Q5"])
print(result.unique())  # Shows "Q1 (Lowest)" and "Q5 (Highest)"
```

This causes failures when downstream code uses exact string matching:

```python
# WRONG: no rows match because actual label is "Q1 (Lowest)"
df.filter(pl.col("quintile") == "Q1")

# CORRECT: use starts_with or contains
df.filter(pl.col("quintile").str.starts_with("Q1"))
df.filter(pl.col("quintile").str.contains("Q1"))
```

**Best practice:** Always inspect `value_counts()` on `qcut` output before
building downstream logic on label values:

```python
df = df.with_columns(
    pl.col("score").qcut(5, labels=["Q1", "Q2", "Q3", "Q4", "Q5"]).alias("quintile")
)
print(df["quintile"].value_counts())  # Inspect actual label values
```

## Performance Anti-Patterns

### Row-by-Row Iteration

**Problem:** Using Python loops destroys performance.

```python
# Very slow - don't do this
results = []
for row in df.iter_rows():
    results.append(process(row))
```

**Fix:** Use expressions or `map_elements` as last resort:

```python
# Preferred: use expressions
df.with_columns(
    (pl.col("a") * 2 + pl.col("b")).alias("result")
)

# Last resort: map_elements (still slow)
df.with_columns(
    pl.col("a").map_elements(process, return_dtype=pl.Int64)
)
```

### Using `.apply()` (Deprecated)

**Problem:** `.apply()` was renamed in Polars 0.19+.

```python
# Deprecated/removed
df.select(pl.col("a").apply(lambda x: x * 2))
```

**Fix:** Use `map_elements` or preferably native expressions:

```python
# Preferred: native expression
df.select(pl.col("a") * 2)

# If custom function needed
df.select(pl.col("a").map_elements(func, return_dtype=pl.Int64))
```

### Collecting Too Early

**Problem:** Calling `.collect()` breaks optimization.

```python
# Bad: collects early, loses optimization
df1 = lf.filter(pl.col("a") > 10).collect()
df2 = df1.lazy().filter(pl.col("b") < 5).collect()
```

**Fix:** Chain lazy operations, collect once:

```python
# Good: single optimized query
df = (
    lf.filter(pl.col("a") > 10)
      .filter(pl.col("b") < 5)
      .collect()
)
```

### Not Using Lazy Mode for Large Data

**Problem:** Eager mode loads everything into memory.

```python
# May run out of memory on large files
df = pl.read_csv("huge_file.csv")
```

**Fix:** Use lazy/scan for large data:

```python
# Streaming, memory efficient
lf = pl.scan_csv("huge_file.csv")
result = lf.filter(...).select(...).collect()
```

## Migration from Pandas

### `groupby` → `group_by`

```python
# Pandas style (wrong in Polars 0.19+)
df.groupby("col")

# Polars style
df.group_by("col")
```

### `melt` → `unpivot`

```python
# Old (Polars <1.0)
df.melt(id_vars=["id"], value_vars=["a", "b"])

# New (Polars 1.0+)
df.unpivot(on=["a", "b"], index=["id"])
```

### Index-Based Access

**Problem:** Polars has no index like Pandas.

```python
# Pandas style (doesn't work)
df.loc[0]
df.iloc[0:5]
```

**Fix:** Use Polars row access methods:

```python
df.head(5)           # First 5 rows
df.tail(5)           # Last 5 rows
df.slice(0, 5)       # Rows 0-4
df.row(0)            # Single row as tuple
df.row(0, named=True)  # First row as dict
```

### Chained Assignment

**Problem:** Pandas-style chained assignment doesn't work.

```python
# Pandas style (doesn't work)
df["new_col"] = df["a"] * 2
```

**Fix:** Use `with_columns`:

```python
df = df.with_columns(
    (pl.col("a") * 2).alias("new_col")
)
```

## Memory Issues

### Out of Memory on Large Files

**Problem:** File too large for available RAM.

**Fix:** Use streaming/lazy mode:

```python
# Streaming read
lf = pl.scan_csv("huge.csv")

# Process in batches
result = (
    lf.filter(...)
      .group_by(...)
      .agg(...)
      .collect(streaming=True)  # Enable streaming engine
)
```

### Memory Not Released

**Problem:** DataFrames not garbage collected.

**Fix:** Delete references explicitly:

```python
del df
import gc
gc.collect()
```

### String Columns Using Too Much Memory

**Problem:** Repeated strings waste memory.

**Fix:** Use Categorical for low-cardinality strings:

```python
df = df.with_columns(
    pl.col("category").cast(pl.Categorical)
)
```

## Quick Fixes

| Problem | Quick Fix |
|---------|-----------|
| Type mismatch | `.cast(pl.TargetType)` |
| Null check | `.is_null()` / `.is_not_null()` |
| Duplicate column name | `.alias("unique_name")` |
| Column not found | Check `df.columns` |
| Slow iteration | Use expressions instead |
| Memory error | Use `scan_*` + lazy mode |
| Pandas conversion | `df.to_pandas()` / `pl.from_pandas(pdf)` |
| groupby error | Use `group_by` (underscore) |
| melt error | Use `unpivot` (Polars 1.0+) |
