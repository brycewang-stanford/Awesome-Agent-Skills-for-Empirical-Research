---
name: risk-modeling-guide
description: "Financial risk modeling including VaR, stress testing, and credit risk"
metadata:
  openclaw:
    emoji: "📉"
    category: "domains"
    subcategory: "finance"
    keywords: ["risk-modeling", "var", "stress-testing", "credit-risk", "monte-carlo", "basel"]
    source: "wentor"
---

# Risk Modeling Guide

A skill for quantitative financial risk modeling, covering Value at Risk, Expected Shortfall, credit risk, stress testing, and Monte Carlo simulation methods. Essential for financial engineering research and regulatory risk analysis.

## Market Risk: Value at Risk

### VaR Methodologies

| Method | Description | Pros | Cons |
|--------|-------------|------|------|
| Historical simulation | Replay past returns | No distributional assumption | Assumes past repeats |
| Variance-covariance | Assume normal returns | Fast, analytical | Underestimates tail risk |
| Monte Carlo simulation | Simulate from fitted model | Flexible distributions | Computationally expensive |
| Filtered historical simulation | GARCH + historical innovations | Captures volatility clustering | More complex |

### Implementation

```python
import numpy as np
import pandas as pd
from scipy.stats import norm, t as t_dist

def historical_var(returns: np.ndarray, confidence: float = 0.99,
                    horizon_days: int = 1) -> dict:
    """
    Compute Value at Risk using historical simulation.
    returns: array of daily log returns
    confidence: confidence level (e.g., 0.99 for 99% VaR)
    horizon_days: risk horizon in days
    """
    # Scale returns to horizon
    if horizon_days > 1:
        # Rolling sum for overlapping returns
        scaled_returns = pd.Series(returns).rolling(horizon_days).sum().dropna().values
    else:
        scaled_returns = returns

    alpha = 1 - confidence
    var = -np.percentile(scaled_returns, alpha * 100)
    es = -np.mean(scaled_returns[scaled_returns <= -var])

    return {
        "VaR": round(var, 6),
        "Expected_Shortfall": round(es, 6),
        "confidence": confidence,
        "horizon_days": horizon_days,
        "n_observations": len(scaled_returns),
    }

def parametric_var(returns: np.ndarray, confidence: float = 0.99,
                    distribution: str = "normal") -> dict:
    """
    Parametric VaR assuming normal or Student-t distribution.
    """
    mu = np.mean(returns)
    sigma = np.std(returns, ddof=1)

    if distribution == "normal":
        z = norm.ppf(1 - confidence)
        var = -(mu + sigma * z)
        # Analytical ES for normal
        es = -mu + sigma * norm.pdf(norm.ppf(1 - confidence)) / (1 - confidence)
    elif distribution == "student-t":
        # Fit Student-t
        df, loc, scale = t_dist.fit(returns)
        z = t_dist.ppf(1 - confidence, df)
        var = -(loc + scale * z)
        # ES for Student-t
        t_pdf = t_dist.pdf(t_dist.ppf(1 - confidence, df), df)
        es = -loc + scale * (t_pdf / (1 - confidence)) * ((df + z**2) / (df - 1))
    else:
        raise ValueError(f"Unknown distribution: {distribution}")

    return {
        "VaR": round(var, 6),
        "Expected_Shortfall": round(es, 6),
        "distribution": distribution,
        "mean": round(mu, 6),
        "std": round(sigma, 6),
    }
```

### Monte Carlo VaR

```python
def monte_carlo_var(returns: np.ndarray, n_simulations: int = 100000,
                     confidence: float = 0.99,
                     horizon_days: int = 10) -> dict:
    """
    Monte Carlo VaR using GBM (Geometric Brownian Motion).
    """
    mu = np.mean(returns)
    sigma = np.std(returns, ddof=1)

    # Simulate daily returns for the horizon
    rng = np.random.default_rng(42)
    simulated = rng.normal(
        mu * horizon_days,
        sigma * np.sqrt(horizon_days),
        size=n_simulations,
    )

    alpha = 1 - confidence
    var = -np.percentile(simulated, alpha * 100)
    es = -np.mean(simulated[simulated <= -var])

    return {
        "VaR": round(var, 6),
        "Expected_Shortfall": round(es, 6),
        "n_simulations": n_simulations,
        "confidence": confidence,
        "horizon_days": horizon_days,
    }
```

## Credit Risk Modeling

### Probability of Default Estimation

```python
from sklearn.linear_model import LogisticRegression

def build_pd_model(features: pd.DataFrame,
                    default_flag: pd.Series) -> dict:
    """
    Build a Probability of Default (PD) model using logistic regression.
    Common features: debt-to-income, credit utilization, payment history,
    employment length, loan amount.
    """
    model = LogisticRegression(max_iter=1000, class_weight="balanced")
    model.fit(features, default_flag)

    # Coefficient interpretation
    coef_df = pd.DataFrame({
        "feature": features.columns,
        "coefficient": model.coef_[0],
        "odds_ratio": np.exp(model.coef_[0]),
    }).sort_values("coefficient", ascending=False)

    # Model discrimination
    from sklearn.metrics import roc_auc_score
    pred_proba = model.predict_proba(features)[:, 1]
    auc = roc_auc_score(default_flag, pred_proba)

    return {
        "auc": round(auc, 4),
        "coefficients": coef_df.to_dict("records"),
        "intercept": round(model.intercept_[0], 4),
    }
```

### Loss Given Default and EAD

```python
def compute_expected_loss(pd_score: float, lgd: float,
                           ead: float) -> dict:
    """
    Compute Expected Loss = PD x LGD x EAD.
    pd_score: probability of default (0-1)
    lgd: loss given default (0-1, fraction of exposure lost)
    ead: exposure at default (dollar amount)
    """
    el = pd_score * lgd * ead
    return {
        "PD": pd_score,
        "LGD": lgd,
        "EAD": ead,
        "Expected_Loss": round(el, 2),
        "Unexpected_Loss_99": round(el * 2.33 * np.sqrt(pd_score * (1 - pd_score)), 2),
    }
```

## Stress Testing

### Scenario-Based Stress Tests

```python
def run_stress_test(portfolio_returns: pd.DataFrame,
                     scenarios: dict[str, dict]) -> pd.DataFrame:
    """
    Apply macroeconomic stress scenarios to a portfolio.
    scenarios: {name: {factor: shock_value}} where factors are
    macroeconomic variables (interest_rate, gdp_growth, unemployment, etc.)
    """
    # Factor sensitivities (betas from regression)
    # In practice, estimated via historical regression
    factor_betas = {
        "interest_rate": -0.15,    # portfolio loses 15bp per 1% rate increase
        "gdp_growth": 0.08,        # gains 8bp per 1% GDP growth
        "unemployment": -0.12,     # loses 12bp per 1% unemployment increase
        "equity_market": 0.45,     # 45bp per 1% equity market move
        "credit_spread": -0.25,    # loses 25bp per 1% spread widening
    }

    results = []
    for name, shocks in scenarios.items():
        portfolio_impact = 0
        for factor, shock in shocks.items():
            beta = factor_betas.get(factor, 0)
            portfolio_impact += beta * shock

        results.append({
            "scenario": name,
            "portfolio_impact_pct": round(portfolio_impact * 100, 2),
            "shocks": shocks,
        })

    return pd.DataFrame(results)

# Example scenarios
scenarios = {
    "Mild Recession": {
        "interest_rate": -0.5, "gdp_growth": -2.0,
        "unemployment": 2.0, "equity_market": -15.0,
        "credit_spread": 1.5,
    },
    "Severe Recession": {
        "interest_rate": -1.0, "gdp_growth": -5.0,
        "unemployment": 5.0, "equity_market": -40.0,
        "credit_spread": 4.0,
    },
    "Rate Shock": {
        "interest_rate": 3.0, "gdp_growth": -1.0,
        "unemployment": 1.0, "equity_market": -10.0,
        "credit_spread": 1.0,
    },
}
```

## Regulatory Framework

### Basel III Capital Requirements

| Risk Type | Measurement | Capital Charge |
|-----------|-------------|---------------|
| Market risk | FRTB (Fundamental Review of the Trading Book) | ES at 97.5%, stressed calibration |
| Credit risk | SA or IRB approach | PD, LGD, EAD based risk weights |
| Operational risk | Basic Indicator / Standardized | Business indicator x ILM |
| Liquidity risk | LCR and NSFR ratios | High-quality liquid assets buffer |

## Tools and Libraries

- **QuantLib (Python/C++)**: Derivatives pricing and risk analytics
- **riskfolio-lib**: Portfolio risk and optimization in Python
- **arch (Python)**: GARCH models for volatility estimation
- **pyfolio**: Portfolio performance and risk analysis
- **OpenGamma Strata**: Open-source market risk analytics (Java)
- **Moody's Analytics / Bloomberg PORT**: Commercial risk platforms
