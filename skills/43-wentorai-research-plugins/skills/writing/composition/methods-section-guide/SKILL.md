---
name: methods-section-guide
description: "Guide to writing clear and reproducible methodology sections"
metadata:
  openclaw:
    emoji: "⚙️"
    category: "writing"
    subcategory: "composition"
    keywords: ["methods writing", "methodology section", "reproducible methods"]
    source: "wentor-research-plugins"
---

# Methods Section Writing Guide

Write methodology sections that are clear, complete, and reproducible, following discipline-specific conventions and best practices.

## Purpose of the Methods Section

The methods section answers: "How did you do this study, and can someone else replicate it?" A well-written methods section:

- Provides enough detail for replication by an independent researcher
- Justifies why each method was chosen
- Describes the study design, participants, materials, and procedures
- Specifies statistical or analytical approaches
- Addresses ethical considerations

## Standard Structure

The methods section typically follows this order (adapt to your discipline):

| Subsection | Contents |
|-----------|----------|
| **Study Design** | Overall approach (experimental, observational, computational, qualitative) |
| **Participants / Samples** | Population, sampling strategy, inclusion/exclusion criteria, sample size justification |
| **Materials / Instruments** | Equipment, software, reagents, questionnaires, datasets |
| **Procedure** | Step-by-step protocol, chronological order of data collection |
| **Data Analysis** | Statistical tests, software, significance thresholds, model specifications |
| **Ethical Considerations** | IRB approval, informed consent, data privacy |

## Writing by Discipline

### Experimental Sciences (Biology, Chemistry, Physics)

```markdown
## Materials and Methods

### Cell Culture and Treatment
HeLa cells (ATCC CCL-2) were maintained in DMEM (Gibco, #11965092)
supplemented with 10% FBS (Gibco, #26140079) and 1% penicillin-
streptomycin (Gibco, #15140122) at 37C in 5% CO2. Cells were
seeded at 5 x 10^4 cells/well in 24-well plates and treated with
compound X (0.1, 1, 10 uM) for 24 hours.

### Western Blot Analysis
Total protein was extracted using RIPA buffer (Thermo, #89900)
with protease inhibitor cocktail (Roche, #04693116001). Proteins
(30 ug/lane) were separated on 10% SDS-PAGE gels and transferred
to PVDF membranes. Primary antibodies: anti-TargetProtein
(Cell Signaling, #1234, 1:1000), anti-beta-actin (Sigma, #A5441,
1:5000). Secondary antibodies: HRP-conjugated (1:10000).
```

Key conventions:
- Include catalog numbers for all reagents
- Specify concentrations, temperatures, durations, and instrument models
- Reference established protocols by citation rather than rewriting them in full
- Use past tense throughout

### Computational / Machine Learning Studies

```markdown
## Methods

### Dataset
We evaluated our method on three benchmark datasets:
- **ImageNet-1K** (Russakovsky et al., 2015): 1.28M training images,
  50K validation images across 1,000 classes
- **CIFAR-100** (Krizhevsky, 2009): 50K training, 10K test, 100 classes
- **Oxford Flowers-102** (Nilsback & Zisserman, 2008): 8,189 images, 102 classes

### Model Architecture
Our model extends the Vision Transformer (ViT-B/16) with the
following modifications:
1. Replaced standard self-attention with linear attention (Katharopoulos et al., 2020)
2. Added a learnable class-conditional normalization layer after each block
3. Used patch size 16x16 with input resolution 224x224

### Training Details
| Hyperparameter | Value |
|---------------|-------|
| Optimizer | AdamW (beta1=0.9, beta2=0.999) |
| Learning rate | 1e-3 with cosine decay |
| Weight decay | 0.05 |
| Batch size | 256 (across 4 A100 GPUs) |
| Training epochs | 300 |
| Warmup epochs | 10 |
| Data augmentation | RandAugment (N=2, M=9), Mixup (alpha=0.8) |
| Label smoothing | 0.1 |

All experiments were implemented in PyTorch 2.1 and run on 4x NVIDIA A100
80GB GPUs. Training took approximately 18 hours per run. Code is available
at [repository URL].
```

### Social Science / Survey Research

```markdown
## Methods

### Participants
A total of 412 participants (245 female, 162 male, 5 non-binary;
M_age = 34.2, SD = 11.8) were recruited via Prolific. Inclusion
criteria: (a) aged 18-65, (b) fluent in English, (c) resided in
the US. Exclusion criteria: (a) failed two or more attention checks,
(b) completed the survey in under 3 minutes. After exclusions,
387 participants remained (attrition: 6.1%).

Sample size was determined a priori using G*Power 3.1 (Faul et al., 2007).
For a medium effect size (f^2 = 0.15), alpha = .05, and power = .80
in a multiple regression with 5 predictors, the required sample was 92.
We oversampled to ensure adequate power for subgroup analyses.

### Measures

**Perceived Stress Scale (PSS-10)** (Cohen et al., 1983): 10 items,
5-point Likert scale (0 = never, 4 = very often). Cronbach's alpha
in the current sample: .87.

**Big Five Inventory (BFI-10)** (Rammstedt & John, 2007): 10 items,
5-point Likert scale. Subscale alphas ranged from .68 to .81.

### Procedure
After providing informed consent, participants completed measures in
the following fixed order: demographics, PSS-10, BFI-10, experimental
task, manipulation check, debriefing. Median completion time: 14 minutes.
Participants were compensated GBP 2.50.

### Ethical Approval
This study was approved by the [University] IRB (Protocol #2024-0123).
All participants provided informed consent.
```

## Reproducibility Checklist

Use this checklist to ensure your methods section is complete:

### For All Studies

- [ ] Study design and rationale clearly stated
- [ ] Sample/dataset described with inclusion/exclusion criteria
- [ ] Sample size justified (power analysis, saturation, or convention)
- [ ] All measures and instruments described with psychometric properties or specifications
- [ ] Procedure described in chronological order with enough detail for replication
- [ ] Statistical/analytical methods specified, including software and version
- [ ] Significance level (alpha) stated
- [ ] Missing data handling described
- [ ] Ethical approval and consent documented

### For Computational Studies

- [ ] Hardware specifications (GPU model, memory, training time)
- [ ] Software framework and version (PyTorch 2.1, TensorFlow 2.15, etc.)
- [ ] All hyperparameters listed in a table
- [ ] Random seed policy described
- [ ] Code and data availability statement
- [ ] Evaluation metrics defined precisely
- [ ] Baseline methods described or cited

## Common Pitfalls

| Issue | Example | Fix |
|-------|---------|-----|
| Vague descriptions | "Data was analyzed statistically" | Specify exact tests: "We used a two-tailed independent samples t-test" |
| Missing software versions | "Analysis done in R" | "Analysis conducted in R 4.3.1 using lme4 v1.1-35" |
| No sample size justification | Just reporting N | Include power analysis or justify based on conventions |
| Ambiguous order | Reader cannot tell what happened when | Use numbered steps or chronological narrative |
| Results in methods | Including p-values or outcomes | Save all results for the Results section |
| Over-referencing | Citing a protocol without summarizing key details | Provide enough detail to understand without reading the reference |

## Language and Tense

- Use **past tense** for what you did: "Participants completed a questionnaire..."
- Use **present tense** for established methods: "ANOVA tests for differences between group means..."
- Use **passive voice** when the agent is unimportant: "Samples were centrifuged at 12,000 rpm..."
- Use **active voice** when clarity is improved: "We excluded participants who..."
