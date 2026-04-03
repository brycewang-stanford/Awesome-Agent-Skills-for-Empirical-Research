---
name: sem-guide
description: "Structural equation modeling with latent variables guide"
metadata:
  openclaw:
    emoji: "🌐"
    category: "analysis"
    subcategory: "statistics"
    keywords: ["structural equation modeling", "SEM", "latent variable model", "multilevel model"]
    source: "wentor-research-plugins"
---

# Structural Equation Modeling Guide

Build, estimate, and evaluate structural equation models (SEM) with latent variables using Python (semopy) and R (lavaan), including confirmatory factor analysis and path analysis.

## What Is SEM?

Structural Equation Modeling is a multivariate statistical framework that combines factor analysis and path analysis to test complex theoretical models involving:

- **Observed (manifest) variables**: Directly measured (e.g., survey items, test scores)
- **Latent (unobserved) variables**: Theoretical constructs measured indirectly through observed indicators (e.g., "motivation," "intelligence")
- **Structural paths**: Directional relationships between variables (regression-like)
- **Measurement model**: How latent variables relate to their indicators (CFA)
- **Structural model**: How latent variables relate to each other (path analysis)

## SEM Components

| Component | Description | Diagram Symbol |
|-----------|-------------|---------------|
| Observed variable | Measured directly | Rectangle |
| Latent variable | Inferred from indicators | Oval/circle |
| Regression path | Directional relationship | Single-headed arrow |
| Covariance | Non-directional association | Double-headed arrow |
| Error/residual | Unexplained variance | Small circle with arrow |

## Step 1: Confirmatory Factor Analysis (CFA)

CFA tests whether observed variables load onto hypothesized latent factors.

### In R (lavaan)

```r
library(lavaan)

# Define the measurement model
# =~ means "is measured by"
cfa_model <- '
  # Latent variable definitions
  Motivation =~ mot1 + mot2 + mot3 + mot4
  SelfEfficacy =~ se1 + se2 + se3
  Performance =~ perf1 + perf2 + perf3 + perf4

  # Covariances between latent variables (estimated by default in CFA)
'

# Fit the model
fit <- cfa(cfa_model, data = mydata, estimator = "MLR")

# View results
summary(fit, fit.measures = TRUE, standardized = TRUE)

# Key output to examine:
# - Factor loadings (standardized > 0.5 is desirable)
# - Model fit indices (see table below)
# - Modification indices (for model improvement)
modindices(fit, sort = TRUE, minimum.value = 10)
```

### In Python (semopy)

```python
import semopy
import pandas as pd

# Define model in lavaan-like syntax
model_spec = """
Motivation =~ mot1 + mot2 + mot3 + mot4
SelfEfficacy =~ se1 + se2 + se3
Performance =~ perf1 + perf2 + perf3 + perf4
"""

# Fit the model
model = semopy.Model(model_spec)
result = model.fit(data)

# View parameter estimates
print(model.inspect())

# Get fit statistics
stats = semopy.calc_stats(model)
print(stats.T)
```

## Step 2: Full Structural Model

After confirming the measurement model, add structural (regression) paths.

### In R (lavaan)

```r
sem_model <- '
  # Measurement model
  Motivation =~ mot1 + mot2 + mot3 + mot4
  SelfEfficacy =~ se1 + se2 + se3
  Performance =~ perf1 + perf2 + perf3 + perf4

  # Structural model (regressions)
  # ~ means "is regressed on"
  Performance ~ Motivation + SelfEfficacy
  SelfEfficacy ~ Motivation

  # Optional: define indirect effect
  # indirect := a * b
'

fit <- sem(sem_model, data = mydata, estimator = "MLR")
summary(fit, fit.measures = TRUE, standardized = TRUE, rsquare = TRUE)
```

### Mediation Analysis

```r
mediation_model <- '
  # Measurement model
  X =~ x1 + x2 + x3
  M =~ m1 + m2 + m3
  Y =~ y1 + y2 + y3

  # Structural model
  M ~ a*X          # a path
  Y ~ b*M + c*X    # b path + direct effect c

  # Define indirect and total effects
  indirect := a * b
  total := c + a * b
'

fit <- sem(mediation_model, data = mydata, se = "bootstrap", bootstrap = 1000)
summary(fit, standardized = TRUE)

# Bootstrap confidence intervals for indirect effect
parameterEstimates(fit, boot.ci.type = "bca.simple", standardized = TRUE)
```

## Model Fit Assessment

### Fit Index Reference Table

| Index | Good Fit | Acceptable | What It Measures |
|-------|----------|------------|-----------------|
| Chi-square (p) | p > 0.05 | Sensitive to N; use with other indices | Exact fit test |
| Chi-square/df | < 2 | < 3 | Parsimony-adjusted exact fit |
| CFI | > 0.95 | > 0.90 | Comparative fit vs. null model |
| TLI | > 0.95 | > 0.90 | CFI adjusted for parsimony |
| RMSEA | < 0.06 | < 0.08 | Approximate fit per df |
| SRMR | < 0.08 | < 0.10 | Average residual correlation |
| AIC/BIC | Lower = better | -- | Model comparison (not absolute) |

### Interpreting Fit

```r
# Extract fit measures in lavaan
fitMeasures(fit, c("chisq", "df", "pvalue", "cfi", "tli", "rmsea",
                    "rmsea.ci.lower", "rmsea.ci.upper", "srmr"))
```

**Reporting template:**
```
The structural equation model demonstrated adequate fit to the data:
chi-square(df) = X.XX, p = .XXX; CFI = .XX; TLI = .XX; RMSEA = .XXX
[90% CI: .XXX, .XXX]; SRMR = .XXX.
```

## Model Modification and Comparison

### Modification Indices

```r
# Show top modification indices
mi <- modindices(fit, sort = TRUE)
head(mi, 10)

# Common modifications:
# - Allow error covariances between similarly-worded items
# - Add cross-loadings (if theoretically justified)
# - Remove non-significant paths
```

### Model Comparison

```r
# Compare nested models using chi-square difference test
fit1 <- sem(model1, data = mydata)  # More constrained
fit2 <- sem(model2, data = mydata)  # Less constrained

anova(fit1, fit2)  # Chi-square difference test

# For non-nested models, compare AIC/BIC
fitMeasures(fit1, c("aic", "bic"))
fitMeasures(fit2, c("aic", "bic"))
```

## Common Pitfalls

| Issue | Problem | Solution |
|-------|---------|----------|
| Small sample size | Unstable estimates, poor fit | Minimum N = 200, or 10-20 per parameter |
| Too many parameters | Overfitting, non-convergence | Simplify model, use parceling |
| Non-normal data | Biased standard errors | Use MLR estimator or bootstrapping |
| Ignoring missing data | Biased results | Use FIML (full information maximum likelihood) |
| Data-driven respecification | Capitalizing on chance | Cross-validate with holdout sample |
| Conflating fit with truth | Good fit does not mean correct model | Consider equivalent/alternative models |

## Assumptions and Diagnostics

1. **Multivariate normality**: Check with Mardia's test; use robust estimators (MLR) if violated
2. **Linearity**: SEM assumes linear relationships between variables
3. **No multicollinearity**: Correlations between latent variables should not exceed 0.85
4. **Sufficient sample size**: Rule of thumb: N >= 200 or 10-20 observations per estimated parameter
5. **Correct model specification**: Omitted variables can bias all estimates

```r
# Check multivariate normality
library(MVN)
mvn(mydata[, c("mot1", "mot2", "mot3", "se1", "se2", "se3")],
    mvnTest = "mardia")

# Use robust estimation if non-normal
fit_robust <- sem(sem_model, data = mydata, estimator = "MLR")
```
