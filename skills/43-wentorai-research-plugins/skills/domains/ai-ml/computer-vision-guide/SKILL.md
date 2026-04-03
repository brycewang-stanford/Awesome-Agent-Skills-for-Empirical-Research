---
name: computer-vision-guide
description: "Apply computer vision research methods, models, and evaluation tools"
metadata:
  openclaw:
    emoji: "👁️"
    category: "domains"
    subcategory: "ai-ml"
    keywords: ["computer vision", "image classification", "object detection", "CNN", "vision transformer", "deep learning"]
    source: "wentor-research-plugins"
---

# Computer Vision Guide

A skill for conducting computer vision research, covering model architectures, dataset preparation, training pipelines, evaluation metrics, and common experimental protocols for image classification, object detection, and segmentation tasks.

## Core Tasks and Architectures

### Computer Vision Task Taxonomy

```
Image Classification:
  Input: Single image
  Output: Class label(s)
  Models: ResNet, EfficientNet, ViT, ConvNeXt

Object Detection:
  Input: Single image
  Output: Bounding boxes + class labels
  Models: YOLO (v5-v9), Faster R-CNN, DETR, RT-DETR

Semantic Segmentation:
  Input: Single image
  Output: Per-pixel class label
  Models: U-Net, DeepLab, SegFormer, Mask2Former

Instance Segmentation:
  Input: Single image
  Output: Per-pixel labels distinguishing individual objects
  Models: Mask R-CNN, Mask2Former, SAM

Image Generation:
  Input: Text prompt or noise
  Output: Generated image
  Models: Stable Diffusion, DALL-E, Imagen
```

### Model Architecture Evolution

```
CNNs (Convolutional Neural Networks):
  LeNet (1998) -> AlexNet (2012) -> VGG (2014) -> ResNet (2015)
  -> EfficientNet (2019) -> ConvNeXt (2022)

Vision Transformers:
  ViT (2020) -> DeiT (2021) -> Swin Transformer (2021)
  -> BEiT (2021) -> DINOv2 (2023)

Trend: Transformers are competitive with CNNs at scale.
Hybrid architectures combining convolutions and attention are common.
```

## Dataset Preparation

### Building a Research Dataset

```python
import os
from pathlib import Path


def organize_image_dataset(source_dir: str,
                            split_ratios: dict = None) -> dict:
    """
    Organize images into train/val/test splits.

    Args:
        source_dir: Directory containing class subdirectories
        split_ratios: Dict with 'train', 'val', 'test' ratios
    """
    if split_ratios is None:
        split_ratios = {"train": 0.7, "val": 0.15, "test": 0.15}

    import random
    random.seed(42)

    stats = {}
    for class_dir in sorted(Path(source_dir).iterdir()):
        if not class_dir.is_dir():
            continue

        images = list(class_dir.glob("*.jpg")) + list(class_dir.glob("*.png"))
        random.shuffle(images)

        n = len(images)
        n_train = int(n * split_ratios["train"])
        n_val = int(n * split_ratios["val"])

        stats[class_dir.name] = {
            "total": n,
            "train": n_train,
            "val": n_val,
            "test": n - n_train - n_val
        }

    return stats
```

### Data Augmentation

```python
from torchvision import transforms


def get_training_transforms(img_size: int = 224) -> transforms.Compose:
    """
    Standard data augmentation pipeline for training.

    Args:
        img_size: Target image size
    """
    return transforms.Compose([
        transforms.RandomResizedCrop(img_size, scale=(0.8, 1.0)),
        transforms.RandomHorizontalFlip(p=0.5),
        transforms.ColorJitter(brightness=0.2, contrast=0.2,
                               saturation=0.2, hue=0.1),
        transforms.RandomRotation(15),
        transforms.ToTensor(),
        transforms.Normalize(
            mean=[0.485, 0.456, 0.406],
            std=[0.229, 0.224, 0.225]
        )
    ])
```

## Training Pipeline

### Transfer Learning Workflow

```python
import torch
import torch.nn as nn
from torchvision import models


def create_classifier(num_classes: int,
                      backbone: str = "resnet50",
                      pretrained: bool = True) -> nn.Module:
    """
    Create an image classifier using transfer learning.

    Args:
        num_classes: Number of target classes
        backbone: Model architecture name
        pretrained: Whether to use ImageNet-pretrained weights
    """
    if backbone == "resnet50":
        weights = models.ResNet50_Weights.DEFAULT if pretrained else None
        model = models.resnet50(weights=weights)
        model.fc = nn.Linear(model.fc.in_features, num_classes)
    elif backbone == "vit_b_16":
        weights = models.ViT_B_16_Weights.DEFAULT if pretrained else None
        model = models.vit_b_16(weights=weights)
        model.heads.head = nn.Linear(
            model.heads.head.in_features, num_classes
        )
    else:
        raise ValueError(f"Unknown backbone: {backbone}")

    return model
```

## Evaluation Metrics

### Metrics by Task

```
Classification:
  - Top-1 Accuracy: Fraction of correct predictions
  - Top-5 Accuracy: Correct class in top 5 predictions
  - Precision, Recall, F1: Per-class and macro-averaged
  - Confusion Matrix: Visualize class-level errors

Object Detection:
  - mAP (mean Average Precision): Standard COCO metric
  - mAP@0.5: AP at IoU threshold 0.5
  - mAP@0.5:0.95: AP averaged over IoU thresholds 0.5 to 0.95
  - AP per class: Identifies weak categories

Segmentation:
  - mIoU (mean Intersection over Union): Standard metric
  - Pixel Accuracy: Fraction of correctly classified pixels
  - Dice Coefficient: F1 score at the pixel level
```

## Reproducibility Checklist

### What to Report in Papers

```
1. Architecture: Exact model name, number of parameters
2. Pretraining: Dataset and weights used for initialization
3. Training: Optimizer, learning rate schedule, batch size, epochs
4. Augmentation: Full list of augmentations with parameters
5. Hardware: GPU type, number, training time
6. Evaluation: Exact metrics, test set version, evaluation protocol
7. Code: Link to repository with training and evaluation scripts
8. Random seeds: Report seeds used; ideally report mean over 3+ seeds
```

## Ethical Considerations

When collecting or using image datasets, consider consent (especially for images of people), geographic and demographic representation, potential for bias amplification, and dual-use concerns. Document the dataset's composition and limitations. Follow the Datasheets for Datasets framework. For generative models, implement safeguards against generating harmful content.
