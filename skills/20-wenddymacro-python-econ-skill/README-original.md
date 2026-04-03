# python-econ-skill
Awesome AI for DSGE and Causal Inference etc.

# Python Economic Numerical Computing
- Author：Wenli Xu
- Email： wlxu@cityu.edu.mo
- 2026-03-11
---


## Overview

Best practices for macroeconomic modeling (DSGE/HANK), causal inference, and data analysis in Python. Core principle: **vectorize first, accelerate loops with Numba, keep code structure aligned with economic theory**.

---

## Library Quick Reference

| Use Case | Preferred Libraries |
|----------|-------------------|
| Numerical core | `numpy`, `scipy` |
| Loop acceleration | `numba` (`@njit`, `@njit(parallel=True)`) |
| Economics toolkit | `quantecon` |
| HANK / sequence space | `sequence_jacobian` (SSJ) |
| Heterogeneous agents | `HARK` |
| **Linear models with FE** | **`pyfixest`** (`pip install pyfixest`) |
| **DID / DD / DDD** | **`diff-diff`** (`pip install diff-diff`) |
| **IV / 2SLS / GMM** | **`linearmodels`** (or `pyfixest` for panel IV with FE) |
| **RD / RDD / RKD** | **`rdrobust`**, `rddensity`, `rdlocrand` |
| **Synthetic Control** | **`pysynth`**, `synth_control`, `sdid` |
| **Matching** | **`causalml`**, `pymatch`, `econml` |
| **Causal ML / DML** | **`econml`**, `dowhy` |
| Data manipulation | `pandas`, `polars` (large datasets) |
| Visualization | `matplotlib`, `seaborn` |
