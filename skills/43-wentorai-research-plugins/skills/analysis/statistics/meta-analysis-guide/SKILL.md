---
name: meta-analysis-guide
description: "Conduct systematic meta-analyses with effect size pooling and heterogeneity"
metadata:
  openclaw:
    emoji: "⚖️"
    category: "analysis"
    subcategory: "statistics"
    keywords: ["meta-analysis", "statistical synthesis", "heterogeneity", "effect size", "forest plot"]
    source: "wentor"
---

# Meta-Analysis Guide

A skill for conducting rigorous meta-analyses: computing and pooling effect sizes, assessing heterogeneity, evaluating publication bias, and generating forest plots. Follows Cochrane Handbook and PRISMA guidelines.

## Effect Size Computation

### Common Effect Size Measures

| Measure | Use Case | Formula | Interpretation |
|---------|----------|---------|----------------|
| Cohen's d | Mean difference (2 groups) | (M1 - M2) / S_pooled | 0.2 small, 0.5 medium, 0.8 large |
| Hedges' g | d with small-sample correction | d * J(df) | Preferred over d for small N |
| Pearson r | Correlation | r | 0.1 small, 0.3 medium, 0.5 large |
| Odds Ratio | Binary outcomes | (a*d)/(b*c) | 1 = no effect |
| Risk Ratio | Binary outcomes | (a/(a+b))/(c/(c+d)) | 1 = no effect |
| SMD | Standardized mean difference | Same as Hedges' g | When scales differ |

### Computing Effect Sizes in Python

```python
import numpy as np
from dataclasses import dataclass

@dataclass
class EffectSize:
    estimate: float
    variance: float
    se: float
    ci_lower: float
    ci_upper: float
    measure: str

def cohens_d(m1: float, m2: float, sd1: float, sd2: float,
              n1: int, n2: int) -> EffectSize:
    """
    Compute Hedges' g (bias-corrected Cohen's d).
    """
    # Pooled standard deviation
    sd_pooled = np.sqrt(((n1-1)*sd1**2 + (n2-1)*sd2**2) / (n1+n2-2))

    # Cohen's d
    d = (m1 - m2) / sd_pooled

    # Small-sample correction (Hedges' g)
    df = n1 + n2 - 2
    j = 1 - (3 / (4*df - 1))
    g = d * j

    # Variance of g
    var_g = (n1+n2)/(n1*n2) + g**2 / (2*(n1+n2))
    se_g = np.sqrt(var_g)

    return EffectSize(
        estimate=g,
        variance=var_g,
        se=se_g,
        ci_lower=g - 1.96*se_g,
        ci_upper=g + 1.96*se_g,
        measure='Hedges_g'
    )

def odds_ratio(a: int, b: int, c: int, d: int) -> EffectSize:
    """
    Compute log odds ratio from a 2x2 table.
    a=treatment success, b=treatment failure, c=control success, d=control failure
    """
    # Add 0.5 continuity correction if any cell is 0
    if any(x == 0 for x in [a, b, c, d]):
        a, b, c, d = a+0.5, b+0.5, c+0.5, d+0.5

    log_or = np.log((a*d) / (b*c))
    var = 1/a + 1/b + 1/c + 1/d
    se = np.sqrt(var)

    return EffectSize(
        estimate=log_or,
        variance=var,
        se=se,
        ci_lower=log_or - 1.96*se,
        ci_upper=log_or + 1.96*se,
        measure='log_OR'
    )
```

## Fixed-Effect and Random-Effects Models

### Inverse-Variance Pooling

```python
def random_effects_meta(effects: list[EffectSize]) -> dict:
    """
    Random-effects meta-analysis using DerSimonian-Laird estimator.
    """
    yi = np.array([e.estimate for e in effects])
    vi = np.array([e.variance for e in effects])
    wi = 1 / vi
    k = len(effects)

    # Fixed-effect estimate
    fe_estimate = np.sum(wi * yi) / np.sum(wi)

    # Q statistic for heterogeneity
    Q = np.sum(wi * (yi - fe_estimate)**2)
    df = k - 1

    # DerSimonian-Laird tau-squared
    C = np.sum(wi) - np.sum(wi**2) / np.sum(wi)
    tau2 = max(0, (Q - df) / C)

    # Random-effects weights
    wi_re = 1 / (vi + tau2)
    re_estimate = np.sum(wi_re * yi) / np.sum(wi_re)
    re_se = np.sqrt(1 / np.sum(wi_re))
    re_ci = (re_estimate - 1.96*re_se, re_estimate + 1.96*re_se)

    # Heterogeneity statistics
    I2 = max(0, (Q - df) / Q * 100) if Q > 0 else 0
    H2 = Q / df if df > 0 else 1

    return {
        'pooled_effect': re_estimate,
        'se': re_se,
        'ci_95': re_ci,
        'tau_squared': tau2,
        'Q_statistic': Q,
        'Q_df': df,
        'Q_pvalue': 1 - stats.chi2.cdf(Q, df),
        'I_squared': I2,
        'H_squared': H2,
        'interpretation': (
            f"I-squared = {I2:.1f}%: "
            + ('low' if I2 < 25 else 'moderate' if I2 < 75 else 'high')
            + ' heterogeneity'
        )
    }
```

## Forest Plot

```python
import matplotlib.pyplot as plt

def forest_plot(studies: list[dict], pooled: dict,
                title: str = 'Forest Plot') -> plt.Figure:
    """
    Create a publication-quality forest plot.

    Args:
        studies: List of dicts with 'name', 'effect', 'ci_lower', 'ci_upper', 'weight'
        pooled: Dict with 'pooled_effect', 'ci_95'
    """
    fig, ax = plt.subplots(figsize=(10, max(6, len(studies)*0.5)))
    k = len(studies)

    for i, study in enumerate(studies):
        y = k - i
        ax.plot([study['ci_lower'], study['ci_upper']], [y, y], 'b-', linewidth=1)
        size = study.get('weight', 5) * 2
        ax.plot(study['effect'], y, 'bs', markersize=max(3, min(size, 15)))
        ax.text(-0.05, y, study['name'], ha='right', va='center', fontsize=9,
                transform=ax.get_yaxis_transform())

    # Pooled estimate (diamond)
    pe = pooled['pooled_effect']
    ci = pooled['ci_95']
    ax.fill([ci[0], pe, ci[1], pe], [0.3, 0.6, 0.3, 0], 'r', alpha=0.7)

    ax.axvline(x=0, color='gray', linestyle='--', linewidth=0.5)
    ax.set_xlabel('Effect Size (Hedges g)')
    ax.set_title(title)
    ax.set_yticks([])
    plt.tight_layout()
    return fig
```

## Publication Bias Assessment

Methods to assess and address publication bias:

1. **Funnel plot**: Visual inspection for asymmetry
2. **Egger's test**: Regression test for funnel plot asymmetry (p < 0.10 suggests bias)
3. **Trim-and-fill**: Imputes missing studies to correct for bias
4. **p-curve analysis**: Tests whether significant results contain evidential value
5. **Selection models**: Formally model the publication process (e.g., Vevea-Hedges)

## Reporting Standards

Follow PRISMA 2020 guidelines for reporting:
- Report all effect sizes with 95% CIs
- Report Q, I-squared, and tau-squared for heterogeneity
- Include forest plots for all primary outcomes
- Report funnel plots and publication bias tests
- Provide subgroup analyses and sensitivity analyses (leave-one-out)
- Register the protocol on PROSPERO before conducting the review
