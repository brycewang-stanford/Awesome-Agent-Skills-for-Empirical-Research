---
name: pubchem-api-guide
description: "Search PubChem for chemical compounds, structures, and bioassay data"
metadata:
  openclaw:
    emoji: "⚗️"
    category: "domains"
    subcategory: "chemistry"
    keywords: ["pubchem", "chemistry", "compounds", "structures", "bioassay", "pharmacology"]
    source: "https://pubchem.ncbi.nlm.nih.gov/docs/pug-rest"
---

# PubChem PUG REST API Guide

## Overview

PubChem is the world's largest free chemistry database, maintained by the National Center for Biotechnology Information (NCBI) at the U.S. National Library of Medicine. It contains information on over 115 million chemical compounds, 300 million substances from hundreds of data sources, and over 1.5 million bioassay experiments. PubChem is a critical resource for researchers in chemistry, pharmacology, drug discovery, toxicology, and related life sciences.

The PUG REST (Power User Gateway RESTful) API provides programmatic access to PubChem's three primary databases: Compound (standardized chemical structures), Substance (depositor-provided records), and BioAssay (biological screening results). The API supports searches by name, molecular formula, structure similarity, substructure, and various identifiers including CID, SID, InChI, and SMILES.

PUG REST is entirely free, requires no authentication, and returns data in JSON, XML, CSV, SDF, and other formats. It is designed for both simple lookups and complex cheminformatics workflows.

## Authentication

No authentication is required. PubChem PUG REST is a free public service.

```bash
# No API key needed
curl "https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/aspirin/JSON"
```

## Core Endpoints

### Get Compound by Name

```
GET https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/{name}/JSON
```

```bash
curl -s "https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/caffeine/JSON" \
  | python3 -m json.tool
```

### Get Compound Properties

Retrieve specific properties for a compound by CID.

```
GET https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/{cid}/property/{properties}/JSON
```

**Available properties:** MolecularFormula, MolecularWeight, CanonicalSMILES, InChI, InChIKey, IUPACName, XLogP, ExactMass, HBondDonorCount, HBondAcceptorCount, RotatableBondCount, TPSA

```bash
curl -s "https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/ibuprofen/property/MolecularFormula,MolecularWeight,CanonicalSMILES,IUPACName,XLogP/JSON" \
  | python3 -m json.tool
```

### Search by Molecular Formula

```bash
curl -s "https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/fastformula/C8H10N4O2/property/IUPACName,MolecularWeight,CanonicalSMILES/JSON" \
  | python3 -m json.tool
```

### Similarity Search

Find compounds structurally similar to a given compound (Tanimoto threshold).

```bash
curl -s "https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/fastsimilarity_2d/cid/2244/property/IUPACName,MolecularWeight,CanonicalSMILES/JSON?Threshold=90" \
  | python3 -m json.tool
```

### Get BioAssay Data

Retrieve biological activity data for a compound.

```bash
curl -s "https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/2244/assaysummary/JSON" \
  | python3 -m json.tool
```

### Python Example: Drug-Likeness Screening

```python
import requests
import time

PUG_REST = "https://pubchem.ncbi.nlm.nih.gov/rest/pug"

def get_compound_properties(name):
    """Fetch key drug-likeness properties for a named compound."""
    props = "MolecularWeight,XLogP,HBondDonorCount,HBondAcceptorCount,TPSA,RotatableBondCount,IUPACName"
    url = f"{PUG_REST}/compound/name/{name}/property/{props}/JSON"
    resp = requests.get(url)
    resp.raise_for_status()
    data = resp.json()
    return data.get("PropertyTable", {}).get("Properties", [{}])[0]

def check_lipinski(props):
    """Check Lipinski's Rule of Five for oral drug-likeness."""
    violations = 0
    mw = props.get("MolecularWeight", 0)
    logp = props.get("XLogP", 0)
    hbd = props.get("HBondDonorCount", 0)
    hba = props.get("HBondAcceptorCount", 0)

    if mw > 500: violations += 1
    if logp > 5: violations += 1
    if hbd > 5: violations += 1
    if hba > 10: violations += 1
    return violations

drug_candidates = ["metformin", "atorvastatin", "lisinopril", "omeprazole"]
print(f"{'Compound':<20} {'MW':>8} {'LogP':>6} {'HBD':>4} {'HBA':>4} {'Violations':>10}")
print("-" * 60)

for drug in drug_candidates:
    props = get_compound_properties(drug)
    violations = check_lipinski(props)
    print(f"{drug:<20} {props.get('MolecularWeight', 0):>8.1f} "
          f"{props.get('XLogP', 0):>6.1f} "
          f"{props.get('HBondDonorCount', 0):>4} "
          f"{props.get('HBondAcceptorCount', 0):>4} "
          f"{violations:>10}")
    time.sleep(0.3)
```

### Python Example: Compound Comparison

```python
import requests

def compare_compounds(cid_list):
    """Compare properties of multiple compounds by CID."""
    cids = ",".join(str(c) for c in cid_list)
    props = "IUPACName,MolecularFormula,MolecularWeight,CanonicalSMILES,XLogP"
    url = f"{PUG_REST}/compound/cid/{cids}/property/{props}/JSON"
    resp = requests.get(url)
    resp.raise_for_status()
    return resp.json().get("PropertyTable", {}).get("Properties", [])

# Compare aspirin (2244), ibuprofen (3672), acetaminophen (1983)
results = compare_compounds([2244, 3672, 1983])
for compound in results:
    print(f"\n{compound.get('IUPACName', 'Unknown')}")
    print(f"  Formula: {compound.get('MolecularFormula')}")
    print(f"  MW: {compound.get('MolecularWeight')}")
    print(f"  SMILES: {compound.get('CanonicalSMILES')}")
    print(f"  LogP: {compound.get('XLogP')}")
```

## Common Research Patterns

**Structure-Activity Relationship (SAR) Analysis:** Use similarity searches to find structural analogs of lead compounds, then retrieve bioassay data to compare biological activity across the series.

**Virtual Screening:** Screen large compound libraries against drug-likeness filters (Lipinski's rules, Veber's rules) using property endpoints to prioritize candidates for experimental testing.

**Chemical Identifier Resolution:** Translate between compound names, CIDs, InChI, InChIKey, and SMILES notations. Essential for data integration across heterogeneous chemistry databases.

**Toxicology Research:** Access bioassay results and safety data for compounds to support toxicity profiling and risk assessment in environmental health research.

## Rate Limits and Best Practices

- **Rate limit:** Maximum 5 requests per second; add 200ms delays between requests
- **No more than 400 requests per minute** from a single IP
- **Batch requests:** Use comma-separated CIDs (up to 200) in a single request to minimize API calls
- **Async operations:** For large similarity/substructure searches, use the async workflow with list keys
- **Response formats:** Use JSON for programmatic access, SDF for structure files, CSV for tabular data
- **Caching:** Compound data is relatively static; cache property lookups aggressively
- **Error handling:** HTTP 404 means compound not found; 503 means server busy (retry with backoff)

## References

- PubChem PUG REST Documentation: https://pubchem.ncbi.nlm.nih.gov/docs/pug-rest
- PubChem PUG REST Tutorial: https://pubchem.ncbi.nlm.nih.gov/docs/pug-rest-tutorial
- PubChem Compound Database: https://pubchem.ncbi.nlm.nih.gov/
- PubChem Power User Gateway: https://pubchem.ncbi.nlm.nih.gov/docs/power-user-gateway
