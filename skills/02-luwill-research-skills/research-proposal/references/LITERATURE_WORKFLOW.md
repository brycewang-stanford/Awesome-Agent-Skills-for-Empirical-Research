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

# Literature Collection Workflow

Guide for gathering relevant literature during research proposal generation.

---

## Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      Literature Source Strategy                          │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌──────────────┐   ┌──────────────────┐   ┌─────────────────────────┐ │
│  │  WebSearch   │   │   Open Access    │   │    Zotero MCP           │ │
│  │              │   │                  │   │    (User Library)       │ │
│  │  • Trends    │   │  • arXiv         │   │                         │ │
│  │  • News      │   │  • PubMed        │   │  • Full-text papers     │ │
│  │  • Reviews   │   │  • bioRxiv       │   │  • User annotations     │ │
│  │  • General   │   │  • SSRN          │   │  • User notes           │ │
│  │    info      │   │  • Google Scholar│   │  • Organized refs       │ │
│  └──────────────┘   └──────────────────┘   └─────────────────────────┘ │
│         │                    │                         │               │
│         └────────────────────┴─────────────────────────┘               │
│                              │                                          │
│                    ┌─────────▼─────────┐                               │
│                    │  Synthesize into  │                               │
│                    │  Proposal Sections│                               │
│                    └───────────────────┘                               │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Phase 1: Initial Reconnaissance with WebSearch

### Purpose
- Understand current landscape
- Identify key researchers and institutions
- Find recent reviews and meta-analyses
- Discover emerging trends

### Search Strategies

#### Broad Overview Searches
```
Queries:
- "{topic} systematic review 2024 2025"
- "{topic} state of the art"
- "{topic} research trends"
- "{topic} future directions"
```

#### Finding Key Papers
```
Queries:
- "{topic} seminal paper"
- "{topic} landmark study"
- "{topic} highly cited"
- "best papers {topic} {year}"
```

#### Identifying Gaps
```
Queries:
- "{topic} limitations"
- "{topic} challenges"
- "{topic} open problems"
- "{topic} future research"
```

#### Methodology Discovery
```
Queries:
- "{topic} methodology"
- "{topic} research methods"
- "how to study {phenomenon}"
- "{method} for {topic}"
```

### Extracting Information from Web Results

When processing web search results, extract:
1. **Key findings** - Main results and conclusions
2. **Authors/Institutions** - Who is working on this
3. **Timeline** - When major advances occurred
4. **Terminology** - Field-specific vocabulary
5. **Controversies** - Debates and disagreements
6. **Open questions** - Identified gaps

---

## Phase 2: Open Access Sources

### arXiv (STEM, CS, Physics, Math)
```
Access: https://arxiv.org/
Search: https://arxiv.org/search/?query={topic}

Categories:
- cs.AI - Artificial Intelligence
- cs.LG - Machine Learning
- cs.CV - Computer Vision
- stat.ML - Statistics/ML
- physics.* - Various physics
- math.* - Various math
```

### PubMed (Biomedical, Life Sciences)
```
Access: https://pubmed.ncbi.nlm.nih.gov/
Search: https://pubmed.ncbi.nlm.nih.gov/?term={topic}

Filters useful:
- Free full text
- Review articles
- Publication date range
- Article type
```

### bioRxiv/medRxiv (Biology/Medicine Preprints)
```
Access: https://www.biorxiv.org/ and https://www.medrxiv.org/
Note: Preprints, not peer-reviewed
Use for: Most recent findings, ongoing research
```

### SSRN (Social Sciences, Economics)
```
Access: https://www.ssrn.com/
Strength: Working papers, business/economics/law
```

### Google Scholar
```
Access: https://scholar.google.com/
Features:
- Citation counts
- Related articles
- Author profiles
- "Cited by" links
```

### Open Access Journals
```
PLOS ONE: https://journals.plos.org/plosone/
Nature Communications: https://www.nature.com/ncomms/
Scientific Reports: https://www.nature.com/srep/
```

---

## Phase 3: Zotero MCP Integration

### Prerequisites
- User must have Zotero installed and configured
- Zotero MCP server must be running
- User should have uploaded relevant papers to their library

### Initial Reminder to User

```
Before we proceed with literature collection, please ensure:

1. Your Zotero library contains relevant papers for this research topic
2. If you have specific papers you want referenced, please add them to Zotero
3. Papers with full-text PDFs attached will be most useful

If you haven't prepared your Zotero library yet, I can proceed with open-access
sources and web searches, then you can add Zotero papers later.
```

### Zotero MCP Tool Usage

#### Search User's Library

**Basic Keyword Search:**
```
Tool: mcp__zotero__zotero_search_items
Parameters:
  query: "{research topic keywords}"

Example:
  query: "deep learning medical imaging"
```

**Advanced Search:**
```
Tool: mcp__zotero__zotero_advanced_search
Parameters:
  conditions: based on:
    - title contains {keyword}
    - author contains {name}
    - date > {year}
    - tag is {tag}

Example:
  conditions: [
    {"field": "title", "operator": "contains", "value": "transformer"},
    {"field": "date", "operator": ">", "value": "2022"}
  ]
```

**Semantic Search (if indexed):**
```
Tool: mcp__zotero__zotero_semantic_search
Parameters:
  query: "{natural language research question}"

Example:
  query: "What methods are used for detecting cardiac abnormalities in ECG signals?"
```

#### Retrieve Paper Content

**Get Full Text:**
```
Tool: mcp__zotero__zotero_get_item_fulltext
Parameters:
  item_key: "{key from search results}"

Returns: Full text content of the paper (if PDF attached)
```

**Get Metadata:**
```
Tool: mcp__zotero__zotero_get_item_metadata
Parameters:
  item_key: "{key from search results}"

Returns: Title, authors, abstract, journal, year, DOI, etc.
```

**Get User Annotations:**
```
Tool: mcp__zotero__zotero_get_annotations
Parameters:
  item_key: "{key from search results}"

Returns: User's highlights and annotations on the paper
```

**Get User Notes:**
```
Tool: mcp__zotero__zotero_get_notes
Parameters:
  item_key: "{key from search results}"

Returns: Any notes the user has attached to the paper
```

### Zotero Workflow Example

```
Step 1: Search for papers on the topic
> zotero_search_items(query="machine learning cardiac diagnosis")

Step 2: From results, identify most relevant papers (by title, year)

Step 3: Get full text of key papers
> zotero_get_item_fulltext(item_key="ABC123")

Step 4: Check for user insights
> zotero_get_annotations(item_key="ABC123")
> zotero_get_notes(item_key="ABC123")

Step 5: Get metadata for citation
> zotero_get_item_metadata(item_key="ABC123")
```

---

## Phase 4: Literature Organization

### Categorization Framework

Organize collected literature into these categories:

#### 1. Background/Context Papers
```
Purpose: Establish the research field
Content:
- Historical development
- Foundational concepts
- Widely-accepted theories
Typical age: Can include older seminal works
```

#### 2. State-of-the-Art Papers
```
Purpose: Show current capabilities and methods
Content:
- Recent advances
- Current best practices
- Latest methodologies
Typical age: Last 5 years
```

#### 3. Gap-Identifying Papers
```
Purpose: Support the research gap argument
Content:
- Limitations identified by others
- Calls for future research
- Reviews noting missing areas
Typical age: Recent (last 3-5 years)
```

#### 4. Methodology Papers
```
Purpose: Justify and detail methods
Content:
- Original method descriptions
- Validation studies
- Application examples
Typical age: Varies; cite original sources
```

#### 5. Comparative/Related Work
```
Purpose: Position the research
Content:
- Similar approaches
- Alternative solutions
- Adjacent research areas
Typical age: Recent preferred
```

### Documentation Template

```markdown
## Literature Collection Summary

### Background/Context (n papers)
| Citation | Key Points | Use In |
|----------|------------|--------|
| Author (Year) | Main finding | Introduction |

### State-of-the-Art (n papers)
| Citation | Key Points | Use In |
|----------|------------|--------|
| Author (Year) | Current best method | Lit Review |

### Gap-Identifying (n papers)
| Citation | Identified Gap | Use In |
|----------|----------------|--------|
| Author (Year) | "Future work should..." | Lit Review |

### Methodology (n papers)
| Citation | Method | Use In |
|----------|--------|--------|
| Author (Year) | Description of approach | Methodology |

### Related Work (n papers)
| Citation | Relation | Use In |
|----------|----------|--------|
| Author (Year) | Similar but different scope | Lit Review |
```

---

## Phase 5: Citation Preparation

### Information to Collect

For each paper, capture:

```
- Authors (full names)
- Year of publication
- Title
- Journal/Conference/Publisher
- Volume/Issue (if applicable)
- Pages (if applicable)
- DOI or URL
- Key findings (for citing)
- Relevant quotes (with page numbers)
```

### Citation Format Examples

#### APA 7th Edition
```
Smith, J. A., & Jones, B. C. (2024). Title of article in sentence case.
    Journal Name in Title Case, 15(3), 123-145. https://doi.org/10.xxxx

Multi-author (3+):
Chen, X., Wang, Y., Liu, Z., & Zhang, W. (2024). Article title.
    Journal, 10(2), 45-67. https://doi.org/10.xxxx

In-text:
(Smith & Jones, 2024)
(Chen et al., 2024)
```

#### MLA 9th Edition
```
Smith, John A., and Barbara C. Jones. "Article Title Here." Journal Name,
    vol. 15, no. 3, 2024, pp. 123-145.

In-text:
(Smith and Jones 128)
```

#### Chicago Author-Date
```
Smith, John A., and Barbara C. Jones. 2024. "Article Title Here."
    Journal Name 15 (3): 123-145. https://doi.org/10.xxxx

In-text:
(Smith and Jones 2024, 128)
```

---

## Handling Different Scenarios

### Scenario 1: Rich Zotero Library
```
User has extensive Zotero collection relevant to topic.

Strategy:
1. Start with Zotero semantic search
2. Get annotations/notes for user insights
3. Supplement with web search for recent news/trends
4. Use user's existing organization (collections, tags)
```

### Scenario 2: Empty or Sparse Zotero Library
```
User has no relevant papers in Zotero.

Strategy:
1. Inform user of limitation
2. Rely on WebSearch and open-access sources
3. Provide clear citations for open-access papers
4. Suggest key papers user might add to Zotero
```

### Scenario 3: Very New Topic
```
Limited existing literature available.

Strategy:
1. Focus on foundational/adjacent literature
2. Emphasize why topic is emerging
3. Include recent conference papers/preprints
4. Frame proposal as pioneering work
```

### Scenario 4: Interdisciplinary Topic
```
Topic spans multiple fields.

Strategy:
1. Search across domain-specific databases
2. Identify bridging papers
3. Balance literature from each field
4. Address methodological borrowing
```

---

## Quality Checks for Literature

### Coverage Check
- [ ] Seminal/foundational works included
- [ ] Recent papers (last 5 years) represented
- [ ] Multiple perspectives/approaches covered
- [ ] Key researchers in field cited
- [ ] Geographic/institutional diversity (if relevant)

### Relevance Check
- [ ] Each paper directly supports a claim
- [ ] No tangential citations
- [ ] Gap papers specifically identify the gap
- [ ] Method papers describe the methods used

### Balance Check
- [ ] Not over-reliant on single author/lab
- [ ] Mix of empirical and theoretical works
- [ ] Both supporting and challenging views
- [ ] Appropriate review-to-primary ratio

### Recency Check
- [ ] ~80% from last 5 years
- [ ] Latest advances included
- [ ] No outdated methods cited as current
- [ ] Historical context appropriately old

---

## Troubleshooting

### "No results found in Zotero"
```
Solutions:
1. Try broader search terms
2. Check if papers have been uploaded with full text
3. Verify MCP connection is working
4. Ask user to add relevant papers
```

### "WebSearch returns low-quality results"
```
Solutions:
1. Add site filters (site:nature.com, site:arxiv.org)
2. Use more specific terminology
3. Include author names if known
4. Add year constraints
```

### "Cannot access full text"
```
Solutions:
1. Check open-access repositories (arXiv, PubMed Central)
2. Use metadata/abstract only
3. Ask user to obtain and add to Zotero
4. Note limitation in proposal
```

### "Too much literature found"
```
Solutions:
1. Prioritize by citation count
2. Filter by publication venue quality
3. Focus on most recent within each category
4. Limit to papers directly supporting claims
```
