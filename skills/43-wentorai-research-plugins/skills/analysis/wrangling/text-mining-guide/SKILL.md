---
name: text-mining-guide
description: "Apply NLP and text mining techniques to research text data"
metadata:
  openclaw:
    emoji: "🔍"
    category: "analysis"
    subcategory: "wrangling"
    keywords: ["text mining", "NLP", "topic modeling", "sentiment analysis", "text preprocessing", "natural language processing"]
    source: "wentor-research-plugins"
---

# Text Mining Guide

A skill for applying natural language processing (NLP) and text mining techniques to research data. Covers text preprocessing, feature extraction, topic modeling, sentiment analysis, and named entity recognition for analyzing surveys, abstracts, social media, and document corpora.

## Text Preprocessing Pipeline

### Standard Cleaning Steps

```python
import re
from collections import Counter


def preprocess_text(text: str, lowercase: bool = True,
                    remove_numbers: bool = False,
                    min_word_length: int = 2) -> list[str]:
    """
    Preprocess text for NLP analysis.

    Args:
        text: Raw input text
        lowercase: Convert to lowercase
        remove_numbers: Remove numeric tokens
        min_word_length: Minimum token length to keep
    """
    if lowercase:
        text = text.lower()

    # Remove URLs
    text = re.sub(r"http\S+|www\.\S+", "", text)

    # Remove HTML tags
    text = re.sub(r"<[^>]+>", "", text)

    # Remove special characters (keep apostrophes for contractions)
    text = re.sub(r"[^a-zA-Z0-9\s']", " ", text)

    # Tokenize
    tokens = text.split()

    if remove_numbers:
        tokens = [t for t in tokens if not t.isdigit()]

    # Remove short tokens
    tokens = [t for t in tokens if len(t) >= min_word_length]

    return tokens


def remove_stopwords(tokens: list[str],
                     custom_stopwords: list[str] = None) -> list[str]:
    """
    Remove stopwords from token list.
    """
    # Minimal English stopwords (extend as needed)
    default_stops = {
        "the", "a", "an", "and", "or", "but", "in", "on", "at",
        "to", "for", "of", "with", "by", "is", "was", "are", "were",
        "be", "been", "being", "have", "has", "had", "do", "does",
        "did", "will", "would", "could", "should", "may", "might",
        "this", "that", "these", "those", "it", "its", "not", "no"
    }

    if custom_stopwords:
        default_stops.update(custom_stopwords)

    return [t for t in tokens if t not in default_stops]
```

### Document-Term Matrix

```python
from sklearn.feature_extraction.text import TfidfVectorizer


def build_tfidf_matrix(documents: list[str],
                       max_features: int = 5000) -> dict:
    """
    Build a TF-IDF document-term matrix.

    Args:
        documents: List of document strings
        max_features: Maximum vocabulary size
    """
    vectorizer = TfidfVectorizer(
        max_features=max_features,
        stop_words="english",
        min_df=2,           # Appear in at least 2 documents
        max_df=0.95,        # Ignore terms in >95% of documents
        ngram_range=(1, 2)  # Unigrams and bigrams
    )

    tfidf_matrix = vectorizer.fit_transform(documents)

    return {
        "matrix_shape": tfidf_matrix.shape,
        "vocabulary_size": len(vectorizer.vocabulary_),
        "top_terms": sorted(
            vectorizer.vocabulary_.items(),
            key=lambda x: x[1]
        )[:20],
        "vectorizer": vectorizer,
        "matrix": tfidf_matrix
    }
```

## Topic Modeling

### Latent Dirichlet Allocation (LDA)

```python
from sklearn.decomposition import LatentDirichletAllocation


def run_topic_model(tfidf_matrix, vectorizer,
                    n_topics: int = 10) -> list[dict]:
    """
    Run LDA topic modeling on a document-term matrix.

    Args:
        tfidf_matrix: Sparse TF-IDF matrix
        vectorizer: Fitted TfidfVectorizer
        n_topics: Number of topics to extract
    """
    lda = LatentDirichletAllocation(
        n_components=n_topics,
        random_state=42,
        max_iter=50,
        learning_method="online"
    )
    lda.fit(tfidf_matrix)

    feature_names = vectorizer.get_feature_names_out()
    topics = []

    for idx, topic_weights in enumerate(lda.components_):
        top_indices = topic_weights.argsort()[-10:][::-1]
        top_words = [feature_names[i] for i in top_indices]
        topics.append({
            "topic_id": idx,
            "top_words": top_words,
            "label": "Assign a human-readable label based on top words"
        })

    return topics
```

### Choosing the Number of Topics

```
Methods for selecting k (number of topics):
  - Coherence score: Higher is better (use gensim's CoherenceModel)
  - Perplexity: Lower is better (but can overfit)
  - Human judgment: Do topics make interpretive sense?
  - Domain knowledge: Expected number of themes in the corpus

Practical advice:
  - Start with k = 5, 10, 15, 20 and compare
  - Examine top words for each k -- look for coherent themes
  - If topics are too broad, increase k
  - If topics overlap heavily, decrease k
```

## Sentiment Analysis

### Lexicon-Based Approach

```python
def simple_sentiment(text: str, positive_words: set,
                     negative_words: set) -> dict:
    """
    Basic lexicon-based sentiment scoring.

    Args:
        text: Input text
        positive_words: Set of positive sentiment words
        negative_words: Set of negative sentiment words
    """
    tokens = text.lower().split()

    pos_count = sum(1 for t in tokens if t in positive_words)
    neg_count = sum(1 for t in tokens if t in negative_words)
    total = len(tokens)

    score = (pos_count - neg_count) / max(total, 1)

    return {
        "positive_count": pos_count,
        "negative_count": neg_count,
        "score": score,
        "label": (
            "positive" if score > 0.05
            else "negative" if score < -0.05
            else "neutral"
        )
    }
```

## Research Applications

### Common Text Mining Tasks in Research

| Task | Method | Application |
|------|--------|-------------|
| Literature mapping | Topic modeling | Identify research themes in a corpus of abstracts |
| Survey analysis | Thematic coding + sentiment | Analyze open-ended survey responses |
| Social media analysis | NER + sentiment | Track public discourse on a topic |
| Content analysis | Classification + keyword extraction | Code qualitative data at scale |
| Bibliometrics | Co-word analysis | Map intellectual structure of a field |

## Validation and Reporting

Always validate text mining results against human judgment. Report preprocessing steps, parameter choices (e.g., number of topics, min_df, max_df), and model evaluation metrics. For topic models, include the top 10-15 words per topic and representative documents. For classification, report precision, recall, and F1 on a held-out test set. Acknowledge that automated text analysis supplements but does not replace close reading.
