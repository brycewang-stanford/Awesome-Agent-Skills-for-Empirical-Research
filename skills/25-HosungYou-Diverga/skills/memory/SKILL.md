---
name: diverga-memory
description: |
  Diverga Memory System v7.0 - Context-persistent research support
  with checkpoint auto-trigger and cross-session continuity.
  Triggers: memory, remember, context, recall, checkpoint, decision, persist,
  기억, 맥락, 세션, 체크포인트
version: "12.0.1"
---

# Diverga Memory System v7.0

## Overview

Human-centered research context persistence with:
- 3-Layer Context System
- Checkpoint Auto-Trigger
- Cross-Session Continuity
- Decision Audit Trail
- Research Documentation Automation

## Quick Reference

### Context Loading Keywords

**English**:
"my research", "research status", "where was I", "continue research", "what stage"

**Korean**:
"내 연구", "연구 진행", "연구 상태", "어디까지", "지금 단계"

### Commands

| Command | Description |
|---------|-------------|
| `/diverga:memory status` | Show project status |
| `/diverga:memory context` | Display full context |
| `/diverga:memory init` | Initialize project |
| `/diverga:memory decision list` | List decisions |
| `/diverga:memory archive [STAGE]` | Archive stage |
| `/diverga:memory migrate` | Run migration |

## Priority Context (v8.2 — Compression Resilience)

### MCP Tools for Priority Context

| Command | MCP Tool | Description |
|---------|----------|-------------|
| Read priority | `diverga_priority_read()` | Read 500-char context summary |
| Write priority | `diverga_priority_write(context)` | Update context summary |
| Full status | `diverga_project_status()` | Project state + checkpoints + decisions |
| Check prereqs | `diverga_check_prerequisites(agent_id)` | Verify agent can proceed |
| Record decision | `diverga_mark_checkpoint(cp_id, decision, rationale)` | Record and auto-update priority |

### Auto-Update Behavior

Priority context is automatically updated when:
- A checkpoint is marked via `diverga_mark_checkpoint()`
- Format: `Project: {name} | Paradigm: {paradigm} | RQ: {question} | ✅/❌ checkpoints | Last: {decision}`
- Maximum 500 characters, stored at `.research/priority-context.md`

### Compression Recovery

When context window is compressed:
1. Call `diverga_priority_read()` to recover essential project context
2. Call `diverga_checkpoint_status()` to see checkpoint state
3. Call `diverga_project_status()` for full project details

## 3-Layer Context System

### Layer 1: Keyword-Triggered (자연어 감지)

When researcher asks "내 연구 진행 상황은?" or "What's my research status?", automatically load and display context.

**Auto-Detection Keywords**:
- "my research", "연구", "research", "progress", "진행"
- "where was I", "continue", "다시", "어디까지"
- "what stage", "현재 단계", "stage", "지금"

**Response Pattern**:
1. Detect keyword match
2. Load `.research/project-state.yaml`
3. Display current stage and progress
4. Show pending checkpoints
5. List available next actions

### Layer 2: Task Interceptor (에이전트 호출)

When `Task(subagent_type="diverga:*")` is called, automatically inject full research context and checkpoint instructions.

**Injection Process**:
1. Detect `diverga:` prefix in subagent_type
2. Read `.research/project-state.yaml`
3. Read `.research/checkpoints.yaml`
4. Inject context into agent prompt
5. Add checkpoint validation wrapper
6. Execute with full research awareness

**Context Injected**:
```yaml
# Automatically included in agent prompt
research_context:
  project_name: "[from project-state.yaml]"
  current_stage: "[from checkpoints.yaml]"
  research_question: "[from project-state.yaml]"
  methodology: "[from project-state.yaml]"
  decisions: "[from decision-log.yaml, last 10]"
  pending_checkpoints: "[from checkpoints.yaml]"
```

### Layer 3: CLI (명시적 요청)

Run `/diverga:memory context --verbose` for full detailed state.

**Available Flags**:
- `--verbose` - Show full decision audit trail
- `--archive` - Include archived stages
- `--decisions` - Show decision log only
- `--checkpoints` - Show checkpoint status only
- `--format json|yaml|text` - Output format

## Checkpoint System

### Checkpoint Levels

| Level | Icon | Behavior | Example |
|-------|------|----------|---------|
| REQUIRED | 🔴 | Must complete before proceeding | CP_RESEARCH_DIRECTION |
| RECOMMENDED | 🟠 | Strongly suggested | CP_PARADIGM_SELECTION |
| OPTIONAL | 🟡 | Can skip with defaults | CP_METHODOLOGY_APPROVAL |

### Standard Checkpoints (Research Workflow)

#### Foundation Stage (0-2 hours)
- **CP_RESEARCH_DIRECTION** 🔴 - Research question finalized and validated
- **CP_PARADIGM_SELECTION** 🟠 - Quantitative/qualitative/mixed selected with rationale
- **CP_SCOPE_DEFINITION** 🔴 - Scope constraints documented (years, populations, outcomes)

#### Design Stage (2-4 hours)
- **CP_THEORY_SELECTION** 🟠 - Theoretical framework chosen and justified
- **CP_VARIABLE_DEFINITION** 🔴 - All variables operationalized (IV, DV, mediators, moderators)
- **CP_METHODOLOGY_APPROVAL** 🟠 - Research design validated (RCT, meta-analysis, qualitative, etc.)

#### Planning Stage (4-6 hours)
- **CP_DATABASE_SELECTION** 🔴 - Data sources identified with inclusion/exclusion criteria
- **CP_SEARCH_STRATEGY** 🔴 - Search terms, filters, and retrieval approach documented
- **CP_SAMPLE_PLANNING** 🟠 - Sample size, power analysis (if quantitative), or saturation plan (if qualitative)

#### Execution Stage (6+ hours)
- **CP_SCREENING_CRITERIA** 🔴 - Inclusion/exclusion criteria operationalized for systematic review
- **CP_RAG_READINESS** 🟠 - Vector database and retrieval system configured
- **CP_DATA_EXTRACTION** 🟠 - Data extraction protocol finalized and tested
- **CP_ANALYSIS_PLAN** 🔴 - Analysis approach documented with reproducible steps

#### Validation Stage (Final)
- **CP_QUALITY_GATES** 🔴 - PRISMA/CONSORT compliance verified
- **CP_PEER_REVIEW** 🟠 - Methodology reviewed by co-investigators
- **CP_PUBLICATION_READY** 🔴 - Manuscript format and ethics approved

### Checkpoint Enforcement Rules

**REQUIRED (🔴) Checkpoints**:
- Cannot skip
- Must have evidence of completion
- Blocks advancement to next stage
- Tracked in `decision-log.yaml` with timestamp

**RECOMMENDED (🟠) Checkpoints**:
- Can skip with documented rationale
- Requires explicit user acknowledgment
- Added to issues.log if skipped
- Tracked as amendment to decision-log

**OPTIONAL (🟡) Checkpoints**:
- Can skip without confirmation
- Tracked for audit trail only
- May be auto-populated with defaults

### Checkpoint Validation

When checkpoint is reached:

```yaml
# In checkpoints.yaml
- checkpoint_id: CP_RESEARCH_DIRECTION
  level: REQUIRED
  status: pending
  triggered_at: 2025-02-03T10:30:00Z
  stage: foundation

# User completes checkpoint
- checkpoint_id: CP_RESEARCH_DIRECTION
  level: REQUIRED
  status: completed
  completed_at: 2025-02-03T10:45:00Z
  completed_by: researcher
  decision_id: DEV_001
  evidence: "Research question: How does AI improve learning outcomes?"

# Moving to next stage
- checkpoint_id: CP_PARADIGM_SELECTION
  level: RECOMMENDED
  status: pending
  triggered_at: 2025-02-03T10:46:00Z
```

## Decision Audit Trail

All decisions are:
- **Immutable**: Never modified after creation
- **Versioned**: Amendments create new entries with `amends` reference
- **Contextual**: Capture research question and prior decisions
- **Timestamped**: ISO 8601 format with timezone

### Decision Structure

```yaml
decisions:
  - decision_id: DEV_001
    checkpoint_id: CP_RESEARCH_DIRECTION
    timestamp: 2025-02-03T10:30:00Z
    researcher_name: "Dr. Park"

    # What was decided
    decision_type: "research_question"
    selected: "How does AI-assisted instruction affect student engagement in STEM?"
    alternatives_considered:
      - "How does AI personalization improve learning outcomes?"
      - "What are barriers to AI adoption in classrooms?"

    # Why this decision
    rationale: |
      Engagement is measurable and significant to existing literature.
      Aligns with team expertise in behavioral psychology.
      Scope is feasible within 6-month timeline.

    # Context at time of decision
    prior_decisions: []
    research_constraints:
      - timeline: "6 months"
      - budget: "$50,000"
      - team_size: 3

    # Amendment tracking
    amends: null  # Only non-null for amendments
    version: 1

  - decision_id: DEV_002
    checkpoint_id: CP_PARADIGM_SELECTION
    timestamp: 2025-02-03T10:45:00Z
    researcher_name: "Dr. Park"
    decision_type: "paradigm"
    selected: "Quantitative: Meta-analysis"
    rationale: "Sufficient RCTs exist. Need synthesis of effect sizes."
    prior_decisions: ["DEV_001"]
    version: 1

  # Amendment example
  - decision_id: DEV_002_A1
    checkpoint_id: CP_PARADIGM_SELECTION
    timestamp: 2025-02-03T14:30:00Z
    researcher_name: "Dr. Park"
    decision_type: "paradigm_amendment"
    selected: "Mixed-methods: Meta-analysis + qualitative synthesis"
    rationale: "Expanded to include implementation barriers (qualitative)"
    amends: "DEV_002"
    version: 2
```

### Decision Amendment Process

When researcher changes mind or refines decision:

1. **View current decision**: `/diverga:memory decision show DEV_002`
2. **Amend decision**: `/diverga:memory decision amend DEV_002 --reason "New data suggests..."`
3. **System action**:
   - Creates new entry: `DEV_002_A1` with `amends: DEV_002`
   - Links to previous decision
   - Records amendment rationale
   - Updates `version: 2`
   - Marks original as "amended" (not deleted)

## Directory Structure

```
.research/
├── baselines/
│   ├── literature/
│   │   └── key_studies.yaml
│   ├── methodology/
│   │   └── frameworks.yaml
│   └── framework/
│       └── theories.yaml
│
├── changes/
│   ├── current/
│   │   ├── research_question.md
│   │   ├── methodology_plan.md
│   │   └── data_extraction.yaml
│   └── archive/
│       ├── foundation_20250203.yaml
│       ├── design_20250210.yaml
│       └── planning_20250217.yaml
│
├── sessions/
│   ├── 2025_02_03_session_001.yaml
│   ├── 2025_02_03_session_002.yaml
│   └── 2025_02_10_session_001.yaml
│
├── project-state.yaml
├── decision-log.yaml
├── checkpoints.yaml
├── issues.log
└── README.md
```

### File Specifications

#### project-state.yaml

```yaml
project:
  name: "AI in STEM Education"
  description: "Meta-analysis of AI-assisted instruction effects"
  created_at: 2025-02-03T10:00:00Z
  updated_at: 2025-02-03T14:30:00Z

research:
  question: "How does AI-assisted instruction affect student engagement in STEM?"
  paradigm: "Quantitative"
  methodology: "Meta-analysis"
  timeline:
    start_date: 2025-02-03
    estimated_completion: 2025-08-03
    current_stage: "foundation"
    stage_progress: "50%"  # % of expected work for this stage

team:
    lead: "Dr. Park"
    members: ["Dr. Park", "Ms. Kim", "Mr. Lee"]

constraints:
  budget: 50000
  budget_used: 5000
  team_capacity_hours_per_week: 40
  database_access: ["Semantic Scholar", "OpenAlex", "arXiv"]

last_session:
  session_id: "2025_02_03_session_002"
  duration_minutes: 45
  checkpoint_reached: "CP_PARADIGM_SELECTION"
```

#### decision-log.yaml

See Decision Audit Trail section above.

#### checkpoints.yaml

```yaml
checkpoints:
  foundation:
    - checkpoint_id: CP_RESEARCH_DIRECTION
      level: REQUIRED
      status: completed
      completed_at: 2025-02-03T10:30:00Z
      decision_id: DEV_001

    - checkpoint_id: CP_PARADIGM_SELECTION
      level: RECOMMENDED
      status: completed
      completed_at: 2025-02-03T10:45:00Z
      decision_id: DEV_002_A1

    - checkpoint_id: CP_SCOPE_DEFINITION
      level: REQUIRED
      status: pending
      triggered_at: 2025-02-03T10:46:00Z

  design:
    - checkpoint_id: CP_THEORY_SELECTION
      level: RECOMMENDED
      status: pending
      expected_completion: 2025-02-10T12:00:00Z

current_stage: "foundation"
completed_stages: []
```

#### issues.log

```yaml
issues:
  - issue_id: ISS_001
    date: 2025-02-03T11:00:00Z
    severity: medium
    category: "checkpoint_skipped"
    checkpoint_id: "CP_SCOPE_DEFINITION"
    message: "User requested to skip scope definition checkpoint"
    resolution: "Documented in decision-log as DEV_003"

  - issue_id: ISS_002
    date: 2025-02-03T13:15:00Z
    severity: low
    category: "api_access_warning"
    message: "OpenAlex API rate limit approaching (890/1000 requests)"
    resolution: "Will reduce request frequency next session"
```

## Usage Examples

### Initialize Project

```bash
# Interactive initialization
/diverga:memory init

# Or with CLI arguments
/diverga:memory init \
  --name "AI in STEM Education" \
  --question "How does AI-assisted instruction affect student engagement?" \
  --paradigm quantitative \
  --methodology "meta-analysis" \
  --timeline 6 \
  --team-lead "Dr. Park"
```

**Output**:
```
✓ Project initialized: AI in STEM Education
✓ Created .research/ directory structure
✓ Set checkpoint: CP_RESEARCH_DIRECTION (REQUIRED)
✓ Next action: Define research scope

Start with: /diverga:memory status
```

### Record Decision

```bash
# At checkpoint completion
/diverga:memory decision add \
  --checkpoint CP_RESEARCH_DIRECTION \
  --selected "How does AI-assisted instruction affect student engagement in STEM?" \
  --rationale "Engagement is measurable and aligns with team expertise"
```

**Output**:
```
✓ Decision recorded: DEV_001
✓ Checkpoint CP_RESEARCH_DIRECTION marked COMPLETED
✓ Next checkpoint: CP_PARADIGM_SELECTION (RECOMMENDED)
✓ Session time: 15 minutes

Next: /diverga:memory checkpoint next
```

### View Project Status

```bash
/diverga:memory status
```

**Output**:
```
╔════════════════════════════════════════╗
║      AI in STEM Education              ║
║      Meta-Analysis Research Project    ║
╚════════════════════════════════════════╝

📊 PROGRESS
├─ Current Stage: Foundation [50% complete]
├─ Sessions: 2 (90 minutes total)
├─ Decisions: 2 completed
└─ Next Milestone: CP_SCOPE_DEFINITION (REQUIRED)

🎯 RESEARCH QUESTION
   "How does AI-assisted instruction affect student engagement in STEM?"

📋 PARADIGM & METHODOLOGY
   Quantitative | Meta-Analysis

⏱️ TIMELINE
   Started: Feb 3, 2025
   Target: Aug 3, 2025
   Elapsed: 45 minutes
   Est. Remaining: 24+ hours

👥 TEAM
   Lead: Dr. Park
   Members: 3

✅ COMPLETED CHECKPOINTS
   ✓ CP_RESEARCH_DIRECTION (Feb 3, 10:30)
   ✓ CP_PARADIGM_SELECTION (Feb 3, 10:45)

⏳ PENDING CHECKPOINTS
   🔴 CP_SCOPE_DEFINITION (REQUIRED)
   🟠 CP_THEORY_SELECTION (RECOMMENDED)

🔗 LAST SESSION
   Duration: 45 minutes
   Ended: Feb 3, 14:30
   Next: CP_SCOPE_DEFINITION discussion
```

### Archive Completed Stage

```bash
# Archive foundation stage after completing all checkpoints
/diverga:memory archive foundation \
  --summary "Research direction and paradigm finalized" \
  --learnings "Team consensus on meta-analysis approach strengthens methodology"
```

**Creates**:
```
.research/changes/archive/foundation_20250203.yaml

foundation_archive:
  archived_at: 2025-02-03T15:00:00Z
  stage_name: "Foundation"
  duration_hours: 2.5

  checkpoints_completed: 2
  checkpoints_skipped: 0
  decisions_made: 2

  summary: "Research direction and paradigm finalized"
  learnings: |
    Team consensus on meta-analysis approach strengthens methodology.
    Early consideration of scope constraints prevented later conflicts.

  next_stage: "Design"
  notes: "Team ready to proceed to theory selection"
```

### List Decisions

```bash
# Show all decisions
/diverga:memory decision list

# Filter by checkpoint
/diverga:memory decision list --checkpoint CP_PARADIGM_SELECTION

# Show with full rationale
/diverga:memory decision list --verbose
```

**Output**:
```
DECISION AUDIT TRAIL
═════════════════════════════════════

DEV_001 | CP_RESEARCH_DIRECTION | ✓ ACTIVE
  Date: Feb 3, 2025 10:30
  Decision: How does AI-assisted instruction affect student engagement in STEM?
  Rationale: Engagement is measurable and significant to existing literature.
  Version: 1

DEV_002_A1 | CP_PARADIGM_SELECTION | ✓ ACTIVE (amended)
  Date: Feb 3, 2025 10:45 [amended 14:30]
  Original (DEV_002): Quantitative: Meta-analysis
  Amendment: Mixed-methods: Meta-analysis + qualitative synthesis
  Amendment Rationale: Expanded to include implementation barriers
  Version: 2

Total Decisions: 2
Total Amendments: 1
```

### Show Full Context

```bash
/diverga:memory context --verbose --format yaml
```

**Output** (excerpt):
```yaml
research_context:
  project_name: "AI in STEM Education"
  current_stage: "foundation"
  research_question: "How does AI-assisted instruction affect student engagement in STEM?"
  paradigm: "Quantitative"
  methodology: "Meta-analysis"

  decisions:
    - DEV_001: "Research question finalized"
    - DEV_002_A1: "Mixed-methods approach approved"

  completed_checkpoints:
    - CP_RESEARCH_DIRECTION (Feb 3 10:30)
    - CP_PARADIGM_SELECTION (Feb 3 10:45)

  pending_checkpoints:
    - CP_SCOPE_DEFINITION (REQUIRED)
    - CP_THEORY_SELECTION (RECOMMENDED)

session_history:
  - session_001: 45 minutes (Feb 3 10:00-10:45)
  - session_002: 45 minutes (Feb 3 13:45-14:30)

issues:
  - ISS_001: Checkpoint skipped (documented)
```

## Migration from v6.8

### Automatic Migration Detection

When accessing v6.8 project with v7.0 system:

```bash
/diverga:memory migrate --dry-run
```

**Output**:
```
MIGRATION CHECK: v6.8 → v7.0
═════════════════════════════════════

Found v6.8 project structure detected:
├─ old_decisions.log (47 entries)
├─ old_checkpoints.txt (basic format)
└─ old_sessions/ (8 files)

MIGRATION PLAN
├─ ✓ Convert decisions to YAML format
├─ ✓ Upgrade checkpoint structure (add levels)
├─ ✓ Import session history
├─ ✓ Create missing metadata fields
└─ ✓ Generate amendment chain analysis

Ready to migrate. Use: /diverga:memory migrate
```

### Execute Migration

```bash
/diverga:memory migrate
```

**Output**:
```
MIGRATION IN PROGRESS
═════════════════════════════════════

✓ Imported 47 decisions
✓ Upgraded checkpoint structure
✓ Analyzed amendment history
✓ Imported 8 session records
✓ Generated project-state.yaml
✓ Validated checkpoint linkage
✓ Created archive/baseline/ structure
✓ Backed up original files to .backup/

MIGRATION COMPLETE
═════════════════════════════════════
Project upgraded to v7.0
Old files backed up in: .research/.backup/v6.8/
Ready to continue research workflow.
```

### Backward Compatibility

v7.0 maintains read-only compatibility with v6.8 files:
- Can read old decision logs
- Can display old checkpoint format
- Cannot write to old format
- Must run migration for full functionality

## Integration with Research Coordinator

Memory system integrates with all Diverga agents (A1-H2) to provide:

### Auto-Context Injection for Agents

When delegating to research agents:

```python
# Without explicit context injection (system does it automatically)
Task(
    subagent_type="diverga:A2-HypothesisArchitect",
    prompt="Help me develop hypotheses for my research"
)

# Memory system automatically:
# 1. Loads .research/project-state.yaml
# 2. Loads .research/decision-log.yaml
# 3. Injects into agent system prompt:
#    - Current research question
#    - Methodology selection
#    - Prior decisions made
#    - Pending checkpoints
# 4. Executes with full context
```

### Checkpoint Enforcement in Agent Execution

Agents automatically:
- Check pending REQUIRED checkpoints before starting
- Validate checkpoint prerequisites
- Record new checkpoints when appropriate
- Update session context
- Log decisions with audit trail

### Session Continuity

When researcher returns later:

```
User: "Let's continue my research on AI in education"

Memory System:
1. Detects keyword trigger
2. Loads last_session from project-state.yaml
3. Displays: "Welcome back! Last session: Feb 3, 14:30"
4. Shows: "Next checkpoint: CP_SCOPE_DEFINITION"
5. Suggests: "Continue with scope definition discussion?"
```

## Advanced Features

### Dependency Chain Tracking

Memory system automatically detects and validates checkpoint dependencies:

```yaml
dependencies:
  CP_PARADIGM_SELECTION:
    requires:
      - CP_RESEARCH_DIRECTION  # Must be completed first
    unlocks:
      - CP_THEORY_SELECTION
      - CP_VARIABLE_DEFINITION
      - CP_METHODOLOGY_APPROVAL

  CP_DATABASE_SELECTION:
    requires:
      - CP_METHODOLOGY_APPROVAL
    unlocks:
      - CP_SEARCH_STRATEGY
      - CP_SCREENING_CRITERIA
```

### Baseline Preservation

Research baselines (literature reviews, theoretical frameworks) are immutable:

```
.research/baselines/
├── literature/
│   └── key_studies.yaml        # Immutable snapshot
├── methodology/
│   └── frameworks.yaml         # Immutable reference
└── framework/
    └── theories.yaml           # Immutable collection
```

Changes are tracked in `changes/current/` while baselines remain stable.

### Cross-Project Learning

After project completion, memory system extracts learnings:

```bash
/diverga:memory extract-learnings
```

Creates shareable artifact for future projects:
- Common decision patterns
- Checkpoint shortcut sequences
- Timeline estimates
- Lessons learned

## Performance and Limits

| Metric | Limit | Notes |
|--------|-------|-------|
| Max decisions per project | 1000 | Archive older decisions if needed |
| Max sessions per project | 500 | Session history available via archive |
| Context injection latency | <100ms | Cached for performance |
| Maximum project lifespan | 10 years | Can archive and restore old projects |

## Privacy and Security

- All project data stored locally in `.research/`
- No cloud sync unless explicitly configured
- Decision audit trail is non-repudiation certified
- Checkpoint timestamps are tamper-evident
- All modifications tracked in git history (if repo enabled)

---

## Summary

Diverga Memory System v7.0 enables researchers to:

✓ **Persist research context** across sessions without manual setup
✓ **Track all decisions** with immutable audit trail and amendment support
✓ **Enforce research rigor** through checkpoint system with dependency validation
✓ **Integrate with agents** automatically for context-aware research support
✓ **Maintain research quality** through baseline preservation and change tracking
✓ **Scale research projects** from single-investigator to multi-year team efforts

---

*Version 7.0.0 | Global Deployment Ready | Last Updated: 2025-02-03*
