---
name: orcid-api
description: "Look up researcher profiles and academic identities via the ORCID registry"
metadata:
  openclaw:
    emoji: "🔍"
    category: "literature"
    subcategory: "metadata"
    keywords: ["researcher ID", "ORCID", "academic identity", "academic metrics"]
    source: "https://info.orcid.org/documentation/api-tutorial/"
    requires:
      env: ["ORCID_ACCESS_TOKEN"]
---

# ORCID API Guide

## Overview

ORCID (Open Researcher and Contributor ID) is a nonprofit organization that provides unique, persistent digital identifiers to researchers worldwide. With over 18 million registered researchers, ORCID has become the standard for disambiguating author identities across the scholarly ecosystem. Publishers, funders, and institutions use ORCID to reliably connect researchers with their works, grants, and affiliations.

The ORCID Public API provides read access to public data in ORCID records. This includes biographical information, employment history, education, works (publications), funding, and peer review activities. The API is essential for building research information systems, verifying researcher identities, and integrating with institutional repositories.

Authentication is required. The public API uses OAuth 2.0 with a client credentials grant, which provides a bearer token for read-only access to public data. Registration is free and tokens can be obtained programmatically.

## Authentication

The ORCID Public API requires an OAuth 2.0 access token. Register for free API credentials at https://orcid.org/developer-tools and obtain a token:

```bash
curl -X POST "https://orcid.org/oauth/token" \
  -H "Accept: application/json" \
  -d "client_id=YOUR_CLIENT_ID" \
  -d "client_secret=YOUR_CLIENT_SECRET" \
  -d "grant_type=client_credentials" \
  -d "scope=/read-public"
```

Include the token in all API requests:

```
Authorization: Bearer YOUR_ACCESS_TOKEN
```

Tokens are long-lived (typically 20 years) and can be reused across sessions.

## Core Endpoints

### Record: Retrieve Full ORCID Profile

- **URL**: `GET https://pub.orcid.org/v3.0/{orcid-id}/record`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | orcid-id | string | Yes | The 16-digit ORCID iD (e.g., 0000-0002-1825-0097) |
  | Accept | header | No | Response format: application/json, application/xml |
- **Example**:
  ```bash
  curl -H "Authorization: Bearer YOUR_TOKEN" \
       -H "Accept: application/json" \
       "https://pub.orcid.org/v3.0/0000-0002-1825-0097/record"
  ```
- **Response**: JSON with complete ORCID record including `person` (name, biography, emails, addresses), `activities-summary` (works, funding, employment, education, peer reviews).

### Works: Retrieve Publication List

- **URL**: `GET https://pub.orcid.org/v3.0/{orcid-id}/works`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | orcid-id | string | Yes | The ORCID iD |
- **Example**:
  ```bash
  curl -H "Authorization: Bearer YOUR_TOKEN" \
       -H "Accept: application/json" \
       "https://pub.orcid.org/v3.0/0000-0002-1825-0097/works"
  ```
- **Response**: JSON with `group` array of work summaries, each containing `title`, `external-ids` (DOI, PMID, etc.), `type`, `publication-date`, and `journal-title`.

### Search: Find Researchers

- **URL**: `GET https://pub.orcid.org/v3.0/search`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | q | string | Yes | Lucene query syntax (e.g., family-name:Einstein, affiliation-org-name:MIT) |
  | start | integer | No | Pagination offset (default: 0) |
  | rows | integer | No | Results per page (default: 100, max: 200) |
- **Example**:
  ```bash
  curl -H "Authorization: Bearer YOUR_TOKEN" \
       -H "Accept: application/json" \
       "https://pub.orcid.org/v3.0/search?q=family-name:Hinton+AND+affiliation-org-name:Toronto&rows=10"
  ```
- **Response**: JSON with `result` array containing `orcid-identifier` (ORCID iD and URI) for each matching researcher.

## Rate Limits

The public API allows 24 requests per second and 40 burst requests. The member API has higher limits. If limits are exceeded, the API returns HTTP 503 with a `Retry-After` header. For bulk data access, ORCID provides annual data dumps and a Lambda file for incremental updates. Rate limits apply per access token.

## Common Patterns

### Verify Researcher Identity

Confirm that a researcher's ORCID is valid and retrieve their public profile:

```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
     -H "Accept: application/json" \
     "https://pub.orcid.org/v3.0/0000-0001-5109-3700/person"
```

### Build a Complete Publication List

Retrieve all works associated with an ORCID profile and extract DOIs:

```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
     -H "Accept: application/json" \
     "https://pub.orcid.org/v3.0/0000-0002-1825-0097/works" | jq '.group[].work-summary[0] | {title: .title.title.value, doi: (.["external-ids"]["external-id"][] | select(.["external-id-type"] == "doi") | .["external-id-value"])}'
```

### Find Researchers at an Institution

Search for ORCID profiles affiliated with a specific organization:

```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
     -H "Accept: application/json" \
     "https://pub.orcid.org/v3.0/search?q=affiliation-org-name:Stanford+AND+current-institution-affiliation-name:Stanford&rows=50"
```

## References

- Official documentation: https://info.orcid.org/documentation/api-tutorial/
- API reference: https://pub.orcid.org/v3.0/
- ORCID integration guide: https://info.orcid.org/documentation/integration-guide/

## See Also

- [orcid-integration-guide](../orcid-integration-guide/SKILL.md) -- Setting up your ORCID profile, publisher/funder integrations, and best practices for maintaining your record.
