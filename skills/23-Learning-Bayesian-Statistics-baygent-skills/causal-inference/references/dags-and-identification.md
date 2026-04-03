# DAGs and Causal Identification

## Contents

1. [Drawing causal graphs](#drawing-causal-graphs)
2. [DAG specification in code](#dag-specification-in-code)
3. [Common causal structures](#common-causal-structures)
4. [Identification strategies](#identification-strategies)
5. [Finding adjustment sets](#finding-adjustment-sets)
6. [Collider bias warning](#collider-bias-warning)
7. [Asking the user: prompt templates](#asking-the-user-prompt-templates)

---

## Drawing causal graphs

A Directed Acyclic Graph (DAG) represents causal structure with nodes (variables) and directed edges (direct causal effects). Arrows point from cause to effect.

**The most important rule:** missing edges are the STRONGEST assumptions. Omitting an edge asserts that one variable has no direct causal effect on another — a strong claim that must be justified by domain knowledge, not by convenience or by the data.

Every edge and every non-edge requires a justification. Before touching data, you should be able to answer for each pair of variables: "Why do I believe X does (or does not) directly cause Y?"

The DAG encodes domain knowledge, not statistical patterns. It cannot be learned from data alone. Two datasets with identical joint distributions can correspond to different causal DAGs. Fitting models to data and then reading off a DAG is not causal inference — it is pattern matching.

---

## DAG specification in code

```python
import networkx as nx
from dowhy import CausalModel

dag = nx.DiGraph()
dag.add_edges_from([
    ("treatment", "outcome"),
    ("confounder", "treatment"),
    ("confounder", "outcome"),
])

model = CausalModel(
    data=df,
    treatment="treatment",
    outcome="outcome",
    graph=dag,
)
```

**Warning:** DoWhy requires explicit `U` nodes for unobserved confounders. If you omit them, DoWhy assumes there is no unobserved confounding — a very strong assumption that is almost never defensible in observational data. Always add unobserved nodes explicitly:

```python
dag.add_edges_from([
    ("U_unobserved", "treatment"),
    ("U_unobserved", "outcome"),
])
```

---

## Common causal structures

### 1. Confounder

```
C → T
C → Y
T → Y
```

C affects both treatment and outcome. Without adjusting for C, the T→Y estimate is biased. **Adjust for C** using regression, matching, IPW, or any valid backdoor adjustment method.

Example: age confounds the relationship between exercise (T) and cardiovascular health (Y) — older people exercise less and have worse health independently.

### 2. Mediator

```
T → M → Y
T → Y  (possibly)
```

M lies on a causal path from T to Y. **Do NOT adjust for M** if you want the total effect of T on Y. Adjusting for a mediator blocks the indirect path and gives you only the direct effect — which may not be what you want.

Example: a job training program (T) improves income (Y) partly through improved employment (M). Conditioning on employment removes the mechanism you care about.

### 3. Collider

```
T → C ← Y
```

C is caused by both T and Y. **NEVER adjust for C.** Conditioning on a collider opens a non-causal path between T and Y, inducing spurious association even when T and Y are independent. See [Collider bias warning](#collider-bias-warning).

### 4. Instrument

```
Z → T → Y
Z ⊥ Y | T  (Z affects Y only through T)
```

Z is a valid instrument when it (1) affects T (relevance), (2) is independent of all confounders of T→Y (exogeneity), and (3) affects Y only via T (exclusion restriction). Use IV estimation — see `references/quasi-experiments.md`.

---

## Identification strategies

### Backdoor criterion

A set of variables S satisfies the backdoor criterion if:
1. No variable in S is a descendant of T.
2. S blocks every path between T and Y that has an arrow into T (backdoor paths).

When S satisfies the backdoor criterion, adjusting for S identifies the causal effect of T on Y. This is the most common identification strategy in observational studies.

### Frontdoor criterion

When all paths from T to Y go through a mediator M, and M has no unobserved confounders with Y, the frontdoor criterion applies. Rare in practice, but it allows identification even when T and Y have unobserved common causes. The estimator chains two regressions: T→M and M→Y, adjusting for T in the second.

### Instrumental variables

When a valid instrument Z exists (relevance + exogeneity + exclusion), use two-stage least squares (2SLS) or a Bayesian IV model. IV gives a Local Average Treatment Effect (LATE) — the effect for compliers only, not the full population. Be explicit about this restriction when reporting results.

See `references/quasi-experiments.md` for implementation details.

### Design-based identification

Randomized assignment, regression discontinuity (RDD), difference-in-differences (DiD), and interrupted time series (ITS) provide identification through study design rather than adjustment. These require their own assumptions (parallel trends for DiD, continuity for RDD) which must be stated and tested where possible.

See `references/quasi-experiments.md`.

---

## Finding adjustment sets

```python
identified_estimand = model.identify_effect(
    proceed_when_unidentifiable=False,  # NEVER set to True silently
)
print(identified_estimand)
```

DoWhy will enumerate valid adjustment sets given your DAG. Review the output carefully — it tells you which variables to include and which identification strategy it found.

**Warning:** `proceed_when_unidentifiable=True` instructs DoWhy to continue even when causal identification fails. Never use this option without explicitly warning the user that the resulting estimate is not causally identified and should be interpreted as an association, not an effect. Using it silently is a form of scientific misconduct.

When DoWhy reports the effect is not identifiable, the correct response is to revise the DAG with the user (add instruments, rethink confounders, consider a design-based approach) — not to override the check.

---

## Collider bias warning

Adjusting for a collider **opens** a non-causal path between treatment and outcome, creating spurious associations that do not exist in the population. This is one of the most common and most damaging mistakes in causal inference.

Classic example: you study the effect of a disease (T) on recovery (Y). You condition on hospitalization (H) because your data comes from a hospital. But both disease severity (a confounder) and recovery both affect who gets hospitalized — making H a collider. Conditioning on H induces a spurious negative association between disease and recovery even if none exists.

```
Severity → H ← Recovery
T (disease) → H
T → Y (recovery)
```

This mistake is especially easy to make when:
- You filter your sample on a post-treatment variable.
- You include a variable "to control for sample selection."
- You condition on any variable that is a common effect of T and Y (or their causes).

Always trace paths in your DAG before adding any variable to an adjustment set.

---

## Asking the user: prompt templates

Before proceeding with any causal analysis, confirm the DAG and its assumptions with the user. Use these templates verbatim or adapt them.

### DAG confirmation prompt

> "Here is the causal graph I'm proposing:
>
> Nodes: [list all variables]
> Edges (direct causal effects): [list all arrows, e.g., 'age → treatment', 'treatment → outcome']
> Non-edges (explicit no-direct-effect assumptions): [list key omitted edges, e.g., 'income does NOT directly affect outcome, only through treatment']
>
> I'm assuming [X] does NOT directly cause [Y] — is that correct? Please confirm or correct each assumption before I proceed. Changing even one edge can change which variables to adjust for and whether the effect is identified at all."

### Assumption confirmation prompt

> "This analysis rests on the following untestable assumptions:
>
> 1. [Assumption 1, e.g., 'No unobserved confounders of the treatment–outcome relationship other than those listed.']
> 2. [Assumption 2, e.g., 'The instrument Z affects Y only through T (exclusion restriction).']
> 3. [Assumption 3, e.g., 'The DAG is acyclic — no feedback loops exist between any variables.']
>
> Are you comfortable defending these in a peer review or stakeholder context? If any feel fragile, I will flag them prominently in the report and, where possible, run a sensitivity analysis to quantify how much hidden confounding would be needed to overturn the conclusion."
