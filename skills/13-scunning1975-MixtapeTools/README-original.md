# MixtapeTools

> Tools for coding, teaching, and presentations with AI assistance.

---

## About This Repo

This is a collection of tools, templates, and philosophies I've developed while using Claude Code for:

- **Coding** (data analysis scripts, replication code, automation)
- **Teaching** (course materials, lecture decks, pedagogical tools)
- **Presentations** (Beamer decks, slides for talks and seminars)

As I develop new approaches, I'll add them here. Anyone is free to use them.

**Take everything with a grain of salt.** These are workflows that work for me. Your mileage may vary.

---

## Who I Am

**Scott Cunningham** — Professor of Economics at Baylor University

- **Website:** [www.scunning.com](https://www.scunning.com)
- **Substack:** [causalinf.substack.com](https://causalinf.substack.com) — I write regularly about causal inference, Claude Code, and random things
- **Free book:** [Causal Inference: The Mixtape](https://mixtape.scunning.com) — available online

---

## Start Here: My Workflow

**Location:** [`workflow.md`](workflow.md) | **Deck:** [`presentations/examples/workflow_deck/`](presentations/examples/workflow_deck/)

Before diving into specific tools, read my workflow document. It explains **how I think about using Claude Code for empirical research**—not just the tools, but the philosophy behind them.

**Key concepts:**

| Concept | What It Means |
|---------|---------------|
| **Thinking partner, not code monkey** | Claude is a collaborator who reasons about problems, not just a code generator |
| **External memory via markdown** | Claude has amnesia between sessions; markdown files provide institutional memory |
| **Cross-software replication** | R = Stata = Python to 6 decimal places, or something is wrong |
| **Adversarial review (Referee 2)** | Fresh Claude instance audits your work; you can't grade your own homework |
| **Verification through visualization** | Trust pictures over numbers; errors become visible |
| **Documentation as first-class output** | If it's not documented, it didn't happen |

Everything else in this repo implements these principles.

---

## The Tools

### 1. Referee 2 (Systematic Audit & Replication Protocol)

**Location:** [`skills/referee2/`](skills/referee2/) | `personas/referee2.md` (full protocol)

Referee 2 is a **health inspector for empirical research** — a systematic five-audit protocol with cross-language replication, formal referee reports, and a revise & resubmit process. It runs after a project is complete, in a **fresh terminal**, by a Claude instance that has never seen the work. The separation is what makes it independent: the Claude that built the pipeline cannot objectively audit it.

**The Five Audits:**

| Audit | What It Does |
|-------|--------------|
| **Code Audit** | Coding errors, missing value handling, merge diagnostics, variable construction |
| **Cross-Language Replication** | Replication scripts in 2 other languages (R/Stata/Python), results compared to 6 decimal places |
| **Directory Audit** | Folder structure, relative paths, naming conventions — replication-package ready? |
| **Output Automation Audit** | Are tables and figures programmatically generated or manually created? |
| **Econometrics Audit** | Identification strategy, standard errors, fixed effects, parallel trends, first stage |

**Critical Rule:** Referee 2 NEVER modifies author code. It only creates its own replication scripts. Only the author modifies the author's code.

*Referee 2 is one of two complementary audit tools. See below.*

---

### 2. Fletcher (Own All the Numbers)

**Location:** [`skills/fletcher/`](skills/fletcher/) | `.claude/skills/fletcher/SKILL.md` (actual skill)

Fletcher is a **defamiliarization audit for empirical output** — a six-step checklist for interrogating a figure or table before you interpret it. Named for Jason Fletcher, who identified a rounding artifact in a p-hacking analysis by asking about the spike at t=1 when everyone else was focused on the spike at t=2. The spike at t=1 was the tell. It was right there in the figure. Nobody asked about it because the main story had already automated their perception.

The habit: when reviewing output, step back from the main result and ask about the number no one is explaining — the odd pattern, the unexpected sign, the sample size that doesn't add up.

**The Shklovsky principle:** Viktor Shklovsky argued that art exists to defamiliarize — to make the stone stony again. Habit makes perception automatic; we stop seeing our output because we've already decided what it means before we looked. Fletcher exists to break that. To make you see the figure as a stranger would, before the story has collapsed everything else into background noise.

**Six steps, each crossed off, ruling at the end:**

| Step | Question |
|------|----------|
| **1. List everything** | What features are visible — not just the main result? |
| **2. What would generate this?** | For each feature: what could cause it, including mundane explanations? |
| **3. Find the hardest one** | Which feature is most difficult to explain under your preferred story? |
| **4. Own the sample size** | Does N make sense? What dropped? |
| **5. Check the pattern** | Across specs, subgroups, time — does it cohere? |
| **6. The ownership test** | If someone asked about any number, do you have an answer? |

**Ruling:** CLEAR / CONDITIONAL / HOLD

**Usage:** `/fletcher path/to/figure-or-table "what I think the main finding is"`

Read the full origin story: [`skills/fletcher/README.md`](skills/fletcher/README.md)

---

### Referee 2 and Fletcher: Complements, Not Substitutes

These two tools address different failure modes at different stages of the research process. **Both should be run. Neither replaces the other.**

| | Referee 2 | Fletcher |
|---|---|---|
| **Core question** | *Is this implemented correctly?* | *Do you understand what you're looking at?* |
| **Failure mode it catches** | Coding errors, bad merges, wrong SEs, non-replicating results | Confirmation focus, unexplained features, misread output |
| **When it runs** | After the project is complete | When output first appears, before writing begins |
| **Session** | Fresh terminal — independence is structural | Same session — you need the person closest to the work |
| **Persona** | Health inspector with a checklist | Mentor at the whiteboard |
| **Would have caught a merge error?** | Yes | Maybe |
| **Would have caught the t=1 spike?** | No | Yes |

**Why separate sessions for Referee 2 but not Fletcher?**

Referee 2 needs a fresh session because it's auditing *implementation* — the Claude that built the code will rationalize its own choices. True independence requires structural separation.

Fletcher doesn't need separation because it's auditing *perception* — your own understanding of output you produced. You're the right person to do that, with a structured forcing function to look past what you expect to see.

**The workflow:**
1. Produce output → `/fletcher` → interpret and write
2. Complete project → open fresh terminal → `/referee2`

---

### 3. The Rhetoric of Decks

**Location:** `presentations/`

My philosophy of slide design, plus a tested prompt for generating Beamer presentations. The key insight: aim for MB/MC equivalence across slides (smoothness), not maximum density.

**Core principles:**
- Beauty earns attention; attention enables communication
- Titles are assertions, not labels
- One idea per slide
- Bullets are defeat—find the structure hiding in your list

### 3. Split-PDF Skill (Download, Split, and Deep-Read Papers)

**Location:** [`skills/`](skills/) (human-readable guide) | `.claude/skills/split-pdf/SKILL.md` (actual skill)

A Claude Code **skill** — an invocable `/split-pdf` command that automates the full pipeline for reading academic papers:

1. **Download** the PDF (web search + download, or use a local file)
2. **Split** into 4-page chunks via PyPDF2
3. **Read** 3 chunks at a time (~12 pages), pausing between batches
4. **Write** structured reading notes with detailed extraction

**Why not just read the full PDF?** Long PDFs either crash the session ("prompt too long" — unrecoverable) or produce shallow, hallucinated output. Splitting forces Claude to attend carefully to every section and externalizes understanding into markdown notes incrementally.

**Usage:** Type `/split-pdf path/to/paper.pdf` or `/split-pdf "search query for paper"`

### 4. Compile Deck (Beamer Presentations with the Rhetoric of Decks)

**Location:** `.claude/commands/compiledeck.md`

A Claude Code **command** — invoke with `/compiledeck` — that embeds the full Rhetoric of Decks philosophy so you don't have to explain it each time.

**The skill asks two questions:**

1. **Who is the audience?**
   - **External** (seminar, conference, teaching) — sparse, performative, one idea per slide
   - **Working** (coauthors, yourself) — can be more detailed, documents reasoning

2. **What's the tone?**
   - **Professional/Academic** — your consistent "house style" for outward-facing work
   - **Colorful/Expressive** — unique, creative design each time

**Why separate these?** External presentations need polish and restraint. Working decks can be messier—they're thinking tools. Some people want the same style for both; others want creative freedom internally while maintaining a professional brand externally.

**House style:** Define your preferred "Professional/Academic" palette in your CLAUDE.md. The skill checks for it. If none is defined, it uses a sensible default.

**What's embedded:**
- The Three Laws (Beauty is Function, Cognitive Load is Enemy, Slide Serves Spoken Word)
- Titles as assertions, not labels
- MB/MC equivalence across slides
- The compile loop (compile → fix errors → fix warnings → visual check → repeat)
- TikZ coordinate checking and figure label verification

**Usage:** Type `/compiledeck` when creating or editing a Beamer deck.

### 5. Additional Commands

**Location:** `.claude/commands/`

| Command | Description |
|---------|-------------|
| `/compiletex [file.tex]` | Compile any LaTeX file and report errors/warnings. Aims for zero warnings. |
| `/newproject [name]` | Scaffold a new research project with standard folder structure and CLAUDE.md. Also available as a [skill](skills/newproject/). |

### 6. CLAUDE.md Template

**Location:** `claude/CLAUDE.md`

A template for giving Claude persistent memory within a project. Copy it to your project root and fill in the specifics. Claude Code will automatically read it every session.

---

## Repository Structure

```
MixtapeTools/
├── README.md                 # You are here
├── workflow.md               # How I use Claude Code for research (START HERE)
├── skills/                   # Human-readable guides to Claude Code skills
│   ├── README.md            # What skills are, how to use them, how to install
│   ├── fletcher/            # Fletcher: defamiliarization audit for output
│   │   └── README.md        # Full essay, origin story, six steps
│   ├── split-pdf/           # Documentation and examples for the split-pdf skill
│   │   └── README.md        # Detailed guide with methodology and examples
│   └── newproject/          # Documentation for the new-project scaffold skill
│       └── README.md        # Philosophy, folder purposes, installation
├── .claude/
│   ├── commands/             # Slash commands (invoke with /command-name)
│   │   ├── compiledeck.md   # /compiledeck — Beamer presentations with Rhetoric of Decks
│   │   ├── compiletex.md    # /compiletex — Compile LaTeX, report errors/warnings
│   │   └── newproject.md    # /newproject — Scaffold new research project
│   └── skills/
│       ├── fletcher/         # Skill: own all the numbers
│       │   └── SKILL.md     # Instructions Claude follows (invoke with /fletcher)
│       ├── split-pdf/        # Skill: download, split, and deep-read PDFs
│       │   ├── SKILL.md     # Instructions Claude follows
│       │   └── methodology.md # Why this method works (for humans)
│       └── newproject/       # Skill: scaffold new research projects
│           └── SKILL.md     # Instructions Claude follows
├── claude/                   # Templates for working with Claude
│   ├── CLAUDE.md            # Project context template (copy to your projects)
│   └── README.md
├── personas/                 # Systematic audit & replication protocols
│   ├── referee2.md          # The 5-audit protocol for empirical research
│   └── README.md
└── presentations/            # Everything about slide decks
    ├── rhetoric_of_decks.md           # Practical principles (condensed)
    ├── rhetoric_of_decks_full_essay.md # Full intellectual framework (600+ lines)
    ├── deck_generation_prompt.md      # The prompt + iterative workflow
    ├── README.md
    └── examples/
        ├── workflow_deck/             # Visual presentation of the workflow
        ├── rhetoric_of_decks/         # The philosophy deck (45 slides)
        └── gov2001_probability/       # A lecture deck
```

---

## The Philosophy

### Design Before Results

During estimation and analysis, focus entirely on whether the specification is correct. Results are meaningless until the "experiment" is designed on purpose. Don't get excited or worried about point estimates until the design is intentional.

### Trust But Verify (Heavily on Verify)

AI makes confident mistakes. Cross-software replication (R = Stata = Python) catches bugs that single-language analysis misses. If results aren't identical to 6+ decimal places across implementations, something is wrong.

### Adversarial Review Requires Separation

If you ask the same Claude that wrote code to review it, you're asking a student to grade their own exam. True adversarial review requires a **new terminal** with fresh context and no prior commitments.

### Referee 2 Never Modifies Author Code

The audit must be independent. Referee 2 creates its own replication scripts but **never touches the author's code**. Only the author modifies the author's code. This separation ensures the audit is truly external.

### Formal Process > Informal Vibes

Checklists beat intuition. The Referee 2 protocol works because it specifies exactly what to check, requires concrete deliverables (replication scripts, comparison tables, referee reports), and creates a paper trail.

### Documentation Is First-Class Output

If it's not documented, it didn't happen. Every audit produces a dated referee report filed in `correspondence/`. Every response is documented. Replication scripts are permanent artifacts. Future you (or your collaborators) can reconstruct exactly what happened.

---

## Quick Start

### 1. Read the Workflow

Start with [`workflow.md`](workflow.md) to understand the philosophy.

### 2. Set Up a Project

Copy `claude/CLAUDE.md` to your project root. Fill in your project specifics.

### 3. Do Your Analysis

Work with Claude as a thinking partner, not a code generator. Ask it to explain its understanding. Verify outputs visually. Document as you go.

### 4. Invoke Referee 2

When you have results worth checking:

1. Open a **new terminal** (fresh context is essential)
2. Paste the contents of `personas/referee2.md`
3. Say: "Please audit and replicate the project at [path]. Primary language is [R/Stata/Python]."
4. Respond to the referee report (fix or justify each concern)
5. Iterate until verdict is Accept

---

## Project Directory Structure

For the Referee 2 workflow to function properly, your research projects should include:

```
your_project/
├── CLAUDE.md                 # Project context for Claude
├── correspondence/
│   └── referee2/
│       ├── 2026-02-01_round1_report.md      # Detailed written report
│       ├── 2026-02-01_round1_deck.pdf       # Visual presentation of findings
│       ├── 2026-02-02_round1_response.md    # Author response
│       └── ...
├── code/
│   ├── R/                    # Author's code (ONLY author modifies)
│   ├── stata/
│   ├── python/
│   └── replication/          # Referee 2's replication scripts
├── data/
│   ├── raw/
│   └── clean/
└── output/
    ├── tables/
    └── figures/
```

---

## Contributing

Have improvements or additions? PRs welcome. I'm particularly interested in:

- Additional audit protocols (security reviewer, pedagogy reviewer, etc.)
- Examples showing the Referee 2 workflow catching real bugs
- Tools for other aspects of coding and teaching

---

## Acknowledgments

Inspired by [Boris Cherny's ChernyCode](https://github.com/meleantonio/ChernyCode) template for AI coding best practices.

---

## License

Use freely. Attribution appreciated but not required.

---

*Last updated: March 2026*
