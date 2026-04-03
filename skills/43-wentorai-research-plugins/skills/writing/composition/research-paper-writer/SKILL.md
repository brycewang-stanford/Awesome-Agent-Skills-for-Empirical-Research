---
name: research-paper-writer
description: "Guide for writing formal academic papers following IEEE and ACM standards"
metadata:
  openclaw:
    emoji: "📝"
    category: "writing"
    subcategory: "composition"
    keywords: ["academic writing", "IEEE format", "ACM format", "paper structure", "manuscript preparation", "citation formatting"]
    source: "wentor-research-plugins"
---

# Research Paper Writer — IEEE/ACM Standards Guide

## Overview

This skill guides the creation of formal academic papers for computer science and engineering venues, with a focus on IEEE and ACM formatting standards. It covers manuscript structure, citation practices, figure/table conventions, and submission preparation. Applicable to conference papers (6-10 pages), journal articles (12-20 pages), and workshop papers (4-6 pages).

## Paper Structure

### IEEE Format (Two-Column)

```
Title
Authors (Name, Affiliation, Email)
Abstract (150-250 words)
Index Terms (4-6 keywords)

I.   INTRODUCTION
II.  RELATED WORK
III. METHODOLOGY / PROPOSED APPROACH
IV.  EXPERIMENTAL SETUP
V.   RESULTS AND DISCUSSION
VI.  CONCLUSION
     ACKNOWLEDGMENTS
     REFERENCES
```

### ACM Format (Two-Column, CCS Concepts)

```
Title
Authors (Name, Affiliation, Email, ORCID)
Abstract (150-250 words)
CCS Concepts (from ACM Computing Classification System)
Keywords (3-6 terms)

1  INTRODUCTION
2  BACKGROUND AND RELATED WORK
3  APPROACH / METHOD
4  EVALUATION
5  RESULTS
6  DISCUSSION
7  THREATS TO VALIDITY
8  CONCLUSION
   ACKNOWLEDGMENTS
   REFERENCES
```

## Section Writing Guidelines

### Abstract

Write the abstract last. Follow the 4-sentence pattern:

1. **Context**: One sentence establishing the problem domain
2. **Problem**: One sentence stating the specific gap or challenge
3. **Approach**: One sentence describing your method/contribution
4. **Results**: One sentence summarizing key findings with numbers

```
Example (IEEE style, ~180 words):
"Large language models have demonstrated remarkable capabilities in code
generation, yet their performance degrades significantly on domain-specific
APIs. This paper addresses the challenge of adapting LLMs to specialized
codebases without extensive fine-tuning. We propose RetrievalCoder, a
retrieval-augmented approach that indexes API documentation and retrieves
relevant context at inference time using semantic similarity. Experiments
on three enterprise codebases show that RetrievalCoder improves functional
correctness by 34.2% over the base model and 12.8% over few-shot prompting,
while reducing API hallucination rate from 47% to 8%."
```

### Introduction (1.5-2 pages)

Structure as an inverted triangle:

1. **Broad context** (1-2 paragraphs): Establish the research area
2. **Specific problem** (1 paragraph): Narrow to your exact problem
3. **Limitations of existing work** (1 paragraph): Why current solutions fall short
4. **Your contribution** (1 paragraph): What you do differently
5. **Contribution list** (bulleted): 3-4 concrete contributions
6. **Paper organization** (1 sentence): "The remainder of this paper is organized as..."

### Related Work (1-1.5 pages)

Organize by **theme**, not chronologically:

```markdown
## 2. Related Work

### 2.1 Retrieval-Augmented Generation
[Discuss RAG papers, position your work relative to them]

### 2.2 Code Generation with LLMs
[Discuss code LLM papers, explain what's different about your setting]

### 2.3 Domain-Specific Adaptation
[Discuss fine-tuning vs. prompting approaches]
```

Each paragraph should: (1) summarize the cited work, (2) state its limitation, (3) contrast with your approach.

### Methodology (2-3 pages)

- Start with a **system overview figure** (architecture diagram)
- Use **formal notation** introduced in a "Preliminaries" subsection
- Define each component with its own subsection
- Include **pseudocode** (Algorithm environment) for complex procedures
- Explain design choices with justification

### Experiments (2-3 pages)

Cover these elements systematically:

| Element | What to Include |
|---------|----------------|
| **Research Questions** | RQ1, RQ2, RQ3 — one per aspect you evaluate |
| **Datasets** | Name, size, source, preprocessing, train/test split |
| **Baselines** | Each baseline with citation and brief description |
| **Metrics** | Definition of each metric, why it's appropriate |
| **Implementation** | Hardware, software versions, hyperparameters |
| **Reproducibility** | Code/data availability statement |

### Results Tables

```latex
% IEEE style table
\begin{table}[t]
\caption{Comparison with baselines on CodeBench.}
\label{tab:main_results}
\centering
\begin{tabular}{lcccc}
\toprule
Method & Pass@1 & Pass@5 & API Acc. & Latency \\
\midrule
GPT-4 (zero-shot) & 42.3 & 61.7 & 53.1 & 2.1s \\
GPT-4 (few-shot)  & 55.8 & 72.4 & 71.2 & 2.3s \\
\textbf{Ours}      & \textbf{68.0} & \textbf{81.2} & \textbf{91.8} & 2.8s \\
\bottomrule
\end{tabular}
\end{table}
```

**Table conventions**:
- Caption above the table (IEEE/ACM standard)
- Bold the best result in each column
- Use `\toprule`, `\midrule`, `\bottomrule` (booktabs) — no vertical lines
- Include statistical significance indicators (†, *, **) with footnotes

### Discussion

Address:
1. **Why does your method work?** — Provide intuition and analysis
2. **When does it fail?** — Failure case analysis builds credibility
3. **Ablation study** — Remove components one at a time
4. **Threats to validity** — Internal, external, construct validity

## Citation Formatting

### IEEE Style

```latex
% Numeric citations in square brackets
As shown by Smith et al. \cite{smith2024}, ...
Several studies \cite{smith2024, jones2023, lee2025} have shown ...

% BibTeX entry
@inproceedings{smith2024,
  author    = {Smith, John and Doe, Jane},
  title     = {Paper Title Here},
  booktitle = {Proceedings of ICSE 2024},
  year      = {2024},
  pages     = {100--110},
  doi       = {10.1145/1234567.1234568}
}
```

### ACM Style

```latex
% Author-year or numeric depending on template
\citet{smith2024} showed that ...  % Smith et al. (2024)
\citep{smith2024}                  % (Smith et al., 2024)
```

### Citation Best Practices

- Cite **40-60 references** for a conference paper, **60-100** for a journal
- Include papers from the **target venue** (shows you know the community)
- Cite **recent work** (at least 30% from last 2 years)
- Always cite the **original source**, not a survey that mentions it
- Use DOI links in bibliography entries for verifiability

## Submission Checklist

```markdown
## Pre-Submission Checks
- [ ] Paper fits within page limit (including references for ACM, excluding for IEEE)
- [ ] Abstract under 250 words
- [ ] All figures are vector graphics (PDF) or high-resolution (≥300 DPI)
- [ ] Figure/table captions are self-contained (understandable without reading text)
- [ ] All references are complete (no "et al." in BibTeX, no missing venues/years)
- [ ] No orphan sections (every section has ≥2 paragraphs)
- [ ] Supplementary material / appendix prepared if needed
- [ ] Anonymous version: no author names, no "our previous work [1]" self-citations
- [ ] Spell check and grammar check completed
- [ ] PDF metadata does not reveal author identity (for double-blind review)
```

## References

- [IEEE Author Tools](https://journals.ieeeauthorcenter.ieee.org/)
- [ACM Primary Article Templates](https://www.acm.org/publications/proceedings-template)
- [ACM CCS Tree](https://dl.acm.org/ccs)
- [Booktabs Package Documentation](https://ctan.org/pkg/booktabs)
