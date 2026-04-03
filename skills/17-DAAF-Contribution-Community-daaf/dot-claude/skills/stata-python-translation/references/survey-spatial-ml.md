# Survey, Spatial, and Machine Learning: Stata to Python

Three specialized domains where Stata has varying levels of capability with Python
equivalents. Surveys (Stata `svy:` to Python `svy`), spatial analysis (Stata's
limited mapping to Python `geopandas`), and machine learning (Stata 16+ lasso/ML
features to Python `scikit-learn`). Each involves domain-specific idioms that do
not translate by simple find-and-replace.

For full Python-side API details, load the dedicated skill: `svy`, `geopandas`, or
`scikit-learn`.

> **Versions referenced:**
> Python: svy 0.13.0, geopandas 1.1.3, scikit-learn 1.8.0, PySAL (latest)
> Stata: Stata 18 (svy, spatial, lasso commands)
> See SKILL.md Section: Library Versions for the complete version table.

---

## Part A: Complex Surveys (Stata `svy:` to Python `svy`)

Stata's `svy:` prefix is the most widely used tool for design-based inference from
complex survey samples. Stata's survey capabilities are mature, well-documented,
and integrated into most estimation commands. Python's `svy` package (v0.13.0)
provides a comparable core with a different API style.

### A1. Design Specification

The fundamental difference: Stata uses a persistent `svyset` declaration that
applies to all subsequent `svy:` commands. Python requires explicitly passing
the design/sample object to every estimation call.

**Stata:**

```stata
svyset psu_id [pw=finalwgt], strata(stratum_var)
```

**Python:**

```python
import svy

design = svy.Design(psu="psu_id", stratum="stratum_var", wgt="finalwgt")
sample = svy.Sample(data=df, design=design)
```

| Aspect | Stata (`svyset`) | Python (`svy`) |
|--------|-----------------|----------------|
| Variable reference | Bare names: `svyset psu, strata(stratum)` | Strings: `psu="psu", stratum="stratum"` |
| Persistence | One `svyset` applies to all `svy:` commands | Must pass `sample` to each call |
| Weight syntax | Bracket syntax: `[pw=weight]` | Keyword: `wgt="weight"` |
| Multiple strata | `strata(var1 var2)` or interaction | Tuple: `stratum=("var1", "var2")` |
| FPC specification | `fpc(pop_size)` | `fpc="pop_size"` |
| Data type | Stata dataset | Polars DataFrame |
| Multi-stage | `svyset psu, strata(s1) || ssu, strata(s2)` | Check svy docs for multi-stage specification |

### A2. Estimation

| Stata | Python (`svy`) | Notes |
|-------|----------------|-------|
| `svy: mean income` | `sample.estimation.mean("income")` | Point estimate, SE, CI, DEFF |
| `svy: total population` | `sample.estimation.total("population")` | Population total |
| `svy: proportion employed` | `sample.estimation.prop("employed")` | Proportions per category |
| `svy: ratio expend/hh_size` | `sample.estimation.ratio(y="expend", x="hh_size")` | Ratio estimation |
| `svy: tabulate var1 var2` | `sample.estimation.prop("var1", by="var2")` | Cross-tabulation |
| `svy, over(gender): mean income` | `sample.estimation.mean("income", by="gender")` | Domain estimation |
| `svy: mean income, over(age_group)` | `sample.estimation.mean("income", by="age_group")` | Same as above |

**Domain estimation (the critical anti-pattern):**

```stata
* Stata -- CORRECT: subpop preserves full design
svy, subpop(female): mean income

* Stata -- ALSO CORRECT: over() for domain estimation
svy, over(gender): mean income
```

```python
# Python -- CORRECT: use by= parameter
sample.estimation.mean("income", by="gender")

# Python -- WRONG: filtering before estimation
# females = df.filter(pl.col("gender") == "Female")
# svy.Sample(data=females, design=design).estimation.mean("income")  # BAD: wrong SEs
```

Why this matters: subpopulation analysis must use the full sample design to
compute correct standard errors. Filtering the data before creating the sample
object produces incorrect variance estimates because it discards design information
from observations outside the subpopulation.

### A3. Regression

| Stata | Python (`svy`) | Notes |
|-------|----------------|-------|
| `svy: regress y x1 x2` | `sample.glm.fit(y="y", x=["x1", "x2"], family="gaussian")` | Survey-weighted OLS |
| `svy: logit y x1 x2` | `sample.glm.fit(y="y", x=["x1", "x2"], family="binomial")` | Logistic |
| `svy: poisson y x1 x2` | `sample.glm.fit(y="y", x=["x1", "x2"], family="poisson")` | Poisson |
| `svy: regress y i.cat x1` | `sample.glm.fit(y="y", x=[svy.Cat("cat"), "x1"], family="gaussian")` | Categorical predictor |
| `svy: regress y c.x1##i.cat` | Pre-compute interaction columns; pass to svy | No formula parsing |

**Formula interface difference:**

Stata's `svy: regress y c.x1##i.cat` uses factor variable notation to create
interactions automatically. Python's `svy` does not parse R/Stata-style formulas
-- interaction and polynomial terms must be created as columns beforehand:

```python
import polars as pl

df = df.with_columns(
    (pl.col("x1") * pl.col("x2")).alias("x1_x2"),
    (pl.col("x1") ** 2).alias("x1_sq"),
)
design = svy.Design(stratum="stratum", psu="psu", wgt="weight")
sample = svy.Sample(data=df, design=design)
model = sample.glm.fit(
    y="y",
    x=["x1", "x2", "x1_x2", "x1_sq"],
    family="gaussian",
)
```

### A4. Variance Estimation

Both ecosystems support the same variance estimation methods.

**Taylor linearization** (default in both):

```stata
svyset psu [pw=weight], strata(stratum)
* Taylor linearization is used by default
```

```python
design = svy.Design(stratum="stratum", psu="psu", wgt="weight")
sample = svy.Sample(data=df, design=design)
# Taylor linearization is used by default
```

**Replicate weights (pre-computed):**

```stata
svyset [pw=finalwgt], vce(brr) brrweight(brr_wt1-brr_wt64) fay(0.5)
```

```python
design = svy.Design(
    wgt="finalwgt",
    rep_weights="brr_wt1-brr_wt64",
    rep_type="brr",
    fay_coefficient=0.5,
)
sample = svy.Sample(data=df, design=design)
```

**Available replication methods:**

| Method | Stata `vce()` | Python `rep_type=` | Notes |
|--------|-------------|---------------------|-------|
| Bootstrap | `vce(bootstrap)` | `"bootstrap"` | Canty-Davison |
| BRR | `vce(brr)` | `"brr"` | Balanced Repeated Replication |
| Fay's BRR | `vce(brr) fay(rho)` | `"fay"` + `fay_coefficient` | Perturbed half-samples |
| Jackknife (unstratified) | `vce(jackknife)` | `"jk1"` | Delete-one |
| Jackknife (stratified) | `vce(jackknife)` | `"jkn"` | Delete-one-PSU |

### A5. Coverage Gaps

Stata's `svy:` prefix works with a much broader set of estimation commands than
Python's `svy` package currently supports:

| Capability | Stata `svy:` | Python `svy` | Gap Severity |
|-----------|-------------|--------------|-------------|
| Gaussian GLM | Yes | Yes | None |
| Binomial (logistic) | Yes | Yes | None |
| Poisson | Yes | Yes | None |
| Ordinal logistic (`svy: ologit`) | Yes | No | High -- common in social science |
| Cox survival (`svy: stcox`) | Yes | No | Medium -- specialized |
| Negative binomial (`svy: nbreg`) | Yes | No | Medium |
| Multinomial logit (`svy: mlogit`) | Yes | No | Medium |
| Quantile regression (`svy: qreg`) | Yes | No | Medium |
| Post-stratification / raking | Yes | Yes | None |
| GREG calibration | Yes | Check svy docs | Possibly partial |
| Two-phase designs (`twophase`) | Yes | No | Low -- specialized |

**When the model family is not available in Python's svy:** Fall back to R's
`survey` package via rpy2. The pattern: keep the design specification logic in
Python, cross to R only for the model fitting step, then extract results back
into Python. See the `svy` skill's regression reference for the full rpy2 bridge
pattern.

---

## Part B: Spatial Analysis (Stata Mapping to Python `geopandas`)

Stata's spatial capabilities are limited compared to both R and Python. Stata has
added mapping features incrementally (Stata 15+ for `spmap`, Stata 17+ for
`spregress`), but the ecosystem is far less mature than Python's geopandas + PySAL
stack. For spatial work, Python is actually the stronger tool.

### B1. Reading and Displaying Spatial Data

| Stata | Python (`geopandas`) | Notes |
|-------|---------------------|-------|
| `shp2dta using shapefile` | `gpd.read_file("shapefile.shp")` | Stata requires conversion to .dta first |
| `use shapefile.dta` | `gpd.read_file("file.gpkg")` | GeoPackage preferred |
| `spmap var using coords.dta` | `gdf.plot(column="var")` | Choropleth |
| `grmap` (community) | `gdf.plot()` | Community command in Stata |
| No equivalent | `gpd.read_file("file.geojson")` | Stata cannot read GeoJSON directly |
| No equivalent | `gpd.read_parquet("file.parquet")` | GeoParquet (modern format) |

**Creating from coordinates:**

```stata
* Stata -- no direct equivalent; must use shp2dta to import shapes
* or use community packages like geo2xy
```

```python
import geopandas as gpd

gdf = gpd.GeoDataFrame(
    df, geometry=gpd.points_from_xy(df["lon"], df["lat"]), crs="EPSG:4326"
)
```

### B2. Core Spatial Operations

Stata has limited built-in spatial operations. Python's geopandas provides a
comprehensive toolkit.

| Operation | Stata | Python (`geopandas`) |
|-----------|-------|---------------------|
| Reproject CRS | Not available (limited) | `gdf.to_crs(epsg=5070)` |
| Spatial join | Not built-in | `gpd.sjoin(a, b)` |
| Buffer | Not built-in | `gdf.buffer(distance)` |
| Intersection test | Not built-in | `a.intersects(b)` |
| Distance | Not built-in | `a.distance(b)` |
| Area | Not built-in | `gdf.area` |
| Centroid | Not built-in | `gdf.centroid` |
| Dissolve | Not built-in | `gdf.dissolve(by="col")` |
| Overlay | Not built-in | `gpd.overlay(a, b, how="intersection")` |

Python's spatial stack is dramatically more capable than Stata's for vector
operations. If your research requires spatial analysis beyond basic choropleth
mapping, Python is the stronger tool.

### B3. Choropleth Maps

**Stata (with spmap):**

```stata
* Requires shapefile converted to Stata format
shp2dta using counties.shp, database(countydb) coordinates(countycoord)
use countydb, clear
merge 1:1 fips using analysis_data
spmap poverty_rate using countycoord, id(_ID) ///
    fcolor(YlOrRd) clmethod(quantile) ///
    title("Poverty Rate by County")
```

**Python:**

```python
import geopandas as gpd
import matplotlib.pyplot as plt

counties = gpd.read_file("counties.gpkg")
counties = counties.merge(analysis_data, on="fips")

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

### B4. Interactive Maps

Stata has no interactive map capability. Python provides several options:

```python
# Quick interactive map (folium-based)
gdf.explore(column="poverty_rate", cmap="YlOrRd")

# Custom interactive map
import folium
m = folium.Map(location=[39.8, -98.5], zoom_start=4)
folium.GeoJson(gdf).add_to(m)
m.save("output/figures/interactive_map.html")
```

### B5. Spatial Statistics and Regression

**Stata 17+ spatial commands:**

```stata
spmatrix create contiguity W, replace
spregress y x1 x2, gs2sls dvarlag(W)    /* spatial lag model */
spregress y x1 x2, gs2sls errorlag(W)   /* spatial error model */
```

**Python (PySAL ecosystem):**

```python
from libpysal.weights import Queen
from spreg import ML_Lag, ML_Error

w = Queen.from_dataframe(gdf)
w.transform = "r"  # row-standardize

# Spatial lag model
lag = ML_Lag(y, X, w=w, name_y="y", name_x=["x1", "x2"])

# Spatial error model
err = ML_Error(y, X, w=w, name_y="y", name_x=["x1", "x2"])
```

| Stata | Python (PySAL) | Notes |
|-------|---------------|-------|
| `spmatrix create contiguity W` | `libpysal.weights.Queen.from_dataframe(gdf)` | Spatial weights |
| `spregress y x, gs2sls dvarlag(W)` | `spreg.ML_Lag(y, X, w=w)` | Spatial lag |
| `spregress y x, gs2sls errorlag(W)` | `spreg.ML_Error(y, X, w=w)` | Spatial error |
| No built-in Moran's I | `esda.Moran(y, w)` | Global spatial autocorrelation |
| No built-in LISA | `esda.Moran_Local(y, w)` | Local indicators |

Python's PySAL ecosystem (`libpysal`, `esda`, `spreg`, `pointpats`) provides
substantially more spatial statistics capability than Stata's built-in tools.

---

## Part C: Machine Learning (Stata lasso/ML to Python `scikit-learn`)

Stata has added machine learning features incrementally starting with Stata 16
(lasso, elastic net) and Stata 18 (H2O integration for random forests, gradient
boosting). However, Python's scikit-learn ecosystem is dramatically more mature
and comprehensive. ML is where Python clearly dominates Stata.

### C1. Paradigm Comparison

| Aspect | Stata (16+) | Python (`scikit-learn`) |
|--------|------------|----------------------|
| ML scope | Lasso, elastic net, limited tree-based | 100+ algorithms |
| Integration | `lasso`, `elasticnet`, `dsregress` built-in | `sklearn` + ecosystem |
| Cross-validation | Built into `lasso` command | `cross_val_score()`, `GridSearchCV` |
| Tuning | Limited (IC-based or CV built in) | `GridSearchCV`, `RandomizedSearchCV`, `BayesSearchCV` |
| Pipeline | None | `sklearn.pipeline.Pipeline` |
| Feature engineering | Manual | `ColumnTransformer`, `PolynomialFeatures` |
| Interpretation | Limited | SHAP, permutation importance, PDP |

### C2. Regularized Regression

| Stata | Python | Notes |
|-------|--------|-------|
| `lasso linear y x1-x20` | `Lasso(alpha=lambda_val).fit(X, y)` | L1 regularization |
| `elasticnet linear y x1-x20` | `ElasticNet(alpha=a, l1_ratio=r).fit(X, y)` | L1 + L2 |
| `lasso linear y x1-x20, selection(cv)` | `LassoCV(cv=5).fit(X, y)` | CV-selected lambda |
| `lasso linear y x1-x20, selection(bic)` | Manual: fit over grid, compute BIC | No built-in IC selection |
| `dsregress y x1, controls(x2-x20)` | `DoubleML` or manual cross-fitting | Double selection / DML |
| `poregress y x1, controls(x2-x20)` | `DoubleML.PartiallyLinearModel()` | Post-regularization |

**Stata's `lasso` vs scikit-learn's `Lasso`:**

```stata
* Stata -- built-in cross-validation, coefficient path
lasso linear wage education experience age i.industry, ///
    selection(cv) folds(10)
```

```python
from sklearn.linear_model import LassoCV
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline

pipe = Pipeline([
    ("scaler", StandardScaler()),
    ("lasso", LassoCV(cv=10, random_state=42)),
])
pipe.fit(X, y)

# Selected alpha (lambda)
print(f"Best alpha: {pipe['lasso'].alpha_}")
# Non-zero coefficients
coefs = pipe["lasso"].coef_
print(f"Non-zero features: {(coefs != 0).sum()} of {len(coefs)}")
```

### C3. Tree-Based Methods

Stata 18+ integrates with H2O for random forests and gradient boosting, but the
integration is limited compared to Python's native ecosystem.

| Stata (18+) | Python | Notes |
|-------------|--------|-------|
| `rf y x1-x20` (via H2O) | `RandomForestClassifier().fit(X, y)` | Direct class |
| `gbt y x1-x20` (via H2O) | `GradientBoostingClassifier().fit(X, y)` | Direct class |
| Limited tuning options | `GridSearchCV(pipe, param_grid)` | Comprehensive |
| No equivalent | `HistGradientBoostingClassifier()` | Fast, handles missing values |
| No equivalent | `XGBClassifier()` (xgboost) | Industry standard |

```python
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.model_selection import GridSearchCV

# Random forest with tuning
param_grid = {
    "n_estimators": [100, 500],
    "max_depth": [5, 10, None],
    "max_features": ["sqrt", "log2"],
}
rf = RandomForestClassifier(random_state=42)
search = GridSearchCV(rf, param_grid, cv=5, scoring="accuracy")
search.fit(X_train, y_train)
```

### C4. Preprocessing and Pipelines

Stata has no concept of preprocessing pipelines. Each step is a separate manual
operation. Python's scikit-learn provides composable pipelines:

```python
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.impute import SimpleImputer

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

# Full pipeline: preprocessing + model
pipe = Pipeline([
    ("preprocessor", preprocessor),
    ("classifier", RandomForestClassifier(n_estimators=500, random_state=42)),
])
pipe.fit(X_train, y_train)
```

### C5. Unsupervised Learning

Stata has minimal unsupervised learning capabilities. Python's scikit-learn covers
the full spectrum:

| Stata | Python | Notes |
|-------|--------|-------|
| `cluster kmeans` | `KMeans(n_clusters=k).fit(X)` | K-means |
| `cluster wardslinkage` | `AgglomerativeClustering(n_clusters=k).fit(X)` | Hierarchical |
| No equivalent | `DBSCAN(eps=eps).fit(X)` | Density-based |
| `pca` | `PCA(n_components=k).fit_transform(X)` | Principal components |
| No equivalent | `TSNE(perplexity=30).fit_transform(X)` | Visualization |
| No equivalent | `umap.UMAP().fit_transform(X)` | Manifold learning |
| `factor` | `FactorAnalysis(n_components=k).fit(X)` | Factor analysis |

**PCA comparison:**

```stata
* Stata
pca x1 x2 x3 x4 x5
screeplot
predict pc1 pc2, score
```

```python
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA

X_scaled = StandardScaler().fit_transform(X)
pca = PCA(n_components=5).fit(X_scaled)
print(pca.explained_variance_ratio_)    # proportion of variance
X_pcs = pca.transform(X_scaled)         # score matrix
```

### C6. Model Evaluation

| Stata | Python | Notes |
|-------|--------|-------|
| Limited built-in metrics | `accuracy_score(y_true, y_pred)` | From `sklearn.metrics` |
| No equivalent | `classification_report(y_true, y_pred)` | Full metrics summary |
| No equivalent | `confusion_matrix(y_true, y_pred)` | Confusion matrix |
| No equivalent | `roc_auc_score(y_true, y_prob)` | ROC AUC |
| Limited CV | `cross_val_score(model, X, y, cv=5)` | K-fold cross-validation |
| No equivalent | `GridSearchCV(model, params, cv=5)` | Grid search + CV |

### C7. Feature Importance and Interpretation

Stata has no built-in model interpretation tools. Python provides several:

```python
# Feature importance (tree-based models)
importances = model.feature_importances_

# Permutation importance (model-agnostic)
from sklearn.inspection import permutation_importance
perm = permutation_importance(model, X_test, y_test, n_repeats=10)

# SHAP values
import shap
explainer = shap.Explainer(model)
shap_values = explainer(X_test)
shap.summary_plot(shap_values, X_test)

# Partial dependence plots
from sklearn.inspection import PartialDependenceDisplay
PartialDependenceDisplay.from_estimator(model, X_train, features=[0, 1])
```

---

## Summary of Coverage Gaps

| Domain | Gap | Workaround |
|--------|-----|-----------|
| Survey | Ordinal logistic, Cox survival, negative binomial | rpy2 bridge to R `survey` |
| Survey | svy formula interface (no factor variable notation) | Pre-compute interaction columns |
| Survey | Persistent `svyset` | Pass `sample` object explicitly |
| Spatial | Stata has limited vector operations | Use geopandas (much stronger) |
| Spatial | Stata has limited spatial statistics | Use PySAL (much stronger) |
| ML | Stata's ML scope is very limited | scikit-learn covers everything |
| ML | Stata has no preprocessing pipelines | sklearn Pipeline + ColumnTransformer |
| ML | Stata has no model interpretation tools | SHAP, permutation importance, PDP |

**The honest assessment:** For surveys, Stata and Python are roughly comparable,
with Stata having broader model family support but Python catching up. For spatial
analysis and machine learning, Python is substantially more capable than Stata.
Stata users moving to Python gain significant new capabilities in these domains.

---

> **Sources:** svy package documentation (svylab.com/docs/svy/, accessed
> 2026-03-28); Stata Survey Data Reference Manual (stata.com/manuals/svy.pdf,
> accessed 2026-03-28); Lumley, *Complex Surveys: A Guide to Analysis Using R*
> (Wiley, 2010); geopandas documentation (geopandas.org, accessed 2026-03-28);
> Stata Spatial Reference Manual (stata.com/manuals, accessed 2026-03-28);
> scikit-learn documentation (scikit-learn.org, accessed 2026-03-28); PySAL
> documentation (pysal.org, accessed 2026-03-28); Stata Lasso Reference Manual
> (stata.com/manuals, accessed 2026-03-28)
