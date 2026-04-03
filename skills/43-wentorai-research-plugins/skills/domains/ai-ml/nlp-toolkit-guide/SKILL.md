---
name: nlp-toolkit-guide
description: "NLP analysis with perplexity scoring, burstiness, and entropy metrics"
metadata:
  openclaw:
    emoji: "💬"
    category: "domains"
    subcategory: "ai-ml"
    keywords: ["NLP", "perplexity", "burstiness", "entropy", "tokenization", "text analysis"]
    source: "https://github.com/huggingface/transformers"
---

# NLP Toolkit Guide

## Overview

Natural Language Processing research requires a diverse set of analytical tools beyond standard model training. Text quality assessment, AI-generated text detection, linguistic feature extraction, and corpus analysis all depend on well-understood metrics: perplexity, burstiness, entropy, and their variants.

This guide provides practical implementations of these core NLP metrics alongside patterns for tokenization, embedding analysis, and text feature engineering. The focus is on metrics used in active research areas -- AI text detection (perplexity + burstiness classifiers), information-theoretic analysis of corpora, and linguistic diversity measurement.

These tools are framework-agnostic where possible, but leverage Hugging Face Transformers for language model operations and standard Python scientific computing libraries for statistical analysis.

## Perplexity Scoring

Perplexity measures how well a language model predicts a text. Lower perplexity means the text is more predictable to the model -- a key signal in AI text detection, model evaluation, and domain adaptation.

```python
import torch
import numpy as np
from transformers import AutoModelForCausalLM, AutoTokenizer

def compute_perplexity(text: str, model_name: str = "gpt2") -> dict:
    """
    Compute token-level and text-level perplexity using a causal LM.

    Returns:
        dict with 'perplexity', 'log_likelihood', 'token_perplexities'
    """
    tokenizer = AutoTokenizer.from_pretrained(model_name)
    model = AutoModelForCausalLM.from_pretrained(model_name)
    model.eval()

    encodings = tokenizer(text, return_tensors="pt", truncation=True, max_length=1024)
    input_ids = encodings.input_ids

    with torch.no_grad():
        outputs = model(input_ids, labels=input_ids)
        neg_log_likelihood = outputs.loss.item()

    # Token-level perplexities for analysis
    with torch.no_grad():
        logits = outputs.logits[:, :-1, :]  # Shift for next-token prediction
        targets = input_ids[:, 1:]
        log_probs = torch.log_softmax(logits, dim=-1)
        token_log_probs = log_probs.gather(2, targets.unsqueeze(-1)).squeeze(-1)
        token_perplexities = torch.exp(-token_log_probs).squeeze().tolist()

    perplexity = np.exp(neg_log_likelihood)

    return {
        "perplexity": perplexity,
        "log_likelihood": -neg_log_likelihood,
        "token_perplexities": token_perplexities,
        "num_tokens": input_ids.size(1),
    }
```

## Burstiness Analysis

Burstiness measures the tendency of words to appear in clusters rather than uniformly across a text. Human writing tends to be "burstier" -- once a topic is introduced, related terms cluster together, then disappear.

```python
from collections import Counter
import numpy as np

def compute_burstiness(text: str, min_freq: int = 2) -> dict:
    """
    Compute burstiness score for a text.

    Burstiness B = (sigma - mu) / (sigma + mu)
    where sigma and mu are the std dev and mean of inter-arrival times.
    B ranges from -1 (periodic) to 1 (bursty). Human text typically B > 0.
    """
    words = text.lower().split()
    word_positions = {}
    for i, word in enumerate(words):
        word_positions.setdefault(word, []).append(i)

    burstiness_scores = {}
    for word, positions in word_positions.items():
        if len(positions) < min_freq:
            continue
        inter_arrivals = np.diff(positions)
        mu = np.mean(inter_arrivals)
        sigma = np.std(inter_arrivals)
        if mu + sigma == 0:
            burstiness_scores[word] = 0.0
        else:
            burstiness_scores[word] = (sigma - mu) / (sigma + mu)

    # Aggregate burstiness
    if burstiness_scores:
        avg_burstiness = np.mean(list(burstiness_scores.values()))
    else:
        avg_burstiness = 0.0

    return {
        "average_burstiness": avg_burstiness,
        "word_burstiness": burstiness_scores,
        "num_words_analyzed": len(burstiness_scores),
    }
```

## Entropy and Information-Theoretic Metrics

```python
from collections import Counter
import numpy as np

def compute_entropy(text: str, level: str = "word") -> dict:
    """
    Compute Shannon entropy at word or character level.

    Higher entropy indicates more diverse, less predictable text.
    AI-generated text often has lower entropy than human text.
    """
    if level == "word":
        tokens = text.lower().split()
    elif level == "character":
        tokens = list(text.lower())
    else:
        raise ValueError("level must be 'word' or 'character'")

    counts = Counter(tokens)
    total = sum(counts.values())
    probabilities = np.array([c / total for c in counts.values()])

    entropy = -np.sum(probabilities * np.log2(probabilities + 1e-12))
    max_entropy = np.log2(len(counts)) if len(counts) > 1 else 1.0
    normalized_entropy = entropy / max_entropy

    return {
        "entropy": entropy,
        "normalized_entropy": normalized_entropy,
        "vocabulary_size": len(counts),
        "total_tokens": total,
        "type_token_ratio": len(counts) / total,
    }

def compute_conditional_entropy(text: str, n: int = 2) -> float:
    """Compute conditional entropy H(X_n | X_{n-1}) for n-gram analysis."""
    words = text.lower().split()
    if len(words) < n:
        return 0.0

    ngrams = [tuple(words[i:i+n]) for i in range(len(words) - n + 1)]
    contexts = [ng[:-1] for ng in ngrams]

    context_counts = Counter(contexts)
    ngram_counts = Counter(ngrams)

    h = 0.0
    total = len(ngrams)
    for ngram, count in ngram_counts.items():
        context = ngram[:-1]
        p_ngram = count / total
        p_context = context_counts[context] / total
        h -= p_ngram * np.log2(count / context_counts[context] + 1e-12)

    return h
```

## AI Text Detection Pipeline

Combining perplexity, burstiness, and entropy into a detection pipeline:

```python
def analyze_text_authenticity(text: str) -> dict:
    """
    Multi-signal analysis for AI vs. human text classification.
    Uses perplexity, burstiness, and entropy as features.
    """
    perplexity_result = compute_perplexity(text)
    burstiness_result = compute_burstiness(text)
    entropy_result = compute_entropy(text, level="word")
    char_entropy = compute_entropy(text, level="character")

    # Heuristic thresholds from literature
    signals = {
        "low_perplexity": perplexity_result["perplexity"] < 30,
        "low_burstiness": burstiness_result["average_burstiness"] < 0.1,
        "low_entropy": entropy_result["normalized_entropy"] < 0.7,
        "uniform_token_ppl": np.std(perplexity_result["token_perplexities"]) < 5,
    }

    ai_score = sum(signals.values()) / len(signals)

    return {
        "perplexity": perplexity_result["perplexity"],
        "burstiness": burstiness_result["average_burstiness"],
        "word_entropy": entropy_result["entropy"],
        "char_entropy": char_entropy["entropy"],
        "type_token_ratio": entropy_result["type_token_ratio"],
        "ai_likelihood_score": ai_score,
        "signals": signals,
    }
```

## Tokenization Patterns

```python
from transformers import AutoTokenizer

def compare_tokenizers(text: str, models: list = None) -> dict:
    """Compare tokenization across different models for research analysis."""
    if models is None:
        models = ["gpt2", "bert-base-uncased", "facebook/opt-1.3b"]

    results = {}
    for model_name in models:
        tokenizer = AutoTokenizer.from_pretrained(model_name)
        tokens = tokenizer.tokenize(text)
        results[model_name] = {
            "num_tokens": len(tokens),
            "tokens": tokens[:50],  # First 50 for inspection
            "vocab_size": tokenizer.vocab_size,
            "compression_ratio": len(text) / len(tokens),
        }
    return results
```

## Best Practices

- **Always specify the model** when computing perplexity. Perplexity is model-relative, not absolute.
- **Normalize by text length** when comparing entropy across texts of different sizes.
- **Use sliding windows** for long documents to capture local variation in metrics.
- **Combine multiple signals** for AI text detection -- no single metric is reliable alone.
- **Report confidence intervals** by computing metrics on paragraph-level chunks, then aggregating.
- **Be aware of domain shift.** Perplexity thresholds trained on news text will not transfer to scientific papers.

## References

- [Hugging Face Transformers](https://huggingface.co/docs/transformers/) -- Model hub and tokenizer library
- [DetectGPT](https://arxiv.org/abs/2301.11305) -- Perplexity-based AI text detection (Mitchell et al., 2023)
- [Burstiness and Memory in Text](https://doi.org/10.1103/PhysRevLett.114.078101) -- Altmann et al., 2015
- [NLTK documentation](https://www.nltk.org/) -- Classic NLP toolkit for feature engineering
- [spaCy documentation](https://spacy.io/) -- Industrial-strength NLP for production pipelines
