# Metadata API Reference

> **LEGACY REFERENCE:** This file documents the Education Data Portal's REST metadata API. Mirror-based file discovery is now the primary data access method (see `education-data-query` skill and `mirrors.yaml`). This file is retained for reference on available endpoints and variable metadata only.

Programmatically discover endpoints, variables, and data availability in the Education Data Portal.

## Contents

- [Metadata Endpoints](#metadata-endpoints)
- [Python Examples](#python-examples)
- [Common Discovery Tasks](#common-discovery-tasks)

---

## Metadata Endpoints

### List All Endpoints

**Endpoint**: `/api/v1/api-endpoints/`

Returns all available data endpoints with metadata.

**Response Fields**:

| Field | Description |
|-------|-------------|
| `endpoint_id` | Unique endpoint identifier |
| `endpoint_url` | API endpoint URL pattern |
| `endpoint_name` | Human-readable name |
| `section` | Data level (schools, school-districts, college-university) |
| `source` | Data source (ccd, crdc, ipeds, etc.) |
| `topic` | Topic name |
| `years_available` | List of available years |
| `subtopic` | Disaggregation (race, sex, etc.) |
| `documentation_url` | Link to documentation |

**Filters**:
- `endpoint_id` - Filter by specific endpoint ID
- `section` - Filter by level (schools, school-districts, college-university)
- `source` - Filter by source (ccd, crdc, ipeds, etc.)

### List All Variables

**Endpoint**: `/api/v1/api-variables/`

Returns all variable definitions across all endpoints.

**Response Fields**:

| Field | Description |
|-------|-------------|
| `variable` | Variable name |
| `label` | Human-readable label |
| `description` | Full description |
| `data_type` | Data type (integer, float, string) |
| `format` | Display format |
| `source` | Data source |
| `section` | Data level |

**Filters**:
- `variable` - Filter by variable name
- `source` - Filter by data source
- `section` - Filter by level

### Variables by Endpoint

**Endpoint**: `/api/v1/api-endpoint-varlist/`

Returns variables available for a specific endpoint.

**Filters** (required):
- `endpoint_id` - Endpoint ID from api-endpoints

**Response**: List of variables with their definitions.

### Data Sources

**Endpoint**: `/api/v1/api-sources/`

Returns information about data sources.

**Response Fields**:

| Field | Description |
|-------|-------------|
| `source` | Source code (ccd, ipeds, etc.) |
| `source_name` | Full source name |
| `source_url` | Original data source URL |
| `description` | Source description |

### Bulk Downloads

**Endpoint**: `/api/v1/api-downloads/`

Returns links to CSV bulk download files.

**Response Fields**:

| Field | Description |
|-------|-------------|
| `download_id` | Download identifier |
| `endpoint_url` | Related endpoint |
| `year` | Data year |
| `download_url` | CSV download URL |
| `file_size` | File size in bytes |
| `record_count` | Number of records |

---

## Python Examples

### Setup

```python
import requests

BASE_URL = "https://educationdata.urban.org/api/v1"

def get_json(endpoint, params=None):
    """Fetch JSON from API endpoint."""
    response = requests.get(f"{BASE_URL}{endpoint}", params=params)
    response.raise_for_status()
    return response.json()
```

### List All Endpoints

```python
# Get all endpoints
endpoints = get_json("/api-endpoints/")

# Print endpoint count
print(f"Total endpoints: {endpoints['count']}")

# List school-level endpoints
for ep in endpoints["results"]:
    if ep["section"] == "schools":
        print(f"{ep['endpoint_id']}: {ep['endpoint_url']}")
```

### Filter Endpoints by Source

```python
# Get all IPEDS endpoints
ipeds_endpoints = get_json("/api-endpoints/", params={"source": "ipeds"})

for ep in ipeds_endpoints["results"]:
    print(f"{ep['endpoint_name']}: {ep['years_available']}")
```

### Get Variables for Endpoint

```python
# Get endpoint ID first
endpoints = get_json("/api-endpoints/", 
                     params={"endpoint_url": "/schools/ccd/directory/"})
endpoint_id = endpoints["results"][0]["endpoint_id"]

# Get variables for that endpoint
variables = get_json("/api-endpoint-varlist/", 
                     params={"endpoint_id": endpoint_id})

for var in variables["results"]:
    print(f"{var['variable']}: {var['label']}")
```

### Check Years Available

```python
def get_years_available(endpoint_url):
    """Get years available for an endpoint."""
    # Remove trailing year placeholder if present
    base_url = endpoint_url.rstrip("/").rsplit("/", 1)[0]
    if base_url.endswith("}"):
        base_url = base_url.rsplit("/", 1)[0]
    
    endpoints = get_json("/api-endpoints/", 
                        params={"endpoint_url": base_url})
    
    if endpoints["results"]:
        return endpoints["results"][0]["years_available"]
    return []

# Example
years = get_years_available("/schools/ccd/directory/")
print(f"CCD Directory available years: {min(years)}-{max(years)}")
```

### Search Variables

```python
def search_variables(keyword):
    """Search variables by keyword in label or description."""
    all_vars = get_json("/api-variables/")
    
    matches = []
    for var in all_vars["results"]:
        label = var.get("label", "").lower()
        desc = var.get("description", "").lower()
        if keyword.lower() in label or keyword.lower() in desc:
            matches.append(var)
    
    return matches

# Find enrollment-related variables
enrollment_vars = search_variables("enrollment")
for var in enrollment_vars[:10]:
    print(f"{var['variable']}: {var['label']}")
```

### Build Complete Endpoint List

```python
def get_all_endpoints_paginated():
    """Get all endpoints handling pagination."""
    all_endpoints = []
    url = "/api-endpoints/"
    
    while url:
        data = get_json(url)
        all_endpoints.extend(data["results"])
        
        # Handle pagination
        next_url = data.get("next")
        if next_url:
            url = next_url.replace(BASE_URL, "")
        else:
            url = None
    
    return all_endpoints

endpoints = get_all_endpoints_paginated()
print(f"Total endpoints: {len(endpoints)}")
```

### Get Endpoint Details

```python
def get_endpoint_details(endpoint_id):
    """Get full details for an endpoint including variables."""
    # Get endpoint info
    ep_info = get_json("/api-endpoints/", 
                       params={"endpoint_id": endpoint_id})
    
    if not ep_info["results"]:
        return None
    
    endpoint = ep_info["results"][0]
    
    # Get variables
    variables = get_json("/api-endpoint-varlist/", 
                        params={"endpoint_id": endpoint_id})
    
    return {
        "endpoint": endpoint,
        "variables": variables["results"]
    }

# Example
details = get_endpoint_details(24)  # CCD directory
print(f"Endpoint: {details['endpoint']['endpoint_name']}")
print(f"Variables: {len(details['variables'])}")
```

---

## Common Discovery Tasks

### Find Endpoints for a Topic

```python
def find_endpoints_for_topic(topic_keyword, level=None):
    """Find endpoints matching a topic."""
    params = {}
    if level:
        params["section"] = level
    
    endpoints = get_json("/api-endpoints/", params=params)
    
    matches = []
    for ep in endpoints["results"]:
        name = ep.get("endpoint_name", "").lower()
        topic = ep.get("topic", "").lower()
        if topic_keyword.lower() in name or topic_keyword.lower() in topic:
            matches.append(ep)
    
    return matches

# Find enrollment endpoints for schools
enrollment_eps = find_endpoints_for_topic("enrollment", "schools")
```

### Check Variable Availability

```python
def check_variable_availability(variable_name):
    """Check which endpoints contain a variable."""
    all_vars = get_json("/api-variables/", 
                       params={"variable": variable_name})
    
    return all_vars["results"]

# Where is 'enrollment' variable available?
enrollment_sources = check_variable_availability("enrollment")
```

### Get Latest Year for Endpoint

```python
def get_latest_year(endpoint_url):
    """Get the most recent year available for an endpoint."""
    years = get_years_available(endpoint_url)
    if years:
        return max(years)
    return None

latest = get_latest_year("/schools/ccd/directory/")
print(f"Latest CCD directory year: {latest}")
```

### Generate Endpoint URL

```python
def build_endpoint_url(level, source, topic, year, disaggregations=None):
    """Build a complete endpoint URL."""
    url = f"/api/v1/{level}/{source}/{topic}/{year}/"
    
    if disaggregations:
        for d in disaggregations:
            url += f"{d}/"
    
    return url

# Example: CCD enrollment by grade and race for 2022
url = build_endpoint_url(
    level="schools",
    source="ccd", 
    topic="enrollment",
    year="2022",
    disaggregations=["grade-5", "race"]
)
print(url)
# Output: /api/v1/schools/ccd/enrollment/2022/grade-5/race/
```

---

## Response Pagination

All metadata endpoints return paginated results:

```json
{
  "count": 150,
  "next": "https://educationdata.urban.org/api/v1/api-endpoints/?page=2",
  "previous": null,
  "results": [...]
}
```

**Pagination Parameters**:
- `page` - Page number (default: 1)
- `per_page` - Results per page (default: 100, max: 10000)

### Handling Pagination

```python
def get_all_results(endpoint, params=None):
    """Get all results from a paginated endpoint."""
    if params is None:
        params = {}
    
    params["per_page"] = 10000  # Max per page
    all_results = []
    page = 1
    
    while True:
        params["page"] = page
        data = get_json(endpoint, params=params)
        all_results.extend(data["results"])
        
        if not data.get("next"):
            break
        page += 1
    
    return all_results
```

---

## Quick Reference

| Task | Endpoint | Key Parameter |
|------|----------|---------------|
| List all endpoints | `/api-endpoints/` | - |
| Filter by level | `/api-endpoints/` | `section=schools` |
| Filter by source | `/api-endpoints/` | `source=ccd` |
| Get endpoint variables | `/api-endpoint-varlist/` | `endpoint_id=24` |
| Search variables | `/api-variables/` | `variable=enrollment` |
| Data source info | `/api-sources/` | `source=ipeds` |
| Bulk downloads | `/api-downloads/` | - |
