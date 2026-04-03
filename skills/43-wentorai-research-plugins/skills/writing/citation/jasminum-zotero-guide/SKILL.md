---
name: jasminum-zotero-guide
description: "Guide to Jasminum for retrieving CNKI Chinese academic metadata in Zotero"
metadata:
  openclaw:
    emoji: "🌸"
    category: "writing"
    subcategory: "citation"
    keywords: ["zotero", "cnki", "chinese-academic", "jasminum", "metadata", "bibliography"]
    source: "https://github.com/l0o0/jasminum"
---

# Jasminum Zotero Guide

## Overview

Jasminum is a Zotero plugin with over 7,000 GitHub stars, specifically designed to enhance Zotero's capabilities for working with Chinese academic literature. Named after the jasmine flower, the plugin bridges the gap between Zotero's predominantly Western academic database integrations and the vast Chinese academic ecosystem centered around CNKI (China National Knowledge Infrastructure).

Chinese academic databases like CNKI, Wanfang, and CQVIP contain millions of papers, theses, and conference proceedings that are often poorly indexed by Western reference management tools. When researchers add PDFs from these sources to Zotero, the metadata is frequently incomplete, incorrectly encoded, or entirely missing. Jasminum solves this by providing direct metadata retrieval from CNKI, automatic filename parsing for Chinese PDFs, and proper handling of Chinese author names and institutional affiliations.

For researchers who work with both Chinese and English academic literature, or for any scholar studying China-related topics across social sciences, humanities, or STEM fields, Jasminum is an indispensable addition to Zotero. It ensures that Chinese-language references receive the same quality of bibliographic management as their English counterparts.

## Installation and Setup

Install Jasminum through the Zotero add-on system:

1. Download the latest `.xpi` file from https://github.com/l0o0/jasminum/releases
2. In Zotero, navigate to Tools > Add-ons > gear icon > Install Add-on From File
3. Select the `.xpi` file and restart Zotero

Post-installation configuration:

- Open Zotero Preferences > Jasminum
- Configure CNKI access settings:
  - If you have institutional CNKI access, the plugin will use your authenticated browser session
  - For direct API access, ensure your network can reach CNKI servers
- Set Chinese name splitting preferences (important for proper author formatting):
  - Enable automatic splitting of Chinese full names into family and given name fields
  - Configure the name order convention (family-given for Chinese entries)
- Set default language detection behavior
- Configure PDF filename parsing rules for Chinese academic PDFs

Additional recommended settings:

- Enable automatic metadata retrieval when Chinese PDFs are imported
- Configure duplicate detection to handle Chinese character variants
- Set up proper encoding for BibTeX export of Chinese entries (UTF-8 recommended)

## Core Features

**CNKI Metadata Retrieval**: The flagship feature of Jasminum. Select one or more items in your Zotero library that were imported from Chinese databases, right-click, and choose "Retrieve CNKI Metadata." The plugin searches CNKI for matching entries and populates all available bibliographic fields including title, authors, abstract, keywords, journal name, volume, issue, pages, and DOI.

**Chinese PDF Filename Parsing**: Chinese academic PDFs often have filenames that encode bibliographic information in specific formats (e.g., `title_author_journal_year.pdf`). Jasminum can parse these filenames and create properly structured Zotero items automatically, saving significant manual data entry.

**Author Name Handling**: Chinese personal names follow different conventions than Western names. Jasminum correctly handles:
- Splitting full Chinese names into family name and given name
- Maintaining proper name order in citations and bibliographies
- Handling pinyin romanization alongside Chinese characters
- Managing names that appear in both Chinese and English formats

**Bookmark and TOC Integration**: For Chinese theses and book chapters imported as PDFs, Jasminum can extract table-of-contents bookmarks and structure them as Zotero note attachments, improving navigation of long documents.

**Batch Processing**: Process an entire collection of Chinese academic PDFs at once. Jasminum will attempt to retrieve metadata for all items, report successes and failures, and allow you to review and correct matches before applying metadata updates.

**CNKI Citation Export**: Export citations in formats compatible with Chinese academic submission requirements, including the GB/T 7714 citation standard used by Chinese journals.

## Academic Workflow for Bilingual Researchers

**Importing Chinese Literature**:
1. Download PDFs from CNKI, Wanfang, or other Chinese databases
2. Drag PDFs into your Zotero library
3. Select the imported items and run Jasminum metadata retrieval
4. Review the matched metadata and confirm updates
5. Verify author names are correctly split and formatted

**Managing Bilingual Collections**:
- Use Zotero tags to mark language (e.g., `lang:zh`, `lang:en`) for filtering
- Create parallel collection structures for Chinese and English literature on the same topic
- Use Jasminum's name handling to ensure Chinese authors appear correctly in both Chinese and English citation styles

**Writing with Chinese References**:
- Configure your citation style to handle Chinese references according to GB/T 7714 when writing for Chinese journals
- Use Better BibTeX alongside Jasminum for LaTeX documents that include Chinese references
- Ensure your LaTeX setup supports CJK characters (XeLaTeX or LuaLaTeX recommended)

**Thesis and Dissertation Work**:
- Import Chinese thesis PDFs and use Jasminum to extract structured metadata
- Use the bookmark extraction feature to navigate long thesis documents
- Build annotated bibliographies that properly represent both Chinese and English sources

**Common Issues and Solutions**:
- If CNKI metadata retrieval fails, check your network connection to CNKI servers
- For papers not found on CNKI, try searching with different title variants
- When author names are incorrectly split, manually adjust and Jasminum will learn the pattern
- For older papers with poor digital records, manual metadata entry may still be necessary

## References

- GitHub Repository: https://github.com/l0o0/jasminum
- CNKI (China National Knowledge Infrastructure): https://www.cnki.net
- Zotero Plugin Directory: https://www.zotero.org/support/plugins
- GB/T 7714 Citation Standard: https://std.samr.gov.cn
- Zotero Chinese User Community: https://zotero-chinese.com
