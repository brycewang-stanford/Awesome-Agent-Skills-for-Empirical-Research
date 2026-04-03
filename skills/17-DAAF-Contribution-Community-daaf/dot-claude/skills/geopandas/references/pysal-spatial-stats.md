# PySAL Spatial Statistics

Spatial weights, autocorrelation, LISA cluster analysis, spatial regression, and point pattern analysis using the PySAL ecosystem. For methodology and interpretation guidance, see the `data-scientist` skill's `geospatial-analysis.md` and `geospatial-operations.md`.

---

## PySAL Ecosystem Overview

PySAL (Python Spatial Analysis Library) is a federation of packages:

| Package | Purpose | Install |
|---------|---------|---------|
| **libpysal** | Spatial weights, core data structures | `pip install libpysal` |
| **esda** | Exploratory spatial data analysis (Moran's I, LISA, Getis-Ord) | `pip install esda` |
| **spreg** | Spatial regression models | `pip install spreg` |
| **pointpats** | Point pattern analysis | `pip install pointpats` |
| **tobler** | Areal interpolation | `pip install tobler` |
| **mapclassify** | Classification schemes for choropleths | `pip install mapclassify` |
| **spaghetti** | Network-constrained spatial analysis | `pip install spaghetti` |

Install all at once:
```bash
pip install pysal
```

---

## Spatial Weights

Spatial weights formalize the concept of "neighbor" — they define which observations are connected and how strongly. Every spatial statistic depends on this choice.

### Contiguity Weights (Polygons)

```python
from libpysal.weights import Queen, Rook

# Queen: neighbors share an edge or vertex
w = Queen.from_dataframe(gdf)

# Rook: neighbors share an edge only (stricter)
w = Rook.from_dataframe(gdf)

# Inspect
print(w.n)                    # Number of observations
print(w.mean_neighbors)       # Average number of neighbors
print(w.min_neighbors)        # Minimum (watch for islands with 0)
print(w.max_neighbors)        # Maximum
print(w.islands)              # Observations with no neighbors
print(w.histogram)            # Distribution of neighbor counts
```

### Distance-Based Weights (Points or Polygons)

```python
from libpysal.weights import KNN, DistanceBand, Kernel

# K-Nearest Neighbors (every observation gets exactly k neighbors)
w = KNN.from_dataframe(gdf, k=6)

# Distance band (all neighbors within threshold distance)
w = DistanceBand.from_dataframe(gdf, threshold=10000)  # 10 km (projected CRS!)

# Kernel weights (distance-weighted, continuous)
w = Kernel.from_dataframe(gdf, bandwidth=15000)
```

**CRS requirement:** Distance-based weights compute distances between observations. The GeoDataFrame must be in a projected CRS (meters) — geographic CRS (degrees) produces meaningless distances.

### Other Weight Types

```python
from libpysal.weights import block_weights

# Block weights (same group = neighbor)
w = block_weights(gdf["state_fips"])

# Higher-order contiguity (neighbors of neighbors)
from libpysal.weights import higher_order
w2 = higher_order(w, k=2)  # 2nd-order neighbors
```

### Graph API (Newer, Recommended)

libpysal's `Graph` class is the modern interface, backed by pandas/sparse matrices:

```python
from libpysal.graph import Graph

# Contiguity
g = Graph.build_contiguity(gdf.geometry, rook=False)  # Queen (rook=False)
g = Graph.build_contiguity(gdf.geometry, rook=True)    # Rook

# KNN
g = Graph.build_knn(gdf.geometry, k=6)

# Distance band
g = Graph.build_distance_band(gdf.geometry, threshold=10000)

# Kernel
g = Graph.build_kernel(gdf.geometry, kernel="gaussian", k=10)

# Inspect
print(g.n)                  # Number of observations
print(g.n_edges)            # Number of neighbor pairs
print(g.cardinalities)      # Neighbor count per observation
print(g.isolates)           # Observations with no neighbors

# Convert to W for use with esda/spreg
w = g.to_W()

# Spatial lag (weighted average of neighbors' values)
spatial_lag = g.lag(gdf["poverty_rate"])
```

### Row Standardization

Most applications use row-standardized weights (each row sums to 1), so the spatial lag is a weighted average:

```python
# W objects
w.transform = "r"  # Row-standardize

# Graph objects
g_std = g.transform("R")
```

### Saving and Loading Weights

```python
# Save as parquet (Graph API)
g.to_parquet("weights.parquet")
g = Graph.read_parquet("weights.parquet")

# Save as GAL/GWT (legacy W format)
from libpysal.io import open as ps_open
gal = ps_open("weights.gal", "w")
gal.write(w)
gal.close()
```

---

## Global Spatial Autocorrelation

### Moran's I

Tests whether a variable is spatially clustered (positive I), dispersed (negative I), or random (I ≈ 0).

```python
from esda.moran import Moran

# Compute Moran's I
mi = Moran(gdf["poverty_rate"], w, permutations=999)

# Results
print(f"Moran's I: {mi.I:.4f}")
print(f"Expected I: {mi.EI:.4f}")
print(f"p-value (permutation): {mi.p_sim:.4f}")
print(f"p-value (analytical): {mi.p_norm:.4f}")
print(f"z-score: {mi.z_sim:.4f}")
```

### Geary's C

Complementary to Moran's I — more sensitive to local differences:

```python
from esda.geary import Geary

gc = Geary(gdf["poverty_rate"], w, permutations=999)
print(f"Geary's C: {gc.C:.4f}")  # C < 1: positive autocorrelation, C > 1: negative
print(f"p-value: {gc.p_sim:.4f}")
```

### Getis-Ord G

Tests for clustering of high values (hot spots) vs low values (cold spots):

```python
from esda.getisord import G

go = G(gdf["poverty_rate"], w, permutations=999)
print(f"G: {go.G:.4f}")
print(f"p-value: {go.p_sim:.4f}")
```

### Join Count Statistics

For binary variables (e.g., urban/rural, treatment/control), join counts test whether like values cluster:

```python
from esda.join_counts import Join_Counts

# Binary variable (1 = urban, 0 = rural)
jc = Join_Counts(gdf["urban"].values, w, permutations=999)

print(f"BB joins (both 1): {jc.bb}")     # Black-black joins
print(f"WW joins (both 0): {jc.ww}")     # White-white joins
print(f"BW joins (mixed): {jc.bw}")      # Black-white joins
print(f"p-value (BB): {jc.p_sim_bb:.4f}")  # Clustering of 1s
```

---

## Local Spatial Autocorrelation (LISA)

### Local Moran's I

Identifies local clusters and outliers — where spatial autocorrelation is strongest.

```python
from esda.moran import Moran_Local

# Compute LISA
lisa = Moran_Local(gdf["poverty_rate"], w, permutations=999)

# Results per observation
gdf["lisa_I"] = lisa.Is              # Local Moran's I value
gdf["lisa_q"] = lisa.q               # Quadrant (1=HH, 2=LH, 3=LL, 4=HL)
gdf["lisa_p"] = lisa.p_sim           # p-value (permutation)
gdf["lisa_sig"] = lisa.p_sim < 0.05  # Significant at 0.05

# Cluster labels
quadrant_labels = {1: "HH", 2: "LH", 3: "LL", 4: "HL"}
gdf["lisa_cluster"] = gdf["lisa_q"].map(quadrant_labels)
gdf.loc[~gdf["lisa_sig"], "lisa_cluster"] = "Not Significant"
```

### LISA Quadrants

| Quadrant | Code | Meaning | Interpretation |
|----------|------|---------|----------------|
| HH | 1 | High-High | Hot spot: high value surrounded by high values |
| LH | 2 | Low-High | Spatial outlier: low value surrounded by high values |
| LL | 3 | Low-Low | Cold spot: low value surrounded by low values |
| HL | 4 | High-Low | Spatial outlier: high value surrounded by low values |

### LISA Cluster Map

```python
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

# Standard LISA color scheme
lisa_colors = {
    "HH": "#d7191c",          # Red (hot spot)
    "LL": "#2c7bb6",          # Blue (cold spot)
    "HL": "#fdae61",          # Orange (high-low outlier)
    "LH": "#abd9e9",          # Light blue (low-high outlier)
    "Not Significant": "#f0f0f0"  # Light gray
}

fig, ax = plt.subplots(figsize=(12, 8))
gdf.plot(
    color=[lisa_colors[c] for c in gdf["lisa_cluster"]],
    edgecolor="white",
    linewidth=0.3,
    ax=ax
)

# Legend
patches = [mpatches.Patch(color=c, label=l) for l, c in lisa_colors.items() if l != "Not Significant"]
patches.append(mpatches.Patch(color=lisa_colors["Not Significant"], label="Not Significant"))
ax.legend(handles=patches, loc="lower right", fontsize=9)
ax.set_title("LISA Cluster Map: Poverty Rate", fontsize=14)
ax.set_axis_off()
plt.tight_layout()
plt.savefig("lisa_clusters.png", dpi=300, bbox_inches="tight")
```

### Local Getis-Ord Gi*

Identifies statistically significant hot spots and cold spots:

```python
from esda.getisord import G_Local

gi = G_Local(gdf["poverty_rate"], w, permutations=999)

gdf["gi_z"] = gi.Zs                # Z-scores
gdf["gi_p"] = gi.p_sim             # p-values
gdf["hotspot"] = "Not Significant"
gdf.loc[(gi.Zs > 0) & (gi.p_sim < 0.05), "hotspot"] = "Hot Spot"
gdf.loc[(gi.Zs < 0) & (gi.p_sim < 0.05), "hotspot"] = "Cold Spot"
```

---

## Spatial Regression

### OLS with Spatial Diagnostics

spreg's OLS includes Lagrange Multiplier tests that help choose the right spatial model:

```python
import numpy as np
from spreg import OLS

# Prepare arrays
y = gdf[["poverty_rate"]].values           # Dependent variable (n, 1)
X = gdf[["median_income", "pct_rural"]].values  # Independent variables (n, k)

# OLS with spatial diagnostics
ols = OLS(
    y, X, w=w,
    name_y="poverty_rate",
    name_x=["median_income", "pct_rural"],
    name_ds="counties",
    spat_diag=True       # Include LM tests for spatial dependence
)

print(ols.summary)
# Look for:
# - Moran's I on residuals (significant = spatial dependence)
# - LM-lag and LM-error tests → guide model choice
# - Robust LM tests → which specification is preferred
```

### LM Test Decision Rule

```
LM test results from OLS:
├─ LM-lag significant, LM-error not → Spatial Lag Model (SAR)
├─ LM-error significant, LM-lag not → Spatial Error Model (SEM)
├─ Both significant → Check robust versions:
│   ├─ Robust LM-lag significant → SAR
│   ├─ Robust LM-error significant → SEM
│   └─ Both robust significant → Spatial Durbin Model or SAR+SEM combo
└─ Neither significant → OLS is fine, no spatial model needed
```

### Spatial Lag Model (SAR)

The outcome is influenced by neighbors' outcomes (Wy):

```python
from spreg import ML_Lag, GM_Lag

# Maximum Likelihood estimation
sar_ml = ML_Lag(
    y, X, w=w,
    name_y="poverty_rate",
    name_x=["median_income", "pct_rural"],
    name_ds="counties"
)
print(sar_ml.summary)
# Key output: rho (spatial autoregressive coefficient), betas, log-likelihood

# GMM estimation (S2SLS — more robust to misspecification)
sar_gm = GM_Lag(
    y, X, w=w,
    name_y="poverty_rate",
    name_x=["median_income", "pct_rural"]
)
```

### Spatial Error Model (SEM)

Spatial dependence is in the error term (unobserved spatially correlated factors):

```python
from spreg import ML_Error, GM_Error

# Maximum Likelihood
sem_ml = ML_Error(
    y, X, w=w,
    name_y="poverty_rate",
    name_x=["median_income", "pct_rural"],
    name_ds="counties"
)
print(sem_ml.summary)
# Key output: lambda (spatial error coefficient), betas

# GMM (robust to heteroskedasticity)
sem_gm = GM_Error(
    y, X, w=w,
    name_y="poverty_rate",
    name_x=["median_income", "pct_rural"]
)
```

### Spatial Durbin Model

Includes both spatial lag of Y and spatial lags of X (most flexible):

```python
from spreg import ML_Lag

# Spatial Durbin = ML_Lag with slx_lags
sdm = ML_Lag(
    y, X, w=w,
    slx_lags=1,     # Include WX terms
    name_y="poverty_rate",
    name_x=["median_income", "pct_rural"],
    name_ds="counties"
)
print(sdm.summary)
```

### Residual Diagnostics

After fitting a spatial model, verify that residuals no longer exhibit spatial autocorrelation:

```python
from esda.moran import Moran

# Check residuals
mi_resid = Moran(model.u, w, permutations=999)  # model.u = residuals
print(f"Moran's I on residuals: {mi_resid.I:.4f}, p={mi_resid.p_sim:.4f}")
# p > 0.05 indicates spatial dependence has been adequately modeled
```

---

## Point Pattern Analysis

### Centrography (Descriptive Statistics)

```python
from pointpats import centrography

points = np.column_stack([gdf.geometry.x, gdf.geometry.y])

# Mean center
mc = centrography.mean_center(points)

# Weighted mean center
wmc = centrography.weighted_mean_center(points, gdf["enrollment"].values)

# Standard distance (spatial spread)
sd = centrography.std_distance(points)

# Standard deviational ellipse
sx, sy, theta = centrography.ellipse(points)
```

### Quadrat Analysis

Test whether points are uniformly distributed:

```python
from pointpats import QStatistic

q = QStatistic(points, nx=10, ny=10)  # 10x10 grid
print(f"Chi-squared: {q.chi2:.2f}, p-value: {q.chi2_pvalue:.4f}")
# Significant p → points are not uniformly distributed
```

### Kernel Density Estimation (KDE)

```python
import numpy as np
from scipy.stats import gaussian_kde

# Compute KDE
xy = np.vstack([gdf.geometry.x, gdf.geometry.y])
kde = gaussian_kde(xy)

# Evaluate on grid
xmin, ymin, xmax, ymax = gdf.total_bounds
xx, yy = np.mgrid[xmin:xmax:100j, ymin:ymax:100j]
positions = np.vstack([xx.ravel(), yy.ravel()])
density = kde(positions).reshape(xx.shape)

# Plot
import matplotlib.pyplot as plt
fig, ax = plt.subplots(figsize=(10, 8))
ax.contourf(xx, yy, density, cmap="YlOrRd", levels=20)
gdf.plot(ax=ax, color="black", markersize=1, alpha=0.3)
ax.set_title("Point Density (KDE)")
```

### Ripley's Functions

Ripley's functions characterize point patterns at multiple scales — testing whether points are clustered, dispersed, or random at different distances.

```python
from pointpats import PointPattern, Genv, Fenv, Kenv

# Create point pattern from coordinates
pp = PointPattern(np.column_stack([gdf.geometry.x, gdf.geometry.y]))

# Ripley's G (nearest-neighbor distance distribution)
# Tests if points are closer together than expected under randomness
g = Genv(pp, intervals=20, realizations=99)
# g.observed  = observed G function
# g.low, g.high = simulation envelope (under CSR)
# If observed > high → clustering at that distance

# Ripley's F (empty space function)
# Tests if empty spaces are smaller than expected (= clustering)
f = Fenv(pp, intervals=20, realizations=99)

# Ripley's K (cumulative neighbor count by distance)
# Most commonly used; L function = variance-stabilized K
k = Kenv(pp, intervals=20, realizations=99)
```

If the observed function falls outside the simulation envelope, the point pattern deviates significantly from Complete Spatial Randomness (CSR) at that distance. For interpretation guidance, see the `data-scientist` skill's `geospatial-analysis.md`.

---

## Bivariate Spatial Autocorrelation

Test whether the spatial pattern of one variable is related to the spatial pattern of another:

```python
from esda.moran import Moran_BV

# Bivariate Moran's I: is poverty spatially correlated with unemployment?
bv = Moran_BV(
    gdf["poverty_rate"].values,
    gdf["unemployment_rate"].values,
    w,
    permutations=999
)
print(f"Bivariate Moran's I: {bv.I:.4f}, p={bv.p_sim:.4f}")
```

---

## Rate-Adjusted Statistics

When analyzing rates derived from counts (e.g., crime rates, disease rates), use rate-adjusted versions to account for variance instability in small populations:

```python
from esda.moran import Moran_Rate, Moran_Local_Rate

# Rate-adjusted global Moran's I
mr = Moran_Rate(
    gdf["crime_count"].values,    # Event count (numerator)
    gdf["population"].values,      # Population (denominator)
    w,
    permutations=999
)

# Rate-adjusted LISA
mlr = Moran_Local_Rate(
    gdf["crime_count"].values,
    gdf["population"].values,
    w,
    permutations=999
)
```

---

## References and Further Reading

Rey, S.J., Arribas-Bel, D., and Wolf, L.J. (2023). *Geographic Data Science with Python*. CRC Press. https://geographicdata.science/book/
- Ch. 4: Spatial weights
- Ch. 6: Global spatial autocorrelation
- Ch. 7: Local spatial autocorrelation
- Ch. 8: Point pattern analysis
- Ch. 11: Spatial regression
- Ch. 12: Spatial feature engineering

Anselin, L. (1995). "Local Indicators of Spatial Association — LISA." *Geographical Analysis*, 27(2), 93-115.

Anselin, L. and Rey, S.J. (2014). *Modern Spatial Econometrics in Practice*. GeoDa Press.

Rey, S.J. et al. (2022). "The PySAL Ecosystem: Philosophy and Implementation." *Geographical Analysis*, 54(3), 467-487. https://pysal.org/

PySAL API documentation:
- libpysal: https://pysal.org/libpysal/
- esda: https://pysal.org/esda/
- spreg: https://pysal.org/spreg/
- pointpats: https://pysal.org/pointpats/
