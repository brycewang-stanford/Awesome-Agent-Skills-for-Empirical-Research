---
name: development-economics-guide
description: "Apply development economics research methods and data sources"
metadata:
  openclaw:
    emoji: "🌍"
    category: "domains"
    subcategory: "economics"
    keywords: ["development economics", "RCT", "impact evaluation", "poverty", "causal inference", "field experiments"]
    source: "wentor-research-plugins"
---

# Development Economics Guide

A skill for conducting development economics research, covering impact evaluation methods, field experiment design, household survey analysis, key data sources, and the methodological toolkit used to study poverty, education, health, and institutions in developing countries.

## Impact Evaluation Methods

### The Identification Problem

```
Fundamental question: What is the causal effect of a program/policy?

Challenge: We observe outcomes for treated individuals, but we cannot
observe what would have happened to them without treatment
(the counterfactual).

Solutions (from strongest to weakest causal identification):
  1. Randomized Controlled Trials (RCTs / field experiments)
  2. Regression Discontinuity Design (RDD)
  3. Instrumental Variables (IV)
  4. Difference-in-Differences (DiD)
  5. Matching / Propensity Score Methods
  6. Cross-sectional regression with controls (weakest)
```

### Randomized Controlled Trials in Development

```python
def design_field_experiment(intervention: str,
                             unit: str,
                             clusters: int,
                             expected_effect: float) -> dict:
    """
    Design a cluster-randomized field experiment.

    Args:
        intervention: Description of the program/policy
        unit: Unit of randomization (individual, household, village, school)
        clusters: Number of clusters available
        expected_effect: Expected effect size (standard deviations)
    """
    return {
        "intervention": intervention,
        "randomization_unit": unit,
        "design_considerations": {
            "cluster_vs_individual": (
                "Cluster randomization when intervention operates at group level "
                "or to avoid spillovers between treated and control within clusters."
            ),
            "stratification": (
                "Stratify randomization by baseline covariates (e.g., region, "
                "baseline outcome) to improve balance and statistical power."
            ),
            "sample_size": {
                "clusters": clusters,
                "note": (
                    "With cluster randomization, power depends more on number "
                    "of clusters than individuals per cluster. Aim for 20+ "
                    "clusters per arm. Account for ICC (intracluster correlation)."
                )
            },
            "expected_effect": expected_effect,
            "pre_registration": "Register at AEA RCT Registry (socialscienceregistry.org)"
        },
        "threats": [
            "Attrition (differential dropout between arms)",
            "Non-compliance (some treated do not take up, some controls do)",
            "Spillovers (treatment affects control units)",
            "Hawthorne effects (behavior changes from being observed)",
            "Ethical concerns (withholding a beneficial intervention)"
        ]
    }
```

## Difference-in-Differences

### Standard DiD Framework

```
Setup:
  Treatment group and control group
  Observed before and after the intervention

Estimator:
  DiD = (Y_treat_after - Y_treat_before) - (Y_control_after - Y_control_before)

Key assumption: Parallel trends
  In the absence of treatment, treatment and control groups would have
  followed the same trajectory over time.

Validation:
  - Plot pre-treatment trends for both groups
  - Test for pre-treatment differences in trends
  - Consider event-study specification with leads and lags
```

```python
import pandas as pd


def estimate_did(df: pd.DataFrame, outcome: str,
                 treatment_col: str, post_col: str) -> dict:
    """
    Estimate a Difference-in-Differences model.

    Args:
        df: Panel DataFrame
        outcome: Outcome variable name
        treatment_col: Binary treatment indicator
        post_col: Binary post-period indicator
    """
    from statsmodels.formula.api import ols

    df["treat_post"] = df[treatment_col] * df[post_col]

    model = ols(
        f"{outcome} ~ {treatment_col} + {post_col} + treat_post",
        data=df
    ).fit(cov_type="cluster", cov_kwds={"groups": df["cluster_id"]})

    return {
        "did_estimate": model.params["treat_post"],
        "std_error": model.bse["treat_post"],
        "p_value": model.pvalues["treat_post"],
        "ci_95": model.conf_int().loc["treat_post"].tolist(),
        "note": "Standard errors clustered at the cluster level"
    }
```

## Key Data Sources

### Major Datasets for Development Research

| Dataset | Coverage | Content |
|---------|----------|---------|
| World Bank LSMS | Multi-country | Household consumption, income, agriculture |
| DHS (Demographic and Health Surveys) | 90+ countries | Health, fertility, education, household |
| MICS (UNICEF) | 100+ countries | Child welfare indicators |
| World Development Indicators | Global | Macro indicators (GDP, poverty, health) |
| Penn World Tables | Global | PPP-adjusted GDP, capital, productivity |
| IPUMS International | Global | Census microdata harmonized across countries |
| Afrobarometer / Latinobarometro | Regional | Attitudes, governance, democracy |

## Measurement Challenges

### Common Issues in Development Data

```
Poverty measurement:
  - Consumption vs. income (consumption preferred in developing countries)
  - Purchasing power parity (PPP) adjustments
  - Poverty line selection ($2.15/day international line)

Survey design:
  - Sampling frame may miss mobile/nomadic populations
  - Recall period affects consumption estimates
  - Sensitive questions (income, violence) require careful design
  - Translation and cultural adaptation of instruments

Administrative data:
  - Often incomplete or of variable quality
  - Can complement survey data for larger populations
  - Satellite imagery increasingly used as proxy (nighttime lights, rooftop material)
```

## Publishing in Development Economics

### Where to Publish

Top general journals that publish development economics: AER, QJE, Econometrica, ReStud, JPE. Field journals: Journal of Development Economics, World Development, Economic Development and Cultural Change, World Bank Economic Review. Pre-register field experiments at the AEA RCT Registry. Make data and code available in a replication package (AEA Data and Code Repository). Follow the J-PAL research transparency guidelines for field experiments.
