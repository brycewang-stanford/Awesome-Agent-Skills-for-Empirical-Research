# Time Series Analysis in Stata

## The tsset Command

```stata
tsset timevar               // Simple time series
tsset panelvar timevar      // Panel data

// Example setup
generate date = quarterly(datestr, "YQ")
format date %tq
tsset date

tsset                       // Check current settings
```

**Important:**
- Time variable must be numeric with unique values per panel
- Time formats: `%td` (daily), `%tw` (weekly), `%tm` (monthly), `%tq` (quarterly), `%ty` (yearly)

```stata
// Setting up quarterly data from scratch
clear
set obs 100
generate quarter = tq(1990q1) + _n - 1
format quarter %tq
tsset quarter
```

---

## Time Series Operators

After `tsset`, four operators are available in expressions and commands.

### L (Lag), F (Forward), D (Difference), S (Seasonal Difference)

```stata
L.gdp              // First lag
L2.gdp             // Second lag
F.inflation         // First lead
D.gdp              // First difference (gdp - L.gdp)
D2.gdp             // Second difference
S4.gdp             // Seasonal difference (quarterly year-over-year)
S12.sales           // Seasonal difference (monthly year-over-year)

// Combinations
L2D.gdp             // Second lag of first difference
DS12.sales           // Difference of seasonal difference
LS12.sales           // Lag of seasonal difference

// Identities
assert L.F.gdp == gdp
assert D.gdp == gdp - L.gdp

// In commands
regress gdp L(1/4).gdp L.inflation
summarize D.gdp D.inflation
generate gdp_pct_change = D.gdp / L.gdp * 100
```

---

## ARIMA Models

```stata
arima depvar [indepvars], ar(numlist) ma(numlist) [options]
```

### Examples

```stata
arima inv, ar(1)                    // AR(1)
arima inv, ma(1)                    // MA(1)
arima inv, ar(1) ma(1)             // ARMA(1,1)
arima D.inv, ar(1) ma(1)           // ARIMA(1,1,1)

// Seasonal: ARIMA(1,1,1)(1,1,1)_4
arima D.S4.inv, ar(1) ma(1) sar(4) sma(4)

// ARMAX (with exogenous variables)
arima inv income, ar(1/2) ma(1)
```

### Model Selection and Post-Estimation

```stata
// Compare models via information criteria
arima inv, ar(1)
estimates store ar1
arima inv, ar(1) ma(1)
estimates store arma11
estimates stats ar1 arma11

// Post-estimation
arima inv, ar(1) ma(1)
predict inv_fitted
predict inv_resid, residuals
wntestq inv_resid                   // Residual autocorrelation test
predict inv_forecast, dynamic(tq(2000q1))
```

### Complete Workflow

```stata
tsset quarter
tsline gdp
dfuller gdp, lags(4)               // Stationarity test
ac D.gdp                           // ACF on differenced series
pac D.gdp                          // PACF
arima D.gdp, ar(1) ma(1)           // Estimate
predict resid, residuals
wntestq resid                      // Diagnostics
predict gdp_forecast, dynamic(tq(2023q1))
```

---

## VAR Models

```stata
var varlist, lags(numlist) [options]
```

### Complete VAR Workflow

```stata
varsoc inv inc cons                          // Lag selection
var inv inc cons, lags(1/2)                  // Estimate
varstable, graph                             // Stability check
vargranger                                   // Granger causality

// Impulse responses and FEVD
irf create results, step(20) set(myirf) replace
irf graph oirf, impulse(inc) response(inv cons)
irf table fevd, step(20)

// Forecasting
fcast compute f_, step(12)
fcast graph f_inv f_inc f_cons, observed
```

### VAR with Exogenous Variables and SVAR

```stata
var inv inc cons, lags(1/2) exog(L.oil_price)

// Structural VAR with short-run restrictions
matrix A = (1, 0, 0 \ ., 1, 0 \ ., ., 1)
matrix B = (., 0, 0 \ 0, ., 0 \ 0, 0, .)
svar inv inc cons, lags(1/2) aeq(A) beq(B)
```

---

## Unit Root Tests

### Augmented Dickey-Fuller (dfuller)

H0: unit root (non-stationary). Reject if p < 0.05.

```stata
dfuller inv                         // Basic
dfuller inv, lags(4)                // With lag selection
dfuller inv, trend lags(4)          // With trend
```

### Phillips-Perron (pperron) and DF-GLS (dfgls)

```stata
pperron inv, trend
dfgls inv, maxlag(8)
```

### Panel Unit Root Tests

```stata
xtset company year
xtunitroot llc invest               // Levin-Lin-Chu
xtunitroot ips invest               // Im-Pesaran-Shin
xtunitroot fisher invest, dfuller   // Fisher-type
xtunitroot hadri invest             // Hadri (H0: all panels stationary)
```

### Interpreting Output

```stata
dfuller gdp, lags(4)
// If Z(t) < critical value: reject H0 (stationary)
// If Z(t) > critical value: fail to reject (unit root present)
```

---

## Time Series Graphs

```stata
tsline inv                          // Basic
tsline inv inc cons                 // Multiple series

// With options
tsline inv, title("Investment") ytitle("Value") xlabel(, angle(45))

// ACF and PACF
ac gdp, lags(20)
pac gdp, lags(20)
```

---

## Forecasting

### Static vs Dynamic Forecasts

```stata
arima inv, ar(1) ma(1)
predict inv_static                          // Uses actual values for lags
predict inv_dynamic, dynamic(tq(2000q1))    // Uses predicted values for lags
```

### Forecasting Beyond Sample

```stata
tsappend, add(8)                            // Extend dataset
arima inv, ar(2) ma(1)
predict inv_forecast, dynamic(tq(1999q1))
predict inv_se, mse                         // Forecast standard errors

// Confidence intervals
generate inv_upper = inv_forecast + 1.96*sqrt(inv_se)
generate inv_lower = inv_forecast - 1.96*sqrt(inv_se)

// Plot with CI bands
twoway (tsline inv) ///
    (tsline inv_forecast, lpattern(dash)) ///
    (rarea inv_upper inv_lower qtr, color(red%20))
```

### Exponential Smoothing

```stata
tssmooth exponential sm_inv = inv, parms(0.3)
tssmooth dexponential ds_inv = inv, parms(0.3 0.1)     // Holt
tssmooth hwinters hw_sales = sales, parms(0.3 0.1 0.2) seasonal(12)  // Holt-Winters
```

### Forecast Evaluation

```stata
generate forecast_error = inv - inv_forecast
egen mae = mean(abs(forecast_error))
generate sq_error = forecast_error^2
egen mse = mean(sq_error)
generate rmse = sqrt(mse)
```

### Rolling Forecasts

```stata
forvalues t = `start'/`end' {
    quietly arima inv if qtr < `t', ar(2) ma(1)
    quietly predict temp if qtr == `t', dynamic(`t')
    replace inv_rolling = temp if qtr == `t'
    drop temp
}
```

---

## Seasonality

### Detecting and Creating Seasonal Variables

```stata
ac sales, lags(36)                          // Look for spikes at seasonal lags
generate quarter = quarter(dofq(qtr))
tabulate quarter, generate(q)
generate month_num = month(dofm(month))
```

### Seasonal Adjustment

```stata
// Via dummies
regress sales q2 q3 q4 trend
predict sales_fitted
generate sales_sa = sales - sales_fitted

// Via seasonal differencing
generate sales_sd = S4.sales               // Quarterly
generate sales_sd_monthly = S12.sales      // Monthly
generate sales_diff_seasonal = D.S12.sales // Combined
```

### Seasonal ARIMA

```stata
// SARIMA(1,1,1)(1,1,1)_4
arima D.S4.sales, ar(1) ma(1) sar(4) sma(4)

// SARIMA(1,1,1)(1,1,1)_12
arima D.S12.sales, ar(1) ma(1) sar(12) sma(12)
```

### Seasonal Decomposition

```stata
tssmooth ma sales_trend = sales, window(12 1 11)
generate sales_detrend = sales - sales_trend
egen sales_seasonal = mean(sales_detrend), by(month_num)
generate sales_irregular = sales_detrend - sales_seasonal
```
