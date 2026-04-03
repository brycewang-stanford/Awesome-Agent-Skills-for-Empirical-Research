# Prior Selection Guide

## Contents
- Philosophy: why priors matter
- Weakly informative priors (the default)
- Prior families by parameter type
- Sparsity priors (high-dimensional regression)
- Prior predictive checking workflow
- Common mistakes

## Philosophy: why priors matter

Priors encode domain knowledge and constrain the model to plausible regions of parameter space. The goal is NOT to be "non-informative" — it is to be **honestly informative** while avoiding undue influence on the posterior when data is sufficient.

Every prior should have a justification. If you cannot articulate why a prior is reasonable, it is not a good prior.

## Weakly informative priors (the default)

When in doubt, use weakly informative priors. These place most mass on plausible values while still allowing the data to dominate.

**Principle**: A good weakly informative prior rules out nonsense values but does not strongly favor any particular reasonable value.

The [PreliZ package](https://preliz.readthedocs.io/en/latest/) is your friend when it comes to choosing priors.

Here are some general rules of thumb:

### Regression coefficients

```python
# if you standardize predictors first -- makes priors comparable
beta = pm.Normal("beta", mu=0, sigma=2.5)  # On standardized scale

# if on raw scale with known range: sigma ≈ expected_range / 4
beta_raw = pm.Normal("beta_raw", mu=0, sigma=(plausible_max - plausible_min) / 4)
```

### Scale parameters (standard deviations)

```python
# Gamma avoiding near-zero values: good default
sigma = pm.Gamma("sigma", alpha=2, beta=2)

# Exponential: when you want to favor smaller values
sigma = pm.Exponential("sigma", lam=1)
```

### Intercepts

```python
# Center on observed data mean when possible
intercept = pm.Normal("intercept", mu=y_mean, sigma=2 * y_std)
```

### Correlation matrices (hierarchical models)

```python
# LKJ: the standard choice. eta=1 is uniform, eta=2 pulls toward identity
chol, corr, stds = pm.LKJCholeskyCov(
    "chol", n=k, eta=2.0, sd_dist=pm.Exponential.dist(1.0)
)
```

## Prior families by parameter type

| Parameter type | Recommended prior | Why |
|---|---|---|
| Location (unbounded) | Normal | Symmetric, well-understood |
| Location (positive) | LogNormal, Gamma | Naturally positive |
| Scale / SD | Gamma, Exponential | Positive, controls spread |
| Proportion (0–1) | Beta | Bounded, flexible shape |
| Correlation matrix | LKJCholesky | Proper prior on correlation structure |
| Count rate | Gamma, LogNormal | Positive, flexible |
| Degrees of freedom (StudentT) | Gamma(2, 0.1) or Exponential(1/30) + shift | Keeps ν reasonable (not too low, not → ∞) |
| Ordinal cutpoints | Normal with ordered transform | Maintains ordering |
| Categorical predictors or Group-level intercepts | ZeroSumNormal | Ensures sum to zero and avoids over-parametrization. Similar to reference-encoding but more appropriate when no obvious placebo/reference category exists |

## Sparsity priors (high-dimensional regression)

When you have many features and expect only a subset to be relevant, use a sparsity-inducing prior instead of a shared Normal. These adaptively shrink irrelevant coefficients toward zero while preserving signal from important ones.

### When to use sparsity priors

| Situation | Prior recommendation |
|-----------|---------------------|
| Few features (< ~10), all plausibly relevant | Normal(0, σ) — sparsity is overkill |
| Many features, expected sparsity | Regularized Horseshoe or R2-D2 |
| Many features, want interpretable R² | R2-D2 |
| Variable selection (hard zeros) | Use BART or kulprit instead — spike-and-slab is rarely worth the complexity in PyMC |

### Regularized Horseshoe (Finnish Horseshoe)

The go-to sparsity prior. Shrinks irrelevant features toward zero ("spike") while allowing strong signals through ("slab"). Always use the **regularized** variant (Piironen & Vehtari, 2017) — the original horseshoe has a double-funnel geometry that causes divergences.

```python
import pytensor.tensor as pt

D = X.shape[1]  # number of features
N = X.shape[0]  # number of observations
p0 = 5  # prior guess for number of relevant features

# Global shrinkage — controls overall sparsity
tau = pm.HalfStudentT("tau", nu=2, sigma=p0 / (D - p0) / np.sqrt(N))

# Local shrinkage — per-feature
lam = pm.HalfStudentT("lam", nu=5, shape=D)

# Slab — regularizes large coefficients (prevents double-funnel)
c2 = pm.InverseGamma("c2", alpha=1, beta=1)

# Effective shrinkage
lam_tilde = pt.sqrt(c2 * lam**2 / (c2 + tau**2 * lam**2))

# Coefficients
beta_raw = pm.Normal("beta_raw", mu=0, sigma=1, shape=D)
beta = pm.Deterministic("beta", beta_raw * tau * lam_tilde, dims="feature")
```

Key hyperparameter: `p0` (expected number of relevant features). This controls the global shrinkage `tau`. Be honest about your prior belief — setting `p0` too high defeats the purpose of sparsity.

**Practical tip**: With horseshoe models, always use `target_accept=0.95` or higher.

**Feature importance with horseshoe**: After fitting, compute `P(|β| > threshold)` per feature to rank practical significance:

```python
beta_samples = idata.posterior["beta"].values  # (chains, draws, D)
threshold = 0.05  # adjust based on scale
prob_relevant = (np.abs(beta_samples) > threshold).mean(axis=(0, 1))
```

### R2-D2 prior

An alternative where you specify prior beliefs about the total R² (variance explained) rather than per-feature shrinkage. More interpretable when you have a prior sense of overall model fit.

```python
import pytensor.tensor as pt  # if not already imported above

# Prior on R² (proportion of variance explained)
R2 = pm.Beta("R2", alpha=1, beta=1)  # uniform on [0, 1] — adjust based on domain

# Concentration parameter controls how R² is distributed across features
# Higher concentration = more uniform; lower = more sparse
phi = pm.Dirichlet("phi", a=np.ones(D), shape=D)

# Coefficient variances derived from R²
sigma2_y = pm.HalfNormal("sigma2_y", sigma=1)  # residual variance
tau2 = R2 / (1 - R2) * sigma2_y * phi

beta = pm.Normal("beta", mu=0, sigma=pt.sqrt(tau2), dims="feature")
```

Use R2-D2 when:
- You have domain knowledge about how much variance the model should explain
- You want a more interpretable parameterization than the horseshoe
- The horseshoe's funnel causes persistent divergences even with regularization

## Prior predictive checking workflow

This is mandatory. Never skip it.

```python
with model:
    prior_pred = pm.sample_prior_predictive()

# Visualize
az.plot_ppc(prior_pred, group="prior", num_pp_samples=100)

# Check: do simulated datasets look plausible?
# - Are values in a reasonable range?
# - Is the spread of outcomes reasonable?
# - Are there impossible values (negative counts, proportions > 1)?
```

**Decision rule**:
- If >10% of prior predictive samples are clearly implausible → tighten priors
- If prior predictions are extremely narrow → priors may be too informative, consider loosening
- If prior predictions are reasonable → proceed to inference

## Common mistakes

1. **Flat / diffuse priors** (e.g., `Normal(0, 1000)`): These are NOT "non-informative". They place excessive mass on extreme, implausible values and can cause sampling issues. Use weakly informative priors instead.

2. **Ignoring scale**: A `Normal(0, 10)` prior means very different things depending on the scale of the data. Always consider the units.

3. **Forgetting to standardize predictors**: Without standardization, coefficients live on different scales, making shared priors inappropriate and slowing sampling. This is not always true, but it is a common mistake.

4. **No prior predictive check**: The single most common source of modeling errors. Always visualize what your priors imply before fitting.

5. **Informative priors without justification**: If you use a tight prior, you need a clear reason (previous study, physical constraint, domain expertise). Document it.
