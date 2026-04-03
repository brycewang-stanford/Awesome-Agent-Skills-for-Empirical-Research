---
name: translate-to-quarto
description: Translate Beamer LaTeX to Quarto RevealJS. Multi-phase workflow with TikZ extraction and QA.
argument-hint: "[LectureN_Topic.tex]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Bash", "Task"]
context: fork
---

# Beamer → Quarto Translation Workflow

Full translation of a Beamer LaTeX lecture to Quarto RevealJS HTML slides.

**CRITICAL: The Beamer .tex file is the SINGLE SOURCE OF TRUTH.**

---

## Phase 0: Pre-Flight Checks

### 0A. Environment Parity Audit
Scan Beamer for all custom environments. Verify CSS equivalents exist in your theme SCSS. If any are missing, create them FIRST.

### 0B. TikZ Freshness Verification
Run `/extract-tikz` to verify SVGs match current Beamer source.

### 0C. RDS Data Inventory
List all RDS files needed for interactive charts.

### 0D. Citation Key Mapping
Extract all citations from Beamer, map to bibliography keys.

## Phase 1: Pre-Translation Preparation
- Read complete Beamer source, count frames
- Inventory figures (TikZ → SVG, R plots → plotly, other → SVG)

## Phase 2: Create QMD File with YAML Header
- Standard RevealJS YAML with theme, logo, footer, bibliography
- Setup chunk for R data loading if needed

## Phase 3: Slide-by-Slide Translation
- Delegate to `beamer-translator` agent
- 1:1 frame-to-slide mapping
- Verbatim math, environment parity, no font reduction

## Phase 4: TikZ Diagram Integration
Reference extracted SVGs with 0-based indexing.

## Phase 5: R Figure Integration (Plotly-First)
Interactive plotly from RDS data, static SVG for TikZ/complex figures.

## Phase 6: First Render & Content Fidelity Check
Render, count slides, go through EVERY slide checking for issues.

## Phase 6.5: Pedagogical Review
Run pedagogy-reviewer before visual polish.

## Phase 7: Visual Polish
Semantic colors, transition slides, framing sentences.

## Phase 8: Proofreading
Run `/proofread` on the QMD file.

## Phase 9: Final Verification & Deployment
Render, open in browser, verify all elements.

## Phase 10: Beamer Source Sync
Apply any corrections back to Beamer source.

## Phase 11: Documentation
Update CLAUDE.md, session log, create PR.
