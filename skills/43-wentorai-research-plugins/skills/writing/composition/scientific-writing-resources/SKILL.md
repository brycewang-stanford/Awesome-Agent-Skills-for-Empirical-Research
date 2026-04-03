---
name: scientific-writing-resources
description: "Curated tools and resources for effective scientific writing"
version: 1.0.0
author: wentor-community
source: https://github.com/writing-resources/awesome-scientific-writing
metadata:
  openclaw:
    category: "writing"
    subcategory: "composition"
    emoji: "✍️"
    keywords:
      - scientific-writing
      - writing-tools
      - academic-style
      - manuscript-preparation
      - writing-resources
      - prose-quality
---

# Scientific Writing Resources

A skill providing curated tools, techniques, and resources for producing clear, effective scientific writing. Based on awesome-scientific-writing (920 stars), this skill equips the agent with knowledge of the best available tools for each stage of the scientific writing process, from initial drafting through final publication.

## Overview

Scientific writing is a specialized craft that demands clarity, precision, and adherence to disciplinary conventions. Unlike creative writing, scientific writing prioritizes unambiguous communication of methods, results, and reasoning. This skill catalogs and guides the use of tools that support every phase of scientific manuscript preparation, including writing environments, grammar and style checkers, reference managers, collaboration tools, and publishing pipelines.

The resources are organized by workflow stage, making it easy to find the right tool for the task at hand, whether you are outlining a new paper, polishing prose, managing references, or preparing the final submission.

## Writing Environments

**Markdown-Based Workflows**
- Markdown provides a lightweight syntax that separates content from formatting
- Pandoc converts Markdown to LaTeX, DOCX, HTML, and other formats
- R Markdown and Quarto integrate code execution with narrative text
- Typora, Zettlr, and Mark Text offer WYSIWYG Markdown editing
- Markdown source files work well with version control systems

**LaTeX Workflows**
- LaTeX remains the standard for mathematics-heavy disciplines
- Overleaf provides collaborative online LaTeX editing with real-time preview
- VS Code with LaTeX Workshop extension offers a powerful local environment
- TeXstudio and TeXmaker provide dedicated LaTeX IDEs with syntax highlighting
- LyX offers a document processor front-end for LaTeX for those who prefer visual editing

**Hybrid Approaches**
- Quarto combines Markdown simplicity with LaTeX power for technical content
- Jupyter notebooks support narrative text alongside executable code
- Org-mode in Emacs provides a comprehensive writing and computing environment
- Typst is an emerging alternative to LaTeX with a more approachable syntax
- Each approach has trade-offs between ease of use and formatting control

## Grammar and Style Tools

**Automated Checking**
- LanguageTool: open-source grammar, style, and spell checker with academic English support
- Vale: prose linter that enforces writing style guides (Microsoft, Google, academic custom)
- textlint: pluggable text linting framework with rules for technical writing
- write-good: naive linter for English prose focusing on common writing issues
- proselint: linter for prose that checks for jargon, cliches, and logical errors

**Style Guides for Science**
- APA Publication Manual: standard for social sciences
- Chicago Manual of Style: comprehensive general reference
- ACS Style Guide: standard for chemistry publications
- IEEE Editorial Style Manual: standard for engineering and computer science
- Nature's guide for authors: concise scientific style reference

**Common Issues to Check**
- Passive voice overuse (acceptable in methods, discouraged elsewhere)
- Nominalizations that obscure the actor and action
- Hedging language that weakens claims unnecessarily
- Jargon used without definition
- Overly long sentences that exceed 30-40 words
- Dangling modifiers and unclear pronoun references
- Inconsistent terminology for the same concept

## Reference Management

**Reference Managers**
- Zotero: free, open-source, with extensive plugin ecosystem
- Mendeley: integrated with Elsevier databases, PDF annotation support
- EndNote: industry standard with deep Word integration
- JabRef: open-source, BibTeX-native reference manager
- Paperpile: lightweight, Google Docs and browser integration

**Citation Processing**
- citeproc: processes citations in any of 10,000+ CSL styles
- BibTeX and BibLaTeX: standard bibliography processing for LaTeX
- Pandoc-citeproc: citation processing integrated with Pandoc conversion
- Citation Style Language (CSL): open standard for citation formatting
- Better BibTeX for Zotero: enhanced BibTeX export with stable citation keys

## Collaboration Tools

**Real-Time Collaboration**
- Overleaf: collaborative LaTeX editing with track changes and comments
- Google Docs: real-time editing with suggestion mode (export to Markdown via add-ons)
- HackMD: collaborative Markdown editing with real-time sync
- Notion: team workspace with Markdown support and database features
- Git-based workflows: asynchronous collaboration with pull requests and code review tools

**Review and Feedback**
- Track changes in Word or LibreOffice for traditional review workflows
- Git diff for line-level change tracking in plain text documents
- Hypothes.is for web-based annotation and discussion of shared documents
- Review tools built into Overleaf for inline commenting
- Dedicated peer review platforms for pre-submission feedback

## Publishing Pipeline

**Manuscript Preparation**
- Pandoc: universal document converter supporting dozens of formats
- LaTeXmk: automated LaTeX compilation with dependency tracking
- Make or Snakemake: build systems for complex multi-step publishing workflows
- Docker containers for reproducible compilation environments
- Continuous integration for automated builds on every commit

**Preprint and Open Access**
- arXiv: preprint server for physics, math, CS, and quantitative fields
- bioRxiv and medRxiv: preprint servers for biology and medical sciences
- SSRN: preprint server for social sciences and humanities
- Zenodo: general-purpose open-access repository with DOI assignment
- OSF Preprints: multidisciplinary preprint server with project integration

**Reproducibility Tools**
- Quarto and R Markdown: executable manuscripts with embedded analysis
- Jupyter Book: publishable documents from Jupyter notebooks
- Binder: shareable computational environments for reproducible analyses
- Code Ocean: computational reproducibility platform with capsules
- Papers with Code: linking publications to their implementation code

## Integration with Research-Claw

This skill provides the Research-Claw agent with comprehensive writing tool knowledge:

- Recommend appropriate tools based on the researcher's discipline and preferences
- Guide tool installation and configuration for academic writing workflows
- Suggest style improvements based on target journal conventions
- Help set up reproducible document compilation pipelines
- Connect with other writing skills for end-to-end manuscript preparation

## Best Practices

- Choose your writing environment early in the project and stick with it
- Use version control for all manuscript files, even Word documents (via Git LFS)
- Set up automated grammar and style checking as part of your writing routine
- Maintain a single source of truth for references to avoid duplication
- Test your document compilation pipeline before the submission deadline
- Keep formatting simple during drafting and apply journal styles only at the end
- Write in short, focused sessions rather than marathon writing blocks
