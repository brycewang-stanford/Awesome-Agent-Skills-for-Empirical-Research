---
name: sophosia-reference-guide
description: "Reference manager with PDF viewer and Markdown note support"
metadata:
  openclaw:
    emoji: "📚"
    category: "literature"
    subcategory: "metadata"
    keywords: ["reference manager", "PDF viewer", "Markdown notes", "Excalidraw", "paper organization", "open source"]
    source: "https://github.com/sophosia/sophosia"
---

# Sophosia Reference Manager Guide

## Overview

Sophosia is an open-source reference manager that combines PDF viewing, Markdown note-taking, and Excalidraw visual notes in a single application. Unlike traditional reference managers, it treats each paper as a rich workspace with typed annotations, linked notes, and visual diagrams. Built with modern web technologies (Electron + Vue), it runs on all desktop platforms.

## Installation

```bash
# Download from GitHub releases (Windows/macOS/Linux)
# Or build from source:
git clone https://github.com/sophosia/sophosia.git
cd sophosia
npm install && npm run build
```

## Features

```markdown
### Core Capabilities
- **PDF Viewer**: Built-in reader with annotations
- **Markdown Notes**: Rich note editor per paper
- **Excalidraw**: Visual whiteboard for diagrams
- **Tags & Collections**: Flexible organization
- **BibTeX Support**: Import/export bibliography
- **Full-text Search**: Search across all papers
- **Citation Graph**: Visual paper relationships

### Note Types
1. **Text notes** — Markdown with LaTeX math
2. **Visual notes** — Excalidraw canvas
3. **Annotation notes** — Linked to PDF highlights
4. **Outline notes** — Structured paper summaries
```

## Workspace Structure

```markdown
### Per-Paper Workspace
Paper: "Attention Is All You Need"
├── PDF (with highlights and annotations)
├── Notes/
│   ├── summary.md (structured summary)
│   ├── ideas.md (research ideas sparked)
│   └── architecture.excalidraw (visual diagram)
├── Metadata (title, authors, year, DOI, tags)
└── Links (related papers, concept connections)
```

## Note-Taking Features

```markdown
### Markdown Notes Support
- Standard Markdown formatting
- LaTeX math: $E = mc^2$ and display equations
- Code blocks with syntax highlighting
- Tables and checklists
- Wikilinks: [[other-paper]] for cross-referencing
- Embeds: ![[figure.png]] for inline images
- Templates for consistent note structure

### Excalidraw Integration
- Draw architecture diagrams
- Mind maps for paper concepts
- Comparison charts between methods
- Hand-drawn style for informal notes
- Export as SVG/PNG for presentations
```

## Import/Export

```markdown
### Import Sources
- BibTeX (.bib)
- RIS format
- DOI lookup (auto-fetch metadata)
- PDF drag-and-drop (auto-extract metadata)
- Zotero export files

### Export Formats
- BibTeX for LaTeX
- Markdown bibliography
- CSV metadata export
- HTML reading lists
```

## Use Cases

1. **Reading workflow**: PDF + notes in single workspace
2. **Visual thinking**: Excalidraw diagrams alongside papers
3. **Literature review**: Linked notes across paper collection
4. **Presentation prep**: Visual notes exportable as diagrams
5. **Research journal**: Rich per-paper documentation

## References

- [Sophosia GitHub](https://github.com/sophosia/sophosia)
- [Excalidraw](https://excalidraw.com/)
