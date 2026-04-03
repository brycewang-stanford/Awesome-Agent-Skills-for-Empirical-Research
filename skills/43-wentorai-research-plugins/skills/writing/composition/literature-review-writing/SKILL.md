---
name: literature-review-writing
description: "Structure and write comprehensive literature reviews for any field"
metadata:
  openclaw:
    emoji: "📜"
    category: "writing"
    subcategory: "composition"
    keywords: ["literature review", "systematic review", "narrative review", "synthesis", "academic writing", "review paper"]
    source: "wentor-research-plugins"
---

# Literature Review Writing

A skill for structuring, synthesizing, and writing literature reviews. Covers narrative reviews, systematic reviews, scoping reviews, and literature review sections within empirical papers. Provides frameworks for organizing sources, identifying themes, and writing with synthesis rather than summary.

## Types of Literature Reviews

### Choosing the Right Review Type

| Type | Purpose | Search | Analysis | Length |
|------|---------|--------|----------|--------|
| Narrative | Broad overview of a topic | Selective | Qualitative synthesis | 5-30 pages |
| Systematic | Answer a specific question exhaustively | Exhaustive, documented | May include meta-analysis | 10-40 pages |
| Scoping | Map the extent of research on a topic | Broad, systematic | Charting and categorizing | 10-20 pages |
| Integrative | Synthesize diverse methodologies | Targeted | Conceptual synthesis | 10-25 pages |
| Umbrella | Review of systematic reviews | Focused on SRs | Synthesis of syntheses | 10-20 pages |

## Organizing Your Sources

### Building a Literature Matrix

```python
def create_literature_matrix(sources: list[dict]) -> dict:
    """
    Create a structured matrix for organizing reviewed literature.

    Args:
        sources: List of dicts with keys: author, year, title, method,
                 sample, key_findings, themes, limitations
    """
    matrix = {
        "headers": [
            "Author (Year)", "Research Question", "Method",
            "Sample/Data", "Key Findings", "Themes", "Limitations"
        ],
        "rows": [],
        "theme_index": {}
    }

    for src in sources:
        row = {
            "citation": f"{src['author']} ({src['year']})",
            "question": src.get("research_question", ""),
            "method": src.get("method", ""),
            "sample": src.get("sample", ""),
            "findings": src.get("key_findings", ""),
            "themes": src.get("themes", []),
            "limitations": src.get("limitations", "")
        }
        matrix["rows"].append(row)

        for theme in src.get("themes", []):
            matrix["theme_index"].setdefault(theme, []).append(
                row["citation"]
            )

    return matrix
```

### Thematic vs. Chronological Organization

```
Chronological (rarely ideal for reviews):
  "In 2010, Smith found X. Then in 2012, Jones found Y.
   In 2015, Lee found Z."
  Problem: Reads like an annotated bibliography, not a synthesis.

Thematic (recommended):
  "Three factors have been identified as predictors of X.
   First, [factor A] has been consistently supported (Smith, 2010;
   Jones, 2012; Lee, 2015). Second, [factor B] shows mixed results..."
  Advantage: Synthesizes findings around conceptual themes.

Methodological (useful for systematic reviews):
  "Studies using qualitative methods (n=12) found [pattern],
   while quantitative studies (n=25) reported [different pattern].
   This methodological divide suggests..."
```

## Writing with Synthesis

### Summary vs. Synthesis

```
Summary (weak -- describes one paper at a time):
  "Smith (2020) studied 200 undergraduates and found that sleep
   quality predicted academic performance. Jones (2021) surveyed
   150 graduate students and found a similar relationship."

Synthesis (strong -- integrates multiple sources around a point):
  "Sleep quality has been consistently linked to academic performance
   across both undergraduate (Smith, 2020; Lee, 2019) and graduate
   (Jones, 2021) populations, with effect sizes ranging from r=0.25
   to r=0.42. However, this relationship may be confounded by
   socioeconomic factors (Park, 2022), which only two studies
   controlled for."
```

### Synthesis Sentence Starters

```
Agreement:
  "There is broad consensus that..."
  "Multiple studies converge on the finding that..."
  "This finding has been replicated across [contexts]..."

Disagreement:
  "However, findings diverge regarding..."
  "In contrast to the majority view, [author] argues..."
  "The evidence is mixed, with some studies reporting [X] and others [Y]..."

Gap identification:
  "Notably absent from this literature is..."
  "While [aspect] has been well studied, [gap] remains unexplored..."
  "No studies to date have examined [specific gap]..."

Transition:
  "Taken together, these findings suggest..."
  "Building on this body of work, recent studies have begun to..."
  "This line of research has evolved from [earlier focus] to [current focus]..."
```

## Structuring the Review

### Standard Sections

```
1. Introduction (1-2 pages)
   - Define the topic and scope
   - Explain why this review is needed (gap, timeliness, controversy)
   - State the review's objectives or research questions

2. Methods (for systematic/scoping reviews)
   - Search strategy, databases, date range
   - Inclusion/exclusion criteria
   - Screening process (PRISMA flow diagram)

3. Body: Thematic Sections (bulk of the review)
   - Each section covers a theme, construct, or sub-question
   - Synthesize rather than summarize
   - Use tables to compare studies when appropriate

4. Discussion / Synthesis
   - What is the overall state of knowledge?
   - Where do studies agree and disagree?
   - What are the gaps?

5. Conclusion / Future Directions
   - Summarize the key takeaways
   - Propose a research agenda addressing identified gaps
```

## Common Pitfalls

### What Reviewers Look For

```
Problem: "Laundry list" structure
  - Each paragraph describes one study in isolation
  Fix: Group studies by theme and synthesize across them

Problem: Missing recent literature
  - Review stops at 2020 in a fast-moving field
  Fix: Search within the last 12 months before submission

Problem: Uncritical acceptance
  - All studies treated as equally valid
  Fix: Evaluate methodological quality and note study limitations

Problem: No conceptual framework
  - Sources listed without a guiding structure
  Fix: Start with a framework (theoretical, conceptual, or thematic map)

Problem: Omitting contradictory evidence
  - Only citing studies that support the authors' position
  Fix: Actively seek and discuss disconfirming evidence
```

## Tools for Literature Review Management

- **Zotero + ZotFile**: Organize PDFs, tag by theme, generate bibliographies
- **Covidence**: Systematic review screening and data extraction
- **Rayyan**: Free AI-assisted abstract screening for systematic reviews
- **Notion/Obsidian**: Build a literature matrix with linked notes
- **VOSviewer**: Bibliometric visualization of citation networks and keyword clusters
