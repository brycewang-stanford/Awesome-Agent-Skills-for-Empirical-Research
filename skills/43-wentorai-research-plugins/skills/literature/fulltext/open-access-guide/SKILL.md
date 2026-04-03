---
name: open-access-guide
description: "Navigate open access policies, repositories, and legal full-text retrieval me..."
metadata:
  openclaw:
    emoji: "🔓"
    category: "literature"
    subcategory: "fulltext"
    keywords: ["open access", "full-text retrieval", "journal copyright policy", "self-archiving", "open access rights"]
    source: "wentor"
---

# Open Access Guide

A skill for understanding open access publishing models, locating free full-text articles legally, and navigating self-archiving policies. Essential for researchers at institutions with limited journal subscriptions.

## Open Access Models

### Types of Open Access

| Type | Description | Cost to Author | Reader Access |
|------|------------|----------------|---------------|
| Gold OA | Published OA by journal (APC paid) | $1,000-$11,000 | Immediate, permanent |
| Green OA | Self-archived preprint/postprint | Free | After embargo (0-24 months) |
| Diamond/Platinum OA | Journal charges no APC | Free | Immediate, permanent |
| Bronze OA | Free to read on publisher site | Free | No reuse license, may be temporary |
| Hybrid OA | OA article in subscription journal | $2,000-$5,000 | Immediate for that article |

### Checking OA Status

```python
import requests

def check_oa_status(doi: str) -> dict:
    """
    Check open access availability using the Unpaywall API.

    Args:
        doi: DOI of the paper (e.g., '10.1038/s41586-021-03819-2')
    Returns:
        OA status and best available link
    """
    email = "researcher@university.edu"  # Required by Unpaywall API
    url = f"https://api.unpaywall.org/v2/{doi}?email={email}"

    response = requests.get(url)
    if response.status_code != 200:
        return {'error': f'API returned status {response.status_code}'}

    data = response.json()

    # Find best OA location
    best_location = data.get('best_oa_location', {})

    return {
        'doi': doi,
        'title': data.get('title', ''),
        'is_oa': data.get('is_oa', False),
        'oa_status': data.get('oa_status', 'closed'),
        'journal_is_oa': data.get('journal_is_oa', False),
        'best_oa_url': best_location.get('url', None) if best_location else None,
        'version': best_location.get('version', None) if best_location else None,
        'license': best_location.get('license', None) if best_location else None,
        'all_locations': len(data.get('oa_locations', []))
    }

# Example
result = check_oa_status('10.1038/s41586-021-03819-2')
if result['is_oa']:
    print(f"OA available: {result['best_oa_url']}")
else:
    print("Not openly available -- check Green OA options below")
```

## Legal Full-Text Sources

### Repositories and Aggregators

| Source | Type | Coverage | URL |
|--------|------|----------|-----|
| PubMed Central (PMC) | Repository | Biomedical + life sciences | ncbi.nlm.nih.gov/pmc |
| arXiv | Preprint server | Physics, CS, Math, Stats | arxiv.org |
| bioRxiv/medRxiv | Preprint server | Biology, medicine | biorxiv.org / medrxiv.org |
| SSRN | Preprint server | Social sciences, law, economics | ssrn.com |
| Zenodo | Repository | All disciplines | zenodo.org |
| CORE | Aggregator | 300M+ papers from repositories | core.ac.uk |
| OpenAlex | Search + OA links | Cross-disciplinary | openalex.org |
| BASE (Bielefeld) | Aggregator | 400M+ documents | base-search.net |

### Batch OA Lookup

```python
def batch_oa_lookup(dois: list[str]) -> list[dict]:
    """
    Check OA status for a batch of DOIs.
    Unpaywall supports up to 100,000 DOIs per day.
    """
    results = []
    for doi in dois:
        status = check_oa_status(doi)
        results.append(status)

    # Summary statistics
    total = len(results)
    oa_count = sum(1 for r in results if r.get('is_oa', False))
    print(f"OA availability: {oa_count}/{total} ({oa_count/total*100:.1f}%)")

    # Group by OA status
    by_status = {}
    for r in results:
        status = r.get('oa_status', 'unknown')
        by_status.setdefault(status, []).append(r)

    for status, papers in by_status.items():
        print(f"  {status}: {len(papers)} papers")

    return results
```

## Self-Archiving and Green OA

### Checking Publisher Policies

Use SHERPA/RoMEO to determine what you can self-archive:

```python
def check_sherpa_romeo(issn: str, api_key: str) -> dict:
    """
    Check journal self-archiving policy via SHERPA/RoMEO.

    Args:
        issn: Journal ISSN
        api_key: SHERPA/RoMEO API key
    """
    url = f"https://v2.sherpa.ac.uk/cgi/retrieve/by_id?item-type=publication&format=Json&api-key={api_key}&filter=[[%22issn%22,%22equals%22,%22{issn}%22]]"

    response = requests.get(url)
    data = response.json()

    if not data.get('items'):
        return {'error': 'Journal not found'}

    journal = data['items'][0]
    policies = journal.get('publisher_policy', [])

    results = {
        'journal': journal.get('title', [{}])[0].get('title', ''),
        'publisher': journal.get('publishers', [{}])[0].get('publisher', {}).get('name', ''),
        'policies': []
    }

    for policy in policies:
        for permitted in policy.get('permitted_oa', []):
            results['policies'].append({
                'version': permitted.get('article_version', ''),
                'location': permitted.get('location', {}).get('location', []),
                'conditions': permitted.get('conditions', []),
                'embargo': permitted.get('embargo', {}).get('amount', 0),
                'license': permitted.get('license', [])
            })

    return results
```

### Version Terminology

- **Preprint** (submitted manuscript): Author's version before peer review
- **Postprint** (accepted manuscript): Author's version after peer review, before typesetting
- **Published version** (Version of Record): Final published PDF with journal formatting

Most funders (NIH, UKRI, ERC) require deposit of at least the postprint in a repository. Always check your specific funder mandate and journal policy before self-archiving.

## Institutional Repository Deposit

When depositing in your institutional repository:

1. Identify the correct version (usually postprint for Green OA)
2. Check the embargo period from SHERPA/RoMEO
3. Add complete metadata: title, authors, DOI, journal, abstract, keywords
4. Apply the correct license (often CC BY for funder mandates)
5. Link to the publisher's Version of Record via DOI

This maximizes discoverability while respecting publisher agreements.
