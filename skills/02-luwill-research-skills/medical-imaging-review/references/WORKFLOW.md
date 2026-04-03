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

# 7-Phase Literature Review Workflow

## Phase 1: Project Initialization

Create project structure:
```
project_root/
├── CLAUDE.md              # Writing guidelines
├── IMPLEMENTATION_PLAN.md # Staged plan
├── manuscript_draft.md    # Main manuscript
└── figures/               # Figure placeholders
```

**Actions:**
1. Create `CLAUDE.md` from template (see TEMPLATES.md)
2. Create `IMPLEMENTATION_PLAN.md` with stages
3. Initialize empty `manuscript_draft.md`

## Phase 2: Literature Collection

### Data Sources

#### 1. ArXiv MCP (Latest Deep Learning Methods)

Best for: Cutting-edge architectures, preprints, AI/ML advances

**Search Strategy:**
```
Query: "[topic] AND (segmentation OR detection OR classification)"
Categories: cs.CV, eess.IV, cs.LG
Date: Last 2-3 years for recent methods
Max results: 50-100 per query
```

**Workflow:**
1. Use `search_papers` with topic keywords
2. Review titles and abstracts for relevance
3. Use `download_paper` for key papers
4. Use `read_paper` to extract method details

**Example Queries:**
- "medical image segmentation transformer"
- "coronary artery deep learning"
- "CT scan neural network"

#### 2. PubMed MCP (Clinical & Biomedical Literature)

Best for: Clinical validation, medical context, peer-reviewed studies

**Search Strategy:**
- Use MeSH terms for precise results
- Filter by publication type (Review, Clinical Study)
- Focus on clinical outcomes and validation

**Example MeSH Queries:**
- "Deep Learning"[MeSH] AND "Coronary Vessels"[MeSH]
- "Image Processing, Computer-Assisted"[MeSH] AND "Tomography, X-Ray Computed"[MeSH]

#### 3. Zotero (Existing Library & Organization)

Best for: Managing collected references, existing collections

**Workflow:**
1. Connect to Zotero API or use Zotero-MCP
2. Browse existing collections by topic
3. Export metadata for citation management

### Collection Workflow

**Actions:**
1. **ArXiv search** - Latest methods and architectures (50-100 papers)
2. **PubMed search** - Clinical validation studies (30-50 papers)
3. **Zotero check** - Existing relevant collections
4. **WebSearch** - Supplementary sources (IEEE, Springer, Google Scholar)
5. **Categorize** papers by method/application
6. Create literature matrix:

| Category | Subcategory | Key Papers | Count | Source |
|----------|-------------|------------|-------|--------|
| Methods  | CNN/U-Net   | [refs]     | N     | ArXiv  |
| Methods  | Transformer | [refs]     | N     | ArXiv  |
| Clinical | Validation  | [refs]     | N     | PubMed |
| Datasets | Public      | [refs]     | N     | Mixed  |

7. **Gap analysis** - Identify missing topics or time periods
8. **Targeted search** - Fill gaps with additional queries

## Phase 3: Outline Development

**Actions:**
1. Define section headings based on literature categories
2. Map papers to sections
3. Plan comparison tables
4. Design figure placeholders

**Output:** Detailed outline in IMPLEMENTATION_PLAN.md

## Phase 4: Section Writing

For each major section:

1. **Write introduction** (1-2 paragraphs on motivation)
2. **Describe methods** using standard template
3. **Add performance data** with consistent metrics
4. **Write limitations** paragraph
5. **Create comparison table**
6. **Update references**

**Progress tracking:** Use TodoWrite for each section

## Phase 5: Tables and Figures

**Required tables:**
- Table 1: Public Datasets
- Table 2: Method Comparison
- Table 3: Commercial Products (if applicable)

**Figure placeholders:**
- Figure 1: Review overview/taxonomy
- Figure 2: Method evolution timeline
- Figure 3: Representative architectures
- Figure 4: Clinical workflow

## Phase 6: Quality Assurance

**Structure check:**
- [ ] Key Points present
- [ ] All sections have summary tables
- [ ] Consistent heading hierarchy

**Content check:**
- [ ] All major methods covered
- [ ] Limitations discussed
- [ ] Future directions articulated

**Language check:**
- [ ] Hedging language used
- [ ] Terminology consistent
- [ ] Transitions smooth

**Reference check:**
- [ ] 80-120 references
- [ ] Recent literature included
- [ ] Organized by topic

## Phase 7: Incremental Updates

When new literature becomes available:

1. **Categorize** new papers
2. **Update CLAUDE.md** reference sources
3. **Update IMPLEMENTATION_PLAN.md** with new stage
4. **Identify insertion points** in manuscript
5. **Update sections** with new methods
6. **Add new sections** if new paradigm emerges
7. **Update tables** with new data
8. **Expand references**

**Version control:**
```markdown
## Change Log
### [Date] - v1.1
- Added Section 3.X [New Category]
- Updated Table 2 with N new methods
- Added references #XX-#YY
```
