---
name: pdf-math-translate-guide
description: "Translate scientific PDFs with preserved math formatting via PDFMathTranslate"
metadata:
  openclaw:
    emoji: "📄"
    category: "tools"
    subcategory: "ocr-translate"
    keywords: ["pdf-translation", "math-formatting", "scientific-papers", "multilingual", "latex-preservation"]
    source: "https://github.com/Byaidu/PDFMathTranslate"
---

# PDFMathTranslate Guide

## Overview

PDFMathTranslate is an open-source tool designed specifically for translating scientific and technical PDF documents while preserving mathematical formulas, tables, figures, and the overall layout structure. Traditional PDF translators often mangle equations and destroy formatting, making translated papers difficult to read. PDFMathTranslate solves this problem by intelligently detecting and preserving mathematical content during the translation process.

The tool leverages large language models for high-quality translation while maintaining the integrity of LaTeX-rendered equations, chemical formulas, and complex table structures commonly found in academic publications. It supports translation between dozens of language pairs, making it invaluable for researchers who need to read papers published in languages outside their expertise.

PDFMathTranslate has gained significant traction in the academic community with over 32,000 GitHub stars, reflecting the widespread need for reliable scientific document translation that respects the specialized formatting requirements of research papers.

## Installation and Setup

Install PDFMathTranslate using pip in a Python environment (Python 3.8 or higher required):

```bash
pip install pdf2zh
```

For GPU-accelerated processing, install with CUDA support:

```bash
pip install pdf2zh[cuda]
```

Configure your translation backend by setting the appropriate environment variable. The tool supports multiple LLM providers:

```bash
# Using OpenAI-compatible APIs
export OPENAI_API_KEY=$OPENAI_API_KEY
export OPENAI_BASE_URL=$OPENAI_BASE_URL

# Using Google Translate (free, no key required)
pdf2zh input.pdf -s google

# Using DeepL
export DEEPL_AUTH_KEY=$DEEPL_AUTH_KEY
pdf2zh input.pdf -s deepl
```

You can also launch the web-based GUI for interactive use:

```bash
pdf2zh -g
```

This starts a Gradio interface where you can upload PDFs and configure translation settings through a browser.

## Core Features

PDFMathTranslate provides several capabilities critical for academic workflows:

**Formula Preservation**: The tool detects and preserves inline and display math environments. Equations rendered in LaTeX, MathML, or image-based formats are identified and left untouched during translation, ensuring mathematical accuracy is maintained.

**Layout Retention**: The translated output maintains the original page layout including headers, footers, figure positions, table structures, and column formatting. This produces a readable document that mirrors the source paper structure.

**Batch Processing**: Translate multiple papers at once using wildcard patterns or directory inputs:

```bash
# Translate all PDFs in a directory
pdf2zh ./papers/*.pdf -lo zh -li en

# Specify output directory
pdf2zh input.pdf -o ./translated/
```

**Dual-Document Output**: Each translation generates two files: a fully translated version and a side-by-side bilingual version where original and translated text appear together, useful for verifying translation quality.

**Selective Translation**: Target specific page ranges to avoid translating references, appendices, or supplementary material:

```bash
# Translate only pages 1 through 15
pdf2zh input.pdf -p 1-15
```

## Research Workflow Integration

PDFMathTranslate fits naturally into several academic research scenarios:

**Literature Review Acceleration**: When conducting systematic reviews across multilingual sources, batch-translate candidate papers to quickly assess relevance before investing time in detailed reading. The preserved formatting means figures and data tables remain interpretable.

**Collaboration Across Languages**: Research teams spanning multiple countries can share translated versions of key papers while maintaining the mathematical rigor of the original. The bilingual output mode is particularly useful for group discussions where team members have different language proficiencies.

**Conference Preparation**: When presenting at international conferences, translate your own papers or related works to prepare for questions and discussions in the host language.

**Integration with Reference Managers**: Combine with Zotero or Mendeley workflows by translating downloaded papers and storing both versions in your reference library:

```bash
# Example workflow with a Zotero storage directory
for pdf in ~/Zotero/storage/*/*.pdf; do
  pdf2zh "$pdf" -lo zh -li en -o ~/translated_papers/
done
```

**Quality Verification**: Always use the bilingual output mode when translation accuracy is critical. Cross-reference translated equations with the original to catch any edge cases where formula detection may have been imprecise.

## Configuration and Customization

Fine-tune translation behavior through configuration options:

```bash
# Use a specific model for translation
pdf2zh input.pdf -s openai -m gpt-4o

# Set custom font for translated text
pdf2zh input.pdf --font "Noto Sans CJK SC"

# Adjust thread count for parallel processing
pdf2zh input.pdf -t 4
```

For programmatic use, PDFMathTranslate can be integrated into Python scripts:

```python
from pdf2zh import translate

# Basic translation
translate.translate(
    files=["paper.pdf"],
    lang_out="zh",
    lang_in="en",
    service="google"
)
```

## References

- PDFMathTranslate repository: https://github.com/Byaidu/PDFMathTranslate
- PyPI package: https://pypi.org/project/pdf2zh/
- Supported translation services documentation in the project wiki
