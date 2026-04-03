<!--
  ╔══════════════════════════════════════════════════════════════╗
  ║  本文件为开源 Skill 原始文档，收录仅供学习与研究参考        ║
  ║  CoPaper.AI 收集整理 | https://copaper.ai                  ║
  ╚══════════════════════════════════════════════════════════════╝

  来源仓库: https://github.com/lishix520/academic-paper-skills
  项目名称: academic-paper-skills
  开源协议: MIT License
  收录日期: 2026-04-02

  声明: 本文件版权归原作者所有。此处收录旨在为社会科学实证研究者
  提供 AI Agent Skills 的集中参考。如有侵权，请联系删除。
-->

# Academic Paper Skills for Claude Code

A systematic framework for planning and writing philosophy and interdisciplinary academic papers using Claude Code. These skills transform your research ideas into submission-ready manuscripts through structured workflows with quality checkpoints.

## Features

- **End-to-End Pipeline**: From initial idea to polished manuscript
- **Evidence-Based Gap Identification**: Every research gap backed by 3-5 citations
- **Platform-Specific Style Learning**: Analyze 8-10 sample papers to extract writing standards
- **Reviewer Simulation**: 7-dimension, 35-point assessment system
- **Quality Assurance**: 3 validation gates + 2 Python verification scripts
- **Preprint Platform Support**: PhilArchive, arXiv, PhilSci-Archive, PsyArXiv, and more

## Two-Skill Workflow

```
┌─────────────────────────────────────────────────────────────┐
│                 ACADEMIC-PAPER-STRATEGIST                   │
│  Phase 1: Platform Analysis → Target venue + style guide    │
│  Phase 2: Theoretical Framework → Literature + gap analysis │
│  Phase 3: Outline Optimization → Reviewer-assessed outline  │
└─────────────────────────┬───────────────────────────────────┘
                          ↓
                   [Detailed Outline]
                          ↓
┌─────────────────────────┴───────────────────────────────────┐
│                  ACADEMIC-PAPER-COMPOSER                    │
│  Phase 1: Foundation → Style guide + chapter planning       │
│  Phase 2: Systematic Writing → Draft with quality checks    │
│  Phase 3: Polish → Final evaluation + submission prep       │
└─────────────────────────────────────────────────────────────┘
```

## Installation

### Prerequisites
- [Claude Code](https://claude.ai/code) installed and configured
- Python 3.8+ (for verification scripts)

### Setup

1. Clone this repository:
```bash
git clone https://github.com/yourusername/academic-paper-skills.git
```

2. Copy skills to your Claude Code skills directory:
```bash
cp -r strategist ~/.claude/skills/academic-paper-strategist
cp -r composer ~/.claude/skills/academic-paper-composer
```

3. Restart Claude Code to load the skills.

## Quick Start

### Planning a Paper (Strategist)

```
You: Plan a paper on how mortality generates consciousness

Claude: [Activates academic-paper-strategist]
        Let me guide you through the three phases...
```

### Writing from Outline (Composer)

```
You: Write the paper from this outline: [your outline]

Claude: [Activates academic-paper-composer]
        Starting Phase 1: Foundation setup...
```

## Directory Structure

```
academic-paper-skills/
├── strategist/
│   ├── SKILL.md                    # Main skill definition
│   ├── references/
│   │   ├── quality_standards.md    # Evaluation criteria
│   │   └── search_strategy.md      # Literature search guide
│   └── scripts/
│       ├── evaluate_samples.py     # Sample paper analyzer
│       └── gap_analysis.py         # Research gap validator
├── composer/
│   ├── SKILL.md                    # Main skill definition
│   ├── references/
│   │   ├── section_guides.md       # Section-by-section guidance
│   │   └── writing_standards.md    # Academic writing principles
│   └── scripts/
│       ├── chapter_quality_check.py    # Per-chapter validation
│       └── final_evaluation.py         # Full manuscript assessment
└── examples/
    ├── consciousness-paper.md      # Example: Philosophy of mind
    └── ai-ethics-paper.md          # Example: AI ethics
```

## Quality Standards

### Reviewer Simulation (7 Dimensions)

| Dimension | Weight | Criteria |
|-----------|--------|----------|
| Originality | 5 pts | Novel contribution to field |
| Argumentation | 5 pts | Logical coherence, evidence support |
| Literature | 5 pts | Comprehensive, current coverage |
| Methodology | 5 pts | Appropriate, rigorous approach |
| Clarity | 5 pts | Accessible, well-structured writing |
| Impact | 5 pts | Potential influence on field |
| Technical | 5 pts | Accuracy, proper citations |

**Threshold**: Outlines scoring ≥28/35 proceed to writing phase.

## Use Cases

- **PhD students**: Transform dissertation chapters into publishable papers
- **Independent researchers**: Professional-grade paper planning without institutional support
- **Interdisciplinary work**: Navigate multiple platform requirements
- **Preprint submission**: Prepare manuscripts for PhilArchive, arXiv, etc.

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT License - see [LICENSE](LICENSE) for details.

## Author

**Li Shixiong**
Independent Researcher
ORCID: [0009-0008-2001-2865](https://orcid.org/0009-0008-2001-2865)

---

*These skills were developed through the author's experience publishing philosophy papers on consciousness and mortality.*
