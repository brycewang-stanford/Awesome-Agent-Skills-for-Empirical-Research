---
name: nonparametric-tests-guide
description: "Apply Mann-Whitney, Kruskal-Wallis, and other nonparametric methods"
metadata:
  openclaw:
    emoji: "📈"
    category: "analysis"
    subcategory: "statistics"
    keywords: ["nonparametric tests", "Mann-Whitney", "Kruskal-Wallis", "Wilcoxon", "rank-based tests", "distribution-free"]
    source: "wentor-research-plugins"
---

# Nonparametric Tests Guide

A skill for selecting and applying nonparametric statistical tests when data violate parametric assumptions. Covers rank-based tests for group comparisons, correlation, and paired data, with implementation examples and guidance on reporting.

## When to Use Nonparametric Tests

### Decision Criteria

```
Use nonparametric tests when:
  - Data are ordinal (Likert scales, rankings)
  - Distribution is clearly non-normal (heavy skew, outliers)
  - Sample size is very small (n < 15-20 per group)
  - Homogeneity of variance is violated
  - You are analyzing ranks or medians rather than means

Use parametric tests when:
  - Data are approximately normal (or n > 30 by CLT)
  - Variance is homogeneous across groups
  - You need greater statistical power
  - The parametric assumptions are reasonably met
```

### Test Selection Guide

| Parametric Test | Nonparametric Alternative | Use Case |
|----------------|--------------------------|----------|
| Independent t-test | Mann-Whitney U | Compare 2 independent groups |
| Paired t-test | Wilcoxon signed-rank | Compare 2 related samples |
| One-way ANOVA | Kruskal-Wallis H | Compare 3+ independent groups |
| Repeated measures ANOVA | Friedman test | Compare 3+ related samples |
| Pearson correlation | Spearman rank correlation | Measure association |
| Chi-square test | Fisher's exact test | Compare proportions (small n) |

## Mann-Whitney U Test

### Two Independent Groups

```python
from scipy import stats
import numpy as np


def mann_whitney_test(group_a: list, group_b: list) -> dict:
    """
    Perform Mann-Whitney U test for two independent groups.

    Args:
        group_a: Observations from group A
        group_b: Observations from group B
    """
    statistic, p_value = stats.mannwhitneyu(
        group_a, group_b, alternative="two-sided"
    )

    n_a, n_b = len(group_a), len(group_b)

    # Rank-biserial correlation as effect size
    r = 1 - (2 * statistic) / (n_a * n_b)

    return {
        "U_statistic": statistic,
        "p_value": p_value,
        "n_a": n_a,
        "n_b": n_b,
        "median_a": np.median(group_a),
        "median_b": np.median(group_b),
        "effect_size_r": abs(r),
        "effect_interpretation": (
            "small" if abs(r) < 0.3
            else "medium" if abs(r) < 0.5
            else "large"
        )
    }


# Example usage
control = [12, 15, 14, 10, 13, 11, 16, 9, 14, 12]
treatment = [18, 22, 19, 17, 20, 21, 16, 23, 19, 20]
result = mann_whitney_test(control, treatment)
print(f"U = {result['U_statistic']}, p = {result['p_value']:.4f}")
print(f"Effect size r = {result['effect_size_r']:.3f} ({result['effect_interpretation']})")
```

## Kruskal-Wallis H Test

### Three or More Independent Groups

```python
def kruskal_wallis_with_posthoc(*groups) -> dict:
    """
    Perform Kruskal-Wallis test with Dunn's post-hoc comparisons.

    Args:
        *groups: Variable number of group data arrays
    """
    # Omnibus test
    h_stat, p_value = stats.kruskal(*groups)

    result = {
        "H_statistic": h_stat,
        "p_value": p_value,
        "n_groups": len(groups),
        "group_medians": [np.median(g) for g in groups]
    }

    # If significant, perform pairwise Mann-Whitney with Bonferroni correction
    if p_value < 0.05:
        n_comparisons = len(groups) * (len(groups) - 1) // 2
        pairwise = []
        for i in range(len(groups)):
            for j in range(i + 1, len(groups)):
                u, p = stats.mannwhitneyu(groups[i], groups[j])
                pairwise.append({
                    "comparison": f"Group {i+1} vs Group {j+1}",
                    "U": u,
                    "p_raw": p,
                    "p_adjusted": min(p * n_comparisons, 1.0),
                    "significant": (p * n_comparisons) < 0.05
                })
        result["posthoc"] = pairwise

    return result
```

## Wilcoxon Signed-Rank Test

### Paired or Repeated Measures

```python
def wilcoxon_signed_rank(before: list, after: list) -> dict:
    """
    Perform Wilcoxon signed-rank test for paired data.

    Args:
        before: Pre-intervention measurements
        after: Post-intervention measurements
    """
    statistic, p_value = stats.wilcoxon(before, after)

    n = len(before)
    # Effect size: r = Z / sqrt(N)
    z_score = stats.norm.ppf(1 - p_value / 2)
    r = z_score / np.sqrt(n)

    differences = [a - b for a, b in zip(after, before)]

    return {
        "W_statistic": statistic,
        "p_value": p_value,
        "n_pairs": n,
        "median_difference": np.median(differences),
        "effect_size_r": abs(r)
    }
```

## Spearman Rank Correlation

### Monotonic Association

```python
def spearman_correlation(x: list, y: list) -> dict:
    """
    Compute Spearman rank correlation.
    """
    rho, p_value = stats.spearmanr(x, y)

    return {
        "rho": rho,
        "p_value": p_value,
        "interpretation": (
            "negligible" if abs(rho) < 0.1
            else "weak" if abs(rho) < 0.3
            else "moderate" if abs(rho) < 0.5
            else "strong" if abs(rho) < 0.7
            else "very strong"
        )
    }
```

## Reporting Nonparametric Results

### APA-Style Reporting Examples

```
Mann-Whitney U:
  "A Mann-Whitney U test indicated that treatment scores
   (Mdn = 20.0) were significantly higher than control scores
   (Mdn = 13.0), U = 5.0, p < .001, r = .82."

Kruskal-Wallis:
  "A Kruskal-Wallis H test showed a significant difference
   in scores across the three conditions, H(2) = 15.32,
   p < .001. Post-hoc pairwise comparisons with Bonferroni
   correction revealed..."

Wilcoxon Signed-Rank:
  "A Wilcoxon signed-rank test showed that the intervention
   significantly improved scores (Mdn_diff = 4.5),
   W = 12.0, p = .003, r = .58."

Spearman:
  "There was a strong positive correlation between X and Y,
   r_s = .72, p < .001."
```

### Effect Size Guidelines

Always report effect sizes alongside p-values. For rank-biserial correlation r: small (0.1), medium (0.3), large (0.5). For Spearman rho, use standard correlation benchmarks. Effect sizes allow readers to judge practical significance independent of sample size.
