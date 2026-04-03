---
name: hypothesis-testing-guide
description: "Statistical hypothesis testing, power analysis, and significance reporting"
metadata:
  openclaw:
    emoji: "📈"
    category: "analysis"
    subcategory: "statistics"
    keywords: ["hypothesis testing", "significance testing", "t-test", "ANOVA", "sample size calculation", "power analysis"]
    source: "N/A"
---

# Hypothesis Testing Guide

## Overview

Hypothesis testing is the backbone of empirical research. It provides a principled framework for deciding whether observed differences in data reflect genuine effects or merely random variation. Misuse of hypothesis tests -- p-hacking, ignoring assumptions, confusing statistical and practical significance -- is a leading cause of irreproducible findings.

This guide covers the core hypothesis testing framework, the most commonly used tests across disciplines, assumption checking, effect size reporting, power analysis for sample size planning, and multiple comparison corrections. Each test is accompanied by Python code using scipy, statsmodels, and pingouin, ready to integrate into research workflows.

The goal is not just to help you run tests, but to help you run the right test correctly and report results following modern standards (APA 7th edition, journal best practices).

## The Hypothesis Testing Framework

### Step-by-Step Procedure

1. **State hypotheses.** Define H0 (null: no effect) and H1 (alternative: effect exists).
2. **Choose significance level.** Typically alpha = 0.05, but justify your choice.
3. **Select the appropriate test.** Based on data type, distribution, and design.
4. **Check assumptions.** Normality, homogeneity of variance, independence.
5. **Compute test statistic and p-value.**
6. **Report effect size and confidence interval.** p-values alone are insufficient.
7. **Make a decision.** Reject or fail to reject H0, with practical interpretation.

### Common Errors

| Error Type | Definition | Probability |
|-----------|-----------|-------------|
| Type I (False Positive) | Reject H0 when it is true | alpha (usually 0.05) |
| Type II (False Negative) | Fail to reject H0 when it is false | beta (usually 0.20) |
| Power | Probability of correctly detecting an effect | 1 - beta (target: 0.80) |

## Test Selection Guide

| Research Question | Data Type | Groups | Test |
|-------------------|-----------|--------|------|
| Two group means differ? | Continuous, normal | 2 independent | Independent t-test |
| Before/after difference? | Continuous, normal | 2 paired | Paired t-test |
| Multiple group means differ? | Continuous, normal | 3+ independent | One-way ANOVA |
| Two group medians differ? | Ordinal / non-normal | 2 independent | Mann-Whitney U |
| Before/after (non-normal)? | Ordinal / non-normal | 2 paired | Wilcoxon signed-rank |
| Multiple groups (non-normal)? | Ordinal / non-normal | 3+ independent | Kruskal-Wallis |
| Association between categories? | Categorical | 2 variables | Chi-square test |
| Correlation? | Continuous | 2 variables | Pearson or Spearman |

## Running Tests in Python

### Independent Samples t-Test

```python
from scipy import stats
import numpy as np
import pingouin as pg

# Generate example data
control = np.random.normal(50, 10, n=30)
treatment = np.random.normal(55, 10, n=30)

# Check normality assumption
stat_c, p_c = stats.shapiro(control)
stat_t, p_t = stats.shapiro(treatment)
print(f"Normality p-values: control={p_c:.3f}, treatment={p_t:.3f}")

# Check homogeneity of variance
stat_l, p_l = stats.levene(control, treatment)
print(f"Levene's test p={p_l:.3f}")

# Run t-test
t_stat, p_val = stats.ttest_ind(control, treatment, equal_var=(p_l > 0.05))

# Effect size (Cohen's d)
cohens_d = (treatment.mean() - control.mean()) / np.sqrt(
    ((len(control)-1)*control.var() + (len(treatment)-1)*treatment.var())
    / (len(control) + len(treatment) - 2)
)

print(f"t={t_stat:.3f}, p={p_val:.4f}, Cohen's d={cohens_d:.3f}")
```

### One-Way ANOVA with Post-Hoc Tests

```python
import pandas as pd

df = pd.DataFrame({
    'score': np.concatenate([
        np.random.normal(50, 10, 30),
        np.random.normal(55, 10, 30),
        np.random.normal(60, 10, 30)
    ]),
    'group': np.repeat(['A', 'B', 'C'], 30)
})

# ANOVA
aov = pg.anova(data=df, dv='score', between='group', detailed=True)
print(aov)

# Post-hoc pairwise comparisons (Tukey HSD)
posthoc = pg.pairwise_tukey(data=df, dv='score', between='group')
print(posthoc[['A', 'B', 'diff', 'p-tukey', 'hedges']])
```

### Chi-Square Test of Independence

```python
# Contingency table
observed = pd.DataFrame(
    [[45, 30], [25, 50]],
    index=['Method A', 'Method B'],
    columns=['Success', 'Failure']
)

chi2, p, dof, expected = stats.chi2_contingency(observed)
cramers_v = np.sqrt(chi2 / (observed.values.sum() * (min(observed.shape) - 1)))

print(f"chi2={chi2:.3f}, p={p:.4f}, Cramer's V={cramers_v:.3f}")
```

## Power Analysis and Sample Size

Power analysis answers: "How many participants do I need?"

```python
from statsmodels.stats.power import TTestIndPower, FTestAnovaPower

# For a two-sample t-test
analysis = TTestIndPower()

# Calculate required sample size
n = analysis.solve_power(
    effect_size=0.5,   # Cohen's d (medium effect)
    alpha=0.05,
    power=0.80,
    ratio=1.0,         # Equal group sizes
    alternative='two-sided'
)
print(f"Required n per group: {int(np.ceil(n))}")

# Power curve
import matplotlib.pyplot as plt

sample_sizes = np.arange(10, 200, 5)
powers = [analysis.power(effect_size=0.5, nobs1=n, ratio=1.0, alpha=0.05)
          for n in sample_sizes]

fig, ax = plt.subplots()
ax.plot(sample_sizes, powers)
ax.axhline(0.8, color='red', linestyle='--', label='Power = 0.80')
ax.set_xlabel('Sample Size per Group')
ax.set_ylabel('Statistical Power')
ax.legend()
fig.savefig('power_curve.pdf')
```

### Effect Size Reference Table

| Effect Size | Small | Medium | Large |
|-------------|-------|--------|-------|
| Cohen's d (t-test) | 0.2 | 0.5 | 0.8 |
| eta-squared (ANOVA) | 0.01 | 0.06 | 0.14 |
| Cramer's V (chi-square) | 0.1 | 0.3 | 0.5 |
| Pearson r (correlation) | 0.1 | 0.3 | 0.5 |

## Multiple Comparison Corrections

When running multiple tests, the family-wise error rate inflates. Use corrections:

```python
from statsmodels.stats.multitest import multipletests

p_values = [0.01, 0.04, 0.03, 0.08, 0.002]

# Bonferroni (conservative)
reject_bonf, pvals_bonf, _, _ = multipletests(p_values, method='bonferroni')

# Benjamini-Hochberg FDR (less conservative)
reject_bh, pvals_bh, _, _ = multipletests(p_values, method='fdr_bh')

for i, p in enumerate(p_values):
    print(f"p={p:.3f} | Bonferroni: {pvals_bonf[i]:.3f} ({reject_bonf[i]}) "
          f"| BH-FDR: {pvals_bh[i]:.3f} ({reject_bh[i]})")
```

## Best Practices

- **Always report effect sizes alongside p-values.** A significant p-value with a tiny effect size is rarely meaningful.
- **Pre-register your analysis plan.** This prevents p-hacking and HARKing (Hypothesizing After Results are Known).
- **Check assumptions before running parametric tests.** Use non-parametric alternatives when assumptions are violated.
- **Use confidence intervals.** They convey both effect magnitude and precision.
- **Report exact p-values (p = 0.032), not thresholds (p < 0.05).** Except when p < 0.001.
- **Consider Bayesian alternatives.** Bayes factors provide evidence for H0, not just against it.
- **Plan sample sizes a priori.** Power analysis should be done before data collection, not after.

## References

- [scipy.stats Documentation](https://docs.scipy.org/doc/scipy/reference/stats.html)
- [pingouin Documentation](https://pingouin-stats.org/) -- Friendly statistics in Python
- [statsmodels Documentation](https://www.statsmodels.org/)
- [APA 7th Edition Statistics Reporting Guide](https://apastyle.apa.org/instructional-aids/numbers-statistics-guide.pdf)
- [Statistical Tests Cheat Sheet](https://machinelearningmastery.com/statistical-hypothesis-tests-in-python-cheat-sheet/)
