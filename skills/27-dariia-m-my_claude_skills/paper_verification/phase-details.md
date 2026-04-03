# Phase Details Reference

Detailed procedures for each verification phase. The SKILL.md gives the overview;
this file has the step-by-step instructions for tricky parts.

## Table of Contents
- Section 2: Table Audit Procedure
- Section 4: Code Review Procedure
- Section 5: Manifest Construction
- Section 6: Replication Script Construction

---

## Section 2: Table Audit Procedure

### Step 2.1: Parse LaTeX Tables

LaTeX tables come in many formats. Here is how to handle the common ones:

**Standard tabular environments:**
Look for `\begin{table}` ... `\end{table}` blocks. Inside, find the `tabular` or `tabular*`
environment. Parse rows by splitting on `\\` and columns by splitting on `&`.

**Stargazer output:**
Stargazer produces `.tex` files with a specific structure. The coefficient rows alternate
with standard error rows (in parentheses). The bottom section contains N, R-squared, and
other diagnostics. Key pattern:
```
variable_name & coeff1 & coeff2 & coeff3 \\
              & (se1)  & (se2)  & (se3)  \\
```

**modelsummary output:**
Similar structure but may use `\multicolumn`, `\midrule`, and different formatting.
Pay attention to the `gof_map` argument which controls which goodness-of-fit statistics
appear.

**kableExtra / huxtable:**
These produce more varied output. Look at the raw `.tex` or `.html` file rather than
trying to parse the R code that generates them.

**Manual tables (not auto-generated):**
These are the highest-risk tables. If a table was created by hand (typing numbers into
LaTeX directly), it is the most likely to contain transcription errors. Flag these
prominently.

### Step 2.2: Extract Numbers Systematically

For each table, create a structured extraction:
```
Table X: [title]
  Row 1, Col 1: value (type: coefficient)
  Row 1, Col 1 SE: value (type: standard_error)
  Row 1, Col 2: value (type: coefficient)
  ...
  Footer: N = value (type: sample_size)
  Footer: R-squared = value (type: r_squared)
```

### Step 2.3: Match to R Output

For auto-generated tables, the matching is straightforward - compare the `.tex` file
included in the paper to the `.tex` file in the results directory. Check for:
- Exact match (ideal)
- Date/version differences (the paper might include an older version)
- Manual edits (the paper version might have hand-edited labels or formatting)

For manually constructed tables, you need to find the model object or summary output
that produced the numbers. Look for:
- `summary(model)` output in log files
- `coef()`, `confint()`, `nobs()` calls
- `.rds` files containing saved model objects (load them and extract)

### Step 2.4: Tolerance Rules

| Value Type        | Tolerance                                           |
|-------------------|-----------------------------------------------------|
| Coefficients      | Must match to displayed decimal places after rounding |
| Standard errors   | Must match to displayed decimal places after rounding |
| t/z-statistics    | Recompute from coef/SE, allow ±0.01                  |
| p-values          | Allow ±0.001, or verify significance star is correct |
| N (sample size)   | Must match exactly                                   |
| R-squared         | Must match to displayed decimal places               |
| F-statistic       | Allow ±0.01                                          |
| Percentages       | Recompute from raw counts, allow ±0.1pp              |
| Means/medians     | Must match to displayed decimal places               |

### Step 2.5: Cross-Table Consistency

After checking individual tables, verify consistency across tables:
- If Tables 1 and 3 use the same sample, N must match
- If Table 2 is a subsample of Table 1, N(Table 2) < N(Table 1)
- Summary statistics in Table 1 should be consistent with regression samples
- If the same variable appears in multiple tables, its coefficient should differ only
  if the specification changed (different controls, different sample, etc.)

---

## Section 4: Code Review Procedure

### Step 4.1: Establish Execution Order

Find the master script (often called `main.R`, `run_all.R`, `master.R`, or `_run.R`).
If none exists, infer execution order from:
- File numbering (01_clean.R, 02_merge.R, 03_analysis.R)
- File dependencies (which scripts load outputs from other scripts?)
- README instructions

### Step 4.2: Data Pipeline Walk-Through

For each script, in order, trace the data:

```
Script: 01_clean_data.R
  Input:  data/raw_survey.csv (N = 15,234 rows, 45 cols)
  Step 1: filter(!is.na(income))     -> N = 14,891 (lost 343, 2.3%)
  Step 2: filter(age >= 18)          -> N = 14,502 (lost 389, 2.6%)
  Step 3: mutate(log_income = ...)   -> N = 14,502 (same, new col added)
  Step 4: left_join(geo_data)        -> N = 14,502 (check: no duplication?)
  Output: data/clean_survey.rds      -> N = 14,502 rows, 47 cols
```

At every transformation, verify:
1. **Observation count**: How many rows before and after? Is the loss reasonable?
2. **Column existence**: Do all columns needed by downstream scripts exist?
3. **Summary stats**: For key variables, are mean/min/max/NA-count sensible?

### Step 4.3: Merge Audit

Merges are the #1 source of silent data corruption. For every merge/join:

- What type? (`left_join`, `inner_join`, `merge`, etc.)
- What are the key columns?
- Is the merge 1:1, 1:m, m:1, or m:m?
- Are there duplicate keys in either dataset? (This causes row multiplication)
- How many rows match vs. don't match?
- Are unmatched rows dropped or kept as NA?

If the code uses `merge()` without specifying `all`, `all.x`, or `all.y`, flag it -
the default behavior might not be what the author intended.

### Step 4.4: Regression Specification Audit

For each regression model, verify:

**Variables:**
- Dependent variable matches paper description
- Independent variables match paper description
- Control variables are all present
- Fixed effects are correctly specified (if using `feols`, check the FE formula;
  if using `lm` with dummies, check that the right dummies are included)

**Standard errors:**
- Clustering level matches the paper
- If the paper says "robust standard errors", check for `vcov = "HC1"` or equivalent
- If using `feols`, check the `vcov` argument
- If using `coeftest` or `sandwich`, verify the specification

**Sample:**
- The data subset used for this regression matches what the paper describes
- Any sample restrictions (e.g., "excluding outliers", "balanced panel only") are
  correctly implemented

**Instrumental variables:**
- First-stage specification matches the paper
- Instruments are correctly specified
- Check for weak instrument diagnostics (F-stat > 10 or similar)

### Step 4.5: Red Flag Patterns

Watch for these specific patterns:

**Hardcoded magic numbers:**
```r
# BAD: What is 2005? Why this cutoff?
df <- df %>% filter(year > 2005)

# BETTER: Named and documented
treatment_start_year <- 2005  # Policy enacted in 2005
df <- df %>% filter(year > treatment_start_year)
```

**Silent NA handling:**
```r
# This silently drops NAs - is that intentional?
model <- lm(y ~ x, data = df)
# How many observations were dropped due to NAs?
```

**Overwritten objects:**
```r
df <- read_csv("data.csv")
df <- df %>% filter(...)
df <- df %>% mutate(...)
# If something goes wrong, you can't recover the original df
```

**Suppressed warnings:**
```r
suppressWarnings(...)  # What is being suppressed and why?
options(warn = -1)     # Globally turning off warnings is a red flag
```

**Commented-out alternatives:**
```r
# model <- lm(y ~ x + z, data = df)           # Was this tried first?
# model <- lm(y ~ x + z + w, data = df)       # And this?
model <- lm(y ~ x + z + w + v, data = df)     # And this is the "winner"?
```

---

## Section 5: Manifest Construction

### Systematic Claim Extraction

Go through the paper linearly (abstract through appendix) and extract claims in order.
Use a consistent ID scheme:

- `ABS_1`, `ABS_2`: Abstract claims
- `T1_R2_C3`: Table 1, Row 2, Column 3
- `T1_N`: Table 1 sample size
- `T1_R2`: Table 1 R-squared
- `F3_POINT_2`: Figure 3, data point 2
- `BODY_S4_P2_S3`: Section 4, Paragraph 2, Sentence 3
- `FN_12`: Footnote 12
- `APP_T_A1_R1_C2`: Appendix Table A1, Row 1, Column 2

### Linking Claims to Code

For each claim, trace the full chain:
```
Paper claim -> Table/Figure -> Output file -> R script -> Data source
```

Every link in the chain must be verified. If any link is broken (e.g., you cannot find
which script produces a particular output file), mark the claim as UNVERIFIED and
document what is missing.

---

## Section 6: Replication Script Construction

### Script Architecture

The replication script should be structured as:

```r
# tests/verify_replication.R
# Automated replication verification
# Generated by academic-paper-verify skill

library(jsonlite)
library(testthat)

# --- Configuration ---
manifest <- fromJSON("verification_manifest.json")
tolerance_default <- 1e-3
results <- list()

# --- Helper functions ---
check_value <- function(claim_id, actual, expected, tol = tolerance_default) { ... }
extract_coef <- function(model, var_name) { ... }
extract_se <- function(model, var_name) { ... }
extract_nobs <- function(model) { ... }

# --- Run scripts in order ---
# Each block: source the script, extract values, compare to manifest

# Block 1: Table 1
source("code/02_main_regression.R")
# ... extract and check ...

# Block 2: Table 2
# ... etc ...

# --- Report ---
report <- generate_report(results)
writeLines(report, "tests/replication_summary.md")
write_json(results, "tests/replication_results.json")
```

### Handling Script Dependencies

Many academic R projects are not designed to be re-run cleanly. Common issues:
- Scripts that assume objects are already in the global environment
- Scripts that use `setwd()` or relative paths that break
- Scripts that read data from absolute paths
- Missing packages

The replication script should handle these gracefully:
- Wrap each source() call in tryCatch
- Check for required objects before proceeding
- Report missing dependencies clearly
- Do not let one failure block the rest of the checks

### Tolerance Strategy

Not all values need the same tolerance:
- Values that should be deterministic (same data, same code): tight tolerance (1e-10)
- Values that involve floating-point differences across platforms: moderate (1e-6)
- Values displayed in tables with limited decimal places: match to display precision
- Values involving bootstrapping or simulation: may not match at all without same seed
