---
name: pharmacovigilance-guide
description: "Adverse drug event detection, safety signal mining, and drug monitoring"
metadata:
  openclaw:
    emoji: "⚠️"
    category: "domains"
    subcategory: "pharma"
    keywords: ["pharmacovigilance", "adverse-events", "drug-safety", "faers", "signal-detection", "disproportionality"]
    source: "wentor"
---

# Pharmacovigilance Guide

A skill for computational pharmacovigilance research, covering adverse drug event (ADE) databases, signal detection algorithms, disproportionality analysis, and safety surveillance methods used in post-market drug monitoring.

## Adverse Event Data Sources

### Key Databases

| Database | Operator | Coverage | Access |
|----------|----------|----------|--------|
| FAERS (FDA Adverse Event Reporting System) | FDA | US spontaneous reports | Free quarterly downloads |
| EudraVigilance | EMA | European reports | Research access via application |
| VigiBase | WHO-UMC | Global (150+ countries) | Research license |
| VAERS | CDC/FDA | US vaccine adverse events | Free download |
| MAUDE | FDA | Medical device reports | Free download |

### Loading FAERS Data

```python
import pandas as pd
import zipfile
import os

def load_faers_quarter(data_dir: str, year: int, quarter: int) -> dict:
    """
    Load FAERS quarterly data files into DataFrames.
    Downloads available from: fis.fda.gov/extensions/FPD-QDE-FAERS/FPD-QDE-FAERS.html
    Returns dict of DataFrames for each file type.
    """
    prefix = f"faers_ascii_{year}Q{quarter}"
    tables = {}

    file_map = {
        "DEMO": "demographics",    # Patient demographics
        "DRUG": "drugs",            # Drug information
        "REAC": "reactions",        # Adverse reactions (MedDRA terms)
        "OUTC": "outcomes",         # Patient outcomes
        "INDI": "indications",     # Drug indications
        "THER": "therapy",          # Therapy dates
        "RPSR": "report_sources",   # Report source
    }

    for suffix, name in file_map.items():
        filepath = os.path.join(data_dir, f"{suffix}{year}Q{quarter}.txt")
        if os.path.exists(filepath):
            tables[name] = pd.read_csv(
                filepath, sep="$", encoding="latin-1",
                low_memory=False, on_error="warn"
            )

    return tables

# Example: Load and inspect
faers = load_faers_quarter("./faers_data", 2024, 3)
print(f"Reports: {len(faers['demographics']):,}")
print(f"Drug-reaction pairs: {len(faers['reactions']):,}")
```

## Signal Detection Methods

### Disproportionality Analysis

Disproportionality measures compare the observed frequency of a drug-event pair against the expected frequency under independence:

```python
import numpy as np
from scipy.stats import chi2

def compute_disproportionality(a: int, b: int, c: int, d: int) -> dict:
    """
    Compute disproportionality measures from a 2x2 contingency table:

              Event+    Event-
    Drug+       a          b
    Drug-       c          d

    a: reports with both the drug and the event
    b: reports with the drug but not the event
    c: reports with the event but not the drug
    d: reports with neither
    """
    n = a + b + c + d
    expected = (a + b) * (a + c) / n if n > 0 else 0

    # Reporting Odds Ratio (ROR)
    ror = (a * d) / (b * c) if b * c > 0 else float("inf")
    ln_ror = np.log(ror) if ror > 0 and ror != float("inf") else 0
    se_ln_ror = np.sqrt(1/a + 1/b + 1/c + 1/d) if min(a, b, c, d) > 0 else float("inf")
    ror_lower = np.exp(ln_ror - 1.96 * se_ln_ror)

    # Proportional Reporting Ratio (PRR)
    prr = (a / (a + b)) / (c / (c + d)) if (a + b) > 0 and (c + d) > 0 else 0

    # Information Component (IC, Bayesian shrinkage)
    ic = np.log2((a + 0.5) / (expected + 0.5)) if expected > 0 else 0

    # Chi-squared with Yates correction
    chi2_val = (n * (abs(a * d - b * c) - n / 2) ** 2) / (
        (a + b) * (c + d) * (a + c) * (b + d)
    ) if min(a + b, c + d, a + c, b + d) > 0 else 0

    return {
        "a": a, "b": b, "c": c, "d": d,
        "expected": round(expected, 2),
        "ROR": round(ror, 3),
        "ROR_lower_95": round(ror_lower, 3),
        "PRR": round(prr, 3),
        "IC": round(ic, 3),
        "chi2": round(chi2_val, 3),
        "signal": ror_lower > 1 and a >= 3 and chi2_val > 3.84,
    }
```

### Multi-Item Gamma Poisson Shrinker (MGPS)

The MGPS method (used by FDA) applies empirical Bayesian shrinkage to stabilize estimates for rare events:

```python
def empirical_bayes_geometric_mean(observed: np.ndarray,
                                     expected: np.ndarray) -> np.ndarray:
    """
    Simplified EBGM computation.
    Shrinks observed/expected ratios toward the overall mean,
    reducing false positives from small counts.
    """
    # Raw ratio
    rr = observed / np.maximum(expected, 0.01)

    # Empirical Bayes shrinkage (simplified two-component mixture)
    # Full implementation uses EM algorithm to fit mixture of gammas
    global_mean = np.mean(rr)
    shrinkage = expected / (expected + 1)  # more shrinkage for small expected
    ebgm = shrinkage * rr + (1 - shrinkage) * global_mean

    return ebgm
```

## MedDRA Terminology

### Medical Dictionary for Regulatory Activities

MedDRA provides the standardized terminology for adverse event coding:

```
Hierarchy (5 levels):
  System Organ Class (SOC)      -- e.g., "Cardiac disorders"
    High Level Group Term (HLGT) -- e.g., "Cardiac arrhythmias"
      High Level Term (HLT)      -- e.g., "Supraventricular tachyarrhythmias"
        Preferred Term (PT)      -- e.g., "Atrial fibrillation"
          Lowest Level Term (LLT) -- e.g., "Auricular fibrillation"
```

### Standardized MedDRA Queries (SMQs)

Pre-defined search strategies for known safety topics:

- **Anaphylactic reaction (SMQ)**: Broad and narrow search terms
- **Drug-induced liver injury (SMQ)**: Hy's Law criteria
- **Torsade de pointes / QT prolongation (SMQ)**: Cardiac safety signals
- **Rhabdomyolysis (SMQ)**: Muscle-related adverse events

## Temporal Pattern Analysis

### Time-to-Onset Analysis

```python
def time_to_onset_analysis(drug_start_dates: pd.Series,
                            event_dates: pd.Series) -> dict:
    """
    Analyze time-to-onset distribution for a drug-event pair.
    Useful for distinguishing causal signals from coincidental reports.
    """
    ttp = (event_dates - drug_start_dates).dt.days
    ttp = ttp[ttp >= 0]  # exclude negative (data quality issue)

    return {
        "n_reports": len(ttp),
        "median_days": ttp.median(),
        "mean_days": ttp.mean(),
        "q25_days": ttp.quantile(0.25),
        "q75_days": ttp.quantile(0.75),
        "within_30_days_pct": (ttp <= 30).mean() * 100,
        "within_90_days_pct": (ttp <= 90).mean() * 100,
    }
```

## Causality Assessment

Standard frameworks for evaluating whether a drug caused an adverse event:

| Method | Type | Key Criteria |
|--------|------|-------------|
| WHO-UMC | Algorithmic | Temporal, dechallenge, rechallenge, alternative causes |
| Naranjo Score | Scoring scale | 10 questions, score 0-13 (definite/probable/possible/doubtful) |
| Bradford Hill | Principles | Strength, consistency, specificity, temporality, biological gradient |

## Tools and Resources

- **openFDA API**: Direct access to FAERS data via REST
- **OHDSI / OMOP CDM**: Standardized observational health data for pharmacoepidemiology
- **PhViD (R package)**: Pharmacovigilance signal detection methods
- **EHRtemporalVariability**: R package for temporal data quality in EHR
- **VigiRank**: WHO-UMC signal prioritization algorithm
- **AEOLUS**: Standardized and cleaned version of FAERS data
