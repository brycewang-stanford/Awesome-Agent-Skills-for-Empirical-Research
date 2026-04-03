---
name: open-syllabus-api
description: "Analyze most-taught books and texts via Open Syllabus analytics"
metadata:
  openclaw:
    emoji: "📖"
    category: "domains"
    subcategory: "education"
    keywords: ["Open Syllabus", "syllabi analytics", "teaching data", "textbook rankings", "curriculum analysis", "higher education"]
    source: "https://opensyllabus.org/"
---

# Open Syllabus API

## Overview

Open Syllabus analyzes 20M+ college course syllabi from 7,000+ institutions in 140+ countries, tracking which books, articles, and media are most frequently assigned in higher education. The Explorer provides teaching frequency rankings and co-assignment patterns. Useful for curriculum research, textbook selection, and understanding disciplinary norms. Free for basic search; institutional subscription for full API access.

## Explorer Interface

### Web Search

```bash
# The primary interface is the web explorer:
# https://explorer.opensyllabus.org/

# Search by title, author, or field
# Filter by country, institution, discipline, year range
```

### API Access

```bash
# API requires institutional subscription
# Base URL: https://api.opensyllabus.org/v1/

# Search titles
curl -H "Authorization: Bearer $OS_TOKEN" \
  "https://api.opensyllabus.org/v1/titles?query=republic+plato&limit=20"

# Get title details
curl -H "Authorization: Bearer $OS_TOKEN" \
  "https://api.opensyllabus.org/v1/titles/12345"

# Co-assignment analysis
curl -H "Authorization: Bearer $OS_TOKEN" \
  "https://api.opensyllabus.org/v1/titles/12345/co-assigned?limit=20"

# Rankings by field
curl -H "Authorization: Bearer $OS_TOKEN" \
  "https://api.opensyllabus.org/v1/rankings?field=Economics&limit=50"
```

### Query Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `query` | Search text | `query=machine+learning` |
| `field` | Academic discipline | `field=Computer Science` |
| `country` | Country filter | `country=US` |
| `institution` | Institution filter | `institution=Harvard` |
| `year_from` | Start year | `year_from=2020` |
| `year_to` | End year | `year_to=2026` |
| `limit` | Results per page | `limit=50` |

## Key Metrics

| Metric | Description |
|--------|-------------|
| **Teaching Score** | 0-100 normalized frequency of syllabi appearances |
| **Count** | Raw number of syllabi featuring the title |
| **Rank** | Position in overall or field-specific ranking |
| **Co-assignment** | Titles frequently taught alongside this one |

## Python Usage

```python
import requests

BASE_URL = "https://api.opensyllabus.org/v1"


def search_titles(query: str, field: str = None,
                  country: str = None,
                  limit: int = 20, token: str = "") -> list:
    """Search Open Syllabus for assigned titles."""
    headers = {"Authorization": f"Bearer {token}"} if token else {}
    params = {"query": query, "limit": limit}
    if field:
        params["field"] = field
    if country:
        params["country"] = country

    resp = requests.get(
        f"{BASE_URL}/titles",
        headers=headers,
        params=params,
    )
    resp.raise_for_status()
    data = resp.json()

    results = []
    for item in data.get("results", []):
        results.append({
            "title": item.get("title"),
            "authors": item.get("authors"),
            "teaching_score": item.get("teaching_score"),
            "count": item.get("appearance_count"),
            "rank": item.get("rank"),
            "top_fields": item.get("top_fields", []),
        })
    return results


def get_co_assigned(title_id: int, limit: int = 20,
                    token: str = "") -> list:
    """Get titles frequently co-assigned with a given title."""
    headers = {"Authorization": f"Bearer {token}"} if token else {}
    resp = requests.get(
        f"{BASE_URL}/titles/{title_id}/co-assigned",
        headers=headers,
        params={"limit": limit},
    )
    resp.raise_for_status()
    return resp.json().get("results", [])


def get_field_rankings(field: str, limit: int = 50,
                       token: str = "") -> list:
    """Get most-taught titles in a field."""
    headers = {"Authorization": f"Bearer {token}"} if token else {}
    resp = requests.get(
        f"{BASE_URL}/rankings",
        headers=headers,
        params={"field": field, "limit": limit},
    )
    resp.raise_for_status()
    return resp.json().get("results", [])


# Example: find most-taught economics texts
# results = search_titles("microeconomics", field="Economics")
# for r in results:
#     print(f"#{r['rank']} {r['title']} — {r['authors']}")
#     print(f"  Teaching Score: {r['teaching_score']} "
#           f"({r['count']} syllabi)")
```

## Top Assigned Works (Examples)

| Rank | Title | Author | Field |
|------|-------|--------|-------|
| 1 | *The Elements of Style* | Strunk & White | Writing |
| 2 | *The Republic* | Plato | Philosophy |
| 3 | *A Manual for Writers* | Turabian | Writing |
| ~10 | *Thinking, Fast and Slow* | Kahneman | Psychology |
| ~50 | *Introduction to Algorithms* | CLRS | CS |

## Use Cases

1. **Curriculum design**: Find canonical texts in a discipline
2. **Textbook market research**: Identify widely adopted materials
3. **Teaching trends**: Track changes in assigned readings over time
4. **Interdisciplinary mapping**: Discover texts bridging fields
5. **Academic publishing**: Understand teaching impact vs. citation impact

## References

- [Open Syllabus](https://opensyllabus.org/)
- [Open Syllabus Explorer](https://explorer.opensyllabus.org/)
- Sinykin, D. & McLaughlin, T. (2021). "Mapping the Disciplinary Canon with Open Syllabus." *Cultural Analytics*.
