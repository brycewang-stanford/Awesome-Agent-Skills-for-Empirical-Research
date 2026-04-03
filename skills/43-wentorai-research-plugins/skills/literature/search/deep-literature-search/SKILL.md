---
name: deep-literature-search
description: "Multi-source exhaustive literature search across academic databases"
metadata:
  openclaw:
    emoji: "🕵️"
    category: "literature"
    subcategory: "search"
    keywords: ["exhaustive search", "systematic search", "multi-database", "literature review", "search strategy", "PRISMA"]
    source: "wentor-research-plugins"
---

# Deep Literature Search

## Overview

A deep literature search goes beyond a quick Google Scholar query. It is a methodical, multi-source search process designed to identify all relevant publications on a topic with minimal omissions. This level of thoroughness is required for systematic reviews, meta-analyses, grant applications, and dissertation literature reviews where comprehensiveness is not optional—it is a methodological requirement.

This skill provides a structured framework for planning, executing, and documenting exhaustive literature searches across multiple academic databases. It covers query formulation using controlled vocabularies, database selection strategy, deduplication, screening workflows, and PRISMA-compliant documentation of the search process.

The framework is database-agnostic and can be applied across disciplines, from biomedical sciences (PubMed, Cochrane) to social sciences (PsycINFO, ERIC), engineering (IEEE Xplore, Compendex), and multidisciplinary databases (Web of Science, Scopus, OpenAlex).

## Search Strategy Design

### Step 1: Define the Research Question

Use the PICO/PEO/SPIDER framework appropriate to your field:

- **PICO** (clinical/biomedical): Population, Intervention, Comparison, Outcome
- **PEO** (qualitative): Population, Exposure, Outcome
- **SPIDER** (mixed methods): Sample, Phenomenon of Interest, Design, Evaluation, Research type

**Example**: "What is the effect of mindfulness-based interventions (I) on academic stress (O) in graduate students (P) compared to no intervention (C)?"

### Step 2: Identify Key Concepts and Synonyms

Break your research question into 2-4 key concepts. For each concept, list all synonyms, related terms, abbreviations, and controlled vocabulary terms:

| Concept | Synonyms and Related Terms |
|---------|---------------------------|
| Mindfulness | mindfulness-based stress reduction, MBSR, meditation, mindful awareness |
| Academic stress | study stress, exam anxiety, academic burnout, student distress |
| Graduate students | postgraduate, doctoral students, PhD candidates, master's students |

### Step 3: Build the Search String

Combine concepts using Boolean logic:

```
("mindfulness" OR "MBSR" OR "mindfulness-based stress reduction" OR "meditation")
AND
("academic stress" OR "study stress" OR "exam anxiety" OR "academic burnout")
AND
("graduate student*" OR "postgraduate*" OR "doctoral student*" OR "PhD candidate*")
```

Key syntax rules:
- Use `OR` within concept groups (broadens)
- Use `AND` between concept groups (narrows)
- Use `*` for truncation (e.g., `student*` matches students, student's)
- Use `""` for exact phrases
- Use `NOT` sparingly and document its use

### Step 4: Adapt for Each Database

Each database has its own syntax and controlled vocabulary. You must translate your master search string for each target:

- **PubMed**: Use MeSH terms alongside free-text; syntax uses `[MeSH]` tags
- **Scopus**: Uses `TITLE-ABS-KEY()` field codes
- **Web of Science**: Uses `TS=` (Topic) and `TI=` (Title) field tags
- **IEEE Xplore**: Uses "Command Search" with field codes
- **OpenAlex**: Uses concept IDs and filter parameters in the API

## Multi-Database Execution

### Recommended Database Selection by Discipline

| Discipline | Primary Databases | Supplementary |
|-----------|-------------------|---------------|
| Biomedical | PubMed, Cochrane, Embase | CINAHL, PsycINFO |
| Computer Science | IEEE Xplore, ACM DL, DBLP | Scopus, arXiv |
| Social Sciences | PsycINFO, ERIC, Sociological Abstracts | Web of Science |
| Engineering | Compendex, IEEE Xplore | Scopus, Web of Science |
| Multidisciplinary | Web of Science, Scopus, OpenAlex | Google Scholar (supplementary) |

### Execution Checklist

For each database:
1. Translate the master search string to the database's syntax
2. Run the search and record the date, exact query string, and result count
3. Export all results in a structured format (RIS, BibTeX, or CSV)
4. Save a screenshot or copy of the search interface showing the query and results count

### Grey Literature and Supplementary Sources

A truly exhaustive search also covers non-indexed sources:

- **Preprint servers**: arXiv, bioRxiv, medRxiv, SSRN
- **Dissertations**: ProQuest Dissertations, EThOS, institutional repositories
- **Conference proceedings**: Check major conferences in your field
- **Citation chaining**: Forward (who cited this?) and backward (what did this cite?) from key papers
- **Expert consultation**: Contact domain experts for unpublished or in-press work
- **Trial registries**: ClinicalTrials.gov, WHO ICTRP (for clinical topics)

## Deduplication and Screening

### Deduplication Process

After collecting results from multiple databases, expect 20-40% overlap. Use reference management software to deduplicate:

1. Import all exported results into a single library (Zotero, EndNote, or Rayyan)
2. Run automatic deduplication using DOI matching first, then title+author matching
3. Manually review flagged potential duplicates—automated tools miss ~5-10%
4. Record the count: total imported, duplicates removed, unique records remaining

### Screening Workflow

Apply a two-stage screening process:

- **Title/Abstract screening**: Review each unique record against your inclusion/exclusion criteria. Mark as Include, Exclude, or Maybe.
- **Full-text screening**: Retrieve full texts for all Include and Maybe records. Apply detailed eligibility criteria.

Use screening tools like Rayyan, Covidence, or ASReview to manage this process, especially for large result sets (500+ records).

## PRISMA Documentation

Document your entire search process using the PRISMA 2020 flow diagram:

```
Records identified (N = ?)
  ├── Database 1 (n = ?)
  ├── Database 2 (n = ?)
  └── Other sources (n = ?)
Duplicates removed (n = ?)
Records screened (n = ?)
Records excluded (n = ?)
Full-text assessed (n = ?)
Full-text excluded with reasons (n = ?)
Studies included (n = ?)
```

Save your complete search strategies (exact query strings, dates, result counts per database) as supplementary material for your publication. This transparency is essential for reproducibility and is increasingly required by journals.

## References

- PRISMA 2020 Statement: https://www.prisma-statement.org
- Cochrane Handbook, Ch. 4 (Searching for studies): https://training.cochrane.org/handbook
- Literature Search tool: wentor-research-plugins
- Bramer, W.M. et al. (2017). "De-duplication of database search results." BMC Medical Research Methodology.
