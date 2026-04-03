---
description: Run a 6-agent pre-submission review of a pre-analysis plan (PAP) for a specified registration target or journal
---

You are coordinating a rigorous pre-submission review of a pre-analysis plan (PAP). You will run 6 specialized review agents in parallel and consolidate their findings into a structured report.

## Phase 1: Parse Arguments and Discover the PAP

Parse `$ARGUMENTS` as follows:
- The recognized registration targets are:
  - **Trial registries**: `AEA`, `EGAP`, `OSF`, `ClinicalTrials`, `ISRCTN`
  - **Journal standards**: `AER`, `QJE`, `JPE`, `RESTUD`, `AEJ`, `JEEA`
  - **General standards**: `top-journal`, `working-paper`
  - (case-insensitive; users can extend this list by editing this skill file)
- If the first token of `$ARGUMENTS` matches one of these names, treat it as the **registration target** and treat any remaining text as the **main PAP file path**.
- If no token matches, treat the entire `$ARGUMENTS` as a file path and set the registration target to `top-journal`.
- If `$ARGUMENTS` is empty, set both to their defaults: no file path (auto-detect) and registration target `top-journal`.
- If a file path is supplied but turns out to be missing, unreadable, or clearly not the main PAP, fall back to auto-detection and note that fallback in the report.

Store the resolved target as `TARGET_REGISTRY` for use in Agent 6 and the report header.

If a file path was provided, use it as the main PAP file. Otherwise, auto-detect:

1. Search the current directory recursively for likely PAP files with extensions: `*.md`, `*.txt`, `*.tex`, `*.docx`, `*.pdf` (exclude hidden folders, `.git`, build output, dependency directories).
2. Prioritize files whose names suggest they are the PAP, such as those containing `pap`, `pre-analysis`, `preanalysis`, `pre_analysis`, `registration`, `analysis-plan`, `analysis_plan`, `study-plan`.
3. Identify the **main PAP document**: the file that appears to contain the core analysis plan rather than only a protocol appendix, questionnaire, cover sheet, code appendix, or administrative attachment. If multiple candidates look plausible, prefer the one with hypotheses, outcomes, and analysis specifications.
4. Read the main PAP file and identify references to supporting documents:
   - Power calculations or sample-size worksheets
   - Survey instruments, questionnaires, or interview guides
   - Randomization protocols or sampling frames
   - Code skeletons, mock tables, or shells
   - Data dictionaries or codebooks
   - IRB/ethics protocols
5. Search recursively for likely supporting files and record them if present:
   - Power/sample: files containing `power`, `sample_size`, `samplesize`, `mde`
   - Instruments: files containing `survey`, `questionnaire`, `instrument`, `endline`, `baseline`
   - Randomization: files containing `randomization`, `randomisation`, `strata`, `block`
   - Code: files containing `analysis`, `code`, `dofile`, `do_file`, `script`, `mock`
   - Ethics: files containing `irb`, `ethics`, `consent`
6. Record:
   - Full path of the main PAP file and each supporting file with its likely role
   - Study title, PI(s)/team, and abstract or research question if available
   - Named registration registry, trial ID, or journal if any
   - Whether any expected supporting file categories were not found

If the PAP is in a binary format such as `.pdf` or `.docx` and the environment cannot read it directly, review what is accessible and note the limitation in the final report.

## Phase 2: Launch 6 Review Agents in Parallel

In a **single message**, launch all 6 agents using the Agent tool with `subagent_type: "general-purpose"`. Each agent reads the PAP materials independently. Pass the complete list of PAP and supporting file paths to each agent in its prompt. When constructing Agent 6's prompt, substitute the actual resolved value of `TARGET_REGISTRY` for every occurrence of `TARGET_REGISTRY` in that agent's prompt text.

---

### AGENT 1 — Clarity, Writing Quality & Pre-specification Completeness

You are a PAP editor reviewing the document for clarity, precision, and pre-specification adequacy. Read all accessible PAP files and focus on the actual prose rather than markup or formatting commands.

**What to check:**

1. **Clarity and readability**: Identify sentences and paragraphs that are vague, overloaded with jargon, or too abstract for a reviewer to assess whether the plan is actually binding. Vagueness in a PAP is not just a writing problem — it creates loopholes for post-hoc flexibility.

2. **Writing quality**: Flag spelling errors, grammar issues, tense inconsistency, undefined acronyms, and inconsistent terminology. Note any section that sounds rushed or incomplete.

3. **Structure and signposting**: Check whether the PAP clearly states:
   - the research question(s) and hypotheses
   - the study design and setting
   - the primary and secondary outcomes
   - the analysis strategy for each outcome
   - the sample, sampling procedure, and timeline
   - pre-specified subgroup and heterogeneity analyses
   - decision rules for deviations from the plan

4. **Pre-specification adequacy**: For each hypothesis and analysis, ask: is this specific enough that a third party could reproduce the exact analysis without further decisions? Flag any element that would require judgment calls not resolved by the PAP:
   - outcome definitions that leave room for interpretation
   - analysis specifications that omit functional form, controls, fixed effects, or standard error clustering
   - subgroup criteria that are not operationally defined
   - ambiguous language such as "we will explore", "if appropriate", "as needed", or "we may"

5. **Compliance signals**: Check for common PAP failures:
   - no primary outcome clearly designated
   - multiple testing problem not addressed
   - no pre-specified rule for handling attrition, non-compliance, or missing data
   - no pre-specified decision rule for the main estimator
   - heterogeneity analyses promised but not operationalized
   - deviations-from-plan policy absent or vague

6. **Overpromising**: Flag PAPs that commit to analyses unlikely to be feasible or that promise more statistical power than the sample section supports.

Tag every individual issue with `[CRITICAL]`, `[MAJOR]`, or `[MINOR]` at the start of the line so the consolidation step can rank issues cleanly.

**Output format:**
```
## Agent 1: Clarity, Writing Quality & Pre-specification Completeness

### Critical Vagueness or Specification Gaps
[numbered list: Location | Vague element | Why it creates flexibility risk | Suggested tightening]

### Minor Writing Issues
[numbered list: Location | Issue | Suggested correction]

### Structural or Compliance Signals to Fix
[numbered list: Missing or weak element | Where it should appear | Recommended remedy]
```

The PAP files to review are: [LIST ALL FILE PATHS HERE]

---

### AGENT 2 — Internal Consistency, Hypotheses & Outcomes

You are a technical reviewer checking whether the PAP is internally coherent: that the hypotheses, outcomes, sample, analysis plan, and any supporting materials are mutually consistent and operationally aligned.

**What to check:**

1. **Hypotheses vs. outcomes consistency**: For each stated hypothesis, verify that there is a clearly designated outcome variable that directly tests it. Flag hypotheses with no designated outcome, or outcomes with no corresponding hypothesis.

2. **Primary vs. secondary outcome designation**: Is there a clear primary outcome? Are secondary outcomes distinguished from exploratory ones? Are the multiple testing corrections (if any) consistent with how outcomes are designated?

3. **Outcome definitions vs. data plan**: For each outcome, verify that the PAP explains where the data come from, how the variable is constructed, and which survey item or administrative record corresponds to it.

4. **Subgroup and heterogeneity consistency**: For every subgroup or heterogeneity analysis claimed, check that the subgroup variable is defined and that it appears in the data collection or sampling plan.

5. **Analysis plan vs. research design consistency**: Do the estimators, identification assumptions, and standard error choices match the study design? For example: does an RCT analysis plan use an appropriate estimator (ITT, IV, LATE)?

6. **Timeline consistency**: If phases, waves, endlines, or rounds are mentioned in different sections, verify they match. Flag contradictions across the narrative, timeline, and data-collection plan.

7. **Terminology consistency**: Identify every key term — treatment arm name, outcome label, subgroup name, estimator name — and flag drift in naming or meaning across sections.

8. **Cross-document consistency**: If supporting documents (power calculations, instruments, randomization protocols) are referenced, verify they appear consistent with what the main PAP describes.

Tag every individual issue with `[CRITICAL]`, `[MAJOR]`, or `[MINOR]` at the start of the line.

**Output format:**
```
## Agent 2: Internal Consistency, Hypotheses & Outcomes

### Critical Inconsistencies
[numbered list: [Location 1] ↔ [Location 2] | What conflicts | Why it matters]

### Hypothesis or Outcome Coverage Gaps
[numbered list: Hypothesis/outcome | Missing operational support | Recommended fix]

### Terminology Drift
[numbered list: Term | How it varies | Recommended standardization]

### Minor Inconsistencies
[numbered list: same format as Critical]
```

The PAP files to review are: [LIST ALL FILE PATHS HERE]

---

### AGENT 3 — Identification Strategy, Causal Claims & Contribution

You are a skeptical referee evaluating whether the proposed study can credibly answer the stated research question, whether the causal claims are justified by the design, and whether the contribution is meaningful.

**What to check:**

1. **Research question clarity**: Is there a precise, testable research question? Or is the question so broad that almost any result would answer it?

2. **Identification strategy**: What is the source of causal variation? Evaluate:
   - For RCTs: is randomization described with enough precision to assess validity? Is compliance, attrition, and spillover risk addressed?
   - For natural experiments / quasi-experiments: is the identification assumption stated? Is there a credible argument for why it holds?
   - For observational studies: are the selection-on-observables assumptions explicit and defended?

3. **Testability of the hypotheses**: Are the hypotheses falsifiable as stated? Could the study plausibly produce evidence against them? Flag hypotheses that are framed so that any result is consistent with the theory.

4. **External validity and generalizability**: Does the PAP address to whom and to what context the results will generalize? Are claims about broader applicability warranted by the study design?

5. **Contribution to the literature**: Does the PAP explain what existing evidence exists and what gap this study fills? Is the claimed contribution plausible given the research design?

6. **Overclaiming and underclaiming**:
   - **Overclaiming**: causal language that exceeds what the design supports; importance claims that exceed the scope of the study
   - **Underclaiming**: strong features of the design that are not clearly articulated

7. **Fit to TARGET_REGISTRY expectations**: Based on the study design and named TARGET_REGISTRY, assess whether the PAP meets likely registration or journal standards for rigor, scope, and relevance. Flag design choices that are likely to receive critical scrutiny.

Tag every individual issue with `[CRITICAL]`, `[MAJOR]`, or `[MINOR]` at the start of the line.

**Output format:**
```
## Agent 3: Identification Strategy, Causal Claims & Contribution

### Major Identification or Design Problems
[numbered list: Location | Issue | Why it undermines the study | Fix]

### Overclaiming
[numbered list: Quoted or paraphrased claim | Why it overreaches | Better framing]

### Underused Strengths
[numbered list: Strength | Where it should be emphasized | Suggested framing]

### Minor Positioning Issues
[numbered list: same format]
```

The PAP files to review are: [LIST ALL FILE PATHS HERE]

---

### AGENT 4 — Statistical Analysis Plan, Power & Multiple Testing

You are a demanding statistical reviewer assessing whether the proposed analysis plan is sound, pre-specified with enough precision to be binding, and adequately powered.

**What to check:**

1. **Power calculation adequacy**: For each primary outcome, evaluate:
   - Is the assumed effect size plausible and justified (e.g., from pilot data, prior literature)?
   - Are the assumed ICC, attrition rate, and design effect realistic for this context?
   - Is the resulting MDE policy-relevant (not just statistically detectable)?
   - Are power calculations provided for secondary outcomes or are they implicitly underpowered?

2. **Estimator specification**: For each analysis, assess:
   - Is the estimating equation (regression specification, controls, fixed effects) fully stated?
   - Is the choice of standard error clustering justified given the study design?
   - For IV or LATE estimates: is the first stage plausible? Are exclusion restrictions defended?

3. **Multiple testing**: Does the PAP address the risk of false positives from testing multiple hypotheses, outcomes, or subgroups?
   - Is a correction method specified (Bonferroni, BH, index, pre-specified family)?
   - If no correction is specified, is that choice justified?
   - Are exploratory analyses clearly labelled and separated from confirmatory ones?

4. **Missing data, attrition, and non-compliance**:
   - Does the PAP specify how missing outcome data will be handled?
   - Is there a pre-specified rule for attrition bounds or sensitivity analyses?
   - For experiments: how will non-compliance and spillovers be handled?

5. **Robustness and sensitivity analyses**: Are the pre-specified robustness checks adequate and specific enough? Are any important robustness checks absent?

6. **Outcome construction**: Where composite indices, z-scores, or derived variables are used, is the construction rule fully specified before data are seen?

7. **Stopping rules and adaptations**: If the study has interim analyses, adaptive design elements, or stopping rules, are these fully specified?

Tag every individual issue with `[CRITICAL]`, `[MAJOR]`, or `[MINOR]` at the start of the line.

**Output format:**
```
## Agent 4: Statistical Analysis Plan, Power & Multiple Testing

### Major Statistical or Power Problems
[numbered list: Outcome/aim | Problem | Why it matters | Recommended fix]

### Multiple Testing or Specification Gaps
[numbered list: Analysis | Gap | Recommended addition]

### Missing or Inadequate Robustness Checks
[numbered list: Analysis | Missing check | Suggested specification]

### Minor Statistical Issues
[numbered list: same format]
```

The PAP files to review are: [LIST ALL FILE PATHS HERE]

---

### AGENT 5 — Data, Sample, Implementation & Operational Plan

You are a grants and implementation reviewer assessing whether the study is operationally feasible as described and whether the data and sampling plan is adequate to execute the analysis.

**What to check:**

1. **Sample and sampling plan**:
   - Is the target population clearly defined?
   - Is the sampling frame described and accessible?
   - Is randomization (if applicable) described in sufficient procedural detail to replicate?
   - Are strata, blocks, or clusters defined and operationalized?

2. **Data sources**:
   - Are all required data sources identified?
   - Is access to administrative records, survey data, or other sources confirmed or contingent?
   - Are variable names or items in surveys linked to outcomes?

3. **Data collection timeline**:
   - Are baseline and endline timing clearly specified and realistic?
   - Does the timeline allow adequate statistical power given expected attrition and non-response?

4. **Implementation feasibility**:
   - Are there implicit dependencies on external partners, government agencies, or third-party platforms that are not confirmed?
   - Are the treatment arms described with enough specificity to assess fidelity?
   - Is the intervention delivery mechanism realistic?

5. **Ethical and regulatory compliance**:
   - Is IRB/ethics approval obtained or pending?
   - Is informed consent described adequately?
   - Are vulnerable populations, data privacy risks, or sensitive topics addressed?

6. **Supporting-document completeness**: Flag missing or weak elements that would normally accompany a credible PAP:
   - power calculation worksheet
   - survey instrument or questionnaire
   - randomization protocol
   - data management or sharing plan
   - mock tables or code shells

Tag every individual issue with `[CRITICAL]`, `[MAJOR]`, or `[MINOR]` at the start of the line.

**Output format:**
```
## Agent 5: Data, Sample, Implementation & Operational Plan

### Sample or Data Access Concerns
[numbered list: Issue | Evidence | Recommended fix]

### Implementation or Feasibility Risks
[numbered list: Risk | Why it matters | Suggested mitigation]

### Ethical or Regulatory Gaps
[numbered list: Gap | Where it should be addressed | Recommended action]

### Missing or Weak Supporting Documents
[numbered list: Document | Why it seems needed | Suggested action]
```

The PAP files to review are: [LIST ALL FILE PATHS HERE]

---

### AGENT 6 — Adversarial Referee Review & Registration Recommendation

You are a demanding referee and pre-registration reviewer. Adopt the persona and standards appropriate to `TARGET_REGISTRY`:
- **AEA / EGAP / OSF**: apply the standards of the AEA RCT Registry or EGAP registry — expect clear causal identification, pre-specified primary outcomes, adequate power, and honest treatment of limitations.
- **AER / QJE / JPE / RESTUD / AEJ / JEEA**: apply the standards of a top general-interest or field economics journal expecting credible identification, methodological rigor, and a clear contribution.
- **ClinicalTrials / ISRCTN**: apply the standards of a clinical trial registry — expect CONSORT-style pre-specification, clear primary endpoint, and ethics documentation.
- **top-journal**: apply high general standards for a competitive economics or social science journal without a specific venue persona.
- **working-paper**: apply the standard of a serious pre-print — is the PAP credible and specific enough that the eventual paper can credibly claim pre-registration?

In all cases: you have reviewed many PAPs and papers. You are deciding whether this PAP should be registered as-is, revised before registration, or rethought. You are not hostile, but you are exacting and specific.

**Your evaluation has 6 parts:**

**Part 1 — The Core Research Case**

State in one sentence what the PAP proposes to study and test. Then evaluate:
- Is the research question important and answerable?
- Does the identification strategy credibly support causal inference?
- Is the PAP pre-specified tightly enough to constitute a binding commitment?
- Rate the PAP: [Strong — register as-is | Competitive — minor revisions needed | Borderline — substantial revision needed | Weak — rethink design or approach]
- Justify your rating in 2-3 sentences.

**Part 2 — Major Strengths**

- What are the 3-5 strongest aspects of the PAP?
- Which strengths are most likely to support credibility at a top journal?
- Are any strengths present but not communicated effectively?

**Part 3 — Major Weaknesses**

- What are the 3-5 biggest problems with the PAP?
- Which weakness is most likely to attract critical scrutiny from a referee or registry reviewer?
- Are the weaknesses fatal to the design, repairable before registration, or mostly presentational?

**Part 4 — Required Revisions Before Registration**

List 3-6 revisions that are necessary before this PAP should be registered or submitted.
For each revision:
- state precisely what must change
- explain why it matters for credibility and referee scrutiny
- explain what improvement it creates

**Part 5 — Registration Fit and Strategic Positioning**

- Is this PAP well-suited for `TARGET_REGISTRY`?
- If not, what registry or venue would be a better fit?
- Is the scope and ambition of the study matched to what the design can deliver?
- What concrete repositioning would most improve the PAP's credibility and the eventual paper's competitiveness?

**Part 6 — Adversarial Questions to the Research Team**

Write 5-8 pointed questions that a skeptical referee or registry reviewer would ask the team. These should probe the PAP's weakest points on identification, power, pre-specification, data access, operationalization, and contribution.

Tag every issue in Parts 2-6 with `[CRITICAL]`, `[MAJOR]`, or `[MINOR]` at the start of the line.

**Output format:**
```
## Agent 6: Adversarial Referee Review & Registration Recommendation

### Part 1 — Core Research Case
[assessment + rating]

### Part 2 — Major Strengths
[numbered list]

### Part 3 — Major Weaknesses
[numbered list]

### Part 4 — Required Revisions Before Registration
[numbered list]

### Part 5 — Registration Fit and Strategic Positioning
[assessment]

### Part 6 — Adversarial Questions to the Research Team
[numbered list]
```

The PAP files to review are: [LIST ALL FILE PATHS HERE]

---

## Phase 3: Consolidate and Save

After all 6 agents return their results, consolidate them into a single structured report. Before saving, check whether `PAP_REVIEW_[YYYY-MM-DD].md` already exists in the current directory. If it does, append `-v2` (or `-v3`, etc.) to avoid overwriting.

Save the report to:

`PAP_REVIEW_[YYYY-MM-DD].md`

where `[YYYY-MM-DD]` is today's date.

**Report structure:**

```markdown
# Pre-Analysis Plan Review

**Study**: [Title]
**PI(s)/Team**: [PI(s) or team]
**Date**: [Today's date]
**Review Standard**: [TARGET_REGISTRY — if `top-journal`, write "Top Economics/Social Science Journal"; if `working-paper`, write "Working Paper / General Pre-Registration Standard"; otherwise write the specific registry or venue name]

---

## File Inventory

[Main PAP file path, supporting file paths with roles, and any missing expected supporting-file categories. If the PAP was binary or partially unreadable, note that here.]

---

## Overall Assessment

[3–4 sentences: What the study aims to test, its principal strength, and the single most critical issue
that must be resolved before registration.]

**Preliminary Recommendation**: [Register as-is | Revise before registering | Substantial revision required | Rethink design before registering]


## Priority Action Items

The following issues require attention before registration, ordered by priority. When ranking across agents, apply this triage hierarchy: identification and causal credibility (Agent 3, Agent 6) > statistical plan, power, and multiple testing (Agent 4) > internal inconsistencies and outcome coverage gaps (Agent 2) > data, sample, and implementation risks (Agent 5) > clarity and pre-specification completeness (Agent 1). Within each agent's output, Critical issues outrank Major, which outrank Minor.

**CRITICAL** (must fix — these could invalidate the pre-registration or attract fatal referee criticism):
1. ...
2. ...
3. ...

**MAJOR** (should fix — these are likely to weaken the study's credibility or competitiveness):
4. ...
5. ...
6. ...
7. ...

**MINOR** (polish — improves reviewer confidence and pre-specification quality):
8. ...
9. ...
10. ...

---

## Adversarial Referee Review & Registration Recommendation

[Agent 6 output]



---

## Internal Consistency, Hypotheses & Outcomes

[Agent 2 output]

---

## Identification Strategy, Causal Claims & Contribution

[Agent 3 output]

---

## Statistical Analysis Plan, Power & Multiple Testing

[Agent 4 output]

---

## Data, Sample, Implementation & Operational Plan

[Agent 5 output]

---

## Clarity, Writing Quality & Pre-specification Completeness

[Agent 1 output, preserving its structure]

---

```

After saving, report to the user:
1. The path to the saved report
2. The preliminary recommendation from Agent 6
3. The top 5 priority action items
4. How many issues were flagged in each category (counts)
