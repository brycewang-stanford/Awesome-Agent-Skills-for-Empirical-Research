---
name: scientific-writing-wrapper
description: "AI-powered scientific writing workflow from outline to polished draft"
metadata:
  openclaw:
    emoji: "✍️"
    category: "writing"
    subcategory: "composition"
    keywords: ["scientific writing", "AI writing", "draft generation", "writing workflow", "paper composition", "manuscript"]
    source: "wentor-research-plugins"
---

# Scientific Writing Wrapper

## Overview

Writing a scientific paper is one of the most time-consuming parts of the research process. The Scientific Writing Wrapper skill provides a structured, AI-assisted workflow that takes you from raw research notes and results to a polished manuscript draft. It is not about generating papers from nothing—it is about using AI tools strategically to accelerate each phase of the writing process while maintaining scientific rigor and your own voice.

This skill covers the complete writing lifecycle: outlining, drafting section by section, iterative revision, and final polish. At each stage, it provides specific prompting strategies and quality checkpoints that ensure the AI output meets the standards of peer-reviewed publication. The workflow is designed to keep you in control of the scientific content while delegating the mechanical aspects of prose generation.

The approach is venue-agnostic and works for journal articles, conference papers, and technical reports across all scientific disciplines.

## Phase 1: Pre-Writing Preparation

Before generating any prose, assemble your writing inputs:

### Gather Raw Materials

Create a structured writing folder with the following:

```
manuscript/
  notes/
    research_question.md     # Your RQ, hypotheses, and scope
    key_findings.md          # Bullet-point list of all results
    figure_descriptions.md   # Description of each figure/table and what it shows
    related_work_notes.md    # Notes on how your work relates to prior literature
  data/
    results_tables.csv       # Raw data for results tables
    figures/                 # All figure files
  references/
    bibliography.bib         # BibTeX file with all references
  drafts/                   # Generated drafts will go here
```

### Define the Paper Skeleton

Write a detailed outline before generating any prose:

1. **Title**: Working title (refine later)
2. **Abstract**: 4-sentence skeleton (context, gap, approach, result)
3. **Introduction**: 4-5 paragraph outline with the specific point of each paragraph
4. **Methods**: Subsection list with bullet points of what each covers
5. **Results**: List each result in presentation order, linked to specific figures/tables
6. **Discussion**: Key interpretation points, limitations, future work
7. **Conclusion**: 3-4 sentence summary of contributions

This outline is your contract with yourself about what the paper will say. AI-generated prose should fill in this structure, not change it.

## Phase 2: Section-by-Section Drafting

Draft each section independently, working from the most concrete (Methods, Results) to the most interpretive (Discussion, Introduction).

### Recommended Drafting Order

1. **Methods** — Most straightforward; describe what you did
2. **Results** — Present findings; closely tied to your figures and tables
3. **Discussion** — Interpret results; requires the most original thinking
4. **Introduction** — Frame the paper; easier to write once you know what you are introducing
5. **Abstract** — Compress the whole paper; write last
6. **Title** — Refine based on the actual content

### Prompting Strategy for Each Section

When using an LLM to draft sections, provide rich context:

```
I am writing the Methods section of a paper about [topic] for [venue].
Here is my outline for this section:
[paste outline]

Here are my detailed notes:
[paste relevant notes]

Please draft this section following these guidelines:
- Use passive voice sparingly; prefer active voice
- Be precise about sample sizes, parameters, and tools
- Include enough detail for reproducibility
- Target approximately [N] words
- Use past tense for describing what was done
- Do not invent any details not present in my notes
```

### Quality Checkpoint After Each Section

After generating a draft of any section, review it against these criteria before moving on:

- **Accuracy**: Does every factual claim match your notes and data? Flag anything the AI might have hallucinated.
- **Completeness**: Are all points from your outline covered?
- **Consistency**: Do variable names, terminology, and notation match the rest of the paper?
- **Voice**: Does the prose sound like your writing? Rewrite sentences that feel generic.
- **Citations**: Are all claims that need citations properly attributed?

## Phase 3: Integration and Revision

### Assembling the Full Draft

Once all sections are drafted individually, assemble them into a complete manuscript and perform an integration pass:

1. **Narrative flow**: Read the paper from start to finish. Does the argument flow logically? Do transitions between sections work?
2. **Redundancy check**: Are any points made in both the Introduction and Discussion without adding new perspective? Eliminate redundancy.
3. **Forward/backward references**: Does the Introduction promise things the Results deliver? Does the Discussion interpret every key result?
4. **Figure/table integration**: Is every figure and table referenced in the text? Do the references appear before or near the figure?

### Iterative Revision Prompts

Use targeted revision prompts for specific improvements:

- **Tighten prose**: "Reduce this paragraph by 30% while preserving all key information."
- **Strengthen transitions**: "Add a transition sentence between these two paragraphs that connects [concept A] to [concept B]."
- **Clarify technical content**: "Rewrite this paragraph for a reader who understands [field] but is not familiar with [specific technique]."
- **Hedging calibration**: "Review this paragraph and ensure claims are appropriately hedged based on the strength of the evidence."

## Phase 4: Final Polish

### Self-Review Checklist

Before submitting for peer review or to a journal, verify:

- [ ] Title is specific and informative
- [ ] Abstract contains all four elements (context, gap, approach, result)
- [ ] All figures have descriptive captions
- [ ] All acronyms defined at first use
- [ ] Reference list is complete and correctly formatted
- [ ] No placeholder text remains (search for "TODO", "XXX", "TBD")
- [ ] Page limits and formatting requirements met
- [ ] Author contributions and acknowledgments included
- [ ] Conflicts of interest disclosed
- [ ] Supplementary materials organized and referenced

### Common AI Writing Pitfalls to Watch For

- **Generic hedging**: AI models overuse phrases like "It is worth noting that" and "Interestingly." Remove these.
- **Circular definitions**: AI sometimes defines a term using the term itself. Check all definitions.
- **False confidence**: AI may present uncertain conclusions with unwarranted certainty. Calibrate claims to your evidence.
- **Homogeneous sentence structure**: AI-generated text often falls into repetitive Subject-Verb-Object patterns. Vary your sentence structure.
- **Missing specifics**: AI may write "significant improvement" without the actual numbers. Always insert your real data.

## References

- PaperCopilot: https://github.com/papercopilot/papercopilot
- Heard, S.B. (2016). "The Scientist's Guide to Writing." Princeton University Press.
- Turbek, S.P. et al. (2016). "Scientific Writing Made Easy." Bulletin of the Ecological Society of America.
