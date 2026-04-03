<!--
  ╔══════════════════════════════════════════════════════════════╗
  ║  本文件为开源 Skill 原始文档，收录仅供学习与研究参考        ║
  ║  CoPaper.AI 收集整理 | https://copaper.ai                  ║
  ╚══════════════════════════════════════════════════════════════╝

  来源仓库: https://github.com/luwill/research-skills
  项目名称: research-skills
  开源协议: MIT License
  收录日期: 2026-04-02

  声明: 本文件版权归原作者所有。此处收录旨在为社会科学实证研究者
  提供 AI Agent Skills 的集中参考。如有侵权，请联系删除。
-->

# Project File Templates

## CLAUDE.md Template

```markdown
# [Topic] Literature Review Writing Guidelines

## Terminology Standardization

| Unified Term | Avoid Using |
|--------------|-------------|
| [standard term 1] | [variant 1], [variant 2] |
| [standard term 2] | [variant 1], [variant 2] |
```

## Reference Sources

### ArXiv MCP (Latest Methods)
```
Search queries:
- "[topic] segmentation transformer" (cs.CV, eess.IV)
- "[topic] deep learning" (cs.LG)
Date range: 2022-present
Downloaded papers: [list paper IDs]
```

### PubMed MCP (Clinical Literature)
```
MeSH queries:
- "Deep Learning"[MeSH] AND "[domain]"[MeSH]
- "[method]"[MeSH] AND "diagnosis"[MeSH]
Filters: Review, Clinical Study
```

### Zotero Database
```
API: http://localhost:23119/api/users/[USER_ID]/
Collections:
- [Collection 1]: collections/[KEY]/items
- [Collection 2]: collections/[KEY]/items
```

### Literature Categories
1. **[Category 1]**: [description, N papers]
2. **[Category 2]**: [description, N papers]
3. **[Category 3]**: [description, N papers]

## Key Methods to Cover

| Category | Methods | Status |
|----------|---------|--------|
| [Cat 1] | [Method A], [Method B] | [ ] |
| [Cat 2] | [Method C], [Method D] | [ ] |

## Performance Data Summary

| Method | Dataset | Dice | HD95 | Source |
|--------|---------|------|------|--------|
| [Method 1] | [Dataset] | 0.XXX | X.XX | [ref] |

## Quality Checklist

### Structure
- [ ] Key Points section (3-5 bullets)
- [ ] Table per major section
- [ ] Figure placeholders with captions

### Content
- [ ] All major methods covered
- [ ] Limitations for each category
- [ ] Future directions articulated

### Language
- [ ] Hedging language used
- [ ] Consistent terminology
- [ ] All claims cited
```

---

## IMPLEMENTATION_PLAN.md Template

```markdown
# Implementation Plan: [Review Title]

## Overview
- **Topic**: [specific topic]
- **Target journals**: [journal 1], [journal 2]
- **Target length**: [word count], [ref count]

## Stage 1: Literature Collection
**Goal**: Gather comprehensive corpus
**Status**: Not Started

### ArXiv MCP (Deep Learning Methods)
- [ ] Search "[topic] segmentation" in cs.CV, eess.IV
- [ ] Search "[topic] transformer/attention" in cs.CV
- [ ] Download key papers (target: 50-100)
- [ ] Extract method details from downloaded papers

### PubMed MCP (Clinical Literature)
- [ ] Search MeSH: "Deep Learning" AND "[domain]"
- [ ] Filter by publication type (Review, Clinical Study)
- [ ] Collect clinical validation studies (target: 30-50)

### Additional Sources
- [ ] Search IEEE Xplore for [keywords]
- [ ] Search Google Scholar for [keywords]
- [ ] Check Zotero existing collections

### Organization
- [ ] Export all to Zotero
- [ ] Categorize by method/application
- [ ] Gap analysis

## Stage 2: Outline Development
**Goal**: Define paper structure
**Status**: Not Started

- [ ] Draft section headings
- [ ] Map literature to sections
- [ ] Plan comparison tables
- [ ] Design figure placeholders

## Stage 3: Section 1-2 (Introduction, Datasets)
**Goal**: Write foundation sections
**Status**: Not Started

- [ ] 1.1 Clinical Background
- [ ] 1.2 Technical Challenges
- [ ] 1.3 Scope and Contributions
- [ ] 2.1 Public Datasets (Table 1)
- [ ] 2.2 Evaluation Metrics

## Stage 4: Section 3 (Methods)
**Goal**: Write method sections
**Status**: Not Started

- [ ] 3.1 [Category 1]
- [ ] 3.2 [Category 2]
- [ ] ...
- [ ] Method comparison table (Table 2)

## Stage 5: Section 4-5 (Applications, Commercial)
**Goal**: Write application sections
**Status**: Not Started

- [ ] 4.1 [Application 1]
- [ ] 4.2 [Application 2]
- [ ] 5.1 Commercial products (Table 3)
- [ ] 5.2 Regulatory landscape

## Stage 6: Section 6-7 (Discussion, Conclusion)
**Goal**: Write synthesis sections
**Status**: Not Started

- [ ] 6.1 Current Limitations
- [ ] 6.2 Future Directions
- [ ] 7. Conclusion

## Stage 7: Integration & Polish
**Goal**: Finalize manuscript
**Status**: Not Started

- [ ] Unify terminology
- [ ] Cross-reference check
- [ ] Language polish
- [ ] Reference formatting

## Key Literature Mapping

| Section | Key Papers |
|---------|------------|
| 3.1 | [Paper A], [Paper B] |
| 3.2 | [Paper C], [Paper D] |

## Literature Sources Summary

| Source | Query/Collection | Papers | Status |
|--------|------------------|--------|--------|
| ArXiv | [query 1] | N | [ ] |
| ArXiv | [query 2] | N | [ ] |
| PubMed | [MeSH query] | N | [ ] |
| Zotero | [collection name] | N | [ ] |
```

---

## Comparison Table Templates

### Dataset Table
```markdown
**Table 1. Public Datasets for [Task]**

| Dataset | Year | Cases | Annotation Type | Access |
|---------|------|-------|-----------------|--------|
| [Name] | 20XX | N | [type] | [link] |
```

### Method Comparison Table
```markdown
**Table 2. Deep Learning Methods for [Task]**

| Reference | Category | Architecture | Dataset | Dice | HD95 | Innovation |
|-----------|----------|--------------|---------|------|------|------------|
| [Author] [ref] | [Cat] | [Arch] | [Data] | 0.XXX | X.XX | [1-line summary] |
```

### Commercial Products Table
```markdown
**Table 3. Commercial [Domain] Products**

| Company | Product | Technology | Regulatory | Key Features |
|---------|---------|------------|------------|--------------|
| [Name] | [Product] | [Tech] | FDA/CE/NMPA | [features] |
```
