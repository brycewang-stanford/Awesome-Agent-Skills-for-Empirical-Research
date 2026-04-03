# Survey, Spatial, and Machine Learning: R to Python

Three specialized domains where R has strong, mature packages with Python equivalents of
varying fidelity. Surveys (R `survey` to Python `svy`), spatial analysis (R `sf` to Python
`geopandas`), and machine learning (R `tidymodels`/`caret` to Python `scikit-learn`) each
involve domain-specific idioms that do not translate by simple find-and-replace. This
reference provides side-by-side mappings, highlights coverage gaps, and flags the places
where the Python ecosystem requires a different mental model.

For full Python-side API details, load the dedicated skill: `svy`, `geopandas`, or
`scikit-learn`.

> **Versions referenced:**
> Python: svy 0.13.0, geopandas 1.1.3, scikit-learn 1.8.0
> R: survey 4.5, sf 1.1-0, terra 1.9-11, tidymodels 1.4.1, caret 7.0-1
> See SKILL.md § Library Versions for the complete version table.

---

## Part A: Complex Surveys (R `survey` to Python `svy`)

R's `survey` package (Thomas Lumley) is the gold standard for design-based inference from
complex samples. Python's `svy` (v0.13.0) provides a comparable core, with some model
family gaps that require an rpy2 bridge back to R.

### A1. Design Specification

The fundamental difference: R uses a formula interface with `~` for variable specification;
Python uses keyword string arguments.

**R:**

```r
library(survey)
des <- svydesign(
  ids     = ~psu,
  strata  = ~stratum,
  weights = ~weight,
  data    = df,
  nest    = TRUE
)
```

**Python:**

```python
import svy

design = svy.Design(stratum="stratum", psu="psu", wgt="weight")
sample = svy.Sample(data=df, design=design)
```

Key differences:

| Aspect | R (`survey`) | Python (`svy`) |
|--------|-------------|----------------|
| Variable reference | Formula: `~varname` | String: `"varname"` |
| Design + data binding | Single `svydesign()` call | Two-step: `Design()` then `Sample()` |
| Multiple strata | `~interaction(var1, var2)` | Tuple: `stratum=("var1", "var2")` |
| FPC specification | `fpc = ~pop_size` | `fpc="pop_size"` |
| Data type | R data.frame | Polars DataFrame |
| Nest flag | `nest = TRUE` | Handled implicitly |

### A2. Estimation

| R (`survey`) | Python (`svy`) | Notes |
|-------------|----------------|-------|
| `svymean(~x, design)` | `sample.estimation.mean("x")` | Point estimate, SE, CI, DEFF |
| `svytotal(~x, design)` | `sample.estimation.total("x")` | Population total |
| `svymean(~factor_var, design)` | `sample.estimation.prop("factor_var")` | Proportions per category |
| `svyby(~x, ~group, design, svymean)` | `sample.estimation.mean("x", by="group")` | Domain estimation |
| `svyratio(~num, ~denom, design)` | `sample.estimation.ratio(y="num", x="denom")` | Ratio estimation with proper covariance |
| `svyquantile(~x, design, quantiles=0.5)` | `sample.estimation.median("x")` | Median; for other quantiles see below |
| `svytable(~x + y, design)` | `sample.estimation.prop("x", by="y")` | Cross-tabulation (weighted counts) |
| `svyvar(~x, design)` | Not a standalone method | Compute from SE: `var = SE^2 * n` |

**Quantile estimation at arbitrary points:**

```r
# R
svyquantile(~income, design, quantiles = c(0.25, 0.5, 0.75))
```

```python
# Python — check svy docs for exact quantile API
# Median is directly available:
result = sample.estimation.median("income")
```

**Domain estimation — the critical anti-pattern:**

```r
# R — CORRECT: domain estimation preserves full design
svyby(~income, ~gender, design, svymean)

# R — WRONG: subsetting before estimation
svymean(~income, subset(design, gender == "Female"))
# (R does allow subset() on designs, but it still preserves design structure internally)
```

```python
# Python — CORRECT: use by= parameter
sample.estimation.mean("income", by="gender")

# Python — WRONG: pre-filtering data
# females = df.filter(pl.col("gender") == "Female")
# svy.Sample(data=females, design=design).estimation.mean("income")  # BAD: wrong SEs
```

### A3. Regression

| R (`survey`) | Python (`svy`) | Notes |
|-------------|----------------|-------|
| `svyglm(y ~ x1 + x2, design, family=gaussian())` | `sample.glm.fit(y="y", x=["x1", "x2"], family="gaussian")` | Linear regression |
| `svyglm(y ~ x1 + x2, design, family=binomial())` | `sample.glm.fit(y="y", x=["x1", "x2"], family="binomial")` | Logistic regression |
| `svyglm(y ~ x1 + x2, design, family=poisson())` | `sample.glm.fit(y="y", x=["x1", "x2"], family="poisson")` | Poisson regression |
| `svyglm(y ~ factor(x), design, ...)` | `sample.glm.fit(y="y", x=[svy.Cat("x")], ...)` | Categorical predictor |
| `svyolr(y ~ x1 + x2, design)` | NOT AVAILABLE | Ordinal logistic -- use rpy2 bridge |
| `svycoxph(Surv(t, d) ~ x, design)` | NOT AVAILABLE | Cox proportional hazards -- use rpy2 bridge |
| `svyglm(..., family=quasibinomial())` | NOT AVAILABLE | Quasi-families -- use rpy2 bridge |
| `svyglm(..., family=negative.binomial())` | NOT AVAILABLE | Negative binomial -- use rpy2 bridge |

**Formula interface difference:**

```r
# R — formula with interactions and polynomial terms
svyglm(y ~ x1 * x2 + I(x1^2), design, family = gaussian())
```

```python
# Python — explicit variable list; create interaction/polynomial columns beforehand
# svy does not parse R-style formulas
import polars as pl
df = df.with_columns(
    (pl.col("x1") * pl.col("x2")).alias("x1_x2"),
    (pl.col("x1") ** 2).alias("x1_sq"),
)
design = svy.Design(stratum="stratum", psu="psu", wgt="weight")
sample = svy.Sample(data=df, design=design)
model = sample.glm.fit(y="y", x=["x1", "x2", "x1_x2", "x1_sq"], family="gaussian")
```

### A4. Variance Estimation

Both ecosystems support the same variance estimation methods; the setup differs.

**Taylor linearization** (default in both):

```r
# R — Taylor is the default when design variables are provided
des <- svydesign(ids = ~psu, strata = ~stratum, weights = ~weight, data = df)
```

```python
# Python — Taylor is the default when design variables are provided
design = svy.Design(stratum="stratum", psu="psu", wgt="weight")
sample = svy.Sample(data=df, design=design)
```

**Replicate weights (pre-computed):**

```r
# R — BRR replicate weights provided in data
des_rep <- svrepdesign(
  data       = df,
  weights    = ~finalwgt,
  repweights = "brr_wt[0-9]+",
  type       = "BRR"
)
```

```python
# Python — BRR replicate weights
design = svy.Design(
    wgt="finalwgt",
    rep_weights="brr_wt1-brr_wt64",
    rep_type="brr"
)
sample = svy.Sample(data=df, design=design)
```

**Converting Taylor design to replicate weights:**

```r
# R — create bootstrap replicates from a Taylor design
des_boot <- as.svrepdesign(des, type = "bootstrap", replicates = 500)
```

```python
# Python — svy handles this via the Design specification
# Specify rep_type and replications when creating the design
# [VERIFY API] — check svy docs for exact conversion syntax
```

**Available replication methods:**

| Method | R `type =` | Python `rep_type =` | Notes |
|--------|-----------|---------------------|-------|
| Bootstrap | `"bootstrap"` | `"bootstrap"` | Canty-Davison |
| BRR | `"BRR"` | `"brr"` | Balanced Repeated Replication |
| Fay's BRR | `"Fay"` | `"fay"` | Perturbed half-samples; set `fay.rho`/`fay_coefficient` |
| Jackknife (unstratified) | `"JK1"` | `"jk1"` | Delete-one jackknife |
| Jackknife (stratified) | `"JKn"` | `"jkn"` | Delete-one-PSU; most common |
| Subbootstrap | `"subbootstrap"` | Not confirmed | Rao-Wu (n-1) bootstrap |

### A5. Coverage Gaps and the rpy2 Bridge

R's `survey` package covers a substantially wider range of models than Python's `svy`:

| Capability | R `survey` | Python `svy` | Gap Severity |
|-----------|-----------|--------------|-------------|
| Gaussian GLM | Yes | Yes | None |
| Binomial (logistic) | Yes | Yes | None |
| Poisson | Yes | Yes | None |
| Ordinal logistic (`svyolr`) | Yes | No | High -- common in social science |
| Cox survival (`svycoxph`) | Yes | No | Medium -- specialized use |
| Negative binomial | Yes | No | Medium |
| Quasi-families | Yes | No | Low -- rarely needed |
| Two-phase designs (`twophase`) | Yes | No | Low -- specialized |
| Post-stratification / raking calibration | Yes | Yes | None |
| GREG calibration | Yes | Check svy docs | Possibly partial |

**When to use the rpy2 bridge:** If the model family is not `"gaussian"`, `"binomial"`, or
`"poisson"`, fall back to R's `survey` package via rpy2. The pattern:

```python
import rpy2.robjects as ro
from rpy2.robjects.packages import importr
from rpy2.robjects import pandas2ri

pandas2ri.activate()

survey_r = importr("survey")

# Pass design variables and data to R, set up svydesign, then call svyolr/svycoxph
# See svy skill -> regression.md for the full rpy2 bridge pattern
```

This is an acceptable fallback — the design specification logic stays in Python, and only
the model fitting crosses to R. Results come back as R objects that can be extracted.

---

## Part B: Spatial Data (R `sf` to Python `geopandas`)

R's `sf` (Simple Features) package provides a tidy, consistent interface for vector spatial
data. Python's `geopandas` (v1.x) offers equivalent functionality built on shapely 2.0 and
pyogrio, with a different API style: R uses standalone functions (`st_*()`), while Python
uses methods and properties on GeoDataFrame/GeoSeries objects.

### B1. Reading and Writing

| R (`sf`) | Python (`geopandas`) | Notes |
|---------|---------------------|-------|
| `st_read("file.shp")` | `gpd.read_file("file.shp")` | Shapefile |
| `st_read("file.gpkg")` | `gpd.read_file("file.gpkg")` | GeoPackage (preferred format) |
| `st_read("file.geojson")` | `gpd.read_file("file.geojson")` | GeoJSON |
| `st_write(df, "file.gpkg")` | `gdf.to_file("file.gpkg")` | Write to GeoPackage |
| `st_read("file.gpkg", layer="name")` | `gpd.read_file("file.gpkg", layer="name")` | Specific layer |
| `sfarrow::st_read_parquet("f.parquet")` | `gpd.read_parquet("f.parquet")` | GeoParquet |
| `sfarrow::st_write_parquet(df, "f.parquet")` | `gdf.to_parquet("f.parquet")` | Write GeoParquet |

**Creating from coordinates:**

```r
# R — create sf object from lat/lon columns
library(sf)
pts <- st_as_sf(df, coords = c("lon", "lat"), crs = 4326)
```

```python
# Python — create GeoDataFrame from lat/lon columns
import geopandas as gpd
gdf = gpd.GeoDataFrame(
    df, geometry=gpd.points_from_xy(df["lon"], df["lat"]), crs="EPSG:4326"
)
```

### B2. Core Operations

| R (`sf`) | Python (`geopandas`) | Notes |
|---------|---------------------|-------|
| `st_transform(df, crs)` | `gdf.to_crs(crs)` | CRS reprojection |
| `st_join(a, b)` | `gpd.sjoin(a, b)` | Spatial join (default: intersects) |
| `st_join(a, b, join=st_nearest_feature)` | `gpd.sjoin_nearest(a, b)` | Nearest-feature join |
| `st_buffer(geom, dist)` | `gdf.buffer(dist)` | Buffer (in CRS units) |
| `st_intersects(a, b)` | `a.intersects(b)` | Returns boolean Series |
| `st_within(a, b)` | `a.within(b)` | Returns boolean Series |
| `st_contains(a, b)` | `a.contains(b)` | Returns boolean Series |
| `st_distance(a, b)` | `a.distance(b)` | Pairwise distance |
| `st_area(geom)` | `gdf.area` | **Property**, not method |
| `st_length(geom)` | `gdf.length` | **Property** |
| `st_centroid(geom)` | `gdf.centroid` | **Property** |
| `st_union(geom)` | `gdf.union_all()` | Was `unary_union`; renamed in geopandas 1.x |
| `st_intersection(a, b)` | `gpd.overlay(a, b, how="intersection")` | Overlay, not predicate test |
| `st_difference(a, b)` | `gpd.overlay(a, b, how="difference")` | Set difference |
| `st_sym_difference(a, b)` | `gpd.overlay(a, b, how="symmetric_difference")` | Symmetric difference |
| `st_bbox(geom)` | `gdf.total_bounds` | Returns array: [minx, miny, maxx, maxy] |
| `st_crs(df)` | `gdf.crs` | Check CRS |
| `st_set_crs(df, 4326)` | `gdf.set_crs("EPSG:4326")` | Set CRS (no reprojection) |
| `st_is_valid(geom)` | `gdf.is_valid` | Check geometry validity |
| `st_make_valid(geom)` | `gdf.make_valid()` | Fix invalid geometries |
| `st_dissolve()` / `group_by() %>% summarise()` | `gdf.dissolve(by="col")` | Dissolve by attribute |
| `st_crop(df, bbox)` | `gpd.clip(gdf, mask)` | Clip to extent |

**Critical API difference:** R's `st_*` functions are standalone functions that take an sf
object as the first argument (pipe-friendly). Python's equivalents are either methods on the
GeoDataFrame/GeoSeries, properties (no parentheses), or module-level functions in `gpd`.

```r
# R — pipe-friendly standalone functions
library(sf)
library(dplyr)
result <- counties %>%
  st_transform(5070) %>%
  st_buffer(1000) %>%
  st_join(points)
```

```python
# Python — method chaining on GeoDataFrame (partial)
import geopandas as gpd
counties_proj = counties.to_crs(epsg=5070)
counties_buf = counties_proj.buffer(1000)
# sjoin is a module-level function, not a method
result = gpd.sjoin(gpd.GeoDataFrame(geometry=counties_buf), points)
```

### B3. Mapping and Visualization

R has two major spatial visualization packages; Python has a more fragmented landscape.

| R | Python | Notes |
|---|--------|-------|
| `ggplot2::geom_sf()` | No direct equivalent | plotnine does NOT have `geom_sf()` |
| `tmap::tm_shape() + tm_fill()` | `gdf.plot(column="var")` | Closest equivalent for choropleths |
| `tmap::tm_shape() + tm_borders()` | `gdf.boundary.plot()` | Boundaries only |
| `mapview::mapview(gdf)` | `gdf.explore()` | Interactive map (folium-based) |
| `leaflet::leaflet()` | `folium.Map()` | Direct folium for custom interactive maps |

**Choropleth comparison:**

```r
# R (tmap)
library(tmap)
tm_shape(counties) +
  tm_fill("poverty_rate", palette = "YlOrRd", style = "quantile") +
  tm_borders(alpha = 0.3) +
  tm_layout(title = "Poverty Rate by County")
```

```python
# Python (geopandas + matplotlib)
import matplotlib.pyplot as plt

fig, ax = plt.subplots(1, 1, figsize=(12, 8))
counties.plot(
    column="poverty_rate",
    cmap="YlOrRd",
    scheme="quantiles",         # requires mapclassify
    legend=True,
    edgecolor="gray",
    linewidth=0.3,
    ax=ax,
)
ax.set_title("Poverty Rate by County")
ax.set_axis_off()
plt.tight_layout()
plt.savefig("output/figures/poverty_map.png", dpi=300, bbox_inches="tight")
```

```r
# R (ggplot2 + geom_sf)
library(ggplot2)
ggplot(counties) +
  geom_sf(aes(fill = poverty_rate), color = "gray70", linewidth = 0.2) +
  scale_fill_viridis_c() +
  theme_minimal() +
  labs(title = "Poverty Rate by County")
```

**Gap: plotnine lacks `geom_sf()`.** The primary Python mapping tool is `gdf.plot()` via
matplotlib. For interactive maps, use `gdf.explore()` (folium). For publication-quality
thematic maps, `gdf.plot()` with mapclassify classification schemes is the standard
approach. Cartopy can be used for maps requiring custom projections and coastlines.

### B4. Raster Data

Raster handling differs substantially between R and Python. R has a unified `terra` package;
Python splits the work across `rasterio` (low-level I/O), `xarray`/`rioxarray`
(multidimensional arrays), and `rasterstats`/`exactextract` (zonal statistics).

| R (`terra`) | Python | Notes |
|------------|--------|-------|
| `rast("file.tif")` | `rasterio.open("file.tif")` | Read raster |
| `rast("file.tif")` | `rioxarray.open_rasterio("file.tif")` | Read as xarray DataArray |
| `extract(raster, points)` | `rasterstats.point_query(gdf, "file.tif")` | Extract at points |
| `extract(raster, polygons, fun=mean)` | `rasterstats.zonal_stats(gdf, "file.tif", stats="mean")` | Zonal statistics |
| `crop(raster, extent)` | `rasterio` + mask/crop operations | More manual in Python |
| `writeRaster(r, "out.tif")` | `rasterio` write with profile | Requires explicit metadata |
| `plot(raster)` | `rioxarray` + matplotlib | Less integrated |

Raster work is less common in DAAF's typical social science workflows, which focus on
tabular and vector data. When needed, the `geopandas` skill's `raster-integration.md`
reference covers the Python-side patterns in detail.

### B5. Spatial Statistics

| R | Python | Notes |
|---|--------|-------|
| `spdep::moran.test()` | `esda.Moran()` (PySAL) | Global Moran's I |
| `spdep::localmoran()` | `esda.Moran_Local()` (PySAL) | LISA |
| `spdep::nb2listw()` | `libpysal.weights.Queen()` | Spatial weights |
| `spatialreg::lagsarlm()` | `spreg.ML_Lag()` (PySAL) | Spatial lag model |
| `spatialreg::errorsarlm()` | `spreg.ML_Error()` (PySAL) | Spatial error model |
| `spatstat::Kest()` | `pointpats.K()` (PySAL) | Ripley's K function |

The PySAL ecosystem (`libpysal`, `esda`, `spreg`, `pointpats`) provides comprehensive
spatial statistics in Python. See the `geopandas` skill's `pysal-spatial-stats.md` for
full API details.

---

## Part C: Machine Learning (R `tidymodels`/`caret` to Python `scikit-learn`)

R's ML ecosystem has two generations: `caret` (legacy, unified interface) and `tidymodels`
(modern, tidyverse-integrated). Python's `scikit-learn` predates both and uses an imperative
`fit()`/`predict()`/`transform()` API rather than a declarative recipe/workflow pipeline.

### C1. Paradigm Comparison

| Aspect | R (`tidymodels`) | Python (`scikit-learn`) |
|--------|-----------------|----------------------|
| Philosophy | Declarative: specify *what*, the framework handles *how* | Imperative: call methods in sequence |
| Preprocessing | `recipe()` with `step_*()` functions | `Pipeline` with transformer objects |
| Model spec | `parsnip` model spec + engine | Direct estimator instantiation |
| Tuning | `tune_grid()` / `tune_bayes()` over workflow | `GridSearchCV` / `RandomizedSearchCV` wrapping estimator |
| Cross-validation | `rsample::vfold_cv()` creates folds | `cross_val_score()` or CV built into search |
| Data | Tibbles / data.frames throughout | numpy arrays or pandas DataFrames |

**Workflow comparison:**

```r
# R (tidymodels) — declarative pipeline
library(tidymodels)

# 1. Define recipe (preprocessing)
rec <- recipe(outcome ~ ., data = train_data) %>%
  step_normalize(all_numeric_predictors()) %>%
  step_dummy(all_nominal_predictors()) %>%
  step_impute_median(all_numeric_predictors())

# 2. Define model specification
rf_spec <- rand_forest(mtry = tune(), trees = 500) %>%
  set_engine("ranger") %>%
  set_mode("classification")

# 3. Bundle into workflow
wf <- workflow() %>%
  add_recipe(rec) %>%
  add_model(rf_spec)

# 4. Tune
folds <- vfold_cv(train_data, v = 5)
results <- tune_grid(wf, resamples = folds, grid = 20)
```

```python
# Python (scikit-learn) — imperative pipeline
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.impute import SimpleImputer
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import GridSearchCV, StratifiedKFold

# 1. Define preprocessing
numeric_transformer = Pipeline([
    ("imputer", SimpleImputer(strategy="median")),
    ("scaler", StandardScaler()),
])
categorical_transformer = Pipeline([
    ("encoder", OneHotEncoder(handle_unknown="ignore")),
])
preprocessor = ColumnTransformer([
    ("num", numeric_transformer, numeric_features),
    ("cat", categorical_transformer, categorical_features),
])

# 2. Define full pipeline (preprocessing + model)
pipe = Pipeline([
    ("preprocessor", preprocessor),
    ("classifier", RandomForestClassifier(n_estimators=500, random_state=42)),
])

# 3. Tune
param_grid = {"classifier__max_features": [5, 10, 15, 20]}
cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)
search = GridSearchCV(pipe, param_grid, cv=cv, scoring="accuracy")
search.fit(X_train, y_train)
```

### C2. Model Training

| R | Python | Notes |
|---|--------|-------|
| `parsnip::rand_forest() %>% set_engine("ranger")` | `RandomForestClassifier()` / `RandomForestRegressor()` | |
| `parsnip::logistic_reg()` | `LogisticRegression()` | |
| `parsnip::linear_reg()` | `Ridge()` / `Lasso()` / `ElasticNet()` | scikit-learn separates by regularization type |
| `parsnip::boost_tree() %>% set_engine("xgboost")` | `GradientBoostingClassifier()` or `HistGradientBoostingClassifier()` | Or `XGBClassifier()` from xgboost |
| `parsnip::svm_rbf()` | `SVC(kernel="rbf")` | |
| `parsnip::nearest_neighbor()` | `KNeighborsClassifier()` | |
| `parsnip::decision_tree()` | `DecisionTreeClassifier()` | |
| `caret::train(y ~ x, method = "rf")` | `RandomForestClassifier().fit(X, y)` | caret wraps many models behind one interface |

**Key mental model shift:** In tidymodels, you specify a model *abstractly* (e.g.,
`rand_forest()`), then bind it to an engine and mode. In scikit-learn, you directly
instantiate the concrete estimator class. There is no abstraction layer between "model
type" and "implementation" -- you choose the class directly.

### C3. Preprocessing

| R (`recipes`) | Python (`sklearn.preprocessing`) | Notes |
|--------------|--------------------------------|-------|
| `step_normalize(all_numeric_predictors())` | `StandardScaler()` | Zero mean, unit variance |
| `step_scale(all_numeric_predictors())` | `MinMaxScaler()` or `MaxAbsScaler()` | Depends on desired range |
| `step_dummy(all_nominal_predictors())` | `OneHotEncoder(drop="first")` | Drop first for same as R default |
| `step_impute_median(all_numeric_predictors())` | `SimpleImputer(strategy="median")` | |
| `step_impute_knn(all_numeric_predictors())` | `KNNImputer()` | |
| `step_log(var)` | `FunctionTransformer(np.log)` | Or create column manually |
| `step_interact(~ var1:var2)` | `PolynomialFeatures(interaction_only=True)` | Or create manually |
| `step_pca(all_numeric_predictors(), num_comp=5)` | `PCA(n_components=5)` | Within a Pipeline |
| `step_corr(all_numeric_predictors(), threshold=0.9)` | Manual: compute correlation matrix, drop | No direct equivalent |
| `step_zv()` | `VarianceThreshold()` | Remove zero-variance features |

**Column selection difference:** R recipes use tidy selectors (`all_numeric_predictors()`,
`starts_with("x")`). scikit-learn uses `ColumnTransformer` with explicit column lists or
`make_column_selector()`:

```python
from sklearn.compose import make_column_selector

preprocessor = ColumnTransformer([
    ("num", StandardScaler(), make_column_selector(dtype_include="number")),
    ("cat", OneHotEncoder(), make_column_selector(dtype_include="object")),
])
```

### C4. Unsupervised Learning

| R | Python | Notes |
|---|--------|-------|
| `kmeans(x, centers = k)` | `KMeans(n_clusters=k).fit(X)` | Set `n_init=10, random_state=42` |
| `hclust(dist(x))` | `AgglomerativeClustering(n_clusters=k).fit(X)` | |
| `dbscan::dbscan(x, eps, minPts)` | `DBSCAN(eps=eps, min_samples=minPts).fit(X)` | |
| `mclust::Mclust(x)` | `GaussianMixture(n_components=k).fit(X)` | BIC selection: loop over k |
| `prcomp(x, scale. = TRUE)` | `PCA(n_components=k).fit_transform(StandardScaler().fit_transform(X))` | Scale first in Python |
| `Rtsne::Rtsne(x, perplexity=30)` | `TSNE(perplexity=30).fit_transform(X)` | Visualization only |
| `umap::umap(x)` | `umap.UMAP().fit_transform(X)` | From umap-learn package |
| `factanal(x, factors=k)` | No direct equivalent | Use `FactorAnalysis(n_components=k)` from sklearn |
| `NbClust::NbClust()` | Manual: silhouette + elbow + gap | No single convenience function |

**PCA comparison in detail:**

```r
# R
pca <- prcomp(X, center = TRUE, scale. = TRUE)
summary(pca)              # proportion of variance explained
pca$rotation              # loadings
pca$x                     # scores (transformed data)
biplot(pca)               # biplot visualization
```

```python
# Python
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA

X_scaled = StandardScaler().fit_transform(X)
pca = PCA(n_components=5).fit(X_scaled)
print(pca.explained_variance_ratio_)   # proportion of variance explained
print(pca.components_)                 # loadings (transposed relative to R)
X_transformed = pca.transform(X_scaled)  # scores
```

Note: R's `prcomp()$rotation` gives loadings as columns; scikit-learn's `pca.components_`
gives them as rows. Transpose when comparing.

### C5. Model Evaluation

| R | Python | Notes |
|---|--------|-------|
| `caret::confusionMatrix(pred, truth)` | `confusion_matrix(y_true, y_pred)` | From `sklearn.metrics` |
| `yardstick::accuracy(data, truth, estimate)` | `accuracy_score(y_true, y_pred)` | |
| `yardstick::roc_auc(data, truth, .pred_class)` | `roc_auc_score(y_true, y_prob)` | Python uses predicted probabilities |
| `yardstick::f_meas(data, truth, estimate)` | `f1_score(y_true, y_pred)` | |
| `yardstick::metrics(data, truth, estimate)` | `classification_report(y_true, y_pred)` | Returns formatted text summary |
| `rsample::vfold_cv(data, v = 5)` | `StratifiedKFold(n_splits=5)` or `cross_val_score(model, X, y, cv=5)` | |
| `tune::tune_grid(wf, resamples, grid)` | `GridSearchCV(pipe, param_grid, cv=5)` | |
| `tune::tune_bayes(wf, resamples)` | `BayesSearchCV()` (scikit-optimize) | Not in core scikit-learn |
| `rsample::bootstraps(data, times=100)` | Manual or `cross_val_score(cv=ShuffleSplit())` | |

**Cross-validation comparison:**

```r
# R (tidymodels)
folds <- vfold_cv(train_data, v = 10, strata = outcome)
results <- fit_resamples(wf, resamples = folds)
collect_metrics(results)
```

```python
# Python (scikit-learn)
from sklearn.model_selection import cross_val_score, StratifiedKFold

cv = StratifiedKFold(n_splits=10, shuffle=True, random_state=42)
scores = cross_val_score(pipe, X_train, y_train, cv=cv, scoring="accuracy")
print(f"Mean accuracy: {scores.mean():.3f} (+/- {scores.std():.3f})")
```

### C6. Feature Importance and Interpretation

| R | Python | Notes |
|---|--------|-------|
| `vip::vip(model)` | `model.feature_importances_` + manual plot | Tree-based models |
| `vip::vi(model)` | `permutation_importance(model, X, y)` | Model-agnostic |
| `DALEX::explain()` | `shap.Explainer(model)` | SHAP values |
| `pdp::partial(model, pred.var)` | `PartialDependenceDisplay.from_estimator()` | PDP |
| `iml::FeatureEffect$new()` | `shap.plots.scatter()` | Individual feature effects |

See the `scikit-learn` skill's `interpretation.md` for full SHAP and permutation importance
patterns.

---

## Summary of Coverage Gaps

| Domain | Gap | Workaround |
|--------|-----|-----------|
| Survey | Ordinal logistic, Cox survival, negative binomial | rpy2 bridge to R `survey` |
| Survey | svy formula interface (no `~` syntax) | Pre-compute interaction/polynomial columns |
| Spatial | plotnine lacks `geom_sf()` | Use `gdf.plot()` (matplotlib) |
| Spatial | `terra` raster -- no single equivalent | `rasterio` + `rioxarray` + `rasterstats` |
| ML | `NbClust` (all-in-one cluster count) | Manual loop: silhouette, elbow, gap |
| ML | `caret`'s 200+ model `method` strings | Direct class instantiation in scikit-learn |
| ML | `recipes` tidy selectors | `ColumnTransformer` + `make_column_selector()` |

---

> **Sources:** Lumley, *Complex Surveys: A Guide to Analysis Using R* (2010);
> Pebesma, *sf: Simple Features for R* (r-spatial.github.io/sf/, accessed 2026-03-28);
> Kuhn & Silge, *Tidy Modeling with R* (2022);
> svy documentation (svylab.com/docs/svy/, accessed 2026-03-28);
> geopandas documentation (geopandas.org, accessed 2026-03-28);
> scikit-learn documentation (scikit-learn.org, accessed 2026-03-28)
