---
name: rebuttal-writing-guide
description: "Write effective rebuttals to reviewer comments for journal submissions"
metadata:
  openclaw:
    emoji: "📝"
    category: "research"
    subcategory: "paper-review"
    keywords: ["rebuttal letter", "reviewer response", "revision", "peer review", "manuscript revision", "author response"]
    source: "wentor-research-plugins"
---

# Rebuttal Writing Guide

A skill for writing effective, professional responses to reviewer comments during the peer review revision process. Covers response letter structure, strategies for addressing criticism constructively, handling unfair reviews, and organizing major revisions.

## Response Letter Structure

### Standard Format

```
Response Letter Template:

Dear Editor and Reviewers,

Thank you for your thoughtful review of our manuscript
"[Title]" (Manuscript ID: [ID]). We appreciate the
constructive feedback and have carefully addressed all
comments. Below, we provide point-by-point responses.

Major changes include:
  - [Summary of change 1]
  - [Summary of change 2]
  - [Summary of change 3]

In the revised manuscript, all changes are highlighted in blue.

---

RESPONSE TO REVIEWER 1

Comment R1.1: [Exact quote of reviewer comment]

Response: [Your response]

Changes made: [Description of what was changed and where]

---

Comment R1.2: [Next comment]
...

RESPONSE TO REVIEWER 2
...
```

### Formatting Best Practices

```python
def format_response(reviewer_num: int, comment_num: int,
                    comment: str, response: str,
                    changes: str = None) -> str:
    """
    Format a single reviewer response entry.

    Args:
        reviewer_num: Reviewer number (1, 2, 3...)
        comment_num: Comment number within this reviewer
        comment: The reviewer's original comment (verbatim)
        response: Your response
        changes: Description of manuscript changes made
    """
    entry = (
        f"**Comment R{reviewer_num}.{comment_num}:**\n"
        f"*{comment}*\n\n"
        f"**Response:**\n{response}\n"
    )

    if changes:
        entry += f"\n**Changes made:** {changes}\n"

    return entry
```

## Response Strategies

### Handling Different Comment Types

```
Agreement (easiest -- just do it):
  Reviewer: "Table 2 should include confidence intervals."
  Response: "We agree. We have added 95% confidence intervals to
            Table 2 (see revised manuscript, p. 12)."

Partial agreement (do what you can, explain what you cannot):
  Reviewer: "The authors should include 5 additional control variables."
  Response: "We appreciate this suggestion. We have added controls for
            age and income, which are theoretically motivated (p. 15).
            We could not include education, occupation, and region
            because [specific reason]. However, we now discuss this
            limitation in Section 5.2."

Respectful disagreement (provide evidence):
  Reviewer: "The sample is too small to draw any conclusions."
  Response: "We understand this concern. However, our power analysis
            (now included as Supplementary Table S1) shows that our
            sample of N=85 provides 80% power to detect a medium
            effect (d=0.5) at alpha=0.05. Furthermore, our primary
            effect sizes were large (d=0.8-1.2), well above the
            detectable threshold. We have added this justification
            to Section 3.1 (p. 8)."
```

### Golden Rules for Rebuttals

```
DO:
  - Thank reviewers (sincerely, not sarcastically)
  - Address EVERY comment, even minor ones
  - Quote the reviewer's comment verbatim before responding
  - Be specific about what changed and where (page/section numbers)
  - Provide evidence for disagreements (citations, analyses, data)
  - Run additional analyses when requested if feasible
  - Use a respectful, professional tone throughout
  - Keep responses concise but thorough

DO NOT:
  - Ignore any comment (even if trivial)
  - Be defensive or dismissive
  - Argue from authority ("We are experts in this area")
  - Lie about changes you did not actually make
  - Attack the reviewer's competence
  - Submit essentially the same manuscript with a new cover letter
```

## Handling Difficult Reviews

### When a Reviewer Is Wrong

```
Situation: The reviewer misunderstood your method.
Strategy: Clarify without blaming the reviewer.

Bad: "The reviewer clearly did not read our paper carefully."

Good: "We appreciate this comment and recognize that our
      description of the method may not have been sufficiently
      clear. We have rewritten Section 3.2 to clarify that
      [explanation]. The key distinction is [point], which we
      now make explicit on p. 10."
```

### When a Reviewer Requests Impossible Changes

```
Situation: The reviewer asks for data you do not have.
Strategy: Acknowledge, explain constraints, offer alternatives.

Response: "This is an excellent suggestion that would strengthen
          the study. Unfortunately, our dataset does not include
          [variable] because [reason]. As an alternative, we have
          [what you did instead]. We have also added this as a
          limitation and future direction (Section 5.3, p. 18)."
```

## Organizing a Major Revision

### Workflow for Revision

```
1. Read ALL reviews completely before making any changes
2. Create a spreadsheet categorizing each comment:
   - Reviewer, comment number, category, difficulty, action
3. Address easy changes first (typos, formatting, missing refs)
4. Tackle substantive comments in order of importance
5. Run any new analyses requested by reviewers
6. Revise the manuscript with tracked changes
7. Write the response letter point by point
8. Have a co-author review both the response and revised manuscript
9. Submit within the deadline (ask for extension if needed)
```

## Cover Letter for Resubmission

The cover letter to the editor should briefly summarize the major changes, highlight the most significant improvements, and note any disagreements with reviewers that you would like the editor to adjudicate. Keep it to one page. The detailed point-by-point responses belong in the separate response document, not the cover letter.
