---
name: stata-python-translation
description: >-
  Stata-to-Python translation for data analysis. Maps Stata commands (reghdfe, xtreg, ivregress, margins, esttab, svy:) to Python (polars, pyfixest, statsmodels, svy). Use when user has Stata background or requests Stata-equivalent code comments.
metadata:
  audience: research-coders
  domain: research-methodology
  skill-last-updated: "2026-03-28"
---

# Stata-to-Python Translation Skill

Stata-to-Python translation reference for quantitative social science data analysis. Maps Stata commands and packages (reghdfe, xtreg, ivregress, margins, esttab, svy:, graph twoway) to DAAF Python equivalents (polars, pyfixest, statsmodels, linearmodels, marginaleffects, svy, plotnine). Use when user mentions Stata background, requests Stata-equivalent code comments, needs to understand Python analysis code from a Stata perspective, or wants to translate Stata data analysis concepts to Python. Covers paradigm differences, command-by-command operation translations, regression modeling, causal inference, visualization, and workflow adaptation.

Cross-language translation reference for researchers moving between the Stata and Python data analysis ecosystems. This skill maps Stata commands, idioms, and workflows to their DAAF Python equivalents so that Stata-background users can audit, understand, and learn from DAAF-produced code, and so that code-producing agents can annotate their output with Stata equivalents when directed.

This skill is a **routing hub** -- it provides overview tables, decision trees, and directs readers to the detailed reference files listed below. The reference files contain the exhaustive command-by-command mappings, code examples, and edge-case documentation.

## What This Skill Does

- Maps the Stata command universe to DAAF's Python stack across data management, regression modeling, causal inference, surveys, visualization, and workflow tooling
- Provides a structured annotation protocol for agents to add inline Stata-equivalent comments to Python code
- Identifies paradigm gaps where Stata and Python diverge fundamentally, so users know where to expect friction

**Use cases:**

1. Stata user auditing DAAF Python code and needing to understand what operations are being performed
2. Agent annotating code with Stata-equivalent comments for a Stata-background researcher
3. Stata user learning Python for data analysis and needing a conceptual bridge
4. Translating a specific Stata command or do-file idiom to its Python equivalent
5. Understanding where Stata commands have no direct Python equivalent (and what the workaround is)

## How to Use This Skill

### Reference File Structure

Each topic in `./references/` contains focused documentation:

| File | Purpose | When to Read |
|------|---------|--------------|
| `paradigm-differences.md` | Core language and paradigm differences (single-dataset model, missing values, value labels, macros, by:/_n/_N) | Encountering fundamental Stata-vs-Python confusion |
| `data-management.md` | gen/replace/keep/drop/sort/merge/append/reshape/collapse/egen to polars | Reading or writing data manipulation code |
| `strings-dates-labels.md` | String functions, date epoch, value labels, encode/decode | Working with string, date, or categorical columns |
| `regression-modeling.md` | regress/areg/reghdfe/xtreg/ivregress/logit/probit/margins/test/esttab to pyfixest/statsmodels/linearmodels | Reading or writing regression code |
| `causal-inference.md` | DiD/RDD/IV/event studies/synthetic control/matching | Working with causal inference methods |
| `visualization.md` | graph twoway/bar/box/histogram to plotnine/plotly | Reading or writing visualization code |
| `survey-spatial-ml.md` | svy: commands, spatial data, machine learning | Working with surveys, spatial data, or ML |
| `workflow-environment.md` | Do-files/log/macros/ado/ssc to Python/DAAF execution model | Adapting to DAAF's execution model |
| `external-resources.md` | Curated guides and tutorials with provenance | Seeking additional learning materials |
| `gotchas.md` | Common Stata-user mistakes in Python | Debugging or reviewing code from Stata perspective |

### Reading Order

1. **Stata user auditing DAAF code:** `paradigm-differences.md` then the relevant domain file (e.g., `data-management.md` for wrangling, `regression-modeling.md` for models) then `gotchas.md`
2. **Agent annotating code with Stata equivalents:** Agent Code Annotation Protocol section below, then the relevant domain file for the code being annotated
3. **Learning Python from Stata background:** `paradigm-differences.md` then `data-management.md` then `workflow-environment.md` then `external-resources.md`
4. **Looking up a specific Stata command translation:** Quick Decision Trees below, then the relevant reference file

## Quick Decision Trees

### "How do I do X from Stata in Python?"

```
What kind of Stata command?
+-  Data management (gen, replace, keep, drop, merge, reshape, collapse)
|   +-- ./references/data-management.md
+-  Group operations (by:, bysort, egen)
|   +-- ./references/data-management.md
+-  Regression / estimation (regress, areg, reghdfe, xtreg, logit, probit)
|   +-- ./references/regression-modeling.md
+-  Post-estimation (margins, test, lincom, nlcom, predict, esttab)
|   +-- ./references/regression-modeling.md
+-  Causal inference (diff, did_multiplegt, rdrobust, teffects, synth)
|   +-- ./references/causal-inference.md
+-  Surveys (svyset, svy:)
|   +-- ./references/survey-spatial-ml.md
+-  Plotting (graph twoway, histogram, graph bar)
|   +-- ./references/visualization.md
+-  String/date manipulation (substr, strpos, date, mdy)
|   +-- ./references/strings-dates-labels.md
+-  Value labels (label define, encode, decode)
|   +-- ./references/strings-dates-labels.md
+-- Programming (local, global, foreach, forvalues, tempvar, preserve)
    +-- ./references/workflow-environment.md
```

### "Why does this Python code look different from Stata?"

```
What looks unfamiliar?
+-  Expression syntax (pl.col().method().alias())
|   +-- ./references/paradigm-differences.md
+-  Missing values (None vs NaN vs null vs .)
|   +-- ./references/paradigm-differences.md
+-  No single "dataset" -- multiple DataFrames everywhere
|   +-- ./references/paradigm-differences.md
+-  Value labels missing from output
|   +-- ./references/paradigm-differences.md
+-  Regression output structure (model objects vs e()/r())
|   +-- ./references/regression-modeling.md
+-  No `by:` prefix -- .over() and .group_by() instead
|   +-- ./references/paradigm-differences.md
+-- Import statements and namespacing
    +-- ./references/gotchas.md
```

### "I want to translate a Stata do-file to Python"

```
What does the do-file do?
+-  Loads and wrangles data (use, gen, replace, keep, merge, collapse)
|   +-- ./references/data-management.md
+-  Runs regressions (regress, xtreg, reghdfe, ivregress)
|   +-- ./references/regression-modeling.md
+-  Creates tables (esttab, outreg2, margins)
|   +-- ./references/regression-modeling.md
+-  Creates plots (graph twoway, histogram)
|   +-- ./references/visualization.md
+-  Uses survey weights (svyset, svy:)
|   +-- ./references/survey-spatial-ml.md
+-  Multiple of the above
|   +-- Start with ./references/paradigm-differences.md, then each relevant file
+-- Uses macros, loops, or programs
    +-- ./references/workflow-environment.md
```

### "Something isn't working and I think it's a Stata habit"

```
What went wrong?
+-  Missing values behaving differently than expected
|   +-- ./references/paradigm-differences.md
+-  gen/replace pattern not translating
|   +-- ./references/gotchas.md
+-  Merge producing wrong results (no _merge diagnostic)
|   +-- ./references/gotchas.md
+-  Model output looks different from Stata
|   +-- ./references/regression-modeling.md
+-  Off-by-one error (0-indexed vs 1-indexed)
|   +-- ./references/gotchas.md
+-  `by:` / `_n` / `_N` not available
|   +-- ./references/paradigm-differences.md
+-- Macro syntax not working
    +-- ./references/gotchas.md
```

### "Which Python package replaces my Stata command?"

```
Which Stata command?
+-  regress / areg / reghdfe -> pyfixest
|   +-- ./references/regression-modeling.md
+-  xtreg (fe/re) -> pyfixest (FE) / linearmodels (RE)
|   +-- ./references/regression-modeling.md
+-  ivregress / ivreg2 / ivreghdfe -> pyfixest / linearmodels
|   +-- ./references/regression-modeling.md
+-  logit / probit / ologit / mlogit -> statsmodels
|   +-- ./references/regression-modeling.md
+-  poisson / nbreg / ppmlhdfe -> statsmodels / pyfixest fepois
|   +-- ./references/regression-modeling.md
+-  margins / marginsplot -> marginaleffects
|   +-- ./references/regression-modeling.md
+-  esttab / outreg2 -> pf.etable()
|   +-- ./references/regression-modeling.md
+-  test / lincom / nlcom -> pyfixest .wald_test() / marginaleffects hypotheses()
|   +-- ./references/regression-modeling.md
+-  gen / replace / drop / keep / sort -> polars
|   +-- ./references/data-management.md
+-  merge / append -> polars .join() / pl.concat()
|   +-- ./references/data-management.md
+-  collapse / egen -> polars .group_by().agg() / .over()
|   +-- ./references/data-management.md
+-  reshape long/wide -> polars .unpivot() / .pivot()
|   +-- ./references/data-management.md
+-  graph twoway / histogram / graph bar -> plotnine / plotly
|   +-- ./references/visualization.md
+-  svyset / svy: -> svy package
|   +-- ./references/survey-spatial-ml.md
+-  rdrobust -> rdrobust (Python, same authors)
|   +-- ./references/causal-inference.md
+-  binscatter -> binsreg (Python, same authors)
|   +-- ./references/causal-inference.md
+-  synth -> scpi (Python, same authors)
|   +-- ./references/causal-inference.md
+-- ado-file / ssc install -> pip install
    +-- ./references/workflow-environment.md
```

## Command Mapping Overview

| Stata Command(s) | Python Package | Fidelity | Key Difference |
|-------------------|---------------|----------|----------------|
| `regress`, `areg`, `reghdfe` | pyfixest | High | Near-identical formula syntax; `\|` for FE absorption |
| `xtreg, fe` | pyfixest | High | No `xtset` needed; FE specified in formula |
| `xtreg, re` | linearmodels | Medium | Requires pandas MultiIndex for panel structure |
| `ivregress`, `ivreg2`, `ivreghdfe` | pyfixest / linearmodels | High | Three-part formula for IV in pyfixest |
| `logit`, `probit`, `ologit`, `mlogit` | statsmodels | Medium | Requires `.fit()`; `C()` for categoricals in formulas |
| `poisson`, `ppmlhdfe` | statsmodels / pyfixest `fepois` | High | `fepois` for Poisson with multi-way FE |
| `margins`, `marginsplot` | marginaleffects | Medium | Separate package; different function names |
| `esttab`, `outreg2` | pyfixest `etable()` | High | `pf.etable([m1, m2])` produces publication tables |
| `gen`, `replace`, `drop`, `keep`, `sort` | polars | Low | Expression system vs imperative commands; immutable DataFrames |
| `merge`, `append` | polars `.join()`, `pl.concat()` | Medium | No automatic `_merge` diagnostic |
| `collapse`, `egen` | polars `.group_by().agg()`, `.over()` | Medium | Must choose aggregation vs window explicitly |
| `reshape long/wide` | polars `.unpivot()`, `.pivot()` | Medium | No in-place reshape; column naming differs |
| `graph twoway`, `histogram`, `graph bar` | plotnine / plotly | Low | Declarative grammar of graphics vs imperative graph syntax |
| `svyset`, `svy:` | svy | Medium | Explicit `Design`/`Sample` objects instead of persistent `svyset` |
| `rdrobust`, `rdplot` | rdrobust (Python) | Very High | Same authors; nearly identical API |
| `binscatter`, `binsreg` | binsreg (Python) | Very High | Same authors; nearly identical API |
| `synth` | scpi | High | Same authors; includes prediction intervals |
| `local`, `global`, `foreach`, `forvalues` | Python variables, f-strings, for loops | Low | Fundamentally different paradigm (text substitution vs value binding) |

**Fidelity key:** Very High = same authors, near-identical API. High = same capability, similar syntax. Medium = same capability, different API patterns. Low = fundamentally different paradigm requiring conceptual remapping.

## Library Versions

Translations in this skill reference specific library versions. Python versions are
pinned in DAAF's Docker environment (Python 3.12). Stata versions reference the
current release as of March 2026. When syntax or behavior has changed between
versions, the reference files note the change.

| Python Package | DAAF Version | Stata Equivalent | Stata Version |
|---|---|---|---|
| polars | 1.38.1 | Data management commands (gen, replace, merge, etc.) | Stata 18 |
| pyfixest | 0.40.0 | regress, areg, reghdfe, ivreghdfe, ppmlhdfe, esttab | Stata 18 + reghdfe 6.x |
| statsmodels | 0.14.6 | regress, logit, probit, poisson, nbreg, glm | Stata 18 |
| linearmodels | unpinned | xtreg, sureg, ivregress | Stata 18 |
| plotnine | 0.15.3 | graph twoway, graph bar, graph box, histogram | Stata 18 |
| plotly | 6.5.2 | (no direct Stata equivalent; interactive charts) | N/A |
| svy | 0.13.0 | svyset, svy: prefix commands | Stata 18 |
| marginaleffects | unpinned | margins, marginsplot, lincom, nlcom | Stata 18 |
| rdrobust | unpinned | rdrobust, rdplot, rdbwselect | rdrobust (SSC) |
| binsreg | unpinned | binsreg, binscatter | binsreg (SSC) |
| scpi | unpinned | synth, synth_runner | synth (SSC) |
| scikit-learn | 1.8.0 | (limited; teffects, psmatch2 partially) | Stata 18 |
| marimo | 0.19.11 | (no equivalent; replaces do-file + log workflow) | N/A |

**Unpinned packages:** linearmodels, marginaleffects, rdrobust, binsreg, and scpi install
the latest version at Docker build time. Translations reference their documented API as
of March 2026.

**Stata version note:** Stata 18 is the current release as of March 2026. Most command
mappings apply to Stata 15+; version-specific features (frames, `hdidregress`) are noted
in the reference files.

## Top 10 Paradigm Differences

These are the friction points Stata users encounter most frequently when reading or writing DAAF Python code. Each is covered in depth in the referenced file.

| # | Friction Point | Stata Way | Python Way | Reference |
|---|---------------|-----------|------------|-----------|
| 1 | Single-dataset model | One dataset in memory; commands implicit | Multiple DataFrames as variables; must specify which | `paradigm-differences.md` |
| 2 | Missing values | `.` = +infinity; 27 types (`.a`-`.z`) | `null` excluded from comparisons; one null type; NaN distinct | `paradigm-differences.md` |
| 3 | Value labels | Three-layer system (data, variable, value labels) | No built-in equivalent; dictionaries or Enum types | `paradigm-differences.md` |
| 4 | `by:`/`_n`/`_N` system | `bysort group: gen x = _N` | `.over("group")` (window) vs `.group_by().agg()` (collapse) | `paradigm-differences.md` |
| 5 | In-place modification | `replace var = expr` modifies data directly | `df = df.with_columns(...)` returns new DataFrame | `paradigm-differences.md` |
| 6 | Macro system | `` `local' `` and `$global` text substitution | Python variables + f-strings | `paradigm-differences.md` |
| 7 | `.fit()` required | `regress y x` auto-fits and prints | `smf.ols("y ~ x", data=df).fit()` -- two steps | `regression-modeling.md` |
| 8 | Expression system | `gen z = x * 2` (bare column names) | `df.with_columns((pl.col("x") * 2).alias("z"))` | `data-management.md` |
| 9 | Merge diagnostics | `_merge` variable (1/2/3) automatic | No automatic merge indicator; must add explicitly | `gotchas.md` |
| 10 | 1-based vs 0-based indexing | `_n` starts at 1; `var[1]` = first obs | Python indices start at 0 | `gotchas.md` |

## Agent Code Annotation Protocol

This section defines when and how code-producing agents add inline Stata-equivalent comments to DAAF Python scripts.

### When to Annotate

Annotations are added **only when the orchestrator explicitly passes a Stata-background directive** to the agent. This is not a default behavior.

**Trigger conditions** (orchestrator activates this when any apply):
- User states they have a Stata background
- User requests Stata-equivalent comments in code
- User asks to understand Python code from a Stata perspective

**How the orchestrator passes the directive:** The orchestrator adds the following to the agent prompt:

> "User has Stata background. Load stata-python-translation skill. Add inline Stata-equivalent comments for non-trivial data operations."

### Comment Format

```python
# Stata: gen log_income = log(income)
df = df.with_columns(pl.col("income").log().alias("log_income"))

# Stata: bysort state: egen mean_score = mean(test_score)
df = df.with_columns(
    pl.col("test_score").mean().over("state").alias("mean_score")
)

# Stata: reghdfe wage education experience, absorb(industry year) cluster(state)
fit = pf.feols("wage ~ education + experience | industry + year",
               data=pdf, vcov={"CRV1": "state"})

# Stata: drop if missing(income)
df = df.filter(pl.col("income").is_not_null())

# Stata: merge 1:1 school_id using "districts.dta"
df = df.join(districts, on="school_id", how="inner")
```

### What to Annotate

- **Annotate:** Data wrangling (polars operations), modeling calls (pyfixest, statsmodels, linearmodels), visualization layer construction (plotnine, plotly), causal inference method calls, survey estimation calls
- **Do NOT annotate:** Import statements, `print()`/`assert` validation lines, file I/O boilerplate (`pl.read_parquet`, `df.write_parquet`), config sections, section separator comments

### Rules

- One `# Stata:` comment per logical operation, placed on the line immediately above the Python code
- Keep annotations to a single line; abbreviate complex Stata command sequences if needed
- Stata annotations are **in addition to** standard IAT comments (`# INTENT:`, `# REASONING:`, `# ASSUMES:`), not a replacement
- Consumer agents: research-executor, code-reviewer, debugger, data-ingest

## Related Skills

| Skill | Relationship |
|-------|-------------|
| `polars` | Python-side data wrangling -- detailed API reference for the gen/replace/merge/collapse equivalent |
| `pyfixest` | Python-side fixed effects regression -- detailed API for the regress/reghdfe/ivregress equivalent |
| `plotnine` | Python-side static visualization -- detailed API for the graph twoway equivalent |
| `plotly` | Python-side interactive visualization -- no direct Stata equivalent |
| `statsmodels` | Python-side general modeling -- covers logit, probit, poisson, nbreg, glm equivalents |
| `linearmodels` | Python-side panel/IV models -- covers xtreg, sureg, ivregress equivalents |
| `scikit-learn` | Python-side ML -- covers limited teffects/matching equivalents |
| `svy` | Python-side survey analysis -- covers svyset and svy: prefix command equivalents |
| `geopandas` | Python-side spatial data -- covers Stata spmap/spregress equivalents |
| `marimo` | Python-side notebooks -- replaces do-file + log workflow |
| `r-python-translation` | Parallel skill for R-background users -- shares the same Python target stack |

**Note:** Individual tool skills contain library-specific usage guidance (syntax, gotchas, performance). This skill provides the Stata-to-Python conceptual bridge -- use both together when a Stata-background user is working with a specific library.

## Topic Index

| Topic | Reference File |
|-------|---------------|
| Single-dataset model (one dataset in memory) | `./references/paradigm-differences.md` |
| Missing values (. vs None/NaN/null) | `./references/paradigm-differences.md` |
| Extended missing values (.a-.z) | `./references/paradigm-differences.md` |
| Value labels (label define, label values) | `./references/paradigm-differences.md` |
| Variable labels (label variable) | `./references/paradigm-differences.md` |
| by: prefix and _n/_N system variables | `./references/paradigm-differences.md` |
| In-place modification vs immutable DataFrames | `./references/paradigm-differences.md` |
| Macro system (local, global) | `./references/paradigm-differences.md` |
| Estimation and e()/r() stored results | `./references/paradigm-differences.md` |
| Type system (destring/tostring vs .cast()) | `./references/paradigm-differences.md` |
| Panel data operators (L./F./D. vs .shift()/.over()) | `./references/paradigm-differences.md` |
| Package model (ssc install vs pip install) | `./references/paradigm-differences.md` |
| gen / replace / rename | `./references/data-management.md` |
| drop / keep (variables and observations) | `./references/data-management.md` |
| sort / gsort | `./references/data-management.md` |
| merge 1:1 / m:1 / 1:m | `./references/data-management.md` |
| append | `./references/data-management.md` |
| reshape long / reshape wide | `./references/data-management.md` |
| collapse (aggregation) | `./references/data-management.md` |
| egen functions (mean, sum, count, rowtotal, group, tag) | `./references/data-management.md` |
| encode / decode | `./references/strings-dates-labels.md` |
| String functions (substr, strpos, subinstr, regexm) | `./references/strings-dates-labels.md` |
| Date system (epoch, %td, mdy(), date()) | `./references/strings-dates-labels.md` |
| destring / tostring | `./references/strings-dates-labels.md` |
| regress (OLS) | `./references/regression-modeling.md` |
| areg / reghdfe (fixed effects) | `./references/regression-modeling.md` |
| xtreg fe / xtreg re (panel models) | `./references/regression-modeling.md` |
| ivregress / ivreg2 / ivreghdfe (IV) | `./references/regression-modeling.md` |
| logit / probit / ologit / mlogit | `./references/regression-modeling.md` |
| poisson / nbreg / ppmlhdfe | `./references/regression-modeling.md` |
| sureg (seemingly unrelated regression) | `./references/regression-modeling.md` |
| margins / marginsplot (marginal effects) | `./references/regression-modeling.md` |
| test / lincom / nlcom (hypothesis testing) | `./references/regression-modeling.md` |
| esttab / outreg2 (regression tables) | `./references/regression-modeling.md` |
| predict (fitted values, residuals) | `./references/regression-modeling.md` |
| Robust and clustered standard errors | `./references/regression-modeling.md` |
| Factor variable notation (i., c., #, ##) | `./references/regression-modeling.md` |
| diff / did_multiplegt / csdid (DiD) | `./references/causal-inference.md` |
| eventstudyinteract / event studies | `./references/causal-inference.md` |
| rdrobust / rdplot (regression discontinuity) | `./references/causal-inference.md` |
| teffects / psmatch2 / cem (matching) | `./references/causal-inference.md` |
| synth / synth_runner (synthetic control) | `./references/causal-inference.md` |
| binscatter / binsreg | `./references/causal-inference.md` |
| graph twoway scatter / line / area / connected | `./references/visualization.md` |
| graph bar / graph box / histogram / kdensity | `./references/visualization.md` |
| graph export | `./references/visualization.md` |
| coefplot / iplot | `./references/visualization.md` |
| svyset / svy: prefix | `./references/survey-spatial-ml.md` |
| svy: mean / total / proportion / ratio | `./references/survey-spatial-ml.md` |
| svy: regress / logit | `./references/survey-spatial-ml.md` |
| Spatial data analysis | `./references/survey-spatial-ml.md` |
| Machine learning (teffects, matching workarounds) | `./references/survey-spatial-ml.md` |
| Do-file execution model | `./references/workflow-environment.md` |
| Log files (log using) | `./references/workflow-environment.md` |
| Ado-files and ssc install | `./references/workflow-environment.md` |
| Macros in loops (foreach, forvalues) | `./references/workflow-environment.md` |
| tempvar / tempfile / preserve / restore | `./references/workflow-environment.md` |
| quietly / capture / noisily | `./references/workflow-environment.md` |
| Curated Stata-to-Python migration guides | `./references/external-resources.md` |
| Textbooks with trilingual code (Stata/R/Python) | `./references/external-resources.md` |
| Package documentation links | `./references/external-resources.md` |
| Tutorial recommendations with provenance | `./references/external-resources.md` |
| gen/replace pattern not translating | `./references/gotchas.md` |
| Missing value comparison traps | `./references/gotchas.md` |
| drop if -> filter(NOT) negation trap | `./references/gotchas.md` |
| Merge without _merge diagnostics | `./references/gotchas.md` |
| egen rowtotal missing-value behavior | `./references/gotchas.md` |
| .fit() forgotten in statsmodels | `./references/gotchas.md` |
| Robust SE syntax differences | `./references/gotchas.md` |
| 0-based vs 1-based indexing | `./references/gotchas.md` |
| Macro syntax in Python context | `./references/gotchas.md` |
| Error message translation table | `./references/gotchas.md` |
