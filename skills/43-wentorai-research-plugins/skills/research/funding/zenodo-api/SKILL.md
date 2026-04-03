---
name: zenodo-api
description: "Open research repository for all disciplines"
metadata:
  openclaw:
    emoji: "🔍"
    category: "research"
    subcategory: "funding"
    keywords: ["open data", "data sharing", "data archiving", "FAIR data principles"]
    source: "https://developers.zenodo.org/"
    requires:
      env: ["ZENODO_API_TOKEN"]
---

# Zenodo API Guide

## Overview

Zenodo is an open-access digital repository developed by CERN and funded by the European Commission. It enables researchers to deposit datasets, software, publications, reports, and any other research-related digital artifacts. Zenodo assigns each upload a DOI, ensuring long-term citability and discoverability of research outputs across all academic disciplines.

The Zenodo API provides programmatic access to the full repository, including the ability to search records, retrieve metadata, create depositions, upload files, and manage communities. It follows FAIR data principles (Findable, Accessible, Interoperable, Reusable) and integrates with GitHub for automatic software archiving.

Researchers, data librarians, and research infrastructure teams use the Zenodo API to automate data publishing workflows, build data discovery tools, integrate archiving into CI/CD pipelines, and harvest metadata for institutional repositories. Zenodo supports versioning, access controls, and rich metadata schemas including DataCite Metadata Schema.

## Authentication

Authentication is required for most write operations and for accessing restricted records. Zenodo uses personal access tokens.

1. Create an account at https://zenodo.org/
2. Navigate to **Settings** > **Applications** > **Personal access tokens**
3. Generate a token with appropriate scopes (`deposit:write`, `deposit:actions`)
4. Include the token in requests via the `access_token` query parameter or `Authorization` header

```bash
# Query parameter method
curl "https://zenodo.org/api/records?access_token=YOUR_TOKEN"

# Header method
curl -H "Authorization: Bearer YOUR_TOKEN" "https://zenodo.org/api/records"
```

Read-only access to public records does not require authentication, but authenticated requests have higher rate limits.

## Core Endpoints

### records: Search and Retrieve Records

Search the Zenodo repository for published records including datasets, software, publications, and other artifacts.

- **URL**: `GET https://zenodo.org/api/records`
- **Parameters**:

| Parameter   | Type   | Required | Description                                          |
|-------------|--------|----------|------------------------------------------------------|
| q           | string | No       | Search query (Elasticsearch syntax)                  |
| type        | string | No       | Record type: `dataset`, `software`, `publication`    |
| communities | string | No       | Filter by community identifier                       |
| sort        | string | No       | Sort order: `bestmatch`, `mostrecent`                |
| size        | int    | No       | Number of results per page (default 10, max 9999)    |
| page        | int    | No       | Page number (default 1)                              |

- **Example**:

```bash
curl "https://zenodo.org/api/records?q=climate+change&type=dataset&sort=mostrecent&size=5"
```

- **Response**: Returns `hits` object containing `total` count and array of record objects with `id`, `doi`, `metadata` (title, creators, description, keywords, publication_date), `files` (download links), and `links`.

### depositions: Create and Manage Uploads

Create new depositions to upload research data and software to Zenodo.

- **URL**: `GET https://zenodo.org/api/deposit/depositions`
- **Parameters**:

| Parameter    | Type   | Required | Description                                     |
|--------------|--------|----------|-------------------------------------------------|
| access_token | string | Yes      | Personal access token                           |
| q            | string | No       | Search within your depositions                  |
| sort         | string | No       | Sort order: `bestmatch`, `mostrecent`           |
| size         | int    | No       | Results per page                                |

- **Example**:

```bash
# List your depositions
curl "https://zenodo.org/api/deposit/depositions?access_token=YOUR_TOKEN"

# Create a new deposition
curl -X POST "https://zenodo.org/api/deposit/depositions?access_token=YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"metadata": {"title": "My Dataset", "upload_type": "dataset", "description": "Sample dataset", "creators": [{"name": "Doe, Jane"}]}}'
```

- **Response**: Returns deposition object with `id`, `metadata`, `state`, `submitted`, `links` (including bucket URL for file uploads), and `files`.

## Rate Limits

Rate limits vary based on authentication status. Authenticated requests receive higher limits than anonymous requests. Zenodo does not publicly document exact rate limit numbers, but typical guidance is to keep requests under 60 per minute for anonymous access and 100 per minute for authenticated access. The API returns standard HTTP 429 responses when limits are exceeded, with a `Retry-After` header indicating when to retry.

## Common Patterns

### Search for Datasets by Topic

Find openly available datasets in a specific research domain:

```python
import requests

params = {
    "q": "machine learning genomics",
    "type": "dataset",
    "sort": "mostrecent",
    "size": 20
}
resp = requests.get("https://zenodo.org/api/records", params=params)
data = resp.json()

for hit in data["hits"]["hits"]:
    meta = hit["metadata"]
    print(f"{meta['title']} | DOI: {hit['doi']} | Date: {meta['publication_date']}")
```

### Archive a GitHub Repository

Zenodo integrates with GitHub to automatically archive releases. You can also deposit programmatically:

```python
import requests

TOKEN = os.environ["ZENODO_API_TOKEN"]
headers = {"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json"}

# Step 1: Create empty deposition
dep = requests.post("https://zenodo.org/api/deposit/depositions",
                     headers=headers, json={}).json()

# Step 2: Upload file to the bucket
bucket_url = dep["links"]["bucket"]
with open("analysis_code.zip", "rb") as f:
    requests.put(f"{bucket_url}/analysis_code.zip",
                 headers={"Authorization": f"Bearer {TOKEN}"},
                 data=f)

# Step 3: Add metadata and publish
metadata = {
    "metadata": {
        "title": "Analysis Code for Paper XYZ",
        "upload_type": "software",
        "description": "Reproducible analysis pipeline.",
        "creators": [{"name": "Doe, Jane", "affiliation": "University X"}]
    }
}
requests.put(f"https://zenodo.org/api/deposit/depositions/{dep['id']}",
             headers=headers, json=metadata)
requests.post(f"https://zenodo.org/api/deposit/depositions/{dep['id']}/actions/publish",
              headers={"Authorization": f"Bearer {TOKEN}"})
```

### Harvest Community Records

Retrieve all records from a specific Zenodo community for institutional tracking:

```bash
curl "https://zenodo.org/api/records?communities=astronomy&size=100&sort=mostrecent"
```

## References

- Official API documentation: https://developers.zenodo.org/
- Zenodo homepage: https://zenodo.org/
- GitHub integration guide: https://guides.github.com/activities/citable-code/
- DataCite Metadata Schema: https://schema.datacite.org/
