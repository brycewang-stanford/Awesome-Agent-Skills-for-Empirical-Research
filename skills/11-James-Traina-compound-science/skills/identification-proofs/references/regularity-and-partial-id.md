# Regularity Conditions and Partial Identification

Detailed checklists for regularity conditions and methods for partial identification when point identification fails. Referenced from the main SKILL.md.

---

## Regularity Conditions Checklist

For every identification argument, verify each condition before claiming the result.

- [ ] **Support condition**: Does the instrument $Z$ have sufficient support? For binary $Z$: $\Pr(Z=1) \in (0,1)$. For continuous $Z$ in nonparametric IV: full support on $\mathcal{Z}$.
- [ ] **Rank condition**: Is the Jacobian $G(\theta_0) = \partial\mathbb{E}[m]/\partial\theta'|_{\theta_0}$ full column rank? Check this numerically at your preliminary estimates — a near-singular Jacobian signals weak identification.
- [ ] **Order condition**: Number of moment conditions $L \geq$ number of parameters $K$.
- [ ] **Compactness**: Is the parameter space $\Theta$ compact? Required for most consistency theorems and for applying extreme value theorems in the proof.
- [ ] **Continuity**: Are the moment functions $\theta \mapsto \mathbb{E}[m(X;\theta)]$ continuous (or differentiable where needed) in $\theta$?
- [ ] **Integrability**: Are all expectations $\mathbb{E}[m(X;\theta)]$ finite? Check that $m(X;\theta)$ is dominated by an integrable function uniformly in $\theta \in \Theta$.
- [ ] **Unique zero (global)**: For global identification, is $\theta_0$ the unique solution to $\mathbb{E}[m(X;\theta)] = 0$ over all of $\Theta$?
- [ ] **Monotonicity (for IV LATE)**: Is $D(Z=1) \geq D(Z=0)$ a.s.? This rules out defiers. Often defended by design (one-sided non-compliance) or institutional argument.
- [ ] **No anticipation (for DiD)**: $Y_{it}(g) = Y_{it}(\infty)$ for $t < g$ (potential outcomes before treatment are unaffected by future treatment status).
- [ ] **Overlap / common support (for ATE, ATT)**: $0 < \Pr(D=1|X) < 1$ over the support of $X$.

**What to do when a condition fails:**
- Rank condition fails: the model is not identified — revisit assumptions or add instruments
- Support condition fails (e.g., instrument has limited support): partial identification may be possible; see below
- Global uniqueness hard to verify: report local identification, note the caveat, use multiple starting values to search for alternative solutions

---

## Partial Identification

When point identification fails, characterize what the data *do* identify: the identified set $\Theta^* = \{\theta \in \Theta : P_\theta = P_{\theta_0}\}$.

### Manski (1990) Sharp Bounds

The canonical example is the average treatment effect under sample selection or missing data. With binary outcome $Y \in \{0,1\}$ and binary treatment $D$:

$$E[Y(1)] \in \left[\frac{E[YD]}{E[D]}, \quad \frac{E[YD]}{E[D]} + \frac{E[1-D]}{1}\right]$$

(the lower bound uses $Y(1)=0$ for non-treated; the upper bound uses $Y(1)=1$). These *sharp* bounds — the tightest possible given the observable distribution — define the identified set without assuming missing-at-random.

Tightening sharp bounds requires additional assumptions: monotone treatment response, monotone treatment selection, or an instrument. Each additional assumption narrows $\Theta^*$. The partial identification approach is explicit about the trade-off between assumptions and set width.

### Intersection Bounds

When multiple identifying assumptions each imply an upper or lower bound on $\theta_0$, the intersection of these bounds is sharper:

$$\theta_0 \in \bigcap_{k} \left[L_k, U_k\right].$$

Chernozhukov, Lee, and Rosen (2013) provide inference methods for intersection bounds.

### Interval Regression

With interval-censored data — $Y \in [Y_L, Y_U]$ — the regression coefficient is set-identified. Stoye (2010) characterizes the identified set and provides valid confidence regions.

### Connection to Sensitivity Analysis

Partial identification and sensitivity analysis are related: Oster (2019) bounds on treatment effects under proportional selection on observables are equivalent to characterizing the identified set under a restriction on the degree of selection. The `empirical-playbook` skill (`sensitivity-analysis.md`) covers Oster bounds and related sensitivity exercises. Both approaches answer the same question: "How much can the unidentified component vary, and what does that imply for the parameter?"
