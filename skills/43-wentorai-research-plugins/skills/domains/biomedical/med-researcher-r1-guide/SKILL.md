---
name: med-researcher-r1-guide
description: "Medical deep research agent with reasoning chain analysis"
metadata:
  openclaw:
    emoji: "🩺"
    category: "domains"
    subcategory: "biomedical"
    keywords: ["medical research", "deep research", "clinical reasoning", "PubMed", "medical agent", "evidence-based"]
    source: "https://github.com/AQ-MedAI/MedResearcher-R1"
---

# MedResearcher-R1 Guide

## Overview

MedResearcher-R1 is a medical deep research agent that combines clinical reasoning chains with iterative literature search to answer complex medical questions. Unlike general research agents, it is specialized for medical evidence — understanding clinical trial designs, PICO frameworks, evidence hierarchies, and medical terminology. Uses reasoning chain analysis (R1) to decompose clinical questions and systematically gather evidence.

## Architecture

```
Clinical Question
      ↓
  R1 Reasoning Chain (decompose into sub-questions)
      ↓
  Medical Search Agent
  ├── PubMed (MeSH terms)
  ├── ClinicalTrials.gov
  ├── Cochrane Library
  └── WHO ICTRP
      ↓
  Evidence Extraction Agent
  ├── PICO extraction
  ├── Study design classification
  ├── Outcome extraction
  └── Risk of bias assessment
      ↓
  Synthesis Agent (evidence grading)
      ↓
  Clinical Answer + Evidence Report
```

## Usage

```python
from med_researcher_r1 import MedResearcherR1

researcher = MedResearcherR1(
    llm_provider="anthropic",
    search_backends=["pubmed", "clinical_trials", "cochrane"],
)

# Complex clinical question
result = researcher.research(
    question="In patients with treatment-resistant depression, "
             "how does psilocybin-assisted therapy compare to "
             "esketamine in terms of remission rates and "
             "long-term outcomes?",
    evidence_level="systematic",  # systematic, rapid, scoping
    max_papers=50,
)

print(result.summary)
print(f"\nEvidence quality: {result.evidence_grade}")
print(f"Papers analyzed: {len(result.papers)}")
```

## Reasoning Chain

```python
# Inspect the R1 reasoning chain
for step in result.reasoning_chain:
    print(f"\nStep {step.number}: {step.type}")
    print(f"  Question: {step.question}")
    print(f"  Strategy: {step.search_strategy}")
    print(f"  Findings: {step.key_finding}")
    print(f"  Next: {step.next_action}")

# Example chain:
# Step 1: DECOMPOSE — Split into psilocybin efficacy,
#          esketamine efficacy, head-to-head comparisons
# Step 2: SEARCH — PubMed: psilocybin depression RCT
# Step 3: EXTRACT — 3 RCTs found, extract PICO + outcomes
# Step 4: SEARCH — PubMed: esketamine depression outcomes
# Step 5: SYNTHESIZE — Compare evidence, note no direct
#          head-to-head trials exist
# Step 6: CONCLUDE — Indirect comparison with caveats
```

## Evidence Grading

```python
# GRADE methodology for evidence quality
for paper in result.papers[:5]:
    print(f"\n{paper.title} ({paper.year})")
    print(f"  Design: {paper.study_design}")
    print(f"  Sample: {paper.sample_size}")
    print(f"  Grade: {paper.evidence_grade}")
    print(f"  Risk of bias: {paper.risk_of_bias}")

# Aggregate evidence
print(f"\nOverall certainty: {result.certainty}")
# HIGH / MODERATE / LOW / VERY LOW
print(f"Recommendation: {result.recommendation}")
```

## Medical Search Configuration

```python
researcher = MedResearcherR1(
    search_config={
        "pubmed": {
            "use_mesh": True,
            "date_range": "2019/01/01:2025/12/31",
            "article_types": [
                "Randomized Controlled Trial",
                "Meta-Analysis",
                "Systematic Review",
            ],
        },
        "clinical_trials": {
            "status": ["Completed", "Active, not recruiting"],
            "phase": ["Phase 3", "Phase 4"],
        },
    },
    reasoning_config={
        "max_chain_length": 10,
        "reflection_enabled": True,
        "uncertainty_explicit": True,
    },
)
```

## Clinical Use Cases

1. **Clinical queries**: Evidence-based answers to medical questions
2. **Drug comparison**: Indirect comparison when no head-to-head data
3. **Guideline review**: Check evidence supporting clinical guidelines
4. **Case analysis**: Literature context for unusual presentations
5. **Grant proposals**: Evidence landscape for research funding

## References

- [MedResearcher-R1 GitHub](https://github.com/AQ-MedAI/MedResearcher-R1)
- [PubMed E-utilities](https://www.ncbi.nlm.nih.gov/books/NBK25501/)
- [GRADE Handbook](https://gdt.gradepro.org/app/handbook/handbook.html)
