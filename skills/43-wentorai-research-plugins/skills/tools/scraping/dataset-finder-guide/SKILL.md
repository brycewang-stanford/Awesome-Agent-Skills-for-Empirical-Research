---
name: dataset-finder-guide
description: "Search and download research datasets from Kaggle, HuggingFace, and repos"
metadata:
  openclaw:
    emoji: "🗄️"
    category: "tools"
    subcategory: "scraping"
    keywords: ["dataset", "Kaggle", "data download", "HuggingFace", "data repository", "open data"]
    source: "wentor-research-plugins"
---

# Dataset Finder Guide

Search, evaluate, and download research datasets from major repositories including Kaggle, Hugging Face, Google Dataset Search, Zenodo, UCI Machine Learning Repository, and domain-specific archives. This skill helps researchers locate the right data for their experiments efficiently.

## Overview

Finding suitable datasets is often one of the most time-consuming phases of empirical research. Datasets are scattered across dozens of platforms, each with different APIs, licensing terms, download mechanisms, and metadata standards. A single research project might require datasets from Kaggle for benchmarking, Hugging Face for NLP tasks, Zenodo for supplementary materials from published papers, and government open data portals for demographic or economic variables.

This skill provides a unified approach to dataset discovery: formulating search queries, evaluating dataset quality and suitability, understanding licensing implications, and efficiently downloading and organizing data. It covers both general-purpose repositories and domain-specific archives that researchers in various fields need.

The emphasis is on reproducibility -- every dataset used in research should be citable, versioned, and documented. This skill includes patterns for recording dataset provenance, creating data cards, and managing dataset versions across experiments.

## Dataset Repositories

### General-Purpose Repositories

| Repository | Strengths | API | Citation Support |
|------------|-----------|-----|-----------------|
| Kaggle | ML benchmarks, competitions, community kernels | REST + CLI | DOI via dataset cards |
| Hugging Face Datasets | NLP, CV, audio; streaming support | Python library | Built-in citation |
| Zenodo | Any research data, DOI minting, EU-funded | REST API | Automatic DOI |
| Google Dataset Search | Meta-search across repositories | Web only | Links to source |
| UCI ML Repository | Classic ML benchmarks | Direct download | BibTeX provided |
| Figshare | Figures, datasets, media, preprints | REST API | DOI per item |
| Dryad | Ecology, biology, environmental science | REST API | DOI per dataset |
| ICPSR | Social science survey data | Restricted API | Persistent IDs |
| Harvard Dataverse | Multi-discipline, institutional | REST API | DOI per dataset |

### Domain-Specific Archives

| Domain | Repository | Notable Datasets |
|--------|-----------|-----------------|
| Genomics | NCBI GEO, ENA | Gene expression, sequencing data |
| Astronomy | NASA archives, SDSS | Sky surveys, spectral data |
| Economics | FRED, World Bank, IMF | Time series, macro indicators |
| Climate | NOAA, CMIP6 | Temperature, precipitation records |
| Linguistics | LDC, CLARIN | Corpora, treebanks |
| Medical | PhysioNet, MIMIC | Clinical records, ECG/EEG |
| Chemistry | PubChem, ChEMBL | Molecular structures, bioassays |

## Searching for Datasets

### Kaggle CLI

```bash
# Install and configure
pip install kaggle
# Place kaggle.json in ~/.kaggle/

# Search datasets
kaggle datasets list -s "sentiment analysis" --sort-by votes
kaggle datasets list -s "medical imaging" --file-type csv --min-size 100MB

# Get dataset details
kaggle datasets metadata -d stanford/imdb-review-dataset

# Download dataset
kaggle datasets download -d stanford/imdb-review-dataset -p ./data/
unzip ./data/imdb-review-dataset.zip -d ./data/imdb/

# Download competition data
kaggle competitions download -c titanic -p ./data/
```

### Hugging Face Datasets

```python
from datasets import load_dataset, list_datasets

# Search for datasets by task
from huggingface_hub import HfApi
api = HfApi()
datasets = api.list_datasets(
    search="scientific papers",
    sort="downloads",
    direction=-1,
    limit=20
)
for ds in datasets:
    print(f"{ds.id}: {ds.downloads} downloads")

# Load a dataset (with streaming for large datasets)
dataset = load_dataset("scientific_papers", "arxiv", streaming=True)

# Inspect structure
print(dataset["train"].features)
print(f"Number of examples: {dataset['train'].num_rows}")

# Load specific split and subset
validation = load_dataset(
    "scientific_papers", "arxiv",
    split="validation[:1000]"
)
```

### Google Dataset Search (Programmatic)

```python
import requests
from bs4 import BeautifulSoup

def search_google_datasets(query, num_results=10):
    """Search Google Dataset Search and extract results."""
    url = f"https://datasetsearch.research.google.com/search"
    params = {"query": query, "docid": ""}
    # Note: Google Dataset Search does not have an official API
    # Use the web interface or alternative approaches
    print(f"Search at: {url}?query={query.replace(' ', '+')}")
    return url
```

### Zenodo API

```python
import requests

def search_zenodo(query, resource_type="dataset", size=10):
    """Search Zenodo for research datasets."""
    url = "https://zenodo.org/api/records"
    params = {
        "q": query,
        "type": resource_type,
        "size": size,
        "sort": "mostrecent",
        "access_right": "open"
    }
    response = requests.get(url, params=params)
    results = response.json()

    for hit in results.get("hits", {}).get("hits", []):
        meta = hit["metadata"]
        print(f"Title: {meta['title']}")
        print(f"DOI: {meta.get('doi', 'N/A')}")
        print(f"License: {meta.get('license', {}).get('id', 'N/A')}")
        print(f"Size: {sum(f['size'] for f in hit.get('files', []))/1e6:.1f} MB")
        print("---")

    return results
```

## Dataset Evaluation Checklist

Before using a dataset in research, verify the following:

### Quality Assessment

- **Completeness**: What percentage of values are missing? Are missing values random or systematic?
- **Accuracy**: Are values within expected ranges? Are there obvious errors?
- **Consistency**: Are formats uniform (dates, categories, units)?
- **Timeliness**: When was the data collected? Is it current enough for your research question?
- **Sample size**: Is the dataset large enough for your intended analysis?

### Licensing and Ethics

| License | Commercial Use | Modification | Attribution Required |
|---------|---------------|-------------|---------------------|
| CC0 | Yes | Yes | No |
| CC-BY 4.0 | Yes | Yes | Yes |
| CC-BY-SA 4.0 | Yes | Yes (share-alike) | Yes |
| CC-BY-NC 4.0 | No | Yes | Yes |
| ODC-ODbL | Yes | Yes (share-alike) | Yes |
| Custom/Restricted | Varies | Varies | Varies |

### Reproducibility Documentation

```markdown
## Data Card

**Dataset**: [Name]
**Source**: [URL]
**Version**: [Version/Date]
**DOI**: [DOI if available]
**License**: [License name]
**Downloaded**: [YYYY-MM-DD]
**Size**: [X rows, Y columns, Z MB]
**Description**: [Brief description]
**Preprocessing**: [Steps applied before use]
**Citation**: [BibTeX entry]
```

## Download and Organization

### Project Data Structure

```
project/
  data/
    raw/              # Original downloaded data (never modify)
      dataset_v1.csv
      README.md       # Data card with provenance
    processed/        # Cleaned and transformed data
      train.csv
      test.csv
    external/         # Third-party reference data
  scripts/
    download_data.py  # Reproducible download script
    preprocess.py     # Data cleaning pipeline
```

### Reproducible Download Script

```python
"""download_data.py - Reproducible dataset download."""
import hashlib
from pathlib import Path
import requests

DATASETS = {
    "main_dataset": {
        "url": "https://zenodo.org/record/12345/files/data.csv",
        "sha256": "abc123...",
        "filename": "raw/main_dataset.csv"
    }
}

DATA_DIR = Path("data")

for name, info in DATASETS.items():
    path = DATA_DIR / info["filename"]
    if path.exists():
        print(f"Already downloaded: {name}")
        continue

    path.parent.mkdir(parents=True, exist_ok=True)
    print(f"Downloading {name}...")
    response = requests.get(info["url"])
    path.write_bytes(response.content)

    # Verify integrity
    sha256 = hashlib.sha256(response.content).hexdigest()
    assert sha256 == info["sha256"], f"Checksum mismatch for {name}"
    print(f"Verified: {name}")
```

## References

- Kaggle API documentation: https://github.com/Kaggle/kaggle-api
- Hugging Face Datasets: https://huggingface.co/docs/datasets
- Zenodo API: https://developers.zenodo.org
- Google Dataset Search: https://datasetsearch.research.google.com
- Gebru et al., "Datasheets for Datasets" (2021): https://arxiv.org/abs/1803.09010
