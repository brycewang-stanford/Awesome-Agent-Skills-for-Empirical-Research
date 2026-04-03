# Regression (ML)

Prediction-focused regression with scikit-learn: Ridge, Lasso, ElasticNet, DecisionTreeRegressor, RandomForestRegressor, GradientBoostingRegressor, HistGradientBoostingRegressor, SVR, and KNeighborsRegressor.

> **Scope boundary:** This reference covers **prediction-focused** ML regression where the goal is accurate out-of-sample predictions. For **econometric regression** with standard errors, hypothesis tests, coefficient interpretation, and causal identification (OLS, fixed effects, IV, DiD), use the `pyfixest` or `statsmodels` skills instead. scikit-learn regressors do not produce standard errors, p-values, or confidence intervals for coefficients.

## Regressor Comparison

| Regressor | Interpretable? | Handles Nonlinear? | Regularized? | Key Strength |
|-----------|---------------|--------------------|----|--------------|
| Ridge | Yes (coefficients) | No | L2 | Multicollinearity; stable |
| Lasso | Yes (sparse coefs) | No | L1 | Feature selection |
| ElasticNet | Yes (sparse coefs) | No | L1 + L2 | Balance of Ridge + Lasso |
| DecisionTree | Yes (tree viz) | Yes | No | Interpretable rules |
| RandomForest | Moderate | Yes | No | Robust; low tuning |
| GradientBoosting | Moderate | Yes | No | High accuracy |
| HistGradientBoosting | Moderate | Yes | No | Large data; native NaN |
| SVR | No | Yes (kernel) | Yes | Complex nonlinear |
| KNeighbors | No | Yes | No | Simple baseline |

## Ridge Regression (L2 Regularization)

Linear regression with L2 penalty. Shrinks coefficients toward zero without eliminating them. Effective when features are correlated (multicollinearity).

```python
from sklearn.linear_model import Ridge

model = Ridge(
    alpha=1.0,               # Regularization strength (larger = stronger)
    fit_intercept=True,
    random_state=42
)
model.fit(X_train, y_train)

# --- Predictions ---
y_pred = model.predict(X_test)

# --- Coefficients ---
print(f"Coefficients: {model.coef_}")
print(f"Intercept: {model.intercept_}")
```

### Choosing alpha with Cross-Validation

```python
from sklearn.linear_model import RidgeCV

model = RidgeCV(
    alphas=[0.01, 0.1, 1.0, 10.0, 100.0],
    cv=5
)
model.fit(X_train, y_train)
print(f"Best alpha: {model.alpha_}")
```

## Lasso Regression (L1 Regularization)

Linear regression with L1 penalty. Drives some coefficients exactly to zero, performing automatic feature selection.

```python
from sklearn.linear_model import Lasso

model = Lasso(
    alpha=0.1,               # Regularization strength
    max_iter=10000,          # Increase if convergence warning
    random_state=42
)
model.fit(X_train, y_train)

# --- Nonzero coefficients (selected features) ---
n_selected = (model.coef_ != 0).sum()
print(f"Selected features: {n_selected} / {len(model.coef_)}")
```

### Choosing alpha with Cross-Validation

```python
from sklearn.linear_model import LassoCV

model = LassoCV(cv=5, random_state=42)
model.fit(X_train, y_train)
print(f"Best alpha: {model.alpha_:.4f}")
```

## ElasticNet (L1 + L2 Regularization)

Combines Ridge and Lasso penalties. Useful when there are correlated features and you want some feature selection.

```python
from sklearn.linear_model import ElasticNet

model = ElasticNet(
    alpha=0.1,               # Overall regularization strength
    l1_ratio=0.5,            # Mix: 0=Ridge, 1=Lasso, 0.5=equal blend
    max_iter=10000,
    random_state=42
)
model.fit(X_train, y_train)
```

### Choosing alpha and l1_ratio with Cross-Validation

```python
from sklearn.linear_model import ElasticNetCV

model = ElasticNetCV(
    l1_ratio=[0.1, 0.5, 0.7, 0.9, 1.0],
    cv=5,
    random_state=42
)
model.fit(X_train, y_train)
print(f"Best alpha: {model.alpha_:.4f}, l1_ratio: {model.l1_ratio_}")
```

## DecisionTreeRegressor

```python
from sklearn.tree import DecisionTreeRegressor

model = DecisionTreeRegressor(
    max_depth=5,
    min_samples_leaf=10,
    random_state=42
)
model.fit(X_train, y_train)
y_pred = model.predict(X_test)
```

## RandomForestRegressor

Ensemble of decision trees with bagging. Robust default choice for nonlinear regression.

```python
from sklearn.ensemble import RandomForestRegressor

model = RandomForestRegressor(
    n_estimators=100,
    max_depth=None,
    max_features=1.0,           # Fraction of features per split (1.0 = all for regression)
    min_samples_leaf=5,
    n_jobs=-1,
    random_state=42
)
model.fit(X_train, y_train)

# --- Feature importance ---
importances = model.feature_importances_
```

## GradientBoostingRegressor

Sequential ensemble that corrects previous errors. Often highest accuracy for tabular data.

```python
from sklearn.ensemble import GradientBoostingRegressor

model = GradientBoostingRegressor(
    n_estimators=200,
    learning_rate=0.1,
    max_depth=3,
    min_samples_leaf=10,
    subsample=0.8,
    random_state=42
)
model.fit(X_train, y_train)
```

## HistGradientBoostingRegressor

Faster histogram-based variant. Handles NaN natively.

```python
from sklearn.ensemble import HistGradientBoostingRegressor

model = HistGradientBoostingRegressor(
    max_iter=200,
    learning_rate=0.1,
    max_leaf_nodes=31,
    min_samples_leaf=20,
    random_state=42
)
model.fit(X_train, y_train)     # Handles NaN natively
```

## SVR (Support Vector Regression)

```python
from sklearn.svm import SVR

model = SVR(
    kernel="rbf",
    C=1.0,
    gamma="scale",
    epsilon=0.1              # Epsilon-tube width (no penalty inside)
)
model.fit(X_train_scaled, y_train)     # Scale features first
y_pred = model.predict(X_test_scaled)
```

## KNeighborsRegressor

```python
from sklearn.neighbors import KNeighborsRegressor

model = KNeighborsRegressor(
    n_neighbors=5,
    weights="distance",      # Inverse-distance weighting (better than 'uniform')
    n_jobs=-1
)
model.fit(X_train_scaled, y_train)     # Scale features first
y_pred = model.predict(X_test_scaled)
```

## Quick Model Comparison

```python
from sklearn.model_selection import cross_val_score
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler

regressors = {
    "Ridge": Ridge(alpha=1.0),
    "Lasso": Lasso(alpha=0.1, max_iter=10000),
    "RandomForest": RandomForestRegressor(n_estimators=100, random_state=42),
    "HistGradientBoosting": HistGradientBoostingRegressor(random_state=42),
}

for name, reg in regressors.items():
    pipe = make_pipeline(StandardScaler(), reg)
    scores = cross_val_score(pipe, X, y, cv=5, scoring="r2")
    print(f"{name}: R2 = {scores.mean():.3f} +/- {scores.std():.3f}")
```

## Beyond HistGradientBoosting: LightGBM and XGBoost

For use cases where scikit-learn's HistGradientBoostingRegressor is not sufficient, LightGBM and XGBoost provide additional capabilities. Both follow the scikit-learn estimator API (`fit`/`predict`).

```python
# LightGBM (available in DAAF Dockerfile)
import lightgbm as lgb
model = lgb.LGBMRegressor(
    n_estimators=100,
    learning_rate=0.1,
    num_leaves=31,
    random_state=42,
)
model.fit(X_train, y_train)

# XGBoost (optional install: uv pip install --system --no-deps xgboost)
import xgboost as xgb
model = xgb.XGBRegressor(
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
| Categorical features | Native | Native | Requires encoding |
| GPU support | No | Yes | Yes |

> **Guidance:** For most DAAF use cases, HistGradientBoosting is sufficient. Use LightGBM when SHAP TreeExplainer performance matters. Use XGBoost for custom loss functions.
