---
description: Standardized Python & Stata coding practices for empirical research projects
---

# Research Project Coding Guidelines

**Version:** 1.0
**Last Updated:** January 2026
**Purpose:** Standardized coding practices for empirical research projects

---

## Table of Contents

1. [Project Structure](#project-structure)
2. [Python Guidelines](#python-guidelines)
3. [Stata Guidelines](#stata-guidelines)
4. [General Best Practices](#general-best-practices)
5. [Quick Reference Templates](#quick-reference-templates)

---

## Project Structure

### Directory Organization

```
ProjectName/
├── Code/                           # All analysis scripts
│   ├── [Number]_[Name].py         # Data processing (Python)
│   ├── AN_[Number]_[Name].do      # Analysis scripts (Stata)
│   ├── AN_[Number]_[Name].py      # Analysis scripts (Python)
│   ├── LogFiles/                  # Stata log files
│   └── README.md                  # Project documentation
├── Data/
│   ├── Raw/                       # Original data (never modify)
│   ├── Intermediate/              # Partial processing
│   └── Clean/                     # Analysis-ready data
└── Results/
    ├── Tables/                    # Regression tables
    └── Figures/                   # Visualizations
```

### Script Numbering Convention

- **0:** Initial data extraction
- **1a, 1b, 1c:** Data cleaning and preparation
- **2a, 2b:** Data merging and linking
- **3a, 3b:** Feature extraction and engineering
- **4a, 4b:** Final data preparation
- **5a, 5b:** Descriptive analysis
- **AN_1, AN_2:** Formal analysis and regressions

**Use letter suffixes (a, b, c)** for parallel steps
**Use number suffixes (1, 2, 3)** for sequential substeps

### Tool Preferences by Task

| Task | Preferred Tool | Rationale |
|------|---------------|-----------|
| **Figures/Visualizations** | Python | Better control, publication-quality with matplotlib/seaborn |
| **Regression Tables** | Stata | More efficient with outreg2/esttab, standard in economics |
| **Data Cleaning** | Python | Better for large datasets, flexible transformations |
| **Panel Regressions** | Stata | reghdfe package is gold standard |

---

## Python Guidelines

### 1. Script Template

```python
#!/usr/bin/env python3
"""
ScriptName.py

Brief description of what this script does.

Input files:
- Data/Raw/input1.csv
- Data/Intermediate/input2.csv

Output files:
- Data/Clean/output.csv (description)

Author: Your Name
Date: YYYY-MM-DD
"""

import pandas as pd
import numpy as np
from pathlib import Path
import matplotlib.pyplot as plt
import seaborn as sns

def get_project_root():
    """Automatically detect the project root directory."""
    return Path(__file__).parent.absolute()


def main():
    """Main processing function."""
    print("=" * 70)
    print("SCRIPT TITLE")
    print("=" * 70)

    # Setup paths
    base_dir = get_project_root()
    data_clean_dir = base_dir / ".." / "Data" / "Clean"

    # Your code here

    print("\n" + "=" * 70)
    print("PROCESSING COMPLETE")
    print("=" * 70)


if __name__ == "__main__":
    main()
```

### 2. Path Management (CRITICAL)

**Always use this pattern for portability:**

```python
def get_project_root():
    """Automatically detect the project root directory."""
    return Path(__file__).parent.absolute()

# Then use relative paths
base_dir = get_project_root()
data_raw_dir = base_dir / ".." / "Data" / "Raw"
data_clean_dir = base_dir / ".." / "Data" / "Clean"
data_intermediate_dir = base_dir / ".." / "Data" / "Intermediate"
results_tables_dir = base_dir / ".." / "Results" / "Tables"
results_figures_dir = base_dir / ".." / "Results" / "Figures"

# Create directories if they don't exist
data_intermediate_dir.mkdir(parents=True, exist_ok=True)
```

### 3. Data Loading & Saving

```python
# Loading with error handling
if not input_file.exists():
    raise FileNotFoundError(f"Input file not found: {input_file}")

try:
    df = pd.read_csv(input_file, low_memory=False)
    print(f"Loaded {len(df):,} records")
except Exception as e:
    print(f"Error reading file: {e}")
    return

# Saving with confirmation
df_sorted = df.sort_values(['company', 'year'])
df_sorted.to_csv(output_file, index=False)
print(f"Saved {len(df_sorted):,} records to: {output_file}")
```

### 4. Progress Reporting

**Use consistent formatting for readability:**

```python
# Section headers
print("\n" + "=" * 70)
print("DATA PROCESSING")
print("=" * 70)

# Progress with comma formatting
print(f"\nLoaded {len(df):,} records")
print(f"  After filtering: {len(df_filtered):,} ({len(df_filtered)/len(df)*100:.1f}%)")

# Summary statistics
print("\n=== SUMMARY ===")
print(f"Total companies: {df['company'].nunique():,}")
print(f"Date range: {df['date'].min()} to {df['date'].max()}")
print(f"Match rate: {match_rate*100:.1f}%")
```

### 5. Function Documentation

```python
def clean_company_name(name_str):
    """
    Clean and standardize company names for matching.

    Parameters:
    - name_str: Raw company name string

    Returns:
    - Cleaned company name (uppercase, no punctuation)
    """
    if pd.isna(name_str):
        return ""

    # Remove common suffixes
    name = str(name_str).upper()
    name = re.sub(r'\b(INC|CORP|LTD|LLC)\b', '', name)
    name = re.sub(r'[^\w\s]', '', name)  # Remove punctuation

    return name.strip()
```

### 6. Data Validation

```python
# Check for required columns
required_cols = ['company', 'year', 'value']
missing_cols = [col for col in required_cols if col not in df.columns]
if missing_cols:
    raise ValueError(f"Missing required columns: {missing_cols}")

# Report data quality
print("\nData Quality Checks:")
print(f"  Missing values in key column: {df['key_col'].isna().sum():,}")
print(f"  Duplicate records: {df.duplicated().sum():,}")
print(f"  Unique companies: {df['company'].nunique():,}")
```

### 7. Merging Pattern

```python
# Prepare keys
df1['merge_key'] = df1['company'].astype(str).str.strip().str.upper()
df2['merge_key'] = df2['company'].astype(str).str.strip().str.upper()

# Merge with reporting
print(f"\nMerging datasets:")
print(f"  Dataset 1: {len(df1):,} records")
print(f"  Dataset 2: {len(df2):,} records")

df_merged = df1.merge(df2, on='merge_key', how='inner', indicator=True)

print(f"  Merged: {len(df_merged):,} records")
print(f"  Match rate: {len(df_merged)/len(df1)*100:.1f}%")

# Check merge results
print("\nMerge indicator breakdown:")
print(df_merged['_merge'].value_counts())
```

### 8. Visualization Standards

```python
# Setup (at top of script)
import matplotlib.pyplot as plt
import seaborn as sns
sns.set_style("whitegrid")
plt.rcParams['figure.figsize'] = (12, 7)

# Create publication-quality figures
fig, ax = plt.subplots(figsize=(14, 8))

ax.plot(x, y, marker='o', linewidth=2, markersize=8,
        color='#2E86AB', label='Series Name')

ax.set_xlabel('X-axis Label', fontsize=12, fontweight='bold')
ax.set_ylabel('Y-axis Label', fontsize=12, fontweight='bold')
ax.set_title('Figure Title', fontsize=14, fontweight='bold', pad=20)

# Format y-axis with commas
ax.yaxis.set_major_formatter(plt.FuncFormatter(lambda x, p: f'{int(x):,}'))

ax.legend(loc='best', frameon=True, fancybox=True, shadow=True)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig(output_path, dpi=300, bbox_inches='tight')
plt.close()

print(f"Saved figure to: {output_path}")
```

### 9. Variable Naming Conventions

| Type | Convention | Examples |
|------|-----------|----------|
| DataFrames | `df_` prefix | `df`, `df_filtered`, `df_merged`, `df_agg` |
| Paths | `_dir` or `_file` suffix | `base_dir`, `input_file`, `output_path` |
| Functions | snake_case verbs | `clean_data()`, `load_files()`, `calculate_returns()` |
| Variables | snake_case | `company_name`, `year_founded`, `total_assets` |
| Constants | UPPER_CASE | `START_YEAR`, `MIN_OBSERVATIONS` |

---

## Stata Guidelines

### 1. Script Template

```stata
/*
================================================================================
ScriptName.do

Description of the analysis performed in this script.

Inputs:
- ../Data/Clean/input_data.csv

Outputs:
- ../Results/Tables/Table1_MainResults.xls
- ../Code/LogFiles/ScriptName.log

Author: Your Name
Date: YYYY-MM-DD
================================================================================
*/

*** Set up paths
global repodir "/Users/zrsong/MIT Dropbox/Zirui Song/Research Projects/PROJECT_NAME"
global datadir "$repodir/Data"
global cleandir "$datadir/Clean"
global intdir "$datadir/Intermediate"
global tabdir "$repodir/Results/Tables"
global figdir "$repodir/Results/Figures"
global logdir "$repodir/Code/LogFiles"

*** Start log
log using "$logdir/ScriptName.log", text replace

/*==============================================================================
    Data Preparation
==============================================================================*/

import delimited "$cleandir/input_data.csv", clear

[Your code here]

*** Close log
log close
```

### 2. Global Path Setup (CRITICAL)

**Always define these at the top:**

```stata
global repodir "/Full/Path/To/Project"
global datadir "$repodir/Data"
global cleandir "$datadir/Clean"
global intdir "$datadir/Intermediate"
global rawdir "$datadir/Raw"
global tabdir "$repodir/Results/Tables"
global figdir "$repodir/Results/Figures"
global logdir "$repodir/Code/LogFiles"
```

**Note:** Update `repodir` for each user/computer

### 3. Regression Structure

```stata
/*==============================================================================
    Main Regressions - Table 1
==============================================================================*/

*** Define variable lists
local borr_controls "log_assets leverage tangibility profitability"
local loan_controls "log_amount maturity"
local all_controls "`borr_controls' `loan_controls'"

*** Column 1: No controls
reghdfe outcome treatment_var, ///
    absorb(industry year) ///
    vce(cluster firm_id)

outreg2 using "$tabdir/Table1_MainResults.xls", replace excel ///
    ctitle("(1) No Controls") label dec(3) ///
    addtext(Industry FE, YES, Year FE, YES) ///
    keep(treatment_var)

*** Column 2: With controls
reghdfe outcome treatment_var `all_controls', ///
    absorb(industry year) ///
    vce(cluster firm_id)

outreg2 using "$tabdir/Table1_MainResults.xls", append excel ///
    ctitle("(2) Full Controls") label dec(3) ///
    addtext(Industry FE, YES, Year FE, YES, Controls, YES) ///
    keep(treatment_var `all_controls')
```

### 4. Output Table Conventions

**Two output workflows:**

| Stage | Command | Output Format | Use Case |
|-------|---------|---------------|----------|
| Working/Exploratory | `outreg2` | Excel (`.xls`) | Quick iteration, reviewing results |
| Final Paper | `esttab` | LaTeX (`.tex`) | Publication-ready tables |

---

#### A. Working Tables: outreg2 with Excel

Use `outreg2` with the `excel` option for exploratory analysis and quick iterations:

```stata
outreg2 using "$tabdir/TableName.xls", [replace/append] excel ///
    ctitle("Column Title") ///              // Column header
    label ///                                // Use variable labels
    dec(3) ///                              // 3 decimal places
    keep(vars_to_show) ///                  // Variables to display
    addtext(Industry FE, YES, ///           // Notes for fixed effects
            Year FE, YES, ///
            Controls, YES)
```

**Working table naming:**
- `Table1_MainResults.xls`
- `Table2_Robustness.xls`
- `TableA1_DescriptiveStats.xls` (appendix)

---

#### B. Final Paper Tables: esttab for LaTeX

Use `esttab` to generate publication-ready LaTeX tables:

```stata
*** Store regression results
eststo clear

eststo m1: reghdfe outcome treatment, absorb(industry year) vce(cluster firm_id)
eststo m2: reghdfe outcome treatment `controls', absorb(industry year) vce(cluster firm_id)
eststo m3: reghdfe outcome treatment `controls', absorb(firm_id year) vce(cluster firm_id)

*** Output LaTeX table
esttab m1 m2 m3 using "$tabdir/Table1_MainResults.tex", replace ///
    b(3) se(3) ///                          // 3 decimal places for coef and SE
    star(* 0.10 ** 0.05 *** 0.01) ///       // Significance stars
    label ///                                // Use variable labels
    booktabs ///                            // Professional table formatting
    nomtitles ///                           // No model titles (use column numbers)
    mgroups("Dependent Variable: Outcome", pattern(1 0 0) ///
            prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
    keep(treatment `controls') ///           // Variables to display
    order(treatment `controls') ///          // Variable order
    stats(r2 N, fmt(3 0) labels("R-squared" "Observations")) ///
    indicate("Industry FE = *industry*" "Year FE = *year*" "Firm FE = *firm_id*") ///
    addnotes("Standard errors clustered by firm in parentheses." ///
             "* p<0.10, ** p<0.05, *** p<0.01")
```

**Simplified esttab for quick LaTeX output:**

```stata
esttab m1 m2 m3 using "$tabdir/Table1.tex", replace ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    label booktabs ///
    keep(treatment) ///
    stats(r2 N, fmt(3 0) labels("R\$^2\$" "N")) ///
    addnotes("Clustered SEs in parentheses.")
```

**Final table naming:**
- `Table1_MainResults.tex`
- `Table2_Robustness.tex`
- `TableA1_Appendix.tex`

### 5. Fixed Effects Patterns

```stata
*** Firm and year fixed effects with clustering
reghdfe outcome treatment controls, ///
    absorb(firm_id year) ///
    vce(cluster firm_id)

*** Industry and year fixed effects
reghdfe outcome treatment controls, ///
    absorb(industry year) ///
    vce(cluster firm_id)

*** Fama-French 12 industry classification
sicff sic, ind(12) gen(ff12)
reghdfe outcome treatment controls, ///
    absorb(ff12 year) ///
    vce(cluster firm_id)
```

### 6. Subsample Analysis

```stata
/*==============================================================================
    Subsample Analysis - Large Firms
==============================================================================*/

preserve

*** Keep only observations meeting criteria
keep if total_assets > median_assets

*** Run regressions for subsample
reghdfe outcome treatment controls, ///
    absorb(industry year) ///
    vce(cluster firm_id)

outreg2 using "$tabdir/Table2_Subsamples.xls", append excel ///
    ctitle("Large Firms") label dec(3)

restore
```

### 7. Variable Generation

```stata
*** Generate dummy variables
gen high_leverage = (leverage > 0.3)
replace high_leverage = 0 if missing(high_leverage)
label variable high_leverage "Leverage > 30%"

*** Generate interaction terms
gen treat_x_post = treatment * post
label variable treat_x_post "Treatment × Post"

*** Generate time trends
gen year_trend = year - 2000
gen year_trend_sq = year_trend^2
```

### 8. Summary Statistics Table

```stata
/*==============================================================================
    Table 1: Descriptive Statistics
==============================================================================*/

*** Summary statistics
estpost tabstat outcome treatment control1 control2, ///
    statistics(count mean sd min p25 p50 p75 max) ///
    columns(statistics)

esttab using "$tabdir/Table1_Descriptives.csv", ///
    cells("count mean sd min p25 p50 p75 max") ///
    replace noobs nomtitle nonumber

*** Alternative: Use outreg2
outreg2 using "$tabdir/Table1_Descriptives.xls", replace sum(log) ///
    keep(outcome treatment control1 control2) ///
    eqkeep(N mean sd min max)
```

### 9. Section Headers

```stata
/*==============================================================================
    Section Title
==============================================================================*/

*** Subsection description
[Code for subsection]

*** Another subsection
[More code]
```

---

## General Best Practices

### 1. File Naming Conventions

| Type | Convention | Examples |
|------|-----------|----------|
| Data cleaning | `[N]_[Action][Dataset].py` | `1a_CleanIPO.py`, `2_MergeCompustat.py` |
| Analysis | `AN_[N]_[Description].[ext]` | `AN_1_DescriptiveStats.py`, `AN_2_MainReg.do` |
| Data files | Descriptive names | `comp_crspa_merged.csv`, `loan_panel_final.csv` |

### 2. Workflow Checklist

**Before running any script:**
- [ ] Input files exist in specified locations
- [ ] Output directories are created
- [ ] Paths are correctly specified

**After running any script:**
- [ ] Check output file was created
- [ ] Verify record counts make sense
- [ ] Review summary statistics
- [ ] Check for unexpected missing values

### 3. Documentation Requirements

**Every script must include:**
- Docstring/header comment with purpose
- List of input files
- List of output files
- Date last modified

**Every analysis must document:**
- Sample selection criteria
- Variable construction
- Outlier treatment
- Missing data handling

### 4. Code Organization

**Within a script, follow this order:**
1. Imports/library loading
2. Path setup
3. Helper functions
4. Main processing function
5. Execution block (`if __name__ == "__main__":`)

### 5. Error Prevention

```python
# Check before processing
assert df['key'].notna().all(), "Key column has missing values"
assert df['year'].between(1990, 2025).all(), "Year outside expected range"
assert not df.duplicated(subset=['key']).any(), "Duplicate keys found"

# Validate merge results
assert len(df_merged) > 0, "Merge produced no matches"
assert '_merge' in df_merged.columns, "Merge indicator missing"
```

### 6. Reproducibility

**Always include:**
- Random seeds when using randomization: `np.random.seed(42)`
- Package versions in README
- Data processing workflow diagram
- Clear execution order in README

**Never:**
- Hardcode absolute paths (except Stata global `repodir`)
- Modify raw data files
- Delete intermediate files until project complete
- Use undocumented manual data adjustments

### 7. Version Control

**Git best practices:**
- Commit after completing each script
- Use descriptive commit messages
- Don't commit large data files
- Include `.gitignore` for:
  ```
  __pycache__/
  *.pyc
  .DS_Store
  LogFiles/
  *.log
  .ipynb_checkpoints/
  ```

---

## Quick Reference Templates

### Python: Basic Data Cleaning

```python
#!/usr/bin/env python3
"""Brief description."""

import pandas as pd
from pathlib import Path

def get_project_root():
    return Path(__file__).parent.absolute()

def main():
    # Paths
    base_dir = get_project_root()
    input_file = base_dir / ".." / "Data" / "Raw" / "input.csv"
    output_file = base_dir / ".." / "Data" / "Clean" / "output.csv"

    # Load
    df = pd.read_csv(input_file)
    print(f"Loaded {len(df):,} records")

    # Process
    df_clean = df.dropna(subset=['key_col'])
    df_clean = df_clean[df_clean['year'] >= 2000].copy()

    # Save
    df_clean.to_csv(output_file, index=False)
    print(f"Saved {len(df_clean):,} records")

if __name__ == "__main__":
    main()
```

### Python: Data Merging

```python
def merge_datasets(df1, df2, merge_key, how='inner'):
    """Merge with reporting."""
    print(f"\nMerging datasets:")
    print(f"  Left: {len(df1):,} records")
    print(f"  Right: {len(df2):,} records")

    merged = df1.merge(df2, on=merge_key, how=how, indicator=True)

    print(f"  Result: {len(merged):,} records")
    print(f"\nMerge breakdown:")
    print(merged['_merge'].value_counts())

    return merged
```

### Stata: Standard Regression Table

```stata
*** Table X: Main Results

local controls "control1 control2 control3"

*** Column 1
reghdfe outcome treatment, absorb(fe1 fe2) vce(cluster id)
outreg2 using "$tabdir/TableX.xls", replace excel ///
    ctitle("(1)") label dec(3) ///
    addtext(FE1, YES, FE2, YES) keep(treatment)

*** Column 2
reghdfe outcome treatment `controls', absorb(fe1 fe2) vce(cluster id)
outreg2 using "$tabdir/TableX.xls", append excel ///
    ctitle("(2)") label dec(3) ///
    addtext(FE1, YES, FE2, YES, Controls, YES) keep(treatment `controls')
```

### Stata: Summary Statistics

```stata
*** Generate summary statistics
estpost tabstat var1 var2 var3, ///
    statistics(count mean sd min max) columns(statistics)

esttab using "$tabdir/Summary.csv", ///
    cells("count mean sd min max") replace noobs
```

---

## Common Pitfalls to Avoid

### Python

1. **SettingWithCopyWarning**: Always use `.copy()` after filtering
   ```python
   df_subset = df[df['year'] >= 2000].copy()  # Good
   df_subset = df[df['year'] >= 2000]         # Bad
   ```

2. **Path issues**: Use `Path` objects, not string concatenation
   ```python
   file = base_dir / "Data" / "file.csv"  # Good
   file = base_dir + "/Data/file.csv"     # Bad
   ```

3. **Memory issues**: Use `low_memory=False` for large CSV files
   ```python
   df = pd.read_csv(file, low_memory=False)
   ```

### Stata

1. **Path separators**: Use forward slashes even on Windows
   ```stata
   global dir "C:/Users/Name/Project"  // Good
   global dir "C:\Users\Name\Project"  // Bad
   ```

2. **Missing absorb()**: Don't forget to include absorb when using reghdfe
   ```stata
   reghdfe y x, absorb(fe1 fe2) vce(cluster id)  // Good
   reghdfe y x, vce(cluster id)                   // Bad - will error
   ```

3. **Log file conflicts**: Always use `replace` option
   ```stata
   log using "$logdir/script.log", text replace  // Good
   log using "$logdir/script.log", text          // Bad - will error if exists
   ```

---

## Checklist for New Projects

### Initial Setup
- [ ] Create directory structure (Code/, Data/, Results/)
- [ ] Create subdirectories (Raw/, Intermediate/, Clean/, Tables/, Figures/)
- [ ] Initialize git repository
- [ ] Create README.md with project description
- [ ] Create .gitignore file
- [ ] Document data sources and access methods

### For Each Script
- [ ] Include header docstring with inputs/outputs
- [ ] Use standardized path management
- [ ] Include progress reporting
- [ ] Validate input files exist
- [ ] Check output makes sense
- [ ] Document any manual decisions

### Before Finalizing
- [ ] All scripts run without errors
- [ ] Results reproduce from raw data
- [ ] Tables and figures saved to Results/
- [ ] README documents full workflow
- [ ] Code is commented appropriately
- [ ] No hardcoded paths (except Stata repodir)
