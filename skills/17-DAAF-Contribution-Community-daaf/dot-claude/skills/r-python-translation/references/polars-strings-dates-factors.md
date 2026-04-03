# Polars for R Users: String, Date/Time, and Categorical Operations

> **Companion file:** For core data manipulation (dplyr verbs, joins, reshaping,
> window functions, piping, lazy evaluation), see `polars-dplyr.md`.

This document provides translations between R's type-specific tidyverse packages
(stringr, lubridate, forcats) and Python's polars library for string, date/time,
and categorical operations. These are the operations you reach for when working
with specific column types rather than general data wrangling. Also includes a
data.table sidebar for R users coming from that ecosystem.

> **Versions referenced:**
> Python: polars 1.38.1
> R: dplyr 1.2.0, tidyr 1.3.2, stringr 1.6.0, lubridate 1.9.5, forcats 1.0.1, data.table 1.18.2
> See SKILL.md § Library Versions for the complete version table.

> **Sources:** stringr 1.5.x documentation (stringr.tidyverse.org, accessed 2026-03-28);
> lubridate 1.9.x documentation (lubridate.tidyverse.org, accessed 2026-03-28);
> forcats 1.0.x documentation (forcats.tidyverse.org, accessed 2026-03-28);
> data.table 1.15.x documentation (rdatatable.gitlab.io, accessed 2026-03-28);
> Polars 1.x User Guide and API Reference (docs.pola.rs, accessed 2026-03-28);
> Wickham et al., *R for Data Science* 2nd ed. (2023).

---

## Section 1: String Operations (stringr to polars .str)

All polars string operations are accessed via the `.str` namespace on an expression.

### Detection and Matching

| stringr (R) | polars .str | Notes |
|-------------|------------|-------|
| `str_detect(x, "pat")` | `pl.col("x").str.contains("pat")` | Returns boolean |
| `str_starts(x, "pre")` | `pl.col("x").str.starts_with("pre")` | |
| `str_ends(x, "suf")` | `pl.col("x").str.ends_with("suf")` | |
| `str_count(x, "pat")` | `pl.col("x").str.count_matches("pat")` | |

```r
# R
df %>% mutate(has_digit = str_detect(name, "\\d"))
```

```python
# polars
df.with_columns(pl.col("name").str.contains(r"\d").alias("has_digit"))
```

### Replacement

| stringr (R) | polars .str | Notes |
|-------------|------------|-------|
| `str_replace(x, "old", "new")` | `pl.col("x").str.replace("old", "new")` | First match only |
| `str_replace_all(x, "old", "new")` | `pl.col("x").str.replace_all("old", "new")` | All matches |
| `str_remove(x, "pat")` | `pl.col("x").str.replace("pat", "")` | |
| `str_remove_all(x, "pat")` | `pl.col("x").str.replace_all("pat", "")` | |

```r
# R
df %>% mutate(clean = str_replace_all(text, "\\s+", " "))
```

```python
# polars
df.with_columns(pl.col("text").str.replace_all(r"\s+", " ").alias("clean"))
```

### Extraction

| stringr (R) | polars .str | Notes |
|-------------|------------|-------|
| `str_extract(x, "(\\d+)")` | `pl.col("x").str.extract(r"(\d+)", group_index=1)` | First match; group_index selects capture group |
| `str_extract_all(x, "\\d+")` | `pl.col("x").str.extract_all(r"\d+")` | Returns list column |
| `str_match(x, "(\\w+):(\\d+)")` | `pl.col("x").str.extract_groups(r"(?P<key>\w+):(?P<val>\d+)")` | Named groups return struct |

```r
# R
df %>% mutate(year = str_extract(date_str, "\\d{4}"))
```

```python
# polars
df.with_columns(pl.col("date_str").str.extract(r"(\d{4})", group_index=1).alias("year"))
```

### Case Transformation

| stringr (R) | polars .str | Notes |
|-------------|------------|-------|
| `str_to_lower(x)` | `pl.col("x").str.to_lowercase()` | |
| `str_to_upper(x)` | `pl.col("x").str.to_uppercase()` | |
| `str_to_title(x)` | `pl.col("x").str.to_titlecase()` | |

```r
# R
df %>% mutate(name_upper = str_to_upper(name))
```

```python
# polars
df.with_columns(pl.col("name").str.to_uppercase().alias("name_upper"))
```

### Trimming

| stringr (R) | polars .str | Notes |
|-------------|------------|-------|
| `str_trim(x)` | `pl.col("x").str.strip_chars()` | Both ends |
| `str_trim(x, "left")` | `pl.col("x").str.strip_chars_start()` | Left only |
| `str_trim(x, "right")` | `pl.col("x").str.strip_chars_end()` | Right only |
| `str_squish(x)` | `.str.strip_chars().str.replace_all(r"\s+", " ")` | No single method |

```r
# R
df %>% mutate(clean = str_trim(name))
```

```python
# polars
df.with_columns(pl.col("name").str.strip_chars().alias("clean"))
```

### Padding

| stringr (R) | polars .str | Notes |
|-------------|------------|-------|
| `str_pad(x, 5, "left", "0")` | `pl.col("x").str.pad_start(5, "0")` | |
| `str_pad(x, 10, "right", " ")` | `pl.col("x").str.pad_end(10, " ")` | |
| `str_pad(x, 5, "left", "0")` | `pl.col("x").str.zfill(5)` | Zero-fill shorthand |

```r
# R
df %>% mutate(code = str_pad(fips, 5, "left", "0"))
```

```python
# polars
df.with_columns(pl.col("fips").str.zfill(5).alias("code"))
```

### Length and Substrings

| stringr (R) | polars .str | Notes |
|-------------|------------|-------|
| `str_length(x)` | `pl.col("x").str.len_chars()` | Character count |
| `nchar(x)` | `pl.col("x").str.len_bytes()` | Byte count (faster, ASCII-safe) |
| `str_sub(x, 1, 3)` | `pl.col("x").str.slice(0, 3)` | 0-indexed offset |
| `str_sub(x, -3)` | `pl.col("x").str.slice(-3)` | From 3rd-to-last |

```r
# R
df %>% mutate(prefix = str_sub(code, 1, 2))
```

```python
# polars -- 0-indexed: offset=0, length=2
df.with_columns(pl.col("code").str.slice(0, 2).alias("prefix"))
```

R's `str_sub(x, 1, 3)` extracts characters 1-3 (1-indexed, inclusive). Polars'
`str.slice(0, 3)` starts at offset 0 and takes 3 characters. The results are
identical but the indexing convention differs.

### Concatenation

| stringr (R) | polars | Notes |
|-------------|--------|-------|
| `str_c(x, y, sep = "_")` | `pl.concat_str(["x", "y"], separator="_")` | |
| `paste0(x, y)` | `pl.concat_str(["x", "y"], separator="")` | |
| `paste(x, y, sep = " ")` | `pl.concat_str(["x", "y"], separator=" ")` | |
| `str_glue("{x}_{y}")` | `pl.concat_str(["x", "y"], separator="_")` | No interpolation equivalent |

```r
# R
df %>% mutate(full_name = str_c(first, last, sep = " "))
```

```python
# polars
df.with_columns(
    pl.concat_str(["first", "last"], separator=" ").alias("full_name")
)
```

### Split

| stringr (R) | polars .str | Notes |
|-------------|------------|-------|
| `str_split(x, ",")` | `pl.col("x").str.split(",")` | Returns list column |
| `str_split_fixed(x, ",", 3)` | `pl.col("x").str.split_exact(",", 2)` | Returns struct; n = n_splits (0-based count) |

```r
# R
df %>% mutate(parts = str_split(tags, ","))
```

```python
# polars
df.with_columns(pl.col("tags").str.split(",").alias("parts"))
```

---

## Section 2: Date/Time Operations (lubridate to polars .dt)

All polars date/time operations are accessed via the `.dt` namespace.

### Parsing Dates

| lubridate (R) | polars | Notes |
|---------------|--------|-------|
| `ymd("2020-01-15")` | `pl.col("x").str.strptime(pl.Date, "%Y-%m-%d")` | Explicit format required |
| `mdy("01/15/2020")` | `pl.col("x").str.strptime(pl.Date, "%m/%d/%Y")` | |
| `dmy("15-01-2020")` | `pl.col("x").str.strptime(pl.Date, "%d-%m-%Y")` | |
| `ymd_hms("2020-01-15 14:30:00")` | `pl.col("x").str.strptime(pl.Datetime, "%Y-%m-%d %H:%M:%S")` | |
| `as_date(x)` | `pl.col("x").cast(pl.Date)` | If already temporal |
| `parse_date_time(x, "Ymd")` | `pl.col("x").str.to_datetime()` | Auto-detect format |

```r
# R
df %>% mutate(date = ymd(date_str))
```

```python
# polars
df.with_columns(
    pl.col("date_str").str.strptime(pl.Date, "%Y-%m-%d").alias("date")
)
```

Lubridate's `ymd()` is flexible about separators (accepts "2020-01-15",
"2020/01/15", "20200115"). Polars `strptime` requires an exact format string. For
flexible parsing, use `str.to_datetime()` which attempts auto-detection, but
explicit formats are more reliable.

### Extracting Components

| lubridate (R) | polars .dt | Notes |
|---------------|-----------|-------|
| `year(x)` | `pl.col("x").dt.year()` | |
| `month(x)` | `pl.col("x").dt.month()` | Integer 1-12 |
| `month(x, label = TRUE)` | `.dt.month()` then map | No direct label option |
| `day(x)` | `pl.col("x").dt.day()` | |
| `hour(x)` | `pl.col("x").dt.hour()` | |
| `minute(x)` | `pl.col("x").dt.minute()` | |
| `second(x)` | `pl.col("x").dt.second()` | |
| `wday(x)` | `pl.col("x").dt.weekday()` | 1=Mon to 7=Sun in polars |
| `wday(x, label = TRUE)` | `.dt.weekday()` then map | No direct label option |
| `week(x)` | `pl.col("x").dt.week()` | ISO week |
| `yday(x)` | `pl.col("x").dt.ordinal_day()` | Day of year (1-366) |
| `quarter(x)` | `pl.col("x").dt.quarter()` | 1-4 |

```r
# R
df %>% mutate(yr = year(date), mo = month(date))
```

```python
# polars
df.with_columns(
    pl.col("date").dt.year().alias("yr"),
    pl.col("date").dt.month().alias("mo"),
)
```

Weekday numbering differs: lubridate's `wday()` returns 1=Sunday by default
(configurable with `week_start`); polars' `.dt.weekday()` returns 1=Monday through
7=Sunday (ISO standard).

### Rounding / Truncating

| lubridate (R) | polars .dt | Notes |
|---------------|-----------|-------|
| `floor_date(x, "month")` | `pl.col("x").dt.truncate("1mo")` | |
| `floor_date(x, "week")` | `pl.col("x").dt.truncate("1w")` | |
| `floor_date(x, "year")` | `pl.col("x").dt.truncate("1y")` | |
| `floor_date(x, "day")` | `pl.col("x").dt.truncate("1d")` | |
| `floor_date(x, "hour")` | `pl.col("x").dt.truncate("1h")` | |
| `ceiling_date(x, "month")` | No direct `ceiling`; manual | See below |
| `round_date(x, "month")` | No direct `round`; manual | See below |

```r
# R
df %>% mutate(month_start = floor_date(date, "month"))
```

```python
# polars
df.with_columns(pl.col("date").dt.truncate("1mo").alias("month_start"))
```

Polars has `dt.truncate()` for flooring. There is no built-in ceiling or rounding
equivalent; implement manually by truncating then adding one unit.

### Date Arithmetic

| lubridate (R) | polars | Notes |
|---------------|--------|-------|
| `x + days(5)` | `pl.col("x") + pl.duration(days=5)` | |
| `x + months(1)` | `pl.col("x").dt.offset_by("1mo")` | Months need `offset_by` |
| `x + years(1)` | `pl.col("x").dt.offset_by("1y")` | Years need `offset_by` |
| `x + hours(2)` | `pl.col("x") + pl.duration(hours=2)` | |
| `x - y` (dates) | `pl.col("x") - pl.col("y")` | Returns Duration |
| `as.numeric(x - y, "days")` | `(pl.col("x") - pl.col("y")).dt.total_days()` | |
| `difftime(x, y, units = "hours")` | `(pl.col("x") - pl.col("y")).dt.total_hours()` | |

```r
# R
df %>% mutate(
  next_week = date + days(7),
  duration_days = as.numeric(end - start, "days")
)
```

```python
# polars
df.with_columns(
    (pl.col("date") + pl.duration(days=7)).alias("next_week"),
    (pl.col("end") - pl.col("start")).dt.total_days().alias("duration_days"),
)
```

Note on month/year arithmetic: `pl.duration()` does not support months or years
(because they are not fixed-length). Use `.dt.offset_by("1mo")` or
`.dt.offset_by("1y")` instead.

### Interval Operations

```r
# R (lubridate)
int <- interval(ymd("2020-01-01"), ymd("2020-12-31"))
x %within% int
```

```python
# polars -- no interval object; use is_between
df.filter(pl.col("x").is_between(pl.date(2020, 1, 1), pl.date(2020, 12, 31)))
```

### Creating Date Sequences

```r
# R
seq(as.Date("2020-01-01"), as.Date("2020-12-31"), by = "month")
```

```python
# polars
pl.date_range(pl.date(2020, 1, 1), pl.date(2020, 12, 31), interval="1mo", eager=True)
```

### Formatting Dates to Strings

```r
# R
df %>% mutate(label = format(date, "%B %d, %Y"))
```

```python
# polars
df.with_columns(pl.col("date").dt.strftime("%B %d, %Y").alias("label"))
```

---

## Section 3: data.table Sidebar

For R users who prefer data.table over dplyr, polars' expression model may feel
more natural. Both data.table and polars emphasize performance, lazy-like
optimization, and concise syntax.

### Syntax Comparison: DT[i, j, by]

```r
# R (data.table)
DT[year == 2020, .(avg = mean(x), n = .N), by = state]
```

```python
# polars
(
    df
    .filter(pl.col("year") == 2020)
    .group_by("state")
    .agg(
        pl.col("x").mean().alias("avg"),
        pl.len().alias("n"),
    )
)
```

### Core Mapping

| data.table | polars | Notes |
|------------|--------|-------|
| `DT[i]` (row filter) | `df.filter(...)` | |
| `DT[, j]` (select/compute) | `df.select(...)` / `df.with_columns(...)` | |
| `DT[, , by]` (group) | `df.group_by(...).agg(...)` | |
| `DT[, x := y * 2]` (modify in place) | `df.with_columns(...)` | polars is immutable |
| `DT[, .N, by = g]` | `df.group_by("g").len()` | |
| `DT[, .SD, .SDcols = cols]` | `df.select(cols)` | |
| `DT[order(-x)]` | `df.sort("x", descending=True)` | |
| `fread("file.csv")` | `pl.read_csv("file.csv")` | |
| `DT[, shift(x, 1), by = g]` | `pl.col("x").shift(1).over("g")` | |
| `DT[DT2, on = "key"]` (join) | `df.join(df2, on="key", how="left")` | |
| `DT[, .I[which.max(x)], by = g]` | `df.sort("x", descending=True).group_by("g").head(1)` | |

### Why data.table Users May Find Polars Intuitive

Both share key design principles:
- **Performance-first**: written in compiled languages (C for data.table, Rust for polars)
- **Expression-oriented**: you describe *what* to compute, not *how*
- **Implicit optimization**: both reorder and optimize operations internally
- **No row index**: neither uses an explicit row index (unlike pandas)
- **Reference semantics**: data.table modifies in place with `:=`; polars returns new
  DataFrames but optimizes memory via copy-on-write

The main adjustment for data.table users: polars separates `i`, `j`, and `by` into
distinct method calls (`filter`, `select`/`with_columns`, `group_by`) rather than
packing them into `DT[i, j, by]`.

### Chained Operations

```r
# R (data.table)
DT[year == 2020
  ][, rate := count / total
  ][, .(avg_rate = mean(rate)), by = state
  ][order(-avg_rate)]
```

```python
# polars
(
    df
    .filter(pl.col("year") == 2020)
    .with_columns((pl.col("count") / pl.col("total")).alias("rate"))
    .group_by("state")
    .agg(pl.col("rate").mean().alias("avg_rate"))
    .sort("avg_rate", descending=True)
)
```

---

## Section 4: Categorical / Factor Operations (forcats to polars)

R's forcats package manipulates factors (categorical variables with ordered levels).
Polars has `pl.Categorical` and `pl.Enum` types that serve a similar purpose.

### Creating Factors / Categoricals

```r
# R
df %>% mutate(status = factor(status))
df %>% mutate(status = factor(status, levels = c("low", "med", "high")))
```

```python
# polars -- unordered categorical
df.with_columns(pl.col("status").cast(pl.Categorical))

# polars -- ordered / fixed-level categorical (Enum)
status_type = pl.Enum(["low", "med", "high"])
df.with_columns(pl.col("status").cast(status_type))
```

### Common forcats Operations

| forcats (R) | polars | Notes |
|-------------|--------|-------|
| `fct_relevel(x, "a", "b")` | Cast to `pl.Enum(["a", "b", ...])` | Explicit level ordering |
| `fct_reorder(x, y, mean)` | Sort then cast; no single equivalent | Manual pattern |
| `fct_recode(x, new = "old")` | `.replace({"old": "new"}).cast(pl.Categorical)` | Map + recast |
| `fct_collapse(x, grp = c("a","b"))` | `.replace({"a": "grp", "b": "grp"})` | |
| `fct_lump_n(x, 5)` | Manual: count, identify top 5, replace rest | No direct equivalent |
| `fct_rev(x)` | Reverse the Enum level list | |
| `fct_infreq(x)` | Sort by frequency then cast to Enum | Manual pattern |
| `fct_drop(x)` | Recast to remove unused levels | |
| `as.numeric(x)` (factor codes) | `pl.col("x").to_physical()` | Integer representation |
| `levels(x)` | `pl.col("x").cat.get_categories()` | |

**Lump infrequent levels into "Other":**

```r
# R (forcats)
df %>% mutate(category = fct_lump_n(category, 5))
```

```python
# polars -- manual pattern
top5 = (
    df.group_by("category").len()
    .sort("len", descending=True)
    .head(5)
    .get_column("category")
    .to_list()
)
df.with_columns(
    pl.when(pl.col("category").is_in(top5))
      .then(pl.col("category"))
      .otherwise(pl.lit("Other"))
      .alias("category")
)
```

**Reorder factor by another variable:**

```r
# R (forcats)
df %>% mutate(state = fct_reorder(state, population, .fun = median))
```

```python
# polars -- compute ordering, then sort or use Enum
ordering = (
    df.group_by("state")
    .agg(pl.col("population").median().alias("med_pop"))
    .sort("med_pop")
    .get_column("state")
    .to_list()
)
state_type = pl.Enum(ordering)
df.with_columns(pl.col("state").cast(state_type))
```

---

## Quick Reference Table

A condensed lookup for type-specific operation translations:

| R (tidyverse) | polars | Category |
|---------------|--------|----------|
| `str_detect(x, "p")` | `.str.contains("p")` | String |
| `str_replace_all(x, "a", "b")` | `.str.replace_all("a", "b")` | String |
| `str_extract(x, "(\\d+)")` | `.str.extract(r"(\d+)", group_index=1)` | String |
| `str_to_lower(x)` | `.str.to_lowercase()` | String |
| `str_trim(x)` | `.str.strip_chars()` | String |
| `str_pad(x, 5, "left", "0")` | `.str.zfill(5)` | String |
| `str_c(x, y, sep="_")` | `pl.concat_str(["x","y"], separator="_")` | String |
| `year(x)` | `.dt.year()` | DateTime |
| `month(x)` | `.dt.month()` | DateTime |
| `ymd(x)` | `.str.strptime(pl.Date, "%Y-%m-%d")` | DateTime |
| `floor_date(x, "month")` | `.dt.truncate("1mo")` | DateTime |
| `x + days(7)` | `+ pl.duration(days=7)` | DateTime |
| `x + months(1)` | `.dt.offset_by("1mo")` | DateTime |
| `factor(x, levels=...)` | `.cast(pl.Enum([...]))` | Categorical |
| `fct_recode(x, new="old")` | `.replace({"old": "new"})` | Categorical |
| `fct_lump_n(x, 5)` | Manual top-N + replace | Categorical |
