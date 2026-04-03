---
name: zotero-style-guide
description: "Feature-rich Zotero plugin for UI customization and styling"
metadata:
  openclaw:
    emoji: "🎨"
    category: "tools"
    subcategory: "document"
    keywords: ["Zotero", "styling", "UI customization", "reading progress", "tags", "columns"]
    source: "https://github.com/MuiseDestiny/zotero-style"
---

# Zotero Style Guide

## Overview

Zotero Style is one of the most popular Zotero plugins, adding extensive UI customization capabilities — custom columns (IF, citation count, reading progress), color-coded tags, visual indicators, and workflow enhancements. It transforms Zotero's default interface into a more informative and visually organized research library. Essential for researchers managing large paper collections.

## Installation

```bash
# Download latest .xpi from GitHub releases
# In Zotero: Tools → Add-ons → Install Add-on From File

# Or install via Zotero Plugin Market
# 1. Install zotero-addons plugin first
# 2. Search "Zotero Style" in the marketplace
```

## Custom Columns

### Impact Factor Column

```json
// Preferences → Zotero Style → Columns
{
  "columns": [
    {
      "name": "IF",
      "field": "extra",
      "regex": "IF:\\s*([\\d.]+)",
      "width": 60,
      "sortable": true
    }
  ]
}
```

### Citation Count Column

```json
{
  "columns": [
    {
      "name": "Citations",
      "field": "extra",
      "regex": "Citations:\\s*(\\d+)",
      "width": 70,
      "sortable": true,
      "format": "number"
    }
  ]
}
```

### Reading Progress Column

```json
{
  "columns": [
    {
      "name": "Progress",
      "type": "progress",
      "width": 100,
      "display": "bar",
      "colors": {
        "0-25": "#EF4444",
        "25-75": "#F59E0B",
        "75-100": "#10B981"
      }
    }
  ]
}
```

## Tag Styling

```json
// Color-coded tags for visual organization
{
  "tagStyles": {
    "#important": {
      "color": "#EF4444",
      "emoji": "🔴",
      "position": "left"
    },
    "#to-read": {
      "color": "#3B82F6",
      "emoji": "📖",
      "position": "left"
    },
    "#methodology": {
      "color": "#8B5CF6",
      "position": "left"
    },
    "#dataset": {
      "color": "#10B981",
      "position": "left"
    }
  }
}
```

## Item Indicators

```json
// Visual indicators in item list
{
  "indicators": {
    "hasAnnotations": {
      "icon": "📝",
      "tooltip": "Has annotations"
    },
    "hasNotes": {
      "icon": "🗒️",
      "tooltip": "Has notes"
    },
    "isRetracted": {
      "icon": "⚠️",
      "color": "#EF4444",
      "tooltip": "Retracted paper"
    }
  }
}
```

## Workflow Integration

```javascript
// Zotero Style works with other plugins

// With zotero-actions-tags: auto-tag on read
// With zotero-better-bibtex: show citekey column
// With zotero-pdf-translate: translation indicators
// With zoplicate: duplicate detection badges

// Custom column from Better BibTeX citekey
{
  "columns": [{
    "name": "CiteKey",
    "field": "citationKey",
    "width": 120,
    "plugin": "better-bibtex"
  }]
}
```

## Layout Customization

```json
{
  "layout": {
    "itemPane": {
      "sections": ["info", "tags", "notes", "related"],
      "defaultTab": "info"
    },
    "columns": {
      "defaultVisible": [
        "title", "creator", "year", "IF",
        "Citations", "Progress", "tags"
      ],
      "defaultSort": {
        "field": "year",
        "direction": "desc"
      }
    },
    "density": "compact"
  }
}
```

## Recommended Setup for Researchers

```markdown
### Suggested Columns
1. Title (auto)
2. Creator/Authors (auto)
3. Year (auto)
4. Publication
5. IF (from Extra field)
6. Citations (from Extra field)
7. Reading Progress (bar)
8. Tags (color-coded)
9. CiteKey (if using BibTeX)

### Suggested Tags
- 🔴 #critical — Must-read papers
- 🟡 #review — Review/survey papers
- 🔵 #methodology — Methods papers
- 🟢 #dataset — Dataset papers
- 🟣 #baseline — Baseline/comparison
- ⬜ #to-read — Reading queue
```

## Use Cases

1. **Library organization**: Visual columns for quick paper assessment
2. **Reading tracking**: Progress bars for paper reading status
3. **Impact assessment**: IF and citation count at a glance
4. **Visual tagging**: Color-coded categorization system
5. **Custom workflows**: Plugin integration for automated organization

## References

- [Zotero Style GitHub](https://github.com/MuiseDestiny/zotero-style)
- [Zotero Plugin Development](https://www.zotero.org/support/dev/client_coding/plugin_development)
- [Zotero Styles Gallery](https://www.zotero.org/styles)
