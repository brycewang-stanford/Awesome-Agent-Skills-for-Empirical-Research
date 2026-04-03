# Model Interpretation

SHAP values, permutation importance, partial dependence plots, and ICE plots for interpreting supervised models. For methodology guidance (when interpretation is appropriate, causation caveats, reporting standards), see `supervised-ml.md` in the `data-scientist` skill.

## SHAP: SHapley Additive exPlanations

SHAP values decompose individual predictions into per-feature contributions using Shapley values from cooperative game theory. For each prediction, SHAP assigns each feature a value representing its contribution to pushing the prediction away from the average. Installed version: `shap==0.51.0`.

### Essential Import

```python
import shap
```

### TreeExplainer (Fast, Exact for Tree Models)

Works with RandomForest, GradientBoosting, HistGradientBoosting, LightGBM, and XGBoost. Computes exact SHAP values in polynomial time.

```python
import shap

# --- TreeExplainer: use for any tree-based model ---
explainer = shap.TreeExplainer(model)
shap_values = explainer(X_test)

# shap_values is an Explanation object:
#   .values  — SHAP values array, shape (n_samples, n_features)
#   .base_values — expected value (average model output)
#   .data — input feature values
#   .feature_names — feature names (if available)

print(f"SHAP values shape: {shap_values.values.shape}")
print(f"Base value: {shap_values.base_values[0]:.4f}")
```

**For classifiers** (multi-output), specify the class to explain:

```python
# --- Binary classification: explain probability of positive class ---
explainer = shap.TreeExplainer(model)
shap_values = explainer(X_test)

# For binary classifiers, shap_values.values has shape (n_samples, n_features)
# or (n_samples, n_features, n_classes) depending on the model.
# If 3D, select the class of interest:
# shap_values_class1 = shap_values[..., 1]
```

### Multi-class Output

For multi-class classifiers, SHAP returns a 3D array: `(n_samples, n_features, n_classes)`.
To plot SHAP values for a specific class:

```python
# SHAP values for class index 2
shap.plots.beeswarm(shap_values[:, :, 2])
```

### KernelExplainer (Model-Agnostic, Slower)

Works with any model that has `predict` or `predict_proba`. Uses a background dataset to estimate SHAP values via weighted local regression. Much slower than TreeExplainer -- use only when TreeExplainer is not available.

```python
import shap

# --- KernelExplainer: model-agnostic ---
# Use a summary of training data as background (100 samples is typical)
background = shap.sample(X_train, 100)

# For regression or binary classification probability:
explainer = shap.KernelExplainer(model.predict, background)
shap_values = explainer.shap_values(X_test[:50])  # Subset for speed

# shap_values is a numpy array, shape (n_samples, n_features)
print(f"SHAP values shape: {shap_values.shape}")
```

> **API difference:** TreeExplainer uses the callable pattern `explainer(X)` returning
> an `Explanation` object (access values via `.values`). KernelExplainer uses
> `.shap_values(X)` returning a numpy array directly. Do not mix these patterns.

**Performance note:** Exact Shapley values require O(2^F) evaluations; KernelExplainer uses sampling approximation (default nsamples = 2*M + 2048), but remains slow for many features. Use `shap.sample()` or `shap.kmeans()` to summarize the background data and limit the number of test samples explained.

### Visualization API

| Plot | Purpose | Code |
|------|---------|------|
| Beeswarm (summary) | Global importance with distributional detail | `shap.plots.beeswarm(shap_values)` |
| Bar | Global importance (magnitude only) | `shap.plots.bar(shap_values)` |
| Waterfall | Single prediction explanation | `shap.plots.waterfall(shap_values[i])` |
| Force | Single prediction as additive forces | `shap.plots.force(shap_values[i], matplotlib=True)` |
| Scatter (dependence) | Feature effect with interaction coloring | `shap.plots.scatter(shap_values[:, "feature_name"])` |
| Heatmap | SHAP values across many observations | `shap.plots.heatmap(shap_values)` |

### Visualization Code Patterns

```python
import shap
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

# --- Beeswarm: global feature importance with direction and magnitude ---
shap.plots.beeswarm(shap_values, show=False)
plt.tight_layout()
plt.savefig(f"{FIGURES_DIR}/shap_beeswarm.png", dpi=150, bbox_inches="tight")
plt.close()
print(f"Saved: {FIGURES_DIR}/shap_beeswarm.png")

# --- Bar: simplified global importance (absolute mean SHAP) ---
shap.plots.bar(shap_values, show=False)
plt.tight_layout()
plt.savefig(f"{FIGURES_DIR}/shap_bar.png", dpi=150, bbox_inches="tight")
plt.close()

# --- Waterfall: explain a single prediction ---
shap.plots.waterfall(shap_values[0], show=False)
plt.tight_layout()
plt.savefig(f"{FIGURES_DIR}/shap_waterfall_obs0.png", dpi=150, bbox_inches="tight")
plt.close()

# --- Force: single prediction as additive force diagram ---
shap.plots.force(shap_values[0], matplotlib=True, show=False)
plt.tight_layout()
plt.savefig(f"{FIGURES_DIR}/shap_force_obs0.png", dpi=150, bbox_inches="tight")
plt.close()

# --- Scatter (dependence): feature effect for one variable ---
shap.plots.scatter(shap_values[:, "feature_name"], show=False)
plt.tight_layout()
plt.savefig(f"{FIGURES_DIR}/shap_scatter_feature.png", dpi=150, bbox_inches="tight")
plt.close()

# --- Heatmap: SHAP values across observations ---
shap.plots.heatmap(shap_values, show=False)
plt.tight_layout()
plt.savefig(f"{FIGURES_DIR}/shap_heatmap.png", dpi=150, bbox_inches="tight")
plt.close()
```

**Key pattern:** Always pass `show=False` to SHAP plots, then use `plt.savefig()` followed by `plt.close()`. This prevents plots from attempting to display interactively and ensures they are saved as files.

### Interaction Values

TreeExplainer can compute pairwise interaction effects:

```python
interaction_values = explainer.shap_interaction_values(X_test)
# interaction_values shape: (n_samples, n_features, n_features)
```

This is computationally expensive. Use only when feature interactions are a specific research question.

## Permutation Importance (scikit-learn Built-In)

Measures feature importance by shuffling each feature and observing the drop in model score. Model-agnostic -- works with any estimator.

```python
from sklearn.inspection import permutation_importance

# --- Compute on TEST set (not training set) ---
# INTENT: Measure feature importance for generalization, not training fit
# REASONING: Training-set importance reflects overfitting, not true signal
result = permutation_importance(
    model, X_test, y_test,
    n_repeats=10,            # Shuffle each feature 10 times for stability
    scoring="accuracy",      # Or "r2", "f1", "neg_mean_squared_error", etc.
    random_state=42,
    n_jobs=-1
)

# --- Display sorted results ---
for name, imp_mean, imp_std in sorted(
    zip(feature_names, result.importances_mean, result.importances_std),
    key=lambda x: -x[1]
):
    if imp_mean > 0.001:
        print(f"{name}: {imp_mean:.4f} +/- {imp_std:.4f}")
```

**Cross-reference:** For using permutation importance in feature selection workflows, see `feature-selection.md` which covers `SelectFromModel`, RFE, and other feature selection methods.

## Partial Dependence and ICE Plots

Partial Dependence Plots (PDP) show the average prediction as one feature varies, marginalizing over all other features. Individual Conditional Expectation (ICE) plots show the same thing per observation, revealing heterogeneity that PDP averages away.

```python
from sklearn.inspection import PartialDependenceDisplay
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

# --- PDP for one or more features ---
fig, ax = plt.subplots(figsize=(10, 6))
PartialDependenceDisplay.from_estimator(
    model, X_test,
    features=["feature_a", "feature_b"],   # Features to plot
    kind="average",                         # "average" = PDP only
    ax=ax
)
plt.tight_layout()
plt.savefig(f"{FIGURES_DIR}/pdp.png", dpi=150, bbox_inches="tight")
plt.close()

# --- ICE plots (individual lines + average) ---
fig, ax = plt.subplots(figsize=(10, 6))
PartialDependenceDisplay.from_estimator(
    model, X_test,
    features=["feature_a"],
    kind="both",                            # "both" = ICE lines + PDP average
    ice_lines_kw={"color": "steelblue", "alpha": 0.1, "linewidth": 0.5},
    pd_line_kw={"color": "red", "linewidth": 2},
    ax=ax
)
plt.tight_layout()
plt.savefig(f"{FIGURES_DIR}/ice_feature_a.png", dpi=150, bbox_inches="tight")
plt.close()

# --- 2D interaction PDP (heatmap) ---
fig, ax = plt.subplots(figsize=(8, 6))
PartialDependenceDisplay.from_estimator(
    model, X_test,
    features=[("feature_a", "feature_b")],  # Tuple for 2D interaction
    ax=ax
)
plt.tight_layout()
plt.savefig(f"{FIGURES_DIR}/pdp_interaction.png", dpi=150, bbox_inches="tight")
plt.close()
```

### PDP vs ICE

| Aspect | PDP (`kind="average"`) | ICE (`kind="both"` or `"individual"`) |
|--------|------------------------|---------------------------------------|
| Shows | Average effect across all observations | Per-observation effect |
| Reveals | Main effect of feature | Heterogeneity and interactions |
| When to use | Initial exploration of feature effects | Suspected interaction effects |
| Caveat | Can mask opposing effects in subgroups | Cluttered with many observations |

## Interpreting Results: Mandatory Caveats

These caveats apply to ALL interpretation methods above. For full methodology treatment, see `supervised-ml.md` in the `data-scientist` skill.

1. **SHAP explains the MODEL, not reality.** SHAP values reflect how the model uses features, which may differ from how the real-world process works. A model trained on biased data produces SHAP values that reflect the bias.

2. **Feature importance is NOT causal importance.** High SHAP value or permutation importance means the feature is predictive in the model. It does NOT mean intervening on that feature would change outcomes. For causal analysis, use econometric methods (see `pyfixest` and `statsmodels` skills).

3. **Correlated features produce unstable SHAP values.** When features are correlated, SHAP distributes importance among them in ways that can vary across samples and models. The individual SHAP values for correlated features should not be interpreted in isolation.

4. **Feature importance rankings are model-dependent.** Different models (random forest vs. gradient boosting vs. logistic regression) can produce different importance rankings for the same data. Report the model alongside any importance claims.

5. **PDP assumes feature independence.** Partial dependence plots marginalize over other features, which can produce misleading results when features are correlated. ICE plots partially address this by showing individual trajectories.

## XGBoost and LightGBM Integration

TreeExplainer is optimized for native tree model formats. LightGBM is available in the Dockerfile; XGBoost is an optional install.

### LightGBM (Available in Dockerfile)

```python
import lightgbm as lgb
import shap

# --- Train LightGBM model (sklearn-compatible API) ---
model = lgb.LGBMClassifier(n_estimators=200, learning_rate=0.1, random_state=42)
model.fit(X_train, y_train)

# --- SHAP with TreeExplainer (fast, native support) ---
explainer = shap.TreeExplainer(model)
shap_values = explainer(X_test)
```

### XGBoost (Optional Install)

```python
# Install: uv pip install --system --no-deps xgboost
import xgboost as xgb
import shap

# --- Train XGBoost model (sklearn-compatible API) ---
model = xgb.XGBClassifier(n_estimators=200, learning_rate=0.1, random_state=42)
model.fit(X_train, y_train)

# --- SHAP with TreeExplainer (fast, native support) ---
explainer = shap.TreeExplainer(model)
shap_values = explainer(X_test)
```

### TreeExplainer Performance by Model Type

| Model | TreeExplainer Speed | Notes |
|-------|-------------------|-------|
| LightGBM (native) | Fastest | Native optimized path |
| XGBoost (native) | Fastest | Native optimized path |
| RandomForestClassifier/Regressor | Fast | scikit-learn tree format |
| GradientBoostingClassifier/Regressor | Fast | scikit-learn tree format |
| HistGradientBoostingClassifier/Regressor | Moderate | In shap 0.51.0, TreeExplainer falls back to a model-agnostic approximation for scikit-learn's HistGradientBoosting estimators, which is significantly slower than the native path used for LightGBM and XGBoost. If SHAP computation speed matters for your workflow, use LightGBM (available in the DAAF Dockerfile) instead. |

## Quick Reference

| Task | Code |
|------|------|
| SHAP for tree models | `explainer = shap.TreeExplainer(model); sv = explainer(X_test)` |
| SHAP for any model | `explainer = shap.KernelExplainer(model.predict, background); sv = explainer.shap_values(X_test)` |
| Beeswarm plot | `shap.plots.beeswarm(shap_values, show=False)` |
| Bar plot | `shap.plots.bar(shap_values, show=False)` |
| Waterfall (single obs) | `shap.plots.waterfall(shap_values[0], show=False)` |
| Force plot (single obs) | `shap.plots.force(shap_values[0], matplotlib=True, show=False)` |
| Scatter/dependence | `shap.plots.scatter(shap_values[:, "feat"], show=False)` |
| Heatmap | `shap.plots.heatmap(shap_values, show=False)` |
| Permutation importance | `permutation_importance(model, X_test, y_test, n_repeats=10, random_state=42)` |
| Partial dependence plot | `PartialDependenceDisplay.from_estimator(model, X, features=["feat"])` |
| ICE plot | `PartialDependenceDisplay.from_estimator(model, X, features=["feat"], kind="both")` |
| 2D PDP interaction | `PartialDependenceDisplay.from_estimator(model, X, features=[("f1", "f2")])` |
