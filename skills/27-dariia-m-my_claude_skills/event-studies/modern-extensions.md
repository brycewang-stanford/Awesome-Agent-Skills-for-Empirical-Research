# Modern Extensions to Event Studies

## Table of Contents

1. Why TWFE Fails with Staggered Treatment
2. Callaway & Sant'Anna (2021) - The `did` Package
3. Sun & Abraham (2021) - Interaction-Weighted Estimator via `fixest`
4. Gardner (2022) - Two-Stage DiD via `did2s`
5. de Chaisemartin & D'Haultfoeuille (2020) - `DIDmultiplegt`
6. Borusyak, Jaravel & Spiess (2024) - Imputation Estimator via `didimputation`
7. Roth et al. (2023) Overview and Choosing Between Estimators
8. Comparing Estimators Side by Side

---

## 1. Why TWFE Fails with Staggered Treatment

The core problem: when treatment rolls out at different times and treatment effects are
heterogeneous (vary across cohorts or over time), TWFE can produce biased estimates.

The intuition:
- TWFE implicitly uses already-treated units as controls for newly-treated units.
- This means it's comparing newly-treated units to units who have already been experiencing
  treatment for a while.
- If treatment effects change over time (e.g., grow or shrink), this comparison is contaminated.
- The resulting estimates can be a weighted average of treatment effects where some weights
  are negative, meaning the overall estimate can even have the wrong sign.

Goodman-Bacon (2021) formalized this by showing that the TWFE estimator is a weighted average
of all possible 2x2 DiD comparisons in the data. Some of these comparisons use already-treated
units as controls, and the weights on different comparisons can be negative.

The solution: modern estimators that only use valid comparisons - typically comparing
newly-treated units to not-yet-treated or never-treated units.

---

## 2. Callaway & Sant'Anna (2021) - The `did` Package

**Key idea**: Estimate group-time average treatment effects ATT(g,t) separately for each
treatment cohort g at each time period t, using only clean comparison groups (never-treated
or not-yet-treated). Then aggregate these into summary measures.

**When to use**: This is the most popular and well-tested robust estimator. Good default
choice for staggered DiD with heterogeneous effects.

### Installation and Setup

```r
# install.packages("did")
library(did)
library(ggplot2)
library(dplyr)
```

### Basic Usage

```r
# Data requirements:
# - yname: outcome variable name (character)
# - tname: time period variable name (character)
# - idname: unit ID variable name (character)
# - gname: group variable = the time period when unit is first treated
#          Use 0 for never-treated units

# Estimate group-time ATTs
cs_out <- att_gt(
  yname = "outcome",
  tname = "year",
  idname = "unit_id",
  gname = "treat_year",  # 0 for never-treated
  data = df,
  control_group = "notyettreated",  # or "nevertreated"
  est_method = "dr",  # doubly robust (default); also "ipw" or "reg"
  clustervars = "unit_id",
  base_period = "varying"  # "varying" (default) or "universal"
)

summary(cs_out)
```

### Aggregation

```r
# Dynamic/event study aggregation (the event study plot)
cs_es <- aggte(cs_out, type = "dynamic")
summary(cs_es)

# Plot the event study
ggdid(cs_es,
      title = "Event Study (Callaway & Sant'Anna)",
      xlab = "Periods Relative to Treatment",
      ylab = "ATT")

# Simple overall ATT aggregation
cs_simple <- aggte(cs_out, type = "simple")
summary(cs_simple)

# Group-specific aggregation (ATT by treatment cohort)
cs_group <- aggte(cs_out, type = "group")
summary(cs_group)

# Calendar time aggregation
cs_calendar <- aggte(cs_out, type = "calendar")
summary(cs_calendar)
```

### Custom ggplot2 Event Study Plot

```r
# Extract event study coefficients for custom plotting
cs_df <- data.frame(
  rel_time = cs_es$egt,
  estimate = cs_es$att.egt,
  se = cs_es$se.egt
) |>
  mutate(
    conf.low = estimate - 1.96 * se,
    conf.high = estimate + 1.96 * se
  )

ggplot(cs_df, aes(x = rel_time, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray50") +
  geom_errorbar(aes(ymin = conf.low, ymax = conf.high), width = 0.2, color = "#E69F00") +
  geom_point(color = "#E69F00", size = 2) +
  labs(
    x = "Periods Relative to Treatment",
    y = "ATT",
    title = "Event Study (Callaway & Sant'Anna 2021)",
    caption = "95% pointwise confidence intervals. Control group: not-yet-treated."
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )
```

### Options and Variants

```r
# With covariates (must be time-invariant or pre-treatment values)
cs_out_cov <- att_gt(
  yname = "outcome",
  tname = "year",
  idname = "unit_id",
  gname = "treat_year",
  data = df,
  xformla = ~ covariate1 + covariate2,  # Covariate formula
  control_group = "notyettreated",
  est_method = "dr"
)

# Using never-treated only as controls
cs_out_nt <- att_gt(
  yname = "outcome",
  tname = "year",
  idname = "unit_id",
  gname = "treat_year",
  data = df,
  control_group = "nevertreated"
)

# Simultaneous confidence bands (uniform inference, more conservative)
cs_es_unif <- aggte(cs_out, type = "dynamic")
# ggdid shows both pointwise and simultaneous CIs by default
ggdid(cs_es_unif)
```

---

## 3. Sun & Abraham (2021) - Interaction-Weighted Estimator

**Key idea**: Decompose the TWFE event study into cohort-specific estimates, then
aggregate using the right weights (cohort shares). Implemented directly in `fixest`
via `sunab()`.

**When to use**: When you like the `fixest` workflow and want a drop-in robust replacement
for the traditional event study. Requires a never-treated or last-treated group.

### Implementation

```r
library(fixest)

# sunab(treat_year, year) handles everything:
# - cohort_var: the period each unit was first treated (Inf or NA for never-treated)
# - period_var: the calendar time
sa_model <- feols(
  outcome ~ sunab(treat_year, year) | unit_id + year,
  data = df,
  cluster = ~unit_id
)

summary(sa_model)

# Event study plot (fixest native)
iplot(sa_model,
      xlab = "Periods Relative to Treatment",
      ylab = "Estimated Effect",
      main = "Event Study (Sun & Abraham 2021)")
abline(h = 0, lty = 2, col = "gray50")
abline(v = -0.5, lty = 2, col = "gray50")

# Get the aggregated ATT
summary(sa_model, agg = "ATT")

# Aggregate by relative period (cohort-averaged dynamic effects)
summary(sa_model, agg = "period")
```

### ggplot2 Custom Plot

```r
# Extract coefficients
sa_coefs <- broom::tidy(sa_model, conf.int = TRUE) |>
  mutate(
    rel_time = as.numeric(stringr::str_extract(term, "-?\\d+"))
  ) |>
  filter(!is.na(rel_time))

# Add reference period
sa_coefs <- bind_rows(
  sa_coefs,
  data.frame(term = "ref", estimate = 0, std.error = 0,
             conf.low = 0, conf.high = 0, rel_time = -1)
)

ggplot(sa_coefs, aes(x = rel_time, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray50") +
  geom_errorbar(aes(ymin = conf.low, ymax = conf.high), width = 0.2, color = "#56B4E9") +
  geom_point(color = "#56B4E9", size = 2) +
  labs(
    x = "Periods Relative to Treatment",
    y = "Estimated Effect",
    title = "Event Study (Sun & Abraham 2021)"
  ) +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"), panel.grid.minor = element_blank())
```

---

## 4. Gardner (2022) - Two-Stage DiD via `did2s`

**Key idea**: In stage 1, estimate unit and time fixed effects using only untreated
observations (not-yet-treated and never-treated in their pre-treatment periods).
In stage 2, residualize the outcome for all observations, then regress the residualized
outcome on treatment indicators. This "cleans out" the fixed effects without contamination
from treatment effects.

**When to use**: Conceptually simple, handles staggered treatment well. Good complement
to Callaway & Sant'Anna.

### Implementation

```r
# install.packages("did2s")
library(did2s)

# Basic usage
g_model <- did2s(
  data = df,
  yname = "outcome",
  first_stage = ~ 0 | unit_id + year,  # Fixed effects (first stage)
  second_stage = ~ i(rel_time, ref = -1),  # Event study (second stage)
  treatment = "treated_post",  # Binary: 1 if treated and in post-treatment period
  cluster_var = "unit_id"
)

# fixest-style plotting works directly
iplot(g_model,
      xlab = "Periods Relative to Treatment",
      ylab = "Estimated Effect",
      main = "Event Study (Gardner 2022, did2s)")

# Or with ggplot2 (same extraction method as fixest models)
```

### With Controls

```r
g_model_cov <- did2s(
  data = df,
  yname = "outcome",
  first_stage = ~ covariate1 + covariate2 | unit_id + year,
  second_stage = ~ i(rel_time, ref = -1),
  treatment = "treated_post",
  cluster_var = "unit_id"
)
```

---

## 5. de Chaisemartin & D'Haultfoeuille (2020) - `DIDmultiplegt`

**Key idea**: Estimate treatment effects period by period, comparing newly-treated
units (switchers) to units whose treatment status doesn't change (stable units).
Uses only "clean" comparisons.

**When to use**: When you have a binary treatment that switches on (and possibly off).
Especially useful when treatment can turn on and off.

### Implementation

```r
# install.packages("DIDmultiplegt")
library(DIDmultiplegt)

# Basic estimation
dcdh_out <- did_multiplegt(
  df = df,
  Y = "outcome",
  G = "unit_id",
  T = "year",
  D = "treatment",  # Binary treatment indicator (0/1)
  placebo = 4,  # Number of pre-treatment placebo periods to estimate
  dynamic = 4,  # Number of post-treatment dynamic effects to estimate
  brep = 100,   # Bootstrap replications for inference
  cluster = "unit_id"
)

# The output is a list with effects, placebos, and SEs
# Create a manual event study plot:
n_placebo <- 4
n_dynamic <- 4

dcdh_df <- data.frame(
  rel_time = c(-(n_placebo:1), 0:n_dynamic),
  estimate = c(
    rev(dcdh_out$placebo),   # Placebo estimates (reverse order)
    dcdh_out$effect,          # Dynamic effects (including contemporaneous)
    dcdh_out$dynamic
  ),
  se = c(
    rev(dcdh_out$se_placebo),
    dcdh_out$se_effect,
    dcdh_out$se_dynamic
  )
) |>
  mutate(
    conf.low = estimate - 1.96 * se,
    conf.high = estimate + 1.96 * se
  )

ggplot(dcdh_df, aes(x = rel_time, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray50") +
  geom_errorbar(aes(ymin = conf.low, ymax = conf.high), width = 0.2, color = "#009E73") +
  geom_point(color = "#009E73", size = 2) +
  labs(
    x = "Periods Relative to Treatment",
    y = "Estimated Effect",
    title = "Event Study (de Chaisemartin & D'Haultfoeuille 2020)"
  ) +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"), panel.grid.minor = element_blank())
```

**Note**: The `DIDmultiplegt` package has been updated in recent versions. Check the
package documentation for the latest syntax. A newer version `DIDmultiplegtDYN` is
also available with additional features.

---

## 6. Borusyak, Jaravel & Spiess (2024) - Imputation Estimator

**Key idea**: Impute untreated potential outcomes for treated units using a model
estimated on untreated observations (similar to Gardner's first stage), then
compute treatment effects as the difference between observed and imputed outcomes.
Efficient and handles heterogeneity well.

**When to use**: Good all-around choice, especially for large panels. Computationally
efficient.

### Implementation

```r
# install.packages("didimputation")
library(didimputation)

# Basic event study
bjs_model <- did_imputation(
  data = df,
  yname = "outcome",
  gname = "treat_year",  # First treatment period (0 for never-treated)
  tname = "year",
  idname = "unit_id",
  horizon = c(-5:5),  # Relative time periods to estimate
  pretrends = TRUE     # Include pre-treatment periods
)

# Plot
bjs_model |>
  ggplot(aes(x = term, y = estimate, ymin = conf.low, ymax = conf.high)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray50") +
  geom_errorbar(aes(ymin = conf.low, ymax = conf.high), width = 0.2, color = "#CC79A7") +
  geom_point(color = "#CC79A7", size = 2) +
  labs(
    x = "Periods Relative to Treatment",
    y = "Estimated Effect",
    title = "Event Study (Borusyak, Jaravel & Spiess 2024)"
  ) +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"), panel.grid.minor = element_blank())
```

---

## 7. Roth et al. (2023) - Choosing Between Estimators

Roth, Sant'Anna, Bilinski, and Poe (2023) "What's Trending in Difference-in-Differences?"
provide an excellent overview. Key takeaways for choosing:

| Estimator | Pros | Cons |
|-----------|------|------|
| Callaway & Sant'Anna | Very flexible, multiple aggregations, covariates via DR | Can be slow with many groups/periods |
| Sun & Abraham | Integrates with fixest, familiar syntax | Requires never-treated or last-treated group |
| Gardner (did2s) | Conceptually simple, fast | Standard errors require care |
| de Chaisemartin & D'H. | Handles treatment turning on/off | Bootstrap inference can be slow |
| Borusyak et al. | Efficient, fast | Requires parallel trends in levels |

**Practical advice**:
- For most applied work, start with Callaway & Sant'Anna (most flexible, well-tested).
- If you're already using fixest, Sun & Abraham via `sunab()` is a natural choice.
- Run two or three estimators and check that results are qualitatively similar.
- If results differ substantially across estimators, investigate why - it may reveal
  important features of your setting.

---

## 8. Comparing Estimators Side by Side

Here's a template for plotting multiple estimators together:

```r
library(ggplot2)
library(dplyr)

# Assume you have data frames from each estimator with columns:
# rel_time, estimate, conf.low, conf.high, estimator

all_estimates <- bind_rows(
  twfe_df |> mutate(estimator = "TWFE"),
  cs_df |> mutate(estimator = "Callaway & Sant'Anna"),
  sa_df |> mutate(estimator = "Sun & Abraham")
)

# Color palette (colorblind-friendly)
colors <- c(
  "TWFE" = "#0072B2",
  "Callaway & Sant'Anna" = "#E69F00",
  "Sun & Abraham" = "#56B4E9"
)

ggplot(all_estimates, aes(x = rel_time, y = estimate, color = estimator)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray50") +
  geom_errorbar(aes(ymin = conf.low, ymax = conf.high), width = 0.2,
                position = position_dodge(width = 0.3)) +
  geom_point(size = 2, position = position_dodge(width = 0.3)) +
  scale_color_manual(values = colors) +
  labs(
    x = "Periods Relative to Treatment",
    y = "Estimated Effect",
    title = "Event Study: Comparing Estimators",
    color = "Estimator"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    legend.position = "bottom"
  )

# Alternative: faceted
ggplot(all_estimates, aes(x = rel_time, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray50") +
  geom_errorbar(aes(ymin = conf.low, ymax = conf.high), width = 0.2, color = "steelblue") +
  geom_point(color = "steelblue", size = 1.5) +
  facet_wrap(~estimator, ncol = 1) +
  labs(
    x = "Periods Relative to Treatment",
    y = "Estimated Effect",
    title = "Event Study: Comparing Estimators"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    strip.text = element_text(face = "bold")
  )
```
