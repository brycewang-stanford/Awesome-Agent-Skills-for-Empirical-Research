---
name: experimental-design-guide
description: "Design rigorous experiments using DOE, factorial designs, and response surfaces"
metadata:
  openclaw:
    emoji: "🧪"
    category: "research"
    subcategory: "methodology"
    keywords: ["design of experiments", "DOE", "factorial design", "response surface methodology", "experimental design"]
    source: "wentor"
---

# Experimental Design Guide

A skill for designing rigorous experiments using formal Design of Experiments (DOE) methodology. Covers factorial designs, fractional factorials, response surface methods, and optimal design strategies for scientific research.

## Fundamental Principles

### Fisher's Three Principles

1. **Randomization**: Assign experimental units to treatments randomly to eliminate systematic bias
2. **Replication**: Include enough replicates to estimate experimental error and ensure statistical power
3. **Blocking**: Group similar experimental units to reduce nuisance variability

### Sample Size and Power Analysis

```python
from scipy import stats
import numpy as np

def power_analysis_ttest(effect_size: float, alpha: float = 0.05,
                          power: float = 0.80, ratio: float = 1.0) -> dict:
    """
    Calculate required sample size for a two-sample t-test.

    Args:
        effect_size: Cohen's d (expected effect size)
        alpha: Significance level
        power: Desired statistical power
        ratio: Ratio of n2/n1 (for unequal groups)
    """
    from statsmodels.stats.power import TTestIndPower
    analysis = TTestIndPower()
    n1 = analysis.solve_power(
        effect_size=effect_size,
        alpha=alpha,
        power=power,
        ratio=ratio,
        alternative='two-sided'
    )

    return {
        'n_per_group': int(np.ceil(n1)),
        'total_n': int(np.ceil(n1) + np.ceil(n1 * ratio)),
        'effect_size_d': effect_size,
        'alpha': alpha,
        'power': power,
        'interpretation': (
            f"Need {int(np.ceil(n1))} per group "
            f"(total N = {int(np.ceil(n1) + np.ceil(n1 * ratio))}) "
            f"to detect d = {effect_size} with {power*100:.0f}% power."
        )
    }

# Example: medium effect size
result = power_analysis_ttest(effect_size=0.5, alpha=0.05, power=0.80)
print(result['interpretation'])
```

## Full Factorial Designs

### 2^k Factorial Design

```python
import itertools
import pandas as pd

def create_factorial_design(factors: dict, replicates: int = 3) -> pd.DataFrame:
    """
    Create a full factorial experimental design.

    Args:
        factors: Dict mapping factor names to lists of levels
                 e.g., {'Temperature': [60, 80], 'Pressure': [1, 2], 'Catalyst': ['A', 'B']}
        replicates: Number of replicates per combination
    """
    factor_names = list(factors.keys())
    factor_levels = list(factors.values())

    # Generate all combinations
    combinations = list(itertools.product(*factor_levels))

    # Create design matrix with replicates
    rows = []
    run_order = 0
    for rep in range(replicates):
        for combo in combinations:
            run_order += 1
            row = {'Run': run_order, 'Replicate': rep + 1}
            for name, value in zip(factor_names, combo):
                row[name] = value
            row['Response'] = None  # To be filled with experimental data
            rows.append(row)

    design = pd.DataFrame(rows)

    # Randomize run order
    design = design.sample(frac=1, random_state=42).reset_index(drop=True)
    design['RandomizedRun'] = range(1, len(design) + 1)

    print(f"Design summary:")
    print(f"  Factors: {len(factors)}")
    print(f"  Levels per factor: {[len(v) for v in factors.values()]}")
    print(f"  Total treatments: {len(combinations)}")
    print(f"  Replicates: {replicates}")
    print(f"  Total runs: {len(design)}")

    return design

# Example: 2^3 factorial
design = create_factorial_design({
    'Temperature': [60, 80],
    'Pressure': [1, 2],
    'Catalyst': ['A', 'B']
}, replicates=3)
```

### Analyzing Factorial Experiments

```python
import statsmodels.api as sm
from statsmodels.formula.api import ols

def analyze_factorial(df: pd.DataFrame, response: str,
                       factors: list[str]) -> dict:
    """
    Analyze a factorial experiment using ANOVA.
    """
    # Build formula with all main effects and interactions
    main_effects = ' + '.join([f'C({f})' for f in factors])
    interactions = ' + '.join([f'C({f1}):C({f2})'
                               for i, f1 in enumerate(factors)
                               for f2 in factors[i+1:]])
    formula = f'{response} ~ {main_effects} + {interactions}'

    model = ols(formula, data=df).fit()
    anova_table = sm.stats.anova_lm(model, typ=2)

    # Effect sizes (eta-squared)
    ss_total = anova_table['sum_sq'].sum()
    anova_table['eta_sq'] = anova_table['sum_sq'] / ss_total

    return {
        'anova_table': anova_table,
        'r_squared': model.rsquared,
        'significant_effects': anova_table[anova_table['PR(>F)'] < 0.05].index.tolist()
    }
```

## Fractional Factorial Designs

When a full factorial has too many runs:

```python
def fractional_factorial_2k(k: int, resolution: int = 3) -> pd.DataFrame:
    """
    Generate a 2^(k-p) fractional factorial design.

    Args:
        k: Number of factors
        resolution: Design resolution (III, IV, or V)
    """
    from pyDOE2 import fracfact

    # Resolution III: 2^(k-p) where p minimizes runs
    # Common designs:
    # 2^(3-1) = 4 runs (Resolution III)
    # 2^(4-1) = 8 runs (Resolution IV)
    # 2^(5-2) = 8 runs (Resolution III)
    # 2^(7-4) = 8 runs (Resolution III, Plackett-Burman)

    design = fracfact(f'a b c {"d" if k >= 4 else ""} {"e" if k >= 5 else ""}')
    df = pd.DataFrame(design, columns=[f'Factor_{i+1}' for i in range(design.shape[1])])

    print(f"Fractional factorial: {len(df)} runs for {k} factors")
    return df
```

## Response Surface Methodology (RSM)

### Central Composite Design

```python
def central_composite_design(factor_ranges: dict) -> pd.DataFrame:
    """
    Create a Central Composite Design for response surface optimization.
    """
    from pyDOE2 import ccdesign

    k = len(factor_ranges)
    design_coded = ccdesign(k, center=(4,), alpha='orthogonal', face='circumscribed')

    factor_names = list(factor_ranges.keys())
    df = pd.DataFrame(design_coded, columns=factor_names)

    # Convert from coded (-1, +1) to natural units
    for name, (low, high) in factor_ranges.items():
        center = (high + low) / 2
        half_range = (high - low) / 2
        df[name] = center + df[name] * half_range

    return df

# Example: optimize a chemical reaction
design = central_composite_design({
    'Temperature_C': [50, 90],
    'pH': [5, 9],
    'Time_min': [10, 60]
})
```

## Randomization and Blinding

- **Single-blind**: Participants do not know their treatment assignment
- **Double-blind**: Neither participants nor experimenters know assignments
- **Allocation concealment**: Assignment sequence is hidden until the moment of assignment

For computer-generated randomization, always record and report the random seed used. Use block randomization to ensure balanced groups when enrollment is sequential.

## Reporting Checklist

Follow CONSORT (clinical trials), ARRIVE (animal studies), or STROBE (observational) guidelines:
- State the primary and secondary outcomes before analysis
- Report all planned analyses, including non-significant results
- Describe randomization method and any deviations from protocol
- Include sample size justification with power analysis parameters
