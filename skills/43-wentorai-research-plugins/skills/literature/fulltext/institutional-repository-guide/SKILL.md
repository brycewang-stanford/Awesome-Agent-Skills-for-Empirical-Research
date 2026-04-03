---
name: institutional-repository-guide
description: "Access papers from institutional and subject repositories at scale"
metadata:
  openclaw:
    emoji: "🏛️"
    category: "literature"
    subcategory: "fulltext"
    keywords: ["institutional repository", "DSpace", "EPrints", "open access archive", "subject repository", "OpenDOAR"]
    source: "wentor-research-plugins"
---

# Institutional Repository Guide

Institutional repositories (IRs) are university-run digital archives that store and provide open access to their researchers' scholarly output — dissertations, journal articles, conference papers, datasets, and technical reports. Subject repositories like arXiv, bioRxiv, SSRN, and RePEc serve similar functions for specific disciplines. Together, they form a distributed network of open scholarship that complements commercial databases.

This guide covers how to discover, access, and systematically harvest content from institutional and subject repositories for literature reviews, meta-analyses, and research data collection.

## Repository Landscape

### Types of Repositories

```
Institutional Repositories (IR):
  - Run by universities to archive their researchers' output
  - Examples: DSpace, EPrints, Fedora-based systems
  - Discovery: OpenDOAR directory (v2.sherpa.ac.uk/opendoar)

Subject Repositories:
  - Discipline-specific archives
  - arXiv (physics, CS, math), bioRxiv, SSRN, RePEc, EarthArXiv

Aggregators:
  - Harvest from many repositories into a single search interface
  - BASE (Bielefeld Academic Search Engine)
  - CORE (core.ac.uk, 200M+ open access articles)
  - OpenAIRE (European research output)
```

### Discovering Repositories

OpenDOAR (Directory of Open Access Repositories) is the primary registry for finding institutional repositories:

```python
import urllib.request
import json

def search_opendoar(subject: str = None, country: str = None) -> list:
    """
    Search the OpenDOAR registry for institutional repositories.

    Args:
        subject: Filter by subject area (e.g., "Biology", "Computer Science")
        country: ISO country code (e.g., "US", "GB", "CN")
    """
    base_url = "https://v2.sherpa.ac.uk/cgi/retrieve"
    params = "?item-type=repository&format=Json"
    if subject:
        params += f"&filter=[[\"{subject}\",\"subject\"]]"
    if country:
        params += f"&filter=[[\"{country}\",\"country\"]]"

    req = urllib.request.Request(base_url + params)
    response = urllib.request.urlopen(req)
    data = json.loads(response.read())

    repositories = []
    for item in data.get("items", []):
        repo_info = {
            "name": item.get("repository_metadata", {}).get("name", [{}])[0].get("name", ""),
            "url": item.get("repository_metadata", {}).get("url", ""),
            "oai_url": item.get("repository_metadata", {}).get("oai_url", ""),
            "software": item.get("repository_metadata", {}).get("software", {}).get("name", ""),
            "type": item.get("repository_metadata", {}).get("type", "")
        }
        repositories.append(repo_info)

    return repositories
```

## OAI-PMH Harvesting from Repositories

Most institutional repositories support OAI-PMH (Open Archives Initiative Protocol for Metadata Harvesting), the standard protocol for metadata exchange:

```python
import xml.etree.ElementTree as ET
import urllib.request

def harvest_repository(base_url: str, metadata_prefix: str = "oai_dc",
                       set_spec: str = None, from_date: str = None) -> list:
    """
    Harvest metadata records from a repository's OAI-PMH endpoint.

    Args:
        base_url: The OAI-PMH base URL
        metadata_prefix: Metadata format (oai_dc, datacite, mets)
        set_spec: Optional set/collection to restrict harvesting
        from_date: Harvest only records added after this date (YYYY-MM-DD)
    """
    params = f"?verb=ListRecords&metadataPrefix={metadata_prefix}"
    if set_spec:
        params += f"&set={set_spec}"
    if from_date:
        params += f"&from={from_date}"

    url = base_url + params
    records = []

    while url:
        response = urllib.request.urlopen(url)
        tree = ET.parse(response)
        root = tree.getroot()
        ns = {"oai": "http://www.openarchives.org/OAI/2.0/"}

        for record in root.findall(".//oai:record", ns):
            header = record.find("oai:header", ns)
            identifier = header.find("oai:identifier", ns).text
            datestamp = header.find("oai:datestamp", ns).text
            records.append({"identifier": identifier, "datestamp": datestamp})

        token_elem = root.find(".//oai:resumptionToken", ns)
        if token_elem is not None and token_elem.text:
            url = f"{base_url}?verb=ListRecords&resumptionToken={token_elem.text}"
        else:
            url = None

    return records
```

### Key OAI-PMH Verbs

| Verb | Purpose |
|------|---------|
| `Identify` | Get repository name, admin email, policies |
| `ListSets` | List available collections/sets |
| `ListMetadataFormats` | List supported metadata schemas |
| `ListIdentifiers` | Lightweight listing of record headers |
| `ListRecords` | Full metadata records with pagination |
| `GetRecord` | Retrieve a single record by identifier |

## Major Repository Platforms

### DSpace

The most widely deployed open-source repository platform (used by ~40% of repositories worldwide):

- OAI-PMH endpoint: `{base-url}/oai/request`
- REST API: `{base-url}/server/api`
- Supports Dublin Core, METS, and custom metadata schemas
- Examples: MIT DSpace, University of Cambridge Repository

### EPrints

Popular in the UK and Europe:

- OAI-PMH endpoint: `{base-url}/cgi/oai2`
- REST API: `{base-url}/cgi/export/{id}/{format}`
- Strong support for research output types (articles, theses, conference items)
- Examples: University of Southampton EPrints

### Fedora / Islandora

Used by larger institutions with complex digital collections:

- Typically paired with a discovery layer (Solr/Blacklight)
- Strong support for digital preservation workflows
- Examples: University of Toronto, Smithsonian Institution

## Building a Harvesting Pipeline

### Systematic Collection Workflow

```
1. Identify target repositories
   - Use OpenDOAR to find IRs by subject or country
   - List subject repositories relevant to your discipline

2. Test endpoints
   - Send Identify request to verify the endpoint is active
   - Check ListMetadataFormats for available schemas

3. Harvest incrementally
   - Use "from" parameter to harvest only new records
   - Store last harvest date for each repository
   - Respect rate limits (typically 1 request per second)

4. Deduplicate
   - Match records by DOI when available
   - Use title + author fuzzy matching for records without DOIs
   - Flag duplicates rather than deleting (keep provenance)

5. Store and index
   - Save metadata in structured format (JSON, SQLite, CSV)
   - Build a local search index for efficient retrieval
```

## Ethical Considerations

- Always respect `robots.txt` and repository rate limits
- Metadata harvesting is generally permitted; bulk full-text download may require permission
- Check each repository's terms of use before harvesting
- Use harvested data for research purposes, not commercial redistribution
- Attribute the source repository in publications using harvested data
- Consider reaching out to repository administrators for large-scale harvesting projects

## References

- OpenDOAR: https://v2.sherpa.ac.uk/opendoar/
- OAI-PMH specification: http://www.openarchives.org/OAI/openarchivesprotocol.html
- CORE: https://core.ac.uk
- BASE: https://www.base-search.net
- DSpace documentation: https://wiki.lyrasis.org/display/DSPACE
