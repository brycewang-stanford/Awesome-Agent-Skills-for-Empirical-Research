---
name: game-theory
argument-hint: "<equilibrium concept or game type>"
description: >-
  This skill covers game-theoretic methods in structural econometrics and industrial organization. Use when the user is working with strategic interactions, equilibrium analysis, or game-theoretic structural models — including entry games, conduct testing, auction models with strategic bidding, bargaining, or matching markets. Triggers on "Nash equilibrium", "subgame perfect", "best response", "strategic interaction", "entry game", "conduct testing", "auction", "mechanism design", "matching market", "bargaining", "BNE", "Bayesian Nash", "static game", "dynamic game", "repeated game", "multiple equilibria", "equilibrium selection", "discrete game", "oligopoly", "game-theoretic", "player", "payoff", "strategy", "dominant strategy", "Bresnahan-Reiss", "Ciliberto-Tamer", "partial identification", "set identification", or markup test.
---

# Game Theory

Reference for game-theoretic methods in applied structural econometrics and industrial organization. Covers equilibrium concepts, computational methods, structural IO applications, and the identification challenges unique to game-theoretic models.

## When to Use This Skill

Use when the user is:
- Estimating a structural model where agents interact strategically (oligopoly, entry, bargaining, auctions)
- Deriving or computing Nash equilibria, BNE, or subgame perfect equilibria
- Handling the multiple equilibria problem in empirical games
- Testing firm conduct (competitive vs. collusive vs. oligopolistic)
- Estimating entry models, matching models, or bargaining models
- Formalizing an identification argument for a game-theoretic model

Skip when:
- The model is single-agent (use `structural-modeling` skill for dynamic discrete choice, demand estimation)
- The task is standard causal inference without strategic interaction (use `causal-inference` skill)
- The game is a well-known IO model with standard estimation code (pyblp covers BLP demand; see `structural-modeling`)

**Quick reference only** — for full implementation code, see `references/` subdirectory.

## Where to Start

- **Choosing equilibrium concept?** See [Equilibrium Concept Routing](#equilibrium-concept-routing) below, then `references/equilibrium-concepts.md` for definitions and formulas
- **Computing equilibria?** See `references/equilibrium-computation.md`
- **Estimating an IO model?** See `references/io-applications.md`
- **Estimation code and diagnostics?** See `references/estimation-diagnostics.md`
- **Facing multiple equilibria?** See [Multiple Equilibria Summary](#multiple-equilibria-summary) below, then `references/multiple-equilibria.md` for selection rules and set identification
- **Identification argument?** See [Identification Summary](#identification-summary) below, then `references/identification-in-games.md` for exclusion restrictions and rank conditions

---

## Quick Start: Nash Equilibrium Computation

```python
import nashpy as nash
import numpy as np

# Define a 2-player game: row player payoffs A, column player payoffs B
A = np.array([[3, 0], [5, 1]])  # e.g., Prisoner's Dilemma
B = A.T                          # Symmetric game
game = nash.Game(A, B)

# Find ALL Nash equilibria via support enumeration
for i, (sr, sc) in enumerate(game.support_enumeration()):
    print(f"NE {i+1}: row={sr.round(3)}, col={sc.round(3)}")
```

For larger games, extensive-form games, or QRE computation, see `references/equilibrium-computation.md`.

## Equilibrium Concept Routing

| Information Structure | Timing | Concept | Refinement | Key Reference |
|----------------------|--------|---------|------------|--------------|
| Complete | Simultaneous | Nash equilibrium | Dominant strategy, trembling-hand perfect | — |
| Complete | Sequential | Subgame perfect equilibrium (SPE) | Backward induction | — |
| Complete | Repeated | SPE with trigger strategies | Folk theorem, Nash reversion | Green-Porter (1984) |
| Complete | Dynamic (states) | Markov perfect equilibrium (MPE) | Strategies depend only on payoff-relevant state | Ericson-Pakes (1995) |
| Incomplete (private types) | Simultaneous | Bayesian Nash equilibrium (BNE) | Monotone strategies, threshold equilibria | — |
| Incomplete | Sequential | Perfect Bayesian equilibrium (PBE) | Sequential rationality + Bayesian updating | Kreps-Wilson |

**Decision tree:**
1. Do players have private information? → Yes: BNE framework. No: Nash/SPE.
2. Is the game sequential? → Yes: SPE (backward induction) or MPE (dynamic states). No: simultaneous Nash.
3. Is the game repeated? → Yes: folk theorem applies; collusion may be sustainable.
4. Are there multiple equilibria? → See [Multiple Equilibria Summary](#multiple-equilibria-summary).

For detailed definitions, formulas, and the complete-vs-incomplete information comparison table, see `references/equilibrium-concepts.md`.

---

## Multiple Equilibria Summary

The central identification challenge in empirical games. Three resolution strategies:

| Strategy | Approach | Trade-off | Key Reference |
|----------|----------|-----------|--------------|
| **Impose selection rule** | Order firms by profitability; pick unique NE | Point identification, but selection rule is an assumption | Berry (1992) |
| **Set identification** | Accept all NE-consistent parameters | No selection assumption, but wider confidence regions | Ciliberto-Tamer (2009) |
| **Exploit multiplicity** | Use correlates of equilibrium selection as instruments | Point identification with weaker assumptions | Sweeting (2009) |
| **QRE** | Bounded rationality generates unique equilibrium | Testable, but imposes logistic choice structure | McKelvey-Palfrey |

For the full selection rule comparison table, QRE implementation code, and Ciliberto-Tamer bounds procedure, see `references/multiple-equilibria.md`.

---

## Identification Summary

Two sources of endogeneity distinguish games from single-agent models: (1) strategic complementarities/substitutes create simultaneity, and (2) correlated unobservables create spurious correlation in actions.

**Resolution:** Firm-specific instruments Z_i (cost, distance, regulatory history) excluded from rival j's profit equation. Variation in Z_i shifts firm i's entry, which instruments for j's strategic response.

**Rank condition (Bajari-Hong-Ryan 2010):** The Jacobian of the best-response system w.r.t. exogenous variables must have full rank. Fails when all firms share the same instruments, competitive effects are zero, or instruments are weak.

**Conduct parameter identification:** Cost shifters must shift supply independently of demand (standard simultaneous equations condition). The conduct parameter θ is identified from the curvature of the markup-quantity relationship.

For the full treatment — exclusion restriction formulas, two-step estimation logic, competitive effect identification, and conduct rank condition failure modes — see `references/identification-in-games.md`.

---

## Structural IO Applications: Routing

For full model specifications, estimation code, and references, see `references/io-applications.md` and `references/estimation-diagnostics.md`.

| Application | Model Class | Estimation | Reference File |
|-------------|------------|------------|---------------|
| Market structure (symmetric firms) | Bresnahan-Reiss ordered probit | MLE | `io-applications.md` |
| Entry (asymmetric firms) | Berry ordered equilibrium | MLE with equilibrium constraints | `io-applications.md` |
| Entry (multiple equilibria) | Ciliberto-Tamer partial identification | Moment inequalities | `io-applications.md` |
| Conduct testing | BLP supply side + markup equation | GMM + Rivers-Vuong test | `io-applications.md` |
| Vertical bargaining | Generalized Nash bargaining (Horn-Wolinsky) | GMM with outside option instruments | `io-applications.md` |
| Procurement/first-price auctions | BNE bidding + GPV inversion | Nonparametric | `io-applications.md` |
| Dynamic oligopoly | MPE (Ericson-Pakes) | CCP two-step (Bajari-Benkard-Levin) | `estimation-diagnostics.md` |
| Collusion sustainability | Repeated game + trigger strategies | Threshold discount factor | `equilibrium-concepts.md` |

---

## Integration with compound-science

- Use `identification-critic` agent to verify equilibrium existence, uniqueness, and stability properties before reporting results
- Use `structural-modeling` skill for the estimation machinery (GMM, MLE, NFXP, MPEC) when the game-theoretic structure is already set up
- Use `identification-critic` agent to stress-test the game-theoretic identification argument — exclusion restrictions, rank conditions, separability assumptions
- Use the `identification-critic` agent (or `identification-proofs` skill) to formalize the full identification argument: target parameter → model → equilibrium concept → moment conditions → rank condition
- Use `numerical-auditor` agent to design Monte Carlo studies verifying identification and estimator performance in your specific game

---

## Common Anti-Patterns

| Anti-Pattern | Problem | Better Approach |
|--------------|---------|-----------------|
| Assuming unique equilibrium without verification | Model may have multiple equilibria; point estimates are identification-assumption-dependent | Enumerate all Nash equilibria at estimated parameters; verify uniqueness or state selection rule |
| Using complete-information entry model when firms have private information | Equilibrium concept is wrong; identification fails | Use incomplete-information model (Seim 2006, Bajari-Hong-Ryan 2010) or test for information structure |
| Ignoring the multiple equilibria problem in partial identification | Inference is invalid under point identification when set identification is required | Use Ciliberto-Tamer bounds or impose and justify a selection rule |
| Conduct test with weak instruments | Low power to reject Bertrand; cannot distinguish conduct | Report first-stage relevance; use optimal instruments (BLP supply side) |
| Treating equilibrium prices as exogenous regressors in demand | Prices are endogenous (set in equilibrium); OLS demand estimates are biased | Instrument with cost shifters; use BLP/IV approach |
| Estimating bargaining weight without outside option variation | β is not identified without variation in outside options | Find instruments for outside options (market-level variation in alternatives) |
| Nash reversion assumption in collusion test without threshold test | Assumes away the inference problem | Estimate threshold discount factor; test whether δ* is plausible given observed interest rates |
| Not reporting equilibrium verification | Referees cannot assess model validity | Always report that estimated parameters support equilibrium existence |

---

## Method Selection Guide

| Setting | Model | Equilibrium Concept | Estimation Approach | Key Reference |
|---------|-------|---------------------|--------------------|--------------:|
| Oligopoly market structure | Complete information entry | Nash (ordered selection) | Ordered probit MLE | Bresnahan-Reiss (1991) |
| Asymmetric firm entry | Complete information entry | Nash (ordered selection) | MLE with equilibrium constraints | Berry (1992) |
| Entry with multiple equilibria | Partial identification | Nash (all equilibria) | Moment inequalities | Ciliberto-Tamer (2009) |
| Entry with private cost info | Bayesian game | Bayesian Nash (threshold) | MLE / two-step | Seim (2006) |
| Conduct: competitive vs. collusive | Oligopoly pricing | Nash in prices/quantities | BLP supply + Rivers-Vuong test | Berry-Levinsohn-Pakes (1995) |
| Vertical bargaining | Nash bargaining | Generalized Nash solution | GMM with outside option instruments | Horn-Wolinsky (1988), Crawford-Yurukoglu (2012) |
| Procurement auctions | First-price sealed-bid | Bayesian Nash (bidding) | GPV nonparametric inversion | Guerre-Perrigne-Vuong (2000) |
| Takeover/merger auctions | Ascending auction | Dominant strategy (IPV) | Order statistics / MLE | Athey-Haile (2002) |
| Common value auctions | Affiliated values | BNE (affiliated) | Parametric MLE | Li-Perrigne-Vuong (2002) |
| Dynamic oligopoly | Markov perfect equilibrium | MPE | CCP two-step (Bajari-Benkard-Levin) | Pakes-McGuire (1994), Bajari et al. (2007) |
| Collusion sustainability | Repeated game | Subgame perfect | Threshold discount factor estimation | Green-Porter (1984), Porter (1983) |
| Matching markets | Stable matching | Stable (Gale-Shapley) | Revealed preference from match outcomes | Fox (2010), Choo-Siow (2006) |
| Small 2-player game (theory) | Normal form | Nash (all equilibria) | nashpy / gambit computation | — |

**Decision heuristic:**
1. Is the game static or dynamic?
   - Dynamic → Markov perfect equilibrium; use CCP two-step (Bajari-Benkard-Levin 2007)
   - Static → proceed below
2. Is information complete or incomplete?
   - Incomplete (private types) → BNE; use threshold strategy estimation or GPV for auctions
   - Complete → Nash equilibrium; proceed below
3. Are there multiple equilibria at plausible parameter values?
   - Yes, and willing to impose selection → ordered probit / Berry (1992)
   - Yes, and not willing to impose selection → moment inequalities / Ciliberto-Tamer (2009)
   - No → standard MLE or GMM
4. Is the question about conduct?
   - Use BLP supply side + Rivers-Vuong test, or Rotemberg-Saloner markup test
5. Is bargaining the mechanism?
   - Use generalized Nash bargaining with outside option instruments

---

## Reference Files

Read these when implementing a specific model type:
- `references/equilibrium-concepts.md` — Detailed definitions and formulas for Nash, BNE, SPE, MPE, mixed strategies, repeated games, folk theorem, complete-vs-incomplete information comparison
- `references/equilibrium-computation.md` — Computing Nash, BNE, and SPE: best response iteration, support enumeration, Gambit solver integration, linear complementarity, dynamic programming
- `references/multiple-equilibria.md` — Selection rules (risk dominance, QRE, ordered equilibrium), QRE implementation code, Ciliberto-Tamer set identification procedure, multiplicity-as-variation
- `references/identification-in-games.md` — Exclusion restrictions, rank conditions (Bajari-Hong-Ryan), two-step estimation logic, competitive effect identification, conduct parameter identification and failure modes
- `references/io-applications.md` — Entry models (Bresnahan-Reiss, Berry, Ciliberto-Tamer), conduct testing (BLP supply, Rivers-Vuong), bargaining (Nash, Rubinstein), auction foundations
- `references/estimation-diagnostics.md` — Estimation code (MLE, two-step, MPEC, moment inequalities), convergence diagnostics, model fit tests, equilibrium verification
