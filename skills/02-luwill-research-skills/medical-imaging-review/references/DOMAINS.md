<!--
  ╔══════════════════════════════════════════════════════════════╗
  ║  本文件为开源 Skill 原始文档，收录仅供学习与研究参考        ║
  ║  CoPaper.AI 收集整理 | https://copaper.ai                  ║
  ╚══════════════════════════════════════════════════════════════╝

  来源仓库: https://github.com/luwill/research-skills
  项目名称: research-skills
  开源协议: MIT License
  收录日期: 2026-04-02

  声明: 本文件版权归原作者所有。此处收录旨在为社会科学实证研究者
  提供 AI Agent Skills 的集中参考。如有侵权，请联系删除。
-->

# Domain-Specific Method Categories

## Coronary Artery Analysis (CCTA)

### Segmentation Methods
1. General CNN/U-Net
2. Vision Transformer
3. Topology-aware (clDice, VCP Loss)
4. Multi-task Learning
5. Semi-supervised
6. Graph Neural Networks
7. Diffusion Models
8. Mamba/State Space Models
9. Foundation Models (SAM, vesselFM)
10. Physics-Informed Neural Networks

### Downstream Tasks
- Centerline extraction
- Vessel labeling (AHA 17-segment)
- Stenosis detection
- CT-FFR computation
- Plaque analysis
- Calcium scoring
- Pericoronary fat analysis (FAI)

### Key Datasets
- CAT08 (32 cases, centerline)
- ASOCA (40 cases, segmentation)
- ImageCAS (1000 cases, segmentation)
- PCCTA120 (120 cases, artery + plaque)

---

## Lung Imaging (CT/X-ray)

### Detection Methods
1. Anchor-based (Faster R-CNN, RetinaNet)
2. Anchor-free (CenterNet, FCOS)
3. Transformer-based (DETR variants)
4. 3D Detection Networks
5. Multi-scale Feature Pyramids

### Segmentation Methods
1. U-Net variants
2. Attention mechanisms
3. Boundary-aware methods
4. Uncertainty quantification

### Tasks
- Nodule detection
- Nodule segmentation
- Malignancy classification
- COVID-19 detection
- Interstitial lung disease

### Key Datasets
- LUNA16 (888 CT scans)
- LIDC-IDRI (1018 cases)
- ChestX-ray14 (112,120 X-rays)
- COVID-CT (349 CT scans)

---

## Brain Imaging (MRI/CT)

### Segmentation Methods
1. Multi-atlas methods
2. CNN-based (U-Net, V-Net)
3. Attention mechanisms
4. Graph neural networks
5. Self-supervised pre-training

### Tasks
- Brain tissue segmentation
- Tumor segmentation (BraTS)
- Lesion detection (stroke, MS)
- Vessel segmentation
- Age estimation

### Key Datasets
- BraTS (brain tumor)
- ADNI (Alzheimer's)
- IXI (healthy brains)
- ISLES (stroke lesions)

---

## Cardiac Imaging (MRI/CT/Echo)

### Segmentation Methods
1. Temporal modeling (RNN, 3D CNN)
2. Shape priors
3. Multi-view fusion
4. Uncertainty estimation

### Tasks
- Chamber segmentation
- Wall motion analysis
- Scar/fibrosis detection
- Valve assessment
- Strain analysis

### Key Datasets
- ACDC (100 patients)
- M&Ms (320 subjects)
- CAMUS (500 patients, echo)

---

## Pathology (Whole Slide Images)

### Methods
1. Patch-based CNN
2. Multiple Instance Learning
3. Attention-based aggregation
4. Graph neural networks
5. Foundation models (PathLM)

### Tasks
- Cancer detection
- Grading/staging
- Biomarker prediction
- Survival prediction

### Key Datasets
- CAMELYON (lymph node)
- TCGA (multi-cancer)
- PANDA (prostate)

---

## Retinal Imaging (Fundus/OCT)

### Methods
1. Multi-scale networks
2. Attention mechanisms
3. Domain adaptation
4. Federated learning

### Tasks
- Diabetic retinopathy grading
- Glaucoma detection
- Age-related macular degeneration
- Vessel segmentation

### Key Datasets
- EyePACS (88,702 images)
- DRIVE (40 images, vessels)
- REFUGE (1200 images, glaucoma)

---

## General Medical Image Segmentation

### Universal Method Categories
1. **Encoder-Decoder** (U-Net, V-Net, nnU-Net)
2. **Attention Mechanisms** (SE, CBAM, Transformers)
3. **Multi-scale Processing** (FPN, PSP, ASPP)
4. **Boundary-aware** (Active contours, edge losses)
5. **Topology-preserving** (clDice, persistent homology)
6. **Uncertainty Quantification** (MC Dropout, ensembles)
7. **Domain Adaptation** (adversarial, self-training)
8. **Few-shot/Zero-shot** (prototypical, foundation models)
9. **Self-supervised Pre-training** (contrastive, masked)
10. **Efficient Architectures** (MobileNet, EfficientNet, Mamba)

### Universal Evaluation Metrics
- **Overlap**: Dice, IoU/Jaccard
- **Distance**: Hausdorff (HD, HD95), ASSD
- **Topology**: clDice, Betti numbers
- **Clinical**: Sensitivity, Specificity, AUC
