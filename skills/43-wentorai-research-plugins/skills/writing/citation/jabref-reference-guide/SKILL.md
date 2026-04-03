---
name: jabref-reference-guide
description: "Guide to JabRef open-source BibTeX and BibLaTeX reference manager"
metadata:
  openclaw:
    emoji: "📖"
    category: "writing"
    subcategory: "citation"
    keywords: ["jabref", "bibtex", "biblatex", "reference-manager", "latex", "bibliography"]
    source: "https://github.com/JabRef/jabref"
---

# JabRef Reference Manager Guide

## Overview

JabRef is an open-source, cross-platform reference manager with over 4,000 GitHub stars, specifically designed for researchers who work with BibTeX and BibLaTeX bibliographies. Written in Java, it runs on Windows, macOS, and Linux, providing a graphical interface for managing bibliographic databases that integrates seamlessly with LaTeX-based writing workflows.

Unlike general-purpose reference managers that treat BibTeX export as an afterthought, JabRef is built from the ground up around the BibTeX format. Every feature, from the entry editor to the search system, understands BibTeX entry types and field semantics natively. This means researchers who write primarily in LaTeX get a tool that speaks their language without the impedance mismatch of converting between proprietary formats.

JabRef supports both BibTeX and BibLaTeX formats, handles cross-references, string constants, and preambles, and provides powerful tools for maintaining bibliography quality. It can fetch metadata from online databases, check entries for completeness, detect duplicates, and generate citation keys following customizable patterns. For researchers who prefer to keep their bibliographic data in plain-text BibTeX files under version control, JabRef is the reference manager of choice.

## Installation and Setup

JabRef can be installed through multiple methods:

**Direct Download**:
1. Visit https://www.jabref.org and download the installer for your platform
2. Run the installer and follow the setup wizard
3. Launch JabRef and create a new BibTeX or BibLaTeX database

**Package Managers**:
- macOS: `brew install --cask jabref`
- Linux (Snap): `sudo snap install jabref`
- Linux (Flatpak): `flatpak install org.jabref.jabref`
- Windows: `winget install JabRef.JabRef`

**Initial Configuration**:
- Go to Options > Preferences > General
- Set your default bibliography mode (BibTeX or BibLaTeX)
- Configure the default encoding (UTF-8 recommended)
- Set up the citation key generator pattern under Preferences > Citation Key Generator:
  - Default: `[auth][year]` produces keys like `Smith2024`
  - Custom example: `[auth:lower][year][veryshorttitle:lower]` produces `smith2024deep`
- Configure external tool integration:
  - Set your LaTeX editor path for push-to-editor functionality
  - Configure your PDF viewer for opening attachments
  - Set up the external file directory for organizing linked PDFs

## Core Features

**Entry Management**: JabRef provides a table view and an entry editor for managing bibliography entries. The entry editor shows all fields relevant to the selected entry type (article, book, inproceedings, etc.) and validates field content against BibTeX specifications.

**Online Database Search**: Search and import references from multiple academic databases directly within JabRef:
- CrossRef for DOI-based metadata
- Google Scholar for broad academic search
- IEEE Xplore for engineering and computer science
- arXiv for preprints
- DBLP for computer science bibliography
- Springer and other publisher databases
- ISBN lookup for books
- INSPIRE-HEP for high-energy physics

**Duplicate Detection**: JabRef identifies potential duplicate entries using configurable similarity algorithms that compare titles, authors, years, and other fields. The merge dialog allows you to combine duplicates while preserving the most complete metadata from each entry.

**Group Management**: Organize entries into hierarchical groups based on:
- Manual assignment (drag and drop)
- Keyword matching (automatic based on BibTeX keywords field)
- Search expressions (dynamic groups based on field content)
- Referenced entries (cross-reference chains)

**Quality Checks**: Run integrity checks on your database to identify:
- Missing required fields for each entry type
- Inconsistent formatting (e.g., mixed abbreviation styles for journal names)
- Broken file links to PDFs or other attachments
- Invalid DOIs, ISBNs, or other identifiers
- Entries without citation keys

**Push to Editor**: Send citation commands directly to your LaTeX editor. JabRef supports integration with:
- TeXstudio, TeXmaker, and other LaTeX editors
- Vim and Emacs with LaTeX plugins
- VS Code with LaTeX Workshop extension
- LyX document processor

## LaTeX Writing Workflow

**Setting Up a Project Bibliography**:
1. Create a new `.bib` file in your LaTeX project directory
2. Open it in JabRef as your working database
3. Add references through online search, DOI import, or manual entry
4. JabRef automatically saves changes to the `.bib` file
5. Reference the file in your LaTeX document with `\bibliography{references}` or `\addbibresource{references.bib}`

**Collaborative Writing**:
- Store your `.bib` file in a Git repository alongside your LaTeX source
- JabRef's plain-text BibTeX format is diff-friendly and merge-friendly
- Use consistent citation key patterns across collaborators to avoid conflicts
- JabRef's cleanup tools help normalize entries contributed by different team members

**Integration with Overleaf**:
- Export your JabRef database as a `.bib` file
- Upload to your Overleaf project or link via Git
- Use JabRef locally for curation and Overleaf for collaborative editing

**Journal Submission Preparation**:
1. Run JabRef's integrity checks to ensure all entries are complete
2. Use the "Find unlinked files" feature to attach any missing PDFs
3. Verify journal name abbreviations match the target journal's requirements
4. Export the final bibliography in the format required by the submission system

## Advanced Features

**Custom Entry Types**: Define custom BibTeX entry types for specialized references not covered by the standard types. This is useful for datasets, software, standards documents, and other non-traditional academic sources.

**Journal Abbreviation Management**: JabRef includes a comprehensive database of journal name abbreviations. Configure automatic abbreviation or expansion of journal names to match specific publisher requirements.

**String Constants**: Use BibTeX string constants to define frequently used values (journal names, publisher details, conference series names) once and reference them throughout your database. This ensures consistency and simplifies bulk updates.

**Web Search Customization**: Configure custom web search providers or API endpoints for specialized databases relevant to your field.

## References

- Official Website: https://www.jabref.org
- GitHub Repository: https://github.com/JabRef/jabref
- JabRef User Documentation: https://docs.jabref.org
- JabRef Blog: https://blog.jabref.org
- CTAN BibTeX Documentation: https://ctan.org/pkg/bibtex
