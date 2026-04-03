---
name: pandas-data-wrangling
description: "Data cleaning, transformation, and exploratory analysis with pandas"
metadata:
  openclaw:
    emoji: "🧹"
    category: "analysis"
    subcategory: "wrangling"
    keywords: ["CSV data analyzer", "pandas", "data wrangling", "exploratory data analysis", "missing value imputation"]
    source: "N/A"
---

# Pandas Data Wrangling Guide

## Overview

Data wrangling -- the process of cleaning, transforming, and preparing raw data for analysis -- typically consumes 60-80% of a data scientist's time. Pandas is the de facto standard library for tabular data manipulation in Python, and mastering its idioms directly translates to faster, more reliable research workflows.

This guide covers the essential pandas operations that researchers encounter daily: loading heterogeneous data sources, diagnosing data quality issues, handling missing values, reshaping data for analysis, and performing exploratory data analysis (EDA). Each section includes copy-paste code examples designed for real-world research datasets.

Whether you are cleaning survey responses, preprocessing experimental logs, merging datasets from multiple sources, or preparing features for machine learning, the patterns here will save hours of trial and error.

## Loading and Inspecting Data

### Reading Common Formats

```python
import pandas as pd
import numpy as np

# CSV with encoding and date parsing
df = pd.read_csv('data.csv', encoding='utf-8',
                 parse_dates=['timestamp'],
                 dtype={'participant_id': str})

# Excel with specific sheet
df = pd.read_excel('data.xlsx', sheet_name='Experiment1',
                   header=1)  # Skip first row

# JSON (nested)
df = pd.json_normalize(json_data, record_path='results',
                       meta=['experiment_id', 'date'])

# Parquet (fast, columnar)
df = pd.read_parquet('data.parquet')
```

### Initial Diagnostics

```python
# Shape and types
print(f"Shape: {df.shape}")
print(df.dtypes)
print(df.info(memory_usage='deep'))

# Statistical summary
print(df.describe(include='all'))

# Missing value report
missing = df.isnull().sum()
missing_pct = (missing / len(df) * 100).round(1)
missing_report = pd.DataFrame({
    'count': missing,
    'percent': missing_pct
}).query('count > 0').sort_values('percent', ascending=False)
print(missing_report)

# Duplicate check
n_dupes = df.duplicated().sum()
print(f"Duplicate rows: {n_dupes}")
```

## Handling Missing Data

### Strategy Decision Tree

| Situation | Strategy | pandas Method |
|-----------|----------|---------------|
| < 5% missing, random | Drop rows | `df.dropna()` |
| Numeric, moderate missing | Mean/median imputation | `df.fillna(df.median())` |
| Categorical missing | Mode or "Unknown" | `df.fillna('Unknown')` |
| Time series gaps | Forward/backward fill | `df.ffill()` / `df.bfill()` |
| Systematic missing | Multiple imputation | `sklearn.impute.IterativeImputer` |
| Feature > 50% missing | Drop column | `df.drop(columns=[...])` |

### Implementation Examples

```python
# Conditional imputation
df['age'] = df['age'].fillna(df.groupby('group')['age'].transform('median'))

# Interpolation for time series
df['temperature'] = df['temperature'].interpolate(method='time')

# Flag missing values before imputing (preserve information)
df['salary_missing'] = df['salary'].isnull().astype(int)
df['salary'] = df['salary'].fillna(df['salary'].median())
```

## Data Transformation

### Type Conversion and Cleaning

```python
# String cleaning
df['name'] = df['name'].str.strip().str.lower()
df['email'] = df['email'].str.replace(r'\s+', '', regex=True)

# Categorical conversion (saves memory, enables ordering)
df['education'] = pd.Categorical(
    df['education'],
    categories=['high_school', 'bachelors', 'masters', 'phd'],
    ordered=True
)

# Numeric extraction from text
df['value'] = df['text_field'].str.extract(r'(\d+\.?\d*)').astype(float)
```

### Reshaping Operations

```python
# Wide to long (unpivot)
df_long = pd.melt(df,
    id_vars=['subject_id', 'condition'],
    value_vars=['score_t1', 'score_t2', 'score_t3'],
    var_name='timepoint',
    value_name='score'
)

# Long to wide (pivot)
df_wide = df_long.pivot_table(
    index='subject_id',
    columns='condition',
    values='score',
    aggfunc='mean'
).reset_index()

# Cross-tabulation
ct = pd.crosstab(df['group'], df['outcome'],
                 margins=True, normalize='index')
```

### Merging and Joining

```python
# Left join with validation
merged = pd.merge(
    experiments, participants,
    on='participant_id',
    how='left',
    validate='many_to_one',  # Catch unexpected duplicates
    indicator=True           # Shows _merge column
)

# Check merge quality
print(merged['_merge'].value_counts())
```

## Exploratory Data Analysis (EDA)

### Automated EDA Pipeline

```python
def quick_eda(df, target_col=None):
    """Run a quick EDA pipeline on a DataFrame."""
    print(f"=== Shape: {df.shape} ===\n")

    # Numeric columns
    numeric_cols = df.select_dtypes(include=np.number).columns
    print(f"Numeric columns ({len(numeric_cols)}):")
    print(df[numeric_cols].describe().round(2))

    # Categorical columns
    cat_cols = df.select_dtypes(include=['object', 'category']).columns
    print(f"\nCategorical columns ({len(cat_cols)}):")
    for col in cat_cols:
        n_unique = df[col].nunique()
        print(f"  {col}: {n_unique} unique values")
        if n_unique <= 10:
            print(f"    {df[col].value_counts().to_dict()}")

    # Correlations with target
    if target_col and target_col in numeric_cols:
        corr = df[numeric_cols].corr()[target_col].drop(target_col)
        print(f"\nCorrelations with '{target_col}':")
        print(corr.sort_values(ascending=False).round(3))

quick_eda(df, target_col='accuracy')
```

### GroupBy Aggregations

```python
# Multi-metric summary by group
summary = df.groupby('method').agg(
    mean_acc=('accuracy', 'mean'),
    std_acc=('accuracy', 'std'),
    median_time=('runtime_sec', 'median'),
    n_runs=('run_id', 'count')
).round(3).sort_values('mean_acc', ascending=False)

print(summary.to_markdown())
```

## Performance Optimization

| Technique | When to Use | Speedup |
|-----------|-------------|---------|
| `pd.Categorical` for strings | Repeated string values | 2-10x memory |
| `.query()` instead of boolean indexing | Complex filters | 1.5-3x |
| `pd.eval()` for arithmetic | Column arithmetic | 2-5x |
| Parquet instead of CSV | Large datasets | 5-20x I/O |
| `df.pipe()` for chaining | Readable pipelines | Clarity |

```python
# Method chaining with pipe
result = (
    df
    .query('score > 0')
    .assign(log_score=lambda x: np.log1p(x['score']))
    .groupby('group')
    .agg(mean_log=('log_score', 'mean'))
    .sort_values('mean_log', ascending=False)
)
```

## Best Practices

- **Never modify the original DataFrame in place.** Use `.copy()` when creating derived datasets.
- **Use method chaining for readability.** Pipe operations together instead of creating intermediate variables.
- **Document your cleaning steps.** Keep a data cleaning log or use a Jupyter notebook with explanations.
- **Validate after every merge.** Check row counts, null values, and the `_merge` indicator column.
- **Profile before optimizing.** Use `df.memory_usage(deep=True)` to identify memory bottlenecks.
- **Save intermediate results as Parquet.** It preserves dtypes and is much faster than CSV.

## References

- [pandas Documentation](https://pandas.pydata.org/docs/) -- Official reference
- [Python for Data Analysis, 3rd Edition](https://wesmckinney.com/book/) -- Wes McKinney
- [Effective Pandas](https://store.metasnake.com/effective-pandas-book) -- Matt Harrison
- [pandas Cookbook](https://github.com/jvns/pandas-cookbook) -- Julia Evans
