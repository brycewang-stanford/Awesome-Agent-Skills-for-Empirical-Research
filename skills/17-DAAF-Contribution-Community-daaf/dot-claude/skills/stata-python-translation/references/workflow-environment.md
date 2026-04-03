# Workflow and Environment: Stata to DAAF Python

Beyond syntax differences, Stata and Python differ in *how you work with them*.
Good news for Stata users: Stata's do-file execution model is conceptually closer
to DAAF's file-first approach than RStudio's interactive console. The mental model
of "write a script, execute it, review the log" maps directly to DAAF's
"write a script, execute via run_with_capture.sh, review the appended output."
The transition is smoother than you might expect.

This reference covers the practical adjustments a Stata user needs to make when
working within DAAF, framed as "here is what you are used to, here is the
equivalent, and here is why it is different."

> **Versions referenced:**
> Python: marimo 0.19.11, Python 3.12, polars 1.38.1
> Stata: Stata 18
> See SKILL.md Section: Library Versions for the complete version table.

---

## Section 1: Do-Files to Python Scripts

### What You Are Used To (Stata)

Stata's primary unit of reproducible work is the **do-file** (`.do`). A typical
workflow:

1. Open a do-file in the Do-file Editor
2. Write commands sequentially
3. Execute with `do analysis.do` or Ctrl+D
4. Output appears in the Results window
5. Optionally capture output with `log using`

```stata
* typical_analysis.do
clear all
set more off
log using "analysis_log.txt", replace

use "schools.dta", clear
drop if missing(enrollment)
gen log_enroll = log(enrollment)
regress test_score log_enroll poverty_rate, robust

log close
```

Key characteristics of do-files:
- Sequential, top-to-bottom execution
- `clear all` resets state defensively at the start
- `log using` captures commands + output as an audit trail
- `set more off` prevents output pagination
- No function definitions, no imports, no module system
- One dataset in memory; commands implicitly act on it

### What DAAF Does Instead

DAAF uses a **file-first execution model** with `.py` scripts:

1. **Write** a complete script to a file
2. **Execute** via the capture wrapper:
   `bash {BASE_DIR}/scripts/run_with_capture.sh {PROJECT_DIR}/scripts/stage7_transform/01_join-data.py`
3. **Review** output appended to the script file as comments
4. If changes are needed, create a new versioned copy (`01_join-data_a.py`)

```python
# scripts/stage6_clean/01_clean-schools.py
# --- Config ---
import polars as pl

BASE_DIR = "/daaf"
PROJECT_DIR = f"{BASE_DIR}/research/2026-01-24_School_Analysis"

# --- Load ---
# INTENT: Load raw school data for cleaning
df = pl.read_parquet(f"{PROJECT_DIR}/data/raw/schools.parquet")
print(f"Loaded: {df.shape}")

# --- Transform ---
# INTENT: Remove records with missing enrollment for complete-case analysis
# REASONING: 2.1% of records have null enrollment; confirmed MCAR in profiling
# ASSUMES: Missingness is MCAR
df = df.filter(pl.col("enrollment").is_not_null())
df = df.with_columns(pl.col("enrollment").log().alias("log_enroll"))

# --- Validate ---
assert df.height > 0, "No rows remaining after filter"
print(f"Rows after cleaning: {df.height}")

# --- Save ---
df.write_parquet(f"{PROJECT_DIR}/data/processed/schools_clean.parquet")
print("Saved cleaned data")
```

### Why the Transition Is Natural

| Stata Do-file | DAAF Python Script | Similarity |
|---------------|-------------------|------------|
| `log using "file.log"` | `run_with_capture.sh` appends output | Same purpose: audit trail |
| Sequential execution, top-to-bottom | Sequential execution, top-to-bottom | Identical model |
| `clear all` resets state | Each script starts a fresh Python process | Same clean-slate approach |
| No function definitions | No function definitions (DAAF convention) | Identical style |
| Comments document intent | IAT comments (`# INTENT:`, `# REASONING:`, `# ASSUMES:`) | Structured version of the same practice |
| `do "other_script.do"` runs sub-scripts | Each script is independent; data passes via parquet | Slightly different: no nesting |

### Key Differences

| Aspect | Stata | DAAF Python |
|--------|-------|-------------|
| Script modification | Overwrite in place, re-run | Immutable after execution; new version (`_a.py`) |
| Output capture | `log using` creates separate log file | Output appended to the script file itself |
| State between scripts | Variables persist in memory across `do` files | Each script is a fresh process; data passed via parquet |
| Interactive execution | Highlight lines, press Ctrl+D | Not supported; always execute full script |
| Data format | `.dta` files | Parquet exclusively |
| Master script | `master.do` calls subsidiary do-files | DAAF's stage-based directories replace master scripts |

### Script Versioning

Stata users typically overwrite a do-file when fixing errors. DAAF never modifies
a script after its execution output has been appended:

```
01_clean-schools.py        # Original -- executed, output appended, now immutable
01_clean-schools_a.py      # Fix attempt 1 -- corrections + its own output
01_clean-schools_b.py      # Fix attempt 2 -- if _a also failed
```

All versions remain in the directory. This creates a complete debugging history.

---

## Section 2: Macros to Variables

### Stata's Macro System

Stata macros are text-substitution mechanisms. They store text that is substituted
into commands before Stata parses them.

```stata
* Local macros (scoped to current do-file)
local controls "education experience age"
local outcome "wage"
regress `outcome' `controls', robust
* Stata sees: regress wage education experience age, robust

* Global macros (persist across do-files in a session)
global datadir "C:/projects/data/"
use "${datadir}schools.dta", clear
```

The `` `macro' `` syntax (backtick + apostrophe) is unique to Stata and a common
source of confusion.

### Python Variables

Python variables are direct value bindings -- much simpler than macro substitution:

```python
# Python equivalents
controls = ["education", "experience", "age"]
outcome = "wage"
formula = f"{outcome} ~ {' + '.join(controls)}"
# formula = "wage ~ education + experience + age"
fit = pf.feols(formula, data=pdf, vcov="hetero")

# Path construction
datadir = "/projects/data/"
df = pl.read_parquet(f"{datadir}schools.parquet")
```

### Extended Macro Functions

Stata has extended macro functions for metadata access and string manipulation:

```stata
local ncontrols : word count `controls'     /* = 3 */
local first_var : word 1 of `controls'      /* = "education" */
local vartype : type income                 /* = "float" */
local varlabel : variable label income      /* label text */
```

Python equivalents:

```python
ncontrols = len(controls)                   # 3
first_var = controls[0]                     # "education"
vartype = str(df.schema["income"])          # "Float64"
# No direct equivalent for variable labels -- use metadata dict
```

### Macros in Loops

```stata
* Stata: loop over outcomes, store models
local outcomes "math reading science"
foreach outcome of local outcomes {
    regress `outcome' poverty_rate, robust
    estimates store m_`outcome'
}
esttab m_math m_reading m_science
```

```python
# Python: loop over outcomes, store in dict
outcomes = ["math", "reading", "science"]
models = {}
for outcome in outcomes:
    models[outcome] = pf.feols(f"{outcome} ~ poverty_rate", data=pdf, vcov="hetero")

pf.etable(list(models.values()))
```

### Dynamic Variable Names

```stata
* Stata: build variable names with macros
forvalues year = 2015/2020 {
    gen income_`year' = .
    replace income_`year' = income if year == `year'
}
```

```python
# Python: f-strings for dynamic column names
for year in range(2015, 2021):
    df = df.with_columns(
        pl.when(pl.col("year") == year)
          .then(pl.col("income"))
          .otherwise(None)
          .alias(f"income_{year}")
    )
```

---

## Section 3: Program Flow

### Conditionals

```stata
* Stata
if `nobs' > 1000 {
    display "Large sample"
}
else {
    display "Small sample"
}
```

```python
# Python
if nobs > 1000:
    print("Large sample")
else:
    print("Small sample")
```

### Loops Over Variable Lists

```stata
* Stata: foreach over a varlist
foreach var of varlist income education age {
    summarize `var'
    gen z_`var' = (`var' - r(mean)) / r(sd)
}
```

```python
# Python: list comprehension (preferred for column operations)
vars_to_standardize = ["income", "education", "age"]
df = df.with_columns([
    ((pl.col(var) - pl.col(var).mean()) / pl.col(var).std()).alias(f"z_{var}")
    for var in vars_to_standardize
])
```

### Numeric Loops

```stata
* Stata
forvalues i = 1/10 {
    display `i'
}

forvalues year = 2000(5)2020 {
    use "data_`year'.dta", clear
}
```

```python
# Python
for i in range(1, 11):    # range() excludes endpoint
    print(i)

for year in range(2000, 2021, 5):    # step size as third arg
    df = pl.read_parquet(f"data_{year}.parquet")
```

### Error Handling

```stata
* Stata: capture suppresses errors
capture drop tempvar
if _rc != 0 {
    display "Variable not found"
}

* capture noisily: show error but continue
capture noisily merge 1:1 id using "other.dta"
```

```python
# Python: try/except
try:
    df = df.drop("tempvar")
except Exception:
    print("Variable not found")

# Continue on error
try:
    df = df.join(other_df, on="id", how="left")
except Exception as e:
    print(f"Join failed: {e}")
```

### Output Suppression

```stata
* Stata: commands print by default; quietly suppresses
quietly regress y x1 x2
* No output displayed

* noisily: force output inside quiet blocks
quietly {
    noisily display "Starting analysis"
    regress y x1 x2
}
```

```python
# Python: functions return objects silently by default
fit = pf.feols("y ~ x1 + x2", data=pdf)
# Nothing printed

# Explicitly print results
fit.summary()
print(fit.coef())
```

This is the inverse of Stata: Stata prints by default and you suppress with
`quietly`; Python is silent by default and you print explicitly.

### Random Seeds

```stata
set seed 42
```

```python
import random
import numpy as np

random.seed(42)
np.random.seed(42)
# scikit-learn: random_state=42 on individual estimators
```

Python requires setting seeds per library, not globally.

---

## Section 4: Package Management

### Stata

```stata
* Install from SSC
ssc install reghdfe

* Install from URL
net install ftools, from("https://example.com/stata/")

* Check installed packages
ado describe

* Update
adoupdate, update

* Which version am I running?
which reghdfe
```

### Python / DAAF

```python
# Packages are pre-installed in the DAAF Docker container
# No pip install during analysis sessions

# Import explicitly (no library() equivalent that exports everything)
import polars as pl
import pyfixest as pf
from sklearn.ensemble import RandomForestClassifier

# Check version
import pyfixest; print(pyfixest.__version__)
```

| Aspect | Stata | Python / DAAF |
|--------|-------|---------------|
| Install mechanism | `ssc install` or `net install` | Pre-installed in Docker container |
| Package location | `~/ado/plus/` | Docker image (frozen) |
| Version locking | No built-in mechanism | Docker image pins all versions |
| Loading | Automatic on first use (ado-path search) | `import` required (explicit) |
| Namespace | All commands in global namespace | Prefixed: `pl.col()`, `pf.feols()` |
| Adding new package | `ssc install` at any time | Requires container rebuild |
| Community vs built-in | Indistinguishable once installed | All equally accessible via import |

### The Namespace Difference

In Stata, after `ssc install reghdfe`, you type `reghdfe y x, absorb(fe)` and it
works -- no prefix, no import. In Python, after the package is installed, you must
`import pyfixest as pf` and then type `pf.feols("y ~ x | fe", data=df)`.

The upside: the `pf.` prefix tells you exactly which library a function comes
from. In Stata, seeing `ivreg2` versus `ivregress`, you need to remember which is
the built-in and which is community-contributed.

---

## Section 5: Getting Help

| Stata | Python | DAAF |
|-------|--------|------|
| `help regress` | `help(pf.feols)` (interactive) | Skill reference files |
| `describe` | `df.schema`, `df.shape` | Print in script |
| `summarize` | `df.describe()` | Print in script |
| `codebook var` | `df.select("var").describe()` + `df["var"].n_unique()` | Profiling scripts (Data Onboarding) |
| `list in 1/10` | `print(df.head(10))` | |
| `browse` (data viewer) | `print(df.head(20))` | No GUI viewer in file-first model |
| `search keyword` | Online docs / PyPI | DAAF skill system |
| `findit command` | `pip search` (deprecated) / PyPI website | |
| `which reghdfe` | `import pkg; pkg.__version__` | |
| `tabulate var` | `print(df["var"].value_counts())` | |

### DAAF's Skill System as Built-in Help

In Stata, you read `help margins` for a command reference. In DAAF, the equivalent
is the **skill reference files** -- domain-specific guidance documents loaded on
demand. Each skill provides decision trees, code examples, and translation tables.

You do not need to find and read these yourself. When you describe what you want to
do, the agent loads the relevant skill automatically. This is analogous to Stata's
automatic ado-path search -- the system finds the right resource without you
specifying where it lives.

---

## Section 6: Project Structure (Stata vs DAAF)

### Typical Stata Project Structure

```
my_analysis/
├── master.do                    # Calls all sub-scripts in order
├── 01_clean.do
├── 02_merge.do
├── 03_analysis.do
├── 04_tables.do
├── data/
│   ├── raw/
│   │   ├── schools.dta
│   │   └── districts.dta
│   └── clean/
│       └── analysis_data.dta
├── output/
│   ├── tables/
│   │   └── regression_table.rtf
│   └── figures/
│       └── scatter.png
└── logs/
    └── analysis_log.txt
```

### DAAF Project Structure

```
research/2026-01-24_School_Poverty_Analysis/
├── scripts/
│   ├── stage5_fetch/            # Data acquisition
│   │   └── 01_fetch-ccd.py
│   ├── stage6_clean/            # Cleaning
│   │   └── 01_clean-ccd.py
│   ├── stage7_transform/        # Transformation
│   │   └── 01_join-data.py
│   └── stage8_analysis/         # Analysis and visualization
│       ├── 01_regression.py
│       └── 02_enrollment-plot.py
├── data/
│   ├── raw/                     # Immutable raw data (parquet)
│   └── processed/               # Derived data (parquet)
├── output/
│   ├── analysis/                # Analysis outputs (parquet)
│   └── figures/                 # Plots (PNG)
├── STATE.md                     # Session state tracking
└── LEARNINGS.md                 # Methodological insights
```

### Key Differences

| Aspect | Stata Convention | DAAF Convention |
|--------|-----------------|----------------|
| Master script | `master.do` calls sub-scripts | Stage-based directories replace master |
| Script naming | `01_clean.do` (flat numbering) | `01_clean-ccd.py` (stage + descriptive) |
| Script modification | Overwrite in place | Immutable after execution (`_a.py`, `_b.py`) |
| Data format | `.dta` files | Parquet exclusively |
| Helper functions | Ado-files or `include "helpers.do"` | Scripts are self-contained |
| State tracking | Ad hoc or log files | Explicit `STATE.md` document |
| Documentation | Comments | IAT: `# INTENT:`, `# REASONING:`, `# ASSUMES:` |

---

## Section 7: Reproducibility

### Stata Reproducibility Practices

```stata
* Random seed
set seed 42

* Version control
version 18          /* ensure forward compatibility */

* Logging
log using "analysis.log", replace text

* Package snapshot (no built-in mechanism)
which reghdfe      /* manually record versions */
```

### DAAF Reproducibility Practices

```python
# Random seeds (per-library)
import random
import numpy as np
random.seed(42)
np.random.seed(42)
# scikit-learn: random_state=42 on individual estimators

# Version is controlled by Docker container
# No equivalent to Stata's version command -- unnecessary
```

| Stata Practice | DAAF Equivalent | Notes |
|---------------|----------------|-------|
| `set seed 42` | `random.seed(42)` + `np.random.seed(42)` + `random_state=42` | Per-library in Python |
| `version 18` | Docker container pins all versions | Reproducibility by environment |
| `log using` | `run_with_capture.sh` | Output appended to script |
| `which pkg` | Docker image manifest | Version frozen at build time |
| Comments | Inline Audit Trail (IAT) | Structured documentation |
| `master.do` order | Stage-based script directories | Stage5 -> Stage6 -> Stage7 -> Stage8 |
| `save data.dta` | `df.write_parquet("data.parquet")` | Parquet only |

### The IAT System

DAAF's Inline Audit Trail is a formalized, mandatory version of Stata do-file
comments. Instead of ad hoc comments like `* clean up the data`, every filter,
join, aggregation, and derived column includes structured annotations:

```python
# INTENT: Remove records with missing enrollment to ensure complete-case analysis
# REASONING: 3.2% of records have null enrollment; MCAR pattern confirmed in profiling
# ASSUMES: Missingness is MCAR -- if MNAR, results may undercount small schools
df = df.filter(pl.col("enrollment").is_not_null())
```

Stata users who write well-commented do-files will find IAT natural -- it is the
same practice with enforced structure.

---

## Section 8: Common Workflow Questions

These are the questions Stata users ask most frequently when starting with DAAF:

**"I want to browse my data."**
Write `print(df.head(20))` in your script. The output appears in the execution
log appended to the script. There is no equivalent to Stata's `browse` command
or Data Editor GUI in DAAF's file-first model.

**"I want to use `preserve`/`restore`."**
Just assign to a new variable: `df_subset = df.filter(...)`. The original `df` is
unchanged. Polars DataFrames are immutable by default -- every operation returns
a new DataFrame, so the original is always preserved automatically.

**"Where is my Results window?"**
Results come from `print()` statements in your script. When the script executes
via `run_with_capture.sh`, all print output is appended to the script file as
comments. This is analogous to `log using` but the output is kept with the code.

**"How do I run part of my do-file?"**
DAAF scripts are designed to be self-contained and run completely. Instead of
running part of a script, write separate scripts per stage. Each loads its own
input data from parquet files and produces its own output.

**"I want to install a package."**
Packages are pre-installed in the DAAF Docker container. If you need something
not available, inform the orchestrator. Do not run `pip install` during analysis.

**"How do I see my data's structure?"**
```python
# In a script -- equivalent to Stata's describe + summarize
print(f"Shape: {df.shape}")
print(f"Schema:\n{df.schema}")
print(f"Nulls:\n{df.null_count()}")
print(df.head(10))
print(df.describe())
```

Compare with Stata:
```stata
describe
summarize
list in 1/10
```

**"I want to pipe things together."**
Stata does not have a pipe operator (though Stata 18+ added some chaining). In
polars, method chaining achieves the same visual flow:

```python
result = (
    df
    .filter(pl.col("year") == 2020)
    .group_by("state")
    .agg(pl.col("income").mean().alias("mean_income"))
    .sort("mean_income", descending=True)
)
```

The parentheses around the chain allow multi-line method chaining without
backslash continuation -- this is the standard Python idiom.

**"I want to run Stata code from Python."**
If you have a Stata license, the `pystata` package (StataCorp) allows calling
Stata from Python. However, DAAF is designed to work entirely in Python. The
skill reference files document Python equivalents for all common Stata commands.

**"I want to weight my analysis."**

Stata:
```stata
regress y x1 x2 [pw=weight]
summarize income [aw=weight]
```

Python:
```python
# Weighted regression: use WLS in statsmodels
import statsmodels.api as sm
model = sm.WLS(y, X, weights=pdf["weight"]).fit()

# Survey weights: use svy package
import svy
design = svy.Design(wgt="weight")
sample = svy.Sample(data=df, design=design)
sample.estimation.mean("income")
```

Stata's bracket weight syntax (`[pw=weight]`) is elegantly concise. Python
requires explicitly choosing the right tool per weight type.

---

## Section 9: Why Polars (Not pandas)

Stata users transitioning to Python often encounter pandas first, since it is the
most widely known Python DataFrame library. DAAF uses **polars** instead.

### For Stata Users Specifically

Polars shares several design philosophies with Stata:

| Stata | polars | pandas |
|-------|--------|--------|
| Operations on columns, not rows | Column-oriented expressions | Row-oriented common |
| `sort var1 var2` (explicit) | `df.sort("var1", "var2")` (explicit) | `df.sort_values()` |
| `collapse (mean) x, by(g)` | `df.group_by("g").agg(pl.col("x").mean())` | `df.groupby("g")["x"].mean()` |
| No row index | No row index | Row index (confusing for Stata users) |
| Type system enforced | Strict type system | Loose typing (silent coercion) |

The biggest conceptual gap between Stata and pandas is pandas' row index system,
which has no Stata equivalent and confuses Stata users. Polars eliminates this
gap -- it has no row index at all.

### When pandas Appears

Some Python libraries require pandas DataFrames:

- **plotnine** -- requires pandas for plotting
- **statsmodels** -- formula API expects pandas
- **pyfixest** -- expects pandas (converts internally)
- **geopandas** -- extends pandas

The DAAF pattern: do all data manipulation in polars, convert at the boundary:

```python
# Polars for wrangling
df = pl.read_parquet("data.parquet")
df = df.filter(pl.col("year") == 2020).select(["y", "x1", "x2"])

# Convert to pandas at the modeling boundary
pdf = df.to_pandas()
fit = pf.feols("y ~ x1 + x2", data=pdf)
```

---

> **Sources:** StataCorp, "16 Do-files" in User's Guide (stata.com/manuals,
> accessed 2026-03-28); StataCorp, "18 Programming Stata" in User's Guide
> (stata.com/manuals, accessed 2026-03-28); StataCorp, "macro -- Macro definition
> and manipulation" (stata.com/manuals/pmacro.pdf, accessed 2026-03-28);
> Turrell, "Coming from Stata" in *Coding for Economists*
> (aeturrell.github.io, accessed 2026-03-28); polars documentation
> (docs.pola.rs, accessed 2026-03-28); marimo documentation (docs.marimo.io,
> accessed 2026-03-28)
