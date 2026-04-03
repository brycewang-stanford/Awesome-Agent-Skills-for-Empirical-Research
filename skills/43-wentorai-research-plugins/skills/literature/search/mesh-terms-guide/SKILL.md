---
name: mesh-terms-guide
description: "Navigate MeSH vocabulary for precise PubMed and MEDLINE searches"
metadata:
  openclaw:
    emoji: "🧬"
    category: "literature"
    subcategory: "search"
    keywords: ["MeSH terms", "PubMed", "MEDLINE", "controlled vocabulary", "medical subject headings", "literature search"]
    source: "wentor-research-plugins"
---

# MeSH Terms Guide

A skill for using Medical Subject Headings (MeSH) to construct precise and comprehensive biomedical literature searches. Covers MeSH tree structure, subheadings, explosion, major topics, and strategies for combining MeSH with free-text terms.

## Understanding MeSH Vocabulary

### What Is MeSH?

MeSH is a hierarchical controlled vocabulary maintained by the National Library of Medicine. Every article indexed in MEDLINE/PubMed is assigned MeSH terms by trained indexers. Using MeSH ensures you capture articles that discuss a concept even when authors use different terminology.

### Tree Structure and Hierarchy

```
MeSH terms are organized in a tree with up to 13 hierarchical levels.

Example tree path for "Breast Neoplasms":

  Neoplasms [C04]
    Neoplasms by Site [C04.588]
      Breast Neoplasms [C04.588.180]
        Breast Neoplasms, Male [C04.588.180.260]
        Inflammatory Breast Neoplasms [C04.588.180.390]
        Phyllodes Tumor [C04.588.180.610]

A term can appear in multiple tree branches.
"Diabetes Mellitus, Type 2" appears under both:
  - Endocrine System Diseases
  - Metabolic Diseases
```

### Explosion vs. Non-Explosion

```
# Exploded search (default in PubMed):
"Breast Neoplasms"[MeSH]
  -> Retrieves articles indexed with "Breast Neoplasms"
     AND all narrower terms underneath it

# Non-exploded search:
"Breast Neoplasms"[MeSH:NoExp]
  -> Retrieves ONLY articles indexed with "Breast Neoplasms" itself
     Does NOT include narrower terms like Inflammatory Breast Neoplasms
```

## Working with MeSH in PubMed

### Finding the Right MeSH Term

```
Step 1: Go to the MeSH Browser (meshb.nlm.nih.gov)
Step 2: Enter your concept (e.g., "heart attack")
Step 3: Review the mapped term: "Myocardial Infarction"
Step 4: Check Entry Terms (synonyms that map to this heading)
Step 5: Examine the tree position and scope note
Step 6: Decide whether to explode or restrict
```

### Subheadings (Qualifiers)

MeSH subheadings refine a concept by specifying an aspect:

```python
def build_mesh_query(mesh_term: str, subheadings: list[str] = None,
                     major_topic: bool = False,
                     explode: bool = True) -> str:
    """
    Build a PubMed MeSH search fragment.

    Args:
        mesh_term: The MeSH heading
        subheadings: List of MeSH subheadings (e.g., 'therapy', 'diagnosis')
        major_topic: If True, restrict to articles where this is a major topic
        explode: If False, do not include narrower terms
    """
    field = "MeSH"
    if major_topic:
        field = "Majr"

    if not explode:
        field += ":NoExp"

    if subheadings:
        sub_parts = " OR ".join(
            f'"{mesh_term}/{sh}"[{field}]' for sh in subheadings
        )
        return f"({sub_parts})"

    return f'"{mesh_term}"[{field}]'


# Example: Diabetes treatment as a major topic
print(build_mesh_query(
    "Diabetes Mellitus, Type 2",
    subheadings=["drug therapy", "therapy"],
    major_topic=True
))
```

### Common Subheadings by Research Purpose

| Purpose | Subheadings |
|---------|-------------|
| Treatment | /therapy, /drug therapy, /surgery, /rehabilitation |
| Etiology | /etiology, /complications, /chemically induced |
| Diagnosis | /diagnosis, /diagnostic imaging, /pathology |
| Prevention | /prevention and control |
| Epidemiology | /epidemiology, /mortality, /statistics and numerical data |
| Genetics | /genetics, /metabolism |

## Combining MeSH with Free Text

### Comprehensive Search Strategy

A robust search combines both MeSH terms and free-text keywords to capture all relevant articles, including those not yet indexed:

```
# Block 1 - MeSH terms for Concept A
("Myocardial Infarction"[MeSH] OR "Acute Coronary Syndrome"[MeSH])

# Block 2 - Free-text terms for Concept A
("myocardial infarction"[tiab] OR "heart attack"[tiab] OR
 "acute coronary"[tiab] OR "STEMI"[tiab] OR "NSTEMI"[tiab])

# Block 3 - Combine with OR
(Block 1 OR Block 2)

# Repeat for Concept B, then AND the concept blocks together
```

### Handling Unindexed Articles

PubMed articles are often available before MeSH indexing is complete. These articles will not be found by MeSH-only searches. Always include free-text (Title/Abstract) terms alongside MeSH to capture recent publications:

```
"Diabetes Mellitus, Type 2"[MeSH]
OR
("type 2 diabetes"[tiab] OR "T2DM"[tiab] OR "non-insulin dependent"[tiab])
```

## Validating Your MeSH Strategy

### Recall and Precision Check

1. Identify 5-10 known relevant articles (your "gold standard" set)
2. Run your MeSH search and verify all gold-standard articles appear
3. If any are missing, check their MeSH indexing to find gaps in your strategy
4. Scan the first 100 results to estimate precision
5. Adjust subheadings and explosion settings accordingly

### Documenting MeSH Searches for Systematic Reviews

Record the MeSH database version date, all terms used with their tree numbers, explosion status, and subheadings. This allows the search to be replicated exactly at a later date.
