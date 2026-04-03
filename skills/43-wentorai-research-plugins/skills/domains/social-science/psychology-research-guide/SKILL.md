---
name: psychology-research-guide
description: "Psychological research methods, experimental design, and analysis"
metadata:
  openclaw:
    emoji: "🧠"
    category: "domains"
    subcategory: "social-science"
    keywords: ["psychology", "experimental design", "cognitive science", "psychometrics", "replication", "effect size"]
    source: "https://github.com/psych-ds/psych-DS"
---

# Psychology Research Guide

## Overview

Psychology is the scientific study of mind and behavior, spanning cognitive processes, social influence, developmental trajectories, clinical disorders, and neuroscience. The field has undergone a methodological revolution since the replication crisis of the 2010s, with new standards for statistical rigor, pre-registration, transparency, and open science fundamentally reshaping how research is conducted and evaluated.

This guide covers the practical aspects of conducting psychology research in the post-replication-crisis era: experimental design with adequate power, pre-registration, appropriate statistical analysis, effect size reporting, and the tools and platforms that support reproducible psychological science. The focus is on what reviewers and editors at top journals now expect.

Whether you are designing a behavioral experiment, analyzing survey data, conducting a psychometric validation, or reviewing a manuscript, these patterns reflect current best practices in the field.

## Experimental Design

### Between-Subjects vs. Within-Subjects

| Design | Advantages | Disadvantages | When to Use |
|--------|-----------|---------------|-------------|
| Between-subjects | No carryover effects, simpler | Requires more participants, individual differences | Deception studies, one-shot manipulations |
| Within-subjects | More power, fewer participants | Order effects, demand characteristics | Perception, memory, reaction time |
| Mixed | Combines benefits | Complex analysis | Treatment x individual difference |

### Power Analysis Before You Collect Data

```python
from statsmodels.stats.power import TTestIndPower, FTestAnovaPower
import numpy as np

# Two-sample t-test power analysis
analysis = TTestIndPower()

# Question: "How many participants per group for d=0.5, power=0.80?"
n_per_group = analysis.solve_power(
    effect_size=0.5,     # Cohen's d (medium effect)
    alpha=0.05,
    power=0.80,
    alternative="two-sided",
)
print(f"Required N per group: {int(np.ceil(n_per_group))}")  # 64

# For small effects (d=0.2), which are common after replication
n_small = analysis.solve_power(effect_size=0.2, alpha=0.05, power=0.80)
print(f"Required N per group for d=0.2: {int(np.ceil(n_small))}")  # 394

# One-way ANOVA (3 groups)
anova_analysis = FTestAnovaPower()
n_anova = anova_analysis.solve_power(
    effect_size=0.25,    # Cohen's f (medium)
    alpha=0.05,
    power=0.80,
    k_groups=3,
)
print(f"Required N per group (ANOVA): {int(np.ceil(n_anova))}")  # 53
```

### Effect Sizes That Reviewers Expect

| Measure | Small | Medium | Large | Use For |
|---------|-------|--------|-------|---------|
| Cohen's d | 0.2 | 0.5 | 0.8 | Group differences |
| Pearson r | 0.1 | 0.3 | 0.5 | Correlations |
| Cohen's f | 0.1 | 0.25 | 0.4 | ANOVA effects |
| eta-squared | 0.01 | 0.06 | 0.14 | ANOVA variance explained |
| Odds ratio | 1.5 | 2.5 | 4.0 | Binary outcomes |
| Cohen's w | 0.1 | 0.3 | 0.5 | Chi-squared tests |

**Important:** Post-replication-crisis psychology finds that most real effects are small (d = 0.2-0.4). Design for small effects unless you have strong prior evidence for larger ones.

## Pre-Registration

### What to Pre-Register

```
Pre-registration template (AsPredicted.org format):

1. HYPOTHESES
   H1: Participants in the gratitude condition will report higher
   life satisfaction (SWLS scores) than those in the control
   condition (d >= 0.3).

2. DESIGN
   - 2 (gratitude vs. control) between-subjects
   - Random assignment via Qualtrics randomizer

3. PLANNED SAMPLE
   - N = 200 per condition (400 total)
   - Power: 0.90 for d = 0.3 at alpha = 0.05
   - Recruitment: Prolific, US residents, 18-65

4. EXCLUSION CRITERIA (stated before data collection)
   - Failed attention check (embedded in survey)
   - Completion time < 3 minutes or > 30 minutes
   - Duplicate IP addresses

5. MEASURED VARIABLES
   - DV: Satisfaction With Life Scale (SWLS; Diener et al., 1985)
   - Manipulation check: "How grateful do you feel right now?" (1-7)
   - Covariates: Age, gender, baseline mood (PANAS)

6. ANALYSIS PLAN
   - Primary: Independent samples t-test on SWLS scores
   - Secondary: ANCOVA controlling for baseline PANAS-PA
   - Exploratory: Moderation by trait gratitude (GQ-6)

7. ANYTHING ELSE
   - All deviations from this plan will be labeled as exploratory
   - We will report all conditions and all measures
```

### Pre-Registration Platforms

| Platform | Strengths | Journal Integration |
|----------|-----------|-------------------|
| OSF Registries | Most widely used, free, flexible | Registered Reports at 300+ journals |
| AsPredicted.org | Simple, private until you share | Widely accepted |
| ClinicalTrials.gov | Required for clinical studies | FDA-mandated |
| EGAP | Political science, field experiments | APSR, AJPS |

## Statistical Analysis

### The Modern Analysis Workflow

```python
import pandas as pd
import pingouin as pg
from scipy import stats

# Load data
df = pd.read_csv("experiment_data.csv")

# Step 1: Descriptive statistics by condition
descriptives = df.groupby("condition").agg(
    n=("dv", "count"),
    mean=("dv", "mean"),
    sd=("dv", "std"),
    median=("dv", "median"),
).round(3)

# Step 2: Check assumptions
# Normality
for condition in df["condition"].unique():
    subset = df[df["condition"] == condition]["dv"]
    stat, p = stats.shapiro(subset)
    print(f"{condition}: Shapiro-Wilk W={stat:.3f}, p={p:.3f}")

# Homogeneity of variance
levene_stat, levene_p = stats.levene(
    df[df["condition"] == "treatment"]["dv"],
    df[df["condition"] == "control"]["dv"],
)

# Step 3: Primary analysis with effect size and CI
result = pg.ttest(
    df[df["condition"] == "treatment"]["dv"],
    df[df["condition"] == "control"]["dv"],
    paired=False,
    alternative="two-sided",
)
print(result[["T", "dof", "p-val", "cohen-d", "CI95%", "BF10"]])

# Step 4: Bayesian analysis (increasingly expected)
bf10 = float(result["BF10"].values[0])
print(f"Bayes Factor BF10 = {bf10:.2f}")
if bf10 > 10:
    print("Strong evidence for H1")
elif bf10 > 3:
    print("Moderate evidence for H1")
elif bf10 > 1:
    print("Anecdotal evidence for H1")
else:
    print("Evidence favors H0")
```

### ANOVA with Post-Hoc Comparisons

```python
# One-way ANOVA
aov = pg.anova(dv="score", between="group", data=df, detailed=True)
print(aov)

# Effect size (eta-squared and omega-squared)
print(f"Eta-squared: {aov['np2'].values[0]:.3f}")

# Post-hoc pairwise comparisons with correction
posthoc = pg.pairwise_tukey(dv="score", between="group", data=df)
print(posthoc)

# Mixed ANOVA (between + within)
mixed = pg.mixed_anova(
    dv="score", between="group", within="time",
    subject="participant_id", data=df_long
)
print(mixed)
```

## Psychometric Validation

```python
# Scale reliability
from pingouin import cronbach_alpha

items = df[["item1", "item2", "item3", "item4", "item5"]]
alpha, ci = cronbach_alpha(items)
print(f"Cronbach's alpha = {alpha:.3f}, 95% CI = [{ci[0]:.3f}, {ci[1]:.3f}]")

# Confirmatory Factor Analysis (using semopy)
from semopy import Model

model_spec = """
factor1 =~ item1 + item2 + item3
factor2 =~ item4 + item5 + item6
"""
model = Model(model_spec)
model.fit(df)
print(model.inspect())

# Fit indices
stats_result = model.calc_stats()
print(f"CFI = {stats_result.loc['CFI', 'Value']:.3f}")
print(f"RMSEA = {stats_result.loc['RMSEA', 'Value']:.3f}")
print(f"SRMR = {stats_result.loc['SRMR', 'Value']:.3f}")
```

## Reporting Results (APA Format)

```
Standard reporting patterns:

t-test:
"Participants in the gratitude condition (M = 5.23, SD = 1.12) reported
significantly higher life satisfaction than those in the control condition
(M = 4.67, SD = 1.08), t(398) = 4.89, p < .001, d = 0.49, 95% CI [0.29, 0.69]."

ANOVA:
"There was a significant main effect of group on performance,
F(2, 297) = 8.43, p < .001, eta-p-squared = .054."

Correlation:
"Life satisfaction was positively correlated with gratitude,
r(198) = .42, p < .001, 95% CI [.30, .53]."

Always include: test statistic, df, p-value, effect size, confidence interval.
```

## Best Practices

- **Power for small effects.** Assume d = 0.2-0.4 unless prior meta-analyses suggest otherwise.
- **Pre-register everything.** Even exploratory studies benefit from stating what is confirmatory vs. exploratory.
- **Report all measures and conditions.** Selective reporting is the primary source of false positives.
- **Use Bayesian statistics** alongside frequentist tests to quantify evidence for the null.
- **Share data and code on OSF.** Transparency is now a condition for publication at many journals.
- **Distinguish statistical from practical significance.** A p < .001 with d = 0.05 is not meaningful.

## References

- [Open Science Framework (OSF)](https://osf.io/) -- Pre-registration, data sharing, collaboration
- Simmons, J. P., Nelson, L. D., & Simonsohn, U. (2011). False-Positive Psychology. Psychological Science, 22(11), 1359-1366.
- Cumming, G. (2014). The New Statistics: Why and How. Psychological Science, 25(1), 7-29.
- [pingouin](https://pingouin-stats.org/) -- Python statistical package for psychology
- [PsychDS](https://psych-ds.github.io/) -- Data standard for psychology datasets
