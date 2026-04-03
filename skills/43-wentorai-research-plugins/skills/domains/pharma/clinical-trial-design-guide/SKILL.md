---
name: clinical-trial-design-guide
description: "Clinical trial methodology, biostatistics, and study design guidance"
metadata:
  openclaw:
    emoji: "🧪"
    category: "domains"
    subcategory: "pharma"
    keywords: ["clinical-trial", "biostatistics", "randomization", "sample-size", "survival-analysis", "rct"]
    source: "wentor"
---

# Clinical Trial Design Guide

A skill for designing and analyzing clinical trials, covering study design selection, sample size calculation, randomization methods, interim analysis, survival endpoints, and regulatory considerations. Essential for pharmaceutical researchers, biostatisticians, and clinical scientists.

## Clinical Trial Phases

### Phase Overview

| Phase | Objective | Typical N | Duration | Primary Endpoints |
|-------|-----------|----------|----------|-------------------|
| Phase I | Safety, dose-finding | 20-80 | Months | MTD, DLT, PK profile |
| Phase II | Efficacy signal, dosing | 100-300 | 1-2 years | Response rate, biomarker |
| Phase III | Confirmatory efficacy | 300-3,000+ | 2-4 years | OS, PFS, clinical outcome |
| Phase IV | Post-marketing surveillance | 1,000+ | Ongoing | Safety, real-world effectiveness |

## Study Design Selection

### Common Designs

```
Parallel Group (most common Phase III):
  R --> Treatment A --> Outcome assessment
  R --> Treatment B --> Outcome assessment

Crossover:
  R --> Treatment A --> Washout --> Treatment B --> Outcome
  R --> Treatment B --> Washout --> Treatment A --> Outcome

Factorial (2x2):
  R --> Drug A + Drug B
  R --> Drug A + Placebo B
  R --> Placebo A + Drug B
  R --> Placebo A + Placebo B

Adaptive:
  Stage 1: Enroll n1 patients --> Interim analysis
  Stage 2: Modify design (dose, sample size, arm dropping) --> Continue
```

### Design Selection Criteria

| Factor | Recommended Design |
|--------|-------------------|
| Chronic disease, stable condition | Crossover (within-subject comparison) |
| Acute condition, one-time treatment | Parallel group |
| Multiple drugs to evaluate | Factorial or multi-arm |
| High uncertainty in effect size | Adaptive (sample size re-estimation) |
| Rare disease, limited patients | Bayesian adaptive, single-arm with historical control |

## Sample Size Calculation

### Two-Sample Comparison of Means

```python
from scipy.stats import norm
import numpy as np

def sample_size_two_means(delta: float, sigma: float,
                           alpha: float = 0.05, power: float = 0.80,
                           ratio: float = 1.0) -> dict:
    """
    Sample size for comparing two group means (two-sided test).
    delta: minimum clinically important difference
    sigma: pooled standard deviation
    alpha: type I error rate
    power: desired power (1 - beta)
    ratio: allocation ratio (n2/n1)
    """
    z_alpha = norm.ppf(1 - alpha / 2)
    z_beta = norm.ppf(power)
    effect = delta / sigma

    n1 = ((z_alpha + z_beta) ** 2 * (1 + 1 / ratio)) / effect ** 2
    n2 = ratio * n1

    return {
        "n_per_group_1": int(np.ceil(n1)),
        "n_per_group_2": int(np.ceil(n2)),
        "total": int(np.ceil(n1) + np.ceil(n2)),
        "effect_size": round(effect, 3),
    }

# Example: detect 5-point difference, SD=15, 80% power
result = sample_size_two_means(delta=5, sigma=15)
print(f"Required: {result['total']} total patients")
```

### Sample Size for Survival Endpoints

```python
def sample_size_logrank(hazard_ratio: float, alpha: float = 0.05,
                         power: float = 0.80, ratio: float = 1.0,
                         median_control: float = 12.0,
                         accrual_time: float = 24.0,
                         followup_time: float = 12.0) -> dict:
    """
    Sample size for log-rank test comparing two survival curves.
    hazard_ratio: expected HR (treatment/control), <1 means treatment better
    median_control: median survival in control arm (months)
    """
    z_alpha = norm.ppf(1 - alpha / 2)
    z_beta = norm.ppf(power)

    # Required number of events (Schoenfeld formula)
    d = ((z_alpha + z_beta) ** 2 * (1 + ratio) ** 2) / (
        ratio * (np.log(hazard_ratio)) ** 2
    )
    d = int(np.ceil(d))

    # Estimate probability of event during study
    lambda_c = np.log(2) / median_control
    lambda_t = lambda_c * hazard_ratio

    # Average probability of event (simplified uniform accrual)
    p_event_c = 1 - np.exp(-lambda_c * followup_time)
    p_event_t = 1 - np.exp(-lambda_t * followup_time)
    p_event_avg = (p_event_c + ratio * p_event_t) / (1 + ratio)

    n_total = int(np.ceil(d / p_event_avg))

    return {
        "events_required": d,
        "total_patients": n_total,
        "hazard_ratio": hazard_ratio,
        "p_event_avg": round(p_event_avg, 3),
    }
```

## Randomization Methods

### Implementation

```python
import random

def stratified_block_randomization(strata: list[str],
                                     block_sizes: list[int] = [4, 6],
                                     ratio: tuple = (1, 1),
                                     seed: int = 42) -> list[str]:
    """
    Stratified permuted block randomization.
    strata: list of stratum labels for each patient (in enrollment order)
    block_sizes: list of possible block sizes (randomly selected)
    ratio: allocation ratio (e.g., (1,1) for 1:1, (2,1) for 2:1)
    Returns list of treatment assignments ('A' or 'B').
    """
    rng = random.Random(seed)
    stratum_queues = {}
    assignments = []

    for stratum in strata:
        if stratum not in stratum_queues:
            stratum_queues[stratum] = []

        if not stratum_queues[stratum]:
            # Generate new block
            block_size = rng.choice(block_sizes)
            n_a = block_size * ratio[0] // sum(ratio)
            n_b = block_size - n_a
            block = ["A"] * n_a + ["B"] * n_b
            rng.shuffle(block)
            stratum_queues[stratum] = block

        assignments.append(stratum_queues[stratum].pop(0))

    return assignments
```

## Interim Analysis and Monitoring

### Group Sequential Design

```python
def obrien_fleming_boundary(n_looks: int, alpha: float = 0.05) -> list[float]:
    """
    Compute O'Brien-Fleming spending function boundaries.
    Provides very conservative early stopping with near-nominal final alpha.
    """
    from scipy.stats import norm
    boundaries = []
    for k in range(1, n_looks + 1):
        info_fraction = k / n_looks
        z_boundary = norm.ppf(1 - alpha / 2) / np.sqrt(info_fraction)
        p_boundary = 2 * (1 - norm.cdf(z_boundary))
        boundaries.append({
            "look": k,
            "info_fraction": round(info_fraction, 3),
            "z_boundary": round(z_boundary, 4),
            "p_boundary": round(p_boundary, 6),
        })
    return boundaries

# Example: 3 interim looks + 1 final
boundaries = obrien_fleming_boundary(4)
for b in boundaries:
    print(f"Look {b['look']}: Z={b['z_boundary']}, p={b['p_boundary']}")
```

## Survival Analysis

### Kaplan-Meier and Log-Rank Test

```python
from lifelines import KaplanMeierFitter
from lifelines.statistics import logrank_test

def analyze_survival(time: pd.Series, event: pd.Series,
                      group: pd.Series) -> dict:
    """
    Perform Kaplan-Meier estimation and log-rank test.
    time: follow-up duration
    event: 1=event occurred, 0=censored
    group: treatment group labels
    """
    groups = group.unique()
    kmf_results = {}

    for g in groups:
        mask = group == g
        kmf = KaplanMeierFitter()
        kmf.fit(time[mask], event[mask], label=str(g))
        kmf_results[g] = {
            "median_survival": kmf.median_survival_time_,
            "survival_at_12m": kmf.predict(12),
        }

    # Log-rank test
    mask_a = group == groups[0]
    lr = logrank_test(
        time[mask_a], time[~mask_a],
        event[mask_a], event[~mask_a],
    )

    return {
        "group_results": kmf_results,
        "logrank_statistic": lr.test_statistic,
        "logrank_p_value": lr.p_value,
    }
```

## Regulatory Considerations

Key regulatory documents for clinical trial design:

- **ICH E6 (R2)**: Good Clinical Practice guidelines
- **ICH E9 (R1)**: Statistical Principles, estimands framework
- **ICH E8 (R1)**: General Considerations for Clinical Studies
- **FDA 21 CFR Part 312**: Investigational New Drug regulations
- **EMA Scientific Guidelines**: Disease-specific guidance documents

## Tools and Software

- **R survival package**: Kaplan-Meier, Cox regression, log-rank test
- **lifelines (Python)**: Survival analysis library
- **gsDesign (R)**: Group sequential design and monitoring boundaries
- **PASS / nQuery**: Commercial sample size software
- **EAST (Cytel)**: Adaptive and group sequential design software
- **REDCap**: Electronic data capture for clinical research
- **ClinicalTrials.gov API**: Trial registry search and data access
