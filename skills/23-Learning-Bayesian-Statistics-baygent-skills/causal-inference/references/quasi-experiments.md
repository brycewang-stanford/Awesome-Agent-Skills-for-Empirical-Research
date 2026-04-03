# Quasi-Experimental Designs

## Contents

- Design selection guide
- Difference-in-Differences (DiD)
- Staggered DiD
- Synthetic Control
- Interrupted Time Series (ITS)
- Piecewise ITS
- Regression Discontinuity (RDD)
- Regression Kink Design
- Instrumental Variables (IV)
- Inverse Propensity Score Weighting (IPSW)
- Accessing results (all designs)

---

## Design selection guide

| Design | Use when | Key assumption | Tool |
|--------|----------|----------------|------|
| DiD | Treatment at known time, control group available | Parallel trends | CausalPy |
| Staggered DiD | Treatment rolls out at different times across units | Parallel trends per cohort | CausalPy |
| Synthetic Control | Single treated unit, donor pool available | Weighted donors approximate counterfactual | CausalPy |
| ITS | Time series, intervention at known time, no control group | No confounding event at treatment time | CausalPy |
| Piecewise ITS | Multiple interventions or structural breaks | No confounding events at each break | CausalPy |
| RDD | Treatment assigned by threshold on running variable | No manipulation at threshold, smooth density | CausalPy |
| Regression Kink | Treatment *intensity* changes slope at threshold | No manipulation at kink point | CausalPy |
| IV | Endogenous treatment, valid instrument available | Exclusion restriction, instrument relevance | CausalPy |
| IPSW | Observational data, model treatment assignment | No unmeasured confounders, positivity | CausalPy |
| Structural (do/observe) | Full causal theory, model mechanisms | Correct DAG specification | PyMC |

If none of these fit, see [references/structural-models.md](structural-models.md) for the `pm.do()` / `pm.observe()` path.

**Always prefer PyMC-backed models over sklearn.** PyMC models give full posterior uncertainty; sklearn gives point estimates only. Every template below uses `cp.pymc_models.*`.

---

## Difference-in-Differences (DiD)

**Use when:** Treatment switches on at a known calendar time, and an untreated control group is available.

**Key assumption:** Parallel trends — treatment and control would have followed the same trajectory absent treatment. Partially testable (check pre-treatment trends) but never fully verifiable post-treatment.

**CausalPy class:** `cp.DifferenceInDifferences`

```python
import causalpy as cp
import numpy as np

rng = np.random.default_rng(sum(map(ord, "did-analysis")))

result = cp.DifferenceInDifferences(
    data=df,
    formula="outcome ~ 1 + post_treatment + group + post_treatment:group",
    time_variable_name="time",
    group_variable_name="group",
    # group must be dummy-coded: 1 = treatment, 0 = control (NOT string labels)
    # post_treatment must also be 0/1 (defaults to column named "post_treatment")
    # data must also have a "unit" column labeling unique units (used for plotting)
    model=cp.pymc_models.LinearRegression(
        sample_kwargs={"nuts_sampler": "nutpie", "random_seed": rng}
    ),
)
fig, ax = result.plot()
es = result.effect_summary(direction="two-sided")
print(es.text)
print(es.table)
```

The `group` column must be dummy-coded (0/1 integers), not string labels — CausalPy will reject string-valued group variables. The data must also have a `unit` column identifying individual units (used for plotting). The interaction `post_treatment:group` is the DiD estimator.

**What can go wrong:** Parallel trends violated (different pre-treatment trajectories); compositional changes in group membership over time; anticipation effects (units respond before the official treatment date); SUTVA violations (treated units affect controls).

**Refutation:** See [references/refutation.md](refutation.md) — placebo treatment time, parallel trends test (visual + formal).

---

## Staggered DiD

**Use when:** Treatment rolls out at different times for different units. Standard DiD with a single date would be misspecified.

**Key assumption:** Parallel trends for each cohort — each treated cohort's counterfactual is well-approximated by not-yet-treated and never-treated units.

**CausalPy class:** `cp.StaggeredDifferenceInDifferences`

```python
import causalpy as cp
import numpy as np

rng = np.random.default_rng(sum(map(ord, "staggered-did")))

result = cp.StaggeredDifferenceInDifferences(
    data=df,
    formula="outcome ~ 1 + C(unit)",
    unit_variable_name="unit",
    time_variable_name="time",
    treated_variable_name="treated",
    treatment_time_variable_name="treatment_date",
    # never_treated_value=np.inf    # default; change if data uses -1 or 0 as sentinel
    # event_window=(-5, 10)         # optional: event-study style (periods relative to treatment)
    model=cp.pymc_models.LinearRegression(
        sample_kwargs={"nuts_sampler": "nutpie", "random_seed": rng}
    ),
)
fig, ax = result.plot()
es = result.effect_summary(direction="two-sided")
print(es.text)
```

**What can go wrong:** TWFE DiD uses already-treated units as controls for later-treated units — biased when treatment effects evolve. CausalPy's staggered implementation mitigates this; verify the comparisons being made. Few cohorts (< 5) produce noisy cohort-specific estimates.

**Refutation:** See [references/refutation.md](refutation.md) — Bacon decomposition, cohort-specific parallel trends checks.

---

## Synthetic Control

**Use when:** You have a single treated unit and a pool of untreated donors whose pre-treatment history can be weighted to approximate the counterfactual.

**Key assumption:** The treated unit's pre-treatment outcomes can be reproduced as a weighted combination of donors. The treated unit must lie within (or near) the convex hull of donors. CausalPy 0.8+ warns about convex hull violations.

**CausalPy class:** `cp.SyntheticControl`

```python
import causalpy as cp
import pandas as pd
import numpy as np

rng = np.random.default_rng(sum(map(ord, "synthetic-control")))

result = cp.SyntheticControl(
    data=df_wide,  # MUST be wide format: index=time, columns=unit names, values=outcome
    treatment_time=pd.Timestamp("2020-01-01"),
    control_units=["unit_A", "unit_B", "unit_C"],
    treated_units=["unit_treated"],
    # SC does NOT use a formula — it finds optimal weights over donors directly
    # If your data is long format, pivot first:
    # df_wide = df.pivot(index="date", columns="unit", values="outcome")
    model=cp.pymc_models.WeightedSumFitter(
        sample_kwargs={"nuts_sampler": "nutpie", "random_seed": rng}
    ),
)
fig, ax = result.plot()
es = result.effect_summary(
    direction="two-sided",
    cumulative=True,   # total cumulative effect over post-treatment window
    relative=True,     # effect as % of counterfactual
)
print(es.text)
print(es.table)
```

**What can go wrong:** Convex hull violation (treated unit is an outlier — inspect pre-treatment fit RMSE); donor contamination (donors affected by spillovers — remove them); fewer than ~5 donors (poorly constrained weights); poor pre-treatment fit means the counterfactual is unreliable.

**Refutation:** See [references/refutation.md](refutation.md) — leave-one-out donors, pre-treatment RMSE, placebo treatments on each control unit.

---

## Interrupted Time Series (ITS)

**Use when:** Single time series, no control group, intervention at a known time. The pre-intervention period defines the counterfactual trend. Weaker than DiD — relies on the pre-trend extrapolating forward with no contaminating events.

**Key assumption:** No confounding event at the treatment time. Requires an explicit user checkpoint.

**CausalPy class:** `cp.InterruptedTimeSeries`

```python
import causalpy as cp
import pandas as pd
import numpy as np

rng = np.random.default_rng(sum(map(ord, "its-analysis")))

result = cp.InterruptedTimeSeries(
    data=df,
    treatment_time=pd.Timestamp("2020-01-01"),
    formula="y ~ 1 + t + C(month)",   # t = numeric time index; C(month) absorbs seasonality
    model=cp.pymc_models.LinearRegression(
        sample_kwargs={"nuts_sampler": "nutpie", "random_seed": rng}
    ),
)
fig, ax = result.plot()
es = result.effect_summary(
    direction="two-sided",
    cumulative=True,
    window="post",   # "post" = all post-treatment points (default); or pass a tuple/slice
)
print(es.text)
print(es.table)
```

**⚠️ MANDATORY USER CHECKPOINT:** Before fitting, ask: "Did anything else change at [treatment_time] that could explain a break in the series?" If yes, the design may not identify the causal effect.

**What can go wrong:** Confounding event (the most common and most serious ITS failure — no statistical test can catch it); autocorrelation in residuals; non-linear pre-trend (add polynomial time terms if needed); too few pre-treatment observations (aim for 12–24+ periods).

**Refutation:** See [references/refutation.md](refutation.md) — placebo treatment time, autocorrelation diagnostics, confounding event search (user checkpoint).

---

## Piecewise ITS

**Use when:** Multiple interventions occurred at different times, or the series has known structural breaks creating distinct segments.

**Key assumption:** Same as ITS — no confounding events at each breakpoint. Assumptions multiply with the number of breaks.

**CausalPy class:** `cp.PiecewiseITS` (requires CausalPy 0.8+)

```python
import causalpy as cp
import numpy as np

rng = np.random.default_rng(sum(map(ord, "piecewise-its")))

# step() = level shift (0 before date, 1 after)
# ramp() = slope change (0 before date, increases linearly after)
result = cp.PiecewiseITS(
    data=df,
    formula=(
        "y ~ 1 + t"
        " + step(t, change_date_1) + ramp(t, change_date_1)"
        " + step(t, change_date_2)"   # add ramp() if slope also changes at date 2
    ),
    model=cp.pymc_models.LinearRegression(
        sample_kwargs={"nuts_sampler": "nutpie", "random_seed": rng}
    ),
)
fig, ax = result.plot()
```

`step()` and `ramp()` are CausalPy formula transforms exported as `cp.step` and `cp.ramp`.

**Fallback if PiecewiseITS is unavailable:** Use `pymc_extras.statespace` (https://github.com/pymc-devs/pymc-extras/tree/main/pymc_extras/statespace) — PyMC's state-space submodule. Fall back to a manual PyMC model only if that doesn't fit. Document whichever path is taken.

**What can go wrong:** All ITS failures, multiplied by the number of breaks. Overfitting with too many segments; break point uncertainty (if timing is approximate, fixing exact dates introduces misspecification).

**Refutation:** Placebo break points, autocorrelation checks, confounding event search at each break.

---

## Regression Discontinuity (RDD)

**Use when:** Treatment is assigned by whether a running variable (score, age, index) crosses a threshold. Units just below and just above the threshold are similar on all other characteristics — the threshold creates local random assignment.

**Key assumption:** No manipulation at the threshold — units cannot sort themselves precisely to one side. Requires a smooth density of the running variable through the threshold (McCrary density test).

**CausalPy class:** `cp.RegressionDiscontinuity`

```python
import causalpy as cp
import numpy as np

rng = np.random.default_rng(sum(map(ord, "rdd-analysis")))

result = cp.RegressionDiscontinuity(
    data=df,
    formula="outcome ~ 1 + running_var + treated + running_var:treated",
    running_variable_name="running_var",
    treatment_threshold=cutoff_value,
    model=cp.pymc_models.LinearRegression(
        sample_kwargs={"nuts_sampler": "nutpie", "random_seed": rng}
    ),
    bandwidth=bandwidth_value,   # restrict to obs within ±bandwidth of threshold
)
fig, ax = result.plot()
es = result.effect_summary(direction="two-sided")
print(es.text)
print(es.table)
```

`running_var:treated` lets the slope differ on each side. For non-linear relationships, add polynomial terms: `"outcome ~ 1 + running_var + I(running_var**2) + treated + running_var:treated"`. Start bandwidth selection with a data-driven approach (Imbens-Kalyanaraman), then check sensitivity in refutation.

**What can go wrong:** Bunching at threshold (manipulation — caught by McCrary test); misspecified functional form (linear fit attributes non-linearity to a spurious discontinuity); bandwidth too wide (weakens local randomization argument); bandwidth too narrow (noisy estimates); covariates jumping at the threshold (selection on observables).

**Refutation:** See [references/refutation.md](refutation.md) — McCrary density test, bandwidth sensitivity, covariate balance at threshold, placebo thresholds.

---

## Regression Kink Design

**Use when:** Treatment *intensity* (not binary assignment) changes slope at a known threshold. You look for a change in the *slope* of the outcome, not a level jump.

**Key assumption:** No manipulation at the kink point, smooth density of running variable. The relationship between the running variable and outcome must be smooth everywhere except at the kink.

**CausalPy class:** `cp.RegressionKink`

```python
import causalpy as cp
import numpy as np

rng = np.random.default_rng(sum(map(ord, "rk-analysis")))

result = cp.RegressionKink(
    data=df,
    formula="outcome ~ 1 + running_var + treated + running_var:treated",
    running_variable_name="running_var",
    kink_point=kink_value,
    model=cp.pymc_models.LinearRegression(
        sample_kwargs={"nuts_sampler": "nutpie", "random_seed": rng}
    ),
    bandwidth=bandwidth_value,
)
fig, ax = result.plot()
es = result.effect_summary(direction="two-sided")
print(es.text)
```

**RDD vs. Regression Kink:** RDD detects a level jump (treatment switches 0→1). Regression Kink detects a slope change (treatment intensity changes continuously). Example: a benefit program that phases out linearly above an income threshold — the kink is where the phase-out begins.

**What can go wrong:** Same as RDD, plus a pre-existing kink in the outcome coinciding with the kink point; small kink angle makes the design underpowered.

**Refutation:** Same as RDD — bandwidth sensitivity, covariate balance, placebo kink points.

---

## Instrumental Variables (IV)

**Use when:** Treatment is endogenous (confounded), but you have an instrument that (a) affects treatment and (b) affects the outcome only through treatment (exclusion restriction). Classic instruments: lottery assignment, distance to facility, policy eligibility cutoffs.

**Key assumptions:**
1. **Relevance:** Instrument strongly predicts treatment. Weak instruments → severely biased estimates.
2. **Exclusion restriction:** Instrument affects outcome only through treatment. Untestable — must be defended on substantive grounds.
3. **Independence:** Instrument is as-good-as-randomly assigned.

**CausalPy class:** `cp.InstrumentalVariable`

```python
import causalpy as cp
import numpy as np

rng = np.random.default_rng(sum(map(ord, "iv-analysis")))

result = cp.InstrumentalVariable(
    instruments_data=df,
    data=df,
    instruments_formula="treatment ~ 1 + instrument",   # first stage
    formula="outcome ~ 1 + treatment",                  # second stage
    model=cp.pymc_models.InstrumentalVariableRegression(
        sample_kwargs={"nuts_sampler": "nutpie", "random_seed": rng}
    ),
)
fig, ax = result.plot()
```

IV estimates the **Local Average Treatment Effect (LATE)** — the effect for compliers (units whose treatment status is changed by the instrument). Report this distinction; LATE ≠ ATE unless all units comply.

**What can go wrong:** Weak instruments (first-stage F < 10 is a warning; F < 5 is very weak — IV estimates are then more biased than OLS); exclusion restriction violated (instrument has a direct effect on outcome — untestable); LATE ≠ ATE when effect heterogeneity is large.

**Note:** Design-specific refutation for IV (weak instrument tests, overidentification) is deferred to v1.1. Use general DoWhy refuters for v1.0. See [references/refutation.md](refutation.md).

---

## Inverse Propensity Score Weighting (IPSW)

**Use when:** Observational data, no natural experiment. Reweight the sample so treatment and control groups have similar covariate distributions, by modeling the probability of treatment given observed covariates (propensity score).

**Key assumptions:**
1. **No unmeasured confounders (strong ignorability):** All variables that affect both treatment and outcome are observed. Untestable.
2. **Positivity:** Every unit has non-zero probability of either treatment status. Extreme propensities → extreme weights → unreliable estimates.

**CausalPy class:** `cp.InversePropensityWeighting`

```python
import causalpy as cp
import numpy as np

rng = np.random.default_rng(sum(map(ord, "ipsw-analysis")))

result = cp.InversePropensityWeighting(
    data=df,
    formula="treatment ~ 1 + confounder1 + confounder2 + confounder3",
    outcome_variable="outcome",
    weighting_scheme="robust",   # "raw": 1/p weights — extreme weights possible
                                 # "robust": Hajek normalized weights — recommended default
                                 # "doubly robust": IPW + outcome model — consistent if either is correct
                                 # "overlap": trims extreme propensities — reduces variance
    model=cp.pymc_models.PropensityScore(
        sample_kwargs={"nuts_sampler": "nutpie", "random_seed": rng}
    ),
)
fig, ax = result.plot()
es = result.effect_summary(direction="two-sided")
print(es.text)
print(es.table)
```

Start with `"robust"`. Use `"doubly robust"` when you also have a plausible outcome model. Use `"overlap"` when propensity scores cluster near 0 or 1.

**What can go wrong:** Unmeasured confounders (the most critical threat — propensity methods only adjust for observed covariates); positivity violations (extreme weights dominate the estimate — inspect propensity distribution); propensity model misspecification (check covariate balance after weighting); limited overlap (IPSW extrapolates if groups don't share covariate support).

**Note:** Design-specific refutation for IPSW (covariate balance after weighting, extreme weight diagnostics) is deferred to v1.1. Use general DoWhy refuters for v1.0. See [references/refutation.md](refutation.md).

---

## Accessing results (all designs)

All CausalPy result objects share a common interface.

```python
# Visualization — always available
fig, ax = result.plot()

# Effect summary — parameters vary by design:
#   DiD, RDD, IV, IPSW: direction, alpha, min_effect
#   SC and ITS additionally: cumulative, relative, window
es = result.effect_summary(direction="two-sided")
print(es.text)    # prose narrative
print(es.table)   # structured DataFrame summary

# SC / ITS with cumulative effects:
es = result.effect_summary(direction="two-sided", cumulative=True, relative=True)

# Underlying InferenceData for deeper analysis:
idata = result.idata
# Delegate all diagnostics to bayesian-workflow:
# import arviz_stats as azs; azs.diagnose(idata)

# Log-likelihood is NOT stored automatically — compute explicitly if needed for LOO:
# with result.model:
#     pm.compute_log_likelihood(idata)
```

Always check the class docstring (`help(cp.DifferenceInDifferences)`) for the full list of `effect_summary` parameters — they differ across designs.
