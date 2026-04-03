# Bayesian Estimation: Structural Models and Reparametrization

Reference for applying Bayesian methods to structural econometric models, including hierarchical demand, dynamic discrete choice, and panel DiD designs. Also covers reparametrization strategies for resolving MCMC pathologies.

---

## Bayesian Structural Models

### Bayesian Hierarchical Demand (Random Coefficients)

In a random coefficients logit model, consumer taste heterogeneity is the random effect. A full Bayesian treatment puts a prior on the distribution of heterogeneity and propagates uncertainty through to demand and welfare predictions.

```python
# Conceptual PyMC structure for a random coefficients demand model
# (simplified — for full BLP, numerical integration over the population
#  distribution is required at each draw)

with pm.Model() as rc_demand:
    # Population distribution of price sensitivity
    mu_alpha = pm.Normal("mu_alpha", mu=-1.0, sigma=0.5)    # mean price sensitivity
    sigma_alpha = pm.HalfNormal("sigma_alpha", sigma=0.3)   # dispersion

    # Consumer-level price sensitivity (N_consumers draws)
    alpha_i = pm.Normal("alpha_i", mu=mu_alpha, sigma=sigma_alpha,
                         shape=N_consumers)

    # Product fixed effects (mean utility)
    delta = pm.Normal("delta", mu=0, sigma=2, shape=N_products)

    # Market shares via softmax over consumer-specific utilities
    # (requires numerical integration / simulation over consumer draws)
```

For serious Bayesian BLP estimation, the dominant approach is to use the BLP contraction mapping to recover mean utilities delta given parameters, then place a Bayesian prior on the random coefficient distribution. This hybrid approach (frequentist inner loop, Bayesian outer loop) is computationally tractable.

### Hierarchical Panel Models (R/brms)

```r
# R: Bayesian hierarchical DiD with brms
library(brms)

# Event study with heterogeneous treatment effects by state
fit_did <- brm(
  outcome ~ time + treated + time:treated + (time:treated | state),
  data = panel_data,
  family = gaussian(),
  prior = c(
    prior(normal(0, 1), class = b),
    prior(normal(0, 10), class = Intercept),
    prior(exponential(1), class = sd),
    prior(lkj(2), class = cor)
  ),
  chains = 4, iter = 3000, warmup = 1000, seed = 42, cores = 4
)

# Partial pooling: state-specific treatment effects borrow strength from the
# population distribution. More stable than fixed effects with small per-state N.
```

### Bayesian Dynamic Discrete Choice

Placing a prior on structural utility parameters and estimating via MCMC through the full Bellman equation is computationally expensive — each MCMC draw requires solving the inner loop. Practical approaches:

1. **Bayesian CCP (Imai, Jain, Ching 2009)**: Update parameters and CCPs jointly via MCMC, avoiding full Bellman solution at each draw. Computationally feasible.

2. **Approximate Bayesian Computation (ABC)**: Simulate from the model at each proposed parameter draw, match to observed data moments. No likelihood evaluation needed — useful for models without closed-form likelihood.

3. **Laplace approximation**: Find the posterior mode (MAP estimate), approximate the posterior as a Gaussian centered at the mode. Cheap but ignores posterior skewness.

```python
# MAP estimation as a fast approximation to the full posterior
import scipy.optimize as opt
import numpy as np

def neg_log_posterior(theta, data, beta, trans_mat, n_states):
    """Negative log posterior = negative log likelihood + negative log prior."""
    # Prior: Normal(0, 2) on both parameters (log scale)
    log_prior = -0.5 * (theta[0]**2 / 4 + theta[1]**2 / 4)
    log_lik = -nfxp_objective(theta, data, beta, trans_mat, n_states)
    return -(log_lik + log_prior)

map_result = opt.minimize(neg_log_posterior, x0=[5.0, 0.01],
                           args=(data, beta, trans_mat, n_states),
                           method='Nelder-Mead')
map_estimate = map_result.x

# Laplace approximation: compute Hessian at MAP
hessian = opt.approx_fprime(map_estimate, lambda t: opt.approx_fprime(
    t, lambda s: -neg_log_posterior(s, data, beta, trans_mat, n_states), 1e-5), 1e-5)
posterior_cov = np.linalg.inv(hessian)
posterior_se = np.sqrt(np.diag(posterior_cov))
```

---

## Reparametrization

Poor posterior geometry is the most common cause of MCMC pathologies (divergences, low ESS, poor mixing). Reparametrization resolves geometry problems without changing the model.

### Non-Centered Parametrization

The most important reparametrization for hierarchical models. Centered parametrization creates a funnel geometry that NUTS cannot navigate efficiently.

```python
# WRONG: Centered parametrization (creates funnel)
with pm.Model() as centered:
    mu = pm.Normal("mu", mu=0, sigma=1)
    sigma = pm.HalfNormal("sigma", sigma=1)
    beta = pm.Normal("beta", mu=mu, sigma=sigma, shape=N_groups)  # problematic

# CORRECT: Non-centered parametrization (separates geometry)
with pm.Model() as noncentered:
    mu = pm.Normal("mu", mu=0, sigma=1)
    sigma = pm.HalfNormal("sigma", sigma=1)
    beta_raw = pm.Normal("beta_raw", mu=0, sigma=1, shape=N_groups)  # N(0,1)
    beta = pm.Deterministic("beta", mu + sigma * beta_raw)            # transform
```

In Stan:

```stan
parameters {
  real mu;
  real<lower=0> sigma;
  vector[N_groups] beta_raw;  // N(0,1)
}
transformed parameters {
  vector[N_groups] beta = mu + sigma * beta_raw;  // non-centered
}
model {
  mu ~ normal(0, 1);
  sigma ~ exponential(1);
  beta_raw ~ normal(0, 1);
  // likelihood uses beta (defined in transformed parameters)
}
```

### Log Parametrization for Positive Parameters

```python
# Instead of: sigma ~ HalfNormal(1) (can create geometry issues near zero)
# Use:
log_sigma = pm.Normal("log_sigma", mu=0, sigma=1)
sigma = pm.Deterministic("sigma", pm.math.exp(log_sigma))
```

### Cholesky Parametrization for Covariance Matrices

Sampling a full covariance matrix directly is inefficient and can violate positive-definiteness. Sample the Cholesky factor instead.

```stan
// Stan: Cholesky factor for multivariate normal
parameters {
  cholesky_factor_corr[K] L_corr;   // Cholesky factor of correlation matrix
  vector<lower=0>[K] sigma_vec;      // marginal SDs
}
transformed parameters {
  matrix[K, K] Sigma = diag_matrix(sigma_vec) * L_corr * L_corr'
                       * diag_matrix(sigma_vec);  // covariance matrix
}
model {
  L_corr ~ lkj_corr_cholesky(2);   // LKJ prior on Cholesky factor
  sigma_vec ~ exponential(1);
}
```

### Geometry Problem Reference

| Symptom | Cause | Fix |
|---------|-------|-----|
| Divergences in hierarchical model | Funnel geometry (centered parametrization) | Non-centered parametrization |
| Low ESS for scale parameters | Near-zero scale posterior (sigma → 0) | Log parametrization of sigma |
| Divergences with covariance matrices | Ill-conditioned matrix near boundary | Cholesky parametrization, LKJ(2) prior |
| Slow mixing for correlated parameters | High posterior correlation | Reparametrize to decorrelate (PCA rotation) |
| BFMI < 0.2 with no divergences | Global geometry issue | Increase target_accept, check prior scale |
