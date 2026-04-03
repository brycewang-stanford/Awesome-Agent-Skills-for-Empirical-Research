---
name: multilingual-research-guide
description: "Strategies for translating academic papers while preserving technical accuracy"
metadata:
  openclaw:
    emoji: "🌐"
    category: "tools"
    subcategory: "ocr-translate"
    keywords: ["translation strategies", "document OCR", "math OCR", "academic writing", "multilingual research"]
    source: "wentor"
---

# Academic Translation Guide

A skill for translating academic papers, theses, and research documents between languages while preserving technical precision, citation integrity, and discipline-specific terminology. Covers workflow design, terminology management, and quality assurance.

## Translation Workflow

### End-to-End Pipeline

```
Source Document
  |
  v
1. Document Preparation
   - Extract text (OCR if scanned)
   - Identify formulas, figures, tables (do NOT translate these)
   - Build terminology glossary
  |
  v
2. Segmentation
   - Split into translatable units (sentences/paragraphs)
   - Tag non-translatable elements: equations, citations, proper nouns
  |
  v
3. Translation
   - Apply machine translation (first pass)
   - Human post-editing (second pass)
   - Terminology consistency check (third pass)
  |
  v
4. Quality Assurance
   - Back-translation verification (sample)
   - Domain expert review
   - Formatting and citation check
  |
  v
Target Document
```

## Terminology Management

### Building a Domain Glossary

```python
import json

def build_terminology_glossary(source_text: str, domain: str,
                                source_lang: str = 'zh',
                                target_lang: str = 'en') -> list[dict]:
    """
    Extract and standardize technical terms from source text.

    Args:
        source_text: Raw text of the source document
        domain: Research domain (e.g., 'machine_learning', 'biochemistry')
        source_lang: Source language code
        target_lang: Target language code
    Returns:
        List of terminology entries
    """
    # Common domain-specific glossaries
    glossaries = {
        'machine_learning': {
            'zh_en': {
                '过拟合': 'overfitting',
                '欠拟合': 'underfitting',
                '梯度下降': 'gradient descent',
                '损失函数': 'loss function',
                '卷积神经网络': 'convolutional neural network',
                '注意力机制': 'attention mechanism',
                '预训练模型': 'pre-trained model',
                '微调': 'fine-tuning',
                '批归一化': 'batch normalization',
                '学习率': 'learning rate'
            }
        },
        'biochemistry': {
            'zh_en': {
                '蛋白质折叠': 'protein folding',
                '酶动力学': 'enzyme kinetics',
                '基因表达': 'gene expression',
                '转录因子': 'transcription factor',
                '信号通路': 'signaling pathway',
                '代谢组学': 'metabolomics'
            }
        }
    }

    domain_terms = glossaries.get(domain, {}).get(f'{source_lang}_{target_lang}', {})

    entries = []
    for source_term, target_term in domain_terms.items():
        if source_term in source_text:
            entries.append({
                'source': source_term,
                'target': target_term,
                'domain': domain,
                'verified': True,
                'notes': ''
            })
    return entries
```

### Terminology Consistency Enforcement

```python
def enforce_terminology(translated_text: str,
                         glossary: list[dict]) -> tuple[str, list[str]]:
    """
    Check and enforce terminology consistency in translated text.

    Returns:
        Tuple of (corrected_text, list of warnings)
    """
    warnings = []
    corrected = translated_text

    for entry in glossary:
        target_term = entry['target']
        # Check for common mistranslations or inconsistent usage
        variants = entry.get('incorrect_variants', [])
        for variant in variants:
            if variant.lower() in corrected.lower():
                warnings.append(
                    f"Found '{variant}' -- should be '{target_term}'"
                )
                # Case-insensitive replacement
                import re
                corrected = re.sub(
                    re.escape(variant), target_term, corrected,
                    flags=re.IGNORECASE
                )

    return corrected, warnings
```

## Machine Translation Integration

### Using DeepL API for Academic Text

```python
import deepl

def translate_academic_text(text: str, source_lang: str, target_lang: str,
                             auth_key: str, glossary_id: str = None) -> str:
    """
    Translate academic text using DeepL with optional glossary.
    """
    translator = deepl.Translator(auth_key)

    result = translator.translate_text(
        text,
        source_lang=source_lang.upper(),
        target_lang=target_lang.upper(),
        formality="more",  # academic style
        glossary=glossary_id,
        preserve_formatting=True,
        tag_handling="xml"  # preserve XML/HTML tags
    )
    return result.text
```

### Protecting Non-Translatable Elements

Before sending text to any translation engine, protect elements that should not be translated:

```python
import re

def protect_elements(text: str) -> tuple[str, dict]:
    """
    Replace non-translatable elements with placeholders.
    Returns protected text and a mapping to restore later.
    """
    placeholders = {}
    counter = 0

    # Protect LaTeX equations
    for pattern in [r'\$\$.*?\$\$', r'\$.*?\$', r'\\begin\{equation\}.*?\\end\{equation\}']:
        for match in re.finditer(pattern, text, re.DOTALL):
            key = f'__MATH_{counter}__'
            placeholders[key] = match.group()
            text = text.replace(match.group(), key, 1)
            counter += 1

    # Protect citations
    for match in re.finditer(r'\\cite\{[^}]+\}|\([A-Z][a-z]+(?:\s+et\s+al\.)?,\s*\d{4}\)', text):
        key = f'__CITE_{counter}__'
        placeholders[key] = match.group()
        text = text.replace(match.group(), key, 1)
        counter += 1

    # Protect URLs
    for match in re.finditer(r'https?://\S+', text):
        key = f'__URL_{counter}__'
        placeholders[key] = match.group()
        text = text.replace(match.group(), key, 1)
        counter += 1

    return text, placeholders

def restore_elements(text: str, placeholders: dict) -> str:
    """Restore protected elements from placeholders."""
    for key, value in placeholders.items():
        text = text.replace(key, value)
    return text
```

## Quality Assurance

### Back-Translation Verification

For critical documents, perform back-translation on a random 10-20% sample of paragraphs. Compare the back-translated text with the original to identify semantic drift. Flag any paragraph where back-translation diverges significantly from the source.

### Checklist Before Submission

1. All technical terms match the domain glossary
2. All equations, formulas, and figures are unchanged
3. All citations and references are intact and correctly formatted
4. Author names and institutional affiliations are not translated
5. Abbreviations are defined on first use in the target language
6. The abstract has been reviewed by a domain expert in the target language
7. Journal-specific terminology preferences have been applied
