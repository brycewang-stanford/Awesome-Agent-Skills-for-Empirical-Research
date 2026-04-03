---
name: svy
description: >-
  Complex survey analysis: strata/PSU/weights, variance estimation (Taylor, BRR, jackknife, bootstrap), survey GLM, domain analysis, calibration. Polars-native. Use for NHANES, CPS, ACS PUMS, BRFSS, DHS. Non-survey regression: statsmodels/pyfixest.
metadata:
  audience: research-coders
  domain: python-library
  library-version: "0.13.0"
  skill-last-updated: "2026-03-28"
---

# svy Skill

svy: design-based analysis of complex survey data in Python. Covers survey design specification (strata, PSU, weights, FPC), variance estimation (Taylor linearization, BRR, jackknife, bootstrap), descriptive estimation (means, totals, proportions, ratios, medians), survey-weighted GLM regression (gaussian, binomial, Poisson), domain/subpopulation analysis, calibration, and survey data I/O (SAS, SPSS, Stata). Uses Polars DataFrames natively. Use when analyzing data from complex sample surveys (NHANES, CPS, ACS PUMS, MEPS, ECLS-K, BRFSS, DHS). For non-survey regression, use statsmodels; for fixed effects, use pyfixest; for panel/IV models, use linearmodels.

Comprehensive skill for complex survey data analysis with svy. Use decision trees below to find the right guidance, then load detailed references.

## What is svy?

svy is the Python package for **design-based analysis of complex survey data**:
- **Survey-aware estimation**: Means, totals, proportions, ratios, medians with proper design-based standard errors
- **GLM regression**: Survey-weighted linear, logistic, and Poisson regression with design-adjusted inference
- **Flexible variance estimation**: Taylor linearization (default), bootstrap, BRR (including Fay's modification), and jackknife (JK1, JKn) replicate methods
- **Domain estimation**: Correct subpopulation analysis without pre-filtering (preserves design structure)
- **Native Polars**: Built on Polars DataFrames, not pandas
- **Survey data I/O**: Read SAS (.sas7bdat), SPSS (.sav), Stata (.dta), and CSV with metadata
- **Calibration**: Post-stratification, raking, and GREG calibration for weight adjustment
- **Validated**: Results numerically equivalent to R's survey package across all methods

## Version Notes

This skill targets **svy 0.13.0** (released 2026-03-25). svy supersedes **samplics** (archived 2026-03-10), an earlier library by the same author (Mamadou S. Diallo, Ph.D.). Key differences from samplics:
- Unified `Sample` object replaces separate `TaylorEstimator` / `ReplicateEstimator` classes
- Polars-native (samplics used numpy arrays)
- Expanded GLM support and data I/O module (`svy.io`)
- The API is substantially different from samplics — do not assume samplics patterns carry over

## How to Use This Skill

### Reference File Structure

| File | Purpose | When to Read |
|------|---------|--------------|
| `estimation.md` | Means, totals, proportions, ratios, medians, domain estimation, cross-tabs, hypothesis tests | Descriptive survey statistics |
| `regression.md` | Survey-weighted OLS, logistic, Poisson regression; extracting results; diagnostics | Survey regression models |
| `design-weights.md` | Design specification, replicate weights, weight manipulation, variance setup, survey data I/O, federal survey patterns | Setting up the survey design object |

### Reading Order

1. **New to svy?** Start with `design-weights.md` then `estimation.md`
2. **Need survey-weighted regression?** Read `design-weights.md` then `regression.md`
3. **Have replicate weights already?** Read `design-weights.md` (replicate design section) then `estimation.md` or `regression.md`
4. **Setting up a federal survey (NHANES, CPS, etc.)?** Read `design-weights.md` (federal survey patterns table)
5. **Coming from samplics?** Read `design-weights.md` for the new API; the `Sample` object replaces `TaylorEstimator`/`ReplicateEstimator`

## Related Skills

| Skill | Relationship |
|-------|-------------|
| `data-scientist` | Provides methodology guidance (especially `survey-analysis.md`); svy provides implementation. Load data-scientist for "when and why" to use survey methods |
| `statsmodels` | Complement for non-survey regression (OLS, GLM, time series, diagnostics). **WLS in statsmodels is NOT survey-weighted regression** — it does not account for stratification or clustering |
| `pyfixest` | Complement for fixed effects models and DiD. pyfixest does not handle complex survey designs; use svy for survey-weighted estimation, pyfixest for FE/DiD |
| `linearmodels` | Complement for panel models (RE, FD, Fama-MacBeth) and IV/GMM. Does not handle survey designs |
| `polars` | svy uses Polars DataFrames natively. Load polars skill for data preparation before passing to svy |

## Quick Decision Trees

### "I need to analyze survey data"

```
What task?
├─ Descriptive statistics (mean, total, proportion)
│   └─ ./references/estimation.md
├─ Regression model
│   ├─ Linear (continuous outcome) → ./references/regression.md
│   ├─ Logistic (binary outcome) → ./references/regression.md
│   └─ Poisson (count outcome) → ./references/regression.md
├─ Set up the survey design object
│   └─ ./references/design-weights.md
├─ Read survey data from SAS/SPSS/Stata
│   └─ ./references/design-weights.md
├─ Subpopulation / domain analysis
│   └─ ./references/estimation.md
└─ Cross-tabulation
    └─ ./references/estimation.md
```

### "I need survey-weighted regression"

```
What model?
├─ Linear regression (continuous Y)
│   └─ family="gaussian" → ./references/regression.md
├─ Logistic regression (binary Y)
│   └─ family="binomial" → ./references/regression.md
├─ Poisson regression (count Y)
│   └─ family="poisson" → ./references/regression.md
├─ Ordinal logistic / Cox survival / IV
│   └─ Not in svy — use rpy2 + R survey package (see rpy2 bridge below)
└─ Fixed effects + survey weights
    └─ Not directly supported — see Boundaries below
```

### "I need to set up variance estimation"

```
What do you have?
├─ Design variables (strata, PSU, weights)
│   └─ Taylor linearization → ./references/design-weights.md
├─ Pre-computed replicate weights
│   ├─ BRR weights → ./references/design-weights.md
│   ├─ Jackknife weights → ./references/design-weights.md
│   └─ Bootstrap weights → ./references/design-weights.md
├─ Need to create replicate weights from design
│   └─ ./references/design-weights.md
└─ Not sure what I have
    └─ Read survey documentation first → ./references/design-weights.md (federal survey table)
```

### "I need descriptive statistics from a survey"

```
What statistic?
├─ Population mean → ./references/estimation.md
├─ Population total → ./references/estimation.md
├─ Proportion → ./references/estimation.md
├─ Ratio (Y/X) → ./references/estimation.md
├─ Median / quantile → ./references/estimation.md
├─ Cross-tabulation → ./references/estimation.md
├─ By subgroup (domain estimation) → ./references/estimation.md
└─ Hypothesis test (t-test) → ./references/estimation.md
```

## Boundaries

**svy covers:**
- Design-based estimation (descriptive and regression) for complex surveys
- Taylor and replicate-weight variance estimation
- Domain/subpopulation analysis
- Calibration and weight adjustment
- Survey data I/O

**svy does NOT cover (use other tools):**
- Fixed effects models — use pyfixest (survey weights + FE is methodologically complex; consult data-scientist skill)
- Panel data models (RE, FD, between) — use linearmodels
- Difference-in-differences — use pyfixest
- Causal inference methods (IV, RD, synthetic control) — use pyfixest/linearmodels/statsmodels
- Time series analysis — use statsmodels
- Machine learning — use scikit-learn
- Ordinal logistic, Cox proportional hazards, negative binomial — use rpy2 + R survey package
- Survey sampling design and sample size calculation — use data-scientist skill for methodology

## The rpy2 Bridge

For models svy does not support (ordinal logistic, survival models, negative binomial GLM, cumulative link models), fall back to R's `survey` package via rpy2:

**Decision rule:** If the model family is not `"gaussian"`, `"binomial"`, or `"poisson"`, use rpy2.

The R survey package (`survey::svyglm`, `survey::svyolr`, `survey::svycoxph`) covers the full range of survey-weighted models. Set up the survey design in R using the same design variables you would pass to `svy.Design`. See R survey package documentation at `r-survey.r-forge.r-project.org` for API details.

## Legacy: samplics

samplics (2020-2026) is archived. svy supersedes it with a cleaner API, Polars integration, and expanded methods. If working with legacy code that uses samplics:
- The API is **substantially different** — `TaylorEstimator`/`ReplicateEstimator` classes are replaced by `svy.Sample`
- samplics used numpy arrays; svy uses Polars DataFrames
- Consult samplics documentation at `samplics-org.github.io/samplics/` for legacy reference
- Migration requires rewriting, not find-and-replace

## File-First Execution in Research Workflows

**Important:** In data research pipelines (see `CLAUDE.md`), svy analyses are executed through **script files**, not interactively. This ensures auditability and reproducibility.

**The pattern:**
1. Write estimation/regression code to `scripts/stage8_analysis/{step}_{task-name}.py`
2. Execute via Bash with automatic output capture wrapper script
3. Validation results get automatically embedded in scripts as comments
4. If failed, create versioned copy for fixes

Closely read `agent_reference/SCRIPT_EXECUTION_REFERENCE.md` for the mandatory file-first execution protocol. All survey analysis scripts must follow the Inline Audit Trail (IAT) standard — document design specification choices (why these strata/PSU/weights, what variance method, domain definitions) with `# INTENT:`, `# REASONING:`, and `# ASSUMES:` comments.

---

## Quick Reference

### Essential Import

```python
import svy
```

### Core Workflow

```python
# 1. Load data
data = svy.io.read_stata("nhanes.dta")

# 2. Specify design
design = svy.Design(stratum="sdmvstra", psu="sdmvpsu", wgt="wtmec2yr")

# 3. Create sample object
sample = svy.Sample(data=data, design=design)

# 4. Estimate
mean_bmi = sample.estimation.mean("bmxbmi")
model = sample.glm.fit(y="bmxbmi", x=["ridageyr", svy.Cat("riagendr")], family="gaussian")
```

### Core Operations

| Operation | Code |
|-----------|------|
| Design (Taylor) | `svy.Design(stratum="s", psu="p", wgt="w")` |
| Sample object | `svy.Sample(data=df, design=design)` |
| Mean | `sample.estimation.mean("var")` |
| Total | `sample.estimation.total("var")` |
| Proportion | `sample.estimation.prop("var")` |
| Ratio | `sample.estimation.ratio(y="num", x="denom")` |
| Median | `sample.estimation.median("var")` |
| Domain estimation | `sample.estimation.mean("var", by="group")` |
| Linear regression | `sample.glm.fit(y="y", x=[...], family="gaussian")` |
| Logistic regression | `sample.glm.fit(y="y", x=[...], family="binomial")` |
| Poisson regression | `sample.glm.fit(y="y", x=[...], family="poisson")` |
| Categorical predictor | `svy.Cat("varname")` |
| Read Stata | `svy.io.read_stata("file.dta")` |
| Read SAS | `svy.io.read_sas("file.sas7bdat")` |
| Read SPSS | `svy.io.read_spss("file.sav")` |

## Topic Index

| Topic | Reference File |
|-------|---------------|
| Survey design setup | `./references/design-weights.md` |
| Taylor linearization | `./references/design-weights.md` |
| Replicate weights (BRR, jackknife, bootstrap) | `./references/design-weights.md` |
| Fay's BRR modification | `./references/design-weights.md` |
| Weight types and handling | `./references/design-weights.md` |
| Federal survey design patterns | `./references/design-weights.md` |
| Singleton PSU handling | `./references/design-weights.md` |
| Calibration and post-stratification | `./references/design-weights.md` |
| Reading SAS/SPSS/Stata files | `./references/design-weights.md` |
| Population means | `./references/estimation.md` |
| Population totals | `./references/estimation.md` |
| Proportions | `./references/estimation.md` |
| Ratios | `./references/estimation.md` |
| Medians and quantiles | `./references/estimation.md` |
| Domain / subpopulation estimation | `./references/estimation.md` |
| Cross-tabulations | `./references/estimation.md` |
| Survey-weighted t-tests | `./references/estimation.md` |
| Design effects (DEFF) | `./references/estimation.md` |
| Survey-weighted OLS | `./references/regression.md` |
| Survey-weighted logistic regression | `./references/regression.md` |
| Survey-weighted Poisson regression | `./references/regression.md` |
| Extracting regression results | `./references/regression.md` |
| Survey regression vs. WLS vs. cluster-robust | `./references/regression.md` |
| Categorical predictors (svy.Cat) | `./references/regression.md` |
| Model diagnostics in survey context | `./references/regression.md` |
| rpy2 bridge to R survey package | `./references/regression.md` |
| samplics migration | `./references/design-weights.md` |
| Polars DataFrame integration | `./references/design-weights.md` |

## Citation

When this library is used as a primary analytical tool, include in the report's
Software & Tools references:

> Diallo, M.S. svy: Python package for complex survey sampling and analysis [Computer software]. (Formerly samplics.)

**Cite when:** svy is used for survey-weighted estimation with complex survey designs (strata, PSU, replicate weights).
**Do not cite when:** Only imported but no survey estimation performed.

For method-specific citations (e.g., variance estimation techniques),
consult the reference files in this skill and `agent_reference/CITATION_REFERENCE.md`.
