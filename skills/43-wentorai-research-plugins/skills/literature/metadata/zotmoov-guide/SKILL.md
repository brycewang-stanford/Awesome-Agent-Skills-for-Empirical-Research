---
name: zotmoov-guide
description: "Zotero plugin for automatic attachment file organization"
metadata:
  openclaw:
    emoji: "📂"
    category: "literature"
    subcategory: "metadata"
    keywords: ["Zotero", "file management", "attachment", "auto-move", "organization", "linked files"]
    source: "https://github.com/wileyyugioh/zotmoov"
---

# ZotMoov Guide

## Overview

ZotMoov is a Zotero plugin that automatically moves and renames attachment files (PDFs, supplementary materials) to a designated directory with customizable naming patterns. It keeps your PDFs organized in a structured folder hierarchy outside Zotero's storage, using linked files instead of copies. Essential for researchers who want clean file organization alongside Zotero's metadata management.

## Installation

```bash
# Download .xpi from GitHub releases
# Zotero 7: Tools → Add-ons → Install Add-on From File
```

## Configuration

```markdown
### Settings (Edit → Preferences → ZotMoov)

**Destination Directory:**
~/Papers/  (your organized PDF library)

**File Naming Pattern:**
{%a}_{%y}_{%t}.pdf
→ Vaswani_2017_Attention Is All You Need.pdf

**Folder Structure:**
{%y}/{%j}/
→ 2017/NeurIPS/Vaswani_2017_Attention.pdf

**Available Variables:**
- {%a} — First author last name
- {%y} — Publication year
- {%t} — Title (truncated)
- {%j} — Journal/venue
- {%T} — Item type
- {%c} — Collection name
```

## Naming Patterns

```markdown
### Common Patterns

**Author_Year_Title:**
{%a}_{%y}_{%t}
→ Vaswani_2017_Attention Is All You Need

**Year/Author-Title:**
{%y}/{%a} - {%t}
→ 2017/Vaswani - Attention Is All You Need

**Collection/Author_Year:**
{%c}/{%a}_{%y}_{%t}
→ Transformers/Vaswani_2017_Attention Is All You Need

**Journal/Year/Author:**
{%j}/{%y}/{%a}_{%t}
→ NeurIPS/2017/Vaswani_Attention Is All You Need
```

## Workflow

```markdown
### Automatic Mode
1. Add paper to Zotero (browser connector, DOI import)
2. ZotMoov detects new attachment
3. Moves PDF to destination with naming pattern
4. Converts to linked file in Zotero
5. Original storage location freed

### Manual Mode
1. Select items in Zotero
2. Right-click → ZotMoov → Move Attachments
3. Bulk processing for existing library

### Reverse (Undo)
1. Right-click → ZotMoov → Move to Zotero Storage
2. Converts back to stored file
```

## Integration with Other Tools

```markdown
### Synced PDF Library
ZotMoov + cloud sync = PDFs accessible everywhere:
- Move to Dropbox/OneDrive/Google Drive folder
- Zotero metadata synced via Zotero Sync
- PDFs synced via cloud provider
- Access on any device with cloud sync

### With Other Plugins
- **Better BibTeX**: Use citekey in file name: {%b}.pdf
- **Zotero Style**: Visual indicators for linked vs stored
- **Zoplicate**: Handles duplicates before moving
```

## Use Cases

1. **File organization**: Structured PDF library outside Zotero
2. **Cloud sync**: PDFs in Dropbox/OneDrive for multi-device
3. **Backup strategy**: Separate PDF backup from Zotero data
4. **Naming convention**: Consistent file naming across library
5. **Storage management**: Free Zotero storage space

## References

- [ZotMoov GitHub](https://github.com/wileyyugioh/zotmoov)
- [Zotero Linked Files](https://www.zotero.org/support/attaching_files)
