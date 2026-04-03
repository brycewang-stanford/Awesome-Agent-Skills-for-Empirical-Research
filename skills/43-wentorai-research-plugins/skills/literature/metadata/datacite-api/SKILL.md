---
name: datacite-api
description: "Resolve dataset DOIs and query research data metadata via DataCite"
metadata:
  openclaw:
    emoji: "🔍"
    category: "literature"
    subcategory: "metadata"
    keywords: ["DOI resolution", "digital object identifier", "FAIR data principles", "data sharing"]
    source: "https://support.datacite.org/docs/api"
---

# DataCite API Guide

## Overview

DataCite is a leading global DOI registration agency focused on research data. While CrossRef primarily handles DOIs for publications, DataCite specializes in assigning persistent identifiers to datasets, software, samples, instruments, and other research outputs. DataCite has registered over 50 million DOIs from thousands of data repositories worldwide.

The DataCite REST API provides access to metadata for all DataCite DOIs. It is essential for researchers and developers working with research data discovery, data citation, FAIR (Findable, Accessible, Interoperable, Reusable) data practices, and repository integration. The metadata follows the DataCite Metadata Schema, which is designed specifically for describing research data and includes fields for resource types, funding references, geolocation, and related identifiers.

The API is free, open, and requires no authentication. It returns JSON responses following the JSON:API specification, with robust filtering, faceting, and pagination support.

## Authentication

No authentication required. The DataCite API is fully open and free to use. No API key, registration, or email is needed. For write operations (DOI registration and metadata updates), authentication via DataCite member credentials is required, but read-only access is completely open.

## Core Endpoints

### DOIs: Search and Retrieve Dataset Metadata

- **URL**: `GET https://api.datacite.org/dois`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | query | string | No | Full-text search query |
  | resource-type-id | string | No | Filter by resource type (dataset, software, text, etc.) |
  | affiliation-id | string | No | Filter by creator affiliation ROR ID |
  | registered | string | No | Filter by registration year (e.g., 2024) |
  | page[size] | integer | No | Results per page (default: 25, max: 1000) |
  | page[number] | integer | No | Page number for pagination |
  | sort | string | No | Sort field: relevance, created, -created, updated |
- **Example**:
  ```bash
  curl "https://api.datacite.org/dois?query=climate+change+dataset&resource-type-id=dataset&page[size]=10&sort=-created"
  ```
- **Response**: JSON:API formatted response with `data` array containing DOI records. Each record has `attributes` with `doi`, `titles`, `creators`, `publisher`, `publicationYear`, `resourceType`, `descriptions`, `subjects`, `dates`, `relatedIdentifiers`, `fundingReferences`, and `geoLocations`.

### Single DOI: Direct Lookup

- **URL**: `GET https://api.datacite.org/dois/{doi}`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | doi | string | Yes | The full DOI (e.g., 10.5281/zenodo.1234567) |
- **Example**:
  ```bash
  curl "https://api.datacite.org/dois/10.5281/zenodo.3678171"
  ```
- **Response**: JSON:API response with complete metadata for the specified DOI, including all DataCite Metadata Schema fields.

### Providers: Data Repository Information

- **URL**: `GET https://api.datacite.org/providers`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | query | string | No | Search provider name or description |
  | region | string | No | Filter by region (e.g., EMEA, Americas, Asia Pacific) |
  | page[size] | integer | No | Results per page |
- **Example**:
  ```bash
  curl "https://api.datacite.org/providers?query=CERN&page[size]=5"
  ```
- **Response**: JSON:API response with provider records including `name`, `displayName`, `region`, `memberType`, `website`, and associated repositories and DOI prefixes.

### Clients: Repository Details

- **URL**: `GET https://api.datacite.org/clients`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | query | string | No | Search repository name |
  | provider-id | string | No | Filter by provider |
  | software | string | No | Filter by repository software (e.g., dspace, dataverse) |
  | page[size] | integer | No | Results per page |
- **Example**:
  ```bash
  curl "https://api.datacite.org/clients?query=zenodo&page[size]=5"
  ```
- **Response**: JSON:API response with repository records including name, DOI count, and service details.

## Rate Limits

No published rate limits. DataCite does not enforce strict API quotas for read access. However, the service is operated by a nonprofit organization, so users should implement reasonable request pacing. For large-scale data mining, use the DataCite OAI-PMH endpoint or the public data file available at https://datafiles.datacite.org. Sustained high-volume requests may be throttled without notice.

## Common Patterns

### Discover Datasets for a Research Topic

Find published datasets related to a research area:

```bash
curl -s "https://api.datacite.org/dois?query=CRISPR+genome+editing&resource-type-id=dataset&page[size]=5&sort=-created" | jq '.data[] | {doi: .attributes.doi, title: .attributes.titles[0].title, year: .attributes.publicationYear, publisher: .attributes.publisher}'
```

### Find Software Citations

Search for research software registered with DataCite:

```bash
curl -s "https://api.datacite.org/dois?query=python+machine+learning&resource-type-id=software&page[size]=10" | jq '.data[] | {doi: .attributes.doi, title: .attributes.titles[0].title, year: .attributes.publicationYear}'
```

### Link Datasets to Publications

Use related identifiers to find papers associated with a dataset:

```bash
curl -s "https://api.datacite.org/dois/10.5281/zenodo.3678171" | jq '.data.attributes.relatedIdentifiers[] | select(.relationType == "IsSupplementTo" or .relationType == "IsReferencedBy") | {type: .relationType, id: .relatedIdentifier}'
```

## References

- Official documentation: https://support.datacite.org/docs/api
- DataCite Metadata Schema: https://schema.datacite.org/
- JSON:API specification: https://jsonapi.org/
