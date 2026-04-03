---
name: conference-paper-template
description: "Templates and formatting guides for major academic conference submissions"
metadata:
  openclaw:
    emoji: "📄"
    category: "writing"
    subcategory: "templates"
    keywords: ["conference paper template", "proceedings format", "camera-ready", "journal formatting requirements", "LaTeX template"]
    source: "wentor"
---

# Conference Paper Template

A skill providing templates, formatting guidelines, and submission checklists for major academic conferences. Covers LaTeX and Word template setup, common formatting requirements, and camera-ready preparation.

## Common Conference Formats

### Format Specifications by Venue

| Conference/Style | Page Limit | Columns | Font | Margins | Template |
|-----------------|-----------|---------|------|---------|----------|
| ACL/EMNLP (ARR) | 8 + refs | 2 | Times 11pt | 1in all | acl.sty |
| NeurIPS | 8 + refs | 2 | Times 10pt | 1in top/bottom, 0.75in sides | neurips.sty |
| ICML | 8 + refs | 2 | Times 10pt | 1in all | icml.sty |
| AAAI | 7 + 1 refs | 2 | Times 10pt | 0.75in all | aaai.sty |
| IEEE (CVPR, etc.) | 8 | 2 | Times 10pt | 1in top, 0.75in sides | IEEEtran.cls |
| ACM (SIGCHI, etc.) | varies | 1 or 2 | Linux Libertine | varies | acmart.cls |
| Springer LNCS | 12-16 | 1 | Computer Modern 10pt | varies | llncs.cls |

### LaTeX Template: General Conference Paper

```latex
\documentclass[11pt,a4paper]{article}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{times}
\usepackage{amsmath,amssymb}
\usepackage{graphicx}
\usepackage{booktabs}
\usepackage{hyperref}
\usepackage{natbib}
\usepackage[margin=1in]{geometry}

% Conference-specific: anonymization for review
\usepackage{xspace}
\newcommand{\etal}{\textit{et al.}\xspace}

\title{Your Paper Title: Subtitle with Key Contribution}

% For review submission (anonymous)
\author{Anonymous Authors}
% For camera-ready (de-anonymized)
% \author{First Author\textsuperscript{1} \and
%         Second Author\textsuperscript{2} \\
%         \textsuperscript{1}University A, \textsuperscript{2}University B \\
%         \texttt{\{first,second\}@email.edu}}

\begin{document}
\maketitle

\begin{abstract}
Your abstract here (typically 150-250 words).
State the problem, approach, key results, and significance.
\end{abstract}

\section{Introduction}
% Paragraph 1: Problem and motivation
% Paragraph 2: Limitations of existing approaches
% Paragraph 3: Your approach and contributions
% Paragraph 4: Paper organization (optional)

\section{Related Work}
% Organized by theme, not chronologically

\section{Method}
% Detailed enough to reproduce

\section{Experiments}
\subsection{Experimental Setup}
\subsection{Results}
\subsection{Analysis}

\section{Conclusion}

\bibliography{references}
\bibliographystyle{plainnat}

\end{document}
```

## Camera-Ready Preparation

### Pre-Submission Checklist

```python
def camera_ready_checklist(paper_info: dict) -> list[dict]:
    """
    Generate a camera-ready preparation checklist.

    Args:
        paper_info: Dict with 'venue', 'page_limit', 'has_appendix', etc.
    """
    checks = [
        {
            'item': 'De-anonymization',
            'description': 'Author names, affiliations, and acknowledgments restored',
            'critical': True
        },
        {
            'item': 'Page limit compliance',
            'description': f"Paper is within {paper_info.get('page_limit', 8)} page limit",
            'critical': True
        },
        {
            'item': 'Copyright/license form',
            'description': 'Signed and uploaded to submission system',
            'critical': True
        },
        {
            'item': 'Figures at 300 DPI',
            'description': 'All figures are high resolution (300 DPI minimum for print)',
            'critical': True
        },
        {
            'item': 'Fonts embedded',
            'description': 'All fonts embedded in PDF (check with pdffonts)',
            'critical': True
        },
        {
            'item': 'References complete',
            'description': 'All references have venue, year, pages; no "to appear" remaining',
            'critical': True
        },
        {
            'item': 'Hyperlinks work',
            'description': 'All URLs and DOIs are valid and clickable',
            'critical': False
        },
        {
            'item': 'Supplementary materials',
            'description': 'Code, data, appendices uploaded separately if required',
            'critical': False
        },
        {
            'item': 'Metadata in PDF',
            'description': 'PDF title and author metadata set correctly',
            'critical': False
        }
    ]

    return checks
```

### Fixing Common Formatting Issues

```bash
# Check for font embedding issues
pdffonts paper.pdf

# Embed all fonts (if any are not embedded)
gs -dNOPAUSE -dBATCH -sDEVICE=pdfwrite \
   -dPDFSETTINGS=/prepress \
   -dEmbedAllFonts=true \
   -dSubsetFonts=true \
   -sOutputFile=paper_embedded.pdf \
   paper.pdf

# Check page count
pdfinfo paper.pdf | grep Pages

# Verify PDF/A compliance (some venues require it)
verapdf paper.pdf
```

## Table and Figure Formatting

### Publication-Quality Tables

```latex
% Use booktabs for professional tables (never use vertical lines)
\begin{table}[t]
\centering
\caption{Comparison of methods on benchmark datasets.
         Best results in \textbf{bold}, second best \underline{underlined}.}
\label{tab:results}
\begin{tabular}{lcccc}
\toprule
Method & Dataset A & Dataset B & Dataset C & Avg. \\
\midrule
Baseline       & 78.2 & 72.1 & 81.3 & 77.2 \\
Previous SOTA  & 82.4 & 76.8 & 84.1 & 81.1 \\
Ours (w/o X)   & \underline{84.1} & \underline{78.2} & \underline{85.7} & \underline{82.7} \\
Ours (full)    & \textbf{86.3} & \textbf{80.1} & \textbf{87.2} & \textbf{84.5} \\
\bottomrule
\end{tabular}
\end{table}
```

### Figure Placement

```latex
% Figures should appear at top of page or on their own page
\begin{figure}[t]
\centering
\includegraphics[width=\columnwidth]{figures/architecture.pdf}
\caption{Overview of the proposed architecture. The encoder processes
         input sequences while the decoder generates structured output.}
\label{fig:architecture}
\end{figure}
```

## Submission Tips

- Start formatting early -- do not leave it for the night before the deadline
- Use `latexdiff` to generate a diff PDF showing changes from previous versions
- For Word submissions, use the official template's styles (not manual formatting)
- Always check the supplementary material policy: some venues allow unlimited appendix pages, others count toward the page limit
- Keep a backup of the exact submitted version with a timestamp for your records
