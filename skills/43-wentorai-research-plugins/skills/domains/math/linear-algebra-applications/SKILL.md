---
name: linear-algebra-applications
description: "Apply linear algebra concepts to research computing and data analysis"
metadata:
  openclaw:
    emoji: "1234"
    category: "domains"
    subcategory: "math"
    keywords: ["linear algebra", "matrix decomposition", "SVD", "eigenvalues", "PCA", "numerical computing"]
    source: "wentor-research-plugins"
---

# Applied Linear Algebra for Research

A skill for applying linear algebra to research computing, data analysis, and scientific modeling. Covers matrix decompositions, eigenvalue problems, least squares, dimensionality reduction, and practical implementation in NumPy/SciPy.

## Essential Operations

### Matrix Multiplication and Solving Systems

```python
import numpy as np
from scipy import linalg


def solve_linear_system(A: np.ndarray, b: np.ndarray) -> dict:
    """
    Solve Ax = b and analyze the system.

    Args:
        A: Coefficient matrix (n x n)
        b: Right-hand side vector (n,)
    """
    n = A.shape[0]

    # Check condition number (sensitivity to perturbations)
    cond = np.linalg.cond(A)

    result = {
        "shape": A.shape,
        "rank": np.linalg.matrix_rank(A),
        "condition_number": cond,
        "well_conditioned": cond < 1e10,
    }

    if result["rank"] == n:
        x = np.linalg.solve(A, b)
        result["solution"] = x
        result["residual_norm"] = np.linalg.norm(A @ x - b)
    else:
        # Underdetermined or singular -- use least-squares
        x, residuals, rank, sv = np.linalg.lstsq(A, b, rcond=None)
        result["least_squares_solution"] = x
        result["note"] = "System is rank-deficient; least-squares solution returned"

    return result
```

## Matrix Decompositions

### LU Decomposition (Solving Multiple Systems)

```python
def lu_factorization(A: np.ndarray) -> dict:
    """
    LU decomposition for efficiently solving Ax=b for multiple b.
    """
    P, L, U = linalg.lu(A)

    return {
        "P": P,  # Permutation matrix
        "L": L,  # Lower triangular
        "U": U,  # Upper triangular
        "usage": (
            "Once computed, solve for any new right-hand side b "
            "in O(n^2) instead of O(n^3). Use scipy.linalg.lu_solve()."
        )
    }
```

### Singular Value Decomposition (SVD)

```python
def svd_analysis(A: np.ndarray) -> dict:
    """
    SVD of matrix A = U S V^T and its applications.

    Args:
        A: Input matrix (m x n)
    """
    U, s, Vt = np.linalg.svd(A, full_matrices=False)

    return {
        "U_shape": U.shape,       # Left singular vectors (m x k)
        "singular_values": s,      # Sorted descending
        "Vt_shape": Vt.shape,     # Right singular vectors (k x n)
        "rank": np.sum(s > 1e-10),
        "condition_number": s[0] / s[-1] if s[-1] > 0 else float("inf"),
        "energy_ratio": np.cumsum(s ** 2) / np.sum(s ** 2),
        "applications": [
            "Low-rank approximation (truncated SVD)",
            "Principal Component Analysis (PCA)",
            "Pseudoinverse computation",
            "Latent Semantic Analysis (LSA) in text mining",
            "Image compression",
            "Noise reduction"
        ]
    }
```

### Eigendecomposition

```python
def eigen_analysis(A: np.ndarray) -> dict:
    """
    Eigenvalue decomposition of a square matrix.
    """
    eigenvalues, eigenvectors = np.linalg.eig(A)

    # Sort by magnitude
    idx = np.argsort(np.abs(eigenvalues))[::-1]

    return {
        "eigenvalues": eigenvalues[idx],
        "eigenvectors": eigenvectors[:, idx],
        "is_symmetric": np.allclose(A, A.T),
        "is_positive_definite": (
            np.all(np.real(eigenvalues) > 0)
            if np.allclose(A, A.T) else "N/A (not symmetric)"
        ),
        "spectral_radius": np.max(np.abs(eigenvalues)),
        "trace_check": (
            f"Sum of eigenvalues: {np.sum(eigenvalues):.4f}, "
            f"Trace of A: {np.trace(A):.4f}"
        )
    }
```

## Research Applications

### Principal Component Analysis

```python
def pca_from_scratch(X: np.ndarray, n_components: int = 2) -> dict:
    """
    PCA using eigendecomposition of the covariance matrix.

    Args:
        X: Data matrix (n_samples x n_features), centered
        n_components: Number of principal components to retain
    """
    # Center the data
    X_centered = X - X.mean(axis=0)

    # Covariance matrix
    C = np.cov(X_centered, rowvar=False)

    # Eigendecomposition (symmetric matrix -> use eigh for stability)
    eigenvalues, eigenvectors = np.linalg.eigh(C)

    # Sort descending
    idx = np.argsort(eigenvalues)[::-1]
    eigenvalues = eigenvalues[idx]
    eigenvectors = eigenvectors[:, idx]

    # Select top components
    components = eigenvectors[:, :n_components]
    explained_variance = eigenvalues[:n_components]
    total_variance = eigenvalues.sum()

    # Project data
    X_projected = X_centered @ components

    return {
        "components": components,
        "explained_variance_ratio": explained_variance / total_variance,
        "cumulative_variance": np.cumsum(explained_variance) / total_variance,
        "projected_data": X_projected
    }
```

### Least Squares Regression

```python
def least_squares_fit(X: np.ndarray, y: np.ndarray) -> dict:
    """
    Solve the normal equations: beta = (X^T X)^{-1} X^T y
    """
    # Using the numerically stable QR decomposition
    Q, R = np.linalg.qr(X)
    beta = linalg.solve_triangular(R, Q.T @ y)

    y_hat = X @ beta
    residuals = y - y_hat

    return {
        "coefficients": beta,
        "r_squared": 1 - np.sum(residuals ** 2) / np.sum((y - y.mean()) ** 2),
        "residual_norm": np.linalg.norm(residuals),
        "method": "QR decomposition (more stable than normal equations)"
    }
```

## Numerical Stability

### Best Practices

```
1. Avoid explicitly computing matrix inverses:
   BAD:  x = np.linalg.inv(A) @ b
   GOOD: x = np.linalg.solve(A, b)

2. Use specialized routines for structured matrices:
   - Symmetric positive definite: Cholesky (linalg.cho_solve)
   - Sparse: scipy.sparse.linalg.spsolve
   - Banded: scipy.linalg.solve_banded

3. Check condition numbers before solving:
   - cond(A) > 10^10 suggests the solution may be unreliable
   - Consider regularization (Tikhonov/ridge) for ill-conditioned systems

4. Use appropriate precision:
   - float64 for most research computing
   - float32 for large-scale GPU computations (monitor for precision loss)
```

When working with very large matrices, leverage sparse matrix representations (scipy.sparse), iterative solvers (conjugate gradient, GMRES), and randomized algorithms (randomized SVD) to keep computation tractable.
