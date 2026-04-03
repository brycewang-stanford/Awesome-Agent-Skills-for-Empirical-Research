---


name: algorithm-designer
description: Design and document statistical algorithms with pseudocode and complexity analysis


---

# Algorithm Designer

You are an expert in designing and documenting statistical algorithms.

## Algorithm Documentation Standards

### Required Components
1. **Purpose**: What problem does this solve?
2. **Input/Output**: Precise specifications
3. **Pseudocode**: Language-agnostic description
4. **Complexity**: Time and space analysis
5. **Convergence**: Conditions and guarantees
6. **Implementation notes**: Practical considerations

## Input/Output Specification

### Formal Specification Template

Every algorithm must have precise input/output documentation:

```
INPUT SPECIFICATION:
- Data: D = {(Y_i, A_i, M_i, X_i)}_{i=1}^n where:
  - Y_i ∈ ℝ (continuous outcome)
  - A_i ∈ {0,1} (binary treatment)
  - M_i ∈ ℝ^d (d-dimensional mediator)
  - X_i ∈ ℝ^p (p covariates)
- Parameters: θ ∈ Θ ⊆ ℝ^k (parameter space)
- Tolerance: ε > 0 (convergence criterion)
- Max iterations: T_max ∈ ℕ

OUTPUT SPECIFICATION:
- Estimate: θ̂ ∈ ℝ^k (point estimate)
- Variance: V̂ ∈ ℝ^{k×k} (covariance matrix)
- Convergence: boolean (did algorithm converge?)
- Iterations: t ∈ ℕ (iterations used)
```

```r
# R implementation of formal I/O specification
define_algorithm_io <- function() {
  list(
    input = list(
      data = "data.frame with columns Y, A, M, X",
      params = "list(tol = 1e-6, max_iter = 1000)",
      models = "list(outcome_formula, mediator_formula, propensity_formula)"
    ),
    output = list(
      estimate = "numeric vector of parameter estimates",
      se = "numeric vector of standard errors",
      vcov = "variance-covariance matrix",
      converged = "logical indicating convergence",
      iterations = "integer count of iterations"
    ),
    complexity = list(
      time = "O(n * p^2) per iteration",
      space = "O(n * p)",
      iterations = "O(log(1/epsilon)) for Newton-type"
    )
  )
}
```

---

## Convergence Criteria

### Standard Convergence Conditions

| Criterion | Formula | Use Case |
|-----------|---------|----------|
| Absolute | $\|\theta^{(t+1)} - \theta^{(t)}\| < \varepsilon$ | Parameter convergence |
| Relative | $\|\theta^{(t+1)} - \theta^{(t)}\|/\|\theta^{(t)}\| < \varepsilon$ | Scale-invariant |
| Gradient | $\|\nabla L(\theta^{(t)})\| < \varepsilon$ | Optimization |
| Function | $\|L(\theta^{(t+1)}) - L(\theta^{(t)})\| < \varepsilon$ | Objective convergence |
| Cauchy | $\max_{i} |\theta_i^{(t+1)} - \theta_i^{(t)}| < \varepsilon$ | Component-wise |

### Mathematical Formulation

**Convergence tolerance**: $\varepsilon = 10^{-6}$ (typical default)

**Standard tolerances by application**:
- Numerical optimization: $\varepsilon = 10^{-8}$
- Statistical estimation: $\varepsilon = 10^{-6}$
- Approximate methods: $\varepsilon = 10^{-4}$

### Complexity Formulas

**Linear complexity** $O(n)$: Operations grow proportionally to input size
$$T(n) = c \cdot n + O(1)$$

**Quadratic complexity** $O(n^2)$: Nested iterations over input
$$T(n) = c \cdot n^2 + O(n)$$

**Linearithmic complexity** $O(n \log n)$: Divide-and-conquer with linear work per level
$$T(n) = c \cdot n \log_2 n + O(n)$$

**Space-Time Tradeoff**:
$$\text{Time} \times \text{Space} \geq \Omega(\text{Information Content})$$

**Convergence rate analysis**:
- Linear convergence: $\|\theta^{(t)} - \theta^*\| \leq C \cdot \rho^t$ where $0 < \rho < 1$
- Quadratic convergence: $\|\theta^{(t+1)} - \theta^*\| \leq C \cdot \|\theta^{(t)} - \theta^*\|^2$
- Superlinear: $\lim_{t \to \infty} \frac{\|\theta^{(t+1)} - \theta^*\|}{\|\theta^{(t)} - \theta^*\|} = 0$

```r
# Comprehensive convergence checking
check_convergence <- function(theta_new, theta_old, gradient = NULL,
                              objective_new = NULL, objective_old = NULL,
                              tol = 1e-6, method = "relative") {
  switch(method,
    "absolute" = {
      # |θ^(t+1) - θ^t| < ε
      converged <- max(abs(theta_new - theta_old)) < tol
      criterion <- max(abs(theta_new - theta_old))
    },
    "relative" = {
      # |θ^(t+1) - θ^t| / |θ^t| < ε
      denom <- pmax(abs(theta_old), 1)  # Avoid division by zero
      converged <- max(abs(theta_new - theta_old) / denom) < tol
      criterion <- max(abs(theta_new - theta_old) / denom)
    },
    "gradient" = {
      # |∇L(θ)| < ε
      stopifnot(!is.null(gradient))
      converged <- sqrt(sum(gradient^2)) < tol
      criterion <- sqrt(sum(gradient^2))
    },
    "objective" = {
      # |L(θ^(t+1)) - L(θ^t)| < ε
      stopifnot(!is.null(objective_new), !is.null(objective_old))
      converged <- abs(objective_new - objective_old) < tol
      criterion <- abs(objective_new - objective_old)
    }
  )

  list(converged = converged, criterion = criterion, method = method)
}

# Newton-Raphson with convergence monitoring
newton_raphson <- function(f, grad, hess, theta0, tol = 1e-6, max_iter = 100) {
  theta <- theta0
  history <- list()

  for (t in 1:max_iter) {
    g <- grad(theta)
    H <- hess(theta)

    # Newton step: θ^(t+1) = θ^t - H^(-1) * g
    # Time complexity: O(p^3) for matrix inversion
    delta <- solve(H, g)
    theta_new <- theta - delta

    # Check convergence
    conv <- check_convergence(theta_new, theta, gradient = g, tol = tol)
    history[[t]] <- list(theta = theta, gradient_norm = sqrt(sum(g^2)))

    if (conv$converged) {
      return(list(
        estimate = theta_new,
        iterations = t,
        converged = TRUE,
        history = history
      ))
    }

    theta <- theta_new
  }

  list(estimate = theta, iterations = max_iter, converged = FALSE, history = history)
}
```

### Complexity and Convergence Relationship

| Algorithm | Convergence Rate | Iterations to $\varepsilon$ |
|-----------|-----------------|----------------------------|
| Gradient Descent | $O(1/t)$ | $O(1/\varepsilon)$ |
| Accelerated GD | $O(1/t^2)$ | $O(1/\sqrt{\varepsilon})$ |
| Newton-Raphson | Quadratic | $O(\log\log(1/\varepsilon))$ |
| EM Algorithm | Linear | $O(\log(1/\varepsilon))$ |
| Coordinate Descent | Linear | $O(p \cdot \log(1/\varepsilon))$ |

---

## Pseudocode Conventions

### Standard Format
```
ALGORITHM: [Name]
INPUT: [List inputs with types]
OUTPUT: [List outputs with types]

1. [Initialize]
2. [Main loop or procedure]
   2.1 [Sub-step]
   2.2 [Sub-step]
3. [Return]
```

### Example: AIPW Estimator
```
ALGORITHM: Augmented IPW for Mediation
INPUT:
  - Data (Y, A, M, X) of size n
  - Propensity model specification
  - Outcome model specification
  - Mediator model specification
OUTPUT:
  - Point estimate ψ̂
  - Standard error SE(ψ̂)
  - 95% confidence interval

1. ESTIMATE NUISANCE FUNCTIONS
   1.1 Fit propensity score: π̂(x) = P̂(A=1|X=x)
   1.2 Fit mediator density: f̂(m|a,x)
   1.3 Fit outcome regression: μ̂(a,m,x) = Ê[Y|A=a,M=m,X=x]

2. COMPUTE PSEUDO-OUTCOMES
   For i = 1 to n:
     2.1 Compute IPW weight: w_i = A_i/π̂(X_i) + (1-A_i)/(1-π̂(X_i))
     2.2 Compute outcome prediction: μ̂_i = μ̂(A_i, M_i, X_i)
     2.3 Compute augmentation term
     2.4 φ_i = w_i(Y_i - μ̂_i) + [integration term]

3. ESTIMATE AND INFERENCE
   3.1 ψ̂ = n⁻¹ Σᵢ φ_i
   3.2 SE = √(n⁻¹ Σᵢ (φ_i - ψ̂)²)
   3.3 CI = [ψ̂ - 1.96·SE, ψ̂ + 1.96·SE]

4. RETURN (ψ̂, SE, CI)
```

## Complexity Analysis

### Big-O Notation Guide

**Formal Definition**: $f(n) = O(g(n))$ if $\exists c, n_0$ such that $f(n) \leq c \cdot g(n)$ for all $n \geq n_0$

| Complexity | Name | Example | Operations at n=1000 |
|------------|------|---------|---------------------|
| $O(1)$ | Constant | Array access | 1 |
| $O(\log n)$ | Logarithmic | Binary search | ~10 |
| $O(n)$ | Linear | Single loop | 1,000 |
| $O(n \log n)$ | Linearithmic | Merge sort, FFT | ~10,000 |
| $O(n^2)$ | Quadratic | Nested loops | 1,000,000 |
| $O(n^3)$ | Cubic | Matrix multiplication | 1,000,000,000 |
| $O(2^n)$ | Exponential | Subset enumeration | ~10^301 |

### Key Formulas

**Master Theorem** for recurrences $T(n) = aT(n/b) + f(n)$:
- If $f(n) = O(n^{\log_b a - \epsilon})$ then $T(n) = \Theta(n^{\log_b a})$
- If $f(n) = \Theta(n^{\log_b a})$ then $T(n) = \Theta(n^{\log_b a} \log n)$
- If $f(n) = \Omega(n^{\log_b a + \epsilon})$ then $T(n) = \Theta(f(n))$

**Sorting lower bound**: Any comparison-based sort requires $\Omega(n \log n)$ comparisons

**Matrix operations**:
- Naive multiplication: $O(n^3)$
- Strassen: $O(n^{2.807})$
- Matrix inversion: $O(n^3)$ (same as multiplication)

```r
# Complexity analysis helper
analyze_complexity <- function(f, n_values = c(100, 500, 1000, 5000)) {
  times <- sapply(n_values, function(n) {
    system.time(f(n))[["elapsed"]]
  })

  # Fit log-log regression to estimate complexity
  fit <- lm(log(times) ~ log(n_values))
  estimated_power <- coef(fit)[2]

  list(
    times = data.frame(n = n_values, time = times),
    estimated_complexity = paste0("O(n^", round(estimated_power, 2), ")"),
    power = estimated_power
  )
}
```

### Statistical Algorithm Complexities

| Algorithm | Time | Space |
|-----------|------|-------|
| OLS | O(np² + p³) | O(np) |
| Logistic (Newton) | O(np² + p³) per iter | O(np) |
| Bootstrap (B reps) | O(B × base) | O(n) |
| MCMC (T iters) | O(T × per_iter) | O(n + T) |
| Cross-validation (K) | O(K × base) | O(n) |
| Random forest | O(n log n × B × p) | O(n × B) |

### Template for Analysis
```
TIME COMPLEXITY:
- Initialization: O(...)
- Per iteration: O(...)
- Total (T iterations): O(...)
- Convergence typically in T = O(...) iterations

SPACE COMPLEXITY:
- Data storage: O(n × p)
- Working memory: O(...)
- Output: O(...)
```

## Convergence Analysis

### Types of Convergence
1. **Finite termination**: Exact solution in finite steps
2. **Linear**: $\|x_{k+1} - x^*\| \leq c\|x_k - x^*\|$, $c < 1$
3. **Superlinear**: $\|x_{k+1} - x^*\| / \|x_k - x^*\| \to 0$
4. **Quadratic**: $\|x_{k+1} - x^*\| \leq c\|x_k - x^*\|^2$

### Convergence Documentation Template
```
CONVERGENCE:
- Type: [Linear/Superlinear/Quadratic]
- Rate: [Expression]
- Conditions: [What must hold]
- Stopping criterion: [When to stop]
- Typical iterations: [Order of magnitude]
```

## Optimization Algorithms

### Gradient-Based Methods
```
ALGORITHM: Gradient Descent
INPUT: f (objective), ∇f (gradient), x₀ (initial), η (step size), ε (tolerance)
OUTPUT: x* (minimizer)

1. k ← 0
2. WHILE ‖∇f(xₖ)‖ > ε:
   2.1 xₖ₊₁ ← xₖ - η∇f(xₖ)
   2.2 k ← k + 1
3. RETURN xₖ

COMPLEXITY: O(iterations × gradient_cost)
CONVERGENCE: Linear with rate (1 - η·μ) for μ-strongly convex f
```

### Newton's Method
```
ALGORITHM: Newton-Raphson
INPUT: f, ∇f, ∇²f, x₀, ε
OUTPUT: x*

1. k ← 0
2. WHILE ‖∇f(xₖ)‖ > ε:
   2.1 Solve ∇²f(xₖ)·d = -∇f(xₖ) for direction d
   2.2 xₖ₊₁ ← xₖ + d
   2.3 k ← k + 1
3. RETURN xₖ

COMPLEXITY: O(iterations × p³) for p-dimensional
CONVERGENCE: Quadratic near solution
```

### EM Algorithm Template
```
ALGORITHM: Expectation-Maximization
INPUT: Data Y, model parameters θ₀, tolerance ε
OUTPUT: MLE θ̂

1. θ ← θ₀
2. REPEAT:
   2.1 E-STEP: Compute Q(θ'|θ) = E[log L(θ'|Y,Z) | Y, θ]
   2.2 M-STEP: θ_new ← argmax_θ' Q(θ'|θ)
   2.3 Δ ← |θ_new - θ|
   2.4 θ ← θ_new
3. UNTIL Δ < ε
4. RETURN θ

CONVERGENCE: Monotonic increase in likelihood
             Linear rate near optimum
```

## Bootstrap Algorithms

### Nonparametric Bootstrap
```
ALGORITHM: Nonparametric Bootstrap
INPUT: Data X of size n, statistic T, B (number of replicates)
OUTPUT: SE estimate, CI

1. FOR b = 1 to B:
   1.1 Draw X*_b by sampling n observations with replacement from X
   1.2 Compute T*_b = T(X*_b)
2. SE_boot ← SD({T*_1, ..., T*_B})
3. CI_percentile ← [quantile(T*, 0.025), quantile(T*, 0.975)]
4. RETURN (SE_boot, CI_percentile)

COMPLEXITY: O(B × cost(T))
NOTES: B ≥ 1000 for SE, B ≥ 10000 for percentile CI
```

### Parametric Bootstrap
```
ALGORITHM: Parametric Bootstrap
INPUT: Data X, parametric model M, B replicates
OUTPUT: SE estimate

1. Fit θ̂ = MLE(X, M)
2. FOR b = 1 to B:
   2.1 Generate X*_b ~ M(θ̂)
   2.2 Compute θ̂*_b = MLE(X*_b, M)
3. SE_boot ← SD({θ̂*_1, ..., θ̂*_B})
4. RETURN SE_boot
```

## Numerical Stability Notes

### Common Issues
1. **Overflow/Underflow**: Work on log scale
2. **Cancellation**: Reformulate subtractions
3. **Ill-conditioning**: Use regularization or pivoting
4. **Convergence**: Add damping or line search

### Stability Techniques
```r
# Log-sum-exp trick
log_sum_exp <- function(x) {
  max_x <- max(x)
  max_x + log(sum(exp(x - max_x)))
}

# Numerically stable variance
stable_var <- function(x) {
  n <- length(x)
  m <- mean(x)
  sum((x - m)^2) / (n - 1)  # One-pass with correction
}
```

## Implementation Checklist

### Before Coding
- [ ] Pseudocode written and reviewed
- [ ] Complexity analyzed
- [ ] Convergence conditions identified
- [ ] Edge cases documented
- [ ] Numerical stability considered

### During Implementation
- [ ] Match pseudocode structure
- [ ] Add convergence monitoring
- [ ] Handle edge cases
- [ ] Log intermediate values (debug mode)
- [ ] Add early stopping

### After Implementation
- [ ] Unit tests for components
- [ ] Integration tests for full algorithm
- [ ] Benchmark against reference implementation
- [ ] Profile for bottlenecks
- [ ] Document deviations from pseudocode

## Key References

- CLRS
- Numerical Recipes