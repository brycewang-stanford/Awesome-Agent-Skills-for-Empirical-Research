---
name: anystyle-api
description: "Citation reference parser using machine learning"
metadata:
  openclaw:
    emoji: "🔍"
    category: "tools"
    subcategory: "document"
    keywords: ["PDF parsing", "document chunking", "format conversion", "PDF extraction"]
    source: "https://anystyle.io/"
---

# AnyStyle API Guide

## Overview

AnyStyle is a fast and smart citation reference parser that uses machine learning (specifically conditional random fields, CRFs) to extract structured bibliographic data from unformatted citation strings. It can parse raw reference text into structured fields such as author, title, journal, volume, pages, year, and DOI, handling the enormous variety of citation formats found in academic literature.

The AnyStyle service provides both a web interface and an API endpoint for programmatic citation parsing. Unlike rule-based parsers that rely on specific citation style templates, AnyStyle uses a trained machine learning model that generalizes across citation formats, making it effective for parsing references from diverse disciplines and publication traditions where citation styles vary widely.

Researchers, librarians, digital humanists, and research software developers use AnyStyle to extract structured references from PDF documents, legacy bibliographies, dissertation reference lists, and scanned documents. It is particularly valuable for building citation networks, enriching bibliographic databases, migrating references between management tools, and processing large volumes of unstructured citation data that would be impractical to parse manually.

## Authentication

No authentication required. The AnyStyle web service is freely accessible without any API key, token, or registration. The service can be used via the web interface at https://anystyle.io/ or through its API endpoint. For heavy usage or private deployments, AnyStyle is also available as an open-source Ruby gem that can be installed locally.

## Core Endpoints

### parse: Parse Citation References

Submit raw citation text and receive structured bibliographic data extracted by the machine learning parser. The endpoint accepts one or more citation strings and returns parsed fields for each reference.

- **URL**: `POST https://anystyle.io/parse`
- **Parameters**:

| Parameter | Type   | Required | Description                                                  |
|-----------|--------|----------|--------------------------------------------------------------|
| body      | string | Yes      | Raw citation text (one reference per line in the POST body)  |
| format    | string | No       | Output format: `json` (default), `xml`, `bib` (BibTeX)      |

- **Example**:

```bash
# Parse a single citation
curl -X POST "https://anystyle.io/parse" \
  -H "Content-Type: text/plain" \
  -d "Vaswani, A., Shazeer, N., Parmar, N., et al. (2017). Attention is all you need. Advances in Neural Information Processing Systems, 30, 5998-6008."

# Parse multiple citations (one per line)
curl -X POST "https://anystyle.io/parse" \
  -H "Content-Type: text/plain" \
  -d "Vaswani, A. et al. (2017). Attention is all you need. NeurIPS 30, 5998-6008.
LeCun, Y., Bengio, Y., & Hinton, G. (2015). Deep learning. Nature, 521(7553), 436-444.
Krizhevsky, A., Sutskever, I., & Hinton, G. E. (2012). ImageNet classification with deep convolutional neural networks. NeurIPS 25."
```

- **Response**: Returns an array of parsed citation objects, each containing extracted fields:

```json
[
  {
    "author": [{"family": "Vaswani", "given": "A."}, {"family": "Shazeer", "given": "N."}],
    "title": ["Attention is all you need"],
    "date": ["2017"],
    "container-title": ["Advances in Neural Information Processing Systems"],
    "volume": ["30"],
    "pages": ["5998-6008"],
    "type": "article-journal"
  }
]
```

Key response fields include `author` (array of name objects), `title`, `date`, `container-title` (journal/conference name), `volume`, `issue`, `pages`, `doi`, `url`, `publisher`, `location`, and `type` (inferred reference type).

## Rate Limits

No formal rate limits are documented for the AnyStyle web service. However, the service is provided as a free community resource, so users should exercise responsible usage patterns. For high-volume parsing tasks (thousands of citations or more), it is strongly recommended to install the AnyStyle Ruby gem locally:

```bash
gem install anystyle
```

The local installation provides the same parsing capabilities without any network dependencies or rate concerns, and supports batch processing of large reference lists and PDF files directly.

## Common Patterns

### Parse a Reference List from a Paper

Extract structured data from a raw reference list copied from a PDF:

```python
import requests

references = """Vaswani, A., Shazeer, N., Parmar, N., Uszkoreit, J., Jones, L., Gomez, A. N., ... & Polosukhin, I. (2017). Attention is all you need. Advances in neural information processing systems, 30.
Devlin, J., Chang, M. W., Lee, K., & Toutanova, K. (2019). BERT: Pre-training of deep bidirectional transformers for language understanding. NAACL-HLT, 4171-4186.
Brown, T. B., Mann, B., Ryder, N., Subbiah, M., et al. (2020). Language models are few-shot learners. NeurIPS 33, 1877-1901."""

resp = requests.post(
    "https://anystyle.io/parse",
    headers={"Content-Type": "text/plain"},
    data=references
)

for ref in resp.json():
    authors = ", ".join(
        f"{a.get('family', '')} {a.get('given', '')}" for a in ref.get("author", [])
    )
    title = ref.get("title", [""])[0]
    year = ref.get("date", [""])[0]
    journal = ref.get("container-title", [""])[0]
    print(f"{authors} ({year}). {title}. {journal}")
```

### Batch Process Citations from Multiple Documents

Process reference lists from multiple papers for citation network analysis:

```python
import requests

def parse_references(raw_text):
    """Parse raw citation text into structured records."""
    resp = requests.post(
        "https://anystyle.io/parse",
        headers={"Content-Type": "text/plain"},
        data=raw_text
    )
    if resp.status_code == 200:
        return resp.json()
    return []

# Process references from multiple source documents
documents = {
    "paper_A": "Smith, J. (2020). Title A. Journal X, 1, 1-10.\nDoe, J. (2019). Title B. Journal Y, 2, 20-30.",
    "paper_B": "Jones, K. (2021). Title C. Conference Z, 100-110.\nSmith, J. (2020). Title A. Journal X, 1, 1-10."
}

citation_graph = {}
for doc_id, refs in documents.items():
    parsed = parse_references(refs)
    citation_graph[doc_id] = parsed
    print(f"{doc_id}: parsed {len(parsed)} references")
```

### Convert Citations to BibTeX Format

Transform unstructured references into BibTeX entries for use with LaTeX:

```python
import requests

citation = "Goodfellow, I., Bengio, Y., & Courville, A. (2016). Deep Learning. MIT Press."

resp = requests.post(
    "https://anystyle.io/parse",
    headers={"Content-Type": "text/plain"},
    data=citation
)

parsed = resp.json()[0]
# Build a BibTeX entry from parsed fields
authors = " and ".join(
    f"{a.get('family', '')}, {a.get('given', '')}" for a in parsed.get("author", [])
)
bib_key = parsed.get("author", [{}])[0].get("family", "unknown").lower() + parsed.get("date", ["0000"])[0]

print(f"@book{{{bib_key},")
print(f"  author = {{{authors}}},")
print(f"  title = {{{parsed.get('title', [''])[0]}}},")
print(f"  year = {{{parsed.get('date', [''])[0]}}},")
print(f"  publisher = {{{parsed.get('publisher', [''])[0] if parsed.get('publisher') else 'Unknown'}}}")
print("}")
```

### Local Installation for High-Volume Processing

For large-scale processing, install AnyStyle locally as a Ruby gem:

```bash
# Install the gem
gem install anystyle

# Parse references from command line
anystyle parse "Smith, J. (2020). My Paper. Journal, 1, 1-10."

# Parse references from a text file
anystyle parse references.txt --format json > parsed.json

# Parse references directly from a PDF
anystyle find document.pdf --format json > extracted_refs.json
```

## References

- AnyStyle web service: https://anystyle.io/
- AnyStyle GitHub repository: https://github.com/inukshuk/anystyle
- AnyStyle Ruby gem: https://rubygems.org/gems/anystyle
- AnyStyle CLI documentation: https://github.com/inukshuk/anystyle-cli
- CSL (Citation Style Language): https://citationstyles.org/
