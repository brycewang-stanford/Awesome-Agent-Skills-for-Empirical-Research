---
name: clinical-pharmacology-guide
description: "Clinical pharmacology principles for dosing, drug interactions, and patient s..."
metadata:
  openclaw:
    emoji: "💉"
    category: "domains"
    subcategory: "pharma"
    keywords: ["drug development", "pharmacokinetics", "clinical trial", "nursing", "pharmacodynamics", "drug interactions"]
    source: "wentor"
---

# Clinical Pharmacology Guide

A skill for applying clinical pharmacology principles to research and practice. Covers pharmacokinetic/pharmacodynamic modeling, drug interaction assessment, therapeutic drug monitoring, and special population dosing.

## Pharmacokinetic-Pharmacodynamic (PK/PD) Relationships

### The Emax Model

The most widely used PK/PD model relates drug concentration to effect:

```python
import numpy as np
import matplotlib.pyplot as plt

def emax_model(concentration: np.ndarray, emax: float, ec50: float,
                hill: float = 1, baseline: float = 0) -> np.ndarray:
    """
    Sigmoid Emax (Hill) model.

    Args:
        concentration: Drug concentration array
        emax: Maximum effect
        ec50: Concentration producing 50% of Emax
        hill: Hill coefficient (steepness)
        baseline: Baseline effect (E0)
    """
    effect = baseline + (emax * concentration**hill) / (ec50**hill + concentration**hill)
    return effect

# Example: dose-response curve
conc = np.logspace(-2, 3, 200)
effect = emax_model(conc, emax=100, ec50=10, hill=1.5)

fig, ax = plt.subplots(figsize=(8, 5))
ax.semilogx(conc, effect)
ax.set_xlabel('Concentration (ng/mL)')
ax.set_ylabel('Effect (%)')
ax.set_title('Sigmoid Emax Model')
ax.axhline(y=50, color='gray', linestyle='--', alpha=0.5)
ax.axvline(x=10, color='gray', linestyle='--', alpha=0.5)
ax.annotate('EC50', xy=(10, 50), fontsize=12)
plt.tight_layout()
```

## Drug Interaction Assessment

### Cytochrome P450 Interaction Prediction

```python
def predict_cyp_interaction(victim_drug: dict, perpetrator_drug: dict) -> dict:
    """
    Predict metabolic drug-drug interaction potential.

    Args:
        victim_drug: {'name': str, 'primary_cyp': str, 'fraction_metabolized': float}
        perpetrator_drug: {'name': str, 'cyp_effects': dict}
            cyp_effects maps CYP enzyme to 'inhibitor'|'inducer'|'none'
    """
    cyp = victim_drug['primary_cyp']
    fm = victim_drug['fraction_metabolized']  # fraction metabolized by this CYP

    perp_effect = perpetrator_drug['cyp_effects'].get(cyp, 'none')

    if perp_effect == 'inhibitor':
        # AUC ratio = 1 / (1 - fm) for complete inhibition
        auc_ratio = 1 / (1 - fm) if fm < 1 else float('inf')
        risk = 'high' if auc_ratio > 5 else 'moderate' if auc_ratio > 2 else 'low'
    elif perp_effect == 'inducer':
        # Induction decreases exposure
        auc_ratio = 1 - fm * 0.7  # approximate 70% induction
        risk = 'high' if auc_ratio < 0.3 else 'moderate' if auc_ratio < 0.5 else 'low'
    else:
        auc_ratio = 1.0
        risk = 'none'

    return {
        'victim': victim_drug['name'],
        'perpetrator': perpetrator_drug['name'],
        'affected_cyp': cyp,
        'interaction_type': perp_effect,
        'predicted_auc_ratio': round(auc_ratio, 2),
        'clinical_risk': risk,
        'recommendation': (
            'Dose adjustment required' if risk == 'high'
            else 'Monitor closely' if risk == 'moderate'
            else 'No action needed'
        )
    }
```

## Therapeutic Drug Monitoring (TDM)

### Narrow Therapeutic Index Drugs

Drugs requiring routine TDM due to narrow therapeutic windows:

| Drug | Therapeutic Range | Toxic Level | Monitoring Frequency |
|------|------------------|-------------|---------------------|
| Vancomycin | AUC/MIC 400-600 | AUC/MIC > 600 | Trough before 4th dose |
| Lithium | 0.6-1.2 mEq/L | > 1.5 mEq/L | Weekly initially, then monthly |
| Digoxin | 0.8-2.0 ng/mL | > 2.0 ng/mL | At steady state (5-7 days) |
| Phenytoin | 10-20 mcg/mL | > 20 mcg/mL | 2 weeks after dose change |
| Tacrolimus | 5-15 ng/mL | > 20 ng/mL | Twice weekly post-transplant |

### Bayesian TDM

```python
def bayesian_dose_adjustment(prior_cl: float, prior_cl_cv: float,
                              measured_conc: float, expected_conc: float,
                              current_dose: float) -> dict:
    """
    Simple Bayesian dose adjustment using one-point TDM.

    Args:
        prior_cl: Population clearance estimate (L/hr)
        prior_cl_cv: CV of clearance in population (0-1)
        measured_conc: Observed trough concentration
        expected_conc: Expected concentration at population CL
        current_dose: Current dose (mg)
    """
    # Individual clearance estimate (MAP approach, simplified)
    ratio = expected_conc / measured_conc
    individual_cl = prior_cl * ratio

    # Bayesian shrinkage toward population
    weight = 1 / (1 + prior_cl_cv**2)
    posterior_cl = weight * prior_cl + (1 - weight) * individual_cl

    # New dose to achieve target
    target_conc = (measured_conc + expected_conc) / 2  # midpoint of range
    new_dose = current_dose * (posterior_cl / prior_cl)

    return {
        'individual_CL': round(individual_cl, 2),
        'posterior_CL': round(posterior_cl, 2),
        'recommended_dose': round(new_dose, 1),
        'dose_change_pct': round((new_dose - current_dose) / current_dose * 100, 1)
    }
```

## Special Populations

Dosing considerations for specific patient groups:

- **Renal impairment**: Use Cockcroft-Gault or CKD-EPI for GFR estimation; adjust doses for renally cleared drugs proportionally
- **Hepatic impairment**: Use Child-Pugh score; reduce doses of hepatically metabolized drugs by 25-50% for moderate impairment
- **Pediatric**: Use allometric scaling (CL proportional to body weight^0.75) rather than simple mg/kg dosing
- **Geriatric**: Account for decreased renal function, polypharmacy, and altered body composition
- **Pregnancy**: Increased clearance for many drugs due to increased blood volume and GFR

## Regulatory Considerations

All clinical pharmacology studies should follow ICH guidelines (E4 for dose-response, E5 for ethnic factors, E7 for geriatric, E11 for pediatric). Report results in standardized population PK/PD formats compatible with FDA and EMA submission requirements.
