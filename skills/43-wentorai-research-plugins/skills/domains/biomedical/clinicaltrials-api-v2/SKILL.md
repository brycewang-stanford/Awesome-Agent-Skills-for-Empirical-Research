---
name: clinicaltrials-api-v2
description: "Search and analyze clinical trials via the ClinicalTrials.gov v2 API"
metadata:
  openclaw:
    emoji: "🏥"
    category: "domains"
    subcategory: "biomedical"
    keywords: ["clinical trials", "ClinicalTrials.gov", "medical research", "study design", "FDA", "drug trials"]
    source: "https://clinicaltrials.gov/data-api/about-api"
---

# ClinicalTrials.gov v2 API Guide

## Overview

ClinicalTrials.gov is the world's largest clinical trial registry, maintained by the U.S. National Library of Medicine (NLM) at NIH. It contains over 576,000 study records from 220+ countries covering interventional trials, observational studies, and expanded access programs. The v2 API provides structured JSON access with field-level filtering, cursor-based pagination, and statistics endpoints.

Key v2 improvements over the legacy API: JSON-native responses, sparse field selection via the `fields` parameter, `nextPageToken` pagination, and dedicated statistics endpoints. Study data is organized into `protocolSection` (sponsor-submitted) and `derivedSection` (NLM-computed).

## Authentication

No authentication required. All endpoints are publicly accessible without API keys or registration. Users should comply with NCBI usage policies and maintain reasonable request rates.

## Core Endpoints

### Search Studies

- **URL**: `GET https://clinicaltrials.gov/api/v2/studies`
- **Parameters**:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| query.term | string | No | Free-text search across all fields |
| query.cond | string | No | Condition or disease filter |
| query.intr | string | No | Intervention or treatment filter |
| query.spons | string | No | Sponsor or collaborator filter |
| filter.overallStatus | string | No | `RECRUITING`, `COMPLETED`, `ACTIVE_NOT_RECRUITING`, etc. |
| filter.phase | string | No | `EARLY_PHASE1`, `PHASE1`, `PHASE2`, `PHASE3`, `PHASE4`, `NA` |
| filter.geo | string | No | Geographic filter (`distance(lat,lng,dist)`) |
| fields | string | No | Comma-separated fields for sparse response |
| sort | string | No | Sort field and direction (e.g., `LastUpdatePostDate:desc`) |
| pageSize | int | No | Results per page (default 10, max 1000) |
| pageToken | string | No | Cursor token for next page |
| format | string | No | `json` (default) or `csv` |

- **Example**:

```bash
curl "https://clinicaltrials.gov/api/v2/studies?query.cond=diabetes&query.intr=metformin&pageSize=1&fields=NCTId,BriefTitle,OverallStatus"
```

- **Response**:

```json
{
  "studies": [{
    "protocolSection": {
      "identificationModule": {
        "nctId": "NCT06649773",
        "briefTitle": "The Experiment of Noiiglutide Injection in Type 2 Diabetes Patients"
      },
      "statusModule": { "overallStatus": "ACTIVE_NOT_RECRUITING" }
    }
  }],
  "nextPageToken": "ZVNj7o2Elu8o3lpo..."
}
```

Full responses include `protocolSection` with: `identificationModule` (NCT ID, titles, organization), `statusModule` (status, dates), `descriptionModule` (summary), `conditionsModule`, `designModule` (type, phases, enrollment), `armsInterventionsModule`, `eligibilityModule` (criteria, sex, age), `outcomesModule`, and `contactsLocationsModule`.

### Get Single Study

- **URL**: `GET https://clinicaltrials.gov/api/v2/studies/{nctId}`

```bash
curl "https://clinicaltrials.gov/api/v2/studies/NCT04280705?fields=NCTId,BriefTitle,OverallStatus,Phase,LeadSponsorName,EnrollmentCount,Condition,InterventionName"
```

```json
{
  "protocolSection": {
    "identificationModule": {
      "nctId": "NCT04280705",
      "briefTitle": "Adaptive COVID-19 Treatment Trial (ACTT)"
    },
    "statusModule": {
      "overallStatus": "COMPLETED",
      "startDateStruct": { "date": "2020-02-21" },
      "completionDateStruct": { "date": "2020-05-21" }
    },
    "sponsorCollaboratorsModule": {
      "leadSponsor": { "name": "National Institute of Allergy and Infectious Diseases (NIAID)" }
    },
    "conditionsModule": { "conditions": ["COVID-19"] },
    "designModule": { "phases": ["PHASE3"], "enrollmentInfo": { "count": 1062 } },
    "armsInterventionsModule": {
      "interventions": [{ "name": "Placebo" }, { "name": "Remdesivir" }]
    }
  }
}
```

### Database Statistics

- **URL**: `GET https://clinicaltrials.gov/api/v2/stats/size`

```bash
curl "https://clinicaltrials.gov/api/v2/stats/size"
```

```json
{
  "totalStudies": 576554,
  "averageSizeBytes": 17186,
  "largestStudies": [
    { "id": "NCT02723955", "sizeBytes": 3596689 },
    { "id": "NCT03688620", "sizeBytes": 2865033 }
  ]
}
```

### Field Value Statistics

- **URL**: `GET https://clinicaltrials.gov/api/v2/stats/fieldValues/{fieldName}`

```bash
curl "https://clinicaltrials.gov/api/v2/stats/fieldValues/Phase"
```

```json
{
  "type": "ENUM",
  "piece": "Phase",
  "field": "protocolSection.designModule.phases",
  "missingStudiesCount": 136632,
  "topValues": [
    { "value": "NA", "studiesCount": 222829 },
    { "value": "PHASE2", "studiesCount": 87478 },
    { "value": "PHASE1", "studiesCount": 63716 },
    { "value": "PHASE3", "studiesCount": 48700 },
    { "value": "PHASE4", "studiesCount": 34911 },
    { "value": "EARLY_PHASE1", "studiesCount": 6179 }
  ]
}
```

## Rate Limits

No formal rate limits are published for the v2 API. Follow NCBI usage guidelines: stay under 3 requests/second without an API key, up to 10/second with one. For bulk data access, use the AACT relational database (https://aact.ctti-clinicaltrials.org/) or downloadable flat files rather than paginating through the full API.

## Academic Use Cases

- **Systematic reviews**: Use `query.cond` + `query.intr` + `filter.overallStatus=COMPLETED` to build PRISMA-compliant trial inventories. Paginate with `nextPageToken` to collect all records, then extract outcomes and enrollment for quantitative synthesis.
- **Landscape mapping**: Combine search with `stats/fieldValues` to map phase distributions, sponsor concentration, and geographic spread for a therapeutic area -- useful for identifying evidence gaps in grant proposals.
- **Recruitment tracking**: Filter by `RECRUITING` status and `filter.geo` to find active enrollment opportunities. Automate periodic queries for new trials in your domain.

## Code Examples

### Paginated Collection for Systematic Review

```python
import requests, time

def collect_trials(condition, intervention, status="COMPLETED"):
    base = "https://clinicaltrials.gov/api/v2/studies"
    studies, token = [], None
    while True:
        params = {
            "query.cond": condition, "query.intr": intervention,
            "filter.overallStatus": status, "pageSize": 100,
            "fields": "NCTId,BriefTitle,Phase,EnrollmentCount,CompletionDate",
        }
        if token:
            params["pageToken"] = token
        data = requests.get(base, params=params).json()
        studies.extend(data.get("studies", []))
        token = data.get("nextPageToken")
        if not token:
            break
        time.sleep(0.34)
    return studies

trials = collect_trials("type 2 diabetes", "metformin")
print(f"Collected {len(trials)} completed metformin T2D trials")
```

### Sponsor and Phase Analysis

```python
import requests
from collections import Counter

params = {"query.cond": "Alzheimer's Disease", "pageSize": 100,
          "fields": "NCTId,Phase,LeadSponsorName"}
data = requests.get("https://clinicaltrials.gov/api/v2/studies", params=params).json()

phases, sponsors = Counter(), Counter()
for s in data["studies"]:
    p = s["protocolSection"]
    for ph in p.get("designModule", {}).get("phases", []):
        phases[ph] += 1
    sponsors[p.get("sponsorCollaboratorsModule", {})
              .get("leadSponsor", {}).get("name", "Unknown")] += 1

for ph, n in phases.most_common():
    print(f"{ph}: {n}")
```

## References

- v2 API reference: https://clinicaltrials.gov/data-api/api
- About the API: https://clinicaltrials.gov/data-api/about-api
- AACT database (bulk access): https://aact.ctti-clinicaltrials.org/
- WHO ICTRP: https://trialsearch.who.int/
- NCBI usage policies: https://www.ncbi.nlm.nih.gov/home/about/policies/
