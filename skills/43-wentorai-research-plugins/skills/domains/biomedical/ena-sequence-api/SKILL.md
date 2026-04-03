---
name: ena-sequence-api
description: "Access nucleotide sequence data from the European Nucleotide Archive"
metadata:
  openclaw:
    emoji: "🔬"
    category: "domains"
    subcategory: "biomedical"
    keywords: ["ENA", "nucleotide sequences", "genomics", "EMBL-EBI", "sequencing data", "NGS"]
    source: "https://www.ebi.ac.uk/ena/"
---

# European Nucleotide Archive (ENA) API

## Overview

The European Nucleotide Archive (ENA) at EMBL-EBI is one of the three global nucleotide sequence databases (with NCBI GenBank and DDBJ). It provides access to raw sequencing reads, assembled sequences, and functional annotations from all organisms. The API supports accession lookup, text search, and bulk data retrieval. Free, no authentication required.

## API Endpoints

### Portal API (Search)

```bash
# Search for studies
curl "https://www.ebi.ac.uk/ena/portal/api/search?query=CRISPR+cas9&result=study&limit=20&format=json"

# Search for samples
curl "https://www.ebi.ac.uk/ena/portal/api/search?query=human+gut+microbiome&result=sample&limit=20&format=json"

# Search for runs (sequencing data)
curl "https://www.ebi.ac.uk/ena/portal/api/search?query=RNA-seq+cancer&result=read_run&limit=20&format=json"
```

### Browser API (Accession Lookup)

```bash
# Get record by accession
curl "https://www.ebi.ac.uk/ena/browser/api/xml/PRJEB12345"

# Get in JSON format
curl "https://www.ebi.ac.uk/ena/browser/api/summary/PRJEB12345"

# Get sequence in FASTA
curl "https://www.ebi.ac.uk/ena/browser/api/fasta/AF123456"

# Get in EMBL flat file format
curl "https://www.ebi.ac.uk/ena/browser/api/embl/AF123456"
```

### Taxonomy Search

```bash
# Search by organism
curl "https://www.ebi.ac.uk/ena/portal/api/search?query=tax_tree(9606)&result=study&limit=20&format=json"

# Get taxonomy details
curl "https://www.ebi.ac.uk/ena/taxonomy/rest/tax-id/9606"
```

### Result Types

| Type | Description | Example accession |
|------|-------------|-------------------|
| `study` | Research project | PRJEB12345 |
| `sample` | Biological sample | SAMEA12345 |
| `experiment` | Library/protocol | ERX12345 |
| `read_run` | Sequencing run | ERR12345 |
| `analysis` | Computed analysis | ERZ12345 |
| `sequence` | Assembled sequence | AF123456 |
| `wgs_set` | Whole genome shotgun | AABR00000000 |

### Query Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `query` | Search text or taxonomy | `query=SARS-CoV-2` |
| `result` | Result type | `result=study` |
| `limit` | Max results (default 100K) | `limit=50` |
| `offset` | Pagination offset | `offset=100` |
| `format` | Response format | `json`, `tsv`, `xml` |
| `fields` | Specific fields | `fields=accession,description` |

## Python Usage

```python
import requests

PORTAL_URL = "https://www.ebi.ac.uk/ena/portal/api"
BROWSER_URL = "https://www.ebi.ac.uk/ena/browser/api"


def search_studies(query: str, limit: int = 20) -> list:
    """Search ENA for research studies."""
    params = {
        "query": query,
        "result": "study",
        "limit": limit,
        "format": "json",
        "fields": "study_accession,study_title,study_description,"
                  "tax_id,scientific_name,center_name",
    }
    resp = requests.get(f"{PORTAL_URL}/search", params=params)
    resp.raise_for_status()
    return resp.json()


def search_runs(query: str, limit: int = 20) -> list:
    """Search for sequencing runs."""
    params = {
        "query": query,
        "result": "read_run",
        "limit": limit,
        "format": "json",
        "fields": "run_accession,experiment_title,instrument_platform,"
                  "library_strategy,read_count,base_count",
    }
    resp = requests.get(f"{PORTAL_URL}/search", params=params)
    resp.raise_for_status()
    return resp.json()


def get_fasta(accession: str) -> str:
    """Retrieve sequence in FASTA format."""
    resp = requests.get(f"{BROWSER_URL}/fasta/{accession}")
    resp.raise_for_status()
    return resp.text


def get_study_runs(study_accession: str) -> list:
    """Get all sequencing runs for a study."""
    params = {
        "query": f'study_accession="{study_accession}"',
        "result": "read_run",
        "format": "json",
        "fields": "run_accession,fastq_ftp,read_count,base_count",
        "limit": 1000,
    }
    resp = requests.get(f"{PORTAL_URL}/search", params=params)
    resp.raise_for_status()
    return resp.json()


# Example: find COVID-19 sequencing studies
studies = search_studies("SARS-CoV-2 whole genome", limit=5)
for s in studies:
    print(f"{s['study_accession']}: {s['study_title']}")
    print(f"  Organism: {s.get('scientific_name')}")

# Example: find RNA-seq runs
runs = search_runs("RNA-seq breast cancer", limit=5)
for r in runs:
    reads = int(r.get("read_count", 0))
    print(f"{r['run_accession']}: {r.get('experiment_title', '')}")
    print(f"  Platform: {r.get('instrument_platform')} | "
          f"Reads: {reads:,}")
```

## Data Access

```bash
# Download FASTQ files (from run metadata)
# The fastq_ftp field provides FTP paths:
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR123/ERR123456/ERR123456_1.fastq.gz

# Bulk download via Aspera (faster)
ascp -QT -l 300m -P33001 \
  era-fasp@fasp.sra.ebi.ac.uk:/vol1/fastq/ERR123/ERR123456/ ./
```

## References

- [ENA](https://www.ebi.ac.uk/ena/)
- [ENA Portal API](https://www.ebi.ac.uk/ena/portal/api/)
- [ENA Browser API](https://www.ebi.ac.uk/ena/browser/api/)
- Harrison, P.W. et al. (2021). "The European Nucleotide Archive in 2020." *NAR* 49(D1).
