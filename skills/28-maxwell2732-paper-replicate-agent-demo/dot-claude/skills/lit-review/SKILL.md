---
name: lit-review
description: Structured literature search and synthesis with citation extraction and gap identification
disable-model-invocation: true
argument-hint: "[topic, paper title, or research question]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "WebSearch", "WebFetch"]
---

# Literature Review

Conduct a structured literature search and synthesis on the given topic.

**Input:** `$ARGUMENTS` — a topic, paper title, research question, or phenomenon to investigate.

---

## Steps

1. **Parse the topic** from `$ARGUMENTS`. If a specific paper is named, use it as the anchor.

2. **Search for related work** using available tools:
   - Check `master_supporting_docs/supporting_papers/` for uploaded papers
   - Use `WebSearch` to find recent publications (if available)
   - Use `WebFetch` to access working paper repositories (if available)
   - Read any existing `.bib` file for papers already in the project

3. **Organize findings** into these categories:
   - **Theoretical contributions** — models, frameworks, mechanisms
   - **Empirical findings** — key results, effect sizes, data sources
   - **Methodological innovations** — new estimators, identification strategies, inference methods
   - **Open debates** — unresolved disagreements in the literature

4. **Identify gaps and opportunities:**
   - What questions remain unanswered?
   - What data or methods could address them?
   - Where do findings conflict?

5. **Extract citations** in BibTeX format for all papers discussed.

6. **Save the report** to `quality_reports/lit_review_[sanitized_topic].md`

---

## Output Format

```markdown
# Literature Review: [Topic]

**Date:** [YYYY-MM-DD]
**Query:** [Original query from user]

## Summary

[2-3 paragraph overview of the state of the literature]

## Key Papers

### [Author (Year)] — [Short Title]
- **Main contribution:** [1-2 sentences]
- **Method:** [Identification strategy / data]
- **Key finding:** [Result with effect size if available]
- **Relevance:** [Why it matters for our research]

[Repeat for 5-15 papers, ordered by relevance]

## Thematic Organization

### Theoretical Contributions
[Grouped discussion]

### Empirical Findings
[Grouped discussion with comparison across studies]

### Methodological Innovations
[Methods relevant to the topic]

## Gaps and Opportunities

1. [Gap 1 — what's missing and why it matters]
2. [Gap 2]
3. [Gap 3]

## Suggested Next Steps

- [Concrete actions: papers to read, data to obtain, methods to consider]

## BibTeX Entries

```bibtex
@article{...}
```
```

---

## Important

- **Be honest about uncertainty.** If you cannot verify a citation, say so.
- **Prioritize recent work** (last 5-10 years) unless seminal papers are older.
- **Note working papers vs published papers** — working papers may change.
- **Do NOT fabricate citations.** If you're unsure about a paper's details, flag it for the user to verify.
