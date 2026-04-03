---
name: fred-api
description: "Federal Reserve Economic Data API for US economic indicators"
metadata:
  openclaw:
    emoji: "🔍"
    category: "domains"
    subcategory: "economics"
    keywords: ["microeconomics", "macroeconomics", "econometrics", "development economics"]
    source: "https://fred.stlouisfed.org/docs/api/fred/"
    requires:
      env: ["FRED_API_KEY"]
---

# FRED API Guide

## Overview

FRED (Federal Reserve Economic Data) is a database maintained by the Research Division of the Federal Reserve Bank of St. Louis. It contains over 800,000 economic time series from dozens of national and international sources, covering macroeconomic indicators, financial markets, employment, trade, monetary policy, and more.

The FRED API provides programmatic access to this extensive economic data repository. Researchers can retrieve time series observations, search for data series by keyword or category, explore release schedules, and access vintage (real-time) data for historical analysis. The data spans decades and in some cases centuries, making it invaluable for longitudinal economic research.

Economists, financial analysts, policy researchers, data scientists, and academic institutions rely on the FRED API for econometric modeling, macroeconomic forecasting, policy analysis, and teaching. It is one of the most widely used economic data APIs in academic research and is cited in thousands of peer-reviewed publications.

## Authentication

Authentication requires a free API key from the Federal Reserve Bank of St. Louis.

1. Register for an account at https://fredaccount.stlouisfed.org/login/secure/
2. Request an API key at https://fredaccount.stlouisfed.org/apikeys
3. Include the key as the `api_key` query parameter in all requests

```bash
curl "https://api.stlouisfed.org/fred/series?series_id=GDP&api_key=YOUR_KEY&file_type=json"
```

API keys are free and available to anyone who registers. There is no fee or approval process.

## Core Endpoints

### series: Retrieve Series Metadata

Get metadata about a specific economic data series, including title, frequency, units, seasonal adjustment, and date range.

- **URL**: `GET https://api.stlouisfed.org/fred/series`
- **Parameters**:

| Parameter  | Type   | Required | Description                                |
|------------|--------|----------|--------------------------------------------|
| series_id  | string | Yes      | FRED series identifier (e.g., `GDP`)       |
| api_key    | string | Yes      | Your FRED API key                          |
| file_type  | string | No       | Response format: `json` or `xml` (default) |

- **Example**:

```bash
curl "https://api.stlouisfed.org/fred/series?series_id=UNRATE&api_key=YOUR_KEY&file_type=json"
```

- **Response**: Returns `seriess` array with `id`, `title`, `observation_start`, `observation_end`, `frequency`, `units`, `seasonal_adjustment`, `notes`, and `popularity` ranking.

### observations: Retrieve Time Series Data

Fetch actual data points (observations) for a specific economic series over a date range.

- **URL**: `GET https://api.stlouisfed.org/fred/series/observations`
- **Parameters**:

| Parameter          | Type   | Required | Description                                        |
|--------------------|--------|----------|----------------------------------------------------|
| series_id          | string | Yes      | FRED series identifier                             |
| api_key            | string | Yes      | Your FRED API key                                  |
| observation_start  | string | No       | Start date in YYYY-MM-DD format                    |
| observation_end    | string | No       | End date in YYYY-MM-DD format                      |
| frequency          | string | No       | Aggregation: `d`, `w`, `m`, `q`, `a`              |
| aggregation_method | string | No       | `avg`, `sum`, `eop` (end of period)                |
| file_type          | string | No       | `json` or `xml`                                    |

- **Example**:

```bash
curl "https://api.stlouisfed.org/fred/series/observations?series_id=GDP&observation_start=2020-01-01&api_key=YOUR_KEY&file_type=json"
```

- **Response**: Returns `observations` array with `date` and `value` for each observation period.

### category: Browse Data Categories

Navigate the hierarchical FRED category system to discover available data series organized by topic.

- **URL**: `GET https://api.stlouisfed.org/fred/category`
- **Parameters**:

| Parameter   | Type   | Required | Description                                   |
|-------------|--------|----------|-----------------------------------------------|
| category_id | int    | Yes      | Category ID (0 for root)                      |
| api_key     | string | Yes      | Your FRED API key                             |
| file_type   | string | No       | `json` or `xml`                               |

- **Example**:

```bash
curl "https://api.stlouisfed.org/fred/category/children?category_id=0&api_key=YOUR_KEY&file_type=json"
```

- **Response**: Returns `categories` array with `id`, `name`, and `parent_id` for child categories.

### releases: Track Data Release Schedules

Retrieve information about data releases, which group related series that are published together.

- **URL**: `GET https://api.stlouisfed.org/fred/releases`
- **Parameters**:

| Parameter  | Type   | Required | Description                           |
|------------|--------|----------|---------------------------------------|
| api_key    | string | Yes      | Your FRED API key                     |
| file_type  | string | No       | `json` or `xml`                       |

- **Example**:

```bash
curl "https://api.stlouisfed.org/fred/releases?api_key=YOUR_KEY&file_type=json"
```

- **Response**: Returns `releases` array with `id`, `name`, `press_release`, `link`, and release notes.

## Rate Limits

The FRED API enforces rate limits that vary by usage. Standard limits allow approximately 120 requests per minute. Exceeding the limit returns HTTP 429 responses. For bulk data retrieval, consider using the FRED Excel add-in or downloading bulk files from https://fred.stlouisfed.org/. Academic users can contact FRED for elevated limits if needed.

## Common Patterns

### Retrieve and Plot GDP Data

Fetch quarterly GDP observations for macroeconomic analysis:

```python
import requests

params = {
    "series_id": "GDP",
    "api_key": "YOUR_KEY",
    "file_type": "json",
    "observation_start": "2015-01-01"
}
resp = requests.get("https://api.stlouisfed.org/fred/series/observations", params=params)
data = resp.json()

for obs in data["observations"]:
    print(f"{obs['date']}: ${obs['value']}B")
```

### Compare Multiple Economic Indicators

Build a multi-series dataset for econometric analysis:

```python
import requests

series_ids = ["UNRATE", "CPIAUCSL", "FEDFUNDS", "GDP"]
api_key = os.environ["FRED_API_KEY"]

for sid in series_ids:
    resp = requests.get("https://api.stlouisfed.org/fred/series/observations", params={
        "series_id": sid,
        "api_key": api_key,
        "file_type": "json",
        "observation_start": "2020-01-01",
        "frequency": "m"
    })
    obs = resp.json()["observations"]
    print(f"{sid}: {len(obs)} monthly observations retrieved")
```

### Search for Series by Keyword

Discover available data series on a specific topic:

```bash
curl "https://api.stlouisfed.org/fred/series/search?search_text=consumer+price+index&api_key=YOUR_KEY&file_type=json&limit=10"
```

## References

- Official API documentation: https://fred.stlouisfed.org/docs/api/fred/
- FRED homepage: https://fred.stlouisfed.org/
- Series search: https://fred.stlouisfed.org/docs/api/fred/series_search.html
- Category tree: https://fred.stlouisfed.org/docs/api/fred/category.html
