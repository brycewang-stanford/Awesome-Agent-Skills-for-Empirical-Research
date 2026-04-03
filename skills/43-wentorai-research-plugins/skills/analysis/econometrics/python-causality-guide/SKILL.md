---
name: python-causality-guide
description: "Learn causal inference with Python using the Brave and True handbook"
metadata:
  openclaw:
    emoji: "📊"
    category: "analysis"
    subcategory: "econometrics"
    keywords: ["causal-inference", "python", "econometrics", "statistics", "treatment-effects", "observational-studies"]
    source: "https://github.com/matheusfacure/python-causality-handbook"
---

# Causal Inference for the Brave and True

## Overview

Causal Inference for the Brave and True is an open-source, Python-based textbook by Matheus Facure that teaches causal inference methods through practical implementations. The book bridges the gap between theoretical econometrics textbooks and hands-on data science practice, presenting each method with runnable Python code, real-world datasets, and intuitive explanations that demystify the mathematics behind causal reasoning.

The handbook covers the full spectrum of causal inference techniques used in modern empirical research, from foundational concepts like potential outcomes and directed acyclic graphs (DAGs) through advanced methods including instrumental variables, regression discontinuity, difference-in-differences, and synthetic control. Each chapter builds on the previous one, constructing a coherent framework for thinking about causation from observational data.

With over 3,000 GitHub stars, this resource has become a standard reference for graduate students, applied researchers, and data scientists seeking to add causal reasoning to their analytical toolkit. The emphasis on Python implementation makes it directly applicable to modern research workflows.

## Installation and Setup

The handbook runs as Jupyter notebooks. Set up the environment:

```bash
git clone https://github.com/matheusfacure/python-causality-handbook.git
cd python-causality-handbook

# Create a virtual environment
python -m venv causal-env
source causal-env/bin/activate

# Install dependencies
pip install numpy pandas matplotlib seaborn scikit-learn statsmodels
pip install linearmodels causalinference
pip install jupyter
```

Launch the notebook server:

```bash
jupyter notebook
```

The chapters are organized as numbered Jupyter notebooks, starting from foundational concepts and progressing to advanced methods. Each notebook is self-contained with all data loading and analysis code included.

## Core Methods Covered

**Potential Outcomes Framework**: The book begins by establishing the Neyman-Rubin potential outcomes model, defining treatment effects and the fundamental problem of causal inference:

```python
import pandas as pd
import numpy as np
from scipy.stats import ttest_ind

# Estimate ATE from randomized experiment
treated = data[data["treatment"] == 1]["outcome"]
control = data[data["treatment"] == 0]["outcome"]
ate = treated.mean() - control.mean()
t_stat, p_value = ttest_ind(treated, control)
print(f"ATE: {ate:.3f}, p-value: {p_value:.4f}")
```

**Regression and Matching**: OLS regression for causal estimation, understanding omitted variable bias, propensity score methods, and matching estimators:

```python
import statsmodels.formula.api as smf

# OLS with controls
model = smf.ols("outcome ~ treatment + age + income + education", data=data)
results = model.fit(cov_type="HC1")
print(results.summary().tables[1])
```

**Instrumental Variables**: Two-stage least squares and the local average treatment effect, with practical guidance on instrument validity and weak instrument diagnostics:

```python
from linearmodels.iv import IV2SLS

# Two-stage least squares
iv_formula = "outcome ~ 1 + [treatment ~ instrument]"
iv_model = IV2SLS.from_formula(iv_formula, data=data)
iv_results = iv_model.fit(cov_type="robust")
print(iv_results.summary)
```

**Difference-in-Differences**: Parallel trends assumption, two-way fixed effects, event study designs, and staggered treatment adoption:

```python
# Difference-in-Differences with two-way fixed effects
did_model = smf.ols(
    "outcome ~ treated_post + C(unit_id) + C(time_period)",
    data=panel_data
)
did_results = did_model.fit(cov_type="cluster", cov_kwds={"groups": panel_data["unit_id"]})
```

**Regression Discontinuity**: Sharp and fuzzy RD designs, bandwidth selection, and local polynomial estimation for identifying causal effects at policy thresholds.

**Synthetic Control**: Constructing counterfactual units from donor pools for comparative case studies, with inference via placebo tests.

## Research Workflow Integration

**Graduate Coursework**: The handbook maps directly to applied econometrics and causal inference course syllabi. Students can follow along with lectures by running the corresponding notebooks, experimenting with parameter changes, and observing how different assumptions affect estimates.

**Method Selection Guide**: Use the decision framework presented across chapters to choose the appropriate method for your research question:

- Randomized experiment available: simple comparison of means or regression adjustment
- Selection on observables: matching, propensity scores, or regression
- Unobserved confounders with instrument: instrumental variables
- Policy threshold: regression discontinuity
- Before/after with control group: difference-in-differences
- Single treated unit over time: synthetic control

**Replication and Extension**: Each chapter uses real or realistic datasets. Researchers can adapt the code to their own data by replacing data loading steps while preserving the analytical pipeline.

**Teaching Tool**: Instructors can assign chapters as interactive homework, asking students to modify assumptions, change specifications, or apply methods to new datasets. The notebook format makes it straightforward to create assignments with embedded solutions.

## Best Practices Highlighted in the Handbook

1. **Always graph your data first**: Visual inspection reveals patterns that inform modeling choices and expose violations of identifying assumptions.
2. **Understand your identification strategy**: Before running any estimator, articulate clearly what variation identifies the causal effect and what assumptions are required.
3. **Cluster standard errors appropriately**: When treatment is assigned at group level, cluster standard errors at that level to avoid overstating statistical significance.
4. **Run robustness checks**: Vary specifications, bandwidths, control variables, and functional forms to assess sensitivity of conclusions.
5. **Report effect sizes alongside p-values**: Statistical significance without practical significance is not informative for policy or scientific understanding.

## References

- Python Causality Handbook: https://github.com/matheusfacure/python-causality-handbook
- Online version: https://matheusfacure.github.io/python-causality-handbook/
- Angrist and Pischke, Mostly Harmless Econometrics (companion reference)
- Cunningham, Causal Inference: The Mixtape (complementary resource)
