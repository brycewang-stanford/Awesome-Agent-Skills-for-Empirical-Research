---
name: medical-imaging-guide
description: "Medical image analysis with deep learning for research applications"
metadata:
  openclaw:
    emoji: "🔬"
    category: "domains"
    subcategory: "biomedical"
    keywords: ["medical imaging", "deep learning", "image segmentation", "radiology AI", "pathology", "convolutional neural networks"]
    source: "wentor-research-plugins"
---

# Medical Imaging Guide

A skill for applying deep learning to medical image analysis in research settings. Covers common imaging modalities, preprocessing pipelines, architecture selection for classification and segmentation tasks, handling small datasets with transfer learning and data augmentation, evaluation metrics specific to medical imaging, and regulatory and ethical considerations for clinical translation.

## Imaging Modalities and Data Characteristics

### Common Modalities in Research

```
Modality Overview:

X-ray / Radiography:
  - 2D grayscale images
  - Resolution: typically 2000x2000 to 4000x4000 pixels
  - Format: DICOM (.dcm)
  - Common tasks: pneumonia detection, fracture detection,
    cardiomegaly screening
  - Dataset examples: CheXpert, MIMIC-CXR, NIH ChestX-ray14

CT (Computed Tomography):
  - 3D volumetric data (stack of 2D slices)
  - Resolution: 512x512 per slice, 50-500+ slices
  - Format: DICOM series, NIfTI (.nii.gz)
  - Common tasks: lung nodule detection, organ segmentation,
    COVID-19 screening
  - Dataset examples: LUNA16, DeepLesion, TotalSegmentator

MRI (Magnetic Resonance Imaging):
  - 3D volumetric, multiple sequences (T1, T2, FLAIR, DWI)
  - Resolution: 256x256 to 512x512 per slice
  - Format: DICOM, NIfTI
  - Common tasks: brain tumor segmentation, cardiac analysis,
    knee injury classification
  - Dataset examples: BraTS, ACDC, fastMRI

Histopathology:
  - Whole slide images (WSI), extremely large
  - Resolution: 100,000x100,000+ pixels at highest magnification
  - Format: SVS, TIFF, NDPI (vendor-specific)
  - Common tasks: cancer grading, mitosis detection,
    tissue classification
  - Dataset examples: Camelyon16/17, TCGA, PANDA

Retinal Imaging (Fundoscopy / OCT):
  - 2D color fundus or 3D OCT volumes
  - Common tasks: diabetic retinopathy grading, glaucoma detection
  - Dataset examples: EyePACS, MESSIDOR, REFUGE
```

## Preprocessing Pipeline

### Standard Preprocessing Steps

```python
import numpy as np

def preprocess_medical_image(image, modality="xray"):
    """
    Standard preprocessing pipeline for medical images.

    Steps vary by modality but typically include:
    1. Intensity normalization
    2. Resizing/resampling
    3. Windowing (for CT)
    4. Artifact removal
    """
    if modality == "ct":
        # CT windowing: map Hounsfield Units to display range
        # Lung window: center=-600, width=1500
        # Soft tissue: center=40, width=400
        window_center = -600
        window_width = 1500
        lower = window_center - window_width // 2
        upper = window_center + window_width // 2
        image = np.clip(image, lower, upper)
        image = (image - lower) / (upper - lower)

    elif modality == "xray":
        # Normalize to [0, 1] range
        image = image.astype(np.float32)
        image = (image - image.min()) / (image.max() - image.min() + 1e-8)

    elif modality == "mri":
        # Z-score normalization (per-volume)
        # Exclude background (zeros) from statistics
        mask = image > 0
        if mask.any():
            mean_val = image[mask].mean()
            std_val = image[mask].std()
            image = (image - mean_val) / (std_val + 1e-8)

    return image


def resize_with_spacing(image, original_spacing, target_spacing):
    """
    Resample 3D medical image to uniform voxel spacing.
    Essential for CT/MRI where slice thickness varies.

    Args:
        image: 3D numpy array
        original_spacing: (z, y, x) voxel sizes in mm
        target_spacing: desired (z, y, x) voxel sizes in mm
    """
    from scipy.ndimage import zoom

    resize_factor = [
        orig / target
        for orig, target in zip(original_spacing, target_spacing)
    ]
    resampled = zoom(image, resize_factor, order=1)
    return resampled
```

## Model Architecture Selection

### Task-Specific Architectures

```
Architecture recommendations by task:

IMAGE CLASSIFICATION (diagnosis, grading):
  - ResNet-50/101: reliable baseline, well-understood
  - EfficientNet-B4/B5: better accuracy-efficiency tradeoff
  - Vision Transformer (ViT): strong with large datasets
  - DenseNet-121: popular for chest X-ray (CheXNet heritage)

  Transfer learning approach:
    1. Start with ImageNet pretrained weights
    2. Replace final classifier layer
    3. Fine-tune with low learning rate (1e-4 to 1e-5)
    4. Use gradual unfreezing (train head, then all layers)

IMAGE SEGMENTATION (organ/lesion delineation):
  - U-Net: gold standard for medical segmentation
  - nnU-Net: self-configuring U-Net (state-of-the-art framework)
  - Attention U-Net: U-Net with attention gates
  - TransUNet: hybrid CNN-Transformer architecture
  - MONAI: framework with pre-built medical imaging models

  For 3D volumes:
    - 3D U-Net: full volumetric processing
    - V-Net: 3D with dice loss
    - 2.5D approach: adjacent slices as multi-channel input

OBJECT DETECTION (lesion localization):
  - YOLO variants: fast inference, suitable for screening
  - Faster R-CNN: higher accuracy, slower
  - RetinaNet: handles class imbalance (focal loss)
  - DETR: transformer-based, no anchor boxes needed
```

## Handling Small Datasets

### Data Augmentation for Medical Images

```python
def get_medical_augmentation_pipeline():
    """
    Medical image augmentation strategy.

    Key differences from natural image augmentation:
    - Preserve anatomical plausibility
    - Avoid color jitter (intensity has diagnostic meaning)
    - Use elastic deformations (mimic anatomical variability)
    - Apply carefully (aggressive augmentation can hurt)
    """
    import albumentations as A

    transform = A.Compose([
        # Spatial transforms (safe for medical images)
        A.HorizontalFlip(p=0.5),
        A.RandomRotate90(p=0.5),
        A.ShiftScaleRotate(
            shift_limit=0.1, scale_limit=0.1,
            rotate_limit=15, p=0.5
        ),
        A.ElasticTransform(
            alpha=120, sigma=120 * 0.05,
            p=0.3
        ),

        # Intensity transforms (use cautiously)
        A.RandomBrightnessContrast(
            brightness_limit=0.1,
            contrast_limit=0.1, p=0.3
        ),
        A.GaussNoise(var_limit=(10, 50), p=0.2),
        A.GaussianBlur(blur_limit=(3, 5), p=0.2),
    ])

    return transform
```

### Transfer Learning Strategies

```
Transfer learning approaches for small medical datasets:

Strategy 1 - ImageNet pretraining (most common):
  - Works surprisingly well despite domain gap
  - Low-level features (edges, textures) transfer well
  - Fine-tune all layers with small learning rate
  - Typical improvement: 5-15% over training from scratch

Strategy 2 - Medical domain pretraining:
  - Pretrain on large medical dataset, fine-tune on target
  - RadImageNet: 1.35M radiological images
  - Models Genesis: self-supervised pretraining on CT/X-ray
  - Better than ImageNet for most medical tasks

Strategy 3 - Self-supervised pretraining:
  - Contrastive learning (SimCLR, MoCo, DINO)
  - Masked image modeling (MAE)
  - No labels needed for pretraining phase
  - Effective when labeled data is very scarce (< 100 images)

Strategy 4 - Few-shot learning:
  - Prototypical networks, MAML
  - Useful for rare diseases with < 20 examples
  - Active research area, not yet production-ready
```

## Evaluation Metrics

### Medical Imaging Specific Metrics

```
Classification metrics:
  - AUROC (Area Under ROC Curve): discrimination ability
    - Primary metric for most medical imaging papers
    - Report with 95% confidence interval (bootstrap)
  - AUPRC (Area Under Precision-Recall Curve):
    - Better than AUROC for imbalanced datasets
    - Common in lesion detection tasks
  - Sensitivity at fixed specificity:
    - e.g., "Sensitivity of 92% at 95% specificity"
    - Clinically meaningful operating point
  - Specificity at fixed sensitivity:
    - e.g., "Specificity of 88% at 90% sensitivity"
    - Ensures acceptable miss rate

Segmentation metrics:
  - Dice Similarity Coefficient (DSC):
    - DSC = 2|A intersection B| / (|A| + |B|)
    - Range: 0 (no overlap) to 1 (perfect overlap)
    - Most commonly reported segmentation metric
  - Hausdorff Distance (HD95):
    - Maximum surface distance between predictions and ground truth
    - Use 95th percentile (HD95) to reduce sensitivity to outliers
    - Reports boundary accuracy in millimeters
  - Average Surface Distance (ASD):
    - Mean distance between predicted and true surfaces

Reporting standards:
  - Always report confidence intervals (95% CI)
  - Use 5-fold cross-validation or held-out test set
  - Report per-class metrics for multi-class problems
  - Compare against at least one established baseline
  - Report results on external validation set when possible
```

## Ethical and Regulatory Considerations

```
Responsible AI in medical imaging research:

Data ethics:
  - De-identify all DICOM headers (remove patient name, ID, dates)
  - Use approved de-identification tools (e.g., DICOM Cleaner)
  - Obtain IRB/ethics approval before starting
  - Data use agreements for public datasets

Bias and fairness:
  - Report demographic breakdown of training data
  - Test performance across subgroups (age, sex, ethnicity)
  - Acknowledge known demographic biases in training data
  - CheXpert and MIMIC-CXR include demographic metadata for this

Reproducibility:
  - Share code and trained model weights when possible
  - Report all hyperparameters and random seeds
  - Use standardized evaluation protocols
  - Follow CLAIM (Checklist for AI in Medical Imaging) guidelines

Clinical translation (if applicable):
  - FDA/CE marking required for clinical use (not research)
  - Software as Medical Device (SaMD) classification
  - Prospective clinical validation required
  - Research prototypes are NOT approved for clinical decisions
```

Medical imaging AI is advancing rapidly, but responsible research requires careful attention to data quality, evaluation rigor, and clinical relevance. The gap between a model that performs well on a benchmark and one that adds genuine clinical value remains significant, and bridging it requires interdisciplinary collaboration between computer scientists, radiologists, pathologists, and clinical researchers.
