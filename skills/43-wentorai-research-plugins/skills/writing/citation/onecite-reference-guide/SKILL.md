---
name: onecite-reference-guide
description: "AI toolkit to parse, complete, and format academic references"
metadata:
  openclaw:
    emoji: "📌"
    category: "writing"
    subcategory: "citation"
    keywords: ["OneCite", "reference formatting", "citation parser", "BibTeX", "metadata completion", "MCP"]
    source: "https://github.com/HzaCode/OneCite"
---

# OneCite Reference Guide

## Overview

OneCite is an AI-powered toolkit for parsing, completing, and formatting academic references. Given incomplete or messy citation strings, it extracts structured metadata, fills in missing fields via API lookups (CrossRef, OpenAlex), and outputs clean formatted references in any style (APA, MLA, BibTeX, Chicago). Available as a Python library and MCP server for agent integration.

## Installation

```bash
# Python package
pip install onecite

# MCP server
npx @onecite/mcp-server
```

## Reference Parsing

```python
from onecite import parse_reference

# Parse messy reference string
ref = parse_reference(
    "Vaswani et al. Attention Is All You Need. "
    "NeurIPS 2017. arXiv:1706.03762"
)

print(ref.title)      # "Attention Is All You Need"
print(ref.authors)    # ["Vaswani, A.", "Shazeer, N.", ...]
print(ref.year)       # 2017
print(ref.venue)      # "NeurIPS"
print(ref.arxiv_id)   # "1706.03762"
print(ref.doi)        # "10.48550/arXiv.1706.03762"
```

## Metadata Completion

```python
from onecite import complete_reference

# Fill in missing metadata from APIs
ref = complete_reference(
    title="Attention Is All You Need",
    # Automatically looks up: DOI, authors, venue,
    # abstract, citation count, pages, volume
)

print(f"DOI: {ref.doi}")
print(f"Authors: {', '.join(ref.authors)}")
print(f"Pages: {ref.pages}")
print(f"Volume: {ref.volume}")
print(f"Citations: {ref.citation_count}")
```

## Format Conversion

```python
from onecite import format_reference, parse_reference

ref = parse_reference(
    "B. Kerbl et al., '3D Gaussian Splatting for Real-Time "
    "Radiance Field Rendering,' SIGGRAPH 2023"
)

# Output in different styles
print(format_reference(ref, style="apa"))
# Kerbl, B., Kopanas, G., Leimkühler, T., & Drettakis, G.
# (2023). 3D Gaussian Splatting for Real-Time Radiance Field
# Rendering. ACM SIGGRAPH 2023.

print(format_reference(ref, style="bibtex"))
# @inproceedings{kerbl2023,
#   title = {3D Gaussian Splatting...},
#   author = {Kerbl, Bernhard and ...},
#   booktitle = {ACM SIGGRAPH 2023},
#   year = {2023}
# }

print(format_reference(ref, style="mla"))
print(format_reference(ref, style="chicago"))
print(format_reference(ref, style="ieee"))
```

## Batch Processing

```python
from onecite import process_references

# Process a list of raw reference strings
raw_refs = [
    "Vaswani et al. Attention Is All You Need. NeurIPS 2017",
    "Devlin et al. BERT. NAACL 2019",
    "Brown et al. Language Models are Few-Shot Learners. 2020",
]

results = process_references(
    raw_refs,
    complete=True,     # Fill missing metadata
    format="bibtex",   # Output format
    deduplicate=True,  # Remove duplicates
)

# Save as .bib file
with open("references.bib", "w") as f:
    for ref in results:
        f.write(ref.formatted + "\n\n")
```

## MCP Server Usage

```json
{
  "mcpServers": {
    "onecite": {
      "command": "npx",
      "args": ["@onecite/mcp-server"],
      "tools": [
        "parse_reference",
        "complete_reference",
        "format_reference",
        "search_paper",
        "get_bibtex"
      ]
    }
  }
}
```

## Reference Validation

```python
from onecite import validate_references

# Check a .bib file for issues
issues = validate_references("references.bib")

for issue in issues:
    print(f"[{issue.severity}] {issue.entry}: {issue.message}")
    # [WARNING] smith2023: Missing DOI
    # [ERROR] jones2024: Author field empty
    # [INFO] chen2022: Title case inconsistency
```

## Use Cases

1. **Reference cleanup**: Fix messy bibliographies
2. **Format conversion**: Convert between citation styles
3. **Metadata completion**: Fill in missing DOIs, pages, venues
4. **Agent integration**: MCP server for AI citation workflows
5. **Validation**: Check references for completeness and errors

## References

- [OneCite GitHub](https://github.com/HzaCode/OneCite)
- [CrossRef API](https://api.crossref.org/)
- [Citation Style Language](https://citationstyles.org/)
