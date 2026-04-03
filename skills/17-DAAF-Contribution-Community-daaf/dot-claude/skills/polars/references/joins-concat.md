# Joins & Concatenation

## Join Types

### Inner Join (Default)

Returns only rows with matches in both DataFrames:

```python
df1.join(df2, on="key")
df1.join(df2, on="key", how="inner")
```

### Left Join

Returns all rows from left, matching rows from right (null if no match):

```python
df1.join(df2, on="key", how="left")
```

### Right Join

Returns all rows from right, matching rows from left:

```python
df1.join(df2, on="key", how="right")
```

### Full Outer Join

Returns all rows from both DataFrames:

```python
df1.join(df2, on="key", how="full")
# Note: how="outer" is NOT valid in Polars 1.x; use how="full"
```

### Cross Join

Cartesian product (every row paired with every row):

```python
df1.join(df2, how="cross")
```

### Anti Join

Rows in left that have NO match in right:

```python
df1.join(df2, on="key", how="anti")
```

### Semi Join

Rows in left that HAVE a match in right (but doesn't include right columns):

```python
df1.join(df2, on="key", how="semi")
```

## Join Keys

### Single Key

```python
df1.join(df2, on="id")
```

### Multiple Keys

```python
df1.join(df2, on=["id", "date"])
```

### Different Column Names

```python
df1.join(df2, left_on="user_id", right_on="id")
df1.join(df2, left_on=["user_id", "date"], right_on=["id", "timestamp"])
```

### Join on Expression

```python
# Join on transformed keys
df1.join(
    df2,
    left_on=pl.col("date").dt.date(),
    right_on=pl.col("timestamp").dt.date()
)
```

## Handling Duplicate Columns

When both DataFrames have columns with the same name (other than join keys):

```python
# Default: adds "_right" suffix
df1.join(df2, on="id")
# If both have "value" column, result has "value" and "value_right"

# Custom suffix
df1.join(df2, on="id", suffix="_from_df2")

# Coalesce (keep left value, fill with right if null)
df1.join(df2, on="id", how="full", coalesce=True)
```

## Join Strategies

For performance optimization with large datasets:

```python
# Let Polars decide (default)
df1.join(df2, on="key")

# Force hash join (good for unique keys)
df1.join(df2, on="key", join_nulls=False)

# Include null keys in join
df1.join(df2, on="key", join_nulls=True)
```

## Concatenation

### Vertical Concatenation (Stack Rows)

```python
# Two DataFrames
pl.concat([df1, df2])

# Multiple DataFrames
pl.concat([df1, df2, df3, df4])

# Different column order (aligns by name)
pl.concat([df1, df2], how="align")

# Diagonal (union of all columns, nulls for missing)
pl.concat([df1, df2], how="diagonal")

# Diagonal with relaxed types
pl.concat([df1, df2], how="diagonal_relaxed")
```

### Horizontal Concatenation (Stack Columns)

```python
pl.concat([df1, df2], how="horizontal")

# Requires same number of rows
```

### From List of DataFrames

```python
dfs = [pl.read_csv(f"data_{i}.csv") for i in range(10)]
combined = pl.concat(dfs)
```

## Pivot (Long to Wide)

Convert long format to wide format:

```python
# Long format:
# | date       | product | sales |
# | 2024-01-01 | A       | 100   |
# | 2024-01-01 | B       | 150   |
# | 2024-01-02 | A       | 120   |

df.pivot(
    on="product",           # Column to spread
    index="date",           # Keep as rows
    values="sales"          # Values to fill
)

# Result:
# | date       | A   | B   |
# | 2024-01-01 | 100 | 150 |
# | 2024-01-02 | 120 | null|
```

### Pivot with Aggregation

```python
df.pivot(
    on="product",
    index="date",
    values="sales",
    aggregate_function="sum"     # If duplicates exist
)

# Multiple aggregations
df.pivot(
    on="product",
    index="date",
    values="sales",
    aggregate_function="first"   # first, last, sum, mean, count, etc.
)
```

### Multiple Index Columns

```python
df.pivot(
    on="product",
    index=["date", "region"],
    values="sales"
)
```

### Multiple Value Columns

```python
df.pivot(
    on="product",
    index="date",
    values=["sales", "quantity"]
)
```

## Unpivot / Melt (Wide to Long)

Convert wide format to long format:

```python
# Wide format:
# | date       | product_A | product_B |
# | 2024-01-01 | 100       | 150       |

df.unpivot(
    on=["product_A", "product_B"],   # Columns to melt
    index="date",                     # Keep as identifier
    variable_name="product",          # Name for column names
    value_name="sales"                # Name for values
)

# Result:
# | date       | product   | sales |
# | 2024-01-01 | product_A | 100   |
# | 2024-01-01 | product_B | 150   |
```

**Note**: `melt` was renamed to `unpivot` in Polars 1.0. Both still work.

### Unpivot All Except Index

```python
df.unpivot(
    index=["id", "date"],    # Keep these
    # All other columns are melted
)
```

### Select Columns to Melt

```python
# By name
df.unpivot(on=["col1", "col2", "col3"], index="id")

# By pattern
import polars.selectors as cs
df.unpivot(on=cs.starts_with("value_"), index="id")
```

## Common Patterns

### Self Join

```python
# Join DataFrame to itself (e.g., find pairs)
df.join(df, on="category", suffix="_other").filter(
    pl.col("id") < pl.col("id_other")
)
```

### Lookup Table

```python
# Main data
orders = pl.DataFrame({
    "order_id": [1, 2, 3],
    "product_code": ["A", "B", "A"]
})

# Lookup table
products = pl.DataFrame({
    "code": ["A", "B"],
    "name": ["Apple", "Banana"]
})

# Add product names
orders.join(products, left_on="product_code", right_on="code", how="left")
```

### Update Values from Another DataFrame

```python
# Use coalesce with full join
df1.join(df2, on="id", how="left", suffix="_new").with_columns(
    pl.coalesce(pl.col("value_new"), pl.col("value")).alias("value")
).drop("value_new")
```

### Conditional Join (Inequality)

```python
# Polars doesn't have direct inequality joins
# Use cross join + filter
df1.join(df2, how="cross").filter(
    (pl.col("start") <= pl.col("date")) &
    (pl.col("date") < pl.col("end"))
)

# Or use join_asof for time-based inequality
```

### As-Of Join (Time-Based)

Join on nearest time match:

```python
# df1 has events at various times
# df2 has reference values at specific times
# Match each event to the most recent reference

df1.sort("timestamp").join_asof(
    df2.sort("timestamp"),
    on="timestamp",
    strategy="backward"    # Use most recent value <= event time
)

# Strategies:
# "backward" - most recent value <= key
# "forward" - next value >= key
# "nearest" - closest value

# With tolerance
df1.join_asof(
    df2,
    on="timestamp",
    tolerance="1h"         # Match only within 1 hour
)

# With grouping
df1.join_asof(
    df2,
    on="timestamp",
    by="symbol",           # Match within same symbol
    strategy="backward"
)
```

### Multiple DataFrames Join

```python
# Chain joins
result = (
    df1
    .join(df2, on="key1", how="left")
    .join(df3, on="key2", how="left")
    .join(df4, on="key3", how="left")
)

# Or reduce over list
from functools import reduce
dfs = [df1, df2, df3, df4]
result = reduce(lambda a, b: a.join(b, on="id", how="left"), dfs)
```

## Summary

| Operation | Code |
|-----------|------|
| Inner join | `df1.join(df2, on="key")` |
| Left join | `df1.join(df2, on="key", how="left")` |
| Full outer join | `df1.join(df2, on="key", how="full")` |
| Anti join | `df1.join(df2, on="key", how="anti")` |
| Semi join | `df1.join(df2, on="key", how="semi")` |
| Different keys | `df1.join(df2, left_on="a", right_on="b")` |
| Vertical concat | `pl.concat([df1, df2])` |
| Horizontal concat | `pl.concat([df1, df2], how="horizontal")` |
| Pivot (long→wide) | `df.pivot(on="col", index="id", values="val")` |
| Unpivot (wide→long) | `df.unpivot(on=["a", "b"], index="id")` |
| As-of join | `df1.join_asof(df2, on="time")` |
