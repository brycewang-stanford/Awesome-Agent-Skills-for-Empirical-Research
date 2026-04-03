<!--
  ╔══════════════════════════════════════════════════════════════╗
  ║  本文件为开源 Skill 原始文档，收录仅供学习与研究参考        ║
  ║  CoPaper.AI 收集整理 | https://copaper.ai                  ║
  ╚══════════════════════════════════════════════════════════════╝

  来源仓库: https://github.com/K-Dense-AI/claude-scientific-writer
  项目名称: claude-scientific-writer
  开源协议: MIT License
  收录日期: 2026-04-02

  声明: 本文件版权归原作者所有。此处收录旨在为社会科学实证研究者
  提供 AI Agent Skills 的集中参考。如有侵权，请联系删除。
-->

# Claude Scientific Writer

[![PyPI version](https://img.shields.io/pypi/v/scientific-writer.svg)](https://pypi.org/project/scientific-writer/)
[![Total Downloads](https://static.pepy.tech/badge/scientific-writer)](https://pepy.tech/project/scientific-writer)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> 🚀 **Looking for more advanced capabilities?** For end-to-end scientiic writing, deep scientfic search, advanced image generation and enterprise solutions, visit **[www.k-dense.ai](https://www.k-dense.ai)**

**A deep research and writing tool** that combines the power of AI-driven deep research with well-formatted written outputs. Generate publication-ready scientific papers, reports, posters, grant proposals, literature reviews, and more academic documents—all backed by real-time literature search and verified citations.

Scientific Writer performs comprehensive research before writing, ensuring every claim is supported by real, verifiable sources. Features include real-time research lookup via Perplexity Sonar Pro Search, intelligent paper detection, comprehensive document conversion, and AI-powered diagram generation with Nano Banana Pro. You have the option of using it as a claude code plugin, python package or a native CLI

## Quick Start

### Prerequisites
- Python 3.10-3.12
- ANTHROPIC_API_KEY (required), OPENROUTER_API_KEY (optional for research lookup)

### Installation Options

#### Option 1: Claude Code Plugin (Recommended) ⭐
The easiest way to use Scientific Writer is as a Claude Code plugin. See the [Plugin Installation](#-use-as-a-claude-code-plugin-recommended) section above.

#### Option 2: Install from PyPI (CLI/API Usage)
```bash
pip install scientific-writer
```

#### Option 3: Install from source with uv
```bash
git clone https://github.com/K-Dense-AI/claude-scientific-writer.git
cd claude-scientific-writer
uv sync
```

### Configure API keys
```bash
# .env file (recommended)
echo "ANTHROPIC_API_KEY=your_key" > .env
echo "OPENROUTER_API_KEY=your_openrouter_key" >> .env
# or export in your shell
export ANTHROPIC_API_KEY='your_key'
```

### Usage Options

#### Use as Plugin (Recommended)
After installing the plugin and running `/scientific-writer:init`, simply ask Claude:
```bash
> Create a Nature paper on CRISPR gene editing. Present experimental_data.csv 
  (efficiency across 5 cell lines), include Western_blot.png and flow_cytometry.png 
  showing 87% editing efficiency (p<0.001). Compare with literature benchmarks.

> Generate an NSF grant proposal presenting preliminary data from quantum_results.csv 
  (99.2% gate fidelity), circuit_topology.png, and error_rates.csv. 
  Include 5-year timeline with milestones_budget.xlsx.

> @research-lookup Find papers on mRNA vaccine efficacy (2022-2024). Compare 
  with our trial_outcomes.csv (n=500, 94% efficacy) and antibody_titers.png.
```

#### Use the CLI
```bash
# If installed via pip
scientific-writer

# If installed from source with uv
uv run scientific-writer
```

#### Use the Python API
```python
import asyncio
from scientific_writer import generate_paper

async def main():
    # Detailed prompt with specific data and figures
    async for update in generate_paper(
        query=(
            "Create a Nature paper on CRISPR gene editing. "
            "Present editing_efficiency.csv (5 cell lines, n=200 cells each). "
            "Include Western blot (protein_knockout.png) showing target depletion, "
            "flow cytometry data (editing_percentages.png) with 87% efficiency in HEK293, "
            "and off_target_analysis.csv showing <0.1% off-target effects. "
            "Compare results to published Cas9 benchmarks (typically 70-75% efficiency)."
        ),
        data_files=[
            "editing_efficiency.csv",
            "protein_knockout.png",
            "editing_percentages.png",
            "off_target_analysis.csv"
        ]
    ):
        if update["type"] == "progress":
            print(f"[{update['stage']}] {update['message']}")
        else:
            print(f"✓ PDF: {update['files']['pdf_final']}")
            print(f"  Figures: {len(update.get('figures', []))} included")

asyncio.run(main())
```

## 🎯 Use as a Claude Code Plugin (Recommended)

**Scientific Writer works best as a Claude Code (Cursor) plugin**, providing seamless access to all scientific writing capabilities directly in your IDE. No CLI required!

### Quick Start - Plugin Installation

1. **Add the plugin marketplace** in Claude Code:
   ```bash
   /plugin marketplace add https://github.com/K-Dense-AI/claude-scientific-writer
   ```

2. **Install the plugin**:
   ```bash
   /plugin install claude-scientific-writer
   ```

3. **Restart Claude Code** when prompted.

4. **Initialize in your project**:
   ```bash
   /scientific-writer:init
   ```
   This creates a `CLAUDE.md` file with comprehensive scientific writing instructions and makes all 19+ skills available.

5. **Start using immediately**:
   ```bash
   # Create papers with data and figures
   > Create a Nature paper on CRISPR gene editing. Present knockout_efficiency.csv 
     (5 cell lines tested), include Western blot (protein_levels.png) and flow 
     cytometry data (editing_rates.png). Highlight 87% efficiency in HEK293 cells.
   
   > Write an NSF grant proposal for quantum computing. Present preliminary results 
     from gate_fidelity.csv (99.2% fidelity), include circuit_diagram.png and 
     error_analysis.png. Compare to state-of-art 95% baseline.
   
   > Generate conference poster. Feature results from clinical_trial.csv 
     (n=150), survival_curves.png, biomarker_heatmap.png, and mechanism_diagram.svg.
   
   # Use specific skills with research data
   > @research-lookup Find papers on mRNA vaccine efficacy (2022-2024). Compare 
     with our trial_data.csv showing 94% efficacy and antibody_titers.xlsx.
   
   > @peer-review Evaluate this manuscript. Reference sample size in methods.csv 
     (n=30) and effect_sizes.png. Assess if statistical power is adequate.
   
   > @clinical-reports Create case report for autoimmune disorder. Include patient_labs.xlsx 
     (6 months data), MRI_scans/ folder, treatment_timeline.csv showing response.
   ```

### Why Use the Plugin?

- ✅ **No CLI Required** - Everything works directly in Claude Code
- ✅ **Instant Access** - All 19+ skills available immediately
- ✅ **IDE Integration** - Files created and edited in your project
- ✅ **Context Aware** - Skills understand your project structure
- ✅ **Seamless Workflow** - No switching between tools

### Available Skills

When installed as a plugin, you get instant access to:
- `scientific-schematics` - AI diagram generation with Nano Banana Pro (CONSORT, neural networks, pathways)
- `research-lookup` - Real-time literature search
- `peer-review` - Systematic manuscript evaluation
- `citation-management` - BibTeX and reference handling
- `clinical-reports` - Medical documentation standards
- `research-grants` - NSF, NIH, DOE proposal support
- `scientific-slides` - Research presentations
- `latex-posters` - Conference poster generation
- `hypothesis-generation` - Scientific hypothesis development
- `market-research-reports` - Comprehensive 50+ page market analysis reports with visuals
- And 10+ more specialized skills...

See the [Plugin Testing Guide](#plugin-testing-local-development) below for local development instructions.

## Features

### 📝 Document Generation
- **Scientific papers** with IMRaD structure (Nature, Science, NeurIPS, etc.)
- **Clinical reports** (case reports, diagnostic reports, trial reports, patient documentation)
- **Research posters** using LaTeX (beamerposter, tikzposter, baposter)
- **Grant proposals** (NSF, NIH, DOE, DARPA) with agency-specific formatting
- **Literature reviews** with systematic citation management
- **Scientific schematics** powered by Nano Banana Pro (CONSORT diagrams, neural architectures, biological pathways, circuit diagrams)

### 🤖 AI-Powered Capabilities
- **Real-time research lookup** using Perplexity Sonar Pro Search (via OpenRouter)
- **AI-powered diagram generation** with Nano Banana Pro - create any scientific diagram from natural language descriptions
- **Intelligent paper detection** - automatically identifies references to existing papers
- **Peer review feedback** with quantitative ScholarEval framework (8-dimension scoring)
- **Iterative editing** with context-aware revision suggestions

### 🔧 Developer-Friendly
- **Programmatic API** - Full async Python API with type hints
- **CLI interface** - Interactive command-line tool with progress tracking
- **Progress streaming** - Real-time updates during generation
- **Comprehensive results** - JSON output with metadata, file paths, citations

### 📦 Data & File Integration
- **Automatic data handling** - Drop files in `data/`, auto-sorted to `figures/` or `data/`
- **Document conversion** - PDF, DOCX, PPTX, XLSX to Markdown with MarkItDown
- **Bibliography management** - Automatic BibTeX generation and citation formatting
- **Figure integration** - Images automatically referenced and organized

## Typical Workflow

### CLI Usage
1. Place figures and data in `data/` at the project root (images → `figures/`, files → `data/` automatically)
2. Run `scientific-writer` and describe what you want
3. Follow progress updates; outputs saved to `writing_outputs/<timestamp>_<topic>/`

```bash
# Start a new paper with figures and data
> Create a Nature paper on CRISPR gene editing. Include experimental_results.csv showing knockout efficiency across 5 cell lines. Reference figure1.png (Western blot) and figure2.png (flow cytometry data) in the results section. Discuss the 87% efficiency improvement observed in HEK293 cells.

# Continue editing with additional research results
> Add a methods section describing the experimental setup used to generate the data in results_table.csv. Reference the protocols for transfection, selection, and validation shown in microscopy_images/ folder.

# Grant proposal with preliminary data
> Write an NSF proposal for quantum computing research. Present preliminary results from quantum_fidelity.csv showing 99.2% gate fidelity. Include circuit_diagram.png and error_rates.png figures. Emphasize the breakthrough results compared to current state-of-art (95% fidelity).

# Research poster with comprehensive figures
> Generate a conference poster from my paper. Feature dose_response_graph.png as the central figure. Include mechanism_schematic.png, compare_treatments.png, and statistical_analysis.png. Highlight the p<0.001 significance for the primary outcome shown in the results.

# Clinical case report with patient data
> Create a clinical case report for rare disease presentation. Reference patient_timeline.csv showing symptom progression over 6 months. Include diagnostic_images/ (CT scans, MRI). Discuss lab_values.xlsx showing elevated biomarkers and treatment response documented in follow_up_data.csv.

# Literature review with meta-analysis
> Create a literature review on machine learning in healthcare. Reference the comparison in studies_comparison.csv covering 50 papers. Include forest_plot.png showing pooled effect sizes and quality_assessment.png from bias analysis. Synthesize the findings showing diagnostic accuracy (AUC 0.89), treatment prediction (accuracy 82%), and risk stratification results.
```

### API Usage
```python
import asyncio
from scientific_writer import generate_paper

async def main():
    async for update in generate_paper(
        query="Create a NeurIPS paper on transformers",
        data_files=["results.csv", "figure.png"],
        output_dir="./my_papers",
        track_token_usage=True  # Optional: track token consumption
    ):
        if update["type"] == "progress":
            print(f"[{update['stage']}] {update['message']}")
        else:
            print(f"✓ PDF: {update['files']['pdf_final']}")
            # Token usage available when track_token_usage=True
            if "token_usage" in update:
                print(f"  Tokens used: {update['token_usage']['total_tokens']:,}")

asyncio.run(main())
```

## Quick Reference

### Common Commands

| Task | Command Example |
|------|----------------|
| **Scientific Paper** | `> Create a Nature paper on CRISPR gene editing. Present knockout efficiency data from results.csv (5 cell lines tested). Include Western blot (figure1.png) and flow cytometry (figure2.png) showing 87% efficiency in HEK293 cells. Compare with published benchmarks.` |
| **Clinical Report** | `> Create a clinical case report for rare mitochondrial disease. Include patient_timeline.csv (6-month progression), diagnostic_scans/ folder (MRI, CT images), and lab_values.xlsx showing elevated lactate (8.2 mmol/L) and creatine kinase (450 U/L). Describe treatment response.` |
| **Grant Proposal** | `> Write an NSF proposal for quantum error correction research. Present preliminary data from gate_fidelity.csv showing 99.2% fidelity (vs 95% state-of-art). Include circuit_topology.png, error_rates_comparison.png, and scalability_projections.csv for 100-qubit systems.` |
| **Research Poster** | `> Generate an A0 conference poster. Highlight findings from efficacy_study.csv (n=150 patients, 40% response rate). Feature mechanism_diagram.png, survival_curves.png, biomarker_heatmap.png, and statistical_forest_plot.png (p<0.001 primary endpoint).` |
| **Literature Review** | `> Create a systematic review on AI in drug discovery. Reference studies_database.csv (127 papers, 2020-2024). Include success_rates_meta.png (pooled OR=2.3, 95% CI 1.8-2.9), publication_trends.png, and therapeutic_areas_breakdown.csv showing oncology dominance (45% of studies).` |
| **Peer Review** | `> Evaluate this manuscript using ScholarEval. Reference figures (power_analysis.png shows n=30, underpowered), review statistics in results_table.csv, assess methodology against CONSORT standards, verify citations match claims.` |
| **Hypothesis Paper** | `> Generate research hypotheses on aging interventions. Reference transcriptomics_data.csv (15,000 genes across tissues), pathway_enrichment.png, and longevity_correlations.csv. Propose 5 testable hypotheses linking NAD+ metabolism, senescence, and lifespan extension.` |
| **Continue Editing** | `> Add methods section describing the protocols used to generate binding_assay.csv data. Include equipment specs, statistical tests used (t-tests in stats_summary.csv), and sample size justification from power_calculation.xlsx` |
| **Find Existing Paper** | `> Find the CRISPR paper and add discussion of limitations shown in off_target_analysis.csv and efficiency_variation.png across different cell types` |

### Research Lookup Examples

```bash
# Recent research with data integration (auto-triggers research lookup)
> Create a paper on recent advances in quantum computing (2024). Compare published values with our gate_fidelity_results.csv (99.2% for 2-qubit gates). Include our error_correction_benchmarks.png and cite papers achieving >98% fidelity. Discuss how our topology_diagram.png relates to Google's and IBM's recent architectures.

# Fact verification with experimental context
> What are the current success rates for CAR-T therapy in B-cell lymphoma? Compare with our clinical_trial_outcomes.csv (n=45 patients, 62% complete response). Include our response_timeline.png and cytokine_profiles.csv. How do our results compare to published JULIET and ZUMA trials?

# Literature search with data-driven focus
> Find 10 recent papers on transformer efficiency optimizations (2023-2024). Compare their reported FLOPS and memory usage with our benchmark_results.csv testing GPT-4, Claude, and Llama models. Include our latency_comparison.png and throughput_scaling.csv for context.

# Meta-analysis with new data
> Search for RCTs on metformin in aging (last 5 years). Compare published efficacy data with our mouse_longevity_study.csv (18% lifespan extension, n=120). Include our survival_curves.png, biomarker_changes.xlsx (AMPK, mTOR, NAD+ levels), and dose_response.png. How do our findings align with human trial outcomes?

# Comparative analysis
> Find papers on CRISPR base editors vs prime editors (2022-2024). Compare their reported efficiency and specificity with our editing_efficiency.csv (5 targets, 3 cell lines). Include our off_target_analysis.png and on_target_rates.csv. Discuss if our 89% on-target rate is competitive.
```

### Document Types

| Type | Example with Data/Figures |
|------|---------|
| **Papers** | `> Create a Nature paper on neural plasticity. Present electrophysiology_data.csv (n=30 neurons), include LTP_traces.png, calcium_imaging_timelapse/ folder, and synaptic_strength.csv showing 156% potentiation (p<0.001).` |
| **Clinical Reports** | `> Write a case report for autoimmune encephalitis. Include MRI_series/ (FLAIR, T2 sequences), CSR_results.xlsx (oligoclonal bands, elevated IgG), EEG_recordings.png, treatment_timeline.csv showing immunotherapy response over 8 weeks.` |
| **Grants** | `> NSF proposal for optogenetics. Present pilot_data/ with behavioral_results.csv (n=24 mice), neural_activation_maps.png, circuit_tracing.tif, and projection_analysis.csv showing 78% success in behavior modification. Include 5-year timeline with milestones.xlsx.` |
| **Posters** | `> A0 poster for ASCO conference. Feature trial_demographics.csv (n=200), primary_outcome_kaplan_meier.png, adverse_events_heatmap.png, biomarker_correlations.csv, mechanism_schematic.png. Highlight 8.5 month median PFS improvement.` |
| **Reviews** | `> Systematic review of immunotherapy combinations. Reference extracted_data.csv from 85 trials, include forest_plot_OS.png and forest_plot_PFS.png for meta-analysis, risk_of_bias_summary.png, network_meta_analysis.csv comparing 12 regimens.` |
| **Schematics** | `> Generate CONSORT diagram for RCT using Nano Banana Pro. Use enrollment_data.csv (n=450 screened, 312 randomized), show flowchart with allocation. Create transformer architecture diagram showing encoder-decoder. Generate biological pathway diagrams for MAPK signaling.` |

### File Handling

```bash
# 1. Drop all your research files in data/ folder
cp experimental_data.csv ~/Documents/claude-scientific-writer/data/
cp western_blot.png ~/Documents/claude-scientific-writer/data/
cp flow_cytometry.png ~/Documents/claude-scientific-writer/data/
cp statistical_summary.xlsx ~/Documents/claude-scientific-writer/data/
cp methods_diagram.svg ~/Documents/claude-scientific-writer/data/

# 2. Files are automatically sorted by type:
#    Images (png, jpg, svg, tif, pdf figures) → figures/
#    Data files (csv, json, txt, xlsx, tsv) → data/
#    Documents (pdf, docx, pptx) → converted to markdown

# 3. Reference files explicitly in your prompt with specific details
> Create a NeurIPS paper on deep learning optimization. Include training_curves.csv showing convergence after 50 epochs across 5 model architectures. Reference accuracy_comparison.png (our method: 94.2% vs baseline: 89.1%), loss_landscapes.png visualizing optimization trajectories, and hyperparameter_grid.csv with 100 configurations tested. Include architecture_diagram.svg in methods. Discuss the 5.1% accuracy improvement and 30% faster convergence shown in benchmark_results.xlsx.

# 4. Reference folders for multiple related files
> Write a radiology case report. Include the CT_scans/ folder (20 slices showing tumor progression), lab_results/ with weekly bloodwork CSVs, and treatment_response.xlsx documenting lesion measurements. Reference dates in imaging_timeline.csv for timeline.

# 5. Combine data files for comprehensive presentation
> Generate grant proposal presenting preliminary data from: dose_response.csv (6 doses, 4 replicates), survival_analysis.csv (Kaplan-Meier data, n=80 mice), mechanism_pathway.png, gene_expression.csv (RNA-seq, 15,000 genes), and protein_validation.xlsx (Western blots quantified). Include budget from project_costs.xlsx.
```

### API Quick Start

```python
import asyncio
from scientific_writer import generate_paper

# Simple usage with detailed prompt
async for update in generate_paper(
    "Create a Nature paper on CRISPR base editing. Present editing efficiency from "
    "results.csv (5 cell lines, n=200 per line). Include Western blots (protein_expression.png), "
    "flow cytometry (editing_rates.png), and off-target analysis (specificity_heatmap.png). "
    "Highlight 89% on-target efficiency with <0.1% off-target effects."
):
    if update["type"] == "result":
        print(f"PDF: {update['files']['pdf_final']}")

# With multiple data files and specific instructions
async for update in generate_paper(
    query=(
        "Create an ICML paper on reinforcement learning for robotics. "
        "Present training_metrics.csv (1M timesteps, 5 environments). "
        "Include learning_curves.png comparing our method (reward: 450) vs baselines (320), "
        "success_rates.csv across 100 test episodes, policy_visualizations.png, "
        "and ablation_study.xlsx testing 8 hyperparameter configurations. "
        "Include robot_architecture.svg diagram and trajectory_examples.png in methods. "
        "Emphasize 40% improvement over SAC and 25% over TD3."
    ),
    data_files=[
        "training_metrics.csv",
        "learning_curves.png", 
        "success_rates.csv",
        "policy_visualizations.png",
        "ablation_study.xlsx",
        "robot_architecture.svg",
        "trajectory_examples.png"
    ],
    output_dir="./papers"
):
    if update["type"] == "progress":
        print(f"[{update['stage']}] {update['message']}")
    elif update["type"] == "result":
        print(f"✓ Paper completed!")
        print(f"  PDF: {update['files']['pdf_final']}")
        print(f"  LaTeX: {update['files']['tex_final']}")
        print(f"  Figures: {len(update.get('figures', []))} included")

# Clinical trial report with comprehensive data
async for update in generate_paper(
    query=(
        "Generate Phase 2 clinical trial report for novel immunotherapy. "
        "Present patient_demographics.csv (n=120, stratified by age/stage), "
        "primary_endpoint_PFS.csv (median 12.3 months, HR=0.65, p=0.003), "
        "secondary_outcomes.xlsx (ORR 45%, DCR 78%), "
        "kaplan_meier_curves.png for OS and PFS, "
        "adverse_events.csv (Grade 3+: 23%), "
        "biomarker_analysis.csv (PD-L1, TMB correlations), "
        "and response_waterfall.png. Include CONSORT diagram based on enrollment_flow.csv."
    ),
    data_files=[
        "patient_demographics.csv",
        "primary_endpoint_PFS.csv", 
        "secondary_outcomes.xlsx",
        "kaplan_meier_curves.png",
        "adverse_events.csv",
        "biomarker_analysis.csv",
        "response_waterfall.png",
        "enrollment_flow.csv"
    ]
):
    if update["type"] == "result":
        print(f"Trial report: {update['files']['pdf_final']}")
```

## Plugin Testing (Local Development)

For developers working on the plugin or testing locally:

### Setup Local Marketplace

1. **Create a test marketplace** in the parent directory:
   ```bash
   cd ..
   mkdir -p test-marketplace/.claude-plugin
   ```

2. **Create marketplace configuration** (`test-marketplace/.claude-plugin/marketplace.json`):
   
   Copy the example from `test-marketplace-example.json` or create:
   
   ```json
   {
     "name": "test-marketplace",
     "owner": { "name": "K-Dense" },
     "plugins": [
       {
         "name": "claude-scientific-writer",
         "source": "../claude-scientific-writer",
         "description": "Scientific writing skills and CLAUDE.md initializer"
       }
     ]
   }
   ```
   
   **Note**: Update the `source` path to match your local directory structure (relative to the test-marketplace directory).

### Install and Test

3. **Add the test marketplace** in Claude Code:
   ```bash
   /plugin marketplace add ../test-marketplace
   ```
   
   (Use the correct relative or absolute path to your test-marketplace directory)

4. **Install the plugin**:
   ```bash
   /plugin install claude-scientific-writer@test-marketplace
   ```

5. **Restart Claude Code** when prompted.

6. **Test the plugin**:
   - Open any project directory
   - Run `/scientific-writer:init`
   - Verify CLAUDE.md is created
   - Test skills: "What skills are available?"
   - Try creating a document: "Create a short scientific abstract on quantum computing"

### Verify Plugin Structure

Your plugin should have this structure:
```
claude-scientific-writer/
├── .claude-plugin/
│   └── plugin.json          # Plugin metadata
├── commands/
│   └── scientific-writer-init.md  # /scientific-writer:init command
├── skills/                  # All 20 skills
│   ├── citation-management/
│   ├── clinical-decision-support/
│   ├── clinical-reports/
│   ├── document-skills/
│   ├── hypothesis-generation/
│   ├── latex-posters/
│   ├── literature-review/
│   ├── market-research-reports/
│   ├── markitdown/
│   ├── paper-2-web/
│   ├── peer-review/
│   ├── research-grants/
│   ├── research-lookup/
│   ├── scholar-evaluation/
│   ├── scientific-critical-thinking/
│   ├── scientific-schematics/
│   ├── scientific-slides/
│   ├── scientific-writing/
│   ├── treatment-plans/
│   └── venue-templates/
├── templates/
│   └── CLAUDE.scientific-writer.md  # CLAUDE.md template
└── ... (existing Python package files)
```

### Troubleshooting Plugin Installation

- **Skills not showing**: Verify each `SKILL.md` has valid YAML frontmatter (name, description, allowed-tools)
- **Command not working**: Check `commands/scientific-writer-init.md` exists and has proper frontmatter
- **Template not found**: Ensure `templates/CLAUDE.scientific-writer.md` is present
- **Marketplace not loading**: Verify `marketplace.json` syntax and relative path to plugin

## 📄 Example Outputs

Want to see what Scientific Writer can create? Check out real examples in the [`docs/examples/`](docs/examples/) directory!

| Document Type | Example | Description |
|--------------|---------|-------------|
| **Research Paper** | Coming soon | Full scientific papers with IMRaD structure |
| **Grant Proposal** | [NSF Proposal](docs/examples/grants/v6_draft.pdf) | Complete NSF grant with budget and timeline |
| **Research Poster** | [Conference Poster](docs/examples/poster/poster.pdf) | LaTeX-generated academic poster |
| **Presentation Slides** | [AI Scientist Talk](docs/examples/slides/ai_scientist_talk.pdf) | Professional research presentation |
| **Clinical Report** | [Treatment Plan](docs/examples/treatment_plan/GERD.pdf) | Patient treatment documentation |
| **Clinical Decision Support** | [Breast Cancer](docs/examples/clinical_decision_support/breast_cancer.pdf) | Evidence-based clinical recommendations |
| **Hypothesis Generation** | [AI Weather Prediction](docs/examples/hypotheses_generation/AI_in_weather.pdf) | Research hypothesis development |
| **Market Research** | [Agentic AI Report](docs/examples/market%20research%20reports/agentic_ai_life_sciences.pdf) | Industry analysis and market insights |

**🎯 Browse the examples** to see formatting, structure, and quality before starting your own projects!

## Documentation

### User Guides
- [📖 Complete Features Guide](docs/FEATURES.md) - Comprehensive overview of all capabilities
- [🔧 API Reference](docs/API.md) - Full programmatic API documentation
- [🎯 Skills Overview](docs/SKILLS.md) - All available skills and tools
- [🐛 Troubleshooting](docs/TROUBLESHOOTING.md) - Common issues and solutions

### Developer Resources
- [💻 Development Guide](docs/DEVELOPMENT.md) - Contributing and development setup
- [📦 Releasing Guide](docs/RELEASING.md) - Versioning and publishing
- [📋 Release Notes](CHANGELOG.md) - Version history and updates
- [🤖 System Instructions](CLAUDE.md) - Agent instructions (advanced)

## Versioning and Publishing (short)
Use `uv` and the helper scripts:
- Bump version (keeps pyproject + __init__ in sync): `uv run scripts/bump_version.py [patch|minor|major]`
- Build and publish: `uv run scripts/publish.py` (or `--bump patch|minor|major`)
See [docs/RELEASING.md](docs/RELEASING.md) for prerequisites, dry runs, tagging, and verification.

## Migration (v1.x -> v2.0)
- CLI remains unchanged (scientific-writer).
- New programmatic API: from scientific_writer import generate_paper.
- Legacy single-file script is replaced by a proper package; no action needed for CLI users.

## License
MIT - see LICENSE.

## Support
- Open an issue on GitHub
- See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for common problems

## 💬 Join Our Community!

**Want to connect with other researchers, share tips, and get help in real-time?** Join our vibrant Slack community! 🎉

Whether you're writing your first paper, exploring advanced features, or just want to chat about scientific writing and AI, we'd love to have you! Get faster support, share your success stories, and collaborate with fellow users.

👉 **[Join the K-Dense Community on Slack](https://join.slack.com/t/k-densecommunity/shared_invite/zt-3iajtyls1-EwmkwIZk0g_o74311Tkf5g)** 👈

We're excited to meet you! 🚀

## ⭐ Show Your Support

If you find this project helpful for your research or work, please consider giving it a star on GitHub! It helps others discover the tool and motivates continued development. Thank you! 🙏

![GitHub stars](https://img.shields.io/github/stars/K-Dense-AI/claude-scientific-writer?style=social)

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=K-Dense-AI/claude-scientific-writer&type=Date)](https://star-history.com/#K-Dense-AI/claude-scientific-writer&Date)
