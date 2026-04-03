---
name: academic-paper-summarizer
description: "Summarize academic papers with structured extraction of key elements"
metadata:
  openclaw:
    emoji: "📋"
    category: "literature"
    subcategory: "metadata"
    keywords: ["paper summary", "structured extraction", "abstract", "key findings", "research synthesis", "literature review"]
    source: "https://github.com/lifan0127/ai-research-assistant"
---

# Academic Paper Summarizer

## Overview

Academic papers are dense, technical documents that require significant time to read and understand fully. The Academic Paper Summarizer skill provides a systematic framework for extracting the essential elements from research papers into structured, reusable summaries.

This skill is designed for researchers who need to rapidly process large volumes of literature—whether during a systematic review, when onboarding into a new field, or when preparing a literature review section for their own manuscripts. Rather than producing generic summaries, it enforces a structured template that captures the components most relevant to downstream academic work: research questions, methodology, key findings, limitations, and contributions to the field.

The skill works with any academic paper format (PDF, HTML, plain text) and can be adapted across disciplines from biomedical sciences to social sciences, engineering, and humanities. It emphasizes fidelity to the original text while organizing information into a consistent schema that facilitates comparison across papers.

## Structured Extraction Framework

The core of this skill is a multi-section extraction template. When summarizing a paper, populate each of the following fields:

**Bibliographic Metadata:**
- Title, authors, journal/conference, year, DOI
- Paper type (empirical, review, theoretical, methodological, case study)

**Research Context:**
- What gap in the literature does this paper address?
- What is the stated research question or hypothesis?
- How does the paper position itself relative to prior work?

**Methodology Summary:**
- Study design (experimental, observational, computational, qualitative, mixed)
- Data sources, sample size, and key variables
- Analytical methods and tools used
- Any novel methodological contributions

**Key Findings:**
- Primary results stated in 3-5 bullet points
- Statistical significance or effect sizes where reported
- Figures and tables worth revisiting (note figure/table numbers)

**Critical Assessment:**
- Strengths of the study design and execution
- Limitations acknowledged by authors and any additional limitations you identify
- Potential biases or confounding factors
- Generalizability of findings

**Relevance and Connections:**
- How does this paper connect to your current research?
- Which references cited in this paper should you follow up on?
- Does this paper support, contradict, or extend existing findings in your collection?

## Batch Processing Workflow

When processing multiple papers (e.g., during a literature review), follow this workflow for efficiency:

1. **Triage pass**: Read title, abstract, and conclusions of each paper. Assign a relevance score (1-5) and decide whether to perform full extraction.
2. **Full extraction**: For papers scoring 3+, apply the complete structured extraction template above.
3. **Cross-paper synthesis**: After extracting 5-10 papers on a related subtopic, create a synthesis note that identifies common findings, methodological trends, and open questions.
4. **Gap identification**: Compare your extraction set against your research questions to identify what evidence is still missing.

**Example extraction prompt:**

```
Read this paper and extract the following in structured format:
1. Bibliographic info (title, authors, year, journal, DOI)
2. Research question / hypothesis
3. Methodology (design, data, sample, analysis)
4. Key findings (3-5 bullets with effect sizes)
5. Limitations and biases
6. Relevance to [your topic]
7. Key references to follow up
```

## Tips for High-Quality Summaries

- **Preserve author voice for claims**: When summarizing findings, note whether the authors use hedging language ("suggests", "may indicate") versus strong claims ("demonstrates", "proves"). This matters for synthesis.
- **Note negative results**: Papers often bury non-significant findings. Explicitly extract these, as they are crucial for meta-analyses and for avoiding publication bias in your review.
- **Tag with your own keywords**: Beyond the authors' keywords, add your own tags that connect the paper to your research framework. This makes retrieval easier later.
- **Record page numbers**: When noting key findings or quotes, record the page number so you can return to the source quickly.
- **Update summaries**: If you re-read a paper later with new context, update the summary rather than creating a duplicate.

## Output Formats

Summaries can be exported in several formats depending on your workflow:

- **Markdown**: For integration with note-taking tools (Obsidian, Notion, Logseq)
- **BibTeX annotation**: Append the summary as an `annote` field in your BibTeX entry
- **CSV row**: For spreadsheet-based literature tracking with one row per paper
- **JSON**: For programmatic processing or import into reference managers

## References

- Keshav, S. (2007). "How to Read a Paper." ACM SIGCOMM Computer Communication Review.
- Pautasso, M. (2013). "Ten Simple Rules for Writing a Literature Review." PLOS Computational Biology.
- AI Research Assistant: https://github.com/lifan0127/ai-research-assistant
