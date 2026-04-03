---
name: zotero-actions-tags-guide
description: "Zotero workflow automation with custom actions and tags"
metadata:
  openclaw:
    emoji: "⚡"
    category: "literature"
    subcategory: "metadata"
    keywords: ["Zotero", "automation", "tags", "workflow", "actions", "productivity"]
    source: "https://github.com/windingwind/zotero-actions-tags"
---

# Zotero Actions & Tags Guide

## Overview

Zotero Actions & Tags is a powerful Zotero plugin that enables workflow automation through event-triggered actions. Define custom rules that execute when items are added, modified, opened, or tagged — such as auto-tagging by collection, running scripts on PDF open, auto-renaming attachments, or sending notifications. Transforms Zotero from a passive reference manager into an active research workflow engine.

## Installation

```bash
# Download .xpi from GitHub releases
# In Zotero 7: Tools → Add-ons → Install Add-on From File
```

## Core Concepts

```markdown
### Event → Condition → Action

**Events** (triggers):
- Item added to library
- Item added to collection
- Item modified
- Tag added/removed
- Attachment opened
- Item selected

**Conditions** (filters):
- Item type (article, book, etc.)
- Collection membership
- Tag presence/absence
- Field value match (regex)
- Date range

**Actions** (responses):
- Add/remove tags
- Set field values
- Run JavaScript
- Open URLs
- Copy to clipboard
- Show notifications
```

## Action Examples

### Auto-Tag by Collection

```json
{
  "name": "Auto-tag ML papers",
  "event": "add_to_collection",
  "condition": {
    "collection": "Machine Learning"
  },
  "actions": [
    {"type": "add_tag", "tag": "#ml"},
    {"type": "add_tag", "tag": "#to-read"}
  ]
}
```

### Mark as Read on Open

```json
{
  "name": "Track reading",
  "event": "open_attachment",
  "condition": {
    "attachment_type": "application/pdf"
  },
  "actions": [
    {"type": "remove_tag", "tag": "#to-read"},
    {"type": "add_tag", "tag": "#reading"},
    {"type": "set_field", "field": "extra",
     "value": "LastOpened: ${date}"}
  ]
}
```

### Auto-Prioritize Highly Cited

```json
{
  "name": "Flag high-impact",
  "event": "item_modified",
  "condition": {
    "field": "extra",
    "regex": "Citations:\\s*(\\d{3,})"
  },
  "actions": [
    {"type": "add_tag", "tag": "#high-impact"},
    {"type": "add_tag", "tag": "#priority"}
  ]
}
```

### Custom Script Action

```javascript
// Run custom JavaScript on trigger
// Example: Auto-format author names
{
  "name": "Format authors",
  "event": "item_added",
  "action": {
    "type": "script",
    "code": `
      const creators = item.getCreators();
      // Log to Zotero debug console
      Zotero.debug('New item by: ' +
        creators.map(c => c.lastName).join(', '));
    `
  }
}
```

## Workflow Recipes

### Reading Pipeline

```json
[
  {
    "name": "New → To-Read",
    "event": "item_added",
    "actions": [{"type": "add_tag", "tag": "#to-read"}]
  },
  {
    "name": "To-Read → Reading",
    "event": "open_attachment",
    "condition": {"has_tag": "#to-read"},
    "actions": [
      {"type": "remove_tag", "tag": "#to-read"},
      {"type": "add_tag", "tag": "#reading"}
    ]
  },
  {
    "name": "Reading → Done",
    "event": "tag_added",
    "condition": {"tag": "#done"},
    "actions": [
      {"type": "remove_tag", "tag": "#reading"}
    ]
  }
]
```

### Auto-Organization

```json
[
  {
    "name": "Tag by journal",
    "event": "item_added",
    "condition": {
      "field": "publicationTitle",
      "regex": "Nature|Science|Cell"
    },
    "actions": [
      {"type": "add_tag", "tag": "#top-journal"}
    ]
  },
  {
    "name": "Flag recent papers",
    "event": "item_added",
    "condition": {
      "field": "date",
      "after": "2024-01-01"
    },
    "actions": [
      {"type": "add_tag", "tag": "#recent"}
    ]
  }
]
```

## Configuration

```markdown
### Settings (Edit → Preferences → Actions & Tags)

- **Enable/disable** individual actions
- **Action priority** — execution order when multiple match
- **Logging** — debug action execution
- **Import/Export** — share action sets with collaborators
- **Keyboard shortcuts** — trigger actions manually
```

## Use Cases

1. **Reading workflow**: Auto-track reading status via tags
2. **Auto-organization**: Tag by collection, journal, or date
3. **Priority flagging**: Highlight high-impact or recent papers
4. **Team workflows**: Shared tag-based review pipelines
5. **Custom scripts**: Extend Zotero with JavaScript actions

## References

- [Zotero Actions & Tags GitHub](https://github.com/windingwind/zotero-actions-tags)
- [Zotero JavaScript API](https://www.zotero.org/support/dev/client_coding/javascript_api)
- [Zotero Plugin Development](https://www.zotero.org/support/dev/client_coding/plugin_development)
