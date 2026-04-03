---
name: academic-writing-refiner
description: "Checklist-driven academic English polishing and Chinglish correction"
metadata:
  openclaw:
    emoji: "🔍"
    category: "writing"
    subcategory: "polish"
    keywords: ["academic English grammar check", "readability improvement", "academic writing style", "Chinglish correction"]
    source: "https://github.com/SYSUSELab/academic-writing-guide"
---

# Academic Writing Refiner

## Overview

Academic papers are judged not only on their scientific merit but also on the quality of their English. Grammatical errors, awkward phrasing, and non-native patterns (commonly called "Chinglish" when originating from Chinese-English interference) can distract reviewers and undermine credibility.

This skill provides a systematic checklist for identifying and correcting common academic English issues. It draws from the academic-writing-guide repository (327+ stars) maintained by SYSUSELab, which catalogs frequent mistakes observed in student and researcher manuscripts across STEM disciplines.

The approach is checklist-driven: rather than relying solely on automated tools, researchers learn to recognize error patterns and self-edit effectively. This skill is especially useful for non-native English speakers preparing manuscripts for international journals and conferences.

## Common Error Categories

### Grammar and Syntax Errors

| Error Type | Example (Wrong) | Correction |
|-----------|-----------------|------------|
| Article misuse | "We propose a novel the method" | "We propose a novel method" |
| Subject-verb disagreement | "The results shows that..." | "The results show that..." |
| Tense inconsistency | "We train the model and evaluated it" | "We trained the model and evaluated it" |
| Dangling modifier | "Using gradient descent, the loss decreased" | "Using gradient descent, we decreased the loss" |
| Run-on sentence | "The model converges fast it achieves high accuracy" | "The model converges fast and achieves high accuracy" |

### Chinglish Patterns

These are interference patterns common when translating from Chinese thought patterns into English:

1. **Topic-comment structure.** Chinese allows "As for X, Y does Z." English prefers "Y does Z to X."
   - Wrong: "As for the dataset, we use ImageNet."
   - Better: "We use ImageNet as our dataset."

2. **Redundant verbs.** Chinese often uses verb-verb compounds that become redundant in English.
   - Wrong: "We can be able to achieve..."
   - Better: "We can achieve..."

3. **Missing determiners.** Chinese has no articles, leading to dropped "the/a/an."
   - Wrong: "Model achieves state-of-art result."
   - Better: "The model achieves a state-of-the-art result."

4. **Overuse of "respectively."**
   - Wrong: "The accuracy and F1 are 95% and 0.93 respectively."
   - Better: "The accuracy is 95% and the F1 score is 0.93."

5. **"With the development of..."** This opening is overused to the point of cliche.
   - Better: Lead with the specific problem or finding.

## Self-Editing Checklist

Apply this checklist before submitting any manuscript:

### Pass 1: Structure and Flow

- [ ] Each paragraph has a clear topic sentence.
- [ ] Transitions connect paragraphs logically (however, therefore, in contrast).
- [ ] No paragraph exceeds 200 words.
- [ ] Figures and tables are referenced in order.

### Pass 2: Grammar and Mechanics

- [ ] All verbs agree with their subjects.
- [ ] Tense is consistent within each section (past for Methods/Results, present for general truths).
- [ ] Every acronym is defined on first use.
- [ ] No comma splices or run-on sentences.
- [ ] Articles (a, an, the) are used correctly.

### Pass 3: Style and Conciseness

- [ ] Remove "very," "really," "quite," "basically" unless essential.
- [ ] Replace "in order to" with "to."
- [ ] Replace "a large number of" with "many" or give the exact count.
- [ ] Convert passive voice to active where possible.
- [ ] Eliminate "it is well known that" and similar filler phrases.

### Pass 4: Technical Accuracy

- [ ] All numbers have units.
- [ ] Table column headers are unambiguous.
- [ ] Equations are numbered and referenced.
- [ ] Statistical claims include confidence intervals or p-values.

## Automated Polishing Tools

While manual review is irreplaceable, these tools serve as a useful second pass:

```bash
# LanguageTool CLI for grammar checking
java -jar languagetool-commandline.jar -l en-US paper.tex

# Writefull for academic-specific suggestions (VS Code extension)
# Install from VS Code marketplace: "Writefull for LaTeX"

# textlint for rule-based prose linting
npm install -g textlint textlint-rule-no-dead-link textlint-rule-write-good
textlint paper.md
```

### Tool Comparison

| Tool | Type | Academic Focus | Free Tier |
|------|------|---------------|-----------|
| Grammarly | Cloud | General + academic | Yes (limited) |
| Writefull | Plugin | High (trained on papers) | Yes |
| LanguageTool | Local/Cloud | General | Yes (full) |
| textlint | CLI | Configurable rules | Yes (open source) |
| Trinka | Cloud | High (academic-specific) | Yes (limited) |

## Sentence-Level Revision Examples

### Before and After

**Before:** "In recent years, with the rapid development of deep learning, more and more researchers have paid attention to the problem of image classification, which is a very important task in computer vision."

**After:** "Image classification is a fundamental task in computer vision. Recent advances in deep learning have renewed interest in this problem, with convolutional and transformer architectures achieving human-level accuracy on standard benchmarks."

**Before:** "We can observe from Table 1 that our method can achieve better performance than baseline methods in terms of all evaluation metrics."

**After:** "Our method outperforms all baselines across every metric (Table 1)."

## Best Practices

- **Read published papers in your target venue.** Absorb the register and conventions of journals like Nature, IEEE TPAMI, or ACL.
- **Have a native speaker review critical sections.** At minimum, ask someone to read the Abstract and Introduction.
- **Use consistent terminology.** If you call it "feature extraction" in Section 2, do not switch to "representation learning" in Section 4 unless you define the distinction.
- **Limit sentences to 25 words on average.** Long sentences are harder to parse, especially for non-native readers.
- **Revise in separate passes.** Do not try to fix grammar, structure, and style simultaneously.

## References

- [academic-writing-guide](https://github.com/SYSUSELab/academic-writing-guide) -- Writing checklist and tutorials (327+ stars)
- [Common Errors in Technical Writing](https://www.cs.columbia.edu/~hgs/etc/writing-bugs.html) -- Henning Schulzrinne, Columbia University
- [Writefull](https://writefull.com/) -- AI writing assistant trained on published papers
- [LanguageTool](https://languagetool.org/) -- Open-source grammar checker
