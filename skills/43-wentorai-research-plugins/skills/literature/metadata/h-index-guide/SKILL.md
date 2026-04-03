---
name: h-index-guide
description: "Understanding and calculating research impact metrics"
metadata:
  openclaw:
    emoji: "🏅"
    category: "literature"
    subcategory: "metadata"
    keywords: ["h-index", "impact factor", "bibliometrics", "academic metrics", "citation statistics"]
    source: "wentor-research-plugins"
---

# H-Index and Research Impact Metrics Guide

Understand, calculate, and responsibly interpret bibliometric indicators including h-index, impact factor, and related metrics.

## Core Bibliometric Indicators

### H-Index

The h-index (Hirsch index) is defined as: a researcher has an h-index of h if h of their papers have each been cited at least h times.

**Example**: If a researcher has published 20 papers with citation counts [120, 80, 55, 40, 22, 18, 15, 12, 10, 8, 5, 3, 2, 2, 1, 1, 0, 0, 0, 0], their h-index is 10 (10 papers with at least 10 citations each).

```python
def calculate_h_index(citation_counts):
    """Calculate h-index from a list of citation counts."""
    sorted_counts = sorted(citation_counts, reverse=True)
    h = 0
    for i, count in enumerate(sorted_counts):
        if count >= i + 1:
            h = i + 1
        else:
            break
    return h

# Example
citations = [120, 80, 55, 40, 22, 18, 15, 12, 10, 8, 5, 3, 2, 2, 1, 1, 0, 0, 0, 0]
print(f"h-index: {calculate_h_index(citations)}")  # Output: 10
```

### Related Author-Level Metrics

| Metric | Definition | Advantage |
|--------|-----------|-----------|
| **h-index** | h papers with >= h citations | Simple, robust to outliers |
| **i10-index** | Number of papers with >= 10 citations | Intuitive threshold (Google Scholar uses this) |
| **g-index** | Largest g such that top g papers have >= g^2 total citations | Rewards highly cited papers more |
| **m-quotient** | h-index divided by years since first publication | Normalizes for career length |
| **hI-norm** | h-index divided by average number of co-authors | Adjusts for team size |

```python
def calculate_g_index(citation_counts):
    """Calculate g-index from citation counts."""
    sorted_counts = sorted(citation_counts, reverse=True)
    cumulative = 0
    g = 0
    for i, count in enumerate(sorted_counts):
        cumulative += count
        if cumulative >= (i + 1) ** 2:
            g = i + 1
    return g

def calculate_i10_index(citation_counts):
    """Calculate i10-index."""
    return sum(1 for c in citation_counts if c >= 10)

print(f"g-index: {calculate_g_index(citations)}")    # Output: 19
print(f"i10-index: {calculate_i10_index(citations)}") # Output: 10
```

## Journal-Level Metrics

### Journal Impact Factor (JIF)

Published annually by Clarivate in the Journal Citation Reports (JCR). The 2-year impact factor for year Y is:

```
JIF(Y) = (Citations in Y to articles published in Y-1 and Y-2)
         / (Number of citable items published in Y-1 and Y-2)
```

| Metric | Provider | Window | Notable Features |
|--------|----------|--------|------------------|
| Impact Factor | Clarivate (JCR) | 2-year or 5-year | Gold standard, subscription only |
| CiteScore | Scopus (Elsevier) | 4-year | Free, includes all document types |
| SJR (Scimago) | Scopus data | 3-year | Weights citations by journal prestige (PageRank-like) |
| SNIP | Scopus data | 3-year | Normalizes for citation potential of each field |
| h5-index | Google Scholar | 5-year | Free, h-index applied to a journal |

### Looking Up Journal Metrics

```python
import requests

# Using the OpenAlex API to get journal/source information
journal_name = "Nature"
response = requests.get(
    "https://api.openalex.org/sources",
    params={"filter": f"display_name.search:{journal_name}", "per_page": 5}
)
results = response.json()["results"]
for source in results:
    print(f"Name: {source['display_name']}")
    print(f"  ISSN: {source.get('issn_l', 'N/A')}")
    print(f"  Works count: {source.get('works_count', 'N/A')}")
    print(f"  Cited by count: {source.get('cited_by_count', 'N/A')}")
    print(f"  h-index: {source.get('summary_stats', {}).get('h_index', 'N/A')}")
    print(f"  2-year mean citedness: {source.get('summary_stats', {}).get('2yr_mean_citedness', 'N/A')}")
```

## Calculating Your Own H-Index

### From Google Scholar

Google Scholar profiles automatically display h-index and i10-index. No calculation needed, but coverage is the broadest (includes non-peer-reviewed sources).

### From OpenAlex

```python
# OpenAlex provides h-index directly in author profiles
author_name = "Geoffrey Hinton"
response = requests.get(
    "https://api.openalex.org/authors",
    params={"filter": f"display_name.search:{author_name}", "per_page": 1}
)
author = response.json()["results"][0]
print(f"h-index: {author['summary_stats']['h_index']}")
print(f"i10-index: {author['summary_stats']['i10_index']}")
print(f"2-year mean citedness: {author['summary_stats']['2yr_mean_citedness']}")
```

## Responsible Use of Metrics

### Known Limitations

1. **Field dependence**: Average citation rates vary dramatically across disciplines. An h-index of 20 is excellent in mathematics but modest in biomedical sciences.
2. **Career stage bias**: The h-index monotonically increases over time. Always compare within career stage (m-quotient helps).
3. **Self-citation**: Some databases include self-citations in h-index calculation.
4. **Database coverage**: Google Scholar, Scopus, and Web of Science yield different h-index values for the same author.
5. **Gaming**: Metrics can be inflated through citation cartels, salami slicing, and excessive self-citation.

### DORA Declaration

The San Francisco Declaration on Research Assessment (DORA) recommends:

- Do not use journal-based metrics (such as impact factor) as a surrogate measure of individual research quality.
- Assess research on its own merits rather than on the basis of the journal in which it is published.
- Use article-level metrics alongside qualitative indicators for assessment.

### Best Practices for Reporting

- Always specify the source database and date when reporting h-index
- Report multiple metrics rather than relying on a single number
- Provide field-normalized indicators (FWCI, SNIP) when comparing across disciplines
- Include qualitative achievements alongside quantitative metrics in CVs and promotion cases
