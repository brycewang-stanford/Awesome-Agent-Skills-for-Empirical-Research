# Strict Analysis Report

## Analysis Question
- Compare Full Model, Frozen Encoder, and Subject Adapter on cross-subject decoding.
- Determine whether the adapter closes the transfer gap without sacrificing stability.

## Data Inventory
- 3 model families
- 5 random seeds per family
- subject-level WER and CER
- training logs for convergence
- ablation outputs for adapter width

## Executive Summary
- Subject Adapter improves mean WER over Frozen Encoder by 3.8 absolute points.
- The improvement is statistically significant under paired testing after multiple-comparison correction.
- Full fine-tuning remains strongest overall, but Subject Adapter offers the best compute-performance tradeoff.
- Performance variance is lower than Frozen Encoder, suggesting a more stable transfer path.

## Main Findings

### 1. Main comparison
- Full fine-tuning: `31.4 ± 1.9` WER
- Subject Adapter: `33.2 ± 1.3` WER
- Frozen Encoder: `37.0 ± 2.1` WER

Observation:
- Subject Adapter consistently outperforms Frozen Encoder across all 5 seeds.

Interpretation:
- The transfer bottleneck is not purely feature reuse; a light adaptation head captures subject-specific alignment that freezing alone misses.

Implication:
- Future work should prioritize adapter variants before investing in heavier full-model tuning.

### 2. Stability
- Subject Adapter has the smallest seed variance among transfer-friendly methods.
- Convergence curves show less oscillation after epoch 8.

Interpretation:
- Adapter tuning is not only better on average, but easier to optimize.

### 3. Ablation
- Reducing adapter width from 256 to 64 hurts WER by 1.6 points.
- Increasing from 256 to 512 yields only marginal improvement.

Interpretation:
- Most of the benefit is captured at moderate width; scale-up is not the current bottleneck.

## Caveats
- Only 5 seeds; inference about tails remains limited.
- Subject count is modest, so subject-level heterogeneity may still be under-estimated.
- Training-time comparison depends on identical hardware assumptions.

## Recommended Next Move
- Promote this finding into a `results-report` note focused on adapter vs freezing.
- Run one robustness pass on held-out low-resource subjects.
