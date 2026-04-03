# Evaluation: Supervised

Metrics and tools for evaluating supervised models: classification metrics (accuracy, precision, recall, F1, ROC-AUC, confusion matrix), regression metrics (MSE, R-squared, MAE), cross-validation, hyperparameter search, and learning curves.

> **Model interpretation:** For SHAP values, permutation importance visualization,
> and partial dependence analysis beyond what's covered here, see
> `interpretation.md`. For fairness assessment across demographic groups, see
> `fairness.md`.

## Classification Metrics

### accuracy_score

Fraction of correct predictions. Only meaningful when classes are balanced.

```python
from sklearn.metrics import accuracy_score

acc = accuracy_score(y_test, y_pred)
print(f"Accuracy: {acc:.3f}")
```

### precision_score, recall_score, f1_score

| Metric | What It Measures | Use When |
|--------|-----------------|----------|
| Precision | Of predicted positives, how many are correct? | False positives are costly |
| Recall | Of actual positives, how many did we find? | False negatives are costly |
| F1 | Harmonic mean of precision and recall | Need balance of both |

```python
from sklearn.metrics import precision_score, recall_score, f1_score

precision = precision_score(y_test, y_pred, average="binary")   # Binary classification
recall = recall_score(y_test, y_pred, average="binary")
f1 = f1_score(y_test, y_pred, average="binary")

# --- Multi-class: choose averaging method ---
f1_macro = f1_score(y_test, y_pred, average="macro")       # Unweighted mean across classes
f1_weighted = f1_score(y_test, y_pred, average="weighted")  # Weighted by class support
```

### Multi-Class Averaging

| Average | Behavior | When to Use |
|---------|----------|-------------|
| `binary` | Only for positive class | Binary classification |
| `macro` | Unweighted mean across classes | Equal importance per class |
| `weighted` | Weighted by class support | Account for class imbalance |
| `micro` | Global TP, FP, FN counts | Same as accuracy for single-label |

### roc_auc_score

Area Under the ROC Curve. Measures discrimination ability across all thresholds. Requires probability scores.

```python
from sklearn.metrics import roc_auc_score, roc_curve

# --- Binary ---
y_proba = model.predict_proba(X_test)[:, 1]  # Probability of positive class
auc = roc_auc_score(y_test, y_proba)
print(f"ROC-AUC: {auc:.3f}")

# --- ROC curve data (for plotting) ---
fpr, tpr, thresholds = roc_curve(y_test, y_proba)

# --- Multi-class ---
auc_ovr = roc_auc_score(y_test, model.predict_proba(X_test), multi_class="ovr")
```

### confusion_matrix

```python
from sklearn.metrics import confusion_matrix, ConfusionMatrixDisplay

cm = confusion_matrix(y_test, y_pred)
print(cm)
# Rows = actual, Columns = predicted
# [[TN, FP],
#  [FN, TP]]

# --- Visual display ---
disp = ConfusionMatrixDisplay(cm, display_labels=model.classes_)
disp.plot()
```

### classification_report

All-in-one summary of precision, recall, F1, and support per class.

```python
from sklearn.metrics import classification_report

report = classification_report(y_test, y_pred, digits=3)
print(report)

# --- As dictionary (for programmatic access) ---
report_dict = classification_report(y_test, y_pred, output_dict=True)
```

## Regression Metrics

```python
from sklearn.metrics import (
    mean_squared_error,
    mean_absolute_error,
    r2_score,
    root_mean_squared_error
)

mse = mean_squared_error(y_test, y_pred)
rmse = root_mean_squared_error(y_test, y_pred)  # Use this — squared param removed from mean_squared_error in 1.8
mae = mean_absolute_error(y_test, y_pred)
r2 = r2_score(y_test, y_pred)

print(f"MSE: {mse:.3f}")
print(f"RMSE: {rmse:.3f}")
print(f"MAE: {mae:.3f}")
print(f"R-squared: {r2:.3f}")
```

| Metric | Range | Interpretation |
|--------|-------|---------------|
| MSE | [0, inf) | Penalizes large errors heavily |
| RMSE | [0, inf) | Same units as target (interpretable) |
| MAE | [0, inf) | Robust to outliers |
| R-squared | (-inf, 1] | Fraction of variance explained; 1 = perfect |

## Cross-Validation

### cross_val_score

Evaluate a model with k-fold cross-validation.

```python
from sklearn.model_selection import cross_val_score

# --- Basic cross-validation ---
scores = cross_val_score(model, X, y, cv=5, scoring="accuracy")
print(f"CV scores: {scores}")
print(f"Mean: {scores.mean():.3f} +/- {scores.std():.3f}")
```

### Common Scoring Parameters

| Task | Scoring String |
|------|---------------|
| Classification accuracy | `"accuracy"` |
| F1 (binary) | `"f1"` |
| F1 (macro) | `"f1_macro"` |
| ROC-AUC | `"roc_auc"` |
| Precision | `"precision"` |
| Recall | `"recall"` |
| Regression R-squared | `"r2"` |
| Negative MSE | `"neg_mean_squared_error"` |
| Negative RMSE | `"neg_root_mean_squared_error"` |
| Negative MAE | `"neg_mean_absolute_error"` |

Note: Regression metrics are negated (higher is better in scikit-learn's convention).

### cross_validate (Multiple Metrics)

```python
from sklearn.model_selection import cross_validate

results = cross_validate(
    model, X, y, cv=5,
    scoring=["accuracy", "f1_macro", "roc_auc_ovr"],
    return_train_score=True
)
print(f"Test accuracy: {results['test_accuracy'].mean():.3f}")
print(f"Test F1: {results['test_f1_macro'].mean():.3f}")
```

### Stratified K-Fold (For Imbalanced Classes)

```python
from sklearn.model_selection import StratifiedKFold

skf = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)
scores = cross_val_score(model, X, y, cv=skf, scoring="f1")
```

## Hyperparameter Search

### GridSearchCV (Exhaustive Search)

```python
from sklearn.model_selection import GridSearchCV

param_grid = {
    "n_estimators": [50, 100, 200],
    "max_depth": [3, 5, 10, None],
    "min_samples_leaf": [1, 5, 10]
}

grid_search = GridSearchCV(
    RandomForestClassifier(random_state=42),
    param_grid,
    cv=5,
    scoring="f1",
    n_jobs=-1,
    refit=True               # Refit best model on full training data
)
grid_search.fit(X_train, y_train)

# --- Results ---
print(f"Best params: {grid_search.best_params_}")
print(f"Best score: {grid_search.best_score_:.3f}")

# --- Use best model directly ---
y_pred = grid_search.predict(X_test)
```

### RandomizedSearchCV (Faster)

Samples parameter combinations randomly. More efficient than grid search for large parameter spaces.

```python
from sklearn.model_selection import RandomizedSearchCV
from scipy.stats import randint, uniform

param_distributions = {
    "n_estimators": randint(50, 500),
    "max_depth": randint(3, 20),
    "min_samples_leaf": randint(1, 20),
    "max_features": uniform(0.1, 0.9)
}

random_search = RandomizedSearchCV(
    RandomForestClassifier(random_state=42),
    param_distributions,
    n_iter=50,               # Number of random samples
    cv=5,
    scoring="f1",
    n_jobs=-1,
    random_state=42
)
random_search.fit(X_train, y_train)
print(f"Best params: {random_search.best_params_}")
```

### Pipeline with GridSearchCV

```python
from sklearn.pipeline import Pipeline
from sklearn.model_selection import GridSearchCV

pipe = Pipeline([
    ("scaler", StandardScaler()),
    ("model", RandomForestClassifier(random_state=42))
])

# --- Use stepname__param for pipeline parameters ---
param_grid = {
    "model__n_estimators": [50, 100, 200],
    "model__max_depth": [3, 5, 10]
}

grid_search = GridSearchCV(pipe, param_grid, cv=5, scoring="accuracy")
grid_search.fit(X_train, y_train)
```

## Learning Curve

Diagnose bias/variance by plotting performance vs training set size.

```python
from sklearn.model_selection import learning_curve

train_sizes, train_scores, test_scores = learning_curve(
    model, X, y,
    train_sizes=[0.2, 0.4, 0.6, 0.8, 1.0],
    cv=5,
    scoring="accuracy",
    n_jobs=-1
)

# --- Summarize ---
for size, train_mean, test_mean in zip(
    train_sizes,
    train_scores.mean(axis=1),
    test_scores.mean(axis=1)
):
    print(f"n={size}: train={train_mean:.3f}, test={test_mean:.3f}")

# Large gap between train and test = overfitting (high variance)
# Both low = underfitting (high bias)
```

## Quick Reference

| Task | Function |
|------|----------|
| Classification accuracy | `accuracy_score(y_true, y_pred)` |
| Precision / recall / F1 | `precision_score()`, `recall_score()`, `f1_score()` |
| ROC-AUC | `roc_auc_score(y_true, y_proba)` |
| Confusion matrix | `confusion_matrix(y_true, y_pred)` |
| Full classification report | `classification_report(y_true, y_pred)` |
| MSE / RMSE / MAE | `mean_squared_error()`, `root_mean_squared_error()`, `mean_absolute_error()` |
| R-squared | `r2_score(y_true, y_pred)` |
| Cross-validate | `cross_val_score(model, X, y, cv=5)` |
| Grid search | `GridSearchCV(model, params, cv=5)` |
| Random search | `RandomizedSearchCV(model, params, n_iter=50)` |
| Learning curve | `learning_curve(model, X, y, cv=5)` |
