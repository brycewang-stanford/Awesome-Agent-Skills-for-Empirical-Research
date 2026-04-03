---
name: paper-recommendation-guide
description: "Systematic paper recommendation and discovery using multiple methods"
metadata:
  openclaw:
    emoji: "🎯"
    category: "literature"
    subcategory: "discovery"
    keywords: ["paper recommendation", "literature discovery", "related papers", "reading list", "citation-based", "algorithmic discovery"]
    source: "wentor-research-plugins"
---

# Paper Recommendation Guide

## Overview

Finding the right papers to read is a research skill in itself. Beyond keyword searches, modern researchers have access to a rich ecosystem of recommendation tools that use citation networks, semantic similarity, co-authorship patterns, and collaborative filtering to surface relevant papers you might otherwise miss.

This skill provides a systematic approach to paper discovery that goes beyond passive reading. It covers algorithmic recommendation services, citation-based discovery techniques, social and community-driven methods, and strategies for building and maintaining a well-curated reading pipeline. The goal is to minimize the chance that you miss an important paper while avoiding information overload.

Whether you are entering a new field and need foundational papers, tracking the frontier of a mature research area, or looking for interdisciplinary connections, this guide provides concrete methods for each scenario.

## Algorithmic Recommendation Services

### OpenAlex Related Works

OpenAlex provides concept-based and citation-based discovery for 250M+ works across all disciplines:

```bash
# Find works related to a specific paper via its concepts and citations
curl "https://api.openalex.org/works?filter=cites:W2741809807&sort=cited_by_count:desc&per_page=10"
```

Use OpenAlex's concept graph to find related work by browsing papers tagged with the same research concepts, or trace citation networks to find derivative and foundational papers.

### Connected Papers

Connected Papers (connectedpapers.com) builds a visual graph of papers related to a seed paper. It uses co-citation and bibliographic coupling analysis rather than direct citation links, which means it can surface related work even when two papers do not cite each other directly. Use this when:

- You have one key paper and want to map the surrounding literature
- You want to identify distinct clusters of related research
- You need to find the "origin paper" for an idea by tracing the graph backward

### Google Scholar Recommendations

Google Scholar's "Related articles" feature and the personalized recommendation emails (if you maintain a Google Scholar profile) use a combination of citation analysis and content similarity. To maximize their usefulness:

- Maintain an up-to-date Google Scholar profile with your publications
- Use the "Library" feature to save papers—this trains the recommendation algorithm
- Set up Google Scholar Alerts for key queries and author names
- Check the "Related articles" link on every important paper you read

### Research Rabbit

Research Rabbit (researchrabbitapp.com) lets you build collections of papers and then visualizes networks of related work, similar work, and suggested papers. It integrates with Zotero for importing existing libraries. Key features:

- "Similar Work" tab: finds papers with semantic similarity
- "All References" and "All Citations": explores the citation tree
- "These Authors" and "Suggested Authors": discovers researchers working on related topics
- Shareable collections for collaborative literature discovery

## Citation-Based Discovery Methods

When algorithmic tools are insufficient, manual citation-based techniques remain powerful:

### Forward Citation Chaining
Start with a foundational paper. Find all papers that cite it (using Google Scholar, OpenAlex, or Web of Science). Screen these citing papers by title and abstract to find relevant descendants. Repeat for the most important descendants.

### Backward Citation Mining
Read the reference list of a key paper. Identify and retrieve the most important cited works. This traces the intellectual lineage of ideas and helps you find the seminal papers in a subfield.

### Co-Citation Analysis
Two papers that are frequently cited together in other papers are likely related, even if they do not cite each other. Tools like VOSviewer and CiteSpace can visualize co-citation clusters from a set of papers, revealing the intellectual structure of a field.

### Bibliographic Coupling
Two papers that share many references are likely addressing related questions. This is the inverse of co-citation and is more useful for discovering recent papers that have not yet accumulated citations.

## Building a Reading Pipeline

A sustainable paper discovery practice requires more than one-off searches. Build a pipeline that continuously surfaces new relevant work:

### Weekly Routine

1. **Check preprint alerts**: Review your arXiv, bioRxiv, or SSRN email alerts or RSS feeds (15 min).
2. **Scan citation alerts**: Review Google Scholar citation alerts for new papers citing your key references (10 min).
3. **Process recommendation queue**: Review suggestions from OpenAlex, Research Rabbit, or Connected Papers for any recently added seed papers (10 min).
4. **Social signals**: Scan academic Twitter/Mastodon, relevant subreddits, or lab group Slack channels for shared papers (10 min).
5. **Triage and queue**: Add promising papers to your "to read" queue with a priority tag (high/medium/low) and the reason you flagged them.

### Managing the Reading Queue

Avoid the trap of an ever-growing, never-read paper queue:

- **Time-box reading**: Dedicate specific blocks (e.g., 2 hours Tuesday/Thursday) to reading queued papers.
- **Triage aggressively**: Not every flagged paper needs a full read. Use a 3-tier system: skim (5 min), selective read (20 min), deep read (60+ min).
- **Expire old items**: Papers that have been in your queue for more than 8 weeks without being read should be re-evaluated. If they are still relevant, read them now; otherwise, archive them.
- **Track what you read**: Maintain a reading log with dates and brief notes to build a personal knowledge base.

## Interdisciplinary Discovery

Finding papers outside your primary field is particularly challenging because you may not know the right terminology. Strategies include:

- **Concept-based search**: Use tools like OpenAlex that organize papers by research concepts rather than keywords.
- **Review articles**: Find review articles in the adjacent field—they provide curated entry points and vocabulary.
- **Cross-field citation chaining**: When your field's paper cites work from another discipline, follow that reference chain.
- **Ask experts**: Reach out to researchers in adjacent fields and ask for their recommended reading list for a newcomer.

## References

- OpenAlex API: https://api.openalex.org
- Connected Papers: https://www.connectedpapers.com
- Research Rabbit: https://www.researchrabbitapp.com
- Paper Recommendation: https://github.com/pengzhenghao/paper-recommendation
- VOSviewer: https://www.vosviewer.com
