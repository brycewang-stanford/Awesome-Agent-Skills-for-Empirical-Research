---
name: new-slide-deck
description: Creates a Quarto revealjs slide deck in slides/ with the project style guide. Use when a presentation is needed.
argument-hint: <title>
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# Create Presentation

Create a new Quarto revealjs slide deck in `slides/` with the project's style guide applied.

## Arguments

- `$ARGUMENTS` — the presentation title and optional subtitle (e.g., "Regional Disparities in GDP" or "Job Market Talk: Regional Disparities")

## Steps

1. Parse the title (and subtitle, if separated by a colon) from the arguments.

2. Check `slides/` for existing files to avoid name collisions. Generate a filename using the naming convention from `slides/README.md` (e.g., `analysis-results.qmd` or `01-seminar-talk.qmd`).

3. Create the `.qmd` file in `slides/` with this YAML front matter (from the style guide in `slides/README.md`):
   ```yaml
   ---
   title: "<title>"
   subtitle: "<subtitle if provided>"
   author: "<from index.qmd author field, or [FILL: Author name]>"
   date: today
   format:
     revealjs:
       theme: simple
       slide-number: true
       css: |
         .reveal h1, .reveal h2, .reveal h3 {
           color: #2874A6;
         }
         .reveal strong {
           color: #229954;
         }
   ---
   ```

4. Pre-populate the body with a standard academic talk structure:
   ```markdown
   ## Motivation

   - [Key question or puzzle]
   - [Why it matters]
   - [What we do about it]

   ## Related Literature

   - [Strand 1: ...]
   - [Strand 2: ...]
   - **This paper:** [Contribution]

   ## Data

   - [Source and sample]
   - [Key variables]
   - [Summary statistics]

   ## Empirical Strategy

   - [Identification approach]
   - [Model specification]

   ## Main Results

   - [Finding 1]
   - [Finding 2]

   ## Robustness

   - [Alternative specifications]
   - [Placebo tests or falsification]

   ## Conclusion

   - [Summary of findings]
   - [Policy implications]
   - [Future work]

   ## Thank You {.center}

   Contact: [email]
   ```

5. Render the slide deck to verify it compiles:
   ```bash
   quarto render slides/<filename>.qmd
   ```

6. Report the file path and the command to re-render.
