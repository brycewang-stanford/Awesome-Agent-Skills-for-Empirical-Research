---
name: papersgpt-zotero-guide
description: "AI plugin for Zotero with ChatGPT, Claude, and DeepSeek support"
version: 1.0.0
author: wentor-community
source: https://github.com/papersgpt/papersgpt-for-zotero
metadata:
  openclaw:
    category: "writing"
    subcategory: "citation"
    emoji: "📑"
    keywords:
      - zotero
      - ai-assistant
      - paper-summarization
      - chatgpt
      - claude
      - research-reading
---

# PapersGPT for Zotero Guide

A skill for using the PapersGPT plugin to integrate AI assistants (ChatGPT, Claude, DeepSeek) directly into the Zotero reference management workflow for paper summarization, question-answering, and research analysis. Based on papersgpt-for-zotero (2K stars), this skill transforms Zotero from a passive reference store into an active research intelligence tool.

## Overview

Researchers accumulate large Zotero libraries but often lack time to deeply read every paper. PapersGPT addresses this by bringing AI analysis capabilities directly into the Zotero interface. Without leaving the reference manager, researchers can generate summaries, ask specific questions about paper content, compare papers, extract key findings, and get AI-assisted insights that accelerate the literature review process.

The plugin supports multiple AI backends, allowing researchers to choose based on quality, cost, and privacy preferences. All interactions happen in context of the selected paper's full text, ensuring responses are grounded in the actual document rather than the model's general knowledge.

## Setup and Configuration

**Installation**
- Download the plugin from the project's releases page
- Install in Zotero via Tools then Add-ons then Install from File
- Restart Zotero to activate the plugin
- Open plugin preferences to configure the AI backend

**Backend Configuration**
- Select the AI provider: OpenAI (ChatGPT), Anthropic (Claude), or DeepSeek
- Enter the API credentials for your chosen provider
- Set the model version (e.g., GPT-4, Claude Sonnet, DeepSeek-V3)
- Configure context window size and response length preferences
- Set language preferences for AI responses (supports multilingual output)

**Privacy Considerations**
- Paper text is sent to the selected AI provider's API for processing
- Consider using local or self-hosted models for sensitive pre-publication work
- Review your institution's data handling policies before processing restricted materials
- The plugin does not store conversation history on external servers
- API credentials are stored locally in Zotero's configuration

## Core Capabilities

**Paper Summarization**
- Generate concise summaries of any paper in your library
- Customize summary length (tweet, abstract, detailed, comprehensive)
- Focus summaries on specific aspects (methodology, results, contributions)
- Generate bullet-point key takeaways for quick scanning
- Produce structured summaries with standardized sections

**Question-Answering**
- Ask specific questions about a selected paper's content
- The AI grounds its answers in the paper's actual text, citing specific sections
- Follow up with clarifying questions in a conversational format
- Ask for explanations of technical concepts in the paper's context
- Request comparisons between the paper's approach and alternatives

**Critical Analysis**
- Request an evaluation of the paper's methodology strengths and weaknesses
- Ask about potential limitations not acknowledged by the authors
- Get an assessment of the evidence quality for specific claims
- Request identification of assumptions underlying the paper's conclusions
- Compare the paper's findings with known results in the field

## Workflow Patterns

**Triage Workflow**
- When adding a batch of new papers to your library, use AI summaries to quickly assess relevance
- Generate one-paragraph summaries for each new paper
- Based on summaries, sort papers into "read now," "read later," and "archive" categories
- Save AI-generated tags to Zotero items for future filtering
- This approach handles 10-20 papers in the time it would take to manually skim 2-3

**Deep Reading Workflow**
- Before reading a paper, generate a structured summary to preview its content
- While reading, ask questions about confusing passages or technical details
- After reading, use the AI to verify your understanding of key claims
- Generate a literature note combining your annotations with AI analysis
- Store the analysis alongside the paper in Zotero for future reference

**Literature Review Workflow**
- Select a collection of papers for review
- Generate comparative summaries highlighting similarities and differences
- Ask the AI to identify common themes across the collection
- Request a synthesis of findings organized by research question
- Use the AI to draft literature review paragraphs grounded in the selected papers

**Writing Support Workflow**
- When drafting a paper, ask the AI to find relevant quotes from your library
- Request context about how a reference supports your argument
- Generate citation context paragraphs that integrate multiple sources
- Ask for suggestions on which papers in your library are most relevant to a specific claim
- Verify that your characterization of a cited paper's findings is accurate

## Multi-Model Strategy

Different AI models have different strengths:

**ChatGPT (GPT-4)** - Strong general comprehension, good at structured output, broad knowledge base
**Claude** - Strong analytical reasoning, careful about uncertainty, detailed explanations
**DeepSeek** - Cost-effective for batch processing, strong multilingual capabilities

Consider using different models for different tasks: a cost-effective model for initial triage summaries and a more capable model for deep analysis of key papers.

## Integration with Research-Claw

This skill enhances the Research-Claw reading and analysis pipeline:

- Use AI-generated summaries as input for literature search expansion
- Feed paper analyses to writing skills for literature review drafting
- Connect with other Zotero skills for a comprehensive reference management workflow
- Store AI analyses in the Research-Claw knowledge base for cross-session access
- Combine with paper-to-agent skills for even deeper interactive exploration

## Best Practices

- Always verify AI-generated summaries against the original paper for accuracy
- Use AI analysis as a complement to, not a replacement for, close reading of key papers
- Be aware that AI models may hallucinate details not present in the paper
- For systematic reviews, document that AI tools were used and how in your methods section
- Monitor API costs when processing large collections of papers
- Periodically review and update AI-generated notes as your understanding evolves
