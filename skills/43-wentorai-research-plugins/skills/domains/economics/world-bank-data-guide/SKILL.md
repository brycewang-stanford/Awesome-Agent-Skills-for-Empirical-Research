---
name: world-bank-data-guide
description: "Access World Bank development indicators and country statistics"
metadata:
  openclaw:
    emoji: "🌍"
    category: "domains"
    subcategory: "economics"
    keywords: ["world-bank", "development", "indicators", "poverty", "economics", "statistics"]
    source: "https://datahelpdesk.worldbank.org/knowledgebase/articles/889392-about-the-indicators-api"
---

# World Bank Data API Guide

## Overview

The World Bank Data API provides free access to one of the most comprehensive collections of global development data available. The Indicators API covers over 16,000 development indicators across 217 countries and territories, with time series data spanning several decades. Topics include poverty and inequality, health outcomes, education statistics, infrastructure, trade, environmental metrics, and governance indicators.

This API is a cornerstone resource for researchers in development economics, public health, education policy, environmental science, and political science. The World Bank's data is widely cited in academic publications and policy documents, making it an authoritative source for cross-country comparative research.

The API is entirely free, requires no authentication, and returns data in JSON, XML, or other formats. The v2 API supports pagination, filtering by date ranges and income levels, and provides metadata about indicators and data sources.

## Authentication

No authentication is required. The World Bank Data API is free and open.

```bash
# No API key needed
curl "https://api.worldbank.org/v2/country/US/indicator/NY.GDP.MKTP.CD?format=json&date=2020:2024"
```

## Core Endpoints

### Get Indicator Data by Country

```
GET https://api.worldbank.org/v2/country/{country_code}/indicator/{indicator_code}?format=json
```

**Parameters:**
- `country_code`: ISO 2-letter or 3-letter code; use `all` for all countries
- `indicator_code`: World Bank indicator code
- `format`: `json` or `xml` (default xml)
- `date`: Year range (e.g., `2015:2024`)
- `per_page`: Results per page (default 50, max 32500)
- `page`: Page number

**Common Indicators:**
- `NY.GDP.MKTP.CD`: GDP (current US$)
- `NY.GDP.PCAP.CD`: GDP per capita (current US$)
- `SP.POP.TOTL`: Total population
- `SI.POV.DDAY`: Poverty headcount ratio at $2.15/day
- `SE.ADT.LITR.ZS`: Adult literacy rate
- `SH.XPD.CHEX.GD.ZS`: Current health expenditure (% of GDP)
- `EN.ATM.CO2E.PC`: CO2 emissions (metric tons per capita)

**Example: GDP per capita for BRICS nations:**

```bash
curl -s "https://api.worldbank.org/v2/country/BR;RU;IN;CN;ZA/indicator/NY.GDP.PCAP.CD?format=json&date=2019:2023&per_page=100" \
  | python3 -m json.tool
```

### List All Indicators

```bash
curl -s "https://api.worldbank.org/v2/indicator?format=json&per_page=50" \
  | python3 -m json.tool
```

### Search Indicators by Topic

```bash
curl -s "https://api.worldbank.org/v2/topic/8/indicator?format=json&per_page=20" \
  | python3 -m json.tool
```

Topics include: 1=Agriculture, 3=Economy, 4=Education, 6=Environment, 8=Health, 11=Poverty, etc.

### Get Country Metadata

```bash
curl -s "https://api.worldbank.org/v2/country/CN?format=json" \
  | python3 -m json.tool
```

### Python Example: Cross-Country Development Analysis

```python
import requests
import time

BASE_URL = "https://api.worldbank.org/v2"

def get_indicator(indicator_code, countries="all", date_range="2015:2023", per_page=500):
    """Fetch World Bank indicator data."""
    url = f"{BASE_URL}/country/{countries}/indicator/{indicator_code}"
    params = {
        "format": "json",
        "date": date_range,
        "per_page": per_page
    }
    resp = requests.get(url, params=params)
    resp.raise_for_status()
    data = resp.json()
    if len(data) < 2:
        return []
    return data[1]

# Compare health expenditure vs life expectancy
health_exp = get_indicator("SH.XPD.CHEX.GD.ZS", countries="US;GB;DE;JP;BR;IN", date_range="2020")
for record in health_exp:
    if record["value"] is not None:
        country = record["country"]["value"]
        year = record["date"]
        value = record["value"]
        print(f"{country} ({year}): {value:.1f}% of GDP on health")
```

### Python Example: Build a Panel Dataset

```python
import requests
import csv

def build_panel(indicators, countries, years):
    """Build a panel dataset from multiple World Bank indicators."""
    panel = {}
    for ind_code, ind_name in indicators.items():
        url = f"https://api.worldbank.org/v2/country/{countries}/indicator/{ind_code}"
        params = {"format": "json", "date": years, "per_page": 5000}
        resp = requests.get(url, params=params)
        data = resp.json()
        if len(data) < 2:
            continue
        for record in data[1]:
            key = (record["country"]["id"], record["date"])
            if key not in panel:
                panel[key] = {"country": record["country"]["value"], "year": record["date"]}
            panel[key][ind_name] = record["value"]

    return list(panel.values())

indicators = {
    "NY.GDP.PCAP.CD": "gdp_per_capita",
    "SP.POP.TOTL": "population",
    "SE.ADT.LITR.ZS": "literacy_rate"
}
data = build_panel(indicators, "BR;IN;NG;ID", "2018:2023")
for row in data[:10]:
    print(row)
```

## Common Research Patterns

**Development Panel Regressions:** Combine multiple indicators across countries and years to construct panel datasets for econometric analysis. Study relationships between education spending, health outcomes, and economic growth.

**Poverty and Inequality Analysis:** Track poverty headcount ratios, Gini coefficients, and income share data across countries and over time to study the effectiveness of development interventions.

**Environmental-Economic Nexus:** Combine CO2 emissions, renewable energy, and GDP data to study the Environmental Kuznets Curve or the decoupling of economic growth from environmental degradation.

**Policy Evaluation:** Compare indicator trajectories before and after major policy reforms across treated and comparison countries using difference-in-differences or synthetic control methods.

## Rate Limits and Best Practices

- **No authentication required** and no strict rate limit, but keep requests to 1-2 per second
- **Pagination:** Default 50 results per page; set `per_page=32500` for single-page retrieval of most queries
- **Format:** Always specify `format=json` as the default is XML
- **Null values:** Many indicators have null values for certain country-year combinations; always check for nulls
- **Country groups:** Use aggregate codes like `EUU` (EU), `WLD` (World), `LIC` (Low Income) for pre-computed aggregates
- **MRV parameter:** Use `MRV=1` to get the most recent value for each country when the latest year varies
- **Bulk downloads:** For large-scale analysis, consider the bulk download options at https://data.worldbank.org/

## References

- World Bank Indicators API Documentation: https://datahelpdesk.worldbank.org/knowledgebase/articles/889392-about-the-indicators-api
- World Bank Data Portal: https://data.worldbank.org/
- World Bank Indicator List: https://data.worldbank.org/indicator
- World Bank API Query Builder: https://datahelpdesk.worldbank.org/knowledgebase/articles/898581-api-basic-call-structures
