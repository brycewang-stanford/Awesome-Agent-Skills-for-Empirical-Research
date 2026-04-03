---
name: automated-review-guide
description: "AI-assisted peer review tools, workflows, and quality standards"
metadata:
  openclaw:
    emoji: "🤖"
    category: "research"
    subcategory: "paper-review"
    keywords: ["automated review", "AI peer review", "LLM review", "review quality", "manuscript screening", "editorial workflow"]
    source: "wentor-research-plugins"
---

# Automated Review Guide

A skill for leveraging AI-assisted tools in the peer review process, covering both author-side self-review and editor-side manuscript screening. Addresses tool selection, prompt engineering for review tasks, limitations and biases of LLM-generated reviews, quality assurance workflows, and ethical guidelines for AI use in peer review.

## Overview of AI in Peer Review

### Current Landscape

AI-assisted peer review tools operate at multiple stages of the publication pipeline. Understanding where automation adds genuine value and where it introduces risk is essential for responsible adoption.

```
Where AI assists in peer review:

Author-side (pre-submission):
  - Grammar and style checking (Grammarly, Writefull)
  - Statistical result verification (statcheck, GRIM/SPRITE)
  - Reference completeness checking
  - Plagiarism detection (iThenticate, Turnitin)
  - Readability scoring
  - Structural completeness (IMRAD compliance)

Editor-side (triage and assignment):
  - Desk rejection screening (scope, quality threshold)
  - Reviewer matching (expertise alignment)
  - Conflict of interest detection
  - Duplicate submission detection
  - Plagiarism and image manipulation screening

Reviewer-side (review assistance):
  - Paper summarization for rapid assessment
  - Statistical claim verification
  - Reference checking (do cited papers support claims)
  - Comparison with related work
  - Structured review template generation

Post-review:
  - Decision consistency analysis
  - Review quality assessment
  - Revision compliance checking
```

## Self-Review with AI Before Submission

### Structured Self-Review Prompts

```
Pre-submission AI review checklist:

1. Abstract completeness check:
   Prompt: "Analyze this abstract. Does it contain:
   (a) background/motivation, (b) research gap,
   (c) methodology summary, (d) key results with
   numbers, (e) conclusion/implication? Identify
   any missing elements."

2. Claim-evidence alignment:
   Prompt: "For each claim in the Discussion section,
   identify the specific result (table, figure, or
   statistical test) that supports it. Flag any claims
   without corresponding evidence in the Results."

3. Methods reproducibility:
   Prompt: "Read the Methods section and list every
   piece of information that another researcher would
   need to replicate this study. Identify any gaps:
   missing sample sizes, unspecified parameters,
   ambiguous procedures, unnamed software versions."

4. Statistical reporting:
   Prompt: "Check all statistical results in this paper
   for completeness. Each test should report: test name,
   test statistic, degrees of freedom, p-value, and
   effect size. List any incomplete reports."

5. Reference audit:
   Prompt: "For each citation in the Introduction, verify
   that the cited claim matches the in-text description.
   Flag any cases where the citation might not support
   the specific claim being made."
```

### Automated Statistical Checking

```python
import re

def check_statistical_reporting(text):
    """
    Check for common statistical reporting issues.

    Verifies:
    - p-values are reported with test statistics
    - Degrees of freedom are included
    - Effect sizes are reported
    - Exact p-values (not just p < .05)
    """
    issues = []

    # Find p-value reports
    p_pattern = r'p\s*[<=<>]\s*\.?\d+'
    p_matches = re.finditer(p_pattern, text, re.IGNORECASE)

    for match in p_matches:
        # Check context (100 chars before) for test statistic
        start = max(0, match.start() - 100)
        context = text[start:match.end()]

        has_test_stat = any(
            stat in context for stat in
            ["t(", "F(", "chi", "r(", "r =", "z =",
             "U =", "W =", "H(", "d =", "eta"]
        )

        if not has_test_stat:
            issues.append({
                "location": match.start(),
                "text": context[-50:],
                "issue": "p-value without test statistic"
            })

    # Check for "p < .05" without exact values
    vague_p = re.findall(r'p\s*<\s*\.05(?!\d)', text)
    if vague_p:
        issues.append({
            "issue": f"Found {len(vague_p)} instances of 'p < .05' "
                     "without exact p-values. APA recommends exact values."
        })

    return issues
```

## Limitations and Biases of AI Reviews

### Known Failure Modes

```
AI review limitations to be aware of:

1. Hallucinated references:
   - LLMs may claim a paper cites X when it does not
   - Always verify any reference claims made by AI
   - LLMs cannot actually read PDFs behind paywalls

2. False confidence in statistical judgments:
   - LLMs may incorrectly flag valid statistical approaches
   - They may miss subtle errors that require domain expertise
   - Statistical verification tools (statcheck) are more reliable

3. Novelty assessment failures:
   - LLMs have knowledge cutoff dates and cannot assess true novelty
   - They may flag well-known methods as novel or novel methods as
     well-known, depending on training data coverage
   - Human expertise is essential for novelty evaluation

4. Disciplinary bias:
   - LLMs trained primarily on English text from well-resourced fields
   - May apply STEM conventions to humanities papers inappropriately
   - May not recognize valid methodologies in underrepresented fields

5. Sycophancy:
   - Tendency to agree with the framing of the prompt
   - "Review this excellent paper" vs "Review this paper" yields
     systematically different feedback
   - Use neutral prompts and ask for both strengths and weaknesses

6. Reproducibility of reviews:
   - Same paper reviewed twice may get different feedback
   - Temperature settings affect consistency
   - Document model, version, and prompt for reproducibility
```

## Quality Assurance Workflow

### Human-AI Hybrid Review

```
Recommended workflow for responsible AI-assisted review:

Step 1 - Human first read (30 minutes):
  Read the paper yourself without AI assistance.
  Form your own initial impressions about strengths,
  weaknesses, and significance.

Step 2 - AI-assisted deep dive (20 minutes):
  Use AI to check specific aspects:
  - Statistical reporting completeness
  - Methods section gaps
  - Reference verification
  - Structural issues

Step 3 - Human synthesis (30 minutes):
  Integrate your own assessment with AI-flagged issues.
  Verify every AI-identified issue before including it.
  Discard AI suggestions that are incorrect or irrelevant.
  Write the review in your own voice.

Step 4 - Disclosure:
  If journal policy requires it, disclose AI tool usage.
  Many journals now have explicit policies on AI in review.

Key principle: AI should help you be MORE thorough,
not replace your expert judgment. The review is YOUR
professional responsibility.
```

## Ethical Guidelines

### Responsible Use Framework

```
Ethics of AI in peer review:

Transparency:
  - Disclose AI tool usage per journal policy
  - Do not present AI-generated text as your own analysis
  - Note which aspects of the review were AI-assisted

Confidentiality:
  - NEVER upload full manuscripts to public AI services
  - Use on-premises or privacy-preserving tools
  - Manuscripts under review are confidential documents
  - Check with the journal before using any AI tool

Accountability:
  - The reviewer, not the AI, is responsible for the review
  - Verify all AI-generated claims and suggestions
  - Do not blindly copy AI output into review reports
  - You must understand and agree with every point in your review

Fairness:
  - Apply AI-assisted scrutiny equally to all papers
  - Be aware of AI biases against non-native English text
  - Do not use AI to generate reject recommendations automatically
  - Maintain the same standards you would without AI assistance

Journal policies (check before using AI):
  - Nature: allows AI tools, requires disclosure
  - Science: allows AI tools for editing, not for review content
  - Many journals have not yet issued explicit guidance
  - When in doubt, disclose and ask the editor
```

## Tools and Resources

```
AI review assistance tools:

General-purpose:
  - Writefull: academic language and style checking
  - Paperpal: manuscript readiness assessment
  - SciSpace: paper reading and comprehension assistance

Statistical checking:
  - statcheck: automatic verification of statistical results
  - GRIM test: granularity-related inconsistency of means
  - SPRITE: sample parameter reconstruction via iterative techniques

Plagiarism and integrity:
  - iThenticate: similarity detection (industry standard)
  - Turnitin: similarity detection (education-focused)
  - Imagetwin: image duplication detection

Reference management:
  - scite.ai: smart citation analysis (supporting/contrasting)
  - OpenAlex: related work discovery
  - Connected Papers: citation graph visualization
```

AI-assisted review tools are most valuable when they augment rather than replace human expertise. They excel at systematic, repetitive checks (statistical reporting, reference formatting, structural completeness) but cannot substitute for the domain knowledge, contextual understanding, and scholarly judgment that define quality peer review.
