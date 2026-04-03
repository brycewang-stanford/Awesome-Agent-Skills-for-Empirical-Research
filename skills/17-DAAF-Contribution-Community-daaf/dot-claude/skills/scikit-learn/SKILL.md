---
name: scikit-learn
description: >-
  Machine learning: clustering, PCA/t-SNE/UMAP, classification, prediction regression (Ridge/Lasso/ensemble), cross-validation, Pipelines. For unsupervised analysis, classification, or prediction. For econometric regression use pyfixest/statsmodels.
metadata:
  audience: research-coders
  domain: python-library
  library-version: "1.8.0"
  skill-last-updated: "2026-03-28"
---

# scikit-learn Skill

General-purpose machine learning with scikit-learn. Covers unsupervised methods (clustering, GMM, PCA, t-SNE, UMAP, manifold learning, evaluation metrics), supervised methods (classification, prediction-focused regression via Ridge/Lasso/ensemble methods, model evaluation, cross-validation), and shared infrastructure (preprocessing, Pipeline construction, feature selection). Use when performing cluster analysis, dimension reduction, classification, prediction-focused regression, or model evaluation in Python. For econometric regression (OLS, FE, IV, DiD), see pyfixest and statsmodels skills instead.

Comprehensive skill for machine learning in Python with scikit-learn. Covers unsupervised methods (clustering, decomposition, manifold learning), supervised methods (classification, regression), and shared infrastructure (preprocessing, pipelines, evaluation). Use decision trees below to find the right guidance, then load detailed references.

## What is scikit-learn?

scikit-learn is the standard **general-purpose machine learning library** for Python:
- **Consistent API**: Every estimator follows `fit()` / `predict()` / `transform()` — learn once, apply everywhere
- **Unsupervised methods**: Clustering (KMeans, DBSCAN, HDBSCAN, hierarchical), decomposition (PCA, NMF, SVD), mixture models (GMM), manifold learning (t-SNE)
- **Supervised methods**: Classification (logistic regression, random forest, gradient boosting, SVM) and prediction-focused regression (Ridge, Lasso, ensemble methods)
- **Model evaluation**: Cross-validation, grid search, metrics for both classification and clustering
- **Pipelines**: Chain preprocessing and models into reproducible, leak-free workflows

## Version Notes

This skill targets **scikit-learn 1.8.0**. Notable changes in recent versions:
- HDBSCAN added as a first-class estimator (1.3+)
- `set_output(transform="pandas")` for DataFrame output from transformers (1.2+)
- HistGradientBoosting estimators are now stable (1.0+)
- `n_init="auto"` default for KMeans (1.4+) — uses 10 for `init="random"`, 1 for `init="k-means++"`

## How to Use This Skill

### Reference File Structure

Each topic in `./references/` contains focused documentation:

| File | Purpose | When to Read |
|------|---------|--------------|
| `quickstart.md` | Import patterns, fit/predict/transform API, Pipeline, train_test_split | First use of scikit-learn |
| `clustering.md` | KMeans, AgglomerativeClustering, DBSCAN, HDBSCAN, SpectralClustering, OPTICS | Cluster analysis tasks |
| `mixture-models.md` | GaussianMixture, BayesianGaussianMixture, BIC/AIC model selection | Model-based clustering, soft assignments |
| `decomposition.md` | PCA, KernelPCA, TruncatedSVD, NMF, IncrementalPCA | Dimension reduction tasks |
| `manifold.md` | t-SNE, UMAP (umap-learn), Isomap, LLE, MDS, SpectralEmbedding | Visualizing high-dimensional data |
| `evaluation-unsupervised.md` | silhouette_score, Davies-Bouldin, Calinski-Harabasz, ARI, NMI, gap statistic | Validating cluster solutions |
| `preprocessing.md` | StandardScaler, encoders, ColumnTransformer, Pipeline construction | Preparing data for ML |
| `classification.md` | LogisticRegression, RandomForest, GradientBoosting, SVC, KNeighbors | Classification tasks |
| `regression-ml.md` | Ridge, Lasso, ElasticNet, tree/ensemble regressors, SVR | ML regression (prediction-focused) |
| `evaluation-supervised.md` | Accuracy, F1, ROC-AUC, confusion matrix, cross_val_score, GridSearchCV | Evaluating supervised models |
| `feature-selection.md` | SelectKBest, RFE, permutation_importance, VarianceThreshold | Selecting informative features |
| `gotchas.md` | Data leakage, scaling errors, t-SNE misinterpretation, class imbalance | Avoiding common mistakes |
| `interpretation.md` | SHAP values (TreeExplainer, KernelExplainer), permutation importance visualization, partial dependence plots, ICE plots | After training a model, when interpretation or explanation is needed |
| `fairness.md` | fairlearn MetricFrame, ThresholdOptimizer, ExponentiatedGradient, demographic parity, equalized odds | Assessing or mitigating fairness of supervised models |

### Reading Order

1. **New to scikit-learn?** Start with `quickstart.md` then the task-specific reference
2. **Clustering task?** Read `clustering.md`, then `evaluation-unsupervised.md`
3. **Classification task?** Read `classification.md`, then `evaluation-supervised.md`
4. **Need preprocessing?** Read `preprocessing.md` (covers Pipeline construction)
5. **Having issues?** Check `gotchas.md` first
6. **Interpretation task?** Read `interpretation.md`, then check `supervised-ml.md` in data-scientist skill for methodology
7. **Fairness assessment?** Read `fairness.md`, then check `supervised-ml.md` in data-scientist skill for conceptual framework

## Related Skills

| Skill | Relationship |
|-------|-------------|
| `data-scientist` | Methodology guidance — load `exploratory-unsupervised.md` for "when and why" behind unsupervised methods |
| `pyfixest` | Econometric regression: OLS with fixed effects, IV, DiD, clustered SEs, hypothesis testing |
| `statsmodels` | Statistical modeling: OLS without FE, GLM, time series, diagnostic tests |
| `polars` | Data preparation before ML (convert to pandas/numpy before passing to scikit-learn) |
| `geopandas` | Spatial analysis — use geopandas for geographic data, not scikit-learn |
| `plotnine` | Custom visualization beyond scikit-learn's built-in plotting |
| `data-scientist` | Load `supervised-ml.md` for supervised ML methodology — the "when and why" behind prediction, interpretation, and fairness |

**Routing guidance:**
- For econometric regression (hypothesis testing, standard errors, coefficient interpretation), use `pyfixest` or `statsmodels` — not scikit-learn
- For unsupervised methodology (when to cluster, how to validate, what to report), read `exploratory-unsupervised.md` in the `data-scientist` skill
- For spatial analysis, use `geopandas`
- For data manipulation, use `polars`

## Quick Decision Trees

### "I need to group observations" (Unsupervised)

```
What kind of data and clusters?
├─ Continuous data, roughly spherical clusters
│   ├─ Know k → KMeans (./references/clustering.md)
│   └─ Don't know k → try multiple k + silhouette/gap
│       (./references/clustering.md + ./references/evaluation-unsupervised.md)
├─ Continuous data, arbitrary shapes
│   ├─ Dense clusters, possible noise → DBSCAN or HDBSCAN (./references/clustering.md)
│   └─ Need soft assignments → GaussianMixture (./references/mixture-models.md)
├─ Need hierarchy / dendrogram → AgglomerativeClustering (./references/clustering.md)
├─ Mixed data types → Gower distance workaround (./references/gotchas.md)
└─ Need probabilistic model comparison → GaussianMixture with BIC
    (./references/mixture-models.md)
```

### "I need to reduce dimensions" (Unsupervised)

```
What is the goal?
├─ Linear reduction for subsequent analysis → PCA (./references/decomposition.md)
├─ Large sparse data → TruncatedSVD (./references/decomposition.md)
├─ Non-negative components → NMF (./references/decomposition.md)
├─ Visualization of structure → t-SNE or UMAP (./references/manifold.md)
│   └─ CAUTION: visualization only, not for analysis
│       (see data-scientist exploratory-unsupervised.md for methodology)
├─ Nonlinear manifold learning → Isomap or LLE (./references/manifold.md)
└─ Correspondence analysis (CA, MCA) → use the prince library
```

### "I need to predict a categorical outcome" (Supervised)

```
What constraints?
├─ Interpretable model needed → LogisticRegression or DecisionTreeClassifier
│   (./references/classification.md)
├─ Best predictive performance → GradientBoostingClassifier or RandomForestClassifier
│   (./references/classification.md)
├─ High-dimensional sparse data → LogisticRegression with penalty
│   (./references/classification.md)
├─ Small dataset, few features → KNeighborsClassifier or SVC
│   (./references/classification.md)
└─ Need probability estimates → any classifier with predict_proba()
    (./references/classification.md)
```

### "I need to predict a continuous outcome" (Supervised)

```
What kind of regression?
├─ NOTE: For econometric regression (hypothesis testing, standard errors,
│   coefficient interpretation), use pyfixest or statsmodels instead
├─ Prediction-focused, nonlinear → GradientBoostingRegressor or RandomForestRegressor
│   (./references/regression-ml.md)
├─ High-dimensional with regularization → Lasso, Ridge, or ElasticNet
│   (./references/regression-ml.md)
├─ Nonlinear relationships → GradientBoostingRegressor or SVR
│   (./references/regression-ml.md)
└─ Simple baseline → Ridge (./references/regression-ml.md)
```

### "I need to evaluate a model"

```
What kind of evaluation?
├─ Unsupervised (no ground truth)
│   ├─ Cluster quality → silhouette_score, Davies-Bouldin
│   │   (./references/evaluation-unsupervised.md)
│   ├─ Stability → Bootstrap + compare across resamples
│   │   (./references/evaluation-unsupervised.md)
│   └─ Against known labels → ARI, NMI
│       (./references/evaluation-unsupervised.md)
├─ Supervised classification
│   ├─ Balanced classes → accuracy + F1 (./references/evaluation-supervised.md)
│   ├─ Imbalanced classes → precision, recall, ROC-AUC
│   │   (./references/evaluation-supervised.md)
│   └─ Model selection → cross_val_score or GridSearchCV
│       (./references/evaluation-supervised.md)
└─ Supervised regression
    ├─ R-squared, RMSE, MAE (./references/evaluation-supervised.md)
    └─ Model selection → cross_val_score or GridSearchCV
        (./references/evaluation-supervised.md)
```

### "I need to interpret or explain a model"

```
What kind of interpretation?
├─ Feature importance (global) → SHAP beeswarm/bar or permutation importance
│   (./references/interpretation.md)
├─ Single prediction explanation → SHAP waterfall or force plot
│   (./references/interpretation.md)
├─ Feature effect visualization → PDP or SHAP dependence plot
│   (./references/interpretation.md)
├─ Fairness across demographic groups → MetricFrame
│   (./references/fairness.md)
└─ CAUTION: feature importance ≠ causal importance
    (see data-scientist supervised-ml.md for methodology)
```

## File-First Execution in Research Workflows

**Important:** In data research pipelines (see `CLAUDE.md`), scikit-learn analyses are executed through **script files**, not interactively. This ensures auditability and reproducibility.

**The pattern:**
1. Write ML code to `scripts/stage8_analysis/{step}_{task-name}.py`
2. Execute via Bash with automatic output capture wrapper script
3. Validation results get automatically embedded in scripts as comments
4. If failed, create versioned copy for fixes

Closely read `agent_reference/SCRIPT_EXECUTION_REFERENCE.md` for the mandatory file-first execution protocol covering complete code file writing, output capture, and file versioning rules. All ML scripts must follow the Inline Audit Trail (IAT) standard -- see `agent_reference/INLINE_AUDIT_TRAIL.md`. For ML code, document model selection rationale (why this algorithm, why these hyperparameters, what assumptions) with `# INTENT:`, `# REASONING:`, and `# ASSUMES:` comments.

**See:**
- `agent_reference/WORKFLOW_PHASE4_ANALYSIS.md` -- Stage 8 (Analysis & Visualization)
- `agent_reference/INLINE_AUDIT_TRAIL.md` -- IAT documentation standard

The examples below show scikit-learn syntax. In research workflows, wrap them in scripts following the file-first pattern.

---

## Quick Reference

### Essential Imports

```python
import numpy as np
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import make_pipeline
```

### The fit/predict/transform Pattern

```python
# Supervised: fit + predict
model.fit(X_train, y_train)
y_pred = model.predict(X_test)

# Unsupervised: fit + transform (or fit_transform)
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Clustering: fit + labels_
kmeans.fit(X)
labels = kmeans.labels_
```

### Common Operations

| Operation | Code |
|-----------|------|
| Train-test split | `X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)` |
| Scale features | `X_scaled = StandardScaler().fit_transform(X)` |
| Build pipeline | `pipe = make_pipeline(StandardScaler(), LogisticRegression())` |
| Cross-validate | `scores = cross_val_score(model, X, y, cv=5, scoring="accuracy")` |
| Grid search | `GridSearchCV(model, param_grid, cv=5, scoring="accuracy")` |
| KMeans clustering | `KMeans(n_clusters=k, n_init=10, random_state=42).fit(X)` |
| PCA | `PCA(n_components=5).fit_transform(X_scaled)` |
| Logistic regression | `LogisticRegression(max_iter=1000).fit(X_train, y_train)` |
| Random forest | `RandomForestClassifier(n_estimators=100, random_state=42).fit(X_train, y_train)` |
| Gradient boosting | `HistGradientBoostingClassifier().fit(X_train, y_train)` |
| Classification report | `print(classification_report(y_test, y_pred))` |
| Confusion matrix | `confusion_matrix(y_test, y_pred)` |
| Silhouette score | `silhouette_score(X, labels)` |
| Feature importance | `model.feature_importances_` |
| Permutation importance | `permutation_importance(model, X_test, y_test, random_state=42)` |
| Set output format | `model.set_output(transform="pandas")` |

## Topic Index

| Topic | Reference File |
|-------|---------------|
| Installation and imports | `./references/quickstart.md` |
| fit/predict/transform API | `./references/quickstart.md` |
| Pipeline construction | `./references/quickstart.md` |
| Train-test split | `./references/quickstart.md` |
| Reproducibility (random_state) | `./references/quickstart.md` |
| KMeans, MiniBatchKMeans | `./references/clustering.md` |
| AgglomerativeClustering | `./references/clustering.md` |
| DBSCAN, HDBSCAN, OPTICS | `./references/clustering.md` |
| SpectralClustering | `./references/clustering.md` |
| GaussianMixture | `./references/mixture-models.md` |
| BayesianGaussianMixture | `./references/mixture-models.md` |
| BIC/AIC model selection | `./references/mixture-models.md` |
| Soft cluster assignments | `./references/mixture-models.md` |
| PCA, KernelPCA | `./references/decomposition.md` |
| TruncatedSVD (sparse data) | `./references/decomposition.md` |
| NMF | `./references/decomposition.md` |
| IncrementalPCA | `./references/decomposition.md` |
| t-SNE | `./references/manifold.md` |
| UMAP (umap-learn) | `./references/manifold.md` |
| Isomap, LLE, MDS | `./references/manifold.md` |
| silhouette_score | `./references/evaluation-unsupervised.md` |
| Davies-Bouldin, Calinski-Harabasz | `./references/evaluation-unsupervised.md` |
| Adjusted Rand Index, NMI | `./references/evaluation-unsupervised.md` |
| Gap statistic | `./references/evaluation-unsupervised.md` |
| StandardScaler, MinMaxScaler | `./references/preprocessing.md` |
| OneHotEncoder, OrdinalEncoder | `./references/preprocessing.md` |
| ColumnTransformer | `./references/preprocessing.md` |
| Pipeline, make_pipeline | `./references/preprocessing.md` |
| LogisticRegression | `./references/classification.md` |
| DecisionTreeClassifier | `./references/classification.md` |
| RandomForestClassifier | `./references/classification.md` |
| GradientBoostingClassifier | `./references/classification.md` |
| SVC, KNeighborsClassifier | `./references/classification.md` |
| Ridge, Lasso, ElasticNet | `./references/regression-ml.md` |
| RandomForestRegressor | `./references/regression-ml.md` |
| GradientBoostingRegressor | `./references/regression-ml.md` |
| SVR, KNeighborsRegressor | `./references/regression-ml.md` |
| accuracy, precision, recall, F1 | `./references/evaluation-supervised.md` |
| ROC-AUC, confusion matrix | `./references/evaluation-supervised.md` |
| cross_val_score, GridSearchCV | `./references/evaluation-supervised.md` |
| learning_curve | `./references/evaluation-supervised.md` |
| SelectKBest, RFE | `./references/feature-selection.md` |
| feature_importances_ | `./references/feature-selection.md` |
| permutation_importance | `./references/feature-selection.md` |
| Data leakage | `./references/gotchas.md` |
| Scaling for distance-based methods | `./references/gotchas.md` |
| t-SNE/UMAP distance interpretation | `./references/gotchas.md` |
| Class imbalance | `./references/gotchas.md` |
| random_state reproducibility | `./references/gotchas.md` |
| SHAP values (TreeExplainer, KernelExplainer) | `./references/interpretation.md` |
| Permutation importance visualization | `./references/interpretation.md` |
| Partial dependence plots (PDP) | `./references/interpretation.md` |
| ICE plots | `./references/interpretation.md` |
| Model interpretation caveats | `./references/interpretation.md` |
| fairlearn MetricFrame | `./references/fairness.md` |
| ThresholdOptimizer | `./references/fairness.md` |
| ExponentiatedGradient | `./references/fairness.md` |
| Demographic parity | `./references/fairness.md` |
| Equalized odds | `./references/fairness.md` |
| LightGBM (LGBMClassifier, LGBMRegressor) | `./references/classification.md`, `./references/regression-ml.md` |
| XGBoost (XGBClassifier, XGBRegressor) | `./references/classification.md`, `./references/regression-ml.md` |

## Citation

When this library is used as a primary analytical tool, include in the report's
Software & Tools references:

> Pedregosa, F. et al. (2011). "Scikit-learn: Machine Learning in Python." Journal of Machine Learning Research, 12, 2825-2830.

**Cite when:** scikit-learn is used for machine learning models, clustering, dimensionality reduction, or cross-validation central to the analysis.
**Do not cite when:** Only used for a single preprocessing step (e.g., StandardScaler in a pipeline where the primary model is from another library).

For method-specific citations (e.g., individual algorithms or techniques),
consult the reference files in this skill and `agent_reference/CITATION_REFERENCE.md`.
