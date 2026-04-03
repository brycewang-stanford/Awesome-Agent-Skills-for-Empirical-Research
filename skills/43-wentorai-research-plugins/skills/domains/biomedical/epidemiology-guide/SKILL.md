---
name: epidemiology-guide
description: "Epidemiological study designs, measures of association, and public health ana..."
metadata:
  openclaw:
    emoji: "🔬"
    category: "domains"
    subcategory: "biomedical"
    keywords: ["epidemiology", "public health", "evidence-based medicine", "clinical medicine", "disease surveillance"]
    source: "wentor"
---

# Epidemiology Guide

A skill for designing and analyzing epidemiological studies. Covers study design selection, measures of disease frequency and association, bias assessment, and public health data analysis methods.

## Study Design Selection

### Design Hierarchy

```
                    Evidence Strength
                         |
    Systematic Review / Meta-Analysis   (Highest)
                         |
         Randomized Controlled Trial
                         |
              Cohort Study (Prospective)
                         |
            Case-Control Study
                         |
         Cross-Sectional Study
                         |
         Case Report / Case Series       (Lowest)
```

### When to Use Each Design

| Design | Research Question | Time | Cost | Bias Risk |
|--------|------------------|------|------|-----------|
| RCT | Does intervention X prevent outcome Y? | Years | Very high | Lowest |
| Prospective Cohort | Does exposure X increase risk of Y? | Years | High | Moderate |
| Retrospective Cohort | Historical exposure-outcome relationship? | Months | Moderate | Moderate-High |
| Case-Control | What exposures are associated with rare disease? | Months | Low | High |
| Cross-Sectional | What is the prevalence of X? | Weeks | Low | High |
| Ecological | Do population-level factors correlate with disease? | Weeks | Very low | Very high |

## Measures of Disease Frequency

```python
import numpy as np

def compute_measures(cases: int, population: int,
                      person_time: float = None,
                      period_years: float = 1.0) -> dict:
    """
    Compute basic epidemiological measures.

    Args:
        cases: Number of new cases (for incidence) or existing cases (for prevalence)
        population: Population at risk
        person_time: Person-years of follow-up (for incidence rate)
        period_years: Time period in years (for cumulative incidence)
    """
    measures = {}

    # Point prevalence
    measures['prevalence'] = {
        'value': cases / population,
        'per_1000': (cases / population) * 1000,
        'formula': 'cases / population at a point in time'
    }

    # Cumulative incidence (risk)
    measures['cumulative_incidence'] = {
        'value': cases / population,
        'per_1000': (cases / population) * 1000,
        'period_years': period_years,
        'formula': 'new cases / population at risk during time period'
    }

    # Incidence rate (if person-time available)
    if person_time:
        measures['incidence_rate'] = {
            'value': cases / person_time,
            'per_1000_py': (cases / person_time) * 1000,
            'formula': 'new cases / person-time at risk'
        }

    return measures
```

## Measures of Association

### Risk Ratio, Odds Ratio, and Attributable Risk

```python
def measures_of_association(a: int, b: int, c: int, d: int) -> dict:
    """
    Compute epidemiological measures of association from a 2x2 table.

                    Disease+    Disease-
    Exposed+          a           b        a+b
    Exposed-          c           d        c+d
                     a+c         b+d        N

    Args:
        a: Exposed with disease
        b: Exposed without disease
        c: Unexposed with disease
        d: Unexposed without disease
    """
    # Risk in exposed and unexposed
    risk_exposed = a / (a + b)
    risk_unexposed = c / (c + d)

    # Risk Ratio (Relative Risk)
    rr = risk_exposed / risk_unexposed
    ln_rr = np.log(rr)
    se_ln_rr = np.sqrt(1/a - 1/(a+b) + 1/c - 1/(c+d))
    rr_ci = (np.exp(ln_rr - 1.96*se_ln_rr), np.exp(ln_rr + 1.96*se_ln_rr))

    # Odds Ratio
    or_val = (a * d) / (b * c)
    ln_or = np.log(or_val)
    se_ln_or = np.sqrt(1/a + 1/b + 1/c + 1/d)
    or_ci = (np.exp(ln_or - 1.96*se_ln_or), np.exp(ln_or + 1.96*se_ln_or))

    # Attributable Risk (Risk Difference)
    ar = risk_exposed - risk_unexposed
    se_ar = np.sqrt(risk_exposed*(1-risk_exposed)/(a+b) +
                     risk_unexposed*(1-risk_unexposed)/(c+d))
    ar_ci = (ar - 1.96*se_ar, ar + 1.96*se_ar)

    # Attributable Fraction in Exposed
    af_exposed = (rr - 1) / rr

    # Population Attributable Fraction
    prevalence_exposure = (a + b) / (a + b + c + d)
    paf = prevalence_exposure * (rr - 1) / (prevalence_exposure * (rr - 1) + 1)

    return {
        'risk_ratio': {'value': round(rr, 3), 'ci_95': tuple(round(x, 3) for x in rr_ci)},
        'odds_ratio': {'value': round(or_val, 3), 'ci_95': tuple(round(x, 3) for x in or_ci)},
        'risk_difference': {'value': round(ar, 4), 'ci_95': tuple(round(x, 4) for x in ar_ci)},
        'attributable_fraction_exposed': round(af_exposed, 3),
        'population_attributable_fraction': round(paf, 3),
        'number_needed_to_harm': round(1/ar, 1) if ar > 0 else None
    }

# Example: smoking and lung cancer
result = measures_of_association(a=80, b=920, c=10, d=990)
print(f"RR: {result['risk_ratio']['value']} ({result['risk_ratio']['ci_95']})")
print(f"OR: {result['odds_ratio']['value']} ({result['odds_ratio']['ci_95']})")
print(f"PAF: {result['population_attributable_fraction']}")
```

## Bias Assessment

### Types of Bias and Mitigation

| Bias Type | Description | Mitigation Strategy |
|-----------|------------|-------------------|
| Selection bias | Non-random sample selection | Random sampling, matching |
| Information bias | Measurement error in exposure/outcome | Validated instruments, blinding |
| Recall bias | Differential recall by disease status | Use records, not self-report |
| Confounding | Third variable affects both exposure and outcome | Stratification, regression, matching |
| Lead-time bias | Earlier detection misinterpreted as longer survival | Use mortality, not survival |
| Healthy worker effect | Workers are healthier than general population | Use employed comparison group |

### Confounding Assessment

```python
def assess_confounding(crude_rr: float, adjusted_rr: float,
                        threshold: float = 0.10) -> dict:
    """
    Assess whether a variable is a confounder.
    """
    pct_change = abs(crude_rr - adjusted_rr) / crude_rr * 100

    return {
        'crude_RR': crude_rr,
        'adjusted_RR': adjusted_rr,
        'percent_change': round(pct_change, 1),
        'is_confounder': pct_change > threshold * 100,
        'interpretation': (
            f"{'Confounder detected' if pct_change > threshold * 100 else 'Not a confounder'}: "
            f"adjusting changed the RR by {pct_change:.1f}% "
            f"(threshold: {threshold*100:.0f}%)"
        )
    }
```

## Survival Analysis

For time-to-event data, use Kaplan-Meier estimators for descriptive analysis, log-rank tests for group comparisons, and Cox proportional hazards regression for multivariable analysis. Always check the proportional hazards assumption using Schoenfeld residuals and report median survival times with 95% confidence intervals.

## Reporting Standards

Follow STROBE (observational studies), CONSORT (trials), or RECORD (routinely collected data) reporting guidelines. Report all measures with 95% confidence intervals. Present both crude and adjusted estimates to show the impact of confounding adjustment.
