---
name: latex-ocr-guide
description: "Extract and convert mathematical formulas from images and PDFs to LaTeX code"
metadata:
  openclaw:
    emoji: "🔍"
    category: "tools"
    subcategory: "ocr-translate"
    keywords: ["math OCR", "formula recognition", "LaTeX OCR", "document OCR", "equation extraction"]
    source: "wentor"
---

# LaTeX OCR Guide

A skill for extracting mathematical formulas from images, PDFs, and handwritten notes and converting them to LaTeX code. Covers tool selection, batch processing workflows, and quality verification techniques.

## Tool Landscape

### Available Math OCR Tools

| Tool | Type | Accuracy | Best For | License |
|------|------|----------|----------|---------|
| Mathpix | Cloud API | Very high | All math, diagrams | Commercial ($) |
| LaTeX-OCR (Lukas Blecher) | Local model | High | Printed formulas | MIT |
| Pix2Tex | Local model | High | Single equations | MIT |
| Nougat (Meta) | Local model | High | Full papers with math | MIT |
| InftyReader | Desktop | High | Printed math, Japanese | Commercial |
| img2latex | Local model | Moderate | Simple equations | MIT |

### Quick Start with LaTeX-OCR

```bash
# Install the open-source LaTeX-OCR package
pip install "pix2tex[gui]"

# Or install from GitHub for latest version
pip install git+https://github.com/lukas-blecher/LaTeX-OCR.git
```

```python
from pix2tex.cli import LatexOCR
from PIL import Image

def recognize_formula(image_path: str) -> str:
    """
    Convert a formula image to LaTeX code.

    Args:
        image_path: Path to image containing a mathematical formula
    Returns:
        LaTeX string representation of the formula
    """
    model = LatexOCR()
    img = Image.open(image_path)
    latex_code = model(img)
    return latex_code

# Single image
result = recognize_formula('formula.png')
print(result)
# Output: E = mc^{2}
```

## Batch Processing Workflow

### Processing Multiple Formulas from a PDF

```python
import fitz  # PyMuPDF
from PIL import Image
import io

def extract_formulas_from_pdf(pdf_path: str, output_dir: str,
                                min_height: int = 30) -> list[dict]:
    """
    Extract formula regions from a PDF and convert to LaTeX.

    Args:
        pdf_path: Path to the PDF file
        output_dir: Directory to save extracted formula images
        min_height: Minimum height (px) to consider as formula region
    """
    doc = fitz.open(pdf_path)
    model = LatexOCR()
    results = []

    for page_num in range(len(doc)):
        page = doc[page_num]
        # Extract images from page
        image_list = page.get_images(full=True)

        for img_idx, img_info in enumerate(image_list):
            xref = img_info[0]
            pix = fitz.Pixmap(doc, xref)

            if pix.height >= min_height:
                img_data = pix.tobytes("png")
                img = Image.open(io.BytesIO(img_data))

                try:
                    latex = model(img)
                    results.append({
                        'page': page_num + 1,
                        'image_index': img_idx,
                        'latex': latex,
                        'confidence': 'high' if len(latex) > 3 else 'low'
                    })
                except Exception as e:
                    results.append({
                        'page': page_num + 1,
                        'image_index': img_idx,
                        'latex': None,
                        'error': str(e)
                    })

    return results
```

### Processing Handwritten Notes

For handwritten mathematics, preprocessing improves accuracy significantly:

```python
import cv2
import numpy as np

def preprocess_handwritten(image_path: str) -> Image.Image:
    """
    Preprocess a handwritten formula image for better OCR accuracy.
    """
    img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)

    # 1. Denoise
    img = cv2.fastNlMeansDenoising(img, h=10)

    # 2. Adaptive thresholding for varying illumination
    img = cv2.adaptiveThreshold(
        img, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
        cv2.THRESH_BINARY, 15, 8
    )

    # 3. Dilation to connect broken strokes
    kernel = np.ones((2, 2), np.uint8)
    img = cv2.dilate(img, kernel, iterations=1)

    # 4. Crop to content with padding
    coords = cv2.findNonZero(255 - img)
    x, y, w, h = cv2.boundingRect(coords)
    pad = 20
    img = img[max(0, y-pad):y+h+pad, max(0, x-pad):x+w+pad]

    return Image.fromarray(img)
```

## Using Mathpix API

**Pricing note:** Mathpix is a paid service (starting at $5/month). For free open-source alternatives, use pix2tex/LaTeX-OCR or Nougat (Meta), both MIT-licensed and capable of running locally.

For production-quality results, the Mathpix API provides the highest accuracy:

```python
import requests
import base64

def mathpix_ocr(image_path: str, app_id: str, app_key: str) -> dict:
    """
    Use Mathpix API for high-accuracy math OCR.
    """
    with open(image_path, 'rb') as f:
        image_data = base64.b64encode(f.read()).decode()

    response = requests.post(
        'https://api.mathpix.com/v3/text',
        headers={
            'app_id': app_id,
            'app_key': app_key,
            'Content-type': 'application/json'
        },
        json={
            'src': f'data:image/png;base64,{image_data}',
            'formats': ['latex_styled', 'text'],
            'data_options': {'include_asciimath': True}
        }
    )
    return response.json()
```

## Verification and Correction

Always verify OCR output by rendering the LaTeX:

```python
import matplotlib.pyplot as plt

def verify_latex(latex_string: str, output_path: str = 'verify.png'):
    """Render LaTeX formula and save as image for visual verification."""
    fig, ax = plt.subplots(figsize=(8, 2))
    ax.text(0.5, 0.5, f'${latex_string}$', fontsize=20,
            ha='center', va='center', transform=ax.transAxes)
    ax.axis('off')
    fig.savefig(output_path, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Verification image saved to {output_path}")
```

Common OCR errors to watch for: confusing `l` with `1`, `O` with `0`, missing superscripts/subscripts, incorrect fraction nesting, and misrecognized Greek letters. Always proofread critical equations before submission.
