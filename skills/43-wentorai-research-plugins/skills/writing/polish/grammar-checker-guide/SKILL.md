---
name: grammar-checker-guide
description: "Use grammar and style checking tools to polish academic manuscripts"
metadata:
  openclaw:
    emoji: "✏️"
    category: "writing"
    subcategory: "polish"
    keywords: ["grammar checker", "academic style", "proofreading", "writing tools", "language editing"]
    source: "wentor-research-plugins"
---

# Grammar Checker Guide

A skill for using grammar and style checking tools to polish academic manuscripts. Covers tool comparison, configuration for scholarly writing, common academic English pitfalls, and workflows for integrating automated checking into the writing process.

## Tool Comparison

### Overview

| Tool | Best For | Academic Mode? | Privacy | Cost |
|------|----------|---------------|---------|------|
| Grammarly | General grammar, clarity | Yes (tone settings) | Cloud-based | Free / Premium |
| LanguageTool | Open-source, privacy | Yes (formal style) | Self-hostable | Free / Premium |
| ProWritingAid | Style depth, reports | Yes (academic style) | Cloud-based | Subscription |
| Writefull | Academic-specific | Designed for academic | Cloud-based | Free / Premium |
| Vale | CLI/CI linting for docs | Configurable rules | Local only | Free (open-source) |

### Privacy Considerations

```
For unpublished research:
  - Check the tool's data retention policy before pasting manuscript text
  - LanguageTool can be self-hosted (no data leaves your machine)
  - Vale runs entirely locally
  - Grammarly Enterprise offers data processing agreements

For sensitive or embargoed work:
  - Use local-only tools (Vale, local LanguageTool server)
  - Avoid pasting full manuscripts into cloud-based free tiers
  - Review the tool's terms regarding data use for model training
```

## Configuring Tools for Academic Writing

### LanguageTool Setup

```python
import os
import json
import urllib.request


def check_text_with_languagetool(text: str, language: str = "en-US") -> list:
    """
    Check text using the LanguageTool API.

    Args:
        text: The text to check
        language: Language code (en-US, en-GB, de-DE, etc.)
    """
    api_url = os.environ.get(
        "LANGUAGETOOL_URL",
        "https://api.languagetool.org/v2/check"
    )

    data = urllib.parse.urlencode({
        "text": text,
        "language": language,
        "enabledCategories": "GRAMMAR,TYPOS,PUNCTUATION,STYLE",
        "level": "picky"
    }).encode("utf-8")

    req = urllib.request.Request(api_url, data=data)
    response = urllib.request.urlopen(req)
    result = json.loads(response.read())

    issues = []
    for match in result.get("matches", []):
        issues.append({
            "message": match["message"],
            "context": match["context"]["text"],
            "offset": match["offset"],
            "length": match["length"],
            "suggestions": [r["value"] for r in match.get("replacements", [])[:3]],
            "rule_id": match["rule"]["id"]
        })

    return issues
```

### Vale Configuration for Academic Prose

```yaml
# .vale.ini -- place in your project root
StylesPath = styles
MinAlertLevel = suggestion

[*.md]
BasedOnStyles = Vale, academic

[*.tex]
BasedOnStyles = Vale, academic

# Custom academic rules (styles/academic/):
# - Flag passive voice overuse
# - Warn about hedging ("it is believed that")
# - Flag jargon and nominalization
# - Check for consistent spelling (US vs. UK English)
```

## Common Academic English Issues

### Grammar Pitfalls

```
1. Subject-verb agreement with collective nouns:
   Wrong:  "The data shows a clear trend."
   Right:  "The data show a clear trend." (data is plural in academic English)
   Note:   "The dataset shows..." is acceptable (dataset is singular)

2. Tense consistency:
   Methods:     Past tense ("We collected samples...")
   Results:     Past tense ("The analysis revealed...")
   Discussion:  Present tense for established knowledge
                ("These results suggest that X plays a role...")

3. Article usage:
   Wrong:  "In the Section 3, we describe method."
   Right:  "In Section 3, we describe the method."

4. Dangling modifiers:
   Wrong:  "Using regression analysis, the results showed..."
   Right:  "Using regression analysis, we found that..."
```

### Style Improvements

```
Wordiness -> Concise:
  "due to the fact that"    -> "because"
  "in order to"             -> "to"
  "a large number of"       -> "many"
  "it is worth noting that" -> (delete, just state the point)
  "at the present time"     -> "currently" or "now"

Nominalization -> Verbal form:
  "made an examination of"  -> "examined"
  "conducted an analysis"   -> "analyzed"
  "reached a conclusion"    -> "concluded"

Passive -> Active (when appropriate):
  "The samples were analyzed by us" -> "We analyzed the samples"
  Note: Passive voice is acceptable in Methods for focus on procedure
```

## Workflow Integration

### Recommended Editing Stages

```
Stage 1 - Content editing (you or co-authors):
  Focus on argument structure, logic, completeness
  Do NOT worry about grammar yet

Stage 2 - Automated grammar check:
  Run LanguageTool or Grammarly on the full manuscript
  Review each suggestion -- reject false positives
  Accept clear grammar and spelling fixes

Stage 3 - Style pass:
  Run ProWritingAid or Vale for style analysis
  Address wordiness, passive voice overuse, readability
  Check for consistent terminology throughout

Stage 4 - Human proofreading:
  Read aloud or have a colleague read
  Catch issues that automated tools miss
  Final check on formatting, references, figure labels
```

## Discipline-Specific Conventions

Different fields have different style expectations. Medical journals expect CONSORT/STROBE language. Legal writing has distinct citation formats. Engineering papers tolerate more passive voice. Always check your target journal's author guidelines and recent publications to calibrate your style to audience expectations.
