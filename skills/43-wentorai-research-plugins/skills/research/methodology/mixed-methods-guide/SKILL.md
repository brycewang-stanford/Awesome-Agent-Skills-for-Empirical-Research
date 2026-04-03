---
name: mixed-methods-guide
description: "Guide to designing and conducting mixed methods research"
metadata:
  openclaw:
    emoji: "🔀"
    category: "research"
    subcategory: "methodology"
    keywords: ["mixed methods research", "multimethod design", "quantitative research design"]
    source: "wentor-research-plugins"
---

# Mixed Methods Research Guide

Design, execute, and report mixed methods research that integrates quantitative and qualitative approaches for more comprehensive and rigorous findings.

## What Is Mixed Methods Research?

Mixed methods research (MMR) systematically combines quantitative and qualitative data collection, analysis, and interpretation within a single study or program of inquiry. It goes beyond simply using both numbers and words; the core requirement is purposeful integration of the two strands.

### When to Use Mixed Methods

| Situation | Why MMR Helps |
|-----------|--------------|
| Quantitative results need explanation | Qualitative follow-up explains why and how |
| Need to develop an instrument | Qualitative exploration informs survey items |
| Testing a new intervention | Quantitative outcomes + qualitative experience |
| Complex phenomena | Neither approach alone captures the full picture |
| Conflicting prior findings | Triangulation resolves discrepancies |
| Studying under-researched topics | Exploration (qual) then confirmation (quant) |

## Major Mixed Methods Designs

### Convergent Design (Concurrent)

Both strands are collected simultaneously, analyzed separately, then merged.

```
    QUAN data collection          QUAL data collection
           |                              |
    QUAN data analysis            QUAL data analysis
           |                              |
           +---------- Merge ------------+
                         |
                  Interpretation
```

**Use when**: You want to compare, validate, or triangulate quantitative and qualitative findings on the same phenomenon.

**Example**: Survey 500 teachers on burnout (QUAN) while simultaneously interviewing 20 teachers about their experiences (QUAL). Merge findings to see if themes align with statistical patterns.

### Explanatory Sequential Design

Quantitative phase first, followed by qualitative phase to explain or elaborate on quantitative results.

```
    QUAN data collection & analysis
                |
    Identify results needing explanation
                |
    QUAL data collection & analysis (informed by QUAN results)
                |
           Interpretation
```

**Use when**: You have surprising, confusing, or significant quantitative results that need deeper understanding.

**Example**: Find that 30% of participants show an unexpected improvement pattern. Interview those participants to understand what drove their experience.

### Exploratory Sequential Design

Qualitative phase first to explore, followed by quantitative phase to test or generalize.

```
    QUAL data collection & analysis
                |
    Develop instrument / hypotheses / categories from QUAL findings
                |
    QUAN data collection & analysis (testing QUAL-derived constructs)
                |
           Interpretation
```

**Use when**: You are studying something new and need qualitative exploration to develop measurement instruments or hypotheses.

**Example**: Interview 25 researchers about AI tool adoption (QUAL). Use themes to develop a survey instrument. Administer survey to 400 researchers (QUAN).

### Embedded Design

One strand is embedded within the other, serving a supplementary role.

```
    QUAN experiment
        |-- Embedded QUAL (interviews during intervention)
        |-- QUAN outcome measures
           |
       Interpretation
```

## Integration Strategies

Integration is what distinguishes mixed methods from simply running two separate studies. Key integration strategies:

| Strategy | Description | When in Study |
|----------|-------------|--------------|
| **Merging** | Bring QUAN + QUAL results together for comparison | Analysis/interpretation |
| **Connecting** | One strand's results inform the next strand's design | Between phases |
| **Building** | QUAL results build a QUAN instrument (or vice versa) | Between phases |
| **Embedding** | One strand is nested within the other's framework | Data collection |

### Joint Display Table

A joint display is a table or visualization that explicitly integrates both data types:

```
| Quantitative Finding | Qualitative Theme | Meta-Inference |
|---------------------|-------------------|----------------|
| 78% reported high stress (M=4.2/5) | Theme: "Always-on culture" — participants described checking email at midnight | Convergent: high stress scores align with descriptions of boundary erosion |
| No significant gender difference (p=.34) | Women described unique stressors (caregiving + work), men described different ones (promotion pressure) | Divergent: similar overall levels but different sources of stress |
| Time-management training reduced stress (d=0.45) | Theme: "Tools help but culture doesn't change" | Complementary: training has modest measurable effect but underlying issues persist |
```

## Sample Size Considerations

| Strand | Typical Range | Rationale |
|--------|---------------|-----------|
| Quantitative (survey) | 100-1000+ | Power analysis, see power-analysis-guide |
| Qualitative (interviews) | 12-30 | Saturation (no new themes emerging) |
| Qualitative (focus groups) | 3-6 groups of 6-10 | Diversity of perspectives |
| Qualitative (case study) | 3-10 cases | In-depth understanding |

**For convergent designs**: The QUAN sample is typically much larger than the QUAL sample. This is acceptable because the two strands serve different purposes (generalizability vs. depth).

## Data Analysis

### Quantitative Analysis

Standard statistical methods apply: descriptive statistics, t-tests, ANOVA, regression, SEM, etc. See the relevant analysis skill guides.

### Qualitative Analysis

Common approaches:

```
1. Thematic Analysis (Braun & Clarke, 2006)
   Step 1: Familiarize with data (read transcripts multiple times)
   Step 2: Generate initial codes
   Step 3: Search for themes (group codes into higher-level themes)
   Step 4: Review themes (check against data)
   Step 5: Define and name themes
   Step 6: Write up findings

2. Coding Process:
   - Open coding: label meaningful segments of text
   - Axial coding: identify relationships between codes
   - Selective coding: identify core categories

3. Tools: NVivo, ATLAS.ti, MAXQDA, Dedoose, or manual coding in spreadsheets
```

### Integration Analysis

```python
# Example: Quantifying qualitative themes for integration
import pandas as pd

# After coding interviews, create a themes-by-participant matrix
themes_matrix = pd.DataFrame({
    "participant": ["P01", "P02", "P03", "P04", "P05"],
    "high_stress": [1, 1, 0, 1, 1],      # 1 = theme present
    "boundary_erosion": [1, 0, 0, 1, 1],
    "coping_strategy": [0, 1, 1, 1, 0],
    "quant_stress_score": [4.5, 3.8, 2.1, 4.2, 4.0]
})

# Now examine whether theme presence correlates with quantitative scores
from scipy.stats import pointbiserialr

r, p = pointbiserialr(themes_matrix["high_stress"],
                       themes_matrix["quant_stress_score"])
print(f"Correlation between stress theme and score: r={r:.3f}, p={p:.3f}")
```

## Reporting Mixed Methods Research

### Essential Components

1. **Research questions**: State both QUAN and QUAL questions plus the mixed methods question
2. **Design rationale**: Explain why mixed methods is needed
3. **Design type**: Name the specific design (convergent, explanatory sequential, etc.)
4. **Strand descriptions**: Describe each strand's methods in detail
5. **Integration procedure**: Explain how and when data are integrated
6. **Joint display**: Present integrated findings in a table or figure
7. **Meta-inferences**: Draw conclusions that leverage both data types

### Quality Criteria

| Criterion | Quantitative | Qualitative | Mixed Methods |
|-----------|-------------|-------------|---------------|
| Validity | Internal, external, construct, statistical conclusion | Credibility, transferability, dependability, confirmability | Inference quality, inference transferability |
| Reliability | Cronbach's alpha, test-retest | Intercoder agreement, audit trail | Integration consistency |
| Rigor | Randomization, control, blinding | Prolonged engagement, member checking, triangulation | Design coherence, integrative adequacy |

### Recommended Reporting Guidelines

- **APA JARS-Mixed** (Journal Article Reporting Standards for Mixed Methods)
- **O'Cathain et al. (2008)** Good Reporting of a Mixed Methods Study (GRAMMS)
- **Creswell & Plano Clark (2018)** Designing and Conducting Mixed Methods Research, 3rd Edition (the standard textbook)
