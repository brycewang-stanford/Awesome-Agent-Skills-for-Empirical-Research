---
name: ensembl-rest-api
description: "Query gene, sequence, and variant data via the Ensembl REST API"
metadata:
  openclaw:
    emoji: "🧬"
    category: "domains"
    subcategory: "biomedical"
    keywords: ["Ensembl", "gene lookup", "sequence retrieval", "genomics", "variant data", "bioinformatics"]
    source: "https://rest.ensembl.org"
---

# Ensembl REST API Guide

## Overview

Ensembl is a genome browser and annotation system maintained by EMBL-EBI and the Wellcome Sanger Institute, providing reference assemblies, gene annotations, variant data, and comparative genomics for over 300 vertebrate genomes. It is the genomic reference underpinning gget, PyEnsembl, and BioMart.

The REST API exposes Ensembl data via stateless HTTP. Researchers can look up genes by symbol or stable ID, retrieve genomic/cDNA/protein sequences, query variant annotations (rsIDs, clinical significance, consequences), access cross-references (HGNC, UniProt, RefSeq, OMIM), and obtain assembly metadata. Responses in JSON or XML.

## Authentication

No authentication required. All endpoints are publicly accessible. Users needing higher throughput can register for an API token.

## Core Endpoints

### lookup/symbol: Gene Lookup by Symbol

Retrieve gene metadata: coordinates, biotype, canonical transcript.

- **URL**: `GET https://rest.ensembl.org/lookup/symbol/{species}/{symbol}`
- **Parameters**:

| Parameter     | Type   | Required | Description                                      |
|---------------|--------|----------|--------------------------------------------------|
| species       | string | Yes      | Species name (e.g., `homo_sapiens`)              |
| symbol        | string | Yes      | Gene symbol (e.g., `BRCA1`, `TP53`)              |
| expand        | int    | No       | Set to 1 to include transcripts and translations |
| content-type  | string | Yes      | `application/json` or `text/xml`                 |

- **Example**:

```bash
curl "https://rest.ensembl.org/lookup/symbol/homo_sapiens/BRCA1?content-type=application/json"
```

- **Response** (actual):

```json
{
  "display_name": "BRCA1",
  "description": "BRCA1 DNA repair associated [Source:HGNC Symbol;Acc:HGNC:1100]",
  "object_type": "Gene", "species": "homo_sapiens",
  "assembly_name": "GRCh38", "biotype": "protein_coding",
  "seq_region_name": "17", "start": 43044292, "end": 43170245, "strand": -1,
  "id": "ENSG00000012048", "canonical_transcript": "ENST00000357654.9"
}
```

### sequence/id: Sequence Retrieval

Retrieve genomic, cDNA, CDS, or protein sequences by Ensembl stable ID.

- **URL**: `GET https://rest.ensembl.org/sequence/id/{id}`
- **Parameters**:

| Parameter      | Type   | Required | Description                                           |
|----------------|--------|----------|-------------------------------------------------------|
| id             | string | Yes      | Ensembl stable ID (e.g., `ENSG00000012048`)           |
| type           | string | No       | `genomic`, `cdna`, `cds`, or `protein`                |
| expand_5prime  | int    | No       | Expand 5' flanking region by N bases                  |
| expand_3prime  | int    | No       | Expand 3' flanking region by N bases                  |
| content-type   | string | Yes      | `application/json` or `text/plain` (FASTA)            |

- **Example**:

```bash
curl "https://rest.ensembl.org/sequence/id/ENSG00000012048?content-type=application/json&type=genomic"
```

- **Response** (actual, seq truncated):

```json
{
  "id": "ENSG00000012048", "query": "ENSG00000012048",
  "desc": "chromosome:GRCh38:17:43044292:43170245:-1",
  "molecule": "DNA",
  "seq": "AAAGCGTGGGAATTACAGATAAATTAAAACTGTGGAACCCCTTTCCTCGGCTGCCGCCAAGGTGTTCGG..."
}
```

### xrefs/symbol: Cross-References

Map a gene symbol to Ensembl stable IDs and external database identifiers.

- **URL**: `GET https://rest.ensembl.org/xrefs/symbol/{species}/{symbol}`
- **Key params**: `species` (required), `symbol` (required), `external_db` (optional filter, e.g., `UniProt`)
- **Example**:

```bash
curl "https://rest.ensembl.org/xrefs/symbol/homo_sapiens/TP53?content-type=application/json"
```

- **Response** (actual): `[{"type":"gene","id":"ENSG00000141510"},{"type":"gene","id":"LRG_321"}]`

Use `xrefs/id/{id}` to expand an Ensembl ID to all external cross-references (UniProt, HGNC, RefSeq, OMIM).

### variation: Variant Annotation

Retrieve variant data by rsID: mappings, alleles, consequence, clinical significance.

- **URL**: `GET https://rest.ensembl.org/variation/{species}/{id}`
- **Key params**: `species` (required), `id` (required, e.g., `rs699`)
- **Example**:

```bash
curl "https://rest.ensembl.org/variation/homo_sapiens/rs699?content-type=application/json"
```

- **Response** (actual, synonyms truncated):

```json
{
  "name": "rs699", "var_class": "SNP",
  "most_severe_consequence": "missense_variant",
  "clinical_significance": ["benign"],
  "evidence": ["Frequency","1000Genomes","Cited","ESP","Phenotype_or_Disease","ExAC","TOPMed","gnomAD"],
  "mappings": [{"location":"1:230710048-230710048","allele_string":"A/G","strand":1,"assembly_name":"GRCh38"}]
}
```

### info/assembly: Assembly Metadata

- **URL**: `GET https://rest.ensembl.org/info/assembly/{species}`
- **Response** (actual): Returns `assembly_name` ("GRCh38.p14"), `assembly_date` ("2013-12"), `assembly_accession` ("GCA_000001405.29"), full `karyotype` array (1-22, X, Y, MT), and 347 `top_level_region` entries.

## Rate Limits

- **Without token**: 15 requests per second per IP.
- **With token**: higher limits available upon registration.
- **Response headers**: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset` on every response.
- **Batch POST endpoints** (`/lookup/id`, `/sequence/id`): accept up to 1000 IDs per request.
- **GRCh37 mirror**: `https://grch37.rest.ensembl.org`

## Academic Use Cases

- **Gene annotation**: Look up coordinates and biotypes for HGNC symbols to annotate RNA-seq results.
- **Variant interpretation**: Retrieve consequence types and clinical significance for GWAS rsIDs.
- **ID mapping**: Map between Ensembl, UniProt, RefSeq, and HGNC identifiers.
- **Primer design**: Fetch genomic sequences with flanking regions for PCR or CRISPR targeting.
- **Comparative genomics**: Query homology endpoints for orthologs across species.

## Code Examples (Python)

### Gene Lookup and Sequence Retrieval

```python
import requests

BASE = "https://rest.ensembl.org"
HEADERS = {"Content-Type": "application/json"}

gene = requests.get(f"{BASE}/lookup/symbol/homo_sapiens/BRCA1", headers=HEADERS).json()
print(f"{gene['display_name']} ({gene['id']}) chr{gene['seq_region_name']}:{gene['start']}-{gene['end']}")

seq = requests.get(f"{BASE}/sequence/id/{gene['id']}?type=cds", headers=HEADERS).json()
print(f"CDS length: {len(seq['seq'])} bp")
```

### Batch ID Lookup (POST)

```python
import requests

ids = ["ENSG00000012048", "ENSG00000141510", "ENSG00000157764"]  # BRCA1, TP53, BRAF
resp = requests.post(
    "https://rest.ensembl.org/lookup/id",
    headers={"Content-Type": "application/json", "Accept": "application/json"},
    json={"ids": ids}
)
for ens_id, info in resp.json().items():
    print(f"{info['display_name']:10s} chr{info['seq_region_name']}:{info['start']}-{info['end']}")
```

### Variant Annotation Pipeline

```python
import requests

for rsid in ["rs699", "rs1042522", "rs334"]:
    v = requests.get(
        f"https://rest.ensembl.org/variation/homo_sapiens/{rsid}",
        headers={"Content-Type": "application/json"}
    ).json()
    loc = v["mappings"][0]["location"] if v.get("mappings") else "N/A"
    print(f"{v['name']:12s} {v['var_class']:5s} {v['most_severe_consequence']:25s} {loc}")
```

## References

- REST API docs: https://rest.ensembl.org/documentation
- Ensembl browser: https://www.ensembl.org
- gget toolkit (built on Ensembl REST): https://pachterlab.github.io/gget/
- GRCh37 archive API: https://grch37.rest.ensembl.org
