---
name: options-analytics-agent-guide
description: "AI agent for options pricing, Greeks, and strategy analysis"
metadata:
  openclaw:
    emoji: "📉"
    category: "domains"
    subcategory: "finance"
    keywords: ["options analytics", "derivatives", "Greeks", "Black-Scholes", "strategy analysis", "financial agent"]
    source: "wentor-research-plugins"
---

# Options Analytics Agent Guide

## Overview

An AI agent for options pricing, risk analysis, and strategy evaluation. It combines Black-Scholes and binomial models, Greeks calculations, implied volatility surfaces, and portfolio risk analytics into a conversational interface. Researchers and quantitative analysts can query options data, price exotic derivatives, and evaluate trading strategies through natural language.

## Core Capabilities

```python
from options_agent import OptionsAgent

agent = OptionsAgent(llm_provider="anthropic")

# Price an option
result = agent.price(
    option_type="call",
    strike=100,
    spot=105,
    expiry_days=30,
    risk_free_rate=0.05,
    volatility=0.20,
    model="black_scholes",
)

print(f"Price: ${result.price:.2f}")
print(f"Delta: {result.delta:.4f}")
print(f"Gamma: {result.gamma:.4f}")
print(f"Theta: {result.theta:.4f}")
print(f"Vega: {result.vega:.4f}")
print(f"Rho: {result.rho:.4f}")
```

## Greeks Analysis

```python
# Full Greeks surface
surface = agent.greeks_surface(
    strike=100,
    spot_range=(80, 120),
    expiry_range=(7, 90),  # days
    volatility=0.25,
)

surface.plot_delta_surface("delta_surface.png")
surface.plot_gamma_surface("gamma_surface.png")
surface.plot_theta_decay("theta_decay.png")
```

## Strategy Evaluation

```python
# Evaluate an options strategy
strategy = agent.evaluate_strategy(
    legs=[
        {"type": "call", "strike": 100, "action": "buy", "qty": 1},
        {"type": "call", "strike": 110, "action": "sell", "qty": 1},
    ],
    spot=105,
    expiry_days=30,
    volatility=0.20,
)

print(f"Strategy: {strategy.name}")  # Bull Call Spread
print(f"Max profit: ${strategy.max_profit:.2f}")
print(f"Max loss: ${strategy.max_loss:.2f}")
print(f"Breakeven: ${strategy.breakeven:.2f}")

strategy.plot_payoff("payoff.png")
strategy.plot_pnl_scenarios("scenarios.png")
```

## Implied Volatility

```python
# Calculate implied volatility
iv = agent.implied_volatility(
    market_price=5.50,
    option_type="call",
    strike=100,
    spot=105,
    expiry_days=30,
    risk_free_rate=0.05,
)
print(f"Implied volatility: {iv:.2%}")

# Volatility smile/surface
vol_surface = agent.volatility_surface(
    ticker="SPY",
    date="2025-03-10",
)
vol_surface.plot("vol_surface.png")
```

## Use Cases

1. **Options pricing**: Black-Scholes and numerical methods
2. **Risk management**: Greeks and portfolio risk metrics
3. **Strategy analysis**: P&L profiles and breakeven analysis
4. **Volatility analysis**: IV surfaces and skew analysis
5. **Education**: Interactive derivatives teaching tool

## References

- [Options Analytics Agent](https://github.com/options-analytics/options-agent)
- [QuantLib](https://www.quantlib.org/) — Quantitative finance library
