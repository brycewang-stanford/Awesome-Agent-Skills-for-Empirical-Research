# Polars for dplyr/tidyr Users: Core Data Manipulation

> **Companion file:** For string operations (stringr), date/time operations
> (lubridate), and categorical/factor operations (forcats), see
> `polars-strings-dates-factors.md`.

This document provides an exhaustive verb-by-verb translation between R's core
tidyverse data manipulation packages (dplyr, tidyr) and Python's polars library.
The fundamental mental model shift: in dplyr, you chain **verbs** that act on a
data frame (filter, mutate, summarize); in polars, you build **expressions** that
describe what you want, then apply them inside a context (`select`, `filter`,
`with_columns`, `agg`). Polars is not a pandas replacement with tidyverse
semantics -- it is a distinct paradigm built on lazy evaluation and an expression
API. R users coming from dplyr will find that most operations have a direct
equivalent, but the grammar is expression-first rather than verb-first.

> **Versions referenced:**
> Python: polars 1.38.1
> R: dplyr 1.2.0, tidyr 1.3.2, stringr 1.6.0, lubridate 1.9.5, forcats 1.0.1, data.table 1.18.2
> See SKILL.md § Library Versions for the complete version table.

> **Sources:** dplyr 1.1.x documentation (dplyr.tidyverse.org, accessed 2026-03-28);
> tidyr 1.3.x documentation (tidyr.tidyverse.org, accessed 2026-03-28);
> Polars 1.x User Guide and API Reference (docs.pola.rs, accessed 2026-03-28);
> Wickham et al., *R for Data Science* 2nd ed. (2023).

---

## Section 1: Core dplyr Verbs

### select -- Choose Columns

**Basic column selection:**

```r
# R (dplyr)
df %>% select(col1, col2)
df %>% select(col1:col5)
```

```python
# polars
df.select("col1", "col2")
df.select(pl.col("col1"), pl.col("col2"))
```

**Drop columns (negative selection):**

```r
# R (dplyr)
df %>% select(-col1)
df %>% select(-c(col1, col2))
```

```python
# polars
df.select(pl.exclude("col1"))
df.select(pl.exclude("col1", "col2"))
```

**Select by type:**

```r
# R (dplyr)
df %>% select(where(is.numeric))
df %>% select(where(is.character))
```

```python
# polars
import polars.selectors as cs
df.select(cs.numeric())
df.select(cs.string())
```

**Select by name pattern:**

```r
# R (dplyr)
df %>% select(starts_with("pop"))
df %>% select(ends_with("_rate"))
df %>% select(contains("enroll"))
df %>% select(matches("^[A-Z]"))
```

```python
# polars
df.select(cs.starts_with("pop"))
df.select(cs.ends_with("_rate"))
df.select(cs.contains("enroll"))
df.select(pl.col("^[A-Z].*$"))  # regex via pl.col
```

**Select and rename:**

```r
# R (dplyr)
df %>% select(new_name = old_name)
```

```python
# polars
df.select(pl.col("old_name").alias("new_name"))
```

### filter -- Subset Rows

**Single condition:**

```r
# R (dplyr)
df %>% filter(x > 5)
```

```python
# polars
df.filter(pl.col("x") > 5)
```

Every column reference in polars must be wrapped in `pl.col()`. This is the single
biggest syntax adjustment for dplyr users.

**Multiple conditions (AND):**

```r
# R (dplyr)
df %>% filter(x > 5, y < 10)
df %>% filter(x > 5 & y < 10)
```

```python
# polars
df.filter((pl.col("x") > 5) & (pl.col("y") < 10))
```

Parentheses around each condition are mandatory due to Python operator precedence.

**OR conditions:**

```r
# R (dplyr)
df %>% filter(x > 5 | y < 10)
```

```python
# polars
df.filter((pl.col("x") > 5) | (pl.col("y") < 10))
```

**Membership (%in%):**

```r
# R (dplyr)
df %>% filter(x %in% c(1, 2, 3))
```

```python
# polars
df.filter(pl.col("x").is_in([1, 2, 3]))
```

**Negated membership:**

```r
# R (dplyr)
df %>% filter(!(x %in% c(1, 2, 3)))
```

```python
# polars
df.filter(~pl.col("x").is_in([1, 2, 3]))
```

**Filter on NA / null:**

```r
# R (dplyr)
df %>% filter(!is.na(x))
df %>% filter(is.na(x))
```

```python
# polars
df.filter(pl.col("x").is_not_null())
df.filter(pl.col("x").is_null())
```

**Filter with string matching:**

```r
# R (dplyr + stringr)
df %>% filter(str_detect(name, "Smith"))
```

```python
# polars
df.filter(pl.col("name").str.contains("Smith"))
```

**Between:**

```r
# R (dplyr)
df %>% filter(between(x, 10, 20))
```

```python
# polars
df.filter(pl.col("x").is_between(10, 20))
```

### mutate -- Create or Modify Columns

**Create a new column:**

```r
# R (dplyr)
df %>% mutate(new = old * 2)
```

```python
# polars
df.with_columns((pl.col("old") * 2).alias("new"))
```

The `.alias()` call names the output column. This is how polars maps the `new = `
syntax on the left side of an R mutate.

**Overwrite an existing column (same name):**

```r
# R (dplyr)
df %>% mutate(x = x + 1)
```

```python
# polars
df.with_columns(pl.col("x") + 1)
```

When the expression already has the correct column name (because it was derived from
a single `pl.col("x")` operation), no `.alias()` is needed -- polars infers the
output name.

**Multiple columns at once:**

```r
# R (dplyr)
df %>% mutate(
  rate = count / total,
  pct  = rate * 100
)
```

```python
# polars
df.with_columns(
    (pl.col("count") / pl.col("total")).alias("rate"),
    (pl.col("count") / pl.col("total") * 100).alias("pct"),
)
```

Note: unlike dplyr, polars `with_columns` does not see columns created earlier in
the same call. Each expression sees the original DataFrame state. To use a derived
column, chain a second `with_columns`.

```python
# polars -- sequential dependency
df.with_columns(
    (pl.col("count") / pl.col("total")).alias("rate"),
).with_columns(
    (pl.col("rate") * 100).alias("pct"),
)
```

**Type casting in mutate:**

```r
# R (dplyr)
df %>% mutate(x = as.numeric(x))
```

```python
# polars
df.with_columns(pl.col("x").cast(pl.Float64))
```

### arrange -- Sort Rows

**Ascending:**

```r
# R (dplyr)
df %>% arrange(x)
```

```python
# polars
df.sort("x")
```

**Descending:**

```r
# R (dplyr)
df %>% arrange(desc(x))
```

```python
# polars
df.sort("x", descending=True)
```

**Multiple sort columns:**

```r
# R (dplyr)
df %>% arrange(group, desc(value))
```

```python
# polars
df.sort("group", "value", descending=[False, True])
```

**Null placement:**

```r
# R -- NA values go last by default in arrange
df %>% arrange(x)
```

```python
# polars -- nulls go last by default
df.sort("x", nulls_last=True)   # explicit (default behavior)
df.sort("x", nulls_last=False)  # nulls first
```

### summarize / summarise -- Aggregate

**Basic summary:**

```r
# R (dplyr)
df %>% summarize(avg = mean(x), total = sum(x))
```

```python
# polars (without grouping -- aggregate entire DataFrame)
df.select(
    pl.col("x").mean().alias("avg"),
    pl.col("x").sum().alias("total"),
)
```

**Grouped summary:**

```r
# R (dplyr)
df %>%
  group_by(g) %>%
  summarize(m = mean(x), n = n())
```

```python
# polars
df.group_by("g").agg(
    pl.col("x").mean().alias("m"),
    pl.len().alias("n"),
)
```

Key difference: in polars, `group_by().agg()` replaces the `group_by() %>%
summarize()` pattern. Expressions inside `agg()` must be aggregating (returning one
value per group).

**Multiple grouping columns:**

```r
# R (dplyr)
df %>% group_by(g1, g2) %>% summarize(total = sum(x))
```

```python
# polars
df.group_by("g1", "g2").agg(pl.col("x").sum().alias("total"))
```

**Common aggregation function mapping:**

| R function | polars expression |
|------------|-------------------|
| `mean(x)` | `pl.col("x").mean()` |
| `sum(x)` | `pl.col("x").sum()` |
| `median(x)` | `pl.col("x").median()` |
| `sd(x)` | `pl.col("x").std()` |
| `var(x)` | `pl.col("x").var()` |
| `min(x)` | `pl.col("x").min()` |
| `max(x)` | `pl.col("x").max()` |
| `n()` | `pl.len()` |
| `n_distinct(x)` | `pl.col("x").n_unique()` |
| `first(x)` | `pl.col("x").first()` |
| `last(x)` | `pl.col("x").last()` |
| `quantile(x, 0.25)` | `pl.col("x").quantile(0.25)` |

### rename -- Rename Columns

```r
# R (dplyr)
df %>% rename(new_name = old_name)
```

```python
# polars
df.rename({"old_name": "new_name"})
```

Note the reversed key-value order compared to R: in dplyr the new name is on the
left; in polars the dict key is the old name and the value is the new name.

**Rename multiple:**

```r
# R (dplyr)
df %>% rename(a = x, b = y)
```

```python
# polars
df.rename({"x": "a", "y": "b"})
```

**Rename with a function:**

```r
# R (dplyr)
df %>% rename_with(toupper)
df %>% rename_with(~ paste0("col_", .x))
```

```python
# polars
df.select(pl.all().name.map(str.upper))
df.select(pl.all().name.prefix("col_"))
```

### distinct / unique -- Remove Duplicates

```r
# R (dplyr)
df %>% distinct()
df %>% distinct(col1, col2)
df %>% distinct(col1, .keep_all = TRUE)
```

```python
# polars
df.unique()
df.unique(subset=["col1", "col2"])
df.unique(subset=["col1"], keep="first")
```

### count / n -- Count Rows

```r
# R (dplyr)
df %>% count(group_col)
df %>% count(group_col, sort = TRUE)
```

```python
# polars
df.group_by("group_col").len()
df.group_by("group_col").len().sort("len", descending=True)
```

**Weighted count / tally:**

```r
# R (dplyr)
df %>% count(group_col, wt = weight_col)
```

```python
# polars
df.group_by("group_col").agg(pl.col("weight_col").sum().alias("n"))
```

### pull -- Extract a Column as a Vector

```r
# R (dplyr)
df %>% pull(col)
```

```python
# polars
df.get_column("col")            # returns polars Series
df.get_column("col").to_list()  # returns Python list
```

### slice -- Subset by Position

```r
# R (dplyr)
df %>% slice(1:5)
df %>% slice_head(n = 5)
df %>% slice_tail(n = 5)
df %>% slice_max(x, n = 5)
df %>% slice_min(x, n = 5)
df %>% slice_sample(n = 10)
```

```python
# polars
df.head(5)                                             # first 5
df.slice(0, 5)                                         # offset 0, length 5 (0-indexed)
df.tail(5)                                             # last 5
df.sort("x", descending=True).head(5)                  # top 5 by x
df.sort("x").head(5)                                   # bottom 5 by x
df.sample(n=10)                                        # random 10 rows
```

Note: R's `slice(1:5)` is 1-indexed; polars' `slice(0, 5)` is 0-indexed.

### bind_rows / bind_cols -- Combine DataFrames

```r
# R (dplyr)
bind_rows(df1, df2)
bind_rows(df1, df2, df3)
bind_cols(df1, df2)
```

```python
# polars
pl.concat([df1, df2])                          # vertical (row-bind)
pl.concat([df1, df2, df3])                     # multiple
pl.concat([df1, df2], how="horizontal")        # horizontal (col-bind)
```

When schemas differ, use `how="diagonal"` for union-style concatenation (fills
missing columns with null):

```python
# polars -- union columns from both, null-fill missing
pl.concat([df1, df2], how="diagonal")
```

### relocate -- Move Columns

```r
# R (dplyr)
df %>% relocate(col3, .before = col1)
df %>% relocate(col3, .after = col2)
```

```python
# polars -- no direct relocate; reorder in select
df.select("col3", pl.exclude("col3"))                  # move to front
df.select("col1", "col2", "col3", pl.exclude("col1", "col2", "col3"))
```

### transmute -- Select and Transform

```r
# R (dplyr)
df %>% transmute(rate = count / total)
```

```python
# polars -- select is the equivalent of transmute
df.select((pl.col("count") / pl.col("total")).alias("rate"))
```

`transmute` = `mutate` + keep only new columns. In polars, `select` already does
this: it returns only the columns you specify.

### group_by + mutate -- Window Operations

```r
# R (dplyr)
df %>%
  group_by(g) %>%
  mutate(group_mean = mean(x))
```

```python
# polars -- use .over() for grouped window operations
df.with_columns(
    pl.col("x").mean().over("g").alias("group_mean")
)
```

The `.over()` method is polars' equivalent of dplyr's grouped mutate. It computes
the expression within groups but keeps all rows (no aggregation).

---

## Section 2: Joins

### Join Type Mapping

| R (dplyr) | polars | Notes |
|-----------|--------|-------|
| `left_join(df1, df2, by = "key")` | `df1.join(df2, on="key", how="left")` | |
| `inner_join(df1, df2, by = "key")` | `df1.join(df2, on="key", how="inner")` | `how="inner"` is the default |
| `full_join(df1, df2, by = "key")` | `df1.join(df2, on="key", how="full")` | NOT `how="outer"` in polars 1.x |
| `right_join(df1, df2, by = "key")` | `df1.join(df2, on="key", how="right")` | |
| `anti_join(df1, df2, by = "key")` | `df1.join(df2, on="key", how="anti")` | |
| `semi_join(df1, df2, by = "key")` | `df1.join(df2, on="key", how="semi")` | |
| `cross_join(df1, df2)` | `df1.join(df2, how="cross")` | No `on` needed |

**Different column names for join keys:**

```r
# R (dplyr)
df1 %>% left_join(df2, by = c("a" = "b"))
```

```python
# polars
df1.join(df2, left_on="a", right_on="b", how="left")
```

**Multiple join keys:**

```r
# R (dplyr)
df1 %>% left_join(df2, by = c("id", "year"))
df1 %>% left_join(df2, by = c("id" = "student_id", "year" = "acad_year"))
```

```python
# polars
df1.join(df2, on=["id", "year"], how="left")
df1.join(df2, left_on=["id", "year"], right_on=["student_id", "acad_year"], how="left")
```

**Suffix handling for duplicate column names:**

```r
# R (dplyr)
df1 %>% left_join(df2, by = "id", suffix = c(".x", ".y"))
```

```python
# polars -- single suffix applied to right-side duplicates
df1.join(df2, on="id", how="left", suffix="_right")
# custom suffix
df1.join(df2, on="id", how="left", suffix="_from_df2")
```

R allows specifying a suffix pair for both sides; polars only renames the
right-side duplicates with a single suffix string.

**Coalescing join (full join with merged keys):**

```r
# R (dplyr) -- full_join coalesces join keys by default
df1 %>% full_join(df2, by = "id")
```

```python
# polars -- use coalesce=True to merge the key columns
df1.join(df2, on="id", how="full", coalesce=True)
```

**As-of join (time-based nearest match):**

```r
# R -- no native dplyr equivalent; data.table has roll
# library(data.table)
# DT1[DT2, on = "timestamp", roll = TRUE]
```

```python
# polars -- join_asof for time-based nearest-match joins
df1.sort("timestamp").join_asof(
    df2.sort("timestamp"),
    on="timestamp",
    strategy="backward",  # most recent value <= event time
)
```

---

## Section 3: Reshaping (tidyr)

### pivot_longer -- Wide to Long

```r
# R (tidyr)
df %>% pivot_longer(
  cols = c(pop_2020, pop_2021, pop_2022),
  names_to = "year",
  values_to = "population"
)
```

```python
# polars -- unpivot (formerly melt)
df.unpivot(
    on=["pop_2020", "pop_2021", "pop_2022"],
    variable_name="year",
    value_name="population",
)
```

The `on` parameter lists the columns to unpivot. Columns not listed remain as
identifiers automatically, or specify them explicitly with the `index` parameter.

```python
# polars -- explicit index columns
df.unpivot(
    on=["pop_2020", "pop_2021", "pop_2022"],
    index=["state", "county"],
    variable_name="year",
    value_name="population",
)
```

**Using column selectors for wide columns:**

```r
# R (tidyr)
df %>% pivot_longer(starts_with("pop_"), names_to = "year", values_to = "population")
```

```python
# polars
df.unpivot(on=cs.starts_with("pop_"), variable_name="year", value_name="population")
```

### pivot_wider -- Long to Wide

```r
# R (tidyr)
df %>% pivot_wider(names_from = product, values_from = sales)
df %>% pivot_wider(id_cols = date, names_from = product, values_from = sales)
```

```python
# polars
df.pivot(on="product", values="sales")
df.pivot(on="product", index="date", values="sales")
```

**With aggregation (when duplicates exist):**

```r
# R (tidyr)
df %>% pivot_wider(names_from = product, values_from = sales, values_fn = sum)
```

```python
# polars
df.pivot(on="product", index="date", values="sales", aggregate_function="sum")
```

Note: `pivot` is available only in eager mode in polars.

### separate -- Split a Column

```r
# R (tidyr)
df %>% separate(col, into = c("first", "second"), sep = "-")
```

```python
# polars -- split and extract struct fields
df.with_columns(
    pl.col("col").str.split("-").list.get(0).alias("first"),
    pl.col("col").str.split("-").list.get(1).alias("second"),
)
```

An alternative using `str.split_exact` which returns a struct:

```python
# polars -- split_exact returns a struct with named fields
df.with_columns(
    pl.col("col").str.split_exact("-", 1).struct.rename_fields(["first", "second"])
).unnest("col")
```

### unite -- Combine Columns

```r
# R (tidyr)
df %>% unite(new_col, col1, col2, sep = "_")
```

```python
# polars
df.with_columns(
    pl.concat_str(["col1", "col2"], separator="_").alias("new_col")
)
```

### fill -- Fill Missing Values Down/Up

```r
# R (tidyr)
df %>% fill(x, .direction = "down")
df %>% fill(x, .direction = "up")
```

```python
# polars
df.with_columns(pl.col("x").forward_fill())
df.with_columns(pl.col("x").backward_fill())
```

### replace_na -- Replace Missing Values

```r
# R (tidyr)
df %>% replace_na(list(x = 0, y = "unknown"))
```

```python
# polars
df.with_columns(
    pl.col("x").fill_null(0),
    pl.col("y").fill_null("unknown"),
)
```

### drop_na -- Remove Rows with Missing Values

```r
# R (tidyr)
df %>% drop_na()
df %>% drop_na(x, y)
```

```python
# polars
df.drop_nulls()
df.drop_nulls(subset=["x", "y"])
```

### nest / unnest -- Nested DataFrames

```r
# R (tidyr)
df %>% nest(data = c(x, y))
df %>% unnest(data)
```

```python
# polars -- nesting is achieved via group_by collecting into list columns
df.group_by("group_col").agg(pl.col("x", "y"))
# This creates list columns; true nested DataFrames are not a polars concept

# Explode (unnest) list columns back to rows
df.explode("x", "y")
```

The paradigm differs: tidyr nests into embedded tibbles, while polars collects
grouped values into list-typed columns. Use `.explode()` to expand list columns
back to individual rows.

### complete -- Make Implicit Missing Values Explicit

```r
# R (tidyr)
df %>% complete(state, year)
```

```python
# polars -- no direct equivalent; manual cross-join + left-join pattern
states = df.select("state").unique()
years = df.select("year").unique()
grid = states.join(years, how="cross")
grid.join(df, on=["state", "year"], how="left")
```

---

## Section 4: across() and Column Selection

### across -- Apply Functions to Multiple Columns

R's `across()` applies one or more functions to a selection of columns. Polars
achieves the same with column selectors (`cs`) and multi-column expressions.

**Single function across numeric columns:**

```r
# R (dplyr)
df %>% summarize(across(where(is.numeric), mean))
```

```python
# polars
df.select(cs.numeric().mean())
```

**Single function across named columns:**

```r
# R (dplyr)
df %>% mutate(across(c(x, y, z), round, digits = 2))
```

```python
# polars
df.with_columns(pl.col("x", "y", "z").round(2))
```

**Multiple functions across columns:**

```r
# R (dplyr)
df %>% summarize(across(c(x, y), list(mean = mean, sd = sd)))
# produces: x_mean, x_sd, y_mean, y_sd
```

```python
# polars -- build explicit expressions
df.select(
    pl.col("x").mean().alias("x_mean"),
    pl.col("x").std().alias("x_sd"),
    pl.col("y").mean().alias("y_mean"),
    pl.col("y").std().alias("y_sd"),
)
```

Polars does not have a single `across`-equivalent that auto-generates suffixed
names. Build the expressions explicitly for clarity.

**Column selector reference (tidyselect to polars cs):**

| tidyselect (R) | polars `cs` / `pl.col` | Example |
|----------------|------------------------|---------|
| `where(is.numeric)` | `cs.numeric()` | All numeric columns |
| `where(is.character)` | `cs.string()` | All string columns |
| `starts_with("x")` | `cs.starts_with("x")` | Columns starting with "x" |
| `ends_with("_rate")` | `cs.ends_with("_rate")` | Columns ending with "_rate" |
| `contains("enroll")` | `cs.contains("enroll")` | Columns containing substring |
| `matches("^pop_\\d{4}$")` | `cs.matches("^pop_\\d{4}$")` | Regex match on column names |
| `all_of(vars)` | `cs.by_name(vars)` | Exact name match from list |
| `everything()` | `pl.all()` | All columns |
| `last_col()` | `pl.last()` | Last column |

**Set operations on selectors:**

```python
# polars -- combine selectors with set operations
cs.numeric() - cs.by_name("id")         # numeric columns except "id"
cs.starts_with("pop") | cs.ends_with("_total")  # union
cs.numeric() & cs.starts_with("score")  # intersection
```

---

## Section 5: case_when and Conditional Logic

### case_when -- Multiple Conditions

```r
# R (dplyr)
df %>% mutate(
  category = case_when(
    x > 100 ~ "high",
    x > 50  ~ "medium",
    x > 0   ~ "low",
    TRUE    ~ "zero_or_negative"
  )
)
```

```python
# polars
df.with_columns(
    pl.when(pl.col("x") > 100).then(pl.lit("high"))
      .when(pl.col("x") > 50).then(pl.lit("medium"))
      .when(pl.col("x") > 0).then(pl.lit("low"))
      .otherwise(pl.lit("zero_or_negative"))
      .alias("category")
)
```

Note the `.lit()` requirement: polars needs `pl.lit()` for literal (scalar) values
in expressions. Forgetting `pl.lit()` is one of the most common polars mistakes for
new users. When the `.then()` value is a column reference, use `pl.col()` instead.

### if_else -- Simple Two-Way Conditional

```r
# R (dplyr)
df %>% mutate(flag = if_else(x > 0, "positive", "non_positive"))
```

```python
# polars
df.with_columns(
    pl.when(pl.col("x") > 0)
      .then(pl.lit("positive"))
      .otherwise(pl.lit("non_positive"))
      .alias("flag")
)
```

### Conditional with column values (not literals)

```r
# R (dplyr)
df %>% mutate(result = if_else(use_adjusted, adjusted_value, raw_value))
```

```python
# polars
df.with_columns(
    pl.when(pl.col("use_adjusted"))
      .then(pl.col("adjusted_value"))
      .otherwise(pl.col("raw_value"))
      .alias("result")
)
```

### coalesce -- First Non-NA Value

```r
# R (dplyr)
df %>% mutate(val = coalesce(primary, secondary, 0))
```

```python
# polars
df.with_columns(
    pl.coalesce(pl.col("primary"), pl.col("secondary"), pl.lit(0)).alias("val")
)
```

### na_if -- Replace Value with NA

```r
# R (dplyr)
df %>% mutate(x = na_if(x, -99))
```

```python
# polars
df.with_columns(
    pl.when(pl.col("x") == -99).then(None).otherwise(pl.col("x")).alias("x")
)
```

---

## Section 6: Window Functions

Window functions compute values within groups without collapsing rows. In dplyr,
these run inside `group_by() %>% mutate()`. In polars, use `.over()`.

### lag / lead -- Shifted Values

```r
# R (dplyr)
df %>% mutate(prev_x = lag(x))
df %>% mutate(next_x = lead(x))
df %>% mutate(prev_x = lag(x, 2))  # lag by 2
```

```python
# polars
df.with_columns(pl.col("x").shift(1).alias("prev_x"))
df.with_columns(pl.col("x").shift(-1).alias("next_x"))
df.with_columns(pl.col("x").shift(2).alias("prev_x"))
```

**Grouped lag/lead:**

```r
# R (dplyr)
df %>% group_by(g) %>% mutate(prev_x = lag(x))
```

```python
# polars
df.with_columns(pl.col("x").shift(1).over("g").alias("prev_x"))
```

### Cumulative Functions

| R (dplyr) | polars | Notes |
|-----------|--------|-------|
| `cumsum(x)` | `pl.col("x").cum_sum()` | |
| `cumprod(x)` | `pl.col("x").cum_prod()` | |
| `cummax(x)` | `pl.col("x").cum_max()` | |
| `cummin(x)` | `pl.col("x").cum_min()` | |
| `cumall(x)` | `pl.col("x").cum_max()` on boolean | No direct equivalent |
| `cumany(x)` | `pl.col("x").cum_min()` on boolean | No direct equivalent |
| `cummean(x)` | Manual: `cum_sum() / cum_count()` | No single method |

**Grouped cumulative:**

```r
# R (dplyr)
df %>% group_by(g) %>% mutate(running_total = cumsum(x))
```

```python
# polars
df.with_columns(pl.col("x").cum_sum().over("g").alias("running_total"))
```

### Ranking Functions

| R (dplyr) | polars | Notes |
|-----------|--------|-------|
| `row_number()` | `pl.col("x").rank(method="ordinal")` | Unique rank, no ties |
| `min_rank()` | `pl.col("x").rank(method="min")` | Ties get minimum rank |
| `dense_rank()` | `pl.col("x").rank(method="dense")` | No gaps after ties |
| `percent_rank()` | Manual calculation | `(rank - 1) / (n - 1)` |
| `cume_dist()` | Manual calculation | `rank / n` |
| `ntile(4)` | `pl.col("x").qcut(4)` | Approximate; returns categorical |

**Grouped ranking:**

```r
# R (dplyr)
df %>% group_by(g) %>% mutate(rnk = dense_rank(x))
```

```python
# polars
df.with_columns(
    pl.col("x").rank(method="dense").over("g").alias("rnk")
)
```

**Row number within groups:**

```r
# R (dplyr)
df %>% group_by(g) %>% mutate(row_num = row_number())
```

```python
# polars
df.with_columns(
    pl.col("x").cum_count().over("g").alias("row_num")
)
```

### Percentage of Group

```r
# R (dplyr)
df %>% group_by(g) %>% mutate(pct = x / sum(x))
```

```python
# polars
df.with_columns(
    (pl.col("x") / pl.col("x").sum().over("g")).alias("pct")
)
```

### Rolling Window Aggregations

```r
# R (slider / zoo)
library(slider)
df %>% mutate(rolling_avg = slide_dbl(x, mean, .before = 6))
```

```python
# polars
df.with_columns(
    pl.col("x").rolling_mean(window_size=7).alias("rolling_avg")
)
```

**Grouped rolling:**

```python
# polars
df.with_columns(
    pl.col("x").rolling_mean(window_size=7).over("g").alias("rolling_avg")
)
```

---

## Section 7: Pipe Operator and Method Chaining

### Conceptual Equivalence

R's pipe operator (`%>%` from magrittr or `|>` from base R 4.1+) passes the result
of the left side as the first argument to the right side. Python's method chaining
calls methods on the returned object. Both achieve the same goal: readable
left-to-right data transformation pipelines.

### Full Pipeline Comparison

```r
# R (dplyr)
result <- df %>%
  filter(year == 2020) %>%
  mutate(rate = count / total) %>%
  group_by(state) %>%
  summarize(avg_rate = mean(rate)) %>%
  arrange(desc(avg_rate)) %>%
  head(10)
```

```python
# polars
result = (
    df
    .filter(pl.col("year") == 2020)
    .with_columns((pl.col("count") / pl.col("total")).alias("rate"))
    .group_by("state")
    .agg(pl.col("rate").mean().alias("avg_rate"))
    .sort("avg_rate", descending=True)
    .head(10)
)
```

Key syntax differences in the chain:
- Python uses parentheses around the entire chain to allow line breaks
- Each method call is on the returned object (no pipe needed)
- Column references always require `pl.col()` (no bare names)
- New column names use `.alias()` rather than `name =`

### Multi-Step Pipeline with Intermediate Validation

In DAAF workflows, pipelines often include intermediate checks:

```python
# polars -- multi-step with validation
df_clean = (
    df
    .filter(pl.col("year") == 2020)
    .filter(pl.col("enrollment").is_not_null())
    .with_columns(
        (pl.col("frl_count") / pl.col("enrollment")).alias("frl_rate")
    )
)
print(f"Rows after filter: {df_clean.height}")
assert df_clean.height > 0, "No rows survived filtering"

result = (
    df_clean
    .group_by("state")
    .agg(
        pl.col("frl_rate").mean().alias("avg_frl_rate"),
        pl.len().alias("n_schools"),
    )
    .sort("avg_frl_rate", descending=True)
)
```

### Assignment Pipe

```r
# R -- assignment pipe (modifies in place)
df %<>% filter(year == 2020)
```

```python
# polars -- reassign the variable
df = df.filter(pl.col("year") == 2020)
```

Polars DataFrames are immutable; every operation returns a new DataFrame. Reassign
the variable to update it.

---

## Section 8: Lazy Evaluation

### Concept Mapping

| R concept | polars concept | Notes |
|-----------|---------------|-------|
| Standard eval (dplyr) | Eager mode | Immediate execution |
| dbplyr (database backend) | Lazy mode | Build query plan, execute on collect |
| data.table optimization | Query optimizer | Both optimize under the hood |

### Eager vs Lazy in Polars

```python
# Eager: reads entire file, executes immediately
df = pl.read_parquet("data.parquet")
result = df.filter(pl.col("x") > 5).select("x", "y")

# Lazy: builds query plan, optimizes, executes on .collect()
lf = pl.scan_parquet("data.parquet")
result = lf.filter(pl.col("x") > 5).select("x", "y").collect()
```

### Why Lazy Matters

Lazy mode enables the query optimizer to:
- **Predicate pushdown**: push filters before reads (read only matching rows)
- **Projection pushdown**: read only needed columns from disk
- **Expression simplification**: combine/reorder operations
- **Parallel execution**: run independent branches simultaneously

R has no direct equivalent for single-file operations. The closest analogy is
`dbplyr`, which builds SQL queries lazily and executes them on a database.

### DAAF Pattern: scan_parquet

The standard DAAF pattern for reading data:

```python
# polars -- preferred DAAF pattern
df = (
    pl.scan_parquet(path)
    .filter(pl.col("year") >= 2015)
    .select("id", "year", "enrollment", "frl_count")
    .collect()
)
```

This reads only the required columns and rows from the Parquet file. The equivalent
eager approach would load the entire file into memory first.

### Inspecting the Query Plan

```python
# polars -- see what the optimizer does
lf = pl.scan_parquet(path).filter(pl.col("x") > 5).select("x", "y")
print(lf.explain())             # optimized plan
print(lf.explain(optimized=False))  # naive plan before optimization
```

No R equivalent exists for single-file operations, though `dbplyr::show_query()`
serves a similar purpose for database operations.

---

## Quick Reference Table

A condensed lookup for the most common core data manipulation translations:

| R (tidyverse) | polars | Category |
|---------------|--------|----------|
| `select(a, b)` | `.select("a", "b")` | Columns |
| `select(-a)` | `.select(pl.exclude("a"))` | Columns |
| `filter(x > 5)` | `.filter(pl.col("x") > 5)` | Rows |
| `mutate(y = x * 2)` | `.with_columns((pl.col("x") * 2).alias("y"))` | Transform |
| `arrange(desc(x))` | `.sort("x", descending=True)` | Sort |
| `group_by(g) %>% summarize(m = mean(x))` | `.group_by("g").agg(pl.col("x").mean().alias("m"))` | Aggregate |
| `group_by(g) %>% mutate(m = mean(x))` | `.with_columns(pl.col("x").mean().over("g").alias("m"))` | Window |
| `rename(new = old)` | `.rename({"old": "new"})` | Rename |
| `distinct()` | `.unique()` | Deduplicate |
| `left_join(df2, by = "k")` | `.join(df2, on="k", how="left")` | Join |
| `pivot_longer(...)` | `.unpivot(...)` | Reshape |
| `pivot_wider(...)` | `.pivot(...)` | Reshape |
| `case_when(...)` | `pl.when().then().when().then().otherwise()` | Conditional |
| `lag(x)` | `.shift(1)` | Window |
| `%>%` / `\|>` | Method chaining | Pipe |
