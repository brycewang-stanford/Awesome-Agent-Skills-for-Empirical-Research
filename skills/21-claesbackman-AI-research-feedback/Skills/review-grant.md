---
description: Run a 6-agent pre-submission panel review for a grant proposal targeting a specified funder or program
---

You are coordinating a rigorous pre-submission review of a grant proposal. You will run 6 specialized review agents in parallel and consolidate their findings into a structured report.

## Phase 1: Parse Arguments and Discover the Proposal

Parse `$ARGUMENTS` as follows:
- The recognized target programs/funders are:
  - **US federal science and health**: `NSF`, `NIH`
  - **International research funders**: `ERC`, `HorizonEurope`
  - **General proposal standards**: `major-funder`, `foundation`
  - (case-insensitive; users can add further programs or funders by editing this list in the skill file)
- If the first token of `$ARGUMENTS` matches one of these names, treat it as the **target program/funder** and treat any remaining text as the **main proposal file path**.
- If no token matches one of these names, treat the entire `$ARGUMENTS` as a file path and set the target program/funder to `major-funder` (meaning the review applies high general standards without a specific sponsor persona).
- If `$ARGUMENTS` is empty, set both to their defaults: no file path (auto-detect) and target program/funder `major-funder`.

Store the resolved target program/funder as `TARGET_PROGRAM` for use in Agent 6 and the report header.

If a file path was provided, use it as the main proposal file. Otherwise, auto-detect:

1. Search the current directory recursively for likely proposal files with common extensions: `*.md`, `*.txt`, `*.tex`, `*.docx`, `*.pdf` (exclude hidden folders, `.git`, build output, and dependency directories).
2. Prioritize files whose names suggest they are the main narrative, such as those containing `proposal`, `project-description`, `research-plan`, `specific-aims`, `narrative`, `case-for-support`, or `application`.
3. Identify the **main proposal document**: the file that appears to contain the core project narrative rather than only a budget, CV, biosketch, appendix, or letter. If more than one file looks plausible, prefer the one with the clearest summary/abstract and the most complete proposal sections.
4. Read the main proposal file and identify references to supporting documents, appendices, attachments, supplementary materials, budget files, timeline files, biosketches/CVs, facilities/resources statements, data-management plans, mentoring plans, or letters of support.
5. Search recursively for common supporting files and record them if present:
   - Budget and justification: files containing `budget`, `justification`
   - Timeline and workplan: files containing `timeline`, `gant`, `gantt`, `milestone`, `workplan`
   - Personnel documents: files containing `biosketch`, `cv`, `resume`, `personnel`, `team`
   - Compliance/supporting plans: files containing `data-management`, `data sharing`, `management plan`, `mentoring`, `facilities`, `resources`, `support letter`, `letter`
   - Appendices and supplements: files containing `appendix`, `supplement`, `supplementary`
6. Record:
   - Full path of the main proposal file
   - Full path of each supporting file and its likely role
   - Proposal title, PI(s)/team, abstract/summary if available
   - Any explicit funding call, solicitation, or sponsor named in the materials

If the proposal is in a binary format such as `.pdf` or `.docx` and the environment cannot read it directly, review what is accessible and explicitly note the limitation in the final report.

## Phase 2: Launch 6 Review Agents in Parallel

In a **single message**, launch all 6 agents using the Agent tool with `subagent_type: "general-purpose"`. Each agent reads the proposal materials independently. Pass the complete list of proposal and supporting file paths to each agent in its prompt. When constructing Agent 6's prompt, substitute the actual resolved value of `TARGET_PROGRAM` for every occurrence of `TARGET_PROGRAM` in that agent's prompt text.

---

### AGENT 1 — Clarity, Writing Quality & Compliance Signals

You are a grant editor reviewing the proposal for clarity, professionalism, and compliance with common proposal-writing expectations. Read all accessible proposal files and focus on the actual prose rather than markup or formatting commands.

**What to check:**

1. **Clarity and readability**: Identify sentences and paragraphs that are hard to follow, overloaded with jargon, too abstract, or too dense for a panel reviewer reading quickly.

2. **Writing quality**: Flag spelling errors, grammar issues, tense inconsistency, awkward phrasing, undefined acronyms, inconsistent terminology, and places where the proposal sounds careless or rushed.

3. **Structure and signposting**: Check whether the proposal clearly states:
   - the problem
   - why it matters
   - the core aims or objectives
   - the approach
   - expected outputs or outcomes
   - why this team can do it

4. **Reviewer-orientation problems**: Flag any place where a busy reviewer would ask:
   - "What exactly is the project trying to do?"
   - "Why is this important?"
   - "What is new here?"
   - "What will be delivered, and when?"

5. **Compliance signals**: Check for common proposal-writing failures that create noncompliance risk even when rules are not fully provided:
   - missing project summary or abstract-like overview
   - unclear aims/objectives
   - no explicit deliverables
   - no timeline cues
   - no evaluation or success criteria
   - vague dissemination or broader-impact language when expected

6. **Tone and style**: Flag hype, overstatement, empty buzzwords, and generic claims such as "transformative," "groundbreaking," or "highly innovative" when unsupported by specifics.

**Output format:**
```
## Agent 1: Clarity, Writing Quality & Compliance Signals

### Critical Writing or Clarity Issues
[numbered list: Location | Problematic text or section | Why it hurts the proposal | Suggested correction]

### Minor Writing Issues
[numbered list: same format]

### Structural or Compliance Signals to Fix
[numbered list: Missing or weak element | Where it should appear | Recommended remedy]
```

The proposal files to review are: [LIST ALL FILE PATHS HERE]

---

### AGENT 2 — Internal Consistency, Scope & Deliverables

You are a technical reviewer checking whether the proposal is internally coherent and operationally consistent. Read all accessible proposal files and verify that the project description, aims, methods, timeline, personnel plan, and budget story align.

**What to check:**

1. **Aims vs. methods consistency**: For each stated aim or objective, verify that the methods section actually explains how that aim will be achieved.

2. **Aims vs. deliverables consistency**: Check whether every major promised output, deliverable, dataset, prototype, publication, or policy product is traceable to a concrete work package or task.

3. **Timeline consistency**: If phases, milestones, or years are named in different places, verify that they match. Flag contradictions across narrative, timeline, budget justification, and appendices.

4. **Personnel consistency**: Do the named investigators, collaborators, staff roles, and external partners match across the narrative, biosketches/CVs, management plan, and budget story?

5. **Budget-story consistency**: If the proposal requests resources for a task, is that task actually described in the narrative? Conversely, are there major activities in the narrative that appear under-resourced or unsupported?

6. **Terminology consistency**: Identify every key project term, work package, intervention, dataset, target population, or evaluation metric and flag drift in naming or meaning.

7. **Claim consistency across sections**: Check whether the abstract/summary, significance section, research plan, management plan, and conclusion describe the same project at the same level of ambition.

8. **External references and attachments**: Flag cases where the proposal says "see attached", "as shown in the budget/timeline/letter", or similar, but the referenced material is missing or does not appear to support the claim.

**Output format:**
```
## Agent 2: Internal Consistency, Scope & Deliverables

### Critical Inconsistencies
[numbered list: [Location 1] ↔ [Location 2] | What conflicts | Why it matters]

### Deliverable or Scope Gaps
[numbered list: Aim/deliverable | Missing operational support | Recommended fix]

### Terminology Drift
[numbered list: Term | How it varies | Recommended standardization]

### Minor Inconsistencies
[numbered list: same format as Critical]
```

The proposal files to review are: [LIST ALL FILE PATHS HERE]

---

### AGENT 3 — Significance, Innovation & Fit to the Call

You are a skeptical panel reviewer evaluating whether the proposal addresses an important problem, offers a credible level of novelty, and fits the likely sponsor or solicitation.

**What to check:**

1. **Problem significance**: Does the proposal explain why the problem matters now, to whom it matters, and what is at stake if the problem is not addressed?

2. **Innovation claims**: Flag every place where the proposal claims novelty, first-mover status, uniqueness, or transformative potential without making clear what is actually new.

3. **Fit to sponsor or call**: Based on the accessible materials and the named `TARGET_PROGRAM`, assess whether the project seems aligned with likely review criteria, scope, mission, and audience. Flag mission drift or weak fit.

4. **Value proposition**: Does the proposal clearly explain why this project deserves funding rather than simply being interesting or worthwhile in the abstract?

5. **Broader impacts / translational / public value claims**: Check whether claims about impact, policy relevance, clinical relevance, social benefit, or broader impacts are concrete and plausible rather than generic.

6. **Competitive positioning**: Would a reviewer understand why this proposal stands out from other plausible applications in the same space? If not, identify what is missing.

7. **Overclaiming and underclaiming**:
   - **Overclaiming**: Claims of importance or novelty that exceed the evidence presented
   - **Underclaiming**: Strong aspects of the proposal that are not framed sharply enough to help in review

**Output format:**
```
## Agent 3: Significance, Innovation & Fit to the Call

### Major Fit or Significance Problems
[numbered list: Location | Issue | Why it weakens competitiveness | Fix]

### Innovation Overclaiming
[numbered list: Quoted or paraphrased claim | Why it overreaches | Better framing]

### Underused Strengths
[numbered list: Strength | Where it should be emphasized | Suggested framing]

### Minor Positioning Issues
[numbered list: same format]
```

The proposal files to review are: [LIST ALL FILE PATHS HERE]

---

### AGENT 4 — Research Design, Methods & Feasibility

You are a demanding methodological reviewer assessing whether the proposed work is technically sound and realistically executable within the proposed project period.

**What to check:**

1. **Methodological adequacy**: For each aim or work package, does the proposal specify a method that is adequate to answer the stated question or achieve the stated objective?

2. **Feasibility**: Are the timeline, staffing, data access, recruitment plan, partnerships, computation, infrastructure, and regulatory assumptions realistic?

3. **Risk identification and mitigation**: Does the proposal identify the main technical, logistical, data, recruitment, regulatory, or dependency risks? Are fallback plans credible?

4. **Evaluation plan**: If the proposal promises outputs, interventions, tools, pilots, or impact, does it specify how success will be measured?

5. **Sampling, data, and evidence plan**: Where relevant, assess whether the proposal adequately explains:
   - data sources or materials
   - sample or participant selection
   - power or scale logic
   - analytic strategy
   - validation or quality-control procedures

6. **Dependencies and hidden assumptions**: Flag any part of the proposal that quietly depends on external approvals, access, collaborators, datasets, or technical breakthroughs that are not secured.

7. **Ambition vs. capacity**: Is the project appropriately ambitious, or does it promise more than the team can plausibly deliver with the requested funds and time?

**Output format:**
```
## Agent 4: Research Design, Methods & Feasibility

### Major Methodological or Feasibility Risks
[numbered list: Aim/work package | Risk or weakness | Why it matters | Recommended fix]

### Missing Risk Mitigation
[numbered list: Risk | Where it should be addressed | Suggested mitigation]

### Evaluation Plan Gaps
[numbered list: Claimed output or outcome | Missing measurement or success criterion | Recommended addition]

### Minor Methodological Issues
[numbered list: same format]
```

The proposal files to review are: [LIST ALL FILE PATHS HERE]

---

### AGENT 5 — Budget, Timeline, Team & Management Plan

You are a grants management reviewer assessing whether the proposal looks fundable from an execution and stewardship standpoint. Read all accessible proposal and supporting files.

**What to check:**

1. **Budget credibility**:
   - Does the requested budget appear plausible for the proposed work?
   - Are there obvious omissions, under-budgeted activities, or unjustified expenses?
   - Does the budget narrative explain why major cost categories are necessary?

2. **Timeline and milestone quality**:
   - Are milestones concrete and sequenced logically?
   - Are deadlines, dependencies, and review points visible?
   - Are the proposed outputs achievable within the stated period?

3. **Team composition and roles**:
   - Does the team collectively appear qualified?
   - Are roles and responsibilities clear?
   - Are there single points of failure or expertise gaps?

4. **Management and coordination**:
   - If the project is collaborative, does the proposal explain who is responsible for what and how coordination will work?
   - Is there a governance or decision structure where one is needed?

5. **Resourcing vs. plan alignment**:
   - Are personnel effort, subcontracting, equipment, travel, or consultant costs aligned with the actual work?
   - Is there evidence of unrealistic staffing assumptions?

6. **Supporting-document completeness**:
   - Flag missing or weak budget justification, timeline, management plan, biosketches/CVs, letters of support, facilities/resources statements, or data-management plans when these appear relevant.

**Output format:**
```
## Agent 5: Budget, Timeline, Team & Management Plan

### Budget or Resource Concerns
[numbered list: Category or task | Concern | Why it matters | Suggested fix]

### Timeline or Milestone Problems
[numbered list: Milestone/task | Issue | Recommended revision]

### Team or Management Gaps
[numbered list: Gap | Evidence | Recommended remedy]

### Missing or Weak Supporting Documents
[numbered list: Document | Why it seems needed | Suggested action]

### Minor Resource or Coordination Issues
[numbered list: same format as above]
```

The proposal files to review are: [LIST ALL FILE PATHS HERE]

---

### AGENT 6 — Adversarial Panel Review & Funding Recommendation

You are a demanding panel reviewer. Adopt the persona and review norms appropriate to `TARGET_PROGRAM`:
- If it is a specific sponsor or program (e.g., NSF, NIH, ERC, HorizonEurope), apply that sponsor's likely expectations about significance, rigor, feasibility, team credibility, and public value.
- If `TARGET_PROGRAM` is `major-funder`, apply high general standards for a competitive major external grant without a specific sponsor persona.
- If `TARGET_PROGRAM` is `foundation`, apply the standards of a selective mission-driven foundation that expects a clear theory of change, focused scope, and practical impact.

In all cases: you have reviewed many proposals and have extremely high standards. You are deciding whether this proposal should be funded, discussed seriously but revised, or declined. You are not hostile, but you are exacting, specific, and rigorous. Read the complete accessible proposal materials and produce a structured evaluation.

**Your evaluation has 6 parts:**

**Part 1 — The Core Funding Case**

State in one sentence what the proposal is asking the funder to support. Then evaluate:
- What is the central reason to fund this project?
- Is the case for importance compelling?
- Is the project differentiated from routine or incremental work?
- Rate the proposal: [Outstanding | Competitive | Borderline | Not Competitive]
- Justify your rating in 2-3 sentences.

**Part 2 — Major Strengths**

- What are the 3-5 strongest aspects of the proposal?
- Which strengths are most likely to persuade reviewers?
- Are any strengths present but not presented effectively enough?

**Part 3 — Major Weaknesses**

- What are the 3-5 biggest reasons this proposal could be declined?
- Which weakness is most likely to damage the score most severely?
- Are the weaknesses fatal, repairable, or mostly presentational?

**Part 4 — Required Revisions Before Submission**

List 3-6 revisions that are necessary before this proposal should be submitted or resubmitted.
For each revision:
- state precisely what must change
- explain why it matters for panel review
- explain what improvement it would create

**Part 5 — Funding Fit and Strategic Positioning**

- Is this proposal a strong fit for `TARGET_PROGRAM`?
- If not, what kind of sponsor or scheme would be a better fit?
- Is the requested scale and ambition matched to the likely funding mechanism?
- What concrete repositioning would most improve competitiveness?

**Part 6 — Panel Questions to the PI**

Write 5-8 pointed questions that a skeptical review panel would ask the PI. These should probe the proposal's weakest points on significance, feasibility, fit, budget, staffing, and evidence.

**Output format:**
```
## Agent 6: Adversarial Panel Review & Funding Recommendation

### Part 1 — Core Funding Case
[assessment + rating]

### Part 2 — Major Strengths
[numbered list]

### Part 3 — Major Weaknesses
[numbered list]

### Part 4 — Required Revisions Before Submission
[numbered list]

### Part 5 — Funding Fit and Strategic Positioning
[assessment]

### Part 6 — Panel Questions to the PI
[numbered list]
```

The proposal files to review are: [LIST ALL FILE PATHS HERE]

---

## Phase 3: Consolidate and Save

After all 6 agents return their results, consolidate them into a single structured report. Before saving, check whether `GRANT_PROPOSAL_REVIEW_[YYYY-MM-DD].md` already exists in the current directory. If it does, append `-v2` (or `-v3`, etc.) to avoid overwriting.

Save the report to:

`GRANT_PROPOSAL_REVIEW_[YYYY-MM-DD].md`

where `[YYYY-MM-DD]` is today's date.

**Report structure:**

```markdown
# Grant Proposal Review

**Proposal**: [Title]
**PI(s)/Team**: [PI(s) or team]
**Date**: [Today's date]
**Review Standard**: [TARGET_PROGRAM — if `major-funder`, write "Competitive Major Funder"; if `foundation`, write "Foundation"; otherwise write the specific program/funder name]

---

## Overall Assessment

[3–4 sentences: What the proposal aims to do, its principal strength, and the single most critical issue
that must be resolved before submission.]

**Preliminary Recommendation**: [Submit as-is | Revise before submitting | Substantial revision required | Do not submit in current form]

---
## Priority Action Items

The following issues require attention before submission, ordered by priority. When ranking across agents, apply this triage hierarchy: sponsor fit and competitive weakness (Agent 3, Agent 6) > methodological and feasibility risks (Agent 4) > internal inconsistencies and unsupported deliverables (Agent 2) > budget, timeline, and team gaps (Agent 5) > clarity and compliance signals (Agent 1). Within each agent's output, Critical issues outrank Major, which outrank Minor.

**CRITICAL** (must fix — these could sink the proposal in panel review):
1. ...
2. ...
3. ...

**MAJOR** (should fix — these are likely to weaken scores materially):
4. ...
5. ...
6. ...
7. ...

**MINOR** (polish — improves reviewer confidence and readability):
8. ...
9. ...
10. ...

---

## Adversarial Panel Review & Funding Recommendation

[Agent 6 output]

---

## Internal Consistency, Scope & Deliverables

[Agent 2 output]

---

## Significance, Innovation & Fit to the Call

[Agent 3 output]

---

## Research Design, Methods & Feasibility

[Agent 4 output]

---

## Budget, Timeline, Team & Management Plan

[Agent 5 output]

---

## Clarity, Writing Quality & Compliance Signals

[Agent 1 output, preserving its structure]

---

```

After saving, report to the user:
1. The path to the saved report
2. The preliminary recommendation from Agent 6
3. The top 5 priority action items
4. How many issues were flagged in each category (counts)
