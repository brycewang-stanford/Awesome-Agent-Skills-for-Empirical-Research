---
name: pangaea-data-api
description: "Access earth and environmental science datasets via PANGAEA API"
metadata:
  openclaw:
    emoji: "🌍"
    category: "domains"
    subcategory: "geoscience"
    keywords: ["PANGAEA", "earth science data", "oceanography", "paleoclimate", "environmental data", "geoscience repository"]
    source: "https://www.pangaea.de/"
---

# PANGAEA Data Repository API

## Overview

PANGAEA is the world's leading data repository for earth and environmental sciences, hosting 400K+ datasets with 20B+ data points. It archives research data from oceanography, paleoclimatology, geology, ecology, and atmospheric science. Each dataset has a DOI and is linked to the originating publication. The API provides search, metadata retrieval, and data download. Free, no authentication required.

## API Endpoints

### Search API

```bash
# Search datasets by keyword
curl "https://www.pangaea.de/advanced/search.php?q=ocean+temperature&count=20&type=json"

# Search with geographic bounding box
curl "https://www.pangaea.de/advanced/search.php?\
q=sediment+core&minlat=-60&maxlat=-30&minlon=-180&maxlon=180&type=json"

# Filter by parameter (measurement type)
curl "https://www.pangaea.de/advanced/search.php?\
q=carbon+dioxide&param=Atmospheric+CO2&type=json"

# Filter by date range
curl "https://www.pangaea.de/advanced/search.php?\
q=Arctic+ice&mindate=2020-01-01&maxdate=2026-12-31&type=json"
```

### ElasticSearch API

```bash
# Full-text search via Elasticsearch
curl -X POST "https://ws.pangaea.de/es/pangaea/panmd/_search" \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "bool": {
        "must": [
          {"match": {"citation.title": "ocean temperature"}}
        ],
        "filter": [
          {"range": {"citation.year": {"gte": 2020}}}
        ]
      }
    },
    "size": 20
  }'
```

### Dataset Access

```bash
# Get dataset metadata
curl "https://doi.pangaea.de/10.1594/PANGAEA.123456?format=metainfo_json"

# Download dataset as tab-delimited text
curl "https://doi.pangaea.de/10.1594/PANGAEA.123456?format=textfile"

# Download as CSV
curl "https://doi.pangaea.de/10.1594/PANGAEA.123456?format=csv"
```

### OAI-PMH Harvesting

```bash
# List records
curl "https://ws.pangaea.de/oai/provider?verb=ListRecords&metadataPrefix=oai_dc"

# Get specific record
curl "https://ws.pangaea.de/oai/provider?verb=GetRecord&identifier=oai:pangaea.de:doi:10.1594/PANGAEA.123456&metadataPrefix=oai_dc"
```

### Query Parameters (Search API)

| Parameter | Description | Example |
|-----------|-------------|---------|
| `q` | Search query | `q=coral+reef+bleaching` |
| `count` | Results per page | `count=50` |
| `offset` | Pagination offset | `offset=20` |
| `minlat/maxlat` | Latitude bounds | `-90` to `90` |
| `minlon/maxlon` | Longitude bounds | `-180` to `180` |
| `mindate/maxdate` | Temporal filter | `2020-01-01` |
| `param` | Parameter/measurement | `Temperature` |
| `topic` | Topic filter | `Atmosphere`, `Biosphere` |
| `type` | Response format | `json`, `xml` |

## Python Usage

```python
import requests
import pandas as pd
from io import StringIO

SEARCH_URL = "https://www.pangaea.de/advanced/search.php"
ES_URL = "https://ws.pangaea.de/es/pangaea/panmd/_search"


def search_pangaea(query: str, count: int = 20,
                   bbox: dict = None) -> list:
    """Search PANGAEA for earth science datasets."""
    params = {"q": query, "count": count, "type": "json"}
    if bbox:
        params.update({
            "minlat": bbox.get("south", -90),
            "maxlat": bbox.get("north", 90),
            "minlon": bbox.get("west", -180),
            "maxlon": bbox.get("east", 180),
        })

    resp = requests.get(SEARCH_URL, params=params, timeout=30)
    resp.raise_for_status()
    data = resp.json()

    results = []
    for item in data.get("results", []):
        results.append({
            "doi": item.get("URI", ""),
            "title": item.get("citation", ""),
            "year": item.get("year"),
            "size": item.get("size"),
            "parameters": item.get("params", []),
            "score": item.get("score"),
        })
    return results


def download_dataset(doi: str) -> pd.DataFrame:
    """Download a PANGAEA dataset as a pandas DataFrame."""
    url = f"https://doi.pangaea.de/{doi}?format=textfile"
    resp = requests.get(url, timeout=60)
    resp.raise_for_status()

    lines = resp.text.split("\n")
    header_end = next(
        (i for i, line in enumerate(lines) if line.startswith("*/")),
        -1,
    )
    data_text = "\n".join(lines[header_end + 1:])
    return pd.read_csv(StringIO(data_text), sep="\t")


def search_by_location(query: str, lat: float, lon: float,
                       radius_deg: float = 5.0) -> list:
    """Search datasets near a geographic location."""
    bbox = {
        "south": lat - radius_deg,
        "north": lat + radius_deg,
        "west": lon - radius_deg,
        "east": lon + radius_deg,
    }
    return search_pangaea(query, bbox=bbox)


# Example: find ocean temperature datasets
datasets = search_pangaea("sea surface temperature", count=5)
for ds in datasets:
    print(f"[{ds['year']}] {ds['title'][:80]}...")
    print(f"  DOI: {ds['doi']} | Size: {ds['size']}")

# Example: download a specific dataset
# df = download_dataset("10.1594/PANGAEA.123456")
# print(df.head())

# Example: find Arctic research data
arctic = search_by_location("permafrost", lat=70, lon=25)
for ds in arctic[:3]:
    print(f"{ds['title'][:80]}...")
```

## Data Topics

| Topic | Coverage |
|-------|----------|
| Oceans | Temperature, salinity, currents, chemistry |
| Paleoclimate | Ice cores, sediment cores, tree rings |
| Atmosphere | CO2, aerosols, weather observations |
| Lithosphere | Geology, tectonics, geochemistry |
| Biosphere | Biodiversity, ecology, marine biology |
| Cryosphere | Sea ice, glaciers, permafrost |

## References

- [PANGAEA](https://www.pangaea.de/)
- [PANGAEA API](https://wiki.pangaea.de/wiki/PANGAEA_API)
- [PANGAEA Elasticsearch](https://wiki.pangaea.de/wiki/Elasticsearch_API)
- Diepenbroek, M. et al. (2002). "PANGAEA — an information system for environmental sciences." *C&G* 28(10).
