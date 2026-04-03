# Traditional Event Study with TWFE

## The Setup

A traditional event study uses a two-way fixed effects (TWFE) regression with leads and lags
of a treatment indicator. The idea: if you can show that outcomes evolved similarly between
treated and control groups before treatment (the "pre-trends"), and then diverged after,
you have compelling evidence that the treatment caused the divergence.

## The Model

The canonical specification is:

```
Y_it = α_i + λ_t + Σ_{k ≠ -1} β_k × D_it^k + X_it'γ + ε_it
```

Where:
- `Y_it` is the outcome for unit i at time t
- `α_i` are unit fixed effects
- `λ_t` are time fixed effects
- `D_it^k` is an indicator for unit i being k periods from treatment at time t
- `k = -1` is omitted (the reference period)
- `X_it` are optional time-varying controls
- `β_k` are the event study coefficients: pre-trends for k < -1, treatment effects for k ≥ 0

## Assumptions

1. **Parallel trends**: Absent treatment, treated and control units would have followed
   the same outcome trajectory. This is the key identifying assumption and is untestable
   in the post-treatment period. Pre-trends provide indirect evidence.

2. **No anticipation**: Units don't change behavior before treatment actually occurs.
   If violated, you can adjust the reference period or allow for anticipation effects.

3. **SUTVA (Stable Unit Treatment Value Assumption)**: One unit's treatment doesn't
   affect another unit's outcome (no spillovers), and treatment is well-defined.

4. **Homogeneous treatment effects (for TWFE validity in staggered designs)**:
   When treatment timing varies, TWFE assumes treatment effects are the same across
   cohorts and over time since treatment. If this fails, TWFE estimates can be biased -
   this is the key motivation for modern robust estimators.

## Implementation in R with fixest

`fixest` is the recommended package for traditional event studies. It's fast, has excellent
syntax, and handles event studies natively with `i()` for interaction terms and `sunab()`
for Sun & Abraham.

### Basic Event Study

```r
library(fixest)
library(ggplot2)

# ---- Data Preparation ----
# Assume: df has columns: unit_id, year, treat_year (year of treatment, Inf or NA if never treated), outcome
# Create relative time variable
df$rel_time <- df$year - df$treat_year

# For never-treated units, set rel_time to a large negative or handle via NA
# fixest handles never-treated units well if treat_year is set appropriately

# ---- Estimation ----
# Using fixest::i() to create the event study dummies
# ref = -1 sets the reference period
# bin argument bins extreme values (e.g., bin = c(-5, 5) bins ≤-5 and ≥5)

es_model <- feols(
  outcome ~ i(rel_time, ref = -1) | unit_id + year,
  data = df,
  cluster = ~unit_id
)

summary(es_model)
```

### Plotting with fixest's Built-in Tools

```r
# fixest has a native event study plotting function
iplot(es_model,
      xlab = "Periods Relative to Treatment",
      ylab = "Estimated Effect",
      main = "Event Study: Effect on Outcome")

# Add reference lines manually if needed
abline(h = 0, lty = 2, col = "gray50")
abline(v = -0.5, lty = 2, col = "gray50")
```

### Publication-Quality Plot with ggplot2

For more control over the plot, extract coefficients and use ggplot2:

```r
library(ggplot2)
library(broom)

# Extract coefficients
es_coefs <- broom::tidy(es_model, conf.int = TRUE) |>
  # Parse the relative time from coefficient names
  # fixest names them like "rel_time::-5", "rel_time::0", etc.
  dplyr::mutate(
    rel_time = as.numeric(stringr::str_extract(term, "-?\\d+"))
  ) |>
  dplyr::filter(!is.na(rel_time))

# Add the reference period (coefficient = 0 by construction)
ref_row <- data.frame(
  term = "ref",
  estimate = 0,
  std.error = 0,
  conf.low = 0,
  conf.high = 0,
  rel_time = -1
)
es_coefs <- dplyr::bind_rows(es_coefs, ref_row)

# Plot
ggplot(es_coefs, aes(x = rel_time, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray50") +
  geom_errorbar(aes(ymin = conf.low, ymax = conf.high), width = 0.2, color = "steelblue") +
  geom_point(color = "steelblue", size = 2) +
  labs(
    x = "Periods Relative to Treatment",
    y = "Estimated Effect on Outcome",
    title = "Event Study",
    caption = "Notes: Reference period is t = -1. 95% confidence intervals shown.\nStandard errors clustered at the unit level."
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )
```

### With Binned Endpoints

When you have very long pre or post periods, bin the endpoints to avoid noisy estimates
from periods with few observations:

```r
# Bin at -5 and +5
es_model_binned <- feols(
  outcome ~ i(rel_time, ref = -1, bin = c(-5, 5)) | unit_id + year,
  data = df,
  cluster = ~unit_id
)

iplot(es_model_binned)
```

### With Controls

```r
# Add time-varying controls
es_model_controls <- feols(
  outcome ~ i(rel_time, ref = -1) + control_var1 + control_var2 | unit_id + year,
  data = df,
  cluster = ~unit_id
)
```

### With Heterogeneity by Group

```r
# Estimate separate event studies by group (e.g., by region)
es_by_group <- feols(
  outcome ~ i(rel_time, ref = -1) | unit_id + year,
  data = df,
  cluster = ~unit_id,
  split = ~group_var
)

# Plot all together
iplot(es_by_group)
```

## When Traditional TWFE Breaks Down

The traditional event study with TWFE works well when:
- All treated units are treated at the same time, OR
- Treatment effects are homogeneous across cohorts and over time

It can produce misleading estimates when:
- Treatment is staggered AND effects vary across cohorts or evolve differently over time
- Already-treated units serve as "controls" for later-treated units
- Negative weights emerge in the TWFE estimand (see Bacon decomposition in diagnostics)

When these concerns apply, move to the modern extensions (see `modern-extensions.md`).

## Simulated Example for Testing

Here's a complete simulated example you can use to verify code works:

```r
library(fixest)
library(ggplot2)
library(dplyr)

set.seed(90841)

# Simulate panel data
n_units <- 200
n_periods <- 20
treat_period <- 11  # Treatment happens at period 11 for treated units

df_sim <- expand.grid(
  unit_id = 1:n_units,
  time = 1:n_periods
) |>
  mutate(
    treated = unit_id <= 100,  # First 100 units are treated
    treat_year = ifelse(treated, treat_period, Inf),
    rel_time = time - treat_year,
    # True effect: grows linearly after treatment
    true_effect = ifelse(treated & time >= treat_period, (time - treat_period + 1) * 0.5, 0),
    # Unit and time fixed effects + noise
    unit_fe = rep(rnorm(n_units, 0, 2), each = n_periods),
    time_fe = rep(rnorm(n_periods, 0, 1), times = n_units),
    outcome = unit_fe + time_fe + true_effect + rnorm(n_units * n_periods, 0, 1)
  )

# Estimate event study
es <- feols(
  outcome ~ i(rel_time, ref = -1) | unit_id + time,
  data = df_sim |> filter(is.finite(rel_time) | !treated),
  cluster = ~unit_id
)

# Plot
iplot(es,
      xlab = "Periods Relative to Treatment",
      ylab = "Estimated Effect",
      main = "Simulated Event Study")
abline(h = 0, lty = 2, col = "gray50")
abline(v = -0.5, lty = 2, col = "gray50")
```
