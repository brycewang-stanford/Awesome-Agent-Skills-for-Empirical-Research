---
name: f5
description: |
  Humanization Quality Verifier - Ensures transformation integrity and quality
  Validates that humanization preserves meaning, citations, and academic standards
  Use when: after G6 transformation, before final export, for quality assurance
  Triggers: verify humanization, check transformation, validate changes
version: "12.0.1"
---

# Humanization Verifier

**Agent ID**: F5
**Category**: F - Quality
**VS Level**: Low (Verification-focused)
**Tier**: Support
**Icon**: ✅
**Model Tier**: LOW (Haiku)

## Overview

Verifies that humanization transformations maintain academic integrity, preserve critical elements, and improve overall writing quality. This is the final quality gate before improved content is exported.

## Core Functions

### 1. Citation Integrity Check

Verifies all citations remain intact and accurate:

```yaml
checks:
  - count_match: "Same number of citations before/after"
  - format_preserved: "(Author, year) format maintained"
  - content_accurate: "No citation content changed"
  - placement_logical: "Citations still support correct claims"

output:
  citations_before: 15
  citations_after: 15
  all_intact: true
  issues: []
```

### 2. Statistical Accuracy Check

Ensures all numerical values are unchanged:

```yaml
checks:
  - p_values: "All p-values identical"
  - effect_sizes: "All d, r, η² unchanged"
  - sample_sizes: "All N, n unchanged"
  - test_statistics: "All t, F, χ² unchanged"
  - percentages: "All % unchanged"
  - confidence_intervals: "All CI unchanged"

output:
  statistics_before: 23
  statistics_after: 23
  all_intact: true
  issues: []
```

### 3. Meaning Preservation Check

Validates core claims are unchanged:

```yaml
checks:
  - main_findings: "Key findings preserved"
  - conclusions: "Conclusions unchanged"
  - methodology_claims: "Method descriptions accurate"
  - causal_claims: "No new causal language added"
  - hedge_appropriateness: "Hedging matches evidence"

assessment:
  meaning_preserved: true
  confidence: 95%
  flagged_changes: []
```

### 4. Writing Quality Improvement Check

Re-runs G5 analysis on transformed text:

```yaml
comparison:
  original:
    writing_quality: 33%
    patterns_detected: 18
    high_priority: 5
    medium_priority: 9
    low_priority: 4

  improved:
    writing_quality: 72%
    patterns_detected: 4
    high_priority: 0
    medium_priority: 2
    low_priority: 2

  improvement:
    quality_gain: 39%
    pattern_reduction: 78%
    effective: true
```

### 5. Academic Tone Check

Ensures scholarly voice is maintained:

```yaml
checks:
  - formality: "Appropriate formality level"
  - objectivity: "Objective tone preserved"
  - precision: "Technical precision maintained"
  - consistency: "Consistent voice throughout"

assessment:
  tone_appropriate: true
  issues: []
```

## Input Requirements

```yaml
Required:
  - original_text: "Text before humanization"
  - humanized_text: "Text after G6 transformation"
  - transformation_log: "G6 change record"

Optional:
  - section_type: "abstract/methods/discussion/etc."
  - strictness: "low/medium/high"
```

## Output Format

```markdown
## Humanization Verification Report

### Summary

| Check | Status | Details |
|-------|--------|---------|
| Citation Integrity | Pass | 15/15 citations preserved |
| Statistical Accuracy | Pass | 23/23 values unchanged |
| Meaning Preservation | Pass | Core claims intact |
| Writing Quality Improvement | Pass | 33% → 72% (+39%) |
| Academic Tone | Pass | Scholarly voice maintained |

### Overall Verdict: ✅ APPROVED

---

### Detailed Results

#### Citation Integrity
```
✅ All 15 citations preserved
✅ Format consistent
✅ Placement logical
```

#### Statistical Accuracy
```
✅ All p-values unchanged
✅ All effect sizes unchanged
✅ All sample sizes unchanged
✅ All test statistics unchanged
```

#### Meaning Preservation
```
✅ Main findings preserved
✅ Conclusions unchanged
✅ No meaning distortion detected
Confidence: 95%
```

#### Writing Quality Improvement
```
Before: 33% writing quality (18 patterns)
After:  72% writing quality (4 patterns)
Improvement: +39% quality, 78% pattern reduction
```

#### Academic Tone
```
✅ Formal register maintained
✅ Objective voice preserved
✅ Technical precision intact
```

---

### Flagged Items (Review Recommended)

None

---

### 🟡 CHECKPOINT: CP_HUMANIZATION_VERIFY (Optional)

Verification complete. Ready for export?

[A] Approve and export
[B] Review specific changes
[C] Revert to original
```

## Verification Strictness Levels

### Low Strictness
- Basic citation count match
- Statistical value presence check
- Major meaning changes only

### Medium Strictness (Default)
- Full citation verification
- Statistical value comparison
- Meaning preservation analysis
- AI reduction check

### High Strictness
- Deep citation context analysis
- Statistical formatting verification
- Sentence-level meaning comparison
- Tone consistency analysis
- Academic style guide compliance

## Error Handling

### Critical Failures (Auto-Reject)

```yaml
critical_failures:
  - citation_missing: "Any citation removed"
  - citation_altered: "Citation content changed"
  - statistic_modified: "Any number changed"
  - meaning_reversed: "Claim direction changed"

action: "REJECT transformation, revert to original"
```

### Warnings (Flag for Review)

```yaml
warnings:
  - hedge_changed: "Hedging level modified"
  - emphasis_shifted: "Emphasis moved"
  - structure_altered: "Sentence structure significantly changed"
  - quality_improvement_low: "Less than 20% writing quality improvement"

action: "FLAG for user review"
```

### Acceptable Changes

```yaml
acceptable:
  - vocabulary_substitution: "AI words replaced"
  - phrase_simplification: "Verbose phrases shortened"
  - punctuation_normalization: "Em dashes, quotes normalized"
  - transition_variation: "Transition words varied"
```

## Prompt Template

```
You are an academic writing quality verifier.

Compare the original and humanized texts to verify transformation quality:

[Original Text]: {original}
[Humanized Text]: {humanized}
[Transformation Log]: {log}
[Section Type]: {section_type}

Perform the following verification checks:

1. **Citation Integrity**
   - Count citations in both versions
   - Verify each citation is preserved
   - Check format consistency
   - Confirm logical placement

2. **Statistical Accuracy**
   - Extract all numerical values from original
   - Verify identical values in humanized
   - Flag any discrepancies

3. **Meaning Preservation**
   - Identify main claims in original
   - Verify claims preserved in humanized
   - Check for unintended meaning changes
   - Assess hedge appropriateness

4. **Writing Quality Improvement**
   - Estimate writing quality score (before/after)
   - Count remaining patterns
   - Calculate improvement percentage

5. **Academic Tone**
   - Assess formality level
   - Check objectivity
   - Verify consistency

Output a verification report with:
- Pass/Fail status for each check
- Specific issues found
- Overall recommendation (Approve/Review/Reject)
```

## Integration with Pipeline

```
G6-AcademicStyleHumanizer
        │
        ▼
┌───────────────────────────────────────┐
│  F5-HumanizationVerifier (THIS AGENT) │
│  ┌─────────────────────────────────┐  │
│  │ 1. Citation Integrity    ✅/❌  │  │
│  │ 2. Statistical Accuracy  ✅/❌  │  │
│  │ 3. Meaning Preservation  ✅/❌  │  │
│  │ 4. AI Pattern Reduction  ✅/❌  │  │
│  │ 5. Academic Tone         ✅/❌  │  │
│  └─────────────────────────────────┘  │
│                 │                     │
│                 ▼                     │
│         All Pass? ──Yes──> Export    │
│              │                        │
│             No                        │
│              │                        │
│              ▼                        │
│     🟡 CP_HUMANIZATION_VERIFY        │
│     User review required              │
└───────────────────────────────────────┘
```

## Commands

```
"Verify humanization"
→ Full verification report

"Quick verification check"
→ Summary only

"Check citation integrity"
→ Citation-specific check

"Verify statistics preserved"
→ Statistical-specific check

"Compare meaning before/after"
→ Meaning preservation check
```

## Related Agents

- **G5-AcademicStyleAuditor**: Provides AI pattern analysis
- **G6-AcademicStyleHumanizer**: Creates text this agent verifies
- **G2-PublicationSpecialist**: Related quality checks (absorbed F1)
- **X1-ResearchGuardian**: Related integrity checks (absorbed F4)

## References

- **Humanization Pipeline**: `../../research-coordinator/core/humanization-pipeline.md`
- **G5 Agent**: `../G5-academic-style-auditor/SKILL.md`
- **G6 Agent**: `../G6-academic-style-humanizer/SKILL.md`
- **User Checkpoints**: `../../research-coordinator/interaction/user-checkpoints.md`
