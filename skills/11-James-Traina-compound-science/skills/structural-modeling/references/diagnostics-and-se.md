# Convergence Diagnostics and Standard Errors for Structural Models

## Convergence Diagnostics

Convergence failures are the most common problem in structural estimation.

### Starting Values

```python
# Strategy 1: Grid search over coarse parameter space
from itertools import product

param_grid = {
    'RC': [2.0, 5.0, 10.0, 20.0],
    'theta1': [0.001, 0.01, 0.05, 0.1]
}

best_obj = np.inf
best_start = None
for RC, theta1 in product(param_grid['RC'], param_grid['theta1']):
    try:
        obj = nfxp_objective([RC, theta1], data, beta, trans_mat, n_states)
        if obj < best_obj:
            best_obj = obj
            best_start = [RC, theta1]
    except (ValueError, np.linalg.LinAlgError):
        continue

# Strategy 2: Estimate simplified model first
# e.g., static version, or version without random coefficients

# Strategy 3: Use estimates from related data/specification
```

### Diagnosing Convergence Failures

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Optimizer reports convergence but objective varies across starts | Multiple local optima | Run from 20+ random starts, use global optimizer (basin-hopping) |
| Inner loop doesn't converge | Contraction rate near 1, discount factor too high | Accelerate with SQUAREM, reduce β, check transition matrix |
| Gradient is NaN or Inf | Log of zero, overflow in exp | Work in log space, add numerical safeguards |
| Hessian is singular at solution | Flat objective, identification failure | Check rank of Jacobian of moment conditions at solution |
| Parameters hit bounds | Misspecification or poor starting values | Widen bounds, check model, try unconstrained reparameterization |
| Objective decreases but very slowly | Poorly scaled problem | Rescale parameters to similar magnitudes, use preconditioner |

### Numerical Safeguards

```python
# Always work in log space for likelihoods
def safe_log_likelihood(log_prob):
    """Numerically stable log-likelihood computation."""
    return np.sum(log_prob)  # already in log space

# Use logsumexp for softmax/logit choice probabilities
from scipy.special import logsumexp

def logit_choice_probs(utilities):
    """Numerically stable logit probabilities."""
    # utilities: (n_states, n_actions)
    log_denom = logsumexp(utilities, axis=1, keepdims=True)
    log_probs = utilities - log_denom
    return np.exp(log_probs)

# Check condition number of key matrices
def check_conditioning(matrix, name="matrix"):
    cond = np.linalg.cond(matrix)
    if cond > 1e10:
        print(f"WARNING: {name} condition number = {cond:.2e} — near singular")
    return cond
```

## Standard Errors for Structural Models

### GMM Standard Errors

```python
def gmm_standard_errors(theta_hat, moment_fn, data, W, epsilon=1e-5):
    """
    Sandwich standard errors for GMM.

    V(θ) = (G'WG)^{-1} G'W S W G (G'WG)^{-1} / N

    G = Jacobian of moment conditions (∂m/∂θ)
    S = Variance of moment conditions
    W = Weighting matrix
    """
    n_params = len(theta_hat)
    moments = moment_fn(theta_hat, data)  # (N, n_moments)
    N = moments.shape[0]

    # Numerical Jacobian
    G = np.zeros((moments.shape[1], n_params))
    for j in range(n_params):
        theta_plus = theta_hat.copy()
        theta_minus = theta_hat.copy()
        theta_plus[j] += epsilon
        theta_minus[j] -= epsilon
        G[:, j] = (moment_fn(theta_plus, data).mean(axis=0)
                    - moment_fn(theta_minus, data).mean(axis=0)) / (2 * epsilon)

    # Long-run variance of moments
    S = moments.T @ moments / N

    # Sandwich formula
    GWG_inv = np.linalg.inv(G.T @ W @ G)
    V = GWG_inv @ (G.T @ W @ S @ W @ G) @ GWG_inv / N

    se = np.sqrt(np.diag(V))
    return se
```

### Bootstrap for Complex Models

When analytic standard errors are difficult (e.g., multi-step estimators, simulation-based estimators):

```python
def parametric_bootstrap(estimate_fn, data, n_bootstrap=200, seed=42):
    """
    Parametric bootstrap: resample from estimated model.
    For structural models, often better than nonparametric bootstrap
    because it preserves the data structure (markets, panels).
    """
    rng = np.random.default_rng(seed)
    theta_hat = estimate_fn(data)

    boot_estimates = []
    for b in range(n_bootstrap):
        # Resample: cluster at appropriate level (market, individual, etc.)
        idx = rng.choice(len(data), size=len(data), replace=True)
        data_b = data.iloc[idx].reset_index(drop=True)

        try:
            theta_b = estimate_fn(data_b)
            boot_estimates.append(theta_b)
        except Exception:
            continue  # skip failed replications but log the count

    boot_estimates = np.array(boot_estimates)
    se = boot_estimates.std(axis=0)

    # Report: how many bootstrap replications converged
    convergence_rate = len(boot_estimates) / n_bootstrap
    if convergence_rate < 0.8:
        print(f"WARNING: Only {convergence_rate:.0%} of bootstrap samples converged")

    return se, boot_estimates
```
