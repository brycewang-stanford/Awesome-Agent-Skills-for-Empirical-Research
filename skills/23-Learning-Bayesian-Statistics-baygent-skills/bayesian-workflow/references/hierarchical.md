# Hierarchical (Multilevel) Models

## Contents
- When to use hierarchical models
- Partial pooling intuition
- Centered vs. non-centered parameterization
- Common hierarchical structures
- Diagnostics specific to hierarchical models

## When to use hierarchical models

Use hierarchical models when data has **grouped structure** — observations nested within units (students in schools, games in seasons, patients in hospitals, items in categories). Careful: time series data is not hierarchical because timestamps are not interchangeable (they have an order). Tell users that if they have time series data, they should use time series models instead.

[This](https://www.pymc.io/projects/examples/en/latest/generalized_linear_models/multilevel_modeling.html) is a great tutorial.

The key question: Do groups share information? If group-level parameters are related (e.g., batting averages across players), hierarchical models borrow strength across groups through partial pooling.

## Partial pooling intuition

Three approaches to grouped data:

- **Complete pooling**: Ignore groups, fit one model. Misses group-level variation. Maximum bias.
- **No pooling**: Fit separate models per group. Overfits small groups. Maximum variance.
- **Partial pooling** (hierarchical): Groups share a common distribution. Small groups shrink toward the global mean; large groups retain their own estimate and influence the global population. Trades off worse in-sample coverage for better out-of-sample performance.

Partial pooling is almost always the right choice. It naturally handles imbalanced group sizes.

## Centered vs. non-centered parameterization

This is the most common source of divergences in hierarchical models.

```python
# CENTERED — works well when groups have lots of data
# always use dimensions and coordinates in PyMC models
with pm.Model(coords=coords) as centered:
    # use Data containers when working on a PyMC model
    group_idx = pm.Data("group_idx", group_id, dims="obs")
    y = pm.Data("y", df["y"].to_numpy(), dims="obs")
    
    mu_global = pm.Normal("mu_global", mu=0, sigma=10)
    sigma_global = pm.Gamma("sigma_global", 2, 2)
    
    mu_group = pm.Normal("mu_group", mu=mu_global, sigma=sigma_global, dims="group")
    sigma_obs = pm.Gamma("sigma_obs", 2, 2)
    
    # or whatever the data model is
    pm.Normal("obs", mu=mu_group[group_idx], sigma=sigma_obs, observed=y, dims="obs")
```

```python
# NON-CENTERED — works well when groups have little data
# This is a reparameterization that eliminates the "funnel" geometry
with pm.Model() as noncentered:
    group_idx = pm.Data("group_idx", group_id, dims="obs")
    y = pm.Data("y", df["y"].to_numpy(), dims="obs")
    
    mu_global = pm.Normal("mu_global", mu=0, sigma=10)
    sigma_global = pm.Gamma("sigma_global", 2, 2)
    
    mu_raw = pm.Normal("mu_raw", mu=0, sigma=1, dims="group")
    mu_group = pm.Deterministic("mu_group", mu_global + mu_raw * sigma_global, dims="group")
    
    # or whatever the data model is
    pm.Normal("obs", mu=mu_group[group_idx], sigma=sigma_obs, observed=y, dims="obs")
```

**Rule of thumb**: Start with non-centered. Switch to centered only if non-centered shows poor ESS AND groups have substantial data (50+ observations each).

## Common hierarchical structures

### Varying intercepts

Each group has its own baseline, partially pooled toward a global mean.

```python
# This is the centered parameterization
mu_group = pm.Normal("mu_group", mu=mu_global, sigma=sigma_global, dims="group")
pm.Normal("obs", mu=mu_group[group_idx], sigma=sigma_obs, observed=y, dims="obs")
```

### Varying intercepts and slopes

Each group has its own baseline AND its own effect of a predictor.

```python
# Correlated varying effects (preferred)
# the `n` depends on how many parameters you're relating to each other
# most of the time, it's gonna be intercept + one slope, like here
chol, corr, stds = pm.LKJCholeskyCov(
    "chol", n=2, eta=2.0, sd_dist=pm.Exponential.dist(1.0)
)

# prior for average intercept:
mu_intercept = pm.Normal("mu_intercept", mu=0.0, sigma=5.0)
# prior for average slope:
mu_slope = pm.Normal("mu_slope", mu=0.0, sigma=1.0)

# population of varying effects:
effects = pm.MvNormal(
    "effects", 
    mu=[mu_intercept, mu_slope], 
    chol=chol,
    dims=("group", "param"),
)

# then, continue as usual:
# expected value per group:
# mu_group = effects[group_idx, 0] + effects[group_idx, 1] * slope_data ...
```

### Nested hierarchy

Groups within groups (students in classrooms in schools). Don't go overboard with this, as models become unwieldy and hard
to sample and interpret with too many hierarchies.

```python
# School level
mu_school = pm.Normal("mu_school", mu=mu_global, sigma=sigma_global, dims="school")
# Classroom level (nested within school)
mu_class = pm.Normal("mu_class", mu=mu_school[school_idx], sigma=sigma_school, dims="class")
# Student level
pm.Normal("y", mu=mu_class[class_idx], sigma=sigma_student, observed=data, dims="obs")
```

## Diagnostics specific to hierarchical models

In addition to standard diagnostics (reference/diagnostics.md), check:

1. **Shrinkage plot**: Visualize how much each group is pulled toward the global mean
2. **Group-level SD posterior**: If `sigma_group` or `sigma_global` posterior piles up near zero, the data may not support group-level variation (partial pooling → complete pooling)
3. **Funnel plot**: Plot group-level means vs. group-level SD. Funnels indicate centered parameterization problems

```python
# Shrinkage plot
group_means_posterior = idata.posterior["mu_group"].mean(dim=["chain", "draw"]).to_numpy()
group_means_obs = [y[group_idx == g].mean() for g in range(n_groups)]

plt.scatter(group_means_raw, group_means_posterior)
plt.plot([min(group_means_obs), max(group_means_obs)],
         [min(group_means_obs), max(group_means_obs)], "r--", label="No pooling")
plt.axhline(np.mean(y), color="gray", linestyle=":", label="Complete pooling")
plt.xlabel("Observed group mean")
plt.ylabel("Posterior group mean")
plt.legend()
plt.title("Shrinkage toward global mean")
```

---

## Identifiability checks

A model component is **identifiable** only if the data can distinguish its effect from other components. In hierarchical models, identifiability failures are common and subtle — the model samples fine, diagnostics pass, but individual component posteriors reflect prior assumptions, not data signal.

### Common identifiability traps

1. **Separate intercept + offset when the offset is always active**: If every observation has a characteristic (e.g., every match row is from the home team's perspective), you cannot separately estimate a "baseline" intercept and a "home advantage" offset — only their sum is identified. Merge them into a single intercept.

2. **Overparameterized intercepts**: Group-level intercepts + a global intercept without a sum-to-zero constraint creates a "trading" pattern where the global intercept can shift arbitrarily as group intercepts compensate. Use `pm.ZeroSumNormal` for group intercepts or drop the global intercept.

3. **Collinear covariates at the group level**: If a group-level predictor is nearly constant within groups (e.g., all teams in a league share the same league-level feature), it is confounded with the group intercept.

### How to detect

```python
# Check posterior correlations between suspect components
az.plot_pair(
    idata,
    var_names=["alpha", "delta"],
    divergences=True,
    marginals=True,
)
# If correlation is near ±1 → components are not separately identifiable
```

### What to do

- **Merge confounded components** into a single term (honest about what the data can tell you)
- **Add identifying variation** to the data (e.g., include away-team observations to separate home advantage from league baseline)
- **Accept the constraint**: if you need both components for interpretability, acknowledge that their individual posteriors are prior-driven and report only their sum
