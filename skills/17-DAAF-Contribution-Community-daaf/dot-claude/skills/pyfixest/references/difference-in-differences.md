# Difference-in-Differences

## Contents

- [TWFE (Traditional Two-Way Fixed Effects)](#twfe-traditional-two-way-fixed-effects)
- [Event Study Specification](#event-study-specification)
- [Modern DiD Estimators](#modern-did-estimators)
- [panelview for Treatment Visualization](#panelview-for-treatment-visualization)
- [Event Study Plotting](#event-study-plotting)
- [Parallel Trends Assessment](#parallel-trends-assessment)

## TWFE (Traditional Two-Way Fixed Effects)

### Basic TWFE DiD

```python
import pyfixest as pf

# Classic 2x2 DiD with entity + time FE
fit = pf.feols("Y ~ treatment | entity + year", data=df,
               vcov={"CRV1": "entity"})
fit.summary()
```

### When TWFE Works

TWFE DiD produces unbiased estimates when:
- **Single treatment date**: All treated units adopt treatment simultaneously
- **Homogeneous effects**: Treatment effect is the same across all units and time periods
- **No anticipation**: Units don't change behavior before treatment

### When TWFE Fails

With **staggered treatment timing** (units adopt at different times) and **heterogeneous treatment effects**, TWFE can produce severely biased estimates — including sign reversals. This occurs because TWFE implicitly uses already-treated units as controls for newly-treated units, creating "forbidden comparisons" with negative weights.

**When you have staggered treatment:** Use one of the modern estimators below (did2s, lpdid, or Sun-Abraham saturated).

For methodological details on the TWFE problem, load the `data-scientist` skill's causal inference reference.

## Event Study Specification

### Manual Event Study with `i()`

```python
# Create relative-time variable: periods since treatment
df["rel_year"] = df["year"] - df["treatment_year"]

# Event study: i() creates dummies for each relative year, omitting -1 as reference
fit = pf.feols("Y ~ i(rel_year, ref=-1) | entity + year", data=df,
               vcov={"CRV1": "entity"})

# Plot the event study
fit.iplot()
```

The `ref=-1` normalizes to the period immediately before treatment, which is the standard convention.

### Unified Event Study Interface

```python
# pf.event_study() provides a clean unified interface
fit = pf.event_study(
    data=df,
    yname="Y",            # Outcome variable
    idname="entity",      # Unit identifier
    tname="year",         # Time period
    gname="treatment_year",  # Cohort (year of treatment adoption)
    estimator="twfe",     # Estimator: "twfe", "did2s", or "saturated"
    att=True,             # True = pooled ATT; False = dynamic event study
    cluster="entity",     # Clustering variable
)
fit.summary()
```

Set `att=False` for dynamic (period-by-period) estimates, `att=True` for a single pooled treatment effect.

## Modern DiD Estimators

### did2s — Gardner (2022) Two-Stage Imputation

```python
fit = pf.did2s(
    data=df,
    yname="Y",
    first_stage="~ 0 | entity + year",     # FE to estimate from untreated obs
    second_stage="~ i(rel_year, ref=-1)",   # Treatment effect specification
    treatment="treated",                     # Binary treatment indicator
    cluster="entity",                        # Clustering variable
)
fit.summary()
fit.iplot()  # Event study plot
```

**Data requirement:** The dataset must include units that are **never treated** (treatment indicator = 0 for all periods). The did2s estimator uses these never-treated units in Stage 1 to estimate time fixed effects. Datasets where all units are eventually treated will cause estimation failure (shape mismatches or singular matrix errors).

**How it works:**
1. **Stage 1**: Estimate entity and time FE using only untreated (and not-yet-treated) observations
2. **Stage 2**: Impute the counterfactual for treated observations, then regress the residual on treatment indicators

**Advantages:** Avoids the negative-weighting problem of TWFE. Consistent under staggered adoption with heterogeneous effects.

**For a pooled ATT** (single treatment effect number):

```python
fit = pf.did2s(
    data=df,
    yname="Y",
    first_stage="~ 0 | entity + year",
    second_stage="~ treated",               # Single treatment dummy → pooled ATT
    treatment="treated",
    cluster="entity",
)
```

### lpdid — Local Projections DiD (Dube, Girardi, Jorda, & Taylor, 2023)

```python
result = pf.lpdid(
    data=df,
    yname="Y",
    idname="entity",
    tname="year",
    gname="treatment_year",     # Cohort variable
    att=True,                   # True = pooled ATT, False = period-specific
    vcov={"CRV1": "entity"},   # Defaults to CRV1 by idname
    pre_window=5,               # Number of pre-treatment periods
    post_window=10,             # Number of post-treatment periods
    never_treated=0,            # Value of gname for never-treated units (default: 0)
)
```

**Important:** `lpdid()` returns a **DataFrame** (not a Feols object) — its API differs from `feols()` / `did2s()`.

**Advantages:**
- Flexible dynamics: does not assume a specific functional form for treatment effects over time
- Allows non-absorbing treatment (treatment can turn off)
- Robust to misspecification of the outcome model

### Sun-Abraham Saturated Estimator

```python
# Via event_study() with estimator="saturated"
fit = pf.event_study(
    data=df,
    yname="Y",
    idname="entity",
    tname="year",
    gname="treatment_year",
    estimator="saturated",
    att=False,                  # Dynamic event study
    cluster="entity",
)

# Full interaction-weighted estimates
fit.summary()

# Aggregate to overall treatment effect
agg = fit.aggregate(weighting="shares")
```

**How it works:** Fully saturates the model with cohort-by-period indicators, then aggregates using appropriate weights. Properly handles staggered timing by never using already-treated units as controls.

**Visualization:**

```python
# Event study plot of saturated estimates
fit.iplot()
```

Note: The R fixest package provides additional Sun-Abraham utilities (`aggregate.fixest()`, treatment heterogeneity tests) that may not all be ported to pyfixest yet. Check the pyfixest changelog and documentation for the latest available methods on the saturated estimator result object.

### Choosing Among Modern Estimators

| Estimator | Best For | Returns | Key Assumption |
|-----------|----------|---------|----------------|
| `did2s` | General staggered DiD; flexible second stage | `Feols` | Parallel trends; no anticipation |
| `lpdid` | Non-absorbing treatment; flexible dynamics | `DataFrame` | Parallel trends; clean control group |
| `saturated` (Sun-Abraham) | Testing for heterogeneity across cohorts | `Feols` | Parallel trends; no anticipation |

All three are consistent under staggered treatment with heterogeneous effects. Choice often depends on what you want to test and how you want to present results.

## panelview for Treatment Visualization

Before running any DiD model, visualize the treatment assignment pattern:

```python
# Heatmap of treatment status across units and time
pf.panelview(
    data=df,
    unit="entity",
    time="year",
    treat="treated",       # Binary treatment indicator
)
```

This produces a heatmap showing which units are treated in which periods — essential for understanding:
- How many units are treated vs. control
- Whether treatment timing is staggered
- Whether there are gaps or reversals in treatment
- How many never-treated units exist

## Event Study Plotting

### `iplot()` for Models with `i()` Terms

```python
fit = pf.feols("Y ~ i(rel_year, ref=-1) | entity + year", data=df,
               vcov={"CRV1": "entity"})

# Basic event study plot
fit.iplot()

# With joint confidence bands (Bonferroni + Scheffe)
fit.iplot(joint="both")

# With customization
fit.iplot(
    alpha=0.05,              # Significance level
    figsize=(10, 6),         # Figure size
    joint="both",            # Both Bonferroni and Scheffe bands
    yintercept=0,            # Reference line at zero
    coord_flip=False,        # Horizontal orientation
)
```

Joint confidence bands are wider than pointwise CIs but account for multiple testing across periods — they provide a valid simultaneous test of no pre-trends and no treatment effect.

### Comparing Estimators Visually

```python
# Run multiple estimators
fit_twfe = pf.event_study(data=df, yname="Y", idname="entity",
                          tname="year", gname="g", estimator="twfe", att=False)
fit_did2s = pf.event_study(data=df, yname="Y", idname="entity",
                           tname="year", gname="g", estimator="did2s", att=False)

# Compare with coefplot
pf.coefplot([fit_twfe, fit_did2s])
```

## Clustering in DiD Designs

The choice of cluster level is especially important in DiD. Following Cameron & Miller (2015): **cluster at the level of treatment assignment**. If a policy varies at the state level, cluster at the state level — not the entity level, even if entities are the panel units.

```python
# State-level policy → cluster at state
fit = pf.feols("Y ~ treatment | entity + year", data=df,
               vcov={"CRV1": "state"})          # NOT "entity"

# did2s with state-level clustering
fit = pf.did2s(data=df, yname="Y",
               first_stage="~ 0 | entity + year",
               second_stage="~ i(rel_year, ref=-1)",
               treatment="treated",
               cluster="state")                   # NOT "entity"
```

See `fixed-effects.md` for full guidance on choosing cluster levels and handling few-cluster inference.

## Parallel Trends Assessment

The parallel trends assumption — that treated and control groups would have followed the same trajectory absent treatment — is fundamentally untestable. Pre-treatment event study coefficients provide suggestive evidence but cannot confirm the assumption.

### Visual Assessment

```python
# Pre-treatment coefficients close to zero suggest (but don't prove) parallel trends
fit = pf.feols("Y ~ i(rel_year, ref=-1) | entity + year", data=df,
               vcov={"CRV1": "entity"})
fit.iplot(joint="both")  # Joint bands make the test more conservative
```

### Joint F-Test for Pre-Trends

```python
# Test that all pre-treatment coefficients are jointly zero
# Use joint confidence bands in iplot() as a visual joint test
fit.iplot(joint="both")  # Bonferroni + Scheffe simultaneous bands

# For a formal Wald test, construct the restriction matrix
# targeting the pre-period coefficient indices, or use
# marginaleffects.hypotheses() for string-based tests
```

### Important Caveat

Failing to reject the null of no pre-trends does **not** confirm parallel trends. It may simply reflect low statistical power. Roth (2022) shows that pre-tests have low power against violations that would meaningfully bias treatment effect estimates. When parallel trends are critical to your identification:

- Present pre-treatment coefficients transparently
- Discuss the plausibility of the assumption based on institutional knowledge
- Consider robustness to violations (e.g., Rambachan & Roth, 2023, HonestDiD)

## References and Further Reading

- Gardner, J. (2022). "Two-Stage Differences in Differences." arXiv:2207.05943
- Dube, A., Girardi, D., Jorda, O., and Taylor, A.M. (2023). "A Local Projections Approach to Difference-in-Differences." NBER Working Paper 31184
- Sun, L. and Abraham, S. (2021). "Estimating Dynamic Treatment Effects in Event Studies with Heterogeneous Treatment Effects." *Journal of Econometrics*, 225(2), 175-199
- Callaway, B. and Sant'Anna, P.H.C. (2021). "Difference-in-Differences with Multiple Time Periods." *Journal of Econometrics*, 225(2), 200-230
- Roth, J. (2022). "Pretest with Caution: Event-Study Estimates after Testing for Parallel Trends." *American Economic Review: Insights*, 4(3), 305-322
- Roth, J., Sant'Anna, P.H.C., Bilinski, A., and Poe, J. (2023). "What's Trending in Difference-in-Differences? A Synthesis of the Recent Econometrics Literature." *Journal of Econometrics*, 235(2), 2218-2244
- de Chaisemartin, C. and D'Haultfoeuille, X. (2020). "Two-Way Fixed Effects Estimators with Heterogeneous Treatment Effects." *American Economic Review*, 110(9), 2964-2996
- Goodman-Bacon, A. (2021). "Difference-in-Differences with Variation in Treatment Timing." *Journal of Econometrics*, 225(2), 254-277
- pyfixest documentation — DiD Estimation: https://pyfixest.org
