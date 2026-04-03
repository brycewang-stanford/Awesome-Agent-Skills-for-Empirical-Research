# Clustering

scikit-learn clustering algorithms: KMeans, MiniBatchKMeans, AgglomerativeClustering, DBSCAN, HDBSCAN, SpectralClustering, and OPTICS. For methodology guidance (when to cluster, how to validate, what to report), see `exploratory-unsupervised.md` in the `data-scientist` skill.

## Algorithm Comparison

| Algorithm | Cluster Shape | Finds k? | Handles Noise? | Scalability | Key Parameters |
|-----------|--------------|----------|----------------|-------------|----------------|
| KMeans | Spherical | No (specify k) | No | Large N | `n_clusters`, `n_init` |
| MiniBatchKMeans | Spherical | No | No | Very large N | `n_clusters`, `batch_size` |
| Agglomerative | Flexible (via linkage) | No (specify k or threshold) | No | Small-medium N | `n_clusters`, `linkage` |
| DBSCAN | Arbitrary | Yes (auto) | Yes | Medium-large N | `eps`, `min_samples` |
| HDBSCAN | Arbitrary | Yes (auto) | Yes | Large N | `min_cluster_size` |
| SpectralClustering | Non-convex | No (specify k) | No | Small-medium N | `n_clusters`, `affinity` |
| OPTICS | Arbitrary | Yes (auto) | Yes | Medium N | `min_samples`, `xi` |

## KMeans

The most common clustering algorithm. Partitions data into k spherical clusters by minimizing within-cluster sum of squares.

```python
from sklearn.cluster import KMeans

# --- Fit KMeans ---
kmeans = KMeans(
    n_clusters=4,        # Number of clusters (must specify)
    n_init=10,           # Number of random initializations (use 10+ for stability)
    max_iter=300,        # Maximum iterations per run
    init="k-means++",   # Smart initialization (default, recommended)
    random_state=42      # Reproducibility
)
kmeans.fit(X_scaled)

# --- Extract results ---
labels = kmeans.labels_              # Shape: (n_samples,)
centers = kmeans.cluster_centers_    # Shape: (n_clusters, n_features)
inertia = kmeans.inertia_           # Total within-cluster sum of squares

print(f"Cluster sizes: {np.bincount(labels)}")
print(f"Inertia: {inertia:.1f}")
```

### Elbow Method (Finding k)

```python
from sklearn.cluster import KMeans

inertias = []
K_range = range(2, 11)
for k in K_range:
    km = KMeans(n_clusters=k, n_init=10, random_state=42)
    km.fit(X_scaled)
    inertias.append(km.inertia_)

# Plot inertia vs k — look for "elbow"
for k, inertia in zip(K_range, inertias):
    print(f"k={k}: inertia={inertia:.1f}")
```

## MiniBatchKMeans

Faster variant of KMeans for large datasets. Uses random subsamples (mini-batches) per iteration instead of the full dataset.

```python
from sklearn.cluster import MiniBatchKMeans

# --- Use for large datasets (>100K rows) ---
mbk = MiniBatchKMeans(
    n_clusters=5,
    batch_size=1024,     # Samples per batch (larger = more accurate, slower)
    n_init=10,
    random_state=42
)
mbk.fit(X_scaled)
labels = mbk.labels_
```

## AgglomerativeClustering

Bottom-up hierarchical clustering. Starts with each point as its own cluster and merges iteratively.

```python
from sklearn.cluster import AgglomerativeClustering

# --- Basic usage ---
agg = AgglomerativeClustering(
    n_clusters=4,        # Number of clusters
    linkage="ward",      # Merge criterion (see table below)
    metric="euclidean"   # Distance metric (ward requires euclidean)
)
labels = agg.fit_predict(X_scaled)
```

### Linkage Options

| Linkage | Merges By | Cluster Shape | Notes |
|---------|----------|---------------|-------|
| `ward` | Minimum variance increase | Spherical, equal-size | Default; requires `metric="euclidean"` |
| `complete` | Maximum pairwise distance | Compact | Sensitive to outliers |
| `average` | Average pairwise distance | Moderate | Good balance |
| `single` | Minimum pairwise distance | Elongated / chaining | Can produce very uneven clusters |

### Dendrogram Visualization (via scipy)

```python
from scipy.cluster.hierarchy import dendrogram, linkage

# --- Compute linkage matrix ---
Z = linkage(X_scaled, method="ward")

# --- Plot dendrogram ---
dendrogram(Z, truncate_mode="lastp", p=20)
# Use scipy for the dendrogram; use sklearn for the final cluster labels
```

### Distance Threshold (No Fixed k)

```python
# --- Cut by distance instead of specifying k ---
agg = AgglomerativeClustering(
    n_clusters=None,
    distance_threshold=10.0,  # Cut at this distance
    linkage="ward"
)
labels = agg.fit_predict(X_scaled)
print(f"Found {len(set(labels))} clusters")
```

## DBSCAN

Density-based clustering. Finds clusters as dense regions separated by sparser regions. Automatically determines the number of clusters and identifies noise points.

```python
from sklearn.cluster import DBSCAN

# --- Fit DBSCAN ---
dbscan = DBSCAN(
    eps=0.5,             # Maximum distance between neighbors
    min_samples=5,       # Minimum points to form a dense region
    metric="euclidean"
)
labels = dbscan.fit_predict(X_scaled)

# --- Noise points labeled as -1 ---
n_clusters = len(set(labels)) - (1 if -1 in labels else 0)
n_noise = (labels == -1).sum()
print(f"Clusters: {n_clusters}, Noise points: {n_noise}")
```

### Choosing eps with k-distance Plot

```python
from sklearn.neighbors import NearestNeighbors

# --- Compute k-th nearest neighbor distance for each point ---
nn = NearestNeighbors(n_neighbors=5)
nn.fit(X_scaled)
distances, _ = nn.kneighbors(X_scaled)

# --- Sort the 5th-nearest-neighbor distances ---
k_distances = np.sort(distances[:, 4])
# Plot k_distances — look for "elbow" to set eps
```

## HDBSCAN

Hierarchical DBSCAN. More robust than DBSCAN: handles varying-density clusters and has fewer sensitive parameters.

```python
from sklearn.cluster import HDBSCAN

# --- Fit HDBSCAN ---
hdbscan = HDBSCAN(
    min_cluster_size=15,     # Minimum cluster membership
    min_samples=5,           # Core point density (optional, defaults to min_cluster_size)
    cluster_selection_epsilon=0.0  # Merge clusters closer than this distance
)
labels = hdbscan.fit_predict(X_scaled)

# --- Noise points labeled as -1 ---
n_clusters = len(set(labels)) - (1 if -1 in labels else 0)
print(f"Clusters: {n_clusters}")

# --- Probabilities (soft assignment confidence) ---
probs = hdbscan.probabilities_  # 0-1 confidence for each assignment
```

## SpectralClustering

Graph-based clustering. Builds a similarity graph and partitions it. Effective for non-convex cluster shapes.

```python
from sklearn.cluster import SpectralClustering

# --- Fit SpectralClustering ---
sc = SpectralClustering(
    n_clusters=4,
    affinity="rbf",          # Kernel for similarity ('rbf', 'nearest_neighbors')
    gamma=1.0,               # RBF kernel width (only for affinity='rbf')
    n_neighbors=10,          # Only for affinity='nearest_neighbors'
    random_state=42,
    assign_labels="kmeans"   # Final assignment method ('kmeans' or 'discretize')
)
labels = sc.fit_predict(X_scaled)
```

## OPTICS

Ordering Points To Identify the Clustering Structure. Similar to DBSCAN but handles varying-density clusters and produces a reachability plot.

```python
from sklearn.cluster import OPTICS

# --- Fit OPTICS ---
optics = OPTICS(
    min_samples=5,
    xi=0.05,                 # Steepness threshold for cluster extraction
    min_cluster_size=0.05    # As fraction of total points
)
labels = optics.fit_predict(X_scaled)

# --- Reachability distances (for plotting) ---
reachability = optics.reachability_
ordering = optics.ordering_
```

## Common Patterns

### Comparing Multiple k Values

```python
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_score

results = []
for k in range(2, 11):
    km = KMeans(n_clusters=k, n_init=10, random_state=42)
    labels = km.fit_predict(X_scaled)
    sil = silhouette_score(X_scaled, labels)
    results.append({"k": k, "inertia": km.inertia_, "silhouette": sil})
    print(f"k={k}: silhouette={sil:.3f}, inertia={km.inertia_:.1f}")
```

### Assigning New Data to Existing Clusters

```python
# --- KMeans supports predict on new data ---
new_labels = kmeans.predict(X_new_scaled)

# --- Most other algorithms do NOT support predict ---
# For those, use nearest-centroid or train a classifier on the labels
```

### Cluster Profiling

Cluster profiling describes what each cluster looks like. This is the primary deliverable of any cluster analysis -- the clusters themselves are only useful if you can characterize them.

```python
# --- Cluster Profiling ---
# INTENT: Describe what each cluster looks like using variable means
# REASONING: Profiles are the primary deliverable of any cluster analysis

import polars as pl
import numpy as np

# Assume: df is a Polars DataFrame, labels is the cluster assignment array
df_with_clusters = df.with_columns(pl.Series("cluster", labels))

# Raw means by cluster
cluster_profiles = df_with_clusters.group_by("cluster").agg(
    [pl.col(var).mean().alias(var) for var in clustering_vars]
)
print("Cluster profiles (raw means):")
print(cluster_profiles)

# Standardized means (z-scores relative to full sample)
overall_means = {var: df[var].mean() for var in clustering_vars}
overall_stds = {var: df[var].std() for var in clustering_vars}

cluster_z = cluster_profiles.with_columns([
    ((pl.col(var) - overall_means[var]) / overall_stds[var]).alias(f"{var}_z")
    for var in clustering_vars
])
print("\nCluster profiles (standardized z-scores):")
print(cluster_z.select(["cluster"] + [f"{var}_z" for var in clustering_vars]))

# Cluster sizes
cluster_sizes = df_with_clusters.group_by("cluster").len().rename({"len": "n"})
cluster_sizes = cluster_sizes.with_columns(
    (pl.col("n") / pl.col("n").sum() * 100).round(1).alias("pct")
)
print(f"\nCluster sizes:\n{cluster_sizes}")
```
