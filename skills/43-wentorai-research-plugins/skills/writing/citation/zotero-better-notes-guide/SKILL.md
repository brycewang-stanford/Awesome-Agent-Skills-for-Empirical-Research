---
name: zotero-better-notes-guide
description: "Guide to Zotero Better Notes for comprehensive note-taking in research"
metadata:
  openclaw:
    emoji: "📝"
    category: "writing"
    subcategory: "citation"
    keywords: ["zotero", "note-taking", "better-notes", "research-notes", "knowledge-management"]
    source: "https://github.com/windingwind/zotero-better-notes"
---

# Zotero Better Notes Guide

## Overview

Zotero Better Notes transforms Zotero from a reference manager into a full-featured research knowledge management system. With over 7,000 GitHub stars, it is one of the most popular Zotero plugins, addressing a critical gap in the academic workflow: the connection between reading papers and building structured knowledge.

The plugin introduces a powerful note editor with bidirectional linking, templates, and syncing capabilities directly within Zotero. Instead of jumping between Zotero and external note-taking applications like Obsidian or Notion, researchers can maintain their notes alongside the papers they reference, preserving the tight coupling between sources and ideas.

Better Notes supports Markdown editing, note templates, outline views, and export to external systems. It integrates with Zotero's annotation system so that highlights and comments made while reading PDFs can flow directly into structured notes. This creates a seamless pipeline from reading to writing that significantly reduces friction in the research process.

## Installation and Setup

Install Better Notes through the standard Zotero add-on mechanism:

1. Download the latest `.xpi` release from https://github.com/windingwind/zotero-better-notes/releases
2. In Zotero, go to Tools > Add-ons > gear icon > Install Add-on From File
3. Select the `.xpi` file and restart Zotero

Initial configuration steps:

- Open Zotero Preferences > Better Notes
- Set your preferred note template directory (a local folder for custom templates)
- Configure the default note template for new notes
- Enable or disable auto-insert of annotations into linked notes
- Set up sync preferences if you want notes to export to an external folder
- Choose your preferred Markdown editor behavior and keyboard shortcuts

For researchers using external knowledge bases, configure the sync feature:

- Set a sync target directory (e.g., your Obsidian vault or a shared folder)
- Choose the sync format (Markdown with YAML frontmatter recommended)
- Configure auto-sync frequency or use manual sync triggers
- Map Zotero fields to frontmatter keys for consistent metadata

## Core Features

**Enhanced Note Editor**: Better Notes replaces the default Zotero note editor with a Markdown-capable editor that supports rich formatting, code blocks, mathematical notation, tables, and more. The editor provides a live preview mode and an outline panel for navigating long notes.

**Note Templates**: Create and manage reusable note templates for different types of research activities:
- Paper reading templates with sections for summary, methods, findings, and critique
- Literature review templates that aggregate information across multiple papers
- Meeting notes templates for lab meetings and conference sessions
- Project planning templates with task tracking and milestone sections

Templates support dynamic variables that auto-populate with item metadata:

```
# ${title}
**Authors**: ${authors}
**Year**: ${year}
**Journal**: ${publicationTitle}

## Summary

## Methods

## Key Findings

## Relevance to My Research
```

**Bidirectional Linking**: Create links between notes using a wiki-style `[[note title]]` syntax. This builds a knowledge graph within your Zotero library, allowing you to trace connections between concepts, papers, and ideas. The backlinks panel shows all notes that reference the current note.

**Annotation Integration**: When you highlight text or add comments in the Zotero PDF reader, Better Notes can automatically insert these annotations into a designated note for that item. Annotations are formatted with citation links back to the exact page and location in the PDF.

**Outline View**: A dedicated outline panel displays the heading structure of your current note, providing quick navigation for long documents. This is especially useful for literature review notes that may span dozens of pages.

**Note Export and Sync**: Export notes as Markdown files to any directory on your system. The sync feature can automatically keep an external folder up to date with your Zotero notes, enabling integration with tools like Obsidian, Logseq, or any Markdown-based system.

## Research Workflow Integration

**Phase 1 - Paper Reading**: When you begin reading a paper, create a new note from your reading template. As you read in the Zotero PDF reader, your highlights and annotations automatically flow into the note. Add your own commentary and analysis in the appropriate template sections.

**Phase 2 - Knowledge Synthesis**: After reading multiple papers on a topic, create a synthesis note that links to individual paper notes using bidirectional links. Use the template system to structure your synthesis with sections for themes, contradictions, gaps, and your own contributions.

**Phase 3 - Writing Preparation**: When preparing to write, use the outline view to organize your synthesis notes into a logical argument structure. Export relevant notes to your writing environment, maintaining citation links that can be converted to formal references.

**Phase 4 - Collaboration**: Share exported notes with collaborators through synced folders. The Markdown format ensures compatibility across different tools and platforms, while Zotero citation keys maintain the connection to the original sources.

**Best Practices for Note Organization**:
- Use a consistent naming convention for notes (e.g., `@citekey - title`)
- Create index notes for major research themes that link to related paper notes
- Review and update your knowledge graph regularly to maintain connections
- Use tags in notes to create cross-cutting categories beyond the folder structure
- Periodically export and backup your notes to guard against data loss

## Advanced Template Customization

Better Notes templates support JavaScript expressions for dynamic content generation:

```
# Reading Notes: ${title}

**Date Read**: ${new Date().toISOString().split('T')[0]}
**Item Type**: ${itemType}
**DOI**: ${DOI}

## Quick Reference
- **Citation**: ${authors} (${year}). ${title}. *${publicationTitle}*.
```

You can create template collections for different research activities and switch between them from the note creation dialog. Templates can also include conditional sections that only appear when certain metadata fields are present.

## References

- GitHub Repository: https://github.com/windingwind/zotero-better-notes
- Better Notes Documentation: https://github.com/windingwind/zotero-better-notes/wiki
- Zotero Plugin Directory: https://www.zotero.org/support/plugins
- Zettelkasten Method for Researchers: https://zettelkasten.de/introduction
