# Geospatial Analysis Methodology

Conceptual foundations for spatial analysis — when to use spatial methods, how to think about geographic data, and how to interpret spatial results. This guide is code-agnostic; load the `geopandas` skill for implementation syntax and the PySAL ecosystem for spatial statistics.

## Acknowledgments

These materials draw extensively from several open-access resources that the authors have generously made available to the research community:

- **Rey, Arribas-Bel, and Wolf** — *Geographic Data Science with Python* (2023), the primary reference for spatial autocorrelation, LISA, point pattern analysis, and spatial regression methodology
- **Dorman, Graser, Nowosad, and Lovelace** — *Geocomputation with Python* (2025), the primary reference for spatial data models, CRS/projections, raster operations, and map design
- **Tenkanen, Heikinheimo, and Whipp** — *Introduction to Python for Geographic Data Analysis* (forthcoming), covering spatial interpolation, network analysis, and web data acquisition workflows

Where methodology draws from a specific source, it is attributed inline. Concepts that are foundational to the discipline (e.g., Tobler's First Law, the MAUP) are attributed to their original authors.

---

## Spatial Thinking for Data Scientists

### Tobler's First Law of Geography

> "Everything is related to everything else, but near things are more related than distant things." — Waldo Tobler (1970)

This is not just a platitude — it has testable statistical implications. If Tobler's Law holds for a variable, that variable exhibits **spatial autocorrelation**: its values are not independent across space. This matters because:

1. **Standard statistical methods assume independence.** If observations are spatially correlated, OLS standard errors are biased (typically too small), confidence intervals are too narrow, and p-values are too optimistic.
2. **Spatial context is informative.** A location's neighbors carry predictive information about it. Ignoring this throws away signal.
3. **Spatial patterns may reveal causal processes.** Clustering of outcomes may indicate shared exposures, diffusion processes, or common unobserved factors.

### Three Ways to Represent Spatial Reality

Every geographic phenomenon fits one of three conceptual models (Rey et al. 2023, Ch. 1):

| Model | What It Represents | Examples | Typical Computation |
|-------|-------------------|----------|-------------------|
| **Objects** | Discrete entities with specific locations and boundaries | Schools, counties, roads, census tracts | Geographic tables (GeoDataFrames) |
| **Fields** | Continuous surfaces theoretically measurable everywhere | Temperature, elevation, pollution, population density | Raster grids, data cubes |
| **Networks** | Connected systems where topology determines relationships | Road networks, rivers, transit systems, social networks with spatial embedding | Spatial graphs (see scope note below) |

The traditional GIS mapping of objects→vectors and fields→rasters is convention, not law. Conceptual model and computational structure can be decoupled — a population density field can be represented as vector polygons (choropleth) or a raster grid (density surface), depending on the analytical purpose.

> **Scope note on networks:** Network analysis (shortest path, service area, network-constrained clustering) is a specialized domain that requires dedicated graph data structures and algorithms beyond what the standard geospatial stack provides. This guide covers object and field representations; for network analysis, consult specialized resources such as OSMnx for street networks or NetworkX/igraph for general spatial graphs. The PySAL ecosystem's `spaghetti` module handles network-constrained point patterns.

### When Spatial Analysis Matters vs. When Standard Methods Suffice

```
Does my research question involve space?
├─ Question is inherently about space/place/location
│   └─ Spatial methods are essential
│      Examples: "Where are schools concentrated?"
│                "Do poverty rates cluster geographically?"
│                "How does distance to amenities affect outcomes?"
├─ Geography is a potential confounder
│   └─ Use spatial fixed effects or spatial controls
│      Examples: "Does class size affect test scores?" (but urban/rural differs)
│                "Does pollution affect health?" (but neighborhoods self-select)
├─ Observations may be spatially correlated
│   └─ At minimum, adjust inference
│      Options: cluster standard errors by geography,
│               use spatial standard errors (Conley),
│               test residuals for spatial autocorrelation
└─ No spatial dimension relevant
    └─ Standard methods suffice — no spatial tools needed
```

**Reference:** Rey et al. (2023) Ch. 1

---

## The Modifiable Areal Unit Problem (MAUP)

Results can change dramatically depending on how geographic boundaries are drawn. This is not a bug — it is a fundamental property of spatially aggregated data.

### Two Components

1. **Scale effect (aggregation level):** The same data produces different statistical relationships at different levels of aggregation. A regression of income on education yields different coefficients at census tract vs. county vs. state level.

2. **Zoning effect (boundary placement):** Even at the same scale, different boundary configurations produce different results. Redrawing county lines while keeping the same number of counties changes the correlation between variables.

### Practical Implications

- Always be explicit about the geographic unit of analysis and why it was chosen
- Acknowledge MAUP sensitivity in limitations sections
- When feasible, test sensitivity across different aggregation levels (e.g., run the analysis at both county and state level and compare)
- Be cautious about cross-study comparisons that use different geographic units
- Finer spatial resolution is not automatically better — it may introduce more noise without improving the answer to the research question

### Example

A study finds a strong positive correlation between percentage of residents with college degrees and median household income at the county level (r = 0.72). The same analysis at the census tract level yields r = 0.45 — weaker because within-county variation reveals a more complex relationship. Neither result is "wrong"; they answer different questions at different scales.

**Reference:** Openshaw (1984); Rey et al. (2023) Ch. 1

---

## Ecological Fallacy

Relationships observed at aggregate (area) level may not hold at the individual level. This is distinct from MAUP but related — both arise from aggregation.

### The Core Problem

If counties with higher average incomes also have higher average test scores, it does **not** follow that richer individuals score higher. The county-level correlation could be driven entirely by confounders that vary across counties (school funding, urbanization, demographics) rather than by an individual-level relationship.

### Implications for Spatial Analysis

- Area-level data (counties, school districts, census tracts) supports area-level inference only
- Individual-level claims require individual-level data
- When using area-level data, frame findings carefully: "Districts with higher poverty rates tend to have lower graduation rates" — not "Poor students graduate at lower rates"
- The finer the geographic unit, the closer area-level relationships approximate individual-level ones, but the ecological fallacy never fully disappears

**Reference:** Robinson (1950)

---

## Coordinate Reference Systems and Projections

Every spatial dataset exists within a Coordinate Reference System (CRS) that defines how positions on Earth's curved surface are represented as numbers. Getting the CRS wrong produces silently incorrect results — distances, areas, and spatial relationships all depend on it.

### Geographic vs. Projected CRS

| Property | Geographic CRS | Projected CRS |
|----------|---------------|---------------|
| Coordinates | Longitude/latitude (degrees) | Easting/northing (meters or feet) |
| Earth model | 3D ellipsoid | 2D flat plane |
| Standard example | WGS84 (EPSG:4326) | UTM zones, Albers Equal-Area |
| Distance units | Decimal degrees (not constant!) | Meters (constant) |
| Area calculation | **Unreliable** — 1° varies by latitude | Reliable (in the projection's valid region) |

**Critical rule:** Geometric calculations (distance, area, buffer, centroid) in a geographic CRS produce wrong results. One degree of longitude is ~111 km at the equator but ~0 km at the poles. Always project before computing.

### Choosing a Projection

No projection preserves area, direction, shape, and distance simultaneously. Choose based on what your analysis needs:

| Analysis Need | Projection Property | Recommended Projections |
|---------------|-------------------|----------------------|
| Thematic/choropleth mapping | **Equal-area** (preserves area) | Albers Equal-Area Conic (US), LAEA centered on study area |
| Local-scale analysis (<500 km) | Distance accuracy | UTM zone for study area |
| Navigation, bearing calculations | **Conformal** (preserves angles) | Mercator, Lambert Conformal Conic |
| Distance from a point | **Equidistant** | Azimuthal Equidistant centered on point of interest |
| Continental-scale mapping | Area + shape balance | Lambert Conformal Conic |
| Polar regions | Minimal polar distortion | Stereographic |
| Web mapping display | Web compatibility | Web Mercator (EPSG:3857) — display only, never for analysis |

### Common US Projections

| Projection | EPSG | Best For |
|-----------|------|----------|
| NAD83 / Conus Albers | EPSG:5070 | Continental US thematic maps |
| UTM Zone 17N | EPSG:32617 | East Coast local analysis |
| State Plane (varies) | Varies | State/local government compatibility |
| WGS84 | EPSG:4326 | Data storage and exchange (not analysis) |

### Setting vs. Transforming

Two distinct operations that are easily confused:

- **Setting** a CRS declares what system the coordinates are already in. No numbers change. Use when data arrives without CRS metadata.
- **Transforming** (reprojecting) recomputes all coordinates from one CRS to another. Numbers change. Use when you need a different projection for analysis.

Confusing these produces data that plots in the wrong hemisphere or at the wrong scale.

### Coordinate Precision and Significant Digits

Latitude/longitude coordinates carry implicit precision claims. Excessive or insufficient precision misleads about data quality:

| Decimal Places | Approximate Precision | Typical Source |
|----------------|----------------------|----------------|
| 0 (e.g., 39°, -77°) | ~111 km | Deliberately rounded (country-level) |
| 1 (e.g., 38.9, -77.0) | ~11 km | Very coarse geocoding |
| 2 (e.g., 38.90, -77.04) | ~1.1 km | City-level, ZIP centroid |
| 3 (e.g., 38.901, -77.036) | ~110 m | Neighborhood, block group centroid |
| 4 (e.g., 38.9013, -77.0365) | ~11 m | Street-level geocoding |
| 5 (e.g., 38.90130, -77.03650) | ~1.1 m | Building-level, high-quality GPS |
| 6+ | Sub-meter | Survey-grade GPS; rarely needed for social science |

**Practical implications:**
- Geocoded addresses typically warrant 4-5 decimal places at most. Storing 14 decimal places (as some geocoding APIs return) implies sub-atomic precision — misleading and wastes storage.
- Census tract or block group centroids are accurate to ~3-4 decimal places.
- When precision exceeds the actual positional accuracy of the source data, truncate to an honest level and document.
- Point-in-polygon joins may produce different results at different precisions if points fall near polygon boundaries.

**Reference:** Dorman et al. (2025) Chs. 1, 6

---

## Spatial Data Types and Formats

### Vector Data: Points, Lines, Polygons

The **Simple Features** standard defines seven geometry types:

| Type | Dimension | Use When |
|------|-----------|----------|
| Point | 0D | Discrete locations (schools, weather stations, events) |
| LineString | 1D | Linear features (roads, rivers, transit routes) |
| Polygon | 2D | Bounded areas (counties, parcels, lakes) |
| MultiPoint | 0D collection | Multiple related points (chain store locations) |
| MultiLineString | 1D collection | Disconnected line segments (fragmented rivers) |
| MultiPolygon | 2D collection | Non-contiguous areas (archipelago state, district with exclaves) |
| GeometryCollection | Mixed | Heterogeneous features (rare — avoid if possible) |

**When to use vector:** Entities have discrete boundaries, you need precise boundary representation, or you're working with administrative/human-defined areas.

### Raster Data: Gridded Surfaces

Regular grids of uniform cells, each holding a single value. The cell size (resolution) determines spatial precision.

**When to use raster:** Continuous phenomena (temperature, elevation, satellite imagery), phenomena without clear boundaries, or when the source data is inherently gridded (remote sensing, climate models).

### File Format Recommendations

| Format | Type | Recommendation |
|--------|------|---------------|
| **GeoPackage (.gpkg)** | Vector | Preferred modern standard. Single file, multi-layer, no column name limits |
| **GeoParquet** | Vector | Best for analytical workflows. Columnar, fast I/O, works with Polars/DuckDB |
| **Shapefile (.shp)** | Vector | Legacy only. 2 GB limit, 10-char column names, multi-file headache |
| **GeoJSON (.geojson)** | Vector | Web interchange only. Text format, large files |
| **GeoTIFF (.tif)** | Raster | Standard raster format. Broad support |
| **Cloud Optimized GeoTIFF (COG)** | Raster | Large rasters. Enables partial reads over HTTP |

For DAAF research workflows, prefer **GeoParquet** for vector analytical data (integrates with the Polars pipeline) and **GeoPackage** for spatial data with complex geometry or multi-layer needs.

**Reference:** Dorman et al. (2025) Chs. 1, 7

---

## Spatial Analysis Methods: A Decision Guide

Start with the research question, not the method. This decision framework maps question types to appropriate spatial methods:

```
What spatial question are you asking?
│
├─ "Where are things concentrated?"
│   └─ Point pattern analysis
│      ├─ Visualization: KDE (kernel density estimation)
│      ├─ Descriptive: Centrography (mean center, standard distance)
│      └─ Inferential: Ripley's G/F functions, quadrat statistics
│
├─ "Is there spatial clustering in this variable?"
│   └─ Global spatial autocorrelation
│      ├─ Continuous variable → Moran's I, Geary's C
│      ├─ Binary variable → Join count statistics
│      └─ High-value clustering only → Getis-Ord G
│
├─ "Where specifically are the clusters?"
│   └─ Local indicators of spatial association (LISA)
│      ├─ Cluster + outlier detection → Local Moran's I
│      └─ Hot/cold spot detection only → Getis-Ord Gi*
│
├─ "How do I combine spatial layers?"
│   └─ Spatial joins and overlays
│      ├─ Point-in-polygon → Spatial join
│      ├─ Area intersection → Overlay operations
│      └─ Nearest feature → Nearest-neighbor join
│
├─ "How do I transfer data between incompatible boundaries?"
│   └─ Areal interpolation
│      ├─ Simple: area-weighted interpolation
│      └─ Advanced: dasymetric mapping (with auxiliary raster data)
│
├─ "Does space affect my regression?"
│   └─ Spatial regression diagnostics, then model selection
│      ├─ Spatial patterns in residuals → Spatial feature engineering or spatial FE
│      ├─ Spillover effects → Spatial lag model (SLX or SAR)
│      ├─ Correlated errors → Spatial error model (SEM)
│      └─ Varying relationships → Spatial regimes or GWR
│
├─ "What are values at unobserved locations?"
│   └─ Interpolation
│      ├─ Simple: IDW (inverse distance weighting)
│      └─ Advanced: Kriging (if spatial covariance structure is known)
│
└─ "How do I summarize raster values within polygons?"
    └─ Zonal statistics
       Extract mean, sum, count, min, max of raster cells within each polygon
```

---

## Spatial Autocorrelation

Spatial autocorrelation measures whether proximity predicts similarity in variable values. It is the spatial analog of temporal autocorrelation in time series.

### Why It Matters

Human visual pattern recognition is highly prone to false positives when viewing maps. Formal testing is essential — what looks like a cluster on a choropleth may be indistinguishable from spatial randomness (Rey et al. 2023, Ch. 6).

### Global Measures

Global measures produce a single summary statistic for the entire study area.

#### Moran's I

The most widely used measure. Summarizes the correlation between a variable and its **spatial lag** (the weighted average of neighbors' values).

- **Range:** Approximately -1 to +1 (exact bounds depend on the weights matrix)
- **Interpretation:**
  - Positive I → similar values cluster together (positive autocorrelation)
  - I near zero → spatial randomness (no pattern)
  - Negative I → dissimilar values are neighbors (negative autocorrelation, rare in practice)
- **Moran plot:** Scatter plot of standardized values (x-axis) vs. their spatial lag (y-axis). The slope of the fitted line equals Moran's I. Four quadrants correspond to HH, LL, LH, HL configurations.

#### Geary's C

Uses squared differences between neighboring pairs rather than cross-products.

- **Range:** 0 to roughly 2
- **Interpretation (inverse of Moran's I):**
  - C < 1 → positive autocorrelation
  - C ≈ 1 → spatial randomness
  - C > 1 → negative autocorrelation
- May diverge from Moran's I because it is more sensitive to local variation

#### Getis-Ord G

Detects concentration of high or low values using a distance-based approach.

- **Only detects positive autocorrelation** — cannot identify dispersion/negative patterns
- **Requires variables with a natural origin** (positive values only)
- Better suited for questions like "Are high values concentrated?" than "Is there any pattern?"

#### Join Count Statistics (Binary Variables)

For dichotomous variables (e.g., urban/rural, above/below threshold):
- Counts neighboring pairs of same-category (BB, WW) vs. different-category (BW) joins
- More same-category joins than expected under randomness → positive autocorrelation (clustering)

### Inference: Permutation Testing

All global measures use **computational inference** rather than parametric assumptions. The observed values are randomly shuffled across locations (typically 999 permutations) to generate a reference distribution. The pseudo p-value is the proportion of random permutations producing a more extreme statistic than observed.

### Sensitivity to Weights Matrix

The choice of spatial weights matrix substantially affects results. Denser connectivity (e.g., k=8 nearest neighbors vs. k=4) produces smoother lag values and may alter both the magnitude and significance of the statistic. Always report which weights specification was used and consider testing sensitivity across alternatives.

**Reference:** Rey et al. (2023) Chs. 4, 6

---

## Local Spatial Autocorrelation (LISA)

Global measures tell you whether clustering exists but not *where*. Local Indicators of Spatial Association (LISA) decompose the global statistic into location-specific scores, revealing the geography of spatial structure (Anselin 1995).

### Local Moran's I

For each observation, identifies whether its value and its neighbors' average are more similar or dissimilar than chance predicts.

**Quadrant classification (from the Moran scatterplot):**

| Quadrant | Label | Meaning | Interpretation |
|----------|-------|---------|----------------|
| Upper-right | **HH** (Hot Spot) | High value surrounded by high neighbors | Positive local autocorrelation — cluster of high values |
| Lower-left | **LL** (Cold Spot) | Low value surrounded by low neighbors | Positive local autocorrelation — cluster of low values |
| Upper-left | **LH** (Donut) | Low value surrounded by high neighbors | Negative local autocorrelation — spatial outlier |
| Lower-right | **HL** (Diamond) | High value surrounded by low neighbors | Negative local autocorrelation — spatial outlier |

### Getis-Ord Gi* (Hot Spot Analysis)

Identifies statistically significant clusters of high values (hot spots) and low values (cold spots).

- Unlike Local Moran's I, **cannot identify spatial outliers** (HL or LH)
- Positive standardized Gi* → high-value cluster; negative → low-value cluster
- Simpler interpretation than LISA but less information

### Proper LISA Interpretation

A single choropleth of raw local I values is insufficient. Proper analysis requires combining:

1. **Raw local statistic values** — magnitude of local association
2. **Quadrant classification** — type of association (HH/LL/LH/HL)
3. **Statistical significance** — p-value from permutation test
4. **Cluster map** — showing only statistically significant results, colored by quadrant

### Caveats

- **Rate data problem:** Local Moran's I assumes distributional properties violated by rate data (events/population) when the denominator varies. Use rate-corrected versions (Empirical Bayes smoothing) for rate variables.
- **Multiple testing:** Testing hundreds of locations simultaneously inflates false positives. Apply Bonferroni correction or False Discovery Rate (FDR) adjustment, or interpret cautiously.
- **Boundary effects:** Observations at the edge of the study area have fewer neighbors, potentially affecting their local statistics.

**Reference:** Rey et al. (2023) Chs. 7; Anselin (1995)

---

## Point Pattern Analysis

Point pattern analysis examines the spatial distribution of discrete events. Unlike geostatistics (where locations are fixed and values vary), here **location itself is the variable of interest** — the question is whether events cluster, disperse, or distribute randomly.

### Key Concepts

- **Completely Spatially Random (CSR):** The null hypothesis — a Poisson process where events could occur anywhere with equal probability. All tests measure departure from CSR.
- **Process vs. Pattern:** The data-generating mechanism (process) is unobserved; we observe only the pattern. Analysis works backward from pattern to infer likely processes.
- **Marked vs. Unmarked:** Unmarked patterns contain only coordinates; marked patterns include attributes (type, intensity, time).

### Visualization Methods

**Kernel Density Estimation (KDE):** Approximates a continuous density surface by applying a kernel function (typically Gaussian) centered on each point. The **bandwidth** parameter controls smoothing — too small overfits to noise, too large obscures real structure. Common bandwidth selection approaches:
- **Silverman's rule of thumb:** Automated, based on data variance and sample size. Good starting point but tends to over-smooth multimodal distributions.
- **Cross-validation:** Data-driven optimization that minimizes integrated squared error. More computationally expensive but adapts to data structure.
- **Domain-informed:** Choose bandwidth based on the spatial scale of the phenomenon (e.g., 1 km for neighborhood-level patterns, 10 km for regional patterns).

**Hexagonal binning:** A spatial histogram using hexagonal cells. Hexagons have better connectivity properties and less shape distortion than square grids. Finer bins reveal local detail but obscure broad structure; coarser bins simplify but lose nuance.

### Centrography (Descriptive Measures)

| Measure | What It Captures | Analog |
|---------|-----------------|--------|
| Mean center | Average location (center of mass) | Mean |
| Median center | Location minimizing total distance | Median |
| Standard distance | Average distance from mean center | Standard deviation |
| Standard deviational ellipse | Center + dispersion + directional orientation | Confidence ellipse |

When mean and median centers diverge substantially, the pattern is asymmetric or has outlier clusters.

### Extent Measures (Tightest to Loosest)

1. **Alpha shape** — tightest boundary (concave, using variable-radius rolling ball)
2. **Convex hull** — smallest convex polygon enclosing all points
3. **Minimum rotated rectangle** — smallest rectangle (possibly diagonal)
4. **Minimum bounding circle** — smallest enclosing circle

The choice of extent measure affects density calculations — always report which was used.

### Formal Tests for Clustering

**Quadrat statistics:** Divide space into regular cells, count events per cell, apply chi-squared test. **Caution:** Irregular study area boundaries can produce false significance even for truly random patterns because the test conflates point uniformity with boundary shape.

**Ripley's G function (nearest-neighbor distances):**
- Rapid increase relative to CSR → clustering (points closer together than expected)
- Slow increase → dispersal (points farther apart than expected)

**Ripley's F function (empty-space distances):**
- Slow increase → clustering with voids (large empty areas between clusters)
- Rapid increase → even/dispersed distribution
- Complements G by characterizing void structure

**Interpreting G/F against CSR envelopes:** Both functions are evaluated by comparing the empirical function against a **simulation envelope** — the range of function values produced by many random point patterns (typically 99 or 999 simulations) under CSR. The envelope represents a confidence band:
- If the empirical curve falls **above** the envelope for G → points are closer together than expected (clustering)
- If the empirical curve falls **below** the envelope for G → points are farther apart (regularity/dispersal)
- For F, the interpretation reverses: **below** the envelope indicates clustering (empty-space distances are larger than expected because points are clumped together with voids between)
- The **distance at which the empirical curve departs from the envelope** indicates the spatial scale of the pattern — critical for choosing DBSCAN parameters or interpreting the phenomenon
- If the empirical curve stays within the envelope across all distances → cannot reject CSR at that confidence level

**DBSCAN clustering:** Identifies clusters requiring at least *m* points within distance *r*. Deterministic, not inferential — identifies clusters but provides no statistical test. Parameter selection should reflect the scale of the phenomenon (Ripley's G/F can inform this — use the distance at which departure from CSR is strongest as a starting point for *r*).

**Reference:** Rey et al. (2023) Ch. 8

---

## Spatial Regression

When standard regression is applied to spatial data, residuals frequently exhibit spatial patterns — indicating that the model has failed to account for geographic structure. Spatial regression methods address this by explicitly incorporating space into the modeling framework (Rey et al. 2023, Ch. 11).

### Diagnosing Spatial Problems in Standard Regression

Before reaching for spatial models, diagnose whether spatial structure is present:

1. **Map the residuals** — visual inspection for geographic patterns
2. **Moran's I on residuals** — formal test for spatial autocorrelation in errors
3. **K-neighbor correlograms** — how spatial dependence in residuals decays with distance
4. **Local Moran's I on residuals** — where specifically the model over/under-predicts

Systematic geographic patterns in residuals indicate at least one of: omitted spatially-varying covariates, spatial spillover effects, or spatially varying relationships.

### Methods Progression (Simplest to Most Complex)

**1. Spatial Feature Engineering**
- Create explanatory variables from geographic relationships (distance to nearest city, count of schools within 10 km, average neighbor income)
- Addresses omitted spatial covariates without changing the model structure
- Estimated with OLS — no special estimator needed
- Try this first before more complex approaches

**2. Spatial Fixed Effects**
- Binary dummies for spatial groupings (county, state, region) that absorb all unobserved factors varying across those units
- Compares observations only within their spatial group
- Standard approach in applied economics; does not require spatial software
- Limitation: only controls for factors that vary at the chosen grouping level

**3. Spatial Regimes**
- Allow both intercepts and slopes to vary across spatial groups
- Tests whether relationships between variables differ by region
- **Chow test** evaluates whether regime differences are statistically significant
- More flexible than fixed effects but requires enough observations per regime

**4. Spatial Lag of X (SLX) Model**
- Includes spatial lags of explanatory variables (neighbors' average X) as additional predictors
- Distinguishes **direct effects** (impact at the focal location) from **indirect effects** (spillover from neighbors)
- Estimable with OLS because spatial lags of X are exogenous
- For row-standardized k-nearest-neighbor weights: indirect effect per neighbor = spatial lag coefficient / k

**5. Spatial Error Model (SEM)**
- Spatial dependence in the error term — errors are correlated across neighbors through autoregressive parameter λ
- OLS coefficient estimates remain asymptotically unbiased, but standard errors are wrong — inference (CIs, p-values) is unreliable without proper estimation
- Requires GMM or ML estimation
- Appropriate when the spatial pattern is a nuisance to correct for, not a substantive interest

**6. Spatial Lag Model (SAR)**
- Includes a spatial lag of the **dependent variable** (neighbors' average Y) as a predictor
- Creates endogeneity — Y appears on both sides. Requires instrumental variable (2SLS) or ML estimation
- **Coefficients cannot be directly interpreted as marginal effects** — changes propagate through the spatial lag, creating feedback. Use scenario-based prediction comparisons instead.
- Appropriate when you believe outcomes in one location genuinely affect outcomes in neighboring locations (spillovers)

### Model Selection Guidance

```
Spatial patterns in residuals?
├─ No → OLS is fine. No spatial correction needed.
├─ Yes → What is the likely source?
│   ├─ Omitted spatially-varying variables
│   │   └─ Try spatial feature engineering (Method 1) or spatial FE (Method 2)
│   │       Recheck residuals after — problem may be resolved.
│   ├─ Spillover effects (neighbor outcomes affect focal outcome)
│   │   └─ Spatial lag model (Method 6) or SLX (Method 4)
│   ├─ Correlated unobserved shocks
│   │   └─ Spatial error model (Method 5)
│   └─ Relationships vary across space
│       └─ Spatial regimes (Method 3)
│           or GWR (exploratory — see note below)
```

### Geographically Weighted Regression (GWR): Scope Note

GWR fits a separate regression at each observation using distance-weighted subsets of the data, producing a surface of locally-varying coefficients. It is conceptually powerful for exploring spatial heterogeneity but carries significant methodological complexity:

- **Not a confirmatory tool:** GWR is best understood as an exploratory technique for discovering *where* relationships vary, not for hypothesis testing. The local coefficient estimates are highly correlated with each other and with the local intercept.
- **Bandwidth selection is critical:** The kernel bandwidth determines how "local" each regression is. Too small overfits to noise; too large approximates global OLS. Cross-validation (AICc-based) is standard practice.
- **Multicollinearity amplification:** Variables that are mildly collinear globally can become severely collinear locally (smaller effective sample size per regression). Check local condition numbers.
- **Interpretation:** Map local coefficients and their local t-statistics side by side. A coefficient that is large but non-significant locally should not be interpreted.

**When to use:** As an exploratory step when spatial regimes (Method 3) suggest relationships vary but you do not know the regime boundaries in advance. Follow up with spatial regimes using GWR-informed groupings for confirmatory analysis.

**Reference:** Fotheringham, Brunsdon, and Charlton (2002). *Geographically Weighted Regression*.

### Lagrange Multiplier Tests for Model Discrimination

The model selection tree above requires distinguishing spatial lag from spatial error dependence. The standard diagnostic is the **Lagrange Multiplier (LM) test battery** applied to OLS residuals:

| Test | What It Detects | Decision Rule |
|------|----------------|---------------|
| LM-lag | Spatial lag dependence (SAR) | Significant → evidence for SAR |
| LM-error | Spatial error dependence (SEM) | Significant → evidence for SEM |
| Robust LM-lag | Lag dependence, controlling for error | Use when both LM tests are significant |
| Robust LM-error | Error dependence, controlling for lag | Use when both LM tests are significant |

**Decision protocol:**
1. Run all four tests on OLS residuals
2. If only LM-lag is significant → SAR (spatial lag model)
3. If only LM-error is significant → SEM (spatial error model)
4. If both are significant → compare robust versions: prefer the model whose **robust** test has the larger test statistic
5. If neither is significant → OLS is adequate; no spatial model needed (even if Moran's I was significant — the LM tests are more specific)

This protocol is standard in spatial econometrics (Anselin 2005) and is the primary tool for the "What is the likely source?" fork in the model selection tree above.

### Key Caveats

- **Omitted variable bias vs. genuine spatial process:** Spatially patterned residuals may reflect omitted variables that happen to vary geographically, not true spatial spillovers. Domain knowledge is essential to distinguish.
- **Weights matrix sensitivity:** Different spatial weights (k-nearest neighbors, distance bands, contiguity) can yield different conclusions. Results should be robust across reasonable specifications.
- **R² improvement alone is insufficient:** A better fit does not mean spatial structure is resolved. Re-run autocorrelation diagnostics after adding spatial components.
- **Multiple comparisons:** Testing many spatial effects simultaneously (regime-specific coefficients, local statistics) requires correction or cautious interpretation.

**Reference:** Rey et al. (2023) Ch. 11

---

## Raster Operations Taxonomy

Raster operations follow a four-category **map algebra** taxonomy organized by spatial scope (Dorman et al. 2025, Ch. 3):

| Operation | Scope | Description | Examples |
|-----------|-------|-------------|----------|
| **Local** | Cell-by-cell | Each output cell depends only on the corresponding input cell(s) | Arithmetic (add, subtract rasters), reclassification, logical comparisons, NDVI calculation |
| **Focal** | Cell + neighbors | Each output cell depends on a neighborhood (kernel) around the input cell | Smoothing, slope/aspect, edge detection, moving averages. Typically 3×3 kernel |
| **Zonal** | Defined zones | Summary statistics computed within zones defined by a categorical raster | Mean elevation per land-use type, total rainfall per watershed. Output is a table, not a raster |
| **Global** | Entire raster | Every cell potentially contributes to every output cell | Distance-to-feature rasters, viewshed analysis, flow accumulation |

### Conceptual Parallels to Vector Operations

| Raster Operation | Vector Analog |
|-----------------|--------------|
| Distance raster | Buffer |
| Reclassification | Dissolve |
| Raster overlay | Vector clip/intersection |
| Zonal statistics | Spatial join + group_by aggregation |

### Raster-Vector Interactions

Three primary interaction types:

1. **Extraction:** Retrieve raster values at vector locations (point values, line transects, polygon summaries via zonal statistics)
2. **Masking/Cropping:** Use vector boundaries to subset rasters (masking sets outside pixels to NoData; cropping also reduces extent)
3. **Conversion:** Rasterization (vector→raster) and vectorization (raster→vector). Both are lossy — resolution and boundary-cell handling decisions affect results and should be explicitly documented.

**Reference:** Dorman et al. (2025) Chs. 3-5

---

## Map Design Principles

Maps are both analytical tools and communication devices. Poor design undermines the presentation of professional analysis — amateur-looking maps weaken credibility regardless of methodological rigor (Dorman et al. 2025, Ch. 8).

### Map Types

| Type | Best For | Key Consideration |
|------|----------|------------------|
| **Choropleth** | Rates, densities, proportions (area-fill by value) | The most common thematic map — but ONLY for normalized data (see below) |
| **Proportional symbol** | Counts, totals, magnitudes (symbol size by value) | Use for raw counts to avoid visual conflation with polygon area |
| **Dot density** | Showing distribution of discrete entities within areas | Each dot represents N entities; reveals within-polygon variation |
| **Static** (PNG/PDF) | Publication, archival, reports | Resolution and print quality |
| **Interactive** (web) | Exploration, presentations, data portals | Basemap + zoom/pan + popups |
| **Faceted** (small multiples) | Comparing patterns across time or attributes | Consistent scale and symbology across panels |

### Choropleth Normalization Rule

**Choropleth maps must display rates, densities, or normalized values — never raw counts.** A choropleth of "total students by county" is essentially a population map: large counties visually dominate regardless of the phenomenon of interest. This is among the most common cartographic errors in data science.

- **Raw counts** (total enrollment, number of events, population) → use proportional symbol or dot density maps
- **Rates/proportions** (poverty rate, graduation rate, percent change) → choropleth is appropriate
- **Densities** (population per sq km, schools per sq mile) → choropleth is appropriate

If the research question requires showing totals and you must use area polygons, normalize by area (density) or population (per capita) before mapping.

### Classification Schemes for Choropleth Maps

How continuous values are binned into color classes dramatically affects the visual story. Common schemes:

| Scheme | Logic | Best For | Pitfall |
|--------|-------|----------|---------|
| **Equal interval** | Constant bin width | Uniformly distributed data | Poor for skewed distributions — most observations in one class |
| **Quantiles** | Equal count per bin | Skewed data, ensuring visual variation | Hides the actual distribution shape; bins may span very different ranges |
| **Natural breaks (Jenks)** | Minimize within-class variance | Data with natural groupings | Opaque — hard for readers to understand bin boundaries |
| **Fisher-Jenks** | Optimized natural breaks | Same as Jenks, larger datasets | Same opacity concern |
| **Standard deviation** | Distance from mean | Highlighting anomalies | Requires normally distributed data |
| **Manual** | Domain-defined thresholds | Policy-relevant breakpoints (poverty line, AQI levels) | Requires domain knowledge |

**Number of classes:** 4-7 classes is the practical range. Fewer than 4 obscures meaningful variation; more than 7 exceeds most readers' ability to distinguish colors reliably. **5 classes** is a robust default. Use fewer classes for simple communication, more for expert audiences.

**Quantile perceptual risk:** Quantile classification forces equal counts per bin, which means bins may span wildly different value ranges. A map can show dramatic spatial contrast between adjacent areas that differ by trivially small amounts if a class boundary happens to fall between them. Always inspect the actual bin edges — if a class boundary splits a cluster of very similar values, consider natural breaks or manual thresholds instead.

**Sequential vs. diverging palettes for choropleth:**
- **Sequential** (light→dark): when data has a natural "low to high" interpretation with no meaningful midpoint (population density, income levels, enrollment counts)
- **Diverging** (two hues meeting at neutral center): when data has a meaningful center or threshold and you want to emphasize deviation in both directions (change from baseline, residuals, above/below average, partisan vote share)
- Using diverging palettes for data without a meaningful center misleads — the neutral midpoint implies a "break" that doesn't exist

**General guidance:** Quantiles for exploratory work (ensures visual variation), natural breaks for presentation (captures data structure), manual for policy contexts (meaningful thresholds). Always include the classification scheme in the legend or caption.

### Color Considerations

- **Sequential palettes** (light→dark or pale→saturated) for continuous quantitative data
- **Diverging palettes** (two hues meeting at a neutral midpoint) for data with a meaningful center (deviation from mean, above/below threshold)
- **Qualitative palettes** (distinct hues, no implied order) for categorical data
- Use **ColorBrewer** palettes — specifically designed for cartography and perceptual accuracy
- Never encode meaning through color alone — pair with pattern, shape, or label for accessibility. Detailed color accessibility guidance is in `visualization-execution.md`.

### Map Elements Checklist

Every publication-quality map should include:
- [ ] Title (declarative for explanatory maps, descriptive for exploratory)
- [ ] Legend with clear labels and classification scheme noted
- [ ] Scale bar (appropriate to map extent)
- [ ] North arrow (if orientation is non-standard or not obvious)
- [ ] Source attribution and date
- [ ] Projection noted (especially if equal-area was used for thematic mapping)

**Reference:** Rey et al. (2023) Ch. 5; Dorman et al. (2025) Ch. 8

---

## References and Further Reading

### Primary Textbooks (Open Access)

Rey, S.J., Arribas-Bel, D., and Wolf, L.J. (2023). *Geographic Data Science with Python*. CRC Press. https://geographicdata.science/book/

Dorman, M., Graser, A., Nowosad, J., and Lovelace, R. (2025). *Geocomputation with Python*. CRC Press. https://py.geocompx.org/

Tenkanen, H., Heikinheimo, V., and Whipp, D. (Forthcoming). *Introduction to Python for Geographic Data Analysis*. CRC Press. https://pythongis.org/

### Foundational References

Anselin, L. (1995). "Local Indicators of Spatial Association — LISA." *Geographical Analysis*, 27(2), 93-115.

Openshaw, S. (1984). *The Modifiable Areal Unit Problem*. Concepts and Techniques in Modern Geography No. 38. Geo Books.

Robinson, W.S. (1950). "Ecological Correlations and the Behavior of Individuals." *American Sociological Review*, 15(3), 351-357.

Tobler, W.R. (1970). "A Computer Movie Simulating Urban Growth in the Detroit Region." *Economic Geography*, 46(Supplement), 234-240.

### Spatial Econometrics and Diagnostics

Anselin, L. (2005). "Exploring Spatial Data with GeoDa: A Workbook." Spatial Analysis Laboratory, University of Illinois. (Canonical source for LM test decision protocol.)

Conley, T.G. (1999). "GMM Estimation with Cross Sectional Dependence." *Journal of Econometrics*, 92(1), 1-45. (Spatial HAC standard errors.)

### Geographically Weighted Regression

Fotheringham, A.S., Brunsdon, C., and Charlton, M. (2002). *Geographically Weighted Regression: The Analysis of Spatially Varying Relationships*. Wiley.

### Software Ecosystem

Rey, S.J. et al. (2022). "The PySAL Ecosystem: Philosophy and Implementation." *Geographical Analysis*, 54(3), 467-487. https://pysal.org/

### Additional Resources

Cleveland, W.S. and McGill, R. (1984). "Graphical Perception: Theory, Experimentation, and Application to the Development of Graphical Methods." *Journal of the American Statistical Association*, 79(387), 531-554.

Anselin, L. and Rey, S.J. (2014). *Modern Spatial Econometrics in Practice: A Guide to GeoDa, GeoDaSpace and PySAL*. GeoDa Press.
