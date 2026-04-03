---
name: bayesian-estimation
argument-hint: "<model or estimation problem>"
description: >-
  This skill covers Bayesian estimation and inference in quantitative social science. Use when the user is specifying priors, running MCMC, diagnosing chain convergence, or reporting posterior summaries — including hierarchical models, Bayesian structural models, and small-sample settings where priors regularize. Triggers on "Bayesian estimation", "Bayesian inference", "MCMC", "Markov chain Monte Carlo", "Stan", "PyMC", "NumPyro", "prior", "posterior", "credible interval", "Bayesian structural", "Bayesian BLP", "Bayesian DSGE", "hierarchical model", "random effects Bayesian", "posterior predictive check", "Bayes factor", "prior predictive check", "NUTS", "HMC", "Hamiltonian Monte Carlo", "R-hat", "rhat", "effective sample size", "ESS", "Bayesian calibration", "posterior distribution", "prior elicitation", "weakly informative prior", "brms", "rstanarm", "cmdstanpy", "pymc", "arviz".
---

# Bayesian Estimation

Reference for Bayesian estimation in quantitative social science: from prior elicitation to MCMC implementation to posterior reporting. Covers the full workflow of specifying a Bayesian model, running inference, diagnosing convergence, and communicating results — with applications to structural models, hierarchical designs, and small-sample settings.

## When to Use This Skill

Use when the user is:
- Specifying priors and setting up a Bayesian model in Stan, PyMC, NumPyro, brms, or rstanarm
- Running MCMC and diagnosing R-hat, ESS, divergences, or trace plots
- Implementing hierarchical (multilevel) models with partial pooling
- Adding Bayesian inference to a structural model (BLP, dynamic discrete choice, DSGE)
- Reporting credible intervals, posterior predictive checks, or model comparison statistics
- Eliciting priors from calibration targets or literature benchmarks
- Debugging sampling pathologies: divergences, low acceptance rates, poor mixing

Skip when:
- The model is large-N and well-identified (frequentist MLE/GMM is more efficient and faster)
- The task is pure structural estimation without Bayesian components (use `structural-modeling` skill)
- The user needs classical causal inference (use `causal-inference` skill)

## When to Use Bayesian Estimation

### Advantages

**Small samples**: Priors act as regularization. With N < 100 observations and several parameters, MLE can overfit or fail to converge. A weakly informative prior is often equivalent to several additional observations of prior knowledge.

**Hierarchical structure**: When data have natural groupings (markets, countries, firms), Bayesian partial pooling is more efficient than either pooling all groups (ignores variation) or fitting each group separately (ignores shared structure). Random effects Bayesian models borrow strength across groups.

**Uncertainty propagation**: The posterior is a full distribution. Downstream quantities (elasticities, welfare changes, counterfactuals) inherit full uncertainty without a delta method approximation.

**Natural model comparison**: Posterior predictive checks and LOO-CV are cleaner than frequentist test-based model selection, especially for non-nested models.

**Constrained parameters**: Parameters with domain restrictions (discount factors in [0,1], positive variances, simplex probability vectors) are handled naturally via transformed parameter blocks and appropriate priors.

### When to Prefer Frequentist

- Large N (N > 10,000): Priors become irrelevant as the likelihood dominates; MLE or GMM is faster
- Simple models where MLE is efficient (OLS, logit, Poisson): No benefit from Bayesian approach
- Publication venues requiring classical standard errors and p-values (some applied micro journals)
- Models requiring solving equilibrium constraints (NFXP/MPEC) at each draw — computationally prohibitive

### Comparison Table

| Scenario | Bayesian | Frequentist |
|----------|----------|-------------|
| N = 50, 10 parameters | Preferred — priors regularize | MLE may not converge |
| N = 100,000, 5 parameters | Either works; MLE faster | Preferred — priors irrelevant |
| Hierarchical / multi-group | Preferred — partial pooling | Mixed effects via ML is comparable |
| Uncertainty in counterfactuals | Preferred — natural propagation | Delta method or bootstrap |
| Structural model, large state space | Difficult — MCMC over full model | Preferred — NFXP/MPEC more tractable |
| Non-standard likelihood | Either — depends on differentiability | GMM often more flexible |
| Model comparison, non-nested | LOO-CV / WAIC | AIC/BIC, Vuong test |
| Publication: applied micro top-5 | Use sparingly; justify carefully | Standard expectation |

---

## Prior Elicitation

The core task: encode genuine prior knowledge without overwhelming the likelihood.

### Weakly Informative Defaults

These encode vague knowledge — parameters are unlikely to be astronomically large — without strongly influencing the posterior when data are informative. These follow Gelman et al. (2008, 2017) recommendations:

| Parameter type | Recommended prior | Rationale |
|----------------|-------------------|-----------|
| Location / intercept (raw scale) | Normal(0, 10) | Very diffuse; most applications won't have effects > 10 SDs |
| Location (standardized predictors) | Normal(0, 2.5) | Rules out extreme effects; standard for logistic regression |
| Scale / variance | HalfNormal(1) or Exponential(1) | Positive, concentrates near zero but with wide right tail |
| Log-scale parameters (elasticities) | Normal(0, 1) on log scale | Implies elasticity plausibly between 0.14 and 7.4 |
| Correlation matrices | LKJ(2) | Shrinks toward identity; LKJ(1) is uniform on correlations |
| Simplex (probability vectors) | Dirichlet(1, ..., 1) | Uniform over simplex |

### Informative Priors from Calibration Targets

When the literature provides benchmark values, use them as prior means with SD reflecting plausible variation:

1. Use the `methods-explorer` agent to find reference parameter values
2. Set prior mean to the benchmark: e.g., price elasticity of -1.2 from literature
3. Set prior SD to cover the plausible range: if literature range is [-0.5, -2.0], use Normal(-1.2, 0.4) so that the range is roughly within 2 SDs
4. Verify with a prior predictive check that implied observables are plausible

```python
# Example: Informative prior on price elasticity from literature
# Literature: price elasticity typically -0.5 to -2.0 (mean around -1.2)
import pymc as pm

with pm.Model() as demand_model:
    alpha = pm.Normal("alpha", mu=-1.2, sigma=0.4)   # price elasticity
    beta_inc = pm.Normal("beta_inc", mu=0, sigma=1.0) # income elasticity
    sigma = pm.HalfNormal("sigma", sigma=1.0)
```

**Prior predictive decision rules:**
- Prior implies impossible values (negative income, market share > 1) → constrain or use transformed parameter
- Prior predictive range is > 100x observed data range → prior too diffuse; tighten it
- Prior predictive range is narrower than observed variation → prior too tight; loosen it

**Prior sensitivity analysis:** After estimation, refit with prior SD at 0.5x and 2x. If the posterior mean shifts by more than 0.5 SD, the prior is informative — report sensitivity results.

---

## MCMC Quick Reference

Key thresholds for diagnosing MCMC convergence. For full code and detailed guidance, see `references/diagnostics-guide.md`.

| Diagnostic | Good | Borderline | Bad | Action if Bad |
|------------|------|-----------|-----|---------------|
| R-hat | < 1.01 | 1.01–1.05 | >= 1.05 | Run longer chains; reparametrize |
| Bulk ESS | > 400 | 200–400 | < 200 | Increase draws; reduce autocorrelation |
| Tail ESS | > 1000 | 400–1000 | < 400 | Increase draws; focus on scale parameters |
| Divergences | 0 | — | Any | Raise target_accept to 0.9–0.95; non-centered parametrization |
| BFMI | > 0.3 | 0.2–0.3 | < 0.2 | Reparametrize; check prior scales |

**Convergence checklist (run before every reported result):**

- [ ] R-hat < 1.01 for all parameters
- [ ] Bulk ESS > 400 for all parameters
- [ ] Tail ESS > 400 (ideally > 1000 for reported credible intervals)
- [ ] Zero divergences
- [ ] BFMI > 0.2
- [ ] Trace plots show fuzzy caterpillar pattern

```python
import arviz as az
summary = az.summary(idata, var_names=["beta", "sigma"])
# Check: r_hat < 1.01, ess_bulk > 400, ess_tail > 400
divergences = idata.sample_stats["diverging"].values.sum()
assert divergences == 0, f"{divergences} divergences — fix before reporting"
```

For full diagnostic code including trace plots, pair plots, and BFMI computation, see `references/diagnostics-guide.md`.

---

## Implementation Quick Start

A minimal PyMC example for hierarchical demand. For full Stan, PyMC, NumPyro, and brms examples (including Bayesian IV, reparametrization patterns, and Cholesky covariance), see `references/implementation.md`.

```python
import pymc as pm
import arviz as az

with pm.Model() as hierarchical_demand:
    # Hyperpriors
    mu_beta = pm.Normal("mu_beta", mu=-1.0, sigma=0.5)
    sigma_beta = pm.HalfNormal("sigma_beta", sigma=0.3)

    # Non-centered parametrization — always use this for hierarchical models
    beta_raw = pm.Normal("beta_raw", mu=0, sigma=1, shape=n_markets)
    beta = pm.Deterministic("beta", mu_beta + sigma_beta * beta_raw)

    sigma = pm.HalfNormal("sigma", sigma=1.0)
    mu = beta[market_idx] * log_price
    log_quantity = pm.Normal("log_quantity", mu=mu, sigma=sigma, observed=Y_obs)

    trace = pm.sample(
        draws=2000, tune=1000, chains=4,
        target_accept=0.9,  # raise if divergences appear
        random_seed=42, return_inferencedata=True
    )

# Always run diagnostics immediately after sampling
print(az.summary(trace, var_names=["beta", "mu_beta", "sigma_beta"]))
```

**Framework selection guide:**

| Framework | Best for |
|-----------|----------|
| Stan (cmdstanpy) | Complex custom models, structural work, production code |
| PyMC | Python-native workflows, hierarchical models, rapid iteration |
| NumPyro | Large models, GPU acceleration, JAX integration |
| brms / rstanarm | R users, standard hierarchical families, formula interface |

For Bayesian structural models (BLP, dynamic discrete choice, hierarchical DiD) and reparametrization strategies, see `references/structural-models.md`.

---

## Integration with compound-science

**Agents to invoke alongside Bayesian estimation:**

- `numerical-auditor`: Review MCMC convergence diagnostics — R-hat, ESS, divergences. Report format should include all five convergence metrics.
- `econometric-reviewer`: Review prior elicitation strategy, sensitivity analysis, and whether priors are consistent with identification. Use for prior predictive checks and moment-matching to literature targets.
- `methods-explorer`: Find literature calibration targets to set informative prior means. Ask for point estimates and uncertainty ranges, not just means.
- `econometric-reviewer`: Verify that reported posterior means, credible intervals, and model comparison statistics match the actual ArviZ/Stan output.

**Related skills:**

- `structural-modeling`: Frequentist counterpart — NFXP, MPEC, BLP, dynamic discrete choice. Use Bayesian skills on top of the structural model framework when small samples or hierarchical structure warrants it.
- `causal-inference`: For reduced-form causal methods. Bayesian DiD and RD designs follow the same identification logic; the Bayesian layer adds partial pooling and uncertainty propagation.

**Extensions to Bayesian context:**

- `empirical-playbook` skill (`diagnostic-battery.md`): Convergence diagnostics (R-hat, ESS, divergences) are a subset of the full diagnostic battery
- `numerical-auditor` agent: Prior predictive simulation is a special case of the Monte Carlo simulation workflow
- `empirical-playbook` skill (`sensitivity-analysis.md`): Prior sensitivity analysis (vary prior SD 0.5x and 2x) is a natural robustness check for Bayesian models

---

## Common Anti-Patterns

| Anti-Pattern | Problem | Better Approach |
|--------------|---------|-----------------|
| Reporting results without checking R-hat | Non-convergence masquerades as valid posterior | Always run full diagnostic checklist first |
| Using uniform priors (flat priors) | Improper or extremely diffuse; creates pathological geometry in hierarchical models | Use weakly informative priors (Normal(0, 2.5) or HalfNormal(1)) |
| Centered parametrization for hierarchical models | Funnel geometry; divergences and low ESS for scale parameters | Non-centered parametrization always for hierarchical models |
| Using variational inference for final results | Underestimates posterior variance; may miss multimodality | MCMC for final results; VI only for exploration |
| Skipping prior predictive check | Priors may imply scientifically impossible data | Always run prior predictive before fitting |
| Single chain | Cannot compute R-hat; cannot detect non-convergence | Always run 4 chains |
| Treating credible interval as confidence interval | Different interpretation | Report as "90% credible interval" and be precise |
| Bayes factors for model comparison | Extremely sensitive to prior specification; computationally unstable | Use LOO-CV (PSIS-LOO) via ArviZ instead |
| Ignoring Pareto k diagnostics | LOO-CV unreliable for high-k observations | Check `loo.pareto_k > 0.7`; use K-fold CV for problematic observations |
