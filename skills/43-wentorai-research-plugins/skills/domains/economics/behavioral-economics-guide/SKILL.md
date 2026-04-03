---
name: behavioral-economics-guide
description: "Behavioral economics research methods and key frameworks"
metadata:
  openclaw:
    emoji: "🧠"
    category: "domains"
    subcategory: "economics"
    keywords: ["behavioral economics", "microeconomics", "development economics"]
    source: "wentor-research-plugins"
---

# Behavioral Economics Guide

Conduct behavioral economics research using experimental methods, prospect theory, nudge frameworks, and key empirical tools for studying decision-making under bounded rationality.

## Core Theoretical Frameworks

### Prospect Theory (Kahneman & Tversky, 1979)

People evaluate outcomes relative to a reference point, with losses looming larger than equivalent gains:

```
Key features:
1. Reference dependence: Utility is defined over gains and losses, not absolute wealth
2. Loss aversion: lambda ≈ 2.25 (losses hurt ~2.25x more than equivalent gains)
3. Diminishing sensitivity: Marginal impact decreases as you move away from reference
4. Probability weighting: Overweight small probabilities, underweight large ones

Value function:
v(x) = x^alpha            if x >= 0  (alpha ≈ 0.88)
v(x) = -lambda * (-x)^beta if x < 0  (beta ≈ 0.88, lambda ≈ 2.25)

Probability weighting function (Prelec, 1998):
w(p) = exp(-(-ln(p))^alpha)   (alpha ≈ 0.65 for gains, 0.69 for losses)
```

### Dual Process Theory (Kahneman, 2011)

| System 1 (Fast) | System 2 (Slow) |
|-----------------|-----------------|
| Automatic, effortless | Deliberate, effortful |
| Intuitive, heuristic-based | Analytical, rule-based |
| Parallel processing | Serial processing |
| Emotional | Logical |
| Prone to biases | Can override biases |
| Default mode | Activated when needed |

### Nudge Theory (Thaler & Sunstein, 2008)

Nudges alter choice architecture to influence decisions without restricting options:

| Nudge Type | Example | Mechanism |
|-----------|---------|-----------|
| Default setting | Opt-out organ donation | Status quo bias |
| Salience | Calorie labels at point of sale | Attention focus |
| Social norms | "9 out of 10 neighbors recycle" | Conformity |
| Commitment device | Pre-commitment to savings plans | Present bias correction |
| Simplification | Pre-filled tax forms | Reduce cognitive load |
| Feedback | Real-time energy usage display | Information salience |
| Framing | "90% survival" vs "10% mortality" | Reference frame |

## Key Behavioral Biases and Experimental Tests

| Bias | Definition | Classic Experiment |
|------|-----------|-------------------|
| **Anchoring** | Over-reliance on first piece of information | Wheel of fortune + estimation task |
| **Endowment effect** | Overvaluing what you own | Mug trading experiment (Kahneman et al., 1990) |
| **Status quo bias** | Preference for current state | Default choice experiments |
| **Present bias** | Overweighting immediate outcomes | Discount rate elicitation |
| **Sunk cost fallacy** | Continuing due to past investment | Theater ticket scenario |
| **Overconfidence** | Overestimating own knowledge/ability | Calibration tasks |
| **Availability heuristic** | Judging probability by ease of recall | Frequency estimation tasks |
| **Representativeness** | Judging probability by similarity | Linda problem |
| **Framing effect** | Choices depend on how options are presented | Asian disease problem |

## Experimental Methods

### Lab Experiments

```python
# Example: Dictator Game implementation with oTree
# oTree is the standard platform for behavioral economics experiments

# models.py
class Player(BasePlayer):
    dictator_give = models.CurrencyField(
        min=0, max=100,
        label="How much do you want to give to the other participant?"
    )

# pages.py
class Decision(Page):
    form_model = 'player'
    form_fields = ['dictator_give']

    def vars_for_template(self):
        return {'endowment': 100}

class Results(Page):
    def vars_for_template(self):
        return {
            'kept': 100 - self.player.dictator_give,
            'given': self.player.dictator_give
        }
```

### Field Experiments and RCTs

```
Design checklist for a behavioral field experiment:

1. RESEARCH QUESTION
   "Does changing the default retirement contribution rate from 3% to 6%
   increase average savings?"

2. TREATMENT ARMS
   - Control: Default contribution = 3% (status quo)
   - Treatment 1: Default contribution = 6% (higher default)
   - Treatment 2: Default contribution = 6% + active choice prompt

3. RANDOMIZATION
   - Unit: Individual employees
   - Method: Stratified randomization by age, salary, tenure
   - Balance checks: t-tests on observables across treatment arms

4. SAMPLE SIZE
   - Power calculation: N = 1,200 per arm (power=0.80, MDE=2pp,
     alpha=0.05, ICC adjusted for clustering by department)

5. OUTCOME MEASURES
   - Primary: Contribution rate at 6 months
   - Secondary: Total savings at 12 months, opt-out rate
   - Administrative data (no survey needed)

6. PRE-REGISTRATION
   - Register on AEA RCT Registry before treatment assignment
```

### Survey Experiments

```python
# Example: Willingness-to-Pay (WTP) elicitation using BDM mechanism
# Becker-DeGroot-Marschak procedure

import numpy as np

def bdm_auction(stated_wtp, item_cost_range=(0, 20)):
    """
    Becker-DeGroot-Marschak incentive-compatible mechanism.
    Random price drawn; participant buys if WTP >= price.
    """
    random_price = np.random.uniform(*item_cost_range)
    buys = stated_wtp >= random_price
    payment = random_price if buys else 0
    return {
        "stated_wtp": stated_wtp,
        "random_price": round(random_price, 2),
        "purchased": buys,
        "payment": round(payment, 2)
    }

# This is incentive-compatible: truthfully reporting WTP is optimal
# because the price is determined independently of the stated WTP
```

## Time Preferences and Discounting

```python
# Estimating discount factors from multiple price list (MPL) choices

def estimate_discount_factor(choices, amounts, delays):
    """
    Estimate quasi-hyperbolic discounting parameters (beta, delta)
    from a series of smaller-sooner vs. larger-later choices.

    beta: present bias (< 1 means present-biased)
    delta: long-run discount factor (per period)
    """
    from scipy.optimize import minimize

    def neg_log_likelihood(params):
        beta, delta = params
        ll = 0
        for choice, (ss, ll_amt), (t_ss, t_ll) in zip(choices, amounts, delays):
            # Discounted utility of each option
            if t_ss == 0:
                u_ss = ss  # No discounting for immediate
                u_ll = beta * (delta ** t_ll) * ll_amt
            else:
                u_ss = beta * (delta ** t_ss) * ss
                u_ll = beta * (delta ** t_ll) * ll_amt

            p_ll = 1 / (1 + np.exp(-(u_ll - u_ss)))  # Logit
            ll += choice * np.log(p_ll + 1e-10) + (1-choice) * np.log(1-p_ll + 1e-10)
        return -ll

    result = minimize(neg_log_likelihood, [0.9, 0.95],
                      bounds=[(0.01, 1.5), (0.8, 1.0)])
    return {"beta": result.x[0], "delta": result.x[1]}
```

## Data Analysis in Behavioral Economics

### Common Estimation Methods

| Method | Use Case | Software |
|--------|----------|----------|
| OLS / Logit | Treatment effects, survey experiments | Stata, R, Python |
| IV / 2SLS | Endogeneity in field settings | Stata (`ivregress`), R (`ivreg`) |
| Difference-in-differences | Policy evaluation | Stata, R (`did` package) |
| Structural estimation | Utility function parameters | Stata, MATLAB, Python |
| Random utility models | Discrete choice experiments | R (`mlogit`), Python (`pylogit`) |
| Clustering corrections | Within-group correlation | Stata `vce(cluster)`, R `sandwich` |

## Key Resources

| Resource | Type | Description |
|----------|------|-------------|
| oTree | Software | Open-source platform for behavioral experiments |
| Gorilla | Platform | Online experiment builder (psychology/economics) |
| LIONESS Lab | Platform | Real-time interactive online experiments |
| AEA RCT Registry | Registry | Pre-registration for economics experiments |
| J-PAL | Organization | Poverty Action Lab, methodological resources |
| NBER Behavioral Finance | Working papers | Latest research in behavioral finance |

## Top Journals and Venues

| Journal | Focus |
|---------|-------|
| American Economic Review | Top 5, publishes major behavioral papers |
| Quarterly Journal of Economics | Top 5, strong behavioral presence |
| Journal of Political Economy | Top 5 |
| Econometrica | Top 5, theory + experiments |
| Journal of the European Economic Association | Top field journal |
| Management Science | Behavioral operations, decision-making |
| Experimental Economics | Dedicated experiments journal |
| Journal of Behavioral and Experimental Economics | Broader behavioral |
| Journal of Economic Behavior & Organization | Interdisciplinary behavioral |
