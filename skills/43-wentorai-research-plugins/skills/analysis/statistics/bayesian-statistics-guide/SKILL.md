---
name: bayesian-statistics-guide
description: "Bayesian inference methods including prior selection, MCMC, and model comparison"
metadata:
  openclaw:
    emoji: "📐"
    category: "analysis"
    subcategory: "statistics"
    keywords: ["Bayesian statistics", "Bayesian inference", "MCMC", "sample size calculation", "prior selection"]
    source: "wentor"
---

# Bayesian Statistics Guide

A skill for applying Bayesian statistical methods to research data analysis. Covers prior specification, Markov chain Monte Carlo (MCMC) sampling, posterior interpretation, model comparison, and reporting standards.

## Bayesian Framework Overview

### Bayes' Theorem in Practice

```
Posterior = (Likelihood x Prior) / Evidence

P(theta | data) = P(data | theta) * P(theta) / P(data)

In practice:
  P(theta | data) is proportional to P(data | theta) * P(theta)
  (the denominator is a normalizing constant)
```

### When to Use Bayesian Methods

| Scenario | Bayesian Advantage |
|----------|-------------------|
| Small sample sizes | Priors regularize estimates |
| Complex hierarchical models | Natural framework for multilevel data |
| Sequential data collection | Update beliefs as data arrives |
| Prior knowledge available | Formally incorporate existing evidence |
| Model comparison | Bayes factors and posterior model probabilities |
| Prediction | Full posterior predictive distributions |

## Prior Specification

### Types of Priors

```python
import numpy as np
from scipy import stats
import matplotlib.pyplot as plt

def visualize_priors(parameter_name: str, prior_type: str = 'weakly_informative'):
    """
    Visualize common prior choices for a parameter.
    """
    x = np.linspace(-10, 10, 1000)

    priors = {
        'flat': {
            'dist': stats.uniform(loc=-100, scale=200),
            'description': 'Flat/Uniform: minimal prior info (often improper)',
            'recommendation': 'Avoid -- can lead to improper posteriors'
        },
        'weakly_informative': {
            'dist': stats.norm(loc=0, scale=2.5),
            'description': 'Weakly informative: Normal(0, 2.5)',
            'recommendation': 'Good default for regression coefficients'
        },
        'informative': {
            'dist': stats.norm(loc=0.5, scale=0.2),
            'description': 'Informative: based on previous studies',
            'recommendation': 'Use when strong prior evidence exists'
        },
        'horseshoe': {
            'dist': stats.cauchy(loc=0, scale=1),
            'description': 'Horseshoe-like (Cauchy): sparsity-inducing',
            'recommendation': 'Good for variable selection problems'
        }
    }

    prior = priors.get(prior_type, priors['weakly_informative'])
    return prior

# Recommended default priors (Gelman et al., 2008):
# Intercept: Normal(0, 10)
# Coefficients: Normal(0, 2.5) on standardized predictors
# Standard deviation: Half-Cauchy(0, 2.5) or Exponential(1)
# Correlation: LKJ(2) for correlation matrices
```

## MCMC with PyMC

### Linear Regression Example

```python
import pymc as pm
import arviz as az

def bayesian_regression(X, y, feature_names=None):
    """
    Fit a Bayesian linear regression model using PyMC.

    Args:
        X: Feature matrix (n_samples, n_features)
        y: Response variable (n_samples,)
        feature_names: List of feature names
    """
    n_features = X.shape[1]
    if feature_names is None:
        feature_names = [f'x{i}' for i in range(n_features)]

    with pm.Model() as model:
        # Priors
        intercept = pm.Normal('intercept', mu=0, sigma=10)
        betas = pm.Normal('betas', mu=0, sigma=2.5, shape=n_features)
        sigma = pm.HalfCauchy('sigma', beta=2.5)

        # Linear predictor
        mu = intercept + pm.math.dot(X, betas)

        # Likelihood
        y_obs = pm.Normal('y_obs', mu=mu, sigma=sigma, observed=y)

        # MCMC sampling
        trace = pm.sample(
            draws=2000,
            tune=1000,
            chains=4,
            cores=4,
            target_accept=0.9,
            return_inferencedata=True
        )

    return model, trace

# After fitting, analyze results:
# az.summary(trace, var_names=['intercept', 'betas', 'sigma'])
# az.plot_trace(trace)
# az.plot_forest(trace, var_names=['betas'])
```

## Diagnostics

### MCMC Convergence Checks

```python
def check_mcmc_diagnostics(trace) -> dict:
    """
    Check MCMC convergence diagnostics.
    """
    summary = az.summary(trace)

    diagnostics = {
        'r_hat': {
            'values': summary['r_hat'].to_dict(),
            'threshold': 1.01,
            'pass': (summary['r_hat'] < 1.01).all(),
            'interpretation': 'R-hat < 1.01 indicates convergence'
        },
        'ess_bulk': {
            'min_value': summary['ess_bulk'].min(),
            'threshold': 400,
            'pass': (summary['ess_bulk'] > 400).all(),
            'interpretation': 'ESS > 400 ensures reliable posterior estimates'
        },
        'ess_tail': {
            'min_value': summary['ess_tail'].min(),
            'threshold': 400,
            'pass': (summary['ess_tail'] > 400).all(),
            'interpretation': 'Tail ESS > 400 ensures reliable credible intervals'
        }
    }

    # Overall assessment
    diagnostics['converged'] = all(
        d['pass'] for d in diagnostics.values() if 'pass' in d
    )

    return diagnostics
```

## Model Comparison

### Bayesian Model Selection

```python
def compare_models(traces: dict) -> dict:
    """
    Compare Bayesian models using LOO-CV and WAIC.

    Args:
        traces: Dict mapping model names to InferenceData objects
    """
    comparison = az.compare(traces, ic='loo')

    return {
        'ranking': comparison.index.tolist(),
        'loo_values': comparison['loo'].to_dict(),
        'weights': comparison['weight'].to_dict(),
        'interpretation': (
            f"Best model: {comparison.index[0]} "
            f"(weight = {comparison['weight'].iloc[0]:.2f})"
        )
    }
```

## Reporting Bayesian Results

Follow the WAMBS checklist (Depaoli & van de Schoot, 2017):

1. **Priors**: Report all prior distributions and justify choices
2. **Convergence**: Report R-hat, ESS, and trace plots (in supplement)
3. **Posteriors**: Report posterior mean/median, 95% credible interval (HDI preferred)
4. **Sensitivity**: Show results are robust to reasonable prior changes
5. **Model fit**: Report LOO-IC, WAIC, or posterior predictive checks

Example results sentence: "The effect of treatment on outcome was estimated at beta = 0.45, 95% HDI [0.21, 0.68], with a posterior probability of 0.99 that the effect is positive."

## References

- Gelman, A., et al. (2013). *Bayesian Data Analysis* (3rd ed.). CRC Press.
- McElreath, R. (2020). *Statistical Rethinking* (2nd ed.). CRC Press.
