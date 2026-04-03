# Workflow and Environment: R to DAAF Python

Beyond syntax differences, R and Python differ in *how you work with them*. RStudio provides
an integrated, interactive environment where exploration and production blur together. DAAF
enforces a file-first execution model where every operation is captured, versioned, and
auditable. This is often the most disorienting transition for R users -- not the code
itself, but the workflow surrounding it.

This reference covers the practical adjustments an R user needs to make when working within
DAAF, framed as "here is what you are used to, here is the equivalent, and here is why it
is different."

> **Versions referenced:**
> Python: marimo 0.19.11, Python 3.12
> R: R 4.5.3, Quarto 1.6.x
> See SKILL.md § Library Versions for the complete version table.

---

## Section 1: Interactive Exploration to File-First Execution

### What You Are Used To (R / RStudio)

In RStudio, the typical workflow is exploratory and iterative:

1. Type a command in the console, see the result immediately
2. Highlight lines in a script and press Ctrl+Enter to run them
3. Inspect objects in the Environment pane
4. Iterate: tweak, re-run, inspect, repeat
5. Once satisfied, save the script

The console is the primary work surface. You think *while* running code. The script is a
cleaned-up record of what you discovered interactively.

### What DAAF Does Instead

DAAF uses a **file-first execution model**:

1. **Write** a complete script to a file (e.g., `scripts/stage7_transform/01_join-data.py`)
2. **Execute** the script via a capture wrapper:
   `bash {BASE_DIR}/scripts/run_with_capture.sh {PROJECT_DIR}/scripts/stage7_transform/01_join-data.py`
3. **Review** the output, which is appended to the script file as comments
4. If changes are needed, create a new versioned copy (`01_join-data_a.py`) -- never modify the original after execution

There is no interactive console step. Every line of code is written to a file before it runs.

### Why This Feels Different

| R Habit | DAAF Equivalent | Why |
|---------|----------------|-----|
| Console exploration | Write script, execute, read appended output | Audit trail: every execution is captured |
| `View(df)` in RStudio | `print(df.head(20))` in script | File-first: output goes to script log |
| Highlight-and-run partial script | Execute the full script | Reproducibility: partial runs create ambiguous state |
| Modify script in place after errors | Create versioned copy (`_a.py`, `_b.py`) | Immutable history: failed versions are evidence |
| `rm(list=ls())` to clear state | Each script execution is a fresh process | No hidden state between runs |

### Mental Model Adjustment

Think of each DAAF script as a **complete RMarkdown chunk** that you knit all at once --
not as a console session you build up line by line. You design the whole transformation,
include `print()` statements for validation, and then execute it as a unit. The appended
output is your "knit" result.

If you are used to RMarkdown or Quarto, this will feel more natural: you already write
code in blocks, knit, and review the output document. DAAF simply makes this the *only*
way to work, and captures the output permanently alongside the code.

---

## Section 2: RMarkdown / Quarto to marimo

### What You Are Used To (RMarkdown / Quarto)

R's literate programming tools run **top-to-bottom** when knitted:

- Chunks execute in document order
- Earlier chunks define objects that later chunks use
- `knit` runs everything sequentially from the top
- The output is an HTML/PDF document combining code, output, and narrative
- Changing one chunk requires re-knitting everything below it (or using chunk caching)

### What marimo Does Instead

marimo is a **reactive** Python notebook:

- Cells form a dependency graph (like a spreadsheet)
- When you change a cell, all cells that depend on its outputs automatically re-run
- Delete a cell, and its variables are removed from memory (no hidden state)
- The notebook is stored as a plain `.py` file (Git-friendly)
- Each cell is wrapped in a `def _():` function (marimo convention, not a regular function)

### Key Difference: Reactive vs. Sequential

```
RMarkdown:  Chunk 1 → Chunk 2 → Chunk 3 → Chunk 4  (linear, top-to-bottom)

marimo:     Cell A ──→ Cell C ──→ Cell D
                  ↗               ↗
            Cell B ──────────────┘         (dependency graph, automatic re-execution)
```

**R equivalent mental model:** imagine if changing one RMarkdown chunk automatically
re-knitted *only* the chunks that depended on it, instantly, without you pressing anything.
That is marimo's reactivity.

### Document Structure Comparison

```r
# RMarkdown / Quarto (.Rmd / .qmd)
---
title: "Analysis"
output: html_document
---

## Load Data

```{r}
library(dplyr)
df <- read.csv("data.csv")
```

## Transform

```{r}
result <- df %>% filter(year == 2020) %>% mutate(pct = x / sum(x))
```

## Visualize

```{r}
library(ggplot2)
ggplot(result, aes(x, y)) + geom_point()
```
```

```python
# marimo (.py)
import marimo as mo

@app.cell
def _():
    import polars as pl
    df = pl.read_parquet("data.parquet")
    return (df,)

@app.cell
def _(df):
    result = df.filter(pl.col("year") == 2020).with_columns(
        (pl.col("x") / pl.col("x").sum()).alias("pct")
    )
    return (result,)

@app.cell
def _(mo, result):
    mo.ui.table(result)
    return ()
```

### What to Expect

- **Cells are not ordered top-to-bottom** -- marimo determines execution order from the
  dependency graph. You can place cells in any visual order.
- **No hidden state** -- if you delete a cell, its variables disappear. No more "this
  works because I ran that other cell 20 minutes ago."
- **`def _():` wrappers** are marimo's cell boundary syntax. They look like function
  definitions but are not meant to be called -- marimo's runtime manages them.
- **No `library()` equivalent** -- Python imports go inside cells and are scoped to the
  dependency graph.

**Note:** In DAAF research pipelines, marimo notebooks are assembled at Stage 9 as a
read-only compilation of executed scripts. They are not used for interactive exploration
during analysis stages. See the `marimo` skill for details.

---

## Section 3: Project Organization

### R Project Structure

R projects are flexible. A typical `.Rproj` layout might be:

```
my_project/
├── my_project.Rproj
├── data/
│   ├── raw/
│   └── processed/
├── scripts/
│   ├── 01_clean.R
│   └── 02_analysis.R
├── output/
│   └── figures/
├── R/                    # Helper functions (optional)
└── renv/                 # Package management (optional)
```

### DAAF Project Structure

DAAF enforces a stage-based directory layout:

```
research/2026-01-24_School_Poverty_Analysis/
├── scripts/
│   ├── stage5_fetch/     # Data acquisition
│   ├── stage6_clean/     # Cleaning
│   ├── stage7_transform/ # Transformation
│   └── stage8_analysis/  # Analysis and visualization
├── data/
│   ├── raw/              # Immutable raw data (parquet only)
│   └── processed/        # Derived data (parquet only)
├── output/
│   ├── analysis/         # Analysis outputs (parquet)
│   └── figures/          # Plots (PNG)
├── STATE.md              # Session state tracking
└── LEARNINGS.md          # Methodological insights
```

### Key Differences

| Aspect | R Convention | DAAF Convention |
|--------|-------------|----------------|
| Script organization | Flat or ad hoc numbering | Stage-based directories (stage5, stage6, ...) |
| Script modification | Overwrite in place | Immutable after execution; new version (`_a.py`) |
| Data format | CSV, RDS, RData | Parquet exclusively |
| Helper functions | `R/` or `source("helpers.R")` | Scripts are self-contained (no sourcing) |
| State tracking | Ad hoc or `.RData` workspace | Explicit `STATE.md` document |
| Documentation | Comments + README | Inline Audit Trail (IAT) with mandatory `# INTENT:`, `# REASONING:`, `# ASSUMES:` |

### Script Versioning

R users typically overwrite a script when fixing errors. DAAF never modifies a script after
its execution output has been appended:

```
01_join-data.py        # Original — executed, output appended, now immutable
01_join-data_a.py      # Fix attempt 1 — new file with corrections
01_join-data_b.py      # Fix attempt 2 — if _a also failed
```

All versions remain in the directory. This creates a complete debugging history that a
reviewer can follow.

---

## Section 4: Package Management

### R Package Management

```r
# Install a package
install.packages("dplyr")

# Use renv for reproducibility
renv::init()
renv::snapshot()   # Locks package versions
renv::restore()    # Restores from lockfile

# Load a package — attaches ALL exported functions to search path
library(dplyr)
# Now filter(), select(), mutate() are all available directly

# Handle conflicts
conflicted::conflict_prefer("filter", "dplyr")
```

### Python / DAAF Package Management

```python
# Packages are pre-installed in the DAAF Docker container
# No pip install during analysis sessions

# Import requires explicit namespacing
import polars as pl       # pl.col(), pl.read_parquet(), etc.
import pyfixest as pf     # pf.feols(), pf.etable(), etc.
from sklearn.ensemble import RandomForestClassifier  # specific imports

# No namespace conflicts — the prefix prevents them
pl.col("x")              # Always clear this is polars
```

| Aspect | R | Python / DAAF |
|--------|---|---------------|
| Install mechanism | `install.packages()` | Pre-installed in Docker container |
| Version locking | `renv` | Docker image pins all versions |
| Loading | `library(pkg)` exports everything | `import pkg as alias` requires prefix |
| Name conflicts | `conflicted` package resolves | Namespacing prevents conflicts entirely |
| Adding a new package | `install.packages()` at any time | Ask the orchestrator; requires container rebuild |

### The Namespace Difference in Practice

This is a frequent friction point. In R, after `library(dplyr)`, you type `filter()` and it
works. In Python, after `import polars as pl`, you must type `pl.filter()` -- or more
precisely, `df.filter(pl.col("x") > 5)`.

The upside: you always know which library a function comes from. When reading unfamiliar
code, the prefix tells you instantly. In R, seeing `filter()` alone, you might need to check
whether it is `dplyr::filter` or `stats::filter`.

---

## Section 5: Getting Help

| R | Python | DAAF |
|---|--------|------|
| `?function` or `help(function)` | `help(function)` or `function?` in IPython | Not interactive -- read skill references |
| `str(object)` | `type(obj)`, `df.schema` (polars), `df.dtypes` (pandas) | Print in script |
| `head(df)` | `df.head()` | Same concept, method vs function |
| `summary(df)` | `df.describe()` (pandas) or `df.describe()` (polars) | Print in script |
| `class(object)` | `type(object)` | |
| `dim(df)` | `df.shape` | Property, not function |
| `names(df)` or `colnames(df)` | `df.columns` | Property |
| `nrow(df)` | `df.shape[0]` or `len(df)` | |
| `vignette("topic")` | Online documentation | DAAF skill reference files serve this role |
| `example(function)` | Docstring examples | Skill reference files include code examples |
| `glimpse(df)` (dplyr) | `df.glimpse()` (polars) or `print(df.head())` | |

### DAAF's Skill System as Vignettes

In R, you might read `vignette("dplyr")` for a guided introduction to a package. In DAAF,
the equivalent is the **skill reference files** -- domain-specific guidance documents loaded
on demand by the agent. Each skill has a `SKILL.md` with decision trees that route to
focused reference files covering syntax, patterns, and pitfalls.

You do not need to find and read these yourself. When you describe what you want to do, the
agent loads the relevant skill automatically and follows its guidance.

---

## Section 6: Reproducibility

### R Reproducibility Practices

```r
# Set random seed
set.seed(42)

# Record session info
sessionInfo()

# Save workspace (common but often discouraged)
save.image(".RData")

# renv for package versions
renv::snapshot()
```

### DAAF Reproducibility Practices

```python
# Set random seed (same concept)
import random
import numpy as np
random.seed(42)
np.random.seed(42)

# scikit-learn: random_state parameter on individual estimators
from sklearn.ensemble import RandomForestClassifier
model = RandomForestClassifier(n_estimators=100, random_state=42)
```

| R Practice | DAAF Equivalent | Notes |
|-----------|----------------|-------|
| `set.seed(42)` | `random.seed(42)` / `np.random.seed(42)` / `random_state=42` | Per-library in Python |
| `sessionInfo()` | Docker container pins all versions | Reproducibility by environment, not runtime inspection |
| `.RData` workspace | No equivalent -- data saved as parquet files | DAAF explicitly avoids workspace persistence |
| `renv::snapshot()` | Docker image = the lockfile | Versions frozen at container build time |
| Script comments | Inline Audit Trail (IAT) | Structured: `# INTENT:`, `# REASONING:`, `# ASSUMES:` |
| `source("script.R")` | Each script is self-contained | No sourcing; all dependencies explicit in each file |
| Knitted document | Execution log appended to script | Output is permanently attached to the code that produced it |

### The IAT System

DAAF's Inline Audit Trail is like a formalized, mandatory version of R script comments.
Instead of ad hoc `# clean up the data` comments, every filter, join, aggregation, and
derived column must include structured annotations:

```python
# INTENT: Remove records with missing enrollment to ensure complete-case analysis
# REASONING: 3.2% of records have null enrollment; MCAR pattern confirmed in profiling
# ASSUMES: Missingness is MCAR — if MNAR, results may undercount small schools
df = df.filter(pl.col("enrollment").is_not_null())
```

This serves the same purpose as well-commented R code, but the structure makes it
machine-parseable and audit-reviewable by DAAF's code-reviewer agent.

---

## Section 7: Why Polars (Not pandas)

R users transitioning to Python often expect to learn pandas, since it is the most widely
known Python data library. DAAF uses **polars** instead. The reason depends on your R
background:

### For data.table Users

If you used `data.table` in R, polars will feel familiar:

- **Speed-first design** -- polars and data.table share the philosophy that data manipulation
  should be fast by default, without manual optimization
- **Lazy evaluation** -- polars' `LazyFrame` is conceptually similar to `data.table`'s
  query optimization; operations are planned before execution
- **No copying** -- both avoid unnecessary data copies
- **Multithreading** -- polars automatically uses all cores; data.table does this for some
  operations

The syntax is different, but the mental model transfers directly.

### For dplyr Users

The paradigm shift is larger, but the payoff is significant:

- **Expressions instead of verbs** -- dplyr has `mutate()`, `filter()`, `select()` as
  separate verbs. Polars uses a composable expression system: `pl.col("x").method().alias("y")`
- **No row index** -- dplyr tibbles have implicit row positions. Polars DataFrames have no
  row index at all. Use `with_row_index()` if you need one.
- **Explicit column references** -- `pl.col("column_name")` instead of bare column names
- **Method chaining instead of pipes** -- `df.filter(...).with_columns(...)` instead of
  `df %>% filter(...) %>% mutate(...)`

See `polars-dplyr.md` in this skill for the complete verb-by-verb mapping, and
`polars-strings-dates-factors.md` for string, date, and categorical operations.

### When pandas Appears

Some Python libraries require pandas DataFrames as input:

- **statsmodels** -- all modeling functions expect pandas
- **pyfixest** -- expects pandas (converts internally)
- **scikit-learn** -- expects numpy arrays or pandas DataFrames
- **geopandas** -- extends pandas, not polars

The pattern in DAAF: do all data manipulation in polars, then convert at the modeling
boundary:

```python
# Polars for wrangling
df = pl.read_parquet("data.parquet")
df = df.filter(pl.col("year") == 2020).select(["y", "x1", "x2"])

# Convert to pandas at the modeling boundary
pdf = df.to_pandas()
model = pf.feols("y ~ x1 + x2", data=pdf)
```

---

## Section 8: Common Workflow Adjustments

These are the questions R users ask most frequently when starting with DAAF, with direct
answers:

**"I want to explore my data interactively."**
Write a profiling script that prints summary statistics, then execute it. The output
appended to the script serves as your exploration record. For ongoing interactive work,
marimo notebooks can provide a reactive exploration environment, but analysis pipelines
use file-first execution.

**"I want to `source()` another script."**
DAAF scripts are self-contained by design. Each script loads its own data from parquet files
and includes all necessary imports. This ensures any script can be understood and re-executed
independently without tracking a chain of `source()` dependencies.

**"I want to save my workspace so I can pick up where I left off."**
Save processed data to parquet: `df.write_parquet("data/processed/clean_data.parquet")`.
DAAF tracks session state in `STATE.md`, which records what has been completed and what
remains. The next session reads `STATE.md` to resume.

**"I want to install a package."**
Packages are pre-installed in the DAAF Docker container. If you need something not
available, inform the orchestrator -- it may require a container rebuild. Do not run
`pip install` during analysis.

**"I want to quickly check a column's values."**
Add `print(df["column_name"].value_counts())` to your script. The output appears in the
appended execution log.

**"Where is my Plots pane?"**
Plots are saved to files: `plt.savefig("output/figures/plot_name.png", dpi=300)`. There is
no interactive plot viewer in the file-first model. In marimo, plots render inline.

**"I want to use `browser()` to debug."**
Python's equivalent is `breakpoint()`, but DAAF's file-first model does not support
interactive debugging. Instead, add diagnostic `print()` statements and create a debug
script in `scripts/debug/`. If a script fails, create a versioned copy with additional
diagnostics rather than debugging interactively.

**"How do I see my data's structure?"**
```python
# In a script:
print(f"Shape: {df.shape}")
print(f"Schema:\n{df.schema}")
print(f"Nulls:\n{df.null_count()}")
print(df.head(10))
print(df.describe())
```

**"I want to pipe things together like `%>%`."**
Polars uses method chaining, which achieves the same visual flow:

```r
# R
result <- df %>%
  filter(year == 2020) %>%
  group_by(state) %>%
  summarise(mean_x = mean(x, na.rm = TRUE))
```

```python
# Python (polars)
result = (
    df
    .filter(pl.col("year") == 2020)
    .group_by("state")
    .agg(pl.col("x").mean().alias("mean_x"))
)
```

The parentheses around the chain allow multi-line method chaining without backslash
continuation -- this is the standard Python idiom for pipeline-style code.

---

> **Sources:** marimo documentation (docs.marimo.io, accessed 2026-03-28);
> RStudio IDE documentation (docs.posit.co, accessed 2026-03-28);
> Quarto documentation (quarto.org, accessed 2026-03-28);
> polars documentation (docs.pola.rs, accessed 2026-03-28);
> Wickham & Grolemund, *R for Data Science* (2e, 2023)
