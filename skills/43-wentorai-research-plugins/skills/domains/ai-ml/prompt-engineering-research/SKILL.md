---
name: prompt-engineering-research
description: "Systematic prompt engineering methods for AI-assisted academic research workf..."
metadata:
  openclaw:
    emoji: "🤖"
    category: "domains"
    subcategory: "ai-ml"
    keywords: ["machine learning", "deep learning", "NLP", "AI coding", "prompt engineering", "LLM"]
    source: "wentor"
---

# Prompt Engineering for Research

A skill for applying systematic prompt engineering techniques in academic research contexts. Covers prompt design patterns, evaluation methodologies, and practical workflows for using large language models (LLMs) as research tools.

## Prompt Design Patterns

### Core Prompting Strategies

| Strategy | Description | Best For | Reliability |
|----------|------------|---------|-------------|
| Zero-shot | Direct instruction, no examples | Simple, well-defined tasks | Moderate |
| Few-shot | Include 2-5 examples in prompt | Pattern matching, formatting | High |
| Chain-of-thought | "Think step by step" | Reasoning, math, analysis | High |
| Role prompting | "You are an expert in..." | Domain-specific tasks | Moderate |
| Structured output | Request JSON/YAML/table format | Data extraction | High |
| Self-consistency | Sample multiple times, majority vote | Fact-checking, reasoning | Very high |

### Research-Specific Prompt Templates

```python
def create_research_prompt(task_type: str, context: dict) -> str:
    """
    Generate a structured prompt for common research tasks.

    Args:
        task_type: One of 'literature_summary', 'methodology_critique',
                   'code_review', 'data_interpretation', 'writing_feedback'
        context: Dict with task-specific context
    """
    templates = {
        'literature_summary': """
You are an academic researcher specializing in {domain}.

Summarize the following paper excerpt, focusing on:
1. The research question and its significance
2. The methodology used
3. Key findings and their implications
4. Limitations acknowledged by the authors
5. How this work relates to {related_topic}

Paper excerpt:
{text}

Provide a structured summary in 200-300 words. Distinguish clearly
between what the authors claim and what the evidence supports.
""",
        'methodology_critique': """
You are a methods expert reviewing a research design.

Evaluate the following methodology description:
{text}

Assess the following:
1. Internal validity: Are there confounding variables not controlled?
2. External validity: How generalizable are the findings?
3. Statistical approach: Is the analysis appropriate for the data?
4. Sample: Is the sample size adequate? Any selection bias?
5. Reproducibility: Could another researcher replicate this?

For each concern, rate severity (minor/moderate/major) and suggest
a specific improvement.
""",
        'data_interpretation': """
You are a statistical consultant helping interpret results.

Given these results:
{results}

Context: {context_description}

Provide:
1. Plain-language interpretation of each result
2. Effect size interpretation (is it practically significant?)
3. Potential alternative explanations
4. Caveats the authors should mention
5. Suggested follow-up analyses

Be precise about what the data does and does not support.
Do not overstate findings.
"""
    }

    template = templates.get(task_type, templates['literature_summary'])
    return template.format(**context)
```

## Chain-of-Thought for Complex Research Tasks

### Structured Reasoning

```python
def research_cot_prompt(question: str, data: str) -> str:
    """
    Create a chain-of-thought prompt for complex research analysis.
    """
    return f"""
I need to analyze the following research question step by step.

Research Question: {question}

Available Data:
{data}

Please reason through this systematically:

Step 1: Identify the key variables and their relationships
Step 2: Consider what statistical test or analytical approach is appropriate
Step 3: Check assumptions required for this approach
Step 4: Perform the analysis or describe how to perform it
Step 5: Interpret the results in context
Step 6: State limitations and alternative interpretations

Show your reasoning at each step before moving to the next.
If you are uncertain about any step, explicitly state the uncertainty
rather than guessing.
"""
```

## Evaluation and Reliability

### Measuring Prompt Effectiveness

```python
def evaluate_prompt(prompt_template: str, test_cases: list[dict],
                     expected_outputs: list[str],
                     model_fn: callable) -> dict:
    """
    Systematically evaluate a prompt template's reliability.

    Args:
        prompt_template: The prompt template with {placeholders}
        test_cases: List of dicts with placeholder values
        expected_outputs: Expected outputs for each test case
        model_fn: Function that takes a prompt string and returns model output
    """
    results = []
    for case, expected in zip(test_cases, expected_outputs):
        prompt = prompt_template.format(**case)

        # Run multiple times for consistency check
        outputs = [model_fn(prompt) for _ in range(3)]

        # Measure consistency (self-agreement)
        from difflib import SequenceMatcher
        similarities = []
        for i in range(len(outputs)):
            for j in range(i+1, len(outputs)):
                sim = SequenceMatcher(None, outputs[i], outputs[j]).ratio()
                similarities.append(sim)

        avg_similarity = sum(similarities) / len(similarities) if similarities else 0

        results.append({
            'test_case': case,
            'n_runs': 3,
            'consistency': round(avg_similarity, 3),
            'outputs': outputs
        })

    return {
        'n_test_cases': len(test_cases),
        'avg_consistency': round(
            sum(r['consistency'] for r in results) / len(results), 3
        ),
        'results': results,
        'reliability': (
            'high' if all(r['consistency'] > 0.8 for r in results)
            else 'moderate' if all(r['consistency'] > 0.5 for r in results)
            else 'low -- prompt needs refinement'
        )
    }
```

## Research Workflow Integration

### Automated Literature Screening

```python
def screen_paper_relevance(title: str, abstract: str,
                            inclusion_criteria: list[str],
                            exclusion_criteria: list[str]) -> str:
    """
    Generate a prompt for AI-assisted paper screening in systematic reviews.
    """
    return f"""
You are screening papers for a systematic review.

Paper:
Title: {title}
Abstract: {abstract}

Inclusion criteria:
{chr(10).join(f'- {c}' for c in inclusion_criteria)}

Exclusion criteria:
{chr(10).join(f'- {c}' for c in exclusion_criteria)}

Evaluate the paper against each criterion and respond with:
1. INCLUDE, EXCLUDE, or UNCERTAIN
2. Which specific criteria were met or not met
3. Confidence level (high/medium/low)

Important: When uncertain, err on the side of INCLUDE (to be screened
at full-text stage). False exclusions are worse than false inclusions
in systematic review screening.
"""
```

## Ethical Considerations

- **Transparency**: Always disclose AI usage in your research methodology
- **Verification**: Never trust LLM outputs without independent verification -- check facts, citations, and calculations
- **Bias awareness**: LLMs can introduce biases; use structured prompts and diverse perspectives
- **Citation integrity**: LLMs may hallucinate citations; verify every reference exists
- **Authorship**: AI tools do not meet authorship criteria (ICMJE); they are tools, not co-authors
- **Reproducibility**: Document the model, version, temperature, and exact prompts used

## Key References

- Wei, J., et al. (2022). Chain-of-thought prompting elicits reasoning in LLMs. *NeurIPS*.
- Brown, T., et al. (2020). Language models are few-shot learners. *NeurIPS*.
