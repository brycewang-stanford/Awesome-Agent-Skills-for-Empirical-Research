---
paths:
  - "**/*.jl"
---

# Julia Code Standards

**Standard:** Production-quality scientific computing for econometric research

---

## 1. Module Structure

- One main module with all estimation functions
- Pipeline orchestrator in a separate main script -- configures and calls the module
- Auto-install missing packages at top of main script

## 2. Parallel Computing

- Use `addprocs()` for CPU-parallel workers
- **All shared functions and data must use `@everywhere`**
- Use `pmap` for embarrassingly parallel tasks (grid search, bootstrap)
- Pre-compute expensive objects before parallel dispatch

## 3. Optimization

- Grid search over key parameters, then Nelder-Mead (or other optimizer) for remaining parameters
- **Always check convergence**: verify `Optim.converged(result)` is true
- Use multiple starting values if convergence is questionable
- Pre-allocate arrays in hot loops

## 4. Type Stability

- Annotate function signatures with concrete types where performance matters
- Avoid abstract types in inner loops (`Vector{Float64}` not `AbstractVector`)
- Use `@code_warntype` to check critical functions

## 5. Path Conventions

- Use `joinpath()` for all file paths (cross-platform)
- Paths relative to the repository root
- Never hardcode OS-specific separators (`\` or `/`)

## 6. RCall Interop

- Load R data via `RCall.@rget` after `R"load('path')"`
- Explicit type conversion at Julia-R boundary
- Test with small data before full pipeline

## 7. Naming Conventions

- `snake_case` for functions and variables
- `CamelCase` for module and type names
- Descriptive names matching paper notation where possible (e.g., `sigma_v`, `rho`, `W_t`)

## 8. Common Pitfalls

| Pitfall | Impact | Prevention |
|---------|--------|------------|
| Missing `@everywhere` | Workers lack function definitions | Annotate all shared code |
| Optimizer local minimum | Incorrect parameter estimates | Grid search + multiple starts |
| Type instability | 100x slower inner loops | Use `@code_warntype` |
| Large closure in `pmap` | Excessive memory per worker | Pass data explicitly |
| Windows path separators | `\` breaks cross-platform | Always use `joinpath()` |

## 9. Line Length & Mathematical Exceptions

**Standard:** Keep lines <= 92 characters (Julia convention).

**Exception:** Mathematical formulas matching paper equations may exceed limit if:
1. An inline comment explains the mathematical operation
2. Breaking would harm readability of matrix/spatial operations

## 10. Code Quality Checklist

```
[ ] Module loads without errors
[ ] `@everywhere` on all parallel-required definitions
[ ] Convergence checks for all optimization calls
[ ] No hardcoded absolute paths
[ ] Type-stable critical functions
[ ] Output files written to expected directories
[ ] Comments reference paper equations where applicable
```
