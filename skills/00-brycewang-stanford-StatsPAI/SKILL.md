---
name: statspai
description: "Agent-native causal inference and econometrics toolkit for Python. 390+ functions, one import, unified API. Covers OLS, IV, DID, staggered DID, RDD, PSM, SCM, DML, Causal Forest, Meta-Learners, TMLE, neural causal models, and more. Use when the user asks about treatment effect estimation, causal analysis, regression analysis, policy evaluation, observational study methods, or any of the listed econometric methods in Python. Every function returns structured result objects with self-describing schemas for LLM-driven workflows."
triggers:
  - implement causal inference
  - run a DID analysis
  - instrumental variables regression
  - regression discontinuity
  - propensity score matching
  - synthetic control
  - double machine learning
  - causal forest
  - panel data regression
  - econometric analysis
  - treatment effect estimation
  - causal analysis
  - policy evaluation
  - observational study
  - StatsPAI
  - statspai
---

# StatsPAI: Agent-Native Causal Inference & Econometrics

StatsPAI is the agent-native Python package for causal inference and applied econometrics. One `import statspai as sp`, 390+ functions, covering the complete empirical research workflow.

**Source**: https://github.com/brycewang-stanford/StatsPAI
**PyPI**: `pip install statspai`
**Paper**: Published in Journal of Open Source Software (JOSS)

## Agent API

StatsPAI provides a self-describing API for agent-driven workflows:

1. **Discovery**: `sp.list_functions()`, `sp.describe_function("did")`, `sp.function_schema("rdrobust")` — discover and understand functions without external documentation
2. **Unified results**: Every function returns a `CausalResult` with `.summary()`, `.plot()`, `.to_latex()`, `.to_word()`, `.to_excel()`, `.cite()`
3. **One import**: `import statspai as sp` covers all 390+ functions
4. **Publication-ready output**: Word, Excel, LaTeX, HTML export in every function

## Core Methods

### Classical Econometrics
```python
sp.regress(df, "y ~ x1 + x2", cluster="firm_id")        # OLS
sp.ivreg(df, "y ~ x1 | z1 + z2", cluster="state")        # IV/2SLS
sp.panel(df, "y ~ x1 + x2", entity="firm", time="year", model="fe")  # Panel FE
sp.heckman(df, "y ~ x1", "select ~ z1 + z2")              # Heckman selection
sp.qreg(df, "y ~ x1 + x2", quantile=0.5)                  # Quantile regression
```

### Difference-in-Differences
```python
sp.did(df, "y", "treated", "post")                         # Auto-dispatch (2x2 or staggered)
sp.callaway_santanna(df, "y", "group", "time")             # Staggered DID (CS 2021)
sp.sun_abraham(df, "y", "cohort", "time")                  # Interaction-weighted event study
sp.bacon_decomposition(df, "y", "treated", "time")         # TWFE diagnostic
sp.honest_did(result, method="smoothness")                 # Sensitivity to PT violations
sp.continuous_did(df, "y", "dose", "time")                 # Continuous treatment
```

### Regression Discontinuity
```python
sp.rdrobust(df, "y", "running_var", cutoff=0)              # Sharp RD (CCT 2014)
sp.rdrobust(df, "y", "running_var", fuzzy="treatment")     # Fuzzy RD
sp.rddensity(df, "running_var")                            # McCrary density test
sp.rdmc(df, "y", "running_var", cutoffs=[0, 5, 10])        # Multi-cutoff RD
sp.rkd(df, "y", "running_var", cutoff=0)                   # Regression kink design
```

### Matching & Reweighting
```python
sp.match(df, "treatment", covariates, method="psm")        # Propensity score matching
sp.match(df, "treatment", covariates, method="cem")        # Coarsened exact matching
sp.ebalance(df, "treatment", covariates)                   # Entropy balancing
```

### Synthetic Control
```python
sp.synth(df, "y", "unit", "time", treated_unit=1, treated_period=2000)  # ADH SCM
sp.sdid(df, "y", "unit", "time", treated_units, treated_periods)        # Synthetic DID
```

### Machine Learning Causal Inference
```python
sp.dml(df, "y", "treatment", controls, model="PLR")       # Double/Debiased ML
sp.causal_forest(df, "y", "treatment", controls)           # Causal Forest (GRF)
sp.metalearner(df, "y", "treatment", controls, learner="dr")  # DR-Learner
sp.tmle(df, "y", "treatment", controls)                    # Targeted MLE
sp.aipw(df, "y", "treatment", controls)                    # Augmented IPW
```

### Neural Causal Models
```python
sp.tarnet(df, "y", "treatment", controls)                  # TARNet
sp.cfrnet(df, "y", "treatment", controls)                  # CFRNet
sp.dragonnet(df, "y", "treatment", controls)               # DragonNet
```

### Robustness & Workflow
```python
sp.spec_curve(df, "y", "treatment", controls, specs)       # Specification curve
sp.robustness_report(result)                               # Automated robustness report
sp.subgroup_analysis(df, "y", "treatment", subgroups)      # Heterogeneity with Wald test
result.to_latex()                                          # Export to LaTeX
result.to_word("output.docx")                              # Export to Word
result.cite()                                              # Auto-generate citation
```

### Interactive Visualization (v0.6+)
```python
fig = result.plot()
sp.interactive(fig)  # Stata Graph Editor-style WYSIWYG editing, 29 academic themes
```

## Agent Integration Pattern

```python
import statspai as sp

# Step 1: Discover available functions
functions = sp.list_functions()

# Step 2: Understand a specific function
info = sp.describe_function("callaway_santanna")

# Step 3: Get JSON schema for structured calls
schema = sp.function_schema("callaway_santanna")

# Step 4: Execute and get structured results
result = sp.callaway_santanna(df, "y", "group", "time")
print(result.summary())
result.to_latex("tables/did_results.tex")
```

## Validation and Error Handling

After running any estimation, check the result before proceeding:

```python
result = sp.did(df, "y", "treated", "post")

# Check convergence and diagnostics
print(result.summary())

# Verify key assumptions
if hasattr(result, 'diagnostics'):
    print(result.diagnostics)
```

Common issues to check:
- **Convergence warnings** in `.summary()` output
- **Weak instruments** for IV: check first-stage F-statistic > 10
- **Parallel trends** for DID: run event study and inspect pre-treatment coefficients
- **Bandwidth sensitivity** for RDD: compare results at half and double the optimal bandwidth
- **Missing data**: StatsPAI drops missing values by default — verify sample sizes match expectations
