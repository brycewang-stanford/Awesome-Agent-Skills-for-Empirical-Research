---
name: wikidata-api-guide
description: "Query Wikidata SPARQL for scholarly metadata, authors, and entities"
metadata:
  openclaw:
    emoji: "🌐"
    category: "literature"
    subcategory: "metadata"
    keywords: ["wikidata", "sparql", "linked-data", "metadata", "knowledge-graph", "scholarly"]
    source: "https://www.wikidata.org/wiki/Wikidata:SPARQL_query_service"
---

# Wikidata SPARQL API Guide

## Overview

Wikidata is a free, collaborative, multilingual knowledge base maintained by the Wikimedia Foundation. It contains structured data about millions of entities including scholarly articles, academic journals, researchers, universities, and scientific concepts. Each entity has a unique QID and properties linking it to other entities, forming a rich knowledge graph.

For academic researchers, Wikidata serves as a powerful tool for bibliometric analysis, disambiguation of author names, mapping institutional relationships, and linking scholarly outputs across different identifier systems (DOI, ORCID, PubMed ID, arXiv ID, etc.). The SPARQL query service provides a flexible, standards-based interface for complex graph queries.

The Wikidata Query Service is entirely free, requires no authentication, and supports the full SPARQL 1.1 query language. It is especially powerful for cross-referencing scholarly metadata that spans multiple databases and identifier systems.

## Authentication

No authentication is required. The Wikidata SPARQL endpoint is free and open.

```bash
# No API key needed -- set a descriptive User-Agent header as courtesy
curl -G "https://query.wikidata.org/sparql" \
  --data-urlencode "query=SELECT ?item WHERE { ?item wdt:P31 wd:Q5 } LIMIT 5" \
  -H "Accept: application/json" \
  -H "User-Agent: ResearchClaw/1.0 (academic research tool)"
```

## Core Endpoints

### SPARQL Query Endpoint

```
GET https://query.wikidata.org/sparql?query={SPARQL}&format=json
```

**Parameters:**
- `query` (required): URL-encoded SPARQL query
- `format`: Response format (`json`, `xml`, `csv`, `tsv`)

### Query: Find Papers by a Researcher (via ORCID)

```bash
curl -G "https://query.wikidata.org/sparql" \
  --data-urlencode 'query=
    SELECT ?paper ?paperLabel ?doi WHERE {
      ?author wdt:P496 "0000-0002-1825-0097" .
      ?paper wdt:P50 ?author ;
             wdt:P356 ?doi .
      SERVICE wikibase:label { bd:serviceParam wikibase:language "en" . }
    } LIMIT 20' \
  -H "Accept: application/json" \
  -H "User-Agent: ResearchClaw/1.0"
```

### Query: Journal Impact and Article Counts

```sparql
SELECT ?journal ?journalLabel ?issn (COUNT(?article) AS ?articleCount) WHERE {
  ?journal wdt:P31 wd:Q5633421 ;
           wdt:P236 ?issn .
  ?article wdt:P1433 ?journal .
  SERVICE wikibase:label { bd:serviceParam wikibase:language "en" . }
}
GROUP BY ?journal ?journalLabel ?issn
ORDER BY DESC(?articleCount)
LIMIT 20
```

### Python Example: Cross-Reference Author Identifiers

```python
import requests

SPARQL_URL = "https://query.wikidata.org/sparql"
HEADERS = {
    "Accept": "application/json",
    "User-Agent": "ResearchClaw/1.0 (academic research tool)"
}

def query_wikidata(sparql_query):
    """Execute a SPARQL query against Wikidata."""
    resp = requests.get(
        SPARQL_URL,
        params={"query": sparql_query},
        headers=HEADERS
    )
    resp.raise_for_status()
    data = resp.json()
    return data["results"]["bindings"]

# Find all identifier mappings for a researcher
sparql = """
SELECT ?person ?personLabel ?orcid ?scopus ?dblp ?gscholar WHERE {
  ?person wdt:P496 "0000-0002-1825-0097" .
  OPTIONAL { ?person wdt:P496 ?orcid . }
  OPTIONAL { ?person wdt:P1153 ?scopus . }
  OPTIONAL { ?person wdt:P2456 ?dblp . }
  OPTIONAL { ?person wdt:P1960 ?gscholar . }
  SERVICE wikibase:label { bd:serviceParam wikibase:language "en" . }
}
"""
results = query_wikidata(sparql)
for r in results:
    print(f"Name: {r.get('personLabel', {}).get('value', 'N/A')}")
    print(f"  ORCID: {r.get('orcid', {}).get('value', 'N/A')}")
    print(f"  Scopus: {r.get('scopus', {}).get('value', 'N/A')}")
    print(f"  DBLP: {r.get('dblp', {}).get('value', 'N/A')}")
    print(f"  Google Scholar: {r.get('gscholar', {}).get('value', 'N/A')}")
```

### Query: Institutions by Country with Coordinates

```sparql
SELECT ?uni ?uniLabel ?country ?countryLabel ?coord WHERE {
  ?uni wdt:P31 wd:Q3918 ;
       wdt:P17 ?country ;
       wdt:P625 ?coord .
  FILTER(?country = wd:Q30)
  SERVICE wikibase:label { bd:serviceParam wikibase:language "en" . }
}
LIMIT 50
```

## Common Research Patterns

**Author Disambiguation:** Use Wikidata to resolve author names by cross-referencing ORCID, Scopus ID, DBLP, and Google Scholar identifiers. This is particularly useful when a common name maps to multiple researchers.

**Bibliometric Graph Construction:** Build citation and co-authorship networks by querying the relationships between authors, papers, journals, and institutions in the Wikidata graph.

**Identifier Translation:** Convert between DOI, PubMed ID, arXiv ID, and other identifiers using Wikidata's comprehensive property mappings. This enables linking records across heterogeneous databases.

**Institutional Analysis:** Map university affiliations, geographic distributions, and organizational hierarchies for researchers in a specific field.

## Rate Limits and Best Practices

- **Query timeout:** 60 seconds; optimize complex queries with filters and limits
- **Request rate:** No strict published limit, but keep requests under 1 per second for sustained usage
- **User-Agent required:** Always include a descriptive User-Agent header identifying your application
- **LIMIT clause:** Always include a LIMIT clause to prevent accidentally fetching millions of results
- **Label service:** Use `SERVICE wikibase:label` for human-readable labels instead of QIDs
- **Caching:** Wikidata results are fairly stable; cache results for repeated queries
- **Bulk queries:** For large-scale data extraction, consider using Wikidata dumps instead of the query service

## References

- Wikidata SPARQL Query Service: https://query.wikidata.org/
- Wikidata SPARQL Tutorial: https://www.wikidata.org/wiki/Wikidata:SPARQL_tutorial
- Wikidata Properties for Scholarly Articles: https://www.wikidata.org/wiki/Wikidata:WikiProject_Source_MetaData
- Wikidata REST API: https://www.wikidata.org/wiki/Wikidata:REST_API
