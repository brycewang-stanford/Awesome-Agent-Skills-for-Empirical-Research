# EDA Checklist

Detailed procedures for exploratory data analysis. Follow these checks BEFORE performing any analysis or transformation.

## Contents

- [Initial Data Inspection](#initial-data-inspection)
- [Missing Value Analysis](#missing-value-analysis)
- [Distribution Analysis](#distribution-analysis)
- [Outlier Detection](#outlier-detection)
- [Uniqueness and Cardinality](#uniqueness-and-cardinality)
- [Correlation Analysis](#correlation-analysis)
- [Automated Profiling Tools](#automated-profiling-tools)

## Initial Data Inspection

Run these checks immediately after loading ANY new dataset.

### Basic Shape and Structure

```python
import polars as pl

# Load data
df = pl.read_csv("data.csv")

# Basic inspection
print(f"Shape: {df.shape[0]} rows x {df.shape[1]} columns")
print(f"Columns: {df.columns}")
print(f"Memory usage: {df.estimated_size() / 1024 / 1024:.2f} MB")
```

### Data Types

```python
# Check types - look for unexpected types
print("Data types:")
for col in df.columns:
    print(f"  {col}: {df[col].dtype}")

# Common issues to look for:
# - Dates stored as strings
# - Numbers stored as strings (often due to formatting or special values)
# - Mixed types (will show as Object/String)
```

### Preview Data

```python
# Multiple views to catch different issues
print("First 5 rows:")
print(df.head())

print("\nLast 5 rows:")  # Often reveals truncation or footer issues
print(df.tail())

print("\nRandom sample:")  # Avoids bias from sorted data
print(df.sample(5, seed=42))
```

### Column Name Issues

```python
# Check for problematic column names
for col in df.columns:
    issues = []
    if col != col.strip():
        issues.append("leading/trailing whitespace")
    if col != col.lower():
        issues.append("mixed case")
    if " " in col:
        issues.append("contains spaces")
    if issues:
        print(f"Column '{col}': {', '.join(issues)}")
```

## Missing Value Analysis

Understanding missingness patterns is CRITICAL. Different patterns require different handling.

### Count and Percentage

```python
# Missing value summary
null_counts = df.null_count()
null_pcts = (df.null_count() / len(df) * 100)

print("Missing values:")
for col in df.columns:
    count = null_counts[col].item()
    pct = null_pcts[col].item()
    if count > 0:
        print(f"  {col}: {count} ({pct:.1f}%)")
```

### Patterns of Missingness

Three types of missingness (important for handling strategy):

| Pattern | Description | Detection | Handling |
|---------|-------------|-----------|----------|
| **MCAR** | Missing Completely At Random | Missingness unrelated to any data | Safe to drop or impute |
| **MAR** | Missing At Random | Missingness depends on observed data | Impute using related columns |
| **MNAR** | Missing Not At Random | Missingness depends on unobserved data | Requires domain knowledge |

```python
# Visual inspection of missingness patterns
# Look for: columns that are always missing together

# Check if missingness correlates across columns
missing_cols = [col for col in df.columns if df[col].null_count().item() > 0]
if len(missing_cols) > 1:
    # Create missingness indicator DataFrame
    missing_indicators = df.select([
        pl.col(col).is_null().alias(f"{col}_missing")
        for col in missing_cols
    ])
    # Correlation of missingness patterns
    print("Missingness correlation (high = missing together):")
    # Examine cross-tabulations of missingness
```

### Special Missing Value Codes

Data often uses special values instead of null:

```python
# Common special values to check for
special_values = ["", "N/A", "NA", "n/a", "null", "NULL", "None", "-", "--", ".", "?", "-999", "9999"]

for col in df.select(pl.col(pl.String)).columns:
    value_counts = df[col].value_counts()
    for sv in special_values:
        count = value_counts.filter(pl.col(col) == sv)
        if len(count) > 0:
            print(f"Column '{col}' has {count[0, 'count']} instances of '{sv}'")
```

## Distribution Analysis

### Numerical Columns

```python
# Summary statistics
print(df.describe())

# For each numerical column, check:
for col in df.select(pl.col(pl.NUMERIC_DTYPES)).columns:
    stats = df.select([
        pl.col(col).min().alias("min"),
        pl.col(col).quantile(0.25).alias("q25"),
        pl.col(col).median().alias("median"),
        pl.col(col).mean().alias("mean"),
        pl.col(col).quantile(0.75).alias("q75"),
        pl.col(col).max().alias("max"),
        pl.col(col).std().alias("std"),
        pl.col(col).skew().alias("skew"),
    ])
    print(f"\n{col}:")
    print(stats)
    
    # Red flags:
    # - Large difference between mean and median (skewness)
    # - Min or max far from quartiles (outliers)
    # - Std = 0 (constant column)
```

### Categorical Columns

```python
# For each string/categorical column
for col in df.select(pl.col(pl.String)).columns:
    n_unique = df[col].n_unique()
    total = len(df)
    
    print(f"\n{col}:")
    print(f"  Unique values: {n_unique} ({n_unique/total*100:.1f}% of rows)")
    
    # Show top values
    print("  Top values:")
    print(df[col].value_counts().head(10))
    
    # Red flags:
    # - Very high cardinality (might be an ID column)
    # - Single value (constant column)
    # - Many low-frequency values (potential data quality issues)
```

### Date/Time Columns

```python
# For datetime columns
for col in df.select(pl.col(pl.TEMPORAL_DTYPES)).columns:
    print(f"\n{col}:")
    print(f"  Min: {df[col].min()}")
    print(f"  Max: {df[col].max()}")
    print(f"  Range: {df[col].max() - df[col].min()}")
    
    # Check for gaps in time series
    # Check for future dates (often errors)
    # Check for very old dates (often errors)
```

## Outlier Detection

### IQR Method

```python
# Detect outliers using IQR method
q1 = df[col].quantile(0.25)
q3 = df[col].quantile(0.75)
iqr = q3 - q1
lower_bound = q1 - 1.5 * iqr
upper_bound = q3 + 1.5 * iqr
outliers = df.filter((pl.col(col) < lower_bound) | (pl.col(col) > upper_bound))
print(f"'{col}': IQR bounds [{lower_bound:.2f}, {upper_bound:.2f}], {len(outliers)} outliers ({len(outliers)/len(df)*100:.1f}%)")
```

### Z-Score Method

```python
# Detect outliers using z-score method
mean = df[col].mean()
std = df[col].std()
threshold = 3.0
outliers = df.filter(((pl.col(col) - mean) / std).abs() > threshold)
print(f"'{col}': mean={mean:.2f}, std={std:.2f}, {len(outliers)} outliers with |z| > {threshold} ({len(outliers)/len(df)*100:.1f}%)")
```

### Important: Investigate Before Removing

**NEVER automatically remove outliers.** Always:
1. Examine outlier records in full
2. Understand WHY they're outliers
3. Consult domain experts if available
4. Document decision and rationale

```python
# Examine outliers in context
outliers = detect_outliers_iqr(df, "amount")
if len(outliers) > 0:
    print("\nOutlier records (examine these!):")
    print(outliers.head(10))
```

## Uniqueness and Cardinality

### Identifying Granularity

The most important question: **What does each row represent?**

```python
# Check if columns uniquely identify rows
unique_count = df.select(cols).n_unique()
is_unique = unique_count == len(df)
print(f"Columns {cols}: {unique_count:,} unique / {len(df):,} total → {'unique key' if is_unique else 'NOT unique'}")
```

Test various candidate key combinations:

```python
for cols in [["id"], ["user_id"], ["user_id", "date"], ["user_id", "product_id", "timestamp"]]:
    unique_count = df.select(cols).n_unique()
    is_unique = unique_count == len(df)
    print(f"Columns {cols}: {unique_count:,} unique / {len(df):,} total → {'unique key' if is_unique else 'NOT unique'}")
```

### Duplicate Detection

```python
# Check for exact duplicate rows
n_duplicates = len(df) - len(df.unique())
print(f"Exact duplicate rows: {n_duplicates}")

# If duplicates exist, examine them
if n_duplicates > 0:
    # Find duplicate rows
    dup_counts = df.group_by(df.columns).len().filter(pl.col("len") > 1)
    print(f"\nDuplicate patterns ({len(dup_counts)} groups):")
    print(dup_counts.head(10))
```

### Cardinality Analysis

| Cardinality Level | Typical Use | Example |
|-------------------|-------------|---------|
| 1 (constant) | Often useless, remove | All values are "USA" |
| Very low (2-10) | Binary/categorical | Gender, Status |
| Low (10-100) | Categorical | Category, Region |
| Medium (100-10k) | High-cardinality categorical | City, Product |
| High (>10k or unique) | ID column or free text | User ID, Comments |

```python
# Cardinality summary
print("Cardinality analysis:")
for col in df.columns:
    n_unique = df[col].n_unique()
    pct_unique = n_unique / len(df) * 100
    
    if n_unique == 1:
        category = "CONSTANT (consider removing)"
    elif n_unique == 2:
        category = "Binary"
    elif n_unique <= 10:
        category = "Low cardinality"
    elif n_unique <= 100:
        category = "Medium cardinality"
    elif pct_unique > 90:
        category = "HIGH (possible ID column)"
    else:
        category = "High cardinality"
    
    print(f"  {col}: {n_unique} unique ({pct_unique:.1f}%) - {category}")
```

## Correlation Analysis

### Numerical Correlations

```python
# Pearson correlation for numerical columns
numeric_cols = df.select(pl.col(pl.NUMERIC_DTYPES)).columns
if len(numeric_cols) > 1:
    # Polars correlation
    corr_matrix = df.select(numeric_cols).corr()
    print("Correlation matrix:")
    print(corr_matrix)
    
    # Flag high correlations (potential multicollinearity)
    # Threshold typically 0.7-0.9
    threshold = 0.7
    print(f"\nHighly correlated pairs (|r| > {threshold}):")
    # ... extract pairs above threshold
```

### Categorical Associations

For categorical columns, examine cross-tabulations:

```python
# Cross-tabulation
ct = df.group_by([col1, col2]).len().pivot(on=col2, index=col1, values="len").fill_null(0)
print(ct)
```

## Automated Profiling Tools

For comprehensive automated profiling:

### ydata-profiling (formerly pandas-profiling)

```python
# Requires: pip install ydata-profiling
from ydata_profiling import ProfileReport

# Note: Requires pandas DataFrame
profile = ProfileReport(df.to_pandas(), title="Data Profile", explorative=True)
profile.to_file("data_profile.html")

# For large datasets, use minimal mode
profile = ProfileReport(df.to_pandas(), minimal=True)
```

### Manual Profiling Summary

If automated tools unavailable, generate this summary:

```python
# Generate a quick profile summary
print(f"Shape: {df.shape}")
print(f"Columns: {df.columns}")
for col in df.columns:
    dtype = df[col].dtype
    nulls = df[col].null_count()
    uniques = df[col].n_unique()
    print(f"  {col}: {dtype}, {nulls} nulls, {uniques} unique")
print(f"\nNumeric summary:\n{df.select(pl.col(pl.NUMERIC_DTYPES)).describe()}")
```

## Red Flags Checklist

After completing EDA, check for these red flags:

- [ ] **High missingness** (>10%) in critical columns
- [ ] **Unexpected data types** (dates as strings, numbers as strings)
- [ ] **Constant columns** (only one unique value)
- [ ] **Near-constant columns** (one value dominates 99%+)
- [ ] **Unexpected duplicates** (should be unique but isn't)
- [ ] **Extreme outliers** (values orders of magnitude different)
- [ ] **Future dates** (often data entry errors)
- [ ] **Negative values** where only positive expected
- [ ] **High cardinality** where low expected (possible ID column mixed in)
- [ ] **Low cardinality** where high expected (possible data truncation)
- [ ] **Suspicious value distributions** (too perfect, too uniform)
- [ ] **Inconsistent encodings** (same thing represented differently)
