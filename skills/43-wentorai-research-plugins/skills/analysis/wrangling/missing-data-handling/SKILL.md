---
name: missing-data-handling
description: "Diagnose missing data patterns and apply appropriate imputation strategies"
metadata:
  openclaw:
    emoji: "🧩"
    category: "analysis"
    subcategory: "wrangling"
    keywords: ["missing value imputation", "missing data handling", "outlier detection", "data cleaning", "multiple imputation"]
    source: "wentor"
---

# Missing Data Handling

A skill for diagnosing missing data mechanisms, selecting appropriate imputation strategies, and conducting sensitivity analyses. Covers everything from simple imputation to multiple imputation and modern machine learning approaches.

## Missing Data Mechanisms

### Rubin's Classification

Understanding the mechanism determines the appropriate handling strategy:

| Mechanism | Definition | Example | Implication |
|-----------|-----------|---------|-------------|
| MCAR | Missingness unrelated to any variable | Lab sample randomly contaminated | Listwise deletion is unbiased (but loses power) |
| MAR | Missingness related to observed variables | Higher-income respondents skip income question less | Multiple imputation appropriate |
| MNAR | Missingness related to the missing value itself | Depressed patients drop out of depression study | Requires sensitivity analysis; no simple fix |

### Diagnosing the Mechanism

```python
import pandas as pd
import numpy as np
from scipy import stats

def diagnose_missing_data(df: pd.DataFrame) -> dict:
    """
    Diagnose missing data patterns and mechanism.
    """
    n_rows, n_cols = df.shape
    results = {
        'total_cells': n_rows * n_cols,
        'total_missing': df.isnull().sum().sum(),
        'pct_missing': (df.isnull().sum().sum() / (n_rows * n_cols)) * 100,
        'by_column': {}
    }

    for col in df.columns:
        n_missing = df[col].isnull().sum()
        pct = n_missing / n_rows * 100
        results['by_column'][col] = {
            'n_missing': n_missing,
            'pct_missing': round(pct, 2)
        }

    # Little's MCAR test approximation
    # Compare means of other variables between missing/non-missing groups
    mcar_tests = {}
    for col in df.columns:
        if df[col].isnull().sum() > 0:
            missing_mask = df[col].isnull()
            for other_col in df.select_dtypes(include=[np.number]).columns:
                if other_col != col and df[other_col].isnull().sum() == 0:
                    group_missing = df.loc[missing_mask, other_col]
                    group_observed = df.loc[~missing_mask, other_col]
                    if len(group_missing) > 1 and len(group_observed) > 1:
                        t_stat, p_val = stats.ttest_ind(group_missing, group_observed)
                        mcar_tests[f'{col}_vs_{other_col}'] = {
                            't': round(t_stat, 3),
                            'p': round(p_val, 4)
                        }

    significant_diffs = sum(1 for v in mcar_tests.values() if v['p'] < 0.05)
    results['mcar_assessment'] = (
        'Likely MCAR' if significant_diffs == 0
        else f'Likely NOT MCAR ({significant_diffs} significant differences found)'
    )
    results['mcar_tests'] = mcar_tests

    return results
```

## Imputation Methods

### Simple Imputation

```python
def simple_imputation(df: pd.DataFrame, strategy: str = 'mean') -> pd.DataFrame:
    """
    Apply simple imputation strategies.

    Args:
        strategy: 'mean', 'median', 'mode', 'constant', or 'forward_fill'
    """
    imputed = df.copy()

    for col in imputed.columns:
        if imputed[col].isnull().any():
            if strategy == 'mean' and np.issubdtype(imputed[col].dtype, np.number):
                imputed[col].fillna(imputed[col].mean(), inplace=True)
            elif strategy == 'median' and np.issubdtype(imputed[col].dtype, np.number):
                imputed[col].fillna(imputed[col].median(), inplace=True)
            elif strategy == 'mode':
                imputed[col].fillna(imputed[col].mode()[0], inplace=True)
            elif strategy == 'forward_fill':
                imputed[col].ffill(inplace=True)

    return imputed
```

### Multiple Imputation (MICE)

The gold standard for MAR data:

```python
from sklearn.experimental import enable_iterative_imputer
from sklearn.impute import IterativeImputer
from sklearn.linear_model import BayesianRidge

def multiple_imputation(df: pd.DataFrame, n_imputations: int = 20,
                         max_iter: int = 50) -> list[pd.DataFrame]:
    """
    Perform Multiple Imputation by Chained Equations (MICE).

    Args:
        df: DataFrame with missing values (numeric columns only)
        n_imputations: Number of imputed datasets (>=20 recommended)
        max_iter: Maximum iterations per imputation
    Returns:
        List of completed DataFrames
    """
    imputed_datasets = []

    for i in range(n_imputations):
        imputer = IterativeImputer(
            estimator=BayesianRidge(),
            max_iter=max_iter,
            random_state=i,
            sample_posterior=True  # Important for proper MI
        )
        imputed_data = imputer.fit_transform(df)
        imputed_df = pd.DataFrame(imputed_data, columns=df.columns, index=df.index)
        imputed_datasets.append(imputed_df)

    return imputed_datasets


def pool_mi_results(estimates: list[float], variances: list[float]) -> dict:
    """
    Pool results across multiply imputed datasets using Rubin's rules.

    Args:
        estimates: Parameter estimate from each imputed dataset
        variances: Variance of estimate from each imputed dataset
    """
    m = len(estimates)
    q_bar = np.mean(estimates)  # Pooled estimate
    u_bar = np.mean(variances)  # Within-imputation variance
    b = np.var(estimates, ddof=1)  # Between-imputation variance

    # Total variance
    total_var = u_bar + (1 + 1/m) * b

    # Degrees of freedom (Barnard-Rubin)
    lambda_hat = ((1 + 1/m) * b) / total_var
    df_old = (m - 1) / lambda_hat**2

    se = np.sqrt(total_var)
    ci = (q_bar - 1.96*se, q_bar + 1.96*se)

    return {
        'pooled_estimate': q_bar,
        'pooled_se': se,
        'ci_95': ci,
        'fraction_missing_info': lambda_hat,
        'relative_efficiency': 1 / (1 + lambda_hat/m)
    }
```

## Outlier Detection

### Statistical Methods

```python
def detect_outliers(series: pd.Series, method: str = 'iqr') -> pd.Series:
    """
    Detect outliers using specified method.

    Returns boolean mask where True indicates an outlier.
    """
    if method == 'iqr':
        q1 = series.quantile(0.25)
        q3 = series.quantile(0.75)
        iqr = q3 - q1
        lower = q1 - 1.5 * iqr
        upper = q3 + 1.5 * iqr
        return (series < lower) | (series > upper)

    elif method == 'zscore':
        z = np.abs((series - series.mean()) / series.std())
        return z > 3

    elif method == 'mad':
        median = series.median()
        mad = np.median(np.abs(series - median))
        modified_z = 0.6745 * (series - median) / (mad + 1e-10)
        return np.abs(modified_z) > 3.5

    else:
        raise ValueError(f"Unknown method: {method}")
```

## Reporting Standards

When reporting missing data handling in a paper:

1. Report the amount and pattern of missing data (by variable and overall)
2. State the assumed mechanism (MCAR/MAR/MNAR) with justification
3. Describe the imputation method and software used
4. Report the number of imputations (for MI)
5. Conduct sensitivity analyses (e.g., compare results from complete-case, single imputation, and multiple imputation)
6. Report results using Rubin's pooling rules for MI

Never simply delete missing data without justification. Even for MCAR data, listwise deletion reduces statistical power and is rarely the best choice.
