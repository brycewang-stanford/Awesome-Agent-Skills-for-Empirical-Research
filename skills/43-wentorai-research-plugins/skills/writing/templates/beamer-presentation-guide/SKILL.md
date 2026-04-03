---
name: beamer-presentation-guide
description: "Guide to creating academic presentations with LaTeX Beamer"
metadata:
  openclaw:
    emoji: "📊"
    category: "writing"
    subcategory: "templates"
    keywords: ["Beamer presentation", "LaTeX slides", "conference paper template"]
    source: "wentor-research-plugins"
---

# Beamer Presentation Guide

Create professional academic presentations using LaTeX Beamer with themes, animations, and best practices for conference talks and research seminars.

## Basic Beamer Document

```latex
\documentclass[aspectratio=169]{beamer}  % 16:9 aspect ratio
% Other options: aspectratio=43 (4:3, default), aspectratio=1610

\usetheme{Madrid}           % Visual theme
\usecolortheme{default}     % Color scheme
\usefonttheme{professionalfonts}

\usepackage{amsmath,amssymb}
\usepackage{graphicx}
\usepackage{booktabs}       % Better tables
\usepackage{hyperref}

\title[Short Title]{Full Title of Your Presentation}
\subtitle{Conference Name 2025}
\author[A. Smith]{Alice Smith\inst{1} \and Bob Jones\inst{2}}
\institute[MIT, Stanford]{
  \inst{1}MIT \and \inst{2}Stanford University
}
\date{March 15, 2025}

\begin{document}

\begin{frame}
  \titlepage
\end{frame}

\begin{frame}{Outline}
  \tableofcontents
\end{frame}

\section{Introduction}
\begin{frame}{Motivation}
  \begin{itemize}
    \item Research question and why it matters
    \item Key challenge in the field
    \item Our contribution in one sentence
  \end{itemize}
\end{frame}

\end{document}
```

## Popular Beamer Themes

| Theme | Style | Best For |
|-------|-------|----------|
| `Madrid` | Professional, structured headers | Conference talks |
| `Metropolis` (mtheme) | Modern, minimal, flat design | CS/tech conferences |
| `CambridgeUS` | Traditional academic | University seminars |
| `Singapore` | Clean navigation sidebar | Long presentations |
| `Bergen` | Compact, information-dense | Technical deep dives |
| `default` | Plain, no decoration | Maximum content area |

### Installing Metropolis (Recommended)

```latex
% Metropolis is a modern, clean theme widely used in CS/ML talks
\documentclass[aspectratio=169]{beamer}
\usetheme{metropolis}

% Customize colors
\definecolor{customPrimary}{RGB}{0, 83, 159}  % University blue
\setbeamercolor{frametitle}{bg=customPrimary}
\setbeamercolor{progress bar}{fg=customPrimary}

% Optional: use Fira Sans font (matches Metropolis design)
% \usepackage[sfdefault]{FiraSans}
```

## Slide Types and Templates

### Title + Content Slide

```latex
\begin{frame}{Main Result}
  \begin{theorem}[Our Main Theorem]
    For any $\epsilon > 0$, Algorithm~\ref{alg:ours} achieves an
    approximation ratio of $(1 - \epsilon)$ in time $O(n \log n / \epsilon)$.
  \end{theorem}

  \vspace{0.5em}
  Key implications:
  \begin{enumerate}
    \item First polynomial-time approximation scheme for this problem
    \item Improves over Smith et al. (2023) by a factor of $O(\log n)$
    \item Extends to weighted variants
  \end{enumerate}
\end{frame}
```

### Two-Column Slide

```latex
\begin{frame}{Method Overview}
  \begin{columns}[T]
    \begin{column}{0.48\textwidth}
      \textbf{Architecture}
      \begin{itemize}
        \item Encoder: 6-layer Transformer
        \item Decoder: 6-layer Transformer
        \item Hidden dim: 512
        \item Attention heads: 8
      \end{itemize}
    \end{column}
    \begin{column}{0.48\textwidth}
      \textbf{Training}
      \begin{itemize}
        \item Optimizer: AdamW
        \item Learning rate: $3 \times 10^{-4}$
        \item Batch size: 256
        \item Epochs: 100
      \end{itemize}
    \end{column}
  \end{columns}
\end{frame}
```

### Figure Slide

```latex
\begin{frame}{Experimental Results}
  \begin{figure}
    \centering
    \includegraphics[width=0.85\textwidth]{figures/results-comparison.pdf}
    \caption{Our method (blue) outperforms baselines across all benchmarks.}
  \end{figure}
\end{frame}
```

### Table Slide

```latex
\begin{frame}{Comparison with State of the Art}
  \centering
  \small
  \begin{tabular}{lcccc}
    \toprule
    Method & Accuracy & F1 & Params & Speed \\
    \midrule
    Baseline A & 85.2 & 83.1 & 110M & 1.0x \\
    Baseline B & 87.5 & 85.8 & 340M & 0.3x \\
    \textbf{Ours} & \textbf{89.1} & \textbf{87.4} & 125M & 0.9x \\
    \bottomrule
  \end{tabular}
\end{frame}
```

## Animations and Overlays

### Progressive Reveal

```latex
\begin{frame}{Key Contributions}
  \begin{itemize}
    \item<1-> First contribution: novel problem formulation
    \item<2-> Second contribution: efficient algorithm
    \item<3-> Third contribution: theoretical guarantees
    \item<4-> Fourth contribution: extensive experiments
  \end{itemize}

  \only<4>{
    \vspace{1em}
    \alert{All code and data are publicly available.}
  }
\end{frame}
```

### Highlighting

```latex
\begin{frame}{Pipeline}
  Step 1: Data collection
  \begin{itemize}
    \item \alert<2>{Crawl 10M web pages}
    \item \alert<3>{Filter and deduplicate}
    \item \alert<4>{Annotate with human labels}
  \end{itemize}

  \uncover<5->{
    \begin{block}{Result}
      Final dataset: 2.3M high-quality labeled examples.
    \end{block}
  }
\end{frame}
```

## Code Listings in Beamer

```latex
\usepackage{listings}
\lstset{
  basicstyle=\ttfamily\scriptsize,
  keywordstyle=\color{blue}\bfseries,
  commentstyle=\color{gray},
  stringstyle=\color{red},
  breaklines=true,
  frame=single,
  backgroundcolor=\color{gray!10}
}

\begin{frame}[fragile]{Implementation}  % [fragile] required for listings
  \begin{lstlisting}[language=Python]
import torch
import torch.nn as nn

class TransformerBlock(nn.Module):
    def __init__(self, d_model, n_heads):
        super().__init__()
        self.attn = nn.MultiheadAttention(d_model, n_heads)
        self.norm = nn.LayerNorm(d_model)

    def forward(self, x):
        return self.norm(x + self.attn(x, x, x)[0])
  \end{lstlisting}
\end{frame}
```

## Presentation Tips for Academic Talks

### Content Planning

| Talk Length | Slides | Content |
|------------|--------|---------|
| 5 min (lightning) | 5-7 | Problem, method, key result |
| 15 min (conference) | 12-18 | + motivation, related work brief, 2-3 results |
| 30 min (seminar) | 20-30 | + background, methods detail, analysis |
| 60 min (colloquium) | 35-50 | + extensive background, all results, future work |

### Design Principles

- **One idea per slide**: If you need to explain two things, use two slides
- **Minimize text**: Use bullet points (max 5-6 per slide), not paragraphs
- **Large fonts**: Body text at least 20pt; never below 16pt
- **High-contrast figures**: Ensure readability on projectors (avoid light colors on white)
- **Consistent style**: Same fonts, colors, and layout throughout
- **Backup slides**: Put extra details, proofs, and additional results after `\appendix` for Q&A

```latex
% Backup slides (not counted in slide numbers)
\appendix
\begin{frame}{Proof of Theorem 1}
  ...
\end{frame}
```
