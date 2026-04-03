---
name: review-julia
description: Run the Julia code review protocol on Julia scripts. Checks code quality, type stability, parallel computing patterns, and scientific computing standards. Produces a report without editing files.
disable-model-invocation: true
argument-hint: "[filename or 'all']"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
---

## Review Julia Code

Run a comprehensive Julia code review on the specified script(s). **Do NOT edit any source files** -- produce a report only.

### Steps

1. **Identify target**: Use `$ARGUMENTS` to find the Julia file(s). If `all`, scan all `.jl` files in the project.

2. **Read standards** from `.claude/rules/julia-code-conventions.md`.

3. **Check these categories**:
   - **Module Structure:** Proper module organization, exports, includes
   - **Parallel Computing:** `@everywhere` annotations, `pmap` usage, worker data distribution
   - **Optimization:** Convergence checks, multiple starting values, grid search patterns
   - **Type Stability:** Concrete types in hot loops, `@code_warntype` recommendations
   - **Path Conventions:** `joinpath()` usage, no hardcoded OS-specific separators
   - **Naming:** `snake_case` functions, `CamelCase` types, paper notation alignment
   - **Common Pitfalls:** Missing `@everywhere`, local minima, large closures in `pmap`

4. **Save report** to `quality_reports/[script_name]_julia_review.md`.

5. **Present summary**: Total issues, severity breakdown, top critical issues.

### Important
- **NEVER edit source files.** Report only.
- Prioritize correctness and performance over style.
- For Julia code generation patterns (MLE, GMM, simulation), see `/econometrics-julia`.
