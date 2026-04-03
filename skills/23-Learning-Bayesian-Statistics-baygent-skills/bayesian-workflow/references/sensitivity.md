# Prior/Likelihood Sensitivity Analysis

Power-scaling sensitivity analysis checks whether your posterior conclusions are robust to reasonable changes in prior (or likelihood) strength — without refitting the model. It uses Pareto-smoothed importance sampling (PSIS) to simulate what would happen if you made your priors stronger or weaker.

## Contents
- Requirements
- Running sensitivity checks
- Interpreting results
- Which variables to check
- Visual diagnostics
- Key principle

## Requirements

The InferenceData object must contain both `log_likelihood` and `log_prior` groups.

**Important**: nutpie silently ignores `idata_kwargs={"log_likelihood": True}` and `idata_kwargs={"log_prior": True}`. You must compute these after sampling:

```python
# After pm.sample():
pm.compute_log_likelihood(idata, model=model)
pm.compute_log_prior(idata, model=model)
```

Verify they're present before running sensitivity checks:

```python
assert "log_likelihood" in idata, "Missing log_likelihood — run pm.compute_log_likelihood(idata, model=model)"
assert "log_prior" in idata, "Missing log_prior — run pm.compute_log_prior(idata, model=model)"
```

## Running sensitivity checks

```python
from arviz_stats import psense_summary

summary = psense_summary(idata)
summary
```

This returns a per-variable table with Cumulative Jensen-Shannon (CJS) divergence values for both prior and likelihood perturbations. CJS > 0.05 flags sensitivity (roughly equivalent to a 0.3 standard deviation shift in the posterior mean).

## Interpreting results

Four diagnostic patterns:

| Pattern | Prior CJS | Likelihood CJS | What it means | What to do |
|---------|-----------|----------------|---------------|------------|
| **Low sensitivity** | < 0.05 | < 0.05 | Posterior is robust to prior/likelihood changes | Nothing — this is the ideal outcome |
| **Prior-data conflict** | > 0.05 | > 0.05 | Prior and data pull in different directions | Investigate whether the prior reflects genuine domain knowledge or is just wrong. Consider empirically-scaled priors (e.g., `β ~ Normal(0, 2.5 * sd_y / sd_x)`) |
| **Strong prior / weak likelihood** | > 0.05 | < 0.05 | Prior dominates the posterior | Check if this is intentional (e.g., strong domain constraint). If not, weaken the prior or collect more data |
| **Likelihood-driven** | < 0.05 | > 0.05 | Data dominates the posterior | Usually fine — note in report for transparency |

## Which variables to check

Not every parameter needs sensitivity analysis. Focus on what matters:

- **Check**: interpretable coefficients, effect sizes, predictions, derived quantities (e.g., Bayesian R², contrasts)
- **Skip**: group-specific parameters in hierarchical models (power-scale only the top-level hyperpriors), spline/GP basis coefficients, variance components you don't interpret directly

For hierarchical models, sensitivity of the hyperprior (e.g., the group-level standard deviation) is more informative than sensitivity of individual group effects.

```python
# Check only specific variables
summary = psense_summary(idata, var_names=["beta", "sigma"])
```

## Visual diagnostics

### `plot_psense_dist` — How the posterior shifts

Shows posterior marginals at three power-scaling levels (α = 0.8, 1.0, 1.25). Use this to see the *direction and magnitude* of the shift, not just whether it exceeds the threshold.

```python
from arviz_plots import plot_psense_dist

plot_psense_dist(idata, var_names=["beta"])
```

Requires `arviz-plots` (`pip install arviz-plots`).

### `plot_psense_quantities` — Sensitivity of derived quantities

Shows how predictions or summary statistics shift under perturbation. Use this when you care more about predictive robustness than individual parameter sensitivity.

```python
from arviz_plots import plot_psense_quantities

plot_psense_quantities(idata)
```

## Key principle

**Sensitivity warnings are not automatic problems.** An intentionally informative prior — grounded in domain knowledge or previous studies — will legitimately flag as sensitive. That's expected: if you have a strong prior and modest data, the prior *should* matter.

The correct response to a sensitivity flag is:
1. **Document** the flag and its magnitude
2. **Justify** why the prior is appropriate (or acknowledge it isn't)
3. **Report** the sensitivity transparently — readers should know which conclusions depend on prior choices

Do not reflexively loosen priors to silence diagnostics. A well-justified informative prior that flags sensitivity is better science than a vague prior that passes all checks but encodes no knowledge.
