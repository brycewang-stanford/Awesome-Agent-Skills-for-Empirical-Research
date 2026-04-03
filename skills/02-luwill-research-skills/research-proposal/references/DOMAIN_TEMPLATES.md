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

# Domain-Specific Templates

Guidance for adapting research proposals to different academic domains.

---

## Overview: Domain Differences

| Dimension | STEM | Humanities | Social Sciences |
|-----------|------|------------|-----------------|
| **Length** | Shorter (2,000-3,000) | Longer (3,000-10,000) | Medium (2,500-4,000) |
| **Focus** | Methodology, experiments | Theory, interpretation | Methods + theory |
| **Hypothesis** | Explicit, testable | Research questions | Both used |
| **Literature** | Recent (5 years) | Broader historical | Mix |
| **Citations** | APA | MLA/Chicago | APA/Chicago |
| **Voice** | Passive preferred | Active acceptable | Mixed |

---

## STEM Domain (Science, Technology, Engineering, Mathematics)

### Structural Emphasis

```
STEM Proposal Structure (~2,500 words)

Abstract                    150-200 words   (6%)
Introduction               400-500 words   (18%)
  - Background/Motivation  150 words
  - Problem Statement      150 words
  - Objectives/Hypotheses  100 words
Literature Review          400-500 words   (18%)
  - State of the Art       300 words
  - Research Gap           200 words
Methodology                600-800 words   (28%)    ← HEAVY EMPHASIS
  - Research Design        150 words
  - Materials/Equipment    150 words
  - Experimental Protocol  200 words
  - Data Analysis          200 words
  - Validation             100 words
Timeline                   200 words       (8%)
Expected Outcomes          300 words       (12%)
  - Scientific Contribution 150 words
  - Publications Plan       100 words
  - Potential Applications  50 words
References                 30-50 citations
```

### Key Characteristics

**Hypothesis-Driven**
- State clear, testable hypotheses
- Define variables (independent, dependent, controlled)
- Specify expected outcomes

```markdown
**Hypothesis 1:** [Independent variable] will [effect] [dependent variable]
when [conditions].

**Hypothesis 2:** The proposed [method] will achieve [metric] performance
compared to [baseline].
```

**Technical Precision**
- Exact specifications for equipment/software
- Detailed protocols with parameters
- Quantifiable success metrics

**Preliminary Results**
- If available, include pilot study data
- Demonstrate feasibility
- Show you have necessary skills

### Methodology Section Template (STEM)

```markdown
## 3. Methodology

### 3.1 Research Design

This research employs a [quantitative/experimental/computational] approach
to investigate [research questions]. The study comprises [N] phases:
[Phase 1], [Phase 2], and [Phase 3].

### 3.2 Materials and Equipment

The following resources are required:
- **Hardware**: [specific equipment, models, specifications]
- **Software**: [programs, versions, licenses]
- **Materials**: [reagents, samples, datasets]
- **Facilities**: [lab access, computing resources]

### 3.3 Experimental Protocol

**Phase 1: [Name]**
1. [Step 1 with parameters]
2. [Step 2 with parameters]
3. [Expected output]

**Phase 2: [Name]**
[Similar detailed steps]

### 3.4 Data Analysis

Data will be analyzed using [software/method]. Specifically:
- [Analysis 1]: [technique] to measure [metric]
- [Analysis 2]: [statistical test] to evaluate [hypothesis]

Statistical significance will be set at p < 0.05.

### 3.5 Validation

To ensure validity:
- [Validation method 1]
- [Validation method 2]
- Comparison with [benchmark/baseline]
```

### STEM-Specific Language

**Technical verbs:**
- analyze, characterize, synthesize, optimize
- validate, calibrate, quantify, measure
- implement, develop, deploy, integrate

**Precision phrases:**
- "with a precision of ±X%"
- "under controlled conditions of [parameters]"
- "achieving [metric] > [threshold]"
- "statistically significant at p < 0.05"

---

## Humanities Domain (History, Philosophy, Literature, Languages, Arts)

### Structural Emphasis

```
Humanities Proposal Structure (~4,000 words)

Abstract                    250-300 words   (7%)
Introduction               600-800 words   (18%)
  - Context/Significance   300 words
  - Central Argument       200 words
  - Research Questions     200 words
Literature Review          1000-1500 words (30%)    ← HEAVY EMPHASIS
  - Theoretical Framework  400 words
  - Historiography/Field   600 words
  - Positioning            300 words
Methodology                400-600 words   (12%)
  - Sources/Archives       200 words
  - Analytical Approach    200 words
  - Interpretive Framework 200 words
Chapter Outline            400-500 words   (12%)    ← UNIQUE TO HUMANITIES
Timeline                   200-300 words   (6%)
Significance               400-500 words   (12%)
References                 50-100 citations
```

### Key Characteristics

**Argument-Driven**
- Central thesis or argument
- Research questions, not hypotheses
- Interpretive rather than predictive

```markdown
**Central Argument:**
This dissertation argues that [thesis statement]. By examining [sources/texts],
this research demonstrates how [phenomenon] reveals [insight] about [broader
significance].

**Research Questions:**
1. How did [historical actors/texts] [action/represent] [phenomenon]?
2. What [factors/discourses] shaped [development/interpretation]?
3. In what ways does [case study] illuminate [broader theoretical issue]?
```

**Theoretical Sophistication**
- Engage with major theorists
- Position within intellectual traditions
- Critical analysis of theory itself

**Source-Based**
- Primary sources (archives, texts, artifacts)
- Language requirements
- Access and travel considerations

### Literature Review Template (Humanities)

```markdown
## 2. Literature Review

### 2.1 Theoretical Framework

This research draws on [theoretical tradition] as articulated by [key
theorists]. [Theorist A]'s concept of [concept] provides a framework for
understanding [aspect of research]. However, [Theorist B] offers a
complementary perspective, arguing that [alternative view].

Building on these foundations, this study employs [specific theoretical
lens] to analyze [research focus]. This approach is particularly suited
to [justification] because [reasons].

### 2.2 Historiography / State of the Field

Scholarly attention to [topic] has evolved considerably over the past
[timeframe]. Early studies, such as [Author (Year)], focused primarily
on [aspect], establishing [finding/interpretation].

The field underwent significant transformation with [Author (Year)]'s
influential work, which challenged [previous assumption] by demonstrating
[new insight]. Subsequent scholars have built on this foundation,
exploring [development 1], [development 2], and [development 3].

More recently, scholars have turned to [new approach/topic]. [Author
(Year)] examines [specific focus], while [Author (Year)] investigates
[related area]. These studies reveal [emerging themes/debates].

### 2.3 Research Gap and Positioning

Despite this rich body of scholarship, significant questions remain
unexplored. First, [gap 1]. Second, [gap 2]. Third, [gap 3].

This dissertation addresses these gaps by [approach]. Unlike previous
studies that [limitation], this research [differentiation]. By [method],
this study offers new insights into [contribution].
```

### Chapter Outline (Unique to Humanities)

```markdown
## Provisional Chapter Outline

**Chapter 1: Introduction**
Introduces the central argument, contextualizes the study, and outlines
the dissertation structure.

**Chapter 2: [Thematic Title]**
Examines [topic/period/text] to establish [foundational argument].
Primary sources: [list key sources]

**Chapter 3: [Thematic Title]**
Analyzes [topic/period/text] to demonstrate [developing argument].
Primary sources: [list key sources]

**Chapter 4: [Thematic Title]**
Investigates [topic/period/text] to explore [complicating factors].
Primary sources: [list key sources]

**Chapter 5: Conclusion**
Synthesizes findings, articulates contributions, and suggests directions
for future research.
```

### Humanities-Specific Language

**Interpretive verbs:**
- argue, contend, posit, suggest
- examine, analyze, interrogate, explore
- illuminate, reveal, demonstrate, trace

**Analytical phrases:**
- "close reading of [text] reveals..."
- "situating [phenomenon] within [context] allows us to see..."
- "this analysis complicates the prevailing narrative by..."
- "reading [source] against [context] demonstrates..."

---

## Social Sciences Domain (Sociology, Psychology, Economics, Political Science)

### Structural Emphasis

```
Social Sciences Proposal Structure (~3,000 words)

Abstract                    200-250 words   (7%)
Introduction               500-600 words   (18%)
  - Background             200 words
  - Problem Statement      200 words
  - Research Questions     150 words
Literature Review          600-800 words   (22%)
  - Theoretical Framework  250 words
  - Empirical Review       350 words
  - Research Gap           200 words
Methodology                600-800 words   (25%)    ← BALANCED EMPHASIS
  - Research Design        150 words
  - Sampling/Participants  150 words
  - Data Collection        200 words
  - Data Analysis          200 words
  - Ethics                 100 words
Timeline                   200-250 words   (7%)
Significance               300-400 words   (12%)
References                 40-60 citations
```

### Key Characteristics

**Question-Driven with Theoretical Grounding**
- Clear research questions
- Hypotheses when appropriate (quantitative)
- Theory guides but doesn't dominate

```markdown
**Research Questions:**
1. What is the relationship between [variable A] and [variable B] among
   [population]?
2. How do [participants] experience/perceive [phenomenon]?
3. To what extent does [factor] mediate/moderate the relationship between
   [X] and [Y]?

**Hypotheses (if quantitative):**
H1: [Variable A] is positively/negatively associated with [Variable B].
H2: The relationship between [X] and [Y] is moderated by [Z].
```

**Mixed Methods Common**
- Often combines quantitative and qualitative
- Sequential or concurrent designs
- Triangulation valued

**Ethical Emphasis**
- Human subjects considerations
- IRB/ethics approval process
- Informed consent, confidentiality

### Methodology Template (Social Sciences)

```markdown
## 3. Methodology

### 3.1 Research Design

This study employs a [quantitative/qualitative/mixed methods] design.
[If mixed: The study follows a [sequential/concurrent] [explanatory/
exploratory] design, beginning with [phase 1] followed by [phase 2].]

The [design type] approach is appropriate because [justification based
on research questions].

### 3.2 Participants and Sampling

**Population:** [Define target population]

**Sample:** [N] participants will be recruited using [sampling strategy].
Inclusion criteria: [list]. Exclusion criteria: [list].

**Sample size justification:** Based on [power analysis/saturation
principle/similar studies], [N] participants are required to [detect
effect/achieve saturation].

### 3.3 Data Collection

**Quantitative:** [Surveys/experiments/secondary data]
- Instrument: [name/description]
- Variables measured: [list with operationalization]
- Procedure: [step-by-step process]

**Qualitative:** [Interviews/focus groups/observation]
- Protocol: [semi-structured/structured, duration]
- Topics covered: [list]
- Recording: [audio/video, transcription process]

### 3.4 Data Analysis

**Quantitative analysis:**
- Descriptive statistics for [variables]
- [Statistical test] to examine [hypothesis 1]
- [Statistical test] to examine [hypothesis 2]
- Software: [SPSS/R/Stata]

**Qualitative analysis:**
- [Thematic/content/discourse] analysis
- Coding approach: [inductive/deductive/hybrid]
- Software: [NVivo/Atlas.ti/manual]

### 3.5 Ethical Considerations

This research will be conducted in accordance with [ethical guidelines].
IRB/Ethics approval will be obtained from [institution].

Key considerations:
- **Informed consent:** [process]
- **Confidentiality:** [data storage, anonymization]
- **Potential risks:** [identified risks and mitigation]
- **Vulnerable populations:** [if applicable, special protections]
```

### Social Sciences-Specific Language

**Research verbs:**
- investigate, examine, explore, assess
- compare, evaluate, measure, test
- understand, interpret, explain, predict

**Methodological phrases:**
- "using a [design] approach"
- "drawing on a [sampling] sample of [N] participants"
- "employing [analysis method] to identify..."
- "controlling for [confounding variables]"

---

## Citation Style Quick Reference

### APA (7th Edition) - STEM, Social Sciences

**Journal article:**
```
Author, A. A., & Author, B. B. (Year). Title of article. Journal Name,
Volume(Issue), pages. https://doi.org/xxxxx
```

**Book:**
```
Author, A. A. (Year). Title of work: Subtitle. Publisher.
```

**In-text:**
- (Author, Year) or Author (Year)
- (Author et al., Year) for 3+ authors

### MLA (9th Edition) - Humanities (Literature, Languages)

**Journal article:**
```
Author Last, First. "Article Title." Journal Name, vol. #, no. #, Year,
pp. #-#.
```

**Book:**
```
Author Last, First. Title of Book. Publisher, Year.
```

**In-text:**
- (Author page) or Author argues "quote" (page)

### Chicago (17th Edition) - History, some Humanities

**Notes-Bibliography (Humanities):**
```
Footnote: Author First Last, Title of Book (Place: Publisher, Year), page.
Bibliography: Author Last, First. Title of Book. Place: Publisher, Year.
```

**Author-Date (Sciences):**
```
(Author Year, page)
Author, First. Year. Title. Place: Publisher.
```

---

## Language Output Considerations

### English Proposals

- Maintain consistent British or American English
- Formal academic register
- Active voice acceptable, passive common in methods
- "We" for multi-author, "This study" for distance

### Chinese Proposals (中文)

**学术语体特征:**
- 使用书面语，避免口语化表达
- 适当使用四字成语和学术术语
- 保持客观语气，避免主观判断词
- 使用"本研究"而非"我"

**常用学术表达:**

| 功能 | 中文表达 |
|------|----------|
| 引出背景 | 随着...的发展，...日益受到关注 |
| 指出问题 | 然而，...仍存在以下问题 |
| 陈述目标 | 本研究旨在...；本文拟探讨... |
| 方法说明 | 采用...方法，对...进行分析 |
| 预期贡献 | 研究结果将有助于...；有望为...提供参考 |

**参考文献格式 (GB/T 7714-2015):**
```
期刊: 作者. 题名[J]. 刊名, 年, 卷(期): 起止页码.
专著: 作者. 书名[M]. 出版地: 出版者, 出版年.
```

---

## Domain-Specific Checklist

### STEM Checklist
- [ ] Hypotheses are specific and testable
- [ ] Variables clearly defined and operationalized
- [ ] Methods section includes specific parameters
- [ ] Equipment/software versions specified
- [ ] Validation approach described
- [ ] Preliminary data included (if available)
- [ ] Realistic within lab capabilities

### Humanities Checklist
- [ ] Central argument clearly stated
- [ ] Theoretical framework articulated
- [ ] Engagement with key scholars demonstrated
- [ ] Primary sources identified and accessible
- [ ] Chapter outline provided
- [ ] Language requirements addressed
- [ ] Archive/field access confirmed

### Social Sciences Checklist
- [ ] Research questions linked to theory
- [ ] Sampling strategy justified
- [ ] Instruments described or referenced
- [ ] Analysis appropriate for question type
- [ ] Ethics considerations addressed
- [ ] Limitations acknowledged
- [ ] Practical significance articulated
