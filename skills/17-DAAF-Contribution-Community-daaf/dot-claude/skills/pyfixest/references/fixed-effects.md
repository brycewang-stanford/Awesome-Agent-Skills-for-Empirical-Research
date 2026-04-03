# Fixed Effects and Standard Errors

## Contents

- [Multi-Way Fixed Effects](#multi-way-fixed-effects)
- [Standard Error Types](#standard-error-types)
- [Clustered Standard Errors](#clustered-standard-errors)
- [Wild Cluster Bootstrap](#wild-cluster-bootstrap)
- [HAC Standard Errors](#hac-standard-errors)
- [Causal Cluster Variance](#causal-cluster-variance)
- [Small Sample Corrections](#small-sample-corrections)
- [Backend Options for Performance](#backend-options-for-performance)

## Multi-Way Fixed Effects

### Syntax

```python
import pyfixest as pf

# One-way FE
fit = pf.feols("Y ~ X1 | entity", data=df)

# Two-way FE (entity + time)
fit = pf.feols("Y ~ X1 | entity + year", data=df)

# Three-way FE
fit = pf.feols("Y ~ X1 | entity + year + industry", data=df)

# Interacted FE (entity-by-year pairs)
fit = pf.feols("Y ~ X1 | entity ^ year", data=df)
```

### How FE Demeaning Works

pyfixest absorbs fixed effects via the **Frisch-Waugh-Lovell theorem** using alternating projections (iterative demeaning). This is fast and memory-efficient — it avoids creating dummy variable matrices.

Key parameters controlling demeaning:
- `fixef_tol=1e-08`: Convergence tolerance (decrease for more precision)
- `fixef_maxiter=100000`: Maximum demeaning iterations
- `fixef_rm="singleton"`: Remove singleton FE groups (default since v0.40)

### Extracting Fixed Effects

```python
fit = pf.feols("Y ~ X1 | entity + year", data=df)

# Get estimated fixed effects as a dict of numpy arrays
fe_dict = fit.fixef()
# fe_dict["entity"] → numpy array of entity FE estimates
# fe_dict["year"] → numpy array of year FE estimates
# To inspect: {name: vals[:5] for name, vals in fe_dict.items()}
```

The `fixef()` method returns a **`dict`** mapping FE names to numpy arrays (not a DataFrame). It recovers the absorbed intercepts via the algorithm in Berge (2018). Parameters `atol` and `btol` control recovery precision.

### When to Use Fixed Effects

Fixed effects are appropriate when:
- **Entity FE**: Control for time-invariant unobserved heterogeneity across units (states, firms, individuals)
- **Time FE**: Control for common shocks affecting all units in a period
- **Two-way FE**: Entity + time together for panel data — the standard panel regression specification
- **Interacted FE** (`entity ^ year`): When you need entity-specific time trends or very flexible controls

For methodology guidance on when FE identification is credible, load the `data-scientist` skill's causal inference references.

## Standard Error Types

### Complete Reference Table

| `vcov` Value | Type | When to Use | FE Support | IV Support |
|---|---|---|---|---|
| `"iid"` | Classical (spherical) | Homoskedastic, independent errors | Yes | Yes |
| `"hetero"` / `"HC1"` | HC1 robust | Default for cross-sectional data | Yes | Yes |
| `"HC2"` | HC2 (leverage-adjusted) | Small samples, when leverage matters | No | No |
| `"HC3"` | HC3 (jackknife-like) | Small samples, conservative | No | No |
| `{"CRV1": "var"}` | Cluster-robust (sandwich) | Correlated errors within clusters | Yes | Yes |
| `{"CRV3": "var"}` | Cluster jackknife | Few clusters, conservative | Yes | Yes |
| `{"CRV1": "v1+v2"}` | Two-way clustering | Errors correlated along two dimensions | Yes | Yes |
| `"NW"` | Newey-West HAC | Time series, serial correlation | Yes | Yes |
| `"DK"` | Driscoll-Kraay | Panel, cross-sectional dependence | Yes | Yes |

### Syntax Examples

```python
fit = pf.feols("Y ~ X1 | fe", data=df)

# IID (default)
fit.vcov("iid")

# Heteroskedasticity-robust
fit.vcov("hetero")
fit.vcov("HC1")  # same as "hetero"

# HC2, HC3 (no FE or IV allowed)
fit_no_fe = pf.feols("Y ~ X1", data=df)
fit_no_fe.vcov("HC2")
fit_no_fe.vcov("HC3")
```

## Clustered Standard Errors

### One-Way Clustering

```python
# At estimation time
fit = pf.feols("Y ~ X1 | entity + year", data=df, vcov={"CRV1": "state"})

# Or switch post-estimation
fit = pf.feols("Y ~ X1 | entity + year", data=df)
fit.vcov({"CRV1": "state"})
```

### Two-Way Clustering

```python
# Cluster by state AND year
fit.vcov({"CRV1": "state+year"})
```

Two-way clustering accounts for correlation within states (across years) AND within years (across states).

### CRV3 for Few Clusters

```python
# Jackknife cluster variance — more conservative, appropriate with few clusters
fit.vcov({"CRV3": "state"})
```

CRV3 (cluster jackknife) is more reliable than CRV1 when the number of clusters is small (roughly 10-30). For fewer than ~10-15 clusters, consider wild cluster bootstrap instead (see `advanced-inference.md`).

### Choosing the Cluster Level

**Rule of thumb from Cameron & Miller (2015):** Cluster at the level of treatment assignment. If a policy varies at the state level, cluster at the state level. If treatment is at the individual level in a clustered sample, cluster at the sampling unit level.

When uncertain, clustering at a coarser level is generally conservative (wider CIs).

## Wild Cluster Bootstrap

For models with very few clusters (<20), asymptotic cluster-robust SEs are unreliable. Wild cluster bootstrap provides better finite-sample inference. See `advanced-inference.md` for full syntax, weight type options (Rademacher vs Webb), and guidance on when to use bootstrap vs. CRV3.

## HAC Standard Errors

### Newey-West (Time Series)

```python
fit = pf.feols("Y ~ X1 | entity", data=df,
               vcov="NW",
               vcov_kwargs={"time_id": "year"})
```

### Driscoll-Kraay (Panel with Cross-Sectional Dependence)

```python
fit = pf.feols("Y ~ X1 | entity", data=df,
               vcov="DK",
               vcov_kwargs={"time_id": "year"})
```

Driscoll-Kraay SEs are robust to both serial correlation and cross-sectional dependence, making them appropriate for macro panels where shocks are correlated across units.

## Causal Cluster Variance

Following Abadie, Athey, Imbens, and Wooldridge (2023), CCV provides design-based inference when treatment assignment is clustered and clusters are sampled from a larger population. See `advanced-inference.md` for full CCV syntax, parameters, and when-to-use guidance.

## Small Sample Corrections

The `ssc()` function controls degrees-of-freedom adjustments:

```python
# Default behavior
fit = pf.feols("Y ~ X1 | fe", data=df,
               ssc=pf.ssc(k_adj=True, k_fixef="none", G_adj=True, G_df="min"))

# Match Stata's conventional two-way clustering
fit = pf.feols("Y ~ X1 | fe", data=df,
               vcov={"CRV1": "state+year"},
               ssc=pf.ssc(G_df="conventional"))
```

### `ssc()` Parameters

| Parameter | Default | Meaning |
|-----------|---------|---------|
| `k_adj` | `True` | Apply (N-1)/(N-k) small-sample adjustment |
| `k_fixef` | `"none"` | Count FE in k: `"none"`, `"full"`, or `"nonnested"` |
| `G_adj` | `True` | Apply G/(G-1) cluster adjustment |
| `G_df` | `"min"` | Two-way cluster DOF: `"min"` (conservative) or `"conventional"` |

**v0.40 breaking change:** These parameter names were all renamed. See `gotchas.md` for the mapping.

## Backend Options for Performance

The `demeaner_backend` parameter controls the FE demeaning algorithm:

| Backend | Install | Best For |
|---------|---------|----------|
| `"numba"` | Included by default | CPU, general use — fastest on CPU |
| `"jax"` | `pip install pyfixest[jax]` | GPU acceleration (Nvidia A100+) |
| `"cupy"` | CuPy + CUDA toolkit | GPU via sparse LSMR solver |
| `"scipy"` | Included by default | Fallback if numba fails |
| `"rust-cg"` | Rust extension | Conjugate gradient solver |

```python
# Use JAX backend for GPU acceleration
fit = pf.feols("Y ~ X1 | f1 + f2", data=df, demeaner_backend="jax")

# Use scipy fallback if numba is problematic
fit = pf.feols("Y ~ X1 | f1 + f2", data=df, demeaner_backend="scipy")
```

GPU acceleration targets the iterative alternating-projections demeaning step, which dominates computation time for models with many FE levels. For small datasets (<100K observations) the overhead of GPU transfer may exceed the speedup — numba on CPU is typically fastest.

The `solver` parameter separately controls the linear algebra solver for the regression itself:
- `"scipy.linalg.solve"` (default)
- `"numpy.linalg.solve"`
- `"jax"` (for GPU)

## References and Further Reading

- Berge, L., Butts, K., and McDermott, G. (2026). "Fast and User-Friendly Econometrics Estimations: The R Package fixest." arXiv:2601.21749
- Cameron, A.C. and Miller, D.L. (2015). "A Practitioner's Guide to Cluster-Robust Inference." *Journal of Human Resources*, 50(2), 317-372
- Abadie, A., Athey, S., Imbens, G.W., and Wooldridge, J.M. (2023). "When Should You Adjust Standard Errors for Clustering?" *Quarterly Journal of Economics*, 138(1), 1-35
- MacKinnon, J.G., Nielsen, M.Ø., and Webb, M.D. (2023). "Cluster-Robust Inference: A Guide to Empirical Practice." *Journal of Econometrics*, 232(2), 272-299
- pyfixest documentation — Standard Errors: https://pyfixest.org
