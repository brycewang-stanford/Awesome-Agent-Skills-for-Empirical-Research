---
name: pmc-oai-api
description: "PubMed Central OAI-PMH metadata harvesting"
metadata:
  openclaw:
    emoji: "🔍"
    category: "literature"
    subcategory: "fulltext"
    keywords: ["full-text retrieval", "open access", "PDF download", "preprint server"]
    source: "https://pmc.ncbi.nlm.nih.gov/tools/oai/"
---

# PMC-OAI API Guide

## Overview

PubMed Central (PMC) is a free full-text archive of biomedical and life sciences journal literature at the U.S. National Institutes of Health's National Library of Medicine (NIH/NLM). The PMC OAI-PMH (Open Archives Initiative Protocol for Metadata Harvesting) service provides a standardized interface for systematically harvesting metadata and full-text content from the PMC archive.

The OAI-PMH protocol is an internationally recognized standard for metadata harvesting, widely used by libraries, repositories, and research infrastructure. The PMC implementation allows researchers to programmatically discover and retrieve article metadata, including titles, authors, abstracts, MeSH terms, publication dates, and links to full-text XML and PDF versions. This is particularly valuable for building local search indexes, systematic review pipelines, and text mining corpora.

Biomedical researchers, systematic reviewers, bioinformaticians, medical librarians, and text mining specialists use the PMC OAI-PMH service to harvest large collections of open-access biomedical literature for meta-analyses, natural language processing research, knowledge graph construction, and institutional repository enrichment. PMC contains over 9 million full-text articles, making it one of the largest open-access biomedical literature collections in the world.

## Authentication

No authentication required. The PMC OAI-PMH service is freely accessible without any API key, token, or registration. All requests are made via standard HTTP GET requests. However, users must comply with NCBI usage guidelines and respect the rate limits to ensure fair access for all users.

## Core Endpoints

### ListRecords: Harvest Article Metadata

Retrieve metadata records from PMC in bulk, with optional filtering by date range and metadata set. This is the primary endpoint for systematic metadata harvesting.

- **URL**: `GET https://pmc.ncbi.nlm.nih.gov/api/oai/v1/mh/`
- **Parameters**:

| Parameter       | Type   | Required | Description                                             |
|-----------------|--------|----------|---------------------------------------------------------|
| verb            | string | Yes      | Must be `ListRecords`                                   |
| metadataPrefix  | string | Yes      | Metadata format: `oai_dc`, `pmc`, or `pmc_fm`          |
| set             | string | No       | Filter by set (e.g., journal, open access subset)       |
| from            | string | No       | Start date for selective harvesting (YYYY-MM-DD)        |
| until           | string | No       | End date for selective harvesting (YYYY-MM-DD)          |
| resumptionToken | string | No       | Token for paginating through large result sets          |

- **Example**:

```bash
# Harvest recent open-access records in Dublin Core format
curl "https://pmc.ncbi.nlm.nih.gov/api/oai/v1/mh/?verb=ListRecords&metadataPrefix=oai_dc&from=2024-06-01&until=2024-06-07"

# Harvest PMC full metadata format
curl "https://pmc.ncbi.nlm.nih.gov/api/oai/v1/mh/?verb=ListRecords&metadataPrefix=pmc_fm&from=2024-06-01&until=2024-06-02"
```

- **Response**: Returns XML containing `<record>` elements, each with `<header>` (identifier, datestamp, setSpec) and `<metadata>` (article title, creators, subjects, description, date, identifiers, rights). Includes a `<resumptionToken>` for fetching subsequent pages.

### GetRecord: Retrieve a Single Record

Fetch the complete metadata record for a specific PMC article by its OAI identifier.

- **URL**: `GET https://pmc.ncbi.nlm.nih.gov/api/oai/v1/mh/`
- **Parameters**:

| Parameter       | Type   | Required | Description                                        |
|-----------------|--------|----------|----------------------------------------------------|
| verb            | string | Yes      | Must be `GetRecord`                                |
| identifier      | string | Yes      | OAI identifier (e.g., `oai:pubmedcentral.nih.gov:1234567`) |
| metadataPrefix  | string | Yes      | Metadata format: `oai_dc`, `pmc`, or `pmc_fm`     |

- **Example**:

```bash
curl "https://pmc.ncbi.nlm.nih.gov/api/oai/v1/mh/?verb=GetRecord&identifier=oai:pubmedcentral.nih.gov:7096803&metadataPrefix=oai_dc"
```

- **Response**: Returns a single `<record>` element with full metadata in the requested format, including article title, all authors, abstract, journal information, publication date, DOI, PMID, and subject classifications.

### ListSets: Discover Available Sets

Retrieve the list of available sets (collections) that can be used to filter records during harvesting. Sets typically correspond to journals, open-access subsets, or subject categories.

- **URL**: `GET https://pmc.ncbi.nlm.nih.gov/api/oai/v1/mh/`
- **Parameters**:

| Parameter | Type   | Required | Description          |
|-----------|--------|----------|----------------------|
| verb      | string | Yes      | Must be `ListSets`   |

- **Example**:

```bash
curl "https://pmc.ncbi.nlm.nih.gov/api/oai/v1/mh/?verb=ListSets"
```

- **Response**: Returns XML with `<set>` elements containing `<setSpec>` (machine-readable identifier) and `<setName>` (human-readable name) for each available collection.

## Rate Limits

The PMC OAI-PMH service enforces a rate limit of 3 requests per second. Exceeding this limit may result in temporary IP blocking. NCBI requires users to make no more than 3 requests per second across all NCBI E-utilities and OAI services combined. For bulk harvesting, implement appropriate delays between requests and use the resumptionToken for pagination rather than making parallel requests.

NCBI also requests that users identify themselves by including an email address in the HTTP request headers or by registering for an NCBI API key (which allows up to 10 requests per second).

## Common Patterns

### Incremental Metadata Harvesting

Harvest new records added since your last sync using date-based selective harvesting:

```python
import requests
import xml.etree.ElementTree as ET
import time

base_url = "https://pmc.ncbi.nlm.nih.gov/api/oai/v1/mh/"
params = {
    "verb": "ListRecords",
    "metadataPrefix": "oai_dc",
    "from": "2024-06-01",
    "until": "2024-06-07"
}

all_records = []
while True:
    resp = requests.get(base_url, params=params)
    root = ET.fromstring(resp.text)
    ns = {"oai": "http://www.openarchives.org/OAI/2.0/"}

    records = root.findall(".//oai:record", ns)
    all_records.extend(records)

    token_elem = root.find(".//oai:resumptionToken", ns)
    if token_elem is not None and token_elem.text:
        params = {"verb": "ListRecords", "resumptionToken": token_elem.text}
        time.sleep(0.5)  # Respect rate limits
    else:
        break

print(f"Harvested {len(all_records)} records")
```

### Build a Local Search Index

Extract structured metadata from harvested records for indexing:

```python
import requests
import xml.etree.ElementTree as ET

url = "https://pmc.ncbi.nlm.nih.gov/api/oai/v1/mh/"
params = {
    "verb": "GetRecord",
    "identifier": "oai:pubmedcentral.nih.gov:7096803",
    "metadataPrefix": "oai_dc"
}

resp = requests.get(url, params=params)
root = ET.fromstring(resp.text)

dc_ns = "http://purl.org/dc/elements/1.1/"
oai_ns = "http://www.openarchives.org/OAI/2.0/"

metadata = root.find(f".//{{{oai_ns}}}metadata")
if metadata is not None:
    title = metadata.find(f".//{{{dc_ns}}}title")
    creators = metadata.findall(f".//{{{dc_ns}}}creator")
    print(f"Title: {title.text if title is not None else 'N/A'}")
    print(f"Authors: {', '.join(c.text for c in creators)}")
```

### Discover Available Journal Sets

List all available journal sets to target specific journal harvesting:

```bash
curl "https://pmc.ncbi.nlm.nih.gov/api/oai/v1/mh/?verb=ListSets" | head -100
```

## References

- Official PMC OAI documentation: https://pmc.ncbi.nlm.nih.gov/tools/oai/
- PMC homepage: https://pmc.ncbi.nlm.nih.gov/
- OAI-PMH protocol specification: https://www.openarchives.org/OAI/openarchivesprotocol.html
- NCBI usage guidelines: https://www.ncbi.nlm.nih.gov/home/about/policies/
- PMC Open Access subset: https://pmc.ncbi.nlm.nih.gov/tools/openftlist/
