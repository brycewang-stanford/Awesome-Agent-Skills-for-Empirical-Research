# Interoperability

## Pandas Integration

### Polars to Pandas

```python
# Basic conversion
pandas_df = polars_df.to_pandas()

# With PyArrow backend (recommended - preserves types better)
pandas_df = polars_df.to_pandas(use_pyarrow_extension_array=True)

# Series to pandas Series
pandas_series = polars_series.to_pandas()
```

### Pandas to Polars

```python
import pandas as pd
import polars as pl

# From pandas DataFrame
polars_df = pl.from_pandas(pandas_df)

# From pandas Series
polars_series = pl.from_pandas(pandas_series)

# With schema override
polars_df = pl.from_pandas(pandas_df, schema_overrides={"id": pl.Int32})
```

### Type Mapping

| Pandas Type | Polars Type |
|-------------|-------------|
| `int64` | `pl.Int64` |
| `float64` | `pl.Float64` |
| `object` (strings) | `pl.String` |
| `bool` | `pl.Boolean` |
| `datetime64[ns]` | `pl.Datetime` |
| `timedelta64[ns]` | `pl.Duration` |
| `category` | `pl.Categorical` |

### Common Gotchas

```python
# Pandas uses NaN for missing values in numeric columns
# Polars uses null - conversion handles this automatically

# String columns with None in pandas become pl.String with null
# Make sure to handle null values appropriately

# Index is NOT converted - use reset_index() first if needed
pandas_df = pandas_df.reset_index()
polars_df = pl.from_pandas(pandas_df)
```

## NumPy Integration

### Polars to NumPy

```python
import numpy as np

# Series to numpy array
arr = polars_series.to_numpy()

# DataFrame to 2D numpy array
arr = polars_df.to_numpy()

# Specific column to numpy
arr = polars_df["column_name"].to_numpy()

# Allow copy (default) or zero-copy if possible
arr = polars_series.to_numpy(allow_copy=False)  # Raises if copy needed
```

### NumPy to Polars

```python
# From numpy array
arr = np.array([1, 2, 3, 4, 5])
series = pl.Series("values", arr)

# 2D array to DataFrame
arr = np.array([[1, 2], [3, 4], [5, 6]])
df = pl.DataFrame(arr, schema=["a", "b"])

# From dict of numpy arrays
df = pl.DataFrame({
    "a": np.array([1, 2, 3]),
    "b": np.array([4.0, 5.0, 6.0])
})
```

### Using NumPy Functions

```python
# NumPy ufuncs work on Polars expressions
df.with_columns(
    np.log(pl.col("value")).alias("log_value"),
    np.sqrt(pl.col("value")).alias("sqrt_value"),
    np.exp(pl.col("value")).alias("exp_value"),
)

# Note: This goes through Python/NumPy, prefer native Polars when available
# Polars native:
df.with_columns(
    pl.col("value").log().alias("log_value"),
    pl.col("value").sqrt().alias("sqrt_value"),
    pl.col("value").exp().alias("exp_value"),
)
```

## PyArrow Integration

PyArrow provides zero-copy conversion when possible.

### Polars to Arrow

```python
import pyarrow as pa

# DataFrame to Arrow Table
arrow_table = polars_df.to_arrow()

# Series to Arrow Array
arrow_array = polars_series.to_arrow()

# Chunked (for large data)
arrow_table = polars_df.to_arrow()  # Already chunked internally
```

### Arrow to Polars

```python
# From Arrow Table
arrow_table = pa.table({"a": [1, 2, 3], "b": ["x", "y", "z"]})
polars_df = pl.from_arrow(arrow_table)

# From Arrow Array
arrow_array = pa.array([1, 2, 3])
polars_series = pl.from_arrow(arrow_array, schema={"values": pl.Int64})

# From RecordBatch
polars_df = pl.from_arrow(record_batch)
```

### Zero-Copy Benefits

```python
# Arrow is Polars' native memory format
# Conversion is often zero-copy (no data copying)
arrow_table = polars_df.to_arrow()  # Fast, shares memory
polars_df = pl.from_arrow(arrow_table)  # Fast, shares memory
```

## DuckDB Integration

DuckDB and Polars can share data efficiently via Arrow.

### Query Polars DataFrame with DuckDB

```python
import duckdb
import polars as pl

df = pl.DataFrame({
    "id": [1, 2, 3],
    "name": ["Alice", "Bob", "Charlie"],
    "value": [100, 200, 300]
})

# Method 1: Register and query
con = duckdb.connect()
con.register("my_table", df.to_arrow())
result = con.execute("SELECT * FROM my_table WHERE value > 100").arrow()
result_df = pl.from_arrow(result)

# Method 2: Direct query (DuckDB 0.8+)
result = duckdb.query("SELECT * FROM df WHERE value > 100").pl()
```

### Use DuckDB for Complex SQL

```python
# For complex SQL that's easier in SQL syntax
result = duckdb.query("""
    WITH ranked AS (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY category ORDER BY value DESC) as rn
        FROM df
    )
    SELECT * FROM ranked WHERE rn <= 3
""").pl()
```

### Polars SQL Interface

Polars has built-in SQL support:

```python
# Query single DataFrame
result = df.sql("SELECT name, SUM(value) as total FROM self GROUP BY name")

# SQL Context for multiple tables
ctx = pl.SQLContext({"users": users_df, "orders": orders_df})
result = ctx.execute("""
    SELECT u.name, COUNT(*) as order_count
    FROM users u
    JOIN orders o ON u.id = o.user_id
    GROUP BY u.name
""").collect()
```

## Database Connections

### SQLAlchemy

```python
from sqlalchemy import create_engine

# Create engine
engine = create_engine("postgresql://user:pass@host:5432/database")

# Read with SQL
df = pl.read_database("SELECT * FROM users", engine)

# Write (via pandas for now)
df.to_pandas().to_sql("table_name", engine, if_exists="replace")
```

### ConnectorX (Recommended for Speed)

```python
# Requires: pip install connectorx

# Direct connection string
df = pl.read_database_uri(
    "SELECT * FROM users WHERE active = true",
    "postgresql://user:pass@host:5432/database"
)

# Supported databases:
# PostgreSQL, MySQL, SQLite, SQL Server, Oracle, Redshift, ClickHouse
```

### ADBC (Arrow Database Connectivity)

```python
# Modern, high-performance option
# pip install adbc-driver-postgresql

import adbc_driver_postgresql.dbapi as pg_dbapi

with pg_dbapi.connect("postgresql://user:pass@host/db") as conn:
    df = pl.read_database("SELECT * FROM users", conn)
```

## Scikit-learn Integration

```python
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier

# Polars for data prep
df = (
    pl.scan_parquet("data.parquet")
    .select(["feature1", "feature2", "feature3", "target"])
    .drop_nulls()
    .collect()
)

# Convert to numpy for sklearn
X = df.select(pl.exclude("target")).to_numpy()
y = df["target"].to_numpy()

# Train model
X_train, X_test, y_train, y_test = train_test_split(X, y)
model = RandomForestClassifier()
model.fit(X_train, y_train)

# Predictions back to Polars
predictions = model.predict(X_test)
result_df = pl.DataFrame({
    "prediction": predictions,
    "actual": y_test
})
```

## Visualization Libraries

### Matplotlib

```python
import matplotlib.pyplot as plt

# Convert column to numpy for plotting
plt.plot(df["x"].to_numpy(), df["y"].to_numpy())
plt.show()

# Or convert to pandas
df.to_pandas().plot(x="date", y="value")
```

### Altair

```python
import altair as alt

# Altair works with pandas
chart = alt.Chart(df.to_pandas()).mark_point().encode(
    x="x:Q",
    y="y:Q",
    color="category:N"
)
```

### Plotly

```python
import plotly.express as px

# Plotly works with pandas
fig = px.scatter(df.to_pandas(), x="x", y="y", color="category")
fig.show()
```

## Common Patterns

### Mixed Pipeline

```python
import polars as pl
import pandas as pd

# Start with Polars for efficient data loading and transformation
df = (
    pl.scan_parquet("data.parquet")
    .filter(pl.col("date") > "2024-01-01")
    .group_by("category")
    .agg(pl.col("value").sum())
    .collect()
)

# Convert to pandas for specific library that requires it
pandas_df = df.to_pandas()

# Use pandas-specific functionality
result = some_pandas_only_function(pandas_df)

# Convert back to Polars if needed
polars_result = pl.from_pandas(result)
```

### Efficient Data Pipeline

```python
# Best practice: Use Polars as much as possible
# Only convert at boundaries (I/O, specific libraries)

# Read with Polars (fast)
df = pl.scan_parquet("input.parquet")

# Transform with Polars (fast, parallel)
df = df.filter(...).with_columns(...).group_by(...).agg(...)

# Only convert when necessary
if need_sklearn:
    X = df.select(features).to_numpy()
    
if need_specific_pandas_function:
    pandas_df = df.to_pandas()
    
# Write with Polars (fast)
df.collect().write_parquet("output.parquet")
```

## Summary

| Source | To Polars | From Polars |
|--------|-----------|-------------|
| Pandas | `pl.from_pandas(df)` | `df.to_pandas()` |
| NumPy | `pl.Series(arr)` / `pl.DataFrame(arr)` | `df.to_numpy()` |
| PyArrow | `pl.from_arrow(table)` | `df.to_arrow()` |
| DuckDB | `duckdb.query(...).pl()` | `conn.register("t", df.to_arrow())` |
| Database | `pl.read_database(sql, conn)` | Via pandas or Arrow |
