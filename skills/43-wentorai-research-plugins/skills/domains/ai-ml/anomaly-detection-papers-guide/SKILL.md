---
name: anomaly-detection-papers-guide
description: "Industrial anomaly detection methods and benchmark papers"
metadata:
  openclaw:
    emoji: "🔍"
    category: "domains"
    subcategory: "ai-ml"
    keywords: ["anomaly detection", "industrial inspection", "defect detection", "MVTec", "unsupervised AD", "visual inspection"]
    source: "https://github.com/M-3LAB/awesome-industrial-anomaly-detection"
---

# Industrial Anomaly Detection Papers Guide

## Overview

Industrial anomaly detection uses machine learning to identify defects, faults, and anomalies in manufacturing and quality inspection. This curated collection covers methods from reconstruction-based (autoencoders) to memory-bank approaches (PatchCore), normalizing flows, knowledge distillation, and foundation model-based detectors. Includes benchmark datasets, evaluation metrics, and real-world deployment considerations.

## Method Taxonomy

```
Anomaly Detection Methods
├── Reconstruction-based
│   ├── Autoencoder (AE, VAE)
│   ├── GAN-based (AnoGAN, GANomaly)
│   └── Diffusion-based (AnoDDPM)
├── Embedding-based
│   ├── Memory bank (PatchCore, PaDiM)
│   ├── Knowledge distillation (STPM, RD4AD)
│   └── Self-supervised (CutPaste, DRAEM)
├── Normalizing Flows
│   ├── FastFlow, CFLOW-AD, CS-Flow
│   └── DifferNet
├── Foundation Models
│   ├── CLIP-based (WinCLIP, AnomalyCLIP)
│   ├── SAM-based (GroundedSAM-AD)
│   └── Vision-language (AnomalyGPT)
└── 3D Anomaly Detection
    ├── Point cloud methods
    └── Multi-modal (RGB + 3D)
```

## Key Methods

| Method | Year | Approach | MVTec AUROC |
|--------|------|----------|-------------|
| **PatchCore** | 2022 | Memory bank | 99.1% |
| **PaDiM** | 2021 | Multivariate Gaussian | 97.9% |
| **RD4AD** | 2022 | Knowledge distillation | 98.5% |
| **FastFlow** | 2022 | Normalizing flow | 99.4% |
| **SimpleNet** | 2023 | Feature adaptation | 99.6% |
| **WinCLIP** | 2023 | CLIP zero-shot | 95.2% |
| **AnomalyGPT** | 2024 | Vision-language | 96.3% |

## Benchmark Datasets

```python
benchmarks = {
    "MVTec AD": {
        "categories": 15,
        "images": 5354,
        "type": "Product/texture defects",
        "annotation": "Pixel-level masks",
    },
    "MVTec 3D-AD": {
        "categories": 10,
        "images": 4147,
        "type": "3D point cloud + RGB",
    },
    "VisA": {
        "categories": 12,
        "images": 10821,
        "type": "Complex structure anomalies",
    },
    "BTAD": {
        "categories": 3,
        "images": 2830,
        "type": "Industrial body/surface",
    },
    "MPDD": {
        "categories": 6,
        "images": 1064,
        "type": "Metal parts defects",
    },
}

for name, info in benchmarks.items():
    print(f"{name}: {info['categories']} categories, "
          f"{info['images']} images — {info['type']}")
```

## Quick Implementation

```python
# PatchCore-style anomaly detection
from anomalib.data import MVTec
from anomalib.models import Patchcore
from anomalib.engine import Engine

# Setup dataset
datamodule = MVTec(
    root="./datasets/MVTec",
    category="bottle",
    image_size=(256, 256),
)

# Initialize model
model = Patchcore(
    backbone="wide_resnet50_2",
    layers=["layer2", "layer3"],
    coreset_sampling_ratio=0.1,
)

# Train and test
engine = Engine()
engine.fit(model=model, datamodule=datamodule)
results = engine.test(model=model, datamodule=datamodule)
print(f"Image AUROC: {results[0]['image_AUROC']:.3f}")
print(f"Pixel AUROC: {results[0]['pixel_AUROC']:.3f}")
```

## Evaluation Metrics

```python
# Standard anomaly detection metrics
from sklearn.metrics import roc_auc_score
import numpy as np

# Image-level: Is this image anomalous?
image_auroc = roc_auc_score(y_true_image, y_score_image)

# Pixel-level: Where is the anomaly?
pixel_auroc = roc_auc_score(
    y_true_pixel.flatten(), y_score_pixel.flatten()
)

# PRO metric: Per-Region Overlap
# Better than pixel AUROC for small anomalies
# Weights each connected anomaly region equally
```

## Research Frontiers

```markdown
### Active Directions (2024-2025)
1. **Zero/few-shot AD** — Detect anomalies without normal training data
2. **Multi-class unified** — One model for all product categories
3. **Foundation model AD** — CLIP/SAM/LLM-based detection
4. **Logical anomalies** — Structural/contextual defects
5. **Continual learning** — Adapt to new defect types
6. **3D anomaly detection** — Point cloud and multi-modal
7. **Real-time deployment** — Edge device optimization
```

## Use Cases

1. **Manufacturing QC**: Automated visual inspection pipelines
2. **Research benchmarking**: Compare new methods on standard datasets
3. **Survey writing**: Comprehensive method taxonomy and comparison
4. **Course teaching**: Industrial AI and computer vision curricula
5. **Defect analysis**: Understanding failure modes and patterns

## References

- [awesome-industrial-anomaly-detection](https://github.com/M-3LAB/awesome-industrial-anomaly-detection)
- [Anomalib Library](https://github.com/openvinotoolkit/anomalib)
- [MVTec AD Dataset](https://www.mvtec.com/company/research/datasets/mvtec-ad)
