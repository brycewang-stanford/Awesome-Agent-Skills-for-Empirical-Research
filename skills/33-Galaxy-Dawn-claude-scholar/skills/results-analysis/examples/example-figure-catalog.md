# Figure Catalog

## Figure 1 — Main comparison
- **Filename**: `figures/figure-01-main-comparison.pdf`
- **Purpose**: Compare WER across Full fine-tuning, Subject Adapter, and Frozen Encoder.
- **Data source**: `metrics/summary.csv`
- **Plot type**: Bar + scatter overlay of seed-level points.
- **Error bars**: 95% CI.
- **Caption must include**:
  - metric direction,
  - number of seeds,
  - meaning of error bars,
  - whether significance markers are corrected.
- **Key observation**: Subject Adapter closes most of the freezing gap.
- **Interpretation checklist**:
  - Is the adapter improvement consistent across seeds?
  - Is the gap practically meaningful, not just statistically significant?
  - Does the figure support a design decision?

## Figure 2 — Convergence dynamics
- **Filename**: `figures/figure-02-training-dynamics.pdf`
- **Purpose**: Compare optimization stability over epochs.
- **Data source**: `logs/train_curves.csv`
- **Plot type**: Mean line + uncertainty ribbon.
- **Caption must include**:
  - smoothing rule if any,
  - whether ribbon is std or CI,
  - training/eval split.
- **Key observation**: Frozen Encoder shows larger oscillation after epoch 8.
- **Interpretation checklist**:
  - Is instability transient or persistent?
  - Does curve shape match final metric variance?
  - Does this explain why one method is harder to tune?
