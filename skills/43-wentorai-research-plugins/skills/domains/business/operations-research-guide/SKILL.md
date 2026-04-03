---
name: operations-research-guide
description: "Optimization and operations research methods for business and logistics"
metadata:
  openclaw:
    emoji: "⚙️"
    category: "domains"
    subcategory: "business"
    keywords: ["optimization", "operations-research", "linear-programming", "scheduling", "supply-chain", "simulation"]
    source: "wentor"
---

# Operations Research Guide

A skill for applying operations research (OR) methods to business, logistics, and resource allocation problems. Covers linear programming, integer programming, scheduling, network optimization, simulation, and decision analysis using Python optimization libraries.

## Linear Programming

### Problem Formulation and Solving

```python
from scipy.optimize import linprog
import numpy as np

def solve_production_planning():
    """
    Example: A factory produces two products (A and B).
    Product A: profit $40, uses 2h labor + 1kg material
    Product B: profit $30, uses 1h labor + 2kg material
    Constraints: 100h labor available, 80kg material available
    Maximize total profit.
    """
    # linprog minimizes, so negate for maximization
    c = [-40, -30]  # objective coefficients (negated)

    # Inequality constraints: A_ub @ x <= b_ub
    A_ub = [
        [2, 1],   # labor constraint
        [1, 2],   # material constraint
    ]
    b_ub = [100, 80]

    # Non-negativity bounds
    bounds = [(0, None), (0, None)]

    result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=bounds, method="highs")

    return {
        "product_A": result.x[0],
        "product_B": result.x[1],
        "max_profit": -result.fun,
        "status": "optimal" if result.success else "infeasible",
    }
```

### Using PuLP for Readable Models

```python
from pulp import LpProblem, LpMaximize, LpVariable, lpSum, value

def workforce_scheduling():
    """
    Workforce scheduling: minimize staffing cost while meeting
    demand for each day of the week. Workers work 5 consecutive days.
    """
    days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    demand = [17, 13, 15, 19, 14, 16, 11]
    cost_per_worker = 1  # uniform cost

    prob = LpProblem("workforce_scheduling", LpMaximize)

    # x[i] = number of workers starting on day i
    x = {i: LpVariable(f"start_{days[i]}", lowBound=0, cat="Integer")
         for i in range(7)}

    # Minimize total workers
    prob += -lpSum(x[i] for i in range(7))

    # Each day, workers starting on days [d-4, d-3, ..., d] are available
    for d in range(7):
        workers_available = lpSum(x[(d - j) % 7] for j in range(5))
        prob += workers_available >= demand[d], f"demand_{days[d]}"

    prob.solve()

    return {
        "status": prob.status,
        "schedule": {days[i]: int(value(x[i])) for i in range(7)},
        "total_workers": int(sum(value(x[i]) for i in range(7))),
    }
```

## Integer and Mixed-Integer Programming

### Vehicle Routing Problem

```python
from itertools import combinations

def solve_tsp_mtz(distances: np.ndarray) -> dict:
    """
    Solve the Traveling Salesman Problem using Miller-Tucker-Zemlin formulation.
    distances: n x n distance matrix
    Returns optimal tour and total distance.
    """
    from pulp import LpProblem, LpMinimize, LpVariable, LpBinary, lpSum, value

    n = len(distances)
    prob = LpProblem("TSP", LpMinimize)

    # Binary variables: x[i][j] = 1 if edge (i,j) in tour
    x = {(i, j): LpVariable(f"x_{i}_{j}", cat=LpBinary)
         for i in range(n) for j in range(n) if i != j}

    # Subtour elimination variables
    u = {i: LpVariable(f"u_{i}", lowBound=1, upBound=n - 1)
         for i in range(1, n)}

    # Objective: minimize total distance
    prob += lpSum(distances[i][j] * x[i, j] for i, j in x)

    # Each city visited exactly once
    for i in range(n):
        prob += lpSum(x[i, j] for j in range(n) if j != i) == 1
        prob += lpSum(x[j, i] for j in range(n) if j != i) == 1

    # MTZ subtour elimination
    for i in range(1, n):
        for j in range(1, n):
            if i != j:
                prob += u[i] - u[j] + (n - 1) * x[i, j] <= n - 2

    prob.solve()

    # Extract tour
    tour = [0]
    current = 0
    for _ in range(n - 1):
        for j in range(n):
            if j != current and (current, j) in x and value(x[current, j]) > 0.5:
                tour.append(j)
                current = j
                break

    return {
        "tour": tour,
        "total_distance": value(prob.objective),
    }
```

## Queuing Theory

### M/M/c Queue Analysis

```python
from math import factorial, exp

def mmc_queue(arrival_rate: float, service_rate: float,
              n_servers: int) -> dict:
    """
    Analyze an M/M/c queue (Poisson arrivals, exponential service, c servers).
    arrival_rate: lambda (customers per unit time)
    service_rate: mu (customers served per unit time per server)
    n_servers: c (number of parallel servers)
    """
    rho = arrival_rate / (n_servers * service_rate)

    if rho >= 1:
        return {"stable": False, "utilization": rho}

    # Erlang C formula: probability of waiting
    a = arrival_rate / service_rate
    sum_terms = sum(a ** k / factorial(k) for k in range(n_servers))
    erlang_c = (a ** n_servers / factorial(n_servers)) / (
        (a ** n_servers / factorial(n_servers)) + (1 - rho) * sum_terms
    )

    # Performance metrics
    Lq = erlang_c * rho / (1 - rho)         # avg queue length
    Wq = Lq / arrival_rate                    # avg wait time
    W = Wq + 1 / service_rate                 # avg time in system
    L = arrival_rate * W                      # avg number in system

    return {
        "stable": True,
        "utilization": round(rho, 4),
        "prob_wait": round(erlang_c, 4),
        "avg_queue_length": round(Lq, 4),
        "avg_wait_time": round(Wq, 4),
        "avg_system_time": round(W, 4),
        "avg_in_system": round(L, 4),
    }
```

## Simulation Methods

### Discrete-Event Simulation

```python
import simpy
import random

def simulate_service_center(n_servers: int, arrival_rate: float,
                             service_rate: float, sim_time: float = 480):
    """
    Discrete-event simulation of a service center using SimPy.
    sim_time: simulation duration in minutes (default 8-hour day).
    """
    wait_times = []

    def customer(env, server):
        arrival_time = env.now
        with server.request() as req:
            yield req
            wait = env.now - arrival_time
            wait_times.append(wait)
            yield env.timeout(random.expovariate(service_rate))

    def customer_generator(env, server):
        customer_id = 0
        while True:
            yield env.timeout(random.expovariate(arrival_rate))
            customer_id += 1
            env.process(customer(env, server))

    env = simpy.Environment()
    server = simpy.Resource(env, capacity=n_servers)
    env.process(customer_generator(env, server))
    env.run(until=sim_time)

    return {
        "customers_served": len(wait_times),
        "avg_wait": np.mean(wait_times) if wait_times else 0,
        "max_wait": max(wait_times) if wait_times else 0,
        "pct_waited": sum(1 for w in wait_times if w > 0) / len(wait_times) * 100,
    }
```

## Decision Analysis

### Multi-Criteria Decision Making

| Method | Description | Best For |
|--------|-------------|----------|
| AHP (Analytic Hierarchy Process) | Pairwise comparison matrix | Structured group decisions |
| TOPSIS | Distance to ideal/anti-ideal solution | Ranking alternatives |
| Weighted scoring | Simple weighted sum | Quick comparisons |
| Decision trees | Sequential decision under uncertainty | Multi-stage problems |

## Tools and Libraries

- **PuLP**: Python LP/MIP modeling with multiple solver backends
- **OR-Tools (Google)**: Constraint programming, routing, scheduling
- **Gurobi / CPLEX**: Commercial high-performance MIP solvers (free academic licenses)
- **SimPy**: Python discrete-event simulation framework
- **SciPy optimize**: Linear programming, nonlinear optimization
- **Pyomo**: Algebraic modeling language for optimization in Python
- **AMPL**: Commercial algebraic modeling language
