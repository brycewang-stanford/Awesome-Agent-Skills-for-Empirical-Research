---
name: identification-proofs
argument-hint: "<target parameter or identification result>"
description: >-
  This skill covers formal identification arguments and proofs in structural and reduced-form econometrics. Use when the user needs to prove or formalize that a parameter is identified — including writing identification propositions, stating regularity conditions, deriving rank conditions, or showing observational equivalence fails. Triggers on "identification proof", "identification argument", "identify the parameter", "show identification", "identification condition", "exclusion restriction proof", "rank condition", "order condition", "identification strategy formal", "nonparametric identification", "parametric identification", "local identification", "global identification", "observational equivalence", "identification at infinity", "completeness condition", "regularity conditions", "Rothenberg", "proof of identification", "identification result", "identified parameter", "point identified", "set identified", "partial identification".
---

# Identification Proofs

Reference for writing formal and informal identification arguments: from stating the target parameter precisely, through deriving the identification result, to connecting it to a feasible estimator.

**Detail files** (load on demand):
- `references/derivation-tools.md` — IFT approach, completeness, worked proofs for LATE/RDD/DiD/BLP
- `references/proof-template.md` — LaTeX and plain-language templates for identification propositions
- `references/regularity-and-partial-id.md` — Regularity conditions checklist and partial identification methods

## When to Use This Skill

Use when the user is:
- Writing a formal identification proposition for a paper or theory appendix
- Deriving whether a structural or causal parameter is point identified
- Stating and verifying regularity conditions for an identification result
- Working through rank or order conditions for GMM moment conditions
- Arguing identification for IV, DiD, RDD, or structural models
- Checking whether two models are observationally equivalent
- Characterizing an identified set under partial identification

Skip when:
- The task is implementing a causal estimator (use `causal-inference` skill)
- The task is structural model estimation code (use `structural-modeling` skill)
- The user needs only informal intuition, not a formal argument

---

## What Identification Means

**Core definition.** A parameter $\theta_0$ is *identified* if the map from the true parameter value to the distribution of observables is injective: $P_{\theta_1} = P_{\theta_2} \implies \theta_1 = \theta_2$.

**Key distinctions:**
- **Local vs global**: Local identification holds in a neighborhood of $\theta_0$ (Rothenberg 1971). Global identification requires uniqueness over the entire parameter space. Estimation needs global identification for a well-defined probability limit.
- **Point vs set**: Under point identification, data uniquely determine $\theta_0$. Under partial identification (Manski 1990), data are consistent with an identified set $\Theta^* \supseteq \{\theta_0\}$.
- **Observational equivalence**: Identification fails when two distinct parameter values generate the same observable distribution.

**Why identification precedes estimation.** A parameter can only be consistently estimated if it is identified. Code runs and produces output even when parameters are unidentified — checking identification before estimation prevents hard-to-diagnose failures.

---

## The 7-Step Canonical Structure

Every formal identification argument follows this architecture. Work through all seven steps before claiming identification.

### Step 1 — Target Parameter
State precisely *what* $\theta$ you want to identify — not "the causal effect" but the exact functional or structural parameter (e.g., coefficient $\beta$ under endogeneity, the ASF $g(x) = E[Y(x)]$, taste parameters in BLP). **Common mistake:** conflating the target with the estimand (LATE is not ATE; ATT from DiD is not ATE).

### Step 2 — Model Primitives
State observables $(Y, X, Z)$, latent variables ($\varepsilon$, unobserved heterogeneity), structural equations, error restrictions (independence, mean independence), functional form (parametric vs nonparametric), and equilibrium concept if applicable.

### Step 3 — Source of Variation
State what observable variation provides identification leverage: instrument variation (IV), policy changes across groups (DiD), proximity to a cutoff (RDD), cost shifters entering supply but not demand (structural). The source must be distinct from functional form assumptions.

### Step 4 — Key Assumptions
Enumerate identifying assumptions explicitly (label A1, A2, ...). Common categories: exclusion restrictions, rank/order conditions, support conditions, independence, monotonicity (LATE), continuity (RDD), parallel trends (DiD). Each must be statable in population terms and either testable or defended substantively.

### Step 5 — Identification Result
Derive identification via one of three strategies:
1. **Explicit formula**: $\theta_0 = h(P_{\theta_0})$ — strongest form, gives both identification and an estimator
2. **Implicit function theorem**: moment conditions $E[m(X;\theta)] = 0$ have $\theta_0$ as unique solution (Jacobian has full rank) — see `references/derivation-tools.md`
3. **Injectivity argument**: show $P_{\theta_1} = P_{\theta_2} \implies \theta_1 = \theta_2$ directly

### Step 6 — Regularity Conditions
State conditions under which the result holds: support, rank, order, compactness, continuity, integrability, unique zero, monotonicity, no anticipation, overlap. Full checklist in `references/regularity-and-partial-id.md`.

### Step 7 — Estimation Link
Connect identification to a feasible estimator: explicit formula yields plug-in estimator $\hat\theta = h(P_n)$; moment conditions yield GMM; likelihood yields MLE. State the consistency result.

---

## Identification Arguments by Method

| Method | Key Assumption | Formal Statement | Common Failure | Test |
|--------|---------------|-----------------|----------------|------|
| IV/2SLS | Exclusion | $Z \perp \varepsilon$ | Direct effect of $Z$ on $Y$ | Overid test; substantive argument |
| LATE | Exclusion + monotonicity | $D(1) \geq D(0)$ a.s.; $Z \perp (Y(0),Y(1),D(0),D(1))$ | Defiers; exclusion violated | Monotonicity untestable; falsification |
| DiD | Parallel trends | $E[Y(0)_{t=1}-Y(0)_{t=0}|D=1] = E[Y_{t=1}-Y_{t=0}|D=0]$ | Differential anticipation/trends | Pre-trends event study; Rambachan-Roth |
| Sharp RDD | Continuity at cutoff | $E[Y(0)|X=x]$ continuous at $c$ | Manipulation | McCrary/rddensity; covariate smoothness |
| Fuzzy RDD | Continuity + first stage | Cutoff shifts $D$ discontinuously | Compound discontinuity | Placebo outcomes; covariate balance |
| Structural (BLP) | Rank on instruments | $\mathrm{rank}(E[Z'X]) = K$ | Weak instruments | First-stage F; Cragg-Donald |
| Structural (dynamic) | Exclusion in Bellman | State captures payoff-relevant history | Omitted state variable | Residual correlation test |
| Nonparametric IV | Completeness | $E[\phi(X)|Z]=0 \implies \phi=0$ a.s. | Discrete instrument | Support conditions (not directly testable) |

Full derivations for each method: `references/derivation-tools.md`

---

## Formal vs Informal Arguments

**Formal proof required when:**
- Proposing a new estimator or identification strategy
- Identification relies on non-standard assumptions (partial ID, extrapolation)
- Model involves equilibrium/fixed-point arguments where uniqueness is non-obvious
- A reviewer raised an identification concern
- Paper is methodological

**Informal argument sufficient when:**
- Applying a well-known method with established identification results
- Assumptions are standard for the method and context
- Paper's contribution is empirical, not methodological

For formal proofs, use the LaTeX and prose templates in `references/proof-template.md`. Minimal skeleton:

```latex
\begin{assumption}[Model restrictions]\label{ass:model}
  (i) Structural equation; (ii) Exogeneity; (iii) Relevance/rank;
  (iv) Support; (v) Compactness; (vi) Continuity.
\end{assumption}

\begin{proposition}[Identification of $\theta_0$]\label{prop:id}
  Under Assumption~\ref{ass:model}, $\theta_0$ is the unique element of
  $\Theta$ satisfying $\mathbb{E}[m(X_i;\theta_0)] = 0$.
\end{proposition}

\begin{proof}
  Step 1: Observational implications (model $\to$ moments).
  Step 2: Rank condition $\implies$ local injectivity (IFT).
  Step 3: Global uniqueness argument. \hfill$\square$
\end{proof}
```

---

## When Point Identification Fails

If identification fails, characterize the identified set $\Theta^*$. Key approaches:
- **Manski sharp bounds** — worst-case bounds without distributional assumptions
- **Intersection bounds** — tighten via multiple assumption-driven bounds (Chernozhukov, Lee, Rosen 2013)
- **Sensitivity analysis** — Oster (2019) bounds relate to partial ID under proportional selection

Full treatment: `references/regularity-and-partial-id.md`. For empirical sensitivity exercises, see `sensitivity-analysis.md` in the `empirical-playbook` skill.

---

## Integration with compound-science

- **`identification-critic` agent** — Reviews a completed identification argument (assumption completeness, rank conditions, support)
- **`mathematical-prover` agent** — Verifies proof steps: fixed-point arguments, rank conditions, uniqueness
- **`identification-critic` agent** — Interactive review of a completed identification argument
- **`causal-inference` skill** — Method-specific implementation after identification is established
- **`structural-modeling` skill** — BLP and dynamic DC implementation details
- **`empirical-playbook` skill → `sensitivity-analysis.md`** — Oster bounds, specification curves, breakdown frontiers
