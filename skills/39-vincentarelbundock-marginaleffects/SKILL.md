---
name: marginaleffects
description: Manual for the marginaleffects R and Python package, and guide to the book "Model to Meaning". Use when users ask about predictions, comparisons, slopes, marginal effects, average treatment effects (ATE/ATT/CATE), hypothesis testing, contrasts, counterfactuals, risk ratios, odds ratios, causal inference with G-computation, or need help with marginaleffects functions like predictions(), comparisons(), slopes(), hypotheses(), datagrid(), avg_predictions(), avg_comparisons(), avg_slopes(), or plot functions.
license: CC-BY-4.0
metadata:
  source: https://marginaleffects.com
  maintainer: vincentarelbundock
allowed-tools: Read, Grep, Glob
---

# marginaleffects

Primary source of information: https://marginaleffects.com
Free book, case studies, and vignettes are available there.

Package manual for R and Python, plus a guide to the companion book.

**Book**: *Model to Meaning: How to Interpret Statistical Models in R and Python*
- Author: Vincent Arel-Bundock (2026)
- Publisher: CRC Press
- Free online: https://marginaleffects.com (primary source with many case studies and vignettes)
- Print: https://routledge.com/9781032908724

## Core framework: Five questions for every analysis

Every interpretation task can be decomposed into five disciplined questions:

1. **Quantity**: What estimand? (predictions, comparisons, slopes, or tests)
2. **Predictors (Grid)**: Where to evaluate? (observed values, counterfactual scenarios, balanced grids)
3. **Aggregation**: Over whom? (unit-level, group means with `by=`, weighted averages)
4. **Uncertainty**: Which inference method? (delta method, robust SE, bootstrap, Bayesian)
5. **Test**: What hypothesis? (null tests, equivalence, pairwise contrasts)

## Quick start

**Chapter summaries**: Read `chapters/<chapter>.qmd`
**Function reference**: Read `man/r/<function>.md` or `man/python/<function>.md`

## When to use this skill

- User asks about predictions, comparisons, slopes, or marginal effects
- User needs help choosing estimands (ATE, ATT, CATE, risk difference, odds ratio)
- User asks about marginaleffects function syntax or arguments
- User wants to interpret model results or test hypotheses
- User mentions counterfactual analysis, G-computation, or causal inference
- User references Model to Meaning chapters

## Instructions

1. **Classify the request**:
   - Conceptual: Which estimand? How to interpret? → Use `chapters/`
   - Implementation: Function syntax, arguments, code → Use `man/r/` or `man/python/`
   - Mixed: Start with conceptual framing, then provide code

2. **Read the relevant source files**:
    - Book chapters: `chapters/framework.qmd`, `chapters/predictions.qmd`, `chapters/comparisons.qmd`, `chapters/slopes.qmd`, `chapters/hypothesis.qmd`, etc.
   - R reference: `man/r/predictions.md`, `man/r/comparisons.md`, `man/r/slopes.md`, `man/r/hypotheses.md`, `man/r/datagrid.md`
   - Python reference: `man/python/predictions.md`, `man/python/comparisons.md`, `man/python/slopes.md`, `man/python/hypotheses.md`

3. **Apply the five-question framework** to organize your response:
   - Help user define the estimand (Quantity)
   - Clarify where to evaluate it (Grid)
   - Determine aggregation level (Aggregation)
   - Recommend uncertainty quantification (Uncertainty)
   - Specify hypothesis if testing (Test)

4. **Provide concrete code examples** using the correct function for their language (R or Python)

## Available resources

### Book chapters (`chapters/`)
| File | Topic | Chapter focus |
|------|-------|---------------|
| `framework.qmd` | Five-question framework (start here) | Defines the five questions and core quantities (predictions, comparisons, slopes) for turning models into intuitive estimands. |
| `predictions.qmd` | Predicted values and expected outcomes | Defines predictions, grids, aggregation, and tests with `predictions()`/`avg_predictions()`. |
| `comparisons.qmd` | Counterfactual comparisons, ATE, ATT, risk ratios | Defines counterfactual comparisons, effect functions, grids, and aggregation with `comparisons()`/`avg_comparisons()`. |
| `slopes.qmd` | Marginal effects, partial derivatives | Defines slopes as partial derivatives, conditional on predictors; uses `slopes()`/`avg_slopes()`. |
| `hypothesis.qmd` | Hypothesis testing and equivalence | Null vs equivalence tests for any quantity using `hypothesis` and `equivalence` arguments. |
| `interactions.qmd` | Interaction effects and effect modification | Interprets heterogeneity and nonlinearity with interactions and polynomials using predictions, comparisons, and slopes. |
| `categorical.qmd` | Categorical predictors and contrasts | Applies the framework to categorical/ordinal outcomes with predictions and comparisons by outcome level. |
| `experiments.qmd` | Experimental designs | ATE in experiments and factorial designs via `avg_comparisons()` and robust SEs. |
| `gcomputation.qmd` | G-computation and causal inference | G-computation steps for ATE/ATT/ATU/CATE with counterfactual prediction grids. |
| `uncertainty.qmd` | Inference methods (delta, bootstrap, Bayesian) | Delta method, bootstrap, simulation, conformal prediction, and robust/clustered standard errors via `inferences()`/`vcov`. |
| `mrp.qmd` | Multilevel regression and poststratification | Multilevel models and poststratification with predictions and comparisons in mixed effects. |
| `ml.qmd` | Machine learning models | Model auditing with predictions, comparisons, and slopes for ML frameworks. |
| `challenge.qmd` | The interpretation challenge | Defines analysis goals, estimands, and why coefficients need transformation. |

### R function reference (`man/r/`)
Core functions (includes `avg_*` variants): `predictions.md`, `comparisons.md`, `slopes.md`, `hypotheses.md`
Grids: `datagrid.md`
Plots: `plot_predictions.md`, `plot_comparisons.md`, `plot_slopes.md`
Utilities: `posterior_draws.md`, `inferences.md`, `get_dataset.md`

### Python function reference (`man/python/`)
Core: `predictions.md`, `avg_predictions.md`, `comparisons.md`, `avg_comparisons.md`, `slopes.md`, `avg_slopes.md`, `hypotheses.md`
Grids: `datagrid.md`
Plots: `plot_predictions.md`, `plot_comparisons.md`, `plot_slopes.md`
Model fitting: `fit_statsmodels.md`, `fit_sklearn.md`, `fit_linearmodels.md`

## Examples

### Logit model example

**R:**
```r
library(marginaleffects)

# Fit logistic regression
mod <- glm(am ~ hp + wt, data = mtcars, family = binomial)

# Average marginal effects (slopes on probability scale)
avg_slopes(mod)

# Predicted probabilities at specific values
predictions(mod, newdata = datagrid(hp = c(100, 150, 200), wt = 3))

# Average treatment effect: compare hp = 150 vs hp = 100
avg_comparisons(mod, variables = list(hp = c(100, 150)))

# Risk ratio for a 50-unit increase in hp
avg_comparisons(mod, variables = list(hp = 50), comparison = "ratio")
```

**Python:**
```python
import marginaleffects as me
import statsmodels.formula.api as smf

# Fit logistic regression
mod = smf.logit("am ~ hp + wt", data=me.get_dataset("mtcars")).fit()

# Average marginal effects
me.avg_slopes(mod)

# Predicted probabilities at specific values
me.predictions(mod, newdata=me.datagrid(mod, hp=[100, 150, 200], wt=3))

# Average treatment effect: compare hp = 150 vs hp = 100
me.avg_comparisons(mod, variables={"hp": [100, 150]})
```

**User asks about choosing an estimand:**
→ Read `chapters/framework.qmd` and `chapters/comparisons.qmd`, explain the five-question framework, recommend the appropriate quantity (e.g., `avg_comparisons()` for ATE).

**User asks how to compute marginal effects:**
→ Read `man/r/slopes.md` or `man/python/slopes.md`, provide syntax with relevant arguments.

**User wants to test treatment effect heterogeneity:**
→ Read `chapters/comparisons.qmd` for CATE concepts, then `man/r/hypotheses.md` for testing syntax with `by=` groups.

**User asks about counterfactual grids:**
→ Read `chapters/framework.qmd` (Predictors section) and `man/r/datagrid.md` for `datagrid()` usage.

## Best practices

- **Ask about language preference**: If the user hasn't specified R or Python, ask which they prefer before providing code examples
- Always frame responses using the five-question framework when appropriate
- Cite specific sections from summaries or manuals
- Mention `get_dataset()` when users need example data
- For mixed requests, start with conceptual framing then show implementation
