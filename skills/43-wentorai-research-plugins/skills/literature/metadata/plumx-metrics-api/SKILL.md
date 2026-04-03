---
name: plumx-metrics-api
description: "Track research impact beyond citations via PlumX altmetrics API"
metadata:
  openclaw:
    emoji: "📊"
    category: "literature"
    subcategory: "metadata"
    keywords: ["PlumX", "altmetrics", "research impact", "social media metrics", "usage statistics", "scholarly metrics"]
    source: "https://plumanalytics.com/"
---

# PlumX Metrics API

## Overview

PlumX (by Elsevier/Plum Analytics) tracks 5 categories of research impact metrics beyond traditional citations: Usage, Captures, Mentions, Social Media, and Citations. It covers 130M+ research artifacts including articles, datasets, presentations, and videos. Available via Elsevier's API infrastructure. Requires an Elsevier API key.

## Metric Categories

| Category | What it measures | Examples |
|----------|-----------------|---------|
| **Usage** | Reading/viewing | Abstract views, PDF downloads, HTML views |
| **Captures** | Saving for later | Mendeley readers, CiteULike bookmarks |
| **Mentions** | Commentary | Blog posts, news articles, Wikipedia refs |
| **Social Media** | Sharing/discussion | Tweets, Facebook shares, Reddit posts |
| **Citations** | Formal references | Scopus, CrossRef, PubMed citations |

## API Endpoints

### Base URL

```
https://api.elsevier.com/analytics/plumx/
```

### Get Metrics by DOI

```bash
curl -H "X-ELS-APIKey: $ELSEVIER_API_KEY" \
  "https://api.elsevier.com/analytics/plumx/doi/10.1038/nature14539"
```

### Get Metrics by Other IDs

```bash
# By PubMed ID
curl -H "X-ELS-APIKey: $ELSEVIER_API_KEY" \
  "https://api.elsevier.com/analytics/plumx/pmid/25428114"

# By ISBN
curl -H "X-ELS-APIKey: $ELSEVIER_API_KEY" \
  "https://api.elsevier.com/analytics/plumx/isbn/9780262035613"

# By Scopus ID
curl -H "X-ELS-APIKey: $ELSEVIER_API_KEY" \
  "https://api.elsevier.com/analytics/plumx/scopusId/84920765826"
```

## Response Structure

```json
{
  "count_categories": [
    {
      "name": "capture",
      "total": 15432,
      "count_types": [
        {"name": "READER_COUNT", "total": 15432, "sources": [
          {"name": "Mendeley", "total": 15432}
        ]}
      ]
    },
    {
      "name": "socialMedia",
      "total": 3250,
      "count_types": [
        {"name": "TWEET_COUNT", "total": 2800},
        {"name": "FACEBOOK_COUNT", "total": 450}
      ]
    },
    {
      "name": "citation",
      "total": 2100,
      "count_types": [
        {"name": "Scopus", "total": 1800},
        {"name": "CrossRef", "total": 2100}
      ]
    },
    {
      "name": "usage",
      "total": 45000,
      "count_types": [
        {"name": "ABSTRACT_VIEWS", "total": 30000},
        {"name": "LINK_OUTS", "total": 15000}
      ]
    },
    {
      "name": "mention",
      "total": 85,
      "count_types": [
        {"name": "NEWS_COUNT", "total": 45},
        {"name": "BLOG_COUNT", "total": 25},
        {"name": "WIKIPEDIA_COUNT", "total": 15}
      ]
    }
  ]
}
```

## Python Usage

```python
import os
import requests

API_KEY = os.environ["ELSEVIER_API_KEY"]
BASE_URL = "https://api.elsevier.com/analytics/plumx"
HEADERS = {"X-ELS-APIKey": API_KEY, "Accept": "application/json"}


def get_plumx_metrics(doi: str) -> dict:
    """Get PlumX metrics for a paper by DOI."""
    resp = requests.get(
        f"{BASE_URL}/doi/{doi}",
        headers=HEADERS,
    )
    resp.raise_for_status()
    data = resp.json()

    metrics = {}
    for cat in data.get("count_categories", []):
        category_name = cat["name"]
        metrics[category_name] = {
            "total": cat["total"],
            "breakdown": {},
        }
        for ct in cat.get("count_types", []):
            metrics[category_name]["breakdown"][ct["name"]] = ct["total"]
    return metrics


def compare_impact(dois: list) -> list:
    """Compare PlumX metrics across multiple papers."""
    results = []
    for doi in dois:
        metrics = get_plumx_metrics(doi)
        results.append({
            "doi": doi,
            "citations": metrics.get("citation", {}).get("total", 0),
            "captures": metrics.get("capture", {}).get("total", 0),
            "social": metrics.get("socialMedia", {}).get("total", 0),
            "usage": metrics.get("usage", {}).get("total", 0),
            "mentions": metrics.get("mention", {}).get("total", 0),
        })
    return results


# Example: analyze a paper's multi-dimensional impact
metrics = get_plumx_metrics("10.1038/nature14539")
for category, data in metrics.items():
    print(f"\n{category.upper()} (total: {data['total']})")
    for metric_type, count in data["breakdown"].items():
        print(f"  {metric_type}: {count}")

# Example: compare two papers
# comparison = compare_impact([
#     "10.1038/nature14539",
#     "10.1126/science.aax2342",
# ])
```

## PlumX vs Other Altmetric Services

| Feature | PlumX | Altmetric.com | Crossref Event Data |
|---------|-------|---------------|---------------------|
| Metric categories | 5 comprehensive | Attention Score | Events only |
| Coverage | 130M+ artifacts | 30M+ outputs | DOI-based |
| Social media | Twitter, Facebook, Reddit | Twitter, Reddit, News | Twitter, Reddit, Wikipedia |
| Usage data | Yes (views, downloads) | No | No |
| Capture data | Yes (Mendeley readers) | Mendeley readers | No |
| Free access | Limited | Limited widget | Full API free |

## References

- [PlumX Metrics](https://plumanalytics.com/learn/about-metrics/)
- [Elsevier Developer Portal](https://dev.elsevier.com/)
- [PlumX API Documentation](https://dev.elsevier.com/documentation/PlumXMetricsAPI.wadl)
