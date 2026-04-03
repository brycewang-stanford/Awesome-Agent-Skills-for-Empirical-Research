# Advanced Inference

## Contents

- [Wild Cluster Bootstrap](#wild-cluster-bootstrap)
- [Randomization Inference](#randomization-inference)
- [Multiple Testing Corrections](#multiple-testing-corrections)
- [Gelbach Decomposition](#gelbach-decomposition)
- [Causal Cluster Variance (CCV)](#causal-cluster-variance-ccv)
- [Wald Tests](#wald-tests)

## Wild Cluster Bootstrap

When the number of clusters is small (<20), asymptotic cluster-robust standard errors (CRV1) have poor finite-sample properties — rejection rates can far exceed nominal levels. Wild cluster bootstrap provides more reliable inference.

### Basic Usage

```python
import pyfixest as pf

fit = pf.feols("Y ~ treatment | entity + year", data=df,
               vcov={"CRV1": "state"})

# Bootstrap test for the treatment coefficient
boot = fit.wildboottest(
    param="treatment",     # Parameter to test
    reps=9999,             # Bootstrap replications (more = more precise p-value)
    cluster="state",       # Cluster variable
    seed=42,               # Reproducibility
)
```

The result contains:
- **p-value**: Bootstrap p-value for H0: coefficient = 0
- **Confidence interval**: Bootstrap confidence interval

### Weight Types

Wild cluster bootstrap perturbs cluster-level residuals using random weights:

- **Rademacher weights** (default): +1 or -1 with equal probability. Standard choice, works well with ≥10 clusters
- **Webb weights**: 6-point distribution. Better for very few clusters (<10), as Rademacher has only 2^G distinct bootstrap datasets

### When to Use

| Clusters | Recommendation |
|----------|---------------|
| >50 | CRV1 is generally reliable |
| 20-50 | CRV1 is acceptable; bootstrap as robustness check |
| 10-20 | Use wild bootstrap as primary inference |
| <10 | Use wild bootstrap with Webb weights; interpret cautiously |

### Visualization

```python
# Plot the bootstrap distribution
fit.plot_ritest()  # If using ritest; for wildboottest, inspect the returned object
```

**Package dependency:** Wild cluster bootstrap requires the `wildboottest` package (`pip install wildboottest`), a Python port of the R `fwildclusterboot` package.

## Randomization Inference

Randomization inference (RI) tests the sharp null hypothesis that treatment had zero effect on every unit. It constructs a reference distribution by repeatedly reassigning treatment and computing the test statistic.

### Basic Usage

```python
fit = pf.feols("Y ~ treatment | entity + year", data=df,
               vcov={"CRV1": "state"})

# Randomization inference for treatment
ri = fit.ritest(
    resampvar="treatment",    # Variable to reshuffle
    reps=1000,                # Number of permutations
    cluster="state",          # Reshuffle at cluster level
    type="randomization-c",   # Inference type
)
```

### Visualizing the RI Distribution

```python
# Plot: observed test statistic vs. permutation distribution
fit.plot_ritest()
```

The plot shows where the actual estimate falls in the distribution of estimates under random reassignment. A p-value close to 0 means the observed effect would be very unlikely under the sharp null.

### When to Use

- **Randomized experiments**: RI is the natural inference framework when treatment is actually randomized
- **Testing the sharp null**: When you want to test "did the treatment have any effect on anyone?" (rather than "is the average effect nonzero?")
- **Small samples**: RI does not rely on large-sample asymptotics
- **As a complement**: Report alongside conventional inference for robustness

### Comparison to Standard Inference

| Feature | Conventional (t-test) | Randomization Inference |
|---------|----------------------|------------------------|
| Null hypothesis | Average effect = 0 | Effect = 0 for every unit |
| Requires | Large-sample asymptotics | Only exchangeability under null |
| Sample size | Needs large N or G | Works with any size |
| Power | Generally more powerful | May have less power |

## Multiple Testing Corrections

When testing the same hypothesis across multiple outcomes or specifications, the probability of at least one false positive increases rapidly. pyfixest provides three correction methods.

### Bonferroni Correction

The simplest correction: multiply each p-value by the number of tests.

```python
fit1 = pf.feols("Y1 ~ treatment | fe", data=df, vcov={"CRV1": "cluster"})
fit2 = pf.feols("Y2 ~ treatment | fe", data=df, vcov={"CRV1": "cluster"})
fit3 = pf.feols("Y3 ~ treatment | fe", data=df, vcov={"CRV1": "cluster"})

# Bonferroni-adjusted p-values
pf.bonferroni([fit1, fit2, fit3], param="treatment")
```

Bonferroni is conservative — it controls the family-wise error rate (FWER) but may reject too few hypotheses.

### Romano-Wolf Step-Down

```python
# Resampling-based correction — less conservative than Bonferroni
pf.rwolf(
    [fit1, fit2, fit3],
    param="treatment",
    reps=999,
    seed=42,
)
```

Romano-Wolf uses a step-down procedure: it tests hypotheses sequentially, dropping rejected ones and re-computing critical values. This yields more power while still controlling FWER.

### Westfall-Young

```python
pf.wyoung(
    [fit1, fit2, fit3],
    param="treatment",
    reps=999,
    seed=42,
)
```

Another resampling-based FWER correction, similar in spirit to Romano-Wolf.

### When to Use Multiple Testing Corrections

Apply corrections when:
- Testing the **same treatment** on multiple outcomes (e.g., does a school reform affect test scores, attendance, AND graduation?)
- Running the **same specification** on multiple subgroups
- Presenting a family of related hypothesis tests

Do NOT routinely apply corrections to:
- Different specifications of the same outcome (these are robustness checks, not independent tests)
- Exploratory analysis (corrections are for confirmatory testing)

## Gelbach Decomposition

Gelbach (2016) decomposes the change in a coefficient when additional controls are added. This answers: "Which specific controls explain most of the change in the coefficient of interest?"

### Basic Usage

```python
# Full model with all controls
fit = pf.feols("wage ~ gender + education + experience + industry | state",
               data=df, vcov={"CRV1": "state"})

# Decompose: how much does the gender coefficient change when controls are added?
gb = fit.decompose(
    decomp_var="gender[T.male]",      # Coefficient to decompose
    combine_covariates={              # Group related covariates
        "education": re.compile("education"),
        "experience": re.compile("experience"),
    },
)
```

### Viewing Results

```python
import re

# Table of decomposition results
gb.etable(panels="levels")           # By variable levels
gb.etable(panels="all")              # Including normalized contributions

# DataFrame output
gb.tidy()

# Visualization
gb.coefplot()
```

### Interpretation

The decomposition shows how much each control variable (or group of controls) explains of the gap between the bivariate coefficient (gender only) and the multivariate coefficient (gender + controls). This is more informative than simply noting "the coefficient changed when I added controls" — it pinpoints which controls matter and by how much.

**Example interpretation:** "The raw gender wage gap is 15%. Adding education controls reduces it by 4 percentage points, experience by 3 points, and industry by 6 points, leaving an unexplained gap of 2%."

## Causal Cluster Variance (CCV)

Following Abadie, Athey, Imbens, and Wooldridge (2023), CCV provides design-based variance estimation that accounts for the specific randomization or sampling design.

```python
fit = pf.feols("Y ~ treatment | entity + year", data=df)

ccv = fit.ccv(
    treatment="treatment",     # Treatment variable
    cluster="state",           # Cluster variable
    pk=0.05,                   # Proportion of treated clusters
    qk=1.0,                    # Proportion of units sampled per cluster
    seed=42,
    n_splits=8,                # Number of sample splits
)
```

### When CCV Applies

CCV is appropriate when:
- Treatment is assigned at the cluster level (e.g., state-level policy)
- Clusters are sampled from a larger population
- You want to account for both sampling uncertainty and treatment effect heterogeneity

CCV standard errors can be substantially smaller than conventional cluster-robust SEs when the treatment effect heterogeneity across clusters is small relative to sampling uncertainty.

## Wald Tests

Test linear hypotheses about estimated coefficients.

### Using `wald_test()`

The `wald_test()` method takes a restriction matrix `R` and optional vector `q` for the hypothesis H0: Rβ = q:

```python
import numpy as np

fit = pf.feols("Y ~ X1 + X2 + X3 | fe", data=df)

# Test: X1 = X2 (i.e., X1 - X2 = 0)
# R matrix has one row: [1, -1, 0] for [X1, X2, X3]
fit.wald_test(R=np.array([[1, -1, 0]]))

# Test: X1 = 0 AND X2 = 0 (joint significance)
fit.wald_test(R=np.eye(2, 3))  # First two coefficients
```

The `distribution` parameter controls whether the test uses an F-distribution (default) or chi-squared.

### With marginaleffects (Recommended for Complex Hypotheses)

For string-based hypotheses and nonlinear tests (which require the delta method), use the `marginaleffects` package:

```python
from marginaleffects import hypotheses

# Linear hypothesis
hypotheses(fit, "X1 - X2 = 0")

# Nonlinear hypothesis (delta method for standard errors)
hypotheses(fit, "(X1 / Intercept - 1) * 100 = 0")
```

The `marginaleffects` package automates gradient computation for the delta method, making nonlinear hypothesis tests straightforward.

## References and Further Reading

- MacKinnon, J.G., Nielsen, M.Ø., and Webb, M.D. (2023). "Cluster-Robust Inference: A Guide to Empirical Practice." *Journal of Econometrics*, 232(2), 272-299
- Romano, J.P. and Wolf, M. (2005). "Stepwise Multiple Testing as Formalized Data Snooping." *Econometrica*, 73(4), 1237-1282
- Westfall, P.H. and Young, S.S. (1993). *Resampling-Based Multiple Testing*. Wiley
- Gelbach, J.B. (2016). "When Do Covariates Matter? And Which Ones, and How Much?" *Journal of Labor Economics*, 34(2), 509-543
- Abadie, A., Athey, S., Imbens, G.W., and Wooldridge, J.M. (2023). "When Should You Adjust Standard Errors for Clustering?" *Quarterly Journal of Economics*, 138(1), 1-35
- Fisher, R.A. (1935). *The Design of Experiments*. Oliver and Boyd. (Original randomization inference framework)
- Young, A. (2019). "Channeling Fisher: Randomization Tests and the Statistical Insignificance of Seemingly Significant Experimental Results." *Quarterly Journal of Economics*, 134(2), 557-598
- pyfixest documentation — Inference: https://pyfixest.org
