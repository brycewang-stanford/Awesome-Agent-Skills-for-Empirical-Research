---
name: legal-nlp-guide
description: "NLP techniques for legal text analysis, case law mining, and contracts"
metadata:
  openclaw:
    emoji: "⚖️"
    category: "domains"
    subcategory: "law"
    keywords: ["legal-nlp", "text-mining", "case-law", "contract-analysis", "named-entity", "classification"]
    source: "wentor"
---

# Legal NLP Guide

A skill for applying natural language processing techniques to legal texts. Covers legal document classification, named entity recognition for legal entities, contract clause extraction, case law similarity search, and court opinion summarization using modern NLP tools.

## Legal Text Characteristics

Legal language presents unique NLP challenges:

- **Long documents**: Court opinions average 5,000-20,000 tokens; contracts can exceed 50,000
- **Domain-specific vocabulary**: Terms of art with precise legal meanings (e.g., "consideration", "estoppel")
- **Complex syntax**: Multi-clause sentences with nested qualifications and cross-references
- **Citation networks**: Dense cross-referencing between cases, statutes, and regulations
- **Temporal reasoning**: Effective dates, amendments, and retroactivity

## Legal Text Classification

### Document Type Classification

```python
from transformers import AutoTokenizer, AutoModelForSequenceClassification
import torch

# Legal-BERT: domain-adapted BERT for legal text
model_name = "nlpaueb/legal-bert-base-uncased"
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForSequenceClassification.from_pretrained(
    model_name, num_labels=5
)

# Legal document categories
labels = ["contract", "court_opinion", "statute", "regulation", "brief"]

def classify_legal_document(text: str, max_length: int = 512) -> dict:
    """
    Classify a legal document into predefined categories.
    For long documents, use the first 512 tokens (typically the
    preamble/introduction which contains strong classification signals).
    """
    inputs = tokenizer(
        text, return_tensors="pt",
        max_length=max_length, truncation=True, padding=True
    )
    with torch.no_grad():
        logits = model(**inputs).logits
    probs = torch.softmax(logits, dim=-1).squeeze()
    predicted = labels[probs.argmax().item()]
    return {
        "predicted_class": predicted,
        "confidence": probs.max().item(),
        "all_scores": {l: p.item() for l, p in zip(labels, probs)},
    }
```

### Topic Classification for Case Law

Common topic taxonomies for legal research:

| Category | Examples |
|----------|---------|
| Constitutional Law | Due process, equal protection, First Amendment |
| Criminal Law | Sentencing, evidence, plea bargaining |
| Contract Law | Breach, formation, damages |
| Tort Law | Negligence, product liability, defamation |
| Property Law | Real property, intellectual property, zoning |
| Administrative Law | Agency rulemaking, judicial review |

## Named Entity Recognition

### Legal NER Categories

Legal NER extends standard NER with domain-specific entity types:

```python
import spacy

# Load a legal NER model (e.g., trained on the LegalNERo dataset)
# or fine-tune spaCy on legal annotations
nlp = spacy.load("en_legal_ner")

legal_entity_types = {
    "COURT": "Court or tribunal name",
    "JUDGE": "Judge or justice name",
    "PARTY": "Plaintiff, defendant, petitioner, respondent",
    "STATUTE": "Statute or regulation citation",
    "CASE_CITATION": "Case name and reporter citation",
    "DATE": "Dates of decisions, filings, events",
    "JURISDICTION": "Geographic or subject matter jurisdiction",
    "PROVISION": "Specific section or clause reference",
}

def extract_legal_entities(text: str) -> list[dict]:
    """Extract legal named entities from text."""
    doc = nlp(text)
    entities = []
    for ent in doc.ents:
        entities.append({
            "text": ent.text,
            "label": ent.label_,
            "start": ent.start_char,
            "end": ent.end_char,
            "description": legal_entity_types.get(ent.label_, ""),
        })
    return entities
```

### Citation Extraction and Parsing

```python
import re

# US case citation patterns (simplified)
CASE_CITE_PATTERN = re.compile(
    r"(?P<volume>\d+)\s+"
    r"(?P<reporter>U\.S\.|S\.\s?Ct\.|F\.\s?\d[dthsr]+|"
    r"F\.\s?Supp\.\s?\d*[dthsr]*)\s+"
    r"(?P<page>\d+)"
    r"(?:\s*,\s*(?P<pinpoint>\d+))?"
    r"(?:\s*\((?P<year>\d{4})\))?"
)

def parse_citations(text: str) -> list[dict]:
    """Extract and parse legal citations from text."""
    citations = []
    for match in CASE_CITE_PATTERN.finditer(text):
        citations.append({
            "full_match": match.group(),
            "volume": match.group("volume"),
            "reporter": match.group("reporter"),
            "page": match.group("page"),
            "pinpoint": match.group("pinpoint"),
            "year": match.group("year"),
        })
    return citations
```

## Contract Analysis

### Clause Extraction and Classification

```python
def segment_contract_clauses(text: str) -> list[dict]:
    """
    Segment a contract into numbered clauses and classify them.
    Uses section numbering patterns as primary segmentation cues.
    """
    # Split on section/article numbering patterns
    section_pattern = re.compile(
        r"\n\s*(?:Section|Article|Clause|\d+\.)\s+\d+[\.\d]*\s*[:\.\-]?\s*",
        re.IGNORECASE,
    )
    sections = section_pattern.split(text)
    headers = section_pattern.findall(text)

    clause_types = {
        "indemnification": ["indemnif", "hold harmless", "defend and indemnify"],
        "termination": ["terminat", "cancel", "expir"],
        "confidentiality": ["confidential", "non-disclosure", "proprietary"],
        "limitation_of_liability": ["limit of liabilit", "limitation of liabilit",
                                     "aggregate liability", "consequential damages"],
        "governing_law": ["governing law", "governed by", "jurisdiction"],
        "force_majeure": ["force majeure", "act of god", "beyond reasonable control"],
        "assignment": ["assign", "transfer", "delegate"],
    }

    clauses = []
    for i, section in enumerate(sections[1:], 1):
        detected_type = "general"
        section_lower = section.lower()
        for ctype, keywords in clause_types.items():
            if any(kw in section_lower for kw in keywords):
                detected_type = ctype
                break
        clauses.append({
            "index": i,
            "header": headers[i - 1].strip() if i <= len(headers) else "",
            "type": detected_type,
            "text": section.strip()[:500],
        })
    return clauses
```

## Case Similarity and Legal Search

### Embedding-Based Case Retrieval

```python
from sentence_transformers import SentenceTransformer
import numpy as np

# Legal domain sentence embeddings
encoder = SentenceTransformer("sentence-transformers/all-MiniLM-L6-v2")

def build_case_index(case_summaries: list[str]) -> np.ndarray:
    """Encode case summaries into dense vector representations."""
    embeddings = encoder.encode(case_summaries, show_progress_bar=True)
    # L2 normalize for cosine similarity via dot product
    norms = np.linalg.norm(embeddings, axis=1, keepdims=True)
    return embeddings / norms

def search_similar_cases(query: str, index: np.ndarray,
                         case_ids: list[str], top_k: int = 10) -> list:
    """Find the most similar cases to a query."""
    query_vec = encoder.encode([query])
    query_vec = query_vec / np.linalg.norm(query_vec)
    scores = (index @ query_vec.T).squeeze()
    top_indices = np.argsort(scores)[::-1][:top_k]
    return [(case_ids[i], scores[i]) for i in top_indices]
```

## Legal Datasets and Benchmarks

- **CaseHOLD**: Multiple-choice QA from case law holdings (Harvard)
- **LEDGAR**: 100,000 contract provisions labeled with 12 clause types
- **ECtHR dataset**: European Court of Human Rights case texts with violation labels
- **LegalBench**: Multi-task benchmark for legal reasoning (Stanford)
- **CUAD (Contract Understanding Atticus Dataset)**: 510 contracts with 41 clause type annotations

## Tools and Resources

- **Legal-BERT / CaseLaw-BERT**: Domain-adapted transformer models
- **spaCy + Blackstone**: Legal NER and text processing for UK law
- **Haystack**: Open-source framework for legal document search and QA
- **CourtListener / RECAP**: Free US case law and PACER document archive
- **LexNLP (ContraxSuite)**: Python library for legal text extraction
