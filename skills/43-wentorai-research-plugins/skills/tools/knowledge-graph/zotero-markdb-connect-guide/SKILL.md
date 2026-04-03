---
name: zotero-markdb-connect-guide
description: "Sync Zotero references to Obsidian and Logseq markdown"
metadata:
  openclaw:
    emoji: "🔗"
    category: "tools"
    subcategory: "knowledge-graph"
    keywords: ["Zotero", "Obsidian", "Logseq", "markdown", "PKM", "literature notes"]
    source: "https://github.com/daeh/zotero-markdb-connect"
---

# Zotero MarkDB-Connect Guide

## Overview

Zotero MarkDB-Connect bridges Zotero with Markdown-based knowledge management tools (Obsidian, Logseq). It creates and maintains bidirectional links between Zotero items and their corresponding Markdown literature notes, enabling seamless navigation between your reference manager and PKM system. Syncs metadata, annotations, and tags.

## Installation

```bash
# Download .xpi from GitHub releases
# Zotero 7: Tools → Add-ons → Install Add-on From File
```

## Configuration

```markdown
### Settings (Edit → Preferences → MarkDB-Connect)

**Markdown Vault Path:**
- Point to your Obsidian vault or Logseq directory
- Example: ~/Documents/ObsidianVault/Literature/

**Note Template:**
- Customize the Markdown template for new literature notes
- Uses Zotero item fields as variables

**Sync Options:**
- Auto-create notes for new items
- Sync annotations to Markdown
- Bidirectional tag sync
- Update existing notes on item change
```

## Note Template

```markdown
<!-- Template for literature notes -->
---
title: "{{title}}"
authors: [{{authors}}]
year: {{year}}
doi: {{doi}}
citekey: {{citekey}}
tags: [{{tags}}]
zotero: {{zoteroSelectURI}}
---

# {{title}}

**Authors:** {{authors}}
**Year:** {{year}}
**Venue:** {{publicationTitle}}
**DOI:** [{{doi}}](https://doi.org/{{doi}})

## Abstract
{{abstractNote}}

## Annotations
{{annotations}}

## Key Takeaways
-

## Notes
-

## Connections
- Related: [[]]
- Builds on: [[]]
- Contradicts: [[]]
```

## Obsidian Integration

```markdown
### Folder Structure
ObsidianVault/
├── Literature/          # Auto-generated literature notes
│   ├── vaswani2017.md
│   ├── devlin2019.md
│   └── brown2020.md
├── Concepts/            # Your concept notes
│   ├── Attention.md     # Links to [[vaswani2017]]
│   └── Pre-training.md  # Links to [[devlin2019]]
└── Projects/            # Project notes referencing papers

### Workflow
1. Import paper in Zotero (via browser connector)
2. MarkDB-Connect auto-creates Literature/citekey.md
3. In Obsidian: open literature note, add your thoughts
4. Link to concept notes using [[wikilinks]]
5. Annotations sync from Zotero PDF reader
```

## Annotation Sync

```markdown
### Zotero PDF Annotations → Markdown

When you highlight or annotate in Zotero's PDF reader:

> [!quote] Highlight (Yellow)
> "The attention mechanism allows focusing on relevant parts"
> — p. 3

> [!note] Note
> This is the key insight — attention replaces recurrence
> — p. 3, linked to highlight above

> [!important] Red Highlight
> "Our model achieves 28.4 BLEU on WMT 2014"
> — p. 7

Annotations auto-sync to the Markdown note when updated.
```

## Logseq Integration

```markdown
### Logseq-Specific Setup
- Set vault path to your Logseq pages directory
- Notes created as Logseq pages with properties block
- Uses Logseq property syntax instead of YAML frontmatter

### Logseq Note Format
title:: Attention Is All You Need
authors:: [[Vaswani]], [[Shazeer]]
year:: 2017
doi:: 10.48550/arXiv.1706.03762
tags:: #transformer #attention
zotero:: zotero://select/items/...

- Key contributions
  - Self-attention mechanism replacing recurrence
  - Multi-head attention for different representation subspaces
```

## Use Cases

1. **Literature management**: Seamless Zotero ↔ Obsidian workflow
2. **Knowledge building**: Link papers to concept notes
3. **Annotation workflow**: PDF annotations in Markdown
4. **Research writing**: Quick access to notes while writing
5. **Zettelkasten**: Literature notes as part of note network

## References

- [MarkDB-Connect GitHub](https://github.com/daeh/zotero-markdb-connect)
- [Obsidian](https://obsidian.md/)
- [Logseq](https://logseq.com/)
