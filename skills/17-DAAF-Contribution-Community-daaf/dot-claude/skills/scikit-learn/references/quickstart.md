# Quickstart

Import patterns, the fit/predict/transform API, Pipeline construction, train-test splitting, and reproducibility with random_state.

## Installation

```bash
pip install scikit-learn
# or
uv add scikit-learn
# or
conda install -c conda-forge scikit-learn
```

### Verify Installation

```python
import sklearn
print(sklearn.__version__)  # Should be 1.8.x
```

### Common Companion Libraries

```bash
# Often needed alongside scikit-learn
pip install numpy pandas matplotlib
# For UMAP (not part of scikit-learn)
pip install umap-learn
```

## Core Concept: The Estimator API

Every scikit-learn object follows the same interface:

| Method | Purpose | Used By |
|--------|---------|---------|
| `fit(X, y)` | Learn from data | All estimators |
| `predict(X)` | Predict labels/values | Classifiers, regressors, clusterers |
| `transform(X)` | Transform data | Transformers (scalers, PCA, encoders) |
| `fit_transform(X)` | Fit + transform in one step | Transformers |
| `fit_predict(X)` | Fit + predict in one step | Clusterers |
| `score(X, y)` | Evaluate on data | Classifiers, regressors |

### Supervised Example (Classification)

```python
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split

# --- Split ---
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# --- Fit ---
model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X_train, y_train)

# --- Predict ---
y_pred = model.predict(X_test)

# --- Evaluate ---
accuracy = model.score(X_test, y_test)
print(f"Accuracy: {accuracy:.3f}")
```

### Unsupervised Example (Clustering)

```python
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler

# --- Scale (required for distance-based methods) ---
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# --- Fit ---
kmeans = KMeans(n_clusters=4, n_init=10, random_state=42)
kmeans.fit(X_scaled)

# --- Extract results ---
labels = kmeans.labels_          # Cluster assignment for each row
centers = kmeans.cluster_centers_ # Cluster centroids
inertia = kmeans.inertia_        # Within-cluster sum of squares
```

### Transformer Example (PCA)

```python
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler

# --- Scale first ---
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# --- Fit and transform ---
pca = PCA(n_components=5)
X_reduced = pca.fit_transform(X_scaled)

# --- Inspect results ---
print(f"Variance explained: {pca.explained_variance_ratio_}")
print(f"Total variance: {sum(pca.explained_variance_ratio_):.3f}")
```

## Pipeline Construction

Pipelines chain preprocessing and model steps into a single object. This prevents data leakage by ensuring that transformers are fit only on training data.

```python
from sklearn.pipeline import Pipeline, make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression

# --- Explicit Pipeline (named steps) ---
pipe = Pipeline([
    ("scaler", StandardScaler()),
    ("model", LogisticRegression(max_iter=1000))
])

# --- Shorthand (auto-named steps) ---
pipe = make_pipeline(StandardScaler(), LogisticRegression(max_iter=1000))

# --- Use like any estimator ---
pipe.fit(X_train, y_train)
y_pred = pipe.predict(X_test)
score = pipe.score(X_test, y_test)
```

## Train-Test Split

```python
from sklearn.model_selection import train_test_split

# --- Basic split ---
X_train, X_test, y_train, y_test = train_test_split(
    X, y,
    test_size=0.2,       # 20% for testing
    random_state=42      # Reproducibility
)

# --- Stratified split (preserves class proportions) ---
X_train, X_test, y_train, y_test = train_test_split(
    X, y,
    test_size=0.2,
    stratify=y,          # Maintain class balance
    random_state=42
)
```

## Reproducibility with random_state

Many scikit-learn estimators use random number generation. Setting `random_state` ensures reproducible results.

```python
# --- Set on individual estimators ---
model = RandomForestClassifier(n_estimators=100, random_state=42)
kmeans = KMeans(n_clusters=5, random_state=42)
X_train, X_test, y_train, y_test = train_test_split(X, y, random_state=42)

# --- Set globally (affects all numpy random operations) ---
import numpy as np
np.random.seed(42)
# Note: prefer per-estimator random_state over global seed for clarity
```

## Data Format: NumPy Arrays and Pandas DataFrames

scikit-learn accepts both NumPy arrays and pandas DataFrames as input:

```python
import numpy as np
import pandas as pd

# --- NumPy array (traditional) ---
X = np.array([[1, 2], [3, 4], [5, 6]])
y = np.array([0, 1, 0])

# --- Pandas DataFrame (preserves column names) ---
df = pd.DataFrame({"feature1": [1, 3, 5], "feature2": [2, 4, 6]})
X = df[["feature1", "feature2"]]
y = pd.Series([0, 1, 0])

# --- Get DataFrame output from transformers (1.2+) ---
from sklearn.preprocessing import StandardScaler
scaler = StandardScaler()
scaler.set_output(transform="pandas")
X_scaled = scaler.fit_transform(X)  # Returns DataFrame, not array
```

## Next Steps

- Need clustering? See `clustering.md`
- Need PCA or dimension reduction? See `decomposition.md`
- Need classification? See `classification.md`
- Need preprocessing pipelines? See `preprocessing.md`
- Common pitfalls? See `gotchas.md`
