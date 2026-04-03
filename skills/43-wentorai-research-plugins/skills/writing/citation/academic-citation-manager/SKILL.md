---
name: academic-citation-manager
description: "Manage academic citations across BibTeX, APA, MLA, and Chicago formats"
metadata:
  openclaw:
    emoji: "🔖"
    category: "writing"
    subcategory: "citation"
    keywords: ["citation", "BibTeX", "APA", "reference management", "bibliography", "formatting"]
    source: "wentor-research-plugins"
---

# Academic Citation Manager

Manage academic citations across multiple formats (BibTeX, APA 7th, MLA 9th, Chicago, Vancouver, IEEE) with automated retrieval from DOIs, conversion between formats, deduplication, and validation. This skill handles the complete citation lifecycle from initial capture through final manuscript formatting.

## Overview

Citation management is a persistent friction point in academic writing. Researchers collect references from multiple sources (databases, PDFs, colleagues, web pages), store them in different formats, and must output them in the specific style required by each target journal. Errors in citations -- misspelled author names, incorrect years, broken DOIs, inconsistent formatting -- are among the most common reasons for desk rejection and reviewer criticism.

This skill provides a comprehensive citation management workflow that goes beyond what GUI reference managers offer. It can retrieve complete metadata from a DOI in seconds, convert between any citation format, detect and merge duplicate entries, validate entries against CrossRef and OpenAlex databases, and generate properly formatted bibliographies for any major citation style.

The approach is text-based and scriptable, making it ideal for integration with LaTeX workflows, Markdown writing pipelines, and automated document generation. All citation data is stored in standard BibTeX format as the canonical source, with on-demand conversion to other formats for specific manuscript requirements.

## Citation Retrieval

### From DOI

```python
import requests

def get_bibtex_from_doi(doi):
    """Retrieve BibTeX entry from a DOI via CrossRef."""
    url = f"https://doi.org/{doi}"
    headers = {"Accept": "application/x-bibtex"}
    response = requests.get(url, headers=headers, allow_redirects=True)
    if response.status_code == 200:
        return response.text
    return None

# Example
bibtex = get_bibtex_from_doi("10.1038/s41586-021-03819-2")
print(bibtex)
# @article{Jumper_2021,
#   title={Highly accurate protein structure prediction with AlphaFold},
#   author={Jumper, John and Evans, Richard and ...},
#   journal={Nature},
#   volume={596},
#   pages={583--589},
#   year={2021},
#   publisher={Springer}
# }
```

### From OpenAlex

```python
def get_citation_from_openalex(work_id):
    """Retrieve citation data from OpenAlex API."""
    url = f"https://api.openalex.org/works/{work_id}"
    headers = {"User-Agent": "ResearchPlugins/1.0 (https://wentor.ai)"}
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        data = response.json()
        return format_as_bibtex(data)
    return None

def format_as_bibtex(oa_data):
    """Convert OpenAlex data to BibTeX."""
    authorships = oa_data.get("authorships", [])
    author_str = " and ".join(a["author"]["display_name"] for a in authorships)
    first_author = authorships[0]["author"]["display_name"].split()[-1] if authorships else "Unknown"
    year = str(oa_data.get("publication_year", ""))
    key = f"{first_author}_{year}"

    venue = oa_data.get("primary_location", {}) or {}
    journal = (venue.get("source") or {}).get("display_name", "")

    return f"""@article{{{key},
  title={{{oa_data.get('title', '')}}},
  author={{{author_str}}},
  year={{{year}}},
  journal={{{journal}}},
  doi={{{oa_data.get('doi', '')}}}
}}"""
```

### From arXiv ID

```python
def get_bibtex_from_arxiv(arxiv_id):
    """Retrieve BibTeX from arXiv."""
    import feedparser
    url = f"http://export.arxiv.org/api/query?id_list={arxiv_id}"
    feed = feedparser.parse(url)
    if feed.entries:
        entry = feed.entries[0]
        authors = " and ".join(a["name"] for a in entry.authors)
        first_author = entry.authors[0]["name"].split()[-1]
        year = entry.published[:4]
        return f"""@article{{{first_author}_{year},
  title={{{entry.title.replace(chr(10), ' ')}}},
  author={{{authors}}},
  year={{{year}}},
  journal={{arXiv preprint arXiv:{arxiv_id}}},
  url={{https://arxiv.org/abs/{arxiv_id}}}
}}"""
    return None
```

## Format Conversion

### BibTeX to APA 7th

```python
def bibtex_to_apa7(entry):
    """Convert a parsed BibTeX entry to APA 7th edition format."""
    authors = format_apa_authors(entry["author"])
    year = entry.get("year", "n.d.")
    title = entry["title"]
    journal = entry.get("journal", "")
    volume = entry.get("volume", "")
    issue = entry.get("number", "")
    pages = entry.get("pages", "")
    doi = entry.get("doi", "")

    # Article format
    citation = f"{authors} ({year}). {title}. "
    if journal:
        citation += f"*{journal}*"
        if volume:
            citation += f", *{volume}*"
        if issue:
            citation += f"({issue})"
        if pages:
            citation += f", {pages}"
        citation += "."
    if doi:
        citation += f" https://doi.org/{doi}"

    return citation

def format_apa_authors(author_string):
    """Format author names in APA style: Last, F. M."""
    authors = [a.strip() for a in author_string.split(" and ")]
    formatted = []
    for author in authors:
        parts = author.split(", ") if ", " in author else author.rsplit(" ", 1)[::-1]
        if len(parts) >= 2:
            last = parts[0]
            firsts = parts[1].split()
            initials = " ".join(f"{f[0]}." for f in firsts)
            formatted.append(f"{last}, {initials}")
        else:
            formatted.append(parts[0])

    if len(formatted) == 1:
        return formatted[0]
    elif len(formatted) == 2:
        return f"{formatted[0]}, & {formatted[1]}"
    elif len(formatted) <= 20:
        return ", ".join(formatted[:-1]) + f", & {formatted[-1]}"
    else:
        return ", ".join(formatted[:19]) + f", ... {formatted[-1]}"
```

### Format Examples

The same reference in different styles:

**BibTeX:**
```bibtex
@article{Jumper_2021,
  title={Highly accurate protein structure prediction with AlphaFold},
  author={Jumper, John and Evans, Richard and Pritzel, Alexander},
  journal={Nature},
  volume={596},
  pages={583--589},
  year={2021},
  doi={10.1038/s41586-021-03819-2}
}
```

**APA 7th:**
Jumper, J., Evans, R., & Pritzel, A. (2021). Highly accurate protein structure prediction with AlphaFold. *Nature*, *596*, 583-589. https://doi.org/10.1038/s41586-021-03819-2

**MLA 9th:**
Jumper, John, Richard Evans, and Alexander Pritzel. "Highly Accurate Protein Structure Prediction with AlphaFold." *Nature*, vol. 596, 2021, pp. 583-89.

**Chicago (Author-Date):**
Jumper, John, Richard Evans, and Alexander Pritzel. 2021. "Highly Accurate Protein Structure Prediction with AlphaFold." *Nature* 596: 583-89.

**Vancouver:**
Jumper J, Evans R, Pritzel A. Highly accurate protein structure prediction with AlphaFold. Nature. 2021;596:583-9.

**IEEE:**
J. Jumper, R. Evans, and A. Pritzel, "Highly accurate protein structure prediction with AlphaFold," *Nature*, vol. 596, pp. 583-589, 2021.

## Deduplication

### Detecting Duplicate Entries

```python
from difflib import SequenceMatcher

def find_duplicates(bib_entries, threshold=0.85):
    """Find duplicate BibTeX entries by title similarity."""
    duplicates = []
    titles = [(key, normalize_title(entry["title"]))
              for key, entry in bib_entries.items()]

    for i in range(len(titles)):
        for j in range(i + 1, len(titles)):
            similarity = SequenceMatcher(
                None, titles[i][1], titles[j][1]
            ).ratio()
            if similarity >= threshold:
                duplicates.append({
                    "entry_a": titles[i][0],
                    "entry_b": titles[j][0],
                    "similarity": similarity
                })
    return duplicates

def normalize_title(title):
    """Normalize title for comparison."""
    import re
    title = title.lower()
    title = re.sub(r'[{}\\]', '', title)  # Remove LaTeX formatting
    title = re.sub(r'[^a-z0-9\s]', '', title)  # Remove punctuation
    title = ' '.join(title.split())  # Normalize whitespace
    return title

def merge_duplicates(entry_a, entry_b):
    """Merge two duplicate entries, preferring the more complete one."""
    merged = {}
    all_fields = set(list(entry_a.keys()) + list(entry_b.keys()))
    for field in all_fields:
        val_a = entry_a.get(field, "")
        val_b = entry_b.get(field, "")
        # Prefer the longer (more complete) value
        merged[field] = val_a if len(str(val_a)) >= len(str(val_b)) else val_b
    return merged
```

## Validation

### CrossRef Validation

```python
def validate_citation(doi):
    """Validate a citation against CrossRef metadata."""
    url = f"https://api.crossref.org/works/{doi}"
    response = requests.get(url)
    if response.status_code != 200:
        return {"valid": False, "error": "DOI not found in CrossRef"}

    data = response.json()["message"]
    return {
        "valid": True,
        "title": data.get("title", [None])[0],
        "authors": [f"{a.get('family', '')}, {a.get('given', '')}"
                    for a in data.get("author", [])],
        "year": data.get("published-print", {}).get("date-parts", [[None]])[0][0],
        "journal": data.get("container-title", [None])[0],
        "type": data.get("type", "unknown")
    }
```

### Common Citation Errors

| Error | Detection | Fix |
|-------|-----------|-----|
| Missing DOI | Check `doi` field is empty | Query CrossRef by title |
| Wrong year | Compare against CrossRef | Use CrossRef year |
| Author name variants | Fuzzy match against ORCID | Standardize to ORCID name |
| Duplicate entries | Title similarity > 85% | Merge into single entry |
| Broken URL | HTTP HEAD request returns 4xx/5xx | Update or remove URL |
| Incomplete entry | Missing required fields for style | Retrieve from DOI |

## Integration with Writing Tools

### LaTeX

```latex
% In document preamble
\usepackage[backend=biber,style=apa]{biblatex}
\addbibresource{references.bib}

% In text
\textcite{Jumper_2021} showed that...
As demonstrated by previous work \parencite{Jumper_2021}...

% At end of document
\printbibliography
```

### Pandoc Markdown

```markdown
Previous work [@Jumper_2021] showed that...

## References
```

```bash
pandoc paper.md --citeproc --bibliography=references.bib \
  --csl=apa.csl -o paper.pdf
```

## References

- CrossRef API: https://api.crossref.org
- OpenAlex API: https://api.openalex.org
- APA 7th Edition Manual: https://apastyle.apa.org/products/publication-manual-7th-edition
- BibTeX documentation: http://www.bibtex.org
- CSL styles repository: https://github.com/citation-style-language/styles
