# Geospatial Operations Guide

Detailed operational guidance for spatial analysis methods — more specific than the conceptual overview in `geospatial-analysis.md` but still methodology-focused (not library syntax). Covers the practical decisions, pitfalls, and interpretation patterns you encounter when actually executing spatial operations.

For implementation syntax, load the `geopandas` skill. For conceptual foundations (when/why to use each method), see `geospatial-analysis.md`.

---

## Spatial Join Strategies and Pitfalls

Spatial joins connect records from two datasets based on geographic relationships rather than shared key columns. They are the spatial analog of tabular joins, but with unique complications.

### Choosing a Spatial Predicate

| Predicate | Meaning | Common Use Case |
|-----------|---------|-----------------|
| **intersects** | Geometries share any space (including touching edges) | Default for most joins — "which polygon does this point fall in?" |
| **within** | Left geometry is entirely inside right geometry | Points within service areas, schools within districts |
| **contains** | Left geometry entirely encloses right geometry | Districts containing schools (reverse of within) |
| **touches** | Geometries share boundary but no interior space | Adjacency detection (neighboring counties) |
| **crosses** | Geometries share some but not all interior space | Roads crossing rivers, pipelines crossing boundaries |
| **nearest** | Closest geometry by distance | Nearest school to each student, nearest hospital to each census tract |

**Default recommendation:** Start with `intersects` unless the research question specifically requires a stricter predicate. It is the most permissive and captures the broadest set of matches. **Exception for point-in-polygon:** when assigning points to polygons (e.g., schools to districts), `within` is the conventional choice — it requires the point to be strictly inside the polygon, avoiding ambiguous boundary matches that `intersects` would produce.

### Cardinality Pitfalls

Spatial joins can produce unexpected row counts. Unlike tabular joins where key uniqueness is often guaranteed, spatial relationships are inherently many-to-many:

| Scenario | Problem | Solution |
|----------|---------|----------|
| Point falls on polygon boundary | Matches multiple polygons | Decide: assign to first match, or keep duplicates and aggregate |
| Overlapping polygons | Point intersects multiple polygons | Check source data for overlaps; resolve with priority rules |
| Buffer-based joins | Buffer intersects multiple features | Expected behavior — aggregate after join (count, mean, sum) |
| Empty geometries | No match found | Decide: keep unmatched rows (left join) or drop (inner join) |

**Validation pattern after every spatial join:**
1. Compare row count before and after
2. Check for duplicated rows from the left table (indicates many-to-many)
3. Check for null values in joined columns (indicates unmatched rows)
4. Spot-check a few results visually on a map

### CRS Prerequisite

Both datasets **must** be in the same CRS before joining. A CRS mismatch silently produces wrong results (points assigned to wrong polygons or no matches found). Always verify CRS agreement before any spatial operation.

---

## Overlay Operation Selection

Overlay operations combine two polygon layers to produce a new geometry layer. Unlike spatial joins (which transfer attributes), overlays create new geometries from the intersection of input geometries.

### Operation Reference

| Operation | Output Contains | Analogy | Use When |
|-----------|----------------|---------|----------|
| **Intersection** | Only areas where both layers overlap | Set ∩ | "What area is both wetland AND within the flood zone?" |
| **Union** | All areas from both layers | Set ∪ | "Combine school districts and census tracts into all unique sub-areas" |
| **Difference** | Areas in first layer but NOT in second | Set A \ B | "What area of the park is NOT in the fire zone?" |
| **Symmetric difference** | Areas in either layer but NOT in both | Set △ | "Areas that are in one zone but not the other" |

### When to Use Overlay vs. Spatial Join

- **Overlay:** When you need new geometries (cutting polygons, finding overlapping areas, computing the area of overlap)
- **Spatial join:** When you need to transfer attributes from one layer to another without modifying geometries

### Common Pitfalls

- **Sliver polygons:** Overlay operations on nearly-coincident boundaries create tiny artifact polygons. Filter by minimum area threshold after overlay.
- **Topology errors:** Invalid geometries (self-intersections, holes) cause overlay failures. Validate and repair geometries before overlaying (see Geometry Validity below).
- **Attribute conflicts:** When both layers have columns with the same name, one gets suffixed. Rename before overlay to control naming.

---

## Geometry Validity

Invalid geometries are the most common cause of silent failures in spatial operations. An invalid geometry violates the rules of the Simple Features specification — overlays, spatial joins, and buffer operations may crash, return empty results, or produce subtly wrong output without warning.

### What Makes a Geometry Invalid

| Defect | Description | Common Source |
|--------|-------------|---------------|
| **Self-intersection** | Polygon boundary crosses itself, creating a "bowtie" or "figure-8" | Digitization errors, aggressive simplification |
| **Ring ordering** | Exterior ring wound clockwise instead of counter-clockwise (or vice versa for holes) | Format conversions, manual geometry construction |
| **Unclosed ring** | First and last coordinates of a polygon ring don't match | Truncated data, lossy format conversion |
| **Duplicate vertices** | Consecutive identical coordinates | GPS noise, data merge artifacts |
| **Collapsed geometry** | Polygon with zero area or line with zero length | Over-aggressive filtering or clipping |
| **Nested holes** | Hole inside a hole | Topology construction errors |

### Detection and Repair

**Detection workflow:**
1. Check validity of all geometries before any spatial operation
2. Count and report invalid geometries (typically a small fraction of the dataset)
3. Inspect a sample of invalid geometries to understand the defect type

**Repair strategies (ordered by preference):**

1. **Buffer by zero** — The classic "fix everything" approach. Applies a zero-width buffer, which forces the geometry engine to reconstruct a valid polygon. Works for most self-intersections and ring ordering issues. May alter geometry shape slightly.

2. **make_valid** — A more sophisticated repair that attempts to preserve the original geometry's intent. Handles self-intersections by splitting into valid components. Preferred when available because it is more predictable than buffer-by-zero.

3. **Simplification** — Removes excess vertices, which may resolve duplicate-vertex and near-self-intersection issues. Use with caution — aggressive simplification creates new invalidity.

4. **Manual inspection** — For geometries that resist automated repair (rare). Investigate the source data; the geometry may need to be re-digitized or excluded.

**Post-repair validation:** Always re-check validity after repair. Some repair methods can introduce new issues (e.g., buffer-by-zero on complex MultiPolygons may merge components that should remain separate).

### When to Validate

- **Before any overlay operation** (intersection, union, difference)
- **Before spatial joins** (especially with `contains` or `within` predicates)
- **After reading data from Shapefiles** (the format is prone to validity issues)
- **After any geometry transformation** (simplification, projection, dissolve)

---

## Spatial Weights Construction Decisions

Spatial weights matrices (W) formalize the concept of "neighbor" — they define which observations are connected and how strongly. Every spatial autocorrelation test, LISA map, and spatial regression depends on this choice, so it is not merely a technical detail but a substantive analytical decision.

### Weight Types

| Type | Logic | Parameters | Best For |
|------|-------|------------|----------|
| **Queen contiguity** | Shared edge OR vertex | None (binary) | Polygons with regular shapes (census tracts, grid cells) |
| **Rook contiguity** | Shared edge only | None (binary) | When vertex-only adjacency is spurious (diagonal cells) |
| **K-nearest neighbors (KNN)** | K closest centroids | k (number of neighbors) | Points; or when you want every observation to have the same number of neighbors |
| **Distance band** | All within threshold distance | d (distance threshold) | When proximity within a specific range matters (e.g., schools within 10 km) |
| **Kernel** | Distance-weighted, continuous | bandwidth, kernel function | When you want closer neighbors to count more than distant ones |
| **Block** | Same group membership | group variable | Observations in the same administrative unit (students in same school) |

### Row Standardization

Most applications use **row-standardized** weights, where each row sums to 1. This means the spatial lag is a weighted average of neighbors' values. Row standardization is conventional but has implications:

- Observations with more neighbors get smaller individual weights per neighbor
- Observations with fewer neighbors (e.g., at edges or borders) give each neighbor more influence
- For KNN weights, row standardization has no effect (all rows already have the same number of neighbors)

### CRS Prerequisite for Distance-Based Weights

Distance-band and KNN weights compute distances between observations. If the data is in a geographic CRS (longitude/latitude), these distances are in decimal degrees — meaningless for spatial analysis because one degree of longitude varies from ~111 km at the equator to ~0 km at the poles. **Always project to an appropriate projected CRS before constructing distance-band or KNN weights.** Contiguity weights (Queen, Rook) are based on shared boundaries, not distances, so they are less sensitive to CRS choice — but projecting is still good practice.

### Decision Guidance

```
What kind of features are you working with?
├─ Regular polygons (grid cells, tracts)
│   └─ Start with Queen contiguity
│       Consider Rook if diagonal adjacency is not meaningful
├─ Irregular polygons (counties, districts)
│   └─ Queen contiguity is default
│       KNN if polygon sizes vary dramatically (ensures connectivity)
├─ Point data
│   └─ KNN is default (k=5 or k=8 is common starting point)
│       Distance band if there is a domain-meaningful threshold
└─ Mixed or uncertain
    └─ Test multiple specifications and compare results
        If conclusions change, report sensitivity
```

### Sensitivity Testing

Because the weights matrix affects all downstream spatial statistics, responsible practice requires:

1. Run the primary analysis with the default specification (e.g., Queen contiguity)
2. Re-run with at least one alternative (e.g., KNN with k=6, k=10)
3. If results are qualitatively similar → report primary, note robustness in supplementary material
4. If results differ → report both and discuss which specification is more defensible for the research question

---

## Interpreting Moran's I and LISA Results

### Global Moran's I: Step-by-Step Interpretation

1. **Report the statistic:** "Moran's I = 0.43"
2. **Report the inference:** "pseudo p-value < 0.001 (999 permutations)" — statistically significant
3. **Interpret direction:** Positive → clustering of similar values; Negative → dispersion
4. **Interpret magnitude:** Closer to +1 → stronger clustering. Context matters — for most socioeconomic variables, I = 0.2-0.5 is moderate, I > 0.5 is strong
5. **Note the weights:** "Based on Queen contiguity weights" — this is essential metadata

**Example write-up:**
> Poverty rates exhibit significant positive spatial autocorrelation (Moran's I = 0.47, p < 0.001, 999 permutations, Queen contiguity), indicating that high-poverty counties tend to neighbor other high-poverty counties and vice versa.

### LISA Cluster Maps: Step-by-Step Interpretation

1. **Report the number of significant clusters by type:**
   - "67 HH clusters (hot spots), 43 LL clusters (cold spots), 12 HL outliers, 8 LH outliers (p < 0.05)"
2. **Describe the spatial pattern:**
   - "Hot spots concentrate in the Deep South and Appalachia; cold spots in the suburban Northeast and Pacific Northwest"
3. **Connect to research question:**
   - "The clustering of high-poverty counties in the Deep South persists even after controlling for urbanization, suggesting structural factors beyond rural/urban differences"
4. **Note caveats:**
   - Multiple testing (if many locations tested, some significant results are expected by chance)
   - Boundary effects (edge observations have fewer neighbors)
   - Weights sensitivity

### Common Interpretation Mistakes

| Mistake | Why It's Wrong | Correct Interpretation |
|---------|---------------|----------------------|
| "Moran's I = 0.4 means 40% spatial correlation" | Moran's I is not a proportion or R² | "Moderate positive spatial autocorrelation" |
| "This HH cluster causes high values" | LISA identifies pattern, not causation | "These locations form a cluster of high values" |
| "Non-significant Moran's I means no spatial pattern" | Absence of evidence ≠ evidence of absence | "We cannot reject spatial randomness at this significance level" |
| Reporting LISA without significance filtering | Many local statistics are not significant | Always filter to p < 0.05 (or chosen threshold) before interpretation |

### Example Write-Up: LISA Cluster Map

> Local Moran's I analysis (p < 0.05, 999 permutations, Queen contiguity weights) identified 67 statistically significant hot spots (HH), 43 cold spots (LL), 12 high-low outliers (HL), and 8 low-high outliers (LH). Hot spots of high child poverty rates concentrate in the Mississippi Delta and central Appalachia, while cold spots cluster in suburban counties of the Northeast and Pacific Northwest. The 20 spatial outliers — high-poverty counties adjacent to low-poverty neighbors and vice versa — include several urban-edge counties where sharp socioeconomic gradients cross county boundaries.

### Example Write-Up: Spatial Regression Results

> OLS residuals exhibited significant spatial autocorrelation (Moran's I = 0.31, p < 0.001, Queen contiguity), indicating spatial model misspecification. Lagrange Multiplier diagnostics favored the spatial error specification (LM-error = 24.7, p < 0.001; robust LM-error = 18.2, p < 0.001) over the spatial lag specification (LM-lag = 8.3, p = 0.004; robust LM-lag = 1.8, p = 0.18). The spatial error model (SEM, lambda = 0.38, p < 0.001) resolved residual autocorrelation (Moran's I on SEM residuals = 0.02, p = 0.41). Coefficient estimates changed modestly: the poverty rate effect increased from 0.42 (OLS) to 0.51 (SEM), suggesting that OLS attenuated this estimate by absorbing spatially structured variation into the error term. All substantive conclusions were robust to alternative weight specifications (KNN k=6, k=10).

---

## Interpolation Method Selection

Interpolation estimates values at unobserved locations from known measurements — filling in the gaps between sample points to create a continuous surface.

### Method Comparison

| Method | Assumption | Strengths | Weaknesses | When to Use |
|--------|-----------|-----------|------------|-------------|
| **IDW (Inverse Distance Weighting)** | Nearby points have more influence; influence decays with distance | Simple, intuitive, always passes through known points | Cannot extrapolate beyond data range; sensitive to clustering; no uncertainty estimate | Quick estimates, exploratory work, uniformly distributed sample points |
| **Kriging (Ordinary)** | Spatial covariance structure is stationary and known (estimated from variogram) | Provides prediction uncertainty; statistically optimal under assumptions; handles clustered data | Requires variogram fitting (subjective); assumes stationarity; computationally heavier | When uncertainty estimates matter; geostatistical applications; environmental monitoring |
| **Spline** | Surface is smooth | Smooth output; honors all data points | Can oscillate wildly between distant points; no uncertainty | Smooth continuous surfaces with good coverage |
| **Nearest neighbor** | Value equals nearest known point | Simple; works for categorical data | Blocky output; no interpolation between points | Categorical data; Voronoi/Thiessen polygons |

### IDW Power Parameter

The power parameter (p) controls how quickly influence decays with distance:
- **p = 1:** Gradual decay — distant points still influential → smoother surface
- **p = 2:** Standard default — moderate decay
- **p = 3+:** Steep decay — result approaches nearest-neighbor → more local, rougher surface

Higher p values make the surface more sensitive to nearby points and less smooth. The choice should reflect domain knowledge about how the variable actually varies in space.

### Variogram Interpretation (for Kriging)

The variogram describes how spatial similarity changes with distance:

| Component | Meaning | Implication |
|-----------|---------|-------------|
| **Nugget** | Variance at zero distance (measurement error + micro-scale variation) | Large nugget → noisy data or significant sub-sample-scale variation |
| **Sill** | Total variance (plateau) | Difference between sill and nugget = spatially structured variance |
| **Range** | Distance at which spatial correlation disappears | Beyond this distance, observations are effectively independent |

**Nugget-to-sill ratio** as a quality indicator:
- Nugget/Sill < 0.25 → strong spatial structure, kriging will perform well
- 0.25 < Nugget/Sill < 0.75 → moderate spatial structure, kriging useful but uncertainty is higher
- Nugget/Sill > 0.75 → weak spatial structure, kriging offers little advantage over simpler methods

#### Theoretical Variogram Models

The empirical variogram (computed from data) must be fit with a theoretical model to use in kriging. Common choices:

| Model | Shape | Best For |
|-------|-------|----------|
| **Spherical** | Linear rise that flattens at range | Most common default; works well for many environmental variables |
| **Exponential** | Asymptotic rise (reaches sill gradually) | When correlation decays smoothly; range is reached asymptotically rather than at a sharp cutoff |
| **Gaussian** | S-shaped, slow rise near origin | Very smooth phenomena (elevation, groundwater); implies high continuity at short distances |
| **Linear** | Straight line, no sill | When spatial correlation does not plateau within the study area; may indicate non-stationarity |

**Fitting guidance:** Start with spherical (the most robust default). If the empirical variogram shows a very gradual initial rise, try Gaussian. If it rises steeply at first then flattens slowly, try exponential. If no plateau is visible, consider whether the study area is too small relative to the spatial process, or whether the process is non-stationary.

#### Stationarity Assumption

Kriging assumes the spatial covariance structure is **stationary** — the same everywhere in the study area. Violations include:
- A trend in the data (values systematically increase in one direction) — use Universal Kriging or detrend first
- Different variogram shapes in different parts of the study area — the phenomenon may require separate regional models

**Anisotropy:** If the variogram looks different in different directions (e.g., stronger correlation along a river valley than perpendicular to it), the data exhibits anisotropy. Standard (isotropic) variograms assume uniform behavior in all directions. If directional variograms reveal anisotropy, use anisotropic kriging or investigate whether a directional trend should be removed first. Common in environmental data (pollution plumes, prevailing wind patterns).

**Fallback decision rule:** If the variogram is flat (nugget ≈ sill), there is no spatial structure to exploit. In this case, the best prediction for any unobserved location is the **global mean** — not IDW, which would still produce locally varying estimates based on proximity even though proximity carries no information. If the variogram cannot be fit convincingly to any theoretical model but shows some structure, fall back to IDW as a simple non-parametric alternative rather than forcing a poor kriging model.

---

## Zonal Statistics Workflow

Zonal statistics summarize raster cell values within vector polygon boundaries — for example, computing mean temperature within each county or total population within each school catchment area.

### Standard Workflow

1. **Ensure CRS match** between raster and vector data
2. **Choose summary statistics** based on the variable and research question:
   - **Count-based variables** (population, events): use `sum`
   - **Rate/intensity variables** (temperature, concentration): use `mean` or `median`
   - **Extremes matter** (flood risk, max temperature): use `min`, `max`, or percentiles
   - **Distribution shape matters**: use `std`, `count` (number of cells) alongside central tendency
3. **Handle edge cells** — cells that overlap polygon boundaries:
   - Default: include all cells whose center falls within the polygon
   - Alternative: include all cells that touch the polygon boundary (all-touched mode)
   - The choice matters most for small polygons relative to raster resolution
4. **Handle NoData cells** — raster cells with missing values:
   - Exclude from calculations (standard)
   - Count the number of NoData cells per polygon to assess data completeness
5. **Validate results** — spot-check a few polygons visually against the raster

### Resolution Considerations

When raster resolution is coarse relative to polygon size:
- Small polygons may contain very few cells → statistics are unreliable
- Report the count of contributing cells alongside summary statistics
- Consider flagging polygons with fewer than a minimum number of cells (e.g., < 10)

---

## Area-Weighted Interpolation for Boundary Mismatches

When you need to transfer data from one set of polygon boundaries to another (e.g., census tracts to school districts), and the boundaries do not align, **areal interpolation** is required.

### The Problem

Source zones (e.g., census tracts) and target zones (e.g., school districts) have different, overlapping boundaries. A simple spatial join would either double-count (if a tract spans two districts) or lose data (if only centroid-based).

### Area-Weighted Approach (Simple)

1. **Intersect** source polygons with target polygons, creating sub-polygons
2. **Calculate** the fraction of each source polygon's area that falls in each target polygon
3. **Distribute** the source value proportionally by area fraction:
   - For **extensive variables** (population counts, total income): multiply value by area fraction
   - For **intensive variables** (density, rate, proportion): use area-weighted average

### Extensive vs. Intensive Variables

| Variable Type | Meaning | Area-Weighted Operation | Example |
|--------------|---------|------------------------|---------|
| **Extensive** | Total quantity that scales with area | Multiply by area fraction | Population: 1000 people in a tract, 60% of area falls in District A → 600 assigned to A |
| **Intensive** | Rate or density independent of area | Area-weighted average | Poverty rate: 15% in tract, weighted by area overlap fraction |

Confusing extensive and intensive variables is the most common error in areal interpolation. If you sum a poverty *rate* instead of averaging it, the result is meaningless.

### Dasymetric Refinement

Simple area-weighting assumes population (or whatever variable) is uniformly distributed within each source zone — obviously wrong for most variables (nobody lives in lakes or parks). **Dasymetric mapping** improves accuracy by using auxiliary data (land use/land cover rasters, building footprints) to weight the redistribution:

- Residential areas receive more weight than industrial or water areas
- Building density can further refine within-residential allocation
- Available via the PySAL `tobler` package (area-weighted, regression-based, and hybrid methods)

### Validation

Areal interpolation introduces uncertainty. After interpolation:
- **Conservation check:** For extensive variables, verify that totals are preserved (sum of target zone values ≈ sum of source zone values)
- **Sanity check:** Compare a few target zone values against expectations from adjacent source zones
- **Document the method** and acknowledge interpolation uncertainty in limitations

---

## Spatial Weights for Regression: Practical Considerations

When using spatial weights in regression contexts (spatial lag models, spatial error models), additional considerations apply beyond those for exploratory statistics.

### Islands and Disconnected Observations

Observations with no neighbors (islands in a contiguity matrix, or isolated points beyond a distance threshold) create problems:
- They cannot have a spatial lag computed
- Many spatial regression estimators will fail or produce unreliable results

**Solutions:**
- KNN weights guarantee connectivity (every observation has k neighbors)
- Increase distance threshold to connect islands
- Remove islands from the analysis (document and justify)

### Endogeneity in Spatial Lag Models

The spatial lag of Y (Wy) is endogenous — it depends on the same Y values being estimated. This means:
- OLS is inconsistent (biased even in large samples)
- 2SLS uses spatial lags of X as instruments (WX, W²X)
- ML estimation is an alternative but requires distributional assumptions

### Spatial Correlograms for Residual Diagnostics

A spatial correlogram plots spatial autocorrelation (typically Moran's I) at increasing distance lags or neighbor orders (k=1, k=2, k=3, ...). It reveals how spatial dependence in residuals decays with distance — essential context that a single global Moran's I obscures:

- **Sharp decay** (significant at k=1, non-significant at k=2+) → local spillover or omitted variable varying at fine scale; SLX or spatial FE may suffice
- **Gradual decay** (significant through k=3 or k=4) → broader spatial process; SAR or SEM likely needed
- **Non-monotonic pattern** (significant, then not, then significant again) → possible multiple spatial scales at work; investigate whether different processes operate at different distances

### Reporting Standards

When reporting spatial regression results, always include:
- Weights specification (type, parameters, row-standardization)
- Spatial diagnostics on OLS residuals that motivated the spatial model
- Both non-spatial (OLS) and spatial model results for comparison
- Diagnostics on the spatial model's residuals (to verify the spatial correction worked)

---

## References and Further Reading

### Primary References

Rey, S.J., Arribas-Bel, D., and Wolf, L.J. (2023). *Geographic Data Science with Python*. CRC Press. https://geographicdata.science/book/

Dorman, M., Graser, A., Nowosad, J., and Lovelace, R. (2025). *Geocomputation with Python*. CRC Press. https://py.geocompx.org/

### Spatial Weights and Autocorrelation

Anselin, L. (1995). "Local Indicators of Spatial Association — LISA." *Geographical Analysis*, 27(2), 93-115.

Anselin, L. and Rey, S.J. (2014). *Modern Spatial Econometrics in Practice*. GeoDa Press.

### Interpolation and Areal Methods

Tobler, W.R. (1979). "Smooth Pycnophylactic Interpolation for Geographical Regions." *Journal of the American Statistical Association*, 74(367), 519-530.

Goodchild, M.F. and Lam, N.S. (1980). "Areal Interpolation: A Variant of the Traditional Spatial Problem." *Geo-Processing*, 1, 297-312.

### Software

Rey, S.J. et al. (2022). "The PySAL Ecosystem: Philosophy and Implementation." *Geographical Analysis*, 54(3), 467-487. https://pysal.org/
