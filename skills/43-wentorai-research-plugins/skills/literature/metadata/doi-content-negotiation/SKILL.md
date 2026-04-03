---
name: doi-content-negotiation
description: "Retrieve structured metadata from any DOI via HTTP content negotiation"
metadata:
  openclaw:
    emoji: "🔗"
    category: "literature"
    subcategory: "metadata"
    keywords: ["DOI", "content negotiation", "metadata retrieval", "BibTeX", "citation metadata", "linked data"]
    source: "https://citation.crosscite.org/"
---

# DOI Content Negotiation

## Overview

Any DOI can return structured metadata in multiple formats through HTTP content negotiation — simply set the `Accept` header when requesting `https://doi.org/{doi}`. This is the most universal way to get citation metadata, BibTeX entries, JSON-LD, and RDF from any publisher without needing a specific API. Works for all 300M+ registered DOIs. Free, no authentication.

## Usage

### Basic Content Negotiation

```bash
# Get JSON citation metadata (Citeproc JSON)
curl -LH "Accept: application/vnd.citationstyles.csl+json" \
  "https://doi.org/10.1038/nature14539"

# Get BibTeX
curl -LH "Accept: application/x-bibtex" \
  "https://doi.org/10.1038/nature14539"

# Get RIS format
curl -LH "Accept: application/x-research-info-systems" \
  "https://doi.org/10.1038/nature14539"

# Get formatted citation (APA style)
curl -LH "Accept: text/x-bibliography; style=apa" \
  "https://doi.org/10.1038/nature14539"

# Get formatted citation (Chicago style)
curl -LH "Accept: text/x-bibliography; style=chicago-author-date" \
  "https://doi.org/10.1038/nature14539"
```

### Available Formats

| Accept Header | Format | Use Case |
|--------------|--------|----------|
| `application/vnd.citationstyles.csl+json` | Citeproc JSON | Programmatic metadata |
| `application/x-bibtex` | BibTeX | LaTeX bibliography |
| `application/x-research-info-systems` | RIS | Reference managers |
| `text/x-bibliography; style=apa` | Formatted text | Direct citation |
| `application/rdf+xml` | RDF/XML | Linked data |
| `text/turtle` | Turtle RDF | Linked data |
| `application/vnd.schemaorg.ld+json` | Schema.org JSON-LD | Web metadata |
| `application/json` | DataCite JSON | DataCite DOIs |
| `application/vnd.crossref.unixref+xml` | Crossref XML | Full Crossref metadata |

### Citation Styles

Over 9,000 CSL styles available:

```bash
# APA 7th edition
style=apa

# Chicago Manual of Style (author-date)
style=chicago-author-date

# IEEE
style=ieee

# MLA
style=modern-language-association

# Harvard
style=harvard-cite-them-right

# Vancouver (medical)
style=vancouver

# Nature
style=nature
```

## Citeproc JSON Response

```json
{
  "DOI": "10.1038/nature14539",
  "type": "article-journal",
  "title": "Deep learning",
  "author": [
    {"given": "Yann", "family": "LeCun"},
    {"given": "Yoshua", "family": "Bengio"},
    {"given": "Geoffrey", "family": "Hinton"}
  ],
  "container-title": "Nature",
  "volume": "521",
  "issue": "7553",
  "page": "436-444",
  "issued": {"date-parts": [[2015, 5, 28]]},
  "publisher": "Springer Science and Business Media LLC",
  "ISSN": ["0028-0836", "1476-4687"],
  "URL": "http://dx.doi.org/10.1038/nature14539",
  "abstract": "Deep learning allows computational models..."
}
```

## Python Usage

```python
import requests


def get_metadata(doi: str) -> dict:
    """Get structured metadata for a DOI."""
    resp = requests.get(
        f"https://doi.org/{doi}",
        headers={"Accept": "application/vnd.citationstyles.csl+json"},
        allow_redirects=True,
    )
    resp.raise_for_status()
    return resp.json()


def get_bibtex(doi: str) -> str:
    """Get BibTeX entry for a DOI."""
    resp = requests.get(
        f"https://doi.org/{doi}",
        headers={"Accept": "application/x-bibtex"},
        allow_redirects=True,
    )
    resp.raise_for_status()
    return resp.text


def get_formatted_citation(doi: str,
                            style: str = "apa") -> str:
    """Get a formatted citation string."""
    resp = requests.get(
        f"https://doi.org/{doi}",
        headers={
            "Accept": f"text/x-bibliography; style={style}",
        },
        allow_redirects=True,
    )
    resp.raise_for_status()
    return resp.text.strip()


def batch_bibtex(dois: list) -> str:
    """Generate BibTeX file for multiple DOIs."""
    entries = []
    for doi in dois:
        try:
            bib = get_bibtex(doi)
            entries.append(bib)
        except requests.HTTPError:
            entries.append(f"% Failed to resolve: {doi}")
    return "\n\n".join(entries)


# Example: get metadata
meta = get_metadata("10.1038/nature14539")
authors = ", ".join(
    f"{a['given']} {a['family']}" for a in meta.get("author", [])
)
print(f"{meta['title']}")
print(f"  Authors: {authors}")
print(f"  {meta.get('container-title')} ({meta.get('volume')})")

# Example: get BibTeX
bibtex = get_bibtex("10.1038/nature14539")
print(f"\nBibTeX:\n{bibtex}")

# Example: formatted APA citation
apa = get_formatted_citation("10.1038/nature14539", "apa")
print(f"\nAPA: {apa}")

# Example: batch export
bibliography = batch_bibtex([
    "10.1038/nature14539",
    "10.5555/3295222.3295349",
])
with open("references.bib", "w") as f:
    f.write(bibliography)
```

## Use Cases

1. **Bibliography generation**: Export BibTeX/RIS for any DOI list
2. **Citation formatting**: Generate properly formatted citations
3. **Metadata extraction**: Get structured metadata for data pipelines
4. **Linked data**: Retrieve RDF for knowledge graph construction
5. **Verification**: Confirm publication details from authoritative source

## References

- [DOI Content Negotiation](https://citation.crosscite.org/docs.html)
- [Crossref Content Negotiation](https://www.crossref.org/documentation/retrieve-metadata/content-negotiation/)
- [CSL Style Repository](https://github.com/citation-style-language/styles)

## See Also

- [doi-resolution-guide](../doi-resolution-guide/SKILL.md) -- Conceptual overview of DOI resolution, validation, normalization, and CrossRef API usage.
