---
name: topology-data-analysis
description: "Topological data analysis: persistent homology, Mapper, and TDA tools"
metadata:
  openclaw:
    emoji: "🖇️"
    category: "domains"
    subcategory: "math"
    keywords: ["topology", "persistent-homology", "tda", "mapper", "betti-numbers", "point-cloud"]
    source: "wentor"
---

# Topological Data Analysis

A skill for applying topological data analysis (TDA) methods to research data. Covers persistent homology, Vietoris-Rips complexes, persistence diagrams, the Mapper algorithm, and vectorization methods for integrating topological features into machine learning pipelines.

## Core Concepts

### Simplicial Complexes from Data

TDA extracts topological features (connected components, loops, voids) from data by building simplicial complexes at multiple scales:

| Complex | Construction | Computational Cost |
|---------|-------------|-------------------|
| Vietoris-Rips | Edge if distance < epsilon | O(n^d) for d-simplices |
| Cech | Ball intersection (exact) | Computationally expensive |
| Alpha | Delaunay-based (exact in low dim) | Efficient in R^2, R^3 |
| Cubical | Grid-based (for images) | Linear in pixels |

### Filtration and Persistence

```
Scale epsilon:  0.1    0.3    0.5    0.7    1.0
                |------|------|------|------|------|
Components:      10      6      3      2      1
  (H0 features born at 0, die at merging scale)

Loops:           0      0      1      2      0
  (H1 features born when loop forms, die when filled)
```

A feature that persists across many scales is a genuine topological signal; short-lived features are noise.

## Persistent Homology with Ripser

### Computing Persistence Diagrams

```python
import numpy as np
from ripser import ripser
from persim import plot_diagrams

def compute_persistence(point_cloud: np.ndarray,
                         max_dim: int = 2,
                         max_edge: float = 2.0) -> dict:
    """
    Compute persistent homology of a point cloud.
    point_cloud: (n_points, n_dimensions) array
    max_dim: maximum homology dimension to compute
    max_edge: maximum edge length in Rips complex
    Returns persistence diagrams for each dimension.
    """
    result = ripser(
        point_cloud,
        maxdim=max_dim,
        thresh=max_edge,
    )

    diagrams = result["dgms"]
    summary = {}

    for dim, dgm in enumerate(diagrams):
        # Filter out infinite death times for H0
        finite = dgm[dgm[:, 1] < np.inf] if len(dgm) > 0 else dgm
        lifetimes = finite[:, 1] - finite[:, 0] if len(finite) > 0 else np.array([])

        summary[f"H{dim}"] = {
            "n_features": len(finite),
            "max_persistence": float(lifetimes.max()) if len(lifetimes) > 0 else 0,
            "mean_persistence": float(lifetimes.mean()) if len(lifetimes) > 0 else 0,
            "birth_death_pairs": finite.tolist(),
        }

    return summary

# Example: torus point cloud
def sample_torus(n=1000, R=3.0, r=1.0, noise=0.1):
    """Sample points from a torus in R^3."""
    theta = np.random.uniform(0, 2 * np.pi, n)
    phi = np.random.uniform(0, 2 * np.pi, n)
    x = (R + r * np.cos(phi)) * np.cos(theta) + np.random.normal(0, noise, n)
    y = (R + r * np.cos(phi)) * np.sin(theta) + np.random.normal(0, noise, n)
    z = r * np.sin(phi) + np.random.normal(0, noise, n)
    return np.column_stack([x, y, z])

torus = sample_torus(500)
persistence = compute_persistence(torus, max_dim=2)
# Expected: H0 has 1 long-lived component,
#           H1 has 2 prominent loops (the two fundamental cycles),
#           H2 has 1 prominent void (the cavity)
```

## Persistence Vectorization

### Converting Persistence to Feature Vectors

To use topological features in machine learning, persistence diagrams must be vectorized:

```python
from sklearn.base import BaseEstimator, TransformerMixin

class PersistenceStatistics(BaseEstimator, TransformerMixin):
    """
    Extract statistical features from persistence diagrams.
    Produces a fixed-length feature vector from variable-length diagrams.
    """

    def __init__(self, max_dim: int = 1):
        self.max_dim = max_dim

    def fit(self, X, y=None):
        return self

    def transform(self, diagrams_list: list) -> np.ndarray:
        features = []
        for diagrams in diagrams_list:
            row = []
            for dim in range(self.max_dim + 1):
                dgm = diagrams[dim]
                lifetimes = dgm[:, 1] - dgm[:, 0]
                lifetimes = lifetimes[np.isfinite(lifetimes)]

                if len(lifetimes) == 0:
                    row.extend([0, 0, 0, 0, 0, 0])
                else:
                    row.extend([
                        len(lifetimes),              # count
                        np.sum(lifetimes),            # total persistence
                        np.max(lifetimes),            # max persistence
                        np.mean(lifetimes),           # mean persistence
                        np.std(lifetimes),            # std persistence
                        np.sum(lifetimes ** 2),       # persistence entropy proxy
                    ])
            features.append(row)
        return np.array(features)
```

### Persistence Images

```python
def persistence_image(diagram: np.ndarray, resolution: int = 20,
                       sigma: float = 0.1,
                       weight_fn=None) -> np.ndarray:
    """
    Compute a persistence image from a persistence diagram.
    Transforms birth-death pairs into a stable, fixed-size representation.
    """
    if weight_fn is None:
        weight_fn = lambda birth, persistence: persistence

    # Transform to birth-persistence coordinates
    births = diagram[:, 0]
    persistences = diagram[:, 1] - diagram[:, 0]

    # Create grid
    x_range = np.linspace(births.min() - sigma, births.max() + sigma, resolution)
    y_range = np.linspace(0, persistences.max() + sigma, resolution)
    xx, yy = np.meshgrid(x_range, y_range)

    image = np.zeros((resolution, resolution))

    for b, p in zip(births, persistences):
        if not np.isfinite(p):
            continue
        w = weight_fn(b, p)
        gaussian = w * np.exp(-((xx - b)**2 + (yy - p)**2) / (2 * sigma**2))
        image += gaussian

    return image
```

## The Mapper Algorithm

### Constructing Mapper Graphs

Mapper provides a compressed topological summary of high-dimensional data:

```python
import kmapper as km
from sklearn.cluster import DBSCAN

def run_mapper(data: np.ndarray, lens_fn=None, n_cubes: int = 10,
               overlap: float = 0.3) -> dict:
    """
    Run the Mapper algorithm to produce a simplicial complex
    summarizing the shape of the data.
    data: (n_samples, n_features) array
    lens_fn: filter function (default: first two PCA components)
    """
    mapper = km.KeplerMapper(verbose=0)

    # Compute lens (filter function)
    if lens_fn is None:
        from sklearn.decomposition import PCA
        lens = mapper.fit_transform(data, projection=PCA(n_components=2))
    else:
        lens = lens_fn(data)

    # Build the Mapper graph
    graph = mapper.map(
        lens, data,
        cover=km.Cover(n_cubes=n_cubes, perc_overlap=overlap),
        clusterer=DBSCAN(eps=0.5, min_samples=3),
    )

    # Summary statistics
    n_nodes = len(graph["nodes"])
    n_edges = sum(len(v) for v in graph["links"].values()) // 2

    return {
        "n_nodes": n_nodes,
        "n_edges": n_edges,
        "node_sizes": [len(v) for v in graph["nodes"].values()],
        "graph": graph,
    }
```

### Mapper Parameters

| Parameter | Effect | Guidance |
|-----------|--------|---------|
| Filter function | Projects data to low dimensions | PCA, eccentricity, density |
| Number of intervals | Controls resolution of cover | 10-30 typical |
| Overlap percentage | Controls connectivity | 20-50%, higher = more edges |
| Clustering algorithm | Groups points within intervals | DBSCAN, single-linkage |

## Stability and Statistical Significance

### Bottleneck and Wasserstein Distances

```python
from persim import bottleneck, wasserstein

def compare_persistence_diagrams(dgm1: np.ndarray,
                                   dgm2: np.ndarray) -> dict:
    """
    Compare two persistence diagrams using standard TDA distances.
    """
    bn_dist = bottleneck(dgm1, dgm2)
    ws_dist = wasserstein(dgm1, dgm2, order=2)

    return {
        "bottleneck_distance": round(bn_dist, 6),
        "wasserstein_2_distance": round(ws_dist, 6),
    }
```

### Permutation Test for Topological Features

```python
def permutation_test_persistence(data1: np.ndarray, data2: np.ndarray,
                                   n_permutations: int = 1000,
                                   dim: int = 1) -> dict:
    """
    Test whether two point clouds have significantly different
    topological features using a permutation test on Wasserstein distance.
    """
    from persim import wasserstein

    # Observed distance
    dgm1 = ripser(data1, maxdim=dim)["dgms"][dim]
    dgm2 = ripser(data2, maxdim=dim)["dgms"][dim]
    observed = wasserstein(dgm1, dgm2)

    # Permutation distribution
    combined = np.vstack([data1, data2])
    n1 = len(data1)
    perm_distances = []

    for _ in range(n_permutations):
        perm = np.random.permutation(len(combined))
        perm_d1 = combined[perm[:n1]]
        perm_d2 = combined[perm[n1:]]
        perm_dgm1 = ripser(perm_d1, maxdim=dim)["dgms"][dim]
        perm_dgm2 = ripser(perm_d2, maxdim=dim)["dgms"][dim]
        perm_distances.append(wasserstein(perm_dgm1, perm_dgm2))

    p_value = np.mean(np.array(perm_distances) >= observed)

    return {
        "observed_distance": round(observed, 6),
        "p_value": round(p_value, 4),
        "significant_at_005": p_value < 0.05,
    }
```

## Tools and Libraries

- **Ripser / ripser.py**: Fast Vietoris-Rips persistence computation
- **GUDHI**: Comprehensive TDA library (C++ with Python bindings)
- **persim**: Persistence diagram distances and visualization
- **KeplerMapper**: Python Mapper algorithm implementation
- **giotto-tda**: TDA integrated with scikit-learn API
- **Dionysus 2**: Persistent homology and cohomology
- **scikit-tda**: Meta-package bundling ripser, persim, kepler-mapper, tadasets
