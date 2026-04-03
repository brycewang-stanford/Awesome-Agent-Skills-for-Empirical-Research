---
name: llm-scientific-discovery-guide
description: "Survey of LLM agents for biomedical scientific discovery"
metadata:
  openclaw:
    emoji: "🧬"
    category: "research"
    subcategory: "deep-research"
    keywords: ["LLM agents", "scientific discovery", "biomedical AI", "drug discovery", "hypothesis generation", "lab automation"]
    source: "https://github.com/zjlrock777/Awesome-LLM-Agents-Scientific-Discovery"
---

# LLM Agents for Scientific Discovery Guide

## Overview

A curated survey of how LLM-based agents are being applied to scientific discovery, with a focus on biomedical research. Covers hypothesis generation, experiment design, lab automation, literature synthesis, and multi-agent scientific collaboration. Tracks papers, tools, and frameworks across the spectrum from fully autonomous to human-in-the-loop systems.

## Landscape

```
LLM Agents for Scientific Discovery
├── Hypothesis Generation
│   ├── Literature-based (gap identification)
│   ├── Data-driven (pattern discovery)
│   └── Analogy-based (cross-domain transfer)
├── Experiment Design
│   ├── Protocol generation
│   ├── Parameter optimization
│   └── Control selection
├── Lab Automation
│   ├── Robot control (self-driving labs)
│   ├── Equipment programming
│   └── Data collection orchestration
├── Analysis & Interpretation
│   ├── Statistical analysis
│   ├── Visualization
│   └── Result interpretation
└── Communication
    ├── Paper writing
    ├── Presentation generation
    └── Peer review simulation
```

## Key Systems

| System | Domain | Capability |
|--------|--------|-----------|
| **AI Scientist** | ML/AI | Full paper generation pipeline |
| **ChemCrow** | Chemistry | Tool-augmented chemical reasoning |
| **Coscientist** | Chemistry | Autonomous experiment execution |
| **BioPlanner** | Biology | Experiment protocol generation |
| **MedAgent** | Medicine | Clinical trial analysis |
| **GenAgent** | Genomics | Gene expression analysis |
| **DrugAgent** | Pharma | Drug interaction prediction |

## Hypothesis Generation

```python
# LLM-based hypothesis generation pattern
from scientific_agent import HypothesisGenerator

generator = HypothesisGenerator(
    llm_provider="anthropic",
    knowledge_sources=["pubmed", "openalex"],
)

hypotheses = generator.generate(
    domain="oncology",
    context="Recent findings show that gut microbiome "
            "composition correlates with immunotherapy response",
    constraints=[
        "Must be testable in vitro",
        "Should involve specific bacterial species",
        "Must have measurable endpoints",
    ],
    num_hypotheses=5,
)

for h in hypotheses:
    print(f"\nHypothesis: {h.statement}")
    print(f"  Rationale: {h.rationale}")
    print(f"  Supporting evidence: {len(h.evidence)} papers")
    print(f"  Novelty score: {h.novelty_score:.2f}")
    print(f"  Feasibility: {h.feasibility}")
```

## Self-Driving Lab Integration

```python
# Agent controlling automated experiments
from scientific_agent import LabAgent

agent = LabAgent(
    llm_provider="anthropic",
    equipment=["plate_reader", "liquid_handler", "incubator"],
    safety_constraints=["bsl2", "max_volume_1ml"],
)

# Design and run experiment
result = agent.run_experiment(
    objective="Determine IC50 of compound X against cell line Y",
    protocol_type="dose_response",
    parameters={
        "compound": "Compound_X",
        "cell_line": "HeLa",
        "concentrations": "serial_dilution",
        "replicates": 3,
        "readout": "cell_viability",
    },
)

print(f"IC50: {result.ic50:.2f} uM")
print(f"R-squared: {result.r_squared:.3f}")
result.plot_dose_response("dose_response.pdf")
```

## Multi-Agent Scientific Collaboration

```python
# Agents with different scientific roles
from scientific_agent import ScientificTeam

team = ScientificTeam(
    agents={
        "PI": {"role": "research_director",
               "expertise": "oncology"},
        "Experimentalist": {"role": "experiment_design",
                           "expertise": "cell_biology"},
        "Analyst": {"role": "data_analysis",
                   "expertise": "biostatistics"},
        "Writer": {"role": "manuscript_writing",
                  "expertise": "scientific_communication"},
    },
)

# Collaborative research cycle
project = team.start_project(
    title="Microbiome-immunotherapy interaction study",
    timeline_weeks=12,
)

# Agents collaborate: PI directs → Experimentalist designs →
# Analyst processes → Writer documents
```

## Reading Roadmap

```markdown
### Foundational Papers
1. "The AI Scientist" (Lu et al., 2024) — Fully automated ML research
2. "ChemCrow" (Bran et al., 2023) — Chemistry tool-use agent
3. "Coscientist" (Boiko et al., 2023) — Autonomous chemical research
4. "BioPlanner" (Biswas et al., 2024) — Biology protocol generation

### Surveys
5. "Scientific Discovery in the Age of AI" (Wang et al., 2023)
6. "Foundation Models for Science" (Bommasani et al., 2022)
7. "LLM Agents: A Survey" (multiple, 2024)

### Ethics & Limitations
8. "Dual-use concerns of AI in biology" (Sandbrink, 2023)
9. "Can LLMs Generate Novel Research Ideas?" (Si et al., 2024)
```

## Use Cases

1. **Literature mining**: Automated hypothesis from research gaps
2. **Experiment automation**: Self-driving lab orchestration
3. **Drug discovery**: Multi-agent screening and optimization
4. **Research planning**: Protocol and proposal generation
5. **Scientific writing**: Paper drafting with verified claims

## References

- [Awesome-LLM-Agents-Scientific-Discovery](https://github.com/zjlrock777/Awesome-LLM-Agents-Scientific-Discovery)
- [The AI Scientist](https://arxiv.org/abs/2408.06292)
- [ChemCrow](https://arxiv.org/abs/2304.05376)
