<!--
  ╔══════════════════════════════════════════════════════════════╗
  ║  本文件为开源 Skill 原始文档，收录仅供学习与研究参考        ║
  ║  CoPaper.AI 收集整理 | https://copaper.ai                  ║
  ╚══════════════════════════════════════════════════════════════╝

  来源仓库: https://github.com/kthorn/research-superpower
  项目名称: research-superpower
  开源协议: MIT License
  收录日期: 2026-04-02

  声明: 本文件版权归原作者所有。此处收录旨在为社会科学实证研究者
  提供 AI Agent Skills 的集中参考。如有侵权，请联系删除。
-->

# Research Superpowers: Literature Search & Review

Give Claude Code superpowers for **systematic literature searching and review**. Search PubMed, screen papers, extract data, traverse citations, and synthesize findings.

**Focus:** Finding and reviewing scientific papers, not lab work or data analysis.

## What You Get

A complete toolkit for **systematic literature reviews**:

- **Literature Search** - PubMed and Semantic Scholar integration
- **Smart Paper Screening** - Abstract scoring + deep dive for relevant data extraction
- **Screening Rubrics** - Build and test custom relevance criteria collaboratively
- **ChEMBL Integration** - Check if medicinal chemistry papers have curated SAR data (~99k papers)
- **Open Access Finding** - Unpaywall API to find free versions of paywalled papers
- **Citation Traversal** - Intelligent backward and forward citation following
- **Large-Scale Screening** - Parallel subagent processing for 50+ papers
- **Research Orchestration** - End-to-end workflow from query to synthesized findings

## Quick Start

### Option 1: Install from Marketplace (Recommended)

```bash
# In Claude Code, add the marketplace
/plugin marketplace add https://github.com/kthorn/research-superpower

# Install the plugin
/plugin install research-superpowers@research-superpowers-marketplace

# Start asking literature search questions!
# Example: "Find papers on BTK inhibitor selectivity with IC50 data"
# Example: "Review literature on CRISPR gene editing in cardiomyocytes"
# Example: "What's known about MmpL3 inhibitors for tuberculosis?"
```

### Option 2: Manual Installation

```bash
# Clone to your config directory
git clone https://github.com/kthorn/research-superpower ~/.config/research-superpowers

# Start Claude Code and tell it your literature search question
```

**Note:** These skills help you **find and review papers**. For analyzing experimental data or designing experiments, you'll need other tools.

## How It Works (Literature Review Workflow)

1. **Parse your literature question** - Extract keywords, data types, constraints
2. **Build screening rubric** - Define what makes papers relevant (optional, for large searches)
3. **Search PubMed** - Find candidate papers
4. **Screen abstracts** - Score papers for relevance (0-10)
5. **Deep dive on promising papers** - Fetch full text, extract specific data and methods
6. **Traverse citations** - Follow relevant references and citing papers (via Semantic Scholar)
7. **Synthesize findings** - Organize results in SUMMARY.md with structured extraction
8. **Track everything** - Maintain research session folder with findings, PDFs, and deduplication

## Project Structure

```
research-superpowers/
├── skills/
│   ├── getting-started/        # Introduction and workflow overview
│   └── research/
│       ├── answering-research-questions/    # Main orchestration
│       ├── searching-literature/            # PubMed search
│       ├── evaluating-paper-relevance/      # Abstract screening + deep dive
│       ├── checking-chembl/                 # ChEMBL SAR data lookup
│       ├── traversing-citations/            # Citation network traversal
│       └── finding-open-access-papers/      # Unpaywall integration
├── scripts/
│   └── find-skills              # Search for relevant skills
└── hooks/
    └── session-start.sh         # Auto-load at Claude Code startup
```

## Research Session Output

Each research query creates a folder:

```
research-sessions/2025-10-11-btk-inhibitor-selectivity/
├── SUMMARY.md                   # Main findings organized by relevance
├── papers-reviewed.json         # Deduplication tracking
├── papers/
│   ├── 10.1234_example.pdf
│   └── ...
└── citations/
    └── citation-graph.json      # Citation relationships
```

## Skills Library

### Literature Search & Review Skills

- **answering-research-questions** - Main orchestration workflow (search → screen → extract → synthesize)
- **building-screening-rubrics** - Collaborative rubric design with test-driven refinement
- **searching-literature** - PubMed API integration with query optimization
- **evaluating-paper-relevance** - Two-stage relevance filtering (abstract + deep dive)
- **subagent-driven-review** - Parallel screening for large searches (50+ papers)
- **checking-chembl** - ChEMBL database lookup for medicinal chemistry papers
- **traversing-citations** - Smart citation following via Semantic Scholar
- **finding-open-access-papers** - Unpaywall API for finding free full text
- **cleaning-up-research-sessions** - Safe cleanup of intermediate files after research complete

## Philosophy

These skills focus on **systematic literature searching and review**:

- **Precision over breadth** - Find papers with specific data you need, not just topically related
- **Test-driven screening** - Build and validate relevance rubrics before bulk processing
- **Smart traversal** - Only follow relevant citations to avoid exponential explosion
- **Track everything** - Deduplicate papers, cache abstracts for re-screening, maintain provenance
- **Check in regularly** - Report progress every 10 papers, checkpoint every 50
- **Reproducible** - Save rubrics, queries, and methodology with each research session

**What this is NOT:** These skills don't analyze experimental data, design experiments, or perform statistical analysis. They help you **find and review published literature**.

## Requirements

- Claude Code CLI
- Internet connection (for PubMed and Semantic Scholar APIs)
- Optional: API keys for higher rate limits (free tier works for most use cases)

## Reducing Command Prompts

When Claude runs API calls (curl commands), you may see approval prompts. To eliminate these for research sessions:

### Option 1: Pre-configure permissions (Recommended)

Copy the template permissions file to your research project:

```bash
# In your research project directory (e.g., research-sessions/YYYY-MM-DD-query/)
mkdir -p .claude
cp ~/.config/research-superpowers/.claude/settings.local.json.template .claude/settings.local.json
```

This pre-approves:
- All PubMed/NCBI API calls
- All Semantic Scholar API calls
- All Unpaywall API calls
- DOI resolution calls
- Basic file operations

### Option 2: Per-command approval

When prompted, choose option 2: "Yes, and don't ask again for similar commands in this directory"

**Note:** If this doesn't work (keeps prompting), use Option 1 instead. Claude Code may add specific commands instead of patterns.

## API Information

**PubMed/E-utilities:**
- Free, no API key required
- Rate limit: 3 requests/second without key, 10 req/sec with key

**Semantic Scholar:**
- Free tier: 100 requests per 5 minutes
- API key (free): 1000 requests per 5 minutes
- [Get API key](https://www.semanticscholar.org/product/api#api-key)

**Unpaywall:**
- Free: 100,000 requests per day
- No API key required (just provide email)
- [Learn more](https://unpaywall.org/products/api)

**ChEMBL:**
- Free, no API key required
- ~99,000 curated medicinal chemistry papers
- Structured SAR data (IC50, MIC, structures, assays)
- [Learn more](https://www.ebi.ac.uk/chembl/)

## Contributing

This is an experimental project! Contributions welcome:
- Try it with real research questions
- Report issues and edge cases
- Suggest new skills
- Improve existing workflows

## License

MIT License - see LICENSE file

## Acknowledgments

Inspired by [Superpowers](https://github.com/obra/superpowers) by Jesse Vincent
