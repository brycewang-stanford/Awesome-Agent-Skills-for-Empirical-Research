---
name: chatpaper-guide
description: "Use ChatPaper to summarize and search arXiv papers with LLM assistance"
metadata:
  openclaw:
    emoji: "📑"
    category: "literature"
    subcategory: "search"
    keywords: ["arxiv", "paper-summarization", "literature-search", "chatgpt", "research-acceleration"]
    source: "https://github.com/kaixindelele/ChatPaper"
---

# ChatPaper Guide

## Overview

ChatPaper is an open-source tool that leverages large language models to automatically summarize, search, and analyze academic papers from arXiv. It addresses a fundamental challenge in modern research: the overwhelming volume of new publications makes it nearly impossible for researchers to keep up with developments in their fields through manual reading alone.

The tool connects to the arXiv API to retrieve papers based on keyword queries, then uses LLM capabilities to generate structured summaries covering research motivation, methodology, key findings, and limitations. This enables researchers to rapidly triage large batches of papers and identify the most relevant ones for detailed study.

With over 19,000 GitHub stars, ChatPaper has become a widely adopted tool in the research community. It supports multiple LLM backends and offers both command-line and web-based interfaces, making it accessible to researchers with varying levels of technical expertise.

## Installation and Setup

Clone the repository and install dependencies:

```bash
git clone https://github.com/kaixindelele/ChatPaper.git
cd ChatPaper
pip install -r requirements.txt
```

Configure your LLM API access by setting environment variables:

```bash
# For OpenAI API
export OPENAI_API_KEY=$OPENAI_API_KEY

# Optional: use a custom API endpoint
export OPENAI_BASE_URL=$OPENAI_BASE_URL
```

Alternatively, edit the configuration directly in the settings file to specify your preferred model and API parameters. The tool supports OpenAI models as well as compatible alternatives.

Verify the installation by running a test query:

```bash
python chat_paper.py --query "transformer attention mechanism" --max_results 3
```

## Core Features

**Automated Paper Search and Summarization**: ChatPaper queries arXiv based on your research interests and generates concise, structured summaries for each paper:

```bash
# Search for recent papers on a topic
python chat_paper.py \
  --query "graph neural networks drug discovery" \
  --max_results 10 \
  --sort "Relevance" \
  --language "en"
```

Each summary is structured to highlight the core research question, proposed method, experimental results, and conclusions, saving significant reading time during literature reviews.

**Batch Processing**: Process multiple search queries or a list of arXiv paper IDs in a single run:

```bash
# Summarize specific papers by arXiv ID
python chat_paper.py \
  --pdf_path "2301.00234,2302.01567,2303.04589" \
  --language "en"
```

**Multi-Language Output**: Generate summaries in your preferred language regardless of the source paper language. This is particularly useful for researchers who think and write in a language different from the papers they read:

```bash
python chat_paper.py \
  --query "quantum computing optimization" \
  --language "zh" \
  --max_results 5
```

**Research Report Generation**: Beyond individual summaries, ChatPaper can compile comparative analysis reports across multiple papers on the same topic, identifying common themes, methodological differences, and research gaps.

## Academic Workflow Integration

ChatPaper integrates into research workflows at several critical stages:

**Daily Literature Monitoring**: Set up automated scripts to check for new papers in your research area each morning. Create a cron job or scheduled task that runs ChatPaper queries and delivers summaries to your inbox or a designated folder:

```bash
# Example daily monitoring script
python chat_paper.py \
  --query "large language model reasoning" \
  --max_results 20 \
  --sort "LastUpdatedDate" \
  --days 1 \
  --save_path ./daily_summaries/
```

**Systematic Review Support**: When conducting systematic literature reviews, use ChatPaper to generate initial screening summaries for a large pool of candidate papers. This accelerates the title-and-abstract screening phase by providing structured, consistent summaries that highlight methodological details often buried in abstracts.

**Research Group Discussions**: Generate summary documents for journal club or lab meeting preparation. Share the structured summaries with your group so everyone arrives with baseline understanding of the papers under discussion.

**Identifying Research Gaps**: By summarizing many papers in a subfield simultaneously, patterns emerge in what has been studied and what remains unexplored. ChatPaper summaries can be analyzed collectively to map the landscape of a research area.

## Advanced Usage and Tips

**Custom Prompts**: Modify the summarization prompts to focus on aspects most relevant to your research. For example, you might emphasize dataset details for data-centric work or focus on theoretical contributions for more mathematical fields.

**Combining with Reference Managers**: Export ChatPaper summaries alongside BibTeX entries for direct import into Zotero, Mendeley, or other reference management tools. This creates an annotated bibliography with minimal manual effort.

**Rate Limiting Considerations**: When processing large batches, be mindful of both arXiv API rate limits and your LLM provider quotas. Space requests appropriately and consider using local or self-hosted models for high-volume processing.

**Quality Verification**: LLM-generated summaries may occasionally contain inaccuracies. Always verify critical claims by checking the original paper, particularly for numerical results, statistical significance values, and methodological details that require precise interpretation.

## References

- ChatPaper repository: https://github.com/kaixindelele/ChatPaper
- arXiv API documentation: https://info.arxiv.org/help/api/
- Related tool ChatReviewer for automated paper review generation
