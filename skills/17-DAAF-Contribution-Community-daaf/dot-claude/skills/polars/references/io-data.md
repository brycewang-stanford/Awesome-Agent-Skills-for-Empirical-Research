# Data I/O

## CSV Files

### Read CSV (Eager)

```python
df = pl.read_csv("data.csv")

# With options
df = pl.read_csv(
    "data.csv",
    separator=",",              # Delimiter (default: ",")
    has_header=True,            # First row is header (default: True)
    skip_rows=1,                # Skip first N rows
    n_rows=1000,                # Only read first N rows
    columns=["a", "b", "c"],    # Only these columns
    schema_overrides={"id": pl.Int32},  # Override types ("dtypes" renamed to "schema_overrides" in 0.20.31)
    null_values=["NA", ""],     # Treat as null
    ignore_errors=True,         # Skip bad rows
    encoding="utf8",            # Encoding (default: utf8)
)
```

### Scan CSV (Lazy - Recommended)

```python
lf = pl.scan_csv("data.csv")

# With options
lf = pl.scan_csv(
    "data.csv",
    has_header=True,
    separator=",",
    skip_rows=0,
    n_rows=None,                # None = all rows
    schema_overrides={"id": pl.Int32},
    null_values=["NA"],
    infer_schema_length=10000,  # Rows to infer types (default: 100)
    low_memory=False,           # Reduce memory at cost of speed
)

df = lf.collect()
```

### Write CSV

```python
df.write_csv("output.csv")

# With options
df.write_csv(
    "output.csv",
    separator=",",
    include_header=True,
    null_value="",              # How to write nulls
    datetime_format="%Y-%m-%d", # Format for datetime
    float_precision=6,          # Decimal places
)
```

### Streaming Write (Large Data)

```python
lf.sink_csv("output.csv")
```

## Parquet Files (Recommended)

Parquet is the preferred format: compressed, fast, type-preserving.

### Read Parquet (Eager)

```python
df = pl.read_parquet("data.parquet")

# Specific columns only
df = pl.read_parquet("data.parquet", columns=["a", "b"])

# Row groups
df = pl.read_parquet("data.parquet", n_rows=1000)
```

### Scan Parquet (Lazy - Best for Large Files)

```python
lf = pl.scan_parquet("data.parquet")

# Benefits: predicate/projection pushdown
result = (
    pl.scan_parquet("huge.parquet")
    .filter(pl.col("date") > "2024-01-01")  # Only reads matching rows
    .select("id", "value")                   # Only reads these columns
    .collect()
)
```

### Write Parquet

```python
df.write_parquet("output.parquet")

# With compression
df.write_parquet(
    "output.parquet",
    compression="zstd",         # "zstd", "snappy", "gzip", "lz4", "uncompressed"
    compression_level=3,        # 1-22 for zstd (higher = smaller, slower)
    statistics=True,            # Include column statistics
    row_group_size=100_000,     # Rows per group
)
```

### Streaming Write

```python
lf.sink_parquet("output.parquet", compression="zstd")
```

## JSON Files

### Read JSON

```python
# Standard JSON (array of objects)
df = pl.read_json("data.json")
```

### Read NDJSON (Newline-Delimited JSON)

```python
# Better for large files, streaming
df = pl.read_ndjson("data.ndjson")

# Lazy scan
lf = pl.scan_ndjson("data.ndjson")
```

### Write JSON/NDJSON

```python
df.write_json("output.json")
df.write_ndjson("output.ndjson")

# Streaming
lf.sink_ndjson("output.ndjson")
```

## Multiple Files (Glob Patterns)

### Read Multiple Files

```python
# All CSVs in directory
lf = pl.scan_csv("data/*.csv")

# Recursive glob
lf = pl.scan_parquet("data/**/*.parquet")

# With pattern matching
lf = pl.scan_csv("data/sales_202[34]*.csv")
```

### Add Source File Column

```python
lf = pl.scan_csv("data/*.csv", include_file_paths="source_file")
# Adds column with the file path for each row
```

### Hive Partitioned Data

```python
# For directory structure: data/year=2024/month=01/data.parquet
lf = pl.scan_parquet("data/**/*.parquet", hive_partitioning=True)
# Automatically creates year and month columns from path
```

## Excel Files

```python
# Requires: pip install xlsx2csv or pip install openpyxl

df = pl.read_excel("data.xlsx")

# Specific sheet
df = pl.read_excel("data.xlsx", sheet_name="Sheet2")
df = pl.read_excel("data.xlsx", sheet_id=1)  # 1-indexed

# Read all sheets
sheets = pl.read_excel("data.xlsx", sheet_id=0)  # Returns dict

# Write Excel
df.write_excel("output.xlsx")
```

## Database Connections

### SQLite

```python
# Read
df = pl.read_database(
    "SELECT * FROM users WHERE active = 1",
    "sqlite:///database.db"
)

# Or with connection object
import sqlite3
conn = sqlite3.connect("database.db")
df = pl.read_database("SELECT * FROM users", conn)
```

### PostgreSQL

```python
# Requires: pip install connectorx

df = pl.read_database(
    "SELECT * FROM users",
    "postgresql://user:pass@host:5432/database"
)

# With query parameters
df = pl.read_database_uri(
    "SELECT * FROM users WHERE id = $1",
    "postgresql://user:pass@host/db",
    execute_options={"parameters": [42]}
)
```

### MySQL

```python
df = pl.read_database(
    "SELECT * FROM users",
    "mysql://user:pass@host:3306/database"
)
```

### Generic ADBC (Arrow Database Connectivity)

```python
# Modern, high-performance option
import adbc_driver_postgresql.dbapi

conn = adbc_driver_postgresql.dbapi.connect("postgresql://...")
df = pl.read_database("SELECT * FROM users", conn)
```

## Cloud Storage

### AWS S3

```python
# Requires: pip install polars[fsspec] and s3fs

# Read directly
df = pl.read_parquet("s3://bucket/path/data.parquet")
lf = pl.scan_parquet("s3://bucket/path/*.parquet")

# With credentials (via environment or explicit)
import s3fs
fs = s3fs.S3FileSystem(
    key="ACCESS_KEY",
    secret="SECRET_KEY",
    endpoint_url="https://s3.region.amazonaws.com"
)
df = pl.read_parquet("s3://bucket/data.parquet", storage_options={"fs": fs})
```

### Google Cloud Storage

```python
# Requires: pip install gcsfs

df = pl.read_parquet("gs://bucket/data.parquet")
lf = pl.scan_parquet("gs://bucket/path/*.parquet")
```

### Azure Blob Storage

```python
# Requires: pip install adlfs

df = pl.read_parquet("az://container/data.parquet")
lf = pl.scan_parquet("abfss://container@account.dfs.core.windows.net/path/*.parquet")
```

## HTTP/URLs

```python
# Read directly from URL
df = pl.read_csv("https://example.com/data.csv")
df = pl.read_parquet("https://example.com/data.parquet")

# Large files - download first for better performance
import urllib.request
urllib.request.urlretrieve("https://example.com/large.parquet", "local.parquet")
df = pl.read_parquet("local.parquet")
```

## IPC (Arrow/Feather)

```python
# Fast binary format, good for inter-process communication

# Read
df = pl.read_ipc("data.arrow")
df = pl.read_ipc("data.feather")

# Lazy scan
lf = pl.scan_ipc("data.arrow")

# Write
df.write_ipc("output.arrow")
df.write_ipc("output.feather", compression="zstd")
```

## Avro Files

```python
# Avro support is built into polars (no extra install needed)

df = pl.read_avro("data.avro")
df.write_avro("output.avro", compression="snappy")
```

## Delta Lake

```python
# Requires: pip install deltalake

df = pl.read_delta("delta_table_path/")
lf = pl.scan_delta("delta_table_path/")

# With version
# Version is passed directly: pl.read_delta("path/", version=5)
df = pl.read_delta("delta_table/", version=5)
```

## Common Patterns

### Type Inference Control

```python
# More rows for type inference
lf = pl.scan_csv("data.csv", infer_schema_length=100000)

# Disable inference (use explicit schema)
df = pl.read_csv("data.csv", infer_schema=False)  # All strings

# Explicit schema
df = pl.read_csv(
    "data.csv",
    schema={
        "id": pl.Int64,
        "name": pl.String,
        "date": pl.Date,
        "value": pl.Float64
    }
)
```

### Handling Large Files

```python
# Use lazy + streaming
result = (
    pl.scan_csv("huge_file.csv")
    .filter(pl.col("category") == "A")
    .group_by("region")
    .agg(pl.col("sales").sum())
    .collect(streaming=True)
)

# Or sink directly to file
(
    pl.scan_csv("input.csv")
    .filter(pl.col("active"))
    .sink_parquet("output.parquet")
)
```

### Reading Specific Rows/Columns

```python
# Only specific columns
df = pl.read_parquet("data.parquet", columns=["id", "name", "value"])

# Only first N rows
df = pl.read_csv("data.csv", n_rows=1000)

# Skip rows
df = pl.read_csv("data.csv", skip_rows=10, skip_rows_after_header=5)
```

## Summary

| Format | Read (Eager) | Scan (Lazy) | Write | Best For |
|--------|--------------|-------------|-------|----------|
| CSV | `read_csv` | `scan_csv` | `write_csv` | Interchange |
| Parquet | `read_parquet` | `scan_parquet` | `write_parquet` | Production (recommended) |
| JSON | `read_json` | - | `write_json` | APIs |
| NDJSON | `read_ndjson` | `scan_ndjson` | `write_ndjson` | Streaming JSON |
| IPC/Arrow | `read_ipc` | `scan_ipc` | `write_ipc` | Inter-process |
| Excel | `read_excel` | - | `write_excel` | Spreadsheets |
| Database | `read_database` | - | - | SQL queries |

**Key recommendation**: Use Parquet with lazy scanning (`scan_parquet`) for large datasets.
