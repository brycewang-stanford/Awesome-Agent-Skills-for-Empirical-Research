---
name: academic-writing-latex
description: "LaTeX-based academic writing assistant for thesis and paper templates"
metadata:
  openclaw:
    emoji: "📐"
    category: "writing"
    subcategory: "latex"
    keywords: ["latex", "thesis writing", "paper template", "academic writing", "document structure", "overleaf"]
    source: "wentor-research-plugins"
---

# Academic Writing with LaTeX Templates

## Overview

This guide covers the workflow of writing academic papers and theses using LaTeX templates. It addresses template selection, document structure, common environments, bibliography management, and compilation. Designed for researchers who need to produce professional documents conforming to specific institutional or publisher formatting requirements.

## Template Selection

### Conference and Journal Templates

| Publisher | Template Source | Document Class |
|-----------|----------------|---------------|
| IEEE | [ieee.org/conferences](https://www.ieee.org/conferences/publishing/templates.html) | `IEEEtran` |
| ACM | [acm.org/publications](https://www.acm.org/publications/proceedings-template) | `acmart` |
| Springer | LNCS template package | `llncs` |
| Elsevier | [elsarticle](https://www.elsevier.com/researcher/author/policies-and-guidelines/latex-instructions) | `elsarticle` |
| Nature | Author submission guidelines | `nature` |
| APS/AIP | [REVTeX](https://journals.aps.org/revtex) | `revtex4-2` |

### Thesis Templates

```latex
% Chinese university thesis examples
\documentclass{thuthesis}    % Tsinghua University
\documentclass{sjtuthesis}   % Shanghai Jiao Tong University
\documentclass{ustcthesis}   % USTC
\documentclass{xjtuthesis}   % Xi'an Jiao Tong University

% International thesis
\documentclass{Dissertate}   % Harvard-style
\documentclass[phd]{novathesis}  % Universidade Nova de Lisboa
```

## Document Structure

### Basic Paper Structure

```latex
\documentclass[conference]{IEEEtran}

% Preamble — packages
\usepackage{amsmath,amssymb}
\usepackage{graphicx}
\usepackage{booktabs}
\usepackage{hyperref}
\usepackage[utf8]{inputenc}

\begin{document}

\title{Your Paper Title}
\author{
  \IEEEauthorblockN{First Author}
  \IEEEauthorblockA{Affiliation\\Email: first@example.com}
  \and
  \IEEEauthorblockN{Second Author}
  \IEEEauthorblockA{Affiliation\\Email: second@example.com}
}
\maketitle

\begin{abstract}
Your abstract here (150-250 words).
\end{abstract}

\begin{IEEEkeywords}
keyword1, keyword2, keyword3
\end{IEEEkeywords}

\section{Introduction}
\label{sec:intro}
Your introduction text...

\section{Related Work}
\section{Methodology}
\section{Experiments}
\section{Results}
\section{Conclusion}

\bibliographystyle{IEEEtran}
\bibliography{references}

\end{document}
```

### Thesis Structure

```latex
\documentclass[12pt,a4paper]{report}

\begin{document}

\frontmatter
\include{chapters/titlepage}
\include{chapters/abstract}
\include{chapters/acknowledgments}
\tableofcontents
\listoffigures
\listoftables

\mainmatter
\include{chapters/introduction}
\include{chapters/literature-review}
\include{chapters/methodology}
\include{chapters/results}
\include{chapters/discussion}
\include{chapters/conclusion}

\appendix
\include{chapters/appendix-a}

\backmatter
\bibliographystyle{apalike}
\bibliography{references}

\end{document}
```

## Essential Environments

### Figures

```latex
\begin{figure}[htbp]
  \centering
  \includegraphics[width=0.8\columnwidth]{figures/architecture.pdf}
  \caption{System architecture overview. The input module processes
           raw data before passing to the transformer encoder.}
  \label{fig:architecture}
\end{figure}

% Two subfigures side by side
\usepackage{subcaption}
\begin{figure}[htbp]
  \centering
  \begin{subfigure}[b]{0.48\columnwidth}
    \includegraphics[width=\textwidth]{fig_a.pdf}
    \caption{Training loss}
    \label{fig:loss}
  \end{subfigure}
  \hfill
  \begin{subfigure}[b]{0.48\columnwidth}
    \includegraphics[width=\textwidth]{fig_b.pdf}
    \caption{Validation accuracy}
    \label{fig:acc}
  \end{subfigure}
  \caption{Training dynamics over 100 epochs.}
  \label{fig:training}
\end{figure}
```

### Tables

```latex
\begin{table}[htbp]
  \centering
  \caption{Comparison of methods on benchmark dataset.}
  \label{tab:results}
  \begin{tabular}{lccc}
    \toprule
    Method & Precision & Recall & F1 \\
    \midrule
    Baseline    & 0.72 & 0.68 & 0.70 \\
    Method A    & 0.81 & 0.76 & 0.78 \\
    \textbf{Ours} & \textbf{0.89} & \textbf{0.85} & \textbf{0.87} \\
    \bottomrule
  \end{tabular}
\end{table}
```

### Mathematics

```latex
% Inline math
The loss function $\mathcal{L}(\theta) = -\sum_{i=1}^{N} y_i \log \hat{y}_i$
minimizes cross-entropy.

% Display equation (numbered)
\begin{equation}
  \text{Attention}(Q, K, V) = \text{softmax}\left(\frac{QK^T}{\sqrt{d_k}}\right)V
  \label{eq:attention}
\end{equation}

% Aligned equations
\begin{align}
  \nabla_\theta J(\theta) &= \mathbb{E}_{\tau \sim \pi_\theta}
    \left[\sum_{t=0}^{T} \nabla_\theta \log \pi_\theta(a_t|s_t) A_t\right]
    \label{eq:policy_grad} \\
  A_t &= Q(s_t, a_t) - V(s_t) \label{eq:advantage}
\end{align}

% Refer to equations
As shown in Equation~\eqref{eq:attention}, the attention mechanism...
```

### Algorithms

```latex
\usepackage{algorithm}
\usepackage{algorithmic}

\begin{algorithm}[htbp]
  \caption{Training procedure}
  \label{alg:training}
  \begin{algorithmic}[1]
    \REQUIRE Dataset $\mathcal{D}$, learning rate $\eta$, epochs $E$
    \ENSURE Trained model parameters $\theta^*$
    \STATE Initialize $\theta$ randomly
    \FOR{$e = 1$ to $E$}
      \FOR{each batch $B \in \mathcal{D}$}
        \STATE Compute loss $\mathcal{L}(B; \theta)$
        \STATE $\theta \leftarrow \theta - \eta \nabla_\theta \mathcal{L}$
      \ENDFOR
    \ENDFOR
    \RETURN $\theta$
  \end{algorithmic}
\end{algorithm}
```

## Bibliography Management

### BibTeX Workflow

```bash
# Compilation sequence (4 steps)
pdflatex paper.tex     # 1. First pass (generates .aux)
bibtex paper           # 2. Process bibliography
pdflatex paper.tex     # 3. Second pass (resolves refs)
pdflatex paper.tex     # 4. Final pass (fixes page numbers)

# Or use latexmk for automatic compilation
latexmk -pdf paper.tex
```

### BibTeX Entry Types

```bibtex
@article{vaswani2017attention,
  title={Attention is all you need},
  author={Vaswani, Ashish and Shazeer, Noam and Parmar, Niki and ...},
  journal={Advances in neural information processing systems},
  volume={30},
  year={2017}
}

@inproceedings{devlin2019bert,
  title={BERT: Pre-training of deep bidirectional transformers},
  author={Devlin, Jacob and Chang, Ming-Wei and Lee, Kenton and ...},
  booktitle={Proceedings of NAACL-HLT 2019},
  pages={4171--4186},
  year={2019}
}
```

## Compilation

```bash
# XeLaTeX (for Unicode/CJK support)
xelatex paper.tex && bibtex paper && xelatex paper.tex && xelatex paper.tex

# LuaLaTeX (alternative Unicode engine)
lualatex paper.tex

# Automated with latexmk
latexmk -xelatex paper.tex    # XeLaTeX
latexmk -pdf paper.tex        # pdfLaTeX
latexmk -c paper.tex          # Clean auxiliary files
```

## References

- [Overleaf Documentation](https://www.overleaf.com/learn)
- [LaTeX Wikibook](https://en.wikibooks.org/wiki/LaTeX)
- [CTAN Package Repository](https://ctan.org/)
- [BibTeX Entry Types](https://www.bibtex.com/e/entry-types/)
