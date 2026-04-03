---
name: plagiarism-detection-guide
description: "Use plagiarism detection tools and ensure manuscript originality"
metadata:
  openclaw:
    emoji: "🛡️"
    category: "writing"
    subcategory: "polish"
    keywords: ["plagiarism detection", "originality check", "Turnitin", "iThenticate", "self-plagiarism", "text similarity"]
    source: "wentor-research-plugins"
---

# Plagiarism Detection Guide

A skill for using plagiarism detection tools to ensure manuscript originality before submission. Covers major detection platforms, understanding similarity reports, avoiding self-plagiarism, paraphrasing best practices, and institutional policies.

## Detection Tools Overview

### Platform Comparison

| Tool | Primary Users | Database | Cost |
|------|-------------|----------|------|
| iThenticate | Researchers, publishers | Crossref, web, dissertations | Subscription |
| Turnitin | Universities (student work) | Student papers, web, journals | Institutional |
| Copyscape | Web content | Web pages | Per-search or subscription |
| Quetext | General | Web, academic | Free tier / Premium |
| PlagScan | Academic, corporate | Web, internal database | Per-document |
| Grammarly Premium | Writers | Web, ProQuest | Included in Premium |

### What Detection Tools Check

```
Text matching (NOT idea matching):
  - Tools compare your text against databases of published content
  - They flag verbatim matches and close paraphrases
  - They do NOT detect idea plagiarism or conceptual theft
  - They do NOT understand context (quoted text may be flagged)

Common databases searched:
  - Published journal articles (via Crossref, Scopus partnerships)
  - Web pages and online content
  - Previously submitted student papers (Turnitin only)
  - Books and dissertations (varies by tool)
  - Preprint servers (arXiv, SSRN)
```

## Understanding Similarity Reports

### Reading the Report

```python
def interpret_similarity_score(total_score: float,
                                source_breakdown: list[dict]) -> dict:
    """
    Interpret a plagiarism detection similarity report.

    Args:
        total_score: Overall similarity percentage
        source_breakdown: List of dicts with 'source', 'percentage', 'type'
    """
    interpretation = {
        "total_similarity": total_score,
        "risk_level": (
            "low" if total_score < 15
            else "moderate" if total_score < 30
            else "high"
        ),
        "guidance": {
            "low": (
                "Under 15% is typical for original research papers. "
                "Review flagged sections to confirm they are properly quoted "
                "or are common phrases."
            ),
            "moderate": (
                "15-30% warrants review. Check if matches are from your own "
                "prior work (self-citation), methods sections using standard "
                "language, or properly attributed quotations."
            ),
            "high": (
                "Over 30% requires careful review. Large blocks of matched "
                "text must be rewritten, quoted, or properly attributed. "
                "Note: review articles and meta-analyses may legitimately "
                "have higher similarity scores."
            )
        }
    }

    # Categorize sources
    for src in source_breakdown:
        src["action"] = (
            "Verify proper citation" if src["type"] == "journal_article"
            else "Check if self-plagiarism" if src["type"] == "own_prior_work"
            else "Rewrite or quote with attribution"
        )

    interpretation["sources"] = source_breakdown
    return interpretation
```

### Acceptable vs. Problematic Matches

```
Typically acceptable:
  - Reference list entries
  - Standard methodology descriptions ("Informed consent was obtained...")
  - Widely used definitions or established terminology
  - Properly quoted and attributed passages
  - Author name and affiliation blocks
  - Common phrases ("on the other hand", "in this study")

Potentially problematic:
  - Paragraphs copied from other papers without quotation or citation
  - Closely paraphrased passages without citation
  - Reuse of your own prior text without disclosure (self-plagiarism)
  - Translated text from another language without attribution
  - Figures, tables, or data descriptions from other sources
```

## Avoiding Self-Plagiarism

### What Counts as Self-Plagiarism

```
Self-plagiarism occurs when you reuse substantial portions of your
own previously published text without disclosure. This is an issue
because publishers hold copyright on your published work.

Problematic:
  - Copying methods paragraphs from your prior paper verbatim
  - Reusing introduction or discussion text across papers
  - "Salami slicing" -- publishing the same data in multiple papers

Acceptable:
  - Building on your own prior findings (with proper citation)
  - Reusing brief, standard methodological phrases
  - Reproducing your own figures with permission and citation
  - Theses/dissertations reused in subsequent journal articles
    (check journal policy -- most allow this)
```

## Paraphrasing Best Practices

### Effective Rewriting Strategy

```
Step 1: Read the source passage carefully
Step 2: Close the source -- do not look at it
Step 3: Write the idea in your own words from memory
Step 4: Compare with the original for accuracy
Step 5: Add the citation

Test: If you can cover the original and still write the passage,
you have genuinely paraphrased. If you need to keep looking back
and changing individual words, you are patch-writing (still plagiarism).
```

### Common Paraphrasing Errors

| Error | Example | Fix |
|-------|---------|-----|
| Word swapping | "Important" becomes "significant" with same structure | Restructure the entire sentence |
| Patchwriting | Changing a few words but keeping sentence structure | Write from understanding, not from text |
| Missing citation | Good paraphrase but no in-text citation | Always cite the source of the idea |

## Pre-Submission Checklist

Before submitting your manuscript, verify: all direct quotes are in quotation marks with page numbers, all paraphrased ideas have in-text citations, methods text is rewritten rather than copied from prior papers, any reuse of your own prior text is disclosed to the editor, and your similarity report shows no large unattributed matches. Run the detection tool on your final manuscript version, not an earlier draft, to ensure all revisions are captured.
