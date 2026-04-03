# `/split-pdf` — Download, Split, and Deep-Read Academic Papers

**Skill location:** [`.claude/skills/split-pdf/SKILL.md`](../../.claude/skills/split-pdf/SKILL.md)

---

## What This Skill Does

You give Claude a paper — either a local PDF file or a search query like "Gentzkow Shapiro 2014 competition newspapers" — and it does the rest. It finds the paper online and downloads it (or uses your local file), saves it to an `articles/` directory, splits it into 4-page chunks using PyPDF2, then reads those chunks in small batches (3 at a time, ~12 pages), pausing between each batch for your review. As it reads, it writes structured notes into a `notes.md` file, extracting specific information across 8 dimensions: research question, audience, method, data, statistical methods, findings, contributions, and replication feasibility. By the end, you have the original PDF preserved in `articles/`, the split files in a subdirectory, and a detailed set of reading notes — all from a single `/split-pdf` command.

---

## Why It Exists

Claude Code can read PDFs, but long academic papers cause two failures:

1. **Session crash.** PDFs are token-expensive (fonts, vector graphics, tables, math notation). A 40-page paper can exceed the context window, producing an unrecoverable "prompt too long" error that destroys the entire session and all context.

2. **Shallow reading.** Even when the PDF fits, Claude's attention degrades over long documents — it reads the abstract carefully, skims the methodology, and often hallucinates details from the results. You get a confident summary that's subtly wrong.

These are related but distinct problems. The first kills the session. The second produces unreliable output while the session continues normally. Splitting addresses both.

---

## The Solution

Split the PDF into 4-page chunks, read 3 chunks at a time (~12 pages), and write structured notes incrementally.

### How It Works

| Step | Action |
|------|--------|
| **Acquire** | Download the PDF (via web search) or use a local file |
| **Split** | PyPDF2 splits into 4-page chunks in `articles/split_<name>/` |
| **Read** | Read 3 splits at a time, pause after each batch |
| **Extract** | Update running `notes.md` with structured information |
| **Confirm** | Wait for user approval before continuing to next batch |

### Usage

```
/split-pdf path/to/paper.pdf
/split-pdf "Gentzkow Shapiro Sinkinson 2014 competition newspapers"
```

**You must tell Claude what paper to read.** Claude cannot webcrawl for a paper it doesn't know exists. Provide either a local file path or a search query specific enough to find the paper — an author name, title, keywords, year, or some combination. If you just type `/split-pdf` with nothing else, Claude will ask you what you're looking for.

### What Gets Extracted (8 Dimensions)

The skill produces a **structured extraction** — more detailed and specific than a typical summary, organized around the dimensions a researcher needs to build on or replicate the work:

1. **Research question** — What is the paper asking and why does it matter?
2. **Audience** — Which sub-community of researchers cares about this?
3. **Method** — How do they answer the question? What is the identification strategy?
4. **Data** — What data do they use? Where did they find it? Unit of observation? Sample size? Time period?
5. **Statistical methods** — What econometric or statistical techniques? Key specifications?
6. **Findings** — Main results? Key coefficient estimates and standard errors?
7. **Contributions** — What is learned that we didn't know before?
8. **Replication feasibility** — Public data? Replication archive? Data appendix? URLs?

---

## Why This Design

**Why 4-page chunks?** Small enough for careful attention, large enough to keep logical sections (a methodology subsection, a results table with discussion) together. A 40-page paper becomes 10 chunks read in 4 rounds.

**Why 3 chunks per batch (~12 pages)?** Balances throughput against attention quality. Twelve pages is enough to make progress but not so much that comprehension degrades.

**Why pause between batches?** So you can:
- Review intermediate output and catch errors before they compound
- Redirect the reading or ask follow-up questions
- Skip sections that aren't relevant
- Control pacing for sections that need more care

**Why incremental notes instead of a final summary?** When Claude reads a full paper at once, it produces a summary — lossy compression. When it reads in batches and updates running notes, it accumulates detail. The final notes are richer than any one-shot summary.

For the full methodology, see [`.claude/skills/split-pdf/methodology.md`](../../.claude/skills/split-pdf/methodology.md).

---

## Directory Structure After Running

```
articles/
├── smith_2024.pdf                    # original PDF — ALWAYS preserved, never deleted
└── split_smith_2024/                 # split subdirectory
    ├── smith_2024_pp1-4.pdf          # 4-page chunks
    ├── smith_2024_pp5-8.pdf
    ├── smith_2024_pp9-12.pdf
    ├── ...
    └── notes.md                      # structured reading notes
```

**The original PDF is never deleted.** Whether Claude downloaded it via web search or you pointed it to a local file, the original always stays in `articles/`. The split files are derivatives. If anything goes wrong — a corrupted split, a re-read with different parameters — you can always re-split from the original.

---

## Example: Gentzkow, Shapiro & Sinkinson (AER 2014)

This directory contains a complete worked example showing the full pipeline from start to finish.

### What happened

The user typed:

```
/split-pdf "Gentzkow Shapiro Sinkinson competition ideological diversity newspapers"
```

Claude searched the web, found the paper on Matt Gentzkow's website at `https://web.stanford.edu/~gentzkow/research/competition.pdf`, downloaded it to a local `articles/` directory, and then split and read it. The original PDF was **kept** — only the splits were created alongside it.

### What's in this directory

```
gentskow_shapiro_competition/
├── gs_competition_pp1-4.pdf       # pages 1–4 (intro, motivation, preview)
├── gs_competition_pp5-8.pdf       # pages 5–8 (data, descriptive analysis)
├── gs_competition_pp9-12.pdf      # pages 9–12 (descriptive results, model setup)
├── gs_competition_pp13-16.pdf     # pages 13–16 (model continued, identification)
├── gs_competition_pp17-20.pdf     # pages 17–20 (model structure, assumptions)
├── gs_competition_pp21-24.pdf     # pages 21–24 (estimation, demand side)
├── gs_competition_pp25-28.pdf     # pages 25–28 (supply estimation, parameter estimates)
├── gs_competition_pp29-32.pdf     # pages 29–32 (model fit, welfare analysis)
├── gs_competition_pp33-36.pdf     # pages 33–36 (policy experiments, robustness)
├── gs_competition_pp37-40.pdf     # pages 37–40 (appendix, references)
├── gs_competition_pp41-42.pdf     # pages 41–42 (remaining references)
└── notes.md                       # structured reading notes (all 8 dimensions)
```

The original PDF would sit one level up in `articles/` — it is not included here to keep the repo size reasonable, but in actual use it is always preserved.

### The reading process

The 42-page paper was split into 11 chunks (ten 4-page chunks + one 2-page chunk). Claude read them in 4 rounds:

| Round | Splits read | Pages | What was covered |
|-------|-------------|-------|------------------|
| 1 | pp1-4, pp5-8, pp9-12 | 1–12 | Introduction, data, descriptive results |
| 2 | pp13-16, pp17-20, pp21-24 | 13–24 | Structural model, identification, estimation |
| 3 | pp25-28, pp29-32, pp33-36 | 25–36 | Parameter estimates, welfare, policy experiments |
| 4 | pp37-40, pp41-42 | 37–42 | Appendix robustness, references |

After each round, Claude paused and asked whether to continue. The `notes.md` file was updated incrementally after each batch.

### What the notes look like

Open [`notes.md`](gentskow_shapiro_competition/notes.md) to see the full output. It's a structured extraction across all 8 dimensions — more detailed than a typical summary — including specific coefficient estimates (e.g., β̄ = 0.81 vs. β̲ = −0.29), standard errors, equation numbers, exact data sources with where they were obtained, sample sizes, and a detailed assessment of replication feasibility. The notes run to ~320 lines because the paper is methodologically dense. A simpler empirical paper would produce shorter notes.

---

## Limitations

- **It is slow.** A 37-page paper requires ~4 rounds of reading with user confirmation between each. This is a deliberate trade-off: careful reading over fast reading.
- **Notes can become repetitive** if the paper revisits themes. Some manual editing of the final notes may be useful.
- **Not for triage.** If you just need to decide whether a paper is relevant, read only the first split (pages 1-4, which usually contains the abstract and introduction). You don't need the full protocol.
- **Papers under ~15 pages** can be read directly without splitting.
