---
name: post-labor-economics
description: "Post-labor economies with automation, UBI, and wealth distribution"
metadata:
  openclaw:
    emoji: "🤖"
    category: "domains"
    subcategory: "economics"
    keywords: ["automation", "UBI", "post-labor", "technological unemployment", "income distribution", "AI economics"]
    source: "wentor-research-plugins"
---

# Post-Labor Economics Guide

## Overview

Post-labor economics studies the economic consequences of advanced automation -- the possibility that AI and robotics will displace human labor at a scale and speed that overwhelms traditional adjustment mechanisms. While technological unemployment is an old concern (dating to the Luddites and Keynes's "Economic Possibilities for Our Grandchildren"), the current wave of AI capabilities has made the question urgent: what happens to labor markets, income distribution, and economic growth when machines can perform most cognitive and physical tasks?

This is not science fiction. The academic literature on task displacement, skill-biased technological change, and automation risk has produced substantial empirical findings and theoretical frameworks. Researchers from economics, political science, sociology, and computer science are converging on these questions.

This guide covers the key theoretical models, empirical evidence, policy proposals (UBI, robot taxes, stakeholder funds), and methodological approaches for studying the economics of automation. It is designed for researchers entering this rapidly growing field and for those in adjacent disciplines who need to engage with the economic arguments.

## Theoretical Frameworks

### The Task-Based Model of Automation

The canonical model (Acemoglu & Restrepo, 2018, 2019) decomposes production into tasks rather than jobs:

```
Production = f(Tasks performed by Labor, Tasks performed by Capital)

Key dynamics:
1. DISPLACEMENT EFFECT
   - Machines replace humans in existing tasks
   - Reduces labor demand, depresses wages
   - Concentrated in routine cognitive and manual tasks

2. PRODUCTIVITY EFFECT
   - Automation lowers costs, increases output
   - Some gains flow to workers via cheaper goods
   - But distribution depends on market structure

3. REINSTATEMENT EFFECT
   - New tasks created that require human comparative advantage
   - Historically: ATMs → bank branch expansion → more tellers (temporarily)
   - Question: Is this time different? Will new tasks emerge fast enough?

4. NET EFFECT
   - Historical pattern: displacement < reinstatement (net job growth)
   - Current concern: AI attacks both routine AND non-routine tasks
   - Speed of displacement may exceed speed of reinstatement
```

### Skill-Biased vs. Routine-Biased Technological Change

| Model | Mechanism | Winners | Losers |
|-------|-----------|---------|--------|
| SBTC (Skill-Biased) | Technology complements high-skill labor | College-educated | Non-college workers |
| RBTC (Routine-Biased) | Automation replaces routine tasks | Creative + manual | Middle-skill routine |
| ABTC (AI-Biased) | AI replaces cognitive tasks broadly | Capital owners, AI specialists | Broad cognitive workers |

```
Job polarization (Autor, 2015):

         High-skill (growing)
           /               \
          /     Hollowing    \
         /       out of       \
        /      middle-skill    \
       /                        \
Low-skill (growing)     Middle-skill (shrinking)

Examples by category:
- High-skill (growing): AI researchers, surgeons, lawyers (judgment tasks)
- Middle-skill (shrinking): Bookkeeping, data entry, assembly, driving
- Low-skill (growing): Care work, cleaning, food service (non-routine manual)
```

## Empirical Evidence

### Automation Risk Estimates

| Study | Method | Finding |
|-------|--------|---------|
| Frey & Osborne (2013) | Expert assessment of 702 occupations | 47% of US jobs at high risk |
| Arntz et al. (2016) | Task-level analysis (PIAAC) | 9% of OECD jobs automatable |
| Nedelkoska & Quintini (2018) | Task-level, 32 countries | 14% high risk, 32% significant change |
| Acemoglu & Restrepo (2020) | Actual robot adoption (US) | 1 robot per 1000 workers = -0.2% employment, -0.37% wages |
| Webb (2020) | Patent-occupation matching | AI threatens high-skill tasks more than previous technologies |
| Eloundou et al. (2023) | GPT exposure analysis | ~80% of US workers have 10%+ tasks exposed to LLMs |

### Measuring Automation Exposure

```python
import pandas as pd
import numpy as np

def compute_automation_exposure(
    occupation_tasks: pd.DataFrame,
    ai_capability_scores: dict,
) -> pd.DataFrame:
    """
    Compute occupation-level AI exposure scores.

    Based on the methodology of Felten et al. (2021) and Eloundou et al. (2023).

    Parameters:
        occupation_tasks: DataFrame with columns [occupation, task, task_weight]
        ai_capability_scores: dict mapping task -> AI performance score (0-1)

    Returns:
        DataFrame with occupation-level exposure scores
    """
    # Map AI scores to tasks
    occupation_tasks["ai_score"] = occupation_tasks["task"].map(ai_capability_scores)

    # Weighted average exposure per occupation
    exposure = occupation_tasks.groupby("occupation").apply(
        lambda g: np.average(g["ai_score"].fillna(0), weights=g["task_weight"])
    ).reset_index(name="ai_exposure")

    # Classify risk levels
    exposure["risk_level"] = pd.cut(
        exposure["ai_exposure"],
        bins=[0, 0.3, 0.6, 1.0],
        labels=["low", "medium", "high"],
    )

    return exposure.sort_values("ai_exposure", ascending=False)
```

## Policy Proposals

### Universal Basic Income (UBI)

```
UBI design parameters:

AMOUNT:
- Subsistence: $12,000-15,000/year (US, ~poverty line)
- Moderate: $18,000-24,000/year (covers basic needs + participation)
- Generous: $30,000+/year (enables full non-employment)

FUNDING MECHANISMS:
1. Carbon tax + dividend (Alaska Permanent Fund model)
2. Value-added tax on automation (Andrew Yang proposal)
3. Sovereign wealth fund (Norway model, applied to AI rents)
4. Robot tax (Bill Gates proposal)
5. Land value tax (Georgist approach)
6. Consolidated existing transfers (replacing welfare bureaucracy)

EVIDENCE FROM PILOTS:
| Pilot | Location | Duration | Key Finding |
|-------|----------|----------|-------------|
| Finland (2017-2018) | National | 2 years | No employment effect, improved well-being |
| Stockton SEED (2019-2021) | City | 2 years | Employment increased, stress decreased |
| GiveDirectly (2016-) | Kenya | 12 years | Consumption up, no labor supply reduction |
| Mincome (1974-1979) | Manitoba | 5 years | Only new mothers and students worked less |
| Y Combinator (2024-) | US cities | 3 years | Results pending |
```

### Alternative Distribution Mechanisms

| Proposal | Mechanism | Advocate |
|----------|-----------|----------|
| Robot tax | Tax capital that replaces labor | Gates, Korinek |
| Data dividend | Citizens own their data, paid for use | Lanier, Posner & Weyl |
| Stakeholder fund | National AI fund, citizen dividends | Bruenig, Stern |
| Job guarantee | Government as employer of last resort | Tcherneva, MMT school |
| Reduced work week | Distribute remaining work more evenly | Keynes, Skidelsky |
| Education subsidy | Continuous retraining for displaced workers | Autor, Goldin |
| Participation income | Conditional on social contribution | Atkinson |

## Modeling Automation Impact

```python
def simulate_automation_transition(
    initial_employment: float,
    automation_rate: float,       # Annual % of tasks automated
    reinstatement_rate: float,    # Annual % of new tasks created
    years: int = 30,
    productivity_growth: float = 0.02,
) -> pd.DataFrame:
    """
    Simple simulation of automation transition dynamics.

    Based on Acemoglu & Restrepo (2019) task-based framework.
    """
    results = []
    employment = initial_employment
    wage_index = 1.0
    task_share_labor = 0.6  # Initial share of tasks done by humans

    for year in range(years):
        # Displacement
        tasks_displaced = task_share_labor * automation_rate
        task_share_labor -= tasks_displaced

        # Reinstatement
        new_tasks = reinstatement_rate
        task_share_labor += new_tasks

        # Cap at reasonable bounds
        task_share_labor = max(0.05, min(0.95, task_share_labor))

        # Employment and wages adjust
        employment_change = (task_share_labor - 0.6) * 0.5
        employment = initial_employment * (1 + employment_change)
        wage_index *= (1 + productivity_growth - automation_rate * 0.3 + reinstatement_rate * 0.2)

        results.append({
            "year": year,
            "task_share_labor": task_share_labor,
            "employment": employment,
            "wage_index": wage_index,
        })

    return pd.DataFrame(results)

# Scenario comparison
optimistic = simulate_automation_transition(100, 0.02, 0.025)  # Reinstatement > displacement
pessimistic = simulate_automation_transition(100, 0.04, 0.015)  # Displacement > reinstatement
```

## Research Methods

### Data Sources for Automation Research

| Source | Coverage | Key Variables |
|--------|----------|---------------|
| O*NET | US occupations | Task descriptions, skills, abilities |
| PIAAC | 40+ countries | Worker skills, task content |
| IFR Robot Data | Global | Industrial robot installations by country/industry |
| ATUS | US | Time use (task content of work) |
| CPS/ACS | US | Employment, wages, occupation codes |
| EU-LFS | Europe | Labor force surveys |
| AI Patents | Global | Technology capability indicators |

## Best Practices

- **Distinguish task automation from job automation.** Most jobs contain a mix of automatable and non-automatable tasks.
- **Model adjustment mechanisms.** Price effects, new task creation, and demand shifts matter as much as direct displacement.
- **Use occupation-task crosswalks** (O*NET, ISCO) rather than crude occupation-level automation scores.
- **Report distributional effects.** Aggregate statistics hide the uneven impact across skill, age, gender, and geography.
- **Engage with political economy.** Automation is not just an economic phenomenon -- it is shaped by policy, institutions, and power.
- **Avoid technological determinism.** The pace and direction of automation are choices, not inevitabilities.

## References

- Acemoglu, D. & Restrepo, P. (2019). Automation and New Tasks. AER Papers & Proceedings, 109, 118-123.
- Autor, D. (2015). Why Are There Still So Many Jobs? JEP, 29(3), 3-30.
- Frey, C. B. & Osborne, M. A. (2017). The Future of Employment. Technological Forecasting and Social Change, 114, 254-280.
- Korinek, A. & Stiglitz, J. E. (2021). Artificial Intelligence, Globalization, and Strategies for Economic Development. NBER WP 28453.
- [OECD Future of Work](https://www.oecd.org/future-of-work/) -- Cross-country analysis and policy recommendations
