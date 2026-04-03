---
name: elegant-paper-template
description: "Beautiful LaTeX template for working papers and technical reports"
metadata:
  openclaw:
    emoji: "✨"
    category: "writing"
    subcategory: "templates"
    keywords: ["ElegantPaper", "LaTeX template", "working paper", "technical report", "elegant design", "academic paper"]
    source: "https://github.com/ElegantLaTeX/ElegantPaper"
---

# ElegantPaper Template

## Overview

ElegantPaper is a beautifully designed LaTeX template from the ElegantLaTeX project, tailored for working papers, technical reports, and preprints. It features clean typography, optional color themes (green, cyan, blue, black), bilingual support (English/Chinese), and a minimal yet professional appearance. Part of the ElegantLaTeX series (ElegantPaper, ElegantBook, ElegantNote).

## Quick Start

```bash
# Download template
git clone https://github.com/ElegantLaTeX/ElegantPaper.git

# Compile with XeLaTeX (for Chinese) or PDFLaTeX (English only)
xelatex elegantpaper-en && bibtex elegantpaper-en && xelatex elegantpaper-en
```

## Template Usage

```latex
\documentclass[lang=en]{elegantpaper}

\title{Your Working Paper Title}
\author{Author Name\thanks{Affiliation, email@university.edu}}
\date{\today}

\begin{document}
\maketitle

\begin{abstract}
  A concise summary of your working paper.
  \keywords{keyword1, keyword2, keyword3}
\end{abstract}

\section{Introduction}
Your introduction text here.

\section{Model}
Mathematical model or methodology.

\begin{theorem}\label{thm:main}
  For all $x \in \mathbb{R}^n$, if $f$ is convex, then...
\end{theorem}

\begin{proof}
  The proof follows from...
\end{proof}

\section{Results}
Empirical or theoretical results.

\bibliography{references}

\end{document}
```

## Template Options

```latex
% Language: en (English) or cn (Chinese)
\documentclass[lang=en]{elegantpaper}
\documentclass[lang=cn]{elegantpaper}

% Color theme
\documentclass[color=green]{elegantpaper}   % Default green
\documentclass[color=cyan]{elegantpaper}
\documentclass[color=blue]{elegantpaper}
\documentclass[color=black]{elegantpaper}   % Formal/print

% Math font
\documentclass[math=cm]{elegantpaper}       % Computer Modern
\documentclass[math=newtx]{elegantpaper}    % Times-like

% Citation style
\documentclass[cite=authoryear]{elegantpaper}  % (Author, Year)
\documentclass[cite=numbers]{elegantpaper}      % [1]
```

## Built-in Environments

```latex
% Theorem family (auto-numbered, colored)
\begin{theorem}...\end{theorem}
\begin{lemma}...\end{lemma}
\begin{proposition}...\end{proposition}
\begin{corollary}...\end{corollary}

% Definition and examples
\begin{definition}...\end{definition}
\begin{example}...\end{example}
\begin{remark}...\end{remark}

% Proof
\begin{proof}...\end{proof}
```

## Chinese Support

```latex
\documentclass[lang=cn]{elegantpaper}

\title{基于深度学习的自然语言处理研究进展}
\author{张三\thanks{北京大学, zhangsan@pku.edu.cn}}

\begin{document}
\maketitle

\begin{abstract}
  本文综述了深度学习在自然语言处理中的最新进展。
  \keywords{深度学习, 自然语言处理, 注意力机制}
\end{abstract}

\section{引言}
近年来...
\end{document}
```

## ElegantLaTeX Family

| Template | Purpose |
|----------|---------|
| **ElegantPaper** | Working papers, short reports |
| **ElegantBook** | Books, long-form documents |
| **ElegantNote** | Lecture notes, course materials |

## References

- [ElegantPaper GitHub](https://github.com/ElegantLaTeX/ElegantPaper)
- [ElegantLaTeX](https://elegantlatex.org/)
- [ElegantPaper Documentation](https://github.com/ElegantLaTeX/ElegantPaper/blob/master/elegantpaper-en.pdf)
