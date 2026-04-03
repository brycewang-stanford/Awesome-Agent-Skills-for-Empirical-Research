---
name: data-anomaly-detection
description: "Detect anomalies and outliers in research data using statistical methods"
metadata:
  openclaw:
    emoji: "🔎"
    category: "analysis"
    subcategory: "statistics"
    keywords: ["anomaly detection", "outlier detection", "data quality", "statistical testing", "robust statistics"]
    source: "wentor-research-plugins"
---

# Data Anomaly Detection

A skill for identifying anomalies, outliers, and suspicious patterns in research datasets. Combines classical statistical methods with modern machine learning approaches to flag data points that deviate significantly from expected distributions, helping researchers maintain data integrity and uncover genuine scientific findings.

## Overview

Anomalous data points in research datasets can arise from measurement errors, instrument malfunction, data entry mistakes, or genuine rare phenomena. Distinguishing between these sources is critical: blindly removing outliers can bias results, while ignoring measurement errors introduces noise. This skill provides a structured framework for detecting, classifying, and handling anomalies in univariate, multivariate, and time-series research data.

The approach follows a three-stage pipeline: detection (flagging candidate anomalies), diagnosis (determining likely cause), and decision (remove, transform, or retain with justification). Every decision is logged for reproducibility and transparent reporting.

## Statistical Detection Methods

### Univariate Outlier Detection

```python
import numpy as np
from scipy import stats

def detect_univariate_outliers(data: np.ndarray, method: str = 'iqr') -> dict:
    """
    Detect outliers using classical univariate methods.

    Methods:
        'iqr': Interquartile range (1.5x IQR rule)
        'zscore': Z-score threshold (|z| > 3)
        'mad': Median absolute deviation (robust)
        'grubbs': Grubbs' test for single outlier
    """
    results = {'method': method, 'n_total': len(data)}

    if method == 'iqr':
        q1, q3 = np.percentile(data, [25, 75])
        iqr = q3 - q1
        lower, upper = q1 - 1.5 * iqr, q3 + 1.5 * iqr
        mask = (data < lower) | (data > upper)

    elif method == 'zscore':
        z = np.abs(stats.zscore(data))
        mask = z > 3

    elif method == 'mad':
        median = np.median(data)
        mad = np.median(np.abs(data - median))
        modified_z = 0.6745 * (data - median) / mad if mad > 0 else np.zeros_like(data)
        mask = np.abs(modified_z) > 3.5

    elif method == 'grubbs':
        # Grubbs' test for the single most extreme value
        n = len(data)
        mean, sd = np.mean(data), np.std(data, ddof=1)
        g = np.max(np.abs(data - mean)) / sd
        t_crit = stats.t.ppf(1 - 0.05 / (2 * n), n - 2)
        g_crit = ((n - 1) / np.sqrt(n)) * np.sqrt(t_crit**2 / (n - 2 + t_crit**2))
        mask = np.abs(data - mean) / sd >= g_crit

    results['outlier_indices'] = np.where(mask)[0].tolist()
    results['n_outliers'] = int(mask.sum())
    results['pct_outliers'] = round(mask.sum() / len(data) * 100, 2)
    return results
```

### Multivariate Outlier Detection

```python
from sklearn.covariance import EllipticEnvelope
from sklearn.ensemble import IsolationForest

def detect_multivariate_outliers(X: np.ndarray, method: str = 'mahalanobis') -> dict:
    """
    Detect multivariate outliers using distance-based and model-based methods.
    """
    if method == 'mahalanobis':
        detector = EllipticEnvelope(contamination=0.05, random_state=42)
        labels = detector.fit_predict(X)  # -1 = outlier, 1 = inlier

    elif method == 'isolation_forest':
        detector = IsolationForest(
            n_estimators=100, contamination=0.05, random_state=42
        )
        labels = detector.fit_predict(X)

    outlier_mask = labels == -1
    return {
        'method': method,
        'outlier_indices': np.where(outlier_mask)[0].tolist(),
        'n_outliers': int(outlier_mask.sum()),
        'contamination_assumed': 0.05
    }
```

## Diagnosis Framework

Once candidate anomalies are flagged, classify each by likely cause:

| Category | Indicators | Action |
|----------|-----------|--------|
| **Measurement error** | Value physically impossible, instrument log shows malfunction | Remove with documentation |
| **Data entry error** | Obvious typo (e.g., extra digit), inconsistent units | Correct if source available, else remove |
| **Sampling artifact** | Unusual but plausible value from edge of population | Retain; use robust methods |
| **Genuine extreme** | Verified measurement, consistent with other variables | Retain; report sensitivity analysis |
| **Contamination** | Data from wrong population or experimental condition | Remove with justification |

### Diagnostic Checks

- **Cross-variable consistency**: Does the flagged value make sense given other columns for the same observation?
- **Temporal context**: For longitudinal data, is the spike consistent with known events?
- **Instrument logs**: Can the anomaly be traced to a calibration or equipment issue?
- **Domain knowledge**: Is the value within theoretically possible bounds?

## Time-Series Anomaly Detection

```python
def detect_timeseries_anomalies(series: np.ndarray, window: int = 20) -> dict:
    """
    Detect anomalies in time-series data using rolling statistics.
    """
    rolling_mean = pd.Series(series).rolling(window=window).mean()
    rolling_std = pd.Series(series).rolling(window=window).std()

    upper_bound = rolling_mean + 3 * rolling_std
    lower_bound = rolling_mean - 3 * rolling_std

    anomalies = (series > upper_bound) | (series < lower_bound)
    return {
        'anomaly_indices': np.where(anomalies)[0].tolist(),
        'n_anomalies': int(anomalies.sum()),
        'window_size': window
    }
```

## Reporting Anomaly Handling

When reporting anomaly handling in publications:

1. **State the detection method** and its parameters (e.g., "Outliers were identified using the 1.5x IQR rule").
2. **Report the number and percentage** of observations flagged.
3. **Describe the disposition**: how many were removed, corrected, or retained.
4. **Provide sensitivity analysis**: show that main conclusions hold with and without outliers.
5. **Include in supplementary materials**: full list of flagged observations and their disposition.

## References

- Rousseeuw, P. J. & Hubert, M. (2011). Robust Statistics for Outlier Detection. *WIREs Data Mining and Knowledge Discovery*, 1(1), 73-79.
- Liu, F. T., Ting, K. M., & Zhou, Z.-H. (2008). Isolation Forest. *ICDM 2008*.
- Aguinis, H., Gottfredson, R. K., & Joo, H. (2013). Best-Practice Recommendations for Defining, Identifying, and Handling Outliers. *Organizational Research Methods*, 16(2), 270-301.
