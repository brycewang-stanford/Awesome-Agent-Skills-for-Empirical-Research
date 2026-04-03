# Aggregations & Grouping

## Basic Aggregations

### On Entire DataFrame

```python
# Single aggregation
df.select(pl.col("value").sum())
df.select(pl.col("value").mean())

# Multiple aggregations
df.select(
    pl.col("value").sum().alias("total"),
    pl.col("value").mean().alias("average"),
    pl.col("value").std().alias("std_dev"),
    pl.col("value").min().alias("minimum"),
    pl.col("value").max().alias("maximum"),
    pl.col("value").count().alias("non_null_count"),
    pl.len().alias("row_count")
)
```

### Available Aggregation Functions

| Function | Description |
|----------|-------------|
| `.sum()` | Sum of values |
| `.mean()` | Arithmetic mean |
| `.median()` | Median value |
| `.min()` | Minimum value |
| `.max()` | Maximum value |
| `.std()` | Standard deviation |
| `.var()` | Variance |
| `.count()` | Non-null count |
| `.n_unique()` | Unique value count |
| `.first()` | First value |
| `.last()` | Last value |
| `.quantile(q)` | Quantile (0-1) |
| `.arg_min()` | Index of minimum |
| `.arg_max()` | Index of maximum |
| `pl.len()` | Total row count |

## GroupBy Operations

### Basic GroupBy

```python
df.group_by("category").agg(
    pl.col("value").sum().alias("total"),
    pl.col("value").mean().alias("average"),
    pl.len().alias("count")
)
```

### Multiple Grouping Columns

```python
df.group_by("region", "category").agg(
    pl.col("sales").sum().alias("total_sales"),
    pl.col("quantity").sum().alias("total_quantity")
)

# Or as list
df.group_by(["region", "category"]).agg(...)
```

### Maintain Order

```python
# By default, group_by doesn't preserve order
# Use maintain_order=True to keep original order
df.group_by("category", maintain_order=True).agg(
    pl.col("value").sum()
)
```

### Multiple Aggregations on Same Column

```python
df.group_by("category").agg(
    pl.col("value").sum().alias("sum"),
    pl.col("value").mean().alias("mean"),
    pl.col("value").std().alias("std"),
    pl.col("value").min().alias("min"),
    pl.col("value").max().alias("max"),
    pl.col("value").count().alias("count"),
    pl.col("value").quantile(0.25).alias("q25"),
    pl.col("value").quantile(0.75).alias("q75"),
)
```

### Aggregating Different Columns

```python
df.group_by("category").agg(
    pl.col("revenue").sum().alias("total_revenue"),
    pl.col("quantity").sum().alias("total_quantity"),
    pl.col("customer_id").n_unique().alias("unique_customers"),
    pl.col("discount").mean().alias("avg_discount")
)
```

### Collecting Values into Lists

```python
df.group_by("category").agg(
    pl.col("product_id"),           # Collect all values into list
    pl.col("product_id").alias("products"),  # Same with alias
    pl.col("value").sort().alias("sorted_values")
)
```

### First/Last per Group

```python
df.group_by("category").agg(
    pl.col("timestamp").first().alias("first_ts"),
    pl.col("timestamp").last().alias("last_ts"),
    pl.col("value").first().alias("first_value"),
    pl.col("value").last().alias("last_value")
)

# First/last with sorting
df.sort("timestamp").group_by("category").agg(
    pl.col("value").first().alias("earliest_value"),
    pl.col("value").last().alias("latest_value")
)
```

## Window Functions (over)

Window functions compute values within groups without reducing rows.

### Basic Window

```python
# Sum per category (added as column, keeps all rows)
df.with_columns(
    pl.col("value").sum().over("category").alias("category_total")
)

# Mean per category
df.with_columns(
    pl.col("value").mean().over("category").alias("category_avg")
)
```

### Multiple Grouping Columns

```python
df.with_columns(
    pl.col("value").sum().over(["region", "category"]).alias("group_total")
)
```

### Common Window Operations

```python
df.with_columns(
    # Aggregations over group
    pl.col("value").sum().over("category").alias("group_sum"),
    pl.col("value").mean().over("category").alias("group_mean"),
    pl.col("value").min().over("category").alias("group_min"),
    pl.col("value").max().over("category").alias("group_max"),
    pl.col("value").count().over("category").alias("group_count"),
    
    # Percentage of group
    (pl.col("value") / pl.col("value").sum().over("category") * 100)
        .alias("pct_of_category"),
    
    # Deviation from group mean
    (pl.col("value") - pl.col("value").mean().over("category"))
        .alias("deviation_from_mean")
)
```

### Ranking

```python
df.with_columns(
    # Rank within group (1, 2, 3, ...)
    pl.col("value").rank().over("category").alias("rank"),
    
    # Dense rank (no gaps)
    pl.col("value").rank(method="dense").over("category").alias("dense_rank"),
    
    # Ordinal rank (unique values)
    pl.col("value").rank(method="ordinal").over("category").alias("ordinal_rank"),
    
    # Descending rank
    pl.col("value").rank(descending=True).over("category").alias("rank_desc")
)
```

### Row Numbers

```python
df.with_columns(
    # Row number within group
    pl.col("id").cum_count().over("category").alias("row_num"),
    
    # Using arange
    pl.int_range(1, pl.len() + 1).over("category").alias("row_num2")  # pl.arange deprecated; use pl.int_range
)
```

### Shift/Lead/Lag

```python
df.with_columns(
    # Previous value (lag)
    pl.col("value").shift(1).over("category").alias("prev_value"),
    
    # Next value (lead)
    pl.col("value").shift(-1).over("category").alias("next_value"),
    
    # Difference from previous
    (pl.col("value") - pl.col("value").shift(1).over("category"))
        .alias("diff_from_prev")
)
```

## Cumulative Operations

```python
df.with_columns(
    pl.col("value").cum_sum().over("category").alias("running_total"),
    pl.col("value").cum_max().over("category").alias("running_max"),
    pl.col("value").cum_min().over("category").alias("running_min"),
    pl.col("value").cum_count().over("category").alias("running_count"),
    pl.col("value").cum_prod().over("category").alias("running_product"),
)

# Without grouping
df.with_columns(
    pl.col("value").cum_sum().alias("cumulative_sum")
)
```

## Rolling Windows

### By Row Count

```python
df.with_columns(
    pl.col("value").rolling_mean(window_size=7).alias("rolling_avg_7"),
    pl.col("value").rolling_sum(window_size=7).alias("rolling_sum_7"),
    pl.col("value").rolling_std(window_size=7).alias("rolling_std_7"),
    pl.col("value").rolling_min(window_size=7).alias("rolling_min_7"),
    pl.col("value").rolling_max(window_size=7).alias("rolling_max_7"),
)

# With minimum periods
df.with_columns(
    pl.col("value").rolling_mean(window_size=7, min_periods=3).alias("rolling_avg")
)

# Center window
df.with_columns(
    pl.col("value").rolling_mean(window_size=7, center=True).alias("centered_avg")
)
```

### Within Groups

```python
df.with_columns(
    pl.col("value").rolling_mean(window_size=7).over("category").alias("rolling_avg")
)
```

### By Time Period

```python
# DataFrame must be sorted by the time column
df.sort("date").rolling(
    index_column="date",
    period="7d"           # 7-day window
).agg(
    pl.col("value").mean().alias("weekly_avg"),
    pl.col("value").sum().alias("weekly_sum")
)

# Group by category within rolling window
df.sort("date").rolling(
    index_column="date",
    period="7d",
    group_by="category"
).agg(
    pl.col("value").mean().alias("weekly_avg")
)
```

### Time Periods

| Period | Description |
|--------|-------------|
| `"1d"` | 1 day |
| `"7d"` | 7 days |
| `"1w"` | 1 week |
| `"1mo"` | 1 month |
| `"1y"` | 1 year |
| `"1h"` | 1 hour |
| `"30m"` | 30 minutes |

## Group By Dynamic (Time-Based Grouping)

```python
# Resample by time period
df.sort("timestamp").group_by_dynamic(
    "timestamp",
    every="1d"              # Daily
).agg(
    pl.col("value").sum().alias("daily_total"),
    pl.col("value").mean().alias("daily_avg")
)

# Weekly aggregation
df.sort("timestamp").group_by_dynamic(
    "timestamp",
    every="1w",
    start_by="monday"       # Week starts Monday
).agg(...)

# With additional grouping
df.sort("timestamp").group_by_dynamic(
    "timestamp",
    every="1d",
    group_by="category"
).agg(...)

# Offset the start
df.sort("timestamp").group_by_dynamic(
    "timestamp",
    every="1d",
    offset="-6h"            # Offset by 6 hours
).agg(...)
```

## Common Patterns

### Top N per Group

```python
# Top 3 per category by value
df.sort("value", descending=True).group_by("category").head(3)

# Or using over + filter
df.with_columns(
    pl.col("value").rank(descending=True).over("category").alias("rank")
).filter(pl.col("rank") <= 3)
```

### Percentage of Total

```python
df.with_columns(
    (pl.col("value") / pl.col("value").sum() * 100).alias("pct_of_total"),
    (pl.col("value") / pl.col("value").sum().over("category") * 100)
        .alias("pct_of_category")
)
```

### Year-over-Year Comparison

```python
df.with_columns(
    pl.col("timestamp").dt.year().alias("year")
).group_by(["category", "year"]).agg(
    pl.col("value").sum().alias("annual_total")
).sort("category", "year").with_columns(
    (pl.col("annual_total") - pl.col("annual_total").shift(1).over("category"))
        .alias("yoy_change")
)
```

### Moving Average with Fill

```python
df.with_columns(
    pl.col("value")
      .rolling_mean(window_size=7, min_periods=1)
      .alias("rolling_avg")
)
```

## Summary

| Operation | Code |
|-----------|------|
| GroupBy aggregate | `df.group_by("col").agg(...)` |
| Window function | `pl.col("x").sum().over("group")` |
| Rank in group | `pl.col("x").rank().over("group")` |
| Cumulative sum | `pl.col("x").cum_sum()` |
| Rolling average | `pl.col("x").rolling_mean(window_size=7)` |
| Time-based grouping | `df.group_by_dynamic("time", every="1d")` |
| Top N per group | `df.sort("val", descending=True).group_by("g").head(n)` |
