---
name: markdown-unwrap
description: 'Unwraps hard-wrapped markdown files so that each sentence ends with a newline instead of mid-sentence line breaks. Joins continuation lines within a paragraph into single lines, then re-breaks at sentence boundaries (period, question mark, exclamation point). Preserves blank lines, headings, fenced code blocks, block quotes, and list items. Use when asked to unwrap text, fix line breaks, reflow sentences, or clean up hard-wrapped markdown or .qmd files.'
metadata:
  author: Christopher T. Kenny
  version: 1.0
---

# Markdown Unwrap

Reflow a markdown (or `.qmd`) file so that each **sentence** occupies its own line. This is the inverse of hard-wrapping: mid-sentence newlines are removed and the text is re-broken only at sentence endings.

## Input Arguments

| Position | Required | Description |
|----------|----------|-------------|
| 1 | **Yes** | Path to the input `.md` or `.qmd` file |
| 2 | No | Output path. Defaults to overwriting the input file in-place |

**Example invocations:**
```
/markdown-unwrap paper/paper.qmd
/markdown-unwrap README.md README-unwrapped.md
```

## Algorithm

Process the file line-by-line, maintaining a **current paragraph buffer**:

1. **Pass-through lines** — output immediately, do not buffer:
   - Blank lines (flush the buffer first, then emit the blank line)
   - ATX headings (`#`, `##`, …)
   - Fenced code block delimiters (` ``` ` or `~~~`); toggle a *in-code-block* flag and pass all lines through until the closing fence
   - Block-quote lines starting with `>`
   - List item lines starting with `-`, `*`, `+`, or a digit followed by `.`/`)`
   - YAML front-matter delimiters `---` / `...` (pass the entire front-matter block through unchanged)

2. **Buffering** — for all other lines, append the line's text to the current buffer (joining with a single space, trimming leading/trailing whitespace from each line).

3. **Flushing** — when a pass-through line (or end-of-file) is encountered, flush the buffer:
   - Split the accumulated text into sentences at `(?<=[.!?])\s+` — i.e., after a sentence-ending punctuation mark followed by whitespace.
   - Emit each sentence on its own line.
   - Clear the buffer.

4. Write the result to the output path (or overwrite the input if no output path was given).

## What Is Preserved

- Blank lines (paragraph separators)
- Fenced code blocks (contents unchanged)
- YAML front matter
- Headings, list items, and block quotes (each kept on its own line)
- All text content — only whitespace between words is affected

## What Changes

- Mid-sentence hard-wrap newlines are removed
- Each sentence ends with exactly one newline
- Trailing spaces within paragraphs are removed

## Implementation Notes

Implement the algorithm directly in your response — read the file, process it line-by-line following the rules above, and write the result. No external script is needed.

The sentence-split heuristic: a period followed by whitespace and an uppercase letter is a sentence boundary **unless** the word immediately before the period is a known abbreviation. Maintain a blocklist of common abbreviations that should never trigger a split:

- Titles: `Mr`, `Mrs`, `Ms`, `Dr`, `Prof`, `Sr`, `Jr`, `Rev`, `Gov`
- Latin: `e.g`, `i.e`, `et al`, `vs`, `etc`
- Academic: `Fig`, `Eq`, `Sec`, `Ch`, `Vol`, `No`, `pp`

When the token before the period matches one of these (case-insensitively), do not split. For `?` and `!` there is no abbreviation concern — always split.
