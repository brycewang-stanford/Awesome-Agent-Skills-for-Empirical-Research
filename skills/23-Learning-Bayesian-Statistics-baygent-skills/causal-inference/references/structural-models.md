# Structural Causal Models

## Contents

- [When to use structural models](#when-to-use-structural-models)
- [pm.do() for interventions](#pmdo-for-interventions)
- [pm.observe() for conditioning](#pmobserve-for-conditioning)
- [Counterfactual queries](#counterfactual-queries)
- [Mediation analysis](#mediation-analysis)
- [Structural vs. quasi-experimental: decision guide](#structural-vs-quasi-experimental-decision-guide)

---

## When to use structural models

Choose a structural causal model (SCM) when:

- You have a full causal theory and want to model mechanisms explicitly
- The problem does not fit a quasi-experimental template (no natural experiment, no discontinuity, no instrument)
- You need **counterfactual queries**: "what would have happened to this specific unit if X had been different?"
- You need to **decompose effects** into direct and indirect paths (mediation)

**Advantage**: flexible, answers counterfactuals, decomposes effects, transparent about assumptions via the DAG.

**Disadvantage**: requires specifying a full structural model — more assumptions, more ways to be wrong. If a quasi-experimental design is available, prefer it; fewer assumptions is better.

---

## pm.do() for interventions

`pm.do()` implements the do-calculus: it cuts incoming edges to the intervened variable, simulating an ideal randomized experiment on the existing model graph.

```python
import pymc as pm
import numpy as np

RANDOM_SEED = sum(map(ord, "causal-structural-v1"))
rng = np.random.default_rng(RANDOM_SEED)

# 1. Define the generative (observational) model
with pm.Model() as scm:
    Z = pm.Normal("Z", mu=0, sigma=1)                    # confounder
    X = pm.Normal("X", mu=0.5 * Z, sigma=0.5)            # treatment (caused by Z)
    Y = pm.Normal("Y", mu=0.3 * X + 0.7 * Z, sigma=0.5) # outcome

# 2. Intervene: set X = 1 (do-calculus)
scm_do_1 = pm.do(scm, {"X": 1})
with scm_do_1:
    idata_do_1 = pm.sample_prior_predictive(samples=2000, random_seed=rng)

# 3. Compare do(X=1) vs do(X=0) for Average Treatment Effect
scm_do_0 = pm.do(scm, {"X": 0})
with scm_do_0:
    idata_do_0 = pm.sample_prior_predictive(samples=2000, random_seed=rng)

ate = idata_do_1.prior["Y"].mean() - idata_do_0.prior["Y"].mean()
print(f"ATE: {ate.values:.3f}")  # Should recover ~0.3 (the direct X -> Y coefficient)
```

**Note**: Using `sample_prior_predictive` gives the ATE under the prior (forward-simulating from structural equations). For posterior-based counterfactuals — using observed data to sharpen estimates — use `pm.observe()` first, then `pm.do()`.

---

## pm.observe() for conditioning

`pm.observe()` conditions the model on observed data, fixing variables to their measured values. This is the standard way to incorporate data into an SCM before doing counterfactual reasoning.

```python
import pymc as pm

# Condition on observed outcome to infer latent variables
scm_obs = pm.observe(scm, {"Y": y_observed})
with scm_obs:
    idata_obs = pm.sample(nuts_sampler="nutpie", random_seed=rng)
```

Use `pm.observe()` when you want to:

- Fit the structural model to data (standard Bayesian inference)
- Perform the **abduction** step of a counterfactual query (see below)
- Infer latent confounders from observed variables

---

## Counterfactual queries

A counterfactual query asks: "What would Y have been for **this specific unit** if X had been different?" This is a unit-level question, not a population average — quasi-experimental methods cannot answer it.

The answer requires the **three-step abduction-action-prediction** procedure:

**Step 1 — Abduction**: condition on the unit's factual observations to infer their latent factors.

**Step 2 — Action**: intervene on the treatment using `pm.do()`.

**Step 3 — Prediction**: forward-simulate the outcome under the counterfactual treatment, using the inferred latent factors from Step 1.

```python
# Step 1: Abduction — infer this unit's latent confounder Z
scm_unit = pm.observe(scm, {"X": x_factual, "Y": y_factual})
with scm_unit:
    idata_abduction = pm.sample(nuts_sampler="nutpie", random_seed=rng)

# Steps 2 & 3: Action + Prediction
# Use the posterior of Z (the inferred latent noise) to forward-simulate Y
# under the counterfactual treatment value
z_posterior = idata_abduction.posterior["Z"]
y_counterfactual = 0.3 * x_counterfactual + 0.7 * z_posterior

print(f"Counterfactual Y mean: {float(y_counterfactual.mean()):.3f}")
```

**Critical assumption**: the structural equations and noise distributions are the same in the factual and counterfactual worlds. If your model is misspecified, counterfactuals inherit that misspecification.

---

## Mediation analysis

Mediation decomposes the total treatment effect into:

- **Total Effect (TE)**: the full effect of T on Y through all paths
- **Natural Direct Effect (NDE)**: the effect of T on Y that does not pass through the mediator M
- **Natural Indirect Effect (NIE)**: the effect of T on Y that operates through M

Additive decomposition: `TE ≈ NDE + NIE`

```python
# Schematic DAG: T -> Y (direct), T -> M -> Y (indirect)
# NDE: intervene do(T=1) but hold M fixed at its value under do(T=0)
# NIE: intervene do(T=0) but let M take its value under do(T=1)
#
# Preferred: use pm.do() to compute interventional distributions for each path.
# Acceptable alternative: Bayesian SEM with chained structural equations, computing
# NDE/NIE from posterior draws of structural coefficients (a * b for indirect, c for direct).
# pm.do() is preferred because it makes the interventional logic explicit and avoids
# manual algebra on coefficients, but both approaches give equivalent results when
# the structural model is correctly specified.

with pm.Model() as mediation_scm:
    T = pm.Bernoulli("T", p=0.5)
    M = pm.Normal("M", mu=0.6 * T, sigma=0.5)       # mediator
    Y = pm.Normal("Y", mu=0.4 * T + 0.5 * M, sigma=0.5)  # outcome

# NDE: fix M to its T=0 distribution, intervene T=1
m_under_t0 = pm.do(mediation_scm, {"T": 0})
# ... sample M under T=0, then use that M in Y equation under T=1
# Full implementation depends on model structure; use pm.do() to block/unblock paths
```

**Strong assumptions for mediation** — make these explicit:

1. No unmeasured T-M confounding
2. No unmeasured M-Y confounding
3. No unmeasured T-Y confounding
4. No effect of T on M-Y confounders

Violation of any of these invalidates the NDE/NIE decomposition. Always communicate these assumptions to the user before reporting mediated effects.

---

## Structural vs. quasi-experimental: decision guide

| Situation | Recommendation |
|-----------|----------------|
| Natural experiment available (policy change, geographic cutoff, lottery) | Quasi-experimental — fewer assumptions |
| Want to estimate mechanisms (how does T affect Y, through which path?) | Structural — can decompose effects via mediation |
| Counterfactual for a specific unit, not a population average | Structural — quasi-experiments give population-level estimates only |
| Limited domain knowledge of the full causal mechanism | Quasi-experimental — avoid specifying a model you cannot defend |
| Complex DAG with multiple mediators and confounders | Structural — can model the full graph explicitly |
| External validity matters (does the effect generalize?) | Structural — can simulate under distribution shifts via pm.do() |
| Speed and robustness are priorities over mechanism | Quasi-experimental — simpler identification assumptions |

When in doubt, ask: "Do I have a credible natural experiment?" If yes, start there. If no, build the SCM and be explicit about every assumption in the DAG.
