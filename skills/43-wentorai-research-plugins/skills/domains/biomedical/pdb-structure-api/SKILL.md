---
name: pdb-structure-api
description: "Search and retrieve 3D protein structures from the RCSB Protein Data Bank"
metadata:
  openclaw:
    emoji: "🔮"
    category: "domains"
    subcategory: "biomedical"
    keywords: ["protein structure", "PDB", "crystallography", "structural biology", "RCSB", "molecular structure"]
    source: "https://data.rcsb.org"
---

# RCSB Protein Data Bank API Guide

## Overview

The RCSB Protein Data Bank (PDB) is the single global archive for experimentally determined 3D structures of biological macromolecules. It hosts over 200,000 structures resolved by X-ray crystallography, cryo-EM, NMR spectroscopy, and other methods. Each entry includes atomic coordinates, experimental metadata, polymer sequences, bound ligands, and literature references.

Two complementary APIs are available. The **Data API** (`data.rcsb.org`) serves structured entry metadata, polymer entities, and chemical components via RESTful GET endpoints. The **Search API** (`search.rcsb.org`) supports full-text, attribute-based, sequence similarity, and structure similarity searches.

## Authentication

No authentication required. Both APIs are freely accessible without API keys, tokens, or registration.

## Core Endpoints

### Data API: Get Entry by PDB ID

Retrieve metadata for a structure including experimental method, resolution, citations, and bound components.

- **URL**: `GET https://data.rcsb.org/rest/v1/core/entry/{pdb_id}`

```bash
curl "https://data.rcsb.org/rest/v1/core/entry/4HHB"
```

- **Response** (key fields):

```json
{
  "rcsb_id": "4HHB",
  "struct": {
    "title": "THE CRYSTAL STRUCTURE OF HUMAN DEOXYHAEMOGLOBIN AT 1.74 ANGSTROMS RESOLUTION"
  },
  "exptl": [{"method": "X-RAY DIFFRACTION"}],
  "rcsb_entry_info": {
    "deposited_atom_count": 4779,
    "molecular_weight": 64.74,
    "polymer_composition": "heteromeric protein",
    "polymer_entity_count_protein": 2,
    "resolution_combined": [1.74],
    "nonpolymer_bound_components": ["HEM"]
  }
}
```

### Data API: Get Polymer Entity

Retrieve protein/nucleic acid entity details including sequence, organism, and gene info.

- **URL**: `GET https://data.rcsb.org/rest/v1/core/polymer_entity/{pdb_id}/{entity_id}`

```bash
curl "https://data.rcsb.org/rest/v1/core/polymer_entity/4HHB/1"
```

- **Response** (key fields):

```json
{
  "entity_poly": {
    "pdbx_seq_one_letter_code_can": "VLSPADKTNVKAAWGKVGAHAGEYGAEALERMFLSFPTTKTYFPHFDLSH...",
    "rcsb_entity_polymer_type": "Protein",
    "rcsb_sample_sequence_length": 141,
    "type": "polypeptide(L)"
  },
  "entity_src_gen": [{
    "gene_src_common_name": "Human",
    "pdbx_gene_src_scientific_name": "Homo sapiens",
    "pdbx_gene_src_ncbi_taxonomy_id": "9606"
  }]
}
```

### Data API: Get Chemical Component

Retrieve ligand or small molecule metadata by component ID.

- **URL**: `GET https://data.rcsb.org/rest/v1/core/chemcomp/{comp_id}`

```bash
curl "https://data.rcsb.org/rest/v1/core/chemcomp/HEM"
```

- **Response** (key fields):

```json
{
  "rcsb_id": "HEM",
  "chem_comp": {
    "formula": "C34 H32 Fe N4 O4",
    "formula_weight": 616.487,
    "name": "PROTOPORPHYRIN IX CONTAINING FE",
    "type": "non-polymer"
  }
}
```

### Search API: Full-Text Search

Search across all PDB entries with free-text queries. Returns ranked results by relevance.

- **URL**: `POST https://search.rcsb.org/rcsbsearch/v2/query`
- **Headers**: `Content-Type: application/json`
- **Key body fields**: `query.type` (`"terminal"`), `query.service` (`"full_text"`, `"text"`, `"sequence"`, `"structure"`), `query.parameters.value`, `return_type` (`"entry"`, `"polymer_entity"`, `"assembly"`), `request_options.paginate.start/rows`

```bash
curl -X POST "https://search.rcsb.org/rcsbsearch/v2/query" \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "type": "terminal",
      "service": "full_text",
      "parameters": {"value": "hemoglobin"}
    },
    "return_type": "entry",
    "request_options": {
      "results_content_type": ["experimental"],
      "paginate": {"start": 0, "rows": 3}
    }
  }'
```

- **Response**:

```json
{
  "query_id": "6f7192a6-d65b-4ff1-9d94-37b9600a8864",
  "result_type": "entry",
  "total_count": 8960,
  "result_set": [
    {"identifier": "3GOU", "score": 1.0},
    {"identifier": "6IHX", "score": 0.9995},
    {"identifier": "2PGH", "score": 0.9985}
  ]
}
```

For attribute-based searches, use `"service": "text"` with `"attribute"` and `"operator"` fields. Combine multiple criteria with `"type": "group"` and `"logical_operator": "and"`.

## Rate Limits

No formal rate limits or rate-limit headers are published. RCSB recommends reasonable request rates. For bulk data, use FTP downloads at `https://files.rcsb.org/pub/pdb/` or `ftp://ftp.wwpdb.org/pub/pdb/` instead of iterative API calls.

## Academic Use Cases

- **Structure-Based Drug Design**: Retrieve target protein structures with bound ligands to analyze binding pockets, then search for similar structures to identify drug scaffolds.
- **Comparative Structural Analysis**: Search all structures of a protein family, compare resolution and methods, select the best template for homology modeling.
- **Protein Engineering**: Retrieve wild-type structures and cross-reference with mutant entries to analyze how mutations affect fold stability and ligand interactions.

## Code Examples

### Search and Retrieve Structures

```python
import requests

# Search for kinase inhibitor structures
search_body = {
    "query": {"type": "terminal", "service": "full_text",
              "parameters": {"value": "tyrosine kinase inhibitor"}},
    "return_type": "entry",
    "request_options": {"results_content_type": ["experimental"],
                        "paginate": {"start": 0, "rows": 5}}
}
results = requests.post("https://search.rcsb.org/rcsbsearch/v2/query",
                        json=search_body).json()
print(f"Total hits: {results['total_count']}")

# Retrieve metadata for each hit
for hit in results["result_set"]:
    pdb_id = hit["identifier"]
    entry = requests.get(
        f"https://data.rcsb.org/rest/v1/core/entry/{pdb_id}").json()
    info = entry["rcsb_entry_info"]
    print(f"{pdb_id}: {entry['struct']['title'][:80]}")
    print(f"  Resolution: {info.get('resolution_combined', ['N/A'])[0]} A, "
          f"Method: {info['experimental_method']}")
```

### Extract Polymer Sequences

```python
import requests

pdb_id = "4HHB"
entry = requests.get(
    f"https://data.rcsb.org/rest/v1/core/entry/{pdb_id}").json()

for eid in range(1, entry["rcsb_entry_info"]["polymer_entity_count"] + 1):
    entity = requests.get(
        f"https://data.rcsb.org/rest/v1/core/polymer_entity/{pdb_id}/{eid}"
    ).json()
    poly = entity["entity_poly"]
    src = entity.get("rcsb_entity_source_organism", [{}])[0]
    print(f"Entity {eid}: {poly['rcsb_entity_polymer_type']} "
          f"({src.get('ncbi_scientific_name', 'N/A')})")
    print(f"  {poly['rcsb_sample_sequence_length']} residues: "
          f"{poly['pdbx_seq_one_letter_code_can'][:50]}...")
```

## References

- Data API docs: https://data.rcsb.org/redoc/index.html
- Search API docs: https://search.rcsb.org/index.html
- RCSB PDB homepage: https://www.rcsb.org/
- Programmatic access guide: https://www.rcsb.org/docs/programmatic-access
- PDB file format: https://www.wwpdb.org/documentation/file-format
- Worldwide PDB: https://www.wwpdb.org/
