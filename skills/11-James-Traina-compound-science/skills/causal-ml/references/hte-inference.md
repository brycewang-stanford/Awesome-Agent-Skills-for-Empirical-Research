# HTE Inference and Reporting — Reference

## Global Test for Heterogeneity

Before reporting CATE estimates, test whether there is genuine heterogeneity. The BLP (best linear projection) approach due to Chernozhukov, Demirer, Duflo, Fernandez-Val (2022) is the standard test:

```r
# R: grf
cal <- test_calibration(cf)
# H0: no heterogeneity (differential.forest.prediction = 0)
# Reject H0 → genuine heterogeneity detected

# Python: econml (manual BLP)
from econml.inference import LinearModelFinalInference
# Use cf.effect() predictions and regress on summary statistics
```

**Do not report heterogeneous effects if the calibration test fails to reject at a reasonable level (p > 0.10).** Report the calibration test result alongside CATE estimates.

## Confidence Intervals on Individual CATE

Individual CATE confidence intervals from causal forests are valid but conservative (they are honest pointwise CIs, not uniform CIs). They should be interpreted as uncertainty about τ(xᵢ), not as evidence that τ(xᵢ) ≠ 0 for that individual.

```python
# econml: point estimates and CIs for each unit
tau_lb, tau_ub = cf.effect_interval(X_test, alpha=0.05)

# R: grf
tau_hat <- predict(cf, estimate.variance = TRUE)
tau_ci_lo <- tau_hat$predictions - 1.96 * sqrt(tau_hat$variance.estimates)
tau_ci_hi <- tau_hat$predictions + 1.96 * sqrt(tau_hat$variance.estimates)
```

**Warning:** Do not use individual CIs for policy targeting without accounting for multiple testing. Targeting based on wide CIs that nominally include zero for some units and not others leads to invalid inference.

## Best Linear Projection of CATE

The best linear projection (BLP) onto covariates gives a sparse, interpretable summary of heterogeneity:

```python
# econml: summary of CATE heterogeneity
blp = cf.const_marginal_effect_inference(X).summary_frame()
print(blp)  # coefficient on each X variable in BLP of CATE
```

```r
# R: grf
blp <- best_linear_projection(cf, A = X_matrix)
print(blp)
# Coefficients tell you: which observed characteristics predict larger/smaller CATE
```

## Subgroup Analysis: Pre-Specified vs Data-Driven

**Pre-specified subgroups** (defined before analysis):
- Report group-specific ATEs using forest-weighted estimators
- Standard: `average_treatment_effect(cf, subset = group_indicator)` in R

**Data-driven subgroups** (quartiles of τ̂(x)):
- Compute quartile cutoffs of τ̂ on a held-out sample
- Report ATEs within quartiles — this is exploratory, not confirmatory
- Requires multiplicity correction (Benjamini-Hochberg) if multiple subgroups reported

```r
# R: subgroup ATE using forest
high_effect <- tau_hat$predictions > median(tau_hat$predictions)

ate_high <- average_treatment_effect(cf, subset = high_effect)
ate_low  <- average_treatment_effect(cf, subset = !high_effect)

cat("ATE (high CATE group):", ate_high["estimate"], "\n")
cat("ATE (low CATE group): ", ate_low["estimate"],  "\n")
```
