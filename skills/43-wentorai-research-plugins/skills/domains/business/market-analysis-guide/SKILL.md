---
name: market-analysis-guide
description: "Structured frameworks for market sizing, competitive analysis, and strategic ..."
metadata:
  openclaw:
    emoji: "📈"
    category: "domains"
    subcategory: "business"
    keywords: ["market analysis", "strategic management", "operations management", "competitive analysis", "market sizing"]
    source: "wentor"
---

# Market Analysis Guide

A comprehensive skill for conducting rigorous market analysis in academic and applied research contexts. This guide covers quantitative market sizing, competitive landscape mapping, and strategic positioning frameworks grounded in peer-reviewed methodologies.

## Market Sizing Methodologies

Market sizing is the foundation of any credible market analysis. There are two primary approaches, and robust research typically employs both for triangulation.

**Top-Down Approach (TAM/SAM/SOM)**

Start with the total addressable market and narrow systematically:

```
TAM (Total Addressable Market)
  -> SAM (Serviceable Available Market)
    -> SOM (Serviceable Obtainable Market)

Example calculation:
  TAM = Global higher-education EdTech spend = $340B (2025, HolonIQ)
  SAM = AI-powered research tools segment  = $12B
  SOM = Realistic capture in Year 3        = $120M (1% of SAM)
```

**Bottom-Up Approach**

Build estimates from unit economics:

```python
# Bottom-up market sizing
users_in_target_segment = 8_000_000  # global PhD + postdoc researchers
adoption_rate = 0.05                  # 5% in first 3 years
avg_revenue_per_user = 180            # USD/year
bottom_up_estimate = users_in_target_segment * adoption_rate * avg_revenue_per_user
# Result: $72,000,000
```

Always cite the data sources for each assumption. Use government statistics (e.g., NSF, Eurostat), industry reports (Gartner, McKinsey), and published academic datasets.

## Competitive Analysis Frameworks

### Porter's Five Forces

Apply Porter's framework systematically to map industry structure:

| Force | Key Questions | Data Sources |
|-------|--------------|--------------|
| Rivalry | How many direct competitors? Market concentration (HHI)? | Crunchbase, SEC filings |
| New Entrants | Capital requirements? Regulatory barriers? | Patent databases, regulatory filings |
| Substitutes | What alternatives exist? Switching costs? | User surveys, app store data |
| Buyer Power | Customer concentration? Price sensitivity? | Industry reports, interviews |
| Supplier Power | Input scarcity? Vendor lock-in? | Supply chain databases |

### SWOT and TOWS Matrix

Go beyond basic SWOT by constructing a TOWS matrix that generates actionable strategies:

```
              Strengths (S)           Weaknesses (W)
Opportunities  SO strategies           WO strategies
  (O)          (use S to exploit O)    (overcome W via O)
Threats        ST strategies           WT strategies
  (T)          (use S to counter T)    (minimize W, avoid T)
```

## Data Collection and Validation

Primary data collection methods for market analysis research:

1. **Structured interviews** with industry experts (N >= 12 for saturation)
2. **Survey instruments** validated with Cronbach's alpha >= 0.70
3. **Conjoint analysis** for preference and willingness-to-pay estimation
4. **Web scraping** of pricing pages, job postings, and product changelogs

Secondary data sources to cross-validate:

- Statista, IBISWorld, Grand View Research for market reports
- USPTO/EPO patent filings for technology trajectory analysis
- PitchBook/Crunchbase for funding and M&A activity

## Reporting and Visualization

Present findings using clear, reproducible visualizations:

```python
import matplotlib.pyplot as plt
import numpy as np

segments = ['Segment A', 'Segment B', 'Segment C', 'Segment D']
sizes = [45, 28, 18, 9]
colors = ['#3B82F6', '#EF4444', '#10B981', '#F59E0B']

fig, ax = plt.subplots(figsize=(8, 6))
ax.barh(segments, sizes, color=colors)
ax.set_xlabel('Market Share (%)')
ax.set_title('Competitive Landscape by Segment')
plt.tight_layout()
plt.savefig('market_share.png', dpi=300)
```

Always include confidence intervals or sensitivity ranges for quantitative estimates. A well-structured market analysis report should contain an executive summary, methodology section, findings with visualizations, and a limitations discussion.
