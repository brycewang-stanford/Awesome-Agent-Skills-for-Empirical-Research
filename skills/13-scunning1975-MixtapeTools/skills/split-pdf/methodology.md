# Why PDF Splitting Works: The Methodology

This document explains the reasoning behind the split-pdf skill. It is reference material for humans — the SKILL.md file contains the actual instructions Claude follows.

---

## The Problem

Claude Code (currently Claude Opus 4.5, model ID `claude-opus-4-5-20251101`) can read PDFs, and it has a very large context window (200k tokens in). In principle, a 40-page academic paper should fit comfortably. In practice, it doesn't work well. Claude Code regularly chokes when asked to read long PDFs, and this manifests in two distinct ways:

**Problem 1: Session-breaking "prompt too long" errors.** PDF rendering into tokens is expensive. PDFs are not plain text — they are containers for fonts, vector graphics, embedded images, multi-column layouts, mathematical notation, tables, and footnotes. When Claude Code ingests a PDF, it must convert this complex layout into a linear token stream. A long PDF can produce a token sequence that, combined with the rest of the conversation context, exceeds the model's input limit. When this happens, Claude Code returns a "prompt too long" error. There is no way to recover — the session is broken, and all context is lost unless it has been externalized to files.

**Problem 2: Shallow, unreliable reading.** Even when the PDF does not trigger a hard failure, comprehension degrades badly for long documents. The model's attention over many tokens from a single dense document is not uniform — it attends more carefully to the beginning and end, and less carefully to the middle. The result is that Claude "skims" rather than "reads." It catches the abstract and introduction, gets fuzzy on the methodology, and often misses or fabricates details from the results and appendix. It truncates content silently, hallucinates details it didn't actually parse, or produces shallow summaries that miss critical methodological details.

These are related but distinct problems. The first is a hard constraint — the session dies. The second is a soft degradation — the session continues but the output is unreliable. Splitting addresses both.

## Why Batched Reading Works

Reading 3 splits at a time (~12 pages) does several things:

1. **Forces the model to focus.** With only 12 pages of content, Claude cannot skim. It has to engage with the material at a granular level — the specific equations, the exact data sources, the precise variable definitions.

2. **Creates natural checkpoints.** After each batch, the model writes down what it has learned so far. This means its understanding is externalized into a markdown file. If it makes an error in batch 1, you can catch it before batch 2 builds on it.

3. **Accumulates rather than summarizes.** When you ask Claude to read a full paper at once, it produces a summary — a lossy compression. When you ask it to read in batches and update running notes, it accumulates detail. The final notes are richer than any one-shot summary could be.

4. **Controls for the "front-loading" problem.** Claude's attention is not uniform over a long document. It attends more carefully to the beginning and end. By splitting the paper, every section gets to be "the beginning" of some chunk.

## Why 4-Page Chunks

Four pages is a sweet spot:
- Small enough that Claude attends carefully to every detail
- Large enough that logical sections (a methodology subsection, a results table with discussion) stay together
- Produces a manageable number of chunks (a 40-page paper = 10 chunks = 4 rounds of reading)

## Why the Pause-and-Confirm Protocol

The human pause between batches serves multiple purposes:
- **Review intermediate output** — catch errors before they compound
- **Redirect the reading** — ask follow-up questions, skip sections, or change focus
- **Prevent context drift** — Claude doesn't lose track of where it is in a long session
- **Control pacing** — some papers require more careful reading in specific sections

## Limitations

- **It is slow.** A 37-page paper split into 10 chunks, read 3 at a time, requires 4 rounds. Each round involves the user confirming "yes, continue." This is a 10-15 minute process rather than a 1-minute process.
- **Notes can become repetitive** if the paper revisits themes. Some manual editing of the final notes may be useful.
- **Assumes the paper is worth reading carefully.** For triage — quickly deciding whether a paper is relevant — reading just the first split (pages 1-4, which usually contains the abstract and introduction) is sufficient.
