---
name: altmetrics-guide
description: "Guide to altmetrics and research impact beyond traditional citations"
metadata:
  openclaw:
    emoji: "📊"
    category: "literature"
    subcategory: "metadata"
    keywords: ["altmetrics", "attention score", "social impact", "online mentions", "academic metrics"]
    source: "wentor-research-plugins"
---

# Altmetrics Guide

Understand and use alternative metrics (altmetrics) to measure the broader impact and reach of research outputs beyond traditional citation counts.

## What Are Altmetrics?

Altmetrics capture the online attention and engagement that research receives across diverse platforms. Unlike citation-based metrics (which can take years to accumulate), altmetrics provide near-real-time signals of how research is being discussed, shared, and used.

| Source Category | Examples | What It Measures |
|----------------|----------|------------------|
| Social media | Twitter/X, Facebook, Reddit, Weibo | Public discussion and sharing |
| News & blogs | Mainstream media, science blogs | Media coverage and science communication |
| Policy documents | Government reports, clinical guidelines | Policy relevance |
| Reference managers | Mendeley, Zotero readership | Academic readership and interest |
| Wikipedia | Article citations | Educational and encyclopedic use |
| Peer review | Publons, post-publication review | Formal and informal peer evaluation |
| Patents | Patent citations | Commercial and industrial relevance |

## Key Altmetric Providers and Scores

### Altmetric.com Attention Score

The Altmetric Attention Score is a weighted composite of online mentions:

| Source | Weight | Rationale |
|--------|--------|-----------|
| News outlets | 8 | Editorial curation, wide audience |
| Blog posts | 5 | Expert commentary |
| Wikipedia | 3 | Encyclopedic significance |
| Policy documents | 3 | Real-world impact |
| Twitter/X posts | 1 | Broad sharing but low barrier |
| Facebook posts | 0.25 | General public engagement |
| Reddit posts | 0.25 | Community discussion |
| Mendeley readers | 0 (separate) | Tracked but not in score |

### PlumX Metrics (Elsevier)

PlumX organizes metrics into five categories:

1. **Usage**: Downloads, views, library holdings
2. **Captures**: Bookmarks, readers, watchers
3. **Mentions**: Blog posts, news articles, reviews, Wikipedia
4. **Social Media**: Tweets, Facebook likes, Reddit activity
5. **Citations**: Scopus, CrossRef, patent citations

### Dimensions Badge

Dimensions provides citation counts alongside altmetric-style attention data, integrating grants, patents, clinical trials, and policy documents.

## Querying the Altmetric.com API

```python
import requests

# Look up altmetrics by DOI
doi = "10.1038/s41586-021-03819-2"
response = requests.get(f"https://api.altmetric.com/v1/doi/{doi}")

if response.status_code == 200:
    data = response.json()
    print(f"Title: {data.get('title')}")
    print(f"Altmetric Score: {data.get('score')}")
    print(f"Twitter mentions: {data.get('cited_by_tweeters_count', 0)}")
    print(f"News mentions: {data.get('cited_by_msm_count', 0)}")
    print(f"Blog mentions: {data.get('cited_by_feeds_count', 0)}")
    print(f"Wikipedia mentions: {data.get('cited_by_wikipedia_count', 0)}")
    print(f"Mendeley readers: {data.get('readers', {}).get('mendeley', 0)}")
    print(f"Detail URL: {data.get('details_url')}")
else:
    print("No altmetric data found for this DOI")
```

### Batch Queries

```python
# Query multiple DOIs using the Altmetric Explorer API (requires subscription)
# Free API supports individual lookups by DOI, PubMed ID, or arXiv ID

# Look up by PubMed ID
pmid = "34234348"
response = requests.get(f"https://api.altmetric.com/v1/pmid/{pmid}")

# Look up by arXiv ID
arxiv_id = "2103.14030"
response = requests.get(f"https://api.altmetric.com/v1/arxiv/{arxiv_id}")
```

## Interpreting Altmetrics Responsibly

### What Altmetrics Tell You

- **Speed of dissemination**: How quickly research is being noticed
- **Audience breadth**: Whether attention comes from academics, media, public, or policymakers
- **Geographic reach**: Where in the world the work is being discussed
- **Interdisciplinary interest**: Engagement from unexpected fields

### What Altmetrics Do NOT Tell You

- **Quality**: High attention does not equal high quality (controversial or flawed papers can go viral)
- **Field-normalized comparison**: Raw scores are not comparable across disciplines
- **Gaming resistance**: Social media metrics can be artificially inflated
- **Comprehensive coverage**: Not all platforms and languages are tracked equally

## Best Practices for Using Altmetrics

1. **Combine with traditional metrics**: Use altmetrics alongside citation counts, h-index, and peer review to build a complete picture of impact.
2. **Context matters**: A score of 50 might be exceptional in pure mathematics but ordinary in public health. Check the "Compared to outputs of the same age" percentile.
3. **Report responsibly**: When including altmetrics in CVs or grant applications, explain what the numbers mean (e.g., "Top 5% of all research outputs tracked by Altmetric.com").
4. **Track over time**: Set up alerts for your publications to monitor engagement trends.
5. **Explore the sources**: Click through to see who is discussing your work and in what context. A single policy document mention may be more meaningful than 100 tweets.

## Tools for Tracking Your Research Impact

| Tool | Cost | Features |
|------|------|----------|
| Altmetric.com Bookmarklet | Free | One-click altmetrics for any paper |
| ImpactStory / OurResearch | Free | ORCID-based open access and impact profiles |
| Google Scholar Profile | Free | Citation tracking, h-index, i10-index |
| PlumX Dashboard | Institutional | Comprehensive multi-source tracking |
| Dimensions | Free tier | Citations + grants + patents + clinical trials |
