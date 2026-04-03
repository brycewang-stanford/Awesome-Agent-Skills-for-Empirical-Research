# Paradigm Differences: R vs Python for Quantitative Social Science

This reference documents the fundamental language and paradigm differences between
R and Python (with polars) as they affect quantitative social science data analysis.
It is the foundational reference that other translation files build upon.

> **Versions referenced:**
> Python: Python 3.12, polars 1.38.1
> R: R 4.5.3
> See SKILL.md § Library Versions for the complete version table.

## Contents

- [Indexing](#indexing)
- [Missing Values](#missing-values)
- [Formula Interfaces](#formula-interfaces)
- [Assignment and Mutability](#assignment-and-mutability)
- [Vectorized Operations](#vectorized-operations)
- [Factor / Categorical Handling](#factor--categorical-handling)
- [Type System](#type-system)
- [Package Ecosystem Philosophy](#package-ecosystem-philosophy)
- [Data Frame Philosophy](#data-frame-philosophy)
- [String Handling](#string-handling)
- [Date/Time Handling](#datetime-handling)
- [File I/O](#file-io)
- [Environment and Scoping](#environment-and-scoping)

---

## Indexing

R uses 1-based indexing; Python uses 0-based. Polars discourages positional
indexing entirely and favors named or expression-based access.

| Operation | R | Python / Polars |
|-----------|---|-----------------|
| First element | `x[1]` | `x[0]` |
| First row | `df[1, ]` | `df.head(1)` or `df.row(0)` |
| Rows 1-5 | `df[1:5, ]` (inclusive) | `df.head(5)` or `df.slice(0, 5)` |
| Last element | `x[length(x)]` | `x[-1]` |
| Column by name | `df$col` | `df.select("col")` or `df["col"]` |

**What R users expect:** `df[1, ]` returns the first row.
**What happens in Python:** `df[1]` would try to index column "1" in polars. Use
`df.row(0)` for a tuple, or `df.head(1)` for a one-row DataFrame.

```r
# R — 1-based, inclusive ranges
x <- c(10, 20, 30, 40)
x[1]       # 10
x[2:4]     # 20, 30, 40 (inclusive on both ends)
```

```python
# Python — 0-based, exclusive upper bound
x = [10, 20, 30, 40]
x[0]       # 10
x[1:4]     # [20, 30, 40] (exclusive upper bound)

# Polars — expression-based, positional access discouraged
df.row(0)              # first row as tuple
df.row(0, named=True)  # first row as dict
df.slice(1, 3)         # 3 rows starting at offset 1
```

> **Sources:** R Language Definition -- Indexing (CRAN, accessed 2026-03-28);
> Polars User Guide -- Coming from Pandas (docs.pola.rs, accessed 2026-03-28)

---

## Missing Values

This is the single largest source of translation bugs. R has one unified missing
value system; Python has three distinct representations that do not behave alike.

### R: Unified NA

R has a single sentinel `NA` with typed variants (`NA_real_`, `NA_character_`,
`NA_integer_`). All share consistent behavior:

- `NA` propagates through arithmetic: `1 + NA` yields `NA`
- `NA` propagates through comparison: `NA == NA` yields `NA` (not `TRUE`)
- Logical short-circuit: `TRUE | NA` yields `TRUE`; `FALSE & NA` yields `FALSE`
- Universal detection: `is.na(x)` works on any type
- Aggregation control: `mean(x, na.rm = TRUE)` skips NAs

### Python: Three Kinds of Missing

| Representation | Scope | Detection | Behavior |
|----------------|-------|-----------|----------|
| `None` | Python-level | `x is None` | Coerced to `null` in polars |
| `float("nan")` / `np.nan` | Float only | `math.isnan(x)` | `NaN + 1 = NaN`; `NaN != NaN` is `True` |
| `null` (polars) | All types | `.is_null()` | Skipped by aggregations |

**Critical trap:** `NaN` and `null` are different in polars. `null` is true
missingness (aggregations skip it). `NaN` is a valid IEEE 754 float (aggregations
propagate it). `fill_null()` does NOT fill `NaN`; `fill_nan()` does NOT fill `null`.

```r
# R — one system
x <- c(1, NA, 3)
is.na(x)                # FALSE, TRUE, FALSE
mean(x, na.rm = TRUE)   # 2
```

```python
# Polars — null is the primary missing representation
df = pl.DataFrame({"x": [1, None, 3]})
df.filter(pl.col("x") == None)    # WRONG — returns empty DataFrame
df.filter(pl.col("x").is_null())  # RIGHT — returns the null row

# NaN vs null — the dangerous case
df = pl.DataFrame({"x": [1.0, float("nan"), None]})
df.select(pl.col("x").mean())                    # NaN (propagates!)
df.select(pl.col("x").fill_nan(None).mean())     # 1.0 (safe pattern)
```

### Common Translation Patterns

| R | Python / Polars |
|---|-----------------|
| `is.na(x)` | `pl.col("x").is_null()` |
| `!is.na(x)` | `pl.col("x").is_not_null()` |
| `na.rm = TRUE` | Default in polars aggregations (nulls skipped) |
| `complete.cases(df)` | `df.drop_nulls()` |
| `replace(x, is.na(x), 0)` | `pl.col("x").fill_null(0)` |
| `coalesce(x, y)` (dplyr) | `pl.coalesce("x", "y")` |

> **Sources:** R Language Definition -- NA (stat.ethz.ch/R-manual, accessed 2026-03-28);
> Polars User Guide -- Missing Data (docs.pola.rs, accessed 2026-03-28);
> Wickham, *Advanced R* 2nd ed., Ch. 3.5.1 (2019)

---

## Formula Interfaces

R has one universal formula system. Python has three incompatible dialects.

### R: Universal Formula

```r
lm(y ~ x1 + x2, data = df)                       # OLS
glm(y ~ x1 + x2, data = df, family = binomial)    # logit
fixest::feols(y ~ x1 + x2 | fe1, data = df)       # FE regression
survey::svyglm(y ~ x1 + x2, design = svy_design)  # survey-weighted
```

The formula `y ~ x1 + x2` auto-includes an intercept, auto-dummies factors,
and generates interactions with `x1:x2` or `x1*x2`. One syntax everywhere.

### Python: Three Dialects

**1. patsy (statsmodels)** -- R-like formulas via `smf`:

```python
model = smf.ols("y ~ x1 + x2", data=pdf).fit()            # OLS
model = smf.ols("y ~ x1 + x2 + C(group)", data=pdf).fit()  # with factor
```

- Auto-adds intercept; `C(var)` marks categoricals; requires pandas DataFrame

**2. formulaic (pyfixest)** -- closest to R's fixest:

```python
model = pf.feols("y ~ x1 + x2 | fe1", data=pdf)            # FE
model = pf.feols("y ~ 1 | fe1 | x_endog ~ z1", data=pdf)    # IV with FE
```

- Supports `i()`, `C()`, `sw()`, `csw()`; accepts polars or pandas

**3. No formula (scikit-learn)** -- matrix-based:

```python
X = df.select("x1", "x2").to_numpy()
y = df.select("y").to_numpy().ravel()
model = LinearRegression().fit(X, y)
```

- Manual feature matrix; manual dummy coding; no automatic intercept

### The Same Model in Four Syntaxes

```r
# R (fixest)
fixest::feols(wage ~ education + experience | industry, data = df)
```

```python
# pyfixest — closest to R
pf.feols("wage ~ education + experience | industry", data=pdf)

# statsmodels — no built-in FE, must dummy-code
smf.ols("wage ~ education + experience + C(industry)", data=pdf).fit()

# scikit-learn — fully manual
X = pd.get_dummies(pdf[["education", "experience", "industry"]], drop_first=True)
LinearRegression().fit(X, pdf["wage"])
```

> **Sources:** patsy docs -- How formulas work (patsy.readthedocs.io, accessed 2026-03-28);
> statsmodels 0.14 -- R-style formulas (statsmodels.org, accessed 2026-03-28);
> pyfixest docs -- Formula syntax (pyfixest.org, accessed 2026-03-28)

---

## Assignment and Mutability

R's copy-on-modify semantics create independent copies by default.
Python's reference semantics create aliases to the same object.

```r
# R — copy-on-modify: modifying df2 never changes df
df2 <- df
df2$new_col <- 1   # triggers a copy; df is unchanged
```

```python
# Python — reference semantics: df2 IS df
df2 = df
# df2[0, "col"] = 1 would modify df too (in pandas)

# Fix: explicit copy
df2 = df.clone()    # polars
pdf2 = pdf.copy()   # pandas
```

**Polars mitigates this:** Most polars operations return new DataFrames rather
than modifying in place (`with_columns()`, `filter()`, etc.), which is closer
to R's behavior. The risk surfaces when mixing polars with pandas or mutable
Python objects.

> **Sources:** Wickham, *Advanced R* 2nd ed., Ch. 2.3 -- Copy-on-modify (2019);
> Polars API -- DataFrame.clone (docs.pola.rs, accessed 2026-03-28)

---

## Vectorized Operations

R implicitly vectorizes nearly all operations. Polars requires the expression
system inside a context.

```r
# R — implicit vectorization, everything "just works"
x <- c(1, 2, 3, 4, 5)
x * 2                          # c(2, 4, 6, 8, 10)
ifelse(x > 3, "high", "low")  # vectorized conditional
df$z <- df$x * 2 + df$y       # direct column arithmetic
```

```python
# Polars — expressions inside contexts
df = df.with_columns(
    (pl.col("x") * 2).alias("x_doubled"),
    pl.when(pl.col("x") > 3)
      .then(pl.lit("high"))
      .otherwise(pl.lit("low"))
      .alias("category"),
)
```

**The expression system is the single biggest paradigm shift for R users:**
- Columns are referenced via `pl.col("name")`, not bare names
- Results need `.alias()` to name the output column
- Expressions must live inside a **context**: `select()`, `with_columns()`,
  `filter()`, or `group_by().agg()`
- Expressions outside a context are lazy blueprints, not evaluated values

| R | Python / Polars |
|---|-----------------|
| `df$z <- df$x * 2` | `df = df.with_columns((pl.col("x") * 2).alias("z"))` |
| `ifelse(cond, a, b)` | `pl.when(cond).then(a).otherwise(b)` |
| `case_when(...)` | Chained `pl.when().then().when().then().otherwise()` |
| `pmax(x, y)` | `pl.max_horizontal("x", "y")` |
| `cumsum(x)` | `pl.col("x").cum_sum()` |
| `rowSums(df[, cols])` | `pl.sum_horizontal(cols)` |

> **Sources:** R Language Definition -- Vectorized operations (CRAN, accessed 2026-03-28);
> Polars User Guide -- Expressions and contexts (docs.pola.rs, accessed 2026-03-28)

---

## Factor / Categorical Handling

R factors are a first-class statistical type with automatic dummy coding.
Polars categoricals are a storage optimization with no regression integration.

```r
# R — factors participate directly in modeling
x <- factor(c("low", "med", "high"), levels = c("low", "med", "high"))
lm(y ~ x, data = df)     # auto-creates x[med] and x[high] dummies
contrasts(df$x)           # shows the coding scheme
relevel(x, ref = "med")  # change reference level
```

```python
# Polars — Categorical/Enum for storage, not modeling
df = df.with_columns(pl.col("group").cast(pl.Categorical))

size_type = pl.Enum(["small", "medium", "large"])  # ordered, known categories
df = df.with_columns(pl.col("size").cast(size_type))
```

Polars `Categorical` and `Enum` reduce memory but do **not** auto-generate
dummies. Use `Enum` when categories are fixed and known; `Categorical` otherwise.

### Getting R-like Factor Behavior in Python

```python
# pyfixest — closest to R
pf.feols("y ~ C(group)", data=pdf)
pf.feols("y ~ i(group, ref='low')", data=pdf)

# statsmodels — C() with explicit contrast
smf.ols("y ~ C(group, Treatment(reference='low'))", data=pdf).fit()

# Manual — when no formula interface is available
pdf_dummies = pd.get_dummies(pdf, columns=["group"], drop_first=True)
```

> **Sources:** UCLA Statistical Consulting -- Contrast coding (stats.oarc.ucla.edu, accessed 2026-03-28);
> statsmodels 0.14 -- Contrast Coding Systems (statsmodels.org, accessed 2026-03-28);
> Polars User Guide -- Categorical data and enums (docs.pola.rs, accessed 2026-03-28)

---

## Type System

R coerces types implicitly along a hierarchy. Python and polars require explicit
conversion.

| Behavior | R | Python / Polars |
|----------|---|-----------------|
| Bool + int | `TRUE + 1` = `2` | `True + 1` = `2` (bool subclasses int) |
| Mixed vector | `c(1, "a")` = `c("1", "a")` | TypeError or explicit cast |
| String to num | `as.numeric("5")` = `5` | `int("5")` or `.cast(pl.Int64)` |
| String + num | `"5" + 1` = Error | `"5" + 1` = TypeError |

R's coercion hierarchy: logical < integer < double < complex < character.
Mixed types silently promote to the more general type.

```python
# Polars — strict types, explicit .cast()
df = df.with_columns(
    pl.col("str_number").cast(pl.Int64).alias("number"),
)
# pl.col("str_col") + pl.col("int_col") raises ComputeError
```

| R | Python / Polars |
|---|-----------------|
| `as.numeric(x)` | `pl.col("x").cast(pl.Float64)` |
| `as.integer(x)` | `pl.col("x").cast(pl.Int64)` |
| `as.character(x)` | `pl.col("x").cast(pl.Utf8)` |
| `as.logical(x)` | `pl.col("x").cast(pl.Boolean)` |
| `as.numeric(factor(x))` | `pl.col("x").to_physical()` (integer codes) |

> **Sources:** R Language Definition -- Coercion (CRAN, accessed 2026-03-28);
> Python docs -- Built-in Types (docs.python.org, accessed 2026-03-28);
> Polars API -- Expr.cast (docs.pola.rs, accessed 2026-03-28)

---

## Package Ecosystem Philosophy

R packages are comprehensive toolkits. Python packages are specialized,
requiring composition of multiple libraries for equivalent coverage.

```r
# R — one package (fixest) does everything
library(fixest)
feols(y ~ x1 | fe1, data = df)       # OLS with FE
fepois(y ~ x1 | fe1, data = df)      # Poisson with FE
feols(y ~ x1 | fe1 | endog ~ z1)     # IV
etable(m1, m2, m3)                    # publication table
iplot(model)                          # coefficient plot
```

The same coverage in Python requires multiple packages:

| R (single package) | Python (DAAF) | Coverage |
|--------------------|---------------|----------|
| `fixest::feols()` | `pyfixest.feols()` | OLS/FE/IV/Poisson |
| `fixest::etable()` | `pyfixest.etable()` | Regression tables |
| `fixest::sunab()` | `pyfixest` with `sunab()` | Sun-Abraham DiD |
| `survey::svyglm()` | `svy` | Survey-weighted |
| `lme4::lmer()` | `statsmodels.MixedLM` | Mixed effects |
| `survival::coxph()` | `lifelines.CoxPHFitter` | Survival analysis |
| `marginaleffects::slopes()` | `marginaleffects` (Python port) | Marginal effects |

R scripts typically have 2-3 `library()` calls; equivalent Python scripts may
have 6-10 `import` statements. This fragmentation is normal and expected.

> **Sources:** fixest CRAN vignette (cran.r-project.org, accessed 2026-03-28);
> pyfixest documentation (pyfixest.org, accessed 2026-03-28)

---

## Data Frame Philosophy

R uses one data frame type everywhere. DAAF uses polars for wrangling but must
convert to pandas for most modeling packages -- a boundary with no R equivalent.

```r
# R — same tibble everywhere: wrangle, model, plot
df %>% filter(x > 2) %>% mutate(z = x * 2)
lm(z ~ x, data = df)
ggplot(df, aes(x, z)) + geom_point()
```

```python
# DAAF pattern: polars → pandas → model → polars
df = pl.read_parquet("data.parquet")          # polars for wrangling
df = df.filter(pl.col("x") > 2).with_columns(
    (pl.col("x") * 2).alias("z")
)
pdf = df.to_pandas()                           # convert for modeling
model = smf.ols("z ~ x", data=pdf).fit()      # statsmodels needs pandas
# pyfixest accepts polars directly:
model = pf.feols("z ~ x", data=df)
```

### The polars-pandas Boundary

1. **Load and wrangle** in polars (fast, expressive, memory-efficient)
2. **Convert to pandas** for modeling: `pdf = df.to_pandas()`
3. **Convert back** for storage: `pl.from_pandas(result)`

Pandas DataFrames carry an index (row labels) that polars lacks. When converting,
`reset_index()` before `pl.from_pandas()` if the index contains meaningful data.

> **Sources:** Wickham & Grolemund, *R for Data Science* 2nd ed. -- Tibbles (2023);
> Polars User Guide -- Coming from Pandas (docs.pola.rs, accessed 2026-03-28)

---

## String Handling

R's `stringr` uses `str_*` prefix functions; polars uses `.str.*` namespace methods.

| Operation | R (stringr) | Polars |
|-----------|-------------|--------|
| Detect | `str_detect(x, "abc")` | `pl.col("x").str.contains("abc")` |
| Replace first | `str_replace(x, "old", "new")` | `pl.col("x").str.replace("old", "new")` |
| Replace all | `str_replace_all(x, "old", "new")` | `pl.col("x").str.replace_all("old", "new")` |
| Extract | `str_extract(x, "\\d+")` | `pl.col("x").str.extract(r"(\d+)", 1)` |
| Split | `str_split(x, ",")` | `pl.col("x").str.split(",")` |
| Trim | `str_trim(x)` | `pl.col("x").str.strip_chars()` |
| Upper/lower | `str_to_upper(x)` | `pl.col("x").str.to_uppercase()` |
| Length | `str_length(x)` | `pl.col("x").str.len_chars()` |
| Concatenate | `str_c(x, y, sep="_")` | `pl.concat_str(["x", "y"], separator="_")` |

```r
# R — stringr pipe chain
df$clean <- df$name %>% str_to_lower() %>% str_trim() %>% str_replace_all("[^a-z ]", "")
```

```python
# Polars — .str namespace chain inside with_columns()
df = df.with_columns(
    pl.col("name").str.to_lowercase().str.strip_chars()
      .str.replace_all(r"[^a-z ]", "").alias("clean")
)
```

**Key difference:** R's `str_extract()` returns the full match. Polars'
`.str.extract()` requires a capture group and group index.

> **Sources:** Wickham, *R for Data Science* 2nd ed., Ch. 14 (2023);
> Polars API -- Expr.str (docs.pola.rs, accessed 2026-03-28)

---

## Date/Time Handling

R's `lubridate` uses intuitive named parsers. Polars uses strftime format strings
and a `.dt` namespace.

| Operation | R (lubridate) | Polars |
|-----------|---------------|--------|
| Parse date | `ymd("2024-01-15")` | `pl.col("d").str.to_date("%Y-%m-%d")` |
| Parse datetime | `ymd_hms(...)` | `pl.col("d").str.to_datetime("%Y-%m-%d %H:%M:%S")` |
| Year | `year(date)` | `pl.col("date").dt.year()` |
| Month | `month(date)` | `pl.col("date").dt.month()` |
| Floor to month | `floor_date(date, "month")` | `pl.col("date").dt.truncate("1mo")` |
| Difference | `difftime(d2, d1, units="days")` | `(pl.col("d2") - pl.col("d1")).dt.total_days()` |
| Add days | `date + days(30)` | `pl.col("date") + pl.duration(days=30)` |

```r
# R — lubridate, auto-detects separators
df$date <- ymd(df$date_str)
df$year <- year(df$date)
df$month_start <- floor_date(df$date, "month")
```

```python
# Polars — explicit format string required
df = df.with_columns(
    pl.col("date_str").str.to_date("%Y-%m-%d").alias("date")
).with_columns(
    pl.col("date").dt.year().alias("year"),
    pl.col("date").dt.truncate("1mo").alias("month_start"),
)
```

**Key difference:** R's `ymd()`, `mdy()`, `dmy()` auto-detect separators. Polars
requires an explicit format string. Wrong format strings silently produce nulls --
always validate parsed dates with a null check.

> **Sources:** Grolemund & Wickham, *R for Data Science* 2nd ed., Ch. 17 (2023);
> Polars User Guide -- Temporal data (docs.pola.rs, accessed 2026-03-28)

---

## File I/O

Both ecosystems handle common formats. DAAF standardizes on parquet.

| Format | R | Python / Polars |
|--------|---|-----------------|
| CSV | `readr::read_csv()` | `pl.read_csv()` |
| Parquet | `arrow::read_parquet()` | `pl.read_parquet()` |
| Parquet (lazy) | `arrow::open_dataset()` | `pl.scan_parquet()` |
| Stata | `haven::read_dta()` | `pd.read_stata()` |
| Excel | `readxl::read_excel()` | `pl.read_excel()` |
| RDS | `readRDS()` | No equivalent; use `pyreadr` |

```python
# Polars — native parquet with lazy scanning
df = pl.read_parquet("data/raw/schools.parquet")
df.write_parquet("data/processed/schools_clean.parquet")

# Lazy scan for large files (predicate/projection pushdown)
lf = pl.scan_parquet("data/raw/large.parquet")
result = lf.filter(pl.col("state") == "CA").select("id", "name").collect()
```

**DAAF convention:** All data stored in parquet format. No CSV, no Excel.

> **Sources:** Polars User Guide -- I/O (docs.pola.rs, accessed 2026-03-28);
> arrow R package docs (arrow.apache.org, accessed 2026-03-28)

---

## Environment and Scoping

R attaches packages to a global search path. Python uses explicit module imports
with namespace prefixes.

```r
# R — library() makes all exports available unqualified
library(dplyr)
df %>% filter(x > 5) %>% mutate(y = str_to_lower(name))

# Name collisions resolved by load order (last wins)
library(dplyr)    # exports filter()
library(stats)    # also exports filter() — masks dplyr::filter()
dplyr::filter(df, x > 5)  # disambiguate with explicit namespace
```

```python
# Python — explicit imports, namespaced access always
import polars as pl
import pyfixest as pf

df = df.filter(pl.col("x") > 5)  # pl.DataFrame.filter(), not built-in filter()
model = pf.feols("y ~ x", data=pdf)
```

**What R users expect:** After importing, functions are available by bare name.
**What actually happens:** Every function lives in its package namespace.
`filter()` alone is Python's built-in (on iterables), not polars' DataFrame filter.

| R Pattern | Python Equivalent | Notes |
|-----------|-------------------|-------|
| `library(dplyr)` | `import polars as pl` | Conventional alias |
| `library(fixest)` | `import pyfixest as pf` | Conventional alias |
| `library(ggplot2)` | `import plotnine as p9` | `from X import *` is discouraged |
| `dplyr::filter()` | `df.filter()` (method) | Always namespaced |
| `.GlobalEnv` | Module-level scope | Top of script |

> **Sources:** R Language Definition -- Scope (CRAN, accessed 2026-03-28);
> Wickham, *R Packages* 2nd ed., Ch. 10 (2023);
> Python docs -- The import system (docs.python.org, accessed 2026-03-28)
