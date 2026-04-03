# Refutation and Sensitivity Analysis

> **Refutation is MANDATORY for every causal analysis. No exceptions. If you skip this step, the analysis cannot support causal claims.**

## Contents

1. [Refutation principles](#refutation-principles)
2. [DiD refutation recipes](#did-refutation-recipes)
3. [Synthetic Control refutation recipes](#synthetic-control-refutation-recipes)
4. [RDD refutation recipes](#rdd-refutation-recipes)
5. [ITS refutation recipes](#its-refutation-recipes)
6. [General refutation (all designs — DoWhy)](#general-refutation-all-designs--dowhy)
7. [Sensitivity to unobserved confounding](#sensitivity-to-unobserved-confounding)
8. [Pass/fail interpretation](#passfail-interpretation)
9. [What to do when refutation fails](#what-to-do-when-refutation-fails)

---

## Refutation principles

Every causal claim rests on assumptions that cannot be directly tested with the available data. Refutation does not test whether the assumptions are true — it tests whether your conclusions are robust to plausible violations of those assumptions.

**The logic of refutation:**

- **Pass** does NOT prove causality. It means you have tried to falsify your result and have not succeeded. The result remains plausible, not proven.
- **Fail** means the causal claim is suspect. The data are consistent with a world where your assumptions are violated and the apparent effect is spurious.
- The value of refutation is asymmetric: a pass gives limited reassurance, a fail gives strong warning.

**Mandatory refutation checklist — run every test for your design, report all results:**

| Test | Design | Required? |
|------|---------|-----------|
| Placebo treatment time | DiD, ITS | Yes |
| Parallel trends plot | DiD | Yes |
| Bandwidth sensitivity | RDD | Yes |
| McCrary density test | RDD | Yes |
| Placebo thresholds | RDD | Yes |
| Leave-one-out donors | Synthetic Control | Yes |
| Pre-treatment fit quality | Synthetic Control | Yes |
| Placebo treatments on controls | Synthetic Control | Yes |
| Random common cause | All (DoWhy) | Yes |
| Placebo treatment (DoWhy) | All (DoWhy) | Yes |
| Data subset stability | All (DoWhy) | Yes |
| Unobserved confounding sensitivity | All observational | Yes |

Report results as a pass/fail table. Do not bury failures in footnotes.

---

## DiD refutation recipes

### Placebo treatment time

Shift the treatment to a point in the pre-treatment period. If your parallel trends assumption holds and the real effect is real, the "effect" estimated at the placebo time should be indistinguishable from zero.

```python
import causalpy as cp
import numpy as np

# Use only pre-treatment data
df_pre_only = df[df["time"] < treatment_time].copy()
placebo_time = df_pre_only["time"].median()  # midpoint of pre-period

result_placebo = cp.DifferenceInDifferences(
    data=df_pre_only,
    formula=same_formula,
    time_variable_name="time",
    group_variable_name="group",
    model=cp.pymc_models.LinearRegression(
        sample_kwargs={"random_seed": rng, "nuts_sampler": "nutpie"}
    ),
)

# PASS if: placebo effect HDI includes zero
print(result_placebo.summary())
```

**Interpretation:** If the placebo effect is large and its HDI excludes zero, the parallel trends assumption is likely violated — units were already diverging before treatment. The real effect estimate is unreliable.

### Parallel trends test

Before any modeling, plot pre-treatment outcomes for treatment and control groups. They should track each other closely. Divergence in the pre-period is the strongest visual signal that DiD is invalid.

```python
import matplotlib.pyplot as plt

pre = df[df["time"] < treatment_time].copy()

fig, ax = plt.subplots(figsize=(9, 4))
for g in pre["group"].unique():
    gd = pre[pre["group"] == g]
    ax.plot(gd["time"], gd["outcome"], label=str(g), marker="o")

ax.axvline(treatment_time, color="red", linestyle="--", alpha=0.6, label="Treatment")
ax.set_title("Pre-treatment trends (should be parallel)")
ax.set_xlabel("Time")
ax.set_ylabel("Outcome")
ax.legend()
plt.tight_layout()
```

**What to look for:** Trend lines should be approximately parallel — same slope, even if different levels. If they are converging, diverging, or crossing, parallel trends is violated.

**If the trends are not parallel:** DiD is not valid for this data. Consider a matching pre-trend model, or switch designs (synthetic control handles heterogeneous pre-trends better).

### Bacon decomposition (staggered DiD)

When treatment is staggered (units adopt treatment at different times), the standard DiD estimator is a weighted average of many 2×2 DiD sub-estimates — some of which use already-treated units as controls. This can produce negatively-weighted comparisons that flip the sign of the true effect.

```python
# Use the bacon_decomposition package or inspect manually
# Each 2x2 estimate: early-treated vs control, late-treated vs control,
# early-treated vs late-treated (problematic if effects are heterogeneous)

# Flag: if any 2x2 comparison uses a treated unit as control, report it
# Flag: if weights are negative, the overall estimate may be uninformative
```

**Interpretation:** Large variation across sub-estimates, or negative weights on sub-estimates, indicates treatment effect heterogeneity that the standard TWFE estimator cannot handle. Use a staggered DiD estimator (Callaway-Sant'Anna, Sun-Abraham) instead.

---

## Synthetic Control refutation recipes

### Leave-one-out donors

Re-fit the synthetic control model removing each donor unit one at a time. If the post-treatment trajectory changes dramatically when any single donor is removed, the result is fragile and dependent on that one unit.

```python
donors = df[df["group"] == "donor"]["unit"].unique()

loo_estimates = {}
for drop_unit in donors:
    df_loo = df[df["unit"] != drop_unit].copy()
    control_units_loo = [u for u in control_units if u != drop_unit]
    sc_loo = cp.SyntheticControl(
        data=df_loo,
        treatment_time=treatment_time,
        control_units=control_units_loo,
        treated_units=treated_units,
        model=cp.pymc_models.WeightedSumFitter(
            sample_kwargs={"random_seed": rng, "nuts_sampler": "nutpie"}
        ),
    )
    loo_estimates[drop_unit] = sc_loo.effect_summary()

# PASS if: post-treatment effect estimates are stable across all LOO runs
# FAIL if: removing any single donor shifts the estimate substantially
```

### Pre-treatment fit quality

The synthetic control must closely track the treated unit in the pre-treatment period. Poor pre-treatment fit means the synthetic control is not a valid counterfactual, and the post-treatment gap is not interpretable as a causal effect.

```python
import numpy as np

pre_actual = df[(df["group"] == "treated") & (df["time"] < treatment_time)]["outcome"].values
# Pre-period synthetic values are stored in sc_result.datapre (an xarray Dataset)
pre_synthetic = sc_result.datapre["synthetic"].values

rmse = np.sqrt(np.mean((pre_actual - pre_synthetic) ** 2))
print(f"Pre-treatment RMSE: {rmse:.4f}")

# PASS if: RMSE is small relative to the scale of the outcome and the post-treatment gap
# Rule of thumb: RMSE < 10% of the post-treatment effect estimate warrants confidence
```

**If pre-treatment fit is poor:** Do not interpret the post-treatment gap causally. Add more predictors to the formula, expand the donor pool, or switch to a Bayesian structural time series model.

### Placebo treatments on controls

Apply the synthetic control procedure to each control unit as if it were the treated unit, using the remaining controls as donors. Compute the post-treatment "effect" for each placebo. If many placebo units show effects as large as the real treated unit, the result is not statistically meaningful.

```python
placebo_effects = {}
for placebo_treated in donors:
    placebo_donors = [u for u in donors if u != placebo_treated]
    sc_placebo = cp.SyntheticControl(
        data=df[df["unit"] != treated_unit].copy(),
        treatment_time=treatment_time,
        control_units=placebo_donors,
        treated_units=[placebo_treated],
        model=cp.pymc_models.WeightedSumFitter(
            sample_kwargs={"random_seed": rng, "nuts_sampler": "nutpie"}
        ),
    )
    summary = sc_placebo.effect_summary()
    placebo_effects[placebo_treated] = summary["mean"].values[0]

# Compute p-value analogue: fraction of placebos with effect >= real effect
real_summary = sc_result.effect_summary()
real_effect = real_summary["mean"].values[0]
p_value_analogue = np.mean([abs(v) >= abs(real_effect) for v in placebo_effects.values()])
print(f"Fraction of placebos as extreme as treated: {p_value_analogue:.2f}")

# PASS if: p_value_analogue < 0.10 (fewer than 1 in 10 placebos match the real effect)
```

---

## RDD refutation recipes

### McCrary density test

Test for bunching at the threshold in the running variable. If units can manipulate whether they fall just above or just below the threshold, the "as-good-as-random" assumption of RDD is violated. A sharp spike in density just below (for a threshold where being above means treatment) is the classic manipulation signature.

```python
# Visual inspection
import matplotlib.pyplot as plt

fig, ax = plt.subplots()
ax.hist(df["running_var"], bins=50, edgecolor="white")
ax.axvline(threshold, color="red", linestyle="--", label="Threshold")
ax.set_title("Running variable density (check for bunching at threshold)")
ax.legend()

# Formal test: use rddensity (R) or a Python port
# If density shows a discontinuity at the threshold, RDD is invalid
```

**If bunching is detected:** Report that the RDD design assumption is violated. Units near the threshold are not comparable. Do not proceed with causal claims. Consider restricting to units far from the threshold (fuzzy analysis) or switching designs.

### Bandwidth sensitivity

The RDD estimate should be robust to reasonable choices of bandwidth. If the estimate changes dramatically as bandwidth varies, the result is sensitive to an arbitrary analyst choice.

```python
import causalpy as cp

base_bw = rdd_result.bandwidth  # whatever the default or IK-optimal bandwidth was
bandwidths = [base_bw * f for f in [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]]

bw_estimates = []
for bw_val in bandwidths:
    r = cp.RegressionDiscontinuity(
        data=df,
        formula=formula,
        running_variable_name="running_var",
        treatment_threshold=threshold,
        model=cp.pymc_models.LinearRegression(
            sample_kwargs={"random_seed": rng, "nuts_sampler": "nutpie"}
        ),
        bandwidth=bw_val,
    )
    summary = r.summary()
    bw_estimates.append({"bandwidth": bw_val, "estimate": summary["mean"], "hdi_lo": summary["hdi_3%"], "hdi_hi": summary["hdi_97%"]})

# Plot bandwidth sensitivity
import pandas as pd
bw_df = pd.DataFrame(bw_estimates)
fig, ax = plt.subplots()
ax.plot(bw_df["bandwidth"], bw_df["estimate"], marker="o")
ax.fill_between(bw_df["bandwidth"], bw_df["hdi_lo"], bw_df["hdi_hi"], alpha=0.2)
ax.axhline(0, color="gray", linestyle="--")
ax.set_xlabel("Bandwidth")
ax.set_ylabel("Effect estimate")
ax.set_title("Bandwidth sensitivity (should be stable)")

# PASS if: estimates are stable and HDIs overlap across bandwidths
```

### Covariate balance at threshold

Covariates (pre-determined characteristics) should not jump discontinuously at the threshold. A covariate jump indicates that units on either side of the threshold differ in ways unrelated to treatment — violating the continuity assumption.

```python
# Run a separate RDD with each covariate as the outcome
covariates = ["age", "income", "prior_outcome"]  # replace with your pre-treatment covariates

for cov in covariates:
    r_cov = cp.RegressionDiscontinuity(
        data=df,
        formula=f"{cov} ~ 1 + running_var",
        running_variable_name="running_var",
        treatment_threshold=threshold,
        model=cp.pymc_models.LinearRegression(
            sample_kwargs={"random_seed": rng, "nuts_sampler": "nutpie"}
        ),
        bandwidth=base_bw,
    )
    print(f"Covariate balance — {cov}:")
    print(r_cov.summary())
    # PASS if: effect HDI includes zero for all covariates
```

### Placebo thresholds

Move the threshold to other values in the pre-treatment distribution. No effect should appear at values that do not correspond to the true treatment threshold.

```python
running_var_quantiles = df["running_var"].quantile([0.25, 0.40, 0.60, 0.75]).tolist()

for placebo_thresh in running_var_quantiles:
    if abs(placebo_thresh - threshold) < base_bw:
        continue  # skip placebo thresholds too close to the real one
    r_placebo = cp.RegressionDiscontinuity(
        data=df[df["running_var"] < threshold],  # use only pre-threshold data
        formula=formula,
        running_variable_name="running_var",
        treatment_threshold=placebo_thresh,
        model=cp.pymc_models.LinearRegression(
            sample_kwargs={"random_seed": rng, "nuts_sampler": "nutpie"}
        ),
        bandwidth=base_bw,
    )
    print(f"Placebo threshold {placebo_thresh:.2f}: {r_placebo.summary()}")
    # PASS if: effect HDI includes zero at all placebo thresholds
```

---

## ITS refutation recipes

### Placebo treatment time

Same logic as the DiD placebo. Shift treatment to the middle of the pre-period and estimate the "effect." If real, it should be near zero.

```python
df_pre_only = df[df["time"] < treatment_time].copy()
placebo_time = df_pre_only["time"].median()

result_placebo = cp.InterruptedTimeSeries(
    data=df_pre_only,
    treatment_time=placebo_time,
    formula=formula,
    model=cp.pymc_models.LinearRegression(
        sample_kwargs={"random_seed": rng, "nuts_sampler": "nutpie"}
    ),
)

# PASS if: placebo effect HDI includes zero
print(result_placebo.effect_summary())
```

### Autocorrelation diagnostics

ITS fits a regression to time-series data. Residuals from time-series regressions are often autocorrelated. If they are, the effective sample size is smaller than the nominal sample size, and standard errors are underestimated — potentially producing a spurious significant result.

```python
import statsmodels.stats.stattools as sms

# Extract posterior mean residuals
residuals = its_result.get_residuals()  # or compute manually

# Durbin-Watson statistic: 2 = no autocorrelation, < 2 = positive, > 2 = negative
dw = sms.durbin_watson(residuals)
print(f"Durbin-Watson: {dw:.3f}")
# Values between 1.5 and 2.5 are generally acceptable

# Plot ACF
import matplotlib.pyplot as plt
from statsmodels.graphics.tsaplots import plot_acf
plot_acf(residuals, lags=20)
plt.title("Residual autocorrelation (spikes outside band = problem)")
plt.tight_layout()

# If autocorrelation is present: add AR terms to the model formula,
# or use a model with explicit autocorrelation structure
```

### Confounding event search

ITS is especially vulnerable to events that happened at the same time as the treatment but are not the treatment. There is no statistical test for this — it requires domain knowledge.

> **Ask the user:** "Did anything else change at or near the treatment time that could explain the observed trend change? Examples: a policy change elsewhere, a market shock, a shift in data collection practices, a simultaneous intervention on a related variable."

If the user identifies a potential confound, either (a) control for it by adding it to the model, (b) collect data on a control unit that experienced the confound but not the treatment (converting ITS to DiD), or (c) downgrade the causal claim.

---

## General refutation (all designs — DoWhy)

These three refuters apply to any analysis where you have a DAG and a DoWhy model. Run all three. They probe complementary failure modes.

```python
import dowhy

dowhy_model = dowhy.CausalModel(
    data=df,
    treatment="treatment",
    outcome="outcome",
    graph=dag,  # your nx.DiGraph from dags-and-identification.md
)

identified = dowhy_model.identify_effect(proceed_when_unidentifiable=False)
estimate = dowhy_model.estimate_effect(
    identified,
    method_name="backdoor.linear_regression",
)

# 1. Random common cause
# Adds a random covariate as an unobserved common cause.
# If the estimate changes substantially, the model is fragile.
ref_rcc = dowhy_model.refute_estimate(
    identified, estimate, method_name="random_common_cause"
)
print(ref_rcc)
# PASS if: new estimate ≈ original estimate (within sampling noise)

# 2. Placebo treatment
# Replaces the real treatment with a random permutation.
# The effect should vanish — a real causal effect cannot survive random treatment assignment.
ref_placebo = dowhy_model.refute_estimate(
    identified, estimate, method_name="placebo_treatment_refuter"
)
print(ref_placebo)
# PASS if: refuted estimate ≈ 0

# 3. Data subset
# Re-estimates on random 80% subsets of the data.
# A robust effect should be stable across subsets.
ref_subset = dowhy_model.refute_estimate(
    identified, estimate, method_name="data_subset_refuter", subset_fraction=0.8
)
print(ref_subset)
# PASS if: estimate stable (HDIs overlap across subsets)
```

---

## Sensitivity to unobserved confounding

This is the most important sensitivity analysis for observational data. Even if all other refutations pass, an unobserved confounder could explain your result. The question is: **how strong would that confounder need to be?**

A weak effect that can be explained by a modest confounder is fragile. A large effect that requires an implausibly strong confounder to be explained away is credible.

```python
# Start with a small effect strength and increase until the estimate is "explained away"
for strength in [0.05, 0.1, 0.2, 0.3, 0.5]:
    ref_confound = dowhy_model.refute_estimate(
        identified,
        estimate,
        method_name="add_unobserved_common_cause",
        confounders_effect_on_treatment="binary_flip",
        confounders_effect_on_outcome="linear",
        effect_strength_on_treatment=strength,
        effect_strength_on_outcome=strength,
    )
    print(f"Confounder strength {strength}: refuted estimate = {ref_confound.new_effect:.4f}")

# The "tipping point" is the strength at which the effect is driven to zero
# Report: "The effect is robust to unobserved confounders up to strength X.
#          A confounder of strength > X would be required to explain away the result.
#          For context, [observed covariate Z] has an association strength of ~Y."
```

**Interpreting the tipping point:** Compare the tipping-point strength to the observed associations of your measured confounders. If explaining away the result requires a confounder much stronger than anything you have measured, the result is credible. If it requires only a modest confounder, report with appropriate humility.

**Reporting language template:**

> "The estimated effect of [treatment] on [outcome] is [X] (95% HDI: [lo, hi]). Sensitivity analysis shows this estimate is robust to unobserved confounders with effect strengths up to approximately [tipping point]. Given that the strongest observed confounder ([variable]) has an association of [observed strength], an unobserved confounder capable of explaining away this result would need to be approximately [ratio]× stronger than any variable we have measured."

---

## Pass/fail interpretation

| Result | Meaning | Action |
|--------|---------|--------|
| All pass | Robust to tested failures | Proceed with causal language |
| Most pass, some marginal | Mildly sensitive | Use hedged language: "suggestive causal evidence" |
| Critical test fails | Assumption likely violated | Downgrade to associational language |
| Multiple failures | Design likely invalid | Do not make causal claims; revisit design |

**Critical tests** (failure of any one is disqualifying):

- Placebo treatment time shows large non-zero effect
- McCrary density test shows bunching at RDD threshold
- Pre-treatment RMSE (SC) is comparable in size to the post-treatment gap
- DoWhy placebo treatment does not drive effect to zero
- Unobserved confounder tipping point is implausibly low

**Marginal tests** (failure warrants caveats but not disqualification):

- Bandwidth sensitivity shows modest variation within overlapping HDIs
- Durbin-Watson indicates mild autocorrelation in ITS residuals
- Leave-one-out SC shows one influential donor
- Data subset refuter shows estimate drifts but remains on same side of zero

---

## What to do when refutation fails

**Rule: do not hide failures.** A buried failure in an appendix is still a failure. Report it prominently, at the top of the findings section.

### Step-by-step failure response

1. **Identify which assumption failed.** Is it a testable design assumption (parallel trends, density continuity) or an untestable structural assumption (no unobserved confounding)? Testable failures are more serious — they are direct evidence of a problem, not just a risk.

2. **Determine if it is fixable.** Some failures suggest a different model or design. Others are fundamental to the data-generating process.

   | Failure type | Possible fix |
   |---|---|
   | Non-parallel pre-trends | Add unit-specific time trends; switch to synthetic control |
   | Bunching at RDD threshold | Restrict to bandwidth well away from threshold; use fuzzy RDD |
   | Poor SC pre-treatment fit | Expand donor pool; add predictors; use BSTS instead |
   | ITS autocorrelation | Add AR terms; use a time-series model |
   | Low unobserved confounding tipping point | Collect more covariates; use a stronger design |
   | DoWhy placebo non-zero | Re-examine DAG; check for residual confounding in adjustment set |

3. **Downgrade the language.** Use "associated with" instead of "causes." Use "suggestive" instead of "demonstrates." Never use causal language when the design has failed its own refutation tests.

4. **Consider alternative designs.** If observational adjustment fails, is there a quasi-experimental design available? Can you find an instrument, a discontinuity, or a comparison group that restores identification?

5. **Mark the assumption as fragile in the report.** Use explicit flagging:

   > "Warning: the parallel trends assumption is not supported by pre-treatment data. The DiD estimate below should be interpreted as associational, not causal. We retain the analysis for transparency but recommend collecting additional comparison units before drawing policy conclusions."

6. **Do not iterate until you get a pass.** Re-running refutation with slightly different parameters until it passes is p-hacking by another name. Run the tests once, with pre-specified parameters, and report honestly.
