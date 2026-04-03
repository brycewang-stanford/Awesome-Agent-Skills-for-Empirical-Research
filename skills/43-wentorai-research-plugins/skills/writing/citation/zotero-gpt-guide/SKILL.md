---
name: zotero-gpt-guide
description: "Guide to Zotero GPT for AI-powered research assistance within Zotero"
metadata:
  openclaw:
    emoji: "🤖"
    category: "writing"
    subcategory: "citation"
    keywords: ["zotero", "gpt", "ai-assistant", "research-ai", "paper-analysis"]
    source: "https://github.com/MuiseDestiny/zotero-gpt"
---

# Zotero GPT Guide

## Overview

Zotero GPT brings large language model capabilities directly into the Zotero reference manager, allowing researchers to interact with their library and papers through natural language. With over 7,000 GitHub stars, it has become one of the most sought-after Zotero plugins as researchers increasingly look for ways to integrate AI into their academic workflows.

The plugin connects Zotero to various LLM providers including OpenAI, Azure OpenAI, and compatible API endpoints. Researchers can ask questions about papers, generate summaries, extract key findings, compare methodologies across studies, and perform many other analytical tasks without leaving Zotero. The AI has access to the context of your current paper, selected text, annotations, and library metadata.

What makes Zotero GPT particularly powerful for academic work is its tight integration with the Zotero ecosystem. Unlike standalone AI tools where you must copy and paste text, Zotero GPT understands the structure of your library and can reference specific papers, annotations, and collections. This contextual awareness makes it far more effective for research tasks than generic chatbot interfaces.

## Installation and Setup

Install Zotero GPT through the Zotero add-on system:

1. Download the latest `.xpi` file from https://github.com/MuiseDestiny/zotero-gpt/releases
2. In Zotero, navigate to Tools > Add-ons > gear icon > Install Add-on From File
3. Select the `.xpi` file and restart Zotero

Configure your LLM provider:

- Open Zotero Preferences > Zotero GPT
- Select your API provider (OpenAI, Azure, or custom endpoint)
- Set your API key through environment variables for security:
  - For OpenAI: configure `$OPENAI_API_KEY` in your system environment
  - For Azure: configure `$AZURE_OPENAI_KEY` and `$AZURE_OPENAI_ENDPOINT`
  - For custom endpoints: configure `$ZOTERO_GPT_API_KEY` and the endpoint URL
- Select your preferred model (GPT-4 recommended for research tasks)
- Set the maximum token limit for responses
- Configure temperature (lower values like 0.3 produce more focused, deterministic outputs)

Additional configuration options:

- Set default prompts for common research tasks
- Configure context window behavior (how much of the paper to include)
- Enable or disable streaming responses
- Set up custom prompt templates for your specific research needs

## Core Features

**Paper Summarization**: Select a paper in your library and ask Zotero GPT to generate a structured summary. The AI reads the available metadata, abstract, and any annotations you have made to produce a concise overview of the paper's contributions, methods, and findings.

**Question Answering**: While reading a PDF in Zotero's reader, highlight a passage and ask questions about it. The AI provides explanations, contextual information, and connections to broader concepts. This is particularly useful for understanding dense technical content outside your primary expertise.

**Annotation Analysis**: Zotero GPT can analyze your annotations across a paper or collection, identifying themes, contradictions, and patterns in your reading notes. This helps synthesize information from multiple sources into coherent research narratives.

**Methodology Comparison**: When reviewing papers for a literature review, ask the AI to compare methodologies, sample sizes, statistical approaches, and experimental designs across selected papers. This structured comparison accelerates the review process significantly.

**Writing Assistance**: Generate draft text based on your notes and annotations. The AI can help structure arguments, suggest transitions between ideas, and identify gaps in your reasoning that need additional evidence.

**Custom Prompts and Commands**: Define reusable prompt templates for tasks you perform regularly:

```
Command: /critique
Prompt: Analyze the methodology of this paper. Identify strengths,
weaknesses, potential biases, and threats to validity. Structure your
response with clear headings for each category.
```

```
Command: /extract-findings
Prompt: Extract and list the key findings from this paper. For each
finding, note the evidence strength, sample characteristics, and
any caveats mentioned by the authors.
```

## Research Workflow Integration

**Literature Screening**: When processing a large batch of papers from a database search, use Zotero GPT to quickly generate summaries and relevance assessments. Create a custom prompt that evaluates each paper against your specific inclusion criteria, dramatically speeding up the screening phase of systematic reviews.

**Deep Reading Assistance**: During close reading of important papers, use the AI as a discussion partner. Ask it to explain unfamiliar methods, clarify statistical procedures, or provide background on referenced theories. This is especially valuable when reading interdisciplinary papers that span multiple fields.

**Synthesis and Gap Analysis**: After annotating a collection of papers, ask Zotero GPT to identify recurring themes, methodological trends, and research gaps across your annotations. Use the output as a starting point for the synthesis section of your literature review.

**Draft Generation**: When moving from reading to writing, use writing assistance features to generate initial draft paragraphs based on your collected annotations and notes. The AI maintains awareness of your sources, making it easier to produce properly attributed text.

**Recommended Workflow Practices**:
- Always verify AI-generated summaries against the original text
- Use low temperature settings for factual extraction tasks
- Use higher temperature for brainstorming and idea generation
- Keep custom prompts in a shared document for lab-wide consistency
- Review AI outputs critically, especially for numerical claims and citations
- Combine Zotero GPT with Better Notes for a comprehensive knowledge pipeline

## Privacy and Ethical Considerations

When using Zotero GPT with cloud-based LLM providers, be aware that paper content is sent to external servers for processing. Consider these guidelines:

- Review your institution's policies on sending research data to third-party AI services
- For sensitive or embargoed research, consider using local LLM endpoints
- Do not send unpublished manuscripts or confidential data through cloud APIs
- Be transparent about AI assistance in your research methodology sections
- Always attribute AI-generated content appropriately in your publications

## References

- GitHub Repository: https://github.com/MuiseDestiny/zotero-gpt
- Zotero Plugin Directory: https://www.zotero.org/support/plugins
- OpenAI API Documentation: https://platform.openai.com/docs
- Responsible AI Use in Research: https://www.nature.com/articles/d41586-023-00056-7
