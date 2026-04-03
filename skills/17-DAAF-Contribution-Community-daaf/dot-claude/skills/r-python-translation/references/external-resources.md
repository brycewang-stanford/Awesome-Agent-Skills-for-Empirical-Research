# External Resources for R-to-Python Translation

Curated catalog of resources for R users transitioning to Python in quantitative
social science contexts. Each entry is self-contained with provenance tracking,
quality assessment, and key takeaways so that the resource's value can be judged
without visiting the link.

Resources are assessed for currency, accuracy, and relevance to the DAAF stack
(polars, pyfixest, statsmodels, plotnine, geopandas). Entries marked with
currency concerns should be cross-checked against current documentation.

## Contents

- [Package-Specific Documentation](#package-specific-documentation)
- [Textbooks with Dual-Language Code](#textbooks-with-dual-language-code)
- [General R-to-Python Guides](#general-r-to-python-guides)
- [Social Science Methodology Resources](#social-science-methodology-resources)
- [R Package Documentation for Reference](#r-package-documentation-for-reference)

---

## Package-Specific Documentation

### pyfixest Documentation

- **Author(s):** Alexander Fischer, Styfen Schaer, and contributors
- **URL:** https://pyfixest.org/
- **Type:** Documentation
- **Last verified:** 2026-03-28
- **Quality:** Excellent
- **Relevance to DAAF:** High
- **Currency concern:** None --- actively maintained, aligned with fixest 0.13+
- **Key content:** Complete documentation for Python's fixest-syntax regression
  library. Covers OLS, IV, Poisson, and quantile regression with multi-way fixed
  effects. The quickstart explicitly references R fixest syntax and demonstrates
  identical formula notation (`Y ~ X | fe1 + fe2`).
- **Strengths:** Mirrors R fixest API closely; includes multiple estimation,
  difference-in-differences estimators (TWFE, did2s, lpdid, Sun-Abraham), and
  publication-quality tables via `etable()`. Formula syntax documentation makes
  direct comparison to R straightforward.
- **Limitations:** Some R fixest features (feglm with FE) not yet implemented.
  See the DAAF pyfixest skill's gotchas.md for the full gap list.

### plotnine Documentation

- **Author(s):** Hassan Kibirige
- **URL:** https://plotnine.org/
- **Type:** Documentation
- **Last verified:** 2026-03-28
- **Quality:** Good
- **Relevance to DAAF:** High
- **Currency concern:** None --- v0.15.3 as of verification date
- **Key content:** Python implementation of the grammar of graphics, with syntax
  intentionally mirroring ggplot2. Covers geoms, aesthetics, scales, facets,
  coords, and themes. The API reference is organized identically to ggplot2's
  function reference.
- **Strengths:** Near-identical syntax to ggplot2 means R users can translate
  plots with minimal changes. Most ggplot2 code translates by replacing `+` line
  continuation with Python's `+` operator inside parentheses.
- **Limitations:** Coverage is not 100% of ggplot2. Some extensions (e.g.,
  `ggrepel`, `patchwork`) do not have plotnine equivalents. When plotnine docs
  are sparse on a topic, the ggplot2 documentation remains a useful conceptual
  reference.

### marginaleffects: Model to Meaning

- **Author(s):** Vincent Arel-Bundock, Noah Greifer, Andrew Heiss
- **URL:** https://marginaleffects.com/
- **Type:** Documentation / Book
- **Last verified:** 2026-03-28
- **Quality:** Excellent
- **Relevance to DAAF:** High
- **Currency concern:** None --- actively maintained with bilingual R/Python support
- **Key content:** Free online textbook and software documentation for the
  marginaleffects package (available in both R and Python). Covers predictions,
  comparisons (contrasts, risk ratios, odds), slopes (marginal effects), and
  hypothesis testing across 100+ model classes. Every page has an R/Python toggle
  showing equivalent code in both languages.
- **Strengths:** The bilingual toggle is the gold standard for R-to-Python
  translation in post-estimation analysis. Covers causal inference, experiments,
  categorical outcomes, and ML interpretation. Published in the Journal of
  Statistical Software (v111, i09). Author royalties support charity.
- **Limitations:** Python API coverage lags slightly behind R for the most
  recently added model classes. Check the GitHub issues for current status.

### Polars: Coming from Pandas

- **Author(s):** Polars contributors
- **URL:** https://docs.pola.rs/user-guide/migration/pandas/
- **Type:** Documentation
- **Last verified:** 2026-03-28
- **Quality:** Excellent
- **Relevance to DAAF:** Medium (pandas-to-polars, not R-to-polars directly)
- **Currency concern:** None --- maintained as part of official polars docs
- **Key content:** Official migration guide covering the seven fundamental
  conceptual differences between pandas and polars: no index, Arrow memory
  format, parallelism, multiple engines, lazy evaluation, strict typing, and
  expression-based API. Includes code comparison patterns.
- **Strengths:** Authoritative source on polars idioms. The emphasis on avoiding
  pandas-style patterns ("if your Polars code looks like pandas code, it likely
  runs slower than it should") helps R users avoid the pandas intermediate step.
- **Limitations:** Assumes familiarity with pandas, not R. R users benefit more
  from the tidyverse-to-polars guides listed below, then using this as a
  conceptual supplement.

### rdrobust: RD Packages

- **Author(s):** Sebastian Calonico, Matias Cattaneo, Rocio Titiunik, and others
- **URL:** https://rdpackages.github.io/rdrobust/
- **Type:** Documentation
- **Last verified:** 2026-03-28
- **Quality:** Excellent
- **Relevance to DAAF:** High (for regression discontinuity work)
- **Currency concern:** None --- maintained across R, Python, and Stata
- **Key content:** Unified documentation hub for the rdrobust family of packages
  providing local polynomial RD estimation, bandwidth selection (rdbwselect),
  and RD plots (rdplot). Available on CRAN (R) and PyPI (Python) with identical
  APIs and function names.
- **Strengths:** Truly parallel implementation --- same function names, same
  arguments, same output structure across R and Python. The translation is
  nearly mechanical. Academic references (Calonico, Cattaneo, Titiunik 2014,
  2015) provide rigorous methodological grounding.
- **Limitations:** Python version documentation is sparser than R's CRAN
  vignettes. Consult the R manual for detailed parameter explanations, then
  apply directly to the Python version.

### statsmodels Documentation

- **Author(s):** Josef Perktold, Skipper Seabold, Jonathan Taylor, and contributors
- **URL:** https://www.statsmodels.org/stable/
- **Type:** Documentation
- **Last verified:** 2026-03-28
- **Quality:** Good
- **Relevance to DAAF:** High
- **Currency concern:** None --- v0.14.6 stable
- **Key content:** Comprehensive statistical modeling library covering OLS, WLS,
  GLS, GLM (logit, probit, Poisson, negative binomial), mixed effects, time
  series, and hypothesis testing. Supports R-style formulas via the
  `statsmodels.formula.api` module.
- **Strengths:** The formula API (`smf.ols("y ~ x1 + x2", data=df)`) is
  intentionally modeled on R's formula interface, making translation
  straightforward. Extensive diagnostic methods (influence plots, residual
  tests, specification tests) mirror what R users expect.
- **Limitations:** Documentation can be dense and assumes familiarity with the
  library's architecture. The two-step pattern (specify model, then `.fit()`)
  differs from R's single-call approach. No built-in high-dimensional FE
  support --- use pyfixest for that.

### scikit-learn Documentation

- **Author(s):** scikit-learn developers
- **URL:** https://scikit-learn.org/stable/
- **Type:** Documentation
- **Last verified:** 2026-03-28
- **Quality:** Excellent
- **Relevance to DAAF:** Medium (prediction-focused, not inference-focused)
- **Currency concern:** None --- v1.8.0 stable
- **Key content:** Machine learning library covering classification, regression,
  clustering, dimensionality reduction, model selection, and preprocessing.
  Comprehensive user guide, API reference, and tutorials.
- **Strengths:** Best-in-class documentation for ML workflows. The consistent
  `fit()`/`predict()`/`transform()` API is easy to learn. Extensive examples
  for every estimator.
- **Limitations:** Not designed for statistical inference --- no standard errors,
  no p-values, no confidence intervals by default. R users expecting `summary()`
  output from a regression will be disappointed. For causal inference and
  hypothesis testing, use pyfixest or statsmodels instead.

---

## Textbooks with Dual-Language Code

### The Effect: An Introduction to Research Design and Causality

- **Author(s):** Nick Huntington-Klein
- **URL:** https://theeffectbook.net/
- **Type:** Book (free online)
- **Last verified:** 2026-03-28
- **Quality:** Excellent
- **Relevance to DAAF:** High
- **Currency concern:** None --- 2nd edition available; code examples in R, Stata,
  and Python
- **Key content:** Causal inference textbook covering research design, DAGs,
  matching, regression, instrumental variables, regression discontinuity,
  difference-in-differences, and event studies. All methods chapters include
  code in R, Stata, and Python using the `causaldata` package (available via
  `pip install causaldata`).
- **Strengths:** The triple-language code examples make this the best single
  resource for seeing how the same causal inference method is implemented
  across ecosystems. Conceptual explanations are exceptionally clear. Free
  online access.
- **Limitations:** Python examples tend to use pandas rather than polars.
  Translation to the DAAF polars stack requires an additional step, but the
  methodology and logic transfer directly.

### Using R, Python, and Julia for Introductory Econometrics

- **Author(s):** Florian Heiss, Daniel Brunner
- **URL:** https://www.urfie.net/
- **Type:** Book (free online)
- **Last verified:** 2026-03-28
- **Quality:** Good
- **Relevance to DAAF:** High
- **Currency concern:** Minor --- examples use standard econometrics libraries,
  which are stable
- **Key content:** Three parallel textbooks implementing Wooldridge's
  "Introductory Econometrics" examples in R, Python, and Julia respectively.
  Covers regression, time series, panel data, instrumental variables, and
  limited dependent variables. Includes Monte Carlo simulations and formula
  derivation demonstrations.
- **Strengths:** The parallel structure means every example exists in all three
  languages with identical data and expected results. Excellent for verifying
  that your Python translation of an R analysis produces the same numbers.
  Built on a widely-used econometrics textbook (Wooldridge).
- **Limitations:** Python examples use pandas and statsmodels, not polars or
  pyfixest. The books are self-published and may lag behind the latest library
  versions, though the core econometric content is timeless.

### R for Data Science (2nd Edition)

- **Author(s):** Hadley Wickham, Mine Cetinkaya-Rundel, Garrett Grolemund
- **URL:** https://r4ds.hadley.nz/
- **Type:** Book (free online)
- **Last verified:** 2026-03-28
- **Quality:** Excellent
- **Relevance to DAAF:** Medium (R-only, but essential tidyverse reference)
- **Currency concern:** None --- 2nd edition published 2023, covers modern
  tidyverse
- **Key content:** The definitive guide to the tidyverse ecosystem: data import,
  tidying, transformation (dplyr), visualization (ggplot2), and communication.
  R-only but essential for understanding the R idioms that DAAF's Python stack
  translates from.
- **Strengths:** If an R user says "I do it the R4DS way," this book defines
  what that means. Understanding dplyr patterns here maps directly to polars
  translations in the DAAF polars-tidyverse reference. Free online.
- **Limitations:** R-only. No Python code. Value is as the "source language"
  reference, not the target.

### Python for Data Analysis (3rd Edition)

- **Author(s):** Wes McKinney
- **URL:** https://wesmckinney.com/book/
- **Type:** Book (free online)
- **Last verified:** 2026-03-28
- **Quality:** Good
- **Relevance to DAAF:** Low-Medium (pandas-focused, DAAF uses polars)
- **Currency concern:** Minor --- updated for pandas 2.0 and Python 3.10, but
  DAAF's primary data manipulation library is polars
- **Key content:** Comprehensive guide to data manipulation with pandas, NumPy,
  and Jupyter. Covers data loading, cleaning, transformation, time series,
  and visualization. Written by the creator of pandas.
- **Strengths:** Authoritative pandas reference. Useful when R users encounter
  pandas code in examples, documentation, or Stack Overflow answers and need
  to understand it before translating to polars. Free HTML version available.
- **Limitations:** Entirely pandas-focused. DAAF uses polars as its primary
  data manipulation library, so this book is a secondary reference rather than
  a primary guide. R users should learn polars directly rather than going
  through pandas as an intermediate step.

### Causal Inference: The Mixtape

- **Author(s):** Scott Cunningham
- **URL:** https://mixtape.scunning.com/
- **Type:** Book (free online)
- **Last verified:** 2026-03-28
- **Quality:** Good
- **Relevance to DAAF:** Medium
- **Currency concern:** Minor --- official code is R and Stata only; Python
  translations are community-maintained
- **Key content:** Causal inference textbook covering potential outcomes,
  matching, instrumental variables, regression discontinuity,
  difference-in-differences, and synthetic control. The official book uses
  R and Stata code.
- **Strengths:** Accessible writing style with real-world examples. The
  companion Mixtape Sessions workshops (mixtapesessions.io) provide hands-on
  training with Python and Stata implementations. Community Python translations
  are available on GitHub (alexanderthclark/Causal-Inference-Mixtape).
- **Limitations:** Official book does not include Python code --- the Python
  notebooks are community-contributed and may not be fully maintained. Prefer
  "The Effect" (above) for native three-language support.

---

## General R-to-Python Guides

### Coding for Economists: Coming from R

- **Author(s):** Arthur Turrell and contributors
- **URL:** https://aeturrell.github.io/coding-for-economists/coming-from-r.html
- **Type:** Guide (chapter in free online book)
- **Last verified:** 2026-03-28
- **Quality:** Excellent
- **Relevance to DAAF:** High
- **Currency concern:** None --- actively maintained
- **Key content:** Dedicated chapter for R users transitioning to Python for
  economics work. Provides a detailed package equivalency table mapping R
  packages to Python counterparts, side-by-side code comparisons for common
  operations, and guidance on fundamental language differences (0-based
  indexing, `=` assignment, general-purpose vs statistical language).
  Recommends polars as the dplyr-like option.
- **Strengths:** Written specifically for economists, not generic data
  scientists. Covers the exact package stack relevant to DAAF (polars,
  plotnine/lets-plot, statsmodels). The broader book covers econometrics,
  causal inference, time series, and reproducibility in Python.
- **Limitations:** The broader book is opinionated toward pandas in some
  chapters, though the "Coming from R" section correctly identifies polars
  as the more dplyr-like option.

### Polars' Rgonomic Patterns

- **Author(s):** Emily Riederer
- **URL:** https://www.emilyriederer.com/post/py-rgo-polars/
- **Type:** Blog
- **Last verified:** 2026-03-28
- **Quality:** Excellent
- **Relevance to DAAF:** High
- **Currency concern:** None --- published January 2024; polars API is stable
- **Key content:** Deep analysis of how polars mirrors dplyr's ergonomic design
  patterns. Covers basic operations (select, filter, mutate, summarize),
  row-wise operations, dynamic column selectors, window functions (`over()`
  as equivalent to grouped mutate), and nested data structures.
- **Strengths:** Goes beyond surface syntax comparison to analyze *why* polars
  feels natural to R users. The emphasis on "complex transformations precisely,
  concisely, and expressively" captures what dplyr users actually value. Written
  by a well-known data science practitioner with deep R expertise.
- **Limitations:** A single blog post, not a comprehensive reference. Best used
  as conceptual orientation alongside the DAAF polars-tidyverse reference file.

### Tidyverse to Polars: My Notes

- **Author(s):** Ken Koon Wong
- **URL:** https://www.kenkoonwong.com/blog/polars/
- **Type:** Blog
- **Last verified:** 2026-03-28
- **Quality:** Good
- **Relevance to DAAF:** High
- **Currency concern:** None --- practical examples use current polars API
- **Key content:** Hands-on notes from an R user learning polars by translating
  familiar tidyverse operations. Covers filtering, selection, summarization,
  mutation, string extraction, conditional logic (case_when to when/then),
  grouping, joining, and pivoting with side-by-side R and Python code.
- **Strengths:** Written from the learner's perspective, capturing the exact
  "I tried this R pattern, here's what polars needs instead" moments that are
  most useful for transitioning users. Practical and example-driven.
- **Limitations:** Not exhaustive. Covers common operations but skips advanced
  topics like lazy evaluation, window functions, and complex joins.

### A Tidyverse R and Polars Python Side-by-Side

- **Author(s):** Robert Mitchell
- **URL:** https://robertmitchellv.com/blog/2022-07-r-python-side-by-side/r-python-side-by-side.html
- **Type:** Blog
- **Last verified:** 2026-03-28
- **Quality:** Good
- **Relevance to DAAF:** Medium
- **Currency concern:** Minor --- published 2022; polars API has evolved but core
  patterns remain valid
- **Key content:** Side-by-side demonstration of tidyverse and polars for data
  manipulation and visualization using the gapminder dataset. Covers filtering,
  aggregation, conditional logic, and interactive plotting with plotly in both
  languages.
- **Strengths:** Clear visual layout with R and Python code blocks adjacent.
  Good introduction to the "think in R, write in polars" approach.
- **Limitations:** Uses an older polars API version. Some method names may have
  changed (e.g., `groupby` to `group_by`). Cross-reference with current polars
  documentation.

### Tidy Data Manipulation: dplyr vs polars

- **Author(s):** Christoph Scheuch (Tidy Intelligence)
- **URL:** https://blog.tidy-intelligence.com/posts/dplyr-vs-polars/
- **Type:** Blog
- **Last verified:** 2026-03-28 (returned 403 on fetch; site appears intermittently restricted)
- **Quality:** Good
- **Relevance to DAAF:** High
- **Currency concern:** Minor --- verify accessibility before relying on it
- **Key content:** Systematic comparison of dplyr and polars covering mutate vs
  with_columns, filter, select, arrange vs sort, group_by/summarize vs
  group_by/agg, and pivot operations. Highlights the non-standard evaluation
  difference (dplyr uses bare column names; polars requires `pl.col()`).
- **Strengths:** Methodical function-by-function comparison. Identifies the key
  conceptual difference that dplyr allows referencing new columns in the same
  mutate block while polars does not.
- **Limitations:** Site returned 403 on some access attempts. Content may be
  behind access restrictions intermittently.

### Comparing dplyr with polars

- **Author(s):** krz (GitHub user)
- **URL:** https://krz.github.io/Comparing-dplyr-with-polars/
- **Type:** Guide
- **Last verified:** 2026-03-28
- **Quality:** Fair
- **Relevance to DAAF:** Medium
- **Currency concern:** Minor --- verify against current polars API
- **Key content:** Concise comparison of dplyr and polars operations including
  selection, filtering, mutation, summarization, and joins.
- **Strengths:** Brief and focused. Good for a quick lookup of "how do I do
  this dplyr thing in polars?"
- **Limitations:** Less detailed than the Riederer or Wong posts. Author
  background is unclear. Use as a quick-reference supplement, not a primary
  learning resource.

### Python and R for the Modern Data Scientist

- **Author(s):** Rick J. Scavetta, Boyan Angelov
- **URL:** https://www.oreilly.com/library/view/python-and-r/9781492093398/
- **Type:** Book (O'Reilly, paid)
- **Last verified:** 2026-03-28
- **Quality:** Fair
- **Relevance to DAAF:** Low
- **Currency concern:** Minor --- published 2021; predates polars adoption
- **Key content:** Guides data scientists from either the R or Python community
  toward bilingual proficiency. Covers parallel structures, where each language
  excels, and practical examples of using both together.
- **Strengths:** Well-organized, addresses the cultural differences between R
  and Python communities. Some reviewers praise its clarity and balance.
- **Limitations:** Reviews are mixed --- some find it "long on opinions and short
  on well-supported arguments." The practical substance is concentrated in the
  final chapters. Predates polars and modern pyfixest. Not free. Not
  recommended as a primary resource for DAAF users.

---

## Social Science Methodology Resources

### Nick Huntington-Klein's Econometrics Resources

- **Author(s):** Nick Huntington-Klein
- **URL:** https://nickchk.com/econometrics.html
- **Type:** Resource hub
- **Last verified:** 2026-03-28
- **Quality:** Excellent
- **Relevance to DAAF:** High
- **Currency concern:** None --- regularly updated
- **Key content:** Curated collection of econometrics learning materials including
  data manipulation tutorials (R and Python), data access packages, animated
  causal inference visualizations, video lecture series, and links to major
  econometrics textbooks. Includes an "Econometrics Navigator" and links to
  R-for-Economists video series.
- **Strengths:** Maintained by the author of "The Effect." Covers both R and
  Python (with more emphasis on R). The animated causal inference plots are
  uniquely valuable for building intuition. Comprehensive data access package
  list (wbstats, tidycensus, fredr, ipumsr, etc.).
- **Limitations:** Python coverage is less extensive than R. Best used alongside
  "The Effect" textbook for methodology, with DAAF skill files for Python
  implementation specifics.

### Tidy Fixed Effects Regressions: fixest vs pyfixest

- **Author(s):** Christoph Scheuch (Tidy Intelligence)
- **URL:** https://blog.tidy-intelligence.com/posts/fixed-effects-regressions/
- **Type:** Blog
- **Last verified:** 2026-03-28 (site returned 403 on some attempts)
- **Quality:** Good
- **Relevance to DAAF:** High
- **Currency concern:** Minor --- verify accessibility
- **Key content:** Direct side-by-side comparison of R fixest and Python pyfixest
  for fixed effects regression, covering model specification, standard errors,
  and output formatting.
- **Strengths:** Practical, focused comparison of the exact R-to-Python
  translation that DAAF users need most for econometric work.
- **Limitations:** Site access may be intermittent (403 errors observed).

### Mixtape Sessions

- **Author(s):** Scott Cunningham and guest instructors
- **URL:** https://www.mixtapesessions.io/sessions/
- **Type:** Course / Workshop
- **Last verified:** 2026-03-28
- **Quality:** Excellent
- **Relevance to DAAF:** Medium
- **Currency concern:** None --- workshops run regularly with updated materials
- **Key content:** Multi-day workshops teaching causal inference methods with
  hands-on coding in Python and Stata. The flagship Causal Inference I and II
  courses cover potential outcomes, matching, IV, RD, DiD, and synthetic control.
  Materials are publicly available on GitHub (Mixtape-Sessions organization).
- **Strengths:** Taught by leading applied econometricians. Workshop format
  provides structured learning with real-world exercises. Python implementations
  are actively maintained. Materials are open-access after the workshop.
- **Limitations:** Paid workshops (materials free afterward). Python code uses
  pandas, not polars. Focus is on methodology, not data manipulation workflow.

### Coding for Economists (Full Book)

- **Author(s):** Arthur Turrell and contributors
- **URL:** https://aeturrell.github.io/coding-for-economists/intro.html
- **Type:** Book (free online)
- **Last verified:** 2026-03-28
- **Quality:** Excellent
- **Relevance to DAAF:** High
- **Currency concern:** None
- **Key content:** Comprehensive Python guide for economists covering programming
  basics, data handling, visualization, econometrics (OLS, IV, causal inference),
  time series, machine learning, text analysis, geospatial analysis, and
  reproducible research. Designed to take economists from zero coding experience
  to productive Python users.
- **Strengths:** The most complete single resource for economists learning Python.
  Covers the full research workflow, not just data manipulation. Includes
  chapters on reproducibility and software engineering practices that align with
  DAAF's philosophy.
- **Limitations:** Some chapters lean toward pandas over polars. The econometrics
  coverage is introductory --- for advanced methods, use DAAF's pyfixest and
  statsmodels skill files.

---

## R Package Documentation (for Reference)

These are the authoritative R package documentation sites. R users should know
these as the "source" for the patterns that DAAF's Python stack translates.

### dplyr (tidyverse)

- **URL:** https://dplyr.tidyverse.org/
- **Type:** R package documentation
- **Last verified:** 2026-03-28
- **DAAF Python equivalent:** polars (`pl.col()`, `.filter()`, `.with_columns()`,
  `.group_by().agg()`, `.join()`, `.sort()`)
- **Key mapping:** `mutate()` to `with_columns()`, `filter()` to `filter()`,
  `select()` to `select()`, `arrange()` to `sort()`, `group_by() %>% summarize()`
  to `group_by().agg()`, `left_join()` to `join(how="left")`

### ggplot2 (tidyverse)

- **URL:** https://ggplot2.tidyverse.org/
- **Type:** R package documentation
- **Last verified:** 2026-03-28
- **DAAF Python equivalent:** plotnine (near-identical syntax)
- **Key mapping:** Syntax is almost 1:1. Main differences: Python requires
  parentheses around the full plot expression, imports from `plotnine` instead
  of loading `library(ggplot2)`, and uses `=` instead of `<-` for assignment.

### fixest

- **URL:** https://lrberge.github.io/fixest/
- **Type:** R package documentation
- **Last verified:** 2026-03-28
- **DAAF Python equivalent:** pyfixest (intentionally parallel API)
- **Key mapping:** `feols()` to `pf.feols()`, `fepois()` to `pf.fepois()`,
  `etable()` to `pf.etable()`, `coefplot()` to `pf.coefplot()`. Formula syntax
  is identical: `Y ~ X1 + X2 | fe1 + fe2`. Note: `feglm()` with FE is not yet
  supported in pyfixest.

### survey

- **URL:** https://cran.r-project.org/package=survey
- **Homepage:** http://r-survey.r-forge.r-project.org/survey/
- **Type:** R package documentation
- **Last verified:** 2026-03-28
- **DAAF Python equivalent:** svy (see DAAF svy skill)
- **Key mapping:** No single Python package replicates the full survey package.
  DAAF's svy skill documents the multi-library approach needed for design-based
  inference in Python.

### sf (r-spatial)

- **URL:** https://r-spatial.github.io/sf/
- **Type:** R package documentation
- **Last verified:** 2026-03-28
- **DAAF Python equivalent:** geopandas
- **Key mapping:** `st_read()` to `gpd.read_file()`, `st_join()` to
  `gpd.sjoin()`, `st_transform()` to `gdf.to_crs()`, `st_buffer()` to
  `gdf.buffer()`. Both libraries build on GDAL/GEOS/PROJ. See the DAAF
  geopandas skill for detailed translation patterns.
