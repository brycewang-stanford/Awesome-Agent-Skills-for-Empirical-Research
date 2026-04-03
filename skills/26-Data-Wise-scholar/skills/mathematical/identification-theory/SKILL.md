---


name: identification-theory
description: DAG and potential outcomes frameworks for causal mediation identification


---

# Identification Theory

**Comprehensive framework for causal identification in statistical methodology**

Use this skill when working on: causal identification, mediation analysis identification, DAG-based reasoning, potential outcomes, identification assumptions, partial identification, sensitivity analysis, or deriving identification formulas.

---

## Core Concepts

### What is Identification?

A causal parameter $\psi$ is **identified** if it can be uniquely determined from the observed data distribution $P(O)$.

Formally: $\psi$ is identified if $P_1(O) = P_2(O) \Rightarrow \psi_1 = \psi_2$.

### Why Identification Matters

```
Causal Question → Target Estimand → Identification → Estimation → Inference
     ↓                  ↓                ↓               ↓            ↓
  "Does A           E[Y(1)-Y(0)]     Express in      Statistical   Confidence
   cause Y?"                         terms of P(O)    methods      intervals
```

Without identification, no amount of data can answer causal questions.

---

## Two Frameworks

### 1. Potential Outcomes (Rubin/Neyman)

**Primitives**:
- $Y(a)$ = potential outcome under treatment $a$
- Only $Y = Y(A)$ is observed (consistency)
- Fundamental problem: never observe both $Y(0)$ and $Y(1)$ for same unit

**Advantages**:
- Clear definition of causal effects
- Natural for experimental reasoning
- Connects to missing data theory

### 2. Structural Causal Models (Pearl)

**Primitives**:
- Directed Acyclic Graph (DAG) encoding causal structure
- Structural equations: $Y := f_Y(PA_Y, U_Y)$
- Interventions via do-operator: $P(Y | do(A=a))$

**Advantages**:
- Visual representation of assumptions
- Systematic identification algorithms
- Clear separation of statistical and causal assumptions

---

## DAG Framework

### Directed Acyclic Graphs (DAGs)

A DAG $\mathcal{G} = (V, E)$ consists of:
- **Vertices** $V$: Random variables
- **Directed edges** $E$: Direct causal relationships
- **Acyclic**: No directed cycles

### Key DAG Terminology

| Term | Definition | Notation |
|------|------------|----------|
| Parents | Direct causes | $PA_Y$ |
| Children | Direct effects | $CH_Y$ |
| Ancestors | All causes | $AN_Y$ |
| Descendants | All effects | $DE_Y$ |
| Collider | Node with two incoming arrows | $A \to C \leftarrow B$ |
| Mediator | Node on causal path | $A \to M \to Y$ |
| Confounder | Common cause | $A \leftarrow C \to Y$ |

```r
# DAG specification and visualization using dagitty
library(dagitty)

# Define mediation DAG
mediation_dag <- dagitty('
  dag {
    A [exposure]
    M [mediator]
    Y [outcome]
    X [confounder]

    X -> A
    X -> M
    X -> Y
    A -> M
    A -> Y
    M -> Y
  }
')

# Visualize
plot(mediation_dag)

# Find adjustment sets
adjustmentSets(mediation_dag, exposure = "A", outcome = "Y")

# Check implied conditional independencies
impliedConditionalIndependencies(mediation_dag)
```

---

## D-Separation

### The Core Concept

Two nodes $A$ and $B$ are **d-separated** by set $Z$ if every path between them is blocked.

### Path Blocking Rules

| Path Type | Blocked by conditioning on... |
|-----------|-------------------------------|
| Chain: $A \to M \to B$ | $M$ (blocks) |
| Fork: $A \leftarrow C \to B$ | $C$ (blocks) |
| Collider: $A \to C \leftarrow B$ | NOT $C$ (conditioning opens!) |

### D-separation Formula

$$A \perp\!\!\!\perp_{\mathcal{G}} B \mid Z \iff \text{every path } A \text{---} B \text{ is blocked by } Z$$

```r
# Check d-separation using dagitty
check_dseparation <- function(dag, x, y, z = NULL) {
  if (is.null(z)) {
    dseparated(dag, x, y)
  } else {
    dseparated(dag, x, y, z)
  }
}

# Find all d-separating sets
find_dsep_sets <- function(dag, x, y) {
  # All adjustment sets that d-separate x and y
  adjustmentSets(dag, exposure = x, outcome = y, effect = "total")
}

# Verify conditional independence implications
verify_ci_implications <- function(dag, data) {
  implied_ci <- impliedConditionalIndependencies(dag)

  results <- lapply(implied_ci, function(ci) {
    # Parse the CI statement
    vars <- strsplit(as.character(ci), " _\\|\\|_ | \\| ")[[1]]
    x <- vars[1]
    y <- vars[2]
    z <- if (length(vars) > 2) vars[3:length(vars)] else NULL

    # Test with partial correlation or conditional independence test
    test_result <- test_conditional_independence(data, x, y, z)

    list(statement = as.character(ci), p_value = test_result$p.value)
  })

  do.call(rbind, lapply(results, as.data.frame))
}
```

---

## Backdoor Criterion

### Definition

A set $Z$ satisfies the **backdoor criterion** relative to $(A, Y)$ if:
1. No node in $Z$ is a descendant of $A$
2. $Z$ blocks every path between $A$ and $Y$ that contains an arrow into $A$

### Backdoor Adjustment Formula

If $Z$ satisfies the backdoor criterion:
$$P(Y | do(A = a)) = \sum_z P(Y | A = a, Z = z) P(Z = z)$$

or equivalently:
$$E[Y(a)] = E_Z[E[Y | A = a, Z]]$$

### Front-Door Criterion

When backdoor fails but mediator is unconfounded:
$$P(Y | do(A)) = \sum_m P(M = m | A) \sum_{a'} P(Y | M = m, A = a') P(A = a')$$

```r
# Check backdoor criterion
check_backdoor <- function(dag, exposure, outcome, adjustment_set) {
  # Using dagitty
  valid_sets <- adjustmentSets(dag, exposure = exposure,
                                outcome = outcome, type = "minimal")

  # Check if proposed set is valid
  is_valid <- any(sapply(valid_sets, function(s) {
    setequal(s, adjustment_set)
  }))

  list(
    is_valid = is_valid,
    minimal_sets = valid_sets,
    proposed = adjustment_set
  )
}

# Compute backdoor-adjusted estimate
backdoor_adjustment <- function(data, outcome, exposure, adjustment) {
  formula_str <- paste(outcome, "~", exposure, "+",
                       paste(adjustment, collapse = " + "))
  model <- lm(as.formula(formula_str), data = data)

  # Standardization
  predictions_a1 <- predict(model,
    newdata = transform(data, setNames(list(1), exposure)))
  predictions_a0 <- predict(model,
    newdata = transform(data, setNames(list(0), exposure)))

  list(
    ate = mean(predictions_a1 - predictions_a0),
    se = sqrt(var(predictions_a1 - predictions_a0) / nrow(data))
  )
}

# Full identification analysis
analyze_identification <- function(dag, exposure, outcome) {
  list(
    adjustment_sets = adjustmentSets(dag, exposure, outcome),
    instrumental_sets = instrumentalVariables(dag, exposure, outcome),
    direct_effects = adjustmentSets(dag, exposure, outcome, effect = "direct"),
    implied_independencies = impliedConditionalIndependencies(dag)
  )
}
```

### Framework Equivalence

For most problems, both frameworks give equivalent results:
$$E[Y(a)] = E[Y | do(A=a)]$$

Choose based on context and audience.

---

## Key Identification Assumptions

### For Treatment Effects

| Assumption | Formal Statement | Interpretation |
|------------|------------------|----------------|
| **Consistency** | $Y = Y(A)$ | Observed outcome equals potential outcome for received treatment |
| **Positivity** | $P(A=a \mid X=x) > 0$ for all $x$ with $P(X=x) > 0$ | Every covariate stratum has both treated and untreated |
| **Exchangeability** | $Y(a) \perp\!\!\!\perp A \mid X$ | No unmeasured confounding given $X$ |
| **SUTVA** | No interference, single version of treatment | Units don't affect each other |

### For Mediation Effects

Additional assumptions required:

| Assumption | Formal Statement | Interpretation |
|------------|------------------|----------------|
| **Cross-world exchangeability** | $Y(a,m) \perp\!\!\!\perp M(a^*) \mid X$ | Counterfactual mediator independent of counterfactual outcome |
| **No $A$-$M$ interaction** (optional) | $Y(a,m) - Y(a',m)$ constant in $m$ | Simplifies identification |
| **Compositional** | $Y(a) = Y(a, M(a))$ | Potential outcome composition |

---

## Standard Identification Results

### 1. Average Treatment Effect (ATE)

**Target**: $\psi = E[Y(1) - Y(0)]$

**Under exchangeability** (A1), **consistency** (A2), **positivity** (A3):

$$\psi = E\left[E[Y | A=1, X] - E[Y | A=0, X]\right]$$

**Proof sketch**:
\begin{align}
E[Y(a)] &= E[E[Y(a) | X]] && \text{(iterated expectations)} \\
        &= E[E[Y(a) | A=a, X]] && \text{(A1: exchangeability)} \\
        &= E[E[Y | A=a, X]] && \text{(A2: consistency)}
\end{align}

### 2. Average Treatment Effect on Treated (ATT)

**Target**: $\psi_{ATT} = E[Y(1) - Y(0) | A=1]$

**Under weaker exchangeability** $Y(0) \perp\!\!\!\perp A \mid X$:

$$\psi_{ATT} = E\left[E[Y | A=1, X] - E[Y | A=0, X] \mid A=1\right]$$

### 3. Natural Direct and Indirect Effects (Mediation)

**Target**:
- NDE: $E[Y(1, M(0)) - Y(0, M(0))]$
- NIE: $E[Y(1, M(1)) - Y(1, M(0))]$

**Under mediation assumptions** (see VanderWeele, 2015):

$$NDE = \int\int \{E[Y|A=1,M=m,X=x] - E[Y|A=0,M=m,X=x]\} \, dP(m|A=0,X=x) \, dP(x)$$

$$NIE = \int\int E[Y|A=1,M=m,X=x] \{dP(m|A=1,X=x) - dP(m|A=0,X=x)\} \, dP(x)$$

### 4. Controlled Direct Effect (CDE)

**Target**: $CDE(m) = E[Y(1,m) - Y(0,m)]$

**Simpler identification** (no cross-world assumption):

$$CDE(m) = E[E[Y|A=1,M=m,X] - E[Y|A=0,M=m,X]]$$

---

## DAG-Based Identification

### The Back-Door Criterion

A set $X$ satisfies the back-door criterion relative to $(A, Y)$ if:
1. No node in $X$ is a descendant of $A$
2. $X$ blocks every path between $A$ and $Y$ that contains an arrow into $A$

**If satisfied**:
$$P(Y | do(A=a)) = \sum_x P(Y | A=a, X=x) P(X=x)$$

### The Front-Door Criterion

When there's an unmeasured confounder $U$ between $A$ and $Y$, but $M$ mediates all of $A$'s effect:

```
    U
   / \
  ↓   ↓
  A → M → Y
```

**Identification**:
$$P(Y | do(A=a)) = \sum_m P(M=m | A=a) \sum_{a'} P(Y | M=m, A=a') P(A=a')$$

### Instrumental Variables

When $Z$ affects $Y$ only through $A$:

```
  U
  ↓
Z → A → Y
```

**Local ATE identification** (with monotonicity):
$$LATE = \frac{E[Y | Z=1] - E[Y | Z=0]}{E[A | Z=1] - E[A | Z=0]}$$

---

## Sequential Identification (Multiple Mediators)

### Sequential Mediation (A → M1 → M2 → Y)

**Product of three path** identification requires:

1. Standard confounding control for each arrow
2. No intermediate confounders affected by treatment
3. Sequential ignorability assumptions

**Path-specific effects**:
- Direct: $A \to Y$
- Through $M_1$ only: $A \to M_1 \to Y$
- Through $M_2$ only: $A \to M_2 \to Y$
- Through both: $A \to M_1 \to M_2 \to Y$

### Identification Formula (No Intermediate Confounding)

$$\text{Effect through } M_1 \to M_2 = \int E\left[\frac{\partial^3}{\partial a \partial m_1 \partial m_2} E[Y|A,M_1,M_2,X]\right]$$

Expressed as product of coefficients: $\hat{\alpha}_1 \cdot \hat{\beta}_1 \cdot \hat{\gamma}_2$

---

## Partial Identification

When point identification fails, we can still bound the parameter.

### Manski Bounds (No Assumptions)

For ATE with missing outcomes:
$$E[Y(1)] \in [E[Y \cdot A]/P(A=1) + y_{min}P(A=0), E[Y \cdot A]/P(A=1) + y_{max}P(A=0)]$$

### Sensitivity Analysis

When exchangeability is uncertain, parameterize violation:

**Unmeasured confounding parameter** $\Gamma$:
$$\frac{1}{\Gamma} \leq \frac{P(A=1|X,U=1)/P(A=0|X,U=1)}{P(A=1|X,U=0)/P(A=0|X,U=0)} \leq \Gamma$$

Compute bounds as function of $\Gamma$ (Rosenbaum bounds).

### E-Value

Minimum strength of unmeasured confounding (on risk ratio scale) needed to explain away observed effect:

$$E\text{-value} = RR + \sqrt{RR \times (RR-1)}$$

---

## Identification Strategies by Design

### Randomized Controlled Trials (RCTs)

- Treatment assignment random → exchangeability holds by design
- Still need SUTVA, consistency
- For mediation: randomize $M$ as well, or use sequential ignorability

### Observational Studies

| Strategy | Key Assumption | Best For |
|----------|----------------|----------|
| Regression adjustment | All confounders measured | Rich covariate data |
| Propensity score | Correct PS model | High-dimensional confounders |
| Instrumental variables | Valid instrument exists | Unmeasured confounding |
| Regression discontinuity | Continuity at threshold | Sharp treatment rules |
| Difference-in-differences | Parallel trends | Panel data |

### Natural Experiments

- Exploit exogenous variation (policy changes, geographic variation)
- Requires careful argument for why variation is "as-if random"

---

## Identification in the MediationVerse

### medfit: Foundation
- Implements standard mediation identification
- VanderWeele regression-based approach
- Supports binary/continuous treatments and mediators

### probmed: Effect Size
- $P_M$ identification requires identified NDE/NIE
- Handles case when NDE and NIE have opposite signs

### RMediation: Confidence Intervals
- Takes identified effects as input
- Distribution of product of coefficients (PRODCLIN)
- Monte Carlo intervals

### medrobust: Sensitivity
- When identification assumptions are uncertain
- Bounds on effects under confounding
- E-values for unmeasured confounding

### medsim: Validation
- Simulate data where truth is known
- Verify identification formulas recover true effects
- Test estimator properties

---

## Identification Proof Template

```latex
\begin{theorem}[Identification of $\psi$]
Under Assumptions:
\begin{enumerate}[label=A\arabic*.]
\item (Consistency) $Y = Y(A)$, $M = M(A)$
\item (Positivity) $P(A=a|X) > \epsilon > 0$ for all $a \in \mathcal{A}$
\item (Exchangeability) $Y(a) \perp\!\!\!\perp A \mid X$
\end{enumerate}
the causal estimand $\psi = E[g(Y(a))]$ is identified by
\[
\psi = E_X\left[E[g(Y) \mid A=a, X]\right].
\]
\end{theorem}

\begin{proof}
\begin{align}
E[g(Y(a))] &= E\left[E[g(Y(a)) \mid X]\right]
    && \text{(law of total expectation)} \\
&= E\left[E[g(Y(a)) \mid A=a, X]\right]
    && \text{(by A3: exchangeability)} \\
&= E\left[E[g(Y) \mid A=a, X]\right]
    && \text{(by A1: consistency)}
\end{align}
The RHS depends only on the observed data distribution $P(Y,A,X)$.
\end{proof}
```

---

## Common Identification Pitfalls

### 1. Conditioning on Colliders

```
A → C ← Y
```

Conditioning on $C$ opens a path between $A$ and $Y$.

### 2. Conditioning on Mediators

```
A → M → Y
```

Conditioning on $M$ blocks the indirect effect, doesn't control confounding.

### 3. Overcontrol Bias

Conditioning on descendants of treatment can bias estimates.

### 4. M-Bias

```
U1 → X ← U2
↓         ↓
A ——————→ Y
```

Conditioning on $X$ opens path $A \leftarrow U_1 \rightarrow X \leftarrow U_2 \rightarrow Y$.

### 5. Table 2 Fallacy

Interpreting coefficients causally when model includes intermediate variables.

---

## Verification Questions

When reviewing identification arguments, ask:

1. **Is the target estimand clearly defined?**
2. **Are all assumptions explicitly stated?**
3. **Is each step in the derivation justified?**
4. **Are the assumptions plausible in this context?**
5. **What if an assumption is violated?**
6. **Is there a DAG that encodes the assumptions?**
7. **Are there alternative identification strategies?**

---

## Integration with Other Skills

This skill works with:
- **proof-architect** - For writing identification proofs
- **asymptotic-theory** - For inference after identification
- **methods-paper-writer** - For presenting identification in manuscripts
- **simulation-architect** - For validating identification

---

## Key References
- Imai
- Hernan

- Pearl, J. (2009). Causality: Models, Reasoning, and Inference (2nd ed.)
- VanderWeele, T.J. (2015). Explanation in Causal Inference
- Hernán, M.A. & Robins, J.M. (2020). Causal Inference: What If
- Imbens, G.W. & Rubin, D.B. (2015). Causal Inference for Statistics

---

**Version**: 1.0
**Created**: 2025-12-08
**Domain**: Causal Inference, Mediation Analysis
