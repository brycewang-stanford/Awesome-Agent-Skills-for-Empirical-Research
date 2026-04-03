---
name: latte-review-guide
description: "Automate systematic literature reviews with LatteReview AI agents"
metadata:
  openclaw:
    emoji: "☕"
    category: "research"
    subcategory: "paper-review"
    keywords: ["LatteReview", "systematic review", "literature screening", "AI review", "title screening", "PRISMA"]
    source: "https://github.com/PouriaRouzrokh/LatteReview"
---

# LatteReview Guide

## Overview

LatteReview is a low-code Python package that uses AI agents to automate systematic literature reviews. It handles title/abstract screening, full-text assessment, data extraction, and PRISMA-compliant reporting — tasks that typically consume hundreds of researcher-hours. Supports multiple LLM backends (Anthropic, OpenAI, local models).

## Installation

```bash
pip install lattereview
```

## Core Workflow

### Step 1: Initialize Review

```python
from lattereview import ReviewProject

# Create a new review project
project = ReviewProject(
    name="ML in Medical Imaging Review",
    research_question="What deep learning architectures are used for "
                      "medical image segmentation?",
    inclusion_criteria=[
        "Uses deep learning for medical image segmentation",
        "Published in peer-reviewed venue",
        "Reports quantitative evaluation metrics",
    ],
    exclusion_criteria=[
        "Review/survey articles",
        "Non-English publications",
        "Conference abstracts only",
    ],
)
```

### Step 2: Import Papers

```python
# Import from various sources
project.import_papers("scopus_export.csv", source="scopus")
project.import_papers("pubmed_export.csv", source="pubmed")

# Or from a DataFrame
import pandas as pd
df = pd.read_csv("papers.csv")
project.import_from_dataframe(df,
    title_col="title",
    abstract_col="abstract",
    year_col="year",
)

print(f"Imported {project.total_papers} papers")
```

### Step 3: AI Screening

```python
from lattereview.agents import ScreeningAgent

# Configure screening agent
screener = ScreeningAgent(
    llm_provider="anthropic",
    model="claude-sonnet-4-20250514",
    criteria=project.inclusion_criteria,
    exclusion=project.exclusion_criteria,
)

# Title/abstract screening
results = screener.screen(
    project.papers,
    mode="title_abstract",
    confidence_threshold=0.7,
)

# Results include: decision, confidence, reasoning
for paper in results[:3]:
    print(f"{paper.title}")
    print(f"  Decision: {paper.decision} "
          f"(confidence: {paper.confidence:.2f})")
    print(f"  Reason: {paper.reasoning}")
```

### Step 4: Data Extraction

```python
from lattereview.agents import ExtractionAgent

extractor = ExtractionAgent(
    llm_provider="anthropic",
    fields={
        "architecture": "Deep learning architecture used",
        "dataset": "Medical imaging dataset",
        "modality": "Imaging modality (CT, MRI, X-ray, etc.)",
        "dice_score": "Best Dice similarity coefficient reported",
        "sample_size": "Number of images/patients",
    },
)

extracted = extractor.extract(project.included_papers)

# Export structured data
extracted.to_csv("extracted_data.csv")
```

### Step 5: Generate Report

```python
# PRISMA flow diagram
project.generate_prisma_diagram("prisma.png")

# Summary statistics
summary = project.summarize()
print(f"Screened: {summary['screened']}")
print(f"Included: {summary['included']}")
print(f"Excluded: {summary['excluded']}")
```

## Configuration

```python
# Use different LLM providers
screener = ScreeningAgent(
    llm_provider="openai",
    model="gpt-4o",
)

# Local models via Ollama
screener = ScreeningAgent(
    llm_provider="ollama",
    model="llama3",
    base_url="http://localhost:11434",
)
```

## Dual-Reviewer Mode

```python
# Simulate dual-reviewer screening for reliability
results = screener.dual_screen(
    project.papers,
    models=["claude-sonnet-4-20250514", "gpt-4o"],
    agreement_threshold=0.8,
)

# Papers with disagreement flagged for human review
conflicts = [p for p in results if p.agreement < 0.8]
print(f"{len(conflicts)} papers need human adjudication")
```

## Use Cases

1. **Systematic reviews**: PRISMA-compliant literature reviews
2. **Scoping reviews**: Rapid evidence mapping
3. **Meta-analysis preparation**: Structured data extraction
4. **Grant applications**: Quick literature landscape assessment

## References

- [LatteReview GitHub](https://github.com/PouriaRouzrokh/LatteReview)
- [LatteReview Documentation](https://lattereview.readthedocs.io/)
- Rouzrokh, P. et al. (2024). "LatteReview: AI-Assisted Systematic Literature Reviews."
