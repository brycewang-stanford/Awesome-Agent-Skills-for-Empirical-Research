---
name: handwriting-recognition-guide
description: "Apply handwriting OCR to digitize historical and archival documents"
metadata:
  openclaw:
    emoji: "🖋️"
    category: "tools"
    subcategory: "ocr-translate"
    keywords: ["handwriting recognition", "HTR", "OCR", "historical documents", "digitization", "manuscript transcription"]
    source: "wentor-research-plugins"
---

# Handwriting Recognition Guide

A skill for applying handwriting text recognition (HTR) to digitize historical documents, archival manuscripts, and handwritten research notes. Covers HTR platforms, image preprocessing, model training, post-correction, and integration into digital humanities research workflows.

## Handwriting Recognition vs. Printed OCR

### Key Differences

```
Printed Text OCR:
  - Characters are standardized and uniform
  - Well-solved problem (>99% accuracy on clean scans)
  - Tools: Tesseract, ABBYY FineReader, Adobe Acrobat

Handwriting Text Recognition (HTR):
  - Characters vary by writer, mood, pen, era
  - Much harder -- typically 85-95% character accuracy
  - Requires training on specific handwriting styles
  - Tools: Transkribus, Kraken, HTR-Flor, Google Cloud Vision

Challenges specific to historical documents:
  - Faded ink, bleed-through, stains, tears
  - Archaic letterforms and abbreviations
  - Multiple hands in one document
  - Non-standard orthography
  - Mixed languages and scripts
```

## HTR Platforms

### Transkribus (State of the Art for Historical Documents)

**Pricing note:** Transkribus uses a credit-based pricing model. A limited free tier is available, but processing large volumes of pages requires purchasing credits.

```
Transkribus is the leading platform for historical HTR.

Workflow:
  1. Upload document images
  2. Automatic layout analysis (detect text regions and baselines)
  3. Manual correction of layout (if needed)
  4. Apply a pre-trained HTR model (or train your own)
  5. Review and correct transcription
  6. Export as TEXT, PAGE XML, TEI, DOCX, or PDF

Pre-trained models:
  - Noscemus GM (general model for Latin scripts)
  - English Writing M1 (18th-19th century English)
  - German Kurrent models
  - Dutch, French, Italian, Spanish models available

Training a custom model:
  - Requires ~15,000-25,000 words of ground truth (manually transcribed)
  - Can start with a pre-trained base model and fine-tune
  - Training takes 1-8 hours depending on dataset size
```

### Other Tools

| Tool | Type | Strengths |
|------|------|----------|
| Transkribus | Cloud platform | Best for historical documents, active community |
| Kraken | Open source (Python) | Flexible, scriptable, custom training |
| eScriptorium | Open source (web) | Based on Kraken, collaborative interface |
| Google Cloud Vision | API | Good for modern handwriting, many languages |
| Azure AI Vision | API | Competitive with Google for modern text |
| HTR-Flor | Open source | Research-focused, PyTorch-based |

## Image Preprocessing

### Preparing Scans for HTR

```python
from PIL import Image, ImageFilter, ImageEnhance


def preprocess_document_image(image_path: str,
                               output_path: str) -> dict:
    """
    Preprocess a document scan for optimal HTR performance.

    Args:
        image_path: Path to the input scan
        output_path: Path to save the preprocessed image
    """
    img = Image.open(image_path)

    # Convert to grayscale
    img = img.convert("L")

    # Enhance contrast
    enhancer = ImageEnhance.Contrast(img)
    img = enhancer.enhance(1.5)

    # Remove noise
    img = img.filter(ImageFilter.MedianFilter(size=3))

    # Binarize (convert to black and white)
    threshold = 128
    img = img.point(lambda x: 255 if x > threshold else 0, "1")

    img.save(output_path)

    return {
        "original": image_path,
        "processed": output_path,
        "steps_applied": [
            "Grayscale conversion",
            "Contrast enhancement (1.5x)",
            "Median filter (noise removal)",
            "Binarization (threshold=128)"
        ],
        "additional_steps_if_needed": [
            "Deskewing (correct rotation)",
            "Dewarping (correct page curvature)",
            "Bleed-through removal",
            "Background normalization"
        ]
    }
```

### Scanning Best Practices

```
Resolution:    300-400 DPI for most documents
               600 DPI for fine handwriting or damaged originals
Color:         Grayscale usually sufficient; color for illuminated MSS
Format:        TIFF (lossless) for archival; PNG for working copies
Lighting:      Even, diffused light; avoid shadows and glare
Flatness:      Use a book cradle or V-shaped scanner for bound volumes
Calibration:   Include a color/grayscale chart for batch consistency
```

## Post-OCR Correction

### Semi-Automated Correction Workflow

```python
def post_correction_workflow(raw_transcription: str,
                              dictionary: set,
                              confidence_threshold: float = 0.8) -> dict:
    """
    Post-correction strategy for HTR output.

    Args:
        raw_transcription: Raw OCR/HTR text output
        dictionary: Set of valid words for the document's language/period
        confidence_threshold: Below this, flag for manual review
    """
    words = raw_transcription.split()
    flagged = []
    corrected = []

    for word in words:
        clean = word.strip(".,;:!?()[]")
        if clean.lower() in dictionary:
            corrected.append(word)
        else:
            flagged.append({
                "word": word,
                "position": len(corrected),
                "suggestion": "Manual review needed"
            })
            corrected.append(word)

    return {
        "total_words": len(words),
        "flagged_words": len(flagged),
        "estimated_accuracy": 1 - len(flagged) / max(len(words), 1),
        "flagged": flagged[:20],
        "correction_strategies": [
            "Dictionary-based spell checking (period-appropriate dictionary)",
            "N-gram language model for context-aware correction",
            "Crowdsourcing (Zooniverse, FromThePage)",
            "Double-keying (two independent transcribers, compare)",
            "AI-assisted correction with human verification"
        ]
    }
```

## Integration with Research Workflows

### From Transcription to Analysis

```
1. Transcribe documents using HTR
2. Correct and validate transcriptions
3. Encode in TEI-XML for digital editions
4. Apply NLP for named entity recognition, topic modeling
5. Link entities to knowledge bases (Wikidata, VIAF)
6. Publish as a searchable digital archive

Tools for TEI encoding:
  - oXygen XML Editor (standard for digital humanities)
  - TEI Publisher (web-based publishing platform)
  - FromThePage (collaborative transcription with TEI export)
```

## Evaluating HTR Accuracy

Report Character Error Rate (CER) and Word Error Rate (WER) on a held-out test set. CER below 5% is generally considered production-quality for historical documents. Always compare against a manually created ground truth. Report accuracy separately for different document types, hands, or time periods if your corpus is heterogeneous.
