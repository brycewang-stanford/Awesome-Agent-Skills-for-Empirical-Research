---
name: huggingface-api
description: "Search and discover ML models, datasets, and Spaces on Hugging Face"
metadata:
  openclaw:
    emoji: "🤗"
    category: "domains"
    subcategory: "ai-ml"
    keywords: ["Hugging Face", "ML models", "datasets", "model hub", "transformers", "NLP", "computer vision"]
    source: "https://huggingface.co/docs/hub/api"
---

# Hugging Face Hub API

## Overview

The Hugging Face Hub is the largest open-source ML ecosystem, hosting over 1 million models, 200,000+ datasets, and 400,000+ Spaces (demo apps). The Hub API at `https://huggingface.co/api` provides programmatic access to search, discover, and retrieve metadata for all public resources without authentication.

For academic researchers, the Hub API enables systematic model selection for benchmarking, dataset discovery for experiments, tracking community adoption metrics (downloads, likes), and building reproducible ML pipelines that reference specific model revisions by SHA.

## Authentication

**Read endpoints require no authentication.** All search and metadata queries work without a token.

For write operations (uploading models, creating repos), set a User Access Token:

```bash
export HF_TOKEN="hf_..."
# Pass via header:
curl -H "Authorization: Bearer $HF_TOKEN" https://huggingface.co/api/...
```

Generate tokens at: https://huggingface.co/settings/tokens

## Core Endpoints

### Search Models

```
GET https://huggingface.co/api/models?search={query}&limit={n}&sort={field}&direction={-1|1}
```

**Parameters**: `search` (query string), `limit` (max results), `sort` (field: `downloads`, `likes`, `lastModified`, `trending`), `direction` (-1 descending, 1 ascending), `filter` (pipeline tag like `text-classification`), `author` (org/user filter), `library` (e.g. `transformers`, `pytorch`)

**Example** -- top 2 models for "bert" by downloads:

```bash
curl -s "https://huggingface.co/api/models?search=bert&limit=2&sort=downloads&direction=-1"
```

```json
[
  {
    "id": "google-bert/bert-base-uncased",
    "likes": 2587,
    "downloads": 71053483,
    "pipeline_tag": "fill-mask",
    "library_name": "transformers",
    "tags": ["transformers","pytorch","tf","jax","bert","fill-mask","en",
             "dataset:bookcorpus","dataset:wikipedia","arxiv:1810.04805",
             "license:apache-2.0"]
  },
  {
    "id": "google-bert/bert-base-multilingual-uncased",
    "likes": 153,
    "downloads": 5017183,
    "pipeline_tag": "fill-mask",
    "library_name": "transformers"
  }
]
```

### Get Model Details

```
GET https://huggingface.co/api/models/{owner}/{model_name}
```

Returns full metadata including `config.architectures`, `cardData` (license, datasets, language), `siblings` (file listing), `sha` (exact revision), and `lastModified`.

```bash
curl -s "https://huggingface.co/api/models/google-bert/bert-base-uncased"
```

Key fields in response:

```json
{
  "id": "google-bert/bert-base-uncased",
  "sha": "86b5e0934494bd15c9632b12f734a8a67f723594",
  "lastModified": "2024-02-19T11:06:12.000Z",
  "downloads": 71053483,
  "config": { "architectures": ["BertForMaskedLM"], "model_type": "bert" },
  "cardData": { "language": "en", "license": "apache-2.0",
                "datasets": ["bookcorpus","wikipedia"] }
}
```

### Search Datasets

```
GET https://huggingface.co/api/datasets?search={query}&limit={n}
```

**Parameters**: `search`, `limit`, `sort`, `direction`, `author`, `filter` (task tag like `question-answering`)

```bash
curl -s "https://huggingface.co/api/datasets?search=squad&limit=2"
```

```json
[
  {
    "id": "rajpurkar/squad_v2",
    "likes": 242,
    "downloads": 36017,
    "description": "Stanford Question Answering Dataset (SQuAD)...",
    "tags": ["task_categories:question-answering","language:en",
             "license:cc-by-sa-4.0","size_categories:100K<n<1M",
             "arxiv:1806.03822"]
  }
]
```

### Get Dataset Details

```
GET https://huggingface.co/api/datasets/{owner}/{dataset_name}
```

```bash
curl -s "https://huggingface.co/api/datasets/rajpurkar/squad_v2"
```

Returns `cardData` with structured metadata (task categories, languages, license, size), `description`, `paperswithcode_id` for cross-referencing, and `tags` with arXiv paper IDs.

### Search Spaces

```
GET https://huggingface.co/api/spaces?search={query}&limit={n}
```

```bash
curl -s "https://huggingface.co/api/spaces?search=chatbot&limit=2"
```

```json
[
  {
    "id": "21Hg/chatbot",
    "likes": 5,
    "sdk": "docker",
    "tags": ["docker","streamlit","region:us"]
  },
  {
    "id": "lmarena-ai/chatbot-arena",
    "likes": 234,
    "sdk": "static"
  }
]
```

## Advanced Filters

Combine filters via query params to narrow results:

```bash
# PyTorch text-generation models with 1000+ likes
curl -s "https://huggingface.co/api/models?filter=text-generation&library=pytorch&sort=likes&direction=-1&limit=5"

# Datasets for NER tasks in Chinese
curl -s "https://huggingface.co/api/datasets?filter=token-classification&language=zh&limit=10"

# Gradio Spaces sorted by trending
curl -s "https://huggingface.co/api/spaces?filter=gradio&sort=trending&direction=-1&limit=5"
```

## Rate Limits

- **Unauthenticated**: generous but undocumented; suitable for interactive use and small scripts
- **Authenticated**: higher limits with Bearer token
- **Best practice**: add `limit` parameter to avoid fetching thousands of results; cache responses locally for batch analysis
- No strict per-minute quota is published; if you receive HTTP 429, back off exponentially

## Academic Use Cases

1. **Model selection for benchmarks**: Search by pipeline tag (`text-classification`, `token-classification`, `summarization`) and sort by downloads to find community-validated baselines
2. **Dataset discovery**: Filter by `task_categories`, `language`, and `size_categories` tags to find training data matching your experimental requirements
3. **Reproducibility**: Pin model versions using the `sha` field from model details -- load exact revisions with `revision="86b5e093..."` in transformers
4. **Citation tracking**: Extract `arxiv:` tags from model/dataset metadata to trace foundational papers
5. **Ecosystem analysis**: Aggregate download/like counts across model families to study adoption trends in ML research

## Code Examples

### Python with requests

```python
import requests

# Search for top text-classification models
resp = requests.get("https://huggingface.co/api/models", params={
    "filter": "text-classification",
    "sort": "downloads",
    "direction": -1,
    "limit": 10
})
models = resp.json()
for m in models:
    print(f"{m['id']:50s}  downloads={m.get('downloads',0):>12,}")

# Get specific model metadata
detail = requests.get("https://huggingface.co/api/models/google-bert/bert-base-uncased").json()
print(f"SHA: {detail['sha']}")
print(f"License: {detail['cardData'].get('license')}")
```

### Python with huggingface_hub library

```python
from huggingface_hub import HfApi

api = HfApi()

# Search models (returns ModelInfo objects)
models = api.list_models(search="bert", sort="downloads", direction=-1, limit=5)
for m in models:
    print(f"{m.id}  downloads={m.downloads}")

# Get full model info
info = api.model_info("google-bert/bert-base-uncased")
print(f"Pipeline: {info.pipeline_tag}, SHA: {info.sha}")

# Search datasets
datasets = api.list_datasets(search="squad", sort="downloads", direction=-1, limit=5)
for d in datasets:
    print(f"{d.id}  downloads={d.downloads}")

# List Spaces
spaces = api.list_spaces(search="chatbot", limit=5)
for s in spaces:
    print(f"{s.id}  sdk={s.sdk}")
```

## References

- Hub API documentation: https://huggingface.co/docs/hub/api
- huggingface_hub Python library: https://huggingface.co/docs/huggingface_hub/
- Model Hub: https://huggingface.co/models
- Dataset Hub: https://huggingface.co/datasets
- Spaces: https://huggingface.co/spaces
- OpenAPI spec: https://huggingface.co/docs/hub/api#openapi
