---
name: bioc-pmc-api
description: "Access PMC Open Access articles in BioC format for text mining"
metadata:
  openclaw:
    emoji: "🧬"
    category: "literature"
    subcategory: "fulltext"
    keywords: ["bioc", "pmc", "text mining", "biomedical nlp", "full text", "pubmed central"]
    source: "https://www.ncbi.nlm.nih.gov/research/bionlp/APIs/BioC-PMC/"
---

# BioC API for PMC Open Access

## Overview

The BioC API provides full-text articles from PubMed Central (PMC) in the BioC format — a simplified XML/JSON structure designed specifically for biomedical text mining. Unlike the standard PMC OAI service (which returns JATS XML), BioC pre-segments text into passages with offset annotations, making it ideal for NLP pipelines, named entity recognition, relation extraction, and other text mining tasks. Free, no authentication required.

## API Endpoints

### Base URL

```
https://www.ncbi.nlm.nih.gov/research/bionlp/RESTful/pmcoa.cgi/BioC_json/{PMCID}/unicode
```

### Retrieve by PMC ID

```bash
# JSON format (recommended for programmatic use)
curl "https://www.ncbi.nlm.nih.gov/research/bionlp/RESTful/pmcoa.cgi/BioC_json/PMC6267067/unicode"

# XML format
curl "https://www.ncbi.nlm.nih.gov/research/bionlp/RESTful/pmcoa.cgi/BioC_xml/PMC6267067/unicode"

# ASCII encoding (strips non-ASCII characters)
curl "https://www.ncbi.nlm.nih.gov/research/bionlp/RESTful/pmcoa.cgi/BioC_json/PMC6267067/ascii"
```

### Retrieve by PubMed ID

```bash
# Convert PMID to PMCID first, then query
curl "https://www.ncbi.nlm.nih.gov/pmc/utils/idconv/v1.0/?ids=29346600&format=json"
# Returns: {"records": [{"pmid": "29346600", "pmcid": "PMC6267067", ...}]}
```

## BioC JSON Structure

```json
{
  "source": "PMC",
  "date": "2024-01-15",
  "key": "collection.key",
  "documents": [
    {
      "id": "PMC6267067",
      "passages": [
        {
          "infons": {
            "section_type": "TITLE",
            "type": "title"
          },
          "offset": 0,
          "text": "Article Title Here"
        },
        {
          "infons": {
            "section_type": "ABSTRACT",
            "type": "abstract"
          },
          "offset": 25,
          "text": "Background: This study investigates..."
        },
        {
          "infons": {
            "section_type": "INTRO",
            "type": "paragraph"
          },
          "offset": 350,
          "text": "The introduction text..."
        }
      ]
    }
  ]
}
```

Key fields:
- `passages[].infons.section_type`: TITLE, ABSTRACT, INTRO, METHODS, RESULTS, DISCUSS, CONCL, REF, FIG, TABLE
- `passages[].offset`: Character offset from document start
- `passages[].text`: Plain text content of the passage

## Python Usage

```python
import requests
import json

def get_bioc_article(pmcid: str, fmt: str = "json") -> dict:
    """Fetch a PMC article in BioC format."""
    url = f"https://www.ncbi.nlm.nih.gov/research/bionlp/RESTful/pmcoa.cgi/BioC_{fmt}/{pmcid}/unicode"
    resp = requests.get(url, timeout=30)
    resp.raise_for_status()
    return resp.json() if fmt == "json" else resp.text

def extract_sections(bioc_doc: dict) -> dict:
    """Extract text organized by section type."""
    sections = {}
    for doc in bioc_doc.get("documents", []):
        for passage in doc.get("passages", []):
            section = passage.get("infons", {}).get("section_type", "OTHER")
            text = passage.get("text", "")
            sections.setdefault(section, []).append(text)
    return {k: "\n".join(v) for k, v in sections.items()}

# Example: fetch and parse
article = get_bioc_article("PMC6267067")
sections = extract_sections(article)
print(f"Title: {sections.get('TITLE', 'N/A')}")
print(f"Abstract length: {len(sections.get('ABSTRACT', ''))} chars")
print(f"Sections found: {list(sections.keys())}")
```

## Data Coverage

- **PMC Open Access Subset**: ~4M+ articles with CC licenses
- **Author Manuscript Collection**: NIH-funded author manuscripts
- Updates: New articles added daily

## Rate Limits

- Follow NCBI standard: **3 requests per second**
- For bulk access, use the PMC FTP service instead
- Add `tool=your_tool_name&email=your@email.com` to requests for priority queue

## Citation

When using this API in publications, cite:
> Comeau DC, Wei CH, Islamaj Dogan R, Lu Z. PMC text mining subset in BioC: about 3 million full text articles and growing. *Bioinformatics*, btz070, 2019.

## References

- [BioC-PMC API Documentation](https://www.ncbi.nlm.nih.gov/research/bionlp/APIs/BioC-PMC/)
- [BioC Format Specification](http://bioc.sourceforge.net/)
- [PMC Open Access Subset](https://www.ncbi.nlm.nih.gov/pmc/tools/openftlist/)
