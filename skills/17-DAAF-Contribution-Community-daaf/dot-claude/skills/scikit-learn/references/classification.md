# Classification

Supervised classification with scikit-learn: LogisticRegression, DecisionTreeClassifier, RandomForestClassifier, GradientBoostingClassifier, HistGradientBoostingClassifier, SVC, and KNeighborsClassifier. For model evaluation metrics (accuracy, F1, ROC-AUC, cross-validation), see `evaluation-supervised.md`.

## Classifier Comparison

| Classifier | Interpretable? | Handles Nonlinear? | Scales to Large N? | Key Strength |
|------------|---------------|--------------------|--------------------|--------------|
| LogisticRegression | Yes (coefficients) | No (linear boundary) | Yes | Baseline; regularization |
| DecisionTree | Yes (tree viz) | Yes | Moderate | Interpretable rules |
| RandomForest | Moderate (importances) | Yes | Yes | Robust; low tuning |
| GradientBoosting | Moderate (importances) | Yes | Moderate | High accuracy |
| HistGradientBoosting | Moderate (importances) | Yes | Yes (fast) | Large data; native NaN |
| SVC | No (kernel) | Yes (kernel) | No (slow >10K) | Small data; complex boundaries |
| KNeighbors | No | Yes | No (slow at predict) | Simple; no training |

## LogisticRegression

Linear classifier with probabilistic output. The standard baseline for classification.

```python
from sklearn.linear_model import LogisticRegression

model = LogisticRegression(
    penalty="l2",            # Regularization: 'l1', 'l2', 'elasticnet', None
                             # Note: penalty param deprecated in 1.8+; L2 is still the default behavior
    C=1.0,                   # Inverse regularization strength (smaller = stronger)
    solver="lbfgs",          # Solver: 'lbfgs' (default), 'saga' (for l1/elasticnet)
    max_iter=1000,           # Increase if convergence warning
    class_weight=None,       # 'balanced' for imbalanced classes
    random_state=42
)
model.fit(X_train, y_train)

# --- Predictions ---
y_pred = model.predict(X_test)
y_proba = model.predict_proba(X_test)  # Class probabilities

# --- Coefficients (interpretable) ---
print(f"Coefficients: {model.coef_}")
print(f"Intercept: {model.intercept_}")
```

### Solver Selection

| Solver | Penalties Supported | Multiclass | Notes |
|--------|-------------------|------------|-------|
| `lbfgs` | l2, None | Yes (multinomial) | Default; good all-around |
| `saga` | l1, l2, elasticnet, None | Yes | Needed for l1/elasticnet |
| `liblinear` | l1, l2 | One-vs-rest only | Fast for small datasets |

## DecisionTreeClassifier

Single decision tree. Highly interpretable but prone to overfitting.

```python
from sklearn.tree import DecisionTreeClassifier

model = DecisionTreeClassifier(
    max_depth=5,                 # Limit tree depth (prevents overfitting)
    min_samples_leaf=10,         # Minimum samples in leaf node
    min_samples_split=20,        # Minimum samples to split a node
    class_weight=None,           # 'balanced' for imbalanced classes
    random_state=42
)
model.fit(X_train, y_train)

# --- Feature importance ---
importances = model.feature_importances_
for name, imp in sorted(zip(feature_names, importances), key=lambda x: -x[1]):
    print(f"{name}: {imp:.4f}")
```

## RandomForestClassifier

Ensemble of decision trees with bagging. Robust, low tuning overhead, good default choice.

```python
from sklearn.ensemble import RandomForestClassifier

model = RandomForestClassifier(
    n_estimators=100,            # Number of trees (more = better, diminishing returns)
    max_depth=None,              # None = trees grow until pure (or min_samples_leaf)
    max_features="sqrt",         # Features per split: 'sqrt', 'log2', int, float
    min_samples_leaf=5,          # Minimum samples in leaf
    class_weight=None,           # 'balanced' for imbalanced classes
    n_jobs=-1,                   # Use all CPU cores
    random_state=42
)
model.fit(X_train, y_train)

# --- Predictions with probability ---
y_pred = model.predict(X_test)
y_proba = model.predict_proba(X_test)

# --- Feature importance ---
importances = model.feature_importances_

# --- Out-of-bag score (free validation estimate) ---
model_oob = RandomForestClassifier(n_estimators=100, oob_score=True, random_state=42)
model_oob.fit(X_train, y_train)
print(f"OOB accuracy: {model_oob.oob_score_:.3f}")
```

## GradientBoostingClassifier

Sequential ensemble that builds trees to correct previous errors. Often highest accuracy.

```python
from sklearn.ensemble import GradientBoostingClassifier

model = GradientBoostingClassifier(
    n_estimators=200,            # Number of boosting stages
    learning_rate=0.1,           # Shrinkage (lower = more stages needed, better generalization)
    max_depth=3,                 # Depth per tree (typically 3-8 for boosting)
    min_samples_leaf=10,
    subsample=0.8,               # Fraction of samples per tree (stochastic boosting)
    random_state=42
)
model.fit(X_train, y_train)
```

## HistGradientBoostingClassifier

Histogram-based gradient boosting. Much faster than GradientBoostingClassifier on large datasets. Handles missing values natively.

```python
from sklearn.ensemble import HistGradientBoostingClassifier

model = HistGradientBoostingClassifier(
    max_iter=200,                # Number of boosting iterations
    learning_rate=0.1,
    max_depth=None,              # None = unlimited (controlled by max_leaf_nodes)
    max_leaf_nodes=31,           # Max leaves per tree
    min_samples_leaf=20,
    random_state=42
)
model.fit(X_train, y_train)     # Handles NaN values natively (no imputation needed)
```

### GradientBoosting vs HistGradientBoosting

| Feature | GradientBoosting | HistGradientBoosting |
|---------|-----------------|---------------------|
| Speed | Slower | Much faster (histogram binning) |
| Large datasets | Slow on >10K rows | Handles millions of rows |
| Missing values | Requires imputation | Handles NaN natively |
| Categorical features | Requires encoding | Native support (1.4+) |
| API | `n_estimators`, `max_depth` | `max_iter`, `max_leaf_nodes` |

## SVC (Support Vector Classifier)

Finds the maximum-margin decision boundary. Effective on small-to-medium datasets with complex boundaries.

```python
from sklearn.svm import SVC

model = SVC(
    kernel="rbf",                # 'linear', 'rbf', 'poly', 'sigmoid'
    C=1.0,                       # Regularization (larger = less regularization)
    gamma="scale",               # Kernel coefficient: 'scale', 'auto', or float
    probability=True,            # Enable predict_proba (slower training)
    class_weight=None,           # 'balanced' for imbalanced classes
    random_state=42
)
model.fit(X_train_scaled, y_train)   # Scale features first (SVM is distance-based)
y_pred = model.predict(X_test_scaled)
```

## KNeighborsClassifier

Classifies based on majority vote of k nearest neighbors. No training phase.

```python
from sklearn.neighbors import KNeighborsClassifier

model = KNeighborsClassifier(
    n_neighbors=5,               # Number of neighbors
    weights="uniform",           # 'uniform' or 'distance' (inverse-distance weighting)
    metric="minkowski",          # Distance metric
    p=2,                         # Minkowski p (2=Euclidean, 1=Manhattan)
    n_jobs=-1
)
model.fit(X_train_scaled, y_train)   # Scale features first (distance-based)
y_pred = model.predict(X_test_scaled)
```

## Common Patterns

### Handling Class Imbalance

```python
# --- Option 1: class_weight parameter ---
model = RandomForestClassifier(class_weight="balanced", random_state=42)

# --- Option 2: class_weight with custom weights ---
model = LogisticRegression(class_weight={0: 1, 1: 10}, random_state=42)

# --- Option 3: Adjust decision threshold ---
y_proba = model.predict_proba(X_test)[:, 1]
y_pred_custom = (y_proba >= 0.3).astype(int)  # Lower threshold for minority class
```

### Multi-Class Classification

```python
# --- Most classifiers handle multi-class natively ---
model = LogisticRegression(multi_class="multinomial", max_iter=1000)
model.fit(X_train, y_train)  # y has >2 classes

# --- For classifiers that don't (e.g., SVC with non-linear kernel) ---
from sklearn.multiclass import OneVsRestClassifier
model = OneVsRestClassifier(SVC(kernel="rbf", probability=True))
```

### Quick Model Comparison

```python
from sklearn.model_selection import cross_val_score
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler

classifiers = {
    "LogisticRegression": LogisticRegression(max_iter=1000),
    "RandomForest": RandomForestClassifier(n_estimators=100, random_state=42),
    "HistGradientBoosting": HistGradientBoostingClassifier(random_state=42),
}

for name, clf in classifiers.items():
    pipe = make_pipeline(StandardScaler(), clf)
    scores = cross_val_score(pipe, X, y, cv=5, scoring="accuracy")
    print(f"{name}: {scores.mean():.3f} +/- {scores.std():.3f}")
```

## Beyond HistGradientBoosting: LightGBM and XGBoost

For use cases where scikit-learn's HistGradientBoostingClassifier is not sufficient, LightGBM and XGBoost provide additional capabilities. Both follow the scikit-learn estimator API (`fit`/`predict`/`predict_proba`).

```python
# LightGBM (available in DAAF Dockerfile)
import lightgbm as lgb
model = lgb.LGBMClassifier(
    n_estimators=100,
    learning_rate=0.1,
    num_leaves=31,
    random_state=42,
)
model.fit(X_train, y_train)

# XGBoost (optional install: uv pip install --system --no-deps xgboost)
import xgboost as xgb
model = xgb.XGBClassifier(
    n_estimators=100,
    learning_rate=0.1,
    max_depth=6,
    random_state=42,
)
model.fit(X_train, y_train)
```

### Comparison

| Feature | HistGradientBoosting | LightGBM | XGBoost |
|---------|---------------------|----------|---------|
| In Dockerfile | Yes | Yes | No (optional) |
| SHAP TreeExplainer | Approximate | Native (fast) | Native (fast) |
| Custom loss functions | No | Yes | Yes |
| Categorical features | Native | Native | Native support via `enable_categorical=True` (1.5+); otherwise requires encoding |
| GPU support | No | Yes | Yes |

> **Guidance:** For most DAAF use cases, HistGradientBoosting is sufficient. Use LightGBM when SHAP TreeExplainer performance matters. Use XGBoost for custom loss functions.
