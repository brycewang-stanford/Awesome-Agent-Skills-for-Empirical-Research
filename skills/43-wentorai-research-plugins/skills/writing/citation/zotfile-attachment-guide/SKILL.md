---
name: zotfile-attachment-guide
description: "Guide to ZotFile for Zotero attachment management, renaming, and syncing"
metadata:
  openclaw:
    emoji: "📂"
    category: "writing"
    subcategory: "citation"
    keywords: ["zotero", "zotfile", "attachment", "pdf-management", "file-organization", "sync"]
    source: "https://github.com/jlegewie/zotfile"
---

# ZotFile Attachment Management Guide

**WARNING: ZotFile is NOT compatible with Zotero 7.** For Zotero 7, use the built-in attachment management or the [Attanger](https://github.com/MuiseDestiny/zotero-attanger) plugin as a replacement.

## Overview

ZotFile is one of the most established Zotero plugins with over 4,000 GitHub stars, providing advanced file management capabilities for PDF attachments and other documents linked to your Zotero library. It handles the critical but often neglected task of organizing, renaming, and synchronizing the actual files that make up a research library.

Without ZotFile, researchers often end up with a chaotic collection of PDFs named with meaningless publisher-generated identifiers, scattered across different directories, and difficult to manage outside of Zotero itself. ZotFile brings order to this chaos by automatically renaming files according to customizable patterns based on bibliographic metadata, moving them to organized directory structures, and managing tablet-based reading workflows.

The plugin is especially valuable for researchers with large libraries who need their PDFs accessible outside Zotero, whether for backup, sharing, or use with other tools. By maintaining a predictable, human-readable file naming and directory structure, ZotFile ensures that your research documents remain organized and accessible regardless of how you access them.

## Installation and Setup

Install ZotFile through the Zotero add-on mechanism:

1. Download the latest `.xpi` file from https://github.com/jlegewie/zotfile/releases
2. In Zotero, navigate to Tools > Add-ons > gear icon > Install Add-on From File
3. Select the `.xpi` file and restart Zotero

Configure ZotFile after installation:

- Open Tools > ZotFile Preferences
- **General Settings**:
  - Set the source folder for new files (where your browser downloads PDFs)
  - Set the custom location for linked attachments (e.g., `~/Documents/Research/Papers`)
  - Choose between "Attach stored copy" (files in Zotero data directory) or "Linked file" (files in custom location)

- **Renaming Rules**:
  - Configure the filename pattern using wildcards:
    - `{%a}` - Author last name
    - `{%y}` - Year
    - `{%t}` - Title
    - `{%j}` - Journal abbreviation
  - Example pattern: `{%a}_{%y}_{%t}` produces `Smith_2024_Deep_Learning_for_Protein.pdf`
  - Set maximum title length to prevent overly long filenames
  - Configure treatment of special characters and spaces

- **Tablet Settings** (if using a tablet for reading):
  - Set the tablet files directory (e.g., a cloud-synced folder)
  - Configure background file handling
  - Enable automatic extraction of annotations from returned tablet PDFs

## Core Features

**Automatic File Renaming**: When you add a new item with an attachment to Zotero, ZotFile can automatically rename the PDF based on the item's metadata. This transforms `10.1038_s41586-024-07487-w.pdf` into `Smith_2024_Title_of_Paper.pdf` without any manual intervention.

Renaming patterns support rich formatting:

| Pattern | Output Example | Description |
|---------|---------------|-------------|
| `{%a}_{%y}_{%t}` | `Smith_2024_Deep_Learning` | Author, year, title |
| `{%a}_{%y}_{%j}` | `Smith_2024_Nature` | Author, year, journal |
| `{%y}/{%a}_{%t}` | `2024/Smith_Deep_Learning` | Year subfolder, author, title |
| `{%a_zotero}_{%y}` | `SmithAndJones_2024` | Multiple authors |

**Custom File Location**: Move attachments from Zotero's internal storage to a custom directory structure. This is essential for researchers who:
- Want PDFs accessible from file managers and other applications
- Need to store files on specific drives with more storage capacity
- Want a predictable directory structure for scripting and automation
- Prefer linked files over Zotero-managed storage for portability

**Subfolder Organization**: Create automatic subfolder structures based on metadata:
- Organize by year: `{%y}/` creates `2024/`, `2023/`, etc.
- Organize by author: `{%a}/` creates `Smith/`, `Jones/`, etc.
- Organize by collection: mirror your Zotero collection hierarchy
- Combine patterns: `{%y}/{%j}/` creates `2024/Nature/`, `2024/Science/`

**Tablet Reading Workflow**: ZotFile manages a bidirectional sync between your Zotero library and a tablet reading folder:

1. Select papers you want to read on your tablet
2. Right-click > Manage Attachments > Send to Tablet
3. ZotFile copies PDFs to your configured tablet directory (typically a cloud-synced folder)
4. Read and annotate on your tablet using your preferred PDF reader
5. When finished, right-click > Manage Attachments > Get from Tablet
6. ZotFile retrieves the annotated PDFs and extracts new annotations into Zotero notes

**PDF Annotation Extraction**: ZotFile can extract highlights and text annotations from PDFs and convert them into Zotero notes. This works with annotations made in any PDF reader, not just Zotero's built-in reader. Each annotation includes:
- The highlighted or annotated text
- The page number for reference
- Color coding information
- Any comments you added

**Batch Operations**: Process your entire library or selected collections at once:
- Rename all attachments according to current rules
- Move all files to the custom location
- Extract annotations from all PDFs
- Update file links after moving directories

## Research Workflow Best Practices

**Setting Up a New Library**:
1. Configure ZotFile with your preferred naming pattern and directory
2. Import your existing PDFs into Zotero with metadata
3. Select all items and run "Rename and Move Attachments" to normalize everything
4. Verify the resulting file structure meets your needs

**Daily Workflow**:
1. Download new papers through your browser
2. Add them to Zotero (drag and drop or browser connector)
3. ZotFile automatically renames and moves the PDF
4. The file appears in your organized directory with a readable name

**Backup Strategy**: With ZotFile managing files in a known directory:
- Use Time Machine, rsync, or cloud storage to back up the PDF directory
- Back up the Zotero database separately
- The combination ensures full recoverability

**Collaboration**: Share your organized PDF directory with collaborators:
- The human-readable filenames make it easy to find specific papers
- The directory structure provides intuitive browsing
- Pair with a shared BibTeX file for complete reference sharing

**Migration from Other Managers**: When switching from Mendeley, EndNote, or other tools:
1. Export your library to a standard format (BibTeX or RIS)
2. Import into Zotero
3. Add your existing PDFs
4. Run ZotFile renaming to normalize all filenames to your chosen convention
5. Verify all file links are correct

## Compatibility Notes

ZotFile was originally developed for Zotero 5 and earlier versions. For Zotero 7 users, check the GitHub repository for the latest compatibility information. Some features may be handled natively in newer Zotero versions, while others may require the updated plugin. The Zotero community actively maintains compatibility guides for major plugin migrations.

## References

- GitHub Repository: https://github.com/jlegewie/zotfile
- ZotFile Documentation: http://zotfile.com
- Zotero Plugin Directory: https://www.zotero.org/support/plugins
- Zotero File Management Guide: https://www.zotero.org/support/attaching_files
