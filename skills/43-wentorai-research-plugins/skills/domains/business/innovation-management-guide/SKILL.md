---
name: innovation-management-guide
description: "Innovation metrics, R&D management research, and technology forecasting"
metadata:
  openclaw:
    emoji: "💡"
    category: "domains"
    subcategory: "business"
    keywords: ["innovation", "r-and-d", "technology-management", "bibliometrics", "diffusion", "strategy"]
    source: "wentor"
---

# Innovation Management Guide

A skill for conducting research on innovation management, technology strategy, and R&D performance. Covers innovation measurement, technology forecasting, diffusion modeling, patent-publication linkage, and bibliometric analysis of research portfolios.

## Innovation Measurement

### Key Innovation Metrics

| Metric | Definition | Data Source |
|--------|-----------|-------------|
| R&D intensity | R&D spending / Revenue | Annual reports, Compustat |
| Patent count | Granted patents per year | USPTO, EPO |
| Citation-weighted patents | Patents weighted by forward citations | PatentsView |
| New product revenue share | Revenue from products < 3 years old | Internal data |
| Time to market | Concept to commercial launch | Project records |
| Innovation efficiency | Revenue from new products / R&D spend | Combined internal data |

### Building an Innovation Scorecard

```python
import pandas as pd
import numpy as np

def compute_innovation_scorecard(firm_data: pd.DataFrame) -> pd.DataFrame:
    """
    Compute a multi-dimensional innovation scorecard for firms.
    firm_data columns: firm_id, rd_spend, revenue, patents_filed,
    patents_granted, citation_count, new_product_revenue, employees
    """
    scorecard = pd.DataFrame()
    scorecard["firm_id"] = firm_data["firm_id"]

    # Input metrics
    scorecard["rd_intensity"] = firm_data["rd_spend"] / firm_data["revenue"]
    scorecard["rd_per_employee"] = firm_data["rd_spend"] / firm_data["employees"]

    # Output metrics
    scorecard["patent_yield"] = (
        firm_data["patents_granted"] / (firm_data["rd_spend"] / 1e6)
    )
    scorecard["citation_impact"] = (
        firm_data["citation_count"] / firm_data["patents_granted"].clip(lower=1)
    )
    scorecard["new_product_share"] = (
        firm_data["new_product_revenue"] / firm_data["revenue"]
    )

    # Efficiency
    scorecard["innovation_efficiency"] = (
        firm_data["new_product_revenue"] / firm_data["rd_spend"]
    )

    # Normalize to percentile ranks within the sample
    for col in scorecard.columns[1:]:
        scorecard[f"{col}_rank"] = scorecard[col].rank(pct=True)

    # Composite score (equal weights)
    rank_cols = [c for c in scorecard.columns if c.endswith("_rank")]
    scorecard["composite_score"] = scorecard[rank_cols].mean(axis=1)

    return scorecard.sort_values("composite_score", ascending=False)
```

## Technology Diffusion Models

### Bass Diffusion Model

The Bass model is the foundational framework for forecasting technology adoption:

```python
from scipy.optimize import curve_fit

def bass_model(t: np.ndarray, p: float, q: float, m: float) -> np.ndarray:
    """
    Bass diffusion model for cumulative adoption.
    t: time periods (0, 1, 2, ...)
    p: coefficient of innovation (external influence)
    q: coefficient of imitation (internal influence)
    m: market potential (total eventual adopters)
    Returns cumulative adoption at each time period.
    """
    return m * (1 - np.exp(-(p + q) * t)) / (1 + (q / p) * np.exp(-(p + q) * t))

def bass_incremental(t: np.ndarray, p: float, q: float, m: float) -> np.ndarray:
    """Bass model incremental (new adopters per period)."""
    F = bass_model(t, p, q, m) / m
    f = (p + q * F) * (1 - F)
    return m * f

def fit_bass_model(adoption_data: np.ndarray) -> dict:
    """
    Fit Bass diffusion parameters to observed adoption data.
    adoption_data: cumulative adoption counts per period.
    """
    t = np.arange(len(adoption_data))
    try:
        popt, pcov = curve_fit(
            bass_model, t, adoption_data,
            p0=[0.01, 0.3, adoption_data[-1] * 2],
            bounds=([0, 0, adoption_data[-1]], [1, 2, adoption_data[-1] * 10]),
            maxfev=10000,
        )
        return {
            "p_innovation": round(popt[0], 6),
            "q_imitation": round(popt[1], 6),
            "m_potential": round(popt[2], 0),
            "peak_period": round(np.log(popt[1] / popt[0]) / (popt[0] + popt[1]), 1),
            "q_p_ratio": round(popt[1] / popt[0], 2),
        }
    except RuntimeError:
        return {"error": "convergence_failed"}
```

### Typical Bass Parameters by Technology Category

| Technology | p (innovation) | q (imitation) | q/p ratio |
|-----------|---------------|---------------|-----------|
| Consumer electronics | 0.01-0.03 | 0.3-0.5 | 10-50 |
| Enterprise software | 0.005-0.02 | 0.2-0.4 | 10-80 |
| Medical devices | 0.001-0.01 | 0.1-0.3 | 10-300 |
| Social media platforms | 0.03-0.10 | 0.5-0.8 | 5-25 |

## Bibliometric Analysis of R&D Portfolios

### Publication Portfolio Analysis

```python
def analyze_research_portfolio(publications: pd.DataFrame) -> dict:
    """
    Bibliometric analysis of an organization's research portfolio.
    publications columns: doi, title, year, journal, citations,
    fields (list), authors (list), affiliations (list)
    """
    # Publication trend
    annual_pubs = publications.groupby("year").size()

    # Citation impact
    citation_stats = {
        "total_citations": publications.citations.sum(),
        "mean_citations": publications.citations.mean(),
        "median_citations": publications.citations.median(),
        "h_index": compute_h_index(publications.citations.values),
    }

    # Research field distribution
    all_fields = []
    for fields in publications.fields:
        all_fields.extend(fields)
    field_dist = pd.Series(all_fields).value_counts().head(20)

    # Collaboration patterns
    collab_rate = publications.affiliations.apply(
        lambda x: len(set(x)) > 1
    ).mean()

    return {
        "total_publications": len(publications),
        "annual_trend": annual_pubs.to_dict(),
        "citation_impact": citation_stats,
        "top_fields": field_dist.to_dict(),
        "collaboration_rate": round(collab_rate, 3),
    }

def compute_h_index(citations: np.ndarray) -> int:
    """Compute h-index from an array of citation counts."""
    sorted_cites = np.sort(citations)[::-1]
    h = 0
    for i, c in enumerate(sorted_cites):
        if c >= i + 1:
            h = i + 1
        else:
            break
    return h
```

## Technology Forecasting Methods

### S-Curve Analysis

Technology performance typically follows an S-curve pattern:

1. **Emergence phase**: Slow initial growth, high uncertainty
2. **Growth phase**: Rapid performance improvement, competitive investment
3. **Maturity phase**: Diminishing returns, incremental improvement
4. **Saturation/decline**: Physical or market limits reached

### Forecasting Approaches

| Method | Time Horizon | Data Requirements | Best For |
|--------|-------------|-------------------|----------|
| Delphi method | 5-30 years | Expert panels | Emerging technologies |
| Trend extrapolation | 2-10 years | Historical time series | Incremental innovation |
| Scenario planning | 5-20 years | Qualitative analysis | Strategic uncertainty |
| Patent analysis | 3-10 years | Patent databases | Technology landscape |
| Bibliometric mapping | 2-5 years | Publication data | Research front detection |

## Open Innovation Research

### Measuring Open Innovation

```python
def open_innovation_metrics(firm_patents: pd.DataFrame,
                             firm_publications: pd.DataFrame,
                             alliances: pd.DataFrame) -> dict:
    """
    Compute open innovation indicators for a firm.
    """
    # Inbound openness: external knowledge sourcing
    external_collab_pubs = firm_publications[
        firm_publications.external_coauthors > 0
    ]
    inbound_ratio = len(external_collab_pubs) / max(len(firm_publications), 1)

    # Outbound openness: technology licensing, spin-offs
    licensed_patents = firm_patents[firm_patents.licensed == True]
    outbound_ratio = len(licensed_patents) / max(len(firm_patents), 1)

    # Network diversity (alliance partner variety)
    partner_industries = alliances.partner_industry.nunique()

    return {
        "inbound_openness": round(inbound_ratio, 3),
        "outbound_openness": round(outbound_ratio, 3),
        "alliance_count": len(alliances),
        "partner_diversity": partner_industries,
    }
```

## Key Journals and Conferences

- *Research Policy*
- *Technovation*
- *Journal of Product Innovation Management*
- *R&D Management*
- *Strategic Management Journal*
- *Academy of Management Conference (TIM division)*

## Tools and Resources

- **Compustat / WRDS**: Financial data including R&D expenditure
- **Web of Science / Scopus**: Bibliometric data for publication analysis
- **PatentsView**: Patent data with inventor and assignee disambiguation
- **VOSviewer**: Bibliometric network visualization
- **Gephi**: Network analysis and visualization
- **Bass forecasting tools**: R diffusion package, Python implementations
