# Supervised Machine Learning for Social Science Research

Methodological guidance for supervised machine learning in applied social science research — when to use prediction methods vs. inference methods, how model complexity decisions are governed by the bias-variance tradeoff, how cross-validation must adapt to social science data structures, and how to interpret ML outputs without claiming causation. This reference covers the *why* and *when* of supervised ML. For implementation syntax, load the `scikit-learn` skill.

**When to read this file:** Stage 8 analysis tasks involving classification, prediction, risk scoring, early warning systems, ML-based variable selection, or any task where the goal is predicting outcomes rather than estimating causal parameters.

**Relationship to other references:**
- For regression as *inference* (coefficient estimation, standard errors, hypothesis testing), see `./statistical-modeling.md`
- For causal identification strategies (DiD, IV, RDD) and causal ML (CATE, DML), see `./causal-inference.md`
- For unsupervised/exploratory analysis (clustering, dimension reduction), see `./exploratory-unsupervised.md`
- For descriptive analysis and association measurement, see `./descriptive-analysis.md`
- For chart selection when presenting ML results, see `./visualization-design.md`
- **Scope boundary:** This file covers supervised ML methodology only. Implementation syntax (scikit-learn API, SHAP API, fairlearn API) belongs in the `scikit-learn` skill's reference files.

## Acknowledgments

These materials draw extensively from several open-access resources that the authors have generously made available to the research community:

- Gareth James, Daniela Witten, Trevor Hastie, and Robert Tibshirani's *An Introduction to Statistical Learning*, 2nd Edition (https://www.statlearning.com/), particularly Chapters 2-10 on supervised learning methods
- Trevor Hastie, Robert Tibshirani, and Jerome Friedman's *The Elements of Statistical Learning*, 2nd Edition (https://hastie.su.domains/ElemStatLearn/download.html), particularly Chapters 7-10 on model assessment and ensemble methods
- Christoph Molnar's *Interpretable Machine Learning* (https://christophm.github.io/interpretable-ml-book/), the standard practitioner reference for model interpretation methods
- The scikit-learn project's comprehensive documentation and user guide (https://scikit-learn.org/)

## Contents

- [Quick Task Lookup](#quick-task-lookup)
- [Prediction vs. Inference: When to Use ML](#prediction-vs-inference-when-to-use-ml)
- [The Bias-Variance Tradeoff](#the-bias-variance-tradeoff)
- [Train/Test Discipline and Cross-Validation](#traintest-discipline-and-cross-validation)
  - [Missing Data in ML Pipelines](#missing-data-in-ml-pipelines)
- [Model Selection for Supervised Tasks](#model-selection-for-supervised-tasks)
  - [Sample Size Considerations](#sample-size-considerations)
- [Classification Methodology](#classification-methodology)
  - [Calibration: When Predictions Inform Individual Decisions](#calibration-when-predictions-inform-individual-decisions)
- [ML Regression Methodology](#ml-regression-methodology)
- [Ensemble Methods](#ensemble-methods)
- [Interpreting ML Models: The Causation Trap](#interpreting-ml-models-the-causation-trap)
- [Fairness, Bias, and Equity](#fairness-bias-and-equity)
- [When Deep Learning Methods Are Appropriate](#when-deep-learning-methods-are-appropriate)
- [Reporting Standards for Supervised ML in Research](#reporting-standards-for-supervised-ml-in-research)
- [Common Pitfalls for Social Scientists](#common-pitfalls-for-social-scientists)
- [References and Further Reading](#references-and-further-reading)

## Quick Task Lookup

| If the plan says... | Read this section |
|---------------------|-------------------|
| "predict," "classify," "risk score," "early warning" | Prediction vs. Inference |
| "model selection," "which algorithm" | Model Selection for Supervised Tasks |
| "cross-validate," "train/test," "hold-out" | Train/Test Discipline and Cross-Validation |
| "feature importance," "variable importance," "SHAP" | Interpreting ML Models: The Causation Trap |
| "fairness," "bias," "equity," "disparate impact" | Fairness, Bias, and Equity |
| "ensemble," "random forest," "boosting" | Ensemble Methods |
| "classification metrics," "precision," "recall," "AUC" | Classification Methodology |
| "regularization," "Ridge," "Lasso," "prediction error" | ML Regression Methodology |
| "deep learning," "neural network," "NLP," "text" | When Deep Learning Methods Are Appropriate |
| "report ML results," "present predictions" | Reporting Standards |

## Prediction vs. Inference: When to Use ML

This is the most consequential methodological decision in applied quantitative social science: whether the research question calls for *predicting outcomes* or *estimating parameters*. Getting this wrong means using the wrong tools, the wrong evaluation criteria, and the wrong language to describe results.

### The Two Cultures (Breiman, 2001)

Breiman's foundational paper identifies two distinct approaches to learning from data:

- **Data-modeling culture:** Assumes a stochastic model generated the data (e.g., Y = Xb + e). The goal is to estimate the parameters of that model. Success is judged by coefficient interpretability, goodness-of-fit, and the validity of statistical inferences about the parameters. This is the dominant tradition in econometrics and social science.
- **Algorithmic-modeling culture:** Treats the data-generating mechanism as unknown. The goal is to find an algorithm that accurately predicts new observations. Success is judged by held-out prediction accuracy. This is the dominant tradition in machine learning and computer science.

These cultures are not competing — they answer different questions. The error is using one culture's tools to answer the other culture's questions: applying ML when you need an interpretable causal estimate, or applying OLS when you need to predict who will drop out of school next year.

### The Explain-Predict Distinction (Shmueli, 2010)

Following Shmueli's (2010) influential framework, the distinction between explanatory and predictive modeling is not merely about technique — it manifests at every stage of the research process:

| Stage | Explanatory (use pyfixest/statsmodels) | Predictive (use scikit-learn) |
|-------|----------------------------------------|-------------------------------|
| **Goal** | Estimate a parameter (beta) accurately | Minimize prediction error on new data |
| **Variable selection** | Theory-driven (omitting a relevant variable causes bias) | Performance-driven (include features if they improve prediction) |
| **Model complexity** | Parsimony preferred (simpler models are more interpretable) | Complexity acceptable if it reduces test error |
| **Evaluation** | Coefficient significance, effect sizes, confidence intervals | Held-out accuracy, RMSE, AUC, calibration |
| **Regularization** | Avoided (biases the coefficient estimate) | Essential (reduces variance of predictions) |
| **Overfitting concern** | Specification error and omitted variable bias | Poor generalization to new data |
| **Primary output** | Estimated coefficients with standard errors | Predicted values for new observations |

A model can predict well yet have misleading coefficients (and vice versa). Following Mullainathan and Spiess's (2017) bridge paper, ML solves prediction problems while econometrics solves parameter estimation problems — they are complementary, not competing.

### Prediction Policy Problems (Kleinberg et al., 2015)

Kleinberg, Ludwig, Mullainathan, and Obermeyer (2015) identify an important class of policy decisions where prediction quality — not causal identification — is the binding constraint. In these problems:

- **The intervention is already decided** — the question is *whom to target*
- The causal effect of the intervention is known or assumed; ML adds value by improving the accuracy of targeting
- Examples in education: early warning systems for dropout, targeting tutoring resources to students most likely to benefit, identifying schools for inspection, screening financial aid applications

This is the strongest justification for ML in policy research. The researcher does not need to establish that tutoring causes better outcomes (that evidence already exists) — they need to predict which students are most likely to drop out so the tutoring can be directed to them.

### When Each Approach Is Appropriate

| Research Question | Approach | Tools |
|-------------------|----------|-------|
| "Does X cause Y?" | Causal inference | pyfixest, statsmodels |
| "What is the association between X and Y, controlling for Z?" | Statistical modeling | pyfixest, statsmodels |
| "Which students are most likely to drop out?" | Prediction | scikit-learn |
| "Where should we allocate intervention resources?" | Prediction policy problem | scikit-learn |
| "What variables predict Y?" (exploratory) | Prediction + interpretation | scikit-learn + SHAP |
| "Are there natural groupings in the data?" | Unsupervised | scikit-learn |

> **Cross-reference:** For causal inference methodology, see `causal-inference.md`. For inference-focused regression (coefficient estimation, standard errors, assumption checking), see `statistical-modeling.md`. For unsupervised/exploratory analysis, see `exploratory-unsupervised.md`.

## The Bias-Variance Tradeoff

### Why This Matters for Social Scientists

The bias-variance tradeoff is the foundational concept governing model complexity in prediction tasks. Social scientists trained in econometrics may find it counterintuitive because it inverts familiar priorities:

- **In inference:** Bias is the enemy. Unbiased estimators are preferred, and introducing bias (through regularization, omitting variables, or using the wrong functional form) is considered a methodological failure.
- **In prediction:** Some bias is *desirable* if it sufficiently reduces variance. Regularization (Ridge, Lasso, ElasticNet) deliberately introduces bias to reduce variance — the opposite of what econometric training teaches.

This is why ML models can predict better than OLS despite being "biased" estimators. The bias-variance tradeoff, formalized in Chapters 2-3 of James et al. (2021), governs all model complexity decisions in prediction.

### The Decomposition

The expected prediction error for a new observation decomposes into three irreducible components:

**Expected prediction error = Irreducible noise + Bias-squared + Variance**

- **Bias:** How far the average model prediction is from the truth across all possible training samples. Systematic error from model assumptions that are too simple for the true relationship.
- **Variance:** How much model predictions fluctuate across different training samples. A model with high variance fits each training set differently, producing unstable predictions.
- **Irreducible noise:** Inherent randomness in the outcome that no model can capture.

The practical consequences are direct:
- Simple models (linear regression with few features): high bias, low variance
- Complex models (deep decision trees, high-degree polynomials): low bias, high variance
- The optimal model minimizes *total* error, not either component alone

### Practical Implications

- Adding more features does NOT always improve prediction — beyond a point, additional features increase variance faster than they reduce bias (the "curse of dimensionality")
- Regularization shrinks coefficients toward zero, accepting bias for lower variance — this is why regularization almost always improves predictive performance
- Cross-validation empirically finds the bias-variance sweet spot by estimating test error across different model complexities
- "More data" reduces variance but not bias; "a more flexible model" reduces bias but increases variance
- The irreducible noise sets a floor on prediction error — no model, however complex, can beat it

## Train/Test Discipline and Cross-Validation

### Why Held-Out Evaluation Is Non-Negotiable

In-sample fit (R-squared, training accuracy) is meaningless for prediction tasks. A model that memorizes the training data — fitting every noise pattern — will show excellent in-sample performance and terrible generalization. Held-out evaluation is the only credible measure of predictive performance.

Following James et al. (2021, Ch. 5), the standard discipline is:

1. **Split** data into training (typically 80%) and test (typically 20%) — the test set is NEVER used for model selection, hyperparameter tuning, or feature engineering
2. **Use cross-validation** on the training set for model selection and hyperparameter tuning
3. **Evaluate** the final chosen model ONCE on the test set
4. **Report** the test set performance as the estimate of generalization error

Violating this discipline — tuning on the test set, selecting the model that performs best on the test set, or reporting cross-validation scores as final performance estimates — produces optimistic estimates that will not replicate.

### Cross-Validation Strategies for Social Science Data

**This is the most critical technical section for applied social science researchers.** Standard k-fold cross-validation assumes observations are independent and identically distributed (i.i.d.). Social science data almost always violates this assumption. Following Roberts et al. (2017), using standard CV on structured data dramatically overstates performance because information leaks across folds through the data's dependence structure.

| CV Strategy | When to Use | How It Works |
|-------------|-------------|--------------|
| **Standard k-fold** | Only if observations are genuinely independent | Random partitioning into k folds |
| **Stratified k-fold** | Imbalanced classes (e.g., rare dropout events) | Preserves class proportions in each fold |
| **Group k-fold** | Clustered data (students within schools, schools within districts) | All observations from a cluster stay in the same fold |
| **Time-series split** | Temporal data (predicting future from past) | Expanding or rolling window; never train on future to predict past |
| **Spatial block CV** | Geographic data (spatial autocorrelation) | Block partitioning with separation distances matching the autocorrelation range |
| **Leave-one-group-out** | Predicting for entirely new units (new schools, new districts) | Each fold holds out all observations from one group |

**The single most common CV mistake in applied social science:** Using standard k-fold on clustered data. If students are nested within schools, random splitting leaks school-level information across folds — the model "sees" other students from the same school during training, producing optimistic performance estimates that collapse when applied to genuinely new schools.

**Decision rule for CV strategy:**
- If the eventual deployment will predict for *new units* (new schools, new districts), use group k-fold or leave-one-group-out with the unit as the group
- If the deployment will predict *future observations* for existing units, use time-series split
- If the data has spatial structure, use spatial block CV with block sizes matching the spatial autocorrelation range
- If none of these structures apply (genuinely i.i.d. data, which is rare in social science), standard k-fold is acceptable

### Hyperparameter Tuning

- **GridSearchCV:** Exhaustive search over a parameter grid. Reliable but computationally expensive for large grids.
- **RandomizedSearchCV:** Random sampling from parameter distributions. More efficient for large search spaces; Bergstra and Bengio (2012) showed random search finds good hyperparameters faster than grid search in most settings.
- Always use cross-validation inside the training set — NEVER tune on the test set.
- Report the hyperparameter search process: the grid or distributions searched, the best parameters found, and the CV scores across candidates.

For implementation syntax of all CV strategies and hyperparameter search, see the `scikit-learn` skill, specifically `evaluation-supervised.md`.

### Missing Data in ML Pipelines

Social science data is riddled with missing values — administrative records have reporting gaps, surveys have nonresponse, longitudinal data has attrition. This is a practical issue that must be handled explicitly in every ML pipeline.

**Models that handle NaN natively:** HistGradientBoostingClassifier/Regressor, LightGBM, and XGBoost all route missing values to optimal tree splits without requiring imputation. When missing data is prevalent, these models are preferred because they eliminate the need for imputation decisions entirely.

**When imputation is required:** For models that cannot handle NaN (logistic regression, standard random forest, SVM, neural networks), imputation is necessary. **CRITICAL: imputation must happen INSIDE the cross-validation loop.** Fitting an imputer on the full dataset before splitting leaks test-set information into the training data — the imputed values in the training fold incorporate statistics from the test fold. Use `sklearn.pipeline.Pipeline` with `SimpleImputer` or `IterativeImputer` as the first step to ensure leak-free imputation.

**Missingness as a feature:** Missing values are often informative in social science data — a school that fails to report a metric may differ systematically from one that reports. Create binary missingness indicator columns (1 = was missing, 0 = was observed) BEFORE imputation. These indicators preserve the information content of the missingness pattern as predictive features.

**Never impute the outcome variable.** Observations with missing outcomes should be excluded from the modeling sample. Imputing outcomes introduces fabricated signal that corrupts both training and evaluation.

> **Cross-reference:** For missing data characterization methodology (MCAR, MAR, MNAR testing and interpretation), see `descriptive-analysis.md`. For Pipeline and imputer implementation syntax, see the `scikit-learn` skill.

## Model Selection for Supervised Tasks

### Decision Framework

No single algorithm dominates across all datasets — this is the "No Free Lunch" principle (Wolpert, 1996). However, for typical social science tabular data, empirical benchmarks provide clear guidance. Following Grinsztajn, Oyallon, and Varoquaux (2022), tree-based ensemble methods outperform neural networks on medium-sized tabular datasets across a wide range of tasks.

| Data Characteristic | Recommended Starting Point | Why |
|---------------------|---------------------------|-----|
| Tabular, moderate features, need interpretability | Logistic regression / Ridge regression | Fully interpretable; competitive baseline |
| Tabular, moderate features, need best performance | HistGradientBoosting (scikit-learn) or LightGBM | Strongest general-purpose tabular predictors |
| High-dimensional, sparse features | Logistic regression with L1 penalty (Lasso) | L1 performs automatic feature selection |
| Small dataset (<1000 rows) | Logistic regression or KNN | Complex models overfit small samples |
| Need calibrated probabilities | CalibratedClassifierCV wrapper | Ensures predicted probabilities match observed frequencies |
| Non-tabular (text, images) | See "When Deep Learning Methods Are Appropriate" | Tree methods do not handle unstructured data |

**Start simple, establish a baseline, then add complexity.** Logistic regression is competitive on many social science datasets and is fully interpretable. Try more complex models only if the baseline is insufficient for the decision the predictions will inform.

### The Interpretability-Performance Tradeoff

Following Rudin's (2019) influential argument in *Nature Machine Intelligence*, for high-stakes policy decisions:

- **Prefer inherently interpretable models** (logistic regression, small decision trees, rule lists) unless there is a meaningful and demonstrated performance gap with more complex models
- **The Rashomon set principle:** When many models achieve similar predictive accuracy — which is common — at least one is likely interpretable. Try interpretable models first before reaching for black boxes.
- **Post-hoc explanations of black boxes** (SHAP, LIME, permutation importance) are approximations of the model's behavior, not faithful representations of its reasoning. They can disagree with each other and can be misleading when the model itself captures spurious patterns.
- **Always compare:** When using a complex model, report its performance alongside the best interpretable model and quantify the gap explicitly. If a logistic regression achieves AUC = 0.82 and a gradient boosting model achieves AUC = 0.84, the 0.02 gain must be weighed against the loss of transparency.

> **Cross-reference:** For implementation syntax of all algorithms listed above, see the `scikit-learn` skill, specifically `classification.md` and `regression-ml.md`.

### Sample Size Considerations

ML models generally need more data than parametric regression models to perform well because they estimate more flexible functions with more effective parameters.

**Rules of thumb for minimum sample size:**
- Simple models (logistic regression, Ridge): at least 10-20 observations per feature
- Tree-based ensembles (random forest, gradient boosting): more data-hungry; hundreds to thousands of observations are needed before they outperform logistic regression
- With very small samples (<500 rows), prefer simple models (logistic regression, small decision trees with limited depth) — complex models will memorize the training data rather than learn generalizable patterns

**Diagnosing memorization:** A large gap between training performance and test/CV performance is the hallmark of overfitting. Use learning curves (plotting performance against training set size) to assess whether your sample supports the model complexity — if test performance is still rising steeply when all training data is used, more data would help; if training and test curves have converged at a gap, the model is too complex for the sample.

**High-dimensional data (p >> n):** When features outnumber observations, most ML models will overfit severely. Use regularization (Lasso, ElasticNet) to perform automatic feature selection, or apply dimensionality reduction (PCA) before modeling. Tree-based models handle moderate dimensionality but still struggle when p greatly exceeds n.

**When in doubt:** Use cross-validation to empirically assess whether your sample supports the model complexity. If CV variance is high across folds, the model is likely too complex for the available data.

## Classification Methodology

### Metric Selection Is a Research Decision

The choice of evaluation metric is not a technical detail — it encodes a value judgment about the relative cost of different types of errors. Following James et al. (2021, Ch. 4), no single metric captures all aspects of classification performance.

| Metric | What It Measures | When to Use |
|--------|-----------------|-------------|
| **Accuracy** | Overall fraction of correct predictions | Balanced classes only; misleading when one class dominates |
| **Precision** | Among predicted positives, how many are correct | When false positives are costly (e.g., wrongly flagging a student for intervention) |
| **Recall (sensitivity)** | Among actual positives, how many are detected | When false negatives are costly (e.g., missing an at-risk student who then drops out) |
| **F1 score** | Harmonic mean of precision and recall | When both types of error matter roughly equally |
| **ROC-AUC** | Discrimination ability across all thresholds | Comparing models before setting a decision threshold |
| **Precision-Recall AUC** | Like ROC-AUC but focused on the positive class | Rare events (dropout, school closure, violence) where ROC-AUC can be misleadingly high |
| **Calibration** | Are predicted probabilities accurate? | When predictions inform individual-level decisions |

Always report multiple metrics. A model with high AUC but poor calibration ranks students correctly but assigns unreliable probability estimates — this matters if those probabilities drive resource allocation decisions.

### Threshold Selection

The default classification threshold of 0.5 is almost never optimal for policy applications. The optimal threshold depends on the cost structure of the decision:

- **If missing at-risk students is much worse than false alarms** (e.g., early warning systems), lower the threshold to increase recall at the cost of precision
- **If false positives carry significant costs** (e.g., intrusive interventions, stigma), raise the threshold to increase precision at the cost of recall
- Report results at multiple thresholds to show how the precision-recall tradeoff changes — this makes the value judgment transparent to decision-makers
- The precision-recall tradeoff is ultimately a **stakeholder decision**, not a statistical one: discuss with domain experts what error rates are acceptable in the specific application context

### Class Imbalance

Class imbalance is the norm in social science classification tasks: dropout is rare, school closures are rare, violence incidents are rare. When the positive class is 5% of the sample, a model that predicts "no" for every observation achieves 95% accuracy — and is completely useless.

**Approaches to class imbalance:**
- **`class_weight="balanced"`:** Reweights the loss function to penalize misclassification of the minority class more heavily. Simple, effective, and generally sufficient for tree-based models.
- **Threshold adjustment:** Train on the natural distribution but lower the classification threshold. Often the best approach because it separates model training from the decision policy.
- **Stratified cross-validation:** Ensures each CV fold preserves the class proportions, preventing folds where the minority class is absent.
- **SMOTE and oversampling** (available via the `imbalanced-learn` package): Synthetic minority oversampling. Available but generally less effective than `class_weight` adjustment for tree-based models, and problematic with categorical features.
- **Always evaluate on the natural class distribution** — never on resampled test data, which produces misleading performance estimates.

### Calibration: When Predictions Inform Individual Decisions

Calibration measures whether a model's predicted probabilities match observed frequencies — a predicted probability of 0.3 should mean roughly 30% of cases assigned that score are actually positive. This is distinct from discrimination (the ability to rank-order observations), which is what AUC measures.

**Why calibration matters for policy:** When predictions drive individual-level decisions — flagging students for intervention, allocating resources based on risk scores, triggering early warning protocols — the absolute probability matters, not just the ranking. A model can have excellent AUC (it rank-orders students correctly) but terrible calibration (a student scored at "80% risk" actually has a 40% chance of the outcome). Stakeholders interpret predicted probabilities at face value; if those probabilities are wrong, resource allocation decisions are poorly calibrated even when targeting is directionally correct.

**Assessing calibration:**
- **Reliability diagrams (calibration curves):** Plot predicted probabilities (binned) against observed frequencies. A well-calibrated model falls on the diagonal. Deviations above the diagonal indicate underconfidence; below indicates overconfidence.
- **Brier score:** Mean squared difference between predicted probabilities and actual outcomes. Decomposes into calibration, refinement, and uncertainty components. Lower is better; 0 is perfect.

**Fixing poor calibration:**
- **CalibratedClassifierCV** wraps any classifier and recalibrates its outputs using a held-out calibration set
- **Platt scaling (method='sigmoid'):** Fits a logistic regression to the model's raw outputs. Works well when the calibration curve is approximately sigmoidal.
- **Isotonic regression (method='isotonic'):** Non-parametric; fits a stepwise non-decreasing function. More flexible but requires more calibration data to avoid overfitting.

**Key insight:** Tree-based models (random forests, gradient boosting) are often poorly calibrated out of the box despite strong discriminative performance. Random forests tend to push probabilities toward 0.5; gradient boosting tends toward extreme probabilities. Always check calibration when using ensemble methods for probability-sensitive decisions.

> **Cross-reference:** For CalibratedClassifierCV implementation syntax and the sklearn.calibration module, see the `scikit-learn` skill.

## ML Regression Methodology

### When Prediction-Focused Regression vs. Inference Regression

The distinction between ML regression and econometric regression is not about the algorithm — it is about the goal. Logistic regression appears in both contexts. The question is: "Am I trying to estimate a parameter, or predict an outcome?"

| Signal | Use scikit-learn (prediction) | Use pyfixest/statsmodels (inference) |
|--------|-------------------------------|--------------------------------------|
| **Goal** | Minimize prediction error on new data | Estimate a coefficient with valid uncertainty |
| **Coefficients** | Not directly interpretable as effects | Primary output of interest |
| **Standard errors** | Not produced; use bootstrap or conformal prediction for uncertainty | First-class output with well-defined statistical properties |
| **Regularization** | Often essential for good performance | Introduces bias in the coefficient estimate |
| **Evaluation** | RMSE, MAE, R-squared on held-out data | Coefficient significance, diagnostic tests |
| **Example** | "Predict school enrollment next year" | "What is the effect of funding on enrollment?" |

> **Cross-reference:** For the inference regression framework (coefficient interpretation, standard error selection, assumption checking, robustness checks), see `statistical-modeling.md`. The SE types table, assumption checking protocol, and coefficient interpretation guide in that reference are not repeated here.

### Regularized Regression

Regularization is the primary tool for managing the bias-variance tradeoff in regression:

- **Ridge (L2 penalty):** Shrinks all coefficients toward zero proportionally. Keeps all features in the model. Best when many features contribute small predictive effects.
- **Lasso (L1 penalty):** Drives some coefficients exactly to zero, performing automatic feature selection. Best when only a subset of features matters for prediction.
- **ElasticNet (L1 + L2):** Combines both penalties. Best when features are correlated — Lasso alone can arbitrarily select one from a group of correlated features, while ElasticNet tends to include or exclude them together.
- **Regularization strength** (alpha/lambda) is always chosen by cross-validation, not set manually
- In the prediction context, regularization is always helpful or neutral — there is no reason to avoid it

## Ensemble Methods

### Why Ensembles Work

Ensemble methods combine multiple base models to achieve better predictive performance than any single model. Following Hastie, Tibshirani, and Friedman (2009, Chs. 8, 10, 16), the two main strategies reduce different components of prediction error:

- **Bagging (Bootstrap Aggregating) — reduces variance.** Trains many deep decision trees on bootstrap samples of the training data and averages their predictions. Each individual tree has low bias (it can fit complex patterns) but high variance (it is sensitive to the specific training sample). Averaging across many trees reduces variance without increasing bias. Random Forests extend bagging by also randomizing the features considered at each split, which decorrelates the trees and further reduces variance.

- **Boosting — primarily reduces bias.** Sequentially fits weak learners (typically shallow trees) to the residuals of the current ensemble. Each new tree corrects errors the ensemble has not yet captured. Gradient boosting (Friedman, 2001) generalizes this to arbitrary loss functions. More prone to overfitting than bagging; requires careful tuning of the learning rate, tree depth, and number of iterations.

- **Stacking** combines diverse model types (e.g., logistic regression, random forest, gradient boosting) through a meta-learner that learns how to optimally combine their predictions. Less commonly used in social science applications.

### Practical Guidance

| Method | When to Use | Key Tuning Parameters |
|--------|-------------|----------------------|
| **Random Forest** | Robust default; hard to misconfigure; good first ensemble choice | n_estimators, max_depth, max_features |
| **HistGradientBoosting** (scikit-learn) | Maximum performance with moderate tuning; handles NaN natively; supports categorical features | learning_rate, max_depth, max_iter |
| **LightGBM** | Large datasets; native SHAP TreeExplainer support; available in DAAF Dockerfile | learning_rate, num_leaves, n_estimators |
| **XGBoost** | Custom loss functions; GPU training | Optional install: `uv pip install --system --no-deps xgboost` |

For most applied social science work, start with Random Forest (simple, robust), then try HistGradientBoosting or LightGBM if more performance is needed. The performance difference between gradient boosting implementations (scikit-learn, LightGBM, XGBoost) is usually small; choose based on practical considerations (SHAP compatibility, native categorical support, installation constraints).

> **Cross-reference:** For implementation syntax of all ensemble methods, see the `scikit-learn` skill, specifically `classification.md` and `regression-ml.md`.

## Interpreting ML Models: The Causation Trap

### The Fundamental Conceptual Error

**Feature importance is not causal importance.** This is the single most important methodological warning for social scientists using machine learning.

The pattern is familiar and dangerous: a researcher trains a prediction model, extracts feature importances or SHAP values, and interprets them as if they identify causes or policy levers. This reasoning is wrong because:

1. **Predictive models capture any correlation**, including confounding, reverse causation, and mediation. A variable can be highly predictive because it is a proxy for an unmeasured confounder, not because it has any causal relationship with the outcome.
2. **Correlated features split importance arbitrarily.** If household income and parental education are highly correlated, their individual SHAP values or importance scores are unstable — the model may attribute most importance to whichever feature happens to be selected first in a tree split, and this allocation changes across training samples.
3. **Regularization reshapes coefficient magnitudes** in ways unrelated to causal structure. Lasso may zero out a truly causal variable if a correlated proxy is slightly more predictive.
4. **SHAP values explain the model's predictions, not the data-generating process.** As the SHAP documentation itself warns: "Be careful when interpreting predictive models in search of causal insights" — correlations made transparent by SHAP are still just correlations.

### Interpretation Methods and Their Limits

| Tool | What It Shows | What It Does NOT Show |
|------|--------------|----------------------|
| **SHAP values** | How each feature contributes to a specific prediction relative to the average prediction | The causal effect of changing that feature in reality |
| **Permutation importance** | How much predictive performance drops when a feature's values are randomly shuffled | Which features to intervene on to change outcomes |
| **Partial dependence plots (PDP)** | The average prediction as one feature varies while others are held at their observed values | The causal effect of that feature (confounding remains) |
| **ICE plots** | Individual conditional expectations — per-observation version of PDP | Same limitation as PDP, but per observation |
| **Tree-based feature importance** | How much a feature was used in tree splits (impurity-based) | Causation, or even necessarily predictive value on new data (biased toward high-cardinality features) |

### Common Language Errors

Following the pattern established in `exploratory-unsupervised.md` for causal language warnings:

| Incorrect Framing | Problem | Correct Framing |
|-------------------|---------|-----------------|
| "SHAP analysis *shows that* poverty *causes* lower graduation rates" | SHAP reflects predictive association, not causation | "SHAP analysis *shows that* poverty is a strong *predictor of* lower graduation rates *in this model*" |
| "The model *identifies* free lunch eligibility *as a key driver of* dropout" | Implies causal mechanism | "The model *identifies* free lunch eligibility *as a highly predictive feature for* dropout" |
| "Feature importance *reveals that* class size *matters most for* test scores" | Conflates predictive relevance with causal importance | "Feature importance *indicates that* class size *is the strongest predictor of* test scores *in this model*" |
| "Intervening on the top SHAP features *would improve* outcomes" | Assumes predictive importance translates to causal leverage | "The features with the highest SHAP values *are associated with* outcome variation *but their causal roles require separate investigation*" |
| "The model *found that* teacher experience *has no effect*" | Low importance does not mean no causal effect | "Teacher experience *had low predictive importance in this model*, which may reflect collinearity with other features rather than a lack of substantive relationship" |

### Following Rudin (2019)

Rudin (2019) argues that post-hoc explanations (SHAP, LIME) are approximations of the model, not of reality. They can be misleading if the model itself captures spurious patterns — explaining a bad model faithfully still produces bad explanations. For policy-relevant research:

- Prefer inherently interpretable models unless the performance gap is substantial and documented
- When SHAP is used, always include the caveat that SHAP explains the model's behavior, not causal relationships in the data
- Never present SHAP values or feature importances as evidence for policy recommendations without independent causal evidence

> **Cross-reference:** For SHAP implementation syntax, see the `scikit-learn` skill, specifically `interpretation.md`. For econometric approaches to understanding variable contributions (Gelbach decomposition, Oster sensitivity analysis), see `statistical-modeling.md`.

## Fairness, Bias, and Equity

### Why Fairness Matters for Education and Social Policy

Prediction models in education and social policy — dropout risk scoring, intervention targeting, resource allocation, admissions screening, child welfare screening — directly affect people's lives and life chances. When these models perform differently across demographic groups, they can perpetuate or amplify existing inequities. This is not a theoretical concern: Obermeyer et al. (2019) demonstrated that a widely used healthcare algorithm systematically underestimated the health needs of Black patients because it used healthcare costs (which reflect access barriers) as a proxy for health needs.

Federal guidance increasingly requires fairness audits for algorithmic decision-making in education. Any prediction model deployed in an education context should include a fairness assessment as a standard component of the analysis, not an afterthought.

### Fairness Criteria Definitions

Three families of fairness criteria dominate the literature. Understanding what each measures — and what it sacrifices — is essential before choosing one.

| Criterion | Formal Definition | Intuition | Prioritizes |
|-----------|------------------|-----------|-------------|
| **Demographic parity** | P(Y-hat=1 \| A=a) = P(Y-hat=1 \| A=b) | Equal selection rates across groups | Equal outcomes regardless of merit |
| **Equalized odds** | P(Y-hat=1 \| Y=y, A=a) = P(Y-hat=1 \| Y=y, A=b) for all y | Equal error rates (FPR and TPR) across groups | Equal treatment of equally situated individuals |
| **Predictive parity (calibration)** | P(Y=1 \| Y-hat=1, A=a) = P(Y=1 \| Y-hat=1, A=b) | Predictions mean the same thing for all groups | Equal meaning of scores across groups |

Each criterion captures a legitimate moral intuition about what "fairness" means. The tension between them is not a technical limitation to be engineered away — it reflects genuine value conflicts.

### The Impossibility Theorems

Kleinberg, Mullainathan, and Raghavan (2016) and Chouldechova (2017) independently proved a result of profound practical importance: **when base rates differ across groups — and they almost always do in social data — calibration and error rate balance cannot simultaneously hold.**

This means:
- You CANNOT have a model that is simultaneously calibrated (predictions mean the same thing across groups) and has equal false positive/negative rates across groups
- You MUST choose which fairness criterion to prioritize — this is a **normative choice**, not a technical one
- The choice depends on the decision context, the stakeholders affected, and the values of the institution deploying the model

**Concrete example:** A dropout prediction model where the base dropout rate differs by income group (e.g., 15% for low-income students vs. 5% for high-income students). You can calibrate the model so that "80% risk" means the same thing regardless of income group. OR you can equalize the false positive rate so that the same proportion of non-dropouts are incorrectly flagged in each group. But you cannot do both simultaneously. The choice between these criteria is a policy decision that should be made by stakeholders, not by the data scientist.

### Connection to Civil Rights Frameworks

Algorithmic fairness in education operates within established legal frameworks:

- **Title VI** (Civil Rights Act of 1964): Prohibits discrimination on the basis of race, color, or national origin in programs receiving federal financial assistance
- **Title IX** (Education Amendments of 1972): Prohibits sex-based discrimination in federally funded education programs
- **IDEA** (Individuals with Disabilities Education Act): Protections for students with disabilities
- **Disparate impact doctrine:** A facially neutral model that produces systematically different outcomes for protected groups triggers scrutiny — intentional discrimination is not required
- **"Business necessity" defense:** The model must be demonstrably necessary for a legitimate purpose, and no less discriminatory alternative achieves the same purpose

These are not abstract legal concerns. A dropout early warning system that flags Black students at disproportionately higher rates than white students with similar academic profiles raises Title VI concerns regardless of whether the model was designed with any discriminatory intent.

### Practical Fairness Assessment Workflow

1. **Define protected attributes** relevant to the application context (race/ethnicity, gender, disability status, income, English learner status, etc.)
2. **Compute group-level metrics** — accuracy, precision, recall, false positive rate, false negative rate — disaggregated by each protected attribute
3. **Assess calibration across groups** — are predicted probabilities equally reliable? A "70% risk" prediction should mean roughly the same thing regardless of group membership
4. **Identify disparities** — which fairness criteria are violated? By how much?
5. **Document the normative choice** — which fairness criterion was prioritized and why? This should be a deliberate, documented decision, not an implicit default
6. **Consider mitigation** if disparities are found — threshold adjustment by group, constrained optimization, or alternative model formulations. Note that mitigation may reduce overall predictive performance; document this tradeoff.
7. **Report fairness assessment results alongside predictive performance** — fairness metrics are not optional supplementary material; they are core results

> **Cross-reference:** For fairlearn implementation syntax (MetricFrame, ThresholdOptimizer, ExponentiatedGradient), see the `scikit-learn` skill, specifically `fairness.md`.

## When Deep Learning Methods Are Appropriate

### The Tabular vs. Unstructured Data Divide

For typical social science research using structured/tabular data — surveys, administrative records, census data — tree-based ensemble methods outperform neural networks on medium-sized datasets. Grinsztajn, Oyallon, and Varoquaux (2022) provide rigorous empirical evidence across 45 tabular datasets, finding that tree-based methods (especially gradient boosting) consistently outperform or match deep learning approaches while being faster to train and easier to tune.

Deep learning's advantages emerge primarily with unstructured data:

| Data Type | Why Deep Learning Excels | Examples in Social Science |
|-----------|-------------------------|---------------------------|
| **Text / NLP** | Sequential and contextual patterns; pretrained language models capture meaning | Classifying open-ended survey responses, coding legislative text, sentiment analysis of public comments |
| **Images** | Spatial hierarchies; convolutional architectures detect visual features | Satellite imagery for neighborhood characterization, document digitization |
| **Very large tabular data** (millions of rows) | Can exploit complex nonlinear interactions at scale | Rare in typical social science research |
| **Multimodal** | Combining text + tabular + image inputs in a single model | Emerging applications; not yet standard in social science |

### Text Classification: The Most Common Entry Point

For social science researchers, text classification is the most likely use case for deep learning. Pretrained transformer models (via Hugging Face) can be fine-tuned for domain-specific classification with relatively small labeled datasets. However, for many text classification tasks, traditional supervised methods — logistic regression on TF-IDF features, or random forest on sentence embeddings — perform comparably to deep learning with far less computational cost. Always establish a traditional baseline before reaching for transformers.

### Current DAAF Support Status

**DAAF does not currently provide implementation support for deep learning frameworks.** PyTorch, TensorFlow, and Hugging Face transformers are not included in the Dockerfile to avoid significant bloat (2-4 GB combined) and scope creep for users who do not need these capabilities.

If your research requires deep learning:
- The methodological guidance in this section applies regardless of framework
- For implementation, consult: Hugging Face documentation (https://huggingface.co/docs), PyTorch tutorials (https://pytorch.org/tutorials/), or fastai (https://docs.fast.ai/)
- Consider whether a traditional ML approach achieves adequate performance before investing in deep learning infrastructure

## Reporting Standards for Supervised ML in Research

### Required Elements

Following the reporting norms emerging for prediction-focused research in applied social science (Athey and Imbens, 2019; Mullainathan and Spiess, 2017):

1. **Problem framing:** Why prediction (not inference) is the appropriate approach for this research question. Explicitly connect to the Shmueli (2010) or Kleinberg et al. (2015) framework.
2. **Data description:** Sample size, features used (with justification), outcome variable definition, time period, and any exclusion criteria
3. **Train/test split:** How data was divided and why — random, temporal, grouped — with the rationale for the choice
4. **Cross-validation strategy:** Which CV method was used and why it matches the data structure. If group k-fold or temporal split was used, identify the grouping variable or temporal boundary.
5. **Model selection:** What models were compared, what hyperparameters were searched, and what the selection criterion was
6. **Baseline comparison:** Performance of a simple interpretable baseline (e.g., logistic regression) alongside the chosen model. The gap between baseline and chosen model should be reported explicitly.
7. **Performance metrics:** Multiple metrics reported on held-out test data, with confidence intervals or bootstrap standard errors where possible
8. **Feature importance with caveats:** If SHAP or permutation importance is reported, explicitly state that these reflect predictive associations, not causal effects
9. **Fairness assessment:** Disaggregated performance metrics by relevant demographic groups, with documentation of which fairness criterion was considered and why
10. **Limitations:** What the model cannot do, where it may fail, populations or contexts where it has not been validated, and what decisions should NOT be automated based on its predictions

### Common Reporting Failures

- Reporting only training accuracy or training R-squared (meaningless for evaluating prediction)
- Claiming causal interpretation of SHAP values or feature importances
- Using a complex ML model when logistic regression achieves comparable performance, without reporting the comparison
- Omitting the fairness assessment entirely
- Using standard k-fold CV on clustered or temporal data without acknowledgment
- Presenting ML results using the language and framing of inference ("the effect of X on Y") rather than prediction ("the predictive association between X and Y")

## Common Pitfalls for Social Scientists

These pitfalls reflect the specific challenges that arise when researchers trained in econometrics or quantitative social science apply machine learning methods. Each represents a genuine conceptual gap, not merely a technical mistake.

1. **The causation trap.** Treating feature importance as causal evidence. ML engineers generally do not claim causation from predictive models; social scientists trained to think about causal mechanisms may unconsciously import that framing. Every feature importance result should be accompanied by an explicit statement that predictive importance does not imply causal importance.

2. **Ignoring data structure in cross-validation.** Social science data is almost always clustered, temporal, or spatial. Standard k-fold CV dramatically overstates performance because it allows information leakage across the dependence structure. Always match the CV strategy to the data structure (Roberts et al., 2017).

3. **Neglecting base rate differences in fairness.** The impossibility theorems (Kleinberg et al., 2016; Chouldechova, 2017) bite hardest when base rates differ by group — which is nearly always true in social data. Ignoring this means deploying models that appear fair on one criterion while violating another.

4. **Overfitting to an in-sample narrative.** Social scientists are accustomed to interpreting individual coefficients and building a narrative from them. In an ensemble of hundreds of trees, there is no single coefficient to interpret — the model IS the ensemble. Attempting to extract a coefficient-level narrative from an ensemble is fundamentally misguided.

5. **Confusion between prediction and explanation goals.** Using ML when OLS would be more appropriate (the goal is to estimate an effect) or using OLS when ML would be more appropriate (the goal is to predict for targeting). The methodology choice should follow from the research question, not from familiarity or fashion.

6. **Publication bias toward novel methods.** Using XGBoost or a neural network because it sounds impressive when logistic regression achieves the same AUC and is fully transparent. Following Rudin (2019), complexity should be justified by demonstrated performance gains, not by novelty.

## References and Further Reading

### Foundational Texts

Breiman, L. (2001). "Statistical Modeling: The Two Cultures (with comments and a rejoinder by the author)." *Statistical Science*, 16(3), 199-231.

Shmueli, G. (2010). "To Explain or to Predict?" *Statistical Science*, 25(3), 289-310. https://doi.org/10.1214/10-STS330

James, G., Witten, D., Hastie, T., and Tibshirani, R. (2021). *An Introduction to Statistical Learning*, 2nd Edition. Springer. **Free:** https://www.statlearning.com/

Hastie, T., Tibshirani, R., and Friedman, J. (2009). *The Elements of Statistical Learning*, 2nd Edition. Springer. **Free:** https://hastie.su.domains/ElemStatLearn/download.html

### ML in Social Science and Economics

Kleinberg, J., Ludwig, J., Mullainathan, S., and Obermeyer, Z. (2015). "Prediction Policy Problems." *American Economic Review*, 105(5), 491-495.

Mullainathan, S. and Spiess, J. (2017). "Machine Learning: An Applied Econometric Approach." *Journal of Economic Perspectives*, 31(2), 87-106.

Athey, S. and Imbens, G.W. (2019). "Machine Learning Methods That Economists Should Know About." *Annual Review of Economics*, 11, 685-725.

Wager, S. and Athey, S. (2018). "Estimation and Inference of Heterogeneous Treatment Effects Using Random Forests." *Journal of the American Statistical Association*, 113(523), 1228-1242.

Chernozhukov, V., Chetverikov, D., Demirer, M., Duflo, E., Hansen, C., Newey, W., and Robins, J. (2018). "Double/Debiased Machine Learning for Treatment and Structural Parameters." *The Econometrics Journal*, 21(1), C1-C68.

### Model Interpretation

Rudin, C. (2019). "Stop Explaining Black Box Machine Learning Models for High Stakes Decisions and Use Interpretable Models Instead." *Nature Machine Intelligence*, 1, 206-215.

Molnar, C. (Ongoing). *Interpretable Machine Learning*. Online book. https://christophm.github.io/interpretable-ml-book/

Lundberg, S.M. and Lee, S.-I. (2017). "A Unified Approach to Interpreting Model Predictions." *Advances in Neural Information Processing Systems*, 30.

Lundberg, S.M., Erion, G., Chen, H., DeGrave, A., Prutkin, J.M., Nair, B., Katz, R., Himmelfarb, J., Bansal, N., and Lee, S.-I. (2020). "From Local Explanations to Global Understanding with Explainable AI for Trees." *Nature Machine Intelligence*, 2, 56-67.

### Fairness and Algorithmic Bias

Kleinberg, J., Mullainathan, S., and Raghavan, M. (2016). "Inherent Trade-Offs in the Fair Determination of Risk Scores." arXiv:1609.05807. Published in *Innovations in Theoretical Computer Science* (ITCS 2017).

Chouldechova, A. (2017). "Fair Prediction with Disparate Impact: A Study of Bias in Recidivism Prediction Instruments." *Big Data*, 5(2), 153-163.

Obermeyer, Z., Powers, B., Vogeli, C., and Mullainathan, S. (2019). "Dissecting Racial Bias in an Algorithm Used to Manage the Health of Populations." *Science*, 366(6464), 447-453.

Bird, S., Dudik, M., Edgar, R., Horn, B., Lutz, R., Milan, V., Sameki, M., Wallach, H., and Walker, K. (2020). "Fairlearn: A Toolkit for Assessing and Improving Fairness in AI." Microsoft Research Tech Report MSR-TR-2020-32.

### Cross-Validation for Structured Data

Roberts, D.R., Bahn, V., Ciuti, S., Boyce, M.S., Elith, J., Guillera-Arroita, G., Hauenstein, S., Lahoz-Monfort, J.J., Schroder, B., Thuiller, W., Warton, D.I., Wintle, B.A., Hartig, F., and Dormann, C.F. (2017). "Cross-Validation Strategies for Data with Temporal, Spatial, Hierarchical, or Phylogenetic Structure." *Ecography*, 40(8), 913-929.

### Deep Learning and Tabular Data

Grinsztajn, L., Oyallon, E., and Varoquaux, G. (2022). "Why Do Tree-Based Models Still Outperform Deep Learning on Typical Tabular Data?" *NeurIPS 2022 Datasets and Benchmarks Track*.

### Ensemble Methods

Friedman, J.H. (2001). "Greedy Function Approximation: A Gradient Boosting Machine." *Annals of Statistics*, 29(5), 1189-1232.

### Software

Pedregosa, F., Varoquaux, G., Gramfort, A., Michel, V., Thirion, B., Grisel, O., Blondel, M., Prettenhofer, P., Weiss, R., Dubourg, V., Vanderplas, J., Passos, A., Cournapeau, D., Brucher, M., Perrot, M., and Duchesnay, E. (2011). "Scikit-learn: Machine Learning in Python." *Journal of Machine Learning Research*, 12, 2825-2830. https://scikit-learn.org/

Ke, G., Meng, Q., Finley, T., Wang, T., Chen, W., Ma, W., Ye, Q., and Liu, T.-Y. (2017). "LightGBM: A Highly Efficient Gradient Boosting Decision Tree." *Advances in Neural Information Processing Systems*, 30.

### Hyperparameter Tuning

Bergstra, J. and Bengio, Y. (2012). "Random Search for Hyper-Parameter Optimization." *Journal of Machine Learning Research*, 13, 281-305.

### Additional Resources

Wolpert, D.H. (1996). "The Lack of A Priori Distinctions Between Learning Algorithms." *Neural Computation*, 8(7), 1341-1390.
