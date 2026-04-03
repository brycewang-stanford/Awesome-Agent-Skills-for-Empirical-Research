---
name: europe-pmc-api
description: "Search biomedical and life sciences literature via Europe PMC"
metadata:
  openclaw:
    emoji: "🔍"
    category: "literature"
    subcategory: "search"
    keywords: ["academic database search", "literature search", "citation tracking", "field-specific search"]
    source: "https://europepmc.org/RestfulWebService"
---

# Europe PMC API Guide

## Overview

Europe PMC (PubMed Central) is a free, comprehensive biomedical literature database maintained by the European Bioinformatics Institute (EMBL-EBI) as part of a network of 32 European funders. It provides access to over 40 million biomedical and life sciences publications, including abstracts from PubMed/MEDLINE, full-text articles from PubMed Central, patents from the European Patent Office, and preprints from biomedical preprint servers.

Europe PMC extends beyond PubMed by integrating additional European content, preprints, and rich text-mined annotations. It provides links to biological databases (UniProt, Protein Data Bank, etc.), grant information from funders, and citation data. The annotation features include gene/protein mentions, disease names, organism identifiers, and chemical entities extracted via machine learning.

The API is free, requires no authentication, and supports 10 requests per second. It returns JSON or XML and offers advanced query syntax with field-specific searches, boolean operators, and date range filters.

## Authentication

No authentication required. The Europe PMC API is fully open. No API key, registration, or email is needed. The API enforces a rate limit of 10 requests per second per IP address. Including a descriptive User-Agent header is considered good practice.

## Core Endpoints

### Search: Full-Text Literature Search

- **URL**: `GET https://www.ebi.ac.uk/europepmc/webservices/rest/search`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | query | string | Yes | Search query (supports field codes: TITLE, AUTH, JOURNAL, DOI, etc.) |
  | format | string | No | Response format: json (default) or xml |
  | resultType | string | No | lite (default) or core (includes full abstract and metadata) |
  | pageSize | integer | No | Results per page (default: 25, max: 1000) |
  | cursorMark | string | No | Cursor for deep pagination (use nextCursorMark from response) |
  | sort | string | No | Sort field: RELEVANCE, CITED, DATE (default: RELEVANCE) |
  | synonym | boolean | No | Enable MeSH synonym expansion (default: true) |
- **Example**:
  ```bash
  curl "https://www.ebi.ac.uk/europepmc/webservices/rest/search?query=CRISPR+AND+cancer&format=json&resultType=core&pageSize=10&sort=CITED+desc"
  ```
- **Response**: JSON with `hitCount`, `nextCursorMark`, and `resultList.result` array. Each result contains `id`, `source` (MED, PMC, PPR, PAT), `pmid`, `pmcid`, `doi`, `title`, `authorString`, `journalTitle`, `pubYear`, `abstractText`, `citedByCount`, `isOpenAccess`, and `fullTextUrlList`.

### Citations: Papers Citing a Publication

- **URL**: `GET https://www.ebi.ac.uk/europepmc/webservices/rest/{source}/{id}/citations`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | source | string | Yes | Source database: MED (PubMed), PMC, PPR (preprint), PAT (patent) |
  | id | string | Yes | The publication ID (PMID, PMCID, etc.) |
  | format | string | No | json or xml |
  | page | integer | No | Page number (default: 1) |
  | pageSize | integer | No | Results per page (default: 25) |
- **Example**:
  ```bash
  curl "https://www.ebi.ac.uk/europepmc/webservices/rest/MED/33116299/citations?format=json&pageSize=10"
  ```
- **Response**: JSON with `hitCount` and `citationList.citation` array containing citing publication metadata.

### References: Papers Cited by a Publication

- **URL**: `GET https://www.ebi.ac.uk/europepmc/webservices/rest/{source}/{id}/references`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | source | string | Yes | Source database |
  | id | string | Yes | The publication ID |
  | format | string | No | json or xml |
  | page | integer | No | Page number |
  | pageSize | integer | No | Results per page |
- **Example**:
  ```bash
  curl "https://www.ebi.ac.uk/europepmc/webservices/rest/MED/33116299/references?format=json&pageSize=50"
  ```
- **Response**: JSON with `referenceList.reference` array containing reference metadata.

## Rate Limits

The API enforces a rate limit of 10 requests per second per IP address. There is no daily request cap. Exceeding the rate limit returns HTTP 429. For bulk data access, Europe PMC provides OAI-PMH harvesting, FTP bulk downloads, and SPARQL endpoint access. Cursor-based pagination (using `cursorMark`) is required for retrieving beyond the first 10,000 results.

## Common Patterns

### Systematic Review Search

Perform a structured biomedical search with MeSH terms and date filters:

```bash
curl -s "https://www.ebi.ac.uk/europepmc/webservices/rest/search?query=(TITLE:immunotherapy+AND+TITLE:melanoma)+AND+(PUB_YEAR:[2022+TO+2026])&format=json&resultType=core&pageSize=25&sort=CITED+desc" | jq '.resultList.result[] | {title: .title, journal: .journalTitle, year: .pubYear, citations: .citedByCount, oa: .isOpenAccess}'
```

### Find Preprints Related to a Topic

Search specifically in the preprint sources indexed by Europe PMC:

```bash
curl -s "https://www.ebi.ac.uk/europepmc/webservices/rest/search?query=(SRC:PPR)+AND+large+language+models+AND+biology&format=json&pageSize=10" | jq '.resultList.result[] | {title: .title, source: .source, year: .pubYear, doi: .doi}'
```

### Build a Citation Map for a Key Paper

Retrieve both citations and references to map a paper's scholarly context:

```bash
# Get papers that cite the target
curl -s "https://www.ebi.ac.uk/europepmc/webservices/rest/MED/33116299/citations?format=json&pageSize=50" | jq '.citationList.citation | length'

# Get papers referenced by the target
curl -s "https://www.ebi.ac.uk/europepmc/webservices/rest/MED/33116299/references?format=json&pageSize=100" | jq '.referenceList.reference | length'
```

## References

- Official documentation: https://europepmc.org/RestfulWebService
- Europe PMC search syntax: https://europepmc.org/searchsyntax
- Europe PMC annotations API: https://europepmc.org/AnnotationsApi
