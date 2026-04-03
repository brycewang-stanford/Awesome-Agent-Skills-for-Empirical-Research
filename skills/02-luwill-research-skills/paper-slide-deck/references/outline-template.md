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

# Outline Template

Standard structure for slide deck outlines with style instructions.

## Outline Format

```markdown
# Slide Deck Outline

**Topic**: [topic description]
**Style**: [selected style]
**Audience**: [target audience]
**Language**: [output language]
**Slide Count**: N slides
**Generated**: YYYY-MM-DD HH:mm

---

<STYLE_INSTRUCTIONS>
Design Aesthetic: [2-3 sentence description from style file]

Background:
  Color: [Name] ([Hex])
  Texture: [description]

Typography:
  Primary Font: [detailed description for image generation]
  Secondary Font: [detailed description for image generation]

Color Palette:
  Primary Text: [Name] ([Hex]) - [usage]
  Background: [Name] ([Hex]) - [usage]
  Accent 1: [Name] ([Hex]) - [usage]
  Accent 2: [Name] ([Hex]) - [usage]

Visual Elements:
  - [element 1 with rendering guidance]
  - [element 2 with rendering guidance]
  - ...

Style Rules:
  Do: [guidelines from style file]
  Don't: [anti-patterns from style file]
</STYLE_INSTRUCTIONS>

---

[Slide entries follow...]
```

## Cover Slide Template

```markdown
## Slide 1 of N

**Type**: Cover
**Filename**: 01-slide-cover.png

// NARRATIVE GOAL
[What this slide achieves in the story arc]

// KEY CONTENT
Headline: [main title]
Sub-headline: [supporting tagline]

// VISUAL
[Detailed visual description - specific elements, composition, mood]

// LAYOUT
Layout: [optional: layout name from gallery, e.g., title-hero]
[Composition, hierarchy, spatial arrangement]
```

## Content Slide Template

```markdown
## Slide X of N

**Type**: Content
**Filename**: {NN}-slide-{slug}.png

// NARRATIVE GOAL
[What this slide achieves in the story arc]

// KEY CONTENT
Headline: [main message - narrative, not label]
Sub-headline: [supporting context]
Body:
- [point 1 with specific detail]
- [point 2 with specific detail]
- [point 3 with specific detail]

// VISUAL
[Detailed visual description]

// LAYOUT
Layout: [optional: layout name from gallery]
[Composition, hierarchy, spatial arrangement]
```

## Image Source Metadata (Automatic Figure Extraction)

For academic presentations, IMAGE_SOURCE metadata is **automatically populated** based on figure detection.

### Auto-Population Process

1. **Figure Detection**: `detect-figures.ts` scans PDF and outputs `figures.json`
2. **Mapping Algorithm**: Agent maps figures to slides using caption keywords:
   - "architecture", "framework", "pipeline" → Methods slides
   - "comparison", "results", "performance" → Results slides (quantitative)
   - "qualitative", "visual", "segmentation" → Results slides (qualitative)
   - Table I/II/III → Quantitative results slides
3. **Auto-Insert**: `// IMAGE_SOURCE` blocks added to outline during generation

### IMAGE_SOURCE Format

```markdown
// IMAGE_SOURCE
Source: generate | extract
Figure: [Figure/Table number from paper, e.g., "Figure 2", "Table 1"]
Page: [PDF page number, 1-indexed]
Caption: [Figure caption for container template]
```

### IMAGE_SOURCE Values

| Value | Description | Processing |
|-------|-------------|------------|
| `generate` | AI generates the slide image (default) | Standard prompt → Gemini generation |
| `extract` | Extract figure from source PDF | PDF extraction → Apply container template |

### Auto-Mapping Rules

| Figure Caption Contains | Maps To | Default Source |
|-------------------------|---------|----------------|
| architecture, framework, pipeline, network, overview | Methods slide | `extract` |
| comparison, results, performance, evaluation | Quantitative results | `extract` |
| qualitative, visual, segmentation, detection | Qualitative results | `extract` |
| ablation, analysis | Analysis slide | `extract` |
| Table I, Table II, TABLE 1, TABLE 2 | Results slide | `extract` |
| motivation, challenge, problem | Background slide | `generate` |
| illustration, concept, example | Any | `generate` |

### Manual Override

To override auto-detection, manually edit the `// IMAGE_SOURCE` block in outline:

```markdown
// IMAGE_SOURCE
Source: extract    # Change to 'generate' if needed
Figure: Figure 3   # Correct figure number if wrong
Page: 5            # Correct page number if wrong
Caption: Corrected caption text
```

### Example: Extracted Figure Slide

```markdown
## Slide 5 of 12

**Type**: Content
**Filename**: 05-slide-architecture.png

// NARRATIVE GOAL
Present the core network architecture

// KEY CONTENT
Headline: Proposed Architecture
Sub-headline: Two-Stage Coarse-to-Fine Framework
Body:
- Stage 1: Global feature extraction
- Stage 2: Local refinement module

// VISUAL
Central architecture diagram from Figure 2 of the paper

// LAYOUT
Layout: methods-diagram

// IMAGE_SOURCE
Source: extract
Figure: Figure 2
Page: 4
Caption: Overall architecture of our proposed two-stage framework
```

### Example: Generated Slide (Default)

```markdown
## Slide 3 of 12

**Type**: Content
**Filename**: 03-slide-motivation.png

// NARRATIVE GOAL
Establish the problem motivation

// KEY CONTENT
Headline: Current Methods Fall Short
Body:
- Existing approaches struggle with X
- Performance gap in Y scenarios

// VISUAL
Split comparison showing limitation vs desired outcome

// LAYOUT
Layout: binary-comparison

// IMAGE_SOURCE
Source: generate
```

**Note**: If `// IMAGE_SOURCE` section is omitted, defaults to `Source: generate`.

## Back Cover Slide Template

```markdown
## Slide N of N

**Type**: Back Cover
**Filename**: {NN}-slide-back-cover.png

// NARRATIVE GOAL
[Meaningful closing - not just "thank you"]

// KEY CONTENT
Headline: [memorable closing statement or call-to-action]
Body: [optional summary points or next steps]

// VISUAL
[Visual that reinforces the core message]

// LAYOUT
Layout: [optional: layout name from gallery]
[Clean, impactful composition]
```

## STYLE_INSTRUCTIONS Block

The `<STYLE_INSTRUCTIONS>` block contains all style-specific guidance for image generation:

| Section | Content |
|---------|---------|
| Design Aesthetic | Overall visual direction from style file |
| Background | Base color and texture details |
| Typography | Font descriptions for Gemini (no font names, describe appearance) |
| Color Palette | Named colors with hex codes and usage guidance |
| Visual Elements | Specific graphic elements with rendering instructions |
| Style Rules | Do/Don't guidelines from style file |

**Important**: Typography descriptions must describe the visual appearance (e.g., "rounded sans-serif", "bold geometric") since image generators cannot use font names.

## Section Dividers

Use `---` (horizontal rule) between:
- Header metadata and STYLE_INSTRUCTIONS
- STYLE_INSTRUCTIONS and first slide
- Each slide entry

## Slide Numbering

- Cover is always Slide 1
- Content slides use sequential numbers
- Back Cover is always final slide (N)
- Filename prefix matches slide position: `01-`, `02-`, etc.

## Filename Slugs

Generate meaningful slugs from slide content:

| Slide Type | Slug Pattern | Example |
|------------|--------------|---------|
| Cover | `cover` | `01-slide-cover.png` |
| Content | `{topic-slug}` | `02-slide-problem-statement.png` |
| Back Cover | `back-cover` | `10-slide-back-cover.png` |

Slug rules:
- Kebab-case (lowercase, hyphens)
- Derived from headline or main topic
- Maximum 30 characters
- Unique within deck

## Academic Slide Templates

For `academic-paper` style presentations.

### Academic Cover Slide

```markdown
## Slide 1 of N

**Type**: Cover
**Filename**: 01-slide-cover.png

// NARRATIVE GOAL
Establish paper title, authors, affiliations, and venue

// KEY CONTENT
Headline: [Paper Title - can be multi-line]
Sub-headline: [Conference/Journal Name, Year]
Authors: [Author1, Author2, Author3]
Affiliations: [University/Company logos or names]

// VISUAL
Clean white background, centered title in dark blue, author names below, institutional logos/names at bottom

// LAYOUT
Layout: paper-title
```

### Methods/Architecture Slide

```markdown
## Slide X of N

**Type**: Content
**Filename**: {NN}-slide-method.png

// NARRATIVE GOAL
Present the core methodology or system architecture

// KEY CONTENT
Headline: [Method Name] / Our Approach
Body:
- Architecture diagram with labeled components
- Data flow arrows between modules
- Key innovation highlighted

// VISUAL
Central pipeline/architecture diagram, labeled boxes for each component, arrows showing data flow, key module emphasized with accent color

// LAYOUT
Layout: methods-diagram
```

### Results Slide (Quantitative)

```markdown
## Slide X of N

**Type**: Content
**Filename**: {NN}-slide-results.png

// NARRATIVE GOAL
Present main experimental results with clear comparisons

// KEY CONTENT
Headline: [Key finding - narrative, e.g., "Our method achieves state-of-the-art on X"]
Body:
- Table or chart with baselines
- Best results highlighted
- Metric names and units clear

// VISUAL
Clean table or bar chart, baseline rows in gray, our method highlighted in blue, best values in bold, clear column headers

// LAYOUT
Layout: results-chart
```

### Results Slide (Qualitative)

```markdown
## Slide X of N

**Type**: Content
**Filename**: {NN}-slide-qualitative.png

// NARRATIVE GOAL
Show visual comparison of results

// KEY CONTENT
Headline: [Qualitative Comparison]
Body:
- 2x2 or 3x2 grid of comparison images
- Labels: Input, Baseline, Ours, Ground Truth
- Caption describing what to observe

// VISUAL
Grid layout with equal-sized images, clear labels below each, subtle borders between cells

// LAYOUT
Layout: qualitative-grid
```

### Contributions Slide

```markdown
## Slide X of N

**Type**: Content
**Filename**: {NN}-slide-contributions.png

// NARRATIVE GOAL
Summarize key contributions of the work

// KEY CONTENT
Headline: Contributions
Body:
1. [First contribution - specific and measurable]
2. [Second contribution]
3. [Third contribution]
(Optional: Code/data release information)

// VISUAL
Numbered list with checkmarks or icons, each contribution on separate line, clean spacing

// LAYOUT
Layout: contributions
```

### References Slide

```markdown
## Slide N of N

**Type**: Back Cover
**Filename**: {NN}-slide-references.png

// NARRATIVE GOAL
Acknowledge key related work and provide resources

// KEY CONTENT
Headline: References / Thank You
Body:
[1] Author et al. "Title." Venue, Year.
[2] Author et al. "Title." Venue, Year.
...
(Optional: QR code for paper/code, contact email)

// VISUAL
Two-column reference list, smaller font, optional QR code in corner, "Questions?" or contact info at bottom

// LAYOUT
Layout: references-list
```
