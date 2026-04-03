---


name: asymptotic-theory
description: M-estimation, influence functions, and semiparametric efficiency theory for causal inference


---

# Asymptotic Theory

**Rigorous framework for statistical inference and efficiency in modern methodology**

Use this skill when working on: asymptotic properties of estimators, influence functions, semiparametric efficiency, double robustness, variance estimation, confidence intervals, hypothesis testing, M-estimation, or deriving limiting distributions.

---

## Efficiency Bounds

### Semiparametric Efficiency Theory

**Cramér-Rao Lower Bound**: For any unbiased estimator,
$$\text{Var}(\hat{\theta}) \geq \frac{1}{nI(\theta)}$$

where $I(\theta)$ is the Fisher information.

**Semiparametric Efficiency Bound**: The variance of the efficient influence function:
$$V_{eff} = E[\phi^*(\theta_0)^2]$$

where $\phi^*$ is the efficient influence function (EIF).

**Influence Function Notation**: $IF(O; \theta, P)$ represents the influence of observation $O$ on parameter $\theta$ under distribution $P$:
$$IF(O; \theta, P) = \lim_{\epsilon \to 0} \frac{T((1-\epsilon)P + \epsilon \delta_O) - T(P)}{\epsilon}$$

**Semiparametric Variance**: For RAL estimators,
$$\sqrt{n}(\hat{\theta} - \theta_0) \xrightarrow{d} N(0, E[IF(O)^2])$$

**Estimating Equations**: M-estimators solve $\sum_{i=1}^n \psi(O_i; \theta) = 0$, with asymptotic variance:
$$V = \left(\frac{\partial}{\partial \theta} E[\psi(O; \theta)]\right)^{-1} E[\psi(O; \theta)\psi(O; \theta)^T] \left(\frac{\partial}{\partial \theta} E[\psi(O; \theta)]\right)^{-T}$$

### Efficiency for Mediation Estimands

| Estimand | Efficient Influence Function | Efficiency Bound |
|----------|------------------------------|------------------|
| ATE | $\phi_{ATE} = \frac{A}{\pi}(Y-\mu_1) - \frac{1-A}{1-\pi}(Y-\mu_0) + \mu_1 - \mu_0 - \psi$ | $V_{ATE} = E[\phi_{ATE}^2]$ |
| NDE | Complex (VanderWeele & Tchetgen, 2014) | Higher than ATE |
| NIE | Complex (VanderWeele & Tchetgen, 2014) | Higher than ATE |

```r
# Compute semiparametric efficiency bound
compute_efficiency_bound <- function(data, estimand = "ATE") {
  n <- nrow(data)

  if (estimand == "ATE") {
    # Estimate nuisance functions
    ps_model <- glm(A ~ X, data = data, family = binomial)
    pi_hat <- predict(ps_model, type = "response")

    mu1_model <- lm(Y ~ X, data = subset(data, A == 1))
    mu0_model <- lm(Y ~ X, data = subset(data, A == 0))

    mu1_hat <- predict(mu1_model, newdata = data)
    mu0_hat <- predict(mu0_model, newdata = data)

    # Efficient influence function
    psi_hat <- mean(mu1_hat - mu0_hat)
    phi <- with(data, {
      A/pi_hat * (Y - mu1_hat) -
      (1-A)/(1-pi_hat) * (Y - mu0_hat) +
      mu1_hat - mu0_hat - psi_hat
    })

    # Efficiency bound = variance of EIF
    list(
      efficiency_bound = var(phi),
      standard_error = sqrt(var(phi) / n),
      eif_values = phi
    )
  }
}
```

---

## Empirical Process Theory

### Key Concepts

**Empirical Process**: $\mathbb{G}_n(f) = \sqrt{n}(\mathbb{P}_n - P)f = \frac{1}{\sqrt{n}}\sum_{i=1}^n (f(O_i) - Pf)$

**Uniform Convergence**: For function class $\mathcal{F}$,
$$\sup_{f \in \mathcal{F}} |\mathbb{G}_n(f)| \xrightarrow{d} \sup_{f \in \mathcal{F}} |\mathbb{G}(f)|$$

where $\mathbb{G}$ is a Gaussian process.

### Complexity Measures

| Measure | Definition | Use |
|---------|------------|-----|
| VC dimension | Max shattered set size | Classification |
| Covering number | $N(\epsilon, \mathcal{F}, \|\cdot\|)$ | General classes |
| Bracketing number | $N_{[]}(\epsilon, \mathcal{F}, L_2)$ | Entropy bounds |
| Rademacher complexity | $\mathcal{R}_n(\mathcal{F}) = E[\sup_{f \in \mathcal{F}} |\frac{1}{n}\sum_i \epsilon_i f(X_i)|]$ | Generalization |

```r
# Estimate Rademacher complexity via Monte Carlo
estimate_rademacher <- function(f_class, data, n_reps = 1000) {
  n <- nrow(data)

  sup_values <- replicate(n_reps, {
    # Random Rademacher variables
    epsilon <- sample(c(-1, 1), n, replace = TRUE)

    # Compute supremum over function class
    sup_f <- max(sapply(f_class, function(f) {
      abs(mean(epsilon * f(data)))
    }))

    sup_f
  })

  mean(sup_values)
}
```

---

## Donsker Classes

### Definition and Importance

A function class $\mathcal{F}$ is **Donsker** if $\mathbb{G}_n \rightsquigarrow \mathbb{G}$ in $\ell^\infty(\mathcal{F})$, where $\mathbb{G}$ is a tight Gaussian process.

### Key Donsker Classes

| Class | Description | Application |
|-------|-------------|-------------|
| VC classes | Finite VC dimension | Classification functions |
| Smooth functions | Bounded derivatives | Regression estimators |
| Monotone functions | Single crossings | Distribution functions |
| Lipschitz functions | Bounded variation | M-estimators |

### Donsker Theorem Applications

**For M-estimation**: If $\psi(O, \theta)$ belongs to a Donsker class, then
$$\sqrt{n}(\hat{\theta} - \theta_0) \xrightarrow{d} N(0, V)$$

where $V = (\partial_\theta E[\psi])^{-1} \text{Var}(\psi) (\partial_\theta E[\psi])^{-T}$

```r
# Verify Donsker conditions for empirical process
check_donsker_conditions <- function(psi_class, data) {
  # Estimate bracketing entropy integral
  epsilon_grid <- seq(0.01, 1, by = 0.01)
  bracket_numbers <- sapply(epsilon_grid, function(eps) {
    # Estimate N_[](eps, F, L_2)
    estimate_bracketing_number(psi_class, data, eps)
  })

  # Donsker if integral converges
  entropy_integral <- integrate(
    function(eps) sqrt(log(approxfun(epsilon_grid, bracket_numbers)(eps))),
    lower = 0, upper = 1
  )

  list(
    is_donsker = entropy_integral$value < Inf,
    entropy_integral = entropy_integral$value,
    bracket_numbers = data.frame(epsilon = epsilon_grid, N = bracket_numbers)
  )
}
```

---

## Core Concepts

### Why Asymptotics?

1. **Exact distributions** often unavailable for complex estimators
2. **Large-sample approximations** provide tractable inference
3. **Efficiency theory** guides optimal estimator construction
4. **Robustness** properties clarified through asymptotic analysis

### Fundamental Sequence

```
Estimator θ̂ₙ → Consistency → Asymptotic Normality → Efficiency → Inference
                    ↓              ↓                     ↓            ↓
               θ̂ₙ →ᵖ θ₀    √n(θ̂ₙ-θ₀) →ᵈ N(0,V)    V = V_eff    CIs, tests
```

---

## Modes of Convergence

### Convergence in Probability ($\xrightarrow{p}$)

$X_n \xrightarrow{p} X$ if $\forall \epsilon > 0$: $P(|X_n - X| > \epsilon) \to 0$

**Consistency**: $\hat{\theta}_n \xrightarrow{p} \theta_0$

### Convergence in Distribution ($\xrightarrow{d}$)

$X_n \xrightarrow{d} X$ if $F_{X_n}(x) \to F_X(x)$ at all continuity points

**Asymptotic normality**: $\sqrt{n}(\hat{\theta}_n - \theta_0) \xrightarrow{d} N(0, V)$

### Almost Sure Convergence ($\xrightarrow{a.s.}$)

$X_n \xrightarrow{a.s.} X$ if $P(\lim_{n\to\infty} X_n = X) = 1$

**Relationship**: $\xrightarrow{a.s.} \Rightarrow \xrightarrow{p} \Rightarrow \xrightarrow{d}$

### Stochastic Order Notation

| Notation | Meaning | Example |
|----------|---------|---------|
| $O_p(1)$ | Bounded in probability | $\hat{\theta}_n = O_p(1)$ |
| $o_p(1)$ | Converges to 0 in probability | $\hat{\theta}_n - \theta_0 = o_p(1)$ |
| $O_p(a_n)$ | $X_n/a_n = O_p(1)$ | $\hat{\theta}_n - \theta_0 = O_p(n^{-1/2})$ |
| $o_p(a_n)$ | $X_n/a_n = o_p(1)$ | Remainder terms |

---

## Key Theorems

### Laws of Large Numbers

**Weak LLN**: If $X_1, \ldots, X_n$ iid with $E|X| < \infty$:
$$\bar{X}_n \xrightarrow{p} E[X]$$

**Strong LLN**: If $X_1, \ldots, X_n$ iid with $E|X| < \infty$:
$$\bar{X}_n \xrightarrow{a.s.} E[X]$$

**Uniform LLN**: For $\sup_{\theta \in \Theta}$ convergence, need additional conditions (compactness, envelope).

### Central Limit Theorem

**Classical CLT**: If $X_1, \ldots, X_n$ iid with $E[X] = \mu$, $Var(X) = \sigma^2 < \infty$:
$$\sqrt{n}(\bar{X}_n - \mu) \xrightarrow{d} N(0, \sigma^2)$$

**Lindeberg-Feller CLT**: For triangular arrays with:
$$\sum_{i=1}^n E[X_{ni}^2 \mathbf{1}(|X_{ni}| > \epsilon)] \to 0 \quad \forall \epsilon > 0$$

**Multivariate CLT**:
$$\sqrt{n}(\bar{X}_n - \mu) \xrightarrow{d} N(0, \Sigma)$$

### Slutsky's Theorem

If $X_n \xrightarrow{d} X$ and $Y_n \xrightarrow{p} c$ (constant):
- $X_n + Y_n \xrightarrow{d} X + c$
- $X_n Y_n \xrightarrow{d} cX$
- $X_n/Y_n \xrightarrow{d} X/c$ (if $c \neq 0$)

### Continuous Mapping Theorem

If $X_n \xrightarrow{d} X$ and $g$ continuous:
$$g(X_n) \xrightarrow{d} g(X)$$

### Delta Method

If $\sqrt{n}(\hat{\theta}_n - \theta_0) \xrightarrow{d} N(0, V)$ and $g$ differentiable at $\theta_0$:
$$\sqrt{n}(g(\hat{\theta}_n) - g(\theta_0)) \xrightarrow{d} N(0, g'(\theta_0)^\top V g'(\theta_0))$$

**Multivariate**: Replace $g'(\theta_0)$ with Jacobian matrix.

---

## M-Estimation Theory

### Setup

Estimator $\hat{\theta}_n$ solves:
$$\hat{\theta}_n = \arg\max_{\theta \in \Theta} M_n(\theta)$$

where $M_n(\theta) = n^{-1} \sum_{i=1}^n m(O_i; \theta)$

### Consistency Conditions

1. **Uniform convergence**: $\sup_\theta |M_n(\theta) - M(\theta)| \xrightarrow{p} 0$
2. **Identification**: $M(\theta)$ uniquely maximized at $\theta_0$
3. **Compactness**: $\Theta$ compact (or identification at distance from boundary)

**Result**: $\hat{\theta}_n \xrightarrow{p} \theta_0$

### Asymptotic Normality Conditions

1. $\theta_0$ interior point of $\Theta$
2. $M(\theta)$ twice differentiable at $\theta_0$
3. $\ddot{M}(\theta_0)$ non-singular
4. $\sqrt{n} \dot{M}_n(\theta_0) \xrightarrow{d} N(0, V)$

**Result**:
$$\sqrt{n}(\hat{\theta}_n - \theta_0) \xrightarrow{d} N(0, [-\ddot{M}(\theta_0)]^{-1} V [-\ddot{M}(\theta_0)]^{-1})$$

### Standard Errors

**Sandwich estimator**:
$$\hat{V} = \hat{A}^{-1} \hat{B} \hat{A}^{-1}$$

where:
- $\hat{A} = -n^{-1} \sum_i \ddot{m}(O_i; \hat{\theta}_n)$ (Hessian)
- $\hat{B} = n^{-1} \sum_i \dot{m}(O_i; \hat{\theta}_n) \dot{m}(O_i; \hat{\theta}_n)^\top$ (outer product)

---

## Influence Functions

### Definition

The **influence function** of a functional $T(P)$ at distribution $P$ is:
$$\phi(o) = \lim_{\epsilon \to 0} \frac{T((1-\epsilon)P + \epsilon \delta_o) - T(P)}{\epsilon}$$

where $\delta_o$ is point mass at $o$.

### Properties

1. **Mean zero**: $E_P[\phi(O)] = 0$
2. **Variance = asymptotic variance**: If $\sqrt{n}(\hat{T}_n - T) \xrightarrow{d} N(0, V)$, then $V = E[\phi(O)^2]$
3. **Linearization**: $\sqrt{n}(\hat{T}_n - T) = \sqrt{n} \mathbb{P}_n[\phi] + o_p(1)$

### Examples

| Functional | Influence Function |
|------------|-------------------|
| Mean $E[Y]$ | $\phi(y) = y - E[Y]$ |
| Variance $Var(Y)$ | $\phi(y) = (y - \mu)^2 - \sigma^2$ |
| Quantile $Q_p$ | $\phi(y) = \frac{p - \mathbf{1}(y \leq Q_p)}{f(Q_p)}$ |
| Regression coefficient | $\phi = (X^\top X)^{-1} X(Y - X^\top\beta)$ |

### Deriving Influence Functions

**Method 1: Gateaux derivative** (definition)

**Method 2: Estimating equation approach**
If $\hat{\theta}$ solves $\mathbb{P}_n[\psi(O; \theta)] = 0$, then:
$$\phi(O) = -E[\partial_\theta \psi]^{-1} \psi(O; \theta_0)$$

**Method 3: Functional delta method**
For $\psi = g(T_1, T_2, \ldots)$:
$$\phi_\psi = \sum_j \frac{\partial g}{\partial T_j} \phi_{T_j}$$

---

## Semiparametric Efficiency

### Semiparametric Models

Model $\mathcal{P}$ contains distributions satisfying:
$$\theta = \Psi(P), \quad P \in \mathcal{P}$$

The "nuisance" is infinite-dimensional (e.g., unknown baseline distribution).

### Tangent Space

**Parametric submodels**: One-dimensional smooth paths $\{P_t : t \in \mathbb{R}\}$ through $P_0$.

**Score**: $S = \partial_t \log p_t \big|_{t=0}$

**Tangent space** $\mathcal{T}$: Closed linear span of all such scores.

### Efficiency Bound

The **efficient influence function** (EIF) is the projection of any influence function onto the tangent space.

**Semiparametric efficiency bound**:
$$V_{eff} = E[\phi_{eff}(O)^2]$$

No regular estimator can have asymptotic variance smaller than $V_{eff}$.

### Achieving Efficiency

An estimator is **semiparametrically efficient** if its influence function equals the EIF:
$$\phi_{\hat{\theta}} = \phi_{eff}$$

**Strategies**:
1. Solve efficient score equation
2. Targeted learning (TMLE)
3. One-step estimator with EIF-based correction

---

## Double Robustness

### Concept

An estimator is **doubly robust** if it is consistent when **either**:
- Outcome model correctly specified, OR
- Treatment model (propensity score) correctly specified

### AIPW Estimator

For ATE $\psi = E[Y(1) - Y(0)]$:

$$\hat{\psi}_{DR} = \mathbb{P}_n\left[\frac{A(Y - \hat{\mu}_1(X))}{\hat{\pi}(X)} + \hat{\mu}_1(X)\right] - \mathbb{P}_n\left[\frac{(1-A)(Y - \hat{\mu}_0(X))}{1-\hat{\pi}(X)} + \hat{\mu}_0(X)\right]$$

where:
- $\hat{\mu}_a(X) = \hat{E}[Y|A=a,X]$ (outcome model)
- $\hat{\pi}(X) = \hat{P}(A=1|X)$ (propensity score)

### Why It Works

**Bias decomposition**:
$$\hat{\psi}_{DR} - \psi = \text{(outcome error)} \times \text{(propensity error)} + o_p(n^{-1/2})$$

If either error is zero, bias is zero.

### Efficiency Under Double Robustness

When **both** models correct:
- Achieves semiparametric efficiency bound
- Asymptotic variance = $E[\phi_{eff}^2]$

When **one** model wrong:
- Still consistent
- But less efficient than when both correct

---

## Variance Estimation

### Analytic (Sandwich)

$$\hat{V} = \frac{1}{n} \sum_{i=1}^n \hat{\phi}(O_i)^2$$

where $\hat{\phi}$ is estimated influence function.

### Bootstrap

**Nonparametric bootstrap**:
1. Resample $n$ observations with replacement
2. Compute $\hat{\theta}^*_b$ for $b = 1, \ldots, B$
3. $\hat{V} = \text{Var}(\hat{\theta}^*_1, \ldots, \hat{\theta}^*_B)$

**Bootstrap validity**: Requires $\sqrt{n}$-consistent, regular estimators.

### Influence Function-Based Bootstrap

More stable than full recomputation:
$$\hat{\theta}^*_b = \hat{\theta} + n^{-1} \sum_{i=1}^n (W_i^* - 1) \hat{\phi}(O_i)$$

where $W_i^*$ are bootstrap weights.

---

## Inference

### Confidence Intervals

**Wald interval**:
$$\hat{\theta} \pm z_{1-\alpha/2} \cdot \hat{SE}$$

**Percentile bootstrap**:
$$[\hat{\theta}^*_{(\alpha/2)}, \hat{\theta}^*_{(1-\alpha/2)}]$$

**BCa bootstrap** (bias-corrected accelerated):
Corrects for bias and skewness.

### Hypothesis Testing

**Wald test**: $W = (\hat{\theta} - \theta_0)^2 / \hat{V} \sim \chi^2_1$

**Score test**: Based on score at null.

**Likelihood ratio test**: $2(\ell(\hat{\theta}) - \ell(\theta_0)) \sim \chi^2_k$

---

## Product of Coefficients (Mediation)

### Setup

Mediation effect = $\alpha \beta$ (or $\alpha_1 \beta_1 \gamma_2$ for sequential)

### Distribution of Products

**Not normal**: Product of normals is NOT normal.

**Exact distribution**: Complex (involves Bessel functions for two normals).

**Approximations**:
1. **Sobel test**: Normal approximation via delta method
2. **PRODCLIN**: Distribution of product method (RMediation)
3. **Monte Carlo**: Simulate from joint distribution

### Delta Method Variance

For $\psi = \alpha\beta$:
$$Var(\hat{\alpha}\hat{\beta}) \approx \beta^2 Var(\hat{\alpha}) + \alpha^2 Var(\hat{\beta}) + Var(\hat{\alpha})Var(\hat{\beta})$$

The last term often omitted (Sobel) but matters when effects are small.

### Product of Three

For sequential mediation $\psi = \alpha_1 \beta_1 \gamma_2$:
- Distribution more complex
- Monte Carlo or specialized methods needed
- Your "product of three" manuscript addresses this

---

## Regularity Conditions Checklist

### For Consistency

- [ ] Parameter space compact (or bounded away from boundary)
- [ ] Objective function continuous in $\theta$
- [ ] Uniform convergence of criterion
- [ ] Unique maximizer at $\theta_0$

### For Asymptotic Normality

- [ ] $\theta_0$ interior point
- [ ] Twice differentiable criterion
- [ ] Non-singular Hessian
- [ ] CLT applies to score
- [ ] Lindeberg/Lyapunov conditions if non-iid

### For Efficiency

- [ ] Model correctly specified
- [ ] Nuisance parameters consistently estimated
- [ ] Sufficient smoothness for influence function calculation
- [ ] Rate conditions on nuisance estimation (for doubly robust)

---

## Common Pitfalls

### 1. Ignoring Estimation of Nuisance Parameters

Wrong: Treat $\hat{\eta}$ as known when computing variance.
Right: Account for $\hat{\eta}$ uncertainty or use cross-fitting.

### 2. Slow Nuisance Estimation

For doubly robust estimators, need:
$$\|\hat{\mu} - \mu_0\| \cdot \|\hat{\pi} - \pi_0\| = o_p(n^{-1/2})$$

If both converge at $n^{-1/4}$, product is $n^{-1/2}$.

### 3. Bootstrap Failure

Bootstrap can fail for:
- Non-differentiable functionals
- Super-efficient estimators
- Boundary parameters

### 4. Underestimating Variance

Sandwich estimator assumes correct influence function.
Model misspecification → wrong variance.

---

## Template: Asymptotic Result

```latex
\begin{theorem}[Asymptotic Distribution]
Under Assumptions \ref{A1}--\ref{An}:
\begin{enumerate}
\item (Consistency) $\hat{\theta}_n \xrightarrow{p} \theta_0$
\item (Asymptotic normality) $\sqrt{n}(\hat{\theta}_n - \theta_0) \xrightarrow{d} N(0, V)$
\item (Variance) $V = E[\phi(O)^2]$ where $\phi$ is the influence function
\item (Variance estimation) $\hat{V} \xrightarrow{p} V$
\end{enumerate}
\end{theorem}

\begin{proof}
\textbf{Step 1 (Consistency):}
[Apply M-estimation or direct argument]

\textbf{Step 2 (Expansion):}
Taylor expand around $\theta_0$:
\[
0 = \mathbb{P}_n[\psi(O; \hat{\theta})] = \mathbb{P}_n[\psi(O; \theta_0)]
    + \mathbb{P}_n[\dot{\psi}(\tilde{\theta})](\hat{\theta} - \theta_0)
\]

\textbf{Step 3 (Rearrangement):}
\[
\sqrt{n}(\hat{\theta} - \theta_0) = -[\mathbb{P}_n[\dot{\psi}]]^{-1} \sqrt{n}\mathbb{P}_n[\psi(O; \theta_0)]
\]

\textbf{Step 4 (CLT):}
$\sqrt{n}\mathbb{P}_n[\psi(O; \theta_0)] \xrightarrow{d} N(0, E[\psi\psi^\top])$ by CLT.

\textbf{Step 5 (Slutsky):}
$\mathbb{P}_n[\dot{\psi}] \xrightarrow{p} E[\dot{\psi}]$ by WLLN. Apply Slutsky.

\textbf{Step 6 (Identify $V$):}
$V = E[\dot{\psi}]^{-1} E[\psi\psi^\top] E[\dot{\psi}]^{-\top}$.
\end{proof}
```

---

## Integration with Other Skills

This skill works with:
- **proof-architect** - For structuring asymptotic proofs
- **identification-theory** - Identification precedes estimation/inference
- **simulation-architect** - Validate asymptotic approximations
- **methods-paper-writer** - Present results in manuscripts

---

## Key References
- Bickel
- Newey
- Robins

- van der Vaart, A.W. (1998). Asymptotic Statistics
- Tsiatis, A.A. (2006). Semiparametric Theory and Missing Data
- Kennedy, E.H. (2016). Semiparametric Theory and Empirical Processes
- van der Laan, M.J. & Rose, S. (2011). Targeted Learning

---

**Version**: 1.0
**Created**: 2025-12-08
**Domain**: Asymptotic Statistics, Semiparametric Inference
