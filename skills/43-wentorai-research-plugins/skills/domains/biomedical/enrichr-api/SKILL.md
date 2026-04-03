---
name: enrichr-api
description: "Perform gene set enrichment analysis using the Enrichr API"
metadata:
  openclaw:
    emoji: "🔬"
    category: "domains"
    subcategory: "biomedical"
    keywords: ["gene set enrichment", "pathway analysis", "GO terms", "KEGG", "Enrichr", "functional analysis"]
    source: "https://maayanlab.cloud/Enrichr"
---

# Enrichr Gene Set Enrichment Analysis API

## Overview

Enrichr is the most widely used gene set enrichment analysis tool, developed by the Ma'ayan Lab at the Icahn School of Medicine at Mount Sinai. It tests whether a user-supplied gene list is statistically over-represented in curated gene set libraries spanning pathways, ontologies, transcription factor targets, disease associations, and cell types. The API provides access to 225 background libraries covering over 500,000 annotated gene sets. Free, no authentication required.

## Two-Step Workflow

Enrichr uses a submit-then-query pattern:

1. **POST gene list** to `/addList` -- returns a `userListId` token
2. **GET enrichment** from `/enrich` using that token and a chosen library

The `userListId` persists on the server, so you can run multiple library queries against the same submission without re-uploading.

## Core Endpoints

### Base URL

```
https://maayanlab.cloud/Enrichr
```

### Step 1: Submit Gene List

```bash
curl -X POST "https://maayanlab.cloud/Enrichr/addList" \
  -F "list=BRCA1
BRCA2
TP53
EGFR
MYC
PTEN
AKT1
KRAS
PIK3CA
RAF1" \
  -F "description=cancer_genes"
```

**Response:**

```json
{
  "shortId": "8619200cc78f1513ff1029a04af90ad7",
  "userListId": 124544426
}
```

Genes are newline-separated. The request must use `multipart/form-data` (the `-F` flag), not `application/x-www-form-urlencoded`.

### Step 2: Retrieve Enrichment Results

```bash
curl "https://maayanlab.cloud/Enrichr/enrich?userListId=124544426&backgroundType=KEGG_2021_Human"
```

**Response (first 3 of 143 results):**

```json
{
  "KEGG_2021_Human": [
    [1, "Breast cancer", 3.37e-22, 198530.0, 9815800.25,
     ["PIK3CA","MYC","PTEN","AKT1","KRAS","BRCA1","BRCA2","RAF1","TP53","EGFR"],
     4.82e-20, 0, 0],
    [2, "Endometrial cancer", 1.35e-19, 1595.2, 69306.12,
     ["PIK3CA","MYC","PTEN","AKT1","KRAS","RAF1","TP53","EGFR"],
     9.68e-18, 0, 0],
    [3, "Central carbon metabolism in cancer", 6.66e-19, 1285.68, 53809.88,
     ["PIK3CA","MYC","PTEN","AKT1","KRAS","RAF1","TP53","EGFR"],
     3.17e-17, 0, 0]
  ]
}
```

Each result array contains: `[rank, term_name, p_value, z_score, combined_score, overlapping_genes, adjusted_p_value, old_p_value, old_adjusted_p_value]`.

### View Submitted Gene List

```bash
curl "https://maayanlab.cloud/Enrichr/view?userListId=124544426"
```

```json
{
  "genes": ["PIK3CA","MYC","AKT1","PTEN","BRCA1","KRAS","BRCA2","EGFR","TP53","RAF1"],
  "description": "cancer_genes"
}
```

### Export Results as TSV

```bash
curl "https://maayanlab.cloud/Enrichr/export?userListId=124544426&backgroundType=KEGG_2021_Human&filename=results" \
  -o enrichr_results.txt
```

### List Available Libraries

```bash
curl "https://maayanlab.cloud/Enrichr/datasetStatistics"
```

Returns metadata for all 225 libraries, each entry containing `libraryName`, `numTerms`, `geneCoverage`, and `genesPerTerm`.

## Available Libraries (225 Total)

### Pathway Databases

| Library | Terms | Genes |
|---------|-------|-------|
| KEGG_2026 | 352 | 8,110 |
| KEGG_2021_Human | 320 | 8,078 |
| WikiPathways_2024_Human | 829 | 8,281 |
| Reactome_Pathways_2024 | 2,105 | 11,671 |
| BioCarta_2016 | 237 | 1,348 |

### Gene Ontology

| Library | Terms | Genes |
|---------|-------|-------|
| GO_Biological_Process_2025 | 5,343 | 14,674 |
| GO_Molecular_Function_2025 | 1,174 | 11,484 |
| GO_Cellular_Component_2025 | 468 | 11,501 |

### Disease and Phenotype

| Library | Terms | Genes |
|---------|-------|-------|
| DisGeNET | 9,828 | 17,464 |
| GWAS_Catalog_2025 | 2,369 | 15,030 |
| ClinVar_2025 | 609 | 3,481 |
| OMIM_Disease | 90 | 1,759 |
| Human_Phenotype_Ontology | 1,779 | 3,096 |

### Transcription Factor and Epigenomics

| Library | Terms | Genes |
|---------|-------|-------|
| ChEA_2022 | 757 | 18,365 |
| ENCODE_TF_ChIP-seq_2015 | 816 | 26,382 |
| JASPAR_PWM_Human_2025 | 675 | 18,518 |

### Cell Type and Tissue

| Library | Terms | Genes |
|---------|-------|-------|
| CellMarker_2024 | 1,692 | 12,642 |
| ARCHS4_Tissues | 108 | 21,809 |
| Human_Gene_Atlas | 84 | 13,373 |

### Cancer and Drug

| Library | Terms | Genes |
|---------|-------|-------|
| MSigDB_Hallmark_2020 | 50 | 4,383 |
| MSigDB_Oncogenic_Signatures | 189 | 11,250 |
| DGIdb_Drug_Targets_2024 | 659 | 2,513 |

## Rate Limits

- No authentication or API key required
- No officially published rate limits, but automated queries should include reasonable delays (1-2 seconds between requests)
- Very large gene lists (>3,000 genes) may time out on some libraries
- The `userListId` persists server-side; avoid re-submitting the same list repeatedly

## Academic Use Cases

- **Differential expression follow-up**: Submit DEGs from RNA-seq to identify enriched pathways and GO terms
- **GWAS hit annotation**: Map GWAS-significant genes to disease phenotypes via DisGeNET or GWAS_Catalog
- **Drug target discovery**: Cross-reference gene signatures against DGIdb_Drug_Targets for druggable candidates
- **Transcription factor analysis**: Identify upstream regulators via ChEA or ENCODE TF libraries

## Python Usage

```python
import requests

ENRICHR_URL = "https://maayanlab.cloud/Enrichr"


def submit_gene_list(genes: list[str], description: str = "") -> int:
    """Submit a gene list to Enrichr, return userListId."""
    payload = {
        "list": (None, "\n".join(genes)),
        "description": (None, description),
    }
    resp = requests.post(f"{ENRICHR_URL}/addList", files=payload)
    resp.raise_for_status()
    return resp.json()["userListId"]


def get_enrichment(user_list_id: int, library: str) -> list[dict]:
    """Retrieve enrichment results for a given library."""
    resp = requests.get(
        f"{ENRICHR_URL}/enrich",
        params={"userListId": user_list_id, "backgroundType": library},
    )
    resp.raise_for_status()
    data = resp.json()

    results = []
    for entry in data.get(library, []):
        results.append({
            "rank": entry[0],
            "term": entry[1],
            "p_value": entry[2],
            "z_score": entry[3],
            "combined_score": entry[4],
            "genes": entry[5],
            "adj_p_value": entry[6],
        })
    return results


def get_libraries() -> list[dict]:
    """List all available Enrichr libraries."""
    resp = requests.get(f"{ENRICHR_URL}/datasetStatistics")
    resp.raise_for_status()
    return resp.json()["statistics"]


# Example: enrichment analysis of cancer-related genes
genes = ["BRCA1", "BRCA2", "TP53", "EGFR", "MYC",
         "PTEN", "AKT1", "KRAS", "PIK3CA", "RAF1"]

list_id = submit_gene_list(genes, "cancer_genes")
print(f"Submitted gene list, ID: {list_id}")

# Query KEGG pathways
kegg = get_enrichment(list_id, "KEGG_2021_Human")
print(f"\nTop 5 KEGG pathways ({len(kegg)} total):")
for r in kegg[:5]:
    print(f"  {r['rank']}. {r['term']}")
    print(f"     p={r['p_value']:.2e}, adj_p={r['adj_p_value']:.2e}, "
          f"genes={','.join(r['genes'][:5])}...")

# Query GO Biological Process
go_bp = get_enrichment(list_id, "GO_Biological_Process_2023")
print(f"\nTop 5 GO Biological Processes ({len(go_bp)} total):")
for r in go_bp[:5]:
    print(f"  {r['rank']}. {r['term']}")
    print(f"     p={r['p_value']:.2e}, genes={','.join(r['genes'])}")
```

## References

- [Enrichr Web App](https://maayanlab.cloud/Enrichr)
- [Enrichr API Docs](https://maayanlab.cloud/Enrichr/help#api)
- Chen, E.Y. et al. (2013). "Enrichr: interactive and collaborative HTML5 gene list enrichment analysis tool." *BMC Bioinformatics* 14:128.
- Kuleshov, M.V. et al. (2016). "Enrichr: a comprehensive gene set enrichment analysis web server 2016 update." *Nucleic Acids Res.* 44(W1).
- Xie, Z. et al. (2021). "Gene Set Knowledge Discovery with Enrichr." *Current Protocols* 1(3):e90.
