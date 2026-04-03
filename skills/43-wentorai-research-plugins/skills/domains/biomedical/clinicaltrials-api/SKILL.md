---
name: clinicaltrials-api
description: "Clinical trial registry database search API"
metadata:
  openclaw:
    emoji: "🔍"
    category: "domains"
    subcategory: "biomedical"
    keywords: ["clinical medicine", "epidemiology", "public health", "evidence-based medicine"]
    source: "https://clinicaltrials.gov/api/"
---

# ClinicalTrials API Guide

## Overview

ClinicalTrials.gov is a registry and results database of publicly and privately supported clinical studies conducted around the world, maintained by the U.S. National Library of Medicine (NLM) at the National Institutes of Health (NIH). It contains registration records for over 500,000 clinical trials from more than 220 countries, making it the largest and most comprehensive clinical trial registry in the world.

The ClinicalTrials.gov API provides programmatic access to this vast repository of clinical trial data. Researchers can search for trials by condition, intervention, sponsor, location, phase, status, and many other criteria. The API returns detailed structured data including study design, eligibility criteria, outcome measures, enrollment information, study contacts, and results when available.

Clinical researchers, pharmaceutical companies, systematic reviewers, epidemiologists, public health officials, patient advocacy groups, and health policy analysts use the ClinicalTrials.gov API to monitor the clinical trial landscape, identify recruiting studies, conduct meta-analyses, analyze research trends, and ensure comprehensive evidence coverage in systematic reviews. The database is a critical resource for evidence-based medicine and regulatory compliance.

## Authentication

No authentication required. The ClinicalTrials.gov API is freely accessible without any API key, token, or registration. All endpoints are publicly available. Users are expected to comply with the NCBI usage policies and make requests at a reasonable rate.

## Core Endpoints

### query/full_studies: Search Clinical Trials

Search the ClinicalTrials.gov database and retrieve full study records with comprehensive metadata about trial design, eligibility, interventions, and outcomes.

- **URL**: `GET https://clinicaltrials.gov/api/v2/studies`
- **Parameters**:

| Parameter      | Type   | Required | Description                                                |
|----------------|--------|----------|------------------------------------------------------------|
| query.term     | string | No       | Free-text search query across all fields                   |
| query.cond     | string | No       | Condition or disease filter                                |
| query.intr     | string | No       | Intervention or treatment filter                           |
| query.spons    | string | No       | Sponsor or collaborator filter                             |
| filter.overallStatus | string | No | Status filter: `RECRUITING`, `COMPLETED`, `ACTIVE_NOT_RECRUITING` |
| filter.phase   | string | No       | Phase filter: `PHASE1`, `PHASE2`, `PHASE3`, `PHASE4`       |
| filter.geo     | string | No       | Geographic filter (distance:lat,lng)                       |
| sort            | string | No       | Sort field and direction                                   |
| pageSize       | int    | No       | Results per page (default 10, max 1000)                    |
| pageToken      | string | No       | Token for next page of results                             |
| format         | string | No       | Response format: `json` (default) or `csv`                 |

- **Example**:

```bash
# Search for recruiting cancer immunotherapy trials
curl "https://clinicaltrials.gov/api/v2/studies?query.cond=cancer&query.intr=immunotherapy&filter.overallStatus=RECRUITING&pageSize=5"

# Search by sponsor
curl "https://clinicaltrials.gov/api/v2/studies?query.spons=NIH&filter.phase=PHASE3&pageSize=10"
```

- **Response**: Returns `totalCount`, `nextPageToken`, and `studies` array. Each study contains `protocolSection` with `identificationModule` (NCT ID, title, organization), `statusModule` (overall status, start/completion dates), `descriptionModule` (brief summary, detailed description), `conditionsModule` (conditions and keywords), `designModule` (study type, phases, allocation, intervention model), `armsInterventionsModule`, `eligibilityModule` (criteria, gender, age range), `contactsLocationsModule`, and `outcomesModule`.

### Single Study Retrieval

Retrieve a specific clinical trial by its NCT identifier.

- **URL**: `GET https://clinicaltrials.gov/api/v2/studies/{nctId}`
- **Parameters**:

| Parameter | Type   | Required | Description                                |
|-----------|--------|----------|--------------------------------------------|
| nctId     | string | Yes      | NCT identifier (e.g., `NCT04280705`)      |

- **Example**:

```bash
curl "https://clinicaltrials.gov/api/v2/studies/NCT04280705"
```

- **Response**: Returns the complete study record with all protocol sections, including detailed eligibility criteria, primary and secondary outcome measures, study arms and interventions, sponsor information, and references.

## Rate Limits

No formal rate limits are documented for the ClinicalTrials.gov API. However, the service follows NCBI usage guidelines which recommend no more than 3 requests per second without an API key, and up to 10 requests per second with an NCBI API key. For bulk data access, ClinicalTrials.gov provides downloadable data files at https://clinicaltrials.gov/AllPublicXML.zip and via the AACT (Aggregate Analysis of ClinicalTrials.gov) database at https://aact.ctti-clinicaltrials.org/.

## Common Patterns

### Monitor Recruiting Trials for a Condition

Track actively recruiting trials for a specific disease or condition:

```python
import requests

params = {
    "query.cond": "Alzheimer's Disease",
    "filter.overallStatus": "RECRUITING",
    "filter.phase": "PHASE3",
    "pageSize": 20
}
resp = requests.get("https://clinicaltrials.gov/api/v2/studies", params=params)
data = resp.json()

print(f"Found {data['totalCount']} recruiting Phase 3 Alzheimer's trials\n")
for study in data["studies"]:
    proto = study["protocolSection"]
    ident = proto["identificationModule"]
    status = proto["statusModule"]
    print(f"{ident['nctId']}: {ident['briefTitle']}")
    print(f"  Status: {status['overallStatus']}")
    print(f"  Start: {status.get('startDateStruct', {}).get('date', 'N/A')}")
    print()
```

### Systematic Review: Comprehensive Trial Search

Perform a comprehensive search for systematic review inclusion screening:

```python
import requests

all_studies = []
page_token = None

while True:
    params = {
        "query.cond": "type 2 diabetes",
        "query.intr": "metformin",
        "filter.overallStatus": "COMPLETED",
        "pageSize": 100
    }
    if page_token:
        params["pageToken"] = page_token

    resp = requests.get("https://clinicaltrials.gov/api/v2/studies", params=params)
    data = resp.json()
    all_studies.extend(data["studies"])

    page_token = data.get("nextPageToken")
    if not page_token:
        break

print(f"Total completed metformin trials for T2D: {len(all_studies)}")
```

### Analyze Trial Characteristics

Extract and analyze study design features for research landscape mapping:

```python
import requests
from collections import Counter

params = {
    "query.cond": "COVID-19",
    "filter.phase": "PHASE3",
    "pageSize": 100
}
resp = requests.get("https://clinicaltrials.gov/api/v2/studies", params=params)
data = resp.json()

sponsors = Counter()
for study in data["studies"]:
    org = study["protocolSection"]["identificationModule"].get("organization", {})
    sponsors[org.get("fullName", "Unknown")] += 1

print("Top sponsors of Phase 3 COVID-19 trials:")
for sponsor, count in sponsors.most_common(10):
    print(f"  {sponsor}: {count} trials")
```

## References

- Official API documentation: https://clinicaltrials.gov/data-api/api
- ClinicalTrials.gov homepage: https://clinicaltrials.gov/
- AACT database for bulk analysis: https://aact.ctti-clinicaltrials.org/
- WHO ICTRP (international registry portal): https://trialsearch.who.int/
- NCBI usage policies: https://www.ncbi.nlm.nih.gov/home/about/policies/
