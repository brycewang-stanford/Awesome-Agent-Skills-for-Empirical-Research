---
name: chemeagle-guide
description: "Multi-agent system for chemical literature information extraction"
metadata:
  openclaw:
    emoji: "🦅"
    category: "domains"
    subcategory: "chemistry"
    keywords: ["ChemEagle", "chemical extraction", "literature mining", "reaction extraction", "chemistry NLP", "multi-agent"]
    source: "https://github.com/CYF2000127/ChemEagle"
---

# ChemEagle Guide

## Overview

ChemEagle is a multi-agent system for extracting structured chemical information from scientific literature. It uses specialized agents for recognizing chemical entities, extracting reaction conditions, identifying product yields, and building structured databases from unstructured chemistry papers. Particularly useful for building reaction databases and automating systematic reviews in chemistry.

## Agent Pipeline

```
Chemistry Paper (PDF/text)
         ↓
   Document Parser Agent (section identification)
         ↓
   Chemical NER Agent
   ├── Compound names → SMILES/InChI
   ├── Reagents and catalysts
   ├── Solvents and conditions
   └── Product identification
         ↓
   Reaction Extraction Agent
   ├── Reactants → Products mapping
   ├── Reaction conditions (T, P, time)
   ├── Yields and selectivity
   └── Procedure steps
         ↓
   Validation Agent (cross-check extracted data)
         ↓
   Structured Output (JSON, CSV, database)
```

## Usage

```python
from chemeagle import ChemEagle

eagle = ChemEagle(llm_provider="anthropic")

# Extract from a chemistry paper
result = eagle.extract("paper.pdf")

# Extracted reactions
for rxn in result.reactions:
    print(f"\nReaction {rxn.id}:")
    print(f"  Reactants: {rxn.reactants}")
    print(f"  Products: {rxn.products}")
    print(f"  Catalyst: {rxn.catalyst}")
    print(f"  Solvent: {rxn.solvent}")
    print(f"  Temperature: {rxn.temperature}")
    print(f"  Time: {rxn.time}")
    print(f"  Yield: {rxn.yield_percent}%")
    print(f"  SMILES: {rxn.product_smiles}")

# Extracted compounds
for compound in result.compounds:
    print(f"{compound.name}: {compound.smiles}")
```

## Batch Processing

```python
# Process multiple papers
results = eagle.extract_batch(
    input_dir="chemistry_papers/",
    output_format="csv",
    output_file="reactions_database.csv",
)

print(f"Papers processed: {results.papers_processed}")
print(f"Reactions extracted: {results.total_reactions}")
print(f"Unique compounds: {results.unique_compounds}")
```

## Chemical Entity Recognition

```python
# Standalone NER
entities = eagle.recognize_entities(
    "The Suzuki coupling of 4-bromoanisole with phenylboronic "
    "acid using Pd(PPh3)4 catalyst in THF/water at 80°C "
    "gave 4-methoxybiphenyl in 95% yield."
)

for entity in entities:
    print(f"  [{entity.type}] {entity.text}")
    if entity.smiles:
        print(f"    SMILES: {entity.smiles}")

# Output:
# [REACTANT] 4-bromoanisole — SMILES: COc1ccc(Br)cc1
# [REACTANT] phenylboronic acid — SMILES: OB(O)c1ccccc1
# [CATALYST] Pd(PPh3)4
# [SOLVENT] THF/water
# [CONDITION] 80°C
# [PRODUCT] 4-methoxybiphenyl — SMILES: COc1ccc(-c2ccccc2)cc1
# [YIELD] 95%
```

## Database Building

```python
# Build a searchable reaction database
from chemeagle import ReactionDatabase

db = ReactionDatabase("reactions.db")

# Add extracted reactions
db.add_from_extraction(result)

# Search by substrate
hits = db.search(reactant="bromoanisole", reaction_type="coupling")
for hit in hits:
    print(f"{hit.reactants} → {hit.products} ({hit.yield_percent}%)")
    print(f"  Source: {hit.paper_doi}")

# Search by conditions
hits = db.search(catalyst="palladium", temperature_max=100)

# Export
db.export_csv("all_reactions.csv")
db.export_json("all_reactions.json")
```

## Use Cases

1. **Reaction mining**: Extract reactions from chemistry literature
2. **Database building**: Automated reaction database construction
3. **Systematic reviews**: Structured data from chemistry papers
4. **Synthesis planning**: Search conditions for target reactions
5. **Trend analysis**: Track reaction methodology evolution

## References

- [ChemEagle GitHub](https://github.com/CYF2000127/ChemEagle)
- [RDKit](https://www.rdkit.org/) — Chemistry toolkit
- [PubChem](https://pubchem.ncbi.nlm.nih.gov/) — Chemical database
