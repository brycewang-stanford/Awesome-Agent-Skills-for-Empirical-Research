# Paradigm Differences: Stata vs Python for Quantitative Social Science

This reference documents the fundamental language and paradigm differences between
Stata and Python (with polars) as they affect quantitative social science data analysis.
It is the foundational reference that other translation files build upon.

> **Versions referenced:**
> Python: Python 3.12, polars 1.38.1
> Stata: Stata 18
> See SKILL.md -- Library Versions for the complete version table.

## Contents

- [The Single-Dataset Model](#the-single-dataset-model)
- [Missing Values](#missing-values)
- [Value Labels](#value-labels)
- [The by: Prefix and System Variables](#the-by-prefix-and-system-variables)
- [In-Place Modification](#in-place-modification)
- [The Macro System](#the-macro-system)
- [Estimation and Post-Estimation](#estimation-and-post-estimation)
- [Type System](#type-system)
- [Panel Data Operators](#panel-data-operators)
- [Package and Namespace Model](#package-and-namespace-model)

---

## The Single-Dataset Model

Stata's architecture is built around a single dataset in memory. Every command
operates on "the dataset" implicitly -- there is no need to specify *which*
DataFrame you mean.

### Stata: Implicit Single Dataset

```stata
* Stata -- implicit single dataset; no variable prefixed with a dataset name
use "schools.dta", clear
keep if enrollment > 500
gen log_enroll = log(enrollment)
summarize log_enroll
regress test_score log_enroll poverty_rate
```

The commands `use`, `keep`, `gen`, `summarize`, and `regress` all target "the
dataset." No object or variable name is attached.

**The `frame` system (Stata 16+):** Frames allow holding multiple datasets
simultaneously:

```stata
frame create districts
frame change districts
use "districts.dta", clear
frame change default                    /* switch back */
frame districts: summarize enrollment   /* operate on districts without switching */
frlink m:1 district_id, frame(districts) /* link frames without merging */
```

Frames are relatively new and adoption is limited. The traditional single-dataset
mental model still dominates Stata workflows.

**`preserve` / `restore`:** Before frames, Stata's mechanism for temporary
modifications was `preserve`/`restore`:

```stata
preserve
keep if state == "CA"
collapse (mean) test_score, by(district)
save "ca_district_means.dta", replace
restore
* Original dataset is back, unmodified
```

### Python: Explicit Multi-Object Workspace

```python
# Python / polars -- explicit multi-object workspace
schools = pl.read_parquet("schools.parquet")
districts = pl.read_parquet("districts.parquet")
ca_schools = schools.filter(pl.col("state") == "CA")
merged = schools.join(districts, on="district_id", how="left")
# 'schools' is never modified
```

The `preserve`/`restore` pattern is unnecessary because creating a subset does
not destroy the original:

```python
# Python equivalent of preserve/restore
ca_means = (
    schools.filter(pl.col("state") == "CA")
    .group_by("district")
    .agg(pl.col("test_score").mean())
)
# 'schools' is never modified -- no preserve needed
```

### Key Mental Model Shift

| Stata Mental Model | Python Mental Model |
|--------------------|---------------------|
| "The dataset" (singular, implicit) | "This DataFrame" (explicit, one of many) |
| Commands modify the dataset in place | Operations return new objects |
| `merge` and `append` build up *the* dataset | Multiple DataFrames coexist; join when needed |
| `preserve`/`restore` for temporary modifications | Just assign to a new variable |
| Column = "variable" (bare name) | Column = string in a DataFrame (`pl.col("name")`) |

> **Sources:** Sullivan, "Stata to Python Equivalents" (danielmsullivan.com, accessed
> 2026-03-28); Turrell, "Coming from Stata" in *Coding for Economists*
> (aeturrell.github.io, accessed 2026-03-28); StataCorp, "Data frames: multiple datasets
> in memory" (stata.com, accessed 2026-03-28); pandas documentation, "Comparison with
> Stata" (pandas.pydata.org, accessed 2026-03-28)

---

## Missing Values

This is the single largest source of translation bugs between Stata and Python.
Stata has a 27-type missing value system with a unique ordering convention that has
no equivalent in any other programming language.

### Stata: Missing = Positive Infinity

Stata supports 27 distinct missing values: system missing (`.`) and 26 extended
missing types (`.a` through `.z`). The ordering is:

```
all nonmissing numbers < . < .a < .b < ... < .z
```

This means missing values sort as **greater than all numeric values**:

```stata
* DANGEROUS: this includes missing values!
count if income > 50000
* Returns observations with income > 50000 AND observations where income is missing

* CORRECT: explicitly exclude missing
count if income > 50000 & !missing(income)
* Or equivalently:
count if income > 50000 & income < .
```

**Why this design?** Stata uses two-valued logic (true/false). Every `if`
condition must resolve to true or false -- no "skip because unknown." Treating
missing as +infinity provides consistent behavior: `keep if x > 0` and
`drop if x <= 0` produce identical results.

**Extended missing values encode reasons for missingness:**

```stata
replace income = .r if refused_income == 1
replace income = .d if dont_know_income == 1
replace income = .n if not_applicable == 1

summarize income     /* all three excluded from mean calculation */
count if income == .r    /* number who refused */
count if income >= .     /* all missing, any type */
```

### Python: Three Kinds of Missing

| Representation | Scope | Comparison | Aggregation |
|----------------|-------|------------|-------------|
| `None` | Python-level | `None == None` is `True` | Coerced to `null` in polars |
| `float("nan")` / `np.nan` | Float only | `NaN != NaN` is `True` | **Propagates** through arithmetic |
| `null` (polars) | All types | Cannot compare with `==` | **Skipped** by default |

**Critical difference from Stata:** In Python, null/NaN comparisons return False:

```python
import math
math.nan > 100     # False   (in Stata, . > 100 is TRUE)
math.nan < 100     # False
math.nan == 100    # False
math.nan == math.nan  # False
```

This is the **opposite** of Stata, where `. > 100` is `True`.

```python
# Polars -- null is the primary missing representation
df = pl.DataFrame({"x": [1, None, 3]})
df.filter(pl.col("x") == None)    # WRONG -- returns empty DataFrame
df.filter(pl.col("x").is_null())  # RIGHT -- returns the null row

# NaN vs null -- the dangerous case
df = pl.DataFrame({"x": [1.0, float("nan"), None]})
df.select(pl.col("x").is_null())     # False, False, True
df.select(pl.col("x").is_nan())      # False, True, False
df.select(pl.col("x").mean())        # NaN (propagates!)
df.select(pl.col("x").fill_nan(None).mean())  # 1.0 (safe pattern)
```

### Common Translation Patterns

| Stata | Python / Polars |
|-------|-----------------|
| `missing(var)` | `pl.col("var").is_null()` |
| `!missing(var)` | `pl.col("var").is_not_null()` |
| `var == .` | `pl.col("var").is_null()` (never `== None`) |
| `replace var = 0 if missing(var)` | `df.with_columns(pl.col("var").fill_null(0))` |
| `drop if missing(var)` | `df.filter(pl.col("var").is_not_null())` or `df.drop_nulls("var")` |
| `mvdecode var, mv(-9 -99)` | `pl.when(pl.col("var").is_in([-9, -99])).then(None).otherwise(pl.col("var"))` |
| `count if income > 50000` (includes missing) | `df.filter(pl.col("income") > 50000)` (excludes null -- safe) |

### No Extended Missing Types

Python has no native way to encode *why* a value is missing. Workaround: use a
separate column:

```python
df = df.with_columns(
    pl.when(pl.col("refused_income") == 1).then(pl.lit("refused"))
      .when(pl.col("dont_know_income") == 1).then(pl.lit("dont_know"))
      .when(pl.col("not_applicable") == 1).then(pl.lit("not_applicable"))
      .otherwise(pl.lit(None))
      .alias("income_missing_reason")
)
```

When reading `.dta` files, `pyreadstat` with `user_missing=True` preserves
extended missing metadata, but most downstream operations discard the distinction.

### NaN vs Null in Polars

When reading Stata `.dta` files via pandas, Stata's `.` arrives as `NaN` in float
columns. Convert to null before analysis:

```python
# Convert NaN to null (standard pattern when importing from Stata)
df = df.with_columns(
    pl.when(pl.col("var").is_nan()).then(None)
      .otherwise(pl.col("var"))
      .alias("var")
)
```

> **Sources:** StataCorp, "Logical expressions and missing values" (stata.com/support/faqs,
> accessed 2026-03-28); StataCorp, "Missing values -- Quick reference"
> (stata.com/manuals/dmissingvalues.pdf, accessed 2026-03-28); UCLA Statistical Consulting,
> "Missing Values" Stata Learning Modules (stats.oarc.ucla.edu, accessed 2026-03-28);
> *Stata Journal*, "Stata Tip 86: The Missing() Function" (2010); polars documentation,
> "Handling Missing Values" (docs.pola.rs, accessed 2026-03-28); Poverty Action, "Missing
> Values" (povertyaction.github.io, accessed 2026-03-28)

---

## Value Labels

Stata has a three-layer labeling system with no direct Python equivalent. This is
a fundamental difference in how the two ecosystems handle categorical data.

### Stata: Three-Layer Label System

**Layer 1: Dataset labels** -- `label data "description"` attaches a description
to the entire dataset.

**Layer 2: Variable labels** -- `label variable varname "description"` attaches a
human-readable description to each column. These appear in output, `describe`, and
the Variables window.

**Layer 3: Value labels** -- a two-step system mapping integer codes to text:

```stata
* Step 1: Define a label set
label define race_lbl 1 "White" 2 "Black" 3 "Hispanic" 4 "Asian" 5 "Other"

* Step 2: Attach the label set to a variable
label values race race_lbl

* Now 'race' stores integers (1-5) but displays text
tabulate race
* Output shows "White", "Black", etc., not 1, 2, etc.
```

**Critical design choice:** The variable stores *integers* but *displays* text.
Regression models use the integers directly. Tabulations show the labels. The same
label set can be shared across multiple variables.

```stata
encode state_name, gen(state_code)    /* string -> labeled numeric */
decode state_code, gen(state_string)  /* labeled numeric -> string */

label variable enrollment "Total student enrollment (K-12), fall count"
```

### Python: No Built-In Equivalent

```python
# Approach 1: Dictionary mapping (most common)
race_labels = {1: "White", 2: "Black", 3: "Hispanic", 4: "Asian", 5: "Other"}
df = df.with_columns(
    pl.col("race").replace(race_labels).alias("race_label")
)

# Approach 2: Polars Enum type (fixed, ordered categories)
race_enum = pl.Enum(["White", "Black", "Hispanic", "Asian", "Other"])
df = df.with_columns(pl.col("race_str").cast(race_enum))

# Variable labels: no native support -- use a dictionary
var_labels = {
    "enrollment": "Total student enrollment (K-12), fall count",
    "frpl_pct": "Percent of students eligible for free/reduced price lunch",
}

# Reading Stata files preserves labels
import pyreadstat
df_pd, meta = pyreadstat.read_dta("data.dta")
meta.column_names_to_labels    # variable labels
meta.variable_value_labels     # value labels: {"varname": {1: "label", ...}}
```

### Key Mental Model Shift

| Stata | Python |
|-------|--------|
| Data + metadata unified (labels travel with dataset) | Data and metadata are separate concerns |
| Integer storage + text display (automatic) | Store as string OR integer (choose one) |
| One label set shared across variables | Each variable manages its own categories |
| `encode`/`decode` bridges strings and numerics | Manual mapping or `.cast()` between types |
| `label variable` documents columns inline | No built-in column documentation |

> **Sources:** StataCorp, "How to label the values of categorical variables"
> (stata.com, accessed 2026-03-28); UCLA Statistical Consulting, "Labeling data"
> (stats.oarc.ucla.edu, accessed 2026-03-28); pyreadstat (github.com/Roche/pyreadstat,
> accessed 2026-03-28); polars User Guide, "Categorical data and enums" (docs.pola.rs,
> accessed 2026-03-28)

---

## The by: Prefix and System Variables

Stata's `by:` prefix (or `bysort:`) repeats a command for each group. Combined
with system variables `_n` (observation number within group) and `_N` (total
observations in group), it enables complex within-group operations.

### Stata: by:, _n, _N

```stata
bysort state: gen state_n = _N                          /* group count */
bysort state: gen state_obs = _n                        /* row number in group */
bysort state (year): gen first_year = year[1]           /* first year per state */
bysort state (year): gen prev_score = test_score[_n-1]  /* lag within group */
bysort state (year): gen lead_score = test_score[_n+1]  /* lead within group */

* egen functions extend by:
bysort state: egen mean_score = mean(test_score)        /* group mean */
bysort state: egen total_enroll = total(enrollment)     /* group sum */
bysort state: egen rank_score = rank(test_score)        /* within-group rank */
```

Key aspects:
- `_n` is the observation number within the current by-group (1-based)
- `_N` is the total number of observations in the current by-group
- `bysort var1 (var2):` sorts by var1 AND var2 but groups only by var1
- Subscript `var[_n-1]` accesses the previous observation's value

### Python: Two Distinct Patterns

Stata's `by:` maps to two different polars patterns. Choosing the wrong one is
the most common mistake during transition:

**1. Window functions (.over()) -- preserves rows** (equivalent to `bysort: gen`
or `bysort: egen`):

```python
df = df.with_columns(
    pl.col("test_score").mean().over("state").alias("mean_score"),
    pl.col("enrollment").sum().over("state").alias("total_enroll"),
    pl.len().over("state").alias("state_n"),
)
```

**2. Aggregation (.group_by().agg()) -- reduces rows** (equivalent to `collapse`):

```python
state_stats = df.group_by("state").agg(
    pl.col("test_score").mean().alias("mean_score"),
    pl.col("enrollment").sum().alias("total_enroll"),
    pl.len().alias("state_n"),
)
```

**_n and _N equivalents:**

```python
df = df.with_columns(
    # _n (row number within group -- 0-based in polars, 1-based in Stata)
    pl.col("test_score").cum_count().over("state").alias("state_obs"),
    # _N (group size)
    pl.len().over("state").alias("state_N"),
)
```

**Lag/lead within groups (Stata: var[_n-1]):**

```python
df = df.sort("state", "year").with_columns(
    pl.col("test_score").shift(1).over("state").alias("prev_score"),
    pl.col("test_score").shift(-1).over("state").alias("lead_score"),
)
```

### Key Mental Model Shift

| Stata (`by:` / `egen`) | Python (polars) |
|-------------------------|-----------------|
| `bysort state: egen mean_x = mean(x)` | `pl.col("x").mean().over("state")` |
| `bysort state: gen obs_num = _n` | `pl.col("x").cum_count().over("state")` |
| `bysort state: gen group_size = _N` | `pl.len().over("state")` |
| `bysort state (year): gen lag_x = x[_n-1]` | `pl.col("x").shift(1).over("state")` (after sorting) |
| `collapse (mean) x, by(state)` | `df.group_by("state").agg(pl.col("x").mean())` |
| Result always added to THE dataset | Must choose: `.over()` (window) vs `.agg()` (collapse) |

> **Sources:** Sullivan, "Stata to Python Equivalents" (danielmsullivan.com, accessed
> 2026-03-28); Notre Dame Library, "by, _n, _N" (libguides.library.nd.edu, accessed
> 2026-03-28); Poverty Action, "Sort, by, bysort, egen"
> (povertyaction.github.io, accessed 2026-03-28); polars User Guide, "Window functions"
> (docs.pola.rs, accessed 2026-03-28)

---

## In-Place Modification

Stata modifies data in place. Polars returns new DataFrames (immutable by design).

### Stata: Modify-in-Place

```stata
drop if missing(income)        /* dataset is now smaller */
gen log_income = log(income)   /* new column added to the dataset */
replace income = income / 1000 /* column modified in place */
rename income income_thousands /* column renamed in place */
sort state year                /* dataset reordered in place */
```

### Python: Functional Returns

```python
df = df.filter(pl.col("income").is_not_null())                  # new DataFrame
df = df.with_columns(pl.col("income").log().alias("log_income"))  # new DataFrame
df = df.with_columns((pl.col("income") / 1000).alias("income"))  # new DataFrame
df = df.rename({"income": "income_thousands"})                   # new DataFrame
df = df.sort("state", "year")                                    # new DataFrame
```

Every operation returns a new DataFrame. The original is unchanged unless you
reassign the variable (`df = df.operation(...)`).

**Why this matters:** Polars' immutability is actually closer to R's copy-on-modify
than to Stata's in-place modification. The practical consequence: you must always
reassign (`df = df.with_columns(...)`) or chain operations. Forgetting the
reassignment is a very common mistake for Stata users.

| Stata | Python / Polars |
|-------|-----------------|
| `gen x = expr` | `df = df.with_columns(expr.alias("x"))` |
| `replace x = expr` | `df = df.with_columns(expr.alias("x"))` (same syntax) |
| `replace x = expr if cond` | `df = df.with_columns(pl.when(cond).then(expr).otherwise(pl.col("x")).alias("x"))` |
| `drop x` | `df = df.drop("x")` |
| `drop if cond` | `df = df.filter(~cond)` (note negation) |
| `keep x y z` | `df = df.select("x", "y", "z")` |
| `keep if cond` | `df = df.filter(cond)` |

> **Sources:** polars User Guide, "Getting Started" (docs.pola.rs, accessed 2026-03-28);
> pandas documentation, "Comparison with Stata" (pandas.pydata.org, accessed 2026-03-28)

---

## The Macro System

Stata's macros are a text-substitution mechanism fundamentally different from
Python variables. Macros store text strings that are *substituted* into commands
before execution.

### Stata: Text Substitution

**Local macros** (scoped to current do-file or program):

```stata
local controls "education experience age"
local outcome "wage"
local threshold = 50000

* Use: backtick + apostrophe
regress `outcome' `controls'
* Stata expands this to: regress wage education experience age

keep if income > `threshold'

* Extended macro functions
local ncontrols : word count `controls'    /* = 3 */
local first_var : word 1 of `controls'     /* = "education" */
```

**Global macros** (persist for entire session):

```stata
global datadir "C:/projects/school_analysis/data/"
global controls "education experience age"

use "${datadir}schools.dta", clear
regress wage $controls
```

**Macros in loops:**

```stata
local outcomes "math_score reading_score science_score"
foreach outcome of local outcomes {
    regress `outcome' poverty_rate, robust
    estimates store m_`outcome'
}
```

### Python: Variables and f-Strings

```python
controls = ["education", "experience", "age"]
outcome = "wage"
threshold = 50000
datadir = "/projects/school_analysis/data/"

# Formula construction via f-strings and join
formula = f"{outcome} ~ {' + '.join(controls)}"
# formula = "wage ~ education + experience + age"
model = pf.feols(formula, data=pdf)

# Looping
outcomes = ["math_score", "reading_score", "science_score"]
results = {}
for outcome in outcomes:
    results[outcome] = pf.feols(f"{outcome} ~ poverty_rate", data=pdf, vcov="hetero")
```

### Key Mental Model Shift

| Stata Macros | Python Variables |
|--------------|-----------------|
| Text substitution (evaluated at parse time) | Value binding (evaluated at runtime) |
| `` `localname' `` (backtick-apostrophe) | `variable_name` (bare name) |
| `$globalname` (dollar sign) | `variable_name` (no scope distinction in syntax) |
| `local x "a b c"` stores a string | `x = ["a", "b", "c"]` stores a list |
| Macro expanded *before* command parses | Variables resolved *during* execution |
| Extended macro functions for metadata | Built-in functions, type introspection |

**The substitution model matters.** In Stata, `` regress `outcome' `controls' ``
first substitutes the macro text, producing `regress wage education experience age`,
then Stata parses and executes that text. In Python, `pf.feols(formula, data=pdf)`
passes a string *object* to a function -- no pre-parse substitution step.

> **Sources:** StataCorp, "macro -- Macro definition and manipulation"
> (stata.com/manuals/pmacro.pdf, accessed 2026-03-28); Wlm, "Stata Guide: Macros"
> (wlm.userweb.mwn.de, accessed 2026-03-28); UVA Library, "Stata Basics: foreach and
> forvalues" (library.virginia.edu, accessed 2026-03-28)

---

## Estimation and Post-Estimation

Stata has a uniquely structured two-phase workflow for statistical modeling. Results
are stored in global `e()` and `r()` scalars that are overwritten by the next
command. Python uses persistent model objects.

### Stata: Global Return Values

```stata
* Phase 1: Estimate
regress wage education experience i.industry, robust

* Phase 2: Post-estimation (interrogate the last model)
display e(N)         /* number of observations */
display e(r2)        /* R-squared */
display _b[education]    /* coefficient */
display _se[education]   /* standard error */

test education = experience       /* F-test */
lincom education + 2*experience   /* linear combination */

margins industry                  /* predictive margins */
margins, dydx(education)          /* average marginal effect */

predict yhat, xb                  /* fitted values added to dataset */
predict resid, residuals          /* residuals added to dataset */

* Model storage for comparison
estimates store m1
regress wage education                    /* replaces e() */
estimates store m2
esttab m1 m2, se r2
```

### Python: Persistent Model Objects

```python
import pyfixest as pf
import statsmodels.formula.api as smf
from marginaleffects import avg_slopes, predictions, hypotheses

# pyfixest approach
m1 = pf.feols("wage ~ education + experience | industry", data=pdf,
              vcov="hetero")
m2 = pf.feols("wage ~ education", data=pdf, vcov="hetero")

# Access results (attributes on the model object)
m1.coef()         # coefficient series
m1.se()           # standard errors
m1._N             # number of observations
m1._r2            # R-squared
m1.coef()["education"]   # specific coefficient

# Model comparison table
pf.etable([m1, m2])

# Hypothesis testing
m1.wald_test("education - experience = 0")

# Marginal effects (via marginaleffects package)
fit = smf.ols("wage ~ education * experience + C(industry)", data=pdf).fit(
    cov_type="HC1")
avg_slopes(fit, variables="education")

# Predictions
m1.predict()      # returns array (not added to dataset)
m1.resid()        # residuals
```

### Key Mental Model Shift

| Stata | Python |
|-------|--------|
| One active estimation result at a time | Multiple model objects coexist as variables |
| `e()` / `r()` global return values | Attributes/methods on model objects |
| `estimates store m1` to save | `m1 = pf.feols(...)` (already saved) |
| `estimates restore m1` to reactivate | Just use `m1.attribute` directly |
| `_b[varname]`, `_se[varname]` | `fit.coef()["varname"]`, `fit.se()["varname"]` |
| `test var1 = var2` | `fit.wald_test("var1 - var2 = 0")` |
| `margins` (built-in, universal) | `marginaleffects` package (separate install) |
| `predict newvar, xb` | `fit.predict()` (returns array, not added to dataset) |
| `esttab m1 m2 m3` (community) | `pf.etable([m1, m2, m3])` |

> **Sources:** UCLA Statistical Consulting, "Returned results" (stats.oarc.ucla.edu,
> accessed 2026-03-28); StataCorp, "Estimation and postestimation commands" User's Guide
> Ch. 20 (stata.com/manuals/u20.pdf, accessed 2026-03-28); pyfixest documentation
> (pyfixest.org, v0.40.0, accessed 2026-03-28); marginaleffects documentation
> (marginaleffects.com, accessed 2026-03-28)

---

## Type System

Stata coerces types implicitly in limited cases and provides `destring`/`tostring`
for explicit conversion. Polars requires explicit `.cast()`.

| Stata Type | polars Type | Notes |
|-----------|------------|-------|
| `byte`, `int`, `long` | `pl.Int8`, `pl.Int16`, `pl.Int32`, `pl.Int64` | polars has more granular integer types |
| `float` | `pl.Float32` | |
| `double` | `pl.Float64` | Default for floating point |
| `str#` (fixed-length string) | `pl.Utf8` | polars strings are always variable-length UTF-8 |
| `strL` (long string) | `pl.Utf8` | Same as above |

### Conversion

| Stata | Python / Polars |
|-------|-----------------|
| `destring var, replace` | `df.with_columns(pl.col("var").cast(pl.Float64))` |
| `destring var, replace force` | `df.with_columns(pl.col("var").cast(pl.Float64, strict=False))` |
| `tostring var, replace` | `df.with_columns(pl.col("var").cast(pl.Utf8))` |
| `tostring var, gen(strvar) format(%9.2f)` | `df.with_columns(pl.col("var").round(2).cast(pl.Utf8).alias("strvar"))` |

**Key behavioral difference:** Stata's `destring` fails on non-numeric characters
unless `force` is specified (which sets those to `.`). Polars' `cast(strict=False)`
sets unparseable values to `null`.

> **Sources:** StataCorp, "destring" manual (stata.com/manuals/ddestring.pdf, accessed
> 2026-03-28); polars User Guide, "Casting" (docs.pola.rs, accessed 2026-03-28)

---

## Panel Data Operators

Stata requires explicit panel structure declaration via `xtset`/`tsset`. Python
has no equivalent declaration -- panel operations must be explicit.

### Stata: Declare Once, Use Everywhere

```stata
xtset state_id year            /* declare panel structure */
gen lag_score = L.test_score   /* lag operator */
gen lead_score = F.test_score  /* lead operator */
gen diff_score = D.test_score  /* first difference */

* Multiple lags
gen lag2 = L2.test_score       /* two-period lag */
```

### Python: Explicit Every Time

```python
# Must sort and specify the group each time
df = df.sort("state_id", "year").with_columns(
    pl.col("test_score").shift(1).over("state_id").alias("lag_score"),
    pl.col("test_score").shift(-1).over("state_id").alias("lead_score"),
    (pl.col("test_score") - pl.col("test_score").shift(1).over("state_id"))
        .alias("diff_score"),
    pl.col("test_score").shift(2).over("state_id").alias("lag2"),
)
```

| Stata | Python / Polars |
|-------|-----------------|
| `xtset entity time` | No equivalent; structure is implicit |
| `L.var` (lag) | `pl.col("var").shift(1).over("entity")` |
| `L2.var` (2-period lag) | `pl.col("var").shift(2).over("entity")` |
| `F.var` (lead) | `pl.col("var").shift(-1).over("entity")` |
| `D.var` (first difference) | `(pl.col("var") - pl.col("var").shift(1)).over("entity")` |

**For panel regression models:** linearmodels requires a pandas MultiIndex:

```python
from linearmodels.panel import PanelOLS
df_panel = df.to_pandas().set_index(["state_id", "year"])
model = PanelOLS.from_formula("test_score ~ 1 + poverty_rate + EntityEffects",
                               data=df_panel).fit()
```

> **Sources:** StataCorp, "xt -- Introduction to xt commands" (stata.com/manuals,
> accessed 2026-03-28); polars User Guide, "Window functions" (docs.pola.rs, accessed
> 2026-03-28); linearmodels documentation (bashtage.github.io/linearmodels, accessed
> 2026-03-28)

---

## Package and Namespace Model

Stata has a flat command namespace with community extensions via SSC/ado-files.
Python uses explicit imports with package namespaces.

### Stata: Flat Namespace

```stata
ssc install reghdfe          /* from SSC archive */
ssc install estout           /* from SSC archive */

reghdfe y x1 x2, absorb(fe1 fe2) cluster(cl1)
esttab using table.tex, se star
```

Once installed, community commands (`reghdfe`, `esttab`) are indistinguishable from
built-in commands. No import needed. No namespace prefix. Stata searches ado-file
directories in priority order.

### Python: Explicit Namespaces

```python
import polars as pl
import pyfixest as pf
import statsmodels.formula.api as smf
from marginaleffects import avg_slopes, predictions

df = df.filter(pl.col("x") > 5)       # pl prefix
fit = pf.feols("y ~ x | fe", data=pdf) # pf prefix
result = smf.ols("y ~ x", data=pdf).fit() # smf prefix
```

**What Stata users expect:** After "importing," functions are available by bare
name (like `library()` in R).
**What actually happens:** Every function lives in its package namespace.
`filter()` alone is Python's built-in (on iterables), not polars' DataFrame filter.

| Stata | Python Equivalent | Notes |
|-------|-------------------|-------|
| `ssc install reghdfe` | `pip install pyfixest` | Package installation |
| `reghdfe y x, absorb(fe)` | `pf.feols("y ~ x \| fe", data=df)` | Explicit namespace |
| `ssc describe reghdfe` | `pip show pyfixest` | Package info |
| Ado-file path search | `import` resolution | |
| No prefix needed | Prefix or explicit import always required | |

R scripts typically have 2-3 `library()` calls; equivalent Stata do-files have
zero imports; equivalent Python scripts may have 6-10 `import` statements. This
is normal and expected.

> **Sources:** StataCorp, "ssc -- Install and uninstall packages from SSC"
> (stata.com/manuals/rssc.pdf, accessed 2026-03-28); Python docs, "The import system"
> (docs.python.org, accessed 2026-03-28)
