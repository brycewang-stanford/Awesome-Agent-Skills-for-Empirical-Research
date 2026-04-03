---
name: obsidian-citation-guide
description: "Citation plugin for Obsidian note-taking with BibTeX support"
version: 1.0.0
author: wentor-community
source: https://github.com/hans/obsidian-citation-plugin
metadata:
  openclaw:
    category: "writing"
    subcategory: "citation"
    emoji: "📚"
    keywords:
      - obsidian
      - citations
      - bibtex
      - literature-notes
      - reference-linking
      - knowledge-management
---

# Obsidian Citation Guide

A skill for using the Obsidian Citation Plugin to integrate bibliographic references from BibTeX or CSL-JSON files into the Obsidian knowledge management workflow. Based on obsidian-citation-plugin (1K stars), this skill enables researchers to create literature notes, insert citations, and build interconnected knowledge bases grounded in their reference libraries.

## Overview

Academic researchers need their notes to be deeply connected to their references. The Obsidian Citation Plugin bridges BibTeX or CSL-JSON bibliography files with Obsidian's note-taking system, enabling seamless creation of literature notes from reference entries, quick citation insertion while writing, and automatic backlinking between notes and their source references.

Unlike Zotero-specific integrations, this plugin works with any tool that exports standard BibTeX or CSL-JSON, making it compatible with Zotero, JabRef, Mendeley, EndNote, and even hand-crafted .bib files.

## Setup and Configuration

**Prerequisites**
- Obsidian with community plugins enabled
- A BibTeX (.bib) or CSL-JSON (.json) bibliography file
- The bibliography file should be accessible from the Obsidian vault directory

**Installation**
- Open Obsidian Settings and navigate to Community Plugins
- Search for "Citations" in the plugin browser
- Install the Citations plugin and enable it
- Navigate to the plugin settings to configure your bibliography source

**Configuration**
- Set the path to your .bib or .json bibliography file
- Configure the literature note folder (e.g., `references/` or `literature/`)
- Set the literature note template with desired frontmatter fields
- Define the citation format for in-text insertions
- Configure the citation key format used for note file names

**Template Variables**
- `{{citekey}}` - the unique citation key for the reference
- `{{title}}` - the full title of the work
- `{{authorString}}` - formatted author list
- `{{year}}` - publication year
- `{{abstract}}` - the abstract if available in the bibliography
- `{{DOI}}` - Digital Object Identifier
- `{{URL}}` - web link to the publication
- `{{containerTitle}}` - journal or conference name
- `{{page}}` - page numbers
- `{{tags}}` - keywords or tags from the bibliography entry

## Core Workflows

**Creating Literature Notes**
- Use the command palette to open the citation picker
- Search by author, title, year, or any metadata field
- Select a reference to create a new literature note from the template
- The note is populated with metadata from the bibliography entry
- Add your own annotations, summaries, and connections to the note

**Inserting Citations**
- While writing in any Obsidian note, trigger the citation insertion command
- Search and select the desired reference
- The citation is inserted in the configured format (e.g., `[@citekey]`, `[[@citekey]]`)
- Citations create automatic backlinks to the corresponding literature notes
- Multiple citation formats can be configured for different output targets

**Browsing References**
- Open the citation panel to browse your entire bibliography
- Filter by type (article, book, chapter, conference), year, or author
- Preview reference details without creating a note
- Quickly jump to existing literature notes for any reference
- Identify references that do not yet have corresponding notes

## Literature Note Strategies

**Minimal Notes (Quick Reference)**
- Include only the frontmatter metadata (citekey, title, authors, year)
- Add a single-paragraph summary of the paper's contribution
- Tag with 2-3 topic tags for filtering
- Useful for references that provide supporting context but are not central to your work

**Standard Notes (Working Knowledge)**
- Include full metadata frontmatter
- Add sections for: summary, key findings, methodology, strengths, limitations
- Extract 3-5 key quotes with page references
- Link to related literature notes and concept notes
- Tag with topic, method, and status tags

**Deep Notes (Core References)**
- Include everything from standard notes plus:
- Detailed methodology breakdown with your assessment
- Figure and table descriptions with your interpretation
- Questions and ideas prompted by the paper
- Connections to your own research with specific implications
- Reading timeline notes tracking your evolving understanding

## Building a Connected Knowledge Base

**Linking Strategies**
- Link literature notes to concept notes that represent key ideas
- Create MOC (Map of Content) notes that curate references by theme
- Use tags consistently to enable cross-cutting queries
- Link literature notes to project notes where the reference is cited
- Create methodology notes that reference the papers using each method

**Dataview Integration**
- Use the Dataview plugin to create dynamic literature dashboards
- Query literature notes by tag, date, status, or any frontmatter field
- Generate reading lists filtered by topic and reading status
- Create citation frequency tables showing your most-used references
- Build project-specific reference lists from linked literature notes

**Graph View Usage**
- The Obsidian graph view shows the link structure between all notes
- Clusters of densely linked literature notes indicate research themes
- Isolated literature notes may need more connections or may be peripheral
- Hub notes (with many connections) are candidates for synthesis writing
- Use the graph to discover unexpected connections between research areas

## Multi-Tool Workflows

**Zotero to Obsidian Pipeline**
- Export from Zotero via Better BibTeX to keep the .bib file continuously updated
- The citation plugin detects changes to the .bib file automatically
- Create literature notes in Obsidian for papers annotated in Zotero
- Use Zotero for PDF management and Obsidian for knowledge synthesis
- This separation leverages the strengths of each tool

**Writing Pipeline**
- Draft manuscripts in Obsidian using Pandoc-compatible citation syntax
- Use Pandoc to compile Markdown to LaTeX, DOCX, or HTML with formatted citations
- The citation keys in your notes map directly to your bibliography file
- Generate bibliographies automatically from cited references
- This pipeline supports any citation style via CSL

## Integration with Research-Claw

This skill enhances the Research-Claw knowledge management workflow:

- Create literature notes programmatically from search results
- Build connected knowledge bases that inform writing and analysis tasks
- Enable citation insertion during AI-assisted manuscript drafting
- Connect with other Obsidian and Zotero skills for comprehensive workflows
- Support systematic review note-taking with structured templates

## Best Practices

- Keep your bibliography file in the Obsidian vault for reliable path resolution
- Use a consistent citation key format across all tools in your workflow
- Create literature notes soon after reading to capture fresh insights
- Review and update literature notes periodically as your understanding deepens
- Use templates to ensure consistent structure across all literature notes
- Back up both the bibliography file and the vault regularly
