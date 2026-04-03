---
name: lit-review
description: Structured literature search and synthesis with citation extraction and gap identification.
disable-model-invocation: true
argument-hint: "[topic, paper title, or research question]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "WebSearch", "WebFetch"]
---

## Literature Review

Conduct a structured literature search and synthesis on the given topic.

### Steps

1. **Check existing materials**:
   - Read `master_supporting_docs/supporting_papers/` for uploaded papers
   - Read existing `.bib` files for already-cited works
   - Check CLAUDE.md and MEMORY.md for project context

2. **Search for literature**:
   - Use `WebSearch` for recent publications (last 5-10 years prioritized)
   - Use `WebFetch` for accessible papers and abstracts
   - Search for working papers on NBER, SSRN, RePEc

3. **Organize findings** into:
   - **Theoretical contributions:** Key models and frameworks
   - **Empirical findings:** Main results and methods used
   - **Methodological innovations:** New techniques relevant to the topic
   - **Open debates:** Unresolved questions and conflicting evidence

4. **Identify gaps and opportunities**: What questions remain unanswered? Where could new work contribute?

5. **Extract citations** in BibTeX format for relevant papers.

6. **Save report** to `quality_reports/lit_review_[sanitized_topic].md`.

### Important
- Distinguish working papers from published papers.
- **Explicitly flag any citation you cannot verify** rather than fabricating details.
- Prioritize papers from top journals in the field.
- Note the identification strategy used in each empirical paper.
