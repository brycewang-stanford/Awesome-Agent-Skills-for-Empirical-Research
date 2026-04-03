---
description: Run a 6-agent pre-submission referee report for an academic paper targeting a specified journal
---

You are coordinating a rigorous pre-submission review of an academic economics paper. You will run 6 specialized review agents in parallel and consolidate their findings into a structured report.

## Phase 1: Parse Arguments and Discover the Paper

Parse `$ARGUMENTS` as follows:
- The recognized journal names are:
  - **Top-5 economics**: `AER`, `QJE`, `JPE`, `Econometrica`, `REStud`
  - **Finance**: `JF`, `JFE`, `RFS`, `JFQA`
  - **Macro**: `AEJMacro`, `JME`, `RED`
  - (case-insensitive; users can add further journals by editing this list in the skill file)
- If the first token of `$ARGUMENTS` matches one of these names, treat it as the **target journal** and treat any remaining text as the **file path**.
- If no token matches a journal name, treat the entire `$ARGUMENTS` as a file path and set the target journal to `top-field` (meaning the review applies high general standards without a specific journal persona).
- If `$ARGUMENTS` is empty, set both to their defaults: no file path (auto-detect) and target journal `top-field`.

Store the resolved target journal as `TARGET_JOURNAL` for use in Agent 6 and the report header.

If a file path was provided, use it as the main LaTeX file. Otherwise, auto-detect:

1. Use Glob with pattern `**/*.tex` to list all .tex files in the current directory (exclude any `_minted-*` or build output folders).
2. Identify the **main document**: the .tex file that contains `\documentclass` or `\begin{document}`. Read each candidate briefly if needed.
3. Read the main file and extract all `\input{}`, `\include{}`, and `\subfile{}` references to build the full file list.
4. Read all component .tex files to understand the complete paper structure (introduction, data, methodology, results, appendix, etc.).
5. Use Glob to list figure files: patterns covering common directories and formats:
   - `**/Figures/**/*.pdf`, `**/figures/**/*.pdf`, `**/Figure/**/*.pdf`, `**/figure/**/*.pdf`
   - `**/Figures/**/*.png`, `**/figures/**/*.png`, `**/Figure/**/*.png`, `**/figure/**/*.png`
   - `**/Figures/**/*.eps`, `**/figures/**/*.eps`, `**/Figure/**/*.eps`, `**/figure/**/*.eps`
   - `**/Figures/**/*.jpg`, `**/figures/**/*.jpg`, `**/Figure/**/*.jpg`, `**/figure/**/*.jpg`
   - `**/Figures/**/*.jpeg`, `**/figures/**/*.jpeg`, `**/Figure/**/*.jpeg`, `**/figure/**/*.jpeg`
   - `**/Figures/**/*.svg`, `**/figures/**/*.svg`, `**/Figure/**/*.svg`, `**/figure/**/*.svg`
   - Root-level: `*.pdf`, `*.png`, `*.eps`, `*.jpg`, `*.jpeg`, `*.svg`
   - Exclude: `**/_minted-*/**`, `**/build/**`, `**/output/**`, `**/.git/**`
6. Use Glob to list table files: patterns covering common directories:
   - `**/Tables/**/*.tex`, `**/tables/**/*.tex`, `**/Table/**/*.tex`, `**/table/**/*.tex`
   - Root-level: `*table*.tex`, `*Table*.tex`
   - Exclude: `**/_minted-*/**`, `**/build/**`, `**/output/**`, `**/.git/**`

Record:
- Full path of each .tex file and its role in the paper
- List of figure file paths
- List of table file paths
- The paper title, authors, and abstract (from the main .tex file)

**If zero figure files are found**, warn the user: "No figure files were found in standard locations. If figures are stored in an `output/` or non-standard directory, re-run with an explicit file path or move files to a `Figures/` folder."

**If zero table files are found**, warn the user: "No table .tex files were found in standard locations. Tables may be stored in an `output/` or non-standard directory. Agent 5 will only be able to check table captions and cross-references from the main .tex files."

## Phase 2: Launch 6 Review Agents in Parallel

In a **single message**, launch all 6 agents using the Agent tool with `subagent_type: "general-purpose"`. Each agent reads the paper files independently. Pass the complete list of .tex file paths, figure paths, and table paths to each agent in its prompt. When constructing Agent 6's prompt, add the following line at the top: "The target journal is [resolved value of TARGET_JOURNAL]." Do not substitute the value into the body of the prompt — leave all conditional logic (e.g., "If TARGET_JOURNAL is top-field...") intact so Agent 6 can reason with it.

---

### AGENT 1 — Spelling, Grammar & Academic Style

You are a copy editor at a top economics journal. Read all .tex files in the following list and perform a thorough review. Ignore LaTeX commands (anything starting with `\`) unless they cause formatting issues. Focus on the actual prose.

**What to check:**

1. **Spelling errors**: Identify every misspelled word. Pay special attention to proper nouns (author names, place names), technical terms, and words commonly confused (affect/effect, principal/principle, complement/compliment).

2. **Grammar errors**: Subject-verb agreement, tense consistency (papers are written in present tense for findings, past tense for what was done), article usage (a/an/the), dangling modifiers, comma splices, run-on sentences, sentence fragments.

3. **Awkward or convoluted phrasing**: Sentences that require re-reading. Suggest clearer alternatives.

4. **Style violations** — flag every instance of:
   - "interestingly", "importantly", "notably", "it is worth noting", "it is important to note", "needless to say", "obviously", "clearly" — delete these; let the finding speak for itself
   - "very unique", "absolutely essential", "completely eliminate" — tautologies
   - "significant" used to mean large or important (reserve "significant" for statistical significance)
   - "This paper contributes to the literature by..." — show, don't tell
   - Passive voice where active is natural ("it is shown that" → "we show that")
   - Inconsistent first person ("we find" in some places, "the paper argues" in others)

5. **Typographic consistency**:
   - Hyphenation: is "long-run" vs "long run" used consistently? Is "high income" vs "high-income" (attributive vs predicative) applied correctly?
   - Em-dash vs en-dash vs hyphen used correctly
   - Spacing around punctuation

6. **Number formatting**: Are numbers below 10 spelled out in prose? Are percentages consistent (15% vs 15 percent)?

**Output format:**

Tag every individual issue with `[CRITICAL]`, `[MAJOR]`, or `[MINOR]` at the start of its line. Use `[CRITICAL]` for errors that must be fixed before submission, `[MAJOR]` for issues likely to be raised by a referee, and `[MINOR]` for polish.

```
## Agent 1: Spelling, Grammar & Style

### Critical Issues (must fix before submission)
[numbered list: [CRITICAL] Location | "Problematic text" → "Suggested correction" | Reason]

### Minor Issues
[numbered list: [MINOR] same format]

### Style Patterns to Fix Throughout
[list recurring style problems with one example each and a global fix instruction — tag each [MAJOR] or [MINOR]]
```

The .tex files to review are: [LIST ALL TEX FILE PATHS HERE]

---

### AGENT 2 — Internal Consistency & Cross-Reference Verification

You are a technical reviewer checking whether an economics paper is internally coherent. Read all .tex files and verify that the paper does not contradict itself and that all cross-references are correct.

**What to check:**

1. **Numerical consistency**: Every time a specific number appears in the text (coefficients, percentages, sample sizes, years), verify it matches the number in the referenced table (read the table .tex file directly). Flag discrepancies such as "text says 1.3% but Table 2 Column 3 shows 1.2%." Note: numbers embedded in figures (e.g., in a binscatter or coefficient plot) cannot be verified from source files — skip those and do not flag them.

2. **Abstract vs. body consistency**: Do numbers, findings, and claims in the abstract exactly match what appears in the main text and tables?

3. **Introduction vs. results consistency**: When the introduction previews results ("we find X"), verify that the results section delivers exactly that.

4. **Terminology consistency**: Identify every key term introduced in the paper and flag any inconsistency in usage or definition. A term defined one way in Section 2 should not mean something different in Section 5. Check, for example, whether the paper uses both "effect" and "impact" interchangeably when one has a specific technical meaning, or whether variable names shift across sections.

5. **Sample description consistency**: Does the stated sample (years, number of observations, filters) remain consistent across abstract, data section, and table notes?

6. **Fixed effects and controls consistency**: Do the fixed effects included in each specification match what the tables show and what the text claims?

7. **Magnitude consistency**: When the same finding is described in multiple places (abstract, introduction, conclusion, results), are the direction (positive/negative/higher/lower) and magnitude (1.3%, 14 cumulative percentage points, etc.) stated consistently?

8. **Literature citations**: For each in-text citation of an external finding (e.g., "Smith (2020) finds X"), verify that (a) the cited author and year appear in the reference list, and (b) the in-text characterization is not suspiciously strong or mismatched with what a paper of that type would plausibly show. Flag any citation where the author-year pair has no matching bibliography entry.

**Output format:**

Tag every individual issue with `[CRITICAL]`, `[MAJOR]`, or `[MINOR]` at the start of its line.

```
## Agent 2: Internal Consistency & Cross-Reference Verification

### Critical Inconsistencies
[numbered list: [CRITICAL] [Location 1] ↔ [Location 2] | What conflicts]

### Terminology Drift
[numbered list: [MAJOR] or [MINOR] Term | How it varies | Recommended standardization]

### Minor Inconsistencies
[numbered list: [MINOR] same format as Critical]
```

The .tex files to review are: [LIST ALL TEX FILE PATHS HERE]
Figure files: [LIST FIGURE PATHS]
Table files: [LIST TABLE PATHS]

---

### AGENT 3 — Unsupported Claims & Identification Integrity

You are a skeptical econometrician who enforces "claim discipline" — the principle that claims must never exceed what identification allows. Read all .tex files and identify every place where the paper overstates its evidence.

**What to check:**

1. **Causal language without causal identification**: Flag every specific sentence where causal language ("causes", "leads to", "drives", "determines", "because of", "due to", "results in") is applied to the main findings without genuine causal identification. Quote the exact sentence and explain why the language exceeds what the identification supports. Focus on text-level instances — do not evaluate the overall identification strategy (that is Agent 6's role). Distinguish between: (a) places where causal language is used but only correlation is shown, (b) places where mechanisms are described as established facts when they are hypotheses.

2. **Generalization beyond the sample**: Claims that extend findings beyond the data's scope (e.g., claiming broad policy implications based on a single country's data without explicit reasoning; claiming current relevance for historical results without caveats about how the context may have changed).

3. **Mechanism claims stated as facts**: When the paper offers an explanation for *why* a result holds, check whether that mechanism is treated as an established fact or appropriately framed as a hypothesis. Flag every instance where a proposed mechanism is asserted rather than argued.

4. **Missing necessary caveats**: Places where a reader would naturally ask "but what about...?" and the paper doesn't address it. Think of the most obvious threats to internal validity for the specific research design used — selection into the sample, reverse causality, measurement error, omitted variables — and flag wherever these are not discussed.

5. **Literature overclaiming**: "No prior study has examined X" or "We are the first to show Y" — these are strong claims that you cannot independently verify. Flag every such claim as an *unverified priority assertion* and note that the authors must confirm it is accurate before submission. Do not attempt to judge whether it is true.

6. **Statistical vs. economic significance conflation**: Places where statistical significance is reported but economic significance is not discussed, or where "statistically significant" is used as if it means "economically important."

7. **Hedging failures in both directions**:
   - **Overconfident**: Claims stated too strongly
   - **Underconfident**: Results that are strong but the paper hedges excessively

**Output format:**

Tag every individual issue with `[CRITICAL]`, `[MAJOR]`, or `[MINOR]` at the start of its line.

```
## Agent 3: Unsupported Claims & Identification Integrity

### Causal Overclaiming (must address)
[numbered list: [CRITICAL] or [MAJOR] [Section/paragraph] | "Exact quoted text" | Why it overclaims | Fix: weaken language OR add evidence]

### Generalization Issues
[numbered list: [MAJOR] or [MINOR] same format]

### Missing Caveats
[numbered list: [CRITICAL] or [MAJOR] Topic | Where it should be addressed | Suggested text]

### Minor Language Issues
[numbered list: [MINOR] same format]
```

The .tex files to review are: [LIST ALL TEX FILE PATHS HERE]

---

### AGENT 4 — Mathematics, Equations & Notation

You are a mathematical economist reviewing the formal content of an economics paper. Read all .tex files, focusing on equations, mathematical definitions, and formal derivations.

**What to check:**

1. **Mathematical correctness**:
   - Do derivations follow logically from stated assumptions?
   - Are there algebraic or arithmetic errors?
   - In regression specifications written out as equations, do the subscripts, superscripts, and terms match the verbal description?

2. **Notation consistency**:
   - Is the same symbol used for the same quantity throughout? List all symbols defined in the paper and flag any reuse.
   - Are subscripts consistent (e.g., is $i$ always an individual, $t$ always time, $g$ always a group)?
   - Are vectors and matrices distinguished from scalars?

3. **Undefined or ambiguous notation**:
   - Is every symbol defined at or before first use?
   - Are any symbols used without definition?

4. **Equation numbering and references**:
   - Are all equations referenced in the text actually numbered?
   - Are there numbered equations that are never referenced (consider removing)?
   - Are equation references correct (e.g., "equation (3)" refers to the right equation)?

5. **Regression specification consistency**:
   - Does the written regression equation match: (a) the verbal description in the text, (b) the column headers in the results tables, (c) the description of controls/fixed effects in the text?
   - Are all control variables mentioned in the text included in the equation? Are there variables in the equation not mentioned in the text?

6. **Return/growth rate definitions**:
   - Are annualization formulas correct? (e.g., $r = (P_1/P_0)^{1/h} - 1$ for holding period $h$)
   - Are percentage vs. percentage point distinctions maintained?
   - Are log approximations flagged when used?

7. **Statistical notation**:
   - Are standard error, t-statistic, and confidence interval formulas correct?
   - Is clustering notation correct and consistent with how the paper describes inference?

8. **LaTeX math formatting issues**:
   - Missing `\left` and `\right` for large brackets/parentheses
   - Improper use of `*` for multiplication (should use `\cdot` or `\times`)
   - Text in math mode not wrapped in `\text{}`
   - Alignment issues in multi-line equations

**Output format:**

Tag every individual issue with `[CRITICAL]`, `[MAJOR]`, or `[MINOR]` at the start of its line.

```
## Agent 4: Mathematics, Equations & Notation

### Mathematical Errors
[numbered list: [CRITICAL] or [MAJOR] Equation/Location | Error description | Correction]

### Notation Inconsistencies
[numbered list: [MAJOR] or [MINOR] Symbol | Used for X in [location], used for Y in [location] | Resolution]

### Undefined Notation
[numbered list: [MAJOR] or [MINOR] Symbol | First used at [location] | Where to add definition]

### Regression Specification Issues
[numbered list: [CRITICAL] or [MAJOR] Table/Specification | Discrepancy between equation, text, and table]

### LaTeX Math Formatting
[numbered list: [MINOR] Location | Issue | Fix]
```

The .tex files to review are: [LIST ALL TEX FILE PATHS HERE]

---

### AGENT 5 — Tables, Figures & Their Documentation

You are a journal production editor reviewing whether every table and figure in an economics paper is complete, self-contained, and correctly described. Read all .tex files.

**Important**: Figure files (PDF, PNG, EPS, JPG) cannot be read directly. Base all figure checks on what is available in the LaTeX source: captions, notes, labels, and any descriptive text in the `.tex` files. If a figure's `.tex` source provides insufficient information to assess completeness (e.g., no notes block at all), flag that explicitly rather than skipping it.

**For every table, check:**

1. **Title/caption**: Does it accurately and fully describe what the table contains? Can a reader understand the table without reading the body of the paper?

2. **Column headers**: Are they clear, unambiguous, and complete? Do they state the dependent variable and key specification differences?

3. **Notes completeness** — every table needs notes covering:
   - Sample definition (what observations are included, time period, any restrictions)
   - Dependent variable definition and units
   - What controls are included (or "No controls", "Controls as in Table X")
   - Which fixed effects are included
   - How standard errors are computed (clustered? at what level?)
   - Definition of significance stars (e.g., *** p<0.01, ** p<0.05, * p<0.10)
   - Whether the table reports standard errors, t-statistics, or something else

4. **Standard errors**: Are they reported in every column? Is it clear they are standard errors (not t-stats or confidence intervals)?

5. **Observations**: Is N reported in every column? If columns use different samples, is this clear?

6. **Cross-referencing**: Is every table referenced at least once in the main text? Are there tables defined but never cited? For every in-text reference ("as shown in Table X", "see Table Y"), verify the referenced table exists and actually shows what is claimed.

7. **Formatting consistency**: Do all tables use consistent notation for fixed effects indicators (e.g., "Yes/No" vs checkmarks vs "✓")?

**For every figure, check:**

1. **Title/caption**: Does it describe what is shown? Is it self-contained?

2. **Axis labels**: Are both axes labeled? Are units included?

3. **Legend**: If multiple series or colors, is there a legend?

4. **Confidence intervals**:
   - Binscatter plots: are confidence intervals shown?
   - Coefficient plots: are confidence intervals shown?
   - Event study plots: are confidence intervals shown?

5. **Notes completeness** — every figure needs notes covering:
   - Sample used
   - What is plotted (raw data? residuals after controls?)
   - For binscatters: number of bins, whether controls are absorbed, what the dots represent
   - For coefficient plots: what the point estimates and intervals represent
   - Data source

6. **Cross-referencing**: Is every figure referenced in the main text? Any figures defined but never cited? For every in-text reference ("as shown in Figure X", "see Figure Y"), verify the referenced figure exists and actually shows what is claimed.

**Cross-paper consistency:**
- Are figure and table styles (fonts, line widths, colors) consistent throughout?
- Are table formatting conventions (decimal places, significance stars) applied consistently?

**Output format:**

Tag every individual issue with `[CRITICAL]`, `[MAJOR]`, or `[MINOR]` at the start of its line.

```
## Agent 5: Tables, Figures & Documentation

### Tables with Missing or Incomplete Notes
[organized by table number: [MAJOR] or [MINOR] Table X | Missing element | Suggested addition]

### Figures with Missing or Incomplete Notes
[organized by figure number: [MAJOR] or [MINOR] Figure X | Missing element | Suggested addition]

### Cross-Reference Issues
[list: [CRITICAL] or [MAJOR] Element | Issue (unreferenced? wrong reference? missing?)]

### Formatting Inconsistencies
[list: [MINOR] Issue | Where it occurs | Standardization recommendation]
```

The .tex files to review are: [LIST ALL TEX FILE PATHS HERE]
Figure files: [LIST FIGURE PATHS]
Table files: [LIST TABLE PATHS]

---

### AGENT 6 — Contribution Evaluation (Adversarial Top-5 Referee)

You are a demanding associate editor. Adopt the persona and editorial norms appropriate to `TARGET_JOURNAL`:
- If it is a specific journal (e.g., AER, QJE, JPE, Econometrica, REStud, JF, JFE, RFS, JFQA, AEJMacro, JME, RED), apply that journal's scope, style preferences, and standards for what constitutes a publishable contribution — including its typical methodological bar, preferred framing, and audience expectations.
- If `TARGET_JOURNAL` is `top-field`, apply high general standards for a leading field journal without a specific journal persona.

In all cases: you have read thousands of papers and have extremely high standards. You are deciding whether this paper deserves to be sent to referees, or whether it should be desk rejected. You are not hostile, but you are exacting, specific, and rigorous. You will read the complete paper and produce a structured evaluation.

Read all .tex files completely and thoroughly.

**Your evaluation has 7 parts:**

**Part 1 — The Central Contribution**

State in one sentence what the paper claims to contribute. Then evaluate:
- Is this finding genuinely new, or is it a replication of known results in a new setting?
- What is the closest prior paper? What does this paper add beyond that paper?
- Does the paper answer a question that reasonable economists disagree about, or that the profession needs answered?
- Does this finding change how economists think about the paper's central topic?
- Rate the contribution: [Transformative | Significant | Incremental | Insufficient for target journal]
- Justify your rating in 2-3 sentences.

**Part 2 — Identification and Credibility**

Evaluate the overall identification strategy — not individual sentences with causal language (that is Agent 3's role). Focus on the research design as a whole.

- What variation does the paper use to identify its main result?
- Is this variation plausibly exogenous? What are the main threats?
- Does the paper adequately address these threats, or does it paper over them?
- Is the main finding causal, correlational, or descriptive? Does the paper claim the right thing?
- Specific weaknesses: What would a skeptical econometrician at a seminar say?
- What would it take to make the identification convincing to a top-5 audience?

**Part 3 — Analyses: Required and Suggested**

**Required analyses** (up to 5 you would require before recommending acceptance — their absence is a blocker; if none are missing, write "None — the paper adequately addresses the main identification concerns"):
- Robustness checks not performed — including any robustness checks the paper claims to have done but that do not actually appear
- Alternative explanations not ruled out
- Placebo or falsification tests that are missing
For each: state what the analysis is, why its absence undermines the paper's credibility, and what a positive result would do for your view.

**Suggested analyses** (up to 5 that would substantially strengthen the paper but are not hard requirements):
- Mechanism tests that are missing
- Subgroup analyses that would enrich the findings
- Extensions that would broaden the contribution
For each: describe the analysis precisely, explain why it matters, and assess whether it is feasible given the data sources described in the paper.

**Part 4 — Literature Positioning**

- Does the paper cite the right papers? Are there obvious relevant papers missing?
- Does the paper adequately distinguish itself from closely related work?
- Is the paper over-citing minor papers and under-citing major ones?
- Is the framing in the introduction the most compelling way to position this paper, or is there a better framing?

**Part 5 — Journal Fit and Recommendation**

- If `TARGET_JOURNAL` is a specific journal: Is this paper a strong fit for `TARGET_JOURNAL` given its scope, methods, and level of contribution? Identify any fit risks (wrong audience, wrong methods bar, topic outside scope).
- If `TARGET_JOURNAL` is `top-field`: Which specific journals are the best realistic targets for this paper, and why?
- What is your preliminary recommendation: [Send to referees | Revise before sending to referees | Desk reject]
- What would it take, concretely, to reach the standard required by the target journal?
- What is the best realistic alternative outlet if the paper is not accepted at the target journal?

**Part 6 — Pointed Questions to the Authors**

Write 4–7 specific, pointed questions that you would send to the authors as a referee. These should be the hard questions — the ones that get at the paper's weakest points. Frame them exactly as a referee would in a report.

**Output format:**

Tag every Required analysis with `[CRITICAL]` and every Suggested analysis with `[MAJOR]`.

```
## Agent 6: Contribution Evaluation

### Part 1 — Central Contribution
[assessment + rating]

### Part 2 — Identification and Credibility
[assessment]

### Part 3 — Analyses: Required and Suggested
**Required:**
[numbered list: [CRITICAL] analysis | why absence undermines credibility | what a positive result would do]

**Suggested:**
[numbered list: [MAJOR] analysis | why it matters | feasibility]

### Part 4 — Literature Positioning
[assessment]

### Part 5 — Journal Fit and Recommendation
[recommendation + path to improvement]

### Part 6 — Questions to the Authors
[numbered list of 4–7 questions, formatted as a referee would write them]
```

The .tex files to review are: [LIST ALL TEX FILE PATHS HERE]

---

## Phase 3: Consolidate and Save

**Before consolidating**, check for agent failures: if any agent returned no output or clearly malformed output, insert a placeholder section in the report (e.g., "## 4. Mathematics, Equations & Notation — Agent did not return output") and include it in the final user-facing summary.

After all available agent results are collected, consolidate them into a single structured report.

**Before saving**, check whether `PRE_SUBMISSION_REVIEW_[YYYY-MM-DD].md` already exists in the current directory. If it does, append `-v2` (or `-v3`, etc.) to avoid overwriting.

Save the report to:

`PRE_SUBMISSION_REVIEW_[YYYY-MM-DD].md`

where `[YYYY-MM-DD]` is today's date.

**Report structure:**

```markdown
# Pre-Submission Referee Report

**Paper**: [Title]
**Authors**: [Authors]
**Date**: [Today's date]
**Review Standard**: [TARGET_JOURNAL — if top-field, write "Leading Field Journal"; otherwise write the specific journal name]

---

## Overall Assessment

[3–4 sentences synthesized as follows: (1) what the paper does — from Agent 6 Part 1; (2) its principal strength — from Agent 6 Part 1 contribution rating; (3) the single most critical issue — the top CRITICAL item from the Priority Action Items list below. Do not introduce judgments not already present in the agent outputs.]

**Preliminary Recommendation**: [Copy exactly from Agent 6 Part 5 — do not paraphrase]

---

## 1. Contribution & Referee Assessment

[Agent 6 output]

---

## 2. Unsupported Claims & Identification Integrity

[Agent 3 output]

---

## 3. Internal Consistency & Cross-Reference Verification

[Agent 2 output]

---

## 4. Mathematics, Equations & Notation

[Agent 4 output]

---

## 5. Tables, Figures & Documentation

[Agent 5 output]

---

## 6. Spelling, Grammar & Style

[Agent 1 output, preserving its structure]

---

## Priority Action Items

Each agent has tagged its findings as `[CRITICAL]`, `[MAJOR]`, or `[MINOR]`. Collect all tagged items across agents and rank them here using the following triage hierarchy: `[CRITICAL]` items from Agent 3 and Agent 6 Part 2 first, then `[CRITICAL]` from Agent 6 Part 3, then remaining `[CRITICAL]` items by agent order, then all `[MAJOR]` items, then `[MINOR]` items.

**CRITICAL** (must fix — these could cause desk rejection or major referee objections):
1. ...
2. ...
3. ...

**MAJOR** (should fix — will likely be raised by referees):
4. ...
5. ...
6. ...
7. ...

**MINOR** (polish — improves paper quality):
8. ...
9. ...
10. ...
```

After saving, report to the user:
1. The path to the saved report
2. The preliminary recommendation from Agent 6
3. The top 5 priority action items
4. How many issues were flagged in each category (counts)
