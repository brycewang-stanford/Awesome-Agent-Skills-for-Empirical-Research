---
paths:
  - "**/*.jl"
  - "**/*.R"
  - "scripts/**"
  - "explorations/**"
---

# Research Project Orchestrator (Simplified)

**For Julia/R scripts, estimation, and data analysis** -- use this simplified loop instead of the full multi-agent orchestrator.

## The Simple Loop

```
Plan approved -> orchestrator activates
  |
  Step 1: IMPLEMENT -- Execute plan steps
  |
  Step 2: VERIFY -- Run code, check outputs
  |         Julia scripts: module loads, main script runs without error
  |         R scripts: Rscript runs without error
  |         Plots: PDF created, correct format
  |         LaTeX: pdflatex compiles, no undefined citations
  |         If verification fails -> fix -> re-verify
  |
  Step 3: SCORE -- Apply quality-gates rubric
  |
  +-- Score >= 80?
        YES -> Done (commit when user signals)
        NO  -> Fix blocking issues, re-verify, re-score
```

**No 5-round loops. No multi-agent reviews. Just: write, test, done.**

## Verification Checklist

- [ ] Script runs without errors
- [ ] All packages/modules loaded at top
- [ ] No hardcoded absolute paths
- [ ] Output files created at expected paths
- [ ] Tolerance checks pass (if applicable)
- [ ] Julia: `@everywhere` on all parallel-required definitions
- [ ] R: `library()` calls at top, paths relative
- [ ] LaTeX: compiles with pdflatex, no undefined citations
- [ ] Quality score >= 80
