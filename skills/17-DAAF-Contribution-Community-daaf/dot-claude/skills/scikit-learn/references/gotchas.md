# Gotchas & Common Mistakes

Common pitfalls with scikit-learn, organized as Problem / Why / Fix.

## Contents

- [Data Leakage (Fitting on Full Data Before Split)](#data-leakage-fitting-on-full-data-before-split)
- [Forgetting to Scale for Distance-Based Methods](#forgetting-to-scale-for-distance-based-methods)
- [Interpreting t-SNE/UMAP Distances as Real Distances](#interpreting-t-sneumap-distances-as-real-distances)
- [Using Accuracy with Imbalanced Classes](#using-accuracy-with-imbalanced-classes)
- [Class Imbalance (class_weight='balanced')](#class-imbalance-class_weightbalanced)
- [Not Setting random_state for Reproducibility](#not-setting-random_state-for-reproducibility)
- [K-Means Initialization Sensitivity](#k-means-initialization-sensitivity)
- [Train-Test Contamination via Pipeline](#train-test-contamination-via-pipeline)
- [Using .score() Without Knowing the Metric](#using-score-without-knowing-the-metric)
- [Mixed Data Types in Clustering](#mixed-data-types-in-clustering)

## Data Leakage (Fitting on Full Data Before Split)

**Problem:** Fitting a scaler or encoder on the full dataset before splitting into train/test, then using the transformed data for evaluation.

**Why:** The test set statistics "leak" into the training process. The scaler learns the mean and std of test data, so the model indirectly sees test data during training. This inflates evaluation metrics.

**Fix:** Always fit transformers on training data only. Use a Pipeline to automate this.

```python
# --- Wrong ---
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)          # Fits on ALL data including test
X_train, X_test = train_test_split(X_scaled, ...)

# --- Right ---
X_train, X_test = train_test_split(X, ...)
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)  # Fit on train only
X_test_scaled = scaler.transform(X_test)         # Transform test with train stats

# --- Best (Pipeline handles it automatically) ---
pipe = make_pipeline(StandardScaler(), LogisticRegression())
pipe.fit(X_train, y_train)
pipe.score(X_test, y_test)
```

## Forgetting to Scale for Distance-Based Methods

**Problem:** Using KMeans, DBSCAN, KNN, SVM, or PCA on unscaled data where features have different units or ranges.

**Why:** Distance-based methods treat all features equally in distance calculations. A feature ranging 0-1,000,000 will dominate one ranging 0-1, regardless of actual importance.

**Fix:** Always scale before distance-based methods. StandardScaler is the default; RobustScaler if outliers are present.

```python
# --- Wrong ---
kmeans = KMeans(n_clusters=4)
kmeans.fit(X)  # "income" in thousands dominates "age" in decades

# --- Right ---
X_scaled = StandardScaler().fit_transform(X)
kmeans = KMeans(n_clusters=4)
kmeans.fit(X_scaled)
```

**Methods that require scaling:** KMeans, DBSCAN, HDBSCAN, AgglomerativeClustering (with Euclidean), PCA, t-SNE, UMAP, SVM/SVR, KNN, Lasso, Ridge, ElasticNet.

**Methods that do NOT require scaling:** Tree-based models (DecisionTree, RandomForest, GradientBoosting), NaiveBayes.

## Interpreting t-SNE/UMAP Distances as Real Distances

**Problem:** Drawing conclusions about cluster sizes, between-cluster distances, or data density from a t-SNE or UMAP plot.

**Why:** These algorithms distort distances to preserve local neighborhoods. Cluster sizes are equalized, between-cluster gaps are unreliable, and random noise can appear structured at certain parameter values.

**Fix:** Use t-SNE/UMAP for visualization only. Validate any apparent structure with formal clustering and metrics (silhouette score, etc.). Run multiple parameter values to check sensitivity.

```python
# --- Run multiple perplexity/n_neighbors values ---
for perp in [5, 15, 30, 50]:
    tsne = TSNE(n_components=2, perplexity=perp, random_state=42)
    embedding = tsne.fit_transform(X_scaled)
    # If "clusters" disappear at different perplexity, they are artifacts
```

## Using Accuracy with Imbalanced Classes

**Problem:** Reporting accuracy on a dataset where one class dominates (e.g., 95% negative, 5% positive).

**Why:** A model that predicts "negative" for everything achieves 95% accuracy while being useless for the minority class.

**Fix:** Use precision, recall, F1, or ROC-AUC instead. For training, use `class_weight="balanced"` or resampling.

```python
# --- Wrong ---
accuracy = model.score(X_test, y_test)  # 95% but predicts all negative

# --- Right ---
from sklearn.metrics import classification_report, f1_score
print(classification_report(y_test, y_pred))
f1 = f1_score(y_test, y_pred, average="macro")

# --- Address in training ---
model = RandomForestClassifier(class_weight="balanced", random_state=42)
```

## Class Imbalance (class_weight='balanced')

**Problem:** The model is biased toward the majority class and performs poorly on the minority class.

**Why:** By default, each training sample contributes equally to the loss function. With 95/5 class split, the model learns to predict the majority class.

**Fix:** Use `class_weight="balanced"` to weight samples inversely proportional to class frequency.

```python
# --- Works with most classifiers ---
model = LogisticRegression(class_weight="balanced", max_iter=1000)
model = RandomForestClassifier(class_weight="balanced", random_state=42)
model = SVC(class_weight="balanced")
```

## Not Setting random_state for Reproducibility

**Problem:** Running the same code twice produces different results.

**Why:** Many scikit-learn operations use random number generation: train_test_split, KMeans initialization, tree construction, etc.

**Fix:** Set `random_state` on every estimator and function call that accepts it.

```python
# --- Set on everything ---
X_train, X_test, y_train, y_test = train_test_split(X, y, random_state=42)
model = RandomForestClassifier(n_estimators=100, random_state=42)
kmeans = KMeans(n_clusters=4, random_state=42)
```

## K-Means Initialization Sensitivity

**Problem:** KMeans gives different results each time, or finds a clearly suboptimal solution.

**Why:** KMeans converges to local optima depending on initial centroid placement. A single random initialization may find a poor solution.

**Fix:** Use `n_init=10` or higher. Under `n_init='auto'` (default since 1.4), n_init=1 for `init='k-means++'` and n_init=10 for `init='random'`. Each initialization runs the full algorithm, and the best result (lowest inertia) is kept.

```python
# --- Use multiple initializations ---
kmeans = KMeans(n_clusters=4, n_init=10, random_state=42)

# --- For critical applications, use even more ---
kmeans = KMeans(n_clusters=4, n_init=50, random_state=42)
```

## Train-Test Contamination via Pipeline

**Problem:** Preprocessing steps outside the pipeline leak test information.

**Why:** If you scale data before cross-validation (outside the pipeline), the scaler sees all folds including the validation fold. This is a subtle form of data leakage.

**Fix:** Put all preprocessing inside the Pipeline so cross-validation handles the split correctly.

```python
# --- Wrong: scaling outside pipeline ---
X_scaled = StandardScaler().fit_transform(X)   # Leaks test fold info
scores = cross_val_score(model, X_scaled, y, cv=5)

# --- Right: scaling inside pipeline ---
pipe = make_pipeline(StandardScaler(), model)
scores = cross_val_score(pipe, X, y, cv=5)     # Scaler fits on train fold only
```

## Using .score() Without Knowing the Metric

**Problem:** Calling `model.score(X, y)` and assuming it returns accuracy (or R-squared) without checking.

**Why:** Different estimators return different default metrics:
- Classifiers: accuracy
- Regressors: R-squared
- Some clusterers: no `.score()` method

**Fix:** Use explicit metrics from `sklearn.metrics` instead of relying on `.score()`.

```python
# --- Explicit is better ---
from sklearn.metrics import accuracy_score, r2_score, f1_score

# Classification
accuracy = accuracy_score(y_test, y_pred)
f1 = f1_score(y_test, y_pred, average="macro")

# Regression
r2 = r2_score(y_test, y_pred)
```

## Mixed Data Types in Clustering

**Problem:** Attempting to cluster data that has both numeric and categorical features using KMeans or other standard algorithms.

**Why:** KMeans uses Euclidean distance, which is only meaningful for numeric features. One-hot encoding categorical features inflates dimensionality and distorts distances.

**Fix:** Use Gower distance (which handles mixed types) with AgglomerativeClustering, or use ColumnTransformer for careful preprocessing.

```python
# --- Option 1: Gower distance with scipy + sklearn ---
import gower  # pip install gower
distance_matrix = gower.gower_matrix(df)

from sklearn.cluster import AgglomerativeClustering
agg = AgglomerativeClustering(
    n_clusters=4,
    metric="precomputed",
    linkage="average"
)
labels = agg.fit_predict(distance_matrix)

# --- Option 2: Careful preprocessing + KMeans ---
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler, OneHotEncoder

preprocessor = ColumnTransformer([
    ("num", StandardScaler(), numeric_cols),
    ("cat", OneHotEncoder(drop="first"), categorical_cols)
])
X_processed = preprocessor.fit_transform(df)
# Note: one-hot columns have different scale than standardized columns
# This approach works but may bias toward categorical features
```

## Quick Fix Table

| Problem | Quick Fix |
|---------|-----------|
| Data leakage | Use `Pipeline` for preprocessing + model |
| Not scaled | `StandardScaler().fit_transform(X_train)` |
| t-SNE distances | Run multiple perplexity values; validate clusters formally |
| Imbalanced classes | `class_weight="balanced"` + F1/ROC-AUC metrics |
| Different results each run | Set `random_state=42` everywhere |
| KMeans bad solution | Use `n_init=10` or higher |
| Preprocessing outside CV | Put all steps inside `Pipeline` |
| Unknown `.score()` metric | Use explicit `sklearn.metrics` functions |
| Mixed data clustering | Gower distance or careful `ColumnTransformer` |
| Convergence warning | Increase `max_iter` |

## Advanced Resampling for Class Imbalance

For advanced resampling methods (SMOTE, ADASYN, BorderlineSMOTE), the
`imbalanced-learn` library is available but not pre-installed. In most cases,
`class_weight="balanced"` is sufficient for tree-based models. Install if needed:
`uv pip install --system imbalanced-learn`
