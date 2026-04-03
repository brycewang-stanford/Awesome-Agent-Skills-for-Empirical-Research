---
name: pmc-ftp-bulk-download
description: "Bulk download PMC Open Access articles via FTP for large-scale mining"
metadata:
  openclaw:
    emoji: "📦"
    category: "literature"
    subcategory: "fulltext"
    keywords: ["pmc", "bulk download", "ftp", "text mining", "open access", "pubmed central"]
    source: "https://www.ncbi.nlm.nih.gov/pmc/tools/ftp/"
---

# PMC FTP Bulk Download

## Overview

The PMC FTP Service provides bulk download access to millions of full-text articles from PubMed Central's Open Access Subset. Unlike the single-article APIs (E-utilities, BioC), the FTP service is designed for large-scale corpus construction — downloading entire collections for text mining, NLP training, systematic reviews, and bibliometric analysis. Free, no authentication required.

**Note**: PMC is migrating to AWS-based Cloud Service in August 2026. FTP paths may change; check official docs for updates.

## FTP Access Points

### Connection

```bash
# FTP (classic)
ftp ftp.ncbi.nlm.nih.gov
# Navigate to: /pub/pmc

# HTTPS alternative (recommended)
# Base: https://ftp.ncbi.nlm.nih.gov/pub/pmc/
```

### Available Datasets

| Dataset | Path | Content | Format |
|---------|------|---------|--------|
| **OA Commercial** | `/pub/pmc/oa_comm/` | CC BY/CC0 articles (commercial use OK) | .tar.gz packages |
| **OA Non-Commercial** | `/pub/pmc/oa_noncomm/` | CC BY-NC articles | .tar.gz packages |
| **OA Other** | `/pub/pmc/oa_other/` | Other open licenses | .tar.gz packages |
| **Author Manuscripts** | `/pub/pmc/manuscript/` | NIH-funded manuscripts | .tar.gz packages |
| **Historical OCR** | `/pub/pmc/historical_ocr/` | Pre-digital scanned articles | .tar.gz |
| **File lists** | `/pub/pmc/oa_file_list.csv` | Index of all OA articles | CSV |

### File List Index

Download the master index to plan your downloads:

```bash
# Download the OA file list (CSV, ~200MB)
wget https://ftp.ncbi.nlm.nih.gov/pub/pmc/oa_file_list.csv

# CSV columns:
# File, Article Citation, AccessionID, LastUpdated, PMID, License
```

## Download Strategies

### Strategy 1: Download Specific Articles

```python
import requests
import tarfile
import io
import csv

def download_article_package(pmcid: str, base_url: str = "https://ftp.ncbi.nlm.nih.gov/pub/pmc"):
    """Download and extract a specific PMC article package."""
    # First, look up the file path from the file list
    # (In practice, you'd load this once and index by PMCID)
    file_list_url = f"{base_url}/oa_file_list.csv"
    # ... lookup pmcid in file list to get path ...

    # Download the tar.gz package
    resp = requests.get(f"{base_url}/{file_path}", stream=True)
    resp.raise_for_status()

    # Extract
    with tarfile.open(fileobj=io.BytesIO(resp.content), mode="r:gz") as tar:
        tar.extractall(path=f"./articles/{pmcid}")
    print(f"Extracted {pmcid}")
```

### Strategy 2: Bulk Download by License

```bash
#!/bin/bash
# Download all commercial-use articles (CC BY / CC0)
# WARNING: This is ~100GB+ compressed

mkdir -p pmc_corpus/commercial
cd pmc_corpus/commercial

# Download the baseline (all current articles)
wget -r -np -nH --cut-dirs=3 \
  https://ftp.ncbi.nlm.nih.gov/pub/pmc/oa_comm/xml/

# Incremental updates (run periodically)
wget -r -np -nH --cut-dirs=3 -N \
  https://ftp.ncbi.nlm.nih.gov/pub/pmc/oa_comm/xml/
```

### Strategy 3: Filtered Download via File List

```python
import csv
import requests
from pathlib import Path

def download_filtered_corpus(file_list_path: str, output_dir: str,
                              license_filter: str = "CC BY",
                              max_articles: int = 1000):
    """Download articles matching a license filter."""
    output = Path(output_dir)
    output.mkdir(parents=True, exist_ok=True)
    base = "https://ftp.ncbi.nlm.nih.gov/pub/pmc"
    downloaded = 0

    with open(file_list_path) as f:
        reader = csv.DictReader(f)
        for row in reader:
            if license_filter and license_filter not in row.get("License", ""):
                continue
            if downloaded >= max_articles:
                break

            file_path = row["File"]
            url = f"{base}/{file_path}"
            local_path = output / Path(file_path).name

            if local_path.exists():
                continue

            resp = requests.get(url, stream=True, timeout=60)
            if resp.status_code == 200:
                local_path.write_bytes(resp.content)
                downloaded += 1
                if downloaded % 100 == 0:
                    print(f"Downloaded {downloaded} articles...")

    print(f"Total downloaded: {downloaded}")
```

## PMC ID Cross-Referencing

Convert between different article identifiers:

```bash
# PMID → PMCID → DOI conversion
curl "https://www.ncbi.nlm.nih.gov/pmc/utils/idconv/v1.0/?ids=29346600&format=json"

# Batch conversion (up to 200 IDs)
curl "https://www.ncbi.nlm.nih.gov/pmc/utils/idconv/v1.0/?ids=29346600,30266829,31048553&format=json"
```

## Package Contents

Each article package (.tar.gz) typically contains:

```
PMC1234567/
├── PMC1234567.xml       # Full text in JATS XML
├── PMC1234567.pdf       # PDF (if available)
├── figure1.jpg          # Figures
├── figure2.jpg
├── table1.html          # Tables (sometimes)
└── supplement1.pdf      # Supplementary materials
```

## Best Practices

- **Start with the file list**: Download `oa_file_list.csv` first and filter locally
- **Respect rate limits**: Space requests 0.3s apart for individual downloads
- **Use incremental updates**: After initial download, use `-N` flag to only get new/updated files
- **Check licenses**: OA Commercial (CC BY) allows any use; Non-Commercial restricts commercial applications
- **Storage planning**: Full OA Subset is ~500GB+ uncompressed

## References

- [PMC FTP Documentation](https://www.ncbi.nlm.nih.gov/pmc/tools/ftp/)
- [PMC Open Access Subset](https://www.ncbi.nlm.nih.gov/pmc/tools/openftlist/)
- [PMC ID Converter API](https://www.ncbi.nlm.nih.gov/pmc/tools/id-converter-api/)
