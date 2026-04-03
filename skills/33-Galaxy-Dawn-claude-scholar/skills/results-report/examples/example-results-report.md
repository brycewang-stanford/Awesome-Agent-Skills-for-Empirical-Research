---
type: results-report
date: 2026-03-18
experiment_line: freezing
round: 3
purpose: transfer-summary
status: active
source_artifacts:
  - analysis-output/analysis-report.md
  - analysis-output/stats-appendix.md
  - analysis-output/figure-catalog.md
linked_experiments:
  - Experiments/Freezing-vs-Adapter.md
linked_results:
  - Results/Adapter-Improves-Transfer.md
---

# Freezing / Round 3 / transfer-summary / 2026-03-18

## Executive Summary
- Round 3 tested whether a subject adapter recovers the performance lost by freezing most of the encoder.
- Across 5 seeds per condition, the adapter reduced mean WER by **3.8 absolute points** relative to the frozen encoder baseline.
- The current evidence supports keeping the adapter branch active, while pure freezing should be deprioritized.

## Experiment Identity and Decision Context
- Experiment line: freezing
- Round: 3
- Purpose: resolve whether the freezing gap is best handled by lightweight adaptation or by abandoning the freezing branch.
- Decision pressure: choose the next transfer branch before scheduling the next low-resource run block.

## Setup and Evaluation Protocol
- Same subject pool and split as rounds 1-2.
- 5 seeds per condition.
- Primary metric: WER (lower is better).
- Compared methods: Full fine-tuning, Subject Adapter, Frozen Encoder.
- Statistical unit: seed-level final WER.

## Main Findings
- Subject Adapter: **27.6 ± 1.0 WER**, 95% CI **[26.4, 28.8]**.
- Frozen Encoder: **31.4 ± 1.5 WER**, 95% CI **[29.6, 33.2]**.
- Full fine-tuning: **25.9 ± 0.8 WER**, 95% CI **[24.9, 26.9]**.
- Adapter beats Frozen Encoder in all 5 paired seed comparisons.

## Statistical Validation
- Adapter vs Frozen Encoder: paired Wilcoxon signed-rank test, **p = 0.031**, Holm-corrected **p = 0.047**, matched-rank biserial effect size **r = 0.90**.
- Full fine-tuning vs Adapter: paired t-test, **p = 0.11**, Cohen's **d = 0.64**.
- Interpretation: the adapter gain over pure freezing is supported at current `n = 5`; the gap to full fine-tuning is directionally consistent but still underpowered.
- Unsupported claim boundary: this report does **not** claim generalization beyond the current subject pool or low-resource regime.

## Figure-by-Figure Interpretation
### Figure 1 — Main comparison
- Why included: this is the core decision figure.
- Evidence carried in: mean WER, 95% CI, and paired-seed comparisons.
- Supported interpretation: lightweight subject adaptation closes most of the freezing gap.
- Decision implication: future transfer experiments should center on adapter design, not frozen-only variants.

### Figure 2 — Training dynamics
- Why included: to explain stability differences.
- Evidence carried in: per-epoch validation traces across seeds.
- Supported interpretation: the frozen baseline oscillates more after epoch 8, matching its wider uncertainty interval.
- Decision implication: branch weakness is not only lower final accuracy but also worse optimization stability.

## Failure Cases / Negative Results / Limitations
- Full fine-tuning still leads in absolute WER.
- The evidence is limited to one subject pool and 5 seeds.
- No low-resource stress test or out-of-domain subject split has been run yet.
- Adapter width was fixed in this round, so capacity trade-offs remain unresolved.

## What Changed Our Belief
- Before round 3, it was plausible that freezing should be abandoned entirely.
- After round 3, the better hypothesis is that freezing alone is too rigid, but freezing plus lightweight adaptation remains viable.

## Next Actions
- Run one low-resource robustness check for the adapter branch.
- Add a width ablation around the current best adapter size.
- Update the canonical result note for adapter-improves-transfer.

## Artifact and Reproducibility Index
- `analysis-output/analysis-report.md`
- `analysis-output/stats-appendix.md`
- `analysis-output/figure-catalog.md`
- `analysis-output/figures/figure-01-main-comparison.pdf`
- `analysis-output/figures/figure-02-training-dynamics.pdf`
