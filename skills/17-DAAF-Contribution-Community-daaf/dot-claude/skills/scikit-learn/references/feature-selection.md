# Feature Selection

Methods for selecting informative features: SelectKBest, RFE, tree-based feature importances, permutation importance, VarianceThreshold, and SelectFromModel.

## Method Comparison

| Method | Type | How It Works | When to Use |
|--------|------|-------------|-------------|
| VarianceThreshold | Filter | Remove low-variance features | Remove constant/near-constant features |
| SelectKBest | Filter | Univariate statistical tests | Quick filtering; large feature sets |
| RFE | Wrapper | Recursively remove least important features | When model supports `coef_` or `feature_importances_` |
| feature_importances_ | Embedded | Built into tree-based models | Tree/ensemble models |
| permutation_importance | Model-agnostic | Measure accuracy drop when feature is shuffled | Any model; most reliable |
| SelectFromModel | Embedded | Threshold on model importances | Automated selection from any model |

## VarianceThreshold

Remove features with variance below a threshold. Useful as a first pass to eliminate constant or near-constant columns.

```python
from sklearn.feature_selection import VarianceThreshold

# --- Remove features with zero variance (constant columns) ---
selector = VarianceThreshold(threshold=0.0)
X_filtered = selector.fit_transform(X)

# --- Remove features with very low variance ---
selector = VarianceThreshold(threshold=0.01)
X_filtered = selector.fit_transform(X)

# --- See which features were kept ---
kept_mask = selector.get_support()
kept_features = [f for f, keep in zip(feature_names, kept_mask) if keep]
print(f"Kept {len(kept_features)} / {len(feature_names)} features")
```

## SelectKBest

Select the k highest-scoring features based on univariate statistical tests.

```python
from sklearn.feature_selection import SelectKBest, f_classif, mutual_info_classif

# --- For classification: f_classif (ANOVA F-test) ---
selector = SelectKBest(score_func=f_classif, k=10)
X_selected = selector.fit_transform(X, y)

# --- For classification: mutual_info_classif (nonlinear dependencies) ---
selector = SelectKBest(score_func=mutual_info_classif, k=10)
X_selected = selector.fit_transform(X, y)

# --- For regression: f_regression or mutual_info_regression ---
from sklearn.feature_selection import f_regression, mutual_info_regression
selector = SelectKBest(score_func=f_regression, k=10)
X_selected = selector.fit_transform(X, y)

# --- Inspect scores ---
scores = selector.scores_
for name, score in sorted(zip(feature_names, scores), key=lambda x: -x[1]):
    print(f"{name}: {score:.3f}")

# --- Get selected feature names ---
selected_mask = selector.get_support()
selected_features = [f for f, sel in zip(feature_names, selected_mask) if sel]
```

### Scoring Functions

| Function | Task | Tests For |
|----------|------|-----------|
| `f_classif` | Classification | Linear relationship (ANOVA F-test) |
| `mutual_info_classif` | Classification | Any dependency (nonlinear OK) |
| `chi2` | Classification | Non-negative features only |
| `f_regression` | Regression | Linear relationship (F-test) |
| `mutual_info_regression` | Regression | Any dependency (nonlinear OK) |

## RFE (Recursive Feature Elimination)

Recursively removes the least important feature(s) until the desired count is reached.

```python
from sklearn.feature_selection import RFE, RFECV
from sklearn.ensemble import RandomForestClassifier

# --- RFE with fixed number of features ---
model = RandomForestClassifier(n_estimators=100, random_state=42)
rfe = RFE(
    estimator=model,
    n_features_to_select=10,
    step=1                   # Features to remove per iteration
)
rfe.fit(X_train, y_train)

# --- Results ---
selected_mask = rfe.support_
rankings = rfe.ranking_      # 1 = selected, 2+ = eliminated in order
selected_features = [f for f, sel in zip(feature_names, selected_mask) if sel]
print(f"Selected: {selected_features}")

# --- RFECV: automatically find optimal number via cross-validation ---
rfecv = RFECV(
    estimator=model,
    step=1,
    cv=5,
    scoring="accuracy",
    n_jobs=-1
)
rfecv.fit(X_train, y_train)
print(f"Optimal features: {rfecv.n_features_}")
```

## Tree-Based Feature Importances

Built into tree and ensemble models. Based on how much each feature reduces impurity across all splits.

```python
from sklearn.ensemble import RandomForestClassifier

model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X_train, y_train)

# --- Feature importances (mean decrease in impurity) ---
importances = model.feature_importances_

# --- Sorted display ---
for name, imp in sorted(zip(feature_names, importances), key=lambda x: -x[1]):
    if imp > 0.01:  # Only show features above threshold
        print(f"{name}: {imp:.4f}")
```

**Caveat:** Impurity-based importances are biased toward high-cardinality features and features with many unique values. Use permutation importance for more reliable results.

## Permutation Importance

Measures feature importance by shuffling each feature and observing how much the model's performance degrades. Works with any model.

```python
from sklearn.inspection import permutation_importance

result = permutation_importance(
    model, X_test, y_test,
    n_repeats=10,
    scoring="accuracy",
    random_state=42,
    n_jobs=-1
)

# --- Results ---
for name, imp_mean, imp_std in sorted(
    zip(feature_names, result.importances_mean, result.importances_std),
    key=lambda x: -x[1]
):
    if imp_mean > 0.001:
        print(f"{name}: {imp_mean:.4f} +/- {imp_std:.4f}")
```

**Why permutation importance is preferred over impurity-based:**
- Not biased toward high-cardinality features
- Accounts for feature interactions (unlike univariate tests)
- Works with any model (not just trees)
- Measured on test data (reflects generalization, not training fit)

## SelectFromModel

Automated feature selection using any model that exposes `coef_` or `feature_importances_`.

```python
from sklearn.feature_selection import SelectFromModel
from sklearn.ensemble import RandomForestClassifier

# --- Select features above median importance ---
selector = SelectFromModel(
    estimator=RandomForestClassifier(n_estimators=100, random_state=42),
    threshold="median"       # 'mean', 'median', or numeric value
)
selector.fit(X_train, y_train)
X_selected = selector.transform(X_train)

# --- Selected features ---
selected_mask = selector.get_support()
selected_features = [f for f, sel in zip(feature_names, selected_mask) if sel]
print(f"Selected {len(selected_features)} features")
```

## Integration with Pipeline

```python
from sklearn.pipeline import Pipeline
from sklearn.feature_selection import SelectKBest, f_classif

pipe = Pipeline([
    ("scaler", StandardScaler()),
    ("selector", SelectKBest(f_classif, k=10)),
    ("model", LogisticRegression(max_iter=1000))
])

pipe.fit(X_train, y_train)
accuracy = pipe.score(X_test, y_test)
```
