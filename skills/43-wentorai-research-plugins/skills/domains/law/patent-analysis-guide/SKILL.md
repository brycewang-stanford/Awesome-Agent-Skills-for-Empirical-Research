---
name: patent-analysis-guide
description: "Patent search, classification, landscape analysis, and prior art mining"
metadata:
  openclaw:
    emoji: "📃"
    category: "domains"
    subcategory: "law"
    keywords: ["patent", "intellectual-property", "prior-art", "cpc", "patent-landscape", "citation-analysis"]
    source: "wentor"
---

# Patent Analysis Guide

A skill for conducting patent research, landscape analysis, and prior art searches. Covers patent database APIs, classification systems, citation network analysis, claim parsing, and technology trend mapping for intellectual property research.

## Patent Data Sources

### Major Patent Databases

| Database | Coverage | API | Cost |
|----------|----------|-----|------|
| USPTO PatentsView | US patents and applications | REST API, bulk download | Free |
| EPO Open Patent Services | EP, WO, and 100+ offices | REST API (OPS) | Free (throttled) |
| Google Patents | 120M+ documents worldwide | BigQuery (Google Patents Public) | Free (BigQuery costs) |
| Lens.org | 130M+ patent records | REST API | Free for researchers |
| WIPO PATENTSCOPE | PCT applications + national | REST API | Free |

### Programmatic Patent Search

```python
import requests
import xml.etree.ElementTree as ET

class EPOClient:
    """Client for the EPO Open Patent Services (OPS) API."""

    BASE_URL = "https://ops.epo.org/3.2/rest-services"

    def __init__(self, consumer_key: str, consumer_secret: str):
        self.token = self._authenticate(consumer_key, consumer_secret)

    def _authenticate(self, key: str, secret: str) -> str:
        import base64
        credentials = base64.b64encode(f"{key}:{secret}".encode()).decode()
        resp = requests.post(
            "https://ops.epo.org/3.2/auth/accesstoken",
            headers={"Authorization": f"Basic {credentials}"},
            data={"grant_type": "client_credentials"},
        )
        return resp.json()["access_token"]

    def search(self, cql_query: str, max_results: int = 25) -> list[dict]:
        """
        Search patents using CQL (Common Query Language).
        Example queries:
          ta="machine learning" AND cl="neural network"
          pa="university" AND pd>=2020
        """
        resp = requests.get(
            f"{self.BASE_URL}/published-data/search",
            headers={"Authorization": f"Bearer {self.token}",
                     "Accept": "application/json"},
            params={"q": cql_query, "Range": f"1-{max_results}"},
        )
        return resp.json()
```

## Patent Classification Systems

### Cooperative Patent Classification (CPC)

The CPC hierarchy has five levels: Section > Class > Subclass > Group > Subgroup.

```
Example: H04L 9/3247
  H       = Electricity (Section)
  H04     = Electric communication technique (Class)
  H04L    = Transmission of digital information (Subclass)
  H04L 9/ = Cryptographic mechanisms (Group)
  H04L 9/3247 = Digital signatures (Subgroup)
```

### IPC to CPC Mapping

```python
def parse_cpc_code(code: str) -> dict:
    """Parse a CPC classification code into its hierarchical components."""
    code = code.strip().replace(" ", "")
    return {
        "section": code[0],
        "class": code[:3],
        "subclass": code[:4],
        "group": code.split("/")[0] if "/" in code else code[:4],
        "subgroup": code if "/" in code else None,
        "full": code,
    }

# Technology domain mapping (top-level CPC sections)
CPC_SECTIONS = {
    "A": "Human Necessities",
    "B": "Performing Operations; Transporting",
    "C": "Chemistry; Metallurgy",
    "D": "Textiles; Paper",
    "E": "Fixed Constructions",
    "F": "Mechanical Engineering; Lighting; Heating",
    "G": "Physics",
    "H": "Electricity",
    "Y": "General Tagging of New Technological Developments",
}
```

## Patent Landscape Analysis

### Building a Patent Landscape

A patent landscape maps the technology and competitive environment in a domain:

```python
import pandas as pd
import numpy as np
from collections import Counter

def patent_landscape_metrics(patents: pd.DataFrame) -> dict:
    """
    Compute patent landscape metrics from a patent dataset.
    Expected columns: patent_id, filing_date, grant_date,
    assignee, cpc_codes (list), claims_count, citations_received
    """
    # Filing trend (annual)
    patents["filing_year"] = pd.to_datetime(patents.filing_date).dt.year
    annual_filings = patents.groupby("filing_year").size()

    # Top assignees
    top_assignees = patents.assignee.value_counts().head(20)

    # Technology distribution (CPC subclass level)
    all_cpc = []
    for codes in patents.cpc_codes:
        all_cpc.extend([c[:4] for c in codes])
    cpc_distribution = Counter(all_cpc).most_common(20)

    # Citation impact
    citation_stats = patents.citations_received.describe()

    # Geographic distribution (from assignee country)
    geo_dist = patents.assignee_country.value_counts()

    return {
        "total_patents": len(patents),
        "annual_filings": annual_filings.to_dict(),
        "top_assignees": top_assignees.to_dict(),
        "technology_areas": cpc_distribution,
        "citation_stats": citation_stats.to_dict(),
        "geographic_distribution": geo_dist.head(10).to_dict(),
    }
```

### Citation Network Analysis

```python
import networkx as nx

def build_citation_network(patents: pd.DataFrame,
                            citations: pd.DataFrame) -> nx.DiGraph:
    """
    Build a patent citation network.
    citations: DataFrame with columns [citing_patent, cited_patent]
    """
    G = nx.DiGraph()

    # Add patent nodes with attributes
    for _, row in patents.iterrows():
        G.add_node(row.patent_id, assignee=row.assignee,
                   year=row.filing_year, cpc=row.cpc_codes[0][:4])

    # Add citation edges
    for _, row in citations.iterrows():
        if row.citing_patent in G and row.cited_patent in G:
            G.add_edge(row.citing_patent, row.cited_patent)

    return G

def identify_seminal_patents(G: nx.DiGraph, top_n: int = 20) -> list:
    """Find the most influential patents by various centrality measures."""
    in_degree = dict(G.in_degree())
    pagerank = nx.pagerank(G)

    # Combine metrics
    scores = {}
    for node in G.nodes():
        scores[node] = {
            "citations_received": in_degree[node],
            "pagerank": pagerank[node],
        }
    ranked = sorted(scores.items(), key=lambda x: x[1]["pagerank"], reverse=True)
    return ranked[:top_n]
```

## Claim Analysis

### Parsing Patent Claims

Patent claims define the legal scope of protection. Independent claims are the broadest; dependent claims narrow them:

```python
def parse_claims(claims_text: str) -> list[dict]:
    """
    Parse patent claims text into structured claim objects.
    Identifies independent vs dependent claims and extracts dependencies.
    """
    # Split on claim numbers
    claim_pattern = re.compile(r"\n\s*(\d+)\.\s+", re.MULTILINE)
    parts = claim_pattern.split(claims_text)

    claims = []
    for i in range(1, len(parts), 2):
        claim_num = int(parts[i])
        claim_text = parts[i + 1].strip()

        # Detect dependency
        dep_match = re.match(
            r"(?:The|A)\s+\w+\s+(?:of|according to)\s+claim\s+(\d+)",
            claim_text, re.IGNORECASE
        )
        is_independent = dep_match is None
        depends_on = int(dep_match.group(1)) if dep_match else None

        claims.append({
            "number": claim_num,
            "text": claim_text,
            "independent": is_independent,
            "depends_on": depends_on,
            "word_count": len(claim_text.split()),
        })
    return claims
```

## Prior Art Search Strategy

Systematic prior art search methodology:

1. **Define the invention**: Break the invention into key technical features
2. **Keyword search**: Use synonyms, broader terms, and technical variants
3. **Classification search**: Identify relevant CPC/IPC codes and search within them
4. **Citation search**: Forward and backward citation tracking from known relevant patents
5. **Assignee search**: Search patents from known competitors and research groups
6. **Non-patent literature**: Check academic papers, standards, product documentation

## Tools and Resources

- **PatentsView API**: Free US patent data with assignee disambiguation
- **Google Patents**: Full-text search with CPC browsing and citation links
- **Lens.org**: Scholarly and patent search with linking between patents and papers
- **Derwent Innovation**: Commercial tool for comprehensive patent analytics
- **PatSnap**: AI-powered patent intelligence platform
- **WIPO Pearl**: Multilingual patent terminology database
