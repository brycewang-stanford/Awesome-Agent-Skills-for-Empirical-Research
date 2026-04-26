# Card (1995) — Returns to schooling, full StatsPAI empirical pipeline

A worked example of the
[`00-Full-empirical-analysis-skill_StatsPAI`](../skills/00-Full-empirical-analysis-skill_StatsPAI/SKILL.md)
skill applied to the canonical IV study from David Card,
*"Using Geographic Variation in College Proximity to Estimate the Return
to Schooling"* (1995). Two execution paths are provided, both producing
identical artifacts:

- [`card_returns_to_schooling_pipeline.py`](card_returns_to_schooling_pipeline.py) — single-file script (`python3 card_returns_to_schooling_pipeline.py`)
- [`card_returns_to_schooling_pipeline.ipynb`](card_returns_to_schooling_pipeline.ipynb) — sectioned notebook with markdown commentary per AER step

## Research question and design

| | |
|---|---|
| **Outcome**     | `lwage` — log of hourly wage in 1976 |
| **Treatment**   | `educ` — years of completed schooling (continuous, 1–18) |
| **Instrument**  | `nearc4` — 1 if grew up in a county with a 4-year college |
| **Controls**    | `exper`, `expersq`, `black`, `south`, `smsa`, `smsa66`, region dummies (reg662–reg669) |
| **Estimand**    | LATE — return to one extra year of schooling for compliers whose schooling is shifted by college proximity |
| **Estimator**   | 2SLS with HC1 robust SE |
| **Sample**      | NLSYM men aged 24–34 in 1976, n = 3,010 |

The estimating equations are documented in
[`artifacts/empirical_strategy.md`](artifacts/empirical_strategy.md), which
is **frozen to disk before any estimation runs** as the pre-registration
artifact (see Step 2 of the skill).

## Headline results

| Estimator | β̂ on `educ` | 95% CI |
|---|---:|---:|
| OLS bivariate | 0.052 | [0.046, 0.058] |
| OLS + Mincer + demographics + region FE | 0.075 | [0.068, 0.082] |
| **2SLS (nearc4)** | **0.132** | **[0.025, 0.238]** |
| 2SLS (nearc2 + nearc4) | 0.157 | (Hansen J p = 0.26) |
| DML PLR | reported in `tableA1_robustness` |

- First-stage coefficient on `nearc4` = +0.32 (SE = 0.085); first-stage F ≈ 13–14.
- Reduced-form effect on `lwage` = +0.042 (SE = 0.018), so the Wald-ratio
  matches 2SLS exactly: 0.042 / 0.32 = 0.132.
- Oster (2019) δ\* = 16.4 — selection on unobservables would have to be
  16× as strong as selection on observables to overturn the OLS estimate.
- Specification curve and 10-row robustness master table show the OLS
  point estimate sits in [0.069, 0.075] across every alternative
  specification; the 2SLS estimate sits in [0.13, 0.16].

## Output layout

```
demo-StatsPAI-skill/
├── card_returns_to_schooling_pipeline.py     # one-file Python script
├── card_returns_to_schooling_pipeline.ipynb  # same pipeline as a notebook
├── data/
│   └── card.csv                              # 3,010 × 34, from the wooldridge package
├── artifacts/                                # pre-registration & metadata
│   ├── sample_construction.json              # footnote-4 sample log
│   ├── data_contract.json                    # 5-check go/no-go gate
│   ├── empirical_strategy.md                 # estimand + identifying assumptions
│   ├── causal_question.yaml                  # machine-readable sidecar
│   ├── codebook.md                           # auto-generated variable codebook
│   ├── oster.txt                             # Oster (2019) bound + δ
│   ├── unified_sensitivity.txt               # Cinelli–Hazlett summary
│   ├── evalue.txt                            # E-value for the OLS estimate
│   └── result.json                           # reproducibility stamp
├── tables/                                   # AER-style tables (.docx / .xlsx / .tex)
│   ├── table1_summary.{docx,xlsx,tex}        # Table 1 — summary statistics
│   ├── table2_main_ols.*                     # Table 2  — OLS progressive controls
│   ├── table2b_iv_triplet.*                  # Table 2-bis — 1st stage / RF / 2SLS
│   ├── table2c_design_horserace.*            # Table 2-ter — OLS vs 2SLS vs DML
│   ├── table2d_multi_outcome.*               # Table 2-quater — log-wage vs wage
│   ├── table3_heterogeneity.*                # Table 3 — subgroups
│   ├── table3b_interactions.*                # Table 3-bis — interaction form
│   ├── table4_cate_by_black.csv              # CATE by race (DR-Learner)
│   └── tableA1_robustness.{docx,xlsx,tex}    # Table A1 — robustness gauntlet
├── figures/                                  # all 9 publication figures (PNG, 200 dpi)
│   ├── fig1_education_by_proximity.png
│   ├── fig2a_first_stage_binscatter.png
│   ├── fig2b_mincer.png
│   ├── fig3_coefplot_main.png
│   ├── fig4a_cate_hist.png
│   ├── fig4b_cate_by_group.png
│   ├── fig5_spec_curve.png
│   ├── fig5b_robustness_forest.png
│   └── fig6_sensitivity_dashboard.png
└── replication/                              # one-stop bundle (sp.collect)
    └── paper.{docx,xlsx,tex,md}
```

## Reproducing the analysis

```bash
# from the repository root
cd demo-StatsPAI-skill

# Option A — script
python3 card_returns_to_schooling_pipeline.py

# Option B — notebook
python3 -m jupyter nbconvert --to notebook --execute --inplace \
    card_returns_to_schooling_pipeline.ipynb
```

Dependencies: `statspai >= 1.6.6`, `pandas`, `numpy`, `matplotlib`,
`nbformat`, `nbconvert`, `ipykernel`, `wooldridge` (only used to (re)build
`data/card.csv` if missing). The bundled `data/card.csv` makes the
pipeline self-contained — neither `wooldridge` nor an internet connection
is required to re-run.

## Mapping back to the StatsPAI skill

| Skill section | Notebook section | Artifacts |
|---|---|---|
| Step 0 — sample construction & data contract  | `[Step 0]` | `artifacts/sample_construction.json`, `data_contract.json` |
| Step 1 — descriptive statistics (Table 1)     | `[Step 1]` | `tables/table1_summary.*`, `figures/fig1_*` |
| Step 2 — empirical strategy + IdentificationPlan | `[Step 2]` | `artifacts/empirical_strategy.md`, `causal_question.yaml` |
| Step 3 — identification graphics              | `[Step 3]` | `figures/fig2a_*`, `fig2b_*` |
| Step 4 — main results (Table 2)               | `[Step 4]` | `tables/table2_*`, `figures/fig3_*` |
| Step 5 — heterogeneity (Table 3 + CATE)       | `[Step 5]` | `tables/table3_*`, `figures/fig4*` |
| Step 7 — robustness gauntlet                  | `[Step 7]` | `tables/tableA1_robustness.*`, `figures/fig5*`, `fig6*`, `artifacts/oster.txt` |
| Step 8 — replication bundle                   | `[Step 8]` | `replication/paper.{docx,xlsx,tex,md}`, `artifacts/result.json` |

## Reference

Card, D. (1995). *Using geographic variation in college proximity to
estimate the return to schooling.* In *Aspects of labour market
behaviour* (pp. 201–222). Univ. of Toronto Press.
