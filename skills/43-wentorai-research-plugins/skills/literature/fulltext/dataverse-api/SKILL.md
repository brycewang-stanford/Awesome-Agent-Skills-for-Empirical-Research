---
name: dataverse-api
description: "Deposit and discover research datasets via Harvard Dataverse API"
metadata:
  openclaw:
    emoji: "🗄️"
    category: "literature"
    subcategory: "fulltext"
    keywords: ["Dataverse", "research data", "data repository", "Harvard", "dataset deposit", "data sharing"]
    source: "https://dataverse.org/"
---

# Harvard Dataverse API

## Overview

Dataverse is an open-source research data repository platform developed by Harvard IQSS, hosting 150K+ datasets across 80+ installations worldwide. The Harvard Dataverse alone has 130K+ datasets covering social science, natural science, and humanities. The API supports search, metadata retrieval, file download, and dataset deposit. Free, no authentication for read access.

## API Endpoints

### Base URL

```
https://dataverse.harvard.edu/api
```

### Search

```bash
# Search datasets
curl "https://dataverse.harvard.edu/api/search?q=climate+change&type=dataset&per_page=20"

# Search files within datasets
curl "https://dataverse.harvard.edu/api/search?q=temperature+data&type=file&per_page=20"

# Filter by subject
curl "https://dataverse.harvard.edu/api/search?q=survey+data&type=dataset&\
fq=subject_ss:\"Social Sciences\""

# Filter by publication date
curl "https://dataverse.harvard.edu/api/search?q=genomics&type=dataset&\
fq=dateSort:[2024-01-01T00:00:00Z TO *]"

# Sort by relevance or date
curl "https://dataverse.harvard.edu/api/search?q=machine+learning&type=dataset&\
sort=date&order=desc"
```

### Get Dataset Metadata

```bash
# By persistent ID (DOI)
curl "https://dataverse.harvard.edu/api/datasets/:persistentId/?persistentId=doi:10.7910/DVN/EXAMPLE"

# By dataset ID
curl "https://dataverse.harvard.edu/api/datasets/12345"

# Get dataset versions
curl "https://dataverse.harvard.edu/api/datasets/:persistentId/versions?persistentId=doi:10.7910/DVN/EXAMPLE"
```

### Download Files

```bash
# Download a specific file by ID
curl -O "https://dataverse.harvard.edu/api/access/datafile/67890"

# Download with original format
curl -O "https://dataverse.harvard.edu/api/access/datafile/67890?format=original"

# Download all files in a dataset (as zip)
curl -O "https://dataverse.harvard.edu/api/access/dataset/:persistentId/?persistentId=doi:10.7910/DVN/EXAMPLE"
```

### Query Parameters (Search)

| Parameter | Description | Example |
|-----------|-------------|---------|
| `q` | Search query | `q=voter+turnout` |
| `type` | Item type | `dataset`, `file`, `dataverse` |
| `per_page` | Results per page (max 1000) | `per_page=50` |
| `start` | Pagination offset | `start=50` |
| `sort` | Sort field | `name`, `date` |
| `order` | Sort order | `asc`, `desc` |
| `fq` | Filter query (Solr) | `fq=subject_ss:"Medicine"` |

## Response Structure

```json
{
  "status": "OK",
  "data": {
    "q": "climate change",
    "total_count": 2450,
    "items": [
      {
        "name": "Global Temperature Dataset 2024",
        "type": "dataset",
        "url": "https://doi.org/10.7910/DVN/EXAMPLE",
        "global_id": "doi:10.7910/DVN/EXAMPLE",
        "description": "Monthly global temperature anomalies...",
        "published_at": "2024-03-15",
        "publisher": "Harvard Dataverse",
        "subjects": ["Earth and Environmental Sciences"],
        "fileCount": 12,
        "citation": "Smith, J. (2024). Global Temperature Dataset..."
      }
    ]
  }
}
```

## Python Usage

```python
import requests

BASE_URL = "https://dataverse.harvard.edu/api"


def search_datasets(query: str, per_page: int = 20,
                    subject: str = None) -> list:
    """Search Harvard Dataverse for datasets."""
    params = {
        "q": query,
        "type": "dataset",
        "per_page": per_page,
        "sort": "date",
        "order": "desc",
    }
    if subject:
        params["fq"] = f'subject_ss:"{subject}"'

    resp = requests.get(f"{BASE_URL}/search", params=params)
    resp.raise_for_status()
    data = resp.json()

    results = []
    for item in data.get("data", {}).get("items", []):
        results.append({
            "name": item.get("name"),
            "doi": item.get("global_id"),
            "description": item.get("description", "")[:300],
            "published": item.get("published_at"),
            "subjects": item.get("subjects", []),
            "files": item.get("fileCount", 0),
            "url": item.get("url"),
        })
    return results


def get_dataset_files(doi: str) -> list:
    """List files in a dataset."""
    resp = requests.get(
        f"{BASE_URL}/datasets/:persistentId/",
        params={"persistentId": doi},
    )
    resp.raise_for_status()
    data = resp.json().get("data", {})

    files = []
    version = data.get("latestVersion", {})
    for f in version.get("files", []):
        df = f.get("dataFile", {})
        files.append({
            "id": df.get("id"),
            "filename": df.get("filename"),
            "size": df.get("filesize"),
            "content_type": df.get("contentType"),
            "md5": df.get("md5"),
        })
    return files


def download_file(file_id: int, output_path: str):
    """Download a file from Dataverse."""
    resp = requests.get(
        f"{BASE_URL}/access/datafile/{file_id}",
        stream=True,
    )
    resp.raise_for_status()
    with open(output_path, "wb") as f:
        for chunk in resp.iter_content(chunk_size=8192):
            f.write(chunk)


# Example: find social science datasets
datasets = search_datasets("income inequality",
                           subject="Social Sciences")
for ds in datasets:
    print(f"[{ds['published']}] {ds['name']} ({ds['files']} files)")
    print(f"  DOI: {ds['doi']}")

# Example: list files in a dataset
# files = get_dataset_files("doi:10.7910/DVN/EXAMPLE")
# for f in files:
#     print(f"  {f['filename']} ({f['size']} bytes)")
```

## Other Dataverse Installations

| Installation | URL | Focus |
|-------------|-----|-------|
| Harvard Dataverse | dataverse.harvard.edu | Multi-discipline |
| UNC Dataverse | dataverse.unc.edu | Social science |
| AUSSDA | data.aussda.at | Austrian social science |
| Borealis (Canada) | borealisdata.ca | Canadian research |
| DataverseNL | dataverse.nl | Dutch research |

## References

- [Harvard Dataverse](https://dataverse.harvard.edu/)
- [Dataverse API Guide](https://guides.dataverse.org/en/latest/api/)
- [Dataverse Project](https://dataverse.org/)
- King, G. (2007). "An Introduction to the Dataverse Network." *Sociological Methods & Research* 36(2).
