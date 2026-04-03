---
name: arxiv-preprint-template
description: "LaTeX template for arXiv preprints in NIPS/NeurIPS style format"
metadata:
  openclaw:
    emoji: "📝"
    category: "writing"
    subcategory: "templates"
    keywords: ["arXiv", "preprint", "NIPS style", "LaTeX template", "NeurIPS", "manuscript"]
    source: "https://github.com/kourgeorge/arxiv-style"
---

# arXiv Preprint Template

## Overview

A clean, minimal LaTeX template for arXiv preprints based on the NIPS/NeurIPS conference style. Provides professional formatting for CS/ML papers without the overhead of full conference submission templates. Includes proper bibliography, math support, and single/double column layouts.

## Quick Start

```bash
git clone https://github.com/kourgeorge/arxiv-style.git
cd arxiv-style
# Edit main.tex, compile:
pdflatex main && bibtex main && pdflatex main && pdflatex main
```

## Template Structure

```latex
\documentclass{article}
\usepackage{arxiv}

\title{Your Paper Title: A Descriptive Subtitle}

\author{
  First Author\thanks{Equal contribution.} \\
  Department of Computer Science\\
  University Name\\
  \texttt{first@university.edu} \\
  \And
  Second Author \\
  Research Lab\\
  Institution Name\\
  \texttt{second@institution.org}
}

\begin{document}
\maketitle

\begin{abstract}
  Your abstract here. Keep it under 200 words for arXiv.
  State the problem, approach, key results, and implications.
\end{abstract}

\keywords{keyword1, keyword2, keyword3}

\section{Introduction}
% Background, motivation, contribution summary

\section{Related Work}
% Position relative to existing literature

\section{Method}
% Technical approach, algorithms, models

\section{Experiments}
% Setup, datasets, baselines, results

\section{Conclusion}
% Summary, limitations, future work

\bibliographystyle{unsrtnat}
\bibliography{references}

\appendix
\section{Supplementary Material}
% Proofs, additional results, hyperparameters

\end{document}
```

## Key Features

### Math Support

```latex
% Theorem environments
\newtheorem{theorem}{Theorem}
\newtheorem{lemma}[theorem]{Lemma}
\newtheorem{proposition}[theorem]{Proposition}

\begin{theorem}
For any $\epsilon > 0$, there exists $\delta > 0$ such that...
\end{theorem}

% Algorithm
\usepackage{algorithm}
\usepackage{algorithmic}

\begin{algorithm}
\caption{Training procedure}
\begin{algorithmic}[1]
\REQUIRE Dataset $\mathcal{D}$, learning rate $\eta$
\FOR{$t = 1$ to $T$}
  \STATE Sample batch $B \sim \mathcal{D}$
  \STATE $\theta \leftarrow \theta - \eta \nabla_\theta \mathcal{L}(B)$
\ENDFOR
\RETURN $\theta$
\end{algorithmic}
\end{algorithm}
```

### Tables and Figures

```latex
% Results table
\begin{table}[t]
\centering
\caption{Comparison with baselines on benchmark datasets.}
\begin{tabular}{lccc}
\toprule
Method & Accuracy & F1 & Time (s) \\
\midrule
Baseline & 85.2 & 83.1 & 12.4 \\
Ours & \textbf{91.7} & \textbf{90.3} & 8.2 \\
\bottomrule
\end{tabular}
\end{table}

% Figure
\begin{figure}[t]
\centering
\includegraphics[width=0.8\columnwidth]{figures/architecture.pdf}
\caption{Model architecture overview.}
\end{figure}
```

### arXiv Submission Tips

```bash
# Prepare submission package
# 1. Include all .tex, .bib, .bbl files
# 2. Include all figures (PDF preferred over PNG)
# 3. Include arxiv.sty
# 4. Do NOT include .aux, .log, .out files

# Create submission archive
tar -czf submission.tar.gz \
  main.tex arxiv.sty references.bbl figures/
```

## Customization

```latex
% Single column (default)
\documentclass{article}

% Two column layout
\documentclass[twocolumn]{article}

% Line numbers (for review)
\usepackage{lineno}
\linenumbers

% Hyperlinks (recommended)
\usepackage{hyperref}
\hypersetup{colorlinks=true, linkcolor=blue, citecolor=blue}
```

## Related Templates

| Template | Best for |
|----------|----------|
| arxiv-style | General ML/CS preprints |
| NeurIPS template | NeurIPS submissions |
| ICML template | ICML submissions |
| ElegantPaper | Working papers/tech reports |

## References

- [arxiv-style GitHub](https://github.com/kourgeorge/arxiv-style)
- [arXiv Submission Guide](https://info.arxiv.org/help/submit/index.html)
- [arXiv LaTeX Cleaner](https://github.com/google-research/arxiv-latex-cleaner)
