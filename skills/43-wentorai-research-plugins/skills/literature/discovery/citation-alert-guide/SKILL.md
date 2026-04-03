---
name: citation-alert-guide
description: "Set up citation alerts and track new papers citing key references"
metadata:
  openclaw:
    emoji: "🔔"
    category: "literature"
    subcategory: "discovery"
    keywords: ["citation alerts", "paper tracking", "Google Scholar alerts", "new citations", "literature monitoring"]
    source: "wentor-research-plugins"
---

# Citation Alert Guide

A skill for setting up automated citation alerts and tracking systems that notify you when key papers are cited, new articles match your research interests, or important journals publish relevant work.

## Alert Types and Platforms

### Overview of Alert Systems

| Platform | Alert Type | Coverage | Cost |
|----------|-----------|----------|------|
| Google Scholar | Citation alert, keyword alert | Broadest, includes preprints | Free |
| Web of Science | Citation alert, search alert, journal ToC | WoS-indexed journals | Institutional |
| Scopus | Citation alert, search alert, author alert | Scopus-indexed journals | Institutional |
| PubMed | Email alert (My NCBI) | Biomedical literature | Free |
| OpenAlex | Work tracking, author profiles, concept feeds | All disciplines | Free |
| ResearchGate | Author follow, recommendation | Member-uploaded papers | Free |

### Setting Up Google Scholar Alerts

```
Citation Alert (track who cites a specific paper):
  1. Search for the paper in Google Scholar
  2. Click "Cited by N" under the result
  3. Click the envelope icon ("Create alert")
  4. Enter your email address
  5. You will receive an email when new papers cite this work

Keyword Alert (track new papers matching a query):
  1. Go to scholar.google.com/scholar_alerts
  2. Click "Create alert"
  3. Enter your search query (use quotes for phrases)
  4. Enter your email address
  5. Choose frequency: as-it-happens or weekly digest
```

## Building a Monitoring System

### Structured Alerting Strategy

```python
def design_alert_system(research_topics: list[str],
                        key_papers: list[str],
                        key_authors: list[str]) -> dict:
    """
    Design a comprehensive literature monitoring system.

    Args:
        research_topics: Core research interest phrases
        key_papers: DOIs or titles of seminal papers to track
        key_authors: Names of researchers to follow
    """
    system = {
        "citation_alerts": {
            "platform": "Google Scholar + Web of Science",
            "items": [
                {"paper": p, "reason": "Seminal work in my area"}
                for p in key_papers
            ],
            "frequency": "as-it-happens"
        },
        "keyword_alerts": {
            "platform": "Google Scholar + PubMed",
            "queries": research_topics,
            "frequency": "weekly"
        },
        "author_alerts": {
            "platform": "OpenAlex + Scopus",
            "authors": key_authors,
            "frequency": "monthly"
        },
        "journal_toc_alerts": {
            "platform": "Web of Science or journal website",
            "note": "Subscribe to table-of-contents for top 3-5 journals"
        }
    }
    return system
```

### Recommended Workflow

```
Daily (5 minutes):
  - Skim citation alert emails
  - Star/flag relevant hits in your reference manager

Weekly (30 minutes):
  - Review keyword alert digests
  - Scan journal ToC for top 3 journals
  - Add promising papers to "To Read" folder

Monthly (1 hour):
  - Review author alerts for new publications from key groups
  - Update keyword queries if your focus has shifted
  - Prune alerts that are no longer relevant
```

## Managing Alert Overload

### Filtering and Prioritization

When alerts generate too many results, refine your strategy:

```
1. Narrow keyword queries:
   Before: "machine learning"
   After:  "machine learning" AND "protein folding"

2. Use field restrictions:
   PubMed: "deep learning"[Title] AND "radiology"[MeSH]

3. Limit to high-impact sources:
   Web of Science: Set alert with journal filter

4. Consolidate with an RSS reader:
   - Export alerts to RSS where supported
   - Use Feedly, Inoreader, or Zotero's feed reader
   - Group feeds by topic for efficient scanning
```

### Using Reference Managers for Tracking

Most reference managers support alert integration:

- **Zotero**: Add RSS feeds to your library; use the "Feeds" feature to pull in new items automatically
- **Paperpile**: Built-in recommendation engine suggests related papers
- **Mendeley**: "Suggest" feature recommends papers based on your library

## PubMed My NCBI Alerts

### Saved Search Alerts

```
1. Run your search in PubMed
2. Click "Save" below the search bar
3. Sign in to My NCBI (free account)
4. Name your search
5. Set schedule: daily, weekly, or monthly
6. Set format: summary, abstract, or full
7. PubMed emails you new results matching your saved search
```

This is particularly valuable for systematic review updates, where you need to re-run the exact same search periodically to capture newly published studies.
