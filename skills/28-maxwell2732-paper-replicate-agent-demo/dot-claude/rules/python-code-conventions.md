---
paths:
  - "replications/**/*.py"
  - "scripts/**/*.py"
---

# Python Scientific Coding Conventions

**Scope:** All Python scripts in `replications/` and `scripts/`.

---

## Paths

- Always use `pathlib.Path` — never string concatenation for paths
- Always use paths relative to the script file or project root:

```python
from pathlib import Path

# Relative to script
DATA_DIR = Path(__file__).parents[3] / "data"

# Or relative to project root (if script is run from root)
DATA_DIR = Path("data")
```

- Never hardcode absolute paths (e.g., `/Users/zhuch/...`) — this breaks on other machines

---

## Reproducibility

At the top of every script that has stochastic elements:

```python
import random
import numpy as np

random.seed(YYYYMMDD)      # Use today's date as integer, e.g., 20260220
np.random.seed(YYYYMMDD)
```

If using other RNG-dependent libraries, seed them explicitly:
```python
import torch
torch.manual_seed(YYYYMMDD)
```

---

## Imports

All imports at the top of the file. Never inside functions. Order:
1. Standard library (`os`, `random`, `pathlib`)
2. Third-party (`numpy`, `pandas`, `statsmodels`, `lifelines`)
3. Local modules

```python
# Standard library
from pathlib import Path
import random

# Third party
import numpy as np
import pandas as pd
import statsmodels.formula.api as smf
from lifelines import CoxPHFitter

# Local
from scripts.utils import load_ukb_extract
```

---

## Pandas

- Always specify `dtype` on `pd.read_csv()` for columns that will be used as keys or binary indicators:

```python
df = pd.read_csv(DATA_DIR / "ukb.csv", dtype={"eid": str, "event": int})
```

- Never use `inplace=True` — it causes silent failures and unclear code:

```python
# Bad
df.dropna(inplace=True)

# Good
df = df.dropna()
```

- Use `.copy()` when slicing a DataFrame you will modify:

```python
subset = df[df["age"] >= 40].copy()
```

---

## Modeling

Use established scientific Python libraries, not ad-hoc implementations:

| Task | Library |
|------|---------|
| Survival analysis (Cox PH) | `lifelines.CoxPHFitter` or `statsmodels.duration` |
| OLS / logistic / Poisson | `statsmodels.formula.api` |
| Fixed effects panel | `linearmodels.PanelOLS` or `pyhdfe` |
| Bayesian models | `pymc` |
| GWAS / PRS | `pandas-plink`, `bed-reader` |

Save all model results as structured files, not just printed output:

```python
# Good
results_df.to_parquet(RESULTS_DIR / "cox_table2.parquet")

import pickle
with open(RESULTS_DIR / "model_fit.pkl", "wb") as f:
    pickle.dump(fit, f)
```

---

## Figures

```python
import matplotlib.pyplot as plt
import matplotlib as mpl

# Okabe-Ito colorblind-safe palette
OKABE_ITO = ["#E69F00", "#56B4E9", "#009E73", "#F0E442",
             "#0072B2", "#D55E00", "#CC79A7", "#000000"]

fig, ax = plt.subplots(figsize=(8, 6))
# ... plotting code ...

fig.savefig(FIGURES_DIR / "figure1.png", dpi=300, bbox_inches="tight",
            facecolor="white")
plt.close(fig)
```

- 300 DPI minimum
- White or transparent background (`facecolor="white"` or `"none"`)
- `bbox_inches="tight"` to avoid clipping
- Always close figure after saving to free memory
- Never use `plt.show()` in scripts (breaks headless execution)

---

## Comments

Comment WHY, not WHAT. The code shows what; comments explain non-obvious decisions.

```python
# Bad
# Drop rows where age is missing
df = df.dropna(subset=["age"])

# Good
# Paper excludes participants with missing age at baseline (Methods, p. 4)
# This affects ~0.3% of the sample (N=1,502 → N=1,497)
df = df.dropna(subset=["age"])
```

Always comment Stata→Python translation decisions:

```python
# TRANSLATION NOTE: Stata 'stset' computes time-at-risk from study entry.
# Here we compute it manually as (exit_date - entry_date).dt.days / 365.25
# to match the paper's person-years denominator.
df["follow_up_years"] = (df["exit_date"] - df["entry_date"]).dt.days / 365.25
```

---

## Script Structure Template

```python
#!/usr/bin/env python3
"""
Replication: [Paper Author (Year)]
Date: YYYY-MM-DD
Original code: Stata / R
Python version: 3.X.Y
Key packages: see requirements.txt

Replicates: [Table X, Figure Y]
"""

# ── Imports ────────────────────────────────────────────────────────────────
from pathlib import Path
import random
import numpy as np
import pandas as pd

# ── Reproducibility ────────────────────────────────────────────────────────
random.seed(20260220)
np.random.seed(20260220)

# ── Paths ──────────────────────────────────────────────────────────────────
PROJECT_ROOT = Path(__file__).parents[3]
DATA_DIR = PROJECT_ROOT / "data"
RESULTS_DIR = Path(__file__).parent / "results"
FIGURES_DIR = Path(__file__).parent / "figures"
RESULTS_DIR.mkdir(exist_ok=True)
FIGURES_DIR.mkdir(exist_ok=True)

# ── 1. Load Data ───────────────────────────────────────────────────────────

# ── 2. Sample Construction ─────────────────────────────────────────────────

# ── 3. Model Fitting ───────────────────────────────────────────────────────

# ── 4. Save Results ────────────────────────────────────────────────────────
```
