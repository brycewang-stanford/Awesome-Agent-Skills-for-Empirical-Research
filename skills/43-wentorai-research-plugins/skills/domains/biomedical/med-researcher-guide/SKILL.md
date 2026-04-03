---
name: med-researcher-guide
description: "Multi-agent system for biomedical literature review and synthesis"
metadata:
  openclaw:
    emoji: "🏥"
    category: "domains"
    subcategory: "biomedical"
    keywords: ["medical research", "biomedical agent", "clinical literature", "PubMed agent", "medical AI", "evidence synthesis"]
    source: "wentor-research-plugins"
---

# Med-Researcher Guide

## Overview

Med-Researcher is a multi-agent system designed specifically for biomedical literature review. It orchestrates specialized agents for searching PubMed and other medical databases, extracting structured evidence from clinical papers, and synthesizing findings into evidence-graded summaries. Particularly useful for clinical evidence reviews, drug interaction research, and systematic reviews in medicine.

## Architecture

### Agent Roles

```
Query → Planning Agent (decomposes clinical question)
            ↓
      Search Agent (PubMed, PMC, clinical trials)
            ↓
      Extraction Agent (PICO, outcomes, evidence grade)
            ↓
      Synthesis Agent (evidence summary, contradictions)
            ↓
      Report Agent (structured review output)
```

### Agent Descriptions

| Agent | Role |
|-------|------|
| **Planner** | Converts clinical question to PICO format, generates sub-queries |
| **Searcher** | Queries PubMed, PMC, ClinicalTrials.gov |
| **Extractor** | Extracts structured data: population, intervention, outcomes |
| **Synthesizer** | Grades evidence, identifies consensus and contradictions |
| **Reporter** | Generates formatted review with citations |

## Usage

```python
from med_researcher import MedResearcher

researcher = MedResearcher(
    llm_provider="anthropic",
    search_backends=["pubmed", "pmc", "clinical_trials"],
)

# Clinical question
result = researcher.review(
    question="What is the comparative efficacy of SGLT2 inhibitors "
             "versus GLP-1 receptor agonists for cardiovascular "
             "outcomes in type 2 diabetes?",
    max_papers=50,
    evidence_grading=True,
)

print(result.summary)
print(f"Papers analyzed: {len(result.papers)}")
print(f"Evidence grade: {result.overall_grade}")
```

## PICO Framework Integration

```python
# Automatic PICO extraction from clinical question
pico = researcher.extract_pico(
    "Does metformin reduce cancer incidence in diabetic patients?"
)
# P: patients with diabetes
# I: metformin treatment
# C: no metformin / other antidiabetics
# O: cancer incidence

# Search with PICO components
result = researcher.review_pico(
    population="type 2 diabetes patients",
    intervention="metformin",
    comparison="placebo or other antidiabetics",
    outcome="cancer incidence",
)
```

## Evidence Grading

```python
# Evidence levels following GRADE methodology
for paper in result.papers:
    print(f"{paper.title}")
    print(f"  Study type: {paper.study_type}")  # RCT, cohort, case-control
    print(f"  Evidence level: {paper.evidence_level}")  # High/Moderate/Low/Very Low
    print(f"  Risk of bias: {paper.bias_risk}")
    print(f"  Sample size: {paper.sample_size}")

# Aggregate evidence summary
print(f"\nOverall certainty: {result.certainty}")
print(f"Recommendation strength: {result.recommendation}")
```

## Search Configuration

```python
researcher = MedResearcher(
    search_config={
        "pubmed": {
            "max_results": 100,
            "date_range": ("2020-01-01", "2025-12-31"),
            "article_types": ["Clinical Trial", "Meta-Analysis",
                              "Randomized Controlled Trial"],
        },
        "clinical_trials": {
            "status": ["Completed", "Active"],
            "phase": ["Phase 3", "Phase 4"],
        },
    },
    extraction_config={
        "fields": ["population", "intervention", "comparator",
                   "primary_outcome", "secondary_outcomes",
                   "adverse_events", "sample_size", "follow_up"],
    },
)
```

## Output Formats

```python
# Structured evidence table
result.export_evidence_table("evidence_table.csv")

# PRISMA flow diagram data
prisma = result.prisma_flow()
print(f"Identified: {prisma['identified']}")
print(f"Screened: {prisma['screened']}")
print(f"Included: {prisma['included']}")

# Bibliography
result.export_bibtex("references.bib")

# Full report
result.export_report("review.md", format="markdown")
```

## Clinical Use Cases

1. **Drug comparison reviews**: Head-to-head efficacy analysis
2. **Safety signal detection**: Adverse event pattern identification
3. **Guideline evidence**: Supporting clinical guideline development
4. **Grant proposals**: Rapid evidence landscape assessment
5. **Journal clubs**: Structured paper discussion preparation

## References

- [Med-Researcher GitHub](https://github.com/mao1207/Med-Researcher)
- [GRADE Handbook](https://gdt.gradepro.org/app/handbook/handbook.html)
- [PubMed API (E-utilities)](https://www.ncbi.nlm.nih.gov/books/NBK25501/)
