---
name: doi-resolution-guide
description: "DOI content negotiation and metadata retrieval techniques"
metadata:
  openclaw:
    emoji: "🔗"
    category: "literature"
    subcategory: "metadata"
    keywords: ["DOI resolution", "digital object identifier", "citation statistics"]
    source: "wentor-research-plugins"
---

# DOI Resolution Guide

Master DOI content negotiation to programmatically retrieve structured metadata, citation data, and formatted references from any Digital Object Identifier.

## What Is DOI Content Negotiation?

Every DOI (e.g., `10.1038/s41586-021-03819-2`) resolves to a landing page by default. However, the DOI system supports HTTP content negotiation: by sending different `Accept` headers, you can retrieve structured metadata in various formats instead of an HTML page.

The DOI resolver endpoint is `https://doi.org/{doi}` or equivalently `https://dx.doi.org/{doi}`.

## Supported Metadata Formats

| Accept Header | Format | Use Case |
|---------------|--------|----------|
| `application/vnd.citationstyles.csl+json` | CSL-JSON | Programmatic metadata extraction |
| `text/x-bibliography; style=apa` | Formatted citation | Ready-to-paste APA reference |
| `text/x-bibliography; style=bibtex` | BibTeX | LaTeX bibliography import |
| `application/x-bibtex` | BibTeX (alt) | LaTeX bibliography import |
| `application/rdf+xml` | RDF/XML | Linked data applications |
| `text/turtle` | Turtle RDF | Linked data applications |
| `application/vnd.crossref.unixref+xml` | CrossRef Unixref | Full CrossRef metadata |

## Retrieving Metadata via Content Negotiation

### Get CSL-JSON (Most Useful for Programmatic Access)

```bash
curl -LH "Accept: application/vnd.citationstyles.csl+json" \
  https://doi.org/10.1038/s41586-021-03819-2
```

```python
import requests

doi = "10.1038/s41586-021-03819-2"
headers = {"Accept": "application/vnd.citationstyles.csl+json"}
response = requests.get(f"https://doi.org/{doi}", headers=headers, allow_redirects=True)

metadata = response.json()
print(f"Title: {metadata['title']}")
print(f"Authors: {', '.join(a.get('family', '') for a in metadata.get('author', []))}")
print(f"Journal: {metadata.get('container-title', 'N/A')}")
print(f"Year: {metadata.get('published', {}).get('date-parts', [[None]])[0][0]}")
print(f"Type: {metadata.get('type')}")
```

### Get a Formatted Citation

```bash
# APA format
curl -LH "Accept: text/x-bibliography; style=apa" \
  https://doi.org/10.1038/s41586-021-03819-2

# Chicago format
curl -LH "Accept: text/x-bibliography; style=chicago-author-date" \
  https://doi.org/10.1038/s41586-021-03819-2

# Harvard format
curl -LH "Accept: text/x-bibliography; style=harvard-cite-them-right" \
  https://doi.org/10.1038/s41586-021-03819-2
```

### Get BibTeX for LaTeX

```bash
curl -LH "Accept: application/x-bibtex" \
  https://doi.org/10.1038/s41586-021-03819-2
```

Output:

```bibtex
@article{Jumper_2021,
  title={Highly accurate protein structure prediction with AlphaFold},
  volume={596},
  DOI={10.1038/s41586-021-03819-2},
  journal={Nature},
  author={Jumper, John and Evans, Richard and ...},
  year={2021},
  pages={583--589}
}
```

## Using the CrossRef API

The CrossRef API provides richer metadata and supports batch queries without content negotiation.

### Single Paper Lookup

```python
import requests

doi = "10.1038/s41586-021-03819-2"
response = requests.get(
    f"https://api.crossref.org/works/{doi}",
    headers={"User-Agent": "ResearchClaw/1.0 (mailto:you@university.edu)"}
)

work = response.json()["message"]
print(f"Title: {work['title'][0]}")
print(f"Publisher: {work['publisher']}")
print(f"Citation count: {work.get('is-referenced-by-count', 0)}")
print(f"Reference count: {work.get('references-count', 0)}")
print(f"License: {work.get('license', [{}])[0].get('URL', 'N/A')}")
```

### Batch DOI Resolution

```python
dois = [
    "10.1038/s41586-021-03819-2",
    "10.1126/science.abj8754",
    "10.1016/j.cell.2021.06.025"
]

results = []
for doi in dois:
    resp = requests.get(
        f"https://api.crossref.org/works/{doi}",
        headers={"User-Agent": "ResearchClaw/1.0 (mailto:you@university.edu)"}
    )
    if resp.status_code == 200:
        results.append(resp.json()["message"])
    else:
        print(f"Failed to resolve: {doi}")
```

## DOI Validation and Normalization

```python
import re

def normalize_doi(raw_input):
    """Extract and normalize a DOI from various input formats."""
    # Match DOI pattern: 10.XXXX/...
    match = re.search(r'(10\.\d{4,9}/[^\s]+)', raw_input)
    if match:
        doi = match.group(1)
        # Remove trailing punctuation
        doi = doi.rstrip('.,;:)')
        return doi.lower()
    return None

# Examples
normalize_doi("https://doi.org/10.1038/s41586-021-03819-2")  # 10.1038/s41586-021-03819-2
normalize_doi("DOI: 10.1038/s41586-021-03819-2.")            # 10.1038/s41586-021-03819-2
normalize_doi("See paper at doi.org/10.1038/s41586-021-03819-2 for details")  # works too
```

## Practical Tips

- **Polite pool**: CrossRef provides faster responses to requests with a `User-Agent` header that includes a `mailto:` contact. This is their "polite pool" with higher rate limits.
- **OpenAlex alternative**: OpenAlex (https://api.openalex.org/works/doi:10.xxx/yyy) provides similar metadata for free, with richer entity linking.
- **Handle redirects**: Always use `allow_redirects=True` (or `-L` in curl) as DOIs redirect through the resolver.
- **Caching**: DOI metadata rarely changes. Cache resolved metadata locally to avoid redundant API calls.
- **Rate limits**: CrossRef allows 50 requests/second in the polite pool. For bulk operations, use their data dumps instead.

## See Also

- [doi-content-negotiation](../doi-content-negotiation/SKILL.md) -- Detailed API reference for retrieving metadata in multiple formats via HTTP content negotiation.
