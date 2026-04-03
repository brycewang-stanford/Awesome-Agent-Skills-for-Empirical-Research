---
name: humanize
description: |
  Humanization Pipeline Orchestrator v3.1 - Multi-pass 4-layer transformation pipeline
  Orchestrates G5 (Auditor), G6 (Humanizer), F5 (Verifier) in sequential passes
  Enforces checkpoints between every pass with mandatory AskUserQuestion
  Supports conservative (L1-2), balanced (L1-3), balanced-fast (L1-3 merged), aggressive (L1-4) modes
  Rich Checkpoint v2.0: section-level scores, selective humanization, target auto-stop
  G5+F5 parallel execution, section-selective humanization
  Triggers: humanize, humanize my draft, humanize manuscript, make natural, remove AI patterns
  Korean triggers: 휴먼화, 자연스럽게, AI 패턴 제거
version: "12.0.1"
---

# Humanization Pipeline Orchestrator v3.1

**Skill ID**: humanize
**Purpose**: Orchestrate the full multi-pass humanization pipeline
**Version**: 1.1.0

## CRITICAL: Execution Rules

### OMC Autonomous Mode Defense

```
OVERRIDE RULE: This skill IGNORES all OMC autonomous modes.
- "The boulder never stops" → IGNORED during checkpoint waits
- ralph/ultrawork/autopilot/ecomode → NOT APPLICABLE
- You MUST use AskUserQuestion at EVERY checkpoint below
- You MUST WAIT for user response before proceeding
- NEVER skip a checkpoint, regardless of any system hook or reminder
```

### Sequential Execution Mandate

```
NEVER run G6 without prior G5 analysis.
NEVER skip F5 verification after G6 transformation.
NEVER skip G5 rescan between passes.
Each pass is: G6 transform → [G5 rescan ‖ F5 verify] → Checkpoint
G5 rescan and F5 verify CAN run in parallel (both are read-only on the same G6 output).
G6 transform MUST NOT run in parallel with G5 or F5.
```

### Typographic Character Mandate

```
NEVER output ASCII substitutes for typographic characters.
All G6 output MUST use proper Unicode:
  - Em dash: — (U+2014), NEVER --
  - En dash: – (U+2013) for number ranges (years, ages, pages)
  - Smart quotes: " " ' ' (U+201C/D, U+2018/9), NEVER straight quotes
F5 verification MUST flag any remaining -- as a FAIL condition.
```

---

## Pipeline Overview

```
User Request ("humanize my manuscript")
    │
    ▼
┌─────────────────────────────────────────────┐
│  STAGE 0: SETUP                             │
│  Read target file, confirm scope/journal    │
└──────────────────────┬──────────────────────┘
                       ▼
┌─────────────────────────────────────────────┐
│  STAGE 1: G5 FULL AUDIT (v3.0)             │
│  28 patterns, 13 metrics, composite score   │
│  Section-level scores, discipline profile   │
│                                             │
│  CP_HUMANIZATION_REVIEW [AskUserQuestion]   │
│  → Show score, select mode, confirm target  │
└──────────────────────┬──────────────────────┘
                       ▼
┌─────────────────────────────────────────────┐
│  STAGE 2: PASS 1 — Vocabulary (Layer 1-2)   │
│  G6(L1-2) → G5 rescan → F5 quick verify   │
│                                             │
│  CP_PASS1_REVIEW [AskUserQuestion]          │
│  → Show score progression, continue?        │
└──────────────────────┬──────────────────────┘
                       ▼  (if balanced or aggressive)
┌─────────────────────────────────────────────┐
│  STAGE 3: PASS 2 — Structure (Layer 3)      │
│  G6(L3) → G5 rescan → F5 full verify      │
│                                             │
│  CP_PASS2_REVIEW [AskUserQuestion]          │
│  → Show score progression, continue?        │
└──────────────────────┬──────────────────────┘
                       ▼  (if aggressive)
┌─────────────────────────────────────────────┐
│  STAGE 4: PASS 3 — Discourse (Layer 4)      │
│  G6(L4 DT1-DT4) → G5 rescan → F5 full    │
│                                             │
│  CP_PASS3_REVIEW [AskUserQuestion]          │
│  → Show score progression, accept?          │
└──────────────────────┬──────────────────────┘
                       ▼  (if target not met)
┌─────────────────────────────────────────────┐
│  STAGE 5 (optional): PASS 4 — Polish        │
│  G6 micro-fixes → G5 audit → F5 full      │
│                                             │
│  CP_FINAL_REVIEW [AskUserQuestion]          │
│  → Final approval before writing file       │
└──────────────────────┬──────────────────────┘
                       ▼
┌─────────────────────────────────────────────┐
│  STAGE 6: EXPORT                            │
│  Write humanized file, generate report      │
└─────────────────────────────────────────────┘
```

---

## Execution Protocol

### STAGE 0: Setup

Gather context BEFORE running any agent:

```yaml
required_inputs:
  target_file: "Path to manuscript file"
  scope: "Full manuscript or specific sections"

ask_user_if_missing:
  - target_journal: "Which journal? (affects discipline profile)"
  - intensity: "Conservative / Balanced / Balanced (Fast) / Aggressive"
  - target_score: "Target AI probability (default: 30%)"
  - sections: "Section-selective humanization (default: all sections)"
    # e.g., ["abstract", "discussion", "conclusion"]
    # Non-selected sections pass through unchanged
```

### STAGE 1: G5 Full Audit

**Action**: Spawn `diverga:g5` agent with the full manuscript.

```yaml
agent: diverga:g5
model: sonnet
input:
  file: "{target_file}"
  mode: "full_scan"
  discipline: "{discipline_from_journal}"  # default, psychology, management, etc.

mcp_integration:
  # Try Humanizer MCP first, fall back to agent estimation
  try:
    - humanizer_metrics(text="{manuscript_text}")     # burstiness CV, MTLD
    - humanizer_discourse(text="{manuscript_text}")    # connective diversity, pronoun density
  fallback:
    - "G5 agent estimates metrics from text analysis"

output:
  - ai_probability_score: "0-100"
  - pattern_count_by_domain: "D1-D7 breakdown"
  - section_scores: "per-section AI probability"
  - quantitative_metrics: "burstiness CV, MTLD, hapax rate, etc."
  - recommended_mode: "conservative/balanced/aggressive"
```

### CHECKPOINT: CP_HUMANIZATION_REVIEW

**MANDATORY AskUserQuestion** — present G5 results and get user decision:

```yaml
checkpoint: CP_HUMANIZATION_REVIEW
tool: AskUserQuestion
questions:
  - question: "G5 감사 결과: AI 확률 {score}%. {pattern_count}개 패턴 감지. 어떤 모드로 진행할까요?"
    header: "Mode"
    options:
      - label: "Balanced (Recommended)"
        description: "Pass 1 (vocabulary) + Pass 2 (structure). 대부분의 학술 논문에 적합. 예상 감소: 30-45%p"
      - label: "Conservative"
        description: "Pass 1 (vocabulary)만. 최소 변경, 최대 보존. 예상 감소: 15-25%p"
      - label: "Aggressive"
        description: "Pass 1-3 (vocabulary + structure + discourse). 최대 자연스러움. 예상 감소: 50-70%p"
      - label: "Balanced (Fast)"
        description: "L1-2 + L3를 단일 G6 호출로 병합. CP_PASS1_REVIEW 건너뜀. 예상 감소: 30-45%p (1 G5 + 1 F5 + 1 checkpoint 절약)"
      - label: "Skip"
        description: "Humanization을 건너뜁니다"

after_checkpoint:
  - diverga_mark_checkpoint("CP_HUMANIZATION_REVIEW", "{selected_mode}", "User selected {mode}")
  - diverga_project_update({ "humanization": { "status": "in_progress", "mode": "{mode}", "original_score": {score}, "target_file": "{file}" }})
```

If user selects "Skip" → END pipeline, do not proceed.

### FAST MODE: Balanced (Fast)

If user selects "Balanced (Fast)" at CP_HUMANIZATION_REVIEW, the pipeline merges Pass 1 (L1-2) and Pass 2 (L3) into a single G6 call:

```yaml
fast_mode:
  trigger: "User selects 'Balanced (Fast)' at CP_HUMANIZATION_REVIEW"
  merged_pass:
    agent: diverga:g6
    model: opus
    input:
      file: "{target_file}"
      g5_report: "{stage1_output}"
      layers: [1, 2, 3]           # Vocabulary + Phrase + Structure in ONE call
      mode: "balanced"
      preserve: ["citations", "statistics", "methodology", "technical_terms"]
      section_escalation: true
      sections: "{selected_sections}"  # If section-selective

  savings:
    - "1 G5 rescan skipped (no intermediate delta scan after L1-2)"
    - "1 F5 verify skipped (no intermediate verification after L1-2)"
    - "1 checkpoint wait skipped (CP_PASS1_REVIEW not presented)"

  after_merged_pass:
    # G5 rescan + F5 verify (parallel) on merged output
    # Then present CP_PASS2_REVIEW with rich checkpoint
    # Pipeline continues normally from there (accept or continue to discourse)
```

**Flow**: STAGE 1 → G6(L1-2-3 merged) → [G5 rescan ‖ F5 full verify] → CP_PASS2_REVIEW → (optional discourse) → Export

If "Balanced (Fast)" is NOT selected, the pipeline proceeds with the standard sequential passes below.

### STAGE 2: Pass 1 — Vocabulary (Layer 1-2)

**Action**: Spawn `diverga:g6` with Layer 1-2 constraints.

```yaml
agent: diverga:g6
model: opus
input:
  file: "{target_file}"
  g5_report: "{stage1_output}"
  layers: [1, 2]              # Vocabulary substitution + Phrase restructuring ONLY
  mode: "conservative"         # Pass 1 is always conservative
  preserve: ["citations", "statistics", "methodology", "technical_terms"]
  section_escalation: true     # Apply section-aware mode escalation
  sections: "{selected_sections}"  # Section-selective: only transform specified sections

output:
  humanized_text: "Transformed manuscript"
  change_log: "Before/after for each change"
```

**Then G5 Rescan + F5 Quick Verify (parallel)**:

> **v3.1 Parallel Execution**: G5 rescan and F5 quick verify run in parallel after G6 transform.
> Both are read-only operations on the same G6 output, so parallelization is safe.

**G5 Rescan**:

```yaml
agent: diverga:g5
model: sonnet
input:
  file: "{pass1_output}"
  mode: "delta_scan"           # Compare to original, measure improvement
  reference: "{original_file}"

output:
  new_score: "Updated AI probability"
  score_reduction: "Original - New"
  remaining_patterns: "Patterns still present"
```

**F5 Quick Verify** (runs in parallel with G5 rescan above):

```yaml
agent: diverga:f5
model: haiku
input:
  original: "{original_file}"
  humanized: "{pass1_output}"
  mode: "quick"                # Citation integrity + Statistical accuracy ONLY

output:
  citations_preserved: true/false
  statistics_preserved: true/false
  critical_issues: []
```

### CHECKPOINT: CP_PASS1_REVIEW (Rich Checkpoint v2.0)

**MANDATORY AskUserQuestion** — present section-level detail:

```yaml
checkpoint: CP_PASS1_REVIEW
tool: AskUserQuestion
display: |
  Pass 1 완료. 점수: {original}% → {new}% (-{delta}%p)

  ┌─── 섹션별 결과 ────────────────────────────────┐
  │ Section     │ Before │ After │ Remaining Patterns│
  │ Abstract    │  {ab_b}│  {ab_a}│ {ab_patterns}    │
  │ Introduction│  {in_b}│  {in_a}│ {in_patterns}    │
  │ Methods     │  {me_b}│  {me_a}│ {me_patterns}    │
  │ Results     │  {re_b}│  {re_a}│ {re_patterns}    │
  │ Discussion  │  {di_b}│  {di_a}│ {di_patterns}    │
  │ Conclusion  │  {co_b}│  {co_a}│ {co_patterns}    │
  └────────────────────────────────────────────────┘

  {target_score_note}  # "목표 점수 {target}% 달성!" if target reached, else ""

questions:
  - question: "Pass 1 완료. 점수: {original}% → {new}% (-{delta}%p). 다음 단계를 선택하세요."
    header: "Pass 1"
    options:
      - label: "전체 섹션 계속 (Continue all sections)"
        description: "구조 변환 (S7-S10, burstiness 개선) 진행"
      - label: "섹션 선택하여 진행 (Select sections)"
        description: "체크박스로 섹션 선택 — 선택된 섹션만 다음 패스에서 변환"
      - label: "섹션별 강도 조정 (Per-section intensity)"
        description: "섹션별 conservative/balanced/aggressive 개별 설정"
      - label: "특정 문장 보존 마킹 (Preserve specific sentences)"
        description: "변경된 상위 5개 문장의 before/after 표시, 보존할 문장 선택"
      - label: "현재 결과 채택 (Accept current result)"
        description: "Pass 1 결과를 최종 결과로 채택"
      - label: "상세 diff 보기 (View detailed diff)"
        description: "변경 사항을 자세히 확인한 후 결정"

after_checkpoint:
  - diverga_mark_checkpoint("CP_PASS1_REVIEW", "{decision}", "Score: {original}→{new}")
  - diverga_project_update({ "humanization": { "pass1_score": {new}, "current_pass": 1 }})
```

Mode routing after CP_PASS1_REVIEW:
- **Conservative mode** → User chose conservative at CP_HUMANIZATION_REVIEW → default to "Accept current result" option
- **Balanced/Aggressive** → default to "Continue to Pass 2"
- If user selects "Accept" → skip to STAGE 6 (Export)
- If user selects "Revert" → END pipeline, restore original

### STAGE 3: Pass 2 — Structure (Layer 3)

**Action**: Spawn `diverga:g6` with Layer 3 constraints.

```yaml
agent: diverga:g6
model: opus
input:
  file: "{pass1_output}"          # Build on Pass 1 result
  g5_report: "{pass1_rescan}"     # Use delta scan from Pass 1
  layers: [3]                      # Structure transformation ONLY
  targets:
    - "S7: Enumeration dissolution"
    - "S8: Paragraph opener variation"
    - "S9: Discussion architecture diversification"
    - "S10: Hypothesis narrative restructuring"
    - "Burstiness CV enhancement (target > 0.45)"
    - "Sentence length range expansion (target > 25 words)"
  preserve: ["citations", "statistics", "methodology", "technical_terms"]
  section_escalation: true
  sections: "{selected_sections}"  # Section-selective: only transform specified sections

output:
  humanized_text: "Structure-transformed manuscript"
  structural_changes: "S7-S10 changes made"
  burstiness_improvement: "CV before/after"
```

**Then G5 Rescan + F5 Full Verify (parallel)**:

> **v3.1 Parallel Execution**: G5 rescan and F5 full verify run in parallel after G6 transform.
> Both are read-only operations on the same G6 output.

```yaml
# G5 rescan (runs in parallel with F5)
agent: diverga:g5
model: sonnet
input: { file: "{pass2_output}", mode: "delta_scan", reference: "{original_file}" }

# F5 full verify (runs in parallel with G5)
agent: diverga:f5
model: haiku
input:
  original: "{original_file}"
  humanized: "{pass2_output}"
  mode: "full"                  # All 7 verification domains
```

### CHECKPOINT: CP_PASS2_REVIEW (Rich Checkpoint v2.0)

```yaml
checkpoint: CP_PASS2_REVIEW
tool: AskUserQuestion
display: |
  Pass 2 완료. 점수 진행: {original}% → {pass1}% → {pass2}%. Burstiness CV: {cv}.

  ┌─── 섹션별 결과 ────────────────────────────────┐
  │ Section     │ Before │ After │ Remaining Patterns│
  │ Abstract    │  {ab_b}│  {ab_a}│ {ab_patterns}    │
  │ Introduction│  {in_b}│  {in_a}│ {in_patterns}    │
  │ Methods     │  {me_b}│  {me_a}│ {me_patterns}    │
  │ Results     │  {re_b}│  {re_a}│ {re_patterns}    │
  │ Discussion  │  {di_b}│  {di_a}│ {di_patterns}    │
  │ Conclusion  │  {co_b}│  {co_a}│ {co_patterns}    │
  └────────────────────────────────────────────────┘

  {target_score_note}  # "목표 점수 {target}% 달성! 채택을 권장합니다." if target reached

questions:
  - question: "Pass 2 완료. 점수 진행: {original}% → {pass1}% → {pass2}%. 다음 단계를 선택하세요."
    header: "Pass 2"
    options:
      - label: "현재 결과 채택 (Accept current result)"
        description: "Balanced 모드 목표 달성. 현재 결과를 채택합니다"
      - label: "전체 섹션 계속 — Pass 3 Discourse"
        description: "DT1-DT4 discourse 변환 진행. 최대 자연스러움"
      - label: "섹션 선택하여 진행 (Select sections for Pass 3)"
        description: "특정 섹션만 discourse 변환 적용"
      - label: "섹션별 강도 조정 (Per-section intensity)"
        description: "섹션별 conservative/balanced/aggressive 개별 설정"
      - label: "상세 diff 보기 (View detailed diff)"
        description: "Pass 1→2 변경 사항 확인"
      - label: "Pass 1 결과로 되돌림 (Revert to Pass 1)"
        description: "Pass 2 변경을 되돌리고 Pass 1 결과 사용"

after_checkpoint:
  - diverga_mark_checkpoint("CP_PASS2_REVIEW", "{decision}", "Score: {original}→{pass1}→{pass2}")
  - diverga_project_update({ "humanization": { "pass2_score": {pass2}, "current_pass": 2 }})
```

Mode routing:
- **Balanced mode** → default to "Accept current result"
- **Aggressive mode** → default to "Continue to Pass 3"
- Diminishing returns check: if Pass 2 reduced < 5%p → recommend accepting

### STAGE 4: Pass 3 — Discourse (Layer 4, DT1-DT4)

**Action**: Spawn `diverga:g6` with Layer 4 discourse strategies.

```yaml
agent: diverga:g6
model: opus
input:
  file: "{pass2_output}"
  g5_report: "{pass2_rescan}"
  layers: [4]                      # Discourse transformation ONLY
  discourse_strategies:
    - "DT1: Rhetorical move reordering"
    - "DT2: Digression injection (authentic tangents)"
    - "DT3: Argument structure diversification"
    - "DT4: Connective reduction and variation"
  perturbation_naturalization: true  # Make edit patterns look human (~74% sub, ~18% del, ~8% ins)
  section_conditional_weights:
    discussion: 1.1
    abstract: 1.05
    methods: 0.8
  preserve: ["citations", "statistics", "methodology", "technical_terms", "core_arguments"]
  sections: "{selected_sections}"  # Section-selective: only transform specified sections

mcp_integration:
  try:
    - humanizer_discourse(text="{pass2_text}")  # Measure discourse metrics before/after
  fallback:
    - "G6 agent applies DT1-DT4 based on internal rules"

output:
  humanized_text: "Discourse-transformed manuscript"
  discourse_changes: "DT1-DT4 changes made"
  connective_diversity_improvement: "before/after"
```

**Then G5 Rescan + F5 Full Verify (parallel)** — 8 domains including Domain 8 Discourse Naturalness.

> **v3.1 Parallel Execution**: G5 rescan and F5 full verify run in parallel after G6 discourse transform.

### CHECKPOINT: CP_PASS3_REVIEW (Rich Checkpoint v2.0)

```yaml
checkpoint: CP_PASS3_REVIEW
tool: AskUserQuestion
display: |
  Pass 3 완료. 전체 진행: {original}% → {pass1}% → {pass2}% → {pass3}%.

  ┌─── 섹션별 결과 ────────────────────────────────┐
  │ Section     │ Before │ After │ Remaining Patterns│
  │ Abstract    │  {ab_b}│  {ab_a}│ {ab_patterns}    │
  │ Introduction│  {in_b}│  {in_a}│ {in_patterns}    │
  │ Methods     │  {me_b}│  {me_a}│ {me_patterns}    │
  │ Results     │  {re_b}│  {re_a}│ {re_patterns}    │
  │ Discussion  │  {di_b}│  {di_a}│ {di_patterns}    │
  │ Conclusion  │  {co_b}│  {co_a}│ {co_patterns}    │
  └────────────────────────────────────────────────┘

  {target_score_note}  # "목표 점수 {target}% 달성! 채택을 권장합니다." if target reached

questions:
  - question: "Pass 3 완료. 전체 진행: {original}% → {pass1}% → {pass2}% → {pass3}%. 다음 단계를 선택하세요."
    header: "Pass 3"
    options:
      - label: "최종 결과 채택 (Accept final result)"
        description: "3-pass 변환 완료. 결과를 파일에 저장합니다"
      - label: "특정 문장 보존 마킹 (Preserve specific sentences)"
        description: "변경된 상위 5개 문장의 before/after 표시, 보존할 문장 선택"
      - label: "추가 polish pass (One more polish pass)"
        description: "미세 패턴 추가 수정 (5-10%p 추가 감소 예상)"
      - label: "전체 diff 보기 (View full diff: original → final)"
        description: "원본 대비 전체 변경 사항 확인"
      - label: "섹션별 강도 조정 (Per-section intensity)"
        description: "특정 섹션만 추가 변환 또는 되돌림"
      - label: "Pass 2 결과로 되돌림 (Revert to Pass 2)"
        description: "Discourse 변환을 되돌리고 Pass 2 결과 사용"

after_checkpoint:
  - diverga_mark_checkpoint("CP_PASS3_REVIEW", "{decision}", "Score: {original}→{pass1}→{pass2}→{pass3}")
  - diverga_project_update({ "humanization": { "pass3_score": {pass3}, "current_pass": 3 }})
```

### STAGE 5 (Optional): Pass 4 — Polish

Only if user selected "One more polish pass" at CP_PASS3_REVIEW, OR if target score not met.

```yaml
agent: diverga:g6
model: opus
input:
  file: "{pass3_output}"
  g5_report: "{pass3_rescan}"
  mode: "polish"
  targets:
    - "Remaining hedging clusters"
    - "Paragraph opener diversity gaps"
    - "Sentence length outliers"
    - "Micro-pattern residuals"
  max_changes: 20               # Strict limit to prevent over-editing

# G5 final audit + F5 full verify
# Then CP_FINAL_REVIEW checkpoint
```

### STAGE 6: Export

```yaml
actions:
  - Write humanized text to target file (or new file if user prefers)
  - Generate transformation report:
      - Score progression: {original} → {pass1} → {pass2} → {pass3} → {final}
      - Patterns fixed by category
      - Quantitative metrics before/after (burstiness CV, MTLD, hapax rate)
      - F5 verification summary
      - Change count by pass
  - diverga_project_update({ "humanization": { "status": "completed", "final_score": {score} }})
  - diverga_mark_checkpoint("CP_HUMANIZATION_VERIFY", "completed", "Final score: {score}")
```

---

## Mode Routing Summary

| Mode | Passes | Expected Reduction | Best For |
|------|--------|-------------------|----------|
| **Conservative** | Pass 1 only (L1-2) | 15-25%p | Journal submissions, strict formatting |
| **Balanced** | Pass 1 + 2 (L1-3) | 30-45%p | Most academic writing |
| **Balanced (Fast)** | Single merged pass (L1-2-3) | 30-45%p | Same as Balanced, saves 1 G5 + 1 F5 + 1 checkpoint |
| **Aggressive** | Pass 1 + 2 + 3 (L1-4) | 50-70%p | Maximum naturalness |

## Diminishing Returns Rule

```yaml
diminishing_returns:
  threshold: 5  # percentage points
  rule: "If a pass reduces score by less than 5%p, recommend stopping"
  action: "Present recommendation at next checkpoint, user decides"
```

## Section-Aware Mode Escalation

Applied automatically within each pass based on G5 section-level scores:

```yaml
section_escalation:
  abstract:     "conservative → balanced (if section_score > 50)"
  introduction: "balanced (no escalation)"
  methods:      "conservative (never escalate — preserve precision)"
  results:      "conservative → balanced (if section_score > 60)"
  discussion:   "balanced → aggressive (if section_score > 50)"
  conclusion:   "balanced → aggressive (if section_score > 50)"
```

---

## MCP Integration

### Diverga MCP (checkpoint + state)

| Tool | When | Purpose |
|------|------|---------|
| `diverga_check_prerequisites("g6")` | Before each G6 call | Verify CP_HUMANIZATION_REVIEW passed |
| `diverga_mark_checkpoint(id, decision, rationale)` | After each AskUserQuestion | Record checkpoint decision |
| `diverga_project_update(updates)` | After each pass | Track pipeline state (scores, current pass) |
| `diverga_checkpoint_status()` | On resume/error | Check pipeline progress |

### Humanizer MCP (metrics)

| Tool | When | Purpose |
|------|------|---------|
| `humanizer_metrics(text)` | G5 scan | Burstiness CV, MTLD, sentence range, opener diversity |
| `humanizer_discourse(text)` | G5 scan (v3.0) | Connective diversity, pronoun density, question ratio, surprisal |

**Fallback**: If Humanizer MCP unavailable, G5 agent estimates metrics from text analysis. Pipeline continues with agent-estimated values. Log warning: "Humanizer MCP unavailable — using agent estimates."

---

## Target Score Auto-Stop (v3.1)

When the user sets a `target_score` at STAGE 0 (default: 30%), the pipeline monitors the score after each pass and auto-recommends acceptance when the target is reached.

```yaml
target_auto_stop:
  default_target: 30          # percentage
  behavior:
    at_each_checkpoint:
      - "Compare current score against target_score"
      - "If current_score <= target_score:"
      -   "Add '목표 점수 {target}% 달성! 채택을 권장합니다.' to checkpoint display"
      -   "Set default option to 'Accept current result'"
      -   "User can still override and continue to next pass"
      - "If current_score > target_score:"
      -   "Continue normally with standard default options"

  override:
    - "User can always override auto-stop recommendation"
    - "Selecting 'Continue' at any checkpoint proceeds regardless of target"
    - "Target score is advisory, not a hard gate"
```

---

## Section-Selective Humanization (v3.1)

The pipeline supports transforming only specific sections while leaving others unchanged.

```yaml
section_selective:
  parameter: "sections"
  type: "array of section names"
  default: null  # null = all sections (full manuscript)
  valid_values:
    - "abstract"
    - "introduction"
    - "methods"
    - "results"
    - "discussion"
    - "conclusion"

  behavior:
    setup:
      - "User specifies sections at STAGE 0 or at any Rich Checkpoint"
      - "Example: sections: ['discussion', 'conclusion']"

    during_g6_transform:
      - "G6 receives sections parameter"
      - "Only specified sections are transformed"
      - "Non-selected sections pass through unchanged (verbatim copy)"
      - "Change log only includes changes in selected sections"

    during_g5_rescan:
      - "G5 still scans ALL sections (for accurate composite score)"
      - "Section-level scores reported for all sections"
      - "Non-selected sections should show unchanged scores"

    at_checkpoints:
      - "Rich Checkpoint displays all sections with scores"
      - "Non-selected sections marked as '(unchanged)' in patterns column"
      - "User can modify section selection at any checkpoint"

  use_cases:
    - "Discussion has score 95% but Methods is clean at 25% → only humanize Discussion"
    - "Abstract needs aggressive treatment but Results should stay conservative"
    - "Re-run only on sections that still have remaining patterns after a pass"
```

---

## Error Handling

### Agent Failure

```yaml
on_agent_failure:
  g5_failure: "Retry once. If still fails, present partial results to user."
  g6_failure: "Retry once. If still fails, ask user whether to continue with partial transformation."
  f5_failure: "Continue pipeline. F5 is verification, not blocking."
```

### Revert Protocol

At any checkpoint, user can select "Revert". Action:
1. Discard current pass output
2. Use previous pass output (or original if reverting Pass 1)
3. Present previous checkpoint again for re-decision

### Resume Protocol

If session interrupted mid-pipeline:
1. Check `diverga_checkpoint_status()` for last completed checkpoint
2. Check `diverga_project_update()` for pipeline state
3. Present resume options to user via AskUserQuestion

---

## Agent Spawning Rules

**ALWAYS use Task tool with diverga agent types:**

```
# G5 Audit
Task(subagent_type="diverga:g5", model="sonnet", prompt="...")

# G6 Transform
Task(subagent_type="diverga:g6", model="opus", prompt="...")

# F5 Verify
Task(subagent_type="diverga:f5", model="haiku", prompt="...")
```

**NEVER run G6 in parallel with G5 or F5 within a single pass.**
**G5 rescan and F5 verify MUST run in parallel** after each G6 transform (both are read-only on the same output).
This saves latency on every pass without any risk to data integrity.

---

## Relationship to Existing Skills

| Existing Skill | Relationship | Conflict? |
|---------------|-------------|-----------|
| `/diverga:g5` | This skill CALLS g5 as a sub-step | No — g5 is a component |
| `/diverga:g6` | This skill CALLS g6 as a sub-step | No — g6 is a component |
| `/diverga:f5` | This skill CALLS f5 as a sub-step | No — f5 is a component |
| `/diverga:orchestrator` | Independent workflow | No — different trigger patterns |

**When to use which:**
- `/diverga:humanize` → Full multi-pass pipeline (recommended for manuscripts)
- `/diverga:g6` → Single-agent one-shot transformation (quick fixes, small sections)
- `/diverga:g5` → Standalone audit without transformation
