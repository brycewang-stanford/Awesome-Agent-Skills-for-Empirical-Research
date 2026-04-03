---
name: novathesis-guide
description: "LaTeX thesis template supporting multiple universities and formats"
version: 1.0.0
author: wentor-community
source: https://github.com/joaomlourenco/novathesis
metadata:
  openclaw:
    category: "writing"
    subcategory: "templates"
    emoji: "🎓"
    keywords:
      - thesis-template
      - latex-thesis
      - dissertation
      - university-formatting
      - academic-typesetting
---

# NovaThesis Guide

A skill for using and customizing the NovaThesis LaTeX thesis template, which supports formatting requirements from multiple universities worldwide. Based on the novathesis project (955 stars), this skill helps graduate students and researchers produce professionally typeset theses and dissertations that comply with institutional formatting mandates.

## Overview

Writing a thesis is a monumental academic achievement, but formatting it to meet university requirements can be frustratingly time-consuming. NovaThesis eliminates this burden by providing a single LaTeX template that adapts to the formatting requirements of dozens of universities. Students focus on their content while the template handles margins, fonts, title pages, chapter headings, bibliographies, and all the other formatting details that institutions demand.

This skill guides the agent through template selection, customization, content structuring, and troubleshooting, making the thesis writing process smoother for LaTeX beginners and experienced users alike.

## Template Selection and Setup

**Choosing the Right Configuration**
- NovaThesis supports universities across Portugal, Brazil, and other countries
- Each university configuration includes the correct title page layout, margin specifications, font requirements, and chapter formatting
- If your university is not directly supported, the generic configuration provides a solid professional base that can be customized
- Check the template repository for the most current list of supported institutions

**Initial Setup**
- Download or clone the novathesis template repository
- Open the main configuration file (typically `template.tex` or `thesis.tex`)
- Set the university and department options in the document class declaration
- Configure the degree type (MSc, PhD, or other as supported)
- Fill in metadata: title, author, supervisors, date, keywords
- Set the language (primary and optional secondary for bilingual requirements)

**Directory Structure**
- `Chapters/` - individual chapter files, one per chapter
- `Appendices/` - supplementary material files
- `Figures/` - all figure files organized by chapter
- `Bibliography/` - BibTeX database files
- `Config/` - template configuration and customization files
- Main file ties everything together with `\include` commands

## Content Organization

**Front Matter**
- Title page: automatically generated from metadata configuration
- Dedication and acknowledgments: optional pages with appropriate styling
- Abstract: in the primary language and (if required) in a secondary language
- Table of contents, list of figures, list of tables: auto-generated
- List of abbreviations and symbols: manually curated with provided macros

**Main Chapters**
- Each chapter is a separate .tex file for modular editing
- Chapter files are included in the main document in order
- Standard thesis structure: Introduction, Literature Review, Methodology, Results, Discussion, Conclusion
- The template handles chapter numbering, header formatting, and page styles automatically

**Back Matter**
- Bibliography: managed via BibTeX or BibLaTeX with university-specified citation style
- Appendices: formatted with letter-based numbering (Appendix A, B, C)
- Index: optional, auto-generated from `\index{}` commands throughout the text

## Customization

**Typography**
- Font selection: the template uses university-specified fonts when available
- Line spacing: configurable (single, 1.5, double) per university requirements
- Paragraph indentation and spacing: preset to institutional standards
- Heading styles: chapter, section, subsection formats are predefined

**Page Layout**
- Margins: set by university configuration, overridable if needed
- Header and footer: typically include chapter title and page number
- Page numbering: roman for front matter, arabic for main content
- Binding margin: adjustable for print versus digital submission

**Bibliography Styles**
- The template supports multiple bibliography backends (bibtex, biber)
- Citation styles are configured per university requirements (APA, IEEE, Chicago, Harvard, numeric)
- Multiple bibliographies per chapter are supported for some configurations
- URL and DOI formatting is handled automatically

## Common Tasks

**Adding a New Chapter**
- Create a new .tex file in the Chapters directory
- Add the `\include{Chapters/newchapter}` command in the main file
- The chapter will automatically receive the correct formatting and numbering
- Cross-references to the new chapter work immediately with `\label` and `\ref`

**Managing Figures**
- Store figures in the Figures directory, organized by chapter
- Use `\includegraphics` with relative paths from the main file
- The template provides figure environments with proper caption placement
- For subfigures, use the `subcaption` package (included in the template)
- Ensure figures are referenced in the text before they appear

**Handling References**
- Add entries to your .bib file using standard BibTeX format
- Use `\cite{}`, `\citep{}`, or `\citet{}` depending on the required citation style
- The template configuration determines how citations are formatted in text and in the bibliography
- Run the full compilation chain (LaTeX, BibTeX/Biber, LaTeX, LaTeX) for correct references

**Bilingual Thesis**
- Set both primary and secondary languages in the configuration
- Provide abstracts in both languages using the designated environments
- Keywords can be provided in both languages
- Chapter titles can optionally be provided in both languages for the table of contents

## Troubleshooting

**Common Compilation Issues**
- Missing packages: install from your TeX distribution (TeX Live, MiKTeX)
- Bibliography not appearing: ensure bibtex/biber is run in the compilation chain
- Figures not found: check file paths relative to the main .tex file location
- Encoding issues: ensure all files use UTF-8 encoding
- Undefined references: run LaTeX twice after adding new labels

**Formatting Overrides**
- When university requirements conflict with template defaults, use the configuration file to override
- Document any custom overrides for future maintenance
- Check with your university's thesis office before making significant formatting changes
- Some universities provide LaTeX support staff who can help with template customization

## Integration with Research-Claw

This skill supports the Research-Claw thesis writing workflow:

- Generate chapter drafts using composition skills and insert into the template
- Manage references using citation skills connected to Zotero
- Create figures using LaTeX drawing skills or export from analysis tools
- Use paper review skills to debug the thesis before submission
- Track writing progress with section-level word counts and completion status

## Best Practices

- Start using the template early in the writing process, not at the end
- Compile frequently to catch formatting issues as they arise
- Use version control (Git) for the entire thesis directory
- Keep a backup of the template's original configuration before customizing
- Write one chapter at a time in separate files for manageable editing
- Consult your university's thesis formatting guidelines alongside the template documentation
