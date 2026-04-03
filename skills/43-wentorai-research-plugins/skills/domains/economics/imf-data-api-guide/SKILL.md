---
name: imf-data-api-guide
description: "Retrieve IMF economic indicators, exchange rates, and country data"
metadata:
  openclaw:
    emoji: "📊"
    category: "domains"
    subcategory: "economics"
    keywords: ["imf", "economics", "macroeconomics", "indicators", "exchange-rates", "gdp"]
    source: "https://datahelp.imf.org/knowledgebase/articles/667681-using-json-restful-web-service"
---

# IMF Data API Guide

## Overview

The International Monetary Fund (IMF) provides a free JSON-based REST API for accessing its extensive collection of macroeconomic and financial datasets. The API covers data from virtually every country and territory, spanning indicators such as GDP, inflation, trade balances, exchange rates, government finance statistics, and balance of payments.

For economics researchers, the IMF API is an essential tool for accessing authoritative international economic data without manual downloads. The data powers research in macroeconomics, development economics, international finance, and policy analysis. The API provides access to key datasets including the World Economic Outlook (WEO), International Financial Statistics (IFS), Balance of Payments Statistics (BOP), and the Direction of Trade Statistics (DOTS).

The API requires no authentication and returns JSON data. It uses a hierarchical structure of datasets, indicators, and country/time dimensions.

## Authentication

No authentication is required. The IMF Data API is completely free and open.

```bash
# No API key needed
curl "https://www.imf.org/external/datamapper/api/v1/NGDP_RPCH?periods=2024"
```

## Core Endpoints

### List Available Datasets

```
GET https://www.imf.org/external/datamapper/api/v1
```

```bash
curl -s "https://www.imf.org/external/datamapper/api/v1" | python3 -m json.tool
```

### List Indicators in a Dataset

```
GET https://www.imf.org/external/datamapper/api/v1/indicators
```

### Get Data for an Indicator

```
GET https://www.imf.org/external/datamapper/api/v1/{indicator}?periods={year}
```

**Common Indicators:**
- `NGDP_RPCH`: Real GDP growth (annual percent change)
- `PCPIPCH`: Inflation, consumer prices (annual percent change)
- `BCA_NGDPD`: Current account balance (percent of GDP)
- `GGXWDG_NGDP`: Government gross debt (percent of GDP)
- `LUR`: Unemployment rate

**Example: Get real GDP growth for all countries in 2024:**

```bash
curl -s "https://www.imf.org/external/datamapper/api/v1/NGDP_RPCH?periods=2024" \
  | python3 -m json.tool
```

### JSON RESTful Web Service (IFS and other databases)

For more granular data, use the Dataflow-based API:

```
GET http://dataservices.imf.org/REST/SDMX_JSON.svc/CompactData/{database}/{dimensions}?startPeriod={start}&endPeriod={end}
```

**Example: Monthly CPI data for the US and China:**

```bash
curl -s "http://dataservices.imf.org/REST/SDMX_JSON.svc/CompactData/IFS/M.US+CN.PCPI_IX?startPeriod=2020&endPeriod=2025" \
  | python3 -m json.tool
```

### Python Example: Compare GDP Growth Across Countries

```python
import requests

DATAMAPPER_URL = "https://www.imf.org/external/datamapper/api/v1"

def get_indicator_data(indicator, periods=None):
    """Fetch IMF indicator data for all countries."""
    url = f"{DATAMAPPER_URL}/{indicator}"
    params = {}
    if periods:
        params["periods"] = ",".join(str(p) for p in periods)
    resp = requests.get(url, params=params)
    resp.raise_for_status()
    return resp.json()

# Compare real GDP growth across G7 countries
data = get_indicator_data("NGDP_RPCH", periods=[2022, 2023, 2024])
values = data.get("values", {}).get("NGDP_RPCH", {})

g7_codes = ["USA", "GBR", "FRA", "DEU", "JPN", "CAN", "ITA"]
print("Country | 2022   | 2023   | 2024")
print("--------|--------|--------|-------")
for code in g7_codes:
    country_data = values.get(code, {})
    row = f"{code:7s}"
    for year in ["2022", "2023", "2024"]:
        val = country_data.get(year, "N/A")
        if isinstance(val, (int, float)):
            row += f" | {val:5.1f}%"
        else:
            row += f" | {str(val):>6s}"
    print(row)
```

### Python Example: Exchange Rate Time Series

```python
import requests

def get_exchange_rates(country_codes, start_year, end_year):
    """Fetch exchange rate data from IFS database."""
    codes = "+".join(country_codes)
    url = (
        f"http://dataservices.imf.org/REST/SDMX_JSON.svc/"
        f"CompactData/IFS/A.{codes}.ENDA_XDC_USD_RATE"
        f"?startPeriod={start_year}&endPeriod={end_year}"
    )
    resp = requests.get(url)
    resp.raise_for_status()
    return resp.json()

data = get_exchange_rates(["BR", "IN", "ZA"], 2015, 2024)
series = data.get("CompactData", {}).get("DataSet", {}).get("Series", [])
for s in series:
    country = s.get("@REF_AREA", "Unknown")
    obs = s.get("Obs", [])
    if isinstance(obs, dict):
        obs = [obs]
    print(f"\n{country} exchange rate (LCU per USD):")
    for o in obs:
        print(f"  {o.get('@TIME_PERIOD')}: {o.get('@OBS_VALUE')}")
```

## Common Research Patterns

**Cross-Country Panel Analysis:** Retrieve indicator data for multiple countries and years to construct panel datasets for econometric analysis. Combine GDP growth, inflation, and trade data for gravity models or growth regressions.

**Policy Impact Assessment:** Track economic indicators before and after major policy changes or economic shocks. Compare indicator trajectories across treatment and control country groups.

**Forecasting Benchmarks:** Use IMF WEO projections as baseline forecasts to compare against model predictions. The IMF publishes projections for most indicators several years forward.

**Development Economics:** Access poverty, inequality, and structural indicators for developing economies to study convergence, aid effectiveness, and institutional quality.

## Rate Limits and Best Practices

- **No formal rate limit** published, but limit requests to 1 per second for sustained use
- **Caching:** IMF data updates infrequently (quarterly/annually); cache aggressively
- **DataMapper vs SDMX:** The DataMapper API is simpler; the SDMX JSON service is more granular with monthly/quarterly frequency
- **Country codes:** Use ISO 3-letter codes (USA, GBR, CHN) for the DataMapper API and ISO 2-letter codes (US, GB, CN) for the SDMX service
- **Large queries:** Fetch data for all countries at once rather than making per-country requests
- **Error handling:** The API may return empty objects for unavailable country-indicator combinations rather than errors

## References

- IMF Data API Documentation: https://datahelp.imf.org/knowledgebase/articles/667681-using-json-restful-web-service
- IMF DataMapper: https://www.imf.org/external/datamapper
- IMF Data Portal: https://data.imf.org/
- IMF World Economic Outlook: https://www.imf.org/en/Publications/WEO
