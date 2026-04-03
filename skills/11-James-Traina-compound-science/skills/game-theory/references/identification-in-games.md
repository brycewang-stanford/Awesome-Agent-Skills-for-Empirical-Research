# Identification in Games — Detailed Reference

## The Core Challenge

In single-agent models, identification of preferences is straightforward: variation in the agent's choice environment traces out the preference parameters. In games, observed behavior reflects the *interaction* of preferences and equilibrium play. Separating these is the identification problem in games.

**Two sources of endogeneity:**
1. **Strategic complementarities/substitutes:** Firm i's action affects firm j's optimal action, creating a simultaneity problem
2. **Correlated unobservables:** Common market-level shocks (ξ) affect all firms' profits, creating spurious correlation in actions

## Exclusion Restrictions in Games

The standard approach: firm-specific instruments that affect firm i's profitability but not firm j's:

```
π_i(enter) = f(X_m, Z_i, ε_i) - competitive_effects(N_{-i})
π_j(enter) = f(X_m, Z_j, ε_j) - competitive_effects(N_{-i})
```

Here Z_i (firm i's cost, distance to market, regulatory history) are excluded from j's profit equation. Variation in Z_i shifts firm i's entry decision, which then acts as an instrument for firm j's strategic response.

**Formal rank condition (Bajari-Hong-Ryan 2010):** The Jacobian of the equilibrium best-response system with respect to exogenous variables must have full rank at the true parameter value. Failures occur when:
- All firms face the same instruments (no within-market variation)
- Competitive effects are zero (no strategic interaction — reduces to single-agent problem)
- Instruments are weak (modest first-stage relevance)

## Separating Preferences from Equilibrium Behavior

**Two-step approaches:**
1. **Reduced form first:** Estimate best-response functions or conditional choice probabilities from data (nonparametrically if possible)
2. **Structural second:** Map the estimated reduced-form objects back to structural parameters

This logic underlies Hotz-Miller CCP estimation in dynamic games and the Bajari-Hong-Ryan approach for static games.

**Identification of competitive effects:** Competitive effects (how rivals' entry affects own profit) are identified from cross-firm variation in profitability:

```
Cov(entry_j, entry_i | X_m, Z_i, Z_j) ≠ 0

identified from: variation in Z_j conditional on Z_i and X_m
```

If Z_j is a valid firm j-specific instrument, its effect on entry_j, controlling for entry_i, identifies the competitive effect on firm i.

## Rank Conditions for Conduct Parameters

In conduct testing, the conduct parameter θ is identified if demand and cost curves shift independently — the standard simultaneous equations rank condition. Specifically:

**Berry-Levinsohn-Pakes identification of conduct:** Cost shifters (input prices, factor costs) shift the supply equation without shifting demand, tracing out the demand curve and pinning down markups. The conduct parameter is identified from the curvature of the markup-quantity relationship.

**Potential failure modes:**
- Cost shifters correlated with demand shocks (instruments are endogenous)
- Cost shifters only shift the level of costs, not the shape of the markup-quantity relationship (rank failure)
- Products are homogeneous (quantity competition and price competition are identical: Kreps-Scheinkman 1983)
