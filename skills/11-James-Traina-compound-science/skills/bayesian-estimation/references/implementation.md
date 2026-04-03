# Bayesian Estimation: Implementation by Framework

Full implementation examples for Stan, PyMC, NumPyro, and brms. Load this reference when setting up a new Bayesian model in any of these frameworks.

---

## Stan (via cmdstanpy in Python)

Stan compiles to efficient C++ and is the gold standard for serious Bayesian structural work.

```stan
// bayesian_iv.stan — Bayesian instrumental variables
data {
  int<lower=0> N;
  vector[N] Y;   // outcome
  vector[N] D;   // endogenous regressor
  vector[N] Z;   // instrument
}
parameters {
  real alpha;            // intercept
  real beta;             // causal effect (structural parameter)
  real gamma;            // first stage: effect of Z on D
  real<lower=0> sigma_y; // outcome noise
  real<lower=0> sigma_d; // first stage noise
}
model {
  // Weakly informative priors
  alpha ~ normal(0, 10);
  beta  ~ normal(0, 2);
  gamma ~ normal(0, 2);
  sigma_y ~ exponential(1);
  sigma_d ~ exponential(1);

  // First stage: D = gamma * Z + error
  D ~ normal(gamma * Z, sigma_d);

  // Structural equation: Y = alpha + beta * D + error
  Y ~ normal(alpha + beta * D, sigma_y);
}
generated quantities {
  // Posterior predictive draws for model checking
  vector[N] Y_rep;
  for (n in 1:N)
    Y_rep[n] = normal_rng(alpha + beta * D[n], sigma_y);
}
```

```python
import cmdstanpy
import numpy as np
import arviz as az

# Compile model (once)
model = cmdstanpy.CmdStanModel(stan_file="bayesian_iv.stan")

# Fit
data_dict = {"N": len(Y), "Y": Y.tolist(), "D": D.tolist(), "Z": Z.tolist()}

fit = model.sample(
    data=data_dict,
    chains=4,
    iter_warmup=1000,
    iter_sampling=2000,
    seed=42,
    show_progress=True
)

# Convert to ArviZ InferenceData for diagnostics
idata = az.from_cmdstanpy(fit)

# Check convergence
print(az.summary(idata, var_names=["alpha", "beta", "gamma"]))
```

**Key Stan code patterns:**
- `transformed parameters` block: compute derived quantities (elasticities from raw parameters) — sampled and stored
- `generated quantities` block: posterior predictive draws, log-likelihood for LOO-CV — computed after sampling
- `<lower=0>` / `<upper=1>` constraints: enforce parameter support without manual transformation

### Non-Centered Parametrization in Stan

```stan
parameters {
  real mu;
  real<lower=0> sigma;
  vector[N_groups] beta_raw;  // N(0,1)
}
transformed parameters {
  vector[N_groups] beta = mu + sigma * beta_raw;  // non-centered transform
}
model {
  mu ~ normal(0, 1);
  sigma ~ exponential(1);
  beta_raw ~ normal(0, 1);
  // likelihood uses beta
}
```

### Cholesky Parametrization for Covariance Matrices in Stan

```stan
parameters {
  cholesky_factor_corr[K] L_corr;   // Cholesky factor of correlation matrix
  vector<lower=0>[K] sigma_vec;      // marginal SDs
}
transformed parameters {
  matrix[K, K] Sigma = diag_matrix(sigma_vec) * L_corr * L_corr'
                       * diag_matrix(sigma_vec);
}
model {
  L_corr ~ lkj_corr_cholesky(2);   // LKJ prior on Cholesky factor
  sigma_vec ~ exponential(1);
}
```

---

## PyMC

PyMC uses PyTensor as its backend, with NUTS as the default sampler. Well-suited for Python-native workflows and hierarchical models.

```python
import pymc as pm
import numpy as np
import arviz as az

with pm.Model() as hierarchical_demand:
    # Hyperpriors (population-level)
    mu_beta = pm.Normal("mu_beta", mu=-1.0, sigma=0.5)   # population mean elasticity
    sigma_beta = pm.HalfNormal("sigma_beta", sigma=0.3)   # cross-market dispersion

    # Market-level elasticities (partial pooling) — non-centered
    n_markets = len(market_ids)
    beta_raw = pm.Normal("beta_raw", mu=0, sigma=1, shape=n_markets)
    beta = pm.Deterministic("beta", mu_beta + sigma_beta * beta_raw)

    # Observation noise
    sigma = pm.HalfNormal("sigma", sigma=1.0)

    # Likelihood
    mu = beta[market_idx] * log_price
    log_quantity = pm.Normal("log_quantity", mu=mu, sigma=sigma, observed=Y_obs)

    # Sample
    trace = pm.sample(
        draws=2000,
        tune=1000,
        chains=4,
        target_accept=0.9,   # raise if divergences appear
        random_seed=42,
        return_inferencedata=True
    )

# Posterior predictive check
with hierarchical_demand:
    ppc = pm.sample_posterior_predictive(trace, random_seed=42)

az.plot_ppc(az.from_pymc(trace, posterior_predictive=ppc))
```

### PyMC Reparametrization Patterns

```python
# WRONG: Centered parametrization (creates funnel geometry)
with pm.Model() as centered:
    mu = pm.Normal("mu", mu=0, sigma=1)
    sigma = pm.HalfNormal("sigma", sigma=1)
    beta = pm.Normal("beta", mu=mu, sigma=sigma, shape=N_groups)  # problematic

# CORRECT: Non-centered parametrization (separates geometry)
with pm.Model() as noncentered:
    mu = pm.Normal("mu", mu=0, sigma=1)
    sigma = pm.HalfNormal("sigma", sigma=1)
    beta_raw = pm.Normal("beta_raw", mu=0, sigma=1, shape=N_groups)
    beta = pm.Deterministic("beta", mu + sigma * beta_raw)

# Log parametrization for positive parameters
log_sigma = pm.Normal("log_sigma", mu=0, sigma=1)
sigma = pm.Deterministic("sigma", pm.math.exp(log_sigma))
```

---

## NumPyro (JAX-based, for large models)

NumPyro runs on JAX, enabling JIT compilation and GPU acceleration. Best for large-scale structural models where PyMC or Stan are too slow.

```python
import numpyro
import numpyro.distributions as dist
from numpyro.infer import MCMC, NUTS
import jax.numpy as jnp
from jax import random

def hierarchical_model(market_idx, log_price, Y_obs=None, n_markets=None):
    # Hyperpriors
    mu_beta = numpyro.sample("mu_beta", dist.Normal(-1.0, 0.5))
    sigma_beta = numpyro.sample("sigma_beta", dist.HalfNormal(0.3))

    # Non-centered parametrization (critical for hierarchical models)
    with numpyro.plate("markets", n_markets):
        beta_raw = numpyro.sample("beta_raw", dist.Normal(0, 1))
    beta = numpyro.deterministic("beta", mu_beta + sigma_beta * beta_raw)

    sigma = numpyro.sample("sigma", dist.HalfNormal(1.0))

    mu = beta[market_idx] * log_price
    numpyro.sample("log_quantity", dist.Normal(mu, sigma), obs=Y_obs)

# Run NUTS
kernel = NUTS(hierarchical_model)
mcmc = MCMC(kernel, num_warmup=1000, num_samples=2000, num_chains=4)
mcmc.run(
    random.PRNGKey(42),
    market_idx=market_idx,
    log_price=log_price,
    Y_obs=Y_obs,
    n_markets=n_markets
)

# Convert to ArviZ
import arviz as az
idata = az.from_numpyro(mcmc)
```

**When to use NumPyro over PyMC:** GPU available, model has large arrays that benefit from JAX vectorization, or you want easy integration with JAX-based structural solvers.

---

## R: brms and rstanarm

For applied researchers working in R, brms provides a formula interface to Stan for hierarchical models, and rstanarm provides pre-compiled Stan programs for common model families.

```r
library(brms)
library(rstanarm)

# brms: Bayesian hierarchical demand model
# Random slopes by market, weakly informative priors
fit_brms <- brm(
  log_quantity ~ log_price + (log_price | market_id),
  data = demand_data,
  family = gaussian(),
  prior = c(
    prior(normal(-1, 0.5), class = b, coef = log_price),
    prior(normal(0, 10),   class = Intercept),
    prior(exponential(1),  class = sd),
    prior(lkj(2),          class = cor)
  ),
  chains = 4,
  iter = 3000,
  warmup = 1000,
  seed = 42,
  cores = 4
)

# Check convergence
summary(fit_brms)          # R-hat, bulk ESS, tail ESS
plot(fit_brms)             # trace plots
pp_check(fit_brms, ndraws = 100)  # posterior predictive check

# rstanarm: simpler for standard models
fit_stan <- stan_lmer(
  log_quantity ~ log_price + (log_price | market_id),
  data = demand_data,
  prior = normal(0, 2.5, autoscale = TRUE),
  seed = 42
)
```

---

## MCMC Algorithm Reference

### Hamiltonian Monte Carlo (HMC) and NUTS

HMC uses gradient information to make large, directed proposals avoiding random walk behavior. NUTS (No-U-Turn Sampler) automatically tunes HMC step size and trajectory length — the default for Stan and NumPyro.

- **When to use:** Continuous, differentiable posteriors — the vast majority of structural and reduced-form models.
- **Requirements:** The log-posterior must be differentiable. Discrete parameters require marginalization or approximation.

### Random Walk Metropolis-Hastings

Simpler but less efficient for high-dimensional posteriors. Acceptance rate should target 20–40%.

- **When to use:** Non-differentiable posteriors, custom likelihood functions that cannot be auto-differentiated, integer-valued parameters.

### Gibbs Sampling

Efficient when full conditional distributions are available in closed form (conjugate priors). Each parameter is updated conditional on all others.

- **When to use:** Bayesian linear regression with conjugate priors, Dirichlet-Multinomial models, latent variable models with data augmentation (probit via Albert-Chib).

### Variational Inference (ADVI)

Approximates the posterior with a simpler parametric family by minimizing KL divergence. Fast but approximate.

- **When to use:** Very large datasets (N > 100,000) where MCMC is too slow, or during model development for fast iteration.
- **Warning:** Typically underestimates posterior variance, especially for correlated parameters. Use for exploration only — not final reported results.
