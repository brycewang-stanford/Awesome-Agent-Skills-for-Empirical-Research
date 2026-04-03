# Strings, Dates, and Labels: Stata to Python (polars)

> **Companion file:** For core data management (generate, replace, keep/drop,
> sorting, group operations, merging, reshaping, collapse, duplicates, missing
> values), see `data-management.md`.

This document translates Stata's string functions, date/time system, and value label
infrastructure to Python's polars library. These are the operations you reach for
when working with specific column types rather than general data wrangling. Stata's
string functions are standalone functions applied to columns; polars accesses them
via the `.str` namespace on expressions. Stata's date system stores dates as plain
integers with display formatting; Python uses typed Date/Datetime objects. Stata's
value label system has no direct Python equivalent and requires explicit workarounds.

> **Versions referenced:**
> Python: polars 1.38.1, pyreadstat 1.2.x
> See SKILL.md for the complete version table.

> **Sources:** Sullivan, "Stata to Python Equivalents" (danielmsullivan.com, accessed
> 2026-03-28); Turrell, "Coming from Stata" in *Coding for Economists*
> (aeturrell.github.io, accessed 2026-03-28); SSCC/UW-Madison, "Working with Text Data
> in Stata" (sscc.wisc.edu, accessed 2026-03-28); Stata Blog, "A tour of datetime in
> Stata" (blog.stata.com, 2015); polars 1.x User Guide and API Reference
> (docs.pola.rs, accessed 2026-03-28); pyreadstat (github.com/Roche/pyreadstat,
> accessed 2026-03-28).

---

## Section 1: String Operations

All polars string operations are accessed via the `.str` namespace on an expression.
Stata string functions are standalone functions that take a string argument.

### Detection and Matching

| Stata | polars `.str` | Notes |
|-------|--------------|-------|
| `strpos(s, "pat") > 0` | `pl.col("s").str.contains("pat")` | Returns boolean (polars) vs position (Stata) |
| `strmatch(s, "pat*")` | `pl.col("s").str.contains("^pat")` | Stata uses glob; polars uses regex |
| `regexm(s, "pat")` | `pl.col("s").str.contains("pat")` | Returns boolean |
| `ustrpos(s, "pat")` | `pl.col("s").str.find("pat")` | Unicode-aware; returns index (-1 if not found in polars, 0 if not found in Stata) |

```stata
* Stata
gen has_elem = regexm(school_type, "Elementary")
gen pos = strpos(name, "Academy")
```

```python
# polars
df = df.with_columns(
    pl.col("school_type").str.contains("Elementary").alias("has_elem"),
    pl.col("name").str.find("Academy").alias("pos"),
)
```

> **Key behavioral difference:** Stata's `strpos()` returns the position (1-based,
> 0 if not found). Polars' `str.find()` returns the byte offset (0-based, -1 if not
> found). For boolean detection, use `str.contains()` which returns `True`/`False`.

### Replacement

| Stata | polars `.str` | Notes |
|-------|--------------|-------|
| `subinstr(s, "old", "new", 1)` | `pl.col("s").str.replace("old", "new")` | First match only |
| `subinstr(s, "old", "new", .)` | `pl.col("s").str.replace_all("old", "new")` | All matches |
| `regexr(s, "pat", "new")` | `pl.col("s").str.replace("pat", "new")` | Regex replacement (first match) |

```stata
* Stata
replace phone = subinstr(phone, "-", "", .)
replace name = regexr(name, "^The ", "")
```

```python
# polars
df = df.with_columns(
    pl.col("phone").str.replace_all("-", ""),
    pl.col("name").str.replace("^The ", ""),
)
```

> **Key behavioral difference:** Stata's `subinstr` with `.` (missing) as the count
> replaces ALL occurrences. Polars distinguishes `replace` (first) vs `replace_all`.
> When migrating Stata code, check whether `subinstr` uses `.` as the count --
> if so, use `replace_all`.

### Extraction

| Stata | polars `.str` | Notes |
|-------|--------------|-------|
| `substr(s, n1, n2)` | `pl.col("s").str.slice(n1-1, n2)` | 0-based offset in polars |
| `regexs(n)` (after `regexm`) | `pl.col("s").str.extract(r"(pat)", group_index=n)` | Combined match + extract |
| `word(s, n)` | `pl.col("s").str.split(" ").list.get(n-1)` | 0-based indexing in polars |
| `word(s, -1)` | `pl.col("s").str.split(" ").list.last()` | Last word |

```stata
* Stata
gen state_abbr = substr(fips_code, 1, 2)
gen has_year = regexm(filename, "([0-9]{4})")
gen year_str = regexs(1)
gen first_word = word(address, 1)
gen last_word = word(address, -1)
```

```python
# polars
df = df.with_columns(
    pl.col("fips_code").str.slice(0, 2).alias("state_abbr"),
    pl.col("filename").str.extract(r"(\d{4})", group_index=1).alias("year_str"),
    pl.col("address").str.split(" ").list.first().alias("first_word"),
    pl.col("address").str.split(" ").list.last().alias("last_word"),
)
```

> **Key behavioral difference:** Stata's `regexm` + `regexs` is a two-step process
> (match, then extract). Polars' `str.extract()` does both in one call. Also, Stata's
> `substr(s, 1, 2)` extracts starting at position 1 (1-indexed). Polars'
> `str.slice(0, 2)` starts at offset 0 (0-indexed). The results are identical but
> the indexing convention differs.

### Case Transformation

| Stata | polars `.str` | Notes |
|-------|--------------|-------|
| `strlower(s)` | `pl.col("s").str.to_lowercase()` | |
| `strupper(s)` | `pl.col("s").str.to_uppercase()` | |
| `strproper(s)` | `pl.col("s").str.to_titlecase()` | |

```stata
* Stata
gen clean_name = strproper(strtrim(strlower(name)))
```

```python
# polars -- method chaining reads left-to-right (easier to follow)
df = df.with_columns(
    pl.col("name").str.to_lowercase().str.strip_chars().str.to_titlecase()
      .alias("clean_name")
)
```

### Trimming

| Stata | polars `.str` | Notes |
|-------|--------------|-------|
| `strtrim(s)` | `pl.col("s").str.strip_chars()` | Both ends |
| `strltrim(s)` | `pl.col("s").str.strip_chars_start()` | Left only |
| `strrtrim(s)` | `pl.col("s").str.strip_chars_end()` | Right only |
| `stritrim(s)` | `.str.strip_chars().str.replace_all(r"\s+", " ")` | Collapse internal spaces (no single method) |

```stata
* Stata
gen clean = stritrim(strtrim(name))
```

```python
# polars -- replicate stritrim (trim + collapse internal whitespace)
df = df.with_columns(
    pl.col("name").str.strip_chars().str.replace_all(r"\s+", " ").alias("clean")
)
```

### Length

| Stata | polars `.str` | Notes |
|-------|--------------|-------|
| `strlen(s)` | `pl.col("s").str.len_bytes()` | Byte count |
| `ustrlen(s)` | `pl.col("s").str.len_chars()` | Character count (Unicode-aware) |

```stata
* Stata
gen name_len = ustrlen(school_name)
```

```python
# polars
df = df.with_columns(pl.col("school_name").str.len_chars().alias("name_len"))
```

For ASCII-only data, `len_bytes()` and `len_chars()` return the same value.
`len_bytes()` is faster when Unicode is not a concern.

### Padding (Zero-Fill)

| Stata | polars `.str` | Notes |
|-------|--------------|-------|
| `string(n, "%05.0f")` | `pl.col("s").str.zfill(5)` | Zero-pad to 5 characters |
| (manual pad) | `pl.col("s").str.pad_start(5, "0")` | General left-pad |
| (manual pad) | `pl.col("s").str.pad_end(10, " ")` | General right-pad |

```stata
* Stata -- zero-fill FIPS codes
gen fips5 = string(fips_num, "%05.0f")
```

```python
# polars
df = df.with_columns(
    pl.col("fips_num").cast(pl.Utf8).str.zfill(5).alias("fips5")
)
```

### Concatenation

| Stata | polars | Notes |
|-------|--------|-------|
| `s1 + s2` | `pl.concat_str(["s1", "s2"], separator="")` | |
| `s1 + " " + s2` | `pl.concat_str(["s1", "s2"], separator=" ")` | |
| (no direct equivalent) | `pl.concat_str(["s1", "s2"], separator="_")` | Custom separator |

```stata
* Stata
gen full_name = first_name + " " + last_name
gen geo_key = state_fips + county_fips
```

```python
# polars
df = df.with_columns(
    pl.concat_str(["first_name", "last_name"], separator=" ").alias("full_name"),
    pl.concat_str(["state_fips", "county_fips"], separator="").alias("geo_key"),
)
```

### Split

| Stata | polars `.str` | Notes |
|-------|--------------|-------|
| (no built-in split) | `pl.col("s").str.split(",")` | Returns list column |
| (manual parsing) | `pl.col("s").str.split_exact(",", 2)` | Returns struct; n = number of splits |

```stata
* Stata -- manual word parsing
gen part1 = word(tags, 1)
gen part2 = word(tags, 2)
```

```python
# polars -- split into list, then extract elements
df = df.with_columns(
    pl.col("tags").str.split(",").list.get(0).alias("part1"),
    pl.col("tags").str.split(",").list.get(1).alias("part2"),
)
```

### Regex Operations (Complete)

| Stata | polars `.str` | Notes |
|-------|--------------|-------|
| `regexm(s, "pat")` | `pl.col("s").str.contains("pat")` | Boolean match |
| `regexs(n)` | `pl.col("s").str.extract(r"(pat)", group_index=n)` | Capture group extraction |
| `regexr(s, "pat", "rep")` | `pl.col("s").str.replace("pat", "rep")` | Replace first match |
| `ustrregexm(s, "pat")` | `pl.col("s").str.contains("pat")` | Unicode-aware (polars is always Unicode-aware) |
| `ustrregexs(n)` | `pl.col("s").str.extract(r"(pat)", group_index=n)` | Unicode-aware extraction |
| `ustrregexra(s, "pat", "rep")` | `pl.col("s").str.replace_all("pat", "rep")` | Unicode-aware replace-all |

```stata
* Stata
gen has_year = regexm(filename, "[0-9]{4}")
gen year_val = regexs(0) if has_year
replace name = regexr(name, "^(The|An?) ", "")
```

```python
# polars -- combined match and extract in one step
df = df.with_columns(
    pl.col("filename").str.contains(r"\d{4}").alias("has_year"),
    pl.col("filename").str.extract(r"(\d{4})", group_index=1).alias("year_val"),
    pl.col("name").str.replace(r"^(The|An?) ", ""),
)
```

### Type Conversion (String <-> Numeric)

| Stata | polars | Notes |
|-------|--------|-------|
| `string(n)` | `pl.col("n").cast(pl.Utf8)` | Number to string |
| `string(n, "%9.2f")` | `pl.col("n").round(2).cast(pl.Utf8)` | Formatted |
| `real(s)` | `pl.col("s").cast(pl.Float64)` | String to number |
| `real(s)` (with invalid) | `pl.col("s").cast(pl.Float64, strict=False)` | Invalid becomes null |

```stata
* Stata
gen income_str = string(income, "%12.2f")
gen fips_num = real(fips_str)
```

```python
# polars
df = df.with_columns(
    pl.col("income").round(2).cast(pl.Utf8).alias("income_str"),
    pl.col("fips_str").cast(pl.Float64, strict=False).alias("fips_num"),
)
```

**Sources:** SSCC/UW-Madison, "Working with Text Data in Stata" (sscc.wisc.edu,
accessed 2026-03-28); StataTex Blog, "Useful string functions in Stata"
(statatexblog.com, 2022); polars User Guide, "String processing" (docs.pola.rs,
accessed 2026-03-28); Stata manuals, "String functions" (stata.com/manuals).

---

## Section 2: Date System

This section is critical because Stata's date system is fundamentally different from
Python's. Stata dates are plain integers with display formatting; Python dates are
typed objects. Getting this wrong produces silent data errors.

### Stata's Date Model

Stata dates are **integers** counting from an epoch of **January 1, 1960**:

| Stata Date Type | Storage Unit | Format | Example: epoch value 0 |
|-----------------|-------------|--------|----------------------|
| Daily (`%td`) | Days since 1960-01-01 | `%td` | 01jan1960 |
| Clock (`%tc`) | Milliseconds since 1960-01-01 00:00:00 | `%tc` | 01jan1960 00:00:00 |
| Monthly (`%tm`) | Months since 1960m1 | `%tm` | 1960m1 |
| Quarterly (`%tq`) | Quarters since 1960q1 | `%tq` | 1960q1 |
| Weekly (`%tw`) | Weeks since 1960w1 | `%tw` | 1960w1 |
| Yearly (`%ty`) | Just the year number | `%ty` | 1960 |

Without a `%t` format applied, a Stata date variable displays as a raw integer
(e.g., `23350`), which is meaningless to a human. Python dates always display in
human-readable form.

### String-to-Date Parsing

| Stata | polars | Notes |
|-------|--------|-------|
| `date("March 15, 2024", "MDY")` | `pl.col("s").str.to_date("%B %d, %Y")` | Mask-based parsing |
| `date("2024-03-15", "YMD")` | `pl.col("s").str.to_date("%Y-%m-%d")` | ISO format |
| `date("15/03/2024", "DMY")` | `pl.col("s").str.to_date("%d/%m/%Y")` | European format |
| `clock("2024-03-15 14:30", "YMD hm")` | `pl.col("s").str.to_datetime("%Y-%m-%d %H:%M")` | Datetime parsing |
| `mdy(3, 15, 2024)` | (no direct equivalent -- build string then parse) | See below |
| `ym(2024, 3)` | (no direct equivalent) | See below |

```stata
* Stata
gen date = date(date_str, "YMD")
format date %td
gen datetime = clock(dt_str, "YMD hms")
format datetime %tc
```

```python
# polars
df = df.with_columns(
    pl.col("date_str").str.to_date("%Y-%m-%d").alias("date"),
    pl.col("dt_str").str.to_datetime("%Y-%m-%d %H:%M:%S").alias("datetime"),
)
```

> **Key behavioral difference:** Stata's `date()` function uses mask codes like
> "MDY", "YMD", "DMY" that are flexible about separators. Polars' `str.to_date()`
> requires an explicit strftime format string ("%m/%d/%Y"). Getting the format wrong
> produces null values silently in polars (no error raised by default).

### Building Dates from Components

Stata's `mdy(month, day, year)` constructs dates directly from numeric components.
Polars has no single equivalent -- build a string, then parse:

```stata
* Stata
gen date = mdy(month, day, year)
gen monthly = ym(year, month)
```

```python
# polars -- build from components via string intermediary
df = df.with_columns(
    pl.concat_str([
        pl.col("year").cast(pl.Utf8),
        pl.lit("-"),
        pl.col("month").cast(pl.Utf8).str.pad_start(2, "0"),
        pl.lit("-"),
        pl.col("day").cast(pl.Utf8).str.pad_start(2, "0"),
    ]).str.to_date("%Y-%m-%d").alias("date")
)

# For year-month only (first day of month):
df = df.with_columns(
    pl.concat_str([
        pl.col("year").cast(pl.Utf8),
        pl.lit("-"),
        pl.col("month").cast(pl.Utf8).str.pad_start(2, "0"),
        pl.lit("-01"),
    ]).str.to_date("%Y-%m-%d").alias("monthly")
)
```

### Extracting Date Components

| Stata | polars `.dt` | Notes |
|-------|-------------|-------|
| `year(date)` | `pl.col("date").dt.year()` | |
| `month(date)` | `pl.col("date").dt.month()` | Integer 1-12 |
| `day(date)` | `pl.col("date").dt.day()` | |
| `dow(date)` | `pl.col("date").dt.weekday()` | **Different numbering** -- see below |
| `doy(date)` | `pl.col("date").dt.ordinal_day()` | Day of year (1-366) |
| `quarter(date)` | `pl.col("date").dt.quarter()` | 1-4 |
| `week(date)` | `pl.col("date").dt.week()` | ISO week |
| `hour(datetime)` | `pl.col("dt").dt.hour()` | |
| `minute(datetime)` | `pl.col("dt").dt.minute()` | |
| `second(datetime)` | `pl.col("dt").dt.second()` | |

```stata
* Stata
gen yr = year(date)
gen mo = month(date)
gen d = day(date)
gen q = quarter(date)
gen day_of_week = dow(date)
```

```python
# polars
df = df.with_columns(
    pl.col("date").dt.year().alias("yr"),
    pl.col("date").dt.month().alias("mo"),
    pl.col("date").dt.day().alias("d"),
    pl.col("date").dt.quarter().alias("q"),
    pl.col("date").dt.weekday().alias("day_of_week"),
)
```

> **DAY-OF-WEEK NUMBERING TRAP:**
> - Stata's `dow()`: 0 = Sunday, 1 = Monday, ..., 6 = Saturday
> - Polars' `dt.weekday()`: 1 = Monday, 2 = Tuesday, ..., 7 = Sunday (ISO 8601)
>
> Code that branches on day-of-week will silently produce wrong results if the
> numbering difference is not accounted for.

### Date Conversion Functions (mofd, dofm, etc.)

Stata has functions to convert between date types (daily, monthly, quarterly):

| Stata | polars | Notes |
|-------|--------|-------|
| `mofd(date)` | `pl.col("date").dt.truncate("1mo")` | Daily to monthly (truncate) |
| `qofd(date)` | `pl.col("date").dt.truncate("3mo")` | Daily to quarterly |
| `yofd(date)` | `pl.col("date").dt.year()` | Daily to yearly |
| `dofm(monthly)` | (first day of month is already a Date) | Monthly to daily |
| `dofq(quarterly)` | (first day of quarter is already a Date) | Quarterly to daily |

```stata
* Stata
gen month_date = mofd(daily_date)
format month_date %tm
gen quarter_date = qofd(daily_date)
format quarter_date %tq
```

```python
# polars -- truncate to period start
df = df.with_columns(
    pl.col("daily_date").dt.truncate("1mo").alias("month_date"),
    pl.col("daily_date").dt.truncate("3mo").alias("quarter_date"),
)
```

> **Key behavioral difference:** In Stata, `mofd()` converts a daily date to a
> monthly integer (months since 1960m1). In polars, `dt.truncate("1mo")` keeps the
> value as a Date type but sets it to the first day of the month. There is no "monthly
> integer" type in polars -- months are represented as Date values at month boundaries.

### Date Arithmetic

| Stata | polars | Notes |
|-------|--------|-------|
| `date + 30` | `pl.col("date") + pl.duration(days=30)` | Add days |
| `date + 365` | `pl.col("date") + pl.duration(days=365)` | Approximate year |
| (add 1 month) | `pl.col("date").dt.offset_by("1mo")` | Calendar-aware month addition |
| (add 1 year) | `pl.col("date").dt.offset_by("1y")` | Calendar-aware year addition |
| `date2 - date1` | `pl.col("date2") - pl.col("date1")` | Returns Duration |
| `date2 - date1` (days) | `(pl.col("date2") - pl.col("date1")).dt.total_days()` | Integer days |
| `mofd(d2) - mofd(d1)` | See below | Months between dates |

```stata
* Stata -- date arithmetic is just integer arithmetic
gen next_month = date + 30
gen days_between = end_date - start_date
gen months_between = mofd(end_date) - mofd(start_date)
```

```python
# polars -- requires explicit duration objects for addition
df = df.with_columns(
    (pl.col("date") + pl.duration(days=30)).alias("next_month"),
    (pl.col("end_date") - pl.col("start_date")).dt.total_days().alias("days_between"),
)

# Months between dates (no direct equivalent of mofd subtraction)
df = df.with_columns(
    ((pl.col("end_date").dt.year() - pl.col("start_date").dt.year()) * 12
     + (pl.col("end_date").dt.month() - pl.col("start_date").dt.month()))
      .alias("months_between")
)
```

> **Key behavioral difference:** In Stata, date arithmetic is plain integer
> arithmetic (`date + 30` adds 30 days). In polars, you must use `pl.duration()`
> for additions. `pl.duration()` does NOT support months or years (because they are
> not fixed-length). Use `dt.offset_by("1mo")` or `dt.offset_by("1y")` for
> calendar-aware month/year arithmetic.

### Date Formatting (Display)

```stata
* Stata -- format controls display, not storage
format date %td
format date %tdCCYY-NN-DD
format date %tdMonth_DD,_CCYY
```

```python
# polars -- strftime for display strings
df = df.with_columns(
    pl.col("date").dt.strftime("%Y-%m-%d").alias("date_iso"),
    pl.col("date").dt.strftime("%B %d, %Y").alias("date_long"),
)
```

### Date Sequences

```stata
* Stata -- no built-in sequence; often done with _n
set obs 365
gen date = mdy(1, 1, 2024) + _n - 1
format date %td
```

```python
# polars
dates = pl.date_range(
    pl.date(2024, 1, 1), pl.date(2024, 12, 31),
    interval="1d", eager=True
).alias("date")
```

### Reading Dates from .dta Files

When reading `.dta` files, Stata date integers are automatically converted by
`pd.read_stata()` and `pyreadstat.read_dta()`:

```python
# Both handle Stata date conversion automatically
import pyreadstat
df_pd, meta = pyreadstat.read_dta("data.dta")
df = pl.from_pandas(df_pd)
# Date columns arrive as proper Date/Datetime types
```

> **EPOCH MISMATCH WARNING:** If you read raw integer values from a Stata file
> (e.g., via low-level readers), those integers are days since 1960-01-01, NOT
> Unix epoch (1970-01-01). Interpreting them as Unix timestamps will shift all
> dates by 10 years.

**Sources:** Stata Blog, "A tour of datetime in Stata" (blog.stata.com, 2015);
StataCorp, "Datetime" (stata.com/manuals/ddatetime.pdf); UCLA Statistical Consulting,
"dates in Stata" (stats.oarc.ucla.edu, accessed 2026-03-28); polars User Guide,
"Date/Time" (docs.pola.rs, accessed 2026-03-28).

---

## Section 3: Value Labels

Stata's value label system is a three-layer metadata infrastructure with no direct
Python equivalent. Understanding what is lost in translation -- and how to compensate
-- is essential for Stata-to-Python workflows.

### Stata's Three-Layer Label System

| Layer | Stata Command | Purpose | Python Equivalent |
|-------|--------------|---------|-------------------|
| Dataset label | `label data "description"` | Describes the entire dataset | None (use documentation) |
| Variable label | `label variable var "desc"` | Describes a column | None (use metadata dict or IAT comments) |
| Value label | `label define` + `label values` | Maps integers to text | Dictionary, `pl.Enum`, or `pl.Categorical` |

### Defining and Applying Value Labels

```stata
* Stata -- two-step process
label define race_lbl 1 "White" 2 "Black" 3 "Hispanic" 4 "Asian" 5 "Other"
label values race race_lbl

* Now race is stored as integers (1-5) but DISPLAYS as text
tabulate race
*    Race |  Freq.
*   White |   500
*   Black |   200
```

```python
# Python -- dictionary mapping (most common approach)
race_labels = {1: "White", 2: "Black", 3: "Hispanic", 4: "Asian", 5: "Other"}

# Option 1: Create a labeled string column (display-oriented)
df = df.with_columns(
    pl.col("race").replace_strict(race_labels).alias("race_label")
)

# Option 2: Keep numeric column, use dict for display only (analysis-oriented)
# Use race_labels dict when creating tables/output; keep integers for regression
```

> **Critical design choice:** In Stata, the variable stores integers but displays
> text automatically. Regression models use the integers; tabulations show the labels.
> In Python, you must choose: store as string (human-readable but requires `C()` for
> regression) OR store as integer (model-ready but requires mapping for display).
> There is no "both at once" option.

### encode / decode

```stata
* Stata
* encode: string -> labeled numeric
encode state_name, gen(state_code)
* state_code is 1, 2, 3... with labels "Alabama", "Alaska", ...

* decode: labeled numeric -> string
decode state_code, gen(state_string)
```

```python
# polars -- encode: string to integer codes
df = df.with_columns(
    pl.col("state_name").cast(pl.Categorical).to_physical().alias("state_code")
)
# The Categorical type remembers the mapping; to_physical() gives integer codes

# polars -- decode: integer codes back to strings (requires the mapping)
state_mapping = {v: k for k, v in enumerate(
    df.select(pl.col("state_name").unique().sort()).to_series().to_list()
)}
# Or: maintain the mapping dict from the original encode step
```

> **Key behavioral difference:** Stata's `encode` produces integer codes with labels
> attached -- you can see text in output but use integers in regression. Polars'
> `cast(pl.Categorical).to_physical()` gives raw integer codes but the text mapping
> is lost unless you save it separately.

### Variable Labels (label variable)

```stata
* Stata
label variable enrollment "Total student enrollment (K-12), fall count"
label variable frpl_pct "Percent students eligible for free/reduced price lunch"
* Labels appear in describe, regression output, GUI
```

```python
# Python -- no built-in equivalent
# Strategy 1: Metadata dictionary (recommended for DAAF)
var_labels = {
    "enrollment": "Total student enrollment (K-12), fall count",
    "frpl_pct": "Percent students eligible for free/reduced price lunch",
}

# Strategy 2: IAT comments in scripts (DAAF convention)
# INTENT: frpl_pct represents the share of students eligible for FRPL

# Strategy 3: Column documentation in the Plan or Report
```

### Reading Labels from .dta Files

```python
# pyreadstat -- preserves all Stata label metadata
import pyreadstat
df_pd, meta = pyreadstat.read_dta("data.dta")

# Value labels: {varname: {int_code: "label_string", ...}}
print(meta.variable_value_labels)
# e.g., {"race": {1: "White", 2: "Black", ...}, "region": {1: "Northeast", ...}}

# Variable labels: {varname: "description"}
print(meta.column_names_to_labels)
# e.g., {"enrollment": "Total student enrollment", "frpl_pct": "Percent FRPL"}

# pandas StataReader (alternative)
import pandas as pd
reader = pd.StataReader("data.dta")
var_labels = reader.variable_labels()
val_labels = reader.value_labels()
```

### Preserving Labels in the DAAF Parquet Workflow

Parquet does not store Stata-style value labels. To preserve them across the
pipeline:

```python
# Strategy: Save label metadata alongside the parquet file
import json

# When first reading the .dta file:
df_pd, meta = pyreadstat.read_dta("data.dta")
label_metadata = {
    "variable_labels": meta.column_names_to_labels,
    "value_labels": {
        var: labels for var, labels in meta.variable_value_labels.items()
    },
}

# Save metadata as JSON companion file
with open(f"{PROJECT_DIR}/data/raw/label_metadata.json", "w") as f:
    json.dump(label_metadata, f, indent=2)

# Save data as parquet (DAAF standard)
df = pl.from_pandas(df_pd)
df.write_parquet(f"{PROJECT_DIR}/data/raw/data.parquet")

# When loading later, reload labels:
with open(f"{PROJECT_DIR}/data/raw/label_metadata.json") as f:
    labels = json.load(f)
```

### Common Pitfalls When Working with Stata Labels

1. **Lost labels on import:** When reading `.dta` files with
   `pd.read_stata(convert_categoricals=True)` (the default), integer codes are
   replaced with label strings. This changes the column type from numeric to string,
   which breaks regression formulas that expect numeric input.

2. **Categoricals are not value labels:** Python's `pl.Categorical` or `pd.Categorical`
   handles ordering and memory efficiency but does NOT replicate the integer-storage-
   with-text-display paradigm. Models in Python see the category strings, not hidden
   integer codes.

3. **Forgetting to encode for modeling:** In Stata, a labeled numeric variable goes
   directly into regression. In Python, string categoricals must be explicitly
   dummy-coded: `C(var)` in formulas or `pd.get_dummies()` manually.

4. **One label set, multiple variables:** Stata allows one `label define` set to be
   attached to multiple variables (e.g., a `yesno` label for all binary indicators).
   Python requires applying the mapping dict separately to each column.

**Sources:** StataCorp, "label values" (stata.com/manuals); UCLA Statistical
Consulting, "Labeling data" (stats.oarc.ucla.edu, accessed 2026-03-28); Poverty
Action, "Value Labels" (povertyaction.github.io, accessed 2026-03-28); pyreadstat
(github.com/Roche/pyreadstat, accessed 2026-03-28); pandas StataReader documentation
(pandas.pydata.org, accessed 2026-03-28).

---

## Section 4: Categorical and Enum Types

Polars has two categorical-like types that serve some of the purposes of Stata's
value labels:

### Categorical vs Enum

| Type | Order | When to Use |
|------|-------|-------------|
| `pl.Categorical` | Determined at runtime (physical order = insertion order) | General-purpose; when level set is unknown in advance |
| `pl.Enum(["a", "b", "c"])` | Fixed, user-defined | When levels are known and ordering matters |

```python
# polars -- Categorical (unordered, levels discovered at runtime)
df = df.with_columns(pl.col("region").cast(pl.Categorical))

# polars -- Enum (ordered, levels defined in advance)
region_type = pl.Enum(["Northeast", "South", "Midwest", "West"])
df = df.with_columns(pl.col("region").cast(region_type))
```

### Comparison with Stata's Labeled Numeric Approach

| Aspect | Stata (value labels) | polars Categorical | polars Enum |
|--------|---------------------|-------------------|-------------|
| Storage | Integer codes | String categories (hashed internally) | String categories (indexed) |
| Display | Label text | Category string | Category string |
| Ordering | Implicit (numeric order of codes) | No inherent order | Order from level definition |
| In regression | Integer used directly | Must use `C()` in formula | Must use `C()` in formula |
| Memory | Efficient (integers) | Efficient (hash table) | Efficient (integer index) |

### Getting Integer Codes (to_physical)

```stata
* Stata -- underlying numeric codes
gen race_num = race    /* already numeric */
```

```python
# polars -- extract integer codes from Categorical
df = df.with_columns(
    pl.col("race").cast(pl.Categorical).to_physical().alias("race_num")
)

# polars -- get the category list (like Stata's label list)
categories = df.select(pl.col("race").cat.get_categories()).to_series().to_list()
```

### Recoding Categories

```stata
* Stata
label define region_lbl 1 "NE" 2 "South" 3 "MW" 4 "West", modify
* or:
recode region (1=1 "Northeast") (2=2 "Southeast") (3=3 "Midwest") (4=4 "West")
```

```python
# polars -- use replace for recoding
df = df.with_columns(
    pl.col("region").replace({"NE": "Northeast", "SE": "Southeast"})
)
```

### Categorical in Regression Formulas

```stata
* Stata -- i. prefix creates dummies from labeled numeric
regress outcome i.region treatment
regress outcome i.region#c.treatment    /* interaction */
regress outcome ib2.region treatment    /* base category = 2 */
```

```python
# pyfixest -- C() creates dummies from string/categorical columns
import pyfixest as pf
fit = pf.feols("outcome ~ C(region) + treatment", data=pdf)
fit = pf.feols("outcome ~ C(region):treatment", data=pdf)       # interaction
fit = pf.feols("outcome ~ C(region, contr.treatment(base='South')) + treatment", data=pdf)

# statsmodels -- same C() syntax in formulas
import statsmodels.formula.api as smf
fit = smf.ols("outcome ~ C(region) + treatment", data=pdf).fit()
fit = smf.ols("outcome ~ C(region, Treatment(reference='South')) + treatment",
              data=pdf).fit()
```

### Lumping Infrequent Categories

```stata
* Stata -- no built-in equivalent; manual recode
gen region5 = region
replace region5 = "Other" if !inlist(region, "Northeast", "South", "Midwest", "West")
```

```python
# polars -- lump infrequent categories into "Other"
top_categories = (
    df.group_by("category").len()
    .sort("len", descending=True)
    .head(5)
    .get_column("category")
    .to_list()
)
df = df.with_columns(
    pl.when(pl.col("category").is_in(top_categories))
      .then(pl.col("category"))
      .otherwise(pl.lit("Other"))
      .alias("category")
)
```

**Sources:** polars User Guide, "Categorical data and enums" (docs.pola.rs, accessed
2026-03-28); StataCorp, "label define" (stata.com/manuals); pandas "Categorical data"
(pandas.pydata.org, accessed 2026-03-28).

---

## Quick Reference Table

A condensed lookup for type-specific operation translations:

| Stata | polars | Category |
|-------|--------|----------|
| `substr(s, 1, 3)` | `.str.slice(0, 3)` | String |
| `strpos(s, "x")` | `.str.find("x")` | String |
| `subinstr(s, "a", "b", .)` | `.str.replace_all("a", "b")` | String |
| `strtrim(s)` | `.str.strip_chars()` | String |
| `strlower(s)` | `.str.to_lowercase()` | String |
| `strupper(s)` | `.str.to_uppercase()` | String |
| `ustrlen(s)` | `.str.len_chars()` | String |
| `regexm(s, "pat")` | `.str.contains("pat")` | String |
| `regexs(1)` | `.str.extract(r"(pat)", group_index=1)` | String |
| `word(s, 1)` | `.str.split(" ").list.first()` | String |
| `s1 + " " + s2` | `pl.concat_str(["s1", "s2"], separator=" ")` | String |
| `string(n)` | `.cast(pl.Utf8)` | String |
| `real(s)` | `.cast(pl.Float64)` | String |
| `date("2024-03-15", "YMD")` | `.str.to_date("%Y-%m-%d")` | Date |
| `mdy(3, 15, 2024)` | Build string then `.str.to_date()` | Date |
| `year(date)` | `.dt.year()` | Date |
| `month(date)` | `.dt.month()` | Date |
| `day(date)` | `.dt.day()` | Date |
| `dow(date)` | `.dt.weekday()` (1=Mon not 0=Sun) | Date |
| `mofd(date)` | `.dt.truncate("1mo")` | Date |
| `date + 30` | `+ pl.duration(days=30)` | Date |
| `date + months(1)` | `.dt.offset_by("1mo")` | Date |
| `format date %td` | `.dt.strftime("%Y-%m-%d")` | Date |
| `label define lbl 1 "A" 2 "B"` | `mapping = {1: "A", 2: "B"}` | Label |
| `label values var lbl` | `.replace_strict(mapping)` | Label |
| `encode strvar, gen(numvar)` | `.cast(pl.Categorical).to_physical()` | Label |
| `decode numvar, gen(strvar)` | `.replace_strict(reverse_mapping)` | Label |
| `label variable var "desc"` | `var_labels = {"var": "desc"}` (metadata dict) | Label |
| `i.region` (in regression) | `C(region)` (in formula) | Categorical |
