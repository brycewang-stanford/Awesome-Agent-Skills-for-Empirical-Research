<!--
  ╔══════════════════════════════════════════════════════════════╗
  ║  本文件为开源 Skill 原始文档，收录仅供学习与研究参考        ║
  ║  CoPaper.AI 收集整理 | https://copaper.ai                  ║
  ╚══════════════════════════════════════════════════════════════╝

  来源仓库: https://github.com/luwill/research-skills
  项目名称: research-skills
  开源协议: MIT License
  收录日期: 2026-04-02

  声明: 本文件版权归原作者所有。此处收录旨在为社会科学实证研究者
  提供 AI Agent Skills 的集中参考。如有侵权，请联系删除。
-->

# Academic Writing Style Guide

Based on Nature Reviews journal conventions and academic writing best practices.

---

## Core Principles

### 1. Prose-Based Writing (CRITICAL)

**Academic proposals must read as flowing, connected prose—not as bulleted lists or enumerated points.**

The hallmark of excellent academic writing is the ability to present complex ideas through coherent paragraphs with smooth transitions. Point-by-point enumeration (bullet points, numbered lists) should be used sparingly and only where truly necessary.

**When lists ARE appropriate:**
- Research questions/objectives (a focused set of 2-4 items)
- Timeline milestones (where tabular format genuinely aids clarity)
- Technical specifications requiring precise enumeration

**When to avoid lists:**
- Describing contributions (narrate them in context instead)
- Explaining methodology (use flowing prose with transitions)
- Presenting background information (integrate into paragraphs)
- Discussing implications (weave into coherent narrative)

**Transformation example:**

*Poor (point-by-point):*
> The main contributions include:
> - A novel segmentation algorithm
> - A multi-modal fusion framework
> - Clinical validation results

*Better (prose-based):*
> This research is expected to advance the field through several interconnected contributions. The development of a novel segmentation algorithm will enable automated plaque detection with accuracy surpassing current methods. Building on this foundation, a multi-modal fusion framework will integrate complementary imaging data to capture plaque characteristics inaccessible to any single modality. Finally, rigorous clinical validation will establish the prognostic value of these computational biomarkers for predicting cardiovascular events.

### 2. Precision Over Impression
- Say exactly what you mean
- Avoid vague language
- Define terms clearly
- Quantify when possible

### 3. Evidence-Based Claims
- Support assertions with citations
- Distinguish fact from interpretation
- Acknowledge uncertainty appropriately

### 4. Logical Flow
- Clear paragraph structure
- Explicit transitions
- Coherent argumentation

### 5. Reader-Centered
- Anticipate reader questions
- Provide necessary context
- Guide through complexity

---

## Hedging Language (学术谦逊表达)

### Why Hedging Matters
Academic writing requires appropriate epistemic humility. Hedging:
- Reflects genuine uncertainty in research
- Protects against overgeneralization
- Maintains scholarly credibility
- Invites scholarly dialogue

### Hedging Strategies

#### Modal Verbs
| Strength | Verbs | Example |
|----------|-------|---------|
| Strong | will, must | Rarely appropriate |
| Medium | would, should, can | "This approach can improve..." |
| Weak | may, might, could | "Results might indicate..." |

#### Hedging Verbs
```
Strong claim:  "X proves Y"
Hedged:        "X suggests/indicates/implies Y"
               "X appears to demonstrate Y"
               "X provides evidence for Y"
```

**Recommended hedging verbs:**
- suggest, indicate, imply
- appear, seem, tend
- propose, hypothesize, speculate

#### Hedging Adverbs
```
Strong:  "X is important"
Hedged:  "X is potentially/possibly/arguably important"
         "X may be particularly significant"
```

**Recommended adverbs:**
- possibly, potentially, perhaps
- apparently, seemingly
- generally, typically, often
- largely, mostly, primarily

#### Hedging Phrases
```
"It is possible that..."
"Evidence suggests that..."
"This finding indicates that..."
"The data appear to show..."
"One interpretation is that..."
"It could be argued that..."
```

### Hedging Examples by Section

**Introduction:**
```
Too strong:  "AI will transform healthcare."
Hedged:      "AI has the potential to transform healthcare."

Too strong:  "This gap must be addressed."
Hedged:      "This gap warrants further investigation."
```

**Methodology:**
```
Too strong:  "This method will produce accurate results."
Hedged:      "This method is expected to yield reliable results."

Too strong:  "We will prove the hypothesis."
Hedged:      "We aim to test the hypothesis."
```

**Results/Expected Outcomes:**
```
Too strong:  "The results will show..."
Hedged:      "The results are anticipated to reveal..."
             "We expect the findings to indicate..."

Too strong:  "This proves that..."
Hedged:      "This provides evidence that..."
             "This suggests that..."
```

**Significance:**
```
Too strong:  "This research will revolutionize..."
Hedged:      "This research has the potential to advance..."
             "This work may contribute to..."

Too strong:  "The findings will definitely impact..."
Hedged:      "The findings could have implications for..."
```

### Chinese Hedging (中文学术谦逊表达)

| 过强表达 | 适当表达 |
|----------|----------|
| 必将证明 | 有望表明、可能揭示 |
| 肯定会 | 预期将、有可能 |
| 彻底解决 | 有助于解决、为...提供新思路 |
| 完全正确 | 基本合理、大体上 |
| 已经证实 | 研究表明、证据显示 |

**常用谦逊表达:**
- 初步探讨、尝试分析
- 可能存在、似乎表明
- 在一定程度上、从某种意义上说
- 有待进一步研究、需要更多证据支持

---

## Sentence Structure

### Topic Sentence First
Every paragraph should begin with a clear topic sentence stating the main point.

```
Good:
"Recent advances in transformer architectures have significantly improved
natural language processing capabilities. [Evidence 1]. [Evidence 2].
[Synthesis]."

Avoid:
"[Evidence 1]. [Evidence 2]. Therefore, recent advances in transformer
architectures have significantly improved NLP capabilities."
```

### Sentence Templates by Function

#### Introducing Background/Context
```
English:
- "Over the past decade, [X] has emerged as a critical area of research in [field]."
- "Recent advances in [X] have opened new possibilities for [application]."
- "[Field] has witnessed remarkable progress in [area], driven by [factors]."
- "The importance of [X] has been increasingly recognized in [context]."

中文:
- "近年来，[X]已成为[领域]研究的热点问题。"
- "随着[X]的快速发展，[Y]日益受到学界关注。"
- "[领域]在[方面]取得了显著进展，主要体现在[具体表现]。"
```

#### Identifying Problems/Gaps
```
English:
- "However, [X] remains poorly understood."
- "Despite these advances, significant challenges persist in [area]."
- "A critical gap exists in our understanding of [phenomenon]."
- "Current approaches fail to adequately address [issue]."
- "The relationship between [A] and [B] has not been systematically examined."

中文:
- "然而，[X]仍缺乏系统深入的研究。"
- "尽管如此，[领域]仍面临[问题]的挑战。"
- "目前研究对[问题]的关注相对不足。"
- "[A]与[B]之间的关系尚未得到充分探讨。"
```

#### Stating Objectives
```
English:
- "This research aims to address [X] by [approach]."
- "The primary objective of this study is to [verb] [what]."
- "This proposal seeks to investigate [question] through [method]."
- "Specifically, this study will [objective 1], [objective 2], and [objective 3]."

中文:
- "本研究旨在通过[方法]探讨[问题]。"
- "本文的主要目标是[动词][内容]。"
- "具体而言，本研究将：第一，...；第二，...；第三，..."
```

#### Justifying Methodology
```
English:
- "Building on previous work, this study proposes to [approach]."
- "This approach was selected because [justification]."
- "[Method] offers several advantages for studying [phenomenon]."
- "[Method] is particularly suited to [research question] because [reasons]."

中文:
- "在前人研究基础上，本研究拟采用[方法]。"
- "选择该方法的原因在于：[理由]。"
- "[方法]对于研究[现象]具有以下优势：..."
```

#### Describing Expected Contributions
```
English:
- "This work has the potential to advance [field/understanding]."
- "The findings may contribute to [theoretical/practical area]."
- "This research could provide insights into [phenomenon]."
- "The results are expected to have implications for [application]."

中文:
- "本研究有望推进[领域]的发展。"
- "研究结果可能为[理论/实践]提供新的视角。"
- "本研究预期将为[问题]的理解提供新的启示。"
```

### Sentence Variety

**Vary sentence length:**
- Mix short (10-15 words) and longer (20-30 words) sentences
- Use short sentences for key points
- Use longer sentences for complex relationships

**Vary sentence structure:**
- Simple: Subject-Verb-Object
- Compound: Clause + Conjunction + Clause
- Complex: Main clause + Subordinate clause
- Periodic: Build to main point at end

---

## Transitions and Connectors

### Addition
- Moreover, Furthermore, In addition, Additionally
- Also, Besides, Equally important
- 此外，另外，同时，与此同时

### Contrast
- However, Nevertheless, Nonetheless
- Conversely, On the other hand, In contrast
- Yet, Still, Although, While
- 然而，但是，尽管如此，相反

### Causation
- Therefore, Consequently, As a result, Thus
- Hence, Accordingly, For this reason
- 因此，由此可见，正因如此

### Emphasis
- Importantly, Notably, Significantly
- Of particular note, It is worth noting
- Indeed, In fact, Particularly
- 值得注意的是，尤其重要的是，特别是

### Sequence
- First, Second, Third, Finally
- Initially, Subsequently, Eventually
- Following this, Prior to, After
- 首先，其次，最后，随后

### Example
- For example, For instance, Specifically
- Such as, Including, Namely
- To illustrate, As demonstrated by
- 例如，具体而言，以...为例

### Summary
- In summary, To summarize, In conclusion
- Overall, In brief, To conclude
- 综上所述，总之，概言之

### Using Transitions Effectively

**Start of paragraph:**
```
"Moreover, recent studies have shown..."
"However, this approach has limitations..."
"In addition to these theoretical contributions..."
```

**Mid-paragraph:**
```
"This finding is particularly important because..."
"Consequently, researchers have begun to..."
```

**Between paragraphs:**
```
"Building on these observations, the next section..."
"Having established the theoretical framework, we now turn to..."
```

---

## Paragraph Structure

### The PEEL Structure
```
P - Point (topic sentence)
E - Evidence (supporting data/citations)
E - Explanation (analysis of evidence)
L - Link (connection to next idea or main argument)
```

### Example Paragraph

```
[Point] Machine learning approaches have shown considerable promise for
medical image analysis. [Evidence] Recent studies have demonstrated that
convolutional neural networks can achieve diagnostic accuracy comparable
to expert radiologists in detecting certain conditions (Smith et al., 2023;
Jones, 2024). [Evidence] Furthermore, these systems have been successfully
deployed in clinical settings, with one large-scale trial reporting a 15%
reduction in diagnostic errors (Chen et al., 2024). [Explanation] These
advances suggest that AI-assisted diagnosis could address the growing
shortage of medical imaging specialists while maintaining high standards
of care. [Link] However, significant challenges remain in ensuring the
generalizability of these systems across diverse patient populations.
```

### Paragraph Length
- Academic writing: 4-8 sentences per paragraph
- Aim for 100-200 words per paragraph
- One main idea per paragraph

### Paragraph Cohesion Techniques

**Repetition of key terms:**
```
"The study examined neural network architectures. These architectures..."
```

**Pronouns:**
```
"Researchers proposed a new framework. They demonstrated that it..."
```

**Synonyms and related terms:**
```
"...machine learning algorithms. These computational approaches..."
```

**Transitional phrases:**
```
"Building on this foundation... In light of these findings..."
```

---

## Citation Integration

### Citation Styles in Text

**Integral citations** (author as subject):
```
"Smith et al. (2023) demonstrated that..."
"According to Jones (2024), the relationship between..."
"As Chen and colleagues (2024) argue, ..."
```

**Non-integral citations** (parenthetical):
```
"Recent studies have shown significant improvements (Smith et al., 2023)."
"This relationship has been well-documented (Jones, 2024; Chen, 2024)."
```

### Reporting Verbs by Strength

| Strength | Verbs | Use When |
|----------|-------|----------|
| Strong | demonstrate, establish, prove | Well-supported findings |
| Medium | show, indicate, suggest, reveal | Typical research findings |
| Weak | propose, speculate, claim, argue | Contested or preliminary |
| Neutral | report, describe, state, note | Describing without evaluation |

### Citation Density Guidelines
- Introduction: Moderate (support key claims)
- Literature Review: High (comprehensive coverage)
- Methodology: Low-Moderate (cite established methods)
- Discussion: Moderate (compare with prior work)

### Synthesizing Multiple Sources

**Agreement:**
```
"Multiple studies have confirmed this relationship (Smith, 2022; Jones,
2023; Chen, 2024)."

"Researchers consistently report that... (Author1, Year; Author2, Year)."
```

**Disagreement:**
```
"While Smith (2022) argues that X, Jones (2023) presents evidence for Y."

"The evidence is mixed, with some studies supporting X (Author1, Year)
and others finding Y (Author2, Year)."
```

**Building on prior work:**
```
"Extending the work of Smith (2022), this study..."

"Building on Jones's (2023) framework, we propose..."
```

---

## Academic Vocabulary

### Words to Avoid

| Avoid | Use Instead |
|-------|-------------|
| a lot of | numerous, considerable, substantial |
| big | significant, substantial, major |
| get | obtain, acquire, achieve |
| thing | factor, element, aspect, component |
| good | effective, beneficial, advantageous |
| bad | detrimental, adverse, problematic |
| very | highly, particularly, considerably |
| really | significantly, substantially |
| kind of / sort of | somewhat, to some extent |
| basically | fundamentally, essentially |

### Precision in Word Choice

**Quantity:**
```
Vague:    "many studies"
Precise:  "numerous studies" / "several studies" / "a substantial body of research"
```

**Degree:**
```
Vague:    "very important"
Precise:  "crucial" / "essential" / "fundamental"
```

**Time:**
```
Vague:    "recently"
Precise:  "in the past five years" / "since 2020"
```

### Academic Verb Choices

| Purpose | Strong Verbs |
|---------|--------------|
| Showing | demonstrate, illustrate, reveal |
| Arguing | contend, assert, maintain |
| Analyzing | examine, investigate, assess |
| Comparing | contrast, differentiate, distinguish |
| Explaining | elucidate, clarify, account for |
| Increasing | enhance, augment, amplify |
| Decreasing | diminish, reduce, attenuate |

---

## Common Errors to Avoid

### Informal Language
```
Avoid:    "Scientists have been looking into this problem."
Better:   "Researchers have investigated this problem."

Avoid:    "This method is way better than the old one."
Better:   "This method demonstrates significant improvements over previous approaches."
```

### Absolute Claims
```
Avoid:    "This proves that X causes Y."
Better:   "This provides evidence that X may influence Y."

Avoid:    "It is obvious that..."
Better:   "Evidence suggests that..."
```

### Colloquialisms
```
Avoid:    "at the end of the day" / "in a nutshell"
Better:   "ultimately" / "in summary"

Avoid:    "a game-changer"
Better:   "a significant advancement"
```

### Redundancy
```
Avoid:    "past history" / "future plans" / "basic fundamentals"
Better:   "history" / "plans" / "fundamentals"

Avoid:    "in order to"
Better:   "to"
```

### Anthropomorphism (attributing human qualities to non-human things)
```
Avoid:    "The data wants to show..."
Better:   "The data indicate..."

Avoid:    "This study tries to..."
Better:   "This study aims to..."
```

### First Person Overuse
```
Avoid:    "I think this is important because..."
Better:   "This is significant because..."

Acceptable: "We propose..." / "Our study..."
```

---

## Writing Checklist

### Before Writing
- [ ] Research question clearly defined
- [ ] Key literature identified
- [ ] Outline prepared
- [ ] Target audience understood

### During Writing
- [ ] Topic sentence for each paragraph
- [ ] Evidence supports all claims
- [ ] Hedging used appropriately
- [ ] Transitions connect ideas
- [ ] Citations integrated smoothly

### After Writing
- [ ] Formal academic tone throughout
- [ ] No colloquialisms or informal language
- [ ] Appropriate hedging (not over-claiming)
- [ ] Clear logical flow
- [ ] Consistent citation format
- [ ] Abbreviations defined on first use
- [ ] No grammatical errors
- [ ] Word count within target range
- [ ] **Prose-based writing** (minimal bullet points)
- [ ] **Figure suggestions included** (3-5 for typical proposal)
- [ ] **No appendix sections**

---

## Figure Suggestions

### Purpose of Figures in Proposals

Figures significantly enhance research proposals by:
- Communicating complex ideas visually
- Breaking up dense text for improved readability
- Demonstrating the applicant's communication skills
- Providing concrete visualization of methodology

### Figure Suggestion Format

Include figure suggestions at appropriate locations using this format:

```markdown
> **[Figure 1 Suggestion]** *Title: Overview of the proposed research framework*
>
> Content: A flowchart illustrating the three-phase research design, showing
> data flow from imaging modalities (CCTA, IVUS, OCT) through AI processing
> modules to clinical outcome predictions. Include distinct visual elements
> for each phase with connecting arrows indicating data flow.
>
> Recommended style: Clean vector graphics using a consistent color palette
> (e.g., blues for data inputs, greens for processing, oranges for outputs).
> Consider using icons for different imaging modalities.
```

### Recommended Figures by Section

| Section | Figure Type | Example |
|---------|-------------|---------|
| **Introduction** | Conceptual diagram | Research scope and positioning within the field |
| **Literature Review** | Timeline or taxonomy | Evolution of methods; Classification of approaches |
| **Methodology** | Flowchart/Architecture | Research framework; Network architecture; Data pipeline |
| **Timeline** | Gantt chart | Research phases with milestones and dependencies |
| **Significance** | Impact diagram | Connections between contributions and beneficiaries |

### Figure Suggestion Principles

1. **Strategic placement**: 3-5 figures for a 3,000-word proposal
2. **No figure in Abstract**: Abstract should stand alone without visual elements
3. **Self-explanatory**: Each figure should convey key information clearly
4. **Consistent style**: Unified visual language throughout
5. **Professional tools**: Suggest appropriate tools (Illustrator, draw.io, BioRender)
6. **Accessibility**: Colorblind-friendly palettes, sufficient contrast

### Example Figure Suggestions

**For Methodology Section:**
> **[Figure 2 Suggestion]** *Title: Deep learning architecture for multimodal plaque analysis*
>
> Content: A schematic showing the neural network architecture with three parallel
> encoder branches (one for each imaging modality), a cross-modal attention fusion
> module in the center, and multiple output heads for segmentation, classification,
> and risk prediction tasks.
>
> Style: Technical diagram with layer representations, dimension annotations,
> and data flow arrows. Use consistent shapes for similar operations.

**For Timeline Section:**
> **[Figure 3 Suggestion]** *Title: Research timeline and milestones*
>
> Content: Gantt chart showing four research phases across 48 months, with
> overlapping periods for parallel activities. Include diamond markers for
> key milestones (model completion, validation study, thesis submission).
>
> Style: Horizontal bar chart with color-coded phases, clear date markers,
> and milestone annotations.
