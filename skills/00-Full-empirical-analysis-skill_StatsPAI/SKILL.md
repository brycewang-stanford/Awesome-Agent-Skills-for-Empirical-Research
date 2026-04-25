---
name: StatsPAI_skill
description: Use when the user asks to run a full empirical / causal analysis in Python in the style of an applied economics paper (AER / QJE / JPE / ReStud / AEJ), pick between DID / RD / IV / SCM / DML / matching, write down an estimating equation and identifying assumption, produce Table 1 / Table 2 / event-study figure / robustness gauntlet, or generate a paper-ready replication package. Also triggers on keywords "StatsPAI", "statspai", "AER empirical analysis", "applied micro pipeline", "Table 1 balance", "event study", "first-stage F", "Oster bound", "honest_did", "spec_curve", "callaway_santanna", "dragonnet", "text as treatment".
triggers:
  - causal inference in python
  - applied microeconomics pipeline
  - AER empirical analysis
  - QJE style robustness
  - DID IV RD SCM
  - callaway_santanna
  - synthetic control
  - double machine learning
  - causal forest
  - event study plot
  - first stage F-statistic
  - Oster bound
  - honest_did
  - spec_curve
  - estimand-first DSL
  - LLM-assisted DAG discovery
  - text as treatment
  - StatsPAI
  - statspai
---

# StatsPAI: Agent-Native Causal Inference & AER-Style Empirical Workflow

StatsPAI is the agent-native Python package for causal inference and applied econometrics: one `import statspai as sp`, 900+ functions behind a self-describing API, and `CausalResult` objects that export to LaTeX / Word / Excel / BibTeX.

This skill drives StatsPAI through the **canonical pipeline of an applied AER empirical paper**. Each step maps to a section of the published paper and emits a paper-ready artifact (Table 1, event-study figure, Table 2 main results, robustness panel, replication stamp).

- **Source**: https://github.com/brycewang-stanford/StatsPAI
- **Install**: `pip install statspai` (>= 1.6)
- **Paper**: submitted to JOSS (under review)

## Why for Agents

1. **Self-describing**: `sp.list_functions()` / `sp.describe_function(name)` / `sp.function_schema(name)` — every public symbol is discoverable without doc lookup.
2. **Unified result**: every estimator returns `CausalResult` with `.summary()`, `.plot()`, `.diagnostics`, `.to_latex()`, `.to_word()`, `.cite()`.
3. **One import, full pipeline**: data contract → Table 1 → estimand-first DSL → identification graphs → main table → heterogeneity → mechanisms → robustness → replication package.
4. **Estimand-first**: `sp.causal_question(...).identify()` forces the "DID vs RD vs IV?" decision *before* estimation, with the identifying assumption written down — the way a referee expects to read it.

## The AER-style empirical pipeline

The skill mirrors the canonical sections of an applied AER / QJE / AEJ paper. Each step below is one paper section and one set of artifacts on disk.

```
Paper section               Step  StatsPAI moves
─────────────────────────── ───── ────────────────────────────────────────────────
Pre-Analysis Plan           −1    sp.power.* + freeze IdentificationPlan to disk
§1. Data                     0    data_contract + sample-construction log (footnote 4)
§1.1 Descriptives (Table 1)  1    sp.sumstats · sp.balance_table · sp.describe
§2. Empirical Strategy       2    write equation + identifying assumption + sp.causal_question
   (LLM-DAG addendum)        2.5  sp.llm_dag_propose · validate · constrained
§3. Identification graphics  3    event-study · first-stage F · McCrary · love plot
§4. Main Results (Table 2)   4    progressive controls + FE  (sp.regtable / sp.causal)
§5. Heterogeneity (Table 3)  5    sp.subgroup_analysis · sp.continuous_did · CATE
§6. Mechanisms               6    sp.mediation · sp.decompose
§7. Robustness gauntlet      7    placebo · Oster · honest_did · E-value · 2-way / Conley SE · spec_curve
§8. Replication package      8    .to_latex() · .plot() · reproducibility stamp
```

> **All code blocks below share one running example (`training → wage`, with `worker_id / firm_id / year / age / edu / tenure`) purely for readability.** Column names, `population`, `estimand`, and `design` values are **illustrative** — substitute the user's actual columns and research question. Only `sp.*` function names and argument *shapes* are normative.

## Paper-ready figure & table inventory (what to produce by section)

A modern AER paper has **5–7 figures** and **3–5 main tables** + an appendix robustness table. Every step below should leave at least one numbered artifact on disk. Default file names (use these so the agent can reference them later):

| § | Artifact | StatsPAI primitive | Filename |
|---|---|---|---|
| §1 | **Figure 1**: raw trends / treatment rollout | `sp.parallel_trends_plot` · `sp.treatment_rollout_plot` | `figures/fig1_trends.png` |
| §1 | **Table 1**: summary stats (full / treated / control + Δ) | `sp.sumstats(by=)` · `sp.balance_table` | `tables/table1_summary.tex` |
| §3 | **Figure 2**: identification graphic (event-study / first-stage / McCrary / RD scatter / SCM trajectory) | `sp.enhanced_event_study_plot` · `sp.binscatter` · `sp.rdplot` · `sp.rddensity().plot()` · `sp.synthdid_plot` | `figures/fig2_identification.png` |
| §4 | **Table 2**: main results — progressive controls | `sp.regtable(M1, M2, M3, M4, ...)` | `tables/table2_main.tex` |
| §4 | **Table 2-bis**: design horse-race (OLS / IV / DID / DML) | `sp.regtable(ols, iv, did, dml, ...)` | `tables/table2b_designs.tex` |
| §4 | **Figure 3** (optional): coefficient plot across specs | `sp.coefplot(M1, M2, M3, M4)` | `figures/fig3_coef.png` |
| §5 | **Table 3**: heterogeneity by subgroup | `sp.regtable(g_full, g_male, g_fem, g_q1...q4)` | `tables/table3_heterogeneity.tex` |
| §5 | **Figure 4**: dose-response / CATE | `sp.dose_response(...).plot()` · `sp.cate_plot` · `sp.cate_group_plot` | `figures/fig4_cate.png` |
| §6 | **Table 4**: mechanisms (mediation / decomposition) | `sp.regtable(total, direct, indirect)` | `tables/table4_mechanisms.tex` |
| §7 | **Table A1**: robustness master (one row per check) | `sp.regtable(rob1...robN, panel_labels=[...])` | `tables/tableA1_robustness.tex` |
| §7 | **Figure 5**: spec curve | `sp.spec_curve(...).plot()` | `figures/fig5_spec_curve.png` |
| §7 | **Figure 6**: sensitivity dashboard / Cinelli–Hazlett contour | `sp.sensitivity_dashboard` · `sp.sensitivity_plot` | `figures/fig6_sensitivity.png` |

> Every `CausalResult` and OLS model can be passed straight into `sp.regtable(...)` and `sp.coefplot(...)`. Don't hand-roll LaTeX.

---

## Step −1 — Pre-Analysis Plan (pre-data; AEA RCT Registry style)

`sp.power(design, n=..., effect_size=..., power_target=...)` is a unified dispatcher — leave one argument `None` to solve for it (sample size, MDE, or power). Convenience wrappers: `sp.power_rct`, `sp.power_did`, `sp.power_rd`, `sp.power_iv`, `sp.power_cluster_rct`, `sp.power_ols`.

```python
sp.power("rct", effect_size=0.3, power_target=0.80)                # → PowerResult(n=349, power=0.80)
sp.power("did", n=200, effect_size=0.15, power_target=0.80)        # DID: solves MDE / n / power
sp.power_cluster_rct(n_clusters=30, cluster_size=50,
                     icc=0.05, effect_size=0.2, power_target=0.80) # Cluster RCT
sp.pretrends_power(result)                                          # Roth (2022) pre-trends power
```

Persist the `PowerResult` next to `data_contract.json` and `empirical_strategy.md` — a referee will ask whether the design was powered before data collection, not after.

## Step 0 — Sample construction & data contract (Section "Data")

An AER §1 *Data* section has three jobs: (a) describe sources, (b) document **every** sample restriction (the "footnote 4" sample log), (c) lock the panel structure. StatsPAI assumes an **analysis-ready DataFrame** — do ETL (imputation, type coercion, merges, transforms) in pandas first, then run the 5-check contract.

### 0.1 Sample-construction log (footnote 4)

```python
sample_log = []
df0 = df_raw.copy();                                       sample_log.append(("0. raw",                len(df0)))
df1 = df0.dropna(subset=["wage"]);                          sample_log.append(("1. drop missing wage",  len(df1)))
df2 = df1[df1["age"].between(18, 65)];                      sample_log.append(("2. drop age outside 18-65", len(df2)))
df3 = df2[df2["industry"].isin(MANUF_CODES)];               sample_log.append(("3. keep manufacturing", len(df3)))
df  = df3
import json; json.dump(sample_log, open("artifacts/sample_construction.json", "w"), indent=2)
```

Paste this log verbatim as footnote 4 of your paper. AER reviewers use it to reconstruct the analysis sample.

### 0.2 Five-check data contract (go / no-go gate)

```python
import pandas as pd, numpy as np, statspai as sp

def data_contract(df, *, y, treatment, id=None, time=None, covariates=()):
    """Return a go/no-go dict. Stop the pipeline if any required check fails."""
    keys = [y, treatment] + ([id, time] if id and time else []) + list(covariates)
    c = {
        "n_obs":       len(df),                                           # 1. shape
        "dtypes":      df[keys].dtypes.astype(str).to_dict(),             # 2. dtypes on keys
        "n_missing":   df[keys].isna().sum().to_dict(),                   # 3. missing pattern
        "n_dupes_on_keys": 0,
        "panel_balanced":  None,
        "cohort_sizes":    None,
    }

    if id and time:
        c["n_dupes_on_keys"] = int(df.duplicated([id, time]).sum())       # 4. duplicate (id,time)
        balanced = sp.balance_panel(df, entity=id, time=time)              # 5. panel balance
        c["panel_balanced"]        = len(balanced) == len(df)
        c["n_dropped_by_balance"]  = len(df) - len(balanced)

        if "first_treat_year" in df.columns:                               # staggered cohorts
            c["cohort_sizes"] = (
                df.drop_duplicates(id).groupby("first_treat_year").size().to_dict()
            )

    c["y_range"]          = (float(df[y].min()), float(df[y].max()))
    c["treatment_share"]  = float(df[treatment].mean())

    # Missingness mechanism hint (Rubin): compare covariate means between
    # rows missing-on-y vs observed. Any p < 0.05 ⇒ NOT MCAR → use MI / IPW,
    # not listwise deletion.
    from scipy import stats
    miss_y = df[y].isna()
    c["mcar_hint"] = "likely MCAR (listwise OK)"
    if miss_y.any() and (~miss_y).any():
        for cov in covariates:
            if df[cov].dtype.kind in "fi":
                _, p = stats.ttest_ind(df.loc[miss_y, cov].dropna(),
                                        df.loc[~miss_y, cov].dropna(),
                                        equal_var=False)
                if p < 0.05:
                    c["mcar_hint"] = f"NOT MCAR (y-miss differs on {cov}, p={p:.3f}) → use MI / IPW"
                    break
    return c

contract = data_contract(df, y="wage", treatment="training",
                         id="worker_id", time="year",
                         covariates=["age", "edu", "tenure"])

assert contract["n_dupes_on_keys"] == 0, "duplicate (id, time) — fix before panel methods"
assert all(v == 0 for v in contract["n_missing"].values()), \
       f"NaNs on keys: {contract['n_missing']}"
```

If any assertion fires, **stop** and fix it in pandas — StatsPAI estimators silently drop NaN rows, the most common source of "mysterious sample-size shrinkage" bugs. Persist:

```python
import json; json.dump(contract, open("artifacts/data_contract.json", "w"), indent=2, default=str)
```

## Step 1 — Descriptive statistics (Table 1)

The signature AER Table 1 has three column blocks plus a difference column:

| | (1) Full | (2) Treated | (3) Control | (4) Δ (t-test) |

The Imbens–Rubin rule of thumb: a normalized difference `|Δ| / √((s²₁+s²₀)/2) > 0.25` flags substantive imbalance and should trigger matching / reweighting *before* you trust an OLS comparison.

```python
sp.sumstats(df, vars=["wage","edu","exp","tenure","age"],
            by="training", output="tables/table1_summary.tex")     # AER-format Table 1
sp.balance_table(df, treat="training",
                 covariates=["age","edu","tenure","firm_size"],
                 test="ttest")                                     # mean diff + p-value
sp.describe(df).to_markdown("references/codebook.md")              # auto-codebook
```

### 1.1 Multi-panel Table 1 (AER convention)
Group rows into **Panel A: Outcomes**, **Panel B: Treatment intensity**, **Panel C: Controls**, **Panel D: Sample composition**. `sp.sumstats` accepts `groups=` for panel-style layout, and the result can be merged into one tex file:

```python
panels = {
    "A. Outcomes":            ["wage", "log_wage", "weeks_employed"],
    "B. Treatment":           ["training", "training_hours"],
    "C. Demographic controls": ["age", "edu", "female", "married"],
    "D. Labor market":         ["tenure", "firm_size", "industry_id"],
}
sp.sumstats(df, groups=panels, by="training",
            stats=["mean", "sd", "n"],
            output="tables/table1_summary.tex")
```

### 1.2 Figure 1 — raw trends / treatment rollout
For DID / event-study designs, the *first* figure of an applied paper is almost always either (a) raw treated-vs-control means over time, or (b) the staggered rollout heat-strip showing which units are treated when. Both are one-liners:

```python
# (a) Raw trends with vertical line at treatment start (DID Figure 1 style)
sp.parallel_trends_plot(df, y="wage", time="year", treat="training",
                        treat_time=2015, ci=True,
                        labels={"treated":"Trained", "control":"Untrained"})\
  .savefig("figures/fig1a_raw_trends.png", dpi=300)

# (b) Treatment rollout heatmap (staggered DID convention; Goodman-Bacon-friendly)
sp.treatment_rollout_plot(df, time="year", treat="training", id="worker_id",
                          sort_by="first_treat_year",
                          title="Figure 1. Treatment timing")\
  .savefig("figures/fig1b_rollout.png", dpi=300)
```

For matching designs, also produce a **love plot** of standardized differences pre/post matching (Step 3.4).

## Step 2 — Empirical strategy (Section "Identification")

This is the heart of an AER paper. Before any code, **write down the equation explicitly** and **state the identifying assumption**. Vague identification language is the single most common reason a referee rejects an applied paper.

### 2.1 Equation × identifying assumption table

| Design | Estimating equation | Identifying assumption |
|---|---|---|
| 2×2 DID | `Y_it = α_i + λ_t + β·D_it + X'γ + ε_it` | parallel trends conditional on X |
| Event-study (CS / SA) | `Y_it = α_i + λ_t + Σ_{e≠-1} β_e · 1{t-G_i = e} + ε_it` | no anticipation + group-time PT |
| 2SLS | `Y_i = α + β·D_i + X'γ + ε_i;  D_i = π·Z_i + X'δ + u_i` | exclusion + relevance + monotonicity |
| Sharp RD | `Y_i = α + β·1{X_i ≥ c} + f(X_i) + ε_i` (local poly) | continuity of E[Y(0)\|X] at c, no manipulation |
| SCM | `Ŷ_1t(0) = Σ_j ŵ_j Y_jt`, τ_t = `Y_1t − Ŷ_1t(0)` for t≥T_0 | pre-period fit + interpolation validity |
| DML / unconfoundedness | `Y_i = m(X_i) + β·D_i + ε_i` (Robinson partialling-out) | unconfoundedness \| X + overlap |

### 2.2 Design picker

When `design="auto"` is too opaque, use this decision tree:

```
                 ┌─ running var + cutoff ───────────────── RDD   (sp.rdrobust)
                 │
                 ├─ exogenous instrument Z ─────────────── IV    (sp.ivreg, sp.dml)
data + question ─┤
                 ├─ pre/post × treat/control ─┬ 2 periods  ── 2×2 DID (sp.did)
                 │                            └ staggered  ── CS / SA  (sp.callaway_santanna)
                 │
                 ├─ 1 treated unit + donor pool + long pre ── SCM   (sp.synth, sp.sdid)
                 │
                 ├─ high-dim X, selection-on-observables ── DML / Causal Forest
                 │
                 └─ none of the above ──────────────────── matching + E-value (sp.match, sp.evalue)
```

### 2.3 Estimand-first DSL = pre-registration

`sp.causal_question` declares the five-tuple (population, treatment, outcome, estimand, design) and `.identify()` picks the estimator with its assumptions written down. **Treat the `IdentificationPlan` as your pre-registration artifact** — freeze it *before* running `q.estimate()` so the analysis plan is a dated document, not a post-hoc rationalization.

```python
q = sp.causal_question(
    treatment="training", outcome="wage", data=df,
    population="manufacturing workers, 2010–2020",
    estimand="ATT",
    design="auto",                 # 'auto' | 'did' | 'event_study' | 'regression_discontinuity'
                                   # | 'iv' | 'rct' | 'selection_on_observables'
                                   # | 'synthetic_control' | 'natural_experiment'
                                   # | 'policy_shock' | 'longitudinal_observational'
    time_structure="panel", time="year", id="worker_id",
    covariates=["age", "edu", "tenure"],
)
plan = q.identify()                # IdentificationPlan: estimator + assumptions + fallbacks
print(plan.summary())              # human-readable Methods paragraph
print(plan.identification_story)   # narrative of why this estimator identifies the estimand

# FREEZE the plan to disk BEFORE estimating — this is your pre-registration:
from pathlib import Path
bullets = lambda xs: "\n".join(f"- {x}" for x in xs)
Path("artifacts/empirical_strategy.md").write_text(
    f"# Empirical Strategy (pre-registration)\n\n"
    f"**Population**: {plan.population}\n"
    f"**Estimand**: {plan.estimand}\n"
    f"**Estimator**: {plan.estimator}\n\n"
    f"## Estimating equation\n```\n{plan.equation}\n```\n\n"
    f"## Identification story\n{plan.identification_story}\n\n"
    f"## Identifying assumptions\n{bullets(plan.assumptions)}\n\n"
    f"## Threats to identification\n{bullets(plan.threats)}\n\n"
    f"## Fallback estimators\n{bullets(plan.fallback_estimators)}\n"
)

result = q.estimate()              # run only after the plan is committed to disk / git
```

### 2.5 (Optional) LLM-assisted DAG addendum

Useful when the user wants an explicit DAG to defend in §2 or §7. Pipe the discovered DAG into `sp.causal(..., dag=...)`.

```python
proposal   = sp.llm_dag_propose(
    variables=df.columns.tolist(),
    domain="labor economics: training, wages, tenure",
    client=my_llm_client,                          # .complete(prompt) -> str; None = heuristic
)
validation = sp.llm_dag_validate(proposal, df, alpha=0.05)
print(validation.edge_evidence)

discovered = sp.llm_dag_constrained(
    df,
    descriptions={"wage": "monthly wage USD", "training": "0/1 program"},
    oracle=my_llm_client.suggest_edges,            # optional; falls back to plain PC
    max_iter=3,
)
# Pass into Step 4 as:  sp.causal(..., dag=discovered.dag)
```

## Step 3 — Identification graphics (Section "Identification, graphical evidence")

AER convention: **the identification figure precedes the regression table**. The reader should see graphical evidence that PT holds / first stage is strong / RD jumps cleanly *before* you ask them to trust your point estimate.

### 3.1 Event-study plot + numerical pre-trends test (DID identification)
Pre-period coefficients ≈ 0 (with the −1 reference period normalized to zero) is the visual evidence for parallel trends. Pair the **figure** with a **numerical** pre-trends test so reviewers don't have to eyeball it.

```python
# Event-study estimates
es = sp.event_study(df, y="wage", treat_time="first_treat_year",
                    time="year", unit="worker_id",
                    window=(-4, 4), ref_period=-1,
                    covariates=["age", "edu"])

# Figure 2a — event-study coefficient plot
sp.enhanced_event_study_plot(
    es, shade_pre=True,
    title="Figure 2a. Event-study coefficients (95% CI; ref. period = −1)")\
  .savefig("figures/fig2a_event_study.png", dpi=300)

# Numerical pre-trends test (joint F + Roth 2022 power) for the table footnote
print(sp.pretrends_summary(es))                       # F-stat, p-value, max-PT bound
sp.bjs_pretrend_joint(es)                             # Borusyak-Jaravel-Spiess joint test

# Bacon decomposition figure for staggered DID (Figure 2a-bis)
bd = sp.bacon_decomposition(df, y="wage", treat="training",
                            time="year", id="worker_id")
sp.bacon_plot(bd, title="Figure 2a-bis. Goodman-Bacon weights")\
  .savefig("figures/fig2a2_bacon.png", dpi=300)

# CS / SA dynamic effects figure (Figure 2a-ter): the post-period τ_e curve
cs = sp.callaway_santanna(df, y="wage", g="first_treat_year", t="year", i="worker_id")
sp.did_summary_plot(cs, title="Figure 2a-ter. Dynamic ATT (Callaway–Sant'Anna)")\
  .savefig("figures/fig2a3_csdid.png", dpi=300)
```

### 3.2 First-stage F-statistic + scatter (IV identification)
Rule of thumb: first-stage F ≥ 10 for OLS-style inference; F ≥ 23 for AR-equivalent inference (Stock–Yogo / Lee 2022).

```python
iv = sp.ivreg("wage ~ (training ~ Z1 + Z2) + age + edu", df, cluster="firm_id")
print(iv.summary())                                    # reports first-stage F (Cragg–Donald / KP)
sp.binscatter(df, y="training", x="Z1",
              controls=["age", "edu"],
              n_bins=20, ci=True)\
  .savefig("figures/fig_first_stage.png", dpi=300)
```

### 3.3 RD: McCrary density + canonical RD plot + binscatter
The signature RD figure is `sp.rdplot` (CCT-style binned scatter with local-polynomial fit on each side), paired with the McCrary manipulation test. Together they answer: (a) is there a visual jump? (b) is the density continuous at the cutoff?

```python
# Figure 2b — canonical RD plot (binned means + local poly fit on each side)
sp.rdplot(df, y="y", x="running_var", c=0,
          p=4, kernel="triangular", binselect="esmv",
          shade_ci=True, ci_level=0.95)\
  .savefig("figures/fig2b_rdplot.png", dpi=300)

# Figure 2b-bis — McCrary density (manipulation test)
sp.rddensity(df, x="running_var", c=0).plot()\
  .savefig("figures/fig2b2_mccrary.png", dpi=300)

# Optional: covariate-adjusted binscatter (continuity in covariates is also testable)
sp.binscatter(df, y="age", x="running_var", n_bins=40, ci=True)\
  .savefig("figures/fig2b3_cov_binscatter.png", dpi=300)
```

### 3.4 Matching: love plot (standardized differences)
```python
m = sp.match(df, y="wage", treat="training",
             covariates=["age", "edu", "tenure"], method="nearest")
m.plot()\
 .savefig("figures/fig2c_love_plot.png", dpi=300)      # |std diff| pre vs post; target |Δ|<0.1
```

### 3.5 SCM: synthetic-control trajectory + gap plot
For synthetic-control designs the canonical Figure 2 is the treated-vs-synthetic time-series with treatment time annotated. `synthdid_plot` does this in one line.

```python
sc = sp.synth(df, outcome="y", unit="unit", time="time",
              treated_unit=1, treatment_time=2000)
sc.plot().savefig("figures/fig2d_synth_trajectory.png", dpi=300)   # treated vs synthetic + gap
sd = sp.sdid(df, outcome="y", unit="unit", time="time",
             treated_unit=1, treatment_time=2000)
sp.synthdid_plot(sd, title="Figure 2d. Synthetic DID")\
  .savefig("figures/fig2d2_sdid.png", dpi=300)
```

### 3.6 Generic pre-flight (identification-independent)
```python
sp.diagnose(df, y="wage", x=["age", "edu", "tenure"])  # leverage, overlap, missing
```

> Identification-specific checks (PT for DID, weak-IV F, density for RD, common support for matching) **are also auto-run inside `sp.causal(...)`** in Step 4 — don't duplicate the numerics here, but DO produce the figures: a referee scans the figures first.

## Step 4 — Main results (multi-regression tables, AER style)

This is the densest section of an applied paper. A modern AER §4 typically contains **2–3 multi-regression tables and one coefficient plot**:

- **Table 2** (main): progressive controls, 4–6 columns
- **Table 2-bis** (design horse race): same coefficient under OLS / 2SLS / DID / DML
- **Table 2-ter** (multi-outcome): same treatment, several outcomes side-by-side
- **Figure 3** (coefplot): visual summary of β̂ and 95% CI across specs

`sp.regtable(*models, ...)` is the workhorse. Useful kwargs:

```
keep              : list of coef names to display (e.g. ["training"])
drop              : list of coef names to suppress (controls)
model_labels      : column labels   ["(1) Baseline", "(2) +Demog", ...]
dep_var_labels    : dep-var-row labels (for multi-outcome tables)
panel_labels      : panel-A / panel-B layout for stacked tables
coef_labels       : pretty-print names for coefficients
stars             : "aer" → * 0.10 ** 0.05 *** 0.01  (or "default", "none")
stats             : footer rows ["N","R2","Cluster","FE","DV mean", ...]
output            : "latex" | "html" | "markdown" | "text"
filename          : path to write the table
```

### 4.1 Pattern A — Progressive controls (the canonical Table 2)
Stable β̂ across columns ⇒ less concern that selection on observables is driving the estimate (Oster 2019 selection-stability logic; quantified in Step 7.5).

| | (1) Baseline | (2) +Demographics | (3) +Labor-market | (4) +Region×Industry FE | (5) +Worker FE |
|---|---|---|---|---|---|
| Controls | none | age, edu | + tenure, firm_size | high-dim FE | individual FE |

```python
M1 = sp.regress("wage ~ training",                                     df, cluster="firm_id")
M2 = sp.regress("wage ~ training + age + edu",                         df, cluster="firm_id")
M3 = sp.regress("wage ~ training + age + edu + tenure + firm_size",    df, cluster="firm_id")
M4 = sp.regress("wage ~ training + age + edu + tenure + firm_size | "
                "region + industry + year",                            df, cluster="firm_id")
M5 = sp.regress("wage ~ training + age + edu + tenure + firm_size | "
                "worker_id + year",                                    df, cluster="firm_id")

sp.regtable(M1, M2, M3, M4, M5,
            keep=["training"],
            coef_labels={"training": "Job training"},
            model_labels=["(1) Baseline", "(2) +Demog.", "(3) +Labor-mkt",
                          "(4) Region×Ind. FE", "(5) Worker FE"],
            stars="aer",                          # * p<0.10  ** p<0.05  *** p<0.01
            stats=["N", "R2", "Cluster", "FE", "DV mean"],
            output="latex", filename="tables/table2_main.tex")
```

### 4.2 Pattern B — Design horse race (Table 2-bis)
Show the same coefficient of interest under multiple identification strategies. This is *the* AER credibility move: convergent evidence across designs each making different identifying assumptions.

```python
ols  = sp.regress("wage ~ training + age + edu + tenure | industry + year",
                   df, cluster="firm_id")                                                 # OLS / FE
ivr  = sp.ivreg("wage ~ (training ~ Z1 + Z2) + age + edu + tenure",
                 df, cluster="firm_id")                                                    # 2SLS
did  = sp.callaway_santanna(df, y="wage", g="first_treat_year",
                             t="year", i="worker_id",
                             covariates=["age","edu","tenure"])                            # CS-DID
dml  = sp.dml(df, y="wage", treat="training",
               covariates=["age","edu","tenure","firm_size"], model="plr")                 # DML
mtch = sp.match(df, y="wage", treat="training",
                 covariates=["age","edu","tenure"], method="nearest")                      # PSM

sp.regtable(ols, ivr, did, dml, mtch,
            keep=["training"],
            coef_labels={"training": "Job training (β̂)"},
            model_labels=["(1) OLS+FE", "(2) 2SLS", "(3) CS-DID",
                          "(4) DML-PLR", "(5) PSM"],
            stats=["Estimator", "Identifying assumption",
                   "N", "R2 / Pseudo-R2", "Cluster"],
            stars="aer",
            output="latex", filename="tables/table2b_design_race.tex")
```

### 4.3 Pattern C — Multi-outcome table (same X, several Y's)
A single treatment, several outcomes. Use `dep_var_labels` so each column carries the Y name.

```python
ys = ["wage", "log_wage", "weeks_employed", "left_firm", "promoted"]
multi_y = [sp.regress(f"{y} ~ training + age + edu + tenure | industry + year",
                       df, cluster="firm_id")
           for y in ys]

sp.regtable(*multi_y,
            keep=["training"],
            dep_var_labels=ys,                    # column header: dep var
            model_labels=["(1)","(2)","(3)","(4)","(5)"],
            stars="aer",
            stats=["N","R2","DV mean","Cluster"],
            output="latex", filename="tables/table2c_multi_outcome.tex")
```

### 4.4 Pattern D — Stacked Panel A / Panel B table
Same model family, two horizons (short-run / long-run) or two samples (pre-2015 / post-2015) stacked vertically. Use `panel_labels`.

```python
panelA = [sp.regress("wage_t1 ~ training + X | industry+year", df, cluster="firm_id"),
          sp.regress("wage_t1 ~ training + X | worker_id+year", df, cluster="firm_id")]
panelB = [sp.regress("wage_t5 ~ training + X | industry+year", df, cluster="firm_id"),
          sp.regress("wage_t5 ~ training + X | worker_id+year", df, cluster="firm_id")]

sp.regtable(*panelA, *panelB,
            panel_labels=["Panel A. Short-run (1 year)",
                          "Panel A. Short-run (1 year)",
                          "Panel B. Long-run (5 years)",
                          "Panel B. Long-run (5 years)"],
            keep=["training"],
            model_labels=["(1) Industry FE","(2) Worker FE"]*2,
            stars="aer", stats=["N","R2"],
            output="latex", filename="tables/table2d_horizons.tex")
```

### 4.5 Pattern E — IV reporting triplet (first-stage / reduced-form / 2SLS)
The textbook AER IV table presents the **first stage**, the **reduced form**, and the **2SLS** in three columns so the reader can verify Wald-ratio = RF / FS.

```python
fs = sp.regress("training ~ Z + age + edu | industry+year", df, cluster="firm_id")  # 1st stage
rf = sp.regress("wage     ~ Z + age + edu | industry+year", df, cluster="firm_id")  # reduced form
iv = sp.ivreg  ("wage ~ (training ~ Z) + age + edu | industry+year",
                df, cluster="firm_id")                                              # 2SLS

sp.regtable(fs, rf, iv,
            keep=["Z", "training"],
            dep_var_labels=["training", "wage", "wage"],
            model_labels=["(1) First stage", "(2) Reduced form", "(3) 2SLS"],
            stats=["First-stage F", "N", "R2", "Cluster"],
            stars="aer",
            output="latex", filename="tables/table2e_iv_triplet.tex")
```

### 4.6 Pattern F — Causal-design main via `sp.causal(...)`
For DID / IV / RD / SCM mains, the `sp.causal(...)` orchestrator returns a `CausalResult` plus diagnostics and an automatic robustness preview. Pipe `.result` into `regtable`:

```python
w = sp.causal(df, y="wage", treatment="training",
              id="worker_id", time="year", design="did",
              covariates=["age", "edu", "tenure"],
              dag=discovered.dag)                  # optional
print(w.diagnostics)                               # PT verdict + warnings
print(w.recommendation)                            # which estimator + why
print(w.result.summary())                          # point estimate + cluster-robust SE + CI
print(w.robustness_findings)                       # automated robustness battery preview
```

### 4.7 Figure 3 — coefficient plot of the main table
Replace one of the wall-of-numbers tables with a coefplot in the body, push the table to the appendix. Modern AER papers increasingly do this.

```python
sp.coefplot(M1, M2, M3, M4, M5,
            model_names=["(1)","(2)","(3)","(4)","(5)"],
            variables=["training"],
            title="Figure 3. β̂ on training across specifications (95% CI)",
            alpha=0.05)\
  .savefig("figures/fig3_coefplot.png", dpi=300)
```

### Reporting checklist for the Table 2 footnote (AER house style)
- Standard-error cluster level (and whether it's two-way / Conley)
- Fixed-effects absorbed
- Sample size **and number of clusters**
- Estimator (OLS / 2SLS / CS-DID / SCM / DML)
- Stars convention `* 0.10  ** 0.05  *** 0.01`
- Mean of dependent variable in the estimation sample (so β̂ can be read as a % of the base rate)

## Step 5 — Heterogeneity (Table 3 + Figure 4)

The AER §5 *Heterogeneity* combines (a) a **subgroup regression table** with one column per subgroup (binary moderators + interaction terms), and (b) a **CATE / dose-response figure** for continuous moderators. Both should appear; they answer different questions.

### 5.1 Pattern G — Subgroup `regtable` (Table 3)
One column per subgroup, with the same specification re-run on each slice. Clean, easy to read, expected by referees.

```python
slices = {
    "(1) All":        df,
    "(2) Female":     df[df["female"] == 1],
    "(3) Male":       df[df["female"] == 0],
    "(4) Low skill":  df[df["skill_quartile"].isin([1, 2])],
    "(5) High skill": df[df["skill_quartile"].isin([3, 4])],
    "(6) Small firm": df[df["firm_size"] < 100],
    "(7) Large firm": df[df["firm_size"] >= 100],
}
gmodels = [sp.regress("wage ~ training + age + edu + tenure | industry+year",
                       d, cluster="firm_id") for d in slices.values()]

sp.regtable(*gmodels,
            keep=["training"],
            coef_labels={"training": "Training"},
            model_labels=list(slices),
            stars="aer",
            stats=["N","R2","DV mean"],
            output="latex", filename="tables/table3_heterogeneity.tex")
```

### 5.2 Interaction-form heterogeneity (alternative Table 3)
Test moderation formally with interaction terms — referees often ask whether the gap between subgroups is statistically significant, which requires the interaction p-value.

```python
H1 = sp.regress("wage ~ training*female + age + edu + tenure | industry+year",
                df, cluster="firm_id")
H2 = sp.regress("wage ~ training*C(skill_quartile) + age + edu + tenure | industry+year",
                df, cluster="firm_id")
H3 = sp.regress("wage ~ training*log_firm_size + age + edu + tenure | industry+year",
                df, cluster="firm_id")

sp.regtable(H1, H2, H3,
            keep=["training", "training:female",
                  "training:C(skill_quartile)[T.2]",
                  "training:C(skill_quartile)[T.3]",
                  "training:C(skill_quartile)[T.4]",
                  "training:log_firm_size"],
            model_labels=["(1) ×Female", "(2) ×Skill quartile", "(3) ×log(Firm size)"],
            stars="aer", stats=["N","R2"],
            output="latex", filename="tables/table3b_interactions.tex")
```

### 5.3 Figure 4 — dose-response (continuous treatment)
```python
dr = sp.dose_response(df, y="wage", treat="training_hours",
                      covariates=["age","edu","tenure","firm_size"],
                      n_dose_points=20)
dr.plot(title="Figure 4a. Dose-response: training hours → wage")\
  .savefig("figures/fig4a_dose_response.png", dpi=300)

# DID-flavored continuous treatment (de Chaisemartin–D'Haultfœuille):
sp.continuous_did(df, y="wage", dose="training_hours",
                  time="year", id="worker_id").plot()\
  .savefig("figures/fig4a2_continuous_did.png", dpi=300)
```

### 5.4 Figure 4-bis — CATE distribution (causal forest / DR-Learner)
```python
cf = sp.causal_forest(formula="wage ~ training | age + edu + tenure + firm_size", data=df)

sp.cate_plot(cf, kind="hist",
             title="Figure 4b. Distribution of conditional ATE")\
  .savefig("figures/fig4b_cate_hist.png", dpi=300)

# CATE by group bar chart (heterogeneity by a discrete moderator)
sp.cate_group_plot(cf, group="skill_quartile",
                   title="Figure 4c. CATE by skill quartile")\
  .savefig("figures/fig4c_cate_by_group.png", dpi=300)

# Tabular summary for the appendix
print(sp.cate_summary(cf))
print(sp.cate_by_group(cf, group="skill_quartile"))
```

### 5.5 Subgroup-analysis dispatcher (one-liner)
```python
sp.subgroup_analysis(df, formula="wage ~ training + age + edu + tenure",
                     x="training",
                     by={"gender": "female", "skill": "skill_quartile"},
                     cluster="firm_id")            # quick subgroup β̂ table
```

For continuous moderators or many subgroups, prefer:
- `sp.continuous_did(...)` — dose-response under DID
- `sp.causal_forest(formula="wage ~ training | X", data=df)` + `sp.cate_plot` — CATE
- `sp.metalearner(..., learner="dr")` — DR-Learner CATE

## Step 6 — Mechanisms / channels

```python
sp.mediation(df, y="wage", d="training", m="hours_worked",
             X=["age", "edu", "tenure"])           # ACME / ADE / total effect
sp.decompose(...)                                   # Oaxaca-Blinder / RIF / FFL / KOB
```

## Step 7 — Robustness gauntlet (the AER referee gauntlet)

The seven canonical robustness blocks of an applied paper. A modern AER paper expects most of these in the body or appendix — assemble a Table A1-style robustness panel from the outputs.

### 7.1 Placebo tests
```python
sp.rdplacebo(df, y="y", x="running_var", c=0,
             placebo_cutoffs=[-2, -1, 1, 2])                      # RD: fake cutoffs
sp.synth_time_placebo(df, outcome="y", unit="unit", time="time",
                      treated_unit=1, treatment_time=2000,
                      n_placebo_times=10)                          # SCM in-time placebo
sp.synthdid_placebo(...)                                           # SDID placebo
# For DID: re-run with a fake treat year before actual treatment and confirm β̂ ≈ 0.
```

### 7.2 Alternative samples
```python
result_no_outliers = sp.causal(df.query("wage < wage.quantile(0.99)"), ...)
result_drop_early  = sp.causal(df.query("first_treat_year > 2008"),  ...)
result_balanced    = sp.causal(sp.balance_panel(df, entity="worker_id", time="year"), ...)
```

### 7.3 Alternative specifications (spec curve)
```python
sp.spec_curve(df, y="wage", x="training",
              controls=[["age"], ["age", "edu"], ["age", "edu", "tenure"]],
              subsets={"all": None, "manuf": df["industry"].eq("manufacturing")})
```

### 7.4 Alternative standard errors
Cluster-level choice is itself a robustness check — show the result is not driven by an over-narrow cluster.

```python
sp.twoway_cluster(M3, df, cluster1="firm_id", cluster2="year")     # two-way clustering
sp.conley(M3, df, lat="lat", lon="lon",
          dist_cutoff=100, kernel="uniform")                        # spatial HAC (Conley 1999)
```

### 7.5 Oster (2019) selection bound
"How big would unobserved selection have to be for β to flip sign / vanish?" The Oster δ tells you whether the bound on selection on unobservables, relative to selection on observables, has to exceed an implausible value to overturn the result.

```python
sp.oster_bounds(data=df, y="wage", treat="training",
                controls=["age", "edu", "tenure"],
                r_max=1.3)                          # β* assuming δ=1, R̃²=1.3·R²
sp.oster_delta(data=df, y="wage", treat="training",
               controls=["age", "edu", "tenure"],
               r_max=1.3)                           # δ for which β=0
```

### 7.6 Honest DID — Rambachan–Roth (2023) PT sensitivity
```python
sp.honest_did(result, method="smoothness")          # bound β under bounded PT violation
```

### 7.7 E-value & unified sensitivity (unmeasured confounding)
```python
sp.evalue(estimate=result.params["training"],       # E-value takes point + CI, NOT result
          ci=tuple(result.conf_int().loc["training"]),
          measure="RR")
sp.unified_sensitivity(result, r2_treated=0.05,
                       r2_controlled=0.10,
                       include_oster=True)          # Cinelli-Hazlett + Oster combined
sp.sensitivity_dashboard(result)                    # one-page sensitivity figure
```

### 7.8 RD-specific bandwidth / kernel sensitivity
```python
sp.rdbwsensitivity(df, y="y", x="running_var", c=0,
                    bw_grid=[0.5, 1.0, 1.5, 2.0])   # is β̂ stable across bandwidths?
```

### 7.9 TWFE diagnostic (staggered DID)
Goodman-Bacon decomposition flags when the TWFE estimate is contaminated by forbidden 2×2's (already-treated as control).

```python
sp.bacon_decomposition(df, y="y", treat="training",
                       time="year", id="worker_id")
```

### 7.10 Sequential confounder blocks (Oster-style robustness table)
```python
blocks = {
    "M1 base":           [],
    "M2 +demographics":  ["age", "edu"],
    "M3 +labor-market":  ["age", "edu", "tenure", "firm_size"],
    "M4 +psychosocial":  ["age", "edu", "tenure", "firm_size", "motivation"],
}
models = [sp.regress(f"wage ~ training + {' + '.join(c) or '1'}",
                     df, cluster="firm_id")
          for c in blocks.values()]
sp.regtable(*models,
            model_labels=list(blocks),
            keep=["training"],
            output="latex",
            filename="tables/table_robust_blocks.tex")
```

### 7.11 Pattern H — Robustness master table (Table A1, one row per check)
The canonical AER appendix Table A1 stacks every robustness specification next to the baseline so reviewers see at a glance that β̂ survives. `sp.regtable` accepts any mix of `EconometricResults` / `CausalResult`, so build the list dynamically:

```python
baseline = sp.regress("wage ~ training + age + edu + tenure | industry+year",
                       df, cluster="firm_id")

rob = {
    "(1) Baseline":            baseline,
    "(2) Drop top 1% wage":    sp.regress("wage ~ training + age + edu + tenure | industry+year",
                                          df.query("wage < wage.quantile(0.99)"),
                                          cluster="firm_id"),
    "(3) Balanced panel":      sp.regress("wage ~ training + age + edu + tenure | industry+year",
                                          sp.balance_panel(df, entity="worker_id", time="year"),
                                          cluster="firm_id"),
    "(4) Drop early cohorts":  sp.regress("wage ~ training + age + edu + tenure | industry+year",
                                          df.query("first_treat_year > 2008"),
                                          cluster="firm_id"),
    "(5) Worker FE":           sp.regress("wage ~ training + age + edu + tenure | worker_id+year",
                                          df, cluster="firm_id"),
    "(6) 2-way cluster":       sp.twoway_cluster(baseline, df,
                                                  cluster1="firm_id", cluster2="year"),
    "(7) Conley spatial SE":   sp.conley(baseline, df,
                                          lat="lat", lon="lon", dist_cutoff=100),
    "(8) Log outcome":         sp.regress("log_wage ~ training + age + edu + tenure | industry+year",
                                          df, cluster="firm_id"),
    "(9) IHS outcome":         sp.regress("ihs_wage ~ training + age + edu + tenure | industry+year",
                                          df, cluster="firm_id"),
    "(10) PSM-weighted":       sp.match(df, y="wage", treat="training",
                                         covariates=["age","edu","tenure","firm_size"],
                                         method="nearest"),
    "(11) Entropy balance":    sp.ebalance(df, y="wage", treat="training",
                                            covariates=["age","edu","tenure","firm_size"]),
    "(12) DML-PLR":            sp.dml(df, y="wage", treat="training",
                                       covariates=["age","edu","tenure","firm_size"], model="plr"),
}

sp.regtable(*rob.values(),
            keep=["training"],
            coef_labels={"training": "Training (β̂)"},
            model_labels=list(rob),
            stars="aer",
            stats=["N", "R2", "Cluster", "FE"],
            output="latex", filename="tables/tableA1_robustness.tex")
```

### 7.12 Figure 5 — coefficient forest plot of all robustness specs
A single visual summary that an AER referee can parse in 5 seconds: every β̂ and 95% CI on one axis. Confirms the estimate is not knife-edge.

```python
sp.coefplot(*rob.values(),
            model_names=list(rob),
            variables=["training"],
            title="Figure 5. β̂ on training across robustness specifications",
            alpha=0.05)\
  .savefig("figures/fig5_robustness_forest.png", dpi=300)
```

### 7.13 Figure 5-bis — spec curve
The Simonsohn et al. (2020) specification curve plots β̂ across **every combination** of {controls × subsamples × outcome transforms × SE types}. Useful when you want to head off "what about specification X?" referee letters.

```python
sc = sp.spec_curve(df, y="wage", x="training",
                   controls=[["age"], ["age","edu"], ["age","edu","tenure"],
                             ["age","edu","tenure","firm_size"]],
                   se_types=["robust", "cluster_firm_id", "cluster_firm_id_year"],
                   y_transforms=["identity", "log", "ihs"],
                   subsets={"all": None,
                            "manuf":  df["industry"].eq("manufacturing"),
                            "no99":   df["wage"] < df["wage"].quantile(0.99)},
                   cluster_var="firm_id")
sc.plot(title="Figure 5-bis. Specification curve")\
  .savefig("figures/fig5b_spec_curve.png", dpi=300)
```

### 7.14 Figure 6 — sensitivity dashboard
One-page Cinelli–Hazlett + Oster + E-value summary for the §7 closing argument.

```python
sens = sp.unified_sensitivity(baseline,
                              r2_treated=0.05, r2_controlled=0.10,
                              include_oster=True)
sp.sensitivity_plot(sens.results,
                    original_estimate=baseline.params["training"],
                    original_ci=tuple(baseline.conf_int().loc["training"]),
                    title="Figure 6. Sensitivity to unobserved confounding")\
  .savefig("figures/fig6_sensitivity.png", dpi=300)

sp.sensitivity_dashboard(baseline)\
  .savefig("figures/fig6b_sensitivity_dashboard.png", dpi=300)
```

### 7.15 One-stop robustness reporter
```python
sp.diagnose_result(result)                          # PT / weak-IV / overlap / leverage verdict
sp.robustness_report(df, formula="wage ~ training + age + edu",
                     x="training", cluster_var="firm_id")
sp.estat(result, test="all")                        # Stata-style postestimation battery
```

## Step 8 — Replication package

Every `CausalResult` exports paper-ready artifacts in three lines:

```python
result.to_latex("tables/main.tex")                         # booktabs LaTeX table
result.plot().savefig("figures/main.png", dpi=300)         # publication-quality figure
print(result.cite())                                       # BibTeX entry for the method

# Reproducibility stamp — pair with the Step-0 contract + Step-2 pre-reg
import json
json.dump({
    "statspai":          sp.__version__,
    "seed":              42,
    "n_obs":             result.data_info["n_obs"],
    "estimand":          result.estimand,
    "estimate":          float(result.params["training"]),
    "ci95":              list(result.conf_int().loc["training"]),
    "pre_registration":  "artifacts/empirical_strategy.md",
    "data_contract":     "artifacts/data_contract.json",
    "sample_log":        "artifacts/sample_construction.json",
}, open("artifacts/result.json", "w"), indent=2)
```

For full-draft generation (abstract + methods + results + bibliography), see `sp.paper(result, ...)` — out of scope for this skill; call it only when the user explicitly asks for a paper draft.

---

## Regtable cookbook (one-page recipe index)

`sp.regtable(*models, ...)` is the single primitive behind every multi-regression table in an AER paper. The eight patterns above map to:

| Pattern | What varies across columns | Step |
|---|---|---|
| **A. Progressive controls** | covariate set / FE depth | 4.1 — Table 2 |
| **B. Design horse race** | identification strategy (OLS / 2SLS / DID / DML / PSM) | 4.2 — Table 2-bis |
| **C. Multi-outcome** | dependent variable Y | 4.3 — Table 2-ter |
| **D. Stacked Panel A / B** | horizon / sample (panel rows × spec columns) | 4.4 — Table 2-quater |
| **E. IV reporting triplet** | first stage / reduced form / 2SLS | 4.5 — Table 2-quinto |
| **F. `sp.causal(...)` orchestrator** | 1 column, full diagnostics | 4.6 |
| **G. Subgroup table** | subsample (full / female / male / Q1…Q4) | 5.1 — Table 3 |
| **H. Robustness master** | every robustness check stacked | 7.11 — Table A1 |

Default `sp.regtable` settings for AER house style:
```python
sp.regtable(*models,
            keep=["training"],                    # show only the coefficient of interest
            coef_labels={"training": "Training"}, # pretty names
            model_labels=[...],                   # column labels
            stars="aer",                          # * 0.10 ** 0.05 *** 0.01
            stats=["N", "R2", "Cluster", "FE", "DV mean"],
            output="latex", filename="tables/...")
```

For pyfixest-style native output, `sp.etable(*models, ...)` is the alternative.

## Figure factory (the 12 standard AER figures)

| # | Figure | StatsPAI call | Section |
|---|---|---|---|
| 1a | Raw trends (DID Figure 1) | `sp.parallel_trends_plot(df, y, time, treat, treat_time, ci=True)` | §1 |
| 1b | Treatment rollout heatmap | `sp.treatment_rollout_plot(df, time, treat, id)` | §1 |
| 2a | Event-study coefficients | `sp.enhanced_event_study_plot(sp.event_study(...))` | §3 |
| 2a' | Bacon weights | `sp.bacon_plot(sp.bacon_decomposition(...))` | §3 |
| 2a'' | CS-DID dynamic effects | `sp.did_summary_plot(sp.callaway_santanna(...))` | §3 |
| 2b | RD canonical plot | `sp.rdplot(df, y, x, c)` | §3 |
| 2b' | McCrary density | `sp.rddensity(df, x, c).plot()` | §3 |
| 2c | Matching love plot | `sp.match(...).plot()` | §3 |
| 2d | SCM trajectory | `sp.synth(...).plot()` · `sp.synthdid_plot(sp.sdid(...))` | §3 |
| 3 | Coefficient plot of main specs | `sp.coefplot(M1...M5, variables=["x"])` | §4 |
| 4a | Dose-response | `sp.dose_response(...).plot()` | §5 |
| 4b | CATE histogram | `sp.cate_plot(forest, kind="hist")` | §5 |
| 4c | CATE by group bar | `sp.cate_group_plot(forest, group=...)` | §5 |
| 5 | Robustness forest plot | `sp.coefplot(*rob.values(), variables=["x"])` | §7 |
| 5b | Specification curve | `sp.spec_curve(...).plot()` | §7 |
| 6 | Sensitivity dashboard | `sp.sensitivity_dashboard(result)` · `sp.sensitivity_plot(...)` | §7 |
| 7 | Final result.plot() | `result.plot()` (estimator-specific) | §8 |

> Every plotting function above accepts `ax=` so panels can be combined with matplotlib subplots, and returns a Figure that supports `.savefig(path, dpi=300)` for publication output.

---

## Method Catalog

### Classical
```python
sp.regress("y ~ x1 + x2", df, cluster="firm_id")                       # OLS (formula-first)
sp.ivreg("y ~ (x1 ~ z1 + z2) + x2", df, cluster="state")               # IV/2SLS — (endog ~ instruments) + exog
sp.panel(df, "y ~ x1 + x2", entity="firm", time="year", method="fe")   # Panel FE
sp.heckman(df, y="wage", x=["age", "edu"],
           select="in_labor_force", z=["marital", "kids"])              # Heckman selection
sp.qreg(df, formula="y ~ x1 + x2", quantile=0.5)                        # Quantile regression
```

### Difference-in-Differences
```python
sp.did(df, y="y", treat="treated", time="post")                              # 2×2 DID (time = 2 values)
sp.callaway_santanna(df, y="y", g="first_treat_year", t="year", i="firm_id") # CS 2021
sp.sun_abraham(df, y="y", g="first_treat_year", t="year", i="firm_id")       # SA 2021 event study
sp.bacon_decomposition(df, y="y", treat="treated", time="year", id="firm_id")# TWFE diagnostic
sp.continuous_did(df, y="y", dose="dose", time="year", id="firm_id")         # Continuous treatment
sp.honest_did(result, method="smoothness")                                   # PT sensitivity (RR 2023)
sp.event_study(df, y="y", treat_time="first_treat_year",
               time="year", unit="firm_id", window=(-4, 4))                  # Event-study coefficients
```

### Regression Discontinuity
```python
sp.rdrobust(df, y="y", x="running_var", c=0)                      # Sharp RD (CCT 2014)
sp.rdrobust(df, y="y", x="running_var", c=0, fuzzy="treatment")   # Fuzzy RD
sp.rddensity(df, x="running_var", c=0)                            # McCrary density test
sp.rdmc(df, y="y", x="running_var", cutoffs=[0, 5, 10])           # Multi-cutoff RD
sp.rkd(df, y="y", x="running_var", c=0)                           # Regression kink
sp.rdplacebo(df, y="y", x="running_var", c=0,
             placebo_cutoffs=[-2, -1, 1, 2])                       # RD placebo
sp.rdbwsensitivity(df, y="y", x="running_var", c=0,
                    bw_grid=[0.5, 1.0, 1.5, 2.0])                  # Bandwidth sensitivity
```

### Matching & Reweighting
```python
sp.match(df, y="wage", treat="training", covariates=["age", "edu"], method="nearest")  # PSM (default)
sp.match(df, y="wage", treat="training", covariates=["age", "edu"], method="cem")      # Coarsened EM
sp.ebalance(df, y="wage", treat="training", covariates=["age", "edu"])                 # Entropy balancing
```

### Synthetic Control
```python
sp.synth(df, outcome="y", unit="unit", time="time",
         treated_unit=1, treatment_time=2000)              # ADH SCM (method='augmented' default)
sp.sdid(df, outcome="y", unit="unit", time="time",
        treated_unit=1, treatment_time=2000)               # Synthetic DID (Arkhangelsky et al. 2021)
sp.synth_time_placebo(df, outcome="y", unit="unit", time="time",
                      treated_unit=1, treatment_time=2000,
                      n_placebo_times=10)                  # SCM in-time placebo
```

### ML Causal
```python
sp.dml(df, y="wage", treat="training", covariates=["age", "edu"], model="plr")       # DML
sp.causal_forest(formula="wage ~ training | age + edu", data=df)                      # Causal Forest (formula API)
sp.metalearner(df, y="wage", treat="training", covariates=["age", "edu"], learner="dr")  # DR-Learner
sp.tmle(df, y="wage", treat="training", covariates=["age", "edu"])                   # Targeted MLE
sp.aipw(df, y="wage", treat="training", covariates=["age", "edu"])                   # Augmented IPW
```

### Neural Causal
```python
sp.tarnet(df,    y="wage", treat="training", covariates=["age", "edu"])
sp.cfrnet(df,    y="wage", treat="training", covariates=["age", "edu"])
sp.dragonnet(df, y="wage", treat="training", covariates=["age", "edu"])
```

### Text Causal (v1.6 P1, experimental)
```python
sp.causal_text.text_treatment_effect(
    df, text_col="doc", outcome="y", treatment="t",
    covariates=["age", "edu"], embedder="hash", n_components=20)      # Veitch–Wang–Blei 2020

sp.causal_text.llm_annotator_correct(
    annotations_llm=df["t_llm"],                                      # aligned pd.Series (all rows)
    annotations_human=df["t_true"],                                   # NaN where unlabelled
    outcome=df["y"], covariates=df[["age", "edu"]],
    method="hausman")                                                 # Egami et al. 2024
```

### Mechanisms / Decomposition
```python
sp.mediation(df, y="wage", d="training", m="hours_worked",
             X=["age", "edu"])                                      # ACME / ADE
sp.decompose(...)                                                    # Oaxaca-Blinder / RIF / FFL / KOB
```

### Robustness, Sensitivity & Inference
```python
sp.spec_curve(df, y="wage", x="training",
              controls=[["age"], ["age", "edu"], ["age", "edu", "tenure"]])
sp.robustness_report(df, formula="wage ~ training + age + edu",
                     x="training", cluster_var="firm_id")
sp.subgroup_analysis(df, formula="wage ~ training + age + edu",
                     x="training", by={"gender": "female", "age_bin": "age_quartile"})
sp.oster_bounds(df, y="wage", treat="training",
                controls=["age", "edu"], r_max=1.3)                  # Oster 2019
sp.unified_sensitivity(result, r2_treated=0.05, r2_controlled=0.10,
                       include_oster=True)                            # Cinelli-Hazlett + Oster
sp.sensitivity_dashboard(result)
sp.evalue(estimate=..., ci=(..., ...), measure="RR")
sp.twoway_cluster(result, df, cluster1="firm_id", cluster2="year")    # two-way SE
sp.conley(result, df, lat="lat", lon="lon", dist_cutoff=100)          # spatial HAC

fig = result.plot()
sp.interactive(fig)                                                   # WYSIWYG editor, 29 academic themes
```

---

## Common Mistakes

| Anti-pattern | Correct form |
|---|---|
| Reporting Table 2 without writing the estimating equation | Step 2 — write the equation + identifying assumption to `artifacts/empirical_strategy.md` *before* estimating |
| Skipping the event-study figure and going straight to the DID coefficient | Step 3.1 — `sp.event_study(...)` + `sp.enhanced_event_study_plot(...)` precedes the regression table |
| Reporting IV without first-stage F | Step 3.2 — `iv.summary()` reports first-stage F; bench-mark F ≥ 10 (≥ 23 for AR-equivalent inference) |
| Reporting RD without McCrary + binscatter | Step 3.3 — `sp.rddensity` + `sp.binscatter` |
| Single-spec main result with no robustness panel | Step 7 — placebo, Oster, honest_did, alt-SE, spec_curve are *expected*, not optional |
| Cluster at observation level when treatment is at firm/state level | Cluster at the level of treatment assignment; use `sp.twoway_cluster` if multi-dim |
| Raw panel → staggered DID without balance check | Run Step 0 `data_contract`; inspect `sp.balance_panel` output and cohort sizes |
| `spec_curve(controls=["a","b","c"])` (flat list) | `controls=[["a"], ["a","b"], ["a","b","c"]]` — each inner list = one spec |
| `sp.rdrobust(..., cutoff=0)` | Kwarg is `c=0` across `rdrobust` / `rkd` / `rdplacebo` / `rdbwsensitivity` |
| `sp.evalue(result)` | `sp.evalue(estimate=<point>, ci=(lo, hi), measure="RR")` |
| `sp.match(df, treat="t", y="y", ...)` | Signature is `(df, y, treat, covariates, ...)` — **y before treat** |
| `sp.sun_abraham(df, y, g, t)` — no unit id | Staggered DID **requires** `i=<unit_id>` |
| `sp.synth(..., treated_period=2000)` | Kwarg is `treatment_time=` (singular) |
| `sp.panel(df, formula, fe=True)` | Kwarg is `method="fe"` |
| `sp.robustness_report(result, ...)` | Takes `(data, formula, x, ...)` — not a result object |
| `sp.mediation(df, y, treat, mediator)` | Kwargs are `(df, y, d, m, X)` — `d` for treatment, `m` for mediator |
| Pre-computed embeddings to `text_treatment_effect` | Pass `text_col=<column_name>`; control vectorisation via `embedder=` |
| `llm_annotator_correct(df)` | Takes aligned `pd.Series` (not DataFrame); NaN for unlabelled rows |
| Trusting SEs without checking convergence / weak-IV / overlap | Always read `result.summary()` warnings and `result.diagnostics` |

---

## Agent Integration Pattern

```python
import statspai as sp

sp.list_functions()                                        # discover
info   = sp.describe_function("callaway_santanna")         # understand
schema = sp.function_schema("callaway_santanna")           # structured call spec

result = sp.callaway_santanna(df, y="y",
                               g="first_treat_year", t="year", i="firm_id")
print(result.summary())
result.to_latex("tables/did_results.tex")
```

---

## When to Use StatsPAI vs Alternatives

| Scenario | Use StatsPAI | Alternative |
|---|---|---|
| One-stop EDA → estimand → DAG → estimate → robustness pipeline | ✅ single import covers all eight AER sections | assemble pyfixest + econml + causalml + differences + ... |
| Agent-driven analysis with self-describing API | ✅ `list_functions` / `describe_function` / `function_schema` | statsmodels / pyfixest (no agent API) |
| Estimand-first "DID vs RD vs IV?" decision | ✅ `sp.causal_question` + `sp.causal` | manual judgement call |
| Stata → Python migration (same API names) | ✅ `sp.regress`, `sp.estat`, `sp.sumstats`, `sp.xtreg` | linearmodels (partial) |
| Full AER-style robustness gauntlet from one package | ✅ Oster / honest_did / E-value / Conley / 2-way / spec_curve / placebo all in `sp.*` | manually wire 5+ packages |
