---
name: ai-scientist-v2-guide
description: "Automated scientific discovery via agentic tree search by Sakana AI"
metadata:
  openclaw:
    emoji: "🧪"
    category: "research"
    subcategory: "automation"
    keywords: ["scientific-discovery", "automation", "tree-search", "paper-generation", "experiment-design", "sakana-ai"]
    source: "https://github.com/SakanaAI/AI-Scientist-v2"
---

# AI Scientist v2 Guide

## Overview

AI-Scientist-v2 is an open-source system developed by Sakana AI with over 2,000 GitHub stars that automates the full scientific research pipeline -- from idea generation through experimentation to paper writing. Building on the original AI Scientist, version 2 introduces an agentic tree search approach that systematically explores the space of research ideas, designs and runs experiments, analyzes results, and produces workshop-level scientific papers with minimal human intervention.

The key innovation in v2 is the tree search mechanism. Rather than pursuing a single research direction linearly, the system maintains a tree of possible research trajectories. At each node, the agent can branch into multiple experimental variations, evaluate the results, and prune unpromising directions while doubling down on successful ones. This mirrors how experienced researchers navigate the research landscape -- exploring broadly at first, then focusing resources on the most promising leads.

AI-Scientist-v2 has demonstrated the ability to generate novel, valid research papers in machine learning subfields including diffusion models, language model training, and optimization. While the generated papers are currently at workshop acceptance level, the system represents a significant step toward autonomous scientific discovery and is an invaluable tool for researchers looking to automate the more mechanical aspects of their research workflow.

## Installation and Setup

```bash
# Clone the repository
git clone https://github.com/SakanaAI/AI-Scientist-v2.git
cd AI-Scientist-v2

# Create a conda environment
conda create -n ai-scientist python=3.11
conda activate ai-scientist

# Install dependencies
pip install -r requirements.txt
```

### Prerequisites

AI-Scientist-v2 requires several components:

```bash
# LLM API access (required for ideation, analysis, and writing)
export OPENAI_API_KEY=$OPENAI_API_KEY
# Or Anthropic
export ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY

# GPU access for running ML experiments
# Recommended: at least one NVIDIA GPU with 24GB+ VRAM

# LaTeX installation for paper compilation
# Ubuntu/Debian
sudo apt-get install texlive-full

# macOS
brew install --cask mactex
```

### Configuration

Set up your research configuration:

```python
# config.yaml
llm:
  provider: "openai"
  model: "gpt-4o"
  temperature: 0.7

search:
  max_depth: 5          # Maximum tree depth
  branching_factor: 3   # Number of branches per node
  pruning_threshold: 0.3  # Prune branches below this score

experiment:
  gpu_ids: [0, 1]       # Available GPUs
  timeout_hours: 2      # Max time per experiment
  num_seeds: 3          # Random seeds per experiment

paper:
  template: "icml"      # Paper template (icml, neurips, iclr)
  max_pages: 8          # Maximum paper length
```

## Core Research Pipeline

### Phase 1: Idea Generation

The system generates research ideas by analyzing existing literature and identifying gaps or extensions:

```python
from ai_scientist import IdeaGenerator

generator = IdeaGenerator(
    research_area="efficient_transformers",
    seed_papers=[
        "path/to/related_paper_1.pdf",
        "path/to/related_paper_2.pdf",
    ],
    num_ideas=10,
)

ideas = generator.generate()
for idea in ideas:
    print(f"Title: {idea.title}")
    print(f"Hypothesis: {idea.hypothesis}")
    print(f"Novelty score: {idea.novelty_score}")
    print(f"Feasibility score: {idea.feasibility_score}")
```

### Phase 2: Agentic Tree Search

The tree search mechanism explores the research space systematically:

```python
from ai_scientist import TreeSearchResearcher

researcher = TreeSearchResearcher(
    idea=ideas[0],  # Start with the top-ranked idea
    base_code="templates/efficient_transformer/",
    config="config.yaml",
)

# Run the tree search
result = researcher.run()

# The search tree tracks all explorations
print(f"Tree depth reached: {result.max_depth}")
print(f"Total experiments run: {result.total_experiments}")
print(f"Best result: {result.best_node.metrics}")
```

The tree search works as follows:

1. **Root node**: The initial research idea and baseline implementation
2. **Expansion**: At each node, the agent proposes 2-4 modifications (hyperparameter changes, architectural tweaks, new training strategies)
3. **Evaluation**: Each modification is implemented and evaluated experimentally
4. **Selection**: Promising branches are selected for further exploration using UCB (Upper Confidence Bound) or similar strategies
5. **Pruning**: Branches that underperform the baseline or show diminishing returns are pruned

### Phase 3: Experiment Execution

Experiments are executed in isolated environments with proper controls:

```python
# Each experiment node contains:
class ExperimentNode:
    hypothesis: str          # What we're testing
    code_changes: list       # Specific code modifications
    config_changes: dict     # Hyperparameter changes
    results: dict            # Experimental results
    analysis: str            # LLM-generated analysis
    children: list           # Branch experiments
```

The system automatically handles experiment boilerplate including random seed management, metric logging, checkpoint saving, and result visualization. Each experiment is run with multiple seeds to ensure statistical significance.

### Phase 4: Paper Generation

After the tree search completes, the system generates a scientific paper:

```python
from ai_scientist import PaperWriter

writer = PaperWriter(
    research_result=result,
    template="neurips",
    sections=[
        "introduction",
        "related_work",
        "method",
        "experiments",
        "analysis",
        "conclusion",
    ],
)

# Generate the paper
paper = writer.write()

# Compile to PDF
paper.compile_latex("output/paper.pdf")

# The paper includes:
# - Abstract summarizing key findings
# - Introduction with motivation and contributions
# - Related work section with citations
# - Method description with equations
# - Experiment section with tables and figures
# - Analysis of results with ablation studies
# - Conclusion with future work directions
```

## Research Templates

AI-Scientist-v2 includes several research templates that define the experimental domain:

### NanoGPT Template
Train and evaluate small language models with various architectural modifications:

```bash
python run_scientist.py \
  --template nanoGPT \
  --idea "Investigate the effect of rotary position embeddings on small-scale language model training" \
  --max_experiments 20
```

### Diffusion Model Template
Experiment with diffusion model architectures and training strategies:

```bash
python run_scientist.py \
  --template diffusion \
  --idea "Compare noise schedules for conditional image generation"
```

### Creating Custom Templates

Define your own research template for your specific domain:

```python
# templates/my_domain/template.py
class MyDomainTemplate:
    name = "my_research_domain"
    base_metrics = ["accuracy", "f1_score", "inference_time"]

    def setup_baseline(self):
        """Set up the baseline experiment."""
        pass

    def evaluate(self, model, data):
        """Evaluate a model configuration."""
        pass

    def get_modification_space(self):
        """Define the space of possible modifications."""
        return {
            "architecture": ["transformer", "lstm", "mamba"],
            "learning_rate": [1e-4, 3e-4, 1e-3],
            "batch_size": [32, 64, 128],
        }
```

## Automated Paper Review

AI-Scientist-v2 includes an automated reviewer that evaluates generated papers using criteria from top ML venues:

```python
from ai_scientist import PaperReviewer

reviewer = PaperReviewer(
    venue="neurips",
    review_criteria=[
        "novelty",
        "significance",
        "clarity",
        "correctness",
        "reproducibility",
    ],
)

review = reviewer.review("output/paper.pdf")
print(f"Overall score: {review.overall_score}/10")
print(f"Strengths: {review.strengths}")
print(f"Weaknesses: {review.weaknesses}")
print(f"Questions: {review.questions}")
```

## Ethical Considerations and Limitations

When using AI-Scientist-v2, keep these considerations in mind:

- **Human oversight**: Always review generated papers for correctness before submission. The system can produce plausible-sounding but incorrect analyses.
- **Attribution**: If using AI-Scientist-v2 outputs in publications, disclose the use of automated research tools per venue guidelines.
- **Scope**: The system works best for incremental research within well-defined experimental frameworks. Breakthrough conceptual contributions still require human creativity.
- **Compute cost**: Tree search with multiple seeds per experiment can require substantial GPU time. Set appropriate budgets and timeouts.
- **Reproducibility**: All experiments are logged with seeds, configurations, and code versions for full reproducibility.

## References

- Repository: https://github.com/SakanaAI/AI-Scientist-v2
- Original AI Scientist paper: https://arxiv.org/abs/2408.06292
- Sakana AI: https://sakana.ai/
- AI Scientist v1: https://github.com/SakanaAI/AI-Scientist
