---
name: oeis-api
description: "On-Line Encyclopedia of Integer Sequences API"
metadata:
  openclaw:
    emoji: "🔍"
    category: "domains"
    subcategory: "math"
    keywords: ["number theory", "algebra", "probability theory", "applied mathematics"]
    source: "https://oeis.org/eishelp1.html"
---

# OEIS API Guide

## Overview

The On-Line Encyclopedia of Integer Sequences (OEIS) is a comprehensive database of integer sequences, founded by Neil Sloane in 1964 and now containing over 370,000 entries. It is one of the most widely cited resources in mathematics, serving as the definitive reference for identifying, cataloging, and exploring integer sequences that arise in combinatorics, number theory, algebra, analysis, and applied mathematics.

The OEIS provides a web-accessible search interface that can also be used programmatically to query sequences by their terms, by A-number (the unique identifier for each sequence), or by keyword. The API returns structured data in JSON or plain text format, including the sequence terms, formulas, generating functions, references, links to related sequences, and contributed programs in various languages.

Mathematicians, computer scientists, physicists, and researchers in any quantitative discipline use the OEIS to identify unknown sequences encountered in their work, verify conjectures, discover connections between different areas of mathematics, and access formulas and programs for computing sequence terms. It is an indispensable tool for both pure and applied mathematical research.

## Authentication

No authentication required. The OEIS is a free, open resource that does not require any API key, token, or registration. All queries are publicly accessible. The OEIS Foundation operates as a non-profit and relies on voluntary contributions.

## Core Endpoints

### search: Search for Sequences

Search the OEIS database by sequence terms, keywords, A-number, or author name. This is the primary endpoint for querying the encyclopedia.

- **URL**: `GET https://oeis.org/search`
- **Parameters**:

| Parameter | Type   | Required | Description                                                   |
|-----------|--------|----------|---------------------------------------------------------------|
| q         | string | Yes      | Search query: sequence terms (comma-separated), keyword, or A-number |
| fmt       | string | No       | Output format: `json`, `text`, `html` (default)               |
| start     | int    | No       | Offset for pagination (default 0)                             |

- **Example**:

```bash
# Search by sequence terms
curl "https://oeis.org/search?q=1,1,2,3,5,8,13,21&fmt=json"

# Search by A-number
curl "https://oeis.org/search?q=A000045&fmt=json"

# Search by keyword
curl "https://oeis.org/search?q=catalan+numbers&fmt=json"
```

- **Response**: Returns a JSON object with `count` (total results), `start`, and `results` array. Each result contains `number` (A-number as integer), `name` (description), `data` (comma-separated terms), `offset`, `formula` (array of formula strings), `comment` (array), `reference` (array of bibliographic references), `link` (array of URLs), `program` (array of code implementations), and `xref` (cross-references to related sequences).

### lookup: Direct Sequence Retrieval

Retrieve a specific sequence by its A-number directly via the URL path. This provides a simpler access pattern for known sequences.

- **URL**: `GET https://oeis.org/A{number}`
- **Parameters**:

| Parameter | Type   | Required | Description                                             |
|-----------|--------|----------|---------------------------------------------------------|
| number    | int    | Yes      | The sequence A-number (in the URL path)                 |
| fmt       | string | No       | Output format: `json`, `text`, `html`                   |

- **Example**:

```bash
# Retrieve the Fibonacci sequence (A000045)
curl "https://oeis.org/A000045?fmt=json"

# Retrieve the prime numbers (A000040)
curl "https://oeis.org/A000040?fmt=json"
```

- **Response**: Returns the same structured JSON as the search endpoint but for a single sequence, including `number`, `name`, `data`, `formula`, `maple` (Maple code), `mathematica` (Mathematica code), `program` (other language implementations), and `keyword` (classification tags like `nonn`, `easy`, `nice`).

## Rate Limits

No formal rate limits are published for the OEIS. However, the service is run by a non-profit organization with limited infrastructure. Users should be respectful and avoid sending more than a few requests per second. For bulk data access, the OEIS provides downloadable data files at https://oeis.org/stripped.gz (sequence terms) and https://oeis.org/names.gz (sequence names) which are more appropriate for large-scale analysis.

## Common Patterns

### Identify an Unknown Sequence

When you encounter an integer sequence in your research and want to identify it:

```python
import requests

# You found this sequence in your combinatorial analysis
unknown_terms = "1,4,9,16,25,36,49,64"

resp = requests.get("https://oeis.org/search", params={"q": unknown_terms, "fmt": "json"})
data = resp.json()

if data["count"] > 0:
    seq = data["results"][0]
    print(f"A{seq['number']:06d}: {seq['name']}")
    print(f"Terms: {seq['data']}")
    if seq.get("formula"):
        print(f"Formula: {seq['formula'][0]}")
else:
    print("No matching sequence found in OEIS")
```

### Retrieve Formulas and Programs

Get computational formulas and reference implementations for a known sequence:

```python
import requests

# Get the Catalan numbers (A000108)
resp = requests.get("https://oeis.org/A000108", params={"fmt": "json"})
data = resp.json()
seq = data["results"][0]

print(f"Sequence: {seq['name']}")
print(f"\nFirst terms: {seq['data']}")

print("\nFormulas:")
for f in seq.get("formula", [])[:5]:
    print(f"  {f}")

print("\nPrograms:")
for p in seq.get("program", [])[:5]:
    print(f"  {p}")
```

### Cross-Reference Related Sequences

Explore mathematical connections through cross-references:

```python
import requests

resp = requests.get("https://oeis.org/search", params={"q": "A000045", "fmt": "json"})
data = resp.json()

if data["results"]:
    seq = data["results"][0]
    print(f"Fibonacci numbers ({seq['name']})")
    print(f"\nCross-references:")
    for xref in seq.get("xref", [])[:10]:
        print(f"  {xref}")
```

## References

- Official help and documentation: https://oeis.org/eishelp1.html
- OEIS homepage: https://oeis.org/
- OEIS Wiki: https://oeis.org/wiki/Welcome
- Downloadable data files: https://oeis.org/stripped.gz
- OEIS Foundation: https://oeisf.org/
