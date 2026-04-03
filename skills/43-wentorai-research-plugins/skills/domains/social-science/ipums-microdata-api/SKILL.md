---
name: ipums-microdata-api
description: "Access harmonized census and survey microdata via the IPUMS API"
metadata:
  openclaw:
    emoji: "📋"
    category: "domains"
    subcategory: "social-science"
    keywords: ["IPUMS", "census data", "microdata", "survey data", "demographics", "social science data"]
    source: "https://www.ipums.org/"
---

# IPUMS Microdata API

## Overview

IPUMS (Integrated Public Use Microdata Series) provides the world's largest collection of harmonized census and survey microdata. Hosted by the University of Minnesota, it covers demographic, health, labor, and geographic data across 100+ countries and 100+ years. The API enables programmatic extract creation, metadata queries, and data retrieval. Free registration required.

## IPUMS Data Collections

| Collection | Coverage | Records |
|-----------|----------|---------|
| IPUMS USA | U.S. Census & ACS (1850-present) | 16B+ person-records |
| IPUMS CPS | Current Population Survey (1962-present) | Labor force data |
| IPUMS International | Census data from 100+ countries | 2B+ person-records |
| IPUMS NHGIS | U.S. geographic/aggregate data | County-level stats |
| IPUMS DHS | Demographic and Health Surveys | 300+ surveys, 90 countries |
| IPUMS Time Use | American Time Use Survey | Time diary data |
| IPUMS Health | NHIS health surveys | Health/disability data |
| IPUMS Higher Ed | NSCG/SDR science workforce | S&E workforce data |

## API Endpoints

### Base URL

```
https://api.ipums.org/extracts/
```

### Authentication

```bash
# Register at https://www.ipums.org/
# API key from your account settings
export IPUMS_KEY="..."
```

### Create an Extract

```bash
# Request a data extract (IPUMS USA example)
curl -X POST "https://api.ipums.org/extracts/?collection=usa&version=2" \
  -H "Authorization: $IPUMS_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Income by education, 2020 ACS",
    "data_structure": {"rectangular": {"on": "P"}},
    "data_format": "csv",
    "samples": {"us2020a": {}},
    "variables": {
      "AGE": {},
      "SEX": {},
      "RACE": {},
      "EDUC": {},
      "INCTOT": {},
      "EMPSTAT": {}
    }
  }'
```

### Check Extract Status

```bash
curl "https://api.ipums.org/extracts/42?collection=usa&version=2" \
  -H "Authorization: $IPUMS_KEY"
```

### Download Extract

```bash
# When status is "completed"
curl -O "https://api.ipums.org/extracts/42/download?collection=usa&version=2" \
  -H "Authorization: $IPUMS_KEY"
```

### Query Metadata

```bash
# List available variables
curl "https://api.ipums.org/metadata/usa/variables?version=2" \
  -H "Authorization: $IPUMS_KEY"

# Get variable details
curl "https://api.ipums.org/metadata/usa/variables/EDUC?version=2" \
  -H "Authorization: $IPUMS_KEY"

# List available samples
curl "https://api.ipums.org/metadata/usa/samples?version=2" \
  -H "Authorization: $IPUMS_KEY"
```

## Python Usage

```python
import os
import time
import requests

BASE_URL = "https://api.ipums.org"
HEADERS = {"Authorization": os.environ.get("IPUMS_KEY", "")}


def create_extract(collection: str, samples: dict,
                   variables: list, description: str = "",
                   data_format: str = "csv") -> int:
    """Create an IPUMS data extract request."""
    var_dict = {v: {} for v in variables}
    body = {
        "description": description,
        "data_format": data_format,
        "data_structure": {"rectangular": {"on": "P"}},
        "samples": {s: {} for s in samples} if isinstance(samples, list)
                   else samples,
        "variables": var_dict,
    }

    resp = requests.post(
        f"{BASE_URL}/extracts/?collection={collection}&version=2",
        headers={**HEADERS, "Content-Type": "application/json"},
        json=body,
    )
    resp.raise_for_status()
    return resp.json()["number"]


def wait_for_extract(extract_id: int, collection: str,
                     poll_interval: int = 30) -> str:
    """Poll until extract is ready, return download URL."""
    while True:
        resp = requests.get(
            f"{BASE_URL}/extracts/{extract_id}"
            f"?collection={collection}&version=2",
            headers=HEADERS,
        )
        resp.raise_for_status()
        data = resp.json()
        status = data.get("status")

        if status == "completed":
            return data["download_links"]["data"]["url"]
        elif status == "failed":
            raise RuntimeError(f"Extract failed: {data}")
        print(f"Status: {status}, waiting {poll_interval}s...")
        time.sleep(poll_interval)


def get_variable_info(collection: str, variable: str) -> dict:
    """Get metadata about a variable."""
    resp = requests.get(
        f"{BASE_URL}/metadata/{collection}/variables/{variable}"
        f"?version=2",
        headers=HEADERS,
    )
    resp.raise_for_status()
    return resp.json()


# Example: request 2020 ACS income data
extract_id = create_extract(
    collection="usa",
    samples=["us2020a"],
    variables=["AGE", "SEX", "RACE", "EDUC", "INCTOT", "EMPSTAT"],
    description="Education-income analysis 2020",
)
print(f"Extract #{extract_id} submitted. Waiting...")

download_url = wait_for_extract(extract_id, "usa")
print(f"Ready: {download_url}")
```

## Key Variables (IPUMS USA)

| Variable | Description |
|----------|-------------|
| `AGE` | Age |
| `SEX` | Sex |
| `RACE` | Race |
| `EDUC` | Education level |
| `INCTOT` | Total income |
| `EMPSTAT` | Employment status |
| `OCC` | Occupation |
| `IND` | Industry |
| `POVERTY` | Poverty status |
| `MIGRATE1` | Migration status |
| `MARST` | Marital status |
| `NCHILD` | Number of children |

## Use Cases

1. **Demographic research**: Population trends, migration, aging
2. **Labor economics**: Wage gaps, employment patterns, occupation shifts
3. **Health disparities**: Insurance coverage, disability, access to care
4. **Education research**: Educational attainment trends, returns to education
5. **Historical analysis**: Long-run comparisons using harmonized variables

## References

- [IPUMS](https://www.ipums.org/)
- [IPUMS API Documentation](https://developer.ipums.org/)
- [IPUMS USA](https://usa.ipums.org/)
- Ruggles, S. et al. (2024). "IPUMS USA: Version 15.0." Minneapolis: IPUMS.
