---
name: slr-automation-guide
description: "Tools and pipelines for automating systematic literature reviews"
metadata:
  openclaw:
    emoji: "📋"
    category: "research"
    subcategory: "methodology"
    keywords: ["systematic review", "SLR", "automation", "screening", "PRISMA", "evidence synthesis"]
    source: "https://github.com/asreview/asreview"
---

# Systematic Literature Review Automation Guide

## Overview

Systematic Literature Reviews (SLRs) are rigorous, reproducible surveys of research evidence following protocols like PRISMA and Cochrane. This guide covers tools that automate the most time-consuming steps — deduplication, title/abstract screening, full-text assessment, and data extraction — using active learning, NLP, and AI agents. Key tools include ASReview, Rayyan, and custom pipelines.

## SLR Pipeline

```
Protocol Definition (PICO, inclusion/exclusion criteria)
         ↓
   Database Search (PubMed, Scopus, Web of Science)
         ↓
   Deduplication (ASReview, Rayyan, or custom)
         ↓
   Title/Abstract Screening (AI-assisted prioritization)
         ↓
   Full-text Assessment (relevance + quality)
         ↓
   Data Extraction (structured tables)
         ↓
   Quality Assessment (risk of bias)
         ↓
   Synthesis + PRISMA Report
```

## ASReview (Active Learning)

```bash
# Install ASReview
pip install asreview

# Launch web interface
asreview lab

# CLI screening
asreview simulate benchmark:van_de_Schoot_2017 \
  -m nb -e tfidf \
  --n_prior_included 5 --n_prior_excluded 5 \
  -o results/simulation.asreview
```

### Python API

```python
import asreview
from asreview import ASReviewData, ReviewSimulate

# Load dataset (RIS, CSV, or Excel)
data = ASReviewData.from_file("search_results.ris")
print(f"Records: {len(data)}")

# Active learning simulation
sim = ReviewSimulate(
    data,
    model="nb",              # Naive Bayes classifier
    feature_extraction="tfidf",
    query_strategy="max",     # Show most likely relevant first
    n_prior_included=5,
    n_prior_excluded=5,
)
sim.review()

# Results: screening order optimized by relevance
print(f"Work saved: {sim.work_saved():.1%}")
# Typically 80-95% of irrelevant papers screened out early
```

## Deduplication

```python
# ASReview deduplication
from asreview.data import ASReviewData

# Merge results from multiple databases
datasets = [
    ASReviewData.from_file("pubmed_results.ris"),
    ASReviewData.from_file("scopus_results.ris"),
    ASReviewData.from_file("wos_results.ris"),
]

merged = ASReviewData.from_dataframe(
    pd.concat([d.df for d in datasets])
)
print(f"Before dedup: {len(merged)}")

# Fuzzy matching on title + DOI
deduplicated = merged.deduplicate()
print(f"After dedup: {len(deduplicated)}")
```

## AI-Assisted Screening

```python
# Custom LLM screening pipeline
from slr_tools import LLMScreener

screener = LLMScreener(
    llm_provider="anthropic",
    criteria={
        "population": "Adults with type 2 diabetes",
        "intervention": "SGLT2 inhibitors",
        "outcomes": "Cardiovascular events",
        "study_types": ["RCT", "cohort", "meta-analysis"],
        "exclusions": ["animal studies", "in vitro", "pediatric"],
    },
)

# Screen abstracts
results = screener.screen_batch(
    records=search_results,
    fields=["title", "abstract"],
    threshold=0.5,  # Include if P(relevant) > 0.5
)

for r in results:
    print(f"[{'INCLUDE' if r.include else 'EXCLUDE'}] "
          f"(p={r.confidence:.2f}) {r.title[:60]}...")
    print(f"  Reason: {r.reason}")
```

## Data Extraction

```python
# Structured data extraction from full-text papers
from slr_tools import DataExtractor

extractor = DataExtractor(
    llm_provider="anthropic",
    schema={
        "study_design": "str",
        "sample_size": "int",
        "population_description": "str",
        "intervention_details": "str",
        "primary_outcome": "str",
        "effect_size": "float",
        "confidence_interval": "str",
        "p_value": "float",
        "follow_up_duration": "str",
        "risk_of_bias": "str",
    },
)

# Extract from PDF
extracted = extractor.extract("paper.pdf")
print(extracted.to_dict())

# Batch extraction
results_df = extractor.extract_batch("fulltext_papers/")
results_df.to_csv("extraction_table.csv")
```

## PRISMA Flow Diagram

```python
# Generate PRISMA 2020 flow diagram
from slr_tools import PRISMAFlow

flow = PRISMAFlow(
    identification={
        "databases": {"PubMed": 1200, "Scopus": 890, "WoS": 650},
        "other_sources": {"citation_search": 45},
    },
    screening={
        "after_dedup": 1850,
        "excluded_title_abstract": 1620,
        "sought_fulltext": 230,
        "not_retrieved": 12,
    },
    included={
        "assessed_fulltext": 218,
        "excluded_fulltext": {
            "wrong_population": 45,
            "wrong_intervention": 32,
            "wrong_outcome": 28,
            "wrong_study_type": 15,
        },
        "final_included": 98,
    },
)

flow.save_svg("prisma_flow.svg")
flow.save_latex("prisma_flow.tex")
```

## Quality Assessment

```python
# Risk of Bias assessment (Cochrane RoB 2)
from slr_tools import RiskOfBias

rob = RiskOfBias(tool="rob2")  # or "robins_i" for non-RCTs

assessment = rob.assess(
    paper="paper.pdf",
    domains=[
        "randomization_process",
        "deviations_from_intervention",
        "missing_outcome_data",
        "outcome_measurement",
        "selection_of_reported_result",
    ],
)

print(f"Overall: {assessment.overall_judgment}")
for domain, judgment in assessment.domain_judgments.items():
    print(f"  {domain}: {judgment}")
```

## Use Cases

1. **Medical SLRs**: Cochrane-style evidence reviews
2. **CS surveys**: Comprehensive literature mapping
3. **Policy reviews**: Evidence synthesis for policy decisions
4. **Thesis literature chapters**: Structured review sections
5. **Grant applications**: Rapid evidence landscape scans

## References

- [ASReview](https://asreview.nl/) — Active learning for systematic reviews
- [PRISMA 2020](http://www.prisma-statement.org/) — Reporting guidelines
- [Cochrane Handbook](https://training.cochrane.org/handbook)
- [Rayyan](https://www.rayyan.ai/) — Collaborative screening platform
