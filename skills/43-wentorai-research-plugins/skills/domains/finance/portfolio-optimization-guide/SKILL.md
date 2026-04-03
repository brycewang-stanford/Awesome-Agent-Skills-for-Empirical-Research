---
name: portfolio-optimization-guide
description: "Portfolio theory, optimization algorithms, and asset allocation methods"
metadata:
  openclaw:
    emoji: "💼"
    category: "domains"
    subcategory: "finance"
    keywords: ["portfolio", "optimization", "markowitz", "asset-allocation", "mean-variance", "black-litterman"]
    source: "wentor"
---

# Portfolio Optimization Guide

A skill for implementing and researching portfolio optimization methods, from classical mean-variance optimization to modern robust and factor-based approaches. Covers Markowitz theory, Black-Litterman, risk parity, and machine learning-enhanced portfolio construction.

## Mean-Variance Optimization

### Classical Markowitz Portfolio

```python
import numpy as np
from scipy.optimize import minimize

def mean_variance_optimize(expected_returns: np.ndarray,
                             cov_matrix: np.ndarray,
                             target_return: float = None,
                             risk_free_rate: float = 0.02) -> dict:
    """
    Markowitz mean-variance optimization.
    expected_returns: array of expected returns for each asset
    cov_matrix: covariance matrix of asset returns
    target_return: target portfolio return (None for max Sharpe)
    """
    n_assets = len(expected_returns)

    def portfolio_volatility(weights):
        return np.sqrt(weights @ cov_matrix @ weights)

    def neg_sharpe(weights):
        ret = weights @ expected_returns
        vol = portfolio_volatility(weights)
        return -(ret - risk_free_rate) / vol

    # Constraints
    constraints = [
        {"type": "eq", "fun": lambda w: np.sum(w) - 1},  # weights sum to 1
    ]
    if target_return is not None:
        constraints.append(
            {"type": "eq", "fun": lambda w: w @ expected_returns - target_return}
        )

    # Bounds: no short selling (0 to 1 per asset)
    bounds = [(0, 1) for _ in range(n_assets)]

    # Initial guess: equal weight
    w0 = np.ones(n_assets) / n_assets

    if target_return is not None:
        # Minimize volatility for given return
        result = minimize(portfolio_volatility, w0,
                         bounds=bounds, constraints=constraints)
    else:
        # Maximize Sharpe ratio
        result = minimize(neg_sharpe, w0,
                         bounds=bounds, constraints=constraints)

    weights = result.x
    ret = weights @ expected_returns
    vol = portfolio_volatility(weights)

    return {
        "weights": {f"asset_{i}": round(w, 4) for i, w in enumerate(weights)},
        "expected_return": round(ret, 4),
        "volatility": round(vol, 4),
        "sharpe_ratio": round((ret - risk_free_rate) / vol, 4),
    }
```

### Efficient Frontier

```python
def compute_efficient_frontier(expected_returns: np.ndarray,
                                 cov_matrix: np.ndarray,
                                 n_points: int = 50) -> list[dict]:
    """
    Compute the efficient frontier by solving for minimum variance
    portfolios at each target return level.
    """
    min_ret = expected_returns.min() * 0.8
    max_ret = expected_returns.max() * 1.1
    target_returns = np.linspace(min_ret, max_ret, n_points)

    frontier = []
    for target in target_returns:
        try:
            result = mean_variance_optimize(
                expected_returns, cov_matrix, target_return=target
            )
            frontier.append({
                "return": result["expected_return"],
                "volatility": result["volatility"],
                "sharpe": result["sharpe_ratio"],
            })
        except Exception:
            continue

    return frontier
```

## Black-Litterman Model

### Incorporating Investor Views

```python
def black_litterman(market_cap_weights: np.ndarray,
                      cov_matrix: np.ndarray,
                      P: np.ndarray,
                      Q: np.ndarray,
                      omega: np.ndarray = None,
                      risk_aversion: float = 2.5,
                      tau: float = 0.05) -> dict:
    """
    Black-Litterman model for combining market equilibrium with
    investor views.
    market_cap_weights: market-cap weighted portfolio
    cov_matrix: covariance matrix
    P: pick matrix (k views x n assets), identifies assets in each view
    Q: view returns (k x 1), expected returns for each view
    omega: view uncertainty (k x k), diagonal matrix
    """
    # Step 1: Implied equilibrium returns (reverse optimization)
    pi = risk_aversion * cov_matrix @ market_cap_weights

    # Step 2: View uncertainty (if not provided, use He-Litterman)
    if omega is None:
        omega = np.diag(np.diag(tau * P @ cov_matrix @ P.T))

    # Step 3: Posterior expected returns
    tau_sigma = tau * cov_matrix
    inv_tau_sigma = np.linalg.inv(tau_sigma)
    inv_omega = np.linalg.inv(omega)

    posterior_precision = inv_tau_sigma + P.T @ inv_omega @ P
    posterior_cov = np.linalg.inv(posterior_precision)
    posterior_mean = posterior_cov @ (inv_tau_sigma @ pi + P.T @ inv_omega @ Q)

    return {
        "equilibrium_returns": pi.round(4).tolist(),
        "posterior_returns": posterior_mean.round(4).tolist(),
        "posterior_covariance": posterior_cov.round(6).tolist(),
    }
```

## Risk Parity

### Equal Risk Contribution Portfolio

```python
def risk_parity(cov_matrix: np.ndarray, budget: np.ndarray = None) -> dict:
    """
    Risk parity: each asset contributes equally to total portfolio risk.
    budget: risk budget (default: equal, 1/n each)
    """
    n = cov_matrix.shape[0]
    if budget is None:
        budget = np.ones(n) / n

    def objective(weights):
        portfolio_vol = np.sqrt(weights @ cov_matrix @ weights)
        marginal_risk = cov_matrix @ weights
        risk_contribution = weights * marginal_risk / portfolio_vol
        target_risk = budget * portfolio_vol
        return np.sum((risk_contribution - target_risk) ** 2)

    constraints = [{"type": "eq", "fun": lambda w: np.sum(w) - 1}]
    bounds = [(0.01, 1) for _ in range(n)]
    w0 = np.ones(n) / n

    result = minimize(objective, w0, bounds=bounds, constraints=constraints)
    weights = result.x

    # Verify risk contributions
    portfolio_vol = np.sqrt(weights @ cov_matrix @ weights)
    marginal_risk = cov_matrix @ weights
    risk_contrib = weights * marginal_risk / portfolio_vol
    risk_pct = risk_contrib / risk_contrib.sum()

    return {
        "weights": weights.round(4).tolist(),
        "portfolio_volatility": round(portfolio_vol, 4),
        "risk_contributions": risk_pct.round(4).tolist(),
        "max_risk_deviation": round(np.max(np.abs(risk_pct - budget)), 4),
    }
```

## Factor-Based Portfolio Construction

### Fama-French Factor Exposures

```python
import statsmodels.api as sm

def estimate_factor_exposures(asset_returns: pd.DataFrame,
                                factor_returns: pd.DataFrame) -> pd.DataFrame:
    """
    Estimate asset exposures to Fama-French factors using regression.
    factor_returns columns: Mkt-RF, SMB, HML, RMW, CMA (5-factor model)
    """
    results = []
    for asset in asset_returns.columns:
        y = asset_returns[asset] - factor_returns.get("RF", 0)
        X = sm.add_constant(factor_returns[["Mkt-RF", "SMB", "HML", "RMW", "CMA"]])
        model = sm.OLS(y, X).fit()

        results.append({
            "asset": asset,
            "alpha": round(model.params["const"], 6),
            "beta_market": round(model.params["Mkt-RF"], 4),
            "beta_size": round(model.params["SMB"], 4),
            "beta_value": round(model.params["HML"], 4),
            "beta_profit": round(model.params["RMW"], 4),
            "beta_invest": round(model.params["CMA"], 4),
            "r_squared": round(model.rsquared, 4),
        })

    return pd.DataFrame(results)
```

## Rebalancing and Transaction Costs

### Optimal Rebalancing with Costs

```python
def rebalance_with_costs(current_weights: np.ndarray,
                          target_weights: np.ndarray,
                          portfolio_value: float,
                          cost_per_trade: float = 0.001,
                          threshold: float = 0.02) -> dict:
    """
    Determine rebalancing trades considering transaction costs.
    threshold: minimum deviation to trigger rebalancing (2% default)
    cost_per_trade: proportional transaction cost (10 bps)
    """
    deviations = np.abs(current_weights - target_weights)
    needs_rebalance = np.any(deviations > threshold)

    if not needs_rebalance:
        return {"action": "hold", "reason": "within threshold"}

    trades = target_weights - current_weights
    trade_value = np.abs(trades) * portfolio_value
    total_cost = trade_value.sum() * cost_per_trade

    return {
        "action": "rebalance",
        "trades": trades.round(4).tolist(),
        "turnover": np.abs(trades).sum() / 2,
        "transaction_cost": round(total_cost, 2),
        "cost_as_pct": round(total_cost / portfolio_value * 100, 4),
    }
```

## Key Academic References

- Markowitz, H. (1952). Portfolio Selection. *Journal of Finance*.
- Black, F. and Litterman, R. (1992). Global Portfolio Optimization. *Financial Analysts Journal*.
- Maillard, S., Roncalli, T., and Teiletche, J. (2010). The Properties of Equally Weighted Risk Contribution Portfolios. *Journal of Portfolio Management*.
- Fama, E. and French, K. (2015). A Five-Factor Asset Pricing Model. *Journal of Financial Economics*.

## Tools and Libraries

- **PyPortfolioOpt**: Portfolio optimization in Python (mean-variance, Black-Litterman, HRP)
- **riskfolio-lib**: Advanced portfolio optimization with risk measures
- **cvxpy**: Convex optimization for custom portfolio problems
- **QuantLib**: Fixed income and derivatives analytics
- **Kenneth French Data Library**: Factor returns data (free)
- **zipline / backtrader**: Backtesting frameworks for strategy evaluation
