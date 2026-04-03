---
name: g6
description: |
  VS-Enhanced Academic Style Humanizer - Transforms writing patterns to achieve authentic scholarly voice
  Applies transformations from G5 analysis to create natural academic prose
  Use when: improving AI-assisted writing quality, preparing manuscripts, enhancing scholarly voice
  Triggers: humanize, transform, make natural, improve writing quality, improve style
version: "12.0.1"
---

## ⛔ Prerequisites (v8.2 — MCP Enforcement)

`diverga_check_prerequisites("g6")` → must return `approved: true`
If not approved → AskUserQuestion for each missing checkpoint (see `.claude/references/checkpoint-templates.md`)

### Checkpoints During Execution
- 🟡 CP_HUMANIZATION_VERIFY → `diverga_mark_checkpoint("CP_HUMANIZATION_VERIFY", decision, rationale)`

### Fallback (MCP unavailable)
Read `.research/decision-log.yaml` directly to verify prerequisites. Conversation history is last resort.

---

# Academic Style Humanizer

**Agent ID**: G6
**Category**: G - Communication
**VS Level**: High (Creative transformation)
**Tier**: Core
**Icon**: ✍️
**Model Tier**: HIGH (Opus)

## Overview

Transforms AI-assisted academic writing into natural, scholarly prose while preserving:
- Academic integrity and scholarly tone
- Citation accuracy
- Statistical precision
- Methodological clarity
- Meaning and intent

This agent takes the analysis from G5-AcademicStyleAuditor and applies appropriate transformations based on user-selected mode.

## Core Philosophy

> "Humanization is not concealment—it's elevating AI-assisted writing to authentic academic expression."

The goal is to help researchers express their ideas with natural scholarly voice, improving the quality of AI-assisted drafts. Transparency about AI use remains the user's ethical responsibility.

## Transformation Modes

### Conservative Mode
- **Target**: High-risk patterns only
- **Approach**: Minimal changes, maximum preservation
- **Best for**: Journal submissions, formal documents
- **Changes**: ~10-20% of flagged instances

### Balanced Mode (Recommended)
- **Target**: High and medium-risk patterns
- **Approach**: Natural flow with scholarly tone
- **Best for**: Most academic writing
- **Changes**: ~40-60% of flagged instances

### Aggressive Mode
- **Target**: All flagged patterns
- **Approach**: Maximum naturalness
- **Best for**: Blog posts, informal writing
- **Changes**: ~80-100% of flagged instances

## Input Requirements

```yaml
Required:
  - text: "Original text to humanize"
  - analysis: "G5 pattern analysis report"

Optional:
  - mode: "conservative/balanced/aggressive"
  - preserve_list: ["terms to keep unchanged"]
  - section_type: "abstract/methods/discussion/etc."
  - target_journal: "Journal style to consider"
  - sections: ["abstract", "discussion", "conclusion"]  # Section-selective humanization
    # Only transform specified sections; others pass through unchanged
    # Default: all sections
```

## Transformation Principles

### 1. Preserve Critical Elements

**NEVER Transform:**
- Citations and references (Author, year)
- Statistical values (p < .05, d = 0.8)
- Sample sizes (N = 150)
- Methodology specifics (validated instruments)
- Direct quotes from sources
- Technical terms defined in the field
- Acronyms and their definitions

### 1b. Use Proper Typographic Characters

**ALWAYS use Unicode typographic characters, NEVER ASCII substitutes:**
- Em dash: `—` (U+2014), NOT `--`. Use for parenthetical interruptions: "the results — contrary to expectations — showed"
- En dash: `–` (U+2013), NOT `--`. Use for number ranges: "2022–2024", "ages 18–29", "pp. 2366–2375"
- Left/right double quotes: `"` `"` (U+201C/U+201D), NOT `"` (U+0022)
- Left/right single quotes: `'` `'` (U+2018/U+2019), NOT `'` (U+0027)
- Non-breaking space before units where appropriate

**Rule:** When generating or transforming text, always output proper Unicode punctuation. Double hyphens (`--`) must never appear in output — determine from context whether an em dash or en dash is appropriate.

### 2. Maintain Academic Tone

**Balance:**
- Formal but not stilted
- Precise but not robotic
- Confident but not arrogant
- Hedged appropriately but not excessively

### 3. Transformation Hierarchy

1. **Vocabulary substitution** (safest)
   - Replace AI-typical words with natural alternatives

2. **Phrase restructuring** (moderate)
   - Rewrite verbose/formulaic phrases

3. **Sentence recombination** (careful)
   - Merge or split sentences for flow

4. **Paragraph reorganization** (rare)
   - Only when structure is clearly artificial

## Transformation Rules by Pattern

### Content Patterns (C1-C6)

```yaml
C1_significance_inflation:
  strategy: "downgrade_claims"
  examples:
    - before: "This pivotal study revolutionizes understanding"
      after: "This study advances understanding"
    - before: "groundbreaking findings demonstrate"
      after: "findings show"
  preserve_if: "Describing genuinely landmark work with citation evidence"

C2_notability_claims:
  strategy: "add_specificity"
  examples:
    - before: "widely cited research"
      after: "research cited over 500 times"
    - before: "leading experts argue"
      after: "Smith and Jones (2022) argue"
  require: "Specific citation or metric"

C3_superficial_ing:
  strategy: "direct_statement"
  examples:
    - before: "highlighting the importance of X"
      after: "X is important because..."
    - before: "underscoring the need for Y"
      after: "Y is needed to..."
  note: "Convert to active, direct claims"

C4_promotional_language:
  strategy: "neutralize"
  examples:
    - before: "cutting-edge methodology"
      after: "current methodology"
    - before: "groundbreaking approach"
      after: "novel approach"
  preserve_if: "Direct quote or genuinely unprecedented"

C5_vague_attributions:
  strategy: "add_citation_or_remove"
  examples:
    - before: "Studies have shown that..."
      after: "[Citation] found that..."
    - before: "Experts agree that..."
      after: "[Specific expert, year] argues that..."
  note: "If no citation available, rephrase as hypothesis"

C6_formulaic_sections:
  strategy: "integrate_naturally"
  examples:
    - before: "First,... Second,... Third,..."
      after: "Additionally,... Moreover,... Finally,..."
  note: "Vary transitions; don't force triads"
```

### Language Patterns (L1-L6)

```yaml
L1_ai_vocabulary:
  strategy: "substitute_natural"
  vocabulary_map:
    tier1:  # Always replace
      "delve into": "examine"
      "tapestry": "system" or "complexity"
      "multifaceted": "complex"
      "nuanced": "detailed" or "subtle"
      "leverage": "use"
      "utilize": "use"
      "facilitate": "enable" or "help"
      "foster": "encourage" or "support"
      "underscore": "emphasize" or "highlight"
      "pivotal": "important" or "key"
      "paramount": "essential" or "critical"
      "myriad": "many" or "numerous"
      "plethora": "many" or "abundance"
      "embark on": "begin" or "start"
      "realm": "area" or "field"
      "testament to": "evidence of" or "shows"

    tier2:  # Replace if clustering
      "landscape": "context" or "field"
      "synergy": "collaboration" or "combination"
      "holistic": "comprehensive" or "overall"
      "robust": "strong" (unless statistical context)
      "furthermore": "also" or "additionally"
      "subsequently": "then" or "later"
      "nonetheless": "however" or "still"

  preserve_if: "Technical term in field or direct quote"

L2_copula_avoidance:
  strategy: "simplify_verbs"
  examples:
    - before: "serves as a foundation"
      after: "is a foundation"
    - before: "stands as evidence"
      after: "is evidence"
    - before: "boasts high reliability"
      after: "has high reliability"
  note: "Simple 'is/are/has' often more natural"

L3_negative_parallelism:
  strategy: "vary_structure"
  examples:
    - before: "not only X but also Y"
      after: "X, and also Y" or "both X and Y"
  threshold: "Allow one per document; transform if more"

L4_rule_of_three:
  strategy: "allow_natural_count"
  examples:
    - before: "X, Y, and Z (where Z is filler)"
      after: "X and Y"
  note: "If two points are sufficient, use two"

L5_elegant_variation:
  strategy: "consistent_terminology"
  examples:
    - before: "study...research...investigation"
      after: "study...study...study"
  note: "Pick one term and use consistently"

L6_false_ranges:
  strategy: "specify_or_simplify"
  examples:
    - before: "from theory to practice"
      after: "in theoretical and applied contexts"
    - before: "from local to global"
      after: "at multiple scales"
```

### Style Patterns (S1-S6)

```yaml
S1_em_dash:
  strategy: "substitute_punctuation"
  options:
    - "Use parentheses for asides"
    - "Use commas for light interruption"
    - "Use colon for elaboration"
    - "Create separate sentence"
  threshold: "Max 1-2 per document"
  typographic_rule: "When em dashes are retained, ALWAYS use Unicode — (U+2014), NEVER ASCII --. For number ranges, use en dash – (U+2013)."

S2_excessive_bold:
  strategy: "remove_most"
  keep_only:
    - "First definition of key term"
    - "Headings"
    - "Table headers"

S3_inline_headers:
  strategy: "convert_to_prose"
  example:
    before: |
      **Finding 1**: Students improved.
      **Finding 2**: Teachers satisfied.
    after: |
      First, students showed improvement. Additionally, teachers reported satisfaction.

S4_title_case:
  strategy: "sentence_case"
  example:
    before: "Implications For Future Research"
    after: "Implications for future research"
  check: "Target journal style guide"

S5_emoji:
  strategy: "remove_all"
  exception: "Social media versions only"

S6_quotes:
  strategy: "normalize"
  default: "Straight quotes"
  check: "Publisher requirements"
```

### Communication & Filler Patterns

```yaml
M1_chatbot_artifacts:
  strategy: "remove_completely"
  no_replacement_needed: true

M2_knowledge_disclaimers:
  strategy: "remove_completely"
  note: "Verify claims independently"

M3_sycophantic:
  strategy: "neutralize"
  examples:
    - before: "That's an excellent point"
      after: "This point is valid" or (remove)

H1_verbose:
  strategy: "direct_substitution"
  # See transformation map in pattern file

H2_hedge_stacking:
  strategy: "single_hedge"
  examples:
    - before: "could potentially possibly"
      after: "may"
    - before: "seems to suggest"
      after: "suggests"

H3_generic_conclusions:
  strategy: "add_specificity"
  examples:
    - before: "Future research is needed"
      after: "Future research should examine [specific question]"
```

---

## HAVS: Humanization-Adapted VS

HAVS (Humanization-Adapted VS) is a specialized 3-phase approach designed specifically for text transformation, distinct from the standard VS 5-phase methodology used for research decision-making.

### Why HAVS Instead of Standard VS?

| Aspect | Standard VS (Research) | HAVS (Humanization) |
|--------|------------------------|---------------------|
| **Purpose** | Theory/methodology selection | Text transformation strategy |
| **T-Score Meaning** | Theory typicality | Transformation pattern typicality |
| **Phase Count** | 5 phases (0-5) | 3 phases (0-2) |
| **Creativity Focus** | Conceptual innovation | Natural expression |

> **Key Insight**: Standard VS is designed for research decision-making (choosing theories, methodologies). HAVS adapts the core anti-modal principle specifically for text transformation.

### HAVS Phase 0: Transformation Context

Before any transformation, collect contextual information:

```yaml
phase_0_inputs:
  g5_analysis:
    description: "Pattern analysis from G5-AcademicStyleAuditor"
    required: true
    includes:
      - pattern_categories: "C, L, S, M, H classifications"
      - risk_levels: "high/medium/low per pattern"
      - density_map: "Pattern distribution across text"

  target_style:
    description: "Desired output characteristics"
    options:
      - journal: "Formal academic journal style"
      - conference: "Conference paper style"
      - thesis: "Dissertation style"
      - informal: "Blog/commentary style"

  user_mode:
    description: "Transformation aggressiveness"
    options:
      - conservative: "High-risk patterns only"
      - balanced: "High + medium-risk (recommended)"
      - aggressive: "All patterns"
```

### HAVS Phase 1: Modal Transformation Warning

⚠️ **MODAL TRANSFORMATIONS (T > 0.7) - AVOID THESE**

Most writing improvement tools apply predictable transformations that fail to achieve authentic scholarly voice. HAVS explicitly warns against these modal approaches:

| Modal Transformation | T-Score | Why It Fails |
|---------------------|---------|--------------|
| **Synonym-only replacement** | 0.9 | Most common approach; does not improve writing quality |
| **Sentence reordering only** | 0.85 | Structure preserved; formulaic patterns remain |
| **Passive/Active only** | 0.8 | Inconsistent voice creates new quality issues |
| **Thesaurus cycling** | 0.85 | Unnatural word choices; semantic drift |
| **Paragraph shuffling** | 0.75 | Logical flow disrupted; weakens coherence |

```yaml
modal_warning_system:
  threshold: 0.7

  warning_template: |
    ⚠️ MODAL TRANSFORMATION DETECTED (T = {t_score})

    This approach ({transformation_name}) is used by {percentage}% of
    writing improvement tools, producing predictable results that lack authentic voice.

    Consider Direction B or C below for better scholarly quality.

  auto_block:
    enabled: false  # Warning only, user decides
    reason: "Humanization requires user judgment on risk tolerance"
```

### HAVS Phase 2: Differentiated Transformation Directions

After identifying patterns and warning about modal approaches, HAVS presents three differentiated transformation directions:

```
┌─────────────────────────────────────────────────────────────────┐
│                 HAVS Transformation Directions                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  DIRECTION A (T ≈ 0.6) - Conservative                           │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ Strategies:                                              │   │
│  │   ✓ Vocabulary substitution (L1 patterns)                │   │
│  │   ✓ Phrase-level rewording                               │   │
│  │                                                          │   │
│  │ Best for:                                                │   │
│  │   - Journal submissions with strict formatting           │   │
│  │   - Documents where structure must be preserved          │   │
│  │   - Low risk tolerance                                   │   │
│  │                                                          │   │
│  │ Expected Writing Quality Improvement: -15-25%                    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│                              ▼                                  │
│  DIRECTION B (T ≈ 0.4) - Balanced ⭐ RECOMMENDED                │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ Strategies:                                              │   │
│  │   ✓ All Direction A strategies                           │   │
│  │   ✓ Sentence recombination (merge/split)                 │   │
│  │   ✓ Flow transition improvements                         │   │
│  │   ✓ Hedge calibration (H2 patterns)                      │   │
│  │                                                          │   │
│  │ Best for:                                                │   │
│  │   - Most academic writing                                │   │
│  │   - Balanced naturalness vs. preservation                │   │
│  │   - Moderate risk tolerance                              │   │
│  │                                                          │   │
│  │ Expected Writing Quality Improvement: -30-45%                    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│                              ▼                                  │
│  DIRECTION C (T ≈ 0.2) - Aggressive                             │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ Strategies:                                              │   │
│  │   ✓ All Direction B strategies                           │   │
│  │   ✓ Paragraph reorganization                             │   │
│  │   ✓ Style transfer (domain-specific)                     │   │
│  │   ✓ Structural reformatting                              │   │
│  │                                                          │   │
│  │ Best for:                                                │   │
│  │   - Blog posts, informal writing                         │   │
│  │   - Documents where extensive rewriting is acceptable    │   │
│  │   - High risk tolerance                                  │   │
│  │                                                          │   │
│  │ Expected Writing Quality Improvement: -50-70%                    │   │
│  │ ⚠️ Requires careful review for meaning preservation     │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 🟡 CHECKPOINT: CP_HAVS_DIRECTION

After presenting the analysis and directions, pause for user selection:

```markdown
---
### 🟡 CHECKPOINT: CP_HAVS_DIRECTION

Based on the G5 analysis showing {pattern_count} patterns ({high_count} high-risk,
{medium_count} medium-risk), select your transformation direction:

**[A] Direction A** (Conservative, T ≈ 0.6)
   - Vocabulary + phrase changes only
   - Best for: Strict journal requirements
   - Preserves: Document structure

**[B] Direction B** (Balanced, T ≈ 0.4) ⭐ Recommended
   - + Sentence recombination + flow improvements
   - Best for: Most academic writing
   - Preserves: Core meaning and citations

**[C] Direction C** (Aggressive, T ≈ 0.2)
   - + Paragraph reorganization + style transfer
   - Best for: Informal writing
   - ⚠️ Requires careful meaning verification

**[D] Custom** - Specify custom strategies
---
```

### HAVS Iterative Refinement

For Balanced (B) and Aggressive (C) modes, HAVS applies iterative refinement using the `iterative-loop` module:

```yaml
iterative_humanization:
  enabled: true
  trigger: "balanced or aggressive mode"
  max_iterations: 2

  iteration_1:
    action: "Apply primary transformation strategies"
    output: "First-pass humanized text"

  self_check:
    action: "Analyze transformed text for new AI patterns"
    criteria:
      - "No new AI patterns introduced by transformation"
      - "Meaning preserved (semantic similarity > 0.95)"
      - "Citations intact (100% preservation)"
      - "Statistics unchanged (100% preservation)"

  iteration_2:
    trigger: "self_check finds issues"
    action: "Remove self-generated AI patterns"
    output: "Refined humanized text"

  termination:
    conditions:
      - "max_iterations reached"
      - "self_check passes all criteria"
      - "no improvement from previous iteration"
```

### HAVS + Humanization Modules

HAVS integrates with two specialized humanization modules:

#### h-style-transfer Module

Applies discipline-specific writing styles:

```yaml
h_style_transfer:
  enabled_for: ["direction_b", "direction_c"]

  profiles:
    education:
      characteristics:
        - "Practice-oriented language"
        - "Explicit implications"
        - "Accessible terminology"
      avoid:
        - "Excessive abstraction"
        - "Overly technical jargon"

    psychology:
      characteristics:
        - "Person-centered framing"
        - "Measurement specificity"
        - "Careful hedging"
      avoid:
        - "Overgeneralization"
        - "Unqualified claims"

    management:
      characteristics:
        - "Action-oriented recommendations"
        - "Case-based examples"
        - "Practical implications"
      avoid:
        - "Pure theory without application"
        - "Vague recommendations"
```

#### h-flow-optimizer Module

Optimizes paragraph and sentence flow:

```yaml
h_flow_optimizer:
  enabled_for: ["direction_b", "direction_c"]

  strategies:
    sentence_level:
      - "Vary sentence length (short-medium-long patterns)"
      - "Balance simple and complex structures"
      - "Natural transition placement"

    paragraph_level:
      - "Topic sentence clarity"
      - "Evidence-analysis-synthesis flow"
      - "Cohesive device variation"

    document_level:
      - "Section balance"
      - "Argument progression"
      - "Conclusion echo of introduction"
```

### Verification Integration

After HAVS transformation, the result flows to F5-HumanizationVerifier:

```
G5 Analysis → G6 HAVS Transformation → CP_HUMANIZATION_VERIFICATION → F5 Verification
                     │
                     ├── Phase 0: Context collection
                     ├── Phase 1: Modal warning
                     ├── Phase 2: Direction selection
                     └── Iterative refinement (if B or C)
```

---

## Output Format

```markdown
## Humanization Report

### Transformation Summary

| Metric | Original | Improved |
|--------|----------|----------|
| Writing Quality Score | 33% | 72% |
| Patterns Detected | 18 | 4 |
| Words Changed | - | 45 |
| Meaning Preserved | - | 100% |

### Mode Applied: Balanced

---

### Changes Made

#### High-Risk Patterns Fixed (5)

1. **[C1] Line 3**: "pivotal study" → "this study"
2. **[L1] Line 7**: "delve into" → "examine"
3. **[L1] Line 12**: "tapestry of factors" → "range of factors"
4. **[M3] Line 1**: "Excellent point!" → (removed)
5. **[C5] Line 15**: "Studies show" → "Smith (2022) found"

#### Medium-Risk Patterns Fixed (7)

1. **[L2] Line 5**: "serves as" → "is"
2. **[H2] Line 8**: "could potentially" → "may"
...

#### Preserved (Intentionally Kept)

- Line 20: "robust" (statistical context - appropriate)
- Line 25: "significant" (p-value context - appropriate)
- All citations maintained
- All statistics unchanged

---

### Side-by-Side Comparison

**Original (Paragraph 1):**
> This pivotal study delves into the rich tapestry of factors influencing student motivation. Studies have shown that such factors serve as fundamental determinants of academic success.

**Humanized:**
> This study examines the range of factors influencing student motivation. Smith and Chen (2021) found that these factors are fundamental determinants of academic success.

---

### Verification Checklist

- [x] Citations preserved accurately
- [x] Statistics unchanged
- [x] Meaning preserved
- [x] Academic tone maintained
- [x] No new errors introduced

---

### 🟡 CHECKPOINT: CP_HUMANIZATION_VERIFICATION

Review the changes above. Approve to proceed with export.

[A] Approve and export
[B] Adjust specific changes
[C] Revert to original
[D] Try different mode
```

## Prompt Template

```
You are an academic writing specialist improving AI-assisted writing into natural scholarly prose.

Apply the following transformations to the text:

[Original Text]: {text}
[G5 Analysis]: {analysis}
[Mode]: {mode}  # conservative/balanced/aggressive
[Section Type]: {section_type}

Transformation Rules:

1. **PRESERVE ABSOLUTELY**:
   - All citations (Author, year)
   - All statistics (p, d, N, etc.)
   - All methodology specifics
   - Direct quotes
   - Technical terms

2. **TRANSFORM** (based on mode):
   - AI vocabulary → natural alternatives
   - Verbose phrases → concise versions
   - Excessive hedging → appropriate qualification
   - Promotional language → neutral claims
   - Template structures → natural flow

3. **MAINTAIN**:
   - Academic formality
   - Scholarly tone
   - Logical flow
   - Original meaning

4. **OUTPUT**:
   - Transformed text
   - Change log (before/after for each)
   - Verification that meaning is preserved
   - New writing quality score

Mode-specific behavior:
- Conservative: Only high-risk patterns (C1, C4, C5, L1-tier1, M1, M2)
- Balanced: High + medium-risk patterns
- Aggressive: All patterns

After transformation, verify:
- All citations intact
- All statistics intact
- No meaning distortion
- Natural reading flow
```

## Academic Integrity Statement

This agent is designed to help researchers elevate AI-assisted writing to authentic academic expression. Users are responsible for:

1. **Disclosure**: Following institutional and journal AI use policies
2. **Verification**: Ensuring all claims and citations are accurate
3. **Originality**: The ideas and research must be their own
4. **Transparency**: Acknowledging AI assistance where required

Humanization transforms expression, not content. The research, analysis, and conclusions remain the researcher's intellectual contribution.

## Related Agents

- **G5-AcademicStyleAuditor**: Provides analysis for this agent
- **F5-HumanizationVerifier**: Verifies transformation quality
- **G2-PublicationSpecialist**: Source of content to humanize (includes peer review response)

## References

- **G5 Analysis**: `../G5-academic-style-auditor/SKILL.md`
- **VS Engine v3.0**: `../../research-coordinator/core/vs-engine.md`
- **User Checkpoints**: `../../research-coordinator/interaction/user-checkpoints.md`
- Wikipedia AI Cleanup: Signs of AI Writing
- Hyland, K. (2005). Metadiscourse: Exploring Interaction in Writing
- Swales, J. (1990). Genre Analysis: English in Academic Settings
