---
name: assessment-design-guide
description: "Psychometrics and educational assessment design for researchers"
metadata:
  openclaw:
    emoji: "📋"
    category: "domains"
    subcategory: "education"
    keywords: ["psychometrics", "assessment", "item-response-theory", "test-design", "validity", "reliability"]
    source: "wentor"
---

# Assessment Design Guide

A skill for designing, validating, and analyzing educational assessments using modern psychometric methods. Covers classical test theory, item response theory, test construction, validity evidence, and computerized adaptive testing.

## Classical Test Theory

### Reliability Analysis

Classical test theory (CTT) models observed scores as the sum of a true score and error:

```
X = T + E
```

Key reliability coefficients:

| Coefficient | Method | Interpretation |
|-------------|--------|----------------|
| Cronbach's alpha | Internal consistency | Homogeneity of items |
| Test-retest | Stability over time | Temporal consistency |
| Parallel forms | Equivalent test versions | Form equivalence |
| Split-half (Spearman-Brown) | Odd-even item split | Internal consistency |
| Inter-rater (Cohen's kappa) | Multiple raters | Scoring agreement |

```python
import numpy as np
import pandas as pd

def item_analysis(responses: pd.DataFrame, total_scores: pd.Series) -> pd.DataFrame:
    """
    Classical item analysis: difficulty, discrimination, point-biserial.
    responses: binary DataFrame (1=correct, 0=incorrect), items as columns.
    total_scores: total test score for each examinee.
    """
    results = []
    for item in responses.columns:
        scores = responses[item]
        difficulty = scores.mean()  # p-value (proportion correct)

        # Point-biserial correlation
        corr = scores.corr(total_scores)

        # Upper-lower discrimination (top/bottom 27%)
        n = len(total_scores)
        cutoff_high = total_scores.quantile(0.73)
        cutoff_low = total_scores.quantile(0.27)
        upper = scores[total_scores >= cutoff_high].mean()
        lower = scores[total_scores <= cutoff_low].mean()
        discrimination = upper - lower

        results.append({
            "item": item,
            "difficulty": round(difficulty, 3),
            "discrimination": round(discrimination, 3),
            "point_biserial": round(corr, 3),
            "flag": "review" if difficulty < 0.2 or difficulty > 0.9
                    or discrimination < 0.2 else "ok"
        })
    return pd.DataFrame(results)
```

### Item Selection Guidelines

- **Difficulty**: Aim for p-values between 0.30 and 0.80 for maximum discrimination
- **Discrimination**: Items with D < 0.20 should be revised or removed
- **Distractors**: Each distractor should attract at least 5% of examinees
- **Point-biserial**: Should be positive and ideally above 0.25

## Item Response Theory

### The Three-Parameter Logistic Model

IRT provides a more rigorous framework than CTT by modeling the probability of a correct response as a function of ability and item parameters:

```python
import numpy as np

def irt_3pl(theta: float, a: float, b: float, c: float) -> float:
    """
    Three-parameter logistic IRT model.
    theta: examinee ability (typically -3 to +3)
    a: discrimination parameter (slope, typically 0.5 to 2.5)
    b: difficulty parameter (location, same scale as theta)
    c: guessing parameter (lower asymptote, typically 0.0 to 0.35)
    Returns: probability of correct response
    """
    exponent = -a * (theta - b)
    return c + (1 - c) / (1 + np.exp(exponent))

# Item characteristic curves for three items
thetas = np.linspace(-3, 3, 100)
item_easy = [irt_3pl(t, a=1.0, b=-1.0, c=0.2) for t in thetas]
item_medium = [irt_3pl(t, a=1.5, b=0.0, c=0.2) for t in thetas]
item_hard = [irt_3pl(t, a=1.2, b=1.5, c=0.2) for t in thetas]
```

### IRT Model Estimation

```python
# Using the 'mirt' package in R (called via rpy2 or standalone)
# R code for fitting a 2PL model:
r_code = """
library(mirt)

# responses: binary matrix (examinees x items)
mod <- mirt(responses, model = 1, itemtype = "2PL")

# Item parameters
coef(mod, simplify = TRUE)

# Ability estimates (Expected A Posteriori)
theta_hat <- fscores(mod, method = "EAP")

# Model fit
M2(mod)  # limited-information fit statistic
itemfit(mod, fit_stats = "S_X2")
"""
```

### Model Comparison

| Model | Parameters | Use Case |
|-------|-----------|----------|
| Rasch (1PL) | b only | Equal discrimination assumed; measurement-focused |
| 2PL | a, b | Different discrimination; general purpose |
| 3PL | a, b, c | Multiple choice with guessing |
| Graded Response | a, b_k | Likert-scale or partial credit items |
| Nominal Response | a_k, c_k | Multiple choice with informative distractors |

## Validity Evidence

### The Unified Validity Framework

Following the Standards for Educational and Psychological Testing (AERA/APA/NCME, 2014), validity is a unitary concept supported by five types of evidence:

1. **Content evidence**: Expert review confirms items represent the construct domain
2. **Response process evidence**: Think-aloud protocols confirm examinees engage intended cognitive processes
3. **Internal structure evidence**: Factor analysis confirms dimensionality matches the test blueprint
4. **Relations to other variables**: Correlations with external criteria (convergent, discriminant, predictive)
5. **Consequences evidence**: Test use leads to intended benefits without unintended harm

```python
from factor_analyzer import FactorAnalyzer

# Confirmatory approach: check dimensionality
fa = FactorAnalyzer(n_factors=3, rotation="promax")
fa.fit(item_responses)

# Eigenvalues for scree plot
eigenvalues, _ = fa.get_eigenvalues()
print("Eigenvalues:", eigenvalues[:10])

# Factor loadings
loadings = pd.DataFrame(
    fa.loadings_,
    columns=["Factor1", "Factor2", "Factor3"],
    index=item_names
)
print(loadings.round(3))
```

## Computerized Adaptive Testing

### CAT Algorithm

Computerized adaptive testing selects items in real time to match examinee ability:

```
Initialize: theta_0 = 0 (prior mean)
For each item i = 1, 2, ..., until stopping rule met:
    1. Select item with maximum Fisher information at current theta
    2. Administer item, observe response
    3. Update theta estimate using maximum likelihood or Bayesian EAP
    4. Check stopping rule:
       - Fixed length (e.g., 30 items)
       - SE(theta) < threshold (e.g., 0.30)
       - Maximum time reached
Return: final theta estimate and standard error
```

### Item Exposure Control

To prevent overuse of high-quality items and maintain test security:

- **Sympson-Hetter method**: Set maximum exposure rates per item (e.g., 0.25)
- **a-stratified method**: Divide item bank into strata by discrimination, sample within strata
- **Shadow test approach**: Assemble full shadow tests at each step, administer the optimal item from the shadow test

## Tools and Software

- **R mirt package**: Full-featured IRT estimation, DIF analysis, CAT simulation
- **Python irt library (py-irt)**: Bayesian IRT models using PyTorch
- **jMetrik**: Open-source Java application for classical and IRT analysis
- **TAO (Testing Assistee par Ordinateur)**: Open-source assessment delivery platform
- **Concerto**: Open-source adaptive testing platform from Cambridge

## Key References

- Embretson, S.E. and Reise, S.P. (2000). *Item Response Theory for Psychologists*. Lawrence Erlbaum.
- de Ayala, R.J. (2022). *The Theory and Practice of Item Response Theory* (2nd ed.). Guilford Press.
- AERA, APA, and NCME (2014). *Standards for Educational and Psychological Testing*.
