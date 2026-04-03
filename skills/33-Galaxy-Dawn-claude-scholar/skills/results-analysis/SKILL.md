---
name: results-analysis
description: This skill should be used when the user asks to "analyze experimental results", "run strict statistical analysis", "compare model performance", "generate scientific figures", "check significance", "do ablation analysis", or mentions interpreting experiment data with rigorous statistics and visualization. It focuses on strict analysis bundles, not Results-section prose.
tags: [Research, Analysis, Statistics, Visualization, Scientific Reporting]
version: 0.2.0
---

# Results Analysis

Run **strict, evidence-first experimental analysis** for ML/AI research.

Use this skill to produce a **strict analysis bundle**:
- `analysis-report.md`
- `stats-appendix.md`
- `figure-catalog.md`
- `figures/`

Do **not** use this skill to draft a paper `Results` section or a full experiment wrap-up report. Those belong to `ml-paper-writing` or `results-report`.

## Core contract

### This skill is responsible for
- validating experiment artifacts and comparison units,
- running rigorous descriptive and inferential statistics,
- generating **real scientific figures** when data/logs are available,
- writing figure purposes, caption requirements, and interpretation checklists,
- surfacing limits, blockers, and missing evidence explicitly.

### This skill is not responsible for
- paper-ready `Results` prose,
- manuscript narrative polishing,
- project-level experiment retrospectives.

If the user wants the complete post-experiment summary report, hand off to `results-report` after this bundle is ready.

## Non-negotiable quality bar

1. **Prefer real figures over figure specs.**
   If the data can be read, generate real figures. Do not stop at “recommended visualization”.
2. **Never fabricate statistics.**
   If sample size, seeds, or raw metrics are missing, state the blocker clearly.
3. **Report complete statistics.**
   Do not report only best scores or only p-values.
4. **Interpret every main figure.**
   Every major figure must have purpose, caption requirements, and post-figure interpretation notes.
5. **Separate evidence from prose.**
   This skill produces analysis artifacts; it does not write manuscript sections.

## Standard workflow

### 1. Inventory and validate artifacts

Start by identifying:
- metric tables (`csv`, `json`, `tsv`, logs),
- training curves and checkpoints,
- seeds / repeated runs,
- baselines, ablations, and comparison families,
- evaluation protocol metadata.

Validate:
- metric direction (higher/lower is better),
- unit of analysis (run, subject, fold, dataset, seed),
- number of runs / seeds,
- missing values or silent failures,
- comparability across methods.

If the comparison is not statistically valid, say so before continuing.

### 2. Lock the comparison questions

Before running statistics, define the exact comparison questions:
- Which method is compared to which baseline?
- What is the primary metric?
- What is the repeated-measure unit?
- Which ablation or robustness questions matter?
- Which findings are decision-changing?

Do not mix unrelated comparisons into one undifferentiated table.

### 3. Run strict statistics

Always produce:
- descriptive statistics: `mean ± std` when appropriate,
- `95% CI` or another clearly justified interval,
- run/seed counts,
- significance tests with assumptions stated,
- effect sizes,
- multiple-comparison handling when several contrasts are reported.

Default expectation:
- check parametric assumptions first,
- use non-parametric fallback when assumptions fail,
- state exactly what was tested and on what samples.

See:
- `references/statistical-methods.md`
- `references/statistical-reporting.md`

### 4. Generate real scientific figures

Produce actual figures whenever artifacts are available.

Minimum expectation for a non-trivial analysis bundle:
- **one main comparison figure**,
- **one supporting figure** (training dynamics / ablation / breakdown / error analysis),
- **one exact numeric summary table** in markdown.

Every main figure must define:
- figure purpose,
- plotted variables,
- error bar meaning,
- caption requirements,
- interpretation checklist.

See:
- `references/visualization-best-practices.md`
- `references/figure-interpretation.md`

### 5. Write analysis artifacts

#### `analysis-report.md`
Summarize:
- the analysis question,
- key findings,
- strongest supported comparisons,
- main caveats,
- what changed in the experimental understanding.

#### `stats-appendix.md`
Record:
- descriptive statistics,
- test choices,
- assumptions checked,
- effect sizes,
- confidence intervals,
- multiple comparison corrections,
- explicit blockers and limitations.

#### `figure-catalog.md`
For each figure, record:
- filename,
- purpose,
- data source,
- caption draft requirements,
- key observation,
- interpretation checklist,
- known caveats.

### 6. Final QA gate

Do not finish until all are true:
- [ ] the primary comparison question is explicit,
- [ ] sample size / seed count is stated,
- [ ] inferential tests are justified,
- [ ] effect sizes are reported for major contrasts,
- [ ] real figures exist when data exists,
- [ ] each figure has an interpretation note,
- [ ] limitations and blockers are explicit,
- [ ] no manuscript-style `Results` draft is included.

## Output structure

```text
analysis-output/
├── analysis-report.md
├── stats-appendix.md
├── figure-catalog.md
└── figures/
    ├── figure-01-main-comparison.pdf
    ├── figure-02-ablation.pdf
    └── ...
```

## Figure interpretation rule

For every major figure, answer all three questions:
1. **Why does this figure exist?**
2. **What exactly should the reader notice?**
3. **What does that observation change in our belief or next decision?**

If a figure cannot answer question 3, it is probably decorative rather than scientific.

## Failure mode policy

When inputs are incomplete, say so explicitly.

Examples:
- no seed-level data -> descriptive summary only; inferential claims blocked,
- no comparable baseline outputs -> no significance claim,
- no readable logs -> cannot generate dynamics figure,
- too few runs -> effect size may be unstable; report this limitation.

Never replace missing evidence with confident prose.

## Reference files

Load only what is needed:
- `references/statistical-methods.md` - test selection and assumptions
- `references/statistical-reporting.md` - minimum reporting standard
- `references/visualization-best-practices.md` - publication-quality figure rules
- `references/figure-interpretation.md` - how to explain figures with evidence
- `references/analysis-depth.md` - move from observation to mechanism and decision
- `references/common-pitfalls.md` - common analysis and reporting failures

## Example files

- `examples/example-analysis-report.md`
- `examples/example-stats-appendix.md`
- `examples/example-figure-catalog.md`
