---
name: time-series-guide
description: "Apply ARIMA, VAR, cointegration, and time series econometric methods"
metadata:
  openclaw:
    emoji: "📉"
    category: "analysis"
    subcategory: "econometrics"
    keywords: ["time series", "ARIMA", "VAR", "cointegration", "stationarity", "forecasting", "econometrics"]
    source: "wentor-research-plugins"
---

# Time Series Guide

A skill for applying time series econometric methods including ARIMA modeling, VAR systems, cointegration analysis, and unit root tests. Covers stationarity concepts, model selection, forecasting, and diagnostic checking for economic and financial data.

## Stationarity and Unit Root Tests

### Why Stationarity Matters

A time series is stationary when its statistical properties (mean, variance, autocorrelation) do not change over time. Most econometric methods require stationarity. Non-stationary series can produce spurious regressions.

### Testing for Stationarity

```python
from statsmodels.tsa.stattools import adfuller, kpss
import pandas as pd


def test_stationarity(series: pd.Series, name: str = "Series") -> dict:
    """
    Test for stationarity using ADF and KPSS tests.

    Args:
        series: Time series data
        name: Label for the series
    """
    # Augmented Dickey-Fuller test
    # H0: Unit root exists (non-stationary)
    adf_result = adfuller(series.dropna(), autolag="AIC")

    # KPSS test
    # H0: Series is stationary
    kpss_result = kpss(series.dropna(), regression="c", nlags="auto")

    return {
        "series": name,
        "adf": {
            "statistic": adf_result[0],
            "p_value": adf_result[1],
            "lags_used": adf_result[2],
            "conclusion": (
                "Stationary (reject unit root)"
                if adf_result[1] < 0.05
                else "Non-stationary (fail to reject unit root)"
            )
        },
        "kpss": {
            "statistic": kpss_result[0],
            "p_value": kpss_result[1],
            "conclusion": (
                "Non-stationary (reject stationarity)"
                if kpss_result[1] < 0.05
                else "Stationary (fail to reject stationarity)"
            )
        }
    }
```

### Making a Series Stationary

```
Method 1: Differencing
  y_diff = y_t - y_{t-1}           (first difference)
  y_diff2 = delta(y_diff)          (second difference, rarely needed)

Method 2: Log transformation + differencing
  y_log = log(y_t)                 (stabilizes variance)
  y_return = log(y_t) - log(y_{t-1})  (log returns)

Method 3: Detrending
  Subtract a fitted trend (linear, polynomial, or HP filter)
```

## ARIMA Modeling

### Model Structure

```
ARIMA(p, d, q):
  p = order of autoregressive (AR) component
  d = degree of differencing
  q = order of moving average (MA) component

SARIMA(p, d, q)(P, D, Q, s):
  Seasonal extension with period s
  P, D, Q = seasonal AR, differencing, MA orders
```

### Model Selection and Fitting

```python
from statsmodels.tsa.arima.model import ARIMA
import numpy as np


def fit_arima(series: pd.Series, order: tuple = None) -> dict:
    """
    Fit an ARIMA model, optionally using auto-selection.

    Args:
        series: Time series data
        order: (p, d, q) tuple; if None, uses AIC-based selection
    """
    if order is None:
        # Grid search over common orders
        best_aic = np.inf
        best_order = (0, 0, 0)
        for p in range(4):
            for d in range(3):
                for q in range(4):
                    try:
                        model = ARIMA(series, order=(p, d, q))
                        result = model.fit()
                        if result.aic < best_aic:
                            best_aic = result.aic
                            best_order = (p, d, q)
                    except Exception:
                        continue
        order = best_order

    model = ARIMA(series, order=order)
    result = model.fit()

    return {
        "order": order,
        "aic": result.aic,
        "bic": result.bic,
        "coefficients": dict(zip(result.param_names, result.params)),
        "residual_diagnostics": {
            "ljung_box_p": float(
                result.test_serial_correlation("ljungbox", lags=[10])[0]["lb_pvalue"].iloc[0]
            )
        }
    }
```

## Vector Autoregression (VAR)

### Multivariate Time Series

```python
from statsmodels.tsa.api import VAR


def fit_var_model(data: pd.DataFrame, maxlags: int = 12) -> dict:
    """
    Fit a VAR model to multivariate time series data.

    Args:
        data: DataFrame with multiple time series columns
        maxlags: Maximum lag order to consider
    """
    model = VAR(data)

    # Select lag order by information criteria
    lag_selection = model.select_order(maxlags=maxlags)
    optimal_lag = lag_selection.aic

    result = model.fit(optimal_lag)

    return {
        "lag_order": optimal_lag,
        "aic": result.aic,
        "variables": list(data.columns),
        "granger_causality": "Use result.test_causality() for pairwise tests",
        "irf": "Use result.irf(periods=20) for impulse response functions"
    }
```

### Granger Causality

Granger causality tests whether past values of variable X improve forecasts of variable Y beyond what past values of Y alone provide. It is a test of predictive precedence, not true causation.

## Cointegration Analysis

### Engle-Granger and Johansen Tests

```python
from statsmodels.tsa.stattools import coint
from statsmodels.tsa.vector_ar.vecm import coint_johansen


def test_cointegration(y1: pd.Series, y2: pd.Series) -> dict:
    """
    Test for cointegration between two series.

    Args:
        y1: First time series
        y2: Second time series
    """
    # Engle-Granger two-step test
    eg_stat, eg_pvalue, eg_crit = coint(y1, y2)

    return {
        "engle_granger": {
            "statistic": eg_stat,
            "p_value": eg_pvalue,
            "conclusion": (
                "Cointegrated" if eg_pvalue < 0.05
                else "Not cointegrated"
            )
        },
        "interpretation": (
            "If cointegrated, these series share a long-run equilibrium "
            "relationship. Use a Vector Error Correction Model (VECM) "
            "rather than a VAR in differences."
        )
    }
```

## Diagnostic Checking

### Model Validation Checklist

```
1. Residual autocorrelation: Ljung-Box test (should be non-significant)
2. Residual normality: Jarque-Bera test or Q-Q plot
3. Heteroskedasticity: ARCH-LM test for conditional heteroskedasticity
4. Stability: Check that AR roots lie inside the unit circle
5. Forecast accuracy: Out-of-sample RMSE, MAE, MAPE
6. Information criteria: Compare AIC/BIC across candidate models
```

Report all diagnostic results in your paper. Reviewers expect evidence that residuals are well-behaved and that the chosen model specification is justified by information criteria and domain knowledge.
