---
name: notero-zotero-notion-guide
description: "Sync Zotero references and annotations to Notion databases"
metadata:
  openclaw:
    emoji: "🔗"
    category: "tools"
    subcategory: "knowledge-graph"
    keywords: ["Zotero", "Notion", "sync", "reference management", "knowledge base", "annotations"]
    source: "https://github.com/dvanoni/notero"
---

# Notero: Zotero-Notion Sync Guide

## Overview

Notero is a Zotero plugin that syncs your reference library to a Notion database. When you add or update items in Zotero, Notero automatically creates or updates corresponding Notion pages with metadata (title, authors, DOI, tags), annotations, and notes. Bridges the gap between reference management and knowledge management workflows.

## Installation

```bash
# 1. Download .xpi from GitHub releases
# 2. In Zotero: Tools → Add-ons → Install Add-on From File

# Prerequisites:
# - Zotero 7
# - Notion account with a database for papers
# - Notion integration token
```

## Notion Database Setup

```markdown
### Required Properties
Create a Notion database with these properties:

| Property | Type | Description |
|----------|------|-------------|
| Title | Title | Paper title (auto-filled) |
| Authors | Rich text | Author names |
| Year | Number | Publication year |
| DOI | URL | Digital Object Identifier |
| URL | URL | Paper link |
| Abstract | Rich text | Paper abstract |
| Tags | Multi-select | Zotero tags |
| Item Type | Select | Article, book, etc. |
| Zotero URI | URL | Link back to Zotero item |
| Date Added | Date | When added to Zotero |
| Publication | Rich text | Journal/conference name |
```

## Configuration

```
# In Zotero: Tools → Notero Preferences

# 1. Notion Integration Token:
#    - Go to notion.so/my-integrations
#    - Create new integration
#    - Copy the token
#    - Share your database with the integration

# 2. Database ID:
#    - Open your Notion database
#    - Copy the ID from the URL
#    - Format: notion.so/<workspace>/<database_id>?v=...

# 3. Property Mapping:
#    - Map Zotero fields to Notion properties
#    - Configure which fields to sync

# 4. Sync Settings:
#    - Auto-sync on add/modify
#    - Sync annotations (highlights + notes)
#    - Sync attachments (link to PDF)
```

## Sync Workflow

```markdown
### Automatic Sync
1. Add paper to Zotero (via browser connector, DOI, etc.)
2. Notero detects new item
3. Creates Notion page with metadata
4. Updates on subsequent edits

### Manual Sync
1. Select items in Zotero
2. Right-click → "Sync to Notion"
3. Bulk sync supported

### Annotation Sync
1. Annotate PDF in Zotero reader
2. Highlights and notes sync to Notion page
3. Page references and colors preserved
```

## Advanced Configuration

```json
{
  "notion": {
    "propertyMapping": {
      "title": "Title",
      "creators": "Authors",
      "date": "Year",
      "DOI": "DOI",
      "url": "URL",
      "abstractNote": "Abstract",
      "tags": "Tags",
      "itemType": "Item Type",
      "publicationTitle": "Publication"
    },
    "syncOptions": {
      "syncOnModify": true,
      "syncAnnotations": true,
      "syncNotes": true,
      "createBacklink": true,
      "pageIcon": "📄"
    },
    "formatting": {
      "authorsFormat": "Last, F.",
      "maxAuthors": 5,
      "tagPrefix": ""
    }
  }
}
```

## Notion Templates

```markdown
### Paper Review Template
When a paper syncs, Notero can use a Notion template:

## Summary
<!-- Auto-filled abstract -->

## Key Contributions
- [ ] Contribution 1
- [ ] Contribution 2

## Methodology
<!-- Your notes -->

## Results
<!-- Your notes -->

## Relevance to My Research
<!-- Your notes -->

## Questions / Follow-ups
- [ ] Question 1

## Rating: ⭐⭐⭐⭐☆
```

## Integration Stack

```markdown
### Recommended Workflow
Zotero (collect) → Notero → Notion (organize + notes)
                                ↓
                         Notion AI (summarize)
                                ↓
                         Writing tool (cite)

### Complementary Plugins
- **Zotero Better BibTeX** — Citation keys in Notion
- **Zotero Style** — Visual organization in Zotero
- **Zotero Sci-Hub** — PDF retrieval before annotation
- **Notion Web Clipper** — Save web pages alongside papers
```

## Use Cases

1. **Knowledge management**: Unified paper + notes database
2. **Research tracking**: Notion views for project-based paper lists
3. **Team collaboration**: Shared Notion databases for lab groups
4. **Literature review**: Tag and categorize papers with Notion filters
5. **Reading workflow**: Kanban board (To Read → Reading → Done)

## References

- [Notero GitHub](https://github.com/dvanoni/notero)
- [Notion API](https://developers.notion.com/)
- [Zotero Plugin Development](https://www.zotero.org/support/dev/)
