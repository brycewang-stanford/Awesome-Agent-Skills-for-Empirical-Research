---
name: survival-analysis-guide
description: "Conduct Kaplan-Meier, Cox regression, and time-to-event analyses"
metadata:
  openclaw:
    emoji: "⏳"
    category: "analysis"
    subcategory: "statistics"
    keywords: ["survival analysis", "Kaplan-Meier", "Cox regression", "time-to-event", "hazard ratio", "censoring"]
    source: "wentor-research-plugins"
---

# Survival Analysis Guide

A skill for conducting time-to-event analyses including Kaplan-Meier estimation, log-rank tests, and Cox proportional hazards regression. Covers censoring concepts, assumption checking, and reporting standards for clinical and social science research.

## Core Concepts

### What Is Survival Analysis?

Survival analysis studies the time until an event of interest occurs. Despite the name, the "event" need not be death -- it can be any well-defined transition:

```
Medical:      Time to disease recurrence, death, or recovery
Engineering:  Time to equipment failure
Social:       Time to job termination, divorce, or graduation
Business:     Time to customer churn or first purchase
Ecology:      Time to species extinction in a habitat
```

### Censoring

```
Right censoring (most common):
  The event has not occurred by the end of the study period.
  Example: Patient is still alive at study end.
  The survival time is "at least T" -- we know T but not the true event time.

Left censoring:
  The event occurred before the observation period began.
  Example: HIV infection detected, but seroconversion happened before testing.

Interval censoring:
  The event occurred between two observation times.
  Example: A patient tests negative at visit 3 and positive at visit 4.
```

## Kaplan-Meier Estimation

### Computing the Survival Curve

```python
import numpy as np


def kaplan_meier(times: list[float], events: list[int]) -> dict:
    """
    Compute Kaplan-Meier survival estimates.

    Args:
        times: Observed times (event or censoring time)
        events: Event indicator (1 = event occurred, 0 = censored)

    Returns:
        Dict with time points and survival probabilities
    """
    data = sorted(zip(times, events), key=lambda x: x[0])
    n = len(data)

    unique_event_times = sorted(set(t for t, e in data if e == 1))
    survival = 1.0
    results = {"time": [0], "survival": [1.0]}

    at_risk = n
    idx = 0

    for t_event in unique_event_times:
        # Count censored before this event time
        while idx < n and data[idx][0] < t_event:
            if data[idx][1] == 0:
                at_risk -= 1
            idx += 1

        # Count events at this time
        d = sum(1 for t, e in data if t == t_event and e == 1)
        c = sum(1 for t, e in data if t == t_event and e == 0)

        survival *= (at_risk - d) / at_risk
        results["time"].append(t_event)
        results["survival"].append(survival)

        at_risk -= (d + c)
        idx = max(idx, sum(1 for t, _ in data if t <= t_event))

    return results
```

### Using lifelines in Python

```python
from lifelines import KaplanMeierFitter

kmf = KaplanMeierFitter()
kmf.fit(durations=time_column, event_observed=event_column, label="Overall")

# Plot the survival curve
kmf.plot_survival_function()

# Median survival time
print(f"Median survival: {kmf.median_survival_time_}")

# Survival probability at specific time
print(f"5-year survival: {kmf.predict(5.0):.3f}")
```

## Log-Rank Test

### Comparing Survival Between Groups

```python
from lifelines.statistics import logrank_test

results = logrank_test(
    durations_A=group_a_times,
    durations_B=group_b_times,
    event_observed_A=group_a_events,
    event_observed_B=group_b_events
)

print(f"Test statistic: {results.test_statistic:.3f}")
print(f"p-value: {results.p_value:.4f}")
```

The log-rank test is the standard method for comparing two or more survival curves. It tests the null hypothesis that the survival functions are identical. It is most powerful when hazards are proportional (consistent relative risk over time).

## Cox Proportional Hazards Regression

### Model Fitting

```python
from lifelines import CoxPHFitter
import pandas as pd

cph = CoxPHFitter()
cph.fit(
    df,
    duration_col="time",
    event_col="event",
    formula="age + treatment + stage"
)

cph.print_summary()

# Hazard ratios
print(cph.summary[["exp(coef)", "exp(coef) lower 95%", "exp(coef) upper 95%", "p"]])
```

### Interpreting Hazard Ratios

```
Hazard Ratio (HR) = exp(coefficient)

HR = 1.0   No effect
HR > 1.0   Increased hazard (worse survival)
HR < 1.0   Decreased hazard (better survival)

Example output:
  treatment:  HR = 0.65, 95% CI [0.48, 0.88], p = 0.005
  Interpretation: Treatment group has 35% lower hazard of the event
                  compared to the control group.
```

### Checking the Proportional Hazards Assumption

```python
# Schoenfeld residuals test
cph.check_assumptions(df, p_value_threshold=0.05, show_plots=True)
```

If the proportional hazards assumption is violated, consider: stratified Cox models, time-varying covariates, or accelerated failure time (AFT) models as alternatives.

## Reporting Standards

### STROBE-style Reporting for Survival Analyses

```
1. Report number of events and total person-time at risk
2. Present Kaplan-Meier curves with number-at-risk tables
3. Report median survival with 95% confidence intervals
4. Report hazard ratios with 95% CIs and p-values
5. State which covariates were included in adjusted models
6. Report proportional hazards assumption test results
7. Specify the handling of tied event times (Efron, Breslow)
8. Note any competing risks and how they were handled
```
