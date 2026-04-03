---
name: data-cog-guide
description: "Upload messy CSVs with minimal prompting for deep automated analysis"
metadata:
  openclaw:
    emoji: "🧠"
    category: "analysis"
    subcategory: "wrangling"
    keywords: ["automated analysis", "data wrangling", "CSV upload", "data profiling", "smart analysis", "minimal prompting"]
    source: "wentor-research-plugins"
---

# Data Cog Guide

An intelligent data analysis assistant that accepts messy, poorly documented CSV files and automatically infers structure, cleans anomalies, and produces deep analytical reports with minimal user prompting. Designed for researchers who need quick insights from unfamiliar or inherited datasets without spending hours on manual data preparation.

## Overview

Researchers frequently receive datasets from collaborators, public repositories, or legacy systems that lack documentation, use inconsistent formatting, and contain mixed data quality. Traditional analysis requires significant upfront effort to understand and prepare such data. Data Cog automates this process by applying heuristic inference, pattern recognition, and iterative cleaning to produce analysis-ready data along with a comprehensive profile report.

The skill implements a "zero-configuration" philosophy: provide the CSV file path and an optional research question, and it handles encoding detection, delimiter inference, type casting, missingness assessment, and initial exploratory statistics automatically.

## Automated Ingestion Pipeline

### Smart Loading

```python
import pandas as pd
import chardet
import io

def smart_load_csv(filepath: str) -> tuple:
    """
    Intelligently load a CSV file, auto-detecting encoding,
    delimiter, header row, and comment lines.
    """
    # Step 1: Detect encoding
    with open(filepath, 'rb') as f:
        raw = f.read(100000)
    encoding = chardet.detect(raw)['encoding']

    # Step 2: Detect delimiter
    import csv
    with open(filepath, 'r', encoding=encoding, errors='replace') as f:
        sample = f.read(8192)
    sniffer = csv.Sniffer()
    try:
        dialect = sniffer.sniff(sample)
        delimiter = dialect.delimiter
    except csv.Error:
        delimiter = ','

    # Step 3: Detect header row (skip comment lines)
    skip_rows = 0
    with open(filepath, 'r', encoding=encoding, errors='replace') as f:
        for line in f:
            if line.startswith('#') or line.startswith('//') or line.strip() == '':
                skip_rows += 1
            else:
                break

    # Step 4: Load with inferred parameters
    df = pd.read_csv(
        filepath, encoding=encoding, delimiter=delimiter,
        skiprows=skip_rows, low_memory=False
    )

    metadata = {
        'encoding': encoding,
        'delimiter': repr(delimiter),
        'skipped_rows': skip_rows,
        'shape': df.shape
    }
    return df, metadata
```

### Automatic Type Inference

```python
def auto_cast_columns(df: pd.DataFrame) -> pd.DataFrame:
    """
    Automatically cast columns to their most appropriate types.
    Handles dates, numerics stored as strings, booleans, and categories.
    """
    for col in df.columns:
        # Try numeric conversion
        numeric = pd.to_numeric(df[col], errors='coerce')
        if numeric.notna().mean() > 0.85:
            df[col] = numeric
            continue

        # Try datetime conversion
        datetime = pd.to_datetime(df[col], errors='coerce', infer_datetime_format=True)
        if datetime.notna().mean() > 0.85:
            df[col] = datetime
            continue

        # Try boolean detection
        unique_lower = df[col].dropna().astype(str).str.lower().unique()
        if set(unique_lower).issubset({'true', 'false', 'yes', 'no', '1', '0', 'y', 'n'}):
            df[col] = df[col].astype(str).str.lower().map(
                {'true': True, 'false': False, 'yes': True, 'no': False,
                 '1': True, '0': False, 'y': True, 'n': False}
            )
            continue

        # Convert low-cardinality strings to category
        if df[col].nunique() / len(df) < 0.05 and df[col].nunique() < 50:
            df[col] = df[col].astype('category')

    return df
```

## Deep Automated Profiling

### Profile Report Generation

The profiling stage produces a structured report covering:

1. **Schema overview**: Column names, inferred types, semantic roles (ID, feature, target, timestamp).
2. **Univariate statistics**: Mean, median, mode, std, skewness, kurtosis for numeric columns; frequency tables for categoricals.
3. **Missing data matrix**: Heatmap-style report of missingness patterns across all columns.
4. **Correlation analysis**: Pairwise Pearson, Spearman, and Cramér's V correlations.
5. **Distribution flags**: Columns that are heavily skewed, zero-inflated, or constant.
6. **Duplicate detection**: Exact row duplicates and near-duplicate clusters.

| Metric | Numeric Columns | Categorical Columns |
|--------|----------------|-------------------|
| Central tendency | Mean, median, mode | Mode, frequency |
| Dispersion | Std, IQR, range, CV | Unique count, entropy |
| Shape | Skewness, kurtosis | Imbalance ratio |
| Quality | Missing %, zero %, outlier % | Missing %, rare labels % |

## Interactive Analysis Workflow

### Minimal-Prompt Usage Pattern

The recommended workflow requires only three inputs:

1. **File path**: The CSV to analyze.
2. **Research question** (optional): A one-sentence description of what you want to learn.
3. **Output format**: "summary", "full_report", or "cleaned_csv".

```
User: Analyze /data/survey_results_2025.csv
      Question: What factors predict participant satisfaction?
      Output: full_report

Data Cog will:
  1. Load and profile the dataset (auto-detect everything)
  2. Clean and transform (handle missing data, encode categoricals)
  3. Run correlation analysis focused on satisfaction-related columns
  4. Generate regression models predicting satisfaction
  5. Produce a structured report with findings and visualizations
```

### Iterative Refinement

After the initial automated analysis, you can refine by asking targeted follow-up questions:

- "Focus only on respondents from Group A"
- "Exclude the first 50 rows (pilot data)"
- "Treat column X as ordinal with levels: low < medium < high"
- "Run the same analysis but with log-transformed income"

## Best Practices

- Always review the auto-generated profile before trusting downstream results.
- Verify that automatic type inference made sensible choices, especially for ambiguous columns.
- Provide a research question when possible to guide feature selection and analysis focus.
- Save the cleaning audit log alongside your results for reproducibility.
- For datasets over 1 million rows, consider sampling for the initial profile to save time.

## References

- Breck, E., et al. (2019). Data Validation for Machine Learning. *MLSys 2019*.
- Hynes, N., et al. (2017). The Data Linter: Lightweight, Automated Sanity Checking for ML Data Sets. *NIPS MLSys Workshop*.
- Pandas Development Team (2024). *pandas: Powerful Python Data Analysis Toolkit*. https://pandas.pydata.org/
