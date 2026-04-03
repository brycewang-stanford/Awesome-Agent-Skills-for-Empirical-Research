# Prompt 1: Implement a Causal Inference Method

Copy and paste the prompt below into Claude with your details filled in.

---

```
You are an expert econometrician implementing causal inference methods.

Implement a complete [METHOD] analysis pipeline in [LANGUAGE: Python / R / Stata].

Requirements:
1. Data preparation (variable creation, sample restrictions)
2. Main estimation with correct standard errors
3. Key diagnostic / robustness check
4. Publication-ready output (coefficient table or plot)

Method-specific requirements:

- DiD: Include parallel trends event study plot. Cluster SE at [level]. Report DiD coefficient with baseline mean for economic magnitude.
- RDD: Include McCrary density test, bandwidth robustness (half/double), polynomial robustness. Report local linear estimate.
- IV: Report first-stage F-statistic. Defend exclusion restriction. Report Wu-Hausman test.
- Synthetic Control: Pre-treatment fit (RMSPE), placebo distribution, gaps plot.
- Matching/IPW: Covariate balance table before and after. Trimming at [0.1, 0.9].
- Event Study: Dynamic coefficients plot with 95% CI. Reference period = t-1.

My details:
- Method: [e.g., Difference-in-Differences]
- Language: [e.g., Python]
- Outcome variable: [e.g., firm_investment]
- Treatment variable: [e.g., reform_exposure]
- Treatment timing: [e.g., 2014 for all treated units / staggered]
- Key controls: [e.g., firm size, leverage, ROA]
- Fixed effects: [e.g., firm + year]
- Clustering level: [e.g., firm]
- Data format: [e.g., panel, entity_id + year columns]
- Sample size: [e.g., ~50,000 firm-years]
- Key concern: [e.g., contemporaneous policies]

[PASTE SAMPLE OF YOUR DATA STRUCTURE OR DESCRIBE COLUMNS]
```

---

## Method-Specific Variants

### For Staggered DiD

```
Additional requirement: Treatment timing varies across units.
- Use [Callaway & Sant'Anna / Sun & Abraham / Bacon decomposition] to address TWFE bias.
- Show that standard TWFE is potentially biased.
- Report group-time ATTs and aggregated dynamic effects.

My staggered details:
- Treatment cohorts: [e.g., 2010, 2012, 2014, 2016]
- Never-treated group exists: [yes/no]
- Preferred estimator: [e.g., Callaway & Sant'Anna]
```

### For Fuzzy RDD

```
Additional requirement: Treatment assignment is not sharp at the cutoff.
- Implement fuzzy RDD as IV where crossing the cutoff instruments for treatment.
- Report both reduced-form and 2SLS estimates.
- Show first-stage discontinuity in treatment probability.

My fuzzy RDD details:
- Running variable: [e.g., vote share]
- Cutoff: [e.g., 50%]
- Treatment: [e.g., policy implementation — not all units above cutoff comply]
- Compliance rate above cutoff: [e.g., ~75%]
```
