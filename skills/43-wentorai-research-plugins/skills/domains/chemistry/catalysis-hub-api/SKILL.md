---
name: catalysis-hub-api
description: "Query computational catalysis reaction data via Catalysis Hub GraphQL"
metadata:
  openclaw:
    emoji: "⚗️"
    category: "domains"
    subcategory: "chemistry"
    keywords: ["catalysis", "DFT", "reaction energy", "surface chemistry", "computational chemistry", "GraphQL"]
    source: "https://www.catalysis-hub.org"
---

# Catalysis Hub GraphQL API Guide

## Overview

Catalysis Hub is an open-access database of DFT-calculated reaction energies and activation barriers for heterogeneous catalysis, developed at SUNCAT Center (Stanford/SLAC). It aggregates computational results from published studies, enabling researchers to search, compare, and reuse DFT data for catalyst screening and mechanism validation.

The GraphQL endpoint provides structured access to reactions, publications, and atomic structures. All data is linked to peer-reviewed publications and includes computational details (DFT code, XC functional, surface facet, coverage).

## Authentication

No authentication required. Catalysis Hub is a free public service with no API keys.

## GraphQL Schema

**Endpoint:** `https://api.catalysis-hub.org/graphql`

All queries use HTTP POST with a JSON `query` field. Responses follow the Relay connection pattern (`edges`/`node`).

### Root Query Types

| Query | Description |
|-------|-------------|
| `reactions` | DFT-computed reaction energies and barriers |
| `publications` | Published studies linked to reaction data |
| `systems` | Atomic structure data (ASE Atoms objects) |
| `species` | Chemical species involved in reactions |

### Reaction Fields

`chemicalComposition`, `surfaceComposition`, `facet`, `reactionEnergy` (eV), `activationEnergy` (eV), `dftCode` (e.g. `Quantum-Espresso`, `VASP-5.4.4`), `dftFunctional` (e.g. `RPBE`), `reactants` (JSON), `products` (JSON), `Equation` (e.g. `0.5O2(g) + * -> O*`)

### Publication Fields

`title`, `authors` (JSON), `journal`, `year` (Int), `doi`, `reactions` (linked Reaction list)

## Core Queries

### List Reactions

```bash
curl -s -X POST "https://api.catalysis-hub.org/graphql" \
  -H "Content-Type: application/json" -d '{"query":"{ reactions(first: 3) { edges { node { chemicalComposition reactionEnergy activationEnergy surfaceComposition } } } }"}'
```

Response (truncated):

```json
{"data":{"reactions":{"edges":[
  {"node":{"chemicalComposition":"Nb9Sn3","reactionEnergy":-9.687,"activationEnergy":null,"surfaceComposition":"Nb3Sn"}},
  {"node":{"chemicalComposition":"Ir3V9","reactionEnergy":-8.395,"activationEnergy":null,"surfaceComposition":"V3Ir"}},
  {"node":{"chemicalComposition":"Ir9Ni3","reactionEnergy":-2.005,"activationEnergy":null,"surfaceComposition":"Ir3Ni"}}
]}}}
```

### Filter by Surface Composition

```bash
curl -s -X POST "https://api.catalysis-hub.org/graphql" \
  -H "Content-Type: application/json" -d '{"query":"{ reactions(first: 2, surfaceComposition: \"Pt\") { edges { node { chemicalComposition surfaceComposition facet reactionEnergy dftCode dftFunctional Equation } } } }"}'
```

Response (truncated):

```json
{"data":{"reactions":{"edges":[
  {"node":{"chemicalComposition":"Pt28","surfaceComposition":"Pt","facet":"100","reactionEnergy":0.856,"dftCode":"Quantum-Espresso","dftFunctional":"RPBE","Equation":"0.5N2(g) + * -> N*"}},
  {"node":{"chemicalComposition":"Pt28","surfaceComposition":"Pt","facet":"100","reactionEnergy":-0.984,"dftCode":"Quantum-Espresso","dftFunctional":"RPBE","Equation":"0.5O2(g) + * -> O*"}}
]}}}
```

### Search by Chemical Composition (partial match with `~` prefix)

```bash
curl -s -X POST "https://api.catalysis-hub.org/graphql" \
  -H "Content-Type: application/json" -d '{"query":"{ reactions(first: 3, chemicalComposition: \"~CO\") { edges { node { chemicalComposition reactionEnergy dftCode } } } }"}'
```

Response (truncated):

```json
{"data":{"reactions":{"edges":[
  {"node":{"chemicalComposition":"Co9Cr2FeMnNiO20","reactionEnergy":1.910,"dftCode":"VASP-5.4.4"}},
  {"node":{"chemicalComposition":"Co9Cr2FeMnNiO20","reactionEnergy":0.648,"dftCode":"VASP-5.4.4"}},
  {"node":{"chemicalComposition":"Co10CrFeMnNiO20","reactionEnergy":3.167,"dftCode":"VASP-5.4.4"}}
]}}}
```

### Query Publications

```bash
curl -s -X POST "https://api.catalysis-hub.org/graphql" \
  -H "Content-Type: application/json" -d '{"query":"{ publications(first: 2, year: 2019) { edges { node { title authors journal year doi } } } }"}'
```

Response (truncated):

```json
{"data":{"publications":{"edges":[
  {"node":{"title":"High-Throughput Calculations of Catalytic Properties of Bimetallic Alloy Surfaces","authors":"[\"Mamun, Osman\",\"Winther, Kirsten T.\",\"Boes, Jacob R.\",\"Bligaard, Thomas\"]","journal":"Scientific Data","year":2019,"doi":"10.1038/s41597-019-0080-z"}},
  {"node":{"title":"Selective high-temperature CO2 electrolysis enabled by oxidized carbon intermediates","journal":"Nature Energy","year":2019,"doi":"10.1038/s41560-019-0457-4"}}
]}}}
```

## Rate Limits

- No documented rate limits; add 200-500ms delays between requests as courtesy
- Use `first` to limit results; pagination via cursor-based `after` argument

## Academic Use Cases

- **Catalyst Screening:** Compare adsorption energies across bimetallic alloy surfaces to identify candidates for target reactions (ORR, NRR, HER)
- **DFT Validation:** Cross-reference your DFT results against published values matched by surface, facet, and functional
- **Scaling Relations:** Retrieve adsorption energies across surfaces to build Bronsted-Evans-Polanyi (BEP) relations
- **Literature Discovery:** Find publications by year or linked reactions for citation and methodology verification

## Python Example

```python
import requests

ENDPOINT = "https://api.catalysis-hub.org/graphql"

def query_catalysis_hub(query):
    """Execute a GraphQL query against Catalysis Hub."""
    resp = requests.post(ENDPOINT, json={"query": query})
    resp.raise_for_status()
    return resp.json()["data"]

# Screen adsorption energies on Pt surfaces
data = query_catalysis_hub("""
{
  reactions(first: 20, surfaceComposition: "Pt") {
    edges { node { Equation facet reactionEnergy dftFunctional } }
  }
}
""")
for edge in data["reactions"]["edges"]:
    r = edge["node"]
    print(f"{r['Equation']:<30} facet={r['facet']}  E={r['reactionEnergy']:+.3f} eV")

# Publications with linked reactions
pubs = query_catalysis_hub("""
{
  publications(first: 5, year: 2019) {
    edges { node { title doi reactions { surfaceComposition Equation } } }
  }
}
""")
for edge in pubs["publications"]["edges"]:
    pub = edge["node"]
    print(f"{pub['title']} | DOI: {pub['doi']} | {len(pub.get('reactions') or [])} reactions")
```

## References

- Catalysis Hub: https://www.catalysis-hub.org
- GraphQL Endpoint: https://api.catalysis-hub.org/graphql
- Winther et al., "Catalysis-Hub.org: An Open Electronic Structure Database for Surface Reactions," Sci. Data 6, 75 (2019). DOI: 10.1038/s41597-019-0081-y
- SUNCAT Center: https://suncat.stanford.edu
