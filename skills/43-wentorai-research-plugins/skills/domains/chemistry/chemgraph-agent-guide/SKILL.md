---
name: chemgraph-agent-guide
description: "Automate molecular simulations with the ChemGraph agentic framework"
metadata:
  openclaw:
    emoji: "⚗️"
    category: "domains"
    subcategory: "chemistry"
    keywords: ["ChemGraph", "molecular simulation", "computational chemistry", "DFT", "LangGraph", "ASE"]
    source: "https://github.com/argonne-lcf/ChemGraph"
---

# ChemGraph Agent Guide

## Overview

ChemGraph is an agentic framework from Argonne National Lab that automates molecular simulation workflows using LLMs. Built on LangGraph and ASE (Atomic Simulation Environment), it enables natural language control of computational chemistry tasks — structure generation, geometry optimization, thermochemistry, and more. Supports DFT (NWChem, ORCA), semi-empirical (xTB), and ML potentials (MACE).

## Installation

```bash
pip install chemgraph

# Or via Docker
docker pull ghcr.io/argonne-lcf/chemgraph:latest
```

## Core Capabilities

### Natural Language Chemistry

```python
from chemgraph import ChemGraphAgent

agent = ChemGraphAgent(
    llm_provider="anthropic",
    calculator="xtb",  # fast semi-empirical
)

# Natural language molecular tasks
result = agent.run("Optimize the geometry of caffeine and calculate its vibrational frequencies")
print(result.energy)
print(result.frequencies)

# Thermochemistry
result = agent.run("Calculate the enthalpy of formation of ethanol at 298K")
print(f"ΔHf = {result.enthalpy:.2f} kJ/mol")
```

### Supported Calculators

| Calculator | Type | Speed | Accuracy |
|-----------|------|-------|----------|
| xTB (TBLite) | Semi-empirical | Fast | Moderate |
| MACE | ML potential | Fast | Good |
| NWChem | Ab initio DFT | Slow | High |
| ORCA | Ab initio/DFT | Slow | High |
| UMA | Universal ML | Fast | Good |

### Workflow Automation

```python
# Multi-step workflow
workflow = agent.create_workflow([
    "Generate 3D structure of aspirin from SMILES",
    "Optimize geometry with DFT/B3LYP/6-31G*",
    "Calculate IR spectrum",
    "Identify key functional group vibrations",
])
results = workflow.execute()

# Reaction pathway
pathway = agent.run(
    "Find the transition state for the Diels-Alder reaction "
    "between butadiene and ethylene"
)
```

### Integration with ASE

```python
from ase.io import read
from chemgraph.calculators import get_calculator

# Use ChemGraph's calculator with ASE directly
atoms = read("molecule.xyz")
calc = get_calculator("xtb")
atoms.calc = calc

energy = atoms.get_potential_energy()
forces = atoms.get_forces()
```

## Agent Architecture

ChemGraph uses LangGraph's state machine to orchestrate:

1. **Parser Agent** — Interprets natural language into chemistry tasks
2. **Structure Agent** — Generates/retrieves molecular structures (SMILES, PDB, CIF)
3. **Calculator Agent** — Selects and runs appropriate simulation backend
4. **Analysis Agent** — Processes results and generates reports

## Use Cases

1. **High-throughput screening**: Automated property calculation for molecular libraries
2. **Reaction discovery**: Transition state finding and reaction pathway analysis
3. **Materials design**: Optimize structures for target properties
4. **Education**: Natural language interface for learning computational chemistry

## Requirements

- Python 3.10+
- At least one calculator backend (xTB recommended for getting started)
- LLM API key (Anthropic, OpenAI, or local)

## References

- [ChemGraph GitHub](https://github.com/argonne-lcf/ChemGraph)
- [ASE Documentation](https://wiki.fysik.dtu.dk/ase/)
- [LangGraph](https://github.com/langchain-ai/langgraph)
