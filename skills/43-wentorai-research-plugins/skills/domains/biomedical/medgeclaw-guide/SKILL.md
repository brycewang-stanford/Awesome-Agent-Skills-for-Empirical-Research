---
name: medgeclaw-guide
description: "AI research assistant for biomedicine, RNA-seq, and drug discovery"
metadata:
  openclaw:
    emoji: "💊"
    category: "domains"
    subcategory: "biomedical"
    keywords: ["biomedicine", "RNA-seq", "drug discovery", "clinical AI", "medical NLP", "bioinformatics"]
    source: "wentor-research-plugins"
---

# MedgeClaw Guide

## Overview

MedgeClaw is a conceptual framework for AI-powered biomedical research assistance, integrating natural language processing for medical literature, computational biology pipelines, and drug discovery workflows. The name reflects the integration of Medical knowledge Edge (cutting-edge biomedical AI) with the Claw agent pattern for autonomous research execution.

Biomedical research is uniquely suited for AI augmentation because it generates massive, heterogeneous data -- genomic sequences, clinical records, imaging data, molecular structures, and published literature -- that exceeds the capacity of individual researchers to synthesize. AI systems that can navigate across these data types, identify patterns, and suggest hypotheses accelerate the pace of discovery.

This guide covers the key computational methods in biomedical AI research: medical NLP for literature mining, RNA-seq analysis pipelines, drug discovery computational workflows, and the integration patterns that connect these components into coherent research workflows. The focus is on methods that are reproducible, validated, and suitable for publication in biomedical journals.

## Medical NLP and Literature Mining

### Biomedical Named Entity Recognition

```python
# Biomedical NER using scispaCy
import scispacy
import spacy
from scispacy.linking import EntityLinker

# Load biomedical NER model
nlp = spacy.load("en_ner_bionlp13cg_md")

# Add UMLS entity linker for concept normalization
nlp.add_pipe("scispacy_linker", config={
    "resolve_abbreviations": True,
    "linker_name": "umls",
})

def extract_biomedical_entities(text: str) -> dict:
    """
    Extract and normalize biomedical entities from text.
    Returns genes, chemicals, diseases, and their UMLS mappings.
    """
    doc = nlp(text)
    entities = {
        "genes": [],
        "chemicals": [],
        "diseases": [],
        "other": [],
    }

    category_map = {
        "GENE_OR_GENE_PRODUCT": "genes",
        "SIMPLE_CHEMICAL": "chemicals",
        "CANCER": "diseases",
        "ORGAN": "other",
        "CELL": "other",
    }

    for ent in doc.ents:
        category = category_map.get(ent.label_, "other")
        entity_info = {
            "text": ent.text,
            "label": ent.label_,
            "start": ent.start_char,
            "end": ent.end_char,
        }

        # Add UMLS links if available
        if hasattr(ent, "_") and hasattr(ent._, "kb_ents"):
            if ent._.kb_ents:
                top_link = ent._.kb_ents[0]
                entity_info["umls_cui"] = top_link[0]
                entity_info["confidence"] = round(top_link[1], 3)

        entities[category].append(entity_info)

    return entities
```

### Systematic Literature Search Pipeline

```python
from Bio import Entrez
import time

Entrez.email = "researcher@university.edu"

def systematic_pubmed_search(
    query: str,
    max_results: int = 1000,
    date_range: tuple = ("2020/01/01", "2025/12/31"),
) -> list:
    """
    Conduct a systematic PubMed search with structured result extraction.
    Suitable for systematic reviews and meta-analyses.
    """
    # Step 1: Search PubMed
    handle = Entrez.esearch(
        db="pubmed",
        term=query,
        retmax=max_results,
        datetype="pdat",
        mindate=date_range[0],
        maxdate=date_range[1],
        sort="relevance",
    )
    results = Entrez.read(handle)
    handle.close()

    pmids = results["IdList"]
    print(f"Found {results['Count']} results, retrieving {len(pmids)}")

    # Step 2: Fetch article details in batches
    articles = []
    batch_size = 100
    for i in range(0, len(pmids), batch_size):
        batch = pmids[i:i + batch_size]
        handle = Entrez.efetch(
            db="pubmed", id=",".join(batch),
            rettype="xml", retmode="xml"
        )
        records = Entrez.read(handle)
        handle.close()

        for article in records["PubmedArticle"]:
            medline = article["MedlineCitation"]
            art = medline["Article"]
            articles.append({
                "pmid": str(medline["PMID"]),
                "title": art["ArticleTitle"],
                "abstract": art.get("Abstract", {}).get("AbstractText", [""])[0],
                "journal": art["Journal"]["Title"],
                "year": art["Journal"]["JournalIssue"]["PubDate"].get("Year", "N/A"),
                "mesh_terms": [
                    d["DescriptorName"]
                    for d in medline.get("MeshHeadingList", [])
                ] if "MeshHeadingList" in medline else [],
            })

        time.sleep(0.4)  # Respect NCBI rate limits

    return articles
```

## RNA-seq Analysis

### Complete DESeq2 Workflow

```r
# Complete RNA-seq differential expression analysis with DESeq2
# This is the standard workflow for biomedical RNA-seq papers

library(DESeq2)
library(ggplot2)
library(EnhancedVolcano)
library(clusterProfiler)
library(org.Hs.eg.db)

# --- 1. Load count matrix and metadata ---
counts <- read.csv("raw_counts.csv", row.names = 1)
coldata <- read.csv("sample_info.csv", row.names = 1)

# Verify sample order matches
stopifnot(all(colnames(counts) == rownames(coldata)))

# --- 2. Create DESeq2 object ---
dds <- DESeqDataSetFromMatrix(
  countData = counts,
  colData = coldata,
  design = ~ condition  # Simple two-group comparison
)

# Pre-filtering: remove low-count genes
keep <- rowSums(counts(dds)) >= 10
dds <- dds[keep, ]

# --- 3. Run differential expression ---
dds <- DESeq(dds)
res <- results(dds, contrast = c("condition", "treatment", "control"),
               alpha = 0.05)

# Summary
summary(res)

# --- 4. Results with shrinkage (recommended for visualization) ---
res_shrunk <- lfcShrink(dds, coef = "condition_treatment_vs_control",
                         type = "apeglm")

# --- 5. Export significant genes ---
sig_genes <- subset(res, padj < 0.05 & abs(log2FoldChange) > 1)
write.csv(as.data.frame(sig_genes), "significant_genes.csv")
```

### Quality Control Metrics

| Metric | Expected Range | Concern If |
|--------|---------------|------------|
| Total reads | 20-50M per sample | < 10M |
| Mapping rate | > 80% | < 70% |
| rRNA contamination | < 5% | > 10% |
| GC content | ~42% (human) | Bimodal distribution |
| Duplication rate | < 30% (mRNA) | > 50% |
| Gene body coverage | Uniform 5' to 3' | Strong 3' bias |
| PCA | Samples cluster by condition | Outlier samples |

## Drug Discovery Computational Methods

### Virtual Screening Pipeline

```python
# Molecular docking workflow using RDKit and AutoDock Vina
from rdkit import Chem
from rdkit.Chem import AllChem, Descriptors, Lipinski
import subprocess

def prepare_ligands(smiles_list: list) -> list:
    """
    Prepare ligands for virtual screening.
    Apply Lipinski's Rule of Five and generate 3D conformers.
    """
    prepared = []
    for smiles in smiles_list:
        mol = Chem.MolFromSmiles(smiles)
        if mol is None:
            continue

        # Lipinski's Rule of Five filter
        mw = Descriptors.MolWt(mol)
        logp = Descriptors.MolLogP(mol)
        hbd = Descriptors.NumHDonors(mol)
        hba = Descriptors.NumHAcceptors(mol)

        if mw > 500 or logp > 5 or hbd > 5 or hba > 10:
            continue  # Fails Ro5

        # Generate 3D conformer
        mol_h = Chem.AddHs(mol)
        AllChem.EmbedMolecule(mol_h, AllChem.ETKDG())
        AllChem.MMFFOptimizeMolecule(mol_h)

        prepared.append({
            "smiles": smiles,
            "mol": mol_h,
            "mw": round(mw, 2),
            "logp": round(logp, 2),
            "hbd": hbd,
            "hba": hba,
        })

    return prepared

def compute_admet_properties(mol) -> dict:
    """Compute ADMET-relevant molecular descriptors."""
    return {
        "tpsa": round(Descriptors.TPSA(mol), 2),           # Topological polar surface area
        "rotatable_bonds": Descriptors.NumRotatableBonds(mol),
        "aromatic_rings": Descriptors.NumAromaticRings(mol),
        "fraction_csp3": round(Descriptors.FractionCSP3(mol), 3),  # Drug-likeness
        "qed": round(Descriptors.qed(mol), 3),              # Quantitative drug-likeness
    }
```

### Target-Disease Association Analysis

```python
def query_open_targets(target_id: str, disease_id: str) -> dict:
    """
    Query Open Targets Platform for target-disease association evidence.
    """
    import requests

    query = """
    query targetDiseaseAssociation($target: String!, $disease: String!) {
      disease(efoId: $disease) {
        name
        associatedTargets(Bs: [$target]) {
          rows {
            target { approvedSymbol }
            score
            datatypeScores {
              componentId: id
              score
            }
          }
        }
      }
    }
    """

    response = requests.post(
        "https://api.platform.opentargets.org/api/v4/graphql",
        json={"query": query, "variables": {"target": target_id, "disease": disease_id}},
    )

    return response.json()
```

## Clinical AI Applications

### Clinical NLP Patterns

```
Common clinical NLP tasks for research:

1. CLINICAL TEXT DE-IDENTIFICATION
   - Remove PHI (Protected Health Information)
   - Tools: Philter, NLM Scrubber, custom regex + NER
   - Validation: Must achieve >95% recall for PHI

2. CLINICAL CODING
   - Assign ICD-10, CPT, SNOMED-CT codes to clinical notes
   - Approaches: Rule-based, ML classification, LLM extraction
   - Evaluation: Precision/recall per code family

3. RELATION EXTRACTION
   - Drug-disease, drug-adverse event, gene-disease relationships
   - From clinical notes, discharge summaries, pathology reports
   - Output: Knowledge graphs for downstream analysis

4. TEMPORAL INFORMATION EXTRACTION
   - Disease onset, treatment timeline, outcome timing
   - Critical for longitudinal studies and survival analysis
   - Tools: SUTime, HeidelTime, custom models
```

## Best Practices

- **Validate AI predictions experimentally.** Computational predictions are hypotheses until confirmed in the lab.
- **Use standard file formats.** FASTQ for sequencing, SDF/MOL2 for molecules, FASTA for sequences, VCF for variants.
- **Follow FAIR data principles.** Findable, Accessible, Interoperable, Reusable data management.
- **De-identify clinical data before any AI processing.** HIPAA and GDPR compliance is non-negotiable.
- **Report computational methods in full detail.** Software versions, parameters, random seeds, and hardware specs.
- **Pre-register clinical AI studies.** Use SPIRIT-AI or CONSORT-AI reporting guidelines.

## References

- [DESeq2](https://bioconductor.org/packages/DESeq2/) -- Standard RNA-seq differential expression tool
- [scispaCy](https://allenai.github.io/scispacy/) -- Biomedical NLP models for spaCy
- [Open Targets Platform](https://platform.opentargets.org/) -- Target-disease association evidence
- [RDKit](https://www.rdkit.org/) -- Cheminformatics toolkit
- Love, M. I., Huber, W., & Anders, S. (2014). Moderated estimation of fold change and dispersion for RNA-seq data with DESeq2. Genome Biology, 15, 550.
