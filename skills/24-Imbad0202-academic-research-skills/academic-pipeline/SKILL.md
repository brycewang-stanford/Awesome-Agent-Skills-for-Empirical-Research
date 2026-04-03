---
name: academic-pipeline
description: "Orchestrator for the full academic research pipeline: research -> write -> integrity check -> review -> revise -> re-review -> re-revise -> final integrity check -> finalize. Coordinates deep-research, academic-paper, and academic-paper-reviewer into a seamless 9-stage workflow with mandatory integrity verification, two-stage peer review, and reproducible quality gates. Triggers on: academic pipeline, research to paper, full paper workflow, paper pipeline, end-to-end paper, research-to-publication, complete paper workflow."
metadata:
  version: "2.7"
  last_updated: "2026-03-27"
  depends_on: "deep-research, academic-paper, academic-paper-reviewer"
---

# Academic Pipeline v2.7 — Full Academic Research Workflow Orchestrator

A lightweight orchestrator that manages the complete academic pipeline from research exploration to final manuscript. It does not perform substantive work — it only detects stages, recommends modes, dispatches skills, manages transitions, and tracks state.

**v2.0 Core Improvements**:
1. **Mandatory user confirmation checkpoints** — Each stage completion requires user confirmation before proceeding to the next step
2. **Academic integrity verification** — After paper completion and before review submission, 100% reference and data verification must pass
3. **Two-stage review** — First full review + post-revision focused verification review
4. **Final integrity check** — After revision completion, re-verify all citations and data are 100% correct
5. **Reproducible** — Standardized workflow producing consistent quality assurance each time
6. **Process documentation** — After pipeline completion, automatically generates a "Paper Creation Process Record" PDF documenting the human-AI collaboration history

## Quick Start

**Full workflow (from scratch):**
```
I want to write a research paper on the impact of AI on higher education quality assurance
```
--> academic-pipeline launches, starting from Stage 1 (RESEARCH)

**Mid-entry (existing paper):**
```
I already have a paper, help me review it
```
--> academic-pipeline detects mid-entry, starting from Stage 2.5 (INTEGRITY)

**Revision mode (received reviewer feedback):**
```
I received reviewer comments, help me revise
```
--> academic-pipeline detects, starting from Stage 4 (REVISE)

**Execution flow:**
1. Detect the user's current stage and available materials
2. Recommend the optimal mode for each stage
3. Dispatch the corresponding skill for each stage
4. **After each stage completion, proactively prompt and wait for user confirmation**
5. Track progress throughout; Pipeline Status Dashboard available at any time

---

## Trigger Conditions

### Trigger Keywords

**English**: academic pipeline, research to paper, full paper workflow, paper pipeline, end-to-end paper, research-to-publication, complete paper workflow

### Non-Trigger Scenarios

| Scenario | Skill to Use |
|----------|-------------|
| Only need to search materials or do a literature review | `deep-research` |
| Only need to write a paper (no research phase needed) | `academic-paper` |
| Only need to review a paper | `academic-paper-reviewer` |
| Only need to check citation format | `academic-paper` (citation-check mode) |
| Only need to convert paper format | `academic-paper` (format-convert mode) |

### Trigger Exclusions

- If the user only needs a single function (just search materials, just check citations), no pipeline is needed — directly trigger the corresponding skill
- If the user is already using a specific mode of a skill, do not force them into the pipeline
- The pipeline is optional, not mandatory

---

## Pipeline Stages (10 Stages)

| Stage | Name | Skill / Agent Called | Available Modes | Deliverables |
|-------|------|---------------------|----------------|-------------|
| 1 | RESEARCH | `deep-research` | socratic, full, quick | RQ Brief, Methodology, Bibliography, Synthesis |
| 2 | WRITE | `academic-paper` | plan, full | Paper Draft |
| **2.5** | **INTEGRITY** | **`integrity_verification_agent`** | **pre-review** | **Integrity verification report + corrected paper** |
| 3 | REVIEW | `academic-paper-reviewer` | full (incl. Devil's Advocate) | 5 review reports + Editorial Decision + Revision Roadmap |
| 4 | REVISE | `academic-paper` | revision | Revised Draft, Response to Reviewers |
| **3'** | **RE-REVIEW** | **`academic-paper-reviewer`** | **re-review** | **Verification review report: revision response checklist + residual issues** |
| **4'** | **RE-REVISE** | **`academic-paper`** | **revision** | **Second revised draft (if needed)** |
| **4.5** | **FINAL INTEGRITY** | **`integrity_verification_agent`** | **final-check** | **Final verification report (must achieve 100% pass to proceed)** |
| 5 | FINALIZE | `academic-paper` | format-convert | Final Paper (default MD + DOCX; ask about LaTeX; confirm correctness; PDF) |
| **6** | **PROCESS SUMMARY** | **orchestrator** | **auto** | **Paper creation process record MD + LaTeX to PDF (bilingual)** |

---

## Pipeline State Machine

1. **Stage 1 RESEARCH** -> user confirmation -> Stage 2
2. **Stage 2 WRITE** -> user confirmation -> Stage 2.5
3. **Stage 2.5 INTEGRITY** -> PASS -> Stage 3 (FAIL -> fix and re-verify, max 3 rounds)
4. **Stage 3 REVIEW** -> Accept -> Stage 4.5 / Minor|Major -> Stage 4 / Reject -> Stage 2 or end
5. **Stage 4 REVISE** -> user confirmation -> Stage 3'
6. **Stage 3' RE-REVIEW** -> Accept|Minor -> Stage 4.5 / Major -> Stage 4'
7. **Stage 4' RE-REVISE** -> user confirmation -> Stage 4.5 (no return to review)
8. **Stage 4.5 FINAL INTEGRITY** -> PASS (zero issues) -> Stage 5 (FAIL -> fix and re-verify)
9. **Stage 5 FINALIZE** -> MD + DOCX -> ask about LaTeX -> confirm -> PDF -> Stage 6
10. **Stage 6 PROCESS SUMMARY** -> ask language version -> generate process record MD -> LaTeX -> PDF -> end

See `references/pipeline_state_machine.md` for complete state transition definitions.

---

## Adaptive Checkpoint System

**Core rule: After each stage completion, the system must proactively prompt the user and wait for confirmation. The checkpoint presentation adapts based on context and user engagement.**

### Checkpoint Types

| Type | When Used | Content |
|------|-----------|---------|
| FULL | First checkpoint; after integrity boundaries; before finalization | Full deliverables list + decision dashboard + all options |
| SLIM | After 2+ consecutive "continue" responses on non-critical stages | One-line status + auto-continue in 5 seconds |
| MANDATORY | Integrity FAIL; Review decision; Stage 5 | Cannot be skipped; requires explicit user input |

### Decision Dashboard (shown at FULL checkpoints)

```
━━━ Stage [X] [Name] Complete ━━━

Metrics:
- Word count: [N] (target: [T] +/-10%)    [OK/OVER/UNDER]
- References: [N] (min: [M])              [OK/LOW]
- Coverage: [N]/[T] sections drafted       [COMPLETE/PARTIAL]
- Quality indicators: [score if available]

Deliverables:
- [Material 1]
- [Material 2]

Flagged: [any issues detected, or "None"]

Ready to proceed to Stage [Y]? You can also:
1. View progress (say "status")
2. Adjust settings
3. Pause pipeline
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Adaptive Rules

1. **First checkpoint**: always FULL
2. **After 2+ consecutive "continue" without review**: prompt user awareness ("You've auto-continued [N] times. Want to review progress?")
3. **Integrity boundaries (Stage 2.5, 4.5)**: always MANDATORY
4. **Review decisions (Stage 3, 3')**: always MANDATORY
5. **Before finalization (Stage 5)**: always MANDATORY
6. **All other stages**: start FULL, downgrade to SLIM if user says "just continue"

### Checkpoint Rules

1. **Cannot auto-skip MANDATORY checkpoints**: Even if the previous stage result is perfect, explicit user input is required at MANDATORY checkpoints
2. **User can adjust**: At FULL and MANDATORY checkpoints, users can modify the mode or settings for the next step
3. **Pause-friendly**: Users can pause at any checkpoint and resume later
4. **SLIM mode**: If the user says "just continue" or "fully automatic," subsequent non-critical checkpoints switch to SLIM format (one-line status + auto-continue), but notifications are still sent
5. **Awareness guard**: After 4+ consecutive auto-continues, the system inserts a FULL checkpoint regardless of stage type to ensure user remains engaged

---

## Agent Team (3 Agents)

| # | Agent | Role | File |
|---|-------|------|------|
| 1 | `pipeline_orchestrator_agent` | Main orchestrator: detects stage, recommends mode, triggers skill, manages transitions | `agents/pipeline_orchestrator_agent.md` |
| 2 | `state_tracker_agent` | State tracker: records completed stages, produced materials, revision loop count | `agents/state_tracker_agent.md` |
| 3 | `integrity_verification_agent` | Integrity verifier: 100% reference/citation/data verification | `agents/integrity_verification_agent.md` |

---

## Orchestrator Workflow

### Step 1: INTAKE & DETECTION

```
pipeline_orchestrator_agent analyzes the user's input:

1. What materials does the user have?
   - No materials           --> Stage 1 (RESEARCH)
   - Has research data      --> Stage 2 (WRITE)
   - Has paper draft        --> Stage 2.5 (INTEGRITY)
   - Has verified paper     --> Stage 3 (REVIEW)
   - Has review comments    --> Stage 4 (REVISE)
   - Has revised draft      --> Stage 3' (RE-REVIEW)
   - Has final draft for formatting --> Stage 5 (FINALIZE)

2. What is the user's goal?
   - Full workflow (research to publication)
   - Partial workflow (only certain stages needed)

3. Determine entry point, confirm with user
```

### Step 2: MODE RECOMMENDATION

```
Based on entry point and user preferences, recommend modes for each stage:

User type determination:
- Novice / wants guidance --> socratic (Stage 1) + plan (Stage 2) + guided (Stage 3)
- Experienced / wants direct output --> full (Stage 1) + full (Stage 2) + full (Stage 3)
- Time-limited --> quick (Stage 1) + full (Stage 2) + quick (Stage 3)

Explain the differences between modes when recommending, letting the user choose
```

### Step 3: STAGE EXECUTION

```
Call the corresponding skill (does not do work itself, purely dispatching):

1. Inform the user which Stage is about to begin
2. Load the corresponding skill's SKILL.md
3. Launch the skill with the recommended mode
4. Monitor stage completion status

After completion:
1. Compile deliverables list
2. Update pipeline state (call state_tracker_agent)
3. [MANDATORY] Proactively prompt checkpoint, wait for user confirmation
```

### Step 4: TRANSITION

```
After user confirmation:

1. Pass the previous stage's deliverables as input to the next stage
2. Trigger handoff protocol (defined in each skill's SKILL.md):
   - Stage 1  --> 2: deep-research handoff (RQ Brief + Bibliography + Synthesis)
   - Stage 2  --> 2.5: Pass complete paper to integrity_verification_agent
   - Stage 2.5 --> 3: Pass verified paper to reviewer
   - Stage 3  --> 4: Pass Revision Roadmap to academic-paper revision mode
   - Stage 4  --> 3': Pass revised draft and Response to Reviewers to reviewer
   - Stage 3' --> 4': Pass new Revision Roadmap to academic-paper revision mode
   - Stage 4/4' --> 4.5: Pass revision-completed paper to integrity_verification_agent (final verification)
   - Stage 4.5 --> 5: Pass verified final draft to format-convert mode
3. Begin next stage
```

---

## Integrity Review Protocol (Added in v2.0)

### Stage 2.5: First Integrity Check (Pre-Review Integrity)

**Trigger**: After Stage 2 (WRITE) completion, before Stage 3 (REVIEW)
**Purpose**: Ensure all references and data are not fabricated or erroneous before submission for review

```
Execution steps:
1. integrity_verification_agent executes Mode 1 (initial verification) on the paper
2. Verification scope:
   - Phase A: 100% reference existence + bibliographic accuracy + ghost citations
   - Phase B: >= 30% citation context spot-check
   - Phase C: 100% statistical data verification
   - Phase D: >= 30% originality spot-check + self-plagiarism check
   - Phase E: 30% claim verification spot-check (minimum 10 claims)
3. Result handling:
   - PASS -> checkpoint -> Stage 3
   - FAIL -> produce correction list -> fix item by item -> re-verify corrected items
   - PASS after corrections -> checkpoint -> Stage 3
   - Still FAIL after 3 rounds -> notify user, list unverifiable items
```

### Stage 4.5: Final Integrity Check (Post-Revision Final Check)

**Trigger**: After Stage 4' (RE-REVISE) or Stage 3' (RE-REVIEW, Accept) completion, before Stage 5 (FINALIZE)
**Purpose**: Confirm the revised paper is 100% correct and ready for publication

```
Execution steps:
1. integrity_verification_agent executes Mode 2 (final verification) on the revised draft
2. Verification scope:
   - Phase A: 100% reference verification (including those added during revision)
   - Phase B: 100% citation context verification (not spot-check, full check)
   - Phase C: 100% statistical data verification
   - Phase D: >= 50% originality spot-check (100% for newly added/modified paragraphs)
   - Phase E: 100% claim verification (zero MAJOR_DISTORTION + zero UNVERIFIABLE required)
3. Special check: Compare with Stage 2.5 results to confirm all previous issues are resolved
4. Result handling:
   - PASS (zero issues) -> checkpoint -> Stage 5
   - FAIL -> fix -> re-verify -> PASS -> Stage 5
5. **Must PASS with zero issues to proceed to Stage 5**
```

---

## Two-Stage Review Protocol (Added in v2.0)

### Stage 3: First Review (Full Review)

- **Input**: Paper that passed integrity check
- **Review team**: EIC + R1 (methodology) + R2 (domain) + R3 (interdisciplinary) + Devil's Advocate
- **Output**: 5 review reports + Editorial Decision + Revision Roadmap + Socratic Revision Coaching
- **Decision branches**: Accept -> Stage 4.5 / Minor|Major -> Revision Coaching -> Stage 4 / Reject -> Stage 2 or end

See `academic-paper-reviewer/SKILL.md` for review process details.

### Stage 3 -> 4 Transition: Revision Coaching

EIC uses Socratic dialogue to guide the user in understanding review comments and planning revision strategy (max 8 rounds). User can say "just fix it for me" to skip.

### Stage 3': Second Review (Verification Review)

- **Input**: Revised draft + Response to Reviewers + original Revision Roadmap
- **Mode**: `academic-paper-reviewer` re-review mode
- **Output**: Revision response comparison table + new issues list + new Editorial Decision
- **Decision branches**: Accept|Minor -> Stage 4.5 / Major -> Residual Coaching -> Stage 4'

See `academic-paper-reviewer/SKILL.md` Re-Review Mode for verification review process.

### Stage 3' -> 4' Transition: Residual Coaching

EIC guides the user in understanding residual issues and making trade-offs (max 5 rounds). User can say "just fix it" to skip.

---

## Mid-Entry Protocol

Users can enter from any stage. The orchestrator will:

1. **Detect materials**: Analyze the content provided by the user to determine what is available
2. **Identify gaps**: Check what prerequisite materials are needed for the target stage
3. **Suggest backfilling**: If critical materials are missing, suggest whether to return to earlier stages
4. **Direct entry**: If materials are sufficient, directly start the specified stage

**Important: mid-entry cannot skip Stage 2.5**
- If the user brings a paper and enters directly, go through Stage 2.5 (INTEGRITY) first before Stage 3 (REVIEW)
- Only exception: User can provide a previous integrity verification report and content has not been modified

---

## External Review Protocol (Added in v2.5)

**Scenario**: The user submitted to a journal and received feedback from real human reviewers, bringing those comments into the pipeline.

**Trigger**: User says "I received reviewer comments," "reviewer comments," "revise and resubmit," etc.

### Differences from Internal Review

| Aspect | Internal Review (Stage 3 simulation) | External Review (real journal) |
|--------|-------------------------------------|-------------------------------|
| Source of review comments | Pipeline's AI reviewers | Journal's human reviewers |
| Comment format | Structured (Revision Roadmap) | Unstructured (free text, PDF, email) |
| Comment quality | Consistent, predictable | Variable quality, may be vague or contradictory |
| Revision strategy | Can accept wholesale | Need to judge which to accept/reject/negotiate |
| Acceptance criteria | AI re-review suffices | Ultimately decided by human reviewers |

### Step 1: Intake and Structuring

```
1. Receive reviewer comments (supported formats):
   - Directly pasted text
   - Provide PDF/DOCX file path
   - Copy from journal system review letter

2. Parse into structured list:
   For each comment, extract:
   - Reviewer number (Reviewer 1/2/3 or R1/R2/R3)
   - Comment type: Major / Minor / Editorial / Positive
   - Core request (one-sentence summary)
   - Original text quote
   - Paper section involved

3. Produce External Review Summary:
   +----------------------------------------+
   | External Review Summary                |
   +----------------------------------------+
   | Journal: [journal name]                |
   | Decision: [R&R / Major / Minor]        |
   | Reviewers: [N]                         |
   | Total comments: [N]                    |
   |   Major: [n]  Minor: [n]  Editorial: [n]|
   +----------------------------------------+

4. Confirm parsing results with user:
   "I organized the reviewer comments into [N] items. Here is the summary — please confirm nothing was missed or misinterpreted."
```

### Step 2: Strategic Revision Coaching (External Revision Coaching)

Unlike the Socratic coaching for internal review, external review coaching focuses more on **strategic judgment**:

```
For each Major comment, guide the user to think through:

1. Understanding layer
   "What is this reviewer's core concern? Is it about methodology, theory, or presentation?"

2. Judgment layer
   "Do you agree with this criticism?"
   - Agree -> "How do you plan to revise?"
   - Partially agree -> "Which parts do you agree with and which not? What is your basis for disagreement?"
   - Disagree -> "What is your rebuttal argument? Can you support it with literature or data?"

3. Strategy layer
   "How will you phrase this in the response letter?"
   - Accept revision: Show specifically what was changed and where
   - Partially accept: Explain the accepted parts + reasons for non-acceptance (must be persuasive)
   - Reject: Provide sufficient scholarly rationale (literature, data, methodological argumentation)

4. Risk assessment
   "If you reject this suggestion, what might the reviewer's reaction be? Is it worth the risk?"
```

**Key principles**:
- **Do not default to "accept all"**: Real reviewer comments are not always correct — some may be based on misunderstanding or school-of-thought bias
- **Encourage user to inject context**: "What school of thought do you think this reviewer might come from? What context might they not be aware of?"
- **User can say "just fix it for me" to skip**: But when skipping strategic discussion, AI defaults to accepting all comments (conservative strategy)
- **Maximum 8 rounds of dialogue**, but at least 1 round per Major comment

### Step 3: Revision and Response to Reviewers

```
Produce two documents:

1. Revised draft
   - Track all modification locations (additions/deletions/rewrites)
   - Revision content consistent with Response to Reviewers

2. Response to Reviewers letter
   Format (point-by-point response):
   +------------------------------------+
   | Reviewer [N], Comment [M]:         |
   |                                    |
   | [Original comment quote]           |
   |                                    |
   | Response:                          |
   | [Response explanation]             |
   |                                    |
   | Changes made:                      |
   | [Specific modification location    |
   |  and content]                      |
   | (or: We respectfully disagree      |
   |  because... [rationale])           |
   +------------------------------------+
```

### Step 4: Self-Verification (Completeness Check)

```
Stage 3' behavior adjustments in external review mode:

1. Point-by-point comparison of External Review Summary with Response to Reviewers:
   - Does every comment have a response? (completeness)
   - Is each response consistent with actual changes? (consistency)
   - Were the places claimed as "modified" actually changed? (truthfulness)

2. New citation verification:
   - New references added during revision enter Stage 4.5 integrity verification

3. Things NOT done (different from internal review):
   - Do not reassess paper quality (that is the human reviewers' job)
   - Do not issue a new Editorial Decision
   - Do not raise new revision requests
```

### Honest Capability Boundaries

1. **AI verification does not equal human reviewer satisfaction**: Stage 3' can confirm revisions are "complete and consistent," but cannot predict whether human reviewers will accept your responses. Reviewers may have unstated expectations, school-of-thought preferences, or methodological insistence
2. **Unstructured comments may not parse perfectly**: Some reviewers write vaguely (e.g., "the methodology needs more work"), and AI will do its best to parse but may miss implied intentions. After parsing, **user confirmation is mandatory**
3. **AI cannot make scholarly judgments for you**: "Should I accept Reviewer 2's suggestion?" is your decision. AI can provide an analytical framework, but final judgment rests with the researcher
4. **Cross-cultural review convention differences**: Response conventions differ across journals/academic circles (some require extreme deference, others accept direct rebuttal). AI defaults to neutral academic tone; the user can request adjustments

---

## Progress Dashboard

Users can say "status" or "pipeline status" at any time to view:

```
+=============================================+
|   Academic Pipeline v2.0 Status             |
+=============================================+
| Topic: Impact of AI on Higher Education     |
|        Quality Assurance                    |
+---------------------------------------------+

  Stage 1   RESEARCH          [v] Completed
  Stage 2   WRITE             [v] Completed
  Stage 2.5 INTEGRITY         [v] PASS (62/62 refs verified)
  Stage 3   REVIEW (1st)      [v] Major Revision (5 items)
  Stage 4   REVISE            [v] Completed (5/5 addressed)
  Stage 3'  RE-REVIEW (2nd)   [v] Accept
  Stage 4'  RE-REVISE         [-] Skipped (Accept)
  Stage 4.5 FINAL INTEGRITY   [..] In Progress
  Stage 5   FINALIZE          [ ] Pending
  Stage 6   PROCESS SUMMARY   [ ] Pending

+---------------------------------------------+
| Integrity Verification:                     |
|   Pre-review:  PASS (0 issues)              |
|   Final:       In progress...               |
+---------------------------------------------+
| Review History:                             |
|   Round 1: Major Revision (5 required)      |
|   Round 2: Accept                           |
+=============================================+
```

See `templates/pipeline_status_template.md` for the output template.

---

## Revision Loop Management

- Stage 3 (first review) -> Stage 4 (revision) -> Stage 3' (verification review) -> Stage 4' (re-revision, if needed) -> Stage 4.5 (final verification)
- **Maximum 1 round of RE-REVISE** (Stage 4'): If Stage 3' gives Major, enter Stage 4' for revision then proceed directly to Stage 4.5 (no return to review)
- **Pipeline overrides academic-paper's max 2 revision rule**: In the pipeline, revisions are limited to Stage 4 + Stage 4' (one round each), replacing academic-paper's max 2 rounds rule
- Mark unresolved issues as Acknowledged Limitations
- Provide cumulative revision history (each round's decision, items addressed, unresolved items)

---

## Reproducibility

v2.0 design ensures consistent quality assurance with each execution:

### Standardized Workflow

| Guarantee Item | Mechanism |
|---------------|-----------|
| Integrity check every time | Stage 2.5 + Stage 4.5 are **mandatory** stages, cannot be skipped |
| Consistent review angles | EIC + R1/R2/R3 + Devil's Advocate — five fixed perspectives |
| Consistent verification methods | integrity_verification_agent uses standardized search templates |
| Consistent quality thresholds | Integrity check PASS/FAIL criteria are explicit (zero SERIOUS + zero MEDIUM + zero MAJOR_DISTORTION + zero UNVERIFIABLE) |
| Traceable workflow | Every stage's deliverables are recorded, enabling retrospective audit |

### Audit Trail

When the pipeline ends, state_tracker_agent produces a complete audit trail:

```
Pipeline Audit Trail
====================
Topic: [topic]
Started: [time]
Completed: [time]
Total Stages: [X/9]

Stage 1 RESEARCH: [mode] -> [output count]
Stage 2 WRITE: [mode] -> [word count]
Stage 2.5 INTEGRITY: [PASS/FAIL] -> [refs verified] / [issues found -> fixed]
Stage 3 REVIEW: [decision] -> [items count]
Stage 4 REVISE: [items addressed / total]
Stage 3' RE-REVIEW: [decision]
Stage 4' RE-REVISE: [executed / skipped]
Stage 4.5 FINAL INTEGRITY: [PASS/FAIL] -> [refs verified]
Stage 5 FINALIZE: Ask format style -> MD + DOCX + LaTeX (apa7/ieee/etc.) -> tectonic -> PDF
Stage 6 PROCESS SUMMARY: Ask language -> MD -> LaTeX -> PDF (zh/en)

Integrity Summary:
  Pre-review: [X] refs checked, [Y] issues found, [Y] fixed
  Final: [X] refs checked, [Y] issues found, [Y] fixed
  Overall: [CLEAN / ISSUES NOTED]
```

---

## Stage 6: Process Summary Protocol (Added in v2.4)

**Trigger**: After Stage 5 (FINALIZE) completion
**Purpose**: Document the complete human-AI collaboration history for the paper creation process, for user sharing, reporting, or reflection

### Workflow

```
1. Ask user language preference:
   "Which language version of the process record would you like to generate first?"
   - Chinese (Traditional Chinese)
   - English
   - Both (default: generate the user's primary conversation language first)

2. Review session history and compile the following:
   - User's initial instructions (verbatim quote)
   - Key decision points and user interventions at each stage
   - Direction correction moments and reasons
   - Iteration count and review result summaries
   - Intellectual insights raised by the user (e.g., questions that spawned new chapters)
   - Quality requirement evolution (e.g., formatting, tone adjustments)
   - Pipeline statistics (stage count, review rounds, integrity verification count, etc.)

3. Generate Markdown version (paper_creation_process.md / paper_creation_process_en.md)

4. Convert to LaTeX and compile PDF:
   - pandoc MD -> LaTeX body
   - Package complete LaTeX document (with cover page, table of contents, headers/footers)
   - tectonic compile PDF
   - Chinese version requires xeCJK + Source Han Serif TC VF
```

### Required Content in Process Record

| Section | Content |
|---------|---------|
| Paper Information | Title, final deliverables list |
| Stage-by-Stage Process | Input/output/key decisions for each stage, with verbatim user quotes |
| Iteration Details | Review comment summaries, revision items, re-review results |
| Interaction Pattern Summary | User role, Claude role, intervention count, key turning points — statistics table |
| User Key Decisions | Chronological list of every important decision made by the user |
| Key Lessons | Reusable lessons learned from the process |
| **Collaboration Quality Evaluation** | **Final chapter: 1-100 score + dimensional analysis + improvement suggestions** (see below) |

### Collaboration Quality Evaluation (Final Chapter, Mandatory)

The final chapter of the process record is a "Collaboration Quality Evaluation" that honestly and constructively assesses the user's performance in the human-AI collaboration. Format follows the Claude Code CLI `/insight` feature.

#### Scoring Dimensions (each 1-100, weighted average for overall score)

```
+--------------------------------------------------+
|  Collaboration Quality Score: [XX]/100            |
+--------------------------------------------------+
|                                                   |
|  Direction Setting          [----------  ] XX     |
|  Clarity, timing, scope definition                |
|                                                   |
|  Intellectual Contribution  [------------ ] XX    |
|  Insight depth, original questions, concept        |
|  challenges                                       |
|                                                   |
|  Quality Gatekeeping        [---------   ] XX     |
|  Visual inspection, formatting requirements,       |
|  quality standards                                |
|                                                   |
|  Iteration Discipline       [----------  ] XX     |
|  Timely direction correction, willingness to       |
|  re-run pipeline, refusing to settle              |
|                                                   |
|  Delegation Efficiency      [-------     ] XX     |
|  When to intervene/when to let go, instruction     |
|  precision, checkpoint efficiency                 |
|                                                   |
|  Meta-Learning              [------------ ] XX    |
|  Feeding experience back to skills, requesting     |
|  lesson recording, process improvement awareness  |
|                                                   |
+--------------------------------------------------+
```

#### Scoring Criteria

| Score Range | Meaning |
|------------|---------|
| 90-100 | Exceptional — User intervention significantly elevated the paper's intellectual quality beyond what AI could produce independently |
| 75-89 | Excellent — User made correct directional decisions and effectively leveraged the pipeline's iteration capabilities |
| 60-74 | Good — User completed necessary decisions but some opportunities were missed |
| 40-59 | Basic — User primarily served as a "continue" button with little substantive intervention |
| 1-39 | Needs Improvement — User intervention may have disrupted the workflow or lacked critical quality gatekeeping |

#### Required Subsections

1. **Overall Score**: Total score + one-sentence evaluation
2. **What Worked Well**: 2-4 specific behaviors, with verbatim user quotes
3. **Missed Opportunities**: 1-3 things the user could have done but didn't
4. **Recommendations for Next Time**: 3-5 specific, actionable improvement suggestions
5. **Human vs AI Value-Add**: Clearly identify which aspects of the final paper quality came from user intervention (not achievable by AI independently)

#### Evaluation Principles

- **Honesty first**: No inflation, no pleasantries. If the user only pressed "continue," reflect that truthfully
- **Evidence-based**: Every score is supported by specific behaviors or conversation records
- **Constructive**: Every criticism must include actionable improvement suggestions
- **Acknowledge uncertainty**: If certain dimensions cannot be evaluated (e.g., mid-entry skipped the research stage), mark as N/A
- **Bidirectional reflection**: Also candidly point out Claude's shortcomings during the process (e.g., areas requiring multiple corrections)

### Output Specifications

- **Filename**: `paper_creation_process.md` (Chinese) / `paper_creation_process_en.md` (English)
- **PDF**: `paper_creation_process_zh.pdf` / `paper_creation_process_en.pdf`
- **LaTeX template**: `article` class, 12pt, A4, Times New Roman + Source Han Serif TC VF
- **Includes table of contents**: `\tableofcontents`
- **Header**: left = document title (italic), right = date
- **Compilation**: tectonic (same toolchain as Stage 5)

---

## Quality Standards

| Dimension | Requirement |
|-----------|------------|
| Stage detection | Correctly identify user's current stage and available materials |
| Mode recommendation | Recommend appropriate mode based on user preferences and material status |
| Material handoff | Stage-to-stage handoff materials are complete and correctly formatted |
| State tracking | Pipeline state updated in real time; Progress Dashboard accurate |
| **Mandatory checkpoint** | **User confirmation required after each stage completion** |
| **Mandatory integrity check** | **Stage 2.5 and 4.5 cannot be skipped, must PASS** |
| No overstepping | Orchestrator does not perform substantive research/writing/reviewing, only dispatching |
| No forcing | User can pause or exit pipeline at any time (but cannot skip integrity checks) |
| Reproducible | Same input follows the same workflow across different sessions |

---

## Error Recovery

| Stage | Error | Handling |
|-------|-------|---------|
| Intake | Cannot determine entry point | Ask user what materials they have and their goal |
| Stage 1 | deep-research not converging | Suggest mode switch (socratic -> full) or narrow scope |
| Stage 2 | Missing research foundation | Suggest returning to Stage 1 to supplement research |
| Stage 2.5 | Still FAIL after 3 correction rounds | List unverifiable items; user decides whether to continue |
| Stage 3 | Review result is Reject | Provide options: major restructuring (Stage 2) or abandon |
| Stage 4 | Revision incomplete on all items | List unaddressed items; ask whether to continue |
| Stage 3' | Verification still has major issues | Enter Stage 4' for final revision |
| Stage 4' | Issues remain after revision | Mark as Acknowledged Limitations; proceed to Stage 4.5 |
| Stage 4.5 | Final verification FAIL | Fix and re-verify (max 3 rounds) |
| Any | User leaves midway | Save pipeline state; can resume from breakpoint next time |
| Any | Skill execution failure | Report error; suggest retry or skip |

---

## Agent File References

| Agent | Definition File |
|-------|----------------|
| pipeline_orchestrator_agent | `agents/pipeline_orchestrator_agent.md` |
| state_tracker_agent | `agents/state_tracker_agent.md` |
| integrity_verification_agent | `agents/integrity_verification_agent.md` |

---

## Reference Files

| Reference | Purpose |
|-----------|---------|
| `references/pipeline_state_machine.md` | Complete state machine definition: all legal transitions, preconditions, actions |
| `references/plagiarism_detection_protocol.md` | Phase D originality verification protocol + self-plagiarism + AI text characteristics |
| `references/mode_advisor.md` | Unified cross-skill decision tree: maps user intent to optimal skill + mode |
| `references/claim_verification_protocol.md` | Phase E claim verification protocol: claim extraction, source tracing, cross-referencing, verdict taxonomy |
| `references/team_collaboration_protocol.md` | Multi-person team coordination: role definitions, handoff protocol, version control, conflict resolution |
| `shared/handoff_schemas.md` | Cross-skill data contracts: 9 schemas for all inter-stage handoff artifacts |

---

## Templates

| Template | Purpose |
|----------|---------|
| `templates/pipeline_status_template.md` | Progress Dashboard output template |

---

## Examples

| Example | Demonstrates |
|---------|-------------|
| `examples/full_pipeline_example.md` | Complete pipeline conversation log (Stage 1-5, with integrity + 2-stage review) |
| `examples/mid_entry_example.md` | Mid-entry example starting from Stage 2.5 (existing paper -> integrity check -> review -> revision -> finalization) |

---

## Output Language

Follows user language. Academic terminology retained in English.

---

## Integration with Other Skills

```
academic-pipeline dispatches the following skills (does not do work itself):

Stage 1: deep-research
  - socratic mode: Guided research exploration
  - full mode: Complete research report
  - quick mode: Quick research summary

Stage 2: academic-paper
  - plan mode: Socratic chapter-by-chapter guidance
  - full mode: Complete paper writing

Stage 2.5: integrity_verification_agent (Mode 1: pre-review)
Stage 4.5: integrity_verification_agent (Mode 2: final-check)

Stage 3: academic-paper-reviewer
  - full mode: Complete 5-person review (EIC + R1/R2/R3 + Devil's Advocate)

Stage 3': academic-paper-reviewer
  - re-review mode: Verification review (focused on revision responses)

Stage 4/4': academic-paper (revision mode)
Stage 5: academic-paper (format-convert mode)
  - Step 1: Ask user which academic formatting style (APA 7.0 / Chicago / IEEE, etc.)
  - Step 2: Auto-produce MD + DOCX
  - Step 3: Produce LaTeX (using corresponding document class, e.g., apa7 class for APA 7.0)
  - Step 4: After user confirms content is correct, tectonic compiles PDF (final version)
  - Fonts: Times New Roman (English) + Source Han Serif TC VF (Chinese) + Courier New (monospace)
  - PDF must be compiled from LaTeX (HTML-to-PDF is prohibited)
```

---

## Related Skills

| Skill | Relationship |
|-------|-------------|
| `deep-research` | Dispatched (Stage 1 research phase) |
| `academic-paper` | Dispatched (Stage 2 writing, Stage 4/4' revision, Stage 5 formatting) |
| `academic-paper-reviewer` | Dispatched (Stage 3 first review, Stage 3' verification review) |

---

## Version Info

| Item | Content |
|------|---------|
| Skill Version | 2.6 |
| Last Updated | 2026-03-08 |
| Maintainer | Cheng-I Wu |
| Dependent Skills | deep-research v2.0+, academic-paper v2.0+, academic-paper-reviewer v1.1+ |
| Role | Full academic research workflow orchestrator |

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 2.7 | 2026-03-27 | **Style Profile in Material Passport**: Pipeline orchestrator now carries optional Style Profile (Schema 10 in `shared/handoff_schemas.md`) through all stages. Produced by academic-paper intake Step 10 when user provides past writing samples. Consumed by draft_writer (Stage 2) and report_compiler (Stage 1) as soft writing voice guide. Does not affect integrity verification or review stages. Coordinates with deep-research v2.4 and academic-paper v2.5 |
| 2.6 | 2026-03-08 | **Handoff Data Schema**: Enhanced `shared/handoff_schemas.md` with 9 comprehensive schemas (RQ Brief, Bibliography, Synthesis, Paper Draft, Integrity Report, Review Report, Revision Roadmap, Response to Reviewers, Material Passport) with full field definitions, type constraints, and validation rules; orchestrator validates output against schemas before each transition. **Adaptive Checkpoint System**: Replaced static checkpoint template with 3-tier system (FULL/SLIM/MANDATORY) based on stage criticality and user engagement; FULL checkpoints include decision dashboard with metrics; SLIM auto-continues for experienced users; MANDATORY cannot be bypassed at integrity/review/finalization boundaries; awareness guard after 4+ auto-continues. **Mode Advisor**: New `references/mode_advisor.md` with unified cross-skill decision tree, common misconceptions table, user archetype recommendations, decision flowchart, and anti-patterns guide. **Team Collaboration Protocol**: New `references/team_collaboration_protocol.md` with 5 role definitions, per-transition handoff procedures, git branching/tagging strategy, conflict resolution matrix, and communication templates; state tracker extended with `assigned_to`, `approval_gate`, `team_notes` per stage and `schema_validation_log`. **Phase E Claim Verification**: New `references/claim_verification_protocol.md` with E1 claim extraction, E2 source tracing, E3 cross-referencing; verdict taxonomy (VERIFIED / MINOR_DISTORTION / MAJOR_DISTORTION / UNVERIFIABLE / UNVERIFIABLE_ACCESS); severity mapping (MAJOR_DISTORTION -> SERIOUS, UNVERIFIABLE -> SERIOUS, MINOR_DISTORTION -> MINOR, UNVERIFIABLE_ACCESS -> MEDIUM); integrated into integrity_verification_agent Mode 1 (30% spot-check) and Mode 2 (100%); pass/fail criteria updated to include Phase E verdicts. **Mid-Entry Material Passport Check**: Pipeline orchestrator now validates Material Passport on mid-entry; decision tree checks verification_status, freshness (< 24 hours), and content modification (version_label comparison); offers skip/spot-check/full re-verify options for Stage 2.5 when passport is valid; passport freshness validation rules added to `shared/handoff_schemas.md` |
| 2.5 | 2026-03-08 | External Review Protocol: structured intake of real journal reviewer feedback (text/PDF/DOCX); 4-step workflow (parse -> strategic coaching -> revise + Response to Reviewers -> completeness check); differentiated behavior from internal simulated review (no default "accept all", risk assessment per comment, user confirmation of parsed items); explicit capability boundaries (AI verification ≠ reviewer satisfaction) |
| 2.4 | 2026-03-08 | Stage 6 PROCESS SUMMARY: post-pipeline paper creation process record; asks user preferred language (zh/en/both); generates structured MD summarizing full human-AI collaboration history with user quotes, key decisions, iteration details, and lessons learned; mandatory final chapter: **Collaboration Quality Evaluation** (6 dimensions scored 1-100, bar chart visualization, What Worked Well / Missed Opportunities / Recommendations / Human vs AI Value-Add / Claude's Self-Reflection); compiles to PDF via LaTeX + tectonic; outputs `paper_creation_process_zh.pdf` + `paper_creation_process_en.pdf` |
| 2.3 | 2026-03-08 | Stage 5 FINALIZE: mandatory formatting style prompt (APA 7.0 / Chicago / IEEE); PDF must compile from LaTeX via tectonic (no HTML-to-PDF); APA 7.0 uses `apa7` document class (`man` mode) with XeCJK for bilingual support; font stack: Times New Roman + Source Han Serif TC VF + Courier New |
| 2.2 | 2025-03-05 | Checkpoint confirmation semantics (6 user commands with precise actions); mode switching rules (safe/dangerous/prohibited matrix); skill failure fallback matrix (per-stage degradation strategies); state ownership protocol (single source of truth with write access control); material version control (versioned artifacts with audit trail); cross-skill reference to `shared/handoff_schemas.md` |
| 2.1 | 2026-03 | Added plagiarism detection protocol (Phase D); enhanced integrity_verification_agent with originality verification (D1 WebSearch, D2 self-plagiarism); updated both verification modes |
| 2.0 | 2026-02 | Added Stage 2.5/4.5 integrity checks, two-stage review, mandatory checkpoints, Devil's Advocate, reproducibility guarantees, integrity_verification_agent |
| 1.0 | 2026-02 | Initial version: 5+1 stage pipeline |
