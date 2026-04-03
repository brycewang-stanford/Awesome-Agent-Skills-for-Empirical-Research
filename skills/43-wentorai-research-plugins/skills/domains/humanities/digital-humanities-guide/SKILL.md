---
name: digital-humanities-guide
description: "Computational methods for humanities research including text mining and netwo..."
metadata:
  openclaw:
    emoji: "📜"
    category: "domains"
    subcategory: "humanities"
    keywords: ["digital humanities", "philosophy", "literary studies", "art history", "linguistics", "text mining"]
    source: "wentor"
---

# Digital Humanities Guide

A skill for applying computational and quantitative methods to humanities research. Covers text mining, network analysis, spatial humanities, and digital archival methods. Designed for researchers bridging traditional humanities with data-driven approaches.

## Text Mining and Distant Reading

### Corpus Preparation

```python
import re
from collections import Counter

def prepare_corpus(texts: list[str], stopwords: set = None) -> list[list[str]]:
    """
    Tokenize and clean a corpus of texts for analysis.

    Args:
        texts: List of raw text strings
        stopwords: Set of words to remove
    Returns:
        List of tokenized, cleaned documents
    """
    if stopwords is None:
        stopwords = {'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on',
                     'at', 'to', 'for', 'of', 'with', 'is', 'was', 'are'}

    processed = []
    for text in texts:
        # Lowercase and remove punctuation
        tokens = re.findall(r'\b[a-z]+\b', text.lower())
        # Remove stopwords and short tokens
        tokens = [t for t in tokens if t not in stopwords and len(t) > 2]
        processed.append(tokens)
    return processed

def compute_tfidf(corpus: list[list[str]]) -> dict:
    """Compute TF-IDF scores for term importance analysis."""
    import math
    n_docs = len(corpus)
    # Document frequency
    df = Counter()
    for doc in corpus:
        df.update(set(doc))
    # TF-IDF per document
    tfidf_scores = []
    for doc in corpus:
        tf = Counter(doc)
        total = len(doc)
        scores = {}
        for term, count in tf.items():
            tf_val = count / total
            idf_val = math.log(n_docs / (1 + df[term]))
            scores[term] = tf_val * idf_val
        tfidf_scores.append(scores)
    return tfidf_scores
```

### Topic Modeling

Apply Latent Dirichlet Allocation (LDA) to discover thematic structures in large text corpora:

```python
from gensim import corpora, models

def run_topic_model(corpus: list[list[str]], n_topics: int = 10,
                     passes: int = 15) -> models.LdaModel:
    """
    Train an LDA topic model on a preprocessed corpus.
    """
    dictionary = corpora.Dictionary(corpus)
    dictionary.filter_extremes(no_below=5, no_above=0.5)
    bow_corpus = [dictionary.doc2bow(doc) for doc in corpus]

    lda_model = models.LdaModel(
        bow_corpus,
        num_topics=n_topics,
        id2word=dictionary,
        passes=passes,
        random_state=42,
        alpha='auto',
        eta='auto'
    )
    return lda_model

# Print top words per topic
# for idx, topic in lda_model.print_topics(-1):
#     print(f"Topic {idx}: {topic}")
```

## Network Analysis for Historical Research

### Correspondence and Social Networks

```python
import networkx as nx

def build_correspondence_network(letters: list[dict]) -> nx.Graph:
    """
    Build a social network from historical correspondence data.

    Args:
        letters: List of dicts with 'sender', 'recipient', 'date', 'location'
    """
    G = nx.Graph()
    for letter in letters:
        sender = letter['sender']
        recipient = letter['recipient']
        if G.has_edge(sender, recipient):
            G[sender][recipient]['weight'] += 1
        else:
            G.add_edge(sender, recipient, weight=1)

    # Compute centrality measures
    degree_cent = nx.degree_centrality(G)
    betweenness = nx.betweenness_centrality(G)

    for node in G.nodes():
        G.nodes[node]['degree_centrality'] = degree_cent[node]
        G.nodes[node]['betweenness'] = betweenness[node]

    return G

# Identify the most connected and most bridging figures
# sorted(degree_cent.items(), key=lambda x: x[1], reverse=True)[:10]
```

## Spatial Humanities

Map historical events, literary settings, or cultural artifacts using GIS tools:

- **QGIS** for desktop spatial analysis with historical maps
- **Recogito** for annotating place names in texts
- **Peripleo** for linked open geodata visualization
- **Palladio** for Stanford's humanities data visualization platform

Georeferencing historical maps requires at least 4 ground control points with known coordinates, using polynomial or thin-plate spline transformation.

## Digital Archival Methods

### TEI Encoding

The Text Encoding Initiative (TEI) is the standard for scholarly digital editions:

```xml
<TEI xmlns="http://www.tei-c.org/ns/1.0">
  <teiHeader>
    <fileDesc>
      <titleStmt>
        <title>Letters of [Historical Figure]</title>
      </titleStmt>
    </fileDesc>
  </teiHeader>
  <text>
    <body>
      <div type="letter" n="1">
        <opener>
          <dateline><date when="1789-07-14">14 July 1789</date></dateline>
          <salute>Dear Friend,</salute>
        </opener>
        <p>The events of today have been most extraordinary...</p>
      </div>
    </body>
  </text>
</TEI>
```

## Ethical Considerations

Digital humanities research must address: copyright and fair use for digitized materials, privacy concerns for living subjects in social network analysis, algorithmic bias in NLP tools trained on modern English when applied to historical texts, and the responsibility to make digital scholarship accessible beyond the academy.
