# Statistical Appendix

## Primary Metric
- Word Error Rate (WER), lower is better.

## Sample Structure
- Unit of analysis: seed-level run, paired by shared data split and subject pool.
- Number of seeds per condition: 5.

## Descriptive Statistics

| Condition | Mean WER | Std | 95% CI |
|---|---:|---:|---:|
| Full fine-tuning | 31.4 | 1.9 | [29.8, 33.0] |
| Subject Adapter | 33.2 | 1.3 | [32.1, 34.3] |
| Frozen Encoder | 37.0 | 2.1 | [35.1, 38.9] |

## Assumption Checks
- Shapiro-Wilk on paired differences: `p = 0.19`
- No strong evidence against normality for the primary contrast.
- Given small n, interpretation remains conservative.

## Inferential Tests

| Contrast | Test | Statistic | p | Effect size | Correction |
|---|---|---|---:|---:|---|
| Subject Adapter vs Frozen Encoder | paired t-test | `t(4) = -4.11` | 0.014 | Cohen's `d = 1.84` | Holm |
| Full fine-tuning vs Subject Adapter | paired t-test | `t(4) = -2.03` | 0.112 | Cohen's `d = 0.91` | Holm |

## Interpretation Guardrails
- First contrast is supported after correction.
- Second contrast trends in favor of full fine-tuning but is not conclusive at this sample size.

## Blockers / Limits
- No subject-level bootstrap yet.
- No calibration analysis available.
