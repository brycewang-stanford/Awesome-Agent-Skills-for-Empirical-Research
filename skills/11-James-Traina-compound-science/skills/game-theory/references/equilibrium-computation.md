# Equilibrium Computation — Implementation Reference

## Best-Response Iteration

For symmetric games or games with a unique equilibrium, best-response iteration often converges to Nash:

```python
import numpy as np

def best_response_iteration(payoff_matrix, tol=1e-10, max_iter=10000):
    """
    Best-response iteration for 2-player symmetric games.

    payoff_matrix: (n_actions, n_actions) — row player's payoffs
    Assumes row = column (symmetric game).
    """
    n = payoff_matrix.shape[0]

    # Start with uniform mixed strategy
    p = np.ones(n) / n   # row player's mixed strategy
    q = np.ones(n) / n   # column player's mixed strategy

    for iteration in range(max_iter):
        # Column player's best response to p
        expected_payoffs_col = payoff_matrix.T @ p
        q_new = np.zeros(n)
        q_new[np.argmax(expected_payoffs_col)] = 1.0

        # Row player's best response to q_new
        expected_payoffs_row = payoff_matrix @ q_new
        p_new = np.zeros(n)
        p_new[np.argmax(expected_payoffs_row)] = 1.0

        if np.max(np.abs(p_new - p)) < tol and np.max(np.abs(q_new - q)) < tol:
            return p_new, q_new, iteration

        p, q = p_new, q_new

    raise RuntimeError(f"Best-response iteration did not converge in {max_iter} iterations")

# Example: Prisoner's Dilemma
# Strategies: [Cooperate, Defect]
pd_payoffs = np.array([
    [3, 0],   # Cooperate vs (Cooperate, Defect)
    [5, 1],   # Defect vs (Cooperate, Defect)
])
# Dominant strategy: Defect — iteration converges immediately
p_eq, q_eq, iters = best_response_iteration(pd_payoffs)
print(f"Equilibrium: row={p_eq}, col={q_eq} (converged in {iters} iterations)")
```

**Caveat:** Iteration is not guaranteed to converge to a mixed-strategy Nash equilibrium — it converges to pure-strategy Nash equilibria when they exist and are stable. For mixed equilibria, use support enumeration or nashpy.

## Support Enumeration (nashpy)

For small 2-player games, nashpy implements support enumeration to find all Nash equilibria:

```python
import nashpy as nash
import numpy as np

# Define a 2-player game
# Row player's payoff matrix A, column player's B
A = np.array([[3, 0], [5, 1]])   # Row player (Prisoner's Dilemma)
B = np.array([[3, 5], [0, 1]])   # Column player (transpose of A for symmetric game)

game = nash.Game(A, B)

# Find ALL Nash equilibria via support enumeration
equilibria = list(game.support_enumeration())
for i, (sigma_r, sigma_c) in enumerate(equilibria):
    print(f"Equilibrium {i+1}: row={sigma_r.round(3)}, col={sigma_c.round(3)}")

# Vertex enumeration (alternative — more numerically stable for degenerate games)
equilibria_vertex = list(game.vertex_enumeration())

# Lemke-Howson (finds one equilibrium, not all — but faster for large games)
equilibrium_lh = game.lemke_howson(initial_label=0)
```

**Computational limits:** Support enumeration has worst-case exponential complexity in the number of strategies. For games with more than ~10 strategies per player, use gambit.

## gambit (via pygambit) for Large and Extensive-Form Games

gambit is the standard computational game theory package. It handles normal-form and extensive-form games, and implements multiple equilibrium-finding algorithms:

```python
import pygambit as gbt

# Create a normal-form game
g = gbt.Game.new_table([2, 2])
g.title = "Coordination Game"

# Set payoffs (player, strategy_profile, payoff)
g[0, 0][0] = 2; g[0, 0][1] = 2    # Both coordinate: (2, 2)
g[0, 1][0] = 0; g[0, 1][1] = 0    # Mismatch: (0, 0)
g[1, 0][0] = 0; g[1, 0][1] = 0    # Mismatch: (0, 0)
g[1, 1][0] = 1; g[1, 1][1] = 1    # Both coordinate: (1, 1)

# Find all Nash equilibria (support enumeration)
solver = gbt.nash.ExternalEnumMixedSolver()
equilibria = solver.solve(g)
for eq in equilibria:
    print(eq)

# Quantal Response Equilibrium (for selecting among multiple equilibria)
qre_solver = gbt.nash.ExternalLogitSolver()
qre = qre_solver.solve(g)

# Sequential equilibria for extensive-form games
g_ext = gbt.Game.read_game("extensive_form.efg")
seq_solver = gbt.nash.ExternalSequenceFormSolver()
seq_eq = seq_solver.solve(g_ext)
```

## Linear Programming for Zero-Sum Games

Zero-sum games have a unique Nash equilibrium value (minimax theorem). LP gives a direct solution:

```python
from scipy.optimize import linprog
import numpy as np

def solve_zerosum(A):
    """
    Solve a zero-sum game with payoff matrix A (row player's payoffs).
    Returns row player's equilibrium mixed strategy and game value.

    LP formulation: maximize v subject to A^T p >= v*1, sum(p) = 1, p >= 0
    Standard form: maximize -v' subject to -A^T p + v' <= 0, ...
    """
    m, n = A.shape

    # Row player: maximize v subject to A @ q <= v*1, sum(q)=1, q>=0
    # Reformulate as: min -v s.t. -A q + v <= 0, sum(q) = 1, q >= 0
    # Variables: [q_1,...,q_m, v] — length m+1

    # Objective: minimize -v
    c = np.zeros(m + 1)
    c[-1] = -1   # -v

    # Inequality: -A.T @ p + v * 1 <= 0  →  [-A.T | 1] @ x <= 0  (n rows, one per column strategy)
    A_ub = np.hstack([-A.T, np.ones((n, 1))])
    b_ub = np.zeros(n)

    # Equality: sum(q) = 1
    A_eq = np.zeros((1, m + 1))
    A_eq[0, :m] = 1.0
    b_eq = np.array([1.0])

    # Bounds: q >= 0, v is free
    bounds = [(0, None)] * m + [(None, None)]

    result = linprog(c, A_ub=A_ub, b_ub=b_ub, A_eq=A_eq, b_eq=b_eq,
                     bounds=bounds, method='highs')

    if result.status != 0:
        raise RuntimeError(f"LP failed: {result.message}")

    q_eq = result.x[:m]
    v = result.x[-1]
    return q_eq, v

# Example: Matching Pennies
A = np.array([[1, -1], [-1, 1]], dtype=float)
q_eq, v = solve_zerosum(A)
print(f"Row player equilibrium: {q_eq.round(3)}")
print(f"Game value: {v:.4f}")   # Should be 0 for matching pennies
```

## Packages Summary

| Package | Language | Best For | Notes |
|---------|----------|----------|-------|
| nashpy | Python | Small normal-form games, learning | Support enumeration, vertex enumeration, Lemke-Howson |
| pygambit | Python | Extensive-form, QRE, research use | Wraps gambit; most complete feature set |
| scipy.optimize.linprog | Python | Zero-sum games | No extra dependency; use HiGHS solver |
| gambit CLI | Any (subprocess) | Batch computation, large games | Direct CLI faster than pygambit for bulk runs |
