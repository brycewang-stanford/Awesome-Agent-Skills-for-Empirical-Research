---
name: revise
description: R&R cycle — classify referee comments and route to appropriate agents. Replaces /respond-to-referee.
argument-hint: "[referee-report file path] [paper path (optional)]"
allowed-tools: Read,Grep,Glob,Write,Edit,Task
---

# Revise

Structure point-by-point referee responses with classification, agent routing per revision protocol, and diplomatic drafting.

**Input:** `$ARGUMENTS` — path to referee report file(s), optionally followed by paper path.

---

## Workflow

### Step 1: Parse Inputs
1. Read referee report(s) from `$ARGUMENTS`
2. Read the paper (paper/main.tex or specified path)
3. Read revision protocol from rules
4. Read existing scripts to know what analyses already exist

### Step 2: Classify Every Comment

| Class | Routing | Action |
|-------|---------|--------|
| **NEW ANALYSIS** | → Coder agent | Flag for user, create analysis task |
| **CLARIFICATION** | → Writer agent | Draft rewritten section |
| **REWRITE** | → Writer agent | Draft structural revision |
| **DISAGREE** | → User (mandatory) | Draft diplomatic pushback, flag for review |
| **MINOR** | → Writer agent | Draft fix directly |

### Step 3: Build Tracking Document
Save to `quality_reports/referee_response_tracker.md` with:
- Summary counts per referee
- Action items by priority (HIGH: new analysis, MEDIUM: clarification, FLAGGED: disagreements, LOW: minor)

### Step 4: Dispatch Agents
- CLARIFICATION/REWRITE → dispatch Writer with specific instructions
- NEW ANALYSIS → flag for user approval before dispatching Coder
- DISAGREE → draft diplomatic response, flag prominently for user

### Step 5: Draft Response Letter
Generate LaTeX response letter with:
- Summary of major changes
- Point-by-point responses with exact referee quotes
- Color-coded responses
- Page/section references for each change

### Step 6: Diplomatic Disagreement Protocol
When DISAGREE: open with acknowledgment, provide evidence, offer partial concession, NEVER say "the referee is wrong." FLAG for user review.

### Step 7: Save Outputs
1. Tracker: `quality_reports/referee_response_tracker.md`
2. Response letter: `quality_reports/referee_response_[journal]_[date].tex`
3. Revised sections: `paper/sections/` (for CLARIFICATION/REWRITE items)

---

## Principles
- **The response letter is the user's voice.** Match their tone.
- **Never fabricate results.** Mark NEW ANALYSIS items as TBD.
- **Flag all DISAGREE items.** These need human judgment.
- **Track everything.** Every comment appears in both tracker and response letter.
