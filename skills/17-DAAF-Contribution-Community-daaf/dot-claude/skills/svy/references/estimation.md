# svy Estimation Reference

svy v0.13.0 — syntax and library guidance only.

---

## Contents

1. [Prerequisites: Design and Sample Setup](#prerequisites-design-and-sample-setup)
2. [Population Means](#population-means)
3. [Population Totals](#population-totals)
4. [Proportions](#proportions)
5. [Ratios](#ratios)
6. [Medians and Quantiles](#medians-and-quantiles)
7. [Domain / Subpopulation Estimation](#domain--subpopulation-estimation)
8. [Cross-Tabulations](#cross-tabulations)
9. [Hypothesis Testing (Survey-Weighted t-Tests)](#hypothesis-testing-survey-weighted-t-tests)
10. [Design Effects (DEFF)](#design-effects-deff)
11. [Working with Polars DataFrames](#working-with-polars-dataframes)
12. [Common Patterns and Pitfalls](#common-patterns-and-pitfalls)

---

## Prerequisites: Design and Sample Setup

All estimation requires a `svy.Sample` object combining data with a design specification. See `design-weights.md` for full design setup. Brief recap:

```python
import svy

# --- Taylor linearization design (most common) ---
design = svy.Design(stratum="sdmvstra", psu="sdmvpsu", wgt="wtmec2yr")
sample = svy.Sample(data=data, design=design)
```

For replicate weight designs, see `design-weights.md`. Once the `Sample` is created, estimation methods are identical regardless of the variance estimation method — the design object determines how SEs are computed.

---

## Population Means

### Basic Mean

```python
# Population mean of BMI with design-based SE
result = sample.estimation.mean("bmxbmi")
print(result)
```

The result includes: point estimate, standard error (SE), 95% confidence interval, and design effect (DEFF).

### Multiple Variables

```python
# Call mean() once per variable — no multi-variable shorthand
result_income = sample.estimation.mean("income")
result_age = sample.estimation.mean("age")
```

### Handling Missing Data

```python
# Drop nulls (default behavior)
result = sample.estimation.mean("bmxbmi", drop_nulls=True)
```

svy uses Polars null handling. Rows with null values in the analysis variable are excluded from the estimate by default. The effective sample size after dropping nulls is reported.

**Critical:** Dropping nulls changes the effective domain of estimation. If missingness is non-random (which it usually is in surveys), acknowledge this limitation in your analysis. Document it with an `# ASSUMES:` comment in research scripts.

---

## Population Totals

### Basic Total

```python
# Estimated population total
result = sample.estimation.total("income")
print(result)
```

Totals estimate the sum of a variable across the entire target population, not just the sample. The SE reflects the uncertainty of this population-level estimate.

### When to Use Totals vs. Means

- **Totals** for aggregate quantities: total enrollment, total expenditure, total population count
- **Means** for per-unit averages: mean income, mean BMI, mean test score
- **Proportions** for binary/categorical shares: percent employed, percent below poverty

---

## Proportions

### Basic Proportion

```python
# Proportion of a binary or categorical variable
result = sample.estimation.prop("employed")
print(result)
```

The variable should contain categorical or binary values. svy computes the proportion in each category with design-based SEs.

### Multi-Category Proportions

```python
# Proportions across all categories of a variable
result = sample.estimation.prop("education_level")
```

This returns the estimated population proportion for each level of the variable (e.g., "High School": 0.28, "College": 0.35, "Graduate": 0.12, etc.) with SEs and CIs for each.

---

## Ratios

### Basic Ratio

```python
# Ratio estimation: y is numerator, x is denominator
result = sample.estimation.ratio(y="total_expenditure", x="household_size")
print(result)
```

Ratio estimation is used when the quantity of interest is a ratio of two survey variables (e.g., per-capita expenditure = total expenditure / household size). The SE accounts for the covariance between numerator and denominator.

### Ratio vs. Mean of a Derived Variable

**Do not** compute `expenditure / household_size` as a new column and then estimate its mean. This gives incorrect SEs because it ignores the covariance structure. Use `estimation.ratio()` for proper variance estimation of ratios.

```python
# WRONG: pre-computing the ratio then estimating the mean
# data = data.with_columns((pl.col("expenditure") / pl.col("hh_size")).alias("per_capita"))
# sample.estimation.mean("per_capita")  # <-- incorrect SEs

# CORRECT: use ratio estimation
sample.estimation.ratio(y="expenditure", x="hh_size")  # <-- correct SEs
```

---

## Medians and Quantiles

### Median

```python
# Population median with design-based SE
result = sample.estimation.median("income")
print(result)
```

Median estimation for survey data uses weighted quantile computation with linearization-based or replicate-weight-based variance estimation. SEs for medians are typically larger than for means.

---

## Domain / Subpopulation Estimation

### The `by` Parameter

Domain estimation computes statistics for subgroups of the population while preserving the full survey design structure.

```python
# Mean BMI by gender
result = sample.estimation.mean("bmxbmi", by="riagendr")
print(result)
```

```python
# Mean income by education level
result = sample.estimation.mean("income", by="education")
```

```python
# Proportions by region
result = sample.estimation.prop("employed", by="region")
```

### Why Not Pre-Filter?

**Never pre-filter the data for domain estimation.** Pre-filtering removes observations needed for correct variance estimation.

```python
# WRONG: filtering before estimation
# females_only = data.filter(pl.col("gender") == "Female")
# female_sample = svy.Sample(data=females_only, design=design)
# female_sample.estimation.mean("income")  # <-- WRONG SEs

# CORRECT: use domain estimation
sample.estimation.mean("income", by="gender")  # <-- correct SEs for each gender
```

Pre-filtering discards PSUs and strata from the design, which can:
1. Produce incorrect variance estimates (too small or too large)
2. Create singleton PSU problems (strata with only one PSU after filtering)
3. Change the degrees of freedom for inference

The `by` parameter handles domain estimation correctly by keeping the full design structure and computing conditional estimates.

### Multiple Grouping Variables

```python
# Multiple grouping variables passed as a tuple
result = sample.estimation.mean("income", by=("gender", "education"))
```

---

## Cross-Tabulations

### Survey-Weighted Contingency Tables

```python
# Cross-tabulation via prop() with by=
result = sample.estimation.prop("employment_status", by="education_level")
```

This produces a survey-weighted cross-tabulation showing the estimated population proportion in each cell, with design-based SEs. Equivalent to R's `svytable()` or `svyby(~var, ~by_var, design, svymean)`.

For a full contingency table with chi-square test, use the `categorical.tabulate()` method:

```python
# Formal cross-tabulation with test statistics
table = sample.categorical.tabulate(rowvar="employment_status", colvar="education_level")
```

---

## Hypothesis Testing (Survey-Weighted t-Tests)

### Comparing Domain Means

```python
# Domain means via the by= parameter
result = sample.estimation.mean("income", by="gender")

# Formal two-group t-test via the categorical accessor
ttest_result = sample.categorical.ttest(y="income", group="gender")
print(ttest_result)
```

For formal hypothesis testing of differences between domains, svy computes design-adjusted t-statistics that account for the complex sampling structure via `sample.categorical.ttest()`. The `group` parameter specifies the binary grouping variable. The degrees of freedom are based on the number of PSUs minus the number of strata (not the sample size), which can substantially affect p-values for small numbers of clusters.

### Key Difference from Unweighted Tests

Standard t-tests assume simple random sampling with known, equal variance. Survey-weighted tests:
- Use the survey weights in the point estimate
- Use the design-based variance (accounting for stratification and clustering)
- Use design-based degrees of freedom (typically much smaller than n - 1)
- Produce wider confidence intervals when there is substantial clustering

---

## Design Effects (DEFF)

The design effect (DEFF) measures how much the variance of an estimate is inflated (or deflated) by the complex design compared to a simple random sample of the same size.

```
DEFF = Var_complex / Var_SRS
```

- **DEFF = 1.0**: The complex design is as efficient as SRS
- **DEFF > 1.0**: The complex design increases variance (common with clustered designs)
- **DEFF < 1.0**: The complex design decreases variance (common with stratified designs)
- **Typical range**: 1.5 to 5.0 for clustered household surveys

DEFF values are included in svy estimation output. Report them alongside estimates — they communicate how much the survey design affects precision.

### Effective Sample Size

The effective sample size is:

```
n_eff = n / DEFF
```

A survey of 10,000 respondents with DEFF = 4.0 has the statistical precision of an SRS of only 2,500. Always consider the effective sample size when evaluating whether a survey has adequate power for a particular analysis.

---

## Working with Polars DataFrames

svy uses Polars DataFrames natively. Data loaded via `svy.io` methods returns Polars DataFrames. If you have data in other formats:

### From Parquet (Common in DAAF Pipelines)

```python
import polars as pl
import svy

# Load data as Polars DataFrame
data = pl.read_parquet("data/raw/nhanes_demo.parquet")

# Proceed with design specification
design = svy.Design(stratum="sdmvstra", psu="sdmvpsu", wgt="wtmec2yr")
sample = svy.Sample(data=data, design=design)
```

### From Pandas

```python
import pandas as pd
import polars as pl
import svy

# Convert pandas to Polars
pd_data = pd.read_csv("survey_data.csv")
data = pl.from_pandas(pd_data)

# Proceed with svy
design = svy.Design(stratum="stratum", psu="psu", wgt="weight")
sample = svy.Sample(data=data, design=design)
```

### Data Wrangling Within svy

svy includes a wrangling module for common survey data preparation tasks. These operate on the Sample object directly, preserving the design linkage.

```python
from svy import CaseStyle, LetterCase

# Clean column names
sample = sample.wrangling.clean_names(
    case_style=CaseStyle.SNAKE,
    letter_case=LetterCase.LOWER
)

# Recode categorical variables
sample = sample.wrangling.recode(
    "education",
    {"High School": ["HS", "high_school"],
     "College": ["BA", "BS", "college"]}
)

# Bin continuous variables into categories
sample = sample.wrangling.categorize(
    "age",
    bins=[0, 18, 35, 65, 100],
    labels=["0-17", "18-34", "35-64", "65+"]
)

# Cap extreme values (winsorize)
sample = sample.wrangling.bottom_and_top_code(
    {"income": (0, 200000)}
)

# Create derived variables
from svy.core.expr import col
sample = sample.wrangling.mutate({
    "income_thousands": col("income") / 1000,
    "age_squared": col("age") ** 2
})
```

**Note:** For complex data preparation (joins, reshaping, filtering), use the polars skill directly, then pass the prepared Polars DataFrame to `svy.Sample`. The wrangling module is for convenience on simple transformations.

---

## Common Patterns and Pitfalls

### Pattern: Complete Estimation Workflow

```python
import svy
import polars as pl

# --- Config ---
DATA_PATH = "data/raw/nhanes_demo.parquet"

# --- Load ---
data = pl.read_parquet(DATA_PATH)

# --- Design ---
# INTENT: NHANES uses a complex multi-stage stratified cluster design
# REASONING: sdmvstra = pseudo-strata, sdmvpsu = pseudo-PSU, wtmec2yr = 2-year MEC exam weight
# ASSUMES: Analysis population is the MEC-examined subsample
design = svy.Design(stratum="sdmvstra", psu="sdmvpsu", wgt="wtmec2yr")
sample = svy.Sample(data=data, design=design)

# --- Estimate ---
mean_bmi = sample.estimation.mean("bmxbmi")
print(mean_bmi)

mean_bmi_by_gender = sample.estimation.mean("bmxbmi", by="riagendr")
print(mean_bmi_by_gender)

prop_obese = sample.estimation.prop("obese_flag")
print(prop_obese)

# --- Validate ---
print(f"Sample size: {data.shape[0]}")
assert data.shape[0] > 0, "No data loaded"
```

### Pitfall: Using Unweighted Statistics

Never use `pl.col("var").mean()` or pandas `.mean()` on survey data. Unweighted statistics are biased for the target population and do not have correct standard errors.

### Pitfall: Ignoring Weight Variable Selection

Surveys often provide multiple weight variables for different analysis populations (e.g., NHANES has `wtint2yr` for interview data and `wtmec2yr` for examination data). Using the wrong weight produces biased estimates. Always consult the survey documentation to select the appropriate weight.

### Pitfall: Treating Survey SEs as Cluster-Robust SEs

Survey-weighted SEs and cluster-robust SEs (e.g., from pyfixest or statsmodels with `cov_type="cluster"`) are **not the same thing**:
- Survey SEs account for stratification, clustering, **and** unequal probability of selection
- Cluster-robust SEs only account for within-cluster correlation
- Survey SEs use design-based degrees of freedom; cluster-robust SEs use large-sample approximations

Use svy when you have a complex survey with known design variables. Use cluster-robust SEs when you have non-survey data with clustered observations.
