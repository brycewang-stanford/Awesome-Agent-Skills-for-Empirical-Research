---
name: journal-metrics-guide
description: "Understand journal impact factors, h5-index, CiteScore, and SJR"
metadata:
  openclaw:
    emoji: "📊"
    category: "literature"
    subcategory: "metadata"
    keywords: ["impact factor", "journal metrics", "h5-index", "CiteScore", "SJR", "journal ranking"]
    source: "wentor-research-plugins"
---

# Journal Metrics Guide

A skill for understanding, comparing, and responsibly using journal-level metrics including Impact Factor, CiteScore, SJR, SNIP, h5-index, and Eigenfactor. Covers where to find each metric, how they are calculated, their limitations, and how to select appropriate journals for submission.

## Overview of Major Metrics

### Metric Comparison

| Metric | Provider | Formula Basis | Window | Free? |
|--------|----------|--------------|--------|-------|
| Impact Factor (JIF) | Clarivate (JCR) | Citations to articles / citable items | 2 years | No |
| 5-Year IF | Clarivate (JCR) | Same, extended window | 5 years | No |
| CiteScore | Scopus/Elsevier | Citations / documents | 4 years | Yes |
| SJR | Scopus/SCImago | Prestige-weighted citations | 3 years | Yes |
| SNIP | Scopus/CWTS | Citation potential normalized | 3 years | Yes |
| h5-index | Google Scholar | h-index of articles published in last 5 years | 5 years | Yes |
| Eigenfactor | Clarivate | Network citation influence | 5 years | Yes |

## How Key Metrics Are Calculated

### Journal Impact Factor

```
JIF (2024) = Citations in 2024 to articles published in 2022-2023
             -------------------------------------------------------
             Number of citable items published in 2022-2023

Example:
  Journal published 200 articles in 2022-2023
  Those articles received 1,000 citations in 2024
  JIF = 1000 / 200 = 5.0
```

### CiteScore

```
CiteScore (2024) = Citations in 2021-2024 to items published in 2021-2024
                   -----------------------------------------------------------
                   Documents published in 2021-2024

Key difference from JIF:
  - 4-year window (vs. 2 years)
  - Includes ALL document types in denominator (not just "citable items")
  - More transparent calculation
  - Freely available at scopus.com/sources
```

### SJR (SCImago Journal Rank)

```python
def explain_sjr() -> dict:
    """
    Explain the SCImago Journal Rank metric.
    """
    return {
        "concept": (
            "SJR weights citations by the prestige of the citing journal. "
            "A citation from Nature counts more than a citation from a "
            "low-prestige journal."
        ),
        "algorithm": "Based on Google PageRank applied to citation network",
        "range": "Typically 0.1 to 20+; most journals 0.2-2.0",
        "lookup": "scimagojr.com - free access",
        "quartiles": {
            "Q1": "Top 25% of journals in the subject category",
            "Q2": "25th-50th percentile",
            "Q3": "50th-75th percentile",
            "Q4": "Bottom 25%"
        }
    }
```

## Finding Journal Metrics

### Free Sources

```
Google Scholar Metrics:
  scholar.google.com/citations?view_op=top_venues
  - h5-index and h5-median for thousands of venues
  - Filtered by broad discipline or specific subcategory
  - Updated annually

SCImago Journal Rank:
  scimagojr.com
  - SJR, h-index, total documents, total citations
  - Country and subject area filtering
  - Free journal comparison tool

Scopus Sources:
  scopus.com/sources
  - CiteScore, SJR, SNIP for all Scopus-indexed journals
  - CiteScore Tracker (real-time estimate)
  - Free with Scopus account
```

### Subscription Sources

```
Journal Citation Reports (JCR):
  Clarivate Analytics (institutional subscription)
  - Impact Factor, 5-Year IF, Eigenfactor
  - Journal quartile rankings by category
  - Cited/citing journal networks

InCites:
  Clarivate Analytics
  - Normalized citation impact at journal and article level
  - Benchmarking tools
```

## Responsible Use of Metrics

### Limitations and Pitfalls

```
1. Field dependence:
   - Life sciences JIF >> Computer science JIF
   - Never compare JIF across disciplines

2. Skewed distributions:
   - A few highly cited papers inflate the average
   - Median citations per article is more representative

3. Gaming and manipulation:
   - Excessive self-citation
   - Citation cartels between journals
   - Review articles inflating citation counts

4. Not a measure of individual paper quality:
   - A paper in a high-IF journal may receive zero citations
   - A paper in a modest journal may become highly influential

5. DORA declaration:
   - Over 2,500 organizations signed the San Francisco
     Declaration on Research Assessment (DORA)
   - Recommends against using JIF as a proxy for
     individual article quality in hiring, promotion,
     or funding decisions
```

### Choosing a Journal for Submission

```python
def evaluate_journal_fit(metrics: dict, paper_profile: dict) -> dict:
    """
    Evaluate journal suitability beyond just impact factor.

    Args:
        metrics: Journal metrics (JIF, CiteScore, acceptance rate, etc.)
        paper_profile: Characteristics of your manuscript
    """
    criteria = {
        "scope_match": "Does the journal publish papers on this topic?",
        "audience": "Will the right readers see this paper here?",
        "turnaround": "What is the average time from submission to decision?",
        "open_access": "Does the journal offer OA options? What are the APCs?",
        "acceptance_rate": "Is the acceptance rate realistic for this paper?",
        "indexing": "Is the journal indexed in Scopus, WoS, PubMed?",
        "prestige": "How is this journal perceived in your specific subfield?",
        "ethics": "Is the journal a member of COPE? Does it follow best practices?"
    }

    return {
        "recommendation": "Consider all factors, not just metrics",
        "criteria": criteria,
        "warning": (
            "Avoid predatory journals. Check Beall's list and "
            "verify the journal is indexed in recognized databases."
        )
    }
```

## Predatory Journal Detection

Watch for these warning signs: unsolicited email invitations to submit, very rapid peer review (days), lack of indexing in Scopus or Web of Science, vague editorial board, no clear ISSN, and APCs that seem unusually low. Use resources like "Think. Check. Submit." (thinkchecksubmit.org) to verify journal legitimacy.
