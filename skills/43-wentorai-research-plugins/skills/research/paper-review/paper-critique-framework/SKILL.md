---
name: paper-critique-framework
description: "Structured framework for writing peer review reports and paper critiques"
metadata:
  openclaw:
    emoji: "📋"
    category: "research"
    subcategory: "paper-review"
    keywords: ["peer review", "paper critique", "referee report", "academic review", "manuscript evaluation", "constructive feedback"]
    source: "wentor-research-plugins"
---

# Paper Critique and Peer Review Framework

## Overview

Writing constructive peer reviews is a core academic skill. This framework provides a systematic approach to evaluating manuscripts — from initial read-through to the final referee report. It covers what reviewers should assess, how to structure feedback, and how to calibrate between different review outcomes (accept, revise, reject). Applicable to conference papers, journal articles, and internal lab reviews.

## The Three-Pass Review Method

### Pass 1: Orientation (15-20 minutes)

Read only these elements:
- Title, abstract, and keywords
- Introduction (first and last paragraphs)
- Section headings and figure captions
- Conclusion

After Pass 1, answer:
```
□ What is the main claim?
□ What type of contribution? (empirical, theoretical, system, survey)
□ Is it within the venue's scope?
□ Does the abstract accurately represent the content?
□ Initial impression: novel or incremental?
```

### Pass 2: Detailed Read (60-90 minutes)

Read the full paper. Annotate as you go:

```markdown
Annotation symbols:
  ? = I don't understand this
  ! = This is interesting / strong point
  X = I disagree / see a problem
  → = This needs more evidence or justification
  ≈ = This is similar to [existing work] — check novelty
```

Focus on:
- **Claims vs. evidence**: Is every major claim supported by data?
- **Methodology**: Are the methods appropriate for the research question?
- **Experimental design**: Are baselines fair? Are ablations sufficient?
- **Figures and tables**: Do they support the narrative? Are they readable?
- **Writing quality**: Is it clear, concise, and well-organized?

### Pass 3: Verification (30-60 minutes)

For papers you're seriously evaluating:
- Check key references — do they say what the authors claim?
- Verify mathematical derivations (spot-check, not exhaustive)
- Examine statistical claims (p-values, confidence intervals, effect sizes)
- Check for cherry-picking in results (only best runs? selected metrics?)
- Look for missing baselines that should have been compared

## Review Report Structure

```markdown
## Summary (3-5 sentences)
[Describe what the paper does, the approach, and the main finding.
 Demonstrate that you understood the paper.]

## Strengths (bulleted list)
- S1: [Specific strength with evidence from the paper]
- S2: [Another strength]
- S3: [Another strength]

## Weaknesses (bulleted list, ordered by severity)
- W1 (Major): [Specific weakness + why it matters + suggestion to fix]
- W2 (Major): [Another major weakness]
- W3 (Minor): [A less critical issue]
- W4 (Minor): [Another minor issue]

## Questions for Authors
- Q1: [Something you'd like clarified]
- Q2: [A concern that the authors might be able to address]

## Detailed Comments
[Page/line-specific comments, typos, suggestions]

## Overall Assessment
Recommendation: [Strong Accept / Accept / Weak Accept / Borderline /
                  Weak Reject / Reject / Strong Reject]
Confidence: [High / Medium / Low]
```

## Assessment Criteria by Dimension

| Dimension | Questions to Ask | Weight |
|-----------|-----------------|--------|
| **Novelty** | Is the idea new? Is the contribution beyond incremental? | High |
| **Significance** | Would this matter to the community? Does it advance the field? | High |
| **Soundness** | Are the methods correct? Are conclusions supported? | High |
| **Clarity** | Is it well-written? Can it be understood and reproduced? | Medium |
| **Completeness** | Are related works covered? Are experiments thorough? | Medium |
| **Reproducibility** | Could someone replicate this? Code/data available? | Medium |

### Calibration Guide

```
Strong Accept: Significant contribution, technically sound, well-written.
  Would be a highlight of the venue.

Accept: Solid contribution with minor issues. Advances the field.
  Worth publishing as-is or with minor revisions.

Weak Accept: Has merit but notable weaknesses. Contribution is real but modest.
  Borderline for this venue; would be accepted at a less selective venue.

Borderline: Equal arguments for and against. Significant weaknesses offset
  by some novelty. Depends on other reviews.

Weak Reject: Interesting direction but fundamental issues not addressed.
  Major revisions needed that likely require a new submission cycle.

Reject: Significant problems in novelty, soundness, or relevance.
  Not suitable for this venue even with revisions.

Strong Reject: Fundamental flaws. Clearly below threshold.
```

## Common Review Pitfalls to Avoid

| Pitfall | Better Approach |
|---------|----------------|
| "The writing needs improvement" (vague) | Give 2-3 specific examples with suggested fixes |
| Rejecting for not solving YOUR problem | Evaluate the paper on its own stated goals |
| Demanding impossible experiments | Suggest feasible improvements within scope |
| Ignoring supplementary material | Check appendix — authors may have addressed your concern |
| Being harsh without being constructive | Every weakness should include a suggestion for improvement |
| Reviewing too quickly | Block dedicated time; a rushed review harms both authors and science |
| Citing only your own work as "missing" | Only cite if genuinely relevant, not self-promotion |

## Reviewing Different Paper Types

### Empirical Papers
- Are datasets described completely? (Size, source, splits, preprocessing)
- Are baselines appropriate and fairly tuned?
- Statistical significance: error bars, multiple runs, significance tests
- Ablation studies: which components contribute to the gain?

### Systems Papers
- Is the system actually built and evaluated (not just designed)?
- Performance at scale: latency, throughput, resource usage
- Comparison with existing systems (not just algorithms)
- Deployment experience or case studies

### Survey/Position Papers
- Coverage: are major relevant works included?
- Taxonomy: is the organizational framework useful and complete?
- Analysis: does the survey add value beyond listing papers?
- Recency: are the most recent advances covered?

## Ethics Considerations

```markdown
During review, check:
□ Are human subjects involved? Was IRB/ethics approval obtained?
□ Are there potential harms from the technology described?
□ Is the data collection ethical? (Consent, privacy, bias)
□ Are dual-use concerns addressed? (Misuse potential)
□ Are limitations and societal implications discussed?
```

## References

- Smith, R. (2006). "Peer review: a flawed process at the heart of science and journals." *Journal of the Royal Society of Medicine*, 99(4), 178-182.
- [NeurIPS Reviewer Guidelines](https://neurips.cc/Conferences/2025/ReviewerGuidelines)
- [ACL Reviewer Tutorial](https://aclrollingreview.org/reviewertutorial)
- Cormode, G. (2009). "How NOT to review a paper." *ACM SIGMOD Record*, 37(4), 100-104.
