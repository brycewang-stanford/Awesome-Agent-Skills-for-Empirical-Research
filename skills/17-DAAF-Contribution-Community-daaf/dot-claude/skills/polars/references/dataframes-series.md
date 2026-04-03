# DataFrames & Series

## DataFrame Creation

### From Dictionary

```python
df = pl.DataFrame({
    "name": ["Alice", "Bob", "Charlie"],
    "age": [25, 30, 35],
    "active": [True, False, True]
})
```

### With Schema Control

```python
df = pl.DataFrame(
    {"id": [1, 2], "value": [10.5, 20.3]},
    schema={"id": pl.Int32, "value": pl.Float32}
)

# Override inferred types
df = pl.DataFrame(
    {"a": [1, 2, 3]},
    schema_overrides={"a": pl.Int16}
)
```

### From Rows (List of Dicts)

```python
df = pl.DataFrame([
    {"name": "Alice", "age": 25},
    {"name": "Bob", "age": 30}
])
```

### From NumPy/Sequences

```python
import numpy as np

df = pl.DataFrame({
    "a": np.array([1, 2, 3]),
    "b": range(3),
    "c": [1.0, 2.0, 3.0]
})
```

## Series Creation

```python
# From list
s = pl.Series("name", [1, 2, 3])

# With explicit type
s = pl.Series("name", [1, 2, 3], dtype=pl.Float64)

# From range
s = pl.Series("nums", range(10))
```

## Column Selection

### By Name

```python
# Single column (returns Series)
df["name"]
df.get_column("name")

# Multiple columns (returns DataFrame)
df.select("name", "age")
df.select(["name", "age"])
df.select(pl.col("name"), pl.col("age"))
```

### All Columns / Exclude

```python
df.select(pl.all())                    # All columns
df.select(pl.all().exclude("id"))      # All except "id"
df.select(pl.exclude("id", "temp"))    # Exclude multiple
```

### By Pattern (Regex)

```python
# Columns starting with "col_"
df.select(pl.col("^col_.*$"))

# Columns ending with "_id"
df.select(pl.col("^.*_id$"))

# Columns containing "price"
df.select(pl.col("^.*price.*$"))
```

### By Data Type (Selectors)

```python
import polars.selectors as cs

df.select(cs.numeric())          # All numeric columns
df.select(cs.string())           # All string columns
df.select(cs.temporal())         # Date/datetime/time/duration
df.select(cs.boolean())          # Boolean columns
df.select(cs.categorical())      # Categorical columns

# Combine selectors
df.select(cs.numeric() | cs.string())    # OR
df.select(cs.numeric() & ~cs.float())    # AND NOT
df.select(cs.numeric() - cs.integer())   # Difference

# Exclude from selector
df.select(cs.numeric().exclude("id"))
```

### First/Last Columns

```python
df.select(pl.first())           # First column
df.select(pl.last())            # Last column
df.select(pl.nth(0, 2, 4))      # By index positions
```

## Row Filtering

### Single Condition

```python
df.filter(pl.col("age") > 25)
df.filter(pl.col("name") == "Alice")
df.filter(pl.col("active"))              # Boolean column
df.filter(~pl.col("active"))             # NOT (negation)
```

### Multiple Conditions

```python
# AND: both conditions must be true
df.filter((pl.col("age") > 25) & (pl.col("active")))

# OR: either condition true
df.filter((pl.col("age") > 30) | (pl.col("name") == "Alice"))

# Complex combinations
df.filter(
    ((pl.col("age") > 25) & (pl.col("active"))) |
    (pl.col("name") == "Admin")
)
```

### Membership (IN)

```python
df.filter(pl.col("name").is_in(["Alice", "Bob"]))
df.filter(~pl.col("name").is_in(["Alice", "Bob"]))  # NOT IN
```

### String Conditions

```python
df.filter(pl.col("name").str.contains("li"))
df.filter(pl.col("name").str.starts_with("A"))
df.filter(pl.col("name").str.ends_with("e"))
```

### Null Handling

```python
df.filter(pl.col("value").is_null())
df.filter(pl.col("value").is_not_null())
df.filter(pl.col("value").is_nan())        # For floats
df.filter(pl.col("value").is_not_nan())
```

### Between

```python
df.filter(pl.col("age").is_between(25, 35))
df.filter(pl.col("age").is_between(25, 35, closed="left"))   # [25, 35)
df.filter(pl.col("age").is_between(25, 35, closed="right"))  # (25, 35]
df.filter(pl.col("age").is_between(25, 35, closed="none"))   # (25, 35)
```

## Adding and Modifying Columns

### with_columns

```python
# Add new columns
df.with_columns(
    (pl.col("age") + 1).alias("age_next_year"),
    (pl.col("score") * 1.1).alias("boosted_score"),
    pl.lit("active").alias("status")
)

# Modify existing column (same name)
df.with_columns(
    pl.col("name").str.to_uppercase()  # No alias = replaces "name"
)
```

### Conditional Columns (when/then/otherwise)

```python
# Simple if-else
df.with_columns(
    pl.when(pl.col("age") >= 30)
      .then(pl.lit("senior"))
      .otherwise(pl.lit("junior"))
      .alias("level")
)

# Multiple conditions (if-elif-else)
df.with_columns(
    pl.when(pl.col("score") >= 90)
      .then(pl.lit("A"))
      .when(pl.col("score") >= 80)
      .then(pl.lit("B"))
      .when(pl.col("score") >= 70)
      .then(pl.lit("C"))
      .otherwise(pl.lit("F"))
      .alias("grade")
)

# Conditional with column values
df.with_columns(
    pl.when(pl.col("active"))
      .then(pl.col("salary") * 1.1)
      .otherwise(pl.col("salary"))
      .alias("adjusted_salary")
)
```

### Rename Columns

```python
df.rename({"old_name": "new_name"})
df.rename({"col1": "a", "col2": "b"})
```

### Drop Columns

```python
df.drop("column_name")
df.drop(["col1", "col2"])
df.drop(cs.temporal())  # Drop by selector
```

### Reorder Columns

```python
df.select("name", "id", pl.all().exclude("name", "id"))
```

## Null Values

### Check for Nulls

```python
df.null_count()                  # Null count per column
df.select(pl.all().is_null())    # Boolean mask per column
```

### Fill Nulls

```python
df.with_columns(
    pl.col("value").fill_null(0),                    # With constant
    pl.col("value").fill_null(strategy="forward"),   # Forward fill
    pl.col("value").fill_null(strategy="backward"),  # Backward fill
    pl.col("value").fill_null(pl.col("value").mean()), # No strategy="mean"; compute mean explicitly
    pl.col("value").fill_null(pl.col("default"))     # From another column
)
```

### Drop Nulls

```python
df.drop_nulls()                      # Rows with any null
df.drop_nulls(subset=["a", "b"])     # Rows with null in a or b
```

### Replace Values

```python
df.with_columns(
    pl.col("status").replace({"old": "new", "unknown": "pending"})
)

# Replace with default for unmatched
df.with_columns(
    pl.col("status").replace(
        {"A": 1, "B": 2},
        default=0
    )
)
```

## Sorting

### Basic Sort

```python
df.sort("age")
df.sort("age", descending=True)
```

### Multiple Columns

```python
df.sort(["category", "date"], descending=[False, True])
```

### Null Handling in Sort

```python
df.sort("value", nulls_last=True)   # Nulls at end
df.sort("value", nulls_last=False)  # Nulls at start (default)
```

### Sort by Expression

```python
df.sort(pl.col("name").str.len_chars())
df.sort(pl.col("date").dt.month())
```

## Unique and Duplicates

### Unique Values

```python
df.unique()                          # Unique rows
df.unique(subset=["name"])           # Unique by column
df.unique(subset=["a", "b"])         # Unique by multiple columns
df.unique(keep="first")              # Keep first occurrence
df.unique(keep="last")               # Keep last occurrence
df.unique(keep="none")               # Drop all duplicates
```

### Count Unique

```python
df.select(pl.col("name").n_unique())
df.n_unique()  # Unique row count
```

### Find Duplicates

```python
df.filter(pl.struct("a", "b").is_duplicated())
df.filter(~pl.struct("a", "b").is_duplicated())  # Non-duplicates
```

## Sampling

```python
df.sample(n=10)                 # N random rows
df.sample(fraction=0.1)         # 10% of rows
df.sample(n=10, seed=42)        # Reproducible
df.sample(n=10, with_replacement=True)
```

## Row Indexing

### By Position

```python
df.head(5)                # First 5
df.tail(5)                # Last 5
df.slice(10, 20)          # Rows 10-29 (offset, length)
df.gather([0, 5, 10])     # Specific row indices
```

### Row Index Column

```python
df.with_row_index()                    # Add "index" column
df.with_row_index(name="row_num")      # Custom name
df.with_row_index(offset=1)            # Start from 1
```

## Column Operations

### Get Column Info

```python
df.columns              # List of column names
df.schema               # Dict of name: dtype
df.dtypes               # List of dtypes
df.estimated_size()     # Memory estimate in bytes
```

### Apply to All Columns

```python
# Same operation on all columns
df.select(pl.all() * 2)
df.select(pl.all().cast(pl.String))
df.select(pl.all().fill_null(0))
```

## Summary

| Operation | Method |
|-----------|--------|
| Select columns | `df.select("a", "b")` |
| Filter rows | `df.filter(pl.col("a") > 1)` |
| Add columns | `df.with_columns(...)` |
| Drop columns | `df.drop("col")` |
| Rename columns | `df.rename({"old": "new"})` |
| Sort | `df.sort("col")` |
| Unique rows | `df.unique()` |
| Drop nulls | `df.drop_nulls()` |
| Fill nulls | `pl.col("a").fill_null(0)` |
| Sample | `df.sample(n=10)` |
