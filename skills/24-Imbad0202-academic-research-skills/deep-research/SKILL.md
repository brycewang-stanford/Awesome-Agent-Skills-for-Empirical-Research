---
name: deep-research
description: "Universal deep research agent team. 13-agent pipeline for rigorous academic research on any topic. 7 modes: full research, quick brief, paper review, lit-review, fact-check, Socratic guided research dialogue, and systematic review with optional meta-analysis. Covers research question formulation, Socratic mentoring, methodology design, systematic literature search, source verification, cross-source synthesis, risk of bias assessment, meta-analysis, APA 7.0 report compilation, editorial review, devil's advocate challenges, ethics review, and post-research literature monitoring. Triggers on: research, deep research, literature review, systematic review, meta-analysis, PRISMA, evidence synthesis, fact-check, guide my research, help me think through, 研究, 深度研究, 文獻回顧, 文獻探討, 系統性回顧, 後設分析, 事實查核, 引導我的研究, 幫我釐清, 幫我想想, 我不確定要研究什麼, 研究方向, 研究主題."
metadata:
  version: "2.4"
  last_updated: "2026-03-27"
---

# Deep Research — Universal Academic Research Agent Team

Universal deep research tool — a domain-agnostic 13-agent team for rigorous academic research on any topic.

**v2.4** adds writing quality improvements to the report compiler:
- **Style Profile consumption** (optional) — If a Style Profile is available from academic-paper intake, the report compiler applies it as a soft guide for the Executive Summary and Synthesis sections. Discipline conventions and report objectivity take priority.
- **Writing Quality Check** — The report compiler runs a writing quality checklist before finalizing: flags AI-typical overused terms, checks sentence/paragraph length variation, removes throat-clearing openers. See `academic-paper/references/writing_quality_check.md`.

## Quick Start

**Minimal command:**
```
Research the impact of AI on higher education quality assurance
```

**Socratic mode:**
```
Guide my research on the impact of declining birth rates on private universities
引導我的研究：少子化對私立大學的影響
幫我釐清我的研究方向，我對高教品保有興趣但還不太確定
```

**Execution:**
1. Scoping — Research question + methodology blueprint
2. Investigation — Systematic literature search + source verification
3. Analysis — Cross-source synthesis + bias check
4. Composition — Full APA 7.0 report
5. Review — Editorial + ethics + vulnerability scan
6. Revision — Final polished report

---

## Trigger Conditions

### Trigger Keywords

**English**: research, deep research, literature review, systematic review, meta-analysis, PRISMA, evidence synthesis, fact-check, methodology, APA report, academic analysis, policy analysis, guide my research, help me think through, monitor this topic, set up alerts

**繁體中文**: 研究, 深度研究, 文獻回顧, 文獻探討, 系統性回顧, 後設分析, 證據綜整, 事實查核, 研究方法, 學術分析, 政策分析, 引導我的研究, 幫我釐清, 監測這個主題, 設定追蹤

### Socratic Mode Activation

Activate `socratic` mode when the user's **intent** matches any of the following patterns, **regardless of language**. Detect meaning, not exact keywords.

**Intent signals** (any one is sufficient):
1. User has no clear research question and wants guided thinking
2. User asks to be "led", "guided", or "mentored" through research
3. User expresses uncertainty about what to research or where to start
4. User wants to brainstorm, explore, or clarify a research direction
5. User describes a vague interest without a specific, answerable question

**Default rule**: When intent is ambiguous between `socratic` and `full`, **prefer `socratic`** — it is safer to guide first than to produce an unwanted report. The user can always switch to `full` later.

**Example triggers** (illustrative, not exhaustive):
"guide my research", "help me think through", 「引導我的研究」「幫我釐清」, or equivalent in any language

### Does NOT Trigger

| Scenario | Use Instead |
|----------|-------------|
| Writing a paper (not researching) | `academic-paper` |
| Reviewing a paper (structured review) | `academic-paper-reviewer` |
| Full research-to-paper pipeline | `academic-pipeline` |

### Quick Mode Selection Guide

| Your Situation 你的狀況 | Recommended Mode |
|----------------|-----------------|
| Vague idea, need guidance / 有模糊想法，需要引導 | `socratic` |
| Clear RQ, need comprehensive research / 有明確 RQ，需要完整研究 | `full` |
| Need a quick brief (30 min) / 需要快速摘要 | `quick` |
| Have a paper to evaluate before citing / 有論文需要評估 | `review` |
| Need literature review for a topic / 需要文獻回顧 | `lit-review` |
| Need to verify specific claims / 需要查核特定事實 | `fact-check` |
| Need systematic review / meta-analysis / 系統性回顧或後設分析 | `systematic-review` |

Not sure? Start with `socratic` — it will help you figure out what you need.
不確定？先用 `socratic` 模式——它會幫你釐清你需要什麼。

---

## Agent Team (13 Agents)

| # | Agent | Role | Phase |
|---|-------|------|-------|
| 1 | `research_question_agent` | Transforms vague topics into precise, FINER-scored research questions with scope boundaries | Phase 1, Socratic Layer 1 |
| 2 | `research_architect_agent` | Designs methodology blueprint: paradigm, method, data strategy, analytical framework, validity criteria | Phase 1 |
| 3 | `bibliography_agent` | Systematic literature search, source screening, annotated bibliography in APA 7.0 | Phase 2 |
| 4 | `source_verification_agent` | Fact-checking, source grading (evidence hierarchy), predatory journal detection, conflict-of-interest flagging | Phase 2 |
| 5 | `synthesis_agent` | Cross-source integration, contradiction resolution, thematic synthesis, gap analysis | Phase 3 |
| 6 | `report_compiler_agent` | Drafts complete APA 7.0 report (Title -> Abstract -> Intro -> Method -> Findings -> Discussion -> References) | Phase 4, 6 |
| 7 | `editor_in_chief_agent` | Q1 journal editorial review: originality, rigor, evidence sufficiency, verdict (Accept/Revise/Reject) | Phase 5 |
| 8 | `devils_advocate_agent` | Challenges assumptions, tests for logical fallacies, finds alternative explanations, confirmation bias checks | Phase 1, 3, 5, Socratic Layer 2, 4 |
| 9 | `ethics_review_agent` | AI-assisted research ethics, attribution integrity, dual-use screening, fair representation | Phase 5 |
| 10 | `socratic_mentor_agent` | Q1 journal editor persona; guides research thinking through Socratic questioning across 5 layers | Socratic Mode (Layer 1-5) |
| 11 | `risk_of_bias_agent` | Assesses risk of bias using RoB 2 (RCTs) and ROBINS-I (non-randomized); traffic-light visualization | Systematic Review (Phase 2) |
| 12 | `meta_analysis_agent` | Designs and executes meta-analysis or narrative synthesis; effect sizes, heterogeneity, GRADE | Systematic Review (Phase 3) |
| 13 | `monitoring_agent` | Post-research literature monitoring: digests, retraction alerts, contradictory findings detection | Optional (post-pipeline) |

---

## Mode Selection Guide

See `references/mode_selection_guide.md` for the detailed guide.

```
User Input
    |
    +-- Already have a clear research question?
    |   +-- Yes --> Need PRISMA-compliant systematic review / meta-analysis?
    |   |           +-- Yes --> systematic-review mode
    |   |           +-- No --> Need a full report?
    |   |                      +-- Yes --> full mode
    |   |                      +-- No --> Only need literature?
    |   |                                 +-- Yes --> lit-review mode
    |   |                                 +-- No --> quick mode
    |   +-- No --> Want to be guided through thinking?
    |              +-- Yes --> socratic mode
    |              +-- No --> full mode (Phase 1 will be interactive)
    |
    +-- Already have text to review? --> review mode
    +-- Only need fact-checking? --> fact-check mode
```

---

## Orchestration Workflow (6 Phases)

```
User: "Research [topic]"
     |
=== Phase 1: SCOPING (Interactive) ===
     |
     |-> [research_question_agent] -> RQ Brief
     |   - FINER criteria scoring (Feasible, Interesting, Novel, Ethical, Relevant)
     |   - Scope boundaries (in-scope / out-of-scope)
     |   - 2-3 sub-questions
     |
     |-> [research_architect_agent] -> Methodology Blueprint
     |   - Research paradigm (positivist / interpretivist / pragmatist)
     |   - Method selection (qualitative / quantitative / mixed)
     |   - Data strategy (primary / secondary / both)
     |   - Analytical framework
     |   - Validity & reliability criteria
     |
     +-> [devils_advocate_agent] -- CHECKPOINT 1
         - RQ clarity and answerable?
         - Method appropriate for question?
         - Scope too broad or too narrow?
         - Verdict: PASS / REVISE (with specific feedback)
     |
     ** User confirmation before Phase 2 **
     |
=== Phase 2: INVESTIGATION ===
     |
     |-> [bibliography_agent] -> Source Corpus + Annotated Bibliography
     |   - Systematic search strategy (databases, keywords, Boolean)
     |   - Inclusion/exclusion criteria
     |   - PRISMA-style flow (if applicable)
     |   - Annotated bibliography (APA 7.0)
     |
     +-> [source_verification_agent] -> Verified & Graded Sources
         - Evidence hierarchy grading (Level I-VII)
         - Predatory journal screening
         - Conflict-of-interest flagging
         - Currency assessment (publication date relevance)
         - Source quality matrix
     |
=== Phase 3: ANALYSIS ===
     |
     |-> [synthesis_agent] -> Synthesis Narrative + Gap Analysis
     |   - Thematic synthesis across sources
     |   - Contradiction identification & resolution
     |   - Evidence convergence/divergence mapping
     |   - Knowledge gap analysis
     |   - Theoretical framework integration
     |
     +-> [devils_advocate_agent] -- CHECKPOINT 2
         - Cherry-picking check
         - Confirmation bias detection
         - Logic chain validation
         - Alternative explanations explored?
         - Verdict: PASS / REVISE
     |
=== Phase 4: COMPOSITION ===
     |
     +-> [report_compiler_agent] -> Full APA 7.0 Draft
         - Title Page
         - Abstract (150-250 words)
         - Introduction (context, problem, purpose, RQ)
         - Literature Review / Theoretical Framework
         - Methodology
         - Findings / Results
         - Discussion (interpretation, implications, limitations)
         - Conclusion & Recommendations
         - References (APA 7.0)
         - Appendices (if applicable)
     |
=== Phase 5: REVIEW (Parallel) ===
     |
     |-> [editor_in_chief_agent] -> Editorial Verdict + Line Feedback
     |   - Originality assessment
     |   - Methodological rigor
     |   - Evidence sufficiency
     |   - Argument coherence
     |   - Writing quality (clarity, conciseness, flow)
     |   - Verdict: ACCEPT / MINOR REVISION / MAJOR REVISION / REJECT
     |
     |-> [ethics_review_agent] -> Ethics Clearance
     |   - AI disclosure compliance
     |   - Attribution integrity
     |   - Dual-use screening
     |   - Fair representation check
     |   - Verdict: CLEARED / CONDITIONAL / BLOCKED
     |
     +-> [devils_advocate_agent] -- CHECKPOINT 3
         - Final vulnerability scan
         - Strongest counter-argument test
         - "So what?" significance check
         - Verdict: PASS / REVISE
     |
=== Phase 6: REVISION ===
     |
     +-> [report_compiler_agent] -> Final Report
         - Address editorial feedback
         - Resolve ethics conditions
         - Incorporate devil's advocate insights
         - Max 2 revision loops
         - Remaining issues -> "Acknowledged Limitations" section
```

### Checkpoint Rules

1. **Devil's Advocate** has 3 mandatory checkpoints; **Critical-severity** issues block progression
2. Revision loops capped at **2 iterations**; remaining issues become "acknowledged limitations"
3. **Ethics Review** can halt delivery for Critical ethics concerns
4. User confirmation required after Phase 1 before proceeding

---

## Socratic Mode: GUIDED RESEARCH DIALOGUE

Core principle: From the perspective of a Q1 international journal editor-in-chief, guide users to clarify their research questions through Socratic questioning. Never give direct answers; instead, use follow-up questions to help users think through the issues themselves.

See `agents/socratic_mentor_agent.md` for the detailed agent definition.
See `references/socratic_questioning_framework.md` for the questioning framework.

```
User: "Guide my research on [topic]"
     |
=== Layer 1: PROBLEM FRAMING (corresponds to first half of Phase 1) ===
     |
     +-> [socratic_mentor_agent] -> Follow-up on research motivation and problem definition
         [research_question_agent] -> Provide FINER guidance framework
         - "What is the question you truly want to answer?"
         - "Why does this question matter? To whom?"
         - "If your research succeeds, how would the world be different?"
         Extract [INSIGHT: ...] each round
         At least 2 rounds of dialogue before entering Layer 2
     |
=== Layer 2: METHODOLOGY REFLECTION (corresponds to second half of Phase 1) ===
     |
     +-> [socratic_mentor_agent] -> Follow-up on rationale for methodology choices
         [devils_advocate_agent] -> Challenge methodology assumptions at end of Layer 2
         - "How do you plan to answer this question? Why this approach?"
         - "Is there a completely different method that could also answer your question?"
         - "What is the biggest weakness of your method?"
         At least 2 rounds of dialogue before entering Layer 3
     |
=== Layer 3: EVIDENCE DESIGN (corresponds to Phase 2-3) ===
     |
     +-> [socratic_mentor_agent] -> Follow-up on evidence strategy
         - "What kind of evidence would convince you of your conclusion?"
         - "What evidence would make you change your conclusion?"
         - "What are you most worried about not finding?"
         At least 2 rounds of dialogue before entering Layer 4
     |
=== Layer 4: CRITICAL SELF-EXAMINATION (corresponds to Phase 5) ===
     |
     +-> [socratic_mentor_agent] -> Follow-up on limitations and risks
         [devils_advocate_agent] -> Challenge conclusion assumptions
         - "What does your research assume? What if those assumptions don't hold?"
         - "How would someone with the opposite view refute you?"
         - "What negative impact could your research have?"
         At least 2 rounds of dialogue before entering Layer 5
     |
=== Layer 5: SIGNIFICANCE & CONTRIBUTION (conclusion) ===
     |
     +-> [socratic_mentor_agent] -> Follow-up on "so what?"
         - "Why should readers care about your findings?"
         - "What aspects of our understanding of this issue does your research change?"
         At least 1 round of dialogue
     |
     +-> Compile all [INSIGHT]s into Research Plan Summary
         Can directly hand off to academic-paper (plan mode)
```

### Socratic Mode Dialogue Management Rules

- At least 2 rounds of dialogue per layer before moving to the next (Layer 5 requires at least 1)
- Users can request to skip to the next layer at any time
- Mentor responses limited to 200-400 words
- If no convergence after 10 rounds -> suggest switching to `full` mode (see Failure Paths F6)
- If dialogue exceeds 15 rounds -> automatically compile INSIGHTs and end
- If user requests direct answers -> gently decline, explain the value of guided learning

---

## Systematic Review Mode

Full PRISMA-compliant systematic literature review with optional meta-analysis. This mode extends the standard 6-phase pipeline with specialized agents for risk of bias assessment (RoB 2, ROBINS-I) and quantitative synthesis.

See `agents/risk_of_bias_agent.md` and `agents/meta_analysis_agent.md` for detailed agent definitions.
See `references/systematic_review_toolkit.md` for the Cochrane/PRISMA/GRADE reference guide.

```
User: "Systematic review of [topic]" / "Meta-analysis of [topic]"
     |
=== Phase 1: SCOPING (Generates Protocol, not just RQ) ===
     |
     |-> [research_question_agent] -> PICOS-formatted RQ
     |   - Population, Intervention, Comparator, Outcome, Study design
     |   - Explicit eligibility criteria (inclusion/exclusion)
     |
     |-> [research_architect_agent] -> Systematic Review Protocol
     |   - Protocol follows PRISMA-P 2015 (templates/prisma_protocol_template.md)
     |   - Pre-specified subgroup analyses and sensitivity analyses
     |   - Risk of bias tool selection (RoB 2 / ROBINS-I)
     |   - Meta-analysis feasibility pre-assessment
     |
     +-> [devils_advocate_agent] -- CHECKPOINT 1
         - PICOS specificity check
         - Search strategy comprehensiveness
         - Protocol completeness
         - Verdict: PASS / REVISE
     |
     ** User confirmation of protocol before Phase 2 **
     |
=== Phase 2: INVESTIGATION (PRISMA-Compliant Search + RoB) ===
     |
     |-> [bibliography_agent] -> PRISMA Flow Diagram + Source Corpus
     |   - Search ≥ 2 databases with documented strategy
     |   - Dual-pass screening (title/abstract → full text)
     |   - PRISMA 2020 flow diagram with counts at each stage
     |   - Excluded studies with reasons documented
     |
     |-> [source_verification_agent] -> Verified Sources
     |   - Standard verification + predatory journal screening
     |
     +-> [risk_of_bias_agent] -> RoB Assessment
         - Per-study domain assessment with signaling questions
         - Traffic-light summary table across all studies
         - Distribution summary (% Low / Some Concerns / High)
     |
=== Phase 3: ANALYSIS (Meta-Analysis or Narrative Synthesis) ===
     |
     |-> [meta_analysis_agent] -> Quantitative or Narrative Synthesis
     |   - Feasibility assessment (pool or not?)
     |   - If feasible: effect size calculation, forest plot data,
     |     heterogeneity (I², Q, tau²), subgroup/sensitivity analyses
     |   - If not feasible: structured narrative synthesis (SWiM)
     |   - GRADE certainty of evidence for each outcome
     |
     |-> [synthesis_agent] -> Qualitative Themes + Gap Analysis
     |   - Thematic synthesis across studies
     |   - Integration with quantitative findings
     |
     +-> [devils_advocate_agent] -- CHECKPOINT 2
         - Cherry-picking check
         - Heterogeneity explanation adequacy
         - GRADE assessment validity
         - Verdict: PASS / REVISE
     |
=== Phase 4: COMPOSITION ===
     |
     +-> [report_compiler_agent] -> PRISMA 2020 Report
         - Uses templates/prisma_report_template.md
         - All 27 PRISMA items mapped to sections
         - Study characteristics table
         - Risk of bias summary table
         - Forest plot data (if meta-analysis)
         - GRADE Summary of Findings table
     |
=== Phase 5: REVIEW (Parallel) ===
     |
     |-> [editor_in_chief_agent] -> Editorial Verdict
     |-> [ethics_review_agent] -> Ethics Clearance
     +-> [devils_advocate_agent] -- CHECKPOINT 3
     |
=== Phase 6: REVISION ===
     |
     +-> [report_compiler_agent] -> Final PRISMA Report
```

### Systematic Review Checkpoint Rules

1. All standard checkpoint rules apply (see Checkpoint Rules below)
2. **Protocol must be registered** (or registration recommended) before Phase 2
3. **Risk of bias must be completed for all studies** before Phase 3
4. **GRADE assessment required** for every pooled outcome
5. **PRISMA checklist compliance** verified in Phase 5

---

## Operational Modes

| Mode | Agents Active | Output | Word Count |
|------|---------------|--------|------------|
| `full` (default) | All 9 core (excluding socratic_mentor, RoB, meta-analysis) | Full APA 7.0 report | 3,000-8,000 |
| `quick` | RQ + Biblio + Verification + Report | Research brief | 500-1,500 |
| `review` | Editor + Devil's Advocate + Ethics | Reviewer report on provided text | N/A |
| `lit-review` | Biblio + Verification + Synthesis | Annotated bibliography + synthesis | 1,500-4,000 |
| `fact-check` | Source Verification only | Verification report | 300-800 |
| `socratic` | Socratic Mentor + RQ + Devil's Advocate | Research Plan Summary (INSIGHT collection) | N/A (iterative) |
| `systematic-review` | RQ + Architect + Biblio + Verification + RoB + Meta-Analysis + Synthesis + Report + Editor + Ethics + DA | Full PRISMA 2020 report + forest plot data + GRADE table | 5,000-15,000 |

---

## Failure Paths

See `references/failure_paths.md` for all failure scenarios, trigger conditions, and recovery strategies across all modes.

Key failure path summary:

| Failure Scenario | Trigger Condition | Recovery Strategy |
|---------|---------|---------|
| RQ cannot converge | Phase 1 / Layer 1 exceeds multiple rounds while still vague | Provide 3 candidate RQs or suggest lit-review |
| Insufficient literature | bibliography_agent finds < 5 sources | Expand search strategy, alternative keywords |
| Methodology mismatch | RQ type misaligned with method capability | Return to Phase 1, suggest 3 alternative methods |
| Devil's Advocate CRITICAL | Fatal logical flaw discovered | STOP, explain the issue, require correction |
| Ethics BLOCKED | Serious ethical issue | STOP, list issues and remediation path |
| Socratic non-convergence | > 10 rounds without convergence | Suggest switching to full mode |
| User abandons mid-process | Explicitly states they don't want to continue | Save progress, provide re-entry path |
| Only Chinese-language literature | English search returns empty | Switch to Chinese academic databases |

---

## Literature Monitoring (Optional Post-Pipeline)

After any research mode is complete, users can optionally activate the `monitoring_agent` to set up post-research literature monitoring. This is not part of the main pipeline — it is an auxiliary capability triggered on demand.

See `agents/monitoring_agent.md` for the detailed agent definition.
See `references/literature_monitoring_strategies.md` for platform-specific setup guides.

**Trigger**: "monitor this topic", "set up alerts", "track new publications on this"

**Capabilities**:
- Weekly/monthly monitoring digest generation
- Retraction alerts for cited sources
- Contradictory findings detection
- Key author tracking
- Keyword evolution tracking

**Input**: Completed bibliography + search strategy from any research mode
**Output**: Monitoring configuration + digest template (markdown)

**Limitation**: The monitoring agent produces configurations and templates for the user to act on. It cannot run autonomous background monitoring.

---

## Handoff Protocol: deep-research → academic-paper

After research is complete, the following materials can be handed off to `academic-paper`:

1. **Research Question Brief** (from research_question_agent)
2. **Methodology Blueprint** (from research_architect_agent)
3. **Annotated Bibliography** (from bibliography_agent)
4. **Synthesis Report** (from synthesis_agent)
5. **[If socratic mode] INSIGHT Collection and Research Plan Summary**

**Trigger**: User says "now help me write a paper" or "write a paper based on this"

`academic-paper`'s `intake_agent` will automatically detect available materials and skip redundant steps:
- Has RQ Brief -> skip topic scoping
- Has Bibliography -> skip literature search
- Has Synthesis -> accelerate findings / discussion writing

See `examples/handoff_to_paper.md` for a detailed handoff example.

---

## Full Academic Pipeline

See `academic-pipeline/SKILL.md` for the complete workflow.

---

## Agent File References

| Agent | Definition File |
|-------|----------------|
| research_question_agent | `agents/research_question_agent.md` |
| research_architect_agent | `agents/research_architect_agent.md` |
| bibliography_agent | `agents/bibliography_agent.md` |
| source_verification_agent | `agents/source_verification_agent.md` |
| synthesis_agent | `agents/synthesis_agent.md` |
| report_compiler_agent | `agents/report_compiler_agent.md` |
| editor_in_chief_agent | `agents/editor_in_chief_agent.md` |
| devils_advocate_agent | `agents/devils_advocate_agent.md` |
| ethics_review_agent | `agents/ethics_review_agent.md` |
| socratic_mentor_agent | `agents/socratic_mentor_agent.md` |
| risk_of_bias_agent | `agents/risk_of_bias_agent.md` |
| meta_analysis_agent | `agents/meta_analysis_agent.md` |
| monitoring_agent | `agents/monitoring_agent.md` |

---

## Reference Files

| Reference | Purpose | Used By |
|-----------|---------|---------|
| `references/apa7_style_guide.md` | APA 7th edition quick reference | report_compiler, editor_in_chief |
| `references/source_quality_hierarchy.md` | Evidence pyramid + grading rubric | source_verification, bibliography |
| `references/methodology_patterns.md` | Research design templates | research_architect |
| `references/logical_fallacies.md` | 30+ fallacies catalog | devils_advocate |
| `references/ethics_checklist.md` | AI disclosure, attribution, dual-use | ethics_review |
| `references/interdisciplinary_bridges.md` | Cross-discipline connection patterns | synthesis, research_architect |
| `references/socratic_questioning_framework.md` | 6 types of Socratic questions + 30+ prompt patterns | socratic_mentor |
| `references/failure_paths.md` | 12 failure scenarios with triggers and recovery paths | all agents |
| `references/mode_selection_guide.md` | Mode selection flowchart and comparison table | orchestrator |
| `references/irb_decision_tree.md` | IRB decision tree + Taiwan process + HE quick reference | ethics_review, research_architect |
| `references/equator_reporting_guidelines.md` | EQUATOR reporting guideline mapping | research_architect, report_compiler |
| `references/preregistration_guide.md` | Preregistration decision tree + platforms + checklist | research_architect |
| `references/systematic_review_toolkit.md` | Cochrane v6.4, PRISMA 2020, RoB 2, ROBINS-I, I² guide, GRADE, protocol registration | risk_of_bias, meta_analysis, bibliography, report_compiler |
| `references/literature_monitoring_strategies.md` | Google Scholar alerts, PubMed alerts, RSS feeds, Retraction Watch, citation tracking, monitoring cadence | monitoring_agent |

---

## Templates

| Template | Purpose |
|----------|---------|
| `templates/research_brief_template.md` | Quick mode output format |
| `templates/literature_matrix_template.md` | Source x Theme analysis matrix |
| `templates/evidence_assessment_template.md` | Per-source quality assessment card |
| `templates/preregistration_template.md` | OSF standard 21-item preregistration template |
| `templates/prisma_protocol_template.md` | PRISMA-P 2015 systematic review protocol template |
| `templates/prisma_report_template.md` | PRISMA 2020 systematic review report template (27 items) |

---

## Examples

| Example | Demonstrates |
|---------|-------------|
| `examples/exploratory_research.md` | Full 6-phase pipeline walkthrough |
| `examples/systematic_review.md` | PRISMA-style literature review |
| `examples/policy_analysis.md` | Applied comparative policy research |
| `examples/socratic_guided_research.md` | Complete Socratic mode multi-turn dialogue (12 rounds) |
| `examples/handoff_to_paper.md` | deep-research full mode handoff to academic-paper |
| `examples/review_mode.md` | Review mode: 3-agent review pipeline for policy recommendation text |
| `examples/fact_check_mode.md` | Fact-check mode: source verification of HEI claims with per-claim verdicts |

---

## Output Language

Follows the user's language. Academic terminology kept in English. Socratic mode uses natural conversational style.

---

## Quality Standards

1. **Every claim must have a citation** — no unsupported assertions
2. **Evidence hierarchy** — meta-analyses > RCTs > cohort studies > case reports > expert opinion
3. **Contradiction disclosure** — if sources disagree, report both sides with evidence quality comparison
4. **Limitation transparency** — every report must have an explicit limitations section
5. **AI disclosure** — all reports include a statement that AI-assisted research tools were used
6. **Reproducibility** — search strategies, inclusion criteria, and analytical methods must be documented for replication
7. **Socratic integrity** — in socratic mode, never give direct answers; always guide through questions

## Cross-Agent Quality Alignment

Unified definitions to prevent inconsistency across agents:

| Concept | Definition | Applies To |
|---------|-----------|------------|
| **Peer-reviewed** | Published in a journal with formal peer review process (editorial review alone does not qualify). Conference proceedings count only if explicitly peer-reviewed | bibliography_agent, source_verification_agent |
| **Currency Rule** | Default: published within 5 years. Override by domain: CS/AI = 3 years, History/Philosophy = 20 years, Law = depends on jurisdiction changes. Seminal works exempt regardless of age | bibliography_agent, ethics_review_agent |
| **CRITICAL severity** | Issue that, if unresolved, would invalidate a core conclusion or constitute academic misconduct. Requires immediate resolution before pipeline can proceed | All agents |
| **Source Tier** | tier_1 = top-quartile peer-reviewed journal; tier_2 = other peer-reviewed; tier_3 = academic but not peer-reviewed; tier_4 = grey literature | bibliography_agent, source_verification_agent |
| **Minimum Source Count** | full = 15+, quick = 5-8, lit-review = 25+, systematic-review = all eligible (no limit), fact-check = 3+ per claim | bibliography_agent |
| **Verification Threshold** | 100% DOI check + 50% WebSearch spot-check | source_verification_agent, ethics_review_agent |

> **Cross-Skill Reference**: See `shared/handoff_schemas.md` for inter-stage data exchange formats.

---

## Integration with Other Skills

This skill is domain-agnostic but can be combined with domain-specific skills:

```
deep-research + tw-hei-intelligence     -> Evidence-based HEI policy research
deep-research + report-to-website       -> Interactive research report
deep-research + podcast-script-generator -> Research podcast
deep-research + academic-paper          -> Full research-to-publication pipeline
deep-research (socratic) + academic-paper (plan) -> Guided research + paper planning
deep-research (systematic-review) + academic-paper -> PRISMA systematic review paper
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 2.4 | 2026-03-27 | Report compiler now consumes optional Style Profile (from academic-paper intake) and runs Writing Quality Check checklist before finalizing reports. Style Profile applied as soft guide for Executive Summary and Synthesis sections; discipline conventions take priority. Writing Quality Check catches overused AI-typical terms, em dash overuse, throat-clearing openers, and monotonous sentence rhythm. See `academic-paper/references/writing_quality_check.md` and `shared/style_calibration_protocol.md` |
| 2.3 | 2026-03-08 | Added systematic-review mode (7th mode): PRISMA 2020 compliant pipeline with risk_of_bias_agent (RoB 2 + ROBINS-I), meta_analysis_agent (effect sizes, heterogeneity, GRADE, narrative synthesis), 2 new templates (PRISMA protocol + report), systematic_review_toolkit reference. Added monitoring_agent (post-pipeline literature monitoring with digests, retraction alerts, author tracking) + literature_monitoring_strategies reference. Enhanced socratic_mentor_agent with 4 convergence signals, 4-type question taxonomy, and auto-end triggers. Added Quick Mode Selection Guide to SKILL.md |
| 2.2 | 2025-03-05 | Added synthesis anti-patterns, Socratic quantified thresholds & auto-end conditions, reference existence verification (DOI + WebSearch), enhanced ethics reference integrity check (50% + Retraction Watch), mode transition matrix, cross-agent quality alignment definitions |
| 2.1 | 2026-03 | Added IRB decision tree, EQUATOR reporting guidelines, preregistration guide + template; enhanced ethics_review_agent with human subjects dimension; enhanced research_architect_agent with ethics/EQUATOR/preregistration integration; enhanced methodology_patterns with EQUATOR cross-references |
| 2.0 | 2026-02 | Added socratic mode (10th agent), failure paths, mode selection guide, handoff protocol, 2 new examples, 3 new references |
| 1.0 | 2026-02 | Initial release: 9 agents, 5 modes, 6-phase pipeline |
