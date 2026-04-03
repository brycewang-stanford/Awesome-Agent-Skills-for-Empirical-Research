---
name: pdf-extraction-guide
description: "PDF parsing, text extraction, and document format conversion"
metadata:
  openclaw:
    emoji: "📄"
    category: "tools"
    subcategory: "document"
    keywords: ["PDF parsing", "PDF extraction", "document chunking", "format conversion", "md2pdf"]
    source: "wentor-research-plugins"
---

# PDF Extraction Guide

Extract text, tables, figures, and metadata from academic PDFs using Python libraries, with strategies for handling multi-column layouts, mathematical content, and scanned documents.

## PDF Extraction Tools Comparison

| Tool | Text | Tables | Figures | Layout | OCR | Speed |
|------|------|--------|---------|--------|-----|-------|
| PyMuPDF (fitz) | Excellent | Manual | Yes | Blocks | No (add with OCR engine) | Fast |
| pdfplumber | Good | Excellent | No | Tables focus | No | Medium |
| PyPDF2 / pypdf | Basic | No | No | No | No | Fast |
| Tabula-py | No | Excellent | No | No | No | Medium |
| GROBID | Structured | Yes | References | Academic layout | No | Slow (ML-based) |
| Nougat (Meta) | Excellent | Yes | Yes | Academic layout | Built-in | Slow (GPU) |
| Marker | Excellent | Yes | Yes | Multi-column | Built-in | Medium |
| pdf2image + Tesseract | Via OCR | Via OCR | Via OCR | No | Yes | Slow |

## PyMuPDF (fitz) — Fast Text Extraction

### Basic Text Extraction

```python
import fitz  # pip install PyMuPDF

def extract_text(pdf_path):
    """Extract all text from a PDF with page numbers."""
    doc = fitz.open(pdf_path)
    full_text = []

    for page_num, page in enumerate(doc, 1):
        text = page.get_text("text")
        full_text.append(f"--- Page {page_num} ---\n{text}")

    doc.close()
    return "\n".join(full_text)

# Usage
text = extract_text("paper.pdf")
print(text[:2000])
```

### Structured Block-Level Extraction

```python
def extract_structured(pdf_path):
    """Extract text with layout information (blocks, lines, spans)."""
    doc = fitz.open(pdf_path)
    pages = []

    for page_num, page in enumerate(doc):
        blocks = page.get_text("dict")["blocks"]
        page_data = {"page": page_num + 1, "blocks": []}

        for block in blocks:
            if "lines" not in block:
                continue  # Skip image blocks

            block_text = ""
            max_font_size = 0
            is_bold = False

            for line in block["lines"]:
                for span in line["spans"]:
                    block_text += span["text"]
                    max_font_size = max(max_font_size, span["size"])
                    if "Bold" in span.get("font", ""):
                        is_bold = True
                block_text += "\n"

            page_data["blocks"].append({
                "text": block_text.strip(),
                "font_size": max_font_size,
                "is_bold": is_bold,
                "bbox": block["bbox"]  # (x0, y0, x1, y1)
            })

        pages.append(page_data)

    doc.close()
    return pages

# Identify section headings
pages = extract_structured("paper.pdf")
for page in pages:
    for block in page["blocks"]:
        if block["is_bold"] and block["font_size"] > 11:
            print(f"[Heading] {block['text'][:80]}")
```

### Extract Images and Figures

```python
def extract_images(pdf_path, output_dir="./images"):
    """Extract all images from a PDF."""
    import os
    os.makedirs(output_dir, exist_ok=True)

    doc = fitz.open(pdf_path)
    img_count = 0

    for page_num, page in enumerate(doc):
        images = page.get_images(full=True)
        for img_idx, img in enumerate(images):
            xref = img[0]
            pix = fitz.Pixmap(doc, xref)

            if pix.n - pix.alpha > 3:  # CMYK
                pix = fitz.Pixmap(fitz.csRGB, pix)

            filename = f"{output_dir}/page{page_num+1}_img{img_idx+1}.png"
            pix.save(filename)
            img_count += 1

    doc.close()
    print(f"Extracted {img_count} images to {output_dir}")
```

## pdfplumber — Table Extraction

```python
import pdfplumber

def extract_tables(pdf_path):
    """Extract all tables from a PDF."""
    tables = []
    with pdfplumber.open(pdf_path) as pdf:
        for page_num, page in enumerate(pdf.pages):
            page_tables = page.extract_tables()
            for table_idx, table in enumerate(page_tables):
                tables.append({
                    "page": page_num + 1,
                    "table_index": table_idx,
                    "data": table
                })
    return tables

# Convert extracted table to pandas DataFrame
import pandas as pd

tables = extract_tables("paper.pdf")
for t in tables:
    if t["data"]:
        df = pd.DataFrame(t["data"][1:], columns=t["data"][0])
        print(f"\nTable on page {t['page']}:")
        print(df.to_string())
```

## GROBID — Structured Academic Paper Parsing

GROBID uses machine learning to parse academic PDFs into structured TEI XML.

```python
import requests

def parse_with_grobid(pdf_path, grobid_url="http://localhost:8070"):
    """Parse a paper PDF using GROBID."""
    with open(pdf_path, "rb") as f:
        response = requests.post(
            f"{grobid_url}/api/processFulltextDocument",
            files={"input": f},
            data={"consolidateHeader": 1, "consolidateCitations": 1}
        )

    if response.status_code == 200:
        return response.text  # TEI XML
    else:
        raise Exception(f"GROBID error: {response.status_code}")

# Parse the TEI XML
from lxml import etree

tei_xml = parse_with_grobid("paper.pdf")
root = etree.fromstring(tei_xml.encode())
ns = {"tei": "http://www.tei-c.org/ns/1.0"}

# Extract title
title = root.find(".//tei:titleStmt/tei:title", ns)
print(f"Title: {title.text if title is not None else 'N/A'}")

# Extract abstract
abstract = root.find(".//tei:profileDesc/tei:abstract", ns)
if abstract is not None:
    print(f"Abstract: {abstract.text}")

# Extract references
refs = root.findall(".//tei:listBibl/tei:biblStruct", ns)
print(f"References found: {len(refs)}")
for ref in refs[:5]:
    title_elem = ref.find(".//tei:title", ns)
    print(f"  - {title_elem.text if title_elem is not None else 'N/A'}")
```

## Document Chunking for RAG

Split documents into semantically meaningful chunks for retrieval-augmented generation:

```python
def chunk_academic_paper(pdf_path, max_chunk_size=1000, overlap=200):
    """Chunk an academic paper by sections with overlap."""
    pages = extract_structured(pdf_path)

    # Identify sections
    sections = []
    current_section = {"heading": "Preamble", "text": ""}

    for page in pages:
        for block in page["blocks"]:
            if block["is_bold"] and block["font_size"] > 11 and len(block["text"]) < 100:
                if current_section["text"].strip():
                    sections.append(current_section)
                current_section = {"heading": block["text"], "text": ""}
            else:
                current_section["text"] += block["text"] + "\n"

    if current_section["text"].strip():
        sections.append(current_section)

    # Split long sections into overlapping chunks
    chunks = []
    for section in sections:
        text = section["text"]
        if len(text) <= max_chunk_size:
            chunks.append({
                "heading": section["heading"],
                "text": text,
                "chunk_index": 0
            })
        else:
            words = text.split()
            start = 0
            chunk_idx = 0
            while start < len(words):
                end = start + max_chunk_size // 5  # Approximate words
                chunk_text = " ".join(words[start:end])
                chunks.append({
                    "heading": section["heading"],
                    "text": chunk_text,
                    "chunk_index": chunk_idx
                })
                start = end - overlap // 5  # Overlap in words
                chunk_idx += 1

    return chunks
```

## Format Conversion

### Markdown to PDF

```bash
# Using Pandoc (most versatile converter)
pandoc paper.md -o paper.pdf --pdf-engine=xelatex

# With template and bibliography
pandoc paper.md -o paper.pdf \
  --pdf-engine=xelatex \
  --template=ieee.tex \
  --bibliography=references.bib \
  --citeproc \
  --number-sections

# Markdown to Word (for collaborators who prefer Word)
pandoc paper.md -o paper.docx --reference-doc=template.docx
```

### PDF to Markdown (Using Marker)

```bash
# Install Marker (ML-based PDF to Markdown converter)
pip install marker-pdf

# Convert a single PDF
marker_single paper.pdf output_dir/ --langs English

# Batch convert
marker output_dir/ input_dir/ --workers 4
```

## OCR for Scanned PDFs

```python
from pdf2image import convert_from_path
import pytesseract

def ocr_pdf(pdf_path, lang="eng"):
    """OCR a scanned PDF using Tesseract."""
    images = convert_from_path(pdf_path, dpi=300)
    full_text = []

    for i, image in enumerate(images):
        text = pytesseract.image_to_string(image, lang=lang)
        full_text.append(f"--- Page {i+1} ---\n{text}")

    return "\n".join(full_text)

# For academic papers with math, use specialized OCR:
# - Mathpix API (commercial, excellent math OCR)
# - Nougat (Meta, open source, GPU required)
# - LaTeX-OCR (open source, formula-specific)
```

## Best Practices

1. **Try PyMuPDF first**: It is the fastest and handles most modern PDFs well. Fall back to GROBID for academic papers that need structural parsing.
2. **Check PDF type**: Use `page.get_text()` to detect if a PDF is text-based or scanned. If empty, use OCR.
3. **Handle multi-column layouts**: PyMuPDF's `sort` parameter in `get_text("blocks")` helps with reading order. GROBID and Marker handle this natively.
4. **Preserve metadata**: Extract DOI, authors, and title from PDF metadata (`doc.metadata`) when available.
5. **Validate table extraction**: Always visually verify extracted tables; complex layouts with merged cells often fail.
6. **Cache extracted text**: Store parsed results alongside PDFs to avoid re-processing.
