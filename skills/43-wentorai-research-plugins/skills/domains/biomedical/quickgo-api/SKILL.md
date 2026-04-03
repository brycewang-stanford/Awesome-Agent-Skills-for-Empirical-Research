---
name: quickgo-api
description: "Browse and search Gene Ontology annotations via the QuickGO API"
metadata:
  openclaw:
    emoji: "🧬"
    category: "domains"
    subcategory: "biomedical"
    keywords: ["Gene Ontology", "GO annotations", "protein function", "QuickGO", "EBI", "functional genomics"]
    source: "https://www.ebi.ac.uk/QuickGO/"
---

# QuickGO API

## Overview

QuickGO is the EBI's fast browser and API for Gene Ontology (GO) annotations — the standard framework for describing gene/protein functions across all organisms. It provides access to 800M+ GO annotations covering biological processes, molecular functions, and cellular components. Essential for functional genomics, pathway analysis, and gene set enrichment. Free, no authentication.

## API Endpoints

### Base URL

```
https://www.ebi.ac.uk/QuickGO/services
```

### Search GO Terms

```bash
# Search terms by keyword
curl "https://www.ebi.ac.uk/QuickGO/services/ontology/go/search?query=apoptosis&limit=20"

# Get term details
curl "https://www.ebi.ac.uk/QuickGO/services/ontology/go/terms/GO:0006915"

# Get term ancestors/descendants
curl "https://www.ebi.ac.uk/QuickGO/services/ontology/go/terms/GO:0006915/ancestors"
curl "https://www.ebi.ac.uk/QuickGO/services/ontology/go/terms/GO:0006915/descendants"
```

### Query Annotations

```bash
# Get annotations for a protein (UniProt ID)
curl "https://www.ebi.ac.uk/QuickGO/services/annotation/search?geneProductId=P04637&limit=50"

# Annotations for a GO term
curl "https://www.ebi.ac.uk/QuickGO/services/annotation/search?goId=GO:0006915&taxonId=9606&limit=50"

# Filter by evidence code
curl "https://www.ebi.ac.uk/QuickGO/services/annotation/search?\
goId=GO:0006915&taxonId=9606&evidence=EXP,IDA,IMP&limit=50"

# Filter by aspect (ontology branch)
curl "https://www.ebi.ac.uk/QuickGO/services/annotation/search?\
geneProductId=P04637&aspect=biological_process"
```

### Download Annotations

```bash
# Download as TSV
curl "https://www.ebi.ac.uk/QuickGO/services/annotation/downloadSearch?\
goId=GO:0006915&taxonId=9606&downloadLimit=10000" -o annotations.tsv
```

### GO Aspects

| Aspect | Code | Description |
|--------|------|-------------|
| Biological Process | `biological_process` | What the gene does |
| Molecular Function | `molecular_function` | Biochemical activity |
| Cellular Component | `cellular_component` | Where in the cell |

### Evidence Codes

| Code | Meaning | Reliability |
|------|---------|-------------|
| `EXP` | Inferred from Experiment | High |
| `IDA` | Inferred from Direct Assay | High |
| `IMP` | Inferred from Mutant Phenotype | High |
| `IPI` | Inferred from Physical Interaction | Medium |
| `ISS` | Inferred from Sequence Similarity | Medium |
| `IEA` | Inferred from Electronic Annotation | Lower |

## Python Usage

```python
import requests

BASE_URL = "https://www.ebi.ac.uk/QuickGO/services"


def search_go_terms(query: str, limit: int = 20) -> list:
    """Search Gene Ontology terms."""
    resp = requests.get(
        f"{BASE_URL}/ontology/go/search",
        params={"query": query, "limit": limit},
    )
    resp.raise_for_status()
    data = resp.json()

    results = []
    for term in data.get("results", []):
        results.append({
            "id": term.get("id"),
            "name": term.get("name"),
            "aspect": term.get("aspect"),
            "definition": term.get("definition", {}).get("text", ""),
        })
    return results


def get_protein_annotations(uniprot_id: str,
                            aspect: str = None,
                            experimental_only: bool = False) -> list:
    """Get GO annotations for a protein."""
    params = {"geneProductId": uniprot_id, "limit": 100}
    if aspect:
        params["aspect"] = aspect
    if experimental_only:
        params["evidence"] = "EXP,IDA,IMP,IPI,IGI,IEP"

    resp = requests.get(
        f"{BASE_URL}/annotation/search",
        params=params,
    )
    resp.raise_for_status()
    data = resp.json()

    annotations = []
    for ann in data.get("results", []):
        annotations.append({
            "go_id": ann.get("goId"),
            "go_name": ann.get("goName"),
            "aspect": ann.get("goAspect"),
            "evidence": ann.get("goEvidence"),
            "reference": ann.get("reference"),
        })
    return annotations


def get_term_genes(go_id: str, taxon_id: int = 9606,
                   limit: int = 100) -> list:
    """Get genes annotated with a GO term."""
    params = {
        "goId": go_id,
        "taxonId": taxon_id,
        "limit": limit,
    }
    resp = requests.get(
        f"{BASE_URL}/annotation/search",
        params=params,
    )
    resp.raise_for_status()
    data = resp.json()

    genes = set()
    for ann in data.get("results", []):
        genes.add(ann.get("geneProductId", ""))
    return sorted(genes)


# Example: search for apoptosis-related GO terms
terms = search_go_terms("programmed cell death")
for t in terms[:5]:
    print(f"{t['id']}: {t['name']} ({t['aspect']})")

# Example: get p53 protein annotations
annotations = get_protein_annotations("P04637",
                                      experimental_only=True)
for a in annotations[:10]:
    print(f"  {a['go_id']} {a['go_name']} [{a['evidence']}]")
```

## References

- [QuickGO](https://www.ebi.ac.uk/QuickGO/)
- [QuickGO API Docs](https://www.ebi.ac.uk/QuickGO/api)
- [Gene Ontology](http://geneontology.org/)
- Binns, D. et al. (2009). "QuickGO: a web-based tool for Gene Ontology searching." *Bioinformatics* 25(22).
