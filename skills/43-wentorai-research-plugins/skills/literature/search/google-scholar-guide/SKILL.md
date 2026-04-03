---
name: google-scholar-guide
description: "Advanced Google Scholar search techniques for comprehensive literature discovery"
metadata:
  openclaw:
    emoji: "🔎"
    category: "literature"
    subcategory: "search"
    keywords: ["academic database search", "search strategy", "Boolean search", "advanced search", "Google Scholar"]
    source: "wentor"
---

# Google Scholar Guide

A skill for leveraging Google Scholar's full capabilities for academic literature search. Covers advanced search operators, citation tracking, alert configuration, and strategies for systematic and comprehensive retrieval.

## Advanced Search Operators

### Core Operators

| Operator | Syntax | Example | Effect |
|----------|--------|---------|--------|
| Exact phrase | `"..."` | `"machine learning"` | Matches exact phrase |
| OR | `OR` | `"deep learning" OR "neural network"` | Matches either term |
| Exclude | `-` | `transformer -electrical` | Excludes term |
| Author | `author:` | `author:"Y LeCun"` | Filter by author |
| Source | `source:` | `source:"Nature"` | Filter by journal |
| Title only | `intitle:` | `intitle:"attention mechanism"` | Search in title only |
| Date range | Custom range | Via Advanced Search UI | Limit publication years |
| File type | `filetype:` | `filetype:pdf` | Specific file formats |

### Constructing Effective Queries

```python
def build_scholar_query(concepts: list[list[str]], exclude: list[str] = None,
                         title_only: bool = False, author: str = None,
                         source: str = None) -> str:
    """
    Build a structured Google Scholar query from concept groups.

    Args:
        concepts: List of concept groups, each a list of synonyms
                  Groups are ANDed together, synonyms are ORed
        exclude: Terms to exclude
        title_only: Search in title only
        author: Author name filter
        source: Journal/source filter
    Returns:
        Formatted Google Scholar query string
    """
    # Build concept groups with OR
    groups = []
    for concept_group in concepts:
        if len(concept_group) == 1:
            groups.append(f'"{concept_group[0]}"')
        else:
            terms = ' OR '.join(f'"{term}"' for term in concept_group)
            groups.append(f'({terms})')

    # AND the concept groups together
    query = ' '.join(groups)

    # Apply title restriction
    if title_only:
        query = f'intitle:{query}'

    # Add exclusions
    if exclude:
        for term in exclude:
            query += f' -{term}'

    # Add author filter
    if author:
        query += f' author:"{author}"'

    # Add source filter
    if source:
        query += f' source:"{source}"'

    return query

# Example: find papers on transfer learning for medical imaging
query = build_scholar_query(
    concepts=[
        ["transfer learning", "domain adaptation", "fine-tuning"],
        ["medical imaging", "radiology", "pathology images"],
        ["deep learning", "convolutional neural network"]
    ],
    exclude=["survey", "review"],
    title_only=False
)
print(query)
# Output: ("transfer learning" OR "domain adaptation" OR "fine-tuning")
#         ("medical imaging" OR "radiology" OR "pathology images")
#         ("deep learning" OR "convolutional neural network") -survey -review
```

## Citation Tracking Strategies

### Forward and Backward Citation Chaining

```
Seed Paper (a highly relevant paper you already know)
  |
  +--> "Cited by" link -> Forward citation tracking
  |    (who cited this paper? newer related work)
  |
  +--> Reference list -> Backward citation tracking
       (what did this paper cite? foundational work)

Repeat for each highly relevant paper found.
Stop when you reach saturation (no new relevant papers appearing).
```

### Identifying Key Papers

Use citation metrics strategically:

```python
def identify_key_papers(search_results: list[dict],
                         min_citations: int = 10) -> list[dict]:
    """
    Identify key papers from search results using citation analysis.

    Args:
        search_results: List of papers with 'title', 'year', 'citations'
        min_citations: Minimum citation threshold
    """
    import datetime
    current_year = datetime.datetime.now().year

    for paper in search_results:
        age = max(1, current_year - paper['year'])
        paper['citations_per_year'] = paper['citations'] / age

        # Classify influence
        if paper['citations_per_year'] > 50:
            paper['influence'] = 'landmark'
        elif paper['citations_per_year'] > 20:
            paper['influence'] = 'highly_influential'
        elif paper['citations_per_year'] > 5:
            paper['influence'] = 'influential'
        else:
            paper['influence'] = 'standard'

    # Filter and sort
    filtered = [p for p in search_results if p['citations'] >= min_citations]
    return sorted(filtered, key=lambda x: x['citations_per_year'], reverse=True)
```

## Google Scholar Alerts

Set up alerts to stay current:

1. Go to Google Scholar and run your search query
2. Click "Create alert" in the left sidebar
3. Configure email frequency (as-it-happens or weekly digest)
4. Use the same carefully constructed query from your search strategy

Best practices for alerts:
- Create separate alerts for each major concept group
- Use narrow, specific queries to reduce noise (10-20 results per alert is ideal)
- Review and refine alert queries quarterly

## Google Scholar Profiles

### Leveraging Author Profiles

- Follow prolific researchers in your field to get notifications of their new publications
- Use the "Related articles" feature on author profile pages
- Check co-author networks to discover related research groups
- The h-index and i10-index on profiles can help gauge researcher impact, but use with caution across different fields

## Limitations and Complementary Databases

Google Scholar has known limitations:
- No controlled vocabulary or MeSH terms (unlike PubMed)
- Cannot filter by study design or methodology
- Includes non-peer-reviewed sources (preprints, theses, slides)
- Citation counts may include self-citations and non-scholarly citations

For systematic reviews, always supplement Google Scholar with structured databases: PubMed/MEDLINE, Web of Science, Scopus, and domain-specific databases (e.g., IEEE Xplore, PsycINFO, EconLit). Document the number of results from each database for your PRISMA flow diagram.
