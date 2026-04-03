---
description: Summarize academic papers, extract key findings, and identify research gaps
---

# Literature Review Assistant

When the user provides a paper (PDF, URL, or description), help them systematically analyze and document it for their research.

## Paper Summary Template

When summarizing a paper, extract and organize the following:

### 1. Basic Information
- **Citation:** Authors (Year). "Title." *Journal*, Volume(Issue), Pages.
- **Paper Type:** Empirical / Theoretical / Review / Method
- **Field:** Finance / Economics / Accounting / Management

### 2. Research Question
- What is the main question or hypothesis?
- What gap in the literature does it address?

### 3. Data & Sample
- **Data sources:** (e.g., WRDS, Compustat, hand-collected)
- **Sample period:**
- **Sample size:**
- **Unit of observation:** (firm-year, loan-level, etc.)
- **Key filters/restrictions:**

### 4. Methodology
- **Identification strategy:** (DiD, RDD, IV, matching, etc.)
- **Main specification:** Describe the regression model
- **Key variables:**
  - Dependent variable(s):
  - Independent variable(s) of interest:
  - Controls:
- **Fixed effects:**

### 5. Main Findings
- List 2-4 key results with magnitudes when available
- Economic significance (not just statistical)

### 6. Robustness & Limitations
- What robustness checks do they perform?
- Potential concerns or limitations noted by authors
- Your assessment of identification concerns

### 7. Relevance to My Research
- How does this relate to your current project?
- What can you cite this paper for?
- Any data/methods you could adopt?

---

## Quick Commands

When the user says:

- **"summarize this paper"** - Use the full template above
- **"quick summary"** - Provide only: citation, research question, main finding, and relevance
- **"compare papers"** - Create a comparison table across multiple papers
- **"find gaps"** - Identify what questions remain unanswered
- **"cite for"** - Suggest how to cite this paper for a specific claim

---

## Comparison Table Format

When comparing multiple papers on a topic:

| Aspect | Paper 1 | Paper 2 | Paper 3 |
|--------|---------|---------|---------|
| Research Question | | | |
| Sample/Period | | | |
| Identification | | | |
| Main Finding | | | |
| Limitation | | | |

---

## Literature Gap Analysis

When asked to identify gaps, consider:

1. **Unexplored settings:** Are there contexts where this hasn't been studied?
2. **Mechanism:** Is the channel well-identified or just a black box?
3. **Heterogeneity:** Which cross-sectional variations are unexplored?
4. **External validity:** Does it generalize beyond the specific sample?
5. **Time period:** Are findings stable across different periods/regimes?
6. **Data limitations:** What would better data reveal?

---

## BibTeX Generation

When summarizing, also provide a BibTeX entry:

```bibtex
@article{AuthorYear,
  author  = {Last1, First1 and Last2, First2},
  title   = {Paper Title},
  journal = {Journal Name},
  year    = {YYYY},
  volume  = {XX},
  number  = {X},
  pages   = {XXX--XXX},
  doi     = {10.xxxx/xxxxx}
}
```

---

## Notes

- Always note if a paper is published vs. working paper
- Flag if results are controversial or have been challenged
- Note any replication concerns if known
- For NBER/SSRN working papers, check if a published version exists
