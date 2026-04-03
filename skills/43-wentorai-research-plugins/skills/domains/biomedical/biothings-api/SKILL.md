---
name: biothings-api
description: "Query gene, variant, and drug annotations via BioThings APIs"
metadata:
  openclaw:
    emoji: "🧪"
    category: "domains"
    subcategory: "biomedical"
    keywords: ["gene annotation", "variant annotation", "drug data", "BioThings", "mygene", "myvariant", "bioinformatics"]
    source: "https://biothings.io"
---

# BioThings API Suite

## Overview

BioThings is a family of high-performance biomedical annotation APIs developed at the Scripps Research Institute. The suite provides unified, up-to-date access to gene, variant, and chemical/drug annotations aggregated from dozens of authoritative sources. Three primary services cover the core entities in translational research:

- **MyGene.info** — Gene annotations from NCBI Entrez, Ensembl, UniProt, GO, KEGG, Reactome, and 20+ sources.
- **MyVariant.info** — Variant annotations from dbSNP, ClinVar, gnomAD, CADD, COSMIC, and 15+ sources.
- **MyChem.info** — Drug and chemical annotations from NDC, DrugBank, ChEMBL, FDA, PubChem, and 10+ sources.

All three share identical query syntax, require no authentication, and return JSON. Free for academic and commercial use.

## Authentication

No authentication or API keys are required. All endpoints are open-access.

```bash
# No API key needed — just query directly
curl "https://mygene.info/v3/query?q=BRCA1&size=1"
```

## MyGene.info — Gene Annotations

### Search Genes

```
GET https://mygene.info/v3/query?q={query}&size={n}
```

Query by gene symbol, name, Entrez ID, Ensembl ID, or keyword. Supports boolean operators (`AND`, `OR`, `NOT`) and field-specific queries like `symbol:CDK2`.

```bash
curl -s "https://mygene.info/v3/query?q=BRCA1&size=1"
```

Response:

```json
{
  "took": 178,
  "total": 13223,
  "hits": [
    {
      "_id": "672",
      "_score": 145.6796,
      "entrezgene": "672",
      "name": "BRCA1 DNA repair associated",
      "symbol": "BRCA1",
      "taxid": 9606
    }
  ]
}
```

### Get Gene by ID

```
GET https://mygene.info/v3/gene/{entrez_id}
```

Returns comprehensive annotations for a single gene. Use the `fields` parameter to select specific data sources.

```bash
# Full annotation (large response)
curl -s "https://mygene.info/v3/gene/1017"

# Selective fields
curl -s "https://mygene.info/v3/gene/1017?fields=symbol,name,summary,genomic_pos,go"
```

Response (key fields for CDK2, Entrez ID 1017):

```json
{
  "_id": "1017",
  "symbol": "CDK2",
  "name": "cyclin dependent kinase 2",
  "HGNC": "1771",
  "MIM": "116953",
  "AllianceGenome": "1771",
  "taxid": 9606,
  "type_of_gene": "protein-coding"
}
```

The full response includes accessions, Gene Ontology terms, pathway memberships (KEGG, Reactome, WikiPathways), protein domains (InterPro, Pfam), homology data, and genomic coordinates.

## MyVariant.info — Variant Annotations

### Search Variants

```
GET https://myvariant.info/v1/query?q={query}&size={n}
```

Query by rsID, HGVS notation (e.g., `chr7:g.140453136A>T`), gene symbol, or ClinVar significance. Returns aggregated annotations from 15+ sources.

```bash
curl -s "https://myvariant.info/v1/query?q=rs58991260&size=1"
```

Response (truncated):

```json
{
  "took": 20,
  "total": 1,
  "hits": [
    {
      "_id": "chr1:g.218631822G>A",
      "_score": 21.382616,
      "dbsnp": {
        "rsid": "rs58991260",
        "vartype": "snv",
        "ref": "G",
        "alt": "A",
        "chrom": "1"
      },
      "cadd": {
        "phred": 1.679,
        "consequence": "INTERGENIC",
        "chrom": 1,
        "pos": 218631822
      },
      "gnomad_genome": {
        "af": { "af": 0.0150338, "af_afr": 0.0528007, "af_eas": 0.0, "af_nfe": 0.00032417 },
        "alt": "A",
        "ref": "G"
      }
    }
  ]
}
```

### Get Variant by HGVS ID

```
GET https://myvariant.info/v1/variant/{hgvs_id}
```

```bash
curl -s "https://myvariant.info/v1/variant/chr1:g.218631822G>A?fields=dbsnp,cadd,clinvar"
```

## MyChem.info — Drug & Chemical Annotations

### Search Drugs/Chemicals

```
GET https://mychem.info/v1/query?q={query}&size={n}
```

Query by drug name, NDC code, InChIKey, or active ingredient. Aggregates data from FDA NDC, DrugBank, ChEMBL, PubChem, SIDER, and more.

```bash
curl -s "https://mychem.info/v1/query?q=aspirin&size=1"
```

Response (truncated):

```json
{
  "took": 82,
  "total": 248,
  "hits": [
    {
      "_id": "0615-8613",
      "_score": 13.657401,
      "ndc": {
        "substancename": "ASPIRIN",
        "nonproprietaryname": "Aspirin",
        "proprietaryname": "Adult Low Dose Aspirin",
        "active_numerator_strength": "81",
        "active_ingred_unit": "mg/1",
        "dosageformname": "TABLET, DELAYED RELEASE",
        "routename": "ORAL",
        "producttypename": "HUMAN OTC DRUG",
        "pharm_classes": [
          "Cyclooxygenase Inhibitors [MoA]",
          "Decreased Platelet Aggregation [PE]",
          "Anti-Inflammatory Agents, Non-Steroidal [CS]",
          "Nonsteroidal Anti-inflammatory Drug [EPC]",
          "Platelet Aggregation Inhibitor [EPC]"
        ]
      }
    }
  ]
}
```

### Get Chemical by ID

```
GET https://mychem.info/v1/chem/{id}
```

```bash
curl -s "https://mychem.info/v1/chem/CHEMBL25?fields=drugbank,chembl,pubchem"
```

## Query Syntax (Shared Across All Three APIs)

All BioThings APIs share the same query engine. Key features:

| Feature | Syntax | Example |
|---------|--------|---------|
| Field-specific | `field:value` | `symbol:TP53` |
| Boolean | `AND`, `OR`, `NOT` | `BRCA1 AND cancer` |
| Wildcard | `*` | `CDK*` |
| Range | `[min TO max]` | `exac.af:[0.01 TO 0.05]` |
| Pagination | `size`, `from` | `size=20&from=40` |
| Field selection | `fields` | `fields=symbol,name,go` |
| Sorting | `sort` | `sort=_score:desc` |
| Batch POST | POST with `ids` | Up to 1000 IDs per request |

## Rate Limits

- **GET requests:** 3 per second sustained; bursts up to 10/s tolerated
- **POST batch requests:** 1 per second; up to 1000 IDs per batch
- **No daily cap** for reasonable academic usage
- **Best practice:** Add 350ms delays between sequential requests; use batch POST for bulk queries
- **User-Agent header:** Set a descriptive User-Agent for priority support from the BioThings team

## Python Example: Cross-API Gene-Variant-Drug Lookup

```python
import requests, time

MYGENE = "https://mygene.info/v3"
MYVARIANT = "https://myvariant.info/v1"
MYCHEM = "https://mychem.info/v1"

def search_gene(symbol):
    resp = requests.get(f"{MYGENE}/query",
                        params={"q": f"symbol:{symbol}", "size": 1, "species": "human"})
    resp.raise_for_status()
    hits = resp.json().get("hits", [])
    return hits[0] if hits else {}

def search_variants(gene_symbol, size=5):
    resp = requests.get(f"{MYVARIANT}/query",
                        params={"q": f"clinvar.gene.symbol:{gene_symbol}",
                                "fields": "dbsnp.rsid,clinvar.rcv.clinical_significance,cadd.phred",
                                "size": size})
    resp.raise_for_status()
    return resp.json().get("hits", [])

def search_drug(name):
    resp = requests.get(f"{MYCHEM}/query",
                        params={"q": name, "size": 1,
                                "fields": "ndc.substancename,ndc.pharm_classes"})
    resp.raise_for_status()
    hits = resp.json().get("hits", [])
    return hits[0] if hits else {}

# Translational research pipeline: gene -> variants -> drug
gene = search_gene("BRCA1")
print(f"Gene: {gene.get('symbol')} (Entrez: {gene.get('entrezgene')})")
time.sleep(0.35)

variants = search_variants("BRCA1", size=3)
for v in variants:
    rsid = v.get("dbsnp", {}).get("rsid", v.get("_id"))
    print(f"  Variant: {rsid} | CADD: {v.get('cadd', {}).get('phred', 'N/A')}")
time.sleep(0.35)

drug = search_drug("olaparib")
print(f"  Drug: {drug.get('ndc', {}).get('substancename', 'N/A')}")
```

## Academic Use Cases

- **GWAS follow-up:** Annotate thousands of significant SNPs with allele frequencies (gnomAD), functional predictions (CADD, SIFT, PolyPhen), and clinical significance (ClinVar) via MyVariant.info batch queries.
- **Drug target mapping:** Link gene symbols to pathway memberships (KEGG, Reactome) via MyGene.info, then find approved drugs targeting those pathways via MyChem.info.
- **Pharmacogenomics:** Cross-reference variant annotations with drug metabolism data to identify clinically actionable gene-drug interactions.
- **Systematic reviews:** Programmatically collect gene/variant metadata across large candidate lists to populate supplementary tables in genomics publications.

## References

- BioThings API Hub: https://biothings.io
- MyGene.info Documentation: https://docs.mygene.info
- MyVariant.info Documentation: https://docs.myvariant.info
- MyChem.info Documentation: https://docs.mychem.info
- Publication: Xin J et al. *Genome Biology* 17:91 (2016). https://doi.org/10.1186/s13059-016-0953-9
