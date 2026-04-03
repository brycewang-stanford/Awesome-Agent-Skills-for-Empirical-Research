---
name: power-analysis-guide
description: "Sample size calculation and statistical power analysis guide"
metadata:
  openclaw:
    emoji: "🎯"
    category: "analysis"
    subcategory: "statistics"
    keywords: ["sample size calculation", "power analysis", "effect size", "significance testing"]
    source: "wentor-research-plugins"
---

# Power Analysis Guide

Calculate appropriate sample sizes for your study using power analysis, understand effect sizes, and avoid underpowered or wastefully overpowered designs.

## Core Concepts

### The Four Parameters of Power Analysis

Every power analysis involves four interrelated quantities. Fix any three to solve for the fourth:

| Parameter | Symbol | Definition | Typical Value |
|-----------|--------|-----------|---------------|
| **Effect size** | d, r, f, etc. | Magnitude of the phenomenon you expect to detect | Varies by field |
| **Significance level** (alpha) | alpha | Probability of Type I error (false positive) | 0.05 |
| **Statistical power** (1 - beta) | 1 - beta | Probability of detecting a true effect | 0.80 or 0.90 |
| **Sample size** | N | Number of observations needed | Solve for this |

### Error Types

| | H0 is true (no effect) | H0 is false (effect exists) |
|---|---|---|
| **Reject H0** | Type I error (alpha) | Correct (power = 1 - beta) |
| **Fail to reject H0** | Correct (1 - alpha) | Type II error (beta) |

## Effect Size Conventions

### Cohen's d (Two-Group Comparison)

```
d = (M1 - M2) / SD_pooled
```

| Size | Cohen's d | Interpretation |
|------|-----------|---------------|
| Small | 0.2 | Subtle, may need large N to detect |
| Medium | 0.5 | Noticeable, typical in social sciences |
| Large | 0.8 | Obvious, often visible without statistics |

### Correlation (r)

| Size | r | r-squared |
|------|---|-----------|
| Small | 0.1 | 1% variance explained |
| Medium | 0.3 | 9% variance explained |
| Large | 0.5 | 25% variance explained |

### Cohen's f (ANOVA)

| Size | f | Equivalent eta-squared |
|------|---|----------------------|
| Small | 0.10 | 0.01 |
| Medium | 0.25 | 0.06 |
| Large | 0.40 | 0.14 |

### Odds Ratio (Logistic Regression)

| Size | OR |
|------|-----|
| Small | 1.5 |
| Medium | 2.5 |
| Large | 4.0 |

## Power Analysis in Python (statsmodels)

### Two-Sample t-Test

```python
from statsmodels.stats.power import TTestIndPower

analysis = TTestIndPower()

# Solve for sample size
n = analysis.solve_power(
    effect_size=0.5,    # Cohen's d = medium
    alpha=0.05,         # Significance level
    power=0.80,         # 80% power
    ratio=1.0,          # Equal group sizes
    alternative='two-sided'
)
print(f"Required N per group: {int(n) + 1}")  # Output: 64

# Solve for power (given N)
power = analysis.solve_power(
    effect_size=0.5,
    alpha=0.05,
    nobs1=50,
    ratio=1.0,
    alternative='two-sided'
)
print(f"Power with N=50 per group: {power:.3f}")  # Output: 0.697
```

### Paired t-Test

```python
from statsmodels.stats.power import TTestPower

analysis = TTestPower()
n = analysis.solve_power(
    effect_size=0.3,    # Small-medium effect
    alpha=0.05,
    power=0.80,
    alternative='two-sided'
)
print(f"Required N (paired): {int(n) + 1}")  # Output: 90
```

### One-Way ANOVA

```python
from statsmodels.stats.power import FTestAnovaPower

analysis = FTestAnovaPower()
n = analysis.solve_power(
    effect_size=0.25,   # Cohen's f = medium
    alpha=0.05,
    power=0.80,
    k_groups=4          # Number of groups
)
print(f"Required N per group: {int(n) + 1}")  # Output: 45
```

### Chi-Square Test

```python
from statsmodels.stats.power import GofChisquarePower

analysis = GofChisquarePower()
n = analysis.solve_power(
    effect_size=0.3,    # Cohen's w = medium
    alpha=0.05,
    power=0.80,
    n_bins=4            # Degrees of freedom + 1
)
print(f"Required total N: {int(n) + 1}")
```

### Multiple Regression

```python
from statsmodels.stats.power import FTestPower

analysis = FTestPower()
# For R-squared: convert to f2 = R2 / (1 - R2)
r_squared = 0.10  # Expected R-squared for the model
f2 = r_squared / (1 - r_squared)  # f2 = 0.111

n = analysis.solve_power(
    effect_size=f2,
    alpha=0.05,
    power=0.80,
    df_num=5            # Number of predictors
)
# n returned is df_denom; total N = n + df_num + 1
total_n = int(n) + 5 + 1
print(f"Required total N: {total_n}")
```

## Power Analysis in R (pwr Package)

```r
library(pwr)

# Two-sample t-test
result <- pwr.t.test(d = 0.5, sig.level = 0.05, power = 0.80,
                     type = "two.sample", alternative = "two.sided")
cat("N per group:", ceiling(result$n), "\n")

# Correlation test
result <- pwr.r.test(r = 0.3, sig.level = 0.05, power = 0.80,
                     alternative = "two.sided")
cat("Total N:", ceiling(result$n), "\n")

# One-way ANOVA (4 groups)
result <- pwr.anova.test(k = 4, f = 0.25, sig.level = 0.05, power = 0.80)
cat("N per group:", ceiling(result$n), "\n")

# Chi-square test
result <- pwr.chisq.test(w = 0.3, df = 3, sig.level = 0.05, power = 0.80)
cat("Total N:", ceiling(result$N), "\n")

# Plot power curve
result <- pwr.t.test(d = 0.5, sig.level = 0.05, power = NULL,
                     n = seq(10, 200, by = 5))
plot(result)
```

## Using G*Power (Desktop Application)

G*Power (gpower.hhu.de) is a free, widely-used GUI application for power analysis:

1. **Select test family**: t-tests, F-tests, chi-square, z-tests, exact tests
2. **Select statistical test**: e.g., "Means: Difference between two independent means (two groups)"
3. **Select type of analysis**: A priori (compute N), Post hoc (compute power), Sensitivity (compute detectable effect)
4. **Input parameters**: Effect size, alpha, power, allocation ratio
5. **Calculate**: Click "Calculate" to get the result
6. **Plot**: Use "X-Y plot for a range of values" to visualize power curves

## Practical Recommendations

### Choosing Effect Sizes

Do NOT blindly use Cohen's conventions. Instead:

1. **Literature review**: Find effect sizes reported in similar studies
2. **Pilot data**: Run a small pilot study to estimate the effect
3. **Smallest effect of interest (SESOI)**: What is the smallest effect that would be practically meaningful?
4. **Meta-analyses**: Use pooled effect sizes from meta-analyses in your area

### Common Mistakes

| Mistake | Problem | Solution |
|---------|---------|----------|
| Post hoc power analysis | Circular and uninformative after data collection | Only do a priori power analysis |
| Using Cohen's "medium" by default | May be unrealistic for your field | Base on literature or SESOI |
| Ignoring attrition | Actual N may be lower than planned | Inflate N by 10-20% for expected dropout |
| Forgetting multiple comparisons | Bonferroni corrections reduce power | Adjust alpha for the number of tests |
| Not reporting power analysis | Reviewers cannot evaluate adequacy | Always report in Methods section |

### Reporting Template

```
A priori power analysis was conducted using [G*Power 3.1 / statsmodels / R pwr].
For a [test name] with an expected effect size of [d/r/f = X] (based on
[source: previous study / meta-analysis / pilot data]), alpha = .05, and
power = .80, the required sample size was [N per group / total N]. To account
for an estimated [X]% attrition rate, we recruited [final N] participants.
```
