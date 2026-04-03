# Fairness Assessment with fairlearn

fairlearn is a toolkit for assessing and improving fairness of ML models. It integrates with scikit-learn's estimator API: wrap any classifier, compute metrics disaggregated by sensitive features, and apply mitigation strategies (post-processing or in-processing). For the conceptual framework -- impossibility theorems, fairness criteria definitions, civil rights connection, and when fairness assessment is required -- see `supervised-ml.md` in the `data-scientist` skill. This file covers only fairlearn syntax.

## Essential Imports

```python
# --- Assessment ---
from fairlearn.metrics import (
    MetricFrame,
    selection_rate,
    demographic_parity_difference,
    demographic_parity_ratio,
    equalized_odds_difference,
)

# --- Mitigation: post-processing ---
from fairlearn.postprocessing import ThresholdOptimizer

# --- Mitigation: in-processing ---
from fairlearn.reductions import ExponentiatedGradient, DemographicParity, EqualizedOdds
```

**Version note:** fairlearn 0.12.0 is pinned in the DAAF Dockerfile. Version 0.13.0 declares `scipy<1.16.0` but the environment has scipy 1.17.0, making it incompatible. Monitor for 0.14.0+ which may resolve this.

## Assessing Fairness: MetricFrame

MetricFrame computes any scikit-learn metric disaggregated by one or more sensitive features. This is the primary assessment tool.

```python
from fairlearn.metrics import MetricFrame, selection_rate
from sklearn.metrics import accuracy_score, precision_score, recall_score

# --- Compute multiple metrics disaggregated by sensitive feature ---
# INTENT: Assess whether model performance differs across demographic groups
# ASSUMES: A_test is an array-like of sensitive feature values aligned with y_test
metrics = {
    "accuracy": accuracy_score,
    "precision": lambda y_t, y_p: precision_score(y_t, y_p, zero_division=0),
    "recall": lambda y_t, y_p: recall_score(y_t, y_p, zero_division=0),
    "selection_rate": selection_rate,
}

mf = MetricFrame(
    metrics=metrics,
    y_true=y_test,
    y_pred=y_pred,
    sensitive_features=A_test    # Array-like: group labels (e.g., race, gender)
)

# --- Overall (full-sample) metrics ---
print(mf.overall)

# --- Group-level metrics ---
print(mf.by_group)

# --- Disparity summary ---
print("Max difference:", mf.difference())   # Largest gap between any two groups
print("Min ratio:", mf.ratio())             # Smallest ratio between any two groups
print("Group min:", mf.group_min())
print("Group max:", mf.group_max())
```

### MetricFrame with Multiple Sensitive Features

```python
# --- Intersectional analysis: disaggregate by two features simultaneously ---
mf_intersect = MetricFrame(
    metrics={"accuracy": accuracy_score},
    y_true=y_test,
    y_pred=y_pred,
    sensitive_features=df_test[["race", "gender"]]   # DataFrame with multiple columns
)
print(mf_intersect.by_group)
```

### Visualization

```python
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

# --- Bar chart of group-level metrics ---
fig, ax = plt.subplots(figsize=(10, 6))
mf.by_group.plot(kind="bar", ax=ax)
ax.set_title("Model Performance by Group")
ax.set_ylabel("Metric Value")
plt.xticks(rotation=45)
plt.tight_layout()
plt.savefig(f"{OUTPUT_DIR}/fairness_by_group.png", dpi=150)
plt.close()
print(f"Saved: {OUTPUT_DIR}/fairness_by_group.png")
```

## Fairness Metrics

Standalone convenience functions for common fairness measures. These wrap MetricFrame patterns internally.

| Function | What It Measures | Signature |
|----------|-----------------|-----------|
| `selection_rate` | P(Y_hat=1) -- fraction predicted positive | `(y_true, y_pred)` |
| `demographic_parity_difference` | Max difference in selection rate across groups | `(y_true, y_pred, sensitive_features=...)` |
| `demographic_parity_ratio` | Min ratio of selection rates across groups | `(y_true, y_pred, sensitive_features=...)` |
| `equalized_odds_difference` | Max difference in TPR or FPR across groups | `(y_true, y_pred, sensitive_features=...)` |
| `false_positive_rate` | FPR for a single group (use within MetricFrame) | `(y_true, y_pred)` |
| `false_negative_rate` | FNR for a single group (use within MetricFrame) | `(y_true, y_pred)` |
| `true_positive_rate` | TPR for a single group (use within MetricFrame) | `(y_true, y_pred)` |
| `equal_opportunity_difference` | Max difference in TPR (recall) across groups | `(y_true, y_pred, sensitive_features=...)` |

**Interpreting thresholds:**
- Demographic parity difference: 0 = perfect parity; closer to 0 is fairer
- Demographic parity ratio: 1 = perfect parity; the "four-fifths rule" uses 0.8 as a threshold
- Equalized odds difference: 0 = equal TPR and FPR across groups

```python
from fairlearn.metrics import demographic_parity_difference, demographic_parity_ratio

dpd = demographic_parity_difference(y_test, y_pred, sensitive_features=A_test)
dpr = demographic_parity_ratio(y_test, y_pred, sensitive_features=A_test)
print(f"Demographic parity difference: {dpd:.3f}")
print(f"Demographic parity ratio: {dpr:.3f}")
```

## Mitigation: ThresholdOptimizer (Post-Processing)

ThresholdOptimizer finds group-specific decision thresholds that optimize a performance objective subject to a fairness constraint. It does **not** retrain the model -- it adjusts decision boundaries on the existing model's probability outputs.

**When to use:** Quick fairness improvement without retraining. Requires the base model to produce probability scores (`predict_proba` or `decision_function`).

```python
from fairlearn.postprocessing import ThresholdOptimizer

# --- Post-process an already-trained classifier ---
to = ThresholdOptimizer(
    estimator=trained_model,       # Any sklearn classifier with predict_proba
    constraints="equalized_odds",  # Fairness constraint (see table below)
    objective="accuracy_score",    # Performance objective to maximize
    prefit=True                    # True = estimator already fitted; False = will refit
)

# --- Fit the threshold optimizer ---
to.fit(X_train, y_train, sensitive_features=A_train)

# --- Predict with fairness-adjusted thresholds ---
y_pred_fair = to.predict(X_test, sensitive_features=A_test, random_state=42)
```

**Score extraction:** ThresholdOptimizer uses `predict_method` to determine how
scores are obtained from the base model. Default is `"deprecated"` (auto-detect).
Set explicitly if your model lacks `predict_proba`:

```python
# For models with only decision_function (e.g., SVC without probability=True)
to = ThresholdOptimizer(
    estimator=svc_model,
    constraints="equalized_odds",
    predict_method="decision_function",
    prefit=True,
)
```

### Constraint Options for ThresholdOptimizer

| Constraint String | Matches Across Groups |
|-------------------|----------------------|
| `"demographic_parity"` | Selection rates (P(Y_hat=1)) |
| `"equalized_odds"` | True positive rate AND false positive rate |
| `"true_positive_rate_parity"` | True positive rate (recall) |
| `"false_positive_rate_parity"` | False positive rate |
| `"true_negative_rate_parity"` | True negative rate |
| `"false_negative_rate_parity"` | False negative rate (miss rate) |

## Mitigation: ExponentiatedGradient (In-Processing)

ExponentiatedGradient retrains the model subject to fairness constraints using a reductions approach. It solves a sequence of re-weighted classification problems to find a fair randomized classifier. More powerful than post-processing but more computationally expensive.

**When to use:** When threshold adjustment is insufficient, or when you want fairness built into the model training process rather than applied after the fact.

```python
from fairlearn.reductions import ExponentiatedGradient, EqualizedOdds
from sklearn.tree import DecisionTreeClassifier

# --- Define base estimator and fairness constraint ---
base_model = DecisionTreeClassifier(max_depth=5, random_state=42)
constraint = EqualizedOdds(difference_bound=0.01)

# --- Train with fairness constraints ---
mitigator = ExponentiatedGradient(
    estimator=base_model,
    constraints=constraint,
    eps=0.01,         # Fairness violation tolerance
    max_iter=50       # Maximum iterations of the algorithm
)

mitigator.fit(X_train, y_train, sensitive_features=A_train)
y_pred_fair = mitigator.predict(X_test)
```

### Constraint Objects for ExponentiatedGradient

| Class | Constrains | Use When |
|-------|-----------|----------|
| `DemographicParity()` | Equal selection rates across groups | Decisions should be independent of group membership |
| `EqualizedOdds()` | Equal TPR and FPR across groups | Error rates should be equal across groups |
| `ErrorRateParity()` | Equal overall error rates | Total misclassification should be group-independent |
| `TruePositiveRateParity()` | Equal recall across groups | Missing positive cases is the key concern |
| `FalsePositiveRateParity()` | Equal FPR across groups | False alarms are the key concern |

All constraint classes accept an optional `difference_bound` parameter to set the maximum allowed disparity.

## Visualization and Reporting

### Comparing Before and After Mitigation

```python
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from fairlearn.metrics import MetricFrame, selection_rate
from sklearn.metrics import accuracy_score

# --- Build MetricFrames for original and mitigated predictions ---
metrics = {"accuracy": accuracy_score, "selection_rate": selection_rate}

mf_original = MetricFrame(
    metrics=metrics, y_true=y_test, y_pred=y_pred_original,
    sensitive_features=A_test
)
mf_mitigated = MetricFrame(
    metrics=metrics, y_true=y_test, y_pred=y_pred_mitigated,
    sensitive_features=A_test
)

# --- Report overall performance and disparity side by side ---
print("=== Original Model ===")
print(f"Overall accuracy: {mf_original.overall['accuracy']:.3f}")
print(f"DP difference:    {mf_original.difference()['selection_rate']:.3f}")

print("\n=== Mitigated Model ===")
print(f"Overall accuracy: {mf_mitigated.overall['accuracy']:.3f}")
print(f"DP difference:    {mf_mitigated.difference()['selection_rate']:.3f}")

# --- Visual comparison ---
fig, axes = plt.subplots(1, 2, figsize=(14, 6))
mf_original.by_group.plot(kind="bar", ax=axes[0], title="Before Mitigation")
mf_mitigated.by_group.plot(kind="bar", ax=axes[1], title="After Mitigation")
plt.tight_layout()
plt.savefig(f"{OUTPUT_DIR}/fairness_before_after.png", dpi=150)
plt.close()
print(f"Saved: {OUTPUT_DIR}/fairness_before_after.png")
```

### DAAF Reporting Integration

When reporting fairness assessment results in DAAF research projects:

1. **Always present fairness metrics alongside overall performance** -- a model is not fully evaluated until both are reported
2. **State which fairness criterion was chosen and why** -- this is a normative decision, not a purely technical one (see `supervised-ml.md` in the `data-scientist` skill for guidance)
3. **Report group-level metrics, not just aggregate disparity** -- use `mf.by_group` to show the full picture
4. **Document the sensitive feature definition** -- how groups were defined and any limitations of the categorization

## Operational Caveats

1. **Fairness metrics can conflict.** The impossibility theorems (see `supervised-ml.md`) mean you cannot optimize all fairness criteria simultaneously. Choose deliberately.
2. **ThresholdOptimizer is stochastic.** Results may vary across runs. Always set `random_state` for reproducibility.
3. **Small group sizes make metrics unstable.** With fewer than ~50 observations in a group, fairness metrics have wide confidence intervals. Report group sizes alongside metrics.
4. **Fairness assessment is not a one-time check.** Model fairness can change as the data distribution shifts over time. Reassess periodically.
5. **Post-processing can degrade overall performance.** ThresholdOptimizer improves fairness at some cost to overall accuracy. Always report both before and after metrics.

## Quick Reference

| Task | Code |
|------|------|
| Disaggregate metrics by group | `MetricFrame(metrics=..., y_true=..., y_pred=..., sensitive_features=...)` |
| Group-level results | `mf.by_group` |
| Overall results | `mf.overall` |
| Max disparity (difference) | `mf.difference()` |
| Min ratio across groups | `mf.ratio()` |
| Demographic parity check | `demographic_parity_difference(y_true, y_pred, sensitive_features=...)` |
| Four-fifths rule check | `demographic_parity_ratio(y_true, y_pred, sensitive_features=...)` |
| Equalized odds check | `equalized_odds_difference(y_true, y_pred, sensitive_features=...)` |
| Post-process for fairness | `ThresholdOptimizer(estimator=model, constraints="equalized_odds", prefit=True)` |
| Retrain with constraints | `ExponentiatedGradient(estimator=base, constraints=DemographicParity())` |
| Plot group metrics | `mf.by_group.plot(kind="bar")` |
