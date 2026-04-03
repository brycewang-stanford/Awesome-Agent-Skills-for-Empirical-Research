# Mixture Models

GaussianMixture and BayesianGaussianMixture for model-based clustering, soft assignments, and principled model selection with BIC/AIC. For methodology guidance (when to prefer GMM over K-means, the classify-analyze problem), see `exploratory-unsupervised.md` in the `data-scientist` skill.

## GaussianMixture

Models data as a mixture of k Gaussian distributions. Each observation gets a posterior probability of belonging to each component (soft assignment).

```python
from sklearn.mixture import GaussianMixture

# --- Fit GMM ---
gmm = GaussianMixture(
    n_components=4,          # Number of mixture components
    covariance_type="full",  # Shape constraint (see table below)
    n_init=5,                # Number of initializations
    max_iter=200,            # Maximum EM iterations
    random_state=42
)
gmm.fit(X_scaled)

# --- Hard assignments (most likely component) ---
labels = gmm.predict(X_scaled)

# --- Soft assignments (posterior probabilities) ---
probs = gmm.predict_proba(X_scaled)  # Shape: (n_samples, n_components)

# --- Model attributes ---
means = gmm.means_               # Component means: (n_components, n_features)
covariances = gmm.covariances_   # Component covariances
weights = gmm.weights_           # Mixing proportions (sum to 1)
```

## Covariance Types

| Type | Shape Constraint | Parameters per Component | When to Use |
|------|-----------------|--------------------------|-------------|
| `full` | Unconstrained (any elliptical shape) | d(d+1)/2 | Default; most flexible |
| `tied` | All components share same covariance | d(d+1)/2 total | Clusters differ in location only |
| `diag` | Axis-aligned ellipses only | d | Moderate flexibility; fewer params |
| `spherical` | Round clusters (equal variance per axis) | 1 | Equivalent to K-means with soft assignment |

Where d = number of features. Start with `full` and let BIC guide simplification.

## Model Selection with BIC/AIC

Fit models across a range of k values AND covariance types. Lower BIC (or AIC) is better.

```python
from sklearn.mixture import GaussianMixture

# --- Compare models ---
results = []
for n in range(2, 9):
    for cov_type in ["full", "tied", "diag", "spherical"]:
        gmm = GaussianMixture(
            n_components=n,
            covariance_type=cov_type,
            n_init=5,
            random_state=42
        )
        gmm.fit(X_scaled)
        results.append({
            "n_components": n,
            "covariance_type": cov_type,
            "bic": gmm.bic(X_scaled),
            "aic": gmm.aic(X_scaled)
        })

# --- Find best model ---
best = min(results, key=lambda r: r["bic"])
print(f"Best: k={best['n_components']}, cov={best['covariance_type']}, BIC={best['bic']:.1f}")
```

### BIC vs AIC

| Criterion | Penalty | Tendency | Recommendation |
|-----------|---------|----------|----------------|
| BIC | log(n) x params | More conservative; favors simpler models | Primary criterion |
| AIC | 2 x params | Less conservative; favors more complex models | Secondary / comparison |

## BayesianGaussianMixture

Bayesian variant that can automatically determine the number of components. Components with near-zero weight are effectively pruned.

```python
from sklearn.mixture import BayesianGaussianMixture

# --- Fit Bayesian GMM ---
bgmm = BayesianGaussianMixture(
    n_components=10,         # Upper bound on components (set high)
    covariance_type="full",
    weight_concentration_prior_type="dirichlet_process",
    weight_concentration_prior=0.1,  # Lower = fewer components favored
    n_init=3,
    random_state=42
)
bgmm.fit(X_scaled)

# --- Effective number of components ---
weights = bgmm.weights_
effective_k = (weights > 0.01).sum()  # Components with meaningful weight
print(f"Effective components: {effective_k}")
print(f"Weights: {weights.round(3)}")

# --- Predict (same interface as GaussianMixture) ---
labels = bgmm.predict(X_scaled)
probs = bgmm.predict_proba(X_scaled)
```

### Weight Concentration Prior

| Value | Effect |
|-------|--------|
| Large (>1) | Encourages many equal-weight components |
| Small (<1) | Encourages few dominant components (sparse) |
| 0.1 - 1.0 | Typical range for exploration |

## Convergence and Diagnostics

```python
# --- Check convergence ---
print(f"Converged: {gmm.converged_}")
print(f"Iterations: {gmm.n_iter_}")

# --- Log-likelihood (higher = better fit) ---
ll = gmm.score(X_scaled)  # Per-sample average log-likelihood
print(f"Avg log-likelihood: {ll:.3f}")

# --- Identify ambiguous assignments ---
probs = gmm.predict_proba(X_scaled)
max_prob = probs.max(axis=1)
n_ambiguous = (max_prob < 0.70).sum()
print(f"Ambiguous assignments (max prob < 0.70): {n_ambiguous}")
```

## GMM vs KMeans Quick Reference

| Feature | GaussianMixture | KMeans |
|---------|----------------|--------|
| Assignment | Probabilistic (posterior) | Hard (nearest centroid) |
| Cluster shape | Elliptical (any covariance) | Spherical only |
| Model selection | BIC/AIC (formal) | Silhouette/elbow (heuristic) |
| Outlier detection | Low max-probability = outlier | Forced into nearest cluster |
| Downstream use | Probabilities reduce classify-analyze bias | Hard labels introduce bias |
| Computation | Slower (EM + covariance) | Faster |
