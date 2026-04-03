---
name: retrosynthesis-guide
description: "Retrosynthetic analysis and computational reaction prediction"
metadata:
  openclaw:
    emoji: "🧪"
    category: "domains"
    subcategory: "chemistry"
    keywords: ["retrosynthesis", "reaction prediction", "organic chemistry", "computational chemistry"]
    source: "wentor-research-plugins"
---

# Retrosynthesis Guide

Plan synthetic routes for target molecules using retrosynthetic analysis principles and computational tools, from Corey's logic to modern AI-driven approaches.

## What Is Retrosynthesis?

Retrosynthesis works backward from a target molecule to identify simpler, commercially available precursors:

```
Target Molecule (TM)
       |
   [Disconnection 1] ← Apply transform (reverse of a known reaction)
       |
   Synthon A + Synthon B
       |            |
   [Available]  [Disconnection 2]
                    |
                Synthon C + Synthon D
                    |            |
                [Available]  [Available]
```

Key terminology:
- **Target Molecule (TM)**: The molecule you want to synthesize
- **Synthon**: Idealized reactive fragment from a disconnection
- **Synthetic Equivalent**: Real reagent corresponding to a synthon
- **Transform**: Reverse of a chemical reaction (retro-reaction)
- **FGI (Functional Group Interconversion)**: Convert one functional group to another to enable a disconnection

## Corey's Retrosynthetic Strategies

### Strategic Bond Disconnections

| Strategy | Description | When to Use |
|----------|-------------|------------|
| **FGI** | Convert functional groups to enable disconnections | When direct disconnection is not possible |
| **C-C Bond disconnection** | Break carbon-carbon bonds | Building the carbon skeleton |
| **C-X Bond disconnection** | Break carbon-heteroatom bonds | Functional group installation |
| **Ring disconnection** | Open rings to identify acyclic precursors | Cyclic target molecules |
| **Symmetry exploitation** | Use molecular symmetry to simplify analysis | Symmetric molecules |
| **Convergent synthesis** | Combine two complex fragments late | Minimize linear step count |

### Common Disconnection Patterns

```
# Alcohol (C-OH) → Carbonyl reduction
R-CH(OH)-R' ⟹ R-CO-R' + NaBH4/LiAlH4

# Amine (C-N) → Reductive amination
R-CH2-NH-R' ⟹ R-CHO + R'-NH2

# C-C Bond (aldol) → Aldol retro
R-CH(OH)-CH2-CO-R' ⟹ R-CHO + CH3-CO-R'

# C-C Bond (Grignard) → Grignard retro
R-CH(OH)-R' ⟹ R-CHO + R'-MgBr

# Ester (C-O) → Fischer esterification retro
R-COO-R' ⟹ R-COOH + R'-OH

# Amide (C-N) → Amide coupling retro
R-CO-NH-R' ⟹ R-COOH + R'-NH2

# Diels-Alder → Retro Diels-Alder
Cyclohexene derivative ⟹ Diene + Dienophile

# Wittig → Retro Wittig
R-CH=CH-R' ⟹ R-CHO + R'-CH2-PPh3
```

## Computational Retrosynthesis Tools

### Tool Comparison

| Tool | Developer | Method | Access |
|------|-----------|--------|--------|
| ASKCOS | MIT | Template-based + neural | Free (askcos.mit.edu) |
| IBM RXN | IBM Research | Transformer seq2seq | Free (rxn.res.ibm.com) |
| Reaxys | Elsevier | Database-backed | Subscription |
| SciFinder-n | CAS | Database + AI | Subscription |
| Spaya | Iktos | Graph neural network | Commercial |
| AiZynthFinder | AstraZeneca | Monte Carlo tree search | Open source |

### Using ASKCOS

```python
import requests

# ASKCOS API for retrosynthetic planning
# (requires running ASKCOS locally or using the hosted version)

target_smiles = "CC(=O)Oc1ccccc1C(=O)O"  # Aspirin

# One-step retrosynthesis
response = requests.post(
    "https://askcos.mit.edu/api/retro/",
    json={
        "smiles": target_smiles,
        "num_results": 10,
        "max_depth": 5
    }
)

results = response.json()
for i, result in enumerate(results.get("precursors", [])[:5]):
    print(f"Route {i+1}:")
    print(f"  Precursors: {result['smiles']}")
    print(f"  Template: {result.get('template', 'N/A')}")
    print(f"  Score: {result.get('score', 'N/A')}")
```

### Using IBM RXN for Chemistry

```python
# IBM RXN API
from rxn4chemistry import RXN4ChemistryWrapper

api_key = os.environ["RXN4CHEM_API_KEY"]
rxn = RXN4ChemistryWrapper(api_key=api_key)
rxn.create_project("retrosynthesis_example")

# Predict retrosynthesis
response = rxn.predict_automatic_retrosynthesis(
    product="CC(=O)Oc1ccccc1C(=O)O",  # Aspirin
    max_steps=3
)

# Get results
results = rxn.get_predict_automatic_retrosynthesis_results(response["prediction_id"])
for route in results.get("retrosynthetic_paths", []):
    print(f"Route confidence: {route.get('confidence', 'N/A')}")
    for step in route.get("steps", []):
        print(f"  Reaction: {step.get('reaction_smiles', 'N/A')}")
```

### Using AiZynthFinder (Open Source)

```python
from aizynthfinder.aizynthfinder import AiZynthFinder

# Configure the finder
finder = AiZynthFinder()
finder.stock.load("zinc_stock.hdf5")  # Commercial building blocks
finder.expansion_policy.load("expansion_policy_model.onnx")  # Retro model

# Set target
finder.target_smiles = "CC(=O)Oc1ccccc1C(=O)O"  # Aspirin

# Run tree search
finder.config.search.time_limit = 120  # seconds
finder.config.search.iteration_limit = 500
finder.tree_search()

# Extract and analyze routes
finder.build_routes()
for i, route in enumerate(finder.routes):
    print(f"Route {i+1} (score: {route.score:.3f}):")
    print(f"  Steps: {len(route.reactions)}")
    for rxn in route.reactions:
        print(f"    {rxn}")
```

## SMILES Notation for Chemistry

SMILES (Simplified Molecular Input Line Entry System) is the standard text representation:

```
# Common SMILES patterns
Water:          O
Ethanol:        CCO
Benzene:        c1ccccc1
Aspirin:        CC(=O)Oc1ccccc1C(=O)O
Caffeine:       Cn1c(=O)c2c(ncn2C)n(C)c1=O
Ibuprofen:      CC(C)Cc1ccc(cc1)C(C)C(=O)O

# SMILES rules
# Atoms: C, N, O, S, P, F, Cl, Br, I
# Bonds: - (single, implicit), = (double), # (triple)
# Branches: () for branching
# Rings: numbers for ring closure (c1ccccc1 = benzene)
# Aromatic: lowercase letters
# Stereochemistry: / \ for E/Z, @ @@ for R/S
```

## Reaction Databases

| Database | Coverage | Features | Access |
|----------|----------|----------|--------|
| Reaxys | 130M+ reactions | Experimental conditions, yields | Subscription |
| SciFinder / CAS | 160M+ reactions | Commercial availability, safety data | Subscription |
| USPTO | 3.7M reactions | US patent reactions | Free (open data) |
| Open Reaction Database (ORD) | Growing | Structured reaction data, conditions | Free |
| RMG (Reaction Mechanism Generator) | Kinetics | Automated mechanism generation | Free (MIT) |

## Best Practices for Route Planning

1. **Start simple**: Begin with the most obvious disconnections before trying exotic transforms.
2. **Consider availability**: Check if precursors are commercially available (Sigma-Aldrich, TCI, Alfa Aesar).
3. **Minimize steps**: Convergent synthesis (combining two complex halves) is generally preferred over linear synthesis.
4. **Protect and deprotect wisely**: Minimize protecting group manipulations; each adds 2 steps (protection + deprotection).
5. **Check literature**: Search Reaxys or SciFinder for precedent before attempting novel transformations.
6. **Validate computationally**: Use forward reaction prediction to verify that proposed retrosynthetic steps are feasible.
7. **Consider scale**: Reactions that work at milligram scale may fail at gram scale. Check for scalability issues (exothermic reactions, heterogeneous mixing).
