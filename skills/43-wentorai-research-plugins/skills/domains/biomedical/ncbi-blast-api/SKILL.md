---
name: ncbi-blast-api
description: "Run sequence similarity searches via the NCBI BLAST REST API"
metadata:
  openclaw:
    emoji: "🧪"
    category: "domains"
    subcategory: "biomedical"
    keywords: ["BLAST", "sequence alignment", "NCBI", "homology search", "protein similarity", "nucleotide search"]
    source: "https://blast.ncbi.nlm.nih.gov/"
---

# NCBI BLAST REST API

## Overview

BLAST (Basic Local Alignment Search Tool) is the most widely used bioinformatics tool, comparing nucleotide or protein sequences against databases to find regions of similarity. The NCBI BLAST REST API enables programmatic submission of searches, status polling, and result retrieval. Free, no authentication required (but rate-limited).

## API Workflow

BLAST searches are asynchronous: submit → poll → retrieve.

### Step 1: Submit Search

```bash
# Nucleotide BLAST (blastn)
curl -X POST "https://blast.ncbi.nlm.nih.gov/blast/Blast.cgi" \
  -d "CMD=Put&PROGRAM=blastn&DATABASE=nt&QUERY=ATGCGATCGATCG..."

# Protein BLAST (blastp)
curl -X POST "https://blast.ncbi.nlm.nih.gov/blast/Blast.cgi" \
  -d "CMD=Put&PROGRAM=blastp&DATABASE=nr&QUERY=MKTLLLTLVVVTIVCL..."

# BLAST with specific parameters
curl -X POST "https://blast.ncbi.nlm.nih.gov/blast/Blast.cgi" \
  -d "CMD=Put&PROGRAM=blastn&DATABASE=nt&QUERY=SEQUENCE&\
EXPECT=0.001&WORD_SIZE=11&HITLIST_SIZE=50"
```

### Step 2: Check Status

```bash
# Poll for completion (returns XML with Status field)
curl "https://blast.ncbi.nlm.nih.gov/blast/Blast.cgi?CMD=Get&FORMAT_OBJECT=SearchInfo&RID=YOUR_RID"
```

### Step 3: Retrieve Results

```bash
# Get results in XML
curl "https://blast.ncbi.nlm.nih.gov/blast/Blast.cgi?CMD=Get&FORMAT_TYPE=XML&RID=YOUR_RID"

# Get results in JSON
curl "https://blast.ncbi.nlm.nih.gov/blast/Blast.cgi?CMD=Get&FORMAT_TYPE=JSON2_S&RID=YOUR_RID"

# Get results in tabular format
curl "https://blast.ncbi.nlm.nih.gov/blast/Blast.cgi?CMD=Get&FORMAT_TYPE=Tabular&RID=YOUR_RID"
```

### BLAST Programs

| Program | Query → Database | Use case |
|---------|-----------------|----------|
| `blastn` | Nucleotide → Nucleotide | DNA/RNA similarity |
| `blastp` | Protein → Protein | Protein homology |
| `blastx` | Translated nuc → Protein | Find protein homologs of DNA |
| `tblastn` | Protein → Translated nuc | Find DNA encoding similar protein |
| `tblastx` | Translated nuc → Translated nuc | Compare at protein level |

### Common Databases

| Database | Content |
|----------|---------|
| `nt` | All GenBank nucleotide sequences |
| `nr` | Non-redundant protein sequences |
| `refseq_rna` | RefSeq RNA sequences |
| `refseq_protein` | RefSeq protein sequences |
| `swissprot` | UniProtKB/Swiss-Prot (curated) |
| `pdb` | Protein Data Bank sequences |

### Key Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `PROGRAM` | BLAST program | Required |
| `DATABASE` | Target database | Required |
| `QUERY` | Sequence or accession | Required |
| `EXPECT` | E-value threshold | `10` |
| `WORD_SIZE` | Word size | `11` (blastn), `6` (blastp) |
| `HITLIST_SIZE` | Max results | `100` |
| `MATRIX` | Scoring matrix (protein) | `BLOSUM62` |
| `FILTER` | Low complexity filter | `L` |
| `ENTREZ_QUERY` | Restrict to organism | `Homo sapiens[ORGN]` |

## Python Usage

```python
import time
import requests
from xml.etree import ElementTree

BLAST_URL = "https://blast.ncbi.nlm.nih.gov/blast/Blast.cgi"


def submit_blast(sequence: str, program: str = "blastn",
                 database: str = "nt",
                 evalue: float = 0.001) -> str:
    """Submit a BLAST search, return Request ID."""
    resp = requests.post(BLAST_URL, data={
        "CMD": "Put",
        "PROGRAM": program,
        "DATABASE": database,
        "QUERY": sequence,
        "EXPECT": evalue,
        "HITLIST_SIZE": 50,
    })
    resp.raise_for_status()

    for line in resp.text.split("\n"):
        if "RID = " in line:
            return line.split("=")[1].strip()
    raise ValueError("No RID in response")


def wait_for_results(rid: str, poll_interval: int = 15,
                     max_wait: int = 300) -> bool:
    """Poll until BLAST search completes."""
    elapsed = 0
    while elapsed < max_wait:
        resp = requests.get(BLAST_URL, params={
            "CMD": "Get",
            "FORMAT_OBJECT": "SearchInfo",
            "RID": rid,
        })
        if "Status=READY" in resp.text:
            return True
        if "Status=FAILED" in resp.text:
            raise RuntimeError("BLAST search failed")
        time.sleep(poll_interval)
        elapsed += poll_interval
    raise TimeoutError(f"BLAST timed out after {max_wait}s")


def get_results(rid: str) -> list:
    """Retrieve BLAST results as parsed hits."""
    resp = requests.get(BLAST_URL, params={
        "CMD": "Get",
        "FORMAT_TYPE": "XML",
        "RID": rid,
    })
    resp.raise_for_status()

    root = ElementTree.fromstring(resp.text)
    ns = ""
    hits = []
    for hit in root.iter(f"{ns}Hit"):
        hsps = hit.find(f"{ns}Hit_hsps")
        hsp = hsps.find(f"{ns}Hsp") if hsps is not None else None
        hits.append({
            "accession": hit.findtext(f"{ns}Hit_accession", ""),
            "description": hit.findtext(f"{ns}Hit_def", ""),
            "length": int(hit.findtext(f"{ns}Hit_len", "0")),
            "evalue": float(hsp.findtext(f"{ns}Hsp_evalue", "999"))
                     if hsp is not None else 999,
            "identity": float(hsp.findtext(f"{ns}Hsp_identity", "0"))
                       if hsp is not None else 0,
            "score": float(hsp.findtext(f"{ns}Hsp_bit-score", "0"))
                    if hsp is not None else 0,
        })
    return hits


# Example: BLAST a short DNA sequence
rid = submit_blast("ATGCGATCGATCGATCGATCGATCG", program="blastn")
print(f"Submitted BLAST search: {rid}")

wait_for_results(rid)
hits = get_results(rid)
for h in hits[:5]:
    print(f"{h['accession']}: {h['description'][:60]}...")
    print(f"  E-value: {h['evalue']:.2e} | Identity: {h['identity']}")
```

## Rate Limits

- Max 1 request per 10 seconds for search submission
- Max concurrent searches: varies by load
- NCBI requests a contact email in User-Agent header

## References

- [NCBI BLAST](https://blast.ncbi.nlm.nih.gov/)
- [BLAST URL API Guide](https://blast.ncbi.nlm.nih.gov/doc/blast-help/developerinfo.html)
- [BLAST Command Line](https://www.ncbi.nlm.nih.gov/books/NBK279690/)
- Altschul, S.F. et al. (1990). "Basic local alignment search tool." *J. Mol. Biol.* 215(3).
