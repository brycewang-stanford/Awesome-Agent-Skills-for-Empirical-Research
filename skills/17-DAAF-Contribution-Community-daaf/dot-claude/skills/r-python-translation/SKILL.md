---
name: r-python-translation
description: >-
  R-to-Python translation for data analysis. Maps R packages (tidyverse, ggplot2, fixest, survey, sf, plm) to Python equivalents (polars, plotnine, pyfixest, svy, geopandas). Use when user has R background or requests R-equivalent code comments.
metadata:
  audience: research-coders
  domain: research-methodology
  skill-last-updated: "2026-03-28"
---

# R-to-Python Translation Skill

R-to-Python translation reference for quantitative social science data analysis. Maps R ecosystem packages (tidyverse/dplyr, ggplot2, fixest, survey, sf, plm, lme4, marginaleffects, rdrobust) to DAAF Python equivalents (polars, plotnine, pyfixest, statsmodels, linearmodels, svy, geopandas). Use when user mentions R/RStudio background, requests R-equivalent code comments, needs to understand Python analysis code from an R perspective, or wants to translate R data analysis concepts to Python. Covers paradigm differences, verb-by-verb operation translations, regression modeling, causal inference, visualization, and workflow adaptation.

Cross-language translation reference for researchers moving between the R and Python data analysis ecosystems. This skill maps R packages, idioms, and workflows to their DAAF Python equivalents so that R-background users can audit, understand, and learn from DAAF-produced code, and so that code-producing agents can annotate their output with R equivalents when directed.

This skill is a **routing hub** — it provides overview tables, decision trees, and directs readers to the detailed reference files listed below. The reference files contain the exhaustive verb-by-verb mappings, code examples, and edge-case documentation.

## What This Skill Does

- Maps the R data analysis ecosystem to DAAF's Python stack across data wrangling, modeling, visualization, causal inference, surveys, spatial analysis, and workflow tooling
- Provides a structured annotation protocol for agents to add inline R-equivalent comments to Python code
- Identifies paradigm gaps where R and Python diverge fundamentally, so users know where to expect friction

**Use cases:**

1. R user auditing DAAF Python code and needing to understand what operations are being performed
2. Agent annotating code with R-equivalent comments for an R-background researcher
3. R user learning Python for data analysis and needing a conceptual bridge
4. Translating a specific R operation or idiom to its Python equivalent
5. Understanding where R tools have no direct Python equivalent (and what the workaround is)

## How to Use This Skill

### Reference File Structure

Each topic in `./references/` contains focused documentation:

| File | Purpose | When to Read |
|------|---------|--------------|
| `paradigm-differences.md` | Core language and paradigm differences | Encountering fundamental R-vs-Python confusion |
| `polars-dplyr.md` | Core dplyr/tidyr to polars verb mapping (select, filter, mutate, joins, reshaping, window functions, lazy eval) | Reading or writing data manipulation code |
| `polars-strings-dates-factors.md` | String, date/time, and factor operations (stringr, lubridate, forcats to polars) | Working with string/date/categorical columns |
| `regression-modeling.md` | fixest/stats/plm to pyfixest/statsmodels/linearmodels | Reading or writing regression code |
| `visualization.md` | ggplot2/plotly R to plotnine/plotly Python | Reading or writing visualization code |
| `causal-inference.md` | R causal inference ecosystem to Python equivalents | Working with DiD, RDD, IV, event studies |
| `survey-spatial-ml.md` | survey/sf/tidymodels to svy/geopandas/scikit-learn | Working with surveys, spatial data, or ML |
| `workflow-environment.md` | RStudio/Quarto workflow to DAAF/marimo workflow | Adapting to DAAF's execution model |
| `external-resources.md` | Curated guides and tutorials with provenance | Seeking additional learning materials |
| `gotchas.md` | Common R-user mistakes in Python | Debugging or reviewing code from R perspective |

### Reading Order

1. **R user auditing DAAF code:** `paradigm-differences.md` then the relevant domain file (e.g., `polars-dplyr.md` for data wrangling, `regression-modeling.md` for models) then `gotchas.md`
2. **Agent annotating code with R equivalents:** Agent Code Annotation Protocol section below, then the relevant domain file for the code being annotated
3. **Learning Python from R background:** `paradigm-differences.md` then `polars-dplyr.md` then `workflow-environment.md` then `external-resources.md`
4. **Looking up a specific translation:** Quick Decision Trees below, then the relevant reference file

## Quick Decision Trees

### "How do I do X from R in Python?"

```
What kind of R operation?
├─ Data wrangling (filter, mutate, join, pivot, summarise)
│   └─ ./references/polars-dplyr.md
├─ Regression / statistical modeling
│   └─ ./references/regression-modeling.md
├─ Plotting / visualization
│   └─ ./references/visualization.md
├─ Causal inference (DiD, RDD, IV, event studies)
│   └─ ./references/causal-inference.md
├─ Surveys / spatial / machine learning
│   └─ ./references/survey-spatial-ml.md
└─ Fundamental language differences (types, syntax, environment)
    └─ ./references/paradigm-differences.md
```

### "Why does this Python code look different from R?"

```
What looks unfamiliar?
├─ Expression syntax (pl.col().method().alias())
│   └─ ./references/paradigm-differences.md
├─ Missing values (None vs NaN vs null vs NA)
│   └─ ./references/paradigm-differences.md
├─ Formula interface (~) behaves differently
│   └─ ./references/regression-modeling.md
├─ Import patterns and namespacing
│   └─ ./references/gotchas.md
└─ No interactive REPL / console workflow
    └─ ./references/workflow-environment.md
```

### "I want to translate an R script to Python"

```
What does the R script do?
├─ Loads and wrangles data (read_csv, dplyr verbs)
│   └─ ./references/polars-dplyr.md
├─ Runs regressions (lm, feols, plm)
│   └─ ./references/regression-modeling.md
├─ Creates plots (ggplot, plotly)
│   └─ ./references/visualization.md
├─ Uses survey weights (svydesign, svymean)
│   └─ ./references/survey-spatial-ml.md
├─ Spatial operations (sf, st_join)
│   └─ ./references/survey-spatial-ml.md
├─ Multiple of the above
│   └─ Start with ./references/paradigm-differences.md, then each relevant file
└─ Uses a package not listed above
    └─ ./references/external-resources.md for broader ecosystem guidance
```

### "Something isn't working and I think it's an R habit"

```
What went wrong?
├─ 1-indexed access gave wrong element
│   └─ ./references/gotchas.md
├─ Factor/categorical behaves differently
│   └─ ./references/gotchas.md
├─ NA handling surprised me
│   └─ ./references/paradigm-differences.md
├─ Pipe operator (|> or %>%) not available
│   └─ ./references/paradigm-differences.md
├─ library() vs import confusion
│   └─ ./references/gotchas.md
└─ Model output structure is different
    └─ ./references/regression-modeling.md
```

### "Which Python package replaces my R package?"

```
Which R package?
├─ dplyr / tidyr / readr / tibble → polars
│   └─ ./references/polars-dplyr.md
├─ ggplot2 → plotnine
│   └─ ./references/visualization.md
├─ plotly (R) → plotly (Python)
│   └─ ./references/visualization.md
├─ fixest → pyfixest
│   └─ ./references/regression-modeling.md
├─ stats (lm, glm) → statsmodels
│   └─ ./references/regression-modeling.md
├─ plm / lme4 / estimatr → linearmodels
│   └─ ./references/regression-modeling.md
├─ survey → svy
│   └─ ./references/survey-spatial-ml.md
├─ sf / terra → geopandas
│   └─ ./references/survey-spatial-ml.md
├─ tidymodels / caret → scikit-learn
│   └─ ./references/survey-spatial-ml.md
├─ marginaleffects → marginaleffects (Python)
│   └─ ./references/regression-modeling.md
├─ rdrobust / did / synthdid → rdrobust / pyfixest DiD
│   └─ ./references/causal-inference.md
└─ Quarto / RMarkdown → marimo
    └─ ./references/workflow-environment.md
```

## Package Mapping Overview

| Python Package | R Equivalent | Fidelity | Key Difference |
|----------------|-------------|----------|----------------|
| polars | dplyr + tidyr + data.table | Low | Expression system vs verb grammar; method chaining vs pipe |
| pyfixest | fixest | High | Near-identical formula syntax; minor SE default differences |
| plotnine | ggplot2 | High | Same grammar of graphics; Python string quoting for aes |
| plotly | plotly (R) | High | `px.scatter()` vs `plot_ly()`; similar output |
| statsmodels | base R stats + lmtest + sandwich | Medium | Three formula dialects; manual vcov specification |
| linearmodels | plm + lme4 + estimatr | Medium | Requires pandas MultiIndex for panel structure |
| scikit-learn | tidymodels / caret | Medium | Imperative fit/predict vs declarative recipe pipeline |
| geopandas | sf + terra | Medium | shapely geometries vs sfc; different CRS handling |
| svy | survey (Lumley) | Medium | Limited GLM family coverage (gaussian/binomial/Poisson only) |
| marimo | Quarto / RMarkdown | Medium | Reactive cells vs knit-based linear execution |

**Fidelity key:** High = near-direct translation, same mental model. Medium = same capability, different API patterns. Low = fundamentally different paradigm requiring conceptual remapping.

## Library Versions

Translations in this skill reference specific library versions. Python versions are
pinned in DAAF's Docker environment (Python 3.12). R versions reference CRAN releases
as of March 2026. When syntax or behavior has changed between versions, the reference
files note the change.

| Python Package | DAAF Version | R Equivalent | R Version (CRAN) |
|---|---|---|---|
| polars | 1.38.1 | dplyr + tidyr + data.table | dplyr 1.2.0, tidyr 1.3.2, data.table 1.18.2 |
| pyfixest | 0.40.0 | fixest | 0.14.0 |
| plotnine | 0.15.3 | ggplot2 | 4.0.2 |
| plotly | 6.5.2 | plotly (R) | 4.12.0 |
| statsmodels | 0.14.6 | base R stats + lmtest + sandwich | lmtest 0.9-40, sandwich 3.1-1 |
| linearmodels | unpinned | plm + lme4 + estimatr | plm 2.6-7, lme4 2.0-1 |
| scikit-learn | 1.8.0 | tidymodels / caret | tidymodels 1.4.1, caret 7.0-1 |
| geopandas | 1.1.3 | sf + terra | sf 1.1-0, terra 1.9-11 |
| svy | 0.13.0 | survey | survey 4.5 |
| marginaleffects | unpinned | marginaleffects (R) | 0.32.0 |
| rdrobust | unpinned | rdrobust (R) | 3.0.0 |
| marimo | 0.19.11 | Quarto / RMarkdown | Quarto 1.6.x |

**Unpinned packages:** linearmodels, marginaleffects, and rdrobust install the latest
version at Docker build time. Translations for these packages reference their documented
API as of March 2026.

**R version note:** R package versions are from CRAN as of March 2026 (R 4.5.3). Check
`packageVersion("pkg")` in your R installation to verify your local version matches.

## Top 10 Paradigm Differences

These are the friction points R users encounter most frequently when reading or writing DAAF Python code. Each is covered in depth in the referenced file.

| # | Friction Point | R Way | Python Way | Reference |
|---|---------------|-------|------------|-----------|
| 1 | Expression system | `df %>% mutate(x = a + b)` | `df.with_columns((pl.col("a") + pl.col("b")).alias("x"))` | `paradigm-differences.md` |
| 2 | Formula fragmentation | One universal `~` syntax | Three dialects (pyfixest, statsmodels, linearmodels) | `regression-modeling.md` |
| 3 | Missing values | Single `NA` type | `None`, `NaN`, and `null` (context-dependent) | `paradigm-differences.md` |
| 4 | mutate equivalent | `mutate(new = expr)` | `with_columns(expr.alias("new"))` | `polars-dplyr.md` |
| 5 | No row index | Tibbles have row numbers | Polars has no row index; use `with_row_index()` | `paradigm-differences.md` |
| 6 | Polars-to-pandas bridge | Data frames go directly into models | Must call `.to_pandas()` before statsmodels/pyfixest | `paradigm-differences.md` |
| 7 | Factor vs Categorical | `factor()` with ordered levels | `pl.Categorical` / `pd.Categorical` (different semantics) | `gotchas.md` |
| 8 | Package fragmentation | One package per domain (fixest does it all) | Multiple packages per domain (statsmodels + linearmodels + pyfixest) | `paradigm-differences.md` |
| 9 | 1-indexed vs 0-indexed | `x[1]` is first element | `x[0]` is first element | `gotchas.md` |
| 10 | Namespace model | `library()` exports all names | `import` requires explicit namespacing | `gotchas.md` |

## Agent Code Annotation Protocol

This section defines when and how code-producing agents add inline R-equivalent comments to DAAF Python scripts.

### When to Annotate

Annotations are added **only when the orchestrator explicitly passes an R-background directive** to the agent. This is not a default behavior.

**Trigger conditions** (orchestrator activates this when any apply):
- User states they have an R / RStudio background
- User requests R-equivalent comments in code
- User asks to understand Python code from an R perspective

**How the orchestrator passes the directive:** The orchestrator adds the following to the agent prompt:

> "User has R background. Load r-python-translation skill. Add inline R-equivalent comments for non-trivial data operations."

### Comment Format

```python
# R: df %>% filter(year == 2020)
filtered = df.filter(pl.col("year") == 2020)

# R: df %>% mutate(pct = count / sum(count))
result = df.with_columns(
    (pl.col("count") / pl.col("count").sum()).alias("pct")
)

# R: feols(y ~ x1 + x2 | state + year, data = df, cluster = ~state)
fit = pf.feols("y ~ x1 + x2 | state + year", data=pdf, vcov={"CRV1": "state"})
```

### What to Annotate

- **Annotate:** Data wrangling (polars operations), modeling calls (pyfixest, statsmodels, linearmodels), visualization layer construction (plotnine, plotly), causal inference method calls
- **Do NOT annotate:** Import statements, `print()`/`assert` validation lines, file I/O boilerplate (`pl.read_parquet`, `df.write_parquet`), config sections, section separator comments

### Rules

- One `# R:` comment per logical operation, placed on the line immediately above the Python code
- Keep annotations to a single line; abbreviate complex R pipelines if needed
- R annotations are **in addition to** standard IAT comments (`# INTENT:`, `# REASONING:`, `# ASSUMES:`), not a replacement
- Consumer agents: research-executor, code-reviewer, debugger, data-ingest

## Related Skills

| Skill | Relationship |
|-------|-------------|
| `polars` | Python-side data wrangling — detailed API reference for the dplyr/tidyr equivalent |
| `pyfixest` | Python-side fixed effects regression — detailed API for the fixest equivalent |
| `plotnine` | Python-side static visualization — detailed API for the ggplot2 equivalent |
| `plotly` | Python-side interactive visualization — detailed API for plotly R equivalent |
| `statsmodels` | Python-side general modeling — covers base R stats, lmtest, sandwich equivalents |
| `linearmodels` | Python-side panel/IV models — covers plm, lme4, estimatr equivalents |
| `scikit-learn` | Python-side ML — covers tidymodels/caret equivalents |
| `geopandas` | Python-side spatial data — covers sf/terra equivalents |
| `svy` | Python-side survey analysis — covers survey (Lumley) equivalents |
| `marimo` | Python-side notebooks — covers Quarto/RMarkdown workflow equivalents |
| `stata-python-translation` | Parallel skill for Stata-background users — shares the same Python target stack |

**Note:** Individual tool skills contain library-specific usage guidance (syntax, gotchas, performance). This skill provides the R-to-Python conceptual bridge — use both together when an R-background user is working with a specific library.

## Topic Index

| Topic | Reference File |
|-------|---------------|
| Pipe operator (`%>%` / `|>`) equivalents | `./references/paradigm-differences.md` |
| Expression system (pl.col, .alias) | `./references/paradigm-differences.md` |
| Missing value semantics (NA vs None/NaN/null) | `./references/paradigm-differences.md` |
| Type system differences | `./references/paradigm-differences.md` |
| Package/namespace model | `./references/paradigm-differences.md` |
| 0-indexing vs 1-indexing | `./references/paradigm-differences.md` |
| Polars-to-pandas conversion for modeling | `./references/paradigm-differences.md` |
| Row index differences | `./references/paradigm-differences.md` |
| dplyr verb mapping (filter, select, mutate, arrange) | `./references/polars-dplyr.md` |
| summarise / group_by equivalents | `./references/polars-dplyr.md` |
| tidyr verbs (pivot_longer, pivot_wider, separate, unite) | `./references/polars-dplyr.md` |
| Join operations (left_join, inner_join, anti_join) | `./references/polars-dplyr.md` |
| String operations (stringr vs polars .str) | `./references/polars-strings-dates-factors.md` |
| Date operations (lubridate vs polars .dt) | `./references/polars-strings-dates-factors.md` |
| across() / where() equivalents | `./references/polars-dplyr.md` |
| case_when equivalent | `./references/polars-dplyr.md` |
| readr I/O equivalents | `./references/polars-dplyr.md` |
| fixest formula syntax in pyfixest | `./references/regression-modeling.md` |
| lm() / glm() in statsmodels | `./references/regression-modeling.md` |
| Formula interface comparison (three Python dialects) | `./references/regression-modeling.md` |
| Standard error specification differences | `./references/regression-modeling.md` |
| plm panel models in linearmodels | `./references/regression-modeling.md` |
| lme4 mixed effects equivalents | `./references/regression-modeling.md` |
| marginaleffects (R to Python) | `./references/regression-modeling.md` |
| Model summary / tidy output | `./references/regression-modeling.md` |
| Sandwich / robust SE equivalents | `./references/regression-modeling.md` |
| ggplot2 layer mapping to plotnine | `./references/visualization.md` |
| aes() string quoting in plotnine | `./references/visualization.md` |
| Theme customization | `./references/visualization.md` |
| Scale functions | `./references/visualization.md` |
| Faceting (facet_wrap, facet_grid) | `./references/visualization.md` |
| plotly R vs plotly Python | `./references/visualization.md` |
| ggsave equivalent | `./references/visualization.md` |
| Difference-in-differences (did, did2s) | `./references/causal-inference.md` |
| Regression discontinuity (rdrobust) | `./references/causal-inference.md` |
| Instrumental variables (ivreg vs pyfixest IV) | `./references/causal-inference.md` |
| Event study designs | `./references/causal-inference.md` |
| Synthetic control | `./references/causal-inference.md` |
| Matching / propensity scores | `./references/causal-inference.md` |
| survey package to svy | `./references/survey-spatial-ml.md` |
| svydesign / svymean / svyglm equivalents | `./references/survey-spatial-ml.md` |
| sf spatial operations to geopandas | `./references/survey-spatial-ml.md` |
| CRS / projection handling | `./references/survey-spatial-ml.md` |
| Spatial joins (st_join vs sjoin) | `./references/survey-spatial-ml.md` |
| tidymodels pipeline to scikit-learn | `./references/survey-spatial-ml.md` |
| RStudio vs DAAF workflow | `./references/workflow-environment.md` |
| Quarto / RMarkdown vs marimo | `./references/workflow-environment.md` |
| Interactive console vs file-first execution | `./references/workflow-environment.md` |
| Package management (renv vs pip/uv) | `./references/workflow-environment.md` |
| Project structure conventions | `./references/workflow-environment.md` |
| Curated R-to-Python migration guides | `./references/external-resources.md` |
| Package documentation links | `./references/external-resources.md` |
| Tutorial recommendations with provenance | `./references/external-resources.md` |
| 1-indexed list/vector access | `./references/gotchas.md` |
| Factor vs Categorical pitfalls | `./references/gotchas.md` |
| library() vs import habits | `./references/gotchas.md` |
| T/F vs True/False | `./references/gotchas.md` |
| Assignment operator (<- vs =) | `./references/gotchas.md` |
| Vectorized operations expectations | `./references/gotchas.md` |
| NULL vs None differences | `./references/gotchas.md` |
| apply family vs map/list comprehension | `./references/gotchas.md` |
| Copying semantics (R copy-on-modify vs Python references) | `./references/gotchas.md` |
| Logical operators (& / | vs and / or) | `./references/gotchas.md` |
| String interpolation (glue vs f-strings) | `./references/gotchas.md` |
| data.table vs polars | `./references/polars-strings-dates-factors.md` |
| Lazy evaluation (polars LazyFrame vs R lazy tibble) | `./references/polars-dplyr.md` |
| nest/unnest equivalents | `./references/polars-dplyr.md` |
| Window functions (over vs mutate + group_by) | `./references/polars-dplyr.md` |
| Coordinate systems (coord_flip, coord_polar) | `./references/visualization.md` |
| Stat layers (stat_smooth, stat_summary) | `./references/visualization.md` |
| Color palette mapping (viridis, brewer) | `./references/visualization.md` |
| Multi-panel layouts (patchwork vs subplot) | `./references/visualization.md` |
| Staggered DiD estimators | `./references/causal-inference.md` |
| Parallel trends testing | `./references/causal-inference.md` |
| BRR / jackknife replication weights | `./references/survey-spatial-ml.md` |
| Raster data handling (terra vs rasterio) | `./references/survey-spatial-ml.md` |
| Feature engineering (recipes vs sklearn Pipeline) | `./references/survey-spatial-ml.md` |
| Cross-validation (rsample vs sklearn) | `./references/survey-spatial-ml.md` |
| Environment/workspace differences (.RData vs nothing) | `./references/workflow-environment.md` |
| Debugging workflow (browser() vs breakpoint()) | `./references/workflow-environment.md` |
| R help system (?func) vs Python help(func) | `./references/workflow-environment.md` |
| Cheat sheet and quick-reference links | `./references/external-resources.md` |
| Community resources (Stack Overflow tags, forums) | `./references/external-resources.md` |
