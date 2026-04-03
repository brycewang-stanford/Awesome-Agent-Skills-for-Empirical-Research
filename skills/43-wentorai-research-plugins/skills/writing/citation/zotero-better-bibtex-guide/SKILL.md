---
name: zotero-better-bibtex-guide
description: "Guide to Better BibTeX for Zotero for LaTeX and BibTeX workflows"
metadata:
  openclaw:
    emoji: "📚"
    category: "writing"
    subcategory: "citation"
    keywords: ["zotero", "bibtex", "latex", "citation-keys", "better-bibtex", "bibliography"]
    source: "https://github.com/retorquere/zotero-better-bibtex"
---

# Better BibTeX for Zotero Guide

## Overview

Better BibTeX (BBT) is an essential Zotero plugin for any researcher who uses LaTeX, BibTeX, or BibLaTeX for academic writing. With over 6,000 GitHub stars, it bridges the gap between Zotero's powerful reference management and the precise citation requirements of LaTeX-based document preparation systems.

The core problem BBT solves is citation key management. Standard Zotero export generates citation keys that can change unpredictably when library items are modified, breaking references in LaTeX documents. Better BibTeX provides stable, customizable citation keys that remain consistent across exports, ensuring your LaTeX documents always compile correctly with up-to-date bibliographic data.

Beyond citation keys, BBT offers superior BibTeX and BibLaTeX export with fine-grained control over field mapping, character encoding, and format compliance. It supports automatic export that keeps your `.bib` files synchronized with your Zotero library in real time, eliminating the manual export step from the writing workflow entirely.

## Installation and Setup

Install Better BibTeX through Zotero's add-on mechanism:

1. Download the latest `.xpi` file from https://github.com/retorquere/zotero-better-bibtex/releases
2. In Zotero, go to Tools > Add-ons > gear icon > Install Add-on From File
3. Select the downloaded `.xpi` file and restart Zotero
4. On first launch after installation, BBT will scan your library and generate citation keys

Configure citation key generation:

- Open Zotero Preferences > Better BibTeX > Citation Keys
- Set the citation key formula (default is `auth.lower + year`):
  - `auth.lower + year` produces keys like `smith2024`
  - `authEtal2.lower + year` produces `smithjones2024` or `smithetal2024`
  - `auth.lower + shorttitle(3,3) + year` produces `smith.wor.thr.2024`
- Enable "Keep citation keys unique" to automatically resolve conflicts
- Choose conflict resolution strategy (postfix with letter, number, etc.)

Configure export settings:

- Go to Preferences > Better BibTeX > Export
- Select your preferred export format (BibLaTeX recommended for modern setups)
- Configure field mapping for custom fields
- Set Unicode handling (recommended: convert to LaTeX commands for maximum compatibility)
- Enable "Automatic export" to keep `.bib` files synchronized

## Core Features

**Stable Citation Keys**: BBT generates predictable citation keys based on configurable patterns. Once a key is assigned, it remains stable even when you edit item metadata. You can also pin specific citation keys to override the automatic generation when needed.

**Citation Key Formulas**: The formula system is highly flexible:

| Formula | Example Output | Use Case |
|---------|---------------|----------|
| `auth.lower + year` | `smith2024` | Simple, common convention |
| `auth.lower + journal.abbr + year` | `smithnature2024` | Disambiguate by journal |
| `auth.lower + shorttitle(1,1) + year` | `smith.deep.2024` | Include title fragment |
| `auth(2).lower + year` | `smjo2024` | Short keys, multiple authors |

**Automatic Export**: Set up a Zotero collection or your entire library to automatically export to a `.bib` file whenever changes are made. This means your LaTeX project always has access to the latest bibliography data without manual intervention.

To set up automatic export:
1. Right-click a collection in Zotero
2. Select "Export Collection"
3. Choose "Better BibTeX" or "Better BibLaTeX" format
4. Check "Keep updated" to enable auto-sync
5. Choose the target file path (typically in your LaTeX project directory)

**Pull Export via HTTP**: BBT runs a local HTTP server that serves your bibliography on demand. Configure your LaTeX build system to pull the latest `.bib` file from `http://127.0.0.1:23119/better-bibtex/export/collection?...` before each compilation.

**Quality Reports**: BBT checks your bibliography entries for common issues such as missing fields, encoding problems, and duplicate entries. Review the quality report to ensure your bibliography meets journal submission standards.

**Drag-and-Drop Citations**: Drag items from Zotero into your text editor to insert formatted citation commands. BBT supports multiple formats including `\cite{key}`, `\autocite{key}`, `\textcite{key}`, and Pandoc-style `[@key]`.

## LaTeX Integration Workflow

**Project Setup**:
1. Create a Zotero collection for your paper or project
2. Set up automatic export to a `.bib` file in your LaTeX project directory
3. Add `\bibliography{references}` or `\addbibresource{references.bib}` to your LaTeX document
4. Use `\cite{citekey}` commands throughout your document

**Working with Overleaf**: If using Overleaf, set up a periodic manual export or use the pull export feature with a build script that fetches the latest bibliography before uploading. Some researchers maintain a Git repository that includes both the LaTeX source and the auto-exported `.bib` file.

**Multi-Author Projects**: For collaborative projects, establish a shared Zotero group library with BBT configured consistently across all collaborators. Agree on a citation key formula so that keys are predictable regardless of who adds the reference.

**Handling Key Conflicts**: When two papers produce the same citation key (e.g., two Smith 2024 papers), BBT automatically appends a disambiguation suffix. You can manually pin a specific key by right-clicking an item and selecting "Better BibTeX > Pin citation key."

**Integration with Reference Checkers**: Use BBT's quality reports alongside tools like `biber --validate-datamodel` to ensure your bibliography is complete and well-formed before journal submission.

## Troubleshooting

**Export File Not Updating**: Verify that automatic export is enabled for the collection. Check the BBT debug log (Help > Better BibTeX Debug Log) for export errors. Ensure the target directory is writable.

**Unicode Characters in Keys**: If citation keys contain unexpected characters, review your key formula. Use `.fold` in the formula to transliterate Unicode characters to ASCII equivalents.

**Large Library Performance**: For libraries with thousands of items, the initial citation key generation may take several minutes. Subsequent operations are incremental and fast. Consider disabling automatic export for very large collections and using scheduled exports instead.

## References

- GitHub Repository: https://github.com/retorquere/zotero-better-bibtex
- BBT Documentation: https://retorque.re/zotero-better-bibtex/
- Citation Key Formulas: https://retorque.re/zotero-better-bibtex/citing/
- Zotero Plugin Directory: https://www.zotero.org/support/plugins
