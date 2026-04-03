---
name: papis-cli-guide
description: "Guide to Papis command-line document and bibliography manager for researchers"
metadata:
  openclaw:
    emoji: "💻"
    category: "writing"
    subcategory: "citation"
    keywords: ["papis", "cli", "bibliography", "document-manager", "terminal", "command-line"]
    source: "https://github.com/papis/papis"
---

# Papis CLI Document Manager Guide

## Overview

Papis is a powerful command-line document and bibliography manager with over 2,000 GitHub stars, designed for researchers who prefer terminal-based workflows. Written in Python, it provides a fast, scriptable, and highly customizable alternative to GUI-based reference managers like Zotero or Mendeley.

The philosophy behind Papis is that bibliographic data should be stored in simple, human-readable files organized in a plain directory structure. Each document in a Papis library is a folder containing a YAML metadata file (`info.yaml`) and associated files (PDFs, supplementary materials, notes). This approach means your library is inherently portable, versionable with Git, and accessible through any tool that can read files and directories.

For researchers who spend most of their time in terminals, use Vim or Emacs for writing, and prefer scriptable tools over graphical interfaces, Papis offers a natural fit. It integrates with academic databases for metadata retrieval, supports BibTeX and BibLaTeX export, and provides an extensible plugin system for custom workflows. Despite its command-line interface, Papis also includes optional GUI pickers and a web interface for when visual browsing is helpful.

## Installation and Setup

Install Papis using pip or your system package manager:

**Via pip (recommended)**:
```bash
pip install papis
```

**Via system package managers**:
- macOS: `brew install papis`
- Arch Linux: `pacman -S papis`
- Nix: `nix-env -i papis`

**Initial configuration**: Papis stores its configuration in `~/.config/papis/config`. Create a minimal configuration:

```ini
[settings]
default-library = research

[research]
dir = ~/Documents/papers
```

This tells Papis to manage a library called "research" stored in `~/Documents/papers`. Each document you add will create a subdirectory within this path containing the document file and metadata.

**Additional configuration options**:
```ini
[settings]
default-library = research
editor = vim
file-browser = open
picktool = papis.pick
database-backend = papis

[research]
dir = ~/Documents/papers
use-cache = True

[books]
dir = ~/Documents/books
```

You can define multiple libraries (research papers, books, technical reports) each with their own directory and configuration.

## Core Features

**Adding Documents**: Add papers to your library from multiple sources:

```bash
# Add a PDF with automatic metadata retrieval via DOI
papis add paper.pdf --from doi 10.1038/s41586-024-07487-w

# Add from arXiv identifier
papis add --from arxiv 2401.12345

# Add from a BibTeX file
papis add paper.pdf --from bibtex reference.bib

# Add with manual metadata
papis add paper.pdf --set author "Smith, John" --set title "Deep Learning" --set year 2024

# Add from ISBN (for books)
papis add book.pdf --from isbn 978-0-13-468599-1
```

**Searching and Browsing**: Query your library with flexible search:

```bash
# Search by any field
papis open "author:smith AND year:2024"

# List matching documents
papis list "machine learning"

# Browse with an interactive picker
papis browse "neural networks"

# Export search results as BibTeX
papis export --format bibtex "deep learning 2024"
```

**Document Operations**:

```bash
# Open the PDF of a document
papis open "smith 2024"

# Edit metadata in your configured editor
papis edit "smith 2024"

# Rename and organize files
papis rename "smith 2024"

# Remove a document
papis rm "old paper 2015"

# Move between libraries
papis mv --lib books "programming textbook"
```

**BibTeX Export**: Generate BibTeX files for LaTeX projects:

```bash
# Export entire library
papis export --all --format bibtex > references.bib

# Export specific entries
papis export --format bibtex "author:smith" >> project.bib

# Export in BibLaTeX format
papis export --format biblatex "machine learning" > ml-refs.bib
```

**Metadata Retrieval**: Fetch or update metadata from online sources:

```bash
# Update metadata from DOI
papis update --from doi "smith 2024"

# Fetch metadata from CrossRef
papis update --from crossref "incomplete entry"

# Bulk update metadata for all items missing DOIs
papis update --from crossref --all
```

## Academic Workflow Integration

**Terminal-Centric Research Workflow**:

1. **Discovery**: Find a paper, download the PDF
2. **Import**: `papis add paper.pdf --from doi 10.xxxx/xxxxx`
3. **Read**: `papis open "paper title"` to open in your PDF viewer
4. **Annotate**: Add notes directly to the info.yaml or in a separate notes file
5. **Cite**: `papis export --format bibtex "paper title" >> thesis.bib`
6. **Write**: Reference in your LaTeX/Markdown document

**Version Control Integration**: Since Papis stores everything as files and directories, you can version your entire library with Git:

```bash
cd ~/Documents/papers
git init
git add .
git commit -m "Initial library snapshot"
```

This gives you full history of metadata changes, the ability to sync across machines, and collaborative library management through Git workflows.

**Scripting and Automation**: Papis exposes a Python API for custom scripts:

```python
import papis.api

# Search the library programmatically
docs = papis.api.get_documents_in_lib("research")
ml_papers = [d for d in docs if "machine learning" in d.get("tags", "")]

# Export filtered results
for doc in ml_papers:
    print(f"{doc['author']} ({doc['year']}). {doc['title']}")
```

**Integration with Text Editors**:
- **Vim**: Use `papis.vim` plugin for searching and inserting citations without leaving the editor
- **Emacs**: Use `papis.el` for Org-mode and LaTeX integration
- **FZF**: Pipe Papis output to fzf for fuzzy finding: `papis list --all | fzf`

**Syncing Across Machines**: Use any file synchronization tool (Syncthing, rsync, cloud storage) or Git to keep your Papis library consistent across workstations. The plain-file storage format ensures compatibility regardless of platform.

## Plugin Ecosystem

Papis supports plugins for extended functionality:

- **papis-rofi**: Rofi-based document picker for Linux desktop users
- **papis-zotero**: Import your existing Zotero library into Papis
- **papis-firefox**: Browser extension for adding papers from web pages
- **papis-libgen**: Search and download from Library Genesis (for open-access content)

Install plugins via pip:
```bash
pip install papis-zotero
papis zotero import --from-bibtex zotero-export.bib
```

## References

- GitHub Repository: https://github.com/papis/papis
- Papis Documentation: https://papis.readthedocs.io
- Papis Wiki: https://github.com/papis/papis/wiki
- PyPI Package: https://pypi.org/project/papis
