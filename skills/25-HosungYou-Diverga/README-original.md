<div align="center">

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                                                                               ║
║     ██████╗ ██╗██╗   ██╗███████╗██████╗  ██████╗  █████╗                      ║
║     ██╔══██╗██║██║   ██║██╔════╝██╔══██╗██╔════╝ ██╔══██╗                     ║
║     ██║  ██║██║██║   ██║█████╗  ██████╔╝██║  ███╗███████║                     ║
║     ██║  ██║██║╚██╗ ██╔╝██╔══╝  ██╔══██╗██║   ██║██╔══██║                     ║
║     ██████╔╝██║ ╚████╔╝ ███████╗██║  ██║╚██████╔╝██║  ██║                     ║
║     ╚═════╝ ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝                     ║
║                                                                               ║
║              * Diverge from the Modal · Discover the Exceptional              ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝

              ┌─────────────────────────────────────────────────┐
              │  Research Methodology AI Assistant for          │
              │  Claude Code · 24 Specialized Agents · VS+HAVS  │
              └─────────────────────────────────────────────────┘
```

[![Version](https://img.shields.io/badge/version-12.0.0-7c3aed?style=for-the-badge&logo=semantic-release&logoColor=white)](https://github.com/HosungYou/Diverga)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Plugin-FF6B00?style=for-the-badge&logo=anthropic&logoColor=white)](https://claude.ai/code)
[![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge&logo=open-source-initiative&logoColor=white)](LICENSE)
[![Methodology](https://img.shields.io/badge/Powered_by-VS+HAVS-violet?style=for-the-badge&logo=academia&logoColor=white)](docs/methodology.md)
[![Language](https://img.shields.io/badge/language-English%20%7C%20한국어-orange?style=for-the-badge)](docs/i18n/ko/README-ko.md)
[![Agents](https://img.shields.io/badge/agents-24-purple?style=for-the-badge)](docs/AGENTS.md)
[![Tests](https://img.shields.io/badge/tests-56%2F56-brightgreen?style=for-the-badge)](mcp/test/)

```
         ╭──────────────────────────────────────────────────────────╮
         │                                                          │
         │  "When AI recommendations converge on the modal,         │
         │   Diverga helps you explore the exceptional."            │
         │                                                          │
         │               — Verbalized Sampling Principle            │
         │                                                          │
         ╰──────────────────────────────────────────────────────────╯
```

</div>

---

## What is Diverga?

**Diverga** is a research methodology assistant that transforms Claude Code into a **24-agent orchestra** for social science research. Built on **Verbalized Sampling (VS)** and **HAVS** (Humanization-Adapted VS) methodologies, it prevents AI "mode collapse" — the tendency to always recommend the same safe, predictable options.

<div align="center">

<img src="docs/images/diverga-agents-overview.jpeg" alt="Diverga: 24 AI Research Agents covering the full research lifecycle" width="700" />

<br /><br />

**Perfect For:** Education | Psychology | Management | Sociology | HRD | Communication

</div>

---

## The Problem: Mode Collapse in Research AI

Most AI research assistants suffer from **mode collapse** — they always recommend the same predictable options:

> "For technology adoption, I recommend TAM." (every single time)
> "For your meta-analysis, use random effects model." (always)
> "Try thematic analysis for your qualitative study." (the obvious choice)

**Diverga is different.** Built on **Verbalized Sampling (VS) methodology** ([arXiv:2510.01171](https://arxiv.org/abs/2510.01171)), it actively prevents mode collapse and guides you toward **creative, defensible research choices**.

<div align="center">

<img src="docs/images/vs-methodology-comparison.jpeg" alt="Standard AI vs Diverga with VS — mode collapse prevention through diversified recommendations" width="700" />

<p><em>Standard AI funnels to a single modal recommendation (T=0.94). Diverga with VS generates multiple creative alternatives across the typicality spectrum.</em></p>

</div>

---

## Quick Start (3 Steps)

```bash
# Step 1: Add to Claude Code marketplace
/plugin marketplace add https://github.com/HosungYou/Diverga

# Step 2: Install the plugin
/plugin install diverga

# Step 3: Run setup wizard
/diverga:setup
```

Then just say what you want:
```
"I want to conduct a meta-analysis on AI in education"
"Help me design an experimental study"
"I need a systematic review following PRISMA 2020"
```

Diverga auto-detects context and activates the right agents.

---

## v11.0.0 — Claude Code Exclusive

### Core Principle

> **"Human decisions remain with humans. AI handles what's beyond human scope."**

### What's New in v11.0.0

| Feature | Description |
|---------|-------------|
| **Agent Consolidation** | 44 agents consolidated to 24 focused agents via intelligent merging |
| **Category X** | New Cross-Cutting category with Research Guardian agent |
| **Claude Code Exclusive** | Streamlined for Claude Code only, removed Codex CLI and OpenCode support |
| **MCP Checkpoint Server** | 7-tool runtime verification of agent prerequisites |
| **Decision Audit Trail** | Immutable YAML log of all research decisions for IRB compliance |

### MCP Checkpoint Tools

| Tool | Description |
|------|-------------|
| `diverga_check_prerequisites` | Verify agent prerequisites before execution |
| `diverga_mark_checkpoint` | Record checkpoint decision with rationale |
| `diverga_checkpoint_status` | View passed/pending/blocked checkpoints |
| `diverga_priority_read` | Read compression-resilient priority context |
| `diverga_priority_write` | Update priority context (max 500 chars) |
| `diverga_project_status` | Full project status with research context |
| `diverga_decision_add` | Record research decisions to audit trail |

### Memory System

```bash
# Initialize project
/diverga:memory init --name "AI Education" --question "How does AI improve learning?" --paradigm quantitative

# Check context (or just ask "What's my research status?")
/diverga:memory status

# Full context loading
/diverga:memory context
```

#### 3-Layer Context System

| Layer | Trigger | When to Use |
|-------|---------|-------------|
| **Layer 1** | "my research", "where was I" | Ask naturally about research status |
| **Layer 2** | `Task(subagent_type="diverga:*")` | Context auto-injected to agents |
| **Layer 3** | `/diverga:memory context` | Full detailed context on demand |

---

## Human Checkpoint System

Diverga implements **forced divergence** through human checkpoints — the system **stops and waits** for your decision at every critical point.

### Checkpoint Types

| Level | Icon | Behavior |
|-------|------|----------|
| **REQUIRED** | RED | System STOPS — Cannot proceed without explicit approval |
| **RECOMMENDED** | ORANGE | System PAUSES — Strongly suggests approval |
| **OPTIONAL** | YELLOW | System ASKS — Defaults available if skipped |

### Required Checkpoints

| Checkpoint | When | What Happens |
|------------|------|--------------|
| CP_RESEARCH_DIRECTION | Research question finalized | Present VS options, WAIT for selection |
| CP_PARADIGM_SELECTION | Methodology approach | Ask Quantitative/Qualitative/Mixed |
| CP_THEORY_SELECTION | Framework chosen | Present alternatives with T-Scores |
| CP_METHODOLOGY_APPROVAL | Design complete | Detailed review required |

### Enforcement (v8.2)

Checkpoints are enforced at two levels:
1. **MCP Runtime**: `diverga_check_prerequisites(agent_id)` verifies all prerequisites before agent execution
2. **Prompt Level**: SKILL.md instructions ensure checkpoints trigger even without MCP

REQUIRED checkpoints **cannot be skipped** — attempting to skip triggers the Override Refusal template.

---

## Verbalized Sampling (VS) Methodology

### Dynamic T-Score System

Diverga assigns **Typicality Scores (T-Score)** to all recommendations:

| T-Score | Interpretation | Diverga Behavior |
|---------|----------------|------------------|
| `T > 0.8` | **Modal** (most common) | Flags as "predictable" |
| `T 0.5-0.8` | **Established alternative** | Suggests as balanced choice |
| `T 0.3-0.5` | **Emerging approach** | Recommends for innovation |
| `T < 0.3` | **Novel/creative** | Presents with strong rationale |

### VS in Action

```
WITHOUT VS (Mode Collapse):
   User: "Help me choose a theoretical framework for AI adoption study"
   AI: "I recommend Technology Acceptance Model (TAM)."
   (Same answer every time, T=0.92)

WITH VS (Diverga):
   User: "Help me choose a theoretical framework for AI adoption study"

   CHECKPOINT: CP_THEORY_SELECTION

   Diverga: "Let me analyze options across the typicality spectrum:

   [Modal Awareness] TAM (T=0.92) and UTAUT (T=0.85) are predictable choices.

   Recommended Options:
   - Direction A (T=0.6): Self-Determination Theory x TAM integration
   - Direction B (T=0.4): Cognitive Load Theory + Adaptive Ecosystem
   - Direction C (T=0.2): Neuroplasticity-based technology learning

   Which direction would you like to proceed?"
   (WAITS for human selection)
```

---

## Architecture: 24 Agents in 9 Categories

### Agent Categories

| Category | Count | Focus | Model Tier |
|----------|-------|-------|------------|
| **A: Research Foundation** | 3 | Research questions, theory, paradigm | Opus |
| **B: Literature & Evidence** | 2 | Literature search, quality appraisal | Sonnet |
| **C: Study Design** | 4 | Quant/qual/mixed design, meta-analysis | Opus |
| **D: Data Collection** | 2 | Interviews, instruments | Mixed |
| **E: Analysis** | 3 | Statistical analysis, qualitative coding, integration | Opus |
| **F: Quality & Validation** | 1 | Humanization verification | Haiku |
| **G: Publication & Communication** | 4 | Journal matching, writing, humanization | Mixed |
| **I: Systematic Review** | 4 | PRISMA pipeline, paper retrieval, screening, RAG | Mixed |
| **X: Cross-Cutting** | 1 | Research integrity, ethics oversight | Sonnet |

### Agent Prerequisite Map

Agents enforce a dependency order — downstream agents cannot run until upstream checkpoints are approved:

```
Level 0 (Entry): CP_RESEARCH_DIRECTION, CP_PARADIGM_SELECTION
Level 1:         CP_THEORY_SELECTION, CP_METHODOLOGY_APPROVAL
Level 2:         CP_ANALYSIS_PLAN, CP_SAMPLING_STRATEGY, CP_CODING_APPROACH, ...
Level 3:         SCH_DATABASE_SELECTION, CP_HUMANIZATION_REVIEW, CP_VS_001-003
Level 4:         SCH_SCREENING_CRITERIA, CP_HUMANIZATION_VERIFY
Level 5:         SCH_RAG_READINESS
```

### Parallel Execution

Independent agents run simultaneously for maximum efficiency:

```python
# Single agent
Task(subagent_type="diverga:a1", prompt="Refine my research question...")

# Parallel execution (single message, multiple Tasks)
Task(subagent_type="diverga:b1", prompt="Literature search...")
Task(subagent_type="diverga:b2", prompt="Quality appraisal...")
Task(subagent_type="diverga:c5", prompt="Meta-analysis orchestration...")
```

### Full Agent Registry

<details>
<summary><strong>Category A: Research Foundation (3 Agents)</strong></summary>

| Agent | Model | Purpose |
|-------|-------|---------|
| A1-research-question-refiner | Opus | FINER/PICO/SPIDER framework |
| A2-theory-and-critique-architect | Opus | Theory selection, critique, ethics, visualization |
| A5-paradigm-worldview-advisor | Opus | Quant/qual/mixed guidance |

</details>

<details>
<summary><strong>Category B: Literature & Evidence (2 Agents)</strong></summary>

| Agent | Model | Purpose |
|-------|-------|---------|
| B1-systematic-literature-scout | Sonnet | PRISMA/qualitative search |
| B2-evidence-quality-appraiser | Sonnet | RoB, GRADE assessment |

</details>

<details>
<summary><strong>Category C: Study Design (4 Agents)</strong></summary>

| Agent | Model | Purpose |
|-------|-------|---------|
| C1-quantitative-design-consultant | Opus | Experimental, survey design |
| C2-qualitative-design-consultant | Opus | Phenomenology, GT, case study |
| C3-mixed-methods-design-consultant | Opus | Sequential, convergent |
| C5-meta-analysis-master | Opus | Multi-gate validation, workflow orchestration |

</details>

<details>
<summary><strong>Category D: Data Collection (2 Agents)</strong></summary>

| Agent | Model | Purpose |
|-------|-------|---------|
| D2-interview-focus-group-specialist | Sonnet | Protocols, transcription |
| D4-measurement-instrument-developer | Opus | Scale construction |

</details>

<details>
<summary><strong>Category E: Analysis (3 Agents)</strong></summary>

| Agent | Model | Purpose |
|-------|-------|---------|
| E1-quantitative-analysis-guide | Opus | Statistical analysis |
| E2-qualitative-coding-specialist | Opus | Thematic, GT coding |
| E3-mixed-methods-integration | Opus | Joint displays, meta-inference |

</details>

<details>
<summary><strong>Category F: Quality & Validation (1 Agent)</strong></summary>

| Agent | Model | Purpose |
|-------|-------|---------|
| F5-humanization-verifier | Haiku | Transformation verification |

</details>

<details>
<summary><strong>Category G: Publication & Communication (4 Agents)</strong></summary>

| Agent | Model | Purpose |
|-------|-------|---------|
| G1-journal-matcher | Sonnet | Target journal selection |
| G2-academic-communicator | Sonnet | Audience adaptation |
| G5-academic-style-auditor | Sonnet | Academic writing quality analysis (24 categories) |
| G6-academic-style-humanizer | Opus | Scholarly voice improvement (HAVS) |

</details>

<details>
<summary><strong>Category I: Systematic Review Automation (4 Agents)</strong></summary>

| Agent | Model | Purpose |
|-------|-------|---------|
| I0-review-pipeline-orchestrator | Opus | 7-stage PRISMA pipeline orchestration |
| I1-paper-retrieval-agent | Sonnet | Multi-database paper fetching |
| I2-screening-assistant | Sonnet | AI-PRISMA screening with Groq |
| I3-rag-builder | Haiku | Vector database construction |

</details>

<details>
<summary><strong>Category X: Cross-Cutting (1 Agent)</strong></summary>

| Agent | Model | Purpose |
|-------|-------|---------|
| X1-research-guardian | Sonnet | Research integrity, ethics oversight, quality assurance |

</details>

---

## Installation

### Claude Code Plugin (Recommended)

```bash
# Install via marketplace
/plugin marketplace add https://github.com/HosungYou/Diverga
/plugin install diverga
/diverga:setup
```

### Manual Installation

```bash
# Clone and symlink skills
git clone https://github.com/HosungYou/Diverga.git
cd Diverga

# Install MCP dependencies
cd mcp && npm install && cd ..

# Create local skill symlinks
for skill_dir in skills/*/; do
  skill_name=$(basename "$skill_dir")
  cp -r "$skill_dir" ~/.claude/skills/diverga-${skill_name}
done

# Restart Claude Code
```

---

## Integration Hub

### Built-in (No Setup)

| Tool | Use Case |
|------|----------|
| Excel | Data extraction, coding sheets |
| PowerPoint | Conference presentations |
| Word | Manuscripts, method sections |
| Python | Analysis scripts |
| Mermaid | Flow diagrams |

### Requires Setup

| Tool | Purpose |
|------|---------|
| Semantic Scholar | Literature retrieval API |
| OpenAlex | Open access search |
| Zotero MCP | Reference management |
| R Scripts | Statistical analysis |

---

## Research Types Supported

**Quantitative:** Experimental designs (RCT, quasi-experimental), survey research, meta-analysis, correlational studies, psychometric validation

**Qualitative:** Phenomenology, grounded theory, case study, ethnography, narrative inquiry, action research

**Mixed Methods:** Sequential (explanatory, exploratory), convergent parallel, embedded design, transformative frameworks

---

## Version History

| Version | Date | Feature |
|---------|------|---------|
| **v11.0.0** | 2026-03-06 | Agent consolidation (44 to 24), Claude Code exclusive, Category X added |
| **v8.4.0** | 2026-02-12 | MCP runtime checkpoint enforcement, SKILL.md simplification, Priority Context |
| **v8.1.0** | 2026-02-10 | Checkpoint enforcement strengthening, Agent Prerequisite Map |
| **v8.0.0** | 2026-02-05 | Independent HUD, simplified setup, natural language project start |
| **v7.0.0** | 2026-02-01 | Memory System — 3-layer context, checkpoint auto-trigger, decision audit trail |
| **v6.7.0** | 2026-01-28 | Systematic Review Automation — Category I agents (I0-I3), PRISMA 2020 pipeline |
| **v6.5.0** | 2026-01-26 | Parallel Execution — Task tool support, /agents/ directory |
| **v6.3.0** | 2026-01-26 | Meta-Analysis Agent System — C5/C6/C7 for Hedges' g calculation |
| **v6.1.0** | 2026-01-25 | Writing Quality Pipeline — G5/G6/F5 for authentic academic expression (HAVS) |
| **v6.0.0** | 2026-01-25 | Human-Centered Edition — Mandatory checkpoints, removed autonomous modes |

See [CHANGELOG](docs/CHANGELOG.md) for full history.

---

## Documentation

| Document | Description |
|----------|-------------|
| [CLAUDE.md](CLAUDE.md) | Full system documentation |
| [AGENTS.md](AGENTS.md) | 24 agents detailed reference |
| [CHANGELOG](docs/CHANGELOG.md) | Version history |
| [Agent Orchestration Guide](docs/AGENT-ORCHESTRATION-GUIDE.md) | Multi-agent pipelines |
| [VS Methodology](docs/VS-METHODOLOGY.md) | Deep dive into Verbalized Sampling |
| [Quick Start](docs/QUICKSTART.md) | Get started in 5 minutes |

---

## License

MIT License - see [LICENSE](LICENSE) for details.

---

## Acknowledgments

- [Claude Code](https://claude.ai/code) by Anthropic
- [Verbalized Sampling (arXiv:2510.01171)](https://arxiv.org/abs/2510.01171) — VS methodology foundation
- Social science research community for feedback

---

## Citation

```bibtex
@software{diverga,
  author = {You, Hosung},
  title = {Diverga: Beyond Modal AI Research Assistant},
  year = {2026},
  version = {11.1.0},
  url = {https://github.com/HosungYou/Diverga},
  note = {24 agents with VS methodology, MCP-enforced human checkpoints,
          meta-analysis system, humanization pipeline (HAVS),
          systematic review automation (PRISMA 2020).
          Prevents mode collapse through Verbalized Sampling (arXiv:2510.01171)}
}
```

---

<div align="center">

**Made for Social Science Researchers**

*Diverga: Where creativity meets rigor. Beyond the obvious, toward the innovative.*

</div>
