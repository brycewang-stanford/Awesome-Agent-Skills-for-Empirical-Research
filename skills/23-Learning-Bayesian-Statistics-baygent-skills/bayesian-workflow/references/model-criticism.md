# Model Criticism

Model criticism answers: "Is this model any good?" Convergence diagnostics (reference/diagnostics.md) only tell you the sampler worked -- they say nothing about whether the model is appropriate for the data.

## Contents
- Posterior predictive checks (PPC)
- Leave-one-out cross-validation (LOO-CV)
- Calibration assessment
- Simulation-based calibration (SBC)
- Residual analysis
- Decision workflow

## Posterior predictive checks (PPC)

The most important model criticism tool. Simulate data from the fitted model and compare to observed data.

```python
with model:
    idata.extend(pm.sample_posterior_predictive(idata, random_seed=rng))

# Visual check: do simulated datasets resemble the real data?
az.plot_ppc(idata)
```

**What to look for**:
- Posterior predictive distribution should envelop the observed data
- Check shape, spread, and key features (skewness, multimodality, tails)
- Systematic departures indicate model misspecification

**Targeted PPCs** — Check specific data features the model should capture, using `az.plot_ppc` 
to isolate parameters of interest (e.g the posterior standard deviation, to check if model captures the observed variance).

Choose test statistics relevant to your problem: mean, variance, skewness, max, proportion above threshold, autocorrelation (for time series), etc.

## Leave-one-out cross-validation (LOO-CV)

Estimates out-of-sample predictive accuracy using Pareto-smoothed importance sampling (PSIS-LOO). This is the primary tool for model comparison but also useful for single-model criticism.

```python
loo = az.loo(idata, pointwise=True)
print(loo)
```

**Key outputs**:
- `elpd_loo`: Expected log pointwise predictive density. Higher (less negative) is better.
- `p_loo`: Effective number of parameters. If p_loo >> actual parameter count, the model may be misspecified or the priors are too weak.
- `pareto_k`: Per-observation diagnostic. Flags influential or poorly-fit observations.

**Pareto k diagnostic** — Critical for trusting LOO results:

| Pareto k | Interpretation | Action |
|---|---|---|
| < 0.5 | Reliable | Trust LOO estimate |
| 0.5–0.7 | Marginally reliable | Investigate flagged observations |
| > 0.7 | Unreliable for that observation | Use K-fold CV or moment matching |

```python
# Find problematic observations
pareto_k = loo.pareto_k.values
bad_obs = np.where(pareto_k > 0.7)[0]
print(f"Observations with high Pareto k: {bad_obs}")

# Visualize
az.plot_khat(loo)
```

High Pareto k observations are often outliers or observations the model fits poorly. Investigate them — they may reveal model misspecification.

## Calibration assessment

Calibration is mandatory for every model, not optional. A well-calibrated model's X% credible intervals should contain the true value about X% of the time. Run this even for binary and count data — ArviZ handles all data types correctly.

### How to run calibration

Always use ArviZ for calibration plots. Don't write custom calibration code — ArviZ's `plot_ppc_pit` handles continuous, binary, and count data correctly out of the box:

```python
# ArviZ 1.0+ (arviz_plots)
import arviz_plots as azp

# PPC-PIT: compares posterior predictive to observed
azp.plot_ppc_pit(idata)

# LOO-PIT: leave-one-out calibration (more robust, preferred when LOO is available)
azp.plot_ppc_pit(idata, loo_pit=True)
```

Refer to [this guide](https://arviz-devs.github.io/EABM/Chapters/Prior_posterior_predictive_checks.html#coverage) for detailed coverage interpretation — it's a treasure trove for the whole Bayesian workflow.

### Coverage calibration

**Interpretation**:
- If empirical coverage ≈ nominal → well-calibrated
- If the difference is positive, the model is under-confident: the predictions have a wider spread than the data – they are too uncertain.
- If the difference is negative, the model is over-confident: the predictions have a narrower spread than the data – they are too certain.

### PIT histograms (probability integral transform)

A sharper calibration check. If the model is calibrated, PIT values should be uniform. Refer to [this section](https://arviz-devs.github.io/EABM/Chapters/Prior_posterior_predictive_checks.html#pit-ecdfs) for how to do it, using the new ArviZ.

**Patterns**:
- U-shaped → underdispersed (intervals too narrow)
- Inverted-U → overdispersed (intervals too wide)
- Skewed → systematic bias in location
- Uniform → well-calibrated

## Simulation-based calibration (SBC)

SBC validates that the entire inference pipeline is correct — priors, data model, sampler, and code. It simulates data from the prior, fits the model, and checks that posterior rank statistics are uniform.

This is the gold standard for validating a new model implementation. Run it once per model specification, if you have doubts about the model, since SBC is computationally expensive.

Use the [simuk package](https://github.com/arviz-devs/simuk), either directly, or as inspiration to adapt your own code.

**Interpretation**:
- Uniform ranks → inference pipeline is correct
- Systematic patterns → implementation bug, wrong prior, sampler failure
- SBC failures mean the model code has a bug — fix before interpreting results

**When to run SBC**:
- Developing a new model you'll reuse
- Complex hierarchical models where bugs are easy to introduce
- Custom data models or potentials
- Not necessary for routine analyses with standard model families

## Residual analysis

For regression-style models, check residuals for patterns:

```python
# Posterior predictive mean
pp_mean = idata.posterior_predictive["obs"].mean(dim=["chain", "draw"])
residuals = y_obs - pp_mean

# Residuals vs. fitted
plt.scatter(pp_mean, residuals, alpha=0.5)
plt.axhline(0, color="red", linestyle="--")
plt.xlabel("Fitted values")
plt.ylabel("Residuals")
plt.title("Residuals vs. Fitted")

# Residuals vs. predictors (check for missed nonlinearity)
for j, name in enumerate(predictor_names):
    plt.figure()
    plt.scatter(X[:, j], residuals, alpha=0.5)
    plt.axhline(0, color="red", linestyle="--")
    plt.xlabel(name)
    plt.ylabel("Residuals")
```

Look for: trends (missed nonlinearity), fans (heteroscedasticity), clusters (missing grouping variable).

## Classification and ordinal model evaluation

Standard PPC and calibration checks apply to classification models — **always run `plot_ppc_pit` first** (see Calibration assessment above). The metrics below supplement PPC-PIT with classification-specific numeric summaries. Note: `sklearn.metrics.brier_score_loss` exists but is binary-only; there is no standard package for multiclass ECE or categorical RPS, so we provide lightweight helpers:

### Metrics for categorical/ordinal outcomes

```python
def expected_calibration_error(pred_probs, actuals, n_bins=10):
    """Confidence-based ECE: are predicted probabilities well-calibrated?"""
    # Standard ECE: bin on the model's confidence (max predicted probability),
    # compare to accuracy within each bin.
    confidences = np.max(pred_probs, axis=1)
    predictions = np.argmax(pred_probs, axis=1)
    accuracies = (predictions == actuals).astype(float)
    bin_edges = np.linspace(0, 1, n_bins + 1)
    ece = 0
    for i in range(n_bins):
        in_bin = (confidences >= bin_edges[i]) & (confidences < bin_edges[i + 1])
        if in_bin.sum() > 0:
            avg_confidence = confidences[in_bin].mean()
            avg_accuracy = accuracies[in_bin].mean()
            ece += np.abs(avg_confidence - avg_accuracy) * in_bin.sum()
    return ece / len(actuals)

def ranked_probability_score(pred_probs, actuals, n_classes):
    """RPS: gold standard for ordinal outcomes. Penalizes being 'far off' more than Brier."""
    rps = 0
    for i, actual in enumerate(actuals):
        pred_cum = np.cumsum(pred_probs[i])
        actual_cum = np.zeros(n_classes)
        actual_cum[int(actual):] = 1
        rps += np.sum((pred_cum - actual_cum) ** 2)
    return rps / len(actuals)
```

### Per-class calibration plots

For classification models, always check calibration **per class**, not just overall. A model can be well-calibrated on average but poorly calibrated for specific outcomes (e.g., good at predicting home wins but overconfident on draws).

```python
fig, axes = plt.subplots(1, n_classes, figsize=(5 * n_classes, 4))
for k, ax in enumerate(axes):
    pred_k = pred_probs[:, k]
    actual_k = (actuals == k).astype(float)
    # Bin predictions and compute observed frequency
    bin_edges = np.linspace(0, 1, 11)
    bin_centers, bin_means = [], []
    for i in range(10):
        mask = (pred_k >= bin_edges[i]) & (pred_k < bin_edges[i + 1])
        if mask.sum() > 5:
            bin_centers.append(pred_k[mask].mean())
            bin_means.append(actual_k[mask].mean())
    ax.plot([0, 1], [0, 1], "k--", alpha=0.3)
    ax.scatter(bin_centers, bin_means)
    ax.set_title(f"Class {k}")
    ax.set_xlabel("Predicted P")
    ax.set_ylabel("Observed frequency")
```

### Key metrics summary

| Metric | Use when | Interpretation |
|--------|----------|---------------|
| Brier score | Any categorical model | Lower is better. Random: ~0.67 (3-class) |
| RPS | Ordinal outcomes | Lower is better. Penalizes "far off" predictions more |
| ECE | Need calibration number | Lower is better. 0 = perfectly calibrated |
| Per-class calibration | Always for classification | Points should track the diagonal |
| Accuracy | Stakeholder communication only | Ignores probability quality — never use alone |

## Temporal and out-of-sample evaluation

For panel data or time-series-adjacent data (e.g., multiple seasons), always evaluate **per time period**:

```python
for period in sorted(data_oos["season"].unique()):
    mask = data_oos["season"] == period
    period_metrics = evaluate(pred_probs[mask], actuals[mask])
    print(f"{period}: {period_metrics}")
```

This reveals **temporal degradation** — a model that works well on 2020 but poorly on 2023 may be overfitting to historical patterns. If you see degradation, consider whether the data-generating process has changed (concept drift) or whether the training window needs expanding.

## Feature importance for shrinkage models

When using sparsity priors (horseshoe, R2-D2), summarize feature relevance via **probability of practical significance**:

```python
beta_samples = idata.posterior["beta"].stack(samples=("chain", "draw")).values
threshold = 0.05  # on the standardized coefficient scale

importance = pd.DataFrame({
    "feature": features,
    "posterior_mean": beta_samples.mean(axis=-1),
    "posterior_sd": beta_samples.std(axis=-1),
    "P(|beta|>threshold)": (np.abs(beta_samples) > threshold).mean(axis=-1),
}).sort_values("P(|beta|>threshold)", ascending=False)
```

This is more informative than just looking at posterior means — it tells you the **probability that each feature has a practically meaningful effect**, which is the natural Bayesian answer to "which features matter?"

## Decision workflow

After running diagnostics:

```
1. Convergence OK?  (reference/diagnostics.md)
   NO  → Fix sampler issues first. Do NOT proceed.
   YES ↓

2. Posterior predictive check pass?
   NO  → Model misspecification. Revise data model or add complexity.
   YES ↓

3. LOO-CV: any high Pareto k?
   YES → Investigate flagged observations. Consider K-fold CV.
   NO  ↓

4. Calibration OK?  (coverage + PIT)
   NO  → Model is mis-calibrated. Check priors, data model, missing predictors.
   YES ↓

5. Residual patterns?
   YES → Missing structure. Add predictors, nonlinearity, or hierarchical effects.
   NO  ↓

→ Model is ready for interpretation and reporting.
```
