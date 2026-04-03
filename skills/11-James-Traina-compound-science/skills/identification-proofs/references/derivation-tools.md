# Derivation Tools for Identification

Detailed tools and worked examples for deriving identification results. Referenced from the main SKILL.md.

---

## 1. Implicit Function Theorem Approach (Parametric Models)

The IFT is the workhorse for local identification in parametric models with moment conditions.

**Setup.** Suppose the model implies moment conditions

$$\mathbb{E}[m(X; \theta)] = 0$$

where $m: \mathcal{X} \times \Theta \to \mathbb{R}^L$ and $\theta \in \mathbb{R}^K$.

**Order condition (necessary).** Identification requires at least as many moment conditions as parameters: $L \geq K$. If $L < K$, the system is underdetermined and $\theta$ is not identified.

**Rank condition (sufficient for local identification).** Assume:
- $\theta_0$ satisfies $\mathbb{E}[m(X;\theta_0)] = 0$
- $\mathbb{E}[m(X;\theta)]$ is continuously differentiable in $\theta$ at $\theta_0$
- The Jacobian $G(\theta_0) \equiv \frac{\partial}{\partial \theta'} \mathbb{E}[m(X;\theta)]\big|_{\theta=\theta_0}$ has full column rank $K$

Then $\theta_0$ is locally identified (Rothenberg 1971).

**Intuition.** Full column rank of $G$ means the moment conditions are "sensitive" to each direction in parameter space — there is no direction $d\theta$ along which all moment conditions are insensitive to the perturbation. If the Jacobian is rank-deficient, there is a direction $d\theta$ along which $\theta_0 + t \cdot d\theta$ is also a solution, at least locally.

**Global identification.** Local identification via the rank condition does not imply global identification. Global identification requires additionally that $\theta_0$ is the *unique* global solution to $\mathbb{E}[m(X;\theta)] = 0$. This typically requires additional restrictions:
- Convexity of the criterion function
- Compactness of $\Theta$ combined with uniqueness on the interior
- Structural arguments (e.g., the contraction mapping in BLP's Berry inversion establishes a unique mean utility vector)

**Worked example: Linear IV.** The structural equation is $Y = X\beta + \varepsilon$ with instruments $Z$ ($K$ endogenous regressors, $L \geq K$ instruments). The moment conditions are

$$\mathbb{E}[Z(Y - X\beta)] = 0 \implies \mathbb{E}[ZY] = \mathbb{E}[ZX]\beta.$$

The Jacobian is $G = -\mathbb{E}[ZX']$, a $L \times K$ matrix. The rank condition requires $\text{rank}(\mathbb{E}[ZX']) = K$, which is the standard IV rank condition. When $L = K$ (just-identified), the unique solution is

$$\beta_0 = (\mathbb{E}[ZX'])^{-1} \mathbb{E}[ZY],$$

establishing point identification via the explicit formula route.

---

## 2. Completeness Approach (Nonparametric IV)

In nonparametric IV settings, identification of the structural function $g$ in $Y = g(X) + \varepsilon$ (with $\mathbb{E}[\varepsilon|Z] = 0$) requires a completeness condition.

**Definition (L2 completeness).** The conditional distribution of $X$ given $Z$ is *L2-complete* if for any square-integrable function $\phi$:

$$\mathbb{E}[\phi(X)|Z] = 0 \text{ a.s.} \implies \phi(X) = 0 \text{ a.s.}$$

**Why it matters.** The moment condition $\mathbb{E}[\varepsilon|Z] = \mathbb{E}[Y - g(X)|Z] = 0$ pins down $g$ only if the map $\phi \mapsto \mathbb{E}[\phi(X)|Z]$ is injective. Completeness is exactly this injectivity condition. Without completeness, the moment condition is consistent with multiple functions $g$.

**When completeness holds:**
- Continuous instruments with a density that is bounded away from zero on its support
- Exponential family models for $(X|Z)$ — Newey and Powell (2003) give sufficient conditions
- Binary instrument $Z$: completeness fails for nonparametric identification; this is why nonparametric LATE is not identified from a binary instrument without additional assumptions

**Connection to parametric IV.** For a parametric class $\mathcal{G} = \{g(\cdot;\theta): \theta \in \Theta\}$, completeness is not needed — the rank condition on the Jacobian suffices. Completeness is the nonparametric analog of full column rank.

---

## 3. Wald Estimand: Identification of LATE

The IV Wald estimand identifies the Local Average Treatment Effect (LATE) — the average effect for *compliers*, units whose treatment status is changed by the instrument.

**Setup.** Binary instrument $Z \in \{0,1\}$, binary treatment $D \in \{0,1\}$, outcome $Y$. Potential outcomes: $Y(d)$ for $d \in \{0,1\}$; potential treatment: $D(z)$ for $z \in \{0,1\}$.

**Assumptions (Imbens and Angrist 1994):**
- **A1 (Relevance):** $\mathbb{E}[D|Z=1] \neq \mathbb{E}[D|Z=0]$ (instrument moves treatment)
- **A2 (Exclusion):** $Y(d,z) = Y(d)$ for all $d,z$ (instrument affects $Y$ only through $D$)
- **A3 (Independence):** $(Y(0), Y(1), D(0), D(1)) \perp Z$
- **A4 (Monotonicity):** $D(1) \geq D(0)$ almost surely (no defiers)

**Identification proof (step by step):**

*Step 1 — Reduced form.* Under A2 and A3:

$$\mathbb{E}[Y|Z=1] - \mathbb{E}[Y|Z=0] = \mathbb{E}[Y(D(1)) - Y(D(0))].$$

*Step 2 — Complier decomposition.* Under A4, the population consists of three strata: always-takers ($D(0)=D(1)=1$), never-takers ($D(0)=D(1)=0$), and compliers ($D(0)=0, D(1)=1$). There are no defiers.

For always-takers and never-takers, $D(1) = D(0)$, so $Y(D(1)) - Y(D(0)) = 0$. Therefore:

$$\mathbb{E}[Y(D(1)) - Y(D(0))] = \mathbb{E}[Y(1) - Y(0) \mid \text{complier}] \cdot \Pr(\text{complier}).$$

*Step 3 — First stage.* Under A3 and A4:

$$\mathbb{E}[D|Z=1] - \mathbb{E}[D|Z=0] = \Pr(\text{complier}).$$

*Step 4 — Conclusion.* Combining steps 2 and 3:

$$\text{LATE} = \mathbb{E}[Y(1)-Y(0) \mid \text{complier}] = \frac{\mathbb{E}[Y|Z=1] - \mathbb{E}[Y|Z=0]}{\mathbb{E}[D|Z=1] - \mathbb{E}[D|Z=0]}.$$

The right-hand side involves only observable quantities, establishing point identification. The Wald estimator $\hat\beta_{IV}$ consistently estimates LATE. $\square$

**What LATE is not.** LATE is not ATE (the average over all units) unless treatment effects are homogeneous or the instrument affects everyone (all units are compliers). The policy relevance of LATE depends on whether compliers are the population of interest.

---

## 4. Regression Discontinuity Identification

**Sharp RD.** Let $X$ be the running variable, $c$ the cutoff, and $D = \mathbf{1}(X \geq c)$ the treatment indicator.

**Assumption (Lee 2008 — Continuity):** The conditional regression functions $E[Y(0)|X=x]$ and $E[Y(1)|X=x]$ are continuous in $x$ at $c$.

**Identification result:**

$$E[Y(1) - Y(0) | X = c] = \lim_{x \downarrow c} E[Y|X=x] - \lim_{x \uparrow c} E[Y|X=x].$$

**Proof.** At $x \geq c$, all units are treated so $E[Y|X=x] = E[Y(1)|X=x]$. At $x < c$, all units are untreated so $E[Y|X=x] = E[Y(0)|X=x]$. Taking limits and invoking continuity:

$$\lim_{x \downarrow c} E[Y|X=x] = E[Y(1)|X=c], \quad \lim_{x \uparrow c} E[Y|X=x] = E[Y(0)|X=c].$$

The difference identifies the average treatment effect at the cutoff. $\square$

**What the continuity assumption rules out.** Sorting: agents cannot precisely manipulate $X$ to be just above vs just below the cutoff. The Lee (2008) density test (implemented via `rddensity`) tests for discontinuity in the density of $X$ at $c$ as a falsification check — a density discontinuity is inconsistent with the continuity assumption.

---

## 5. DiD Identification

**Classic 2x2 DiD.** Two groups ($D \in \{0,1\}$, treated and control), two periods ($T \in \{0,1\}$, pre and post). Treatment occurs for the treated group in period 1.

**Parallel trends assumption:**

$$\mathbb{E}[Y(0)_{T=1} - Y(0)_{T=0} \mid D=1] = \mathbb{E}[Y_{T=1} - Y_{T=0} \mid D=0].$$

This states that the *counterfactual* trend for the treated group (what would have happened absent treatment) equals the observed trend for the control group.

**Identification result:**

$$ATT = \mathbb{E}[Y(1)_{T=1} - Y(0)_{T=1} \mid D=1]$$
$$= (\mathbb{E}[Y_{T=1}|D=1] - \mathbb{E}[Y_{T=0}|D=1]) - (\mathbb{E}[Y_{T=1}|D=0] - \mathbb{E}[Y_{T=0}|D=0]).$$

**Staggered treatment (Callaway and Sant'Anna 2021).** Define group $g$ as units first treated at time $g$. The conditional parallel trends assumption:

$$\mathbb{E}[Y_t(0) - Y_{g-1}(0) \mid G=g, X] = \mathbb{E}[Y_t(0) - Y_{g-1}(0) \mid G=\infty, X],$$

for $t < g$, where $G=\infty$ denotes never-treated units and $X$ are pre-treatment covariates. The group-time ATT $ATT(g,t)$ is identified under this assumption plus a no-anticipation condition.

---

## 6. BLP Demand Identification

**Berry (1994) mean utility inversion.** In the random coefficients logit model, market shares $s_j$ are nonlinear functions of mean utilities $\delta_j$. Berry shows that the mapping $\delta \mapsto s(\delta)$ is invertible — the contraction mapping

$$\delta^{(k+1)} = \delta^{(k)} + \ln s_{\text{obs}} - \ln s(\delta^{(k)})$$

converges to the unique $\delta^*$ such that $s(\delta^*) = s_{\text{obs}}$ (Berry 1994, Proposition 1). This inversion is the inner-loop contraction in BLP estimation and establishes that the mean utilities (and hence the linear parameters $\beta$) are identified up to instruments.

**Rank condition for BLP instruments.** The identification of $\beta$ requires instruments $Z_j$ (excluded from the demand equation) that are correlated with prices after controlling for observed product characteristics. Standard BLP instruments are sums of rivals' product characteristics:

$$Z_j = \sum_{k \neq j, k \in \text{same market}} x_k.$$

The rank condition requires $\text{rank}(E[Z'X]) = K$ where $X$ are the endogenous variables (prices) and $Z$ are the instruments. This parallels the IV rank condition. Weak BLP instruments — a common problem — lead to poorly identified price coefficients and unreliable elasticities.
