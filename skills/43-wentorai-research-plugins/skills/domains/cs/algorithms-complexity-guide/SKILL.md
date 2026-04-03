---
name: algorithms-complexity-guide
description: "Analyze algorithm complexity and computational efficiency for research"
metadata:
  openclaw:
    emoji: "⚙️"
    category: "domains"
    subcategory: "cs"
    keywords: ["algorithms", "computational complexity", "Big-O", "NP-hard", "optimization", "data structures"]
    source: "wentor-research-plugins"
---

# Algorithms and Complexity Guide

A skill for analyzing algorithm complexity and computational efficiency in research contexts. Covers asymptotic notation, common complexity classes, NP-completeness, amortized analysis, and strategies for presenting algorithmic contributions in papers.

## Asymptotic Notation

### Big-O, Omega, and Theta

```
O(f(n))   -- Upper bound (worst case, "at most")
            T(n) is O(f(n)) if T(n) <= c * f(n) for large n

Omega(f(n)) -- Lower bound (best case, "at least")
               T(n) is Omega(f(n)) if T(n) >= c * f(n) for large n

Theta(f(n)) -- Tight bound (exact asymptotic growth)
               Both O(f(n)) and Omega(f(n))

Common growth rates (slowest to fastest):
  O(1) < O(log n) < O(sqrt(n)) < O(n) < O(n log n) < O(n^2) < O(n^3) < O(2^n) < O(n!)
```

### Practical Interpretation

```python
def estimate_runtime(n: int, complexity: str) -> dict:
    """
    Estimate practical runtime for common complexities.

    Args:
        n: Input size
        complexity: Complexity class string
    """
    import math

    complexities = {
        "O(1)": 1,
        "O(log n)": math.log2(max(n, 1)),
        "O(n)": n,
        "O(n log n)": n * math.log2(max(n, 1)),
        "O(n^2)": n ** 2,
        "O(n^3)": n ** 3,
        "O(2^n)": 2 ** min(n, 40),  # Cap to avoid overflow
    }

    operations = complexities.get(complexity, n)

    # Assuming ~10^9 operations per second
    seconds = operations / 1e9

    return {
        "input_size": n,
        "complexity": complexity,
        "estimated_operations": operations,
        "estimated_time": (
            f"{seconds:.2e} seconds"
            if seconds < 60
            else f"{seconds / 60:.1f} minutes"
            if seconds < 3600
            else f"{seconds / 3600:.1f} hours"
        ),
        "feasible": operations < 1e12  # Roughly 1000 seconds
    }
```

## Complexity Classes

### P, NP, and Beyond

```
P:     Problems solvable in polynomial time
       Examples: Sorting, shortest path, MST, linear programming

NP:    Problems verifiable in polynomial time
       (Given a solution, can check it quickly)
       Examples: SAT, TSP, graph coloring, subset sum

NP-Complete: The "hardest" problems in NP
             If any one is in P, then P = NP
             Proven via reduction from a known NP-complete problem

NP-Hard:   At least as hard as NP-complete
           Not necessarily in NP (may not even be decision problems)
           Examples: Optimization versions of NP-complete problems

PSPACE:    Solvable with polynomial space (possibly exponential time)
           Examples: QBF, certain game-theoretic problems
```

### Proving NP-Completeness

```
To prove problem X is NP-complete:
  1. Show X is in NP:
     - Given a certificate (proposed solution), verify it in poly time

  2. Reduce a known NP-complete problem Y to X:
     - Construct a polynomial-time transformation f
       such that Y has solution iff f(Y) has solution in X
     - Common starting problems: SAT, 3-SAT, Vertex Cover,
       Hamiltonian Path, Subset Sum
```

## Algorithm Analysis Techniques

### Recurrence Relations

```
For divide-and-conquer algorithms, solve recurrences:

Master Theorem: T(n) = a * T(n/b) + O(n^d)

  Case 1: d < log_b(a)  ->  T(n) = O(n^(log_b(a)))
  Case 2: d = log_b(a)  ->  T(n) = O(n^d * log n)
  Case 3: d > log_b(a)  ->  T(n) = O(n^d)

Examples:
  Merge Sort:    T(n) = 2T(n/2) + O(n)     -> O(n log n)  [Case 2]
  Binary Search: T(n) = T(n/2) + O(1)       -> O(log n)    [Case 2]
  Strassen:      T(n) = 7T(n/2) + O(n^2)   -> O(n^2.81)   [Case 1]
```

### Amortized Analysis

```
Amortized analysis provides the average cost per operation over
a worst-case sequence of operations.

Methods:
  - Aggregate method: Total cost / number of operations
  - Accounting method: Assign "credits" to cheap operations
  - Potential method: Define a potential function

Example: Dynamic array (ArrayList)
  Most insertions: O(1)
  Occasional resize: O(n)
  Amortized cost per insertion: O(1)
  (The expensive resizes are rare enough that the average stays constant)
```

## Presenting Algorithms in Papers

### Algorithm Pseudocode Standards

```latex
% Use the algorithm2e or algorithmicx package in LaTeX

\begin{algorithm}[H]
\caption{Description of Algorithm}
\label{alg:myalgorithm}
\KwIn{Input description}
\KwOut{Output description}

initialization\;
\While{condition}{
    compute something\;
    \If{condition}{
        action\;
    }
}
\Return result\;
\end{algorithm}
```

### What to Include in an Algorithms Paper

```
1. Problem definition (formal, with input/output specification)
2. Related work and existing approaches with their complexities
3. Algorithm description (pseudocode + English explanation)
4. Correctness proof (invariants, termination argument)
5. Complexity analysis (time and space, worst/average/amortized)
6. Experimental evaluation:
   - Comparison with baselines on standard benchmarks
   - Runtime scaling with input size (empirical vs. theoretical)
   - Real-world datasets in addition to synthetic ones
7. Discussion of practical considerations (constants, cache behavior)
```

## Dealing with Intractability

When you encounter NP-hard problems in your research, consider: polynomial-time approximation algorithms (with provable approximation ratios), heuristics (greedy, local search, simulated annealing), fixed-parameter tractable (FPT) algorithms if a relevant parameter is small, integer linear programming (ILP) solvers for moderate-size instances, or restricting to special cases where the problem becomes tractable (e.g., trees, planar graphs).
