---
name: conference-proceedings-guide
description: "Find, access, and cite conference papers and proceedings effectively"
metadata:
  openclaw:
    emoji: "💬"
    category: "literature"
    subcategory: "discovery"
    keywords: ["conference papers", "proceedings", "ACM", "IEEE", "academic conferences", "workshop papers"]
    source: "wentor-research-plugins"
---

# Conference Proceedings Guide

A skill for finding, accessing, and citing conference papers and proceedings. In many fields -- especially computer science, engineering, and HCI -- conferences are the primary venue for publishing cutting-edge research. This guide covers major proceedings databases, search strategies, and citation practices.

## Major Proceedings Databases

### Database Overview

| Database | Coverage | Access |
|----------|----------|--------|
| ACM Digital Library | ACM conferences (CHI, SIGCOMM, KDD, etc.) | Institutional or ACM membership |
| IEEE Xplore | IEEE conferences (CVPR, ICRA, INFOCOM, etc.) | Institutional or IEEE membership |
| DBLP | CS bibliography, links to proceedings | Free metadata |
| Springer LNCS | Lecture Notes in Computer Science series | Institutional |
| AAAI Digital Library | AAAI, IJCAI proceedings | Free for AAAI papers |
| NeurIPS / ICML / ICLR | ML conference proceedings | OpenReview (free) |
| arXiv | Preprints including conference submissions | Free |

### Finding Conference Papers

```
Strategy 1 - Search by conference name:
  Google Scholar: source:"NeurIPS" "transformer" "attention"
  DBLP: Browse conference page -> search within proceedings

Strategy 2 - Search by topic across all venues:
  OpenAlex: Filter by type "proceedings-article"
  Google Scholar: Use keywords, then check venue names in results

Strategy 3 - Track specific conferences:
  Bookmark the conference proceedings page (e.g., openreview.net)
  Subscribe to DBLP RSS feeds for specific conference series
  Follow conference Twitter/social media accounts for announcements
```

## Navigating Conference Tiers

### Understanding Conference Rankings

```python
def assess_conference_quality(conference_name: str) -> dict:
    """
    Framework for evaluating conference quality and reputation.

    Args:
        conference_name: Name or acronym of the conference
    """
    indicators = {
        "acceptance_rate": {
            "top_tier": "< 25%",
            "mid_tier": "25-40%",
            "lower_tier": "> 40%",
            "note": "Check conference website for historical rates"
        },
        "ranking_sources": [
            "CORE Conference Ranking (core.edu.au)",
            "CSRankings.org (CS-specific, based on publication counts)",
            "Google Scholar Metrics (h5-index for venues)",
            "CCF Ranking (Chinese Computer Federation, A/B/C tiers)"
        ],
        "quality_signals": [
            "Program committee reputation and size",
            "Keynote speaker caliber",
            "Longevity and consistency of the conference series",
            "Whether proceedings are indexed in Scopus/WoS",
            "Industry participation and sponsorship"
        ]
    }
    return indicators
```

### Major CS Conference Tiers (Illustrative)

```
Tier A* (Top):  ICML, NeurIPS, CVPR, ACL, SIGCOMM, OSDI, CHI, KDD
Tier A:         AAAI, ECCV, EMNLP, ICSE, WWW, CIKM, ICDM
Tier B:         COLING, WACV, ICSME, PAKDD, AISTATS
```

Tiers vary by subfield. Always check the ranking relevant to your specific area.

## Accessing Conference Papers

### Free Access Strategies

```
1. Author homepages: Many researchers post preprints/camera-ready PDFs
2. arXiv: Conference-accepted papers are often on arXiv
3. OpenReview: NeurIPS, ICLR, and others host papers with reviews
4. Institutional repository: Check the authors' university repository
5. Conference website: Some conferences offer free proceedings
6. OpenAlex: Aggregates metadata and OA links from multiple sources
```

### Workshop Papers vs. Main Conference

Workshop papers are shorter (4-8 pages), less rigorously reviewed, and represent more preliminary work. They are still citable but carry less weight. When citing, always distinguish:

```
# Main conference paper:
Author et al. "Title." In Proceedings of NeurIPS 2024.

# Workshop paper:
Author et al. "Title." In Workshop on X at NeurIPS 2024.
```

## Citing Conference Proceedings

### BibTeX Format

```bibtex
@inproceedings{vaswani2017attention,
  title     = {Attention Is All You Need},
  author    = {Vaswani, Ashish and Shazeer, Noam and Parmar, Niki
               and Uszkoreit, Jakob and Jones, Llion and Gomez,
               Aidan N and Kaiser, Lukasz and Polosukhin, Illia},
  booktitle = {Advances in Neural Information Processing Systems},
  volume    = {30},
  year      = {2017}
}
```

### Common Mistakes in Conference Citations

- Using `@article` instead of `@inproceedings`
- Citing the arXiv preprint instead of the published proceedings version
- Missing the conference name or year
- Confusing the workshop name with the main conference name

Always use the official proceedings citation provided by the conference or digital library.
