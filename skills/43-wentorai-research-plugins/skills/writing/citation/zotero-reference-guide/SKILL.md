---
name: zotero-reference-guide
description: "PDF references add-on for enriching Zotero library metadata"
version: 1.0.0
author: wentor-community
source: https://github.com/MuiseDestiny/zotero-reference
metadata:
  openclaw:
    category: "writing"
    subcategory: "citation"
    emoji: "📖"
    keywords:
      - zotero
      - references
      - pdf-parsing
      - bibliography
      - metadata-enrichment
      - citation-linking
---

# Zotero Reference Guide

A skill for using the Zotero Reference add-on to automatically parse, link, and enrich reference lists from PDF documents within Zotero. Based on zotero-reference (3K stars), this skill streamlines the process of building comprehensive, interconnected reference libraries from the papers you read.

## Overview

When reading academic papers, the reference list at the end contains valuable connections to related work. Manually looking up and adding these references to your library is tedious and error-prone. Zotero Reference automates this by parsing the reference section of PDFs, matching references against academic databases, and offering one-click addition to your Zotero library. This transforms passive reading into active library building.

The plugin is particularly powerful for literature reviews, where you need to systematically follow citation chains, and for new researchers building their initial reference collection in a new field.

## Core Features

**Reference Parsing**
- Automatically detects and parses the reference section of PDF documents
- Extracts individual reference entries with author, title, year, and venue information
- Handles multiple reference formatting styles (numbered, author-year, footnote)
- Works with references spanning multiple columns and pages
- Identifies DOIs, arXiv IDs, and other persistent identifiers within references

**Database Matching**
- Matches parsed references against Crossref, OpenAlex, and other academic databases
- Retrieves complete metadata for matched references (abstract, keywords, citation count)
- Displays match confidence to help users verify correct identification
- Supports manual correction when automatic matching fails
- Caches lookup results to avoid redundant API calls

**Library Integration**
- One-click addition of matched references to the Zotero library
- Automatically downloads available PDFs for added references
- Places new references in the same collection as the source paper
- Creates "related" links between the source paper and its references
- Tracks which references from each paper have been added to the library

## Workflow

**Reading-Driven Library Building**
- Open a PDF in the Zotero reader
- The plugin's sidebar displays the parsed reference list
- Each reference shows its match status (matched, uncertain, unmatched)
- Click to preview metadata for any reference
- Click the add button to import the reference into your Zotero library
- Star references for later follow-up without immediate import

**Systematic Citation Chasing**
- Open a key paper in your research area
- Review all references and add the relevant ones to your library
- Open each newly added paper and repeat the process
- Continue until you reach saturation (no new relevant references found)
- The plugin tracks which papers have been processed to avoid revisiting

**Reference Verification**
- When the automatic match is uncertain, the plugin shows candidate matches
- Compare the parsed reference text with each candidate's metadata
- Select the correct match or search manually if none are correct
- For references with no database match (grey literature, old publications), manually enter metadata
- The verification status is saved to avoid repeated checking

## Advanced Features

**Batch Processing**
- Process multiple papers in a collection simultaneously
- Generate a combined reference list across all papers in a collection
- Identify the most frequently cited references across the collection
- Highlight references that appear in multiple papers (high-relevance indicators)
- Export the frequency-ranked reference list for systematic review screening

**Citation Network Visualization**
- View how papers in your library cite each other
- Identify clusters of closely related papers
- Find bridge papers connecting different research themes
- Visualize the chronological development of a research thread
- Export citation network data for analysis in external tools

**Missing Reference Detection**
- Compare your library against the complete reference lists of key papers
- Identify important references you have not yet added
- Prioritize missing references by citation frequency across your collection
- Generate reading lists from the most-cited missing references
- Track library completeness for systematic review requirements

## Handling Edge Cases

The plugin manages several common challenges:

**Malformed References**
- References with typos or formatting errors may fail to parse correctly
- The plugin highlights uncertain parses for manual review
- Users can edit the parsed text before attempting database matching
- Common formatting issues (missing year, abbreviated journal names) are handled automatically

**Preprints and Working Papers**
- arXiv papers are matched using arXiv IDs when present
- Working papers from SSRN, NBER, and similar repositories are supported
- Conference papers are matched against DBLP and ACL Anthology
- When multiple versions exist (preprint and published), the published version is preferred

**Non-English References**
- References in non-Latin scripts are handled with Unicode support
- Cross-language matching uses transliterated author names
- Database coverage varies by language (English has the best coverage)
- Manual entry is recommended for references in less-covered languages

## Integration with Research-Claw

This skill enhances the Research-Claw reference management pipeline:

- Automatically build comprehensive bibliographies while reading papers
- Feed parsed references to literature search skills for deeper exploration
- Connect with citation management skills for consistent formatting
- Support systematic review workflows with complete reference tracking
- Enable citation network analysis across the entire research project

## Best Practices

- Process reference lists from your most important papers first to build a high-quality seed library
- Always verify uncertain matches before adding to your library
- Use collections in Zotero to organize references by project or review topic
- Periodically check for updated metadata on previously added references
- Combine with Zotero's duplicate detection to keep the library clean
- Export processed reference lists as documentation for systematic review methods sections
