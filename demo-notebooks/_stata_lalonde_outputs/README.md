# Stata Lalonde Pipeline — Output Inventory

This directory holds the artifacts produced by
[`../Stata_skill_lalonde_full_pipeline.do`](../Stata_skill_lalonde_full_pipeline.do).

## v2 alignment (2026-04-29)

The `.do` file was extended to mirror the v2 Python / R / StatsPAI demos:

| § | New block in the .do | Output |
|---|---|---|
| §-1 | Pre-Analysis Plan via `power twomeans` | `artifacts/pap.json` |
| §0 | Sample-construction log + 5-check data contract | `artifacts/sample_construction.json`, `artifacts/data_contract.json` |
| §2.5 | Empirical-strategy pre-registration | `artifacts/strategy.md` |
| §3.5 | Identification graphics — love plot + PS overlap | `figures/fig2c_love_plot.pdf`, `figures/fig2c2_overlap.pdf` |
| §6 (Pattern H) | Robustness master Table A1 + spec-curve forest | `tables/tableA1_robustness.{tex,rtf}`, `figures/fig5_spec_curve.pdf` |
| §8 | Reproducibility stamp | `artifacts/result.json` |

## Two execution paths

**(a) Run the full Stata pipeline locally** (recommended, produces all artifacts):

```bash
stata -b do ../Stata_skill_lalonde_full_pipeline.do
```

This single command rebuilds `artifacts/` + `figures/` + `tables/` + the legacy
Step 1–8 outputs from scratch.

**(b) Pre-generate just the language-agnostic artifacts** without Stata:

```bash
python3 _pregenerate_artifacts.py
```

This populates four files where the math doesn't need Stata at all
(`pap.json`, `sample_construction.json`, `data_contract.json`, `strategy.md`)
using the same `power twomeans` / sample-log numbers the .do file would
produce. Useful for CI environments or for a quick preview of what the
v2 contract layer looks like before you have Stata installed.

## Artifact files (current state)

```
artifacts/
  pap.json                  Pre-Analysis Plan       — Cohen's d MDE at 80% power
  sample_construction.json  Footnote-4 sample log
  data_contract.json        5-check go/no-go contract
  strategy.md               Equation × ID assumption × estimator pre-reg
  result.json               (a) only — produced by the .do; pins Stata version
                             + headline β̂ + 95% CI + pointers to all artifacts
figures/
  fig2c_love_plot.pdf       Love plot (psmatch2 + pstest, both graph)
  fig2c2_overlap.pdf        PS overlap density (twoway kdensity)
  fig5_spec_curve.pdf       β̂(treat) ± 95% CI across 10 robustness specs
  ... + legacy Step 8 figures (pscore_overlap, kde_re78, het_*, etc.)
tables/
  tableA1_robustness.tex    Pattern H — 10-column robustness master
  tableA1_robustness.rtf    Same table, Word-friendly
  ... + legacy Step 8 tables (table1_balance, table_main_estimators, etc.)
data/
  lalonde_analysis.dta      Step 1 cleaned analysis sample
logs/
  lalonde_pipeline.log      Captured run output
```

## Cross-language reproducibility

The headline ATT β̂ on `treat` (NSW training → re78 in dollars) lands at
**$+1,548 (95% CI [$78, $3,018], HC3 SE = $750)** under the full-controls OLS.
Identical to the values produced by the parallel Python notebook
(`_python_pipeline_outputs/artifacts/result.json`) and R notebook
(`_r_pipeline_outputs/artifacts/result.json`) — same data + same OLS + same
covariate set, three language ecosystems, one number.
