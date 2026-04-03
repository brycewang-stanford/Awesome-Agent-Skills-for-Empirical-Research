# Quality Rubrics for Paper Audit

Descriptive scoring anchors for both audit scoring systems.
Use these rubrics to calibrate scores and map them to editorial decisions.

---

## 4-Dimension NeurIPS-Style Scale (1.0 - 6.0)

Base score: 6.0, deducted per issue (Critical -1.5, Major -0.75, Minor -0.25). Floor: 1.0.

### Quality (Weight: 30%)

Primary checks: LOGIC, BIB, GBT7714

| Score Range | Level | Behavioral Indicators |
|-------------|-------|----------------------|
| 5.5 - 6.0 | Exceptional | Technically flawless; rigorous proofs or experiments; all claims well-supported by evidence; no logical gaps |
| 4.5 - 5.4 | Strong | Sound methodology with minor gaps; adequate baselines and ablations; claims mostly supported |
| 3.5 - 4.4 | Adequate | Generally sound but notable weaknesses; some claims lack sufficient evidence; minor logical inconsistencies |
| 2.5 - 3.4 | Weak | Significant methodological concerns; several claims unsupported; logical gaps undermine core argument |
| 1.0 - 2.4 | Insufficient | Fundamental errors in reasoning or methodology; critical evidence missing; conclusions not supported |

### Clarity (Weight: 30%)

Primary checks: FORMAT, GRAMMAR, SENTENCES, CONSISTENCY, REFERENCES, VISUAL, FIGURES, DEAI

| Score Range | Level | Behavioral Indicators |
|-------------|-------|----------------------|
| 5.5 - 6.0 | Exceptional | Crystal clear writing; perfect formatting; all figures/tables well-designed and referenced; no grammar issues |
| 4.5 - 5.4 | Strong | Clear writing with minor formatting issues; figures readable; occasional grammar or style issues |
| 3.5 - 4.4 | Adequate | Generally understandable but some sections unclear; several formatting inconsistencies; grammar errors present |
| 2.5 - 3.4 | Weak | Frequently unclear; significant formatting problems; many grammar errors; figures poorly designed |
| 1.0 - 2.4 | Insufficient | Very difficult to follow; pervasive formatting issues; grammar errors impede comprehension |

### Significance (Weight: 20%)

Primary checks: LOGIC, CHECKLIST

| Score Range | Level | Behavioral Indicators |
|-------------|-------|----------------------|
| 5.5 - 6.0 | Exceptional | Addresses a critical problem; results advance the field substantially; broad impact potential |
| 4.5 - 5.4 | Strong | Important problem with meaningful results; clear contribution to the field |
| 3.5 - 4.4 | Adequate | Reasonable problem; results provide incremental contribution; limited broader impact |
| 2.5 - 3.4 | Weak | Problem significance unclear; results are marginal or narrowly applicable |
| 1.0 - 2.4 | Insufficient | Trivial problem or results; no discernible contribution to the field |

### Originality (Weight: 20%)

Primary checks: DEAI, CHECKLIST

| Score Range | Level | Behavioral Indicators |
|-------------|-------|----------------------|
| 5.5 - 6.0 | Exceptional | Novel framework or paradigm; opens new research direction; highly creative approach |
| 4.5 - 5.4 | Strong | Novel methodology or significant new application; clearly distinct from prior work |
| 3.5 - 4.4 | Adequate | Incremental extension of existing work; some novel elements but largely builds on known approaches |
| 2.5 - 3.4 | Weak | Minor variations of existing methods; limited novelty over prior work |
| 1.0 - 2.4 | Insufficient | No discernible novelty; appears to replicate existing work without meaningful extension |

### Decision Mapping (4-Dimension)

| Overall Score | Recommendation | Typical Next Steps |
|---------------|----------------|-------------------|
| >= 5.5 | Strong Accept | Submit with confidence; minor polish only |
| 4.5 - 5.4 | Accept | Address minor issues in camera-ready version |
| 3.5 - 4.4 | Borderline Accept | Revise and resubmit; follow revision roadmap |
| 2.5 - 3.4 | Borderline Reject | Major revision cycle needed; reconsider approach |
| 1.5 - 2.4 | Reject | Fundamental rework required |
| 1.0 - 1.4 | Strong Reject | Reconsider research direction or methodology |

---

## 8-Dimension ScholarEval Scale (1.0 - 10.0)

Base score: 10.0, deducted per issue (Critical -2.5, Major -1.25, Minor -0.5). Floor: 1.0.

### Soundness (Weight: 20%, Source: Script)

| Score Range | Level | Behavioral Indicators |
|-------------|-------|----------------------|
| 9.0 - 10.0 | Excellent | All claims rigorously supported; no logical gaps; statistical methods appropriate and well-applied |
| 7.0 - 8.9 | Good | Claims mostly supported; minor logical gaps; appropriate methodology with small concerns |
| 5.0 - 6.9 | Fair | Several claims lack support; notable methodological weaknesses; some statistical concerns |
| 3.0 - 4.9 | Poor | Major claims unsupported; significant methodological flaws; inappropriate statistical methods |
| 1.0 - 2.9 | Failing | Fundamental logical errors; methodology invalid; conclusions not justified by evidence |

### Clarity (Weight: 15%, Source: Script)

| Score Range | Level | Behavioral Indicators |
|-------------|-------|----------------------|
| 9.0 - 10.0 | Excellent | Exceptionally well-written; perfectly organized; all notation consistent and well-defined |
| 7.0 - 8.9 | Good | Clear writing; well-organized; minor notation or terminology inconsistencies |
| 5.0 - 6.9 | Fair | Generally clear but some sections confusing; organization could improve; several style issues |
| 3.0 - 4.9 | Poor | Frequently unclear; poor organization; inconsistent terminology hinders understanding |
| 1.0 - 2.9 | Failing | Very difficult to understand; disorganized; pervasive writing problems |

### Presentation (Weight: 10%, Source: Script)

| Score Range | Level | Behavioral Indicators |
|-------------|-------|----------------------|
| 9.0 - 10.0 | Excellent | Professional layout; all figures/tables publication-ready; consistent formatting throughout |
| 7.0 - 8.9 | Good | Good layout; figures clear; minor formatting inconsistencies |
| 5.0 - 6.9 | Fair | Acceptable layout; some figures unclear or poorly labeled; formatting issues present |
| 3.0 - 4.9 | Poor | Significant layout problems; figures hard to read; inconsistent formatting throughout |
| 1.0 - 2.9 | Failing | Unprofessional presentation; figures missing or illegible; major formatting problems |

### Novelty (Weight: 15%, Source: LLM)

| Score Range | Level | Behavioral Indicators |
|-------------|-------|----------------------|
| 9.0 - 10.0 | Excellent | Groundbreaking contribution; entirely new approach or framework; paradigm-shifting potential |
| 7.0 - 8.9 | Good | Clearly novel approach; meaningful distinction from prior work; creative solution |
| 5.0 - 6.9 | Fair | Incremental novelty; extends existing methods in reasonable ways; some creative elements |
| 3.0 - 4.9 | Poor | Marginal novelty; minor variations of existing work; unclear how this advances the field |
| 1.0 - 2.9 | Failing | No discernible novelty; replicates existing work without meaningful contribution |

### Significance (Weight: 15%, Source: LLM)

| Score Range | Level | Behavioral Indicators |
|-------------|-------|----------------------|
| 9.0 - 10.0 | Excellent | Addresses critical problem; results will influence multiple research areas; high practical impact |
| 7.0 - 8.9 | Good | Important problem; meaningful results; clear impact on the target community |
| 5.0 - 6.9 | Fair | Reasonable problem; results contribute incrementally; limited broader impact |
| 3.0 - 4.9 | Poor | Problem significance questionable; results narrowly applicable; minimal impact expected |
| 1.0 - 2.9 | Failing | Trivial or irrelevant problem; results of no practical value |

### Reproducibility (Weight: 10%, Source: Mixed)

| Score Range | Level | Behavioral Indicators |
|-------------|-------|----------------------|
| 9.0 - 10.0 | Excellent | Code and data publicly available; all hyperparameters documented; full experimental protocol provided |
| 7.0 - 8.9 | Good | Code available or promised; most details provided; could likely reproduce with reasonable effort |
| 5.0 - 6.9 | Fair | Some details missing; code not available; reproduction would require significant effort |
| 3.0 - 4.9 | Poor | Major details missing; no code or data; reproduction very difficult |
| 1.0 - 2.9 | Failing | Insufficient detail to reproduce; no artifacts; critical information withheld |

### Ethics (Weight: 5%, Source: LLM)

| Score Range | Level | Behavioral Indicators |
|-------------|-------|----------------------|
| 9.0 - 10.0 | Excellent | Thorough ethics discussion; all concerns addressed; IRB/consent documented where needed |
| 7.0 - 8.9 | Good | Ethics acknowledged; main concerns addressed; minor gaps in discussion |
| 5.0 - 6.9 | Fair | Limited ethics discussion; some concerns not addressed; potential issues not fully explored |
| 3.0 - 4.9 | Poor | Ethics largely ignored; significant concerns unaddressed; potential for harm not discussed |
| 1.0 - 2.9 | Failing | No ethics consideration; clear ethical violations; potential for significant harm |

### Literature Grounding (Weight: 12%, Source: Mixed) -- NEW in v3.0

| Score Range | Level | Behavioral Indicators |
|-------------|-------|----------------------|
| 9.0 - 10.0 | Excellent | Comprehensive coverage of seminal and recent works; thematic organization; clear gap derivation; no important missing references |
| 7.0 - 8.9 | Good | Solid coverage; mostly thematic organization; adequate gap identification; minor gaps |
| 5.0 - 6.9 | Fair | Reasonable but notable gaps; some enumeration; weak gap derivation; several missing recent papers |
| 3.0 - 4.9 | Poor | Incomplete coverage; predominantly enumerated; many important references missing |
| 1.0 - 2.9 | Failing | Minimal literature review; foundational works missing; no literature-contribution connection |

### Overall (Weight: 10%, Source: Computed)

Weighted average of all non-null dimensions, normalized by total available weight.

### Decision Mapping (ScholarEval)

| Overall Score | Readiness Label | Recommendation |
|---------------|----------------|----------------|
| >= 9.0 | Strong Accept | Ready for top-tier venue |
| 8.0 - 8.9 | Accept | Publication ready |
| 7.0 - 7.9 | Ready with Minor Revisions | Address minor issues before submission |
| 6.0 - 6.9 | Major Revisions Needed | Significant rework required |
| 5.0 - 5.9 | Significant Rework Required | Fundamental improvements needed |
| < 5.0 | Not Ready | Reconsider approach and methodology |

---

## Calibration Notes

- Scores are relative to the target venue's standards. A score of 7.0 at NeurIPS represents higher absolute quality than 7.0 at a regional workshop.
- When `--venue` is specified, interpret scores in the context of that venue's acceptance standards.
- Script-based scores are strongest for Clarity and Presentation dimensions; weakest for Novelty and Significance (these require LLM judgment).
- If script and LLM scores diverge by more than 2 points on the same dimension, flag this discrepancy in the report.
- The 4-dimension (1-6) and 8-dimension (1-10) systems are complementary. The 4-dim system provides a quick overview; the 8-dim ScholarEval provides deeper analysis.
