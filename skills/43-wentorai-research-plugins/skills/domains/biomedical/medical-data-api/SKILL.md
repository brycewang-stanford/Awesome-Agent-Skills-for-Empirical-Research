---
name: medical-data-api
description: "Access FDA drug data and WHO global health statistics for research"
metadata:
  openclaw:
    emoji: "💊"
    category: "domains"
    subcategory: "biomedical"
    keywords: ["FDA", "drug safety", "WHO", "global health", "adverse events", "medical data", "pharmacovigilance"]
    source: "https://open.fda.gov"
---

# Medical Data API Guide (openFDA + WHO GHO)

## Overview

This skill covers two major open medical data APIs for academic research:

**openFDA** is the U.S. Food and Drug Administration's public API providing access to drug labeling (SPL), adverse event reports (FAERS), recalls, and NDC directory. The FAERS dataset contains over 722,000 reports for common drugs like aspirin, making it a primary pharmacovigilance resource.

**WHO Global Health Observatory (GHO)** is the WHO's OData v4 API serving over 2,000 health indicators across 194 member states -- life expectancy, mortality, disease burden, health system coverage, risk factors, and SDG targets. Returns structured JSON with numeric values, confidence intervals, and dimensional breakdowns by country, sex, and year.

Both APIs are free, require no authentication, and return JSON.

## Authentication

**openFDA**: No authentication required. An optional API key (free, via https://open.fda.gov/apis/authentication/) increases rate limits from 240/min to 120,000/day. Register at https://open.fda.gov/apis/ to obtain a key, then append `&api_key=YOUR_KEY` to requests.

**WHO GHO**: No authentication required. No API key needed. All endpoints are publicly accessible with no registration.

## Core Endpoints

### openFDA: Drug Labels

Search FDA-approved drug labeling data (Structured Product Labeling). Returns boxed warnings, indications, dosage, contraindications, and adverse reactions text.

- **URL**: `GET https://api.fda.gov/drug/label.json`
- **Parameters**:

| Parameter | Type   | Required | Description                                         |
|-----------|--------|----------|-----------------------------------------------------|
| search    | string | No       | Search query using openFDA query syntax              |
| limit     | int    | No       | Number of results (default 1, max 1000)              |
| skip      | int    | No       | Offset for pagination                                |
| count     | string | No       | Count unique values of a field                       |

- **Example**:

```bash
curl "https://api.fda.gov/drug/label.json?search=aspirin&limit=1"
```

- **Response**: Returns `meta.results.total` (26,564 for "aspirin") and `results` array. Each result contains `boxed_warning`, `indications_and_usage`, `dosage_and_administration`, `warnings`, `adverse_reactions`, `drug_interactions`, and `openfda` cross-references (brand/generic names, manufacturer, NDC, pharmacologic class).

### openFDA: Adverse Events (FAERS)

Search the FDA Adverse Event Reporting System. Each record describes a safety report including patient demographics, suspect drugs, reported reactions, and outcomes.

- **URL**: `GET https://api.fda.gov/drug/event.json`
- **Parameters**:

| Parameter | Type   | Required | Description                                         |
|-----------|--------|----------|-----------------------------------------------------|
| search    | string | No       | Query (e.g., `patient.drug.openfda.brand_name:"aspirin"`) |
| limit     | int    | No       | Number of results (default 1, max 1000)              |
| skip      | int    | No       | Offset for pagination (max skip+limit = 26,000)      |
| count     | string | No       | Count field values (e.g., `patient.reaction.reactionmeddrapt.exact`) |

- **Example**:

```bash
curl 'https://api.fda.gov/drug/event.json?search=patient.drug.openfda.brand_name:"aspirin"&limit=1'
```

- **Response**: Returns `meta.results.total` (722,607 for aspirin). Each result: `safetyreportid`, `serious` (1=yes, 2=no), `primarysourcecountry`, `receivedate`, nested `patient` with `patientsex`, `reaction` array (MedDRA terms + `reactionoutcome`), and `drug` array with `drugcharacterization` (1=suspect, 2=concomitant, 3=interacting), `medicinalproduct`, `openfda` cross-references.

### WHO GHO: Health Indicator Data

Retrieve data points for a specific health indicator with country, year, and sex dimensions.

- **URL**: `GET https://ghoapi.azureedge.net/api/{IndicatorCode}`
- **Parameters** (OData v4 query options):

| Parameter | Type   | Required | Description                                           |
|-----------|--------|----------|-------------------------------------------------------|
| $top      | int    | No       | Limit number of records returned                       |
| $skip     | int    | No       | Skip records for pagination                            |
| $filter   | string | No       | OData filter (e.g., `SpatialDim eq 'USA' and TimeDim eq 2020`) |
| $select   | string | No       | Select specific fields                                 |
| $orderby  | string | No       | Sort results                                           |

- **Example**:

```bash
# Life expectancy at birth (WHOSIS_000001)
curl "https://ghoapi.azureedge.net/api/WHOSIS_000001?\$top=2"
```

- **Response**: OData JSON with `value` array. Each record: `SpatialDim` (ISO country, e.g., "BTN"), `ParentLocation` (WHO region), `TimeDim` (year), `Dim1` (sex: "SEX_BTSX"/"SEX_MLE"/"SEX_FMLE"), `Value` ("67.8 [67.1-68.6]"), `NumericValue` (67.845665), `Low`/`High` confidence bounds.

### WHO GHO: Indicator Directory

List available health indicators with their codes and names.

- **URL**: `GET https://ghoapi.azureedge.net/api/Indicator`
- **Example**:

```bash
curl "https://ghoapi.azureedge.net/api/Indicator?\$top=5"
```

- **Response**: Array of entries with `IndicatorCode` (e.g., "Adult_curr_e-cig"), `IndicatorName` (e.g., "Prevalence of current e-cigarette use among adults (%)"), `Language` ("EN"). Over 2,000 indicators spanning mortality, morbidity, health systems, and risk factors.

## Rate Limits

**openFDA**:
- Without API key: 240 requests per minute (burst), 1,000 requests per day
- With free API key: 240 requests per minute, 120,000 requests per day
- Pagination ceiling: `skip` + `limit` cannot exceed 26,000 (use `search` + `sort` for deeper access)

**WHO GHO**:
- No documented rate limits; the service runs on Azure CDN (azureedge.net)
- Recommended: keep requests under 10/second for courtesy
- For bulk downloads, use the GHO data portal CSV exports at https://www.who.int/data/gho

## Academic Use Cases

### Pharmacovigilance: Adverse Event Signal Detection

Count reactions by MedDRA term to identify safety signals:

```python
import requests

resp = requests.get("https://api.fda.gov/drug/event.json", params={
    "search": 'patient.drug.openfda.brand_name:"aspirin"',
    "count": "patient.reaction.reactionmeddrapt.exact",
    "limit": 10
})
for r in resp.json()["results"]:
    print(f"  {r['term']}: {r['count']} reports")
```

### Epidemiology: Cross-National Health Comparisons

Compare health indicators across countries and time periods:

```python
import requests

resp = requests.get("https://ghoapi.azureedge.net/api/WHOSIS_000001", params={
    "$filter": "SpatialDim eq 'JPN' and Dim1 eq 'SEX_BTSX'",
    "$orderby": "TimeDim desc",
    "$top": 10
})
for row in resp.json()["value"]:
    print(f"  Japan {row['TimeDim']}: {row['Value']}")
```

### Public Health: Drug Label Comparison

Compare safety language across drug labels for regulatory research:

```python
import requests

for drug in ["ibuprofen", "naproxen", "celecoxib"]:
    resp = requests.get("https://api.fda.gov/drug/label.json",
        params={"search": f'openfda.generic_name:"{drug}"', "limit": 1})
    results = resp.json().get("results", [])
    if results:
        warning = results[0].get("boxed_warning", ["None"])[0][:200]
        print(f"{drug.upper()}: {warning}...\n")
```

## Key Indicator Codes (WHO GHO)

| Code | Indicator |
|------|-----------|
| WHOSIS_000001 | Life expectancy at birth |
| NCDMORT3070 | NCD mortality (30-70 years) |
| MDG_0000000001 | Under-five mortality rate |
| WHS4_100 | Physicians per 10,000 population |
| NCD_BMI_30A | Prevalence of obesity (BMI >= 30) |
| SA_0000001688 | Alcohol per capita consumption |
| TOBACCO_0000000262 | Tobacco smoking prevalence |

## References

- openFDA documentation: https://open.fda.gov/apis/
- openFDA API key registration: https://open.fda.gov/apis/authentication/
- openFDA query syntax: https://open.fda.gov/apis/query-syntax/
- openFDA GitHub: https://github.com/FDA/openfda
- WHO GHO API documentation: https://www.who.int/data/gho/info/gho-odata-api
- WHO GHO OData endpoint: https://ghoapi.azureedge.net/api/
- WHO GHO indicator list: https://ghoapi.azureedge.net/api/Indicator
- WHO Global Health Observatory portal: https://www.who.int/data/gho
