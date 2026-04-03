---
name: systematic-search-strategy
description: "Construct rigorous systematic search strategies for literature reviews"
metadata:
  openclaw:
    emoji: "🎯"
    category: "literature"
    subcategory: "search"
    keywords: ["search strategy", "Boolean search", "search string construction", "advanced search", "systematic review"]
    source: "wentor"
---

# Systematic Search Strategy

A skill for designing and executing comprehensive, reproducible literature search strategies for systematic reviews, scoping reviews, and meta-analyses. Follows PRISMA 2020 guidelines and Cochrane Handbook best practices.

## PICO Framework for Search Design

Structure your research question using PICO (or variants):

```
P - Population / Problem:   Who or what is being studied?
I - Intervention / Exposure: What is the treatment or exposure?
C - Comparison:              What is the alternative?
O - Outcome:                 What is being measured?

Variants:
PICOS: adds Study design
SPIDER: Sample, Phenomenon of Interest, Design, Evaluation, Research type
PCC:    Population, Concept, Context (for scoping reviews)
```

### From PICO to Search Strategy

```python
def pico_to_search_blocks(pico: dict) -> dict:
    """
    Convert a PICO question into search concept blocks.

    Args:
        pico: Dict with keys 'population', 'intervention', 'comparison', 'outcome'
              Each value is a list of synonyms/related terms
    Returns:
        Search blocks ready for Boolean combination
    """
    blocks = {}
    for component, terms in pico.items():
        # Expand each term with common variants
        expanded = []
        for term in terms:
            expanded.append(f'"{term}"')
            # Add truncation variants
            if len(term) > 5:
                expanded.append(f'{term.rstrip("s")}*')  # basic stemming
        blocks[component] = expanded

    # Build final query: AND between blocks, OR within blocks
    query_parts = []
    for component, terms in blocks.items():
        block = ' OR '.join(terms)
        query_parts.append(f'({block})')

    final_query = ' AND '.join(query_parts)
    return {
        'blocks': blocks,
        'combined_query': final_query,
        'n_concepts': len(blocks)
    }

# Example: RQ: "Does mindfulness meditation reduce anxiety in college students?"
pico = {
    'population': ['college students', 'university students', 'undergraduate students',
                    'higher education students'],
    'intervention': ['mindfulness', 'mindfulness meditation', 'mindfulness-based stress reduction',
                     'MBSR', 'mindfulness-based cognitive therapy', 'MBCT'],
    'outcome': ['anxiety', 'anxiety disorder', 'generalized anxiety', 'test anxiety',
                'anxiety symptoms', 'state anxiety', 'trait anxiety']
}
result = pico_to_search_blocks(pico)
print(result['combined_query'])
```

## Database-Specific Search Syntax

### Adapting Searches Across Databases

```python
def adapt_search_for_database(base_query: str, database: str) -> str:
    """
    Adapt a base search string for different database syntaxes.
    """
    adaptations = {
        'pubmed': {
            'truncation': '*',
            'phrase': '"..."',
            'proximity': None,  # PubMed doesn't support proximity
            'field_tags': {'title': '[ti]', 'abstract': '[tiab]', 'mesh': '[MeSH]'},
            'notes': 'Add MeSH terms for each concept block'
        },
        'web_of_science': {
            'truncation': '*',
            'phrase': '"..."',
            'proximity': 'NEAR/N',
            'field_tags': {'title': 'TI=', 'topic': 'TS=', 'author': 'AU='},
            'notes': 'Use TS= for topic search (title+abstract+keywords)'
        },
        'scopus': {
            'truncation': '*',
            'phrase': '"..."',
            'proximity': 'W/N',
            'field_tags': {'title': 'TITLE()', 'title_abs': 'TITLE-ABS-KEY()', 'author': 'AUTH()'},
            'notes': 'Use TITLE-ABS-KEY() for comprehensive searching'
        },
        'psycinfo': {
            'truncation': '*',
            'phrase': '"..."',
            'proximity': 'Nn',
            'field_tags': {'title': 'TI', 'abstract': 'AB', 'thesaurus': 'DE'},
            'notes': 'Use DE field for PsycINFO thesaurus terms'
        }
    }

    db = adaptations.get(database.lower(), {})
    adapted = base_query  # Start with base query

    return {
        'database': database,
        'query': adapted,
        'syntax_notes': db.get('notes', ''),
        'truncation': db.get('truncation', '*'),
        'field_tags': db.get('field_tags', {})
    }
```

## Search Documentation

### PRISMA-S Reporting Checklist

Document every search completely:

```yaml
search_documentation:
  date_searched: "2026-03-09"
  databases:
    - name: "PubMed/MEDLINE"
      interface: "PubMed.gov"
      date_coverage: "1966-present"
      search_string: |
        (("college students"[tiab] OR "university students"[tiab])
        AND ("mindfulness"[tiab] OR "MBSR"[tiab])
        AND ("anxiety"[tiab] OR "anxiety disorders"[MeSH]))
      results_count: 342
      filters_applied: "English language; 2010-2026"

    - name: "Web of Science"
      interface: "Clarivate"
      date_coverage: "1900-present"
      search_string: |
        TS=("college student*" OR "university student*")
        AND TS=(mindfulness OR MBSR OR MBCT)
        AND TS=(anxiety)
      results_count: 287
      filters_applied: "Article or Review; English; 2010-2026"

  grey_literature:
    - "ProQuest Dissertations (N=45)"
    - "Google Scholar first 200 results"
    - "OpenGrey (N=12)"
    - "Hand-searched reference lists of included studies"

  total_before_dedup: 686
  total_after_dedup: 493
  deduplication_tool: "Covidence"
```

## Screening Workflow

### PRISMA Flow Diagram Data

```python
def prisma_flow(records: dict) -> str:
    """Generate PRISMA 2020 flow diagram data."""
    flow = f"""
    IDENTIFICATION
      Records from databases: {records['from_databases']}
      Records from other sources: {records['from_other']}
      Duplicates removed: {records['duplicates']}
      Records after dedup: {records['from_databases'] + records['from_other'] - records['duplicates']}

    SCREENING
      Title/abstract screened: {records['screened']}
      Excluded at title/abstract: {records['excluded_screening']}
      Full-text assessed: {records['fulltext_assessed']}
      Excluded at full-text: {records['excluded_fulltext']}
        Reasons: {records.get('exclusion_reasons', 'See table')}

    INCLUDED
      Studies in qualitative synthesis: {records['included_qualitative']}
      Studies in meta-analysis: {records.get('included_meta', 'N/A')}
    """
    return flow
```

## Iterating and Refining

After initial search execution:

1. Check sensitivity: Are known relevant papers (seed papers) captured?
2. Check precision: What proportion of results are relevant? (Target >5% for systematic reviews)
3. If too many results: Add specificity with additional concept blocks or filters
4. If too few results: Broaden terms, add synonyms, remove restrictive blocks
5. Consult a research librarian for complex searches -- they are expert search strategists

Document every modification to the search strategy with rationale to maintain transparency and reproducibility.
