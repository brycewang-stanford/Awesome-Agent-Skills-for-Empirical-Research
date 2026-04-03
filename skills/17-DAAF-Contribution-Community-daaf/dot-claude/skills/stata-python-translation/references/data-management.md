# Data Management: Stata to Python (polars)

> **Companion file:** For string operations, date/time operations, and value
> labels / categorical types, see `strings-dates-labels.md`.

This document provides an exhaustive command-by-command translation between Stata's
core data management commands and Python's polars library. The fundamental mental
model shift: Stata operates on a single implicit dataset and modifies it in place;
polars operates on explicitly named DataFrames and returns new objects from every
operation. Stata users will find that most commands have a direct polars equivalent,
but the grammar requires (a) naming the DataFrame, (b) wrapping column references
in `pl.col()`, and (c) reassigning the result (`df = df.operation(...)`).

> **Versions referenced:**
> Python: polars 1.38.1, pyreadstat 1.2.x
> See SKILL.md for the complete version table.

> **Sources:** Sullivan, "Stata to Python Equivalents" (danielmsullivan.com, accessed
> 2026-03-28); Turrell, "Coming from Stata" in *Coding for Economists*
> (aeturrell.github.io, accessed 2026-03-28); pandas documentation, "Comparison with
> Stata" (pandas.pydata.org, accessed 2026-03-28); polars 1.x User Guide and API
> Reference (docs.pola.rs, accessed 2026-03-28); pyreadstat (github.com/Roche/pyreadstat,
> accessed 2026-03-28); Stata manuals (stata.com/manuals, accessed 2026-03-28).

---

## Section 1: Data I/O

### use / save / import / export

| Stata | polars | Notes |
|-------|--------|-------|
| `use myfile.dta` | `df = pl.read_parquet("myfile.parquet")` | DAAF uses parquet exclusively |
| `use var1 var2 using myfile.dta` | `df = pl.read_parquet("myfile.parquet", columns=["var1", "var2"])` | Column-selective read |
| `save myfile.dta, replace` | `df.write_parquet("myfile.parquet")` | DAAF mandate: parquet only |
| `import delimited myfile.csv` | `df = pl.read_csv("myfile.csv")` | polars infers types aggressively |
| `import delimited, delimiters("\t")` | `df = pl.read_csv("myfile.csv", separator="\t")` | Tab-delimited |
| `export delimited myfile.csv` | `df.write_csv("myfile.csv")` | |
| `import excel myfile.xlsx` | `df = pl.read_excel("myfile.xlsx")` | Requires `xlsx2csv` or `openpyxl` backend |

### Reading .dta files (bridge pattern)

Polars cannot read `.dta` files natively. Use pyreadstat to preserve Stata metadata
including value labels, variable labels, and extended missing values:

```python
# pyreadstat bridge -- preserves all Stata metadata
import pyreadstat
df_pd, meta = pyreadstat.read_dta("myfile.dta")
df = pl.from_pandas(df_pd)

# Metadata available from pyreadstat:
# meta.variable_value_labels  -- dict: {varname: {int: label_string, ...}}
# meta.column_names_to_labels -- dict: {varname: "variable label text"}
# meta.original_variable_types -- dict: {varname: "stata_type"}
```

```python
# Simpler bridge via pandas (loses some metadata)
df = pl.from_pandas(pd.read_stata("myfile.dta"))
```

### Lazy scanning (preferred DAAF pattern)

```python
# Lazy scan -- reads only needed columns and rows from Parquet
df = (
    pl.scan_parquet("myfile.parquet")
    .filter(pl.col("year") >= 2015)
    .select("id", "year", "enrollment")
    .collect()
)
```

> **Key behavioral differences:**
> - Stata loads one dataset into memory at a time (the "one dataset" model). Python
>   holds arbitrarily many DataFrames simultaneously as separate variables.
> - Stata's `.dta` format embeds variable labels, value labels, and format specs.
>   Parquet does not -- store metadata in documentation or a companion schema dict.
> - The single-dataset model eliminates `preserve`/`restore` in Python: creating a
>   subset never destroys the original.

**Sources:** polars User Guide (docs.pola.rs, accessed 2026-03-28); pyreadstat
(github.com/Roche/pyreadstat, accessed 2026-03-28); pandas "Comparison with Stata"
(pandas.pydata.org, accessed 2026-03-28).

---

## Section 2: Variable Creation and Modification

### generate -- Create a New Column

```stata
* Stata
generate newvar = oldvar + 7
```

```python
# polars
df = df.with_columns((pl.col("oldvar") + 7).alias("newvar"))
```

The `.alias()` call names the output column. This is how polars maps Stata's
`generate newvar = expr` syntax.

### generate ... if -- Conditional Creation

```stata
* Stata
generate category = "low" if income < 30000
replace category = "mid" if income >= 30000 & income < 80000
replace category = "high" if income >= 80000
```

```python
# polars
df = df.with_columns(
    pl.when(pl.col("income") < 30000).then(pl.lit("low"))
      .when(pl.col("income") < 80000).then(pl.lit("mid"))
      .otherwise(pl.lit("high"))
      .alias("category")
)
```

> **Key behavioral difference:** Stata's `generate var = expr if condition` sets
> unmet rows to `.` (missing). In polars, use
> `pl.when(cond).then(expr).otherwise(None)` to replicate this. Without the
> `.otherwise()` clause, polars sets unmet rows to null, which happens to match
> Stata's behavior -- but being explicit is safer.

### replace -- Overwrite a Column

**Unconditional replace:**

```stata
* Stata
replace var = var + 1
```

```python
# polars
df = df.with_columns(pl.col("var") + 1)
```

When the expression is derived from `pl.col("var")`, polars infers the output name
automatically -- no `.alias()` needed.

**Conditional replace:**

```stata
* Stata
replace income = 0 if missing(income)
```

```python
# polars
df = df.with_columns(
    pl.when(pl.col("income").is_null())
      .then(pl.lit(0))
      .otherwise(pl.col("income"))
      .alias("income")
)
```

Or more concisely using `fill_null`:

```python
# polars -- simpler for the common "replace missing with value" case
df = df.with_columns(pl.col("income").fill_null(0))
```

> **Key behavioral difference:** Stata modifies the dataset in place. Polars returns
> a new DataFrame (immutable). Always reassign: `df = df.with_columns(...)`.

### Multiple columns in one call

```stata
* Stata
generate rate = count / total
generate pct = rate * 100
```

```python
# polars -- NOTE: columns created in the same with_columns cannot reference each other
df = df.with_columns(
    (pl.col("count") / pl.col("total")).alias("rate"),
    (pl.col("count") / pl.col("total") * 100).alias("pct"),
)
```

Unlike Stata, polars `with_columns` does not see columns created earlier in the same
call. Each expression sees the original DataFrame state. To use a derived column,
chain a second `with_columns`:

```python
# polars -- sequential dependency
df = df.with_columns(
    (pl.col("count") / pl.col("total")).alias("rate"),
)
df = df.with_columns(
    (pl.col("rate") * 100).alias("pct"),
)
```

### rename

```stata
* Stata
rename old new
rename (old1 old2) (new1 new2)
```

```python
# polars -- dictionary-based; can rename multiple at once
df = df.rename({"old": "new"})
df = df.rename({"old1": "new1", "old2": "new2"})
```

Note the reversed key-value order compared to Stata: in polars, the dict key is the
old name and the value is the new name.

### Type casting

| Stata | polars | Notes |
|-------|--------|-------|
| `destring var, replace` | `df = df.with_columns(pl.col("var").cast(pl.Float64))` | String to numeric |
| `destring var, replace force` | `df = df.with_columns(pl.col("var").cast(pl.Float64, strict=False))` | `strict=False` coerces invalid to null |
| `destring var, gen(numvar)` | `df = df.with_columns(pl.col("var").cast(pl.Float64).alias("numvar"))` | New numeric column |
| `tostring var, replace` | `df = df.with_columns(pl.col("var").cast(pl.Utf8))` | Numeric to string |
| `tostring var, format(%9.2f)` | `df = df.with_columns(pl.col("var").round(2).cast(pl.Utf8))` | Formatted string |

> **Key behavioral difference:** Stata's `destring` fails if non-numeric characters
> are present unless `force` is specified (which sets those to `.`). Polars'
> `cast(pl.Float64, strict=False)` sets unparseable values to `null`.

**Sources:** Sullivan, "Stata to Python Equivalents" (danielmsullivan.com, accessed
2026-03-28); Turrell, "Coming from Stata" (aeturrell.github.io, accessed 2026-03-28);
polars User Guide (docs.pola.rs, accessed 2026-03-28).

---

## Section 3: Sample Selection

### keep variables / drop variables -- Column Selection

```stata
* Stata
keep var1 var2 var3
keep varstem*
drop var1 var2
drop varstem*
```

```python
# polars
df = df.select("var1", "var2", "var3")
df = df.select(cs.starts_with("varstem"))         # requires: import polars.selectors as cs
df = df.drop("var1", "var2")
df = df.select(~cs.starts_with("varstem"))         # negate selector with ~
```

### Column selection by type

```stata
* Stata -- no built-in type selection; must use ds command
ds, has(type numeric)
```

```python
# polars -- column selectors by type
import polars.selectors as cs
df = df.select(cs.numeric())                       # all numeric columns
df = df.select(cs.string())                        # all string columns
df = df.select(cs.temporal())                      # all date/time columns
```

### keep if / drop if -- Row Selection

```stata
* Stata
keep if year == 2020
keep if enrollment > 500 & !missing(enrollment)
drop if missing(income)
```

```python
# polars
df = df.filter(pl.col("year") == 2020)
df = df.filter(pl.col("enrollment") > 500)         # nulls excluded automatically
df = df.filter(pl.col("income").is_not_null())
```

> **NEGATION TRAP:** Stata's `drop if condition` becomes `filter(~condition)` in
> polars -- note the tilde (`~`) for negation:

```stata
* Stata
drop if state == "PR"
```

```python
# polars
df = df.filter(pl.col("state") != "PR")
# or equivalently:
df = df.filter(~(pl.col("state") == "PR"))
```

### Membership filtering

```stata
* Stata
keep if inlist(state, "CA", "NY", "TX")
drop if inlist(race, 8, 9)
```

```python
# polars
df = df.filter(pl.col("state").is_in(["CA", "NY", "TX"]))
df = df.filter(~pl.col("race").is_in([8, 9]))
```

### Positional selection (in)

```stata
* Stata
keep in 1/10
keep in -5/l
```

```python
# polars
df = df.head(10)                                   # first 10 rows
df = df.tail(5)                                    # last 5 rows
df = df.slice(0, 10)                               # offset 0, length 10
```

Note: Stata's `in` is 1-indexed; polars' `slice` is 0-indexed.

### Compound conditions

```stata
* Stata
keep if age >= 18 & age <= 65 & !missing(income)
```

```python
# polars -- parentheses around each condition are mandatory (Python operator precedence)
df = df.filter(
    (pl.col("age") >= 18) & (pl.col("age") <= 65) & pl.col("income").is_not_null()
)
# or using is_between:
df = df.filter(
    pl.col("age").is_between(18, 65) & pl.col("income").is_not_null()
)
```

> **Key behavioral difference -- the missing value trap in reverse:**
> In Stata, `keep if income > 50000` INCLUDES rows where income is missing (because
> `.` sorts as +infinity, so `. > 50000` is TRUE). In polars,
> `df.filter(pl.col("income") > 50000)` EXCLUDES null rows automatically. This is
> the single most dangerous difference for Stata-to-Python transitions: the same
> logical intent produces different row sets.

**Sources:** Sullivan, "Stata to Python Equivalents" (danielmsullivan.com, accessed
2026-03-28); pandas "Comparison with Stata" (pandas.pydata.org, accessed 2026-03-28);
polars User Guide (docs.pola.rs, accessed 2026-03-28).

---

## Section 4: Sorting

### sort -- Ascending Sort

```stata
* Stata
sort var1 var2
```

```python
# polars
df = df.sort("var1", "var2")
```

### gsort -- Mixed Ascending/Descending

```stata
* Stata
gsort -var1 var2
gsort -var1 -var2
```

```python
# polars
df = df.sort("var1", "var2", descending=[True, False])
df = df.sort("var1", "var2", descending=True)       # scalar True applies to all
```

### Null placement

```stata
* Stata -- missing values sort LAST (greater than all numeric values)
sort var1
```

```python
# polars -- nulls sort last by default (same as Stata)
df = df.sort("var1", nulls_last=True)               # explicit (default behavior)
df = df.sort("var1", nulls_last=False)              # nulls first
```

> **Key behavioral difference:** Stata sorts in place. Polars returns a new
> DataFrame; must reassign.

**Sources:** polars User Guide (docs.pola.rs, accessed 2026-03-28).

---

## Section 5: Group Operations (by: prefix)

This is the most conceptually challenging section for Stata users. Stata's `by:`
prefix maps to **two completely different** polars patterns, and choosing the wrong
one produces silently incorrect results.

### The Two Patterns

| Stata Pattern | Polars Pattern | Rows Preserved? | Use When |
|---------------|---------------|-----------------|----------|
| `bysort group: gen/egen` | `.over("group")` inside `with_columns` | Yes (window function) | Adding a group stat to each row |
| `collapse ..., by(group)` | `.group_by("group").agg(...)` | No (aggregation) | Reducing to one row per group |

### Pattern 1: Window functions (preserves rows)

Stata's `bysort group: gen newvar = expr` and `bysort group: egen newvar = func()`
create a new column where each row gets its group's value. In polars, this is
`.over("group")`:

```stata
* Stata
bysort state: gen state_count = _N
bysort state: gen state_obs = _n
bysort state: egen mean_score = mean(test_score)
bysort state: egen total_enroll = total(enrollment)
bysort state: egen sd_score = sd(test_score)
```

```python
# polars -- window functions via .over()
df = df.with_columns(
    pl.len().over("state").alias("state_count"),                    # _N
    pl.col("test_score").cum_count().over("state").alias("state_obs"),  # _n (0-based)
    pl.col("test_score").mean().over("state").alias("mean_score"),
    pl.col("enrollment").sum().over("state").alias("total_enroll"),
    pl.col("test_score").std().over("state").alias("sd_score"),
)
```

### Pattern 2: Aggregation (reduces rows)

Stata's `collapse` reduces the dataset to one row per group. In polars, this is
`group_by().agg()`:

```stata
* Stata
collapse (mean) test_score (sum) enrollment (count) n=school_id, by(state)
```

```python
# polars
state_stats = df.group_by("state").agg(
    pl.col("test_score").mean(),
    pl.col("enrollment").sum(),
    pl.col("school_id").count().alias("n"),
)
```

> **Critical difference:** Stata's `collapse` **destroys** the original data
> (replaces it with the collapsed version). Polars `group_by().agg()` returns a
> **new** DataFrame; the original is preserved.

### The _n and _N system variables

Stata's `_n` (row number within group, 1-based) and `_N` (group size) are system
variables available inside `by:` blocks. Polars equivalents:

| Stata | polars | Notes |
|-------|--------|-------|
| `_N` (group size) | `pl.len().over("group")` | |
| `_n` (row number in group) | `pl.col("x").cum_count().over("group")` | 0-based in polars vs 1-based in Stata |
| `_n == 1` (first in group) | `pl.int_range(pl.len()).over("group") == 0` | Or use `group_by().first()` |
| `_n == _N` (last in group) | Manual: compare row index to group size | Or use `group_by().last()` |

```stata
* Stata -- keep first observation per group
bysort state (year): keep if _n == 1
```

```python
# polars
df = df.sort("year").group_by("state").first()
```

```stata
* Stata -- keep last observation per group
bysort state (year): keep if _n == _N
```

```python
# polars
df = df.sort("year").group_by("state").last()
```

### Lag and lead within groups

Stata's subscript notation `var[_n-1]` accesses adjacent observations. Polars uses
`.shift()`:

```stata
* Stata
bysort state (year): gen lag_score = test_score[_n-1]
bysort state (year): gen lead_score = test_score[_n+1]
bysort state (year): gen change = test_score - test_score[_n-1]
```

```python
# polars -- MUST sort first; .shift() operates on current row order
df = df.sort("state", "year").with_columns(
    pl.col("test_score").shift(1).over("state").alias("lag_score"),
    pl.col("test_score").shift(-1).over("state").alias("lead_score"),
    (pl.col("test_score") - pl.col("test_score").shift(1).over("state")).alias("change"),
)
```

> **Key behavioral difference:** Stata's `bysort state (year):` sorts within groups
> automatically before applying the subscript. Polars `.shift()` operates on whatever
> order the data is in -- you must sort explicitly first. Forgetting to sort produces
> silently wrong lag/lead values.

### Multiple grouping variables

```stata
* Stata
bysort state district: egen district_mean = mean(test_score)
```

```python
# polars -- pass a list to .over()
df = df.with_columns(
    pl.col("test_score").mean().over(["state", "district"]).alias("district_mean")
)
```

### Panel time-series operators (xtset context)

Stata's `xtset` declaration enables `L.`, `F.`, `D.` operators:

```stata
* Stata
xtset state_id year
gen lag_score = L.test_score
gen lead_score = F.test_score
gen diff_score = D.test_score
```

```python
# polars -- no declaration needed; explicit sort + shift
df = df.sort("state_id", "year").with_columns(
    pl.col("test_score").shift(1).over("state_id").alias("lag_score"),
    pl.col("test_score").shift(-1).over("state_id").alias("lead_score"),
    (pl.col("test_score") - pl.col("test_score").shift(1).over("state_id"))
      .alias("diff_score"),
)
```

**Sources:** Sullivan, "Stata to Python Equivalents" (danielmsullivan.com, accessed
2026-03-28); Turrell, "Coming from Stata" (aeturrell.github.io, accessed 2026-03-28);
polars User Guide, "Window functions" (docs.pola.rs, accessed 2026-03-28); Notre Dame
Library, "by, _n, _N" (libguides.library.nd.edu, accessed 2026-03-28); Poverty Action,
"Sort, by, bysort, egen" (povertyaction.github.io, accessed 2026-03-28).

---

## Section 6: egen Functions

`egen` ("extensions to generate") provides group-aware and row-wise functions.

### Group-level functions (with by:)

These attach a group statistic to every row in the group, preserving the original
row count:

| Stata `egen` | polars | Notes |
|--------------|--------|-------|
| `egen mean_x = mean(x), by(g)` | `pl.col("x").mean().over("g")` | |
| `egen sum_x = sum(x), by(g)` | `pl.col("x").sum().over("g")` | |
| `egen count_x = count(x), by(g)` | `pl.col("x").count().over("g")` | Excludes nulls |
| `egen sd_x = sd(x), by(g)` | `pl.col("x").std().over("g")` | polars uses N-1 denominator by default |
| `egen min_x = min(x), by(g)` | `pl.col("x").min().over("g")` | |
| `egen max_x = max(x), by(g)` | `pl.col("x").max().over("g")` | |
| `egen med_x = median(x), by(g)` | `pl.col("x").median().over("g")` | |
| `egen total_x = total(x)` | `pl.col("x").sum()` | No `by()` = full column |
| `egen pct_x = pctile(x), p(75) by(g)` | `pl.col("x").quantile(0.75).over("g")` | |

```stata
* Stata
bysort state: egen mean_score = mean(test_score)
bysort state: egen n_schools = count(school_id)
```

```python
# polars
df = df.with_columns(
    pl.col("test_score").mean().over("state").alias("mean_score"),
    pl.col("school_id").count().over("state").alias("n_schools"),
)
```

### egen group -- Numeric Group IDs

```stata
* Stata
egen state_id = group(state region)
```

```python
# polars -- approximate equivalent using rank on struct
df = df.with_columns(
    pl.struct("state", "region").rank("dense").alias("state_id")
)

# More exact: create lookup table, then join
group_ids = (
    df.select("state", "region").unique()
    .sort("state", "region")
    .with_row_index("state_id", offset=1)
)
df = df.join(group_ids, on=["state", "region"], how="left")
```

### egen tag -- First-Occurrence Indicator

```stata
* Stata
egen first_in_group = tag(state year)
```

```python
# polars -- 1 for first occurrence of each group, 0 otherwise
df = df.with_columns(
    (pl.int_range(pl.len()).over("state", "year") == 0)
      .cast(pl.Int32)
      .alias("first_in_group")
)
```

### Row-wise functions (rowtotal, rowmean, etc.)

These operate across columns within a single row:

| Stata `egen` | polars | Notes |
|--------------|--------|-------|
| `egen total = rowtotal(x1 x2 x3)` | `pl.sum_horizontal("x1", "x2", "x3")` | **TRAP:** see below |
| `egen avg = rowmean(x1 x2 x3)` | `pl.mean_horizontal("x1", "x2", "x3")` | |
| `egen lo = rowmin(x1 x2 x3)` | `pl.min_horizontal("x1", "x2", "x3")` | |
| `egen hi = rowmax(x1 x2 x3)` | `pl.max_horizontal("x1", "x2", "x3")` | |

```stata
* Stata
egen total_income = rowtotal(wage salary bonus)
```

```python
# polars
df = df.with_columns(
    pl.sum_horizontal("wage", "salary", "bonus").alias("total_income")
)
```

> **THE rowtotal MISSING VALUE TRAP:**
> Stata's `rowtotal()` treats missing values as **zero** by default. If `wage` is
> missing, `rowtotal(wage salary)` returns just `salary`. Polars' `sum_horizontal()`
> **propagates null** -- if any input is null, the result is null.
>
> To replicate Stata behavior, fill nulls with 0 first:
>
> ```python
> # polars -- replicate Stata rowtotal behavior (missing = 0)
> df = df.with_columns(
>     pl.sum_horizontal(
>         pl.col("wage").fill_null(0),
>         pl.col("salary").fill_null(0),
>         pl.col("bonus").fill_null(0),
>     ).alias("total_income")
> )
> ```
>
> Stata also has `rowtotal(...), missing` which returns missing if ALL values are
> missing. The `fill_null(0)` approach always returns a number, so add a null check
> if you need the "all-missing" behavior.

### egen cut -- Quantile Binning

```stata
* Stata
egen quintile = cut(income), group(5)
```

```python
# polars
df = df.with_columns(
    pl.col("income").qcut(5).alias("quintile")
)
```

### egen rank -- Within-Group Ranking

```stata
* Stata
bysort state: egen rank_score = rank(test_score)
```

```python
# polars
df = df.with_columns(
    pl.col("test_score").rank(method="average").over("state").alias("rank_score")
)
```

Polars rank methods: `"average"` (default), `"min"`, `"max"`, `"dense"`, `"ordinal"`.

**Sources:** Sullivan, "Stata to Python Equivalents" (danielmsullivan.com, accessed
2026-03-28); Stata `egen` manual (stata.com/manuals/degen.pdf); polars User Guide
(docs.pola.rs, accessed 2026-03-28).

---

## Section 7: Merging

### merge -- Join Two Datasets

| Stata | polars | Notes |
|-------|--------|-------|
| `merge 1:1 key using file2` | `df1.join(df2, on="key", how="inner")` | |
| `merge m:1 key using file2` | `df1.join(df2, on="key", how="left")` | Many-to-one: left join |
| `merge 1:m key using file2` | `df1.join(df2, on="key", how="left")` | One-to-many: left join |
| `merge m:m key using file2` | Avoid | Stata's m:m is rarely correct |
| `merge ..., keep(3)` | `df1.join(df2, on="key", how="inner")` | `_merge==3` = matched |
| `merge ..., keep(1 3)` | `df1.join(df2, on="key", how="left")` | Master + matched |

```stata
* Stata
merge m:1 state_fips using "state_names.dta"
tab _merge
keep if _merge == 3
drop _merge
```

```python
# polars
df = df.join(state_names, on="state_fips", how="left")
```

### Multiple merge keys

```stata
* Stata
merge 1:1 state_id year using "panel_data.dta"
```

```python
# polars
df = df.join(panel_data, on=["state_id", "year"], how="inner")
```

### Different key names

```stata
* Stata -- not directly supported; rename first
rename stfips state_fips
merge m:1 state_fips using "states.dta"
```

```python
# polars -- left_on / right_on for different key names
df = df.join(states, left_on="stfips", right_on="state_fips", how="left")
```

### Replicating Stata's _merge diagnostic

Stata's `merge` creates a `_merge` variable (1=master only, 2=using only, 3=matched
in both). Polars has no automatic equivalent. Replicate it manually:

```python
# polars -- replicate Stata _merge indicator
df1 = df1.with_columns(pl.lit(True).alias("_in_master"))
df2 = df2.with_columns(pl.lit(True).alias("_in_using"))
merged = df1.join(df2, on="key", how="full", coalesce=True)
merged = merged.with_columns(
    pl.when(pl.col("_in_master").is_not_null() & pl.col("_in_using").is_not_null())
      .then(pl.lit(3))
      .when(pl.col("_in_master").is_not_null())
      .then(pl.lit(1))
      .otherwise(pl.lit(2))
      .alias("_merge")
)
# Tabulate the merge result
print(merged.group_by("_merge").len().sort("_merge"))
```

### Assert on merge results

```stata
* Stata
merge m:1 state_fips using "states.dta", assert(3) nogenerate
```

```python
# polars -- validate all rows matched
pre_count = df.height
df = df.join(states, on="state_fips", how="left")
unmatched = df.filter(pl.col("state_name").is_null()).height
assert unmatched == 0, f"{unmatched} rows failed to match on state_fips"
assert df.height == pre_count, f"Row count changed: {pre_count} -> {df.height}"
```

> **Key behavioral differences:**
> - Stata requires the dataset to be sorted on merge keys. Polars does not.
> - Stata merges one in-memory dataset with a file on disk. Polars merges two
>   in-memory DataFrames.
> - Stata's `_merge` variable is automatic. Polars requires explicit diagnostics.
> - Suffix handling: Stata appends nothing (requires unique names). Polars adds a
>   configurable suffix (`suffix="_right"` by default) to duplicate non-key columns.

### Join types (complete mapping)

| Stata equivalent | polars `how=` | Description |
|-----------------|---------------|-------------|
| `merge ..., keep(3)` | `"inner"` | Only matched rows |
| `merge ..., keep(1 3)` | `"left"` | All from left + matched from right |
| `merge ..., keep(2 3)` | `"right"` | All from right + matched from left |
| `merge ..., keep(1 2 3)` | `"full"` | All rows from both sides |
| (no Stata equivalent) | `"anti"` | Rows in left NOT in right |
| (no Stata equivalent) | `"semi"` | Rows in left that HAVE a match in right |
| (no Stata equivalent) | `"cross"` | Cartesian product (every row x every row) |

**Sources:** Sullivan, "Stata to Python Equivalents" (danielmsullivan.com, accessed
2026-03-28); pandas "Comparison with Stata" (pandas.pydata.org, accessed 2026-03-28);
polars User Guide, "Joins" (docs.pola.rs, accessed 2026-03-28).

---

## Section 8: Appending

### append -- Stack Datasets Vertically

```stata
* Stata
use "file1.dta", clear
append using "file2.dta"
append using "file3.dta"
```

```python
# polars
df = pl.concat([df1, df2])
df = pl.concat([df1, df2, df3])
```

### Handling different column sets

```stata
* Stata -- append fills missing columns with .
append using "file2.dta"
```

```python
# polars -- use how="diagonal" for union-style concatenation (fills missing with null)
df = pl.concat([df1, df2], how="diagonal")
```

The default `how="vertical"` in polars requires identical schemas (same columns in
same order). Use `how="diagonal"` when the DataFrames have different column sets --
it creates the union of all columns and fills missing values with null.

```python
# polars -- strict vertical (schemas must match)
df = pl.concat([df1, df2], how="vertical")

# polars -- relaxed (different column sets, same as Stata append)
df = pl.concat([df1, df2], how="diagonal")
```

### Horizontal concatenation (no Stata equivalent)

```python
# polars -- side-by-side concatenation (column-bind)
df = pl.concat([df1, df2], how="horizontal")
```

**Sources:** polars User Guide (docs.pola.rs, accessed 2026-03-28).

---

## Section 9: Reshaping

### reshape long -- Wide to Long

```stata
* Stata
* Data has: id income2018 income2019 income2020
reshape long income, i(id) j(year)
* Now has: id year income
```

```python
# polars -- unpivot (formerly melt)
income_cols = [c for c in df.columns if c.startswith("income")]
df_long = df.unpivot(
    on=income_cols,
    index="id",
    variable_name="year",
    value_name="income",
)
# Clean the year column: "income2018" -> 2018
df_long = df_long.with_columns(
    pl.col("year").str.replace("income", "").cast(pl.Int32)
)
```

Using column selectors for wide columns:

```python
# polars -- selector-based
import polars.selectors as cs
df_long = df.unpivot(
    on=cs.starts_with("income"),
    index="id",
    variable_name="year",
    value_name="income",
)
```

### reshape wide -- Long to Wide

```stata
* Stata
* Data has: id year income
reshape wide income, i(id) j(year)
* Now has: id income2018 income2019 income2020
```

```python
# polars -- pivot
df_wide = df.pivot(on="year", index="id", values="income")
# Column names will be the year values (2018, 2019, 2020)
# Optionally prefix them:
df_wide = df_wide.rename(
    {c: f"income{c}" for c in df_wide.columns if c != "id"}
)
```

### Pivot with aggregation

When duplicate index-on combinations exist, polars requires an aggregation function:

```python
# polars -- pivot with aggregation
df_wide = df.pivot(
    on="product", index="date", values="sales",
    aggregate_function="sum",
)
```

> **Key behavioral differences:**
> - Stata's `reshape` modifies data in place and remembers the reshape spec for
>   reversal (`reshape long` <-> `reshape wide`). Polars `unpivot`/`pivot` return
>   new DataFrames with no memory of the previous shape.
> - Polars `pivot()` is available only in eager mode.
> - Stata auto-names stub columns (e.g., `income2018`). Polars names pivot columns
>   from the `on` column values; stub prefixes must be added manually.

**Sources:** polars User Guide, "Pivots" (docs.pola.rs, accessed 2026-03-28); pandas
"Comparison with Stata" (pandas.pydata.org, accessed 2026-03-28); QuantEcon
Statistics Cheatsheet (cheatsheets.quantecon.org, accessed 2026-03-28).

---

## Section 10: Aggregation (collapse)

### Basic collapse

```stata
* Stata
collapse (mean) test_score (sum) enrollment, by(state)
```

```python
# polars
state_stats = df.group_by("state").agg(
    pl.col("test_score").mean(),
    pl.col("enrollment").sum(),
)
```

### Multiple statistics

```stata
* Stata
collapse (mean) avg_score=test_score (sd) sd_score=test_score ///
         (min) min_score=test_score (max) max_score=test_score ///
         (count) n=test_score, by(state)
```

```python
# polars
state_stats = df.group_by("state").agg(
    pl.col("test_score").mean().alias("avg_score"),
    pl.col("test_score").std().alias("sd_score"),
    pl.col("test_score").min().alias("min_score"),
    pl.col("test_score").max().alias("max_score"),
    pl.col("test_score").count().alias("n"),
)
```

### Percentile aggregation

```stata
* Stata
collapse (p25) p25_income=income (p50) p50_income=income (p75) p75_income=income, by(state)
```

```python
# polars
state_income = df.group_by("state").agg(
    pl.col("income").quantile(0.25).alias("p25_income"),
    pl.col("income").quantile(0.50).alias("p50_income"),
    pl.col("income").quantile(0.75).alias("p75_income"),
)
```

### Common aggregation function mapping

| Stata collapse stat | polars expression | Notes |
|--------------------|-------------------|-------|
| `(mean) x` | `pl.col("x").mean()` | |
| `(sum) x` | `pl.col("x").sum()` | |
| `(count) x` | `pl.col("x").count()` | Excludes nulls |
| `(sd) x` | `pl.col("x").std()` | N-1 denominator (ddof=1) by default |
| `(min) x` | `pl.col("x").min()` | |
| `(max) x` | `pl.col("x").max()` | |
| `(median) x` | `pl.col("x").median()` | |
| `(first) x` | `pl.col("x").first()` | |
| `(last) x` | `pl.col("x").last()` | |
| `(p25) x` | `pl.col("x").quantile(0.25)` | |
| `(p75) x` | `pl.col("x").quantile(0.75)` | |

### collapse without by() -- Full-column aggregation

```stata
* Stata
collapse (mean) test_score enrollment
* Result: one row with the overall means
```

```python
# polars -- two approaches
# Approach 1: select with aggregations
result = df.select(
    pl.col("test_score").mean(),
    pl.col("enrollment").mean(),
)

# Approach 2: using describe for a quick summary
df.select("test_score", "enrollment").describe()
```

### Counting observations

```stata
* Stata
collapse (count) n=school_id, by(state)

* Stata -- tabulate (interactive)
tab state
```

```python
# polars -- group count
df.group_by("state").len()
df.group_by("state").len().sort("len", descending=True)
```

> **Key behavioral differences:**
> - Stata's `collapse` **destroys** the original data. Polars `group_by().agg()`
>   returns a new DataFrame; the original is preserved.
> - Stata's `collapse` without `by()` produces a single row. Polars:
>   `df.select(pl.col("x").mean())` or `df.agg(pl.col("x").mean())`.
> - Naming: Stata keeps the original variable name by default. Polars also keeps the
>   original column name but can be renamed with `.alias()`.

**Sources:** Sullivan, "Stata to Python Equivalents" (danielmsullivan.com, accessed
2026-03-28); Turrell, "Coming from Stata" (aeturrell.github.io, accessed 2026-03-28).

---

## Section 11: Duplicate Management

### duplicates report

```stata
* Stata
duplicates report
duplicates report state year
```

```python
# polars -- overall duplicate check
print(f"Total rows: {df.height}")
print(f"Unique rows: {df.unique().height}")
print(f"Duplicate rows: {df.height - df.unique().height}")

# polars -- check uniqueness of specific columns
key_dupes = df.group_by("state", "year").len().filter(pl.col("len") > 1)
print(f"Duplicate key combinations: {key_dupes.height}")
print(key_dupes.sort("len", descending=True).head())
```

### duplicates tag

```stata
* Stata
duplicates tag state year, gen(dup_count)
```

```python
# polars -- count occurrences of each key combination, broadcast to rows
df = df.with_columns(
    (pl.len().over("state", "year") - 1).alias("dup_count")
)
# dup_count = 0 means unique; > 0 means duplicated (matches Stata convention)
```

### duplicates drop

```stata
* Stata
duplicates drop
duplicates drop state year, force
```

```python
# polars
df = df.unique()                                    # drop fully identical rows
df = df.unique(subset=["state", "year"])            # drop by key columns (keeps first)
df = df.unique(subset=["state", "year"], keep="first")  # explicit
df = df.unique(subset=["state", "year"], keep="last")   # keep last instead
```

### is_duplicated / is_unique

```python
# polars -- flag rows (useful for inspection before dropping)
df = df.with_columns(
    pl.struct("state", "year").is_duplicated().alias("is_dup"),
    pl.struct("state", "year").is_unique().alias("is_unique"),
)
# Inspect the duplicates
print(df.filter(pl.col("is_dup")).sort("state", "year"))
```

**Sources:** polars User Guide (docs.pola.rs, accessed 2026-03-28).

---

## Section 12: Missing Value Operations

### The Missing Value Model

| Concept | Stata | polars |
|---------|-------|--------|
| Standard missing | `.` (system missing) | `null` |
| Extended missing | `.a` through `.z` (26 types) | No equivalent (use separate column) |
| Not-a-number | Not a separate concept | `NaN` (distinct from `null` in float columns) |
| Test for missing | `missing(var)` | `pl.col("var").is_null()` |
| Missing in comparisons | `.` sorts as **+infinity** (`> 100` is TRUE) | `null` excluded from comparisons |
| Missing in aggregations | Excluded by default | `null` excluded; `NaN` **propagates** |

### mvdecode -- Convert Sentinel Values to Missing

```stata
* Stata
mvdecode income, mv(-9 -99 = .)
mvdecode income, mv(-9 = .r \ -99 = .d)
```

```python
# polars -- convert sentinel values to null
df = df.with_columns(
    pl.when(pl.col("income").is_in([-9, -99]))
      .then(None)
      .otherwise(pl.col("income"))
      .alias("income")
)
```

For multiple sentinel patterns across many columns:

```python
# polars -- sentinel replacement across multiple columns
sentinel_vals = [-9, -99, -999]
numeric_cols = df.select(cs.numeric()).columns
df = df.with_columns(
    pl.when(pl.col(col).is_in(sentinel_vals))
      .then(None)
      .otherwise(pl.col(col))
      .alias(col)
    for col in numeric_cols
)
```

### mvencode -- Fill Missing Values

```stata
* Stata
mvencode income, mv(0)
replace income = 0 if missing(income)
```

```python
# polars
df = df.with_columns(pl.col("income").fill_null(0))
```

### misstable summarize -- Missing Value Report

```stata
* Stata
misstable summarize
misstable patterns
```

```python
# polars -- missing value summary
null_counts = df.null_count()
print(null_counts)

# Detailed missing report
for col in df.columns:
    n_null = df.select(pl.col(col).is_null().sum()).item()
    pct = n_null / df.height * 100
    if n_null > 0:
        print(f"{col}: {n_null} missing ({pct:.1f}%)")
```

### drop if missing / keep if not missing

```stata
* Stata
drop if missing(income)
drop if missing(income) | missing(age)
```

```python
# polars
df = df.filter(pl.col("income").is_not_null())
df = df.drop_nulls(subset=["income"])              # equivalent
df = df.drop_nulls(subset=["income", "age"])       # drop if EITHER is null
df = df.drop_nulls()                               # drop if ANY column is null
```

### Forward-fill and backward-fill

```stata
* Stata -- requires carryforward (community package)
bysort id (time): carryforward var, replace
```

```python
# polars
df = df.with_columns(pl.col("var").forward_fill())
df = df.with_columns(pl.col("var").backward_fill())

# Within groups:
df = df.sort("id", "time").with_columns(
    pl.col("var").forward_fill().over("id")
)
```

### The NaN vs null trap

When reading Stata `.dta` files via pandas, Stata's `.` (missing) arrives as `NaN`
in float columns. In polars, `NaN` and `null` are different:

```python
# NaN is NOT null -- this is a common trap
df = pl.DataFrame({"x": [1.0, float("nan"), None]})
df.select(pl.col("x").is_null())     # [False, False, True]
df.select(pl.col("x").is_nan())      # [False, True, False]
df.select(pl.col("x").mean())        # NaN (NaN propagates!)

# Safe pattern: convert NaN to null first
df = df.with_columns(pl.col("x").fill_nan(None))
df.select(pl.col("x").mean())        # 1.0 (correct)
```

> **THE MISSING-AS-INFINITY TRAP:**
>
> This is the single most dangerous Stata-to-Python difference. In Stata:
> ```stata
> * Stata: THIS INCLUDES MISSING OBSERVATIONS
> count if income > 50000
> keep if var < threshold   /* SAFE: missing excluded because . > threshold */
> ```
>
> In polars:
> ```python
> # polars: nulls are EXCLUDED from comparisons (safe by default)
> df.filter(pl.col("income") > 50000)  # null rows excluded
> ```
>
> The risk reverses: Stata users learn to add `& !missing(x)` defensively. In
> polars, this is unnecessary -- but if you're writing Stata code after working in
> Python, you must remember that Stata's behavior goes the other way.

### Extended missing values (.a through .z)

Stata's 27 missing types have no Python equivalent. When reading `.dta` files:

```python
# pyreadstat preserves extended missing types
import pyreadstat
df_pd, meta = pyreadstat.read_dta("data.dta", user_missing=True)
# Extended missing values are preserved as special NaN values
# Access via meta.missing_ranges

# Strategy: create a separate "reason for missing" column
# before converting to polars null
```

**Sources:** pandas "Working with missing data" (pandas.pydata.org, accessed
2026-03-28); polars documentation, "Handling Missing Values" (docs.pola.rs, accessed
2026-03-28); StataCorp, "Missing values" (stata.com/manuals/dmissingvalues.pdf);
pyreadstat (github.com/Roche/pyreadstat).

---

## Quick Reference Table

A condensed lookup for the most common data management translations:

| Stata | polars | Category |
|-------|--------|----------|
| `use myfile.dta` | `pl.read_parquet("myfile.parquet")` | I/O |
| `save myfile.dta, replace` | `df.write_parquet("myfile.parquet")` | I/O |
| `generate newvar = expr` | `.with_columns(expr.alias("newvar"))` | Create |
| `replace var = expr if cond` | `.with_columns(pl.when(cond).then(expr).otherwise(pl.col("var")))` | Modify |
| `rename old new` | `.rename({"old": "new"})` | Rename |
| `keep var1 var2` | `.select("var1", "var2")` | Columns |
| `drop var1 var2` | `.drop("var1", "var2")` | Columns |
| `keep if condition` | `.filter(condition)` | Rows |
| `drop if condition` | `.filter(~condition)` | Rows |
| `sort var1 var2` | `.sort("var1", "var2")` | Sort |
| `gsort -var1 var2` | `.sort("var1", "var2", descending=[True, False])` | Sort |
| `bysort g: egen m = mean(x)` | `.with_columns(pl.col("x").mean().over("g"))` | Window |
| `collapse (mean) x, by(g)` | `.group_by("g").agg(pl.col("x").mean())` | Aggregate |
| `merge m:1 key using file` | `.join(df2, on="key", how="left")` | Join |
| `append using file2` | `pl.concat([df1, df2])` | Stack |
| `reshape long stub, i(id) j(t)` | `.unpivot(on=cols, index="id")` | Reshape |
| `reshape wide stub, i(id) j(t)` | `.pivot(on="t", index="id", values="stub")` | Reshape |
| `duplicates drop key, force` | `.unique(subset=["key"])` | Dedup |
| `drop if missing(var)` | `.filter(pl.col("var").is_not_null())` | Missing |
| `mvdecode var, mv(-9)` | `pl.when(pl.col("var") == -9).then(None)...` | Missing |
| `destring var, replace` | `.with_columns(pl.col("var").cast(pl.Float64))` | Type |
| `tostring var, replace` | `.with_columns(pl.col("var").cast(pl.Utf8))` | Type |
