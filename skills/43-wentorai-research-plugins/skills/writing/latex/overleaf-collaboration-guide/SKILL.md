---
name: overleaf-collaboration-guide
description: "Guide to collaborative LaTeX editing with Overleaf"
metadata:
  openclaw:
    emoji: "👥"
    category: "writing"
    subcategory: "latex"
    keywords: ["online LaTeX editor", "collaborative LaTeX", "Overleaf", "LaTeX environment setup"]
    source: "wentor-research-plugins"
---

# Overleaf Collaboration Guide

Set up and manage collaborative LaTeX projects on Overleaf with best practices for multi-author workflows, version control, and project organization.

## Getting Started with Overleaf

### Creating a Project

Overleaf (overleaf.com) is a browser-based LaTeX editor that provides real-time collaboration, automatic compilation, and integrated version history.

Project creation options:

| Method | When to Use |
|--------|-------------|
| Blank project | Starting from scratch |
| Upload project | Migrating existing local LaTeX project |
| Import from GitHub | Existing repo-based project |
| Use a template | Conference/journal submissions (IEEE, ACM, Springer, Elsevier templates available) |
| Copy from existing | Forking a previous project |

### Recommended Project Structure

```
project-root/
├── main.tex              # Main document (entry point)
├── preamble.tex          # Packages, macros, custom commands
├── sections/
│   ├── 01-introduction.tex
│   ├── 02-related-work.tex
│   ├── 03-methods.tex
│   ├── 04-results.tex
│   ├── 05-discussion.tex
│   └── 06-conclusion.tex
├── figures/
│   ├── fig1-overview.pdf
│   ├── fig2-results.pdf
│   └── fig3-comparison.pdf
├── tables/
│   └── results-table.tex
├── references.bib        # Bibliography database
└── README.md             # Project notes (not compiled)
```

### Main File Setup

```latex
% main.tex
\documentclass[conference]{IEEEtran}  % or article, etc.
\input{preamble}  % load packages and macros

\begin{document}

\title{Your Paper Title}
\author{Author One \and Author Two \and Author Three}
\maketitle

\begin{abstract}
Your abstract here.
\end{abstract}

\input{sections/01-introduction}
\input{sections/02-related-work}
\input{sections/03-methods}
\input{sections/04-results}
\input{sections/05-discussion}
\input{sections/06-conclusion}

\bibliographystyle{IEEEtran}
\bibliography{references}

\end{document}
```

## Multi-Author Collaboration

### Sharing and Permissions

| Role | Capabilities |
|------|-------------|
| Owner | Full control, can delete project, manage collaborators |
| Editor | Can edit all files, cannot manage collaborators |
| Viewer | Read-only access, can download but not modify |

Share via:
- **Link sharing**: Generate a read-only or edit link (anyone with the link can access)
- **Email invitation**: Invite specific collaborators by email with role assignment

### Author Coordination Best Practices

1. **Assign sections**: Each author owns specific `.tex` files to minimize merge conflicts.
2. **Use comments**: Overleaf supports inline comments (`% TODO: revise this paragraph`) and threaded review comments.
3. **Use custom commands for notes**:

```latex
% In preamble.tex, define author-specific annotation commands
\usepackage{xcolor}
\newcommand{\alice}[1]{\textcolor{blue}{[Alice: #1]}}
\newcommand{\bob}[1]{\textcolor{red}{[Bob: #1]}}
\newcommand{\todo}[1]{\textcolor{orange}{[TODO: #1]}}

% In text:
This result is surprising \alice{Should we add more analysis here?}
and warrants further investigation \todo{Add statistical test}.
```

4. **Track changes**: Overleaf Premium includes a track-changes mode. For free plans, use the `changes` package:

```latex
\usepackage{changes}
\definechangesauthor[name={Alice}, color=blue]{AL}
\definechangesauthor[name={Bob}, color=red]{BO}

% Usage:
\added[id=AL]{This is new text added by Alice.}
\deleted[id=BO]{This text was removed by Bob.}
\replaced[id=AL]{new text}{old text}
```

## Git Integration

### Overleaf + GitHub Sync

Overleaf Premium supports bidirectional GitHub sync:

1. In Overleaf, go to Menu > Sync > GitHub
2. Link your GitHub account and select or create a repository
3. Pull/push changes between Overleaf and GitHub

### Overleaf + Local Git

```bash
# Clone your Overleaf project via git
git clone https://git.overleaf.com/YOUR_PROJECT_ID my-paper
cd my-paper

# Edit locally, then push back to Overleaf
git add -A
git commit -m "Updated results table"
git push origin master

# Pull changes made on Overleaf
git pull origin master
```

**Credentials**: Use your Overleaf email as username and an Overleaf-generated token as password.

## Compilation and Debugging

### Common Compilation Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `Undefined control sequence` | Missing package or typo in command | Check `\usepackage` or spelling |
| `Missing $ inserted` | Math symbol outside math mode | Wrap in `$...$` or `\text{...}` |
| `File not found` | Incorrect path in `\input` or `\includegraphics` | Check file names (case-sensitive on Overleaf) |
| `Overfull \hbox` | Content too wide for column | Resize figure, adjust text, or add `\sloppy` |
| `Citation undefined` | BibTeX entry missing or key mismatch | Verify `.bib` entry key matches `\cite{}` |

### Debugging Tips

- Use **Recompile from scratch** (Ctrl+Shift+Enter) to clear cache
- Check the **Logs and output files** panel for detailed error messages
- Use `\listfiles` in preamble to see which packages are loaded
- Overleaf uses TeX Live 2024; check package compatibility if using older templates

## Submission Workflow

### Preparing for Journal Submission

1. **Flatten the project**: Some journals require a single `.tex` file.

```bash
# Use latexpand to flatten \input commands
latexpand main.tex > submission.tex
```

2. **Check formatting**: Verify page limits, font sizes, margin requirements.
3. **Download as zip**: Menu > Download > Source to get all files.
4. **Convert figures**: Ensure all figures are in accepted formats (PDF, EPS, or high-res PNG/TIFF).
5. **Clean up**: Remove TODO comments, author annotation commands, and debug code.

```latex
% Add to preamble for submission: disable all annotation commands
\renewcommand{\alice}[1]{}
\renewcommand{\bob}[1]{}
\renewcommand{\todo}[1]{}
```

## Useful Overleaf Keyboard Shortcuts

| Action | Shortcut (Mac) | Shortcut (Windows) |
|--------|---------------|-------------------|
| Compile | Cmd+Enter | Ctrl+Enter |
| Bold | Cmd+B | Ctrl+B |
| Italic | Cmd+I | Ctrl+I |
| Comment toggle | Cmd+/ | Ctrl+/ |
| Find & replace | Cmd+H | Ctrl+H |
| Go to line | Cmd+Shift+L | Ctrl+Shift+L |
| Toggle PDF | Cmd+Shift+O | Ctrl+Shift+O |
