---
name: software-heritage-api
description: "Archive and retrieve source code history via Software Heritage API"
metadata:
  openclaw:
    emoji: "💾"
    category: "domains"
    subcategory: "cs"
    keywords: ["Software Heritage", "code archive", "source code preservation", "SWHID", "code provenance", "open source"]
    source: "https://www.softwareheritage.org/"
---

# Software Heritage API

## Overview

Software Heritage is the universal archive of software source code, preserving 18B+ source files from 280M+ software origins (GitHub, GitLab, Bitbucket, CRAN, PyPI, Debian, etc.). Each artifact receives a persistent SWHID (SoftWare Heritage IDentifier) for reliable citation in research. The API enables code search, provenance tracking, and historical analysis. Free, no authentication for read access.

## API Endpoints

### Base URL

```
https://archive.softwareheritage.org/api/1
```

### Search Origins (Repositories)

```bash
# Search for repositories
curl "https://archive.softwareheritage.org/api/1/origin/search/scikit-learn/?limit=10"

# Get origin metadata
curl "https://archive.softwareheritage.org/api/1/origin/https://github.com/scikit-learn/scikit-learn/get/"

# List visits (snapshots) of an origin
curl "https://archive.softwareheritage.org/api/1/origin/https://github.com/scikit-learn/scikit-learn/visits/"
```

### Retrieve Content

```bash
# Get a specific file by its SHA1 hash
curl "https://archive.softwareheritage.org/api/1/content/sha1:adc83b19e793491b1c6ea0fd8b46cd9f32e592fc/"

# Get raw file content
curl "https://archive.softwareheritage.org/api/1/content/sha1:adc83b19e793491b1c6ea0fd8b46cd9f32e592fc/raw/"

# Get directory listing
curl "https://archive.softwareheritage.org/api/1/directory/{sha1_git}/"
```

### Resolve SWHIDs

```bash
# Resolve a SWHID to its object
curl "https://archive.softwareheritage.org/api/1/resolve/swh:1:cnt:adc83b19e793491b1c6ea0fd8b46cd9f32e592fc/"

# Get snapshot
curl "https://archive.softwareheritage.org/api/1/snapshot/{sha1_git}/"

# Get revision (commit)
curl "https://archive.softwareheritage.org/api/1/revision/{sha1_git}/"
```

### Save Code Now

```bash
# Request archival of a repository
curl -X POST "https://archive.softwareheritage.org/api/1/origin/save/git/url/https://github.com/user/repo/"
```

## SWHID Format

SoftWare Heritage persistent IDentifiers:

```
swh:1:{type}:{hash}

Types:
  cnt  → Content (file)
  dir  → Directory
  rev  → Revision (commit)
  rel  → Release (tag)
  snp  → Snapshot

Examples:
  swh:1:cnt:94a9ed024d3859793618152ea559a168bbcbb5e2  (file)
  swh:1:rev:309cf2674ee7a0749978cf8265ab91a60aea0f7d  (commit)
  swh:1:snp:c7c108084bc0bf3d81436bf980b46e98571c7b17  (snapshot)

With qualifiers:
  swh:1:cnt:{hash};origin=https://github.com/user/repo;visit=swh:1:snp:{hash};path=/src/main.py
```

## Python Usage

```python
import requests
import time

BASE_URL = "https://archive.softwareheritage.org/api/1"


def search_origins(query: str, limit: int = 10) -> list:
    """Search Software Heritage for archived repositories."""
    resp = requests.get(
        f"{BASE_URL}/origin/search/{query}/",
        params={"limit": limit},
        timeout=30,
    )
    resp.raise_for_status()
    return [
        {
            "url": o.get("url"),
            "has_visits": o.get("has_visits"),
        }
        for o in resp.json()
    ]


def get_origin_visits(origin_url: str) -> list:
    """Get archival snapshots for a repository."""
    resp = requests.get(
        f"{BASE_URL}/origin/{origin_url}/visits/",
        timeout=30,
    )
    resp.raise_for_status()
    return [
        {
            "date": v.get("date"),
            "status": v.get("status"),
            "snapshot": v.get("snapshot"),
            "type": v.get("type"),
        }
        for v in resp.json()
    ]


def get_directory(sha1_git: str) -> list:
    """List files in an archived directory."""
    resp = requests.get(
        f"{BASE_URL}/directory/{sha1_git}/",
        timeout=30,
    )
    resp.raise_for_status()
    return [
        {
            "name": entry.get("name"),
            "type": entry.get("type"),
            "target": entry.get("target"),
        }
        for entry in resp.json()
    ]


def save_code_now(repo_url: str) -> dict:
    """Request Software Heritage to archive a repository."""
    resp = requests.post(
        f"{BASE_URL}/origin/save/git/url/{repo_url}/",
        timeout=30,
    )
    resp.raise_for_status()
    return resp.json()


# Example: find archived ML frameworks
origins = search_origins("pytorch", limit=5)
for o in origins:
    print(f"Archived: {o['url']}")

# Example: get snapshot history
visits = get_origin_visits("https://github.com/pytorch/pytorch")
for v in visits[:5]:
    print(f"[{v['date'][:10]}] {v['status']} — {v['type']}")

# Example: request archival
# result = save_code_now("https://github.com/my-org/my-research-code")
# print(f"Save request: {result['save_request_status']}")
```

## Use Cases

1. **Code citation**: Cite specific code versions in papers using SWHIDs
2. **Reproducibility**: Archive the exact code used in experiments
3. **Provenance tracking**: Trace code evolution and authorship
4. **Software archaeology**: Study historical codebases
5. **Compliance**: Ensure open-source license compliance through archival

## Rate Limits

- Unauthenticated: 120 requests/hour
- Authenticated (free token): 1200 requests/hour

## References

- [Software Heritage](https://www.softwareheritage.org/)
- [API Documentation](https://archive.softwareheritage.org/api/)
- [SWHID Specification](https://docs.softwareheritage.org/devel/swh-model/persistent-identifiers.html)
- Di Cosmo, R. & Zacchiroli, S. (2017). "Software Heritage: Why and How to Preserve Software Source Code." *iPRES 2017*.
