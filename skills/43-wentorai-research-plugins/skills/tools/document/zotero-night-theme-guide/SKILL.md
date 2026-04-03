---
name: zotero-night-theme-guide
description: "Dark mode theme plugin for Zotero reference manager"
metadata:
  openclaw:
    emoji: "🌙"
    category: "tools"
    subcategory: "document"
    keywords: ["Zotero", "dark mode", "theme", "night mode", "UI customization", "eye comfort"]
    source: "https://github.com/tefkah/zotero-night"
---

# Zotero Night Theme Guide

## Overview

Zotero Night is a dark mode theme plugin for Zotero that transforms the entire UI — library view, PDF reader, note editor, and preferences — into a comfortable dark interface. Reduces eye strain during long reading sessions and matches system-wide dark mode preferences. Works with Zotero 7 and integrates with other Zotero plugins.

## Installation

```bash
# Download latest .xpi from GitHub releases
# In Zotero 7: Tools → Add-ons → Install Add-on From File

# Or via Zotero Plugin Market
# Search "Zotero Night" in zotero-addons marketplace
```

## Configuration

```markdown
### Settings (Tools → Zotero Night)

**Theme Mode:**
- Dark — Always dark
- Light — Always light
- System — Follow OS dark/light mode
- Schedule — Dark between custom hours

**PDF Reader:**
- Dark background with inverted text
- Sepia mode for reduced blue light
- Custom brightness/contrast
- Preserve figure colors (don't invert images)

**Colors:**
- Background: customizable (default #1E1E1E)
- Text: customizable (default #D4D4D4)
- Accent: customizable (matches Zotero theme)
- Link color: customizable
```

## Theme Variants

```css
/* Built-in theme presets */

/* Default Dark */
--background: #1E1E1E;
--surface: #252526;
--text: #D4D4D4;
--text-secondary: #808080;
--accent: #007ACC;
--border: #3C3C3C;

/* OLED Dark */
--background: #000000;
--surface: #121212;
--text: #E0E0E0;

/* Nord */
--background: #2E3440;
--surface: #3B4252;
--text: #ECEFF4;
--accent: #88C0D0;

/* Solarized Dark */
--background: #002B36;
--surface: #073642;
--text: #839496;
--accent: #268BD2;
```

## PDF Reader Dark Mode

```markdown
### How It Works
1. Applies CSS filter to PDF viewer canvas
2. Inverts luminance while preserving hue
3. Special handling for:
   - Figures/images: excluded from inversion
   - Highlighted text: color preserved
   - Annotations: maintain original colors
   - Links: distinct clickable appearance

### Settings
- Brightness: 80-120% (adjustable)
- Contrast: 90-110% (adjustable)
- Invert images: on/off (default off)
- Sepia filter: 0-100% (for warm tones)
```

## Integration with Other Plugins

```markdown
### Compatible Plugins
- **Zotero Style** — Custom columns work in dark mode
- **Zotero PDF Translate** — Translation overlay themed
- **Better BibTeX** — Citation dialog themed
- **Zotero Actions Tags** — Tag colors adapt to dark background

### CSS Customization
For advanced users, override via userChrome.css:
  Zotero profile → chrome/userChrome.css
```

## Scheduled Dark Mode

```json
{
  "schedule": {
    "enabled": true,
    "darkStart": "18:00",
    "darkEnd": "07:00",
    "useSystemSunrise": true,
    "transition": "gradual"
  }
}
```

## Use Cases

1. **Night reading**: Comfortable PDF reading in low light
2. **Eye health**: Reduce blue light and screen glare
3. **Consistency**: Match OS/IDE dark mode preferences
4. **Long sessions**: Extended literature review comfort
5. **Presentation**: Professional dark UI for screen sharing

## References

- [Zotero Night GitHub](https://github.com/tefkah/zotero-night)
- [Zotero 7 Theming](https://www.zotero.org/support/preferences)
