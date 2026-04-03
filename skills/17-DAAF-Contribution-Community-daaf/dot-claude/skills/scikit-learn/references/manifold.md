# Manifold Learning

t-SNE, UMAP (via umap-learn), Isomap, LocallyLinearEmbedding, MDS, and SpectralEmbedding for nonlinear dimension reduction and visualization. For methodology guidance (interpreting embeddings, parameter sensitivity, visualization-only warnings), see `exploratory-unsupervised.md` in the `data-scientist` skill.

**Key principle:** These methods are primarily **visualization tools**, not analysis tools. Cluster sizes, between-cluster distances, and apparent structure in 2D embeddings should not be interpreted as real properties of the high-dimensional data without formal validation.

## Method Comparison

| Method | Preserves | Speed | Key Parameter | Output Dims |
|--------|-----------|-------|---------------|-------------|
| t-SNE | Local neighborhoods | Slow (>10K rows) | `perplexity` (5-50) | 2-3 only |
| UMAP | Local + some global | Fast | `n_neighbors`, `min_dist` | Any |
| Isomap | Geodesic distances | Moderate | `n_neighbors` | Any |
| LLE | Local linear structure | Moderate | `n_neighbors` | Any |
| MDS | Pairwise distances | Slow | `metric` (True/False) | Any |
| SpectralEmbedding | Graph structure | Moderate | `n_neighbors`, `affinity` | Any |

## t-SNE

t-Distributed Stochastic Neighbor Embedding. Excellent for 2D visualization of high-dimensional data. Preserves local neighborhood structure.

```python
from sklearn.manifold import TSNE

# --- Fit t-SNE ---
tsne = TSNE(
    n_components=2,          # Almost always 2 (or 3)
    perplexity=30,           # Balance local/global structure (5-50)
    n_iter=1000,             # Iterations (increase if not converged)
    learning_rate="auto",    # Auto-scales with dataset size (default in 1.2+)
    init="pca",              # Initialize with PCA (more stable than random)
    random_state=42
)
X_embedded = tsne.fit_transform(X_scaled)

# --- Check convergence ---
print(f"KL divergence: {tsne.kl_divergence_:.4f}")
# Lower is better; if decreasing with more iterations, increase n_iter
```

### Perplexity Sensitivity

Perplexity controls the effective number of nearest neighbors. Different values can produce qualitatively different plots.

```python
# --- Run multiple perplexity values to assess sensitivity ---
for perp in [5, 15, 30, 50]:
    tsne = TSNE(n_components=2, perplexity=perp, random_state=42)
    embedding = tsne.fit_transform(X_scaled)
    print(f"Perplexity {perp}: KL divergence = {tsne.kl_divergence_:.4f}")
    # Compare plots across perplexity values
```

### What t-SNE Cannot Tell You

- Cluster sizes in the plot are not meaningful (algorithm equalizes apparent density)
- Distances between clusters are not meaningful (only within-cluster neighborhoods are preserved)
- Apparent clusters in t-SNE can emerge from random noise at low perplexity
- Different random seeds produce different layouts

## UMAP (via umap-learn)

Uniform Manifold Approximation and Projection. Generally preferred over t-SNE: faster, preserves more global structure, supports arbitrary output dimensions.

```bash
pip install umap-learn
```

```python
import umap

# --- Fit UMAP ---
reducer = umap.UMAP(
    n_components=2,          # Output dimensions (can be >3 for general reduction)
    n_neighbors=15,          # Local neighborhood size (5-50)
    min_dist=0.1,            # Minimum distance between points in embedding (0-1)
    metric="euclidean",      # Distance metric
    random_state=42
)
X_embedded = reducer.fit_transform(X_scaled)

# --- Transform new data (unlike t-SNE, UMAP supports this) ---
X_new_embedded = reducer.transform(X_new_scaled)
```

### Key Parameters

| Parameter | Effect of Increasing | Typical Range |
|-----------|---------------------|---------------|
| `n_neighbors` | More global structure preserved; less fine detail | 5-50 |
| `min_dist` | Points spread out more; less tight clusters | 0.0-1.0 |

### UMAP vs t-SNE

| Feature | UMAP | t-SNE |
|---------|------|-------|
| Speed | Much faster (especially >10K rows) | Slow on large data |
| Global structure | Better preserved | Poor |
| Reproducibility | More stable across runs | Highly variable |
| Transform new data | Yes (`reducer.transform()`) | No (must re-fit) |
| Output dimensions | Any number | Practically limited to 2-3 |
| Implementation | `umap-learn` (separate library) | `sklearn.manifold.TSNE` |

## Isomap

Estimates geodesic distances (shortest path along data manifold) and applies classical MDS.

```python
from sklearn.manifold import Isomap

# --- Fit Isomap ---
isomap = Isomap(
    n_components=2,
    n_neighbors=10           # Size of local neighborhood
)
X_embedded = isomap.fit_transform(X_scaled)

# --- Reconstruction error ---
print(f"Reconstruction error: {isomap.reconstruction_error():.4f}")

# --- Transform new data ---
X_new_embedded = isomap.transform(X_new_scaled)
```

## LocallyLinearEmbedding (LLE)

Preserves local linear relationships between neighbors.

```python
from sklearn.manifold import LocallyLinearEmbedding

# --- Fit LLE ---
lle = LocallyLinearEmbedding(
    n_components=2,
    n_neighbors=10,
    method="standard",       # 'standard', 'modified', 'hessian', 'ltsa'
    random_state=42
)
X_embedded = lle.fit_transform(X_scaled)
```

## MDS

Multidimensional Scaling. Preserves pairwise distances in the low-dimensional embedding.

```python
from sklearn.manifold import MDS

# --- Metric MDS (preserves absolute distances) ---
mds = MDS(
    n_components=2,
    metric=True,             # True = metric MDS, False = non-metric
    n_init=4,                # Number of random initializations
    max_iter=300,
    random_state=42
)
X_embedded = mds.fit_transform(X_scaled)

# --- Stress (lower = better fit) ---
print(f"Stress: {mds.stress_:.2f}")
```

## SpectralEmbedding

Graph-based embedding using the Laplacian eigenvectors of the affinity graph.

```python
from sklearn.manifold import SpectralEmbedding

# --- Fit SpectralEmbedding ---
se = SpectralEmbedding(
    n_components=2,
    affinity="nearest_neighbors",  # or 'rbf'
    n_neighbors=10,
    random_state=42
)
X_embedded = se.fit_transform(X_scaled)
```

## Best Practice: Run Multiple Methods and Parameters

```python
# --- Compare embeddings to assess robustness ---
# If structure appears consistently across methods and parameters,
# it is more likely to reflect genuine data structure.
# If structure changes dramatically, interpret with extreme caution.
```
