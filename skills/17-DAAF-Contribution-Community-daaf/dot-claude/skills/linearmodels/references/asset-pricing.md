# Asset Pricing Models

Reference for asset pricing estimators in `linearmodels.asset_pricing`. These models test whether a set of risk factors explains the cross-section of expected returns. For Fama-MacBeth regressions (the most commonly used asset pricing estimation method), see `./panel-models.md` -- FamaMacBeth lives in `linearmodels.panel`. This file covers the specialized factor model classes that test asset pricing theories.

## Contents

- [Overview](#overview)
- [LinearFactorModel (Non-Traded Factors)](#linearfactormodel-non-traded-factors)
- [LinearFactorModelGMM](#linearfactormodelgmm)
- [TradedFactorModel](#tradedfactormodel)
- [Interpreting Output](#interpreting-output)
- [Covariance Options](#covariance-options)
- [Common Use Cases](#common-use-cases)
- [Data Format](#data-format)
- [References and Further Reading](#references-and-further-reading)

## Overview

Three model classes for testing linear factor pricing models:

- `LinearFactorModel` -- two-step estimation for non-traded factors
- `LinearFactorModelGMM` -- GMM estimation for non-traded factors (more efficient)
- `TradedFactorModel` -- SUR-based estimation for traded factor portfolios

All test the same pricing restriction: E[R_i] = lambda_0 + lambda_1 * beta_i1 + ... + lambda_K * beta_iK. Test portfolios (rows) are assets or portfolios; factors explain cross-sectional return differences. The J-statistic tests whether the model correctly prices all test portfolios (null: all pricing errors are jointly zero).

## LinearFactorModel (Non-Traded Factors)

Two-step estimation: (1) time-series regressions of each portfolio's excess returns on factors to get betas, (2) cross-sectional regression of mean excess returns on estimated betas to get risk premia. For factors that are NOT excess returns themselves (e.g., macro factors, consumption growth, labor income growth).

```python
from linearmodels.asset_pricing import LinearFactorModel

# portfolios: T x N DataFrame of excess returns (time periods x test portfolios)
# factors: T x K DataFrame of factor values (not necessarily excess returns)
mod = LinearFactorModel(portfolios=excess_returns, factors=factors)
res = mod.fit(cov_type="kernel", kernel="bartlett", bandwidth=6)
print(res.summary)

# J-statistic: test of whether all pricing errors (alphas) are jointly zero
print(f"J-statistic: {res.j_statistic.stat:.3f} (p={res.j_statistic.pval:.3f})")
```

### Risk-Free Rate Handling

```python
# LinearFactorModel estimates a free intercept (lambda_0) in the cross-sectional
# regression. If the model is correct, lambda_0 should equal the risk-free rate
# (or zero if portfolios are already excess returns).
print(f"Estimated risk-free rate (lambda_0): {res.risk_premia.iloc[0]:.4f}")
```

## LinearFactorModelGMM

GMM estimation of the same non-traded factor model. Jointly estimates factor betas and risk premia in a single system rather than sequentially. More efficient than two-step when the model is correctly specified. Same interface as `LinearFactorModel`.

```python
from linearmodels.asset_pricing import LinearFactorModelGMM

mod = LinearFactorModelGMM(portfolios=excess_returns, factors=factors)
res = mod.fit(cov_type="kernel", kernel="bartlett", bandwidth=6)
print(res.summary)

# Same output structure as LinearFactorModel
print(f"J-statistic: {res.j_statistic.stat:.3f} (p={res.j_statistic.pval:.3f})")
print(res.risk_premia)
```

## TradedFactorModel

For factors that ARE traded portfolios or excess returns (e.g., Fama-French HML, SMB, Mkt-RF). Uses SUR-based estimation: runs time-series regressions of each test portfolio on the factors, then tests whether the intercepts (alphas) are jointly zero. No cross-sectional regression needed because factor risk premia are directly observed as factor mean returns.

```python
from linearmodels.asset_pricing import TradedFactorModel

# factors must be excess returns (e.g., Mkt-RF, SMB, HML from Ken French's library)
mod = TradedFactorModel(portfolios=excess_returns, factors=factor_returns)
res = mod.fit(cov_type="kernel", kernel="bartlett", bandwidth=6)
print(res.summary)

# GRS test (Gibbons, Ross, Shanken 1989) — tests if all alphas are jointly zero
print(f"J-statistic (GRS): {res.j_statistic.stat:.3f}")
print(f"p-value: {res.j_statistic.pval:.3f}")

# Individual alphas: pricing errors per portfolio
print(res.alphas)
```

### Interpreting Alphas

```python
# Large positive alpha = portfolio earns more than factors predict (underpriced)
# Large negative alpha = portfolio earns less than factors predict (overpriced)
# If model is correct, all alphas should be indistinguishable from zero
alphas = res.alphas
print("Alphas with largest absolute pricing errors:")
print(alphas.reindex(alphas.abs().sort_values(ascending=False).index).head(5))
```

## Interpreting Output

All three model classes produce results with these key elements:

| Output | Meaning |
|--------|---------|
| `res.risk_premia` | Estimated compensation per unit of factor exposure (lambda) |
| `res.betas` | Sensitivity of each test portfolio to each factor |
| `res.j_statistic` | Joint test of all pricing errors (null: alphas jointly zero) |
| `res.alphas` | Pricing error per portfolio -- return unexplained by factor exposures |

The J-statistic is the central test: rejection means the factor model is incomplete and fails to explain the cross-section of returns. Individual alphas identify which portfolios the model misprices.

```python
res = mod.fit(cov_type="kernel", kernel="bartlett", bandwidth=6)

# Risk premia
print("Estimated risk premia (annualized if returns are monthly, multiply by 12):")
print(res.risk_premia)

# Factor betas (N x K matrix)
print(f"Betas shape: {res.betas.shape}")
print(res.betas.head())

# Full summary with standard errors, t-stats, p-values
print(res.summary)
```

## Covariance Options

All asset pricing models support HAC covariance estimation for time-series dependence in returns.

| Parameter | Value | Description |
|-----------|-------|-------------|
| `cov_type` | `"kernel"` | HAC covariance (required for time-series data) |
| `kernel` | `"bartlett"` | Newey-West kernel (most common) |
| `kernel` | `"parzen"` | Parzen kernel |
| `kernel` | `"qs"` | Quadratic Spectral kernel |
| `bandwidth` | integer | Number of lags for kernel estimation |

```python
# Newey-West with 6 lags (common for monthly data)
res = mod.fit(cov_type="kernel", kernel="bartlett", bandwidth=6)

# Parzen kernel
res = mod.fit(cov_type="kernel", kernel="parzen", bandwidth=6)

# Homoskedastic (no correction — rarely appropriate for asset returns)
res = mod.fit(cov_type="unadjusted")
```

## Common Use Cases

**CAPM test:** Single market factor, test if alpha = 0 for portfolios sorted on size, value, momentum, etc.

```python
mod = TradedFactorModel(portfolios=test_portfolios, factors=mkt_excess[["Mkt-RF"]])
res = mod.fit(cov_type="kernel", kernel="bartlett", bandwidth=6)
```

**Fama-French 3-factor:** Mkt-RF, SMB, HML -- all traded factors.

```python
ff3 = factors[["Mkt-RF", "SMB", "HML"]]
mod = TradedFactorModel(portfolios=test_portfolios, factors=ff3)
res = mod.fit(cov_type="kernel", kernel="bartlett", bandwidth=6)
```

**Fama-French 5-factor + momentum:** Extend factor set.

```python
ff6 = factors[["Mkt-RF", "SMB", "HML", "RMW", "CMA", "Mom"]]
mod = TradedFactorModel(portfolios=test_portfolios, factors=ff6)
res = mod.fit(cov_type="kernel", kernel="bartlett", bandwidth=6)
```

**Macro factor models (consumption CAPM):** Non-traded factors require LinearFactorModel.

```python
macro_factors = factors[["consumption_growth", "labor_income_growth"]]
mod = LinearFactorModel(portfolios=test_portfolios, factors=macro_factors)
res = mod.fit(cov_type="kernel", kernel="bartlett", bandwidth=6)
```

## Data Format

- **portfolios**: T x N pandas DataFrame. Rows = time periods. Columns = test portfolios (e.g., 25 size-value sorted portfolios). Values are excess returns (subtract risk-free rate before estimation).
- **factors**: T x K pandas DataFrame. Rows = time periods (must align with portfolios index). Columns = risk factors.
- Both DataFrames must share the same time index.
- No MultiIndex required -- these are NOT panel models.

```python
import pandas as pd

# Typical setup with Fama-French data
portfolios = pd.read_parquet("data/raw/ff25_excess_returns.parquet")
factors = pd.read_parquet("data/raw/ff_factors.parquet")

# Verify alignment
assert portfolios.index.equals(factors.index), "Time indices must match"
print(f"Time periods: {len(portfolios)}")
print(f"Test portfolios: {portfolios.shape[1]}")
print(f"Factors: {factors.shape[1]}")
```

## References and Further Reading

- Sheppard, K. linearmodels Asset Pricing documentation. https://bashtage.github.io/linearmodels/asset-pricing/introduction.html
- Fama, E.F. and French, K.R. (1993). "Common Risk Factors in the Returns on Stocks and Bonds." *Journal of Financial Economics*, 33(1), 3-56.
- Cochrane, J.H. (2005). *Asset Pricing*. Revised ed. Princeton University Press.
- Gibbons, M.R., Ross, S.A., and Shanken, J. (1989). "A Test of the Efficiency of a Given Portfolio." *Econometrica*, 57(5), 1121-1152.
