---
name: zotero-api
description: "Reference management library and collections API"
metadata:
  openclaw:
    emoji: "🔍"
    category: "writing"
    subcategory: "citation"
    keywords: ["reference management", "citation management", "bibliography organization", "literature import"]
    source: "https://www.zotero.org/support/dev/web_api/v3/basics"
---

# Zotero API Guide

## Overview

Zotero is a free, open-source reference management software designed to help researchers collect, organize, cite, and share bibliographic references. The Zotero Web API provides programmatic access to user and group libraries stored on Zotero servers, enabling integration with research workflows, automated bibliography management, and custom tool development.

The API supports reading and writing items (books, journal articles, conference papers, web pages, and dozens of other item types), organizing items into collections, managing tags, retrieving attachment metadata, and accessing shared group libraries. It follows RESTful conventions and supports JSON and Atom response formats, making it straightforward to integrate with existing research infrastructure.

Researchers, librarians, research software developers, and digital humanities scholars use the Zotero API to build literature review tools, automate citation workflows, synchronize reference libraries across platforms, generate bibliographies programmatically, and create custom research management dashboards. The API is particularly popular in digital humanities projects where large bibliographic datasets need programmatic manipulation.

## Authentication

Authentication is optional for reading public libraries but required for accessing private libraries and all write operations. Zotero uses API keys for authentication.

1. Log in to your Zotero account at https://www.zotero.org/
2. Navigate to https://www.zotero.org/settings/keys
3. Create a new API key with appropriate permissions (read/write access to personal or group libraries)
4. Include the key in the `Zotero-API-Key` header

```bash
# Authenticated request
curl -H "Zotero-API-Key: YOUR_API_KEY" "https://api.zotero.org/users/USER_ID/items"

# Public group library (no auth needed)
curl "https://api.zotero.org/groups/GROUP_ID/items"
```

Your user ID can be found at https://www.zotero.org/settings/keys alongside your API key settings.

## Core Endpoints

### users/{id}/items: User Library Items

Retrieve, search, and manage items in a user's personal Zotero library.

- **URL**: `GET https://api.zotero.org/users/{userID}/items`
- **Parameters**:

| Parameter  | Type   | Required | Description                                              |
|------------|--------|----------|----------------------------------------------------------|
| userID     | int    | Yes      | Zotero user ID (in URL path)                             |
| q          | string | No       | Quick search query (searches title, creator, year)       |
| qmode      | string | No       | Search mode: `titleCreatorYear` or `everything`          |
| itemType   | string | No       | Filter by type: `journalArticle`, `book`, `conferencePaper`, etc. |
| tag        | string | No       | Filter by tag (can be repeated for multiple tags)        |
| sort       | string | No       | Sort field: `dateAdded`, `dateModified`, `title`, `creator` |
| direction  | string | No       | Sort direction: `asc` or `desc`                          |
| limit      | int    | No       | Results per request (default 25, max 100)                |
| start      | int    | No       | Pagination offset                                        |
| format     | string | No       | Response format: `json` (default), `atom`, `bib`, `keys` |

- **Example**:

```bash
# Get all journal articles tagged "machine learning"
curl -H "Zotero-API-Key: YOUR_KEY" \
  "https://api.zotero.org/users/12345/items?itemType=journalArticle&tag=machine+learning&format=json"

# Search for items by keyword
curl -H "Zotero-API-Key: YOUR_KEY" \
  "https://api.zotero.org/users/12345/items?q=neural+networks&format=json"
```

- **Response**: Returns array of item objects, each containing `key`, `version`, `data` (with `itemType`, `title`, `creators`, `abstractNote`, `date`, `DOI`, `url`, `tags`, `collections`, `relations`), and `links`.

### groups/{id}/items: Group Library Items

Access items in shared group libraries, which are commonly used for collaborative research projects and reading groups.

- **URL**: `GET https://api.zotero.org/groups/{groupID}/items`
- **Parameters**:

| Parameter | Type   | Required | Description                                         |
|-----------|--------|----------|-----------------------------------------------------|
| groupID   | int    | Yes      | Zotero group ID (in URL path)                       |
| q         | string | No       | Quick search query                                  |
| itemType  | string | No       | Filter by item type                                 |
| tag       | string | No       | Filter by tag                                       |
| sort      | string | No       | Sort field                                          |
| limit     | int    | No       | Results per request (max 100)                       |
| start     | int    | No       | Pagination offset                                   |
| format    | string | No       | Response format: `json`, `atom`, `bib`, `keys`      |

- **Example**:

```bash
# List items in a public group library
curl "https://api.zotero.org/groups/67890/items?format=json&limit=50"

# Get formatted bibliography from a group
curl "https://api.zotero.org/groups/67890/items?format=bib&style=apa"
```

- **Response**: Same structure as user library items. Group items may include additional access control metadata depending on the group's privacy settings.

## Rate Limits

No strict rate limits are enforced, but Zotero asks users to limit requests to a reasonable rate. The API uses conditional requests via `If-Modified-Since-Version` headers for efficient synchronization. Responses include a `Last-Modified-Version` header that should be stored and used in subsequent requests to only retrieve changed items. Batch operations are supported for creating/updating multiple items in a single request (up to 50 items per write request).

## Common Patterns

### Export a Bibliography in a Specific Citation Style

Generate a formatted bibliography from a Zotero collection:

```python
import requests

headers = {"Zotero-API-Key": "YOUR_KEY"}

# Get items formatted as APA bibliography
resp = requests.get(
    "https://api.zotero.org/users/12345/collections/ABCDEF/items",
    headers=headers,
    params={"format": "bib", "style": "apa", "limit": 100}
)
print(resp.text)
```

### Sync Library Items to a Custom Database

Efficiently synchronize Zotero items using version tracking:

```python
import requests

headers = {"Zotero-API-Key": "YOUR_KEY"}
last_version = 0  # Store this between syncs

resp = requests.get(
    "https://api.zotero.org/users/12345/items",
    headers={**headers, "If-Modified-Since-Version": str(last_version)},
    params={"format": "json", "limit": 100}
)

if resp.status_code == 200:
    items = resp.json()
    last_version = resp.headers["Last-Modified-Version"]
    for item in items:
        print(f"Updated: {item['data'].get('title', 'No title')} (v{item['version']})")
elif resp.status_code == 304:
    print("No changes since last sync")
```

### Analyze Research Library by Tag Distribution

Explore the thematic distribution of a research library:

```python
import requests
from collections import Counter

headers = {"Zotero-API-Key": "YOUR_KEY"}

resp = requests.get(
    "https://api.zotero.org/users/12345/items",
    headers=headers,
    params={"format": "json", "limit": 100, "itemType": "journalArticle"}
)

tag_counts = Counter()
for item in resp.json():
    for tag in item["data"].get("tags", []):
        tag_counts[tag["tag"]] += 1

for tag, count in tag_counts.most_common(20):
    print(f"  {tag}: {count}")
```

## References

- Official Web API documentation: https://www.zotero.org/support/dev/web_api/v3/basics
- API key management: https://www.zotero.org/settings/keys
- Item types and fields: https://api.zotero.org/itemTypes
- Zotero homepage: https://www.zotero.org/
- Citation styles: https://www.zotero.org/styles
