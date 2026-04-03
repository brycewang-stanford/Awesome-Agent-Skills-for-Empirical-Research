---
name: ai-writing-humanizer
description: "Remove AI-generated patterns to produce natural, authentic academic writing"
metadata:
  openclaw:
    emoji: "✏️"
    category: "writing"
    subcategory: "polish"
    keywords: ["humanize", "AI pattern removal", "natural writing", "AI-assisted writing", "writing style"]
    source: "wentor"
---

# AI Writing Humanizer

A skill for identifying and removing characteristic patterns of AI-generated text to produce natural, authentic academic writing. Designed for researchers who use AI tools for drafting and want to ensure the final output reads as genuine scholarly prose.

## Common AI Writing Patterns

### Lexical Patterns to Identify and Replace

AI-generated text frequently overuses certain words and phrases:

```python
def identify_ai_patterns(text: str) -> dict:
    """
    Scan text for common AI-generated writing patterns.

    Returns a report of detected patterns with suggested replacements.
    """
    overused_phrases = {
        # Hedging/filler phrases AI overuses
        'it is important to note that': 'Note that',
        'it is worth mentioning that': '[delete or rephrase]',
        'it should be noted that': '[delete or rephrase]',
        'in the realm of': 'in',
        'in the context of': 'in / for / regarding',
        'a testament to': '[rephrase with specific evidence]',
        'the landscape of': '[delete -- be specific]',
        'a nuanced understanding': '[delete or specify what nuance]',
        'shed light on': 'clarified / revealed / explained',
        'delve into': 'examined / analyzed / investigated',
        'furthermore': '[vary: also, additionally, moreover, or restructure]',
        'moreover': '[vary: in addition, also, or restructure]',
        'utilizing': 'using',
        'leverage': 'use / apply / employ',
        'facilitate': 'enable / support / help',
        'a myriad of': 'many / numerous / various',
        'plays a crucial role': 'is important for / contributes to',
        'in conclusion': '[often unnecessary -- just conclude]',
        'overall': '[often unnecessary filler]',
        'comprehensive': '[usually vague -- be specific about scope]',
        'robust': '[overused -- specify what makes it strong]',
        'multifaceted': '[specify the actual facets]',
        'notably': '[usually filler -- delete or restructure]'
    }

    results = {'detected': [], 'total_flags': 0}

    text_lower = text.lower()
    for phrase, suggestion in overused_phrases.items():
        count = text_lower.count(phrase.lower())
        if count > 0:
            results['detected'].append({
                'phrase': phrase,
                'count': count,
                'suggestion': suggestion
            })
            results['total_flags'] += count

    return results
```

### Structural Patterns

AI text tends to exhibit predictable structural patterns:

```
AI Pattern: Formulaic paragraph structure
  - Topic sentence (broad claim)
  - Supporting point 1
  - Supporting point 2
  - Concluding/transition sentence
  Every paragraph follows this exact template.

Human Fix: Vary paragraph structure
  - Sometimes lead with evidence, then interpret
  - Sometimes pose a question, then answer it
  - Sometimes use a single punchy sentence as a paragraph
  - Let paragraph length vary naturally (2-8 sentences)
```

```
AI Pattern: Excessive parallel construction
  "The study examined X, analyzed Y, and evaluated Z."
  "This approach enhances accuracy, improves efficiency, and reduces cost."

Human Fix: Break parallelism occasionally
  "The study examined X. For Y, a different analytical lens was required,
   so we turned to Z for comparison."
```

## Revision Strategies

### Sentence-Level Humanization

```python
def humanize_sentence_variety(sentences: list[str]) -> dict:
    """
    Analyze sentence variety -- AI text often has uniform sentence lengths
    and structures.
    """
    lengths = [len(s.split()) for s in sentences]
    avg_length = sum(lengths) / len(lengths)
    std_length = (sum((l - avg_length)**2 for l in lengths) / len(lengths)) ** 0.5

    # Check first word variety
    first_words = [s.split()[0].lower() if s.split() else '' for s in sentences]
    unique_first_words = len(set(first_words)) / len(first_words)

    issues = []

    if std_length < 3:
        issues.append(
            f"Sentence lengths are too uniform (avg={avg_length:.0f}, "
            f"std={std_length:.1f}). Mix short (5-10 words) and long "
            f"(20-30 words) sentences."
        )

    if unique_first_words < 0.5:
        repeated = [w for w in set(first_words) if first_words.count(w) > 2]
        issues.append(
            f"Too many sentences start with the same word: {repeated}. "
            f"Vary sentence openings."
        )

    # Check for consecutive similar-length sentences
    uniform_runs = 0
    for i in range(1, len(lengths)):
        if abs(lengths[i] - lengths[i-1]) < 3:
            uniform_runs += 1

    if uniform_runs > len(lengths) * 0.6:
        issues.append("Too many consecutive sentences with similar lengths.")

    return {
        'avg_sentence_length': round(avg_length, 1),
        'length_std': round(std_length, 1),
        'first_word_variety': round(unique_first_words, 2),
        'issues': issues,
        'assessment': 'natural' if not issues else 'needs_revision'
    }
```

### Voice and Perspective

AI text often defaults to an impersonal, overly balanced voice. Academic writing benefits from:

1. **Authorial voice**: Use "we" in multi-author papers. Take clear positions.
2. **Disciplinary conventions**: Match the register of your target journal (some are more formal, others more conversational).
3. **Specific over general**: Replace "many researchers have studied X" with "Smith (2020), Jones (2021), and Lee (2023) each approached X differently."
4. **Genuine hedging**: Use hedging when genuinely uncertain, not as a default.

## Workflow for AI-Assisted Writing

```
Step 1: Draft with AI assistance (outline, first draft)
Step 2: Print the draft and read aloud -- mark anything that sounds generic
Step 3: Replace flagged phrases with your natural voice
Step 4: Add personal scholarly judgment (interpretations, critiques)
Step 5: Insert discipline-specific terminology and citations
Step 6: Vary sentence structure and paragraph length
Step 7: Run the pattern detector to catch remaining AI fingerprints
Step 8: Final read-aloud check
```

## Ethical Considerations

Using AI for writing assistance is increasingly accepted in academia, but transparency is essential. Many journals now require disclosure of AI tool usage. The key ethical principle: you must deeply understand and stand behind every claim in the final text. AI is a drafting tool; scholarly judgment and intellectual ownership remain yours.
