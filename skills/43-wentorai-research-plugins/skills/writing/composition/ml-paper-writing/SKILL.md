---
name: ml-paper-writing
description: "Write ML/AI research papers targeting NeurIPS, ICML, and ICLR venues"
metadata:
  openclaw:
    emoji: "🧠"
    category: "writing"
    subcategory: "composition"
    keywords: ["machine learning", "NeurIPS", "ICML", "ICLR", "AI paper", "deep learning", "conference paper"]
    source: "https://github.com/karpathy/arxiv-sanity-lite"
---

# ML Paper Writing

## Overview

Publishing at top machine learning venues—NeurIPS, ICML, ICLR, AAAI, and similar conferences—requires not only strong technical contributions but also clear, persuasive writing that follows community conventions. The reviewing process at these venues is highly competitive (acceptance rates of 15-30%), and the difference between a borderline accept and a borderline reject often comes down to how well the paper communicates its contributions.

This skill provides a comprehensive guide to writing ML/AI research papers that meet the expectations of reviewers at top venues. It covers paper structure, the specific writing conventions of the ML community, common reviewer complaints to avoid, and practical templates for each section.

The guidance here is based on published reviewer guidelines from NeurIPS, ICML, and ICLR, as well as widely-cited advice from established researchers in the field.

## Paper Structure and Section Guide

### Title

Your title should be specific and informative. Avoid generic titles like "A Novel Approach to X." Include:
- The key technical contribution or method name
- The problem domain or task
- Optionally, a hint at the result

**Good examples:**
- "Attention Is All You Need"
- "BERT: Pre-training of Deep Bidirectional Transformers for Language Understanding"
- "Scaling Laws for Neural Language Models"

**Avoid:**
- "A Deep Learning Approach for Better Results" (too vague)
- "On Some Properties of Neural Networks" (uninformative)

### Abstract (150-250 words)

Structure your abstract as four implicit paragraphs, even if written as a single block:

1. **Context** (1-2 sentences): What problem area are you working in? Why does it matter?
2. **Gap/Problem** (1-2 sentences): What specific limitation or open question does your work address?
3. **Approach** (2-3 sentences): What is your method? What is the key insight?
4. **Results** (2-3 sentences): What are your main empirical results? Include specific numbers (accuracy, speedup, etc.).

### Introduction (1-1.5 pages)

The introduction expands the abstract with more context and should accomplish:

1. Motivate the problem with a concrete example or real-world impact
2. Summarize the current state of the art and its limitations
3. State your contributions as a numbered or bulleted list (typically 3-4 points)
4. Briefly describe the paper's organization

**The contribution list is critical.** Reviewers often decide their initial impression from the contribution bullets. Each contribution should be specific and falsifiable, not vague ("We propose a novel method" is weak; "We propose X, which achieves Y% improvement on Z benchmark" is strong).

### Related Work (0.5-1.5 pages)

In ML papers, Related Work can appear after the Introduction or before the Conclusion. Position it after the Introduction if your method is best understood in the context of prior work; put it near the end if it would interrupt the flow of your technical exposition.

- Organize by theme, not chronologically
- Explicitly state how your work differs from each group of related methods
- Be fair and generous—reviewers may be the authors of cited papers
- Cover the most recent work (last 2 years); missing recent papers is a common reviewer complaint

### Method (2-3 pages)

This is the core of your paper. Structure it as:

1. **Problem formulation**: Define notation, input/output, and the objective mathematically
2. **Method overview**: A high-level description (ideally with a figure showing the architecture or pipeline)
3. **Detailed description**: Each component of your method in its own subsection
4. **Training procedure**: Loss functions, optimization details, any tricks

**Tips:**
- Use a method figure (architecture diagram) early in this section
- Define all notation before first use
- Use consistent notation throughout (common complaint: variable names change between sections)
- If your method has multiple components, use an algorithm box (Algorithm 1) to summarize

### Experiments (2-3 pages)

This section must answer: "Does the proposed method work, and why?"

Structure:
1. **Experimental setup**: Datasets, baselines, evaluation metrics, implementation details
2. **Main results**: Comparison tables against baselines on standard benchmarks
3. **Ablation study**: Remove or modify each component of your method to show each one matters
4. **Analysis**: Qualitative examples, visualization of learned representations, failure cases

**Common reviewer complaints to preempt:**
- "The baselines are weak/outdated" — Include SOTA methods from the last 1-2 years
- "Missing ablation study" — Always include one
- "No error bars/confidence intervals" — Report mean and standard deviation over 3-5 runs
- "No computational cost comparison" — Report FLOPs, wall-clock time, or parameter counts

### Conclusion

Keep it short (0.5 pages). Summarize contributions, state limitations honestly (reviewers appreciate this), and suggest future directions.

## Writing Style for ML Papers

### Clarity and Precision

- Use active voice: "We propose" not "It is proposed"
- Define acronyms at first use
- Keep sentences short—aim for one idea per sentence
- Use mathematical notation consistently
- Avoid hedge words unless truly uncertain ("Our method achieves" not "Our method seems to achieve")

### Figures and Tables

- Every figure and table must be referenced in the text
- Use vector graphics (PDF/SVG) for plots, not rasterized PNG
- Tables should have clear column headers and the best result should be **bolded**
- Include a descriptive caption that lets the figure/table stand alone

### Reproducibility Checklist

NeurIPS and ICML now require a reproducibility checklist. Address these in your paper:

- Exact hyperparameters and how they were selected
- Random seeds used
- Computational resources (GPU type, training time)
- Dataset splits and preprocessing details
- Code availability (link to anonymized repository for review)

## Submission Logistics

### Formatting

- Use the official LaTeX template for your target venue (NeurIPS, ICML, ICLR each have their own)
- Do not exceed the page limit (typically 8-9 pages for main content, unlimited for references and appendix)
- Anonymous submission: remove author names, avoid self-identifying references ("In our prior work [Author, 2024]" should be "In prior work [Anonymous, 2024]")

### Supplementary Material

Use the appendix for:
- Extended proofs
- Additional experimental results
- Implementation details and pseudocode
- Dataset details and preprocessing steps

Reviewers are not required to read the appendix, so the main paper must be self-contained.

### Rebuttal Preparation

After reviews come in, you typically have 1 week for a rebuttal. Prepare by:
- Running additional experiments that reviewers might request (start before reviews arrive)
- Having a collaborator re-read the paper to anticipate potential criticisms
- Drafting template responses for common concerns (computational cost, additional baselines, etc.)

## References

- NeurIPS 2025 Call for Papers and Reviewer Guidelines: https://neurips.cc
- ICML Author Instructions: https://icml.cc
- ICLR Submission Guidelines: https://iclr.cc
- Karpathy's arXiv Sanity: https://github.com/karpathy/arxiv-sanity-lite
- Liang, P. "How to Write a Good ML Paper" (Stanford CS229 handout)
