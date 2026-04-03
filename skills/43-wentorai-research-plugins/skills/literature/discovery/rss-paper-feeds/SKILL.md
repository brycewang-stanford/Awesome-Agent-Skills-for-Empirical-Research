---
name: rss-paper-feeds
description: "Set up RSS feeds and alerts to track new publications in your research area"
metadata:
  openclaw:
    emoji: "🔔"
    category: "literature"
    subcategory: "discovery"
    keywords: ["RSS feed", "new publication tracking", "literature alert", "citation notification", "research monitoring"]
    source: "wentor"
---

# RSS Paper Feeds

A skill for configuring automated literature monitoring using RSS feeds, email alerts, and citation notifications. Stay current with new publications in your research area without manual searching.

## RSS Feed Sources for Academic Papers

### Journal-Level Feeds

Most major publishers provide RSS feeds for their journals:

| Publisher | Feed URL Pattern | Example |
|-----------|-----------------|---------|
| Nature | `https://www.nature.com/[journal].rss` | `nature.com/nature.rss` |
| Science | `https://www.science.org/action/showFeed?type=etoc&feed=rss&jc=[code]` | jc=science |
| Elsevier | `https://rss.sciencedirect.com/publication/science/[ISSN]` | ISSN 0004-3702 for AI |
| Springer | `https://link.springer.com/search.rss?search-within=Journal&facet-journal-id=[id]` | id=10994 |
| IEEE | `https://ieeexplore.ieee.org/rss/TOC[journal_number].XML` | |
| arXiv | `https://rss.arxiv.org/rss/[category]` | cs.AI, stat.ML |

### Setting Up arXiv Feeds

```python
import feedparser
from datetime import datetime

def fetch_arxiv_feed(categories: list[str], max_results: int = 50) -> list[dict]:
    """
    Fetch recent papers from arXiv RSS feeds.

    Args:
        categories: List of arXiv categories (e.g., ['cs.AI', 'cs.CL', 'stat.ML'])
        max_results: Maximum number of papers to return
    """
    all_papers = []

    for category in categories:
        feed_url = f"https://rss.arxiv.org/rss/{category}"
        feed = feedparser.parse(feed_url)

        for entry in feed.entries[:max_results]:
            all_papers.append({
                'title': entry.title.strip(),
                'authors': entry.get('author', 'Unknown'),
                'abstract': entry.get('summary', '')[:500],
                'link': entry.link,
                'category': category,
                'published': entry.get('published', ''),
                'arxiv_id': entry.link.split('/')[-1] if entry.link else ''
            })

    # Deduplicate (papers may appear in multiple categories)
    seen = set()
    unique = []
    for p in all_papers:
        if p['arxiv_id'] not in seen:
            seen.add(p['arxiv_id'])
            unique.append(p)

    return unique[:max_results]

# Example: monitor AI and NLP papers
papers = fetch_arxiv_feed(['cs.AI', 'cs.CL', 'cs.LG'], max_results=30)
for p in papers[:5]:
    print(f"[{p['category']}] {p['title']}")
    print(f"  {p['link']}\n")
```

## Citation Alerts

### Google Scholar Citations Alert

```
Setup:
1. Search for your key reference papers on Google Scholar
2. Click the "Cited by N" link under each paper
3. Click the envelope icon ("Create alert") at the top of results
4. Enter your email address
5. You will receive notifications when new papers cite that work

Recommended: Set alerts for:
- Your own publications (track who cites you)
- 5-10 foundational papers in your field
- Key competitor or collaborator publications
```

### OpenAlex Citation Tracking

```python
import requests

def track_citations_openalex(work_id: str) -> dict:
    """
    Monitor citations for a specific paper via OpenAlex.

    Args:
        work_id: OpenAlex work ID (e.g., 'W2741809807') or DOI
    """
    headers = {"User-Agent": "ResearchPlugins/1.0 (https://wentor.ai)"}
    response = requests.get(
        f"https://api.openalex.org/works/{work_id}",
        headers=headers
    )
    data = response.json()

    # Get recent citing works
    citing_resp = requests.get(
        "https://api.openalex.org/works",
        params={"filter": f"cites:{work_id}", "sort": "publication_date:desc", "per_page": 10},
        headers=headers
    )
    citing = citing_resp.json().get("results", [])

    return {
        'paper': data.get('title', ''),
        'current_citations': data.get('cited_by_count', 0),
        'recent_citing_works': [
            {'title': c.get('title'), 'year': c.get('publication_year')}
            for c in citing
        ],
        'status': 'configured'
    }
```

## RSS Reader Configuration

### Recommended RSS Readers for Researchers

| Reader | Platform | Features | Cost |
|--------|----------|----------|------|
| Feedly | Web/mobile | AI summaries, boards, teams | Free tier + Pro $8/mo |
| Inoreader | Web/mobile | Rules, filters, monitoring | Free tier + Pro $5/mo |
| Zotero RSS | Desktop | Integrated with reference manager | Free |
| Thunderbird | Desktop | Email + RSS in one client | Free |
| Miniflux | Self-hosted | Minimal, fast, API | Free (self-hosted) |

### Organizing Feeds Effectively

```yaml
feed_organization:
  folders:
    core_journals:
      description: "Top journals in my primary field"
      feeds: 5-8
      check_frequency: "daily"

    broad_monitoring:
      description: "Adjacent fields and high-impact general journals"
      feeds: 10-15
      check_frequency: "weekly"

    preprints:
      description: "arXiv categories and SSRN feeds"
      feeds: 3-5
      check_frequency: "daily"

    citation_alerts:
      description: "New citations of key papers"
      feeds: 10-20
      check_frequency: "weekly"

  workflow:
    daily: "Scan titles in core_journals and preprints (10 min)"
    weekly: "Review broad_monitoring and citation_alerts (30 min)"
    monthly: "Audit feed list, remove low-value feeds, add new ones"
```

## Automated Filtering and Summarization

### Keyword-Based Paper Filtering

```python
def filter_papers(papers: list[dict], keywords: list[str],
                   title_weight: float = 3.0,
                   abstract_weight: float = 1.0,
                   threshold: float = 2.0) -> list[dict]:
    """
    Score and filter papers by relevance to your research keywords.

    Args:
        papers: List of paper dicts with 'title' and 'abstract'
        keywords: Your research keywords
        title_weight: Weight multiplier for title matches
        abstract_weight: Weight multiplier for abstract matches
        threshold: Minimum relevance score to include
    """
    scored = []
    for paper in papers:
        score = 0
        title_lower = paper.get('title', '').lower()
        abstract_lower = paper.get('abstract', '').lower()

        for kw in keywords:
            kw_lower = kw.lower()
            if kw_lower in title_lower:
                score += title_weight
            if kw_lower in abstract_lower:
                score += abstract_weight

        if score >= threshold:
            paper['relevance_score'] = score
            scored.append(paper)

    return sorted(scored, key=lambda x: x['relevance_score'], reverse=True)
```

## Integration with Reference Managers

Configure your RSS reader to send relevant papers directly to your reference manager (Zotero, Mendeley, or EndNote). Most readers support "Save to Zotero" browser extensions or IFTTT/Zapier integrations for automated workflows. This creates a seamless pipeline from discovery to organized storage.
