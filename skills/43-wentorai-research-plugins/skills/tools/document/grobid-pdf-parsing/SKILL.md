---
name: grobid-pdf-parsing
description: "Extract structured text, metadata, and references from academic PDFs"
metadata:
  openclaw:
    emoji: "📄"
    category: "tools"
    subcategory: "document"
    keywords: ["PDF parsing", "PDF extraction", "document chunking", "format conversion"]
    source: "https://github.com/kermitt2/grobid"
---

# GROBID PDF Parsing Guide

## Overview

Academic PDFs are the primary format for distributing research, yet extracting structured data from them remains challenging. PDFs encode visual layout, not semantic structure -- headings, paragraphs, equations, tables, and citations are all just positioned text and graphics. GROBID (GeneRation Of BIbliographic Data) is the leading open-source tool for parsing academic PDFs into structured XML/TEI format, extracting metadata, body text, references, and figures with high accuracy.

GROBID is used by major academic platforms including CORE, ResearchGate, and others for large-scale document processing. It combines machine learning models (CRF and deep learning) with heuristic rules to handle the diverse formatting of academic papers across publishers and disciplines.

This guide covers installing and running GROBID, using its REST API for batch processing, extracting specific elements (metadata, references, body sections), and integrating GROBID output into downstream workflows such as knowledge bases, systematic reviews, and literature analysis pipelines.

## Installation

### Docker (Recommended)

```bash
# Pull the latest GROBID image
docker pull grobid/grobid:0.8.1

# Run GROBID server
docker run --rm --init \
  --ulimit core=0 \
  -p 8070:8070 \
  grobid/grobid:0.8.1

# GROBID is now running at http://localhost:8070
# Web console: http://localhost:8070/console
```

### From Source

```bash
git clone https://github.com/kermitt2/grobid.git
cd grobid
./gradlew clean install
./gradlew run
```

## REST API Usage

### Process Full Document

```bash
# Process a single PDF and get TEI XML
curl -v --form input=@paper.pdf \
  http://localhost:8070/api/processFulltextDocument \
  -o paper.tei.xml

# With options
curl -v --form input=@paper.pdf \
  --form consolidateHeader=1 \
  --form consolidateCitations=1 \
  --form includeRawCitations=1 \
  http://localhost:8070/api/processFulltextDocument \
  -o paper.tei.xml
```

### API Endpoints

| Endpoint | Purpose | Input | Output |
|----------|---------|-------|--------|
| `/api/processFulltextDocument` | Full paper parsing | PDF | TEI XML |
| `/api/processHeaderDocument` | Metadata only | PDF | TEI XML (header) |
| `/api/processReferences` | Reference parsing | PDF | TEI XML (refs) |
| `/api/processCitation` | Parse citation string | Text | TEI XML |
| `/api/processDate` | Parse date string | Text | Structured date |

### Python Client

```python
import requests
from pathlib import Path

class GrobidClient:
    def __init__(self, base_url='http://localhost:8070'):
        self.base_url = base_url

    def process_fulltext(self, pdf_path, consolidate_header=True,
                         consolidate_citations=True):
        """Process a PDF and return TEI XML."""
        url = f'{self.base_url}/api/processFulltextDocument'
        files = {'input': open(pdf_path, 'rb')}
        data = {
            'consolidateHeader': '1' if consolidate_header else '0',
            'consolidateCitations': '1' if consolidate_citations else '0',
        }
        response = requests.post(url, files=files, data=data)
        response.raise_for_status()
        return response.text

    def process_header(self, pdf_path):
        """Extract only header metadata from PDF."""
        url = f'{self.base_url}/api/processHeaderDocument'
        files = {'input': open(pdf_path, 'rb')}
        response = requests.post(url, files=files)
        response.raise_for_status()
        return response.text

    def is_alive(self):
        """Check if GROBID server is running."""
        try:
            resp = requests.get(f'{self.base_url}/api/isalive')
            return resp.status_code == 200
        except requests.ConnectionError:
            return False

# Usage
client = GrobidClient()
if client.is_alive():
    tei_xml = client.process_fulltext('paper.pdf')
    with open('paper.tei.xml', 'w') as f:
        f.write(tei_xml)
```

## Parsing TEI XML Output

### Extracting Metadata

```python
from lxml import etree

def parse_tei_metadata(tei_xml):
    """Extract title, authors, abstract from TEI XML."""
    ns = {'tei': 'http://www.tei-c.org/ns/1.0'}
    root = etree.fromstring(tei_xml.encode('utf-8'))

    # Title
    title_el = root.find('.//tei:titleStmt/tei:title', ns)
    title = title_el.text if title_el is not None else ''

    # Authors
    authors = []
    for author in root.findall('.//tei:sourceDesc//tei:author', ns):
        forename = author.findtext('.//tei:forename', '', ns)
        surname = author.findtext('.//tei:surname', '', ns)
        if surname:
            authors.append(f'{forename} {surname}'.strip())

    # Abstract
    abstract_el = root.find('.//tei:profileDesc/tei:abstract', ns)
    abstract = ''.join(abstract_el.itertext()).strip() if abstract_el is not None else ''

    # DOI
    doi_el = root.find('.//tei:idno[@type="DOI"]', ns)
    doi = doi_el.text if doi_el is not None else ''

    return {
        'title': title,
        'authors': authors,
        'abstract': abstract,
        'doi': doi,
    }
```

### Extracting Body Sections

```python
def parse_tei_sections(tei_xml):
    """Extract structured sections from TEI XML body."""
    ns = {'tei': 'http://www.tei-c.org/ns/1.0'}
    root = etree.fromstring(tei_xml.encode('utf-8'))

    sections = []
    for div in root.findall('.//tei:body/tei:div', ns):
        head = div.findtext('tei:head', '', ns).strip()
        paragraphs = []
        for p in div.findall('tei:p', ns):
            text = ''.join(p.itertext()).strip()
            if text:
                paragraphs.append(text)
        sections.append({
            'heading': head,
            'n': div.get('n', ''),
            'paragraphs': paragraphs,
        })

    return sections
```

### Extracting References

```python
def parse_tei_references(tei_xml):
    """Extract structured references from TEI XML."""
    ns = {'tei': 'http://www.tei-c.org/ns/1.0'}
    root = etree.fromstring(tei_xml.encode('utf-8'))

    refs = []
    for bib in root.findall('.//tei:listBibl/tei:biblStruct', ns):
        ref = {'id': bib.get('{http://www.w3.org/XML/1998/namespace}id', '')}

        # Title
        title_el = bib.find('.//tei:title[@level="a"]', ns)
        if title_el is None:
            title_el = bib.find('.//tei:title', ns)
        ref['title'] = title_el.text if title_el is not None else ''

        # Authors
        ref['authors'] = []
        for author in bib.findall('.//tei:author', ns):
            name = f"{author.findtext('.//tei:forename', '', ns)} {author.findtext('.//tei:surname', '', ns)}".strip()
            if name:
                ref['authors'].append(name)

        # Year
        date_el = bib.find('.//tei:date[@type="published"]', ns)
        ref['year'] = date_el.get('when', '') if date_el is not None else ''

        # DOI
        doi_el = bib.find('.//tei:idno[@type="DOI"]', ns)
        ref['doi'] = doi_el.text if doi_el is not None else ''

        refs.append(ref)

    return refs
```

## Batch Processing

### Processing a Directory of PDFs

```python
from pathlib import Path
import json
from concurrent.futures import ThreadPoolExecutor

def batch_process(pdf_dir, output_dir, max_workers=4):
    """Process all PDFs in a directory using GROBID."""
    client = GrobidClient()
    pdf_dir = Path(pdf_dir)
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    pdf_files = list(pdf_dir.glob('*.pdf'))
    print(f"Processing {len(pdf_files)} PDFs...")

    def process_one(pdf_path):
        try:
            tei = client.process_fulltext(str(pdf_path))
            meta = parse_tei_metadata(tei)
            refs = parse_tei_references(tei)

            # Save TEI XML
            tei_path = output_dir / f'{pdf_path.stem}.tei.xml'
            tei_path.write_text(tei)

            # Save structured JSON
            json_path = output_dir / f'{pdf_path.stem}.json'
            json_path.write_text(json.dumps({
                'metadata': meta,
                'references': refs,
                'n_references': len(refs),
            }, indent=2))

            return pdf_path.name, 'success'
        except Exception as e:
            return pdf_path.name, f'error: {str(e)}'

    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        results = list(executor.map(process_one, pdf_files))

    for name, status in results:
        print(f"  {name}: {status}")

batch_process('papers/', 'parsed_output/')
```

## Best Practices

- **Use consolidation flags.** `consolidateHeader=1` and `consolidateCitations=1` cross-reference against Crossref for better metadata.
- **Handle errors gracefully.** Some PDFs are scanned images, corrupted, or have unusual layouts. Always wrap processing in try/except.
- **Limit concurrent requests.** GROBID is CPU-intensive. 4-8 concurrent requests is usually optimal.
- **Validate output.** Spot-check a sample of parsed documents against the original PDFs.
- **Use GROBID for structured extraction, not OCR.** For scanned documents, run OCR first (Tesseract) then GROBID.
- **Keep GROBID updated.** Each release improves parsing accuracy, especially for newer publisher formats.

## References

- [GROBID Documentation](https://grobid.readthedocs.io/) -- Official documentation
- [GROBID GitHub](https://github.com/kermitt2/grobid) -- Source code
- [TEI Guidelines](https://tei-c.org/release/doc/tei-p5-doc/en/html/) -- TEI XML standard
- [grobid-client-python](https://github.com/kermitt2/grobid_client_python) -- Official Python client
- [Science Parse](https://github.com/allenai/science-parse) -- Allen AI alternative parser
