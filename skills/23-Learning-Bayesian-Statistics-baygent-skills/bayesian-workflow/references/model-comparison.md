# Model Comparison

## Contents
- When to compare models
- LOO-CV comparison
- Stacking weights
- WAIC (and when to prefer LOO)
- Reporting comparisons

## When to compare models

Compare models when you have genuinely different modeling assumptions — not for variable selection. Bayesian model comparison answers: "Which model predicts unseen data better?" LOO-CV works across different data models — they do not need to share the same observation distribution (see [CV-FAQ](https://users.aalto.fi/~ave/CV-FAQ.html#differentmodels)).

For variable selection, use a [BART model](https://github.com/pymc-devs/pymc-bart), or the [kulprit package](https://github.com/bambinos/kulprit).

Common comparison scenarios:
- Linear vs. nonlinear trend
- Different hierarchical structures (varying intercepts vs. varying slopes)
- Different covariate sets guided by domain knowledge

## LOO-CV comparison

The primary comparison tool. Uses PSIS-LOO via ArviZ.

```python
# Fit multiple models, store InferenceData for each
models = {"m1": idata_1, "m2": idata_2, "m3": idata_3}

# you need to store the pointwise log-likelihood in the InferenceData for each model,
# either upstream with `idata_kwargs={"log_likelihood": True}` when sampling,
# or downstream with:
with m1:
    pm.compute_log_likelihood(idata_1)
with m2:
    pm.compute_log_likelihood(idata_2)
with m3:
    pm.compute_log_likelihood(idata_3)

# Compare
comparison = az.compare(models)
print(comparison)

# Visualize
az.plot_compare(comparison)
```

**Reading the comparison table**:
- `elpd_loo`: Higher is better (less negative = better predictive accuracy)
- `se`: Standard error of ELPD estimate
- `elpd_diff`: Difference from best model
- `dse`: Standard error of the difference
- `weight`: Stacking weight (see below)
- `warning`: True if high Pareto k values exist

**Interpreting differences**:
- If `elpd_diff` < 2×`dse` → Models are practically indistinguishable. Prefer the simpler one.
- If `elpd_diff` > 4×`dse` → Strong evidence for the better model.
- Between 2–4×`dse` → Moderate evidence. Consider domain knowledge.

## Stacking weights

When no single model is clearly best, use Bayesian stacking to combine predictions:

```python
comparison = az.compare(models, method="stacking")
# The 'weight' column gives optimal combination weights
```

Stacking weights minimize expected log predictive density loss. They often outperform selecting a single best model.
Report stacking weights alongside ELPD differences — they give a more nuanced picture.

## WAIC (and when to prefer LOO)

WAIC (Widely Applicable Information Criterion) is asymptotically equivalent to LOO but less robust in practice.

```python
waic = az.waic(idata)
```

**Prefer LOO over WAIC** in most cases because:
- LOO provides the Pareto k diagnostic (you know when to trust it)
- WAIC can silently give unreliable results with no warning
- LOO is better calibrated for small samples

Use WAIC only when LOO is computationally infeasible (very rare with PSIS-LOO).

## Reporting comparisons

When reporting model comparisons, always include:

1. Table of ELPD values with standard errors
2. ELPD differences with their standard errors
3. Stacking weights
4. Note any high Pareto k warnings, what they mean, and what to do about it
5. The substantive interpretation — what does the better model imply about the phenomenon? Be careful to NOT make causal claims based on model comparison -- it only tells us about predictive accuracy.

Template:

```markdown
## Model comparison

| Model | ELPD (LOO) | SE | ΔELPD | ΔSE | Weight |
|-------|------------|-----|-------|------|--------|
| Model 1 | -234.5 | 12.3 | 0.0 | — | 0.72 |
| Model 2 | -241.2 | 11.8 | -6.7 | 3.1 | 0.28 |

Model 1 is slightly preferred by LOO (ΔELPD = 6.7, ~2.2× the SE of the difference),
suggesting moderate evidence. Consider domain knowledge to choose one model, 
or use stacking weights to combine predictions.
No observations had Pareto k > 0.7.
```
