---
name: clawbio-guide
description: "OpenClaw bioinformatics skill library for genomics pipelines"
metadata:
  openclaw:
    emoji: "🧪"
    category: "domains"
    subcategory: "biomedical"
    keywords: ["ClawBio", "bioinformatics", "OpenClaw", "genomics", "pipeline", "biological analysis"]
    source: "https://github.com/ClawBio/ClawBio"
---

# ClawBio Guide

## Overview

ClawBio is a bioinformatics skill library for OpenClaw that provides pre-built skills for common genomics and biological analysis tasks — sequence alignment, variant calling, differential expression, pathway analysis, and more. Each skill encapsulates best-practice bioinformatics pipelines as conversational agent capabilities, making complex analyses accessible through natural language.

## Installation

```bash
# Install as OpenClaw plugin
openclaw plugins install @clawbio/clawbio

# Or add to your OpenClaw configuration
# In openclaw.config.json:
{
  "plugins": ["@clawbio/clawbio"]
}
```

## Available Skills

| Skill | Pipeline | Description |
|-------|----------|-------------|
| **sequence-align** | BWA/Bowtie2 | Align reads to reference genome |
| **variant-call** | GATK/BCFtools | Call SNPs and indels |
| **rna-seq** | STAR + DESeq2 | Differential expression analysis |
| **chip-seq** | MACS2 + DiffBind | Peak calling and differential binding |
| **metagenomics** | Kraken2 + Bracken | Taxonomic classification |
| **phylogenetics** | IQ-TREE + RAxML | Phylogenetic tree construction |
| **protein-structure** | AlphaFold/ESMFold | Structure prediction |
| **pathway-analysis** | GSEA + enrichR | Gene set enrichment |

## Usage Examples

### RNA-Seq Analysis

```python
# Through OpenClaw conversational interface:
# "Analyze differential expression between treated and control
#  samples in the data/rnaseq/ directory"

# ClawBio executes:
# 1. Quality control (FastQC)
# 2. Trimming (Trimmomatic)
# 3. Alignment (STAR)
# 4. Quantification (featureCounts)
# 5. Differential expression (DESeq2)
# 6. Visualization (volcano plot, MA plot, heatmap)
# 7. Pathway enrichment (GSEA)
```

### Variant Calling

```python
# "Call variants from the whole-genome sequencing data
#  in samples/ against hg38 reference"

# Pipeline:
# 1. Alignment: BWA-MEM2 → sorted BAM
# 2. Preprocessing: MarkDuplicates, BQSR
# 3. Variant calling: GATK HaplotypeCaller
# 4. Filtering: VQSR or hard filters
# 5. Annotation: VEP or SnpEff
# 6. Report: variant statistics, quality metrics
```

### Metagenomics

```python
# "Classify the microbial communities in my 16S/shotgun
#  sequencing data and generate taxonomic plots"

# Pipeline:
# 1. Quality filtering (fastp)
# 2. Host decontamination (Bowtie2 vs human)
# 3. Classification (Kraken2 + Bracken)
# 4. Diversity analysis (alpha + beta diversity)
# 5. Differential abundance (LEfSe/ANCOM)
# 6. Visualization (stacked bar, PCoA, heatmap)
```

## Configuration

```json
{
  "clawbio": {
    "reference_genomes": {
      "hg38": "/data/references/hg38/",
      "mm39": "/data/references/mm39/",
      "custom": "/data/references/custom/"
    },
    "tools": {
      "aligner": "bwa-mem2",
      "variant_caller": "gatk",
      "quantifier": "featurecounts",
      "de_method": "deseq2"
    },
    "resources": {
      "threads": 8,
      "memory_gb": 32,
      "gpu": false
    },
    "output": {
      "format": ["html_report", "csv", "plots"],
      "figures_dpi": 300
    }
  }
}
```

## Skill Development

```python
# Create custom bioinformatics skills
# SKILL.md template for new analysis types

"""
---
name: my-custom-analysis
description: "Custom bioinformatics analysis skill"
metadata:
  openclaw:
    category: "domains"
    subcategory: "biomedical"
---

# My Custom Analysis

## When to use
Describe when this analysis is appropriate.

## Pipeline Steps
1. Input validation
2. Processing step 1
3. Processing step 2
4. Output generation

## Example Usage
Show conversational examples.
"""
```

## Use Cases

1. **Genomics pipelines**: Standard NGS analysis workflows
2. **Lab integration**: Natural language interface for bioinformatics
3. **Teaching**: Demonstrate analysis pipelines interactively
4. **Rapid prototyping**: Quick exploratory biological analyses
5. **Reproducibility**: Standardized, documented pipelines

## References

- [ClawBio GitHub](https://github.com/ClawBio/ClawBio)
- [Bioconductor](https://www.bioconductor.org/)
- [nf-core Pipelines](https://nf-co.re/)
