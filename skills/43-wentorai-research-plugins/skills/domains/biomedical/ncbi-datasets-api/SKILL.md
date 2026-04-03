---
name: ncbi-datasets-api
description: "Access genomes, genes, and taxonomy data via NCBI Datasets v2 API"
metadata:
  openclaw:
    emoji: "🧬"
    category: "domains"
    subcategory: "biomedical"
    keywords: ["NCBI", "genome data", "gene data", "taxonomy", "RefSeq", "GenBank"]
    source: "https://www.ncbi.nlm.nih.gov/datasets/"
---

# NCBI Datasets v2 API

## Overview

NCBI Datasets is the modern API for accessing NCBI's genomic, gene, and taxonomic data — replacing older E-utilities for sequence data retrieval. It provides clean REST endpoints for genome assemblies, gene records, taxonomy trees, and sequence downloads. Covers all organisms in NCBI's databases including RefSeq and GenBank. Free, no authentication required.

## API Endpoints

### Base URL

```
https://api.ncbi.nlm.nih.gov/datasets/v2
```

### Genome Data

```bash
# Search genome assemblies by organism
curl "https://api.ncbi.nlm.nih.gov/datasets/v2/genome/taxon/9606?page_size=5"

# Get assembly by accession
curl "https://api.ncbi.nlm.nih.gov/datasets/v2/genome/accession/GCF_000001405.40"

# Download genome package
curl -o genome.zip \
  "https://api.ncbi.nlm.nih.gov/datasets/v2/genome/accession/GCF_000001405.40/download?\
include_annotation_type=GENOME_FASTA,GENOME_GFF"
```

### Gene Data

```bash
# Search genes by symbol
curl "https://api.ncbi.nlm.nih.gov/datasets/v2/gene/symbol/TP53/taxon/human"

# Get gene by NCBI Gene ID
curl "https://api.ncbi.nlm.nih.gov/datasets/v2/gene/id/7157"

# Search genes by keyword
curl "https://api.ncbi.nlm.nih.gov/datasets/v2/gene/search?query=BRCA&taxon=9606&page_size=20"

# Download gene data package
curl -o gene.zip \
  "https://api.ncbi.nlm.nih.gov/datasets/v2/gene/id/7157/download?include_annotation_type=FASTA_GENE"
```

### Taxonomy

```bash
# Get taxonomy info
curl "https://api.ncbi.nlm.nih.gov/datasets/v2/taxonomy/taxon/9606"

# Search taxonomy by name
curl "https://api.ncbi.nlm.nih.gov/datasets/v2/taxonomy/name_report?taxon_query=Homo+sapiens"

# Get taxonomy tree (subtree)
curl "https://api.ncbi.nlm.nih.gov/datasets/v2/taxonomy/taxon/9443/subtree"
```

### Query Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `page_size` | Results per page | `page_size=20` |
| `page_token` | Pagination token | From previous response |
| `include_annotation_type` | Download content | `GENOME_FASTA`, `GENOME_GFF`, `PROT_FASTA` |
| `filters.assembly_level` | Assembly quality | `complete_genome`, `chromosome` |
| `filters.refseq_only` | RefSeq assemblies | `true` |

## Response Structure (Gene)

```json
{
  "genes": [
    {
      "gene": {
        "gene_id": 7157,
        "symbol": "TP53",
        "description": "tumor protein p53",
        "taxname": "Homo sapiens",
        "tax_id": 9606,
        "type": "PROTEIN_CODING",
        "chromosomes": ["17"],
        "genomic_ranges": [
          {
            "accession_version": "NC_000017.11",
            "range": [{"begin": 7668402, "end": 7687550, "orientation": "minus"}]
          }
        ],
        "nomenclature": {
          "symbol": "TP53",
          "name": "tumor protein p53"
        },
        "annotations": [
          {"release_date": "2024-03-15", "release_name": "GRCh38.p14"}
        ]
      }
    }
  ]
}
```

## Python Usage

```python
import requests
import zipfile
import io

BASE_URL = "https://api.ncbi.nlm.nih.gov/datasets/v2"


def search_genes(query: str, taxon: str = "human",
                 page_size: int = 20) -> list:
    """Search NCBI genes by keyword."""
    resp = requests.get(
        f"{BASE_URL}/gene/search",
        params={"query": query, "taxon": taxon,
                "page_size": page_size},
    )
    resp.raise_for_status()
    data = resp.json()

    results = []
    for item in data.get("genes", []):
        gene = item.get("gene", {})
        results.append({
            "gene_id": gene.get("gene_id"),
            "symbol": gene.get("symbol"),
            "description": gene.get("description"),
            "type": gene.get("type"),
            "chromosomes": gene.get("chromosomes", []),
            "taxname": gene.get("taxname"),
        })
    return results


def get_gene(gene_id: int) -> dict:
    """Get detailed gene information."""
    resp = requests.get(f"{BASE_URL}/gene/id/{gene_id}")
    resp.raise_for_status()
    genes = resp.json().get("genes", [])
    return genes[0].get("gene", {}) if genes else {}


def search_genomes(taxon: str, refseq_only: bool = True,
                   page_size: int = 10) -> list:
    """Search genome assemblies by organism."""
    params = {"page_size": page_size}
    if refseq_only:
        params["filters.refseq_only"] = "true"

    resp = requests.get(
        f"{BASE_URL}/genome/taxon/{taxon}",
        params=params,
    )
    resp.raise_for_status()
    data = resp.json()

    results = []
    for report in data.get("reports", []):
        assembly = report.get("assembly_info", {})
        stats = report.get("assembly_stats", {})
        results.append({
            "accession": report.get("accession"),
            "name": assembly.get("assembly_name"),
            "level": assembly.get("assembly_level"),
            "organism": report.get("organism", {}).get("organism_name"),
            "total_length": stats.get("total_sequence_length"),
            "contig_n50": stats.get("contig_n50"),
        })
    return results


# Example: search cancer-related genes
genes = search_genes("tumor suppressor", taxon="human")
for g in genes[:5]:
    print(f"{g['symbol']} (ID: {g['gene_id']}): {g['description']}")
    print(f"  Type: {g['type']} | Chr: {', '.join(g['chromosomes'])}")

# Example: find reference genomes
genomes = search_genomes("Mus musculus", refseq_only=True)
for g in genomes[:3]:
    print(f"{g['accession']}: {g['name']} ({g['level']})")
    print(f"  Length: {g['total_length']:,} bp")
```

## CLI Tool

NCBI also provides a command-line tool:

```bash
# Install
curl -o datasets "https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/v2/linux-amd64/datasets"
chmod +x datasets

# Download human genome
./datasets download genome taxon "Homo sapiens" --reference --include genome

# Download gene data
./datasets download gene gene-id 7157 --include gene
```

## References

- [NCBI Datasets](https://www.ncbi.nlm.nih.gov/datasets/)
- [Datasets API Reference](https://www.ncbi.nlm.nih.gov/datasets/docs/v2/reference-docs/rest-api/)
- [Datasets CLI](https://www.ncbi.nlm.nih.gov/datasets/docs/v2/download-and-install/)
