# External Resources for Stata-to-Python Translation

Curated catalog of resources for Stata users transitioning to Python in
quantitative social science contexts. Each entry is self-contained with
provenance tracking, quality assessment, and key takeaways so that the
resource's value can be judged without visiting the link.

Resources are assessed for currency, accuracy, and relevance to the DAAF stack
(polars, pyfixest, statsmodels, linearmodels, plotnine, svy, geopandas). Entries
marked with currency concerns should be cross-checked against current
documentation.

## Contents

- [Package-Specific Documentation](#package-specific-documentation)
- [Textbooks with Dual-Language Code](#textbooks-with-dual-language-code)
- [General Stata-to-Python Guides](#general-stata-to-python-guides)
- [Social Science Methodology Resources](#social-science-methodology-resources)
- [Community Resources](#community-resources)
- [Stata Official Documentation (for Reference)](#stata-official-documentation-for-reference)

---

## Package-Specific Documentation

### pyfixest Documentation

- **Author(s):** Alexander Fischer, Styfen Schaer, and contributors
- **URL:** https://pyfixest.org/
- **Type:** Documentation
- **Last verified:** 2026-03-28
- **Quality:** Excellent
- **Currency concern:** None -- actively maintained, aligned with fixest/reghdfe
- **Key content:** Python implementation of R's fixest, which itself was inspired
  by Stata's reghdfe. Supports OLS, WLS, IV, Poisson, and GLMs with multi-way
  high-dimensional fixed effects. Formula syntax: `Y ~ X1 + X2 | fe1 + fe2` for
  FE absorption, `Y ~ X1 | fe1 | endo ~ instrument` for IV. Inference: iid,
  HC1-3, CRV1/CRV3 clustering, wild bootstrap, randomization inference. Includes
  DiD estimators: TWFE, did2s, lpdid, Sun-Abraham. The quickstart page explicitly
  references both Stata reghdfe syntax and R fixest syntax for comparison.
- **Relevance to DAAF:** High -- primary regression package in the DAAF stack.
  The formula syntax deliberately mirrors reghdfe conventions, making it the most
  natural bridge for Stata users. `etable()` replaces `esttab`/`outreg2`.
- **Strengths:** Near-identical formula syntax to Stata's reghdfe; includes
  multiple estimation shortcuts (`sw()`, `csw()`, `split`); publication-quality
  tables via `etable()` with LaTeX, markdown, and HTML output.
- **Limitations:** `feglm()` does not yet support fixed effects absorption (the
  single largest feature gap vs Stata). Some fixest R features not yet ported.
  See the DAAF pyfixest skill's gotchas.md for the full gap list.

### statsmodels Documentation

- **Author(s):** Josef Perktold, Skipper Seabold, Jonathan Taylor, and contributors
- **URL:** https://www.statsmodels.org/stable/
- **Type:** Documentation
- **Last verified:** 2026-03-28
- **Quality:** Good
- **Currency concern:** None -- v0.14.6 stable
- **Key content:** Comprehensive statistical modeling library covering OLS, WLS,
  GLS, GLM (logit, probit, Poisson, negative binomial), discrete choice models
  (ordered logit/probit, multinomial logit), time series, mixed effects, and
  hypothesis testing. For Stata users: the formula API
  (`smf.ols("y ~ x1 + x2", data=df)`) is intentionally modeled on R/Stata
  formula syntax. Important gotcha: statsmodels does NOT include an intercept by
  default (must use `sm.add_constant()` or the formula API with `smf`).
- **Relevance to DAAF:** High -- core dependency for models beyond pyfixest's
  scope, especially GLMs, discrete choice, time series, and mixed effects.
- **Strengths:** Formula API makes translation from Stata straightforward.
  Extensive diagnostic methods (influence plots, residual tests, specification
  tests) mirror what Stata users expect from post-estimation.
- **Limitations:** Documentation can be dense. The two-step pattern (specify
  model, then `.fit()`) differs from Stata's single-call approach. No built-in
  high-dimensional FE support -- use pyfixest for that.

### marginaleffects: Model to Meaning

- **Author(s):** Vincent Arel-Bundock, Noah Greifer, Andrew Heiss
- **URL:** https://marginaleffects.com/
- **Type:** Documentation / Book
- **Last verified:** 2026-03-28
- **Quality:** Excellent
- **Currency concern:** None -- actively maintained with bilingual R/Python support
- **Key content:** Unified interface for post-estimation analysis, directly
  corresponding to Stata's `margins` command. Core functions: `predictions()`,
  `comparisons()` (contrasts, risk ratios, odds), `slopes()` (marginal effects),
  `hypotheses()` (test, lincom, nlcom equivalents). Every documentation page has
  an R/Python toggle showing equivalent code. Published in the Journal of
  Statistical Software (v111, i09). Explicitly validated against Stata output.
- **Relevance to DAAF:** High -- Stata's `margins` command is one of the most
  heavily used post-estimation tools. This package is the direct Python
  equivalent, covering `margins`, `marginsplot`, `lincom`, and `nlcom`.
- **Strengths:** The bilingual R/Python toggle is the gold standard for
  cross-language translation. Covers causal inference, experiments, categorical
  outcomes, and ML interpretation. Author royalties support charity.
- **Limitations:** Described by the author as alpha for the Python version.
  Python API coverage lags slightly behind R. Verify critical results against
  Stata for published research.

### plotnine Documentation

- **Author(s):** Hassan Kibirige
- **URL:** https://plotnine.org/
- **Type:** Documentation
- **Last verified:** 2026-03-28
- **Quality:** Good
- **Currency concern:** None -- v0.15.3 as of verification date
- **Key content:** Python implementation of the grammar of graphics with syntax
  mirroring R's ggplot2. For Stata users, this represents a paradigm shift from
  Stata's imperative `graph twoway` syntax to a declarative, layered approach.
  Covers geoms, aesthetics, scales, facets, coordinates, and themes.
- **Relevance to DAAF:** High -- DAAF's primary static visualization library.
  Stata users should read this alongside the skill's visualization.md reference,
  which provides direct Stata-to-plotnine command mappings.
- **Strengths:** Comprehensive geom coverage; grammar-of-graphics composability
  exceeds Stata's graph system in flexibility. Plot composition operators
  (`|`, `/`) available in v0.15+.
- **Limitations:** Requires pandas DataFrames (convert from polars). Some R
  ggplot2 extensions (e.g., `ggrepel`) have no plotnine equivalent. Stata users
  unfamiliar with the grammar of graphics face a learning curve.

### svy: Complex Survey Analysis in Python

- **Author(s):** svy development team
- **URL:** https://svylab.com/docs/svy/
- **Type:** Documentation
- **Last verified:** 2026-03-28
- **Quality:** Excellent
- **Currency concern:** None -- actively maintained; supersedes samplics
- **Key content:** Python equivalent of Stata's `svy:` command prefix. Design
  specification via `svy.Design(stratum=..., psu=..., wgt=...)`, directly
  paralleling Stata's `svyset`. Supports Taylor linearization, BRR, jackknife,
  and bootstrap variance estimation. Estimation: means, totals, proportions,
  ratios, medians, and regression models. Validated to be numerically equivalent
  to R's survey package.
- **Relevance to DAAF:** High -- primary complex survey analysis library. Direct
  mapping to Stata's `svyset` and `svy:` prefix commands makes it the natural
  translation path for Stata users working with NHANES, DHS, BRFSS, ACS, and
  similar survey data.
- **Strengths:** Design-based inference with proper variance estimation. API
  conceptually parallels Stata's svy workflow.
- **Limitations:** Narrower model family coverage than Stata's `svy:` (no ordinal
  logistic, Cox survival, negative binomial). For unsupported models, use the
  rpy2 bridge to R's survey package.

### Polars: Coming from Pandas

- **Author(s):** Polars contributors
- **URL:** https://docs.pola.rs/user-guide/migration/pandas/
- **Type:** Documentation
- **Last verified:** 2026-03-28
- **Quality:** Excellent
- **Currency concern:** None -- maintained as part of official polars docs
- **Key content:** Official migration guide covering the seven fundamental
  conceptual differences between pandas and polars: no index, Arrow memory
  format, parallelism, multiple engines, lazy evaluation, strict typing, and
  expression-based API. Useful for Stata users because most external
  Stata-to-Python resources target pandas, not polars -- this guide helps
  translate from the pandas code you find online to the polars code DAAF expects.
- **Relevance to DAAF:** Medium -- pandas-to-polars, not Stata-to-polars
  directly. Valuable as a secondary translation step when Stata users find pandas
  examples online and need to convert to polars.
- **Strengths:** Authoritative, emphasizes avoiding pandas-style patterns.
- **Limitations:** Assumes pandas familiarity, not Stata. Stata users should use
  the DAAF skill's data-management.md reference first.

### rdrobust: RD Packages

- **Author(s):** Sebastian Calonico, Matias Cattaneo, Rocio Titiunik, and others
- **URL:** https://rdpackages.github.io/rdrobust/
- **Type:** Documentation
- **Last verified:** 2026-03-28
- **Quality:** Excellent
- **Currency concern:** None -- maintained across R, Python, and Stata
- **Key content:** Unified documentation hub for the rdrobust family providing
  local polynomial RD estimation, bandwidth selection (rdbwselect), and RD plots
  (rdplot). Available on SSC (Stata), CRAN (R), and PyPI (Python) with identical
  APIs and function names. Academic references (Calonico, Cattaneo, Titiunik
  2014, 2015) provide rigorous methodological grounding.
- **Relevance to DAAF:** High -- same function names, same arguments, same output
  across all three languages. The Stata-to-Python translation is mechanical.
- **Strengths:** Truly parallel implementation across Stata, R, and Python.
  Actively maintained by the original methodological authors.
- **Limitations:** Python documentation is sparser than Stata's manual entries.
  Consult the Stata help file for detailed parameter explanations, then apply
  directly to the Python version.

### binsreg: Binscatter Regressions

- **Author(s):** Matias D. Cattaneo, Richard K. Crump, Max H. Farrell, Yingjie Feng
- **URL:** https://nppackages.github.io/binsreg/
- **Type:** Documentation
- **Last verified:** 2026-03-28
- **Quality:** Excellent
- **Currency concern:** None -- maintained across Stata, R, and Python
- **Key content:** Identical methodology in all three languages. Includes
  `binsreg` (least squares binscatter), `binslogit`/`binsprobit` (nonlinear),
  `binstest` (hypothesis testing), `binspwc` (pairwise comparison), and
  `binsregselect` (bin selection). Directly replaces Stata's older `binscatter`
  command with improved methodology and inference.
- **Relevance to DAAF:** High -- binscatter is a standard visualization in
  applied economics. Identical API across Stata and Python means near-zero
  translation friction.
- **Strengths:** Same authors, same methodology, same API across all languages.
  Proper inference (confidence intervals, hypothesis testing) unlike the original
  `binscatter` Stata command.
- **Limitations:** Does not directly support `absorb()` for fixed effects in the
  Python version. Residualize manually using pyfixest before passing to binsreg.

---

## Textbooks with Dual-Language Code

### The Effect: An Introduction to Research Design and Causality

- **Author(s):** Nick Huntington-Klein
- **URL:** https://theeffectbook.net/
- **Type:** Book (free online)
- **Last verified:** 2026-03-28
- **Quality:** Excellent
- **Currency concern:** None -- 2nd edition available; code in R, Stata, and Python
- **Key content:** Causal inference textbook covering research design, DAGs,
  matching, regression, instrumental variables, regression discontinuity,
  difference-in-differences, and event studies. All methods chapters include code
  in R, Stata, and Python using the `causaldata` package (available via
  `pip install causaldata`). 60+ video lectures accompany the text.
- **Relevance to DAAF:** High -- the trilingual code examples are the gold
  standard for seeing how the same causal inference method is implemented across
  ecosystems. Stata users can look up any method and see the Python equivalent
  side-by-side.
- **Strengths:** Free online. Triple-language code. Exceptionally clear
  conceptual explanations. The `causaldata` package enables hands-on practice.
- **Limitations:** Python examples use pandas rather than polars. Translation to
  the DAAF polars stack requires an additional step, but the methodology and
  logic transfer directly.

### Causal Inference: The Mixtape

- **Author(s):** Scott Cunningham
- **URL:** https://mixtape.scunning.com/
- **Type:** Book (free online)
- **Last verified:** 2026-03-28
- **Quality:** Excellent
- **Currency concern:** Minor -- official code is R and Stata only; Python
  translations are community-maintained
- **Key content:** Causal inference textbook covering potential outcomes, matching,
  instrumental variables, regression discontinuity, difference-in-differences, and
  synthetic control. The official book uses R and Stata code. Community-contributed
  Python Jupyter notebooks replicate all examples
  (https://github.com/alexanderthclark/Causal-Inference-Mixtape).
- **Relevance to DAAF:** High -- alongside The Effect, one of the two most popular
  causal inference textbooks in economics. The Stata code in the book maps
  directly to Python equivalents documented in the DAAF skill.
- **Strengths:** Accessible writing with real-world examples. The `causaldata`
  package provides datasets in Python. Companion Mixtape Sessions workshops
  (mixtapesessions.io) offer Python implementations.
- **Limitations:** Official book does not include Python code. Community
  translations may not be fully maintained. Prefer "The Effect" for native
  three-language support.

### Data Analysis for Business, Economics, and Policy

- **Author(s):** Gabor Bekes and Gabor Kezdi
- **URL:** https://gabors-data-analysis.com/
- **Type:** Textbook (code freely available)
- **Last verified:** 2026-03-28
- **Quality:** Excellent
- **Currency concern:** Low -- published 2021 by Cambridge University Press; code
  repository actively maintained
- **Key content:** Comprehensive data analysis textbook with all code freely
  available in R, Stata, and Python via GitHub
  (github.com/gabors-data-analysis/da_case_studies). Covers data exploration,
  regression analysis, predictive analytics (cross-validation, tree-based ML),
  and causal analysis. Each case study has parallel implementations in all three
  languages.
- **Relevance to DAAF:** High -- the three-language parallel code is ideal for
  building Stata-to-Python translation intuition. Case studies drawn from
  real-world economics and policy contexts.
- **Strengths:** 47 case studies with parallel R/Stata/Python code. Teaching
  guide available. Published by a major academic press.
- **Limitations:** Python examples use pandas and statsmodels, not polars or
  pyfixest. Print edition required for text; code is free on GitHub.

### Using R, Python, and Julia for Introductory Econometrics

- **Author(s):** Florian Heiss, Daniel Brunner
- **URL:** https://www.urfie.net/
- **Type:** Book (free PDF available)
- **Last verified:** 2026-03-28
- **Quality:** Good
- **Currency concern:** Minor -- examples use standard econometrics libraries
- **Key content:** Companion to Wooldridge's *Introductory Econometrics* (the most
  widely assigned Stata-based econometrics textbook). Chapters mirror Wooldridge's
  structure covering regression, inference, heteroskedasticity, time series, panel
  data, IV/2SLS, and limited dependent variables. Available in R, Python, and
  Julia versions.
- **Relevance to DAAF:** High -- since Wooldridge is the canonical Stata-based
  econometrics textbook, this companion directly bridges every Wooldridge example
  to Python. Invaluable for graduate students making the transition.
- **Strengths:** Every example exists in multiple languages with identical data and
  expected results. Perfect for verifying that a Python translation produces the
  same numbers as the Stata original. Free PDF version available.
- **Limitations:** Python examples use pandas and statsmodels, not polars or
  pyfixest. May lag behind latest library versions.

### Causal Inference for the Brave and True

- **Author(s):** Matheus Facure
- **URL:** https://matheusfacure.github.io/python-causality-handbook/
- **Type:** Online handbook / textbook (Python-only)
- **Last verified:** 2026-03-28
- **Quality:** Excellent
- **Currency concern:** Low -- actively maintained
- **Key content:** Python-focused causal inference resource covering RCTs, linear
  regression, propensity score matching, DiD (including modern heterogeneous
  treatment effects methods), synthetic control, and synthetic DiD. Particularly
  strong chapter on "The Difference-in-Differences Saga" covering
  Callaway-Sant'Anna, Sun-Abraham, and imputation approaches.
- **Relevance to DAAF:** Medium -- Python-only (no Stata code), but excellent for
  Stata users who need to understand how familiar causal inference methods are
  implemented in Python. Free online and also published by O'Reilly.
- **Strengths:** Modern methods coverage (heterogeneous DiD) surpasses most
  textbooks. Clear Python implementations. Free online version.
- **Limitations:** No Stata code for direct comparison. Uses pandas.

### Tidy Finance with Python

- **Author(s):** Christoph Scheuch, Stefan Voigt, Patrick Weiss
- **URL:** https://www.tidy-finance.org/python/
- **Type:** Online textbook
- **Last verified:** 2026-03-28
- **Quality:** Excellent
- **Currency concern:** Low -- uses pyfixest, actively maintained
- **Key content:** Finance-focused Python textbook with chapters on fixed effects,
  clustered standard errors, difference-in-differences, and asset pricing.
  Demonstrates pyfixest alongside pandas. The fixed effects chapter explicitly
  shows the equivalence between Stata's `areg`/`reghdfe` and pyfixest's `feols()`.
- **Relevance to DAAF:** Medium -- finance focus limits direct applicability to
  social science, but econometric techniques (FE, clustering, DiD) are identical.
- **Strengths:** Uses pyfixest (same as DAAF). Clear practical examples.
- **Limitations:** Finance-specific examples and datasets.

---

## General Stata-to-Python Guides

### Daniel M. Sullivan: Stata to Python Equivalents

- **Author(s):** Daniel M. Sullivan
- **URL:** https://www.danielmsullivan.com/pages/tutorial_stata_to_python.html
- **Type:** Guide / Reference
- **Last verified:** 2026-03-28
- **Quality:** Excellent
- **Currency concern:** Moderate -- references `econtools` for regression (now
  dated; pyfixest is the modern equivalent); pandas API stable but some methods
  deprecated. Core data manipulation mappings remain accurate.
- **Key content:** The single most comprehensive Stata-to-Python command mapping
  online. Covers 13 sections: Input/Output, Sample Selection, Data Info, Variable
  Manipulation, Bysort, Panel Data, Merging and Joining, Reshape, Econometrics,
  Plotting, and Other Differences. Maps 80+ Stata commands to pandas equivalents.
  Includes critical notes on missing value behavior and composability differences.
- **Relevance to DAAF:** High -- directly maps the Stata commands social scientists
  use daily. While it targets pandas (not polars), the conceptual mappings are
  foundational and the Stata command inventory ensures complete coverage.
- **Strengths:** Most comprehensive single-page Stata-to-Python reference. Covers
  edge cases and behavioral differences that other guides miss. Free.
- **Limitations:** Uses pandas exclusively (DAAF uses polars). The econtools
  regression package is outdated -- use pyfixest instead.

### Coding for Economists: Coming from Stata

- **Author(s):** Arthur Turrell and contributors
- **URL:** https://aeturrell.github.io/coding-for-economists/coming-from-stata.html
- **Type:** Guide (chapter in free online book)
- **Last verified:** 2026-03-28
- **Quality:** Excellent
- **Currency concern:** None -- actively maintained
- **Key content:** Dedicated chapter for Stata users transitioning to Python for
  economics work. Detailed package equivalency table mapping Stata packages to
  Python counterparts. Side-by-side code comparisons for common operations.
  Supplementary regression reference table covering fixed effects, categorical
  variables, interaction terms, robust/clustered standard errors, and IV.
  Recommends polars as the dplyr-like option.
- **Relevance to DAAF:** High -- uses the same Python stack as DAAF (pyfixest,
  statsmodels, binsreg, plotnine). The broader book covers the full Python data
  analysis workflow.
- **Strengths:** Written for economists, not generic data scientists. Covers the
  exact package stack relevant to DAAF. Actively maintained.
- **Limitations:** The broader book leans toward pandas in some chapters, though
  the "Coming from Stata" section correctly identifies polars as dplyr-like.

### pandas Official Documentation: Comparison with Stata

- **Author(s):** pandas development team
- **URL:** https://pandas.pydata.org/docs/getting_started/comparison/comparison_with_stata.html
- **Type:** Official documentation
- **Last verified:** 2026-03-28
- **Quality:** Excellent
- **Currency concern:** None -- updated with each pandas release
- **Key content:** Official pandas page mapping Stata concepts across 8 sections:
  Data Structures, I/O, Data Operations, String Processing, Merging, Missing Data,
  GroupBy, and Other Considerations. Detailed examples for `collapse`/`groupby`,
  `egen`/`transform`, `merge`/`pd.merge()`. Documents zero-based indexing,
  copies vs. in-place operations, and NaN vs. dot missing values.
- **Relevance to DAAF:** High -- authoritative source for core data manipulation
  mappings. While DAAF uses polars, the conceptual mappings are foundational.
- **Strengths:** Authoritative, comprehensive, well-maintained. The standard
  reference that most Stata-to-Python guides build upon.
- **Limitations:** pandas-only (DAAF uses polars). Stata users should use this
  for conceptual understanding, then translate to polars using the DAAF skill.

### UC Berkeley Econ 148: Python for Economists

- **Author(s):** Rohan Jha
- **URL:** https://www.econ148.org/textbook/content/01-python_v_stata/index.html
- **Type:** University course textbook
- **Last verified:** 2026-03-28
- **Quality:** Good
- **Currency concern:** Low -- copyright 2024
- **Key content:** UC Berkeley course textbook with a dedicated "Python vs Stata"
  section covering pedagogy, language history, summary of differences, and syntax
  translation. Emphasizes that economists spend ~1/3 of their time getting and
  cleaning data, motivating Python's data engineering capabilities.
- **Relevance to DAAF:** Medium -- useful for high-level conceptual framing and
  motivational context, though less detailed than Sullivan or Turrell for specific
  command mappings.
- **Strengths:** Academic context. Modern (2024). Good motivational framing.
- **Limitations:** Less detailed command mappings than Sullivan or Turrell.

### QuantEcon Statistics Cheatsheet

- **Author(s):** Thomas J. Sargent, John Stachurski, and contributors
- **URL:** https://cheatsheets.quantecon.org/stats-cheatsheet.html
- **Type:** Cheat sheet / Quick reference
- **Last verified:** 2026-03-28
- **Quality:** Good
- **Currency concern:** Low -- core operations are stable
- **Key content:** Three-column crosswalk (Stata, Pandas, Base R) covering ~29
  statistical operations organized into Basics, Filtering, Summarizing, Reshaping,
  Merging, and Plotting.
- **Relevance to DAAF:** Medium -- useful as a quick-reference companion but too
  abbreviated for in-depth translation. Good for quick lookups.
- **Strengths:** Clean three-language side-by-side format. Quick to scan.
- **Limitations:** Too abbreviated for learning. Covers only common operations.

### Adam Ross Nelson: StataQuickReference Crosswalk

- **Author(s):** Adam Ross Nelson
- **URL:** https://github.com/adamrossnelson/StataQuickReference/blob/master/spcrosswlk.md
- **Type:** GitHub repository / Reference document
- **Last verified:** 2026-03-28
- **Quality:** Good
- **Currency concern:** Moderate -- repository activity unclear; core API stable
- **Key content:** Comprehensive crosswalk covering 7 sections: Starting Out,
  Categorical/Factor Variables, Merge, Append, Reshape, Loops, and Exporting.
  Includes notes on unicode handling and data type conversion for .dta files.
  The loop translation section (`foreach`/`forvalues` to Python `for`) is useful.
- **Relevance to DAAF:** Medium -- pandas-focused, but the Stata command inventory
  helps ensure complete coverage.
- **Strengths:** Covers loop patterns and .dta export details often missing from
  other guides. Community-contributed.
- **Limitations:** pandas-only. Repository maintenance status unclear.

---

## Social Science Methodology Resources

### Nick Huntington-Klein's Econometrics Resources

- **Author(s):** Nick Huntington-Klein
- **URL:** https://nickchk.com/econometrics.html
- **Type:** Resource hub
- **Last verified:** 2026-03-28
- **Quality:** Excellent
- **Currency concern:** None -- regularly updated
- **Key content:** Curated collection of econometrics learning materials including
  data manipulation tutorials, data access packages, animated causal inference
  visualizations, video lecture series, and links to major econometrics textbooks.
  Includes the "Econometrics Navigator" and R-for-Economists video series.
- **Relevance to DAAF:** High -- maintained by the author of "The Effect." Covers
  both R and Python. The animated causal inference plots are uniquely valuable for
  building intuition about identification strategies.
- **Strengths:** Comprehensive link collection. Animated visualizations.
  Regularly updated by a leading econometrics educator.
- **Limitations:** Python coverage less extensive than R/Stata. Best used alongside
  "The Effect" for methodology with DAAF skill files for implementation.

### LOST: Library of Statistical Techniques

- **Author(s):** Nick Huntington-Klein and community contributors
- **URL:** https://lost-stats.github.io/
- **Type:** Community wiki / Rosetta Stone
- **Last verified:** 2026-03-28
- **Quality:** Good
- **Currency concern:** Moderate -- community-maintained; some pages may be dated
- **Key content:** Rosetta Stone for statistical software. Each page covers one
  statistical technique with implementations in multiple languages (Python, R,
  Stata, SAS, and more). Seven categories: Data Manipulation, Geo-Spatial,
  Machine Learning, Model Estimation, Presentation, Time Series, and Other.
- **Relevance to DAAF:** High -- the multi-language format makes this the best
  "look up any technique in Stata, see the Python equivalent" resource. Covers
  OLS, matching, logit/probit, multilevel models, DiD, RDD, event studies.
- **Strengths:** Multi-language implementations for each technique. Community-
  editable. Covers modern causal inference methods.
- **Limitations:** Community-maintained -- quality varies by page. Some pages may
  use outdated package versions.

### Mixtape Sessions

- **Author(s):** Scott Cunningham and guest instructors
- **URL:** https://www.mixtapesessions.io/sessions/
- **Type:** Course / Workshop
- **Last verified:** 2026-03-28
- **Quality:** Excellent
- **Currency concern:** None -- workshops run regularly with updated materials
- **Key content:** Multi-day workshops teaching causal inference methods with
  hands-on coding in Python and Stata. Flagship courses cover potential outcomes,
  matching, IV, RD, DiD, and synthetic control. Materials publicly available on
  GitHub (Mixtape-Sessions organization).
- **Relevance to DAAF:** Medium -- taught by leading applied econometricians.
  Python implementations use pyfixest and modern packages. Materials are
  open-access after workshops.
- **Strengths:** Expert instruction. Practical exercises. Python materials
  actively maintained. Open-access after the workshop.
- **Limitations:** Paid workshops (materials free afterward). Python code uses
  pandas, not polars.

### Coding for Economists (Full Book)

- **Author(s):** Arthur Turrell and contributors
- **URL:** https://aeturrell.github.io/coding-for-economists/intro.html
- **Type:** Book (free online)
- **Last verified:** 2026-03-28
- **Quality:** Excellent
- **Currency concern:** None -- actively maintained
- **Key content:** Comprehensive Python guide for economists covering programming
  basics, data handling, visualization (plotnine chapter), econometrics (OLS, IV,
  causal inference), time series, machine learning, text analysis, geospatial
  analysis, and reproducible research. Designed to take economists from zero
  Python to productive users.
- **Relevance to DAAF:** High -- the most complete single resource for economists
  learning Python. Includes chapters on reproducibility and software engineering
  that align with DAAF's philosophy. The "Coming from Stata" and "Coming from R"
  chapters serve as entry points for transitioning users.
- **Strengths:** Comprehensive. Free. Economics-focused. Includes chapters on
  every domain relevant to DAAF (data, viz, econometrics, ML, spatial, text).
- **Limitations:** Some chapters lean toward pandas. Econometrics coverage is
  introductory -- use DAAF skill files for advanced methods.

---

## Community Resources

### Chuck Huber's Stata/Python Integration Blog Series

- **Author(s):** Chuck Huber (Director of Statistical Outreach, StataCorp)
- **URL:** https://blog.stata.com/author/chuber/
- **Type:** Blog series (8 parts)
- **Last verified:** 2026-03-28
- **Quality:** Good
- **Currency concern:** Moderate -- written 2020; core concepts valid but Stata
  17-19 may have evolved some APIs
- **Key content:** Official 8-part series on using Python within Stata (introduced
  in Stata 16). Covers: installation/setup, three ways to call Python from Stata,
  installing packages, using packages, 3D surface plots, API/JSON data access,
  and the Stata Function Interface (SFI) for data exchange.
- **Relevance to DAAF:** Medium -- focused on Python-WITHIN-Stata rather than
  Python-INSTEAD-OF-Stata. Useful for understanding how Stata officially positions
  Python integration, and for users maintaining a hybrid workflow during
  transition.
- **Strengths:** Written by StataCorp staff. Authoritative on Stata's Python
  integration capabilities.
- **Limitations:** Covers Stata 16's Python integration, not standalone Python.
  Most DAAF users will work in pure Python, not Stata+Python.

### UCLA OARC: Stata Resources

- **Author(s):** UCLA Office of Advanced Research Computing
- **URL:** https://stats.oarc.ucla.edu/stata/
- **Type:** University resource hub
- **Last verified:** 2026-03-28
- **Quality:** Excellent
- **Currency concern:** Low -- regularly maintained
- **Key content:** Comprehensive Stata learning resource featuring FAQs, learning
  modules, annotated output for many statistical procedures, textbook examples,
  and web books. Extensive coverage of logistic regression, multilevel models,
  ordinal outcomes, and more with step-by-step Stata implementations.
- **Relevance to DAAF:** Medium -- understanding how UCLA OARC teaches Stata helps
  identify common workflows that need Python translation. The annotated output
  sections are useful for understanding what Stata users expect in output.
- **Strengths:** Comprehensive. Well-organized by statistical method. Annotated
  output shows exactly what Stata produces.
- **Limitations:** Stata-only. No Python equivalents provided.

### German Rodriguez: Princeton Stata Tutorial

- **Author(s):** German Rodriguez (Princeton University)
- **URL:** https://grodri.github.io/stata/
- **Type:** Tutorial
- **Last verified:** 2026-03-28
- **Quality:** Excellent
- **Currency concern:** Low -- updated for Stata 18
- **Key content:** Widely cited introductory Stata tutorial covering data
  management, graphics, tables, and programming. Recommended by stata.com as a
  primary learning resource.
- **Relevance to DAAF:** Medium -- not a translation resource per se, but
  understanding the standard Stata tutorial path helps frame the skill to meet
  users where they are. Every concept covered here has a Python equivalent in the
  DAAF skill.
- **Strengths:** Clear, concise, authoritative. Recommended by StataCorp.
- **Limitations:** Stata-only. Tutorial format, not a translation reference.

### Oscar Torres-Reyna: Princeton Panel Data Tutorial

- **Author(s):** Oscar Torres-Reyna (Princeton University)
- **URL:** https://www.princeton.edu/~otorres/Panel101.pdf
- **Type:** Tutorial / PDF
- **Last verified:** 2026-03-28
- **Quality:** Good
- **Currency concern:** Moderate -- older tutorial, but panel data fundamentals
  unchanged
- **Key content:** Classic tutorial on panel data analysis with Stata. Covers
  `xtreg` with fixed and random effects, Hausman test, and practical
  implementation. Widely used in economics graduate programs.
- **Relevance to DAAF:** Medium -- the skill should map every command in this
  tutorial to its Python equivalent (pyfixest for FE, linearmodels for RE).
  Understanding this tutorial helps anticipate what Stata users know and expect.
- **Strengths:** The standard panel data reference for Stata users. Concise,
  practical.
- **Limitations:** Stata-only. Panel data fundamentals are stable but the
  tutorial predates modern DiD methods.

---

## Stata Official Documentation (for Reference)

These are Stata's own documentation resources. They serve as the "source" for the
patterns that DAAF's Python stack translates from.

### Stata Documentation Overview

- **URL:** https://www.stata.com/features/documentation/
- **Type:** Official documentation hub
- **Last verified:** 2026-03-28
- **Key content:** Stata 18 documentation consists of over 19,000 pages organized
  by command. Core manuals cover data management, graphics, functions, and
  reporting. 18+ subject-specific statistics manuals cover every domain from
  Bayesian analysis to survival models. Each entry follows a consistent format:
  syntax, options, examples, stored results, and methods/formulas.
- **Why this matters for translation:** Stata's documentation is organized around
  COMMANDS (one entry per command), not tasks or workflows. Stata users think in
  terms of specific commands (`reghdfe`, `xtreg`, `margins`) and need Python
  equivalents for those exact commands. The DAAF skill is organized to support
  this lookup pattern.

### Stata Graph Overview (Visual Reference)

- **URL:** https://www.stata.com/support/faqs/graphics/gph/stata-graphs/
- **Type:** Visual reference
- **Last verified:** 2026-03-28
- **Key content:** 100+ categorized graph examples showing Stata's graph system
  capabilities. Organized by plot type (scatter, line, bar, box, etc.) with
  the Stata code that produced each graph.
- **Why this matters for translation:** When a Stata user shows you a graph and
  asks "how do I make this in Python," this visual reference identifies the Stata
  command that produced it. Then the DAAF skill's visualization.md provides the
  plotnine equivalent.

### Resources for Learning Stata

- **URL:** https://www.stata.com/links/resources-for-learning-stata/
- **Type:** Curated link collection
- **Last verified:** 2026-03-28
- **Key content:** StataCorp's curated collection of learning resources: 350+
  video tutorials, NetCourses, Stata Blog, Statalist forum (60,000+ users), Stata
  Journal, and links to university tutorials.
- **Why this matters for translation:** Understanding which resources Stata users
  learned from helps predict which commands and workflows they consider standard.
  The DAAF skill prioritizes translating the commands taught in these resources.

---

> **Sources:** All resources listed above were accessed and verified on
> 2026-03-28. Quality and currency assessments are based on examination of the
> resource content, publication date, maintenance activity, and relevance to the
> DAAF Python stack. This catalog was compiled from systematic research documented
> in `/daaf/research/2026-03-28_Stata_Python_Translation_Research.md`.
