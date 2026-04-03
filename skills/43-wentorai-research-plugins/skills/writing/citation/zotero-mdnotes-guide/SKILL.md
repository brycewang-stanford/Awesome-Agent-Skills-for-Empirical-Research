---
name: zotero-mdnotes-guide
description: "Export Zotero items and annotations to Markdown note files"
version: 1.0.0
author: wentor-community
source: https://github.com/argenos/zotero-mdnotes
metadata:
  openclaw:
    category: "writing"
    subcategory: "citation"
    emoji: "📝"
    keywords:
      - zotero
      - markdown
      - note-export
      - annotations
      - knowledge-management
      - literature-notes
---

# Zotero MDNotes Guide

A skill for exporting Zotero items, annotations, and notes to structured Markdown files for use in knowledge management systems like Obsidian, Logseq, or plain Markdown workflows. Based on zotero-mdnotes (1K stars), this skill creates a bridge between your reference library and your personal knowledge base.

## Overview

Zotero is excellent for managing references and reading PDFs, but its note-taking capabilities are limited compared to dedicated knowledge management tools. MDNotes solves this by exporting Zotero data to Markdown files that can be used in any Markdown-compatible system. Each exported file contains bibliographic metadata, your annotations, and your notes in a structured, interlinked format.

This approach gives researchers the best of both worlds: Zotero's powerful reference management with the flexibility and interconnection capabilities of Markdown-based knowledge systems.

## Configuration

**Template System**
- MDNotes uses Nunjucks-based templates to control the output format
- Default templates produce well-structured Markdown with YAML frontmatter
- Templates can be customized to match your preferred note structure
- Separate templates exist for item metadata, annotations, and combined notes
- Template variables provide access to all Zotero metadata fields

**Key Configuration Options**
- Output directory: where exported Markdown files are saved
- File naming convention: citation key, title, or custom pattern
- Frontmatter fields: which metadata fields to include in YAML header
- Annotation grouping: by color, type, page, or section
- Link format: wiki-links, Markdown links, or plain text references

**Frontmatter Configuration**
- Title, authors, year, journal, DOI are standard frontmatter fields
- Tags from Zotero are converted to note tags
- Custom fields can be added (read status, rating, project association)
- Zotero item key is included for bidirectional linking
- Date fields use ISO 8601 format for consistent sorting

## Export Workflows

**Single Item Export**
- Right-click a Zotero item and select the MDNotes export option
- Choose between metadata only, annotations only, or combined export
- The plugin generates the Markdown file in the configured output directory
- If a file with the same name exists, choose to overwrite or create a new version
- The exported file opens automatically in the configured editor (optional)

**Batch Export**
- Select multiple items or an entire collection in Zotero
- Apply export to the full selection
- Each item generates its own Markdown file
- A summary index file can optionally be generated listing all exported items
- Batch exports respect the same templates and configuration as single exports

**Annotation Export**
- PDF highlights are exported with their color, page number, and surrounding text
- Comments attached to highlights are included as sub-items
- Free-text notes from the Zotero note editor are exported as separate sections
- Annotations are grouped according to the configured strategy (color, page, etc.)
- Each annotation includes a link back to the specific PDF location in Zotero

## Template Customization

**Metadata Template**
- Controls the structure of the bibliographic information section
- Standard fields: title, authors, year, journal, volume, pages, DOI, URL
- Extended fields: abstract, keywords, collection path, date added
- Custom fields: any Zotero extra field data
- The template determines the order and formatting of each field

**Annotation Template**
- Controls how individual annotations are formatted
- Color mapping: assign semantic meaning to highlight colors (yellow for key findings, blue for methodology, etc.)
- Include or exclude the page number, annotation date, and comment
- Format as blockquotes, bullet points, or plain text
- Group by color to create thematic sections automatically

**Combined Template**
- Merges metadata and annotations into a single cohesive note
- Includes section headings for clear structure
- Adds a personal notes section at the bottom for your own synthesis
- Includes a placeholder for connections to other notes
- Provides a reading status field for tracking progress

## Knowledge Management Integration

**Obsidian Integration**
- Export to the Obsidian vault's literature notes folder
- Use wiki-link format for interoperability with Obsidian's linking system
- Tags are formatted as Obsidian-compatible hashtags
- Dataview-compatible frontmatter enables dynamic queries
- Graph view shows connections between literature notes and your other notes

**Logseq Integration**
- Export in Logseq-compatible Markdown format
- Use page references for linking between notes
- Properties block replaces YAML frontmatter for Logseq compatibility
- Block-level references are supported for granular linking
- Journal page references connect reading dates to daily notes

**Plain Markdown Workflows**
- Export to any directory for use with any Markdown editor
- Standard Markdown formatting ensures compatibility
- Frontmatter follows common conventions for static site generators
- Links use standard Markdown link syntax for maximum portability
- Files are self-contained with no external dependencies

## Advanced Usage

**Selective Field Export**
- Configure which Zotero fields are exported to reduce noise
- Create focused templates for different project needs
- Academic fields: include abstract, methodology tags, dataset references
- Reading group fields: include discussion questions, presenter notes
- Writing project fields: include relevance score, key quotes, argument position

**Incremental Updates**
- Re-export items after adding new annotations
- The plugin can append new annotations or regenerate the full file
- Track changes between exports using version control
- Maintain a changelog of reading progress through dated annotations
- Sync exported files across devices using standard file sync tools

**Custom Post-Processing**
- Apply regex transformations to exported files
- Add custom metadata computed from Zotero fields
- Generate index files grouping exports by tag, year, or author
- Create citation graph files from the exported reference data
- Format exports for specific publishing pipelines

## Integration with Research-Claw

This skill connects with the Research-Claw knowledge management workflow:

- Export Zotero annotations as the first step in building literature reviews
- Feed exported notes to synthesis and writing skills
- Connect with other citation skills for a complete reference workflow
- Use exported metadata for bibliometric analysis
- Store exported notes in the Research-Claw knowledge base for agent access

## Best Practices

- Establish your template before exporting in bulk to avoid reformatting later
- Use a consistent color scheme for annotations across all papers
- Export promptly after reading to capture your fresh understanding
- Include a personal synthesis section in each literature note beyond just annotations
- Use tags consistently to enable useful filtering and grouping
- Back up both Zotero and the exported notes directory regularly
