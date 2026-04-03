---
name: figshare-api
description: "Research data sharing and repository"
metadata:
  openclaw:
    emoji: "🔍"
    category: "research"
    subcategory: "funding"
    keywords: ["open data", "data sharing", "data archiving", "FAIR data principles", "open source code"]
    source: "https://docs.figshare.com/"
    requires:
      env: ["FIGSHARE_API_TOKEN"]
---

# Figshare API Guide

## Overview

Figshare is a cloud-based research data management platform that allows researchers to store, share, and discover research outputs including datasets, figures, media, papers, posters, and fileset collections. Every item uploaded to Figshare receives a citable DOI and is stored in a FAIR-compliant manner, making research outputs findable, accessible, interoperable, and reusable.

The Figshare API provides comprehensive programmatic access to the repository, enabling researchers and institutions to automate data publishing, integrate with research workflows, and build custom discovery interfaces. The platform supports versioning, embargo periods, and flexible access controls for both public and private research data.

Researchers, data managers, institutional repository administrators, and research infrastructure developers use the Figshare API to automate deposit workflows, harvest metadata for institutional dashboards, build data discovery tools, and integrate research data management into existing laboratory information management systems. Figshare serves over 150 institutions worldwide and hosts millions of research outputs.

## Authentication

Authentication via personal access token is required for write operations and accessing private content. Read access to public content is available without authentication but has lower rate limits.

1. Log in to Figshare at https://figshare.com/
2. Navigate to **Applications** in your account settings
3. Create a **Personal Token** with desired permissions
4. Include the token in the `Authorization` header

```bash
curl -H "Authorization: token YOUR_FIGSHARE_TOKEN" "https://api.figshare.com/v2/account/articles"
```

Public endpoints can be accessed without a token for browsing published content.

## Core Endpoints

### articles: Search and Retrieve Articles

Search the public Figshare repository for published articles (datasets, figures, papers, media, and other item types).

- **URL**: `GET https://api.figshare.com/v2/articles`
- **Parameters**:

| Parameter      | Type   | Required | Description                                            |
|----------------|--------|----------|--------------------------------------------------------|
| search_for     | string | No       | Free-text search query                                 |
| item_type      | int    | No       | Item type filter (1=figure, 2=media, 3=dataset, etc.)  |
| published_since| string | No       | Filter by date (YYYY-MM-DD format)                     |
| order          | string | No       | Sort: `published_date`, `modified_date`, `views`       |
| order_direction| string | No       | `asc` or `desc`                                        |
| page           | int    | No       | Page number (default 1)                                |
| page_size      | int    | No       | Results per page (default 10, max 1000)                |

- **Example**:

```bash
curl -X POST "https://api.figshare.com/v2/articles/search" \
  -H "Content-Type: application/json" \
  -d '{"search_for": "genomics CRISPR", "item_type": 3, "page_size": 5}'
```

- **Response**: Returns array of article objects with `id`, `title`, `doi`, `url`, `published_date`, `description`, `defined_type_name`, `categories`, `tags`, `authors`, `files` (with download URLs), and `citation`.

### datasets: Manage Research Datasets

Retrieve and manage dataset-specific content in Figshare. Datasets are a specialized article type with additional support for large file collections.

- **URL**: `GET https://api.figshare.com/v2/articles/{article_id}`
- **Parameters**:

| Parameter  | Type | Required | Description                        |
|------------|------|----------|------------------------------------|
| article_id | int  | Yes      | The Figshare article/dataset ID    |

- **Example**:

```bash
# Get a specific dataset by ID
curl "https://api.figshare.com/v2/articles/12345678"

# List files in a dataset
curl "https://api.figshare.com/v2/articles/12345678/files"
```

- **Response**: Returns complete article object with `id`, `title`, `doi`, `description`, `authors`, `categories`, `tags`, `files` (array with `name`, `size`, `download_url`, `computed_md5`), `license`, `version`, `is_embargoed`, and `custom_fields`.

## Rate Limits

Rate limits vary based on authentication status and endpoint. Authenticated requests generally allow up to 100 requests per minute. Unauthenticated requests are limited to approximately 10 requests per minute. The API returns HTTP 429 with a `Retry-After` header when limits are exceeded. For bulk data harvesting, Figshare provides OAI-PMH endpoints at `https://api.figshare.com/v2/oai` which are more suitable for large-scale metadata collection.

## Common Patterns

### Search for Datasets in a Research Area

Find publicly available datasets matching specific research topics:

```python
import requests

payload = {
    "search_for": "single cell RNA-seq",
    "item_type": 3,  # datasets only
    "page_size": 20,
    "order": "published_date",
    "order_direction": "desc"
}

resp = requests.post("https://api.figshare.com/v2/articles/search", json=payload)
results = resp.json()

for item in results:
    print(f"{item['title']}")
    print(f"  DOI: {item['doi']}")
    print(f"  Published: {item['published_date']}")
    print()
```

### Upload a Dataset Programmatically

Automate data deposit for reproducible research workflows:

```python
import requests

TOKEN = os.environ["FIGSHARE_API_TOKEN"]
headers = {"Authorization": f"token {TOKEN}", "Content-Type": "application/json"}

# Step 1: Create a new article
article_data = {
    "title": "Supplementary Data for Analysis of Gene Expression",
    "defined_type": "dataset",
    "description": "RNA-seq counts and metadata for the analysis.",
    "tags": ["RNA-seq", "gene expression"],
    "categories": [69]  # Genetics category
}
resp = requests.post("https://api.figshare.com/v2/account/articles",
                     headers=headers, json=article_data)
article_url = resp.json()["location"]

# Step 2: Upload file
article = requests.get(article_url, headers=headers).json()
print(f"Created article ID: {article['id']}, DOI will be assigned on publish")
```

### Harvest Institutional Outputs via OAI-PMH

Collect metadata from all Figshare items in an institution's repository:

```bash
curl "https://api.figshare.com/v2/oai?verb=ListRecords&metadataPrefix=oai_dc&set=institution_123"
```

## References

- Official API documentation: https://docs.figshare.com/
- Figshare homepage: https://figshare.com/
- API endpoint reference: https://docs.figshare.com/#figshare_documentation_api_description
- OAI-PMH endpoint: https://docs.figshare.com/#oai_pmh
