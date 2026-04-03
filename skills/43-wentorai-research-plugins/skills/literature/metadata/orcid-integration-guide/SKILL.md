---
name: orcid-integration-guide
description: "Set up and leverage ORCID for researcher identification and profiles"
metadata:
  openclaw:
    emoji: "🪪"
    category: "literature"
    subcategory: "metadata"
    keywords: ["ORCID", "researcher ID", "author disambiguation", "scholarly identity", "publication profile"]
    source: "wentor-research-plugins"
---

# ORCID Integration Guide

A skill for creating, maintaining, and leveraging ORCID (Open Researcher and Contributor ID) to establish a persistent digital identity, automate publication tracking, and integrate with journals, funders, and institutional systems.

## What Is ORCID?

### Overview

ORCID provides a unique 16-digit identifier (e.g., 0000-0002-1825-0097) that distinguishes you from every other researcher, regardless of name similarity, institutional changes, or transliteration variations. Over 19 million researchers have ORCID iDs, and thousands of publishers and funders now require or support ORCID integration.

### Why ORCID Matters

```
Problem: Name ambiguity in scholarly publishing
  - "J. Wang" could be thousands of researchers
  - Name changes (marriage, legal reasons)
  - Transliteration differences (Chinese, Korean, Arabic names)
  - Multiple institutional affiliations over a career

Solution: ORCID provides a persistent, unique identifier
  - Follows you across institutions and career stages
  - Links to your publications, grants, affiliations
  - Accepted by 1,500+ publishers and funders
  - Free and researcher-controlled
```

## Setting Up Your ORCID Profile

### Registration and Configuration

```
Step 1: Register at orcid.org
  - Use your institutional email (can add personal email too)
  - Choose a password
  - Set visibility defaults (public recommended for researchers)

Step 2: Complete your profile
  - Name and alternate names (include transliterations)
  - Biography (2-3 sentences about your research)
  - Education history (degrees, institutions, years)
  - Employment history (positions, institutions, years)
  - Keywords (5-10 terms describing your research areas)

Step 3: Link your works
  - Use "Search & Link" to pull in publications automatically
  - Supported sources: Crossref, Scopus, Web of Science, Europe PMC
  - Review each imported work before adding

Step 4: Connect to other systems
  - Link Scopus Author ID
  - Link ResearcherID / Web of Science
  - Connect institutional repository
```

### Privacy Settings

```python
def configure_orcid_visibility(profile_sections: dict) -> dict:
    """
    Recommended ORCID visibility settings for academic researchers.

    Args:
        profile_sections: Dict of section names and current visibility
    """
    recommendations = {
        "name": "public",
        "biography": "public",
        "education": "public",
        "employment": "public",
        "works": "public",
        "email": "trusted_parties",
        "funding": "public",
        "peer_reviews": "trusted_parties",
        "keywords": "public"
    }

    settings = {}
    for section, current in profile_sections.items():
        recommended = recommendations.get(section, "public")
        settings[section] = {
            "current": current,
            "recommended": recommended,
            "reason": (
                "Public visibility maximizes discoverability"
                if recommended == "public"
                else "Shared only with authorized organizations"
            )
        }

    return settings
```

## Integrating ORCID with Publishing Workflows

### Journal Submission

Most major publishers now request your ORCID during manuscript submission:

```
Elsevier:    Required for corresponding author
Springer Nature: Required for corresponding author
Wiley:       Requested for all authors
PLOS:        Required for corresponding author
IEEE:        Requested for all authors
Taylor & Francis: Requested for all authors
```

When you provide your ORCID during submission, the publication is automatically added to your ORCID record upon acceptance (via Crossref auto-update).

### Funder Integration

```
NIH:         ORCID linked via eRA Commons / SciENcv
NSF:         ORCID accepted in proposal submissions
ERC:          ORCID required for applicants
UKRI:        ORCID required for grant holders
ARC (Australia): ORCID required for applicants
```

## Using the ORCID API

### Retrieving Public Records

```python
import urllib.request
import json


def get_orcid_works(orcid_id: str) -> list:
    """
    Retrieve the public works list from an ORCID profile.

    Args:
        orcid_id: The ORCID iD (e.g., '0000-0002-1825-0097')
    """
    url = f"https://pub.orcid.org/v3.0/{orcid_id}/works"
    req = urllib.request.Request(url, headers={
        "Accept": "application/json"
    })
    response = urllib.request.urlopen(req)
    data = json.loads(response.read())

    works = []
    for group in data.get("group", []):
        summary = group["work-summary"][0]
        works.append({
            "title": summary["title"]["title"]["value"],
            "type": summary.get("type"),
            "year": summary.get("publication-date", {}).get("year", {}).get("value"),
            "journal": summary.get("journal-title", {}).get("value") if summary.get("journal-title") else None,
            "put_code": summary.get("put-code")
        })

    return works
```

## Maintaining Your ORCID Record

### Best Practices

- Review your record quarterly for completeness
- Enable auto-updates from Crossref (Settings > Account Settings > Crossref)
- Add preprints and datasets, not just journal articles
- Include peer review activity (via Publons/Web of Science integration)
- Use your ORCID iD in email signatures, CVs, and personal websites
- Format as a full URL: https://orcid.org/0000-0002-1825-0097

## See Also

- [orcid-api](../orcid-api/SKILL.md) -- Detailed ORCID Public API reference with endpoints, authentication, rate limits, and query examples.
