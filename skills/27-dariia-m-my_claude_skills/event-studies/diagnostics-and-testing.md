# Diagnostics, Testing, and Sensitivity Analysis

## Table of Contents

1. Pre-Trend Testing
2. Bacon Decomposition
3. Placebo and Falsification Tests
4. Sensitivity Analysis with HonestDiD
5. Balance and Covariate Checks
6. Aggregation and Power Considerations

---

## 1. Pre-Trend Testing

### Visual Inspection

The most important diagnostic is the event study plot itself. Look at pre-treatment
coefficients: are they close to zero? Do they show a trend? Visual inspection is more
informative than formal tests because it reveals patterns (drifts, level shifts) that
a single test statistic misses.

### Formal Joint Test of Pre-Trends

Test whether all pre-treatment coefficients are jointly zero:

```r
library(fixest)
library(car)

# Estimate the event study
es_model <- feols(
  outcome ~ i(rel_time, ref = -1) | unit_id + year,
  data = df,
  cluster = ~unit_id
)

# Joint F-test of pre-treatment coefficients
# Identify pre-treatment coefficient names
pre_coefs <- grep("rel_time::-[2-9]|rel_time::-[1-9][0-9]", names(coef(es_model)), value = TRUE)

# Using fixest's built-in wald test
wald(es_model, keep = pre_coefs)
```

### Roth (2022) - Pre-Test Bias Warning

Jonathan Roth (2022) "Pre-test with Caution" shows that conditioning on passing a
pre-trends test introduces bias. The intuition:
- If you only proceed when pre-trends look flat, you're selecting on a noisy signal.
- This selection can bias your post-treatment estimates, especially when pre-trends
  have low power to detect violations.
- The bias is toward finding significant post-treatment effects even when the true
  effect is zero.

Implications:
- Don't treat a non-significant pre-trends test as proof of parallel trends.
- Consider the HonestDiD sensitivity analysis (Section 4) as a complement.
- Report the event study plot regardless of whether pre-trends "pass."
- Be especially cautious when the confidence intervals on pre-trends are wide.

---

## 2. Bacon Decomposition

Goodman-Bacon (2021) showed that TWFE DiD with staggered treatment is a weighted
average of all possible 2x2 DiD comparisons. The decomposition reveals which
comparisons drive your estimate and whether problematic comparisons (using
already-treated as controls) get large weights.

```r
# install.packages("bacondecomp")
library(bacondecomp)

# Requires a balanced panel with a binary treatment indicator
# df needs: unit_id, time, treatment (0/1), outcome

bacon_out <- bacon(
  outcome ~ treatment,
  data = df,
  id_var = "unit_id",
  time_var = "year"
)

# View the decomposition
print(bacon_out)

# The output shows:
# - Type: "Earlier vs Later Treated", "Later vs Earlier Treated", "Treated vs Untreated"
# - Weight: how much each comparison contributes to TWFE
# - Estimate: the 2x2 DiD estimate for each comparison

# Plot the decomposition
ggplot(bacon_out, aes(x = weight, y = estimate, color = type, shape = type)) +
  geom_point(size = 3) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  labs(
    x = "Weight in TWFE Estimate",
    y = "2x2 DiD Estimate",
    title = "Bacon Decomposition of TWFE Estimate",
    color = "Comparison Type",
    shape = "Comparison Type"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    legend.position = "bottom",
    panel.grid.minor = element_blank()
  )
```

### Interpreting the Decomposition

- **Treated vs Untreated**: Clean comparisons. These are fine.
- **Earlier vs Later Treated**: Uses not-yet-treated as controls. Fine if no anticipation.
- **Later vs Earlier Treated**: Uses already-treated as controls. Problematic if
  treatment effects change over time.

If "Later vs Earlier Treated" comparisons have large weights and different estimates
from other types, your TWFE is likely contaminated. Switch to a robust estimator.

---

## 3. Placebo and Falsification Tests

### Placebo Treatment Timing

Assign a fake treatment date before the actual treatment and test for effects:

```r
# Create a placebo treatment, e.g., 3 years before actual treatment
df_placebo <- df |>
  mutate(
    placebo_treat_year = treat_year - 3,
    placebo_rel_time = year - placebo_treat_year
  ) |>
  # Only use pre-treatment data for this test
  filter(year < treat_year | !treated)

es_placebo <- feols(
  outcome ~ i(placebo_rel_time, ref = -1) | unit_id + year,
  data = df_placebo,
  cluster = ~unit_id
)

iplot(es_placebo,
      main = "Placebo Test: Fake Treatment 3 Years Early",
      xlab = "Periods Relative to Placebo Treatment")
abline(h = 0, lty = 2)
```

### Placebo Outcome

Test whether treatment affects an outcome it theoretically should not affect:

```r
es_placebo_outcome <- feols(
  placebo_outcome ~ i(rel_time, ref = -1) | unit_id + year,
  data = df,
  cluster = ~unit_id
)

iplot(es_placebo_outcome,
      main = "Placebo Test: Effect on Unrelated Outcome")
abline(h = 0, lty = 2)
```

### Randomization / Permutation Inference

Randomly reassign treatment across units and re-estimate. Repeat many times to build
a distribution under the null of no effect:

```r
set.seed(58104)
n_perms <- 500
perm_estimates <- numeric(n_perms)

# Get the true estimate (e.g., simple post-treatment ATT)
true_model <- feols(outcome ~ treated_post | unit_id + year, data = df, cluster = ~unit_id)
true_est <- coef(true_model)["treated_post"]

for (i in 1:n_perms) {
  # Randomly reassign treatment groups
  df_perm <- df
  unit_ids <- unique(df_perm$unit_id)
  perm_treated <- sample(unit_ids, sum(df$treated[df$year == min(df$year)]))
  df_perm$treated_perm <- df_perm$unit_id %in% perm_treated
  df_perm$treated_post_perm <- df_perm$treated_perm & (df_perm$year >= df_perm$treat_year)

  perm_model <- feols(outcome ~ treated_post_perm | unit_id + year, data = df_perm)
  perm_estimates[i] <- coef(perm_model)["treated_post_perm"]
}

# Permutation p-value
p_perm <- mean(abs(perm_estimates) >= abs(true_est))
cat("Permutation p-value:", p_perm, "\n")

# Plot the distribution
ggplot(data.frame(est = perm_estimates), aes(x = est)) +
  geom_histogram(bins = 50, fill = "gray70", color = "white") +
  geom_vline(xintercept = true_est, color = "red", linewidth = 1) +
  labs(
    x = "Estimated Effect",
    y = "Count",
    title = "Permutation Distribution",
    caption = paste0("Red line = true estimate. Permutation p-value = ", round(p_perm, 3))
  ) +
  theme_minimal(base_size = 13)
```

---

## 4. Sensitivity Analysis with HonestDiD

Rambachan & Roth (2023) "A More Credible Approach to Parallel Trends" provides
tools to assess how robust your conclusions are to violations of parallel trends.

The key question: how much would parallel trends need to be violated to explain
away your treatment effect?

```r
# install.packages("HonestDiD")
library(HonestDiD)

# First, estimate the event study with fixest
es_model <- feols(
  outcome ~ i(rel_time, ref = -1) | unit_id + year,
  data = df,
  cluster = ~unit_id
)

# Extract results for HonestDiD
# Need: coefficient vector and variance-covariance matrix
# for both pre-treatment and post-treatment coefficients

betahat <- coef(es_model)
sigma <- vcov(es_model)

# Identify pre and post coefficients
# Pre-treatment: negative rel_time (excluding -1 which is the reference)
# Post-treatment: rel_time >= 0

# Get coefficient names and indices
coef_names <- names(betahat)
pre_idx <- grep("rel_time::-[2-9]|rel_time::-[1-9][0-9]", coef_names)
post_idx <- grep("rel_time::[0-9]", coef_names)

# Sort by relative time
pre_times <- as.numeric(stringr::str_extract(coef_names[pre_idx], "-?\\d+"))
post_times <- as.numeric(stringr::str_extract(coef_names[post_idx], "-?\\d+"))

pre_idx <- pre_idx[order(pre_times)]
post_idx <- post_idx[order(post_times)]

# Relative magnitudes approach:
# How large could the post-treatment violation be relative to the max pre-trend?
honest_rm <- createSensitivityResults_relativeMagnitudes(
  betahat = betahat[c(pre_idx, post_idx)],
  sigma = sigma[c(pre_idx, post_idx), c(pre_idx, post_idx)],
  numPrePeriods = length(pre_idx),
  numPostPeriods = length(post_idx),
  Mbarvec = seq(0, 2, by = 0.5)  # Grid of M-bar values
)

# Smoothness-based approach:
# Allows for smooth violations of parallel trends
honest_smooth <- createSensitivityResults(
  betahat = betahat[c(pre_idx, post_idx)],
  sigma = sigma[c(pre_idx, post_idx), c(pre_idx, post_idx)],
  numPrePeriods = length(pre_idx),
  numPostPeriods = length(post_idx),
  Mvec = seq(0, 0.05, by = 0.01)  # Grid of M values (slope change bound)
)

# Original event study plot with sensitivity
createSensitivityPlot_relativeMagnitudes(honest_rm,
  rescaleFactor = 1,
  gridPoints = 100
)
```

### Interpreting HonestDiD

- **M-bar = 0**: Assumes parallel trends hold exactly. This is the standard result.
- **M-bar = 1**: Allows post-treatment violations up to the size of the largest pre-trend.
- **M-bar = 2**: Allows violations twice as large as the largest pre-trend.

If your confidence intervals exclude zero even at M-bar = 1 or 2, your results are
robust to meaningful violations of parallel trends. If they don't, your conclusions
are more fragile.

---

## 5. Balance and Covariate Checks

### Pre-Treatment Covariate Balance

Check whether treated and control groups are balanced on observables:

```r
library(dplyr)

# Pre-treatment period only
pre_data <- df |> filter(year < treat_year | !treated)

# Balance table
balance <- pre_data |>
  group_by(treated) |>
  summarise(
    across(c(covariate1, covariate2, covariate3),
           list(mean = mean, sd = sd),
           .names = "{.col}_{.fn}")
  )

print(balance)

# Normalized differences (preferred over t-tests for balance)
norm_diff <- function(x_treat, x_control, sd_treat, sd_control) {
  (x_treat - x_control) / sqrt((sd_treat^2 + sd_control^2) / 2)
}
```

### Event Study on Covariates

Run event studies on pre-treatment covariates. If treatment "affects" a covariate
that it shouldn't, something is wrong:

```r
# Event study on a covariate
es_covariate <- feols(
  covariate1 ~ i(rel_time, ref = -1) | unit_id + year,
  data = df,
  cluster = ~unit_id
)

iplot(es_covariate,
      main = "Covariate Balance: Event Study on Covariate 1")
abline(h = 0, lty = 2)
```

---

## 6. Aggregation and Power Considerations

### Power Analysis for Event Studies

Burlig, Preonas, and Woerman (2020) discuss power in event study settings:

```r
# Rough power calculation for event study
# Key parameters:
# - N: number of units
# - T_pre: pre-treatment periods
# - T_post: post-treatment periods
# - prop_treated: share of units treated
# - sigma_unit: unit-level SD
# - rho: within-unit correlation
# - mde: minimum detectable effect

power_es <- function(N, T_pre, T_post, prop_treated, sigma_unit, rho, alpha = 0.05) {
  n_treated <- N * prop_treated
  n_control <- N * (1 - prop_treated)

  # Effective sample size accounting for clustering
  T_total <- T_pre + T_post
  deff <- 1 + (T_total - 1) * rho  # Design effect

  # SE of the DiD estimate (approximate)
  se <- sigma_unit * sqrt(deff * (1/n_treated + 1/n_control) / T_post)

  # MDE for 80% power
  mde <- (qnorm(1 - alpha/2) + qnorm(0.8)) * se

  return(list(se = se, mde = mde))
}

# Example
pow <- power_es(N = 500, T_pre = 5, T_post = 5,
                prop_treated = 0.5, sigma_unit = 1, rho = 0.5)
cat("MDE (80% power):", pow$mde, "\n")
```

### Trimming Extreme Relative Time Periods

When some relative time periods have very few observations, estimates are noisy.
Consider trimming or binning:

```r
# Count observations per relative time period
obs_per_period <- df |>
  filter(is.finite(rel_time)) |>
  count(rel_time)

# Only keep periods with sufficient observations
min_obs <- 50  # Adjust based on your data
valid_periods <- obs_per_period |> filter(n >= min_obs) |> pull(rel_time)

es_trimmed <- feols(
  outcome ~ i(rel_time, ref = -1) | unit_id + year,
  data = df |> filter(rel_time %in% valid_periods | !treated),
  cluster = ~unit_id
)
```

### Aggregating Post-Treatment Effects

Often you want a single summary measure of the treatment effect:

```r
# Average post-treatment effect from the event study
post_coefs <- grep("rel_time::[0-9]", names(coef(es_model)), value = TRUE)

# Using fixest's aggregate function
# For overall ATT in sunab models:
# summary(sa_model, agg = "ATT")

# Manual aggregation with lincom:
lincom_formula <- paste0("(", paste(post_coefs, collapse = " + "), ") / ", length(post_coefs))
# Note: exact syntax depends on fixest version

# Or extract and average:
post_est <- coef(es_model)[post_coefs]
post_vcov <- vcov(es_model)[post_coefs, post_coefs]

avg_effect <- mean(post_est)
avg_se <- sqrt(sum(post_vcov)) / length(post_coefs)
cat("Average post-treatment effect:", avg_effect, "(SE:", avg_se, ")\n")
```
