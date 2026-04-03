---
name: citation-chaining-guide
description: "Forward and backward citation chaining techniques for literature search"
metadata:
  openclaw:
    emoji: "🔗"
    category: "literature"
    subcategory: "search"
    keywords: ["citation tracking", "advanced search", "search strategy", "literature search"]
    source: "wentor-research-plugins"
---

# Citation Chaining Guide

Master forward and backward citation chaining to systematically discover relevant literature by following the threads of scholarly communication.

## What Is Citation Chaining?

Citation chaining (also called citation tracking, pearl growing, or snowball searching) exploits the connections between papers through their references and citations. Starting from one or more "seed" papers, you trace connections in two directions:

- **Backward chaining**: Examine the reference list of a paper to find older, foundational works it builds upon.
- **Forward chaining**: Find newer papers that have cited the seed paper, discovering subsequent developments.

This approach is especially powerful when keyword searches fail (e.g., when terminology varies across subfields or when concepts predate standardized vocabulary).

## Step-by-Step Workflow

### Step 1: Identify Seed Papers

Select 3-5 highly relevant papers that are central to your research question. Good seed papers are:

- Frequently cited review articles or seminal original research
- Papers whose methodology or framework aligns closely with your work
- Recent papers in top venues for your field

### Step 2: Backward Chaining (Reference Mining)

Examine the reference list of each seed paper and identify which cited works are relevant.

```python
import requests

HEADERS = {"User-Agent": "ResearchPlugins/1.0 (https://wentor.ai)"}

def get_references(work_id):
    """Get all references of a paper via OpenAlex."""
    url = f"https://api.openalex.org/works/{work_id}"
    response = requests.get(url, headers=HEADERS)
    paper = response.json()
    ref_ids = paper.get("referenced_works", [])

    references = []
    for ref_id in ref_ids:
        ref = requests.get(f"https://api.openalex.org/works/{ref_id.split('/')[-1]}", headers=HEADERS).json()
        if ref.get("title"):
            references.append(ref)
    return references

# Get references of a seed paper
seed_id = "W2741809807"
references = get_references(seed_id)

# Sort by citation count to find the most influential foundations
references.sort(key=lambda p: p.get("cited_by_count", 0), reverse=True)
for ref in references[:15]:
    print(f"[{ref.get('publication_year', '?')}] {ref['title']} ({ref.get('cited_by_count', 0)} citations)")
```

### Step 3: Forward Chaining (Citation Tracking)

Find all papers that have cited your seed paper.

```python
def get_citations(work_id, limit=200):
    """Get papers citing a given paper via OpenAlex."""
    all_citations = []
    page = 1
    while len(all_citations) < limit:
        response = requests.get(
            "https://api.openalex.org/works",
            params={
                "filter": f"cites:{work_id}",
                "sort": "cited_by_count:desc",
                "per_page": min(200, limit - len(all_citations)),
                "page": page
            },
            headers=HEADERS
        )
        results = response.json().get("results", [])
        if not results:
            break
        all_citations.extend(results)
        page += 1
    return all_citations

citations = get_citations(seed_id)
# Filter for recent, well-cited papers
recent_impactful = [c for c in citations if c.get("publication_year", 0) >= 2022 and c.get("cited_by_count", 0) >= 5]
recent_impactful.sort(key=lambda p: p.get("cited_by_count", 0), reverse=True)
```

### Step 4: Co-Citation and Bibliographic Coupling

Two advanced techniques extend basic citation chaining:

| Technique | Definition | What It Reveals |
|-----------|-----------|-----------------|
| **Co-citation** | Two papers are frequently cited together by the same set of subsequent papers | Conceptual proximity: these works form a shared intellectual foundation |
| **Bibliographic coupling** | Two papers share many of the same references | Methodological or topical similarity at the time of writing |

```python
def find_co_cited_papers(paper_ids, min_co_citation_count=3):
    """Find papers frequently co-cited with the given papers."""
    from collections import Counter
    reference_counts = Counter()

    for pid in paper_ids:
        refs = get_references(pid)
        for ref in refs:
            ref_id = ref.get("paperId")
            if ref_id and ref_id not in paper_ids:
                reference_counts[ref_id] += 1

    # Papers cited by multiple seeds are co-cited candidates
    co_cited = [(pid, count) for pid, count in reference_counts.items()
                if count >= min_co_citation_count]
    co_cited.sort(key=lambda x: x[1], reverse=True)
    return co_cited
```

### Step 5: Iterative Expansion

Repeat the process with the most relevant papers discovered in each round:

1. **Round 1**: Start with 3-5 seed papers
2. **Round 2**: Run backward + forward chaining on seeds, identify 10-15 new relevant papers
3. **Round 3**: Run chaining on the new papers from Round 2
4. **Saturation**: Stop when new rounds yield diminishing returns (i.e., the same papers keep appearing)

## Tools for Citation Chaining

| Tool | Method | Cost |
|------|--------|------|
| Google Scholar "Cited by" | Forward chaining | Free |
| Web of Science "Cited References" / "Times Cited" | Both directions | Subscription |
| Scopus "References" / "Cited by" | Both directions | Subscription |
| OpenAlex API | Programmatic, both directions | Free |
| Connected Papers (connectedpapers.com) | Visual co-citation graph | Free (limited) |
| Litmaps (litmaps.com) | Visual citation network | Free tier |
| CoCites (cocites.com) | Co-citation analysis | Free |
| Citation Gecko | Seed-based discovery | Free |

## Common Pitfalls

- **Citation bias**: Highly cited papers are not always the best or most relevant. Pay attention to less-cited but methodologically sound papers.
- **Recency bias**: Forward chaining favors recent papers with fewer citations. Allow time for citation accumulation or use Mendeley readership as a proxy.
- **Field boundaries**: Citation chains tend to stay within disciplinary silos. Combine with keyword searches in adjacent-field databases to break out.
- **Incomplete coverage**: No single database indexes all citations. Cross-check with at least two sources (e.g., OpenAlex + Google Scholar).
