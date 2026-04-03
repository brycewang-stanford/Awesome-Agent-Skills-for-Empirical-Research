---
name: open-access-mining-guide
description: "Mine open access full-text repositories for research data extraction"
metadata:
  openclaw:
    emoji: "🔓"
    category: "literature"
    subcategory: "fulltext"
    keywords: ["open access", "text mining", "full text", "PubMed Central", "CORE", "content mining", "TDM"]
    source: "wentor-research-plugins"
---

# Open Access Mining Guide

A skill for systematically mining open access full-text repositories to extract structured research data at scale. Covers legal frameworks for text and data mining (TDM), major open access repositories and their APIs, full-text retrieval and parsing, section-level extraction, entity recognition in scientific text, and building reproducible mining pipelines.

## Legal Framework for Text and Data Mining

### Rights and Regulations

Text and data mining of published literature operates within a specific legal framework that varies by jurisdiction. Understanding these rules is essential before starting any mining project.

```
Legal landscape for TDM:

EU Directive 2019/790 (DSM Directive):
  - Article 3: TDM exception for research organizations
    - Lawful access required (institutional subscription counts)
    - Must be for scientific research purposes
    - No opt-out possible for publishers
    - Applies to EU/EEA research institutions
  - Article 4: General TDM exception
    - Available to anyone with lawful access
    - Publishers CAN opt out (via robots.txt or metadata)

UK: TDM exception for non-commercial research (CDPA s.29A)

US: No specific TDM law; relies on fair use doctrine
  - Transformative use generally favored by courts
  - Google Books case (2015) supports large-scale text analysis
  - But: database protection via Terms of Service

Practical guidelines:
  - Mine open access content (CC-BY, CC-BY-SA) freely
  - Mine subscription content under institutional license
  - Check publisher TDM policies (Elsevier, Springer, Wiley
    all have TDM APIs for licensed content)
  - Never redistribute full text; share derived data only
  - Credit the data source in publications
```

## Major Open Access Repositories

### Repository Comparison

```
Repository overview for full-text mining:

PubMed Central (PMC):
  - Coverage: 8M+ full-text articles (biomedical/life sciences)
  - Access: Free, OA subset freely downloadable
  - Formats: XML (JATS), PDF
  - API: E-utilities (Entrez), bulk FTP download
  - License: varies by article (check individual licenses)
  - Best for: biomedical systematic reviews, meta-analyses
  - Bulk download: ftp.ncbi.nlm.nih.gov/pub/pmc/

Europe PMC:
  - Coverage: PMC content + European-funded research
  - Access: Free, REST API
  - Formats: XML, JSON
  - API: europepmc.org/RestfulWebService
  - Annotations: sentence-level annotations, concepts, data links
  - Best for: European research, annotated text mining

CORE (core.ac.uk):
  - Coverage: 200M+ metadata records, 36M+ full texts
  - Access: Free API (registration required)
  - Formats: JSON, full text as extracted plain text
  - Sources: aggregates from 10,000+ repositories worldwide
  - Best for: cross-disciplinary mining, thesis/dissertation text

arXiv:
  - Coverage: 2M+ preprints (physics, math, CS, etc.)
  - Access: Free bulk download, API
  - Formats: LaTeX source, PDF
  - Bulk: Kaggle dataset, S3 requester-pays bucket
  - Best for: STEM preprint analysis, citation studies

Unpaywall / OpenAlex:
  - Coverage: tracks OA status of 200M+ works
  - Access: Free API, database dump
  - Use: Find OA versions of any DOI
  - Best for: Locating freely available versions of papers

OpenAlex:
  - Coverage: 250M+ works, all disciplines
  - Access: Free API, no key required
  - Features: Concepts, citation counts, author profiles, institution data
  - Best for: Cross-disciplinary metadata and OA discovery
```

## Full-Text Retrieval and Parsing

### Retrieving from PubMed Central

```python
import requests
import xml.etree.ElementTree as ET
import time

def fetch_pmc_fulltext(pmc_id):
    """
    Fetch full-text XML from PubMed Central via E-utilities.

    Args:
        pmc_id: PMC identifier (e.g., "PMC7096724")

    Returns:
        Parsed article as structured dictionary
    """
    base_url = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi"
    params = {
        "db": "pmc",
        "id": pmc_id.replace("PMC", ""),
        "rettype": "xml",
    }

    response = requests.get(base_url, params=params, timeout=30)
    response.raise_for_status()

    root = ET.fromstring(response.content)
    article = parse_jats_xml(root)

    return article


def parse_jats_xml(root):
    """
    Parse JATS XML (Journal Article Tag Suite) into structured data.
    JATS is the standard XML format for PMC articles.
    """
    article = {}

    # Title
    title_elem = root.find(".//article-title")
    article["title"] = "".join(title_elem.itertext()) if title_elem is not None else ""

    # Abstract
    abstract_elem = root.find(".//abstract")
    if abstract_elem is not None:
        article["abstract"] = "".join(abstract_elem.itertext()).strip()

    # Body sections
    body = root.find(".//body")
    if body is not None:
        article["sections"] = extract_sections(body)

    # References
    ref_list = root.find(".//ref-list")
    if ref_list is not None:
        article["references"] = extract_references(ref_list)

    return article


def extract_sections(body_element):
    """
    Extract sections with their titles and text content.
    Preserves the hierarchical structure of the paper.
    """
    sections = []
    for sec in body_element.findall(".//sec"):
        title_elem = sec.find("title")
        title = title_elem.text if title_elem is not None else "Untitled"
        paragraphs = []
        for p in sec.findall("p"):
            text = "".join(p.itertext()).strip()
            if text:
                paragraphs.append(text)

        sections.append({
            "title": title,
            "text": "\n".join(paragraphs),
            "id": sec.get("id", ""),
        })

    return sections
```

### Batch Processing Pipeline

```python
def batch_mine_pmc(pmc_ids, output_dir, delay=0.4):
    """
    Mine multiple PMC articles with rate limiting.

    NCBI E-utilities rate limit:
    - Without API key: 3 requests/second
    - With API key: 10 requests/second
    - Register for API key at ncbi.nlm.nih.gov/account/
    """
    import json
    import os

    results = []
    errors = []

    for i, pmc_id in enumerate(pmc_ids):
        try:
            article = fetch_pmc_fulltext(pmc_id)
            results.append(article)

            # Save individual article
            output_path = os.path.join(output_dir, f"{pmc_id}.json")
            with open(output_path, "w") as f:
                json.dump(article, f, indent=2)

            if (i + 1) % 100 == 0:
                print(f"Processed {i + 1}/{len(pmc_ids)} articles")

        except Exception as e:
            errors.append({"pmc_id": pmc_id, "error": str(e)})

        # Rate limiting
        time.sleep(delay)

    print(f"Successfully mined {len(results)} articles, "
          f"{len(errors)} errors")
    return results, errors
```

## Information Extraction from Full Text

### Section-Level Extraction

```
Targeted extraction by paper section:

Introduction:
  - Research questions and hypotheses
  - Knowledge gaps identified
  - Theoretical framework references

Methods:
  - Study design (RCT, cohort, case-control, etc.)
  - Sample size and population characteristics
  - Measurement instruments and their validity
  - Statistical analysis methods
  - Software and versions used

Results:
  - Effect sizes with confidence intervals
  - P-values and test statistics
  - Participant flow (enrollment, dropout, analysis)
  - Tables and figures (structured data)

Discussion:
  - Key findings summarized
  - Comparison with prior work
  - Limitations acknowledged
  - Future directions proposed
  - Clinical/practical implications
```

### Named Entity Recognition for Science

```python
def extract_scientific_entities(text):
    """
    Extract scientific named entities from full text.

    For biomedical text, use specialized NER models:
    - SciSpaCy: biomedical NER (diseases, chemicals, genes)
    - BioBERT: contextual biomedical NER
    - PubTator: NCBI's annotation service
    """
    import scispacy
    import spacy

    nlp = spacy.load("en_ner_bionlp13cg_md")
    doc = nlp(text)

    entities = []
    for ent in doc.ents:
        entities.append({
            "text": ent.text,
            "label": ent.label_,
            "start": ent.start_char,
            "end": ent.end_char,
        })

    return entities
```

## Building Reproducible Pipelines

### Pipeline Architecture

```
Recommended pipeline structure:

1. Query definition:
   - Define search terms, date ranges, inclusion criteria
   - Document in a protocol file (version-controlled)

2. Article retrieval:
   - Search API for matching articles
   - Download full text (XML/PDF)
   - Store raw data with metadata

3. Text extraction:
   - Parse XML or extract text from PDF
   - Section segmentation
   - Table and figure extraction (if needed)

4. Information extraction:
   - NER for entities of interest
   - Relation extraction
   - Numeric data extraction (effect sizes, p-values)

5. Quality control:
   - Sample-based manual validation (10-20% of results)
   - Inter-annotator agreement on validation sample
   - Error analysis and pipeline refinement

6. Data export:
   - Structured output (CSV, JSON, database)
   - Provenance tracking (which article, which section)
   - Ready for downstream analysis

Best practices:
  - Version control the entire pipeline code
  - Log all API queries and responses
  - Set random seeds for any sampling steps
  - Share the pipeline code in supplementary materials
  - Use DOIs or PMCIDs as stable article identifiers
  - Cache downloaded articles to avoid re-fetching
```

Open access full-text mining enables research at a scale impossible with manual reading. A single researcher can systematically extract data from thousands of papers, enabling comprehensive evidence synthesis, trend analysis, and hypothesis generation. The key requirements are respecting legal and ethical boundaries, building robust parsing pipelines, and rigorously validating extracted data against manual review.
