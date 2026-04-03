---
name: zotero-pdf2zh-guide
description: "PDF Chinese translation plugin for Zotero reference manager"
version: 1.0.0
author: wentor-community
source: https://github.com/guaguastandup/zotero-pdf2zh
metadata:
  openclaw:
    category: "tools"
    subcategory: "ocr-translate"
    emoji: "🌐"
    keywords:
      - pdf-translation
      - zotero-plugin
      - chinese-translation
      - ocr
      - academic-papers
      - bilingual-reading
---

# Zotero PDF2ZH Guide

A skill for using the Zotero PDF2ZH plugin to translate academic PDF documents between Chinese and English while preserving the original layout, figures, and mathematical notation. Based on zotero-pdf2zh (3K stars), this skill enables researchers to bridge the language barrier in academic literature.

## Overview

Academic research is inherently global, yet language barriers remain a significant obstacle. Chinese-speaking researchers need to read English-language papers, and English-speaking researchers increasingly need access to Chinese-language publications, particularly in fields where China produces significant research output (materials science, AI, engineering, traditional medicine). PDF2ZH addresses this by providing high-quality translation directly within the Zotero reference management workflow, producing bilingual documents that preserve the original formatting.

The plugin supports bidirectional translation between Chinese and English, leveraging modern neural machine translation while maintaining the structural integrity of academic documents including equations, tables, figures, and references.

## Installation and Setup

**Prerequisites**
- Zotero 6 or Zotero 7 installed and configured
- An active internet connection for translation API access
- Sufficient storage for translated PDF copies (approximately 2x per document)

**Installation Steps**
- Download the latest .xpi file from the project's releases page
- In Zotero, navigate to Tools then Add-ons
- Click the gear icon and select Install Add-on From File
- Select the downloaded .xpi file and confirm installation
- Restart Zotero to activate the plugin
- Configure translation settings in the plugin preferences panel

**Configuration Options**
- Select the default translation direction (EN to ZH or ZH to EN)
- Choose the translation engine (multiple backends supported)
- Configure output format (side-by-side bilingual or translated-only)
- Set quality preferences (speed versus accuracy trade-off)
- Define custom terminology dictionaries for domain-specific terms

## Translation Workflow

**Single Document Translation**
- Right-click a PDF item in the Zotero library
- Select the PDF2ZH translation option from the context menu
- Choose the target language if different from the default
- The plugin processes the document and creates a translated copy
- The translated PDF is automatically attached to the same Zotero item
- Original and translated versions are both accessible from the item entry

**Batch Translation**
- Select multiple items in the Zotero library
- Apply translation to the entire selection
- The plugin queues documents and processes them sequentially
- Progress is displayed in the Zotero status bar
- Failed translations are flagged for manual review

**Translation Quality Features**
- Mathematical equations are detected and preserved without translation
- Figures and their captions are handled separately for better accuracy
- Tables maintain their structure with cell-level translation
- Reference lists are preserved in their original form
- Headers, footers, and page numbers are excluded from translation

## Handling Academic Content

The plugin includes special handling for academic document elements:

**Mathematical Notation**
- LaTeX-style equations are detected and excluded from translation
- Inline math symbols and variables are preserved in context
- Equation numbers and cross-references maintain their original format
- Greek letters and mathematical operators are not transliterated

**Technical Terminology**
- Domain-specific terms can be added to custom dictionaries
- The plugin supports glossary files for consistent term translation
- Ambiguous terms are handled based on the document's detected field
- Acronyms are expanded on first occurrence in the translation
- Standard academic phrases have pre-verified translations

**Figures and Tables**
- Figure labels and captions are translated while images are preserved
- Table headers and cell contents are translated maintaining structure
- Chart axis labels and legends within embedded images are not modified
- Cross-references to figures and tables maintain their numbering

## Bilingual Reading Mode

The side-by-side bilingual output is particularly useful for research:

**Layout Options**
- Parallel paragraphs: original and translation appear side by side
- Interleaved paragraphs: translation appears below each original paragraph
- Margin annotations: brief translations appear in the margin alongside originals
- Separate documents: full original and full translation as independent PDFs

**Reading Strategies**
- Use bilingual mode to learn technical vocabulary in the target language
- Reference the original when the translation of a technical passage is unclear
- Compare sentence structures to understand discipline-specific writing conventions
- Build personal glossaries from translated terms in your research area

## Domain-Specific Considerations

Translation quality varies by academic domain:

**High Accuracy Domains** - Computer science, mathematics, physics (standardized terminology)
**Medium Accuracy Domains** - Biology, chemistry, engineering (mixed standardized and specialized terms)
**Challenging Domains** - Social sciences, humanities, law (culturally embedded terminology)
**Specialized Domains** - Traditional Chinese medicine, regional studies (unique conceptual frameworks)

For challenging domains, always verify key translated terms against established bilingual dictionaries or domain experts.

## Integration with Research-Claw

This skill enhances the Research-Claw multilingual research workflow:

- Translate papers discovered through literature search skills
- Feed translated content to paper analysis skills for knowledge extraction
- Support bilingual literature reviews spanning Chinese and English sources
- Connect with citation management skills for multilingual bibliographies
- Enable cross-language comparison of research findings on the same topic

## Best Practices

- Always verify critical translations against the original, especially for methodology details
- Build and maintain domain-specific glossaries to improve translation consistency
- Use bilingual mode for important papers to catch translation nuances
- Batch-translate collection items during off-peak hours to manage API load
- Keep both original and translated versions in Zotero for reference
- Report translation errors to improve the tool's accuracy over time
