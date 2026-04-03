---
name: preprint-servers-guide
description: "Guide to preprint servers across scientific disciplines"
metadata:
  openclaw:
    emoji: "📄"
    category: "literature"
    subcategory: "fulltext"
    keywords: ["preprint server", "preprint submission", "arXiv", "bioRxiv", "open access"]
    source: "wentor-research-plugins"
---

# Preprint Servers Guide

A comprehensive guide to preprint servers across all major academic disciplines, covering submission workflows, licensing, and programmatic access.

## What Are Preprints?

Preprints are complete research manuscripts shared publicly before formal peer review. They enable rapid dissemination of findings, establish priority of discovery, and invite community feedback before journal submission.

Key characteristics:
- **Not peer reviewed** (but increasingly moderated for basic quality)
- **Freely accessible** to anyone
- **Citable** with a DOI
- **Versioned** (authors can post revisions)
- **Compatible** with most journal submissions (check journal policy first)

## Major Preprint Servers by Discipline

| Server | Disciplines | Operator | Moderation | DOI Prefix |
|--------|-------------|----------|------------|------------|
| arXiv | Physics, Math, CS, Econ, EE, Stats, Q-Bio | Cornell | Light screening | 10.48550 |
| bioRxiv | Biology (all subfields) | Cold Spring Harbor | Basic screening | 10.1101 |
| medRxiv | Clinical/health sciences | Yale/BMJ/CSHL | Enhanced screening | 10.1101 |
| ChemRxiv | Chemistry | ACS | Moderate screening | 10.26434 |
| EarthArXiv | Earth/planetary sciences | Community-led | Light screening | 10.31223 |
| PsyArXiv | Psychology | COS/OSF | Light screening | 10.31234 |
| SocArXiv | Social sciences | COS/OSF | Light screening | 10.31235 |
| SSRN | Social sciences, law, economics | Elsevier | Minimal | various |
| engrXiv | Engineering | COS/OSF | Light screening | 10.31224 |
| EdArXiv | Education | COS/OSF | Light screening | 10.35542 |
| Preprints.org | Multidisciplinary | MDPI | Basic screening | 10.20944 |
| Research Square | Multidisciplinary | Springer Nature | In Review service | 10.21203 |
| TechRxiv | Electrical eng., CS | IEEE | Moderate | 10.36227 |

## Submission Workflow

### arXiv Submission

1. **Create an account** at arxiv.org and get endorsed (new users need endorsement in the relevant category).
2. **Prepare your manuscript**:
   - LaTeX source (preferred): upload `.tex` + figures + `.bbl` as a single archive
   - PDF: accepted but LaTeX is strongly preferred
3. **Select categories**: Choose a primary category (e.g., `cs.CL`) and optional cross-lists.
4. **Submit metadata**: Title, abstract, authors, comments, journal-ref (if applicable).
5. **Wait for processing**: Papers appear in the next daily posting (submissions before 14:00 ET on weekdays).
6. **Receive arXiv ID**: Format `YYMM.NNNNN` (e.g., `2401.12345`).

```bash
# Download arXiv paper PDF programmatically
curl -o paper.pdf https://arxiv.org/pdf/2401.12345

# Get metadata via arXiv API
curl "http://export.arxiv.org/api/query?id_list=2401.12345"
```

### bioRxiv/medRxiv Submission

1. **Create an account** at biorxiv.org or medrxiv.org.
2. **Upload manuscript** as a single Word or PDF file.
3. **Add metadata**: Title, authors with ORCIDs, abstract, subject area.
4. **Select license**: CC-BY, CC-BY-NC, CC-BY-ND, CC-BY-NC-ND, or CC0.
5. **Screening**: bioRxiv screens for plagiarism, dual submission, and non-scientific content. medRxiv applies additional clinical content screening.
6. **Posting**: Typically within 24-48 hours after screening.

```python
# bioRxiv API: search recent preprints
import requests

response = requests.get(
    "https://api.biorxiv.org/details/biorxiv/2024-01-01/2024-01-31",
    params={"cursor": 0, "format": "json"}
)
papers = response.json()["collection"]
for p in papers[:5]:
    print(f"[{p['date']}] {p['title']} (doi: {p['doi']})")
```

## Licensing Options

| License | Allows Reuse | Allows Commercial | Allows Derivatives | Requires Attribution |
|---------|-------------|-------------------|--------------------|---------------------|
| CC-BY | Yes | Yes | Yes | Yes |
| CC-BY-NC | Yes | No | Yes | Yes |
| CC-BY-ND | Yes | Yes | No | Yes |
| CC-BY-NC-ND | Yes | No | No | Yes |
| CC0 | Yes | Yes | Yes | No |

**Recommendation**: Use CC-BY for maximum openness and compatibility with funder mandates (NIH, Wellcome Trust, ERC). Use CC-BY-NC if you want to restrict commercial reuse.

## Journal Policies on Preprints

Most major publishers now accept manuscripts previously posted as preprints:

- **Accepts preprints**: Nature, Science, PNAS, Cell, Lancet, BMJ, PLOS, eLife, all IEEE journals, most ACM venues
- **Does not accept preprints**: Some society journals in certain fields (check SHERPA/RoMEO at sherpa.ac.uk/romeo for specific policies)

Important considerations:
- Some journals require you to update the preprint with a link to the published version.
- Dual posting on multiple preprint servers may violate policies.
- Embargo periods may apply for some clinical journals (especially medRxiv).

## Programmatic Access Comparison

| Server | API Available | Bulk Download | OAI-PMH | Rate Limit |
|--------|--------------|---------------|---------|------------|
| arXiv | Yes (Atom) | Yes (S3 bulk) | Yes | 1 req/3 sec |
| bioRxiv | Yes (REST) | No | No | Polite use |
| SSRN | No public API | No | No | N/A |
| OSF Preprints | Yes (SHARE) | Yes | Yes | Polite use |

## Best Practices

1. **Post before or at submission**: Maximize the time for community feedback.
2. **Use ORCIDs**: Link your preprint to your ORCID profile for discoverability.
3. **Update with journal DOI**: After acceptance, add a comment or new version linking to the published article.
4. **Choose the right server**: Use the discipline-specific server for maximum visibility within your community.
5. **Check funder requirements**: Some funders (NIH, Plan S) mandate preprint posting for funded research.
