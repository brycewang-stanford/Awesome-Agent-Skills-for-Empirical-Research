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

# Presentation Analysis Framework

Deep content analysis for effective slide deck creation.

## 1. Message Hierarchy

Identify the core message structure before designing slides.

### Core Message (One Sentence)
- What is the single most important takeaway?
- If the audience remembers only one thing, what should it be?
- Can you state it in ≤15 words?

### Supporting Points (3-5 Maximum)
- What evidence supports the core message?
- What sub-topics must be covered?
- Prioritize by audience relevance, not source order

### Call-to-Action
- What should the audience DO after viewing?
- Is it clear, specific, and achievable?
- Where does it appear (slide position)?

## 2. Audience Decision Matrix

| Question | Analysis |
|----------|----------|
| Who is the primary audience? | [Role, expertise level, relationship to topic] |
| What do they currently believe? | [Existing knowledge, assumptions, biases] |
| What decision do we want them to make? | [Specific action or conclusion] |
| What barriers exist? | [Objections, concerns, missing information] |
| What evidence will convince them? | [Data types, credibility sources, emotional hooks] |

### Audience Adaptation

| Audience Type | Content Focus | Visual Treatment |
|---------------|---------------|------------------|
| Executives | Outcomes, ROI, strategic impact | High-level, clean, data highlights |
| Technical | Architecture, implementation, specs | Detailed diagrams, code, schematics |
| General | Benefits, stories, relatability | Visual metaphors, simple charts |
| Investors | Market size, traction, team | Growth charts, milestones, comparisons |
| Learners | Step-by-step, examples, practice | Progressive reveals, exercises |

## 3. Visual Opportunity Map

Identify which content benefits from visualization.

### Content-to-Visual Mapping

| Content Type | Visual Treatment | Example |
|--------------|------------------|---------|
| Comparisons | Side-by-side, before/after | Feature comparison table |
| Processes | Flow diagrams, numbered steps | Workflow illustration |
| Hierarchies | Org charts, pyramids, trees | Organizational structure |
| Timelines | Horizontal/vertical timelines | Project milestones |
| Statistics | Charts, highlighted numbers | Key metrics with context |
| Concepts | Icons, metaphors, illustrations | Abstract idea visualization |
| Relationships | Venn diagrams, networks | Ecosystem or dependencies |
| Lists | Structured grids, icon rows | Feature bullets with icons |

### Visual Priority

Rate each piece of content:
- **Must Visualize**: Complex data, key differentiators, memorable moments
- **Should Visualize**: Supporting evidence, secondary points
- **Text Only**: Simple statements, transitions, minor details

## 4. Presentation Flow

Structure for impact and retention.

### Opening (First 2-3 Slides)

| Element | Purpose |
|---------|---------|
| Hook | Capture attention (surprising stat, question, story) |
| Context | Why this matters now |
| Preview | What audience will learn/gain |

### Middle (Content Slides)

| Pattern | When to Use |
|---------|-------------|
| Problem → Solution | Introducing new products/ideas |
| Situation → Complication → Resolution | Complex business cases |
| What → Why → How | Educational content |
| Past → Present → Future | Transformation stories |
| Claim → Evidence → Implication | Data-driven arguments |

### Closing (Final 2-3 Slides)

| Element | Purpose |
|---------|---------|
| Synthesis | Tie back to core message |
| Call-to-Action | Clear next steps |
| Memorable Close | Resonant quote, image, or statement |

### Transitions

- Each slide should answer: "What comes next?"
- Use narrative connectors between sections
- Build logical progression, not topic jumps

## 5. Content Adaptation

Decide what to keep, transform, or omit.

### Keep (High Value)
- Core arguments and evidence
- Unique insights or data
- Audience-relevant examples
- Memorable quotes or statistics

### Simplify (Medium Value)
- Technical details → Visual summaries
- Long explanations → Bullet hierarchies
- Multiple examples → Best 1-2 examples
- Background context → Brief framing

### Visualize (Transform)
- Data tables → Charts or highlighted numbers
- Process descriptions → Flow diagrams
- Comparisons in text → Side-by-side visuals
- Abstract concepts → Concrete metaphors

### Omit (Low Value)
- Tangential information
- Redundant examples
- Excessive caveats
- Background the audience already knows

## 6. Analysis Checklist

Before outline creation, confirm:

### Message Clarity
- [ ] Core message stated in one sentence
- [ ] 3-5 supporting points identified
- [ ] Call-to-action defined

### Audience Fit
- [ ] Primary audience identified
- [ ] Existing beliefs mapped
- [ ] Desired decision clear
- [ ] Evidence matches audience needs

### Visual Planning
- [ ] Key visualizations identified
- [ ] Chart/diagram types selected
- [ ] Visual priority assigned

### Flow Design
- [ ] Opening hook defined
- [ ] Middle pattern selected
- [ ] Closing approach planned
- [ ] Transitions considered

### Content Decisions
- [ ] Keep/simplify/visualize/omit applied
- [ ] Source material fully processed
- [ ] No important content overlooked

## 7. Academic Presentation Analysis

For conference talks, thesis defense, and research presentations.

### Paper Structure to Slide Mapping

| Paper Section | Slide Type | Suggested Layout |
|---------------|------------|------------------|
| Title + Abstract | Cover + Motivation | `paper-title`, `title-hero` |
| Introduction | Problem Statement + Background | `split-screen`, `bullet-list` |
| Related Work | Context (optional, can condense) | `comparison-matrix`, `hub-spoke` |
| Methods | Architecture/Pipeline | `methods-diagram`, `linear-progression` |
| Experiments | Setup + Results | `results-chart`, `qualitative-grid` |
| Ablation Studies | Detailed Analysis | `comparison-matrix`, `results-chart` |
| Conclusions | Summary + Future Work | `contributions`, `bullet-list` |
| References | Key Citations | `references-list` |

### Academic Slide Count Guidelines

| Talk Duration | Recommended Slides | Pace |
|---------------|-------------------|------|
| 5 min (spotlight) | 5-7 slides | ~1 min/slide |
| 10 min (short) | 8-12 slides | ~1 min/slide |
| 15 min (standard) | 12-18 slides | ~1 min/slide |
| 20 min (full) | 15-22 slides | ~1 min/slide |
| 30+ min (invited) | 25-35 slides | ~1 min/slide |

### Citation Handling

**Inline Citations**:
- Key works: "[Author et al., Year]" or "[1]"
- Include only most relevant citations on slides
- Full bibliographic details optional

**Reference Slide**:
- List 5-10 key references at end
- Format: [N] Author et al. "Title." Venue, Year.

### Results Presentation Checklist

- [ ] Baseline comparisons clearly labeled
- [ ] Best results highlighted (bold or color)
- [ ] Statistical significance noted where applicable
- [ ] Units and metrics clearly stated
- [ ] Error bars or confidence intervals if available
- [ ] Ablation results in separate table/chart

### Academic Talk Flow

1. **Hook** (1 slide): Problem motivation, why it matters
2. **Background** (1-2 slides): Essential context only
3. **Approach** (2-4 slides): Your method, architecture
4. **Results** (2-4 slides): Main experiments, comparisons
5. **Analysis** (1-2 slides): Ablations, insights (optional)
6. **Conclusion** (1 slide): Summary, contributions, future work
7. **References** (1 slide): Key citations

## 8. Automatic Figure Detection and Mapping

For academic papers, automatically detect and map figures/tables to slides.

### Figure Detection Process

1. **Run detection script** on source PDF:
   ```bash
   npx -y bun ${SKILL_DIR}/scripts/detect-figures.ts --pdf source-paper.pdf --output figures.json
   ```

2. **Parse detection results** to identify:
   - Figure numbers, pages, and captions
   - Table numbers, pages, and captions
   - Total figure/table count

### Figure-to-Slide Mapping Rules

| Figure Type | Maps To | Extract? | Reasoning |
|-------------|---------|----------|-----------|
| Architecture/Pipeline diagram | Methods slide | **Yes** | Core visual, must be accurate |
| Network structure | Methods slide | **Yes** | Technical precision required |
| Quantitative results table | Results slide | **Yes** | Data accuracy critical |
| Qualitative comparison grid | Results slide | **Yes** | Visual comparison must be authentic |
| Ablation study table | Analysis slide | **Yes** | Precise numbers needed |
| Challenge/motivation illustration | Background slide | Maybe | Depends on complexity |
| Conceptual diagram | Any | No | Can be re-stylized by AI |
| Simple flowchart | Any | No | AI can render cleanly |

### Automatic Mapping Algorithm

```
For each detected figure:
  1. Analyze caption keywords:
     - "architecture", "framework", "pipeline", "network" → Methods slide
     - "comparison", "results", "performance" → Results slide
     - "ablation", "analysis" → Analysis slide
     - "qualitative", "visual" → Qualitative Results slide

  2. Determine extraction necessity:
     - Contains numerical data (tables) → Extract
     - Contains precise diagrams (architecture) → Extract
     - Contains comparison images → Extract
     - Simple conceptual illustration → Generate

  3. Match to outline slide:
     - Find slide with matching topic
     - Add IMAGE_SOURCE metadata automatically
```

### Mapping Confidence Levels

| Confidence | Action |
|------------|--------|
| **High** (>80%) | Auto-map and extract |
| **Medium** (50-80%) | Auto-map, flag for review |
| **Low** (<50%) | Skip, use AI generation |

### Figure Caption Keywords

**Extract (High Priority)**:
- "architecture", "framework", "pipeline", "overview", "structure"
- "comparison", "results", "performance", "evaluation"
- "ablation", "analysis", "study"
- "qualitative", "visual", "segmentation", "detection"
- Table I/II/III, Table 1/2/3

**Generate (Low Priority)**:
- "illustration", "example", "concept", "motivation"
- "schematic", "diagram" (simple ones)
- Generic workflow without specific data

### Auto-Population Format

When auto-populating IMAGE_SOURCE in outline:

```markdown
// IMAGE_SOURCE
Source: extract
Figure: Figure 2
Page: 4
Caption: Overview of the proposed two-stage framework
Confidence: high
Mapping: Methods slide - "architecture" keyword match
```

### Review Checklist

After auto-detection, verify:
- [ ] All key figures detected (architecture, results tables)
- [ ] Page numbers correct
- [ ] No duplicate mappings
- [ ] Conceptual slides correctly marked as "generate"

## 9. Practical Implementation Notes

Lessons learned from real-world slide generation sessions.

### PDF Figure Extraction

**pdfjs-dist Compatibility**:
- Use `pdfjs-dist/legacy/build/pdf.mjs` for Node.js compatibility
- The modern build requires browser APIs (DOMMatrix) not available in Node
- If extraction fails with "Image or Canvas expected", fall back to PyMuPDF

**PyMuPDF (fitz) Fallback**:
```python
import fitz
doc = fitz.open("paper.pdf")
page = doc[page_num - 1]  # 0-indexed
mat = fitz.Matrix(3, 3)   # 3x scale for 4K quality
pix = page.get_pixmap(matrix=mat)
pix.save("output.png")
```
PyMuPDF is more reliable for complex PDFs with embedded images.

### Gemini API Image Generation

**Model**: `gemini-3-pro-image-preview`

**Config**:
```python
config=types.GenerateContentConfig(
    image_config=types.ImageConfig(
        aspect_ratio="16:9",
        image_size="4K"
    )
)
```

**Response Handling**:
- Image data is returned as raw bytes in `part.inline_data.data`
- Do NOT base64 decode - write bytes directly to file
- MIME type is `image/jpeg` even when requesting PNG output

**Network Issues**:
- Server disconnections are common for large image generation
- Implement retry logic with exponential backoff (3 retries recommended)
- Wait 5-15 seconds between retries

**Optimization**:
- Skip already-generated slides (check file size > 10KB)
- Run generation script multiple times if failures occur
- Script is idempotent - safe to re-run

### Slide Output Organization

**Directory Structure**:
```
slide-deck/{topic-slug}/
├── source-paper.pdf          # Original PDF
├── figures.json              # Detection results
├── outline.md                # Final outline with IMAGE_SOURCE
├── extracted/                # Raw PDF page extractions
│   └── page-{N}.png
├── prompts/                  # Generation prompts
│   └── {NN}-slide-{name}.txt
├── slides/                   # Final slide images
│   └── {NN}-slide-{name}.png
├── {topic-slug}.pptx         # Merged PPTX
└── generate-slides.py        # Generated script (optional)
```

### Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| pdfjs "DOMMatrix is not defined" | Use legacy build import |
| pdfjs "Image or Canvas expected" | Use PyMuPDF fallback |
| Gemini "Server disconnected" | Retry with delay |
| Small output files (~600 bytes) | Fix: Don't base64 decode response |
| pdf-lib "Cannot embed PNG" | Check actual image format (may be JPEG) |
| merge-to-pdf fails | Use PPTX as primary output, convert externally |
