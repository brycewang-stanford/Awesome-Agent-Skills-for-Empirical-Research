---
name: research-paper-kb
description: "Build a persistent cross-session knowledge base from academic papers"
metadata:
  openclaw:
    emoji: "🧠"
    category: "research"
    subcategory: "methodology"
    keywords: ["knowledge base", "paper notes", "literature management", "cross-session", "research memory"]
    source: "wentor-research-plugins"
---

# Research Paper Knowledge Base

Build and maintain a persistent, structured knowledge base from academic papers that persists across sessions. This skill enables cumulative literature understanding by storing extracted insights, cross-references, and analytical notes in a queryable format that grows with each reading session.

## Overview

A core challenge in literature review work is that insights from individual papers are often lost between reading sessions. Researchers read a paper, extract key findings, then move on -- only to forget critical details weeks later when writing their own manuscript or encountering a related paper. Traditional reference managers store metadata and PDFs but do not capture the analytical work of reading: the connections between papers, the critiques of methodology, the synthesis of findings across studies.

This skill creates a structured knowledge base that captures not just what papers say, but how they relate to each other and to the researcher's own questions. Each paper entry includes standard metadata, section-by-section notes, methodological assessments, extracted claims with evidence quality ratings, and explicit connections to other papers in the knowledge base.

The knowledge base is stored in a human-readable format (Markdown + YAML frontmatter) that can be version-controlled with git, searched with standard tools, and read by both humans and AI assistants. When returning to the literature after days or weeks, the researcher (or their AI assistant) can query the knowledge base to recall prior findings, identify gaps, and build on accumulated understanding.

## Knowledge Base Structure

### Directory Layout

```
research-kb/
  _index.yaml              # Master index of all papers
  _themes.yaml             # Cross-cutting themes and concepts
  _questions.yaml           # Active research questions
  papers/
    smith-2024-deep-learning-proteins/
      notes.md              # Structured paper notes
      claims.yaml           # Extracted claims with evidence
      figures/              # Saved key figures (optional)
    jones-2023-attention-mechanisms/
      notes.md
      claims.yaml
  syntheses/
    attention-in-biology.md  # Cross-paper synthesis documents
    methodology-comparison.md
```

### Paper Notes Template

```markdown
---
paper_id: smith-2024-deep-learning-proteins
title: "Deep Learning for Protein Structure Prediction: A Survey"
authors: ["Smith, J.", "Chen, L.", "Williams, R."]
year: 2024
venue: "Nature Reviews Molecular Cell Biology"
doi: "10.1038/s41580-024-00001-1"
date_read: "2026-03-10"
relevance: high
tags: ["protein structure", "deep learning", "AlphaFold", "survey"]
connections: ["jones-2023-attention-mechanisms", "brown-2022-alphafold2"]
---

# Deep Learning for Protein Structure Prediction: A Survey

## Reading Purpose
Why I read this paper and what questions I hoped it would answer.

## Summary
2-3 paragraph summary of the paper's main argument and contribution.

## Key Findings
1. **Finding 1**: Description with page/section reference (p. 5, Section 3.2)
2. **Finding 2**: Description
3. **Finding 3**: Description

## Methodology Assessment
- **Approach**: Survey/review methodology
- **Scope**: 200+ papers covering 2018-2024
- **Strengths**: Comprehensive taxonomy of approaches, clear evaluation framework
- **Weaknesses**: Limited coverage of non-English literature, no meta-analysis
- **Reproducibility**: N/A (review paper)

## Connections to My Research
- Directly relevant to [my research question] because...
- Contradicts/supports [finding from another paper] in that...
- Suggests new direction: ...

## Key Quotes
> "Quote 1" (p. X)
> "Quote 2" (p. Y)

## Questions Raised
- [ ] Follow up on the claim that X leads to Y (cited as [ref])
- [ ] Check whether the benchmark in Table 3 includes recent models
- [ ] Read the methodological critique in [cited paper]

## References to Chase
- [Author, Year]: Reason this reference seems important
- [Author, Year]: Potential counterargument to main thesis
```

### Claims Database

```yaml
# claims.yaml - Extracted claims with evidence quality
claims:
  - id: smith-2024-claim-01
    statement: "AlphaFold2 achieves experimental-level accuracy on 95% of CASP14 targets"
    evidence_type: "empirical"
    evidence_quality: "strong"  # strong | moderate | weak | anecdotal
    page: 8
    section: "3.1"
    supports: ["brown-2022-claim-03"]
    contradicts: []
    caveats: "Accuracy measured by GDT-TS; performance varies for disordered regions"

  - id: smith-2024-claim-02
    statement: "Attention mechanisms are the key architectural innovation enabling structure prediction"
    evidence_type: "analytical"
    evidence_quality: "moderate"
    page: 12
    section: "4.2"
    supports: ["jones-2023-claim-01"]
    contradicts: ["lee-2023-claim-05"]
    caveats: "Author's interpretation; alternative architectures not fully explored"
```

## Building the Knowledge Base

### Adding a Paper

```python
import yaml
from pathlib import Path
from datetime import date

def add_paper(kb_path, paper_id, metadata, notes):
    """Add a new paper to the knowledge base."""
    paper_dir = Path(kb_path) / "papers" / paper_id
    paper_dir.mkdir(parents=True, exist_ok=True)

    # Write notes.md with YAML frontmatter
    frontmatter = yaml.dump(metadata, default_flow_style=False)
    content = f"---\n{frontmatter}---\n\n{notes}"

    (paper_dir / "notes.md").write_text(content)

    # Update master index
    update_index(kb_path, paper_id, metadata)

    print(f"Added paper: {paper_id}")

def update_index(kb_path, paper_id, metadata):
    """Update the master index with new paper."""
    index_path = Path(kb_path) / "_index.yaml"
    if index_path.exists():
        index = yaml.safe_load(index_path.read_text()) or {}
    else:
        index = {"papers": {}}

    index["papers"][paper_id] = {
        "title": metadata["title"],
        "year": metadata["year"],
        "relevance": metadata.get("relevance", "medium"),
        "tags": metadata.get("tags", []),
        "date_added": str(date.today())
    }

    index_path.write_text(yaml.dump(index, default_flow_style=False))
```

### Querying the Knowledge Base

```python
def find_papers_by_tag(kb_path, tag):
    """Find all papers with a given tag."""
    index = yaml.safe_load((Path(kb_path) / "_index.yaml").read_text())
    results = []
    for paper_id, info in index["papers"].items():
        if tag in info.get("tags", []):
            results.append((paper_id, info["title"]))
    return results

def find_connections(kb_path, paper_id):
    """Find all papers connected to a given paper."""
    paper_dir = Path(kb_path) / "papers" / paper_id
    notes_path = paper_dir / "notes.md"
    content = notes_path.read_text()

    # Parse YAML frontmatter
    parts = content.split("---", 2)
    metadata = yaml.safe_load(parts[1])

    return metadata.get("connections", [])

def get_claims_supporting(kb_path, claim_id):
    """Find all claims that support a given claim."""
    results = []
    for claims_file in Path(kb_path).rglob("claims.yaml"):
        data = yaml.safe_load(claims_file.read_text())
        for claim in data.get("claims", []):
            if claim_id in claim.get("supports", []):
                results.append(claim)
    return results
```

## Cross-Session Workflow

### Session Start Protocol

When beginning a new reading or writing session, the AI assistant should:

1. Load the master index to understand what has been read
2. Check active research questions in `_questions.yaml`
3. Review the most recent synthesis documents
4. Identify papers flagged for follow-up in previous sessions

### Session End Protocol

At the end of each session:

1. Update notes for any papers read during the session
2. Add new connections discovered between papers
3. Update research questions (answer resolved ones, add new ones)
4. Flag any papers to chase in the next session
5. Commit changes to git with a session summary message

## Synthesis Generation

### Theme-Based Synthesis

```markdown
# Synthesis: Attention Mechanisms in Biology

## Theme Overview
How attention mechanisms from NLP have been adapted for biological sequence analysis.

## Contributing Papers
1. smith-2024: Survey covering 200+ papers on protein structure prediction
2. jones-2023: Original attention mechanism analysis
3. brown-2022: AlphaFold2 architecture deep dive

## Consensus Findings
- Attention enables capturing long-range dependencies in sequences
- Multi-head attention is more effective than single-head for structural prediction
- Pre-training on large unlabeled sequence databases is critical

## Contested Points
- Whether attention maps are interpretable (smith-2024 says yes, lee-2023 says no)
- Optimal number of attention heads (ranges from 8 to 64 in literature)

## Gaps in the Literature
- Limited comparison with non-attention architectures on equal compute budgets
- Few studies on attention for RNA structure prediction
- No theoretical analysis of why attention works for biological sequences
```

## References

- Obsidian knowledge management: https://obsidian.md
- Zettlekasten method: https://zettelkasten.de/introduction
- Notion for research: https://www.notion.so/templates/research
- YAML specification: https://yaml.org/spec/1.2.2/
