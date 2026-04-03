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

# Research Skills

A collection of Claude Code skills for academic research workflows.

## Skills

| Skill | Description | Trigger |
|-------|-------------|---------|
| [medical-imaging-review](./medical-imaging-review/) | Write comprehensive literature reviews for medical imaging AI | `/medical-imaging-review`, "review paper", "survey", "综述" |
| [paper-slide-deck](./paper-slide-deck/) | Generate professional slides from academic papers with auto figure extraction | `/paper-slide-deck paper.pdf` |
| [research-proposal](./research-proposal/) | Generate PhD research proposals with Nature Reviews-style academic writing | `/research-proposal`, "research proposal", "PhD proposal", "研究计划" |

## Installation

Copy the desired skill folder to your Claude Code skills directory:

```bash
# For medical-imaging-review
cp -r medical-imaging-review ~/.claude/skills/

# For paper-slide-deck
cp -r paper-slide-deck ~/.claude/skills/

# For research-proposal
cp -r research-proposal ~/.claude/skills/
```

Or copy to project-local skills:

```bash
cp -r medical-imaging-review .agents/skills/
cp -r paper-slide-deck .agents/skills/
cp -r research-proposal .agents/skills/
```

---

## Medical Imaging Review Skill

A systematic workflow for writing survey papers, systematic reviews, and literature analyses on medical imaging AI topics.

### Features

- **Structured 7-phase workflow** for literature review writing
- **Domain-specific templates** covering multiple medical imaging domains
- **Standardized writing style** with hedging language and citation patterns
- **Quality checklists** ensuring completeness
- **Zotero integration** for reference management

### Supported Domains

- Coronary Artery Analysis (CCTA)
- Lung Imaging (CT/X-ray)
- Brain Imaging (MRI/CT)
- Cardiac Imaging (MRI/CT/Echo)
- Pathology (Whole Slide Images)
- Retinal Imaging (Fundus/OCT)

### Files

| Path | Description |
|------|-------------|
| `SKILL.md` | Main skill definition and quick reference |
| `references/WORKFLOW.md` | Detailed 7-phase workflow guide |
| `references/TEMPLATES.md` | Project file templates |
| `references/DOMAINS.md` | Domain-specific method categories and datasets |
| `references/MCP_SETUP.md` | ArXiv, PubMed, Zotero MCP configuration |
| `references/QUALITY_CHECKLIST.md` | Pre-submission quality checklist |

---

## Paper Slide Deck Skill

Transform academic papers into professional slide decks with automatic figure extraction and AI-generated visuals.

### Features

- **Auto figure detection** from PDF papers
- **Smart figure-to-slide mapping** based on caption analysis
- **17 visual styles** (academic-paper, sketch-notes, minimal, etc.)
- **Gemini API integration** for AI slide generation
- **PPTX/PDF export** with merge scripts

### Workflow

1. Analyze paper and detect figures/tables
2. Generate outline with auto IMAGE_SOURCE mapping
3. Extract figures from PDF (or AI-generate)
4. Apply academic templates
5. Merge to PPTX/PDF

### Files

| Path | Description |
|------|-------------|
| `SKILL.md` | Main skill definition and workflow |
| `references/` | Analysis framework, templates, style definitions |
| `scripts/` | Python/TypeScript automation scripts |

### Scripts

| Script | Purpose |
|--------|---------|
| `generate-slides.py` | Gemini API image generation |
| `detect-figures.ts` | PDF figure/table detection |
| `extract-figure.ts` | PDF page extraction |
| `apply-template.ts` | Academic figure container template |
| `merge-to-pptx.ts` | PPTX generation |
| `merge-to-pdf.ts` | PDF generation |

---

## Research Proposal Skill

Generate high-quality academic research proposals for PhD applications following Nature Reviews-style academic writing conventions.

### Features

- **Structured 5-phase workflow**: Requirements → Literature → Outline → Content → Output
- **Multi-source literature integration**: WebSearch, Zotero MCP, arXiv, PubMed
- **Bilingual support**: English and Chinese (中文)
- **Domain adaptation**: STEM, Humanities, Social Sciences
- **Academic writing style**: Prose-based with hedging language, minimum 40 references

### Workflow

1. Gather requirements (topic, domain, language, word count)
2. Collect literature from multiple sources
3. Generate outline for user approval
4. Write full proposal based on approved outline
5. Output Markdown with quality checklist

### Files

| Path | Description |
|------|-------------|
| `SKILL.md` | Main skill definition and 5-phase workflow |
| `references/STRUCTURE_GUIDE.md` | Section-by-section writing guide |
| `references/DOMAIN_TEMPLATES.md` | STEM vs Humanities differences |
| `references/WRITING_STYLE_GUIDE.md` | Nature Reviews academic writing style |
| `references/QUALITY_CHECKLIST.md` | Quality verification checklist |
| `references/LITERATURE_WORKFLOW.md` | Literature collection workflow |
| `assets/proposal_scaffold_en.md` | English template scaffold |
| `assets/proposal_scaffold_zh.md` | Chinese template scaffold |

### Output

- Target: 2,000-4,000 words (default ~3,000)
- Minimum 40 references
- 3-5 figure suggestions
- Markdown format (convertible to DOCX/PDF via pandoc)

---

## License

MIT License
