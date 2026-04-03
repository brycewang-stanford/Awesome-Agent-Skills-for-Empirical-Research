---
name: huggingface-inference-guide
description: "Run NLP and CV model inference via Hugging Face free-tier API"
metadata:
  openclaw:
    emoji: "🤗"
    category: "domains"
    subcategory: "ai-ml"
    keywords: ["huggingface", "inference", "nlp", "machine-learning", "transformers", "models"]
    source: "https://huggingface.co/docs/api-inference/index"
---

# Hugging Face Inference API Guide

## Overview

The Hugging Face Inference API provides instant access to thousands of pre-trained machine learning models for natural language processing, computer vision, audio processing, and multimodal tasks. Researchers can run inference on state-of-the-art models without managing infrastructure, GPU resources, or complex deployment pipelines.

The API hosts models from the Hugging Face Hub, which contains over 500,000 models contributed by the research community. This includes transformer models for text classification, named entity recognition, summarization, translation, question answering, text generation, and image classification. For academic researchers, the Inference API is invaluable for rapid prototyping, benchmark evaluation, and integrating ML capabilities into research workflows without dedicated compute resources.

The free tier provides access to a broad selection of models with rate limits suitable for development and small-scale research. An API token is required for authentication, available for free at huggingface.co.

## Authentication

A free Hugging Face API token is required. Create an account and generate a token at https://huggingface.co/settings/tokens.

Store your token securely in an environment variable:

```bash
export HF_API_TOKEN=$HF_API_TOKEN
```

```bash
curl -X POST "https://api-inference.huggingface.co/models/bert-base-uncased" \
  -H "Authorization: Bearer $HF_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"inputs": "The goal of life is [MASK]."}'
```

## Core Endpoints

### Text Classification (Sentiment Analysis)

```
POST https://api-inference.huggingface.co/models/{model_id}
```

```bash
curl -s -X POST \
  "https://api-inference.huggingface.co/models/distilbert-base-uncased-finetuned-sst-2-english" \
  -H "Authorization: Bearer $HF_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"inputs": "This research methodology provides robust and reproducible results."}' \
  | python3 -m json.tool
```

### Named Entity Recognition

```bash
curl -s -X POST \
  "https://api-inference.huggingface.co/models/dslim/bert-base-NER" \
  -H "Authorization: Bearer $HF_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"inputs": "Dr. Marie Curie conducted research at the University of Paris on radioactivity."}' \
  | python3 -m json.tool
```

### Text Summarization

```bash
curl -s -X POST \
  "https://api-inference.huggingface.co/models/facebook/bart-large-cnn" \
  -H "Authorization: Bearer $HF_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "inputs": "The study of quantum computing has seen tremendous advances in the past decade. Researchers have demonstrated quantum supremacy with processors containing over 100 qubits. Error correction remains a significant challenge, but recent breakthroughs in topological qubits and surface codes suggest viable paths forward. Applications in drug discovery, materials science, and cryptography are expected to be among the first practical use cases.",
    "parameters": {"max_length": 80, "min_length": 30}
  }' | python3 -m json.tool
```

### Zero-Shot Classification

Classify text into arbitrary categories without fine-tuning.

```bash
curl -s -X POST \
  "https://api-inference.huggingface.co/models/facebook/bart-large-mnli" \
  -H "Authorization: Bearer $HF_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "inputs": "New CRISPR technique enables precise gene editing in human stem cells",
    "parameters": {"candidate_labels": ["biology", "computer science", "physics", "economics"]}
  }' | python3 -m json.tool
```

### Python Example: Batch Sentiment Analysis of Paper Abstracts

```python
import requests
import os
import time

API_URL = "https://api-inference.huggingface.co/models/distilbert-base-uncased-finetuned-sst-2-english"
HEADERS = {"Authorization": f"Bearer {os.environ['HF_API_TOKEN']}"}

def classify_sentiment(texts):
    """Classify sentiment for a batch of texts."""
    response = requests.post(API_URL, headers=HEADERS, json={"inputs": texts})
    if response.status_code == 503:
        # Model is loading, wait and retry
        wait_time = response.json().get("estimated_time", 20)
        print(f"Model loading, waiting {wait_time:.0f}s...")
        time.sleep(wait_time)
        response = requests.post(API_URL, headers=HEADERS, json={"inputs": texts})
    response.raise_for_status()
    return response.json()

abstracts = [
    "Our results demonstrate a significant improvement over baseline methods.",
    "The proposed approach failed to achieve meaningful gains on the benchmark.",
    "We present preliminary findings that warrant further investigation.",
]

results = classify_sentiment(abstracts)
for abstract, result in zip(abstracts, results):
    top = max(result, key=lambda x: x["score"])
    print(f"Sentiment: {top['label']} ({top['score']:.3f})")
    print(f"  Text: {abstract[:80]}...")
    print()
```

### Python Example: Research Paper Topic Classification

```python
import requests
import os

ZSC_URL = "https://api-inference.huggingface.co/models/facebook/bart-large-mnli"
HEADERS = {"Authorization": f"Bearer {os.environ['HF_API_TOKEN']}"}

def classify_paper(abstract, categories):
    """Classify a paper abstract into research categories."""
    payload = {
        "inputs": abstract,
        "parameters": {"candidate_labels": categories}
    }
    resp = requests.post(ZSC_URL, headers=HEADERS, json=payload)
    resp.raise_for_status()
    return resp.json()

categories = [
    "machine learning",
    "computational biology",
    "natural language processing",
    "computer vision",
    "reinforcement learning",
    "quantum computing"
]

abstract = "We propose a novel transformer architecture for protein structure prediction that achieves state-of-the-art results on CASP benchmarks."
result = classify_paper(abstract, categories)

print("Topic classification:")
for label, score in zip(result["labels"], result["scores"]):
    bar = "#" * int(score * 40)
    print(f"  {label:<30} {score:.3f} {bar}")
```

## Common Research Patterns

**Literature Screening:** Use zero-shot classification to automatically categorize and filter large collections of paper abstracts by research topic, methodology, or relevance to a specific research question.

**Sentiment and Stance Detection:** Analyze the tone and conclusions of research papers, review comments, or social media discussions about scientific topics using sentiment analysis models.

**Named Entity Extraction:** Extract researcher names, institutions, chemical compounds, gene names, and other domain-specific entities from unstructured text in papers and reports.

**Automated Summarization:** Generate concise summaries of lengthy research papers or grant proposals to accelerate literature review workflows.

**Multilingual Research:** Use translation and multilingual models to access and analyze research published in languages other than English.

## Rate Limits and Best Practices

- **Free tier:** Rate-limited; approximately 1,000 requests per day depending on model and load
- **Model loading:** Cold models may take 20-60 seconds to load; handle 503 responses with retry logic
- **Batch inputs:** Send multiple texts as an array in a single request to improve throughput
- **Model selection:** Use distilled or smaller variants (e.g., `distilbert` instead of `bert-large`) for faster inference
- **Timeouts:** Set request timeouts to 60+ seconds for large models or first requests after cold start
- **Caching:** Cache inference results for identical inputs to avoid redundant API calls
- **Pro tier:** For production workloads, consider the Inference Endpoints or Pro subscription for dedicated resources

## References

- Hugging Face Inference API Documentation: https://huggingface.co/docs/api-inference/index
- Hugging Face Model Hub: https://huggingface.co/models
- Hugging Face API Token Settings: https://huggingface.co/settings/tokens
- Hugging Face Tasks Overview: https://huggingface.co/tasks
