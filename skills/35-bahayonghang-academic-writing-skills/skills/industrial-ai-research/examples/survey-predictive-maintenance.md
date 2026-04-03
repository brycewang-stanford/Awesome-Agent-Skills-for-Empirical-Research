# Example: Survey Draft — Predictive Maintenance with Deep Learning

This example demonstrates the complete `survey-draft` workflow from intake to final merge.

## User Prompt

> I need a survey on deep learning methods for predictive maintenance in manufacturing.
> Focus on vibration-based and multi-modal approaches from the last 3 years.

## Intake Answers

| Question | Answer |
|----------|--------|
| Report language | English |
| Deliverable | survey-draft |
| Time window | Last 3 years |
| Industrial AI emphasis | Predictive maintenance |
| Target audience | Researchers new to the subfield |
| Output format | Markdown only |
| Target length | Standard survey (5000–10000 words) |

## Phase S1: Outline

### Expected taxonomy.md (excerpt)

```markdown
# Taxonomy: Deep Learning for Predictive Maintenance

## Classification Axes

- Axis 1: Signal modality — the type of sensor data used as primary input
- Axis 2: Method family — the core deep learning architecture

## Paper-to-Cell Mapping

| Paper ID | First Author | Year | Signal Modality | Method Family | Primary Cell |
|----------|-------------|------|-----------------|---------------|-------------|
| pdm-01 | Zhang | 2024 | Vibration | CNN | Vibration × CNN |
| pdm-02 | Li | 2024 | Vibration | Transformer | Vibration × Transformer |
| pdm-03 | Wang | 2023 | Multi-modal | Hybrid | Multi-modal × Hybrid |
| pdm-04 | Kim | 2024 | Acoustic | CNN | Acoustic × CNN |
| pdm-05 | Chen | 2023 | Current | Physics-informed | Current × Physics-informed |
```

### Expected outline.yml (excerpt)

```yaml
title: "Survey: Deep Learning for Predictive Maintenance in Manufacturing"
audience: researchers_new
length_tier: standard
taxonomy:
  axis_1: "Signal modality"
  axis_2: "Method family"
sections:
  - id: S1
    title: "Introduction"
    type: front-matter
    guidance: "Motivation for DL-based PdM, limitations of traditional approaches, contribution of this survey"
  - id: S2
    title: "Background and Scope"
    type: front-matter
    guidance: "PdM problem formulation, DL basics for time-series, search methodology"
  - id: S3
    title: "Vibration-Based Methods"
    type: body
    subsections:
      - id: S3.1
        title: "CNN Architectures for Vibration Signals"
        paper_count: 8
        key_papers: ["pdm-01", "pdm-06", "pdm-11"]
      - id: S3.2
        title: "Transformer and Attention Models"
        paper_count: 6
        key_papers: ["pdm-02", "pdm-07"]
      - id: S3.3
        title: "Physics-Informed Hybrid Models"
        paper_count: 4
        key_papers: ["pdm-08", "pdm-12"]
  - id: S4
    title: "Acoustic and Current-Based Methods"
    type: body
    subsections:
      - id: S4.1
        title: "Acoustic Emission Analysis"
        paper_count: 5
        key_papers: ["pdm-04", "pdm-13"]
      - id: S4.2
        title: "Motor Current Signature Analysis"
        paper_count: 4
        key_papers: ["pdm-05", "pdm-14"]
  - id: S5
    title: "Multi-Modal Fusion Approaches"
    type: body
    subsections:
      - id: S5.1
        title: "Early and Late Fusion Strategies"
        paper_count: 5
        key_papers: ["pdm-03", "pdm-15"]
      - id: S5.2
        title: "Cross-Modal Attention Mechanisms"
        paper_count: 3
        key_papers: ["pdm-16", "pdm-17"]
  - id: S6
    title: "Comparative Analysis"
    type: analysis
  - id: S7
    title: "Open Challenges and Future Directions"
    type: discussion
  - id: S8
    title: "Conclusion"
    type: closing
```

## Phase S2: Evidence Pack (excerpt for S3.1)

```markdown
# Evidence Pack: S3.1 — CNN Architectures for Vibration Signals

## Claim Candidates

- **1D-CNN outperforms traditional features on CWRU**: pdm-01 — "The proposed 1D-CNN achieved 99.2% accuracy on the CWRU bearing dataset, outperforming SVM (94.1%) and random forest (92.7%)."
- **Multi-scale CNN captures frequency patterns**: pdm-06 — "Multi-scale convolutional filters at 32, 64, and 128 kernel sizes capture both local transient events and global frequency patterns."
- **Transfer learning reduces labeled data need**: pdm-11 — "Pre-training on a source domain with abundant labels and fine-tuning on the target domain with only 50 labeled samples achieved 96.8% accuracy."
- **Lightweight CNN for edge deployment**: pdm-18 — "The pruned CNN model (0.3M parameters) runs at 15ms inference on Raspberry Pi 4, enabling real-time bearing monitoring."
- **Attention-augmented CNN**: pdm-19 — "Adding channel attention to ResNet-18 improved F1-score from 0.94 to 0.97 on the Paderborn bearing dataset."

## Comparison Table

| Paper | Method | Dataset | Key Metric | Result | Deployment Evidence |
|-------|--------|---------|------------|--------|---------------------|
| pdm-01 | 1D-CNN | CWRU | Accuracy | 99.2% | None |
| pdm-06 | Multi-scale CNN | CWRU + Paderborn | Accuracy | 99.5% | Simulation |
| pdm-11 | Transfer CNN | CWRU → Factory | Accuracy | 96.8% | Pilot |
| pdm-18 | Pruned CNN | CWRU | Accuracy / Latency | 98.1% / 15ms | Production (edge) |
| pdm-19 | Attention-CNN | Paderborn | F1-score | 0.97 | None |

## Anchor Facts

- 99.2% accuracy on CWRU with 1D-CNN: pdm-01
- 50 labeled samples sufficient for transfer: pdm-11
- 15ms inference on Raspberry Pi 4: pdm-18
- 0.3M parameters after pruning: pdm-18

## Gaps and Limitations

- **Cross-domain generalization**: pdm-01, pdm-06 — models validated only on CWRU; real factory data may differ significantly.
- **Label scarcity**: pdm-11 — transfer learning helps but requires a well-labeled source domain.

## Allowed Citations

- **Primary**: pdm-01, pdm-06, pdm-11, pdm-18, pdm-19
- **Chapter-level**: pdm-02, pdm-08, pdm-12
- **Global**: pdm-03

## Evidence Density Flag

- Status: SUFFICIENT
```

## Phase S3: Draft (excerpt for S3.1)

```markdown
## CNN Architectures for Vibration Signals

Convolutional neural networks have become the dominant architecture for vibration-based
predictive maintenance, largely due to their ability to extract hierarchical features
directly from raw or minimally processed time-series signals.

Zhang et al. [pdm-01] demonstrated that a straightforward 1D-CNN achieves 99.2% accuracy
on the CWRU bearing dataset, substantially outperforming traditional machine learning
baselines including SVM (94.1%) and random forest (92.7%). Building on this foundation,
Li et al. [pdm-06] introduced multi-scale convolutional filters at kernel sizes of 32, 64,
and 128, capturing both local transient events and global frequency patterns, which pushed
accuracy to 99.5% across both CWRU and Paderborn benchmarks.

A persistent challenge in industrial PdM is the scarcity of labeled fault data. Wang et al.
[pdm-11] addressed this through transfer learning, pre-training on a source domain with
abundant labels and fine-tuning on a target factory domain with only 50 labeled samples,
achieving 96.8% accuracy — a result that suggests practical deployment is feasible even
with minimal target-domain annotation.

| Paper | Method | Dataset | Key Metric | Result | Deployment |
|-------|--------|---------|------------|--------|------------|
| pdm-01 | 1D-CNN | CWRU | Accuracy | 99.2% | None |
| pdm-06 | Multi-scale CNN | CWRU + Paderborn | Accuracy | 99.5% | Simulation |
| pdm-11 | Transfer CNN | CWRU → Factory | Accuracy | 96.8% | Pilot |
| pdm-18 | Pruned CNN | CWRU | Acc / Latency | 98.1% / 15ms | Production |
| pdm-19 | Attention-CNN | Paderborn | F1-score | 0.97 | None |

For edge deployment, Kim et al. [pdm-18] demonstrated that a pruned CNN with only 0.3M
parameters achieves 98.1% accuracy while running at 15ms inference on a Raspberry Pi 4,
enabling real-time bearing monitoring in resource-constrained environments. Park et al.
[pdm-19] further showed that augmenting ResNet-18 with channel attention improves F1-score
from 0.94 to 0.97 on the Paderborn dataset, suggesting that attention mechanisms offer a
low-cost accuracy boost without significant computational overhead.

Despite these advances, most CNN-based PdM studies rely heavily on the CWRU benchmark
[pdm-01, pdm-06], raising concerns about cross-domain generalization to real factory
conditions where noise profiles, operating regimes, and fault modes differ substantially.
```

## Phase S4: Final Output Structure

```
output-dir/
├── outline.yml
├── taxonomy.md
├── evidence/
│   ├── s3-1-cnn-vibration.md
│   ├── s3-2-transformer-vibration.md
│   ├── s3-3-physics-informed.md
│   ├── s4-1-acoustic.md
│   ├── s4-2-current.md
│   ├── s5-1-fusion-strategies.md
│   └── s5-2-cross-modal-attention.md
├── citation-map.md
├── drafts/
│   ├── s1-introduction.md
│   ├── s2-background.md
│   ├── s3-vibration-methods.md
│   ├── s4-acoustic-current.md
│   ├── s5-multi-modal.md
│   ├── s6-comparative-analysis.md
│   ├── s7-challenges.md
│   └── s8-conclusion.md
├── survey-draft.md
└── quality-report.md
```
