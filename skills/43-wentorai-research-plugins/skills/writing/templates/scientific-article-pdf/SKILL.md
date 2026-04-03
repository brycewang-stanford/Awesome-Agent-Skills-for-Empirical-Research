---
name: scientific-article-pdf
description: "Generate publication-ready scientific article PDFs from templates"
metadata:
  openclaw:
    emoji: "📑"
    category: "writing"
    subcategory: "templates"
    keywords: ["PDF generation", "article template", "publication-ready", "journal format", "LaTeX template", "manuscript"]
    source: "wentor-research-plugins"
---

# Scientific Article PDF

## Overview

Producing a publication-ready PDF that meets the exact formatting requirements of a target journal or conference is one of the final and most frustrating steps of the research publication process. Each venue has its own LaTeX class file, formatting rules, margin specifications, font requirements, and reference style. Getting these details wrong can lead to desk rejection before your paper even reaches a reviewer.

This skill provides a systematic approach to generating correctly formatted scientific article PDFs. It covers obtaining and using official LaTeX templates, configuring common elements (title blocks, author affiliations, abstracts, section numbering, bibliography), and troubleshooting formatting issues that arise during compilation. The goal is to produce a PDF that compiles cleanly and passes the publisher's automated format checks on the first try.

The skill focuses on LaTeX-based workflows, as LaTeX remains the standard for most scientific venues, particularly in STEM fields. It includes guidance for major publishers and conference families.

## Obtaining Official Templates

### Major Publisher Templates

Always start from the official template provided by your target venue. Using a custom or outdated template is a common cause of formatting problems.

**IEEE:**
```bash
# IEEE conference and journal templates
# Download from: https://www.ieee.org/conferences/publishing/templates.html
# Key files: IEEEtran.cls, IEEEtran.bst
wget https://www.ieee.org/content/dam/ieee-org/ieee/web/org/pubs/conference-latex-template_10-17-19.zip
```

**ACM (Association for Computing Machinery):**
```bash
# ACM Primary Article Template
# Download from: https://www.acm.org/publications/proceedings-template
# Key file: acmart.cls (supports all ACM formats)
# Use: \documentclass[sigconf]{acmart}  % for conference
#      \documentclass[acmlarge]{acmart}  % for journal
```

**Springer (LNCS - Lecture Notes in Computer Science):**
```bash
# Download from: https://www.springer.com/gp/computer-science/lncs/conference-proceedings-guidelines
# Key file: llncs.cls
# Typical usage: \documentclass[runningheads]{llncs}
```

**Elsevier:**
```bash
# Elsevier article template
# Download from: https://www.elsevier.com/authors/policies-and-guidelines/latex-instructions
# Key file: elsarticle.cls
# Usage: \documentclass[preprint,12pt]{elsarticle}  % for submission
#        \documentclass[final,3p,times]{elsarticle}  % for camera-ready
```

**NeurIPS / ICML / ICLR:**
```bash
# NeurIPS: https://neurips.cc/Conferences/2026/PaperInformation/StyleFiles
# ICML: https://icml.cc/Conferences/2026/StyleAuthorInstructions
# ICLR: Uses OpenReview; template available from submission portal
```

### Template Verification

After downloading a template, verify it compiles correctly before writing:

```bash
# Compile the sample document
pdflatex sample.tex
bibtex sample       # or biber sample
pdflatex sample.tex
pdflatex sample.tex  # Two passes to resolve references

# Check for warnings
grep -i "warning" sample.log | head -20
```

## Document Structure Template

Here is a general-purpose structure that works across most scientific article templates:

```latex
\documentclass[options]{template-class}

% ========== Packages ==========
\usepackage[utf8]{inputenc}     % UTF-8 encoding
\usepackage{amsmath,amssymb}    % Math symbols
\usepackage{graphicx}           % Figures
\usepackage{booktabs}           % Professional tables
\usepackage{hyperref}           % Clickable links
\usepackage{algorithm2e}        % Algorithm pseudocode
\usepackage{microtype}          % Typographic refinement

% ========== Metadata ==========
\title{Your Paper Title}
\author{%
  Author One\thanks{Corresponding author: author@example.edu} \\
  University of Example \\
  \and
  Author Two \\
  Institute of Research
}
\date{}

\begin{document}
\maketitle

\begin{abstract}
Your abstract text here (typically 150-300 words).
\end{abstract}

\section{Introduction}
\label{sec:intro}

\section{Related Work}
\label{sec:related}

\section{Method}
\label{sec:method}

\section{Experiments}
\label{sec:experiments}

\section{Conclusion}
\label{sec:conclusion}

\section*{Acknowledgments}
This work was supported by...

\bibliographystyle{template-bst}
\bibliography{references}

\appendix
\section{Additional Results}
\label{app:results}

\end{document}
```

## Common Formatting Tasks

### Professional Tables with booktabs

```latex
\begin{table}[t]
\centering
\caption{Comparison of methods on the benchmark dataset.}
\label{tab:results}
\begin{tabular}{lccc}
\toprule
Method & Accuracy & F1 Score & Params (M) \\
\midrule
Baseline A & 82.3 & 79.1 & 110 \\
Baseline B & 84.7 & 81.4 & 145 \\
\textbf{Ours} & \textbf{87.6} & \textbf{84.9} & 95 \\
\bottomrule
\end{tabular}
\end{table}
```

### Figure Placement

```latex
\begin{figure}[t]  % [t]=top, [b]=bottom, [h]=here, [p]=page of floats
\centering
\includegraphics[width=0.9\columnwidth]{figures/architecture.pdf}
\caption{Overview of the proposed architecture. The encoder (left)
processes input features while the decoder (right) generates
predictions autoregressively.}
\label{fig:architecture}
\end{figure}
```

### Algorithm Pseudocode

```latex
\begin{algorithm}[t]
\caption{Training Procedure}
\label{alg:training}
\KwIn{Dataset $\mathcal{D}$, learning rate $\eta$, epochs $T$}
\KwOut{Trained model parameters $\theta^*$}
Initialize $\theta$ randomly\;
\For{$t = 1$ \KwTo $T$}{
    \ForEach{batch $(x, y) \in \mathcal{D}$}{
        $\hat{y} \gets f_\theta(x)$\;
        $\mathcal{L} \gets \text{Loss}(\hat{y}, y)$\;
        $\theta \gets \theta - \eta \nabla_\theta \mathcal{L}$\;
    }
}
\Return $\theta$\;
\end{algorithm}
```

## Build Pipeline and Automation

### Makefile for Clean Builds

```makefile
MAIN = paper
LATEX = pdflatex
BIB = bibtex

all: $(MAIN).pdf

$(MAIN).pdf: $(MAIN).tex references.bib
	$(LATEX) $(MAIN)
	$(BIB) $(MAIN)
	$(LATEX) $(MAIN)
	$(LATEX) $(MAIN)

clean:
	rm -f *.aux *.bbl *.blg *.log *.out *.toc *.fls *.fdb_latexmk

check:
	@echo "=== Overfull boxes ==="
	@grep -c "Overfull" $(MAIN).log || echo "None"
	@echo "=== Undefined references ==="
	@grep -c "undefined" $(MAIN).log || echo "None"
	@echo "=== Missing citations ==="
	@grep -c "Citation.*undefined" $(MAIN).log || echo "None"

.PHONY: all clean check
```

### Using latexmk for Automatic Rebuilds

```bash
# latexmk automatically determines how many passes are needed
latexmk -pdf paper.tex

# Continuous mode: recompiles on file changes
latexmk -pdf -pvc paper.tex

# Clean up auxiliary files
latexmk -c paper.tex
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "Overfull hbox" warnings | Rephrase text, use `\sloppy` locally, or adjust figure widths |
| Missing references | Run BibTeX/Biber and re-run LaTeX twice |
| Figures not found | Use paths relative to the main .tex file; check file extensions |
| Font not found | Install the required font package: `tlmgr install <font>` |
| Page limit exceeded | Move content to appendix; tighten prose; reduce figure sizes |
| "Too many unprocessed floats" | Add `\clearpage` or use the `placeins` package with `\FloatBarrier` |

## References

- IEEE LaTeX templates: https://www.ieee.org/conferences/publishing/templates.html
- ACM acmart class: https://www.acm.org/publications/proceedings-template
- Springer LNCS: https://www.springer.com/gp/computer-science/lncs
- Elsevier elsarticle: https://www.elsevier.com/authors/policies-and-guidelines/latex-instructions
- LaTeX Wikibook: https://en.wikibooks.org/wiki/LaTeX
