---
name: universal-ma-codebook
description: |
  Universal Meta-Analysis Codebook v2.2 - AI-Human collaboration for meta-analysis data extraction.
  4-layer design: Identifiers, Statistics, AI Provenance, Human Verification.
  Integrates with C5/C6/C7 agents and Category I systematic review pipeline.
  Triggers: meta-analysis, codebook, data extraction, Hedges g, effect size
version: "12.0.1"
---

# Universal Meta-Analysis Codebook

**Version**: 2.2
**Status**: Production
**Codex Review**: APPROVE WITH MINOR CHANGES (2026-01-26)
**Update**: Context-specific extensions (2026-01-26)

## Purpose

A **universal, AI-Human collaboration codebook** for meta-analysis that enables:
1. AI extraction from PDFs (RAG/OCR) with confidence tracking
2. Human verification of AI-extracted values
3. 100% human-verified data through structured workflow
4. Integration with Diverga C5/C6/C7 agents and Category I pipeline
5. **Context-specific extensions** for domain-specific moderator variables

## Context-Specific Extensions

The Universal Codebook supports **project-specific moderator layers** that extend the base 4-layer structure. Each meta-analysis context may have unique moderator variables.

### Extension Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│              UNIVERSAL CODEBOOK WITH CONTEXT EXTENSION              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  LAYER 1: IDENTIFIERS + METADATA (10 fields) ← Universal           │
│  LAYER 2: CORE STATISTICAL VALUES (18 fields) ← Universal          │
│  LAYER 3: CONTEXT-SPECIFIC MODERATORS ← Project Extension          │
│  LAYER 4: AI EXTRACTION PROVENANCE ← Universal                     │
│  LAYER 5: HUMAN VERIFICATION (8 fields) ← Universal                │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Available Context Extensions

| Context | Extension File | Moderator Count |
|---------|----------------|-----------------|
| GenAI-HE | `GENAI_HE_CODEBOOK.md` | 15 moderators |
| Clinical Trials | `CLINICAL_CODEBOOK.md` | TBD |
| Educational Tech | `EDTECH_CODEBOOK.md` | TBD |

### Creating a Context Extension

1. **Define moderator variables** specific to your research domain
2. **Create classification rules** for categorical moderators
3. **Write AI extraction prompts** for each moderator
4. **Configure C6 agent** with the extension schema

```python
# Example: Configure C6 for GenAI-HE context
c6.configure_extension(
    context="genai_he",
    moderators=[
        {"name": "genai_tool", "type": "categorical", "values": ["ChatGPT", "Claude", ...]},
        {"name": "blooms_level", "type": "ordinal", "values": ["remember", "understand", ...]},
        {"name": "study_design", "type": "categorical", "values": ["RCT", "quasi", ...]},
    ],
    extraction_prompts=GENAI_HE_PROMPTS
)
```

### GenAI-HE Extension (Example)

**Layer 3: GenAI-HE Moderator Variables (15 fields)**

| Category | Fields |
|----------|--------|
| GenAI Tool | genai_tool, genai_tool_version, genai_access_type |
| Educational Outcome | blooms_level, outcome_dimension, learning_domain |
| Study Design | study_design, intervention_duration, intervention_type, control_condition |
| Context | education_level, discipline, country, sample_size_total, publication_type |

See: `GenAI-HE-Review-AIMC/docs/GENAI_HE_CODEBOOK.md` for full specification

## Architecture: Four-Layer Design

```
┌─────────────────────────────────────────────────────────────────────┐
│              UNIVERSAL META-ANALYSIS CODEBOOK v2.1                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  LAYER 1: IDENTIFIERS + METADATA (10 fields)                        │
│  study_id, es_id, citation, doi, year, design_type,                │
│  timepoint, arm_label_treat, arm_label_control, unit_of_analysis   │
│                                                                     │
│  LAYER 2: CORE STATISTICAL VALUES (18 fields)                       │
│  Primary: outcome_name → se_g (12)                                  │
│  Change-score: pre_mean_treat, pre_sd_treat, pre_post_corr (3)     │
│  Cluster: cluster_size, icc, n_clusters (3)                        │
│                                                                     │
│  LAYER 3: AI EXTRACTION PROVENANCE                                  │
│  Per-value: ai_value, source, method, confidence, derived_from     │
│  Stored as: ai_extraction_json                                     │
│                                                                     │
│  LAYER 4: HUMAN VERIFICATION (8 fields)                             │
│  verified_status, verified_by, verified_date, corrections_json,    │
│  disagreement_resolved, final_values_json, verification_notes,     │
│  sign_off                                                          │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Workflow: AI-Human Collaboration

### Phase 1: AI Extraction (Automated)

**Triggered by**: I3 RAG building completion or manual PDF upload

**Agent**: C6-DataIntegrityGuard

```python
# C6 extracts statistical values from PDFs
extraction_result = c6.extract_with_provenance(
    pdf_folder="./pdfs",
    methods=["rag", "ocr"],
    reconciliation="hierarchy",
    log_all_candidates=True
)
```

**Actions**:
1. I3 builds RAG from PDFs
2. C6 queries for statistical values (M, SD, n)
3. Multiple extraction methods run in parallel
4. Conflict resolution applied (hierarchy + tolerance)
5. Provenance recorded for all extractions
6. Hedges' g calculated where inputs complete

**Output**: All rows → `verified_status = PENDING`

### Phase 2: Triage (Automated)

**Agent**: C7-ErrorPreventionEngine

```python
# C7 categorizes by effective confidence
triage_result = c7.triage_extractions(
    data=extraction_result,
    thresholds=CONFIGURABLE_THRESHOLDS
)
```

**Categories**:
| Confidence | Status | Action |
|------------|--------|--------|
| HIGH (≥90%) | PROVISIONAL | Awaits sign-off |
| MEDIUM (70-89%) | PENDING | Recommended review |
| LOW (<70%) | PENDING | Required review (priority) |
| CONFLICT | PENDING | Required review (top priority) |

### Phase 3: Human Review (Mandatory)

**Interface**: Excel Review Queue or Web UI

**Critical Rule**: ALL rows require human verification

**Priority Queue**:
1. Conflicts detected (highest)
2. LOW confidence
3. MEDIUM confidence
4. HIGH confidence (spot check)

**Human Actions**:
- Verify AI extraction against PDF
- Correct errors, record reason
- Mark as VERIFIED or REJECTED
- Resolve conflicts

### Phase 4: Final Sign-Off

**Agent**: C5-MetaAnalysisMaster

```python
# C5 validates all gates pass
validation = c5.validate_final(
    data=verified_data,
    require_all_verified=True,
    require_all_signed_off=True
)
```

**Requirements**:
- All rows: `verified_status = VERIFIED`
- All rows: `sign_off = True`
- All gates pass (C5 validation)

**Result**: 100% Human-Verified Dataset

---

## Field Specifications

### Layer 1: Identifiers + Metadata

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `study_id` | str | Unique study identifier | "CHEN_2024" |
| `es_id` | str | Effect size ID | "CHEN_2024_01" |
| `citation` | str | Full APA citation | "Chen et al. (2024)..." |
| `doi` | str | DOI | "10.1000/xyz" |
| `year` | int | Publication year | 2024 |
| `design_type` | str | RCT\|QUASI\|PRE_POST | "RCT" |
| `timepoint` | str | Measurement timing | "post" |
| `arm_label_treat` | str | Treatment label | "ChatGPT group" |
| `arm_label_control` | str | Control label | "Traditional" |
| `unit_of_analysis` | str | individual\|cluster | "individual" |

### Layer 2: Core Statistical Values

#### Primary Statistics

| Field | Type | Required |
|-------|------|----------|
| `outcome_name` | str | Yes |
| `outcome_unit` | str | No |
| `es_type` | str | Yes |
| `analysis_type` | str | No |
| `n_treatment` | int | Yes |
| `n_control` | int | Yes |
| `m_treatment` | float | Conditional |
| `sd_treatment` | float | Conditional |
| `m_control` | float | Conditional |
| `sd_control` | float | Conditional |
| `hedges_g` | float | Derived |
| `se_g` | float | Derived |

#### Change-Score Fields (when es_type = CHANGE)

| Field | Type | Description |
|-------|------|-------------|
| `pre_mean_treat` | float | Pre-test mean |
| `pre_sd_treat` | float | Pre-test SD |
| `pre_post_corr` | float | Pre-post correlation (default 0.5) |

#### Cluster Fields (when unit_of_analysis = cluster)

| Field | Type | Description |
|-------|------|-------------|
| `cluster_size` | float | Average cluster size |
| `icc` | float | Intra-class correlation |
| `n_clusters` | int | Number of clusters |

### Layer 3: AI Extraction Provenance

Stored in `ai_extraction_json`:

```json
{
  "n_treatment": {
    "ai_value": 43,
    "source": "Table 2, p.8",
    "method": "OCR",
    "confidence": 85,
    "derived_from": null
  },
  "sd_treatment": {
    "ai_value": 12.5,
    "source": "Text p.11, 95% CI",
    "method": "CALCULATED",
    "confidence": 92,
    "derived_from": "CI_95: SE = (14.8-10.2)/3.92"
  }
}
```

### Layer 4: Human Verification

| Field | Type | Values |
|-------|------|--------|
| `verified_status` | str | PENDING\|PROVISIONAL\|VERIFIED\|REJECTED |
| `verified_by` | str | Reviewer initials |
| `verified_date` | date | Review date |
| `corrections_json` | json | {field: {ai_value, final_value, reason}} |
| `disagreement_resolved` | bool | Conflict resolved? |
| `final_values_json` | json | Human-confirmed values |
| `verification_notes` | str | Free text notes |
| `sign_off` | bool | Final approval |

---

## Confidence Thresholds (Configurable)

### Per-Field Thresholds

| Field | HIGH | MEDIUM | LOW |
|-------|------|--------|-----|
| n (sample size) | ≥95% | 80-94% | <80% |
| M (mean) | ≥90% | 70-89% | <70% |
| SD | ≥85% | 65-84% | <65% |
| hedges_g (derived) | ≥92% | 75-91% | <75% |
| se_g (derived) | ≥92% | 75-91% | <75% |
| pre_post_corr | ≥85% | 65-84% | <65% |
| icc | ≥80% | 60-79% | <60% |

### Per-Source Modifiers

| Source | Modifier |
|--------|----------|
| Structured table | +10% |
| Semi-structured figure | +5% |
| Unstructured text | 0% |
| Abstract only | -15% |
| OCR with artifacts | -20% |

**Formula**: `effective_confidence = base_confidence + source_modifier`

---

## Conflict Resolution

### Extraction Hierarchy

| Priority | Source | Weight |
|----------|--------|--------|
| 1 | Table cell | 1.0 |
| 2 | Figure data | 0.9 |
| 3 | In-text stats | 0.8 |
| 4 | Abstract | 0.5 |

### Tolerance Thresholds

| Value Type | Relative | Absolute |
|------------|----------|----------|
| n (sample size) | 5% | 2 |
| M (mean) | 10% | 0.5 |
| SD | 15% | 0.5 |

**Rule**: If disagreement exceeds EITHER threshold → Human review required

---

## Derived Value Verification

For calculated values (hedges_g, se_g), human verification means:

1. All source values (M, SD, n) verified
2. Formula appropriate for es_type
3. If change-score: pre_post_corr verified or documented default
4. If cluster: ICC and cluster_size verified
5. Final values recalculated from verified inputs

---

## Integration Points

### Systematic Review Pipeline Integration

```python
# After Stage 5 (RAG building)
# RAG query integration

rag = RAGQuery(project_path)
values = c6.extract_from_rag(
    rag=rag,
    fields=["n_treatment", "n_control", "m_treatment", "sd_treatment",
            "m_control", "sd_control"],
    fallback_to_ocr=True
)
```

### C5/C6/C7 Agent Roles

| Agent | Role in Codebook |
|-------|------------------|
| C5-MetaAnalysisMaster | Final validation, gate enforcement |
| C6-DataIntegrityGuard | Extraction, Hedges' g calculation |
| C7-ErrorPreventionEngine | Triage, conflict detection, warnings |

---

## Excel Template Structure

### Sheet 1: Codebook

One-page reference with field definitions

### Sheet 2: Data (Main)

41 columns (39 visible + 2 JSON)

### Sheet 3: Review Queue

Priority-ordered list of rows needing human review

### Sheet 4: Extraction Log

Audit trail of all AI extractions

---

## Success Metrics

| Metric | Target |
|--------|--------|
| AI extraction rate | ≥85% |
| AI confidence accuracy | ≥90% |
| Conflict detection rate | ≥95% |
| Human review completeness | 100% |
| Final sign-off rate | 100% |
| Data completeness (Hedges' g) | ≥95% |

---

## Commands

```bash
# Initialize codebook for a project
diverga codebook init --project genai-he

# Import AI extractions
diverga codebook import --source rag --project genai-he

# Generate review queue
diverga codebook queue --project genai-he

# Validate final dataset
diverga codebook validate --project genai-he
```

---

## References

- Plan document: `docs/plans/META_ANALYSIS_CODEBOOK_PLAN_V2.md`
- C5 agent: `.claude/skills/C5-meta-analysis-master/SKILL.md`
- C6 agent: `.claude/skills/C6-data-integrity-guard/SKILL.md`
- C7 agent: `.claude/skills/C7-error-prevention-engine/SKILL.md`
- Borenstein et al. (2021). Introduction to Meta-Analysis
- Cochrane Handbook Chapter 6: Extracting Data
- PRISMA 2020 Statement

---

*Created: 2026-01-26*
*Codex Review: APPROVE WITH MINOR CHANGES*
*Author: Claude Code*
