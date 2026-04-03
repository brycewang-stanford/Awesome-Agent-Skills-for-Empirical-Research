---
name: crossref-event-data-api
description: "Track scholarly mentions across the web via Crossref Event Data"
metadata:
  openclaw:
    emoji: "📡"
    category: "literature"
    subcategory: "metadata"
    keywords: ["Crossref", "event data", "altmetrics", "social media mentions", "scholarly impact", "web mentions"]
    source: "https://www.eventdata.crossref.org/"
---

# Crossref Event Data API

## Overview

Crossref Event Data tracks where scholarly publications are discussed, shared, and referenced across the open web — Wikipedia citations, Twitter/X mentions, Reddit posts, blog references, policy document citations, and more. Unlike traditional citation counts, Event Data captures real-time online attention to research. Free, no authentication required.

## API Endpoints

### Base URL

```
https://api.eventdata.crossref.org/v1
```

### Query Events

```bash
# Get events for a specific DOI
curl "https://api.eventdata.crossref.org/v1/events?obj-id=10.1038/nature14539&rows=20"

# Filter by source
curl "https://api.eventdata.crossref.org/v1/events?\
obj-id=10.1038/nature14539&source=wikipedia"

# Filter by date range
curl "https://api.eventdata.crossref.org/v1/events?\
from-occurred-date=2024-01-01&until-occurred-date=2024-12-31&source=twitter&rows=100"

# Get events about a DOI prefix (publisher level)
curl "https://api.eventdata.crossref.org/v1/events?obj-id.prefix=10.1371&rows=50"

# Events from a specific source
curl "https://api.eventdata.crossref.org/v1/events?source=reddit&rows=50"
```

### Event Sources

| Source | Description | What it tracks |
|--------|-------------|---------------|
| `wikipedia` | Wikipedia article references | DOIs cited in Wikipedia |
| `twitter` | Twitter/X posts | Tweets linking to DOIs |
| `reddit` | Reddit posts/comments | Reddit links to papers |
| `hypothesis` | Hypothesis annotations | Web annotations on papers |
| `newsfeed` | News articles | Media coverage of research |
| `stackexchange` | Stack Exchange Q&A | Technical discussions |
| `web` | General web pages | Blog posts, reports |
| `wordpressdotcom` | WordPress blogs | Blog references |
| `datacite` | DataCite DOIs | Dataset-paper linkages |
| `crossref` | Crossref metadata | Reference list updates |

### Query Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `obj-id` | DOI of the paper | `obj-id=10.1038/nature14539` |
| `obj-id.prefix` | DOI prefix (publisher) | `obj-id.prefix=10.1371` |
| `source` | Event source | `source=wikipedia` |
| `from-occurred-date` | Events from date | `2024-01-01` |
| `until-occurred-date` | Events until date | `2024-12-31` |
| `rows` | Results per page (max 10000) | `rows=100` |
| `cursor` | Pagination cursor | Returned in response |

## Response Structure

```json
{
  "status": "ok",
  "message-type": "event-list",
  "message": {
    "total-results": 245,
    "events": [
      {
        "obj_id": "https://doi.org/10.1038/nature14539",
        "source_id": "wikipedia",
        "subj_id": "https://en.wikipedia.org/wiki/Deep_learning",
        "relation_type_id": "references",
        "occurred_at": "2024-03-15T10:30:00Z",
        "subj": {
          "title": "Deep learning - Wikipedia",
          "url": "https://en.wikipedia.org/wiki/Deep_learning"
        }
      }
    ],
    "next-cursor": "abc123..."
  }
}
```

## Python Usage

```python
import requests
from collections import Counter

BASE_URL = "https://api.eventdata.crossref.org/v1"


def get_events(doi: str, source: str = None,
               rows: int = 100) -> list:
    """Get Event Data events for a DOI."""
    params = {"obj-id": doi, "rows": rows}
    if source:
        params["source"] = source

    resp = requests.get(f"{BASE_URL}/events", params=params)
    resp.raise_for_status()
    data = resp.json()

    events = []
    for ev in data.get("message", {}).get("events", []):
        events.append({
            "source": ev.get("source_id"),
            "subject_url": ev.get("subj_id"),
            "subject_title": ev.get("subj", {}).get("title", ""),
            "relation": ev.get("relation_type_id"),
            "date": ev.get("occurred_at", "")[:10],
        })
    return events


def get_attention_summary(doi: str) -> dict:
    """Summarize online attention for a paper."""
    events = get_events(doi, rows=10000)
    source_counts = Counter(e["source"] for e in events)
    return {
        "total_events": len(events),
        "by_source": dict(source_counts),
        "first_event": min((e["date"] for e in events), default=None),
        "latest_event": max((e["date"] for e in events), default=None),
    }


def find_wikipedia_citations(doi: str) -> list:
    """Find Wikipedia articles that cite a paper."""
    events = get_events(doi, source="wikipedia")
    return [
        {"wikipedia_page": e["subject_title"],
         "url": e["subject_url"],
         "date": e["date"]}
        for e in events
        if e["relation"] == "references"
    ]


# Example: analyze online attention for a paper
doi = "10.1038/nature14539"
summary = get_attention_summary(doi)
print(f"Total events: {summary['total_events']}")
for source, count in sorted(summary["by_source"].items(),
                             key=lambda x: -x[1]):
    print(f"  {source}: {count}")

# Example: find Wikipedia coverage
wiki_refs = find_wikipedia_citations(doi)
for ref in wiki_refs:
    print(f"Cited in: {ref['wikipedia_page']} ({ref['date']})")
```

## Use Cases

1. **Altmetrics research**: Measure non-traditional scholarly impact
2. **Public engagement**: Track how research reaches public audiences
3. **Policy monitoring**: Discover when research informs policy documents
4. **Social media analytics**: Track paper sharing on Twitter, Reddit
5. **Wikipedia coverage**: Find which papers are cited in encyclopedias

## References

- [Crossref Event Data](https://www.eventdata.crossref.org/)
- [Event Data API Guide](https://www.eventdata.crossref.org/guide/)
- [Event Data User Guide](https://www.crossref.org/services/event-data/)
