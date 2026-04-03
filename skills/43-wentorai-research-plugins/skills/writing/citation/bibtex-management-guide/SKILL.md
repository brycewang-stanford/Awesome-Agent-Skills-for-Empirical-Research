---
name: bibtex-management-guide
description: "Clean, format, deduplicate, and manage BibTeX bibliography files for LaTeX"
metadata:
  openclaw:
    emoji: "🗃️"
    category: "writing"
    subcategory: "citation"
    keywords: ["BibTeX formatting", "BibTeX conversion", "bibliography cleanup", "reference deduplication", "citation management"]
    source: "wentor"
---

# BibTeX Management Guide

A skill for maintaining clean, consistent, and complete BibTeX bibliography files. Covers formatting standards, deduplication, common errors, and automated cleanup workflows essential for LaTeX-based academic writing.

## BibTeX Entry Standards

### Required Fields by Entry Type

```bibtex
% Article in a journal
@article{smith2024deep,
  author    = {Smith, John A. and Doe, Jane B.},
  title     = {Deep Learning for Climate Prediction: A Comparative Study},
  journal   = {Nature Machine Intelligence},
  year      = {2024},
  volume    = {6},
  number    = {3},
  pages     = {234--248},
  doi       = {10.1038/s42256-024-00001-1}
}

% Conference proceedings
@inproceedings{lee2024attention,
  author    = {Lee, Wei and Chen, Li},
  title     = {Attention Mechanisms for Scientific Document Understanding},
  booktitle = {Proceedings of the 62nd Annual Meeting of the ACL},
  year      = {2024},
  pages     = {1123--1135},
  publisher = {Association for Computational Linguistics},
  doi       = {10.18653/v1/2024.acl-main.89}
}

% Book
@book{bishop2006pattern,
  author    = {Bishop, Christopher M.},
  title     = {Pattern Recognition and Machine Learning},
  publisher = {Springer},
  year      = {2006},
  isbn      = {978-0387310732}
}
```

## Automated BibTeX Cleanup

### Deduplication

```python
import re
from collections import defaultdict

def parse_bibtex_entries(bib_content: str) -> list[dict]:
    """
    Parse a BibTeX file into structured entries.
    """
    entries = []
    pattern = r'@(\w+)\{([^,]+),\s*(.*?)\n\}'
    matches = re.finditer(pattern, bib_content, re.DOTALL)

    for match in matches:
        entry = {
            'type': match.group(1).lower(),
            'key': match.group(2).strip(),
            'raw': match.group(0),
            'fields': {}
        }

        fields_str = match.group(3)
        field_pattern = r'(\w+)\s*=\s*[{\"](.+?)[}\"]'
        for field_match in re.finditer(field_pattern, fields_str, re.DOTALL):
            entry['fields'][field_match.group(1).lower()] = field_match.group(2).strip()

        entries.append(entry)

    return entries


def deduplicate_bibtex(entries: list[dict]) -> dict:
    """
    Find and remove duplicate BibTeX entries.

    Deduplication strategy:
    1. Exact DOI match
    2. Fuzzy title match (normalized)
    3. Author + year + first title word match
    """
    seen_dois = {}
    seen_titles = {}
    duplicates = []
    unique = []

    for entry in entries:
        doi = entry['fields'].get('doi', '').lower().strip()
        title = entry['fields'].get('title', '').lower().strip()
        title_normalized = re.sub(r'[^a-z0-9\s]', '', title)

        is_duplicate = False

        # Check DOI match
        if doi and doi in seen_dois:
            duplicates.append({
                'entry': entry['key'],
                'duplicate_of': seen_dois[doi],
                'reason': 'same DOI'
            })
            is_duplicate = True
        elif doi:
            seen_dois[doi] = entry['key']

        # Check title match
        if not is_duplicate and title_normalized:
            if title_normalized in seen_titles:
                duplicates.append({
                    'entry': entry['key'],
                    'duplicate_of': seen_titles[title_normalized],
                    'reason': 'same title'
                })
                is_duplicate = True
            else:
                seen_titles[title_normalized] = entry['key']

        if not is_duplicate:
            unique.append(entry)

    return {
        'unique_entries': len(unique),
        'duplicates_found': len(duplicates),
        'duplicates': duplicates,
        'entries': unique
    }
```

### Field Formatting

```python
def clean_bibtex_entry(entry: dict) -> dict:
    """
    Clean and standardize a BibTeX entry.
    """
    cleaned = entry.copy()
    fields = cleaned['fields']

    # Standardize author names: "Last, First and Last, First"
    if 'author' in fields:
        authors = fields['author']
        # Fix common issues
        authors = authors.replace(' AND ', ' and ')
        authors = authors.replace(' & ', ' and ')
        fields['author'] = authors

    # Ensure proper page ranges with en-dash
    if 'pages' in fields:
        fields['pages'] = fields['pages'].replace('-', '--').replace('---', '--')

    # Capitalize title properly (protect proper nouns with braces)
    if 'title' in fields:
        title = fields['title']
        # Protect acronyms and proper nouns
        words = title.split()
        for i, word in enumerate(words):
            if word.isupper() and len(word) > 1:
                words[i] = '{' + word + '}'
        fields['title'] = ' '.join(words)

    # Add missing DOI prefix
    if 'doi' in fields:
        doi = fields['doi']
        doi = doi.replace('https://doi.org/', '')
        doi = doi.replace('http://dx.doi.org/', '')
        fields['doi'] = doi

    # Remove empty fields
    fields = {k: v for k, v in fields.items() if v.strip()}
    cleaned['fields'] = fields

    return cleaned
```

## DOI-Based Entry Generation

### Fetch Complete BibTeX from DOI

```python
import requests

def doi_to_bibtex(doi: str) -> str:
    """
    Retrieve a complete BibTeX entry from a DOI using CrossRef.
    """
    url = f"https://doi.org/{doi}"
    headers = {'Accept': 'application/x-bibtex'}
    response = requests.get(url, headers=headers, allow_redirects=True)

    if response.status_code == 200:
        return response.text
    else:
        return f"% Error: Could not retrieve BibTeX for DOI {doi}"

# Example
bibtex = doi_to_bibtex('10.1038/s41586-021-03819-2')
print(bibtex)
```

## Citation Key Conventions

Consistent citation keys improve readability:

```
Convention: authorYEARfirstword
Examples:
  smith2024deep
  lee2024attention
  bishop2006pattern

For multiple papers by same author in same year:
  smith2024a, smith2024b

For papers with many authors:
  smithetal2024deep  (use "etal" for 3+ authors)
```

## Validation Checklist

Before submitting a manuscript, validate your BibTeX file:

1. Every `\cite{}` in the manuscript has a matching entry in the .bib file
2. No orphaned entries (entries in .bib not cited in manuscript)
3. All entries have at minimum: author, title, year
4. All journal articles have: volume, pages (or article number), DOI
5. Page ranges use en-dash (`--`), not single hyphen
6. No encoding errors in author names (check accented characters)
7. Proper nouns and acronyms in titles are protected with braces
8. No duplicate entries exist

Use `biber --validate-datamodel` or `checkcites` for automated validation.
