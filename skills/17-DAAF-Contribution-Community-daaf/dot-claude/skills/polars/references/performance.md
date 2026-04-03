# Performance Optimization

## Lazy Evaluation

### Why Use Lazy Mode

Lazy evaluation is Polars' killer feature for performance:

1. **Query Optimization**: Polars rewrites your query for efficiency
2. **Predicate Pushdown**: Filters are pushed to file read operations
3. **Projection Pushdown**: Only required columns are loaded
4. **Common Subexpression Elimination**: Avoids redundant computation
5. **Streaming**: Enables processing larger-than-memory datasets

### Lazy vs Eager Comparison

```python
# Eager (reads entire file, then filters)
df = pl.read_csv("huge.csv")           # Load all data
df = df.filter(pl.col("status") == "active")  # Then filter

# Lazy (optimized - reads only what's needed)
df = (
    pl.scan_csv("huge.csv")            # Just creates plan
    .filter(pl.col("status") == "active")  # Adds filter to plan
    .collect()                         # Executes optimized plan
)
```

### Inspecting Query Plans

```python
lf = (
    pl.scan_parquet("data.parquet")
    .filter(pl.col("date") > "2024-01-01")
    .select("id", "name", "value")
    .group_by("name")
    .agg(pl.col("value").sum())
)

# View logical plan (what you wrote)
print(lf.explain())

# View optimized plan (what Polars will do)
print(lf.explain(optimized=True))
```

## Best Practices

### Use scan_ Instead of read_

```python
# Prefer this
lf = pl.scan_csv("data.csv")
lf = pl.scan_parquet("data.parquet")
lf = pl.scan_ndjson("data.ndjson")

# Over this
df = pl.read_csv("data.csv")
df = pl.read_parquet("data.parquet")
```

### Filter Early

```python
# Good - filter pushed to scan
result = (
    pl.scan_parquet("data.parquet")
    .filter(pl.col("year") == 2024)      # First
    .select("id", "name", "value")
    .group_by("name")
    .agg(pl.col("value").sum())
    .collect()
)

# Less efficient - processes more data than needed
result = (
    pl.scan_parquet("data.parquet")
    .group_by("name")
    .agg(pl.col("value").sum())
    .filter(pl.col("year") == 2024)      # Too late!
    .collect()
)
```

### Select Only Needed Columns

```python
# Good - only reads 3 columns from file
result = (
    pl.scan_parquet("wide_table.parquet")
    .select("id", "name", "value")
    .collect()
)

# Bad - reads all columns then discards
df = pl.read_parquet("wide_table.parquet")
result = df.select("id", "name", "value")
```

### Avoid Multiple collect() Calls

```python
# Bad - scans file twice
lf = pl.scan_parquet("data.parquet")
sum_result = lf.select(pl.col("value").sum()).collect()
mean_result = lf.select(pl.col("value").mean()).collect()

# Good - single scan
lf = pl.scan_parquet("data.parquet")
results = lf.select(
    pl.col("value").sum().alias("sum"),
    pl.col("value").mean().alias("mean")
).collect()

# Or use collect_all for separate LazyFrames
lf = pl.scan_parquet("data.parquet")
lf1 = lf.filter(pl.col("type") == "A").select(pl.col("value").sum())
lf2 = lf.filter(pl.col("type") == "B").select(pl.col("value").sum())
results = pl.collect_all([lf1, lf2])  # Optimized together
```

## Anti-Patterns to Avoid

### Row-by-Row Iteration

```python
# BAD - Extremely slow
result = []
for row in df.iter_rows(named=True):
    result.append(row["value"] * 2)

# GOOD - Vectorized
df.with_columns(
    (pl.col("value") * 2).alias("doubled")
)
```

### Using map_elements (Python UDFs)

```python
# BAD - Python overhead for each element
df.with_columns(
    pl.col("value").map_elements(lambda x: x * 2, return_dtype=pl.Int64)
)

# GOOD - Native Polars expression
df.with_columns(
    (pl.col("value") * 2).alias("result")
)

# If you must use Python functions, prefer map_batches
df.with_columns(
    pl.col("value").map_batches(lambda s: s * 2)  # Works on entire Series
)
```

### String Concatenation in Loop

```python
# BAD
result = df.select(pl.col("a"))
for col in ["b", "c", "d"]:
    result = result.with_columns(pl.col(col))

# GOOD
result = df.select("a", "b", "c", "d")
```

### Creating DataFrames in Loops

```python
# BAD - Creates many small DataFrames
dfs = []
for file in files:
    dfs.append(pl.read_parquet(file))
combined = pl.concat(dfs)

# GOOD - Single scan with glob
combined = pl.scan_parquet("data/*.parquet").collect()
```

## Memory Optimization

### Use Appropriate Data Types

```python
# Check current memory usage
print(df.estimated_size())  # Bytes

# Downcast numeric types
df = df.with_columns(
    pl.col("small_int").cast(pl.Int16),      # Instead of Int64
    pl.col("tiny_int").cast(pl.Int8),
    pl.col("unsigned").cast(pl.UInt32),
    pl.col("small_float").cast(pl.Float32),  # Instead of Float64
)
```

### Use Categorical for Repeated Strings

```python
# High cardinality strings = lots of memory
df = pl.DataFrame({"category": ["A", "B", "A", "C", "B"] * 1000000})
print(df.estimated_size())  # Large

# Categorical = much smaller
df = df.with_columns(pl.col("category").cast(pl.Categorical))
print(df.estimated_size())  # Much smaller
```

### Streaming for Large Files

```python
# Process larger-than-memory files
result = (
    pl.scan_parquet("huge_file.parquet")
    .filter(pl.col("status") == "active")
    .group_by("category")
    .agg(pl.col("value").sum())
    .collect(streaming=True)  # Processes in chunks
)

# Write directly without collecting
(
    pl.scan_parquet("input.parquet")
    .filter(pl.col("date") > "2024-01-01")
    .sink_parquet("output.parquet")  # Streams to file
)
```

### Release Memory

```python
# Delete when done
del large_df

# Or use context manager for temporary data
def process():
    df = pl.read_parquet("data.parquet")
    result = df.group_by("key").agg(pl.col("value").sum())
    return result  # df goes out of scope

summary = process()  # Large df is released
```

## Parallel Processing

Polars automatically parallelizes operations across CPU cores.

### Check Thread Count

```python
import polars as pl
print(pl.threadpool_size())
```

### Control Parallelism

```python
# Set at runtime (before any operations)
import os
os.environ["POLARS_MAX_THREADS"] = "4"

# Or in code
pl.Config.set_streaming_chunk_size(100_000)
```

### Operations That Parallelize Well

- Aggregations (sum, mean, etc.)
- Filtering
- Joins
- Group by operations
- Window functions

## Benchmarking

### Profile Your Code

```python
import time

start = time.perf_counter()
result = (
    pl.scan_parquet("data.parquet")
    .filter(pl.col("x") > 0)
    .group_by("category")
    .agg(pl.col("value").sum())
    .collect()
)
elapsed = time.perf_counter() - start
print(f"Elapsed: {elapsed:.3f}s")
```

### Compare Approaches

```python
import timeit

# Approach 1: Eager
def eager_approach():
    df = pl.read_parquet("data.parquet")
    return df.filter(pl.col("x") > 0).group_by("y").agg(pl.col("z").sum())

# Approach 2: Lazy
def lazy_approach():
    return (
        pl.scan_parquet("data.parquet")
        .filter(pl.col("x") > 0)
        .group_by("y")
        .agg(pl.col("z").sum())
        .collect()
    )

print("Eager:", timeit.timeit(eager_approach, number=10))
print("Lazy:", timeit.timeit(lazy_approach, number=10))
```

## File Format Performance

### Use Parquet

Parquet is significantly faster than CSV:

```python
# CSV - slow, no type preservation
df = pl.read_csv("data.csv")           # Slow
df = pl.scan_csv("data.csv").collect() # Better but still slow

# Parquet - fast, typed, compressed
df = pl.scan_parquet("data.parquet").collect()  # Fast!
```

### Parquet Compression

```python
# Write with compression
df.write_parquet("data.parquet", compression="zstd")  # Good balance
df.write_parquet("data.parquet", compression="snappy")  # Faster decompress
df.write_parquet("data.parquet", compression="lz4")     # Fastest

# Compression levels (zstd)
df.write_parquet("data.parquet", compression="zstd", compression_level=3)  # Default
df.write_parquet("data.parquet", compression="zstd", compression_level=19) # High compression (max is 22)
```

## Common Performance Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Slow on large CSV | Eager read | Use `scan_csv` + lazy |
| Memory error | Loading entire file | Use streaming or lazy |
| Slow filters | After aggregation | Move filters before grouping |
| Slow string ops | `map_elements` | Use native `.str` methods |
| Multiple scans | Multiple `collect()` | Use `collect_all` or single pipeline |
| Type conversion | Wrong inference | Specify schema explicitly |
| Slow joins | Large DataFrames | Use lazy mode, filter first |

## Checklist for Optimal Performance

1. Use `scan_*` instead of `read_*`
2. Use Parquet format when possible
3. Filter early in the pipeline
4. Select only needed columns
5. Avoid `map_elements`/Python UDFs
6. Use appropriate data types (Int32 vs Int64, Categorical)
7. Use single `collect()` or `collect_all()`
8. Enable streaming for large data: `collect(streaming=True)`
9. Use native expressions instead of iteration
10. Profile and benchmark your code
