---
name: social-research-methods
description: "Core methods for empirical social science research including surveys and expe..."
metadata:
  openclaw:
    emoji: "👥"
    category: "domains"
    subcategory: "social-science"
    keywords: ["sociology", "political science", "cognitive psychology", "social psychology", "research methodology"]
    source: "wentor"
---

# Social Research Methods

A comprehensive skill for designing and conducting empirical social science research. Covers survey methodology, experimental design, qualitative methods, and mixed-methods approaches used across sociology, political science, and psychology.

## Research Design Fundamentals

### Selecting a Research Strategy

```
Research Question Type -> Recommended Design

"What is the prevalence of X?"     -> Cross-sectional survey
"Does X cause Y?"                   -> Randomized experiment or quasi-experiment
"How does X develop over time?"     -> Longitudinal panel study
"What does X mean to participants?" -> Qualitative (interviews, ethnography)
"How much of Y is explained by X?" -> Correlational / regression study
"Does the effect hold across contexts?" -> Comparative / cross-national study
```

### Operationalization Framework

```python
def operationalize_construct(construct: str, dimensions: list[dict]) -> dict:
    """
    Create an operationalization plan for a theoretical construct.

    Args:
        construct: Name of the abstract concept
        dimensions: List of dicts with 'name', 'indicators', 'measurement_level'
    """
    plan = {
        'construct': construct,
        'dimensions': [],
        'total_items': 0
    }
    for dim in dimensions:
        items = []
        for indicator in dim['indicators']:
            items.append({
                'indicator': indicator,
                'measurement': dim['measurement_level'],
                'source': dim.get('data_source', 'self-report survey')
            })
        plan['dimensions'].append({
            'name': dim['name'],
            'items': items,
            'n_items': len(items)
        })
        plan['total_items'] += len(items)
    return plan

# Example: operationalize "social capital"
social_capital = operationalize_construct(
    construct="Social Capital",
    dimensions=[
        {
            'name': 'bonding_capital',
            'indicators': ['close_friends_count', 'family_support_scale', 'trust_in_neighbors'],
            'measurement_level': 'ordinal (Likert 1-5)'
        },
        {
            'name': 'bridging_capital',
            'indicators': ['diverse_network_size', 'weak_ties_count', 'civic_participation'],
            'measurement_level': 'ratio'
        }
    ]
)
```

## Survey Design

### Questionnaire Construction Best Practices

1. **Question wording**: Avoid double-barreled questions, leading questions, and loaded terms
2. **Response scales**: Use balanced Likert scales (typically 5 or 7 points)
3. **Question order**: Move from general to specific; place sensitive items later
4. **Pretesting**: Conduct cognitive interviews with 5-10 respondents before field deployment

### Sampling Methods

| Method | Description | When to Use |
|--------|------------|------------|
| Simple random | Every unit has equal probability | Small, accessible populations |
| Stratified | Divide into strata, sample within each | Need representation of subgroups |
| Cluster | Sample groups, then individuals within | Geographically dispersed populations |
| Quota | Non-probability; fill demographic quotas | Exploratory research, tight budgets |
| Snowball | Participants recruit others | Hard-to-reach populations |

### Sample Size Calculation

```python
import math

def sample_size_proportion(p: float = 0.5, margin_error: float = 0.05,
                            confidence: float = 0.95, population: int = None) -> int:
    """
    Calculate required sample size for estimating a proportion.

    Args:
        p: Expected proportion (use 0.5 for maximum variance)
        margin_error: Desired margin of error
        confidence: Confidence level
        population: Finite population size (optional)
    """
    z_scores = {0.90: 1.645, 0.95: 1.96, 0.99: 2.576}
    z = z_scores.get(confidence, 1.96)

    n = (z**2 * p * (1 - p)) / margin_error**2

    # Finite population correction
    if population:
        n = n / (1 + (n - 1) / population)

    return math.ceil(n)

print(sample_size_proportion(p=0.5, margin_error=0.03, confidence=0.95))
# Result: 1068
```

## Experimental Design in Social Science

### Between-Subjects vs. Within-Subjects

```
Between-subjects:
  + No carryover effects
  + Simpler analysis
  - Requires more participants
  - Individual differences add noise

Within-subjects:
  + More statistical power
  + Fewer participants needed
  - Carryover/order effects
  - Demand characteristics
  Solution: Counterbalance condition order (Latin square)
```

### Randomization and Control

Always use computer-generated random assignment. Block randomization ensures balanced groups. Include manipulation checks to verify that the independent variable was perceived as intended.

## Data Analysis Workflow

```python
# Standard analysis pipeline for survey data
import pandas as pd
from scipy import stats

def analyze_survey(df: pd.DataFrame, iv: str, dv: str,
                    covariates: list[str] = None) -> dict:
    """Run standard analytical checks on survey data."""
    results = {}

    # 1. Descriptive statistics
    results['descriptives'] = df[[iv, dv]].describe().to_dict()

    # 2. Reliability (if scale items provided)
    # Compute Cronbach's alpha for multi-item scales

    # 3. Bivariate test
    if df[iv].nunique() == 2:
        groups = [group[dv].dropna() for _, group in df.groupby(iv)]
        t_stat, p_val = stats.ttest_ind(*groups)
        d = (groups[0].mean() - groups[1].mean()) / df[dv].std()  # Cohen's d
        results['test'] = {'type': 't-test', 't': t_stat, 'p': p_val, 'cohens_d': d}
    else:
        # Correlation for continuous IV
        r, p = stats.pearsonr(df[iv].dropna(), df[dv].dropna())
        results['test'] = {'type': 'correlation', 'r': r, 'p': p}

    return results
```

## Ethical Requirements

All social science research with human participants requires Institutional Review Board (IRB) or Ethics Committee approval. Obtain informed consent, ensure confidentiality, minimize harm, and provide debriefing for deception studies. Follow APA or ASA ethical guidelines as applicable to your discipline.

## Key References

- Creswell, J. W., & Creswell, J. D. (2018). *Research Design* (5th ed.). SAGE.
- Babbie, E. (2020). *The Practice of Social Research* (15th ed.). Cengage.
