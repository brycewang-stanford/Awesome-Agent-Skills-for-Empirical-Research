# Convergence Diagnostics

## Contents
- Quick diagnostic checklist
- R-hat
- Effective sample size (ESS)
- Divergences
- Trace plots and rank plots
- Energy diagnostics
- Automated diagnostics workflow

## Quick diagnostic checklist

Run this immediately after sampling. If any check fails, do NOT interpret results.

```python
# you just ran this:
# idata = pm.sample(nuts_sampler="nutpie", random_seed=rng)

import arviz_stats as azs

# 1. One-call diagnostics: R-hat, ESS, divergences, tree depth, E-BFMI
# Prints a human-readable summary and returns True if any check failed.
# Defaults already enforce our thresholds (rhat_max=1.01, ess=100*chains, bfmi>=0.3).
has_errors = azs.diagnose(idata)

# 2. If you need the detailed breakdown programmatically:
has_errors, diagnostics = azs.diagnose(idata, return_diagnostics=True, show_diagnostics=False)
# diagnostics contains: "divergent", "treedepth", "bfmi", "ess", "rhat"

# 3. Visual check
az.plot_trace(idata, kind="rank_vlines")
```

If `azs.diagnose` is not available (arviz-stats < 1.0.0), fall back to the manual checks below.

## R-hat

Measures agreement across chains. Uses the rank-normalized split-R-hat (ArviZ default).

| R-hat | Interpretation | Action |
|---|---|---|
| ≤ 1.01 | Chains have converged | Proceed |
| 1.01–1.05 | Possibly not converged | Run longer, investigate |
| > 1.05 | Not converged | Do NOT use results. Diagnose |

**Common causes of high R-hat**:
- Insufficient warmup (increase `tune`)
- Multimodal posterior (reparameterize or use different sampler)
- Model misspecification creating ridges/funnels

## Effective sample size (ESS)

The number of independent-equivalent draws. Two flavors matter:

- **ESS bulk**: Reliability of central tendency estimates (mean, median)
- **ESS tail**: Reliability of tail estimates (credible intervals, quantiles)

| ESS | Interpretation | Action |
|---|---|---|
| ≥ 100 * number of chains per chain | Sufficient for most summaries | Proceed |
| 100-100 * number of chains | Marginal | Run longer or reparameterize |
| < 100 | Unreliable | Diagnose autocorrelation, reparameterize |

**Improving ESS**:
- Increase number of draws
- Reparameterize (non-centered for hierarchical models)
- Reduce posterior correlations
- Increase `target_accept` (trades speed for better exploration)

## Divergences

Divergent transitions indicate the sampler encountered regions of high curvature it could not navigate. Even a few divergences (starting from 10+) can bias results.

```python
# Count divergences
n_div = idata.sample_stats["diverging"].sum().item()

# Visualize where divergences occur
# sometimes, when the model is high dimensional and / or has lots of parameters,
# this plot becomes impossible and you want to check just some pairs of potentially
# problematic parameters (e.g population standard deviation in hierarchical models).
az.plot_pair(idata, var_names=["param1", "param2"], divergences=True)
```

**Fix divergences in this order**:

1. **Increase `target_accept`**: `pm.sample(target_accept=0.95)` — try up to 0.99
2. **Reparameterize**: Non-centered parameterization for hierarchical models:

```python
# CENTERED (can cause funnel divergences)
mu = pm.Normal("mu", mu=0, sigma=sigma_group)

# NON-CENTERED (usually fixes the funnel)
mu_offset = pm.Normal("mu_offset", mu=0, sigma=1)
mu = pm.Deterministic("mu", mu_offset * sigma_group)
```

3. **Stronger priors on scale parameters**: Tight prior on group-level SD can eliminate the funnel, especially avoiding the regions near 0, which don't really mean much in practice anyways (if there is no group-level variation, you don't need to model it!)
4. **Marginalize discrete parameters**: If possible, integrate out discrete variables analytically

## Trace plots and rank plots

```python
# Rank plots (preferred over raw trace plots)
az.plot_trace(idata, kind="rank_vlines")

# What to look for:
# - Rank plots should look uniform (no spikes or gaps)
# - Traces should be "well-mixed" — all chains overlapping
# - No chains stuck in different regions
# - No obvious trends or slow drift
```

## Energy diagnostics

Energy plots detect problems the other diagnostics may miss (e.g., incomplete exploration of the typical set).

```python
az.plot_energy(idata)

# What to look for:
# - Marginal energy and energy transition distributions should overlap
# - Large gap between them indicates poor exploration
```

## Automated diagnostics workflow

The recommended approach is `arviz_stats.diagnose()` (see Quick diagnostic checklist above). It checks R-hat, ESS, divergences, tree depth saturation, and E-BFMI in one call — with sensible defaults that match our thresholds.

For a script-based workflow, use `diagnose_model.py`:

```bash
python scripts/diagnose_model.py --idata model_output.nc
```

Or inline (this last approach doesn't require `arviz_stats.diagnose()`):

```python
def run_diagnostics(idata):
    """Run all convergence diagnostics. Returns dict of results."""
    summary = az.summary(idata)
    num_chains = idata.posterior.sizes["chain"]
    results = {
        "rhat_max": float(summary["r_hat"].max()),
        "rhat_ok": bool((summary["r_hat"] <= 1.01).all()),
        "ess_bulk_min": int(summary["ess_bulk"].min()),
        "ess_tail_min": int(summary["ess_tail"].min()),
        "ess_ok": bool((summary["ess_bulk"] >= 100 * num_chains).all() and (summary["ess_tail"] >= 100 * num_chains).all()),
        "n_divergences": int(idata.sample_stats["diverging"].sum()),
        "divergences_ok": int(idata.sample_stats["diverging"].sum()) == 0,
    }
    results["all_ok"] = results["rhat_ok"] and results["ess_ok"] and results["divergences_ok"]
    return results
```
