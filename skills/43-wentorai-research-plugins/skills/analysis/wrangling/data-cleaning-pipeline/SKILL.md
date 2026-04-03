---
name: data-cleaning-pipeline
description: "Systematic data cleaning workflows for research datasets"
metadata:
  openclaw:
    emoji: "🧹"
    category: "analysis"
    subcategory: "wrangling"
    keywords: ["data cleaning", "data quality", "missing values", "outlier detection", "data validation", "preprocessing"]
    source: "wentor-research-plugins"
---

# Data Cleaning Pipeline

A skill for building systematic, reproducible data cleaning pipelines for research datasets. Covers common data quality issues, step-by-step cleaning workflows, handling missing values, detecting and treating outliers, validating data integrity, and documenting cleaning decisions for reproducibility.

## The Data Cleaning Workflow

### Pipeline Overview

Data cleaning should follow a consistent, documented order. Each step builds on the previous one, and the entire pipeline should be scripted for reproducibility.

```
Data Cleaning Pipeline (recommended order):

1. Initial Assessment
   - Load data, check dimensions, inspect dtypes
   - Generate summary statistics and missing value report
   - Identify structural issues (merged cells, inconsistent delimiters)

2. Structural Fixes
   - Standardize column names (snake_case, no spaces)
   - Fix data types (strings to numbers, dates, categories)
   - Split or merge columns as needed
   - Remove completely empty rows/columns

3. Deduplication
   - Identify exact duplicates
   - Identify near-duplicates (fuzzy matching)
   - Decide keep-first, keep-last, or merge strategy

4. Missing Value Treatment
   - Classify missingness mechanism (MCAR, MAR, MNAR)
   - Apply appropriate imputation or exclusion strategy
   - Document and justify missing data decisions

5. Outlier Detection and Treatment
   - Statistical methods (IQR, z-score, Mahalanobis)
   - Domain-based validation (impossible values)
   - Decide: correct, cap, remove, or keep with flag

6. Consistency Checks
   - Cross-field validation (age vs birth date)
   - Range validation (0-100 for percentages)
   - Referential integrity (foreign keys exist)

7. Documentation and Export
   - Log all changes with before/after counts
   - Export cleaned dataset with version number
   - Save cleaning script for reproducibility
```

## Initial Data Assessment

### Automated Quality Report

```python
import pandas as pd
import numpy as np

def generate_quality_report(df):
    """
    Generate a comprehensive data quality report.
    Run this BEFORE any cleaning to establish a baseline.
    """
    report = {
        "dimensions": f"{df.shape[0]} rows x {df.shape[1]} columns",
        "memory_usage": f"{df.memory_usage(deep=True).sum() / 1e6:.1f} MB",
        "duplicate_rows": df.duplicated().sum(),
    }

    col_report = []
    for col in df.columns:
        info = {
            "column": col,
            "dtype": str(df[col].dtype),
            "missing_count": df[col].isna().sum(),
            "missing_pct": f"{df[col].isna().mean() * 100:.1f}%",
            "unique_values": df[col].nunique(),
            "sample_values": str(df[col].dropna().head(3).tolist()),
        }

        if pd.api.types.is_numeric_dtype(df[col]):
            info["min"] = df[col].min()
            info["max"] = df[col].max()
            info["mean"] = df[col].mean()
            info["std"] = df[col].std()

        col_report.append(info)

    report["columns"] = col_report
    return report
```

## Missing Value Treatment

### Classifying Missingness

```
Missing data mechanisms (Rubin's classification):

MCAR (Missing Completely At Random):
  - Missingness is unrelated to any variable
  - Example: Lab samples randomly lost during transport
  - Test: Little's MCAR test, compare distributions
  - Safe to: Listwise delete if < 5% missing

MAR (Missing At Random):
  - Missingness depends on observed variables but not the missing value
  - Example: Younger participants skip income questions more often
  - Test: Compare missingness patterns across groups
  - Best approach: Multiple imputation, regression imputation

MNAR (Missing Not At Random):
  - Missingness depends on the unobserved value itself
  - Example: High-income people refuse to report income
  - Cannot be tested directly from the data
  - Requires: Sensitivity analysis, selection models, domain expertise
```

### Imputation Strategies

```python
from sklearn.impute import SimpleImputer, KNNImputer

def impute_missing_values(df, numeric_strategy="median",
                          categorical_strategy="mode"):
    """
    Apply appropriate imputation strategies by column type.

    For research data, prefer:
    - Median for skewed numeric data
    - Mean for normally distributed numeric data
    - Mode for categorical data
    - KNN for multivariate patterns
    - Multiple imputation for inference (use statsmodels or mice)
    """
    numeric_cols = df.select_dtypes(include=[np.number]).columns
    categorical_cols = df.select_dtypes(include=["object", "category"]).columns

    # Numeric imputation
    if len(numeric_cols) > 0:
        if numeric_strategy == "knn":
            imputer = KNNImputer(n_neighbors=5)
            df[numeric_cols] = imputer.fit_transform(df[numeric_cols])
        else:
            imputer = SimpleImputer(strategy=numeric_strategy)
            df[numeric_cols] = imputer.fit_transform(df[numeric_cols])

    # Categorical imputation
    if len(categorical_cols) > 0:
        imputer = SimpleImputer(strategy="most_frequent")
        df[categorical_cols] = imputer.fit_transform(df[categorical_cols])

    return df
```

## Outlier Detection

### Statistical Methods

```python
def detect_outliers_iqr(series, multiplier=1.5):
    """
    Detect outliers using the IQR method.
    Standard multiplier is 1.5 (outlier) or 3.0 (extreme outlier).
    """
    q1 = series.quantile(0.25)
    q3 = series.quantile(0.75)
    iqr = q3 - q1
    lower = q1 - multiplier * iqr
    upper = q3 + multiplier * iqr

    outliers = (series < lower) | (series > upper)
    return outliers, lower, upper


def detect_outliers_zscore(series, threshold=3.0):
    """
    Detect outliers using z-score method.
    Threshold of 3.0 corresponds to 99.7% of normal distribution.
    Use modified z-score (MAD-based) for skewed distributions.
    """
    from scipy import stats
    z_scores = np.abs(stats.zscore(series.dropna()))
    outliers = z_scores > threshold
    return outliers
```

### Domain-Based Validation

```
Common domain validations:

Age: 0-120 (flag > 100)
Height (cm): 50-250
Weight (kg): 1-300
Blood pressure systolic: 60-250
Blood pressure diastolic: 30-150
Temperature (C): 30-45 for body temperature
Likert scale (1-5): only integer values 1-5
Percentage: 0-100
Latitude: -90 to 90
Longitude: -180 to 180
Year of birth: 1900-current_year
Email: matches standard regex pattern
```

## Reproducibility and Documentation

### Cleaning Log

```python
class CleaningLog:
    """
    Log all cleaning operations for reproducibility.
    Every step should be documented with before/after counts.
    """

    def __init__(self):
        self.entries = []
        self.version = 0

    def log_step(self, step_name, description,
                 rows_before, rows_after, cols_affected):
        self.version += 1
        self.entries.append({
            "version": self.version,
            "step": step_name,
            "description": description,
            "rows_before": rows_before,
            "rows_after": rows_after,
            "rows_removed": rows_before - rows_after,
            "columns_affected": cols_affected,
        })

    def save_report(self, path):
        report_df = pd.DataFrame(self.entries)
        report_df.to_csv(path, index=False)
```

### Best Practices for Research Data

```
Reproducibility rules:
  1. Never modify the raw data file -- always save cleaned versions
  2. Use version numbers (data_v1_raw, data_v2_cleaned, data_v3_final)
  3. Script every step -- no manual edits in Excel
  4. Document every decision (why delete, why impute, why cap)
  5. Include the cleaning script in supplementary materials
  6. Record software versions (pandas, numpy, R packages)
  7. Set random seeds for any stochastic imputation
  8. Save intermediate datasets at major checkpoints
```

A well-documented data cleaning pipeline not only improves the quality of research findings but also strengthens the credibility of the work during peer review. Reviewers increasingly expect transparent data handling practices, and journals like PLOS ONE and Nature require data availability statements that implicitly demand reproducible preprocessing.
