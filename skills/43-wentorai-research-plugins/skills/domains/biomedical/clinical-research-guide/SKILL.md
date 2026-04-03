---
name: clinical-research-guide
description: "Design clinical studies and report using CONSORT, STROBE guidelines"
metadata:
  openclaw:
    emoji: "🏥"
    category: "domains"
    subcategory: "biomedical"
    keywords: ["clinical research", "CONSORT", "STROBE", "clinical trial", "study design", "reporting guidelines"]
    source: "wentor-research-plugins"
---

# Clinical Research Guide

A skill for designing clinical studies and reporting results according to established guidelines. Covers randomized controlled trials (CONSORT), observational studies (STROBE), diagnostic studies (STARD), and systematic reviews (PRISMA).

## Study Design Selection

### Hierarchy of Evidence

```
Systematic Reviews / Meta-analyses
       |
Randomized Controlled Trials (RCTs)
       |
Cohort Studies (prospective)
       |
Case-Control Studies
       |
Cross-Sectional Studies
       |
Case Reports / Case Series
       |
Expert Opinion

Choose the design that best answers your research question
given ethical, practical, and resource constraints.
```

### Design Decision Framework

```python
def select_study_design(research_question: str,
                        can_randomize: bool,
                        outcome_prevalence: str,
                        time_constraint: str) -> dict:
    """
    Guide selection of clinical study design.

    Args:
        research_question: The clinical question
        can_randomize: Whether randomization is ethical and feasible
        outcome_prevalence: 'common' or 'rare'
        time_constraint: 'short', 'medium', or 'long'
    """
    if can_randomize:
        design = {
            "recommended": "Randomized Controlled Trial (RCT)",
            "reporting": "CONSORT 2010",
            "strengths": "Strongest causal inference",
            "considerations": [
                "Need equipoise (genuine uncertainty about which is better)",
                "Blinding may or may not be feasible",
                "Intent-to-treat analysis is the primary approach",
                "Pre-register at ClinicalTrials.gov or ISRCTN"
            ]
        }
    elif outcome_prevalence == "rare":
        design = {
            "recommended": "Case-Control Study",
            "reporting": "STROBE",
            "strengths": "Efficient for rare outcomes",
            "considerations": [
                "Select controls carefully (matching, population-based)",
                "Recall bias is a major threat",
                "Can only calculate odds ratios, not incidence"
            ]
        }
    elif time_constraint == "short":
        design = {
            "recommended": "Cross-Sectional Study",
            "reporting": "STROBE (cross-sectional extension)",
            "strengths": "Quick, inexpensive, good for prevalence",
            "considerations": [
                "Cannot establish temporal sequence",
                "Prevalence bias (overrepresents chronic conditions)",
                "Useful for hypothesis generation"
            ]
        }
    else:
        design = {
            "recommended": "Prospective Cohort Study",
            "reporting": "STROBE",
            "strengths": "Can establish temporal sequence, multiple outcomes",
            "considerations": [
                "Loss to follow-up is the main threat",
                "Confounding must be addressed analytically",
                "Expensive and time-consuming"
            ]
        }

    return design
```

## CONSORT for Randomized Trials

### Essential CONSORT Checklist Items

```
Title and Abstract:
  - Identify as randomized trial in the title
  - Structured abstract with trial design, methods, results, conclusions

Methods:
  - Trial design (parallel, crossover, factorial, etc.)
  - Participants: Eligibility criteria, settings, locations
  - Interventions: Precise details of interventions for each group
  - Outcomes: Primary and secondary, how and when assessed
  - Sample size: Calculation with assumptions stated
  - Randomization: Sequence generation, allocation concealment
  - Blinding: Who was blinded, how blinding was maintained

Results:
  - CONSORT flow diagram (enrollment, allocation, follow-up, analysis)
  - Baseline demographic table (Table 1)
  - Primary outcome with effect size and confidence interval
  - Harms and adverse events

Discussion:
  - Limitations including sources of potential bias
  - Generalizability
  - Interpretation consistent with results
```

### CONSORT Flow Diagram

```
                    Assessed for eligibility (n=...)
                              |
                    Excluded (n=...)
                    - Not meeting criteria (n=...)
                    - Declined to participate (n=...)
                    - Other reasons (n=...)
                              |
                    Randomized (n=...)
                    /                    \
            Allocated to               Allocated to
            intervention (n=...)       control (n=...)
                    |                        |
            Lost to follow-up          Lost to follow-up
            (n=..., reasons)           (n=..., reasons)
                    |                        |
            Analyzed (n=...)           Analyzed (n=...)
            Excluded from analysis     Excluded from analysis
            (n=..., reasons)           (n=..., reasons)
```

## STROBE for Observational Studies

### Key STROBE Requirements

```
Study design specific items:

Cohort:
  - Report follow-up time (person-years, median)
  - Report loss to follow-up with reasons
  - Use hazard ratios or incidence rate ratios

Case-Control:
  - Describe case definition and case ascertainment
  - Describe control selection (source, matching criteria)
  - Report odds ratios with confidence intervals

Cross-Sectional:
  - Report response rate and non-response analysis
  - Describe how the sample represents the target population
  - Report prevalence with confidence intervals
```

## Sample Size and Power

### Power Calculation

```python
def power_analysis_rct(effect_size: float, alpha: float = 0.05,
                       power: float = 0.80, ratio: float = 1.0) -> dict:
    """
    Calculate required sample size for a two-arm RCT.

    Args:
        effect_size: Expected Cohen's d
        alpha: Significance level (two-sided)
        power: Desired statistical power
        ratio: Allocation ratio (control:treatment)
    """
    from scipy import stats
    import math

    z_alpha = stats.norm.ppf(1 - alpha / 2)
    z_beta = stats.norm.ppf(power)

    n_per_arm = math.ceil(
        ((z_alpha + z_beta) ** 2 * (1 + 1 / ratio)) / effect_size ** 2
    )

    return {
        "n_per_arm": n_per_arm,
        "total_n": n_per_arm + math.ceil(n_per_arm * ratio),
        "parameters": {
            "effect_size": effect_size,
            "alpha": alpha,
            "power": power,
            "allocation_ratio": f"1:{ratio}"
        },
        "note": "Add 10-20% for anticipated dropout"
    }
```

## Other Reporting Guidelines

| Guideline | Study Type | Checklist Items |
|-----------|-----------|-----------------|
| CONSORT | Randomized trials | 25 items + flow diagram |
| STROBE | Observational studies | 22 items |
| STARD | Diagnostic accuracy studies | 30 items |
| PRISMA | Systematic reviews | 27 items + flow diagram |
| TRIPOD | Prediction models | 22 items |
| SPIRIT | Trial protocols | 33 items |
| CARE | Case reports | 13 items |

All checklists are available at the EQUATOR Network (equator-network.org). Most journals require submission of the relevant checklist with your manuscript. Completing the checklist during manuscript writing, not after, ensures comprehensive reporting.
