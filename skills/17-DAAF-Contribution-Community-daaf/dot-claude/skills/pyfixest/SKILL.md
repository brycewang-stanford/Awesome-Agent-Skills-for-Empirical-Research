---
name: pyfixest
description: >-
  Fast high-dimensional fixed effects: OLS, Poisson, IV with multi-way FE; DiD (TWFE, did2s, Sun-Abraham); clustered SEs; etable/coefplot/iplot. Use for FE regressions or DiD. For panel RE/between use linearmodels; for GLM without FE use statsmodels.
metadata:
  audience: research-coders
  domain: python-library
  library-version: "0.40.0"
  skill-last-updated: "2026-03-27"
---

# pyfixest Skill

pyfixest: fast high-dimensional fixed effects estimation for Python. Covers OLS, Poisson, and IV regression with multi-way fixed effects; difference-in-differences estimators (TWFE, did2s, lpdid, Sun-Abraham); clustered standard errors; wild bootstrap; and publication output (etable regression tables, coefplot, iplot event study plots). Use when running fixed effects regressions, difference-in-differences designs, Poisson count models with FE, or producing publication-ready regression tables. For panel random/between effects, use linearmodels; for GLM/time series without FE, use statsmodels.

Comprehensive skill for fixed effects regression, instrumental variables, and difference-in-differences estimation with pyfixest. Use decision trees below to find the right guidance, then load detailed references.

## What is pyfixest?

pyfixest is a Python implementation of the R **fixest** package (Berge, Butts, & McDermott, 2026):
- **Fast**: Multi-way FE demeaning via alternating projections with numba/JAX/GPU backends
- **Concise formula syntax**: Fixed effects after `|`, IV after second `|`, multiple estimation via `sw()`/`csw()`
- **Modern DiD**: Built-in did2s, local projections DiD (lpdid), and Sun-Abraham saturated estimator
- **Flexible inference**: Switch SE types post-estimation; wild bootstrap, randomization inference, CCV
- **Publication output**: `etable()` for regression tables, `coefplot()` and `iplot()` for coefficient visualization

## Version Notes

This skill targets **pyfixest 0.40.0**, the major release aligning with R fixest 0.13. Breaking changes from earlier versions:
- Default standard errors changed from "cluster by first FE" to `"iid"` — old code silently produces different SEs
- `ssc()` arguments renamed: `adj` → `k_adj`, `fixef_k` → `k_fixef`, `cluster_adj` → `G_adj`, `cluster_df` → `G_df`
- `fixef_rm` default changed from `"none"` to `"singleton"` — singletons now dropped by default
- Multicollinearity tolerance reduced from 1e-10 to 1e-09

## How to Use This Skill

### Reference File Structure

Each topic in `./references/` contains focused documentation:

| File | Purpose | When to Read |
|------|---------|--------------|
| `quickstart.md` | Installation, first regression, formula syntax | Starting with pyfixest |
| `fixed-effects.md` | Multi-way FE, SE types, clustering, wild bootstrap | FE models and inference |
| `instrumental-variables.md` | IV syntax, first stage, weak instruments | IV/2SLS estimation |
| `difference-in-differences.md` | TWFE, did2s, lpdid, Sun-Abraham, event studies | DiD designs |
| `tables-and-plots.md` | etable, coefplot, iplot, dtable | Reporting results |
| `advanced-inference.md` | Wild bootstrap, randomization inference, MHT corrections, Gelbach | Advanced statistical inference |
| `integration.md` | Multiple estimation, Poisson, GLM, marginaleffects, online learning | Advanced features |
| `gotchas.md` | Common errors, v0.40 breaking changes, fixest vs pyfixest | Debugging issues |

### Reading Order

1. **New to pyfixest?** Start with `quickstart.md` then `fixed-effects.md`
2. **Running DiD?** Read `quickstart.md`, then `difference-in-differences.md`
3. **Need IV?** Read `quickstart.md`, then `instrumental-variables.md`
4. **Making tables?** Check `tables-and-plots.md`
5. **Coming from R fixest?** Read `quickstart.md` then `gotchas.md`

## Related Skills

| Skill | Relationship |
|-------|-------------|
| `data-scientist` | Methodology guidance — load for "why and when" behind methods |
| `statsmodels` | Complement for non-FE models: GLM, time series, diagnostics |
| `linearmodels` | Random effects, GMM, system estimation when pyfixest's FE-only approach is insufficient |
| `svy` | Survey-weighted regression with complex survey designs. pyfixest's clustered SEs account for within-group correlation but do NOT handle full survey design features (stratification, unequal probability weights, FPC). If your data comes from a complex probability survey, use `svy` for design-based inference |
| `polars` | Data preparation before estimation (convert to pandas before passing to pyfixest) |
| `plotnine` | Custom visualization beyond pyfixest's built-in plots |

## Quick Decision Trees

### "I need to run a regression"

```
What kind of regression?
├─ OLS with fixed effects → ./references/quickstart.md
├─ OLS without fixed effects → ./references/quickstart.md
├─ IV / 2SLS → ./references/instrumental-variables.md
├─ Poisson (count data) → ./references/integration.md
├─ Logit / Probit → ./references/integration.md
├─ Quantile regression → ./references/integration.md
└─ Multiple models at once → ./references/integration.md
```

### "I need difference-in-differences"

```
DiD design?
├─ Simple 2x2 DiD (one treatment date) → ./references/difference-in-differences.md
├─ Staggered treatment timing → ./references/difference-in-differences.md
│   ├─ did2s (Gardner imputation) → ./references/difference-in-differences.md
│   ├─ Local projections DiD → ./references/difference-in-differences.md
│   └─ Sun-Abraham saturated → ./references/difference-in-differences.md
├─ Event study plot → ./references/difference-in-differences.md
├─ Visualize treatment patterns → ./references/difference-in-differences.md
└─ Parallel trends assessment → ./references/difference-in-differences.md
```

### "I need to choose standard errors"

```
What inference?
├─ Heteroskedasticity-robust (HC1) → ./references/fixed-effects.md
├─ Clustered (one-way / two-way) → ./references/fixed-effects.md
├─ Few clusters (<20) → ./references/advanced-inference.md
│   └─ Wild cluster bootstrap → ./references/advanced-inference.md
├─ HAC / Newey-West → ./references/fixed-effects.md
├─ Randomization inference → ./references/advanced-inference.md
├─ Multiple hypothesis testing → ./references/advanced-inference.md
└─ Causal cluster variance (CCV) → ./references/advanced-inference.md
```

### "I need to present results"

```
Presenting results?
├─ Regression table (multiple models) → ./references/tables-and-plots.md
├─ Coefficient plot → ./references/tables-and-plots.md
├─ Event study plot → ./references/tables-and-plots.md
├─ Descriptive statistics table → ./references/tables-and-plots.md
└─ LaTeX output → ./references/tables-and-plots.md
```

### "Something isn't working"

```
Having issues?
├─ Different results from old code → ./references/gotchas.md
├─ feglm with fixed effects error → ./references/gotchas.md
├─ numba installation problems → ./references/gotchas.md
├─ CRV3 memory issues → ./references/gotchas.md
├─ Poisson convergence → ./references/gotchas.md
├─ Formula parsing errors → ./references/gotchas.md
├─ R fixest vs pyfixest differences → ./references/gotchas.md
└─ Singleton warnings → ./references/gotchas.md
```

## File-First Execution in Research Workflows

**Important:** In data research pipelines (see `CLAUDE.md`), pyfixest regressions are executed through **script files**, not interactively. This ensures auditability and reproducibility.

**The pattern:**
1. Write regression code to `scripts/stage8_analysis/{step}_{task-name}.py`
2. Execute via Bash with automatic output capture wrapper script
3. Validation results get automatically embedded in scripts as comments
4. If failed, create versioned copy for fixes

Closely read `agent_reference/SCRIPT_EXECUTION_REFERENCE.md` for the mandatory file-first execution protocol covering complete code file writing, output capture, and file versioning rules. All regression scripts must follow the Inline Audit Trail (IAT) standard — see `agent_reference/INLINE_AUDIT_TRAIL.md`. For regression code, document model specification choices (why this estimator, why this clustering level, what identifying assumptions) with `# INTENT:`, `# REASONING:`, and `# ASSUMES:` comments.

**See:**
- `agent_reference/WORKFLOW_PHASE4_ANALYSIS.md` — Stage 8 (Analysis & Visualization)
- `agent_reference/INLINE_AUDIT_TRAIL.md` — IAT documentation standard

The examples below show pyfixest syntax. In research workflows, wrap them in scripts following the file-first pattern.

---

## Quick Reference

### Essential Import

```python
import pyfixest as pf
```

### Core Estimation Functions

| Function | Purpose |
|----------|---------|
| `pf.feols("Y ~ X \| fe", data=df)` | OLS with fixed effects |
| `pf.fepois("Y ~ X \| fe", data=df)` | Poisson with fixed effects |
| `pf.feols("Y ~ X2 \| fe \| X1 ~ Z1", data=df)` | IV / 2SLS |
| `pf.did2s(data, yname, first_stage, second_stage, treatment, cluster)` | Gardner (2022) DiD |
| `pf.event_study(data, yname, idname, tname, gname, estimator)` | Unified event study |
| `pf.lpdid(data, yname, idname, tname, gname)` | Local projections DiD |

### Formula Syntax Quick Reference

| Pattern | Meaning | Example |
|---------|---------|---------|
| `Y ~ X1 + X2` | No FE | `"wage ~ educ + exper"` |
| `Y ~ X \| fe1 + fe2` | With FE | `"wage ~ educ \| state + year"` |
| `Y ~ X \| fe \| endog ~ inst` | FE + IV | `"wage ~ exper \| state \| educ ~ college_prox"` |
| `i(factor, ref=val)` | Categorical with ref | `"Y ~ i(year, ref=2000) \| state"` |
| `sw(X1, X2)` | Stepwise alternatives | `"Y ~ sw(educ, exper) \| state"` |
| `csw0(X1, X2)` | Cumulative stepwise | `"Y ~ csw0(educ, exper) \| state"` |
| `Y1 + Y2 ~ X` | Multiple outcomes | `"wage + hours ~ educ \| state"` |

### Post-Estimation Essentials

```python
fit = pf.feols("Y ~ X1 + X2 | fe", data=df)

fit.summary()                          # Print results
fit.tidy()                             # DataFrame of coefficients
fit.vcov("hetero")                     # Re-estimate with robust SEs (requires arg)
fit.vcov({"CRV1": "state"})            # Re-estimate with clustered SEs
fit.coef()                             # Coefficient values
fit.se()                               # Standard errors
fit.confint()                          # Confidence intervals
fit.predict()                          # Fitted values
fit.resid()                            # Residuals
fit.fixef()                            # Dict of FE name → numpy array (not a DataFrame)
```

### Reporting

```python
pf.etable([fit1, fit2, fit3])          # Regression table
pf.coefplot([fit1, fit2])              # Coefficient plot
pf.iplot(fit)                          # Event study / interaction plot
pf.panelview(data, unit, time, treat)  # Treatment pattern visualization
```

## Topic Index

| Topic | Reference File |
|-------|---------------|
| Installation | `./references/quickstart.md` |
| First regression | `./references/quickstart.md` |
| Formula syntax | `./references/quickstart.md` |
| SE comparison table | `./references/quickstart.md` |
| Multi-way fixed effects | `./references/fixed-effects.md` |
| Standard error types | `./references/fixed-effects.md` |
| Clustered SEs | `./references/fixed-effects.md` |
| HAC / Newey-West | `./references/fixed-effects.md` |
| Backend options | `./references/fixed-effects.md` |
| IV formula syntax | `./references/instrumental-variables.md` |
| First-stage diagnostics | `./references/instrumental-variables.md` |
| Weak instrument tests | `./references/instrumental-variables.md` |
| TWFE | `./references/difference-in-differences.md` |
| did2s | `./references/difference-in-differences.md` |
| Local projections DiD | `./references/difference-in-differences.md` |
| Sun-Abraham | `./references/difference-in-differences.md` |
| Event study plots | `./references/difference-in-differences.md` |
| Parallel trends | `./references/difference-in-differences.md` |
| panelview | `./references/difference-in-differences.md` |
| etable | `./references/tables-and-plots.md` |
| coefplot | `./references/tables-and-plots.md` |
| iplot | `./references/tables-and-plots.md` |
| dtable | `./references/tables-and-plots.md` |
| Wild cluster bootstrap | `./references/advanced-inference.md` |
| Randomization inference | `./references/advanced-inference.md` |
| Multiple testing corrections | `./references/advanced-inference.md` |
| Gelbach decomposition | `./references/advanced-inference.md` |
| CCV | `./references/advanced-inference.md` |
| Multiple estimation | `./references/integration.md` |
| Poisson regression | `./references/integration.md` |
| GLM (logit/probit) | `./references/integration.md` |
| Quantile regression | `./references/integration.md` |
| marginaleffects | `./references/integration.md` |
| Online learning | `./references/integration.md` |
| Performance tuning | `./references/integration.md` |
| Polars DataFrame input | `./references/gotchas.md` |
| Polars-to-pandas conversion | `./references/quickstart.md` |
| DiD clustering level | `./references/difference-in-differences.md` |
| v0.40 breaking changes | `./references/gotchas.md` |
| feglm FE limitation | `./references/gotchas.md` |
| numba issues | `./references/gotchas.md` |
| Formula parsing | `./references/gotchas.md` |
| R fixest differences | `./references/gotchas.md` |

## Citation

When this library is used as a primary analytical tool, include in the report's
Software & Tools references:

> Berge, L., Butts, K., & McDermott, G. (2026). pyfixest: Fast high-dimensional fixed effects estimation [Computer software]. Based on fixest (R).

**Cite when:** pyfixest is used for regression estimation (OLS, Poisson, IV) or difference-in-differences analysis.
**Do not cite when:** Only imported but no estimation performed.

For method-specific citations (e.g., individual DiD estimators or inference techniques),
consult the reference files in this skill and `agent_reference/CITATION_REFERENCE.md`.
