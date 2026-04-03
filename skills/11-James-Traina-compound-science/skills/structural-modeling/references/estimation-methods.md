# Structural Modeling: Full Estimation Method Code

Full implementation code for BLP demand estimation, NFXP/MPEC dynamic discrete choice, and auction models. Referenced from `SKILL.md`.

---

## BLP Demand Estimation (Full)

### Problem Setup

```python
import pyblp

# Define the problem
problem = pyblp.Problem(
    product_formulations=(
        pyblp.Formulation('1 + prices + x1 + x2'),           # linear (β)
        pyblp.Formulation('1 + prices + x1'),                  # random coefficients (Σ)
        pyblp.Formulation('0 + demand_instruments0 + demand_instruments1')  # supply
    ),
    product_data=product_data,  # DataFrame with market_ids, shares, prices, etc.
    agent_formulation=pyblp.Formulation('0 + income'),         # demographics
    agent_data=agent_data
)
```

### Estimation with Multiple Starting Values

```python
import numpy as np

# Starting values matter — use multiple starting points
results_best = None
for _ in range(10):
    sigma_init = np.random.uniform(0.1, 2.0, size=(3, 3))
    sigma_init = np.tril(sigma_init)  # lower triangular for Cholesky

    results = problem.solve(
        sigma=sigma_init,
        optimization=pyblp.Optimization('l-bfgs-b', {'gtol': 1e-8}),
        iteration=pyblp.Iteration('squarem', {'atol': 1e-14}),  # accelerated contraction
        method='1s'  # start with 1-step GMM, then switch to 2-step
    )

    if results_best is None or results.objective < results_best.objective:
        results_best = results

# Two-step GMM with optimal weighting matrix
results_2s = problem.solve(
    sigma=results_best.sigma,
    optimization=pyblp.Optimization('l-bfgs-b', {'gtol': 1e-8}),
    iteration=pyblp.Iteration('squarem', {'atol': 1e-14}),
    method='2s',
    W=results_best.updated_W
)
```

### BLP Post-Estimation Checks

```python
# Own-price elasticities: must be negative
elasticities = results_2s.compute_elasticities('prices')
print("Own-price elasticities (diagonal):", np.diag(elasticities).describe())
assert (np.diag(elasticities) < 0).all(), "Some own-price elasticities are positive!"

# Cross-price elasticities: should be positive for substitutes
diversion = results_2s.compute_diversion_ratios()

# Marginal costs: must be positive
costs = results_2s.compute_costs()
assert (costs > 0).all(), "Negative marginal costs — check instruments or supply-side spec"

# Check inner loop convergence
assert results_2s.fp_converged.all(), "Not all markets converged in contraction mapping"
print(f"Contraction evaluations: {results_2s.contraction_evaluations.sum()}")

# Optimal instruments (improves efficiency)
updated_instruments = results_2s.compute_optimal_instruments(method='approximate')
```

### BLP Instruments

Standard BLP instruments and when to use them:

| Instrument Type | Formula | When to Use |
|----------------|---------|-------------|
| BLP (own-firm) | Sum of own characteristics (excl. product j) | Standard — characteristics of other products by same firm |
| BLP (rival) | Sum of rival characteristics | Standard — characteristics of competing firms |
| Hausman | Prices in other markets | Multi-market data; requires independent markets |
| Cost shifters | Input prices, wages | Supply-side IV when cost data available |
| Optimal IV | E[∂ξ/∂θ \| Z] | Requires consistent first-stage; improves efficiency |

---

## NFXP Implementation (Full)

### Inner Loop: Bellman Contraction

```python
import numpy as np
from scipy.optimize import minimize

def solve_inner(theta, beta, trans_mat, n_states):
    """Solve Bellman equation by value function iteration (contraction mapping)."""
    RC, theta1 = theta
    flow_maintain = -theta1 * np.arange(n_states)
    EV = np.zeros(n_states)

    for _ in range(2000):  # generous iteration limit
        # Choice-specific value functions (logit shocks)
        cv_maintain = flow_maintain + beta * trans_mat @ EV
        cv_replace = -RC + beta * trans_mat[0, :] @ EV

        # Log-sum formula for expected value with Type 1 EV errors
        EV_new = np.log(np.exp(cv_maintain) + np.exp(cv_replace))

        if np.max(np.abs(EV_new - EV)) < 1e-12:  # tight tolerance (Su & Judd 2012)
            break
        EV = EV_new

    return EV

def nfxp_objective(theta, data, beta, trans_mat, n_states):
    """Negative log-likelihood for NFXP."""
    EV = solve_inner(theta, beta, trans_mat, n_states)
    RC, theta1 = theta

    flow_maintain = -theta1 * np.arange(n_states)
    cv_maintain = flow_maintain + beta * trans_mat @ EV
    cv_replace = -RC + beta * trans_mat[0, :] @ EV

    # Choice probabilities (logit)
    prob_replace = 1 / (1 + np.exp(cv_maintain - cv_replace))

    # Log-likelihood
    ll = np.sum(
        data['replace'] * np.log(prob_replace[data['state']] + 1e-15)
        + (1 - data['replace']) * np.log(1 - prob_replace[data['state']] + 1e-15)
    )
    return -ll

result = minimize(nfxp_objective, x0=[5.0, 0.01],
                  args=(data, beta, trans_mat, n_states),
                  method='Nelder-Mead',
                  options={'xatol': 1e-8, 'fatol': 1e-10})
```

---

## MPEC Implementation (Full)

### MPEC Formulation with cyipopt

```python
import cyipopt
import numpy as np

class RustMPEC:
    """MPEC formulation of Rust (1987) bus engine model."""

    def __init__(self, data, beta, trans_mat, n_states):
        self.data = data
        self.beta = beta
        self.trans = trans_mat
        self.n_states = n_states
        # Decision variables: [RC, theta1, EV_0, ..., EV_{n-1}]
        self.n_vars = 2 + n_states

    def objective(self, x):
        """Negative log-likelihood."""
        RC, theta1 = x[0], x[1]
        EV = x[2:]

        flow_maintain = -theta1 * np.arange(self.n_states)
        cv_m = flow_maintain + self.beta * self.trans @ EV
        cv_r = -RC + self.beta * self.trans[0, :] @ EV

        prob_r = 1 / (1 + np.exp(cv_m - cv_r))
        ll = np.sum(
            self.data['replace'] * np.log(prob_r[self.data['state']] + 1e-15)
            + (1 - self.data['replace']) * np.log(1 - prob_r[self.data['state']] + 1e-15)
        )
        return -ll

    def gradient(self, x):
        """Gradient of objective (use autodiff in practice)."""
        # In practice, compute via JAX: jax.grad(self.objective)(x)
        raise NotImplementedError("Use JAX autodiff for gradient")

    def constraints(self, x):
        """Bellman equation constraints: EV = log-sum-exp(CV)."""
        RC, theta1 = x[0], x[1]
        EV = x[2:]

        flow_maintain = -theta1 * np.arange(self.n_states)
        cv_m = flow_maintain + self.beta * self.trans @ EV
        cv_r = -RC + self.beta * self.trans[0, :] @ EV

        EV_implied = np.log(np.exp(cv_m) + np.exp(cv_r))
        return EV - EV_implied  # should equal zero at solution

    def jacobianstructure(self):
        """Sparsity structure of the constraint Jacobian."""
        # Constraints: n_states equations
        # Variables: 2 structural params + n_states EV values
        rows = np.repeat(np.arange(self.n_states), self.n_states + 2)
        cols = np.tile(np.arange(self.n_vars), self.n_states)
        return rows, cols


# Run MPEC via cyipopt
mpec_problem = RustMPEC(data, beta, trans_mat, n_states)
x0 = np.concatenate([[5.0, 0.01], np.zeros(n_states)])  # initial point
bounds_lower = np.concatenate([[0.0, 0.0], -np.inf * np.ones(n_states)])
bounds_upper = np.concatenate([[np.inf, np.inf], np.inf * np.ones(n_states)])
constraint_lower = np.zeros(n_states)  # equality constraints
constraint_upper = np.zeros(n_states)

nlp = cyipopt.Problem(
    n=mpec_problem.n_vars,
    m=n_states,
    problem_obj=mpec_problem,
    lb=bounds_lower, ub=bounds_upper,
    cl=constraint_lower, cu=constraint_upper
)
nlp.add_option('tol', 1e-10)
nlp.add_option('max_iter', 1000)
x_opt, info = nlp.solve(x0)
```

---

## Hotz-Miller CCP Estimation (Full)

```python
import numpy as np

def hotz_miller_ccp(data, n_states, n_actions, beta, trans_mat):
    """
    Hotz-Miller (1993) CCP estimator.
    Step 1: Estimate CCPs nonparametrically.
    Step 2: Use CCPs to form pseudo-value functions, then run simple regression.
    """
    # Step 1: Estimate CCPs from frequency of actions in each state
    ccps = np.zeros((n_states, n_actions))
    for s in range(n_states):
        mask = data['state'] == s
        if mask.sum() > 0:
            for a in range(n_actions):
                ccps[s, a] = (data['action'][mask] == a).mean()

    # Smooth to avoid log(0) — add small probability mass
    ccps = np.clip(ccps, 0.001, 0.999)
    ccps = ccps / ccps.sum(axis=1, keepdims=True)

    # Step 2: Construct pseudo-value functions
    # With logit errors: E[ε | a chosen] = euler_constant - log(P(a))
    euler = 0.5772156649

    # Forward simulation of CCPs to get expected future utilities
    e_eps = euler - np.log(ccps[:, 0])  # expected shock conditional on maintain

    # Mapping matrix: expected transitions under estimated policy
    F = np.diag(ccps[:, 0]) @ trans_mat + np.diag(ccps[:, 1]) @ trans_mat[[0], :]

    # Pseudo-value: (I - beta * F)^{-1} * (flow_payoff + correction)
    # This gives a linear-in-parameters system for the structural parameters

    return ccps, F
```

---

## Auction Models (Full)

### First-Price Sealed-Bid: GPV Estimator

```python
from scipy.interpolate import UnivariateSpline
from scipy.stats import gaussian_kde
import numpy as np

def gpv_estimate(bids, n_bidders):
    """
    GPV (2000) nonparametric estimation for symmetric IPV first-price auctions.

    Key insight: In equilibrium, bidder with value v bids:
        b(v) = v - G(b)/(n-1)*g(b)
    where G is the bid distribution and g its density.

    Inversion: v(b) = b + G(b)/((n-1)*g(b))
    """
    n = n_bidders

    # Step 1: Estimate bid distribution and density
    kde = gaussian_kde(bids, bw_method='silverman')

    # Evaluate on a grid
    b_grid = np.linspace(bids.min(), bids.max(), 200)
    g_hat = kde(b_grid)                                    # density
    G_hat = np.array([kde.integrate_box_1d(-np.inf, b) for b in b_grid])  # CDF

    # Step 2: Invert to recover pseudo-values
    v_hat = b_grid + G_hat / ((n - 1) * g_hat)

    # Step 3: Estimate value distribution from pseudo-values
    # (can use kernel density on v_hat, or fit parametric family)

    return b_grid, v_hat, g_hat, G_hat


def validate_gpv(bids, v_hat):
    """Diagnostics for GPV estimator."""
    # Pseudo-values must exceed bids (bidders shade down in equilibrium)
    assert (v_hat >= bids[:len(v_hat)]).all(), "Some pseudo-values below bids"

    # Check for negative values in cost auctions
    if v_hat.min() < 0:
        print("Warning: negative pseudo-values — check support assumption")

    # Boundary bias check
    print(f"Fraction of grid at boundaries: {(v_hat == v_hat[0]).mean():.3f}")
```

### Ascending (English) Auction Estimation

```python
from scipy.stats import rv_continuous
from scipy.optimize import minimize
import numpy as np

# Transaction prices = second-order statistics of value distribution
# Use order statistics theory to recover the parent distribution

# With N bidders, transaction price ~ F_{(N-1:N)} distribution
# f_{(k:n)}(x) = n!/(k-1)!(n-k)! * F(x)^{k-1} * (1-F(x))^{n-k} * f(x)

def order_stat_density(x, params, n_bidders, dist='lognormal'):
    """Density of the (n-1)-th order statistic for lognormal values."""
    from scipy.stats import lognorm
    k = n_bidders - 1  # second-highest
    n = n_bidders
    mu, sigma = params

    # Lognormal: F and f
    F = lognorm.cdf(x, s=sigma, scale=np.exp(mu))
    f = lognorm.pdf(x, s=sigma, scale=np.exp(mu))

    # Order statistic density
    coeff = np.math.factorial(n) / (np.math.factorial(k-1) * np.math.factorial(n-k))
    return coeff * F**(k-1) * (1-F)**(n-k) * f

def ascending_mle(prices, n_bidders):
    """MLE for value distribution from ascending auction prices."""
    def neg_ll(params):
        densities = np.array([order_stat_density(p, params, n_bidders) for p in prices])
        densities = np.clip(densities, 1e-15, None)
        return -np.sum(np.log(densities))

    result = minimize(neg_ll, x0=[np.log(prices.mean()), 0.5],
                      method='Nelder-Mead', options={'xatol': 1e-8})
    return result
```

### Auction Model Selection

| Model | Key Assumption | Estimation Approach |
|-------|---------------|---------------------|
| First-price IPV | Private values, symmetric | GPV nonparametric or MLE |
| Ascending IPV | Private values, dominant strategy | MLE on order statistics |
| Common value | Shared value component, winner's curse | Li-Perrigne-Vuong (2002), parametric |
| Asymmetric IPV | Different value distributions | Numerical equilibrium, then MLE |
| Multi-unit | Multiple units sold | More complex — see Athey-Haile (2007) |
