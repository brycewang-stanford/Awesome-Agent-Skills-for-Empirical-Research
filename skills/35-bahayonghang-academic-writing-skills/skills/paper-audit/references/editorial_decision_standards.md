# Editorial Decision Standards

Reference document for the Synthesis Agent. Defines consensus classification, arbitration rules, score divergence handling, and decision mapping.

---

## 1. Consensus Labels

| Label | Definition | Threshold | Handling |
|-------|-----------|-----------|----------|
| `[CONSENSUS-ALL]` | All 3 agent reviewers flag the same issue | 3/3 agree | Priority 1 — author MUST address |
| `[CONSENSUS-MAJORITY]` | 2 of 3 agent reviewers flag the same issue | 2/3 agree | Priority 1 or 2 (severity-dependent) |
| `[SPLIT]` | No majority — fundamental disagreement | <2/3 | Requires arbitration; document all positions |
| `[AUTOMATED-ONLY]` | Issue found only by Phase 0 scripts | Script-detected | Include as-is; severity from script |

### Matching Criteria

Two findings are considered "the same issue" when:
1. They reference the **same location** (section, figure, table) in the paper, AND
2. They describe the **same underlying problem** (even if phrased differently)

Do NOT match findings that merely share a category (e.g., two unrelated "overclaim" findings in different sections are separate issues).

---

## 2. Arbitration Rules

When reviewers disagree (SPLIT), the Synthesis Agent resolves using these principles in strict priority order:

### Priority 1: Evidence Principle
The position backed by **specific textual evidence** (quotes, data points, citations) outweighs positions based on general impressions.

**Example**: Methodology Reviewer says "Table 3 shows p < 0.05" vs. Critical Reviewer says "results seem unconvincing" — Methodology Reviewer's evidence-backed position wins.

### Priority 2: Expertise Principle
On domain-specific disputes, weight the relevant specialist higher:

| Dispute Type | Primary Authority | Rationale |
|-------------|-------------------|-----------|
| Research design, statistics | Methodology Reviewer | Technical methods expertise |
| Literature coverage, novelty | Domain Reviewer | Field knowledge |
| Logical argument, overclaims | Critical Reviewer | Argumentation expertise |
| Cross-cutting (scope unclear) | Equal weight | Use Evidence Principle |

### Priority 3: Conservative Principle
When evidence and expertise are balanced, lean toward the **more cautious** (more critical) assessment. Rationale: it is safer to flag a potential issue for the author to address than to dismiss a genuine concern.

### Documentation Requirement

Every arbitration MUST be documented with this structure:

```markdown
#### Arbitration: [Issue Title]

- **Disagreement**: [Concise description]
- **Position A** ([Reviewer]): [Their view, with quote from their report]
- **Position B** ([Reviewer]): [Their view, with quote from their report]
- **Principle Applied**: [Evidence / Expertise / Conservative]
- **Resolution**: [Decision and rationale]
- **Confidence**: [High / Medium / Low]
```

---

## 3. Score Divergence Handling

### Detection Threshold
A **score divergence** occurs when two reviewers rate the same dimension with a gap > 2.0 points.

### Handling Protocol

| Gap Size | Action |
|----------|--------|
| <= 1.0 | Average directly, no comment needed |
| 1.1 - 2.0 | Average and note the spread in the report |
| > 2.0 | **Mandatory explanation**: investigate cause, apply arbitration, document rationale for final score |

### Investigation Steps for Large Divergence

1. Identify which specific findings drove each reviewer's score
2. Check if one reviewer considered evidence the other missed
3. Apply the Arbitration Rules (Section 2) to the underlying disagreement
4. Set the final score with documented rationale (do NOT simply average)

### Score Merging Table

| Dimension | Primary Source | Secondary Source | Merge Rule |
|-----------|---------------|-----------------|------------|
| Soundness | Methodology Reviewer | Critical Reviewer | Average; flag if gap > 2 |
| Reproducibility | Methodology Reviewer | — | Direct use |
| Novelty | Domain Reviewer | — | Direct use |
| Significance | Domain Reviewer | — | Direct use |
| 4-dim NeurIPS (Quality, Clarity, Significance, Originality) | Phase 0 script | — | Direct use (objective, deduction-based) |

---

## 4. Decision Matrix

### For Review Mode (Advisory)

| Consensus | Average Score (8-dim) | Recommendation | Typical Action |
|-----------|----------------------|----------------|---------------|
| CONSENSUS-ALL on critical flaw | Any | **Reject** | Fundamental rework needed |
| CONSENSUS-ALL, no critical | >= 7.0 | **Accept** | Minor revisions at most |
| CONSENSUS-ALL, no critical | 5.0 - 6.9 | **Revise & Resubmit** | Address specific weaknesses |
| CONSENSUS-ALL, no critical | < 5.0 | **Reject** | Significant quality concerns |
| CONSENSUS-MAJORITY | >= 7.0 | **Conditional Accept** | Address majority concerns |
| CONSENSUS-MAJORITY | 5.0 - 6.9 | **Major Revision** | Substantial revision needed |
| CONSENSUS-MAJORITY | < 5.0 | **Reject** | Multiple serious issues |
| SPLIT | >= 7.0 | **Discuss** | Highlight areas of disagreement |
| SPLIT | < 7.0 | **Major Revision** | Err on cautious side |

### For 4-Dimension Scale (1-6)

| Overall Score | Label | Interpretation |
|---------------|-------|----------------|
| 5.5 - 6.0 | Exceptional | Top-tier quality, ready for submission |
| 4.5 - 5.4 | Strong | Minor issues only |
| 3.5 - 4.4 | Adequate | Noticeable issues, revision recommended |
| 2.5 - 3.4 | Weak | Significant revision required |
| 1.0 - 2.4 | Insufficient | Fundamental problems |

---

## 5. Report Confidence Indicators

The Synthesis Agent should indicate confidence in the final assessment:

| Indicator | When to Use |
|-----------|------------|
| **High Confidence** | CONSENSUS-ALL on most findings, small score spreads, clear evidence |
| **Medium Confidence** | CONSENSUS-MAJORITY with some SPLIT, moderate score spreads |
| **Low Confidence** | Multiple SPLIT findings, large score divergences, limited evidence |

Include the confidence indicator in the Overall Assessment section of the final report.

---

## 6. Edge Cases

### When All Reviewers Miss an Automated Finding
Phase 0 automated findings that no agent reviewer addresses should be included verbatim in the final report. Do not suppress automated findings simply because agents did not comment on them.

### When an Agent Finding Contradicts Automated Data
If an agent reviewer's assessment contradicts objective automated data (e.g., agent says "citations are complete" but BIB module found undefined references), the automated data takes precedence for factual matters.

### When Critical Reviewer Flags a CRITICAL Issue
Critical Reviewer CRITICAL findings are **never suppressed**, even if other reviewers disagree. They must appear in the final report and be addressed in the Revision Roadmap as Priority 1. The Synthesis Agent may note that other reviewers disagree, but the finding itself must remain.
