---
name: large-document-reader
description: "Split and read long documents chapter-by-chapter for structured analysis"
metadata:
  openclaw:
    emoji: "📖"
    category: "tools"
    subcategory: "document"
    keywords: ["document reading", "chunking", "long document", "chapter splitting", "structured reading"]
    source: "wentor-research-plugins"
---

# Large Document Reader

Split long documents (books, reports, theses, legal filings, technical manuals) into structured chapters or sections for systematic, chapter-by-chapter reading and analysis within LLM context windows.

## Overview

Large Language Models have finite context windows, and even models with 100K+ token limits can lose accuracy on information buried in the middle of very long inputs. Academic researchers frequently work with documents that exceed practical context limits: doctoral theses (200+ pages), government reports, book-length monographs, legal case compilations, and multi-volume technical standards.

This skill provides a systematic approach to splitting large documents into semantically meaningful chapters or sections, maintaining cross-references between parts, and reading each section with full comprehension. Rather than naive fixed-size chunking that breaks mid-sentence or mid-argument, this approach respects document structure -- headings, chapter breaks, section markers, and logical boundaries.

The result is a structured reading experience where each chapter is analyzed in full context, summaries are maintained across sessions, and the reader can navigate directly to any section of interest. This is especially valuable for literature reviews, systematic reviews, and comprehensive document analysis tasks.

## Document Splitting Strategy

### Hierarchy of Split Points

Documents should be split at the highest-level structural boundary that keeps each chunk within the target size:

| Priority | Boundary Type | Markers |
|----------|--------------|---------|
| 1 | Part/Volume | `PART I`, `Volume 2`, page breaks with Roman numerals |
| 2 | Chapter | `Chapter 1`, `CHAPTER`, numbered headings level 1 |
| 3 | Section | `1.1`, `Section`, headings level 2 |
| 4 | Subsection | `1.1.1`, headings level 3 |
| 5 | Paragraph break | Double newline, indentation change |
| 6 | Sentence boundary | Period + space + capital letter |

### Splitting Algorithm

```python
def split_document(text, max_tokens=8000, overlap_tokens=200):
    """Split document respecting structural boundaries."""
    # Step 1: Detect document structure
    chapters = detect_chapters(text)

    if not chapters:
        # Fallback: split by sections
        chapters = detect_sections(text)

    if not chapters:
        # Fallback: split by paragraphs with size limit
        chapters = split_by_paragraphs(text, max_tokens)

    # Step 2: Merge small adjacent sections
    merged = merge_small_sections(chapters, min_tokens=500)

    # Step 3: Split oversized sections
    final = []
    for chapter in merged:
        if count_tokens(chapter.text) > max_tokens:
            sub_parts = split_by_paragraphs(chapter.text, max_tokens)
            for i, part in enumerate(sub_parts):
                final.append(Section(
                    title=f"{chapter.title} (Part {i+1})",
                    text=part,
                    index=len(final)
                ))
        else:
            chapter.index = len(final)
            final.append(chapter)

    # Step 4: Add overlap for continuity
    for i in range(1, len(final)):
        final[i].context_prefix = get_last_n_tokens(
            final[i-1].text, overlap_tokens
        )

    return final
```

### Structure Detection Patterns

```python
import re

CHAPTER_PATTERNS = [
    r'^#{1,2}\s+.+',                          # Markdown H1/H2
    r'^Chapter\s+\d+',                         # "Chapter 1"
    r'^\d+\.\s+[A-Z]',                        # "1. Introduction"
    r'^PART\s+[IVX]+',                         # "PART III"
    r'^\\(chapter|section)\{',                 # LaTeX commands
    r'^\f',                                    # Form feed (page break)
]

def detect_chapters(text):
    sections = []
    current_title = "Preamble"
    current_start = 0

    for match in re.finditer('|'.join(CHAPTER_PATTERNS), text, re.MULTILINE):
        if match.start() > current_start:
            sections.append(Section(
                title=current_title,
                text=text[current_start:match.start()].strip()
            ))
        current_title = match.group().strip()
        current_start = match.start()

    sections.append(Section(title=current_title, text=text[current_start:].strip()))
    return sections
```

## Structured Reading Workflow

### Phase 1: Survey

Read the table of contents, introduction, and conclusion first to build a mental model of the document's argument structure:

```
1. Extract and display Table of Contents
2. Read Introduction (typically Chapter 1)
3. Read Conclusion (typically last chapter)
4. Generate a document map: chapter titles + estimated page counts
5. Identify key themes and arguments
```

### Phase 2: Sequential Deep Reading

Process each chapter with a standardized analysis template:

```
For each chapter:
  - Chapter title and position in document
  - Key arguments or findings (3-5 bullet points)
  - Methodology described (if applicable)
  - Data or evidence presented
  - Connections to previous chapters
  - Open questions or points for follow-up
  - Notable quotes or passages (with page/section references)
```

### Phase 3: Synthesis

After all chapters are read, generate cross-cutting analyses:

```
- Thematic summary across all chapters
- Argument progression map
- Methodology comparison (if multiple studies)
- Contradiction or tension identification
- Gap analysis relative to research questions
```

## Cross-Session Persistence

For documents that take multiple sessions to read, maintain a reading state file:

```json
{
  "document": "thesis_smith_2024.pdf",
  "total_sections": 24,
  "completed": [0, 1, 2, 3, 4, 5],
  "current": 6,
  "summaries": {
    "0": "Preamble: Defines scope of study on...",
    "1": "Chapter 1: Introduction to the problem of...",
    "2": "Chapter 2: Literature review covering..."
  },
  "themes": ["data governance", "algorithmic fairness", "institutional trust"],
  "open_questions": [
    "How does the author reconcile findings in Ch3 with Ch5?"
  ]
}
```

## Format-Specific Handling

| Format | Tool | Notes |
|--------|------|-------|
| PDF | `pdfplumber`, `PyMuPDF` | Extract text with layout awareness |
| EPUB | `ebooklib` | Chapters are HTML files in the spine |
| DOCX | `python-docx` | Headings define structure |
| LaTeX | Regex on `\chapter`, `\section` | Native structure markers |
| HTML | `BeautifulSoup` | Split on `<h1>`, `<h2>` tags |
| Plain text | Heuristic detection | Use blank lines, indentation, page breaks |

## Best Practices

1. **Preserve cross-references**: When a chapter references "as discussed in Section 3.2," maintain a reference index so the reader can retrieve that section.
2. **Maintain running context**: Each chunk should include a brief summary of preceding material (the overlap window) to maintain narrative continuity.
3. **Respect tables and figures**: Never split in the middle of a table, code block, or figure caption. These should be kept as atomic units.
4. **Index creation**: Build a searchable index of key terms, names, and concepts with section references for rapid lookup.
5. **Citation extraction**: Pull out all references cited in each chapter to build a cumulative bibliography.

## References

- pdfplumber: https://github.com/jsvine/pdfplumber
- python-docx: https://python-docx.readthedocs.io
- ebooklib: https://github.com/aerkalov/ebooklib
- PyMuPDF (fitz): https://pymupdf.readthedocs.io
