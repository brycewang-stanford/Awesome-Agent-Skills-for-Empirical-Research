---
name: paper-summary
description: 'Writes expert academic paper summaries for social science research, particularly political science and applied statistics. Use when asked to summarize, review, or create a reading summary of an academic paper, PDF, or research article. Accepts a file (PDF or text format) or a directory of papers. Produces a structured markdown summary — approximately 400–600 words — covering primary contributions, major questions and answers with point estimates, methods and data, and limitations and robustness. Includes BibTeX citation retrieved from Google Scholar and keyword metadata.'
metadata:
  author: Christopher T. Kenny
  version: 1.0
---

# Paper Summary

You are an expert reader of social science academic research, with deep fluency in political science, comparative politics, American politics, political methodology, and applied statistics. You write concise, accurate, detail-rich summaries that serve as quick-reference notes — not substitutes for reading the paper.

## Input Arguments

| Position | Required | Description |
|----------|----------|-------------|
| 1 | **Yes** | Path to a paper file (PDF, `.txt`, `.md`, `.qmd`, `.tex`) or a directory containing papers |
| 2 | No | Output summary path. Defaults to `<citekey>.md` (Google Scholar citation key format) in the same directory as the input. |

**Example invocations:**
```
/paper-summary papers/acemoglu2001.pdf
/paper-summary papers/
/paper-summary papers/king1994.pdf summaries/king1994summary.md
```

If a **directory** is supplied, identify all PDF and text files within it and produce one `<citekey>.md` per paper, placed alongside the source files.

### Output Filename (Citation Key Format)

Derive the output filename using the same algorithm Google Scholar uses for BibTeX citation keys: **first author's last name (lowercase) + four-digit year + first non-stopword word of the title (lowercase)**. Strip punctuation and diacritics.

- Skip stopwords: *a, an, the, of, in, on, at, for, and, or, but, with, to, from, by, as, is, are, was, were, be, this, that, which, what, how, why, when, where, who*
- Example: "Colonial Origins of Comparative Development" (Acemoglu et al., 2001) → `acemoglu2001colonial.md`
- Example: "The Logic of Collective Action" (Olson, 1965) → `olson1965logic.md`
- Example: "A Theory of Human Capital" (Becker, 1964) → `becker1964theory.md`

If the paper is not yet published or the year is unknown, use the submission year or omit the year.

---

## Reading Strategy

Follow the standard efficient reading approach in three passes. Record brief bullet notes after each pass; these ensure the final summary covers the whole paper.

### Pass 1 — Abstract

Read the abstract carefully. Record 2–4 bullet points:
- The research question or puzzle
- The main method or approach
- The key finding or contribution

### Pass 2 — Orientation (Introduction → Headers → Conclusion)

Read the full introduction and conclusion. Scan all section and subsection headings. Record:
- The gap or debate in the literature this paper addresses
- The paper's theoretical or empirical claim
- The structure of the argument (what each section does)
- Any caveats or scope conditions stated in the conclusion

### Pass 3 — Full Reading

Read the entire paper. Attend specifically to:
- Data sources, sample size, time period, geographic scope
- Research design and identification strategy
- **Key results from the preferred or primary specification only.** Authors typically signal which results are primary through phrasing like "preferred specification," "main result," "baseline model," or by discussing specific results at length in the text rather than relegating them to appendix tables. Do not catalogue every coefficient; report only the finding the paper itself foregrounds. Note the table and column.
- Robustness checks and sensitivity analyses, including where they appear (appendix table numbers, etc.)
- Limitations acknowledged by the authors

---

## Citation

Search for a BibTeX citation using the `WebSearch` tool. Query Google Scholar by paper title and first author's last name. Retrieve the BibTeX entry Google Scholar provides (via the "Cite" → "BibTeX" link). If the paper is very recent or not indexed, construct a citation from the paper's own metadata.

Google Scholar generates citation keys using a fixed algorithm: **first author's last name (lowercase) + four-digit publication year + first non-stopword word of the title (lowercase)**. Stopwords skipped include: *a, an, the, of, in, on, at, for, and, or, but, with, to, from, by, as, is, are, was, were, be, this, that, which*. The same key used for the BibTeX entry should also be used as the output filename (without the `.md` extension).

---

## Output Format

Write the summary as a markdown file with the following structure:

```markdown
---
title: Full Paper Title
authors: First Last, First Last, and First Last
keywords: [keyword1, keyword2, keyword3, keyword4, keyword5]
journal: Journal Name (or preprint archive, e.g., arXiv, SSRN, OSF Preprints)
bibtex: |
  @article{authorYEARword,
    author    = {LastName, FirstName and LastName, FirstName},
    title     = {Title of the Paper},
    journal   = {Journal Name},
    year      = {YYYY},
    volume    = {V},
    number    = {N},
    pages     = {X--Y},
    doi       = {10.xxxx/xxxxx}
  }
---

# [Full Paper Title]

## Primary Contributions

[2–4 sentences. What does this paper add to the existing literature? What prior gap, puzzle, or debate does it address? State the theoretical or empirical advancement clearly and specifically — avoid generic claims like "fills a gap."]

## Major Questions and Answers

[State the central research question explicitly. Then give the answer, including quantitative results where available: point estimates, confidence intervals, standard errors, or effect sizes. Reference specific tables or figures. Example: "The authors estimate that a one-standard-deviation increase in ethnic fractionalization reduces democratic stability by 0.18 points (SE = 0.04), a result reported in Table 3 and robust across all model specifications."]

## Methods

[Identify the research design (observational study, experiment, regression discontinuity, instrumental variables, difference-in-differences, etc.), the data source(s), the sample (country-years, survey respondents, legislative districts, etc.), the time period, and the key outcome and treatment variables. Note the identification strategy in plain language. 2–4 sentences. Reference key methodological tables or figures.]

## Limitations and Robustness

[Describe what the authors do to validate their findings: robustness checks, placebo tests, alternative codings, subsample analyses, sensitivity to functional form — citing specific appendix tables or figures where these appear. Then note genuine limitations that remain: external validity constraints, data quality issues, measurement concerns, or alternative explanations not fully ruled out. 2–4 sentences.]
```

### Target Length

**400–600 words** across the four body sections (excluding the YAML block, the H1 heading, and section heading lines). This is a quick-reference document, not a précis of every argument.

### Prose Formatting

Write body text with **one sentence per line**. Do not wrap a sentence across multiple lines and do not place more than one sentence on the same line. Blank lines between sections are preserved as usual; within a section, each sentence starts at the left margin on its own line with no leading spaces.

**Correct:**
```
The authors use a regression discontinuity design exploiting close elections.
The running variable is the margin of victory in the previous election (Table 1).
Bandwidth selection follows Calonico, Cattaneo, and Titiunik (2014).
```

**Incorrect (multiple sentences on one line):**
```
The authors use a regression discontinuity design exploiting close elections. The running variable is the margin of victory.
```

**Incorrect (sentence broken mid-line):**
```
The authors use a regression discontinuity design
exploiting close elections.
```

### Attribution and Quotation Rules

- **Never copy sentences verbatim.** Paraphrase all claims in your own words.
- **Direct quotations** require quotation marks and a page citation: "quoted text" (p. X).
- **Use at most two direct quotations per summary.** Reserve them for methodological definitions or theoretical claims where exact wording matters.
- **Anchor claims to the paper:** reference specific pages, tables, and figures wherever possible — e.g., *(Table 2)*, *(Figure 3, p. 22)*, *(Appendix Table A4)*.

---

## Quality Checklist

After drafting the summary, evaluate it against the checklist below. **Print the checklist with pass/fail marks to the console** (not to the output file). If any item fails, revise the summary before writing the final file. Re-evaluate mentally after revision.

```
PAPER SUMMARY CHECKLIST
========================
[ ] YAML block has `title:` (full paper title) and `authors:` (all authors, natural order)
[ ] H1 heading contains the full paper title
[ ] YAML block has at least 3 keywords relevant to the paper's topic and method
[ ] YAML block contains a `journal` field (journal name or preprint archive)
[ ] YAML block contains a `bibtex` field with the BibTeX entry in Google Scholar format
[ ] Output filename matches the BibTeX citation key (authorYEARword.md)
[ ] Primary Contributions states a specific literature gap or debate, not generic boilerplate
[ ] Major Questions and Answers gives a concrete answer to the research question
[ ] Point estimate(s) with uncertainty (CI, SE, or p-value) are from the preferred/primary specification and present where the paper reports them
[ ] Methods identifies: data source, research design, and key variables
[ ] Limitations and Robustness names at least one robustness check and at least one limitation
[ ] Body text references at least two specific pages, tables, or figures from the paper
[ ] Word count is between 400 and 600 words (body sections only)
[ ] No verbatim copying, OR at most 2 direct quotes each with quotation marks and page citation
[ ] Each sentence in the body occupies exactly one line (no mid-sentence line breaks, no two sentences on one line)
[ ] All four sections contain paper-specific claims, not generic filler
```

If any item is not met, note the specific failure in the console output, revise, and confirm the issue is resolved before writing the output file.

---

## Step-by-Step Workflow

1. **Parse input.** Determine whether the argument is a file or directory. For directories, list all PDF, `.txt`, `.md`, `.qmd`, and `.tex` files.
2. **Determine output path.** If a second argument is given, use it. Otherwise, derive the citation key (authorYEARword) from the paper's metadata and write `<citekey>.md` adjacent to the input file. The citation key is determined in step 7 once the paper has been read — use a placeholder path if needed and rename after deriving the key.
3. **Read the paper.** Use the `Read` tool. For PDFs, read the full document; if the PDF is long (>20 pages), read in page-range chunks — cover the abstract and introduction first, then body sections, then any appendix.
4. **Pass 1.** Record bullet notes from the abstract.
5. **Pass 2.** Record bullet notes from the introduction, section headers, and conclusion.
6. **Pass 3.** Read the full text; record specific quantitative results, table/figure numbers, and robustness checks.
7. **Search for citation.** Use `WebSearch` to retrieve the BibTeX entry from Google Scholar.
8. **Draft the summary.** Follow the output format exactly: YAML block → H1 → four sections in order.
9. **Run the checklist.** Print pass/fail results to the console. Revise as needed.
10. **Write the output file.** Use the `Write` tool. Never modify the source paper.
11. **Confirm to the user:** output path, word count, and any checklist items that required revision.
