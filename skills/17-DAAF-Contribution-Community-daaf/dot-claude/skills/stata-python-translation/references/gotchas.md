# Stata-to-Python Gotchas and False Friends

Common mistakes Stata users make when writing Python, organized from most
dangerous/frequent to least. Each entry documents what Stata users expect, what
actually happens in Python, and the correct approach.

This reference focuses on the DAAF Python stack: polars for data manipulation,
pyfixest/statsmodels for modeling, and plotnine for visualization.

> **Versions referenced:**
> Python: polars 1.38.1, pyfixest 0.40.0, statsmodels 0.14.6
> Stata: Stata 18
> See SKILL.md -- Library Versions for the complete version table.

## Contents

- [False Friends: Syntax](#false-friends-syntax)
- [Data Manipulation Traps](#data-manipulation-traps)
- [Modeling Traps](#modeling-traps)
- [Environment Traps](#environment-traps)
- [Common Error Messages Translated](#common-error-messages-translated)
- [Quick Diagnostic Table](#quick-diagnostic-table)

## False Friends: Syntax

These are constructs from Stata that look like they should work in Python but
behave differently or fail entirely. Each one has caught experienced Stata
users off guard.

| Stata | Python Attempt | Trap | Correct Python |
|-------|----------------|------|----------------|
| `.` (missing value) | `.` | `SyntaxError` or attribute access -- not missingness | `None`, `float("nan")`, or `pl.col("x").is_null()` |
| `gen x = expr` | `gen x = expr` | No `gen` function; Stata commands are not Python functions | `df = df.with_columns(expr.alias("x"))` |
| `replace x = expr if cond` | No direct equivalent | Stata modifies in place with condition | `df = df.with_columns(pl.when(cond).then(expr).otherwise(pl.col("x")).alias("x"))` |
| `` `macro' `` (local macro) | Backtick is string delimiter in some contexts | Backtick-apostrophe has no Python meaning | `variable_name` or f-string: `f"{variable}"` |
| `$global` (global macro) | `$global` | `SyntaxError` -- `$` has no meaning outside strings | `variable_name` (module-level) |
| `&` / `|` (logical operators) | `&` / `|` | Same symbols, but require parentheses around comparisons in Python | `(pl.col("x") > 5) & (pl.col("y") < 10)` |
| `!` (logical NOT) | `!expr` | `SyntaxError` for polars expressions | `~pl.col("x")` (expression) or `not x` (scalar) |
| `_n` (row number) | `_n` | `NameError` -- no built-in row counter | `pl.int_range(pl.len()).over("group")` or `.cum_count()` |
| `_N` (group size) | `_N` | `NameError` | `pl.len().over("group")` |
| `in 1/10` (first 10 obs) | N/A | No `in` range syntax for DataFrames | `df.head(10)` or `df.slice(0, 10)` |
| `var[_n-1]` (lag) | `var[n-1]` | Python list indexing, not lag | `pl.col("var").shift(1).over("group")` |
| `L.var` (lag operator) | `L.var` | `AttributeError` | `pl.col("var").shift(1).over("entity")` |
| `F.var` (lead operator) | `F.var` | `AttributeError` | `pl.col("var").shift(-1).over("entity")` |
| `D.var` (first difference) | `D.var` | `AttributeError` | `(pl.col("var") - pl.col("var").shift(1)).over("entity")` |
| `i.var` (factor notation) | `i.var` | `AttributeError` | `C(var)` in formulas or `i(var)` in pyfixest |
| `c.var#i.cat` (interaction) | N/A | No factor-variable notation | `var:C(cat)` in pyfixest, `var*C(cat)` in statsmodels |
| `var == .` (test for missing) | `var == None` | Returns `False` or empty DataFrame | `pl.col("var").is_null()` |
| `1/10` (range 1 through 10) | `1/10` | Division, not range | `range(1, 11)` |
| `foreach var of varlist x*` | N/A | No `foreach` | `for var in df.select(cs.starts_with("x")).columns:` |
| `forvalues i = 1/10` | N/A | No `forvalues` | `for i in range(1, 11):` |
| `quietly reg y x` | N/A | Python is quiet by default | `fit = pf.feols("y ~ x", data=df)` (no print unless asked) |
| `nrow(df)` / `_N` | `nrow(df)` | No `nrow()` function | `df.height` or `len(df)` |
| `ncol(df)` | `ncol(df)` | No `ncol()` function | `df.width` |
| `display expr` | `display(expr)` | `NameError` unless in Jupyter | `print(expr)` |
| `//` (comment in Stata) | `//` | Floor division in Python, not comment | `#` for comments |
| `/* comment */` | `/* comment */` | `SyntaxError` | `# comment` or `""" multiline """` |

## Data Manipulation Traps

### 1. Forgetting `.alias()` in `with_columns()` (the gen/replace trap)

**Severity:** Very high -- silent column overwrites.

**What Stata users expect:** `gen newvar = expr` creates a new column named by the
left-hand side of the `=`.

**What happens in Python:**
```python
# WRONG: overwrites the source column (polars uses input column name)
df = df.with_columns(pl.col("x") * 2)
# The column "x" is now doubled -- original values lost

# RIGHT: explicit naming with .alias()
df = df.with_columns((pl.col("x") * 2).alias("x_doubled"))
```

Without `.alias()`, polars uses the input column name as the output name,
silently replacing the original. In Stata, `gen` always requires a new variable
name, making this impossible. This is the single most common gotcha for
Stata-to-polars transitions.

### 2. The "Greater Than" Missing Value Trap

**Severity:** Very high -- silent wrong results going in opposite directions.

**What Stata users expect:** `keep if income > 50000` includes observations where
income is missing (because `.` > all numbers in Stata). Stata users learn to add
`& !missing(income)` as a defensive habit.

**What happens in Python:**
```python
# Python: null is EXCLUDED from > comparisons (opposite of Stata)
df.filter(pl.col("income") > 50000)
# This correctly excludes null rows -- no defensive filter needed

# The Stata defensive habit is unnecessary in Python:
# df.filter((pl.col("income") > 50000) & pl.col("income").is_not_null())
# This works but the is_not_null() check is redundant
```

The risk reverses direction: in Stata, the danger is accidentally *including*
missing values; in Python, the danger is accidentally *excluding* valid values
when using complex conditions.

### 3. `drop if` Becomes `filter(NOT condition)` -- Negation Trap

**Severity:** High -- logic inversion error.

**What Stata users expect:** `drop if condition` removes rows matching the
condition.

**What happens in Python:**
```python
# Stata: drop if income < 0
# Python equivalent: keep everything that does NOT match
df = df.filter(~(pl.col("income") < 0))
# Or equivalently:
df = df.filter(pl.col("income") >= 0)

# COMMON MISTAKE: forgetting the negation
df = df.filter(pl.col("income") < 0)  # This KEEPS only negative income!
```

`drop if` translates to `filter(NOT condition)`. `keep if` translates to
`filter(condition)`. Mixing these up silently produces the opposite dataset.

### 4. Merge Without `_merge` Diagnostics

**Severity:** High -- undetected merge problems.

**What Stata users expect:** After `merge`, a `_merge` variable (1=master only,
2=using only, 3=matched) enables quality checks: `tab _merge`.

**What happens in Python:**
```python
# Polars join produces no diagnostic
df = df1.join(df2, on="school_id", how="left")
# No way to tell which rows matched vs didn't

# CORRECT: add indicators before joining
df1 = df1.with_columns(pl.lit(True).alias("_in_master"))
df2 = df2.with_columns(pl.lit(True).alias("_in_using"))
df = df1.join(df2, on="school_id", how="full")
# Now check: _in_master.is_null() = using only, _in_using.is_null() = master only
```

DAAF's validation checkpoints require explicit merge diagnostics. Always validate
row counts before and after joins and check for unexpected nulls in key columns.

### 5. `collapse` Destroys Data; `group_by().agg()` Preserves Original

**Severity:** Medium -- conceptual confusion.

**What Stata users expect:** `collapse (mean) income, by(state)` permanently
replaces the dataset with state-level means. The original observation-level data
is gone.

**What happens in Python:**
```python
# This returns a NEW DataFrame; the original is preserved
state_means = df.group_by("state").agg(pl.col("income").mean())
# df still has all original rows
# state_means has one row per state
```

This is actually an advantage -- no need for `preserve`/`restore`. But Stata
users may be surprised that the original DataFrame is still available.

### 6. `egen rowtotal` Treats Missing as 0; polars `sum_horizontal` Propagates Null

**Severity:** High -- silent numerical differences.

**What Stata users expect:** `egen total = rowtotal(x1 x2 x3)` treats missing
values as zeros: `rowtotal(1, ., 3)` = 4.

**What happens in Python:**
```python
# WRONG: propagates nulls (rowtotal(1, null, 3) = null)
df = df.with_columns(
    pl.sum_horizontal("x1", "x2", "x3").alias("total")
)

# RIGHT: fill nulls first to match Stata rowtotal behavior
df = df.with_columns(
    pl.sum_horizontal(
        pl.col("x1").fill_null(0),
        pl.col("x2").fill_null(0),
        pl.col("x3").fill_null(0),
    ).alias("total")
)
```

The same applies to `rowmean` -- Stata's `egen rowmean(x1 x2 x3)` ignores missing
and averages the non-missing values. Polars' `pl.mean_horizontal()` propagates
nulls.

### 7. `replace var = expr if cond` Requires Explicit Else

**Severity:** Medium -- missing otherwise clause.

**What Stata users expect:** `replace income = 0 if income < 0` modifies only
rows where the condition is true; other rows are unchanged.

**What happens in Python:**
```python
# WRONG: missing the otherwise clause sets non-matching rows to null
df = df.with_columns(
    pl.when(pl.col("income") < 0).then(0).alias("income")
)
# All rows where income >= 0 are now null!

# RIGHT: explicit otherwise to preserve existing values
df = df.with_columns(
    pl.when(pl.col("income") < 0)
      .then(0)
      .otherwise(pl.col("income"))
      .alias("income")
)
```

In Stata, `replace` implicitly preserves values for non-matching rows. In polars,
`when/then` without `otherwise` produces null for non-matching rows.

### 8. Choosing `.over()` vs `.group_by().agg()` -- Window vs Aggregation

**Severity:** Medium -- wrong output shape.

**What Stata users expect:** `bysort state: egen mean_inc = mean(income)` adds a
column to the existing dataset (preserves all rows).

**What happens in Python:**
```python
# WRONG: this collapses to one row per state
result = df.group_by("state").agg(pl.col("income").mean().alias("mean_inc"))

# RIGHT: .over() preserves all rows (like egen)
df = df.with_columns(
    pl.col("income").mean().over("state").alias("mean_inc")
)
```

Rule of thumb: `egen` with `by:` = `.over()`. `collapse` = `.group_by().agg()`.

### 9. `sort` Is In-Place in Stata but Returns New DataFrame in Polars

**Severity:** Low -- immediate error if forgotten.

**What Stata users expect:** `sort state year` reorders the dataset permanently.

**What happens in Python:**
```python
# WRONG: result discarded
df.sort("state", "year")  # Returns sorted DataFrame, but df is unchanged

# RIGHT: reassign
df = df.sort("state", "year")
```

### 10. Referring to Newly Created Columns in the Same Step

**Severity:** Medium -- error or stale values.

**What Stata users expect:** Sequential `gen` and `replace` commands in a do-file
can reference columns created by earlier commands in the same block.

**What happens in Python:**
```python
# WRONG: "a" does not exist yet within this with_columns call
df = df.with_columns(
    (pl.col("x") + 1).alias("a"),
    (pl.col("a") * 2).alias("b")  # ColumnNotFoundError
)

# RIGHT: chain two with_columns calls
df = df.with_columns((pl.col("x") + 1).alias("a"))
df = df.with_columns((pl.col("a") * 2).alias("b"))
```

Polars evaluates all expressions in a single `with_columns()` in parallel.
Newly created columns are not visible to sibling expressions.

## Modeling Traps

### 1. statsmodels Requires Explicit `.fit()`

**Severity:** High -- unfitted model with no results.

**What Stata users expect:** `regress y x1 x2` fits the model and displays results
in one step.

**What happens in Python:**
```python
import statsmodels.formula.api as smf

# WRONG: model is unfitted
model = smf.ols("y ~ x1 + x2", data=pdf)
model.summary()  # AttributeError -- no results yet

# RIGHT: call .fit()
results = smf.ols("y ~ x1 + x2", data=pdf).fit()
results.summary()  # Works
```

pyfixest's `pf.feols()` auto-fits (matching Stata behavior). statsmodels,
linearmodels, and scikit-learn all require an explicit fit step.

### 2. `robust` = HC1 in Stata; Specify `vcov="hetero"` in pyfixest

**Severity:** High -- different standard errors.

**What Stata users expect:** `regress y x, robust` produces heteroskedasticity-
robust SEs using the HC1 (small-sample adjusted) correction.

**What happens in Python:**
```python
# pyfixest: vcov="hetero" produces HC1 by default (matches Stata)
fit = pf.feols("y ~ x", data=pdf, vcov="hetero")

# statsmodels: must specify HC1 explicitly
result = smf.ols("y ~ x", data=pdf).fit(cov_type="HC1")
# Default .fit() uses non-robust (IID) SEs
# .fit(cov_type="HC3") is statsmodels' default robust -- NOT HC1
```

**Clustered SEs:**
```python
# Stata: regress y x, vce(cluster state)
# pyfixest:
fit = pf.feols("y ~ x", data=pdf, vcov={"CRV1": "state"})

# Stata: regress y x, vce(cluster state year)  -- two-way
# pyfixest:
fit = pf.feols("y ~ x", data=pdf, vcov={"CRV1": "state+year"})
```

### 3. `_b[x]` / `_se[x]` Become Method Calls

**Severity:** Low -- immediate error, easy to fix.

**What Stata users expect:** `display _b[education]` retrieves a coefficient.

**What happens in Python:**
```python
# pyfixest
fit.coef()["education"]      # coefficient
fit.se()["education"]        # standard error
fit._r2                       # R-squared
fit._N                        # observation count

# statsmodels
result.params["education"]   # coefficient
result.bse["education"]      # standard error
result.rsquared              # R-squared
result.nobs                  # observation count
```

### 4. `margins` Requires a Separate Package

**Severity:** Medium -- feature not where expected.

**What Stata users expect:** `margins` is a built-in post-estimation command
available after any estimation.

**What happens in Python:**
```python
from marginaleffects import avg_slopes, predictions, hypotheses, datagrid

# Stata: margins, dydx(*)
avg_slopes(result)

# Stata: margins, at(x1=(0 1))
predictions(result, newdata=datagrid(x1=[0, 1], model=result))

# Stata: margins, dydx(x1) by(group)
avg_slopes(result, variables="x1", by="group")
```

The Python `marginaleffects` package is described by its author as alpha-quality.
Verify critical results against Stata for published research.

### 5. `outreg2` / `esttab` Become `pf.etable()`

**Severity:** Low -- feature discovery.

**What Stata users expect:** `esttab m1 m2 m3, se star(* 0.10 ** 0.05 *** 0.01)`
produces a publication table.

**What happens in Python:**
```python
m1 = pf.feols("y ~ x1", data=pdf)
m2 = pf.feols("y ~ x1 + x2", data=pdf)
m3 = pf.feols("y ~ x1 + x2 | fe1", data=pdf)

# Publication table
pf.etable([m1, m2, m3])

# With custom options (matching esttab)
pf.etable([m1, m2, m3],
    signif_code=[0.01, 0.05, 0.10],
    labels={"x1": "Education", "x2": "Experience"},
    felabels={"fe1": "Industry FE"},
    type="tex")  # or "md" for Markdown
```

### 6. Factor Variables: `i.var` Becomes `C(var)` or `i(var)`

**Severity:** Medium -- formula syntax differs.

**What Stata users expect:** `regress y x1 i.region` auto-creates dummies.

**What happens in Python:**
```python
# pyfixest: C() or i() for categoricals
pf.feols("y ~ x1 + C(region)", data=pdf)
pf.feols("y ~ x1 + i(region, ref='Northeast')", data=pdf)

# statsmodels: C() with optional contrast
smf.ols("y ~ x1 + C(region, Treatment(reference='Northeast'))", data=pdf).fit()

# Interactions (Stata: c.x1#i.region)
pf.feols("y ~ x1:C(region)", data=pdf)
```

Python formula interfaces will not auto-detect categorical columns. You must
explicitly mark them with `C()` or `i()`.

## Environment Traps

### 1. No Auto-Printing (Stata Displays by Default; Python Is Silent)

**Severity:** Medium -- validation output missing.

**What Stata users expect:** `summarize income` prints a table. `regress y x`
prints results. Every command shows output.

**What happens in Python:**
```python
# These compute but produce NO visible output in a script
df.describe()
fit = pf.feols("y ~ x", data=pdf)
df.head()

# Must explicitly print
print(df.describe())
fit.summary()
print(df.head())
```

In DAAF's file-first execution model, every validation must use explicit
`print()` or `assert` to appear in the captured output.

### 2. Working Directory and File Paths

**What Stata users expect:** `use "data.dta"` reads from the current directory
set by `cd` or Stata's default.

**What to do in Python:** Avoid `os.chdir()`. DAAF enforces absolute paths:
```python
BASE_DIR = "/path/to/project"
df = pl.read_parquet(f"{BASE_DIR}/data/raw/dataset.parquet")
```

### 3. Log Files vs run_with_capture

**What Stata users expect:** `log using "analysis.log", replace` captures all
commands and output.

**What to do in Python:** DAAF's `run_with_capture.sh` serves the same purpose --
it appends stdout/stderr to the script file after execution, creating an immutable
audit trail. Never run `python script.py` directly.

### 4. No Persistent State Across Scripts

**What Stata users expect:** A do-file can `do "other_script.do"` and the dataset
persists across scripts.

**What happens in Python:** Each script is independent. Data must be saved to disk
(parquet) and loaded by the next script:
```python
# Script 1: save
df.write_parquet(f"{PROJECT_DIR}/data/processed/clean.parquet")

# Script 2: load
df = pl.read_parquet(f"{PROJECT_DIR}/data/processed/clean.parquet")
```

### 5. 0-Based vs 1-Based Indexing

**What Stata users expect:** `_n` starts at 1. `var[1]` is the first observation.

**What happens in Python:** Indices start at 0. `x[0]` is the first element.
Polars avoids this issue by using named column access and expression-based row
selection, but it surfaces with `.row(0)`, `.shift(1)`, `range()`, and list
indexing.

```python
# Polars: first row
df.row(0)          # index 0 = first row (Stata: [1])
df.head(1)         # first row as DataFrame

# Range: 1 through 10
range(1, 11)       # [1, 2, ..., 10] -- exclusive upper bound
# Stata: forvalues i = 1/10 is inclusive
```

## Common Error Messages Translated

| Stata Error | Python Equivalent | Meaning |
|-------------|-------------------|---------|
| `variable x not found` | `ColumnNotFoundError` (polars) | Column does not exist in DataFrame |
| `type mismatch` | `InvalidOperationError` or `TypeError` | Wrong type in operation |
| `no observations` | `ShapeError` or empty DataFrame | Filter removed all rows |
| `r(198) - varname ambiguous` | N/A (Python uses exact names) | Multiple columns match pattern |
| `r(111) - variable already defined` | Column silently overwritten (with `.alias()`) | Column already exists |
| `r(109) - type mismatch` | `ComputeError: cannot cast` | Type conversion failure |
| `merge: key not unique` | Duplicated rows in join result | Non-unique join keys |
| `using not sorted` | N/A (polars does not require sorted keys) | Pre-sorting requirement |
| `r(2000) - no room to add obs` | `MemoryError` | Out of memory |
| `r(601) - file not found` | `FileNotFoundError` | File path is wrong |
| `r(100) - varlist required` | `TypeError: expected str, got NoneType` | Missing required argument |
| `_rc != 0` | `except Exception as e:` | Command failed (check return code) |
| `command unrecognized` | `ModuleNotFoundError` / `ImportError` | Package not installed |
| `conformability error` | `ShapeError` | Dimension mismatch |
| `results not found` | `AttributeError` on unfitted model | Model not yet fitted (`.fit()` not called) |
| `last estimates not found` | N/A (model objects persist) | No active estimation -- save model object |
| `may not combine numeric and string` | `InvalidOperationError` | Mixed types in operation |

## Quick Diagnostic Table

| Problem | Quick Fix |
|---------|-----------|
| Column silently overwritten | Add `.alias("new_name")` to expression |
| Null check finds nothing | Use `.is_null()` not `== None` |
| Compound filter fails with TypeError | Wrap each comparison in parentheses: `(x > 5) & (y < 10)` |
| `drop if` keeps wrong rows | Remember: `drop if cond` = `filter(~cond)` (negation) |
| New column not visible in same step | Chain separate `.with_columns()` calls |
| Model returns unfitted object | Call `.fit()` (statsmodels, linearmodels, scikit-learn) |
| Polars DataFrame rejected by model | Call `.to_pandas()` before passing to statsmodels/pyfixest |
| `rowtotal` gives null instead of sum | `fill_null(0)` on each column before `sum_horizontal` |
| `replace if` sets non-matching to null | Add `.otherwise(pl.col("x"))` to the `when/then` chain |
| Print produces no output in script | Use explicit `print()` -- Python scripts are silent by default |
| Off-by-one in sequence | Python uses 0-based indexing; `range()` excludes the endpoint |
| Merge has no `_merge` diagnostic | Add indicator columns before joining; validate row counts |
| SEs differ from Stata | Check: pyfixest `vcov="hetero"` = HC1 (Stata `robust`); statsmodels default is not robust |
| `sort` did not stick | Reassign: `df = df.sort(...)` -- polars sort returns new DataFrame |
| Lag/lead within groups wrong | Sort by time first, then use `.shift(n).over("entity")` |
| No `i.var` syntax | Use `C(var)` in formulas or `i(var, ref=...)` in pyfixest |
| Macro expansion not working | Replace `` `macro' `` with f-string: `f"{variable}"` |
| `quietly` not available | Python is quiet by default -- just omit `.summary()` |
| `foreach` not available | Use `for var in [...]:` Python loop or list comprehension |

> **Sources:** Sullivan, "Stata to Python Equivalents" (danielmsullivan.com, accessed
> 2026-03-28); Turrell, "Coming from Stata" in *Coding for Economists*
> (aeturrell.github.io, accessed 2026-03-28); pandas documentation, "Comparison with
> Stata" (pandas.pydata.org, accessed 2026-03-28); polars User Guide (docs.pola.rs,
> accessed 2026-03-28); pyfixest documentation (pyfixest.org, accessed 2026-03-28);
> statsmodels documentation (statsmodels.org, accessed 2026-03-28)
