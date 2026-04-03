---
name: linearmodels
description: >-
  Panel data, IV/GMM, system regression. PanelOLS (FE/RE), BetweenOLS, Fama-MacBeth, IV2SLS/LIML/GMM, SUR, 3SLS, Driscoll-Kraay SEs. Use for RE/between, system estimation, or GMM. Complements pyfixest (FE + DiD) and statsmodels (GLM + time series).
metadata:
  audience: research-coders
  domain: python-library
  library-version: "7.0"
  skill-last-updated: "2026-03-27"
---

# linearmodels Skill

linearmodels: panel data, IV/GMM, system regression, and asset pricing models in Python. Covers PanelOLS (FE/RE), BetweenOLS, FirstDifferenceOLS, Fama-MacBeth, IV2SLS/LIML/GMM, SUR, IV3SLS, and Driscoll-Kraay SEs. Use for random effects estimation, between or first-difference panel models, system estimation (SUR, 3SLS), LIML/GMM instrumental variables, Fama-MacBeth regressions, or Driscoll-Kraay standard errors. Complements pyfixest (high-dimensional FE + DiD) and statsmodels (GLM + time series).

Comprehensive skill for panel data estimation, instrumental variables, system regression, and asset pricing with linearmodels (Kevin Sheppard). Use decision trees below to find the right guidance, then load detailed references.

## What is linearmodels?

linearmodels extends statsmodels with specialized model classes for structured data:
- **Panel data**: PanelOLS (fixed effects), RandomEffects, BetweenOLS, FirstDifferenceOLS, PooledOLS, FamaMacBeth
- **Instrumental variables**: IV2SLS, IVLIML (k-class), IVGMM, IVGMMCUE (continuously updating), AbsorbingLS
- **System estimation**: SUR (Seemingly Unrelated Regression), IV3SLS, IVSystemGMM
- **Asset pricing**: LinearFactorModel, LinearFactorModelGMM, TradedFactorModel
- **Rich inference**: Driscoll-Kraay, clustered (1- and 2-way), HAC kernels (Bartlett, Parzen, Quadratic Spectral)
- **Dual API**: Formula-based (via formulaic) and array-based interfaces

## How to Use This Skill

### Reference File Structure

| File | Purpose | When to Read |
|------|---------|--------------|
| `quickstart.md` | Installation, MultiIndex setup, formula vs array API, first model | Starting with linearmodels |
| `panel-models.md` | PanelOLS, RandomEffects, BetweenOLS, FD, Pooled, FamaMacBeth | Panel data estimation |
| `iv-models.md` | IV2SLS, IVLIML, IVGMM, IVGMMCUE, AbsorbingLS | IV / GMM estimation |
| `system-models.md` | SUR, IV3SLS, IVSystemGMM, cross-equation constraints | System estimation |
| `asset-pricing.md` | LinearFactorModel, TradedFactorModel, GMM estimation | Asset pricing tests |
| `covariance-inference.md` | All SE types, Driscoll-Kraay, clustering, GMM weights | Choosing standard errors |
| `gotchas.md` | MultiIndex requirement, pyfixest/statsmodels boundary, limits | Debugging issues |

### Reading Order

1. **New to linearmodels?** Start with `quickstart.md` then `panel-models.md`
2. **Need IV/GMM?** Read `quickstart.md` then `iv-models.md`
3. **System estimation (SUR/3SLS)?** Read `quickstart.md` then `system-models.md`
4. **Asset pricing?** Read `quickstart.md` then `asset-pricing.md`
5. **Choosing SEs?** Read `covariance-inference.md`
6. **Coming from pyfixest?** Read `quickstart.md` then `gotchas.md`

## Related Skills

| Skill | Relationship |
|-------|-------------|
| `pyfixest` | Preferred for high-dimensional FE, FE + IV, DiD, fast demeaning, publication tables. Use linearmodels when pyfixest cannot do what you need (RE, system models, LIML/GMM, Fama-MacBeth) |
| `statsmodels` | Foundation library. Use statsmodels for GLM, time series, diagnostics. linearmodels extends statsmodels for panel/IV/system models |
| `svy` | Survey-weighted regression with complex survey designs. linearmodels supports `weights` for population/precision weighting in panel models, but this is NOT equivalent to design-based survey inference — it does not handle stratification, clustering as a design feature, or replicate weights. If your data comes from a complex probability survey, use `svy` |
| `data-scientist` | Methodology guidance — load for "why and when" behind model choices |
| `polars` | Data preparation before estimation; convert to pandas with `.to_pandas()` before passing to linearmodels |

## Quick Decision Trees

### "I need a panel model"

```
What panel estimation method?
├─ Fixed effects (within estimator)
│   ├─ 1-2 way FE, no IV → linearmodels PanelOLS or pyfixest feols
│   ├─ 3+ way FE → pyfixest (linearmodels max 2-way in PanelOLS)
│   ├─ FE + IV combined → pyfixest (linearmodels has no Panel IV)
│   └─ FE + DiD → pyfixest (linearmodels has no DiD)
├─ Random effects (GLS) → linearmodels RandomEffects
│   └─ → ./references/panel-models.md
├─ FE vs RE comparison → linearmodels (run both, compare)
│   └─ → ./references/panel-models.md
├─ Between estimator → linearmodels BetweenOLS
│   └─ → ./references/panel-models.md
├─ First difference → linearmodels FirstDifferenceOLS
│   └─ → ./references/panel-models.md
├─ Pooled OLS (panel-aware SEs) → linearmodels PooledOLS
│   └─ → ./references/panel-models.md
└─ Fama-MacBeth → linearmodels FamaMacBeth
    └─ → ./references/panel-models.md
```

### "I need IV / GMM estimation"

```
What IV method?
├─ 2SLS (standard IV)
│   ├─ With fixed effects → pyfixest (linearmodels has no Panel IV)
│   └─ Without FE → linearmodels IV2SLS or pyfixest
│       └─ → ./references/iv-models.md
├─ LIML / k-class (better finite-sample) → linearmodels IVLIML
│   └─ → ./references/iv-models.md
├─ GMM-IV (efficient, overidentified) → linearmodels IVGMM
│   └─ → ./references/iv-models.md
├─ Continuously updating GMM → linearmodels IVGMMCUE
│   └─ → ./references/iv-models.md
└─ High-dimensional absorbed FE (OLS) → linearmodels AbsorbingLS
    └─ → ./references/iv-models.md
```

### "I need system estimation"

```
System of equations?
├─ Multiple equations, correlated errors → SUR
│   └─ → ./references/system-models.md
├─ Multiple equations + endogenous variables → IV3SLS
│   └─ → ./references/system-models.md
├─ System GMM → IVSystemGMM
│   └─ → ./references/system-models.md
├─ Cross-equation parameter restrictions → LinearConstraint
│   └─ → ./references/system-models.md
└─ Not sure which → Start with SUR
    └─ → ./references/system-models.md
```

### "Something isn't working"

```
Having issues?
├─ TypeError about DataFrame index → ./references/gotchas.md
├─ Need FE + IV in one model → ./references/gotchas.md
├─ Need 3+ way fixed effects → ./references/gotchas.md
├─ Constant term confusion → ./references/gotchas.md
├─ Formula parsing errors → ./references/gotchas.md
├─ Want to compare with pyfixest → ./references/gotchas.md
└─ SUR performance issues → ./references/gotchas.md
```

## File-First Execution in Research Workflows

**Important:** In data research pipelines (see `CLAUDE.md`), linearmodels estimation is executed through **script files**, not interactively. This ensures auditability and reproducibility.

**The pattern:**
1. Write model code to `scripts/stage8_analysis/{step}_{task-name}.py`
2. Execute via Bash with automatic output capture wrapper script
3. Validation results get automatically embedded in scripts as comments
4. If failed, create versioned copy for fixes

Closely read `agent_reference/SCRIPT_EXECUTION_REFERENCE.md` for the mandatory file-first execution protocol covering complete code file writing, output capture, and file versioning rules.

The examples below show linearmodels syntax. In research workflows, wrap them in scripts following the file-first pattern.

---

## Quick Reference

### Essential Imports

```python
from linearmodels.panel import PanelOLS, RandomEffects, BetweenOLS
from linearmodels.panel import FirstDifferenceOLS, PooledOLS, FamaMacBeth
from linearmodels.iv import IV2SLS, IVLIML, IVGMM, IVGMMCUE, AbsorbingLS
from linearmodels.system import SUR, IV3SLS, IVSystemGMM
from linearmodels.panel import compare  # Panel model comparison tables
```

### Data Setup (Critical — MultiIndex Required for Panel Models)

```python
import pandas as pd

# Panel data MUST have a MultiIndex with (entity, time)
df = df.set_index(["entity_id", "year"])

# Verify the index
print(f"Index names: {df.index.names}")
print(f"Index levels: {df.index.nlevels}")
```

### Core Operations

| Operation | Code |
|-----------|------|
| Panel FE (formula) | `PanelOLS.from_formula("y ~ x1 + x2 + EntityEffects", data=df).fit()` |
| Panel FE (array) | `PanelOLS(df.y, df[["x1","x2"]], entity_effects=True).fit()` |
| Two-way FE | `PanelOLS.from_formula("y ~ x1 + EntityEffects + TimeEffects", data=df).fit()` |
| Random effects | `RandomEffects.from_formula("y ~ 1 + x1 + x2", data=df).fit()` |
| Between OLS | `BetweenOLS.from_formula("y ~ 1 + x1 + x2", data=df).fit()` |
| First difference | `FirstDifferenceOLS.from_formula("y ~ x1 + x2", data=df).fit()` |
| Fama-MacBeth | `FamaMacBeth.from_formula("y ~ 1 + x1 + x2", data=df).fit()` |
| IV / 2SLS | `IV2SLS.from_formula("y ~ 1 + exog + [endog ~ inst]", data=df).fit()` |
| LIML | `IVLIML.from_formula("y ~ 1 + exog + [endog ~ inst]", data=df).fit()` |
| Clustered SEs | `mod.fit(cov_type="clustered", cluster_entity=True)` |
| Driscoll-Kraay | `mod.fit(cov_type="kernel", kernel="bartlett", bandwidth=5)` |
| Summary | `results.summary` |
| Model comparison | `compare({"FE": fe_res, "RE": re_res})` |

### Formula Syntax

```python
# Panel FE keywords (appear in formula, not after |)
"y ~ x1 + x2 + EntityEffects"               # Entity FE
"y ~ x1 + x2 + EntityEffects + TimeEffects"  # Two-way FE
"y ~ x1 + x2 + TimeEffects"                  # Time FE only

# IV bracket notation
"y ~ 1 + exog + [endog ~ instrument1 + instrument2]"

# Suppress intercept
"y ~ x1 + x2 - 1"
```

## Topic Index

| Topic | Reference File |
|-------|---------------|
| Installation | `./references/quickstart.md` |
| MultiIndex data setup | `./references/quickstart.md` |
| Formula vs array API | `./references/quickstart.md` |
| First model | `./references/quickstart.md` |
| Syntax comparison (pyfixest, statsmodels) | `./references/quickstart.md` |
| PanelOLS (entity/time effects) | `./references/panel-models.md` |
| RandomEffects | `./references/panel-models.md` |
| BetweenOLS | `./references/panel-models.md` |
| FirstDifferenceOLS | `./references/panel-models.md` |
| PooledOLS | `./references/panel-models.md` |
| FamaMacBeth | `./references/panel-models.md` |
| FE vs RE decision | `./references/panel-models.md` |
| Variance decomposition | `./references/panel-models.md` |
| Weighted panel estimation | `./references/panel-models.md` |
| R-squared types (within, between, overall) | `./references/panel-models.md` |
| IV2SLS | `./references/iv-models.md` |
| IVLIML and k-class estimators | `./references/iv-models.md` |
| IVGMM (1-step, 2-step, iterative) | `./references/iv-models.md` |
| IVGMMCUE | `./references/iv-models.md` |
| AbsorbingLS (high-dim FE OLS) | `./references/iv-models.md` |
| First-stage diagnostics | `./references/iv-models.md` |
| Overidentification tests | `./references/iv-models.md` |
| SUR (Seemingly Unrelated Regression) | `./references/system-models.md` |
| IV3SLS | `./references/system-models.md` |
| IVSystemGMM | `./references/system-models.md` |
| Cross-equation constraints | `./references/system-models.md` |
| LinearFactorModel | `./references/asset-pricing.md` |
| TradedFactorModel | `./references/asset-pricing.md` |
| Factor model GMM | `./references/asset-pricing.md` |
| Driscoll-Kraay SEs | `./references/covariance-inference.md` |
| Clustered SEs (entity, time, both) | `./references/covariance-inference.md` |
| HAC / kernel covariance | `./references/covariance-inference.md` |
| GMM weight matrices | `./references/covariance-inference.md` |
| Debiased inference | `./references/covariance-inference.md` |
| MultiIndex requirement | `./references/gotchas.md` |
| Maximum 2-way FE limit | `./references/gotchas.md` |
| No Panel IV | `./references/gotchas.md` |
| pyfixest vs linearmodels boundary | `./references/gotchas.md` |
| statsmodels vs linearmodels boundary | `./references/gotchas.md` |
| Constant term handling | `./references/gotchas.md` |

## Citation

When this library is used as a primary analytical tool, include in the report's
Software & Tools references:

> Sheppard, K. linearmodels: Econometric models for panel data, IV/GMM, and system regression [Computer software]. https://bashtage.github.io/linearmodels/

**Cite when:** linearmodels is used for panel estimation (RE, between), IV/GMM, Fama-MacBeth, or system regression (SUR, 3SLS).
**Do not cite when:** Only imported but no estimation performed.

For method-specific citations (e.g., individual estimators or techniques),
consult the reference files in this skill and `agent_reference/CITATION_REFERENCE.md`.
