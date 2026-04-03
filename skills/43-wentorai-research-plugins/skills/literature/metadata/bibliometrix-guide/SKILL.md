---
name: bibliometrix-guide
description: "Perform science mapping and bibliometric analysis with R bibliometrix"
metadata:
  openclaw:
    emoji: "📉"
    category: "literature"
    subcategory: "metadata"
    keywords: ["bibliometrix", "bibliometrics", "science mapping", "R", "citation analysis", "research trends"]
    source: "https://github.com/massimoaria/bibliometrix"
---

# Bibliometrix Guide

## Overview

Bibliometrix is an R package for comprehensive science mapping and bibliometric analysis. It imports data from Scopus, Web of Science, PubMed, and other databases, then performs co-citation analysis, keyword co-occurrence mapping, collaboration networks, thematic evolution tracking, and more. Includes Biblioshiny — a Shiny-based web interface for no-code analysis.

## Installation

```r
install.packages("bibliometrix")

# Or development version
devtools::install_github("massimoaria/bibliometrix")
```

## Quick Start

### Import Data

```r
library(bibliometrix)

# From Scopus CSV export
M <- convert2df("scopus_export.csv", dbsource = "scopus", format = "csv")

# From Web of Science
M <- convert2df("wos_export.txt", dbsource = "wos", format = "plaintext")

# From PubMed
M <- convert2df("pubmed_export.txt", dbsource = "pubmed", format = "pubmed")

# From multiple files
file_list <- c("data1.csv", "data2.csv")
M <- convert2df(file_list, dbsource = "scopus", format = "csv")
```

### Descriptive Analysis

```r
# Basic bibliometric summary
results <- biblioAnalysis(M)
summary(results, k = 10)  # Top 10 in each category

# Key metrics produced:
# - Publication trends over time
# - Most productive authors
# - Most cited papers
# - Top journals/sources
# - Country/affiliation rankings
# - Keyword frequency
```

### Citation Analysis

```r
# Most cited documents
CR <- citations(M, field = "article", sep = ";")
head(CR$Cited, 20)

# Most cited first authors
CR_auth <- citations(M, field = "author", sep = ";")

# Local citations (within the dataset)
LC <- localCitations(M)
head(LC$Papers, 10)
```

### Network Analysis

```r
# Co-citation network
NetMatrix <- biblioNetwork(M, analysis = "co-citation",
                           network = "references", sep = ";")
net <- networkPlot(NetMatrix, n = 30, type = "fruchterman",
                   Title = "Co-citation Network")

# Author collaboration network
NetMatrix <- biblioNetwork(M, analysis = "collaboration",
                           network = "authors", sep = ";")
net <- networkPlot(NetMatrix, n = 50, type = "kamada",
                   Title = "Collaboration Network")

# Keyword co-occurrence
NetMatrix <- biblioNetwork(M, analysis = "co-occurrences",
                           network = "keywords", sep = ";")
net <- networkPlot(NetMatrix, n = 40, type = "fruchterman",
                   Title = "Keyword Co-occurrence")
```

### Thematic Analysis

```r
# Thematic map (strategic diagram)
Map <- thematicMap(M, field = "DE", n = 250, minfreq = 5)
plot(Map$map)

# Quadrants:
# Motor themes (high centrality, high density)
# Basic themes (high centrality, low density)
# Niche themes (low centrality, high density)
# Emerging/declining themes (low centrality, low density)

# Thematic evolution over time periods
nexus <- thematicEvolution(M,
    field = "DE",
    years = c(2015, 2019, 2023),
    n = 100, minFreq = 3)
plotThematicEvolution(nexus$Nodes, nexus$Edges)
```

### Biblioshiny (Web Interface)

```r
# Launch interactive web dashboard
biblioshiny()

# Opens browser with GUI for:
# - Data import from multiple sources
# - Descriptive analysis
# - Network visualization
# - Thematic mapping
# - All plots exportable
```

## Supported Data Sources

| Source | Format | Import function |
|--------|--------|----------------|
| Scopus | CSV/BibTeX | `convert2df(..., dbsource="scopus")` |
| Web of Science | Plain text/BibTeX | `convert2df(..., dbsource="wos")` |
| PubMed | PubMed format | `convert2df(..., dbsource="pubmed")` |
| Dimensions | CSV | `convert2df(..., dbsource="dimensions")` |
| Cochrane | Plain text | `convert2df(..., dbsource="cochrane")` |
| OpenAlex | JSON | Via API integration |

## Key Analysis Types

| Analysis | Function | Output |
|----------|----------|--------|
| Descriptive | `biblioAnalysis()` | Summary statistics |
| Co-citation | `biblioNetwork(analysis="co-citation")` | Citation clusters |
| Collaboration | `biblioNetwork(analysis="collaboration")` | Author networks |
| Co-occurrence | `biblioNetwork(analysis="co-occurrences")` | Keyword maps |
| Thematic map | `thematicMap()` | Strategic quadrant diagram |
| Trend analysis | `fieldByYear()` | Topic evolution |
| Country collab | `metaTagExtraction() + biblioNetwork()` | Geo collaboration |

## References

- [Bibliometrix](https://www.bibliometrix.org/)
- [Bibliometrix GitHub](https://github.com/massimoaria/bibliometrix)
- Aria, M. & Cuccurullo, C. (2017). "bibliometrix: An R-tool for comprehensive science mapping analysis." *Journal of Informetrics* 11(4): 959-975.
