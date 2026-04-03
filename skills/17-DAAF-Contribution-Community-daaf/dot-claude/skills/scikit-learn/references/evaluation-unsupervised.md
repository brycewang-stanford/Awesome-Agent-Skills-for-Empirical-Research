# Evaluation: Unsupervised

Metrics for evaluating cluster quality: internal metrics (silhouette, Davies-Bouldin, Calinski-Harabasz), external metrics (ARI, NMI), and gap statistic implementation. For methodology guidance on validation strategy and reporting requirements, see `exploratory-unsupervised.md` in the `data-scientist` skill.

## Metric Overview

| Metric | Type | Range | Better | Needs Ground Truth? |
|--------|------|-------|--------|---------------------|
| Silhouette Score | Internal | [-1, +1] | Higher | No |
| Davies-Bouldin | Internal | [0, inf) | Lower | No |
| Calinski-Harabasz | Internal | [0, inf) | Higher | No |
| Adjusted Rand Index | External | [-0.5, 1] | Higher | Yes |
| Normalized Mutual Info | External | [0, 1] | Higher | Yes |

## Internal Metrics (No Ground Truth)

### Silhouette Score

Measures how similar each point is to its own cluster versus the nearest neighbor cluster. The most widely used internal metric.

```python
from sklearn.metrics import silhouette_score, silhouette_samples

# --- Overall score ---
sil_avg = silhouette_score(X_scaled, labels)
print(f"Average silhouette score: {sil_avg:.3f}")
# Interpretation: >0.7 strong, >0.5 reasonable, >0.25 weak, <0.25 poor

# --- Per-sample scores (for visualization by cluster) ---
sil_samples = silhouette_samples(X_scaled, labels)

# --- Per-cluster average ---
import numpy as np
for cluster_id in sorted(set(labels)):
    cluster_sils = sil_samples[labels == cluster_id]
    print(f"Cluster {cluster_id}: mean={cluster_sils.mean():.3f}, "
          f"n={len(cluster_sils)}, negative={(cluster_sils < 0).sum()}")
```

### Davies-Bouldin Score

Ratio of within-cluster to between-cluster distances. Lower means better-separated clusters.

```python
from sklearn.metrics import davies_bouldin_score

db = davies_bouldin_score(X_scaled, labels)
print(f"Davies-Bouldin score: {db:.3f}")
# Lower is better; 0 = perfect separation
```

### Calinski-Harabasz Score

Ratio of between-cluster dispersion to within-cluster dispersion (variance ratio criterion). Higher means denser, better-separated clusters.

```python
from sklearn.metrics import calinski_harabasz_score

ch = calinski_harabasz_score(X_scaled, labels)
print(f"Calinski-Harabasz score: {ch:.1f}")
# Higher is better; no absolute threshold
```

### Comparing k Values with Multiple Metrics

```python
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_score, davies_bouldin_score, calinski_harabasz_score

results = []
for k in range(2, 11):
    km = KMeans(n_clusters=k, n_init=10, random_state=42)
    labels = km.fit_predict(X_scaled)
    results.append({
        "k": k,
        "silhouette": silhouette_score(X_scaled, labels),
        "davies_bouldin": davies_bouldin_score(X_scaled, labels),
        "calinski_harabasz": calinski_harabasz_score(X_scaled, labels),
        "inertia": km.inertia_
    })

for r in results:
    print(f"k={r['k']}: sil={r['silhouette']:.3f}, "
          f"db={r['davies_bouldin']:.3f}, ch={r['calinski_harabasz']:.1f}")
```

## External Metrics (With Ground Truth)

### Adjusted Rand Index (ARI)

Measures agreement between two clusterings, corrected for chance. Use when you have known group labels to compare against.

```python
from sklearn.metrics import adjusted_rand_score

ari = adjusted_rand_score(labels_true, labels_pred)
print(f"Adjusted Rand Index: {ari:.3f}")
# 1.0 = perfect match, 0.0 = random, negative = worse than random
```

### Normalized Mutual Information (NMI)

Information-theoretic measure of agreement between two clusterings.

```python
from sklearn.metrics import normalized_mutual_info_score

nmi = normalized_mutual_info_score(labels_true, labels_pred)
print(f"Normalized Mutual Information: {nmi:.3f}")
# 1.0 = perfect match, 0.0 = independent
```

### Other External Metrics

```python
from sklearn.metrics import (
    adjusted_mutual_info_score,
    fowlkes_mallows_score,
    homogeneity_score,
    completeness_score,
    v_measure_score
)

# --- Adjusted Mutual Information ---
ami = adjusted_mutual_info_score(labels_true, labels_pred)

# --- Fowlkes-Mallows (geometric mean of precision and recall) ---
fm = fowlkes_mallows_score(labels_true, labels_pred)

# --- Homogeneity, completeness, V-measure ---
h = homogeneity_score(labels_true, labels_pred)   # Each cluster has one class
c = completeness_score(labels_true, labels_pred)   # Each class in one cluster
v = v_measure_score(labels_true, labels_pred)      # Harmonic mean of h and c
```

## Gap Statistic (Not Built-In)

The gap statistic (Tibshirani et al., 2001) compares within-cluster dispersion to a null reference distribution. It is not included in scikit-learn but can be implemented.

```python
import numpy as np
from sklearn.cluster import KMeans

def gap_statistic(X, k_range, n_references=20, random_state=42):
    """Compute gap statistic for a range of k values."""
    rng = np.random.RandomState(random_state)
    gaps = []
    s_values = []

    for k in k_range:
        # --- Fit on real data ---
        km = KMeans(n_clusters=k, n_init=10, random_state=random_state)
        km.fit(X)
        W_k = km.inertia_

        # --- Fit on reference (uniform random) data ---
        # NOTE: Uses uniform distribution over bounding box. For correlated data,
        # consider PCA-based reference distribution (project data onto principal
        # components, then generate uniform within that space).
        ref_inertias = []
        for _ in range(n_references):
            X_ref = rng.uniform(
                low=X.min(axis=0), high=X.max(axis=0), size=X.shape
            )
            km_ref = KMeans(n_clusters=k, n_init=10, random_state=random_state)
            km_ref.fit(X_ref)
            ref_inertias.append(km_ref.inertia_)

        ref_log = np.log(ref_inertias)
        gap = ref_log.mean() - np.log(W_k)
        s_k = ref_log.std() * np.sqrt(1 + 1.0 / n_references)
        gaps.append(gap)
        s_values.append(s_k)

    return gaps, s_values

# --- Usage ---
k_range = range(1, 11)
gaps, s_vals = gap_statistic(X_scaled, k_range, n_references=25)

# --- Optimal k: smallest k where gap(k) >= gap(k+1) - s(k+1) ---
for i in range(len(gaps) - 1):
    k = list(k_range)[i]
    if gaps[i] >= gaps[i+1] - s_vals[i+1]:
        print(f"Optimal k = {k} (gap criterion)")
        break
```

## Consensus Clustering (Stability Assessment)

Consensus clustering assesses cluster stability via resampling. If clusters are real, they should replicate across subsamples. This is not included in scikit-learn but can be implemented.

> **Note:** The `consensus_matrix` function below is an exception to the "no function definitions" code style rule. A function is used here because the resampling loop is a reusable utility pattern that would be unwieldy as inline code.

```python
# --- Consensus Clustering (Stability Assessment) ---
# INTENT: Assess cluster stability via resampling
# REASONING: If clusters are real, they should replicate across subsamples

import numpy as np
from sklearn.cluster import KMeans
from sklearn.metrics import adjusted_rand_score

def consensus_matrix(X, k, n_resamples=100, subsample_fraction=0.8, random_state=42):
    """Build consensus matrix showing how often pairs co-cluster."""
    n = X.shape[0]
    coassignment = np.zeros((n, n))
    cosampled = np.zeros((n, n))
    rng = np.random.default_rng(random_state)

    for _ in range(n_resamples):
        # Subsample
        idx = rng.choice(n, size=int(n * subsample_fraction), replace=False)
        X_sub = X[idx]

        # Cluster the subsample
        labels_sub = KMeans(n_clusters=k, n_init=10, random_state=rng.integers(1e6)).fit_predict(X_sub)

        # Update co-assignment matrix
        for i_local, i_global in enumerate(idx):
            for j_local, j_global in enumerate(idx):
                cosampled[i_global, j_global] += 1
                if labels_sub[i_local] == labels_sub[j_local]:
                    coassignment[i_global, j_global] += 1

    # Normalize: proportion of times co-clustered when co-sampled
    consensus = np.divide(coassignment, cosampled, where=cosampled > 0, out=np.zeros_like(coassignment))
    return consensus

# Usage
C = consensus_matrix(X_scaled, k=3, n_resamples=100)
# Clean block-diagonal structure in C indicates stable clusters
# Visualize with: plt.imshow(C[np.argsort(labels)][:, np.argsort(labels)], cmap="Blues")
print(f"Consensus matrix shape: {C.shape}")
print(f"Mean consensus (same cluster): {C[labels==0][:, labels==0].mean():.3f}")
```

## Quick Reference

| Task | Function |
|------|----------|
| Overall cluster quality | `silhouette_score(X, labels)` |
| Per-point cluster quality | `silhouette_samples(X, labels)` |
| Cluster separation ratio | `davies_bouldin_score(X, labels)` |
| Variance ratio | `calinski_harabasz_score(X, labels)` |
| Compare to known labels | `adjusted_rand_score(true, pred)` |
| Information overlap | `normalized_mutual_info_score(true, pred)` |
| Formal k selection | Gap statistic (implement manually -- see above) |
