# statsmodels Time Series Reference

statsmodels v0.14.6 — syntax and library reference only.

---

## Contents

1. [ARIMA and SARIMAX](#arima-and-sarimax)
2. [VAR and VECM](#var-and-vecm)
3. [Exponential Smoothing (Holt-Winters)](#exponential-smoothing-holt-winters)
4. [State Space Models](#state-space-models)
5. [Unit Root Tests (Stationarity)](#unit-root-tests-stationarity)
6. [ACF and PACF](#acf-and-pacf)
7. [Model Selection (AIC/BIC)](#model-selection-aicbic)
8. [Forecasting](#forecasting)
9. [Stationarity Concepts Quick Reference](#stationarity-concepts-quick-reference)
10. [References and Further Reading](#references-and-further-reading)

---

## ARIMA and SARIMAX

`sm.tsa.ARIMA` fits a non-seasonal ARIMA model. `sm.tsa.SARIMAX` is the more
general class that supports both non-seasonal and seasonal components and
exogenous regressors — use SARIMAX whenever seasonality or exogenous variables
are needed.

```python
import statsmodels.api as sm

# Basic ARIMA(p, d, q)
model = sm.tsa.ARIMA(y, order=(1, 1, 1))
results = model.fit()
print(results.summary())

# SARIMAX — ARIMA with seasonal component
model = sm.tsa.SARIMAX(
    y,
    order=(1, 1, 1),              # (p, d, q) non-seasonal
    seasonal_order=(1, 1, 1, 12)  # (P, D, Q, s) seasonal
)
results = model.fit()
```

**`order=(p, d, q)` — non-seasonal parameters:**
- `p`: number of autoregressive (AR) lags
- `d`: order of differencing (0 = no differencing, 1 = first difference)
- `q`: number of moving-average (MA) lags

**`seasonal_order=(P, D, Q, s)` — seasonal parameters:**
- `P`: seasonal AR lags
- `D`: seasonal differencing order
- `Q`: seasonal MA lags
- `s`: seasonal period (e.g., 12 for monthly data with annual seasonality, 4 for quarterly)

**Exogenous variables:**

```python
# Passing exogenous regressors (X must align with y in length)
model = sm.tsa.SARIMAX(y, exog=X, order=(1, 1, 1))
results = model.fit()

# Forecast with future exog values
future_exog = X_future  # must have `steps` rows
forecast = results.forecast(steps=12, exog=future_exog)
```

**Key constructor parameters:**

| Parameter | Default | Notes |
|-----------|---------|-------|
| `enforce_stationarity` | `True` | Enforces stationary AR polynomial |
| `enforce_invertibility` | `True` | Enforces invertible MA polynomial |
| `trend` | `None` | `'c'` = constant, `'t'` = linear trend, `'ct'` = both, `'n'` = none |
| `concentrate_scale` | `False` | Concentrate scale out of likelihood (faster) |
| `time_varying_regression` | `False` | Treat exog coefficients as time-varying |

```python
# ARIMA with a constant term
model = sm.tsa.SARIMAX(y, order=(1, 1, 1), trend='c')

# SARIMAX with linear trend and exog
model = sm.tsa.SARIMAX(y, exog=X, order=(1, 1, 1),
                        seasonal_order=(1, 1, 0, 12), trend='ct')
results = model.fit(disp=False)  # suppress convergence output
```

**`fit()` keyword arguments:**
- `disp=False`: suppress optimizer output
- `method='lbfgs'`: optimizer (default); alternatives: `'nm'`, `'bfgs'`, `'powell'`
- `maxiter=50`: maximum optimizer iterations (default)
- `cov_type='opg'`: covariance estimator (`'opg'`, `'oim'`, `'approx'`, `'robust'`)

**Useful results attributes:**

```python
results.aic          # Akaike Information Criterion
results.bic          # Bayesian Information Criterion
results.hqic         # Hannan-Quinn Information Criterion
results.llf          # Log-likelihood
results.params       # Parameter estimates (Series)
results.pvalues      # p-values for parameter estimates
results.resid        # Residuals
results.fittedvalues # In-sample fitted values
results.summary()    # Full summary table
```

**Residual diagnostics:**

```python
# Plot residual diagnostics (4-panel: standardized residuals, histogram,
# Q-Q plot, correlogram)
results.plot_diagnostics(figsize=(12, 8))
import matplotlib.pyplot as plt
plt.savefig("diagnostics.png", dpi=300, bbox_inches='tight')
plt.close()

# Ljung-Box test for residual autocorrelation
from statsmodels.stats.diagnostic import acorr_ljungbox
lb_result = acorr_ljungbox(results.resid, lags=[10, 20], return_df=True)
print(lb_result)
# lb_stat: test statistic; lb_pvalue: p-value (want > 0.05 for white noise)
```

---

## VAR and VECM

### VAR (Vector Autoregression)

VAR models multiple interrelated time series jointly. Input `y` is a DataFrame
or 2D array with one column per variable. All series are treated symmetrically —
each variable is regressed on its own lags and the lags of all other variables.

```python
import statsmodels.api as sm

# y is a DataFrame or 2D array with multiple columns (one per variable)
model = sm.tsa.VAR(y)

# Select optimal lag order
lag_order = model.select_order(maxlags=12)
print(lag_order.summary())  # Shows AIC, BIC, HQIC, FPE for each lag

# Fit with lag selected by information criterion
results = model.fit(maxlags=4, ic='aic')

# Fit with an explicit lag count
results = model.fit(4)
```

**Lag selection criteria available in `select_order`:**
- `'aic'`, `'bic'`, `'hqic'`: information criteria (lower = better)
- `'fpe'`: Final Prediction Error

```python
# Access the selected lag count
selected_lag = lag_order.selected_orders['aic']
results = model.fit(selected_lag)
```

**VAR results attributes and methods:**

```python
results.k_ar                    # Fitted lag order
results.params                  # Parameter matrix
results.sigma_u                 # Residual covariance matrix
results.aic                     # AIC
results.bic                     # BIC

# Impulse response functions
irf = results.irf(periods=10)
irf.plot(orth=False)            # Non-orthogonalized IRF
irf.plot(orth=True)             # Cholesky-orthogonalized IRF
import matplotlib.pyplot as plt
plt.savefig("irf.png", dpi=300, bbox_inches='tight')
plt.close()

# Forecast error variance decomposition
fevd = results.fevd(periods=10)
fevd.plot()
plt.savefig("fevd.png", dpi=300, bbox_inches='tight')
plt.close()

# Granger causality test
# H0: 'causing' variable does not Granger-cause 'caused' variable
gc_result = results.test_causality('gdp', causing='inflation', kind='f')
print(gc_result.summary())
# Access p-value: gc_result.pvalue

# Out-of-sample forecast
# Must pass the last k_ar observations as the initial values
forecast_input = y.values[-results.k_ar:]  # shape (k_ar, n_variables)
forecast = results.forecast(forecast_input, steps=5)  # numpy array
# Shape: (steps, n_variables)

# Forecast with confidence intervals
forecast, lower, upper = results.forecast_interval(
    forecast_input, steps=5, alpha=0.05
)

# Stability check (all eigenvalues inside unit circle)
results.is_stable()             # returns bool
```

**Normality and serial correlation tests:**

```python
# Test for serial correlation in residuals
serial_result = results.test_whiteness(nlags=10)
print(serial_result.summary())

# Test for normality of residuals
norm_result = results.test_normality()
print(norm_result.summary())
```

### VECM (Vector Error Correction Model)

VECM is appropriate when series are cointegrated (individually non-stationary
but a linear combination is stationary). Run the Johansen test first to
determine cointegration rank.

```python
from statsmodels.tsa.vector_ar.vecm import VECM, coint_johansen

# Johansen cointegration test
# det_order: -1 = no constant, 0 = constant outside CI, 1 = constant in CI
# k_ar_diff: number of lagged differences
coint_result = coint_johansen(data, det_order=0, k_ar_diff=2)

# Trace and max-eigenvalue statistics
print(coint_result.lr1)           # Trace statistics
print(coint_result.lr2)           # Maximum eigenvalue statistics
print(coint_result.cvt)           # Trace critical values (90%, 95%, 99%)
print(coint_result.cvm)           # Max-eigenvalue critical values
print(coint_result.eig)           # Eigenvalues
print(coint_result.evec)          # Eigenvectors (cointegrating vectors)

# Fit VECM
# coint_rank: number of cointegrating relations (from Johansen test)
model = VECM(data, k_ar_diff=2, coint_rank=1)
results = model.fit()
print(results.summary())

# Impulse response from VECM
irf = results.irf(10)
irf.plot()
```

**VECM key parameters:**

| Parameter | Notes |
|-----------|-------|
| `k_ar_diff` | Number of lagged differences (analogous to VAR lag minus 1) |
| `coint_rank` | Number of cointegrating vectors (from Johansen test) |
| `deterministic` | `'n'` = no deterministic, `'co'` = constant outside, `'ci'` = constant inside, `'lo'` = linear outside, `'li'` = linear inside |
| `seasons` | Seasonal period for deterministic seasonals (0 = none) |

---

## Exponential Smoothing (Holt-Winters)

### ExponentialSmoothing

```python
import statsmodels.api as sm

# Simple exponential smoothing (no trend, no seasonality)
model = sm.tsa.ExponentialSmoothing(
    y,
    trend=None,
    seasonal=None
)
results = model.fit()

# Holt's linear trend (no seasonality)
model = sm.tsa.ExponentialSmoothing(
    y,
    trend='add',        # 'add' (additive) or 'mul' (multiplicative)
    seasonal=None
)
results = model.fit()

# Holt-Winters (trend + seasonal)
model = sm.tsa.ExponentialSmoothing(
    y,
    trend='add',
    seasonal='add',      # 'add' or 'mul'
    seasonal_periods=12  # periods per seasonal cycle
)
results = model.fit(optimized=True)  # optimize smoothing parameters
```

**Key parameters:**

| Parameter | Values | Notes |
|-----------|--------|-------|
| `trend` | `None`, `'add'`, `'mul'` | `None` = no trend; `'mul'` requires strictly positive data |
| `seasonal` | `None`, `'add'`, `'mul'` | `None` = no seasonality |
| `seasonal_periods` | int | Required when `seasonal` is not `None` |
| `damped_trend` | `True`/`False` | Dampens trend toward flat; prevents overforecasting long-horizon |
| `use_boxcox` | `True`/`False`/float | Box-Cox transformation for variance stabilization; `True` = estimate lambda |
| `initialization_method` | `'estimated'`, `'heuristic'`, `'legacy-heuristic'`, `'known'` | How initial states are set |
| `initial_level` | float | Used when `initialization_method='known'` |
| `initial_trend` | float | Used when `initialization_method='known'` |
| `initial_seasonal` | array-like | Used when `initialization_method='known'` |

**`fit()` keyword arguments:**

| Parameter | Notes |
|-----------|-------|
| `optimized=True` | Automatically optimize smoothing parameters (default True) |
| `smoothing_level` | alpha — level smoothing (0–1); ignored if `optimized=True` |
| `smoothing_trend` | beta — trend smoothing (0–1) |
| `smoothing_seasonal` | gamma — seasonal smoothing (0–1) |
| `damping_trend` | phi — damping factor (0–1); only used if `damped_trend=True` |
| `remove_bias` | `True` to adjust forecasts to remove bias |

```python
# Damped multiplicative Holt-Winters
model = sm.tsa.ExponentialSmoothing(
    y,
    trend='add',
    damped_trend=True,
    seasonal='mul',
    seasonal_periods=12,
    use_boxcox=True
)
results = model.fit(optimized=True)

# Inspect fitted smoothing parameters
print(f"alpha: {results.params['smoothing_level']:.4f}")
print(f"beta:  {results.params['smoothing_trend']:.4f}")
print(f"gamma: {results.params['smoothing_seasonal']:.4f}")
print(f"phi:   {results.params['damping_trend']:.4f}")

# Forecast
forecast = results.forecast(steps=12)

# Simulation-based prediction intervals
sim = results.simulate(
    nsimulations=12,
    repetitions=1000,
    anchor='end',       # 'start', 'end', or integer index
    random_errors='bootstrap'  # 'bootstrap' or None (Gaussian)
)
# sim shape: (nsimulations, repetitions)
import numpy as np
lower = np.percentile(sim, 2.5, axis=1)
upper = np.percentile(sim, 97.5, axis=1)
```

### ETSModel (State Space ETS)

`ETSModel` is the state space formulation of ETS. Unlike `ExponentialSmoothing`,
it provides true likelihood-based inference and information criteria.

```python
model = sm.tsa.ETSModel(
    y,
    error='add',        # 'add' or 'mul'
    trend='add',        # 'add', 'mul', or None
    damped_trend=False,
    seasonal='add',     # 'add', 'mul', or None
    seasonal_periods=12
)
results = model.fit(disp=False)

# ETS model has proper AIC/BIC
print(results.aic)
print(results.bic)

# Forecast with prediction intervals from state space
pred = results.get_prediction(start=len(y), end=len(y) + 11)
pred_summary = pred.summary_frame(alpha=0.05)
# Columns: mean, mean_se, mean_ci_lower, mean_ci_upper
```

**When to prefer ETSModel over ExponentialSmoothing:**
- When you need valid AIC/BIC for model comparison
- When you need likelihood-based prediction intervals (not simulation)
- When comparing ETS against ARIMA models using information criteria

---

## State Space Models

### Unobserved Components Model

Structural decomposition of a time series into trend, seasonal, cycle, and
irregular components using a state space framework.

```python
model = sm.tsa.UnobservedComponents(
    y,
    level='local linear trend',  # specification for level/trend component
    seasonal=12,                  # seasonal period (or None)
    cycle=True,                   # include stochastic cycle
    stochastic_level=True,        # allow level to have stochastic drift
    stochastic_trend=True,        # allow slope to vary stochastically
    stochastic_seasonal=True      # allow seasonal to evolve stochastically
)
results = model.fit(disp=False)
print(results.summary())
```

**`level` specification options:**

| Value | Description |
|-------|-------------|
| `'irregular'` | White noise only (no level component) |
| `'fixed intercept'` | Constant level, no variation |
| `'deterministic constant'` | Alias for fixed intercept |
| `'local level'` | Random walk level (Kalman filter) |
| `'random walk'` | Alias for local level |
| `'local linear trend'` | Level + stochastic slope (Harvey's BSM) |
| `'smooth trend'` | Level + deterministic slope |
| `'random walk with drift'` | Random walk with fixed drift |

```python
# Access decomposed components
results.states.smoothed  # DataFrame: level, trend, seasonal, cycle, etc.

# Plot decomposition
fig = results.plot_components(figsize=(10, 10))
import matplotlib.pyplot as plt
plt.savefig("components.png", dpi=300, bbox_inches='tight')
plt.close()

# Forecast
pred = results.get_forecast(steps=12)
pred_ci = pred.conf_int(alpha=0.05)
```

**With exogenous regressors:**

```python
model = sm.tsa.UnobservedComponents(
    y,
    level='local linear trend',
    exog=X
)
results = model.fit(disp=False)
```

### Dynamic Factor Model

Extracts latent factors common to multiple time series. Useful for dimension
reduction and index construction.

```python
model = sm.tsa.DynamicFactor(
    data,           # DataFrame or 2D array: T x n_series
    k_factors=2,    # number of latent factors to extract
    factor_order=1  # AR order governing factor dynamics
)
results = model.fit(disp=False)

# Extracted factor estimates
factors = results.factors.filtered   # T x k_factors array
# or
factors_smoothed = results.factors.smoothed

# Factor loadings
print(results.params)
```

**DynamicFactorMQ** (mixed-frequency, missing data):

```python
# For mixed-frequency data (e.g., monthly + quarterly)
model = sm.tsa.DynamicFactorMQ(
    data,
    factors=1,
    factor_orders=1
)
results = model.fit(disp=False)
```

### Generic State Space Models

For custom state space specifications:

```python
# MLEModel base class — subclass for custom models
# Most users will not need this directly; use SARIMAX/UCM/DFM instead.
# See statsmodels documentation for the custom state space API.
```

---

## Unit Root Tests (Stationarity)

### Augmented Dickey-Fuller (ADF)

```python
from statsmodels.tsa.stattools import adfuller

result = adfuller(y, maxlag=None, regression='c', autolag='AIC')
adf_stat, p_value, n_lags, n_obs, crit_values, icbest = result

print(f"ADF statistic:   {adf_stat:.4f}")
print(f"p-value:         {p_value:.4f}")
print(f"Lags used:       {n_lags}")
print(f"Observations:    {n_obs}")
print(f"Critical values: {crit_values}")
# crit_values is a dict: {'1%': ..., '5%': ..., '10%': ...}
```

- **H0:** series has a unit root (non-stationary)
- Reject H0 when p-value < 0.05 → evidence for stationarity
- Test statistic more negative than critical value → reject H0

**`regression` options:**

| Value | Includes |
|-------|----------|
| `'c'` | Constant only (default) |
| `'ct'` | Constant and linear trend |
| `'ctt'` | Constant, linear and quadratic trend |
| `'n'` | No constant or trend |

**`autolag` options:**
- `'AIC'` (default): select lags minimizing AIC
- `'BIC'`: select lags minimizing BIC
- `'t-stat'`: sequential t-test lag selection
- `None`: use `maxlag` directly

### KPSS (Kwiatkowski-Phillips-Schmidt-Shin)

```python
from statsmodels.tsa.stattools import kpss

stat, p_value, n_lags, crit_values = kpss(y, regression='c', nlags='auto')

print(f"KPSS statistic:  {stat:.4f}")
print(f"p-value:         {p_value:.4f}")
print(f"Lags used:       {n_lags}")
print(f"Critical values: {crit_values}")
```

- **H0:** series is stationary (opposite of ADF)
- Reject H0 when p-value < 0.05 → evidence for non-stationarity

**`regression` options:**
- `'c'`: test for stationarity around a constant (level stationarity)
- `'ct'`: test for stationarity around a deterministic trend (trend stationarity)

**`nlags` options:**
- `'auto'` (default): Hobijn et al. bandwidth selection
- `'legacy'`: older statsmodels bandwidth rule
- integer: explicit number of lags

**Combined ADF + KPSS interpretation:**

| ADF result | KPSS result | Interpretation |
|------------|-------------|----------------|
| Reject H0 (p < 0.05) | Fail to reject H0 (p > 0.05) | Stationary |
| Fail to reject H0 (p > 0.05) | Reject H0 (p < 0.05) | Non-stationary (unit root) |
| Reject H0 | Reject H0 | Trend-stationary (deterministic trend; consider detrending) |
| Fail to reject H0 | Fail to reject H0 | Inconclusive |

```python
# Standard workflow: apply both tests
from statsmodels.tsa.stattools import adfuller, kpss

adf = adfuller(y, regression='c', autolag='AIC')
kp = kpss(y, regression='c', nlags='auto')

print(f"ADF p-value:  {adf[1]:.4f}  (H0: unit root)")
print(f"KPSS p-value: {kp[1]:.4f}  (H0: stationary)")
```

### Zivot-Andrews Breakpoint Unit Root Test

```python
from statsmodels.tsa.stattools import zivot_andrews

# Tests for unit root allowing for a single structural break
zastat, pvalue, cvdict, baselag, basebreak = zivot_andrews(
    y, trim=0.15, maxlag=None, regression='c', autolag=None
)
print(f"ZA statistic: {zastat:.4f}, p-value: {pvalue:.4f}")
print(f"Breakpoint index: {basebreak}")
```

---

## ACF and PACF

### Computing ACF and PACF Values

```python
from statsmodels.tsa.stattools import acf, pacf

# ACF: correlation between y_t and y_{t-k} for k = 0, 1, ..., nlags
acf_values, acf_confint = acf(y, nlags=20, fft=True, alpha=0.05)
# acf_confint shape: (nlags+1, 2) — lower and upper bounds

# PACF: partial correlation at each lag (controlling for intervening lags)
pacf_values, pacf_confint = pacf(y, nlags=20, method='ywm', alpha=0.05)
```

**`acf()` parameters:**

| Parameter | Default | Notes |
|-----------|---------|-------|
| `nlags` | 40 | Number of lags to compute |
| `fft` | `True` | Use FFT for speed (recommended for large series) |
| `alpha` | `None` | If set, returns confidence intervals as second return value |
| `missing` | `'none'` | How to handle NaN: `'none'`, `'raise'`, `'conservative'`, `'drop'` |

**`pacf()` estimation methods:**

| Method | Notes |
|--------|-------|
| `'ywm'` | Yule-Walker (modified), default |
| `'yw'` | Yule-Walker (unbiased) |
| `'ols'` | OLS regression at each lag |
| `'ols-inefficient'` | OLS without heteroskedasticity correction |
| `'ld'` | Levinson-Durbin recursion |
| `'ldb'` | Levinson-Durbin with bias correction |

### Plotting ACF and PACF

```python
from statsmodels.graphics.tsaplots import plot_acf, plot_pacf
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 2, figsize=(12, 4))
plot_acf(y, lags=20, ax=axes[0], title='ACF')
plot_pacf(y, lags=20, ax=axes[1], title='PACF', method='ywm')
plt.tight_layout()
plt.savefig("acf_pacf.png", dpi=300, bbox_inches='tight')
plt.close()
```

**`plot_acf` / `plot_pacf` common parameters:**

| Parameter | Default | Notes |
|-----------|---------|-------|
| `lags` | None | Number of lags (or array of lag values) |
| `alpha` | 0.05 | Confidence interval level (shaded region) |
| `zero` | `True` | Include lag 0 in plot |
| `title` | auto | Plot title |
| `ax` | None | Matplotlib axis to plot on |

### Interpreting ACF/PACF for ARIMA Order Selection

| Pattern | ACF | PACF | Suggested Model |
|---------|-----|------|-----------------|
| AR(p) | Tails off (gradual decay) | Cuts off after lag p | ARIMA(p, d, 0) |
| MA(q) | Cuts off after lag q | Tails off (gradual decay) | ARIMA(0, d, q) |
| ARMA(p, q) | Tails off | Tails off | ARIMA(p, d, q) — use AIC/BIC to select |
| Seasonal AR(P) | Spikes at multiples of s, decay | Spike at lag s, then cuts off | Seasonal AR component |
| Seasonal MA(Q) | Spike at lag s, then cuts off | Spikes at multiples of s, decay | Seasonal MA component |

Differenced series with `d=1`:

```python
import numpy as np
y_diff = np.diff(y)  # or y.diff().dropna() for pandas Series
fig, axes = plt.subplots(1, 2, figsize=(12, 4))
plot_acf(y_diff, lags=20, ax=axes[0])
plot_pacf(y_diff, lags=20, ax=axes[1])
plt.tight_layout()
plt.savefig("acf_pacf_diff.png", dpi=300, bbox_inches='tight')
plt.close()
```

---

## Model Selection (AIC/BIC)

### Grid Search over ARIMA Orders

```python
import statsmodels.api as sm
import pandas as pd

results_list = []
for p in range(4):
    for q in range(4):
        try:
            model = sm.tsa.ARIMA(y, order=(p, 1, q))
            res = model.fit(disp=False)
            results_list.append({
                'order': (p, 1, q),
                'aic': res.aic,
                'bic': res.bic,
                'hqic': res.hqic,
                'llf': res.llf
            })
        except Exception:
            continue  # skip non-convergent or invalid models

comparison = pd.DataFrame(results_list).sort_values('aic')
print(comparison.head(10))
```

- **Lower AIC/BIC = better** (penalizes complexity)
- AIC penalizes complexity less; tends to select larger models
- BIC penalizes complexity more strongly; preferable for larger samples
- HQIC (Hannan-Quinn) is intermediate

### Grid Search over SARIMAX Orders

```python
import itertools

p_range = range(3)
q_range = range(3)
P_range = range(2)
Q_range = range(2)
s = 12  # seasonal period

results_list = []
for p, q, P, Q in itertools.product(p_range, q_range, P_range, Q_range):
    try:
        model = sm.tsa.SARIMAX(
            y,
            order=(p, 1, q),
            seasonal_order=(P, 1, Q, s),
            enforce_stationarity=True,
            enforce_invertibility=True
        )
        res = model.fit(disp=False)
        results_list.append({
            'order': (p, 1, q),
            'seasonal_order': (P, 1, Q, s),
            'aic': res.aic,
            'bic': res.bic
        })
    except Exception:
        continue

comparison = pd.DataFrame(results_list).sort_values('aic')
print(comparison.head(10))
```

### Accessing Information Criteria from Results

```python
# Available on all ARIMA/SARIMAX/ETS/UCM/VAR results objects
results.aic    # Akaike Information Criterion
results.bic    # Bayesian Information Criterion
results.hqic   # Hannan-Quinn Information Criterion (ARIMA/SARIMAX)
results.llf    # Log-likelihood (for manual AIC/BIC computation)

# Manual formula (for reference):
# AIC = -2 * llf + 2 * k
# BIC = -2 * llf + k * log(n)
# where k = number of parameters, n = number of observations
```

---

## Forecasting

### Out-of-Sample Forecast (Point Only)

```python
# Returns a pandas Series of point forecasts
forecast = results.forecast(steps=12)
```

### Forecast with Confidence Intervals

```python
# get_forecast returns a PredictionResults object
pred = results.get_forecast(steps=12)

# DataFrame with columns: mean, mean_se, mean_ci_lower, mean_ci_upper
pred_summary = pred.summary_frame(alpha=0.05)  # 95% CI
print(pred_summary)

# Extract components separately
point_forecast = pred.predicted_mean
conf_int_df = pred.conf_int(alpha=0.05)  # DataFrame: lower, upper
```

### In-Sample Prediction

```python
# Predict over a range of in-sample observations
pred_in = results.get_prediction(start=pd.Timestamp('2020-01-01'),
                                   end=pd.Timestamp('2022-12-01'))
pred_in_summary = pred_in.summary_frame(alpha=0.05)

# Or use integer indices
pred_in = results.get_prediction(start=100, end=200)
```

### Applying a Model to New Data (apply)

```python
# Fit model parameters on training set, apply to new data
train_results = sm.tsa.SARIMAX(y_train, order=(1, 1, 1)).fit(disp=False)
test_results = train_results.apply(y_test)
# test_results.fittedvalues gives one-step-ahead predictions on y_test
```

### Updating / Extending a Model with New Observations

```python
# Extend a fitted model with new data (online update)
results_updated = results.append(y_new, refit=False)
# refit=True re-estimates parameters; refit=False uses existing parameters

# Forecast from updated model
new_forecast = results_updated.forecast(steps=6)
```

### Exponential Smoothing Forecasting

```python
# Point forecasts
forecast = results.forecast(steps=12)  # pandas Series

# Simulation-based prediction intervals (ExponentialSmoothing only)
sim = results.simulate(
    nsimulations=12,
    repetitions=1000,
    anchor='end',
    random_errors='bootstrap'  # resample from historical residuals
)
import numpy as np
lower_95 = np.percentile(sim, 2.5, axis=1)
upper_95 = np.percentile(sim, 97.5, axis=1)
```

### VAR Forecasting

```python
# VAR requires passing the last k_ar observations as seed values
y_array = y.values  # numpy array, shape (T, n_vars)
forecast_input = y_array[-results.k_ar:]   # shape (k_ar, n_vars)

# Point forecasts
forecast = results.forecast(forecast_input, steps=5)  # (5, n_vars) array

# Forecast with confidence intervals
forecast_mean, lower, upper = results.forecast_interval(
    forecast_input, steps=5, alpha=0.05
)
# Each is (5, n_vars) array
```

---

## Stationarity Concepts Quick Reference

| Symptom | Meaning | Recommended Fix |
|---------|---------|-----------------|
| Mean changes over time | Level non-stationarity (unit root) | First difference: `y.diff().dropna()` |
| Deterministic upward/downward slope | Deterministic trend | Detrend: `sm.tsa.detrend(y)` or add `trend='t'` in model |
| Variance grows/shrinks over time | Heteroskedasticity | Log transform: `np.log(y)` (requires `y > 0`); or Box-Cox |
| Repeating seasonal spikes in ACF | Seasonal non-stationarity | Seasonal difference: `y.diff(s).dropna()` where `s` = seasonal period |
| Both unit root and seasonal | Both issues | Seasonal + regular differencing: `y.diff(s).diff().dropna()` |

**Quick differencing helpers:**

```python
import numpy as np
import pandas as pd

# First difference (d=1)
y_diff1 = y.diff().dropna()  # pandas
y_diff1 = np.diff(y)          # numpy

# Second difference (d=2)
y_diff2 = y.diff().diff().dropna()

# Seasonal difference (D=1, s=12)
y_sdiff = y.diff(12).dropna()

# Combined: seasonal then regular (typical for monthly SARIMA)
y_full_diff = y.diff(12).diff().dropna()

# Log transform + difference
y_log_diff = np.log(y).diff().dropna()
```

**`sm.tsa.detrend()` for deterministic trend removal:**

```python
# Remove polynomial trend from series
from statsmodels.tsa.tsatools import detrend

y_detrended = detrend(y, order=1)  # remove linear trend
y_detrended2 = detrend(y, order=2) # remove quadratic trend
```

---

## References and Further Reading

- statsmodels time series overview: https://www.statsmodels.org/stable/tsa.html
- statsmodels SARIMAX / state space models: https://www.statsmodels.org/stable/statespace.html
- statsmodels VAR and VECM: https://www.statsmodels.org/stable/vector_ar.html
- statsmodels ExponentialSmoothing: https://www.statsmodels.org/stable/generated/statsmodels.tsa.holtwinters.ExponentialSmoothing.html
- statsmodels ETSModel: https://www.statsmodels.org/stable/generated/statsmodels.tsa.exponential_smoothing.ets.ETSModel.html
- statsmodels UnobservedComponents: https://www.statsmodels.org/stable/generated/statsmodels.tsa.statespace.structural.UnobservedComponents.html
- statsmodels stattools (unit root tests, ACF/PACF): https://www.statsmodels.org/stable/stats.html#time-series-analysis
- Hamilton, J.D. (1994). *Time Series Analysis*. Princeton University Press.
- Hyndman, R.J. & Athanasopoulos, G. (2021). *Forecasting: Principles and Practice*, 3rd ed. https://otexts.com/fpp3/
- Lütkepohl, H. (2005). *New Introduction to Multiple Time Series Analysis*. Springer.
- Harvey, A.C. (1989). *Forecasting, Structural Time Series Models and the Kalman Filter*. Cambridge University Press.
