---
name: genomics-analysis-guide
description: "Workflows for RNA-seq, GWAS, and variant calling in genomic research"
metadata:
  openclaw:
    emoji: "🔬"
    category: "domains"
    subcategory: "biomedical"
    keywords: ["genomics", "RNA-seq", "GWAS", "molecular biology", "genetics", "bioinformatics"]
    source: "wentor-research-plugins"
---

# Genomics Analysis Guide

## Overview

Genomic data analysis is the computational backbone of modern molecular biology. From identifying disease-associated variants through Genome-Wide Association Studies (GWAS) to quantifying gene expression with RNA-seq, these workflows transform raw sequencing data into biological insights that drive discoveries in medicine, agriculture, and evolutionary biology.

This guide covers the three most common genomic analysis workflows: RNA-seq differential expression analysis, GWAS for variant-trait associations, and variant calling from whole-genome sequencing (WGS) data. Each workflow is described with tool recommendations, command-line examples, and downstream analysis steps in R and Python.

The emphasis is on reproducibility and best practices. Genomic analyses involve many sequential steps, and errors in early stages propagate through the entire pipeline. Following standardized workflows -- like those from the Broad Institute, ENCODE, and Bioconductor -- reduces the risk of methodological errors.

## RNA-seq Analysis Pipeline

### Workflow Overview

```
Raw FASTQ files
    |
    v
[Quality Control] --> FastQC, MultiQC
    |
    v
[Trimming] --> Trimmomatic, fastp
    |
    v
[Alignment] --> STAR, HISAT2
    |
    v
[Quantification] --> featureCounts, Salmon
    |
    v
[Differential Expression] --> DESeq2, edgeR
    |
    v
[Pathway Analysis] --> clusterProfiler, GSEA
```

### Step 1: Quality Control

```bash
# Run FastQC on all FASTQ files
fastqc -t 8 -o qc_results/ raw_data/*.fastq.gz

# Aggregate QC reports
multiqc qc_results/ -o multiqc_report/
```

### Step 2: Read Trimming

```bash
# fastp for quality trimming and adapter removal
fastp \
  --in1 sample_R1.fastq.gz \
  --in2 sample_R2.fastq.gz \
  --out1 trimmed_R1.fastq.gz \
  --out2 trimmed_R2.fastq.gz \
  --detect_adapter_for_pe \
  --thread 8 \
  --html fastp_report.html
```

### Step 3: Alignment with STAR

```bash
# Build genome index (one time)
STAR --runMode genomeGenerate \
  --genomeDir star_index/ \
  --genomeFastaFiles genome.fa \
  --sjdbGTFfile annotations.gtf \
  --runThreadN 16

# Align reads
STAR --runMode alignReads \
  --genomeDir star_index/ \
  --readFilesIn trimmed_R1.fastq.gz trimmed_R2.fastq.gz \
  --readFilesCommand zcat \
  --outSAMtype BAM SortedByCoordinate \
  --quantMode GeneCounts \
  --outFileNamePrefix sample_ \
  --runThreadN 16
```

### Step 4: Differential Expression with DESeq2

```r
library(DESeq2)

# Load count matrix and sample info
counts <- read.csv("gene_counts.csv", row.names = 1)
coldata <- read.csv("sample_info.csv", row.names = 1)

# Create DESeq2 object
dds <- DESeqDataSetFromMatrix(
  countData = counts,
  colData = coldata,
  design = ~ condition
)

# Filter low-count genes
keep <- rowSums(counts(dds) >= 10) >= 3
dds <- dds[keep, ]

# Run differential expression
dds <- DESeq(dds)
res <- results(dds, contrast = c("condition", "treated", "control"),
               alpha = 0.05)

# Summary
summary(res)

# Export significant genes
sig_genes <- subset(as.data.frame(res), padj < 0.05 & abs(log2FoldChange) > 1)
write.csv(sig_genes, "significant_genes.csv")
```

## GWAS Pipeline

### Workflow Overview

```
Genotype Data (VCF/PLINK)
    |
    v
[Quality Control] --> Sample/variant filtering
    |
    v
[Population Stratification] --> PCA
    |
    v
[Association Testing] --> PLINK2, REGENIE
    |
    v
[Multiple Testing Correction] --> Bonferroni, FDR
    |
    v
[Visualization] --> Manhattan plot, QQ plot
```

### QC with PLINK2

```bash
# Sample QC
plink2 \
  --bfile dataset \
  --mind 0.05 \          # Remove samples with >5% missing
  --geno 0.02 \          # Remove variants with >2% missing
  --maf 0.01 \           # Remove rare variants (MAF < 1%)
  --hwe 1e-6 \           # HWE filter
  --make-bed \
  --out dataset_qc

# LD pruning for PCA
plink2 \
  --bfile dataset_qc \
  --indep-pairwise 50 5 0.2 \
  --out pruned

# PCA for population stratification
plink2 \
  --bfile dataset_qc \
  --extract pruned.prune.in \
  --pca 10 \
  --out pca_results
```

### Association Testing

```bash
# Linear/logistic regression with covariates
plink2 \
  --bfile dataset_qc \
  --glm \
  --pheno phenotypes.txt \
  --covar pca_results.eigenvec \
  --covar-col-nums 3-12 \
  --out gwas_results
```

### Manhattan Plot in Python

```python
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

def manhattan_plot(gwas_file, output='manhattan.pdf'):
    df = pd.read_csv(gwas_file, sep='\t')
    df['-log10p'] = -np.log10(df['P'])

    # Assign cumulative positions
    df = df.sort_values(['CHR', 'BP'])
    df['pos_cum'] = 0
    offset = 0
    for chrom in df['CHR'].unique():
        mask = df['CHR'] == chrom
        df.loc[mask, 'pos_cum'] = df.loc[mask, 'BP'] + offset
        offset = df.loc[mask, 'pos_cum'].max()

    fig, ax = plt.subplots(figsize=(16, 5))
    colors = ['#3B82F6', '#94A3B8']
    for i, chrom in enumerate(df['CHR'].unique()):
        subset = df[df['CHR'] == chrom]
        ax.scatter(subset['pos_cum'], subset['-log10p'],
                   s=2, color=colors[i % 2], alpha=0.7)

    ax.axhline(-np.log10(5e-8), color='red', linestyle='--', linewidth=0.8)
    ax.set_xlabel('Chromosome')
    ax.set_ylabel('-log10(p-value)')
    fig.savefig(output, dpi=300, bbox_inches='tight')
```

## Variant Calling Pipeline

### GATK Best Practices

```bash
# Mark duplicates
gatk MarkDuplicates \
  -I aligned.bam \
  -O dedup.bam \
  -M metrics.txt

# Base quality score recalibration
gatk BaseRecalibrator \
  -I dedup.bam \
  -R reference.fa \
  --known-sites dbsnp.vcf \
  -O recal_table.txt

gatk ApplyBQSR \
  -I dedup.bam \
  -R reference.fa \
  --bqsr-recal-file recal_table.txt \
  -O recal.bam

# Call variants
gatk HaplotypeCaller \
  -I recal.bam \
  -R reference.fa \
  -O variants.g.vcf \
  -ERC GVCF
```

## Best Practices

- **Use containerized workflows.** Nextflow + Docker/Singularity ensures reproducibility across environments.
- **Document every parameter.** Small changes in alignment settings can significantly affect downstream results.
- **Apply appropriate multiple testing corrections.** Genome-wide significance is p < 5e-8 for GWAS.
- **Validate findings in independent cohorts.** Replication is essential before biological interpretation.
- **Archive raw data and analysis scripts.** Deposit in GEO (expression) or dbGaP (genotypes) for reproducibility.
- **Use established pipelines (nf-core).** Community-maintained Nextflow pipelines encode best practices.

## References

- [DESeq2 Vignette](https://bioconductor.org/packages/release/bioc/vignettes/DESeq2/inst/doc/DESeq2.html) -- Differential expression analysis
- [GATK Best Practices](https://gatk.broadinstitute.org/hc/en-us/sections/360007226651-Best-Practices-Workflows) -- Variant calling
- [PLINK2 Documentation](https://www.cog-genomics.org/plink/2.0/) -- Genetic association analysis
- [nf-core Pipelines](https://nf-co.re/) -- Community Nextflow workflows
- [RNA-seq Analysis Tutorial](https://rnabio.org/) -- Griffith Lab comprehensive tutorial
