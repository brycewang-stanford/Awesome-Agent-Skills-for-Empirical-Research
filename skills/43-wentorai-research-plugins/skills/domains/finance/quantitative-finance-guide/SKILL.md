---
name: quantitative-finance-guide
description: "Quantitative methods for financial modeling, derivatives pricing, and risk an..."
metadata:
  openclaw:
    emoji: "📊"
    category: "domains"
    subcategory: "finance"
    keywords: ["quantitative finance", "financial data", "stock analysis", "pricing psychology", "derivatives pricing"]
    source: "wentor"
---

# Quantitative Finance Guide

A rigorous skill for applying quantitative methods to financial research, covering derivatives pricing, portfolio optimization, risk modeling, and time series econometrics. Designed for academic researchers and quantitative analysts.

## Derivatives Pricing

### Black-Scholes-Merton Model

The foundational model for European option pricing:

```python
import numpy as np
from scipy.stats import norm

def black_scholes(S: float, K: float, T: float, r: float,
                   sigma: float, option_type: str = 'call') -> dict:
    """
    Black-Scholes European option pricing.

    Args:
        S: Current stock price
        K: Strike price
        T: Time to maturity (years)
        r: Risk-free rate (annualized)
        sigma: Volatility (annualized)
        option_type: 'call' or 'put'
    """
    d1 = (np.log(S / K) + (r + 0.5 * sigma**2) * T) / (sigma * np.sqrt(T))
    d2 = d1 - sigma * np.sqrt(T)

    if option_type == 'call':
        price = S * norm.cdf(d1) - K * np.exp(-r * T) * norm.cdf(d2)
    else:
        price = K * np.exp(-r * T) * norm.cdf(-d2) - S * norm.cdf(-d1)

    greeks = {
        'delta': norm.cdf(d1) if option_type == 'call' else norm.cdf(d1) - 1,
        'gamma': norm.pdf(d1) / (S * sigma * np.sqrt(T)),
        'theta': -(S * norm.pdf(d1) * sigma) / (2 * np.sqrt(T)),
        'vega': S * norm.pdf(d1) * np.sqrt(T),
        'rho': K * T * np.exp(-r * T) * norm.cdf(d2) if option_type == 'call'
               else -K * T * np.exp(-r * T) * norm.cdf(-d2)
    }
    return {'price': price, 'greeks': greeks}

# Example: price a call option
result = black_scholes(S=100, K=105, T=0.5, r=0.05, sigma=0.20, option_type='call')
print(f"Call Price: ${result['price']:.2f}")
print(f"Delta: {result['greeks']['delta']:.4f}")
```

### Monte Carlo Simulation

For path-dependent options and complex payoffs:

```python
def monte_carlo_option(S0, K, T, r, sigma, n_paths=100000, n_steps=252):
    """Geometric Brownian Motion Monte Carlo pricer."""
    dt = T / n_steps
    Z = np.random.standard_normal((n_paths, n_steps))
    paths = np.zeros((n_paths, n_steps + 1))
    paths[:, 0] = S0

    for t in range(n_steps):
        paths[:, t + 1] = paths[:, t] * np.exp(
            (r - 0.5 * sigma**2) * dt + sigma * np.sqrt(dt) * Z[:, t]
        )

    payoffs = np.maximum(paths[:, -1] - K, 0)
    price = np.exp(-r * T) * np.mean(payoffs)
    std_err = np.exp(-r * T) * np.std(payoffs) / np.sqrt(n_paths)
    return {'price': price, 'std_error': std_err, '95_ci': (price - 1.96*std_err, price + 1.96*std_err)}
```

## Portfolio Optimization

### Mean-Variance Optimization (Markowitz)

Construct efficient frontiers using quadratic programming:

```python
from scipy.optimize import minimize

def efficient_frontier(returns: np.ndarray, n_portfolios: int = 50) -> list:
    """
    Compute efficient frontier points.
    returns: T x N array of asset returns
    """
    n_assets = returns.shape[1]
    mean_returns = returns.mean(axis=0)
    cov_matrix = np.cov(returns.T)

    results = []
    target_returns = np.linspace(mean_returns.min(), mean_returns.max(), n_portfolios)

    for target in target_returns:
        constraints = [
            {'type': 'eq', 'fun': lambda w: np.sum(w) - 1},
            {'type': 'eq', 'fun': lambda w, t=target: w @ mean_returns - t}
        ]
        bounds = [(0, 1)] * n_assets
        w0 = np.ones(n_assets) / n_assets

        result = minimize(lambda w: w @ cov_matrix @ w, w0,
                          bounds=bounds, constraints=constraints, method='SLSQP')
        if result.success:
            vol = np.sqrt(result.fun)
            results.append({'return': target, 'volatility': vol, 'weights': result.x})
    return results
```

## Risk Management

### Value at Risk (VaR) and Expected Shortfall

Three approaches to VaR estimation:

1. **Historical Simulation**: Non-parametric, uses actual return distribution
2. **Variance-Covariance (Parametric)**: Assumes normal distribution, fast computation
3. **Monte Carlo VaR**: Most flexible, handles non-linear instruments

```python
def compute_var_es(returns: np.ndarray, confidence: float = 0.95) -> dict:
    """Compute VaR and Expected Shortfall (CVaR)."""
    sorted_returns = np.sort(returns)
    var_index = int((1 - confidence) * len(sorted_returns))
    var = -sorted_returns[var_index]
    es = -sorted_returns[:var_index].mean()
    return {'VaR': var, 'ES': es, 'confidence': confidence}
```

## Time Series Econometrics

For financial time series, test for stationarity (ADF test), model volatility clustering with GARCH models, and check for cointegration in pairs trading strategies. Always report Newey-West standard errors when autocorrelation is present, and use information criteria (AIC, BIC) for model selection.

## References

- Hull, J. C. (2022). *Options, Futures, and Other Derivatives* (11th ed.). Pearson.
- Markowitz, H. (1952). Portfolio Selection. *Journal of Finance*, 7(1), 77-91.
