# Strings, Datetime & Categorical

## String Operations

All string operations are accessed via the `.str` namespace.

### Basic String Operations

```python
df.with_columns(
    pl.col("text").str.to_uppercase().alias("upper"),
    pl.col("text").str.to_lowercase().alias("lower"),
    pl.col("text").str.to_titlecase().alias("title"),
    pl.col("text").str.len_chars().alias("char_count"),      # Character count
    pl.col("text").str.len_bytes().alias("byte_count"),      # Byte count (UTF-8)
)
```

### Whitespace Handling

```python
df.with_columns(
    pl.col("text").str.strip_chars(),               # Strip both ends
    pl.col("text").str.strip_chars_start(),         # Left strip
    pl.col("text").str.strip_chars_end(),           # Right strip
    pl.col("text").str.strip_chars(" \t\n"),        # Strip specific chars
)
```

### Slicing and Substrings

```python
df.with_columns(
    pl.col("text").str.slice(0, 5),        # First 5 characters
    pl.col("text").str.slice(-3),          # Last 3 characters
    pl.col("text").str.head(5),            # First 5 characters
    pl.col("text").str.tail(3),            # Last 3 characters
)
```

### Search and Match

```python
df.with_columns(
    pl.col("text").str.contains("pattern"),              # Contains substring
    pl.col("text").str.contains("pat.*n", literal=False),# Regex match
    pl.col("text").str.starts_with("prefix"),            # Starts with
    pl.col("text").str.ends_with("suffix"),              # Ends with
    pl.col("text").str.find("needle"),                   # Index of first match (null if not found)
    pl.col("text").str.count_matches("a"),               # Count occurrences
)

# Filter by string content
df.filter(pl.col("name").str.contains("Smith"))
df.filter(pl.col("email").str.ends_with("@gmail.com"))
```

### Replace

```python
df.with_columns(
    # Replace first occurrence
    pl.col("text").str.replace("old", "new"),
    
    # Replace all occurrences
    pl.col("text").str.replace_all("old", "new"),
    
    # Regex replace
    pl.col("text").str.replace_all(r"\d+", "NUM"),
    
    # Replace with captured groups
    pl.col("text").str.replace_all(r"(\w+)@(\w+)", r"\2:\1"),
)
```

### Split and Join

```python
df.with_columns(
    # Split to list
    pl.col("tags").str.split(","),                  # Returns List[String]
    pl.col("path").str.split("/"),
    
    # Split and extract
    pl.col("tags").str.split(",").list.first(),     # First element
    pl.col("tags").str.split(",").list.get(1),      # Second element
    pl.col("tags").str.split(",").list.len(),       # Count elements
)

# Join list to string
df.with_columns(
    pl.col("list_col").list.join(", "),            # Join with separator
)
```

### Extract with Regex

```python
df.with_columns(
    # Extract first match of pattern
    pl.col("text").str.extract(r"(\d+)", group_index=1),
    
    # Extract all matches
    pl.col("text").str.extract_all(r"\d+"),         # Returns list
    
    # Named groups
    pl.col("text").str.extract_groups(r"(?<name>\w+):(?<value>\d+)"),
)
```

### Padding and Alignment

```python
df.with_columns(
    pl.col("code").str.pad_start(5, "0"),       # "42" -> "00042"
    pl.col("code").str.pad_end(10, " "),        # Right pad with spaces
    pl.col("code").str.zfill(5),                # Zero-fill left
)
```

### Concatenation

```python
# Concatenate columns
df.with_columns(
    pl.concat_str([
        pl.col("first_name"),
        pl.lit(" "),
        pl.col("last_name")
    ]).alias("full_name")
)

# With separator
df.with_columns(
    pl.concat_str(["city", "state", "country"], separator=", ").alias("location")
)
```

## Datetime Operations

All datetime operations are accessed via the `.dt` namespace.

### Parsing Strings to Datetime

```python
df.with_columns(
    # Auto-detect format
    pl.col("date_str").str.to_datetime(),
    
    # Explicit format
    pl.col("date_str").str.strptime(pl.Datetime, "%Y-%m-%d %H:%M:%S"),
    pl.col("date_str").str.strptime(pl.Date, "%Y-%m-%d"),
    pl.col("date_str").str.strptime(pl.Time, "%H:%M:%S"),
    
    # With timezone
    pl.col("date_str").str.strptime(pl.Datetime, "%Y-%m-%d %H:%M:%S", time_zone="UTC"),
)
```

### Common Format Codes

| Code | Meaning | Example |
|------|---------|---------|
| `%Y` | 4-digit year | 2024 |
| `%y` | 2-digit year | 24 |
| `%m` | Month (01-12) | 07 |
| `%d` | Day (01-31) | 15 |
| `%H` | Hour 24h (00-23) | 14 |
| `%I` | Hour 12h (01-12) | 02 |
| `%M` | Minute (00-59) | 30 |
| `%S` | Second (00-59) | 45 |
| `%f` | Microseconds | 123456 |
| `%p` | AM/PM | PM |
| `%z` | UTC offset | +0000 |
| `%Z` | Timezone name | UTC |

### Extracting Components

```python
df.with_columns(
    pl.col("datetime").dt.year().alias("year"),
    pl.col("datetime").dt.month().alias("month"),
    pl.col("datetime").dt.day().alias("day"),
    pl.col("datetime").dt.hour().alias("hour"),
    pl.col("datetime").dt.minute().alias("minute"),
    pl.col("datetime").dt.second().alias("second"),
    pl.col("datetime").dt.microsecond().alias("microsecond"),
    pl.col("datetime").dt.nanosecond().alias("nanosecond"),
    
    # Day of week (1=Monday, 7=Sunday)
    pl.col("datetime").dt.weekday().alias("weekday"),
    
    # Week of year
    pl.col("datetime").dt.week().alias("week"),
    
    # Day of year (1-366)
    pl.col("datetime").dt.ordinal_day().alias("day_of_year"),
    
    # Quarter (1-4)
    pl.col("datetime").dt.quarter().alias("quarter"),
    
    # ISO year and week
    pl.col("datetime").dt.iso_year().alias("iso_year"),
)
```

### Formatting to String

```python
df.with_columns(
    pl.col("datetime").dt.strftime("%Y-%m-%d").alias("date_str"),
    pl.col("datetime").dt.strftime("%B %d, %Y").alias("formatted"),
    pl.col("datetime").dt.to_string("%Y-%m-%d %H:%M").alias("str"),
)
```

### Truncation (Rounding Down)

```python
df.with_columns(
    pl.col("datetime").dt.truncate("1h").alias("hour_start"),
    pl.col("datetime").dt.truncate("1d").alias("day_start"),
    pl.col("datetime").dt.truncate("1w").alias("week_start"),
    pl.col("datetime").dt.truncate("1mo").alias("month_start"),
)
```

### Date/Time Arithmetic

```python
df.with_columns(
    # Add duration
    (pl.col("date") + pl.duration(days=7)).alias("next_week"),
    (pl.col("datetime") + pl.duration(hours=2)).alias("plus_2h"),
    
    # Subtract dates (returns Duration)
    (pl.col("end_date") - pl.col("start_date")).alias("duration"),
    
    # Duration to days/hours
    (pl.col("end_date") - pl.col("start_date")).dt.total_days().alias("days"),
    (pl.col("end_date") - pl.col("start_date")).dt.total_hours().alias("hours"),
)

# Duration literals
pl.duration(days=1)
pl.duration(hours=2, minutes=30)
pl.duration(weeks=1)
```

### Timezone Handling

```python
df.with_columns(
    # Set timezone (localize)
    pl.col("datetime").dt.replace_time_zone("UTC"),
    
    # Convert between timezones
    pl.col("datetime").dt.convert_time_zone("America/New_York"),
    
    # Remove timezone
    pl.col("datetime").dt.replace_time_zone(None),
)
```

### Filtering by Date

```python
# Date comparisons
df.filter(pl.col("date") > pl.date(2024, 1, 1))
df.filter(pl.col("date").is_between(pl.date(2024, 1, 1), pl.date(2024, 12, 31)))

# Filter by component
df.filter(pl.col("datetime").dt.year() == 2024)
df.filter(pl.col("datetime").dt.month() == 7)
df.filter(pl.col("datetime").dt.weekday() < 5)  # Weekdays only
```

### Creating Dates/Datetimes

```python
# Date literals
pl.date(2024, 7, 15)

# Datetime literals
pl.datetime(2024, 7, 15, 14, 30, 0)

# From columns
df.with_columns(
    pl.datetime(
        pl.col("year"),
        pl.col("month"),
        pl.col("day")
    ).alias("date")
)

# Date range
pl.date_range(
    start=pl.date(2024, 1, 1),
    end=pl.date(2024, 12, 31),
    interval="1d",
    eager=True
)
```

## Categorical Data

Categorical type stores strings as integers for memory efficiency.

### Creating Categorical

```python
df.with_columns(
    pl.col("category").cast(pl.Categorical)
)

# Or on read
df = pl.read_csv("data.csv", dtypes={"category": pl.Categorical})
```

### Enum Type (Fixed Categories)

For known, fixed set of categories:

```python
# Define enum type
status_type = pl.Enum(["pending", "active", "completed", "cancelled"])

df.with_columns(
    pl.col("status").cast(status_type)
)

# Enum is stricter - errors on unknown values
```

### StringCache (Consistent Categories)

When working with multiple DataFrames with same categorical column:

```python
# Without StringCache, categories may not match between DataFrames
with pl.StringCache():
    df1 = pl.DataFrame({"cat": ["a", "b"]}).with_columns(
        pl.col("cat").cast(pl.Categorical)
    )
    df2 = pl.DataFrame({"cat": ["b", "c"]}).with_columns(
        pl.col("cat").cast(pl.Categorical)
    )
    
    # Now can safely concatenate or join
    combined = pl.concat([df1, df2])
```

### Categorical Operations

```python
df.with_columns(
    # Get physical (integer) representation
    pl.col("category").to_physical().alias("cat_code"),
    
    # Get categories
    pl.col("category").cat.get_categories().alias("categories"),
)

# Sort by categorical order (not alphabetically)
df.sort("category")
```

### Converting Back to String

```python
df.with_columns(
    pl.col("category").cast(pl.String)
)
```

## Summary

### String Functions

| Operation | Code |
|-----------|------|
| Uppercase | `pl.col("s").str.to_uppercase()` |
| Contains | `pl.col("s").str.contains("x")` |
| Replace | `pl.col("s").str.replace_all("a", "b")` |
| Split | `pl.col("s").str.split(",")` |
| Extract | `pl.col("s").str.extract(r"(\d+)")` |
| Length | `pl.col("s").str.len_chars()` |
| Trim | `pl.col("s").str.strip_chars()` |
| Concat | `pl.concat_str(["a", "b"], separator=" ")` |

### Datetime Functions

| Operation | Code |
|-----------|------|
| Parse | `pl.col("s").str.strptime(pl.Datetime, "%Y-%m-%d")` |
| Year | `pl.col("dt").dt.year()` |
| Month | `pl.col("dt").dt.month()` |
| Weekday | `pl.col("dt").dt.weekday()` |
| Format | `pl.col("dt").dt.strftime("%Y-%m-%d")` |
| Truncate | `pl.col("dt").dt.truncate("1d")` |
| Add time | `pl.col("dt") + pl.duration(days=7)` |
| Diff | `(pl.col("end") - pl.col("start")).dt.total_days()` |

### Categorical

| Operation | Code |
|-----------|------|
| Cast to categorical | `pl.col("c").cast(pl.Categorical)` |
| Use enum | `pl.col("c").cast(pl.Enum(["a", "b"]))` |
| Get codes | `pl.col("c").to_physical()` |
| Use StringCache | `with pl.StringCache(): ...` |
