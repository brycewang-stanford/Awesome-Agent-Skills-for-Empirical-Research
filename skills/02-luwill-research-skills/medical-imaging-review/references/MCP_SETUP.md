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

# MCP Server Configuration for Literature Collection

## ArXiv MCP (Preprints & Latest Research)

**Repository:** https://github.com/blazickjp/arxiv-mcp-server

### Configuration

```json
{
  "mcpServers": {
    "arxiv": {
      "command": "uvx",
      "args": ["arxiv-mcp-server"],
      "env": {
        "ARXIV_STORAGE_PATH": "~/.arxiv-mcp-server/papers"
      }
    }
  }
}
```

### Available Tools

| Tool | Purpose |
|------|---------|
| `search_papers` | Search by keywords with date range and category filters |
| `download_paper` | Download paper by arXiv ID |
| `list_papers` | List all downloaded papers |
| `read_paper` | Read downloaded paper content |

### Search Strategy

```
Query: "[topic] AND (segmentation OR detection OR classification)"
Categories: cs.CV, eess.IV, cs.LG
Date: Last 2-3 years for recent methods
Max results: 50-100 per query
```

### Example Queries

- `"medical image segmentation transformer"` (cs.CV, eess.IV)
- `"coronary artery deep learning"` (cs.CV)
- `"CT scan neural network"` (eess.IV)

---

## PubMed MCP (Biomedical Literature)

**Repository:** https://github.com/grll/pubmedmcp

Access 35+ million biomedical literature citations.

### Configuration

```json
{
  "mcpServers": {
    "pubmedmcp": {
      "command": "uvx",
      "args": ["pubmedmcp@latest"],
      "env": {
        "UV_PRERELEASE": "allow",
        "UV_PYTHON": "3.12"
      }
    }
  }
}
```

### Search Tips

- Use MeSH terms for precise medical searches
- Combine with publication type filters (Review, Clinical Trial)
- Filter by date for recent literature

### Example MeSH Queries

- `"Deep Learning"[MeSH] AND "Coronary Vessels"[MeSH]`
- `"Image Processing, Computer-Assisted"[MeSH] AND "Tomography, X-Ray Computed"[MeSH]`

---

## Zotero Integration

Access local Zotero database via API or Zotero-MCP.

### Direct API Access

```bash
# List collections
curl -s "http://localhost:23119/api/users/[USER_ID]/collections"

# Get items from collection
curl -s "http://localhost:23119/api/users/[USER_ID]/collections/[KEY]/items"
```

### Zotero-MCP (Recommended)

**Repository:** https://github.com/54yyyu/zotero-mcp

Provides structured access to:
- `zotero_search_items` - Search by keywords
- `zotero_get_item_fulltext` - Get full paper text
- `zotero_get_annotations` - Get user highlights/notes

### Extractable Fields

- title, abstractNote, date
- creators, publicationTitle
- DOI, tags, collections

---

## Source Selection Guide

| Source | Best For | Strengths |
|--------|----------|-----------|
| **ArXiv** | Latest methods, DL advances | Preprints, fast access, CS/AI focus |
| **PubMed** | Clinical validation, medical context | Peer-reviewed, MeSH indexing |
| **Zotero** | Organized collections, existing library | Local management, annotations |
