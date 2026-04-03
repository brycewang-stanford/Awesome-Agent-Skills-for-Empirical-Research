---
name: econometrics-r
description: R-based econometric analysis for academic research. Use when writing R code for panel data, difference-in-differences, instrumental variables, spatial econometrics, or regression analysis. Covers data.table, fixest, sf, modelsummary, and publication-ready outputs.
---

# R Econometrics Skill

## Core Packages
```r
library(data.table)      # Data manipulation
library(fixest)          # Fixed effects estimation  
library(modelsummary)    # Regression tables
library(ggplot2)         # Visualization
library(sf)              # Spatial data
library(here)            # Project paths
```

## Data Manipulation (data.table)
```r
# Read and assign
dt <- fread(here("data", "raw", "file.csv"))

# Common operations
dt[, new_var := old_var * 100]                    # Create variable
dt[, mean_y := mean(y, na.rm = TRUE), by = group] # Group operations
dt[year >= 2000 & treated == 1]                   # Filter
dt[, .(mean_y = mean(y), n = .N), by = group]     # Summarize
dt[other_dt, on = .(id, year)]                    # Merge

# Lag/lead within groups
setorder(dt, id, year)
dt[, lag_y := shift(y, 1), by = id]
dt[, lead_y := shift(y, -1), by = id]
```

## Estimation (fixest)

### Basic Fixed Effects
```r
# Two-way fixed effects
est1 <- feols(y ~ treatment + controls | id + year, data = dt)

# Clustered standard errors (default: fixed effect groups)
est2 <- feols(y ~ treatment | id + year, data = dt, cluster = ~state)

# IV regression  
est3 <- feols(y ~ controls | id + year | endog ~ instrument, data = dt)
```

### Difference-in-Differences
```r
# Classic 2x2 DiD
est_did <- feols(y ~ treated:post | id + year, data = dt)

# Event study / dynamic effects
dt[, rel_time := year - treatment_year]
dt[, rel_time := fifelse(is.na(rel_time), -1000, rel_time)]  # Never-treated

est_es <- feols(y ~ i(rel_time, ref = -1) | id + year, data = dt)
iplot(est_es)  # Coefficient plot
```

### Sun-Abraham / Callaway-Sant'Anna
```r
# Sun-Abraham (requires cohort variable)
est_sa <- feols(y ~ sunab(cohort, year) | id + year, data = dt)

# Multiple estimators comparison
library(did)  # Callaway-Sant'Anna
```

## Tables Output

### modelsummary
```r
models <- list(
  "OLS"       = est1,
  "With FE"   = est2,
  "IV"        = est3
)

modelsummary(models,
  stars = c('*' = 0.1, '**' = 0.05, '***' = 0.01),
  coef_omit = "Intercept",
  gof_omit = "AIC|BIC|Log",
  output = here("output", "tables", "main_results.tex")
)
```

### fixest::etable
```r
etable(est1, est2, est3,
  se.below = TRUE,
  keep = "treatment",
  fitstat = c("n", "r2", "fe"),
  tex = TRUE,
  file = here("output", "tables", "results.tex")
)

# example
etable(
    m1.suit, m2.suit,
    dict = c(
        'gruter_1' = 'Gruter Suitability 1',
        'gruter_2' = 'Gruter Suitability 2',
        'gruter_3' = 'Gruter Suitability 3',
        'gruter_4' = 'Gruter Suitability 4',
        'area_ha' = 'Orchard Size (ha)',
        'yield' = 'Yield (kg/ha), 2023'
    ),
    extralines = list(
        '_Average yield (kg/ha)' = c(
            round(mean(yields[area_ha > 1 & year == 2023, yield], na.rm = TRUE), 2),
            round(mean(yields[area_ha > 1 & year == 2023, yield], na.rm = TRUE), 2)
        ),
        '_Average orchard size (ha)' = c(
            round(mean(yields[area_ha > 1 & year == 2023, area_ha], na.rm = TRUE), 2),
            round(mean(yields[area_ha > 1 & year == 2023, area_ha], na.rm = TRUE), 2)
        )
    ),
    tex = TRUE,
    style.tex = style.tex('aer'),
    digits = 3,
    depvar = TRUE
)

```

## Figures

### Coefficient Plots
```r
coef_data <- broom::tidy(est_es, conf.int = TRUE)

ggplot(coef_data, aes(x = term, y = estimate)) +
  geom_point() +
  geom_errorbar(aes(ymin = conf.low, ymax = conf.high), width = 0.2) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  theme_bw() +
  labs(x = "Period", y = "Coefficient")

ggsave(here("output", "figures", "event_study.pdf"), width = 8, height = 5)
```

### Maps (sf)
```r
library(sf)
map_data <- st_read(here("data", "raw", "shapefile.shp"))
map_data <- merge(map_data, results_dt, by = "region_id")

ggplot(map_data) +
  geom_sf(aes(fill = estimate), color = "white", size = 0.1) +
  scale_fill_viridis_c() +
  theme_void()
```

## Spatial Econometrics
```r
library(spdep)
library(spatialreg)

# Create spatial weights
coords <- st_coordinates(st_centroid(map_data))
nb <- knn2nb(knearneigh(coords, k = 5))
W <- nb2listw(nb, style = "W")

# Spatial lag model
est_sar <- lagsarlm(y ~ x1 + x2, data = map_data, listw = W)

# Spatial error model  
est_sem <- errorsarlm(y ~ x1 + x2, data = map_data, listw = W)
```

## Machine Learning for Causal Inference
```r
library(grf)  # Generalized random forests

# Causal forest
cf <- causal_forest(
  X = as.matrix(dt[, .(x1, x2, x3)]),
  Y = dt$y,
  W = dt$treatment
)

# Treatment effects
ate <- average_treatment_effect(cf)
cate <- predict(cf)$predictions
```

## Best Practices
- Always set seed for reproducibility: `set.seed(12345)`
- Use `feols(..., lean = TRUE)` for large datasets
- Preallocate data.table columns when adding many variables
- Use `fwrite()` for fast CSV output
