# Synthetic Control — Implementation Reference

## Standard Synthetic Control

```python
# Python: SparseSC, pensynth, or manual implementation
# The R package Synth is the standard reference implementation

import numpy as np
from scipy.optimize import minimize

def synthetic_control(Y, treated_idx, pre_periods, post_periods):
    """
    Basic synthetic control: find weights W such that
    Y_treated(pre) ≈ Y_controls(pre) @ W

    Y: (T x N) matrix of outcomes
    treated_idx: index of treated unit
    pre_periods: indices of pre-treatment periods
    post_periods: indices of post-treatment periods
    """
    Y_pre = Y[pre_periods, :]
    control_idx = [i for i in range(Y.shape[1]) if i != treated_idx]

    Y1_pre = Y_pre[:, treated_idx]           # treated unit, pre-treatment
    Y0_pre = Y_pre[:, control_idx]            # control units, pre-treatment

    n_controls = len(control_idx)

    # Minimize || Y1_pre - Y0_pre @ w ||^2
    # subject to: w >= 0, sum(w) = 1
    def objective(w):
        return np.sum((Y1_pre - Y0_pre @ w) ** 2)

    constraints = [
        {'type': 'eq', 'fun': lambda w: np.sum(w) - 1}
    ]
    bounds = [(0, 1)] * n_controls

    w0 = np.ones(n_controls) / n_controls
    result = minimize(objective, w0, method='SLSQP',
                      bounds=bounds, constraints=constraints)

    weights = result.x

    # Synthetic control outcome for all periods
    Y_synth = Y[:, control_idx] @ weights

    # Treatment effect = treated - synthetic
    effect = Y[:, treated_idx] - Y_synth

    return weights, Y_synth, effect

# Inference: permutation (placebo) test
def placebo_test(Y, treated_idx, pre_periods, post_periods):
    """
    Run synthetic control for every unit as if it were treated.
    Compare treated unit's gap to placebo distribution.
    """
    effects = {}
    for i in range(Y.shape[1]):
        w, y_synth, eff = synthetic_control(Y, i, pre_periods, post_periods)

        # Pre-treatment RMSPE (for quality filter)
        pre_rmspe = np.sqrt(np.mean(eff[pre_periods] ** 2))
        post_rmspe = np.sqrt(np.mean(eff[post_periods] ** 2))

        effects[i] = {
            'effect': eff,
            'pre_rmspe': pre_rmspe,
            'post_rmspe': post_rmspe,
            'ratio': post_rmspe / pre_rmspe if pre_rmspe > 0 else np.inf
        }

    # p-value: fraction of placebos with ratio >= treated unit's ratio
    treated_ratio = effects[treated_idx]['ratio']
    ratios = [v['ratio'] for v in effects.values()]
    p_value = np.mean([r >= treated_ratio for r in ratios])

    return effects, p_value
```

## Augmented Synthetic Control (Ben-Michael et al. 2021)

Combines synthetic control with outcome modeling to reduce bias:

```python
# R: augsynth package
# library(augsynth)
# result <- augsynth(
#     outcome ~ treatment,
#     unit = unit_id, time = year,
#     data = df,
#     progfunc = "ridge",  # or "none" for standard SC
#     scm = TRUE
# )
# summary(result)
```

## Synthetic Control Diagnostics

- [ ] **Pre-treatment fit**: Synthetic control closely tracks treated unit pre-treatment (plot and report RMSPE)
- [ ] **Weight sparsity**: Examine weights — too many near-zero weights suggest poor donor pool
- [ ] **Placebo tests**: Permutation inference over all donor units
- [ ] **Leave-one-out**: Remove each control unit with positive weight; results should be stable
- [ ] **Time placebo**: Assign treatment to an earlier date; should find no effect
- [ ] **Predictor balance**: Match on pre-treatment covariates, not just outcome
