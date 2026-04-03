---
name: finsight-research-guide
description: "Deep financial research with the FinSight multi-agent system"
metadata:
  openclaw:
    emoji: "💰"
    category: "domains"
    subcategory: "finance"
    keywords: ["FinSight", "financial analysis", "deep research", "market analysis", "financial reports", "multi-agent"]
    source: "https://github.com/RUC-NLPIR/FinSight"
---

# FinSight Research Guide

## Overview

FinSight is a deep research agent designed specifically for financial analysis. Developed by RUC-NLPIR, it combines multi-source data retrieval, financial reasoning, and report generation to produce publication-ready financial research. It handles market analysis, company fundamentals, sector comparisons, and macroeconomic assessment through specialized agents.

## Installation

```bash
git clone https://github.com/RUC-NLPIR/FinSight.git
cd FinSight && pip install -e .
```

## Core Capabilities

### Research Query to Report

```python
from finsight import FinSightAgent

agent = FinSightAgent(llm_provider="anthropic")

# Generate comprehensive financial analysis
report = agent.research(
    "Analyze the competitive landscape of the global EV battery "
    "market. Compare CATL, LG Energy, and Panasonic on market "
    "share, technology, margins, and growth outlook."
)

print(report.summary)
report.save("ev_battery_analysis.pdf")
```

### Agent Architecture

| Agent | Role |
|-------|------|
| **Retrieval Agent** | Fetches data from SEC filings, financial APIs, news |
| **Data Agent** | Processes financial statements, ratios, time series |
| **Analysis Agent** | Performs fundamental, technical, and comparative analysis |
| **Reasoning Agent** | Synthesizes findings, identifies trends and risks |
| **Report Agent** | Generates structured research reports with citations |

### Financial Data Sources

```python
# FinSight integrates with multiple data sources
config = {
    "sec_edgar": True,        # SEC filings (free)
    "fred": True,             # Federal Reserve economic data
    "yahoo_finance": True,    # Market data (free)
    "news_api": True,         # Financial news
    "world_bank": True,       # Macro indicators
}
```

### Analysis Types

```python
# Company fundamental analysis
report = agent.research(
    "Provide a fundamental analysis of NVIDIA including "
    "revenue trends, margin analysis, valuation multiples, "
    "and competitive moat assessment."
)

# Sector analysis
report = agent.research(
    "Compare the top 5 cloud computing companies by revenue "
    "growth, operating margins, and R&D investment intensity."
)

# Macro analysis
report = agent.research(
    "Analyze the impact of rising interest rates on US "
    "commercial real estate valuations since 2022."
)
```

## Report Structure

Generated reports typically include:

1. **Executive Summary** — Key findings in 3-5 bullets
2. **Market Overview** — Industry size, growth, trends
3. **Company Analysis** — Financials, competitive position
4. **Risk Assessment** — Key risks and mitigation
5. **Outlook** — Forward-looking analysis with scenarios
6. **Sources** — Cited data sources and references

## Use Cases

1. **Investment research**: Company and sector deep dives
2. **Due diligence**: Comprehensive target company analysis
3. **Academic research**: Financial economics research support
4. **Market intelligence**: Competitive landscape mapping

## References

- [FinSight GitHub](https://github.com/RUC-NLPIR/FinSight)
- [RUC-NLPIR Lab](http://playbigdata.ruc.edu.cn/)
