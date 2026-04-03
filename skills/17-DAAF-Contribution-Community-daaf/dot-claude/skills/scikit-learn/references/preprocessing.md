# Preprocessing

Scalers, encoders, ColumnTransformer, and Pipeline construction for preparing data before ML. Proper preprocessing prevents data leakage and ensures reproducibility.

## Scalers

### StandardScaler (Z-score Normalization)

Centers to mean=0, scales to std=1. The default choice for most ML methods.

```python
from sklearn.preprocessing import StandardScaler

scaler = StandardScaler()
X_scaled = scaler.fit_transform(X_train)       # Fit on train, transform train
X_test_scaled = scaler.transform(X_test)        # Transform test (using train stats)

# --- Inspect learned parameters ---
print(f"Means: {scaler.mean_}")
print(f"Stds: {scaler.scale_}")
```

### MinMaxScaler (Range Normalization)

Scales features to [0, 1] range. Useful when features need bounded values.

```python
from sklearn.preprocessing import MinMaxScaler

scaler = MinMaxScaler(feature_range=(0, 1))     # Default range
X_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)
```

### RobustScaler (Outlier-Resistant)

Uses median and IQR instead of mean and std. Better when data has outliers.

```python
from sklearn.preprocessing import RobustScaler

scaler = RobustScaler(
    with_centering=True,     # Subtract median
    with_scaling=True,       # Divide by IQR
    quantile_range=(25.0, 75.0)  # IQR boundaries
)
X_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)
```

### Scaler Comparison

| Scaler | Centers By | Scales By | Outlier Robust? | When to Use |
|--------|-----------|-----------|-----------------|-------------|
| StandardScaler | Mean | Std dev | No | Default choice; normal-ish data |
| MinMaxScaler | Min | Range | No | Need bounded [0,1] values |
| RobustScaler | Median | IQR | Yes | Data has outliers |
| MaxAbsScaler | - | Max abs | No | Sparse data (preserves zeros) |

## Encoders

### OneHotEncoder (Nominal Categories)

Creates binary columns for each category. Use for unordered categorical variables.

```python
from sklearn.preprocessing import OneHotEncoder

encoder = OneHotEncoder(
    sparse_output=False,     # Dense array (True for sparse matrix)
    drop="first",            # Drop first category to avoid multicollinearity
    handle_unknown="ignore"  # Unknown categories become all-zeros
)
X_encoded = encoder.fit_transform(X_categorical)

# --- See category mappings ---
print(encoder.categories_)
print(encoder.get_feature_names_out())
```

### OrdinalEncoder (Ordered Categories)

Maps categories to integers. Use for ordered categorical variables.

```python
from sklearn.preprocessing import OrdinalEncoder

encoder = OrdinalEncoder(
    categories=[["low", "medium", "high"]],  # Specify order
    handle_unknown="use_encoded_value",
    unknown_value=-1
)
X_encoded = encoder.fit_transform(X_ordinal)
```

### LabelEncoder (Target Variable)

Encodes target labels as integers. Use only for the target (y), not features.

```python
from sklearn.preprocessing import LabelEncoder

le = LabelEncoder()
y_encoded = le.fit_transform(y)

# --- Decode back ---
y_decoded = le.inverse_transform(y_encoded)
print(f"Classes: {le.classes_}")
```

## ColumnTransformer (Mixed Column Types)

Applies different transformers to different columns. Essential when a dataset has both numeric and categorical features.

```python
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler, OneHotEncoder

# --- Define column groups ---
numeric_features = ["age", "income", "score"]
categorical_features = ["state", "occupation"]

# --- Build ColumnTransformer ---
preprocessor = ColumnTransformer(
    transformers=[
        ("num", StandardScaler(), numeric_features),
        ("cat", OneHotEncoder(drop="first", handle_unknown="ignore"), categorical_features)
    ],
    remainder="drop"         # 'drop' (default), 'passthrough', or transformer
)

X_processed = preprocessor.fit_transform(X_train)
X_test_processed = preprocessor.transform(X_test)

# --- Get output feature names ---
print(preprocessor.get_feature_names_out())
```

## Pipeline Construction

Pipelines chain preprocessing and model steps into a single estimator. This is the recommended pattern because it prevents data leakage during cross-validation.

### Basic Pipeline

```python
from sklearn.pipeline import Pipeline, make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier

# --- Named steps (explicit) ---
pipe = Pipeline([
    ("scaler", StandardScaler()),
    ("model", RandomForestClassifier(n_estimators=100, random_state=42))
])

# --- Shorthand (auto-named) ---
pipe = make_pipeline(StandardScaler(), RandomForestClassifier(n_estimators=100, random_state=42))

# --- Use like any estimator ---
pipe.fit(X_train, y_train)
y_pred = pipe.predict(X_test)
accuracy = pipe.score(X_test, y_test)
```

### Pipeline with ColumnTransformer

```python
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.ensemble import GradientBoostingClassifier

# --- Preprocessor ---
preprocessor = ColumnTransformer([
    ("num", StandardScaler(), numeric_features),
    ("cat", OneHotEncoder(drop="first", handle_unknown="ignore"), categorical_features)
])

# --- Full pipeline ---
pipe = Pipeline([
    ("preprocessor", preprocessor),
    ("model", GradientBoostingClassifier(random_state=42))
])

pipe.fit(X_train, y_train)
y_pred = pipe.predict(X_test)
```

### Pipeline with Cross-Validation

```python
from sklearn.model_selection import cross_val_score

# --- Cross-validation respects the pipeline ---
# Scaler is fit ONLY on training folds, preventing data leakage
scores = cross_val_score(pipe, X, y, cv=5, scoring="accuracy")
print(f"CV accuracy: {scores.mean():.3f} +/- {scores.std():.3f}")
```

### Accessing Pipeline Steps

```python
# --- Access a specific step ---
pipe.named_steps["model"]
pipe["model"]               # Shorthand (1.0+)

# --- Access step parameters (for GridSearchCV) ---
# Use double underscore: stepname__parameter
param_grid = {
    "model__n_estimators": [50, 100, 200],
    "model__max_depth": [3, 5, 10]
}
```

## DataFrame Output from Transformers

```python
# --- Get pandas DataFrame output instead of numpy array ---
from sklearn.preprocessing import StandardScaler

scaler = StandardScaler()
scaler.set_output(transform="pandas")
X_scaled = scaler.fit_transform(X_df)  # Returns DataFrame with column names
```

## Quick Reference

| Task | Class |
|------|-------|
| Z-score normalize | `StandardScaler()` |
| Scale to [0,1] | `MinMaxScaler()` |
| Outlier-robust scaling | `RobustScaler()` |
| One-hot encode | `OneHotEncoder(drop="first")` |
| Ordinal encode | `OrdinalEncoder(categories=...)` |
| Encode target labels | `LabelEncoder()` |
| Mix column types | `ColumnTransformer(...)` |
| Chain steps | `Pipeline([...])` or `make_pipeline(...)` |
| DataFrame output | `transformer.set_output(transform="pandas")` |
