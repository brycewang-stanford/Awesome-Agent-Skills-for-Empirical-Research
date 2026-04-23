---
name: statspai
description: Agent-native one-stop toolkit for the full empirical data-analysis pipeline in Python (v1.6+). 390+ functions, one import (`import statspai as sp`), unified API. Covers the complete loop after data cleaning — descriptive stats & EDA (sp.sumstats, sp.balance_table, sp.balance_panel), estimand-first research-question DSL (sp.causal_question), LLM-assisted DAG discovery (sp.llm_dag_propose/validate/constrained), one-call orchestration (sp.causal), classical estimators (OLS, IV, DID, staggered DID, RDD, PSM, SCM), ML causal (DML, Causal Forest, Meta-Learners, TMLE), neural causal, text causal (sp.causal_text), and diagnostics + robustness (sp.diagnose, sp.spec_curve, sp.honest_did). Use when the user asks to run a full empirical analysis, decide which estimator to use ("DID vs RD vs IV?"), explore models via DAG, estimate treatment effects, evaluate policy, run observational studies, or apply any of the listed econometric methods in Python. Every function returns structured result objects with self-describing schemas for LLM-driven workflows. Data cleaning (missing values, type coercion, merges) is *not* covered — handle that with pandas first, then enter StatsPAI.
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
  - estimand-first DSL
  - causal question to estimator
  - LLM-assisted DAG discovery
  - complete empirical pipeline
  - data analysis workflow
  - descriptive statistics and balance table
  - panel balance check
  - pre-flight diagnostics
  - text as treatment
  - StatsPAI
  - statspai
---

# StatsPAI: Agent-Native Causal Inference & Econometrics

StatsPAI is the agent-native Python package for causal inference and applied econometrics. One `import statspai as sp`, 390+ functions, covering the complete empirical research workflow.

**Source**: https://github.com/brycewang-stanford/StatsPAI
**PyPI**: `pip install statspai`
**Paper**: Published in Journal of Open Source Software (JOSS)

## Why StatsPAI for Agents?

StatsPAI is the **first econometrics toolkit purpose-built for LLM-driven empirical research**:

1. **Self-describing API**: `sp.list_functions()`, `sp.describe_function("did")`, `sp.function_schema("rdrobust")` — agents discover and understand functions without doc lookup.
2. **Unified result objects**: Every estimator returns a `CausalResult` with `.summary()`, `.plot()`, `.to_latex()`, `.to_word()`, `.to_excel()`, `.cite()`, and a structured `.diagnostics` dict for agent logic.
3. **One import covers the full pipeline**: descriptive stats → research-question DSL → DAG discovery → estimation → diagnostics → robustness, all behind `sp.<func>`.
4. **Estimand-first decisions**: `sp.causal_question` and `sp.causal` make the "DID vs RD vs IV?" choice explicit and defensible — not a guess.

## End-to-End Empirical Pipeline (v1.6 P1) — the one-stop flow

The canonical agent loop, after the dataset is loaded:

```
Step 0  Data cleaning           pandas (NOT StatsPAI — see Scope below)
Step 1  EDA & descriptives      sp.sumstats / sp.balance_table / sp.describe
Step 2  Pre-flight checks       sp.balance_panel / sp.diagnose / overlap & missing
Step 3  Research question       sp.causal_question(...).identify()
Step 4  Model exploration       sp.llm_dag_propose → sp.llm_dag_validate → sp.llm_dag_constrained
Step 5  Estimation              sp.causal(...)  OR  sp.<specific_estimator>(...)
Step 6  Diagnostics & robust    sp.diagnose / sp.spec_curve / sp.honest_did / sp.evalue
```

`sp.paper()` exists for end-to-end draft generation but is **out of scope for this skill** — stop at Step 6 and hand the `CausalResult` back to the user.

### Scope boundary — what StatsPAI does NOT do

StatsPAI assumes you arrive with an **analysis-ready DataFrame**. Do these in pandas (or your preferred ETL) *before* calling any `sp.*` function:

```python
import pandas as pd

df = pd.read_csv("raw.csv")
df = df.dropna(subset=["y", "treatment"])              # missing on key vars
df["year"] = pd.to_numeric(df["year"], errors="coerce") # type coercion
df = df.merge(covariates, on="firm_id", how="left")    # joins
df["log_wage"] = np.log(df["wage"].clip(lower=1))      # transforms
```

If the agent skips Step 0 and feeds dirty data into `sp.*`, estimators will either error or silently drop rows — both are bugs you own, not StatsPAI's.

### Step 1 — Descriptive statistics & EDA

```python
sp.sumstats(df, vars=["wage", "edu", "exp"], by="treated", output="table1.docx")
sp.describe(df)                                          # variable labels & types
sp.balance_table(df, treat="treated",
                 covariates=["age", "edu", "income"], test="ttest")  # Table 1
```

### Step 2 — Pre-flight checks (catch design failures before estimation)

```python
# Panel structure
balanced = sp.balance_panel(df, entity="firm_id", time="year")
assert len(balanced) == len(df), "Unbalanced panel — decide drop vs keep before DID"

# Treatment timing (staggered adoption?)
df.groupby("first_treat_year").size()                    # cohort sizes

# Covariate overlap (matching / DML / meta-learners)
sp.balanceplot(df, treat="treated", covariates=["age", "edu", "income"])

# Identification & data sanity battery
report = sp.diagnose(df, y="y", treatment="treated",
                     id="firm_id", time="year", design="did")
print(report.summary())                                  # surfaces missing, leakage, weak ID
```

### Step 3 — Estimand-first research question (the "DID vs RD vs IV?" decision)

`sp.causal_question` is the **estimand-first DSL**: declare population, treatment, outcome, estimand, design — then `.identify()` picks the estimator and writes down the assumptions you're committing to. This is the decision layer; `sp.spec_curve` is the *results-layer* multiverse and is not a substitute.

```python
q = sp.causal_question(
    treatment="training",
    outcome="wage",
    data=df,
    population="manufacturing workers, 2010–2020",
    estimand="ATT",
    design="auto",                # or "did" / "rdd" / "iv" / "rct" / "obs"
    time_structure="panel",
    time="year", id="worker_id",
    covariates=["age", "edu", "tenure"],
)

plan = q.identify()               # IdentificationPlan: estimator + assumptions + fallbacks
print(plan)                       # human-readable Methods paragraph
result = q.estimate()             # runs the picked estimator
print(result.summary())
```

### Step 4 — Model exploration via LLM-assisted DAG (closed loop)

```python
# Propose: LLM (or heuristic backend) drafts a DAG from variable names + domain
proposal = sp.llm_dag_propose(
    variables=df.columns.tolist(),
    domain="labor economics: training, wages, tenure",
    client=my_llm_client,         # any object with .complete(prompt) -> str; None = heuristic
)

# Validate: per-edge CI test against the data
validation = sp.llm_dag_validate(proposal, df, alpha=0.05)
print(validation.edge_evidence)   # which proposed edges the data supports

# Constrained discovery: propose → constrain → CI-validate → demote, until stable
discovered = sp.llm_dag_constrained(
    df,
    descriptions={"wage": "monthly wage USD", "training": "0/1 program"},
    oracle=my_llm_client.suggest_edges,   # optional; falls back to plain PC without it
    max_iter=3,
)
```

Pass the resulting DAG into `sp.causal(..., dag=discovered.dag)` so identification reasoning uses it.

### Step 5 — Estimation (one-call orchestration OR specific estimator)

**One-call (recommended for agents):**
```python
w = sp.causal(df, y="wage", treatment="training",
              id="worker_id", time="year", design="did",
              covariates=["age", "edu", "tenure"],
              dag=discovered.dag)        # optional
print(w.diagnostics)                     # identification verdict
print(w.recommendation)                  # which estimator + why
print(w.result.summary())                # point estimate + SE + CI
print(w.robustness_findings)             # automated robustness battery
```

**Or call a specific estimator directly** — see "Method Catalog" below.

### Step 6 — Diagnostics & robustness

```python
sp.diagnose_result(result)               # battery: PT, weak IV, overlap, leverage
sp.honest_did(result, method="smoothness")   # Rambachan–Roth PT sensitivity (DID)
sp.evalue(result)                        # unmeasured-confounder sensitivity (obs studies)
sp.spec_curve(df, "wage", "training",    # multiverse over controls / subsamples
              controls=["age", "edu", "tenure"],
              specs=spec_grid)
sp.bacon_decomposition(df, "wage", "training", "year")   # TWFE diagnostic for staggered DID
sp.estat(result, ["hettest", "vif", "linktest"])        # Stata-style postestimation
```

---

## Method Catalog

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

### Text Causal (v1.6 P1, experimental)
```python
sp.causal_text.text_treatment_effect(                      # Veitch–Wang–Blei (2020)
    df, treatment="t", outcome="y", text_embedding="emb")  # text-as-treatment via embedding adjustment
sp.causal_text.llm_annotator_correct(                      # Egami–Hinck–Stewart–Wei (2024)
    df, llm_label="t_llm", human_label="t_true",           # measurement-error correction for
    outcome="y", validation_idx=val_ix)                    # LLM-derived treatment labels
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

## When to Use StatsPAI vs Other Packages

| Scenario | Use StatsPAI | Alternative |
|----------|-------------|-------------|
| One-stop empirical pipeline (EDA → estimand → DAG → estimate → robustness) | ✅ Single import covers all six steps | Assemble 10+ R/Python packages |
| Agent-driven analysis with self-describing API | ✅ `list_functions` / `describe_function` / `function_schema` | pyfixest, statsmodels (no agent API) |
| "DID vs RD vs IV?" decision (estimand-first) | ✅ `sp.causal_question` + `sp.causal` recommender | None — usually a manual judgement call |
| LLM-assisted DAG discovery loop | ✅ `sp.llm_dag_propose / validate / constrained` | causal-learn (no LLM oracle integration) |
| Staggered DID with diagnostics | ✅ CS + SA + Bacon + HonestDID in one place | differences (partial) |
| Neural causal models | ✅ TARNet / CFRNet / DragonNet | econml (partial) |
| Stata users migrating to Python | ✅ Stata-equivalent names (`sp.regress`, `sp.estat`, `sp.sumstats`) | linearmodels (limited) |

## Validation and Error Handling

After running any estimation, check the result object before proceeding:

```python
result = sp.did(df, "y", "treated", "post")

# Always inspect the human-readable summary first
print(result.summary())

# Inspect structured diagnostics for agent-driven logic
if hasattr(result, "diagnostics"):
    print(result.diagnostics)
```

Common pitfalls to guard against:

- **Convergence warnings** — surfaced in `result.summary()` (check before trusting SEs).
- **Weak instruments** for IV — require first-stage F ≥ 10 (Stock–Yogo rule of thumb); StatsPAI exposes this in `result.diagnostics["First-stage F (<endog>)"]`.
- **Parallel trends** for DID — run an event study and verify pre-treatment coefficients are statistically indistinguishable from zero; follow up with `sp.honest_did(result)` for Rambachan–Roth sensitivity.
- **Bandwidth sensitivity** for RDD — re-run `sp.rdrobust` at half and double the MSE-optimal bandwidth; agreement within one SE is reassuring.
- **Missing data** — StatsPAI drops rows with missing values by default; check `result.data_info["n_obs"]` matches your expected sample size.
- **Overlap / common support** — for matching, DML, and meta-learners, inspect propensity-score distributions before interpreting CATEs.
