# R & Stata Comparison — Methods Not Available in Python

Cross-language coverage gaps and package recommendations.

---

## Method Coverage Matrix

| Method | Python | R | Stata |
|--------|--------|---|-------|
| OLS / Robust SE | statsmodels | estimatr | reg, robust |
| Cluster SE | statsmodels | estimatr/lfe | cluster() |
| Two-way FE | statsmodels (slow) | fixest (fast) | reghdfe (fast) |
| DiD (2x2) | statsmodels | did/fixest | reghdfe |
| Event Study | manual | fixest/did | reghdfe + coefplot |
| Bacon Decomposition | **None** | bacondecomp | bacondecomp |
| Callaway-Sant'Anna | **None** | did | csdid |
| Sun & Abraham | **None** | fixest (sunab) | eventstudyinteract |
| Sharp RDD | statsmodels (manual) | rdrobust | rdrobust |
| Fuzzy RDD | linearmodels | rdrobust | rdrobust |
| McCrary Test | **None** | rdd | rddensity |
| IV / 2SLS | linearmodels | AER/ivreg | ivregress |
| JIVE | **None** | **None** | jive |
| Synthetic Control | **rpy2 only** | Synth + SCtools | synth |
| Augmented SC | **None** | augsynth | sdid |
| PSM / Matching | manual | MatchIt | teffects psmatch |
| CEM | **None** | MatchIt (method="cem") | cem |
| IPW | manual | ipw | teffects ipw |
| Randomization Inference | manual loop | ri2 | ritest |
| DAGs | **None** | dagitty + ggdag | **None** |

---

## Python Gaps — Recommended Workarounds

### Synthetic Control

No mature Python package. Two options:

1. **rpy2 bridge** (recommended for production):
```python
import rpy2.robjects as ro
from rpy2.robjects import pandas2ri
pandas2ri.activate()
ro.globalenv['df'] = df
ro.r('library(Synth); ...')
```

2. **SparseSC** (experimental): `pip install SparseSC` — limited functionality

### Bacon Decomposition

No Python implementation. Use R:
```r
library(bacondecomp)
bacon(y ~ treatment, data = df, id_var = "id", time_var = "year")
```

### Coarsened Exact Matching (CEM)

Stata's `cem` command is the gold standard. R alternative:
```r
library(MatchIt)
m.out <- matchit(treated ~ x1 + x2, data = df, method = "cem")
```

### McCrary Density Test

R implementation:
```r
library(rdd)
DCdensity(running_var, cutpoint = cutoff, plot = TRUE)
```

---

## Package Quick Reference

### R Packages

| Package | Purpose | Install |
|---------|---------|---------|
| estimatr | Robust/cluster SE OLS | `install.packages("estimatr")` |
| lfe | High-dimensional FE | `install.packages("lfe")` |
| fixest | Fast FE estimation | `install.packages("fixest")` |
| AER | IV / 2SLS | `install.packages("AER")` |
| rdrobust | RDD estimation | `install.packages("rdrobust")` |
| Synth | Synthetic control | `install.packages("Synth")` |
| SCtools | SC placebo tests | `install.packages("SCtools")` |
| MatchIt | Matching (PSM/CEM) | `install.packages("MatchIt")` |
| did | Callaway-Sant'Anna | `install.packages("did")` |
| bacondecomp | Bacon decomposition | `install.packages("bacondecomp")` |
| dagitty | DAG analysis | `install.packages("dagitty")` |
| ri2 | Randomization inference | `install.packages("ri2")` |
| ipw | Inverse probability weighting | `install.packages("ipw")` |

### Stata Packages

| Package | Purpose | Install |
|---------|---------|---------|
| reghdfe | High-dimensional FE | `ssc install reghdfe` |
| rdrobust | RDD estimation | `ssc install rdrobust` |
| synth | Synthetic control | `ssc install synth` |
| cem | Coarsened exact matching | `ssc install cem` |
| bacondecomp | Bacon decomposition | `ssc install bacondecomp` |
| ritest | Randomization inference | `ssc install ritest` |
| did_multiplegt | Staggered DiD | `ssc install did_multiplegt` |
| eventstudyinteract | Sun & Abraham | `ssc install eventstudyinteract` |
| csdid | Callaway-Sant'Anna | `ssc install csdid` |

### Python Packages

| Package | Purpose | Install |
|---------|---------|---------|
| statsmodels | OLS / WLS / GLM / logit | `pip install statsmodels` |
| linearmodels | IV2SLS / panel models | `pip install linearmodels` |
| plotnine | ggplot2-style plotting | `pip install plotnine` |
| rpy2 | Call R from Python | `pip install rpy2` |

---

## When to Switch Languages

| Situation | Recommendation |
|-----------|---------------|
| Already in a Python ML pipeline | Stay in Python, use rpy2 for gaps |
| Need Bacon decomposition | Switch to R or Stata |
| Synthetic control analysis | Use R (Synth) or Stata (synth) |
| Publication-ready regression tables | Stata (esttab) or R (modelsummary) |
| Exploratory / quick prototyping | Python statsmodels |
| Teaching / reproducibility | R (tidyverse ecosystem) |
| Referee asks for specific robustness | Match the language to the available package |
