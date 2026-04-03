# Common Pitfalls in Academic Paper Verification

Known failure modes organized by category. Check for all of these during verification.

## Table of Contents
- Numerical Discrepancies
- Data Pipeline Issues
- Econometric / Modeling Issues
- LaTeX and Formatting Issues
- Replicability Issues

---

## Numerical Discrepancies

### 1. Rounding chain errors
The R output shows 0.03468. The author rounds to 0.035. Then in the text they write
"approximately 3.5 percentage points." Each rounding step is individually defensible,
but the chain can introduce drift. Always compare to the raw value, not to
intermediate rounded versions.

### 2. Stale output files
The code was updated after the last time it was run. The output files in results/ are
from an earlier version of the code. The paper includes these stale numbers. Check
file modification dates. If the code file is newer than its output file, the output
may be stale.

### 3. Copy-paste across tables
Authors sometimes copy a row or panel from one table to another (e.g., "baseline
specification" appears in Tables 2, 3, and 4). If one table was regenerated but the
others were not, the "same" row might show different numbers. Cross-check identical
rows across tables.

### 4. Manual overrides in LaTeX
Sometimes the auto-generated .tex table is included via `\input{}`, but the author
then manually edits numbers in the .tex file (e.g., to add significance stars, fix
formatting, or "correct" a rounding). Compare the .tex file in the paper directory
with the one in the results directory byte-by-byte if possible.

### 5. Standard error type mismatch
The paper says "clustered standard errors" but the table was generated with
heteroskedasticity-robust (HC) standard errors. Coefficients will match but
standard errors, t-stats, and p-values will all differ.

---

## Data Pipeline Issues

### 6. Unintended row duplication from joins
A left_join where the right-hand table has duplicate keys silently duplicates rows
in the output. The author may not notice because they never check N after the join.
This inflates the sample size and biases standard errors downward.

### 7. Factor level ordering
In R, the reference category for a factor depends on factor level ordering. If the
data is read in differently (e.g., different locale, different R version), factor
levels may change, shifting which category is the baseline in regressions.

### 8. Silent NA propagation
If a variable used in a regression has NAs, `lm()` drops those observations by
default. If the paper reports N = 5,000 but the regression actually uses N = 4,800
because 200 observations had NA in one control variable, the paper's N is wrong.
Check `nobs(model)` against the claimed sample size.

### 9. Encoding issues in data
CSV files with special characters (accents, cyrillic, etc.) may read differently
depending on locale settings. This can silently corrupt string variables used for
merging or fixed effects.

### 10. Date parsing ambiguity
Is "01/02/2020" January 2nd or February 1st? Different `read_csv` locale settings
parse this differently. If dates are used for sample restrictions or event studies,
this can change results.

---

## Econometric / Modeling Issues

### 11. Fixed effects specification mismatch
The paper says "we include municipality and year fixed effects" but the code uses
`factor(region)` instead of `factor(municipality)`. This is a different specification
than described. Or the code uses `feols(y ~ x | municipality + year)` but the paper
says "province fixed effects."

### 12. Clustering level mismatch
The paper says standard errors are "clustered at the district level" but the code
clusters at the municipality level. Or the paper is ambiguous ("clustered at the
regional level") and the code reveals which specific regional unit is used.

### 13. Weight variable issues
If the regression uses weights (`lm(..., weights = w)`), verify:
- Are the weights the same ones described in the paper?
- Are there zero or negative weights?
- Do the weights change the effective N?

### 14. Subsample definition drift
The paper says "urban areas" but the code uses `urban_flag == 1`, and the definition
of `urban_flag` was set earlier in the pipeline using a threshold that may not match
the conventional definition. Trace the definition of subsample indicators back to
their construction.

### 15. Instrument validity not checked
For IV/2SLS regressions, the first-stage F-statistic should be reported. If it is
not computed in the code, the paper may either fabricate this number or report a
different statistic. Check that diagnostic tests match.

### 16. Winsorization / trimming not documented
Some authors winsorize or trim outliers but do not mention this in the paper, or
mention it only in a footnote. Check the code for any `quantile()` based filtering
or variable recoding.

---

## LaTeX and Formatting Issues

### 17. Significance stars inconsistent
The paper footnote says * p<0.1, ** p<0.05, *** p<0.01, but stargazer defaults are
* p<0.1, ** p<0.05, *** p<0.01. However, some journals use * p<0.05, ** p<0.01,
*** p<0.001. Check that the stars in the table match the footnote definition, and
that both match the actual p-values.

### 18. Parentheses ambiguity
Are the values in parentheses standard errors, t-statistics, confidence intervals,
or p-values? The table note should specify, and the code should confirm.

### 19. Table note vs. actual specification
Table notes like "All regressions include year and region fixed effects" should be
verified against the actual code. Sometimes the note is copied from a template and
does not match the actual specification in a particular table.

### 20. Absolute vs. relative values
The paper says "a 5% increase" - is that 5 percentage points (0.05) or 5 percent
of the baseline? Check the coefficient, the baseline mean, and the exact wording.

---

## Replicability Issues

### 21. Missing package versions
The code uses packages that have been updated since the analysis was run. Function
behavior may have changed. Check for `renv.lock` or `sessionInfo()` output. If not
available, note that exact replication may not be possible.

### 22. Random seed not set
Bootstrap standard errors, permutation tests, or simulation-based inference will
give different results each time without `set.seed()`. If the paper reports
bootstrapped CIs, check that a seed is set.

### 23. Platform-dependent results
Some numerical results differ slightly between Windows, Mac, and Linux due to
floating-point arithmetic differences. This usually affects only very small digits
but can occasionally flip significance at borderline p-values.

### 24. Proprietary or restricted data
If the raw data is not included in the repository (common with confidential survey
data or administrative records), full replication is impossible. Note which steps
can be verified and which cannot.

### 25. Undocumented manual steps
Sometimes the pipeline includes manual steps ("open the Excel file and delete the
first two rows", "rename column X to Y"). These break automated replication. Flag
any gap in the automated pipeline.
