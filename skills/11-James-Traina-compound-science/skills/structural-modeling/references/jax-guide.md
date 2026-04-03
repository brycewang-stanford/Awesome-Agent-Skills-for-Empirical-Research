# JAX for Structural Estimation

JAX provides automatic differentiation and JIT compilation — valuable for structural models where analytic gradients are tedious.

```python
import jax
import jax.numpy as jnp
from jax import grad, jit

@jit
def bellman_operator(EV, theta, beta, trans_mat):
    """JAX-compatible Bellman operator with autodiff support."""
    RC, theta1 = theta[0], theta[1]
    n_states = EV.shape[0]

    flow_maintain = -theta1 * jnp.arange(n_states, dtype=float)
    cv_maintain = flow_maintain + beta * trans_mat @ EV
    cv_replace = -RC + beta * trans_mat[0, :] @ EV

    # logsumexp for numerical stability
    EV_new = jnp.logaddexp(cv_maintain, cv_replace)
    return EV_new

# Automatic gradient of the objective w.r.t. parameters
# — no hand-derived gradients needed
grad_objective = jit(grad(nfxp_objective_jax, argnums=0))
```

**When to use JAX:**
- Models with many parameters (gradient computation is expensive)
- Need second derivatives (Hessian) for standard errors or Newton steps
- Inner loop can be expressed as a differentiable fixed-point iteration
- Want GPU acceleration for large state spaces

**When NOT to use JAX:**
- Simple models where scipy.optimize works fine
- Models with non-differentiable components (discrete jumps, if-else logic)
- PyBLP already handles the specific model class

## vmap for Simulated Moments

JAX's `vmap` vectorizes computation over simulation draws — useful for MSM and simulated MLE:

```python
from jax import vmap

# Simulate moments for each draw in parallel (no Python loop)
simulate_one = lambda draw: compute_moments(theta, draw)
all_moments = vmap(simulate_one)(simulation_draws)  # (R, n_moments)
simulated_moments = all_moments.mean(axis=0)
```

## Fixed-Point Iteration with JAX

For differentiating through contraction mappings (e.g., BLP inversion, Bellman iteration):

```python
from jax.lax import while_loop

def contraction_jax(ev0, theta, beta, trans_mat, tol=1e-12):
    """Differentiable fixed-point via lax.while_loop."""
    def cond_fn(state):
        ev, ev_prev, _ = state
        return jnp.max(jnp.abs(ev - ev_prev)) > tol

    def body_fn(state):
        ev, _, i = state
        ev_new = bellman_operator(ev, theta, beta, trans_mat)
        return ev_new, ev, i + 1

    ev_init = jnp.zeros(trans_mat.shape[0])
    ev_final, _, n_iter = while_loop(cond_fn, body_fn, (ev_init, ev_init + 1.0, 0))
    return ev_final
```
