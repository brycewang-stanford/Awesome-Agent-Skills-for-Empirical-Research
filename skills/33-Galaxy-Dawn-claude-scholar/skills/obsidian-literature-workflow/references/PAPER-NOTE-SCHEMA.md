# Paper Note Schema

Use this schema when normalizing or creating durable paper notes in `Papers/`.

## Required frontmatter

```yaml
---
type: paper
title: "Paper Title"
project: project-slug
authors:
  - Author A
year: 2026
venue: "Venue"
doi: "10.xxxx/xxxxx"
url: "https://..."
citekey: "author2026paper"
status: read
updated: 2026-03-16T00:00:00Z
---
```

## Recommended frontmatter for knowledge mapping

```yaml
keywords:
  - decoding
concepts:
  - shared geometry
methods:
  - contrastive learning
related_papers:
  - "Papers/Neighbor-Paper"
linked_knowledge:
  - "Knowledge/Literature-Overview"
  - "Knowledge/Method-Families"
```

## Recommended sections

- `## Claim`
- `## Research question`
- `## Method`
- `## Evidence`
- `## Strengths`
- `## Limitation`
- `## Direct relevance to repo`
- `## Relation to other papers`
- `## Knowledge links`
- `## Optional downstream hooks`

## Working rules from real collection passes

- Prefer one canonical note per paper and keep the schema aligned across the whole covered set.
- When the user asks to check **all** papers, perform a coverage pass rather than stopping at a representative subset.
- Use `zotero_key` as the durable join key between Zotero items and Obsidian notes.
- Keep `Direct relevance to repo` concrete enough to drive experiments, writing, or review prioritization.
