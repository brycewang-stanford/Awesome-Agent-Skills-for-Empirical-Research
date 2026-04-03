# Quickstart

## Installation

### Basic Install

```bash
pip install polars
# or
uv add polars
# or
conda install -c conda-forge polars
```

### With Optional Dependencies

```bash
# All optional features
pip install "polars[all]"

# Specific extras
pip install "polars[numpy,pandas,pyarrow]"  # Interop
pip install "polars[timezone]"               # Timezone support
pip install "polars[connectorx]"             # Database connections
pip install "polars[fsspec]"                 # Cloud storage (S3, GCS, Azure)
```

### Verify Installation

```python
import polars as pl
print(pl.__version__)  # Should be 1.x
```

## Core Concepts

### Lazy vs Eager Execution

Polars has two execution modes:

**Eager** - Executes immediately (like Pandas):
```python
df = pl.DataFrame({"a": [1, 2, 3], "b": [4, 5, 6]})
result = df.filter(pl.col("a") > 1)  # Runs now
```

**Lazy** - Builds query plan, optimizes, then executes:
```python
lf = pl.LazyFrame({"a": [1, 2, 3], "b": [4, 5, 6]})
# Or from file scan
lf = pl.scan_csv("data.csv")

result = (
    lf.filter(pl.col("a") > 1)
    .select("a", "b")
    .collect()  # Executes optimized plan here
)
```

**When to use which:**
- **Eager**: Small data, interactive exploration, quick tests
- **Lazy**: Large data, complex pipelines, production code (recommended)

### Why Lazy is Better for Large Data

1. **Query Optimization**: Polars rewrites your query for efficiency
2. **Predicate Pushdown**: Filters applied at read time (skip unneeded rows)
3. **Projection Pushdown**: Only reads columns you actually use
4. **Streaming**: Process larger-than-memory datasets

```python
# This reads ONLY the needed columns and rows
result = (
    pl.scan_parquet("huge_file.parquet")
    .filter(pl.col("date") > "2024-01-01")  # Pushed down to file read
    .select("id", "value")                   # Only these columns loaded
    .collect()
)
```

### Expressions

Expressions are the heart of Polars. They describe transformations:

```python
# Expressions are functions: Series → Series
pl.col("a")              # Reference column "a"
pl.col("a") + 1          # Add 1 to each value
pl.col("a").sum()        # Sum all values
pl.col("a").alias("b")   # Rename to "b"
```

Expressions are evaluated in **contexts**:
- `select()` - Choose/transform columns
- `with_columns()` - Add new columns
- `filter()` - Filter rows
- `group_by().agg()` - Aggregate by groups

## Creating DataFrames

### From Dictionary

```python
df = pl.DataFrame({
    "name": ["Alice", "Bob", "Charlie"],
    "age": [25, 30, 35],
    "score": [85.5, 90.0, 78.5]
})
```

### With Explicit Schema

```python
df = pl.DataFrame(
    {
        "id": [1, 2, 3],
        "value": ["a", "b", "c"]
    },
    schema={
        "id": pl.Int32,
        "value": pl.String
    }
)
```

### From Series

```python
s1 = pl.Series("a", [1, 2, 3])
s2 = pl.Series("b", [4, 5, 6])
df = pl.DataFrame([s1, s2])
```

### Empty DataFrame with Schema

```python
df = pl.DataFrame(
    schema={
        "id": pl.Int64,
        "name": pl.String,
        "created": pl.Datetime
    }
)
```

### LazyFrame (Lazy Mode)

```python
# From data
lf = pl.LazyFrame({"a": [1, 2, 3]})

# From files (preferred for large data)
lf = pl.scan_csv("data.csv")
lf = pl.scan_parquet("data.parquet")
lf = pl.scan_ndjson("data.ndjson")
```

## Basic Operations

### View Data

```python
df.head(5)          # First 5 rows
df.tail(5)          # Last 5 rows
df.sample(10)       # Random 10 rows
df.glimpse()        # Transposed view
df.describe()       # Statistics summary
df.schema           # Column names and types
df.columns          # List of column names
df.shape            # (rows, cols) tuple
len(df)             # Row count
```

### Select Columns

```python
df.select("name", "age")
df.select(pl.col("name"), pl.col("age"))
df.select(pl.all())                      # All columns
df.select(pl.exclude("id"))              # All except "id"
```

### Filter Rows

```python
df.filter(pl.col("age") > 25)
df.filter((pl.col("age") > 25) & (pl.col("score") > 80))
```

### Add Columns

```python
df.with_columns(
    (pl.col("age") + 1).alias("age_next_year"),
    pl.lit("active").alias("status")
)
```

### Sort

```python
df.sort("age")
df.sort("age", descending=True)
df.sort(["name", "age"], descending=[False, True])
```

## LazyFrame Operations

### Building a Query

```python
query = (
    pl.scan_csv("data.csv")
    .filter(pl.col("status") == "active")
    .select("id", "name", "value")
    .with_columns(
        (pl.col("value") * 1.1).alias("adjusted")
    )
    .sort("value", descending=True)
)
```

### Executing

```python
# Execute and get DataFrame
df = query.collect()

# Execute with streaming (for large data)
df = query.collect(streaming=True)

# Write directly to file (streaming)
query.sink_parquet("output.parquet")
query.sink_csv("output.csv")
```

### Inspecting the Plan

```python
# Logical plan (what you wrote)
print(query.explain())

# Optimized plan (what Polars will do)
print(query.explain(optimized=True))
```

## Type System

### Common Types

| Polars Type | Python Equivalent | Notes |
|-------------|-------------------|-------|
| `pl.Int8/16/32/64` | `int` | Signed integers |
| `pl.UInt8/16/32/64` | `int` | Unsigned integers |
| `pl.Float32/64` | `float` | Floating point |
| `pl.String` | `str` | UTF-8 strings (alias: `pl.Utf8`) |
| `pl.Boolean` | `bool` | True/False |
| `pl.Date` | `datetime.date` | Calendar date |
| `pl.Datetime` | `datetime.datetime` | Timestamp |
| `pl.Duration` | `datetime.timedelta` | Time difference |
| `pl.Time` | `datetime.time` | Time of day |
| `pl.Categorical` | - | Categorical strings |
| `pl.Enum` | - | Fixed set of categories |
| `pl.List` | `list` | Variable-length lists |
| `pl.Array` | - | Fixed-length arrays |
| `pl.Struct` | `dict` | Named fields |
| `pl.Null` | `None` | Null type |

### Casting Types

```python
df.with_columns(
    pl.col("id").cast(pl.Int32),
    pl.col("price").cast(pl.Float64),
    pl.col("category").cast(pl.Categorical)
)
```

## Next Steps

- Learn the [expression system](./expressions.md) - the core of Polars
- Master [data I/O](./io-data.md) for loading files
- Understand [performance patterns](./performance.md) for efficient code
