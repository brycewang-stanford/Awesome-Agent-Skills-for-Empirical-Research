---
name: discussion-writing-guide
description: "Write effective discussion sections that interpret results and impact"
metadata:
  openclaw:
    emoji: "💭"
    category: "writing"
    subcategory: "composition"
    keywords: ["discussion section", "academic writing", "results interpretation", "paper structure", "research implications"]
    source: "wentor-research-plugins"
---

# Discussion Writing Guide

A skill for writing compelling discussion sections in academic papers. Covers the standard structure, strategies for interpreting results, addressing limitations, connecting to existing literature, and articulating the broader implications of your findings.

## Discussion Section Structure

### The Hourglass Model

The discussion mirrors the introduction in reverse -- it starts narrow (your specific findings) and broadens to implications:

```
Introduction:  Broad context -> Specific gap -> Your question
Discussion:    Your findings -> Broader literature -> Implications

Standard Structure:
  1. Summary of key findings (1-2 paragraphs)
  2. Interpretation and comparison with literature (bulk of section)
  3. Limitations (1-2 paragraphs)
  4. Implications and future directions (1-2 paragraphs)
  5. Conclusion (optional, or as separate section)
```

### Paragraph-Level Template

```python
def outline_discussion(findings: list[dict],
                       literature_connections: list[dict],
                       limitations: list[str],
                       implications: list[str]) -> dict:
    """
    Generate a structured discussion outline.

    Args:
        findings: List of dicts with 'result' and 'interpretation'
        literature_connections: Dicts with 'finding', 'related_work', 'comparison'
        limitations: List of limitation statements
        implications: List of implication statements
    """
    outline = {
        "opening_paragraph": {
            "purpose": "Restate the research question and summarize key findings",
            "template": (
                "This study examined [research question]. "
                "The principal finding was [main result], "
                "which [supports/contradicts/extends] [hypothesis or expectation]."
            ),
            "tips": [
                "Do NOT repeat numbers from Results -- summarize in words",
                "State whether hypotheses were supported",
                "Lead with the most important finding"
            ]
        },
        "interpretation_paragraphs": [
            {
                "finding": f["result"],
                "interpretation": f["interpretation"],
                "literature": next(
                    (lc for lc in literature_connections
                     if lc["finding"] == f["result"]), None
                )
            }
            for f in findings
        ],
        "limitations": {
            "items": limitations,
            "tip": "Frame limitations honestly but not apologetically"
        },
        "implications": {
            "items": implications,
            "tip": "Distinguish practical implications from theoretical ones"
        }
    }
    return outline
```

## Interpreting Results

### Connecting Findings to Literature

Each major finding should be discussed in relation to prior work:

```
Pattern 1 - Consistent with prior work:
  "Our finding that X is associated with Y is consistent with
   Smith et al. (2022), who reported a similar relationship in
   [different context]. This convergence across [populations/methods]
   strengthens the evidence that [mechanism/explanation]."

Pattern 2 - Contradicts prior work:
  "In contrast to Jones et al. (2021), who found no effect of X
   on Y, our results suggest a significant positive relationship.
   This discrepancy may be explained by [methodological differences,
   population differences, measurement differences]."

Pattern 3 - Extends prior work:
  "While previous studies have established that X affects Y,
   our results extend this finding by showing that this effect
   is moderated by Z, suggesting [new insight]."

Pattern 4 - Novel finding:
  "To our knowledge, this is the first study to demonstrate [finding].
   One possible explanation is [mechanism]. However, this interpretation
   should be treated with caution until [replication/additional evidence]."
```

### Avoiding Common Mistakes

```
DO NOT:
  - Simply restate results with numbers (that is the Results section)
  - Introduce new results not presented in the Results section
  - Overclaim: "This proves that..." (use "suggests," "indicates")
  - Ignore findings that contradict your hypothesis
  - Speculate without clearly labeling it as speculation

DO:
  - Interpret what the results MEAN, not just what they ARE
  - Address unexpected or negative findings
  - Explain WHY your results may differ from others
  - Connect findings to theory or conceptual frameworks
  - Use hedging language appropriately (may, might, suggests, appears)
```

## Writing About Limitations

### Framing Limitations Constructively

```
Weak framing:
  "A limitation of this study is that the sample size was small."

Better framing:
  "The sample size (N=45) may have limited statistical power to
   detect small effects. However, the effect sizes observed for
   our primary outcomes were medium to large (Cohen's d = 0.6-0.8),
   suggesting that the main findings are robust. Future studies
   with larger samples could examine whether the non-significant
   trends observed for secondary outcomes reach significance."

Structure for each limitation:
  1. State the limitation clearly
  2. Explain its potential impact on the findings
  3. Note any mitigating factors
  4. Suggest how future work could address it
```

### Common Limitation Categories

| Category | Examples |
|----------|---------|
| Design | Cross-sectional (cannot infer causation), no control group |
| Sample | Small N, non-representative, convenience sampling |
| Measurement | Self-report bias, single-item measures, validity concerns |
| Analysis | Multiple comparisons, missing data, model assumptions |
| Generalizability | Single site, specific population, cultural context |

## Implications and Future Directions

### Types of Implications

```
Theoretical implications:
  "These findings support the [theory name] by demonstrating that
   [specific contribution to theory]."

Practical implications:
  "These results suggest that [practitioners/policymakers] should
   consider [actionable recommendation] when [context]."

Methodological implications:
  "Our comparison of [methods] suggests that [method recommendation]
   is preferable when [condition], which may inform future study design."

Future research directions:
  "Three avenues for future research emerge from these findings:
   (1) [replication in different context], (2) [testing the proposed
   mechanism], and (3) [extending to related outcomes]."
```

## Conclusion Paragraph

The final paragraph should leave readers with a clear takeaway. State the single most important finding and its significance in 2-3 sentences. Avoid introducing new information or hedging excessively in the conclusion. End on a forward-looking note that motivates continued research.
