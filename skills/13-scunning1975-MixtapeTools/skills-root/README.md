# Skills for Claude Code

## What is this?

[Claude Code](https://docs.anthropic.com/en/docs/claude-code) is a way to work with Claude directly on your computer — you type instructions, and Claude reads files, writes code, searches the web, and carries out tasks for you. If you've used Claude in the browser, Claude Code is the version that can actually *do things* on your machine.

**Skills** are pre-written workflows for Claude Code. Think of them as recipes. You type a short command (like `/split-pdf`), and Claude follows a detailed set of instructions to carry out a complex, multi-step task automatically. Without the skill, you'd have to explain every step yourself each time. With the skill, it's one command.

This directory contains documentation, methodology, and example output for the skills in this repo. Browse what's available below.

---

## Available Skills

| Skill | Command | What it does |
|-------|---------|--------------|
| [**Referee 2**](referee2/) | `/referee2` | A five-audit systematic review protocol — code correctness, cross-language replication, directory structure, output automation, and econometrics. Runs in a fresh terminal after project completion. Creates independent replication scripts in two additional languages and files a formal referee report with verdict. [See documentation →](referee2/) |
| [**Fletcher**](fletcher/) | `/fletcher` | A defamiliarization audit for empirical output. Before you interpret a figure or table, Fletcher walks through six steps: list every feature (not just the main result), ask what would generate each one, find the hardest feature to explain, check the sample size, verify the pattern across specs, and confirm you can account for every number. Named for Jason Fletcher. [See the origin story →](fletcher/) |
| [**Compile Deck**](compiledeck/) | `/compiledeck` | Creates and compiles Beamer presentations following the Rhetoric of Decks philosophy — one idea per slide, assertion titles, MB/MC equivalence. Compiles until the log shows zero warnings. [See documentation →](compiledeck/) |
| [**Split-PDF**](split-pdf/) | `/split-pdf` | Downloads and deep-reads academic PDFs without crashing the session. Splits into 4-page chunks, reads in batches of ~12 pages, writes structured notes. [See full walkthrough →](split-pdf/) |
| [**New Project**](newproject/) | `/newproject` | Scaffolds a new research project with standard directory structure, CLAUDE.md template, and documented README. [See documentation →](newproject/) |

---

## How to Use These Skills

**Prerequisites:** You need [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed. If you haven't set it up yet, follow Anthropic's installation guide first.

**Then:**

1. **Clone this repo** (or just copy the `.claude/skills/` directory — that's the hidden folder where the actual skill instructions live)
2. Place the `.claude/skills/` folder in your project root
3. Open Claude Code in that project directory
4. Type the slash command: `/split-pdf "Gentzkow Shapiro 2014 competition newspapers"`

That's it. Claude Code automatically discovers skills in `.claude/skills/` and makes them available as slash commands. No configuration needed.

---

## Why are there two directories?

You might notice this repo has both a visible `skills/` folder (what you're reading now) and a hidden `.claude/skills/` folder. Here's why:

- **`.claude/skills/`** contains the actual skill files — the instructions Claude follows when you invoke a command. These are written *for Claude*, in a format it understands (step-by-step imperatives with metadata). This directory is hidden on GitHub because it starts with a dot.

- **`skills/`** (this directory) contains documentation *for you* — what each skill does, why it works, how to use it, and examples of real output. It's the human-readable companion to the machine-readable instructions.

When you clone the repo, you get both. Claude reads its instructions from `.claude/skills/`. You read the documentation here in `skills/`.

---

## How Skills Work (Under the Hood)

Each skill is a markdown file at `.claude/skills/<name>/SKILL.md`. It has a small header (metadata) that tells Claude Code the skill's name and what tools it's allowed to use, followed by step-by-step instructions that Claude follows when you invoke the command.

```
.claude/skills/
├── referee2/
│   └── SKILL.md           # The instructions Claude follows
├── fletcher/
│   └── SKILL.md           # The instructions Claude follows
├── compiledeck/
│   ├── SKILL.md           # The instructions Claude follows
│   ├── domain_patterns.md # Audience-specific guidance
│   ├── palette_reference.md # Color palette options
│   └── tikz_rules.md      # TikZ collision-prevention protocol
├── split-pdf/
│   ├── SKILL.md           # The instructions Claude follows
│   └── methodology.md     # Why this approach works (for humans)
└── newproject/
    └── SKILL.md           # The instructions Claude follows

skills/
├── referee2/
│   └── README.md          # Five audits, the R&R process, how it works
├── fletcher/
│   └── README.md          # Full origin essay — the t=1 spike story, Shklovsky
├── compiledeck/
│   └── README.md          # The Rhetoric of Decks, palettes, TikZ rules
├── split-pdf/
│   └── README.md          # Full documentation and examples (for humans)
└── newproject/
    └── README.md          # Philosophy, folder purposes, installation (for humans)
```

If you're curious what the actual instructions look like, you can read the [SKILL.md file directly](../.claude/skills/split-pdf/SKILL.md) — but you don't need to understand it to use the skill.

---

## Adding New Skills

To create your own skill:

1. Create a directory under `.claude/skills/` with a `SKILL.md` file
2. Optionally create a matching directory under `skills/` with a `README.md` for documentation

If you develop a useful skill for academic research, PRs are welcome.
