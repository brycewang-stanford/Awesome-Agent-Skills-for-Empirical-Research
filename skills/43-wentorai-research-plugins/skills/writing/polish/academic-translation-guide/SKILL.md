---
name: academic-translation-guide
description: "Academic translation, post-editing, and Chinglish correction guide"
metadata:
  openclaw:
    emoji: "🌐"
    category: "writing"
    subcategory: "polish"
    keywords: ["academic translation", "machine translation", "post-editing", "Chinglish correction"]
    source: "wentor-research-plugins"
---

# Academic Translation Guide

Translate and polish research manuscripts between languages with a focus on academic register, domain-specific terminology, and common pitfalls for Chinese-English academic writing.

## Machine Translation for Academic Texts

### Recommended MT Engines for Academic Use

| Engine | Strengths | Weaknesses | Best For |
|--------|-----------|------------|----------|
| DeepL | Excellent European languages, natural output | Limited Asian language pairs | EU language papers |
| Google Translate | Broadest language coverage | Less polished academic register | Quick drafts, rare languages |
| ChatGPT / Claude | Context-aware, follows style instructions | May hallucinate terminology | Post-editing, term-aware translation |
| Tencent TranSmart | Strong Chinese-English technical | Limited other languages | CN-EN STEM papers |
| Baidu Translate | Strong Chinese-English | Less natural English | CN-EN drafts |

### MT Post-Editing Workflow

1. **Pre-process**: Clean the source text. Remove figure captions, table contents, and equations (translate these separately).
2. **Translate**: Run through your preferred MT engine.
3. **Light post-editing (PE)**: Fix factual errors, terminology, and grammar without rewriting.
4. **Full post-editing**: Rewrite for fluency, cohesion, and academic register.
5. **Domain review**: Have a subject-matter expert verify technical terminology.

```
# Example: Light post-editing checklist
- [ ] Technical terms are correct and consistent
- [ ] Numbers, units, and chemical formulas are accurate
- [ ] Negation is preserved (a common MT error)
- [ ] Subject-verb agreement is correct
- [ ] Hedging language is appropriate ("may" vs "will")
- [ ] Citations and references are intact
```

## Common Chinglish Patterns and Corrections

### Word-Level Issues

| Chinglish | Correction | Explanation |
|-----------|-----------|-------------|
| "in recent years" (overuse) | "recently" / omit | Direct translation of "近年来", used excessively |
| "play an important role" | varies by context | Direct translation of "起着重要作用", often vague |
| "more and more" | "increasingly" | Direct translation of "越来越" |
| "discuss about" | "discuss" | "discuss" is transitive in English |
| "research on" (as verb) | "investigate" / "study" | "Research" used more as noun in English |
| "the experiment result shows" | "the experimental results show" | Adjective form + plural |
| "according to" (overuse) | "based on" / rephrase | Direct translation of "根据" |

### Sentence-Level Issues

**Problem: Topic-comment structure (Chinese) vs. Subject-verb-object (English)**

```
Chinglish: "This method, its advantage is that it can process large datasets."
Correct:   "The advantage of this method is its ability to process large datasets."
```

**Problem: Missing articles (a, an, the)**

```
Chinglish: "We propose method to solve problem."
Correct:   "We propose a method to solve the problem."
```

**Problem: Redundant phrasing**

```
Chinglish: "In this paper, we propose a novel new method..."
Correct:   "We propose a novel method..."  (or "a new method")

Chinglish: "The purpose of this study is to study..."
Correct:   "This study investigates..."
```

**Problem: Overuse of passive voice**

```
Chinglish: "It was found by us that the results were improved by the new method."
Correct:   "We found that the new method improved the results."
```

## Academic Register Conventions

### Formal vs. Informal

| Informal | Formal Academic |
|----------|----------------|
| "a lot of" | "numerous" / "substantial" |
| "get" | "obtain" / "achieve" |
| "big" | "significant" / "substantial" |
| "show" | "demonstrate" / "indicate" |
| "think" | "hypothesize" / "propose" |
| "look at" | "examine" / "investigate" |
| "pretty good" | "satisfactory" / "promising" |
| "kind of" | "somewhat" / "to some extent" |

### Hedging Language

Academic writing requires appropriate hedging to avoid overclaiming:

```
Too strong: "This proves that X causes Y."
Hedged:     "These results suggest that X may contribute to Y."

Too strong: "It is certain that..."
Hedged:     "It appears likely that..." / "The evidence indicates..."

Too strong: "All researchers agree..."
Hedged:     "There is broad consensus that..." / "Most studies suggest..."
```

## Translation of Domain-Specific Terms

### Building a Terminology Glossary

For each paper, maintain a bilingual glossary to ensure consistency:

```markdown
| Chinese Term | English Term | Domain | Notes |
|-------------|-------------|--------|-------|
| 深度学习 | deep learning | CS/AI | not "depth learning" |
| 损失函数 | loss function | ML | not "lost function" |
| 显著性 | significance | Stats | statistical significance |
| 显著性 | saliency | CV | visual saliency (different!) |
| 鲁棒性 | robustness | General | not "robust nature" |
| 过拟合 | overfitting | ML | not "over-fitting" (no hyphen) |
| 特征提取 | feature extraction | ML/CV | |
| 基准测试 | benchmark | CS | not "base test" |
```

### Using LLMs for Terminology-Aware Translation

```python
prompt = """Translate the following Chinese academic abstract to English.
Requirements:
1. Use formal academic register
2. Maintain these specific translations:
   - 注意力机制 -> attention mechanism
   - 自监督学习 -> self-supervised learning
   - 下游任务 -> downstream task
3. Do not add information not present in the original
4. Preserve all citation markers like [1], [2]

Chinese text:
{source_text}
"""
```

## Quality Assurance Checklist

After translating and editing, verify:

- [ ] All technical terms are correct and consistent throughout
- [ ] Article usage (a/an/the) is correct
- [ ] Subject-verb agreement is correct
- [ ] Tense usage follows disciplinary conventions
- [ ] Hedging language is appropriate
- [ ] No Chinglish patterns remain
- [ ] Numbers, units, and equations are accurate
- [ ] References and citation markers are intact
- [ ] Abstract length meets journal requirements
- [ ] Register is consistently formal
- [ ] No direct translations of Chinese idioms or four-character phrases
