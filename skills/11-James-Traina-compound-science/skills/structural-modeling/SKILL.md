---
name: structural-modeling
argument-hint: "<model type or estimation problem>"
description: >-
  This skill covers structural econometric models. Use when the user is building, estimating, or debugging structural models — including BLP demand estimation, dynamic discrete choice, auction models, or any workflow involving moment conditions, nested fixed-point algorithms, or MPEC formulations. Triggers on "structural model", "moment conditions", "NFXP", "MPEC", "BLP", "random coefficients", "dynamic discrete choice", "CCP", "Rust model", "auction estimation", "GMM objective", "inner loop", "contraction mapping", or convergence/starting value problems in optimization-based estimation.
---

# Structural Modeling

Reference for implementing structural econometric models: from economic model to moment conditions to estimated parameters. Covers the full workflow of taking a theoretical model, deriving its empirical content, and recovering structural parameters from data.

## When to Use This Skill

Use when the user is:
- Specifying a structural model and deriving moment conditions
- Implementing NFXP or MPEC estimation routines
- Working with BLP-style demand systems (random coefficients logit)
- Building dynamic discrete choice models (Rust, Hotz-Miller CCP)
- Estimating auction models (first-price, ascending, common value)
- Debugging convergence failures in structural estimation
- Choosing between estimation approaches for a given model

Skip when:
- The task is reduced-form causal inference (use `causal-inference` skill)
- The task is pure simulation design (use `numerical-auditor` agent)
- The user just needs standard regression (statsmodels/linearmodels suffice)

## Quick Reference: Structural Methods

| Method | Use Case | Key Package | Estimator |
|--------|----------|-------------|-----------|
| NFXP | Dynamic discrete choice (small state space) | `scipy.optimize` | MLE / GMM |
| MPEC | Dynamic discrete choice (large state space, slow inner loop) | `cyipopt` (IPOPT) | MLE / GMM |
| BLP | Differentiated products demand with RC logit | `pyblp` | GMM (2-step) |
| CCP (Hotz-Miller) | Dynamic models, counterfactuals not needed | `scipy` | 2-step semiparametric |
| GPV | First-price auctions, nonparametric values | `scipy` | Nonparametric |
| Ascending auction | English auctions, private values | `scipy` | MLE on order statistics |

## The Structural Estimation Workflow

Every structural estimation follows the same logical arc:

```
Economic Model → Equilibrium/Decision Rule → Observable Implications
    → Moment Conditions → Estimator → Optimization → Inference
```

### Step 1: Model Specification

Define primitives clearly before writing any code:

```python
# model_spec.py — Document structural primitives
"""
Model: Single-agent optimal stopping (Rust 1987 bus engine replacement)

State:    x_t ∈ {0, 1, ..., X_max}  (mileage bin)
Action:   a_t ∈ {0, 1}  (0 = maintain, 1 = replace)
Flow payoff:
    u(x, 0; θ) = -θ_1 * x - θ_2 * x²     (maintenance cost)
    u(x, 1; θ) = -RC                        (replacement cost)
Discount:  β = 0.9999 (fixed)
Shocks:    ε ~ Type 1 Extreme Value (logit errors)
"""
```

Document these before writing estimation code: agents, information, timing, payoff functional form, equilibrium concept.

### Step 2: Derive Moment Conditions

| Source | Example | Estimator |
|--------|---------|-----------|
| Optimality conditions (FOCs) | Euler equations, Bellman optimality | GMM |
| Equilibrium restrictions | Market clearing, Nash conditions | GMM / ML |
| Distributional assumptions | Choice probabilities under logit errors | MLE |
| Exclusion restrictions | Cost shifters excluded from demand | IV-GMM |

**Key question:** Just-identified → method of moments; over-identified → GMM with optimal weighting matrix; under-identified → revisit assumptions.

## NFXP vs MPEC

Two dominant paradigms for models with latent quantities (unobserved heterogeneity, future expectations, equilibrium objects):

**NFXP (Nested Fixed-Point):** Solve the model in an inner loop for each parameter guess, evaluate likelihood/moments in an outer loop. Conceptually simple; inner loop must fully converge at every iteration — requires tight tolerance (1e-12, not 1e-6; see Su & Judd 2012).

**MPEC (Mathematical Programming with Equilibrium Constraints):** Reformulate as a single constrained optimization. No inner loop — solver handles everything; can be faster for large state spaces; requires IPOPT or KNITRO.

| Factor | Favors NFXP | Favors MPEC |
|--------|-------------|-------------|
| State space | Small (< 500 states) | Large (> 1000 states) |
| Inner loop | Fast convergence (rate < 0.9) | Slow or fragile |
| Solver availability | `scipy.optimize` sufficient | IPOPT/KNITRO available |
| Debugging | Easier — isolate inner vs outer | Harder to diagnose constraint violations |

For full NFXP and MPEC code (Rust 1987 bus engine model), see `references/estimation-methods.md`.

## BLP Demand Estimation

BLP (Berry, Levinsohn, Pakes 1995) is the workhorse for differentiated products demand. Use PyBLP whenever possible — it handles the difficult numerical details correctly.

```python
import pyblp

# Define the problem
problem = pyblp.Problem(
    product_formulations=(
        pyblp.Formulation('1 + prices + x1 + x2'),       # linear (β)
        pyblp.Formulation('1 + prices + x1'),              # random coefficients (Σ)
    ),
    product_data=product_data,
    agent_data=agent_data
)

# Solve — always use multiple starting values; BLP objective is non-convex
results = problem.solve(
    sigma=sigma_init,
    optimization=pyblp.Optimization('l-bfgs-b', {'gtol': 1e-8}),
    iteration=pyblp.Iteration('squarem', {'atol': 1e-14}),
    method='2s'
)
```

For the full multi-start loop, two-step GMM, elasticity checks, instrument selection, and marginal cost computation, see `references/estimation-methods.md`.

**BLP Diagnostics Checklist:**
- [ ] First-stage F > 10 for price instruments
- [ ] Run 10+ random starts (objective is non-convex)
- [ ] Own-price elasticities all negative: `results.compute_elasticities('prices')`
- [ ] All markets converged: `results.fp_converged.all()`
- [ ] Marginal costs positive: `results.compute_costs()`
- [ ] Inner loop atol <= 1e-14 (tighter is safer)

## Dynamic Discrete Choice

**Rust (1987) NFXP:** Full solution — solve the Bellman equation by value function iteration at every outer iteration. Use for models where counterfactuals require the full model.

**Hotz-Miller CCP:** Two-step semiparametric approach. Step 1: estimate conditional choice probabilities nonparametrically. Step 2: form pseudo-value functions for a linear regression. Faster; less efficient; sufficient when counterfactuals are not needed.

| Feature | Full Solution (NFXP/MPEC) | CCP (Hotz-Miller) |
|---------|---------------------------|---------------------|
| Computational cost | High (solve DP at each θ) | Low (no DP solving) |
| Efficiency | Efficient (MLE) | Less efficient (2-step) |
| Counterfactuals | Natural (full model available) | Must resolve for new policies |

For full CCP implementation code, see `references/estimation-methods.md`.

## Auction Models

**First-price sealed-bid (GPV):** Guerre, Perrigne, Vuong (2000) — invert the bidding equilibrium condition v(b) = b + G(b)/((n-1)g(b)) to recover latent values nonparametrically from observed bids.

**Ascending (English):** In IPV setting, transaction price = second-highest value. Use MLE on order statistics to recover the value distribution.

**Common value:** Requires accounting for winner's curse. Li-Perrigne-Vuong (2002) approach; typically requires parametric assumptions.

For full GPV estimator code, ascending auction MLE, and validation diagnostics, see `references/estimation-methods.md`.

## Method Selection

**When to use structural vs. reduced-form:**
- Structural: Need to evaluate counterfactual policies, recover preference parameters, or model strategic interactions
- Reduced-form: Need a credible causal estimate of a specific treatment effect with minimal assumptions

**Within structural:**
1. Static discrete choice with heterogeneity? → BLP / mixed logit
2. Dynamic single-agent optimal stopping? → NFXP (small state) or MPEC (large state)
3. Counterfactuals not needed, data rich? → CCP estimator
4. Auction data? → GPV (first-price) or order statistics MLE (ascending)
5. Market-level entry/exit? → Bresnahan-Reiss or Ciliberto-Tamer (see `game-theory` skill)

## Common Anti-Patterns

| Anti-Pattern | Problem | Better Approach |
|--------------|---------|-----------------|
| Estimating β jointly with payoff parameters | Notoriously poorly identified; flat objective | Fix β at reasonable value (0.95, 0.99) or calibrate externally |
| Loose inner loop tolerance (1e-6) | Optimizer sees noise; spurious convergence | Use 1e-12 or tighter; see Su & Judd (2012) |
| Single starting value | Structural objectives are non-convex | Use 10+ random starts plus grid search |
| Ignoring simulation error in simulated MLE/MSM | Biased standard errors | Use enough draws (R >> N) or bias-correct |
| Numerical gradients with default step size | Inaccurate for poorly scaled problems | Use central differences or analytic gradients (JAX) |
| Hard-coding state space discretization | Results sensitive to grid coarseness | Test sensitivity to grid refinement |

## JAX Acceleration

For GPU-accelerated structural estimation (JIT compilation, autodiff, vmap for simulated moments, differentiable fixed-point iteration with `lax.while_loop`), see `references/jax-guide.md`.

## Integration with compound-science

- `numerical-auditor` — Systematic convergence review: gradient norms, conditioning, tolerance sensitivity
- `numerical-auditor` — DGP formalization, Monte Carlo studies, convergence review
- `identification-critic` — Verify equilibrium existence, uniqueness, stability, comparative statics
- `econometric-reviewer` — Reviews moment-matching strategy, parameter identification, sensitivity to targets
- `/estimate` — Full estimation pipeline with quality gates

## Additional References

- `references/estimation-methods.md` — Full code: BLP multi-start, NFXP Bellman solver, MPEC cyipopt formulation, Hotz-Miller CCP, GPV auction estimator
- `references/diagnostics-and-se.md` — Convergence failure diagnosis, numerical safeguards (logsumexp, conditioning), GMM sandwich SEs, parametric bootstrap
- `references/jax-guide.md` — JAX JIT/autodiff for structural objectives, vmap for simulation, lax.while_loop for differentiable contraction mappings
