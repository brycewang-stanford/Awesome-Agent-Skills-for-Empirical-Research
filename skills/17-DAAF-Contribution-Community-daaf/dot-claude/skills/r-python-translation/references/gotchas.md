# R-to-Python Gotchas and False Friends

Common mistakes R users make when writing Python, organized from most
dangerous/frequent to least. Each entry documents what R users expect, what
actually happens in Python, and the correct approach.

This reference focuses on the DAAF Python stack: polars for data manipulation,
pyfixest/statsmodels for modeling, and plotnine for visualization.

> **Versions referenced:**
> Python: polars 1.38.1, pyfixest 0.40.0, statsmodels 0.14.6
> R: R 4.5.3
> See SKILL.md § Library Versions for the complete version table.

## Contents

- [False Friends: Syntax](#false-friends-syntax)
- [Data Manipulation Traps](#data-manipulation-traps)
- [Modeling Traps](#modeling-traps)
- [Environment Traps](#environment-traps)
- [Common Error Messages Translated](#common-error-messages-translated)

## False Friends: Syntax

These are constructs that look similar between R and Python but behave
differently. Each one has caught experienced R users off guard.

| R | Python Attempt | Trap | Correct Python |
|---|----------------|------|----------------|
| `df[1,]` (first row) | `df[1]` | Polars does not support bracket indexing on DataFrames | `df.head(1)` or `df.row(0)` |
| `df$column` | `df.column` | `AttributeError` --- polars DataFrames are not namespaces | `df["column"]` or `pl.col("column")` in expressions |
| `TRUE` / `FALSE` | `TRUE` / `FALSE` | `NameError` --- Python is case-sensitive | `True` / `False` |
| `T` / `F` | `T` / `F` | R allows abbreviation; Python has no such aliases | `True` / `False` |
| `NA` | `NA` | Three distinct missingness types in Python | `None`, `float("nan")`, or `pl.col("x").is_null()` |
| `NULL` | `NULL` | `NameError` | `None` |
| `c(1, 2, 3)` | `c(1, 2, 3)` | No `c()` function in Python | `[1, 2, 3]` or `pl.Series([1, 2, 3])` |
| `<-` | `<-` | Parsed as `< -` (less-than negative), not assignment | `=` for assignment |
| `x <- x %>% ...` | `x = x.pipe(...)` | No pipe operator; method chaining or reassignment | `x = x.filter(...).with_columns(...)` |
| `paste0(a, b)` | `paste0(a, b)` | No `paste0` in Python | `f"{a}{b}"` or `a + b` for strings |
| `paste(a, b)` | N/A | `paste()` joins with space by default | `f"{a} {b}"` or `" ".join([a, b])` |
| `%%` (modulo) | `%%` | `SyntaxError` in Python | `%` |
| `%/%` (integer division) | `%/%` | `SyntaxError` in Python | `//` |
| `&` / `|` (vectorized) | `&` / `|` | Same symbols, but require parentheses around comparisons in Python | `(pl.col("x") > 5) & (pl.col("y") < 10)` |
| `&&` / `||` (scalar) | `&&` / `||` | `SyntaxError` --- Python uses keywords | `and` / `or` |
| `1:10` | `1:10` | Slice notation, not sequence generation | `range(1, 11)` or `list(range(1, 11))` |
| `x %in% c(1,2,3)` | `x in [1,2,3]` | Works for scalars; for polars columns use `.is_in()` | `pl.col("x").is_in([1, 2, 3])` |
| `!x` (logical NOT) | `!x` | `SyntaxError` for scalar; `~` for polars expressions | `not x` (scalar) or `~pl.col("x")` (expression) |
| `nrow(df)` | `nrow(df)` | No `nrow()` function | `df.height` or `len(df)` |
| `ncol(df)` | `ncol(df)` | No `ncol()` function | `df.width` |
| `names(df)` | `names(df)` | No `names()` for DataFrames | `df.columns` |

## Data Manipulation Traps

### 1. Forgetting `.alias()` in `with_columns()`

**Severity:** Very high --- silent overwrites or cryptic errors.

**What R users expect:** In dplyr, `mutate(new_col = expr)` names the column
via the left-hand side of the `=`.

**What happens in Python:**
```python
# WRONG: overwrites the source column or produces unnamed result
df.with_columns(pl.col("x") * 2)

# RIGHT: explicit naming with .alias()
df.with_columns((pl.col("x") * 2).alias("x_doubled"))
```

Without `.alias()`, polars uses the input column name as the output name,
silently replacing the original column. This is the single most common
gotcha for R-to-polars transitions.

### 2. Using `==` to Check for Nulls

**Severity:** Very high --- silently returns no matches.

**What R users expect:** `is.na(x)` is a dedicated function, but some R users
also use `x == NA` (which also does not work in R, returning `NA`).

**What happens in Python:**
```python
# WRONG: null is not equal to anything, including itself
df.filter(pl.col("x") == None)

# RIGHT: dedicated null check
df.filter(pl.col("x").is_null())
df.filter(pl.col("x").is_not_null())
```

### 3. Direct Column Assignment on DataFrames

**Severity:** High --- immediate error, but confusing for newcomers.

**What R users expect:** `df$col <- value` or `df[,"col"] <- value` for
in-place assignment.

**What happens in Python:**
```python
# WRONG: polars DataFrames are immutable
df["new_col"] = some_series  # TypeError

# RIGHT: create a new DataFrame with the column added
df = df.with_columns(pl.lit("constant").alias("new_col"))
```

Polars enforces immutability by design. Every transformation returns a new
DataFrame. This is a fundamental paradigm shift from R's copy-on-modify
semantics.

### 4. Forgetting Parentheses in Compound Filters

**Severity:** High --- operator precedence error.

**What R users expect:** `filter(df, x > 5 & y < 10)` works because R's `&`
has lower precedence than comparison operators.

**What happens in Python:**
```python
# WRONG: & binds tighter than > and < in Python
df.filter(pl.col("x") > 5 & pl.col("y") < 10)  # TypeError

# RIGHT: parentheses around each comparison
df.filter((pl.col("x") > 5) & (pl.col("y") < 10))
```

Python's bitwise `&` has higher precedence than comparison operators. This
is the opposite of what R users expect and produces confusing `TypeError`
messages about incompatible types.

### 5. Expecting `group_by().agg()` to Keep All Columns

**Severity:** Medium --- unexpected column loss.

**What R users expect:** dplyr's `group_by()` keeps all columns; only
`summarize()` drops non-grouped, non-aggregated columns.

**What happens in Python:**
```python
# Returns ONLY grouping columns + explicitly aggregated columns
result = df.group_by("state").agg(pl.col("income").mean())
# result has columns: ["state", "income"] --- nothing else

# To keep other columns, aggregate them too or use a different approach
result = df.group_by("state").agg(
    pl.col("income").mean().alias("mean_income"),
    pl.col("population").first()
)
```

### 6. Bare Literals in Expressions

**Severity:** Medium --- error or silent wrong behavior.

**What R users expect:** `mutate(df, x = "constant")` just works.

**What happens in Python:**
```python
# WRONG: bare string in expression context
df.with_columns(pl.col("x") + "suffix")  # May error

# RIGHT: wrap scalar values in pl.lit()
df.with_columns(pl.lit("constant").alias("label"))
df.with_columns((pl.col("x") + pl.lit(100)).alias("x_plus"))
```

Use `pl.lit()` to wrap any scalar value (string, number, boolean) that
appears in a polars expression context.

### 7. Expecting `group_by()` to Preserve Row Order

**Severity:** Medium --- silently reordered output.

**What R users expect:** dplyr's `group_by() %>% summarize()` preserves the
order groups first appeared.

**What happens in Python:**
```python
# group_by() does NOT guarantee output order
result = df.group_by("category").agg(pl.col("value").sum())
# Row order is non-deterministic

# To get deterministic order, sort explicitly
result = df.group_by("category").agg(
    pl.col("value").sum()
).sort("category")
```

Polars `sort()` is stable, but `group_by()` is not order-preserving. If
order matters, always sort after aggregation.

### 8. Expecting `library()` Semantics from `import`

**Severity:** Low --- immediate errors, easy to fix.

**What R users expect:** `library(dplyr)` makes `filter()`, `mutate()`,
`select()` etc. available as bare functions.

**What happens in Python:**
```python
import polars as pl

# WRONG: no bare filter() or select()
filter(df, condition)   # This calls Python's built-in filter(), not polars

# RIGHT: always use the pl prefix or method syntax
df.filter(pl.col("x") > 5)
df.select("col1", "col2")
```

### 9. Referring to Newly Created Columns in the Same Step

**Severity:** Medium --- error or stale values.

**What R users expect:** dplyr's `mutate()` allows referencing a column
created earlier in the same call: `mutate(a = x + 1, b = a * 2)`.

**What happens in Python:**
```python
# WRONG: "a" does not exist yet within this with_columns call
df.with_columns(
    (pl.col("x") + 1).alias("a"),
    (pl.col("a") * 2).alias("b")  # ColumnNotFoundError
)

# RIGHT: chain two with_columns calls
df = df.with_columns((pl.col("x") + 1).alias("a"))
df = df.with_columns((pl.col("a") * 2).alias("b"))
```

Polars evaluates all expressions in a single `with_columns()` in parallel,
so newly created columns are not visible to sibling expressions.

## Modeling Traps

### 1. statsmodels Requires Explicit `.fit()`

**What R users expect:** `lm(y ~ x, data = df)` returns a fitted model.

**What happens in Python:**
```python
import statsmodels.formula.api as smf

# WRONG: model is unfitted, results will error
model = smf.ols("y ~ x", data=df)
model.summary()  # AttributeError

# RIGHT: call .fit() to get results
results = smf.ols("y ~ x", data=df).fit()
results.summary()  # Works
```

This two-step pattern (specify, then fit) applies to statsmodels, pyfixest,
and scikit-learn. R's `lm()`, `glm()`, and `feols()` combine both steps.
pyfixest's `pf.feols()` does auto-fit, matching R behavior.

### 2. Polars-to-Pandas Conversion for Modeling

**What R users expect:** Data flows directly into model functions.

**What happens in Python:**
```python
import pyfixest as pf

# WRONG: pyfixest expects pandas
fit = pf.feols("y ~ x | fe", data=df_polars)  # TypeError

# RIGHT: convert first
fit = pf.feols("y ~ x | fe", data=df_polars.to_pandas())
```

pyfixest, statsmodels, and scikit-learn all expect pandas DataFrames (or
numpy arrays). Always call `.to_pandas()` before passing polars data to
modeling functions.

### 3. Intercept Handling Differs Across Libraries

**What R users expect:** `lm(y ~ x)` includes an intercept by default.

**What happens in Python:**

| Library | Default | Suppress Intercept |
|---------|---------|-------------------|
| statsmodels (formula API) | Intercept included | `y ~ x - 1` or `y ~ 0 + x` |
| pyfixest | Intercept included (absorbed into FE when present) | `y ~ x - 1` |
| scikit-learn | Intercept included (`fit_intercept=True` is default) | `fit_intercept=False` to suppress |

The real intercept gotcha is with statsmodels' **array API**: `sm.OLS(y, X)`
does NOT add an intercept — you must use `sm.add_constant(X)` explicitly.
The formula API (`smf.ols("y ~ x")`) includes it by default, matching R.

### 4. Factor/Categorical Handling in Formulas

**What R users expect:** R auto-creates dummy variables from factors in
formulas. `lm(y ~ factor(x))` just works.

**What happens in Python:**
```python
# statsmodels (patsy): use C() for categorical
results = smf.ols("y ~ C(region)", data=df).fit()

# pyfixest: use i() for interactions, C() for main effects
fit = pf.feols("y ~ i(treat, ref=0)", data=df)
```

Python will not auto-detect categorical columns from the data. You must
explicitly wrap categorical variables in `C()` (statsmodels) or `i()`
(pyfixest) in the formula.

### 5. Default Standard Error Types

**What R users expect:** `lm()` defaults to classical/IID SEs. `feols()`
in fixest also defaults to IID (since fixest 0.13).

**What happens in Python:**

| Library | Default SE | Notes |
|---------|-----------|-------|
| pyfixest (v0.40+) | IID | Aligned with R fixest 0.13 |
| statsmodels OLS | Non-robust (IID) | Use `.get_robustcov_results()` for robust |
| scikit-learn | No SEs provided | Not a statistical inference tool |

pyfixest's alignment with fixest means R users get familiar defaults.
However, pre-v0.40 pyfixest defaulted to clustering by the first FE, so
older code may produce different results.

## Environment Traps

### 1. Working Directory Assumptions

**What R users expect:** `setwd()` changes the working directory globally;
`read.csv("data.csv")` reads from the working directory.

**What to do in Python:** Avoid `os.chdir()`. DAAF enforces absolute paths
for all file operations. Use `pathlib.Path` or string constants for paths:
```python
BASE_DIR = "/path/to/project"
df = pl.read_parquet(f"{BASE_DIR}/data/raw/dataset.parquet")
```

### 2. Random Seeds

**What R users expect:** `set.seed(42)` before stochastic operations.

**What to do in Python:**
```python
import numpy as np
np.random.seed(42)         # NumPy operations
# Or, for newer NumPy:
rng = np.random.default_rng(42)
```

The seed must be set before each stochastic call if exact reproducibility
is needed. Different libraries (numpy, random, scipy) have independent
RNG states.

### 3. Auto-Printing in Scripts

**What R users expect:** Typing `df` at the console prints it. In R scripts,
the last expression in a block auto-prints.

**What happens in Python:** In scripts (which DAAF always uses), nothing
prints unless you explicitly call `print()`:
```python
df.head()          # Computes but displays nothing in a script
print(df.head())   # Actually shows the output
```

This is critical for DAAF's file-first execution pattern --- every
validation must use explicit `print()` or `assert` to appear in the
captured output.

### 4. Return Values and Last-Expression Evaluation

**What R users expect:** The last expression in an R function is its return
value. No explicit `return` needed.

**What happens in Python:** Functions require explicit `return`. However,
DAAF uses sequential inline scripts without function definitions, so this
is rarely encountered. Be aware of it when reading library source code or
documentation examples.

### 5. 1-Based vs 0-Based Indexing

**What R users expect:** `x[1]` is the first element.

**What happens in Python:** `x[0]` is the first element. This applies to
lists, tuples, numpy arrays, and string indexing. Polars avoids this issue
by using named column access and expression-based row selection rather than
numeric indexing.

## Common Error Messages Translated

| R Error | Python Equivalent | Meaning |
|---------|-------------------|---------|
| `object 'x' not found` | `NameError: name 'x' is not defined` | Variable does not exist in scope |
| `could not find function "f"` | `AttributeError` or `ImportError` | Package not imported or function misspelled |
| `arguments imply differing number of rows` | `ShapeError` (polars) | Column lengths do not match |
| `non-numeric argument to binary operator` | `TypeError` | Wrong types in arithmetic operation |
| `replacement has X rows, data has Y` | `ShapeError` (polars) | Length mismatch in column assignment |
| `$ operator is invalid for atomic vectors` | `TypeError: 'int' object is not subscriptable` | Trying to index a scalar |
| `Error in if (...) : missing value where TRUE/FALSE needed` | `TypeError` with polars expressions | Null in a boolean context |
| `cannot coerce type 'character' to ...` | `InvalidOperationError: ... cast ...` | Type conversion failure |
| `subscript out of bounds` | `IndexError: list index out of range` | Index exceeds collection length |
| `unused argument` | `TypeError: got an unexpected keyword argument` | Wrong parameter name |
| `cannot open connection` / `No such file` | `FileNotFoundError` | File path is wrong |
| `package 'x' is not available` | `ModuleNotFoundError: No module named 'x'` | Package not installed |

## Quick Diagnostic Table

| Problem | Quick Fix |
|---------|-----------|
| Column silently overwritten | Add `.alias("new_name")` |
| Null check finds nothing | Use `.is_null()` not `== None` |
| Compound filter fails | Wrap each comparison in parentheses |
| New column not visible in same step | Chain separate `.with_columns()` calls |
| Model function returns unfitted object | Call `.fit()` on the model |
| Polars DataFrame rejected by model | Call `.to_pandas()` before passing |
| Bare literal in expression | Wrap with `pl.lit()` |
| `group_by` output missing columns | Explicitly aggregate every column you need |
| Print produces no output in script | Use explicit `print()` |
| Off-by-one in sequence | Python uses 0-based indexing; `range()` excludes the endpoint |
