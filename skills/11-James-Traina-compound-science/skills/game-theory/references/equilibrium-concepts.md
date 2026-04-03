# Equilibrium Concepts — Detailed Reference

## Static Games of Complete Information

**Normal form:** A game is defined by (N, {S_i}, {u_i}) — N players, strategy sets S_i, payoff functions u_i(s_1, ..., s_N).

**Nash equilibrium:** A strategy profile s* such that no player can profitably deviate:
```
u_i(s_i*, s_{-i}*) >= u_i(s_i, s_{-i}*)   for all i, all s_i ∈ S_i
```

**Dominant strategies:** s_i* dominates s_i' if u_i(s_i*, s_{-i}) > u_i(s_i', s_{-i}) for all s_{-i}. Dominant strategy equilibria are robust — they do not require beliefs about opponents.

**Mixed strategies:** When no pure-strategy Nash equilibrium exists (or multiple exist), players randomize. A mixed Nash equilibrium requires each player to be indifferent over all strategies in their support. Computing mixed equilibria is more demanding computationally and creates the equilibrium selection problem for estimation.

**Relevance for IO:** Most empirical entry and conduct models are static complete-information games. The workhorse examples are Bresnahan-Reiss (1991) and Berry (1992).

## Dynamic Games: Extensive Form and SPE

**Extensive form:** Represents the sequential structure of a game — who moves when, what they observe, what actions are available.

**Subgame perfect equilibrium (SPE):** Computed by backward induction. A Nash equilibrium that is also an equilibrium in every proper subgame. Eliminates non-credible threats.

```
Terminal nodes → payoffs
         ↑
Last-mover's optimal actions (given payoffs)
         ↑
Second-to-last mover's optimal actions (given last mover's best responses)
         ...
         ↑
First mover's optimal action
```

**Markov perfect equilibrium (MPE):** The standard refinement for dynamic oligopoly games (Ericson-Pakes 1995, Pakes-McGuire 1994). Strategies depend only on the current payoff-relevant state, not full histories. This tractability is essential for empirical work — MPE reduces the strategy space to Markov strategies indexed by a state variable.

**Key difference from single-agent dynamics:** In MPE, each firm's continuation value depends on *competitors' strategies*, so the inner loop must solve a system of coupled Bellman equations simultaneously, not one agent's problem in isolation.

## Incomplete Information: Bayesian Nash Equilibrium

**Bayesian game:** Players have private types θ_i drawn from distributions F_i (the type space). A type summarizes private information — cost, quality, value, capability.

**Bayesian Nash equilibrium (BNE):** A profile of strategies s_i*(θ_i) such that each player maximizes expected utility given their type and beliefs about opponents' types and strategies:
```
s_i*(θ_i) ∈ argmax E_{θ_{-i}} [u_i(s_i, s_{-i}*(θ_{-i}), θ_i, θ_{-i})]
```

**Why it matters empirically:** Auctions are the canonical Bayesian game — bidders have private values (IPV framework) or affiliated signals (mineral rights model). Entry models can be cast as either complete or incomplete information, with very different empirical implications (Bajari, Hong, Ryan 2010).

**Complete vs. incomplete information in entry:**

| Feature | Complete Information | Incomplete Information |
|---------|---------------------|----------------------|
| Equilibrium concept | Nash (pure or mixed) | Bayesian Nash (in thresholds) |
| Multiple equilibria | Severe | Often unique in monotone strategies |
| Identification | Harder (selection rule needed) | Easier (equilibrium pins down behavior) |
| Standard reference | Berry (1992), Bresnahan-Reiss (1991) | Seim (2006), Bajari-Hong-Ryan (2010) |

## Repeated Games: Folk Theorem and Collusion

In infinitely repeated games, cooperation can be sustained as a subgame perfect equilibrium even when one-shot incentives favor defection — the folk theorem.

**Grim trigger strategy:** Cooperate in every period; switch to Nash reversion forever after any defection. Cooperation is sustainable when:
```
π_collude / (1 - δ) >= π_deviate + δ * π_Nash / (1 - δ)
```
Solving: `δ >= (π_deviate - π_collude) / (π_deviate - π_Nash)`

**Empirical relevance:** The Rotemberg-Saloner (1986) model and Green-Porter (1984) provide structural foundations for testing collusion. Empirical work (Porter 1983, Ellison 1994) estimates threshold discount factors and tests whether observed conduct is consistent with Nash reversion strategies.

**Key implication for conduct testing:** Repeated game models predict that collusion is harder to sustain when: (1) discount factor is lower, (2) deviation gains are higher, (3) detection lag is longer. These comparative statics generate testable restrictions.
