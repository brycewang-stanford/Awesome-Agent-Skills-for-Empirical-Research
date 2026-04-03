---
name: extract-tikz
description: Extract TikZ diagrams from Beamer source, compile to PDF, convert to SVG with 0-based indexing. Use when updating TikZ diagrams for Quarto slides.
argument-hint: "[LectureN, e.g., Lecture2]"
allowed-tools: ["Read", "Bash", "Glob"]
---

# Extract TikZ Diagrams to SVG

Extract TikZ diagrams from the Beamer source, compile to multi-page PDF, and convert each page to SVG for use in Quarto slides.

## Steps

### Step 0: Freshness Check (MANDATORY)

**Before compiling, verify that `extract_tikz.tex` matches the current Beamer source.**

1. Find the Beamer source: `ls Slides/$ARGUMENTS*.tex`
2. Extract all `\begin{tikzpicture}` blocks from Beamer
3. Compare with `Figures/$ARGUMENTS/extract_tikz.tex`
4. If ANY difference exists: update extract_tikz.tex from the Beamer source
5. If extract_tikz.tex doesn't exist: create it from scratch

### Step 1: Navigate to the lecture's Figures directory
```bash
cd Figures/$ARGUMENTS
```

### Step 2: Compile the extract_tikz.tex file
```bash
TEXINPUTS=../../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode extract_tikz.tex
```

### Step 3: Count the number of pages
```bash
pdfinfo extract_tikz.pdf | grep "Pages:"
```

### Step 4: Convert each page to SVG using 0-BASED INDEXING

**CRITICAL: PDF pages are 1-indexed, but output SVG files are 0-indexed!**

```bash
PAGES=$(pdfinfo extract_tikz.pdf | grep "Pages:" | awk '{print $2}')
for i in $(seq 1 $PAGES); do
  idx=$(printf "%02d" $((i-1)))
  pdf2svg extract_tikz.pdf tikz_exact_$idx.svg $i
done
```

### Step 5: Sync to docs/ for deployment
```bash
cd ../..
./scripts/sync_to_docs.sh $ARGUMENTS
```

### Step 6: Verify SVG files
- Read 2-3 SVG files to confirm they contain valid SVG markup
- Confirm file sizes are reasonable (not 0 bytes)

### Step 7: Report results

## Source of Truth Reminder
TikZ diagrams MUST be edited in the Beamer `.tex` file first, then copied verbatim to `extract_tikz.tex`. See `.claude/rules/single-source-of-truth.md`.
