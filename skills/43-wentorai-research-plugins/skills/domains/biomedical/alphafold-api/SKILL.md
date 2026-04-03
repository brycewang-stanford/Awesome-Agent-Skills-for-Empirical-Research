---
name: alphafold-api
description: "Query AlphaFold protein structure predictions by UniProt accession"
metadata:
  openclaw:
    emoji: "🧬"
    category: "domains"
    subcategory: "biomedical"
    keywords: ["protein structure", "AlphaFold", "structure prediction", "UniProt", "pLDDT", "bioinformatics"]
    source: "https://alphafold.ebi.ac.uk"
---

# AlphaFold Protein Structure Database API

## Overview

The AlphaFold DB, maintained by EMBL-EBI and DeepMind, provides open access to over 200 million protein structure predictions. The REST API enables programmatic lookup of predicted structures, confidence metrics (pLDDT, PAE), and downloadable structure files (PDB, mmCIF, BinaryCIF) keyed on UniProt accessions. Free, no authentication required.

## Authentication

None. All endpoints are publicly accessible without API keys or tokens.

## Core Endpoints

Base URL: `https://alphafold.ebi.ac.uk/api`

### 1. Get Prediction by UniProt Accession

Retrieves all AlphaFold models for a given UniProt accession or model ID.

```bash
curl "https://alphafold.ebi.ac.uk/api/prediction/P04637"
```

**Response** (first entry, abbreviated):

```json
[
  {
    "entryId": "AF-P04637-F1",
    "uniprotAccession": "P04637",
    "uniprotId": "P53_HUMAN",
    "uniprotDescription": "Cellular tumor antigen p53",
    "gene": "TP53",
    "organismScientificName": "Homo sapiens",
    "taxId": 9606,
    "globalMetricValue": 75.06,
    "fractionPlddtVeryHigh": 0.527,
    "fractionPlddtConfident": 0.071,
    "fractionPlddtLow": 0.104,
    "fractionPlddtVeryLow": 0.298,
    "latestVersion": 6,
    "modelCreatedDate": "2025-08-01T00:00:00Z",
    "sequenceStart": 1,
    "sequenceEnd": 393,
    "pdbUrl": "https://alphafold.ebi.ac.uk/files/AF-P04637-F1-model_v6.pdb",
    "cifUrl": "https://alphafold.ebi.ac.uk/files/AF-P04637-F1-model_v6.cif",
    "bcifUrl": "https://alphafold.ebi.ac.uk/files/AF-P04637-F1-model_v6.bcif",
    "paeImageUrl": "https://alphafold.ebi.ac.uk/files/AF-P04637-F1-predicted_aligned_error_v6.png",
    "paeDocUrl": "https://alphafold.ebi.ac.uk/files/AF-P04637-F1-predicted_aligned_error_v6.json",
    "plddtDocUrl": "https://alphafold.ebi.ac.uk/files/AF-P04637-F1-confidence_v6.json",
    "amAnnotationsUrl": "https://alphafold.ebi.ac.uk/files/AF-P04637-F1-aa-substitutions.csv"
  }
]
```

### 2. Per-Residue Confidence Scores (pLDDT)

Download the per-residue pLDDT confidence JSON linked in `plddtDocUrl`:

```bash
curl "https://alphafold.ebi.ac.uk/files/AF-P04637-F1-confidence_v6.json"
```

**Response** (truncated):

```json
{
  "residueNumber": [1, 2, 3, 4, 5],
  "confidenceScore": [40.66, 44.53, 49.97, 48.59, 44.88],
  "confidenceCategory": ["D", "D", "D", "D", "D"]
}
```

Categories: **A** (Very High, >90), **B** (Confident, 70-90), **C** (Low, 50-70), **D** (Very Low, <50).

### 3. UniProt Summary (3D-Beacons Format)

Returns model metadata following the 3D-Beacons data standard:

```bash
curl "https://alphafold.ebi.ac.uk/api/uniprot/summary/P04637.json"
```

**Response** (abbreviated):

```json
{
  "uniprot_entry": {
    "ac": "P04637",
    "id": "P53_HUMAN",
    "sequence_length": 393
  },
  "structures": [
    {
      "summary": {
        "model_identifier": "AF-P04637-F1",
        "model_url": "https://alphafold.ebi.ac.uk/files/AF-P04637-F1-model_v6.cif",
        "provider": "AlphaFold DB",
        "confidence_type": "pLDDT",
        "confidence_avg_local_score": 75.06,
        "coverage": 1.0
      }
    }
  ]
}
```

### 4. Download Structure Files

Structure files are available at the URLs returned in prediction responses:

```bash
# PDB format
curl -O "https://alphafold.ebi.ac.uk/files/AF-P04637-F1-model_v6.pdb"

# mmCIF format
curl -O "https://alphafold.ebi.ac.uk/files/AF-P04637-F1-model_v6.cif"

# Predicted Aligned Error (PAE) matrix
curl -O "https://alphafold.ebi.ac.uk/files/AF-P04637-F1-predicted_aligned_error_v6.json"
```

## Key Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `entryId` | string | AlphaFold model ID (e.g., `AF-P04637-F1`) |
| `uniprotAccession` | string | UniProt accession code |
| `gene` | string | Gene symbol |
| `globalMetricValue` | float | Average pLDDT score (0-100) |
| `fractionPlddtVeryHigh` | float | Fraction of residues with pLDDT > 90 |
| `fractionPlddtConfident` | float | Fraction with pLDDT 70-90 |
| `fractionPlddtLow` | float | Fraction with pLDDT 50-70 |
| `fractionPlddtVeryLow` | float | Fraction with pLDDT < 50 |
| `pdbUrl` | string | Direct download URL for PDB file |
| `cifUrl` | string | Direct download URL for mmCIF file |
| `paeDocUrl` | string | URL for predicted aligned error JSON |
| `plddtDocUrl` | string | URL for per-residue confidence JSON |
| `latestVersion` | int | Model version number |

## Rate Limits

The AlphaFold DB API has no published per-request rate limits. EMBL-EBI's general fair use policy applies: usage that degrades service for others may result in blocking. For bulk downloads (entire proteomes), use the FTP archive at `https://ftp.ebi.ac.uk/pub/databases/alphafold/` rather than repeated API calls.

## Python Example

```python
import requests


def get_alphafold_prediction(uniprot_id: str) -> dict:
    """Fetch AlphaFold structure prediction for a UniProt accession."""
    url = f"https://alphafold.ebi.ac.uk/api/prediction/{uniprot_id}"
    resp = requests.get(url)
    resp.raise_for_status()
    entries = resp.json()
    # Return the canonical (first) entry
    return entries[0] if entries else None


def get_confidence_scores(prediction: dict) -> dict:
    """Download per-residue pLDDT confidence scores."""
    resp = requests.get(prediction["plddtDocUrl"])
    resp.raise_for_status()
    return resp.json()


def download_structure(prediction: dict, fmt: str = "pdb",
                       output_dir: str = ".") -> str:
    """Download structure file in pdb, cif, or bcif format."""
    url_key = {"pdb": "pdbUrl", "cif": "cifUrl", "bcif": "bcifUrl"}[fmt]
    url = prediction[url_key]
    filename = url.split("/")[-1]
    path = f"{output_dir}/{filename}"

    resp = requests.get(url)
    resp.raise_for_status()
    with open(path, "wb") as f:
        f.write(resp.content)
    return path


# Example: fetch p53 structure and assess quality
pred = get_alphafold_prediction("P04637")
print(f"Gene: {pred['gene']} ({pred['uniprotDescription']})")
print(f"Organism: {pred['organismScientificName']}")
print(f"Average pLDDT: {pred['globalMetricValue']}")
print(f"Very high confidence: {pred['fractionPlddtVeryHigh']:.1%}")

# Download per-residue scores
scores = get_confidence_scores(pred)
high_conf = [i+1 for i, c in enumerate(scores["confidenceCategory"])
             if c in ("A", "B")]
print(f"High-confidence residues: {len(high_conf)}/{len(scores['residueNumber'])}")

# Download PDB file
path = download_structure(pred, fmt="pdb")
print(f"Structure saved to: {path}")
```

## Academic Use Cases

- **Drug target assessment**: Check pLDDT scores in binding pockets before docking
- **Homology model comparison**: Compare AlphaFold predictions with experimental PDB structures
- **Disorder prediction**: Low pLDDT regions (<50) correlate with intrinsically disordered regions
- **Variant interpretation**: Use AlphaMissense annotations (via `amAnnotationsUrl`) to assess pathogenicity
- **Structural coverage**: Quickly check if a protein of interest has a predicted structure
- **Batch proteome analysis**: Retrieve predictions for all proteins in a reference proteome

## References

- [AlphaFold Protein Structure Database](https://alphafold.ebi.ac.uk/)
- [AlphaFold DB API Documentation](https://alphafold.ebi.ac.uk/api/openapi.json)
- [AlphaFold DB FTP (Bulk Downloads)](https://ftp.ebi.ac.uk/pub/databases/alphafold/)
- Jumper, J. et al. (2021). "Highly accurate protein structure prediction with AlphaFold." *Nature* 596, 583-589.
- Varadi, M. et al. (2022). "AlphaFold Protein Structure Database: massively expanding the structural coverage of protein-sequence space with high-accuracy models." *Nucleic Acids Research* 50(D1).
