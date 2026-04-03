# Integration and Advanced Features

## Contents

- [Multiple Estimation](#multiple-estimation)
- [Poisson Regression](#poisson-regression)
- [GLM (Logit/Probit)](#glm-logitprobit)
- [Quantile Regression](#quantile-regression)
- [marginaleffects Integration](#marginaleffects-integration)
- [Online Learning / Streaming](#online-learning--streaming)
- [Compressed Regression](#compressed-regression)
- [Performance Tuning](#performance-tuning)
- [Related Packages](#related-packages)

## Multiple Estimation

pyfixest can estimate many related models from a single function call using stepwise operators. This is efficient and produces well-organized output.

### Stepwise Operators

| Operator | Behavior | Example Formula | Models Produced |
|----------|----------|-----------------|-----------------|
| `sw(X1, X2)` | Sequential replacement | `"Y ~ sw(X1, X2) \| fe"` | Y~X1\|fe, Y~X2\|fe |
| `sw0(X1, X2)` | Sequential + empty baseline | `"Y ~ sw0(X1, X2) \| fe"` | Y~1\|fe, Y~X1\|fe, Y~X2\|fe |
| `csw(X1, X2)` | Cumulative addition | `"Y ~ csw(X1, X2) \| fe"` | Y~X1\|fe, Y~X1+X2\|fe |
| `csw0(X1, X2)` | Cumulative + empty baseline | `"Y ~ csw0(X1, X2) \| fe"` | Y~1\|fe, Y~X1\|fe, Y~X1+X2\|fe |
| `mvsw(X1, X2)` | All 2^n combinations | `"Y ~ mvsw(X1, X2) \| fe"` | All non-empty subsets |

### Examples

```python
import pyfixest as pf

data = pf.get_data()

# Build up controls cumulatively — classic "robustness table" pattern
fits = pf.feols("Y ~ csw0(X1, X2) | f1", data=data)
pf.etable(fits)

# Multiple dependent variables
fits = pf.feols("Y + Y2 ~ X1 | f1", data=data)
pf.etable(fits)

# Combine: multiple outcomes × cumulative controls
fits = pf.feols("Y + Y2 ~ csw0(X1, X2) | f1", data=data)
pf.etable(fits)  # Produces 2 outcomes × 3 control sets = 6 models
```

### Sample Splitting

```python
# Estimate by subgroup only
fits = pf.feols("Y ~ X1 | f1", data=data, split="f2")

# Full sample + each subgroup
fits = pf.feols("Y ~ X1 | f1", data=data, fsplit="f2")
pf.etable(fits)
```

`split` runs the regression separately for each level of the splitting variable. `fsplit` adds the full-sample estimate as the first column.

### Cartesian Product of Operators

Operators combine multiplicatively:

```python
# csw on controls × sw on FE specifications
fits = pf.feols("Y ~ csw(X1, X2) | sw(f1, f1 + f2)", data=data)
# Produces: 2 control specs × 2 FE specs = 4 models
```

## Poisson Regression

`fepois()` estimates Poisson pseudo-maximum likelihood (PPML) regression with multi-way FE, following the ppmlhdfe algorithm (Correia, Guimarães, & Zylkin, 2020).

### Basic Usage

```python
# Count outcome with fixed effects
fit = pf.fepois("count_Y ~ X1 + X2 | entity + year", data=df,
                vcov={"CRV1": "entity"})
fit.summary()
```

### When to Use Poisson

- **Count data**: Outcomes that are non-negative integers (patents, publications, trade flows)
- **Log-linear models**: Poisson PPML is consistent for E[Y|X] = exp(Xβ) even when Y is not a count — making it appropriate for gravity models in trade, for example
- **Zeros in the outcome**: Unlike log-OLS, Poisson handles zeros naturally without requiring log(Y+1) transformations

### Convergence and Separation

```python
# Increase iterations if convergence is slow
fit = pf.fepois("Y ~ X1 | fe1 + fe2", data=df,
                iwls_maxiter=50,       # Max IWLS iterations (default 25)
                iwls_tol=1e-08,        # Convergence tolerance
                separation_check=True, # Check for separated observations
                )
```

**Separation** occurs when some FE levels perfectly predict zero counts. Separated observations have infinite likelihood and must be detected and handled. pyfixest can check for separation but the user should be aware of this possibility with sparse count data.

### Poisson with Multiple Estimation

```python
# Stepwise controls with Poisson
fits = pf.fepois("Y ~ csw0(X1, X2, X3) | entity + year", data=df)
pf.etable(fits)
```

## GLM (Logit/Probit)

`feglm()` estimates generalized linear models.

### Basic Usage

```python
# Logit model
fit = pf.feglm("binary_Y ~ X1 + X2", data=df, family="logit",
               vcov="hetero")
fit.summary()

# Probit model
fit = pf.feglm("binary_Y ~ X1 + X2", data=df, family="probit",
               vcov="hetero")

# Gaussian GLM
fit = pf.feglm("Y ~ X1 + X2", data=df, family="gaussian")
```

### Fixed Effects Limitation

**`feglm()` does NOT currently support fixed effects demeaning.** This is a work in progress. Attempting `pf.feglm("Y ~ X | fe", ...)` raises `NotImplementedError`.

**Workarounds:**
- **Linear probability model**: Use `pf.feols("binary_Y ~ X | fe", data=df)` — interprets coefficients as percentage point changes in probability
- **Manual dummies**: Include FE as explicit dummy variables (slow for many levels)
- **statsmodels**: For logit/probit with moderately many FE levels, use `statsmodels` with dummy variables
- **Conditional logit**: For binary outcomes with entity FE, Chamberlain's conditional logit eliminates the incidental parameters problem

## Quantile Regression

Estimate conditional quantile functions (experimental feature).

```python
# Single quantile (median regression)
fit = pf.quantreg("Y ~ X1 + X2", data=df, quantile=0.5)
fit.summary()

# Multiple quantiles
fits = pf.quantreg("Y ~ X1 + X2", data=df,
                   quantile=[0.1, 0.25, 0.5, 0.75, 0.9])

# Visualize coefficient estimates across quantiles
pf.qplot(fits, nrow=2)
```

### Standard Errors for Quantile Regression

```python
fit = pf.quantreg("Y ~ X1 + X2", data=df, quantile=0.5,
                  vcov="iid")           # IID
fit = pf.quantreg("Y ~ X1 + X2", data=df, quantile=0.5,
                  vcov="hetero")        # Heteroskedasticity-robust
fit = pf.quantreg("Y ~ X1 + X2", data=df, quantile=0.5,
                  vcov={"CRV1": "g"})   # Clustered
```

### Solver Options

| Method | Use For |
|--------|---------|
| `"fn"` (default) | Frisch-Newton interior point — single quantile |
| `"pfn"` | Preprocessing Frisch-Newton — single quantile, large datasets |
| `"cfm1"` (default multi) | Independent estimation of each quantile |
| `"cfm2"` | Faster but uses asymptotic equivalence approximation |

**Note:** Quantile regression is marked **experimental** in pyfixest. Check the changelog for stability updates.

## marginaleffects Integration

The `marginaleffects` Python package provides post-estimation interpretation for pyfixest models: average marginal effects, predictions, comparisons, and hypothesis tests.

### Installation

```bash
pip install marginaleffects
```

### Average Marginal Effects

```python
from marginaleffects import avg_slopes, predictions, comparisons

fit = pf.feols("Y ~ X1 + X2 + X1:X2 | fe", data=df)

# Average marginal effect of X1 (accounting for interaction)
avg_slopes(fit, variables="X1")
```

### Predictions

```python
# Predicted values at specific covariate values
predictions(fit, newdata=datagrid(X1=[0, 1, 2], X2=df["X2"].mean()))
```

### Hypothesis Testing (Delta Method)

```python
from marginaleffects import hypotheses

# Linear hypothesis
hypotheses(fit, "X1 - X2 = 0")

# Nonlinear hypothesis (delta method computes gradient automatically)
hypotheses(fit, "(X1 / Intercept - 1) * 100 = 0")
```

Returns a DataFrame with estimate, standard error, z-statistic, p-value, and confidence interval.

### Compatibility and SE Limitation

`marginaleffects` works directly with `Feols`, `Fepois`, and `Feglm` objects — no conversion needed.

**Important:** When using `marginaleffects` with pyfixest models that include fixed effects, standard errors are computed with `vcov=False` (no uncertainty quantification for FE parameters). This means `marginaleffects` SEs do not account for uncertainty in the absorbed fixed effects. For most applied work this is acceptable (FE are nuisance parameters), but be aware of this limitation when interpreting confidence intervals from `avg_slopes()` or `predictions()`.

## Online Learning / Streaming

Update regression coefficients for new observations without re-fitting the entire model, using the Sherman-Morrison formula.

```python
fit = pf.feols("Y ~ X1 + X2", data=df_initial)

# Update with new data
fit_updated = fit.update(X_new, y_new, inplace=False)
```

- `inplace=False` (default): Returns a new object, original unchanged
- `inplace=True`: Modifies the fitted object in place

Useful for very large datasets or sequential data processing where re-estimation is expensive.

## Compressed Regression

For large datasets, compressed regression reduces memory usage by compressing the data before estimation.

```python
fit = pf.feols("Y ~ X1 + X2 | fe", data=df,
               use_compression=True)
```

Returns a `FeolsCompressed` object. Point estimates are identical to standard `feols()`; inference adjusts for the compression.

## Performance Tuning

### Backend Selection

| Component | Parameter | Options | Default |
|-----------|-----------|---------|---------|
| FE demeaning | `demeaner_backend` | `"numba"`, `"jax"`, `"cupy"`, `"scipy"`, `"rust-cg"` | `"numba"` |
| Linear solver | `solver` | `"scipy.linalg.solve"`, `"numpy.linalg.solve"`, `"jax"` | `"scipy.linalg.solve"` |

### When to Switch Backends

| Scenario | Recommendation |
|----------|---------------|
| Standard use (<1M obs) | Default (numba + scipy) |
| Large data, many FE | Try `jax` or `cupy` with GPU |
| numba installation issues | `demeaner_backend="scipy"` |
| GPU available (Nvidia A100+) | `demeaner_backend="jax"`, `solver="jax"` |

```python
# GPU-accelerated estimation
fit = pf.feols("Y ~ X1 | f1 + f2 + f3", data=large_df,
               demeaner_backend="jax", solver="jax")
```

### Other Performance Parameters

```python
fit = pf.feols("Y ~ X1 | f1 + f2", data=df,
               lean=True,              # Reduce memory footprint of result
               copy_data=False,        # Don't copy input data (careful: may modify in place)
               store_data=False,       # Don't store data in result object
               fixef_rm="singleton",   # Drop singleton FE (default, improves speed)
               )
```

## Related Packages

pyfixest sits within a broader Python econometrics ecosystem. These packages complement its functionality:

| Package | Role | When to Use Instead/Alongside |
|---------|------|-------------------------------|
| `linearmodels` | Panel FE/RE, IV/2SLS/GMM, system estimation | Random effects models, GMM estimation |
| `rdrobust` | Regression discontinuity (sharp, fuzzy, bandwidth) | RD designs |
| `marginaleffects` | Post-estimation: marginal effects, predictions | Interpreting interaction/nonlinear models |
| `wildboottest` | Wild cluster bootstrap | Few-cluster inference (called via `fit.wildboottest()`) |
| `statsmodels` | OLS, GLM, time series, diagnostics | Non-FE regression, GLM, time series, diagnostic tests |
| `pydynpd` | Dynamic panel GMM (Arellano-Bond, Blundell-Bond) | Lagged dependent variable, dynamic panels |

## References and Further Reading

- Correia, S., Guimarães, P., and Zylkin, T. (2020). "Fast Poisson Estimation with High-Dimensional Fixed Effects." *Stata Journal*, 20(1), 95-115
- Arel-Bundock, V. (2024). "marginaleffects: Predictions, Comparisons, Slopes, Marginal Means, and Hypothesis Tests." https://marginaleffects.com/
- Berge, L., Butts, K., and McDermott, G. (2026). "Fast and User-Friendly Econometrics Estimations: The R Package fixest." arXiv:2601.21749
- Koenker, R. (2005). *Quantile Regression*. Cambridge University Press
- pyfixest documentation: https://pyfixest.org
