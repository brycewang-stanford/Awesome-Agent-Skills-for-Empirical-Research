---
name: philosophy-research-guide
description: "Research methods and analytical frameworks for philosophical inquiry and scho..."
metadata:
  openclaw:
    emoji: "🦉"
    category: "domains"
    subcategory: "humanities"
    keywords: ["philosophy", "ethics", "epistemology", "history", "logic", "argumentation"]
    source: "wentor"
---

# Philosophy Research Guide

A skill for conducting rigorous philosophical research, from constructing arguments and analyzing texts to writing publishable philosophy papers. Covers major subfields, argumentation methods, and the distinctive methodology of philosophical inquiry.

## Philosophical Argumentation

### Argument Structure and Evaluation

Every philosophical argument can be reconstructed in standard form:

```
Premise 1: All knowledge requires justification. (epistemic principle)
Premise 2: Sensory experience alone cannot provide certainty. (empirical claim)
Premise 3: If knowledge requires certainty, then sensory experience
           is insufficient for knowledge. (conditional from P1, P2)
Conclusion: Therefore, knowledge requires something beyond sensory
            experience. (from P1, P2, P3 by modus ponens)
```

### Validity and Soundness Checks

```python
def evaluate_argument(premises: list[str], conclusion: str,
                       premises_true: list[bool],
                       valid: bool) -> dict:
    """
    Evaluate an argument's logical properties.

    An argument is:
    - Valid: if the conclusion follows necessarily from the premises
    - Sound: if it is valid AND all premises are true
    - Cogent (inductive): if premises make conclusion probable
    """
    all_true = all(premises_true)
    sound = valid and all_true

    return {
        'n_premises': len(premises),
        'valid': valid,
        'all_premises_true': all_true,
        'sound': sound,
        'diagnosis': (
            'Sound argument' if sound
            else 'Valid but unsound (false premise)' if valid
            else 'Invalid argument -- conclusion does not follow'
        )
    }
```

### Common Logical Fallacies

Identify and avoid these in philosophical writing:

| Fallacy | Structure | Example |
|---------|-----------|---------|
| Affirming the consequent | If P then Q; Q; therefore P | "If it rained, the street is wet. The street is wet. Therefore it rained." |
| Begging the question | Assuming the conclusion in a premise | "God exists because the Bible says so, and the Bible is true because it is God's word." |
| False dilemma | Presenting only two options when more exist | "Either we have free will or everything is determined." |
| Equivocation | Using a term with different meanings | "A bank is beside a river. I deposit money in a bank. Therefore I deposit money beside a river." |
| Straw man | Misrepresenting an opponent's position | Attacking a weakened version of the actual argument |

## Research Methods by Subfield

### Epistemology

Key research questions and methods:

- **Analysis of knowledge**: Examine Gettier-style counterexamples to JTB (justified true belief)
- **Thought experiments**: Construct carefully specified scenarios to test intuitions
- **Formal epistemology**: Apply Bayesian probability, decision theory, and logic

### Ethics and Applied Ethics

Systematic approach to ethical analysis:

```
Step 1: Identify the moral question clearly
Step 2: Gather relevant empirical facts
Step 3: Apply ethical frameworks:
  - Consequentialism: What outcomes does each option produce?
  - Deontology: What duties or rules apply?
  - Virtue ethics: What would a virtuous person do?
  - Care ethics: What relationships and responsibilities are involved?
Step 4: Identify conflicts between frameworks
Step 5: Construct a reasoned position addressing objections
Step 6: Consider implications and edge cases
```

### History of Philosophy

Hermeneutic methodology for textual interpretation:

1. **Close reading**: Analyze the primary text sentence by sentence
2. **Historical context**: Situate the text within its intellectual and social milieu
3. **Charitable interpretation**: Apply the principle of charity (interpret ambiguous passages in the strongest possible way)
4. **Systematic reconstruction**: Build a coherent account of the philosopher's position
5. **Critical evaluation**: Assess internal consistency and compare with rival interpretations

## Writing Philosophy Papers

### Paper Structure

A standard analytic philosophy paper follows this structure:

```
1. Introduction (10%)
   - State the thesis clearly in the first paragraph
   - Preview the argument structure

2. Background / Setup (15%)
   - Present the problem or debate
   - Define key terms precisely

3. Main Argument (40%)
   - Present the argument in numbered steps
   - Provide support for each premise

4. Objections and Replies (25%)
   - Consider the strongest objections
   - Provide substantive responses

5. Conclusion (10%)
   - Summarize without merely repeating
   - Note limitations and future directions
```

### Citation Practices

Philosophy primarily uses author-date citations and engages directly with the text. Quote passages when the exact wording matters for the argument. Always cite the most authoritative edition of historical texts (e.g., Bekker numbers for Aristotle, Adam and Tannery for Descartes).

## Key Databases

- PhilPapers (philpapers.org): the most comprehensive philosophy bibliography
- JSTOR: historical journal archives
- Stanford Encyclopedia of Philosophy (SEP): authoritative survey articles
- PhilArchive: open-access preprint repository for philosophy
