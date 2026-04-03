# Awesome Econ AI Stuff 

> A curated collection of AI skills for economists. Skills follow the open [SKILL.md](https://agentskills.io/home) standard and work with Claude Code, Cursor, Codex, Gemini CLI, and other AI-native coding tools.

<p align="center">
  <a href="https://meleantonio.github.io/awesome-econ-ai-stuff">🌐 Website</a> •
  <a href="#quick-start">🚀 Quick Start</a> •
  <a href="#skills-catalog">📚 Skills</a> •
  <a href="CONTRIBUTING.md">🤝 Contribute</a>
</p>

---

## Why AI Skills for Economists?

Economic research involves complex, repetitive workflows—from data cleaning in Stata to writing LaTeX papers. AI skills automate these workflows while preserving methodological rigor.

**Skills help you:**
- 📊 Clean and transform data faster (Stata, R, Python)
- 📐 Write mathematical models in LaTeX
- 🔬 Run econometric analyses with proper diagnostics
- 📝 Draft papers following journal conventions
- 🎯 Create publication-quality visualizations

---

## Quick Start

### 1. Choose Your AI Tool

Skills work with multiple AI coding assistants:

| Tool | Skill Location | Setup |
|------|---------------|-------|
| **Claude Code** | `~/.claude/skills/` | [Docs](https://docs.anthropic.com/claude-code) |
| **Cursor** | `~/.cursor/skills/` | [Docs](https://cursor.com/docs) |
| **Gemini CLI** | `~/.gemini/skills/` | [Docs](https://github.com/google-gemini/gemini-cli) |
| **Codex** | Project `AGENTS.md` | [Docs](https://agents.md) |

### 2. Install a Skill

```bash
# Clone a skill to your tools directory
# Example for Claude Code:
mkdir -p ~/.claude/skills
cp -r skills/analysis/r-econometrics ~/.claude/skills/
```

### 3. Use the Skill

Invoke skills via slash commands or natural language:

```
/r-econometrics Run a DiD analysis on my treatment data
```

---

## Skills Catalog

Skills are organized by research workflow stage:

### 💡 Ideation
- [research-ideation](skills/ideation/research-ideation/) - Generate research questions from economic phenomena

### 📚 Literature Review
- [lit-review-assistant](skills/literature/lit-review-assistant/) - Search, summarize, and synthesize papers

### 📐 Theory & Modeling
- [latex-econ-model](skills/theory/latex-econ-model/) - Write economic models in LaTeX
- [general-equilibrium-model-builder](skills/theory/general-equilibrium-model-builder/) - Build and solve Walrasian GE models in Julia
- [game-theory-solver](skills/theory/game-theory-solver/) - Solve and visualize game theory problems

### 📊 Data Management
- [stata-data-cleaning](skills/data/stata-data-cleaning/) - Clean and transform data in Stata
- [api-data-fetcher](skills/data/api-data-fetcher/) - Fetch data from economic APIs (FRED, World Bank)

### 🔬 Econometric Analysis
- [r-econometrics](skills/analysis/r-econometrics/) - Run IV, DiD, RDD in R
- [python-panel-data](skills/analysis/python-panel-data/) - Panel data analysis with Python
- [stata-regression](skills/analysis/stata-regression/) - Regression analysis in Stata

### 📝 Academic Writing
- [academic-paper-writer](skills/writing/academic-paper-writer/) - Draft papers with proper structure
- [latex-tables](skills/writing/latex-tables/) - Generate publication-ready LaTeX tables
- [referee-response](skills/writing/referee-response/) - Draft referee report responses

### 🎯 Communication
- [beamer-presentation](skills/communication/beamer-presentation/) - Create Beamer slides
- [econ-visualization](skills/communication/econ-visualization/) - Publication-quality charts
- [research-website](skills/communication/research-website/) - Build academic project websites

---

## Creating Skills

See our [Skill Template](skills/SKILL_TEMPLATE.md) and [Contributing Guide](CONTRIBUTING.md).

Basic structure:
```yaml
---
name: my-skill-name
description: What the skill does (shown in skill discovery)
workflow_stage: analysis
compatibility: [claude-code, cursor, codex, gemini-cli]
---

# My Skill Name

[Detailed instructions for the AI agent...]
```

### 🆕 Propose a New Skill

**[Submit via Web Form →](https://meleantonio.github.io/awesome-econ-ai-stuff/submit)**

Or open an [Issue](https://github.com/meleantonio/awesome-econ-ai-stuff/issues/new?template=skill-proposal.md).

---

## Compatible Tools

| Tool | Status | Notes |
|------|--------|-------|
| Claude Code | ✅ Full | Native SKILL.md support |
| Cursor | ✅ Full | Native SKILL.md support |
| Gemini CLI | ✅ Full | Native SKILL.md support |
| GitHub Copilot | ⚠️ Partial | Use AGENTS.md format |
| Windsurf | ✅ Full | SKILL.md compatible |
| Aider | ⚠️ Partial | Use .aider.conf.yml |

---

## Resources

- [Agent Skills Standard](https://agentskills.io/home) - The open SKILL.md specification
- [Anthropic Claude Code Docs](https://docs.anthropic.com/claude-code)
- [Cursor Skills Documentation](https://cursor.com/docs/skills)
- [QuantEcon](https://quantecon.org) - Python/Julia for economists

---

## Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

**Ways to contribute:**
- 🆕 Submit new skills via the [web form](https://meleantonio.github.io/awesome-econ-ai-stuff/submit)
- 🐛 Report issues or suggest improvements
- 📖 Improve documentation
- ⭐ Star this repo to show support

---

## License

[![CC0](https://licensebuttons.net/p/zero/1.0/88x31.png)](https://creativecommons.org/publicdomain/zero/1.0/)

This work is dedicated to the public domain under [CC0 1.0](LICENSE).
