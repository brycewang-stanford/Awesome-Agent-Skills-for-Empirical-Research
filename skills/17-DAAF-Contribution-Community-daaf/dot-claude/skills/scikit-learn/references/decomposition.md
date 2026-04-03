# Decomposition

PCA, KernelPCA, TruncatedSVD, NMF, and IncrementalPCA for dimension reduction. For methodology guidance (when to use PCA, how many components to retain, interpreting loadings), see `exploratory-unsupervised.md` in the `data-scientist` skill. For PCA as an index construction tool, see `descriptive-analysis.md`.

## Method Comparison

| Method | Data Type | Linearity | Handles Sparse? | Key Use Case |
|--------|-----------|-----------|-----------------|--------------|
| PCA | Dense, continuous | Linear | No | General dimension reduction |
| KernelPCA | Dense, continuous | Nonlinear | No | Nonlinear structure in data |
| TruncatedSVD | Sparse | Linear | Yes | Text/count data, sparse matrices |
| NMF | Non-negative | Linear | Yes | Parts-based decomposition (topic modeling) |
| IncrementalPCA | Dense, continuous | Linear | No | Large data that doesn't fit in memory |

## PCA

Principal Component Analysis. Projects data onto orthogonal axes of maximum variance.

```python
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler

# --- Standardize first (almost always required for PCA) ---
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# --- Fit PCA with specific number of components ---
pca = PCA(n_components=5, random_state=42)  # random_state only matters when svd_solver="randomized" (auto-selected for large data)
X_reduced = pca.fit_transform(X_scaled)

# --- Inspect results ---
print(f"Components shape: {X_reduced.shape}")
print(f"Variance explained per component: {pca.explained_variance_ratio_}")
print(f"Cumulative variance: {pca.explained_variance_ratio_.cumsum()}")
print(f"Total variance explained: {sum(pca.explained_variance_ratio_):.3f}")
```

### Choosing n_components

```python
# --- Fit full PCA to inspect all components ---
pca_full = PCA(random_state=42)
pca_full.fit(X_scaled)

# --- Variance explained by each component ---
for i, var in enumerate(pca_full.explained_variance_ratio_):
    cumulative = sum(pca_full.explained_variance_ratio_[:i+1])
    print(f"PC{i+1}: {var:.4f} (cumulative: {cumulative:.4f})")

# --- Choose by variance threshold ---
pca_90 = PCA(n_components=0.90)  # Retain 90% of total variance
X_reduced = pca_90.fit_transform(X_scaled)
print(f"Components needed for 90% variance: {pca_90.n_components_}")
```

### Loadings (Component-Variable Relationships)

```python
import pandas as pd

# --- Loadings matrix ---
loadings = pd.DataFrame(
    pca.components_.T,  # Transpose: rows=features, cols=components
    index=feature_names,
    columns=[f"PC{i+1}" for i in range(pca.n_components_)]
)
print(loadings.round(3))

# --- Top contributing features per component ---
for i in range(pca.n_components_):
    top = loadings.iloc[:, i].abs().nlargest(5)
    print(f"\nPC{i+1} top features: {list(top.index)}")
```

### Parallel Analysis (Component Retention)

scikit-learn does not include parallel analysis, but it can be implemented using PCA on random data. This is the gold-standard method for determining how many PCA components to retain.

```python
# --- Parallel Analysis for Component Retention ---
# INTENT: Determine how many PCA components to retain using the gold-standard method
# REASONING: Compare observed eigenvalues to eigenvalues from random data of the same dimensions
# ASSUMES: Data is standardized (parallel analysis should operate on correlation matrix)

import numpy as np
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler

# Standardize
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Observed eigenvalues
pca_full = PCA(n_components=X_scaled.shape[1])
pca_full.fit(X_scaled)
observed_eigenvalues = pca_full.explained_variance_

# Simulated eigenvalues from random data (use 95th percentile, not mean)
n_iterations = 1000
n_samples, n_features = X_scaled.shape
simulated_eigenvalues = np.zeros((n_iterations, n_features))

rng = np.random.default_rng(42)
for i in range(n_iterations):
    random_data = rng.standard_normal((n_samples, n_features))
    pca_random = PCA(n_components=n_features)
    pca_random.fit(random_data)
    simulated_eigenvalues[i] = pca_random.explained_variance_

# 95th percentile threshold (more conservative than mean)
threshold = np.percentile(simulated_eigenvalues, 95, axis=0)

# Retain components where observed > 95th percentile of random
n_components_parallel = np.sum(observed_eigenvalues > threshold)
print(f"Parallel analysis suggests {n_components_parallel} components")

# Visualization
for j in range(min(10, n_features)):
    marker = "***" if observed_eigenvalues[j] > threshold[j] else ""
    print(f"  Component {j+1}: observed={observed_eigenvalues[j]:.3f}  threshold={threshold[j]:.3f} {marker}")
```

For methodology on when and why to use parallel analysis, see `exploratory-unsupervised.md` in the `data-scientist` skill.

## KernelPCA

Nonlinear extension of PCA using kernel functions.

```python
from sklearn.decomposition import KernelPCA

# --- Fit KernelPCA ---
kpca = KernelPCA(
    n_components=2,
    kernel="rbf",        # 'linear', 'poly', 'rbf', 'sigmoid', 'cosine'
    gamma=0.1,           # Kernel coefficient (for rbf, poly, sigmoid)
    random_state=42
)
X_reduced = kpca.fit_transform(X_scaled)
```

## TruncatedSVD

SVD-based dimension reduction that works directly on sparse matrices. Does not center data (unlike PCA), making it suitable for sparse data where centering would destroy sparsity.

```python
from sklearn.decomposition import TruncatedSVD

# --- Use for sparse data (e.g., TF-IDF matrices) ---
svd = TruncatedSVD(
    n_components=50,
    n_iter=10,           # Number of iterations for randomized SVD
    random_state=42
)
X_reduced = svd.fit_transform(X_sparse)

# --- Variance explained ---
print(f"Variance explained: {svd.explained_variance_ratio_.sum():.3f}")
```

## NMF

Non-negative Matrix Factorization. Decomposes data into non-negative components, producing parts-based representations. Useful for topic modeling and count data.

```python
from sklearn.decomposition import NMF

# --- Input must be non-negative ---
nmf = NMF(
    n_components=10,
    init="nndsvda",      # Initialization method
    max_iter=500,
    random_state=42
)
W = nmf.fit_transform(X_nonneg)  # Document-topic matrix
H = nmf.components_              # Topic-term matrix

# --- Reconstruction error ---
print(f"Reconstruction error: {nmf.reconstruction_err_:.3f}")
```

## IncrementalPCA

PCA for datasets too large to fit in memory. Processes data in mini-batches.

```python
from sklearn.decomposition import IncrementalPCA

# --- Fit in batches ---
ipca = IncrementalPCA(n_components=10, batch_size=500)

# --- Option 1: From array (auto-batched) ---
X_reduced = ipca.fit_transform(X_scaled)

# --- Option 2: Manual batching ---
ipca = IncrementalPCA(n_components=10)
for batch in np.array_split(X_scaled, 20):
    ipca.partial_fit(batch)
X_reduced = ipca.transform(X_scaled)
```

## Notes on Related Libraries

- **UMAP**: For nonlinear dimension reduction beyond PCA, see `manifold.md`. UMAP (via `umap-learn`) is the recommended tool for visualization of high-dimensional data.
- **prince**: For correspondence analysis (CA, MCA, FAMD) on categorical or mixed data, use the `prince` library -- not scikit-learn.
- **Factor analysis**: scikit-learn includes `FactorAnalysis` but it is limited. For full EFA/CFA with rotation, consider the `factor_analyzer` library.
