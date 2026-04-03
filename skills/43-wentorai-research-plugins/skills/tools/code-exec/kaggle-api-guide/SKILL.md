---
name: kaggle-api-guide
description: "Download datasets, manage competitions and notebooks via Kaggle API"
metadata:
  openclaw:
    emoji: "📈"
    category: "tools"
    subcategory: "code-exec"
    keywords: ["kaggle", "datasets", "competitions", "notebooks", "data-science", "machine-learning"]
    source: "https://www.kaggle.com/docs/api"
---

# Kaggle API Guide

## Overview

Kaggle is the world's largest data science and machine learning community, hosting thousands of datasets, competitions, and computational notebooks. The Kaggle API provides programmatic access to these resources, enabling researchers to download datasets, submit competition entries, manage kernels (notebooks), and explore the Kaggle ecosystem from the command line or scripts.

For academic researchers, Kaggle is a valuable resource for accessing curated, well-documented datasets across diverse domains including healthcare, natural language processing, computer vision, economics, and social sciences. Many published research papers use Kaggle datasets as benchmarks, and the platform's competition infrastructure provides standardized evaluation frameworks for comparing methods.

The Kaggle API is available as a Python CLI tool and library. It requires a free Kaggle account and API token for authentication. The API supports dataset search and download, competition data retrieval, kernel management, and model access.

## Authentication

A free Kaggle API token is required. Generate one from your Kaggle account settings at https://www.kaggle.com/settings.

Download the `kaggle.json` credentials file and place it in the standard location:

```bash
# The kaggle.json file should be at ~/.kaggle/kaggle.json
# It contains your username and key from your Kaggle account settings
mkdir -p ~/.kaggle
# Move your downloaded kaggle.json to ~/.kaggle/kaggle.json
chmod 600 ~/.kaggle/kaggle.json
```

Alternatively, use environment variables:

```bash
export KAGGLE_USERNAME=$KAGGLE_USERNAME
export KAGGLE_KEY=$KAGGLE_KEY
```

Install the CLI tool:

```bash
pip install kaggle
```

## Core Endpoints

### Search Datasets

Find datasets by keyword, file type, or license.

```bash
# Search for datasets
kaggle datasets list -s "climate change" --sort-by votes

# Search with specific criteria
kaggle datasets list -s "medical imaging" --file-type csv --max-size 1000000
```

### Download a Dataset

```bash
# Download and unzip a dataset
kaggle datasets download -d "heptapod/titanic" --unzip -p ./data/titanic/

# Download a specific file from a dataset
kaggle datasets download -d "yelp-dataset/yelp-dataset" -f "yelp_academic_dataset_review.json" -p ./data/
```

### List and Join Competitions

```bash
# List active competitions
kaggle competitions list

# Download competition data (must accept rules on kaggle.com first)
kaggle competitions download -c "house-prices-advanced-regression-techniques" -p ./data/house-prices/
```

### Submit to a Competition

```bash
# Submit predictions
kaggle competitions submit -c "house-prices-advanced-regression-techniques" \
  -f ./submission.csv -m "Random forest baseline v1"

# Check submission status
kaggle competitions submissions -c "house-prices-advanced-regression-techniques"
```

### Manage Notebooks (Kernels)

```bash
# Search for notebooks
kaggle kernels list -s "transformer nlp" --sort-by voteCount

# Pull a notebook to local
kaggle kernels pull "username/notebook-name" -p ./notebooks/

# Push a notebook to Kaggle
kaggle kernels push -p ./my-notebook/
```

### Python Example: Automated Dataset Discovery and Download

```python
import subprocess
import json
import os

def search_kaggle_datasets(query, sort_by="votes", max_results=10):
    """Search Kaggle datasets and return structured results."""
    cmd = [
        "kaggle", "datasets", "list",
        "-s", query,
        "--sort-by", sort_by,
        "--max-size", "50000000",
        "--csv"
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    lines = result.stdout.strip().split("\n")
    if len(lines) < 2:
        return []

    headers = lines[0].split(",")
    datasets = []
    for line in lines[1:max_results + 1]:
        values = line.split(",")
        dataset = dict(zip(headers, values))
        datasets.append(dataset)
    return datasets

def download_dataset(dataset_ref, output_dir="./data"):
    """Download a Kaggle dataset by reference."""
    os.makedirs(output_dir, exist_ok=True)
    cmd = [
        "kaggle", "datasets", "download",
        "-d", dataset_ref,
        "--unzip",
        "-p", output_dir
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode == 0:
        print(f"Downloaded {dataset_ref} to {output_dir}")
    else:
        print(f"Error: {result.stderr}")

# Search for NLP benchmark datasets
datasets = search_kaggle_datasets("nlp text classification benchmark")
for ds in datasets[:5]:
    print(f"  {ds.get('ref', 'N/A')}")
    print(f"    Size: {ds.get('totalBytes', 'N/A')} bytes")
    print(f"    Votes: {ds.get('voteCount', 'N/A')}")
    print()
```

### Python Example: Using the Kaggle Python API Directly

```python
from kaggle.api.kaggle_api_extended import KaggleApi

api = KaggleApi()
api.authenticate()

# Search datasets
datasets = api.dataset_list(search="genomics", sort_by="updated")
for ds in datasets[:5]:
    print(f"{ds.ref}: {ds.title} ({ds.size})")

# Get dataset metadata
metadata = api.dataset_view("nih-chest-xrays/data")
print(f"Title: {metadata.title}")
print(f"Size: {metadata.totalBytes}")
print(f"Description: {metadata.description[:200]}")

# Download dataset files
api.dataset_download_files(
    "nih-chest-xrays/sample",
    path="./data/chest-xrays/",
    unzip=True
)
```

## Common Research Patterns

**Benchmark Dataset Access:** Download well-established datasets used in published research for reproducibility studies. Kaggle hosts canonical versions of many benchmark datasets referenced in ML papers.

**Competition as Evaluation Framework:** Use Kaggle competitions as standardized evaluation environments with leaderboards and held-out test sets. Submit predictions from novel methods to compare against state-of-the-art approaches.

**Data Exploration Notebooks:** Search for and pull community notebooks that explore datasets relevant to your research. These often contain valuable preprocessing code, exploratory analysis, and baseline models.

**Collaborative Research Datasets:** Upload processed research datasets to Kaggle for sharing with collaborators and the broader community, enabling others to reproduce and extend your work.

**Cross-Domain Transfer:** Search across Kaggle's diverse dataset collection to find datasets from adjacent domains that could be useful for transfer learning or cross-domain validation studies.

## Rate Limits and Best Practices

- **API rate limits:** Kaggle imposes daily limits on API calls; typical free accounts allow several hundred requests per day
- **Download limits:** Large datasets may take significant time and disk space; check sizes before downloading
- **Competition rules:** Always accept competition rules on the Kaggle website before attempting to download competition data via API
- **Kernel push format:** When pushing notebooks, include a `kernel-metadata.json` file specifying the kernel type, language, and datasets
- **Authentication security:** Never commit `kaggle.json` to version control; use environment variables in CI/CD pipelines
- **Dataset versioning:** Kaggle datasets support versions; specify version numbers for reproducibility in research
- **Large files:** For datasets over 10GB, consider using the Kaggle CLI rather than the Python API for more reliable downloads

## References

- Kaggle API Documentation: https://www.kaggle.com/docs/api
- Kaggle API GitHub Repository: https://github.com/Kaggle/kaggle-api
- Kaggle Datasets: https://www.kaggle.com/datasets
- Kaggle Competitions: https://www.kaggle.com/competitions
- Kaggle Notebooks: https://www.kaggle.com/code
