---
name: zutilo-guide
description: "Zotero utility plugin for keyboard shortcuts and batch editing"
metadata:
  openclaw:
    emoji: "⌨️"
    category: "literature"
    subcategory: "metadata"
    keywords: ["Zotero", "shortcuts", "batch editing", "utility", "productivity", "copy paste"]
    source: "https://github.com/wshanks/Zutilo"
---

# Zutilo Guide

## Overview

Zutilo is a Zotero utility plugin that adds keyboard shortcuts, batch editing capabilities, and clipboard operations for efficient library management. It enables power-user workflows — copying/pasting tags between items, batch-editing fields, assigning keyboard shortcuts to any Zotero action, and quick item manipulation. Essential for researchers managing large collections who need speed and efficiency.

## Installation

```bash
# Download .xpi from GitHub releases
# Zotero 7: Tools → Add-ons → Install Add-on From File
```

## Key Features

### Clipboard Operations

```markdown
### Tag Management
- **Copy tags** from selected item(s)
- **Paste tags** to selected item(s)
- **Remove tags** from selected item(s) by clipboard
- Supports multiple items simultaneously

### Field Operations
- Copy creator (author) information
- Paste creators to other items
- Copy item fields to clipboard
- Batch copy/paste between items

### Related Items
- Copy related item links
- Paste related items in bulk
- Quick-link items as related
```

### Keyboard Shortcuts

```markdown
### Configurable Shortcuts
Zutilo lets you assign keyboard shortcuts to:
- Copy/paste tags
- Copy/paste related items
- Edit item info
- Open attachment
- Show/hide panes
- Merge duplicates
- Any Zotero menu action

### Common Shortcuts Setup
Ctrl+Shift+C → Copy tags
Ctrl+Shift+V → Paste tags
Ctrl+Shift+R → Copy related items
Alt+E → Edit item
Alt+O → Open first attachment
```

### Batch Operations

```markdown
### Batch Tag Editing
1. Select multiple items (Ctrl+Click or Shift+Click)
2. Zutilo → Paste Tags (applies to all selected)
3. Or: Zutilo → Remove Tags (removes from all selected)

### Batch Field Editing
- Modify item type for multiple items
- Batch-update a field value
- Copy field from one item, paste to many

### Item Manipulation
- Merge items (combine metadata)
- Relate items in batch
- Move items between collections
```

## Configuration

```markdown
### Preferences (Edit → Preferences → Zutilo)

**Shortcut Configuration:**
- Each Zutilo function can have a keyboard shortcut
- Shortcuts: single key, Ctrl+key, or Ctrl+Shift+key
- Avoid conflicts with existing Zotero shortcuts

**Context Menu:**
- Show/hide Zutilo items in right-click menu
- Configure which operations appear
- Group by category (tags, fields, related)

**Behavior:**
- Tag paste mode: append (default) or replace
- Clipboard format: plain text or JSON
- Confirm before batch operations: on/off
```

## Workflow Examples

```markdown
### Organize by Reading Status
1. Create tag set: #to-read, #reading, #done
2. Select papers to read → Ctrl+Shift+V (paste #to-read)
3. As you finish → Copy #done tag → Select item → Paste

### Bulk Relate Papers
1. Select all papers on a topic
2. Zutilo → Relate Selected Items
3. All items now linked as related in Zotero

### Migrate Tags
1. Select items with old tag
2. Copy tags → modify in text editor → Paste new tags
3. Remove old tags in batch
```

## Use Cases

1. **Power-user efficiency**: Keyboard-driven library management
2. **Batch operations**: Tag and edit multiple items at once
3. **Organization**: Quick tag assignment and removal
4. **Workflow speed**: Reduce clicks in repetitive tasks
5. **Collection management**: Efficient item relationships

## References

- [Zutilo GitHub](https://github.com/wshanks/Zutilo)
- [Zotero Keyboard Shortcuts](https://www.zotero.org/support/kb)
