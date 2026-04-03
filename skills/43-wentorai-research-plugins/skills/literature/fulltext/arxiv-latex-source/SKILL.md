---
name: arxiv-latex-source
description: "Download and parse LaTeX source files from arXiv preprints"
metadata:
  openclaw:
    emoji: "📜"
    category: "literature"
    subcategory: "fulltext"
    keywords: ["arXiv", "LaTeX source", "paper parsing", "formula extraction", "full text", "preprint"]
    source: "https://info.arxiv.org/help/bulk_data_s3.html"
---

# arXiv LaTeX Source Access Guide

## Overview

arXiv stores the original LaTeX source files for the vast majority of its 2.4 million+ preprints. Accessing LaTeX source provides major advantages over PDF parsing: exact mathematical notation as written by the author, structured sections and labels, machine-readable bibliography entries, and intact figure captions, table data, and cross-references.

For formula extraction, citation graph construction, section-level text analysis, or training data curation for scientific language models, LaTeX source is the gold standard. PDF parsing introduces OCR errors in equations, loses structural hierarchy, and mangles complex tables.

The e-print endpoint serves source bundles as gzip-compressed tarballs (`.tar.gz`) containing `.tex` files, figures, `.bib`/`.bbl` bibliography files, style files, and supplementary materials. No authentication is required.

## Authentication

No authentication or API key is required. The e-print endpoint is publicly accessible. However, arXiv asks that automated tools set a descriptive `User-Agent` header and comply with rate limits.

## Core Endpoints

### Download LaTeX Source

- **URL**: `GET https://arxiv.org/e-print/{arxiv_id}`
- **Response**: `application/gzip` — a `.tar.gz` archive containing the source files
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | arxiv_id | string | Yes | arXiv identifier, e.g. `2301.00001` or `2301.00001v2` for a specific version |

- **Example**:
  ```bash
  # Download source archive (response: 200, application/gzip, ~1.3 MB)
  curl -sL -o source.tar.gz "https://arxiv.org/e-print/2301.00001"

  # List archive contents
  tar tz -f source.tar.gz | head -10
  # ACM-Reference-Format.bbx
  # ACM-Reference-Format.bst
  # Image_1.jpg
  # README.txt
  # acmart.cls
  ```

- **Content-Disposition header**: `attachment; filename="arXiv-2301.00001v1.tar.gz"`
- **ETag**: SHA-256 hash provided for caching: `sha256:f1ffe8ec...`

### Format Detection

The endpoint almost always returns a gzip-compressed tar archive. Rare cases (very old or single-file submissions) may return a single gzip-compressed `.tex` file without tar wrapper. Always verify format before extracting:

```bash
curl -sL "https://arxiv.org/e-print/{arxiv_id}" -o source.gz
file source.gz  # "gzip compressed data, was 'XXXX.tar', ..."
```

### Metadata API (Companion)

Pair source downloads with the arXiv Atom API for structured metadata:

- **URL**: `GET https://export.arxiv.org/api/query?id_list={arxiv_id}`
- **Response**: Atom XML with `<title>`, `<author>`, `<summary>`, `<category>`, `<published>`
- **Example**: `curl -s "https://export.arxiv.org/api/query?id_list=2301.00001"`

## LaTeX Source Parsing Guide

### Locating the Main .tex File

A source archive typically contains multiple files. To find the main document:

1. Look for `\documentclass` in `.tex` files — this marks the root document
2. Check for a `README.txt` that may specify the main file
3. If multiple `.tex` files contain `\documentclass`, prefer the one with `\begin{document}`

```python
import tarfile, re

def find_main_tex(tar_path):
    with tarfile.open(tar_path, 'r:gz') as tar:
        tex_files = [m for m in tar.getmembers() if m.name.endswith('.tex')]
        for member in tex_files:
            content = tar.extractfile(member).read().decode('utf-8', errors='ignore')
            if r'\documentclass' in content and r'\begin{document}' in content:
                return member.name, content
    return None, None
```

### Extracting Sections

LaTeX sections follow a predictable hierarchy:

```python
import re

def extract_sections(tex_content):
    pattern = r'\\(section|subsection|subsubsection)\{([^}]+)\}'
    sections = re.findall(pattern, tex_content)
    return [(level, title) for level, title in sections]
    # [('section', 'Introduction'), ('section', 'Related Work'), ...]
```

### Extracting Equations

```python
def extract_equations(tex_content):
    patterns = [
        r'\\\[(.+?)\\\]',
        r'\\begin\{equation\}(.+?)\\end\{equation\}',
        r'\\begin\{align\*?\}(.+?)\\end\{align\*?\}',
    ]
    equations = []
    for pat in patterns:
        equations.extend(re.findall(pat, tex_content, re.DOTALL))
    return equations
```

### Extracting Bibliography

Parse `.bib` files (BibTeX entries) or `.bbl` files (compiled `\bibitem` commands):

```python
def extract_bibliography(tar_path):
    refs = []
    with tarfile.open(tar_path, 'r:gz') as tar:
        for member in tar.getmembers():
            if member.name.endswith('.bib'):
                content = tar.extractfile(member).read().decode('utf-8', errors='ignore')
                refs.extend(re.findall(r'@\w+\{([^,]+),(.+?)\n\}', content, re.DOTALL))
            elif member.name.endswith('.bbl'):
                content = tar.extractfile(member).read().decode('utf-8', errors='ignore')
                refs.extend(re.findall(r'\\bibitem.*?\{(.+?)\}', content))
    return refs
```

## Rate Limits

- **Maximum**: 4 requests per second for automated access
- **Recommended**: 1 request/second with delays between sequential downloads
- **Bulk access**: For 1000+ papers, use the arXiv S3 bulk data mirror instead
- **HTTP 429**: Rate limit exceeded; implement exponential backoff
- **User-Agent**: Required — set a descriptive string: `MyTool/1.0 (mailto:user@university.edu)`
- Persistent abuse may result in IP-level blocks

## Academic Use Cases

- **Formula extraction for ML training** — Build equation datasets with ground-truth LaTeX notation, free of OCR noise from PDF parsing
- **Citation network analysis** — Parse `.bib`/`.bbl` files for exact reference keys to construct citation graphs
- **Section-level text analysis** — Extract specific sections (e.g., all "Related Work" across a subfield) for systematic reviews
- **Reproducibility auditing** — Examine algorithm environments, hyperparameter tables, and methodology sections
- **Cross-paper notation alignment** — Compare and normalize equation environments across papers in a subfield

## Complete Python Example

```python
import requests, tarfile, io, re, time, gzip

def download_arxiv_source(arxiv_id, delay=1.0):
    """Download and extract all .tex files from an arXiv paper's source."""
    url = f"https://arxiv.org/e-print/{arxiv_id}"
    headers = {"User-Agent": "ResearchTool/1.0 (mailto:user@example.com)"}
    resp = requests.get(url, headers=headers)
    resp.raise_for_status()
    time.sleep(delay)

    buf = io.BytesIO(resp.content)
    try:
        with tarfile.open(fileobj=buf, mode='r:gz') as tar:
            return {m.name: tar.extractfile(m).read().decode('utf-8', errors='ignore')
                    for m in tar.getmembers() if m.name.endswith('.tex') and m.isfile()}
    except tarfile.ReadError:
        buf.seek(0)
        return {"main.tex": gzip.decompress(buf.read()).decode('utf-8', errors='ignore')}

# Usage
sources = download_arxiv_source("2301.00001")
for fname, content in sources.items():
    if r'\documentclass' in content:
        sections = re.findall(r'\\section\{([^}]+)\}', content)
        equations = re.findall(r'\\begin\{equation\}(.+?)\\end\{equation\}', content, re.DOTALL)
        print(f"{fname}: {len(sections)} sections, {len(equations)} equations")
```

## References

- arXiv e-print access: https://info.arxiv.org/help/bulk_data_s3.html
- arXiv API documentation: https://info.arxiv.org/help/api/index.html
- arXiv terms of use: https://info.arxiv.org/help/api/tou.html
- arXiv S3 bulk data: https://info.arxiv.org/help/bulk_data_s3.html
