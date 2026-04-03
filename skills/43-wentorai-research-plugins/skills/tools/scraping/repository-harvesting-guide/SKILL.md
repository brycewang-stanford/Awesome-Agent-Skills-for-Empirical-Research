---
name: repository-harvesting-guide
description: "Harvest metadata from open repositories using OAI-PMH protocol"
metadata:
  openclaw:
    emoji: "🚜"
    category: "tools"
    subcategory: "scraping"
    keywords: ["OAI-PMH", "metadata harvesting", "open repositories", "Dublin Core", "institutional repositories", "data providers"]
    source: "wentor-research-plugins"
---

# Repository Harvesting Guide

A skill for harvesting metadata from open access repositories using the OAI-PMH (Open Archives Initiative Protocol for Metadata Harvesting) protocol. Covers protocol fundamentals, building harvesters in Python, handling resumption tokens for large collections, metadata format parsing (Dublin Core, MARC, METS), selective harvesting by date and set, and integrating harvested data into research workflows.

## OAI-PMH Protocol Fundamentals

### What Is OAI-PMH

OAI-PMH is a standardized protocol that allows metadata to be harvested from repository systems. It is the backbone of library interoperability and is supported by virtually every institutional repository, preprint server, and digital library worldwide.

```
OAI-PMH Architecture:

Data Providers (repositories):
  - Expose metadata through a standardized HTTP interface
  - Must support Dublin Core as minimum metadata format
  - May support additional formats (MARC, MODS, DataCite, etc.)
  - Examples: arXiv, PubMed Central, DSpace repositories,
    EPrints, institutional repositories

Service Providers (harvesters):
  - Send HTTP requests to data providers
  - Collect, aggregate, and index metadata
  - Build search services, union catalogs, analytics
  - Examples: BASE (Bielefeld), CORE, OpenDOAR

Protocol Version: 2.0 (current, since 2002)
Transport: HTTP GET or POST
Response format: XML
Base URL example: https://arxiv.org/oai2
```

### Six OAI-PMH Verbs

```
OAI-PMH defines exactly six request types (verbs):

1. Identify
   Purpose: Describe the repository
   URL: baseURL?verb=Identify
   Returns: repository name, admin email, earliest datestamp,
            granularity, compression support

2. ListMetadataFormats
   Purpose: List available metadata formats
   URL: baseURL?verb=ListMetadataFormats
   Returns: format prefixes (oai_dc, marc21, datacite, etc.)
   Optional: identifier parameter to check formats for one record

3. ListSets
   Purpose: List available sets (collections/categories)
   URL: baseURL?verb=ListSets
   Returns: set names and specs for selective harvesting
   Example sets: physics:hep-th, cs:AI, math:AG

4. ListIdentifiers
   Purpose: List record identifiers (headers only, no metadata)
   URL: baseURL?verb=ListIdentifiers&metadataPrefix=oai_dc
   Optional: from, until, set parameters
   Returns: identifiers, datestamps, set memberships

5. ListRecords
   Purpose: Harvest full metadata records
   URL: baseURL?verb=ListRecords&metadataPrefix=oai_dc
   Optional: from, until, set parameters
   Returns: complete metadata records in requested format

6. GetRecord
   Purpose: Retrieve a single record by identifier
   URL: baseURL?verb=GetRecord&identifier=oai:arxiv:2301.00001
         &metadataPrefix=oai_dc
   Returns: one complete metadata record
```

## Building a Harvester in Python

### Basic Harvester

```python
import requests
import xml.etree.ElementTree as ET
import time

OAI_NS = "http://www.openarchives.org/OAI/2.0/"
DC_NS = "http://purl.org/dc/elements/1.1/"

def harvest_records(base_url, metadata_prefix="oai_dc",
                    from_date=None, until_date=None,
                    set_spec=None):
    """
    Harvest all records from an OAI-PMH endpoint.
    Handles resumption tokens for paginated results.

    Args:
        base_url: OAI-PMH base URL
        metadata_prefix: metadata format (default: oai_dc)
        from_date: selective harvest start (YYYY-MM-DD)
        until_date: selective harvest end (YYYY-MM-DD)
        set_spec: restrict to a specific set
    """
    params = {
        "verb": "ListRecords",
        "metadataPrefix": metadata_prefix,
    }

    if from_date:
        params["from"] = from_date
    if until_date:
        params["until"] = until_date
    if set_spec:
        params["set"] = set_spec

    all_records = []
    request_count = 0

    while True:
        response = requests.get(base_url, params=params, timeout=30)
        response.raise_for_status()
        request_count += 1

        root = ET.fromstring(response.content)

        # Parse records from this page
        records = root.findall(
            f".//{{{OAI_NS}}}record"
        )

        for record in records:
            parsed = parse_dublin_core(record)
            if parsed:
                all_records.append(parsed)

        # Check for resumption token
        token_elem = root.find(
            f".//{{{OAI_NS}}}resumptionToken"
        )

        if token_elem is not None and token_elem.text:
            params = {
                "verb": "ListRecords",
                "resumptionToken": token_elem.text,
            }
            # Polite delay between requests
            time.sleep(2)
        else:
            break

    print(f"Harvested {len(all_records)} records "
          f"in {request_count} requests")
    return all_records


def parse_dublin_core(record_element):
    """
    Parse a Dublin Core metadata record into a dictionary.
    """
    header = record_element.find(f"{{{OAI_NS}}}header")
    metadata = record_element.find(f"{{{OAI_NS}}}metadata")

    if header is None or metadata is None:
        return None

    # Check if record is deleted
    status = header.get("status", "")
    if status == "deleted":
        return None

    identifier = header.findtext(f"{{{OAI_NS}}}identifier", "")
    datestamp = header.findtext(f"{{{OAI_NS}}}datestamp", "")

    dc = metadata.find(f".//{{{DC_NS}}}../")

    result = {
        "oai_identifier": identifier,
        "datestamp": datestamp,
        "title": find_dc_text(metadata, "title"),
        "creator": find_dc_all(metadata, "creator"),
        "subject": find_dc_all(metadata, "subject"),
        "description": find_dc_text(metadata, "description"),
        "date": find_dc_text(metadata, "date"),
        "type": find_dc_text(metadata, "type"),
        "identifier": find_dc_all(metadata, "identifier"),
        "language": find_dc_text(metadata, "language"),
        "rights": find_dc_text(metadata, "rights"),
    }

    return result


def find_dc_text(metadata, element_name):
    """Find first Dublin Core element text."""
    elem = metadata.find(f".//{{{DC_NS}}}{element_name}")
    return elem.text if elem is not None else ""


def find_dc_all(metadata, element_name):
    """Find all values of a Dublin Core element."""
    elems = metadata.findall(f".//{{{DC_NS}}}{element_name}")
    return [e.text for e in elems if e.text]
```

## Selective Harvesting

### By Date Range

```
Incremental harvesting strategy:

First harvest: Get everything
  from_date = None (or repository's earliestDatestamp)
  until_date = today

Subsequent harvests: Get only new/modified records
  from_date = last_harvest_date
  until_date = today

Date granularity:
  - Day-level: YYYY-MM-DD (most common)
  - Second-level: YYYY-MM-DDThh:mm:ssZ (some repositories)
  - Check the Identify response for supported granularity

Important: OAI-PMH datestamps reflect the date the METADATA
was last modified, not the publication date. A record edited
yesterday to fix a typo will appear in a harvest with
from=yesterday, even if the paper was published in 2015.
```

### By Set (Collection)

```
Common set structures by repository type:

arXiv:
  physics, physics:hep-th, cs, cs:AI, math, math:AG, etc.

DSpace repositories:
  com_12345_1 (community), col_12345_2 (collection)
  Hierarchical: department -> collection

PubMed Central:
  By journal: pmc-journal-name
  By funder: pmc-funder-name

Strategy:
  1. Call ListSets to see available sets
  2. Identify sets relevant to your research topic
  3. Harvest only those sets to reduce data volume
  4. Store the set membership for each record
```

## Data Quality and Deduplication

### Common Quality Issues

```
Quality problems in harvested metadata:

1. Duplicate records:
   - Same paper in multiple repositories
   - Same paper in multiple sets within one repository
   - Solution: Deduplicate by DOI, then by title similarity

2. Incomplete metadata:
   - Missing abstracts (very common)
   - Missing author identifiers
   - Missing dates or using inconsistent date formats
   - Solution: Enrich with Crossref or OpenAlex lookups

3. Encoding issues:
   - Non-UTF-8 characters in older repositories
   - HTML entities in text fields
   - Solution: Normalize encoding, strip HTML tags

4. Inconsistent formats:
   - Dates as "2023", "2023-01", "2023-01-15", "January 2023"
   - Author names as "Smith, John" vs "John Smith" vs "J. Smith"
   - Solution: Parse and normalize to canonical formats
```

## Notable OAI-PMH Endpoints

```
Major repositories with OAI-PMH support:

arXiv:          https://export.arxiv.org/oai2
PubMed Central: https://www.ncbi.nlm.nih.gov/pmc/oai/oai.cgi
Europeana:      https://oai.europeana.eu/oai
HAL (France):   https://api.archives-ouvertes.fr/oai/hal
DBLP:           https://dblp.org/oai
CiteSeerX:      https://citeseerx.ist.psu.edu/oai2

To find more endpoints:
  - OpenDOAR directory: https://v2.sherpa.ac.uk/opendoar/
  - ROAR (Registry of Open Access Repositories)
  - BASE (Bielefeld Academic Search Engine) source list
```

OAI-PMH harvesting remains the most reliable method for building comprehensive metadata collections from open repositories. While newer APIs like ResourceSync and Signposting offer richer functionality, OAI-PMH's universal adoption and simplicity make it the practical choice for most academic metadata collection tasks.
