---
name: bioagents-guide
description: "AI scientist framework for autonomous biological research workflows"
metadata:
  openclaw:
    emoji: "🧬"
    category: "domains"
    subcategory: "biomedical"
    keywords: ["AI scientist", "biological research", "autonomous lab", "drug discovery", "protein design", "bioinformatics"]
    source: "https://github.com/SakanaAI/AI-Scientist"
---

# BioAgents Guide

## Overview

BioAgents -- AI agent systems for biological research -- represent a paradigm shift in how life science experiments are conceived, designed, executed, and analyzed. Building on the foundation of large language models, these systems integrate literature search, hypothesis generation, experimental design, data analysis, and manuscript drafting into semi-autonomous or fully autonomous research pipelines.

The AI Scientist framework (Sakana AI, 2024) demonstrated that language models can conduct end-to-end research: generating ideas, writing code, running experiments, and producing papers. In biology, this approach is being applied to drug discovery, protein engineering, genomics analysis, and systems biology -- domains where the combinatorial complexity of experimental space makes AI-assisted exploration particularly valuable.

This guide covers the architecture of bioagent systems, the biological research tasks they can automate, integration with wet-lab automation, and the methodological considerations for researchers building or evaluating these systems. The focus is on practical patterns that connect AI capabilities to real biological research problems.

## BioAgent Architecture

### System Components

```
BioAgent System Architecture:

┌─────────────────────────────────────────────────┐
│                  ORCHESTRATOR                     │
│  (LLM-based planning and reasoning agent)        │
├──────────┬──────────┬──────────┬────────────────┤
│ LITERATURE│ HYPOTHESIS│ EXPERIMENT│   ANALYSIS    │
│  MODULE   │  MODULE   │  MODULE   │   MODULE      │
├──────────┼──────────┼──────────┼────────────────┤
│ PubMed   │ Causal   │ Protocol │ Statistical    │
│ Semantic │ inference│ generator│ analysis       │
│ Scholar  │ Graph    │ Robot    │ Visualization  │
│ BioRxiv  │ reasoning│ interface│ Interpretation │
│ Patents  │ Novelty  │ LIMS     │ Manuscript     │
│          │ scoring  │ integration│ drafting      │
└──────────┴──────────┴──────────┴────────────────┘
         │              │              │
    ┌────┴────┐   ┌────┴────┐   ┌────┴────┐
    │ Knowledge│   │ Wet Lab  │   │ Compute │
    │ Bases    │   │ Equipment│   │ Cluster │
    └─────────┘   └─────────┘   └─────────┘
```

### Implementing a Literature-Driven Hypothesis Agent

```python
from dataclasses import dataclass
from typing import List, Optional
import json

@dataclass
class Hypothesis:
    statement: str
    mechanism: str
    evidence_for: List[str]
    evidence_against: List[str]
    novelty_score: float
    testability_score: float
    predicted_outcome: str

def generate_hypotheses(
    research_question: str,
    literature_context: List[dict],
    existing_data: Optional[dict] = None,
    n_hypotheses: int = 5,
) -> List[Hypothesis]:
    """
    Generate ranked hypotheses from literature and data context.

    This is a framework for LLM-driven hypothesis generation.
    In practice, the LLM call would go here.
    """
    prompt = f"""
    Based on the following research question and literature context,
    generate {n_hypotheses} testable hypotheses.

    Research question: {research_question}

    Literature findings:
    {json.dumps(literature_context, indent=2)}

    For each hypothesis, provide:
    1. A clear, falsifiable statement
    2. The proposed mechanism
    3. Supporting evidence from the literature
    4. Contradictory evidence
    5. Novelty score (0-1): How novel relative to existing literature
    6. Testability score (0-1): How feasible to test experimentally
    7. Predicted outcome if the hypothesis is correct
    """

    # In production: response = llm.generate(prompt)
    # Parse and return structured hypotheses
    return []  # Placeholder for LLM output parsing

def rank_hypotheses(hypotheses: List[Hypothesis]) -> List[Hypothesis]:
    """Rank hypotheses by composite score (novelty * testability)."""
    for h in hypotheses:
        h.composite_score = h.novelty_score * h.testability_score
    return sorted(hypotheses, key=lambda h: h.composite_score, reverse=True)
```

## Biological Research Tasks for AI Agents

### Drug Discovery Pipeline

```
AI-assisted drug discovery workflow:

1. TARGET IDENTIFICATION
   - Literature mining for disease-gene associations
   - Network analysis of protein-protein interactions
   - Druggability assessment (binding site prediction)
   Tools: OpenTargets, STRING, FPocket

2. HIT IDENTIFICATION
   - Virtual screening of compound libraries
   - De novo molecular generation (SMILES, graph-based)
   - Docking and scoring (molecular dynamics)
   Tools: AutoDock-GPU, RDKit, DeepChem

3. LEAD OPTIMIZATION
   - ADMET property prediction (absorption, distribution, metabolism)
   - Toxicity prediction
   - Multi-objective optimization (potency vs. selectivity vs. ADMET)
   Tools: ADMET-AI, ToxCast, Optuna

4. PRECLINICAL VALIDATION
   - In vitro assay design and analysis
   - Animal model selection and protocol design
   - Pharmacokinetic modeling
   Tools: PK-Sim, literature-based dose prediction
```

### Protein Design and Engineering

```python
# Example: Using ESM-2 embeddings for protein function prediction
# (Practical pattern for bioagent integration)

from transformers import AutoTokenizer, AutoModel
import torch

def get_protein_embeddings(sequences: list, model_name: str = "facebook/esm2_t33_650M_UR50D"):
    """
    Generate protein embeddings using ESM-2 for downstream tasks.
    Applications: function prediction, fitness landscape, design.
    """
    tokenizer = AutoTokenizer.from_pretrained(model_name)
    model = AutoModel.from_pretrained(model_name)
    model.eval()

    embeddings = []
    for seq in sequences:
        inputs = tokenizer(seq, return_tensors="pt", padding=True, truncation=True, max_length=1024)
        with torch.no_grad():
            outputs = model(**inputs)
            # Use mean pooling over sequence length
            embedding = outputs.last_hidden_state.mean(dim=1).squeeze().numpy()
            embeddings.append(embedding)

    return embeddings

# Applications:
# 1. Cluster proteins by function (unsupervised)
# 2. Predict fitness effects of mutations (supervised)
# 3. Guide directed evolution experiments (active learning)
# 4. Design novel sequences (generative, conditional on embedding space)
```

### Genomics Analysis Automation

```python
# Automated RNA-seq analysis pipeline
# (Pattern for agent-orchestrated bioinformatics)

def automated_rnaseq_pipeline(
    fastq_dir: str,
    reference_genome: str,
    sample_sheet: str,
    output_dir: str,
) -> dict:
    """
    End-to-end RNA-seq analysis pipeline that a bioagent can orchestrate.

    Steps:
    1. Quality control (FastQC + MultiQC)
    2. Adapter trimming (Trim Galore)
    3. Alignment (STAR or HISAT2)
    4. Quantification (featureCounts or Salmon)
    5. Differential expression (DESeq2)
    6. Pathway analysis (GSEA, enrichR)
    7. Visualization and report generation
    """
    pipeline_steps = {
        "qc": f"fastqc {fastq_dir}/*.fastq.gz -o {output_dir}/qc/",
        "trim": f"trim_galore --paired {fastq_dir}/*_R1.fastq.gz {fastq_dir}/*_R2.fastq.gz -o {output_dir}/trimmed/",
        "align": f"STAR --genomeDir {reference_genome} --readFilesIn {{trimmed_R1}} {{trimmed_R2}} --outSAMtype BAM SortedByCoordinate",
        "count": f"featureCounts -a {reference_genome}/genes.gtf -o {output_dir}/counts.txt {{bam_files}}",
        "de_analysis": "Rscript run_deseq2.R --counts counts.txt --design sample_sheet.csv",
        "pathway": "Rscript run_gsea.R --de_results de_results.csv --gene_sets msigdb.gmt",
        "report": "Rmarkdown::render('analysis_report.Rmd')",
    }

    return {
        "pipeline": pipeline_steps,
        "expected_outputs": [
            "qc/multiqc_report.html",
            "de_results.csv",
            "pathway_results.csv",
            "analysis_report.html",
            "figures/volcano_plot.pdf",
            "figures/heatmap.pdf",
        ],
    }
```

## Integration with Lab Automation

### Connecting AI Agents to Robotic Labs

```
Cloud lab integration pattern:

AGENT → API → CLOUD LAB → RESULTS → AGENT

Platforms:
- Emerald Cloud Lab: Programmatic access to wet lab equipment
- Strateos: Automated biology research platform
- Arctoris: AI-integrated drug discovery lab

API pattern:
1. Agent designs experiment protocol (JSON/YAML)
2. Protocol validated against lab capabilities
3. Experiment submitted via API
4. Real-time monitoring of experiment progress
5. Results returned as structured data
6. Agent analyzes results, designs next experiment

Active learning loop:
- Agent proposes most informative experiment (Bayesian optimization)
- Lab executes experiment
- Results update model
- Repeat until convergence or budget exhausted
```

## Evaluation and Validation

### How to Evaluate a BioAgent System

| Criterion | Metric | Benchmark |
|-----------|--------|-----------|
| Literature coverage | Recall of relevant papers | Compare to expert bibliography |
| Hypothesis quality | Expert rating (1-5), novelty score | Panel of domain scientists |
| Experimental design | Validity, power, feasibility | IRB/protocol review standards |
| Data analysis | Accuracy, reproducibility | Gold standard datasets |
| Manuscript quality | Expert review scores | Peer review simulation |
| Cost efficiency | $/discovery, time to insight | Traditional lab benchmarks |

## Ethical Considerations

```
Key ethical issues in autonomous biological research:

1. DUAL USE RISK
   - AI-designed pathogens or toxins
   - Mitigation: Red-team evaluation, biosecurity review
   - Reference: Wilson Center, NTI biosecurity frameworks

2. REPRODUCIBILITY
   - Agent-generated experiments must be reproducible
   - All parameters, code, and data must be logged
   - Version control for every pipeline component

3. ATTRIBUTION
   - Who is the "author" of AI-generated research?
   - Current consensus: Humans are responsible, AI is a tool
   - Journals require human accountability for all claims

4. DATA PRIVACY
   - Patient data in biomedical research (HIPAA, GDPR)
   - Agent access must respect data governance
   - De-identification before agent processing
```

## Best Practices

- **Human in the loop for critical decisions.** AI can propose hypotheses and designs; humans must validate before wet-lab execution.
- **Version control everything.** Prompts, model versions, pipeline configs, and results must be reproducible.
- **Validate against known results first.** Test the bioagent on problems with known answers before applying to novel questions.
- **Use structured output formats.** JSON schemas for protocols, results, and hypotheses enable reliable agent-to-agent communication.
- **Monitor for hallucination.** LLMs can generate plausible but incorrect biological claims -- always verify against primary literature.
- **Start narrow, expand gradually.** Build agents for specific tasks (e.g., differential expression analysis) before attempting end-to-end research.

## References

- [AI Scientist](https://github.com/SakanaAI/AI-Scientist) -- Sakana AI's autonomous research framework
- [ESM-2](https://github.com/facebookresearch/esm) -- Meta's protein language model
- [ChemCrow](https://arxiv.org/abs/2304.05376) -- LLM agent for chemistry research
- [BioGPT](https://github.com/microsoft/BioGPT) -- Microsoft's biomedical text generation model
- [OpenTargets](https://www.opentargets.org/) -- Target identification platform
