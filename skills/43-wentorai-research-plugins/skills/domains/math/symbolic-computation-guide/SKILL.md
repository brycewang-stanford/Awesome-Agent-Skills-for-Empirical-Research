---
name: symbolic-computation-guide
description: "Computer algebra systems: SymPy, SageMath, and Mathematica for research"
metadata:
  openclaw:
    emoji: "🧮"
    category: "domains"
    subcategory: "math"
    keywords: ["symbolic-computation", "computer-algebra", "sympy", "sagemath", "mathematica", "calculus"]
    source: "wentor"
---

# Symbolic Computation Guide

A skill for using computer algebra systems (CAS) in mathematical research. Covers symbolic differentiation, integration, equation solving, series expansion, linear algebra, and polynomial arithmetic using SymPy, SageMath, and Mathematica, with practical workflows for research mathematics.

## SymPy Fundamentals

### Symbolic Expressions and Manipulation

```python
from sympy import (
    symbols, expand, factor, simplify, cancel, apart,
    sin, cos, exp, log, sqrt, pi, oo, I,
    Rational, Eq, solve, solveset, S
)

x, y, z, t, n, k = symbols("x y z t n k")
a, b, c = symbols("a b c", real=True)

# Expression manipulation
expr = (x + 1) ** 3
expanded = expand(expr)       # x**3 + 3*x**2 + 3*x + 1
factored = factor(expanded)   # (x + 1)**3

# Trigonometric simplification
from sympy import trigsimp
trig_expr = sin(x)**2 + cos(x)**2
simplified = trigsimp(trig_expr)  # 1

# Partial fraction decomposition
rational = (x**2 + 2*x + 3) / ((x + 1) * (x + 2) * (x + 3))
partial = apart(rational, x)
# 3/(2*(x + 3)) - 2/(x + 2) + 1/(2*(x + 1))
```

### Calculus

```python
from sympy import diff, integrate, limit, series, Sum, Product

# Differentiation
f = x**3 * exp(-x) * sin(x)
f_prime = diff(f, x)
f_double_prime = diff(f, x, 2)

# Integration
# Definite integral
area = integrate(exp(-x**2), (x, -oo, oo))  # sqrt(pi)

# Indefinite integral
antideriv = integrate(x * sin(x), x)  # -x*cos(x) + sin(x)

# Limits
lim_result = limit(sin(x) / x, x, 0)  # 1
lim_inf = limit((1 + 1/n)**n, n, oo)   # E (Euler's number)

# Taylor series
taylor = series(exp(x) * cos(x), x, 0, n=6)
# 1 + x - x**3/3 - x**4/6 + ...

# Summation
harmonic = Sum(1/k, (k, 1, n))
partial_sum = harmonic.doit()  # harmonic(n) -- returns harmonic number

geometric = Sum(x**k, (k, 0, oo))
closed_form = geometric.doit()  # Piecewise(1/(1 - x), Abs(x) < 1)
```

### Equation Solving

```python
# Algebraic equations
solutions = solve(x**3 - 6*x**2 + 11*x - 6, x)  # [1, 2, 3]

# System of equations
system_sol = solve([
    2*x + 3*y - 7,
    x - y + 1
], [x, y])  # {x: 4/5, y: 9/5}

# Differential equations
from sympy import Function, dsolve, Derivative
f = Function("f")

# f''(x) + f(x) = 0  (simple harmonic oscillator)
ode = Eq(f(x).diff(x, 2) + f(x), 0)
general_solution = dsolve(ode, f(x))
# f(x) = C1*sin(x) + C2*cos(x)

# With initial conditions
particular = dsolve(ode, f(x), ics={f(0): 1, f(x).diff(x).subs(x, 0): 0})
# f(x) = cos(x)
```

## Linear Algebra

### Symbolic Matrix Operations

```python
from sympy import Matrix, eye, zeros, det, Rational

# Define a symbolic matrix
A = Matrix([
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 10]
])

# Basic operations
print(f"Determinant: {det(A)}")           # -3
print(f"Inverse:\n{A.inv()}")
print(f"Eigenvalues: {A.eigenvals()}")
print(f"Rank: {A.rank()}")

# Characteristic polynomial
lam = symbols("lambda")
char_poly = (A - lam * eye(3)).det()
char_poly = expand(char_poly)

# Jordan normal form
P, J = A.jordan_form()

# Null space and column space
null = A.nullspace()
col_space = A.columnspace()

# Symbolic matrix with parameters
M = Matrix([
    [a, b],
    [c, a]
])
eigenvals = M.eigenvals()  # {a - sqrt(b*c): 1, a + sqrt(b*c): 1}
```

## SageMath for Research

### Number Theory

```python
# SageMath syntax (Python-based, but with enhanced number theory)
# Run in SageMath environment or via sage -python

"""
# Prime factorization
factor(2024)  # 2^3 * 11 * 23

# Modular arithmetic
R = IntegerModRing(17)
R(3)^(-1)  # multiplicative inverse of 3 mod 17

# Elliptic curves
E = EllipticCurve(QQ, [-1, 0])
E.rank()
E.torsion_subgroup()
E.gens()

# Polynomial rings
R.<x,y> = PolynomialRing(QQ)
I = R.ideal(x^2 + y^2 - 1, x - y)
I.groebner_basis()  # [y^2 - 1/2, x - y]

# Group theory
G = SymmetricGroup(4)
G.order()           # 24
G.center()
G.normal_subgroups()
"""
```

### Combinatorics and Graph Theory

```python
"""
# SageMath combinatorics
Partitions(10).cardinality()  # 42

# Graph theory
G = graphs.PetersenGraph()
G.chromatic_number()      # 3
G.is_vertex_transitive()  # True
G.automorphism_group().order()  # 120

# Posets and lattices
P = posets.BooleanLattice(3)
P.is_lattice()
P.mobius_function(P.bottom(), P.top())
"""
```

## Mathematica / Wolfram Language

### Common Research Patterns

```mathematica
(* Symbolic integration *)
Integrate[x^n * Exp[-x], {x, 0, Infinity}, Assumptions -> n > -1]
(* Result: Gamma[1 + n] *)

(* Solve a PDE *)
DSolve[D[u[x, t], t] == k * D[u[x, t], {x, 2}], u[x, t], {x, t}]

(* Asymptotic expansion *)
Series[Gamma[n + 1], {n, Infinity, 3}]

(* Minimize with constraints *)
NMinimize[{x^2 + y^2, x + y >= 1}, {x, y}]

(* Compute a sum in closed form *)
Sum[1/k^2, {k, 1, Infinity}]  (* Pi^2/6 *)
```

## Practical Workflows

### Verifying Research Computations

Common CAS workflow in mathematical research:

1. **Conjecture formulation**: Test conjectures for small cases programmatically
2. **Identity verification**: Verify algebraic identities symbolically
3. **Closed-form discovery**: Use pattern matching and OEIS lookup
4. **Proof assistance**: Compute bounds, verify inequalities
5. **Counterexample search**: Systematically search parameter spaces

```python
from sympy import simplify, Abs

def verify_identity(lhs, rhs):
    """Verify a proposed mathematical identity symbolically."""
    diff = simplify(lhs - rhs)
    if diff == 0:
        return "VERIFIED: identity holds symbolically"
    else:
        return f"NOT VERIFIED: difference = {diff}"

# Example: verify Cauchy-Schwarz for 2D
a1, a2, b1, b2 = symbols("a1 a2 b1 b2", real=True)
lhs = (a1*b1 + a2*b2)**2
rhs = (a1**2 + a2**2) * (b1**2 + b2**2)
diff = expand(rhs - lhs)
# (a1*b2 - a2*b1)**2 >= 0, confirming Cauchy-Schwarz
```

## Tools and Resources

- **SymPy**: Pure Python CAS, integrates with Jupyter and NumPy
- **SageMath**: Comprehensive open-source math system (wraps GAP, PARI, Singular, etc.)
- **Mathematica / Wolfram Alpha**: Commercial CAS with unmatched integration database
- **Maxima**: Free CAS (Lisp-based), used in wxMaxima GUI
- **PARI/GP**: Specialized in number theory computations
- **Macaulay2**: Commutative algebra and algebraic geometry
- **GAP**: Computational group theory
- **OEIS (oeis.org)**: Online Encyclopedia of Integer Sequences for pattern identification
