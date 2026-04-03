---
name: csv-data-analyzer
description: "Load, explore, clean, and analyze CSV data with statistical summaries"
metadata:
  openclaw:
    emoji: "📊"
    category: "analysis"
    subcategory: "wrangling"
    keywords: ["CSV analysis", "data exploration", "data cleaning", "statistical summary", "tabular data", "pandas"]
    source: "wentor-research-plugins"
---

# CSV Data Analyzer

A comprehensive skill for loading, exploring, cleaning, and analyzing CSV datasets within research workflows. Designed for researchers who need to quickly understand the structure, quality, and statistical properties of tabular data before conducting deeper analysis.

## Overview

Research datasets commonly arrive as CSV files from instrument exports, survey platforms, government repositories, and collaborator handoffs. This skill provides a structured approach to the entire CSV analysis pipeline: ingestion, profiling, quality assessment, cleaning, transformation, and summary statistics. It emphasizes reproducibility by generating audit logs of every transformation applied to the raw data.

The skill supports datasets of varying complexity, from single-table survey results to multi-file longitudinal study exports with hundreds of columns. It works with standard Python data science libraries (pandas, numpy, scipy) and produces outputs suitable for inclusion in methods sections and supplementary materials.

## Data Loading and Initial Profiling

### Loading Strategies

```python
import pandas as pd
import numpy as np

def load_and_profile_csv(filepath: str, encoding: str = 'utf-8') -> dict:
    """
    Load a CSV file and generate an initial data profile.
    Handles common encoding issues and delimiter detection.
    """
    # Try multiple encodings if default fails
    encodings = [encoding, 'latin-1', 'utf-8-sig', 'cp1252']
    df = None
    for enc in encodings:
        try:
            df = pd.read_csv(filepath, encoding=enc, low_memory=False)
            break
        except (UnicodeDecodeError, pd.errors.ParserError):
            continue

    if df is None:
        raise ValueError(f"Could not parse {filepath} with any supported encoding")

    profile = {
        'rows': len(df),
        'columns': len(df.columns),
        'memory_mb': df.memory_usage(deep=True).sum() / 1e6,
        'dtypes': df.dtypes.value_counts().to_dict(),
        'missing_pct': (df.isnull().sum() / len(df) * 100).to_dict(),
        'duplicates': df.duplicated().sum(),
        'column_names': df.columns.tolist()
    }
    return df, profile
```

### Column Type Inference

```python
def infer_semantic_types(df: pd.DataFrame) -> dict:
    """
    Infer semantic column types beyond pandas dtypes.
    Detects dates, identifiers, categorical, continuous, and text columns.
    """
    semantic_types = {}
    for col in df.columns:
        nunique = df[col].nunique()
        ratio = nunique / len(df) if len(df) > 0 else 0

        if ratio > 0.95 and df[col].dtype == 'object':
            semantic_types[col] = 'identifier'
        elif nunique <= 20 and df[col].dtype in ['object', 'int64']:
            semantic_types[col] = 'categorical'
        elif df[col].dtype in ['float64', 'int64']:
            semantic_types[col] = 'continuous'
        elif pd.to_datetime(df[col], errors='coerce').notna().mean() > 0.8:
            semantic_types[col] = 'datetime'
        else:
            semantic_types[col] = 'text'
    return semantic_types
```

## Data Cleaning Pipeline

### Systematic Cleaning Steps

1. **Remove fully empty rows and columns**: Drop rows/columns where all values are NaN.
2. **Standardize column names**: Convert to snake_case, remove special characters.
3. **Handle missing data**: Assess missingness patterns (MCAR/MAR/MNAR) before choosing imputation strategy.
4. **Detect and handle duplicates**: Identify exact and near-duplicates using fuzzy matching.
5. **Validate value ranges**: Flag values outside expected domain ranges.
6. **Standardize categorical labels**: Merge inconsistent spellings (e.g., "Male", "male", "M").

```python
def clean_column_names(df: pd.DataFrame) -> pd.DataFrame:
    """Standardize column names to snake_case."""
    import re
    df.columns = [
        re.sub(r'[^a-z0-9]+', '_', col.lower().strip()).strip('_')
        for col in df.columns
    ]
    return df

def assess_missingness(df: pd.DataFrame) -> pd.DataFrame:
    """Generate a missingness report for each column."""
    report = pd.DataFrame({
        'missing_count': df.isnull().sum(),
        'missing_pct': (df.isnull().sum() / len(df) * 100).round(2),
        'dtype': df.dtypes
    })
    report['action'] = report['missing_pct'].apply(
        lambda x: 'drop' if x > 60 else ('impute' if x > 0 else 'ok')
    )
    return report.sort_values('missing_pct', ascending=False)
```

## Statistical Summary Generation

### Descriptive Statistics

```python
def generate_statistical_summary(df: pd.DataFrame) -> dict:
    """
    Generate comprehensive descriptive statistics for all columns.
    Includes measures of central tendency, dispersion, and distribution shape.
    """
    numeric_cols = df.select_dtypes(include=[np.number])
    summary = {
        'numeric': numeric_cols.describe().T.assign(
            skewness=numeric_cols.skew(),
            kurtosis=numeric_cols.kurtosis(),
            iqr=numeric_cols.quantile(0.75) - numeric_cols.quantile(0.25),
            cv=numeric_cols.std() / numeric_cols.mean()  # coefficient of variation
        ),
        'categorical': {
            col: df[col].value_counts().head(10).to_dict()
            for col in df.select_dtypes(include=['object']).columns
        },
        'correlations': numeric_cols.corr().round(3)
    }
    return summary
```

### Normality and Distribution Testing

| Test | Use Case | Function |
|------|----------|----------|
| Shapiro-Wilk | Normality test (n < 5000) | `scipy.stats.shapiro()` |
| D'Agostino-Pearson | Normality test (n >= 5000) | `scipy.stats.normaltest()` |
| Kolmogorov-Smirnov | Compare to any distribution | `scipy.stats.kstest()` |
| Levene's test | Homogeneity of variance | `scipy.stats.levene()` |

## Best Practices for Reproducibility

- Always save the raw CSV separately; never overwrite original files.
- Log every cleaning step with timestamps in a transformation audit trail.
- Export cleaned datasets with a version suffix (e.g., `data_v2_cleaned.csv`).
- Include the cleaning script or notebook alongside the published dataset.
- Report the number of rows removed at each step in your methods section.
- Use `random_state` parameters consistently for any stochastic operations.

## References

- McKinney, W. (2022). *Python for Data Analysis* (3rd ed.). O'Reilly Media.
- Wickham, H. (2014). Tidy Data. *Journal of Statistical Software*, 59(10).
- Van den Broeck, J., et al. (2005). Data Cleaning: Detecting, Diagnosing, and Editing Data Abnormalities. *PLoS Medicine*, 2(10).
