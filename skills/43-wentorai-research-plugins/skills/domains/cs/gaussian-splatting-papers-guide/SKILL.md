---
name: gaussian-splatting-papers-guide
description: "Curated papers and resources for 3D Gaussian Splatting"
metadata:
  openclaw:
    emoji: "🔮"
    category: "domains"
    subcategory: "cs"
    keywords: ["3D Gaussian Splatting", "3DGS", "neural rendering", "NeRF", "novel view synthesis", "point cloud"]
    source: "https://github.com/MrNeRF/awesome-3D-gaussian-splatting"
---

# 3D Gaussian Splatting Papers Guide

## Overview

3D Gaussian Splatting (3DGS) is a breakthrough technique for real-time radiance field rendering that represents scenes as collections of 3D Gaussians. This curated collection tracks the rapidly evolving 3DGS literature — from the original paper through extensions for dynamic scenes, generation, compression, SLAM, avatars, and more. Essential for researchers in computer vision, graphics, and neural rendering.

## Core Paper

```bibtex
@inproceedings{kerbl3Dgaussians,
  title={3D Gaussian Splatting for Real-Time Radiance Field Rendering},
  author={Kerbl, Bernhard and Kopanas, Georgios and Leimk{\"u}hler, Thomas
          and Drettakis, George},
  booktitle={ACM SIGGRAPH 2023},
  year={2023}
}
```

### Key Idea

```
Input: Multi-view images + SfM point cloud
  ↓
Initialize 3D Gaussians (position, covariance, color, opacity)
  ↓
Differentiable splatting (project Gaussians → image plane)
  ↓
Optimize via photometric loss
  ↓
Adaptive density control (clone, split, prune)
  ↓
Output: Real-time renderable 3D scene (100+ FPS)
```

## Research Landscape

### Category Map

| Category | Focus | Key Papers |
|----------|-------|------------|
| **Static Scenes** | Quality, compression, anti-aliasing | Mip-Splatting, Compact3D |
| **Dynamic Scenes** | Deformable, 4D, temporal | Dynamic3DGS, 4DGS, Deformable3DGS |
| **Generation** | Text/image to 3D | DreamGaussian, GaussianDreamer, LGM |
| **SLAM** | Real-time mapping | SplaTAM, Gaussian-SLAM, MonoGS |
| **Avatars** | Human body/face | GaussianAvatar, HUGS, SplatFace |
| **Autonomous Driving** | Street scenes | StreetGaussians, DriveGS |
| **Compression** | Storage efficiency | LightGaussian, CompGS |
| **Editing** | Scene manipulation | GaussianEditor, GSEditor |
| **Physics** | Simulation, deformation | PhysGaussian, Gaussian Splashing |
| **Language** | 3D understanding | LangSplat, LEGaussians |

## Tracking New Papers

```python
import requests
from datetime import datetime, timedelta

# Search arXiv for recent 3DGS papers
def search_3dgs_papers(days_back=7):
    """Find recent 3D Gaussian Splatting papers on arXiv."""
    import arxiv

    query = (
        "ti:gaussian splatting OR "
        "abs:3D gaussian splatting OR "
        "abs:3DGS"
    )

    search = arxiv.Search(
        query=query,
        max_results=50,
        sort_by=arxiv.SortCriterion.SubmittedDate,
    )

    cutoff = datetime.now() - timedelta(days=days_back)
    papers = []
    for result in search.results():
        if result.published.replace(tzinfo=None) > cutoff:
            papers.append({
                "title": result.title,
                "authors": [a.name for a in result.authors[:3]],
                "url": result.entry_id,
                "published": result.published.strftime("%Y-%m-%d"),
                "categories": result.categories,
            })
    return papers

recent = search_3dgs_papers(days_back=14)
for p in recent:
    print(f"[{p['published']}] {p['title']}")
    print(f"  {', '.join(p['authors'])} | {p['url']}")
```

## Key Methods Comparison

```python
# Performance comparison (from original benchmarks)
methods = {
    "NeRF": {"psnr": 31.01, "fps": 0.03, "train_time": "hours"},
    "Instant-NGP": {"psnr": 33.18, "fps": 9.43, "train_time": "5 min"},
    "3DGS": {"psnr": 33.31, "fps": 134, "train_time": "6 min"},
    "Mip-Splatting": {"psnr": 33.46, "fps": 120, "train_time": "7 min"},
}

print(f"{'Method':<16} {'PSNR':>6} {'FPS':>8} {'Training':>10}")
print("-" * 44)
for name, m in methods.items():
    print(f"{name:<16} {m['psnr']:>6.2f} {m['fps']:>8.2f} "
          f"{m['train_time']:>10}")
```

## Implementation Resources

```bash
# Original implementation
git clone https://github.com/graphdeco-inria/gaussian-splatting
cd gaussian-splatting
pip install -r requirements.txt

# Train on custom scene
python train.py -s path/to/colmap/data

# Real-time viewer
./SIBR_viewers/bin/SIBR_gaussianViewer_app \
  -m output/trained_model
```

## Survey Papers

1. **"A Survey on 3D Gaussian Splatting"** (Chen et al., 2024) — comprehensive taxonomy
2. **"3DGS: Recent Developments and Applications"** (Wu et al., 2024) — application-focused
3. **"Gaussian Splatting: A Survey"** (Fei et al., 2024) — technical deep dive

## Use Cases

1. **Novel view synthesis**: Photo-realistic rendering from sparse views
2. **Real-time visualization**: Interactive 3D scene exploration
3. **Digital twins**: Rapid scene reconstruction for simulation
4. **VR/AR content**: Real-time immersive experiences
5. **Autonomous driving**: Street-level scene understanding

## References

- [awesome-3D-gaussian-splatting](https://github.com/MrNeRF/awesome-3D-gaussian-splatting)
- [Original 3DGS](https://repo-sam.inria.fr/fungraph/3d-gaussian-splatting/)
- [3DGS Papers Collection](https://3dgaussians.github.io/)
