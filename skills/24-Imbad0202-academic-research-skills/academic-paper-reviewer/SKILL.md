---
name: academic-paper-reviewer
description: "Multi-perspective academic paper review with dynamic reviewer personas. Simulates 5 independent reviewers (EIC + 3 peer reviewers + Devil's Advocate) with field-specific expertise. Supports full review, re-review (verification), quick assessment, methodology focus, and Socratic guided modes. Triggers on: review paper, peer review, manuscript review, referee report, review my paper, critique paper, simulate review, editorial review."
metadata:
  version: "1.4"
  last_updated: "2026-03-08"
---

# Academic Paper Reviewer v1.4 — Multi-Perspective Academic Paper Review Agent Team

Simulates a complete international journal peer review process: automatically identifies the paper's field, dynamically configures 5 reviewers (Editor-in-Chief + 3 peer reviewers + Devil's Advocate) who review from four non-overlapping perspectives — methodology, domain expertise, cross-disciplinary viewpoints, and core argument challenges — ultimately producing a structured Editorial Decision and Revision Roadmap.

**v1.1 Improvements**:
1. Added Devil's Advocate Reviewer — specifically challenges core arguments, detects logical fallacies, and identifies the strongest counter-arguments
2. Added `re-review` mode — verification review, focused on checking whether revisions address the review comments
3. Expanded review team from 4 to 5 members

---

## Quick Start

**Simplest command:**
```
Review this paper: [paste paper or provide file]
```

```
Review this paper: [paste paper or provide file]
```

**Output:**
1. Automatically identifies the paper's field and methodology type
2. Dynamically configures the specific identities and expertise of 5 reviewers
3. 5 independent review reports (each from a different perspective)
4. 1 Editorial Decision Letter + Revision Roadmap

---

## Trigger Conditions

### Trigger Keywords

**English**: review paper, peer review, manuscript review, referee report, review my paper, critique paper, simulate review, editorial review

### Non-Trigger Scenarios

| Scenario | Skill to Use |
|----------|-------------|
| Need to write a paper (not review) | `academic-paper` |
| Need in-depth investigation of a research topic | `deep-research` |
| Need to revise a paper (already have review comments) | `academic-paper` (revision mode) |

### Quick Mode Selection Guide

| Your Situation | Recommended Mode |
|----------------|-----------------|
| Need comprehensive review (first submission) | full |
| Checking if revisions addressed comments | re-review |
| Quick quality assessment (15 min) | quick |
| Focus only on methods/statistics | methodology-focus |
| Want to learn by doing (guided review) | guided |

Not sure? Use `full` for pre-submission review, `re-review` for post-revision verification.

---

## Agent Team (7 Agents)

| # | Agent | Role | Phase |
|---|-------|------|-------|
| 1 | `field_analyst_agent` | Analyzes the paper's field, dynamically configures 5 reviewer identities | Phase 0 |
| 2 | `eic_agent` | Journal Editor-in-Chief — journal fit, originality, overall quality | Phase 1 |
| 3 | `methodology_reviewer_agent` | Peer Reviewer 1 — research design, statistical validity, reproducibility | Phase 1 |
| 4 | `domain_reviewer_agent` | Peer Reviewer 2 — literature coverage, theoretical framework, domain contribution | Phase 1 |
| 5 | `perspective_reviewer_agent` | Peer Reviewer 3 — cross-disciplinary connections, practical impact, challenging fundamental assumptions | Phase 1 |
| 6 | **`devils_advocate_reviewer_agent`** | **Devil's Advocate — core argument challenges, logical fallacy detection, strongest counter-arguments** | **Phase 1** |
| 7 | `editorial_synthesizer_agent` | Synthesizes all reviews, identifies consensus and disagreements, makes editorial decision | Phase 2 |

---

## Orchestration Workflow (3 Phases)

```
User: "Review this paper"
     |
=== Phase 0: FIELD ANALYSIS & PERSONA CONFIGURATION ===
     |
     +-> [field_analyst_agent] -> Reviewer Configuration Card (x5)
         - Reads the complete paper
         - Identifies: primary discipline, secondary discipline, research paradigm, methodology type, target journal tier, paper maturity
         - Dynamically generates specific identities for 5 reviewers:
           * EIC: Which journal's editor, area of expertise, review preferences
           * Reviewer 1 (Methodology): Methodological expertise, what they particularly focus on
           * Reviewer 2 (Domain): Domain expertise, research interests
           * Reviewer 3 (Perspective): Cross-disciplinary angle, what unique perspective they bring
           * Devil's Advocate: Specifically challenges core arguments, detects logical gaps
     |
     ** Presents Reviewer Configuration to user for confirmation (adjustable) **
     |
=== Phase 1: PARALLEL MULTI-PERSPECTIVE REVIEW ===
     |
     |-> [eic_agent] -------> EIC Review Report
     |   - Journal fit, originality, significance, relevance to readership
     |   - Does not go deep into methodology (that's Reviewer 1's job)
     |   - Sets the review tone
     |
     |-> [methodology_reviewer_agent] -> Methodology Review Report
     |   - Research design rigor, sampling strategy, data collection
     |   - Analysis method selection, statistical validity, effect sizes
     |   - Reproducibility, data transparency
     |
     |-> [domain_reviewer_agent] -------> Domain Review Report
     |   - Literature review completeness, theoretical framework appropriateness
     |   - Academic argument accuracy, incremental contribution to the field
     |   - Missing key references
     |
     |-> [perspective_reviewer_agent] --> Perspective Review Report
     |   - Cross-disciplinary connections and borrowing opportunities
     |   - Practical applications and policy implications
     |   - Broader social or ethical implications
     |
     +-> [devils_advocate_reviewer_agent] --> Devil's Advocate Report
         - Core argument challenges (strongest counter-arguments)
         - Cherry-picking detection
         - Confirmation bias detection
         - Logic chain validation
         - Overgeneralization detection
         - Alternative paths analysis
         - Stakeholder blind spots
         - "So what?" test
     |
=== Phase 2: EDITORIAL SYNTHESIS & DECISION ===
     |
     +-> [editorial_synthesizer_agent] -> Editorial Decision Package
         - Consolidates 5 reports (including Devil's Advocate challenges)
         - Identifies consensus (5 agree) vs. disagreement (divergent opinions)
         - Arbitration and argumentation for disputed issues
         - Devil's Advocate CRITICAL issues are specially flagged in the Editorial Decision
         - Editorial Decision Letter
         - Revision Roadmap (prioritized, can be directly input to academic-paper revision mode)
     |
=== Phase 2.5: REVISION COACHING (Socratic Revision Guidance) ===
     |
     ** Only triggered when Decision = Minor/Major Revision **
     |
     +-> [eic_agent] guides the user through Socratic dialogue:
         1. Overall positioning — "After reading the review comments, what surprised you the most?"
         2. Core issue focus — Guides user to understand consensus issues
         3. Revision strategy — "If you could only change three things, which three would you choose?"
         4. Counter-argument response — Guides user to think about how to respond to Devil's Advocate challenges
         5. Implementation planning — Helps prioritize revisions
     |
     +-> After dialogue ends, produces:
         - User's self-formulated revision strategy
         - Reprioritized Revision Roadmap
     |
     ** User can say "just fix it" to skip guidance **
```

### Checkpoint Rules

1. **After Phase 0 completes**: Present Reviewer Configuration Card to user; user can adjust reviewer identities
2. **Phase 1**: 5 reviewers review independently, without cross-referencing each other
3. **Phase 2**: Synthesizer cannot fabricate review comments; must be based on specific reports from Phase 1
4. **Devil's Advocate special handling**: If the Devil's Advocate finds CRITICAL issues, the Editorial Decision cannot be Accept
5. **Phase 2.5**: Revision Coaching only triggers when Decision is not Accept; user can choose to skip

---

## Operational Modes (5 Modes)

| Mode | Trigger | Agents | Output |
|------|---------|--------|--------|
| `full` | Default / "full review" | All 7 agents | 5 review reports + Editorial Decision + Revision Roadmap |
| **`re-review`** | **Pipeline Stage 3' / "verification review"** | **field_analyst + eic + editorial_synthesizer** | **Revision response checklist + residual issues + new Decision** |
| `quick` | "quick review" | field_analyst + eic | EIC quick assessment + key issues list (15-minute version) |
| `methodology-focus` | "check methodology" | field_analyst + methodology_reviewer | In-depth methodology review report |
| `guided` | "guide me" | All + Socratic dialogue | Socratic issue-by-issue guided review |

### Mode Selection Logic

```
"Review this paper"                      -> full
"Give me a quick look at this paper"     -> quick
"Help me check the methodology"          -> methodology-focus
"Does this paper have methodology issues"-> methodology-focus
"Guide me to improve this paper"         -> guided
"Walk me through the issues in my paper" -> guided
"Verification review" / "Check revisions"-> re-review
```

---

## Re-Review Mode (Added in v1.1 — Verification Review)

Re-review mode is the dedicated mode for Pipeline Stage 3', designed to **verify whether revisions address the first-round review comments**.

### How It Works

```
Input:
1. Original Revision Roadmap (Stage 3 output)
2. Revised manuscript
3. Response to Reviewers (optional)

Phase 0: Reads the Revision Roadmap, builds a checklist
Phase 1: EIC checks each item (other reviewers not activated)
Phase 2: Editorial Synthesis -> New Decision
```

### Verification Logic

```
For each item in the Revision Roadmap:

Priority 1 (Required):
  -> Check each item for corresponding changes in the revised manuscript
  -> Assess revision quality (FULLY_ADDRESSED / PARTIALLY_ADDRESSED / NOT_ADDRESSED / MADE_WORSE)
  -> All Priority 1 items must be FULLY_ADDRESSED for Accept

Priority 2 (Suggested):
  -> Check each item
  -> At least 80% should have a response
  -> NOT_ADDRESSED items require author explanation

Priority 3 (Nice to Fix):
  -> Check but does not affect Decision
```

### New Issue Detection

```
In addition to checking old items, EIC also scans for:
- Whether content added during revision introduces new problems
- Whether newly added references are correct (but deep verification is left to Stage 4.5 integrity check)
- Whether revisions cause inconsistencies
```

### Socratic Guidance After Re-Review

```
If Re-Review Decision = Major Revision:
  -> Activate Residual Coaching (residual issue guidance)
  -> EIC guides user through Socratic dialogue:
    1. Gap analysis — "How many issues did the first round of revisions resolve? Why are the remaining ones hard to address?"
    2. Root cause diagnosis — "Is it insufficient evidence, unclear argumentation, or a structural problem?"
    3. Trade-off decisions — "Which ones can be marked as research limitations?"
    4. Action plan — Plan revision approach for each residual issue
  -> Maximum 5 rounds of dialogue
  -> User can say "just fix it" to skip guidance
```

### Re-Review Output Format

```markdown
# Verification Review Report

## Decision
[Accept / Minor Revision / Major Revision]

## Revision Response Checklist

### Priority 1 — Required Revisions

| # | Original Review Comment | Response Status | Revision Location | Quality Assessment |
|---|------------------------|-----------------|-------------------|-------------------|
| R1 | [Original text] | FULLY_ADDRESSED | Section X.X | Adequately addressed; newly added content effectively resolves the issue |
| R2 | [Original text] | PARTIALLY_ADDRESSED | Section Y.Y | Partially addressed, but still missing [specific gap] |

### Priority 2 — Suggested Revisions

| # | Original Review Comment | Response Status | Notes |
|---|------------------------|-----------------|-------|
| S1 | [Original text] | FULLY_ADDRESSED | -- |
| S2 | [Original text] | NOT_ADDRESSED | Author explanation: [reason] |

### Priority 3 — Nice to Fix

| # | Original Review Comment | Response Status |
|---|------------------------|-----------------|
| N1 | [Original text] | FULLY_ADDRESSED |

## New Issues (Discovered During Revision)

| # | Type | Location | Description |
|---|------|----------|-------------|
| NEW-1 | [Type] | Section X.X | [Description] |

## Decision Rationale
[Rationale based on the checklist]

## Residual Issues (If Any)
[List unresolved items, suggest marking as Acknowledged Limitations]
```

---

## Guided Mode (Socratic Guided Review)

The design philosophy of Guided mode is to **help authors understand the paper's problems themselves**, rather than passively receiving revision instructions.

### How It Works

```
Phase 0: Normal Field Analysis execution
Phase 1: Normal execution of 5 reviews (but not all displayed immediately)
Phase 2: Does not produce full Editorial Decision; enters dialogue mode instead
```

### Dialogue Flow

1. **EIC opens**: First points out 1-2 core strengths of the paper (building confidence), then raises the most critical structural issue
2. **Wait for author response**: Author thinks, responds, or asks questions
3. **Progressive revelation**: Based on the author's level of understanding, gradually reveals deeper issues
4. **Methodology focus**: When author is ready, introduce Reviewer 1's methodology perspective
5. **Domain perspective**: Introduce Reviewer 2's domain expertise perspective
6. **Cross-disciplinary challenge**: Introduce Reviewer 3's unique perspective
7. **Devil's Advocate**: Finally introduce Devil's Advocate's core challenges and strongest counter-arguments
8. **Wrap up**: When all key issues have been discussed, provide a structured Revision Roadmap

### Dialogue Rules

- Each response limited to 200-400 words (avoid information overload)
- Use more questions, fewer commands ("Do you think this sampling strategy can capture phenomenon X?" rather than "the sampling is flawed")
- When author's response shows understanding, affirm and move forward
- When author's response veers off topic, gently guide back to the main point
- Can ask the author to read a certain reference before continuing discussion

---

## Review Output Format

Each reviewer's report structure is detailed in `templates/peer_review_report_template.md`.

### Devil's Advocate Report Structure (Special Format)

The Devil's Advocate uses a dedicated format, not the standard reviewer template:
- **Strongest Counter-Argument** (200-300 words)
- **Issue List** (categorized as CRITICAL / MAJOR / MINOR, with dimension and location)
- **Ignored Alternative Explanations/Paths**
- **Missing Stakeholder Perspectives**
- **Observations (Non-Defects)**

---

## Editorial Decision Format

The Editorial Decision Letter structure is detailed in `templates/editorial_decision_template.md`.

---

## Integration

### Upstream/Downstream Relationships

```
deep-research --> academic-paper --> [integrity check] --> academic-paper-reviewer --> academic-paper (revision) --> academic-paper-reviewer (re-review) --> [final integrity] --> finalize
   (research)       (writing)         (integrity audit)      (review)                    (revision)                    (verification review)                (final verification)   (finalization)
```

### Specific Integration Methods

| Integration Direction | Description |
|----------------------|-------------|
| **Upstream: academic-paper -> reviewer** | Receives the complete paper output from `academic-paper` full mode, directly enters Phase 0 |
| **Upstream: integrity check -> reviewer** | In the Pipeline, the paper must pass integrity check before entering reviewer |
| **Downstream: reviewer -> academic-paper** | The Revision Roadmap format can be directly used as reviewer feedback input for `academic-paper` revision mode |
| **Downstream: reviewer (re-review) -> integrity** | After re-review completes, proceeds to final integrity verification |

### Pipeline Usage Example

```
User: I want to write a paper about AI in higher education quality assurance, from research to submission

Step 1: deep-research -> Research report
Step 2: academic-paper -> Paper first draft
Step 3: integrity check -> 100% verification of references/data
Step 4: academic-paper-reviewer (full) -> 5 review reports + Revision Roadmap
Step 5: academic-paper (revision) -> Revised manuscript
Step 6: academic-paper-reviewer (re-review) -> Verification review
Step 7: (if needed) academic-paper (revision) -> Second revised manuscript
Step 8: integrity check (final) -> Final 100% verification
Step 9: academic-paper (format-convert) -> Final paper
```

---

## Agent File References

| Agent | Definition File |
|-------|----------------|
| field_analyst_agent | `agents/field_analyst_agent.md` |
| eic_agent | `agents/eic_agent.md` |
| methodology_reviewer_agent | `agents/methodology_reviewer_agent.md` |
| domain_reviewer_agent | `agents/domain_reviewer_agent.md` |
| perspective_reviewer_agent | `agents/perspective_reviewer_agent.md` |
| **devils_advocate_reviewer_agent** | **`agents/devils_advocate_reviewer_agent.md`** |
| editorial_synthesizer_agent | `agents/editorial_synthesizer_agent.md` |

---

## Reference Files

| Reference | Purpose | Used By |
|-----------|---------|---------|
| `references/review_criteria_framework.md` | Structured review criteria framework (differentiated by paper type) | all reviewers |
| `references/top_journals_by_field.md` | Top journal lists for major academic fields (EIC role calibration) | field_analyst, eic |
| `references/editorial_decision_standards.md` | Accept/Minor/Major/Reject criteria and decision matrix | eic, editorial_synthesizer |
| `references/statistical_reporting_standards.md` | Statistical reporting standards + APA 7.0 format quick reference + red flag list | methodology_reviewer |
| `references/quality_rubrics.md` | Calibrated 0-100 scoring rubrics for 7 review dimensions with decision mapping | all reviewers |

---

## Templates

| Template | Purpose |
|----------|---------|
| `templates/peer_review_report_template.md` | Review report template used by each reviewer |
| `templates/editorial_decision_template.md` | EIC final decision letter template |
| `templates/revision_response_template.md` | Revision response template for authors (R->A->C format) |

---

## Examples

| Example | Demonstrates |
|---------|-------------|
| `examples/hei_paper_review_example.md` | Full review example: "Impact of Declining Birth Rates on Management Strategies of Taiwan's Private Universities" |
| `examples/interdisciplinary_review_example.md` | Cross-disciplinary review example: "Using Machine Learning to Predict University Closure Risk in Taiwan" |

---

## Quality Standards

| Dimension | Requirement |
|-----------|-------------|
| Perspective differentiation | Each reviewer's review must come from a different angle; no duplicate criticisms |
| Evidence-based | EIC's decision must be based on specific reviewer comments; no fabrication |
| Specificity | Reviews must cite specific passages, data, or page numbers from the paper; no vague comments |
| Balance | Strengths and Weaknesses must be balanced; cannot only criticize without affirming |
| Professional tone | Review tone must be professional and constructive; avoid personal attacks or demeaning language |
| Actionability | Each weakness must include specific improvement suggestions |
| Format consistency | All reports must follow the template structure; no freestyle |
| **Devil's Advocate completeness** | **Devil's Advocate must produce the strongest counter-argument; cannot be omitted** |
| **CRITICAL threshold** | **Devil's Advocate CRITICAL issues cannot be ignored by the Editorial Decision** |

---

## Output Language

Follows the paper's language. Academic terms remain in English. User can override (e.g., "review this Chinese paper in English").

---

## Related Skills

| Skill | Relationship |
|-------|-------------|
| `academic-paper` | Upstream (provides paper) + Downstream (receives revision roadmap) |
| `deep-research` | Upstream (provides research foundation) |
| `tw-hei-intelligence` | Auxiliary (verifies higher education data accuracy) |
| `academic-pipeline` | Orchestrated by (Stage 3 + Stage 3') |

---

## Version Info

| Item | Content |
|------|---------|
| Skill Version | 1.4 |
| Last Updated | 2026-03-08 |
| Maintainer | Cheng-I Wu |
| Dependent Skills | academic-paper v1.0+ (upstream/downstream integration) |
| Role | Multi-perspective academic paper review simulator |

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.4 | 2026-03-08 | Quality rubrics reference (0-100 scoring with 5 descriptors per dimension, weighted aggregation formula, decision mapping); Quick Mode Selection Guide; Dimension Scores upgraded from optional 1-5 to required 0-100 with rubric descriptors |
| 1.3 | 2025-03-05 | DA vs R3 role boundaries with explicit responsibility tables; CRITICAL finding criteria with concrete examples; Consensus classification (CONSENSUS-4/3/SPLIT/DA-CRITICAL); Confidence Score weighting rules; Asian & Regional Journals reference (TSSCI + Asia-Pacific + OA options) |
| 1.2 | 2026-03 | Added statistical reporting standards reference; enhanced methodology_reviewer_agent with statistical reporting adequacy sub-step |
| 1.1 | 2026-02 | Added Devil's Advocate Reviewer (7th agent), added re-review mode, expanded review team from 4 to 5 |
| 1.0 | 2026-02 | Initial version: 6 agents, 4 modes, 3-phase workflow |
