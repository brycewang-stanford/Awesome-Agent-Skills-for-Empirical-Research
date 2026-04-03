---
name: numerical-methods-guide
description: "Apply numerical methods and scientific computing techniques"
metadata:
  openclaw:
    emoji: "🧮"
    category: "domains"
    subcategory: "math"
    keywords: ["numerical methods", "scientific computing", "ODE solver", "optimization", "interpolation", "finite differences"]
    source: "wentor-research-plugins"
---

# Numerical Methods Guide

A skill for applying numerical methods in scientific computing and research. Covers root finding, numerical integration, ODE solvers, optimization, interpolation, and error analysis with practical implementations in Python.

## Root Finding

### Newton's Method and Alternatives

```python
import numpy as np


def newton_method(f, df, x0: float, tol: float = 1e-10,
                  max_iter: int = 100) -> dict:
    """
    Newton's method for finding roots of f(x) = 0.

    Args:
        f: Function whose root we seek
        df: Derivative of f
        x0: Initial guess
        tol: Convergence tolerance
        max_iter: Maximum iterations
    """
    x = x0
    history = [x]

    for i in range(max_iter):
        fx = f(x)
        dfx = df(x)

        if abs(dfx) < 1e-15:
            return {"root": x, "converged": False,
                    "reason": "Zero derivative encountered"}

        x_new = x - fx / dfx
        history.append(x_new)

        if abs(x_new - x) < tol:
            return {
                "root": x_new,
                "converged": True,
                "iterations": i + 1,
                "f_at_root": f(x_new),
                "convergence": "quadratic"
            }

        x = x_new

    return {"root": x, "converged": False, "reason": "Max iterations reached"}
```

### Method Selection Guide

| Method | Convergence | Requires | Robustness |
|--------|------------|----------|-----------|
| Bisection | Linear (slow) | Bracketing interval | Very robust |
| Newton | Quadratic (fast) | Derivative | May diverge |
| Secant | Superlinear (~1.62) | Two initial guesses | Moderate |
| Brent | Superlinear | Bracketing interval | Very robust |

## Numerical Integration

### Quadrature Methods

```python
from scipy import integrate


def numerical_integration_comparison(f, a: float, b: float) -> dict:
    """
    Compare numerical integration methods.

    Args:
        f: Function to integrate
        a: Lower bound
        b: Upper bound
    """
    # Adaptive Gaussian quadrature (recommended default)
    quad_result, quad_error = integrate.quad(f, a, b)

    # Simpson's rule (fixed-point)
    n_points = 101
    x = np.linspace(a, b, n_points)
    simps_result = integrate.simpson(f(x), x=x)

    # Romberg integration
    romb_result = integrate.romberg(f, a, b)

    return {
        "quad": {"value": quad_result, "error_estimate": quad_error},
        "simpson": {"value": simps_result, "n_points": n_points},
        "romberg": {"value": romb_result},
        "recommendation": (
            "Use scipy.integrate.quad for most cases. "
            "It adaptively chooses points for accuracy."
        )
    }
```

## Ordinary Differential Equations

### Solving Initial Value Problems

```python
from scipy.integrate import solve_ivp


def solve_ode_system(f, t_span: tuple, y0: list,
                     method: str = "RK45") -> dict:
    """
    Solve a system of ODEs: dy/dt = f(t, y).

    Args:
        f: Right-hand side function f(t, y)
        t_span: (t_start, t_end)
        y0: Initial conditions
        method: Solver method (RK45, RK23, Radau, BDF, LSODA)
    """
    sol = solve_ivp(
        f, t_span, y0,
        method=method,
        dense_output=True,
        rtol=1e-8,
        atol=1e-10
    )

    return {
        "success": sol.success,
        "message": sol.message,
        "t": sol.t,
        "y": sol.y,
        "n_evaluations": sol.nfev,
        "method_used": method
    }


# Example: Lorenz system (chaotic dynamics)
def lorenz(t, state, sigma=10, rho=28, beta=8/3):
    x, y, z = state
    return [
        sigma * (y - x),
        x * (rho - z) - y,
        x * y - beta * z
    ]

result = solve_ode_system(lorenz, (0, 50), [1.0, 1.0, 1.0])
```

### Solver Selection

```
Non-stiff problems:
  RK45 (default):  4th/5th order Runge-Kutta, adaptive step
  RK23:            Lower order, useful for less smooth problems
  DOP853:          High-order, excellent for smooth problems

Stiff problems:
  Radau:           Implicit Runge-Kutta, good for stiff systems
  BDF:             Backward differentiation formula (classic stiff solver)
  LSODA:           Automatically switches between non-stiff and stiff

How to tell if your problem is stiff:
  - RK45 takes many tiny steps or fails to converge
  - The system has widely separated time scales
  - Chemical kinetics, circuit simulations often stiff
```

## Optimization

### Minimization Methods

```python
from scipy.optimize import minimize


def optimize_with_comparison(f, x0: np.ndarray,
                              bounds: list = None) -> dict:
    """
    Compare optimization methods on a given objective function.

    Args:
        f: Objective function to minimize
        x0: Initial guess
        bounds: List of (min, max) tuples for each variable
    """
    results = {}

    # Gradient-free
    res_nm = minimize(f, x0, method="Nelder-Mead")
    results["Nelder-Mead"] = {"x": res_nm.x, "fun": res_nm.fun,
                               "nfev": res_nm.nfev}

    # Gradient-based (quasi-Newton)
    res_bfgs = minimize(f, x0, method="L-BFGS-B", bounds=bounds)
    results["L-BFGS-B"] = {"x": res_bfgs.x, "fun": res_bfgs.fun,
                            "nfev": res_bfgs.nfev}

    return results
```

## Error Analysis

### Sources of Numerical Error

```
1. Rounding error:
   Finite precision arithmetic (float64 has ~16 significant digits)
   Accumulates in long computations

2. Truncation error:
   Error from approximating continuous math with discrete formulas
   Example: Finite difference df/dx ~ (f(x+h) - f(x)) / h

3. Conditioning:
   Sensitivity of the result to perturbations in input
   Condition number quantifies this amplification

Best practice: Always compare your numerical solution against
analytical solutions (when available) or use convergence studies
(refine the discretization and check if the answer converges).
```

When publishing numerical results, report the method used, convergence criteria, error tolerances, grid resolution (for PDEs), and validate against known test cases. Provide code so readers can reproduce your computations.
