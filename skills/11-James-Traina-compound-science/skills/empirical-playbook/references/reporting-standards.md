# Applied Micro Toolkit: Reporting Standards and Power Analysis

Full reference for minimum reporting standards by method and power analysis formulas. Load this when preparing the empirical strategy section of a paper or conducting a formal power analysis.

---

## Minimum Reporting Standards

Based on Brodeur et al. (2020), Christensen and Miguel (2018), and AEA Data Editor guidelines.

### Every Empirical Paper Must Report

| Item | Where | Why |
|------|-------|-----|
| Sample construction | Data section | Reader must be able to reconstruct your sample from the raw data |
| Summary statistics | Table 1 | Means, SDs, N, and key percentiles for all variables used in analysis |
| Main specification | Empirical strategy section | Written as an equation with all variables defined |
| Coefficient + SE + stars | Results tables | Standard errors in parentheses; state clustering level and type |
| Number of observations | Every regression table | N for each column; explain if N varies across columns |
| R-squared or goodness-of-fit | Every regression table | Adjusted R-squared, within R-squared for FE, pseudo R-squared for nonlinear |
| Economic magnitude | Results discussion | Interpret coefficients in meaningful units (% of mean, SD change, dollar amount) |
| Identification assumptions | Empirical strategy section | Formally state (numbered if possible); discuss testable implications |
| Robustness checks | Robustness section | At minimum: alternative specifications, alternative samples, alternative standard errors |
| Falsification / placebo tests | Robustness section | Placebo outcomes, placebo treatments, placebo samples |
| Data and code availability | Footnote or appendix | State where replication package is or will be deposited |

### Method-Specific Minimum Reporting

**For IV / 2SLS:**
- First-stage regression (full table, not just F-statistic)
- First-stage F-statistic (Kleibergen-Paap if heteroskedasticity-robust)
- Reduced form (Y on Z) results
- OLS for comparison (with discussion of expected bias direction)
- Overidentification test (if overidentified)
- Discussion of LATE interpretation and complier characterization

**For DiD:**
- Event study plot with pre-treatment and post-treatment coefficients
- Pre-trend test (formal F-test on pre-treatment coefficients)
- Raw outcome means by group and period
- Discussion of parallel trends assumption with institutional context
- If staggered: Bacon decomposition or modern DiD estimator
- Sensitivity analysis for parallel trends (Rambachan-Roth)

**For RDD:**
- RD plot with binned means
- McCrary density test
- Covariate balance at cutoff
- Bandwidth sensitivity (table or plot across bandwidth range)
- Effective sample size (N within bandwidth, left and right)
- Local linear preferred; report polynomial sensitivity

**For Synthetic Control:**
- Pre-treatment fit plot (treated vs synthetic)
- Donor unit weights
- Predictor balance table (treated vs synthetic)
- Permutation (placebo) test with p-value
- Leave-one-out robustness
- RMSPE ratio

**For Matching / AIPW:**
- Propensity score distributions by treatment status (overlap plot)
- Covariate balance (Love plot or SMD table) before and after matching
- Sensitivity analysis (Oster bounds, Rosenbaum bounds, or Altonji-Elder-Taber ratio)
- Results under alternative PS specifications
- Trimming sensitivity
- Effective sample size after weighting

---

## Power Analysis Guide

### Why Power Matters

An underpowered study that fails to reject the null is uninformative — it cannot distinguish "no effect" from "too little data to detect an effect." Power analysis should be done before data collection (prospective) or, for observational studies, before running the main specification (to set expectations about what effects are detectable).

### Core Concepts

| Concept | Definition | Typical Value |
|---------|-----------|---------------|
| Significance level (alpha) | Probability of rejecting H0 when H0 is true (Type I error) | 0.05 |
| Power (1 - beta) | Probability of rejecting H0 when H1 is true | 0.80 (minimum) |
| Minimum Detectable Effect (MDE) | Smallest effect size the study can detect with specified power | Depends on context |
| Effect size (Cohen's d) | Standardized effect: d = (mu1 - mu0) / sigma | Small: 0.2, Medium: 0.5, Large: 0.8 |
| Intraclass correlation (ICC) | Share of variance between clusters (for cluster-randomized) | 0.01-0.20 typical |

### MDE Formula for Standard Designs

**Simple two-group comparison:**

```
MDE = (t_alpha/2 + t_beta) * sigma * sqrt(1/N_T + 1/N_C)

Where:
  t_alpha/2 = 1.96 for alpha = 0.05 (two-sided)
  t_beta    = 0.84 for power = 0.80
  sigma     = standard deviation of outcome
  N_T, N_C  = sample sizes in treatment and control
```

**With equal groups (N_T = N_C = N/2):**

```
MDE = 2.8 * sigma / sqrt(N)
```

This means you need `N = (2.8 * sigma / MDE)^2` total observations.

**Cluster-randomized design:**

```
MDE = (t_alpha/2 + t_beta) * sigma * sqrt((1 + (m-1)*ICC) * (1/J_T + 1/J_C) / m)

Where:
  J_T, J_C = number of clusters in treatment and control
  m        = average cluster size
  ICC      = intraclass correlation
```

The design effect `(1 + (m-1)*ICC)` inflates the MDE. With ICC = 0.05 and m = 50, the design effect is 3.45 — you need 3.45 times as many observations as a non-clustered design.

### Power for DiD

```
MDE_DiD = (t_alpha/2 + t_beta) * sigma_epsilon * sqrt(1 / (N_T * T_post * (1 - R^2)))

Where:
  sigma_epsilon = residual SD after removing unit and time FEs
  T_post        = number of post-treatment periods
  R^2           = R-squared from the outcome regression (higher = more power)
```

Key insight: DiD gains power from more post-treatment periods and from higher within-group correlation (which is absorbed by FEs, reducing residual variance).

### Power for IV / 2SLS

IV estimates have larger standard errors than OLS. As a rule of thumb:

```
SE_IV ≈ SE_OLS / first_stage_coefficient

Equivalently:
MDE_IV ≈ MDE_OLS / |pi| * sqrt(1 + 1/F)

Where:
  pi = first-stage coefficient
  F  = first-stage F-statistic
```

With a first-stage F of 10, the IV MDE is approximately `MDE_OLS / |pi| * sqrt(1.1)` — much larger than the OLS MDE when pi is small. IV requires much larger samples than OLS to detect the same effect.

### Power for RDD

RDD uses only observations near the cutoff, so effective sample size is much smaller than total N:

```
Effective N ≈ N * h / range(X)

Where:
  h        = bandwidth
  range(X) = range of the running variable
```

If only 10% of observations fall within the bandwidth, the effective sample size is roughly N/10. MDE calculations should use this effective N. RDD is inherently less powered than designs that use the full sample.

### Simulation-Based Power

For nonstandard designs where analytical formulas do not exist, simulate:

```python
import numpy as np
from scipy import stats

def power_simulation(n, effect_size, sigma, n_sims=5000, alpha=0.05):
    """Simulate power for a two-group comparison."""
    rejections = 0
    n_treat = n // 2
    n_control = n - n_treat

    for _ in range(n_sims):
        y_control = np.random.normal(0, sigma, n_control)
        y_treat = np.random.normal(effect_size, sigma, n_treat)
        t_stat, p_value = stats.ttest_ind(y_treat, y_control)
        if p_value < alpha:
            rejections += 1

    return rejections / n_sims

# Example: 80% power to detect effect of 0.3 SD with N=350
power = power_simulation(n=350, effect_size=0.3, sigma=1.0)
print(f"Power: {power:.3f}")
```

**For DiD:**

```python
def power_did_simulation(n_units, n_periods, treat_share, effect_size,
                          sigma_unit, sigma_time, sigma_eps,
                          n_sims=2000, alpha=0.05):
    """Simulate power for a canonical DiD design."""
    import statsmodels.formula.api as smf
    import pandas as pd

    rejections = 0
    n_treat = int(n_units * treat_share)
    t_post = n_periods // 2

    for _ in range(n_sims):
        unit_fe = np.random.normal(0, sigma_unit, n_units)
        time_fe = np.random.normal(0, sigma_time, n_periods)
        treat = np.array([1]*n_treat + [0]*(n_units - n_treat))

        rows = []
        for i in range(n_units):
            for t in range(n_periods):
                post = int(t >= t_post)
                y = (unit_fe[i] + time_fe[t]
                     + effect_size * treat[i] * post
                     + np.random.normal(0, sigma_eps))
                rows.append({'unit': i, 'time': t, 'y': y,
                            'treat': treat[i], 'post': post,
                            'treat_post': treat[i] * post})

        df = pd.DataFrame(rows)
        result = smf.ols('y ~ C(unit) + C(time) + treat_post', data=df).fit()
        if result.pvalues.get('treat_post', 1.0) < alpha:
            rejections += 1

    return rejections / n_sims
```

**For Cluster-Randomized Designs:**

```python
def power_cluster_simulation(n_clusters, cluster_size, effect_size,
                              icc, sigma, n_sims=2000, alpha=0.05):
    """Simulate power for a cluster-randomized design."""
    rejections = 0
    n_treat_clusters = n_clusters // 2
    sigma_between = np.sqrt(icc) * sigma
    sigma_within = np.sqrt(1 - icc) * sigma

    for _ in range(n_sims):
        treat = np.array([1]*n_treat_clusters + [0]*(n_clusters - n_treat_clusters))
        cluster_effects = np.random.normal(0, sigma_between, n_clusters)
        y_list = []; t_list = []; c_list = []

        for j in range(n_clusters):
            y_j = (effect_size * treat[j] + cluster_effects[j]
                   + np.random.normal(0, sigma_within, cluster_size))
            y_list.extend(y_j); t_list.extend([treat[j]] * cluster_size)
            c_list.extend([j] * cluster_size)

        y = np.array(y_list); c = np.array(c_list)
        means_t = [np.mean(y[c==j]) for j in range(n_clusters) if treat[j]==1]
        means_c = [np.mean(y[c==j]) for j in range(n_clusters) if treat[j]==0]
        if stats.ttest_ind(means_t, means_c).pvalue < alpha:
            rejections += 1

    return rejections / n_sims
```

### Power Analysis Reporting

Every power analysis should report:

| Item | Description |
|------|-------------|
| Target parameter | What effect are you trying to detect? |
| MDE | The minimum effect you can detect with 80% power |
| MDE in context | Is the MDE substantively meaningful? Compare to existing estimates |
| Assumptions | Outcome variance, ICC (for clustered), autocorrelation (for panel), first-stage strength (for IV) |
| Method | Analytical formula, simulation-based, or both |
| Sensitivity | How MDE changes with N, alpha, ICC, etc. |

**MDE Interpretation Guide:**

| MDE relative to existing estimates | Assessment |
|------------------------------------|------------|
| MDE < 0.5 * prior estimate | Well-powered for the expected effect |
| MDE ≈ prior estimate | Marginal power — 50/50 chance of detecting the effect |
| MDE > 2 * prior estimate | Underpowered — null result will be uninformative |
| No prior estimate available | Compare MDE to smallest policy-relevant effect |

---

## Specification Curve Analysis

When there are many defensible specification choices, a specification curve (Simonsohn, Simmons, and Nelson 2020) shows how results vary across all of them.

### What to Vary

| Dimension | Example Choices |
|-----------|----------------|
| Control variables | None, demographic controls, full controls, kitchen-sink |
| Sample definition | Full sample, balanced panel, no outliers, alternative age/time cutoffs |
| Functional form | Linear, log, levels, first differences |
| Standard errors | Robust, clustered (at different levels), wild bootstrap |
| Outcome variable | Alternative measures of the same concept |
| Treatment definition | Binary vs continuous, different treatment timing, ITT vs TOT |
| Estimation method | OLS, IV, matching, doubly robust |
| Fixed effects | None, unit FE, time FE, unit + time FE, unit trends |

### Implementation

```python
import itertools

# Define specification choices
specs = {
    'controls': ['none', 'basic', 'full'],
    'sample': ['full', 'balanced', 'no_outliers'],
    'se_type': ['robust', 'clustered_state'],
    'fe': ['unit_time', 'unit_time_trends'],
}

# Generate all combinations
all_specs = list(itertools.product(*specs.values()))
# For each specification, estimate the model and store:
# (coefficient, se, p_value, specification_choices)

# Plot: sort specifications by coefficient, show CI for each
# Mark "preferred" specification
# Report: median coefficient, share significant, share positive
```

### Reporting

- Plot all specifications sorted by effect size, with confidence intervals.
- Highlight the "preferred" specification but show it is not cherry-picked.
- Report: share of specifications with significant effects, share with the same sign, median effect size.
- This is a complement to robustness tables, not a replacement.
