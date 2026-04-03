---
name: modeling-strategy-guide
description: "Strategic statistical modeling, experimentation, and causal inference"
metadata:
  openclaw:
    emoji: "🎯"
    category: "analysis"
    subcategory: "statistics"
    keywords: ["statistical modeling", "causal inference", "A/B testing", "experimentation", "feature engineering", "data science"]
    source: "wentor-research-plugins"
---

# Modeling Strategy Guide

A skill for strategic statistical modeling applied to academic research. Covers advanced modeling decisions, experimental design, causal inference, feature engineering, and the critical thinking required to move from data to defensible conclusions.

## Overview

Senior data scientists distinguish themselves not by knowing more algorithms but by asking better questions, designing cleaner experiments, and being honest about what the data can and cannot tell them. This skill translates that professional discipline into a research context, helping academics apply modern data science practices to their empirical work. It covers the strategic decisions that matter most: when to use simple models versus complex ones, how to establish causality rather than mere correlation, and how to communicate uncertainty honestly.

The skill is particularly useful for researchers working with observational data who need causal inference techniques, those designing randomized experiments who need proper power calculations and analysis plans, and anyone building predictive models who needs to avoid common overfitting and leakage pitfalls.

## Strategic Modeling Decisions

### Model Selection Philosophy

```
Decision Framework:
1. Start with the simplest model that could answer your question
2. Add complexity only when diagnostics reveal inadequacy
3. Prefer interpretable models unless prediction accuracy is the sole goal
4. Always have a baseline (mean, majority class, last observation)

Model Complexity Ladder:
  Level 1: Descriptive statistics, cross-tabulations
  Level 2: Linear/logistic regression
  Level 3: Regularized regression (Lasso, Ridge, Elastic Net)
  Level 4: Tree ensembles (Random Forest, Gradient Boosting)
  Level 5: Deep learning (only with sufficient data and clear justification)
```

### Feature Engineering Principles

```python
import pandas as pd
import numpy as np

def engineer_features(df: pd.DataFrame, config: dict) -> pd.DataFrame:
    """
    Apply systematic feature engineering based on domain knowledge.

    config example:
    {
        'log_transform': ['income', 'citations'],
        'interactions': [('experience', 'education')],
        'polynomial': {'age': 2},
        'time_features': 'date_column',
        'lag_features': {'metric': [1, 7, 30]}
    }
    """
    df = df.copy()

    # Log transforms for right-skewed variables
    for col in config.get('log_transform', []):
        df[f'{col}_log'] = np.log1p(df[col])

    # Interaction terms
    for col_a, col_b in config.get('interactions', []):
        df[f'{col_a}_x_{col_b}'] = df[col_a] * df[col_b]

    # Polynomial features
    for col, degree in config.get('polynomial', {}).items():
        for d in range(2, degree + 1):
            df[f'{col}_pow{d}'] = df[col] ** d

    # Time-based features
    if 'time_features' in config:
        time_col = config['time_features']
        df[time_col] = pd.to_datetime(df[time_col])
        df[f'{time_col}_month'] = df[time_col].dt.month
        df[f'{time_col}_dayofweek'] = df[time_col].dt.dayofweek
        df[f'{time_col}_quarter'] = df[time_col].dt.quarter

    return df
```

## Causal Inference Methods

### Beyond Correlation

| Method | When to Use | Key Assumption |
|--------|-----------|---------------|
| Randomized experiment | You can randomly assign treatment | Proper randomization, no attrition |
| Difference-in-differences | Policy change affects one group | Parallel trends pre-treatment |
| Regression discontinuity | Treatment assigned by cutoff | No manipulation near cutoff |
| Instrumental variables | Endogeneity present | Valid instrument (relevance + exclusion) |
| Propensity score matching | Observational data, many confounders | No unobserved confounders |
| Synthetic control | Single treated unit, many controls | Good pre-treatment fit |

### Propensity Score Matching

```python
from sklearn.linear_model import LogisticRegression
from sklearn.neighbors import NearestNeighbors

def propensity_score_match(df, treatment_col, covariates, caliper=0.05):
    """
    Match treated and control units based on propensity scores.
    """
    # Estimate propensity scores
    X = df[covariates].values
    y = df[treatment_col].values

    lr = LogisticRegression(max_iter=1000, random_state=42)
    lr.fit(X, y)
    df['pscore'] = lr.predict_proba(X)[:, 1]

    # Match using nearest neighbor within caliper
    treated = df[df[treatment_col] == 1]
    control = df[df[treatment_col] == 0]

    nn = NearestNeighbors(n_neighbors=1, metric='euclidean')
    nn.fit(control[['pscore']].values)

    distances, indices = nn.kneighbors(treated[['pscore']].values)

    # Apply caliper
    valid = distances.flatten() < caliper
    matched_treated = treated[valid].index.tolist()
    matched_control = control.iloc[indices.flatten()[valid]].index.tolist()

    return {
        'matched_treated': matched_treated,
        'matched_control': matched_control,
        'n_matched': sum(valid),
        'n_unmatched': sum(~valid),
        'balance_check': 'Run standardized mean differences on covariates'
    }
```

## Experimentation Design

### A/B Testing for Research

```python
from scipy import stats
import numpy as np

def design_experiment(baseline_rate, mde, alpha=0.05, power=0.80):
    """
    Calculate required sample size for a two-proportion z-test.

    Args:
        baseline_rate: Current conversion/success rate
        mde: Minimum detectable effect (absolute change)
        alpha: Significance level
        power: Statistical power
    """
    from statsmodels.stats.power import NormalIndPower
    effect_size = mde / np.sqrt(baseline_rate * (1 - baseline_rate))
    analysis = NormalIndPower()
    n = analysis.solve_power(
        effect_size=effect_size, alpha=alpha, power=power, ratio=1.0
    )
    return {
        'sample_size_per_group': int(np.ceil(n)),
        'total_sample_size': int(np.ceil(n)) * 2,
        'baseline_rate': baseline_rate,
        'minimum_detectable_effect': mde,
        'alpha': alpha,
        'power': power
    }
```

### Pre-Analysis Plan Template

Before running any experiment, document:

1. **Primary hypothesis**: One clearly stated prediction.
2. **Primary outcome metric**: One pre-specified metric for the main test.
3. **Sample size justification**: Power calculation with assumptions.
4. **Randomization procedure**: How units are assigned to conditions.
5. **Analysis method**: Exact statistical test and model specification.
6. **Multiple comparisons**: How secondary analyses will be corrected.
7. **Stopping rules**: Conditions for early termination (if applicable).

## Model Validation

### Cross-Validation Strategy

| Data Type | Recommended CV | Rationale |
|-----------|---------------|-----------|
| i.i.d. data | Stratified K-fold (K=5 or 10) | Preserves class balance |
| Time series | Time-series split (expanding window) | Prevents look-ahead bias |
| Grouped data | Group K-fold | Prevents data leakage across groups |
| Small dataset (n<200) | Leave-one-out or repeated K-fold | Maximizes training data |
| Spatial data | Spatial blocking | Prevents spatial autocorrelation leakage |

### Leakage Detection Checklist

- [ ] No future information used as features (check timestamps)
- [ ] No target-derived features (e.g., group means computed on full data)
- [ ] Train/test split performed before any preprocessing
- [ ] Cross-validation folds respect group structure
- [ ] Feature selection performed inside CV loop, not before
- [ ] If accuracy seems too good to be true, it probably is

## Communication and Reporting

### The Senior DS Reporting Standard

- Lead with the business/research question, not the algorithm.
- Report confidence intervals, not just point estimates.
- Show what you tried that did not work (negative results matter).
- Quantify uncertainty: "The model predicts X with a 95% interval of [a, b]."
- Be explicit about limitations and assumptions.
- Use visualizations that a domain expert (not a statistician) can interpret.

## References

- Angrist, J. D. & Pischke, J.-S. (2009). *Mostly Harmless Econometrics*. Princeton University Press.
- Cunningham, S. (2021). *Causal Inference: The Mixtape*. Yale University Press.
- Hastie, T., Tibshirani, R., & Friedman, J. (2009). *The Elements of Statistical Learning* (2nd ed.). Springer.
