---
name: latex-translation-guide
description: "Translate LaTeX documents preserving math formulas and structure"
metadata:
  openclaw:
    emoji: "🌐"
    category: "tools"
    subcategory: "ocr-translate"
    keywords: ["LaTeX translation", "document translation", "multilingual", "math preservation", "academic translation"]
    source: "https://github.com/SUSYUSTC/MathTranslate"
---

# LaTeX Document Translation Guide

## Overview

Translating LaTeX academic documents requires preserving mathematical formulas, cross-references, citations, and formatting while converting the text between languages. This guide covers tools and techniques for translating LaTeX papers — from command-line utilities to full document pipelines. Particularly useful for making research accessible across language barriers.

## LaTeXTrans Approach

```bash
# Install LaTeXTrans
pip install latextrans

# Translate a LaTeX file
latextrans translate paper.tex --from en --to zh --output paper_zh.tex
```

### How It Works

1. **Parse**: Extract text segments while preserving LaTeX commands
2. **Protect**: Shield math environments (`$...$`, `\[...\]`, equations)
3. **Translate**: Send text segments to translation API
4. **Reconstruct**: Reassemble with original LaTeX structure

### Python Usage

```python
from latextrans import LatexTranslator

translator = LatexTranslator(
    source_lang="en",
    target_lang="zh",
    engine="google",  # or "deepl", "openai"
)

# Translate a file
translator.translate_file("paper.tex", "paper_zh.tex")

# Translate a string
result = translator.translate(
    r"The loss function $\mathcal{L}(\theta)$ is minimized "
    r"using gradient descent with learning rate $\eta$."
)
# Output preserves $\mathcal{L}(\theta)$ and $\eta$ untouched
```

## MathTranslate Tool

```bash
# Install MathTranslate (specialized for math-heavy papers)
pip install mathtranslate

# Translate arXiv paper directly
translate_arxiv 2301.00001 -o translated.tex

# Translate local file
translate_tex paper.tex -o paper_translated.tex
```

### MathTranslate Features

```python
# Configuration
import mathtranslate

# Set translation backend
mathtranslate.config.set_translator("google")  # free
mathtranslate.config.set_translator("openai")  # higher quality

# Translate with customization
mathtranslate.translate(
    input_file="paper.tex",
    output_file="paper_zh.tex",
    source_lang="en",
    target_lang="zh-CN",
    threads=4,  # parallel translation
)
```

## Manual Translation Tips

### Protecting Math Environments

```python
import re

def extract_and_protect(latex_text: str) -> tuple:
    """Extract math environments before translation."""
    math_pattern = r'(\$\$[\s\S]*?\$\$|\$[^$]+\$|\\begin\{equation\}[\s\S]*?\\end\{equation\}|\\begin\{align\}[\s\S]*?\\end\{align\})'

    placeholders = {}
    counter = [0]

    def replace_math(match):
        key = f"__MATH_{counter[0]}__"
        placeholders[key] = match.group(0)
        counter[0] += 1
        return key

    protected = re.sub(math_pattern, replace_math, latex_text)
    return protected, placeholders


def restore_math(translated: str, placeholders: dict) -> str:
    """Restore math environments after translation."""
    for key, value in placeholders.items():
        translated = translated.replace(key, value)
    return translated
```

### Commands to Protect

```latex
% Always protect these:
\ref{...}      % Cross-references
\cite{...}     % Citations
\label{...}    % Labels
\eqref{...}    % Equation references
\url{...}      % URLs
\texttt{...}   % Code/monospace

% Math environments to protect:
$...$          % Inline math
$$...$$        % Display math
\[...\]        % Display math
\begin{equation}...\end{equation}
\begin{align}...\end{align}
\begin{theorem}...\end{theorem}  % Custom environments
```

## Bilingual Output

```latex
% Create side-by-side bilingual document
\usepackage{paracol}

\begin{paracol}{2}
\switchcolumn[0]
The transformer architecture has become...

\switchcolumn[1]
Transformer架构已经成为...

\switchcolumn[0]
Self-attention computes $\text{Attention}(Q,K,V) = \text{softmax}(\frac{QK^T}{\sqrt{d_k}})V$

\switchcolumn[1]
自注意力计算 $\text{Attention}(Q,K,V) = \text{softmax}(\frac{QK^T}{\sqrt{d_k}})V$
\end{paracol}
```

## Translation Backends

| Backend | Quality | Cost | Speed |
|---------|---------|------|-------|
| Google Translate | Good | Free | Fast |
| DeepL | Better | Freemium | Fast |
| OpenAI GPT-4 | Best | Paid | Slower |
| Claude | Best | Paid | Slower |

## References

- [LaTeXTrans](https://github.com/SUSYUSTC/MathTranslate)
- [PDFMathTranslate](https://github.com/Byaidu/PDFMathTranslate)
- [arXiv LaTeX Cleaner](https://github.com/google-research/arxiv-latex-cleaner)
