# Bayesian Estimation: MCMC Diagnostics and Posterior Inference

Full reference for diagnosing MCMC convergence and conducting posterior inference. Always run the complete diagnostic checklist before reporting any results — a posterior with poor convergence is not a valid posterior.

---

## MCMC Diagnostics

### R-hat (Potential Scale Reduction Factor)

R-hat compares variance within chains to variance between chains. Values near 1.0 indicate chains have mixed and converged to the same distribution.

**Decision rules:**
- R-hat < 1.01: Good convergence (Stan default threshold)
- 1.01 <= R-hat < 1.05: Borderline — run longer chains (double iterations)
- R-hat >= 1.05: Poor convergence — chains have not mixed; do not report results
- R-hat >= 1.1: Severe non-convergence — model geometry problem; reparametrize

```python
import arviz as az

# Full summary with R-hat and ESS for all parameters
summary = az.summary(idata, var_names=["beta", "sigma", "mu_beta"])
print(summary[["mean", "sd", "hdi_3%", "hdi_97%", "r_hat", "ess_bulk", "ess_tail"]])

# Flag parameters with R-hat > 1.01
bad_rhat = summary[summary["r_hat"] > 1.01]
if len(bad_rhat) > 0:
    print("WARNING: R-hat > 1.01 for:", bad_rhat.index.tolist())
```

### Effective Sample Size (ESS)

ESS measures the number of independent draws the MCMC chain is equivalent to. High autocorrelation between draws reduces ESS below the total number of draws.

- **Bulk ESS**: Reliability of posterior means and medians. Should be > 400.
- **Tail ESS**: Reliability of tail quantiles (5th, 95th percentile). Should be > 400; needs 1000+ for reliable 90% HDI.

**Decision rules:**
- ESS / total_draws > 0.5: Excellent mixing
- ESS / total_draws 0.1–0.5: Acceptable
- ESS / total_draws < 0.1: Poor mixing — increase iterations or reparametrize

```python
# Check ESS for all parameters
print(summary[["ess_bulk", "ess_tail"]])

total_draws = 4 * 2000  # 4 chains * 2000 draws each
summary["ess_ratio"] = summary["ess_bulk"] / total_draws
low_ess = summary[summary["ess_ratio"] < 0.1]
if len(low_ess) > 0:
    print("WARNING: Low ESS ratio for:", low_ess.index.tolist())
    print("Fix: increase iterations, reduce autocorrelation via reparametrization")
```

### Trace Plots

Visual check that chains have converged and are mixing well.

```python
# Trace plots — should look like "fuzzy caterpillars"
az.plot_trace(idata, var_names=["beta", "sigma"])

# Pathological patterns to watch for:
# - Upward/downward trends: chain not converged, needs longer warmup
# - Stuck chain: one chain at a different level, possible local mode
# - Spiky chain with low acceptance: step size too large
# - All chains superimposed but oscillating widely: high variance, need more draws
```

### Divergences — Zero Tolerance

A divergence indicates the NUTS trajectory left a region of high probability density, signaling a pathological posterior geometry. Even 1% divergence rate invalidates the posterior.

```python
# Count divergences
divergences = idata.sample_stats["diverging"].values.sum()
total_draws = idata.sample_stats["diverging"].values.size
print(f"Divergences: {divergences} / {total_draws} ({divergences/total_draws:.1%})")

if divergences > 0:
    print("ACTION REQUIRED: Fix divergences before reporting results.")

# Visualize where divergences occur in parameter space
az.plot_pair(idata, var_names=["beta", "sigma"], divergences=True)
# Divergent draws appear as red dots — their location shows which parameters
# have problematic geometry.
```

**Fixes for divergences (in order of preference):**
1. Raise `target_accept` from 0.8 to 0.9 or 0.95 (slows sampling but reduces divergences)
2. Apply non-centered parametrization (most common fix for hierarchical models)
3. Tighten priors on scale parameters (very wide scale priors create funnels)
4. Reparametrize constrained parameters (log transform, Cholesky decomposition)

### Energy Diagnostic (BFMI)

The Bayesian Fraction of Missing Information (BFMI) measures how efficiently the sampler explores the posterior energy landscape.

```python
# Compute BFMI per chain
bfmi = az.bfmi(idata)
print(f"BFMI: {bfmi}")

# Decision rule:
# BFMI > 0.3: Good
# 0.2 < BFMI < 0.3: Borderline — investigate further
# BFMI < 0.2: Poor — geometry problem, reparametrize

# Low BFMI often co-occurs with divergences; fix the root cause, not the symptom.
```

### Geometry Problem Diagnostics

| Symptom | Cause | Fix |
|---------|-------|-----|
| Divergences in hierarchical model | Funnel geometry (centered parametrization) | Non-centered parametrization |
| Low ESS for scale parameters | Near-zero scale posterior (sigma → 0) | Log parametrization of sigma |
| Divergences with covariance matrices | Ill-conditioned matrix near boundary | Cholesky parametrization, LKJ(2) prior |
| Slow mixing for correlated parameters | High posterior correlation | Reparametrize to decorrelate |
| BFMI < 0.2 with no divergences | Global geometry issue | Increase target_accept, check prior scale |

### Complete Diagnostic Checklist

Run this after every MCMC fit before proceeding to inference:

- [ ] R-hat < 1.01 for all parameters
- [ ] Bulk ESS > 400 for all parameters
- [ ] Tail ESS > 400 (ideally > 1000 for reported credible intervals)
- [ ] Zero divergences
- [ ] BFMI > 0.2
- [ ] Trace plots show fuzzy caterpillar pattern (no trends, no stuck chains)
- [ ] Prior predictive check was run before estimation
- [ ] Posterior predictive check passes (model can reproduce observed data)

---

## Posterior Inference and Reporting

### Credible Intervals

The highest density interval (HDI) is preferred over the equal-tailed interval when posteriors are skewed. The HDI is the shortest interval containing the specified probability mass.

```python
import arviz as az

# 90% HDI for all parameters
hdi_90 = az.hdi(idata, hdi_prob=0.90)
print(hdi_90)

# Reporting template:
# "The posterior mean price elasticity is -1.24 (90% HDI: [-1.61, -0.89])."
# Prefer 90% over 95% in applied economics (matches one-tailed 5% frequentist convention).

# Posterior mean and SD
summary = az.summary(idata, hdi_prob=0.90)
print(summary[["mean", "sd", "hdi_5%", "hdi_95%"]])
```

### Posterior Predictive Checks

Generate data from the posterior and compare to observed data. This is the primary model validation tool in Bayesian analysis.

```python
# PyMC: sample posterior predictive
with model:
    ppc = pm.sample_posterior_predictive(trace, random_seed=42)

idata_full = az.from_pymc(trace, posterior_predictive=ppc)

# Visual check: does the model reproduce the observed distribution?
az.plot_ppc(idata_full, data_pairs={"log_quantity": "log_quantity"}, num_pp_samples=200)

# Specific statistics
import numpy as np

y_rep = ppc.posterior_predictive["log_quantity"].values.reshape(-1, len(Y_obs))
print(f"Observed mean: {Y_obs.mean():.3f}")
print(f"Predicted mean: {y_rep.mean():.3f} (95%: {np.percentile(y_rep.mean(axis=1), [2.5, 97.5])})")
print(f"Observed SD:   {Y_obs.std():.3f}")
print(f"Predicted SD:  {y_rep.std(axis=1).mean():.3f}")
```

**What to look for:**
- The distribution of replicated datasets should overlap substantially with observed data
- If the model systematically misses the tails, consider a heavier-tailed likelihood (Student-t instead of Normal)
- If the model misses discrete features (spikes, multi-modality), the model may be misspecified

### Effect Size Reporting

The posterior enables natural probability statements without p-values:

```python
import numpy as np

beta_draws = idata.posterior["beta"].values.flatten()

# Probability of direction
prob_negative = (beta_draws < 0).mean()
print(f"P(beta < 0 | data) = {prob_negative:.3f}")

# Probability of practical significance
threshold = -0.5  # elasticity threshold for meaningful effect
prob_meaningful = (beta_draws < threshold).mean()
print(f"P(beta < {threshold} | data) = {prob_meaningful:.3f}")
```

### Model Comparison via LOO-CV

Use LOO-CV (leave-one-out cross-validation) or WAIC for comparing non-nested models. Prefer LOO-CV — it has better theoretical properties and ArviZ computes it efficiently via Pareto-smoothed importance sampling (PSIS).

```python
import arviz as az

# Compute LOO-CV for each model
# Requires log-likelihood to be stored (use compute_log_likelihood=True in sampling)
loo_m1 = az.loo(idata_model1, pointwise=True)
loo_m2 = az.loo(idata_model2, pointwise=True)

# Compare models
comparison = az.compare({"model1": idata_model1, "model2": idata_model2}, ic="loo")
print(comparison)

# Interpretation:
# - elpd_diff: difference in expected log predictive density (higher is better)
# - se: standard error of the difference
# - If |elpd_diff| / se < 2: models are indistinguishable

# Warning: check Pareto k values
print(loo_m1.pareto_k[loo_m1.pareto_k > 0.7])
# Pareto k > 0.7: that observation is highly influential
# LOO estimate unreliable — use K-fold CV instead
```
