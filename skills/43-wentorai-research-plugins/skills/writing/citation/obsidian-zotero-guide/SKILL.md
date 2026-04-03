---
name: obsidian-zotero-guide
description: "Insert citations and notes from Zotero into Obsidian knowledge bases"
version: 1.0.0
author: wentor-community
source: https://github.com/mgmeyers/obsidian-zotero-integration
metadata:
  openclaw:
    category: "writing"
    subcategory: "citation"
    emoji: "🔗"
    keywords:
      - obsidian
      - zotero
      - citation-management
      - note-taking
      - knowledge-base
      - bibliography
---

# Obsidian-Zotero Guide

A skill for integrating Zotero reference management with Obsidian note-taking to create a seamless academic knowledge management workflow. Based on the obsidian-zotero-integration plugin (2K stars), this skill guides the agent through setting up, configuring, and optimizing the bridge between your reference library and your personal knowledge base.

## Overview

Academic researchers accumulate hundreds or thousands of papers over a career, each containing insights that need to be connected, synthesized, and retrieved when writing new work. Zotero excels at organizing references and PDFs, while Obsidian excels at creating interlinked notes and building knowledge graphs. This integration bridges the two, allowing annotations made in Zotero to flow into Obsidian as linked notes, and enabling citation insertion directly from the Obsidian editor.

The result is a unified research workflow where reading, annotating, note-taking, and writing happen in a connected ecosystem rather than in isolated tools.

## Setup and Configuration

**Prerequisites**
- Zotero 6 or 7 with the Better BibTeX plugin installed
- Obsidian with community plugins enabled
- A designated vault folder for literature notes (e.g., `references/` or `literature/`)

**Installation Steps**
- Install the Zotero Integration plugin from the Obsidian community plugins browser
- Configure the Zotero data directory path in the plugin settings
- Set up the Better BibTeX citation key format (recommended: `authYear` or `authYearTitle`)
- Define the literature note template (see Template Configuration below)
- Test the connection by inserting a citation from a known Zotero entry

**Template Configuration**
- Create a template file that defines the structure of imported literature notes
- Include frontmatter fields: citekey, authors, year, journal, DOI, tags
- Include body sections: abstract, key findings, methodology notes, personal comments
- Use Nunjucks template syntax for dynamic field insertion
- Configure annotation extraction to pull highlights and comments from PDFs

## Citation Workflow

The primary citation workflow during writing:

**Inserting Citations**
- Use the command palette or hotkey to open the Zotero citation picker
- Search by author, title, year, or tag to find the desired reference
- Insert the citation in the desired format (pandoc, LaTeX, plain text)
- The plugin creates a backlink to the corresponding literature note
- Multiple citation formats can be configured for different output targets

**Managing Literature Notes**
- Each imported Zotero entry generates a literature note in Obsidian
- Notes are named by citation key for consistent linking
- Tags from Zotero are imported as Obsidian tags for cross-referencing
- PDF annotations (highlights, comments) are extracted into structured sections
- Notes are automatically updated when Zotero metadata changes

**Building Connections**
- Link literature notes to topic notes, project notes, and concept notes
- Use Obsidian's graph view to visualize connections between references
- Create MOC (Map of Content) notes that curate papers by theme
- Track reading status with custom frontmatter fields (unread, reading, read, reviewed)
- Use dataview queries to generate dynamic reading lists and bibliographies

## Annotation Extraction

One of the most powerful features is extracting PDF annotations:

**Highlight Extraction**
- Color-coded highlights can be mapped to different note sections
- Yellow highlights for key findings, blue for methodology, green for quotes
- Each highlight includes the page number and surrounding context
- Highlights are formatted as blockquotes with source attribution
- Batch extraction processes all annotations from a paper at once

**Comment Extraction**
- Marginal comments from Zotero's PDF reader are imported alongside highlights
- Comments are distinguished from highlights with different formatting
- Time-stamped comments preserve the reading chronology
- Comments can be tagged for follow-up actions (verify, discuss, replicate)

**Image Extraction**
- Area annotations (image selections) from PDFs can be extracted
- Extracted images are saved to a designated assets folder
- Image annotations include captions from the Zotero comment field
- Useful for capturing key figures, tables, and equations from papers

## Advanced Workflows

**Systematic Review Support**
- Import entire Zotero collections as literature note sets
- Use Obsidian dataview to create screening matrices
- Track inclusion/exclusion decisions with frontmatter fields
- Generate evidence tables from structured literature notes
- Export curated collections back to Zotero for bibliography generation

**Collaborative Research**
- Share Obsidian vaults via Git for team-based literature reviews
- Merge literature notes from multiple team members
- Use consistent templates to ensure compatible note structures
- Track who added which annotations and comments

**Writing Integration**
- Use pandoc with citeproc to render citations in final documents
- Export bibliography in any CSL-supported format
- Generate reference lists directly from cited literature notes
- Support for footnote, author-date, and numeric citation styles

## Integration with Research-Claw

This skill enhances the Research-Claw reference management capabilities:

- Automate literature note creation from newly added Zotero entries
- Generate synthesis notes combining insights from multiple papers
- Suggest connections between newly imported papers and existing notes
- Help maintain consistent tagging and categorization across the library
- Assist with writing literature review sections from interlinked notes

## Best Practices

- Establish a consistent citation key format before importing any references
- Create templates before importing to avoid reformatting existing notes
- Use a dedicated folder for literature notes separate from personal notes
- Regularly sync Zotero and re-extract annotations after additional reading
- Back up the Obsidian vault before bulk import operations
- Keep literature note templates versioned to track structural changes over time
