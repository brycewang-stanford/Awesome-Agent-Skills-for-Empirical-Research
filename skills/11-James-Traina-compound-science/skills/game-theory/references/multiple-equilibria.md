# The Multiple Equilibria Problem — Detailed Reference

The multiple equilibria problem is the central identification challenge in empirical games. When a game has more than one equilibrium, the econometrician needs an additional assumption to determine which equilibrium is played — or must relax point identification.

## Why Multiple Equilibria Arise

**Coordination games:** Multiple equilibria by design (Stag Hunt, Battle of the Sexes). Players coordinate on one of several Pareto-ranked equilibria.

**Entry games:** The game in which firms simultaneously decide whether to enter can have equilibria where firm A enters and B stays out, B enters and A stays out, or both enter — all consistent with Nash. The observed outcome depends on unmodeled coordination mechanisms.

**Symmetric games:** Any symmetric game has a symmetric Nash equilibrium (players randomize identically), but may also have asymmetric equilibria.

## Equilibrium Selection Approaches

| Selection Rule | Basis | Applicability |
|---------------|-------|--------------|
| Risk dominance (Harsanyi-Selten 1988) | Robustness to opponents' mixing | 2x2 games; computationally difficult for large games |
| Payoff dominance | Pareto ranking of equilibria | Only applies when one NE Pareto-dominates all others |
| Trembling-hand perfect (Selten 1975) | Robustness to small mistakes | Refines away weakly dominated strategies |
| Sequential rationality (Kreps-Wilson) | Consistency at off-path information sets | Extensive-form games |
| Quantal Response Equilibrium (McKelvey-Palfrey) | Bounded rationality, logistic choice | Generates unique equilibrium; testable |
| Ordered equilibrium (Berry 1992) | Exogenous ordering by profitability | Entry games with asymmetric firms |

**Quantal Response Equilibrium (QRE):** Firms respond probabilistically — more profitable strategies are played more often, but not with certainty. QRE is indexed by a precision parameter λ → ∞ (QRE converges to Nash), making it useful for equilibrium selection via model fit.

```python
def quantal_response_equilibrium(payoff_matrix, lambda_param=2.0, tol=1e-10, max_iter=5000):
    n = payoff_matrix.shape[0]
    p = np.ones(n) / n
    for _ in range(max_iter):
        eu = payoff_matrix @ p
        log_p_new = lambda_param * eu - (lambda_param * eu).max()
        p_new = np.exp(log_p_new) / np.exp(log_p_new).sum()
        if np.max(np.abs(p_new - p)) < tol:
            return p_new
        p = p_new
    raise RuntimeError("QRE iteration did not converge")
```

## Set Identification (Ciliberto-Tamer Bounds)

When no selection rule is imposed, the model is set-identified. The sharp identified set contains all parameter values θ such that the observed data is consistent with *some* equilibrium selection mechanism under θ.

**Practical approach:**
1. For each θ on a grid, compute all Nash equilibria of the game
2. Check whether the observed outcome distribution can be rationalized as a mixture of Nash equilibria
3. The identified set = {θ : observed distribution ∈ convex hull of Nash outcome distributions}

**Inference:** Use Chernozhukov, Hong, Tamer (2007) for confidence regions, or Romano-Shaikh (2010) subsampling. These are more demanding computationally than point-identified models.

## Using Multiplicity as Identifying Variation

A clever alternative: exploit the fact that different markets may play different equilibria, and use observable correlates of equilibrium selection as instruments (Sweeting 2009, Ellickson-Misra 2011). This requires a model of equilibrium selection, but allows point identification of structural parameters.
