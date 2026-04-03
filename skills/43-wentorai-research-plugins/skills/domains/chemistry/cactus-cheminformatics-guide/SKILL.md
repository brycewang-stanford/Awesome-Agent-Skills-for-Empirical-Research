---
name: cactus-cheminformatics-guide
description: "PNNL cheminformatics LLM agent for molecular analysis"
metadata:
  openclaw:
    emoji: "🌵"
    category: "domains"
    subcategory: "chemistry"
    keywords: ["CACTUS", "cheminformatics", "PNNL", "molecular analysis", "LLM chemistry", "chemical agent"]
    source: "https://github.com/pnnl/cactus"
---

# CACTUS Cheminformatics Agent Guide

## Overview

CACTUS is a cheminformatics LLM agent developed at Pacific Northwest National Laboratory (PNNL) that provides AI-assisted molecular analysis, property prediction, and chemical reasoning. It wraps RDKit, molecular databases, and ML models behind a conversational interface, enabling researchers to query molecular properties, perform similarity searches, and run cheminformatics workflows using natural language.

## Usage

```python
from cactus import ChemAgent

agent = ChemAgent(llm_provider="anthropic")

# Natural language chemistry queries
result = agent.ask(
    "What is the molecular weight and LogP of aspirin? "
    "Is it drug-like by Lipinski's rules?"
)
print(result.answer)
# Aspirin (CC(=O)Oc1ccccc1C(=O)O):
# MW: 180.16, LogP: 1.24
# Lipinski: PASS (MW<500, LogP<5, HBD=1≤5, HBA=4≤10)

# Molecular property calculation
props = agent.calculate_properties(
    smiles="CC(=O)Oc1ccccc1C(=O)O",
    properties=["mw", "logp", "tpsa", "hbd", "hba", "rotatable"],
)
print(props)
```

## Similarity Search

```python
# Find similar molecules
similar = agent.similarity_search(
    query_smiles="CC(=O)Oc1ccccc1C(=O)O",  # Aspirin
    database="chembl",
    threshold=0.7,  # Tanimoto similarity
    max_results=10,
)

for mol in similar:
    print(f"{mol.name}: {mol.smiles} "
          f"(similarity: {mol.tanimoto:.3f})")
```

## Substructure Analysis

```python
# Substructure search
matches = agent.substructure_search(
    pattern="c1ccccc1C(=O)O",  # Benzoic acid motif
    database="drugbank",
    max_results=20,
)

# Functional group identification
groups = agent.identify_functional_groups(
    smiles="CC(=O)Oc1ccccc1C(=O)O"
)
# ["ester", "carboxylic_acid", "aromatic_ring"]
```

## Use Cases

1. **Molecular analysis**: Property calculation via natural language
2. **Drug screening**: Lipinski/Veber rule checking
3. **Similarity search**: Find analogs in chemical databases
4. **Structure analysis**: Substructure and functional group ID
5. **Chemical education**: Interactive chemistry exploration

## References

- [CACTUS GitHub](https://github.com/pnnl/cactus)
- [RDKit](https://www.rdkit.org/)
- [PNNL](https://www.pnnl.gov/)
